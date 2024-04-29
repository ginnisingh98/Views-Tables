--------------------------------------------------------
--  DDL for Package AHL_DI_DOC_REVISION_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_DOC_REVISION_VUHK" AUTHID CURRENT_USER AS
/* $Header: AHLIDORS.pls 115.2 2002/12/04 08:49:09 pbarman noship $ */

 PROCEDURE CREATE_REVISION_PRE
(

	 p_x_revision_tbl      IN OUT NOCOPY AHL_DI_DOC_REVISION_PVT.revision_tbl,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2
);

 PROCEDURE CREATE_REVISION_POST
(

	 p_revision_tbl       IN  AHL_DI_DOC_REVISION_PVT.revision_tbl,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2
);


PROCEDURE MODIFY_REVISION_PRE
(

 p_x_revision_tbl 	      IN  OUT NOCOPY AHL_DI_DOC_REVISION_PVT.revision_tbl,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2

);

PROCEDURE MODIFY_REVISION_POST
(

 p_revision_tbl       IN   AHL_DI_DOC_REVISION_PVT.revision_tbl,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2

);

END AHL_DI_DOC_REVISION_VUHK;

 

/
