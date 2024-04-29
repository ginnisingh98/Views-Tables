--------------------------------------------------------
--  DDL for Package Body AMS_DISCOVERERSQL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DISCOVERERSQL_PVT" AS
/* $Header: amsvldcb.pls 115.13 2003/03/09 10:17:50 gjoby ship $ */
G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_DiscovererSQL_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvldcb.pls';
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE get_source_type_code (
   p_workbook_name   IN VARCHAR2,
   p_worksheet_name  IN VARCHAR2,
   x_source_type_code   OUT NOCOPY VARCHAR2
);

-- Start of Comments
--
-- NAME
--  EUL_TRIGGER$POST_SAVE_DOCUMENT
--
-- PURPOSE
--   1. This Function if registered by discoverer will save any sql from any worksheet which has been
--      saved to the database into the AMS_DISCOVERER_SQL table.

--   2. If the SQL string is under 2000 bytes in length then the sequence number will be Zero.

--   3. If the SQL string is greater than 2000 bytes then the sequence number will start from One
--      and subsequenct insertions will have the sequence number incremented by one.

--   4. A check is also performed to see if the same workbook name and worksheet name combination
--      already exists in the AMS_DISCOVERER_SQL table. If this is the case all entries for this
--      workbook and sheet will be deleted from the table first.


--   Called By:
--   Oracle Discoverer.


-- NOTES
--
--
-- HISTORY
--   06/21/1999        tdonohoe            created
--   01/15/2002        yxliu               changed logic
-- End of Comments
Function  EUL_TRIGGER$POST_SAVE_DOCUMENT
  ( P_WorkBookOwner IN varchar2,
    P_WorkBookName  IN varchar2,
    P_WorkSheetName IN varchar2,
    P_Sequence      IN number,
    P_SQLSegment    IN varchar2)  RETURN  NUMBER IS

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

-- Start of Comments
--
-- NAME
--   Search SQL string
--
-- PURPOSE
--    1. Will search for the p_search_string variable in the set of strings which compose a workbook
--       SQL statement and are stored in the AMS_DISCOVERER_SQL table.

--    2. x_found will return FND_API.G_TRUE if the string has been found.

--    3. x_found_in_str returns the number of the sql string in which the search string was found.
--       each SQL string is 2000 characters in length.

--    4. p_position returns the position in the string where the first character in the search string
--       was found.

--    5. x_overflow wil return the number of characters which contain part of the search string
--       in the  overflow string if the searched for string spans two SQL strings.

--    6. p_max_search_len restricts the number of characters to search on from the set of sql strings.

--    7. A pl\sql table is returned which contains all of the sql strings that have been processed for
--       the specified workbook.


-- HISTORY
--   06/28/1999 tdonohoe created
--   02/08/2000 tdonohoe modified increment variable "l_str_pos" by one position after each search.
--                                put nvl(l_str_len,0) , it was evaluating to NULL in some cases causing
--                                the search to fail.
-- End of Comments

Procedure Search_SQL_string(p_search_string  in  varchar2,
                            p_workbook_name  in  varchar2,
                            p_worksheet_name in  varchar2,
                            p_max_search_len in  number ,--default NULL,
                            x_found          OUT NOCOPY varchar2 ,
                            x_found_in_str   OUT NOCOPY number,
                            x_position       OUT NOCOPY number,
                            x_overflow       OUT NOCOPY number) IS

  l_sql_table t_SQLtable;

 --the total number of strings for a sql statement.
  l_str_count      number :=0;

  --the current search position in the string.
  l_str_pos        number      :=0;

  --the length of the current sql string.
  l_str_len        number      :=0;

  --the total number of characters read from the set of sql strings so far.
  l_total_str_len  number      :=0;

  --this flag indicates that no more fetched of sql strings are to be made
  --because the max. number of characters have been read.
  l_last_fetch     varchar2(1);

  --this flag is set to 'Y' when processing on the last sql string has started.
  l_last_str       varchar2(1) := 'N';

  --temporary substring holder used if a p_max_search_len has been reached.
  l_tmp_str        varchar2(2000);

  --if a sub string has to be constructed because of overflow into a second string then it
  --is stored in this variable.
  l_substr         varchar2(1000);

  --the length of the sub string.
  l_substr_len     number :=0;

  --set to FND_API.G_TRUE when the first character of the searched for string has been found.
  l_first_char_found     varchar2(1);


  --the first character being searched for.
  l_first_char     varchar2(1);

  --the position that the first character was found in the current sql string.
  l_first_char_pos number :=0;

  --the length of the string being searched for.
  l_search_str_len number :=0;

  --the search string without its first character.
  l_search_sub_str varchar2(2000);



  l_sqlerrm varchar2(600);
  l_sqlcode varchar2(100);

  Cursor C_SQL_string IS Select Sql_String
                         From   Ams_Discoverer_SQL
                         Where  Workbook_name       = p_workbook_name
                         And    Worksheet_name      = p_worksheet_name
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

   if(l_str_count = 0)then
       x_found := FND_API.G_FALSE;
       RETURN;
   end if;


   --Getting the SQL strings.
	   Open C_SQL_string;

	   --starting from Zero because the sequence in which the strings are stored
	   --start from Zero.


	   <<l_fetch_string>>
       For l_iterator in 0 .. (l_str_count - 1) Loop


	         --Fetching the next string for the discoverer workbook.
	         Fetch C_SQL_string into l_sql_table(l_iterator + 1);



			 --initializing the current search position for the string.
			 l_str_pos := 0;

			 --checking for the last string.
		     if( l_iterator = (l_str_count -1) )then
			       l_last_str := 'Y';
			 end if;

			 --getting the length of the current sql string.
			 l_str_len :=  Length(l_sql_table(l_iterator + 1));

			 --updating the total number of characters read from the set of sql strings.
			 l_total_str_len := l_total_str_len + l_str_len;


			 --if the max. number of characters have been read then set this flag to break
			 --out of the fetch string loop.
			 if(l_total_str_len >= p_max_search_len)then


                 l_last_fetch := FND_API.G_TRUE;
               	 l_tmp_str    := substr(l_sql_table(l_iterator + 1),1,p_max_search_len - 1);


                 l_sql_table(l_iterator + 1) := NULL;
	             l_sql_table(l_iterator + 1) := l_tmp_str;

 			 end if;


			 --If First character of search string has been found in the previous string but
			 --the remainder of previous string is too short to contain the rest of the search string.
			 if(l_first_char_found  = FND_API.G_TRUE)then

     		      --getting the substring length.
			      l_substr_len :=  length(l_substr);

			      --concatenating the substring and the necessary number of characters in the current
				  --string to search for search string minus the first character of it.


				  if( l_substr||substr(l_sql_table(l_iterator + 1),1,((l_search_str_len-1)-nvl(l_substr_len,0)) ) = l_search_sub_str)then


						x_found         := FND_API.G_TRUE;
						x_overflow      := (l_search_str_len-1)- l_substr_len;


						exit l_fetch_string;
				  else

				        x_found         := FND_API.G_FALSE;
				        --calculating the new search position.
				   	l_str_pos :=  l_str_pos + 1;


				  end if;
			  end if;


		   --Loop through the current sql string searching for  l_first_char,
		   --If this is  found then check that the next length(l_search_sub_str - 1)
		   --characters are part of the search string.

		   --If when l_first_char is found there are not enough characters to perform a match, copy the
		   --remaining characters into l_sub_str, read the next string(this is done before this loop,
		   --after the string is fetched) and then perform a check for a match.

		   --If l_first_char is not found then read in the next string and continue searching.

		   <<l_search_string>>
		   Loop


			  --getting the position of l_first_char in the current string.
			  l_first_char_pos := Instr(l_sql_table(l_iterator + 1),l_first_char,l_str_pos+1);


		      --the first character of the search string has been found.
	          if( l_first_char_pos <> 0 )then

			      --setting current position in sql string.
			      l_str_pos := l_first_char_pos;

				  --indicating that the first character of the searched for string has been found.
				  l_first_char_found := FND_API.G_TRUE;


				  if(l_str_count = 1) then
				     x_found_in_str := l_iterator;
				  else
                                     x_found_in_str := l_iterator + 1;
                                  end if;


				  x_position     := l_first_char_pos;

                  if(l_search_str_len = 1 )then
						 x_found := FND_API.G_TRUE;
						 exit       l_search_string;
			      --there are enough characters left in the current string to find a match.
			      elsif ( (l_str_len - (l_str_pos + 1)) >= (l_search_str_len - 1) )then


		                 l_substr := substr(l_sql_table(l_iterator + 1),l_str_pos + 1,l_search_str_len - 1);


						 --match has been found.
						 if(l_substr = l_search_sub_str )then

						        x_found := FND_API.G_TRUE;
						   	    exit       l_search_string;

						 --no match found, update string search position.
						 else
						        x_found := FND_API.G_FALSE;
						        l_str_pos    := l_str_pos + 1;
				   	     end if;

				  --not enough characters remaining in current sql string to perform a match.
				  --creating a sub string of the remaining characters, which are used with
				  --the next string	fetched to perform a check.
				  elsif((l_str_len - l_str_pos) < (l_search_str_len-1))then

				          l_substr := substr(l_sql_table(l_iterator + 1),l_str_pos + 1,l_str_len) ;

						  --exit the search string loop and fetch another sql string.
						  exit       l_search_string;
				  end if;

			  else
    		       --l_first_char has not been been found in the current string.


				  --indicating that the first character of the searched for string has not been found.
				  l_first_char_found := FND_API.G_FALSE;

                  --indicating that the search string has not been found;
                  x_found := FND_API.G_FALSE;

				  --exit the search string loop and fetch another sql string.
				  exit l_search_string;
			  end if;


			End Loop l_search_string;--Searching the current strings.

            --the string has been found , no need to fetch any more sql strings.
			--OR the max. number of characters have been read.
            If(x_found = FND_API.G_TRUE or l_last_fetch = FND_API.G_TRUE )then

			       exit l_fetch_string;
		    end If;

	   End Loop l_fetch_string;--Fetching the SQL strings.
	   Close C_SQL_string;

EXCEPTION
WHEN OTHERS THEN

        if(c_sql_string%ISOPEN)then
              Close C_SQL_string;
        end if;

		l_sqlerrm := SQLERRM;
        l_sqlcode := SQLCODE;


End Search_SQL_string;


PROCEDURE get_source_type_code (
   p_workbook_name   IN VARCHAR2,
   p_worksheet_name  IN VARCHAR2,
   x_source_type_code   OUT NOCOPY VARCHAR2
)
IS
   l_source_type_code   VARCHAR2(30);
   l_search_code        VARCHAR2(30);

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
      ;
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
END get_source_type_code;


END AMS_DiscovererSQL_PVT;




/
