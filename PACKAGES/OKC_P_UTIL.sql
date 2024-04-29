--------------------------------------------------------
--  DDL for Package OKC_P_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_P_UTIL" AUTHID CURRENT_USER AS
/* $Header: OKCPUTLS.pls 120.0 2005/05/25 23:04:28 appldev noship $ */
 -- Sub-Program Unit Declarations
/* Convert major and minor version numbers into a string for the veiws */
FUNCTION  VERSION_STRING
  (P_MAJOR  IN  NUMBER
  ,P_MINOR  IN  NUMBER
  )
  RETURN  VARCHAR2;
 PRAGMA  RESTRICT_REFERENCES  (VERSION_STRING,  WNPS,  WNDS);
 /* Convert raw value to number */
FUNCTION  RAW_TO_NUMBER
  (P_RAWID  IN  RAW
  )
  RETURN  NUMBER;
 PRAGMA  RESTRICT_REFERENCES  (RAW_TO_NUMBER,  RNPS,  WNPS,  WNDS);
 /* Execute any sql via dynamic sql */
FUNCTION  EXECUTE_SQL
  (P_SQL  IN  VARCHAR2
  )
  RETURN  INTEGER;
 /* Logic to run in view instead of triggers */
PROCEDURE  INSTEAD_OF_TRG;

END  OKC_P_UTIL;

 

/
