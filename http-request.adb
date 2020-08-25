with Ada.Text_IO; use Ada.Text_IO;

package body HTTP.Request is
package body Parse is
   procedure Debug (Ctx : in Context; Str : in String) is
	  function Slice (Idx:    in HTTP.Indexes; Str : in String) return String
	  is        (Str (Idx.First .. Idx.Last));
   begin
	  Put_Line ("KIND: " & Slice (Ctx.Split.Line.Kind, Str));
	  Put_Line ("PATH: " & Slice (Ctx.Split.Line.Path, Str));
	  Put_Line ("VERS: " & Slice (Ctx.Split.Line.Vers, Str));
	  for I in Integer range 1 .. Ctx.Split.Cnt-1 loop
		 Put_Line ("["
		             & Slice (Ctx.Split.Headers (I).Key, Str) & ": "
		             & Slice (Ctx.Split.Headers (I).Val, Str)
		             &
		           "]");
	  end loop;
	  Put_Line ("TERMINAL STATE: " & Parse_State'Image (Ctx.State));
   end Debug;

   package State is
	  type Char_Table is array (Character)   of Parse_State;
	  type Step_Table is array (Parse_State) of  Char_Table;

	  subtype Up  is Character range 'A' .. 'Z';
	  subtype Low is Character range 'a' .. 'z';
	  subtype Num is Character range '0' .. '9';

	  CR : constant Character := ASCII.CR; LF : constant Character := ASCII.LF;

	  -- A mealy machine expressed as a lookup table, for request parsing;
	  Table : Step_Table :=
		(
		 Kind => (Up => Kind,     ' ' => Path,                 others => Err),
		 Path => (Up | Low |'/' | '.' => Path,    ' ' => Pref, others => Err),
		 Pref => (Up | Num |'/' | '.' => Pref,     CR => Line, others => Err),
		 --------------------------------------------------------------------
		 -- TODO: ... Perhaps put the transitions for Responses here.
		 --------------------------------------------------------------------
		 Line => (                                 LF => Head, others => Err),
		 Head => (Up|Low|'-' => Head, ':' => SSep, CR => Term, others => Err),
		 SSep       => ( ' ' => HBod, others => Err ),
		 HBod       => (CR   => Line, others => HBod),
		 Term       => (LF   => Done, others => Err ),
		 Done       => (others => Overread),
		 Overread   => (others => Overread), -- Maps to itself.
		 Err        => (others => Err    )); -- Maps to itself.

	  function Step (St : Parse_State; Ch : Character) return Parse_State
	  is                 (State.Table (St) (Ch));
   end State;

   procedure Update_Split (Req      : in out As_Sliced;
                           Prv, Nxt : in     Parse_State;
                           Count    : in     Natural) is
	  procedure Update (Next_Indxs  : in out Indexes;
	                    Transition  : in     Boolean) is
	  begin
		 if Transition then Next_Indxs.First := Count + 1; end if;
		                    Next_Indxs.Last  := Count;
	  end Update;

	  Trans : Boolean := Prv /= Nxt;
   begin -- TODO: Use inheiritance + casting to have a single function.
	  case Nxt is
		 when Kind => Update (Req.Line.Kind, False);
		 when Path => Update (Req.Line.Path, Trans);
		 when Pref => Update (Req.Line.Vers, Trans);
		 when Head => Update (Req.Headers (Req.Cnt).Key, Trans);
		 when HBod => Update (Req.Headers (Req.Cnt).Val, Trans);
		 when Line => Req.Cnt := Req.Cnt + 1;
		 when others => null;
	  end case;
   end Update_Split;

   procedure One_Char (Ctx : in out Context; Char : in Character) is
	  Next_State : Parse_State;
   begin
	  Next_State := State.Step(Ctx.State, Char);
	  Update_Split (Ctx.Split, Ctx.State, Next_State, Ctx.Count);

	  Ctx. Count := Ctx. Count + 1;
	  Ctx. State := Next_State;
   end One_Char;

   procedure Str_Read (Ctx: in out Context; Str: in String; Cnt: out Natural) is
	  Original : Positive := Ctx.Count;
   begin
	  for I in Str'Range loop
		 One_Char (Ctx, Str (I));
		 exit when Ctx. State = Done;
	  end loop;

	  Cnt := Ctx. Count - Original;
   end Str_Read;
end Parse;
end HTTP.Request;
