--------------------------------------------------------
--  DDL for Package AMS_DISCOVERER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DISCOVERER_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvdiss.pls 115.10 2004/04/07 20:27:40 choang ship $ */

TYPE t_SQLtable is TABLE OF varchar2(2000)
INDEX BY BINARY_INTEGER;

TYPE source_type_code_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

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
Procedure Create_Discoverer_Url(p_text              IN VARCHAR2,
                                p_application_id    IN NUMBER,
                                p_responsibility_id IN NUMBER,
                                p_function_id       IN NUMBER,
                                p_target            IN VARCHAR2 default '_top',
                                p_session_id        IN NUMBER,
                                x_discoverer_url    OUT NOCOPY VARCHAR2
                               );

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

-- HISTORY
--   04/13/2001        yxliu            copied from AMS_DiscovererSQL_PVT
-- End of Comments
-----------------------------------------------------------------------------
Function  EUL_TRIGGER$POST_SAVE_DOCUMENT
(   P_WorkBookOwner IN varchar2,
    P_WorkBookName  IN varchar2,
    P_WorkSheetName IN varchar2,
    P_Sequence      IN number,
    P_SQLSegment    IN varchar2
)
return NUMBER;

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
                            x_found          OUT NOCOPY varchar2,
                            x_found_in_str   OUT NOCOPY number,
                            x_position       OUT NOCOPY number,
                            x_overflow       OUT NOCOPY number);

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
    P_session_id    IN number)
RETURN varchar2;



--
-- Purpose
-- =========
-- Given a table of source_type_codes (from ams_list_src_types)
-- search a Discoverer workbook saved SQL to identify a match
-- of the code.  Intended for denormalizing the source_type_code
-- of a workbook to a column in ams_discoverer_sql for faster
-- querying.
--
-- Usage
-- =========
-- Input Parameters:
--    p_workbook_name - the name of the Discoverer workbook
--    p_worksheet_name - the name of the Discoverer worksheet within the
--       given workbook.
--    p_source_type_code_tab - a PL/SQL table containing all the codes used
--       for matching with the workbooks.
-- Output Parameters:
--    x_found_index - index that identifies the source_type_code in the input
--       PL/SQL table.
--
-- History
-- =========
-- 21-Aug-2003 choang   Created for bug 3000427.
--
PROCEDURE batch_search_sql (
   p_workbook_name  in  varchar2,
   p_worksheet_name in  varchar2,
   p_source_type_code_tab IN source_type_code_type,
   x_found_index   OUT NOCOPY VARCHAR2
);


END; -- Package spec

 

/
