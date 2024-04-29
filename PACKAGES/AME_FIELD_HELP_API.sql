--------------------------------------------------------
--  DDL for Package AME_FIELD_HELP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_FIELD_HELP_API" AUTHID CURRENT_USER AS
/* $Header: amefhapi.pkh 120.0 2005/07/26 06:00:18 mbocutt noship $ */
procedure INSERT_ROW (
 X_FIELD_NAME                      in VARCHAR2,
 X_PROCEDURE_NAME                  in VARCHAR2,
 X_PACKAGE_NAME                    in VARCHAR2,
 X_HELP_TEXT                       in VARCHAR2);

procedure UPDATE_ROW (
        X_FIELD_HELP_ROWID                in VARCHAR2,
        X_HELP_TEXT                       in VARCHAR2);

procedure DELETE_ROW (
  X_FIELD_NAME      in VARCHAR2,
  X_PROCEDURE_NAME  in VARCHAR2,
  X_PACKAGE_NAME    in VARCHAR2
);

procedure LOAD_ROW (
        X_FIELD_NAME                      in VARCHAR2,
        X_PROCEDURE_NAME                  in VARCHAR2,
        X_PACKAGE_NAME                    in VARCHAR2,
        X_HELP_TEXT                       in VARCHAR2
);

END AME_FIELD_HELP_API;

 

/
