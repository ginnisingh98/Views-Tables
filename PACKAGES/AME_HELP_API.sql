--------------------------------------------------------
--  DDL for Package AME_HELP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_HELP_API" AUTHID CURRENT_USER AS
/* $Header: ameheapi.pkh 120.0 2005/07/26 06:00:30 mbocutt noship $ */

procedure INSERT_ROW (
 X_CONTEXT                         in VARCHAR2,
 X_FILE_NAME                       in VARCHAR2);

procedure UPDATE_ROW (
 X_HELP_ROWID                      in VARCHAR2,
 X_FILE_NAME                       in VARCHAR2);

procedure DELETE_ROW (
  X_CONTEXT   in VARCHAR2,
  X_FILE_NAME in VARCHAR2
);

procedure LOAD_ROW (
          X_CONTEXT          in VARCHAR2,
          X_FILE_NAME        in VARCHAR2
);

END AME_HELP_API;

 

/
