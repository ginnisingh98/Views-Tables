--------------------------------------------------------
--  DDL for Package Body XDP_XDP_PERF_BM_RT_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_XDP_PERF_BM_RT_U" AS
Procedure XDP_PERF_BM_RT( 
p_order_id       IN  NUMBER,
p_line_item_id   IN  NUMBER,
p_wi_instance_id IN  NUMBER,
p_fa_instance_id IN  NUMBER,
p_fe_name        OUT VARCHAR2,
p_return_code    OUT NUMBER,
p_error_description OUT VARCHAR2)
is 
begin
/*****************************************************************************
p_order_id       IN  NUMBER,
p_line_item_id   IN  NUMBER,
p_wi_instance_id IN  NUMBER,
p_fa_instance_id IN  NUMBER,
p_fe_name        OUT VARCHAR2,
p_return_code    OUT NUMBER,
p_error_description OUT VARCHAR2
*****************************************************************************/
xdp_macros.initdefault(p_order_id, p_line_item_id, p_wi_instance_id, p_fa_instance_id);
declare 
  /*****************************************************************************
This procedure returns the Fulfillment Element (FE) name of the FE
that is to be provisioned by this Fulfillment Action (FA).
It has the following input and output parameters:       
p_order_id 	 IN  NUMBER   -- order ID          
p_wi_instance_id IN  NUMBER   -- workitem instance ID 
p_fa_instance_id IN  NUMBER   -- FA instance ID   
p_fe_name        OUT VARCHAR2 -- FE to be provisioned           
*****************************************************************************/
-- Enter your procedure below:
BEGIN
-- your code...
p_fe_name := 'XDP_PERF_BM_NULL_FE';
END;
    
xdp_macros.EndProc(p_return_code, p_error_description);
exception 
when others then 
    xdp_macros.HandleProcErrors(p_return_code,p_error_description); 
end XDP_PERF_BM_RT ;
 END  XDP_XDP_PERF_BM_RT_U;

/
