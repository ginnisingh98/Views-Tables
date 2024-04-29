--------------------------------------------------------
--  DDL for Package AHL_DI_DOC_INDEX_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_DOC_INDEX_CUHK" AUTHID CURRENT_USER AS
/* $Header: AHLCDIXS.pls 115.4 2002/12/04 08:48:30 pbarman noship $ */

PROCEDURE CREATE_DOCUMENT_PRE
(

	 p_x_document_tbl            IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Document_Tbl,
	 p_x_supplier_tbl            IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Supplier_Tbl,
 	 p_x_recipient_tbl           IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Recipient_Tbl,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE CREATE_DOCUMENT_POST
(

	 p_document_tbl            IN  AHL_DI_DOC_INDEX_PVT.Document_Tbl,
	 p_supplier_tbl            IN  AHL_DI_DOC_INDEX_PVT.Supplier_Tbl,
 	 p_recipient_tbl           IN  AHL_DI_DOC_INDEX_PVT.Recipient_Tbl,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2
);


PROCEDURE MODIFY_DOCUMENT_PRE
(

 p_x_document_tbl            IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Document_Tbl,
 p_x_supplier_tbl            IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Supplier_Tbl,
 p_x_recipient_tbl           IN OUT NOCOPY AHL_DI_DOC_INDEX_PVT.Recipient_Tbl,
 x_return_status                OUT NOCOPY VARCHAR2   ,
 x_msg_count                    OUT NOCOPY NUMBER     ,
 x_msg_data                     OUT NOCOPY VARCHAR2

);

PROCEDURE MODIFY_DOCUMENT_POST
(

 p_document_tbl            IN  AHL_DI_DOC_INDEX_PVT.Document_Tbl,
 p_supplier_tbl            IN  AHL_DI_DOC_INDEX_PVT.Supplier_Tbl,
 p_recipient_tbl           IN  AHL_DI_DOC_INDEX_PVT.Recipient_Tbl,
 x_return_status                OUT NOCOPY VARCHAR2   ,
 x_msg_count                    OUT NOCOPY NUMBER     ,
 x_msg_data                     OUT NOCOPY VARCHAR2

);

END AHL_DI_DOC_INDEX_CUHK;

 

/
