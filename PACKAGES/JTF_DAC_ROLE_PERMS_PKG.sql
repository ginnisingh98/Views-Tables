--------------------------------------------------------
--  DDL for Package JTF_DAC_ROLE_PERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DAC_ROLE_PERMS_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfarps.pls 120.2 2005/10/25 05:15:39 psanyal ship $ */

  /* for return status */
  ERROR_STATUS      CONSTANT NUMBER      := -1;
  OKAY_STATUS       CONSTANT NUMBER      := 0;

procedure INSERT_ROW(
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_role_perm_id in number,
  x_role_id in number,
  x_permission_id in number,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
  x_object_version_number in number,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure UPDATE_ROW (
  x_role_perm_id in number,
  x_role_id in number,
  x_permission_id in number,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
  x_object_version_number in number,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

PROCEDURE TRANSLATE_ROW(
  x_role_perm_id in number,
  x_role_id in number,
  x_permission_id in number,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
  x_object_version_number in number,
  x_owner in varchar2
);

PROCEDURE LOAD_ROW(
  x_role_perm_id in number,
  x_role_id in number,
  x_permission_id in number,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
  x_object_version_number in number,
  x_owner in varchar2
);

end JTF_DAC_ROLE_PERMS_PKG;

 

/
