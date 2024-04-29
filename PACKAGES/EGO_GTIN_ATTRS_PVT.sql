--------------------------------------------------------
--  DDL for Package EGO_GTIN_ATTRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_GTIN_ATTRS_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVGATS.pls 120.6 2007/03/27 17:00:02 dsakalle ship $ */

  /*
   ** This function returns TRUE if check digit is invalid
   */
  FUNCTION Is_Check_Digit_Invalid (p_code VARCHAR2) RETURN BOOLEAN;

  /*
   ** This procedure populates the interface table rows for UCCnet attributes
   *  into pl/sql table
   */
  PROCEDURE Get_Gdsn_Intf_Rows( p_data_set_id IN  NUMBER
                               ,p_target_proc_status   IN  NUMBER
                               ,p_inventory_item_id    IN  NUMBER
                               ,p_organization_id      IN  NUMBER
                               ,p_ignore_delete        IN  VARCHAR2 DEFAULT 'N'
                               ,x_singe_row_attrs_rec  OUT NOCOPY  EGO_ITEM_PUB.UCCNET_ATTRS_SINGL_ROW_REC_TYP
                               ,x_multi_row_attrs_tbl  OUT NOCOPY  EGO_ITEM_PUB.UCCNET_ATTRS_MULTI_ROW_TBL_TYP
                               ,x_return_status        OUT NOCOPY VARCHAR2
                               ,x_msg_count            OUT NOCOPY NUMBER
                               ,x_msg_data             OUT NOCOPY VARCHAR2
                              );

  /*
   ** This procedure validates the interface table rows for UCCnet attributes
   */
  PROCEDURE Validate_Intf_Rows( p_data_set_id IN  NUMBER
                               ,p_entity_id NUMBER
                               ,p_entity_code VARCHAR2
                               ,p_add_errors_to_fnd_stack VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2
                              );

  PROCEDURE Do_Post_UCCnet_Attrs_Action ( p_data_set_id  IN  NUMBER
                                         ,p_entity_id   IN  NUMBER
                                         ,p_entity_code IN VARCHAR2
                                         ,p_add_errors_to_fnd_stack IN VARCHAR2);

  /*
   ** This procedure validates the data passed in for UCCnet attributes
   */
  PROCEDURE Validate_Attributes(
              p_inventory_item_id    IN  NUMBER
             ,p_organization_id      IN  NUMBER
             ,p_singe_row_attrs_rec  IN  EGO_ITEM_PUB.UCCNET_ATTRS_SINGL_ROW_REC_TYP
             ,p_multi_row_attrs_tbl  IN  EGO_ITEM_PUB.UCCNET_ATTRS_MULTI_ROW_TBL_TYP
             ,p_extra_attrs_rec      IN  EGO_ITEM_PUB.UCCnet_Extra_Attrs_Rec_Typ
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             );

  /*
   ** This procedure creates/updates the UCCnet attributes for an item
   */
  PROCEDURE Process_UCCnet_Attrs_For_Item (
          p_api_version                   IN   NUMBER
         ,p_inventory_item_id             IN   NUMBER
         ,p_organization_id               IN   NUMBER
         ,p_single_row_attrs_rec          IN   EGO_ITEM_PUB.UCCnet_Attrs_Singl_Row_Rec_Typ
         ,p_multi_row_attrs_table         IN   EGO_ITEM_PUB.UCCnet_Attrs_Multi_Row_Tbl_Typ
         ,p_check_policy                  IN   VARCHAR2   DEFAULT FND_API.G_TRUE
         ,p_entity_id                     IN   NUMBER     DEFAULT NULL
         ,p_entity_index                  IN   NUMBER     DEFAULT NULL
         ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
         ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
         ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
         ,x_return_status                 OUT NOCOPY VARCHAR2
         ,x_errorcode                     OUT NOCOPY NUMBER
         ,x_msg_count                     OUT NOCOPY NUMBER
         ,x_msg_data                      OUT NOCOPY VARCHAR2);

END EGO_GTIN_ATTRS_PVT;

/
