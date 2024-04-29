--------------------------------------------------------
--  DDL for Package CS_COST_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_COST_DETAILS_PVT" AUTHID CURRENT_USER AS
/* $Header: csxvcsts.pls 120.2 2008/01/11 05:48:06 amganapa noship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE SPECIFIC CONSTANTS
  -----------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'CS_COST_DETAILS_PVT';

  -----------------------------------------------------------------------------
  -- APPLICATION GLOBAL CONSTANTS
  -----------------------------------------------------------------------------
  G_APP_NAME             CONSTANT VARCHAR2(2)   :=  'CS';
  G_API_VERSION          CONSTANT NUMBER        := 1.0;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_DB_ERROR             CONSTANT VARCHAR2(11)  := 'CS_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;


  -----------------------------------------------------------------------------
  -- PROGRAM UNITS
  -----------------------------------------------------------------------------
PROCEDURE Create_cost_details
(
        p_api_version              IN         NUMBER,
        p_init_msg_list            IN         VARCHAR2         := FND_API.G_FALSE,
        p_commit                   IN         VARCHAR2         := FND_API.G_FALSE,
        p_validation_level         IN         NUMBER           := FND_API.G_VALID_LEVEL_FULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_object_version_number    OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
        x_cost_id                  OUT NOCOPY NUMBER,
        p_resp_appl_id             IN         NUMBER		:= FND_GLOBAL.RESP_APPL_ID,
        p_resp_id                  IN         NUMBER		:= FND_GLOBAL.RESP_ID,
        p_user_id                  IN         NUMBER		:= FND_GLOBAL.USER_ID,
        p_login_id                 IN         NUMBER		:= FND_GLOBAL.LOGIN_ID,
        p_transaction_control      IN         VARCHAR2		:= FND_API.G_TRUE,
        p_Cost_Rec                 IN         CS_Cost_Details_PUB.Cost_Rec_Type,
	p_cost_creation_override   IN         VARCHAR2 :='N'
);



PROCEDURE Update_Cost_details
(
        p_api_version              IN         NUMBER,
        p_init_msg_list            IN         VARCHAR2         := FND_API.G_FALSE,
        p_commit                   IN         VARCHAR2         := FND_API.G_FALSE,
        p_validation_level         IN         NUMBER           := FND_API.G_VALID_LEVEL_FULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_object_version_number    OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
        p_resp_appl_id             IN         NUMBER           := FND_GLOBAL.RESP_APPL_ID,
        p_resp_id                  IN         NUMBER           := FND_GLOBAL.RESP_ID,
        p_user_id                  IN         NUMBER           := FND_GLOBAL.USER_ID,
        p_login_id                 IN         NUMBER           := FND_GLOBAL.LOGIN_ID,
        p_transaction_control      IN         VARCHAR2         := FND_API.G_TRUE,
        p_Cost_Rec                 IN         CS_Cost_Details_PUB.Cost_Rec_Type
) ;




 PROCEDURE Delete_Cost_Details
 (
             p_api_version          IN         NUMBER,
             p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
             p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
             p_validation_level     IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
             x_return_status        OUT NOCOPY VARCHAR2,
             x_msg_count            OUT NOCOPY NUMBER,
             x_msg_data             OUT NOCOPY VARCHAR2,
             p_transaction_control  IN         VARCHAR2 := FND_API.G_TRUE,
             p_cost_id		    IN         NUMBER   := NULL
) ;

-- Procedure to purge cost lines attached to an SR.

PROCEDURE Purge_Cost
(
  p_api_version_number IN  NUMBER := 1.0
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, p_commit             IN  VARCHAR2 := FND_API.G_FALSE
, p_object_type        IN  VARCHAR2
, p_processing_set_id  IN  NUMBER
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
);

 PROCEDURE  get_currency_converted_value
 (
                         p_from_currency IN  VARCHAR2,
                         p_to_currency   IN  VARCHAR2,
                         p_value         IN  NUMBER,
                         p_ou            IN  VARCHAR2,
                         x_value         OUT NOCOPY NUMBER
 ) ;

 END CS_Cost_Details_PVT;

/
