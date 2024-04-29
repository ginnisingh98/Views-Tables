--------------------------------------------------------
--  DDL for Package GME_UNRELEASE_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_UNRELEASE_STEP_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVURSS.pls 120.2 2005/07/11 06:41:25 anewbury noship $ */
   PROCEDURE unrelease_step (
      p_batch_step_rec          IN              gme_batch_steps%ROWTYPE
     ,p_update_inventory_ind    IN              VARCHAR2
     ,p_create_resv_pend_lots   IN              NUMBER
     ,p_from_unrelease_batch    IN              NUMBER
     ,x_batch_step_rec          OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status           OUT NOCOPY      VARCHAR2);

   PROCEDURE validate_step_for_unrelease
               (p_batch_hdr_rec        IN gme_batch_header%ROWTYPE
               ,p_batch_step_rec       IN gme_batch_steps%ROWTYPE
               ,x_return_status        OUT NOCOPY VARCHAR2);

END gme_unrelease_step_pvt;

 

/
