--------------------------------------------------------
--  DDL for Package HR_KI_ITF_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_ITF_LOAD_API" AUTHID CURRENT_USER as
/* $Header: hrkiitfl.pkh 115.0 2004/01/11 21:46:00 vkarandi noship $ */
--
-- Package Variables
--
--

procedure LOAD_ROW
  (
   X_USER_INTERFACE_KEY   in VARCHAR2,
   X_TYPE                 in VARCHAR2,
   X_FORM_NAME            in VARCHAR2,
   X_PAGE_REGION_CODE     in VARCHAR2,
   X_REGION_CODE          in VARCHAR2,
   X_LAST_UPDATE_DATE     in VARCHAR2,
   X_CUSTOM_MODE          in VARCHAR2,
   X_OWNER                in VARCHAR2
   );

END HR_KI_ITF_LOAD_API;

 

/
