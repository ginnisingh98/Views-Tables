--------------------------------------------------------
--  DDL for Package GMD_SUBSTITUTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SUBSTITUTION_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPSUBS.pls 120.0.12000000.1 2007/01/31 16:16:27 appldev noship $ */

  m_api_version   CONSTANT NUMBER         := 1;
  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMD_SUBSTITUTION_PUB';

  /* define record and table type to specify the column that needs to
     updated */
  TYPE update_table_rec_type IS RECORD
  (
    p_col_to_update      VARCHAR2(240)
  , p_value              VARCHAR2(240)
  );

  TYPE update_tbl_type IS TABLE OF update_table_rec_type INDEX BY BINARY_INTEGER;

  TYPE gmd_substitution_hdr_rec_type IS RECORD
  (
    SUBSTITUTION_NAME        gmd_item_substitution_hdr_b.substitution_name%TYPE
  , SUBSTITUTION_DESCRIPTION gmd_item_substitution_hdr_tl.substitution_description%TYPE
  , SUBSTITUTION_VERSION     gmd_item_substitution_hdr_b.substitution_version%TYPE
  , ORIGINAL_INVENTORY_ITEM_ID gmd_item_substitution_hdr_b.original_inventory_item_id%TYPE
  , ORIGINAL_ITEM_NO         VARCHAR2(1000)
  , ORIGINAL_QTY             gmd_item_substitution_hdr_b.original_qty%TYPE
  , PREFERENCE               gmd_item_substitution_hdr_b.preference%TYPE
  , START_DATE               DATE  := trunc(SYSDATE)
  , END_DATE                 DATE
  , OWNER_ORGANIZATION_ID    gmd_item_substitution_hdr_b.owner_organization_id%TYPE
  , REPLACEMENT_UOM_TYPE     gmd_item_substitution_hdr_b.replacement_uom_type%TYPE
  , ATTRIBUTE_CATEGORY       gmd_item_substitution_hdr_b.attribute_category%TYPE
  , ATTRIBUTE1               gmd_item_substitution_hdr_b.attribute1%TYPE
  , ATTRIBUTE2               gmd_item_substitution_hdr_b.attribute2%TYPE
  , ATTRIBUTE3               gmd_item_substitution_hdr_b.attribute3%TYPE
  , ATTRIBUTE4               gmd_item_substitution_hdr_b.attribute4%TYPE
  , ATTRIBUTE5               gmd_item_substitution_hdr_b.attribute5%TYPE
  , ATTRIBUTE6               gmd_item_substitution_hdr_b.attribute6%TYPE
  , ATTRIBUTE7               gmd_item_substitution_hdr_b.attribute7%TYPE
  , ATTRIBUTE8               gmd_item_substitution_hdr_b.attribute8%TYPE
  , ATTRIBUTE9               gmd_item_substitution_hdr_b.attribute9%TYPE
  , ATTRIBUTE10              gmd_item_substitution_hdr_b.attribute10%TYPE
  , ATTRIBUTE11              gmd_item_substitution_hdr_b.attribute11%TYPE
  , ATTRIBUTE12              gmd_item_substitution_hdr_b.attribute12%TYPE
  , ATTRIBUTE13              gmd_item_substitution_hdr_b.attribute13%TYPE
  , ATTRIBUTE14              gmd_item_substitution_hdr_b.attribute14%TYPE
  , ATTRIBUTE15              gmd_item_substitution_hdr_b.attribute15%TYPE
  , ATTRIBUTE16              gmd_item_substitution_hdr_b.attribute16%TYPE
  , ATTRIBUTE17              gmd_item_substitution_hdr_b.attribute17%TYPE
  , ATTRIBUTE18              gmd_item_substitution_hdr_b.attribute18%TYPE
  , ATTRIBUTE19              gmd_item_substitution_hdr_b.attribute19%TYPE
  , ATTRIBUTE20              gmd_item_substitution_hdr_b.attribute20%TYPE
  , ATTRIBUTE21              gmd_item_substitution_hdr_b.attribute21%TYPE
  , ATTRIBUTE22              gmd_item_substitution_hdr_b.attribute22%TYPE
  , ATTRIBUTE23              gmd_item_substitution_hdr_b.attribute23%TYPE
  , ATTRIBUTE24              gmd_item_substitution_hdr_b.attribute24%TYPE
  , ATTRIBUTE25              gmd_item_substitution_hdr_b.attribute25%TYPE
  , ATTRIBUTE26              gmd_item_substitution_hdr_b.attribute26%TYPE
  , ATTRIBUTE27              gmd_item_substitution_hdr_b.attribute27%TYPE
  , ATTRIBUTE28              gmd_item_substitution_hdr_b.attribute28%TYPE
  , ATTRIBUTE29              gmd_item_substitution_hdr_b.attribute29%TYPE
  , ATTRIBUTE30              gmd_item_substitution_hdr_b.attribute30%TYPE
  , CREATION_DATE            gmd_item_substitution_hdr_b.creation_date%TYPE
  , CREATED_BY               gmd_item_substitution_hdr_b.created_by%TYPE
  , LAST_UPDATE_DATE         gmd_item_substitution_hdr_b.last_update_date%TYPE
  , LAST_UPDATED_BY          gmd_item_substitution_hdr_b.last_updated_by%TYPE
  , LAST_UPDATE_LOGIN        gmd_item_substitution_hdr_b.last_update_login%TYPE
  );

  TYPE gmd_substitution_dtl_rec_type IS RECORD
  (
    INVENTORY_ITEM_ID        gmd_item_substitution_dtl.inventory_item_id%TYPE
  , ITEM_NO                  VARCHAR2(1000)
  , UNIT_QTY                 gmd_item_substitution_dtl.unit_qty%TYPE
  , DETAIL_UOM               gmd_item_substitution_dtl.detail_uom%TYPE
  , CREATION_DATE            gmd_item_substitution_dtl.creation_date%TYPE
  , CREATED_BY               gmd_item_substitution_dtl.created_by%TYPE
  , LAST_UPDATE_DATE         gmd_item_substitution_dtl.last_update_date%TYPE
  , LAST_UPDATED_BY          gmd_item_substitution_dtl.last_updated_by%TYPE
  , LAST_UPDATE_LOGIN        gmd_item_substitution_dtl.last_update_login%TYPE
  );

  TYPE gmd_fmsubstitution_rec_type IS RECORD
  (
    FORMULA_ID               gmd_formula_substitution.formula_id%TYPE
  , FORMULA_NO               fm_form_mst_b.formula_no%TYPE
  , FORMULA_VERS             fm_form_mst_b.formula_vers%TYPE
  , CREATION_DATE            gmd_formula_substitution.creation_date%TYPE
  , CREATED_BY               gmd_formula_substitution.created_by%TYPE
  , LAST_UPDATE_DATE         gmd_formula_substitution.last_update_date%TYPE
  , LAST_UPDATED_BY          gmd_formula_substitution.last_updated_by%TYPE
  , LAST_UPDATE_LOGIN        gmd_formula_substitution.last_update_login%TYPE
  );

  TYPE gmd_formula_substitution_tab IS TABLE OF gmd_fmsubstitution_rec_type
       INDEX BY BINARY_INTEGER;

  -- Creation of substitution header, detail and formula association
  PROCEDURE Create_substitution
  (
    p_api_version               IN  NUMBER
  , p_init_msg_list             IN  VARCHAR2
  , p_commit                    IN  VARCHAR2
  , p_substitution_hdr_rec      IN  gmd_substitution_hdr_rec_type
  , p_substitution_dtl_rec      IN  gmd_substitution_dtl_rec_type
  , p_formula_substitution_tbl  IN  gmd_formula_substitution_tab
  , x_message_count             OUT NOCOPY  NUMBER
  , x_message_list              OUT NOCOPY  VARCHAR2
  , x_return_status             OUT NOCOPY  VARCHAR2
  );

  -- Creation of formula association
  PROCEDURE Create_formula_association
  (
    p_api_version               IN  NUMBER
  , p_init_msg_list             IN  VARCHAR2
  , p_commit                    IN  VARCHAR2
  , p_substitution_id           IN  NUMBER    Default NULL
  , p_substitution_name         IN  VARCHAR2  Default NULL
  , p_substitution_version      IN  NUMBER    Default NULL
  , p_formula_substitution_tbl  IN  gmd_formula_substitution_tab
  , x_message_count             OUT NOCOPY  NUMBER
  , x_message_list              OUT NOCOPY  VARCHAR2
  , x_return_status             OUT NOCOPY  VARCHAR2
  );

  -- Update of substitution header
  PROCEDURE Update_substitution_header
  ( p_api_version          IN          NUMBER
  , p_init_msg_list        IN          VARCHAR2
  , p_commit               IN          VARCHAR2
  , p_substitution_id      IN          NUMBER     Default NULL
  , p_substitution_name    IN          VARCHAR2   Default NULL
  , p_substitution_version IN          NUMBER     Default NULL
  , p_update_table         IN          update_tbl_type
  , x_message_count        OUT NOCOPY  NUMBER
  , x_message_list         OUT NOCOPY  VARCHAR2
  , x_return_status        OUT NOCOPY  VARCHAR2
  );

  -- Update of substitution lines
  PROCEDURE Update_substitution_detail
  ( p_api_version            IN          NUMBER
  , p_init_msg_list          IN          VARCHAR2
  , p_commit                 IN          VARCHAR2
  , p_substitution_line_id   IN          NUMBER     Default NULL
  , p_substitution_id        IN          NUMBER     Default NULL
  , p_substitution_name      IN          VARCHAR2   Default NULL
  , p_substitution_version   IN          NUMBER     Default NULL
  , p_update_table           IN          update_tbl_type
  , x_message_count          OUT NOCOPY  NUMBER
  , x_message_list           OUT NOCOPY  VARCHAR2
  , x_return_status          OUT NOCOPY  VARCHAR2
  );

  -- Deletion of formula association
  PROCEDURE Delete_formula_association
  ( p_api_version              IN          NUMBER
  , p_init_msg_list            IN          VARCHAR2
  , p_commit                   IN          VARCHAR2
  , p_formula_substitution_id  IN          NUMBER    Default NULL
  , p_substitution_id          IN          NUMBER    Default NULL
  , p_substitution_name        IN          VARCHAR2  Default NULL
  , p_substitution_version     IN          NUMBER    Default NULL
  , p_formula_id               IN          NUMBER    Default NULL
  , p_formula_no               IN          VARCHAR2  Default NULL
  , p_formula_vers             IN          NUMBER    Default NULL
  , x_message_count            OUT NOCOPY  NUMBER
  , x_message_list             OUT NOCOPY  VARCHAR2
  , x_return_status            OUT NOCOPY  VARCHAR2
  );


END GMD_SUBSTITUTION_PUB;

 

/
