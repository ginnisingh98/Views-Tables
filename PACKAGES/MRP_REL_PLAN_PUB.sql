--------------------------------------------------------
--  DDL for Package MRP_REL_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_REL_PLAN_PUB" AUTHID CURRENT_USER AS
/* $Header: MRPPRELS.pls 115.11 2002/11/22 21:49:07 schaudha ship $ */

--  Start of Comments
--  API name    MRP_Release_Plan_Sc
--  Type        Public
--  Procedure
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE MRP_RELEASE_PLAN_SC
(  arg_log_org_id		IN 	NUMBER
,  arg_org_id 			IN 	NUMBER
,  arg_compile_desig	    	IN 	VARCHAR2
,  arg_user_id 			IN	NUMBER
,  arg_po_group_by 		IN 	NUMBER
,  arg_po_batch_number		IN 	NUMBER
,  arg_wip_group_id 		IN 	NUMBER
,  arg_loaded_jobs 		IN OUT NOCOPY 	NUMBER
,  arg_loaded_reqs 		IN OUT NOCOPY  NUMBER
,  arg_loaded_scheds 		IN OUT NOCOPY  NUMBER
,  arg_resched_jobs 		IN OUT NOCOPY  NUMBER
,  arg_resched_reqs 		IN OUT NOCOPY  NUMBER
,  arg_wip_req_id  		IN OUT NOCOPY  NUMBER
,  arg_req_load_id 		IN OUT NOCOPY  NUMBER
,  arg_req_resched_id 		IN OUT NOCOPY  NUMBER
,  arg_mode                     IN      VARCHAR2 DEFAULT NULL
,  arg_transaction_id           IN      NUMBER DEFAULT NULL
);

/** Bug#1519701 : Added a new function get_dock_date **/

FUNCTION GET_DOCK_DATE
( arg_compile_desig IN VARCHAR2
, arg_plan_owning_org  IN      NUMBER /*2448572*/
, arg_calendar_exception_set_id	IN 	NUMBER
, arg_calendar_code  IN VARCHAR2
, arg_implement_date IN DATE
, arg_vendor_id IN NUMBER
, arg_vendor_site_id IN NUMBER
, arg_item_id IN NUMBER
, arg_lead_time NUMBER
) RETURN DATE;

END MRP_Rel_Plan_PUB;

 

/
