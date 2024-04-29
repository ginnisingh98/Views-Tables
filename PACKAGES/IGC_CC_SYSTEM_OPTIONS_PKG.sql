--------------------------------------------------------
--  DDL for Package IGC_CC_SYSTEM_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_SYSTEM_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCSYSPS.pls 120.0.12000000.1 2007/10/25 04:56:01 mbremkum noship $ */

PROCEDURE Insert_Row
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_row_id                    IN OUT NOCOPY VARCHAR2,
  p_org_id                                  NUMBER,
  p_cc_num_method                           VARCHAR2,
  p_cc_num_datatype                         VARCHAR2,
  p_cc_next_num                             NUMBER,
  p_cc_prefix                               VARCHAR2,
  p_default_rate_type                       VARCHAR2,
  p_enforce_vendor_hold_flag                VARCHAR2,
  p_last_update_date                        DATE,
  p_last_updated_by                         NUMBER,
  p_last_update_login                       NUMBER,
  p_created_by                              NUMBER,
  p_creation_date                           DATE
);

PROCEDURE Lock_Row
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_row_id                    IN OUT NOCOPY VARCHAR2,
  p_org_id                                  NUMBER,
  p_cc_num_method                           VARCHAR2,
  p_cc_num_datatype                         VARCHAR2,
  p_cc_next_num                             NUMBER,
  p_cc_prefix                               VARCHAR2,
  p_default_rate_type                       VARCHAR2,
  p_enforce_vendor_hold_flag                VARCHAR2,
  p_row_locked                OUT NOCOPY    VARCHAR2
);

PROCEDURE Update_Row
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_row_id                    IN OUT NOCOPY VARCHAR2,
  p_org_id                                  NUMBER,
  p_cc_num_method                           VARCHAR2,
  p_cc_num_datatype                         VARCHAR2,
  p_cc_next_num                             NUMBER,
  p_cc_prefix                               VARCHAR2,
  p_default_rate_type                       VARCHAR2,
  p_enforce_vendor_hold_flag                VARCHAR2,
  p_last_update_date                        DATE,
  p_last_updated_by                         NUMBER,
  p_last_update_login                       NUMBER
);

PROCEDURE Delete_Row
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_row_id                    IN            VARCHAR2
);


PROCEDURE Check_Unique
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_row_id                    IN OUT NOCOPY VARCHAR2,
  p_org_id		                              NUMBER,
  p_return_value              IN OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Auto_CC_Num
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_org_id                    IN            igc_cc_headers.org_id%TYPE,
  p_sob_id                    IN            igc_cc_headers.set_of_books_id%TYPE,
  x_cc_num                    OUT NOCOPY    igc_cc_headers.cc_num%TYPE
);

PROCEDURE Validate_Numeric_CC_Num
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_cc_num                    IN            igc_cc_headers.cc_num%TYPE
);

END IGC_CC_SYSTEM_OPTIONS_PKG;

 

/
