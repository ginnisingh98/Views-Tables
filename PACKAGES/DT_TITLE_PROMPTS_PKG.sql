--------------------------------------------------------
--  DDL for Package DT_TITLE_PROMPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DT_TITLE_PROMPTS_PKG" AUTHID CURRENT_USER AS
/* $Header: dttprrhi.pkh 115.3 2002/12/06 11:40:41 apholt ship $ */
procedure ADD_LANGUAGE;
PROCEDURE LOAD_ROW (
  X_VIEW_NAME   in VARCHAR2,
  X_TITLE_PROMPT in VARCHAR2,
  X_OWNER        in VARCHAR2
);
PROCEDURE TRANSLATE_ROW (
  X_VIEW_NAME in VARCHAR2,
  X_TITLE_PROMPT in VARCHAR2,
  X_OWNER        in VARCHAR2
);
end DT_TITLE_PROMPTS_PKG;

 

/
