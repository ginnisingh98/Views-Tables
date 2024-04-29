--------------------------------------------------------
--  DDL for Package HR_KI_OPT_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_OPT_LOAD_API" AUTHID CURRENT_USER as
/* $Header: hrkioptl.pkh 115.0 2004/01/11 21:39:51 vkarandi noship $ */
--
-- Package Variables
--
--
procedure LOAD_ROW
  (
   X_OPTION_TYPE_KEY  in VARCHAR2,
   X_OPTION_LEVEL     in VARCHAR2,
   X_OPTION_LEVEL_KEY in VARCHAR2,
   X_INTEGRATION_KEY  in VARCHAR2,
   X_VALUE            in VARCHAR2,
   X_ENCRYPTED        in VARCHAR2,
   X_OWNER            in VARCHAR2,
   X_CUSTOM_MODE      in VARCHAR2,
   X_LAST_UPDATE_DATE in VARCHAR2
  );

END HR_KI_OPT_LOAD_API;

 

/
