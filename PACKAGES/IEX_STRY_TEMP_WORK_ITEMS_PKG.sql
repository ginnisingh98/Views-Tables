--------------------------------------------------------
--  DDL for Package IEX_STRY_TEMP_WORK_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRY_TEMP_WORK_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: iextstws.pls 120.0 2004/01/24 03:23:05 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_STRY_TEMP_WORK_ITEMS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW (
  X_WORK_ITEM_TEMP_ID                in NUMBER,
  X_NAME              in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER                 in VARCHAR2
);
end IEX_STRY_TEMP_WORK_ITEMS_PKG;

 

/
