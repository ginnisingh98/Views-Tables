--------------------------------------------------------
--  DDL for Package Body FA_XLA_EXTRACT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_EXTRACT_UTIL_PKG" AS
/* $Header: FAXLAXUB.pls 120.25.12010000.7 2009/10/29 12:45:46 bridgway ship $ */

G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_extract_util_pkg.';

----------------------------------------------------------------------------------
-- Check Events
--  This is called at the beginning to determine the books,
--  entities and event types in the xla GT table.
--  Allows us to skip over inserts which are not needed
--
--------------------------------------------------------------------------------

PROCEDURE check_events IS

   TYPE tab_varchar  IS TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;

   t_book_type_code     tab_varchar;
   t_event_type_code    tab_varchar;
   t_entity_code        tab_varchar;

   l_last_book_used     FA_BOOK_CONTROLS.Book_Type_Code%TYPE := ' ';

   cursor c_events is
   select distinct valuation_method,
          ENTITY_CODE,
          EVENT_TYPE_CODE
     from xla_events_gt;

   l_procedure_name  varchar2(80) := 'check_events';

begin

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');

   END IF;

   -- reset globals to false

   G_trx_exists            := false;
   G_inter_trx_exists      := false;
   G_dep_exists            := false;
   G_def_exists            := false;

   G_fin_trx_exists        := false;
   G_xfr_trx_exists        := false;
   G_dist_trx_exists       := false;
   G_ret_trx_exists        := false;
   G_res_trx_exists        := false;
   G_deprn_exists          := false;
   G_rollback_deprn_exists := false;

   G_alc_enabled           := false;
   G_group_enabled         := false;
   G_sorp_enabled          := false;

   open c_events;
   fetch c_events BULK COLLECT
    into t_book_type_code,
         t_entity_code,
         t_event_type_code;
   close c_events;

   for i in 1..t_book_type_code.count loop

      if (t_book_type_code(i) <> l_last_book_used or
          i = 1) then
         if not fa_cache_pkg.fazcbc (t_book_type_code(i)) then
            null;
         end if;

         if (nvl(fa_cache_pkg.fazcbc_record.mc_source_flag, 'N') = 'Y') then
            G_alc_enabled := true;
         end if;

         if (nvl(fa_cache_pkg.fazcbc_record.allow_group_deprn_flag, 'N') = 'Y') then
            G_group_enabled := true;
         end if;

         if (nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag, 'N') = 'Y') then
            G_sorp_enabled := true;
         end if;

         l_last_book_used := t_book_type_code(i);

      end if;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        't_entity_code(i): ' || t_entity_code(i));
      END IF;

      if (t_entity_code(i)    = 'TRANSACTIONS') then
         G_trx_exists := true;
      elsif (t_entity_code(i) = 'INTER_ASSET_TRANSACTIONS') then
         G_inter_trx_exists := true;
      elsif (t_entity_code(i) = 'DEPRECIATION') then
         G_dep_exists := true;
      elsif (t_entity_code(i) = 'DEFERRED_DEPRECIATION') then
         G_def_exists := true;
      else
         null;
      end if;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                  fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        't_event_type_code(i): ' || t_event_type_code(i));
      END IF;

      if (t_event_type_code(i)      in  ('ADDITIONS',      'CIP_ADDITIONS',
                                         'ADJUSTMENTS',    'CIP_ADJUSTMENTS',
                                         'CAPITALIZATION', 'REVERSE_CAPITALIZATION',
                                         'REVALUATION',    'CIP_REVALUATION',
                                         'DEPRECIATION_ADJUSTMENTS',
                                         'UNPLANNED_DEPRECIATION',
                                         'TERMINAL_GAIN_LOSS',
                                         'RETIREMENT_ADJUSTMENTS',
                                         'IMPAIRMENT')) then
         G_fin_trx_exists := true;
      elsif (t_event_type_code(i) in ('TRANSFERS', 'CIP_TRANSFERS')) then
         G_xfr_trx_exists := true;
      elsif (t_event_type_code(i) in ('CATEGORY_RECLASS', 'CIP_CATEGORY_RECLASS',
                                      'UNIT_ADJUSTMENTS', 'CIP_UNIT_ADJUSTMENTS')) then
         G_dist_trx_exists := true;
      elsif (t_event_type_code(i) in ('RETIREMENTS', 'CIP_RETIREMENTS')) then
         G_ret_trx_exists := true;
      elsif (t_event_type_code(i) in ('REINSTATEMENTS','CIP_REINSTATEMENTS')) then
         G_res_trx_exists := true;
      elsif (t_event_type_code(i) = 'DEPRECIATION') then
         G_deprn_exists := true;
      elsif (t_event_type_code(i) = 'ROLLBACK_DEPRECIATION') then
         G_rollback_deprn_exists := true;
      else
         null;
      end if;
   end loop;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');

   END IF;

EXCEPTION
   WHEN others THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        raise;

end check_events;

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--
-- Main Locking program
--  This is the stub called from the locking_status subscription routine
--
-- NOTE: only certain events/transactions need locking as most transactions
--       in assets can't be undone / deleted / updated
--
--       Requiring locking: Deprn, Retirements, Additions (unprocessed)
--
--------------------------------------------------------------------------------

PROCEDURE lock_assets
           (p_book_type_code  varchar2,
            p_ledger_id       number) IS

   l_procedure_name  varchar2(80) := 'lock_assets';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');

   END IF;

   if (p_book_type_code is null) then
      update fa_book_controls
         set create_accounting_request_id = fnd_global.conc_request_id
       where set_of_books_id = p_ledger_id
         and book_class <> 'BUDGET';
   else
      update fa_book_controls
         set create_accounting_request_id = fnd_global.conc_request_id
       where book_type_code = p_book_type_code;
   end if;

   commit;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');

   END IF;

   return;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RAISE;

END lock_assets;

--------------------------------------------------------------------------------
--
-- Main UnLocking program
--  This is the stub called from the locking_status subscription routine
--
-- NOTE: only certain events/transactions need locking as most transactions
--       in assets can't be undone / deleted / updated
--
--       Requiring locking: Deprn, Retirements, Additions (unprocessed)
--
--------------------------------------------------------------------------------

PROCEDURE unlock_assets
           (p_book_type_code  varchar2,
            p_ledger_id       number) IS

   l_procedure_name  varchar2(80) := 'unlock_assets';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');

   END IF;

   if (p_book_type_code is null) then
      update fa_book_controls
         set create_accounting_request_id = null
       where set_of_books_id = p_ledger_id
         and book_class <> 'BUDGET';
   else
      update fa_book_controls
         set create_accounting_request_id = null
       where book_type_code = p_book_type_code;
   end if;

   commit;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');

   END IF;

   return;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RAISE;

END unlock_assets;



--------------------------------------------------------------------------------
--
-- Main nonaccountable events program
--  This is the stub called from the preaccounting subscription routine
--
--------------------------------------------------------------------------------

PROCEDURE update_nonaccountable_events
            (p_book_type_code   varchar2,
             p_process_category varchar2,
             p_ledger_id        number) IS

   l_appl_id         number := 140;
   l_entity_code     varchar2(30);

   l_trx             number;
   l_trx_count       number;
   l_inter_trx_count number;

   l_procedure_name  varchar2(80) := 'update_nonaccountable_events';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');

   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_book_type_code: ' || p_book_type_code);
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_ledger_id: ' || to_char(p_ledger_id));
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_process_category: ' || p_process_category);

   END IF;

   BEGIN

      select 1
        into l_trx
        from dual
       where exists(
             select 1
               from xla_event_class_attrs
              where application_id = 140
                and entity_code in ('TRANSACTIONS', 'INTER_ASSET_TRANSACTIONS')
                and EVENT_CLASS_GROUP_CODE = nvl(p_process_category,
                                                 EVENT_CLASS_GROUP_CODE));

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            l_trx := 0;
       WHEN OTHERS THEN
            l_trx := 0;
   END;

   if (l_trx <> 0) then
      -- BUG# 4439932
      -- the following is for setting status on non-accountable events

      insert into xla_events_int_gt
        (event_id,
         event_status_code,
         application_id,
         ledger_id,
         entity_code,
         valuation_method)
      select /*+ leading(EV,TE) use_nl(EV TE TH BC) */
             ev.event_id,
             'N',
             140,
             bc.set_of_books_id,
             'TRANSACTIONS',
             bc.book_type_code
        from xla_transaction_entities te,
             xla_events               ev,
             fa_transaction_headers   th,
             fa_book_controls         bc
       where te.application_id            = l_appl_id
         and te.ledger_id                 = p_ledger_id
         and te.entity_code               = 'TRANSACTIONS'
         and te.valuation_method          = nvl(p_book_type_code, te.valuation_method)
         and ev.application_id            = l_appl_id
         and ev.process_status_code      in ('U','I','E')
         and ev.event_status_code         = 'U'
         and ev.entity_id                 = te.entity_id
         and th.transaction_header_id     = te.source_id_int_1
         and bc.book_type_code            = te.source_id_char_1
         and bc.set_of_books_id           = te.ledger_id
         and not exists
             (select /*+ no_unnest */ 1
                from fa_adjustments adj
               where adj.transaction_header_id        = th.transaction_header_id
                 and adj.book_type_code               = bc.book_type_code
                 and adj.adjustment_amount           <> 0
                 and nvl(adj.track_member_flag, 'N') <> 'Y')
         and not exists
             (select /*+ no_unnest index(adj FA_ADJUSTMENTS_U1) */ 1
                from fa_adjustments         adj,
                     fa_transaction_headers th2
               where th2.member_transaction_header_id = th.transaction_header_id
                 and adj.transaction_header_id        = th2.transaction_header_id
                 and adj.book_type_code               = bc.book_type_code
                 and adj.adjustment_amount           <> 0
                 and nvl(adj.track_member_flag, 'N') <> 'Y');

      l_trx_count := SQL%ROWCOUNT;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into gt for non-accountable - trx: ' || to_char(l_trx_count));
      END IF;

      insert into xla_events_int_gt
       (event_id,
        event_status_code,
        application_id,
        ledger_id,
        entity_code,
        valuation_method)
      select /*+ leading(EV,TE) use_nl(EV TE TRX BC) */
             ev.event_id,
             'N',
             140,
             bc.set_of_books_id,
             'INTER_ASSET_TRANSACTIONS',
             bc.book_type_code
        from xla_events               ev,
             xla_transaction_entities te,
             fa_trx_references        trx,
             fa_book_controls         bc
       where te.application_id            = l_appl_id
         and te.ledger_id                 = p_ledger_id
         and te.entity_code               = 'INTER_ASSET_TRANSACTIONS'
         and te.valuation_method          = nvl(p_book_type_code, te.valuation_method)
         and ev.application_id            = l_appl_id
         and ev.process_status_code      in ('U','I','E')
         and ev.event_status_code         = 'U'
         and ev.entity_id                 = te.entity_id
         and trx.trx_reference_id         = te.source_id_int_1
         and bc.book_type_code            = te.source_id_char_1
         and bc.set_of_books_id           = te.ledger_id
         and not exists
             (select /*+ no_unnest */ 1
                from fa_adjustments         adj
               where adj.transaction_header_id       in
                     (trx.src_transaction_header_id, trx.dest_transaction_header_id)
                 and adj.book_type_code               = bc.book_type_code
                 and adj.adjustment_amount           <> 0
                 and nvl(adj.track_member_flag, 'N') <> 'Y')
         and not exists
             (select /*+ no_unnest index(adj FA_ADJUSTMENTS_U1) */ 1
                from fa_adjustments         adj,
                     fa_transaction_headers th2
               where th2.member_transaction_header_id in
                     (trx.src_transaction_header_id, trx.dest_transaction_header_id)
                 and adj.transaction_header_id        = th2.transaction_header_id
                 and adj.book_type_code               = bc.book_type_code
                 and adj.adjustment_amount           <> 0
                 and nvl(adj.track_member_flag, 'N') <> 'Y');

      l_inter_trx_count := SQL%ROWCOUNT;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into gt for non-accountable - intertrx: ' || to_char(l_inter_trx_count));
      END IF;

      if (l_trx_count       <> 0 or
          l_inter_trx_count <> 0) then
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'calling: ' || 'xla_events_pub_pkg.update_bulk_event_statuses');
         END IF;

         xla_events_pub_pkg.update_bulk_event_statuses(p_application_id => 140);
      end if;

   end if;

   commit;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');

   END IF;

   return;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RAISE;

END update_nonaccountable_events;


--------------------------------------------------------------------------------
--
-- Main Extraction program
--  This is the stub called from the extract_status subscription routine
--
-- NOTE: the accounting programs will be the one determein which
--       event classes make it into the temp table.  Thus
--       this will always run for all transactions types,
--       it just may not find any matches for some.
--
--------------------------------------------------------------------------------

PROCEDURE extract(p_accounting_mode  IN VARCHAR2) IS

   l_stmt_deprn varchar2(1000) :=
       'BEGIN fa_xla_extract_deprn_pkg.load_data; END;';
   l_stmt_def   varchar2(1000) :=
       'BEGIN fa_xla_extract_def_pkg.load_data; END;';
   l_stmt_trx   varchar2(1000) :=
       'BEGIN fa_xla_extract_trx_pkg.load_data; END;';

   l_procedure_name  varchar2(80) := 'extract';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');

   END IF;

   -- check what entities, types and books exist in the GT table
   check_events;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN

      if (G_trx_exists) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_trx_exists: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_trx_exists: false' );

      end if;

      if (G_inter_trx_exists) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_inter_trx_exists: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_inter_trx_exists: false' );

      end if;

      if (G_dep_exists) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_dep_exists: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_dep_exists: false' );

      end if;

      if (G_def_exists) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_def_exists: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_def_exists: false' );

      end if;

      if (G_fin_trx_exists) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_fin_trx_exists: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_fin_trx_exists: false' );
      end if;

      if (G_xfr_trx_exists) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_xfr_trx_exists: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_xfr_trx_exists: false' );
      end if;

      if (G_dist_trx_exists) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_dist_trx_exists: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_dist_trx_exists: false' );
      end if;

      if (G_ret_trx_exists) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_ret_trx_exists: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_ret_trx_exists: false' );
      end if;

      if (G_res_trx_exists) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_res_trx_exists: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_res_trx_exists: false' );
      end if;

      if (G_deprn_exists) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_deprn_exists: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_deprn_exists: false' );
      end if;

      if (G_rollback_deprn_exists) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_rollback_deprn_exists: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_rollback_deprn_exists: false' );
      end if;

      if (G_alc_enabled) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_alc_enabled: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_alc_enabled: false' );
      end if;

      if (G_sorp_enabled) then
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_sorp_enabled: true' );
      else
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'G_sorp_enabled: false' );
      end if;

   END IF;

   -- process trx level first (common for all trx level events)

   if (G_trx_exists or G_inter_trx_exists) then
      EXECUTE IMMEDIATE l_stmt_trx;
   end if;

   if (G_dep_exists) then
      EXECUTE IMMEDIATE l_stmt_deprn;
   end if;

   if (G_def_exists) then
      EXECUTE IMMEDIATE l_stmt_def;
   end if;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');

   END IF;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RAISE;
END;

--------------------------------------------------------------------------------

END fa_xla_extract_util_pkg;

/
