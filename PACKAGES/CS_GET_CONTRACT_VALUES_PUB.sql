--------------------------------------------------------
--  DDL for Package CS_GET_CONTRACT_VALUES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_GET_CONTRACT_VALUES_PUB" AUTHID CURRENT_USER AS
/* $Header: csctvals.pls 115.3 99/07/16 08:55:38 porting ship  $ */

/*******************************************************************************
  --  GLOBAL VARIABLES
*******************************************************************************/

  G_PKG_NAME       CONSTANT   VARCHAR2(200)   := 'CS_CONTRACT_VALUES_PUB';
  G_APP_NAME       CONSTANT   VARCHAR2(3)     := 'CS';

/*******************************************************************************
  --  Procedures and Functions
*******************************************************************************/

  PROCEDURE Get_PO_Required (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_contract_id             IN  NUMBER,
                p_cp_service_id           IN  NUMBER,
                x_PO_required_for_service OUT VARCHAR2,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  );

  PROCEDURE Get_Pre_Payment_Required (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_contract_id             IN  NUMBER,
                p_cp_service_id           IN  NUMBER,
                x_pre_payment_required    OUT VARCHAR2,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  );

  PROCEDURE Get_Address (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_cp_service_id           IN  NUMBER,
  	           x_bill_address_id         OUT NUMBER,
                x_bill_address1           OUT VARCHAR2,
                x_bill_address2           OUT VARCHAR2,
                x_bill_address3           OUT VARCHAR2,
  	           x_ship_address_id         OUT NUMBER,
                x_ship_address1           OUT VARCHAR2,
                x_ship_address2           OUT VARCHAR2,
                x_ship_address3           OUT VARCHAR2,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  );

  PROCEDURE Get_Salesperson (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_contract_id             IN  NUMBER,
                p_cp_service_id           IN  NUMBER,
                x_salesperson_id          OUT NUMBER,
                x_salesperson             OUT VARCHAR2,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  );

  PROCEDURE Get_Auto_Renewal_Flag (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_contract_id             IN  NUMBER,
                p_cp_service_id           IN  NUMBER,
                x_auto_renewal_flag       OUT VARCHAR2,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  );

END CS_GET_CONTRACT_VALUES_PUB;

 

/
