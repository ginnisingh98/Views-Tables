--------------------------------------------------------
--  DDL for Package GMP_BATCH_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_BATCH_WRAPPER_PKG" AUTHID CURRENT_USER AS
/* $Header: GMPBTWRS.pls 120.2 2005/09/02 01:31:09 nsinghi noship $ */

   SUBTYPE exceptions_tab IS gme_common_pvt.exceptions_tab;

   PROCEDURE create_batch(
      p_api_version              IN              NUMBER := 2.0
     ,p_validation_level         IN              NUMBER := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_org_code                 IN              VARCHAR2 := NULL
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,p_batch_size               IN              NUMBER := NULL
     ,p_batch_size_uom           IN              VARCHAR2 := NULL
     ,p_creation_mode            IN              VARCHAR2
     ,p_recipe_id                IN              NUMBER := NULL
     ,p_recipe_no                IN              VARCHAR2 := NULL
     ,p_recipe_version           IN              NUMBER := NULL
     ,p_product_no               IN              VARCHAR2 := NULL
     ,p_item_revision            IN              VARCHAR2 := NULL
     ,p_product_id               IN              NUMBER := NULL
     ,p_ignore_qty_below_cap     IN              VARCHAR2 := fnd_api.g_true
     ,p_use_workday_cal          IN              VARCHAR2 := fnd_api.g_true
     ,p_contiguity_override      IN              VARCHAR2 := fnd_api.g_true
     ,p_use_least_cost_validity_rule     IN              VARCHAR2 := fnd_api.g_false
--     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,x_exception_material_tbl   OUT NOCOPY      exceptions_tab
   );

END GMP_BATCH_WRAPPER_PKG;

 

/
