--------------------------------------------------------
--  DDL for Package PER_QUESTION_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QUESTION_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: hrupqlct.pkh 115.0 99/08/05 04:03:10 porting  $ */
procedure INSERT_ROW (
  X_PROPOSAL_QUESTION_NAME in VARCHAR2,
  X_ALIGN                  in VARCHAR2,
  X_HTML_TYPE              in VARCHAR2,
  X_WIDTH_SIZE             in NUMBER,
  X_HEIGHT_SIZE            in NUMBER,
  X_MAXLENGTH              in NUMBER,
  X_DEFAULT_VALUE_TYPE     in VARCHAR2,
  X_LOOKUP_TYPE            in VARCHAR2,
  X_OPTION_SQL_TEXT        in VARCHAR2,
  X_PROVIDE_FIND           in VARCHAR2,
  X_FIND_FILTER_COLUMN     in VARCHAR2,
  X_FIND_SELECT_SQL        in VARCHAR2,
  X_TYPE                   in VARCHAR2,
  X_DEFAULT_VALUE          in VARCHAR2,
  X_FULL_TEXT              in VARCHAR2,
  X_QUESTION_HEADER        in VARCHAR2,
  X_HELP_TEXT              in VARCHAR2,
  X_NOTE_TEXT              in VARCHAR2,
  X_CREATION_DATE          in DATE,
  X_CREATED_BY             in VARCHAR2,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in VARCHAR2,
  X_LAST_UPDATE_LOGIN      in NUMBER
);
procedure LOCK_ROW (
  X_PROPOSAL_QUESTION_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_PROPOSAL_QUESTION_NAME in VARCHAR2,
  X_ALIGN                  in VARCHAR2,
  X_HTML_TYPE              in VARCHAR2,
  X_WIDTH_SIZE             in NUMBER,
  X_HEIGHT_SIZE            in NUMBER,
  X_MAXLENGTH              in NUMBER,
  X_DEFAULT_VALUE_TYPE     in VARCHAR2,
  X_LOOKUP_TYPE            in VARCHAR2,
  X_OPTION_SQL_TEXT        in VARCHAR2,
  X_PROVIDE_FIND           in VARCHAR2,
  X_FIND_FILTER_COLUMN     in VARCHAR2,
  X_FIND_SELECT_SQL        in VARCHAR2,
  X_TYPE                   in VARCHAR2,
  X_DEFAULT_VALUE          in VARCHAR2,
  X_FULL_TEXT              in VARCHAR2,
  X_QUESTION_HEADER        in VARCHAR2,
  X_HELP_TEXT              in VARCHAR2,
  X_NOTE_TEXT              in VARCHAR2,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in VARCHAR2,
  X_LAST_UPDATE_LOGIN      in NUMBER
);
procedure DELETE_ROW (
  X_PROPOSAL_QUESTION_NAME in VARCHAR2
);
procedure LOAD_ROW (
  X_PROPOSAL_QUESTION_NAME in VARCHAR2,
  X_ALIGN                  in VARCHAR2,
  X_HTML_TYPE              in VARCHAR2,
  X_WIDTH_SIZE             in NUMBER,
  X_HEIGHT_SIZE            in NUMBER,
  X_MAXLENGTH              in NUMBER,
  X_DEFAULT_VALUE_TYPE     in VARCHAR2,
  X_LOOKUP_TYPE            in VARCHAR2,
  X_OPTION_SQL_TEXT        in VARCHAR2,
  X_PROVIDE_FIND           in VARCHAR2,
  X_FIND_FILTER_COLUMN     in VARCHAR2,
  X_FIND_SELECT_SQL        in VARCHAR2,
  X_TYPE                   in VARCHAR2,
  X_DEFAULT_VALUE          in VARCHAR2,
  X_FULL_TEXT              in VARCHAR2,
  X_QUESTION_HEADER        in VARCHAR2,
  X_HELP_TEXT              in VARCHAR2,
  X_NOTE_TEXT              in VARCHAR2,
  X_OWNER in VARCHAR2
);
procedure TRANSLATE_ROW (
  X_PROPOSAL_QUESTION_NAME in VARCHAR2,
  X_DEFAULT_VALUE          in VARCHAR2,
  X_FULL_TEXT              in VARCHAR2,
  X_QUESTION_HEADER        in VARCHAR2,
  X_HELP_TEXT              in VARCHAR2,
  X_NOTE_TEXT              in VARCHAR2,
  X_OWNER                  in VARCHAR2
);
end PER_QUESTION_TYPES_PKG;

 

/
