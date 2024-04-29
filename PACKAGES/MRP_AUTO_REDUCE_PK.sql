--------------------------------------------------------
--  DDL for Package MRP_AUTO_REDUCE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_AUTO_REDUCE_PK" AUTHID CURRENT_USER AS
/* $Header: MRPPARPS.pls 115.0 99/07/16 12:31:27 porting ship $'*/

PROCEDURE mrp_auto_reduce_mps(
                arg_sched_mgr       IN      NUMBER,
                arg_org_id          IN      NUMBER,
                arg_user_id         IN      NUMBER,
                arg_sched_desig     IN      VARCHAR2,
                arg_request_id      IN      NUMBER);

END MRP_AUTO_REDUCE_PK;

 

/
