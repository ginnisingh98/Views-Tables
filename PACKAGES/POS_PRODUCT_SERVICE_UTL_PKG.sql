--------------------------------------------------------
--  DDL for Package POS_PRODUCT_SERVICE_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_PRODUCT_SERVICE_UTL_PKG" AUTHID CURRENT_USER AS
/* $Header: POSPSUTS.pls 120.5.12010000.9 2014/04/16 04:28:52 ppotnuru ship $*/
--
-- before calling other procedures in this package,
-- call this procedure to initialize
--
-- x_status:                     Y or N for success or failure
-- x_error_message:              an error message if there is an error
--
PROCEDURE initialize
  (x_status                     OUT NOCOPY VARCHAR2,
   x_error_message              OUT NOCOPY VARCHAR2
   );

PROCEDURE validate_segment_prof_nocache (
  p_product_segment_definition IN VARCHAR2
, x_status                     OUT NOCOPY VARCHAR2
, x_error_message              OUT NOCOPY VARCHAR2
);

PROCEDURE save_segment_profile (
  p_product_segment_definition IN VARCHAR2
, x_status                     OUT NOCOPY VARCHAR2
, x_error_message              OUT NOCOPY VARCHAR2
);

PROCEDURE get_product_meta_data
  (x_product_segment_definition OUT NOCOPY VARCHAR2,
   x_product_segment_count      OUT NOCOPY NUMBER,
   x_default_po_category_set_id OUT NOCOPY NUMBER,
   x_delimiter                  OUT NOCOPY VARCHAR2
   );

PROCEDURE get_product_segment_info
  (p_index            	  IN  NUMBER,
   x_column_name      	  OUT NOCOPY VARCHAR2,
   x_value_set_id     	  OUT NOCOPY NUMBER,
   x_validation_type  	  OUT NOCOPY VARCHAR2,
   x_table_name       	  OUT NOCOPY VARCHAR2,
   x_meaning_column   	  OUT NOCOPY VARCHAR2,
   x_id_column        	  OUT NOCOPY VARCHAR2,
   x_value_column     	  OUT NOCOPY VARCHAR2,
   x_where_clause     	  OUT NOCOPY VARCHAR2,
   x_parent_segment_index OUT NOCOPY INTEGER
   );
--

-- get the description of product and service for a row
-- in pos_sup_products_services table.
--
PROCEDURE get_product_description
  (p_classification_id IN  NUMBER, x_description OUT NOCOPY VARCHAR2 );

-- get the description of product and service represented
-- in the "category" format: 'value.value.valule..'
--
PROCEDURE get_product_description
  (p_category IN  VARCHAR2, x_description OUT NOCOPY VARCHAR2 );

-- get the description of product and service for a row
-- in pos_sup_products_services table, and whether there
-- is a subcategories for the product and service
PROCEDURE get_desc_check_subcategory
  (p_classification_id IN  NUMBER,
   x_description       OUT NOCOPY VARCHAR2,
   x_has_subcategory   OUT NOCOPY VARCHAR2 -- return Y or N
   );

FUNCTION get_vendor_by_category_query RETURN VARCHAR2;

-- return a string that includes meta data and the product segments info
FUNCTION debug_to_string RETURN VARCHAR2;

-- this function is included in the spec to allow testing
-- please do not call this function except for testing purpose
FUNCTION get_product_description
  (p_product_segment_index IN NUMBER,
   p_segment_value IN VARCHAR2,
   p_parent_segment_value IN VARCHAR2 DEFAULT NULL
   ) RETURN VARCHAR2;

-- get the description of product and service for a row
-- in pos_product_service_requests table, and whether there
-- is a subcategories for the product and service
PROCEDURE get_req_desc_has_sub
  (p_ps_request_id     IN  NUMBER,
   x_description       OUT NOCOPY VARCHAR2,
   x_has_subcategory   OUT nocopy VARCHAR2 -- return Y or N
   );



PROCEDURE add_new_ps_req
(  p_vendor_id     IN  NUMBER,
   p_segment1	   IN  VARCHAR2,
   p_segment2	   IN  VARCHAR2,
   p_segment3	   IN  VARCHAR2,
   p_segment4	   IN  VARCHAR2,
   p_segment5	   IN  VARCHAR2,
   p_segment6	   IN  VARCHAR2,
   p_segment7	   IN  VARCHAR2,
   p_segment8	   IN  VARCHAR2,
   p_segment9	   IN  VARCHAR2,
   p_segment10	   IN  VARCHAR2,
   p_segment11	   IN  VARCHAR2,
   p_segment12	   IN  VARCHAR2,
   p_segment13	   IN  VARCHAR2,
   p_segment14	   IN  VARCHAR2,
   p_segment15	   IN  VARCHAR2,
   p_segment16	   IN  VARCHAR2,
   p_segment17	   IN  VARCHAR2,
   p_segment18	   IN  VARCHAR2,
   p_segment19	   IN  VARCHAR2,
   p_segment20	   IN  VARCHAR2,
   p_segment_definition	   IN  VARCHAR2,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
) ;
PROCEDURE update_main_ps_req
(     p_req_id_tbl        IN  po_tbl_number,
      p_status            IN  VARCHAR2,
      x_return_status     OUT nocopy VARCHAR2,
      x_msg_count         OUT nocopy NUMBER,
      x_msg_data          OUT nocopy VARCHAR2
);

PROCEDURE remove_mult_ps_reqs
(   p_req_id_tbl        IN  po_tbl_number,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count       OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
);

PROCEDURE approve_mult_temp_ps_reqs
(   p_req_id_tbl        IN  po_tbl_number,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count       OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
);
/* Added following functions for P and S ER 7482793 */

 PROCEDURE insert_into_glb_temp
 (
    p_validation_type   IN  VARCHAR2,
    p_curr_seg_val_id   IN  NUMBER,
    p_parent_seg_val_id IN  NUMBER,
    p_table_name        IN  VARCHAR2,
    p_where_clause      IN  VARCHAR2,
    p_meaning           IN  VARCHAR2,
    p_id_column         IN  VARCHAR2,
    p_value_column      IN  VARCHAR2,
    p_column_name         IN VARCHAR2,
    p_parent_column_name  IN VARCHAR2,
	l_hierarchy           IN NUMBER,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count         OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
 );

 FUNCTION get_segment_value_description(x_segment_value_id VARCHAR2)
 RETURN VARCHAR2;

 FUNCTION get_segment_value_code(x_segment_value_id VARCHAR2)
 RETURN VARCHAR2;

 FUNCTION get_classid(x_segment_code in varchar2,x_vendor_id in NUMBER)
 RETURN NUMBER;

 FUNCTION get_requestid(x_segment_code in VARCHAR2,x_mapp_id in NUMBER)
 RETURN NUMBER;


 FUNCTION get_concat_code(x_classification_id in varchar2)
 RETURN VARCHAR2;

 FUNCTION get_concat_code(x_classification_id in VARCHAR2,record_type IN VARCHAR2)
 RETURN VARCHAR2;


/* Begin Supplier Hub: Supplier Profile Workbench */

TYPE product_service_ocv_rec IS RECORD
  (code       VARCHAR2(1000),
   meaning    VARCHAR2(4000)
  );

TYPE product_service_ocv_table IS
  TABLE OF product_service_ocv_rec;

FUNCTION product_service_ocv
RETURN product_service_ocv_table PIPELINED;

-- Added for bug 17007701
FUNCTION product_service_description(x_code in VARCHAR2)
RETURN VARCHAR2;

-- Added for bug 9275861
FUNCTION get_flexfield_columns
RETURN VARCHAR2;

/* End Supplier Hub: Supplier Profile Workbench */

END pos_product_service_utl_pkg;

/
