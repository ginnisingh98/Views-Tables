--------------------------------------------------------
--  DDL for Package CS_CHARGE_CONTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHARGE_CONTRACT_PKG" AUTHID CURRENT_USER as
/*$Header: cschcons.pls 120.0.12010000.1 2010/04/06 11:11:49 gasankar noship $*/

PROCEDURE Get_Contract_Price_List (
                 P_Api_Version              IN NUMBER default null,
                 P_Init_Msg_List            IN VARCHAR2 ,
                 p_contract_line_id         IN NUMBER,
                 p_business_process_id      IN NUMBER,
                 p_request_date             IN DATE,
                 x_return_status            OUT NOCOPY VARCHAR2,
                 x_msg_count                OUT NOCOPY NUMBER,
                 x_msg_data                 OUT NOCOPY VARCHAR2,
		 x_contract_line_id         OUT NOCOPY Number,
                 x_business_process_id      OUT NOCOPY NUMBER,
                 x_BP_Price_list_id         OUT NOCOPY NUMBER,
                 x_BP_Discount_id           OUT NOCOPY NUMBER,
                 x_BP_start_date            OUT NOCOPY DATE,
                 x_BP_end_date              OUT NOCOPY DATE,
                 x_Contract_Price_list_Id   OUT NOCOPY NUMBER ) ;

END CS_Charge_Contract_PKG;

/
