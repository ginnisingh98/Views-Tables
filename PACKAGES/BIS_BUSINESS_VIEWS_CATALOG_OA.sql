--------------------------------------------------------
--  DDL for Package BIS_BUSINESS_VIEWS_CATALOG_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BUSINESS_VIEWS_CATALOG_OA" AUTHID CURRENT_USER AS
/* $Header: BISEULQS.pls 115.5 2003/01/30 06:23:20 rchandra ship $ */

--Constants declarations
c_title   CONSTANT varchar2(400) := ICX_UTIL.getPrompt(191, 'BIS_BVC_PROMPTS', 191, 'BIS_BVC_TITLE');
c_submit  CONSTANT varchar2(100) := ICX_UTIL.getPrompt(191, 'BIS_BVC_PROMPTS', 191, 'BIS_BVC_SEARCH_BUTTON');
c_busarea CONSTANT varchar2(400) := ICX_UTIL.getPrompt(191, 'BIS_BVC_PROMPTS', 191, 'BIS_BVC_BUSINESS_AREA');
c_folder CONSTANT varchar2(80)  := ICX_UTIL.getPrompt(191, 'BIS_BVC_PROMPTS', 191, 'BIS_BVC_FOLDER');
c_desc   CONSTANT varchar2(400) := ICX_UTIL.getPrompt(191, 'BIS_BVC_PROMPTS', 191, 'BIS_BVC_DESCRIPTION');
c_eul   CONSTANT varchar2(100) := ICX_UTIL.getPrompt(191, 'BIS_BVC_PROMPTS', 191, 'BIS_BVC_EUL');

C_MAX_HITS   CONSTANT PLS_INTEGER := 200; -- To be used in case I need to stop searching after this
C_ROW_COUNT  CONSTANT PLS_INTEGER := 40;  -- To be used in case I need to show only so many at a time

/*
-- ********************************************************
--  Procedure that paints the search form as a plug
-- *********************************************************
PROCEDURE  enter_query_page_plug
( p_session_id    IN  pls_integer
, p_plug_id       IN  pls_integer
, p_display_name  IN  VARCHAR2   DEFAULT NULL
, p_delete        IN  VARCHAR2   DEFAULT 'N'
);
*/

-- *******************************************************
--  Procedure that paints the search form again for second try
-- *******************************************************
PROCEDURE enter_query_page
( p_keywords      in  varchar2
, p_lang          in  varchar2
);

-- ********************************************************
--   Procedure that goes throught the plsql table containing
--  the query hits and paints them as a html table structure
-- *********************************************************
PROCEDURE  results_page
( p_results_tbl  IN  BIS_GNRL_SEARCH_ENGINE_PVT_OA.results_tbl_typ
, p_lang         IN  VARCHAR2
);

-- ********************************************************
-- Main procedure which  cleans / validates the search words
-- and transfers them into a plsql table to be sent to the
-- package that runs the InterMedia query BIS_GNRL_SEARCH_ENGINE_PVT
-- **********************************************************
PROCEDURE  query
( p_keywords         IN  varchar2
, p_lang             IN  varchar2
);

-- ********************************************************
--  Function to get a Business Area the folder belongs to.
--  A folder might belong to multiple BUS areas, but this
--  picks the first one it finds.
-- ********************************************************
FUNCTION   get_a_business_area
( p_folder_id   IN  PLS_INTEGER
, p_eul         IN  VARCHAR2
)
return bis_gnrl_search_engine_pvt_oa.results_tbl_typ;
--RETURN  VARCHAR2;

-- ********************************************************
--  Procedures to paint parts of HTML table/table heading
-- ********************************************************
--PROCEDURE insert_heading_cell (p_text  in varchar2);

--PROCEDURE insert_blank_heading_cell;

--PROCEDURE insert_blank_cell;

-- ******************************************************
--
-- ******************************************************

PROCEDURE Container(
 p_keywords      in  varchar2
,p_lang          in  varchar2
,p_results_tbl  IN  BIS_GNRL_SEARCH_ENGINE_PVT.results_tbl_typ
);

--*******************************************************

function Is_Business_Area_Accessible(
  x_ba_id               number,
  x_apps_user_id         number,
  x_eul                 varchar2
) return varchar2;

-- ******************************************************
END  bis_business_views_catalog_oa;

 

/
