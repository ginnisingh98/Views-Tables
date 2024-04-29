--------------------------------------------------------
--  DDL for Package XDP_PLSQL_FE_LOC_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_PLSQL_FE_LOC_U" AUTHID CURRENT_USER AS
Procedure PLSQL_FE_LOC( 
p_order_id       IN  NUMBER,
p_line_item_id   IN  NUMBER,
p_wi_instance_id IN  NUMBER,
p_fa_instance_id IN  NUMBER,
p_fe_name        OUT VARCHAR2,
p_return_code    OUT NUMBER,
p_error_description OUT VARCHAR2)
; 
 END  XDP_PLSQL_FE_LOC_U;

 

/
