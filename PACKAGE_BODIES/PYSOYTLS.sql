--------------------------------------------------------
--  DDL for Package Body PYSOYTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYSOYTLS" as
/* $Header: pysoytls.pkb 120.0 2005/05/29 08:53:45 appldev noship $

 Copyright (c) Oracle Corporation 1995. All rights reserved

 Name          : pysoytls
 Description   : Start Of Year Tools Functions
 Author        : Barry Goodsell
 Date Created  : 15-Aug-95

 Change List
 -----------
 Date        Name            Vers     Bug No   Description
 +-----------+---------------+--------+--------+-----------------------+
  15-Aug-95   B.Goodsell      40.0              First Created

  09-Oct-95   B.Goodsell      40.1              Edits required for
						release

  30-JUL-96   J.Alloun        40.2              Added error handling.

  01-APR-98   A.Rundell      110.1     649418   Added check for invalid
						chars in tax value.
  17-Feb-00   ILeath         115.3              Added extra logic to Prefix
                                                Function to cope with new
                                                'S' codes.
  27-Apr-00   AMills         115.4     1280564  Fixed Prefix function for
                                                2-char tax codes with no
                                                prefix, eg 3L.


 +-----------+---------------+--------+--------+-----------------------+
*/
--
   g_numbers       varchar2(10)  := '0123456789';
   g_alphabet      varchar2(26)  := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
--
 ---------------------------------------------------------------------
 -- NAME                                                            --
 -- pyudet.trim                                    PRIVATE FUNCTION --
 --                                                                 --
 -- DESCRIPTION                                                     --
 -- Function converts the input string to upper case and removes    --
 -- all space characters                                            --
 ---------------------------------------------------------------------
--
function trim (
   p_string             in      varchar2)
return varchar2 is
begin
   return(replace(upper(p_string),' '));
end trim;
--
 ---------------------------------------------------------------------
 -- NAME                                                            --
 -- pyudet.tax_prefix                              PRIVATE FUNCTION --
 --                                                                 --
 -- DESCRIPTION                                                     --
 -- Function strips out the Tax Code Prefix from a Tax Code, or     --
 -- returns null if there is no prefix.                             --
 -- 1999/2000.  Additional work to allow 2 characters in the prefix --
 -- e.g. 'SK'.                                                      --
 ---------------------------------------------------------------------
--
function tax_prefix (
   p_tax_code		in	varchar2)
return varchar2 is
--
l_prefix varchar2(2);
--
begin
--
   if instr(g_numbers,substr(trim(p_tax_code),1,1)) = 0 then
   --
   -- (If the first character of the Tax Code is not a number)
   -- Account for tax codes that have two characters only and the first
   -- character is not a prefix, eg 3L.
   --
    l_prefix :=  replace(translate(substr(trim(p_tax_code),1,2),g_numbers,' '),' ');
   --
   end if; -- else the tax code has a digit as the first
           -- character so has no prefix, can return null.
--
return l_prefix;
--
end tax_prefix;
--
 ---------------------------------------------------------------------
 -- NAME                                                            --
 -- pyudet.tax_value                               PRIVATE FUNCTION --
 --                                                                 --
 -- DESCRIPTION                                                     --
 -- Function strips out the Tax Code Value from a Tax Code, or      --
 -- returns null if there is no value                              --
 ---------------------------------------------------------------------
--
function tax_value (
   p_tax_code		in	varchar2)
return number is

l_tax_value	VARCHAR2(30);

begin

   l_tax_value := replace(translate(trim(p_tax_code),g_alphabet,' '),' ');

   if(translate(l_tax_value,'A'||g_numbers,'A') is not null) then
	l_tax_value := '999999';
   end if;

   return(fnd_number.canonical_to_number(l_tax_value));
end tax_value;
--
 ---------------------------------------------------------------------
 -- NAME                                                            --
 -- pyudet.tax_suffix                              PRIVATE FUNCTION --
 --                                                                 --
 -- DESCRIPTION                                                     --
 -- Function strips out the Tax Code Suffix from a Tax Code, or     --
 -- returns null if there is no suffix                              --
 ---------------------------------------------------------------------
--
function tax_suffix (
   p_tax_code		in	varchar2)
return varchar2 is
begin
   return(replace(translate(substr(trim(p_tax_code),-1,1),g_numbers,' '),' '));
end tax_suffix;
--
end pysoytls;

/
