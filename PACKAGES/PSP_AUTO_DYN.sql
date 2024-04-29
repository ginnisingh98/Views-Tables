--------------------------------------------------------
--  DDL for Package PSP_AUTO_DYN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_AUTO_DYN" AUTHID CURRENT_USER AS
--$Header: PSPAUDYS.pls 120.0 2005/06/02 15:43:24 appldev noship $

--------------------------------------------------------------------
--	PROCEDURE CREATE_DYN_DATA		-------------------
--------------------------------------------------------------------

PROCEDURE create_dyn_data(p_parameter_class	IN 	VARCHAR2,
			  p_parameter		IN	VARCHAR2,
			  p_appl_column_name	IN	VARCHAR2,
			  p_dff_col_name	IN	VARCHAR2,
			  p_dff_context_code    IN      VARCHAR2, -- Introduced for bug 4303976
			  p_flex_val_set_id	IN	NUMBER,
			  p_dyn_sql_stmt	OUT NOCOPY	VARCHAR2,
			  p_bind_var		OUT NOCOPY	VARCHAR2,
			  p_validation_type 	OUT NOCOPY	VARCHAR2,
			  p_param_value_set	OUT NOCOPY	VARCHAR2);

PROCEDURE type_table_flex_code(	p_parameter_class 	IN  VARCHAR2,
				p_type			OUT NOCOPY VARCHAR2,
				p_table_name		OUT NOCOPY VARCHAR2,
				p_flex_code		OUT NOCOPY VARCHAR2);

PROCEDURE get_flexfield_parameters( p_type 		IN VARCHAR2,
				    p_table_name 	IN VARCHAR2,
				    p_flex_code 	IN VARCHAR,
				    p_parameter 	IN VARCHAR2,
				    p_datatype 		IN VARCHAR2,
				    p_business_group_id IN NUMBER,
				    p_appl_column_name 	OUT NOCOPY VARCHAR2,
				    p_dff_col_name 	OUT NOCOPY VARCHAR2,
				    p_flex_val_set_id 	OUT NOCOPY NUMBER);

END psp_auto_dyn; -- End package

 

/
