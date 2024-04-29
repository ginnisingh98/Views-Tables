--------------------------------------------------------
--  DDL for Package GME_RELEASE_BATCH_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_RELEASE_BATCH_STEP_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVRLSS.pls 120.5 2005/07/18 21:06:58 anewbury ship $ */
   PROCEDURE release_step (
      p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_batch_step_rec           OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_exception_material_tbl   IN OUT NOCOPY   gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   PROCEDURE release_step_recursive (
      p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_batch_step_rec           OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_exception_material_tbl   IN OUT NOCOPY   gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   PROCEDURE process_dependent_steps (
      p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_exception_material_tbl   IN OUT NOCOPY   gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   PROCEDURE release_step_line (
      p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,x_batch_step_rec           OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_exception_material_tbl   IN OUT NOCOPY   gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   PROCEDURE release_step_ingredients (
      p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_update_inv_ind           IN              VARCHAR2
     ,x_exception_material_tbl   IN OUT NOCOPY   gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   PROCEDURE validate_step_for_release  (p_batch_header_rec     IN gme_batch_header%ROWTYPE
                                        ,p_batch_step_rec       IN gme_batch_steps%ROWTYPE
                                        ,x_batch_step_rec       OUT NOCOPY gme_batch_steps%ROWTYPE
                                        ,x_return_status        OUT NOCOPY VARCHAR2);

END gme_release_batch_step_pvt;

 

/
