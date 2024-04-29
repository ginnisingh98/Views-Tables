--------------------------------------------------------
--  DDL for Package GMP_WPS_WRITER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_WPS_WRITER" AUTHID CURRENT_USER AS
/* $Header: GMPWPSWS.pls 120.1 2005/08/17 13:59:56 rpatangy noship $ */

TYPE NUMBER_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
/*  Global value variables */

/* Variables for document types */
  v_doc_prod      VARCHAR2(4) := 'PROD';


/* Procedure to update the batch header after the WPS scheduler has completed */
PROCEDURE update_batch_header(
  pbatch_id      IN  NUMBER,
  pstart_date    IN  NUMBER,
  pend_date      IN  NUMBER,
  plast_update   IN  NUMBER,
  phorizon       IN  NUMBER,
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER);

/* Procedure to update the batch steps after the WPS scheduler has completed */
PROCEDURE update_batch_steps(
  pbatch_id      IN  NUMBER,
  pstep_no       IN  NUMBER_TBL_TYPE,
  pstep_id       IN  NUMBER_TBL_TYPE,
  pstart_date    IN  NUMBER_TBL_TYPE,
  pend_date      IN  NUMBER_TBL_TYPE,
  plast_update   IN  NUMBER_TBL_TYPE,
  phorizon       IN  NUMBER,
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  pnum_rows      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER);

/* Procedure to update the batch step activities after the WPS scheduler has
   completed */
PROCEDURE update_batch_activities(
  pbatch_id      IN  NUMBER,
  pstep_id       IN  NUMBER,
  pactivity_id   IN  NUMBER,
  pstart_date    IN  NUMBER,
  pend_date      IN  NUMBER,
  plast_update   IN  NUMBER,
  phorizon       IN  NUMBER,
  puom_hour      IN  VARCHAR2,
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER);

/* Procedure to update the batch step resources after the WPS scheduler has
   completed */
PROCEDURE update_batch_resources(
  pbatch_id      IN  NUMBER,
  pstep_id       IN  NUMBER_TBL_TYPE,
  pact_res_id    IN  NUMBER_TBL_TYPE,
  pres_usage     IN  NUMBER_TBL_TYPE,
  presource_id   IN  NUMBER_TBL_TYPE,
  psetup_id      IN  NUMBER_TBL_TYPE,
  pstart_date    IN  NUMBER_TBL_TYPE,
  pend_date      IN  NUMBER_TBL_TYPE,
  plast_update   IN  NUMBER_TBL_TYPE,
  pseq_dep_usage IN  NUMBER_TBL_TYPE,
  phorizon       IN  NUMBER,
  puom_hour      IN  VARCHAR2,
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  pres_rows      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER,
  pnew_act_res   IN OUT NOCOPY NUMBER_TBL_TYPE);

/* Procedure to update the batch resource transactions after the WPS scheduler
   has completed */
PROCEDURE update_resource_transactions(
  pbatch_id      IN  NUMBER,
  pact_res_id    IN  NUMBER_TBL_TYPE,
  presource_id   IN  NUMBER_TBL_TYPE,
  pinstance_id   IN  NUMBER_TBL_TYPE,
  prsrc_count    IN  NUMBER_TBL_TYPE,
  pseq_dep_ind   IN  NUMBER_TBL_TYPE,
  pstart_date    IN  NUMBER_TBL_TYPE,
  pend_date      IN  NUMBER_TBL_TYPE,
  phorizon       IN  NUMBER,
  puom_hour      IN  VARCHAR2,
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  pres_rows      IN  NUMBER,
  ptrn_rows      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER,
  porig_act_res  IN  NUMBER_TBL_TYPE,
  pnew_act_res   IN  NUMBER_TBL_TYPE);

/* Procedure to update the batch resource instances transactions after the
   WPS scheduler has completed */
PROCEDURE update_operation_resources(
  pbatch_id       IN  NUMBER,
  pactivity_id    IN  NUMBER,
  pact_start_date IN  NUMBER,
  pact_end_date   IN  NUMBER,
  pact_last_update IN  NUMBER,
  pstep_id        IN  NUMBER_TBL_TYPE,
  pact_res_id     IN  NUMBER_TBL_TYPE,
  presource_id    IN  NUMBER_TBL_TYPE,
  presource_usage IN  NUMBER_TBL_TYPE,
  psetup_id       IN  NUMBER_TBL_TYPE,
  pres_start_date IN  NUMBER_TBL_TYPE,
  pres_end_date   IN  NUMBER_TBL_TYPE,
  plast_update    IN  NUMBER_TBL_TYPE,
  pseq_dep_usage  IN  NUMBER_TBL_TYPE,
  ptrn_act_res_id IN  NUMBER_TBL_TYPE,
  ptrn_resource_id IN  NUMBER_TBL_TYPE,
  ptrn_rsrc_count IN  NUMBER_TBL_TYPE,
  ptrn_seq_dep    IN  NUMBER_TBL_TYPE,
  ptrn_start_date IN  NUMBER_TBL_TYPE,
  ptrn_end_date   IN  NUMBER_TBL_TYPE,
  ptrn_instance_id IN  NUMBER_TBL_TYPE,
  phorizon        IN  NUMBER,
  puom_hour       IN  VARCHAR2,
  puser_id        IN  NUMBER,
  plogin_id       IN  NUMBER,
  pres_rows      IN  NUMBER,
  ptrn_rows      IN  NUMBER,
  return_status   OUT NOCOPY NUMBER);

/* Procedure to lock the batch header and details after the WPS scheduler
   has completed */
PROCEDURE lock_batch_details(
  pbatch_id      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER);

PROCEDURE log_message(
  pbuff          IN VARCHAR2);

FUNCTION get_wps_atr(
      p_organization_id              IN              NUMBER
     ,p_inventory_item_id            IN              NUMBER ) RETURN NUMBER ;

FUNCTION get_wps_onhand(
      p_organization_id              IN              NUMBER
     ,p_inventory_item_id            IN              NUMBER ) RETURN NUMBER ;

END gmp_wps_writer;

 

/
