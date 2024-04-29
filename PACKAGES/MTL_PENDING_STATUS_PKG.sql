--------------------------------------------------------
--  DDL for Package MTL_PENDING_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_PENDING_STATUS_PKG" AUTHID CURRENT_USER as
/* $Header: INVISMPS.pls 120.1 2005/06/11 08:18:38 appldev  $ */
  PROCEDURE  get_org(X_ORG_ID IN   NUMBER ,
                     X_CUR_ORG_ID     OUT NOCOPY /* file.sql.39 change */  NUMBER ,
                     X_CUR_ORG_CODE   OUT NOCOPY /* file.sql.39 change */  VARCHAR2 ,
                     X_CUR_ORG_NAME   OUT NOCOPY /* file.sql.39 change */  VARCHAR2 );
END MTL_PENDING_STATUS_PKG;

 

/
