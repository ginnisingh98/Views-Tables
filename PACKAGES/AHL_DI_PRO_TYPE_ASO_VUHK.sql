--------------------------------------------------------
--  DDL for Package AHL_DI_PRO_TYPE_ASO_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_PRO_TYPE_ASO_VUHK" AUTHID CURRENT_USER AS
/* $Header: AHLIPTAS.pls 115.2 2002/12/04 08:21:52 pbarman noship $ */

 PROCEDURE Create_Doc_Type_Assoc_PRE
(

	 p_x_doc_type_assoc_tbl      IN OUT NOCOPY AHL_DI_PRO_TYPE_ASO_PVT.doc_type_assoc_tbl,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2
);

 PROCEDURE Create_Doc_Type_Assoc_POST
(

	 p_doc_type_assoc_tbl      IN  AHL_DI_PRO_TYPE_ASO_PVT.doc_type_assoc_tbl,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2
);


PROCEDURE MODIFY_DOC_TYPE_ASSOC_PRE
(

 p_x_doc_type_assoc_tbl      IN  OUT NOCOPY AHL_DI_PRO_TYPE_ASO_PVT.doc_type_assoc_tbl,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2

);

PROCEDURE MODIFY_DOC_TYPE_ASSOC_POST
(

 p_doc_type_assoc_tbl      IN   AHL_DI_PRO_TYPE_ASO_PVT.doc_type_assoc_tbl,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2

);

END AHL_DI_PRO_TYPE_ASO_VUHK;

 

/
