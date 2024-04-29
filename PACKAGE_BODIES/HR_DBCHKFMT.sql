--------------------------------------------------------
--  DDL for Package Body HR_DBCHKFMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DBCHKFMT" as
/* $Header: pydbckft.pkb 115.4 2003/06/12 13:54:40 irgonzal ship $ */
------------------------------------------------------------------------------
--			Private Global Definitions
-----------------------------------------------------------------------------
g_package	varchar2(33) := ' hr_dbchkfmt.';  -- Global package name


--  PRIVATE  PROCEDURES
------------------------- is_upper ----------------------------
--
--      Name
--         is _upper  - checks whether the input is upper case.
--
Procedure is_upper(p_str in  varchar2,
                   p_result  out nocopy boolean) is
l_upper_str   varchar2(60) := upper(p_str);
l_proc 	    varchar2(72) := g_package || 'is_upper';
  begin
	hr_utility.set_location ('Entering:'||l_proc,5);
     	if (l_upper_str = p_str) then
	   hr_utility.set_location (l_proc,10);
	   p_result:= TRUE;
	else
	  hr_utility.set_location(l_proc,15);
	   p_result := FALSE;
	end if;
  end is_upper;
----------------------- is _lower -------------------------------------
--	NAME
--	   is_lower  - checks whether the input is lower case
--
procedure is_lower (p_str in varchar2,
                    p_result out nocopy boolean) is
l_lower_str   varchar2(80) ;
l_proc	    varchar2(72) := g_package ||'is_lower';
  begin
	hr_utility.set_location ('Entering:'||l_proc,5);
	l_lower_str := lower(p_str);
	if (l_lower_str = p_str) then
	   hr_utility.set_location (l_proc,10);
	   p_result := TRUE;
	else
	   hr_utility.set_location (l_proc,15);
	   p_result := FALSE;
        end if;
end is_lower;
-------------------------- is_initcap ----------------------------------
--      NAME
--        is_initcap   - checks whether the input is in initcap form.
--
procedure is_initcap (p_str in varchar2,
                      p_result out nocopy boolean) is
l_initcap_str   varchar2(50) ;
l_proc	      varchar2(72) := g_package || 'is_initcap';
  begin
	hr_utility.set_location ('Entering:'||l_proc,5);
	l_initcap_str := initcap(p_str);
	if (l_initcap_str = p_str) then
	   hr_utility.set_location (l_proc,10);
	   p_result:= TRUE;
	else
	 hr_utility.set_location (l_proc,15);
	   p_result:= FALSE;
	end if;
  end is_initcap;
--
--
------------------------- is_db_format -------------------------------
--                      << overloaded >>
--
procedure  is_db_format
  (
   p_value     in     varchar2,
   p_arg_name  in     varchar2,
   p_format    in     varchar2,
   p_curcode   in     varchar2 default null
   ) is

  l_output varchar2(60) := null;
begin

  is_db_format
  (
   p_value,
   l_output,
   p_arg_name,
   p_format,
   p_curcode
   );

end is_db_format;
--
--
------------------------- is_db_format --------------------------------
--  Name
--    is_db_format - Checks for valid database format.
--  Description
--    This checks the validity of the input format by comparing it
--    with equivalent database format.
--
procedure  is_db_format
  (
   p_value            in     varchar2,
   p_formatted_output in out nocopy varchar2,     -- #2734822
   p_arg_name         in     varchar2,
   p_format           in     varchar2,
   p_curcode          in     varchar2 default null
   ) is
--
   l_proc  varchar2(72) := g_package || 'is_db_format';
   l_result  boolean;
   l_output  varchar2(60); --dummy to hold output from checkformat.
   l_value   varchar2(60); --dummy to hold value for checkformat.
   l_rgeflg  varchar2(1); --dummy to hold rangeflag from checkformat.
-------------------------------dbchkdbi ---------------------------------
--       NAME
--        dbchkdbi - check format of database item name.
--       DESCRIPTION
--        Check that db item name only contains legal characters.
--        The legal charaters are as follows:
--        First character : upper or lower case alphabetic characters.
--        Subsequent chars: alpha, numeric or underscore.
--       NOTES
--        Uses the translate function to spot illegal characters.
--        This function is very similar to chkpay, but has been
--        kept separate in case more differences between the
--        format models eventually emerge.
--
procedure dbchkdbi
      (
         p_value in varchar2,
         p_result out nocopy boolean
      ) is
         l_proc varchar2(72) := g_package || 'dbchkdbi';
         l_result varchar(240); -- result from the translate statement.
         l_legal  varchar(100); -- holds list of legal characters.
         l_match  varchar(100); -- holds match characters for translate.
         l_ALPHA  constant
          varchar2(52):='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
         l_NUMERIC constant varchar2(10) := '0123456789';
         l_SPECIAL constant varchar2(2) := '_';
         l_LEGCHAR constant varchar2(1) := 'A'; -- the legal character.
      begin
	 hr_utility.set_location ('Entering:'||l_proc,5);
         -- build up list of legal characters for first character.
         l_legal := l_ALPHA;
         -- now do a translate on the first character of value.
         l_result := translate(substr(p_value,1,1),l_legal,l_LEGCHAR);
         if(nvl(l_result,l_LEGCHAR) <> l_LEGCHAR) then
            hr_utility.set_location (l_proc,10);
            p_result :=FALSE;
         end if;
         -- if string is longer than one character,
         -- check the full legal list.
         if(length(p_value) > 1) then
            l_legal := l_ALPHA || l_NUMERIC || l_SPECIAL;
            l_match := lpad(l_LEGCHAR,length(l_legal),l_LEGCHAR);
            l_result := translate(substr(p_value,2),l_legal,l_match);
            l_result := replace(l_result,l_LEGCHAR,'');
            -- if all characters were legal, expect result to be null.
            if(l_result is not null) then
               hr_utility.set_location (l_proc,15);
                p_result := FALSE;
            end if;
         end if;
         hr_utility.set_location ('Leaving'||l_proc,20);
         p_result := TRUE;
   exception
        when others then
           p_result := FALSE;
      end dbchkdbi;
----------------------------- dbchknacha -------------------------------
--     NAME
--        dbchkknacha - check legal NACHA string.
--     DESCRIPTION
--        Checks that inputs used for NACHA only contain
--        a certain defined range of characters. These are:
--        0-9, A-Z (upper case), blank, asterisk, ampersand,
--        comma, hyphen, decimal and dollar.
--     NOTES
--        Uses translate to check for illegal characters.
--
procedure dbchknacha
      (
         p_value  in  varchar2, -- the name to check.
         p_result out nocopy   boolean   -- result of the formatting.
      ) is
	 l_proc   varchar2(72) := g_package ||'dbchknacha';
	 l_value varchar2(240);  -- local parameter to contain the name.
         l_trres  varchar(240);   -- result from the translate statement.
         l_legal  varchar(100); -- holds list of legal characters.
         l_match  varchar(100); -- holds match characters for translate.
         l_ALPHA   constant varchar2(52) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
         l_NUMERIC constant varchar(10) := '0123456789';
         l_SPECIAL constant varchar(8) := '*&,-.$_ ';
         l_LEGCHAR constant varchar(1) := '*';
      begin
         hr_utility.set_location ('Entering:'||l_proc,5);
         -- convert any alpha characters to upper case.
	 l_value:=p_value;
         l_value := nls_upper(l_value);
         -- build up list of legal characters for first character.
         l_legal := l_ALPHA;
         -- now do a translate on the first character of value.
         l_trres := translate(substr(l_value,1,1),l_legal,l_LEGCHAR);
         if(nvl(l_trres,l_LEGCHAR) <> l_LEGCHAR) then
            p_result := FALSE;
            hr_utility.set_location (l_proc,10);
            return;
         end if;
         -- if string is longer than one character,
         -- check the full legal list.
         if(length(l_value) > 1) then
            l_legal := l_ALPHA || l_NUMERIC || l_SPECIAL;
            l_match := lpad(l_LEGCHAR,length(l_legal),l_LEGCHAR);
            l_trres := translate(substr(l_value,2),l_legal,l_LEGCHAR);
            l_trres := replace(l_trres,l_LEGCHAR,'');
            -- if all characters in value are legal, trres should be null.
            if(l_trres is not null) then
               p_result := FALSE;
               hr_utility.set_location (l_proc,15);
	       return;
            end if;
         end if;
         hr_utility.set_location ('LEAVING ' || l_proc, 20);
   exception
        when others then
           p_result := FALSE;
      end dbchknacha;
---------------------------------- dbchkpay ---------------------------------
--      NAME
--        dbchkpay - check payroll name does not contain illegal characters.
--      DESCRIPTION
--        Used to ensure that a name passed in only comprises of:
--        First character : alpha characters (upper or lower case).
--        Subsequent chars: alpha, space and underscore.
--      NOTES
--        Use the translate function to check for illegal chars.
--
procedure dbchkpay
      (
         p_value in varchar2, -- the name to check.
         p_result out nocopy boolean
      ) is
         l_proc varchar2(72) := g_package || 'dbchkpay';
         l_result varchar(240);  -- result from the translate statement.
         l_legal  varchar2(100); -- holds list of legal characters.
         l_match  varchar2(100); -- hold matching characters for translate.
         l_ALPHA  constant
          varchar2(52):='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
         l_NUMERIC constant varchar(10) := '0123456789';
         l_SPECIAL constant varchar(2) := ' _';
         l_LEGCHAR constant varchar(1) := 'A';
      begin
         hr_utility.set_location ('Entering:'||l_proc,5);
         -- build up list of legal characters for first character.
         l_legal := l_ALPHA;
         -- now do a translate on the first character of value.
         l_result := translate(substr(p_value,1,1),l_legal,l_LEGCHAR);
         if(nvl(l_result,l_LEGCHAR) <> l_LEGCHAR) then
            hr_utility.set_location (l_proc,10);
            p_result := FALSE;
         end if;
         -- if string is longer than one character,
         -- check the full legal list.
         if(length(p_value) > 1) then
            l_legal := l_ALPHA || l_NUMERIC || l_SPECIAL;
            l_match := lpad(l_LEGCHAR,length(l_legal),l_LEGCHAR);
            -- build match string.
            l_result := translate(substr(p_value,2),l_legal,l_LEGCHAR);
            l_result := replace(l_result,l_LEGCHAR,'');
            -- if string contains legal characters, result should be null.
            if(l_result is not null) then
               hr_utility.set_location (l_proc,15);
               p_result := FALSE;
            end if;
         end if;
         hr_utility.set_location ('Leaving:'||l_proc,20);
         p_result:= TRUE;
   exception
        when others then
           p_result := FALSE;
  end dbchkpay;
-------------------------------------------------------------------------
--
--  This is the main body of the is_db_format
--
------------------------------------------------------------------------
   begin
        hr_utility.set_location ('Entering:'||l_proc,5);
	hr_api.mandatory_arg_error(l_proc,p_arg_name,p_value);
        l_result:= TRUE;
        l_value := p_value;
      -- Choose correct action for format specifier.
      if(p_format = 'UPPER') then
        is_upper(p_value,l_result);
        if(l_result = FALSE) then
	  hr_utility.set_message (801, 'HR_7909_CHECK_FMT_UPPER');
	  hr_utility.set_message_token('ARG_NAME', p_arg_name);
	  hr_utility.set_message_token('ARG_VALUE', p_value);
          hr_utility.raise_error;
        end if;
      elsif(p_format = 'LOWER' ) then
        is_lower(p_value,l_result);
        if(l_result = FALSE ) then
	  hr_utility.set_message (801, 'HR_7910_CHECK_FMT_LOWER');
	  hr_utility.set_message_token('ARG_NAME', p_arg_name);
	  hr_utility.set_message_token('ARG_VALUE', p_value);
          hr_utility.raise_error;
        end if;
      elsif(p_format = 'INITCAP' ) then
        is_initcap(p_value,l_result);
        if(l_result = FALSE) then
	  hr_utility.set_message (801, 'HR_7911_CHECK_FMT_INITCAP');
	  hr_utility.set_message_token('ARG_NAME', p_arg_name);
	  hr_utility.set_message_token('ARG_VALUE', p_value);
          hr_utility.raise_error;
        end if;
      elsif(p_format = 'M' or p_format = 'MONEY') then
         begin
           hr_chkfmt.checkformat(l_value, p_format, l_output, NULL, NULL, 'Y', l_rgeflg, p_curcode);
         exception
           when others then
             hr_utility.set_message(801,'HR_7912_CHECK_FMT_MONEY');
	     hr_utility.set_message_token('ARG_NAME', p_arg_name);
	     hr_utility.set_message_token('ARG_VALUE', p_value);
             hr_utility.raise_error;
         end;
      elsif(p_format = 'I' or p_format = 'INTEGER' or p_format = 'H_HH'
            or p_format = 'NUMBER' or p_format = 'ND' or p_format = 'N') then
         begin
           hr_chkfmt.checkformat(l_value, p_format, l_output, NULL, NULL, 'Y', l_rgeflg, p_curcode);
         exception
           when others then
	     hr_utility.set_message(801,'HR_7914_CHECK_FMT_NUMBER');
	     hr_utility.set_message_token('ARG_NAME', p_arg_name);
	     hr_utility.set_message_token('ARG_VALUE', p_value);
             hr_utility.raise_error;
         end;
      elsif(p_format = 'TIMES' or p_format = 'T') then
         begin
           hr_chkfmt.checkformat(l_value, p_format, l_output, NULL, NULL, 'Y', l_rgeflg, p_curcode);
         exception
           when others then
             hr_utility.set_message(801,'HR_7916_CHECK_FMT_HHMM');
	     hr_utility.set_message_token('ARG_NAME', p_arg_name);
	     hr_utility.set_message_token('ARG_VALUE', p_value);
             hr_utility.raise_error;
         end;
      elsif(p_format = 'H_DECIMAL1' or p_format = 'H_DECIMAL2' or p_format = 'H_HHMM' or p_format = 'H_HHMMSS'
            or p_format = 'H_DECIMAL2' or p_format = 'H_DECIMAL3' or p_format = 'HOURS') then
         begin
           hr_chkfmt.checkformat(l_value, p_format, l_output, NULL, NULL, 'Y', l_rgeflg, p_curcode);
         exception
           when others then
             hr_utility.set_message(801,'HR_7918_CHECK_FMT_HDECIMAL');
	     hr_utility.set_message_token('ARG_NAME', p_arg_name);
	     hr_utility.set_message_token('ARG_VALUE', p_value);
             hr_utility.set_message_token('DECIMAL_POINT', '1');
             hr_utility.raise_error;
         end;
      elsif(p_format = 'DB_ITEM_NAME') then
        dbchkdbi(p_value,l_result);
        if(l_result = FALSE) then
          hr_utility.set_message(801,'HR_7919_CHECK_FMT_HR_NAME');
	  hr_utility.set_message_token('ARG_NAME', p_arg_name);
	  hr_utility.set_message_token('ARG_VALUE', p_value);
          hr_utility.raise_error;
         end if;
      elsif(p_format = 'PAY_NAME') then
        dbchkpay(p_value,l_result);
        if(l_result = FALSE) then
          hr_utility.set_message(801,'HR_7919_CHECK_FMT_HR_NAME');
	  hr_utility.set_message_token('ARG_NAME', p_arg_name);
	  hr_utility.set_message_token('ARG_VALUE', p_value);
          hr_utility.raise_error;
         end if;
      elsif(p_format = 'NACHA') then
         dbchknacha(p_value,l_result); -- check for legal NACHA characters
         if(l_result = FALSE) then
            hr_utility.set_message(801,'HR_7930_CHECK_FMT_NACHA');
	    hr_utility.set_message_token('ARG_NAME', p_arg_name);
	    hr_utility.set_message_token('ARG_VALUE', p_value);
            hr_utility.raise_error;
         end if;
      else
         -- invalid format.
         hr_utility.set_message(801,'HR_7944_CHECK_FMT_BAD_FORMAT');
         hr_utility.raise_error;
      end if;
      --
      p_formatted_output := l_output; -- #2734822
      --
      hr_utility.set_location ('Leaving:'||l_proc,10);
   end is_db_format;
 end hr_dbchkfmt;

/
