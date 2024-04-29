--------------------------------------------------------
--  DDL for Package BSC_PMD_OPT_DOC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PMD_OPT_DOC_UTIL" AUTHID CURRENT_USER AS
/*$Header: BSCPDGS.pls 120.0 2005/06/01 16:52:59 appldev noship $*/

  FUNCTION GET_MV_BY_STABLE(
    P_STABLE              IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION GET_MV_BY_SBTABLE(
    P_STABLE              IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION GET_ZMV_BY_STABLE(
    P_STABLE              IN VARCHAR2
  ) RETURN VARCHAR2;

  PROCEDURE GEN_TBL_RELS_DISPLAY;

  PROCEDURE RENAME_TBL_RELS_DISPLAY(
    P_OLD              IN VARCHAR2,
    P_NEW              IN VARCHAR2
  );

END BSC_PMD_OPT_DOC_UTIL;

 

/
