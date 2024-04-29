--------------------------------------------------------
--  DDL for Package PER_CATEGORY_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CATEGORY_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: hruoclct.pkh 115.1 1999/11/09 15:05:15 pkm ship $ */
procedure INSERT_ROW (
  X_PROPOSAL_CATEGORY_TYPE_ID in NUMBER,
  X_TYPE                   in VARCHAR2,
  X_HEADING_TEXT           in VARCHAR2,
  X_HELP_TEXT              in VARCHAR2,
  X_NOTE_TEXT              in VARCHAR2,
  X_FOOTER_TEXT            in VARCHAR2,
  X_CATEGORY_NAME          in VARCHAR2,
  X_CREATION_DATE          in DATE,
  X_CREATED_BY             in VARCHAR2,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in VARCHAR2,
  X_LAST_UPDATE_LOGIN      in NUMBER
);
procedure LOCK_ROW (
  X_PROPOSAL_CATEGORY_TYPE_ID in NUMBER
);
procedure UPDATE_ROW (
  X_PROPOSAL_CATEGORY_TYPE_ID     in NUMBER,
  X_TYPE                   in VARCHAR2,
  X_HEADING_TEXT           in VARCHAR2,
  X_HELP_TEXT              in VARCHAR2,
  X_NOTE_TEXT              in VARCHAR2,
  X_FOOTER_TEXT            in VARCHAR2,
  X_CATEGORY_NAME          in VARCHAR2,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in VARCHAR2,
  X_LAST_UPDATE_LOGIN      in NUMBER
);
procedure DELETE_ROW (
  X_PROPOSAL_CATEGORY_TYPE_ID in NUMBER
);
procedure LOAD_ROW (
  X_PROPOSAL_CATEGORY_TYPE_ID in NUMBER,
  X_TYPE                   in VARCHAR2,
  X_HEADING_TEXT           in VARCHAR2,
  X_HELP_TEXT              in VARCHAR2,
  X_NOTE_TEXT              in VARCHAR2,
  X_FOOTER_TEXT            in VARCHAR2,
  X_CATEGORY_NAME          in VARCHAR2,
  X_OWNER                  in VARCHAR2
);
procedure TRANSLATE_ROW (
  X_PROPOSAL_CATEGORY_TYPE_ID  in NUMBER,
  X_HEADING_TEXT           in VARCHAR2,
  X_HELP_TEXT              in VARCHAR2,
  X_NOTE_TEXT              in VARCHAR2,
  X_FOOTER_TEXT            in VARCHAR2,
  X_CATEGORY_NAME          in VARCHAR2,
  X_OWNER                  in VARCHAR2
);
end PER_CATEGORY_TYPES_PKG;

 

/
