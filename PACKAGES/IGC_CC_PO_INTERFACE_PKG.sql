--------------------------------------------------------
--  DDL for Package IGC_CC_PO_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_PO_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCCPIS.pls 120.4.12010000.2 2008/08/04 14:49:51 sasukuma ship $ */

PROCEDURE Update_PO_Approved_Flag
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
  --
  p_cc_header_id              IN       NUMBER
);


PROCEDURE Convert_CC_To_PO
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
  --
  p_cc_header_id              IN       NUMBER
);

PROCEDURE Lock_PO_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
  p_cc_header_id              IN       NUMBER,
  x_row_locked                OUT NOCOPY      VARCHAR2
);

END IGC_CC_PO_INTERFACE_PKG;

/
