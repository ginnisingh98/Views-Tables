--------------------------------------------------------
--  DDL for Package JL_BR_SPED_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_SPED_PUB" AUTHID CURRENT_USER AS
/* $Header: jlspedps.pls 120.0.12010000.2 2008/11/13 08:01:49 pakumare noship $ */

-- UPDATE_ATTRIBUTES Procedure - To update the attributes

PROCEDURE UPDATE_ATTRIBUTES (
  P_API_VERSION	              IN	    NUMBER    DEFAULT 1.0,
  P_COMMIT	              IN	    VARCHAR2  DEFAULT FND_API.G_FALSE,
  P_CUSTOMER_TRX_ID           IN	    NUMBER,
  P_ELECT_INV_WEB_ADDRESS     IN	    VARCHAR2,
  P_ELECT_INV_STATUS          IN	    VARCHAR2,
  P_ELECT_INV_ACCESS_KEY      IN            VARCHAR2,
  P_ELECT_INV_PROTOCOL        IN	    VARCHAR2,
  X_RETURN_STATUS             OUT   NOCOPY  VARCHAR2,
  X_MSG_DATA                  OUT   NOCOPY  VARCHAR2);

-- INSERT_LOG Procedure - To insert the log

PROCEDURE INSERT_LOG (
  P_API_VERSION	              IN	    NUMBER    DEFAULT 1.0,
  P_COMMIT	              IN	    VARCHAR2  DEFAULT FND_API.G_FALSE,
  P_CUSTOMER_TRX_ID           IN	    NUMBER,
  P_OCCURRENCE_DATE           IN	    DATE,
  P_ELECT_INV_STATUS          IN	    VARCHAR2,
  P_MESSAGE_TEXT              IN            VARCHAR2,
  X_RETURN_STATUS             OUT   NOCOPY  VARCHAR2,
  X_MSG_DATA                  OUT   NOCOPY  VARCHAR2);


-- GET_IBGE_CODES Procedure - To retrieve IBGE code for a given Location

PROCEDURE GET_IBGE_CODES (
  P_API_VERSION	              IN	    NUMBER    DEFAULT 1.0,
  P_LOCATION_ID               IN	    NUMBER      ,
  X_STATE_CODE                OUT   NOCOPY  VARCHAR2,
  X_CITY_CODE                 OUT   NOCOPY  VARCHAR2,
  X_CENTRAL_BANK_CODE         OUT   NOCOPY  VARCHAR2,
  X_RETURN_STATUS             OUT   NOCOPY  VARCHAR2,
  X_MSG_DATA                  OUT   NOCOPY  VARCHAR2);


END JL_BR_SPED_PUB;

/
