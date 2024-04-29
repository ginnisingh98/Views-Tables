--------------------------------------------------------
--  DDL for Package AMS_DISCOVERERSQL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DISCOVERERSQL_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvldcs.pls 115.5 2002/11/12 23:38:58 jieli ship $ */
--PL\SQL table to hold the strings that compose a valid SQL statement from
--a discoverer workbook

TYPE t_SQLtable is TABLE OF varchar2(2000)
INDEX BY BINARY_INTEGER;

-- Start of Comments
--
-- NAME
--   EUL_TRIGGER$POST_SAVE_DOCUMENT
--
-- PURPOSE
--   1. This Function is used by Oracle Discoverer to save a WorkSheets SQL
--      to The AMS_DISCOVERER_SQL table.

--   2. This Function must be Registered as a valid Function using Oracle
--      Discoverer's Administration Edition before any WorkBook SQL will be
--      saved.

-- NOTES

-- HISTORY
--   06/21/1999        tdonohoe            created
-- End of Comments

   Function  EUL_TRIGGER$POST_SAVE_DOCUMENT
  ( P_WorkBookOwner IN varchar2,
    P_WorkBookName  IN varchar2,
    P_WorkSheetName IN varchar2,
    P_Sequence      IN number,
    P_SQLSegment    IN varchar2) return NUMBER;


-- Start of Comments
--
-- NAME
--   Search SQL string
--
-- PURPOSE
--    1. Will search for the p_search_string variable in the set of strings which compose a workbook
--       SQL statement and are stored in the AMS_DISCOVERER_SQL table.

--    2. p_found will return FND_API.G_TRUE if the string has been found.

--    3. p_found_in_str returns the number of the sql string in which the search string was found.
--       each SQL string is 2000 characters in length.

--    4. p_position returns the position in the string where the first character in the search string
--       was found.

--    5. p_overflow wil return the number of characters which contain part of the search string
--       in the  overflow string if the searched for string spans two SQL strings.

--    6. p_max_search_len restricts the number of characters to search on from the set of sql strings.

-- Called By.
--    1. Validate SQL.
--
-- HISTORY
--   06/28/1999        tdonohoe            created
-- End of Comments
Procedure Search_SQL_string(p_search_string  in  varchar2,
                            p_workbook_name  in  varchar2,
                            p_worksheet_name in  varchar2,
                            p_max_search_len in  number default NULL,
                            x_found          OUT NOCOPY varchar2 ,
                            x_found_in_str   OUT NOCOPY number,
                            x_position       OUT NOCOPY number,
                            x_overflow       OUT NOCOPY number);



END AMS_DiscovererSQL_PVT; -- Package spec




 

/
