--------------------------------------------------------
--  DDL for Package Body CS_CHARGE_CONTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CHARGE_CONTRACT_PKG" as
/* $Header: cschconb.pls 120.0.12010000.2 2010/04/21 05:18:38 gasankar noship $ */

/*********** Global  Variables  ********************************/
G_PKG_NAME     CONSTANT  VARCHAR2(30)  := 'CS_Charge_Contract_PKG' ;

PROCEDURE Get_Contract_Price_List (
                 P_Api_Version              IN NUMBER default null ,
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
                 x_Contract_Price_list_Id   OUT NOCOPY NUMBER ) IS

l_service_line_id Number     := p_contract_line_id;
l_business_process_id Number := p_business_process_id;
l_request_date Date          := p_request_date;
l_record_count Number;

lx_pricing_tbl oks_con_coverage_pub.pricing_tbl_type;
lx_return_status  VARCHAR2(1);
lx_msg_count      NUMBER;
lx_msg_data       VARCHAR2(2000);

l_api_name       CONSTANT  VARCHAR2(100) := 'Get_Contract_Price_List' ;
l_api_name_full  CONSTANT  VARCHAR2(100) := G_PKG_NAME || '.' || l_api_name ;
l_log_module     CONSTANT VARCHAR2(500) := 'cs.plsql.' || l_api_name_full || '.';


BEGIN

--add_to_temp_log('Inside Package');

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Api_Version              	:' || P_Api_Version
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Init_Msg_List            	:' || P_Init_Msg_List
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'p_contract_line_id        	:' || p_contract_line_id
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'p_business_process_id            	:' || p_business_process_id
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'p_request_date			:' || p_request_date
    );

  END IF;

    oks_con_coverage_pub.get_bp_pricelist(
            p_api_version => 1.0,
            p_init_msg_list => 'T',
            p_contract_line_id => l_service_line_id,
            p_business_process_id  => l_business_process_id,
            p_request_date => l_request_date,
            x_return_status => lx_return_status,
            x_msg_count => lx_msg_count,
            x_msg_data => lx_msg_data,
            x_pricing_tbl => lx_pricing_tbl);

    x_return_status := lx_return_status;
    x_msg_data := lx_msg_data;
    x_msg_count := lx_msg_count;


   IF lx_return_status = FND_API.G_RET_STS_SUCCESS AND lx_pricing_tbl.count > 0 THEN
       l_record_count := lx_pricing_tbl.first;
       x_BP_Price_list_id       := lx_pricing_tbl(l_record_count).bp_price_list_id;
       x_contract_line_id       := lx_pricing_tbl(l_record_count).contract_line_id;
       x_business_process_id    := lx_pricing_tbl(l_record_count).business_process_id;
       x_BP_Discount_id         := lx_pricing_tbl(l_record_count).BP_Discount_id;
       x_BP_start_date          := lx_pricing_tbl(l_record_count).BP_start_date;
       x_BP_end_date            := lx_pricing_tbl(l_record_count).BP_end_date;
       x_Contract_Price_list_Id := lx_pricing_tbl(l_record_count).Contract_Price_list_Id;

       --add_to_temp_log('x_BP_Price_list_id',x_BP_Price_list_id);


   END IF;


--x_return_status := FND_API.G_RET_STS_SUCCESS;

   EXCEPTION
      WHEN OTHERS THEN
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Contract_Price_List;

END CS_Charge_Contract_PKG;

/
