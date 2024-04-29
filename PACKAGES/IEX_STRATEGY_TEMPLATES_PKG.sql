--------------------------------------------------------
--  DDL for Package IEX_STRATEGY_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGY_TEMPLATES_PKG" AUTHID CURRENT_USER as
/* $Header: iextstts.pls 120.2 2006/02/24 06:38:03 kasreeni noship $ */
-- Start of Comments
-- Package name     : IEX_STRATEGY_TEMPLATES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW (
  X_STRATEGY_TEMP_ID                in NUMBER,
  X_STRATEGY_NAME              in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER                 in VARCHAR2
);

/* begin BUG 4939638 kasreeni 02/26/2006 Copy Strategy Group */
PROCEDURE COPY_STRATEGY_GROUP(P_GROUP_ID in NUMBER, RETURN_STATUS OUT NOCOPY VARCHAR2);

/* end  BUG 4939638 kasreeni 02/26/2006 Copy Strategy Group */
end IEX_STRATEGY_TEMPLATES_PKG;

 

/
