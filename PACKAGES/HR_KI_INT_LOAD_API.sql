--------------------------------------------------------
--  DDL for Package HR_KI_INT_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_INT_LOAD_API" AUTHID CURRENT_USER as
/* $Header: hrkiintl.pkh 115.0 2004/01/11 21:30:17 vkarandi noship $ */
--
-- Package Variables
--
--

procedure LOAD_ROW
  (
   X_INTEGRATION_KEY       in VARCHAR2,
   X_PARTY_TYPE            in VARCHAR2,
   X_PARTY_NAME            in VARCHAR2,
   X_PARTY_SITE_NAME       in VARCHAR2,
   X_TRANSACTION_TYPE      in VARCHAR2,
   X_TRANSACTION_SUBTYPE   in VARCHAR2,
   X_STANDARD_CODE         in VARCHAR2,
   X_EXT_TRANS_TYPE        in VARCHAR2,
   X_EXT_TRANS_SUBTYPE     in VARCHAR2,
   X_TRANS_DIRECTION       in VARCHAR2,
   X_URL                   in VARCHAR2,
   X_SYNCHED               in VARCHAR2,
   X_APPLICATION_NAME      in VARCHAR2,
   X_APPLICATION_TYPE      in VARCHAR2,
   X_APPLICATION_URL       in VARCHAR2,
   X_LOGOUT_URL            in VARCHAR2,
   X_USER_FIELD            in VARCHAR2,
   X_PASSWORD_FIELD        in VARCHAR2,
   X_AUTHENTICATION_NEEDED in VARCHAR2,
   X_FIELD_NAME1           in VARCHAR2,
   X_FIELD_VALUE1          in VARCHAR2,
   X_FIELD_NAME2           in VARCHAR2,
   X_FIELD_VALUE2          in VARCHAR2,
   X_FIELD_NAME3           in VARCHAR2,
   X_FIELD_VALUE3          in VARCHAR2,
   X_FIELD_NAME4           in VARCHAR2,
   X_FIELD_VALUE4          in VARCHAR2,
   X_FIELD_NAME5           in VARCHAR2,
   X_FIELD_VALUE5          in VARCHAR2,
   X_FIELD_NAME6           in VARCHAR2,
   X_FIELD_VALUE6          in VARCHAR2,
   X_FIELD_NAME7           in VARCHAR2,
   X_FIELD_VALUE7          in VARCHAR2,
   X_FIELD_NAME8           in VARCHAR2,
   X_FIELD_VALUE8          in VARCHAR2,
   X_FIELD_NAME9           in VARCHAR2,
   X_FIELD_VALUE9          in VARCHAR2,
   X_PARTNER_NAME          in VARCHAR2,
   X_SERVICE_NAME          in VARCHAR2,
   X_LAST_UPDATE_DATE      in VARCHAR2,
   X_CUSTOM_MODE           in VARCHAR2,
   X_OWNER                 in VARCHAR2
  );

procedure TRANSLATE_ROW
  (
  X_INTEGRATION_KEY  in varchar2,
  X_PARTNER_NAME     in VARCHAR2,
  X_SERVICE_NAME     in VARCHAR2,
  X_OWNER            in varchar2,
  X_CUSTOM_MODE      in varchar2,
  X_LAST_UPDATE_DATE in varchar2
  );

END HR_KI_INT_LOAD_API;

 

/
