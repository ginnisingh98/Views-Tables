--------------------------------------------------------
--  DDL for Package FII_EUL4I_UTILS_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EUL4I_UTILS_2" AUTHID CURRENT_USER AS
/* $Header: FIIEL42S.pls 120.0 2002/08/24 04:52:38 appldev noship $ */

--FUNCTION foldersToHide(pBusAreaName VARCHAR2)
--  RETURN INTEGER;

FUNCTION foldersToRename(pBusAreaName VARCHAR2,
                         pFolderName  VARCHAR2)
  RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (foldersToRename , WNDS);

/*FUNCTION foldersToHide(pBusAreaName VARCHAR2,
                       pFolderName  VARCHAR2)
  RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (foldersToHide , WNDS);
*/

FUNCTION  ItemsToHide(pBusAreaNameIn VARCHAR2,
                      pTableNameIn   VARCHAR2,
                      pColumnNameIn  VARCHAR2,
                      pItemNameIn    VARCHAR2)
  RETURN INTEGER;
PRAGMA RESTRICT_REFERENCES (ItemsToHide , WNDS);

END FII_EUL4I_UTILS_2;

 

/
