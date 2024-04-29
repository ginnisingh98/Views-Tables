--------------------------------------------------------
--  DDL for Package IBE_COPY_LOGICALCONTENT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_COPY_LOGICALCONTENT_GRP" AUTHID CURRENT_USER AS
  /* $Header: IBECLCTS.pls 120.0.12010000.2 2009/12/16 17:05:28 ytian noship $ */


g_api_version CONSTANT NUMBER      := 1.0;
g_pkg_name    CONSTANT VARCHAR2(30):='IBE_Copy_LogicalContent_GRP';
TYPE IDS_LIST IS TABLE OF NUMBER;

PROCEDURE copy_lgl_ctnt(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_object_type_code    IN  VARCHAR2,
  p_from_Product_id     IN NUMBER,
  p_from_Context_ids	IN IDS_LIST,
  p_to_product_ids       IN IDS_LIST ,
  x_copy_status         OUT NOCOPY IDS_LIST,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2
);

PROCEDURE copy_lgl_ctnt(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_object_type_code    IN  VARCHAR2,
  p_from_Product_id     IN NUMBER,
  p_from_Context_ids	IN IDS_LIST,
  p_from_deliverable_ids IN IDS_LIST,
  p_to_product_ids       IN IDS_LIST,
  x_copy_status         OUT NOCOPY IDS_LIST,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2
 );

END IBE_COPY_LogicalContent_GRP;

/
