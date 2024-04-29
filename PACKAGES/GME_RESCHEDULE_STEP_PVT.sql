--------------------------------------------------------
--  DDL for Package GME_RESCHEDULE_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_RESCHEDULE_STEP_PVT" AUTHID CURRENT_USER AS
   /* $Header: GMEVRSSS.pls 120.1 2005/06/03 13:50:16 appldev  $ */
   TYPE step_tab IS TABLE OF gme_batch_steps.batchstep_id%TYPE
      INDEX BY BINARY_INTEGER;

   PROCEDURE reschedule_step (
      p_batch_step_rec          IN              gme_batch_steps%ROWTYPE
     ,p_source_step_id_tbl      IN              step_tab
     ,p_contiguity_override     IN              VARCHAR2 := 'F'
     ,p_reschedule_preceding    IN              VARCHAR2 := 'F'
     ,p_reschedule_succeeding   IN              VARCHAR2 := 'T'
     ,p_use_workday_cal         IN              VARCHAR2 := 'F'
     ,x_batch_step_rec          OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status           OUT NOCOPY      VARCHAR2);

   PROCEDURE save_all_data (
      p_batch_step_rec        IN              gme_batch_steps%ROWTYPE
     ,p_use_workday_cal       IN              VARCHAR2 := 'F'
     ,p_contiguity_override   IN              VARCHAR2 := 'F'
     ,p_start_date            IN              DATE
     ,p_end_date              IN              DATE
     ,x_return_status         OUT NOCOPY      VARCHAR2);
END gme_reschedule_step_pvt;

 

/
