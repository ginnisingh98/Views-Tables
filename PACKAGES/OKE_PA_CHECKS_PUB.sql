--------------------------------------------------------
--  DDL for Package OKE_PA_CHECKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_PA_CHECKS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKEPPACS.pls 115.4 2002/11/20 20:37:34 who ship $ */

  -- GLOBAL VARIABLES

  G_PKG_NAME     CONSTANT VARCHAR2(200) := 'OKE_PA_CHECKS_PUB';
  G_APP_NAME     CONSTANT VARCHAR2(200) := OKE_API.G_APP_NAME;

--
--  Name          : Project_Used
--  Function      : This function checks if a certain project is used by OKE
--
--  Parameters    :
--  IN            : Project_ID NUMBER
--
--  OUT           : X_Result VARCHAR2     ( 'Y'  'N' )



PROCEDURE Project_Used
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
,  Project_ID 		    IN	  NUMBER
,  X_Result		    OUT   NOCOPY VARCHAR2
);


--
--  Name          : Task_Used
--  Function      : This function checks if a certain task is used by OKE
--
--  Parameters    :
--  IN            : Task_ID	NUMBER
--
--  OUT           : X_Result VARCHAR2     ( 'Y'  'N' )


PROCEDURE Task_Used
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
,  Task_ID 		    IN	  NUMBER
,  X_Result		    OUT   NOCOPY VARCHAR2
);



--
--  Name          : Disassociation_Allowed
--  Function      : This function checks if a certain project(To_Project_ID)
--			can be disassociatied from
--			a task(From_Project_ID,From_Task_ID)
--
--  Parameters    :
--  IN            : 	From_Project_ID		NUMBER
--			From_Task_ID		NUMBER
--			To_Project_ID		NUMBER
--  OUT           : X_Result VARCHAR2     ( 'Y'  'N' )
--



PROCEDURE Disassociation_Allowed
(  p_api_version		IN	NUMBER
,  p_commit			IN	VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE
,  x_msg_count			OUT	NOCOPY NUMBER
,  x_msg_data			OUT	NOCOPY VARCHAR2
,  x_return_status		OUT	NOCOPY VARCHAR2
,  From_Project_ID		IN	NUMBER
,  From_Task_ID			IN	NUMBER
,  To_Project_ID		IN	NUMBER
,  X_Result			OUT	NOCOPY VARCHAR2
);



END OKE_PA_CHECKS_PUB;

 

/
