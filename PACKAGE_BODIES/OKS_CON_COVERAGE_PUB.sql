--------------------------------------------------------
--  DDL for Package Body OKS_CON_COVERAGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CON_COVERAGE_PUB" AS
/* $Header: OKSPACCB.pls 120.0 2005/05/25 18:25:54 appldev noship $ */

  PROCEDURE apply_contract_coverage
	(p_api_version             IN  Number
	,p_init_msg_list           IN  Varchar2
    ,p_est_amt_tbl             IN  ser_tbl_type
	,x_return_status           OUT NOCOPY Varchar2
	,x_msg_count               OUT NOCOPY Number
	,x_msg_data		         OUT NOCOPY Varchar2
	,x_est_discounted_amt_tbl  OUT NOCOPY cov_tbl_type)
  IS
   l_return_status	Varchar2(1);
   l_api_name           CONSTANT VARCHAR2(30) := 'apply_contract_coverage';
  BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

	OKS_CON_COVERAGE_PVT.apply_contract_coverage
			(p_api_version
			,p_init_msg_list
      		,p_est_amt_tbl
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_est_discounted_amt_tbl);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');

  END apply_contract_coverage;

  PROCEDURE get_bp_pricelist
	(p_api_version	        IN  Number
	,p_init_msg_list	        IN  Varchar2
    ,p_Contract_line_id		IN NUMBER
    ,p_business_process_id  IN NUMBER
    ,p_request_date         IN DATE
	,x_return_status 	        OUT NOCOPY Varchar2
	,x_msg_count	        OUT NOCOPY Number
	,x_msg_data		        OUT NOCOPY Varchar2
	,x_pricing_tbl		OUT NOCOPY PRICING_TBL_TYPE )
IS
   l_return_status	 Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_bp_pricelist';

  BEGIN
   l_return_status	 := OKC_API.G_RET_STS_SUCCESS;

       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

	OKS_CON_COVERAGE_PVT.get_bp_pricelist
			(p_api_version
			,p_init_msg_list
      		,p_Contract_line_id
            ,p_business_process_id
            ,p_request_date
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_pricing_tbl);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');

  END get_bp_pricelist;

  PROCEDURE get_bill_rates
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,P_input_br_rec         IN INPUT_BR_REC
    ,P_labor_sch_tbl        IN LABOR_SCH_TBL_TYPE
    ,x_return_status        OUT NOCOPY Varchar2
    ,x_msg_count            OUT NOCOPY Number
    ,x_msg_data             OUT NOCOPY Varchar2
    ,X_bill_rate_tbl        OUT NOCOPY BILL_RATE_TBL_TYPE )
  IS
   l_return_status	 Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_bill_rates';

  BEGIN
   l_return_status	 := OKC_API.G_RET_STS_SUCCESS;

       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

	OKS_CON_COVERAGE_PVT.get_bill_rates
			(p_api_version
			,p_init_msg_list
      		,P_input_br_rec
            ,P_labor_sch_tbl
			,x_return_status
			,x_msg_count
			,x_msg_data
			,X_bill_rate_tbl);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
  END get_bill_rates;

END OKS_CON_COVERAGE_PUB;

/
