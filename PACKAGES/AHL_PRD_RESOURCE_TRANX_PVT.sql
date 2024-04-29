--------------------------------------------------------
--  DDL for Package AHL_PRD_RESOURCE_TRANX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_RESOURCE_TRANX_PVT" AUTHID CURRENT_USER AS
 /* $Header: AHLVTRSS.pls 120.5 2006/01/19 16:46:02 sikumar noship $ */
TYPE PRD_RESOURCE_TXNS_REC IS RECORD
(
WORKORDER_ID            NUMBER,
WORKORDER_OPERATION_ID  NUMBER,
OPERATION_RESOURCE_ID   NUMBER,
ORGANIZATION_ID         NUMBER,
OPERATION_SEQUENCE_NUM  NUMBER,
RESOURCE_SEQUENCE_NUM   NUMBER,
RESOURCE_NAME           VARCHAR2(240),
RESOURCE_ID             NUMBER,
EMPLOYEE_NUM            VARCHAR2(30),
EMPLOYEE_NAME           VARCHAR2(240),
PERSON_ID               NUMBER,
DEPARTMENT_CODE         VARCHAR2(80),
DEPARTMENT_ID           NUMBER,
SERIAL_NUMBER           VARCHAR2(30),
INSTANCE_ID             NUMBER,
QTY                     NUMBER,
UOM_CODE                VARCHAR2(30),
UOM_MEANING             VARCHAR2(80),
ACTIVITY_MEANING        VARCHAR2(80),
ACTIVITY_ID             NUMBER,
REASON_ID               NUMBER,
REASON                  VARCHAR2(80),
REFERENCE               VARCHAR2(30),
DML_OPERATION           VARCHAR2(1),
RESOURCE_TYPE_CODE      VARCHAR2(30),
RESOURCE_TYPE_NAME      VARCHAR2(80),
DEPARTMENT_NAME         VARCHAR2(240),
TRANSACTION_DATE        DATE,
END_DATE                DATE
);

TYPE PRD_RESOURCE_TXNS_TBL IS TABLE OF PRD_RESOURCE_TXNS_REC INDEX BY BINARY_INTEGER;


--ADDED BY VSUNDARA FOR TRANSIT CHECK ENHANCEMENTS
TYPE PRD_MYWORKORDER_TXNS_REC IS RECORD
(
WORKORDER_ID            NUMBER,
WORKORDER_OPERATION_ID  NUMBER,
ASSIGNMENT_ID           NUMBER,
RESOURCE_SEQUENCE        NUMBER,
OPERATION_SEQUENCE  NUMBER ,
EMPLOYEE_ID  NUMBER ,
TOTAL_TRANSACTED_HOURS    NUMBER,
TRANSACTED_HOURS         NUMBER,
DML_OPERATION           VARCHAR2(1),
OBJECT_VERSION_NUMBER   NUMBER,
OP_OBJECT_VERSION_NUMBER NUMBER ,
OPERATION_COMPLETE      VARCHAR2(1)
);

TYPE PRD_MYWORKORDER_TXNS_TBL IS TABLE OF PRD_MYWORKORDER_TXNS_REC INDEX BY BINARY_INTEGER;



PROCEDURE PROCESS_RESOURCE_TXNS
(
 p_api_version                  IN  	NUMBER     := 1.0,
 p_init_msg_list                IN  	VARCHAR2   := FND_API.G_TRUE,
 p_commit                       IN  	VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  	NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN 	VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN 	VARCHAR2   := NULL,
 x_return_status                OUT NOCOPY   VARCHAR2,
 x_msg_count                    OUT NOCOPY   NUMBER,
 x_msg_data                     OUT NOCOPY   VARCHAR2,
 p_x_prd_resrc_txn_tbl          IN OUT  NOCOPY  PRD_RESOURCE_TXNS_TBL
);

PROCEDURE PROCESS_MYWORKORDER_TXNS
(
 p_api_version                  IN  	NUMBER     := 1.0,
 p_init_msg_list                IN  	VARCHAR2   := FND_API.G_TRUE,
 p_commit                       IN  	VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  	NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN 	VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN 	VARCHAR2   := NULL,
 x_return_status                OUT NOCOPY   VARCHAR2,
 x_msg_count                    OUT NOCOPY   NUMBER,
 x_msg_data                     OUT NOCOPY   VARCHAR2,
 p_x_prd_myworkorder_txn_tbl    IN OUT NOCOPY   PRD_MYWORKORDER_TXNS_TBL
);


FUNCTION Get_transacted_hours
(
    p_wip_entity_id  IN  NUMBER,
    p_operation_seq_num IN NUMBER,
    p_resource_seq_num IN NUMBER,
    p_employee_id IN NUMBER
)  RETURN NUMBER;

/*
-- NAME
--     PROCEDURE: Get_Resource_Txn_Defaults
-- PARAMETERS
-- Standard IN Parameters
--  p_api_version                  IN 	NUMBER     := 1.0
--  p_init_msg_list                IN 	VARCHAR2   := FND_API.G_TRUE
--  p_module_type                  IN 	VARCHAR2   := NULL
--
-- Standard OUT Parameters
--  x_return_status    OUT NOCOPY VARCHAR2
--  x_msg_count        OUT NOCOPY   NUMBER
--  x_msg_data         OUT NOCOPY   VARCHAR2
--
-- Get_Resource_Txn_Defaults Parameters
--  p_employee_id			IN  	NUMBER
--  p_workorder_id			IN  	NUMBER
--  p_operation_seq_num		IN	NUMBER
--  p_function_name	         	IN	VARCHAR2 - The function name identifying the type of user
--  x_resource_txn_tbl                 OUT  NOCOPY  PRD_RESOURCE_TXNS_TBL
--
-- DESCRIPTION
-- 	This procedure is used to retrieve the default resource transactions based on the user/function name
--
-- HISTORY
--   16-Jun-2005   rroy  Created
--*/

PROCEDURE Get_Resource_Txn_Defaults
(
 p_api_version                  IN  	NUMBER     := 1.0,
 p_init_msg_list                IN  	VARCHAR2   := FND_API.G_TRUE,
 p_module_type                  IN 	VARCHAR2   := NULL,
 x_return_status                OUT NOCOPY   VARCHAR2,
 x_msg_count                    OUT NOCOPY   NUMBER,
 x_msg_data                     OUT NOCOPY   VARCHAR2,
 p_employee_id			IN  	NUMBER,
 p_workorder_id			IN  	NUMBER,
 p_operation_seq_num		IN	NUMBER,
 p_function_name 	        IN	VARCHAR2,
 x_resource_txn_tbl            OUT  NOCOPY  PRD_RESOURCE_TXNS_TBL
);

END  AHL_PRD_RESOURCE_TRANX_PVT;

 

/
