--------------------------------------------------------
--  DDL for Package Body AHL_DI_PRO_TYPE_ASO_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_PRO_TYPE_ASO_CUHK" AS
/* $Header: AHLCPTAB.pls 115.2 2002/12/04 08:20:57 pbarman noship $ */



 PROCEDURE Create_Doc_Type_Assoc_PRE
(

	 p_x_doc_type_assoc_tbl      IN OUT NOCOPY AHL_DI_PRO_TYPE_ASO_PVT.doc_type_assoc_tbl ,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin

   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
 End Create_Doc_Type_Assoc_PRE;


 PROCEDURE Create_Doc_Type_Assoc_POST
(

	 p_doc_type_assoc_tbl      IN AHL_DI_PRO_TYPE_ASO_PVT.doc_type_assoc_tbl ,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
 End Create_Doc_Type_Assoc_POST;


PROCEDURE MODIFY_DOC_TYPE_ASSOC_PRE
(

 p_x_doc_type_assoc_tbl      IN  OUT NOCOPY AHL_DI_PRO_TYPE_ASO_PVT.doc_type_assoc_tbl ,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
End MODIFY_DOC_TYPE_ASSOC_PRE;



PROCEDURE MODIFY_DOC_TYPE_ASSOC_POST
(
 p_doc_type_assoc_tbl      IN   AHL_DI_PRO_TYPE_ASO_PVT.doc_type_assoc_tbl ,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2)

AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
End MODIFY_DOC_TYPE_ASSOC_POST;

End AHL_DI_PRO_TYPE_ASO_CUHK;

/
