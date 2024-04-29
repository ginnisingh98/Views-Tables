--------------------------------------------------------
--  DDL for Package AHL_RM_RT_OPER_PANEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RM_RT_OPER_PANEL_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVRAPS.pls 120.0.12000000.1 2007/10/17 13:25:41 adivenka noship $ */

TYPE rt_oper_panel_rec_type IS RECORD
(
        RT_OPER_PANEL_ID                 NUMBER,
        OBJECT_VERSION_NUMBER            NUMBER,
        LAST_UPDATE_DATE                 DATE,
        LAST_UPDATED_BY                  NUMBER(15),
        CREATION_DATE                    DATE,
        CREATED_BY                       NUMBER(15),
        LAST_UPDATE_LOGIN                NUMBER(15),

        PANEL_TYPE_ID                    VARCHAR2(80),
        PANEL_TYPE                       VARCHAR2(80),


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
        DML_OPERATION                    VARCHAR2(1)
);

TYPE rt_oper_panel_tbl_type IS TABLE OF rt_oper_panel_rec_type INDEX BY BINARY_INTEGER;




-- Start of Comments
-- Procedure name              : process_rt_oper_panel
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
-- process_rt_oper_panel IN parameters:
--      p_association_type_code     VARCHAR2 Required
--      p_object_id                 NUMBER   Required
--
-- process_rt_oper_panel IN OUT parameters:
--      p_x_rt_oper_panel_tbl         rt_oper_panel_tbl_type Required
--
-- process_rt_oper_panel OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE process_rt_oper_panel
(
  p_api_version            IN            NUMBER     := 1.0,
  p_init_msg_list          IN            VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN            VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default                IN            VARCHAR2   := FND_API.G_FALSE,
  p_module_type            IN            VARCHAR2   := NULL,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_msg_count              OUT NOCOPY    NUMBER,
  x_msg_data               OUT NOCOPY    VARCHAR2,
  p_x_rt_oper_panel_tbl    IN OUT NOCOPY rt_oper_panel_tbl_type,
  p_association_type_code  IN            VARCHAR2,
  p_object_id              IN            NUMBER
);



END AHL_RM_RT_OPER_PANEL_PVT;

 

/
