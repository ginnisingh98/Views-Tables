--------------------------------------------------------
--  DDL for Package AHL_PRD_NONROUTINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_NONROUTINE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPNRS.pls 120.3.12010000.3 2010/03/23 10:22:53 manesing ship $ */
-----------------------------------------------------------
-- Record Types for record structures needed by the APIs --
-----------------------------------------------------------
-- Record for service record and vwp task

TYPE sr_task_rec_type IS RECORD (
  Request_date                    DATE         ,
  Type_id                             NUMBER    ,
  Type_name                           VARCHAR2(30) ,
  Status_id                           NUMBER       ,
  Status_name                     VARCHAR2(30)  ,
  Severity_id                     NUMBER        ,
  Severity_name                   VARCHAR2(30)  ,
  Urgency_id                      NUMBER        ,
  Urgency_name                    VARCHAR2(30)  ,
  Summary                             VARCHAR2(240) ,
  Customer_type                   VARCHAR2(30)  ,
  Customer_id                     NUMBER        ,
  Customer_number                 VARCHAR2(30)  ,
  Customer_name                   VARCHAR2(360) ,
  Contact_type                    VARCHAR2(30)  ,
  Contact_id                      NUMBER        ,
  Contact_number                  VARCHAR2(30)  ,
  Contact_name                    VARCHAR2(360) ,
  Instance_id                     NUMBER        ,
  Instance_number                 VARCHAR2(30)  ,
  Problem_code                    VARCHAR2(50)  ,
  Problem_meaning                     VARCHAR2(80)  ,
  Resolution_code                 VARCHAR2(50)  ,
  Resolution_meaning                      VARCHAR2(240)  ,
  Incident_id                     NUMBER       ,
  Incident_number                 VARCHAR2(30)  ,
  Incident_object_version_number  NUMBER        ,
  Visit_id                        NUMBER     ,
  Visit_number                    NUMBER     ,
  Duration                        NUMBER     ,
  Task_type_code                  VARCHAR2(30)  ,
  Visit_task_id                   NUMBER        ,
  Visit_task_number               NUMBER        ,
  Visit_task_name                 VARCHAR2(80)  ,
  Operation_type                  VARCHAR2(15)  ,
  Workflow_process_id             NUMBER        ,
  Interaction_id                  NUMBER        ,
  Originating_wo_id               NUMBER        ,
  Nonroutine_wo_id                NUMBER        ,
  source_program_code             VARCHAR2(30)  ,
  --Modified by VSUNDARA For TRANSIT CHECK ENHANCEMENT
  Object_id                       NUMBER        ,
  Object_type                     VARCHAR2(80)  ,
  link_id                         NUMBER        ,
  -- Modified for bug# 5261150 in R12.
  -- FP for ER 5716489 -- start
  WO_Create_flag                  VARCHAR2(1),
  WO_Release_flag                 VARCHAR2(1),
  -- FP for ER 5716489 -- end
  instance_quantity               NUMBER, --amsriniv . ER 6014567
  move_qty_to_nr_workorder              VARCHAR2(1), --amsriniv . ER 6014567
  -- FP Bug # 7720088 (Mexicana Bug # 7697685) -- start
  workorder_start_time            DATE,
  -- FP Bug # 7720088 (Mexicana Bug # 7697685) -- end
  -- MANESING::DFF Project, 16-Feb-2010, added attributes to record
  Attribute_Category VARCHAR2(30),
  Attribute1  VARCHAR2(150),
  Attribute2  VARCHAR2(150),
  Attribute3  VARCHAR2(150),
  Attribute4  VARCHAR2(150),
  Attribute5  VARCHAR2(150),
  Attribute6  VARCHAR2(150),
  Attribute7  VARCHAR2(150),
  Attribute8  VARCHAR2(150),
  Attribute9  VARCHAR2(150),
  Attribute10 VARCHAR2(150),
  Attribute11 VARCHAR2(150),
  Attribute12 VARCHAR2(150),
  Attribute13 VARCHAR2(150),
  Attribute14 VARCHAR2(150),
  Attribute15 VARCHAR2(150)
);

G_MISS_Sr_Task_Rec   Sr_task_rec_type;
----------------------------------------------
-- Define Table Type for Records Structures --
----------------------------------------------
--Declare Sr_Task table type for Sr_task_rec record

TYPE Sr_task_tbl_type IS TABLE OF Sr_task_rec_type INDEX BY BINARY_INTEGER;

-- MR NR ER -- Start
---------------------------------------------------------------------
-- MR details rec. Used to capture detail of MRs added to a SR
---------------------------------------------------------------------
TYPE MR_Association_Rec_Type IS RECORD (
        MR_HEADER_ID            NUMBER,
        MR_TITLE                VARCHAR2(80),
        MR_VERSION              NUMBER,
        UE_RELATIONSHIP_ID      NUMBER,         -- OUT parameter for Create Operation
        UNIT_EFFECTIVITY_ID     NUMBER,         -- OUT parameter for Create Operation
        OBJECT_VERSION_NUMBER   NUMBER,         -- OVN of Unit Effectivity, Mandatory for Delete
        RELATIONSHIP_CODE       VARCHAR2(30),   -- Always 'PARENT' or null
        CSI_INSTANCE_ID         NUMBER,         -- Instance to which the MR is associated
        CSI_INSTANCE_NUMBER     VARCHAR2(30),
        SR_TBL_INDEX            NUMBER          -- unique identifier linking MR to corresponding SR.
        );

TYPE MR_Association_tbl_type IS TABLE OF MR_Association_Rec_Type INDEX BY BINARY_INTEGER;
-- MR NR ER -- End
-- MR NR ER -- Start
-------------------------------------------------------------------
-- Declare Procedures                                            --
-------------------------------------------------------------------
--  Procedure name    : Process_nonroutine_job
--  Type              : Private
--  Function          : To Create or Update Service request based on
--                      operation_type and to create vwp task for
--                      a nonroutine job.
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Process_nonroutine_job Parameters:
--      p_x_sr_task_tbl                 IN OUT  Sr_task_tbl  Required
--        The table of records for creation / updation of Service
--        request and creation of vwp task.
--      p_x_mr_asso_tbl                 IN OUT  MR_Association_tbl_type Required
--        The table of records containing MRs to be associated to the SR.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE process_nonroutine_job (
  p_api_version          IN            NUMBER,
  p_init_msg_list        IN            VARCHAR2  := Fnd_Api.g_false,
  p_commit               IN            VARCHAR2  := Fnd_Api.g_false,
  p_validation_level     IN            NUMBER    := Fnd_Api.g_valid_level_full,
  p_module_type          IN            VARCHAR2  := 'JSP',
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_count            OUT NOCOPY    NUMBER,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_x_sr_task_tbl        IN OUT NOCOPY ahl_prd_nonroutine_pvt.sr_task_tbl_type,
  p_x_mr_asso_tbl        IN OUT NOCOPY AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type
);
-- MR NR ER -- End
END;

/
