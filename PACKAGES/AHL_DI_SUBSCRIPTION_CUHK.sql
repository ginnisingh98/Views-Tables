--------------------------------------------------------
--  DDL for Package AHL_DI_SUBSCRIPTION_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_SUBSCRIPTION_CUHK" AUTHID CURRENT_USER AS
/* $Header: AHLCSUBS.pls 115.2 2002/12/04 08:21:04 pbarman noship $ */


PROCEDURE CREATE_SUBSCRIPTION_Pre
(

	 p_x_subscription_tbl      IN OUT NOCOPY AHL_DI_SUBSCRIPTION_PVT.subscription_tbl ,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2
);

 PROCEDURE CREATE_SUBSCRIPTION_Post
(

	 p_subscription_tbl      IN  AHL_DI_SUBSCRIPTION_PVT.subscription_tbl ,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2
);


PROCEDURE MODIFY_SUBSCRIPTION_Pre
(

 p_x_subscription_tbl      IN  OUT NOCOPY AHL_DI_SUBSCRIPTION_PVT.subscription_tbl ,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2

);

PROCEDURE MODIFY_SUBSCRIPTION_Post
(

 p_subscription_tbl      IN   AHL_DI_SUBSCRIPTION_PVT.subscription_tbl ,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2

);

END AHL_DI_SUBSCRIPTION_CUHK;

 

/
