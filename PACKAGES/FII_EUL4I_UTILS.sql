--------------------------------------------------------
--  DDL for Package FII_EUL4I_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EUL4I_UTILS" AUTHID CURRENT_USER AS
/* $Header: FIIEL41S.pls 120.1 2005/06/13 11:18:54 sgautam noship $ */

PROCEDURE EULMaint(Errbuf           IN OUT  NOCOPY VARCHAR2,
                   Retcode          IN OUT  NOCOPY VARCHAR2,
                   pEulOwnerName    IN      VARCHAR2 DEFAULT 'EUL4EDW_US',
                   pMode            IN      VARCHAR2 DEFAULT 'PROD',
                   pBusAreaName     IN      VARCHAR2 DEFAULT NULL,
                   pAction          IN      VARCHAR2 DEFAULT NULL);


/*
PROCEDURE InitBusAreas(Errbuf      	IN OUT  NOCOPY VARCHAR2,
                       Retcode     	IN OUT  NOCOPY VARCHAR2,
                       pBusAreaName     IN      VARCHAR2,
                       pAction          IN      VARCHAR2 DEFAULT 'ADD');

PROCEDURE InitTables(Errbuf      	IN OUT  NOCOPY VARCHAR2,
                     Retcode     	IN OUT  NOCOPY VARCHAR2,
                     pBusAreaName       IN      VARCHAR2,
                     pAction            IN VARCHAR2 DEFAULT 'ADD');

PROCEDURE InitColumns(Errbuf      	IN OUT  NOCOPY VARCHAR2,
                      Retcode     	IN OUT  NOCOPY VARCHAR2,
                      pFolderId         IN NUMBER,
                      pTableName        IN VARCHAR2);
*/
FUNCTION  ItemsToHide(pBusAreaNameIn  VARCHAR2,
                      pTableNameIn    VARCHAR2,
                      pColumnNameIn   VARCHAR2,
                      pItemNameIn     VARCHAR2)

  RETURN INTEGER;


END FII_EUL4I_UTILS;

 

/
