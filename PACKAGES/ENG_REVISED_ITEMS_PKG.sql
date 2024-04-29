--------------------------------------------------------
--  DDL for Package ENG_REVISED_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_REVISED_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: engprvis.pls 120.3 2006/07/07 13:42:08 pdutta noship $ */

FUNCTION Get_High_Rev_ECO (x_organization_id    NUMBER,
                           x_revised_item_id    NUMBER,
                           x_new_item_revision  VARCHAR2) RETURN VARCHAR2;


FUNCTION Get_BOM_Lists_Seq_Id RETURN NUMBER;


PROCEDURE Insert_BOM_Lists (x_revised_item_id   NUMBER,
                            x_sequence_id       NUMBER,
                            x_bill_sequence_id  NUMBER);


PROCEDURE Delete_BOM_Lists (x_sequence_id NUMBER);


PROCEDURE Delete_Details (x_organization_id       NUMBER,
        x_revised_item_id       NUMBER,
        x_revised_item_sequence_id      NUMBER,
        x_bill_sequence_id        NUMBER,
        x_change_notice       VARCHAR2);


PROCEDURE Create_BOM (x_assembly_item_id          NUMBER,
                      x_organization_id           NUMBER,
                      x_alternate_BOM_designator  VARCHAR2,
                      x_userid                    NUMBER,
                      x_change_notice             VARCHAR2,
                      x_revised_item_sequence_id  NUMBER,
                      x_bill_sequence_id          NUMBER,
                      x_assembly_type             NUMBER,
                      x_structure_type_id         NUMBER);


PROCEDURE Insert_Current_Scheduled_Dates (x_change_notice     VARCHAR2,
            x_organization_id   NUMBER,
            x_revised_item_id   NUMBER,
            x_scheduled_date    DATE,
            x_revised_item_sequence_id  NUMBER,
                    x_requestor_id    NUMBER,
            x_userid      NUMBER);


PROCEDURE Delete_Item_Revisions (x_change_notice      VARCHAR2,
                 x_organization_id      NUMBER,
         x_inventory_item_id      NUMBER,
         x_revised_item_sequence_id   NUMBER);


PROCEDURE Insert_Item_Revisions (x_inventory_item_id      NUMBER,
         x_organization_id      NUMBER,
         x_revision       VARCHAR2,
         x_userid       NUMBER,
         x_change_notice      VARCHAR2,
         x_scheduled_date     DATE,
         x_revised_item_sequence_id   NUMBER,
                                 x_revision_description                 VARCHAR2 := NULL,
                                 p_new_revision_label                   VARCHAR2 DEFAULT NULL,
                                 p_new_revision_reason_code             VARCHAR2 DEFAULT NULL,
                                 p_from_revision_id                     NUMBER DEFAULT NULL);

PROCEDURE Insert_Item_Revisions (x_inventory_item_id            NUMBER,
                 x_organization_id           NUMBER,
                 x_revision                  VARCHAR2,
                 x_userid                    NUMBER,
                 x_change_notice             VARCHAR2,
                 x_scheduled_date            DATE,
                 x_revised_item_sequence_id  NUMBER,
                 x_revision_description      VARCHAR2 := NULL,
                 p_new_revision_label        VARCHAR2 DEFAULT NULL,
                 p_new_revision_reason_code  VARCHAR2 DEFAULT NULL,
                 p_from_revision_id          NUMBER DEFAULT NULL,
                 x_new_revision_id   IN OUT NOCOPY NUMBER);

PROCEDURE Update_Item_Revisions (x_revision       VARCHAR2,
         x_scheduled_date     DATE,
         x_change_notice      VARCHAR2,
         x_organization_id      NUMBER,
         x_inventory_item_id      NUMBER,
         x_revised_item_sequence_id   NUMBER,
                                 x_revision_description                 VARCHAR2 := NULL);


PROCEDURE Update_Inventory_Components (x_change_notice      VARCHAR2,
               x_bill_sequence_id   NUMBER,
               x_revised_item_sequence_id NUMBER,
               x_scheduled_date     DATE,
               x_from_end_item_unit_number  VARCHAR2 DEFAULT NULL);


 -- Added for bug 3496165
/********************************************************************
 * API Name      : UPDATE_REVISION_CHANGE_NOTICE
 * Parameters IN : p_revision_id, p_change_notice
 * Parameters OUT: None
 * Purpose       : Updates the value of change_notice in the
 * mtl_item_revisions_b/_tl table with the value passed as parameter
 * for the row specified.
 *********************************************************************/
PROCEDURE UPDATE_REVISION_CHANGE_NOTICE ( p_revision_id IN NUMBER
          , p_change_notice IN VARCHAR2);

PROCEDURE Query_Target_Revised_Item (
    p_api_version          IN  NUMBER   := 1.0
  , p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
--  , p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
--  , p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  , x_return_status        OUT NOCOPY VARCHAR2
  , x_msg_count            OUT NOCOPY NUMBER
  , x_msg_data             OUT NOCOPY VARCHAR2
  , p_change_id            IN NUMBER
  , p_organization_id      IN NUMBER
  , p_revised_item_id      IN NUMBER
  , p_revision_id          IN NUMBER
  , x_revised_item_seq_id  OUT NOCOPY NUMBER
  );

PROCEDURE Get_Component_Intf_Change_Dtls (
    p_api_version             IN  NUMBER   := 1.0
  , p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE
--  , p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
--  , p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  , x_return_status             OUT NOCOPY VARCHAR2
  , x_msg_count                 OUT NOCOPY NUMBER
  , x_msg_data                  OUT NOCOPY VARCHAR2
  , p_change_id                 IN NUMBER
  , p_change_notice             IN VARCHAR2
  , p_organization_id           IN NUMBER
  , p_revised_item_id           IN NUMBER
  , p_bill_sequence_id          IN NUMBER
  , p_component_item_id         IN NUMBER
  , p_effectivity_date          IN DATE    := NULL
  , p_from_end_item_unit_number IN NUMBER  := NULL
  , p_from_end_item_rev_id      IN NUMBER  := NULL
  , p_old_component_sequence_id IN NUMBER  := NULL
  , p_transaction_type          IN VARCHAR2
  , x_revised_item_sequence_id  OUT NOCOPY NUMBER
  , x_component_sequence_id     OUT NOCOPY NUMBER
  , x_acd_type                  OUT NOCOPY NUMBER
  , x_change_transaction_type   OUT NOCOPY VARCHAR2
  ) ;

-- Bug 4290411
/********************************************************************
 * API Name      : Check_Rev_Comp_Editable
 * Parameters IN : p_component_sequence_id
 * Parameters OUT: x_rev_comp_editable_flag
 * Purpose       : The API is called from bom explosion to check if
 *                 revised component is editable.
 *                 This api does not check change header status/workflow
 *                 and user access as PW already handles this.
 *********************************************************************/
PROCEDURE Check_Rev_Comp_Editable (
    p_component_sequence_id   IN NUMBER
  , x_rev_comp_editable_flag  OUT NOCOPY VARCHAR2 -- FND_API.G_TRUE, FND_API.G_FALSE
);

END ENG_REVISED_ITEMS_PKG ;

 

/
