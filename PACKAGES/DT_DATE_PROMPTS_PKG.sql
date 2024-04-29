--------------------------------------------------------
--  DDL for Package DT_DATE_PROMPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DT_DATE_PROMPTS_PKG" AUTHID CURRENT_USER AS
/* $Header: dtdprrhi.pkh 115.3 2002/12/06 15:57:53 apholt ship $ */
procedure ADD_LANGUAGE;
--
PROCEDURE LOAD_ROW (
  X_EFFECTIVE_END_PROMPT in VARCHAR2,
  X_EFFECTIVE_START_PROMPT in VARCHAR2,
  X_OWNER                in VARCHAR2
);
--
PROCEDURE TRANSLATE_ROW (
  X_EFFECTIVE_END_PROMPT in VARCHAR2,
  X_EFFECTIVE_START_PROMPT in VARCHAR2,
  X_OWNER                  in VARCHAR2
);
--
end DT_DATE_PROMPTS_PKG;

 

/
