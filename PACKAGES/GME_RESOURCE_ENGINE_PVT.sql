--------------------------------------------------------
--  DDL for Package GME_RESOURCE_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_RESOURCE_ENGINE_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVRXNS.pls 120.4.12000000.2 2007/01/26 23:06:46 snene ship $
 *****************************************************************
 *                                                               *
 * Package  GME_RESOURCE_ENGINE_PVT                              *
 *                                                               *
 * Contents CREATE_RESOURCE_TRANS                                *
 *          UPDATE_RESOURCE_TRANS                                *
 *          DELETE_RESOURCE_TRANS                                *
 *          FETCH_ALL_RESOURCES                                  *
 *          BUILD_RESOURCE_TRAN               *
 *     FETCH_ACTIVE_RESOURCES           *
 *                                                               *
 * Use      This is the private layer of the GME Resource        *
 *          Transaction Processor.                               *
 *                                                               *
 * History                                                       *
 ****************************************************************
*/
   PROCEDURE fetch_all_resources (
      p_resource_rec    IN              gme_resource_txns_gtmp%ROWTYPE
     ,x_resource_tbl    OUT NOCOPY      gme_common_pvt.resource_transactions_tab
     ,x_return_status   OUT NOCOPY      VARCHAR2
     ,p_active_trans    IN              NUMBER DEFAULT 0);

   PROCEDURE create_resource_trans (
      p_tran_rec        IN              gme_resource_txns_gtmp%ROWTYPE
     ,x_tran_rec        OUT NOCOPY      gme_resource_txns_gtmp%ROWTYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE delete_resource_trans (
      p_tran_rec        IN              gme_resource_txns_gtmp%ROWTYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE update_resource_trans (
      p_tran_rec        IN              gme_resource_txns_gtmp%ROWTYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE consolidate_batch_resources (
      p_batch_id        IN              NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE build_resource_tran (
      p_tmp_rec        IN              gme_resource_txns_gtmp%ROWTYPE
     ,p_resource_rec   OUT NOCOPY      gme_resource_txns%ROWTYPE);

   PROCEDURE fetch_active_resources (
      p_resource_rec    IN              gme_resource_txns_gtmp%ROWTYPE
     ,p_calling_mode    IN              VARCHAR2 DEFAULT NULL --bug#5609683
     ,x_resource_tbl    OUT NOCOPY      gme_common_pvt.resource_transactions_tab
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE resource_dtl_process (
      p_step_resources_rec   IN              gme_batch_step_resources%ROWTYPE
     ,p_action_code          IN              VARCHAR2
     ,p_check_prim_rsrc      IN              BOOLEAN := FALSE
     ,x_step_resources_rec   OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_return_status        OUT NOCOPY      VARCHAR2);

   PROCEDURE validate_resource (
      p_batch_step_rec       IN              gme_batch_steps%ROWTYPE
     ,p_step_activity_rec    IN              gme_batch_step_activities%ROWTYPE
     ,p_step_resources_rec   IN              gme_batch_step_resources%ROWTYPE
     ,p_check_prim_rsrc      IN              BOOLEAN := FALSE
     ,x_return_status        OUT NOCOPY      VARCHAR2);

   PROCEDURE get_resource_usage (
      p_step_resources_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_step_resources_rec   OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_return_status        OUT NOCOPY      VARCHAR2);

   PROCEDURE check_primary_resource (
      p_step_resources_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_return_status        OUT NOCOPY      VARCHAR2);

   PROCEDURE check_primary_resource (
      p_batch_id        IN              NUMBER
     ,p_batchstep_id    IN              NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE validate_rsrc_txn_param (
      p_called_from         IN              NUMBER
     ,p_batchstep_rsrc_id   IN              NUMBER
     ,p_org_code            IN              VARCHAR2
     ,p_batch_no            IN              VARCHAR2 := NULL
     ,p_batchstep_no        IN              NUMBER := NULL
     ,p_activity            IN              VARCHAR2 := NULL
     ,p_resource            IN              VARCHAR2 := NULL
     ,p_trans_date          IN              DATE
     ,p_start_date          IN              DATE
     ,p_end_date            IN              DATE
     ,p_usage               IN              NUMBER
     ,p_reason_name         IN              VARCHAR2
     ,p_reason_id           IN              NUMBER
     ,p_instance_id         IN              NUMBER
     ,p_instance_no         IN              NUMBER
     ,x_line_id             OUT NOCOPY      NUMBER
     ,x_step_status         OUT NOCOPY      NUMBER
     ,x_batch_header_rec    OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_instance_id         OUT NOCOPY      NUMBER
     ,x_reason_id           OUT NOCOPY      NUMBER
     ,x_return_status       OUT NOCOPY      VARCHAR2
--Rishi Varma 02-09-2004 B3856541
/*Added the new parameter to the procedure*/
   ,  x_trans_date          OUT NOCOPY      DATE);

/*
PROCEDURE  update_actual_resource_usagep
( p_batchstep_rsrc_id   IN NUMBER
, p_plant_code         IN  VARCHAR2 := NULL
, p_batch_no           IN  VARCHAR2 := NULL
, p_batchstep_no        IN      NUMBER := NULL
, p_activity      IN VARCHAR2 := NULL
, p_resource      IN VARCHAR2 := NULL
, p_trans_date         IN  DATE
, p_start_date         IN  DATE
, p_end_date      IN DATE
, p_usage           IN  NUMBER
, p_reason_code           IN  VARCHAR2
, p_instance_id      IN NUMBER
, p_instance_no      IN NUMBER
, x_batch_id            OUT NOCOPY     NUMBER
, x_line_id             OUT NOCOPY     NUMBER
, x_return_status OUT NOCOPY  VARCHAR2);
*/
   PROCEDURE update_actual_resource_usage (
      /* start ,Punit Kumar
      p_batchstep_rsrc_id     IN      NUMBER   ,
      p_plant_code            IN      VARCHAR2 := NULL,
      */
      p_org_code        IN              VARCHAR2
     ,        /*, inventory organization under which the batch was created.*/
/*end*/
      p_batch_no        IN              VARCHAR2 := NULL
     ,p_batchstep_no    IN              NUMBER := NULL
     ,p_activity        IN              VARCHAR2 := NULL
     ,p_resource        IN              VARCHAR2 := NULL
     ,
      /* start ,Punit Kumar
      p_trans_date            IN      DATE,
      p_start_date            IN      DATE,
      p_end_date              IN      DATE,
      p_usage                 IN      NUMBER,
      p_reason_code           IN      VARCHAR2,
      p_instance_id           IN      NUMBER ,
      */
      p_reason_name     IN              VARCHAR2,
      p_instance_no     IN              NUMBER
     ,
      /*
      x_batch_id              OUT NOCOPY     NUMBER,
      x_line_id               OUT NOCOPY     NUMBER,
      */
      p_rsrc_txn_rec    IN              gme_resource_txns%ROWTYPE
     ,x_rsrc_txn_rec    IN OUT NOCOPY   gme_resource_txns%ROWTYPE
     ,
      /*end*/
      x_return_status   OUT NOCOPY      VARCHAR2);

/*
PROCEDURE  insert_incr_actual_rsrc_txnp
( p_batchstep_rsrc_id   IN NUMBER
, p_plant_code         IN  VARCHAR2 := NULL
, p_batch_no           IN  VARCHAR2 := NULL
, p_batchstep_no        IN      NUMBER := NULL
, p_activity      IN VARCHAR2 := NULL
, p_resource      IN VARCHAR2 := NULL
, p_trans_date         IN  DATE
, p_start_date         IN  DATE
, p_end_date      IN DATE
, p_usage           IN  NUMBER
, p_reason_code           IN  VARCHAR2
, p_instance_id      IN NUMBER
, p_instance_no      IN NUMBER
, x_batch_id            OUT NOCOPY     NUMBER
, x_poc_trans_id        OUT NOCOPY     NUMBER
, x_return_status       OUT NOCOPY  VARCHAR2);
*/
   PROCEDURE insert_incr_actual_rsrc_txn (
       /* start ,Punit Kumar
       p_batchstep_rsrc_id     IN      NUMBER   ,
      p_plant_code            IN      VARCHAR2 := NULL,
       */
      p_org_code        IN              VARCHAR2
     ,          /*inventory organization under which the batch was created.*/
/* end */
      p_batch_no        IN              VARCHAR2 := NULL
     ,p_batchstep_no    IN              NUMBER := NULL
     ,p_activity        IN              VARCHAR2 := NULL
     ,p_resource        IN              VARCHAR2 := NULL
     ,
      /* start , Punit Kumar
      p_trans_date            IN      DATE,
      p_start_date            IN      DATE,
      p_end_date              IN      DATE,
      p_usage                 IN      NUMBER,
      p_reason_code           IN      VARCHAR2,
      p_instance_id           IN      NUMBER ,
      */
      p_reason_name     IN              VARCHAR2,
      p_instance_no     IN              NUMBER
     ,
      /*
      x_batch_id              OUT NOCOPY     NUMBER,
      x_poc_trans_id          OUT NOCOPY     NUMBER,
      */
      p_rsrc_txn_rec    IN              gme_resource_txns%ROWTYPE
     ,x_rsrc_txn_rec    IN OUT NOCOPY   gme_resource_txns%ROWTYPE
     ,
      /*end*/
      x_return_status   OUT NOCOPY      VARCHAR2);

/*
PROCEDURE  insert_timed_actual_rsrc_txnp
( p_batchstep_rsrc_id   IN NUMBER
, p_plant_code         IN  VARCHAR2 := NULL
, p_batch_no           IN  VARCHAR2 := NULL
, p_batchstep_no        IN      NUMBER := NULL
, p_activity      IN VARCHAR2 := NULL
, p_resource      IN VARCHAR2 := NULL
, p_trans_date         IN  DATE
, p_start_date         IN  DATE
, p_end_date      IN DATE
, p_reason_code           IN  VARCHAR2
, p_instance_id      IN NUMBER
, p_instance_no      IN NUMBER
, x_batch_id            OUT NOCOPY     NUMBER
, x_poc_trans_id        OUT NOCOPY     NUMBER
, x_return_status       OUT NOCOPY  VARCHAR2);
*/
   PROCEDURE insert_timed_actual_rsrc_txn (
      /* start ,Punit Kumar
      p_batchstep_rsrc_id     IN      NUMBER   ,
      p_plant_code            IN      VARCHAR2 := NULL,
      */
      p_org_code        IN              VARCHAR2
     ,         /* inventory organization under which the batch was created.*/
/* end */
      p_batch_no        IN              VARCHAR2 := NULL
     ,p_batchstep_no    IN              NUMBER := NULL
     ,p_activity        IN              VARCHAR2 := NULL
     ,p_resource        IN              VARCHAR2 := NULL
     ,
      /* start, Punit Kumar
      p_trans_date            IN      DATE,
      p_start_date            IN      DATE,
      p_end_date              IN      DATE,
      p_reason_code           IN      VARCHAR2,
      p_instance_id           IN      NUMBER ,
      */
      p_reason_name     IN              VARCHAR2,
      p_instance_no     IN              NUMBER
     ,
      /*
      x_batch_id              OUT NOCOPY     NUMBER,
      x_poc_trans_id          OUT NOCOPY     NUMBER,
      */
      p_rsrc_txn_rec    IN              gme_resource_txns%ROWTYPE
     ,x_rsrc_txn_rec    IN OUT NOCOPY   gme_resource_txns%ROWTYPE
     ,
      /*end*/
      x_return_status   OUT NOCOPY      VARCHAR2);

/*
PROCEDURE  start_cmplt_actual_rsrc_txnp
( p_batchstep_rsrc_id   IN NUMBER
, p_plant_code         IN  VARCHAR2 := NULL
, p_batch_no           IN  VARCHAR2 := NULL
, p_batchstep_no  IN      NUMBER := NULL
, p_activity      IN VARCHAR2 := NULL
, p_resource      IN VARCHAR2 := NULL
, p_trans_date         IN  DATE
, p_start_date         IN  DATE
, p_reason_code           IN  VARCHAR2
, p_instance_id      IN NUMBER
, p_instance_no      IN NUMBER
, x_batch_id            OUT NOCOPY     NUMBER
, x_poc_trans_id        OUT NOCOPY     NUMBER
, x_return_status OUT NOCOPY  VARCHAR2);
*/
   PROCEDURE start_cmplt_actual_rsrc_txn (
      /* start , Punit Kumar
      p_batchstep_rsrc_id     IN      NUMBER   ,
      p_plant_code            IN      VARCHAR2 := NULL,
      */
      p_org_code        IN              VARCHAR2
     ,          /*inventory organization under which the batch was created */
/* end */
      p_batch_no        IN              VARCHAR2 := NULL
     ,p_batchstep_no    IN              NUMBER := NULL
     ,p_activity        IN              VARCHAR2 := NULL
     ,p_resource        IN              VARCHAR2 := NULL
     ,
      /* start , Punit Kumar
      p_trans_date            IN      DATE,
      p_start_date            IN      DATE,
      p_reason_code           IN      VARCHAR2,
      p_instance_id           IN      NUMBER ,
      */
      p_reason_name     IN              VARCHAR2,
      p_instance_no     IN              NUMBER
     ,
      /*
      x_batch_id              OUT NOCOPY     NUMBER,
      x_poc_trans_id          OUT NOCOPY     NUMBER,
      */
      p_rsrc_txn_rec    IN              gme_resource_txns%ROWTYPE
     ,x_rsrc_txn_rec    IN OUT NOCOPY   gme_resource_txns%ROWTYPE
     ,
      /*end */
      x_return_status   OUT NOCOPY      VARCHAR2);

/*
PROCEDURE  end_cmplt_actual_rsrc_txnp
( p_poc_trans_id  IN NUMBER
, p_trans_date         IN  DATE
, p_end_date      IN DATE
, p_reason_code           IN  VARCHAR2
, p_instance_id      IN NUMBER
, p_instance_no      IN NUMBER
, x_poc_trans_id     OUT NOCOPY NUMBER --BUG#3479669 RAGHU
, x_batch_id            OUT NOCOPY     NUMBER
, x_return_status OUT NOCOPY  VARCHAR2);
*/
   PROCEDURE end_cmplt_actual_rsrc_txn (
      p_rsrc_txn_rec    IN              gme_resource_txns%ROWTYPE
      ,p_reason_name     IN              VARCHAR2
      ,p_instance_no     IN              NUMBER
      ,x_rsrc_txn_rec    IN OUT NOCOPY   gme_resource_txns%ROWTYPE
      ,x_return_status   OUT NOCOPY      VARCHAR2);
END gme_resource_engine_pvt;

 

/
