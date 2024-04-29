--------------------------------------------------------
--  DDL for Package CSD_TO_FORM_REPAIR_JOB_XREF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_TO_FORM_REPAIR_JOB_XREF" AUTHID CURRENT_USER as
/* $Header: csdgdrjs.pls 115.12 2003/09/15 21:34:53 sragunat ship $ */
-- Start of Comments
-- Package name     : CSD_TO_FORM_REPAIR_JOB_XREF
-- Purpose          : Takes all parameters from the FORM and construct those parameters into a record for calling
--                    the prviate API in the CSP_MOVEORDER_HEADERS_PVT package.
-- History          : 11/17/1999, Created by Vernon Lou
-- History          : 12/26/2001, TRAVI Added INVENTORY_ITEM_ID and ITEM_REVISION
-- History          : 01/17/2002, TRAVI added column OBJECT_VERSION_NUMBER
-- History          : 08/20/2003, Shiv Ragunathan, 11.5.10 Changes: Added
-- History          :   parameters p_source_type_code, p_source_id1,
-- History          :   p_ro_service_code_id, p_job_name to
-- History          :   Validate_And_Write.
-- NOTE             :
-- End of Comments

  -- travi changes
  PROCEDURE Validate_And_Write (
        P_Api_Version_Number           IN   NUMBER,
        P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
        P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
        p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
        p_action_code                  IN   NUMBER,    /* 0 = insert, 1 = update, 2 = delete */
        px_REPAIR_JOB_XREF_ID   IN OUT NOCOPY NUMBER,
        p_CREATED_BY    NUMBER,
        p_CREATION_DATE    DATE,
        p_LAST_UPDATED_BY    NUMBER,
        p_LAST_UPDATE_DATE    DATE,
        p_LAST_UPDATE_LOGIN    NUMBER,
        p_REPAIR_LINE_ID    NUMBER,
        p_WIP_ENTITY_ID    NUMBER,
        p_GROUP_ID    NUMBER,
        p_ORGANIZATION_ID    NUMBER,
        p_QUANTITY    NUMBER,
        p_INVENTORY_ITEM_ID    NUMBER,
        p_ITEM_REVISION    VARCHAR2,
        p_SOURCE_TYPE_CODE 		VARCHAR2,
        p_SOURCE_ID1  			NUMBER,
        p_RO_SERVICE_CODE_ID 		NUMBER,
        p_JOB_NAME 			VARCHAR2,
        p_OBJECT_VERSION_NUMBER    NUMBER,
        p_ATTRIBUTE_CATEGORY    VARCHAR2,
        p_ATTRIBUTE1    VARCHAR2,
        p_ATTRIBUTE2    VARCHAR2,
        p_ATTRIBUTE3    VARCHAR2,
        p_ATTRIBUTE4    VARCHAR2,
        p_ATTRIBUTE5    VARCHAR2,
        p_ATTRIBUTE6    VARCHAR2,
        p_ATTRIBUTE7    VARCHAR2,
        p_ATTRIBUTE8    VARCHAR2,
        p_ATTRIBUTE9    VARCHAR2,
        p_ATTRIBUTE10    VARCHAR2,
        p_ATTRIBUTE11    VARCHAR2,
        p_ATTRIBUTE12    VARCHAR2,
        p_ATTRIBUTE13    VARCHAR2,
        p_ATTRIBUTE14    VARCHAR2,
        p_ATTRIBUTE15    VARCHAR2,
       p_QUANTITY_COMPLETED NUMBER,
        X_Return_Status              OUT NOCOPY  VARCHAR2,
        X_Msg_Count                  OUT NOCOPY  NUMBER,
        X_Msg_Data                   OUT NOCOPY  VARCHAR2
       );

END CSD_TO_FORM_REPAIR_JOB_XREF;

 

/
