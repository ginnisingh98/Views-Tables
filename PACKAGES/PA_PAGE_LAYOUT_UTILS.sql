--------------------------------------------------------
--  DDL for Package PA_PAGE_LAYOUT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAGE_LAYOUT_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAPGLUTS.pls 120.1 2005/08/19 16:40:38 mwasowic noship $ */
	procedure	copy_object_page_layouts(
                        p_object_type		IN     VARCHAR2,
			P_object_id_from        IN     number,
			P_object_id_to 	        IN     number,
			--p_function_name         IN     VARCHAR2 := NULL,  --Bug 3665562
		        x_return_status         OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   			x_msg_count             OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   			x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			);

     /* This is the function to check customer and project value columns
        exists in the project header at the project level */
     procedure	check_cols_in_proj_header(
                        p_object_type	   IN     VARCHAR2,
			p_object_id        IN     number,
                        x_customer_exists  OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                        x_proj_val_exists  OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

	Function get_ak_region_code
	  (
	   p_region_name IN VARCHAR2,
	   p_application_id IN number
	   )  RETURN VARCHAR2  ;

	Function get_region_source_code
	  (
	   p_region_source_name IN VARCHAR2,
	   p_region_source_type IN VARCHAR2,
	   p_application_id IN NUMBER,
	   p_flex_name IN VARCHAR2
	   )  RETURN VARCHAR2 ;

	FUNCTION is_page_type_region_deletable(
					       p_page_type_code IN VARCHAR2,
					       p_region_source_type IN VARCHAR2,
					       p_region_source_code IN VARCHAR2) RETURN VARCHAR2  ;

	FUNCTION get_context_name( p_context_code IN VARCHAR2)
	RETURN VARCHAR2  ;

	 procedure Check_pagelayout_Name_Or_Id (
			p_pagelayout_name	IN	VARCHAR2 :=FND_API.G_MISS_CHAR,
			p_pagetype_code		IN	VARCHAR2 :=FND_API.G_MISS_CHAR,
			p_check_id_flag		IN	VARCHAR2 := 'A',
			x_pagelayout_id		IN OUT	NOCOPY NUMBER , --File.Sql.39 bug 4440895
			x_return_status		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_error_message_code	OUT	NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

         FUNCTION check_page_layout_deletable (p_page_id NUMBER)
         return varchar2;

         FUNCTION GET_PAGE_ID_FROM_FUNCTION(
			p_page_type_code	IN	VARCHAR2,
			p_pers_function_name	IN	VARCHAR2
			)
	 return NUMBER;

	 PROCEDURE POPULATE_PERS_FUNCTIONS (p_page_type_code_tbl  IN	 SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
				   p_function_name_tbl		  IN	 SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
				   x_return_status		  OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	   			   x_msg_count			  OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
			           x_msg_data			  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				  );
END PA_Page_layout_Utils;

 

/
