--------------------------------------------------------
--  DDL for Package AP_ISPEED_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_ISPEED_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: apispeds.pls 120.5 2004/10/28 23:22:02 pjena noship $ */
--
PROCEDURE Installation_Status (
                 P_Installation_Exists       OUT   NOCOPY     VARCHAR2);
PROCEDURE Add_language( P_Term_Id IN Number);


END AP_ISPEED_UTIL_PKG;

 

/
