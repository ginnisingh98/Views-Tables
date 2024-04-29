--------------------------------------------------------
--  DDL for Package Body XDP_PLSQL_FE_LOC_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_PLSQL_FE_LOC_U" AS
Procedure PLSQL_FE_LOC( 
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
p_return_code    OUT NUMBER   -- Return Code
p_error_description OUT VARCHAR2 -- Error description
*****************************************************************************/
BEGIN
p_fe_name := 'PLSQL_FE';
p_return_code := 0;
END;
    
xdp_macros.EndProc(p_return_code, p_error_description);
exception 
when others then 
    xdp_macros.HandleProcErrors(p_return_code,p_error_description); 
end PLSQL_FE_LOC ;
 END  XDP_PLSQL_FE_LOC_U;

/
