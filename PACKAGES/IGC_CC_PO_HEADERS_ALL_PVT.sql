--------------------------------------------------------
--  DDL for Package IGC_CC_PO_HEADERS_ALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_PO_HEADERS_ALL_PVT" AUTHID CURRENT_USER AS
/* $Header: IGCCPHDS.pls 120.3.12000000.1 2007/08/20 12:14:04 mbremkum ship $ */


PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
  ----------------------------------------------
  p_po_headers_rec            IN       po_headers_all%rowtype
);

PROCEDURE Update_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
  ----------------------------------------------
  p_po_headers_rec            IN       po_headers_all%rowtype
);

END IGC_CC_PO_HEADERS_ALL_PVT;

 

/