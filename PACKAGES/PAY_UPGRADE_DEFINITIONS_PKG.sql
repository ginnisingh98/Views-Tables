--------------------------------------------------------
--  DDL for Package PAY_UPGRADE_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_UPGRADE_DEFINITIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: pypud01t.pkh 120.1 2005/06/16 03:21 nmanchan noship $ */

  PROCEDURE Insert_Row (
  	 P_SHORT_NAME              in            VARCHAR2
	,P_NAME			   in		 VARCHAR2
	,P_DESCRIPTION             in            VARCHAR2
	,P_LEGISLATION_CODE        in            VARCHAR2   default null
	,P_UPGRADE_LEVEL           in            VARCHAR2
	,P_CRITICALITY             in            VARCHAR2
	,P_FAILURE_POINT           in            VARCHAR2
	,P_LEGISLATIVELY_ENABLED   in            VARCHAR2
	,P_UPGRADE_PROCEDURE       in            VARCHAR2
	,P_THREADING_LEVEL         in            VARCHAR2
	,P_UPGRADE_METHOD          in            VARCHAR2
	,P_QUALIFYING_PROCEDURE    in            VARCHAR2   default null
	,P_OWNER_APPL_ID           in            NUMBER     default null
        ,P_FIRST_PATCHSET          in            VARCHAR2   default null
        ,P_VALIDATE_CODE           in            VARCHAR2   default null
        ,P_ADDITIONAL_INFO         in            VARCHAR2   default null
	,P_LAST_UPDATE_DATE	   in	         DATE
	,P_LAST_UPDATED_BY	   in	         NUMBER
	,P_LAST_UPDATE_LOGIN	   in	         NUMBER
	,P_CREATED_BY		   in	         NUMBER
	,P_CREATION_DATE	   in	         DATE
	,P_UPGRADE_DEFINITION_ID   out nocopy    NUMBER
       );

  PROCEDURE UPDATE_ROW (
	  P_UPGRADE_DEFINITION_ID  in            NUMBER
        , P_CRITICALITY            in            VARCHAR2
        , P_FAILURE_POINT          in            VARCHAR2
        , P_UPGRADE_PROCEDURE      in            VARCHAR2
        , P_DESCRIPTION            in            VARCHAR2
	, P_QUALIFYING_PROCEDURE   in            VARCHAR2
	, P_OWNER_APPL_ID          in            NUMBER
        , P_FIRST_PATCHSET         in            VARCHAR2
        , P_VALIDATE_CODE          in            VARCHAR2
        , P_ADDITIONAL_INFO        in            VARCHAR2
	, P_LAST_UPDATE_DATE       in            DATE
	, P_LAST_UPDATED_BY        in            NUMBER
	, P_LAST_UPDATE_LOGIN      in            NUMBER
       );

  PROCEDURE LOCK_ROW (
	  P_UPGRADE_DEFINITION_ID  in            NUMBER
	, P_SHORT_NAME             in            VARCHAR2
	, P_NAME                   in            VARCHAR2
	, P_LEGISLATION_CODE       in            VARCHAR2
	, P_UPGRADE_LEVEL          in            VARCHAR2
	, P_CRITICALITY            in            VARCHAR2
	, P_FAILURE_POINT          in            VARCHAR2
	, P_LEGISLATIVELY_ENABLED  in            VARCHAR2
	, P_UPGRADE_PROCEDURE      in            VARCHAR2
	, P_THREADING_LEVEL        in            VARCHAR2
	, P_DESCRIPTION            in            VARCHAR2
	, P_UPGRADE_METHOD         in            VARCHAR2
	, P_QUALIFYING_PROCEDURE   in            VARCHAR2
       );

  PROCEDURE DELETE_ROW (
	  P_UPGRADE_DEFINITION_ID in NUMBER
	);

  PROCEDURE ADD_LANGUAGE;

  PROCEDURE LOAD_ROW (
       	  P_SHORT_NAME             in  VARCHAR2
        , P_NAME	           in  VARCHAR2
	, P_DESCRIPTION            in  VARCHAR2
	, P_LEGISLATION_CODE       in  VARCHAR2
	, P_UPGRADE_LEVEL          in  VARCHAR2
	, P_CRITICALITY            in  VARCHAR2
	, P_THREADING_LEVEL        in  VARCHAR2
	, P_FAILURE_POINT          in  VARCHAR2
	, P_LEGISLATIVELY_ENABLED  in  VARCHAR2
	, P_UPGRADE_PROCEDURE      in  VARCHAR2
	, P_UPGRADE_METHOD         in  VARCHAR2
	, P_QUALIFYING_PROCEDURE   in  VARCHAR2
	, P_OWNER_APPL_SHORT_NAME  in  VARCHAR2
	, P_FIRST_PATCHSET         in  VARCHAR2
	, P_VALIDATE_CODE          in  VARCHAR2
        , P_ADDITIONAL_INFO        in  VARCHAR2
	, P_OWNER		   in  VARCHAR2
       );

  PROCEDURE TRANSLATE_ROW (
       	  P_SHORT_NAME      in  VARCHAR2
        , P_NAME	    in  VARCHAR2
	, P_DESCRIPTION     in  VARCHAR2
	, P_ADDITIONAL_INFO  in varchar2
	, P_OWNER	    in  VARCHAR2
       );


END PAY_UPGRADE_DEFINITIONS_PKG;


 

/
