--------------------------------------------------------
--  DDL for Package MRP_AP_REL_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_AP_REL_PLAN_PUB" AUTHID CURRENT_USER AS
/* $Header: MRPRELPS.pls 120.2 2007/02/05 13:36:37 rsyadav ship $ */

PROCEDURE INITIALIZE
               ( p_user_name         IN  VARCHAR2,
                 p_resp_name         IN  VARCHAR2,
                 p_application_name  IN  VARCHAR2,
                 p_wip_group_id      OUT NOCOPY NUMBER,
                 p_po_batch_number   OUT NOCOPY NUMBER);

PROCEDURE INITIALIZE
               ( p_user_name         IN  VARCHAR2,
                 p_resp_name         IN  VARCHAR2,
                 p_application_name  IN  VARCHAR2,
                 p_instance_id       IN  NUMBER,
                 p_instance_code     IN  VARCHAR2,
                 p_aps_dblink        IN  VARCHAR2,
                 p_wip_group_id      OUT NOCOPY NUMBER,
                 p_po_batch_number   OUT NOCOPY NUMBER,
                 p_application_id    IN  NUMBER);

PROCEDURE LD_WIP_JOB_SCHEDULE_INTERFACE
               ( o_request_id        OUT NOCOPY  NUMBER);

PROCEDURE LD_LOT_JOB_SCHEDULE_INTERFACE
               ( o_request_id        OUT NOCOPY  NUMBER);

PROCEDURE LD_PO_REQUISITIONS_INTERFACE
               ( p_po_group_by_name  IN  VARCHAR2,
                 o_request_id        OUT NOCOPY  NUMBER);

PROCEDURE LD_PO_RESCHEDULE_INTERFACE
               ( o_request_id        OUT NOCOPY  NUMBER);

PROCEDURE MODIFY_RESOURCE_REQUIREMENT;

PROCEDURE MODIFY_COMPONENT_REQUIREMENT;

-- PROCEDURE MODIFY_EAM_COMP_REQUIREMENT; -- dsr bug# 4524589

-- PROCEDURE MODIFY_EAM_RES_REQUIREMENT; -- dsr

/* PROCEDURE LD_EAM_RESCHEDULE_JOBS -- dsr
               ( o_request_id    OUT NOCOPY NUMBER); */

END MRP_AP_REL_PLAN_PUB;

/
