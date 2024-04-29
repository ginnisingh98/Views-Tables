--------------------------------------------------------
--  DDL for Package INV_VIEW_MTL_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_VIEW_MTL_TXN" AUTHID CURRENT_USER AS
/*$Header: INVVTXNS.pls 120.0.12010000.2 2009/04/09 09:16:54 skommine ship $*/

/*
** --------------------------------------------------------------------------
** Procedure :Get_Decription
** Decription: This procedure accepts the identifiers and returns the
**             description for the identifiers. The following columns
**             from mtl_material_transactions are passed as input for
**             this procedure
**
**   TRANSACTION_TYPE_ID
**   TRANSACTION_ACTION_ID
**   COSTED_FLAG
**   PM_COST_COLLECTED
**   PM_COST_COLLECTOR_GROUP_ID
**   TRANSACTION_SOURCE_TYPE_ID
**   REASON_ID
**   DEPARTMENT_ID
**   TRANSFER_ORGANIZATION_ID
**   LPN_ID
**   CONTENT_LPN_ID
**   TRANSFER_LPN_ID
**   COST_GROUP_ID
**   TRANSFER_COST_GROUP_ID
**   INV_ADV_INSTALLED
**   PUT_AWAY_STRATEGY_ID
**   PUT_AWAY_RULE_ID
**   PICK_STRATEGY_ID
**   PICK_RULE_ID
**   ORGANIZATION_ID
**   TRANSFER_OWNING_TP_TYPE
**   XFR_OWNING_ORGANIZATION_ID
**
** The following are the output columns for the procedure:
**  X_RETURN_STATUS               :Return Status indicating success,
**                                 error, unexpected error for the procedure
**  X_MSG_DATA                    :if the number of messages in message list
**                                  is 1, contains message text
**  X_MSG_COUNT                   :number of messages in message list
**  X_TRANSACTION_TYPE_NAME       : Description for TRANSACTION_TYPE_ID
**  X_TRANSACTION_ACTION          : Description for TRANSACTION_ACTION_ID
**  X_COSTED_FLAG_1               : Description for COSTED_FLAG
**  X_COSTED_LOOKUP_CODE          : Description for COSTED_LOOKUP_CODE
**  X_PM_COST_COLLECTED_1         : Description for PM_COST_COLLECTED
**  X_PM_COST_COLLECTED_LK_CODE   : Description for COSTED_LOOKUP_CODE
**  X_TRANSACTION_SOURCE_TYPE_NAME: Description for TRANSACTION_SOURCE_TYPE_ID
**  X_TRANSACTION_SOURCE_NAME_DB  : Description for TRANSACTION_SOURCE_TYPE_ID
**  X_REASON_NAME                 : Description for REASON_ID
**  X_DEPARTMENT_CODE             : Description for DEPARTMENT_ID
**  X_TRANSFER_ORGANIZATION_NAME  : Description for TRANSFER_ORGANIZATION_ID
**  X_TRANSFER_LPN                : Description for TRANSFER_LPN_ID
**  X_CONTENT_LPN                 : Description for CONTENT_LPN_ID
**  X_LPN                         : Description for LPN_ID
**  X_COST_GROUP_NAME             : Description for COST_GROUP_ID
**  X_TRANSFER_COST_GROUP_NAME    : Description for TRANSFER_COST_GROUP_ID
**  X_PUT_AWAY_STRATEGY_NAME      : Description for PUT_AWAY_STRATEGY_ID
**  X_PUT_AWAY_RULE_NAME          : Description for PUT_AWAY_RULE_ID
**  X_PICK_STRATEGY_NAME          : Description for PICK_STRATEGY_ID
**  X_PICK_RULE_NAME              : Description for PICK_RULE_ID
**  X_ORGANIZATION_CODE           : Description for ORGANIZATION_ID
**  X_OPERATIN_UNIT               : Operating Unit for the ORGANIZATION_ID
**  X_XFR_OWNING_ORGANIZATION_NAME: Description for XFR_OWNING_ORGANIZATION_ID
*/
PROCEDURE GET_DESCRIPTION(
           X_RETURN_STATUS                  OUT NOCOPY VARCHAR2
          ,X_MSG_DATA                       OUT NOCOPY VARCHAR2
          ,X_MSG_COUNT                      OUT NOCOPY NUMBER
          ,X_TRANSACTION_TYPE_NAME          OUT NOCOPY VARCHAR2
          ,X_TRANSACTION_ACTION             OUT NOCOPY VARCHAR2
          ,X_COSTED_FLAG_1                  OUT NOCOPY VARCHAR2
          ,X_COSTED_LOOKUP_CODE             OUT NOCOPY VARCHAR2
          ,X_PM_COST_COLLECTED_1            OUT NOCOPY VARCHAR2
          ,X_PM_COST_COLLECTED_LK_CODE      OUT NOCOPY VARCHAR2
          ,X_TRANSACTION_SOURCE_TYPE_NAME   OUT NOCOPY VARCHAR2
          ,X_TRANSACTION_SOURCE_NAME_DB     OUT NOCOPY VARCHAR2
          ,X_REASON_NAME                    OUT NOCOPY VARCHAR2
          ,X_DEPARTMENT_CODE                OUT NOCOPY VARCHAR2
          ,X_TRANSFER_ORGANIZATION_NAME     OUT NOCOPY VARCHAR2
          ,X_TRANSFER_LPN                   OUT NOCOPY VARCHAR2
          ,X_CONTENT_LPN                    OUT NOCOPY VARCHAR2
          ,X_LPN                            OUT NOCOPY VARCHAR2
          ,X_COST_GROUP_NAME                OUT NOCOPY VARCHAR2
          ,X_TRANSFER_COST_GROUP_NAME       OUT NOCOPY VARCHAR2
          ,X_put_away_strategy_name         OUT NOCOPY VARCHAR2
          ,X_put_away_rule_name             OUT NOCOPY VARCHAR2
          ,X_PICK_STRATEGY_NAME             OUT NOCOPY VARCHAR2
          ,X_PICK_RULE_NAME                 OUT NOCOPY VARCHAR2
          ,x_owning_organization_name       OUT NOCOPY VARCHAR2
          ,x_supplier                       OUT NOCOPY VARCHAR2
          ,x_supplier_site_name             OUT NOCOPY VARCHAR2
          ,X_ORGANIZATION_CODE              OUT NOCOPY VARCHAR2
          ,X_OPERATING_UNIT                 OUT NOCOPY VARCHAR2
          ,X_XFR_OWNING_ORGANIZATION_NAME   OUT NOCOPY VARCHAR2
          ,p_TRANSACTION_TYPE_ID             IN NUMBER
          ,p_TRANSACTION_ACTION_ID           IN NUMBER
          ,p_COSTED_FLAG                     IN VARCHAR2
          ,p_PM_COST_COLLECTED               IN VARCHAR2
          ,P_PM_COST_COLLECTOR_GROUP_ID      IN VARCHAR2
          ,p_TRANSACTION_SOURCE_TYPE_ID      IN NUMBER
          ,P_REASON_ID                       IN NUMBER
          ,p_DEPARTMENT_ID                   IN NUMBER
          ,p_TRANSFER_ORGANIZATION_ID        IN NUMBER
          ,p_LPN_ID                          IN NUMBER
          ,p_content_lpn_id                  IN NUMBER
          ,p_transfer_lpn_id                 IN NUMBER
          ,p_COST_GROUP_ID                   IN NUMBER
          ,p_TRANSFER_COST_GROUP_ID          IN NUMBER
          ,p_INV_ADV_INSTALLED               IN VARCHAR2
          ,p_put_away_strategy_id            IN NUMBER
          ,p_put_away_rule_id                IN NUMBER
          ,p_pick_strategy_id                IN NUMBER
          ,p_pick_rule_id                    IN NUMBER
          ,p_owning_organization_id          IN NUMBER
          ,p_planning_tp_type                IN NUMBER
          ,p_owning_tp_type                  IN NUMBER
          ,p_planning_organization_id        IN NUMBER
          ,p_organization_id                 IN NUMBER DEFAULT NULL
          ,p_transfer_owning_tp_type         IN NUMBER
          ,p_xfr_owning_organization_id      IN NUMBER
          ) ;
PROCEDURE update_mmt_process_cost
(
   p_organization_id number
   ,p_trans_date_from DATE
   ,p_trans_date_to DATE
   ,p_report VARCHAR2 DEFAULT 'T'
 );
END INV_VIEW_MTL_TXN;

/
