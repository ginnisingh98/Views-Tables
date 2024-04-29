--------------------------------------------------------
--  DDL for Package GME_FPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_FPL_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVFPLS.pls 120.1.12010000.1 2008/11/06 03:42:12 srpuri noship $ */

PROCEDURE get_fixed_process_loss (
      p_batch_id                     IN   NUMBER DEFAULT NULL
     ,p_validity_rule_id             IN   NUMBER
     ,p_organization_id              IN   NUMBER DEFAULT NULL
     ,x_fixed_process_loss           OUT  NOCOPY NUMBER
     ,x_fixed_process_loss_uom       OUT  NOCOPY sy_uoms_mst.uom_code%TYPE
     );

PROCEDURE apply_fixed_process_loss (
      p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_material_tbl             IN              gme_common_pvt.material_details_tab
     ,p_organization_id          IN              NUMBER DEFAULT NULL
     ,p_creation_mode            IN              VARCHAR2
     ,p_called_from              IN              NUMBER DEFAULT 1 /*1 = Create Batch, 2 = Batch details */
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_material_tbl             OUT NOCOPY      gme_common_pvt.material_details_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2
     );

PROCEDURE FPL_batch_details (
          p_batch_header_rec	IN              gme_batch_header%ROWTYPE
         ,p_called_from         IN              NUMBER DEFAULT 1 /*1 = Create Batch, 2 = Batch details */
         ,p_init_msg_list       IN              VARCHAR2 := fnd_api.g_false
         ,x_message_count       OUT NOCOPY      NUMBER
         ,x_message_list        OUT NOCOPY      VARCHAR2
         ,x_return_status       OUT NOCOPY      VARCHAR2
         );

END gme_fpl_pvt;

/
