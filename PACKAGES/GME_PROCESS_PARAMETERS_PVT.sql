--------------------------------------------------------
--  DDL for Package GME_PROCESS_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_PROCESS_PARAMETERS_PVT" AUTHID CURRENT_USER AS
   /* $Header: GMEVPPRS.pls 120.1 2005/06/03 13:48:25 appldev  $ */
   PROCEDURE insert_process_parameter (
      p_batch_no              IN              VARCHAR2 := NULL
     ,p_org_code              IN              VARCHAR2 := NULL
     ,p_validate_flexfields   IN              VARCHAR2 := fnd_api.g_false
     ,p_batchstep_no          IN              NUMBER := NULL
     ,p_activity              IN              VARCHAR2 := NULL
     ,p_parameter             IN              VARCHAR2 := NULL
     ,p_process_param_rec     IN              gme_process_parameters%ROWTYPE
     ,x_process_param_rec     OUT NOCOPY      gme_process_parameters%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2);

   PROCEDURE update_process_parameter (
      p_batch_no              IN              VARCHAR2 := NULL
     ,p_org_code              IN              VARCHAR2 := NULL
     ,p_validate_flexfields   IN              VARCHAR2 := fnd_api.g_false
     ,p_batchstep_no          IN              NUMBER := NULL
     ,p_activity              IN              VARCHAR2 := NULL
     ,p_parameter             IN              VARCHAR2 := NULL
     ,p_process_param_rec     IN              gme_process_parameters%ROWTYPE
     ,x_process_param_rec     OUT NOCOPY      gme_process_parameters%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2);

   PROCEDURE delete_process_parameter (
      p_batch_no            IN              VARCHAR2 := NULL
     ,p_org_code            IN              VARCHAR2 := NULL
     ,p_batchstep_no        IN              NUMBER := NULL
     ,p_activity            IN              VARCHAR2 := NULL
     ,p_parameter           IN              VARCHAR2 := NULL
     ,p_process_param_rec   IN              gme_process_parameters%ROWTYPE
     ,x_return_status       OUT NOCOPY      VARCHAR2);

   PROCEDURE validate_process_param (
      p_org_code        IN              VARCHAR2 := NULL
     ,p_batch_no        IN              VARCHAR2 := NULL
     ,p_batchstep_no    IN              NUMBER := NULL
     ,p_activity        IN              VARCHAR2 := NULL
     ,p_resource        IN              VARCHAR2 := NULL
     ,p_parameter       IN              VARCHAR2 := NULL
     ,x_batch_id        OUT NOCOPY      NUMBER
     ,x_batchstep_id    OUT NOCOPY      NUMBER
     ,x_activity_id     OUT NOCOPY      NUMBER
     ,x_resource_id     OUT NOCOPY      NUMBER
     ,x_parameter_id    OUT NOCOPY      NUMBER
     ,x_proc_param_id   OUT NOCOPY      NUMBER
     ,x_step_status     OUT NOCOPY      NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2);
END gme_process_parameters_pvt;

 

/
