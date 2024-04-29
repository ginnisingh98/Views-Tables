--------------------------------------------------------
--  DDL for Package INVPCOII
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPCOII" AUTHID CURRENT_USER AS
/* $Header: INVPCOIS.pls 120.1 2005/12/05 01:08:39 anmurali noship $ */

FUNCTION CSTFVSUB (
         I_TRANSID              IN      NUMBER,
	 I_MATERIAL_SUB_ELEM    IN      VARCHAR2 DEFAULT NULL,
	 I_MATERIAL_OH_SUB_ELEM IN      VARCHAR2 DEFAULT NULL,
	 I_ORGANIZATION_ID      IN      NUMBER,
         I_USER_ID              IN      NUMBER := -1,
         I_LOGIN_ID             IN      NUMBER := -1,
         I_REQ_ID               IN      NUMBER := -1,
         I_PRGM_ID              IN      NUMBER := -1,
         I_PRGM_APPL_ID         IN      NUMBER := -1,
         O_ERR_TEXT             IN OUT  NOCOPY VARCHAR2)
RETURN INTEGER;


PROCEDURE CSTPIICD (
         I_ORGANIZATION_ID      IN      NUMBER,
         I_INVENTORY_ITEM_ID    IN      NUMBER,
         I_COST_ELEMENT_ID      IN      NUMBER,
         I_COST_RATE            IN      NUMBER,
         I_RESOURCE_ID          IN      NUMBER,
         I_USER_ID              IN      NUMBER,
         I_LOGIN_ID             IN      NUMBER,
         I_REQ_ID               IN      NUMBER,
         I_PRGM_ID              IN      NUMBER,
         I_PRGM_APPL_ID         IN      NUMBER,
         O_RETURN_CODE          OUT     NOCOPY NUMBER,
         O_ERR_TEXT             IN OUT  NOCOPY VARCHAR2);


PROCEDURE CSTPPCOI (
         I_ORGANIZATION_ID         IN      NUMBER,
         I_INVENTORY_ITEM_ID       IN      NUMBER,
         I_MATERIAL_COST           IN      NUMBER,
         I_MATERIAL_SUB_ELEM_ID    IN      NUMBER,
         I_MATERIAL_OH_RATE        IN      NUMBER,
         I_MATERIAL_OH_SUB_ELEM_ID IN      NUMBER,
         I_USER_ID                 IN      NUMBER,
         I_LOGIN_ID                IN      NUMBER,
         I_REQ_ID                  IN      NUMBER,
         I_PRGM_ID                 IN      NUMBER,
         I_PRGM_APPL_ID            IN      NUMBER,
         O_RETURN_CODE             OUT     NOCOPY NUMBER,
         O_ERR_TEXT                IN OUT  NOCOPY VARCHAR2);

PROCEDURE CSTPIICP (
         I_USER_ID                 IN      NUMBER := -1,
         I_LOGIN_ID                IN      NUMBER := -1,
         I_REQ_ID                  IN      NUMBER := -1,
         I_PRGM_ID                 IN      NUMBER := -1,
         I_PRGM_APPL_ID            IN      NUMBER := -1,
         O_RETURN_CODE             OUT     NOCOPY NUMBER,
         O_RETURN_ERR              OUT     NOCOPY VARCHAR2,
         xset_id                   IN  NUMBER DEFAULT NULL);


END INVPCOII;

 

/
