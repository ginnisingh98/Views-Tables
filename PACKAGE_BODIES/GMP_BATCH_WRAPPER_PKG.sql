--------------------------------------------------------
--  DDL for Package Body GMP_BATCH_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_BATCH_WRAPPER_PKG" AS
/* $Header: GMPBTWRB.pls 120.2 2005/09/02 01:31:28 nsinghi noship $ */

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
   ) IS
   BEGIN
              gme_api_pub.create_batch(
                  p_api_version           =>  p_api_version
                  ,p_validation_level      =>  p_validation_level
                  ,p_init_msg_list         => p_init_msg_list
                  ,p_commit                => p_commit
                  ,x_message_count         => x_message_count
                  ,x_message_list          => x_message_list
                  ,x_return_status         => x_return_status
                  ,p_org_code              => p_org_code
                  ,p_batch_header_rec      => p_batch_header_rec
                  ,x_batch_header_rec      => x_batch_header_rec
                  ,p_batch_size            => p_batch_size
                  ,p_batch_size_uom        => p_batch_size_uom
                  ,p_creation_mode         => p_creation_mode
                  ,p_recipe_id             => p_recipe_id
                  ,p_recipe_no             => p_recipe_no
                  ,p_recipe_version        => p_recipe_version
                  ,p_product_no            => p_product_no
                  ,p_item_revision         => p_item_revision
                  ,p_product_id            => p_product_id
                  ,p_ignore_qty_below_cap  => p_ignore_qty_below_cap
                  ,p_use_workday_cal       => p_use_workday_cal
                  ,p_contiguity_override   => p_contiguity_override
                  ,p_use_least_cost_validity_rule => p_use_least_cost_validity_rule
                  ,x_exception_material_tbl => x_exception_material_tbl
                  );

   END create_batch;
END GMP_BATCH_WRAPPER_PKG;

/
