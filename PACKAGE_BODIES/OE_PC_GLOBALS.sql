--------------------------------------------------------
--  DDL for Package Body OE_PC_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PC_GLOBALS" AS
/* $Header: OEXPPCGB.pls 120.0 2005/06/01 00:05:12 appldev noship $ */

-- type declaration
-- constants
Procedure  Debug_Print (
   p_buffer long
   ,p_title in varchar2 default null
)
is
  i   number;
  j   number;
begin
   --DBMS_OUTPUT.NEW_LINE;
   i := length(p_buffer);

   if (p_title is not null) then
     -- dbms_output.put_line(p_title || '(' || to_char(i) || ' characters) ');
     -- dbms_output.put_line('--------------------------------------------');
	null;
   end if;
   j := 1;
   while (i > 0) loop
      if (i >= 250) then
       --  dbms_output.put_line(substr(p_buffer,j,250));
         i := i - 250;
         j := j+ 250;
      else
       --  dbms_output.put_line(substr(p_buffer,j,i));
         i := 0;
      end if;
   end loop;
   --DBMS_OUTPUT.NEW_LINE;
end Debug_Print;
-------------------------------------------------------*/
END Oe_PC_Globals;

/
