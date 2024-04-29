--------------------------------------------------------
--  DDL for Package CS_KB_SETS_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_SETS_AUDIT_PKG" AUTHID CURRENT_USER AS
/* $Header: cskbsas.pls 115.24 2003/08/28 21:20:37 mkettle noship $ */

  --for RETURN status
  ERROR_STATUS      CONSTANT NUMBER      := -1;

 FUNCTION Get_Published_Set_Id(
   P_SET_NUMBER IN VARCHAR2 )
 RETURN NUMBER;

END CS_KB_SETS_AUDIT_PKG;

 

/
