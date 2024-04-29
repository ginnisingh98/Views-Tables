--------------------------------------------------------
--  DDL for Package CST_TPRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_TPRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVTPAS.pls 115.0 2002/11/18 08:13:35 rzhu noship $ */
procedure Adjust_Acct(
  P_API_VERSION         IN      NUMBER,
  P_INIT_MSG_LIST       IN      VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT              IN      VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_TPRICE_OPTION       IN      NUMBER,
  P_TXF_PRICE           IN      NUMBER,
  P_TXN_ID              IN      NUMBER,
  P_COST_GRP_ID         IN      NUMBER,
  P_TXF_COST_GRP        IN      NUMBER,
  P_ITEM_ID             IN      NUMBER,
  P_TXN_DATE            IN      DATE,
  P_QTY                 IN      NUMBER,
  P_SUBINV              IN      VARCHAR2,
  P_TXF_SUBINV          IN      VARCHAR2,
  P_TXN_ORG_ID          IN      NUMBER,
  P_TXF_ORG_ID          IN      NUMBER,
  P_TXF_TXN_ID          IN      NUMBER,
  P_TXF_COST            IN      NUMBER,
  P_TXN_ACT_ID          IN      NUMBER,
  P_TXN_SRC_ID          IN      NUMBER,
  P_SRC_TYPE_ID         IN      NUMBER,
  P_FOB_POINT           IN      NUMBER,
  P_USER_ID             IN      NUMBER,
  P_LOGIN_ID            IN      NUMBER,
  P_REQ_ID              IN      NUMBER,
  P_PRG_APPL_ID         IN      NUMBER,
  P_PRG_ID              IN      NUMBER,
  X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
  X_MSG_COUNT           OUT NOCOPY NUMBER,
  X_MSG_DATA            OUT NOCOPY VARCHAR2,
  X_ERROR_NUM           OUT NOCOPY NUMBER,
  X_ERROR_CODE          OUT NOCOPY VARCHAR2,
  X_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
);

END CST_TPRICE_PVT;

 

/
