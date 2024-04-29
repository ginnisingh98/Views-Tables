--------------------------------------------------------
--  DDL for Package XDP_XDP_PERF_BM_FP_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_XDP_PERF_BM_FP_U" AUTHID CURRENT_USER AS
Procedure XDP_PERF_BM_FP( 
p_order_id       IN  NUMBER,
p_line_item_id   IN  NUMBER,
p_wi_instance_id IN  NUMBER,
p_fa_instance_id IN  NUMBER,
p_channel_name   IN  VARCHAR2,
p_fe_name        IN VARCHAR2,
p_fa_item_type   IN VARCHAR2,
p_fa_item_key    IN VARCHAR2,
p_return_code    OUT NUMBER,
p_error_description OUT VARCHAR2)
; 
 END  XDP_XDP_PERF_BM_FP_U;

 

/
