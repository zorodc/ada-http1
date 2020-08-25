--
-- Nice little HTTP 1.x request parser. Uses a state machine.
-- Operates by cutting up the incoming request string into sections.
--

package HTTP with SPARK_Mode => On
is
   type Version is delta 0.1 range 1.0 .. 9.9;

   type Indexes is record
	  First : Natural := 1;
	  Last  : Natural := 0;
   end record;
end HTTP;
