--------------------------------------------------------
--  DDL for Package GR_ITEM_SAFETY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_ITEM_SAFETY" AUTHID CURRENT_USER AS
/*$Header: GRFMISS.pls 120.1 2005/07/08 13:24:28 methomas noship $*/
/*	This record definition maintains the list of columns returned the form. */

   TYPE item_property_rec IS RECORD
	(description 		  gr_properties_tl.description%TYPE,
	 sequence_number	  gr_label_properties.sequence_number%TYPE,
	 property_id		  gr_label_properties.property_id%TYPE,
	 label_code  		  gr_label_properties.label_code%TYPE,
	 property_type_indicator  gr_properties_b.property_type_indicator%TYPE,
	 length			  gr_properties_b.length%TYPE,
	 precision 		  gr_properties_b.precision%TYPE,
	 range_min 		  gr_properties_b.range_min%TYPE,
	 range_max 		  gr_properties_b.range_max%TYPE,
	 rowid 			  VARCHAR2(18),
	 organization_id          gr_inv_item_properties.organization_id%TYPE,
	 inventory_item_id        gr_inv_item_properties.inventory_item_id%TYPE,
	 number_value 		  gr_inv_item_properties.number_value%TYPE,
	 alpha_value 		  gr_inv_item_properties.alpha_value%TYPE,
	 date_value 		  gr_inv_item_properties.date_value%TYPE,
	 meaning		  gr_property_values_tl.meaning%TYPE,
	 created_by		  gr_inv_item_properties.created_by%TYPE,
	 creation_date		  gr_inv_item_properties.creation_date%TYPE,
	 last_updated_by	  gr_inv_item_properties.last_updated_by%TYPE,
	 last_update_date	  gr_inv_item_properties.last_update_date%TYPE,
	 last_update_login	  gr_inv_item_properties.last_update_login%TYPE
	 );

/*  This table is the PL/SQL table returned to the form. */

   TYPE t_property_data IS TABLE OF item_property_rec
      INDEX BY BINARY_INTEGER;


   PROCEDURE get_properties
    			(p_organization_id   IN NUMBER,
                         p_inventory_item_id IN NUMBER,
    			 p_label_code        IN VARCHAR2,
			 x_prop_data         IN OUT NOCOPY t_property_data);

   PROCEDURE paste_item_safety
			(p_organization_id   IN NUMBER,
                         p_copy_from_item    IN NUMBER,
			 p_paste_to_item     IN NUMBER,
			 x_return_status    OUT NOCOPY VARCHAR2,
			 x_oracle_error     OUT NOCOPY NUMBER,
			 x_msg_data         OUT NOCOPY VARCHAR2);

   PROCEDURE delete_item_safety
			(p_delete_item IN VARCHAR2,
			 x_return_status OUT NOCOPY VARCHAR2,
			 x_oracle_error OUT NOCOPY NUMBER,
			 x_msg_data OUT NOCOPY VARCHAR2);

   PROCEDURE delete_item_document
			(p_delete_item IN VARCHAR2,
                         p_document_code IN VARCHAR2,
                         p_delete_option IN VARCHAR2,
			 x_return_status OUT NOCOPY VARCHAR2,
			 x_oracle_error OUT NOCOPY NUMBER,
			 x_msg_data OUT NOCOPY VARCHAR2);

END GR_ITEM_SAFETY;

 

/
