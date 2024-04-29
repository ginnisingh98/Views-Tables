--------------------------------------------------------
--  DDL for Package EAM_SAFETY_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_SAFETY_STATUSES_PKG" AUTHID CURRENT_USER as
/* $Header: EAMSFSTS.pls 120.0.12010000.4 2010/03/24 10:16:44 vboddapa noship $ */

--This procedure will insert new rows in EAM_SAFETY_USR_DEF_STATUSES_B and eam_safety_usr_def_statuses_tl tables
procedure INSERT_ROW (
  X_ROWID						 in out NOCOPY VARCHAR2,
  X_STATUS_ID					  in out NOCOPY NUMBER,
  P_SEEDED_FLAG				in VARCHAR2,
  P_SYSTEM_STATUS			in NUMBER,
  P_ENABLED_FLAG				in VARCHAR2,
  P_USER_DEFINED_STATUS			 in VARCHAR2,
  P_ENTITY_TYPE	        in NUMBER,
  P_CREATION_DATE				in DATE,
  P_CREATED_BY				in NUMBER,
  P_LAST_UPDATE_DATE			in DATE,
  P_LAST_UPDATED_BY			in NUMBER,
  P_LAST_UPDATE_LOGIN		in NUMBER
  );

--This procedure will update rows in EAM_SAFETY_USR_DEF_STATUSES_B and eam_safety_usr_def_statuses_tl tables
procedure UPDATE_ROW (
  P_STATUS_ID					  in NUMBER,
  P_SEEDED_FLAG				in VARCHAR2,
  P_SYSTEM_STATUS			in NUMBER,
  P_ENABLED_FLAG				in VARCHAR2,
  P_USER_DEFINED_STATUS		 in VARCHAR2,
  P_ENTITY_TYPE	        in NUMBER,
  P_LAST_UPDATE_DATE			in DATE,
  P_LAST_UPDATED_BY			in NUMBER,
  P_LAST_UPDATE_LOGIN		in NUMBER,
  P_MODE                                              in VARCHAR2 DEFAULT 'FORMS'
);

--This procedure will delete rows in EAM_SAFETY_USR_DEF_STATUSES_B and eam_safety_usr_def_statuses_tl tables
procedure DELETE_ROW (
  P_STATUS_ID in NUMBER,
  P_ENTITY_TYPE in NUMBER
);

--This procedure will be called when a new langauge is installed. This will insert rows
-- in Eam_Wo_Statuses_TL table for the new langauge
procedure ADD_LANGUAGE;

--This procedure will be called for all the langauges to translate the User_Defined_Status value
procedure TRANSLATE_ROW
(
			P_STATUS_ID						in NUMBER,
                         P_USER_DEFINED_STATUS			in VARCHAR2,
                         P_ENTITY_TYPE       in NUMBER,
                         P_OWNER							in VARCHAR2,
                         P_LAST_UPDATE_DATE				in VARCHAR2,
                         P_CUSTOM_MODE					in VARCHAR2
);

--This procedure will be called during upgarde of seeded statuses
procedure LOAD_ROW
(
  X_STATUS_ID					  in out nocopy NUMBER,
  P_SEEDED_FLAG				in VARCHAR2,
  P_SYSTEM_STATUS			in NUMBER,
  P_ENABLED_FLAG				in VARCHAR2,
  P_USER_DEFINED_STATUS			 in VARCHAR2,
  P_ENTITY_TYPE	        in NUMBER,
  P_OWNER							in VARCHAR2,
  P_LAST_UPDATE_DATE			in VARCHAR2,
  P_CUSTOM_MODE					in VARCHAR2
  );


end EAM_SAFETY_STATUSES_PKG;

/
