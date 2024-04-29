--------------------------------------------------------
--  DDL for Package EGO_UCCNET_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_UCCNET_EVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVGTNS.pls 120.1 2005/12/05 01:14:33 dsakalle noship $ */

G_FILE_NAME       CONSTANT  VARCHAR2(12)  :=  'EGOVGTNS.pls';

G_RET_STS_SUCCESS   CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
G_RET_STS_ERROR     CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'

--  Define the package global constants to substitute FND_API global variables for missing values

G_MISS_NUM      CONSTANT    NUMBER       :=  9.99E125;
G_MISS_CHAR     CONSTANT    VARCHAR2(1)  :=  CHR(0);
G_MISS_DATE     CONSTANT    DATE         :=  TO_DATE('1','j');

PROCEDURE Add_Additional_CIC_Info (
         p_api_version                  IN      NUMBER
        ,p_commit                       IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_init_msg_list                IN      VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_cln_id                       IN      NUMBER
        ,p_cic_code                     IN      VARCHAR2
        ,p_cic_description              IN      VARCHAR2
        ,p_cic_action_needed            IN      VARCHAR2
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY VARCHAR2
        ,x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Event_Disposition (
         p_api_version                  IN      NUMBER
        ,p_commit                       IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_init_msg_list                IN      VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_cln_id                       IN      NUMBER
        ,p_disposition_code             IN      VARCHAR2
        ,p_disposition_date             IN      DATE
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY VARCHAR2
        ,x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE Set_Collaboration_Id (
         p_api_version                  IN      NUMBER
        ,p_commit                       IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_init_msg_list                IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_batch_id                     IN      NUMBER
        ,p_subbatch_id                  IN      NUMBER
        ,p_top_gtin                     IN      NUMBER
        ,p_cln_id                       IN      NUMBER
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY VARCHAR2
        ,x_msg_data                     OUT NOCOPY VARCHAR2
);


END EGO_UCCNET_EVENTS_PVT;


 

/
