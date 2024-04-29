--------------------------------------------------------
--  DDL for Package PER_STARTUP_PERSON_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STARTUP_PERSON_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: pespt01t.pkh 115.5 2002/12/09 10:53:04 eumenyio ship $ */
g_firstrun varchar2(10) := 'Y';
procedure POPULATE_KEY (
  p_seeded_person_type_key in varchar2,
  p_user_person_type in varchar2,
  p_system_person_type in varchar2);

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SEEDED_PERSON_TYPE_KEY in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SYSTEM_PERSON_TYPE in VARCHAR2,
  X_CURRENT_APPLICANT_FLAG in VARCHAR2,
  X_CURRENT_EMP_OR_APL_FLAG in VARCHAR2,
  X_CURRENT_EMPLOYEE_FLAG in VARCHAR2,
  X_USER_PERSON_TYPE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure UPDATE_ROW (
  X_FORCE_MODE in varchar2,
  X_SEEDED_PERSON_TYPE_KEY in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SYSTEM_PERSON_TYPE in VARCHAR2,
  X_CURRENT_APPLICANT_FLAG in VARCHAR2,
  X_CURRENT_EMP_OR_APL_FLAG in VARCHAR2,
  X_CURRENT_EMPLOYEE_FLAG in VARCHAR2,
  X_USER_PERSON_TYPE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure DELETE_ROW (
  X_SEEDED_PERSON_TYPE_KEY in VARCHAR2
);
procedure LOAD_ROW (
  x_Upload_mode  in varchar2,
  X_SEEDED_PERSON_TYPE_KEY in varchar2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SYSTEM_PERSON_TYPE in VARCHAR2,
  X_CURRENT_APPLICANT_FLAG in VARCHAR2,
  X_CURRENT_EMP_OR_APL_FLAG in VARCHAR2,
  X_CURRENT_EMPLOYEE_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in varchar2,
  X_USER_PERSON_TYPE in VARCHAR2
   );

procedure TRANSLATE_ROW (
  X_SEEDED_PERSON_TYPE_KEY in varchar2,
  X_USER_PERSON_TYPE in VARCHAR2,
  X_LAST_UPDATE_DATE in varchar2);

function validate_upload (
p_Upload_mode           in varchar2,
p_Table_name            in varchar2,
p_new_row_updated_by    in varchar2,
p_new_row_update_date  in date,
p_Table_key_name        in varchar2,
p_table_key_value       in varchar2)
return boolean;


PROCEDURE data_upgrade;

procedure ADD_LANGUAGE;
end PER_STARTUP_PERSON_TYPES_PKG;

 

/
