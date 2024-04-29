--------------------------------------------------------
--  DDL for Package IGC_CC_PO_DIST_ALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_PO_DIST_ALL_PVT" AUTHID CURRENT_USER AS
/* $Header: IGCCPDTS.pls 120.3.12010000.2 2008/12/11 09:04:14 gaprasad ship $ */


PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
----------------------------------------------------------------------
  p_po_dist_rec               IN       po_distributions_all%ROWTYPE
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
----------------------------------------------------------------------
  p_po_dist_rec               IN       po_distributions_all%ROWTYPE
);

PROCEDURE Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
----------------------------------------------------------------------
  p_po_distribution_id        IN       po_distributions_all.po_distribution_id%TYPE
);

END IGC_CC_PO_DIST_ALL_PVT;

/
