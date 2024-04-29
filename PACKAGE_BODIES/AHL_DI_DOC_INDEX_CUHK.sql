--------------------------------------------------------
--  DDL for Package Body AHL_DI_DOC_INDEX_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_DOC_INDEX_CUHK" AS
/* $Header: AHLCDIXB.pls 115.4 2002/12/04 08:48:38 pbarman noship $ */
PROCEDURE CREATE_DOCUMENT_PRE
(

	 p_x_document_tbl            IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Document_Tbl,
	 p_x_supplier_tbl            IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Supplier_Tbl,
 	 p_x_recipient_tbl           IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Recipient_Tbl,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2
)
AS

 Begin

   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
 End CREATE_DOCUMENT_PRE;


PROCEDURE CREATE_DOCUMENT_POST
(

	 p_document_tbl            IN  AHL_DI_DOC_INDEX_PVT.Document_Tbl,
	 p_supplier_tbl            IN  AHL_DI_DOC_INDEX_PVT.Supplier_Tbl,
 	 p_recipient_tbl           IN  AHL_DI_DOC_INDEX_PVT.Recipient_Tbl,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2
)
AS

 Begin

   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
 End CREATE_DOCUMENT_POST;




PROCEDURE MODIFY_DOCUMENT_PRE
(

 p_x_document_tbl            IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Document_Tbl,
 p_x_supplier_tbl            IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Supplier_Tbl,
 p_x_recipient_tbl           IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Recipient_Tbl,
 x_return_status                OUT NOCOPY VARCHAR2  ,
 x_msg_count                    OUT NOCOPY NUMBER    ,
 x_msg_data                     OUT NOCOPY VARCHAR2

)
AS

 Begin

   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
 End MODIFY_DOCUMENT_PRE;


PROCEDURE MODIFY_DOCUMENT_POST
(

 p_document_tbl            IN  AHL_DI_DOC_INDEX_PVT.Document_Tbl,
 p_supplier_tbl            IN  AHL_DI_DOC_INDEX_PVT.Supplier_Tbl,
 p_recipient_tbl           IN  AHL_DI_DOC_INDEX_PVT.Recipient_Tbl,
 x_return_status                OUT NOCOPY VARCHAR2  ,
 x_msg_count                    OUT NOCOPY NUMBER    ,
 x_msg_data                     OUT NOCOPY VARCHAR2

)
AS

 Begin

   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 Exception
   When Others Then
	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
 End MODIFY_DOCUMENT_POST;



END AHL_DI_DOC_INDEX_CUHK;

/
