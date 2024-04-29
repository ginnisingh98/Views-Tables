--------------------------------------------------------
--  DDL for Package OZF_DEBUG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_DEBUG_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvdbgs.pls 120.0.12010000.3 2012/11/06 06:58:28 nkjaiswa noship $*/

/*****************************************************************************************/
   -- NAME --    DEBUG_MO
   -- PURPOSE
   --    Retrieves the MOAC context form MO_GLOBAL and DB session
   --    and pass it to the calling API.
/*****************************************************************************************/

  PROCEDURE DEBUG_MO(P_APP_SHORT_NAME OUT NOCOPY  VARCHAR2,
            P_RESP_ID OUT NOCOPY  NUMBER,
            P_USER_ID OUT NOCOPY NUMBER,
            P_MO_CURRENT_ORG_ID OUT NOCOPY NUMBER,
            P_MO_ACCESS_MODE OUT NOCOPY VARCHAR2,
            P_DB_CURRENT_ORG_ID OUT NOCOPY NUMBER,
            P_DB_ACCESS_MODE OUT NOCOPY VARCHAR2,
            P_MO_SECURITY_ORGS OUT NOCOPY VARCHAR2);

/*****************************************************************************************/
   -- NAME --    DEBUG_MO
   -- PURPOSE
   --    Retrieves the MOAC context form MO_GLOBAL and DB session
   --    and log  into the  FND_LOG_MESSAGES.
/*****************************************************************************************/

  PROCEDURE DEBUG_MO(P_TEXT IN VARCHAR2);

END OZF_DEBUG_PVT;

/
