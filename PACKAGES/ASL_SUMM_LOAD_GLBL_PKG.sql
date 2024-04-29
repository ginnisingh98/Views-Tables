--------------------------------------------------------
--  DDL for Package ASL_SUMM_LOAD_GLBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASL_SUMM_LOAD_GLBL_PKG" AUTHID CURRENT_USER AS

PROCEDURE Delete_Rows (
             p_table_name        IN  VARCHAR2
           , p_category_set_id   IN  NUMBER
	        , p_organization_id   IN  NUMBER
	        , p_category_id       IN  NUMBER
	        , x_err_msg           OUT NOCOPY VARCHAR2
	        , x_err_code          OUT NOCOPY VARCHAR2
	   );

PROCEDURE Write_Log(
  		        p_table          IN   VARCHAR2 DEFAULT NULL
            , p_action         IN   VARCHAR2 DEFAULT NULL
            , p_procedure      IN   VARCHAR2 DEFAULT NULL
            , p_num_rows       IN   NUMBER   DEFAULT 0
            , p_load_mode      IN   VARCHAR2 DEFAULT NULL
            , p_message        IN   VARCHAR2 DEFAULT NULL
            , p_start          IN   VARCHAR2 DEFAULT NULL
            , p_end            IN   VARCHAR2 DEFAULT NULL
            , p_load_year      IN   NUMBER   DEFAULT NULL
            , p_delete_mode    IN   VARCHAR2 DEFAULT NULL
		) ;

END asl_summ_load_glbl_pkg;


 

/
