--------------------------------------------------------
--  DDL for Package AHL_RM_ASSO_DOCASO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RM_ASSO_DOCASO_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVRODS.pls 120.0 2005/05/26 01:52:17 appldev noship $ */

TYPE doc_association_rec IS RECORD
 (
  DOC_TITLE_ASSO_ID      NUMBER,
  DOCUMENT_ID            NUMBER,
  DOCUMENT_NO            VARCHAR2(80),
  DOC_REVISION_ID        NUMBER,
  REVISION_NO            VARCHAR2(30),
  USE_LATEST_REV_FLAG    VARCHAR2(1),
  OBJECT_TYPE_CODE   	 VARCHAR2(30),
  OBJECT_TYPE_DESC   	 VARCHAR2(80),
  OBJECT_ID          	 NUMBER,
  OBJECT_NUMBER		 VARCHAR2(80),
  OBJECT_REVISION	 NUMBER,
  SERIAL_NO              VARCHAR2(30),
  SOURCE_LANG            VARCHAR2(12),
  CHAPTER                VARCHAR2(30),
  SECTION                VARCHAR2(30),
  SUBJECT                VARCHAR2(240),
  PAGE                   VARCHAR2(5),
  FIGURE                 VARCHAR2(30),
  NOTE                   VARCHAR2(2000),
  SOURCE_REF_CODE        VARCHAR2(30),
  SOURCE_REF_MEAN        VARCHAR2(80),
  OBJECT_VERSION_NUMBER  NUMBER,
  ATTRIBUTE_CATEGORY     VARCHAR2(30),
  ATTRIBUTE1             VARCHAR2(150),
  ATTRIBUTE2             VARCHAR2(150),
  ATTRIBUTE3             VARCHAR2(150),
  ATTRIBUTE4             VARCHAR2(150),
  ATTRIBUTE5             VARCHAR2(150),
  ATTRIBUTE6             VARCHAR2(150),
  ATTRIBUTE7             VARCHAR2(150),
  ATTRIBUTE8             VARCHAR2(150),
  ATTRIBUTE9             VARCHAR2(150),
  ATTRIBUTE10            VARCHAR2(150),
  ATTRIBUTE11            VARCHAR2(150),
  ATTRIBUTE12            VARCHAR2(150),
  ATTRIBUTE13            VARCHAR2(150),
  ATTRIBUTE14            VARCHAR2(150),
  ATTRIBUTE15            VARCHAR2(150),
  DML_OPERATION          VARCHAR2(1)
  );

 TYPE doc_association_tbl IS TABLE OF doc_association_rec INDEX BY BINARY_INTEGER;

-- Start of Comments
-- Procedure name              : process_association
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--	p_api_version               NUMBER   Required
--	p_init_msg_list             VARCHAR2 Default  FND_API.G_TRUE
--	p_commit                    VARCHAR2 Default  FND_API.G_FALSE
--	p_validation_level          NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--	p_default                   VARCHAR2 Default  FND_API.G_FALSE
--	p_module_type               VARCHAR2 Default  NULL
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2 Required
--      x_msg_count                 NUMBER   Required
--      x_msg_data                  VARCHAR2 Required
--
-- process_route_operation_as IN parameters:
--      None
--
-- process_route_operation_as IN OUT parameters:
--	p_x_association_tbl        AHL_DI_ASSO_DOC_GEN_PUB.association_tbl Required
--
-- process_route_operation_as OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments


PROCEDURE PROCESS_ASSOCIATION
(
 p_api_version                  IN  		NUMBER    := 1.0,
 p_init_msg_list                IN  		VARCHAR2  := FND_API.G_TRUE,
 p_commit                       IN  		VARCHAR2  := FND_API.G_FALSE,
 p_validation_level             IN  		NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_validate_only             	IN  		VARCHAR2  := FND_API.G_TRUE,
 p_default                      IN  		VARCHAR2  := FND_API.G_FALSE,
 p_module_type                  IN  		VARCHAR2  := NULL,
 x_return_status                OUT 		NOCOPY VARCHAR2,
 x_msg_count                    OUT 		NOCOPY NUMBER,
 x_msg_data                     OUT 		NOCOPY VARCHAR2,
 p_x_association_tbl            IN  OUT NOCOPY  doc_association_tbl
 );

END AHL_RM_ASSO_DOCASO_PVT;

 

/
