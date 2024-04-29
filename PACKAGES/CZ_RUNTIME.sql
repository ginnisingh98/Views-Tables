--------------------------------------------------------
--  DDL for Package CZ_RUNTIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_RUNTIME" AUTHID CURRENT_USER AS
/*	$Header: czruns.pls 120.2 2005/09/01 12:34:30 skudryav ship $		*/

  FUNCTION annotated_node_path
  (p_root_model_id            IN NUMBER,
   p_target_page_expl_id      IN NUMBER,
   p_target_ui_def_id         IN NUMBER,
   p_target_page_persist_id   IN NUMBER,
   p_root_model_expl_id       IN NUMBER
   ) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (annotated_node_path, WNDS, WNPS);

  FUNCTION get_TARGET_PAGE_REF_DEPTH
  (p_root_model_id       IN NUMBER,
   p_target_page_expl_id IN NUMBER,
   p_target_ui_def_id    IN NUMBER,
   p_root_model_expl_id  IN NUMBER) RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (get_TARGET_PAGE_REF_DEPTH, WNDS, WNPS);

  PROCEDURE get_Target_UI_Pages(p_root_ui_def_id         IN NUMBER,
                                p_root_model_expl_id     IN NUMBER,
                                p_root_model_node_id     IN NUMBER,
                                p_node_collection_flag   IN VARCHAR2,
                                p_curr_ui_def_id         IN NUMBER,
                                p_curr_page_id           IN NUMBER,
                                p_order_by_template      IN NUMBER,
                                x_ui_page_tbl            OUT NOCOPY SYSTEM.cz_tgt_ui_page_tbl);


  PROCEDURE sort_options( p_ui_def_id 	IN	NUMBER,
			  p_property_id IN	NUMBER,
			  p_sort_order	IN	NUMBER,
			  x_sorted_table IN OUT NOCOPY system.cz_sort_tbl_type
			 );

  /* retrieves root bom node id in a model
     p_err_flag = 0  success
     p_err_flag > 0  indicates error and p_err_msg specifies what is wrong
                  1  means more than one id returned which is not supported currently.
                  2  indicates no bom component found
  */
  PROCEDURE get_root_bom_node(p_model_id IN NUMBER,
                              p_persistent_node_id OUT NOCOPY NUMBER,
                              p_ps_node_id OUT NOCOPY NUMBER,
                              p_err_flag OUT NOCOPY VARCHAR2,
                              p_err_msg OUT NOCOPY VARCHAR2
                             );

  PROCEDURE get_config_info(p_config_hdr_id   IN  NUMBER
                           ,p_config_rev_nbr  IN  NUMBER
                           ,x_component_id         OUT  NOCOPY  NUMBER
                           ,x_top_item_id          OUT  NOCOPY  NUMBER
                           ,x_organization_id      OUT  NOCOPY  NUMBER
                           ,x_quantity             OUT  NOCOPY  NUMBER
                           ,x_usage_name           OUT  NOCOPY  VARCHAR2
                           ,x_effective_date       OUT  NOCOPY  DATE
                           ,x_config_date_created  OUT  NOCOPY  DATE
                           ,x_complete_flag        OUT  NOCOPY  VARCHAR2
                           ,x_valid_flag           OUT  NOCOPY  VARCHAR2
                           ,x_return_status        OUT  NOCOPY  VARCHAR2
                           ,x_msg_data             OUT  NOCOPY  VARCHAR2
                           );
/* This procedure is called when a configurator runtime UI is
   launched from embedded JRAD Region The API returns NULL if the ui_style on the publication
   is not a JRAD style UI otherwise it returns a publictaion_id. */

FUNCTION embedded_publication_for_item   (inventory_item_id		IN	NUMBER,
		               	 organization_id		IN	NUMBER,
		      		 config_lookup_date	IN	DATE,
		      		 calling_application_id IN	NUMBER,
		     		 	 usage_name			IN	VARCHAR2,
 		      		 publication_mode		IN	VARCHAR2 DEFAULT NULL,
		      		 language			IN	VARCHAR2 DEFAULT NULL
		      		)
RETURN NUMBER;

/* This procedure is called when a configurator runtime UI is
   launched from embedded JRAD Region The API returns NULL if the ui_style on the publication
   is not a JRAD style UI otherwise it returns a publictaion_id. */

FUNCTION embedded_pubId_for_product(product_key   IN	VARCHAR2,
		      		 config_lookup_date	  IN	DATE,
		      		 calling_application_id   IN	NUMBER,
		     		 	 usage_name			  IN	VARCHAR2,
 		      		 publication_mode		  IN	VARCHAR2 DEFAULT NULL,
		     		 	 language			  IN	VARCHAR2 DEFAULT NULL
		      		)
RETURN NUMBER;

/* This procedure is called when a configurator runtime UI is
   launched from embedded JRAD Region The API returns NULL if the ui_style on the publication
   is not a JRAD style UI otherwise it returns a publictaion_id. */

FUNCTION embedded_pub_for_savedconfig (config_hdr_id  IN	NUMBER,
		               	 		     config_rev_nbr IN	NUMBER,
		      		 		     config_lookup_date		IN	DATE,
		      		 		     calling_application_id  	IN	NUMBER,
		     		 	 		     usage_name			IN	VARCHAR2,
 		      		 		     publication_mode		IN	VARCHAR2 DEFAULT NULL,
		      		 		     language			IN	VARCHAR2 DEFAULT NULL
		      				)
RETURN NUMBER;

END;

 

/
