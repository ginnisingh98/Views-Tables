--------------------------------------------------------
--  DDL for Package CS_CHARGE_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHARGE_DETAILS_PVT" AUTHID CURRENT_USER AS
/* $Header: csxvests.pls 120.3 2005/08/18 16:49:35 mviswana noship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE SPECIFIC CONSTANTS
  -----------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'CS_CHARGE_DETAILS_PVT';

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
PROCEDURE Create_Charge_Details(
      p_api_version           IN  	  NUMBER,
      p_init_msg_list         IN 	  VARCHAR2 	:= FND_API.G_FALSE,
      p_commit                IN 	  VARCHAR2 	:= FND_API.G_FALSE,
      p_validation_level      IN  	  NUMBER 	:= FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_object_version_number OUT NOCOPY  NUMBER,
      x_estimate_detail_id    OUT NOCOPY  NUMBER,
      x_line_number           OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      --p_resp_appl_id          IN  	  NUMBER  	:= NULL,
      --p_resp_id               IN  	  NUMBER  	:= NULL,
      --p_user_id               IN  	  NUMBER  	:= NULL,
      p_resp_appl_id          IN          NUMBER := FND_GLOBAL.RESP_APPL_ID,
      p_resp_id               IN          NUMBER := FND_GLOBAL.RESP_ID,
      p_user_id               IN          NUMBER := FND_GLOBAL.USER_ID,
      p_login_id              IN  	  NUMBER  	:= NULL,
      p_transaction_control   IN          VARCHAR2 := FND_API.G_TRUE,
      p_est_detail_rec        IN          CS_Charge_Details_PUB.Charges_Rec_Type);



-- Procedure Update Charge Detail
-- Updates CS_ESTIMATE_DETAILS

PROCEDURE Update_Charge_Details(
	p_api_version      	   IN  	      NUMBER,
	p_init_msg_list    	   IN         VARCHAR2 	    := FND_API.G_FALSE,
	p_commit           	   IN         VARCHAR2 	    := FND_API.G_FALSE,
	p_validation_level 	   IN  	      NUMBER 	    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status    	   OUT NOCOPY VARCHAR2,
	x_msg_count         	   OUT NOCOPY NUMBER,
	x_object_version_number    OUT NOCOPY NUMBER,
	x_msg_data         	   OUT NOCOPY VARCHAR2,
	--p_resp_appl_id    	   IN  	      NUMBER  	    := NULL,
	--p_resp_id          	   IN  	      NUMBER  	    := NULL,
    --	p_user_id          	   IN  	      NUMBER  	    := NULL,
        p_resp_appl_id         IN         NUMBER := FND_GLOBAL.RESP_APPL_ID,
        p_resp_id              IN         NUMBER := FND_GLOBAL.RESP_ID,
        p_user_id              IN         NUMBER := FND_GLOBAL.USER_ID,
	p_login_id         	   IN  	      NUMBER  	    := NULL,
        p_transaction_control      IN         VARCHAR2      := FND_API.G_TRUE,
	p_est_detail_rec           IN         CS_Charge_Details_PUB.Charges_Rec_Type);


 -- Procedure Delete Charge Detail
--  Deletes CS_ESTIMATE_DETAILS

 PROCEDURE Delete_Charge_Details(
             p_api_version          IN         NUMBER,
             p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
             p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
             p_validation_level     IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
             x_return_status        OUT NOCOPY VARCHAR2,
             x_msg_count            OUT NOCOPY NUMBER,
             x_msg_data             OUT NOCOPY VARCHAR2,
             p_transaction_control  IN         VARCHAR2 := FND_API.G_TRUE,
             p_estimate_detail_id   IN         NUMBER   := NULL) ;

-- Procedure Copy Estimate
-- Copies Estimate from CS_ESTIMATE_DETAILS

Procedure  Copy_Estimate(
        p_api_version         IN         NUMBER,
        p_init_msg_list       IN         VARCHAR2 := FND_API.G_FALSE,
        p_commit              IN         VARCHAR2 := FND_API.G_FALSE,
        p_transaction_control IN         VARCHAR2 := FND_API.G_TRUE,
        p_estimate_detail_id  IN         NUMBER   := NULL,
        x_estimate_detail_id  OUT NOCOPY NUMBER,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2);

-- Procedure Get Contracts
-- Get Contract
-- Chaged for R12 contract re-arch changes

procedure get_contract(
      p_api_name               IN VARCHAR2,
      p_contract_SR_ID         IN NUMBER,
      p_incident_date          IN DATE,
      p_creation_date          IN DATE,
      p_customer_id            IN NUMBER,
      p_cust_account_id        IN NUMBER,
      p_cust_product_id        IN NUMBER,
      p_system_id              IN NUMBER DEFAULT NULL,
      p_inventory_item_id      IN NUMBER DEFAULT NULL,
      p_business_process_id    IN NUMBER,
      x_contract_id            OUT NOCOPY NUMBER,
      x_po_number              OUT NOCOPY VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2);

-- Procedure to validate charge lines related to an SR
-- and indicating if the SR can be purged or not.

PROCEDURE Purge_Chg_Validations
    (
        p_api_version_number IN  NUMBER := 1.0
    ,   p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
    ,   p_commit             IN  VARCHAR2 := FND_API.G_FALSE
    ,   p_object_type        IN  VARCHAR2
    ,   p_processing_set_id  IN  NUMBER
    ,   x_return_status      OUT NOCOPY  VARCHAR2
    ,   x_msg_count          OUT NOCOPY  NUMBER
    ,   x_msg_data           OUT NOCOPY  VARCHAR2
    );

-- Procedure to purge charge lines attached to an SR.

PROCEDURE Purge_Charges
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


 END CS_Charge_Details_PVT;

 

/
