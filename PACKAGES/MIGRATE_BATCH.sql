--------------------------------------------------------
--  DDL for Package MIGRATE_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MIGRATE_BATCH" AUTHID CURRENT_USER AS
/* $Header: GMEMIGBS.pls 120.1 2005/06/09 08:26:06 appldev  $ */

/***********************************************************/
/* Oracle Process Manufacturing Process Execution APIs     */
/*                                                         */
/* File Name: GMEMIGBS.pls                                 */
/* Contents:  Package specification for migration          */
/* Author:    Shrikant Nene                                */
/* Date:      January 2001                                 */
/*                                                         */
/* History                                                 */
/* =======                                                 */
/*  05-JUL-01  Thomas Daniel                              */
/* Added code to process on batch entity row at a time*/
/* also added code to write error messages on the     */
/* occurence of an error               */
/*  12-NOV-01  Thomas Daniel                              */
/* Added the split_trans_line and is_reversal routines to  */
/* split the completed default lot line                    */
/*  15-NOV-01 Pawan Kumar Addfunction check product        */
/*                                                         */
/*  12-DEC-01 Shyam Sitaraman                              */
/*  1) Created a backup for insert_message                 */
/*                            => insert_message_into_table */
/*  2) Made insert_message a private procedure in PL/SQL it*/
/*     amounts to removing the this procedure from the pkg */
/*     specification                                       */
/*  3) Created a constructor for this package              */
/*     It performs the following actions -                 */
/*     a)  Initialize global variables, currently we have  */
/*         g_location that gets the file path were the GME */
/*         validation log file is created                  */
/*     b)  Avoids repeated cursors calls.                  */
/*                                                         */
/* G. Muratore  06/09/2005 Bug 4249832                     */
/*     Removed hard coded schemas per gscc.                */
/***********************************************************/

   /* Package variable to hold the trans ids of reversal transactions */
   p_default_loct   VARCHAR2 (80) := fnd_profile.VALUE ('IC$DEFAULT_LOCT');

   PROCEDURE initialize_migration;

   FUNCTION get_oprn_id (p_batch_id IN NUMBER, p_batchstep_no IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_process_qty_uom (p_oprn_id NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_actual_cost_ind (p_batch_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_gl_posted_ind (p_batch_id IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_poc_data_ind (p_batch_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_ref_uom (p_uom_class IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_batchstep_id (p_batch_id IN NUMBER, p_batchstep_no IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_wip_planned_qty (
      p_batch_id     IN   NUMBER,
      p_line_id      IN   NUMBER,
      p_actual_qty   IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION get_planned_qty (
      p_batch_id   IN   NUMBER,
      p_line_id    IN   NUMBER,
      p_plan_qty   IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION get_actual_qty (
      p_batch_id     IN   NUMBER,
      p_line_id      IN   NUMBER,
      p_actual_qty   IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION get_actual_activity_factor (
      p_batchstep_id   IN   gme_batch_steps.batchstep_id%TYPE
   )
      RETURN gme_batch_step_activities.actual_activity_factor%TYPE;

   FUNCTION get_planned_usage (p_batchstepline_id IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_actual_usage (p_line_id IN NUMBER)
      RETURN NUMBER;

   PROCEDURE check_wip_batches (
      x_return_status            OUT NOCOPY      VARCHAR2,
      p_reverse_compl_def_txns   IN       BOOLEAN DEFAULT FALSE
   );

   PROCEDURE run (p_commit IN BOOLEAN DEFAULT FALSE);

   PROCEDURE insert_batch_header (x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE insert_material_details (x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE insert_batch_steps (x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE insert_batch_step_dtls (x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE insert_batch_step_items (x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE insert_batch_step_dependencies (x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE insert_resource_txns (x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE insert_batch_history (x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE insert_batch_step_transfers (x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE insert_text_header (x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE insert_text_dtl (x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE split_trans_line (x_return_status OUT NOCOPY VARCHAR2);

   /*  Commented this procedure to make it Private to this package */
   /* PROCEDURE insert_message(p_table_name   IN VARCHAR2,
                           p_procedure_name   IN VARCHAR2,
                           p_parameters       IN VARCHAR2,
                           p_message       IN VARCHAR2,
                           p_error_type    IN VARCHAR2);

   PROCEDURE insert_message_into_table (p_table_name   IN VARCHAR2,
                                        p_procedure_name  IN VARCHAR2,
                                        p_parameters      IN VARCHAR2,
                                        p_message      IN VARCHAR2,
                                        p_error_type      IN VARCHAR2);

   */

   PROCEDURE deduce_transaction_warehouse (
      p_transaction   IN       ic_tran_pnd%ROWTYPE,
      p_item_master   IN       ic_item_mst%ROWTYPE,
      x_whse_code     OUT NOCOPY      ps_whse_eff.whse_code%TYPE
   );

   PROCEDURE get_default_lot (
      p_line_id         IN       pm_matl_dtl_bak.line_id%TYPE,
      x_def_lot_id      OUT NOCOPY      ic_tran_pnd.trans_id%TYPE,
      x_is_plain        OUT NOCOPY      BOOLEAN,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE load_trans (
      p_batch_row       IN       pm_btch_hdr_bak%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE build_gmi_trans (
      p_ic_tran_row     IN       ic_tran_pnd%ROWTYPE,
      x_tran_row        OUT NOCOPY      gmi_trans_engine_pub.ictran_rec,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE insert_inv_txns_gtmp (
      p_batch_id        IN       pm_btch_hdr_bak.batch_id%TYPE,
      p_doc_type        IN       ic_tran_pnd.doc_type%TYPE,
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_trans_id        IN       ic_tran_pnd.trans_id%TYPE DEFAULT NULL
   );

   FUNCTION get_actual_date (p_date IN DATE)
      RETURN DATE;

   FUNCTION get_rsrc_offset (
      p_batch_id       IN   pm_btch_hdr_bak.batch_id%TYPE,
      p_batchstep_no   IN   pm_rout_dtl.batchstep_no%TYPE,
      p_activity       IN   pm_oprn_dtl.activity%TYPE,
      p_offset         IN   pm_oprn_dtl.offset_interval%TYPE
   )
      RETURN NUMBER;

   FUNCTION get_min_capacity (
      p_batch_id   pm_btch_hdr_bak.batch_id%TYPE,
      p_rsrc       pm_oprn_dtl.resources%TYPE
   )
      RETURN NUMBER;

   FUNCTION get_max_capacity (
      p_batch_id   pm_btch_hdr_bak.batch_id%TYPE,
      p_rsrc       pm_oprn_dtl.resources%TYPE
   )
      RETURN NUMBER;

   FUNCTION get_capacity_uom (
      p_batch_id   pm_btch_hdr_bak.batch_id%TYPE,
      p_rsrc       pm_oprn_dtl.resources%TYPE
   )
      RETURN VARCHAR2;

   PROCEDURE get_capacity (
      p_batch_id        IN       pm_btch_hdr_bak.batch_id%TYPE,
      p_resources       IN       pm_oprn_dtl.resources%TYPE,
      x_min_capacity    OUT NOCOPY      NUMBER,
      x_max_capacity    OUT NOCOPY      NUMBER,
      x_capacity_uom    OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

   FUNCTION get_activity_id (
      p_batch_id       IN   NUMBER,
      p_batchstep_no   IN   NUMBER,
      p_activity       IN   VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION is_table_migrated (p_table_name IN VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE set_table_migrated (
      p_table_name      IN       VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE renumber_duplicate_line_no;

   PROCEDURE renumber_blank_line_no;

   FUNCTION is_GME_validated RETURN BOOLEAN;

   PROCEDURE set_GME_validated;

   PROCEDURE reset_GME_validated;

   PROCEDURE unlock_all;

   PROCEDURE del_step_dtl_for_del_steps;

   PROCEDURE tablespace_check(
      p_User         IN VARCHAR2,
      p_pct_free     IN NUMBER
   );

   PROCEDURE report_step_item_orphans;

   PROCEDURE report_step_dep_orphans;

   FUNCTION GME_data_exists RETURN BOOLEAN;

END migrate_batch;

 

/
