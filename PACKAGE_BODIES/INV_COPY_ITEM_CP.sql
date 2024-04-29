--------------------------------------------------------
--  DDL for Package Body INV_COPY_ITEM_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_COPY_ITEM_CP" AS
/* $Header: INVITCPB.pls 120.9.12010000.3 2010/09/02 18:31:55 ccsingh ship $ */
--======================================================================
-- GLOBALS
--======================================================================
TYPE g_request_tbl_type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

G_SLEEP_TIME           NUMBER       := 15;

G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_COPY_ITEM_CP.';

--=============================================
-- GLOBAL VARIABLES
--=============================================

g_debug_level        NUMBER := NULL;
g_proc_level         NUMBER := NULL;
g_unexp_level        NUMBER := NULL;
g_excep_level        NUMBER := NULL;
g_statement_level    NUMBER := NULL;

PROCEDURE Init;

--========================================================================
-- PROCEDURE : Copy_Items
-- TYPE      : PRIVATE
-- PARAMETERS: p_organization_id       IN            an organization
--             p_set_process_id        IN            Set process ID
--             x_workers               IN OUT NOCOPY workers' request ID
--             p_request_count         IN            max worker number
--             p_copy_eng_items        IN            'Y' or 'N' flag for
--                                                   coping engineering items
--             p_copy_base_models      IN            'Y' or 'N' flag for
--                                                   coping base models
-- COMMENT   : This procedure submits the Item Import concurrent program.
--             Before submitting the request, it verifies that there are
--             enough workers available and wait for the completion of one
--             if necessary.
--=========================================================================
PROCEDURE  Copy_Items
(x_return_message       OUT   NOCOPY VARCHAR2
,x_return_status        OUT   NOCOPY VARCHAR2
,p_source_org_id        IN    NUMBER
,p_target_org_id        IN    NUMBER
,p_validate             IN    VARCHAR2
,p_copy_eng_items       IN    VARCHAR2
,p_copy_base_models     IN    VARCHAR2
);

--======================================================================
--START OF PACKAGE BODY.
--======================================================================


--========================================================================
-- FUNCTION  : Has_Worker_Completed    PRIVATE
-- PARAMETERS: p_request_id            IN  NUMBER
-- RETURNS   : BOOLEAN
-- COMMENT   : Accepts a request ID. TRUE if the corresponding worker
--             has completed; FALSE otherwise
--=========================================================================
FUNCTION Has_Worker_Completed
( p_request_id  IN NUMBER
)
RETURN BOOLEAN
IS
  l_count   NUMBER;
  l_result  BOOLEAN;
  l_function_name CONSTANT VARCHAR2(30) := 'Has_Worker_Completed';
BEGIN
  Init;
  IF (g_proc_level >= g_debug_level)
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_function_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;
  SELECT COUNT(*)
  INTO   l_count
  FROM   fnd_concurrent_requests
  WHERE  request_id = p_request_id
  AND    phase_code = 'C';

  IF l_count = 1
  THEN
    l_result := TRUE;
  ELSE
    l_result := FALSE;
  END IF;
  IF (g_proc_level >= g_debug_level)
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_function_name || '.end'
                  ,'exit function.'
                  );
  END IF;
  RETURN l_result;
END Has_Worker_Completed;

--========================================================================
-- PROCEDURE : Wait_For_Worker         PRIVATE
-- PARAMETERS: p_workers               IN  workers' request ID
--             x_worker_idx            OUT position in p_workers of the
--                                         completed worked
-- COMMENT   : This procedure polls the submitted workers and suspend
--             the program till the completion of one of them; it returns
--             the completed worker through x_worker_idx
--=========================================================================
PROCEDURE Wait_For_Worker
( p_workers          IN  g_request_tbl_type
, x_worker_idx       OUT NOCOPY BINARY_INTEGER
)
IS
  l_done BOOLEAN;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Wait_For_Worker';
BEGIN
  Init;
  IF (g_proc_level >= g_debug_level)
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;
  l_done := FALSE;
  WHILE (NOT l_done)
  LOOP

    FOR l_Idx IN 1..p_workers.COUNT

    LOOP
      IF Has_Worker_Completed(p_workers(l_Idx))
      THEN
        l_done := TRUE;
        x_worker_idx := l_Idx;
        EXIT;
      END IF;

    END LOOP;

    IF (NOT l_done)
    THEN
      DBMS_LOCK.sleep(G_SLEEP_TIME);
    END IF;

  END LOOP;
  IF (g_proc_level >= g_debug_level)
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure.'
                  );
  END IF;
END Wait_For_Worker;

--========================================================================
-- PROCEDURE : Wait_For_All_Workers    PRIVATE
-- PARAMETERS: p_workers               IN workers' request ID
-- COMMENT   : This procedure polls the submitted workers and suspend
--             the program till the completion of all of them.
--=========================================================================
PROCEDURE Wait_For_All_Workers
( p_workers IN g_request_tbl_type)
IS
  l_done BOOLEAN;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Wait_For_All_Workers';
BEGIN
  Init;
  IF (g_proc_level >= g_debug_level)
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  l_done := FALSE;
  WHILE (NOT l_done)
  LOOP
    l_done := TRUE;

    FOR l_Idx IN 1..p_workers.COUNT
    LOOP
      IF NOT Has_Worker_Completed(p_workers(l_Idx))
      THEN
        l_done := FALSE;
        EXIT;
      END IF;
    END LOOP;

    IF (NOT l_done)
    THEN
      DBMS_LOCK.sleep(G_SLEEP_TIME);
    END IF;
  END LOOP;
  IF (g_proc_level >= g_debug_level)
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure.'
                  );
  END IF;
END Wait_For_All_Workers;

--========================================================================
-- PROCEDURE : Submit_Item_Import      PRIVATE
-- PARAMETERS: p_organization_id       IN            an organization
--             p_set_process_id        IN            Set process ID
--             x_workers               IN OUT NOCOPY workers' request ID
--             p_request_count         IN            max worker number
-- COMMENT   : This procedure submits the Item Import concurrent program.
--             Before submitting the request, it verifies that there are
--             enough workers available and wait for the completion of one
--             if necessary.
--             The list of workers' request ID is updated.
--=========================================================================
PROCEDURE Submit_Item_Import
( p_organization_id  IN            NUMBER
--myerrams, Bug: 5964347. Added source org id parameter to Submit_Item_Import Procedure.
--This parameter will be passed as an additional parameter to INCOIN
--in order to avoid the call to INVPUTLI.assign_master_defaults in INCOIN.
, p_source_org_id    IN		   NUMBER
, p_set_process_id   IN            NUMBER
, p_validate_items   IN            VARCHAR2
, x_workers          IN OUT NOCOPY g_request_tbl_type
, x_return_status    OUT NOCOPY    VARCHAR2
, x_return_message   OUT NOCOPY    VARCHAR2
, p_request_count    IN            NUMBER
)
IS
  l_worker_idx     BINARY_INTEGER;
  l_request_id     NUMBER;

  l_procedure_name CONSTANT VARCHAR2(30) := 'Submit_Item_Import';
  l_submit_failure_exc   EXCEPTION;
BEGIN
  Init;
  IF (g_proc_level >= g_debug_level)
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  IF x_workers.COUNT < p_request_count
  THEN
   -- number of workers submitted so far does not exceed the maximum
   -- number of workers allowed
     l_worker_idx := x_workers.COUNT + 1;
  ELSE
   -- need to wait for a submitted worker to finish
    Wait_For_Worker
    ( p_workers    => x_workers
    , x_worker_idx => l_worker_idx
    );
  END IF;
  IF NOT FND_REQUEST.Set_Options
         ( implicit  => 'WARNING'
         , protected => 'YES'
         )
  THEN
    RAISE l_submit_failure_exc;
  END IF;

  IF (g_statement_level >= g_debug_level)
  THEN
    FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'Before Calling INCOIN '
                  );
  END IF;
  commit;

  x_workers(l_worker_idx):= FND_REQUEST.Submit_Request
                            ( application => 'INV'
                            , program     => 'INCOIN'
                            , argument1   => p_organization_id
                            , argument2   => 1
                            , argument3   => p_validate_items
                            , argument4   => 1
                            , argument5   => 1
                            , argument6   => p_set_process_id
                            , argument7   => 1
			    , argument8   => p_source_org_id	--myerrams, Bug: 5964347
                            );

  IF (g_statement_level >= g_debug_level)
  THEN
    FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'After Calling INCOIN '
                  );
  END IF;

  IF x_workers(l_worker_idx) = 0
  THEN
    IF (g_excep_level >= g_debug_level)
    THEN
      FND_LOG.string(g_excep_level
                    , G_MODULE_NAME || l_procedure_name
                    ,'Item Open Interface Program (INCOIN) failed '
                    );
    END IF;
    RAISE l_submit_failure_exc;
  END IF;
  COMMIT;

  x_return_status  :=  FND_API.G_RET_STS_SUCCESS;
  x_return_message :=  'Submitted Item Copy request successfully';

  IF (g_proc_level >= g_debug_level)
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure.'
                  );
  END IF;

  EXCEPTION
    WHEN l_submit_failure_exc THEN
      FND_MESSAGE.Set_Name('INV', 'INV_UNABLE_TO_SUBMIT_CONC');
      x_return_message := SUBSTR(FND_MESSAGE.Get, 1, 255);
      x_return_status := FND_API.G_RET_STS_ERROR;
END Submit_Item_Import;

--========================================================================
-- PROCEDURE : Copy_Org_Items
-- PARAMETERS: p_organization_id       IN            an organization
--             p_set_process_id        IN            Set process ID
--             x_workers               IN OUT NOCOPY workers' request ID
--             p_request_count         IN            max worker number
-- COMMENT   : It calls Copy_Items in four steps to copy items:
--                1. Copy Base Models of engineering items
--                2. Copy children of Base Models engineering items
--                3. Copy Base Models of non-engineering items
--                4. Copy children of Base Models non-engineering items
--             Copy_Items further submits the Item Import concurrent program
--             after populating interface table for IOI.
--=========================================================================

PROCEDURE  Copy_Org_Items
(x_return_message       OUT   NOCOPY VARCHAR2
,x_return_status        OUT   NOCOPY VARCHAR2
,p_source_org_id        IN    NUMBER
,p_target_org_id        IN    NUMBER
,p_validate             IN    VARCHAR2
)
IS
l_procedure_name CONSTANT VARCHAR2(30) := 'Copy_Org_Items';
BEGIN
 Init;

 IF (g_proc_level >= g_debug_level)
 THEN
   FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
 END IF;

 IF (g_statement_level >= g_debug_level)
 THEN
    FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'Parameters : '
                  );
    FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'p_source_org_id : '||p_source_org_id
                  );
    FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'p_target_org_id : '||p_target_org_id
                  );
    FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'p_validate : '||p_validate
                  );
 END IF;

 -- Copy Base Models of engineering items.
 Copy_Items (x_return_message
            ,x_return_status
            ,p_source_org_id
            ,p_target_org_id
            ,p_validate
            ,'Y'
            ,'Y'
            );

 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
  RETURN;
 END IF;
 IF (g_statement_level >= g_debug_level)
 THEN
  FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'Engineering Items copied where BaseItemId is NULL'
                  );
 END IF;
 -- Copy children of Base Models engineering items.
 Copy_Items (x_return_message
            ,x_return_status
            ,p_source_org_id
            ,p_target_org_id
            ,p_validate
            ,'Y'
            ,'N'
            );
 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
  RETURN;
 END IF;
 IF (g_statement_level >= g_debug_level)
 THEN
  FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'Engineering Items copied where BaseItemId is not NULL'
                  );
 END IF;
 -- Copy Base Models of non-engineering items.
 Copy_Items (x_return_message
            ,x_return_status
            ,p_source_org_id
            ,p_target_org_id
            ,p_validate
            ,'N'
            ,'Y'
            );
 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
  RETURN;
 END IF;
 IF (g_statement_level >= g_debug_level)
 THEN
  FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'Non Engineering Items copied where BaseItemId is NULL'
                  );
 END IF;
 -- Copy children of Base Models non-engineering items.
 Copy_Items (x_return_message
            ,x_return_status
            ,p_source_org_id
            ,p_target_org_id
            ,p_validate
            ,'N'
            ,'N'
            );
 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
  RETURN;
 END IF;
 IF (g_statement_level >= g_debug_level)
 THEN
  FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'Non Engineering Items copied where BaseItemId is not NULL'
                  );
 END IF;

 IF (g_proc_level >= g_debug_level)
 THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure.'
                  );
 END IF;

END Copy_Org_Items;


/* Private Helper Functions/Procedures */

--=============================================================================
-- PROCEDURE NAME: Init
-- TYPE          : PRIVATE
-- PARAMETERS    : None
-- DESCRIPTION   : Initializes Global Variables.
-- EXCEPTIONS    : None
--=============================================================================

PROCEDURE Init
IS
BEGIN

  -- initializes the global variables for FND Log

  IF g_proc_level IS NULL
    THEN
    g_proc_level := FND_LOG.LEVEL_PROCEDURE;
  END IF; /* IF g_proc_level IS NULL */

  IF g_unexp_level IS NULL
    THEN
    g_unexp_level := FND_LOG.LEVEL_UNEXPECTED;
  END IF; /* IF g_unexp_level IS NULL */

  IF g_excep_level IS NULL
    THEN
    g_excep_level := FND_LOG.LEVEL_EXCEPTION;
  END IF; /* IF g_excep_level IS NULL */

  IF g_statement_level IS NULL
    THEN
    g_statement_level := FND_LOG.LEVEL_STATEMENT;
  END IF; /* IF g_statement_level IS NULL */

  g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


END Init;

--========================================================================
-- PROCEDURE : Copy_Items
-- TYPE      : PRIVATE
-- PARAMETERS: p_organization_id       IN            an organization
--             p_set_process_id        IN            Set process ID
--             x_workers               IN OUT NOCOPY workers' request ID
--             p_request_count         IN            max worker number
--             p_copy_eng_items        IN            'Y' or 'N' flag for
--                                                   coping engineering items
--             p_copy_base_models      IN            'Y' or 'N' flag for
--                                                   coping base models
-- COMMENT   : This procedure submits the Item Import concurrent program.
--             Before submitting the request, it verifies that there are
--             enough workers available and wait for the completion of one
--             if necessary.
--             The list of workers' request ID is updated.
--=========================================================================

PROCEDURE  Copy_Items
(x_return_message       OUT   NOCOPY VARCHAR2
,x_return_status        OUT   NOCOPY VARCHAR2
,p_source_org_id        IN    NUMBER
,p_target_org_id        IN    NUMBER
,p_validate             IN    VARCHAR2
,p_copy_eng_items       IN    VARCHAR2
,p_copy_base_models     IN    VARCHAR2
)
IS
  l_procedure_name CONSTANT VARCHAR2(30) := 'Copy_Items';
  l_max_batch_size         NUMBER;
  l_workers_tbl            g_request_tbl_type;
  l_min_index              BINARY_INTEGER;
  l_max_index              BINARY_INTEGER;
  l_count                  NUMBER;
  l_request_count          NUMBER;
  l_return_code            INTEGER;
  l_counter                NUMBER := 1;
  l_validate_items         NUMBER;
  l_rowid                  ROWID;
  l_set_process_id         mtl_system_items_interface.set_process_id%TYPE;
  l_organization_id        mtl_parameters.organization_id%TYPE;
  l_expense_Account        mtl_parameters.expense_Account%TYPE;
  l_sales_account          mtl_parameters.sales_account%TYPE;
  l_cost_of_sales_account  mtl_parameters.cost_of_sales_account%TYPE;
  l_encumbrance_account    mtl_parameters.encumbrance_account%TYPE;
  l_process_flag	   mtl_item_revisions_interface.process_flag%TYPE;   --myerrams, Bug: 4892069

  -- Define a record type to contain required details from mtl_system_items_b.
  TYPE mtl_system_items_rec IS RECORD
      ( inventory_item_id            mtl_system_items_b.inventory_item_id%Type
      , purchasing_enabled_flag      mtl_system_items_b.purchasing_enabled_flag%Type
      , customer_order_enabled_flag  mtl_system_items_b.customer_order_enabled_flag%Type
      , internal_order_enabled_flag  mtl_system_items_b.internal_order_enabled_flag%Type
      , mtl_transactions_enabled_flag   mtl_system_items_b.mtl_transactions_enabled_flag%Type
      , stock_enabled_flag     mtl_system_items_b.stock_enabled_flag%Type
      , bom_enabled_flag       mtl_system_items_b.bom_enabled_flag%Type
      , build_in_wip_flag      mtl_system_items_b.build_in_wip_flag%Type
      , invoice_enabled_flag   mtl_system_items_b.invoice_enabled_flag%Type
      , source_organization_id mtl_system_items_b.source_organization_id%Type	--myerrams, Bug: 5964347
      , source_subinventory    mtl_system_items_b.source_subinventory%Type	--myerrams, Bug: 5964347
      );

  -- Define a table of above record type
  TYPE mtl_system_items_tbl IS TABLE OF mtl_system_items_rec
     INDEX BY BINARY_INTEGER;
  l_mtl_system_items_tbl          mtl_system_items_tbl;


  -- Cursor to retrieve all the inventory items from the mtl_system_items_b
  -- for the source organization id.
  CURSOR c_item_cursor
  IS
  SELECT   inventory_item_id
         , purchasing_enabled_flag
         , customer_order_enabled_flag
         , internal_order_enabled_flag
         , mtl_transactions_enabled_flag
         , stock_enabled_flag
         , bom_enabled_flag
         , build_in_wip_flag
         , invoice_enabled_flag
	 , source_organization_id --myerrams, Bug: 5964347
	 , source_subinventory --myerrams, Bug: 5964347
  FROM  mtl_system_items_b
  WHERE organization_id = p_source_org_id
  AND ((base_item_id is null and p_copy_base_models = 'Y') or (base_item_id is not null and p_copy_base_models = 'N'))
  AND eng_item_flag = p_copy_eng_items;

/* myerrams,
Following Query is added to update mtl_item_revisions_interface table with Revision Id when ValidateItems is No.
Bug: 4892069
*/
--myerrams, Bug: 5624219.
  CURSOR  c_item_rev_update_cursor(c_set_process_id_in NUMBER)
  IS
  SELECT   organization_id
	 , inventory_item_id
	 , revision
  FROM mtl_item_revisions_interface
  WHERE set_process_id = c_set_process_id_in;

  l_org_id	NUMBER;
  l_inv_item_id	NUMBER;
  l_revision_id	NUMBER;
  l_revision	VARCHAR2(3);
/* myerrams, end */
-- serial_tagging enh -- bug 9913552
   x_ret_sts VARCHAR2(1);

BEGIN
  Init;
  IF (g_proc_level >= g_debug_level)
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status  :=  FND_API.G_RET_STS_SUCCESS;

  -- Find number of items from source organizations based on input
  -- parameters p_copy_base_models and p_copy_eng_items
  SELECT COUNT(*)
  INTO   l_count
  FROM   mtl_system_items_b
  WHERE  organization_id = p_source_org_id
  AND ((base_item_id is null and p_copy_base_models = 'Y') or (base_item_id is not null and p_copy_base_models = 'N'))
  AND eng_item_flag = p_copy_eng_items;

  IF (g_statement_level >= g_debug_level)
  THEN
    FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'p_copy_eng_items : '||p_copy_eng_items
                  );
    FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'p_copy_base_models : '||p_copy_base_models
                  );
    FND_LOG.string(g_statement_level
                  , G_MODULE_NAME || l_procedure_name
                  ,'No of items in the Model Org : '||l_count
                  );
  END IF;

  -- Process only if item count in source organization is more than 0
  IF l_count > 0
  THEN
    IF p_validate = 'Y'
    THEN
     l_validate_items := 1;
     l_process_flag := 1;	--myerrams, Bug: 4892069
    ELSE
     l_validate_items := 2;
     l_process_flag := 4;	--myerrams, Bug: 4892069
    END IF;

    -- get the max batch size from the profile option;
    -- default it to 1000 if the profile option is not defined.
    l_max_batch_size := NVL( TO_NUMBER( FND_PROFILE.Value('INV_CCEOI_COMMIT_POINT'))
                         ,1000
                         );
    -- get the max no. of workers for IOI from the profile option;
    -- default it to 10 if the profile option is not defined.
    -- myerrams, Modified the IOI workers Profile option from INV_IOI_WORKERS to INV_CCEOI_WORKERS.
    l_request_count := NVL( TO_NUMBER( FND_PROFILE.Value('INV_CCEOI_WORKERS'))
                         ,10
                         );

    l_min_index := 1;
    IF l_count > l_max_batch_size
    THEN
      l_max_index := l_max_batch_size;
    ELSE
      l_max_index := l_count;
    END IF;

    -- Retrieve account details from target organization
    SELECT organization_id
         , cost_of_sales_account
         , encumbrance_account
         , sales_account
         , expense_account
    INTO   l_organization_id
         , l_cost_of_sales_account
	 , l_encumbrance_account
         , l_sales_account
         , l_expense_Account
    FROM   mtl_parameters
    WHERE organization_id = p_target_org_id;

    IF (g_statement_level >= g_debug_level)
    THEN
      FND_LOG.string(g_statement_level
                    , G_MODULE_NAME || l_procedure_name
                    ,'Value of various accounts are : '||l_expense_Account
		     ||' '||l_sales_account||' '||l_cost_of_sales_account
		     ||' '||l_encumbrance_account
                    );
    END IF;

--myerrams, Bug: 5509589.
      OPEN c_item_cursor;
	LOOP
	  FETCH c_item_cursor BULK COLLECT INTO l_mtl_system_items_tbl LIMIT l_max_batch_size;
	  l_counter := 1; --myerrams, Bug 5509589. Reset the l_mtl_system_items_tbl counter.

      IF (g_statement_level >= g_debug_level)
      THEN
        FND_LOG.string(g_statement_level
                     , G_MODULE_NAME || l_procedure_name
                     ,'Inside First Loop'
                     );
      END IF;

      -- Get next sequece value for SetProcessId
      SELECT  mtl_system_items_intf_sets_s.NEXTVAL
      INTO  l_set_process_id
      FROM  dual;

      IF(g_statement_level >= g_debug_level)
      THEN
        FND_LOG.string(g_statement_level
                     , G_MODULE_NAME || l_procedure_name
                     ,'The process_id is : '||l_set_process_id
                     );
      END IF;

      -- Bulk collect item related required information from source organization

      FOR l_Idx IN l_min_index..l_max_index
      LOOP

        -- ===========================================================
        -- Insert into Items interface table
        -- ===========================================================
        INSERT INTO mtl_system_items_interface
        ( process_flag
        , set_process_id
        , transaction_type
        , inventory_item_id
        , organization_id
        , cost_of_sales_account
        , encumbrance_account
        , sales_account
        , expense_account
        , last_update_date
        , last_updated_by
        , creation_date
        , created_by
        , last_update_login
        , request_id
        , program_application_id
        , program_id
        , program_update_date
        , purchasing_enabled_flag
        , CUSTOMER_ORDER_ENABLED_FLAG
        , INTERNAL_ORDER_ENABLED_FLAG
        , MTL_TRANSACTIONS_ENABLED_FLAG
        , STOCK_ENABLED_FLAG
        , BOM_ENABLED_FLAG
        , BUILD_IN_WIP_FLAG
        , invoice_enabled_flag
	, source_organization_id	--myerrams, Bug: 5964347
	, source_subinventory		--myerrams, Bug: 5964347
        )
        VALUES
        ( l_process_flag		--myerrams, Bug: 4892069
        , l_set_process_id
        , 'CREATE'
        , l_mtl_system_items_tbl(l_counter).inventory_item_id
        , p_target_org_id
        , l_cost_of_sales_account
        , l_encumbrance_account
        , l_sales_account
        , l_expense_account
        , SYSDATE
        , FND_GLOBAL.user_id
        , SYSDATE
        , FND_GLOBAL.user_id
        , FND_GLOBAL.login_id
        , FND_GLOBAL.conc_request_id
        , FND_GLOBAL.prog_appl_id
        , FND_GLOBAL.conc_program_id
        , SYSDATE
	  , l_mtl_system_items_tbl(l_counter).purchasing_enabled_flag
        , l_mtl_system_items_tbl(l_counter).customer_order_enabled_flag
        , l_mtl_system_items_tbl(l_counter).internal_order_enabled_flag
        , l_mtl_system_items_tbl(l_counter).mtl_transactions_enabled_flag
        , l_mtl_system_items_tbl(l_counter).stock_enabled_flag
        , l_mtl_system_items_tbl(l_counter).bom_enabled_flag
        , l_mtl_system_items_tbl(l_counter).build_in_wip_flag
        , l_mtl_system_items_tbl(l_counter).invoice_enabled_flag
	, l_mtl_system_items_tbl(l_counter).source_organization_id	--myerrams, Bug: 5964347
	, l_mtl_system_items_tbl(l_counter).source_subinventory		--myerrams, Bug: 5964347
        );


        -- Get rowid from items interface table
        SELECT rowid
         INTO l_rowid
         FROM   mtl_system_items_interface
         WHERE  set_process_id     = l_set_process_id
         AND  inventory_item_id  = l_mtl_system_items_tbl(l_counter).inventory_item_id
         AND  organization_id    = p_target_org_id;

        -- Assign Master Defaults
        l_return_code := INVPUTLI.Assign_master_defaults
                             (Tran_id         => NULL
                             ,Item_id         => l_mtl_system_items_tbl(l_counter).inventory_item_id
                             ,Org_id          => p_target_org_id
                             ,Master_org_id   => p_source_org_id
                             ,Status_default  => NULL
                             ,Uom_default     => NULL
                             ,Allow_item_desc_flag => NULL
                             ,Req_required_flag    => NULL
                             ,p_rowid              => l_rowid
                             ,Err_text             => x_return_message
                             );


      -- error while assigning master defaults
      IF l_return_code <> 0 THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
      END IF;

      -- Serial Tagging Enh -- bug 9913552
      IF INV_SERIAL_NUMBER_PUB.is_serial_tagged(p_inventory_item_id => l_mtl_system_items_tbl(l_counter).inventory_item_id,
                                                p_organization_id => p_source_org_id)=2 THEN

               INV_SERIAL_NUMBER_PUB.copy_serial_tag_assignments(
	                                                 p_from_item_id =>l_mtl_system_items_tbl(l_counter).inventory_item_id,
	                                                 p_from_org_id =>p_source_org_id,
	                                                 p_to_item_id =>l_mtl_system_items_tbl(l_counter).inventory_item_id ,
	                                                 p_to_org_id =>p_target_org_id,
	                                                 x_return_status => x_ret_sts);



               IF x_ret_sts <>FND_API.G_RET_STS_SUCCESS THEN
                  x_return_status:= FND_API.G_RET_STS_ERROR;
		  return;
	       END IF;
      END IF;
      -- Assign Status attributes
      l_return_code := INVPULI4.assign_status_attributes
                             (item_id         => l_mtl_system_items_tbl(l_counter).inventory_item_id
                             ,org_id          => p_target_org_id
                             ,Err_text        => x_return_message
                             ,p_rowid         => l_rowid
                             );

      -- error while assigning status attributes
      IF l_return_code <> 0 THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
      END IF;
      l_counter := l_counter + 1;

      END LOOP; -- end loop for that range of index

      -- ===========================================================
      -- Set value of product_family_item_id as NULL
      -- ===========================================================
      UPDATE mtl_system_items_interface set
        product_family_item_id = NULL
      WHERE set_process_id = l_set_process_id;


      -- ===========================================================
      -- Insert into Revisions interface table
      -- ===========================================================
      INSERT INTO mtl_item_revisions_interface
      ( inventory_item_id
      , organization_id
      , revision
      , revision_label			--myerrams, Bug: 4892069
      , implementation_date
      , effectivity_date
      , process_flag			--myerrams, Bug: 4892069
      , transaction_type
      , set_process_id
      , last_update_date
      , last_updated_by
      , creation_date
      , created_by
      , last_update_login
      , request_id
      , program_application_id
      , program_id
      , program_update_date
      )
      SELECT  msi.inventory_item_id
           ,p_target_org_id
	     ,mir.REVISION
	     ,mir.revision_label	--myerrams, Bug: 4892069
	     ,mir.implementation_date
	     ,mir.effectivity_date
	     ,l_process_flag		--myerrams, Bug: 4892069
	     ,'CREATE'
	     ,l_set_process_id
	     ,SYSDATE
	     ,FND_GLOBAL.user_id
	     ,SYSDATE
	     ,FND_GLOBAL.user_id
	     ,FND_GLOBAL.login_id
	     ,FND_GLOBAL.conc_request_id
	     ,FND_GLOBAL.prog_appl_id
	     ,FND_GLOBAL.conc_program_id
	     ,SYSDATE
      FROM  mtl_item_revisions_b mir
           ,mtl_system_items_interface msi
      WHERE mir.inventory_item_id = msi.inventory_item_id
        and mir.organization_id = p_source_org_id
        and msi.organization_id = p_target_org_id
        and msi.set_process_id = l_set_process_id
     ORDER BY mir.REVISION,effectivity_date ;

/*myerrams,
Following code is to update mtl_item_revisions_interface table with Revision Id, which is generated using
the sequence 'MTL_ITEM_REVISIONS_B_S';
Bug: 4892069
*/
    IF p_validate = 'N'
    THEN
      IF(g_statement_level >= g_debug_level)
      THEN
        FND_LOG.string(g_statement_level
                     , G_MODULE_NAME || l_procedure_name
                     ,'The Set Process Id that is used to execute the c_item_rev_update_cursor is: '|| l_set_process_id
                     );
      END IF;
--myerrams, Bug: 5624219. Modified the cursor to use Cursor Parameter l_set_process_id
      OPEN c_item_rev_update_cursor(l_set_process_id);
      LOOP
      FETCH c_item_rev_update_cursor into l_org_id, l_inv_item_id, l_revision;
      EXIT WHEN c_item_rev_update_cursor%NOTFOUND;

      --Get the new Revision Id from Sequence.
      SELECT MTL_ITEM_REVISIONS_B_S.NEXTVAL into l_revision_id from dual;

      --Update Inferface table with mandatroy Revision Id Attribute.
      UPDATE mtl_item_revisions_interface
      SET revision_id = l_revision_id
      WHERE ORGANIZATION_ID = l_org_id
      AND   INVENTORY_ITEM_ID = l_inv_item_id
      AND   REVISION = l_revision;
      END LOOP;
      CLOSE c_item_rev_update_cursor;
    END IF;
/*myerrams,  end */
      -- ===========================================================
      -- Insert into Categories interface table
      -- ===========================================================


      INSERT INTO mtl_item_categories_interface
      ( inventory_item_id
      , organization_id
      , CATEGORY_SET_ID
      , CATEGORY_ID
      , process_flag
      , transaction_type
      , set_process_id
      , last_update_date
      , last_updated_by
      , creation_date
      , created_by
      , last_update_login
      , request_id
      , program_application_id
      , program_id
      , program_update_date
      )
      SELECT msi.inventory_item_id
          ,p_target_org_id
	    ,mic.CATEGORY_SET_ID
	    ,mic.CATEGORY_ID
--	    ,l_process_flag			--myerrams, Bug: 4892069
	    ,1					--myerrams, Bug: 5624219; ProcessFlag for Item Categories has to be 1 irrespective of validate items option.
          ,'CREATE'
	    ,l_set_process_id
	    ,SYSDATE
	    ,FND_GLOBAL.user_id
	    ,SYSDATE
	    ,FND_GLOBAL.user_id
          ,FND_GLOBAL.login_id
          ,FND_GLOBAL.conc_request_id
          ,FND_GLOBAL.prog_appl_id
          ,FND_GLOBAL.conc_program_id
          ,SYSDATE
      FROM   mtl_category_sets_b mcs
            ,mtl_system_items_interface msi
	      ,mtl_item_categories mic
      WHERE msi.inventory_item_id = mic.inventory_item_id
      AND msi.organization_id = p_target_org_id
      AND mic.organization_id = p_source_org_id
      AND msi.set_process_id = l_set_process_id
      AND mcs.category_set_id = mic.category_set_id
      AND mcs.control_level = 2
	AND mcs.category_set_id NOT IN
	    ( SELECT  mdc.category_set_id
              FROM    mtl_default_category_sets  mdc
              WHERE   mdc.functional_area_id = DECODE( msi.INVENTORY_ITEM_FLAG, 'Y', 1, 0 )
                   OR mdc.functional_area_id = DECODE( msi.PURCHASING_ITEM_FLAG, 'Y', 2, 0 )
         	   OR mdc.functional_area_id = DECODE( msi.INTERNAL_ORDER_FLAG, 'Y', 2, 0 )
                   OR mdc.functional_area_id = DECODE( msi.MRP_PLANNING_CODE, 6, 0, 3 )
                   OR mdc.functional_area_id = DECODE( msi.SERVICEABLE_PRODUCT_FLAG, 'Y', 4, 0 )
                   OR mdc.functional_area_id = DECODE( msi.COSTING_ENABLED_FLAG, 'Y', 5, 0 )
                   OR mdc.functional_area_id = DECODE( msi.ENG_ITEM_FLAG, 'Y', 6, 0 )
                   OR mdc.functional_area_id = DECODE( msi.CUSTOMER_ORDER_FLAG, 'Y', 7, 0 )
                   OR mdc.functional_area_id = DECODE( NVL(msi.EAM_ITEM_TYPE, 0), 0, 0, 9 )
                   OR mdc.functional_area_id =
                   DECODE( msi.CONTRACT_ITEM_TYPE_CODE,
                         'SERVICE'      , 10,
                         'WARRANTY'     , 10,
                         'SUBSCRIPTION' , 10,
                         'USAGE'        , 10, 0 )
           -- These Contract Item types also imply an item belonging to the Service functional area
                   OR mdc.functional_area_id =
                   DECODE( msi.CONTRACT_ITEM_TYPE_CODE,
                         'SERVICE'      , 4,
                         'WARRANTY'     , 4, 0 )
                   OR mdc.functional_area_id = DECODE( msi.INTERNAL_ORDER_FLAG, 'Y', 11, 0 )
                   OR mdc.functional_area_id = DECODE( msi.CUSTOMER_ORDER_FLAG, 'Y', 11, 0 )
      );

      -- Submit concurrent request for INCOIN
      Submit_Item_Import
      ( p_organization_id => p_target_org_id
      , p_source_org_id   => p_source_org_id	--myerrams, Bug: 5964347
      , p_set_process_id  => l_set_process_id
      , p_validate_items  => l_validate_items
      , x_workers         => l_workers_tbl
      , x_return_status   => x_return_status
      , x_return_message  => x_return_message
      , p_request_count   => l_request_count
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RETURN;
      END IF;

      l_min_index := l_max_index + 1;
      IF l_count > (l_max_index + l_max_batch_size)
      THEN
        l_max_index := l_max_index + l_max_batch_size;
      ELSE
        l_max_index := l_count;
      END IF;

      -- Exit when all items are processed
      -- myerrams, Bug: 5509589. Exit condition for Bulk Collect and close c_item_cursor.
        EXIT WHEN c_item_cursor%NOTFOUND;
        END LOOP;
      CLOSE c_item_cursor;

    -- Wait for completion of all workers
    Wait_For_All_Workers(p_workers  => l_workers_tbl);

    x_return_message := 'Submitted Item Copy request successfully';

  END IF; -- End of IF for l_count > 0
  IF (g_proc_level >= g_debug_level)
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_message := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
      x_return_message := x_return_message || FND_GLOBAL.NewLine || SQLCODE || '  :  ' || SQLERRM;

      IF(g_statement_level >= g_debug_level)
      THEN
        FND_LOG.string(g_statement_level
                     , G_MODULE_NAME || l_procedure_name
                     ,'x_return_message: '||  x_return_message
                     );
      END IF;

END Copy_Items;

END INV_COPY_ITEM_CP;

/
