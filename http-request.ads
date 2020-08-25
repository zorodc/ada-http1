package HTTP.Request with SPARK_Mode => On
is
   package Sliced is
	  type Header is record
		 Key : Indexes;
		 Val : Indexes;
	  end record;
	  subtype Header_Index is Natural range 1 ..  20;
	  type    Header_List  is array (Header_Index) of Header;

	  type Request_Line is record
		 Kind : Indexes; -- Get, Post, ect.
		 Path : Indexes;
		 Vers : Indexes;
	  end record;

	  type Request is record
		 Line    : Request_Line;
		 Headers : Header_List;
		 Cnt     : Natural := 0;
	  end record;
   end Sliced;

   type As_Stored is null record; -- TODO;
   type As_Sliced is new Sliced.Request;
   type Parse_State is private;


   -- Note: Parse is a separate nested pacakge.
   package Parse is
	  type Context is private;
	  procedure One_Char (Ctx : in out Context; Char: in Character);
	  procedure Str_Read (Ctx : in out Context; Str : in String; Cnt: out Natural);
	  procedure Debug    (Ctx : in     Context; Str : in String);

   private
	  type Context is record
		 State : Parse_State;
		 Split : As_Sliced;      -- TODO: Better names for ``Count''
		 Count : Positive := 1;  -- Position of incoming char (1st, 2nd, ..)
	  end record;
   end Parse;

-- Note: Parse is a separate nested package.

private
   type Parse_State is (
	  -- Request Header --
	  Kind, -- Kind: The request method type; Get, Post, ect.
	  Path,
	  Pref, -- HTTP version preferred by client.

	  Line, -- Waiting for the rest of the carriage return sequence.
	  Head, -- Gathering the name of header (Part preceeded by colon ':').
	  SSep, -- Remainder of separator, following colon; (a single space).
	  HBod, -- Body of header. (Following the colon and space);

	  -- Final CRLF; HTTP Requests terminated by an additional CRLF sequence;
	  -- These states represent this final evenuality.
	  Term,     -- Remainder of terminal CRLF sequence (the LF ('\n') part);
	  Done,     -- Done reading all the header sections!
	  Overread, -- A character was fed after all header sections done with!
	  Err       -- Error state; Signals that an error occurred.
	 ) with Default_Value => Kind;
end HTTP.Request;
