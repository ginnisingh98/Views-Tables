--------------------------------------------------------
--  DDL for Package XDP_XDP_PERF_BM_RT_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_XDP_PERF_BM_RT_U" AUTHID CURRENT_USER AS
Procedure XDP_PERF_BM_RT( 
p_order_id       IN  NUMBER,
p_line_item_id   IN  NUMBER,
p_wi_instance_id IN  NUMBER,
p_fa_instance_id IN  NUMBER,
p_fe_name        OUT VARCHAR2,
p_return_code    OUT NUMBER,
p_error_description OUT VARCHAR2)
; 
 END  XDP_XDP_PERF_BM_RT_U;

 

/
