--------------------------------------------------------
--  DDL for Package GME_COMPLETE_BATCH_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_COMPLETE_BATCH_STEP_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVCMSS.pls 120.4.12010000.1 2008/07/25 10:29:54 appldev ship $ */

  PROCEDURE complete_step
    (p_batch_step_rec            IN GME_BATCH_STEPS%ROWTYPE
    ,p_batch_header_rec          IN gme_batch_header%ROWTYPE
    ,x_batch_step_rec            OUT NOCOPY GME_BATCH_STEPS%ROWTYPE
    ,x_exception_material_tbl    IN OUT NOCOPY gme_common_pvt.exceptions_tab
    ,x_return_status             OUT NOCOPY VARCHAR2);

  PROCEDURE complete_step_recursive
    (p_batch_step_rec             IN       gme_batch_steps%ROWTYPE
    ,p_batch_header_rec           IN       gme_batch_header%ROWTYPE
    ,x_batch_step_rec             OUT NOCOPY      gme_batch_steps%ROWTYPE
    ,x_exception_material_tbl     IN  OUT NOCOPY gme_common_pvt.exceptions_tab
    ,x_return_status              OUT NOCOPY      VARCHAR2
    , p_quality_override     IN  BOOLEAN := FALSE); --Bug#6348353

  PROCEDURE complete_step_line
    (p_batch_step_rec            IN              gme_batch_steps%ROWTYPE
    ,x_batch_step_rec            OUT NOCOPY      gme_batch_steps%ROWTYPE
    ,x_exception_material_tbl    IN  OUT NOCOPY  gme_common_pvt.exceptions_tab
    ,x_return_status             OUT NOCOPY      VARCHAR2);

  PROCEDURE complete_step_material
              (p_batch_step_rec             IN         gme_batch_steps%ROWTYPE
              ,p_update_inv_ind             IN         VARCHAR2
              ,x_exception_material_tbl     IN  OUT NOCOPY gme_common_pvt.exceptions_tab
              ,x_return_status              OUT NOCOPY VARCHAR2);

  PROCEDURE validate_step_for_complete  (p_batch_header_rec     IN gme_batch_header%ROWTYPE
                                        ,p_batch_step_rec       IN gme_batch_steps%ROWTYPE
                                        ,p_override_quality     IN VARCHAR2
                                        ,x_batch_step_rec       OUT NOCOPY gme_batch_steps%ROWTYPE
                                        ,x_return_status        OUT NOCOPY VARCHAR2);

  PROCEDURE validate_step_cmplt_date
      (p_batch_step_rec       IN  GME_BATCH_STEPS%ROWTYPE
      ,p_batch_header_rec     IN  GME_BATCH_HEADER%ROWTYPE
      ,x_batch_start_date     OUT NOCOPY DATE
      ,x_return_status        OUT NOCOPY VARCHAR2);

  PROCEDURE validate_dependent_steps (p_batch_id           IN NUMBER
                                     ,p_step_id            IN NUMBER
                                     ,p_step_actual_start_date IN DATE
                                     ,x_return_status      OUT NOCOPY VARCHAR2);

END gme_complete_batch_step_pvt;

/
