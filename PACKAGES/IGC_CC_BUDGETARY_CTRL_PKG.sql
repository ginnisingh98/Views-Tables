--------------------------------------------------------
--  DDL for Package IGC_CC_BUDGETARY_CTRL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_BUDGETARY_CTRL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCBCLS.pls 120.4.12000000.2 2007/09/07 11:49:59 smannava ship $ */

PROCEDURE Execute_Budgetary_Ctrl
(
  p_api_version                   IN       NUMBER,
  p_init_msg_list                 IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_bc_status                     OUT NOCOPY      VARCHAR2,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  p_cc_header_id                  IN       NUMBER,
  p_accounting_date               IN       DATE,
  p_mode                          IN       VARCHAR2,
  p_notes                         IN       VARCHAR2 DEFAULT NULL
);

PROCEDURE Check_Budgetary_Ctrl_On
(
  p_api_version                         IN       NUMBER,
  p_init_msg_list                       IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                    IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                       OUT NOCOPY      VARCHAR2,
  x_msg_count                           OUT NOCOPY      NUMBER,
  x_msg_data                            OUT NOCOPY      VARCHAR2,
  p_org_id                              IN       NUMBER,
  p_sob_id                              IN       NUMBER,
  p_cc_state                            IN       VARCHAR2,
  x_encumbrance_on                      OUT NOCOPY      VARCHAR2
);

PROCEDURE Set_Encumbrance_Status
(
  p_api_version                         IN       NUMBER,
  p_init_msg_list                       IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                              IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                    IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                       OUT NOCOPY      VARCHAR2,
  x_msg_count                           OUT NOCOPY      NUMBER,
  x_msg_data                            OUT NOCOPY      VARCHAR2,
  p_cc_header_id                        IN       NUMBER,
  p_encumbrance_status_code             IN       VARCHAR2
);



PROCEDURE 	Validate_CC
(
  p_api_version                	IN      NUMBER,
  p_init_msg_list              	IN      VARCHAR2 	:= FND_API.G_FALSE,
  p_validation_level           	IN      NUMBER   	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status              	OUT NOCOPY     VARCHAR2,
  x_msg_count                  	OUT NOCOPY     NUMBER,
  x_msg_data                   	OUT NOCOPY     VARCHAR2,
  p_cc_header_id               	IN      NUMBER,
  x_valid_cc                   	OUT NOCOPY     VARCHAR2,
  p_mode 			IN 	VARCHAR2,
  p_field_from			IN 	VARCHAR2,
  p_encumbrance_flag 		IN 	VARCHAR2,
  p_sob_id                      IN      NUMBER,
  p_org_id			IN 	NUMBER,
  p_start_date			IN	DATE,
  p_end_date			IN 	DATE,
  p_cc_type_code		IN 	VARCHAR2,
  p_parent_cc_header_id		IN 	NUMBER,
  p_cc_det_pf_date		IN 	DATE,
  p_acct_date			IN	DATE,
  p_prev_acct_date		IN	DATE,
  p_cc_state			IN	VARCHAR2
);


PROCEDURE calculate_nonrec_tax (
  p_api_version       IN       NUMBER,
  p_init_msg_list     IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY      VARCHAR2,
  x_msg_count         OUT NOCOPY      NUMBER,
  x_msg_data          OUT NOCOPY      VARCHAR2,
  p_tax_id            IN       ap_tax_codes.tax_id%TYPE,
  p_amount            IN       NUMBER,
  p_tax_amount        OUT NOCOPY      NUMBER
);


END IGC_CC_BUDGETARY_CTRL_PKG;

 

/
