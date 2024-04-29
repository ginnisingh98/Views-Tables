--------------------------------------------------------
--  DDL for Package IBC_CONTENT_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CONTENT_SEARCH_PVT" AUTHID CURRENT_USER AS
/* $Header: ibcvsrcs.pls 120.0 2005/09/01 21:40 srrangar noship $ */

--
-- CONSTANTS
--

  G_PKG_NAME  	     CONSTANT VARCHAR2(50) := 'IBC_CONTENT_SEARCH_PVT';

  -- for return status
  ERROR_STATUS      CONSTANT NUMBER      := -1;
  OKAY_STATUS       CONSTANT NUMBER      := 0;

  G_TRUE    CONSTANT VARCHAR2(1)  := Fnd_Api.G_TRUE;
  G_FALSE   CONSTANT VARCHAR2(1)  := Fnd_Api.G_FALSE;
  G_VALID_LEVEL_TYPESOK CONSTANT NUMBER := 50;

--
-- TYPES AND MISSING CONSTANTS
--
  G_MISS_NUM15          CONSTANT NUMBER(15)  := -9E14;


------------------< Global Constants >-----------------------
  G_POSITIVE_ASSOC   CONSTANT NUMBER(5)   := 1;
  G_NEGATIVE_ASSOC   CONSTANT NUMBER(5)   := -1;

  /* default increment for count */
  G_COUNT_INCR       CONSTANT NUMBER(5)   := 1;
  G_COUNT_INIT       CONSTANT NUMBER(5)   := 1;

  /* for different Search options */

  MATCH_ALL          CONSTANT NUMBER(5)   := 0;
  MATCH_ANY          CONSTANT NUMBER(5)   := 1;
  FUZZY              CONSTANT NUMBER(5)   := 2;
  INTERMEDIA_SYNTAX  CONSTANT NUMBER(5)   := 3;
  THEME_BASED        CONSTANT NUMBER(5)   := 4;
  MATCH_ACCUM        CONSTANT NUMBER(5)   := 5;
  -- "6" is reserved for match by id at java level
  MATCH_PHRASE       CONSTANT NUMBER(5)   := 7;

--
-- TYPES AND MISSING CONSTANTS
-- (All types are defined in PUB package)
--

  /* for input query strings */
  TYPE varchar21990_tbl_type IS TABLE OF VARCHAR2(1990);

  /* for input ids */
  TYPE number15_tbl_type IS TABLE OF NUMBER(15);

  /* weakly typed cursor for dynamic sql */
  TYPE general_csr_type IS REF CURSOR;

----------------<End of Constants>--------------------
--
-- Procedures and Functions
--

--
-- Utility functions
--
FUNCTION Build_Simple_Text_Query
  (
    p_qry_string IN VARCHAR2,
    p_search_option IN NUMBER
  )
  RETURN VARCHAR2;


FUNCTION Build_Keyword_Query
  (
    p_string        IN VARCHAR2,
    p_search_option IN NUMBER
  )
  RETURN VARCHAR2;

END Ibc_Content_Search_Pvt;

 

/
