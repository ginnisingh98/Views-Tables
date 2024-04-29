--------------------------------------------------------
--  DDL for Package WIP_EAM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EAM_UTILS" AUTHID CURRENT_USER as
/* $Header: wipeamus.pls 115.11 2003/11/21 01:19:20 baroy noship $
   $Author: baroy $ */

  -- Author  : BAROY
  -- Created : 11/13/02 12:48:31 PM
  -- Purpose : API to default the WAC
  -- Standard who


  -- Procedure to find the default wip accounting class for a work order
  -- based on pre-defined criteria
  PROCEDURE DEFAULT_ACC_CLASS(
    p_org_id          IN  NUMBER,                -- Organization Id
    p_job_type        IN  NUMBER DEFAULT 1,      -- Standard/Rebuild
    p_serial_number   IN  VARCHAR2 DEFAULT null, -- Asset Number
    p_asset_group     IN  VARCHAR2 DEFAULT null, -- Asset Group
    p_parent_wo_name  IN  VARCHAR2 DEFAULT null, -- Parent Wip Entity Id
    p_asset_activity  IN  VARCHAR2 DEFAULT null, -- Asset Activity
    p_project_number  IN  VARCHAR2 DEFAULT null, -- Project Number
    p_task_number     IN  VARCHAR2 DEFAULT null, -- Task Number
    x_class_code      OUT NOCOPY VARCHAR2,       -- WAC (return value)
    x_return_status   OUT NOCOPY VARCHAR2,       -- Return Status
    x_msg_data        OUT NOCOPY VARCHAR2        -- Error messages
  );


  -- A copy of the default_acc_class procedure. The only difference is that in
  -- this procedure, the input parameters are 'id's instead of names
  -- Procedure to find the default wip accounting class for a work order
  -- based on pre-defined criteria
  PROCEDURE DEFAULT_ACC_CLASS(
    p_org_id          IN  NUMBER,                -- Organization Id
    p_job_type        IN  NUMBER DEFAULT 1,      -- Standard/Rebuild
    p_serial_number   IN  VARCHAR2 DEFAULT null, -- Asset Number
    p_asset_group_id  IN  NUMBER DEFAULT null,   -- Asset Group
    p_parent_wo_id    IN  NUMBER DEFAULT null,   -- Parent Wip Entity Id
    p_asset_activity_id  IN  number DEFAULT null,-- Asset Activity
    p_project_id      IN  NUMBER DEFAULT null,   -- Project Number
    p_task_id         IN  NUMBER DEFAULT null,   -- Task Number
    x_class_code      OUT NOCOPY VARCHAR2,       -- WAC (return value)
    x_return_status   OUT NOCOPY VARCHAR2,       -- Return Status
    x_msg_data        OUT NOCOPY VARCHAR2        -- Error messages
  );


  -- This procedure copies over the asset attachments,
  -- asset activity attachments, activity bom attachments
  -- and activity routing attachments to the work order
  -- created by the WIP Mass Load.
  PROCEDURE copy_attachments(
    copy_asset_attachments         IN VARCHAR2, -- Copy Asset Attachments (Y/N).
    copy_activity_attachments      IN VARCHAR2, -- Copy Activity Attachments (Y/N).
    copy_activity_bom_attachments  IN VARCHAR2, -- Copy Activity BOM Attachments (Y/N).
    copy_activity_rtng_attachments IN VARCHAR2, -- Copy Activity Routing Attachments (Y/N).
    p_organization_id              IN NUMBER,   -- Org Id of the Work Order
    p_wip_entity_id                IN NUMBER,   -- Wip Ent Id of WO (created thru WML).
    p_primary_item_id              IN NUMBER,   -- Asset Activity Id of the activity.
    p_common_bom_sequence_id       IN NUMBER,   -- BOM Sequence Id for the activity
    p_common_routing_sequence_id   IN NUMBER    -- Routing Sequence Id for the Activity
  );


procedure create_default_operation
  (  p_organization_id             IN    NUMBER
    ,p_wip_entity_id               IN    NUMBER
  );


END WIP_EAM_UTILS;

 

/
