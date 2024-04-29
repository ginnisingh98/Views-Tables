--------------------------------------------------------
--  DDL for Package Body IRC_QUERY_PARSER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_QUERY_PARSER_PKG" 
/* $Header: irctxqpr.pkb 120.0 2005/07/26 15:02:04 mbocutt noship $ */
AS
--
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< remove_sequence >-------------------------------|
-- ---------------------------------------------------------------------------
-- Description:
--   This function replaces the sequential occurrences of a character with a
--   single occurrence of the character in the input text and returns the
--   resulting text.
--   Arguments
--   1)The first argument,input_text, is the input string.
--   2)The second argument,onechar, is the character whose sequential occurrences
--     should be replaced with a single occurrence.
-- -------------------------------------------------------------------------
   FUNCTION remove_sequence(input_text in varchar2, onechar in varchar2)
     return varchar2
   AS
     result varchar2(2000);
     twochar varchar2(2);
   BEGIN
     twochar := onechar || onechar;
     result:=ltrim(rtrim(input_text));
     --
     while(instrb(result,twochar)>0) loop
       result:=replace(result,twochar,onechar);
     end loop;
     --
     return result;
   END remove_sequence;
--
--
-- -------------------------------------------------------------------------
-- |----------------------< remove_spl_chars >-----------------------------|
-- -------------------------------------------------------------------------
-- Description:
--   This function removes the non-allowed characters from the input text
--   and returns the remaining text.
--
--   The ascii values of the allowed characters are:-
--   32,34,37,40, 41,42,45,
--   48-57(both inclusive),
--   65-90(both inclusive),
--   97-122(both inclusive)
-- -------------------------------------------------------------------------
   FUNCTION remove_spl_chars(input_text in varchar2)
     return varchar2
   AS
     result       VARCHAR2 (2000); -- String w/o special characters
     len number := 1;
     l_count number :=1;
     onechar varchar2(30); -- Each Character of the i/p parse_text
     asciiVal number;
   BEGIN
     result := input_text;
     len := length(result);
   --
     while(l_count<=len)loop
       onechar  := substr (result, l_count, 1);
       asciiVal := ascii(onechar);
       if((asciiVal<32)
          or (asciiVal >32 and asciiVal <34)
          or (asciiVal >34 and asciiVal <37)
          or (asciiVal >37 and asciiVal <40)
          or (asciiVal >42 and asciiVal <45)
          or (asciiVal >45 and asciiVal <48)
          or (asciiVal >57 and asciiVal <65)
          or (asciiVal >90 and asciiVal <97)
          or (asciiVal >122 and asciiVal<170)
          or (asciiVal >170 and asciiVal<181)
          or (asciiVal >181 and asciiVal<192)
          or (asciiVal =215)
          or (asciiVal =247)
       )
       then
         result := replace(result,onechar);
         l_count:=l_count-1;
         len := length(result);
       end if;
       l_count := l_count +1;
     end loop;
     --
     --remove unneccesary spaces that would have
     --cropped due to removing the special characters
     --For e.g, 'a / b' becomes 'a  b'due to the above code.
     --
     result := remove_sequence(result,' ');
     return result;
   END remove_spl_chars;
--
--
-- -------------------------------------------------------------------------
-- |--------------------------< query_parser >-----------------------------|
-- -------------------------------------------------------------------------
-- Description:
--   This function returns the parsed text of the input text
--
-- -------------------------------------------------------------------------
   FUNCTION query_parser (input_text IN VARCHAR2)
      RETURN VARCHAR2
   AS
      result varchar2(2000);
      pos number;
      pos2 number;
   begin
      result := upper(input_text);
      result := remove_sequence(result,' ');

      --remove +- as an invalid set of characters
      result:= replace(result,' +-',' ');
      result:= replace(result,'-+ ',' ');
      result:=remove_spl_chars(result);
      result:= replace(result,'*','%');
      --Replace sequential occurrences of % with a single occurrence
      result := remove_sequence(result,'%');

      --Remove trailing '-' characters.
      --We need to handle '-' character only as other
      --operators are removed by remove_spl_chars()

      while(substrb(result,length(result),1) = '-') loop
        result := rtrim(rtrim(result,'-'));
      end loop;

      result:=replace(result,' - ',' ~');
      result:=replace(result,' -',' ~');
      result:=replace(result,'-','\-');
      result:=replace(result,' AND ',' ');
      result:=replace(result,' OR ',' |');
      result:=replace(result,' NOT ',' ~');
      result:=replace(result,'( ','(');
      result:=replace(result,' )',')');
      result:=replace(result,' % ',' ');
      if(substrb(result,length(result)-1,2)=' %') then
        result := substrb(result,1,length(result)-2);
      end if;

      result:=replace(result,' |','#OR#');
      result:=replace(result,' ~','#NOT#');
      result:=replace(result,' ','#AND#');
      result:=replace(result,'#',' ');

      result:=remove_sequence(result,'"');
      pos:=instrb(result,'"',1,1);
      while(pos>0) loop
        pos2:=instrb(result,'"',1,2);
        if(pos2>0) then
          result:=substrb(result,1,pos-1)||'('||replace(substrb(result,pos+1,pos2-pos-1),' AND ',' ')||')'||substrb(result,pos2+1);
        else
          result := substrb(result,1,pos-1) || substrb(result,pos+1);
        end if;
        pos:=instrb(result,'"',1,1);
      end loop;
     result := remove_sequence(result,' ');
     while(instrb(result,' AND AND ')>0) loop
       result:=replace(result,' AND AND ',' AND ');
     end loop;
     result:=ltrim(rtrim(result));
      while (substrb(result,length(result)-3,4) = ' AND') loop
        result:=substrb(result,1,length(result)-4);
      end loop;
      return result;
   END query_parser;
--
--
-- -------------------------------------------------------------------------
-- |------------------------< isInvalidToken >-------------------------------|
-- -------------------------------------------------------------------------
-- Description:
--   This function checks the validity of the parsed text and returns TRUE
--   in the following cases:-
--   a)the parsed text contains at least a wildcard in a token of length 2
--   OR
--   b)the parsed text contains atleast two wildcards in a token of length 3
--   OR
--   c)the parsed text contains a token that starts with '%(' or ends with ')%'
--   d)the parsed text contains only logical operators like AND, NOT, OR
--   Else, false is returned.
-- -------------------------------------------------------------------------
   FUNCTION isInvalidToken (input_text IN VARCHAR2)
      RETURN Boolean
   AS
      result varchar2(2000);
      token irc_search_criteria.keywords%type;
      pos number;
      pos2 number;
      isInvalidOperator boolean := true;
   BEGIN
      result := input_text;
      while(length(result)>0) loop
        pos := instrb(result,' ');
        if(pos=0) then
          pos:=length(result)+1;
        end if;
        token:=substrb(result,1,pos-1);
        result := substrb(result,pos+1);
--dbms_output.put_line(token);
        if(((length(token) = 2) and (instrb(token,'%') > 0))
           OR((length(token) = 3) and (instrb(token,'%',1,2) > 0))) then
          return true;
        elsif (substrb(token,1,2)='%(' OR substrb(token,1,2)='%)' OR substrb(token,length(token)-1,2) = ')%' OR substrb(token,length(token)-1,2) = '(%') then
          return true;
        elsif (NOT((token = 'OR') OR (token = 'AND') OR (token = 'NOT'))) then
          isInvalidOperator := false;
        end if;
      end loop;
      return isInvalidOperator;
   END isInvalidToken;
--
--
-- -------------------------------------------------------------------------
-- |------------------------ isInvalidKeyword >----------------------------|
-- -------------------------------------------------------------------------
-- Description:
--   This function checks the validity of the keyword and returns
--   TRUE if it is invalid and false otherwise.
--   A parsed keyword is invalid if
--   a)it has  null tokens like () or ( )
--   b)any token contains only wildcard characters, eg, (%)
--   c)the parsed keyword contains '(IRC%)'
--   d)the parsed keyword has a leading negative term
--   e)the parsed keyword contains at least one wildcard in a token of
--     length 2 or at least two wildcards in a token of length 3
-- -------------------------------------------------------------------------
   FUNCTION isInvalidKeyword (input_text IN VARCHAR2)
      RETURN Boolean
   AS
      result varchar2(2000);
   BEGIN
      -- Obtain the parsed text from the query_parser()
      result := query_parser(input_text);
      --
      --case 1 : Return true if the parsed keyword contains '()' or '( )'
      --         or is null
      if(result is null or instrb(result,'()')>0 or instrb(result,'( )')>0) then
        return true;
      -- case2  Return true if the parsed keyword contains  just %
      elsif(instrb(result,' % ')>0) then
        return true;
      elsif(substrb(result,1,2)='% ') then
        return true;
      elsif(substrb(result,-2,2)=' %') then
        return true;
      elsif(result='%') then
        return true;
      --case 3 : Return true if the parsed keyword is IRC% or contains 'IRC%'
      elsif(instrb(result,' IRC% ')>0) then
        return true;
      elsif(substrb(result,1,5)='IRC% ') then
        return true;
      elsif(substrb(result,-5,5)=' IRC%') then
        return true;
      elsif(result='IRC%') then
        return true;
      -- case 4 check for starting with a - which always fails
      elsif (substrb(result,1,2)='\-') then
        return true;
      -- case5 Return true if the parsed keyword contains
      --       one wildcard in a token of length 2
      --       or two wildcards in a token of length 3
      elsif(isInvalidToken(result)) then
        return true;
      end if;
      --
     return false;
   END isInvalidKeyword;
--
--
END irc_query_parser_pkg;

/
