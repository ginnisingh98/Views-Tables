--------------------------------------------------------
--  DDL for Package AR_CMGT_DP_TABLE_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_DP_TABLE_HANDLER" AUTHID CURRENT_USER AS
/* $Header: ARCMGDTS.pls 120.12 2006/06/29 17:33:39 bsarkar noship $ */

procedure INSERT_ROW
	( p_data_point_name		        IN	VARCHAR2,
	  p_description			        IN	VARCHAR2,
	  p_data_point_category	   		IN	VARCHAR2,
	  p_user_defined_flag		    	IN	VARCHAR2,
	  p_scorable_flag		        IN	VARCHAR2,
	  p_display_on_checklist	    	IN	VARCHAR2,
	  p_created_by			        IN	NUMBER,
	  p_last_updated_by		        IN	NUMBER,
	  p_last_update_login			IN	NUMBER,
	  p_data_point_id		      	IN   	NUMBER,
	  p_return_data_type			IN		VARCHAR2,
	  p_return_date_format			IN		VARCHAR2,
	  p_application_id				IN		NUMBER,
	  p_parent_data_point_id		IN		NUMBER,
	  p_enabled_flag				IN		VARCHAR2,
	  p_package_name				IN		VARCHAR2,
	  p_function_name				IN		VARCHAR2,
	  p_data_point_sub_category		IN		VARCHAR2,
      p_data_point_code             IN  VARCHAR2
      );

PROCEDURE insert_adp_row(
				 p_data_point_code				IN		VARCHAR2,
                 p_data_point_name              IN  	VARCHAR2,
                 p_description                  IN  	VARCHAR2,
                 p_data_point_sub_category      IN  	VARCHAR2,
                 p_data_point_category          IN  	VARCHAR2,
                 p_user_defined_flag            IN  	VARCHAR2,
                 p_scorable_flag                IN  	VARCHAR2,
                 p_display_on_checklist         IN  	VARCHAR2,
                 p_created_by                   IN  	NUMBER,
                 p_last_updated_by              IN  	NUMBER,
                 p_last_update_login            IN  	NUMBER,
                 p_data_point_id                IN  	NUMBER,
                 p_application_id               IN  	NUMBER,
                 p_parent_data_point_id         IN  	NUMBER,
                 p_enabled_flag                 IN  	VARCHAR2,
                 p_package_name                 IN  	VARCHAR2,
                 p_function_name                IN  	VARCHAR2,
				 p_function_type				IN		VARCHAR2,
				 p_return_data_type				IN		VARCHAR2,
				 p_return_date_format			IN		VARCHAR2);

procedure UPDATE_ROW
	( p_data_point_id           IN      NUMBER,
      p_data_point_name    		IN	VARCHAR2,
      p_description            	IN      VARCHAR2,
	  p_data_point_category		IN	VARCHAR2,
	  p_user_defined_flag		IN	VARCHAR2,
	  p_scorable_flag	    	IN	VARCHAR2,
	  p_display_on_checklist	IN	VARCHAR2,
      p_application_id      	IN      NUMBER,
      p_parent_data_point_id    IN      NUMBER,
      p_enabled_flag        	IN      VARCHAR2,
      p_package_name        	IN      VARCHAR2,
      p_function_name       	IN      VARCHAR2,
      p_data_point_sub_category	IN      VARCHAR2,
	  p_return_data_type    	IN      VARCHAR2,
	  p_return_date_format  	IN      VARCHAR2,
	  p_last_updated_by			IN	NUMBER,
	  p_last_update_login		IN	NUMBER,
      p_data_point_code         IN  VARCHAR2) ;


PROCEDURE update_adp_row(
		 p_data_point_code		IN  VARCHAR2,
                 p_data_point_name              IN  VARCHAR2,
                 p_description	                IN  VARCHAR2,
                 p_data_point_sub_category      IN  VARCHAR2,
                 p_scorable_flag                IN  VARCHAR2,
                 p_data_point_id                IN  NUMBER,
                 p_application_id               IN  NUMBER,
                 p_parent_data_point_id         IN  NUMBER,
                 p_enabled_flag                 IN  VARCHAR2,
                 p_package_name                 IN  VARCHAR2,
                 p_function_name                IN  VARCHAR2,
		 p_function_type		IN	VARCHAR2,
		 p_return_data_type		In	VARCHAR2,
		 p_return_date_format		IN	VARCHAR2,
	  	 p_last_updated_by		IN	NUMBER,
	  	 p_last_update_login		IN	NUMBER);

procedure DELETE_ROW (
  	  p_data_point_id 		IN 	NUMBER
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  	  P_DATA_POINT_ID               IN 	NUMBER,
  	  P_DESCRIPTION                 IN 	VARCHAR2,
  	  P_DATA_POINT_NAME             IN 	VARCHAR2,
  	  P_OWNER                       IN 	VARCHAR2);


procedure LOAD_ROW
	( p_data_point_id         	IN      VARCHAR2,
      p_data_point_name	      	IN	VARCHAR2,
	  p_description		      	IN	VARCHAR2,
	  p_data_point_category	  	IN	VARCHAR2,
	  p_user_defined_flag	  	IN	VARCHAR2,
	  p_scorable_flag	      	IN	VARCHAR2,
	  p_display_on_checklist  	IN	VARCHAR2,
	  p_application_id			IN	NUMBER,
	  p_parent_data_point_id	IN	NUMBER,
	  p_enabled_flag			IN	VARCHAR2,
	  p_package_name			IN	VARCHAR2,
	  p_function_name			IN	VARCHAR2,
	  p_data_point_sub_category	IN	VARCHAR2,
	  p_return_data_type		IN	VARCHAR2,
	  p_return_date_format		IN	VARCHAR2,
	  p_created_by		      	IN	NUMBER,
	  p_last_updated_by	      	IN	NUMBER,
   	  p_last_update_login     	IN  NUMBER,
      p_data_point_code         IN  VARCHAR2
       );


procedure LOAD_ADP_ROW
	( p_data_point_code				IN		VARCHAR2,
	  p_data_point_name	      		IN		VARCHAR2,
	  p_description		      		IN		VARCHAR2,
	  p_data_point_category	  		IN		VARCHAR2,
	  p_user_defined_flag	  		IN		VARCHAR2,
	  p_scorable_flag	      		IN		VARCHAR2,
	  p_display_on_checklist  		IN		VARCHAR2,
      p_application_id      		IN      NUMBER,
      p_parent_data_point_code      IN      VARCHAR2,
      p_enabled_flag        		IN      VARCHAR2,
      p_package_name        		IN      VARCHAR2,
      p_function_name       		IN      VARCHAR2,
      p_function_type       		IN      VARCHAR2,
      p_data_point_sub_category		IN		VARCHAR2,
	  p_return_data_type			IN		VARCHAR2,
	  p_return_date_format			IN		VARCHAR2,
	  p_created_by		      		IN		NUMBER,
	  p_last_updated_by	      		IN		NUMBER,
      p_last_update_login     	IN        NUMBER
       );

procedure TRANSLATE_ADP_ROW (
  P_DATA_POINT_CODE	    IN	    VARCHAR2,
  P_DESCRIPTION             IN      VARCHAR2,
  P_DATA_POINT_NAME         IN      VARCHAR2,
  P_APPLICATION_ID			IN		NUMBER,
  P_OWNER                   IN      VARCHAR2);

END AR_CMGT_DP_TABLE_HANDLER;


 

/
