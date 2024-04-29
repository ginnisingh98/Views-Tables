--------------------------------------------------------
--  DDL for Package IBU_DAC_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_DAC_CRITERIA_PKG" AUTHID CURRENT_USER AS
/* $Header: ibudacs.pls 115.7 2002/11/28 00:23:43 nazhou noship $ */
FUNCTION GetDACCriteria(
  UserName   in  varchar2,
  PermissionName   in  varchar2,
  UserID   in  varchar2
) return varchar2;

FUNCTION CheckPermission(
  PermissionName   in  varchar2,
  PRINCIPAL_NAME   in  varchar2
) return boolean;

end IBU_DAC_Criteria_PKG;


 

/
