--------------------------------------------------------
--  DDL for Package Body XLA_TB_DATA_MANAGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TB_DATA_MANAGER_PVT" AS
/* $Header: xlatbdmg.pkb 120.25.12010000.15 2010/03/26 07:24:23 rajose ship $   */
/*===========================================================================+
|             Copyright (c) 2005-2006 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         ALL rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_tb_data_manager_pvt                                                |
|                                                                            |
| DESCRIPTION                                                                |
|     This IS a XLA PRIVATE PACKAGE, which contains ALL THE logic required   |
|     TO upload trial balance data INTO xla_trial_balances                   |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     07-OCT-2005 M.Asada    Created                                         |
|     20-May-2008 schodava   Bug 7109823 - TB Remodelling                    |
|     29-May-2008 rajose     bug#7109823 Dynamic building of where clause    |
|                            for accounting_class_code defined for           |
|                            program code for an application.                |
|     18-June-2008 rajose    bug#7109823 Added index(xah XLA_AE_HEADERS_U1)  |
|                            hint in the 3 sql's to improve performance.     |
|			     Addition of the hint has improved performance   |
|			     for US GAP customer Refer bug#6990540           |
|     4-Jul-2008   rajose    bug#7225096 fix for ORA-00911: invalid character|
|                            error                                           |
|     1-Sep-2008   rajose    bug#7320079 To move all GSI changes performance |
|                            recovery to branchline code. Passed             |
|                            p_je_source name to worker_process so that      |
|			     insert_trial_balance_wu will insert data into   |
|                            tb table if transfer to GL is spawned by an     |
|			     application other than Payables and acctng class|
|			     code is registered in Post Programs.            |
|     23-Sep-2008  rajose    bug#7364921 Upgraded invoices not appearing in  |
|                            the TB report for a given date range.           |
|     19-Nov-2008  rajose    bug#7552876 data manager upload_pvt procedure   |
|                            errors out with ORA-01403: no data found        |
|     27-Nov-2008  rajose    bug#7600550 TB remodeling phase 4. Addresses the|
|                            issue where Open Account AP balances Listing    |
|			     shows no data if new Journal source is added to |
|        		     Definition part of QA bug 7431923               |
|     21-Jan-2008  rajose    bug#7717479 data not appearing for definition   |
|                            code rebuild of reporting ledger                |
|     12-Mar-2009 VGOPISET   Trial balance not rebuild for 11i Data for the  |
|                            Definition Code defined by SEGMENT              |
|     19-Mar-2009 rajose     bug#8333978 Open Account Balances Data Manager  |
|                            main program is taking time to complete.        |
|     22-Jul-2009 nksurana   8348885:Added NO_INDEX on XAL in TBInsert script|
|                            to ignore usage of MIS_XLA_AE_LINES_N1 index.   |
+===========================================================================*/


--
-- Global Variables - WHO Column Information
--

g_request_id         NUMBER(15);
g_user_id            NUMBER(15);
g_login_id           NUMBER(15);
g_prog_appl_id       NUMBER(15);
g_program_id         NUMBER(15);
g_ledger_id          PLS_INTEGER;
g_group_id           xla_ae_headers.group_id%TYPE;
g_definition_code    xla_tb_definitions_b.definition_code%TYPE;
g_process_mode_code  VARCHAR2(30);
g_je_source_name     gl_je_sources.je_source_name%TYPE;
g_application_id     PLS_INTEGER;
g_tb_insert_sql      VARCHAR2(32000);
g_wu_count           PLS_INTEGER;       -- Work Unit Count
g_work_unit          PLS_INTEGER;
g_num_of_workers     PLS_INTEGER;
g_retrieve_wu_flag   BOOLEAN;
g_gl_date_from       VARCHAR2(30);
g_gl_date_to         VARCHAR2(30);
/*------------------------------------------------------------+
|                                                             |
| Template SQL                                                |
|                                                             |
+------------------------------------------------------------*/

-- ********************** Note bug#7213289********************************
-- The hint in the select of C_TB_INSERT_SQL ie
-- /*+ index(xah XLA_AE_HEADERS_U1) */ is replaced in the
-- procedure insert_trial_balance_wu. If any changes are made to the hint
-- in the SELECT, change the replace statement accordingly in
-- insert_trial_balance_wu.
-- **********************End Note*****************************************

C_TB_INSERT_SQL      CONSTANT    VARCHAR2(32000) := '
   INSERT INTO xla_trial_balances (
          record_type_code
         ,source_entity_id
         ,event_class_code
         ,source_application_id
         ,applied_to_entity_id
         ,applied_to_application_id
         ,gl_date
         ,trx_currency_code
         ,entered_rounded_dr
         ,entered_rounded_cr
         ,entered_unrounded_dr
         ,entered_unrounded_cr
         ,acctd_rounded_dr
         ,acctd_rounded_cr
         ,acctd_unrounded_dr
         ,acctd_unrounded_cr
         ,code_combination_id
         ,balancing_segment_value
         ,natural_account_segment_value
         ,cost_center_segment_value
         ,intercompany_segment_value
         ,management_segment_value
         ,ledger_id
         ,definition_code
         ,party_id
         ,party_site_id
         ,party_type_code
         ,ae_header_id
         ,generated_by_code
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date)


   SELECT  /*+ index(xah XLA_AE_HEADERS_U1)  no_index(xal MIS_XLA_AE_LINES_N1) */
           DECODE(xdl.applied_to_entity_id
                ,NULL
                ,''SOURCE''
                ,''APPLIED'')                           record_type_code
         ,xah.entity_id                                 source_entity_id
         ,xet.event_class_code                      	event_class_code
         ,xah.application_id                     	source_application_id
         ,xdl.applied_to_entity_id               	applied_to_entity_id
         ,xdl.applied_to_application_id         	applied_to_application_id
         ,xah.accounting_date                    	gl_date
         ,xal.currency_code                      	trx_currency_code

  -- changes for incorrect trial balance amounts bug 6366295
         -- entered_rounded_dr
         ,decode(nvl(sum(xdl.unrounded_entered_cr), sum(xdl.unrounded_entered_dr)), null, null,
          CASE xlo.acct_reversal_option_code
          WHEN ''SIDE'' THEN
            CASE SIGN(
                  NVL(SUM(xdl.unrounded_entered_dr),0) - NVL(SUM(xdl.unrounded_entered_cr),0)+
                  NVL(SUM(xdl.doc_rounding_entered_amt), 0)
                     )
            WHEN -1 THEN null
            WHEN 1 THEN
              ROUND(
                (NVL(SUM(xdl.unrounded_entered_dr),0) - NVL(SUM(xdl.unrounded_entered_cr),0)+
                NVL(SUM(xdl.doc_rounding_entered_amt), 0))
                /nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
                + decode(xlo.rounding_rule_code,''NEAREST'', 0,''UP'',.5-power(10, -30),''DOWN'',-(.5-power(10, -30)),0))
              *nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
             ELSE
               CASE SIGN(NVL(SUM(xdl.unrounded_accounted_dr),0) - NVL(SUM(xdl.unrounded_accounted_cr),0)
                         +NVL(SUM(xdl.doc_rounding_acctd_amt), 0))
               WHEN -1 THEN null
               WHEN 1 THEN 0
               ELSE DECODE(sum(xdl.unrounded_accounted_cr), 0, to_number(null), 0)
               END
            END
          ELSE DECODE(sum(xdl.unrounded_accounted_cr), null ,
                ROUND(
              (SUM(xdl.unrounded_entered_dr)-NVL(SUM(xdl.doc_rounding_entered_amt), 0))
              /nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
              +decode(xlo.rounding_rule_code,''NEAREST'', 0,''UP'',(.5-power(10, -30)),''DOWN'',-(.5-power(10, -30)),0))
              *nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
           ,ROUND(
              SUM(xdl.unrounded_entered_dr) /nvl(minimum_accountable_unit, power(10, -1* precision))
              +decode(rounding_rule_code,''NEAREST'', 0,''UP'',(.5-power(10, -30)),''DOWN'',-(.5-power(10, -30)),0))
              *nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
           )
         END )     entered_rounded_dr
         -- entered_rounded_cr
        ,decode(nvl(sum(xdl.unrounded_entered_cr), sum(xdl.unrounded_entered_dr)), null, null,
         CASE xlo.acct_reversal_option_code
             WHEN ''SIDE'' THEN
             CASE SIGN(
                  NVL(SUM(xdl.unrounded_entered_cr),0) - NVL(SUM(xdl.unrounded_entered_dr),0)+
                  NVL(SUM(xdl.doc_rounding_entered_amt), 0)
                      )
            WHEN -1 THEN null
            WHEN 1 THEN
              ROUND(
                (NVL(SUM(xdl.unrounded_entered_cr),0) - NVL(SUM(xdl.unrounded_entered_dr),0)+
                NVL(SUM(xdl.doc_rounding_entered_amt), 0))
                /nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
                + decode(xlo.rounding_rule_code,''NEAREST'', 0,''UP'',.5-power(10, -30),''DOWN'',-(.5-power(10, -30)),0))
              *nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
            ELSE
               CASE SIGN(NVL(SUM(xdl.unrounded_accounted_cr),0) - NVL(SUM(xdl.unrounded_accounted_dr),0)
                         +NVL(SUM(xdl.doc_rounding_acctd_amt), 0))
               WHEN -1 THEN null
               WHEN 1 THEN 0
               ELSE DECODE(sum(xdl.unrounded_accounted_cr), 0, 0, null)
               END
            END
           ELSE DECODE(SUM(xdl.unrounded_entered_cr), null, to_number(null) ,
              ROUND(
                (SUM(xdl.unrounded_entered_cr) +
                NVL(SUM(xdl.doc_rounding_entered_amt), 0))
                /fdc.minimum_accountable_unit
                +decode(xlo.rounding_rule_code,''NEAREST'', 0,''UP'',.5-power(10, -30),''DOWN'',-(.5-power(10, -30)),0))
                 *fdc.minimum_accountable_unit)
            END )       entered_rounded_cr

        --entered_unrounded_dr
       ,CASE SIGN(NVL(SUM(xdl.unrounded_entered_cr),0) - NVL(SUM(xdl.unrounded_entered_dr),0)
           )
           WHEN 1 THEN null
           WHEN -1 THEN (NVL(SUM(xdl.unrounded_entered_dr),0) - NVL(SUM(xdl.unrounded_entered_cr),0))
           ELSE 0
           END entered_unrounded_dr

        --entered_unrounded_cr
         ,CASE SIGN(NVL(SUM(xdl.unrounded_entered_cr),0) - NVL(SUM(xdl.unrounded_entered_dr),0)
           )
           WHEN 1 THEN (NVL(SUM(xdl.unrounded_entered_cr),0) - NVL(SUM(xdl.unrounded_entered_dr),0))
           WHEN -1 THEN NULL
           ELSE 0
           END entered_unrounded_cr

         -- accounted_rounded_dr
         , decode(nvl(sum(xdl.unrounded_accounted_cr), sum(xdl.unrounded_accounted_dr)), null, null,
             CASE xlo.acct_reversal_option_code
               WHEN ''SIDE'' THEN
               CASE SIGN(
                  NVL(SUM(xdl.unrounded_accounted_dr),0) - NVL(SUM(xdl.unrounded_accounted_cr),0)-
                  NVL(SUM(xdl.doc_rounding_acctd_amt), 0)
                        )
                WHEN -1 THEN null
                WHEN 1 THEN
            ROUND(
                (NVL(SUM(xdl.unrounded_accounted_dr),0) - NVL(SUM(xdl.unrounded_accounted_cr),0)-
                NVL(SUM(xdl.doc_rounding_acctd_amt), 0))
                /nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
                +decode(xlo.rounding_rule_code,''NEAREST'', 0,''UP'',.5-power(10, -30),''DOWN'',-(.5-power(10, -30)),0))
              *nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
           ELSE
            CASE SIGN(NVL(SUM(xdl.unrounded_entered_dr),0) - NVL(SUM(xdl.unrounded_entered_cr),0)-
                   NVL(SUM(xdl.doc_rounding_entered_amt), 0))
             WHEN -1 THEN null
             WHEN 1 THEN 0
            ELSE DECODE(sum(xdl.unrounded_accounted_cr), 0, to_number(null), 0)
            END
          END
        ELSE
          decode(SUM(xdl.unrounded_accounted_cr), null,
            ROUND(
              (SUM(xdl.unrounded_accounted_dr)-NVL(SUM(xdl.doc_rounding_acctd_amt), 0))
              /nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
              +decode(xlo.rounding_rule_code,''NEAREST'', 0,''UP'',.5-power(10, -30),''DOWN'',-(.5-power(10, -30)),0))
              *nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
           ,ROUND(
              SUM(xdl.unrounded_accounted_dr) /nvl(minimum_accountable_unit, power(10, -1* precision))
              +decode(xlo.rounding_rule_code,''NEAREST'', 0,''UP'',.5-power(10, -30),''DOWN'',-(.5-power(10, -30)),0))
              *nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
         )
        END) accounted_rounded_dr

      -- accounted_rounded_cr
      , decode(nvl(sum(xdl.unrounded_accounted_cr), sum(xdl.unrounded_accounted_dr)), null, null,
        CASE xlo.acct_reversal_option_code
         WHEN ''SIDE'' THEN
         CASE SIGN(
                  NVL(SUM(xdl.unrounded_accounted_cr),0) - NVL(SUM(xdl.unrounded_accounted_dr),0)+
                  NVL(SUM(xdl.doc_rounding_acctd_amt), 0)
                )
         WHEN -1 THEN null
         WHEN 1 THEN
              ROUND(
                (NVL(SUM(xdl.unrounded_accounted_cr),0) - NVL(SUM(xdl.unrounded_accounted_dr),0)+
                NVL(SUM(xdl.doc_rounding_acctd_amt), 0))
                /nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
                +decode(xlo.rounding_rule_code,''NEAREST'', 0,''UP'',.5-power(10, -30),''DOWN'',-(.5-power(10, -30)),0))
              *nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
         ELSE
           CASE SIGN(NVL(SUM(xdl.unrounded_entered_cr),0) - NVL(SUM(xdl.unrounded_entered_dr),0)+
                  NVL(SUM(xdl.doc_rounding_entered_amt), 0))
           WHEN -1 THEN null
           WHEN 1 THEN 0
           ELSE DECODE(sum(xdl.unrounded_accounted_cr), 0, 0, null)
           END
          END
        ELSE DECODE(SUM(xdl.unrounded_accounted_cr), null, to_number(null) ,
              ROUND(
                (SUM(xdl.unrounded_accounted_cr) +
                NVL(SUM(xdl.doc_rounding_acctd_amt), 0))
                /nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
                +decode(xlo.rounding_rule_code,''NEAREST'', 0,''UP'',.5-power(10, -30),''DOWN'',-(.5-power(10, -30)),0))
              *nvl(fdc.minimum_accountable_unit, power(10, -1* fdc.precision))
              )
           END) accounted_rounded_cr

       -- acctd_unrounded_dr
         ,CASE SIGN(NVL(SUM(xdl.unrounded_accounted_cr),0) - NVL(SUM(xdl.unrounded_accounted_dr),0)
           )
           WHEN 1 THEN NULL
           WHEN -1 THEN (NVL(SUM(xdl.unrounded_accounted_dr),0) - NVL(SUM(xdl.unrounded_accounted_cr),0))
           ELSE 0
           END acctd_unrounded_dr

       -- acctd_unrounded_cr
           ,CASE SIGN(NVL(SUM(xdl.unrounded_accounted_cr),0) - NVL(SUM(xdl.unrounded_accounted_dr),0)
           )
           WHEN 1 THEN (NVL(SUM(xdl.unrounded_accounted_cr),0) - NVL(SUM(xdl.unrounded_accounted_dr),0))
           WHEN -1 THEN NULL
           ELSE 0
           END acctd_unrounded_cr
   --end changes bug 6366295
         ,xal.code_combination_id                	code_combination_id
         ,$bal_segment$                          	balancing_segment_value
         ,$acct_segment$                         	natural_account_segment_value
         ,$cc_segment$                           	cost_center_segment_value
         ,$ic_segment$                           	intercompany_segment_value
         ,$mgt_segment$                          	management_segment_value
         ,xah.ledger_id                          	ledger_id
         ,xtd.definition_code                    	DEFINITION_code
         ,xal.party_id                          	party_id
         ,xal.party_site_id                      	party_site_id
         ,xal.party_type_code                   	party_type_code
         ,xah.ae_header_id                       	ae_header_id
         ,''SYSTEM''                             	generated_by_code
         ,SYSDATE                                	creation_date
         ,:1      -- g_user_id
         ,SYSDATE
         ,:2      -- g_user_id
         ,:3      -- g_login_id
         ,:4      -- g_request_id
         ,:5      -- g_prog_appl_id
         ,:6      -- g_program_id
         ,sysdate

 FROM
          xla_ae_headers             xah
         ,xla_ae_lines               xal
         ,xla_distribution_links     xdl
         ,xla_ledger_options         xlo
         ,fnd_currencies             fdc
         ,gl_ledgers                 gl
         ,gl_code_combinations       gcc
         ,xla_event_types_b          xet
         ,xla_tb_definitions_b       xtd
         $l_from$
    WHERE xah.ae_header_id BETWEEN :7 AND :8
      AND xah.upg_batch_id IS NULL                                     -- added bug 6704677
      $l_ledger_where$
      AND xah.gl_transfer_status_code IN (''Y'',''NT'')
      AND xah.application_id        = xal.application_id
      AND xah.ae_header_id          = xal.ae_header_id
      AND xal.application_id        = xdl.application_id (+)
      AND xal.ae_header_id          = xdl.ae_header_id (+)
      AND xal.ae_line_num           = xdl.ae_line_num (+)
      AND xtd.enabled_flag          = ''Y''
      $l_where$
      AND xal.code_combination_id      = gcc.code_combination_id
      AND gcc.chart_of_accounts_id     = :coa_id
      AND xah.application_id           = xet.application_id
      AND xah.event_type_code          = xet.event_type_code
      AND xlo.ledger_id(+)             = xah.ledger_id
      AND xlo.application_id(+)        = xah.application_id
      AND xah.ledger_id                = gl.ledger_id
      AND xah.ledger_id                = xtd.ledger_id --added bug 7359012,one definition code showing data for multilple ledgers in TB report
      AND fdc.currency_code            = gl.currency_code
--- remodeling
     $l_accounting_class_code_where$
     AND xah.event_type_code  <> ''MANUAL''
--- remodeling
    GROUP BY
     DECODE(xdl.applied_to_entity_id
                ,NULL
                ,''SOURCE''
                ,''APPLIED'')
         ,xtd.definition_code
         ,xet.event_class_code
         ,xah.application_id
         ,xdl.applied_to_entity_id
         ,xdl.applied_to_application_id
         ,xal.party_id
         ,xal.party_site_id
         ,xal.party_type_code
         ,xah.entity_id
         ,xah.ledger_id
         ,xah.accounting_date
         ,xah.ae_header_id
         ,xal.currency_code
         ,xal.code_combination_id
         ,$bal_segment$
         ,$acct_segment$
         ,$cc_segment$
         ,$ic_segment$
         ,$mgt_segment$
         ,xlo.acct_reversal_option_code
         ,xlo.rounding_rule_code
         ,fdc.minimum_accountable_unit
         ,fdc.precision
';


 --added bug 6704677
-- 26-Mar-2008 bug#6917849 added 2 insert scripts by splitting C_TB_INSERT_UPG_SQL into
-- C_TB_INSERT_UPG_SQL_AE and C_TB_INSERT_UPG_SQL_SLE. The SQL in the 2 scripts
-- are used to pick the appropriate index in ap_liability_balance table.

--for bug#7364921 did a trunc of xah.accounting_date in the query below
--Reason gl_date is populated with time component and the trial balance report
--query does not fetch data for a date including time stamp
-- example report query date range is '01-MAY-2008' to '31-MAY-2008' and if
-- for a invoice in trial balance table the gl_date is '31-MAY-2008 09:13:00 AM'
-- this invoice will not fall in the above date range. It will fall in the date
-- range for the next day ie '01-MAY-2008' to '01-JUN-2008'

--bug#7717479 commented the join --AND xteu.ledger_id           = alb.set_of_books_id in both
-- the upgrade scripts _AE and _SLE as for reporting ledger this join fails and trial balance is not rebuild
-- cannot remove this join as performance will be affected since ledger_id is
-- leading part of index _N1 in xteu.

--bug#7619431 made the query dynamic so that definition Details/Definition Seg Ranges is used
-- for Flex/Segment Definition, when TB Definition Code is re-built
-- Also, all commented code has been removed from the String as Variable can hold only 32000

C_TB_INSERT_UPG_SQL_AE  CONSTANT    VARCHAR2(32000) := '
 INSERT INTO xla_trial_balances xtb(
          record_type_code
         ,source_entity_id
         ,event_class_code
         ,source_application_id
         ,applied_to_entity_id
         ,applied_to_application_id
         ,gl_date
         ,trx_currency_code
         ,entered_rounded_dr
         ,entered_rounded_cr
         ,entered_unrounded_dr
         ,entered_unrounded_cr
         ,acctd_rounded_dr
         ,acctd_rounded_cr
         ,acctd_unrounded_dr
         ,acctd_unrounded_cr
         ,code_combination_id
         ,balancing_segment_value
         ,natural_account_segment_value
         ,cost_center_segment_value
         ,intercompany_segment_value
         ,management_segment_value
         ,ledger_id
         ,definition_code
         ,party_id
         ,party_site_id
         ,party_type_code
         ,ae_header_id
         ,generated_by_code
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date)
SELECT   /*+ index(xah XLA_AE_HEADERS_U1)  no_index(xal MIS_XLA_AE_LINES_N1) */
          DECODE(xet.event_class_code,''PREPAYMENT APPLICATIONS'',''APPLIED'',DECODE(xteu.entity_id,xah.entity_id,''SOURCE'',''APPLIED'')) record_type_code
         ,xah.entity_id                          source_entity_id
         ,xet.event_class_code                   event_class_code
         ,xah.application_id                     source_application_id
         ,DECODE(xet.event_class_code,''PREPAYMENT APPLICATIONS'',xteu.entity_id,DECODE(xteu.entity_id, xah.entity_id,NULL,xteu.entity_id)) applied_to_entity_id
          ,200                                    applied_to_application_id
         ,trunc(xah.accounting_date)             gl_date
         ,xal.currency_code                      trx_currency_code
         ,SUM(NVL(xal.entered_dr,0))             entered_rounded_dr
         ,SUM(NVL(xal.entered_cr,0))             entered_rounded_cr
         ,SUM(NVL(xal.entered_dr,0))             entered_unrounded_dr
         ,SUM(NVL(xal.entered_cr,0))             entered_unrounded_cr
         ,SUM(NVL(alb.accounted_dr, 0))          acctd_rounded_dr
         ,SUM(NVL(alb.accounted_cr, 0))          acctd_rounded_cr
         ,SUM(NVL(alb.accounted_dr,0))           acctd_unrounded_dr
         ,SUM(NVL(alb.accounted_cr,0))           acctd_unrounded_cr
         ,xal.code_combination_id                code_combination_id
         ,DECODE(fsav.balancing_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
                                                 balancing_segment_value
         ,DECODE(fsav.account_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
                                                 natural_account_segment_value
         ,DECODE(fsav.cost_crt_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
                                                 cost_center_segment_value
         ,DECODE(fsav.intercompany_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
                                                 intercompany_segment_value
         ,DECODE(fsav.management_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
                                                 management_segment_value
         ,xah.ledger_id                          ledger_id
         ,xtd.definition_code                    DEFINITION_code
         ,xal.party_id                           party_id
         ,xal.party_site_id                      party_site_id
         ,xal.party_type_code                    party_type_code
         ,xah.ae_header_id                       ae_header_id
         ,''SYSTEM''                               generated_by_code
         ,SYSDATE                                creation_date
         ,-1                                     created_by
         ,SYSDATE                                last_update_date
         ,-1                                     last_updated_by
         ,-1                                     last_update_login
         ,-1                                     request_id
         ,-1                                     program_application_id
         ,-1                                     program_id
         ,SYSDATE                                program_update_date
        FROM
          ap_liability_balance                        alb
         ,xla_ae_headers               PARTITION (AP) xah
         ,xla_event_types_b                           xet
         ,xla_tb_definitions_b                        xtd
	 $l_from$
         ,xla_transaction_entities_upg PARTITION (AP) xteu
         ,xla_ae_lines                 PARTITION (AP) xal
         ,gl_code_combinations                        gcc
         ,( SELECT /*+ NO_MERGE*/ id_flex_num
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, ''GL_BALANCING'', application_column_name, NULL)) balancing_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, ''GL_ACCOUNT'', application_column_name, NULL)) account_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, ''FA_COST_CTR'', application_column_name, NULL)) cost_crt_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, ''GL_INTERCOMPANY'', application_column_name, NULL)) intercompany_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, ''GL_MANAGEMENT'', application_column_name, NULL)) management_segment
            FROM fnd_segment_attribute_values  fsav1  -- Need alias here also.
            WHERE application_id = 101
            AND id_flex_code = ''GL#''
            AND attribute_value = ''Y''
            GROUP BY id_flex_num) fsav
       WHERE
         xah.gl_transfer_status_code IN (''Y'',''NT'')
         AND xah.application_id       = xal.application_id
         AND xah.ae_header_id          BETWEEN :1 AND :2
         AND xah.application_id         = 200
         AND xah.ledger_id            = :3
         AND xah.upg_batch_id IS NOT NULL
         AND xah.ae_header_id         = xal.ae_header_id
         AND xal.code_combination_id  = gcc.code_combination_id
         AND xal.code_combination_id  = alb.code_combination_id
         AND xah.application_id       = xet.application_id
         AND xteu.application_id      = 200
         AND xteu.entity_code         =  ''AP_INVOICES''
         AND NVL(xteu.source_id_int_1,-99)  = alb.invoice_id
         --AND xteu.ledger_id           = alb.set_of_books_id
         AND xteu.ledger_id           = $l_derived_primary_ledger$
         AND alb.ae_header_id  IS NOT NULL
         AND alb.ae_line_id  IS NOT NULL
         AND alb.ae_header_id = xah.completion_acct_seq_value
         AND 200 = xah.completion_acct_seq_version_id
  	 AND alb.ae_line_id =  xal.ae_line_num
    	 AND xah.upg_source_application_id = 200
         AND xah.event_type_code      = xet.event_type_code
         AND gcc.chart_of_accounts_id = fsav.id_flex_num
	 $l_where$
         AND xtd.ledger_id            = alb.set_of_books_id
         AND alb.code_combination_id  = xal.code_combination_id
     --- remodeling
         AND xal.accounting_class_code = ''LIABILITY''
         AND xah.event_type_code  <> ''MANUAL''
     --- remodeling

        GROUP BY
     DECODE(xet.event_class_code,''PREPAYMENT APPLICATIONS'',''APPLIED'',DECODE(xteu.entity_id,xah.entity_id,''SOURCE'',''APPLIED''))
         ,xah.entity_id
         ,xet.event_class_code
         ,xah.application_id
         ,DECODE(xet.event_class_code,''PREPAYMENT APPLICATIONS'',xteu.entity_id,DECODE(xteu.entity_id, xah.entity_id,NULL,xteu.entity_id))
         ,xah.accounting_date
         ,xal.currency_code
         ,xal.code_combination_id
         ,DECODE(fsav.balancing_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
         ,DECODE(fsav.account_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
         ,DECODE(fsav.cost_crt_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
         ,DECODE(fsav.intercompany_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
         ,DECODE(fsav.management_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
         ,xah.ledger_id
         ,xtd.definition_code
         ,xal.party_id
         ,xal.party_site_id
         ,xal.party_type_code
         ,xah.ae_header_id
';
-- added $l_from$,$l_where$ to dynamically build code for Flex/Segment TB Def Code. bug: 7619431
-- commented code from above SQL
/*
       Tables removed from FROM clause:
       -------------------------------
       ,xla_tb_defn_details                         xdd
       ,xla_tb_defn_je_sources                      xjs
       ,xla_subledgers                              xsu
*/
--       Conditions removed from WHERE clause:
--       -------------------------------------
      /* AND NVL(alb.ae_header_id, alb.sle_header_id)                = xah.completion_acct_seq_value
         AND NVL2(alb.ae_header_id,200, alb.journal_sequence_id)     = xah.completion_acct_seq_version_id
         AND NVL2(alb.ae_header_id, alb.ae_line_id,alb.sle_line_num) = xal.ae_line_num
         AND (
              (alb.ae_header_id IS NOT NULL AND xah.upg_source_application_id = 200)
              OR
              (alb.ae_header_id IS NULL AND xah.upg_source_application_id = 600 AND xah.upg_batch_id = -5672)
             )
          */
/*
         AND xtd.definition_code      = xdd.definition_code
         AND xtd.definition_code =     :4
         AND xtd.definition_code      = xjs.definition_code
         AND xtd.enabled_flag         = ''Y''
         AND xjs.je_source_name       = xsu.je_source_name
         AND xsu.application_id       = 200
	 AND alb.code_combination_id  = xdd.code_combination_id
*/

--for bug#7364921 did a trunc of xah.accounting_date in the query below
--Reason gl_date is populated with time component and the trial balance report
--query does not fetch data for a date including time stamp.

--bug#7619431 made the query dynamic so that definition Details/Definition Seg Ranges is used
-- for Flex/Segment Definition, when TB Definition Code is re-built
-- Also, all commented code has been removed from the String as Variable can hold only 32000

C_TB_INSERT_UPG_SQL_SLE  CONSTANT    VARCHAR2(32000) := '
 INSERT INTO xla_trial_balances xtb(
          record_type_code
         ,source_entity_id
         ,event_class_code
         ,source_application_id
         ,applied_to_entity_id
         ,applied_to_application_id
         ,gl_date
         ,trx_currency_code
         ,entered_rounded_dr
         ,entered_rounded_cr
         ,entered_unrounded_dr
         ,entered_unrounded_cr
         ,acctd_rounded_dr
         ,acctd_rounded_cr
         ,acctd_unrounded_dr
         ,acctd_unrounded_cr
         ,code_combination_id
         ,balancing_segment_value
         ,natural_account_segment_value
         ,cost_center_segment_value
         ,intercompany_segment_value
         ,management_segment_value
         ,ledger_id
         ,definition_code
         ,party_id
         ,party_site_id
         ,party_type_code
         ,ae_header_id
         ,generated_by_code
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date)
SELECT   /*+ index(xah XLA_AE_HEADERS_U1)  no_index(xal MIS_XLA_AE_LINES_N1) */
         DECODE(xet.event_class_code,''PREPAYMENT APPLICATIONS'',''APPLIED'',DECODE(xteu.entity_id,xah.entity_id,''SOURCE'',''APPLIED'')) record_type_code
         ,xah.entity_id                          source_entity_id
         ,xet.event_class_code                   event_class_code
         ,xah.application_id                     source_application_id
         ,DECODE(xet.event_class_code,''PREPAYMENT APPLICATIONS'',xteu.entity_id,DECODE(xteu.entity_id, xah.entity_id,NULL,xteu.entity_id)) applied_to_entity_id
          ,200                                    applied_to_application_id
         ,trunc(xah.accounting_date)             gl_date
         ,xal.currency_code                      trx_currency_code
         ,SUM(NVL(xal.entered_dr,0))             entered_rounded_dr
         ,SUM(NVL(xal.entered_cr,0))             entered_rounded_cr
         ,SUM(NVL(xal.entered_dr,0))             entered_unrounded_dr
         ,SUM(NVL(xal.entered_cr,0))             entered_unrounded_cr
         ,SUM(NVL(alb.accounted_dr, 0))          acctd_rounded_dr
         ,SUM(NVL(alb.accounted_cr, 0))          acctd_rounded_cr
         ,SUM(NVL(alb.accounted_dr,0))           acctd_unrounded_dr
         ,SUM(NVL(alb.accounted_cr,0))           acctd_unrounded_cr
         ,xal.code_combination_id                code_combination_id
         ,DECODE(fsav.balancing_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
                                                 balancing_segment_value
         ,DECODE(fsav.account_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
                                                 natural_account_segment_value
         ,DECODE(fsav.cost_crt_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
                                                 cost_center_segment_value
         ,DECODE(fsav.intercompany_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
                                                 intercompany_segment_value
         ,DECODE(fsav.management_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
                                                 management_segment_value
         ,xah.ledger_id                          ledger_id
         ,xtd.definition_code                    DEFINITION_code
         ,xal.party_id                           party_id
         ,xal.party_site_id                      party_site_id
         ,xal.party_type_code                    party_type_code
         ,xah.ae_header_id                       ae_header_id
         ,''SYSTEM''                               generated_by_code
         ,SYSDATE                                creation_date
         ,-1                                     created_by
         ,SYSDATE                                last_update_date
         ,-1                                     last_updated_by
         ,-1                                     last_update_login
         ,-1                                     request_id
         ,-1                                     program_application_id
         ,-1                                     program_id
         ,SYSDATE                                program_update_date
        FROM
          ap_liability_balance                        alb
         ,xla_ae_headers               PARTITION (AP) xah
         ,xla_event_types_b                           xet
         ,xla_tb_definitions_b                        xtd
	 $l_from$
         ,xla_transaction_entities_upg PARTITION (AP) xteu
         ,xla_ae_lines                 PARTITION (AP) xal
         ,gl_code_combinations                        gcc
         ,( SELECT /*+ NO_MERGE*/ id_flex_num
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, ''GL_BALANCING'', application_column_name, NULL)) balancing_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, ''GL_ACCOUNT'', application_column_name, NULL)) account_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, ''FA_COST_CTR'', application_column_name, NULL)) cost_crt_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, ''GL_INTERCOMPANY'', application_column_name, NULL)) intercompany_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, ''GL_MANAGEMENT'', application_column_name, NULL)) management_segment
            FROM fnd_segment_attribute_values  fsav1  -- Need alias here also.
            WHERE application_id = 101
            AND id_flex_code = ''GL#''
            AND attribute_value = ''Y''
            GROUP BY id_flex_num) fsav
       WHERE
         xah.gl_transfer_status_code IN (''Y'',''NT'')
         AND xah.application_id       = xal.application_id
         AND xah.ae_header_id          BETWEEN :1 AND :2
         AND xah.application_id         = 200
         AND xah.ledger_id            = :3
         AND xah.upg_batch_id IS NOT NULL
         AND xah.ae_header_id         = xal.ae_header_id
         AND xal.code_combination_id  = gcc.code_combination_id
         AND xal.code_combination_id  = alb.code_combination_id
         AND xah.application_id       = xet.application_id
         AND xteu.application_id      = 200
         AND xteu.entity_code         =  ''AP_INVOICES''
         AND NVL(xteu.source_id_int_1,-99)  = alb.invoice_id
         --AND xteu.ledger_id           = alb.set_of_books_id
         AND xteu.ledger_id           = $l_derived_primary_ledger$
	 AND alb.sle_header_id IS NOT NULL
         AND alb.sle_line_num IS NOT NULL
         AND alb.sle_header_id = xah.completion_acct_seq_value
       	 AND alb.journal_sequence_id = xah.completion_acct_seq_version_id
	 AND alb.sle_line_num =  xal.ae_line_num
         AND xah.upg_source_application_id = 600
         AND xah.upg_batch_id = -5672

	 AND xah.event_type_code      = xet.event_type_code
         AND gcc.chart_of_accounts_id = fsav.id_flex_num
	 $l_where$
         AND xtd.ledger_id            = alb.set_of_books_id
         AND alb.code_combination_id  = xal.code_combination_id
     --- remodeling
         AND xal.accounting_class_code = ''LIABILITY''
         AND xah.event_type_code <> ''MANUAL''
     --- remodeling

        GROUP BY
     DECODE(xet.event_class_code,''PREPAYMENT APPLICATIONS'',''APPLIED'',DECODE(xteu.entity_id,xah.entity_id,''SOURCE'',''APPLIED''))
         ,xah.entity_id
         ,xet.event_class_code
         ,xah.application_id
         ,DECODE(xet.event_class_code,''PREPAYMENT APPLICATIONS'',xteu.entity_id,DECODE(xteu.entity_id, xah.entity_id,NULL,xteu.entity_id))
         ,xah.accounting_date
         ,xal.currency_code
         ,xal.code_combination_id
         ,DECODE(fsav.balancing_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
         ,DECODE(fsav.account_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
         ,DECODE(fsav.cost_crt_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
         ,DECODE(fsav.intercompany_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
         ,DECODE(fsav.management_segment,
              ''SEGMENT1'', gcc.segment1, ''SEGMENT2'', gcc.segment2, ''SEGMENT3'', gcc.segment3,
              ''SEGMENT4'', gcc.segment4, ''SEGMENT5'', gcc.segment5, ''SEGMENT6'', gcc.segment6,
              ''SEGMENT7'', gcc.segment7, ''SEGMENT8'', gcc.segment8, ''SEGMENT9'', gcc.segment9,
              ''SEGMENT10'', gcc.segment10, ''SEGMENT11'', gcc.segment11, ''SEGMENT12'', gcc.segment12,
              ''SEGMENT13'', gcc.segment13, ''SEGMENT14'', gcc.segment14, ''SEGMENT15'', gcc.segment15,
              ''SEGMENT16'', gcc.segment16, ''SEGMENT17'', gcc.segment17, ''SEGMENT18'', gcc.segment18,
              ''SEGMENT19'', gcc.segment19, ''SEGMENT20'', gcc.segment20, ''SEGMENT21'', gcc.segment21,
              ''SEGMENT22'', gcc.segment22, ''SEGMENT23'', gcc.segment23, ''SEGMENT24'', gcc.segment24,
              ''SEGMENT25'', gcc.segment25, ''SEGMENT26'', gcc.segment26, ''SEGMENT27'', gcc.segment27,
              ''SEGMENT28'', gcc.segment28, ''SEGMENT29'', gcc.segment29, ''SEGMENT30'', gcc.segment30,
              null)
         ,xah.ledger_id
         ,xtd.definition_code
         ,xal.party_id
         ,xal.party_site_id
         ,xal.party_type_code
         ,xah.ae_header_id
';

-- added $l_from$,$l_where$ to dynamically build code for Flex/Segment TB Def Code. bug: 7619431
-- commented code from the above SQL
/*
         Tables removed from FROM clause:
	 --------------------------------
	 ,xla_tb_defn_details                         xdd
	 ,xla_tb_defn_je_sources                      xjs
         ,xla_subledgers                              xsu
*/
--       Conditions removed from WHERE clause:
	 -------------------------------------
	/* AND NVL(alb.ae_header_id, alb.sle_header_id)                = xah.completion_acct_seq_value
         AND NVL2(alb.ae_header_id,200, alb.journal_sequence_id)     = xah.completion_acct_seq_version_id
         AND NVL2(alb.ae_header_id, alb.ae_line_id,alb.sle_line_num) = xal.ae_line_num
         AND (
              (alb.ae_header_id IS NOT NULL AND xah.upg_source_application_id = 200)
              OR
              (alb.ae_header_id IS NULL AND xah.upg_source_application_id = 600 AND xah.upg_batch_id = -5672)
             )
          */
/*
         AND xtd.definition_code      = xdd.definition_code
         AND xtd.definition_code =     :4
         AND xtd.definition_code      = xjs.definition_code
         AND xtd.enabled_flag         = ''Y''
         AND xjs.je_source_name       = xsu.je_source_name
         AND xsu.application_id       = 200
         AND alb.code_combination_id  = xdd.code_combination_id
*/
--end  bug 6704677


--
-- Template for upgraded transactions
--
C_TB_UPG_SQL      CONSTANT    VARCHAR2(32000) := '
   INSERT INTO xla_trial_balances (
          record_type_code
         ,source_entity_id
         ,event_class_code
         ,source_application_id
         ,applied_to_entity_id
         ,gl_date
         ,trx_currency_code
         ,entered_rounded_dr
         ,entered_rounded_cr
         ,entered_unrounded_dr
         ,entered_unrounded_cr
         ,acctd_rounded_dr
         ,acctd_rounded_cr
         ,acctd_unrounded_dr
         ,acctd_unrounded_cr
         ,code_combination_id
         ,balancing_segment_value
         ,natural_account_segment_value
         ,cost_center_segment_value
         ,intercompany_segment_value
         ,management_segment_value
         ,ledger_id
         ,definition_code
         ,party_id
         ,party_site_id
         ,party_type_code
         ,ae_header_id
         ,generated_by_code
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date)
   SELECT ''SOURCE''                             record_type_code
         ,-1                                     source_entity_id
         ,''-1''                                 event_class_code
         ,xsu.application_id                     source_application_id
         ,NULL                                   applied_to_entity_id
         ,xdd.balance_date                       gl_date
         ,:1                                     trx_currency_code
         ,$ent_rounded_amt_dr$                   entered_rounded_dr
         ,$ent_rounded_amt_cr$                   entered_rounded_cr
         ,$ent_unrounded_amt_dr$                 entered_unrounded_dr
         ,$ent_unrounded_amt_cr$                 entered_unrounded_cr
         ,$acct_rounded_amt_dr$                  acctd_rounded_dr
         ,$acct_rounded_amt_cr$                  acctd_rounded_cr
         ,$acct_unrounded_amt_dr$                acctd_unrounded_dr
         ,$acct_unrounded_amt_cr$                acctd_unrounded_cr
         ,xdd.code_combination_id                code_combination_id
         ,$bal_segment$                          balancing_segment_value
         ,$acct_segment$                         natural_account_segment_value
         ,$cc_segment$                           cost_center_segment_value
         ,$ic_segment$                           intercompany_segment_value
         ,$mgt_segment$                          management_segment_value
         ,:2                                     ledger_id
         ,:3                                     definition_code
         ,NULL                                   party_id
         ,NULL                                   party_site_id
         ,NULL                                   party_type_code
         ,NULL                                   ae_header_id
         ,''SYSTEM''                             generated_by_code
         ,SYSDATE                                creation_date
         ,:4      -- g_user_id
         ,SYSDATE
         ,:5      -- g_user_id
         ,:6      -- g_login_id
         ,:7      -- g_request_id
         ,:8      -- g_prog_appl_id
         ,:9      -- g_program_id
         ,sysdate
     FROM
          gl_code_combinations       gcc
         ,xla_subledgers             xsu
         ,xla_tb_defn_je_sources     xjs
         ,xla_tb_defn_details        xdd
    WHERE xdd.definition_code       = :10
      AND xdd.owner_code            = ''S''
      and xdd.code_combination_id   = gcc.code_combination_id
      AND xsu.je_source_name        = xjs.je_source_name
      AND xjs.owner_code            = ''S''
      AND xjs.definition_code       = :11
      AND gcc.chart_of_accounts_id  = :12
';
-- end of C_TB_UPG_SQL

--
-- Global Constants
--
C_NUM_OF_WORKERS      CONSTANT NUMBER       := 1;
                      --NVL(fnd_profile.value ('XLA_TB_DM_NUM_OF_WORKERS'),0);

C_WORK_UNIT           CONSTANT NUMBER       := 1000;
                      --NVL(fnd_profile.value ('XLA_TB_DM_WORK_UNIT'),0);

-- process status

C_PROCESSED           CONSTANT VARCHAR2(30) := 'PROCESSED';
C_DISABLED            CONSTANT VARCHAR2(30) := 'DISABLED';

-- Work Unit
C_WU_UNPROCESSED      CONSTANT VARCHAR2(30) := 'UNPROCESSED';
C_WU_PROCESSED        CONSTANT VARCHAR2(30) := 'PROCESSED';
C_WU_PROCESSING       CONSTANT VARCHAR2(30) := 'PROCESSING';

-- definition status
C_DEF_NEW             CONSTANT VARCHAR2(30) := 'NEW';
C_DEF_RELOAD          CONSTANT VARCHAR2(30) := 'RELOAD';
C_DEF_PROCESSED       CONSTANT VARCHAR2(30) := 'PROCESSED';

C_NEW_LINE            CONSTANT VARCHAR2(8)  := fnd_global.newline;
C_SPECIAL_STRING      CONSTANT VARCHAR2(4)  := '%#@*';

C_GL_APPS_ID          CONSTANT NUMBER(15)   := 101;
C_ID_FLEX_CODE        CONSTANT VARCHAR2(4)  := 'GL#';

C_BALANCE_SEG         CONSTANT VARCHAR2(30) := 'GL_BALANCING';
C_ACCOUNT_SEG         CONSTANT VARCHAR2(30) := 'GL_ACCOUNT';
C_COST_CENTER_SEG     CONSTANT VARCHAR2(30) := 'FA_COST_CTR';
C_INTERCOMPANY_SEG    CONSTANT VARCHAR2(30) := 'GL_INTERCOMPANY';
C_MANAGEMENT_SEG      CONSTANT VARCHAR2(30) := 'GL_MANAGEMENT';


--
-- Global Variables for Caching
--
TYPE t_array_num15  IS TABLE OF NUMBER(15)    INDEX BY BINARY_INTEGER;
TYPE t_array_vc30   IS TABLE OF VARCHAR2(30)  INDEX BY VARCHAR2(100);
TYPE t_array_vc30b  IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;

--
g_array_segment_column           t_array_vc30;
g_array_wu_requests              t_array_num15;


--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240)
                      := 'xla.plsql.xla_tb_data_manager_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
BEGIN

      --fnd_file.put_line(FND_FILE.LOG, 'here2');
      --fnd_file.put_line(FND_FILE.LOG, 'p_level ' || p_level );
      --fnd_file.put_line(FND_FILE.LOG, 'g_log_level ' || g_log_level );

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
         (p_location   => 'xla_tb_data_manager_pkg.trace');
END trace;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
|    Dump_Text                                                          |
|                                                                       |
|    Dump text into fnd_log_messages.                                   |
|                                                                       |
+======================================================================*/
PROCEDURE dump_text
                    (
                      p_text          IN  VARCHAR2
                    )
IS
   l_cur_position      INTEGER;
   l_next_cr_position  INTEGER;
   l_text_length       INTEGER;
   l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_text';
   END IF;

   --Dump the SQL command
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      l_cur_position      := 1;
      l_next_cr_position  := 0;
      l_text_length       := LENGTH(p_text);

      WHILE l_next_cr_position < l_text_length
      LOOP
         l_next_cr_position := INSTR( p_text
                                     ,C_NEW_LINE
                                     ,l_cur_position
                                    );

         IF l_next_cr_position = 0
         THEN
            l_next_cr_position := l_text_length;
         END IF;

         trace
            (p_msg      => SUBSTR( p_text
                                  ,l_cur_position
                                  ,l_next_cr_position
                                   - l_cur_position
                                   + 1
                                 )
            ,p_level    => C_LEVEL_STATEMENT
			,p_module   => l_log_module);

         IF l_cur_position < l_text_length
         THEN
            l_cur_position := l_next_cr_position + 1;
         END IF;
      END LOOP;
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_report_pvt.dump_text');
END dump_text;


PROCEDURE delete_tb_log
IS
l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.delete_tb_log';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN delete_tb_log',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Deleting log entry',C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   DELETE xla_tb_logs
   WHERE request_id = g_request_id;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END delete_tb_log',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_tb_data_manager_pvt.delete_tb_log');
END delete_tb_log;


PROCEDURE define_segment_ranges
   (p_definition_code VARCHAR2 ) IS

l_define_by_code         VARCHAR2(30);
l_log_module             VARCHAR2(240);

l_def_by_seg_sql         VARCHAR2(32000);
l_ins_columns            VARCHAR2(32000);
l_sel_columns            VARCHAR2(32000);
l_tables                 VARCHAR2(32000);
l_joins                  VARCHAR2(32000);
l_seg_num                VARCHAR2(1);
C_NEW_LINE      CONSTANT VARCHAR2(8)   := fnd_global.newline;

BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.define_segment_ranges';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
          (p_msg      => 'BEGIN of procedure.define_segment_ranges'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
      trace
          (p_msg      => 'p_definition_code = '||p_definition_code
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
   END IF;

   DELETE FROM xla_tb_def_seg_ranges
   WHERE definition_code = p_definition_code;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('# of rows deleted = ' || SQL%ROWCOUNT
            ,C_LEVEL_STATEMENT
            ,l_Log_module);
   END IF;

   SELECT defined_by_code
   INTO l_define_by_code
   FROM xla_tb_definitions_b  xtd
   WHERE xtd.definition_code = p_definition_code;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('Defined By Code = ' || l_define_by_code
            ,C_LEVEL_STATEMENT
            ,l_Log_module);
   END IF;

   IF l_define_by_code = 'FLEXFIELD' THEN

      INSERT INTO xla_tb_def_seg_ranges
          (definition_code
          ,line_num
          ,balance_date
          ,owner_code
          ,segment1_from
          ,segment1_to
          ,segment2_from
          ,segment2_to
          ,segment3_from
          ,segment3_to
          ,segment4_from
          ,segment4_to
          ,segment5_from
          ,segment5_to
          ,segment6_from
          ,segment6_to
          ,segment7_from
          ,segment7_to
          ,segment8_from
          ,segment8_to
          ,segment9_from
          ,segment9_to
          ,segment10_from
          ,segment10_to
          ,segment11_from
          ,segment11_to
          ,segment12_from
          ,segment12_to
          ,segment13_from
          ,segment13_to
          ,segment14_from
          ,segment14_to
          ,segment15_from
          ,segment15_to
          ,segment16_from
          ,segment16_to
          ,segment17_from
          ,segment17_to
          ,segment18_from
          ,segment18_to
          ,segment19_from
          ,segment19_to
          ,segment20_from
          ,segment20_to
          ,segment21_from
          ,segment21_to
          ,segment22_from
          ,segment22_to
          ,segment23_from
          ,segment23_to
          ,segment24_from
          ,segment24_to
          ,segment25_from
          ,segment25_to
          ,segment26_from
          ,segment26_to
          ,segment27_from
          ,segment27_to
          ,segment28_from
          ,segment28_to
          ,segment29_from
          ,segment29_to
          ,segment30_from
          ,segment30_to)
       SELECT tdd.definition_code         definition_code
             ,ROWNUM
             ,tdd.balance_date            balance_date
             ,tdd.owner_code              owner_code
             ,gcc.segment1                segment1_from
             ,gcc.segment1                segment1_to
             ,gcc.segment2                segment2_from
             ,gcc.segment2                segment2_to
             ,gcc.segment3                segment3_from
             ,gcc.segment3                segment3_to
             ,gcc.segment4                segment4_from
             ,gcc.segment4                segment4_to
             ,gcc.segment5                segment5_from
             ,gcc.segment5                segment5_to
             ,gcc.segment6                segment6_from
             ,gcc.segment6                segment6_to
             ,gcc.segment7                segment7_from
             ,gcc.segment7                segment7_to
             ,gcc.segment8                segment8_from
             ,gcc.segment8                segment8_to
             ,gcc.segment9                segment9_from
             ,gcc.segment9                segment9_to
             ,gcc.segment10               segment10_from
             ,gcc.segment10               segment10_to
             ,gcc.segment11               segment11_from
             ,gcc.segment11               segment11_to
             ,gcc.segment12               segment12_from
             ,gcc.segment12               segment12_to
             ,gcc.segment13               segment13_from
             ,gcc.segment13               segment13_to
             ,gcc.segment14               segment14_from
             ,gcc.segment14               segment14_to
             ,gcc.segment15               segment15_from
             ,gcc.segment15               segment15_to
             ,gcc.segment16               segment16_from
             ,gcc.segment16               segment16_to
             ,gcc.segment17               segment17_from
             ,gcc.segment17               segment17_to
             ,gcc.segment18               segment18_from
             ,gcc.segment18               segment18_to
             ,gcc.segment19               segment19_from
             ,gcc.segment19               segment19_to
             ,gcc.segment20               segment20_from
             ,gcc.segment20               segment20_to
             ,gcc.segment21               segment21_from
             ,gcc.segment21               segment21_to
             ,gcc.segment22               segment22_from
             ,gcc.segment22               segment22_to
             ,gcc.segment23               segment23_from
             ,gcc.segment23               segment23_to
             ,gcc.segment24               segment24_from
             ,gcc.segment24               segment24_to
             ,gcc.segment25               segment25_from
             ,gcc.segment25               segment25_to
             ,gcc.segment26               segment26_from
             ,gcc.segment26               segment26_to
             ,gcc.segment27               segment27_from
             ,gcc.segment27               segment27_to
             ,gcc.segment28               segment28_from
             ,gcc.segment28               segment28_to
             ,gcc.segment29               segment29_from
             ,gcc.segment29               segment29_to
             ,gcc.segment30               segment30_from
             ,gcc.segment30               segment30_to
         FROM xla_tb_defn_details         tdd
             ,gl_code_combinations        gcc
        WHERE tdd.definition_code       = p_definition_code
          AND gcc.code_combination_id   = tdd.code_combination_id;

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('# of rows inserted (Flexfield) = ' || SQL%ROWCOUNT
            ,C_LEVEL_STATEMENT
            ,l_Log_module);
       END IF;

   ELSE

      FOR c_segs IN (SELECT DISTINCT flexfield_segment_code
                       FROM xla_tb_defn_details
                      WHERE definition_code = p_definition_code)
      LOOP
          l_seg_num     := SUBSTR(c_segs.flexfield_segment_code,8,2);

          --
          --    Inserted Columns
          --
          --   ,segment<n>_from
          --   ,segment<n>_to
          --
          l_ins_columns := C_NEW_LINE
                        || ',segment' || l_seg_num || '_from '
                        || C_NEW_LINE
                        || ',segment' || l_seg_num || '_to '
                        || C_NEW_LINE;

          --
          --   Selected Columns
          --
          --   ,tab<n>.segment_value_from     segment<n>_from
          --   ,tab<n>.segment_value_to       segment<n>_to
          --
          l_sel_columns := C_NEW_LINE
                        || ',tab' || l_seg_num  || '.segment_value_from     '
                                  || ' segment' || l_seg_num || '_from '
                        || C_NEW_LINE
                        || ',tab' || l_seg_num  || '.segment_value_to       '
                                  || ' segment' || l_seg_num || '_to '
                        || C_NEW_LINE;
          --
          --   Selected Tables
          --
          --   ,xla_tb_defn_details         tab<n>
          --
          l_tables      := C_NEW_LINE
                        || ',xla_tb_defn_details         tab'|| l_seg_num
                        || C_NEW_LINE;

          --
          --   Join Conditions
          --
          --   AND tab<n>.flexfield_segment_code(+)  = 'SEGMENT<n>'
          --   AND tab<n>.definition_code(+)         = xtd.definition_code
          --
          l_joins       := C_NEW_LINE
                        || ' AND tab' || l_seg_num
                        || '.flexfield_segment_code(+)  = ''SEGMENT'
                        || l_seg_num  ||''''
                        || C_NEW_LINE
                        || ' AND tab' || l_seg_num
                        || '.definition_code(+)         = xtd.definition_code '
                        || C_NEW_LINE;


      END LOOP;

      l_def_by_seg_sql :=
         'INSERT INTO xla_tb_def_seg_ranges
             (definition_code
             ,line_num '
       ||     l_ins_columns
       ||   ')
          SELECT xtd.definition_code
                ,ROWNUM '
       ||        l_sel_columns
       ||'  FROM xla_tb_definitions_b xtd '
       ||        l_tables
       ||' WHERE xtd.definition_code             = :1 '
       ||        l_joins;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

         dump_text(p_text => l_def_by_seg_sql);

      END IF;

      EXECUTE IMMEDIATE l_def_by_seg_sql USING p_definition_code;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('# of rows inserted (Segment) = ' || SQL%ROWCOUNT
              ,C_LEVEL_STATEMENT
              ,l_Log_module);
      END IF;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
          (p_msg      => '# rows inserted = '||SQL%ROWCOUNT
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);

      trace
          (p_msg      => 'End of procedure.define_segment_ranges'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_data_manager_pkg.define_segment_ranges');
END define_segment_ranges;

--=============================================================================

--=============================================================================
--
-- Name: get_schema
-- Description: Retrieve the schema name for XLA
--
-- Return: If schema is found, the schema name is returned.  Else, null is
--         returned.
--
--=============================================================================
FUNCTION get_schema
RETURN VARCHAR2
IS
  l_status       VARCHAR2(30);
  l_industry     VARCHAR2(30);
  l_schema       VARCHAR2(30);
  l_retcode      BOOLEAN;

  l_log_module   VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_schema';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function get_schema',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (NOT FND_INSTALLATION.get_app_info
                       (application_short_name   => 'XLA'
                       ,status                   => l_status
                       ,industry                 => l_industry
                       ,oracle_schema            => l_schema)) THEN
     l_schema := NULL;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function get_schema',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_schema;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_subledgers_f_pkg.get_schema');

END get_schema;


/*------------------------------------------------------------+
|                                                             |
|  PRIVATE FUNCTION                                           |
|                                                             |
|       add_partition                                         |
|                                                             |
|  Add a new partition to the trial balance table.            |
|                                                             |
+------------------------------------------------------------*/
PROCEDURE add_partition ( p_definition_code VARCHAR2 ) IS
   l_schema       VARCHAR2(30);
   l_log_module   VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.add_partition';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN add_partition',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   -- Get schema name
   l_schema := get_schema;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_definition_code = '||p_definition_code,C_LEVEL_STATEMENT,l_Log_module);
      trace('Adding a new partition' || p_definition_code ,C_LEVEL_STATEMENT,l_Log_module);
      trace('l_schema = ' || l_schema,C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   -- Add  partition.
   EXECUTE IMMEDIATE
         'ALTER TABLE '||l_schema||'.xla_trial_balances'||' ADD PARTITION '||p_definition_code||
         ' VALUES ('''||p_definition_code||''' )';
EXCEPTION
   WHEN OTHERS THEN

      --
      -- Exit when partition p_definition_code already exists.
      --
      IF SQLCODE = -14312 THEN

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('The following partition already exists: ' || p_definition_code
                 ,C_LEVEL_STATEMENT
                 ,l_Log_module);
         END IF;

         NULL;

      ELSE
         xla_exceptions_pkg.raise_message
            (p_location   => 'xla_tb_data_manager_pvt.add_partition');
      END IF;

END add_partition;


/*------------------------------------------------------------+
|                                                             |
|  PUBLIC PROCEDURE                                           |
|                                                             |
|       delete_trial_balances                                 |
|                                                             |
|  Delete Trial Balances for given apps id and ae_header_id.  |
|  Used for data fix.                                                          |
+------------------------------------------------------------*/
PROCEDURE delete_trial_balances
    (p_application_id         IN NUMBER
    ,p_ae_header_id           IN NUMBER)
IS
   l_log_module  VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.delete_trial_balances';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN delete_trial_balances'
           ,C_LEVEL_PROCEDURE
           ,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_application_id = '||p_application_id
           ,C_LEVEL_STATEMENT
           ,l_Log_module);
   END IF;


   DELETE xla_trial_balances
    WHERE source_application_id  = p_application_id
      AND ae_header_id           = p_ae_header_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('# of records deleted '||SQL%ROWCOUNT
           ,C_LEVEL_STATEMENT
           ,l_Log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END delete_trial_balances'
           ,C_LEVEL_PROCEDURE
           ,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_data_manager_pvt.delete_trial_balances');
END delete_trial_balances;

/*------------------------------------------------------------+
|                                                             |
|  PUBLIC PROCEDURE                                           |
|                                                             |
|       delete_trial_balances                                 |
|                                                             |
|  DELETE Trial Balance Report Non-Setup Data                 |
|                                                             |
+------------------------------------------------------------*/
PROCEDURE delete_trial_balances
    (p_definition_code                          IN VARCHAR2) IS
   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.delete_trial_balances';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN delete_trial_balances',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_definition_code = '||p_definition_code,C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   IF g_je_source_name IS NULL THEN

      DELETE xla_tb_user_trans_views
      WHERE  definition_code = p_definition_code;

      DELETE xla_tb_work_units
      WHERE  definition_code = p_definition_code;

      DELETE xla_tb_def_seg_ranges
      WHERE  definition_code = p_definition_code;

      DELETE xla_tb_logs
      WHERE  definition_code = p_definition_code;

   ELSE

      DELETE xla_tb_logs
      WHERE  definition_code = p_definition_code
      AND    je_source_name  = g_je_source_name;

      DELETE xla_tb_user_trans_views
      WHERE  definition_code = p_definition_code
      AND    application_id  = g_application_id;

      DELETE xla_trial_balances
      WHERE  definition_code        = p_definition_code
      AND   source_application_id  = g_application_id;
       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('rows deleted'||sql%rowcount,C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   END IF;


   --DELETE xla_tb_processes
   --WHERE  definition_code = p_definition_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('rows deleted'||sql%rowcount,C_LEVEL_PROCEDURE,l_Log_module);
   END IF;



   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END delete_trial_balances',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_data_manager_pvt.delete_trial_balances');
END delete_trial_balances;




/*------------------------------------------------------------+
|                                                             |
|  PRIVATE FUNCTION                                           |
|                                                             |
|       delete_definition                                     |
|                                                             |
|  DELETE Trial Balance Report DEFINITION                     |
|                                                             |
+------------------------------------------------------------*/

PROCEDURE delete_definition
       (p_definition_code                        IN VARCHAR2) IS
l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.delete_definition';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN delete_definition',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_definition_code = '||p_definition_code,C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   IF g_je_source_name IS NULL THEN

      DELETE xla_tb_definitions_b
      WHERE  definition_code = p_definition_code;

      DELETE xla_tb_definitions_tl
      WHERE  definition_code = p_definition_code;

      DELETE xla_tb_defn_details
      WHERE  definition_code = p_definition_code;

      DELETE xla_tb_defn_je_sources
      WHERE  definition_code = p_definition_code;

      DELETE xla_tb_user_trans_views
      WHERE  definition_code = p_definition_code;

      DELETE xla_tb_work_units
      WHERE  definition_code = p_definition_code;

      DELETE xla_tb_def_seg_ranges
      WHERE  definition_code = p_definition_code;

      --DELETE xla_tb_processes
      --WHERE  definition_code = p_definition_code;

      DELETE xla_tb_logs
      WHERE  definition_code = p_definition_code;

   ELSE

      DELETE xla_tb_defn_je_sources
      WHERE  definition_code = p_definition_code
      AND    je_source_name  = g_je_source_name;

      DELETE xla_tb_logs
      WHERE  definition_code = p_definition_code
      AND    je_source_name  = g_je_source_name;

      DELETE xla_tb_user_trans_views
      WHERE  definition_code = p_definition_code
      AND    application_id  = g_application_id;

      DELETE xla_trial_balances
      WHERE  definition_code        = p_definition_code
      AND    source_application_id  = g_application_id;

   END IF;


   --DELETE xla_tb_processes
   --WHERE  definition_code = p_definition_code;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END delete_definition',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_data_manager_pvt.delete_definition');
END delete_definition;


/*===========================================================================+
  PROCEDURE
     drop_partition (Private)

  DESCRIPTION
     Drop partitions.

  SCOPE - PRIVATE

  ARGUMENTS


  NOTES

 +===========================================================================*/

PROCEDURE drop_partition IS
   l_log_module  VARCHAR2(240);
   l_schema       VARCHAR2(30);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.drop_partition';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('drop_partition.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;
   drop_partition (p_definition_code => g_definition_code);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('drop_partition.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_data_manager_pvt.drop_partition');
END drop_partition;

/*===========================================================================+
  PROCEDURE
     drop_partition (Public)

  DESCRIPTION
     Drop partitions.

  SCOPE - Public

  ARGUMENTS
     p_definition_code

  NOTES
    Called from TbReportDefnsAMImpl.java.
 +===========================================================================*/
PROCEDURE drop_partition
   (p_definition_code IN VARCHAR2)
IS
   l_log_module  VARCHAR2(240);
   l_schema       VARCHAR2(30);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.drop_partition';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('Begin of drop_partition',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   l_schema := get_schema;
   EXECUTE IMMEDIATE 'ALTER TABLE ' ||l_schema ||'.XLA_TRIAL_BALANCES drop partition '||p_definition_code;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('End of drop_partition',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_data_manager_pvt.drop_partition');
END drop_partition;

/*------------------------------------------------------------+
|                                                             |
|  PRIVATE FUNCTION                                           |
|                                                             |
|       get_report_definition                                 |
|                                                             |
|  Get Trial Balance Report DEFINITION                        |
|                                                             |
+---------------------------eeg---------------------------------*/


FUNCTION get_report_definition
  (p_definition_code IN  VARCHAR2)
RETURN r_definition_info IS

   l_definition_info    r_definition_info;
   l_log_module         VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_report_definition';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_report_definition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   SELECT xtd.definition_code
         ,xtd.ledger_id
         --,xtd.je_source_name
         ,xtd.enabled_flag
         ,xtd.balance_side_code
         ,xtd.defined_by_code
         ,xtd.definition_status_code
         ,xtd.owner_code
     INTO l_definition_info.definition_code
         ,l_definition_info.ledger_id
         --,l_definition_info.je_source_name
         ,l_definition_info.enabled_flag
         ,l_definition_info.balance_side_code
         ,l_definition_info.defined_by_code
         ,l_definition_info.definition_status_code
         ,l_definition_info.owner_code
     FROM xla_tb_definitions_b xtd
    WHERE xtd.definition_code = p_definition_code;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of get_report_definition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_definition_info;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
WHEN OTHERS    THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_data_manager_pvt.get_report_definition');
END get_report_definition;

PROCEDURE get_worker_info
  (p_ledger_id IN  VARCHAR2)
IS
   l_ledger_info    r_ledger_info;
   l_log_module     VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_worker_info';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_worker_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   BEGIN
      SELECT work_unit
            ,num_of_workers
        INTO g_work_unit
            ,g_num_of_workers
        FROM xla_gl_ledgers
       WHERE ledger_id = p_ledger_id ;
   EXCEPTION
       WHEN no_data_found THEN
           l_ledger_info := get_ledger_info
                             (p_ledger_id => p_ledger_id);

           xla_exceptions_pkg.raise_message
              (p_appli_s_name   => 'XLA'
              ,p_msg_name       => 'XLA_TB_NO_DEF_FOR_LEDGER'
              ,p_token_1        => 'LEDGER_NAME'
              ,p_value_1        => l_ledger_info.ledger_name);
   END;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of get_worker_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
WHEN OTHERS    THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_data_manager_pvt.get_worker_info');
END get_worker_info;


FUNCTION get_ledger_info
  (p_ledger_id IN  NUMBER) RETURN r_ledger_info IS

   l_ledger_info    r_ledger_info;
   l_log_module     VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_ledger_info';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_ledger_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_ledger_id = '|| p_ledger_id,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   SELECT gl.ledger_id
         ,gl.NAME
         ,gl.short_name
         ,gl.ledger_category_code
         ,gl.currency_code
         ,gl.chart_of_accounts_id
         ,gl.object_type_code
     INTO l_ledger_info.ledger_id
         ,l_ledger_info.ledger_name
         ,l_ledger_info.ledger_short_name
         ,l_ledger_info.ledger_category_code
         ,l_ledger_info.currency_code
         ,l_ledger_info.coa_id
         ,l_ledger_info.object_type_code
     FROM gl_ledgers gl
    WHERE gl.ledger_id = p_ledger_id;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of get_ledger_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_ledger_info;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
WHEN OTHERS    THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_data_manager_pvt.get_ledger_info');
END get_ledger_info;

/*------------------------------------------------------------+
|
|  PRIVATE FUNCTION
|
|       get_ledger_where
|
|  Return join conditions for ledgers and ledger sets.
|
+------------------------------------------------------------*/
FUNCTION get_ledger_where
  (p_ledger_id        IN  NUMBER
  ,p_object_type_code IN VARCHAR2)
RETURN VARCHAR2 IS

   l_log_module     VARCHAR2(240);
   l_ledger_where   VARCHAR2(2000);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_ledger_where';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_ledger_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_ledger_id = '|| p_ledger_id,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   IF p_object_type_code = 'S' THEN
      l_ledger_where := ' AND xah.ledger_id IN
                              (SELECT gl.ledger_id
                               FROM   gl_ledgers gl
                                     ,gl_ledger_set_assignments sa
                               WHERE  gl.ledger_id = sa.ledger_id
                                 AND  sa.ledger_set_id = :9) ';
   ELSE
      l_ledger_where := ' AND xah.ledger_id = :9 ';
   END IF;



   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of get_ledger_where'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_ledger_where;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
WHEN OTHERS    THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_data_manager_pvt.get_ledger_where');
END get_ledger_where;


/*------------------------------------------------------------+
|
|  PRIVATE FUNCTION
|
|       get_je_source_info
|
|  Derive information related TO THE JE SOURCE.
|
+------------------------------------------------------------*/
FUNCTION get_je_source_info (p_je_source_name VARCHAR2)
   RETURN NUMBER  IS

BEGIN

   SELECT application_id
   INTO   g_application_id
   FROM   xla_subledgers
   WHERE  je_source_name = g_je_source_name;

   RETURN g_application_id;

EXCEPTION
WHEN too_many_rows THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'More than one applications is associated with the
                         JE SOURCE ' || g_je_source_name);
WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
WHEN OTHERS    THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_data_manager_pvt.get_je_source_info');

END get_je_source_info;

/*------------------------------------------------------------+
|                                                             |
|  PRIVATE FUNCTION                                           |
|                                                             |
|       get_segment_columns                                   |
|                                                             |
|  Returns a SEGMENT COLUMN NAME FOR SEGMENT NAMES            |
|                                                             |
+------------------------------------------------------------*/
PROCEDURE get_segment_columns
            (p_coa_id              IN NUMBER
            ,p_bal_segment_column  OUT NOCOPY VARCHAR2
            ,p_acct_segment_column OUT NOCOPY VARCHAR2
            ,p_cc_segment_column   OUT NOCOPY VARCHAR2
            ,p_ic_segment_column   OUT NOCOPY VARCHAR2
            ,p_mgt_segment_column  OUT NOCOPY VARCHAR2)
IS

  l_bal_segment_column    VARCHAR2(30);
  l_acct_segment_column   VARCHAR2(30);
  l_cc_segment_column     VARCHAR2(30);
  l_ic_segment_column     VARCHAR2(30);
  l_mgt_segment_column    VARCHAR2(30);

  l_log_module            VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_segment_columns';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_segment_columns'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   l_bal_segment_column  := 'gcc.' ||
       xla_flex_pkg.get_qualifier_segment
          (p_application_id    => 101
          ,p_id_flex_code      => 'GL#'
          ,p_id_flex_num       => p_coa_id
          ,p_qualifier_segment => C_BALANCE_SEG);

   l_acct_segment_column := 'gcc.' ||
       xla_flex_pkg.get_qualifier_segment
          (p_application_id    => 101
          ,p_id_flex_code      => 'GL#'
          ,p_id_flex_num       => p_coa_id
          ,p_qualifier_segment => C_ACCOUNT_SEG);

   l_cc_segment_column   := 'gcc.' ||
       xla_flex_pkg.get_qualifier_segment
          (p_application_id    => 101
          ,p_id_flex_code      => 'GL#'
          ,p_id_flex_num       => p_coa_id
          ,p_qualifier_segment => C_COST_CENTER_SEG);

   l_ic_segment_column   := 'gcc.' ||
       xla_flex_pkg.get_qualifier_segment
          (p_application_id    => 101
          ,p_id_flex_code      => 'GL#'
          ,p_id_flex_num       => p_coa_id
          ,p_qualifier_segment => C_INTERCOMPANY_SEG);

   l_mgt_segment_column  := 'gcc.' ||
       xla_flex_pkg.get_qualifier_segment
          (p_application_id    => 101
          ,p_id_flex_code      => 'GL#'
          ,p_id_flex_num       => p_coa_id
          ,p_qualifier_segment => C_MANAGEMENT_SEG);

   IF l_bal_segment_column = 'gcc.' THEN
      l_bal_segment_column := 'NULL';
   END IF;
   IF l_acct_segment_column = 'gcc.' THEN
      l_acct_segment_column := 'NULL';
   END IF;
   IF l_cc_segment_column = 'gcc.' THEN
      l_cc_segment_column := 'NULL';
   END IF;
   IF l_ic_segment_column = 'gcc.' THEN
      l_ic_segment_column := 'NULL';
   END IF;
   IF l_mgt_segment_column = 'gcc.' THEN
      l_mgt_segment_column := 'NULL';
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace('l_bal_segment_column = ' || l_bal_segment_column,C_LEVEL_STATEMENT,l_Log_module);
      trace('l_acct_segment_column = ' || l_acct_segment_column,C_LEVEL_STATEMENT,l_Log_module);
      trace('l_cc_segment_column = ' || l_cc_segment_column,C_LEVEL_STATEMENT,l_Log_module);
      trace('l_ic_segment_column = ' || l_ic_segment_column,C_LEVEL_STATEMENT,l_Log_module);
      trace('l_mgt_segment_column = ' || l_mgt_segment_column,C_LEVEL_STATEMENT,l_Log_module);

   END IF;

   p_bal_segment_column  := l_bal_segment_column;
   p_acct_segment_column := l_acct_segment_column;
   p_cc_segment_column   := l_cc_segment_column;
   p_ic_segment_column   := l_ic_segment_column;
   p_mgt_segment_column  := l_mgt_segment_column;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of get_segment_columns'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
WHEN OTHERS    THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_data_manager_pvt.get_segment_columns');
END get_segment_columns;


FUNCTION get_segment_clause
       (p_ledger_id                IN NUMBER
       ) RETURN VARCHAR2 IS

C_STRING    CONSTANT     VARCHAR2(240) :=
                        ' AND NVL(gcc.$segment$,''0'') BETWEEN NVL(NVL(xsr.$segment$_from, gcc.$segment$),''0'')
                          AND NVL(NVL(xsr.$segment$_to, gcc.$segment$),''0'') '; --added nvl bug#9501376

CURSOR csr_segments(x_coa_id      IN NUMBER) IS

SELECT application_column_name
  FROM fnd_id_flex_segments
 WHERE application_id = 101
   AND id_flex_code = 'GL#'
   AND id_flex_num = x_coa_id
   AND enabled_flag = 'Y';

l_return_string           VARCHAR2(30000);
l_coa_id                  NUMBER;

BEGIN

   SELECT chart_of_accounts_id
     INTO l_coa_id
     FROM gl_ledgers
    WHERE ledger_id = p_ledger_id;

   FOR c1 IN csr_segments(l_coa_id) LOOP
   l_return_string := l_return_string||
                      REPLACE(C_STRING,'$segment$',c1.application_column_name);
   END LOOP;

   RETURN(l_return_string);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
     RAISE;
WHEN OTHERS    THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_data_manager_pvt.get_segment_clause');
END get_segment_clause;


PROCEDURE populate_user_trans_view
            (p_definition_code  IN VARCHAR2
            ,p_ledger_id       IN NUMBER
            ,p_group_id         IN NUMBER
	    )
IS

    CURSOR c_event_class (p_request_id NUMBER) IS
       SELECT DISTINCT
           xut.application_id
          ,xec.entity_code
          ,xut.event_class_code
          ,xut.reporting_view_name
      FROM xla_tb_user_trans_views xut
          ,xla_event_classes_b xec
     WHERE xut.application_id       =  xec.application_id
       AND xut.event_class_code     =  xec.event_class_code
       AND xut.select_string        = '###'
       AND xut.request_id           = p_request_id
       ;

    l_application_id       NUMBER(15);
    l_entity_code          VARCHAR2(30);
    l_event_class_code     VARCHAR2(30);
    l_reporting_view_name  VARCHAR2(30);
    l_select_string        VARCHAR2(4000);
    l_from_string          VARCHAR2(4000);
    l_where_string         VARCHAR2(4000);

    l_log_module           VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.populate_user_trans_view';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of populate_user_trans_view'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace('p_definition_code = ' || p_definition_code
           ,C_LEVEL_STATEMENT
           ,l_Log_module);

      trace('Inserting user transaction views'
           ,C_LEVEL_STATEMENT
           ,l_Log_module);

   END IF;

   --
   -- Populate user transaction identifiers
   --

  BEGIN


   IF p_definition_code IS NOT NULL THEN

   --perf imp 13-may-2008

   -- Bug#8333978 Changed the select clause to remove the reference of xla_trial_balances
   -- table in the from. To get the definition code and application id
   -- used the following tables in the join ie xla_tb_defn_je_sources and
   -- xla_subledgers.


     INSERT INTO xla_tb_user_trans_views
          (definition_code
          ,application_id
          ,event_class_code
          ,reporting_view_name
          ,select_string
          ,from_string
          ,where_string
          ,creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          )
    SELECT DISTINCT
              xjs.definition_code
             ,xsu.application_id
             ,xeca.event_class_code
             ,xeca.reporting_view_name
             ,'###'
             ,'###'
             ,'###'
             ,SYSDATE
             ,g_user_id
             ,SYSDATE
             ,g_user_id
             ,g_login_id
             ,g_request_id
             ,g_prog_appl_id
             ,g_program_id
             ,SYSDATE
        FROM
          xla_subledgers xsu,
          xla_tb_defn_je_sources xjs,
          xla_event_class_attrs xeca
       WHERE  xeca.event_class_code <> 'MANUAL'
       AND  xeca.application_id = xsu.application_id
       AND  xsu.je_source_name = xjs.je_source_name
       AND  xjs.definition_code = p_definition_code
       AND xeca.reporting_view_name IS NOT NULL
       AND NOT EXISTS
       (
         SELECT 'x'
         FROM  xla_tb_user_trans_views  xut
         WHERE  xut.definition_code  = xjs.definition_code
         AND  xut.application_id   = xsu.application_id
         AND  xut.event_class_code = xeca.event_class_code
       );

   --perf imp 13-may-2008


   ELSE
   --
   -- p_definition_code is null (from gl_transfer)
   --
      IF p_group_id IS NOT NULL AND p_ledger_id IS NOT NULL
      THEN
        INSERT INTO xla_tb_user_trans_views
          (definition_code
          ,application_id
          ,event_class_code
          ,reporting_view_name
          ,select_string
          ,from_string
          ,where_string
          ,creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          )
          SELECT DISTINCT
              xtd.definition_code
             ,xah.application_id
             ,xet.event_class_code
             ,xeca.reporting_view_name
             ,'###'
             ,'###'
             ,'###'
             ,SYSDATE
             ,g_user_id
             ,SYSDATE
             ,g_user_id
             ,g_login_id
             ,g_request_id
             ,g_prog_appl_id
             ,g_program_id
             ,SYSDATE
          from xla_ae_headers xah,
               xla_event_types_b xet,
               xla_event_class_attrs xeca,
               xla_tb_definitions_b xtd
          WHERE  xet.event_class_code     <> 'MANUAL'
            AND    xet.event_type_code      = xah.event_type_code
            AND    xet.event_class_code = xeca.event_class_code
            AND    xeca.application_id = xet.application_id
            AND    xah.application_id  =  xet.application_id
            AND    xah.ledger_id       =  xtd.ledger_id
            AND    xah.ledger_id       =  p_ledger_id
            AND    xah.group_id        =  p_group_id
            AND NOT EXISTS
            (
             SELECT 'x'
               FROM  xla_tb_user_trans_views  xut
              WHERE  xut.definition_code  = xtd.definition_code
                AND  xut.application_id   = xah.application_id
                AND  xut.event_class_code = xet.event_class_code
                AND  xut.event_class_code = xeca.event_class_code
                AND  xut.application_id  = xeca.application_id
            );


      ELSE

       -- Bug#8333978 Changed the select clause to remove the reference of xla_trial_balances
       -- table in the from clause. To get the definition code and application id
       -- used the following tables in the join ie xla_tb_defn_je_sources and
       -- xla_subledgers.

       INSERT INTO xla_tb_user_trans_views
          (definition_code
          ,application_id
          ,event_class_code
          ,reporting_view_name
          ,select_string
          ,from_string
          ,where_string
          ,creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          )
       SELECT DISTINCT
              xjs.definition_code
             ,xsu.application_id
             ,xeca.event_class_code
             ,xeca.reporting_view_name
             ,'###'
             ,'###'
             ,'###'
             ,SYSDATE
             ,g_user_id
             ,SYSDATE
             ,g_user_id
             ,g_login_id
             ,g_request_id
             ,g_prog_appl_id
             ,g_program_id
             ,SYSDATE
       FROM   xla_subledgers xsu,
              xla_tb_defn_je_sources xjs,
              xla_event_class_attrs xeca
       WHERE  xeca.event_class_code     <> 'MANUAL'
       AND    xsu.application_id  = xeca.application_id
       AND    xsu.je_source_name = xjs.je_source_name
       AND xeca.reporting_view_name IS NOT NULL
       AND NOT EXISTS
          (SELECT 'x'
             FROM  xla_tb_user_trans_views  xut
            WHERE  xut.definition_code  = xjs.definition_code
              AND  xut.application_id   = xsu.application_id
              AND  xut.event_class_code = xeca.event_class_code
                );

    END IF;  --for p_group_id IS NOT NULL AND p_ledger_id IS NOT NULL

   END IF; -- for p_definition_code IS NOT NULL

 /*
   21-Aug-2008 Added this exception as part of bug#7304630
   Due to concurrency issues a unique constraint error is raised, as this is the last part
   of processing all the distinct event_class_codes would already be inserted even if this error is
   raised.
  */

   EXCEPTION
       WHEN dup_val_on_index THEN
       NULL;

  END; -- Exception handling for INSERT

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('# of rows inserted = ' || SQL%ROWCOUNT
           ,C_LEVEL_STATEMENT
           ,l_Log_module);
   END IF;

   OPEN c_event_class(g_request_id);
      LOOP
         FETCH c_event_class
          INTO l_application_id
              ,l_entity_code
              ,l_event_class_code
              ,l_reporting_view_name;

         EXIT WHEN c_event_class%NOTFOUND;

         IF l_event_class_code <> 'MANUAL'  THEN

            xla_report_utility_pkg.get_transaction_id
               (p_application_id      =>  l_application_id
               ,p_entity_code         =>  l_entity_code
               ,p_event_class_code    =>  l_event_class_code
               ,p_reporting_view_name =>  l_reporting_view_name
               ,p_select_str          =>  l_select_string
               ,p_from_str            =>  l_from_string
               ,p_where_str           =>  l_where_string);

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN

               trace
                  (p_msg      => 'l_select_string = ' || l_select_string
                  ,p_level    => C_LEVEL_PROCEDURE
                  ,p_module   => l_log_module);
               trace
                  (p_msg      => 'l_from_string = '   || l_from_string
                  ,p_level    => C_LEVEL_PROCEDURE
                  ,p_module   => l_log_module);
               trace
                  (p_msg      => 'l_where_string = '  || l_where_string
                  ,p_level    => C_LEVEL_PROCEDURE
                  ,p_module   => l_log_module);

               trace('Updating user transaction view...'
                    ,C_LEVEL_STATEMENT
                    ,l_Log_module);

            END IF;

            UPDATE xla_tb_user_trans_views
               SET select_string = l_select_string
                  ,from_string   = l_from_string
                  ,where_string  = l_where_string
            WHERE request_id     = g_request_id
            AND   application_id = l_application_id
            AND   event_class_code = l_event_class_code
            ;

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace('# of rows updated = ' || SQL%ROWCOUNT
                   ,C_LEVEL_STATEMENT
                   ,l_Log_module);
            END IF;

         END IF;
      END LOOP;
   CLOSE c_event_class;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of populate_user_trans_view'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
     RAISE;
WHEN OTHERS THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_data_manager_pvt.populate_user_trans_view');
END populate_user_trans_view;

/*===========================================================================+
  PROCEDURE
     insert_trial_balance_upg

  DESCRIPTION
      Insert Trial Balance for a system generated definition code

  SCOPE - PRIVATE

  ARGUMENTS



  NOTES

 +===========================================================================*/


PROCEDURE insert_trial_balance_upg
            (p_definition_code IN VARCHAR2)
IS

l_defined_by_code       xla_tb_definitions_b.defined_by_code%TYPE;
l_sql                   VARCHAR2(32000);
l_log_module            VARCHAR2(240);
l_bal_segment_column    VARCHAR2(30);
l_acct_segment_column   VARCHAR2(30);
l_cc_segment_column     VARCHAR2(30);
l_ic_segment_column     VARCHAR2(30);
l_mgt_segment_column    VARCHAR2(30);
l_ledger_info           r_ledger_info;
l_defn_info             r_definition_info;
l_seg_clause            VARCHAR2(32000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_trial_balance_upg';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('insert_trial_balance_upg.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_definition_code = ' || p_definition_code ,C_LEVEL_STATEMENT,l_log_module);
   END IF;
   -- Initialize Variables
   l_sql := C_TB_UPG_SQL;

   l_ledger_info := get_ledger_info
                      (p_ledger_id => g_ledger_id);

   get_segment_columns
            (p_coa_id              => l_ledger_info.coa_id
            ,p_bal_segment_column  => l_bal_segment_column
            ,p_acct_segment_column => l_acct_segment_column
            ,p_cc_segment_column   => l_cc_segment_column
            ,p_ic_segment_column   => l_ic_segment_column
            ,p_mgt_segment_column  => l_mgt_segment_column);

   l_sql :=
        REPLACE(l_sql,'$bal_segment$',l_bal_segment_column);
   l_sql :=
        REPLACE(l_sql,'$acct_segment$',l_acct_segment_column);
   l_sql :=
        REPLACE(l_sql,'$cc_segment$',l_cc_segment_column);
   l_sql :=
        REPLACE(l_sql,'$ic_segment$',l_ic_segment_column);
   l_sql :=
        REPLACE(l_sql,'$mgt_segment$',l_mgt_segment_column);

   l_defn_info   := get_report_definition
                      (p_definition_code => p_definition_code);

   IF l_defn_info.balance_side_code = 'C' THEN

      l_sql := REPLACE(l_sql,'$ent_rounded_amt_dr$','NULL');
      l_sql := REPLACE(l_sql,'$ent_rounded_amt_cr$','xdd.balance_amount');
      l_sql := REPLACE(l_sql,'$ent_unrounded_amt_dr$','NULL');
      l_sql := REPLACE(l_sql,'$ent_unrounded_amt_cr$','xdd.balance_amount');
      l_sql := REPLACE(l_sql,'$acct_rounded_amt_dr$','NULL');
      l_sql := replace(l_sql,'$acct_rounded_amt_cr$','xdd.balance_amount');
      l_sql := REPLACE(l_sql,'$acct_unrounded_amt_dr$','NULL');
      l_sql := REPLACE(l_sql,'$acct_unrounded_amt_cr$','xdd.balance_amount');

   ELSIF l_defn_info.balance_side_code = 'D' THEN

      l_sql := REPLACE(l_sql,'$ent_rounded_amt_dr$','xdd.balance_amount');
      l_sql := REPLACE(l_sql,'$ent_rounded_amt_cr$','NULL');
      l_sql := REPLACE(l_sql,'$ent_unrounded_amt_dr$','xdd.balance_amount');
      l_sql := REPLACE(l_sql,'$ent_unrounded_amt_cr$','NULL');
      l_sql := REPLACE(l_sql,'$acct_rounded_amt_dr$','xdd.balance_amount');
      l_sql := replace(l_sql,'$acct_rounded_amt_cr$','NULL');
      l_sql := REPLACE(l_sql,'$acct_unrounded_amt_dr$','xdd.balance_amount');
      l_sql := REPLACE(l_sql,'$acct_unrounded_amt_cr$','NULL');

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('l_sql after replace = ' ||
              substr(l_sql,1,3000),C_LEVEL_STATEMENT,l_Log_module);
       trace('l_sql after replace = ' ||
              substr(l_sql,3001,6000),C_LEVEL_STATEMENT,l_Log_module);
       trace('l_sql after replace = ' ||
              substr(l_sql,6001,9000),C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('Inserting trial balances - Upgrade ',C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   --
   -- Execute INSERT statement
   --
   EXECUTE IMMEDIATE l_sql
   USING l_ledger_info.currency_code
        ,l_ledger_info.ledger_id
        ,p_definition_code
        ,g_user_id
        ,g_user_id
        ,g_login_id
        ,g_request_id
        ,g_prog_appl_id
        ,g_program_id
        ,p_definition_code
        ,p_definition_code
        ,l_ledger_info.coa_id
        ;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Number of rows inserted  = ' || SQL%ROWCOUNT,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('l_sql = ' || l_sql,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('insert_trial_balance_upg.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
       IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
          trace('Unexpected error in insert_trial_balance_upg'
               ,C_LEVEL_UNEXPECTED
               ,l_log_module);
       END IF;
      RAISE;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_tb_data_manager_pvt.insert_trial_balance_upg');
END insert_trial_balance_upg;

/*===========================================================================+
  PROCEDURE
     insert_trial_balance_def

  DESCRIPTION
      Insert Trial Balance for a specific definition code

  SCOPE - PRIVATE

  ARGUMENTS



  NOTES

 +===========================================================================*/


PROCEDURE insert_trial_balance_def
            (p_definition_code IN VARCHAR2
            ,p_application_id  IN NUMBER       DEFAULT NULL -- for Data Fix
            ,p_from_header_id  IN PLS_INTEGER
            ,p_to_header_id    IN PLS_INTEGER
            ) IS

l_defined_by_code       xla_tb_definitions_b.defined_by_code%TYPE;
l_owner_code            xla_tb_definitions_b.owner_code%TYPE;
l_sql                   VARCHAR2(32000);
l_upg_sql               VARCHAR2(32000);
l_from                  VARCHAR2(4000);
l_where                 VARCHAR2(4000);
l_ledger_where          VARCHAR2(4000);
l_log_module            VARCHAR2(240);
l_bal_segment_column    VARCHAR2(30);
l_acct_segment_column   VARCHAR2(30);
l_cc_segment_column     VARCHAR2(30);
l_ic_segment_column     VARCHAR2(30);
l_mgt_segment_column    VARCHAR2(30);
l_ledger_info           r_ledger_info;
l_seg_clause            VARCHAR2(32000);
l_post_programs_where   VARCHAR2(32000);
l_application_id        PLS_INTEGER;
l_derived_primary_ledger PLS_INTEGER; --bug#7717479
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_trial_balance_def';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('Begin of insert_trial_balance_def',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_definition_code = ' || p_definition_code ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_from_header_id  = ' || p_from_header_id ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_to_header_id    = ' || p_to_header_id ,C_LEVEL_STATEMENT,l_log_module);
   END IF;


   --29-may-2008 change remodeling bug#7109823 dynamic building of where clause
   -- for accounting_class_code defined for program code OPEN_ACCT_BAL_DATA_MGR_
   --for a given application
   -- Modified the code below to consider accounting class codes of
   -- all applications bug#7600550 remodeling phase 4

    l_post_programs_where :=  ' AND xal.accounting_class_code IN (NULL';


    FOR i IN ( SELECT xsu.application_id
                FROM xla_subledgers xsu,
                     xla_tb_defn_je_sources xjs
               WHERE xsu.je_source_name = xjs.je_source_name
                 AND  xjs.definition_code = p_definition_code)
    LOOP
      l_application_id := i.application_id;

      FOR c1 in (
                  select accounting_class_code
                   from xla_acct_class_assgns xac, xla_post_acct_progs_b xpa
                  where xac.program_owner_code = xpa.program_owner_code
                    and xac.program_code       = xpa.program_code
                    and xac.program_code = 'OPEN_ACCT_BAL_DATA_MGR_'||l_application_id
                 )
      LOOP
            l_post_programs_where := l_post_programs_where||
                               ','''||c1.accounting_class_code||'''';
      END LOOP;

     END LOOP;

     l_post_programs_where := l_post_programs_where||')';

    --end bug#7109823

   -- Initialize Variables
   l_sql := g_tb_insert_sql;

   -- bug#7109823
   l_sql :=
        REPLACE(l_sql,'$l_accounting_class_code_where$',l_post_programs_where);
   --bug#7109823

   l_ledger_info := get_ledger_info(p_ledger_id => g_ledger_id);
   l_upg_sql := C_TB_INSERT_UPG_SQL_AE;

   get_segment_columns
            (p_coa_id              => l_ledger_info.coa_id
            ,p_bal_segment_column  => l_bal_segment_column
            ,p_acct_segment_column => l_acct_segment_column
            ,p_cc_segment_column   => l_cc_segment_column
            ,p_ic_segment_column   => l_ic_segment_column
            ,p_mgt_segment_column  => l_mgt_segment_column);


   l_sql :=
        REPLACE(l_sql,'$bal_segment$',l_bal_segment_column);
   l_sql :=
        REPLACE(l_sql,'$acct_segment$',l_acct_segment_column);
   l_sql :=
        REPLACE(l_sql,'$cc_segment$',l_cc_segment_column);
   l_sql :=
        REPLACE(l_sql,'$ic_segment$',l_ic_segment_column);
   l_sql :=
        REPLACE(l_sql,'$mgt_segment$',l_mgt_segment_column);

   --
   -- If object type is 'S' (Ledger Set) then
   --    use joins between gl_ledgers and gl_ledger_set_assignments
   -- else
   --    use a simple join with gl_ledgers
   -- end if
   l_ledger_where := get_ledger_where
                       (p_ledger_id        => g_ledger_id
                       ,p_object_type_code => l_ledger_info.object_type_code);

   l_sql := REPLACE(l_sql,'$l_ledger_where$',l_ledger_where);


   -- Derive Definition Type
   SELECT defined_by_code
         ,owner_code
   INTO   l_defined_by_code
         ,l_owner_code
   FROM   xla_tb_definitions_b
   WHERE  definition_code = p_definition_code;

   IF l_defined_by_code = 'FLEXFIELD' THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Defined by Flexfield = ',C_LEVEL_STATEMENT,l_Log_module);
      END IF;

      l_from  := ',xla_subledgers             xsu
                  ,xla_tb_defn_je_sources     xjs
                  ,xla_tb_defn_details        xdd ';

      --
      -- Owner Cocde = 'C' (User)
      --
      IF NVL(l_owner_code,'C') = 'C' THEN
         l_where := ' AND xtd.definition_code       = :10
                      AND xtd.definition_code      = xdd.definition_code
                      AND xal.code_combination_id  = xdd.code_combination_id
                      AND NVL(xdd.owner_code,''C'')= ''C''
                      AND xsu.application_id       = xah.application_id
                      AND xsu.je_source_name       = xjs.je_source_name
                      AND NVL(xjs.owner_code,''C'')= ''C''
                      AND xtd.definition_code      = xjs.definition_code ';
      ELSE
      --
      -- Owner Code = 'S' (Oracle) -- Upgraded
      -- accounting_date > balance_date (Bug 4931102)
      --
         l_where := ' AND xtd.definition_code      = :10
                      AND xtd.definition_code      = xdd.definition_code
                      AND xal.code_combination_id  = xdd.code_combination_id
                      AND xsu.application_id       = xah.application_id
                      AND xsu.je_source_name       = xjs.je_source_name
                      AND xtd.definition_code      = xjs.definition_code ';

      END IF;

      l_sql := REPLACE(l_sql,'$l_from$', l_from);
      l_sql := REPLACE(l_sql,'$l_where$', l_where);

     /* IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('l_sql after replace = ' || substr(l_sql,1,2000),C_LEVEL_STATEMENT,l_Log_module);
         trace('l_sql after replace = ' || substr(l_sql,2001,4000),C_LEVEL_STATEMENT,l_Log_module);
         trace('l_sql after replace = ' || substr(l_sql,4001,6000),C_LEVEL_STATEMENT,l_Log_module);

      END IF;
     */ -- commented for bug:7619431

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Inserting trial balances - by Flexfield ',C_LEVEL_STATEMENT,l_Log_module);
	 dump_text(p_text => l_sql); -- added for bug:7619431
      END IF;

      --
      -- Execute INSERT statement
      --
      EXECUTE IMMEDIATE l_sql
      USING g_user_id
           ,g_user_id
           ,g_login_id
           ,g_request_id
           ,g_prog_appl_id
           ,g_program_id
           ,p_from_header_id
           ,p_to_header_id
           ,g_ledger_id          -- :9 in get_ledger_where
           ,p_definition_code    -- :10 in this procedure
           ,l_ledger_info.coa_id -- :coa_id in C_TB_INSERT_SQL
                      ;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('# of rows inserted for R12 data = ' || SQL%ROWCOUNT,C_LEVEL_STATEMENT,l_log_module);
      END IF;

    /*Deriving primary ledger bug#7717479 */
     FOR i IN
     (
     SELECT ledger_id
     FROM gl_ledgers
     WHERE ledger_category_code = 'PRIMARY'
     AND   configuration_id =
                            (SELECT configuration_id
                              FROM gl_ledgers WHERE ledger_id = g_ledger_id )
     )
     LOOP
       l_derived_primary_ledger := i.ledger_id;
     END LOOP;

     l_derived_primary_ledger := nvl(l_derived_primary_ledger,g_ledger_id);
    /*End Deriving primary ledger bug#7717479 */


     l_where := ' AND xtd.definition_code      = xdd.definition_code
                  AND xtd.definition_code      = :4
                  AND xtd.definition_code      = xjs.definition_code
                  AND xtd.enabled_flag         = ''Y''
                  AND xjs.je_source_name       = xsu.je_source_name
                  AND xsu.application_id       = 200
                  AND alb.code_combination_id  = xdd.code_combination_id
                ';                                                          -- added for bug:7619431

     l_upg_sql := REPLACE(l_upg_sql, '$l_derived_primary_ledger$',l_derived_primary_ledger); -- bug#7717479
     l_upg_sql := REPLACE(l_upg_sql,'$l_from$', l_from);                    -- added for bug:7619431
     l_upg_sql := REPLACE(l_upg_sql,'$l_where$', l_where);                  -- added for bug:7619431

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Inserting trial balances for Upgraded Data - by Flexfield ',C_LEVEL_STATEMENT,l_Log_module);
	 dump_text(p_text => l_upg_sql); -- added for bug:7619431
      END IF;

       EXECUTE IMMEDIATE l_upg_sql
       USING p_from_header_id
            ,p_to_header_id
            ,g_ledger_id
            ,p_definition_code
           ;
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('# of rows inserted for Upgraded data = ' || SQL%ROWCOUNT,C_LEVEL_STATEMENT,l_log_module);
      END IF;

      l_upg_sql := C_TB_INSERT_UPG_SQL_SLE;

      l_upg_sql := REPLACE(l_upg_sql, '$l_derived_primary_ledger$',l_derived_primary_ledger); -- bug#7717479
      l_upg_sql := REPLACE(l_upg_sql,'$l_from$', l_from);                    -- added for bug:7619431
      l_upg_sql := REPLACE(l_upg_sql,'$l_where$', l_where);                  -- added for bug:7619431

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Inserting trial balances for AX Upgraded Data - by Flexfield ',C_LEVEL_STATEMENT,l_Log_module);
	 dump_text(p_text => l_upg_sql); -- added for bug:7619431
      END IF;

      EXECUTE IMMEDIATE l_upg_sql
       USING p_from_header_id
            ,p_to_header_id
            ,g_ledger_id
            ,p_definition_code
           ;

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('# of rows inserted for AX Upgraded  data = ' || SQL%ROWCOUNT,C_LEVEL_STATEMENT,l_log_module);
      END IF;

   ELSIF  l_defined_by_code = 'SEGMENT' THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Definition is defined by Segment ',C_LEVEL_STATEMENT,l_Log_module);
      END IF;

      l_seg_clause   := get_segment_clause(p_ledger_id => g_ledger_id);

      l_from  := ',xla_subledgers             xsu
                  ,xla_tb_defn_je_sources     xjs
                  ,xla_tb_def_seg_ranges      xsr ';

      l_where := ' AND xtd.definition_code         = :p_definition_code
                   AND xtd.definition_code         = xsr.definition_code
                   AND xsu.application_id          = xah.application_id
                   AND NVL(:11,xsu.application_id) = xsu.application_id
                   AND xsu.je_source_name          = xjs.je_source_name
                   AND xtd.definition_code         = xjs.definition_code ';


      l_sql :=
        REPLACE(l_sql,'$l_from$',l_from);
      l_sql :=
        REPLACE(l_sql,'$l_where$',l_where ||l_seg_clause);

    /*IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('l_sql after replace = ' || substr(l_sql,1,3000),C_LEVEL_STATEMENT,l_Log_module);
         trace('l_sql after replace = ' || substr(l_sql,3001,6000),C_LEVEL_STATEMENT,l_Log_module);
         trace('l_sql after replace = ' || substr(l_sql,6001,9000),C_LEVEL_STATEMENT,l_Log_module);
      END IF;
    */

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Inserting trial balances for R12 Data by Segment ',C_LEVEL_STATEMENT,l_Log_module);
         dump_text(p_text => l_sql);
      END IF;

      EXECUTE IMMEDIATE l_sql
      USING g_user_id
           ,g_user_id
           ,g_login_id
           ,g_request_id
           ,g_prog_appl_id
           ,g_program_id
           ,p_from_header_id
           ,p_to_header_id
           ,g_ledger_id
           ,p_definition_code     -- :10 in this procedure
           ,p_application_id      -- :11 in this procedure
           ,l_ledger_info.coa_id
           ;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('# of rows inserted for R12 Data by Segment  = ' || SQL%ROWCOUNT,C_LEVEL_STATEMENT,l_log_module);
      END IF;

      -- added the following code for bug: 7619431
      /*Deriving primary ledger bug#7717479 */
      FOR i IN
       (
         SELECT ledger_id
         FROM gl_ledgers
         WHERE ledger_category_code = 'PRIMARY'
         AND   configuration_id =
                            (SELECT configuration_id
                              FROM gl_ledgers WHERE ledger_id = g_ledger_id )
       )
      LOOP
            l_derived_primary_ledger := i.ledger_id;
      END LOOP;

      l_derived_primary_ledger := nvl(l_derived_primary_ledger,g_ledger_id);
      /*End Deriving primary ledger bug#7717479 */

      l_where := 'AND xtd.definition_code      = xsr.definition_code
                  AND xtd.definition_code      = :4
                  AND xtd.definition_code      = xjs.definition_code
                  AND xjs.je_source_name       = xsu.je_source_name
                  AND xsu.application_id       = 200
                ';

     l_upg_sql := REPLACE(l_upg_sql, '$l_derived_primary_ledger$',l_derived_primary_ledger); -- bug#7717479
     l_upg_sql := REPLACE(l_upg_sql,'$l_from$', l_from);
     l_upg_sql := REPLACE(l_upg_sql,'$l_where$', l_where || l_seg_clause );

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Inserting trial balances for Upgraded Data - by Segment',C_LEVEL_STATEMENT,l_Log_module);
	 dump_text(p_text => l_upg_sql);
      END IF;

       EXECUTE IMMEDIATE l_upg_sql
       USING p_from_header_id
            ,p_to_header_id
            ,g_ledger_id
            ,p_definition_code
           ;
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('# of rows inserted for Upgraded data = ' || SQL%ROWCOUNT,C_LEVEL_STATEMENT,l_log_module);
      END IF;

      l_upg_sql := C_TB_INSERT_UPG_SQL_SLE;

      l_upg_sql := REPLACE(l_upg_sql, '$l_derived_primary_ledger$',l_derived_primary_ledger);
      l_upg_sql := REPLACE(l_upg_sql,'$l_from$', l_from);
      l_upg_sql := REPLACE(l_upg_sql,'$l_where$', l_where || l_seg_clause);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Inserting trial balances for AX Upgraded Data - by Segment',C_LEVEL_STATEMENT,l_Log_module);
	 dump_text(p_text => l_upg_sql);
      END IF;

      EXECUTE IMMEDIATE l_upg_sql
       USING p_from_header_id
            ,p_to_header_id
            ,g_ledger_id
            ,p_definition_code
           ;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('# of rows inserted for AX Upgraded data - by Segment = ' || SQL%ROWCOUNT,C_LEVEL_STATEMENT,l_log_module);
      END IF;

   END IF;



   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('End of insert_trial_balance_def',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
       IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
          trace('Unexpected error in insert_trial_balance_def'
               ,C_LEVEL_UNEXPECTED
               ,l_log_module);
       END IF;
      RAISE;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_tb_data_manager_pvt.insert_trial_balance_def');
END insert_trial_balance_def;

/*------------------------------------------------------------+
|                                                             |
|  PUBLIC PROCEDURE                                           |
|                                                             |
|       recreate_trial_balances                               |
|                                                             |
|  Delete Trial Balances for given apps id and ae_header_id.  |
|  And re-extract journal entries to populate trila balances. |
|  Used for Data Fix.                                         |
+------------------------------------------------------------*/
PROCEDURE recreate_trial_balances
    (p_application_id         IN NUMBER
    ,p_ae_header_id           IN NUMBER)
IS

   l_definition_info    r_definition_info;
   l_array_defn_code    t_array_vc30b;
   l_log_module         VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.recreate_trial_balances';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN recreate_trial_balances'
           ,C_LEVEL_PROCEDURE
           ,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_application_id = '||p_application_id
           ,C_LEVEL_STATEMENT
           ,l_Log_module);
   END IF;

   --
   --  Set global variables for insert_trial_balance_def
   --
   g_request_id    := xla_environment_pkg.g_req_id;
   g_user_id       := xla_environment_pkg.g_usr_id;
   g_login_id      := xla_environment_pkg.g_login_id;
   g_prog_appl_id  := xla_environment_pkg.g_prog_appl_id;
   g_program_id    := xla_environment_pkg.g_prog_id;
   g_tb_insert_sql := C_TB_INSERT_SQL;

   DELETE xla_trial_balances
    WHERE source_application_id  = p_application_id
      AND ae_header_id           = p_ae_header_id
    RETURNING definition_code BULK COLLECT INTO l_array_defn_code;

   FOR i IN l_array_defn_code.FIRST .. l_array_defn_code.LAST LOOP

       l_definition_info := get_report_definition
                             (p_definition_code => l_array_defn_code(i));

       --
       --  Need g_ledger_id in insert_trial_balance_def
       --
       g_ledger_id     := l_definition_info.ledger_id;

       insert_trial_balance_def
         (p_definition_code => l_array_defn_code(i)
         ,p_application_id  => p_application_id
         ,p_from_header_id  => p_ae_header_id
         ,p_to_header_id    => p_ae_header_id);

   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END recreate_trial_balances'
           ,C_LEVEL_PROCEDURE
           ,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_data_manager_pvt.recreate_trial_balances');
END recreate_trial_balances;



/*===========================================================================+
  PROCEDURE
     insert_tb_logs

  DESCRIPTION


  SCOPE - PRIVATE

  ARGUMENTS


  NOTES

 +===========================================================================*/


PROCEDURE insert_tb_logs IS

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_tb_logs';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('insert_tb_logs.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Inserting into the xla_tb_logs table.',C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   INSERT INTO xla_tb_logs
      ( REQUEST_ID
      , LEDGER_ID
      , GROUP_ID
      , PROCESS_MODE_CODE
      , DEFINITION_CODE
      , DEFINITION_STATUS_CODE
      , REQUEST_STATUS_CODE
      )
   VALUES
      (g_request_id
      ,g_ledger_id
      ,g_group_id
      ,g_process_mode_code
      ,g_definition_code
      ,NULL
      ,C_WU_PROCESSING
      );

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END insert_tb_logs',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_tb_data_manager_pvt.insert_tb_logs');
END insert_tb_logs;

/*===========================================================================+
  PROCEDURE
     insert_trial_balance_wu

  DESCRIPTION


  SCOPE - PRIVATE

  ARGUMENTS
     p_ledger_id  - PRIMARY/secondary ledger identifier.

  NOTES

 +===========================================================================*/
PROCEDURE insert_trial_balance_wu
            (p_from_header_id IN PLS_INTEGER
            ,p_to_header_id   IN PLS_INTEGER
	    ,p_je_source_name    IN VARCHAR2 -- pass the je source name
            ) IS
l_log_module            VARCHAR2(240);
l_sql                   VARCHAR2(32000);
l_ledger_info           r_ledger_info;
l_bal_segment_column    VARCHAR2(30);
l_acct_segment_column   VARCHAR2(30);
l_cc_segment_column     VARCHAR2(30);
l_ic_segment_column     VARCHAR2(30);
l_mgt_segment_column    VARCHAR2(30);
l_from                  VARCHAR2(2000);
l_where                 VARCHAR2(32000);
l_ledger_where          VARCHAR2(4000);
l_seg_clause            VARCHAR2(32000);
l_application_id        PLS_INTEGER;
l_post_programs_where   VARCHAR2(32000);
l_group_id              NUMBER(15); --bug#7338524

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_trial_balance_wu';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN insert_trial_balance_wu',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;
   -- Initialize Variables
   l_sql          := g_tb_insert_sql;

   -- Replaced the hint to improve the performance in GSI instance bug#7213289
   --**********************Note****************************************
   --Any hint changes made in C_TB_INSERT_SQL replace the same correspondingly
   --in the replace statement below. Reason the SQL needs to run without any hints
   --to give better performance as observed in GSI instance bug#7213289 with respect
   --to the group id join.
   --**********************End Note************************************

   l_sql          := REPLACE(l_sql, '/*+ index(xah XLA_AE_HEADERS_U1)  no_index(xal MIS_XLA_AE_LINES_N1) */', ' ');


   l_ledger_info  := get_ledger_info(p_ledger_id => g_ledger_id);
   l_seg_clause   := get_segment_clause(p_ledger_id => g_ledger_id);
   l_from         := ',xla_tb_def_seg_ranges xsr ';
   l_where        := ' AND xtd.definition_code = xsr.definition_code ';

   IF g_group_id IS NOT NULL THEN
      l_where := l_where || ' AND xah.group_id        = :group_id ';
   END IF;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_from_header_id = ' || p_from_header_id,C_LEVEL_STATEMENT,l_Log_module);
      trace('p_to_header_id   = ' || p_to_header_id,C_LEVEL_STATEMENT,l_Log_module);
      trace('l_ledger_info.coa_id = ' || l_ledger_info.coa_id,C_LEVEL_STATEMENT,l_Log_module);
      trace('g_ledger_id = ' || g_ledger_id,C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   get_segment_columns
            (p_coa_id              => l_ledger_info.coa_id
            ,p_bal_segment_column  => l_bal_segment_column
            ,p_acct_segment_column => l_acct_segment_column
            ,p_cc_segment_column   => l_cc_segment_column
            ,p_ic_segment_column   => l_ic_segment_column
            ,p_mgt_segment_column  => l_mgt_segment_column);



   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('l_sql BEFORE replace = ' || substr(l_sql,1,3000),C_LEVEL_STATEMENT,l_Log_module);
      trace('l_sql BEFORE replace = ' || substr(l_sql,3001,6000),C_LEVEL_STATEMENT,l_Log_module);
   END IF;


  /*bug#7225096 4-Jul-2008 Added this replace as receiving ORA-00911: invalid character error
     when this program is spawned from Create Accounting */
   --29-may-2008 change remodeling bug#7109823 dynamic building of where clause
   -- for accounting_class_code defined for program code OPEN_ACCT_BAL_DATA_MGR_
   --for a given application
   -- Modified the code below to consider accounting class codes of
   -- all applications bug#7600550 remodeling phase 4

    l_post_programs_where :=  ' AND xal.accounting_class_code IN (NULL';

    FOR i IN (  SELECT xsu.application_id
                FROM xla_subledgers xsu,
                     (SELECT distinct je_source_name FROM xla_tb_defn_je_sources) xjs
               WHERE xsu.je_source_name = xjs.je_source_name
	       AND  xjs.je_source_name = p_je_source_name)
    LOOP
      l_application_id := i.application_id;

      FOR c1 in (
                  select accounting_class_code
                   from xla_acct_class_assgns xac, xla_post_acct_progs_b xpa
                  where xac.program_owner_code = xpa.program_owner_code
                    and xac.program_code       = xpa.program_code
                    and xac.program_code = 'OPEN_ACCT_BAL_DATA_MGR_'||l_application_id
                 )
      LOOP
            l_post_programs_where := l_post_programs_where||
                               ','''||c1.accounting_class_code||'''';
      END LOOP;

     END LOOP;

     l_post_programs_where := l_post_programs_where||')';

     l_sql :=
        REPLACE(l_sql,'$l_accounting_class_code_where$',l_post_programs_where);

    --end bug#7109823
  -- End bug#7225096 4-Jul-2008

   l_sql :=
        REPLACE(l_sql,'$bal_segment$',l_bal_segment_column);
   l_sql :=
        REPLACE(l_sql,'$acct_segment$',l_acct_segment_column);
   l_sql :=
        REPLACE(l_sql,'$cc_segment$',l_cc_segment_column);
   l_sql :=
        REPLACE(l_sql,'$ic_segment$',l_ic_segment_column);
   l_sql :=
        REPLACE(l_sql,'$mgt_segment$',l_mgt_segment_column);
   l_sql :=
        REPLACE(l_sql,'$l_from$',' ,xla_tb_def_seg_ranges xsr ');
   l_sql :=
        REPLACE(l_sql,'$l_where$',l_where ||l_seg_clause);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('l_sql AFTER replace = ' || substr(l_sql,1,3000),C_LEVEL_STATEMENT,l_Log_module);
      trace('l_sql AFTER replace = ' || substr(l_sql,3001,6000),C_LEVEL_STATEMENT,l_Log_module);
      trace('l_sql AFTER replace = ' || substr(l_sql,6001,9000),C_LEVEL_STATEMENT,l_Log_module);

   END IF;

   --
   -- If object type is 'S' (Ledger Set) then
   --    use joins between gl_ledgers and gl_ledger_set_assignments
   -- else
   --    use a simple join with gl_ledgers
   -- end if
   l_ledger_where := get_ledger_where
                       (p_ledger_id        => g_ledger_id
                       ,p_object_type_code => l_ledger_info.object_type_code);

   l_sql := REPLACE(l_sql,'$l_ledger_where$',l_ledger_where);


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Inserting trial balances  ',C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   IF g_group_id IS NOT NULL THEN
     /*
      bug#7338524 This cursor has been introduced to find the correct group_id
      for the header_id passed and lying in xla_tb_work_units but not associated
      to the current group_id generated for transfer to GL.
      The failed worker units in xla_tb_work_units table is updated with the
      current transfer to GL's parent request id in recover_failed_requests procedure.
      The ae_header_id of that failed request would be picked up by the worker's and
      will be passed to this procedure for inserting into xla_trial_balances table.
      Part of recovery is handled here.
     */

     FOR i in ( SELECT group_id FROM xla_tb_work_units
                WHERE FROM_HEADER_ID = p_from_header_id )
     LOOP
       l_group_id := i.group_id;
     END LOOP;

     EXECUTE IMMEDIATE l_sql
      USING g_user_id
           ,g_user_id
           ,g_login_id
           ,g_request_id
           ,g_prog_appl_id
           ,g_program_id
           ,p_from_header_id
           ,p_to_header_id
           ,g_ledger_id
           , nvl(l_group_id,g_group_id) -- bug#7338524
          --,g_group_id
           ,l_ledger_info.coa_id
           ;
   ELSE
      EXECUTE IMMEDIATE l_sql
      USING g_user_id
           ,g_user_id
           ,g_login_id
           ,g_request_id
           ,g_prog_appl_id
           ,g_program_id
           ,p_from_header_id
           ,p_to_header_id
           ,g_ledger_id
           ,l_ledger_info.coa_id;
   END IF;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Number of rows inserted =   ' || SQL%ROWCOUNT,C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END insert_trial_balance_wu',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_tb_data_manager_pvt.insert_trial_balance_wu');
END insert_trial_balance_wu;





/*===========================================================================+
  PROCEDURE
     RECOVER_BATCH

  DESCRIPTION
     Performs RECOVERY opration FOR THE previously failed batches.


  SCOPE - PRIVATE

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED

  ARGUMENTS


  NOTES

 +===========================================================================*/
PROCEDURE recover_failed_requests
   (p_ledger_id       IN INTEGER
   ,p_definition_code IN VARCHAR2
   ) IS


l_log_module  VARCHAR2(240);
l_process_mode_code VARCHAR2(30);

   -- Find a failed request for a specific defintion
   CURSOR c_failed_req_def IS
      SELECT xtb.request_id, xtb.process_mode_code
      FROM   xla_tb_logs  xtb
            ,fnd_concurrent_requests fcr
      WHERE  xtb.ledger_id                      = p_ledger_id
      AND    xtb.definition_code                = p_definition_code
      AND    xtb.request_status_code            = 'PROCESSING'
      AND    xtb.request_id                     = fcr.request_id
      AND    fcr.phase_code NOT IN ('R','P','I');

   -- Find requests failed for a group_id or not specific to a definition code
   CURSOR c_failed_req ( p_ledger_id VARCHAR2 ) IS
      SELECT xtb.request_id
      FROM   xla_tb_logs       xtb
            ,fnd_concurrent_requests fcr
      WHERE  xtb.ledger_id                      = p_ledger_id
      AND    xtb.definition_code IS NULL
      AND    xtb.request_status_code            = 'PROCESSING'
      AND    xtb.request_id                     = fcr.request_id
      AND    fcr.phase_code NOT IN ('R','P','I');
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.recover_failed_requests';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('recover_failed_requests.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;


   -- for failed requests, delete old requets from the tb_log table, update
   -- the work unit table with new parent request_id, NEW status
   -- Ignore request that are either runnning, pending or inactive.
   -- Phase Code: R - Running, P - Pending, I - Inactive
   -- Check if there is an existing request for the specified criteria.


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Resetting parent request in TB work units. ',C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   -- Recover request for a specific definition code
   IF g_definition_code IS NOT NULL THEN
      FOR failed_req_rec IN c_failed_req_def
      LOOP

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('failed_req_rec - Updating TB work units',C_LEVEL_STATEMENT,l_Log_module);
         END IF;

         -- Process
         UPDATE xla_tb_work_units
         SET    status_code       = C_WU_UNPROCESSED
               ,parent_request_id = g_request_id
         WHERE definition_code    = g_definition_code;

         g_wu_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Work units updated (g_wu_count) = ' || g_wu_count,C_LEVEL_STATEMENT,l_Log_module);
            trace('failed_req_rec - Deleting TB logs',C_LEVEL_STATEMENT,l_Log_module);
         END IF;

         DELETE xla_tb_logs
         WHERE  request_id  = failed_req_rec.request_id;

      END LOOP;
   ELSE
      FOR failed_req_rec IN c_failed_req(p_ledger_id => p_ledger_id)
      LOOP
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Updating work units for request id = ' || failed_req_rec.request_id,C_LEVEL_STATEMENT,l_Log_module);
         END IF;

         UPDATE xla_tb_work_units
         SET    status_code       = C_WU_UNPROCESSED
               ,parent_request_id = g_request_id
         WHERE  parent_request_id = failed_req_rec.request_id;

         g_wu_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Work units updated = ' || g_wu_count,C_LEVEL_STATEMENT,l_Log_module);
            trace('Work units updated rowcount = ' || SQL%ROWCOUNT,C_LEVEL_STATEMENT,l_Log_module);
         END IF;

         DELETE xla_tb_logs
         WHERE  request_id  = failed_req_rec.request_id;
      END LOOP;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Deleting entries from TB logs for failed requests.',C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   DELETE xla_tb_logs xtl
   WHERE  request_id NOT IN
      (  SELECT xtb.request_id
         FROM   xla_tb_logs       xtb
               ,fnd_concurrent_requests fcr
         WHERE  xtb.ledger_id                   = p_ledger_id
         AND    nvl(xtb.definition_code,'###')  = NVL(p_definition_code,'###')
         AND    xtb.request_status_code         = 'PROCESSING'
         AND    xtb.request_id                  = fcr.request_id
         AND    fcr.phase_code IN ('R','P','I'))
  /* bug#7338524 Added this and clause as records of only the current ledger
    needs to be deleted from the logs*/
   AND ledger_id = p_ledger_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('recover_failed_requests.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      trace('Recovery failed',C_LEVEL_UNEXPECTED,l_Log_module);
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.get_gllezl_status');
END recover_failed_requests;



/*------------------------------------------------------------+
|                                                             |
|  PRIVATE FUNCTION                                           |
|                                                             |
|       update_definition_status                              |
|                                                             |
+------------------------------------------------------------*/
PROCEDURE update_definition_status
         (p_definition_code IN VARCHAR2
         ,p_status_code     IN VARCHAR2) IS

   l_log_module      VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_definition_status';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of update_definition_status'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   UPDATE xla_tb_definitions_b
      SET definition_status_code = p_status_code
         ,last_updated_by        = g_user_id
         ,last_update_date       = SYSDATE
         ,last_update_login      = g_login_id
         ,request_id             = g_request_id
         ,program_application_id = g_prog_appl_id
         ,program_id             = g_program_id
         ,program_update_date    = SYSDATE
    WHERE definition_code = p_definition_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of update_definition_status'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
     RAISE;
WHEN OTHERS THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_data_manager_pvt.update_definition_status');
END update_definition_status;


/*------------------------------------------------------------+
|                                                             |
|  PRIVATE FUNCTION                                           |
|                                                             |
|       upload_pvt                                            |
|                                                             |
+------------------------------------------------------------*/
PROCEDURE generate_work_units
             (p_ledger_id        IN NUMBER
             ,p_group_id         IN NUMBER
             ,p_definition_code  IN VARCHAR2
             ) IS

l_group_id      NUMBER(15);
l_upg_batch_id  NUMBER(15);
l_ledger_id     NUMBER(15);
l_ledger_info   r_ledger_info;

l_log_module    VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_work_units';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN generate_work_units',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_ledger_id       = ' || p_ledger_id,C_LEVEL_STATEMENT,l_log_module);
      trace('p_group_id        = ' || p_group_id,C_LEVEL_STATEMENT,l_log_module);
      trace('p_definition_code = ' || p_definition_code,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   l_ledger_info := get_ledger_info(p_ledger_id => p_ledger_id);

   IF p_group_id IS NOT NULL THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Generating work units for a group_id = '
              || p_group_id,C_LEVEL_STATEMENT,l_log_module);
         trace('Ledger Object Type Code = '
              || l_ledger_info.object_type_code,C_LEVEL_STATEMENT,l_log_module);
      END IF;

      IF l_ledger_info.object_type_code = 'S' THEN
         --
         -- Ledger Set
         --
         INSERT INTO xla_tb_work_units
               (group_id
               ,upg_batch_id
               ,from_header_id
               ,to_header_id
               ,status_code
               ,parent_request_id
               )
         SELECT
                p_group_id
               ,l_upg_batch_id
               ,min(ae_header_id)
               ,max(ae_header_id)
               ,C_WU_UNPROCESSED
               ,g_request_id
           FROM
               (SELECT ae_header_id,
                     FLOOR
                     (
                      sum(count(*)) over
                         (ORDER BY ae_header_id
                          ROWS unbounded preceding
                       )/g_work_unit
                      ) wu
                FROM   xla_ae_headers
                WHERE  group_id          = p_group_id
                  AND  ledger_id         IN (
                         SELECT lg.ledger_id
                           FROM gl_ledgers lg
                               ,gl_ledger_set_assignments sa
                          WHERE lg.ledger_id     = sa.ledger_id
                            AND sa.ledger_set_id = p_ledger_id)
                GROUP BY ae_header_id
             )
        GROUP BY wu;


      ELSE
         --
         --  p_ledger_id is not a ledger set
         --
         INSERT INTO xla_tb_work_units
               (group_id
               ,upg_batch_id
               ,from_header_id
               ,to_header_id
               ,status_code
               ,parent_request_id
               )
         SELECT
                p_group_id
               ,l_upg_batch_id
               ,min(ae_header_id)
               ,max(ae_header_id)
               ,C_WU_UNPROCESSED
               ,g_request_id
           FROM
               (SELECT ae_header_id,
                     FLOOR
                     (
                      sum(count(*)) over
                         (ORDER BY ae_header_id
                          ROWS unbounded preceding
                       )/g_work_unit
                      ) wu
                FROM   xla_ae_headers
                WHERE  group_id          = p_group_id
                  AND  ledger_id         = p_ledger_id
                GROUP BY ae_header_id
             )
          GROUP BY wu;

      END IF;

   ELSIF p_definition_code IS NOT NULL OR p_group_id IS NULL THEN

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Generating work units for definition code = '||p_definition_code
              ,C_LEVEL_STATEMENT
              ,l_log_module);
         trace('Ledger Object Type Code = '
              || l_ledger_info.object_type_code
              ,C_LEVEL_STATEMENT
              ,l_log_module);
      END IF;

      --
      -- p_gl_date_from is not null only for upgrade on demand
      --
      IF g_gl_date_from IS NULL THEN
      -- Select all entries transferred to GL

         IF l_ledger_info.object_type_code = 'S' THEN
            --
            -- Ledger Set
            --
            INSERT INTO xla_tb_work_units
                  (group_id
                  ,upg_batch_id
                  ,from_header_id
                  ,to_header_id
                  ,status_code
                  ,parent_request_id
                  ,definition_code
                  )
            SELECT
                   NULL
                  ,l_upg_batch_id
                  ,min(ae_header_id)
                  ,max(ae_header_id)
                  ,C_WU_UNPROCESSED
                  ,g_request_id
                  ,p_definition_code
            FROM
                  (SELECT ae_header_id,
                     FLOOR
                     (
                      sum(count(*)) over
                         (ORDER BY ae_header_id
                          ROWS unbounded preceding
                       )/C_WORK_UNIT
                      ) wu
                   FROM xla_ae_headers aeh
                       ,xla_subledgers xsu
                       ,xla_tb_definitions_b xtd
                       ,xla_tb_defn_je_sources xjs
                  WHERE gl_transfer_status_code IN ('Y','NT')
                    AND aeh.ledger_id         IN (
                          SELECT lg.ledger_id
                            FROM gl_ledgers lg
                                ,gl_ledger_set_assignments sa
                           WHERE lg.ledger_id     = sa.ledger_id
                             AND sa.ledger_set_id = p_ledger_id)
                    AND xtd.definition_code     = p_definition_code
                    AND xtd.definition_code     = xjs.definition_code
                    AND xjs.je_source_name      = xsu.je_source_name
                    AND aeh.application_id      = xsu.application_id
                  GROUP BY ae_header_id
             )
            GROUP BY wu;
         ELSE
            --
            -- p_ledger_id is not a ledger set
            --
            INSERT INTO xla_tb_work_units
                  (group_id
                  ,upg_batch_id
                  ,from_header_id
                  ,to_header_id
                  ,status_code
                  ,parent_request_id
                  ,definition_code
                  )
            SELECT
                   NULL
                  ,l_upg_batch_id
                  ,min(ae_header_id)
                  ,max(ae_header_id)
                  ,C_WU_UNPROCESSED
                  ,g_request_id
                  ,p_definition_code
            FROM
                  (SELECT ae_header_id,
                     FLOOR
                     (
                      sum(count(*)) over
                         (ORDER BY ae_header_id
                          ROWS unbounded preceding
                       )/C_WORK_UNIT
                      ) wu
                   FROM xla_ae_headers aeh
                       ,xla_subledgers xsu
                       ,xla_tb_definitions_b xtd
                       ,xla_tb_defn_je_sources xjs
                  WHERE gl_transfer_status_code IN ('Y','NT')
                    AND aeh.ledger_id           = p_ledger_id
                    AND xtd.definition_code     = p_definition_code
                    AND xtd.definition_code     = xjs.definition_code
                    AND xjs.je_source_name      = xsu.je_source_name
                    AND aeh.application_id      = xsu.application_id
                  GROUP BY ae_header_id
             )
            GROUP BY wu;
          END IF; -- Ledger Set
      --
      --  Upgrade On Demand
      --
      ELSE
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Generating work units for definition code (Upgrade) = '||p_definition_code
                 ,C_LEVEL_STATEMENT
                 ,l_log_module);
            trace('Ledger Object Type Code = '
                 || l_ledger_info.object_type_code
                 ,C_LEVEL_STATEMENT
                 ,l_log_module);
         END IF;

         IF l_ledger_info.object_type_code = 'S' THEN
            --
            -- Ledger Set
            --
            INSERT INTO xla_tb_work_units
                  (group_id
                  ,upg_batch_id
                  ,from_header_id
                  ,to_header_id
                  ,status_code
                  ,parent_request_id
                  ,definition_code
                  )
            SELECT
                   NULL
                  ,l_upg_batch_id
                  ,min(ae_header_id)
                  ,max(ae_header_id)
                  ,C_WU_UNPROCESSED
                  ,g_request_id
                  ,p_definition_code
            FROM
                  (SELECT ae_header_id,
                        FLOOR
                        (
                         sum(count(*)) over
                            (ORDER BY ae_header_id
                             ROWS unbounded preceding
                          )/C_WORK_UNIT
                         ) wu
                     FROM xla_ae_headers aeh
                         ,xla_subledgers xsu
                         ,xla_tb_definitions_b xtd
                         ,xla_tb_defn_je_sources xjs
                    WHERE gl_transfer_status_code IN ('Y','NT')
                      AND aeh.ledger_id           IN (
                                 SELECT lg.ledger_id
                                   FROM gl_ledgers lg
                                       ,gl_ledger_set_assignments sa
                                  WHERE lg.ledger_id     = sa.ledger_id
                                    AND sa.ledger_set_id = p_ledger_id)
                      AND xtd.definition_code     = p_definition_code
                      AND xtd.definition_code     = xjs.definition_code
                      AND xjs.je_source_name      = xsu.je_source_name
                      AND xsu.je_source_name      = g_je_source_name
                      AND aeh.application_id      = xsu.application_id
                      AND aeh.accounting_date
                       >= fnd_date.canonical_to_date(g_gl_date_from)
                      AND aeh.accounting_date
                       <= fnd_date.canonical_to_date(g_gl_date_to)
                    GROUP BY ae_header_id
                )
            GROUP BY wu;
         ELSE
            --
            -- p_ledger_id is not a ledger set
            --
            INSERT INTO xla_tb_work_units
                  (group_id
                  ,upg_batch_id
                  ,from_header_id
                  ,to_header_id
                  ,status_code
                  ,parent_request_id
                  ,definition_code
                  )
            SELECT
                   NULL
                  ,l_upg_batch_id
                  ,min(ae_header_id)
                  ,max(ae_header_id)
                  ,C_WU_UNPROCESSED
                  ,g_request_id
                  ,p_definition_code
            FROM
                  (SELECT ae_header_id,
                        FLOOR
                        (
                         sum(count(*)) over
                            (ORDER BY ae_header_id
                             ROWS unbounded preceding
                          )/C_WORK_UNIT
                         ) wu
                     FROM xla_ae_headers aeh
                         ,xla_subledgers xsu
                         ,xla_tb_definitions_b xtd
                         ,xla_tb_defn_je_sources xjs
                    WHERE gl_transfer_status_code IN ('Y','NT')
                      AND aeh.ledger_id           = p_ledger_id
                      AND xtd.definition_code     = p_definition_code
                      AND xtd.definition_code     = xjs.definition_code
                      AND xjs.je_source_name      = xsu.je_source_name
                      AND xsu.je_source_name      = g_je_source_name
                      AND aeh.application_id      = xsu.application_id
                      AND aeh.accounting_date
                       >= fnd_date.canonical_to_date(g_gl_date_from)
                      AND aeh.accounting_date
                       <= fnd_date.canonical_to_date(g_gl_date_to)
                    GROUP BY ae_header_id
                )
            GROUP BY wu;
         END IF;
      END IF; -- p_gl_date_from is null

   END IF;

   IF nvl(g_wu_count,0) <= 0  THEN
      g_wu_count := SQL%ROWCOUNT;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Generated work units = ' || g_wu_count ,C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(' END generate_work_units',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
   WHEN OTHERS THEN
        xla_exceptions_pkg.raise_message
            (p_location => 'xla_tb_data_manager_pvt.generate_work_units');
END generate_work_units;

/*------------------------------------------------------------+
|                                                             |
|  PRIVATE FUNCTION                                           |
|                                                             |
|       Retrieve_Work_Unit                                    |
|                                                             |
+------------------------------------------------------------*/
PROCEDURE retrieve_work_unit
   (p_from_header_id  OUT NOCOPY VARCHAR2
   ,p_to_header_id    OUT NOCOPY VARCHAR2
   ,p_definition_code OUT NOCOPY VARCHAR2
   ,p_parent_request_id IN PLS_INTEGER
   ) IS

  l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.retrieve_work_unit';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN retrieve_work_unit',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_parent_request_id =  ' || p_parent_request_id,C_LEVEL_STATEMENT,l_log_module);
      trace('Updating tb_work_units.status_code to ' || C_WU_PROCESSING,C_LEVEL_STATEMENT,l_log_module);
   END IF;


   UPDATE xla_tb_work_units
      SET status_code            = C_WU_PROCESSING
    WHERE parent_request_id      = p_parent_request_id
    AND   status_code            = C_WU_UNPROCESSED
    AND ROWNUM                   = 1
    RETURNING from_header_id
             ,to_header_id
             ,definition_code
         INTO p_from_header_id, p_to_header_id, p_definition_code;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Number of work units updated = ' || SQL%ROWCOUNT,C_LEVEL_STATEMENT,l_log_module);
      trace('p_from_header_id    =  ' || p_from_header_id,C_LEVEL_STATEMENT,l_log_module);
      trace('p_to_header_id      =  ' || p_to_header_id,C_LEVEL_STATEMENT,l_log_module);
      trace('p_definition_code   =  ' || p_definition_code,C_LEVEL_STATEMENT,l_log_module);
   END IF;

  COMMIT;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END retrieve_work_unit',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
     RAISE;
WHEN OTHERS THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_data_manager_pvt.retrieve_work_units');
END retrieve_work_unit;



/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
|    Upload_Preprocessor                                                |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE upload_preprocessor
            (p_ledger_id   IN NUMBER) IS

l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.upload_preprocessor';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN upload_preprocessor',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Deleting log entry',C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   -- No need to generate if it's a recovery operation.

   IF g_group_id IS NOT NULL OR g_process_mode_code IS NOT NULL THEN
      generate_work_units (p_ledger_id       => p_ledger_id
                          ,p_group_id        => g_group_id
                          ,p_definition_code => g_definition_code);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END upload_preprocessor',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_tb_data_manager_pvt.upload_preprocessor');
END upload_preprocessor;

/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
|    update_definition                                                  |
|                                                                       |
|                                                                       |
+======================================================================*/

PROCEDURE truncate_partition
   (p_definition_code VARCHAR2
   ) IS
l_log_module   VARCHAR2(240);
l_schema       VARCHAR2(30);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.truncate_partition';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN truncate_partition',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Truncating the partition',C_LEVEL_STATEMENT,l_Log_module);
   END IF;
   l_schema := get_schema;


   -- Truncate Partition
   EXECUTE IMMEDIATE 'ALTER TABLE ' || l_schema ||'.XLA_TRIAL_BALANCES TRUNCATE partition '||p_definition_code;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END truncate_partition',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_tb_data_manager_pvt.truncate_partition');
END truncate_partition;

/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
|    Upload_Pvt                                                         |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE upload_pvt
  (p_errbuf          OUT NOCOPY VARCHAR2
  ,p_retcode         OUT NOCOPY NUMBER
  ,p_ledger_id       IN  NUMBER
  ,p_group_id        IN  NUMBER
  ,p_definition_code IN  VARCHAR2
  ) IS


l_req_data           VARCHAR2(10);
l_request_id         NUMBER(15);
l_log_module         VARCHAR2(240);
l_array_wu_requests  t_array_num15;
l_callStatus         BOOLEAN;
l_phase              VARCHAR2(30);
l_status             VARCHAR2(30);
l_dev_phase          VARCHAR2(30);
l_dev_status         VARCHAR2(30);
l_message            VARCHAR2(240);


BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.upload_pvt';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_group_id = '||p_group_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_definition_code = '||p_definition_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
      --
      --
      -- Generate work units
      --
      upload_preprocessor(p_ledger_id => p_ledger_id);


      IF nvl(g_wu_count,0) = 0 THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('No work units to process existing',C_LEVEL_STATEMENT,l_Log_module);
         END IF;
         RETURN;
      END IF;
      COMMIT;

      -- Initialize array
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Initializing array',C_LEVEL_STATEMENT,l_Log_module);
      END IF;
      g_array_wu_requests.DELETE;

      --
      -- Submit child processes
      --

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Submitting child processes',C_LEVEL_STATEMENT,l_Log_module);
      END IF;

      FOR j IN 1..g_NUM_OF_WORKERS LOOP

         l_request_id := FND_REQUEST.SUBMIT_REQUEST
                           (application => 'XLA'
                           ,program     => 'XLATBDMW'
                           ,description => 'TB Worker '||j
                           ,start_time  => SYSDATE
                           ,sub_request => NULL
                           ,argument1   => p_ledger_id
                           ,argument2   => p_group_id
                           ,argument3   => p_definition_code
                           ,argument4   => g_request_id
			   ,argument5   => g_je_source_name -- to pass g_je_source_name
                           );

         COMMIT;
         IF l_request_id = 0 THEN

            p_errbuf  := fnd_message.get;
            p_retcode := 2;

            RETURN;
         ELSE
           --l_array_wu_requests(l_request_id) := l_request_id;
	   /* bug#7552876 request ids are not getting generated sequentially.
	   so on looping l_array_wu_requests outside is giving ORA-01403: no data found
	   error */
	    l_array_wu_requests(j) := l_request_id;
         END IF;
      END LOOP;

      -- Wait until child threads stop

   FOR i IN REVERSE l_array_wu_requests.first..l_array_wu_requests.last
   LOOP
      IF (l_array_wu_requests(i) IS NOT NULL) THEN
         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace('Checking status for request id = ' || l_array_wu_requests(i),C_LEVEL_EVENT,l_log_module);
         END IF;
         l_callStatus := fnd_concurrent.wait_for_request
            (request_id => l_array_wu_requests(i)
            ,interval   => 5
            ,phase      => l_phase
            ,status     => l_status
            ,dev_phase  => l_dev_phase
            ,dev_status => l_dev_status
            ,message    => l_message);

        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('l_dev_phase = '  || l_dev_phase,C_LEVEL_STATEMENT,l_log_module);
          trace('l_dev_status = ' || l_dev_status,C_LEVEL_STATEMENT,l_log_module);
        END IF;

        IF ( l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL') THEN
           IF (C_LEVEL_ERROR >= g_log_level) THEN
               trace('The child request failed. Request Id = ' || l_array_wu_requests(i),C_LEVEL_ERROR,l_log_module);
               xla_exceptions_pkg.raise_message
                  (p_location => 'The child request failed. Request Id = ' || l_array_wu_requests(i));
           END IF;
         END IF;
      END IF;
   END LOOP;

   -- Once all the child processes stop. If there are no work units to process
   -- then delete row from the TB logs table.

/*
   fnd_conc_global.set_req_globals(conc_status  => 'PAUSED',
                                   request_data => fnd_global.conc_request_id);
*/

--perf imp 13-May-2008 moved here ie after all the workers have finished processing
    populate_user_trans_view
    (p_definition_code => p_definition_code
     ,p_ledger_id       => p_ledger_id
     ,p_group_id        => p_group_id
    );
--perf imp 13-May-2008

   p_errbuf  := 'Worker processes submitted.';
   p_retcode := 0;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('upload_pvt.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;
   RETURN;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_tb_data_manager_pvt.upload_pvt');

END upload_pvt;

PROCEDURE validate_parameters
   (p_ledger_id         IN INTEGER
   ,p_definition_code   IN VARCHAR2
   ,p_group_id          IN INTEGER
   ,p_process_mode_code IN VARCHAR2
   ) IS
BEGIN

   IF p_ledger_id IS NOT NULL THEN
     -- ledger_id is required
      NULL;
   ELSIF p_definition_code IS NOT NULL
      AND p_group_id IS NOT NULL THEN
     -- invalid parameters
     NULL;
   ELSIF p_group_id IS NOT NULL AND p_process_mode_code IS NOT NULL THEN
      NULL;
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_tb_data_manager_pvt.validate_parameters');
END validate_parameters;


/*======================================================================+
|                                                                       |
| PUBLIC FUNCTION                                                       |
|                                                                       |
|    Upload                                                             |
|                                                                       |
|    Main PROCEDURE TO upload trial balance                             |
|    Called FROM Cocurrent Program Trial Balance Data Manager           |
|    p_process_mode_code = DELETED, CHANGED, NEW                        |
+======================================================================*/
PROCEDURE upload
   (p_errbuf                   IN OUT NOCOPY VARCHAR2
   ,p_retcode                  IN OUT NOCOPY NUMBER
   ,p_application_id           IN NUMBER    DEFAULT NULL
   ,p_ledger_id                IN NUMBER
   ,p_group_id                 IN NUMBER
   ,p_definition_code          IN VARCHAR2  DEFAULT NULL
   ,p_process_mode_code        IN VARCHAR2
   ,p_je_source_name           IN VARCHAR2  DEFAULT NULL
   ,p_upg_batch_id             IN NUMBER    DEFAULT NULL
   ,p_gl_date_from             IN VARCHAR2  DEFAULT NULL
   ,p_gl_date_to               IN VARCHAR2  DEFAULT NULL
   ) IS

l_req_data        VARCHAR2(10);
l_request_id      NUMBER(15);
l_log_module      VARCHAR2(240);

BEGIN
   --Initialize Variables
   g_request_id               := xla_environment_pkg.g_req_id;
   g_user_id                  := xla_environment_pkg.g_usr_id;
   g_login_id                 := xla_environment_pkg.g_login_id;
   g_prog_appl_id             := xla_environment_pkg.g_prog_appl_id;
   g_program_id               := xla_environment_pkg.g_prog_id;
   g_ledger_id                := p_ledger_id;
   g_definition_code          := p_definition_code;
   g_process_mode_code        := p_process_mode_code;
   g_je_source_name           := p_je_source_name;
   g_group_id                 := p_group_id;
   g_gl_date_from             := p_gl_date_from;
   g_gl_date_to               := p_gl_date_to;


   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.upload';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure upload'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_group_id = '||p_group_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_definition_code = '||p_definition_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_process_mode_code = '||p_process_mode_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_je_source_name = '||p_je_source_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   -- Validate input parameters
   validate_parameters(
      p_ledger_id          => p_ledger_id
     ,p_definition_code    => p_definition_code
     ,p_group_id           => p_group_id
     ,p_process_mode_code  => p_process_mode_code
   );

   -- Insert log entries
   insert_tb_logs;


   IF p_je_source_name IS NOT NULL THEN
      g_application_id := get_je_source_info
                              (p_je_source_name => p_je_source_name);
   END IF;

   IF p_process_mode_code = 'DELETED' THEN
      delete_definition
         ( p_definition_code => p_definition_code);
      drop_partition;
   ELSIF p_process_mode_code in ('CHANGED','NEW') THEN
      -- Delete non setup data
      delete_trial_balances
         ( p_definition_code => p_definition_code);
      truncate_partition
         ( p_definition_code => p_definition_code);
      -- Recreate segment ranges
      define_segment_ranges
         ( p_definition_code => p_definition_code);
   END IF;

   -- Recover failed batches.
   -- IF p_group_id IS NULL
   /*Bug#7338524 Changed this condition to group_id IS NOT NULL as in case of transfer
   to GL group_id is passed and recovery needs to be done for failed batches lying in
   xla_tb_logs which belongs to different group_id */

   IF p_group_id IS NOT NULL
      --OR (p_definition_code IS NOT NULL AND p_process_mode_code IS NULL)
  /* commented this condition as part of bug#7344564 which needs review and
   further analysis of the issues raised as part of recovery */
   THEN
      recover_failed_requests
         (p_ledger_id         => p_ledger_id
         ,p_definition_code   => p_definition_code
         );
   END IF;

   IF nvl(p_process_mode_code,'N') NOT IN ('DELETED') THEN
      -- Derive processing unit;
      --
      -- Set work unit size and number of workers
      --
      get_worker_info(p_ledger_id => p_ledger_id);

      --
      -- Submit Worker Processes
      --
      upload_pvt
        (p_errbuf          => p_errbuf
        ,p_retcode         => p_retcode
        ,p_ledger_id       => p_ledger_id
        ,p_group_id        => p_group_id
        ,p_definition_code => p_definition_code
        );

   END IF;

   -- Delete log entry
   delete_tb_log;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
   WHEN OTHERS THEN
	     xla_exceptions_pkg.raise_message
	              (p_location => 'xla_tb_data_manager_pvt.upload');
END upload;


/*======================================================================+
|
| PRIVATE FUNCTION
|
|    delete_wu
|
|
+======================================================================*/

PROCEDURE delete_wu
   (p_from_header_id NUMBER )IS

l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.delete_wu';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN of delete_wu',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_from_header_id = '||p_from_header_id,C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   DELETE xla_tb_work_units
   WHERE  from_header_id = p_from_header_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END of delete_wu',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_tb_data_manager_pvt.delete_wu');

END delete_wu;

/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
|    Worker_Proces_Pvt                                                  |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE worker_process_pvt
    (p_errbuf            OUT NOCOPY VARCHAR2
    ,p_retcode           OUT NOCOPY VARCHAR2
    ,p_ledger_id         IN  NUMBER
    ,p_definition_code   IN  VARCHAR2
    ,p_parent_request_id IN PLS_INTEGER
    ,p_je_source_name    IN VARCHAR2 -- to pass the je_source_name
    )  IS

l_from_header_id    NUMBER(15);
l_to_header_id      NUMBER(15);
l_definition_code   xla_tb_definitions_b.definition_code%TYPE;
l_log_module        VARCHAR2(240);
l_owner_code        VARCHAR2(1);
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.worker_process_pvt';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('worker_process_pvt.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace('p_ledger_id         = ' || p_ledger_id
           ,C_LEVEL_STATEMENT
           ,l_log_module);

      trace('p_definition_code   = ' || p_definition_code
           ,C_LEVEL_STATEMENT
           ,l_log_module);

      trace('p_parent_request_id = ' || p_parent_request_id
           ,C_LEVEL_STATEMENT
           ,l_log_module);
   END IF;

   -- Initialize variables

   g_tb_insert_sql := C_TB_INSERT_SQL;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Calling  retrieve_work_unit ',C_LEVEL_STATEMENT,l_log_module);
   END IF;

   LOOP
      retrieve_work_unit
         (p_parent_request_id => p_parent_request_id
         ,p_from_header_id    => l_from_header_id
         ,p_to_header_id      => l_to_header_id
         ,p_definition_code   => l_definition_code
        );

      --
      --  Exit when there is no work unit
      --
      IF l_from_header_id IS NULL THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('No more records to process ',C_LEVEL_STATEMENT,l_log_module);
         END IF;
         EXIT;
      END IF;

      IF p_definition_code IS NOT NULL THEN
         insert_trial_balance_def
            (p_definition_code => l_definition_code
            ,p_from_header_id => l_from_header_id
            ,p_to_header_id   => l_to_header_id
            );
      ELSE
         insert_trial_balance_wu
            (p_from_header_id => l_from_header_id
            ,p_to_header_id   => l_to_header_id
	    ,p_je_source_name => p_je_source_name  -- pass the je_source_name
            );
      END IF;

      --
      -- Moved from worker_process to eliminate TX contention
      -- for the case # of unit processors is more than one.
      --

      --
      -- Delete Work Unit
      --

      delete_wu(p_from_header_id => l_from_header_id);


   END LOOP;

   --
   --  Create upgraded rows
   --
   /* Bug 5635401
      Due to the change in bug 5394467, need not populate initial balances.
      For upgraded report definitions, insert_trial_balance_upg will fail
      with ORA-1400 as balance date is null.

   FOR c_def IN (SELECT definition_code
                   FROM xla_tb_definitions_b
                  WHERE definition_code = NVL(p_definition_code,definition_code)
                    AND ledger_id = p_ledger_id
                    AND owner_code = 'S')
   LOOP

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('System Generated Report Definition ' || c_def.definition_code
              ,C_LEVEL_STATEMENT
              ,l_log_module);
      END IF;

      --
      -- Delete existing records
      --
      DELETE FROM xla_trial_balances
      WHERE  definition_code  = c_def.definition_code
        AND  source_entity_id = -1;

      insert_trial_balance_upg
        (p_definition_code => c_def.definition_code);

   END LOOP;
   */

   COMMIT;

   p_errbuf  := 'Completed successfully.';
   p_retcode := 0;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('worker_process_pvt.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
   IF l_from_header_id IS NOT NULL THEN

      /*
      update_wu_status
         (p_from_header_id => l_from_header_id
         ,p_status_code    => C_WU_ERROR);
      */ -- update processes status

      p_errbuf  := SQLERRM;
      p_retcode := 2;

      COMMIT;

   END IF;
   xla_exceptions_pkg.raise_message
        (p_location => 'xla_tb_data_manager_pvt.worker_process_pvt');

END worker_process_pvt;

/*======================================================================+
|                                                                       |
| PUBLIC FUNCTION                                                       |
|                                                                       |
|    Worker_Proces                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE worker_process
  (p_errbuf            OUT NOCOPY VARCHAR2
  ,p_retcode           OUT NOCOPY NUMBER
  ,p_ledger_id         IN  NUMBER
  ,p_group_id          IN  NUMBER
  ,p_definition_code   IN  VARCHAR2
  ,p_parent_request_id IN PLS_INTEGER
  ,p_je_source_name    IN VARCHAR2  --to pass the je_source_name
  ) IS

l_log_module       VARCHAR2(240);
l_ledger_info      r_ledger_info;
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.worker_process';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN of worker_process',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      -- Print all input parameters
      trace('p_ledger_id        = ' || p_ledger_id      ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_group_id         = ' || p_group_id      ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_definition_code  = ' || p_definition_code,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   -- Initialize variables
   g_request_id               := xla_environment_pkg.g_req_id;
   g_user_id                  := xla_environment_pkg.g_usr_id;
   g_login_id                 := xla_environment_pkg.g_login_id;
   g_prog_appl_id             := xla_environment_pkg.g_prog_appl_id;
   g_program_id               := xla_environment_pkg.g_prog_id;
   g_group_id                 := p_group_id;
   g_ledger_id                := p_ledger_id;
   l_ledger_info              := get_ledger_info
                                  (p_ledger_id => g_ledger_id);


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('Calling worker_process_pvt ',C_LEVEL_STATEMENT,l_log_module);
   END IF;

   worker_process_pvt
      (p_errbuf            => p_errbuf
      ,p_retcode           => p_retcode
      ,p_ledger_id         => p_ledger_id
      ,p_definition_code   => p_definition_code
      ,p_parent_request_id => p_parent_request_id
      ,p_je_source_name    => p_je_source_name -- to pass the je_source_name
      );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Calling populate_user_trans_view ',C_LEVEL_STATEMENT,l_log_module);
   END IF;

   p_errbuf  := 'Completed Successfully.';
   p_retcode := 0;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('End of worker_process',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
       IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
          trace('Unexpected error in worker_process'
               ,C_LEVEL_UNEXPECTED
               ,l_log_module);
       END IF;
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
       (p_location       => 'xla_accounting_pub_pkg.accounting_program_batch');
END worker_process;

/*======================================================================+
|                                                                       |
| PUBLIC FUNCTION                                                       |
|                                                                       |
|    Delete_Non_UI_Rows                                                 |
|                                                                       |
|    Deletes rows from the following tables:                            |
|    - xla_tb_logs                                                      |
|    - xla_tb_def_seg_ranges                                            |
|    - xla_tb_user_trans_views                                          |
|    - xla_tb_work_units                                                |
|                                                                       |
|    For xla_trial_balances, call drop_partition separately             |
|    Called from TbReportDefnsAMImpl.java.                              |
+======================================================================*/
PROCEDURE delete_non_ui_rows
   (p_definition_code IN VARCHAR2)
IS
   l_log_module        VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.worker_process';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('BEGIN delete_non_ui_data'
           ,C_LEVEL_PROCEDURE
           ,l_log_module);
   END IF;

   DELETE xla_tb_logs
   WHERE  definition_code = p_definition_code;

   DELETE xla_tb_def_seg_ranges
   WHERE  definition_code = p_definition_code;

   DELETE xla_tb_user_trans_views
   WHERE  definition_code = p_definition_code;

   DELETE xla_tb_work_units
   WHERE  definition_code = p_definition_code;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('END delete_non_ui_rows'
           ,C_LEVEL_PROCEDURE
           ,l_log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
       IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
          trace('Unexpected error in delete_non_ui_rows'
               ,C_LEVEL_UNEXPECTED
               ,l_log_module);
       END IF;
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
       (p_location       => 'xla_tb_data_manager_pvt.delete_non_ui_rows');
END delete_non_ui_rows;

--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

--=============================================================================
--
--
--
--  The following code is executed when the package body is referenced for the
-- first time
--
--
--
--=============================================================================

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;



END XLA_TB_DATA_MANAGER_PVT;

/
