--------------------------------------------------------
--  DDL for Package WMS_RULE_PVT_EXT_PSETJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_PVT_EXT_PSETJ" AUTHID CURRENT_USER as
/* $Header: WMSOPPAS.pls 115.2 2003/08/25 19:06:13 joabraha noship $ */
--
-- API name    : Assign_operation_plan
-- Type        : Private
-- Function    : Assign operation_plan to a specific record in MMTT
-- Input Parameters  :
--           p_task_id NUMBER
--
-- Output Parameters:
-- Version     :
-- Current version 1.0
--
-- Notes       :
-- Date           Modification                                   Author
-- ------------   ------------                                   ------------------
-- 08 Aug. 2003   Added 2 new input parameters in patchset 'J'.  By Johnson Abraham.
--                p_activity_type_id and p_organization_id.
--                For Inbound ATF, the  p_activity_type_id
--                will be passed in as a mandatory input
--                parameter.
--                The call to Outbound ATF will continue
--                via the wrapper 'assign_operation_plans'.
--                The change to the wrapper is that now
--                organization_id is also derived and hence
--                passed in to the 'assign_operation_plans'.
PROCEDURE assign_operation_plan_psetj(
   p_api_version                  IN   NUMBER,
   p_init_msg_list                IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                       IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_validation_level             IN   NUMBER   DEFAULT fnd_api.g_valid_level_full,
   x_return_status                OUT  NOCOPY VARCHAR2,
   x_msg_count                    OUT  NOCOPY NUMBER,
   x_msg_data                     OUT  NOCOPY VARCHAR2,
   p_task_id                      IN   NUMBER,
   p_activity_type_id             IN   NUMBER   DEFAULT NULL,     -- Added in patchset 'J' for the ATF Inbound project.
   p_organization_id		  IN   NUMBER   DEFAULT NULL);    -- Added in patchset 'J' for the ATF Inbound project.
--
--

end wms_rule_pvt_ext_psetj;

 

/
