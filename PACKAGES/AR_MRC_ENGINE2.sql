--------------------------------------------------------
--  DDL for Package AR_MRC_ENGINE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_MRC_ENGINE2" AUTHID CURRENT_USER AS
/* $Header: ARMCEN2S.pls 120.1 2004/12/03 01:45:51 orashid noship $ */

/*============================================================================+
 |  Declare PUBLIC Data Types and Variables                                   |
 +============================================================================*/

/*=============================================================================
 |  PUBLIC PROCEDURE  Maintain_MRC_Data2
 |
 |  DESCRIPTION:
 |                Initial Entry point for all AR code in order to maintain,
 |                create, and delete any MRC data for the following Tables:
 |		  AR_DISTRIBTIONS
 |		  AR_RECEIVABLE_APPLICATIONS
 |                RA_CUST_TRX_LINE_GL_DIST
 |
 |                This procedure will call the appropriate MRC api with the
 |                information required.
 |
 |  PARAMETERS
 |   p_event_mode          IN     event to preform on MRC tables
 |   p_table_name          IN     Base Table Name.
 |   p_key_value           IN     primary key value
 |   p_row_info            IN     AR_DISTRIBTIONS%ROWTYPE
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date    	Author             	Description of Change
 |  04/25/02	Debbie Sue Jancis  	Created
 |
 *============================================================================*/
 PROCEDURE  Maintain_MRC_Data2(
            p_event_mode     IN VARCHAR2,
            p_table_name     IN VARCHAR2,
            p_mode           IN VARCHAR,
            p_key_value      IN NUMBER default NULL,
            p_key_value_list IN gl_ca_utility_pkg.r_key_value_arr default NULL,
            p_row_info       IN AR_DISTRIBUTIONS%ROWTYPE DEFAULT NULL
              );

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
                   p_history_status   IN VARCHAR2
             );

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
             );

END AR_MRC_ENGINE2;

 

/
