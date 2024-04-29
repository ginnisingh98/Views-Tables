--------------------------------------------------------
--  DDL for Package HR_KI_OTY_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_OTY_LOAD_API" AUTHID CURRENT_USER as
/* $Header: hrkiotyl.pkh 115.0 2004/01/11 21:36:59 vkarandi noship $ */
--
-- Package Variables
--
--
procedure TRANSLATE_ROW
          (
          X_OPTION_TYPE_KEY  in varchar2
         ,X_OPTION_NAME      in varchar2
         ,X_OWNER            in varchar2
         ,X_CUSTOM_MODE      in varchar2
         ,X_LAST_UPDATE_DATE in varchar2
         );

procedure LOAD_ROW
          (
          X_OPTION_TYPE_KEY  in varchar2
         ,X_DISPLAY_TYPE     in varchar2
         ,X_OPTION_NAME      in varchar2
         ,X_OWNER            in varchar2
         ,X_CUSTOM_MODE      in varchar2
         ,X_LAST_UPDATE_DATE in varchar2
         );
END HR_KI_OTY_LOAD_API;

 

/
