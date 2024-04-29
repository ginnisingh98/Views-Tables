--------------------------------------------------------
--  DDL for Package PAY_UPGRADE_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_UPGRADE_PARAMETERS_PKG" AUTHID CURRENT_USER AS
/* $Header: pypup01t.pkh 120.1 2005/07/07 03:56 rajeesha noship $ */

  PROCEDURE Insert_Row (
  	 P_UPG_DEF_SHORT_NAME   in            VARCHAR2
	,P_PARAMETER_NAME	   in		 VARCHAR2
	,P_PARAMETER_VALUE         in            VARCHAR2
	,P_last_update_date        in            DATE
	,P_LAST_UPDATED_BY         in            NUMBER
	,P_LAST_UPDATE_LOGIN       in            NUMBER
	,P_CREATED_BY              in            NUMBER
	,P_CREATION_DATE           in            DATE
       );

  PROCEDURE UPDATE_ROW (
	  P_UPGRADE_DEFINITION_ID  in            NUMBER
        , P_PARAMETER_NAME	   in		 VARCHAR2
	, P_PARAMETER_VALUE        in            VARCHAR2
	, P_LAST_UPDATE_DATE       in            DATE
	, P_LAST_UPDATED_BY        in            NUMBER
	, P_LAST_UPDATE_LOGIN      in            NUMBER
       );

  PROCEDURE LOAD_ROW (
       	  P_SHORT_NAME             in            VARCHAR2
        , P_PARAMETER_NAME	   in		 VARCHAR2
	, P_PARAMETER_VALUE        in            VARCHAR2
	, P_OWNER		   in            VARCHAR2
       );

END PAY_UPGRADE_PARAMETERS_PKG;


 

/
