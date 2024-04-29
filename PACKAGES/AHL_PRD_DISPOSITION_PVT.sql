--------------------------------------------------------
--  DDL for Package AHL_PRD_DISPOSITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_DISPOSITION_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVDISS.pls 120.2.12010000.2 2008/12/09 01:41:07 jaramana ship $ */

  G_OP_CREATE        CONSTANT  VARCHAR(1) := 'C';
  G_OP_UPDATE        CONSTANT  VARCHAR(1) := 'U';
  G_OP_DELETE        CONSTANT  VARCHAR(1) := 'D';

  --YES NO FLAGS
  G_NO_FLAG           CONSTANT VARCHAR2(1)  := 'N';
  G_YES_FLAG          CONSTANT VARCHAR2(1)  := 'Y';




TYPE disposition_rec_type IS RECORD (
    DISPOSITION_ID	             NUMBER,
    OPERATION_FLAG              VARCHAR2(1),
    OBJECT_VERSION_NUMBER        NUMBER,
    LAST_UPDATE_DATE             DATE,
    LAST_UPDATED_BY              NUMBER,
    CREATION_DATE                DATE,
    CREATED_BY                   NUMBER,
    LAST_UPDATE_LOGIN            NUMBER,
    WORKORDER_ID	             NUMBER,
    PART_CHANGE_ID	             NUMBER,
    PATH_POSITION_ID	         NUMBER,
    INVENTORY_ITEM_ID	         NUMBER,
    ITEM_ORG_ID		             NUMBER,
    ITEM_GROUP_ID	             NUMBER,
    CONDITION_ID	             NUMBER,
    INSTANCE_ID	                 NUMBER,
    COLLECTION_ID	             NUMBER,
    PRIMARY_SERVICE_REQUEST_ID	 NUMBER,
    NON_ROUTINE_WORKORDER_ID	 NUMBER,
    WO_OPERATION_ID              NUMBER,
    ITEM_REVISION                VARCHAR(3),
    SERIAL_NUMBER	             VARCHAR2(30),
    LOT_NUMBER	                 MTL_LOT_NUMBERS.LOT_NUMBER%TYPE,
    IMMEDIATE_DISPOSITION_CODE	 VARCHAR2(30),
    SECONDARY_DISPOSITION_CODE	 VARCHAR2(30),
    STATUS_CODE	                 VARCHAR2(30),
    QUANTITY	                 NUMBER,
    UOM	                         VARCHAR2(3),
    COMMENTS	                 VARCHAR2(2000),
    SEVERITY_ID	                 NUMBER,
    PROBLEM_CODE	             VARCHAR(50),
    SUMMARY	                     VARCHAR(240),
    DURATION                     NUMBER,     -- For Service Request
    -- Following option added by jaramana on October 9, 2007 for ER 5903318
    CREATE_WORK_ORDER_OPTION     VARCHAR2(30),
    IMMEDIATE_DISPOSITION	     VARCHAR(150),
    SECONDARY_DISPOSITION	     VARCHAR(150),
    CONDITION_MEANING	         VARCHAR(150),
    INSTANCE_NUMBER	             VARCHAR(30),
    ITEM_NUMBER	                 VARCHAR(40),
    ITEM_GROUP_NAME	             VARCHAR(80),
    DISPOSITION_STATUS	         VARCHAR(80),
    SEVERITY_NAME                VARCHAR2(30),
    PROBLEM_MEANING				 VARCHAR2(80),
    OPERATION_SEQUENCE           NUMBER,
    -- Following two attributes added by jaramana on 18-NOV-2008 for bug 7566597
    RESOLUTION_CODE              VARCHAR2(30),
    RESOLUTION_MEANING           VARCHAR2(80),
    SECURITY_GROUP_ID            NUMBER,
    ATTRIBUTE_CATEGORY           VARCHAR2(30),
    ATTRIBUTE1                   VARCHAR2(150),
    ATTRIBUTE2                   VARCHAR2(150),
    ATTRIBUTE3                   VARCHAR2(150),
    ATTRIBUTE4                   VARCHAR2(150),
    ATTRIBUTE5                   VARCHAR2(150),
    ATTRIBUTE6                   VARCHAR2(150),
    ATTRIBUTE7                   VARCHAR2(150),
    ATTRIBUTE8                   VARCHAR2(150),
    ATTRIBUTE9                   VARCHAR2(150),
    ATTRIBUTE10                  VARCHAR2(150),
    ATTRIBUTE11                  VARCHAR2(150),
    ATTRIBUTE12                  VARCHAR2(150),
    ATTRIBUTE13                  VARCHAR2(150),
    ATTRIBUTE14                  VARCHAR2(150),
    ATTRIBUTE15                  VARCHAR2(150)
);

TYPE Disposition_Tbl_Type IS TABLE OF Disposition_Rec_Type
   INDEX BY BINARY_INTEGER;
------------------------
-- Declare Procedures --
------------------------

-- Start of Comments  --
-- Define procedure CREATE_JOB_DISPOSITIONS
--
-- Procedure name: CREATE_JOB_DISPOSITIONS
-- Type:           Private
-- Function:       To get all default dispositions for a job from its related route and then put
-- them into the dispostion entity.
-- Pre-reqs:
--
-- Parameters:
--   p_workorder_id  IN NUMBER  Required
-- Version: Initial Version   1.0
--
-- End of Comments  --
PROCEDURE create_job_dispositions(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_workorder_id          IN  NUMBER);


-- Start of Comments --
--  Procedure name    : process_disposition
--  Type              : Private
--  Function          : create or update a disposition based on the input diposition record.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--
--      This parameter indicates the front-end form interface. The default value is 'JSP'. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values based
--      on which the Id's are populated.
--
--  process_disposition Parameters:
--
--       p_x_disposition_rec         IN OUT NOCOPY  AHL_PRD_DISPOSITION_PVT.disposition_rec_type    Required
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE process_disposition(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    p_x_disposition_rec     IN OUT NOCOPY  AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
    -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
    p_mr_asso_tbl           IN             AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2);

--------------------------
End AHL_PRD_DISPOSITION_PVT;
----------------------------------------------

/
