--------------------------------------------------------
--  DDL for Package PAY_UPGRADE_LEGISLATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_UPGRADE_LEGISLATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: pypul01t.pkh 115.0 2003/11/21 03:07 tvankayl noship $ */

  PROCEDURE Insert_Row (
	 P_UPGRADE_DEFINITION_ID   in            NUMBER
	,P_LEGISLATION_CODE        in            VARCHAR2
	,P_LAST_UPDATE_DATE	   in	         DATE
	,P_LAST_UPDATED_BY	   in	         NUMBER
	,P_LAST_UPDATE_LOGIN	   in	         NUMBER
	,P_CREATED_BY		   in	         NUMBER
	,P_CREATION_DATE	   in	         DATE
       );

  PROCEDURE LOCK_ROW (
	  P_UPGRADE_DEFINITION_ID in NUMBER
	, P_LEGISLATION_CODE in VARCHAR2
       );

  PROCEDURE DELETE_ROW (
	  P_UPGRADE_DEFINITION_ID in NUMBER
	 ,P_LEGISLATION_CODE      in VARCHAR2
        );

  PROCEDURE LOAD_ROW (
       	  P_SHORT_NAME             in  VARCHAR2
	, P_LEGISLATION_CODE       in  VARCHAR2
	, P_OWNER		   in  VARCHAR2
       );

END PAY_UPGRADE_LEGISLATIONS_PKG;


 

/
