--------------------------------------------------------
--  DDL for Package OKE_VERSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_VERSION_PUB" AUTHID CURRENT_USER AS
/* $Header: OKEPVERS.pls 115.6 2002/11/20 20:39:21 who ship $ */

PROCEDURE version_contract
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
--,  p_Contract_Number        IN    VARCHAR2 := FND_API.G_MISS_CHAR
--,  p_Contract_Num_Modifier  IN    VARCHAR2 := FND_API.G_MISS_CHAR
,  p_Contract_Header_ID     IN    NUMBER   --:= FND_API.G_MISS_NUM
,  p_chg_request_id	    IN    NUMBER
,  p_version_reason_code    IN    VARCHAR2
,  x_Prev_Version           OUT   NOCOPY NUMBER
,  x_New_Version            OUT   NOCOPY NUMBER
);


PROCEDURE restore_contract_version
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
--,  p_Contract_Number        IN    VARCHAR2 := FND_API.G_MISS_CHAR
--,  p_Contract_Num_Modifier  IN    VARCHAR2 := FND_API.G_MISS_CHAR
,  p_Contract_Header_ID     IN    NUMBER   --:= FND_API.G_MISS_NUM
,  p_Restore_From_Version   IN    NUMBER   --:= FND_API.G_MISS_NUM
,  p_chg_request_id	    IN    NUMBER
,  p_version_reason_code    IN    VARCHAR2
,  x_New_Version            OUT   NOCOPY NUMBER
);

END oke_version_pub;

 

/
