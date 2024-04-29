--------------------------------------------------------
--  DDL for Package Body XDP_XDP_PERF_BM_FP_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_XDP_PERF_BM_FP_U" AS
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
is 
order_id NUMBER := p_order_id;
line_item_id NUMBER := p_line_item_id;
workitem_instance_id NUMBER := p_wi_instance_id;
fa_instance_id NUMBER := p_fa_instance_id;
db_channel_name VARCHAR2(40) := p_channel_name;
fe_name VARCHAR2(80) := p_fe_name;
fa_item_type VARCHAR2(8) := p_fa_item_type;
fa_item_key VARCHAR2(240) := p_fa_item_key;
LOG VARCHAR2(1) := 'N';
NOLOG VARCHAR2(1) := 'Y';
RETRY number := 1;
NORETRY number := 0;
fa_item_key VARCHAR2(240) := p_fa_item_key;
sdp_internal_response VARCHAR2(32767);
sdp_internal_err_code VARCHAR2(40) := p_return_code;
sdp_internal_err_str VARCHAR2(40) := p_error_description;
begin
/*****************************************************************************
p_order_id       IN  NUMBER,
p_line_item_id   IN  NUMBER,
p_wi_instance_id IN  NUMBER,
p_fa_instance_id IN  NUMBER,
p_channel_name   IN  VARCHAR2,
p_fe_name        IN VARCHAR2,
p_fa_item_type   IN VARCHAR2,
p_fa_item_key    IN VARCHAR2,
p_return_code    OUT NUMBER,
p_error_description OUT VARCHAR2
*****************************************************************************/
xdp_macros.initfp(p_order_id, p_line_item_id, p_wi_instance_id, p_fa_instance_id, p_channel_name, p_fe_name, 'XDP_PERF_BM_FP');
declare 
 /*****************************************************************************
This procedure is called by the FA to provision a FE for a particular service.
It has the following input parameters and no output parameters:       
order_id 	 IN  NUMBER   -- order ID          
line_item_id     IN NUMBER -- Line Item ID
workitem_instance_id IN  NUMBER   -- workitem instance ID 
fa_instance_id IN  NUMBER   -- FA instance ID   
db_channel_name	 IN  VARCHAR2 -- Channel name used by this procedure
fe_name	 IN  VARCHAR2 -- FE name to be provisioned by this procedure
fa_item_type   IN  VARCHAR2 -- FA workflow process item type
fa_item_key    IN  VARCHAR2 -- FA workflow process item key      
*****************************************************************************/
-- Enter your procedure below:
BEGIN
-- your code...
null;
END;
    
xdp_macros.EndProc(p_return_code, p_error_description);
exception 
when others then 
    xdp_macros.HandleProcErrors(p_return_code,p_error_description); 
end XDP_PERF_BM_FP ;
 END  XDP_XDP_PERF_BM_FP_U;

/
