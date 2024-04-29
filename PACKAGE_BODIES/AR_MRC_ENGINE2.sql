--------------------------------------------------------
--  DDL for Package Body AR_MRC_ENGINE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_MRC_ENGINE2" AS
/* $Header: ARMCEN2B.pls 120.6 2005/04/14 22:41:38 hyu noship $ */

/*=============================================================================
 |   Public Functions / Procedures
 *============================================================================*/

/*=============================================================================
 |  PUBLIC PROCEDURE  Maintain_MRC_Data2
 |
 |  DESCRIPTION:
 |                Initial Entry point for all AR code in order to maintain,
 |                or create any MRC data for the following Tables:
 |                AR_DISTRIBTIONS
 |                AR_RECEIVABLE_APPLICATIONS
 |                RA_CUST_TRX_LINE_GL_DIST
 |
 |                This procedure will call the appropriate MRC api with the
 |                information required.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |   p_event_mode          IN     event to preform on MRC tables (INSERT/UPDATE)
 |   p_table_name          IN     Base Table Name.
 |   p_key_value           IN     primary key value (USED IN SINGLE MODE)
 |   p_row_info            IN     AR_DISTRIBTIONS%ROWTYPE
 |   p_mode                IN     SINGLE or BATCH MODE
 |   p_key_value_list      IN     Used in Batch Mode (list of values)
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:   DELETES TO THIS TABLES WILL NOT BE PROCESSED IN THIS MODULE
 |           THEY ARE HANDLED THE SAME FOR ALL TABLES AND WILL BE PROCESSED
 |           IN THE ORIGINAL AR_MRC_ENGINE
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  04/25/02    Debbie Sue Jancis  	Created
 *============================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE  Maintain_MRC_Data2(
            p_event_mode     IN VARCHAR2,
            p_table_name     IN VARCHAR2,
            p_mode           IN VARCHAR,
            p_key_value      IN NUMBER default NULL,
            p_key_value_list IN gl_ca_utility_pkg.r_key_value_arr default NULL,
            p_row_info       IN AR_DISTRIBUTIONS%ROWTYPE DEFAULT NULL
          ) IS
BEGIN
--{BUG4301323
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE2.Maintain_MRC_Data2(+)');
--   END IF;

   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +-----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('Maintain_MRC_Data2: ' || ' EVENT Mode        : ' || p_event_mode);
--      arp_standard.debug('Maintain_MRC_Data2: ' || ' Table Name  : ' || p_table_name);
--      arp_standard.debug('Maintain_MRC_Data2: ' || 'key_value : ' || to_char(p_key_value));
--      arp_standard.debug('Maintain_MRC_Data2: ' || 'p_mode : ' || p_mode);
--   END IF;


   /*-----------------------------------------------------------------+
    | In order to work for backwards compatiability, we need to check |
    | for the table names which have had the trigger replaced.  So    |
    | each time a new table is added, it needs to be added here,      |
    | until all tables are added and this outside if statement can be |
    | removed.                                                        |
    +-----------------------------------------------------------------*/

--  IF (p_table_name = 'AR_DISTRIBUTIONS' ) THEN

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('Maintain_MRC_Data2: ' || 'Called with one of the supported table names ');
--   END IF;
   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('Maintain_MRC_Data2: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--    IF (gl_ca_utility_pkg.mrc_enabled(p_sob_id => ar_mc_info.primary_sob_id,
--                               p_org_id => ar_mc_info.org_id,
--                               p_appl_id => 222
--                              ))  THEN

--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('Maintain_MRC_Data2: ' || 'MRC is enabled...     ');
--        END IF;

       /*------------------------------------------------------------+
        | Branch based upon the mode of operation                    |
        +------------------------------------------------------------*/
--        IF (p_event_mode = 'DELETE') THEN
--            IF PG_DEBUG in ('Y', 'C') THEN
--               arp_standard.debug('Maintain_MRC_Data2: ' || 'THIS MODULE SHOULD NOT BE CALLED FOR Deletion');
--            END IF;
--        END IF;   /* end p_event_mode = DELETE */

--        IF  ( p_event_mode = 'INSERT') THEN
--              BEGIN
--                  IF ( p_table_name = 'AR_DISTRIBUTIONS') THEN
--                     arp_mrc_acct_main.derive_mrc_acctg(
--                                 p_line_id        => p_key_value,
--                                 p_key_value_list => p_key_value_list,
--                                 p_row_info       => p_row_info,
--                                 p_ddl_mode       => p_event_mode,
--                                 p_process_mode   => p_mode);
--                  END IF;
--              EXCEPTION
--               WHEN OTHERS THEN
--                  IF PG_DEBUG in ('Y', 'C') THEN
--                     arp_standard.debug('Maintain_MRC_Data2: ' || SQLERRM);
--                    arp_standard.debug('Maintain_MRC_Data2: ' || 'error during Insert for ' || p_table_name);
--                 END IF;
--                 APP_EXCEPTION.RAISE_EXCEPTION;
--              END;
--        END IF;   /* end p_event_mode = INSERT */

--        IF (p_event_mode = 'UPDATE') THEN

--           IF PG_DEBUG in ('Y', 'C') THEN
--              arp_standard.debug('Maintain_MRC_Data2: ' || 'Before calling MRC api for Update');
--           END IF;
--           BEGIN

--              IF (p_table_name = 'AR_DISTRIBUTIONS') THEN
--                     arp_mrc_acct_main.derive_mrc_acctg(
--                                 p_line_id        => p_key_value,
--                                 p_key_value_list => p_key_value_list,
--                                 p_row_info       => p_row_info,
--                                 p_ddl_mode       => p_event_mode,
--                                 p_process_mode   => p_mode);
--              END IF;
--           EXCEPTION
--              WHEN OTHERS THEN
--                 IF PG_DEBUG in ('Y', 'C') THEN
--                    arp_standard.debug('Maintain_MRC_Data2: ' || 'error during update for ' || p_table_name);
--                 END IF;
--                 APP_EXCEPTION.RAISE_EXCEPTION;
--           END;
--        END IF;   /* end p_event_mode = UPDATE */

--    END IF;  /* end of mrc is enabled */

--  END IF;   /* end of checking for specific tables */
--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE2.Maintain_MRC_Data2(-)');
--  END IF;

END Maintain_MRC_Data2;

/*===========================================================================
 |  PROCEDURE  mrc_bulk_process
 |
 |  DESCRIPTION:
 |                 This procedure will be called by auto receipts to insert
 |                 records into MRC tables using BULK processing
 |
 |  CALLS PROCEDURES / FUNCTIONS
 |
 |  ar_mc_info.rec_mrc_bulk_process    (MRC bulk processing API
 |                                      called from Auto Receipts
 |                                      for ar_cash_Receipts,
 |                                      ar_cash_Receipt_history,
 |                                      and ar_payment_schedules inserts)
 |  PARAMETERS
 |     p_prog_name           IN   VARCHAR   (AUTOREC)
 |     p_request_id          IN   VARCHAR2
 |     p_batch_id            IN   VARCHAR2
 |     p_confirmed_flag      IN   VARCHAR2
 |     p_history_status      IN   VARCHAR2
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  07/24/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE  mrc_bulk_process(
                   p_prog_name        IN VARCHAR2,
                   p_created_from     IN VARCHAR2,
                   p_request_id       IN VARCHAR2,
                   p_batch_id         IN VARCHAR2,
                   p_confirmed_flag   IN VARCHAR2,
                   p_history_status   IN VARCHAR2)
IS

BEGIN
--{BUG#4301323
NULL;
--    IF PG_DEBUG in ('Y', 'C') THEN
--       arp_standard.debug('AR_MRC_ENGINE2.mrc_bulk_process(+)');
--       arp_standard.debug('mrc_bulk_process: ' || 'CALLING PROGRAM : ' || p_prog_name);
--       arp_standard.debug('mrc_bulk_process: ' || 'before checking to see if mrc is enabled..');
--    END IF;
--    IF (gl_ca_utility_pkg.mrc_enabled(p_sob_id => ar_mc_info.primary_sob_id,
--                               p_org_id => ar_mc_info.org_id,
--                               p_appl_id => 222
--                              ))  THEN

--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('mrc_bulk_process: ' || 'MRC is enabled...     ');
--        END IF;

--         AR_MC_INFO.rec_mrc_bulk_process(
--                           to_number(p_request_id),
--                           to_number(p_batch_id),
--                           p_confirmed_flag,
--                           p_history_status,
--                           p_created_from
--                            );
--    END IF;

--    IF PG_DEBUG in ('Y', 'C') THEN
--       arp_standard.debug('AR_MRC_ENGINE2.mrc_bulk_process(-)');
--    END IF;
END mrc_bulk_process;

/*===========================================================================
 |  PROCEDURE  mrc_correct_rounding
 |
 |  DESCRIPTION:
 |                 This procedure will be called by the rounding package to
 |                 handle rounding in the MRC table
 |
 |  CALLS PROCEDURES / FUNCTIONS
 |
 |  ar_mc_info.correct_receivables_header
 |  ar_mc_info.correct_nonrule_line_records
 |  ar_mc_info.correct_receivables_records
 |  ar_mc_info.correct_round_records
 |  ar_mc_info.correct_rul_records_by_line
 |
 |  PARAMETERS
 |      rounding_prog_name        IN VARCHAR2,
 |      p_request_id              IN NUMBER,
 |      p_customer_trx_id         IN NUMBER,
 |      p_customer_trx_line_id    IN NUMBER,
 |      p_trx_class_to_process    IN VARCHAR2,
 |      concat_segs               IN VARCHAR2 default null,
 |      balanced_round_ccid       IN NUMBER   default null,
 |      p_check_rules_flag        IN VARCHAR2 default null,
 |      p_period_set_name         IN VARCHAR2 default null
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  08/20/02    Debbie Sue Jancis       Created
 |  05/27/04    Srinivasa Kini          Added CORRECT_SUSPENSE
 *============================================================================*/
PROCEDURE  mrc_correct_rounding(
                  rounding_prog_name        IN VARCHAR2,
                  p_request_id              IN NUMBER,
                  p_customer_trx_id         IN NUMBER,
                  p_customer_trx_line_id    IN NUMBER,
                  p_trx_class_to_process    IN VARCHAR2,
                  concat_segs               IN VARCHAR2 default null,
                  balanced_round_ccid       IN NUMBER   default null,
                  p_check_rules_flag        IN VARCHAR2 default null,
                  p_period_set_name         IN VARCHAR2 default null
) IS
BEGIN
--{BUG4301323
NULL;
--    IF PG_DEBUG in ('Y', 'C') THEN
--       arp_standard.debug('AR_MRC_ENGINE2.mrc_correct_rounding(+)');
--       arp_standard.debug('mrc_correct_rounding: ' || 'before checking to see if mrc is enabled..');
--    END IF;
--    IF (gl_ca_utility_pkg.mrc_enabled(p_sob_id => ar_mc_info.primary_sob_id,
--                               p_org_id => ar_mc_info.org_id,
--                               p_appl_id => 222
--                              ))  THEN
--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('mrc_correct_rounding: ' || 'MRC is enabled...     ');
--        END IF;

--        IF (rounding_prog_name =  'CORRECT_NONRULE_LINE_RECORDS') THEN
--            ar_mc_info.correct_nonrule_line_records(
--                                  p_request_id,
--                                  p_customer_trx_id,
--                                  p_customer_trx_line_id,
--                                  p_trx_class_to_process);
--        ELSIF (rounding_prog_name = 'CORRECT_RECEIVABLES_RECORDS') THEN
--            ar_mc_info.correct_receivables_records(
--                                  p_request_id,
--                                  p_customer_trx_id,
--                                  p_customer_trx_line_id,
--                                  p_trx_class_to_process);
--        ELSIF (rounding_prog_name = 'CORRECT_ROUND_RECORDS') THEN
--            ar_mc_info.correct_round_records(
--                                  p_request_id,
--                                  p_customer_trx_id,
--                                  p_customer_trx_line_id,
--                                  p_trx_class_to_process,
--                                  concat_segs,
--                                  balanced_round_ccid);

--        ELSIF (rounding_prog_name = 'CORRECT_RULE_RECORDS_BY_LINE') THEN
--            ar_mc_info.correct_rule_records_by_line(
--                                  p_request_id,
--                                  p_customer_trx_id,
--                                  p_trx_class_to_process,
--                                  p_check_rules_flag,
--                                  p_period_set_name);

--        ELSIF (rounding_prog_name = 'CORRECT_REV_ADJ_BY_LINE') THEN
--            /* Bug 3879222 - enhancement to RAM Collectibility */
--            /* Note that this correction is done using a join
--               to ar_line_rev_adj_gt so no parameters are
--               required */
--            ar_mc_info.correct_rev_adj_by_line;

--        ELSIF (rounding_prog_name = 'CORRECT_RECEIVABLES_HEADER') THEN
--            ar_mc_info.correct_receivables_header(
--                                  p_request_id,
--                                  p_customer_trx_id,
--                                  p_customer_trx_line_id,
--                                  p_trx_class_to_process);
--        ELSIF (rounding_prog_name = 'CORRECT_SUSPENSE') THEN
--            ar_mc_info.correct_suspense(p_customer_trx_id);
--        ELSE
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('INCORRECT arguments to mrc_correct_rounding');
--              END IF;
--        END IF;
--    END IF;

--    IF PG_DEBUG in ('Y', 'C') THEN
--       arp_standard.debug('AR_MRC_ENGINE2.mrc_correct_rounding(-)');
--    END IF;
END mrc_correct_rounding;


END AR_MRC_ENGINE2;

/
