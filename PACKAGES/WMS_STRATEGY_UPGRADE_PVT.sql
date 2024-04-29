--------------------------------------------------------
--  DDL for Package WMS_STRATEGY_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_STRATEGY_UPGRADE_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSSTGUS.pls 115.4 2003/02/21 01:46:50 grao noship $ */
--
-- File        : WMSSTGUS.pls
-- Content     : WMS_Strategy_upgrade_PVT package specification
-- Description : WMS private API's
-- Notes       :
-- Created    : 10/31/02 Grao
--
-- API name    : Upgrade Script for Strategy search order / Strategy Assignments
-- Type        : Private
-- Function    : Convert each strategy assignment record into a record in the new table
--	         WMS_SELECTION_CRITERIA_TXN
--
--
--
--
--
-- Pre-reqs    :  record in WMS_STAGINGLANES_ASSIGNMENTS
--
--
-- Input Parameters  :

--
-- Output Parameter :

procedure copy_stg_assignments
  ( x_return_status      OUT  NOCOPY 	VARCHAR2
   ,x_msg_count            OUT  NOCOPY 	NUMBER
   ,x_msg_data             OUT  NOCOPY 	VARCHAR2
   );

PROCEDURE INSERT_ROW (
  X_STG_ASSIGNMENT_ID                                   IN 	  NUMBER
 ,X_SEQUENCE_NUMBER                                     IN 	  NUMBER
 ,X_RULE_TYPE_CODE                                      IN	  NUMBER
 ,X_RETURN_TYPE_CODE                                    IN	  VARCHAR2
 ,X_RETURN_TYPE_ID                                      IN	  NUMBER
 ,X_ENABLED_FLAG                                        IN         VARCHAR2
 ,X_DATE_TYPE_CODE                                      IN         VARCHAR2
 ,X_DATE_TYPE_FROM                                      IN         NUMBER
 ,X_DATE_TYPE_TO                                        IN         NUMBER
 ,X_DATE_TYPE_LOOKUP_TYPE                               IN         VARCHAR2
 ,X_EFFECTIVE_FROM                                      IN         DATE
 ,X_EFFECTIVE_TO                                        IN         DATE
 ,X_FROM_ORGANIZATION_ID                                IN         NUMBER
 ,X_FROM_SUBINVENTORY_NAME                              IN         VARCHAR2
 ,X_TO_ORGANIZATION_ID                                  IN         NUMBER
 ,X_TO_SUBINVENTORY_NAME                                IN         VARCHAR2
 ,X_CUSTOMER_ID                                         IN         NUMBER
 ,X_FREIGHT_CODE                                        IN         VARCHAR2
 ,X_INVENTORY_ITEM_ID                                   IN         NUMBER
 ,X_ITEM_TYPE                                           IN         VARCHAR2
 ,X_ASSIGNMENT_GROUP_ID                                 IN         NUMBER
 ,X_ABC_CLASS_ID                                        IN         NUMBER
 ,X_CATEGORY_SET_ID                                     IN         NUMBER
 ,X_CATEGORY_ID                                         IN         NUMBER
 ,X_ORDER_TYPE_ID                                       IN         NUMBER
 ,X_VENDOR_ID                                           IN         NUMBER
 ,X_PROJECT_ID                                          IN         NUMBER
 ,X_TASK_ID                                             IN         NUMBER
 ,X_USER_ID                                             IN         NUMBER
 ,X_TRANSACTION_ACTION_ID                               IN         NUMBER
 ,X_REASON_ID                                           IN         NUMBER
 ,X_TRANSACTION_SOURCE_TYPE_ID                          IN         NUMBER
 ,X_TRANSACTION_TYPE_ID                                 IN         NUMBER
 ,X_UOM_CODE                                            IN         VARCHAR2
 ,X_UOM_CLASS                                           IN         VARCHAR2
 ,X_LAST_UPDATED_BY                                     IN 	   NUMBER
 ,X_LAST_UPDATE_DATE                                    IN 	   DATE
 ,X_CREATED_BY                                          IN 	   NUMBER
 ,X_CREATION_DATE                                       IN 	   DATE
 ,X_LAST_UPDATE_LOGIN                                   IN         NUMBER);

end WMS_Strategy_upgrade_PVT ;

 

/
