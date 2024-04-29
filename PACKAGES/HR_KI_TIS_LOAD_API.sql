--------------------------------------------------------
--  DDL for Package HR_KI_TIS_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_TIS_LOAD_API" AUTHID CURRENT_USER as
/* $Header: hrkitisl.pkh 120.1 2008/02/01 10:40:28 avarri ship $ */
--
-- Package Variables
--
--
procedure LOAD_ROW
  (
   X_TOPIC_KEY        in VARCHAR2,
   X_INTEGRATION_KEY  in VARCHAR2,
   X_PARAM_NAME1      in VARCHAR2,
   X_PARAM_VALUE1     in VARCHAR2,
   X_PARAM_NAME2      in VARCHAR2,
   X_PARAM_VALUE2     in VARCHAR2,
   X_PARAM_NAME3      in VARCHAR2,
   X_PARAM_VALUE3     in VARCHAR2,
   X_PARAM_NAME4      in VARCHAR2,
   X_PARAM_VALUE4     in VARCHAR2,
   X_PARAM_NAME5      in VARCHAR2,
   X_PARAM_VALUE5     in VARCHAR2,
   X_PARAM_NAME6      in VARCHAR2,
   X_PARAM_VALUE6     in VARCHAR2,
   X_PARAM_NAME7      in VARCHAR2,
   X_PARAM_VALUE7     in VARCHAR2,
   X_PARAM_NAME8      in VARCHAR2,
   X_PARAM_VALUE8     in VARCHAR2,
   X_PARAM_NAME9      in VARCHAR2,
   X_PARAM_VALUE9     in VARCHAR2,
   X_PARAM_NAME10     in VARCHAR2,
   X_PARAM_VALUE10    in VARCHAR2,
   X_LAST_UPDATE_DATE in VARCHAR2,
   X_CUSTOM_MODE      in VARCHAR2,
   X_OWNER            in VARCHAR2
);
--
END HR_KI_TIS_LOAD_API;

/
