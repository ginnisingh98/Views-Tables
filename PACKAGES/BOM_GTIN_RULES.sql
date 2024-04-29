--------------------------------------------------------
--  DDL for Package BOM_GTIN_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_GTIN_RULES" AUTHID CURRENT_USER AS
/* $Header: BOMLGTNS.pls 120.4 2007/07/19 09:34:31 dikrishn ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLGTNS.pls
--
--  DESCRIPTION
--
--      Package spec: BOM Validations for GTIN
--
--  NOTES
--
--  HISTORY
--
--  18-MAY-04   Refai Farook    Initial Creation
--
--
****************************************************************************/

  PROCEDURE Check_GTIN_Attributes ( p_bill_sequence_id IN NUMBER := NULL,
                                    p_assembly_item_id NUMBER,
                                    p_organization_id IN NUMBER,
                                    p_alternate_bom_code IN VARCHAR2 := NULL,
                                    p_component_item_id IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_error_message  OUT NOCOPY VARCHAR2);

  /* Overloaded method with p_ignore_published for rollups to ignore
   * published hierarchies exception */
  PROCEDURE Check_GTIN_Attributes ( p_bill_sequence_id IN NUMBER := NULL,
                                    p_assembly_item_id NUMBER,
                                    p_organization_id IN NUMBER,
                                    p_alternate_bom_code IN VARCHAR2 := NULL,
                                    p_component_item_id IN NUMBER,
                                    p_ignore_published IN VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_error_message  OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Top_GTIN( p_organization_id IN NUMBER,
                             p_component_item_id IN NUMBER,
                             p_parent_item_id in NUMBER := NULL,
                             p_structure_name in VARCHAR2 := NULL);


  /* Returns the uom conversion rate
    Returns -99999 when any error occurs */


  FUNCTION Get_Suggested_Quantity ( p_component_item_id IN NUMBER,
                                    p_component_uom  IN VARCHAR2,
                                    p_assembly_uom  IN VARCHAR2) RETURN NUMBER;
  FUNCTION Pack_Check(p_item_id IN NUMBER , p_org_id IN NUMBER) return
VARCHAR2;

  /*
  FUNCTION Get_Suggested_Quantity ( p_component_item_id   IN NUMBER,
                                    p_component_uom_name  IN VARCHAR2,
                                    p_assembly_uom_name   IN VARCHAR2) RETURN NUMBER;
 */

  FUNCTION Get_Suggested_Quantity ( p_organization_id IN NUMBER,
                   p_assembly_item_id NUMBER,
                                    p_component_item_id IN NUMBER ) RETURN NUMBER;

 PROCEDURE Perform_Rollup
        (  p_item_id            IN  NUMBER
         , p_organization_id    IN  NUMBER
         , p_parent_item_id     IN  NUMBER := NULL
         , p_structure_type_name IN  VARCHAR2
         , p_transaction_type   IN  VARCHAR2
         , p_validate           IN  VARCHAR2 := 'N'
         , p_halt_on_error      IN  VARCHAR2 := 'N'
         , p_structure_name     IN  VARCHAR2 := NULL
         , x_error_message      OUT NOCOPY VARCHAR2
        );


        PROCEDURE UPDATE_REG_PUB_UPDATE_DATES (p_inventory_item_id NUMBER,
                                        p_organization_id  IN NUMBER,
                                        p_update_reg        IN VARCHAR2 := 'N',
                                        p_commit            IN VARCHAR2 :=  FND_API.G_FALSE,
                                        x_return_status    OUT NOCOPY VARCHAR2,
                                        x_msg_count        OUT NOCOPY NUMBER,
                                        x_msg_data          OUT NOCOPY VARCHAR2
     );

PROCEDURE GET_UOM_CLASS_COMPATIBILITY(p_src_uom_code IN VARCHAR2,
                                      p_dest_uom_code IN VARCHAR2,
                                      x_compatibility_status OUT NOCOPY VARCHAR2);

PROCEDURE GET_UOM_CLASS_COMPATIBILITY(p_source_item_id IN NUMBER,
                                      p_destn_item_id IN NUMBER,
                                      p_src_org_id IN NUMBER,
                                      p_dest_org_id IN NUMBER,
                                      x_compatibility_status OUT NOCOPY VARCHAR2);

 PROCEDURE Validate_Hierarchy_Attrs ( p_group_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_error_message  OUT NOCOPY VARCHAR2);


END BOM_GTIN_Rules;

/
