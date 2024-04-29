--------------------------------------------------------
--  DDL for Package Body AMS_DISCOVERER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DISCOVERER_PVT" AS
/* $Header: amsvdisb.pls 120.1 2005/12/15 17:48:58 musman noship $ */

/*==========================================================================+
 | PROCEDURES.                                                              |
 |    Create_Discoverer_Url.                                                |
 |    get_source_type_code                                                  |
 |    EUL_TRIGGER$POST_SAVE_DOCUMENT                                        |
 |    Search_SQL_string                                                     |
 +==========================================================================*/

 g_pkg_name      CONSTANT VARCHAR2(30):='AMS_DISCOVERER_PVT';
 g_file_name     CONSTANT VARCHAR2(12):='amsvdisb.pls';


--
-- Foreward Procedure Declarations
--
AMS_DEBUG_HIGH_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE get_source_type_code (
   p_workbook_name   IN VARCHAR2,
   p_worksheet_name  IN VARCHAR2,
   x_source_type_code   OUT NOCOPY VARCHAR2
);


--
-- Procedure Bodies
--

-----------------------------------------------------------------------------
-- Procedure
--   Create_Discoverer_Url

-- PURPOSE
--   Creates a URL which will launch Web Discoverer.
--
-- PARAMETERS

-- NOTES
-- created yxliu 14-Mar-2001
-----------------------------------------------------------------------------
PROCEDURE Create_Discoverer_Url(p_text              IN VARCHAR2,
                                p_application_id    IN NUMBER,
                                p_responsibility_id IN NUMBER,
                                p_function_id       IN NUMBER,
                                p_target            IN VARCHAR2,
                                p_session_id        IN NUMBER,
                                x_discoverer_url    OUT NOCOPY VARCHAR2
                               )
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'Create_Discoverer_Url';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

/*
vbhandar commented to fix  bug 2665683
   x_discoverer_url := ORACLEAPPS.CREATERFLINK(
                 p_text              => p_text
                ,p_application_id    => p_application_id
                ,p_responsibility_id => p_responsibility_id
                ,p_security_group_id => 0
                ,p_function_id       => p_function_id
                ,p_target            => p_target
                ,p_session_id        => p_session_id);
*/
   x_discoverer_url := ICX_SEC.CREATERFURL (
                           p_function_name      => null,
                           p_function_id        => p_function_id,
                           p_application_id     => p_application_id,
                           p_responsibility_id  => p_responsibility_id,
                           p_security_group_id  => 0,
                           p_session_id         => p_session_id
                       );


   IF (AMS_DEBUG_HIGH_ON) THEN





   AMS_Utility_PVT.debug_message(l_full_name||': end');


   END IF;

END;

-----------------------------------------------------------------------------
-- Function
--  EUL_TRIGGER$POST_SAVE_DOCUMENT

-- PURPOSE
--   1. This Function is used by Oracle Discoverer to save a WorkSheets SQL
--      to The AMS_DISCOVERER_SQL table.

--   2. This Function must be Registered as a valid Function using Oracle
--      Discoverer's Administration Edition before any WorkBook SQL will be
--      saved.

-- NOTES
--    choang - 24-jun-2002 - new logic for post save document
--       - get source_type_code for workbook/worksheet
--       - if source_type_code exists, use source_type_code for current record
--       - else merge sql for workbook/worksheet
--       - search for source_type_code in merged sql
--       - if source_type_code exists, update all records for workbook/worksheet
--       - else continue
--
-- HISTORY
-- 13-Apr-2001 yxliu    copied from AMS_DiscovererSQL_PVT
-- 24-Jun-2002 choang   added logic to populate source_type_code
--
-- End of Comments
-----------------------------------------------------------------------------
FUNCTION  EUL_TRIGGER$POST_SAVE_DOCUMENT (
   p_workbookowner IN VARCHAR2,
   p_workbookname  IN VARCHAR2,
   p_worksheetname IN VARCHAR2,
   p_sequence      IN NUMBER,
   p_sqlsegment    IN VARCHAR2
)
RETURN NUMBER
IS

   l_max_sequence_number number;

    -- Declare program variables
    l_sqlerrm varchar2(600);
    l_sqlcode varchar2(100);

   CURSOR c_get_seq IS
      SELECT ams_discoverer_sql_s.NEXTVAL
      FROM DUAL;

   l_discoverer_sql_id     NUMBER;

   -- choang - 24-jun-2002
   -- get the start id for this workbook+worksheet
   -- get the largest sequence_order and source_type_code
   -- to determine if the requested worksheet is a replacement
   -- or a continuation, and if source type code is defined
   CURSOR c_disco (p_workbook_name IN VARCHAR2, p_worksheet_name IN VARCHAR2) IS
      SELECT MIN (discoverer_sql_id), MAX (sequence_order), MAX (source_type_code)
      FROM   ams_discoverer_sql
      WHERE  workbook_name = p_workbook_name
      AND    worksheet_name = p_worksheet_name
      ;

   l_source_type_code      ams_discoverer_sql.source_type_code%TYPE;
BEGIN
   OPEN c_disco (p_workbookname, p_worksheetname);
   FETCH c_disco INTO l_discoverer_sql_id, l_max_sequence_number, l_source_type_code;
   CLOSE c_disco;

/* choang - 24-jun-2002 - replaced with new logic
     --checking for an existing set of entries for this workbook and worksheet combination.
     select max(sequence_order)
     into   l_max_sequence_number
     from   ams_discoverer_sql
     where  workbook_name  = P_WorkBookName
     and    WORKSHEET_NAME = P_WorkSheetName;
*/

/* choang - 24-jun-2002 - replaced to use one cursor for performance
     -- checking the start discoverer_sql_id for this workbook and worksheet
     -- combination
     select min(discoverer_sql_id)
     into l_start_id
     from ams_discoverer_sql
     where workbook_name = P_WorkBookName
       and worksheet_name = P_WorkSheetName;
*/

   --if the workbook and worksheet combination exists in the AMS_DISCOVERER_SQL table
   --then delete all entries , then we can insert the new records for the newest version
   --of this workbook - worksheet.
   IF ((l_max_sequence_number >= p_sequence) OR (l_max_sequence_number = 0)) THEN
      DELETE FROM ams_discoverer_sql
      WHERE  workbook_name  = p_workbookname
      AND    WORKSHEET_NAME = p_worksheetname;
   END IF;

   -- start new logic to update source type code

   -- if updating the same workbook + worksheet, we
   -- need to preserve the disco sql id which is
   -- associated to marketing objects.  the logic:
   --    - new worksheet = p_sequence in 0,1 and disco sql id is null
   --    - updated worksheet = p_sequence in 0,1 and disco sql id not null
   --    - wrapped long sql = p_sequence > 1
   IF p_sequence IN (0, 1) THEN
      IF l_discoverer_sql_id IS NULL THEN
         OPEN c_get_seq;
         FETCH c_get_seq INTO l_discoverer_sql_id;
         CLOSE c_get_seq;
      END IF;
   ELSE
      OPEN c_get_seq;
      FETCH c_get_seq INTO l_discoverer_sql_id;
      CLOSE c_get_seq;
   END IF;

   INSERT INTO ams_discoverer_sql (
      discoverer_sql_id,
      workbook_owner_name,
      workbook_name,
      worksheet_name,
      sequence_order,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      sql_string,
      source_type_code
   )
   VALUES (
      l_discoverer_sql_id,
      p_workbookowner,
      p_workbookname,
      p_worksheetname,
      p_sequence,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      p_sqlsegment,
      l_source_type_code
  );

   -- update needed when SQL spans multiple
   -- segments.
   get_source_type_code (
      p_workbook_name   => p_workbookname,
      p_worksheet_name  => p_worksheetname,
      x_source_type_code   => l_source_type_code
   );

   IF l_source_type_code IS NOT NULL THEN
      UPDATE ams_discoverer_sql
      SET source_type_code = l_source_type_code
      WHERE workbook_name = p_workbookname
      AND   worksheet_name = p_worksheetname
      AND   (source_type_code <> l_source_type_code OR source_type_code IS NULL)
      ;
   END IF;

   RETURN (0);

EXCEPTION
   WHEN OTHERS THEN
     l_sqlerrm := SQLERRM;
     l_sqlcode := SQLCODE;
     RETURN (1);
END EUL_TRIGGER$POST_SAVE_DOCUMENT;

-----------------------------------------------------------------------------
-- Procedure
-- Search_SQL_string

-- PURPOSE
--    1. Will search for the p_search_string variable in the set of strings
--       which compose a workbook SQL statement and are stored in the
--       AMS_DISCOVERER_SQL table.

--    2. p_found will return FND_API.G_TRUE if the string has been found.

--    3. p_found_in_str returns the number of the sql string in which the search
--       string was found. each SQL string is 2000 characters in length.

--    4. p_position returns the position in the string where the first character
--       in the search string was found.

--    5. p_overflow wil return the number of characters which contain part of
--       the search string in the overflow string if the searched for string
--       spans two SQL strings.

--    6. p_max_search_len restricts the number of characters to search on from
--       the set of sql strings.

-- NOTES

-- HISTORY
--   04/13/2001        yxliu            copied from AMS_DiscovererSQL_PVT
-- End of Comments
-----------------------------------------------------------------------------
Procedure Search_SQL_string(p_search_string  in  varchar2,
                            p_workbook_name  in  varchar2,
                            p_worksheet_name in  varchar2,
                            p_max_search_len in  number default NULL,
                            x_found          out nocopy varchar2 ,
                            x_found_in_str   out nocopy number,
                            x_position       out nocopy number,
                            x_overflow       out nocopy number)
IS

  l_sql_table t_SQLtable;

  --the total number of strings for a sql statement.
  l_str_count      number      := 0;

  --the current search position in the string.
  l_str_pos        number      := 0;

  --the length of the current sql string.
  l_str_len        number      := 0;

  --the total number of characters read from the set of sql strings so far.
  l_total_str_len  number      := 0;

  --this flag indicates that no more fetched of sql strings are to be made
  --because the max. number of characters have been read.
  l_last_fetch     varchar2(1);

  --this flag is set to 'Y' when processing on the last sql string has started.
  l_last_str       varchar2(1) := 'N';

  --temporary substring holder used if a p_max_search_len has been reached.
  l_tmp_str        varchar2(2000);

  --if a sub string has to be constructed because of overflow into a second
  --string then it is stored in this variable.
  l_substr         varchar2(1000);

  --the length of the sub string.
  l_substr_len     number       := 0;

  --set to FND_API.G_TRUE when the first character of the searched for string
  --has been found.
  l_first_char_found     varchar2(1);


  --the first character being searched for.
  l_first_char     varchar2(1);

  --the position that the first character was found in the current sql string.
  l_first_char_pos number       := 0;

  --the length of the string being searched for.
  l_search_str_len number       := 0;

  --the search string without its first character.
  l_search_sub_str varchar2(2000);



  l_sqlerrm varchar2(600);
  l_sqlcode varchar2(100);

  Cursor C_SQL_string IS
  Select  Sql_String
    From  Ams_Discoverer_SQL
   Where  Workbook_name       = p_workbook_name
     And  Worksheet_name      = p_worksheet_name
   Order by Sequence_Order;

Begin

   l_first_char     := substr(p_search_string,1,1);
   l_search_str_len := length(p_search_string);
   l_search_sub_str := substr(p_search_string,2,l_search_str_len);


   x_found := FND_API.G_FALSE;

   --getting the total number of strings that compose the sql statement.
   Select   Count(*)
   into     l_str_count
   From     ams_discoverer_sql
   Where    Workbook_name       = p_workbook_name
   And      Worksheet_name      = p_worksheet_name;

   if (l_str_count = 0) then
       x_found := FND_API.G_FALSE;
       --dbms_output.put_line('search sql str : could not find workbook SQL  = '||to_char(l_str_count));
       RETURN;
   end if;


   --Getting the SQL strings.
   Open C_SQL_string;

   --starting from Zero because the sequence in which the strings are stored
   --start from Zero.


   <<l_fetch_string>>
   For l_iterator in 0 .. (l_str_count - 1) Loop

      --dbms_output.put_line('search sql str : fetch string iteration '||to_char(l_iterator + 1));

      --Fetching the next string for the discoverer workbook.
      Fetch C_SQL_string into l_sql_table(l_iterator + 1);

      --initializing the current search position for the string.
      l_str_pos := 0;

      --checking for the last string.
      if ( l_iterator = (l_str_count -1) )then
         --dbms_output.put_line('search sql str :  last string detected ');
         l_last_str := 'Y';
      end if;

      --getting the length of the current sql string.
      l_str_len :=  Length(l_sql_table(l_iterator + 1));
      --dbms_output.put_line('search sql str : length of current sql string = '||to_char(l_str_len));

      --updating the total number of characters read from the set of sql strings.
      l_total_str_len := l_total_str_len + l_str_len;

      --dbms_output.put_line('search sql str : total number of chars read = '||to_char(l_total_str_len));

      --if the max. number of characters have been read then set this flag to
      --break out of the fetch string loop.
      if (l_total_str_len >= p_max_search_len) then

         --dbms_output.put_line('search sql str : max num of characters have been read');

         l_last_fetch := FND_API.G_TRUE;
          l_tmp_str    := substr(l_sql_table(l_iterator + 1),1,p_max_search_len - 1);

         --dbms_output.put_line('search sql str : l_tmp_str ='||l_tmp_str);

         l_sql_table(l_iterator + 1) := NULL;
         l_sql_table(l_iterator + 1) := l_tmp_str;

      end if;

      --If First character of search string has been found in the previous string
      --but the remainder of previous string is too short to contain the rest of
      --the search string.
      if (l_first_char_found  = FND_API.G_TRUE) then
         --getting the substring length.
         l_substr_len :=  length(l_substr);
         --dbms_output.put_line('search sql str : overflow detected, length of sub string = '||to_char(l_substr_len));

         --concatenating the substring and the necessary number of characters in
         --the current string to search for search string minus the first
         --character of it.

         --dbms_output.put_line('search sql str : overflow match string  ='||l_substr||substr(x_sql_table(l_iterator + 1),1,(l_search_str_len-1)-l_substr_len));

         if ( l_substr||substr(l_sql_table(l_iterator + 1),1,((l_search_str_len-1)-nvl(l_substr_len,0)) ) = l_search_sub_str) then
            --dbms_output.put_line('search sql str : sucessful match after overflow');

            x_found         := FND_API.G_TRUE;
            x_overflow      := (l_search_str_len-1)- l_substr_len;

            --dbms_output.put_line('search sql str : overflow length = '||to_char(x_overflow));

            exit l_fetch_string;
         else

            x_found         := FND_API.G_FALSE;
            --calculating the new search position.
            l_str_pos :=  l_str_pos + 1;

            --dbms_output.put_line('search sql str : unsucessful match after overflow, new string position ='||to_char(l_str_pos ));

         end if;
      end if;


      --Loop through the current sql string searching for  l_first_char,
      --If this is  found then check that the next length(l_search_sub_str - 1)
      --characters are part of the search string.

      --If when l_first_char is found there are not enough characters to perform
      --a match, copy the remaining characters into l_sub_str, read the next
      --string(this is done before this loop,
      --after the string is fetched) and then perform a check for a match.

      --If l_first_char is not found then read in the next string and continue
      --searching.

      <<l_search_string>>
      Loop

         --dbms_output.put_line('search sql str : looping through current sql string searching for first char');

         --getting the position of l_first_char in the current string.
         l_first_char_pos := Instr(l_sql_table(l_iterator + 1),l_first_char,l_str_pos+1);

         --the first character of the search string has been found.
         if ( l_first_char_pos <> 0 ) then

            --dbms_output.put_line('search sql str :  getting the position of l_first_char in the current string, found position ='||to_char(l_first_char_pos ));
            --setting current position in sql string.
            l_str_pos := l_first_char_pos;

            --indicating that the first character of the searched for string has been found.
            l_first_char_found := FND_API.G_TRUE;


            if (l_str_count = 1) then
               x_found_in_str := l_iterator;
            else
               x_found_in_str := l_iterator + 1;
            end if;

            --dbms_output.put_line('search sql str : first char found in sql string number '||to_char(x_found_in_str));

            x_position     := l_first_char_pos;

            if (l_search_str_len = 1 ) then
               --dbms_output.put_line('search sql str : Match has been found');
               x_found := FND_API.G_TRUE;
               exit       l_search_string;
            --there are enough characters left in the current string to find a match.
            elsif ( (l_str_len - (l_str_pos + 1)) >= (l_search_str_len - 1) )then

               --dbms_output.put_line('search sql str : enough remaining chars in current string to perform match');

               l_substr := substr(l_sql_table(l_iterator + 1),l_str_pos + 1,l_search_str_len - 1);
               --dbms_output.put_line('search sql str : Sub string = '||l_substr);


               --match has been found.
               if ( l_substr = l_search_sub_str ) then

                  --dbms_output.put_line('search sql str : Match has been found');
                  x_found := FND_API.G_TRUE;
             exit       l_search_string;

               --no match found, update string search position.
               else
                  --dbms_output.put_line('search sql str : Match has not been found');
                  x_found := FND_API.G_FALSE;
                  l_str_pos    := l_str_pos + 1;
               end if;

               --not enough characters remaining in current sql string to perform a match.
               --creating a sub string of the remaining characters, which are used with
               --the next string fetched to perform a check.
            elsif ((l_str_len - l_str_pos) < (l_search_str_len-1)) then
               --dbms_output.put_line('search sql str : Not enough chars remaining to perform check');
               l_substr := substr(l_sql_table(l_iterator + 1),l_str_pos + 1,l_str_len) ;

               --dbms_output.put_line('search sql str : sub string created = '||l_substr);
               --exit the search string loop and fetch another sql string.
               exit       l_search_string;
            end if;

         else
            --dbms_output.put_line('search sql str : first char not found in current sql string');
            --l_first_char has not been been found in the current string.


            --indicating that the first character of the searched for string has not been found.
            l_first_char_found := FND_API.G_FALSE;

            --indicating that the search string has not been found;
            x_found := FND_API.G_FALSE;

            --exit the search string loop and fetch another sql string.
            exit l_search_string;
         end if;


      End Loop l_search_string;--Searching the current strings.
      --dbms_output.put_line('search sql str : exiting search string loop');

      --the string has been found , no need to fetch any more sql strings.
      --OR the max. number of characters have been read.
      If (x_found = FND_API.G_TRUE or l_last_fetch = FND_API.G_TRUE ) then
         exit l_fetch_string;
      end If;

   End Loop l_fetch_string;--Fetching the SQL strings.
   --dbms_output.put_line('search sql str : exiting fetch string loop');
   Close C_SQL_string;

EXCEPTION
WHEN OTHERS THEN

   if (c_sql_string%ISOPEN) then
      Close C_SQL_string;
   end if;

   l_sqlerrm := SQLERRM;
   l_sqlcode := SQLCODE;
   --dbms_output.put_line('Search SQL string:'||l_sqlerrm||l_sqlcode);

End Search_SQL_string;

-----------------------------------------------------------------------------
-- Function
--  Encrypt_Param

-- PURPOSE
--   1. This Function is used by the middle tier java class to get encryption
--      of parameters that need to be passed to form function

-- NOTES

-- HISTORY
--   05/03/2001        yxliu            created
-- End of Comments
-----------------------------------------------------------------------------
Function Encrypt_Param
  ( P_params        IN varchar2,
    P_session_id    IN NUMBER)
RETURN varchar2

IS

BEGIN
   RETURN icx_call.encrypt2(P_params, P_session_id);

END Encrypt_Param;


--
-- NOTE
--    Need to
PROCEDURE get_source_type_code (
   p_workbook_name   IN VARCHAR2,
   p_worksheet_name  IN VARCHAR2,
   x_source_type_code   OUT NOCOPY VARCHAR2
)
IS
   -- by musman bug:4655422:fix start
   l_source_type_code   ams_discoverer_sql.source_type_code%TYPE; --VARCHAR2(30);
   l_search_code        VARCHAR2(50);-- VARCHAR2(30);
   --end

   -- variables used to call search_sql_string
   l_found              VARCHAR2(1);
   l_found_in_str       NUMBER;
   l_position           NUMBER;
   l_overflow           NUMBER;

   CURSOR c_master_types IS
      SELECT source_type_code
      FROM   ams_list_src_types
      WHERE  master_source_type_flag = 'Y'
      AND    enabled_flag = 'Y'
      and list_source_type = 'TARGET'    -- by musman bug:4655422:fix
      order by list_source_type_id ;   -- by musman bug:4655422:fix
BEGIN
   OPEN c_master_types;
   LOOP
      l_source_type_code := NULL;

      FETCH c_master_types INTO l_source_type_code;

      -- Need to encapsulate the source type code
      -- with single quotes because the saved
      -- SQL has the search string within quotes.
      -- Without the quotes, any string with the
      -- searched string will return regardless if it
      -- is designated as the source type code.
      l_search_code := '''' || l_source_type_code || '''';

      search_sql_string (
         p_search_string      => l_search_code,
         p_workbook_name      => p_workbook_name,
         p_worksheet_name     => p_worksheet_name,
         x_found              => l_found,
         x_found_in_str       => l_found_in_str,
         x_position           => l_position,
         x_overflow           => l_overflow
      );

      EXIT WHEN c_master_types%NOTFOUND OR l_found = FND_API.G_TRUE;
   END LOOP;
   CLOSE c_master_types;

   x_source_type_code := l_source_type_code;

EXCEPTION
  WHEN OTHERS THEN

   if (c_master_types%ISOPEN) then
      Close c_master_types;
   end if;

END get_source_type_code;


--
-- Note
-- ======
-- 2 main scenarios in the processing flow: 1) all the fragments concatenated
-- are not longer than 32k (max PL/SQL string), so instr has to be done to only
-- that one str.  2) all the fragments would concatenate to a string longer than
-- 32k, so the instr has to be done in batches with a size no bigger than 32k
-- at a time.
Procedure batch_search_sql (
   p_workbook_name   in  varchar2,
   p_worksheet_name  in  varchar2,
   p_source_type_code_tab  IN source_type_code_type,
   x_found_index     OUT NOCOPY VARCHAR2
)
IS
   MAX_FRAGMENTS     CONSTANT NUMBER := 8;   -- each SQL fragment is 4k, so the string can only be up to 32k

   TYPE sql_string_type IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
   l_sql_string_tab  sql_string_type;

   l_str       VARCHAR2(32767);

   l_last_str     VARCHAR2(4000);
   l_end_offset   NUMBER := MAX_FRAGMENTS;

   CURSOR c_sql_string IS
      SELECT  sql_string
      FROM  ams_discoverer_sql
      WHERE workbook_name       = p_workbook_name
      AND   worksheet_name      = p_worksheet_name
      ORDER BY sequence_order;
BEGIN
   x_found_index := 0;

   OPEN c_sql_string;
   FETCH c_sql_string BULK COLLECT INTO l_sql_string_tab;
   CLOSE c_sql_string;

   IF l_sql_string_tab.COUNT > MAX_FRAGMENTS THEN
      --
      -- Logic
      -- =========
      -- Build a string up to 32k length (max for PL/SQL
      -- strings).  Look for code in the string, and if
      -- not found, build another 32k string but start
      -- with the last fragment of the previous string.
      FOR j IN 1 .. l_sql_string_tab.COUNT LOOP
         IF j > l_end_offset THEN
            l_str := l_last_str;
            l_end_offset := (j - 1) + MAX_FRAGMENTS;
         ELSE
            l_str := l_str || l_sql_string_tab(j);
            IF j = l_end_offset THEN
               l_last_str := l_sql_string_tab(j);
            END IF;
         END IF;

         IF j = l_end_offset OR j = l_sql_string_tab.COUNT THEN
            --
            -- Logic
            -- =======
            -- Constructing the strings is expensive, so we don't
            -- want to keep re-doing it.  For every string, check
            -- all the codes for a match.
            FOR i IN 1 .. p_source_type_code_tab.COUNT LOOP
               IF INSTR (l_str, '''' || p_source_type_code_tab(i) || '''') <> 0 THEN
                  x_found_index := i;
                  RETURN;
               END IF;
            END LOOP;
         END IF;
      END LOOP;
   ELSE
      -- construct a single string out of all the sql fragments
      FOR i IN 1 .. l_sql_string_tab.COUNT LOOP
         l_str := l_str || l_sql_string_tab(i);
      END LOOP;

      FOR i IN 1 .. p_source_type_code_tab.COUNT LOOP
         IF INSTR (l_str, '''' || p_source_type_code_tab(i) || '''') <> 0 THEN
            x_found_index := i;
            RETURN;
         END IF;
      END LOOP;
   END IF;


END;

END AMS_DISCOVERER_PVT;

/
