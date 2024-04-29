--------------------------------------------------------
--  DDL for Package Body XLA_DATAFIXES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_DATAFIXES_PUB" AS
/* $Header: xlajedfp.pkb 120.1.12010000.10 2009/12/02 16:15:20 rajose ship $ */

--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
TYPE t_array_integer  IS TABLE OF INTEGER        INDEX BY BINARY_INTEGER;
TYPE t_array_char1    IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE t_array_char30   IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;

TYPE t_je_ae_header_id IS TABLE OF INTEGER       INDEX BY BINARY_INTEGER; --krsankar

C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_datafixes_pub';

--=============================================================================
--               *********** Private Global Constant **********
--=============================================================================
C_COMPLETION_OPTION_DRAFT       CONSTANT VARCHAR2(1)    := 'D';
C_COMPLETION_OPTION_FINAL       CONSTANT VARCHAR2(1)    := 'F';
C_COMPLETION_OPTION_POST        CONSTANT VARCHAR2(1)    := 'P';

C_STATUS_FUNDS_RESERVE          CONSTANT VARCHAR2(30) := 'FUNDS_RESERVE';
C_STATUS_FINAL                  CONSTANT VARCHAR2(30) := 'FINAL';
C_STATUS_DRAFT_CODE             CONSTANT VARCHAR2(1) := 'D';
C_STATUS_FINAL_CODE             CONSTANT VARCHAR2(1) := 'F';
C_STATUS_POSTING_CODE           CONSTANT VARCHAR2(1) := 'P';

C_ITEM_HEADER_DESCRIPTION       CONSTANT VARCHAR2(20) := 'HEADER_DESCRIPTION';
C_ITEM_GL_DATE                  CONSTANT VARCHAR2(20) := 'GL_DATE';
C_ITEM_REFERENCE_DATE           CONSTANT VARCHAR2(20) := 'REFERENCE_DATE';
C_ITEM_LINE_DESCRIPTION         CONSTANT VARCHAR2(20) := 'LINE_DESCRIPTION';
C_ITEM_ACCOUNT                  CONSTANT VARCHAR2(20) := 'ACCOUNT';
C_ITEM_ACCOUNTED_DR             CONSTANT VARCHAR2(20) := 'ACCOUNTED_DR';
C_ITEM_ACCOUNTED_CR             CONSTANT VARCHAR2(20) := 'ACCOUNTED_CR';
C_ITEM_CURRENCY_CODE            CONSTANT VARCHAR2(20) := 'CURRENCY_CODE';
C_ITEM_CURR_CONV_TYPE           CONSTANT VARCHAR2(20) := 'CURR_CONV_TYPE';
C_ITEM_CURR_CONV_RATE           CONSTANT VARCHAR2(20) := 'CURR_CONV_RATE';
C_ITEM_CURR_CONV_DATE           CONSTANT VARCHAR2(20) := 'CURR_CONV_DATE';
C_ITEM_ENTERED_DR               CONSTANT VARCHAR2(20) := 'ENTERED_DR';
C_ITEM_ENTERED_CR               CONSTANT VARCHAR2(20) := 'ENTERED_CR';
C_ITEM_ACCOUNTING_CLASS         CONSTANT VARCHAR2(20) := 'ACCOUNTING_CLASS';


g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE delete_tb_entries ( p_event_id IN NUMBER
                             ,p_application_id IN NUMBER);

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
BEGIN
  ----------------------------------------------------------------------------
  -- Following is for FND log.
  ----------------------------------------------------------------------------
  IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
  ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_datafixes_pub.trace');
END trace;

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================


/*
 This function returns the transaction number or transaction details
 depending on the flag p_trans_details_flag.
 IF p_trans_details_flag = 'N' THEN
   return the transaction number
 ELSE
   return the transaction details based on the entity code passed.
 END IF;
*/
FUNCTION get_transaction_details ( p_application_id      IN INTEGER,
                                   p_entity_id           IN INTEGER,
                                   p_trans_details_flag  IN VARCHAR2 DEFAULT 'N',
                                   p_entity_code         IN VARCHAR2 DEFAULT NULL
                                   )
                                   RETURN VARCHAR2 IS

CURSOR c_transaction_number IS
SELECT transaction_number
FROM xla_transaction_entities
WHERE entity_id = p_entity_id
AND application_id = p_application_id;


l_transaction_number xla_transaction_entities.transaction_number%TYPE;

v_refcur        SYS_REFCURSOR;
l_join_string   VARCHAR2(32000);

l_transaction_entity_sql VARCHAR2(32000) :=
                 'SELECT $transaction_entity_columns$
                  FROM xla_transaction_entities ent
                  WHERE ent.application_id = :1
                  AND  ent.entity_id       = :2 ';

l_trx_columns         VARCHAR2(4000);
l_trx_col1            VARCHAR2(1000);
l_trx_col2            VARCHAR2(1000);
l_trx_col3            VARCHAR2(1000);
l_trx_col4            VARCHAR2(1000);


BEGIN

    IF p_trans_details_flag = 'N' THEN
      OPEN c_transaction_number;
      FETCH c_transaction_number INTO l_transaction_number;
      CLOSE c_transaction_number;

     RETURN l_transaction_number;

   ELSIF ( p_trans_details_flag = 'Y' AND
           p_entity_code NOT IN ('MANUAL','THIRD_PARTY_MERGE')
          ) THEN

   FOR i IN
   ( SELECT  xid.transaction_id_col_name_1   trx_col_1
             ,xid.transaction_id_col_name_2   trx_col_2
             ,xid.transaction_id_col_name_3   trx_col_3
             ,xid.transaction_id_col_name_4   trx_col_4
             ,xid.source_id_col_name_1        src_col_1
             ,xid.source_id_col_name_2        src_col_2
             ,xid.source_id_col_name_3        src_col_3
             ,xid.source_id_col_name_4        src_col_4
     FROM  xla_entity_id_mappings xid
     WHERE xid.application_id = p_application_id  -- input to the procedure
     AND xid.entity_code = p_entity_code
    )
    LOOP

      IF i.trx_col_1 IS NOT NULL THEN
                     l_join_string := l_join_string || ''''|| lower(i.TRX_COL_1) || ': '|| '''' || ' '|| '||' ||
                                       'ENT.'|| i.src_col_1 || ' TRX_COL_1' ||  ',';
      END IF;

      IF i.trx_col_1 IS NULL THEN
           l_join_string := l_join_string || 'NULL' || ' TRX_COL_1' || ',';
      END IF;


      IF i.trx_col_2 IS NOT NULL THEN
                     l_join_string := l_join_string || ''''|| lower(i.TRX_COL_2) || ': ' || '''' || ' '|| '||' ||
                                       'ENT.'|| i.src_col_2 || ' TRX_COL_2' || ',';
      END IF;

      IF i.trx_col_2 IS NULL THEN
                     l_join_string := l_join_string || 'NULL' || ' TRX_COL_2' || ',';
      END IF;


      IF i.trx_col_3 IS NOT NULL THEN
                     l_join_string := l_join_string || ''''|| lower(i.TRX_COL_3) || ': ' || '''' ||' '|| '||' ||
                                       'ENT.'|| i.src_col_3 || ' TRX_COL_3' || ',';
      END IF;

      IF i.trx_col_3 IS NULL THEN
                     l_join_string := l_join_string || 'NULL' || ' TRX_COL_3' || ',' ;
      END IF;

      IF i.trx_col_4 IS NOT NULL THEN
                     l_join_string := l_join_string ||  ''''|| lower(i.TRX_COL_4) || ': ' || '''' || ' '|| '||' ||
                                       'ENT.'|| i.src_col_4 || ' TRX_COL_4' ;
      END IF;

      IF i.trx_col_4 IS NULL THEN
                     l_join_string := l_join_string ||  'NULL' || ' TRX_COL_4' ;
      END IF;

    END LOOP;

    l_transaction_entity_sql := REPLACE(l_transaction_entity_sql, '$transaction_entity_columns$' , l_join_string);


    OPEN v_refcur FOR  l_transaction_entity_sql USING p_application_id, p_entity_id ;
    LOOP
      FETCH v_refcur INTO l_trx_col1, l_trx_col2,
                        l_trx_col3,l_trx_col4;
      EXIT WHEN v_refcur%NOTFOUND;

      IF l_trx_col1 IS NOT NULL THEN
       l_trx_columns :=  l_trx_columns || l_trx_col1;
      END IF ;

      IF l_trx_col2 IS NOT NULL THEN
       l_trx_columns :=  l_trx_columns || ' '|| l_trx_col2;
      END IF ;

     IF l_trx_col3 IS NOT NULL THEN
        l_trx_columns :=  l_trx_columns || ' ' || l_trx_col3;
     END IF ;

     IF l_trx_col4 IS NOT NULL THEN
       l_trx_columns :=  l_trx_columns || ' ' || l_trx_col4;
     END IF ;

    END LOOP;

    CLOSE v_refcur;

    RETURN l_trx_columns;
   ELSE
     -- indicates that this is a MANUAL or THIRD_PARTY_MERGE entity
     RETURN NULL;

   END IF;

END get_transaction_details;


--=============================================================================
--
-- Following API are used for data fix:
--
--    1.    delete_journal_entries
--    2.    reverse_journal_entries
--    3.    redo_accounting
--    4.    do_not_transfer_je
--    5.    validate_journal_entry
--
--
--=============================================================================


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE delete_journal_entries
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_event_id                   IN  INTEGER
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS

  l_api_name          CONSTANT VARCHAR2(30) := 'delete_journal_entries';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_retcode                  INTEGER;
  l_log_module               VARCHAR2(240);
  l_gl_transfer_status_code  VARCHAR2(10) := NULL;
  l_count number;

BEGIN
  IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.delete_journal_entries';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure delete_journal_entries',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF (NOT FND_API.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

 --Bug : 8752657 - Check MO security setting
  select count(1)
  into l_count
  from xla_events xe
  ,xla_transaction_entities xte
  where xe.application_id=p_application_id
  and xe.event_id=p_event_id
  and xe.entity_id=xte.entity_id
  and xte.application_id=xe.application_id;

  IF l_count = 0 THEN
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Journal entries cannot be deleted because either MO Security is not set for this session or Entity does not exist for this event',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
   Log_error(p_module    => l_log_module
              ,p_error_msg => 'Journal entries cannot be deleted because either MO Security is not set for this session or Entity does not exist for this event');
  END IF;--Bug 	8752657.

  --  Initialize global variables
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  -----------------------------------------------------------------------------------
  -- Validation
  -----------------------------------------------------------------------------------
  SELECT MAX(NVL(gl_transfer_status_code,'N'))  -- N, NT, S, Y
  INTO   l_gl_transfer_status_code
  FROM   xla_ae_headers xah
  WHERE  application_id = p_application_id
  AND    event_id       = p_event_id
 -- added bug#8344908
  AND NOT EXISTS
      ( SELECT 1
        FROM xla_ae_lines xal, gl_import_references gir
        WHERE xah.ae_header_id = xal.ae_header_id
        AND  xah.application_id = xal.application_id
        AND  xal.gl_sl_link_id = gir.gl_sl_link_id
        AND  xal.gl_sl_link_table = gir.gl_sl_link_table
      );
 -- bug#8344908

  IF l_gl_transfer_status_code IS NULL THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'No such journal entry or the journal entries are transferred to gl and cannot be deleted.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     Log_error(p_module    => l_log_module
              ,p_error_msg => 'No such journal entry or the journal entries are transferred to gl and cannot be deleted.');

  ELSIF l_gl_transfer_status_code IN ('S','Y') THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'l_gl_transfer_status_code='||l_gl_transfer_status_code||
                           'Journal entries cannot be deleted because it has either been Transferred or set to Not Transferred or gl_transfer_status_flag has an incorrect status as the journal entries are not transferred to General Ledger.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     Log_error(p_module    => l_log_module
              ,p_error_msg => 'Journal entries cannot be deleted because it has either been Transferred or set to Not Transferred or gl_transfer_status_flag has an incorrect status as the journal entries are not transferred to General Ledger.');

  ELSE

     --------------------------------------------------------
     -- delete all journal entries for the event
     -- no impact on trial balance if not transferred
     --------------------------------------------------------
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Calling xla_journal_entries_pkg.delete_journal_entries.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;

     xla_journal_entries_pkg.delete_journal_entries
        (p_application_id      => p_application_id
        ,p_event_id            => p_event_id);

     --------------------------------------------------------
     -- mark event as un-processed so can be re-processed
     --------------------------------------------------------
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Update xla_events event_id'||p_event_id||' to Unprocessed.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     UPDATE XLA_EVENTS
     SET    EVENT_STATUS_CODE   = xla_events_pub_pkg.C_EVENT_UNPROCESSED
           ,PROCESS_STATUS_CODE = xla_events_pkg.C_INTERNAL_UNPROCESSED
     WHERE  application_id      = p_application_id
     AND    event_id            = p_event_id;


     audit_datafix (p_application_id      => p_application_id
                   ,p_event_id            => p_event_id);

  END IF;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_journal_entries',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    FND_MSG_PUB.add_exc_msg(C_DEFAULT_MODULE, l_api_name);
  END IF;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);
END delete_journal_entries;



/*=== Logic ====================================================================
1) find the ae_header_id of the primary ledger (and original parent entry of
   MPA/Accrual Reversal entry, if exists) for the original p_event_id
2) calls Reverse_Journal_Entry with the ae_header_id
   a) delete the incomplete MPA
   b) calls Create_Reversal_Entry of the ae_header_id to create the reversal of
      the original entry, returning the new rev_ae_header_id and rev_event_id
      i) calls Complete_Journal_Entry with rev_ae_header_id, p_event_id and
         p_rev_flag = 'Y' to validate the reversal entry rev_ae_header_id and on
         success,
         -> calls Create_MRC_Reversal_Entry to create reversal of all other
            ledgers and entries related to the original entry p_event_id.
   c) Create a new event and entity, and map the original entry to the new
      event id and entity id.
==============================================================================*/
PROCEDURE reverse_journal_entries
  (p_api_version           IN  NUMBER
  ,p_init_msg_list         IN  VARCHAR2
  ,p_application_id        IN  INTEGER
  ,p_event_id              IN  INTEGER
  ,p_reversal_method       IN  VARCHAR2
  ,p_gl_date               IN  DATE
  ,p_post_to_gl_flag       IN  VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
  ,x_rev_ae_header_id      OUT NOCOPY INTEGER
  ,x_rev_event_id          OUT NOCOPY INTEGER
  ,x_rev_entity_id         OUT NOCOPY INTEGER
  ,x_new_event_id          OUT NOCOPY INTEGER
  ,x_new_entity_id         OUT NOCOPY INTEGER
) IS

  l_api_name          CONSTANT VARCHAR2(30) := 'reverse_journal_entries';
  l_api_version       CONSTANT NUMBER       := 1.0;

  ---------------------------------------------------------------
  -- in order to reverse, they must be FINAL and Transferred.
  ---------------------------------------------------------------
/* Bug 7011889 - Removed ae_header_id out of this CURSOR to fetch through BULK COLLECT */
 -- Bug#8736946 changed the cursor to pick secondary ledger events which are
 -- valuation based

  CURSOR c_orig_je IS
  SELECT   /*+ leading(xah) */
         gl.currency_code,    xsu.je_source_name,
         xah.entity_id,     xah.accounting_date,
         xah.ledger_id,     xte.legal_entity_id,  xah.accrual_reversal_flag,
         xle.budgetary_control_flag
   FROM XLA_LEDGER_OPTIONS opt,
        XLA_LEDGER_RELATIONSHIPS_V rs,
        xla_gl_ledgers_v gl,
        xla_ae_headers xah,
        xla_subledgers xsu,
        xla_events     xle,
        xla_transaction_entities xte
   WHERE  opt.LEDGER_ID =  xah.ledger_id
   AND opt.APPLICATION_ID = xah.application_id
   AND xsu.application_id = xah.application_id
   AND xah.event_id = p_event_id -- input parameters
   AND xah.application_id = p_application_id -- input parameters
   AND xah.event_id = xle.event_id
   AND xah.application_id = xle.application_id
   AND xah.entity_id      = xte.entity_id
   AND xah.application_id = xte.application_id
   AND xah.parent_ae_header_id IS NULL
   AND xah.accounting_entry_status_code = C_STATUS_FINAL_CODE
   AND opt.ENABLED_FLAG = 'Y'
   AND rs.LEDGER_ID = opt.LEDGER_ID
   AND (   rs.LEDGER_CATEGORY_CODE = 'PRIMARY'
        OR (rs.LEDGER_CATEGORY_CODE = 'SECONDARY'
            AND xsu.valuation_method_flag = 'Y'
            AND opt.CAPTURE_EVENT_FLAG = 'Y'))
   AND rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
   AND rs.ledger_id = gl.ledger_id
   AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL
   AND NOT EXISTS (SELECT 1
                  FROM   xla_ae_headers  xah2
                  WHERE  xah2.application_id = p_application_id
                  AND    xah2.event_id       = p_event_id
                  AND    xah2.accounting_entry_status_code = C_STATUS_FINAL_CODE
                  AND    NVL(xah2.gl_transfer_status_code,'N') IN ('N','NT')) -- can be reversed only if it is transferred
  --Added bug#8344908
   AND EXISTS
       ( SELECT 1
         FROM xla_ae_lines xal, gl_import_references gir
         WHERE xah.ae_header_id = xal.ae_header_id
         AND  xah.application_id = xal.application_id
         AND  xal.gl_sl_link_id = gir.gl_sl_link_id
         AND  xal.gl_sl_link_table = gir.gl_sl_link_table
       );
  --Added bug#8344908


  l_functional_curr      xla_gl_ledgers_v.currency_code%TYPE;
  l_je_source_name       xla_subledgers.je_source_name%TYPE;
  l_entity_id            INTEGER;
  l_pri_ae_header_id     INTEGER;
  l_pri_gl_date          DATE;
  l_ledger_id            INTEGER;
  l_legal_entity_id      INTEGER;
  l_mpa_acc_rev_flag     VARCHAR2(1);
  l_bc_flag              VARCHAR2(1);
  l_transfer_request_id  INTEGER;

  l_event_source_info    xla_events_pub_pkg.t_event_source_info;
  l_array_ae_header_id   t_array_integer;

  /* Bug 7011889 - Array to hold ae_header_ids from BULK COLLECT in case of Encumbarance events */
  l_array_je_header_id   xla_je_validation_pkg.t_array_int;

  l_retcode              INTEGER;
  l_log_module           VARCHAR2(240);
  l_completion_option    VARCHAR2(1);
  l_completion_retcode   VARCHAR2(30);

 --bug#8279661
  CURSOR c_entity_code(p_orig_entity_id INTEGER)   IS
  SELECT entity_code
  FROM xla_transaction_entities
  WHERE application_id = p_application_id
  AND entity_id  = p_orig_entity_id;

  l_orig_entity_code xla_event_types_b.entity_code%TYPE;
  l_new_description  xla_ae_headers.description%TYPE;

  l_count number;--Bug 	8752657

 --end bug#8279661

BEGIN
  IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.reverse_journal_entries';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure reverse_journal_entries',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
     FND_MSG_PUB.initialize;
  END IF;

   -- Bug :8752657 Check MO security setting
  select count(1)
  into l_count
  from xla_events xe
  ,xla_transaction_entities xte
  where xe.application_id=p_application_id
  and xe.event_id=p_event_id
  and xe.entity_id=xte.entity_id
  and xte.application_id=xe.application_id;

  IF l_count = 0 THEN
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Journal entries cannot be deleted because either MO Security is not set for this session or Entity does not exist for this event',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
   Log_error(p_module    => l_log_module
              ,p_error_msg => 'Journal entries cannot be deleted because either MO Security is not set for this session or Entity does not exist for this event');
  END IF;-- Bug 8752657.

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'Delete entries from xla_trial_balances',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Standard call to check for call compatibility.
  IF (NOT FND_API.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --  Initialize global variables
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

   --------------------------------------------------------------
  -- Call to DELETE TB entries for original event E1
  --------------------------------------------------------------
   delete_tb_entries( p_event_id
                     ,p_application_id);


  -- Validation -------------------------------------------------------
/* Bug 7011889 - Modified from OPEN,FETCH to CURSOR FOR LOOP */

FOR c_orig_je_rec IN c_orig_je
LOOP
 l_functional_curr := c_orig_je_rec.currency_code;
 l_je_source_name  := c_orig_je_rec.je_source_name;
 l_entity_id       := c_orig_je_rec.entity_id;
 l_pri_gl_date     := c_orig_je_rec.accounting_date;
 l_ledger_id       := c_orig_je_rec.ledger_id;
 l_legal_entity_id := c_orig_je_rec.legal_entity_id;
 l_mpa_acc_rev_flag := c_orig_je_rec.accrual_reversal_flag;
 l_bc_flag          := c_orig_je_rec.budgetary_control_flag;

END LOOP;


 --Added bug#8344908 Added the following IF condition to check whether there exists an
 -- entity id for the event to be reversed. If its null its an indication that the event
 -- does not exists in gl and throw an error that the event cannot be reversed as its not transferred to gl

IF l_entity_id IS NOT NULL THEN


/* Bug 7011889 - Bulk collecting header ids into an array */
 -- Bug#8736946 changed the SELECT to pick secondary ledger events which are
 -- valuation based
   SELECT   /*+ leading(xah) */
         xah.ae_header_id
          BULK COLLECT INTO l_array_je_header_id
   FROM XLA_LEDGER_OPTIONS opt,
        XLA_LEDGER_RELATIONSHIPS_V rs,
        xla_gl_ledgers_v gl,
        xla_ae_headers xah,
        xla_subledgers xsu,
        xla_events     xle,
        xla_transaction_entities xte
   WHERE  opt.LEDGER_ID =  xah.ledger_id
   AND opt.APPLICATION_ID = xah.application_id
   AND xsu.application_id = xah.application_id
   AND xah.event_id = p_event_id -- input parameters
   AND xah.application_id = p_application_id -- input parameters
   AND xah.event_id = xle.event_id
   AND xah.application_id = xle.application_id
   AND xah.entity_id      = xte.entity_id
   AND xah.application_id = xte.application_id
   AND xah.parent_ae_header_id IS NULL
   AND xah.accounting_entry_status_code = C_STATUS_FINAL_CODE
   AND opt.ENABLED_FLAG = 'Y'
   AND rs.LEDGER_ID = opt.LEDGER_ID
   AND (   rs.LEDGER_CATEGORY_CODE = 'PRIMARY'
        OR (rs.LEDGER_CATEGORY_CODE = 'SECONDARY'
            AND xsu.valuation_method_flag = 'Y'
            AND opt.CAPTURE_EVENT_FLAG = 'Y'))
   AND rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
   AND rs.ledger_id = gl.ledger_id
   AND NOT EXISTS (SELECT 1
                  FROM   xla_ae_headers  xah2
                  WHERE  xah2.application_id = p_application_id
                  AND    xah2.event_id       = p_event_id
                  AND    xah2.accounting_entry_status_code = C_STATUS_FINAL_CODE
                  AND    NVL(xah2.gl_transfer_status_code,'N') IN ('N','NT')
                 )  -- can be reversed only if it is transferred
  AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL;


  --------------------------------------------------------------
  -- if this is not Accrual Reversal entry, check if it is MPA
  --------------------------------------------------------------
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'l_functional_curr  = '||l_functional_curr,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'l_je_source_name   = '||l_je_source_name,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'l_entity_id        = '||l_entity_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'l_pri_gl_date      = '||l_pri_gl_date,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'l_ledger_id        = '||l_ledger_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'l_legal_entity_id  = '||l_legal_entity_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'l_bc_flag  = '||l_bc_flag,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'Accrual Reversal   = '||l_mpa_acc_rev_flag,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
  END IF;

/* Bug 7011889 - Writing to trace file the array of header ids through LOOP */

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     FOR i IN l_array_je_header_id.FIRST..l_array_je_header_id.LAST
     LOOP
            trace(p_msg    => 'l_pri_ae_header_id = '||l_array_je_header_id(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
     END LOOP;
    END IF;

  If l_mpa_acc_rev_flag = 'N' THEN

  /* Bug 7011889 - Modified the SQL to handle multiple header ids */

     SELECT MAX(NVL(MPA_ACCRUAL_ENTRY_FLAG,'N'))
     INTO   l_mpa_acc_rev_flag
     FROM   xla_ae_lines
     WHERE  application_id = p_application_id
     AND    ae_header_id in (SELECT ae_header_id
                             FROM xla_ae_headers
			     WHERE event_id = p_event_id
			     AND application_id = p_application_id);

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'MPA Accrual = '||l_mpa_acc_rev_flag,
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
  END IF;


  IF NVl(p_post_to_gl_flag,'N') = 'Y' THEN
     l_completion_option := C_STATUS_POSTING_CODE; -- if previously posted, then reverse is Final and Post to GL
  ELSE
     l_completion_option := C_STATUS_FINAL_CODE;   -- if not previously posted, then reverse is only Final
  END IF;
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'l_completion_option = '||l_completion_option,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
  END IF;

  -------------------------------------------------------------------------
  -- delete incomplete MPA here or later :
  -- less work in subsequent APIs, and anyway rollback if there is error
  -------------------------------------------------------------------------
  IF l_mpa_acc_rev_flag = 'Y' THEN
     FOR i in (SELECT ae_header_id
               FROM   xla_ae_headers
               WHERE  application_id      = p_application_id
               AND    event_id            = p_event_id
               AND    parent_ae_header_id IS NOT NULL
               AND    accounting_entry_status_code <> C_STATUS_FINAL_CODE ) LOOP
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace(p_msg    => 'Delete journal entry = '||i.ae_header_id,
                   p_module => l_log_module,
                   p_level  => C_LEVEL_STATEMENT);
         END IF;
         -------------------------------------------------
         -- delete incomplete MPA/Accrual Reversal Entries
         -------------------------------------------------
         DELETE xla_ae_lines
         WHERE  application_id = p_application_id
         AND    ae_header_id   = i.ae_header_id;
         --
         DELETE xla_distribution_links
         WHERE  application_id = p_application_id
         AND    ae_header_id   = i.ae_header_id;
         --
         DELETE  xla_ae_headers
         WHERE  application_id = p_application_id
         AND    ae_header_id   = i.ae_header_id;
         --
     END LOOP;
  END IF;

  -----------------------------------------------------------------------------------
  -- Currently, xla_journal_entries_pkg.reverse_journal_entry only process MANUAL entry
  -----------------------------------------------------------------------------------
  update xla_ae_headers
  set    accounting_entry_type_code = 'MANUAL'
  where  application_id = p_application_id
  and    event_id       = p_event_id;

  --------------------------------------------------------
  -- reverse journal entries
  --------------------------------------------------------
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Calling  xla_journal_entries_pkg.reverse_journal_entry.',
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
  END IF;

  /* Bug 7011889 - Replace call to l_pri_ae_header_id with array of header ids for Encumbarance */

  xla_journal_entries_pkg.reverse_journal_entry(
        p_array_je_header_id     => l_array_je_header_id
       ,p_application_id         => p_application_id
       ,p_reversal_method        => p_reversal_method
       ,p_gl_date                => p_gl_date
       ,p_completion_option      => l_completion_option
       ,p_functional_curr        => l_functional_curr
       ,p_je_source_name         => l_je_source_name
       ,p_rev_header_id          => x_rev_ae_header_id
       ,p_rev_event_id           => x_rev_event_id
       ,p_completion_retcode     => l_completion_retcode  -- S,X
       ,p_transfer_request_id    => l_transfer_request_id
       );

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Returned from  xla_journal_entries_pkg.reverse_journal_entry.',
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF l_completion_retcode <> 'S' or x_rev_ae_header_id IS NULL THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Failure in xla_journal_entries_pkg.reverse_journal_entry. Please verify log file.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     Log_error(p_module    => l_log_module
              ,p_error_msg => 'Failure in xla_journal_entries_pkg.reverse_journal_entry. Please verify log file.');
  END IF;

  SELECT entity_id
  INTO   x_rev_entity_id
  FROM   xla_events
  WHERE  application_id = p_application_id
  AND    event_id       = x_rev_event_id
  AND    rownum = 1;

-- Bug  6964268  Begin
UPDATE xla_transaction_entities
  SET   (entity_code
       , source_id_int_1
       , source_id_char_1
       , security_id_int_1
       , security_id_int_2
       , security_id_int_3
       , security_id_char_1
       , security_id_char_2
       , security_id_char_3
       , source_id_int_2
       , source_id_char_2
       , source_id_int_3
       , source_id_char_3
       , source_id_int_4
       , source_id_char_4
       , valuation_method
       , source_application_id
       , upg_batch_id
       , upg_source_application_id
       , upg_valid_flag
       , transaction_number
       -- legal_entity_id
       -- ledger_id
       , creation_date
       , created_by
       , last_update_date
       , last_updated_by
       , last_update_login) = (SELECT 'MANUAL'  -- entity_code  This also prevents transaction to be used in bflow.
                                     ,source_id_int_1
                                     ,source_id_char_1
                                     ,security_id_int_1
                                     ,security_id_int_2
                                     ,security_id_int_3
                                     ,security_id_char_1
                                     ,security_id_char_2
                                     ,security_id_char_3
                                     ,source_id_int_2
                                     ,source_id_char_2
                                     ,source_id_int_3
                                     ,source_id_char_3
                                     ,source_id_int_4
                                     ,source_id_char_4
                                     ,valuation_method
                                     ,source_application_id
                                     ,upg_batch_id
                                     ,upg_source_application_id
                                     ,upg_valid_flag
                                     ,transaction_number --bug#8279661
                                     -- legal_entity_id
                                     -- ledger_id
                                     ,sysdate
                                     ,fnd_global.user_id
                                     ,sysdate
                                     ,fnd_global.user_id
                                     ,fnd_global.user_id
                           FROM   xla_transaction_entities
                           WHERE  application_id = p_application_id
                           AND    entity_id      = l_entity_id)
  WHERE application_id = p_application_id
  AND   entity_id      = x_rev_entity_id;


-- Bug  6964268  End

  -----------------------------------------------------------------
  -- Create new event and entity, same details as original entry
  -----------------------------------------------------------------
  l_event_source_info.application_id   := p_application_id;
  l_event_source_info.legal_entity_id  := l_legal_entity_id;
  l_event_source_info.ledger_id        := l_ledger_id;
  l_event_source_info.entity_type_code := 'MANUAL';

  ---------------------------------------------------------------------------------------------
  -- Currently, xla_events_pkg.validate_event_type_code failes if not MANUAL event type
  ---------------------------------------------------------------------------------------------
  -- Currently,  xla_events_pkg.validate_event_type_code can only process MANUAL event type
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Calling xla_events_pkg.create_manual_event.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;
  x_new_event_id := xla_events_pkg.create_manual_event
                         (p_event_source_info 	=> l_event_source_info
                         ,p_event_type_code     => 'MANUAL'
                         ,p_event_date          => l_pri_gl_date
                         ,p_event_status_code   => xla_events_pub_pkg.C_EVENT_UNPROCESSED
                         ,p_process_status_code	=> xla_events_pkg.C_INTERNAL_UNPROCESSED
                         ,p_event_number        => 1
                         ,p_budgetary_control_flag => l_bc_flag);
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Returned from xla_events_pkg.create_manual_event = event id '||x_new_event_id,
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;

  -----------------------------------------------------
  -- update new EVENT_ID and ENTITY_ID
  -----------------------------------------------------
  UPDATE xla_events
  SET    event_status_code    = xla_events_pub_pkg.C_EVENT_PROCESSED
       , process_status_code  = xla_events_pub_pkg.C_EVENT_PROCESSED
       ,(event_type_code
       , event_date
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
       , on_hold_flag
       , upg_batch_id
       , upg_source_application_id
       , upg_valid_flag
       , transaction_date
       , budgetary_control_flag
       , merge_event_set_id
       -- event_number
       , creation_date
       , created_by
       , last_update_date
       , last_updated_by
       , last_update_login
       , program_update_date
       , program_application_id
       , program_id
       , request_id) = (SELECT 'MANUAL'  -- event_type_code
                             , event_date
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
                             , on_hold_flag
                             , upg_batch_id
                             , upg_source_application_id
                             , upg_valid_flag
                             , transaction_date
                             , budgetary_control_flag
                             , merge_event_set_id
                             -- event_number
                             , sysdate
                             , fnd_global.user_id
                             , sysdate
                             , fnd_global.user_id
                             , fnd_global.user_id
                             , sysdate
                             , -1
                             , -1
                             , -1
                        FROM   xla_events
                        WHERE  application_id = p_application_id
                        AND    event_id       = p_event_id)
  WHERE application_id = p_application_id
  AND   event_id       = x_new_event_id
  RETURNING entity_id INTO x_new_entity_id;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'entity id = '||x_new_entity_id,
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_transaction_entities
  SET   (entity_code
       , source_id_int_1
       , source_id_char_1
       , security_id_int_1
       , security_id_int_2
       , security_id_int_3
       , security_id_char_1
       , security_id_char_2
       , security_id_char_3
       , source_id_int_2
       , source_id_char_2
       , source_id_int_3
       , source_id_char_3
       , source_id_int_4
       , source_id_char_4
       , valuation_method
       , source_application_id
       , upg_batch_id
       , upg_source_application_id
       , upg_valid_flag
       , transaction_number
       -- legal_entity_id
       -- ledger_id
       , creation_date
       , created_by
       , last_update_date
       , last_updated_by
       , last_update_login) = (SELECT 'MANUAL'  -- entity_code  This also prevents transaction to be used in bflow.
                                     ,source_id_int_1
                                     ,source_id_char_1
                                     ,security_id_int_1
                                     ,security_id_int_2
                                     ,security_id_int_3
                                     ,security_id_char_1
                                     ,security_id_char_2
                                     ,security_id_char_3
                                     ,source_id_int_2
                                     ,source_id_char_2
                                     ,source_id_int_3
                                     ,source_id_char_3
                                     ,source_id_int_4
                                     ,source_id_char_4
                                     ,valuation_method
                                     ,source_application_id
                                     ,upg_batch_id
                                     ,upg_source_application_id
                                     ,upg_valid_flag
                                     ,transaction_number -- bug#8279661
                                     -- legal_entity_id
                                     -- ledger_id
                                     ,sysdate
                                     ,fnd_global.user_id
                                     ,sysdate
                                     ,fnd_global.user_id
                                     ,fnd_global.user_id
                           FROM   xla_transaction_entities
                           WHERE  application_id = p_application_id
                           AND    entity_id      = l_entity_id)
  WHERE application_id = p_application_id
  AND   entity_id      = x_new_entity_id;


  ---------------------------------------------------------
  -- audit original event and entries
  ---------------------------------------------------------
  audit_datafix (p_application_id => p_application_id
                ,p_event_id       => p_event_id
                ,p_audit_all      => 'Y');

  -------------------------------------------------------------------------------
  -- set original entries to link to new event, entity.  Also update Description
  -------------------------------------------------------------------------------
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Update xla_ae_headers',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;


  -- bug#8279661
  OPEN c_entity_code(l_entity_id);
  FETCH c_entity_code INTO l_orig_entity_code;
  CLOSE c_entity_code;

  /* bug#8279661 Get the entity description details for the event thats reversed */
 l_new_description := 'Data fix entry: event_id of '||p_event_id || ' For ' ||
                       get_transaction_details(p_application_id,l_entity_id, 'Y', l_orig_entity_code );

  UPDATE xla_ae_headers
  SET     entity_id        = x_new_entity_id
         ,event_id         = x_new_event_id
         ,event_type_code  = 'MANUAL'
         ,description      =  l_new_description -- 'Data fix entry: event_id of '||p_event_id
  WHERE  application_id = p_application_id
  AND    event_id       = p_event_id
  RETURNING ae_header_id  BULK COLLECT INTO l_array_ae_header_id;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Update xla_ae_lines',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;
  FORALL i in 1..l_array_ae_header_id.COUNT
     UPDATE xla_ae_lines
     SET    description         =  l_new_description --'Data fix entry: event_id of '||p_event_id
        --  business_class_code = NULL    -- This is not needed to prevent use by bflow since the entity_code is now 'MANUAL'
     WHERE  application_id = p_application_id
     AND    ae_header_id   = l_array_ae_header_id(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Update xla_distribution_links',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i in 1..l_array_ae_header_id.COUNT
     UPDATE xla_distribution_links
     SET    event_id       = x_new_event_id,
            temp_line_num  = abs(temp_line_num) -- added for RCA bug#8421688
     WHERE  application_id = p_application_id
     AND    ae_header_id   = l_array_ae_header_id(i);

/*
  bug#8421688:
  On undoing a cancelled event like invoice cancellation or payment cancellation, the redo of that event
  is resulting in accounting error as the NOT EXISTS of the following select fails in xla_ae_lines_pkg
  accounting_reversal procedure.
  SELECT 1  FROM xla_distribution_links xdl
  WHERE ref_ae_header_id = xdl.ae_header_id
  AND temp_line_num    = xdl.temp_line_num * -1
  AND application_id   = xdl.application_id
  Fix is to make the E3 event temp_line_num +ve for a cancelled event in xla_distribution_links table
  using abs(temp_line_num).
*/

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Update xla_events',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;
  ---------------------------------------------------------
  -- set original event to Unprocessed
  ---------------------------------------------------------
  UPDATE XLA_EVENTS
  SET    EVENT_STATUS_CODE   = xla_events_pub_pkg.C_EVENT_UNPROCESSED
        ,PROCESS_STATUS_CODE = xla_events_pkg.C_INTERNAL_UNPROCESSED
  WHERE   application_id = p_application_id
  AND     event_id       = p_event_id;

  -------------------------------------------------------------------------------
  -- update Description for reverse entries
  -------------------------------------------------------------------------------
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Update descriptions',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;

  /* bug#8279661 Get the entity description details for the event thats reversed */
  l_new_description := 'Data fix reversal entry: event_id of '||x_new_event_id || ' For ' ||
                       get_transaction_details(p_application_id,l_entity_id, 'Y', l_orig_entity_code );

  UPDATE xla_ae_headers
  SET    description    =  l_new_description --'Data fix reversal entry: event_id of '||x_new_event_id
  WHERE  application_id = p_application_id
  AND    event_id       = x_rev_event_id
  RETURNING ae_header_id  BULK COLLECT INTO l_array_ae_header_id;

  FORALL i in 1..l_array_ae_header_id.COUNT
     UPDATE xla_ae_lines
     SET    description    = l_new_description -- 'Data fix reversal entry: event_id of '||x_new_event_id
     WHERE  application_id = p_application_id
     AND    ae_header_id   = l_array_ae_header_id(i);

  ----------------------------------------------------------
  -- audit reversed event
  ----------------------------------------------------------
  audit_datafix (p_application_id => p_application_id
                ,p_event_id       => x_rev_event_id
                ,p_audit_all      => 'Y');


  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure reverse_journal_entries',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

ELSIF l_entity_id IS NULL THEN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace(p_msg    => 'Journal entry cannot be reversed as its not transferred to General Ledger.',
             p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
   END IF;
   Log_error(p_module    => l_log_module
              ,p_error_msg => 'Journal entry cannot be reversed as its not transferred to General Ledger.');
END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    FND_MSG_PUB.add_exc_msg(C_DEFAULT_MODULE, l_api_name);
  END IF;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);
END reverse_journal_entries;



--=============================================================================
--
--
--
--=============================================================================
PROCEDURE redo_accounting
  (p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2
  ,p_application_id         IN  INTEGER
  ,p_event_id               IN  INTEGER
  ,p_gl_posting_flag        IN  VARCHAR2
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
) IS
  l_api_name          CONSTANT VARCHAR2(30) := 'redo_accounting';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_errbuf            VARCHAR2(240);
  l_retcode           INTEGER;
  l_log_module        VARCHAR2(240);
  l_dummy             INTEGER;
  l_accounting_mode   VARCHAR2(30);
  l_process_status    VARCHAR2(1);
  l_batch_id          INTEGER;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.redo_accounting';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure redo_accounting',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF (NOT FND_API.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --  Initialize global variables
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  -- Validation ------------------------------------------------------------------------------------------
  SELECT DECODE(NVL(budgetary_control_flag,'N'),'Y', C_STATUS_FUNDS_RESERVE, C_STATUS_FINAL),process_status_code
  INTO   l_accounting_mode, l_process_status
  FROM   xla_events
  WHERE  application_id = p_application_id
  AND    event_id       = p_event_id;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'l_accounting_mode='||l_accounting_mode||', l_process_status='||l_process_status,
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;
  IF l_process_status <> 'U' THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'No such event or event has been processed. Please verify.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     Log_error(p_module    => l_log_module
              ,p_error_msg => 'No such event or event has been processed. Please verify.');
  END IF;
  --------------------------------------------------------------------------------------------------------

  ---------------------------------------------------------
  -- populate a row to be used by accounting_program_events
  ---------------------------------------------------------
  INSERT INTO xla_acct_prog_events_gt (event_id, ledger_id)
  VALUES (p_event_id, null);
  --
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Calling xla_accounting_pub_pkg.accounting_program_events.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;
  xla_accounting_pub_pkg.accounting_program_events
        (p_application_id        => p_application_id
        ,p_accounting_mode       => l_accounting_mode
        ,p_gl_posting_flag       => p_gl_posting_flag
        ,p_accounting_batch_id   => l_batch_id
        ,p_errbuf                => l_errbuf
        ,p_retcode               => l_retcode);
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Returned from xla_accounting_pub_pkg.accounting_program_events.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;

  ----------------------------------------------------------------------------------------------
  -- when BC event failed, l_retcode is still 0, do this check to make sure vent is procesed.
  ----------------------------------------------------------------------------------------------
  SELECT process_status_code
  INTO   l_process_status
  FROM   xla_events
  WHERE  application_id = p_application_id
  AND    event_id       = p_event_id;

  IF l_retcode = 0 AND l_process_status = 'P' THEN

     audit_datafix (p_application_id  => p_application_id
                   ,p_event_id        => p_event_id
                   ,p_audit_all       => 'Y');

  ELSE
     Log_error(p_module    => l_log_module
              ,p_error_msg => 'Error in redo accounting. Please check the log file.');
  END IF;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure redo_accounting',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);


WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    FND_MSG_PUB.add_exc_msg(C_DEFAULT_MODULE, l_api_name);
  END IF;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);
END redo_accounting;



--=============================================================================
--
--
--
--=============================================================================
PROCEDURE do_not_transfer_je
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
  l_api_name          CONSTANT VARCHAR2(30) := 'do_not_transfer_je';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_retcode           INTEGER;
  l_log_module        VARCHAR2(240);
  l_dummy             NUMBER;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.do_not_transfer_je';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure do_not_transfer_je',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF (NOT FND_API.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --  Initialize global variables
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  UPDATE xla_ae_headers
  SET    gl_transfer_status_code = 'NT'
  WHERE  application_id          = p_application_id
  AND    ae_header_id            = p_ae_header_id
  AND    accounting_entry_status_code = C_STATUS_FINAL_CODE
  AND    gl_transfer_status_code = 'N';    -- if already transferred, S or Y, then do not set to NT.

  l_dummy := SQL%ROWCOUNT;
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Rows updated = '||l_dummy,
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF l_dummy = 0 THEN
     Log_error(p_module    => l_log_module
              ,p_error_msg => 'No such entry, or the entry is not in Final mode or it has been transferred. Please verify.');
  END IF;

  audit_datafix (p_application_id  => p_application_id
                ,p_ae_header_id    => p_ae_header_id);

  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure do_not_transfer_je',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    FND_MSG_PUB.add_exc_msg(C_DEFAULT_MODULE, l_api_name);
  END IF;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);
END do_not_transfer_je;


--=============================================================================
-- PROCEDURE delete_tb_entries to delete original event E1 entries from
-- TRIAL BALANCES table
--
--=============================================================================

PROCEDURE delete_tb_entries( p_event_id       IN NUMBER
                            ,p_application_id IN NUMBER)
IS
  l_log_module VARCHAR2(240);
BEGIN

IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.delete_tb_entries';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure delete tb entries',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'p_event_id ='||p_event_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'p_application_id ='||p_application_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
END IF;

FOR i in ( SELECT xah.ae_header_id
      		 ,xah.accounting_date
      		 ,xah.ledger_id
      		 ,xah.entity_id
      		 ,xtb.definition_code
  	   FROM   xla_ae_headers xah
                 ,xla_tb_defn_je_sources xtbje
                 ,xla_tb_definitions_vl xtb
                 ,xla_subledgers xsl
           WHERE  xah.application_id  = p_application_id
           AND    xah.event_id        = p_event_id
           AND    xtb.ledger_id       = xah.ledger_id
           AND    xtb.definition_code = xtbje.definition_code
           AND    xsl.application_id  = xah.application_id
           AND    xsl.je_source_name  = xtbje.je_source_name
           AND    xtb.enabled_flag    = 'Y'
)
  LOOP
           DELETE FROM xla_trial_balances
           WHERE  definition_code       = i.definition_code
           AND    ae_header_id          = i.ae_header_id
           AND    gl_date between (i.accounting_date-2) and (i.accounting_date+2)
           AND    ledger_id             = i.ledger_id
           AND    source_entity_id      = i.entity_id
           AND    source_application_id = p_application_id;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace(p_msg    => 'END of procedure delete tb entries',
         p_module => l_log_module,
         p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
   ROLLBACK;
   RAISE;
END;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE validate_journal_entry
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
  l_api_name          CONSTANT VARCHAR2(30) := 'validate_journal_entry';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_retcode           INTEGER;
  l_log_module        VARCHAR2(240);
  l_dummy             INTEGER;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_journal_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF (NOT FND_API.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --  Initialize global variables
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  SELECT count(*)
  INTO   l_dummy
  FROM   xla_ae_headers
  WHERE  application_id = p_application_id
  AND    ae_header_id   = p_ae_header_id
  AND    accounting_entry_status_code = C_STATUS_FINAL_CODE;

  IF l_dummy = 0 THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'No such entry or it is not in Final mode.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     Log_error(p_module    => l_log_module
              ,p_error_msg => 'No such entry or it is not in Final mode.');
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Calling XLA_UPGRADE_PUB.Validate_Header_Line_Entries.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;
  XLA_UPGRADE_PUB.Validate_Header_Line_Entries (
          p_application_id        => p_application_id
         ,p_header_id             => p_ae_header_id);
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Returned from XLA_UPGRADE_PUB.Validate_Header_Line_Entries.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;


  FOR i IN (SELECT error_message_name
            FROM   xla_upg_errors
            WHERE  application_id = p_application_id
            AND    ae_header_id   = p_ae_header_id) LOOP
         Log_error(p_error_name  => i.ERROR_MESSAGE_NAME);
  END LOOP;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    FND_MSG_PUB.add_exc_msg(C_DEFAULT_MODULE, l_api_name);
  END IF;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);
END validate_journal_entry;



--=============================================================================
--
--
--
--=============================================================================
PROCEDURE audit_datafix
  (p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER DEFAULT NULL
  ,p_ae_line_num                IN  INTEGER DEFAULT NULL
  ,p_event_id                   IN  INTEGER DEFAULT NULL
  ,p_audit_all                  IN  VARCHAR2 DEFAULT 'N'
) IS

  l_log_module        VARCHAR2(240);
  l_array_ae_header_id       t_array_integer;

BEGIN

  IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.audit_datafix';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure audit_datafix',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -----------------------------------------------------
  -- audit xla_ae_headers
  -----------------------------------------------------
  IF p_ae_header_id IS NOT NULL THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Audit xla_ae_headers.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     UPDATE XLA_AE_HEADERS
     SET    LAST_UPDATE_DATE = sysdate
           ,UPG_BATCH_ID     = -9999
     WHERE  application_id = p_application_id
     AND    ae_header_id   = p_ae_header_id;
  END IF;

  -----------------------------------------------------
  -- audit xla_ae_lines
  -----------------------------------------------------
  IF p_ae_line_num IS NOT NULL THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Audit xla_ae_lines.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     UPDATE XLA_AE_LINES
     SET    LAST_UPDATE_DATE = sysdate
           ,UPG_BATCH_ID     = -9999
     WHERE  application_id = p_application_id
     AND    ae_header_id   = p_ae_header_id
     AND    ae_line_num    = p_ae_line_num;
  END IF;

  -----------------------------------------------------
  -- audit xla_events and all related entries
  -----------------------------------------------------
  IF p_event_id IS NOT NULL THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Audit xla_events.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     UPDATE XLA_EVENTS
     SET    LAST_UPDATE_DATE = sysdate
           ,UPG_BATCH_ID     = -9999
     WHERE  application_id = p_application_id
     AND    event_id       = p_event_id;

     IF p_audit_all = 'Y' THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace(p_msg    => 'Audit all details of xla_events.',
                   p_module => l_log_module,
                   p_level  => C_LEVEL_STATEMENT);
         END IF;
         UPDATE XLA_AE_HEADERS
         SET    LAST_UPDATE_DATE = sysdate
               ,UPG_BATCH_ID     = -9999
         WHERE  application_id = p_application_id
         AND    event_id       = p_event_id
         RETURNING ae_header_id  BULK COLLECT INTO l_array_ae_header_id;

         FORALL i in 1..l_array_ae_header_id.COUNT
            UPDATE XLA_AE_LINES
            SET    LAST_UPDATE_DATE       = sysdate
                  ,UPG_BATCH_ID           = -9999
              WHERE  application_id = p_application_id
              AND    ae_header_id   = l_array_ae_header_id(i);
     END IF;

  END IF;

END audit_datafix;



--=============================================================================
--
--
--
--=============================================================================
-- Currently there is no token param needed, but can be enhanced if necessary.
PROCEDURE log_error
  (p_module             IN  VARCHAR2 DEFAULT NULL
  ,p_error_msg          IN  VARCHAR2 DEFAULT NULL
  ,p_error_name         IN  VARCHAR2 DEFAULT NULL
) IS

BEGIN

   IF p_error_name IS NULL THEN
     -- An internal error occurred.  Please inform your system administrator or
     -- support representative that:
     -- An internal error has occurred in the program LOCATION.  ERROR.
     --
      Xla_exceptions_pkg.raise_message
     (p_appli_s_name   => 'XLA'
     ,p_msg_name       => 'XLA_COMMON_ERROR'
     ,p_token_1        => 'LOCATION'
     ,p_value_1        => p_module
     ,p_token_2        => 'ERROR'
     ,p_value_2        => p_error_msg
     ,p_msg_mode       => g_msg_mode);

   ELSE
      Xla_exceptions_pkg.raise_message
     (p_appli_s_name   => 'XLA'
     ,p_msg_name       => p_error_name
     ,p_msg_mode       => g_msg_mode);

   END IF;

   Raise FND_API.G_EXC_ERROR;

END log_error;


--=============================================================================
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--=============================================================================
BEGIN

   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_datafixes_pub;

/
