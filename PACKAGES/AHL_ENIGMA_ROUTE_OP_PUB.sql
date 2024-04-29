--------------------------------------------------------
--  DDL for Package AHL_ENIGMA_ROUTE_OP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_ENIGMA_ROUTE_OP_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPEROS.pls 120.0.12010000.1 2008/11/24 09:17:27 bachandr noship $ */

TYPE enigma_route_rec_type IS RECORD
(
ROUTE_ID               VARCHAR2(2000),
STATUS                 VARCHAR2(30),
ATA_CODE               VARCHAR2(30),
DESCRIPTION            VARCHAR2(2000),
REVISION_DATE          DATE,
ENIGMA_ID              VARCHAR2(2000),
CHANGE_FLAG            VARCHAR2(1),
PDF                    VARCHAR2(100)
);

TYPE enigma_op_rec_type IS RECORD
(
OPERATION_ID      VARCHAR2(2000),
STATUS            VARCHAR2(30),
ATA_CODE          VARCHAR2(30),
DESCRIPTION       VARCHAR2(2000),
PARENT_ROUTE_ID   VARCHAR2(2000),
ENIGMA_ID         VARCHAR2(2000),
CHANGE_FLAG       VARCHAR2(1)
);

TYPE enigma_op_tbl_type IS TABLE OF enigma_op_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE Process_Route_Operations
   (
        p_api_version          IN               NUMBER        := 1.0,
        p_init_msg_list        IN               VARCHAR2      := FND_API.G_FALSE,
        p_commit               IN               VARCHAR2      := FND_API.G_FALSE,
        p_validation_level     IN               NUMBER        := FND_API.G_VALID_LEVEL_FULL,
        p_module_type          IN               VARCHAR2,
        p_context              IN               VARCHAR2,
        p_pub_date             IN               DATE,
        p_enigma_route_rec     IN               enigma_route_rec_type,
        p_enigma_op_tbl        IN               enigma_op_tbl_type,
        x_return_status        OUT    NOCOPY    VARCHAR2,
        x_msg_count            OUT    NOCOPY    NUMBER,
        x_msg_data             OUT    NOCOPY    VARCHAR2
   );

END AHL_ENIGMA_ROUTE_OP_PUB;

/
