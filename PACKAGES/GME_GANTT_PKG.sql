--------------------------------------------------------
--  DDL for Package GME_GANTT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_GANTT_PKG" AUTHID CURRENT_USER AS
/* $Header: GMEGNTS.pls 120.3 2006/04/06 06:55:55 svgonugu noship $  */

   /***********************************************************/
   /* Oracle Process Manufacturing Process Execution APIs     */
   /*                                                         */
   /* File Name: GMEGNTS.pls                                  */
   /* Contents:  Package specification of Gantt chart routines*/
   /* HISTORY                                                 */
   /* SivakumarG 05-APR-2006 Bug#4867640                      */
   /*  Added p_to_batch_no parameter to init_session procedure*/
   /***********************************************************/

   g_null_date   VARCHAR2 (14) := '19700101010000';

   TYPE gantttableofoperation IS TABLE OF VARCHAR2 (32000)
      INDEX BY BINARY_INTEGER;

   TYPE gantttableofactivity IS TABLE OF VARCHAR2 (32000)
      INDEX BY BINARY_INTEGER;

   TYPE gantttableofresource IS TABLE OF VARCHAR2 (32000)
      INDEX BY BINARY_INTEGER;

   TYPE gantttableofbatch IS TABLE OF VARCHAR2 (32000)
      INDEX BY BINARY_INTEGER;

   TYPE shopcalendartabletype IS TABLE OF VARCHAR2 (32000)
      INDEX BY BINARY_INTEGER;

   TYPE shifttabletype IS TABLE OF VARCHAR2 (32000)
      INDEX BY BINARY_INTEGER;

   PROCEDURE init_session (
      p_organization_id    IN   NUMBER
     ,p_org_code           IN   VARCHAR2
     ,p_batch_no           IN   VARCHAR2
     ,p_to_batch_no        IN   VARCHAR2 --Bug#5032359
     ,p_from_date          IN   DATE
     ,p_to_date            IN   DATE
     ,p_resource           IN   VARCHAR2
     ,p_product_no         IN   VARCHAR2
     ,p_ingredient_no      IN   VARCHAR2
     ,p_prim_rsrc_ind      IN   INTEGER
     ,p_sec_rsrc_ind       IN   INTEGER
     ,p_aux_rsrc_ind       IN   INTEGER
     ,p_batch_type         IN   INTEGER
     ,p_fpo_type           IN   INTEGER
     ,p_released_status    IN   INTEGER
     ,p_pending_status     IN   INTEGER
     ,p_certified_status   IN   INTEGER);

   PROCEDURE get_operations (
      p_batch_id           IN              NUMBER
     ,p_resource           IN              VARCHAR2
     ,p_prim_rsrc_ind      IN              NUMBER
     ,p_sec_rsrc_ind       IN              NUMBER
     ,p_aux_rsrc_ind       IN              NUMBER
     ,x_nb_operation       OUT NOCOPY      NUMBER
     ,x_operations_table   OUT NOCOPY      gantttableofoperation);

   PROCEDURE get_activities (
      p_batch_id         IN              NUMBER
     ,p_batchstep_no     IN              NUMBER
     ,p_resource         IN              VARCHAR2
     ,p_prim_rsrc_ind    IN              NUMBER
     ,p_sec_rsrc_ind     IN              NUMBER
     ,p_aux_rsrc_ind     IN              NUMBER
     ,x_nb_activity      OUT NOCOPY      NUMBER
     ,x_activity_table   OUT NOCOPY      gantttableofactivity);

   PROCEDURE get_resources (
      p_batch_id         IN              NUMBER
     ,p_batchstep_no     IN              NUMBER
     ,p_activity         IN              VARCHAR2
     ,p_resource         IN              VARCHAR2
     ,p_prim_rsrc_ind    IN              NUMBER
     ,p_sec_rsrc_ind     IN              NUMBER
     ,p_aux_rsrc_ind     IN              NUMBER
     ,x_nb_resource      OUT NOCOPY      NUMBER
     ,x_resource_table   OUT NOCOPY      gantttableofresource);

   PROCEDURE get_batch_properties (
      p_batch_id               IN              NUMBER
     ,x_batch_properties_str   OUT NOCOPY      VARCHAR2);

   PROCEDURE close_cursors;

   PROCEDURE get_next_batch_set (
      x_nb_batches             OUT NOCOPY   NUMBER
     ,x_start_of_first_batch   OUT NOCOPY   DATE
     ,x_batch_table            OUT NOCOPY   gantttableofbatch);

/*======================================================================
 # Retrieve Shop calendar assigned to the given organization
 #======================================================================*/
   PROCEDURE fetch_shop_calendar (
      p_organization_id     IN              NUMBER
     ,p_date                IN              DATE
     ,x_calendar_no         OUT NOCOPY      VARCHAR2
     ,x_calendar_desc       OUT NOCOPY      VARCHAR2
     ,x_calendar_start      OUT NOCOPY      VARCHAR2
     ,x_calendar_end        OUT NOCOPY      VARCHAR2
     ,x_calendar_assigned   OUT NOCOPY      VARCHAR2
     ,x_return_code         OUT NOCOPY      VARCHAR2
     ,x_error_msg           OUT NOCOPY      VARCHAR2);

/*======================================================================
 # Retrieve working and non working days for a given date range
 #======================================================================*/
   PROCEDURE fetch_work_non_work_days (
      p_organization_id     IN              NUMBER
     ,p_from_date           IN              DATE
     ,p_to_date             IN              DATE
     ,x_calendar_no         OUT NOCOPY      VARCHAR2
     ,x_calendar_desc       OUT NOCOPY      VARCHAR2
     ,x_calendar_start      OUT NOCOPY      VARCHAR2
     ,x_calendar_end        OUT NOCOPY      VARCHAR2
     ,x_rec_count           OUT NOCOPY      NUMBER
     ,x_shop_cal_tbl        OUT NOCOPY      shopcalendartabletype
     ,x_calendar_assigned   OUT NOCOPY      VARCHAR2
     ,x_return_code         OUT NOCOPY      VARCHAR2
     ,x_error_msg           OUT NOCOPY      VARCHAR2);

/*======================================================================
 # Check whether batch/FPO/Step can be re-scheduled based on shop calendar.
 # Returns:
 #       S : Batch/Step can be rescheduled
 #       C : Prompt the user to reschedule without using shop calendar
 #       P : Prompt the user to reschedule ignoring contiguity constraints
 #       F : Batch/Step cannot be reschedule
 #======================================================================*/
   PROCEDURE validate_reschedule_event (
      p_batch_id          IN              NUMBER
     ,p_organization_id   IN              NUMBER
     ,p_primary_prod_no   IN              VARCHAR2
     ,p_start_date        IN              DATE
     ,p_end_date          IN              DATE
     ,p_entity_type       IN              VARCHAR2
     ,x_return_code       OUT NOCOPY      VARCHAR2
     ,x_error_msg         OUT NOCOPY      VARCHAR2);

   TYPE batchidtab IS TABLE OF gme_batch_header.batch_id%TYPE;

   TYPE batchnotab IS TABLE OF gme_batch_header.batch_no%TYPE;

   TYPE batchstatustab IS TABLE OF gme_batch_header.batch_status%TYPE;

   TYPE batchtypetab IS TABLE OF gme_batch_header.batch_type%TYPE;

   TYPE batchdatetab IS TABLE OF gme_batch_header.plan_start_date%TYPE;

   TYPE batchstepnotab IS TABLE OF gme_batch_steps.batchstep_no%TYPE;

   TYPE batchqtytab IS TABLE OF gme_batch_steps.plan_step_qty%TYPE;

   TYPE batchdesctab IS TABLE OF gmd_operations_b.oprn_desc%TYPE;

   TYPE batchclasstab IS TABLE OF gmd_operation_class_b.oprn_class%TYPE;

   TYPE batchumtab IS TABLE OF gmd_operations_b.process_qty_um%TYPE;

   TYPE batchverstab IS TABLE OF gmd_operations_b.oprn_vers%TYPE;

   TYPE activitycodetab IS TABLE OF gmd_activities_b.activity%TYPE;

   TYPE costancodetab IS TABLE OF gmd_activities_b.cost_analysis_code%TYPE;

   TYPE batchresourcestab IS TABLE OF cr_rsrc_mst.resources%TYPE;

   TYPE batchintindtab IS TABLE OF gme_batch_step_resources.prim_rsrc_ind%TYPE;

   TYPE itemnotab IS TABLE OF mtl_system_items_kfv.concatenated_segments%TYPE;

--   TYPE calendar_date IS TABLE OF mr_shcl_dtl.calendar_date%TYPE;

/*======================================================================
 # For timezone changes.
 # Returns:
 #       date : date in the client timezone
 # HISTORY
 #       Bharati Satpute   Bug3315440   21-JAN-2004
 #======================================================================*/
   FUNCTION date_to_clientdt (dateval DATE)
      RETURN DATE;
END;

 

/
