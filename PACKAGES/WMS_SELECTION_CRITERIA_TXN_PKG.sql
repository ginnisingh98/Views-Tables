--------------------------------------------------------
--  DDL for Package WMS_SELECTION_CRITERIA_TXN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_SELECTION_CRITERIA_TXN_PKG" AUTHID CURRENT_USER AS
 /* $Header: WMSSCTXS.pls 120.1 2005/05/27 01:43:00 appldev  $ */
 --
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
 ,X_LOCATION_ID                                         IN         NUMBER
 ,X_LAST_UPDATED_BY                                     IN 	   NUMBER
 ,X_LAST_UPDATE_DATE                                    IN 	   DATE
 ,X_CREATED_BY                                          IN 	   NUMBER
 ,X_CREATION_DATE                                       IN 	   DATE
 ,X_LAST_UPDATE_LOGIN                                   IN         NUMBER);

 PROCEDURE LOCK_ROW (
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
 ,X_LOCATION_ID                                         IN         NUMBER);

 PROCEDURE UPDATE_ROW (
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
  ,X_LOCATION_ID                                         IN         NUMBER
  ,X_LAST_UPDATED_BY                                     IN 	   NUMBER
  ,X_LAST_UPDATE_DATE                                    IN 	   DATE
  ,X_LAST_UPDATE_LOGIN                                   IN         NUMBER);

 PROCEDURE DELETE_ROW (
   X_STG_ASSIGNMENT_ID IN 	NUMBER
   );


END WMS_SELECTION_CRITERIA_TXN_PKG;

 

/
