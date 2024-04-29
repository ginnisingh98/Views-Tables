--------------------------------------------------------
--  DDL for Package GMF_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: gmfmigrs.pls 120.16 2006/10/05 12:50:39 anthiyag noship $ */

  G_Migration_run_id                     NUMBER;
  G_Table_name                           VARCHAR2(30);
  G_Context                              VARCHAR2(255);
  G_Mode                                 VARCHAR2(5) DEFAULT 'ALL';

  G_legal_entity                         VARCHAR2(30) DEFAULT 'LEGAL_ENTITY_ID';
  G_Ledger_id                            VARCHAR2(30) DEFAULT 'LEDGER_ID';
  G_organization                         VARCHAR2(30) DEFAULT 'ORGANIZATION_ID';
  G_subinventory                         VARCHAR2(30) DEFAULT 'SUBINVENTORY_CODE';
  G_inventory_item_id                    VARCHAR2(30) DEFAULT 'INVENTORY_ITEM_ID';
  G_reason_id                            VARCHAR2(30) DEFAULT 'REASON_ID';
  G_currency_code                        VARCHAR2(30) DEFAULT 'CURRENCY_CODE';
  G_price_element_type_id                VARCHAR2(30) DEFAULT 'AQUI_COST_ID';
  G_resources                            VARCHAR2(30) DEFAULT 'RESOURCES';
  G_order_type                           VARCHAR2(30) DEFAULT 'ORDER_TYPE';
  G_cost_cmpntcls_id                     VARCHAR2(30) DEFAULT 'COST_CMPNTCLS_ID';
  G_cost_analysis_code                   VARCHAR2(30) DEFAULT 'COST_ANALYSIS_CODE';
  G_line_type                            VARCHAR2(30) DEFAULT 'LINE_TYPE';
  G_ar_trx_type                          VARCHAR2(30) DEFAULT 'AR_TRX_TYPE_ID';
  G_journal_line_type                    VARCHAR2(30) DEFAULT 'JOURNAL_LINE_TYPE';
  G_gl_business_class_cat_id             VARCHAR2(30) DEFAULT 'BC_CAT_CATEGORY_ID';
  G_gl_product_line_cat_id               VARCHAR2(30) DEFAULT 'PL_CAT_CATEGORY_ID';
  G_gl_category_id                       VARCHAR2(30) DEFAULT 'GL_CAT_CATEGORY_ID';

  G_vendor                               VARCHAR2(30) DEFAULT 'VENDOR_ID';
  G_customer                             VARCHAR2(30) DEFAULT 'CUST_ID';
  G_vendgl_class                         VARCHAR2(30) DEFAULT 'VENDGL_CLASS';
  G_custgl_class                         VARCHAR2(30) DEFAULT 'CUSTGL_CLASS';
  G_routing_id                           VARCHAR2(30) DEFAULT 'ROUTING_ID';

  G_Constant                             VARCHAR2(30) DEFAULT 'C';
  G_And                                  VARCHAR2(30) DEFAULT 'A';
  G_Or                                   VARCHAR2(30) DEFAULT 'O';
  G_Equal                                VARCHAR2(30) DEFAULT 'E';
  G_Application_id                       NUMBER(38) := 555;

  FUNCTION get_account_id
  (
  p_account_code          IN             VARCHAR2,
  p_co_code               IN             VARCHAR2
  )
  RETURN VARCHAR2;

  FUNCTION Get_Co_Code
  (
  p_whse_code             IN             VARCHAR2
  )
  RETURN VARCHAR2;

  FUNCTION Get_Inventory_Item_Id
  (
  p_Item_id               IN             NUMBER
  )
  RETURN NUMBER;

  FUNCTION Get_Legal_entity_Id
  (
  p_co_code               IN             VARCHAR2,
  p_source_type           IN             VARCHAR2
  )
  RETURN NUMBER;

  FUNCTION Get_Legal_entity_Id
  (
  p_organization_id       IN             NUMBER
  )
  RETURN NUMBER;

  FUNCTION Get_Legal_entity_Id
  (
  p_whse_code             IN             VARCHAR2
  )
  RETURN NUMBER;

  FUNCTION Get_Item_Number
  (
  p_inventory_item_id     IN             NUMBER
  )
  RETURN VARCHAR2;

  FUNCTION Get_Customer_no
  (
  p_cust_id     IN             NUMBER
  )
  RETURN VARCHAR2;

  FUNCTION Get_Vendor_no
  (
  p_vendor_id       IN             NUMBER
  )
  RETURN VARCHAR2;

  FUNCTION Get_Reason_id
  (
  p_reason_code        IN          VARCHAR2
  )
  RETURN NUMBER;

  PROCEDURE Get_Routing_no
  (
  p_routing_id         IN                NUMBER,
  x_routing_no            OUT   NOCOPY   VARCHAR2,
  x_routing_vers          OUT   NOCOPY   NUMBER
  );

  FUNCTION Get_price_element_Type_id
  (
  p_aqui_cost_id       IN             NUMBER
  )
  RETURN NUMBER;

  FUNCTION Get_Cost_cmpntcls_code
  (
  p_cost_cmpntcls_id       IN             NUMBER
  )
  RETURN VARCHAR2;

  FUNCTION Get_Order_type_code
  (
  p_Order_type            IN             NUMBER,
  p_source_type           IN             NUMBER
  )
  RETURN VARCHAR2;

  FUNCTION Get_Line_type_code
  (
  p_Line_type            IN             NUMBER
  )
  RETURN VARCHAR2;

  FUNCTION Get_Ar_trx_type_code
  (
  p_ar_trx_type_id        IN             NUMBER,
  p_legal_entity_id       IN             NUMBER
  )
  RETURN VARCHAR2;

  FUNCTION Get_Gl_business_class_cat
  (
  p_Gl_business_class_cat_id       IN             NUMBER
  )
  RETURN VARCHAR2;

  FUNCTION Get_Gl_product_line_cat
  (
  p_Gl_product_line_cat_id         IN             NUMBER
  )
  RETURN VARCHAR2;

  PROCEDURE Migrate_Fiscal_Policies_LE
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  x_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Fiscal_Policies_Others
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Cost_Methods
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Lot_Cost_Methods
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Cost_Calendars
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Burden_Percentages
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Lot_Costs
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Lot_Costed_Items
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Lot_Cost_Adjustments
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Material_Lot_Cost_Txns
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Lot_Cost_Burdens
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Allocation_Basis
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Allocation_Expenses
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Account_Mappings
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Acquisition_Codes
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Period_Balances
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Allocation_Inputs
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Burden_Priorities
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Component_Materials
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Allocation_Codes
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Event_Policies
  (
  P_migration_run_id      IN             NUMBER,
  P_commit                IN             VARCHAR2,
  X_failure_count         OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Cost_Warehouses
  (
  P_migration_run_id       IN             NUMBER,
  P_commit                 IN             VARCHAR2,
  X_failure_count          OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Source_Warehouses
  (
  P_migration_run_id       IN             NUMBER,
  P_commit                 IN             VARCHAR2,
  X_failure_count          OUT   NOCOPY   NUMBER
  );

  PROCEDURE Migrate_Items
  (
  P_migration_run_id      IN              NUMBER,
  P_commit                IN              VARCHAR2,
  X_failure_count         OUT    NOCOPY   NUMBER
  );

  PROCEDURE Migrate_ActualCost_control
  (
  P_migration_run_id      IN              NUMBER,
  P_commit                IN              VARCHAR2,
  X_failure_count         OUT   NOCOPY    NUMBER
  );

  PROCEDURE Migrate_Rollup_control
  (
  P_migration_run_id      IN              NUMBER,
  P_commit                IN              VARCHAR2,
  X_failure_count         OUT   NOCOPY    NUMBER
  );

  PROCEDURE Migrate_CostUpdate_control
  (
  P_migration_run_id      IN              NUMBER,
  P_commit                IN              VARCHAR2,
  X_failure_count         OUT   NOCOPY    NUMBER
  );

  PROCEDURE Migrate_SubLedger_control
  (
  P_migration_run_id      IN              NUMBER,
  P_commit                IN              VARCHAR2,
  X_failure_count         OUT   NOCOPY    NUMBER
  );

  PROCEDURE Log_Errors
  (
  p_log_level             IN             PLS_INTEGER DEFAULT 2,
  p_from_rowid            IN             ROWID,
  p_to_rowid              IN             ROWID
  );

  PROCEDURE Migrate_Vendor_id
  (
  P_migration_run_id      IN              NUMBER,
  P_commit                IN              VARCHAR2,
  X_failure_count         OUT   NOCOPY    NUMBER
  );

END GMF_MIGRATION;

 

/
