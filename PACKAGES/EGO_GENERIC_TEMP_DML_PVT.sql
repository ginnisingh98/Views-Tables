--------------------------------------------------------
--  DDL for Package EGO_GENERIC_TEMP_DML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_GENERIC_TEMP_DML_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVGTDS.pls 120.0.12010000.2 2009/08/05 13:18:40 vijoshi noship $ */

G_RET_STS_SUCCESS         CONSTANT  VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
G_RET_STS_ERROR           CONSTANT  VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
G_RET_STS_UNEXP_ERROR     CONSTANT  VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'

G_PKG_NAME                CONSTANT  VARCHAR2(50) := 'EGO_GENERIC_TEMP_DML_PVT';

G_CURRENT_USER_ID         NUMBER := FND_GLOBAL.User_Id;
G_CURRENT_LOGIN_ID        NUMBER := FND_GLOBAL.Login_Id;

G_FALSE                   CONSTANT  VARCHAR2(1)  :=  FND_API.G_FALSE; -- 'F'
G_TRUE                    CONSTANT  VARCHAR2(1)  :=  FND_API.G_TRUE;  -- 'T'


--  ============================================================================
--  Name        : INSERT_ROW
--  Description : This procedure is used to insert data in the EGO_GENERIC_TEMP table
--
--  Parameters:
--        IN    :
--                p_generic_temp_tbl  IN    EGO_GENERIC_TEMP_TBL_TYPE
--
--
--  ============================================================================

 PROCEDURE Insert_Row ( p_api_version       IN NUMBER
                       --,p_commit            IN VARCHAR2 DEFAULT G_FALSE
                       ,p_generic_temp_tbl  IN  Ego_Generic_Temp_Tbl_Type
                       ,x_return_status     OUT NOCOPY VARCHAR2
                       ,x_msg_data          OUT NOCOPY VARCHAR2
                       ,x_msg_count         OUT NOCOPY NUMBER
                      );

END EGO_GENERIC_TEMP_DML_PVT;


/
