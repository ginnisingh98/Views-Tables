--------------------------------------------------------
--  DDL for Package AR_CMGT_DNB_TABLE_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_DNB_TABLE_HANDLER" AUTHID CURRENT_USER AS
/* $Header: ARCMDNTS.pls 120.0 2005/07/26 22:53:39 bsarkar noship $ */
procedure INSERT_ROW
	( p_data_element_name		    IN		VARCHAR2,
	  p_scorable_flag		        IN		VARCHAR2,
      p_source_table_name           IN      VARCHAR2,
      p_source_column_name          IN      VARCHAR2,
	  p_created_by			        IN		NUMBER,
	  p_last_updated_by		        IN		NUMBER,
	  p_last_update_login			IN		NUMBER,
	  p_data_element_id		      	IN   	NUMBER,
	  p_application_id			 	IN		NUMBER,
	  p_return_data_type		 	IN		VARCHAR2,
      p_return_date_format		 	IN		VARCHAR2
      ) ;
procedure UPDATE_ROW
	( p_data_element_id           IN      NUMBER,
      p_data_element_name	       	IN		VARCHAR2,
	  p_scorable_flag		    IN		VARCHAR2,
      p_source_table_name       IN      VARCHAR2,
      p_source_column_name      IN      VARCHAR2,
	  p_last_updated_by		    IN		NUMBER,
	  p_last_update_login		IN		NUMBER,
	  p_application_id			 IN		NUMBER,
	  p_return_data_type		 	IN		VARCHAR2,
      p_return_date_format		 	IN		VARCHAR2);

procedure DELETE_ROW (
  p_data_element_id in NUMBER
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  P_data_element_id           IN      NUMBER,
  P_data_element_name         IN      VARCHAR2,
  P_OWNER                   IN      VARCHAR2);

procedure LOAD_ROW
	( p_data_element_id          IN     VARCHAR2,
      p_data_element_name	     IN		VARCHAR2,
	  p_scorable_flag	         IN		VARCHAR2,
      p_source_table_name        IN     VARCHAR2,
      p_source_column_name       IN     VARCHAR2,
	  p_created_by		         IN		NUMBER,
	  p_last_updated_by	         IN		NUMBER,
      p_last_update_login        IN     NUMBER,
      p_application_id			 IN		NUMBER,
      p_return_data_type		 IN		VARCHAR2,
      p_return_date_format		 IN		VARCHAR2
       ) ;

END AR_CMGT_DNB_TABLE_HANDLER;

 

/
