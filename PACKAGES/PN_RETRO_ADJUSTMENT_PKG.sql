--------------------------------------------------------
--  DDL for Package PN_RETRO_ADJUSTMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_RETRO_ADJUSTMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: PNRTADJS.pls 120.1.12010000.2 2009/05/26 07:08:53 rthumma ship $ */

------------------------------ DECLARATIONS ----------------------------------+

TYPE payment_item_rec IS RECORD(
   item_id        pn_payment_items.payment_item_id%TYPE,
   start_date     pn_payment_items.adj_start_date%TYPE,
   end_date       pn_payment_items.adj_end_date%TYPE,
   trx_date       pn_payment_items.due_date%TYPE,
   amount         pn_payment_terms.actual_amount%TYPE,
   new_amount     pn_payment_terms.actual_amount%TYPE,
   payment_status pn_payment_schedules.payment_status_lookup_code%TYPE,
   schedule_date  pn_payment_schedules.schedule_date%TYPE,
   schedule_id    pn_payment_schedules.payment_schedule_id%TYPE,
   adj_summ_id    pn_adjustment_summaries.adjustment_summary_id%TYPE,
   adj_date       pn_adjustment_summaries.adj_schedule_date%TYPE);

TYPE payment_item_tbl_type IS TABLE OF payment_item_rec INDEX BY BINARY_INTEGER;

--------------------------- PUBLIC PROCEDURES --------------------------------+

PROCEDURE create_retro_adjustments(
            p_lease_id      pn_payment_terms.lease_id%TYPE,
            p_lease_chg_id  pn_lease_changes.lease_change_id%TYPE,
            p_term_id       pn_payment_terms.payment_term_id%TYPE,
            p_term_start_dt pn_payment_terms.start_date%TYPE,
            p_term_end_dt   pn_payment_terms.end_date%TYPE,
            p_term_sch_day  pn_payment_terms.schedule_day%TYPE,
            p_term_act_amt  pn_payment_terms.actual_amount%TYPE,
            p_term_freq     pn_payment_terms.frequency_code%TYPE,
            p_term_hist_id  pn_payment_terms_history.term_history_id%TYPE,
            p_adj_type_cd   pn_payment_items.last_adjustment_type_code%TYPE
         );

PROCEDURE find_schedule (
            p_lease_id        pn_leases.lease_id%TYPE,
            p_lease_change_id pn_lease_changes.lease_change_id%TYPE,
            p_term_id         pn_payment_terms.payment_term_id%TYPE,
            p_schedule_date   pn_payment_schedules.schedule_date%TYPE,
            p_schedule_id     OUT NOCOPY pn_payment_schedules.payment_schedule_id%TYPE
         );

PROCEDURE create_virtual_schedules(
            p_start_date pn_payment_terms.start_date%TYPE,
            p_end_date   pn_payment_terms.end_date%TYPE,
            p_sch_day    pn_payment_terms.schedule_day%TYPE,
            p_amount     pn_payment_terms.actual_amount%TYPE,
            p_term_freq  pn_payment_terms.frequency_code%TYPE,
    	    p_payment_term_id pn_payment_terms_all.payment_term_id%TYPE,
            x_sched_tbl  OUT NOCOPY payment_item_tbl_type
         );

PROCEDURE cleanup_schedules(p_lease_id        pn_leases_all.lease_id%TYPE);

END pn_retro_adjustment_pkg;

/
