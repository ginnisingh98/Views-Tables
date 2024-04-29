--------------------------------------------------------
--  DDL for Package AHL_UMP_NONROUTINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_NONROUTINES_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVNRTS.pls 120.2.12010000.2 2010/03/24 10:30:31 ajprasan ship $ */

G_APP_NAME  CONSTANT    VARCHAR2(3)     := 'AHL';                       -- Use for all FND_MESSAGE.SET_NAME calls
G_PKG_NAME  CONSTANT    VARCHAR2(30)    := 'AHL_UMP_NONROUTINES_PVT';   -- Use for all debug messages, FND_API.COMPATIBLE_API_CALL, etc

-------------------------------
-- Define records and tables --
-------------------------------
TYPE NonRoutine_Rec_Type IS RECORD
(
    INCIDENT_ID                 NUMBER,
    INCIDENT_NUMBER             VARCHAR2(30),
    INCIDENT_OBJECT_VERSION_NUMBER      NUMBER,
    INCIDENT_DATE               DATE,
    TYPE_ID                     NUMBER,
    TYPE_NAME                   VARCHAR2(30),
    STATUS_ID                   NUMBER,
    STATUS_NAME                 VARCHAR2(30),
    SEVERITY_ID                 NUMBER,
    SEVERITY_NAME               VARCHAR2(30),
    URGENCY_ID                  NUMBER,
    URGENCY_NAME                VARCHAR2(30),
    CUSTOMER_TYPE               VARCHAR2(30),
    CUSTOMER_ID                 NUMBER,
    CUSTOMER_NUMBER             VARCHAR2(30),
    CUSTOMER_NAME               VARCHAR2(360),
    CONTACT_TYPE                VARCHAR2(30),
    CONTACT_ID                  NUMBER,
    CONTACT_NUMBER              VARCHAR2(30),
    CONTACT_NAME                VARCHAR2(360),
    INSTANCE_ID                 NUMBER,
    INSTANCE_NUMBER             VARCHAR2(30),
    PROBLEM_CODE                VARCHAR2(50),
    PROBLEM_MEANING             VARCHAR2(80),
    PROBLEM_SUMMARY             VARCHAR2(240),
    RESOLUTION_CODE             VARCHAR2(50),
    RESOLUTION_MEANING          VARCHAR2(240),
    EXPECTED_RESOLUTION_DATE    DATE,
    ACTUAL_RESOLUTION_DATE      DATE,

    UNIT_EFFECTIVITY_ID         NUMBER,
    UE_OBJECT_VERSION_NUMBER    NUMBER,
    LOG_SERIES_CODE             VARCHAR2(30),
    LOG_SERIES_MEANING          VARCHAR2(80),
    LOG_SERIES_NUMBER           NUMBER,
    FLIGHT_NUMBER               VARCHAR2(30),
    MEL_CDL_TYPE_CODE           VARCHAR2(30),
    MEL_CDL_TYPE_MEANING        VARCHAR2(80),
    POSITION_PATH_ID            NUMBER,
    ATA_CODE                    VARCHAR2(30),
    ATA_MEANING                 VARCHAR2(80),
    CLEAR_STATION_ORG_ID        NUMBER,
    CLEAR_STATION_ORG           VARCHAR2(3),
    CLEAR_STATION_DEPT_ID       NUMBER,
    CLEAR_STATION_DEPT          VARCHAR2(10),
    UNIT_CONFIG_HEADER_ID       NUMBER,
    UNIT_NAME                   VARCHAR2(80),
    INVENTORY_ITEM_ID           NUMBER,
    ITEM_NUMBER                 VARCHAR2(40),
    SERIAL_NUMBER               VARCHAR2(30),
    ATA_SEQUENCE_ID             NUMBER,
    MEL_CDL_QUAL_FLAG           VARCHAR2(1),
    --AJPRASAN::DFF Project, 18-Feb-2010, added DFF attributes to record type
    REQUEST_CONTEXT             VARCHAR2(30),
    REQUEST_ATTRIBUTE1          VARCHAR2(150),
    REQUEST_ATTRIBUTE2          VARCHAR2(150),
    REQUEST_ATTRIBUTE3          VARCHAR2(150),
    REQUEST_ATTRIBUTE4          VARCHAR2(150),
    REQUEST_ATTRIBUTE5          VARCHAR2(150),
    REQUEST_ATTRIBUTE6          VARCHAR2(150),
    REQUEST_ATTRIBUTE7          VARCHAR2(150),
    REQUEST_ATTRIBUTE8          VARCHAR2(150),
    REQUEST_ATTRIBUTE9          VARCHAR2(150),
    REQUEST_ATTRIBUTE10         VARCHAR2(150),
    REQUEST_ATTRIBUTE11         VARCHAR2(150),
    REQUEST_ATTRIBUTE12         VARCHAR2(150),
    REQUEST_ATTRIBUTE13         VARCHAR2(150),
    REQUEST_ATTRIBUTE14         VARCHAR2(150),
    REQUEST_ATTRIBUTE15         VARCHAR2(150)
);

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name      : Create_SR
--  Type                : Private
--  Description         : This procedure creates a CMRO non-routine (service request and its unit effectivity).
--  Pre-reqs            :
--
--  Standard IN  Parameters :
--      p_api_version       NUMBER                                          Required
--      p_init_msg_list     VARCHAR2    := FND_API.G_FALSE
--      p_commit            VARCHAR2    := FND_API.G_FALSE
--      p_validation_level  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--      p_default           VARCHAR2    := FND_API.G_FALSE
--      p_module_type       VARCHAR2    := NULL
--
--  Standard OUT Parameters :
--      x_return_status     VARCHAR2                                        Required
--      x_msg_count         NUMBER                                          Required
--      x_msg_data          VARCHAR2                                        Required
--
--  Procedure IN, OUT, IN/OUT params :
--      p_x_nonroutine_rec  NonRoutine_Rec_Type                             Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Create_SR
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN          VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_nonroutine_rec          IN OUT NOCOPY   NonRoutine_Rec_Type
);

--  Start of Comments  --
--
--  Procedure name      : Update_SR
--  Type                : Private
--  Description         : This procedure updates a CMRO non-routine (service request and its unit effectivity).
--  Pre-reqs            :
--
--  Standard IN  Parameters :
--      p_api_version       NUMBER                                          Required
--      p_init_msg_list     VARCHAR2    := FND_API.G_FALSE
--      p_commit            VARCHAR2    := FND_API.G_FALSE
--      p_validation_level  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--      p_default           VARCHAR2    := FND_API.G_FALSE
--      p_module_type       VARCHAR2    := NULL
--
--  Standard OUT Parameters :
--      x_return_status     VARCHAR2                                        Required
--      x_msg_count         NUMBER                                          Required
--      x_msg_data          VARCHAR2                                        Required
--
--  Procedure IN, OUT, IN/OUT params :
--      p_x_nonroutine_rec  NonRoutine_Rec_Type                             Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Update_SR
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN          VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_nonroutine_rec          IN OUT NOCOPY   NonRoutine_Rec_Type
);

--  Start of Comments  --
--
--  Procedure name      : Initiate_Mel_Cdl_Approval
--  Type                : Private
--  Description         : This procedure submits the unit effectivity of a CMRO non-routine for approval.
--  Pre-reqs            :
--
--  Standard IN  Parameters :
--      p_api_version       NUMBER                                          Required
--      p_init_msg_list     VARCHAR2    := FND_API.G_FALSE
--      p_commit            VARCHAR2    := FND_API.G_FALSE
--      p_validation_level  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--      p_default           VARCHAR2    := FND_API.G_FALSE
--      p_module_type       VARCHAR2    := NULL
--
--  Standard OUT Parameters :
--      x_return_status     VARCHAR2                                        Required
--      x_msg_count         NUMBER                                          Required
--      x_msg_data          VARCHAR2                                        Required
--
--  Procedure IN, OUT, IN/OUT params :
--      p_ue_id             NUMBER                                          Required
--      p_ue_object_version NUMBER                                          Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Initiate_Mel_Cdl_Approval
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN          VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_ue_id                     IN          NUMBER,
    p_ue_object_version         IN          NUMBER
);

-----------------------
-- Define functions --
-----------------------
--  Start of Comments  --
--
--  Function name       : Get_Mel_Cdl_Header_Id
--  Type                : Private/Public
--  Description         : This function returns the applicable MEL/CDL for a CMRO non-routine unit effectivity. It uses the
--                        unit effectivity's MEL/CDL type code, instance, unit and ata_sequence.
--  Pre-reqs            :
--
--  Function params :
--      p_unit_effectivity_id   NUMBER
--      p_csi_instance_id       NUMBER
--      p_mel_cdl_type_code     VARCHAR2    [One of p_unit_effectivity_id or (p_csi_instance_id and p_mel_cdl_type_code) is mandatory]
--
--  Return type and typical values :
--      NUMBER      The relevant MEL/CDL header id
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
FUNCTION Get_Mel_Cdl_Header_Id
(
    p_unit_effectivity_id   NUMBER,
    p_csi_instance_id       NUMBER,
    p_mel_cdl_type_code     VARCHAR2
)
RETURN NUMBER;

-----------------------
-- Define functions --
-----------------------
--  Start of Comments  --
--
--  Function name       : Get_Mel_Cdl_Status
--  Type                : Private/Public
--  Description         : This function returns the MEL/CDL status for a particular unit effectivity.
--  Pre-reqs            :
--
--  Function params :
--      p_unit_effectivity_id   NUMBER      Required
--      p_get_code              VARCHAR2    Required, Default FND_API.G_FALSE
--
--  Return type and typical values :
--      VARCHAR2      The relevant MEL/CDL status
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
FUNCTION Get_Mel_Cdl_Status
(
    p_unit_effectivity_id   NUMBER,
    p_get_code              VARCHAR2    := FND_API.G_FALSE
)
RETURN VARCHAR2;

-----------------------
-- Define functions --
-----------------------
--  Start of Comments  --
--
--  Function name       : Check_Open_NRs
--  Type                : Private
--  Description         : This procedure verifies whether there are any open non-routines for a particular
--                        MEL/CDL or Product Classification node.
--  Pre-reqs            :
--
--  Standard IN  Parameters :
--
--  Standard OUT Parameters :
--      x_return_status     VARCHAR2                                        Required
--
--  Procedure IN, OUT, IN/OUT params :
--      p_mel_cdl_header_id     NUMBER (one of p_mel_cdl_header_id or p_pc_node_id is mandatory)
--      p_pc_node_id            NUMBER (one of p_mel_cdl_header_id or p_pc_node_id is mandatory)
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Check_Open_NRs
(
    -- Standard OUT params
    x_return_status     OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_mel_cdl_header_id IN          NUMBER	DEFAULT NULL,
    p_pc_node_id        IN          NUMBER	DEFAULT NULL
);

-- Procedure to process MEL/CDL approval when called from workflow.
PROCEDURE Process_MO_procedures
(
    p_unit_effectivity_id   IN          NUMBER,
    p_unit_deferral_id      IN          NUMBER,
    p_unit_deferral_ovn     IN          NUMBER,
    p_ata_sequence_id       IN          NUMBER,
    p_cs_incident_id        IN          NUMBER,
    p_csi_item_instance_id  IN          NUMBER);


End AHL_UMP_NONROUTINES_PVT;

/
