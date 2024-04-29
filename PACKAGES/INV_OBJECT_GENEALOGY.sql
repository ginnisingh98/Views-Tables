--------------------------------------------------------
--  DDL for Package INV_OBJECT_GENEALOGY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_OBJECT_GENEALOGY" AUTHID CURRENT_USER AS
  /* $Header: INVOGENS.pls 120.4.12010000.2 2009/04/29 12:59:42 mporecha ship $ */
  FUNCTION getobjecttype(p_object_id IN NUMBER)
    RETURN NUMBER;

  FUNCTION getobjectnumber(
    p_object_id    IN NUMBER
  , p_object_type  IN NUMBER
  , p_object_id2   IN NUMBER DEFAULT NULL
  , p_object_type2 IN NUMBER DEFAULT NULL
  )
    RETURN VARCHAR2;

  PROCEDURE getobjectinfo(
    p_object_id          IN            NUMBER
  , p_object_type        IN            NUMBER
  , p_object_name        OUT NOCOPY    VARCHAR2
  , p_object_description OUT NOCOPY    VARCHAR2
  , p_object_type_name   OUT NOCOPY    VARCHAR2
  , p_expiration_date    OUT NOCOPY    DATE
  , p_primary_uom        OUT NOCOPY    VARCHAR2
  , p_inventory_item_id  OUT NOCOPY    NUMBER
  , p_object_number      OUT NOCOPY    VARCHAR2
  , p_material_status    OUT NOCOPY    VARCHAR2
  , p_unit_number        OUT NOCOPY    VARCHAR2
  );

  /*Serial Tracking in WIP. Create an overloaded procedure getobjectinfo which returns 3
  extra parameters- wip_entity_id, operation_seq_num and intraoperation_step_type */
  /*R12 Lot Serial Genealogy Project : Added new parameter x_current_lot_number */
  PROCEDURE getobjectinfo(
    p_object_id                IN            NUMBER
  , p_object_type              IN            NUMBER
  , p_object_name              OUT NOCOPY    VARCHAR2
  , p_object_description       OUT NOCOPY    VARCHAR2
  , p_object_type_name         OUT NOCOPY    VARCHAR2
  , p_expiration_date          OUT NOCOPY    DATE
  , p_primary_uom              OUT NOCOPY    VARCHAR2
  , p_inventory_item_id        OUT NOCOPY    NUMBER
  , p_object_number            OUT NOCOPY    VARCHAR2
  , p_material_status          OUT NOCOPY    VARCHAR2
  , p_unit_number              OUT NOCOPY    VARCHAR2
  ,   --Serial Tracking in WIP project. Return the wip_entity_id, operation_seq_number and intraoperation_step_type also.
    x_wip_entity_id            OUT NOCOPY    NUMBER
  , x_operation_seq_num        OUT NOCOPY    NUMBER
  , x_intraoperation_step_type OUT NOCOPY    NUMBER
  , x_current_lot_number       OUT NOCOPY    VARCHAR2
  );

  /* Since we don't use it any more so comment out --------

  CURSOR  TXNRECS_CURSOR IS
            SELECT TRANSACTION_ID,
                   TRANSACTION_DATE,
                   TRANSACTION_SOURCE_TYPE_NAME,
                   TRANSACTION_SOURCE_NAME,
                   TRANSACTION_TYPE_NAME,
                   ORGANIZATION_CODE,
                   CUSTOMER_NAME
              FROM MTL_MATERIAL_TRANSACTIONS,
                   MTL_TXN_SOURCE_TYPES,
                   MTL_TRANSACTION_TYPES,
                   MTL_PARAMETERS,
                   RA_CUSTOMERS;

  TYPE TXNRECS IS REF CURSOR RETURN TXNRECS_CURSOR%ROWTYPE;
  */
  FUNCTION getsource(p_org_id IN NUMBER, p_trx_src_type IN NUMBER, p_trx_src_id IN NUMBER)
    RETURN VARCHAR2;

  FUNCTION gettradingpartner(
    p_org_id          IN NUMBER
  , p_trx_src_type    IN NUMBER
  , p_trx_src_id      IN NUMBER
  , p_trx_src_line_id IN NUMBER
  , p_transfer_org_id IN NUMBER
  )
    RETURN VARCHAR2;

  /*
  PROCEDURE getTransactionInfo(p_object_id IN NUMBER,
                               p_object_type IN NUMBER,
                               p_txn_cursor IN OUT TXNRECS);
  */
  -- Added this package as part of Bug 4018721
  PROCEDURE init;

  --
  -- Procedure to populate child tree
  --
  PROCEDURE inv_populate_child_tree(
    p_object_id         IN NUMBER
  , p_related_object_id IN NUMBER
  , p_object_type       IN NUMBER DEFAULT NULL
  , p_object_id2        IN NUMBER DEFAULT NULL
  , p_object_type2      IN NUMBER DEFAULT NULL
  );

  --
  -- Procedure to populate parent tree
  --
  PROCEDURE inv_populate_parent_tree(
    p_object_id         IN NUMBER
  , p_related_object_id IN NUMBER
  , p_object_type       IN NUMBER DEFAULT NULL
  , p_object_id2        IN NUMBER DEFAULT NULL
  , p_object_type2      IN NUMBER DEFAULT NULL
  );

  FUNCTION getjData(
    p_object_id    IN NUMBER
  , p_object_type  IN NUMBER
  , p_object_id2   IN NUMBER DEFAULT NULL
  , p_object_type2 IN NUMBER DEFAULT NULL
  )
    RETURN NUMBER;

  --Bug 8467584
  PROCEDURE set_rowlimit(p_numrows IN NUMBER);


  --
  -- Global variables used
  --
  g_ind    NUMBER := 0;
  g_treeno NUMBER := 1;
  g_depth  NUMBER := 1;
  g_jData NUMBER := -1;
  --Bug 8467584
  g_rowlimit NUMBER := 40000;

-- End Bug 4018721
END inv_object_genealogy;

/
