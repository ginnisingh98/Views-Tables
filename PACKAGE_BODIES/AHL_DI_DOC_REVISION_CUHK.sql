--------------------------------------------------------
--  DDL for Package Body AHL_DI_DOC_REVISION_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_DOC_REVISION_CUHK" AS
/* $Header: AHLCDORB.pls 115.2 2002/12/04 08:41:24 pbarman noship $ */



 PROCEDURE CREATE_REVISION_PRE
(

	 p_x_revision_tbl      IN OUT NOCOPY AHL_DI_DOC_REVISION_PVT.revision_tbl ,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin

   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
 End CREATE_REVISION_PRE;


 PROCEDURE CREATE_REVISION_POST
(

	 p_revision_tbl      IN AHL_DI_DOC_REVISION_PVT.revision_tbl ,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
 End CREATE_REVISION_POST;


PROCEDURE  MODIFY_REVISION_PRE
(

 p_x_revision_tbl      IN  OUT NOCOPY AHL_DI_DOC_REVISION_PVT.revision_tbl ,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
End MODIFY_REVISION_PRE ;



PROCEDURE MODIFY_REVISION_POST
(
 p_revision_tbl      IN   AHL_DI_DOC_REVISION_PVT.revision_tbl ,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
End MODIFY_REVISION_POST;

End AHL_DI_DOC_REVISION_CUHK;

/
