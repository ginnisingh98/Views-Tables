--------------------------------------------------------
--  DDL for Package Body IGI_DOS_FUNDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DOS_FUNDS" AS
-- $Header: igidoseb.pls 120.15.12010000.2 2010/02/09 10:28:34 dramired ship $

   /* ============== FND LOG VARIABLES ================== */
      l_debug_level   number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
      l_state_level   number := FND_LOG.LEVEL_STATEMENT ;
      l_proc_level    number := FND_LOG.LEVEL_PROCEDURE ;
      l_event_level   number := FND_LOG.LEVEL_EVENT ;
      l_excep_level   number := FND_LOG.LEVEL_EXCEPTION ;
      l_error_level   number := FND_LOG.LEVEL_ERROR ;
      l_unexp_level   number := FND_LOG.LEVEL_UNEXPECTED ;

   /* =================== DEBUG_LOG_UNEXP_ERROR =================== */
--bug 9128478
 TYPE packet_data_type IS TABLE OF GL_BC_PACKETS.PACKET_ID%TYPE;
PROCEDURE Packet_Error(p_packet_count IN NUMBER,
                       p_packet_data_tab IN packet_data_type);
   Procedure Debug_log_unexp_error (P_module     IN VARCHAR2,
                                    P_error_type IN VARCHAR2)
   IS

   BEGIN

    IF (l_unexp_level >= l_debug_level) THEN

       IF   (P_error_type = 'DEFAULT') THEN
             FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
             FND_MESSAGE.SET_TOKEN('CODE',sqlcode);
             FND_MESSAGE.SET_TOKEN('MSG',sqlerrm);
             FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igidoseb.' || P_module ,TRUE);
       ELSIF (P_error_type = 'USER') THEN
             FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igidoseb.' || P_module ,TRUE);
       END IF;

    END IF;

  END Debug_log_unexp_error;

   /* =================== DEBUG_LOG_STRING =================== */

   Procedure Debug_log_string (P_level   IN NUMBER,
                               P_module  IN VARCHAR2,
                               P_Message IN VARCHAR2)
   IS

   BEGIN

     IF (P_level >= l_debug_level) THEN
         FND_LOG.STRING(P_level, 'igi.plsql.igidoseb.' || P_module, P_message) ;
     END IF;

   END Debug_log_string;

   /* Bug 6126275 start */

   /* ================== INSERT_ROW ========================= */

    PROCEDURE insert_row( P_packet_id NUMBER,
                             P_sob_id      NUMBER,
                             P_code_combination_id NUMBER,
                             P_period_name VARCHAR2,
                             P_period_year number,
                             P_period_num  number,
                             P_quarter_num number,
                             P_currency_code  varchar2,
                             P_user_id varchar2,
                             P_source_amount number,
                             P_dossier_id number,
                             P_trx_id number,
                             P_encumbrance_type_id number,
                             P_budget_version_id number,
                             P_source_trx_id  number ) AS

     PRAGMA AUTONOMOUS_TRANSACTION;

       --l_trx_id                    NUMBER;

      l_session_id gl_bc_packets.session_id%type;
      l_serial_id gl_bc_packets.serial_id%type;
      l_application_id gl_bc_packets.application_id%type;


      CURSOR get_dest (p_source_trx_id         igi_dos_trx_dest.source_trx_id%TYPE)
      IS
          SELECT *
          FROM  igi_dos_trx_dest
          WHERE trx_id = P_trx_id
          AND   source_trx_id = p_source_trx_id;

    BEGIN


        begin
          select s.audsid,  s.serial#   into l_session_id, l_serial_id
          from v$session s, v$process p
          where s.paddr = p.addr
          and   s.audsid = USERENV('SESSIONID');
        exception
           when others then
           raise;
        end;



      -- Bug 3627318
      -- reversing the encumbrance for source.
      INSERT INTO gl_bc_packets (status_code,
                                 packet_id,
                                 ledger_id,                                   je_source_name,
                                 je_category_name,
                                 code_combination_id,
                                 actual_flag,
                                 period_name,
                                 period_year,
                                 period_num,
                                 quarter_num,
                                 currency_code,
                                 last_update_date,
                                 last_updated_by,
                                 budget_version_id,
                                 entered_dr,
                                 entered_cr,
                                 accounted_dr,
                                 accounted_cr,
                                 je_batch_name,
                                 reference1,
                                 reference2,
                                 encumbrance_type_id,
                                 session_id,serial_id,application_id )
                         VALUES
                                 ('P',
                                  P_packet_id,
                                  P_sob_id,
                                  'Transfer',
                                  'Budget',
                                  P_code_combination_id,
                                  'E',
                                  P_period_name,
                                  P_period_year,
                                  P_period_num,
                                  P_quarter_num,
                                  P_currency_code,
                                  sysdate,
                                  P_user_id,
                                  null,
                                  null,
                                  P_source_amount,
                                  null,
                                  P_source_amount,
                                  'Budget '||P_dossier_id,
                                  P_dossier_id || '..' ||       /* Bug 3466463 */
                                  P_trx_id,             /* packet_rec.trx_id, */
                                  P_source_trx_id,
                                  P_encumbrance_type_id,
                                  l_session_id,l_serial_id,101);

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Approve.Msg27',
                           ' INSERT INTO gl_bc_packets --> ' || SQL%ROWCOUNT);
      -- =============== END DEBUG LOG ==================

      -- Bug 1635678 sekhar kappaga  budget jounral for the source key ---
      INSERT INTO gl_bc_packets
                                (status_code,
                                 packet_id,
                            -- Set_of_books_id,  /* Commented for bug 6126275 */
                                 ledger_id,   /* Added for bug 6126275 */
                                 je_source_name,
                                 je_category_name,
                                 code_combination_id,
                                 actual_flag,
                                 period_name,
                                 period_year,
                                 period_num,
                                 quarter_num,
                                 currency_code,
                                 last_update_date,
                                 last_updated_by,
                                 budget_version_id,
                                 entered_dr,
                                 entered_cr,
                                 accounted_dr,
                                 accounted_cr,
                                 je_batch_name,
                                 reference1,
                                 reference2,
                                 session_id,serial_id,application_id )
            	         VALUES
                                 ('P',
                                  P_packet_id,
                                  P_sob_id,
                                  'Transfer',
                                  'Budget',
                                  P_code_combination_id,
                                  'B',
                                  P_period_name,
                                  P_period_year,
                                  P_period_num,
                                  P_quarter_num,
                                  P_currency_code,
                                  sysdate,
                                  P_user_id,
                                  P_budget_version_id,
                                  null,
                                  P_source_amount,
                                  null,
                                  P_source_amount,
                                  'Budget '||P_dossier_id,
                                  P_dossier_id || '..' ||   /* Bug 3466463 */
                                  P_trx_id,           /* packet_rec.trx_id, */
                                  P_source_trx_id,
                                  l_session_id,l_serial_id,101);

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Approve.Msg30',
                           ' INSERTED --> ' || SQL%ROWCOUNT);
         Debug_log_string (l_proc_level, 'Approve.Msg31',
                           ' INSERTING INTO gl_bc_packets for budget');
         Debug_log_string (l_proc_level, 'Approve.Msg32',
                           ' CREDIT SOURCE AMOUNT --> ' || P_source_amount);
      -- =============== END DEBUG LOG ==================


        -- Bug 1635678 sekhar kappaga  budget jounral for the destination key  start ---
        FOR dest_rec IN get_dest(P_source_trx_id)
        LOOP

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Approve.Msg34',
                              ' In to dest_rec loop ');
            Debug_log_string (l_proc_level, 'Approve.Msg35',
                           ' INSERTING INTO gl_bc_packets for budget');
            Debug_log_string (l_proc_level, 'Approve.Msg36',
                           ' DEBIT DEST AMOUNT --> ' || dest_rec.budget_amount);
          -- =============== END DEBUG LOG ==================

         INSERT INTO gl_bc_packets
                                  (status_code,
                                   packet_id,
                                   ledger_id,   /* Added for bug 6126275 */
                                   je_source_name,
                                   je_category_name,
                                   code_combination_id,
                                   actual_flag,
                                   period_name,
                                   period_year,
                                   period_num,
                                   quarter_num,
                                   currency_code,
                                   last_update_date,
                                   last_updated_by,
                                   budget_version_id,
                                   entered_dr,
                                   entered_cr,
                                   accounted_dr,
                                   accounted_cr,
                                   je_batch_name,
                                   reference1,
                                   reference2,
                                   session_id,serial_id,application_id )
                         VALUES   ('P',
                                   P_packet_id,
                                   dest_rec.sob_id,
                                   'Transfer',
                                   'Budget',
                                   dest_rec.code_combination_id,
                                   'B',
                                   dest_rec.period_name,
                                   dest_rec.period_year,
                                   dest_rec.period_num,
                                   dest_rec.quarter_num,
                                   P_currency_code,
                                   sysdate,
                                   P_user_id,
                                   dest_rec.budget_version_id,
                                   dest_rec.budget_amount,
                                   null,
                                   dest_rec.budget_amount,
                                   null,
                                'Dossier ' ||ltrim(to_char(dest_rec.dossier_id))|| ' ' || dest_rec.period_name,
                 to_char(dest_rec.dossier_id) || '..' || dest_rec.trx_id,
                 dest_rec.dest_trx_id,
              l_session_id,l_serial_id,101);





         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Approve.Msg37',
                              ' INSERTED --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

	END LOOP;

    COMMIT;

   END insert_row;

   /* =================== REJECT_INSERT_ROW ======================= */

    PROCEDURE reject_insert_row ( P_packet_id NUMBER,
                             P_sob_id      NUMBER,
                             P_code_combination_id NUMBER,
                             P_period_name VARCHAR2,
                             P_period_year number,
                             P_period_num  number,
                             P_quarter_num number,
                             P_currency_code  varchar2,
                             P_user_id number,
                             P_source_amount number,
                             P_dossier_id number,
                             P_trx_id number,
                             P_encumbrance_type_id number,
                             P_source_trx_id  number ) AS

    PRAGMA AUTONOMOUS_TRANSACTION;

      l_session_id gl_bc_packets.session_id%type;
      l_serial_id gl_bc_packets.serial_id%type;
      l_application_id gl_bc_packets.application_id%type;


    BEGIN

        begin
          select s.audsid,  s.serial#   into l_session_id, l_serial_id
          from v$session s, v$process p
          where s.paddr = p.addr
          and   s.audsid = USERENV('SESSIONID');
        exception
           when others then
           raise;
        end;


      -- Bug 3627318
      -- reversing the encumbrance for source.
      INSERT INTO gl_bc_packets (status_code,
                                 packet_id,
                                 ledger_id,
                                 je_source_name,
                                 je_category_name,
                                 code_combination_id,
                                 actual_flag,
                                 period_name,
                                 period_year,
                                 period_num,
                                 quarter_num,
                                 currency_code,
                                 last_update_date,
                                 last_updated_by,
                                 budget_version_id,
                                 entered_dr,
                                 entered_cr,
                                 accounted_dr,
                                 accounted_cr,
                                 je_batch_name,
                                 reference1,
                                 reference2,
                                 encumbrance_type_id,
                                 session_id,serial_id,application_id)
                         VALUES ('P',
                                  P_packet_id,
                                  P_sob_id,
                                  'Transfer',
                                  'Budget',
                                  P_code_combination_id,
                                  'E',
                                  P_period_name,
                                  P_period_year,
                                  P_period_num,
                                  P_quarter_num,
                                  P_currency_code,
                                  sysdate,
                                  P_user_id,
                                  null,
                                  null,
                                  P_source_amount,
                                  null,
                                  P_source_amount,
                                  'Budget '||P_dossier_id,
                            P_dossier_id || '..' || P_trx_id,                                                   P_source_trx_id,
                                  P_encumbrance_type_id,
                             l_session_id,l_serial_id,101);

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Reject.Msg31',
                           ' INSERT INTO gl_bc_packets --> ' || SQL%ROWCOUNT);
      -- =============== END DEBUG LOG ==================

    COMMIT;

    END reject_insert_row;

   /* end bug 6126275 */



   /* =================== APPROVE =================== */


   FUNCTION APPROVE  ( p_trx_number        IN VARCHAR2,
                       p_user_id           IN VARCHAR2,
                       p_responsibility_id IN VARCHAR2,
                       p_sob_id            IN VARCHAR2)
   RETURN BOOLEAN
   IS

    user_transfer               VARCHAR2(30);
    user_budget                 VARCHAR2(30);
    effective_date_rule_code    VARCHAR2(2);
    frozen_source_flag          VARCHAR2(2);
    approval_flag               VARCHAR2(2);
    l_packet_id                 NUMBER;
    v_packet_id                 NUMBER;
    l_return_code               VARCHAR2(30);
    v_source_amount             NUMBER;
    reversal_option_code        VARCHAR2(2);
    v_encumbrance_type_id       NUMBER;

    -- Bug 1635678 sekhar kappaga.
    l_currency_code             VARCHAR2(15);

    l_trx_id                    NUMBER;
    l_user_id                   VARCHAR2(30);
    l_responsibility_id         VARCHAR2(30);
    l_resp_appl_id              VARCHAR2(30);
    temp                        VARCHAR2(30);
    l_sob_id                    VARCHAR2(30);
 -- Bug 9128478 : Added
    l_packet_count NUMBER;
 --  TYPE packet_data_type IS TABLE OF GL_BC_PACKETS.PACKET_ID%TYPE;
    l_packet_data_tab packet_data_type;


   CURSOR get_trx_id
   IS
     SELECT   trx_id
     FROM     igi_dos_trx_headers
     WHERE     trx_number = P_TRX_NUMBER;

   CURSOR   get_packets
   IS
     SELECT   *
     FROM     igi_dos_trx_sources
     WHERE    trx_id = l_trx_id;

   -- Bug 1635678 sekhar kappaga
   CURSOR get_dest (p_source_trx_id  igi_dos_trx_dest.source_trx_id%TYPE)
   IS
     SELECT *
     FROM  igi_dos_trx_dest
     WHERE trx_id = l_trx_id
     AND   source_trx_id = p_source_trx_id;

   CURSOR get_currency_code
   IS
     SELECT currency_code
     FROM gl_sets_of_books
     WHERE set_of_books_id = l_sob_id;

 BEGIN
 --bug 9128478 : intializing the packet count
   l_packet_count := 0;

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg1',
                         ' ** BEGIN APPROVE ** ');
   -- =============== END DEBUG LOG ==================

   l_sob_id := p_sob_id;

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg2.1',
                         ' l_sob_id --> ' || l_sob_id);
   -- =============== END DEBUG LOG ==================


   -- Bug 1635678 sekhar kappaga.
   OPEN  get_currency_code;
   FETCH get_currency_code into l_currency_code;
   CLOSE get_currency_code;

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg2.2',
                         ' l_currency_code --> ' || l_currency_code);
   -- =============== END DEBUG LOG ==================

   OPEN  get_trx_id;
   FETCH get_trx_id into l_trx_id;
   CLOSE get_trx_id;

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg3',
                         ' l_trx_id --> ' || l_trx_id);
   -- =============== END DEBUG LOG ==================

   l_user_id := fnd_global.user_id;

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg4',
                         ' l_user_id --> ' || l_user_id);
   -- =============== END DEBUG LOG ==================

   l_responsibility_id := fnd_global.resp_id;

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg4.1',
                         ' l_responsibility_id --> ' || l_responsibility_id);
   -- =============== END DEBUG LOG ==================

   l_resp_appl_id := fnd_global.resp_appl_id;

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg4.1',
                         ' l_resp_appl_id --> ' || l_resp_appl_id);
   -- =============== END DEBUG LOG ==================

   -- Get the translation of Transfer
   temp := 'Transfer';

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg5',
                         ' CALLING GL_JE_SOURCES_PKG.select_columns ');
       Debug_log_string (l_proc_level, 'Approve.Msg6',
                         ' temp --> '|| temp);
       Debug_log_string (l_proc_level, 'Approve.Msg7',
                         ' user_transfer --> ' || user_transfer);
       Debug_log_string (l_proc_level, 'Approve.Msg8',
                         ' effective_date_rule_code --> ' || effective_date_rule_code);
       Debug_log_string (l_proc_level, 'Approve.Msg9',
                         ' frozen_source_flag --> ' || frozen_source_flag);
       Debug_log_string (l_proc_level, 'Approve.Msg10',
                         ' approval_flag --> ' || approval_flag);
   -- =============== END DEBUG LOG ==================

   GL_JE_SOURCES_PKG.select_columns( X_JE_SOURCE_NAME           => temp,
                                     X_USER_JE_SOURCE_NAME      => user_transfer,
                                     X_EFFECTIVE_DATE_RULE_CODE => effective_date_rule_code,
                                     X_FROZEN_SOURCE_FLAG       => frozen_source_flag,
                                     X_JOURNAL_APPROVAL_FLAG    => approval_flag);

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg11',
                         ' AFTER GL_JE_SOURCES_PKG.select_columns ');
       Debug_log_string (l_proc_level, 'Approve.Msg12',
                         ' temp --> '|| temp);
       Debug_log_string (l_proc_level, 'Approve.Msg13',
                         ' user_transfer --> ' || user_transfer);
       Debug_log_string (l_proc_level, 'Approve.Msg14',
                         ' effective_date_rule_code --> ' || effective_date_rule_code);
       Debug_log_string (l_proc_level, 'Approve.Msg15',
                         ' frozen_source_flag --> ' || frozen_source_flag);
       Debug_log_string (l_proc_level, 'Approve.Msg16',
                         ' approval_flag --> ' || approval_flag);
   -- =============== END DEBUG LOG ==================

   -- Get the translation of Budget
   temp := 'Budget';

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg17',
                         ' CALLING GL_JE_CATEGORIES_PKG.select_columns ');
       Debug_log_string (l_proc_level, 'Approve.Msg18',
                         ' temp --> '|| temp);
       Debug_log_string (l_proc_level, 'Approve.Msg19',
                         ' user_budget --> ' || user_budget);
   -- =============== END DEBUG LOG ==================

   GL_JE_CATEGORIES_PKG.select_columns ( X_JE_CATEGORY_NAME      => temp,
                                         X_USER_JE_CATEGORY_NAME => user_budget);


   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg20',
                         ' AFTER GL_JE_CATEGORIES_PKG.select_columns ');
       Debug_log_string (l_proc_level, 'Approve.Msg21',
                         ' temp --> '|| temp);
       Debug_log_string (l_proc_level, 'Approve.Msg23',
                         ' user_budget --> ' || user_budget);
   -- =============== END DEBUG LOG ==================

    --get the encumbrance id
    SELECT encumbrance_type_id
    INTO   v_encumbrance_type_id
    FROM   gl_encumbrance_types
    WHERE upper(encumbrance_type) = 'DOSSIER' ;

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg24',
                         ' v_encumbrance_type_id --> ' || v_encumbrance_type_id);
   -- =============== END DEBUG LOG ==================

   -- Bug 9128478 : Initializing the packet data table
   l_packet_data_tab := packet_data_type();
    FOR packet_rec IN get_packets
    LOOP

      -- Bug 9128478 : Incrementing the packet count and table
      l_packet_count := l_packet_count + 1;
      l_packet_data_tab.extend(1);
      l_packet_id :=packet_rec.group_id;

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Approve.Msg25',
                           ' l_packet_id --> ' || l_packet_id);
      -- =============== END DEBUG LOG ==================

      SELECT gl_bc_packets_s.nextval
      INTO v_packet_id
      FROM dual;

      -- Bug 9128478 : Storing the generated packet details
      l_packet_data_tab(l_packet_count) := v_packet_id;
      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Approve.Msg26',
                           ' v_packet_id --> ' || v_packet_id);
      -- =============== END DEBUG LOG ==================
       l_packet_data_tab(l_packet_count) := v_packet_id;
 -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Approve.Msg26.1',
                              'l_packet_count --> '|| l_packet_count);
  -- =============== END DEBUG LOG ==================
      --get the total amount for the source budget journal
      SELECT nvl(sum(dest.budget_amount),0)
      INTO   v_source_amount
      FROM   igi_dos_trx_dest dest
      WHERE  dest.source_trx_id = packet_rec.source_trx_id;

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Approve.Msg35',
                           ' INSERTING INTO gl_bc_packets for source enc ');
         Debug_log_string (l_proc_level, 'Approve.Msg36',
                           ' CREDIT SOURCE AMOUNT --> ' || v_source_amount );
      -- =============== END DEBUG LOG ==================
   /* Commented for bug 6126275 */
      -- Bug 3627318
      -- reversing the encumbrance for source.
   /*   INSERT INTO gl_bc_packets (status_code,
                                 packet_id,
                                -- Set_of_books_id,  -- Commented for bug 6126275
                                 ledger_id,    -- Added for bug 6126275
                                 je_source_name,
                                 je_category_name,
                                 code_combination_id,
                                 actual_flag,
                                 period_name,
                                 period_year,
                                 period_num,
                                 quarter_num,
                                 currency_code,
                                 last_update_date,
                                 last_updated_by,
                                 budget_version_id,
                                 entered_dr,
                                 entered_cr,
                                 accounted_dr,
                                 accounted_cr,
                                 je_batch_name,
                                 reference1,
                                 reference2,
                                 encumbrance_type_id )
                         VALUES
                                 ('P',
                                  v_packet_id,
                                  packet_rec.sob_id,
                                  'Transfer',
                                  'Budget',
                                  packet_rec.code_combination_id,
                                  'E',
                                  packet_rec.period_name,
                                  packet_rec.period_year,
                                  packet_rec.period_num,
                                  packet_rec.quarter_num,
                                  l_currency_code,
                                  sysdate,
                                  l_user_id,
                                  null,
                                  null,
                                  v_source_amount,
                                  null,
                                  v_source_amount,
                                  'Budget '||packet_rec.dossier_id,
                                  packet_rec.dossier_id || '..' ||        -- Bug 3466463
                                  packet_rec.trx_id,                  -- packet_rec.trx_id,
                                  packet_rec.source_trx_id,
                                  v_encumbrance_type_id);

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Approve.Msg27',
                           ' INSERT INTO gl_bc_packets --> ' || SQL%ROWCOUNT);
      -- =============== END DEBUG LOG ==================

      -- Bug 1635678 sekhar kappaga  budget jounral for the source key ---
      INSERT INTO gl_bc_packets
                                (status_code,
                                 packet_id,
                                  -- Set_of_books_id,  -- Commented for bug 6126275
                                 ledger_id,   -- Added for bug 6126275
                                 je_source_name,
                                 je_category_name,
                                 code_combination_id,
                                 actual_flag,
                                 period_name,
                                 period_year,
                                 period_num,
                                 quarter_num,
                                 currency_code,
                                 last_update_date,
                                 last_updated_by,
                                 budget_version_id,
                                 entered_dr,
                                 entered_cr,
                                 accounted_dr,
                                 accounted_cr,
                                 je_batch_name,
                                 reference1,
                                 reference2 )
            	         VALUES
                                 ('P',
                                  v_packet_id,
                                  packet_rec.sob_id,
                                  'Transfer',
                                  'Budget',
                                  packet_rec.code_combination_id,
                                  'B',
                                  packet_rec.period_name,
                                  packet_rec.period_year,
                                  packet_rec.period_num,
                                  packet_rec.quarter_num,
                                  l_currency_code,
                                  sysdate,
                                  l_user_id,
                                  packet_rec.budget_version_id,
                                  null,
                                  v_source_amount,
                                  null,
                                  v_source_amount,
                                  'Budget '||packet_rec.dossier_id,
                                  packet_rec.dossier_id || '..' ||      -- Bug 3466463
                                  packet_rec.trx_id,                   -- packet_rec.trx_id,
                                  packet_rec.source_trx_id);

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Approve.Msg30',
                           ' INSERTED --> ' || SQL%ROWCOUNT);
         Debug_log_string (l_proc_level, 'Approve.Msg31',
                           ' INSERTING INTO gl_bc_packets for budget');
         Debug_log_string (l_proc_level, 'Approve.Msg32',
                           ' CREDIT SOURCE AMOUNT --> ' || v_source_amount);
      -- =============== END DEBUG LOG ==================


        -- Bug 1635678 sekhar kappaga  budget jounral for the destination key  start ---
        FOR dest_rec IN get_dest(packet_rec.source_trx_id)
        LOOP

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Approve.Msg34',
                              ' In to dest_rec loop ');
            Debug_log_string (l_proc_level, 'Approve.Msg35',
                           ' INSERTING INTO gl_bc_packets for budget');
            Debug_log_string (l_proc_level, 'Approve.Msg36',
                           ' DEBIT DEST AMOUNT --> ' || dest_rec.budget_amount);
          -- =============== END DEBUG LOG ==================

         INSERT INTO gl_bc_packets
                                  (status_code,
                                   packet_id,
                                    -- Set_of_books_id,  -- Commented for bug 6126275
                                   ledger_id,   -- Added for bug 6126275
                                   je_source_name,
                                   je_category_name,
                                   code_combination_id,
                                   actual_flag,
                                   period_name,
                                   period_year,
                                   period_num,
                                   quarter_num,
                                   currency_code,
                                   last_update_date,
                                   last_updated_by,
                                   budget_version_id,
                                   entered_dr,
                                   entered_cr,
                                   accounted_dr,
                                   accounted_cr,
                                   je_batch_name,
                                   reference1,
                                   reference2 )
                         VALUES   ('P',
                                   v_packet_id,
                                   dest_rec.sob_id,
                                   'Transfer',
                                   'Budget',
                                   dest_rec.code_combination_id,
                                   'B',
                                   dest_rec.period_name,
                                   dest_rec.period_year,
                                   dest_rec.period_num,
                                   dest_rec.quarter_num,
                                   l_currency_code,
                                   sysdate,
                                   l_user_id,
                                   dest_rec.budget_version_id,
                                   dest_rec.budget_amount,
                                   null,
                                   dest_rec.budget_amount,
                                   null,
                                   'Dossier ' ||ltrim(to_char(dest_rec.dossier_id))
                                              || ' ' || dest_rec.period_name,
                                  to_char(dest_rec.dossier_id) || '..' ||       -- Bug 3466463
                                          dest_rec.trx_id,                 -- ltrim(to_char(dest_rec.dossier_id)),
                                  dest_rec.dest_trx_id);               -- 'New Budget Tranfer Row' );





         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Approve.Msg37',
                              ' INSERTED --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

	END LOOP;  */


    /* bug 6126175 start */
    -- AUTONOMOUS procedure

                  insert_row (v_packet_id,
                             packet_rec.sob_id,
                             packet_rec.code_combination_id,
                             packet_rec.period_name,
                             packet_rec.period_year,
                             packet_rec.period_num,
                             packet_rec.quarter_num,
                             l_currency_code,
                             l_user_id,
                             v_source_amount,
                             packet_rec.dossier_id,
                             packet_rec.trx_id,
                             v_encumbrance_type_id,
                             packet_rec.budget_version_id,
                             packet_rec.source_trx_id );
    /* end bug 6126275 */

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Approve.Msg38',
                           ' CALLING GL_FUNDS_CHECKER_PKG.glxfck ');
         Debug_log_string (l_proc_level, 'Approve.Msg39',
                           ' P_SOBID --> ' || l_sob_id);
         Debug_log_string (l_proc_level, 'Approve.Msg40',
                           ' P_PACKETID --> ' || v_packet_id);
         Debug_log_string (l_proc_level, 'Approve.Msg41',
                           ' P_MODE --> R');
         Debug_log_string (l_proc_level, 'Approve.Msg42',
                           ' P_PARTIAL_RESV_FLAG --> N ');
         Debug_log_string (l_proc_level, 'Approve.Msg43',
                           ' P_OVERRIDE --> Y ');
         Debug_log_string (l_proc_level, 'Approve.Msg44',
                           ' P_CONC_FLAG --> N ');
         Debug_log_string (l_proc_level, 'Approve.Msg45',
                           ' P_USER_ID --> ' || l_user_id);
         Debug_log_string (l_proc_level, 'Approve.Msg46',
                           ' P_USER_RESP_ID --> ' || l_responsibility_id);
     -- =============== END DEBUG LOG ==================

      -- Bug 1635678 sekhar kappaga  budget jounral for the destination key  end ---
   /* Commented GL_FUNDS_CHECKER code and added PSA_FUNDS_CHECKER_PKG for bug 6126275 */
   /*  IF GL_FUNDS_CHECKER_PKG.glxfck ( P_SOBID             => l_sob_id ,
                                       P_PACKETID          => v_packet_id ,
                                       P_MODE              => 'R',
                                       P_PARTIAL_RESV_FLAG => 'N',
                                       P_OVERRIDE          => 'Y',
                                       P_CONC_FLAG         => 'N',
                                       P_USER_ID           => l_user_id,
                                       P_USER_RESP_ID     => l_responsibility_id,
                                       P_RETURN_CODE       => l_return_code ) */

    IF PSA_FUNDS_CHECKER_PKG.glxfck ( p_ledgerid             => l_sob_id ,
                                       P_PACKETID          => v_packet_id ,
                                       P_MODE              => 'R',
                                       P_OVERRIDE          => 'Y',
                                       P_CONC_FLAG         => 'N',
                                       P_USER_ID           => l_user_id,
                                       P_USER_RESP_ID     => l_responsibility_id,
                                       P_CALLING_PROG_FLAG => 'G',
                                       P_RETURN_CODE       => l_return_code )
THEN

            IF l_return_code = 'S' OR  l_return_code = 'A' THEN
         NULL;
            ELSE
  -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Approve.Msg47',
                              'Calling Packet_Error procedure');
   -- =============== END DEBUG LOG ==================
                Packet_Error(l_packet_count , l_packet_data_tab);
                RETURN FALSE;
            END IF;
         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Approve.Msg48',
                              ' GL_FUNDS_CHECKER_PKG.glxfck --> TRUE');
         -- =============== END DEBUG LOG ==================
        ELSE
         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Approve.Msg49',
                              ' GL_FUNDS_CHECKER_PKG.glxfck --> FALSE');
         -- =============== END DEBUG LOG ==================
       -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Approve.Msg49.1',
                              'Calling Packet_Error procedure');
   -- =============== END DEBUG LOG ==================
                Packet_Error(l_packet_count , l_packet_data_tab);
         -- =============== START DEBUG LOG ================
                   Debug_log_string (l_proc_level, 'Approve.Msg53',
                             ' ** Updating status of all packets to false ** ');
         -- =============== END DEBUG LOG ==================
            RETURN FALSE;
        END IF;

     -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Approve.Msg50',
                           ' P_RETURN_CODE --> ' || l_return_code);
     -- =============== END DEBUG LOG ==================

    END LOOP;

    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Approve.Msg51',
                         ' RETURN TRUE ');
       Debug_log_string (l_proc_level, 'Approve.Msg52',
                         ' ** END APPROVE ** ');
    -- =============== END DEBUG LOG ==================

    RETURN TRUE;

 EXCEPTION
    WHEN OTHERS THEN
       -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Approve.Msg53',
                              'Calling Packet_Error procedure');
   -- =============== END DEBUG LOG ==================
          Packet_Error(l_packet_count , l_packet_data_tab);
        -- =============== START DEBUG LOG ================
           DEBUG_LOG_UNEXP_ERROR ('Approve.unexp1','DEFAULT');
        -- =============== END DEBUG LOG ==================
        RETURN FALSE;
 END Approve;


 /* ============================ REJECT ======================= */

 FUNCTION Reject   ( p_trx_number         IN VARCHAR2,
                     p_user_id            IN VARCHAR2,
                     p_responsibility_id  IN VARCHAR2,
                     p_sob_id             IN VARCHAR2)
 RETURN BOOLEAN
 IS

    l_trx_id                    NUMBER;
    l_packet_id                 NUMBER;
    v_packet_id                 NUMBER;
    l_return_code               VARCHAR2(30);
    l_user_id                   VARCHAR2(30) :=p_user_id;
    l_responsibility_id         VARCHAR2(30) :=p_responsibility_id ;
    l_sob_id                    VARCHAR2(30) :=p_sob_id ;
    v_source_amount             NUMBER;
    user_transfer 		        VARCHAR2(30);
    user_budget 		        VARCHAR2(30);
    temp 			        VARCHAR2(30);
    effective_date_rule_code    VARCHAR2(2);
    frozen_source_flag          VARCHAR2(2);
    reversal_option_code        VARCHAR2(2);
    approval_flag               VARCHAR2(2);
    v_user_id 		            NUMBER(15);
    v_encumbrance_type_id       NUMBER;
    l_currency_code 	VARCHAR2(15);
-- Bug 9128478 : Added
    l_packet_count NUMBER;
 --  TYPE packet_data_type IS TABLE OF GL_BC_PACKETS.PACKET_ID%TYPE;
    l_packet_data_tab packet_data_type;

   -- Bug 1635678 sekhar kappaga
   CURSOR get_dest (p_source_trx_id  igi_dos_trx_dest.source_trx_id%TYPE)
   IS
     SELECT *
     FROM  igi_dos_trx_dest
     WHERE trx_id = l_trx_id
     AND   source_trx_id = p_source_trx_id;


   CURSOR   get_trx_id
   IS
      SELECT   trx_id
      FROM     igi_dos_trx_headers
      WHERE     trx_number = p_trx_NUMBER;

   CURSOR   get_packets
   IS
      SELECT   *
      FROM     igi_dos_trx_sources
      WHERE    trx_id = l_trx_id;

   CURSOR get_currency_code
   IS
      SELECT currency_code
      FROM gl_sets_of_books
      WHERE set_of_books_id = l_sob_id;


 BEGIN
       l_packet_count := 0;
   -- =============== START DEBUG LOG ================
      Debug_log_string (l_proc_level, 'Reject.Msg1',
                        ' ** BEGIN REJECT ** ');
   -- =============== END DEBUG LOG ==================
        -- Bug 9128478 : Initializing the packet data table
       l_packet_data_tab := packet_data_type();

   OPEN  get_currency_code;
   FETCH get_currency_code into l_currency_code;
   CLOSE get_currency_code;

   -- =============== START DEBUG LOG ================
      Debug_log_string (l_proc_level, 'Reject.Msg2',
                        ' l_currency_code --> ' || l_currency_code);
   -- =============== END DEBUG LOG ==================

   OPEN  get_trx_id;
   FETCH get_trx_id into l_trx_id;
   CLOSE get_trx_id;

   -- =============== START DEBUG LOG ================
      Debug_log_string (l_proc_level, 'Reject.Msg3',
                        ' l_trx_id --> ' || l_trx_id);
   -- =============== END DEBUG LOG ==================

   v_user_id := fnd_global.user_id;

   -- =============== START DEBUG LOG ================
      Debug_log_string (l_proc_level, 'Reject.Msg4',
                        ' v_user_id --> ' || v_user_id);
   -- =============== END DEBUG LOG ==================

   l_responsibility_id := fnd_global.resp_id;

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Reject.Msg4.1',
                         ' l_responsibility_id --> ' || l_responsibility_id);
   -- =============== END DEBUG LOG ==================

   -- Get the translation of Transfer
   temp := 'Transfer';

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Reject.Msg5',
                         ' CALLING GL_JE_SOURCES_PKG.select_columns ');
       Debug_log_string (l_proc_level, 'Reject.Msg6',
                         ' temp --> '|| temp);
       Debug_log_string (l_proc_level, 'Reject.Msg7',
                         ' user_transfer --> ' || user_transfer);
       Debug_log_string (l_proc_level, 'Reject.Msg8',
                         ' effective_date_rule_code --> ' || effective_date_rule_code);
       Debug_log_string (l_proc_level, 'Reject.Msg9',
                         ' frozen_source_flag --> ' || frozen_source_flag);
       Debug_log_string (l_proc_level, 'Reject.Msg10',
                         ' approval_flag --> ' || approval_flag);
   -- =============== END DEBUG LOG ==================

   GL_JE_SOURCES_PKG.select_columns( X_JE_SOURCE_NAME           => temp,
                                     X_USER_JE_SOURCE_NAME      => user_transfer,
                                     X_EFFECTIVE_DATE_RULE_CODE => effective_date_rule_code,
                                     X_FROZEN_SOURCE_FLAG       => frozen_source_flag,
                                     X_JOURNAL_APPROVAL_FLAG    => approval_flag);

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Reject.Msg11',
                         ' AFTER GL_JE_SOURCES_PKG.select_columns ');
       Debug_log_string (l_proc_level, 'Reject.Msg12',
                         ' temp --> '|| temp);
       Debug_log_string (l_proc_level, 'Reject.Msg13',
                         ' user_transfer --> ' || user_transfer);
       Debug_log_string (l_proc_level, 'Reject.Msg14',
                         ' effective_date_rule_code --> ' || effective_date_rule_code);
       Debug_log_string (l_proc_level, 'Reject.Msg15',
                         ' frozen_source_flag --> ' || frozen_source_flag);
       Debug_log_string (l_proc_level, 'Reject.Msg16',
                         ' approval_flag --> ' || approval_flag);
   -- =============== END DEBUG LOG ==================

   -- Get the translation of Budget
   temp := 'Budget';

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Reject.Msg17',
                         ' CALLING GL_JE_CATEGORIES_PKG.select_columns ');
       Debug_log_string (l_proc_level, 'Reject.Msg18',
                         ' temp --> '|| temp);
       Debug_log_string (l_proc_level, 'Reject.Msg19',
                         ' user_budget --> ' || user_budget);
   -- =============== END DEBUG LOG ==================

   GL_JE_CATEGORIES_PKG.select_columns ( X_JE_CATEGORY_NAME      => temp,
                                         X_USER_JE_CATEGORY_NAME => user_budget);


   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Reject.Msg20',
                         ' AFTER GL_JE_CATEGORIES_PKG.select_columns ');
       Debug_log_string (l_proc_level, 'Reject.Msg21',
                         ' temp --> '|| temp);
       Debug_log_string (l_proc_level, 'Reject.Msg23',
                         ' user_budget --> ' || user_budget);
   -- =============== END DEBUG LOG ==================

    --get the encumbrance id
    SELECT encumbrance_type_id
    INTO   v_encumbrance_type_id
    FROM   gl_encumbrance_types
    WHERE upper(encumbrance_type) = 'DOSSIER' ;

   -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Reject.Msg24',
                         ' v_encumbrance_type_id --> ' || v_encumbrance_type_id);
   -- =============== END DEBUG LOG ==================


        FOR packet_rec IN get_packets
        LOOP
          -- Bug 9128478 : Incrementing the packet count and table
         l_packet_count := l_packet_count + 1;
         l_packet_data_tab.extend(1);
         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Reject.Msg25',
                              ' INTO get packest cursor');
         -- =============== END DEBUG LOG ==================

         l_packet_id := packet_rec.group_id;

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Reject.Msg26',
                              ' l_packet_id --> '|| l_packet_id);
         -- =============== END DEBUG LOG ==================

         SELECT gl_bc_packets_s.nextval
         INTO v_packet_id
         FROM dual;

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Reject.Msg27',
                              ' v_packet_id --> '|| v_packet_id);
         -- =============== END DEBUG LOG ==================
     -- Bug 9128478 : Storing the generated packet details
      l_packet_data_tab(l_packet_count) := v_packet_id;
 -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Reject.Msg27.1',
                              'l_packet_count --> '|| l_packet_count);
  -- =============== END DEBUG LOG ==================

	 SELECT nvl(sum(dest.budget_amount),0)
         INTO v_source_amount
	 FROM   igi_dos_trx_dest dest
         WHERE  dest.source_trx_id = packet_rec.source_trx_id;

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Reject.Msg28',
                           ' v_source_amount --> ' || v_source_amount);
         Debug_log_string (l_proc_level, 'Reject.Msg29',
                           ' INSERTING INTO gl_bc_packets ');
         Debug_log_string (l_proc_level, 'Reject.Msg30',
                           ' CREDIT SOURCE AMOUNT --> ' || v_source_amount);
      -- =============== END DEBUG LOG ==================
/* Commented for bug 6126275 */
/*
      -- Bug 3627318
      -- reversing the encumbrance for source.
      INSERT INTO gl_bc_packets (status_code,
                                 packet_id,
                                  -- Set_of_books_id,  -- Commented for bug 6126275
                                 ledger_id,   --Added for bug 6126275
                                 je_source_name,
                                 je_category_name,
                                 code_combination_id,
                                 actual_flag,
                                 period_name,
                                 period_year,
                                 period_num,
                                 quarter_num,
                                 currency_code,
                                 last_update_date,
                                 last_updated_by,
                                 budget_version_id,
                                 entered_dr,
                                 entered_cr,
                                 accounted_dr,
                                 accounted_cr,
                                 je_batch_name,
                                 reference1,
                                 reference2,
                                 encumbrance_type_id)
                         VALUES
                                 ('P',
                                  v_packet_id,
                                  packet_rec.sob_id,
                                  'Transfer',
                                  'Budget',
                                  packet_rec.code_combination_id,
                                  'E',
                                  packet_rec.period_name,
                                  packet_rec.period_year,
                                  packet_rec.period_num,
                                  packet_rec.quarter_num,
                                  l_currency_code,
                                  sysdate,
                                  v_user_id,
                                  null,
                                  null,
                                  v_source_amount,
                                  null,
                                  v_source_amount,
                                  'Budget '||packet_rec.dossier_id,
                                  packet_rec.dossier_id || '..' ||    -- Bug 3466463
                                  packet_rec.trx_id,                  -- packet_rec.trx_id,
                                  packet_rec.source_trx_id,
                                  v_encumbrance_type_id);

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Reject.Msg31',
                           ' INSERT INTO gl_bc_packets --> ' || SQL%ROWCOUNT);
      -- =============== END DEBUG LOG ==================  */

    /* bug 6126275 start */
         reject_insert_row ( v_packet_id,
                             packet_rec.sob_id,
                             packet_rec.code_combination_id,
                             packet_rec.period_name,
                             packet_rec.period_year,
                             packet_rec.period_num,
                             packet_rec.quarter_num,
                             l_currency_code,
                             v_user_id,
                             v_source_amount,
                             packet_rec.dossier_id,
                             packet_rec.trx_id,
                             v_encumbrance_type_id,
                             packet_rec.source_trx_id);
    /* end bug 6126275 */

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Reject.Msg32',
                           ' CALLING GL_FUNDS_CHECKER_PKG.glxfck ');
         Debug_log_string (l_proc_level, 'Reject.Msg33',
                           ' P_SOBID --> ' || l_sob_id);
         Debug_log_string (l_proc_level, 'Reject.Msg34',
                           ' P_PACKETID --> ' || v_packet_id);
         Debug_log_string (l_proc_level, 'Reject.Msg35',
                           ' P_MODE --> R');
         Debug_log_string (l_proc_level, 'Reject.Msg36',
                           ' P_PARTIAL_RESV_FLAG --> N ');
         Debug_log_string (l_proc_level, 'Reject.Msg37',
                           ' P_OVERRIDE --> Y ');
         Debug_log_string (l_proc_level, 'Reject.Msg38',
                           ' P_CONC_FLAG --> N ');
         Debug_log_string (l_proc_level, 'Reject.Msg39',
                           ' P_USER_ID --> ' || l_user_id);
         Debug_log_string (l_proc_level, 'Reject.Msg40',
                           ' P_USER_RESP_ID --> ' || l_responsibility_id);
     -- =============== END DEBUG LOG ==================

      -- Bug 1635678 sekhar kappaga  budget jounral for the destination key  end ---
  /* Commented GL_FUND_CHECKER_PKG and added PSA_FUNDS_CHECKER_PKG for R12 uptake of Dossier - bug 6126275 */
 /* IF GL_FUNDS_CHECKER_PKG.glxfck ( P_SOBID             => l_sob_id ,
                                       P_PACKETID          => v_packet_id ,
                                       P_MODE              => 'R',
                                       P_PARTIAL_RESV_FLAG => 'N',
                                       P_OVERRIDE          => 'Y',
                                       P_CONC_FLAG         => 'N',
                                       P_USER_ID           => l_user_id,
                                       P_USER_RESP_ID     => l_responsibility_id,
                                       P_RETURN_CODE       => l_return_code ) */
IF PSA_FUNDS_CHECKER_PKG.glxfck ( p_ledgerid             => l_sob_id ,
                                       P_PACKETID          => v_packet_id ,
                                       P_MODE              => 'R',
                                       P_OVERRIDE          => 'Y',
                                       P_CONC_FLAG         => 'N',
                                       P_USER_ID           => l_user_id,
                                       P_USER_RESP_ID     => l_responsibility_id,
                                       P_CALLING_PROG_FLAG => 'G',
                                       P_RETURN_CODE       => l_return_code) THEN
            IF l_return_code = 'S' OR  l_return_code = 'A' THEN

         NULL;
            ELSE
         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Reject.Msg40.1',
                              'Calling Packet_Error procedure');
   -- =============== END DEBUG LOG ==================
                Packet_Error(l_packet_count , l_packet_data_tab);
                RETURN FALSE;
            END IF;
         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Reject.Msg41',
                              ' GL_FUNDS_CHECKER_PKG.glxfck --> TRUE');
         -- =============== END DEBUG LOG ==================
        ELSE
   -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Reject.Msg41.1',
                              'Calling Packet_Error procedure');
   -- =============== END DEBUG LOG ==================
              Packet_Error(l_packet_count , l_packet_data_tab);
              RETURN FALSE;
         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Reject.Msg42',
                              ' GL_FUNDS_CHECKER_PKG.glxfck --> FALSE');
         -- =============== END DEBUG LOG ==================
        END IF;

     -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Reject.Msg43',
                           ' P_RETURN_CODE --> ' || l_return_code);
     -- =============== END DEBUG LOG ==================

    END LOOP;


    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Reject.Msg44',
                         ' RETURN TRUE ');
       Debug_log_string (l_proc_level, 'Reject.Msg45',
                         ' ** END APPROVE ** ');
    -- =============== END DEBUG LOG ==================

    RETURN TRUE;

 EXCEPTION
    WHEN OTHERS THEN
        -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Reject.Msg46',
                              'Calling Packet_Error procedure');
   -- =============== END DEBUG LOG ==================
     Packet_Error(l_packet_count , l_packet_data_tab);
        -- =============== START DEBUG LOG ================
           DEBUG_LOG_UNEXP_ERROR ('Reject.unexp1','DEFAULT');
        -- =============== END DEBUG LOG ==================
        RETURN FALSE;

END Reject;
-- Bug 9128478: Partial dossier level reservation is not
--              supported by Dossier
--              Setting the status_code of all previously
--              approved packets to 'T' as suggested by the PSA team

PROCEDURE Packet_Error(p_packet_count IN NUMBER,
                       p_packet_data_tab IN packet_data_type) IS
BEGIN
 -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Packet.Msg1',
                              'Entering the Packet_Error procedure');
         -- =============== END DEBUG LOG ==================
           FOR cnt IN 1..p_packet_count-1 LOOP
                UPDATE gl_bc_packets
                SET status_code = 'T'
                WHERE packet_id = p_packet_data_tab(cnt);
                UPDATE gl_bc_packet_arrival_order ao
                SET ao.affect_funds_flag = 'N'
                WHERE ao.packet_id = p_packet_data_tab(cnt);
            END LOOP;
            UPDATE gl_bc_packets
            SET status_code = 'T'
            WHERE packet_id = p_packet_data_tab(p_packet_count)
            AND status_code IN('P','A');
            UPDATE gl_bc_packet_arrival_order ao
            SET ao.affect_funds_flag = 'N'
            WHERE ao.packet_id = p_packet_data_tab(p_packet_count);
          -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Packet_Error.Msg1',
                              'Updated the previous records');
         -- =============== END DEBUG LOG ==================
EXCEPTION
    WHEN OTHERS THEN
        -- =============== START DEBUG LOG ================
           DEBUG_LOG_UNEXP_ERROR ('Packet_Error.unexp1','DEFAULT');
        -- =============== END DEBUG LOG ==================
END Packet_Error;
END igi_dos_funds;


/
