--------------------------------------------------------
--  DDL for Package AHL_DI_ASSO_DOC_ASO_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_ASSO_DOC_ASO_CUHK" AUTHID CURRENT_USER AS
/* $Header: AHLCDASS.pls 115.3 2002/12/04 08:20:16 pbarman noship $ */
 PROCEDURE CREATE_ASSOCIATION_PRE
 (
 p_x_association_tbl            IN  OUT NOCOPY AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2);

 PROCEDURE CREATE_ASSOCIATION_POST
 (
 p_association_tbl            IN  AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2);


PROCEDURE MODIFY_ASSOCIATION_PRE
(
 p_x_association_tbl            IN  OUT NOCOPY AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2);

PROCEDURE MODIFY_ASSOCIATION_POST
(
 p_association_tbl            IN  AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2);


PROCEDURE PROCESS_ASSOCIATION_PRE
(
 p_x_association_tbl            IN  OUT NOCOPY AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2);

PROCEDURE PROCESS_ASSOCIATION_POST
(
 p_association_tbl            IN  AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2);

END AHL_DI_ASSO_DOC_ASO_CUHK;

 

/
