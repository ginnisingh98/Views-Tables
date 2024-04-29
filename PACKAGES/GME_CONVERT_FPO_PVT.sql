--------------------------------------------------------
--  DDL for Package GME_CONVERT_FPO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_CONVERT_FPO_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVCFPS.pls 120.3 2005/06/29 03:01:22 kxhunt noship $ */

   --******************************************************************
   TYPE pregen_fpo_row IS RECORD (
      batch_id             gme_batch_header.batch_id%TYPE
     ,qty_per_batch        NUMBER
     ,batch_size_uom       gme_material_details.dtl_um%TYPE
     ,num_batches          NUMBER
     ,validity_rule_id     gmd_recipe_validity_rules.recipe_validity_rule_id%TYPE
     ,leadtime             NUMBER
     ,offset_type          NUMBER
     ,batch_offset         NUMBER
     ,plan_start_date      gme_batch_header.plan_start_date%TYPE
     ,plan_cmplt_date      gme_batch_header.plan_cmplt_date%TYPE
     ,fpo_assigned_qty     gme_material_details.plan_qty%TYPE
     ,fpo_unassigned_qty   gme_material_details.plan_qty%TYPE
     ,schedule_method      VARCHAR2 (10)
     ,effective_qty        gme_material_details.plan_qty%TYPE
     ,sum_eff_qty          gme_material_details.plan_qty%TYPE       DEFAULT 0
     ,std_qty              NUMBER
     ,fixed_leadtime       NUMBER
     ,variable_leadtime    NUMBER
     ,rules_found          NUMBER
   );

   TYPE error_return_sts IS RECORD (
      return_status   VARCHAR2 (2)
   );

   TYPE validity_rule_row IS RECORD (
      plant_code                gme_batch_header.plant_code%TYPE
     ,prim_prod_item_id         gme_material_details.inventory_item_id%TYPE
     ,prim_prod_item_no         VARCHAR2(2000)
     ,prim_prod_item_desc1      mtl_system_items.description%TYPE
     ,prim_prod_item_um         gme_material_details.dtl_um%TYPE
     ,prim_prod_effective_qty   gme_material_details.plan_qty%TYPE
     ,organization_id           NUMBER
   );

   TYPE fpo_material_details_tab IS TABLE OF gme_material_details%ROWTYPE
      INDEX BY BINARY_INTEGER;

   TYPE generated_pre_batch_tab IS TABLE OF gme_batch_header%ROWTYPE
      INDEX BY BINARY_INTEGER;

   TYPE recipe_validity_rule_tab IS TABLE OF gmd_recipe_validity_rules%ROWTYPE
      INDEX BY BINARY_INTEGER;

   TYPE return_array_sts IS TABLE OF error_return_sts
      INDEX BY BINARY_INTEGER;

--******************************************************************

   --can remove schedule_method as parameter as is now calculated
   --in validation.
   PROCEDURE VALIDATION (
      p_batch_header               IN              gme_batch_header%ROWTYPE
     ,p_batch_size                 IN              NUMBER
     ,p_batch_size_uom             IN              VARCHAR2
     ,p_num_batches                IN              NUMBER
     ,p_validity_rule_id           IN              NUMBER
     ,p_leadtime                   IN              NUMBER
     ,p_batch_offset               IN              NUMBER
     ,p_offset_type                IN              NUMBER
     ,p_plan_start_date            IN              gme_batch_header.plan_start_date%TYPE
     ,p_plan_cmplt_date            IN              gme_batch_header.plan_cmplt_date%TYPE
     ,x_pregen_fpo_row             OUT NOCOPY      pregen_fpo_row
     ,x_return_status              OUT NOCOPY      VARCHAR2);

   PROCEDURE retrieve_fpo_data (
      p_fpo_header_row             IN              gme_batch_header%ROWTYPE
     ,x_fpo_header_row             OUT NOCOPY      gme_batch_header%ROWTYPE
     ,p_pregen_fpo_row             IN              pregen_fpo_row
     ,x_pregen_fpo_row             OUT NOCOPY      pregen_fpo_row
     ,x_prim_prod_row              OUT NOCOPY      gme_material_details%ROWTYPE
     ,x_validity_rule_row          OUT NOCOPY      validity_rule_row
     ,x_fpo_material_details_tab   OUT NOCOPY      fpo_material_details_tab
     ,x_return_status              OUT NOCOPY      VARCHAR2);

   PROCEDURE calculate_leadtime (
      p_pregen_fpo_row             IN              pregen_fpo_row
     ,x_pregen_fpo_row             OUT NOCOPY      pregen_fpo_row
     ,x_return_status              OUT NOCOPY      VARCHAR2);

   PROCEDURE generate_pre_batch_header_recs (
      p_fpo_header_row            IN              gme_batch_header%ROWTYPE
     ,p_prim_prod_row             IN              gme_material_details%ROWTYPE
     ,p_pregen_fpo_row            IN              pregen_fpo_row
     ,x_generated_pre_batch_tab   OUT NOCOPY      generated_pre_batch_tab
     ,x_return_status             OUT NOCOPY      VARCHAR2);

    /*  PROCEDURE get_validity_rule
      ( p_validity_rule_row         IN validity_rule_row
      , x_recipe_validity_rule_tab  OUT NOCOPY gme_common_pvt.recipe_validity_rule_tab
      , x_return_status             OUT NOCOPY VARCHAR2
      );
   */
   /* Pawan Kumar 09-16-2003 Bug 823188
        Modified the procedures call for shop calendar */
   PROCEDURE convert_fpo_to_batch (
      p_generated_pre_batch_tab    IN              generated_pre_batch_tab
     ,p_recipe_validity_rule_tab   IN              gme_common_pvt.recipe_validity_rule_tab
     ,p_pregen_fpo_row             IN              pregen_fpo_row
     ,x_generated_pre_batch_tab    OUT NOCOPY      generated_pre_batch_tab
     ,x_return_status              OUT NOCOPY      VARCHAR2
     ,x_arr_rtn_sts                OUT NOCOPY      return_array_sts
     ,p_process_row                IN              NUMBER DEFAULT 0
     ,p_use_shop_cal               IN              VARCHAR2 := fnd_api.g_false
     ,p_contiguity_override        IN              VARCHAR2 := fnd_api.g_true
     ,x_exception_material_tbl     OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,p_fpo_validity_rule_id       IN              NUMBER -- Bug 3185748 Added
                                                         );

    --can remove schedule_method as parameter as is now calculated
    --in validation.
   /* Pawan Kumar 09-16-2003 Bug 823188
        Modified the procedures call for shop calendar */
   PROCEDURE convert_fpo_main (
      p_batch_header               IN              gme_batch_header%ROWTYPE
     ,p_batch_size                 IN              NUMBER
     ,p_num_batches                IN              NUMBER
     ,p_validity_rule_id           IN              NUMBER
     ,p_validity_rule_tab          IN              gme_common_pvt.recipe_validity_rule_tab
     ,p_enforce_vldt_check         IN              VARCHAR2 := fnd_api.g_true
     ,p_leadtime                   IN              NUMBER
     ,p_batch_offset               IN              NUMBER
     ,p_offset_type                IN              NUMBER
     ,p_plan_start_date            IN              gme_batch_header.plan_start_date%TYPE
     ,p_plan_cmplt_date            IN              gme_batch_header.plan_cmplt_date%TYPE
     ,p_use_shop_cal               IN              VARCHAR2 := fnd_api.g_false
     ,p_contiguity_override        IN              VARCHAR2 := fnd_api.g_true
     ,x_return_status              OUT NOCOPY      VARCHAR2
     ,x_batch_header               OUT NOCOPY      gme_batch_header%ROWTYPE
     ,p_use_for_all                IN              VARCHAR2 := fnd_api.g_true);

   PROCEDURE update_original_fpo (
      p_fpo_header_row             IN              gme_batch_header%ROWTYPE
     ,p_prim_prod_row              IN              gme_material_details%ROWTYPE
     ,p_pregen_fpo_row             IN              pregen_fpo_row
     ,p_fpo_material_details_tab   IN              fpo_material_details_tab
     ,p_enforce_vldt_check         IN              VARCHAR2 := fnd_api.g_true
     ,x_fpo_header_row             OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status              OUT NOCOPY      VARCHAR2);
END gme_convert_fpo_pvt;

 

/
