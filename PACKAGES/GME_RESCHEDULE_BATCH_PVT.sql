--------------------------------------------------------
--  DDL for Package GME_RESCHEDULE_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_RESCHEDULE_BATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVRSBS.pls 120.1 2005/06/03 13:49:39 appldev  $ */
   PROCEDURE reschedule_batch (
      p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_use_workday_cal       IN              VARCHAR2
     ,p_contiguity_override   IN              VARCHAR2
     ,x_batch_header_rec      OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2);

   PROCEDURE truncate_date (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_date               IN              NUMBER
     ,p_batchstep_id       IN              gme_batch_steps.batchstep_id%TYPE
            DEFAULT NULL
     ,x_return_status      OUT NOCOPY      VARCHAR2);
END gme_reschedule_batch_pvt;

 

/
