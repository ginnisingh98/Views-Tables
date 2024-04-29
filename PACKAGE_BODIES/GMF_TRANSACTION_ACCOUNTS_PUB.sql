--------------------------------------------------------
--  DDL for Package Body GMF_TRANSACTION_ACCOUNTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_TRANSACTION_ACCOUNTS_PUB" AS
/* $Header: GMFXTABB.pls 120.3 2005/10/13 11:43:14 umoogala noship $ */

  --===================================================================
  --
  -- global variables
  --
  --===================================================================

  G_PACKAGE_NAME                 VARCHAR2(50) := 'GMF_transaction_accounts_PUB';

  G_CURRENT_RUNTIME_LEVEL     NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR      CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION  CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT      CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE  CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT  CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME      CONSTANT VARCHAR2(50) :='GMF.PLSQL.GMF_transaction_accounts_PUB.';

  g_log_msg          FND_LOG_MESSAGES.message_text%TYPE;

  --===================================================================
  --
  -- Private procedures
  --
  --===================================================================

  Procedure get_accounts_po
    (
      x_return_status                     OUT NOCOPY    VARCHAR2
    , x_msg_data                          OUT NOCOPY    VARCHAR2
    , x_msg_count                         OUT NOCOPY    NUMBER
    );

  Procedure get_accounts_cto
    (
      x_return_status                     OUT NOCOPY    VARCHAR2
    , x_msg_data                          OUT NOCOPY    VARCHAR2
    , x_msg_count                         OUT NOCOPY    NUMBER
    );

  --===================================================================
  --
  -- Start of comments
  -- API name        : get_accounts
  -- Type            : Public
  -- Pre-reqs        : load g_gmf_accts_tab_PROD plsql table
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- PURPOSE         : To get accounts for the calling application
  --                   using SLA TAB functionality
  -- Parameters      :
  --
  -- End of comments
  --===================================================================

  Procedure get_accounts
    ( p_api_version                       IN            NUMBER
    , p_init_msg_list                     IN            VARCHAR2
    , p_source                            IN            VARCHAR2

    , x_return_status                     OUT NOCOPY    VARCHAR2
    , x_msg_data                          OUT NOCOPY    VARCHAR2
    , x_msg_count                         OUT NOCOPY    NUMBER
    )
  IS

    l_api_name               VARCHAR2(80);
    l_return_status          VARCHAR2(1);

    l_account_type_code      VARCHAR2(80);
    l_legal_entity_id        NUMBER;
    l_ledger_id              NUMBER;
    l_coa_id                 NUMBER;

  BEGIN

    l_api_name      := 'get_accounts';
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    g_log_msg := 'Begin of procedure '|| l_api_name;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_api_name,
               message     => g_log_msg
      );
    END IF;

    g_log_msg := 'Running for Source '|| p_source;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_api_name,
               message     => g_log_msg
      );
    END IF;

    IF p_source = 'PO'
    THEN
      get_accounts_po
        (
          x_return_status  => x_return_status
        , x_msg_data       => x_msg_data
        , x_msg_count      => x_msg_count
        );
    ELSIF p_source = 'CTO'
    THEN
      get_accounts_cto
        (
          x_return_status  => x_return_status
        , x_msg_data       => x_msg_data
        , x_msg_count      => x_msg_count
        );
    END IF;


    g_log_msg := 'End of procedure '|| l_api_name;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_api_name,
               message     => g_log_msg
      );
    END IF;

  END get_accounts;


  --===================================================================
  --
  -- Start of comments
  -- API name        : get_accounts_po
  -- Type            : Public
  -- Pre-reqs        : load g_gmf_accts_tab_PUR plsql table
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- PURPOSE         : To get Charge (INV/EXP) and Accrual (AAP) accounts
  --                   using SLA TAB functionality
  -- Parameters      :
  --
  -- End of comments
  --===================================================================
  Procedure get_accounts_po
    (
      x_return_status                     OUT NOCOPY    VARCHAR2
    , x_msg_data                          OUT NOCOPY    VARCHAR2
    , x_msg_count                         OUT NOCOPY    NUMBER
    )
  IS

    l_api_name               VARCHAR2(80);
    l_return_status          VARCHAR2(1);

    l_account_type_code      VARCHAR2(80);
    l_legal_entity_id        NUMBER;
    l_ledger_id              NUMBER;
    l_coa_id                 NUMBER;

  BEGIN

    l_api_name      := 'get_accounts_po';
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    g_log_msg := 'Begin of procedure '|| l_api_name;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_api_name,
               message     => g_log_msg
      );
    END IF;


    /* Start INVCONV umoogala -- remove this once SLA TAB starts working */
    FOR Idx IN g_gmf_accts_tab_PUR.FIRST .. g_gmf_accts_tab_PUR.LAST
    LOOP

      g_log_msg := 'Fetching account for ' || g_gmf_accts_tab_PUR(idx).account_type_code ||
                   ' for organization_id: ' || g_gmf_accts_tab_PUR(idx).organization_id;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_statement,
                 module      => g_module_name || l_api_name,
                 message     => g_log_msg
        );
      END IF;

      SELECT CASE WHEN g_gmf_accts_tab_PUR(idx).account_type_code = 'INV' THEN
                    material_account
                  WHEN g_gmf_accts_tab_PUR(idx).account_type_code = 'EXP' THEN
                    expense_account
                  WHEN g_gmf_accts_tab_PUR(idx).account_type_code = 'AAP' THEN
                    ap_accrual_account
                  WHEN g_gmf_accts_tab_PUR(idx).account_type_code = 'PPV' THEN
                    purchase_price_var_account
             END CASE
        INTO g_gmf_accts_tab_PUR(idx).target_ccid
        FROM mtl_parameters mp
       WHERE mp.organization_id = g_gmf_accts_tab_PUR(idx).organization_id
      ;

      SELECT CONCATENATED_SEGMENTS
        INTO g_gmf_accts_tab_PUR(idx).concatenated_segments
        FROM gl_code_combinations_kfv
       WHERE CODE_COMBINATION_ID = g_gmf_accts_tab_PUR(idx).target_ccid
      ;

      g_log_msg := 'Concatenated account fetch: ' || g_gmf_accts_tab_PUR(idx).concatenated_segments;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_statement,
                 module      => g_module_name || l_api_name,
                 message     => g_log_msg
        );
      END IF;

    END LOOP;

    /*
    --===================================================================
    -- reset package variables
    --===================================================================

    GMF_XLA_TAB_PKG.reset_online_interface(
        p_api_version                     => 1.0
      , x_return_status                   => l_return_status
      , x_msg_count                       => x_msg_count
      , x_msg_data                        => x_msg_data
      );

    --===================================================================
    -- get Legal Entity, Ledger and Chart of accounts
    --===================================================================

    SELECT legal_entity, set_of_books_id, chart_of_accounts_id
      INTO l_legal_entity_id, l_ledger_id, l_coa_id
      FROM org_organization_definitions
     WHERE organization_id = to_number(g_gmf_accts_tab_PUR(1).operating_unit);


    --======================================================================
    --                    Insert Transaction data into PL/SQL table
    --======================================================================

    FOR Idx IN g_gmf_accts_tab_PUR.FIRST .. g_gmf_accts_tab_PUR.LAST
    LOOP

      IF g_gmf_accts_tab_PUR(idx).account_type_code = 'INV'
      THEN
        l_account_type_code := 'GMF_PUR_INV';
      ELSIF g_gmf_accts_tab_PUR(idx).account_type_code = 'EXP'
      THEN
        l_account_type_code := 'GMF_PUR_EXP';
      ELSIF g_gmf_accts_tab_PUR(idx).account_type_code = 'AAP'
      THEN
        l_account_type_code := 'GMF_PUR_AAP';
      END IF;

      GMF_XLA_TAB_PKG.write_online_tab_PUR(
          p_api_version                  => 1.0
        , p_source_distrib_id_num_1      => g_gmf_accts_tab_PUR(idx).source_distrib_id_num_1
        , p_source_distrib_id_num_2      => g_gmf_accts_tab_PUR(idx).source_distrib_id_num_2
        , p_source_distrib_id_num_3      => g_gmf_accts_tab_PUR(idx).source_distrib_id_num_3
        , p_source_distrib_id_num_4      => g_gmf_accts_tab_PUR(idx).source_distrib_id_num_4
        , p_source_distrib_id_num_5      => g_gmf_accts_tab_PUR(idx).source_distrib_id_num_5

        , p_account_type_code            => l_account_type_code
          --Start of source list
        , organization_code              => g_gmf_accts_tab_PUR(idx).organization_id
        , inventory_item_id              => g_gmf_accts_tab_PUR(idx).inventory_item_id
        , item_type                      => g_gmf_accts_tab_PUR(idx).item_type
        , ledger_id                      => l_ledger_id
        , legal_entity_id                => l_legal_entity_id
        , locator_id                     => g_gmf_accts_tab_PUR(idx).locator_id
        -- , lot_number                     => g_gmf_accts_tab_PUR(idx).lot_number
        , operating_unit                 => g_gmf_accts_tab_PUR(idx).operating_unit
        , subinventory_code              => g_gmf_accts_tab_PUR(idx).subinventory_code
        , subinventory_type              => g_gmf_accts_tab_PUR(idx).subinventory_type
        , vendor_id                      => g_gmf_accts_tab_PUR(idx).vendor_id
        , vendor_site_id                 => g_gmf_accts_tab_PUR(idx).vendor_site_id
          --End of source list

        , x_return_status                => x_return_status
        , x_msg_count                    => x_msg_count
        , x_msg_data                     => x_msg_data
        );

    END LOOP ;


    --======================================================================
    --                    Call Transaction Account Builder in online mode
    --======================================================================

     GMF_XLA_TAB_PKG.run (
        p_api_version                     => 1.0
      , p_account_definition_type_code    => 'S'  -- system
      , p_account_definition_code         => 'GMF_XLA_PUR_TAD'
      , p_transaction_coa_id              => l_coa_id
      , p_mode                            => 'ONLINE'
      , x_return_status                   => l_return_status
      , x_msg_count                       => x_msg_count
      , x_msg_data                        => x_msg_data
      )
    ;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      x_return_status := l_return_status;
    END IF;

    --======================================================================
    --                    retieve the code combination identifiers
    --======================================================================

    FOR Idx IN g_gmf_accts_tab_PUR.FIRST .. g_gmf_accts_tab_PUR.LAST LOOP

      GMF_XLA_TAB_PKG.read_online_tab_PUR(
          p_api_version                  => 1.0
        , p_source_distrib_id_num_1      => g_gmf_accts_tab_PUR(idx).source_distrib_id_num_1
        , p_source_distrib_id_num_2      => g_gmf_accts_tab_PUR(idx).source_distrib_id_num_2
        , p_source_distrib_id_num_3      => g_gmf_accts_tab_PUR(idx).source_distrib_id_num_3
        , p_source_distrib_id_num_4      => g_gmf_accts_tab_PUR(idx).source_distrib_id_num_4
        , p_source_distrib_id_num_5      => g_gmf_accts_tab_PUR(idx).source_distrib_id_num_5

        , p_account_type_code            => GMF_XLA_TAB_PKG.g_array_xla_tab_PUR(idx).account_type_code

        , x_target_ccid                  => g_gmf_accts_tab_PUR(idx).target_ccid
        , x_concatenated_segments        => g_gmf_accts_tab_PUR(idx).concatenated_segments
        , x_return_status                => l_return_status
        , x_msg_count                    => g_gmf_accts_tab_PUR(idx).msg_count
        , x_msg_data                     => g_gmf_accts_tab_PUR(idx).msg_data
        );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        x_return_status := l_return_status;
      END IF;

    END LOOP ;
    */

    -- x_return_status is initialized to success at the beginning of the procedure


    g_log_msg := 'End of procedure '|| l_api_name;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_api_name,
               message     => g_log_msg
      );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
      g_log_msg := 'Exc_Unexpected_Error in GMF_transaction_accounts_PUB.get_accounts_po';
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_procedure,
                 module      => g_module_name || l_api_name,
                 message     => g_log_msg
        );
      END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
       x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_ERROR
    THEN
      g_log_msg := 'EXC_ERROR in GMF_transaction_accounts_PUB.get_accounts_po: ' || x_msg_data;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_procedure,
                 module      => g_module_name || l_api_name,
                 message     => g_log_msg
        );
      END IF;

       x_return_status := FND_API.G_RET_STS_ERROR;
       IF x_msg_data IS NULL
       THEN
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
       END IF;

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
       x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PACKAGE_NAME, l_api_name);
       end if;

      g_log_msg := 'In when-others. error: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_procedure,
                 module      => g_module_name || l_api_name,
                 message     => g_log_msg
        );
      END IF;


  END get_accounts_po;


  --===================================================================
  --
  -- Start of comments
  -- API name        : get_accounts_cto
  -- Type            : Public
  -- Pre-reqs        : load g_gmf_accts_tab_CTO plsql table
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- PURPOSE         :
  -- Parameters      :
  --
  -- End of comments
  --===================================================================
  Procedure get_accounts_cto
    (
      x_return_status                     OUT NOCOPY    VARCHAR2
    , x_msg_data                          OUT NOCOPY    VARCHAR2
    , x_msg_count                         OUT NOCOPY    NUMBER
    )
  IS

    l_api_name               VARCHAR2(80);
    l_return_status          VARCHAR2(1);

    l_account_type_code      VARCHAR2(80);
    l_legal_entity_id        NUMBER;
    l_ledger_id              NUMBER;
    l_coa_id                 NUMBER;

  BEGIN

    l_api_name      := 'get_accounts_cto';
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    g_log_msg := 'Begin of procedure '|| l_api_name;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_api_name,
               message     => g_log_msg
      );
    END IF;


    /* Start INVCONV umoogala -- remove this once SLA TAB starts working */
    FOR Idx IN g_gmf_accts_tab_CTO.FIRST .. g_gmf_accts_tab_CTO.LAST
    LOOP

      g_log_msg := 'Fetching account for ' || g_gmf_accts_tab_CTO(idx).account_type_code ||
                   ' for organization_id: ' || g_gmf_accts_tab_CTO(idx).organization_id;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_statement,
                 module      => g_module_name || l_api_name,
                 message     => g_log_msg
        );
      END IF;

      SELECT CASE WHEN g_gmf_accts_tab_CTO(idx).account_type_code = G_CHARGE_INV_ACCT THEN
                    material_account
                  WHEN g_gmf_accts_tab_CTO(idx).account_type_code = G_CHARGE_EXP_ACCT THEN
                    expense_account
                  WHEN g_gmf_accts_tab_CTO(idx).account_type_code = G_ACCRUAL_ACCT THEN
                    ap_accrual_account
                  WHEN g_gmf_accts_tab_CTO(idx).account_type_code = G_VARIANCE_PPV_ACCT THEN
                    purchase_price_var_account
             END CASE
        INTO g_gmf_accts_tab_CTO(idx).target_ccid
        FROM mtl_parameters mp
       WHERE mp.organization_id = g_gmf_accts_tab_CTO(idx).organization_id
      ;

      SELECT CONCATENATED_SEGMENTS
        INTO g_gmf_accts_tab_CTO(idx).concatenated_segments
        FROM gl_code_combinations_kfv
       WHERE CODE_COMBINATION_ID = g_gmf_accts_tab_CTO(idx).target_ccid
      ;

      g_log_msg := 'concatenated Account fetched: ' || g_gmf_accts_tab_CTO(idx).concatenated_segments;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_statement,
                 module      => g_module_name || l_api_name,
                 message     => g_log_msg
        );
      END IF;

    END LOOP;

    /*
    -- Start INVCONV umoogala -- remove this once SLA TAB starts working

    FOR Idx IN g_gmf_accts_tab_CTO.FIRST .. g_gmf_accts_tab_CTO.LAST
    LOOP
      SELECT CASE WHEN g_gmf_accts_tab_CTO(idx).account_type_code = 'INV' THEN
                    distribution_account_id
                  WHEN g_gmf_accts_tab_CTO(idx).account_type_code = 'EXP' THEN
                    expense_account
                  WHEN g_gmf_accts_tab_CTO(idx).account_type_code = 'AAP' THEN
                    ap_accrual_account
                  WHEN g_gmf_accts_tab_CTO(idx).account_type_code = 'PPV' THEN
                    purchase_price_var_account
             END CASE
        INTO g_gmf_accts_tab_CTO(idx).target_ccid
        FROM mtl_parameters mp
       WHERE mp.organization_id = g_gmf_accts_tab_CTO(idx).organization_id
      ;

      SELECT CONCATENATED_SEGMENTS
        INTO g_gmf_accts_tab_CTO(idx).concatenated_segments
        FROM gl_code_combinations_kfv
       WHERE CODE_COMBINATION_ID = g_gmf_accts_tab_CTO(idx).target_ccid
      ;
    END LOOP;

    RETURN;

    --===================================================================
    -- reset package variables
    --===================================================================

    GMF_XLA_TAB_PKG.reset_online_interface(
        p_api_version                     => 1.0
      , x_return_status                   => l_return_status
      , x_msg_count                       => x_msg_count
      , x_msg_data                        => x_msg_data
      );

    --===================================================================
    -- get Legal Entity, Ledger and Chart of accounts
    --===================================================================

    SELECT legal_entity, set_of_books_id, chart_of_accounts_id
      INTO l_legal_entity_id, l_ledger_id, l_coa_id
      FROM org_organization_definitions
     WHERE organization_id = g_gmf_accts_tab_CTO(1).operating_unit;


    --======================================================================
    --                    Insert Transaction data into PL/SQL table
    --======================================================================

    FOR Idx IN g_gmf_accts_tab_CTO.FIRST .. g_gmf_accts_tab_CTO.LAST
    LOOP

      IF g_gmf_accts_tab_CTO(idx).account_type_code = 'INV'
      THEN
        l_account_type_code := 'GMF_PUR_INV';
      ELSIF g_gmf_accts_tab_CTO(idx).account_type_code = 'EXP'
      THEN
        l_account_type_code := 'GMF_PUR_EXP';
      ELSIF g_gmf_accts_tab_CTO(idx).account_type_code = 'AAP'
      THEN
        l_account_type_code := 'GMF_PUR_AAP';
      END IF;

      GMF_XLA_TAB_PKG.write_online_tab_CTO(
          p_api_version                  => 1.0
        , p_source_distrib_id_num_1      => g_gmf_accts_tab_CTO(idx).source_distrib_id_num_1
        , p_source_distrib_id_num_2      => g_gmf_accts_tab_CTO(idx).source_distrib_id_num_2
        , p_source_distrib_id_num_3      => g_gmf_accts_tab_CTO(idx).source_distrib_id_num_3
        , p_source_distrib_id_num_4      => g_gmf_accts_tab_CTO(idx).source_distrib_id_num_4
        , p_source_distrib_id_num_5      => g_gmf_accts_tab_CTO(idx).source_distrib_id_num_5

        , p_account_type_code            => l_account_type_code
          --Start of source list
        , organization_code              => g_gmf_accts_tab_CTO(idx).organization_id
        , inventory_item_id              => g_gmf_accts_tab_CTO(idx).inventory_item_id
        , ato_flag                       => g_gmf_accts_tab_CTO(idx).ato_flag
        , ledger_id                      => l_ledger_id
        , legal_entity_id                => l_legal_entity_id
        , operating_unit                 => g_gmf_accts_tab_CTO(idx).operating_unit
        , vendor_id                      => g_gmf_accts_tab_CTO(idx).vendor_id
        , vendor_site_id                 => g_gmf_accts_tab_CTO(idx).vendor_site_id
        , customer_id                    => g_gmf_accts_tab_CTO(idx).customer_id
        , customer_site_id               => g_gmf_accts_tab_CTO(idx).customer_site_id
          --End of source list

        , x_return_status                => x_return_status
        , x_msg_count                    => x_msg_count
        , x_msg_data                     => x_msg_data
        );

    END LOOP ;


    --======================================================================
    --                    Call Transaction Account Builder in online mode
    --======================================================================

     GMF_XLA_TAB_PKG.run (
        p_api_version                     => 1.0
      , p_account_definition_type_code    => 'S'  -- system
      , p_account_definition_code         => 'GMF_XLA_TAD'
      , p_transaction_coa_id              => l_coa_id
      , p_mode                            => 'ONLINE'
      , x_return_status                   => l_return_status
      , x_msg_count                       => x_msg_count
      , x_msg_data                        => x_msg_data
      )
    ;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      x_return_status := l_return_status;
    END IF;

    --======================================================================
    --                    retieve the code combination identifiers
    --======================================================================

    FOR Idx IN g_gmf_accts_tab_CTO.FIRST .. g_gmf_accts_tab_CTO.LAST LOOP

      GMF_XLA_TAB_PKG.read_online_tab_CTO(
          p_api_version                  => 1.0
        , p_source_distrib_id_num_1      => g_gmf_accts_tab_CTO(idx).source_distrib_id_num_1
        , p_source_distrib_id_num_2      => g_gmf_accts_tab_CTO(idx).source_distrib_id_num_2
        , p_source_distrib_id_num_3      => g_gmf_accts_tab_CTO(idx).source_distrib_id_num_3
        , p_source_distrib_id_num_4      => g_gmf_accts_tab_CTO(idx).source_distrib_id_num_4
        , p_source_distrib_id_num_5      => g_gmf_accts_tab_CTO(idx).source_distrib_id_num_5

        -- , p_account_type_code            => GMF_XLA_TAB_PKG.g_array_xla_tab_CTO(idx).account_type_code

        , x_target_ccid                  => g_gmf_accts_tab_CTO(idx).target_ccid
        , x_concatenated_segments        => g_gmf_accts_tab_CTO(idx).concatenated_segments
        , x_return_status                => l_return_status
        , x_msg_count                    => g_gmf_accts_tab_CTO(idx).msg_count
        , x_msg_data                     => g_gmf_accts_tab_CTO(idx).msg_data
        );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        x_return_status := l_return_status;
      END IF;

    END LOOP ;
    */

    -- x_return_status is initialized to success at the beginning of the procedure

    g_log_msg := 'End of procedure '|| l_api_name;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_api_name,
               message     => g_log_msg
      );
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
       x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

      g_log_msg := 'Exc_Unexpected_Error. Error: ' || x_msg_data;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_procedure,
                 module      => g_module_name || l_api_name,
                 message     => g_log_msg
        );
      END IF;


    WHEN FND_API.G_EXC_ERROR
    THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF x_msg_data IS NULL
       THEN
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
       END IF;

      g_log_msg := 'EXC_ERROR. Error: ' || x_msg_data;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_procedure,
                 module      => g_module_name || l_api_name,
                 message     => g_log_msg
        );
      END IF;


    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
       x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PACKAGE_NAME, l_api_name);
       end if;

      g_log_msg := 'In when-others. Error: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_statement,
                 module      => g_module_name || l_api_name,
                 message     => g_log_msg
        );
      END IF;


  END get_accounts_cto;

END GMF_transaction_accounts_PUB;

/
