--------------------------------------------------------
--  DDL for Package Body AHL_DI_ASSO_DOC_ASO_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_ASSO_DOC_ASO_CUHK" as
/* $Header: AHLCDASB.pls 115.3 2002/12/04 08:20:23 pbarman noship $ */
PROCEDURE CREATE_ASSOCIATION_PRE
 (
 p_x_association_tbl            IN  OUT NOCOPY AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2) AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 End CREATE_ASSOCIATION_PRE;

PROCEDURE CREATE_ASSOCIATION_POST
 (
 p_association_tbl            IN  AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2) AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 End CREATE_ASSOCIATION_POST;

PROCEDURE MODIFY_ASSOCIATION_PRE
(
 p_x_association_tbl            IN  OUT NOCOPY AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2) AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 End MODIFY_ASSOCIATION_PRE;

PROCEDURE MODIFY_ASSOCIATION_POST
(
 p_association_tbl            IN  AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2) AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 End MODIFY_ASSOCIATION_POST;

PROCEDURE PROCESS_ASSOCIATION_PRE
(
 p_x_association_tbl            IN  OUT NOCOPY AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2) AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 End PROCESS_ASSOCIATION_PRE;

PROCEDURE PROCESS_ASSOCIATION_POST
(
 p_association_tbl            IN  AHL_DI_ASSO_DOC_ASO_PVT.association_tbl       ,
 x_return_status                    OUT NOCOPY VARCHAR2                     ,
 x_msg_count                        OUT NOCOPY NUMBER                       ,
 x_msg_data                         OUT NOCOPY VARCHAR2) AS

 Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
 END PROCESS_ASSOCIATION_POST;


End AHL_DI_ASSO_DOC_ASO_CUHK;

/
