--------------------------------------------------------
--  DDL for Package Body GMF_XLA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_XLA_PKG" AS
/* $Header: GMFXLAPB.pls 120.18.12010000.11 2010/02/18 19:48:51 rpatangy ship $ */

  G_CURRENT_RUNTIME_LEVEL       NUMBER                := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED            CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                 CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION             CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                 CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE             CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT             CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                 CONSTANT VARCHAR2(50) :='GMF.PLSQL.GMF_XLA_PKG.';


  G_reference_no                NUMBER;
  G_legal_entity_id             NUMBER;
  G_ledger_id                   NUMBER;
  G_accounting_mode             VARCHAR2(1);

  --
  -- Process Categories defined in SLA
  --
  /*
  G_inventory_transactions			VARCHAR2(30) :=  'INVENTORY_TRANSACTIONS';
  G_production_transactions			VARCHAR2(30) :=  'PRODUCTION_TRANSACTIONS';
  G_purchasing_transactions			VARCHAR2(30) :=  'PURCHASING_TRANSACTIONS';
  G_order_management					  VARCHAR2(30) :=  'ORDER_MANAGEMENT';
  G_revaluation_transactions		VARCHAR2(30) :=  'REVALUATION_TRANSACTIONS';
  */
  G_inventory_transactions			VARCHAR2(50) :=  'Inventory Transactions';
  G_production_transactions			VARCHAR2(50) :=  'Production Management Transactions';
  G_purchasing_transactions			VARCHAR2(50) :=  'Purchasing Transactions';
  G_order_management            VARCHAR2(50) :=  'Order Management Transactions';
  G_revaluation_transactions		VARCHAR2(50) :=  'Inventory Revaluation';

  --
  -- Event Classes defined in SLA
  --
  G_batch_material              VARCHAR2(30) := 'BATCH_MATERIAL';
  G_batch_resource              VARCHAR2(30) := 'BATCH_RESOURCE';
  g_batch_close                 VARCHAR2(30) := 'BATCH_CLOSE';
  G_costreval                   VARCHAR2(30) := 'COSTREVAL';
  G_lotcostadj                  VARCHAR2(30) := 'LOTCOSTADJ';

  --
  -- SLA call back stages.
  -- 1. Pre-Processing
  -- 2. Extract
  -- 3. Post-Processing
  -- 4. Post-Accounting
  --
  G_pre_accounting              VARCHAR2(30) := 'PRE_ACCOUNTING';
  G_extract                     VARCHAR2(30) := 'EXTRACT';
  G_post_processing             VARCHAR2(30) := 'POST_PROCESSING';
  G_post_accounting             VARCHAR2(30) := 'POST_ACCOUNTING';

	-- Initialize WHO columns
	g_user_id	                    NUMBER := FND_GLOBAL.USER_ID;
	g_login_id	                  NUMBER := FND_GLOBAL.LOGIN_ID;
	g_prog_appl_id	              NUMBER := FND_GLOBAL.PROG_APPL_ID;
	g_program_id	                NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
	g_request_id	                NUMBER := FND_GLOBAL.CONC_REQUEST_ID;

  g_log_msg                     FND_LOG_MESSAGES.message_text%TYPE;

  /**
   * Output log messages
   */

  PROCEDURE print_debug( pmsg IN VARCHAR2 )
  IS
   l_dt VARCHAR2(64);

  BEGIN
   l_dt := TO_CHAR(SYSDATE, 'yyyy-mm-dd hh24:mi:ss');
    fnd_file.put_line(fnd_file.log,pmsg||'  - '||l_dt);
  END print_debug;


/*============================================================================
 |  PUNCTION -  CREATE_EVENT
 |
 |  DESCRIPTION
 |          Create accounting events for '<TRANSACTION>' type
 |
 |  PRAMETERS
 |          p_event_type: Event type
 |          p_transaction_id: Unique Identifier
 |          P_event_date: Event date
 |          p_calling_sequence: Debug information
 |
 |  RETURN TYPE: NUMBER
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/

  FUNCTION create_event
  (
      p_reference_no       IN           NUMBER
    , p_legal_entity_id    IN           NUMBER
    , p_ledger_id          IN           NUMBER
    , x_errbuf             OUT NOCOPY   VARCHAR2
  )
  RETURN NUMBER
  IS

    l_procedure_name       CONSTANT VARCHAR2(100) := G_MODULE_NAME || 'CREATE_EVENT';
    l_entity_type_code     xla_events_int_gt.entity_code%TYPE;

    n_rows_inserted        NUMBER;  /* into xla_events_int_gt table */

    l_curr_calling_sequence VARCHAR2(4000);
    n_hdrs number;  -- xxxremove
    n_lines number;  -- xxxremove
    n_events number;  -- xxxremove

  BEGIN


    l_curr_calling_sequence := 'SLAPre-Processor' || '.GMF_XLA_PKG.CREATE_EVENT';
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


    g_log_msg := 'Begin of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    -- umxla_extract_gt;  /* xxxremove */

    select count(*) into n_hdrs  from gmf_xla_extract_headers_gt;  -- xxxremove
    select count(*) into n_lines from gmf_xla_extract_lines_gt;  -- xxxremove

    g_log_msg := n_hdrs || ' rows in hdrs_gt and ' || n_lines || ' rows in lines_gt';

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    ---------------------------------------------------------------------
    -- Set global variables
    ---------------------------------------------------------------------
    G_reference_no := p_reference_no;


    ---------------------------------------------------------------------
    -- Update extract hdr and lines global temp tables to set
    -- entity code, event class and type.
    ---------------------------------------------------------------------
    g_log_msg := 'Calling proc GMF_XLA_PKG.update_extract_gt to set entity codes';

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    update_extract_gt('SET_ENTITY_CODES', NULL);


    ------------------------------------------------------------------------
    -- Insert into xla_events_int_gt table. Create_Bulk_Events procedure
    -- of SLA will pickup txn from here and create events. It will
    -- also update event_id column in this table.
    -- We'll stamp this event id on gmf_xla_extract_headers.event_id.
    --
    -- We will insert only transactions for which event needs to be created.
    ------------------------------------------------------------------------

    --
    -- Bug 5668308: Added for loop to process multiple entity code. Multiple entity codes
    -- will come in case of Purchasing and OM since all internal order txns are
    -- mapped to Inventory Entity in SLA.
    --
    FOR i in (
                SELECT distinct entity_code
                  FROM gmf_xla_extract_headers_gt
             )
    LOOP
      g_log_msg := 'Calling function GMF_XLA_PKG.insert_into_xla_events_gt for entity ' || i.entity_code ||
                   ' (if entity is Inventory when process was submitted for PUR/OM, then we have some' ||
                   ' internal order transfers)';

      print_debug(g_log_msg);
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_procedure,
                 module      => g_module_name || l_procedure_name,
                 message     => g_log_msg
        );
      END IF;

      -- Bug 5668308: sending entity_code as parameter
      n_rows_inserted := insert_into_xla_events_gt(i.entity_code);

      ---------------------------------------------------------------------
      -- Now create events by calling xla_events_pkg.create_bulk_events
      -- only when there are any events to create.
      ---------------------------------------------------------------------
      IF n_rows_inserted = 0
      THEN
        g_log_msg := 'No events to create for entity ' || i.entity_code || '. User might be running the process more than once.' ||
                     ' We will still update extract headers and lines, since amounts might ' ||
                     ' differ from last run';

        print_debug(g_log_msg);
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_procedure,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

      ELSE
        --
        -- We've events to create
        --

        g_log_msg := 'Calling proc XLA_EVENTS_PKG.create_bulk_events for entity ' || i.entity_code;

        print_debug(g_log_msg);
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_procedure,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        /* Bug 5668308: we cannot use this as we've more than one
	 * entity code for PUR and OM since they process internal
	 * orders, which are mapped to Inventory entity.
	 * Following SQL was causing incorrect entity being set on
	 * SLA event and hence unable to query the event.
        SELECT entity_code
          INTO l_entity_type_code
          FROM gmf_xla_extract_headers_gt
         WHERE rownum = 1
        ;
        */


        xla_events_pub_pkg.create_bulk_events
        (
            p_source_application_id  => NULL
          , p_application_id         => 555
          , p_legal_entity_id        => p_legal_entity_id
          , p_ledger_id              => p_ledger_id
          -- , p_entity_type_code       => l_entity_type_code  Bug 5668308
          , p_entity_type_code       => i.entity_code
        );

        select count(*) into n_events from xla_events
         where application_id = 555
           and reference_num_1 = p_reference_no;     -- xxxremove

        g_log_msg := 'Completed bulk events creation. created ' || n_events || ' events (cumulative)';

        print_debug(g_log_msg);
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_procedure,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

      END IF;


      ---------------------------------------------------------------------
      -- Update gmf_xla_extract_headers_gt to set event_id
      -- generated by above call. No need to update if n_rows_inserted = 0
      ---------------------------------------------------------------------
      IF n_rows_inserted = 0
      THEN
        g_log_msg := 'No events were created for entity ' || i.entity_code ||'. So, no need to update extract_headers gt with event ids';

        print_debug(g_log_msg);
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_procedure,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

      ELSE
        g_log_msg := 'Calling proc XLA_EVENTS_PKG.update_extract_gt to set event ids for entity ' || i.entity_code;

        print_debug(g_log_msg);
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_procedure,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

	-- Bug 5668308: sending entity_code as parameter
        update_extract_gt('SET_EVENT_IDS', i.entity_code);

      END IF;

      DELETE FROM xla_events_int_gt; -- Cleanup for next run

    END LOOP; -- Loop for each Entity (i.e., Source/Process Category)
    /* Bug 5668308 */

    ---------------------------------------------------------------------
    -- Now insert/update gmf_xla_extract_headers to set event_id
    ---------------------------------------------------------------------
    g_log_msg := 'Calling proc update_extract_header';

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    update_extract_headers_table;


    ---------------------------------------------------------------------
    -- Now insert/update gmf_xla_extract_headers to set event_id
    ---------------------------------------------------------------------
    g_log_msg := 'Calling proc XLA_EVENTS_PKG.update_extract_lines';

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    update_extract_lines_table;


    ---------------------------------------------------------------------
    -- Now merge rows into gmf_transaction_valuation table.
    ---------------------------------------------------------------------
    g_log_msg := 'Calling proc XLA_EVENTS_PKG.merge_into_gtv';

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    merge_into_gtv;


    ---------------------------------------------------------------------
    -- Clean-up...
    --
    -- Now delete from xla_events_int_gt table. This table should not contain
    -- any rows for next time around. SLA expects this table to contain
    -- only rows for which events has to be created.
    -- Verify GT table definitions to decide whether to keep following
    -- stmt or not.
    ---------------------------------------------------------------------
    g_log_msg := 'Events creation complete. Deleting ALL rows from table xla_events_int_gt';

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    DELETE FROM xla_events_int_gt;


    ---------------------------------------------------------------------
    -- Clean-up...
    --
    -- gmf_xla_extract_headers/lines_gt tables too!
    -- Verify GT table definitions to decide whether to keep following
    -- stmts or not.
    ---------------------------------------------------------------------
    g_log_msg := 'Events creation complete. Deleting ALL rows from extract headers/lines gt tables';

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    DELETE FROM gmf_xla_extract_headers_gt;
    DELETE FROM gmf_xla_extract_lines_gt;

    ---------------------------------------------------------------------
    -- All done!
    ---------------------------------------------------------------------
    g_log_msg := 'End of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    RETURN 0;

  EXCEPTION
    WHEN OTHERS
    THEN
      x_errbuf := substrb('gmf_xla_pkg.create_event. in when-others: ' ||
                  '; sqlcode/err: ' ||  to_char(sqlcode) || '-' || sqlerrm, 1, 240);

      print_debug(x_errbuf);
      IF (FND_LOG.LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => FND_LOG.LEVEL_EXCEPTION,
                 module      => g_module_name || l_procedure_name,
                 message     => x_errbuf
        );
      END IF;

      g_log_msg := substrb('gmf_xla_pkg.create_event. in when-others (backtrace): ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 240);

      print_debug(g_log_msg);
      IF (FND_LOG.LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => FND_LOG.LEVEL_EXCEPTION,
                 module      => g_module_name || l_procedure_name,
                 message     => g_log_msg
        );
      END IF;

      RETURN -1;

  END create_event;

  PROCEDURE update_extract_gt (
    p_what_to_update  IN VARCHAR2,
    p_entity_code     IN VARCHAR2
  )
  IS

    l_procedure_name             CONSTANT VARCHAR2(100) := g_module_name || 'UPDATE_EXTRACT_GT';
    l_entity_code                VARCHAR2(100);
    l_event_class_code           VARCHAR2(100);
    l_event_type_code            VARCHAR2(100);

    l_transaction_id             BINARY_INTEGER;
    l_transaction_source_type_id BINARY_INTEGER;
    l_transaction_action_id      BINARY_INTEGER;
    l_source_document_id         BINARY_INTEGER;
    l_source_line_id             BINARY_INTEGER;
    l_transaction_type           VARCHAR2(100);
    l_ledger_id                  BINARY_INTEGER;
    l_valuation_cost_type_id     BINARY_INTEGER;
    l_cnt                        BINARY_INTEGER;

  BEGIN

    g_log_msg := 'Begin of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    <<update_extract_hdr_gt>>
    CASE p_what_to_update
    WHEN 'SET_ENTITY_CODES'
    THEN
      --
      -- setting entity_code, event_class_code, event_type_code
      --
      g_log_msg := 'Setting entity_code, event_class_code, and event_type_code now.';

      print_debug(g_log_msg);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_statement,
                 module      => g_module_name || l_procedure_name,
                 message     => g_log_msg
        );
      END IF;


      update gmf_xla_extract_headers_gt ehgt
         set (entity_code, event_class_code, event_type_code) =
                (SELECT entity_code, event_class_code, event_type_code
                   FROM gmf_xla_event_model em
                  WHERE
                    (   em.transaction_source_type_id     = ehgt.transaction_source_type_id
                    AND em.transaction_action_id          = ehgt.transaction_action_id
                    AND nvl(em.organization, 'x')         = nvl(ehgt.organization, 'x')
                    AND nvl(em.transfer_type, 'x')        = nvl(ehgt.transfer_type, 'x')
                    AND nvl(em.transfer_price_flag, 'x')  = nvl(ehgt.transfer_price_flag, 'x')
                    AND nvl(em.transaction_type, 'x')     = nvl(ehgt.transaction_type, 'x')
                    AND nvl(em.fob_point, 99)             = nvl(ehgt.fob_point, 99)
                    AND nvl(ehgt.transaction_type, 'x')   <> 'RESOURCE_TRANSACTIONS'
                    )
                    OR
                    (
                      nvl(ehgt.transaction_type, 'x')     = em.transaction_type -- 'RESOURCE_TRANSACTIONS'
                    )
                )
      ;

      g_log_msg := sql%rowcount || ' rows updated';

      print_debug(g_log_msg);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_statement,
                 module      => g_module_name || l_procedure_name,
                 message     => g_log_msg
        );
      END IF;

    -- /*
      BEGIN

        g_log_msg := 'Could not set event type for ' ||
                     'TxnID/SrcTyp/Act/Org/XferType/TPflag/FOB/TxnType/SrcDoc/SrcLine'
        ;
        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        FOR i in (
                    SELECT transaction_id, transaction_source_type_id, transaction_action_id,
                           source_document_id, source_line_id,
                           nvl(organization, 'x')        as organization,
                           nvl(transfer_type, 'x')       as transfer_type,
                           nvl(transfer_price_flag, 'x') as transfer_price_flag,
                           nvl(fob_point, 99)            as fob_point,
                           nvl(transaction_type, 'x')    as transaction_type
                      FROM gmf_xla_extract_headers_gt
                     WHERE entity_code IS NULL or event_class_code IS NULL OR event_type_code IS NULL
        )
        LOOP

          g_log_msg := i.transaction_id || '/' ||
                       i.transaction_source_type_id || '/' || i.transaction_action_id || '/' ||
                       i.organization || '/' || i.transfer_type || '/' ||
                       i.transfer_price_flag || '/' || i.fob_point || '/' ||
                       i.transaction_type || '/' ||
                       i.source_document_id || '/' ||
                       i.source_line_id
          ;

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;
        END LOOP;

        DELETE FROM gmf_xla_extract_lines_gt
         where header_id in (SELECT header_id
                               FROM gmf_xla_extract_headers_gt
                              WHERE entity_code IS NULL or event_class_code IS NULL OR event_type_code IS NULL)
        ;
        DELETE FROM gmf_xla_extract_headers_gt
         WHERE entity_code IS NULL or event_class_code IS NULL OR event_type_code IS NULL
        ;

      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          NULL;
      END;
    --*/



    WHEN 'SET_EVENT_IDS'
    THEN
      --
      -- setting event_id
      --
      g_log_msg := 'Setting event_id on extract_headers_gt for entity ' || p_entity_code;

      print_debug(g_log_msg);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_statement,
                 module      => g_module_name || l_procedure_name,
                 message     => g_log_msg
        );
      END IF;

      UPDATE gmf_xla_extract_headers_gt ehgt
         SET event_id = (SELECT event_id
                           FROM xla_events_int_gt egt
                          WHERE egt.source_id_int_1            = ehgt.transaction_id
                            AND egt.source_id_int_2            = ehgt.ledger_id
                            AND egt.source_id_int_3            = ehgt.valuation_cost_type_id
                            /* AND egt.source_id_int_4            = ehgt.transaction_source_type_id INVCONV */
                            AND egt.source_id_char_1           = ehgt.event_class_code
                            /* AND nvl(egt.source_id_char_2, 'x') = nvl(ehgt.lot_number, 'x') INVCONV */
                        )
       WHERE entity_code = p_entity_code
      ;



      g_log_msg := sql%rowcount || ' rows updated';

      print_debug(g_log_msg);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_statement,
                 module      => g_module_name || l_procedure_name,
                 message     => g_log_msg
        );
      END IF;


    END CASE update_extract_hdr_gt;


    g_log_msg := 'End of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

  END update_extract_gt;

  /* Bug 5668308: Added p_entity_code parameter */
  FUNCTION insert_into_xla_events_gt (p_entity_code IN VARCHAR2)
  RETURN NUMBER
  IS

    l_procedure_name   CONSTANT VARCHAR2(100) := g_module_name || 'INSERT_INTO_XLA_EVENTS_GT';
    n_rows_inserted    NUMBER;

  BEGIN

    g_log_msg := 'Begin of function '|| l_procedure_name || ' for entity ' || p_entity_code;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

      --
      -- Bug 5052850
      -- SLA created new table xla_events_int_gt for performance improvements.
      -- So, changed xla_events_int_gt table to xla_events_int_gt table.
      -- Prereq SLA patch: 4777706
      --
      -- RS Bug 5059076 - line_number and event_created_by columns
      -- are not there present in the new _int_gt table
      -- Both columns were set to Null before
      INSERT INTO xla_events_int_gt
      (
        entity_id
        , application_id
        , ledger_id
        , legal_entity_id
        , entity_code
        , transaction_number
        , source_id_int_1
        , source_id_int_2
        , source_id_int_3
        , source_id_int_4
        , source_id_char_1
        , source_id_char_2
        , source_id_char_3
        , source_id_char_4
        , event_id
        , event_class_code
        , event_type_code
        , event_number
        , event_date
        , event_status_code
        , process_status_code
        , reference_num_1
        , reference_num_2
        , reference_num_3
        , reference_num_4
        , reference_char_1
        , reference_char_2
        , reference_char_3
        , reference_char_4
        , reference_date_1
        , reference_date_2
        , reference_date_3
        , reference_date_4
        , valuation_method
        , security_id_int_1
        , security_id_int_2
        , security_id_int_3
        , security_id_char_1
        , security_id_char_2
        , security_id_char_3
        , on_hold_flag
        , transaction_date
      )
      SELECT
        DISTINCT
        NULL                    -- entity_id
        , 555                     -- application_id
        , ledger_id
        , legal_entity_id
        , entity_code
        , transaction_id              -- transaction_number
        , transaction_id              -- SOURCE_ID_INT_1
        , ledger_id                   -- SOURCE_ID_INT_2
        , valuation_cost_type_id      -- SOURCE_ID_INT_3
        /* , transaction_source_type_id  -- SOURCE_ID_INT_4 INVCONV */
        , NULL                        -- SOURCE_ID_INT_4
        , event_class_code            -- SOURCE_ID_CHAR_1
        /* , lot_number                  -- SOURCE_ID_CHAR_2 INVCONV */
        , NULL                        -- SOURCE_ID_CHAR_2
        , NULL                        -- SOURCE_ID_CHAR_3
        , NULL                        -- SOURCE_ID_CHAR_4
        , NULL                        -- event_id
        , event_class_code
        , event_type_code
        , NULL                    -- event_number
        , transaction_date        -- event_date
        , xla_events_pub_pkg.C_EVENT_UNPROCESSED  -- event_status_code
        , NULL                    -- process_status_code
        , reference_no            -- REFERENCE_NUM_1
        , NULL                    -- REFERENCE_NUM_2
        , NULL                    -- REFERENCE_NUM_3
        , NULL                    -- REFERENCE_NUM_4
        , NULL                    -- REFERENCE_CHAR_1
        , NULL                    -- REFERENCE_CHAR_2
        , NULL                    -- REFERENCE_CHAR_3
        , NULL                    -- REFERENCE_CHAR_4
        , NULL                    -- REFERENCE_DATE_1
        , NULL                    -- REFERENCE_DATE_2
        , NULL                    -- REFERENCE_DATE_3
        , NULL                    -- REFERENCE_DATE_4
        , valuation_cost_type     -- valuation_method
        , ehgt.organization_id    -- SECURITY_ID_INT_1
        , ehgt.operating_unit     -- SECURITY_ID_INT_2
        , legal_entity_id         -- SECURITY_ID_INT_3  Bug 6601963
        , NULL                    -- SECURITY_ID_CHAR_1
        , NULL                    -- SECURITY_ID_CHAR_2
        , NULL                    -- SECURITY_ID_CHAR_3
        , NULL
        , transaction_date
      FROM
        gmf_xla_extract_headers_gt ehgt
      WHERE
        entity_code = p_entity_code
      AND
        not exists (SELECT 'txns for which events created'
                     FROM gmf_xla_extract_headers eh
                    WHERE eh.transaction_id             = ehgt.transaction_id
                      AND eh.legal_entity_id            = ehgt.legal_entity_id
                      AND eh.ledger_id                  = ehgt.ledger_id
                      AND eh.valuation_cost_type_id     = ehgt.valuation_cost_type_id
                      /* AND eh.transaction_source_type_id = ehgt.transaction_source_type_id INVCONV */
                      AND eh.event_class_code           = ehgt.event_class_code
                      /* AND nvl(eh.lot_number, 'x')       = nvl(ehgt.lot_number, 'x') INVCONV */
                  )
      ;


    n_rows_inserted := sql%rowcount;

    g_log_msg := n_rows_inserted || ' rows inserted into xla_events_int_gt';

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    g_log_msg := 'End of procedure '|| l_procedure_name || ' for entity ' || p_entity_code;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    RETURN n_rows_inserted;

  END insert_into_xla_events_gt;

  PROCEDURE update_extract_headers_table
  IS

    l_procedure_name CONSTANT VARCHAR2(100) := g_module_name || 'UPDATE_EXTRACT_HEADERS_TABLE';

  BEGIN

    g_log_msg := 'Begin of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    g_log_msg := 'Merging rows in to gmf_xla_extract_headers table';

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    MERGE INTO gmf_xla_extract_headers eh
    USING (SELECT
                  DISTINCT
                    reference_no
                  , event_id
                  , entity_code
                  , event_class_code
                  , event_type_code
                  , legal_entity_id
                  , ledger_id
                  , xfer_legal_entity_id
                  , xfer_ledger_id
                  , operating_unit
                  , base_currency
                  , transaction_id
                  , transaction_date
                  , valuation_cost_type_id
                  , valuation_cost_type
                  , inventory_item_id
                  -- , item_revision
                  , organization_id
                  , lot_number
                  , transaction_quantity
                  , transaction_uom
                  , transaction_source_type_id
                  , transaction_action_id
                  , transaction_type_id
                  , transaction_value
                  , transaction_value_raw
                  , transaction_currency
                  , txn_source
                  , source_document_id
                  , source_line_id
                  , currency_code
                  , currency_conversion_date
                  , currency_conversion_type
                  , currency_conversion_rate -- Bug 6792803
                  , resources
                  -- , resource_class
                  , line_type
                  , ar_trx_type_id
                  , order_type
                  , reason_id
                  /*
                  , charge_id
                  , customer_id
                  , customer_site_id
                  , taxauth_id
                  , vendor_id
                  , vendor_site_id
                  , routing_id
                  , customer_gl_class
                  , itemcost_class
                  , vendor_gl_class
                  , cost_category_id
                  , gl_business_class_cat_id
                  , gl_product_line_cat_id
                  , jv_qty_ind
                  , quantity_um
                  */
                  , accounted_flag
                  , actual_posting_date
                  , invoiced_flag
                  , shipment_costed
             FROM gmf_xla_extract_headers_gt) ehgt
    ON    (    eh.transaction_id              = ehgt.transaction_id
           AND eh.ledger_id                   = ehgt.ledger_id
           AND eh.valuation_cost_type_id      = ehgt.valuation_cost_type_id
           /* AND eh.transaction_source_type_id  = ehgt.transaction_source_type_id INVCONV */
           AND eh.event_class_code            = ehgt.event_class_code
           /* AND nvl(eh.lot_number, 'x')        = nvl(ehgt.lot_number, 'x') INVCONV */
           /* Bug 7620018. Added legal_entity_id so that unique index GMF_XLA_EXTRACT_HEADERS_U2 is used. */
           AND eh.legal_entity_id             = ehgt.legal_entity_id
          )
    WHEN MATCHED THEN
      UPDATE SET
          eh.transaction_quantity     = ehgt.transaction_quantity
        , eh.transaction_uom          = ehgt.transaction_uom    /* B8617122 */
        , eh.transaction_value        = ehgt.transaction_value
        , eh.transaction_value_raw    = ehgt.transaction_value_raw
        , eh.reference_no             = ehgt.reference_no
        , eh.shipment_costed          = ehgt.shipment_costed
        , eh.invoiced_flag            = ehgt.invoiced_flag
        , eh.last_update_date         = sysdate
	, eh.last_updated_by          = g_user_id
	, eh.last_update_login        = g_login_id
	, eh.program_application_id   = g_prog_appl_id
	, eh.program_id               = g_program_id
	, eh.request_id               = g_request_id
        , eh.currency_conversion_rate = ehgt.currency_conversion_rate
        , eh.transaction_date         = ehgt.transaction_date         /* Bug 8251052 */
    WHEN NOT MATCHED THEN
      INSERT
        (
            header_id
          , reference_no
          , event_id
          , entity_code
          , event_class_code
          , event_type_code
          , legal_entity_id
          , ledger_id
          , xfer_legal_entity_id
          , xfer_ledger_id
          , operating_unit
          , base_currency
          , transaction_id
          , transaction_date
          , valuation_cost_type_id
          , valuation_cost_type
          , inventory_item_id
          -- , item_revision
          , organization_id
          , lot_number
          , transaction_quantity
          , transaction_uom
          , transaction_source_type_id
          , transaction_action_id
          , transaction_type_id
          , transaction_value
          , transaction_value_raw
          , transaction_currency
          , txn_source
          , source_document_id
          , source_line_id
          , currency_code
          , currency_conversion_date
          , currency_conversion_type
          , currency_conversion_rate -- Bug 6792803
          , resources
          -- , resource_class
          , line_type
          , ar_trx_type_id
          , order_type
          , reason_id
          /*
          , charge_id
          , customer_id
          , customer_site_id
          , taxauth_id
          , vendor_id
          , vendor_site_id
          , routing_id
          , customer_gl_class
          , itemcost_class
          , vendor_gl_class
          , cost_category_id
          , gl_business_class_cat_id
          , gl_product_line_cat_id
          , jv_qty_ind
          , quantity_um
          */
          , accounted_flag
          , actual_posting_date
          , creation_date
          , created_by
          , last_update_date
          , last_updated_by
          , last_update_login
          , program_application_id
          , program_id
          , request_id
        )
      VALUES
        (
            gmf_xla_extract_headers_s.NEXTVAL  -- header_id
          , ehgt.reference_no
          , ehgt.event_id
          , ehgt.entity_code
          , ehgt.event_class_code
          , ehgt.event_type_code
          , ehgt.legal_entity_id
          , ehgt.ledger_id
          , ehgt.xfer_legal_entity_id
          , ehgt.xfer_ledger_id
          , ehgt.operating_unit
          , ehgt.base_currency
          , ehgt.transaction_id
          , ehgt.transaction_date
          , ehgt.valuation_cost_type_id
          , ehgt.valuation_cost_type
          , ehgt.inventory_item_id
          -- , ehgt.item_revision
          , ehgt.organization_id
          , ehgt.lot_number
          , ehgt.transaction_quantity
          , ehgt.transaction_uom
          , ehgt.transaction_source_type_id
          , ehgt.transaction_action_id
          , ehgt.transaction_type_id
          , ehgt.transaction_value
          , ehgt.transaction_value_raw
          , ehgt.transaction_currency
          , ehgt.txn_source
          , ehgt.source_document_id
          , ehgt.source_line_id
          , ehgt.currency_code
          , ehgt.currency_conversion_date
          , ehgt.currency_conversion_type
          , ehgt.currency_conversion_rate
          , ehgt.resources
          -- , ehgt.resource_class
          , ehgt.line_type
          , ehgt.ar_trx_type_id
          , ehgt.order_type
          , ehgt.reason_id
          /*
          , ehgt.charge_id
          , ehgt.customer_id
          , ehgt.customer_site_id
          , ehgt.taxauth_id
          , ehgt.vendor_id
          , ehgt.vendor_site_id
          , ehgt.routing_id
          , ehgt.customer_gl_class
          , ehgt.itemcost_class
          , ehgt.vendor_gl_class
          , ehgt.cost_category_id
          , ehgt.gl_business_class_cat_id
          , ehgt.gl_product_line_cat_id
          , ehgt.jv_qty_ind
          , ehgt.quantity_um
          */
          , 'N'   -- ehgt.accounted_flag
          , ehgt.actual_posting_date
          , sysdate
          , g_user_id
          , sysdate
          , g_user_id
          , g_login_id
          , g_prog_appl_id
          , g_program_id
          , g_request_id
        )
    ;


    g_log_msg := sql%rowcount || ' rows merged into extract headers';

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;



    g_log_msg := 'End of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;


  END update_extract_headers_table;

  PROCEDURE update_extract_lines_table
  IS

    l_procedure_name CONSTANT VARCHAR2(100) := g_module_name || 'UPDATE_EXTRACT_LINES_TABLE';
    l_cnt number; -- xxxremove
  BEGIN

    g_log_msg := 'Begin of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    --
    -- First, set the header_id and event_id in extract_lines_gt table
    --
    -- B 7147477 include legal entity id so that unique index GMF_XLA_EXTRACT_HEADERS_U2 is used.
    UPDATE gmf_xla_extract_lines_gt elgt
       SET (header_id, event_id) =
                       (SELECT
                               eh.header_id, eh.event_id
                          FROM
                               gmf_xla_extract_headers_gt ehgt,
                               gmf_xla_extract_headers    eh
                         WHERE
                               ehgt.header_id                 = elgt.header_id
                           AND eh.legal_entity_id             = ehgt.legal_entity_id
                           AND eh.ledger_id                   = ehgt.ledger_id
                           AND eh.valuation_cost_type_id      = ehgt.valuation_cost_type_id
                           AND eh.transaction_id              = ehgt.transaction_id
                           /* AND eh.transaction_source_type_id  = ehgt.transaction_source_type_id INVCONV */
                           AND eh.event_class_code            = ehgt.event_class_code
                           /* AND nvl(eh.lot_number, 'x')        = nvl(ehgt.lot_number, 'x') INVCONV */
                       )
    ;


    g_log_msg := sql%rowcount || ' rows updated with header_id and event_id in extract_lines_gt table';

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;



    --
    -- Now, delete any old rows
    --
    DELETE FROM gmf_xla_extract_lines el
     WHERE
       -- reference_no <> g_reference_no AND
       header_id in
              (
                SELECT header_id
                  FROM gmf_xla_extract_lines_gt elgt
                 -- WHERE ehgt.header_id = el.header_id
              )
    ;

    g_log_msg := sql%rowcount || ' old rows deleted from extract_lines table';

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    --
    -- Now, merge with main extract_lines table
    --
    INSERT INTO gmf_xla_extract_lines
    (
        line_id
      , header_id
      , reference_no
      , event_id
      , ledger_id
      , line_number
      , journal_line_type
      , cost_cmpntcls_id
      , cost_analysis_code
      , component_cost
      , usage_ind
      , cost_level
      , aqui_cost_id
      , trans_amount_raw
      , base_amount_raw
      , trans_amount
      , base_amount
      , dr_cr_sign
      , organization_id
      , subinv_organization_id
      , subinventory_code
      , xfer_subinventory_code
      , lot_number
      , locator_id
      , transaction_account_id
      , entered_amount
      , accounted_amount
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , program_application_id
      , program_id
      , request_id
    )
    SELECT
        gmf_xla_extract_lines_s.NEXTVAL  -- line_id
      , elgt.header_id
      , elgt.reference_no
      , elgt.event_id
      , elgt.ledger_id
      , row_number() over(partition by header_id order by header_id)                   -- line_number
      , elgt.journal_line_type
      , elgt.cost_cmpntcls_id
      , elgt.cost_analysis_code
      , elgt.component_cost
      , elgt.usage_ind
      , elgt.cost_level
      , elgt.aqui_cost_id
      , elgt.trans_amount_raw
      , elgt.base_amount_raw
      , elgt.trans_amount
      , elgt.base_amount
      , elgt.dr_cr_sign
      , elgt.organization_id
      , elgt.organization_id
      , elgt.subinventory_code
      , elgt.xfer_subinventory_code
      , elgt.lot_number
      , elgt.locator_id
      , elgt.transaction_account_id
      , elgt.entered_amount
      , elgt.accounted_amount
      , sysdate
      , g_user_id
      , sysdate
      , g_user_id
      , g_prog_appl_id
      , g_program_id
      , g_request_id
    FROM
      gmf_xla_extract_lines_gt elgt
    ;

    g_log_msg := sql%rowcount || ' rows inserted into extract_lines table';

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;


    g_log_msg := 'End of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;


  END update_extract_lines_table;


  PROCEDURE merge_into_gtv
  IS

    l_procedure_name CONSTANT VARCHAR2(100) := g_module_name || 'MERGE_INTO_GTV';

  BEGIN

    g_log_msg := 'Begin of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    delete from gmf_transaction_valuation
     where (transaction_id, ledger_id, valuation_cost_type_id,
            -- transaction_source_type_id,
            event_class_code) IN
             (select eh.transaction_id, eh.ledger_id, eh.valuation_cost_type_id,
                     -- eh.transaction_source_type_id,
                     eh.event_class_code
                from gmf_xla_extract_headers eh,
                     gmf_xla_extract_lines_gt elgt
               where eh.header_id = elgt.header_id
                 and eh.event_id  = elgt.event_id
             )
    ;


    g_log_msg := sql%rowcount || ' previous rows deleted from GVT';

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => G_LEVEL_STATEMENT,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    INSERT INTO gmf_transaction_valuation
    (
        valuation_id
      , header_id
      , event_id
      , ledger_id
      , legal_entity_id
      , ledger_currency
      , valuation_cost_type
      , valuation_cost_type_id
      , reference_no
      , transaction_source
      , transaction_id
      , doc_id
      , line_id
      , org_id
      , organization_id
      , inventory_item_id
      , item_number
      , lot_number
      , resources
      , transaction_date
      , transaction_source_type_id
      , transaction_action_id
      , transaction_type_id
      , entity_code
      , event_class_code
      , event_type_code
      , final_posting_date
      , accounted_flag
      , line_type
      , transaction_source_type
      , journal_line_type
      , subinventory_code
      , component_class_usage
      , component_class_usage_type
      , cost_level
      , txn_base_value_raw
      , txn_base_value
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , program_application_id
      , program_id
      , request_id
    )
    SELECT
        gmf_transaction_valuation_S.nextval
      , a.header_id
      , a.event_id
      , a.ledger_id
      , a.legal_entity_id
      , a.ledger_currency
      , a.valuation_cost_type
      , a.valuation_cost_type_id
      , a.reference_no
      , a.transaction_source
      , a.transaction_id
      , a.doc_id
      , a.line_id
      , a.org_id
      , a.organization_id
      , a.inventory_item_id
      , a.item_number
      , a.lot_number
      , a.resources
      , a.transaction_date
      , a.transaction_source_type_id
      , a.transaction_action_id
      , a.transaction_type_id
      , a.entity_code
      , a.event_class_code
      , a.event_type_code
      , a.final_posting_date
      , a.accounted_flag
      , a.line_type
      , a.transaction_source_type
      , a.journal_line_type
      , a.subinventory_code
      , a.component_class_usage
      , a.component_class_usage_type
      , a.cost_level
      , a.txn_base_value_raw
      , a.txn_base_value
      , sysdate
      , g_user_id
      , sysdate
      , g_user_id
      , g_prog_appl_id
      , g_program_id
      , g_request_id
      FROM
           (SELECT
                eh.header_id
              , eh.event_id
              , eh.ledger_id
              , eh.legal_entity_id
              , eh.base_currency           as ledger_currency
              , eh.valuation_cost_type
              , eh.valuation_cost_type_id
              , eh.reference_no
              , decode(eh.txn_source,   'INV', 'INVENTORY',
                                        'PUR', 'PURCHASING',
                                        'OM',  'ORDERMANAGEMENT',
                                        'PM',  'PRODUCTION',
                                        'RVAL',  'COSTREVALUATION')
                                           as transaction_source
              , eh.transaction_id
              , eh.source_document_id    as doc_id
              , eh.source_line_id        as line_id
              , eh.operating_unit        as org_id
              , eh.organization_id
              , eh.inventory_item_id
              , item.concatenated_segments as item_number
              , NULL as lot_number
              , eh.resources
              , eh.transaction_date
              , eh.transaction_source_type_id
              , eh.transaction_action_id
              , eh.transaction_type_id
              , eh.entity_code
              , eh.event_class_code
              , eh.event_type_code
              , eh.actual_posting_date  as final_posting_date
              , eh.accounted_flag
              , eh.line_type
              , nvl(ts.transaction_source_type_name, ' ')  as transaction_source_type
              , elgt.journal_line_type
              , elgt.subinventory_code
              , decode(elgt.usage_ind, 1, 'Material',
                                       2, 'Overhead',
                                       3, 'Resource',
                                       4, 'Expense Alloc',
                                       5, 'Std Cost Adj') as component_class_usage
              , elgt.usage_ind as component_class_usage_type
              , elgt.cost_level
              , sum(elgt.BASE_AMOUNT_RAW)      as txn_base_value_raw
              , sum(elgt.BASE_AMOUNT)          as txn_base_value
              FROM gmf_xla_extract_headers eh,
                   gmf_xla_extract_lines_gt elgt,
                   mtl_system_items_kfv item,
                   mtl_txn_source_types ts
             WHERE eh.header_id                     = elgt.header_id
               AND eh.event_id                      = elgt.event_id
               --
               -- Need an outer join here since for batch close rows, item id is null
               --
               AND item.organization_id(+)          = eh.organization_id
               AND item.inventory_item_id(+)        = eh.inventory_item_id
               AND ts.transaction_source_type_id(+) = eh.transaction_source_type_id
             GROUP BY
                eh.header_id
              , eh.event_id
              , eh.ledger_id
              , eh.legal_entity_id
              , eh.base_currency
              , eh.valuation_cost_type
              , eh.valuation_cost_type_id
              , eh.reference_no
              , decode(eh.txn_source,   'INV', 'INVENTORY',
                                        'PUR', 'PURCHASING',
                                        'OM',  'ORDERMANAGEMENT',
                                        'PM',  'PRODUCTION',
                                        'RVAL',  'COSTREVALUATION')
              , eh.transaction_id
              , eh.source_document_id
              , eh.source_line_id
              , eh.operating_unit
              , eh.organization_id
              , eh.inventory_item_id
              , item.concatenated_segments
              , eh.lot_number
              , eh.resources
              , eh.transaction_date
              , eh.transaction_source_type_id
              , eh.transaction_action_id
              , eh.transaction_type_id
              , eh.entity_code
              , eh.event_class_code
              , eh.event_type_code
              , eh.actual_posting_date
              , eh.accounted_flag
              , eh.line_type
              , ts.transaction_source_type_name
              , elgt.journal_line_type
              , elgt.subinventory_code
              , decode(elgt.usage_ind, 1, 'Material',
                                       2, 'Overhead',
                                       3, 'Resource',
                                       4, 'Expense Alloc',
                                       5, 'Std Cost Adj')
              , elgt.usage_ind
              , elgt.cost_level
           ) a
    ;

    g_log_msg := sql%rowcount || ' rows inserted into GVT';

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;



    g_log_msg := 'End of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;


  END MERGE_INTO_GTV;



/*============================================================================
 |  PROCEDURE -  PREACCOUNTING(PUBLIC)
 |
 |  DESCRIPTION
 |    This procedure is the AP SLA preaccounting procedure. This procedure
 |    will be called by SLA through an API.
 |
 |  PRAMETERS
 |    p_application_id:
 |      This parameter is the application ID of the application that the SLA
 |      workflow event is for. This procedure must exit without doing anything
 |      if this parameter is not 200 to ensure that this procedure is only
 |      executed when the workflow event is for AP. This parameter will never
 |       be NULL.
 |    p_ledger_id:
 |      This parameter is the ledger ID of the ledger to account.This
 |      parameter is purely informational. This procedure selects from the
 |      XLA_ENTITY_EVENTS_V view, which does not include events incompatible
 |      with this parameter. This parameter will never be NULL.
 |    p_process_category:
 |      This parameter is the "process category" of the events to account. This
 |      parameter is purely informational. This procedure selects from the
 |      XLA_ENTITY_EVENTS_V view, which does not include events incompatible
 |      with this parameter.Possible values are as following:
 |      +------------+------------------------------------------+
 |      | Value      | Meaning                                  |
 |      +------------+------------------------------------------+
 |      | 'Invoices' | process invoices                         |
 |      | 'Payments' | process payments and reconciled payments |
 |      | 'All'      | process everything                       |
 |      +------------+------------------------------------------+
 |    p_end_date
 |      This parameter is the maximum event date of the events to be processed
 |      in this run of the accounting. This procedure selects from the
 |      XLA_ENTITY_EVENTS_V view, which does not include events incompatible
 |      with this parameter. This parameter will never be NULL.
 |    p_accounting_mode
 |      This parameter is the "accounting mode" that the accounting is being
 |      run in. This parameter will never be NULL.
 |      +-------+------------------------------------------------------------+
 |      | Value | Meaning                                                    |
 |      +-------+------------------------------------------------------------+
 |      | 'D'   | The accounting is being run in "draft mode". Draft mode is |
 |      |       | used to examine what the accounting entries would look for |
 |      |       | an event without actually creating the accounting entries. |
 |      |       | without actually creating the accounting entries.          |
 |      | 'F'   | The accounting is being run in "final mode". Final mode is |
 |      |       | used to create accounting entries.                         |
 |      +-------+------------------------------------------------------------+
 |    p_valuation_method
 |      This parameter is unused by AP. This parameter is purely informational.
 |      This procedure selects from the XLA_ENTITY_EVENTS_V view, which does
 |      not include events incompatible with this parameter.
 |    p_security_id_int_1
 |      This parameter is unused by AP.
 |    p_security_id_int_2
 |      This parameter is unused by AP.
 |    p_security_id_int_3
 |      This parameter is unused by AP.
 |    p_security_id_char_1
 |      This parameter is unused by AP.
 |    p_security_id_char_2
 |      This parameter is unused by AP.
 |    p_security_id_char_3
 |      This parameter is unused by AP.
 |    p_report_request_id
 |      This parameter is the concurrent request ID of the concurrent request
 |      that is this run of the accounting. This parameter is used to specify
 |      which events in the XLA_ENTITY_EVENTS_V view are to be accounted in
 |      this run of the accounting. This parameter will never be NULL.
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |    1) This procedure is run in final mode and draft mode.
 |    2) This procedure is run in batch mode but not in document mode.
 |    3) This procedure is in its own commit cycle.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
  PROCEDURE preaccounting
   ( p_application_id       IN           NUMBER
   , p_ledger_id            IN           NUMBER
   , p_process_category     IN           VARCHAR2
   , p_end_date             IN           DATE
   , p_accounting_mode      IN           VARCHAR2
   , p_valuation_method     IN           VARCHAR2
   , p_security_id_int_1    IN           NUMBER
   , p_security_id_int_2    IN           NUMBER
   , p_security_id_int_3    IN           NUMBER
   , p_security_id_char_1   IN           VARCHAR2
   , p_security_id_char_2   IN           VARCHAR2
   , p_security_id_char_3   IN           VARCHAR2
   , p_report_request_id    IN           NUMBER
   )
   IS
   l_profile varchar2(1);
   l_cost_frozen_flag NUMBER;
   x_cost_frozen_flag NUMBER;
   l_count Number;
   l_cost_type_id NUMBER;
   l_cost_mthd varchar2(10);




   CURSOR check_cost_not_frozen (l_security_id_int_3 NUMBER, l_valuation_method varchar2) IS
   Select 1 from dual
   where exists
   (SELECT  mp.organization_id
     FROM  mtl_parameters mp,
           gmf_fiscal_policies gfp,
           org_organization_definitions ood,
           gl_item_cst gic,
           gmf_period_statuses gps,
           cm_mthd_mst cmm
    WHERE  mp.process_enabled_flag = 'Y'
      AND  gfp.legal_entity_id = ood.legal_entity
      AND  gfp.legal_entity_id = l_security_id_int_3
      AND  mp.organization_id = ood.organization_id
      AND  gic.organization_id = mp.organization_id
      AND  gic.cost_type_id = gps.cost_type_id
      AND  gic.final_flag = 0
      AND  gic.end_date <= gps.end_date
      AND  gps.legal_entity_id = gfp.legal_entity_id
      AND  cmm.cost_type_id = gps.cost_type_id
      AND  cmm.cost_mthd_code = l_valuation_method
      AND  gps.start_date <= p_end_date
      AND  gps.end_date >= p_end_date);

-- Cursor used if no records exist in gl_item_cost

   CURSOR cost_update_run (l_security_id_int_3 NUMBER, l_valuation_method varchar2)  IS
   SELECT  count(mp.organization_id)
     FROM  mtl_parameters mp,
           gmf_fiscal_policies gfp,
           org_organization_definitions ood,
           gl_item_cst gic,
           gmf_period_statuses gps,
           cm_mthd_mst cmm
    WHERE  mp.process_enabled_flag = 'Y'
      AND  gfp.legal_entity_id = ood.legal_entity
      AND  gfp.legal_entity_id = l_security_id_int_3
      AND  mp.organization_id = ood.organization_id
      AND  gic.organization_id = mp.organization_id
      AND  gic.cost_type_id = gps.cost_type_id
      AND  gic.end_date <= gps.end_date
      AND  gps.legal_entity_id = gfp.legal_entity_id
      AND  cmm.cost_type_id = gps.cost_type_id
      AND  cmm.cost_mthd_code = l_valuation_method
      AND  gps.start_date <= p_end_date
      AND  gps.end_date >= p_end_date;

-- Get cost type and legal entity from extract headers
  CURSOR cur_le_cost_mthd IS
  SELECT DISTINCT cost_mthd_code, eh.legal_entity_id
    FROM gmf_xla_extract_headers eh, cm_mthd_mst cmm, gmf_ledger_valuation_methods vm
   WHERE eh.valuation_cost_type_id =  cmm.cost_type_id
     AND vm.ledger_id = eh.ledger_id
     AND vm.cost_type_id = eh.valuation_cost_type_id
     AND eh.ledger_id =   p_ledger_id
     AND eh.accounted_flag IS NOT NULL
     AND eh.transaction_date <= p_end_date
     AND cmm.cost_mthd_code = NVL(p_valuation_method, cmm.cost_mthd_code)
     AND eh.legal_entity_id = NVL(p_security_id_char_3, eh.legal_entity_id);

  BEGIN
    g_log_msg := 'Begin of procedure preaccounting Mode is '||p_accounting_mode;

    l_profile := NVL(fnd_profile.VALUE ('GMF_CHECK_COSTS_FROZEN'),'N');

    IF p_accounting_mode = 'F' THEN
     IF l_profile = 'Y' THEN

         x_cost_frozen_flag := 0; -- OK to begin with

         FOR rec IN cur_le_cost_mthd LOOP

           l_cost_frozen_flag := 0;

           OPEN cost_update_run( rec.legal_entity_id, rec.cost_mthd_code);
           FETCH cost_update_run INTO l_count;
           CLOSE cost_update_run;

           If l_count >= 1 THEN -- cost update has been run

             OPEN check_cost_not_frozen( rec.legal_entity_id, rec.cost_mthd_code);
             FETCH check_cost_not_frozen INTO l_cost_frozen_flag;
             CLOSE check_cost_not_frozen;

           Else
             l_cost_frozen_flag := 1;

           End If;

           IF l_cost_frozen_flag = 1 THEN
             x_cost_frozen_flag := 1;
           END IF;

         END LOOP;

      IF x_cost_frozen_flag = 1 THEN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
            THEN

          FND_LOG.STRING(
                        log_level   => g_level_procedure,
                        module      => g_module_name ,
                        message     => g_log_msg
                        );
        END IF;

      -- g_log_msg := 'Raising application error. costs are not frozen and accounting mode is '||p_accounting_mode;
      FND_MESSAGE.SET_NAME('GMF', 'CM_NOT_FROZEN');

      g_log_msg := FND_MESSAGE.GET;


       RAISE_APPLICATION_ERROR(-20101, g_log_msg);
      END IF;

     END IF; -- l_profile = 'Y'
    END IF; -- p_accounting_mode = 'F'
    /*
    CASE p_process_category
      WHEN G_inventory_transactions
      THEN
        process_inv_txns(g_pre_accounting);
      WHEN G_purchasing_transactions
      THEN
        process_pur_txns(g_pre_accounting);
      WHEN G_production_transactions
      THEN
        process_pm_txns(g_pre_accounting);
      WHEN G_order_management
      THEN
        process_om_txns(g_pre_accounting);
      WHEN G_revaluation_transactions
      THEN
        process_rval_txns(g_pre_accounting);
    END CASE;
    */
  END preaccounting;


/*============================================================================
 |  PROCEDURE - EXTRACT (PUBLIC)
 |
 |  DESCRIPTION
 |    This procedure is the AP SLA extract procedure. This procedure
 |    will be called by SLA thorugh an API.
 |
 |  PRAMETERS
 |    p_application_id
 |      This parameter is the application ID of the application that the SLA
 |      workflow event is for. This procedure must exit without doing anything
 |      if this parameter is not 200 to ensure that this procedure is only
 |      executed when the workflow event is for AP. This parameter will never
 |      be NULL.
 |   p_accounting_mode
 |     This parameter is the "accounting mode" that the accounting is being
 |     run in. This parameter will never be NULL.
 |     +-------+-----------------------------------------------------------+
 |     | Value | Meaning                                                   |
 |     +-------+-----------------------------------------------------------+
 |     | 'D'   | The accounting is being run in "draft mode". Draft mode is|
 |     |       | used TO examine what the accounting entries would look for|
 |     |       | an event without actually creating the accounting entries |
 |     | 'F'   | The accounting is being run in "final mode". Final mode is|
 |     |       | used to create accounting entries.                        |
 |     +-------+-----------------------------------------------------------+
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |    1) This procedure is run in final mode and draft mode.
 |    2) This procedure is run in batch mode and document mode.
 |    3) This procedure is part of the accounting commit cycle.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
  PROCEDURE extract
   ( p_application_id       IN           NUMBER
   , p_accounting_mode      IN           VARCHAR2
   )
   IS

  BEGIN
    NULL;
    /*
    CASE p_process_category
      WHEN G_inventory_transactions
      THEN
        process_inv_txns(G_extract);
      WHEN G_purchasing_transactions
      THEN
        process_pur_txns(G_extract);
      WHEN G_production_transactions
      THEN
        process_pm_txns(G_extract);
      WHEN G_order_management
      THEN
        process_om_txns(G_extract);
      WHEN G_revaluation_transactions
      THEN
        process_rval_txns(G_extract);
    END CASE;
    */
  END extract;


/*============================================================================
 |  PROCEDURE -  POSTACCOUNTING(PUBLIC)
 |
 |  DESCRIPTION
 |    This procedure is the AP SLA post-accounting procedure. This procedure
 |    will be called by SLA through an API.
 |
 |  PRAMETERS
 |    p_application_id
 |      This parameter is the application ID of the application that the SLA
 |      workflow event is for. This procedure must exit without doing anything
 |      if this parameter is not 200 to ensure that this procedure is only
 |      executed when the workflow event is for AP. This parameter will never
 |      be NULL.
 |    p_ledger_id
 |      This parameter is the ledger ID of the ledger to account. This
 |      parameter is purely informational. This procedure selects from the
 |      XLA_ENTITY_EVENTS_V view, which does not include events incompatible
 |      with this parameter. This parameter will never be NULL.
 |    p_process_category
 |      This parameter is the "process category" of the events to account.
 |      This parameter is purely informational. This procedure selects from
 |      the XLA_ENTITY_EVENTS_V view, which does not include events
 |      incompatible with this parameter.Possible values are as following:
 |      +------------+-------------------------------+
 |      | Value      | Meaning                       |
 |      +------------+-------------------------------+
 |      | 'Invoices' | process invoices              |
 |      | 'Payments' | process payments and receipts |
 |      | 'All'      | process everything            |
 |      +------------+-------------------------------+
 |    p_end_date
 |      This parameter is the maximum event date of the events to be processed
 |      in this run of the accounting. This procedure selects from the
 |      XLA_ENTITY_EVENTS_V view, which does not include events incompatible
 |      with this parameter. This parameter will never be NULL.
 |    p_accounting_mode
 |      This parameter is the "accounting mode" that the accounting is being
 |      run in. This parameter will never be NULL.
 |      +-------+-------------------------------------------------------------+
 |      | Value | Meaning                                                     |
 |      +-------+-------------------------------------------------------------+
 |      | 'D'   | The accounting is being run in "draft mode". Draft mode is  |
 |      |       | used to examine what the accounting entries would look for  |
 |      |       | an event without actually creating the accounting entries.  |
 |      | 'F'   | The accounting is being run in "final mode". Final mode is  |
 |      |       | used to create accounting entries.                          |
 |      +-------+-------------------------------------------------------------+
 |    p_valuation_method
 |       This parameter is unused by AP. This parameter is purely informational
 |       This procedure selects from the XLA_ENTITY_EVENTS_V view, which does
 |       not include events incompatible with this parameter.
 |    p_security_id_int_1
 |      This parameter is unused by AP.
 |    p_security_id_int_2
 |      This parameter is unused by AP.
 |    p_security_id_int_3
 |      This parameter is unused by AP.
 |    p_security_id_char_1
 |      This parameter is unused by AP.
 |    p_security_id_char_2
 |      This parameter is unused by AP.
 |    p_security_id_char_3
 |      This parameter is unused by AP.
 |    p_report_request_id
 |      This parameter is the concurrent request ID of the concurrent request
 |      that is this run of the accounting. This parameter is used to specify
 |      which events in the XLA_ENTITY_EVENTS_V view are to be accounted in
 |      this run of the accounting. This parameter will never be NULL.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |    1) This procedure is run in final mode and draft mode.
 |    2) This procedure is run in batch mode but not in document mode.
 |    3) This procedure is in its own commit cycle.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
  PROCEDURE postaccounting
    ( p_application_id       IN           NUMBER
    , p_ledger_id            IN           NUMBER
    , p_process_category     IN           VARCHAR2
    , p_end_date             IN           DATE
    , p_accounting_mode      IN           VARCHAR2
    , p_valuation_method     IN           VARCHAR2
    , p_security_id_int_1    IN           NUMBER
    , p_security_id_int_2    IN           NUMBER
    , p_security_id_int_3    IN           NUMBER
    , p_security_id_char_1   IN           VARCHAR2
    , p_security_id_char_2   IN           VARCHAR2
    , p_security_id_char_3   IN           VARCHAR2
    , p_report_request_id    IN           NUMBER
    )
    IS

  BEGIN
    NULL;
    /*
    CASE p_process_category
      WHEN G_inventory_transactions
      THEN
        process_inv_txns(G_post_accounting);
      WHEN G_purchasing_transactions
      THEN
        process_pur_txns(G_post_accounting);
      WHEN G_production_transactions
      THEN
        process_pm_txns(G_post_accounting);
      WHEN G_order_management
      THEN
        process_om_txns(G_post_accounting);
      WHEN G_revaluation_transactions
      THEN
        process_rval_txns(G_post_accounting);
    END CASE;
    */
  END postaccounting;

/*============================================================================
 |  PROCEDURE - POSTPROCESSING (PUBLIC)
 |
 |  DESCRIPTION
 |    This procedure is the AP SLA post-processing procedure. This procedure
 |    will be called by SLA thorugh an API.
 |
 |    The XLA_POST_ACCTG_EVENTS_V view contains only the successfully accounted
 |    events.
 |
 |  PRAMETERS
 |    p_application_id
 |      This parameter is the application ID of the application that the SLA
 |      workflow event is for. This procedure must exit without doing anything
 |      if this parameter is not 200 to ensure that this procedure is only
 |      executed when the workflow event is for AP. This parameter will never
 |      be NULL.
 |   p_accounting_mode
 |     This parameter is the "accounting mode" that the accounting is being
 |     run in. This parameter will never be NULL.
 |     +-------+-----------------------------------------------------------+
 |     | Value | Meaning                                                   |
 |     +-------+-----------------------------------------------------------+
 |     | 'D'   | The accounting is being run in "draft mode". Draft mode is|
 |     |       | used TO examine what the accounting entries would look for|
 |     |       | an event without actually creating the accounting entries |
 |     | 'F'   | The accounting is being run in "final mode". Final mode is|
 |     |       | used to create accounting entries.                        |
 |     +-------+-----------------------------------------------------------+
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |    1) This procedure is run in final mode and draft mode.
 |    2) This procedure is run in batch mode and document mode.
 |    3) This procedure is part of the accounting commit cycle.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
  PROCEDURE postprocessing
   ( p_application_id       IN           NUMBER
   , p_accounting_mode      IN           VARCHAR2
   )
  IS


    l_procedure_name               CONSTANT VARCHAR2(100):= g_module_name || 'preaccounting';

  BEGIN

    g_log_msg := 'Begin of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;


    g_log_msg := 'Parameters: application_id = ' || p_application_id ||
                 ' p_accounting_mode = ' || p_accounting_mode;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    ---------------------------------------------------------------------
    -- This procedure should only called for GMF (application id = 555)
    -- Otherwise exit the procedure.
    ---------------------------------------------------------------------
    IF (p_application_id <> 555) THEN

      g_log_msg := 'Invalid application id ' || p_application_id || ' passed. exiting';

      print_debug(g_log_msg);
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_procedure,
                 module      => g_module_name || l_procedure_name,
                 message     => g_log_msg
        );
      END IF;
      RETURN;
    END IF;

    ---------------------------------------------------------------------
    -- only accept 'D' (draft) or 'F' (final) mode
    ---------------------------------------------------------------------
    IF p_accounting_mode NOT IN ('D', 'F')
    THEN

      g_log_msg := 'Invalid Accounting mode ' || p_accounting_mode || ' for this procedure';

      print_debug(g_log_msg);
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_procedure,
                 module      => g_module_name || l_procedure_name,
                 message     => g_log_msg
        );
      END IF;
      RETURN;
    END IF;

    G_accounting_mode := p_accounting_mode;

    ---------------------------------------------------------------------
    -- Now update extract header, transaction valuation and mmt to set
    -- costed flag.
    -- We need to loop for each process category as this is not a mandatory
    -- parameter to Create Accounting program.
    ---------------------------------------------------------------------
    FOR i in (SELECT DISTINCT process_category
                FROM gmf_xla_event_model em
               WHERE exists (SELECT 'X'
                               FROM xla_post_acctg_events_v ae
                              WHERE ae.event_class_code = em.event_class_code)
             )
    LOOP

      g_log_msg := 'Post-Processing for '|| i.process_category;

      print_debug(g_log_msg);
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
        FND_LOG.STRING(
                 log_level   => g_level_procedure,
                 module      => g_module_name || l_procedure_name,
                 message     => g_log_msg
        );
      END IF;

      CASE i.process_category

        ---------------------------------------------------------------------
        -- Inventory Transactions
        ---------------------------------------------------------------------
        WHEN G_inventory_transactions
        THEN
          process_inv_txns(G_post_processing);

        ---------------------------------------------------------------------
        -- OPM Production transactions
        ---------------------------------------------------------------------
        WHEN G_production_transactions
        THEN
          process_pm_txns(G_post_processing);

        ---------------------------------------------------------------------
        -- Purchasing Transactions
        ---------------------------------------------------------------------
        WHEN G_purchasing_transactions
        THEN
          process_pur_txns(G_post_processing);

        ---------------------------------------------------------------------
        -- Order Management Transactions
        ---------------------------------------------------------------------
        WHEN G_order_management
        THEN
          process_om_txns(G_post_processing);

        ---------------------------------------------------------------------
        -- Cost Reval and Lot Cost Adjustment Transactions
        ---------------------------------------------------------------------
        WHEN G_revaluation_transactions
        THEN
          process_rval_txns(G_post_processing);
      END CASE;

    END LOOP;

    g_log_msg := 'End of procedure '|| l_procedure_name;

    print_debug(g_log_msg);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_procedure,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

  END postprocessing;

/*============================================================================
 |  PROCEDURE - process_inv_txns
 |
 |  DESCRIPTION
 |    This procedure processes all inventory transactions. Right now we are
 |    using this procedure for post-processing, but we can use it for other
 |    processing events (pre-processing, extract and post-accounting).
 |
 |  PRAMETERS
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  01-Oct-2005  umoogala           Genesis
 *===========================================================================*/
  PROCEDURE process_inv_txns(p_event VARCHAR2)
  IS
    l_procedure_name    CONSTANT VARCHAR2(100) := 'process_inv_txns';

  BEGIN

    g_log_msg := 'Begin of procedure ' || l_procedure_name || ' for event ' || p_event;

    print_debug(g_log_msg);

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    CASE p_event
      WHEN G_pre_accounting
      THEN
        NULL;
      WHEN G_extract
      THEN
        NULL;
      WHEN G_post_accounting
      THEN
        NULL;
      WHEN G_post_processing
      THEN

        g_log_msg := 'Updating gmf_xla_extract_headers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        --
        -- Update extract Headers
        --
        UPDATE gmf_xla_extract_headers
           SET   accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , actual_posting_date   = DECODE(G_accounting_mode, 'F', sysdate, NULL)
               , last_update_date      = sysdate
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE (transaction_id, ledger_id, valuation_cost_type_id, event_class_code)
                  in (SELECT
                             xpae.SOURCE_ID_INT_1, xpae.SOURCE_ID_INT_2,
                             xpae.SOURCE_ID_INT_3, xpae.SOURCE_ID_CHAR_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_inventory_transactions
                         and xpae.event_class_code = gxem.event_class_code
                     )
        ;
        g_log_msg := sql%rowcount || ' rows updated in gmf_xla_extract_headers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT  >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        --
        -- Update transaction valuation table
        --
        g_log_msg := 'Updating gmf_transaction_valuation table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        UPDATE gmf_transaction_valuation
           SET   accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , final_posting_date    = DECODE(G_accounting_mode, 'F', sysdate, NULL)
               , last_update_date      = sysdate
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE
               (transaction_id, ledger_id, valuation_cost_type_id, event_class_code)
                  in (SELECT
                             xpae.SOURCE_ID_INT_1, xpae.SOURCE_ID_INT_2,
                             xpae.SOURCE_ID_INT_3, xpae.SOURCE_ID_CHAR_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_inventory_transactions
                         and xpae.event_class_code = gxem.event_class_code
                     )
          AND ACCOUNTED_FLAG IS NOT NULL   -- B7395353 Rajesh Patangya
        ;
        g_log_msg := sql%rowcount || ' rows updated in gmf_transaction_valuation table';
        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        --
        -- Update transaction valuation table
        --
        g_log_msg := 'Updating mtl_material_transactions table';

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;
        -- We need to do a single update to mtl_material_transactions so that
        -- session will perform all updates together. If any other session has updated any of the records session will wait
        -- until lock is available eliminating dead lock.
        -- Old queries PK Bug 9066162. These queries are now used to insert data in gmf_inv_Txn_flags_gt
        -- Q1
      /*  UPDATE mtl_material_transactions
           SET   opm_costed_flag       = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , program_update_date   = SYSDATE
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE transaction_id
                  IN (SELECT
                             xpae.SOURCE_ID_INT_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_inventory_transactions
                         AND xpae.event_class_code = gxem.event_class_code
                         AND xpae.event_class_code NOT IN ('FOB_RCPT_SENDER_RCPT', 'FOB_SHIP_RECIPIENT_SHIP') ); */
        -- Q2 performed only when G_accounting_mode = 'F'
       /*  UPDATE mtl_material_transactions
             SET   opm_costed_flag       = NULL
                 , program_update_date   = SYSDATE
                 , last_updated_by       = g_user_id
                 , last_update_login     = g_login_id
                 , program_application_id= g_prog_appl_id
                 , program_id            = g_program_id
                 , request_id            = g_request_id
           WHERE transaction_source_type_id in (2, 4, 8, 9, 10, 13)
             AND transaction_action_id      in (2, 28)
             AND transfer_transaction_id
                    in (SELECT
                               xpae.SOURCE_ID_INT_1
                          FROM
                               xla_post_acctg_events_v xpae,
                               gmf_xla_event_model     gxem
                         WHERE
                               gxem.process_category = G_inventory_transactions
                           AND xpae.event_class_code = gxem.event_class_code
                           AND xpae.event_class_code in ('SUBINV_XFER'));  */
         -- Q3 performed only when G_accounting_mode = 'F'
         /* UPDATE mtl_material_transactions
             SET   shipment_costed       = 'Y'
                 , program_update_date   = SYSDATE
                 , last_updated_by       = g_user_id
                 , last_update_login     = g_login_id
                 , program_application_id= g_prog_appl_id
                 , program_id            = g_program_id
                 , request_id            = g_request_id
           WHERE transaction_source_type_id in (7, 8, 13)
             AND transaction_action_id      in (12, 21)
             AND transaction_id
                    in (SELECT
                               xpae.SOURCE_ID_INT_1
                          FROM
                               xla_post_acctg_events_v xpae,
                               gmf_xla_event_model     gxem
                         WHERE
                               gxem.process_category = G_inventory_transactions
                           AND xpae.event_class_code = gxem.event_class_code
                           AND xpae.event_class_code in ('FOB_RCPT_SENDER_RCPT', 'FOB_SHIP_RECIPIENT_SHIP')); */

       /* There may be multiple sessions. Q1 is specific to current session. Q2 and Q3 are performed only when accouting mode is final.
          Q2 should not be a problem since there is only one event for Subinventory transfer. We do not have two separate events for
          Subinventory transfer. These multiple updates caused deadlock based on how events were distributed amongst workers.
          Old queries are now used to insert data in gmf_inv_Txn_flags_gt. And a single update is used to update all mmt rows.
          Bug 9066162 new logic follows. We need to sort duplicates. Union can not be used since hard coded values are used for
          opm_costed_flag and shipment_costed. Events for these may or may not be processed by the same worker.
       */


                Insert into gmf_inv_Txn_flags_gt (transaction_id, opm_costed_flag, shipment_costed)
                        SELECT DISTINCT xpae.SOURCE_ID_INT_1 transaction_id,
                        DECODE(G_accounting_mode, 'D', 'D', 'F', NULL) opm_costed_flag,
                        NULL shipment_costed
                          FROM xla_post_acctg_events_v xpae,
                               gmf_xla_event_model     gxem
                         WHERE gxem.process_category = G_inventory_transactions
                           AND xpae.event_class_code = gxem.event_class_code
                           AND xpae.event_class_code NOT IN ('FOB_RCPT_SENDER_RCPT', 'FOB_SHIP_RECIPIENT_SHIP')
                      UNION ALL
                        SELECT DISTINCT mmt1.transfer_transaction_id, NULL, NULL
                          FROM mtl_material_transactions mmt1
                         WHERE G_accounting_mode = 'F'
                           AND mmt1.transaction_source_type_id in (2, 4, 8, 9, 10, 13)
                           AND mmt1.transaction_action_id      in (2, 28)
                           AND mmt1.transaction_id IN
                               (SELECT xpae.SOURCE_ID_INT_1
                                  FROM xla_post_acctg_events_v xpae,
                                       gmf_xla_event_model     gxem
                                 WHERE gxem.process_category = G_inventory_transactions
                                   AND xpae.event_class_code = gxem.event_class_code
                                   AND xpae.event_class_code in ('SUBINV_XFER')
                               )
                      UNION ALL
                        SELECT DISTINCT mmt2.transaction_id, 'N', 'Y'
                          FROM  mtl_material_transactions mmt2
                         WHERE G_accounting_mode = 'F'
                           AND mmt2.transaction_source_type_id in (7, 8, 13)
                           AND mmt2.transaction_action_id      in (12, 21)
                           AND mmt2.transaction_id IN
                               (SELECT xpae.SOURCE_ID_INT_1
                                  FROM xla_post_acctg_events_v xpae,
                                       gmf_xla_event_model     gxem
                                 WHERE gxem.process_category = G_inventory_transactions
                                   AND xpae.event_class_code = gxem.event_class_code
                                   AND xpae.event_class_code in ('FOB_RCPT_SENDER_RCPT', 'FOB_SHIP_RECIPIENT_SHIP'))
                           ;

                  -- One session can get both events for shipment and Intransit. In such case there will be duplicate rows in
                  -- gmf_inv_Txn_flags_gt. Find duplicates update and eliminate duplicates


                 Update gmf_inv_Txn_flags_gt
                    set opm_costed_flag = NULL,
                        shipment_costed = 'Y'
                  where transaction_id IN (select transaction_id
                                             from   gmf_inv_Txn_flags_gt
                                            group by  transaction_id
                                           having count(transaction_id) > 1);


                 IF sql%rowcount > 0 THEN

                   delete from gmf_inv_Txn_flags_gt
                    where rowid IN (select min(rowid) from   gmf_inv_Txn_flags_gt
                                              group by  transaction_id
                                             having count(transaction_id) > 1);

                 END IF;


         -- Bug 9066162 New logic. Uses sigle update for all transactions to eliminate deadlock.
         -- If any transaction/s are updated by another session this will wait, replacing possible deadlock with a wait event.
         -- Now Update mmt flags. We do not want to overwrite flags if written by another session Thus decode is used in select query.
         -- for both opm_costed_flag and shipment_costed.

         update   mtl_material_transactions mmt
            set (opm_costed_flag, shipment_costed) = (select  decode(mmt.opm_costed_flag,NULL,NULL,'D',decode(txngt.opm_costed_flag, NULL, NULL,'D'),'N',txngt.opm_costed_flag)
                                                             ,decode(mmt.shipment_costed,'Y','Y',decode(txngt.shipment_costed,NULL,NULL,txngt.shipment_costed))
                                                        from gmf_inv_Txn_flags_gt txngt
                                                       where mmt.transaction_id = txngt.transaction_id)
                , program_update_date   = SYSDATE
                /* Vpedarla bug: 9292668 commenting last_updated_by and last_update_login update*/
               -- , last_updated_by       = g_user_id
               -- , last_update_login     = g_login_id
                , program_application_id= g_prog_appl_id
                , program_id            = g_program_id
                , request_id            = g_request_id
          where transaction_id IN (select txngt.transaction_id from gmf_inv_Txn_flags_gt txngt);


          g_log_msg := sql%rowcount || ' rows of Inv Transactions updated to set OPM_costed_flag and shipment_costed flag in mtl_material_transactions table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
            );
          END IF;

      ELSE
        g_log_msg := 'Invalid event passed';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;
        RETURN;
    END CASE;

    g_log_msg := 'End of procedure ' || l_procedure_name || ' for event ' || p_event;

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

  END process_inv_txns;


/*============================================================================
 |  PROCEDURE - process_pur_txns
 |
 |  DESCRIPTION
 |    This procedure processes all inventory transactions. Right now we are
 |    using this procedure for post-processing, but we can use it for other
 |    processing events (pre-processing, extract and post-accounting).
 |
 |  PRAMETERS
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  01-Oct-2005  umoogala           Genesis
 |  27-Feb-2007  pmarada   Bug 5436974, Invoices enhancement, added code to
 |                update gmf_invoice_distributions table
 |  5-Aug-2009   pmarada bug 8642337 LCM-OPM Integration, updating LC adjustment
 |                tables  accounted flag and final accounted date.
 *===========================================================================*/
  PROCEDURE process_pur_txns(p_event VARCHAR2)
  IS
    l_procedure_name    CONSTANT  VARCHAR2(100) := 'process_pur_txns';
  BEGIN

    g_log_msg := 'Begin of procedure ' || l_procedure_name || ' for event ' || p_event;

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    CASE p_event
      WHEN G_pre_accounting
      THEN
        NULL;
      WHEN G_extract
      THEN
        NULL;
      WHEN G_post_accounting
      THEN
        NULL;
      WHEN G_post_processing
      THEN
        g_log_msg := 'Updating gmf_xla_extract_headers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        --
        -- Update extract Headers
        --
        UPDATE gmf_xla_extract_headers
           SET   accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , actual_posting_date   = DECODE(G_accounting_mode, 'F', sysdate, NULL)
               , last_update_date      = sysdate
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE (transaction_id, ledger_id, valuation_cost_type_id, event_class_code)
                  in (SELECT
                             xpae.SOURCE_ID_INT_1, xpae.SOURCE_ID_INT_2,
                             xpae.SOURCE_ID_INT_3, xpae.SOURCE_ID_CHAR_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_purchasing_transactions
                         and xpae.event_class_code = gxem.event_class_code
                     )
        ;
        g_log_msg := sql%rowcount || ' rows updated in gmf_xla_extract_headers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT  >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        --
        -- Update transaction valuation table
        --
        g_log_msg := 'Updating gmf_transaction_valuation table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        UPDATE gmf_transaction_valuation
           SET   accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , final_posting_date    = DECODE(G_accounting_mode, 'F', sysdate, NULL)
               , last_update_date      = sysdate
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE
               (transaction_id, ledger_id, valuation_cost_type_id, event_class_code)
                  in (SELECT
                             xpae.SOURCE_ID_INT_1, xpae.SOURCE_ID_INT_2,
                             xpae.SOURCE_ID_INT_3, xpae.SOURCE_ID_CHAR_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_purchasing_transactions
                         and xpae.event_class_code = gxem.event_class_code
                     )
          AND ACCOUNTED_FLAG IS NOT NULL   -- B7395353 Rajesh Patangya
        ;
        g_log_msg := sql%rowcount || ' rows updated in gmf_transaction_valuation table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        --
        -- Update transaction valuation table
        --
        g_log_msg := 'Updating mtl_material_transactions table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        UPDATE mtl_material_transactions
           SET   opm_costed_flag       = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , program_update_date   = SYSDATE /* ANTHIYAG Updating Porgram_update_date instead of Last_update_date to avoid auditing issues */
	       /* Vpedarla bug: 9292668 commenting last_updated_by and last_update_login update*/
             --  , last_updated_by       = g_user_id
             --  , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE transaction_id
                  in (SELECT
                             xpae.SOURCE_ID_INT_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_purchasing_transactions
                         and xpae.event_class_code = gxem.event_class_code
                     )
        ;

        g_log_msg := sql%rowcount || ' rows updated in mtl_material_transactions table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        /* bug 4879803 start jboppana*/

        g_log_msg := 'Updating gmf_rcv_accounting_txns table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;

          UPDATE gmf_rcv_accounting_txns
             SET    accounted_flag      = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
                 , last_update_date      = sysdate
                 , last_updated_by       = g_user_id
                 , last_update_login     = g_login_id
                 , program_application_id= g_prog_appl_id
                 , program_id            = g_program_id
                 , request_id            = g_request_id
           WHERE accounting_txn_id
                    in (SELECT
                               xpae.SOURCE_ID_INT_1
                          FROM
                               xla_post_acctg_events_v xpae,
                               gmf_xla_event_model     gxem
                         WHERE
                               gxem.process_category = G_purchasing_transactions
                           and gxem.transaction_type IN ('RECEIVING_RECEIVE','RECEIVING_DELIVER_EXPENSE',
                                                         'RECEIVING_RET_TO_VENDOR','DELIVER_EXP_RET_TO_RECEIVING',
                                                         'RECEIVING_LOG_RET_TO_VENDOR', 'RECEIVING_LOG_RECEIVE',
                                                         'RECEIVING_ADJUST_RECEIVE', 'RECEIVING_ADJUST_DELIVER')
                           and xpae.event_class_code = gxem.event_class_code
                       )
          ;

          g_log_msg := sql%rowcount || ' rows updated in gmf_rcv_accounting_txns table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;
      /* bug 4879803 end jboppana*/
       --
       -- Bug 5436974 Start Invoices enhancement pmarada
       --
      g_log_msg := 'Updating gmf_invoice_distributions table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;
            /* update the accounting  */
          UPDATE gmf_invoice_distributions SET
                 Accounted_flag = DECODE(G_accounting_mode, 'D', 'D', 'F',  NULL )
                ,final_posting_date   = DECODE (G_accounting_mode, 'F', sysdate, NULL)
                ,last_update_date      = sysdate
                ,last_updated_by       = g_user_id
                ,last_update_login     = g_login_id
                ,program_application_id= g_prog_appl_id
                ,program_id            = g_program_id
                ,request_id            = g_request_id
          WHERE distribution_id
                 IN (SELECT xpae.SOURCE_ID_INT_1
                     FROM   xla_post_acctg_events_v xpae,
                            gmf_xla_event_model     gxem
                     WHERE  gxem.process_category = G_purchasing_transactions
                       AND  gxem.transaction_type IN ('PAYABLES_INVOICE_IPV_ADJ','PAYABLES_INVOICE_ERV_ADJ')
                       AND  xpae.event_class_code = gxem.event_class_code
                      );

          g_log_msg := sql%rowcount || ' rows updated in gmf_invoice_distributions table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;
        --
        -- End bug 5436974 Invoice enhancement
        --

          -- Start LCM-OPM Integration
          -- Update gmf_lc_adj_transactions table
         g_log_msg := 'Updating gmf_lc_adj_transactions table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(
                      log_level   => g_level_statement,
                      module      => g_module_name || l_procedure_name,
                      message     => g_log_msg
                     );
          END IF;

         UPDATE gmf_lc_adj_transactions SET
               Accounted_flag = DECODE(G_accounting_mode, 'D', 'D', 'F',  NULL )
              ,final_posting_date   = DECODE (G_accounting_mode, 'F', sysdate, NULL)
              ,last_update_date      = sysdate
              ,last_updated_by       = g_user_id
              ,last_update_login     = g_login_id
              ,program_application_id= g_prog_appl_id
              ,program_id            = g_program_id
              ,request_id            = g_request_id
         WHERE adj_transaction_id
               IN (SELECT xpae.SOURCE_ID_INT_1
                   FROM   xla_post_acctg_events_v xpae,
                          gmf_xla_event_model     gxem
                   WHERE  gxem.process_category = G_purchasing_transactions
                     AND  gxem.transaction_type IN ('LC_ADJUSTMENT_EXP_DELIVER','LC_ADJUSTMENT_DELIVER','LC_ADJUSTMENT_RECEIVE')
                     AND  xpae.event_class_code = gxem.event_class_code
                    );

          g_log_msg := sql%rowcount || ' rows updated in gmf_lc_adj_transactions table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )  THEN
             FND_LOG.STRING(
                      log_level   => g_level_statement,
                      module      => g_module_name || l_procedure_name,
                      message     => g_log_msg
            );
          END IF;

            -- Update gmf_lc_actual_cost_adjs table
        g_log_msg := 'Updating gmf_lc_actual_cost_adjs table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )  THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;
        UPDATE gmf_lc_actual_cost_adjs SET
               accounted_flag = DECODE(G_accounting_mode, 'D', 'D', 'F',  NULL )
              ,final_posting_date   = DECODE (G_accounting_mode, 'F', sysdate, NULL)
              ,last_update_date      = sysdate
              ,last_updated_by       = g_user_id
              ,last_update_login     = g_login_id
              ,program_application_id= g_prog_appl_id
              ,program_id            = g_program_id
              ,request_id            = g_request_id
        WHERE adj_transaction_id
               IN (SELECT xpae.SOURCE_ID_INT_1
                   FROM   xla_post_acctg_events_v xpae,
                          gmf_xla_event_model     gxem
                   WHERE  gxem.process_category = G_purchasing_transactions
                     AND  gxem.transaction_type IN ('LC_ADJUSTMENT_VALUATION')
                     AND  xpae.event_class_code = gxem.event_class_code
                    );

          g_log_msg := sql%rowcount || ' rows updated in gmf_lc_actual_cost_adjs table';
          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )  THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;

            -- Update gmf_lc_lot_cost_adjs table
          g_log_msg := 'Updating gmf_lc_lot_cost_adjs table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )  THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;
        UPDATE gmf_lc_lot_cost_adjs SET
               accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F',  NULL )
              ,final_posting_date    = DECODE (G_accounting_mode, 'F', sysdate, NULL)
              ,last_update_date      = sysdate
              ,last_updated_by       = g_user_id
              ,last_update_login     = g_login_id
              ,program_application_id= g_prog_appl_id
              ,program_id            = g_program_id
              ,request_id            = g_request_id
        WHERE adj_transaction_id
               IN (SELECT xpae.SOURCE_ID_INT_1
                   FROM   xla_post_acctg_events_v xpae,
                          gmf_xla_event_model     gxem
                   WHERE  gxem.process_category = G_purchasing_transactions
                     AND  gxem.transaction_type IN ('LC_ADJUSTMENT_VALUATION')
                     AND  xpae.event_class_code = gxem.event_class_code
                    );

          g_log_msg := sql%rowcount || ' rows updated in gmf_lc_lot_cost_adjs table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )  THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;
        -- End LCM-OPM Integration

      ELSE
        g_log_msg := 'Invalid event passed';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;
        RETURN;
    END CASE;

    g_log_msg := 'End of procedure ' || l_procedure_name || ' for event ' || p_event;

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;
  END process_pur_txns;

/*============================================================================
 |  PROCEDURE - process_pm_txns
 |
 |  DESCRIPTION
 |    This procedure processes all inventory transactions. Right now we are
 |    using this procedure for post-processing, but we can use it for other
 |    processing events (pre-processing, extract and post-accounting).
 |
 |  PRAMETERS
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  01-Oct-2005  umoogala           Genesis
 *===========================================================================*/
  PROCEDURE process_pm_txns(p_event VARCHAR2)
  IS
    l_procedure_name  CONSTANT  VARCHAR2(100) := 'process_pm_txns';
  BEGIN

    g_log_msg := 'Begin of procedure ' || l_procedure_name || ' for event ' || p_event;

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    CASE p_event
      WHEN G_pre_accounting
      THEN
        NULL;
      WHEN G_extract
      THEN
        NULL;
      WHEN G_post_accounting
      THEN
        NULL;
      WHEN G_post_processing
      THEN
        g_log_msg := 'Updating gmf_xla_extract_headers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        --
        -- Update extract Headers
        --
        UPDATE gmf_xla_extract_headers
           SET   accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , actual_posting_date   = DECODE(G_accounting_mode, 'F', sysdate, NULL)
               , last_update_date      = sysdate
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE (transaction_id, ledger_id, valuation_cost_type_id, event_class_code)
                  in (SELECT
                             xpae.SOURCE_ID_INT_1, xpae.SOURCE_ID_INT_2,
                             xpae.SOURCE_ID_INT_3, xpae.SOURCE_ID_CHAR_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_production_transactions
                         and xpae.event_class_code = gxem.event_class_code
                     )
        ;
        g_log_msg := sql%rowcount || ' rows updated in gmf_xla_extract_headers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT  >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        --
        -- Update transaction valuation table
        --
        g_log_msg := 'Updating gmf_transaction_valuation table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        UPDATE gmf_transaction_valuation
           SET   accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , final_posting_date    = DECODE(G_accounting_mode, 'F', sysdate, NULL)
               , last_update_date      = sysdate
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE
               (transaction_id, ledger_id, valuation_cost_type_id, event_class_code)
                  in (SELECT
                             xpae.SOURCE_ID_INT_1, xpae.SOURCE_ID_INT_2,
                             xpae.SOURCE_ID_INT_3, xpae.SOURCE_ID_CHAR_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_production_transactions
                         and xpae.event_class_code = gxem.event_class_code
                     )
          AND ACCOUNTED_FLAG IS NOT NULL   -- B7395353 Rajesh Patangya
        ;
        g_log_msg := sql%rowcount || ' rows updated in gmf_transaction_valuation table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        --
        -- Update material transaction table
        --
        g_log_msg := 'Updating mtl_material_transactions table for batch material transactions';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        UPDATE mtl_material_transactions
           SET   opm_costed_flag       = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , program_update_date   = SYSDATE /* ANTHIYAG Updating Porgram_update_date instead of Last_update_date to avoid auditing issues */
	       /* Vpedarla bug: 9292668 commenting last_updated_by and last_update_login update*/
             --  , last_updated_by       = g_user_id
             --  , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE transaction_id
                  in (SELECT
                             xpae.SOURCE_ID_INT_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_production_transactions
                         and gxem.event_class_code = G_batch_material
                         and xpae.event_class_code = gxem.event_class_code
                     )
        ;

        g_log_msg := sql%rowcount || ' rows updated in mtl_material_transactions table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        --
	-- BatchesXperiods Enh. 12.0.1. - umoogala - Feb 2007
        -- Update incoming layers table
        --
        g_log_msg := 'Updating gmf_incoming_material_layers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        UPDATE gmf_incoming_material_layers
           SET   accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , actual_posting_date   = DECODE(G_accounting_mode, 'F', sysdate, NULL)
               , last_update_date      = sysdate
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
         WHERE (mmt_transaction_id)
                  in (SELECT
                             xpae.SOURCE_ID_INT_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_production_transactions
                         and xpae.event_class_code = gxem.event_class_code
                     )
        ;

        g_log_msg := sql%rowcount || ' rows updated in gmf_incoming_material_layers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;
	-- End BatchesXperiods Enh. 12.0.1. - umoogala - Feb 2007


        IF G_accounting_mode = 'F'
        THEN

          --
          -- Update resource transaction table
          -- Decide what Flag to use when run in Draft Mode.
          --
          g_log_msg := 'Updating gme_resource_txns table for batch material transactions';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;

          UPDATE gme_resource_txns
             SET   posted_ind            = DECODE(G_accounting_mode, 'D', posted_ind, 'F', 1)
                 , last_update_date      = sysdate
                 , last_updated_by       = g_user_id
                 , last_update_login     = g_login_id
                 , program_application_id= g_prog_appl_id
                 , program_id            = g_program_id
                 , request_id            = g_request_id
           WHERE poc_trans_id
                    in (SELECT
                               xpae.SOURCE_ID_INT_1
                          FROM
                               xla_post_acctg_events_v xpae,
                               gmf_xla_event_model     gxem
                         WHERE
                               gxem.process_category = G_production_transactions
                           and gxem.event_class_code = G_batch_resource
                           and xpae.event_class_code = gxem.event_class_code
                       )
          ;

          g_log_msg := sql%rowcount || ' rows updated in gme_resource_txns table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;


          --
          -- Update Batch Header table
          --
          g_log_msg := 'Updating gme_batch_header table for batch material transactions';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;

          UPDATE gme_batch_header
             SET   gl_posted_ind         = DECODE(G_accounting_mode, 'D', gl_posted_ind, 'F', 1)
                 , last_update_date      = sysdate
                 , last_updated_by       = g_user_id
                 , last_update_login     = g_login_id
           WHERE batch_id
                    in (SELECT
                               xpae.SOURCE_ID_INT_1
                          FROM
                               xla_post_acctg_events_v xpae,
                               gmf_xla_event_model     gxem
                         WHERE
                               gxem.process_category = G_production_transactions
                           and gxem.event_class_code = g_batch_close
                           and xpae.event_class_code = gxem.event_class_code
                       )
          ;

          g_log_msg := sql%rowcount || ' rows updated in gme_batch_header table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;

        END IF;

      ELSE
        g_log_msg := 'Invalid event passed';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;
        RETURN;
    END CASE;

    g_log_msg := 'End of procedure ' || l_procedure_name || ' for event ' || p_event;

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;
  END process_pm_txns;

/*============================================================================
 |  PROCEDURE - process_om_txns
 |
 |  DESCRIPTION
 |    This procedure processes all inventory transactions. Right now we are
 |    using this procedure for post-processing, but we can use it for other
 |    processing events (pre-processing, extract and post-accounting).
 |
 |  PRAMETERS
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  01-Oct-2005  umoogala           Genesis
 *===========================================================================*/
  PROCEDURE process_om_txns(p_event VARCHAR2)
  IS
    l_procedure_name  CONSTANT VARCHAR2(100) := 'process_om_txns';
  BEGIN

    g_log_msg := 'Begin of procedure ' || l_procedure_name || ' for event ' || p_event;

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    CASE p_event
      WHEN G_pre_accounting
      THEN
        NULL;
      WHEN G_extract
      THEN
        NULL;
      WHEN G_post_accounting
      THEN
        NULL;
      WHEN G_post_processing
      THEN
        g_log_msg := 'Updating gmf_xla_extract_headers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        --
        -- Update extract Headers
        --
        UPDATE gmf_xla_extract_headers
           SET   accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , actual_posting_date   = DECODE(G_accounting_mode, 'F', sysdate, NULL)
               , last_update_date      = sysdate
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE (transaction_id, ledger_id, valuation_cost_type_id, event_class_code)
                  in (SELECT
                             xpae.SOURCE_ID_INT_1, xpae.SOURCE_ID_INT_2,
                             xpae.SOURCE_ID_INT_3, xpae.SOURCE_ID_CHAR_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_order_management
                         and xpae.event_class_code = gxem.event_class_code
                     )
        ;
        g_log_msg := sql%rowcount || ' rows updated in gmf_xla_extract_headers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT  >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        --
        -- Update transaction valuation table
        --
        g_log_msg := 'Updating gmf_transaction_valuation table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        UPDATE gmf_transaction_valuation
           SET   accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , final_posting_date    = DECODE(G_accounting_mode, 'F', sysdate, NULL)
               , last_update_date      = sysdate
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE
               (transaction_id, ledger_id, valuation_cost_type_id, event_class_code)
                  in (SELECT
                             xpae.SOURCE_ID_INT_1, xpae.SOURCE_ID_INT_2,
                             xpae.SOURCE_ID_INT_3, xpae.SOURCE_ID_CHAR_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_order_management
                         and xpae.event_class_code = gxem.event_class_code
                     )
          AND ACCOUNTED_FLAG IS NOT NULL   -- B7395353 Rajesh Patangya
        ;
        g_log_msg := sql%rowcount || ' rows updated in gmf_transaction_valuation table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        --
        -- Update transaction valuation table
        --
        g_log_msg := 'Updating mtl_material_transactions table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        UPDATE mtl_material_transactions
           SET   opm_costed_flag       = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , program_update_date   = SYSDATE /* ANTHIYAG Updating Porgram_update_date instead of Last_update_date to avoid auditing issues */
	       /* Vpedarla bug: 9292668 commenting last_updated_by and last_update_login update*/
              -- , last_updated_by       = g_user_id
              -- , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE transaction_id
                  in (SELECT
                             xpae.SOURCE_ID_INT_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_order_management
                         and xpae.event_class_code = gxem.event_class_code
                     )
        ;

        g_log_msg := sql%rowcount || ' rows updated in mtl_material_transactions table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        --
        -- Update cst_cogs_events table
        --
        g_log_msg := 'Updating cst_cogs_events table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        /* Set the costed flag in cst_cogs_events SO issues */
        /* xxx - REMOVE the comments. NOT code.
        UPDATE cst_cogs_events
           SET costed                 = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
             , last_update_date       = sysdate
	           , last_updated_by        = g_user_id
	           , last_update_login      = g_login_id
	           , program_application_id = g_prog_appl_id
	           , program_id             = g_program_id
	           , request_id             = g_request_id
        WHERE
              exists (SELECT 'x'
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem,
                             gmf_xla_extract_headers eh
                       WHERE
                             eh.transaction_id         = xpae.SOURCE_ID_INT_1
                         AND eh.ledger_id              = xpae.SOURCE_ID_INT_2
                         AND eh.valuation_cost_type_id = xpae.SOURCE_ID_INT_3
                         AND eh.event_class_code       = xpae.SOURCE_ID_CHAR_1
                         AND eh.transaction_action_id  = 36
                         AND gxem.process_category     = G_order_management
                         AND xpae.event_class_code     = gxem.event_class_code
                         AND cogs_om_line_id           = eh.source_line_id
                         AND cce.mmt_transaction_id    = eh.transaction_id
                     )
        ;

        g_log_msg := sql%rowcount || ' rows updated in cst_cogs_events table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;
        --
        -- End of updates
        --
        */

      ELSE
        g_log_msg := 'Invalid event passed';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;
        RETURN;
    END CASE;

    g_log_msg := 'End of procedure ' || l_procedure_name || ' for event ' || p_event;

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

  END process_om_txns;

/*============================================================================
 |  PROCEDURE - process_cm_txns
 |
 |  DESCRIPTION
 |    This procedure processes all inventory transactions. Right now we are
 |    using this procedure for post-processing, but we can use it for other
 |    processing events (pre-processing, extract and post-accounting).
 |
 |  PRAMETERS
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  01-Oct-2005  umoogala           Genesis
 |  06-Nov-2006  ANTHIYAG           Bug#5597804
 |                                  Modified Code to Change the transaction_type to
 |                                  "LOT_COST_ADJUSTMENTS" instead of "COST_REVALUATIONS"
 |                                  to account for Lot Cost Adjustments in Final Mode.
 |  04-Mar-2008  Pramod B.H         Bug 6646395 - GL Cost Allocations enhancement
 *===========================================================================*/
  PROCEDURE process_rval_txns(p_event VARCHAR2)
  IS
    l_procedure_name    CONSTANT VARCHAR2(100) := 'process_rval_txns';
    l_cost_method_type  cm_mthd_mst.cost_type%TYPE;
  BEGIN

    g_log_msg := 'Begin of procedure ' || l_procedure_name || ' for event ' || p_event;

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;

    CASE p_event
      WHEN G_pre_accounting
      THEN
        NULL;
      WHEN G_extract
      THEN
        NULL;
      WHEN G_post_accounting
      THEN
        NULL;
      WHEN G_post_processing
      THEN
        g_log_msg := 'Updating gmf_xla_extract_headers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        --
        -- Update extract Headers
        --
        UPDATE gmf_xla_extract_headers
           SET   accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , actual_posting_date   = DECODE(G_accounting_mode, 'F', sysdate, NULL)
               , last_update_date      = sysdate
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE (transaction_id, ledger_id, valuation_cost_type_id, event_class_code)
                  in (SELECT
                             xpae.SOURCE_ID_INT_1, xpae.SOURCE_ID_INT_2,
                             xpae.SOURCE_ID_INT_3, xpae.SOURCE_ID_CHAR_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_revaluation_transactions
                         and xpae.event_class_code = gxem.event_class_code
                     )
        ;
        g_log_msg := sql%rowcount || ' rows updated in gmf_xla_extract_headers table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT  >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        --
        -- Update transaction valuation table
        --
        g_log_msg := 'Updating gmf_transaction_valuation table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        UPDATE gmf_transaction_valuation
           SET   accounted_flag        = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
               , final_posting_date    = DECODE(G_accounting_mode, 'F', sysdate, NULL)
               , last_update_date      = sysdate
               , last_updated_by       = g_user_id
               , last_update_login     = g_login_id
               , program_application_id= g_prog_appl_id
               , program_id            = g_program_id
               , request_id            = g_request_id
         WHERE
               (transaction_id, ledger_id, valuation_cost_type_id, event_class_code)
                  in (SELECT
                             xpae.SOURCE_ID_INT_1, xpae.SOURCE_ID_INT_2,
                             xpae.SOURCE_ID_INT_3, xpae.SOURCE_ID_CHAR_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_revaluation_transactions
                         and xpae.event_class_code = gxem.event_class_code
                     )
          AND ACCOUNTED_FLAG IS NOT NULL   -- B7395353 Rajesh Patangya
        ;
        g_log_msg := sql%rowcount || ' rows updated in gmf_transaction_valuation table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;


        /*
        --
        -- Update transaction valuation table
        --
        g_log_msg := 'Updating mtl_material_transactions table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;

        UPDATE mtl_material_transactions
           SET opm_costed_flag = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
         WHERE transaction_id
                  in (SELECT
                             xpae.SOURCE_ID_INT_1
                        FROM
                             xla_post_acctg_events_v xpae,
                             gmf_xla_event_model     gxem
                       WHERE
                             gxem.process_category = G_revaluation_transactions
                         and xpae.event_class_code = gxem.event_class_code
                     )
        ;

        g_log_msg := sql%rowcount || ' rows updated in mtl_material_transactions table';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;
        */

        SELECT cost_type
          INTO l_cost_method_type
          FROM cm_mthd_mst
         WHERE cost_type_id = (SELECT xpae.SOURCE_ID_INT_3
                                 FROM xla_post_acctg_events_v xpae
                                WHERE rownum = 1)
        ;

        --
        -- Now for lot cost method, update gmf_lot_cost_adjustmets table
        -- For Actual/Standard methods, update gmf_period_balances table.
        --

        IF l_cost_method_type = 6
           -- Lot Cost Method
        THEN
          --
          -- Update transaction valuation table
          --
          g_log_msg := 'Updating gmf_lot_cost_adjustments table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;

          UPDATE gmf_lot_cost_adjustments
             SET   gl_posted_ind      = DECODE(G_accounting_mode, 'D', gl_posted_ind, 'F', 1)
                 , last_update_date      = sysdate
                 , last_updated_by       = g_user_id
                 , last_update_login     = g_login_id
                 , program_application_id= g_prog_appl_id
                 , program_id            = g_program_id
                 , request_id            = g_request_id
           WHERE adjustment_id
                    in (SELECT
                               xpae.SOURCE_ID_INT_1
                          FROM
                               xla_post_acctg_events_v xpae,
                               gmf_xla_event_model     gxem
                         WHERE
                               gxem.process_category = G_revaluation_transactions
                           and gxem.transaction_type = 'LOT_COST_ADJUSTMENTS' /* Bug#5597804 ANTHIYAG 06-Nov-2006 */
                           and xpae.event_class_code = gxem.event_class_code
                       )
          ;

          g_log_msg := sql%rowcount || ' rows updated in gmf_lot_cost_adjustments table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;

        ELSE
          --
          -- Actual/Standard Cost Methods
          --
          -- Update transaction valuation table
          --
          g_log_msg := 'Updating gmf_period_balances table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;

          UPDATE gmf_period_balances
             SET   costed_flag           = DECODE(G_accounting_mode, 'D', 'D', 'F', NULL)
                 , last_update_date      = sysdate
                 , last_updated_by       = g_user_id
                 , last_update_login     = g_login_id
                 , program_application_id= g_prog_appl_id
                 , program_id            = g_program_id
                 , request_id            = g_request_id
           WHERE period_balance_id
                    in (SELECT
                               xpae.SOURCE_ID_INT_1
                          FROM
                               xla_post_acctg_events_v xpae,
                               gmf_xla_event_model     gxem
                         WHERE
                               gxem.process_category = G_revaluation_transactions
                           and gxem.transaction_type = 'COST_REVALUATIONS' /*changed LOT_COST_ADJUSTMENTS to COST_REVALUATIONS jboppana*/
                           and xpae.event_class_code = gxem.event_class_code
                       )
          ;

          g_log_msg := sql%rowcount || ' rows updated in gmf_period_balances table';

          print_debug(g_log_msg);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
          THEN
            FND_LOG.STRING(
                     log_level   => g_level_statement,
                     module      => g_module_name || l_procedure_name,
                     message     => g_log_msg
            );
          END IF;

        /* for actual cost adjustments enhancement jboppana start*/
          IF l_cost_method_type = 1 THEN
                g_log_msg := 'Updating cm_adjs_dtl table';

                print_debug(g_log_msg);
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
                THEN
                  FND_LOG.STRING(
                           log_level   => g_level_statement,
                           module      => g_module_name || l_procedure_name,
                           message     => g_log_msg
                  );
                END IF;

                UPDATE cm_adjs_dtl
                   SET   gl_posted_ind      = DECODE(G_accounting_mode, 'D', gl_posted_ind, 'F', 1)
                       , last_update_date      = sysdate
                       , last_updated_by       = g_user_id
                       , last_update_login     = g_login_id
                       , program_application_id= g_prog_appl_id
                       , program_id            = g_program_id
                       , request_id            = g_request_id
                   WHERE cost_adjust_id
                    in (SELECT
                               xpae.SOURCE_ID_INT_1
                          FROM
                               xla_post_acctg_events_v xpae,
                               gmf_xla_event_model     gxem
                         WHERE
                               gxem.process_category = G_revaluation_transactions
                           and gxem.transaction_type = 'ACTUAL_COST_ADJUSTMENTS'
                           and xpae.event_class_code = gxem.event_class_code
                       )
                    ;

                g_log_msg := sql%rowcount || ' rows updated in cm_adjs_dtl table';

                print_debug(g_log_msg);
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
                THEN
                  FND_LOG.STRING(
                           log_level   => g_level_statement,
                           module      => g_module_name || l_procedure_name,
                           message     => g_log_msg
                  );
                END IF;


          END IF;
          /* for actual cost adjustments enhancement jboppana end*/

          /* Bug 6646395 - GL Cost Allocations enhancement phiriyan start*/
          IF l_cost_method_type = 1 THEN
                g_log_msg := 'Updating gl_aloc_dtl table';

                print_debug(g_log_msg);
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
                THEN
                  FND_LOG.STRING(
                           log_level   => g_level_statement,
                           module      => g_module_name || l_procedure_name,
                           message     => g_log_msg
                  );
                END IF;

                UPDATE gl_aloc_dtl
                   SET   gl_posted_ind      = DECODE(G_accounting_mode, 'D', gl_posted_ind, 'F', 1)
                       , last_update_date      = sysdate
                       , last_updated_by       = g_user_id
                       , last_update_login     = g_login_id
                       , program_application_id= g_prog_appl_id
                       , program_id            = g_program_id
                       , request_id            = g_request_id
                   WHERE allocdtl_id
                    in (SELECT
                               xpae.SOURCE_ID_INT_1
                          FROM
                               xla_post_acctg_events_v xpae,
                               gmf_xla_event_model     gxem
                         WHERE
                               gxem.process_category = G_revaluation_transactions
                           and gxem.transaction_type = 'GL_COST_ALLOCATIONS'
                           and xpae.event_class_code = gxem.event_class_code
                       )
                    ;

                g_log_msg := sql%rowcount || ' rows updated in gl_aloc_dtl table';

                print_debug(g_log_msg);
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
                THEN
                  FND_LOG.STRING(
                           log_level   => g_level_statement,
                           module      => g_module_name || l_procedure_name,
                           message     => g_log_msg
                  );
                END IF;


          END IF;
          /* Bug 6646395 - GL Cost Allocations enhancement phiriyan end*/
        END IF; -- Actual/Standard Cost Methods

      ELSE

        g_log_msg := 'Invalid event passed';

        print_debug(g_log_msg);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(
                   log_level   => g_level_statement,
                   module      => g_module_name || l_procedure_name,
                   message     => g_log_msg
          );
        END IF;
        RETURN;
    END CASE;

    g_log_msg := 'End of procedure ' || l_procedure_name || ' for event ' || p_event;

    print_debug(g_log_msg);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL )
    THEN
      FND_LOG.STRING(
               log_level   => g_level_statement,
               module      => g_module_name || l_procedure_name,
               message     => g_log_msg
      );
    END IF;
  END process_rval_txns;

---------------------------------------------------------------------------
-- PROCEDURE:  DRILLDOWN
-- COMMENT:    DRILLDOWN procedure provides a public API for sla to return
--             the appropriate information via OUT parameters to open the
--             appropriate transaction form.
-- PARAMETERS:
--   p_application_id     : Subledger application internal identifier
--   p_ledger_id          : Event ledger identifier
--   p_legal_entity_id    : Legal entity identifier
--   p_entity_code        : Event entity internal code
--   p_event_class_code   : Event class internal code
--   p_event_type_code    : Event type internal code
--   p_source_id_int_1    : Generic system transaction identifiers
--   p_source_id_int_2    : Generic system transaction identifiers
--   p_source_id_int_3    : Generic system transaction identifiers
--   p_source_id_int_4    : Generic system transaction identifiers
--   p_source_id_char_1   : Generic system transaction identifiers
--   p_source_id_char_2   : Generic system transaction identifiers
--   p_source_id_char_3   : Generic system transaction identifiers
--   p_source_id_char_4   : Generic system transaction identifiers
--   p_security_id_int_1  : Generic system transaction identifiers
--   p_security_id_int_2  : Generic system transaction identifiers
--   p_security_id_int_3  : Generic system transaction identifiers
--   p_security_id_char_1 : Generic system transaction identifiers
--   p_security_id_char_2 : Generic system transaction identifiers
--   p_security_id_char_3 : Generic system transaction identifiers
--   p_valuation_method   : Valuation Method internal identifier
--   p_user_interface_type: This parameter determines the user interface type.
--                          The possible values are FORM, HTML, or NONE.
--   p_function_name      : The name of the Oracle Application Object
--                          Library function defined to open the transaction
--                          form. This parameter is used only if the page
--                          is a FORM page.
--   p_parameters         : An Oracle Application Object Library Function
--                          can have its own arguments/parameters. SLA
--                          expects developers to return these arguments via
--                          p_parameters.
--
---------------------------------------------------------------------------

   PROCEDURE DRILLDOWN
   (
     p_application_id      IN            INTEGER
   , p_ledger_id           IN            INTEGER
   , p_legal_entity_id     IN            INTEGER DEFAULT NULL
   , p_entity_code         IN            VARCHAR2
   , p_event_class_code    IN            VARCHAR2
   , p_event_type_code     IN            VARCHAR2
   , p_source_id_int_1     IN            INTEGER DEFAULT NULL
   , p_source_id_int_2     IN            INTEGER DEFAULT NULL
   , p_source_id_int_3     IN            INTEGER DEFAULT NULL
   , p_source_id_int_4     IN            INTEGER DEFAULT NULL
   , p_source_id_char_1    IN            VARCHAR2 DEFAULT NULL
   , p_source_id_char_2    IN            VARCHAR2 DEFAULT NULL
   , p_source_id_char_3    IN            VARCHAR2 DEFAULT NULL
   , p_source_id_char_4    IN            VARCHAR2 DEFAULT NULL
   , p_security_id_int_1   IN            INTEGER DEFAULT NULL
   , p_security_id_int_2   IN            INTEGER DEFAULT NULL
   , p_security_id_int_3   IN            INTEGER DEFAULT NULL
   , p_security_id_char_1  IN            VARCHAR2 DEFAULT NULL
   , p_security_id_char_2  IN            VARCHAR2 DEFAULT NULL
   , p_security_id_char_3  IN            VARCHAR2 DEFAULT NULL
   , p_valuation_method    IN            VARCHAR2 DEFAULT NULL
   , p_user_interface_type IN OUT NOCOPY VARCHAR2
   , p_function_name       IN OUT NOCOPY VARCHAR2
   , p_parameters          IN OUT NOCOPY VARCHAR2
   )
   IS
      l_security_id_int_1     BINARY_INTEGER;
      l_source_id_int_1       BINARY_INTEGER;
      l_form_usage_mode	      CONSTANT VARCHAR2(30) := 'SLA_DRILLDOWN';
      l_batch_id              BINARY_INTEGER;
      l_batchstep_id          BINARY_INTEGER;
      l_resource              VARCHAR2(16);
      l_batchstep_activity_id BINARY_INTEGER;
      l_batchstep_resource_id BINARY_INTEGER;
      l_process_param_id      BINARY_INTEGER;
      l_ship_header_id        BINARY_INTEGER;
      l_ship_line_id          BINARY_INTEGER;

   BEGIN
      -- To check whether the application is GMF
      IF (p_application_id = 555)
      THEN
        IF (p_entity_code in ('INVENTORY', 'ORDERMANAGEMENT') OR
           (p_entity_code = 'PRODUCTION' AND p_event_class_code = 'BATCH_MATERIAL')
           )
        THEN
          --
          -- Should open Material Transactions form
          -- p_source_id_int_1: mmt.transaction_id
          -- p_security_id_int_1: organization_id
          --
          p_user_interface_type := 'FORM';
          p_function_name       := 'CST_INVTVTXN';

          IF (p_event_class_code = 'FOB_SHIP_RECIPIENT_SHIP') OR
             (p_event_class_code = 'FOB_RCPT_SENDER_RCPT')
          THEN
            SELECT organization_id
              INTO l_security_id_int_1
              FROM mtl_material_transactions
             WHERE transaction_id = p_source_id_int_1;
          ELSE
            l_security_id_int_1 := p_security_id_int_1;
          END IF;

          p_parameters := ' FORM_USAGE_MODE="'||l_form_usage_mode||'"'
                          ||' INVTVTXN_GO_DETAIL="Y"'
                          ||' INVTVTXN_TRXN_ID="' || to_char(p_source_id_int_1)||'"'
                          ||' ORG_ID="'||to_char(l_security_id_int_1)||'"';

        ELSIF (p_entity_code = 'PURCHASING')
        THEN

          --
          -- Should open Receiving Transactions form
          -- p_source_id_int_1: mmt.transaction_id
          -- p_security_id_int_1: organization_id
          --
          IF p_event_class_code = 'DELIVER'
          THEN
            SELECT rcv_transaction_id
              INTO l_source_id_int_1
              FROM mtl_material_transactions
             WHERE transaction_id = p_source_id_int_1
            ;
          ELSIF p_event_class_code = 'RECEIVE'
          THEN
	    --
	    -- Bug 5668308: p_source_id_int_1 is grat id. So, get the
	    -- rcv transaction id.
	    --
            -- l_source_id_int_1 := p_source_id_int_1;
	    --
	    SELECT event_source_id
	      INTO l_source_id_int_1
	      FROM gmf_rcv_accounting_txns
	     WHERE accounting_txn_id = p_source_id_int_1;

          ELSIF p_event_class_code='PAYABLES_INVOICE'  THEN
                 RETURN;
          END IF;

          IF p_event_class_code IN ('RECEIVE', 'DELIVER') THEN
             p_user_interface_type := 'FORM';
             p_function_name       := 'RCV_RCVRCVRC';
             p_parameters          := ' FORM_USAGE_MODE="'||l_form_usage_mode||'"'
				                           ||' TRANSACTION_ID="' || to_char(l_source_id_int_1)||'"'
				                           ||' MO_ORG_ID="'||to_char(p_security_id_int_2)||'"'
				                           ||' ORG_ID="'||to_char(p_security_id_int_1)||'"';
               /* LCM-OPM Integration pmarada */
          ELSIF p_event_class_code IN ('LC_ADJUST_RECEIVE','LC_ADJUST_DELIVER','LC_ADJUST_EXP_DELIVER','LC_ADJUST_VALUATION')
          THEN
              /* invoke View landed costs page for LCM shipment header and LCM shipment line */
             SELECT  ship_header_id,
                     ship_line_id
               INTO  l_ship_header_id,
                     l_ship_line_id
               FROM  gmf_lc_adj_transactions
              WHERE  adj_transaction_id = p_source_id_int_1;

               /* invoke view landed costs page */
               p_user_interface_type := 'HTML';
               p_function_name       := 'INL_VIEW_LC';
               p_parameters          :=  ' shipHeaderId="'|| l_ship_header_id ||'"'
                                       ||' callerUrlGridPage="' || ''||'"'
                                       ||' returnLinkGridText="' || 'INL_RETURN_REF_SHIP'||'"'
				                      ||' fromPage="'||''||'"';

             /* End LCM-OPM Integration pmarada */
          ELSE
             p_user_interface_type := 'NONE';
          END IF;

        ELSIF (p_entity_code = 'PRODUCTION')
        THEN

          IF p_event_class_code = 'BATCH_RESOURCE'
          THEN
            --
            -- Should open Resource Transactions window in Batch Steps form
            -- p_source_id_int_1: gme_resource_txns.poc_trans_id
            -- p_security_id_int_1: organization_id
            --

            SELECT a.batch_id,
                   a.batchstep_id,
                   grt.resources,
                   a.batchstep_activity_id,
                   a.batchstep_resource_id
              INTO l_batch_id,
                   l_batchstep_id,
                   l_resource,
                   l_batchstep_activity_id,
                   l_batchstep_resource_id
            FROM  gme_batch_step_resources a,
                  gme_resource_txns grt
            WHERE grt.poc_trans_id = p_source_id_int_1
               AND grt.line_id     = a.batchstep_resource_id;

            p_user_interface_type := 'FORM';
            p_function_name       := 'GMESTPED_F';

            p_parameters := ' FORMS_USAGE_MODE="'||l_form_usage_mode||'"'
                       ||' ORG_ID="'||to_char(p_security_id_int_1) ||'"'
                       ||' BATCH_ID="'||to_char(l_batch_id)||'"'
                       ||' BATCHSTEP_ID="'||to_char(l_batchstep_id)||'"'
                       ||' BATCHSTEP_ACTIVITY_ID="'||to_char(l_batchstep_activity_id) ||'"'
                       ||' BATCHSTEP_RESOURCE_ID="'||to_char(l_batchstep_resource_id)||'"'
                       ||' RESOURCES="'||to_char(l_resource) ||'"'||' QUERY_ONLY="'||'YES'||'"';

          ELSIF p_event_class_code = 'BATCH_CLOSE'
          THEN
            --
            -- Should open Batch Details form
            -- p_source_id_int_1: gme_batch_header.batch_id
            -- p_security_id_int_1: organization_id
            --
            p_user_interface_type := 'FORM';
            p_function_name       := 'GMEBDTED_F';

            p_parameters          := ' QUERY_ONLY="'||'Y'||'"'||' BATCH_ID="' || to_char(p_source_id_int_1)||'"'
				             ||' ORG_ID="'||to_char(p_security_id_int_1)||'"';
          END IF;
        ELSIF (p_entity_code = 'REVALUATION')
        THEN

          --
          -- Should open Lot Cost Adjustment form
          -- p_source_id_int_1: adjustment_id
          -- p_security_id_int_1: organization_id
          --
          IF p_event_class_code = 'LOTCOSTADJ'
          THEN

            p_user_interface_type := 'FORM';
            p_function_name       := 'GMFLCADJ_F';
            p_parameters          :=  ' QUERY_ONLY="'||'Y'||'"'
                                      ||' ADJUSTMENT_ID="' || to_char(p_source_id_int_1)||'"'
				                      ||' ORG_ID="'||to_char(p_security_id_int_1)||'"';
          ELSE
            p_user_interface_type := 'NONE';
          END IF;

        ELSE
            p_user_interface_type := 'NONE';
        END IF;
      END IF;
   END DRILLDOWN;

END GMF_XLA_PKG;

/
