--------------------------------------------------------
--  DDL for Package BIS_GNRL_SEARCH_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_GNRL_SEARCH_ENGINE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVGSES.pls 115.3 99/09/17 19:17:25 porting ship  $ */

-- Exceptions
-- ********************************
e_noIndexDefined   EXCEPTION;

-- Record and Table type declarations
-- ************************************************************
TYPE results_tbl_rec   IS RECORD(folder_id           pls_integer
                                ,folder_name         varchar2(400)
                                ,folder_description  varchar2(32000));
TYPE results_tbl_typ  IS TABLE of results_tbl_rec INDEX BY BINARY_INTEGER;
TYPE keywords_tbl_typ IS TABLE of varchar2(32000) INDEX BY BINARY_INTEGER;

-- Constants declaration
-- ************************************************************
c_stem_optr    CONSTANT varchar2(1) :=  '$';
c_accum_optr   CONSTANT varchar2(1) :=  ',';
C_ROW_COUNT  CONSTANT PLS_INTEGER := 40;  -- To be used in case I need to show only so many at a time
C_MAX_HITS   CONSTANT PLS_INTEGER := 200; -- To be used in case I need to stop searching after this

-- Procedure declarations
-- *************************************************************
-- Procedure : BUILD_QUERY  = Procedure creates and runs the
--      Intermedia query to search the pre-indexed table.
--      The script BISPBVI.sql should be run first to create the
--      InterMedia Domain Index. It needs to be run in the Discoverer
--      eul schema that contains the Business Views in the specified language.
-- Parameters 1. p_api_version    =  version of this api
--            2. p_eul            =  Name of the schema in which the
--                                Intermedia domain index was created
--            3. p_keywords_tbl    = plsql table containing the search words
--            4. x_results_tbl    = plsql table containing the query results
--            5. x_return_status  = return status
--            6. x_error_tbl      = error table for debugging
-- *************************************************************
PROCEDURE  build_query
( p_api_version      in   pls_integer
 ,p_eul              in   varchar2
 ,p_keywords_tbl     in   BIS_GNRL_SEARCH_ENGINE_PVT.keywords_tbl_typ
 ,x_results_tbl      out  BIS_GNRL_SEARCH_ENGINE_PVT.results_tbl_typ
 ,x_return_status    out  varchar2
 ,x_error_tbl        out  BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- ****************************************************
--  Function: get_a_index_owner
--      Given an intermedia index name returns a possible
--      index owner, in order to get the Schema name
-- ****************************************************
Function get_a_index_owner( p_index    in   varchar2 )
   RETURN    VARCHAR2;


-- *****************************************************
-- Function : concat_string
--     Given a string, this concatenates the appropriate
--     number of single quotes on either sides, so that
--     it could be inserted into a quoted sql query string.
-- ****************************************************
Function concat_string (p_str  in varchar2)
   RETURN VARCHAR2;


-- *****************************************************
END bis_gnrl_search_engine_pvt;

 

/
