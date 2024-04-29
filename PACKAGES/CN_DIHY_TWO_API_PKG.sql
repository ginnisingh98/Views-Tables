--------------------------------------------------------
--  DDL for Package CN_DIHY_TWO_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_DIHY_TWO_API_PKG" AUTHID CURRENT_USER AS
-- $Header: cndihy2s.pls 120.3 2005/12/13 01:54:43 hanaraya ship $



  PROCEDURE Insert_Edge ( X_name		IN VARCHAR2,
			  X_dim_hierarchy_id	IN NUMBER,
			  X_value_id	    IN OUT NOCOPY NUMBER,
			  X_parent_value_id	IN NUMBER,
			  X_external_id		IN NUMBER,
			  X_hierarchy_api_id    IN NUMBER,
			 --R12 MOAC Changes--Start
			X_org_id 	in NUMBER);
			--R12 MOAC Changes--End



  PROCEDURE Insert_Dimension (X_dimension_id		NUMBER,
			      X_name			VARCHAR2,
			      X_base_table_id		NUMBER,
			      X_primary_key_id		NUMBER,
			      X_user_column_name_id	NUMBER,
			      --R12 MOAC Changes--Start
				X_org_id 	 NUMBER);
				--R12 MOAC Changes--End

  PROCEDURE Cascade_Delete(X_value_id              number,
                           X_parent_value_id       number,
                           X_dim_hierarchy_id      number,
			   --R12 MOAC Changes--Start
				X_org_id 	 NUMBER);
				--R12 MOAC Changes--End



END CN_DIHY_TWO_API_PKG;
--/

-- SHOW ERRORS PACKAGE BODY CN_DIHY_TWO_API_PKG
--
-- SELECT to_date('SQLERROR')
--   FROM user_errors
--  WHERE type = 'PACKAGE BODY'
--    AND name = upper('CN_DIHY_TWO_API_PKG');


 

/
