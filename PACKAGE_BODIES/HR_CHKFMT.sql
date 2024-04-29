--------------------------------------------------------
--  DDL for Package Body HR_CHKFMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CHKFMT" as
/* $Header: pychkfmt.pkb 120.7 2007/11/06 10:38:55 ayegappa noship $ */

g_group_sep_profile CONSTANT VARCHAR2(2) := NVL(fnd_profile.value('HR_NUMBER_SEPARATOR'),'N');

FUNCTION add_remove_group_separator ( input            IN VARCHAR2
                                    , remove_separator IN BOOLEAN  DEFAULT FALSE)
RETURN VARCHAR2
IS
  l_output VARCHAR2(100);
  l_group_separator  VARCHAR2(2) := substr(ltrim(to_char(1032,'0G999')),2,1);
                                    --NVL(SUBSTR(fnd_profile.value('ICX_NUMERIC_CHARACTERS'),2,1),',');
  l_dec_separator    VARCHAR2(2) := substr(ltrim(to_char(.3,'0D0')),2,1);
                                    --NVL(SUBSTR(fnd_profile.value('ICX_NUMERIC_CHARACTERS'),1,1),'.');
  l_negative_flag  BOOLEAN  := FALSE ;
BEGIN

   IF remove_separator THEN
     l_output := REPLACE(input,l_group_separator,'');
   ELSE

     IF (input<0 and input>-1) THEN     -- Added for bug 5707731.
        l_negative_flag := TRUE;
     END IF;

     l_output := LTRIM(TO_CHAR( TRUNC(TO_NUMBER(input)), '99G999G999G999G999G999G990'));

     IF INSTR(input,l_dec_separator) <> 0 THEN
        l_output := l_output || l_dec_separator || SUBSTR(input,INSTR(input,l_dec_separator) + 1);
     END IF;

     IF (l_negative_flag) THEN          -- Added for bug 5707731
        l_output := '-' || l_output ;
     END IF;


   END IF;

  RETURN l_output;

END add_remove_group_separator;

----------------------------- chkmoney ----------------------------------
/*
   NAME
      chkmoney - format currency.
   DESCRIPTION
       Formats and checks currency input.
       Uses FND_CURRENCIES to get information about precision.
   NOTES
       p_value can be passed in in either NLS or canonical format, as
       indicated by p_value_is_canonical. p_value is always returned in
       NLS format, rounded and padded according to the rules in table
       fnd_currencies.
*/
PROCEDURE chkmoney
(
   p_value   IN OUT NOCOPY VARCHAR2, -- the input to be formatted (see notes).
   p_output  IN OUT NOCOPY VARCHAR2, -- the canonical format of returned p_value.
   p_curcode IN            VARCHAR2, -- currency code.
   p_minimum IN            VARCHAR2, -- minimum in canonical format.
   p_maximum IN            VARCHAR2, -- maximum in canonical format.
   p_rgeflg  IN OUT NOCOPY VARCHAR2, -- success or otherwise of range check.
   p_result     OUT NOCOPY BOOLEAN,  -- the result of the format check.
   p_value_is_canonical IN BOOLEAN --TRUE if value is passed IN in canonical format.
) IS
   RGE_SUCC CONSTANT VARCHAR2(1) := 'S';
   RGE_FAIL CONSTANT VARCHAR2(1) := 'F';
   --
   -- Max and min value that can be handled by the money format.
   --
   MAX_VALUE CONSTANT NUMBER     := 99999999999999999999;
   MIN_VALUE CONSTANT NUMBER     := -99999999999999999999;

   nvalue   NUMBER; -- used to hold p_value as a number.
   noutput  NUMBER; -- used to hold p_output as a number.
   l_value  VARCHAR2(100);
BEGIN
   p_result := TRUE;
   IF p_value_is_canonical THEN
      nvalue := fnd_number.canonical_to_number( p_value );
   ELSE
      IF g_group_sep_profile = 'Y' THEN
         l_value := add_remove_group_separator(p_value,TRUE);
         IF p_value = l_value THEN
            nvalue := TO_NUMBER( l_value );
         ELSIF p_value = add_remove_group_separator(l_value) THEN
            nvalue := TO_NUMBER(l_value);
         ELSE
            nvalue := p_value;
	        p_result := FALSE;
        END IF;
      ELSE
          nvalue := TO_NUMBER( p_value ); --uses session NLS settings.
      END IF;
   END IF;
   SELECT DECODE --round to min acct limits if available.
          ( fc.minimum_accountable_unit,
            NULL, ROUND( nvalue, fc.precision ),
            ROUND( nvalue / fc.minimum_accountable_unit ) * fc.minimum_accountable_unit
          )
   ,      LTRIM
          ( TO_CHAR
            ( DECODE --round to min acct limits if available.
              ( fc.minimum_accountable_unit,
                NULL, ROUND( nvalue, fc.precision ),
                ROUND( nvalue / fc.minimum_accountable_unit ) * fc.minimum_accountable_unit
              )
            , CONCAT --construct NLS format mask.
              ( '99999999999999999990', --currencies formatted without NLS 'G'.
                DECODE( fc.precision, 0, '', RPAD( 'D', fc.precision+1, '9' ) )
              )
            ), ' ' --left trim white space.
          )
   INTO noutput
   ,    p_value
   FROM fnd_currencies fc
   WHERE fc.currency_code = p_curcode;
   -- range checking.
   IF p_minimum IS NOT NULL THEN
      IF noutput < fnd_number.canonical_to_number( p_minimum ) THEN
         p_rgeflg := RGE_FAIL;
      END IF;
   END IF;
   IF p_maximum IS NOT NULL THEN
      IF noutput > fnd_number.canonical_to_number( p_maximum ) THEN
         p_rgeflg := RGE_FAIL;
      END IF;
   END IF;

   IF not (noutput between MIN_VALUE and MAX_VALUE) then
      p_result := FALSE;
   END IF;

   IF g_group_sep_profile = 'Y' THEN
      p_value := add_remove_group_separator(p_value);
   END IF;

   p_output := fnd_number.number_to_canonical( noutput );
EXCEPTION
   -- this catches illegal numbers.
   WHEN VALUE_ERROR THEN
      p_result := FALSE;
   WHEN OTHERS THEN
      p_result := FALSE;
END chkmoney;
--
------------------------------ chkdech ----------------------------------
/*
   NAME
      chkdech - format check hours in decimal format..
   DESCRIPTION
      Converts p_value to an NLS VARCHAR2 representation with p_format
      number of significant decimal places.
      P_result returns FALSE if p_value fails conversion to a number.
   NOTES
       p_value can be passed in in either NLS or canonical format, as
       indicated by p_value_is_canonical. p_value is always returned in
       NLS format, rounded and padded according to p_format.
*/
PROCEDURE chkdech
(
   p_value   IN OUT NOCOPY VARCHAR2, -- the input to be formatted.
   p_format  IN            VARCHAR2, -- the specific format.
   p_minimum IN            VARCHAR2, -- minimum in canonical format.
   p_maximum IN            VARCHAR2, -- maximum in canonical format.
   p_rgeflg  IN OUT NOCOPY VARCHAR2, -- success or otherwise of range check.
   p_result     OUT NOCOPY BOOLEAN,  -- the result of the format check.
   p_value_is_canonical IN BOOLEAN --TRUE if value is passed IN in canonical format.
) IS
   RGE_SUCC CONSTANT VARCHAR2(1) := 'S';
   RGE_FAIL CONSTANT VARCHAR2(1) := 'F';
   decplace PLS_INTEGER;      -- number of decimal places.
   nvalue   NUMBER; -- used to hold p_value as a number.
BEGIN
   p_result := TRUE; -- start by assuming success.
   IF p_value_is_canonical THEN
      nvalue := fnd_number.canonical_to_number( p_value );
   ELSE
      nvalue := TO_NUMBER( p_value ); --uses session NLS settings.
   END IF;
   -- can get dec places from the last character of the format:
   IF p_format = 'HOURS' THEN
      decplace := 3; -- for backwards compatability.
   ELSE
      decplace := TO_NUMBER( SUBSTR( p_format, -1, 1 ) );
   END IF;
   -- round and format the number.
   nvalue :=  ROUND( nvalue, decplace );
   SELECT LTRIM( TO_CHAR( nvalue, CONCAT( '999999999999990',
           DECODE( decplace, 0, '', RPAD( 'D', decplace+1, '9' ) ) ) ) , ' ' )
   INTO p_value
   FROM dual;
   -- range checking.
   IF p_minimum IS NOT NULL THEN
      IF nvalue < fnd_number.canonical_to_number( p_minimum ) THEN
         p_rgeflg := RGE_FAIL;
      END IF;
   END IF;
   IF p_maximum IS NOT NULL THEN
      IF nvalue > fnd_number.canonical_to_number( p_maximum ) THEN
         p_rgeflg := RGE_FAIL;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN --when varchar2 conversion to number fails.
      p_result := FALSE;
END chkdech;
--
--------------------------------- chknum --------------------------------
/*
   NAME
      chknum - check format of number
   DESCRIPTION
      Check format of number (decimal) and integer.
      P_result returns FALSE if p_value fails conversion to a number.
   NOTES
       p_value can be passed in in either NLS or canonical format, as
       indicated by p_value_is_canonical. p_value is always returned in
       NLS format (integers are unaffected by NLS formatting).  Note
       Decimal separater is still required, even for whole decimal
       numbers. E.g. 20 becomes '20.'.
*/
PROCEDURE chknum
(
   p_value   IN OUT NOCOPY VARCHAR2, -- value to be formatted.
   p_output  IN OUT NOCOPY VARCHAR2, -- the canonical format of returned p_value.
   p_minimum IN            VARCHAR2, -- minimum in canonical format.
   p_maximum IN            VARCHAR2, -- maximum in canonical format.
   p_rgeflg  IN OUT NOCOPY VARCHAR2, -- success or otherwise of range check.
   p_format  IN            VARCHAR2, -- the format to check.
   p_result  OUT    NOCOPY BOOLEAN,  -- true (success) or false (failure).
   p_value_is_canonical IN BOOLEAN --TRUE if value is passed IN in canonical format.
) IS
   RGE_SUCC CONSTANT VARCHAR2(1) := 'S';
   RGE_FAIL CONSTANT VARCHAR2(1) := 'F';

   --
   -- Max and min value that can be handled by the number format.
   --
   MAX_VALUE CONSTANT NUMBER     := 99999999999999999999;
   MIN_VALUE CONSTANT NUMBER     := -99999999999999999999;

   nvalue   NUMBER; -- used to hold p_value as a number.
   l_value  VARCHAR2(100);
BEGIN
   p_result := TRUE; -- start by assuming success.
   IF p_value_is_canonical THEN
      nvalue := fnd_number.canonical_to_number( p_value );
   ELSE
      IF g_group_sep_profile = 'Y' THEN
         l_value := add_remove_group_separator(p_value,TRUE);
         IF p_value = l_value THEN
            nvalue := TO_NUMBER( l_value );
         ELSIF p_value = add_remove_group_separator(l_value) THEN
            nvalue := TO_NUMBER(l_value);
         ELSE
            nvalue := p_value;
	        p_result := FALSE;
         END IF;
      ELSE
         nvalue := TO_NUMBER( p_value ); --uses session NLS settings.
      END IF;
   END IF;

   IF p_format = 'INTEGER' or p_format = 'I' THEN
      IF MOD( nvalue, 1 ) <> 0 THEN
         p_result := FALSE; --p_value is not an integer.
      ELSE
         p_value := TO_CHAR( nvalue ); --integers do not have Decimal separater.
      END IF;
   ELSE
      -- Convert number to NLS string.
      if (nvalue = trunc(nvalue)) then
         p_value := LTRIM( TO_CHAR( nvalue, '99999999999999999990' ) );
      else
         p_value := LTRIM( RTRIM( TO_CHAR( nvalue,
                              '99999999999999999990D99999999999999999999' ), '0' ) );
      end if;
   END IF;
   -- range checking.
   IF p_minimum IS NOT NULL THEN
      IF nvalue < fnd_number.canonical_to_number( p_minimum ) THEN
         p_rgeflg := RGE_FAIL;
      END IF;
   END IF;
   IF p_maximum IS NOT NULL THEN
      IF nvalue > fnd_number.canonical_to_number( p_maximum ) THEN
         p_rgeflg := RGE_FAIL;
      END IF;
   END IF;

   IF not (nvalue between MIN_VALUE and MAX_VALUE) then
      p_result := FALSE;
   END IF;

   p_output := fnd_number.number_to_canonical(p_value);

   IF g_group_sep_profile = 'Y' THEN
      p_value := add_remove_group_separator(p_value);
   END IF;
EXCEPTION
   WHEN OTHERS THEN --when varchar2 conversion to number fails.
      p_result := FALSE;
END chknum;
--
--------------------------- checkformat -----------------------------------
/*
   NAME
      checkformat - checks format of various inputs.
   DESCRIPTION
      Entry point for the checkformat routine.
      Is used to check the validity of the following formats:
      CHAR           : arbitrary string of characters.
      UPPER          : converts string to upper case.
      LOWER          : converts string to lower case.
      INITCAP        : init caps string.
      INTEGER        : checks that input is integer.
      NUMBER         : checks input is valid decimal number.
      ND             : Same as number, (another days format).
      TIMES          : checks input is valid time.
      DATE           : checks input is valid date (DD-MON-YYYY).
      HOURS          : checks input is valid number of hours.
      DB_ITEM_NAME   : checks input is valid database item name.
      PAY_NAME       : checks input is valid payroll name.
      NACHA          : checks input contains valid nacha digits.
      KANA           : checks input is KANA character.
   NOTES
      This procedure is called directly from FF RSP user exit.
      Maximum and minimum parameters:
        Use canonical format for decimal numbers.
*/
procedure checkformat
(
   value   in out nocopy varchar2, -- the value to be formatted.
   format  in            varchar2, -- the format to check.
   output  in out nocopy varchar2, -- the formatted value on output.
   minimum in            varchar2, -- minimum value (can be null).
   maximum in            varchar2, -- maximum value (can be null).
   nullok  in            varchar2, -- is ok to be null ?
   rgeflg  in out nocopy varchar2, -- used for range checking.
   curcode in            varchar2  -- currency code to be used for money format.
) is
   result boolean;
   RGE_SUCC constant varchar2(1) := 'S';
   RGE_FAIL constant varchar2(1) := 'F';
--
   -------------------------------- chkdate --------------------------------
   /*
      NAME
         chkdate - check format of date
      DESCRIPTION
         Checks date formats.
      NOTES
         The following date formats are now handled:
         Specified    Real        Input Field Output Field
         ------------ ----------- ----------- ------------
         D_DDMONYY    DD-MON-RR   28-JAN-92   28-JAN-1992
         D_DDMONYYYY  DD-MON-RRRR 28-JAN-1992 28-JAN-1992
         D_DDMONYYYY  DD-MON-RRRR 28-AUG-01   28-AUG-2001
         D_DDMMYY     DD-MM-RR    28-01-92    28-JAN-1992
         D_DDMMYYYY   DD-MM-RRRR  28-01-1992  28-JAN-1992
         D_DDMMYYYY   DD-MM-RRRR  28-01-01    28-JAN-2001
         D_MMDDYY     MM-DD-RR    01-28-02    28-JAN-2002
         D_MMDDYYYY   MM-DD-RRRR  01-28-1992  28-JAN-1992
         D_MMDDYYYY   MM-DD-RRRR  01-28-01    28-JAN-2001
--
         - If format is one of the 'YYYY' types, and only 'YY'
           value is input, the date is output using century rounding.
           See the examples above.
         - The exception handler is used to detect illegal dates.
         - Range checking is allowed on all formats, but the
           limits must be in the same format as the input.
         - The output format is always in 'DD-MON-YYYY'.
         - If the input format has a 2 digit year
   */
   procedure chkdate
   (
      value   in out nocopy varchar2, -- date value to be checked.
      format  in            varchar2, -- the particular date format.
      output  in out nocopy varchar2, -- the converted date format.
      minimum in            varchar2, -- minimum date.
      maximum in            varchar2, -- maximum date.
      rgeflg  in out nocopy varchar2, -- success or otherwise of range check.
      result     out nocopy boolean   -- format success or fail.
   ) is
      realfmt varchar2(11); -- the real format.
      l_date  date;
   begin

      result := TRUE;
      -- now check that we have the correct date format
      -- passed in.
      l_date := fnd_date.displaydate_to_date(value);
--
      -- the date format has been correctly verified.
      -- now return it to the output field in the
      -- canonical format of of 'YYYY/MM/DD'
      output := fnd_date.date_to_canonical(l_date);
--
      -- Return the corrected format to the output.
      -- Needed for instance where user inputs a
      -- value like '01-jan-99' which we want displayed
      -- as '01-JAN-1999'.
      value := fnd_date.date_to_displaydate(l_date);
--
      -- minimum and maximum checking.
      if(minimum is not null) then
         if(l_date < fnd_date.canonical_to_date(minimum)) then
            rgeflg := RGE_FAIL;
            return;
         end if;
      end if;
      if(maximum is not null) then
         if(l_date > fnd_date.canonical_to_date(maximum)) then
            rgeflg := RGE_FAIL;
            return;
         end if;
      end if;
   exception
      -- have to user the 'others' exception, since there is
      -- no specific exception to catch illegal date formats.
      when others then
         result := FALSE;
   end chkdate;
--
   ------------------------------- chkhours --------------------------------
   /*
      NAME
         chkhours - check hours format and convert.
      DESCRIPTION
         Performs the following actions. Firstly, validates
         hours in the following formats: H_HH, H_HHMM, H_HHMMSS.
         Secondly, it converts these to an internal format,
         which is currently number(40,20).
         Will perform conversions such as 112:3 -> 112:30.
      NOTES
         <none>
   */
   procedure chkhours
   (
      value   in out nocopy varchar2, -- the input value to be formatted.
      format  in            varchar2, -- the specific format.
      output  in out nocopy varchar2, -- value in canonical format.
      minimum in            varchar2, -- min hours value in canonical format.
      maximum in            varchar2, -- min hours value in canonical format.
      rgeflg  in out nocopy varchar2, -- indicate success or otherwise of range.
      result     out nocopy boolean   -- success or failure flag.
   ) is
      INT_PREC   constant number := 20; -- internal format precision.
      SEPARATOR  constant varchar2(1) := ':';
      MIN_HHMM   constant number := 3;
      MIN_HHMMSS constant number := 6;
      hours      varchar2(40);
      minutes    varchar2(40);
      seconds    varchar2(40);
      minplussec varchar2(40); -- holds minutes + seconds string.
      len        number;  -- length of the input string.
      minseppos  number;  -- minute separator position.
      secseppos  number;  -- seconds separator position.
      negative   boolean; -- is the input negative??
   begin
      hours := 0;
      minutes := 0;
      seconds := 0;
      negative := FALSE;
      -- if the first character of the input
      -- is a minus sign, we assume the input is negative.
      if(substr(value,1,1) = '-') then
         negative := TRUE;
         value := substr(value,2); -- remove the minus sign.
      end if;
      -- bug 6522314. Added nvl
      len := nvl(length(value),0); -- len of input without any negation sign.
      -- get the values of hours, minutes and seconds,
      -- depending on the format passed.
      if(format = 'H_HH') then
         -- check is number and integer.
         if(trunc(value) <> value) then
            result := FALSE;
            return;
         end if;
         hours := value;
      elsif(format = 'H_HHMM') then
         declare
            check_fmt varchar2(10);
         begin
            if(len < MIN_HHMM) then
               result := FALSE;
               return;
            end if;
            minseppos := instr(value,SEPARATOR); -- where is the colon char.
            -- error if either the separator is the first or last
            -- character, or there is an illegal separator.
            if(minseppos = 1 or minseppos = len or minseppos = 0) then
               result := FALSE;
               return;
            end if;
            hours := substr(value,1,(minseppos - 1));      -- hours string.
            minutes := substr(value,(minseppos + 1),len); -- minutes string.
            -- Check that we do not have any illegal
            -- characters in our format.
            check_fmt := to_char(to_date(minutes,'MI'),'MI');
            minutes := rpad(minutes,2,'0'); -- format correctly.
         end;
      elsif(format = 'H_HHMMSS') then
         minseppos := instr(value,SEPARATOR);    -- pos of minutes sep.
         -- Check that we have a legal minutes separator.
         if(minseppos = 1 or minseppos = len or minseppos = 0) then
            result := FALSE;
            return;
         end if;
         hours := substr(value,1,(minseppos - 1));
         -- check that the hours string represents an integer.
         if(trunc(hours) <> hours) then
            result := FALSE;
            return;
         end if;
         minplussec := substr(value,(minseppos + 1),len);
         minutes := to_char(to_date(minplussec,'MI:SS'),'MI');
         seconds := to_char(to_date(minplussec,'MI:SS'),'SS');
      end if;
--
      -- apply some sanity checks.
      if(hours < 0 or minutes < 0 or minutes > 59 or
      seconds < 0 or seconds > 59) then
         result := FALSE;
         return;
      end if;
--
      -- do the output of the format.
      if(format = 'H_HHMM') then
         value := hours || SEPARATOR || minutes;
      elsif(format = 'H_HHMMSS') then
         value := hours || SEPARATOR || minutes || SEPARATOR || seconds;
      else
         -- format is H_HH.
         null;
      end if;
--
      -- output the converted value.
      output := fnd_number.number_to_canonical(
                  round(hours + (minutes/60) + (seconds/3600),INT_PREC) );
--
      -- having done the checks, we need to check
      -- if we originally had negative input
      if(negative = TRUE) then
         output := '-' || output;
         value := '-' || value;
      end if;
      -- minimum and maximum checking.
      if(minimum is not null) then
         if(fnd_number.canonical_to_number(output) <
                 fnd_number.canonical_to_number(minimum)) then
            rgeflg := RGE_FAIL;
            return;
         end if;
      end if;
      if(maximum is not null) then
         if(fnd_number.canonical_to_number(output) >
                 fnd_number.canonical_to_number(maximum)) then
            rgeflg := RGE_FAIL;
            return;
         end if;
      end if;
   exception
      -- this exception could be raised if illegal
      -- number supplied as a minimum or maximum.
      when value_error then
         result := FALSE;
      when others then
         result := FALSE;
   end chkhours;
--
   -------------------------------- chktime --------------------------------
   /*
      NAME
         chktime - check the format of time.
      DESCRIPTION
         Routine checks that time is correcly formatted.
         Will do format conversions like '2:2' -> '02:20'.
      NOTES
         Exceptions processing used to catch any illegal
         time formats passed to routine.
   */
   procedure chktime
   (
      value   in out nocopy varchar2,
      minimum in            varchar2, -- minimum allow able value
      maximum in            varchar2, -- maximum allowable value
      rgeflg  in out nocopy varchar2, -- success or otherwise of range check.
      result     out nocopy boolean
   ) is
      TIME_SEPARATOR constant varchar2(1) := ':'; -- make this a constant.
      isdate date; -- used when checking is legal date.
      hours   varchar2(2); -- hold hours component.
      minutes varchar2(2); -- hold minutes component.
      len     number;      -- length of string.
      seppos  number;      -- the character position of the time separator.
--
   begin
      -- first thing, check that we have a legal oracle time format.
      isdate := to_date(value,'HH24:MI');  -- raises exception if not.
      seppos := instr(value,TIME_SEPARATOR);  -- look for legal separator.
      if(seppos = 0) then
         result := FALSE;
         return;
      end if;
      -- separate hours and minutes.
      len := length(value); -- how long the time string.
      hours := substr(value,1,(seppos - 1));     -- get hours string.
      minutes := substr(value,(seppos + 1),len); -- get minutes string.
      -- now we put them together using lpad and rpad to format correctly.
      value := lpad(hours,2,'0') || TIME_SEPARATOR || rpad(minutes,2,'0');
--
      -- check this again following formatting.
      isdate := to_date(value,'HH24:MI');
      --
      result := TRUE;
      if(minimum is not null) then
        if(isdate <
          to_date(minimum,'HH24:MI')) then
          rgeflg := RGE_FAIL;
          return;
        end if;
      end if;
      if(maximum is not null) then
        if(isdate >
          to_date(maximum,'HH24:MI')) then
          rgeflg := RGE_FAIL;
          return;
        end if;
      end if;
   exception
      -- use 'others' exception because there are
      -- no specific errors we can trap for illegal times.
      when others then
         result := FALSE;
   end chktime;
--
   -------------------------------- chkpay ---------------------------------
   /*
      NAME
         chkpay - check payroll name does not contain illegal characters.
      DESCRIPTION
         Used to ensure that a name passed in only comprises of:
         First character : alpha characters (upper or lower case).
         Subsequent chars: alpha, numeric, space and underscore.
      NOTES
         Use the translate function and dbms_sql package to check for
         illegal chars. Cannot be called from pragma restrict_references
         code.
   */
   function chkpay
   (
      value in varchar2 -- the name to check.
   ) return boolean is
      l_cursor_id binary_integer; -- Cursor for dynamic PL/SQL.
      statement varchar2(2000);    -- Dynamic PL/SQL statement.

      copy  varchar2(240);  -- Copy of string without spaces.

      chunk varchar2(2000); -- Chunk to be syntax-checked.
      spos integer;         -- Start position of chunk in input string.
      epos integer;         -- End position of chunk in input string.
      clen number;          -- Length of input string in characters.
      first boolean;        -- Is this the first chunk being processed ?

      -- The following string will be added to any chunks to avoid problems
      -- with reserved words being rejected.
      MUCK    constant varchar2(3) := 'ZQX';

      -- Variables for checking for PL/SQL characters that aren't
      -- allowed in name syntax.
      exchk varchar2(240);
      match varchar2(240);
      PADCH constant varchar2(1) := '$';

      SPACE constant varchar2(1) := ' ';

      -- Valid PL/SQL identifier name characters that are are illegal
      -- in HR, Payroll, and Formula names.
      PLSQL_EXCLUDE varchar2(64);
      -- Maximum length of the name being checked in bytes.
      MAX_NAME_LEN  constant number := 80;
      -- Maximum PL/SQL name length in bytes.
      MAX_PLSQL_LEN constant number := 30;
   begin
      -------------------------------------------------------------
      -- Name syntax is a letter followed by a string containing --
      -- letters, digits, ' ', and '_'. PL/SQL does not have any --
      -- character classification functions e.g. to say what's a --
      -- 'letter' or a 'digit'. PL/SQL identifier name syntax is --
      -- the same as the name syntax except that it allows '#'   --
      -- and '$' characters in the names, and allows " quoted    --
      -- identifier names which may contain spaces.              --
      -------------------------------------------------------------
      -- The basic algorithm is to use the input value as a      --
      -- PL/SQL identifier name in some dynamic PL/SQL code. The --
      -- PL/SQL parser will syntax check the value as a PL/SQL   --
      -- identifier name - if an error is detected an exception  --
      -- will be raised. The code can reject values that contain --
      -- '#', '$', or could be quoted identifiers, before trying --
      -- to parse the dynamic PL/SQL. If the parse is okay, the  --
      -- syntax is okay. The algorithm is slightly complicated   --
      -- by fact the PL/SQL names may only be up 30 bytes in     --
      -- length, whereas the names being checked may be up to 80 --
      -- bytes in length. The input value is chopped into chunks --
      -- of size 30 bytes or less and the PL/SQL test is run on  --
      -- the chunks.                                             --
      -------------------------------------------------------------

      if ( ( value is not null or length( value ) <> 0 ) and
           lengthb( value ) <= MAX_NAME_LEN ) then

         -- Set up the PL/SQL exclusion characters.
         PLSQL_EXCLUDE := '"$#' || to_multi_byte( '"$#' );

         -- Check that the string does not contain any excluded PL/SQL
         -- characters.
         match := PADCH;
         match := lpad( match, length( PLSQL_EXCLUDE ), PADCH );
         exchk := translate( value, PLSQL_EXCLUDE, match );
         exchk := replace( exchk, PADCH, '' );
         if ( exchk is null or length( exchk ) < length( value ) ) then
            return( FALSE );
         end if;

         -- We have to operate on a copy of the string without the spaces
         -- because PL/SQL variable names may not contain spaces.
         if ( substr( value, 1, 1 ) = SPACE ) then
            return( FALSE );
         end if;
         copy := replace( value, SPACE, '' );
         clen := length( copy );

         -- Check the name string chunk by chunk. Need to do this chunk
         -- by chunk because string can be longer than the PL/SQL allows.

         -- Set up information for the first chunk to be checked.
         first := TRUE;
         spos := 1;
         epos := clen;
         chunk := copy || MUCK;

         while ( spos <= clen ) loop
            -- Make sure that the chunk is short enough for PL/SQL to
            -- handle.
            while ( lengthb( chunk ) > MAX_PLSQL_LEN ) loop
               epos := ( spos + epos ) / 2;
               if ( first ) then
                  -- Append MUCK to make sure that the start of the name
                  -- is okay.
                  chunk := substr( copy, spos, epos - spos + 1 ) || MUCK;
               else
                  -- Prepend MUCK because the chunk may not start with a
                  -- letter.
                  chunk := MUCK || substr( copy, spos, epos - spos + 1 );
               end if;
            end loop;

            if ( first ) then
               first := FALSE;
            end if;

            -- Build a dynamic SQL statement using the name as a variable
            -- name. This will syntax check the name as a valid PL/SQL name.
            statement := 'DECLARE ' || chunk || ' NUMBER;BEGIN ' ||
                         chunk || ':=1;END;';
            l_cursor_id := dbms_sql.open_cursor;
            dbms_sql.parse( l_cursor_id, statement, dbms_sql.native );
            dbms_sql.close_cursor( l_cursor_id );

            -- Move onto next the chunk.
            spos := epos + 1;
            epos := clen;
            if ( spos <= clen ) then
               -- Prepend MUCK because the chunk may not start
               -- with a letter.
               chunk := MUCK || substr( copy, spos, epos - spos + 1 );
            end if;
         end loop;

         -- Exited the loop without problems, so value is good.
         return( TRUE );
     else
        -- String is null, zero length, or too long.
        return( FALSE );
     end if;

     -- Exception handler to catch errors in the dynamic SQL ie.
     -- the syntax of the chunk being tested is invalid.
     exception
        when others then
        begin
           --
           -- Make sure that the cursor was closed.
           --
           if ( dbms_sql.is_open( l_cursor_id ) ) then
              dbms_sql.close_cursor( l_cursor_id );
           end if;
           return( FALSE );
        end;
   end chkpay;
--
   -------------------------------- chkdbi ---------------------------------
   /*
      NAME
         chkdbi - check format of database item name.
      DESCRIPTION
         Check that db item name only contains legal characters.
         The are the following:
         First character : upper or lower case alphabetic characters.
         Subsequent chars: alpha, numeric or underscore.

         JULY-2004: introduced a new style of database item name where
         any text within double-quotes is allowed.

      NOTES
         Use the translate function and dbms_sql package to check for
         illegal chars. Cannot be called from pragma restrict_references
         code.
   */
   function chkdbi
   (
      value in varchar2 -- the name to check.
   ) return boolean is
      l_cursor_id binary_integer; -- Cursor for dynamic PL/SQL.
      statement varchar2(2000);    -- Dynamic PL/SQL statement.

      chunk varchar2(2000); -- Chunk to be syntax-checked.
      spos integer;         -- Start position of chunk in input string.
      epos integer;         -- End position of chunk in input string.
      clen number;          -- Length of input string in characters.
      first boolean;        -- Is this the first chunk being processed ?

      -- The following string will be added to any chunks to avoid problems
      -- with reserved words being rejected.
      MUCK    constant varchar2(3) := 'ZQX';

      -- Variables for checking for PL/SQL characters that aren't
      -- allowed in name syntax.
      exchk varchar2(240);
      match varchar2(240);
      PADCH constant varchar2(1) := '$';

      -- Valid PL/SQL identifier name characters that are are illegal
      -- in HR, Payroll, and Formula names.
      PLSQL_EXCLUDE varchar2(64);
      -- Maximum length of the name being checked in characters.
      MAX_NAME_LEN  constant number := 160;
      -- Maximum PL/SQL name length in bytes.
      MAX_PLSQL_LEN constant number := 30;
      -- Maximum  name length in bytes.
      MAX_BYTE_LENGTH constant number := 240;

      QUOTE1  varchar2(16);
      QUOTE2  varchar2(16);
      thechar varchar2(16);
   begin
      -------------------------------------------------------------
      -- Name syntax is a letter followed by a string containing --
      -- letters, digits, and '_'. PL/SQL does not have any      --
      -- character classification functions e.g. to say what's a --
      -- 'letter' or a 'digit'. PL/SQL identifier name syntax is --
      -- the same as the name syntax except that it allows '#'   --
      -- and '$' characters in the names, and allows " quoted    --
      -- identifier names which may contain spaces.              --
      -------------------------------------------------------------
      -- The basic algorithm is to use the input value as a      --
      -- PL/SQL identifier name in some dynamic PL/SQL code. The --
      -- PL/SQL parser will syntax check the value as a PL/SQL   --
      -- identifier name - if an error is detected an exception  --
      -- will be raised. The code can reject values that contain --
      -- '#', '$', or could be quoted identifiers, before trying --
      -- to parse the dynamic PL/SQL. If the parse is okay, the  --
      -- syntax is okay. The algorithm is slightly complicated   --
      -- by fact the PL/SQL names may only be up 30 bytes in     --
      -- length, whereas the names being checked may be up to 80 --
      -- bytes in length. The input value is chopped into chunks --
      -- of size 30 bytes or less and the PL/SQL test is run on  --
      -- the chunks.                                             --
      -------------------------------------------------------------

      if ( ( value is not null or length( value ) <> 0 ) and
           length( value ) <= MAX_NAME_LEN
           and lengthb( value ) <= MAX_BYTE_LENGTH ) then
         --
         -- First look for double-quote delimited value.
         --
         QUOTE1 := '"';
         QUOTE2 := to_multi_byte('"');
         thechar := substr(value, 1, 1);
         if thechar = QUOTE1 or thechar = QUOTE2 then
            --
            -- Minimum acceptable string is "".
            --
            clen := length(value);
            if clen = 1 then
               return FALSE;
            end if;
            --
            -- Check for end-quote.
            --
            thechar :=  substr(value, clen, 1);
            if thechar = QUOTE1 or thechar = QUOTE2 then
               --
               -- Quotes must be paired within the string.
               --
               if clen > 2 then
                  --
                  -- Strip off start and end quotes.
                  --
                  chunk := substr(value, 2, clen - 2);
                  while chunk is not null and
                        instr(chunk, QUOTE1) <> 0 and
                        instr(chunk, QUOTE2) <> 0 loop
                    thechar := substr(chunk, 1, 1);
                    if thechar = QUOTE1 or thechar = QUOTE2 then
                       thechar := substr(chunk, 2, 1);
                       if thechar is not null and
                          (thechar = QUOTE1 or thechar = QUOTE2) then
                          --
                          -- Skip the paired quotes.
                          --
                          chunk := substr(chunk, 3);
                       else
                          --
                          -- Error because of unpaired quote.
                          --
                          return FALSE;
                       end if;
                    else
                       --
                       -- Skip the first character.
                       --
                       chunk := substr(chunk, 2);
                    end if;
                  end loop;
               end if;
               --
               -- It's got here so it's valid.
               --
               return TRUE;
            end if;
            --
            -- No end-quote found.
            --
            return FALSE;
         end if;

         -- Set up the PL/SQL exclusion characters.
         PLSQL_EXCLUDE := '"$#' || to_multi_byte( '"$#' );

         -- Save the length (in characters) of the input string.
         clen := length( value );

         -- Check that the string does not contain any excluded PL/SQL
         -- characters.
         match := PADCH;
         match := lpad( match, length( PLSQL_EXCLUDE ), PADCH );
         exchk := translate( value, PLSQL_EXCLUDE, match );
         exchk := replace( exchk, PADCH, '' );
         if ( exchk is null or length( exchk ) < clen ) then
            return( FALSE );
         end if;

         -- Check the name string chunk by chunk. Need to do this chunk
         -- by chunk because string can be longer than the PL/SQL allows.

         -- Set up information for the first chunk to be checked.
         first := TRUE;
         spos := 1;
         epos := clen;
         chunk := value || MUCK;

         while ( spos <= clen ) loop
            -- Make sure that the chunk is short enough for PL/SQL to
            -- handle.
            while ( lengthb( chunk ) > MAX_PLSQL_LEN ) loop
               epos := ( spos + epos ) / 2;
               if ( first ) then
                  -- Append MUCK to make sure that the start of the name
                  -- is okay.
                  chunk := substr( value, spos, epos - spos + 1 ) || MUCK;
               else
                  -- Prepend MUCK because the chunk may not start with a
                  -- letter.
                  chunk := MUCK || substr( value, spos, epos - spos + 1 );
               end if;
            end loop;

            if ( first ) then
               first := FALSE;
            end if;

            -- Build a dynamic SQL statement using the name as a variable
            -- name. This will syntax check the name as a valid PL/SQL name.
            statement := 'DECLARE ' || chunk || ' NUMBER;BEGIN ' ||
                         chunk || ':=1;END;';
            l_cursor_id := dbms_sql.open_cursor;
            dbms_sql.parse( l_cursor_id, statement, dbms_sql.native );
            dbms_sql.close_cursor( l_cursor_id );

            -- Move onto next the chunk.
            spos := epos + 1;
            epos := clen;
            if ( spos <= clen ) then
               -- Prepend MUCK because the chunk may not start
               -- with a letter.
               chunk := MUCK || substr( value, spos, epos - spos + 1 );
            end if;
         end loop;

         -- Exited the loop without problems, so value is good.
         return( TRUE );
     else
        -- String is null, zero length, or too long.
        return( FALSE );
     end if;

     -- Exception handler to catch errors in the dynamic SQL ie.
     -- the syntax of the chunk being tested is invalid.
     exception
        when others then
        begin
           --
           -- Make sure that the cursor was closed.
           --
           if ( dbms_sql.is_open( l_cursor_id ) ) then
              dbms_sql.close_cursor( l_cursor_id );
           end if;
           return( FALSE );
        end;
   end chkdbi;
--
   -------------------------------- chknacha -------------------------------
   /*
      NAME
         chkknacha - check legal NACHA string.
      DESCRIPTION
         Checks that inputs used for NACHA only contain
         a certain defined range of characters. These are:
         0-9, A-Z (upper case), blank, asterisk, ampersand,
         comma, hyphen, decimal and dollar.
      NOTES
         Uses translate to check for illegal characters.
   */
   procedure chknacha
   (
      value  in out nocopy varchar2, -- the name to check.
      result    out nocopy boolean   -- result of the formatting.
   ) is
      trres  varchar(240);   -- result from the translate statement.
      legal  varchar(100); -- holds list of legal characters.
      match  varchar(100); -- holds match characters for translate.
      ALPHA   constant varchar2(52) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      NUMERIC constant varchar(10) := '0123456789';
      SPECIAL constant varchar(8) := '*&,-.$_ ';
      LEGCHAR constant varchar(1) := '*';
   begin
      -- convert any alpha characters to upper case.
      value := nls_upper(value);
      -- build up list of legal characters for first character.
      legal := ALPHA;
      -- now do a translate on the first character of value.
      trres := translate(substr(value,1,1),legal,LEGCHAR);
      if(nvl(trres,LEGCHAR) <> LEGCHAR) then
         result := FALSE;
         return;
      end if;
      -- if string is longer than one character,
      -- check the full legal list.
      if(length(value) > 1) then
         legal := ALPHA || NUMERIC || SPECIAL;
         match := lpad(LEGCHAR,length(legal),LEGCHAR);
         trres := translate(substr(value,2),legal,LEGCHAR);
         trres := replace(trres,LEGCHAR,'');
         -- if all characters in value are legal, trres should be null.
         if(trres is not null) then
            result := FALSE;
            return;
         end if;
      end if;
   end chknacha;
   --
   ------------------------ chk_half_kana --------------------------------
   procedure chk_half_kana(value in varchar2,
                           result out nocopy boolean) is
     l_charset varchar2(64) := substr(userenv('language'),instr(userenv('language'),'.')+1);
     l_strlen  number := length(value);
     l_ch      varchar2(5);
     l_correct BOOLEAN := TRUE;
     i         number := 1;
   begin
   --
   -- make sure that all the characters are half kana
   --
      while i <= l_strlen and l_correct loop
        l_ch := substr(value, i, 1);
        --
        -- Check if characters are valid against the characterset.
        --
        if l_charset='JA16SJIS' then
          if not ascii(l_ch) between 32 and 126 and
             not ascii(l_ch) between 161 and 223 then
            l_correct := FALSE;
          end if;
        elsif l_charset='JA16EUC' then
          if not ascii(l_ch) between 32 and 126 and
             not ascii(l_ch) between 36513 and 36575 then
            l_correct := FALSE;
          end if;
        elsif (l_charset='UTF8' or l_charset='AL32UTF8') then
          if not ascii(l_ch) between 32 and 126 and
             not ascii(l_ch) between 15711649 and 15711679 and
             not ascii(l_ch) between 15711872 and 15711903 then
            l_correct := FALSE;
          end if;
        else
          --  (Bug 1477718)
          --  Exit and return true when another characterset is used.
          --
          exit;
        end if;
        i := i + 1;
      end loop;
      --
      -- Set out variable
      --
      result:=l_correct;
      --
    end chk_half_kana;
--
begin
   rgeflg := RGE_SUCC; -- start by saying range checking succeeded.
   -- start by checking if the input is allowed to be null.
   if(nullok = 'N' and value is null) then
      hr_utility.set_message(801,'HR_51159_INVAL_VALUE_FORMAT');
      hr_utility.raise_error;
   end if;
   -- if ok to be null and value is null, then return immediately.
   if(nullok = 'Y' and value is null) then
      output := NULL;
      return;
   end if;
   -- Choose correct action for format specifier.
   if(format = 'CHAR' or format = 'C') then
      -- we can have minimum and maximum values.
      if(minimum is not null) then
         if(value < minimum) then
            rgeflg := RGE_FAIL;
         end if;
      end if;
      if(maximum is not null) then
         if(value > maximum) then
            rgeflg := RGE_FAIL;
         end if;
      end if;
      output := value;
   elsif(format = 'UPPER') then
      value := nls_upper(value);
      output := value;
   elsif(format = 'LOWER') then
      value := nls_lower(value);
      output := value;
   elsif(format = 'INITCAP') then
      value := nls_initcap(value);
      output := value;
   --
   elsif(format = 'M' or format = 'MONEY') then
      chkmoney(value,output,curcode,minimum,maximum,rgeflg,result,FALSE);
      if(result = FALSE) then
         hr_utility.set_message(801,'HR_51152_INVAL_MON_FORMAT');
         hr_utility.raise_error;
      end if;
   elsif(format = 'I' or format = 'N' or format = 'NUMBER'
      or format = 'ND') then
      chknum(value,output,minimum,maximum,rgeflg,format,result,FALSE);
      if(result = FALSE) then
         hr_utility.set_message(801,'HR_51153_INVAL_NUM_FORMAT');
         hr_utility.raise_error;
      end if;
      --output is in canonical format
      --output := fnd_number.number_to_canonical( to_number(value) );
   elsif(format = 'H_HH' or format = 'H_HHMM' or
      format = 'H_HHMMSS') then
      chkhours(value,format,output,minimum,maximum,rgeflg,result);
      if(result = FALSE) then
         hr_utility.set_message(801,'HR_51153_INVAL_NUM_FORMAT');
         hr_utility.raise_error;
      end if;
   elsif(format = 'TIMES' or format = 'T') then
      chktime(value, minimum, maximum, rgeflg, result);
      if(result = FALSE) then
         hr_utility.set_message(801,'HR_51154_INVAL_TIME_FORMAT');
         hr_utility.raise_error;
      end if;
      output := value;

   --elsif(format = 'D_DDMONYY' or format = 'D_DDMONYYYY' or
         --format = 'D_DDMMYY' or format = 'D_DDMMYYYY' or
         --format = 'D_MMDDYY' or format = 'D_MMDDYYYY' or
         --format = 'DATE') then
   elsif (format = 'D' or format = 'DATE') then
      chkdate(value,format,output,minimum,maximum,rgeflg,result);
      if(result = FALSE) then
         hr_utility.set_message(801,'HR_51155_INVAL_DATE_FORMAT');
         hr_utility.raise_error;
      end if;
   elsif(format = 'H_DECIMAL1' or format = 'H_DECIMAL2'
      or format = 'H_DECIMAL3' or format = 'HOURS') then
      chkdech(value,format,minimum,maximum,rgeflg,result,FALSE);
      if(result = FALSE) then
         hr_utility.set_message(801,'HR_51153_INVAL_NUM_FORMAT');
         hr_utility.raise_error;
      end if;
      --output is in canonical format
      output := fnd_number.number_to_canonical( to_number(value) );
   elsif(format = 'DB_ITEM_NAME') then
      if(chkdbi(value) = FALSE) then
         hr_utility.set_message(801,'HR_51156_INVAL_NUM_FORMAT');
         hr_utility.raise_error;
      end if;
      output := value;
   elsif(format = 'PAY_NAME') then
      if(chkpay(value) = FALSE) then
         hr_utility.set_message(801,'HR_51157_INVAL_PAY_NAME_FORMAT');
         hr_utility.raise_error;
      end if;
      output := value;
   elsif(format = 'NACHA') then
      chknacha(value,result); -- check for legal NACHA characters
      if(result = FALSE) then
         hr_utility.set_message(801,'HR_51158_INVAL_NACHA_FORMAT');
         hr_utility.raise_error;
      end if;
      output := value;
   elsif(format = 'KANA'or format = 'K') then
      chk_half_kana(value,result);
      if(result = FALSE) then
        hr_utility.set_message(801, 'HR_72021_PER_INVALID_KANA');
        hr_utility.raise_error;
      end if;
   else
      -- invalid format.
      hr_utility.set_message(801,'HR_51159_INVAL_VALUE_FORMAT');
      hr_utility.raise_error;
   end if;
end checkformat;
--
--------------------------- changeformat -----------------------------------
/*
   NAME
      changeformat - converts from internal to external formats.
   DESCRIPTION
      Is called when you need to convert from a format that is
      held in one format internally but which needs to be
      displayed in another format.
   NOTES
      Currently, the following formats require conversion:
      date formats, money and H_HHMM/H_HHMMSS.
*/
function changeformat
(
   input   in     varchar2, -- the input format.
   format  in     varchar2, -- indicates the format to convert to.
   curcode in     varchar2  -- currency code for money format.
) return varchar2 is
--
   value  varchar2(240); -- needed when calling chkdech.
   rgeflg varchar2(1);   -- needed when calling chkdech.
   result boolean;       -- needed when calling chkdech.
   output varchar2(240);      -- the output format.
--
   ---------------------------- to_money ----------------------------------
   /*
      NAME
         to_money - converts internal currency format to external one.
      DESCRIPTION
         Converts a decimal number (in which currency is held)
         to the external format.
      NOTES
         Currently, the internal and external formats are the same,
         but this function exists as a stub for later use.
   */
   function to_money
   (
      input   in varchar2, -- the input to format.
      curcode in varchar2  -- the currency code.
   ) return  varchar2 is
      value  varchar2(240);
      output varchar2(240);
      rgeflg varchar2(10);
      result boolean;
   begin
      -- use the checkformat procedure to handle format.
      value := input;
      chkmoney(value,output,curcode,null,null,rgeflg,result,TRUE);
      return(value);
   end to_money;
--
   ---------------------------- to_hours -----------------------------------
   /*
      NAME
         to_hours - converts decimal hours to hours formats.
      DESCRIPTION
         This converts from decimal into either H_HHMM or H_HHMMSS.
      NOTES
         <none>
   */
   function to_hours(input in varchar2, format in varchar2)
   return varchar2 is
      hours varchar2(100); -- holds the hours string.
      mins  number;        -- holds minutes (and seconds) string.
   begin
      -- separate hours string.
      hours := trunc(fnd_number.canonical_to_number( input ));
      mins  := abs(round((fnd_number.canonical_to_number( input ) - hours)
                          * 3600));
--
      -- Bugfix 4269787
      -- If mins has been rounded to 3600 we have 1 hour!
      if mins = 3600 then
         hours := hours+1;
         mins := 0;
      end if;
--
      -- Bugfix 3650335
      -- Ensure the sign of the input is maintained.
      if hours = '0' and mins > 0
        and sign(fnd_number.canonical_to_number(input)) = -1 then
        --
        -- Prefix the hours value with a minus sign as this will have been
        -- lost in the conversion process.
        --
        hours := '-'||hours;
        --
      end if;
--
      -- process diffferently for H_HHMM and H_HHMMSS.
      if(format = 'H_HHMM') then
         return(hours || ':' ||
         to_char(to_date(to_char(mins),'SSSSS'),'MI'));
      else
         return(hours || ':' ||
         to_char(to_date(to_char(mins),'SSSSS'),'MI:SS'));
      end if;
   end to_hours;
--
   ---------------------------- conv_date ----------------------------------
   /*
      NAME
         conv_date - convert internal to displayed date format.
      DESCRIPTION
         Dates are converted from the universal internal format
         of 'DD-MON-YYYY' to whatever is specified by 'format'.
      NOTES
         <none>
   */
   function conv_date(input in varchar2,format in varchar2)
   return varchar2 is
         l_date date ;
      oraformat varchar2(11);
   begin
      if(format = 'D' or format = 'DATE') then
         l_date := fnd_date.canonical_to_date(input) ;
      else
         oraformat := 'UNKNOWN';  -- this should cause failure.
      end if;
--
      -- now convert to external format.
      return(fnd_date.date_to_displaydate(l_date));
   end conv_date;
--
begin
   if(input is null) then
      output := NULL; -- if input is null, do not do any processing.
      -- main statement to do the conversion.
   else
      if(format = 'H_HHMM' or format = 'H_HHMMSS') then
         output := to_hours(input,format);
      elsif(format = 'M' or format = 'MONEY') then
         output := to_money(input,curcode);
      elsif(format like 'H_DECIMAL%') then
         value := input;
         chkdech(value,format,null,null,rgeflg,result,TRUE);
         output := value;
      elsif(format = 'N' or format = 'NUMBER' or format = 'ND') then
         value := input;
         chknum(value,output,null,null,rgeflg,format,result,TRUE);
         output := value;
      elsif(format = 'INTEGER' or format = 'I' ) then
         value := input;
         chknum(value,output,null,null,rgeflg,format,result,TRUE);
         output := value;
      elsif(format = 'D' or format = 'DATE') then
         -- convert to required external format.
         output := conv_date(input,format);
      else
         -- all other formats remain the same.
         output := input;
      end if;
   end if;
   return(output);
end changeformat;
--
--------------------------- changeformat -----------------------------------
/*
   NAME
      changeformat - converts from internal to external formats.
   DESCRIPTION
      Is called when you need to convert from a format that is
      held in one format internally but which needs to be
      displayed in another format.
   NOTES
      Currently, the following formats require conversion:
      date formats, money and H_HHMM/H_HHMMSS.
*/
procedure changeformat
(
   input   in            varchar2, -- the input format.
   output  out    nocopy varchar2, -- the output formated
   format  in            varchar2, -- indicates the format to convert to.
   curcode in            varchar2  -- currency code for money format.
) is
begin
   output := changeformat(input, format, curcode);
end changeformat;
--
end hr_chkfmt;

/
