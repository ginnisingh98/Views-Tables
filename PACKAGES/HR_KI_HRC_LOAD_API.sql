--------------------------------------------------------
--  DDL for Package HR_KI_HRC_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_HRC_LOAD_API" AUTHID CURRENT_USER as
/* $Header: hrkihrcl.pkh 115.0 2004/01/09 06:17:21 vkarandi noship $ */
--
-- Package Variables
--
--

procedure LOAD_ROW
  (
   X_HIERARCHY_KEY        in VARCHAR2,
   X_PARENT_HIERARCHY_KEY in VARCHAR2,
   X_NAME                 in VARCHAR2,
   X_DESCRIPTION          in VARCHAR2,
   X_LAST_UPDATE_DATE     in VARCHAR2,
   X_CUSTOM_MODE          in VARCHAR2,
   X_OWNER                in VARCHAR2
   );

procedure TRANSLATE_ROW
  (
  X_HIERARCHY_KEY in varchar2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in varchar2,
  X_CUSTOM_MODE in varchar2,
  X_LAST_UPDATE_DATE in varchar2
  );

END HR_KI_HRC_LOAD_API;

 

/
