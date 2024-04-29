--------------------------------------------------------
--  DDL for Package DT_COLUMN_PROMPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DT_COLUMN_PROMPTS_PKG" AUTHID CURRENT_USER AS
/* $Header: dtclprhi.pkh 115.3 2002/12/09 15:41:38 apholt ship $ */
procedure ADD_LANGUAGE;
procedure LOAD_ROW (
                    X_VIEW_NAME      in VARCHAR2,
                    X_COLUMN_NAME    in VARCHAR2,
                    X_COLUMN_PROMPT  in VARCHAR2,
                    X_OWNER          in VARCHAR2
                   );
procedure TRANSLATE_ROW (
                         X_VIEW_NAME     in VARCHAR2,
                         X_COLUMN_NAME   in VARCHAR2,
                         X_COLUMN_PROMPT in VARCHAR2,
                         X_OWNER         in VARCHAR2
                        );
end DT_COLUMN_PROMPTS_PKG;

 

/
