--------------------------------------------------------
--  DDL for Package AHL_FMP_MR_INTERVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_MR_INTERVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMITS.pls 120.1.12010000.2 2009/08/23 02:10:29 bachandr ship $ */

TYPE threshold_rec_type IS RECORD
(
        MR_EFFECTIVITY_ID                NUMBER,
        OBJECT_VERSION_NUMBER            NUMBER,
        THRESHOLD_DATE                   DATE,
        PROGRAM_DURATION                 NUMBER,
        PROGRAM_DURATION_UOM_CODE        VARCHAR2(30)
);

TYPE interval_rec_type IS RECORD
(
        MR_INTERVAL_ID                   NUMBER,
        OBJECT_VERSION_NUMBER            NUMBER,
        COUNTER_ID                       NUMBER,
        COUNTER_NAME                     VARCHAR2(30),
        INTERVAL_VALUE                   NUMBER,
        EARLIEST_DUE_VALUE               NUMBER,
        START_VALUE                      NUMBER,
        STOP_VALUE                       NUMBER,
        START_DATE                       DATE,
        STOP_DATE                        DATE,
        TOLERANCE_BEFORE                 NUMBER,
        TOLERANCE_AFTER                  NUMBER,
        RESET_VALUE                      NUMBER,
        ATTRIBUTE_CATEGORY               VARCHAR2(30),
        ATTRIBUTE1                       VARCHAR2(150),
        ATTRIBUTE2                       VARCHAR2(150),
        ATTRIBUTE3                       VARCHAR2(150),
        ATTRIBUTE4                       VARCHAR2(150),
        ATTRIBUTE5                       VARCHAR2(150),
        ATTRIBUTE6                       VARCHAR2(150),
        ATTRIBUTE7                       VARCHAR2(150),
        ATTRIBUTE8                       VARCHAR2(150),
        ATTRIBUTE9                       VARCHAR2(150),
        ATTRIBUTE10                      VARCHAR2(150),
        ATTRIBUTE11                      VARCHAR2(150),
        ATTRIBUTE12                      VARCHAR2(150),
        ATTRIBUTE13                      VARCHAR2(150),
        ATTRIBUTE14                      VARCHAR2(150),
        ATTRIBUTE15                      VARCHAR2(150),
        LAST_UPDATE_DATE                 DATE,
        LAST_UPDATED_BY                  NUMBER(15),
        CREATION_DATE                    DATE,
        CREATED_BY                       NUMBER(15),
        LAST_UPDATE_LOGIN                NUMBER(15),
        DML_OPERATION                    VARCHAR2(1),
	--pdoki added for ADAT ER
	DUEDATE_RULE_CODE                VARCHAR2(30),
        DUEDATE_RULE_MEANING             VARCHAR2(80)
);

TYPE interval_tbl_type IS TABLE OF interval_rec_type INDEX BY BINARY_INTEGER;

-- Start of Comments
-- Procedure name              : process_interval
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      p_api_version               NUMBER   Required
--      p_init_msg_list             VARCHAR2 Default  FND_API.G_FALSE
--      p_commit                    VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level          NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                   VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type               VARCHAR2 Default  NULL
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2 Required
--      x_msg_count                 NUMBER   Required
--      x_msg_data                  VARCHAR2 Required
--
-- process_interval IN parameters:
--      p_mr_header_id              NUMBER   Required
--
-- process_interval IN OUT parameters:
--      p_x_interval_tbl            interval_tbl_type  Required
--      p_x_threshold_rec           threshold_rec_type Required
--
-- process_interval OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE process_interval
(
 p_api_version        IN             NUMBER     := '1.0',
 p_init_msg_list      IN             VARCHAR2   := FND_API.G_TRUE,
 p_commit             IN             VARCHAR2   := FND_API.G_FALSE,
 p_validation_level   IN             NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default            IN             VARCHAR2   := FND_API.G_FALSE,
 p_module_type        IN             VARCHAR2   := NULL,
 x_return_status      OUT NOCOPY     VARCHAR2,
 x_msg_count          OUT NOCOPY     NUMBER,
 x_msg_data           OUT NOCOPY     VARCHAR2,
 p_x_interval_tbl     IN OUT NOCOPY  interval_tbl_type,
 p_x_threshold_rec    IN OUT NOCOPY  threshold_rec_type,
 p_mr_header_id       IN             NUMBER,
 p_super_user         IN             VARCHAR2
);

END AHL_FMP_MR_INTERVAL_PVT;

/
