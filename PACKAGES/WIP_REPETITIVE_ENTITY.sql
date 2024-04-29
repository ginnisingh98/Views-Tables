--------------------------------------------------------
--  DDL for Package WIP_REPETITIVE_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_REPETITIVE_ENTITY" AUTHID CURRENT_USER as
/* $Header: wiprents.pls 115.7 2002/11/29 15:27:23 rmahidha ship $ */

/*==========================================================================+
  PROCEDURE
	Create_Entity

  PURPOSE
   	Create wip entity in table wip_entities and wip_repetitive_items.

  EXCEPTIONS


  NOTES

+==========================================================================*/

procedure create_entity(p_rowid 	              	  IN OUT NOCOPY VARCHAR2,
                 p_wip_entity_id                  IN OUT NOCOPY NUMBER,
		 p_wip_entity_name		  VARCHAR2,
		 p_description			  VARCHAR2,
                 p_line_Id                        NUMBER,
                 p_organization_id                NUMBER,
                 p_primary_item_id                NUMBER,
                 p_alternate_bom_designator       VARCHAR2,
                 p_alternate_routing_designator   VARCHAR2,
                 p_class_code                     VARCHAR2,
                 p_wip_supply_type                NUMBER,
                 p_completion_subinventory        VARCHAR2,
                 p_completion_locator_id          NUMBER,
                 p_load_distribution_priority     NUMBER,
                 p_primary_line_flag              NUMBER,
                 p_production_line_rate           NUMBER,
		 p_overcompletion_toleran_type	  NUMBER,
		 p_overcompletion_toleran_value	  NUMBER,
                 p_attribute_category             VARCHAR2,
                 p_attribute1                     VARCHAR2,
                 p_attribute2                     VARCHAR2,
                 p_attribute3                     VARCHAR2,
                 p_attribute4                     VARCHAR2,
                 p_attribute5                     VARCHAR2,
                 p_attribute6                     VARCHAR2,
                 p_attribute7                     VARCHAR2,
                 p_attribute8                     VARCHAR2,
                 p_attribute9                     VARCHAR2,
                 p_attribute10                    VARCHAR2,
                 p_attribute11                    VARCHAR2,
                 p_attribute12                    VARCHAR2,
                 p_attribute13                    VARCHAR2,
                 p_attribute14                    VARCHAR2,
                 p_attribute15                    VARCHAR2);



/*==========================================================================+
  PROCEDURE
	Delete_Entity

  PURPOSE
   	Delete wip entity in wip_repetitive_items.  If the record being
  	deleted is the last instance in wip_repetitive_items, the entity
	will be deleted in wip_entities.

  EXCEPTIONS


  NOTES

+==========================================================================*/

procedure delete_entity(p_wip_entity_id	IN OUT NOCOPY NUMBER,
	 	 p_org_id		NUMBER,
		 p_rowid		VARCHAR2);



/*==========================================================================+
  PROCEDURE
	Update_Entity

  PURPOSE
   	Update information in wip_repetitive_items.

  EXCEPTIONS


  NOTES

+==========================================================================*/

procedure update_entity(p_rowid                          VARCHAR2,
                 p_wip_entity_id                  NUMBER,
                 p_line_Id                        NUMBER,
                 p_organization_id                NUMBER,
                 p_primary_item_id                NUMBER,
                 p_alternate_bom_designator       VARCHAR2,
                 p_alternate_routing_designator   VARCHAR2,
                 p_class_code                     VARCHAR2,
                 p_wip_supply_type                NUMBER,
                 p_completion_subinventory        VARCHAR2,
                 p_completion_locator_id          NUMBER,
                 p_load_distribution_priority     NUMBER,
                 p_primary_line_flag              NUMBER,
                 p_production_line_rate           NUMBER,
		 p_overcompletion_toleran_type	  NUMBER,
		 p_overcompletion_toleran_value	  NUMBER,
                 p_attribute_category             VARCHAR2,
                 p_attribute1                     VARCHAR2,
                 p_attribute2                     VARCHAR2,
                 p_attribute3                     VARCHAR2,
                 p_attribute4                     VARCHAR2,
                 p_attribute5                     VARCHAR2,
                 p_attribute6                     VARCHAR2,
                 p_attribute7                     VARCHAR2,
                 p_attribute8                     VARCHAR2,
                 p_attribute9                     VARCHAR2,
                 p_attribute10                    VARCHAR2,
                 p_attribute11                    VARCHAR2,
                 p_attribute12                    VARCHAR2,
                 p_attribute13                    VARCHAR2,
                 p_attribute14                    VARCHAR2,
                 p_attribute15                    VARCHAR2);
end WIP_REPETITIVE_ENTITY;

 

/
