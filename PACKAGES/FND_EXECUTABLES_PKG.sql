--------------------------------------------------------
--  DDL for Package FND_EXECUTABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_EXECUTABLES_PKG" AUTHID CURRENT_USER as
/* $Header: AFCPMPES.pls 115.11 2003/01/09 15:38:10 ckclark ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_EXECUTABLE_ID in NUMBER,
  X_EXECUTABLE_NAME in VARCHAR2,
  X_EXECUTION_METHOD_CODE in VARCHAR2,
  X_EXECUTION_FILE_NAME in VARCHAR2,
  X_SUBROUTINE_NAME in VARCHAR2,
  X_EXECUTION_FILE_PATH in VARCHAR2,
  X_USER_EXECUTABLE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_EXECUTABLE_ID in NUMBER,
  X_EXECUTABLE_NAME in VARCHAR2,
  X_EXECUTION_METHOD_CODE in VARCHAR2,
  X_EXECUTION_FILE_NAME in VARCHAR2,
  X_SUBROUTINE_NAME in VARCHAR2,
  X_EXECUTION_FILE_PATH in VARCHAR2,
  X_USER_EXECUTABLE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_EXECUTABLE_ID in NUMBER,
  X_EXECUTABLE_NAME in VARCHAR2,
  X_EXECUTION_METHOD_CODE in VARCHAR2,
  X_EXECUTION_FILE_NAME in VARCHAR2,
  X_SUBROUTINE_NAME in VARCHAR2,
  X_EXECUTION_FILE_PATH in VARCHAR2,
  X_USER_EXECUTABLE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
-- Overloaded in case x_custom_mode and x_last_update_date not used
procedure TRANSLATE_ROW (
  x_executable_name		in varchar2,
  x_application_short_name	in varchar2,
  x_owner			in varchar2,
  x_user_executable_name	in varchar2,
  x_description			in varchar2
);
-- Overloaded
procedure TRANSLATE_ROW (
  x_executable_name		in varchar2,
  x_application_short_name	in varchar2,
  x_owner			in varchar2,
  x_user_executable_name	in varchar2,
  x_description			in varchar2,
  x_custom_mode 		in varchar2,
  x_last_update_date		in varchar2
);
-- Overloaded in case x_custom_mode and x_last_update_date not used
procedure LOAD_ROW (
  x_executable_name	    in varchar2,
  x_application_short_name  in varchar2,
  x_owner		    in varchar2,
  x_execution_method_code   in varchar2,
  x_execution_file_name     in varchar2,
  x_subroutine_name         in varchar2,
  x_execution_file_path     in varchar2,
  x_user_executable_name    in varchar2,
  x_description 	    in varchar2
);
-- Overloaded
procedure LOAD_ROW (
  x_executable_name	    in varchar2,
  x_application_short_name  in varchar2,
  x_owner		    in varchar2,
  x_execution_method_code   in varchar2,
  x_execution_file_name     in varchar2,
  x_subroutine_name         in varchar2,
  x_execution_file_path     in varchar2,
  x_user_executable_name    in varchar2,
  x_description 	    in varchar2,
  x_custom_mode		    in varchar2,
  x_last_update_date	    in varchar2
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_EXECUTABLE_ID in NUMBER
);
procedure ADD_LANGUAGE;
end FND_EXECUTABLES_PKG;

 

/
