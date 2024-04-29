--------------------------------------------------------
--  DDL for Package MST_CP_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_CP_WRAPPER" AUTHID CURRENT_USER AS
/*$Header: MSTCPWPS.pls 115.1 2004/02/21 01:13:36 jnhuang noship $ */
   -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.

PROCEDURE COPY_PLAN(p_plan_id IN NUMBER,
                    p_dest_plan_name IN VARCHAR2,
                    p_dest_plan_desc IN VARCHAR2,
                    p_request_id OUT NOCOPY NUMBER);

PROCEDURE LAUNCH_PLAN(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER);

PROCEDURE REOPTIMIZE_PLAN(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER);

PROCEDURE CALCULATE_KPI(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER);

PROCEDURE CALCULATE_EXCEPTIONS(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER);

PROCEDURE CALCULATE_AUDIT_EXCEPTIONS(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER);

PROCEDURE start_online_planner(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER);

END MST_CP_WRAPPER;



 

/
