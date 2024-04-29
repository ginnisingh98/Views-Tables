--------------------------------------------------------
--  DDL for Package Body AHL_DI_SUBSCRIPTION_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_SUBSCRIPTION_VUHK" AS
/* $Header: AHLISUBB.pls 115.2 2002/12/04 08:22:27 pbarman noship $ */

PROCEDURE  CREATE_SUBSCRIPTION_Pre
(

	 p_x_subscription_tbl      IN OUT NOCOPY AHL_DI_SUBSCRIPTION_PVT.subscription_tbl ,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin

   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;

 End CREATE_SUBSCRIPTION_Pre;


 PROCEDURE CREATE_SUBSCRIPTION_Post
(

	 p_subscription_tbl      IN AHL_DI_SUBSCRIPTION_PVT.subscription_tbl ,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
 End CREATE_SUBSCRIPTION_Post;


PROCEDURE MODIFY_SUBSCRIPTION_Pre
(

 p_x_subscription_tbl      IN  OUT NOCOPY AHL_DI_SUBSCRIPTION_PVT.subscription_tbl ,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
End MODIFY_SUBSCRIPTION_Pre;



PROCEDURE  MODIFY_SUBSCRIPTION_Post
(

p_subscription_tbl     IN   AHL_DI_SUBSCRIPTION_PVT.subscription_tbl ,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;

End MODIFY_SUBSCRIPTION_Post;

End AHL_DI_SUBSCRIPTION_VUHK ;

/
