--------------------------------------------------------
--  DDL for Package GME_INSERT_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_INSERT_STEP_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVINSS.pls 120.2 2006/06/14 14:52:13 svgonugu noship $ */
   PROCEDURE insert_batch_step (
      p_gme_batch_header   IN              gme_batch_header%ROWTYPE
     ,p_gme_batch_step     IN              gme_batch_steps%ROWTYPE
     ,x_gme_batch_step     OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   PROCEDURE calc_max_capacity (
      p_recipe_rout_resc   IN              gmd_recipe_fetch_pub.oprn_resc_tbl
                                -- resources that we want the max_capacity of
     ,p_max_capacity       OUT NOCOPY      gme_batch_steps.max_step_capacity%TYPE
     ,p_capacity_uom       OUT NOCOPY      gme_batch_steps.max_step_capacity_um%TYPE
     ,x_resource           OUT NOCOPY      gme_batch_step_resources.resources%TYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_step_qty_uom       IN              VARCHAR2 DEFAULT NULL); --Bug#5231180

END gme_insert_step_pvt;

 

/
