--------------------------------------------------------
--  DDL for Package IEX_APP_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_APP_PREFERENCES_PKG" AUTHID CURRENT_USER as
/* $Header: iextapps.pls 120.0 2004/01/24 03:21:05 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_APP_PREFERENCES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_PREFERENCE_ID          in NUMBER,
  X_USER_NAME              in VARCHAR2,
  X_OBJECT_VERSION_NUMBER  in NUMBER,
  X_OWNER                  in VARCHAR2
);

end IEX_APP_PREFERENCES_PKG;

 

/
