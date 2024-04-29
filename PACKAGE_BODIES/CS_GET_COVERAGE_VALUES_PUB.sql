--------------------------------------------------------
--  DDL for Package Body CS_GET_COVERAGE_VALUES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_GET_COVERAGE_VALUES_PUB" AS
/* $Header: csctcvgb.pls 115.0 99/07/16 08:52:00 porting ship  $ */
  -- Start of comments
  -- API name            : Get_Bill_Rates
  -- Type                : Public
  -- Pre-reqs            : None.
  -- Function            : This function will retrieve  the Bill rates for
  --                       the service customer as requested.
  -- Parameters          :
  -- IN                  :
  --                         p_api_version             NUMBER    Required
  --                         p_coverage_id             NUMBER    Required
  --                         p_exception_coverage_flag VARCHAR2
  --                         p_Business_process_id     NUMBER    Required
  --                         p_Bill_Rate_Code          NUMBER    Required
  --                         p_unit_of_measure_code    VARCHAR2  Required
  --                         p_list_price              NUMBER    Required
  --                         p_init_msg_list           VARCHAR2  Required
  --                         p_commit                  VARCHAR2  Required
  -- OUT                 :
  --        		         x_Flat_Rate               NUMBER,
  --        		         x_Percent_Rate            NUMBER,
  --        		         x_ltem_price              NUMBER,
  --                         x_return_status           VARCHAR2
  --                         x_msg_count               NUMBER
  --                         x_msg_data                VARCHAR2
  --End of comments

  PROCEDURE Get_Bill_Rates (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_coverage_id             IN  NUMBER,
		      p_exception_coverage_flag IN  VARCHAR2,
			 p_business_process_id     IN  NUMBER,
			 p_bill_rate_code          IN  VARCHAR2,
			 p_unit_of_measure_code    IN  VARCHAR2,
			 p_list_price              IN  NUMBER,
			 x_flat_rate               OUT NUMBER,
			 x_percent_rate            OUT NUMBER,
			 x_ltem_price              OUT NUMBER,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  ) IS
    l_coverage_id                         CS_COVERAGES.COVERAGE_ID%TYPE;

    CURSOR   Bill_Rate_UOM_csr IS
    SELECT   CBR.Flat_Rate,
		   CBR.Percent_Rate
    FROM     CS_COV_BILL_RATES            CBR,
		   CS_COVERAGE_TXN_GROUPS       CTG,
		   CS_COV_BILLING_TYPES         CBT,
		   CS_TXN_BILLING_TYPES         TBT,
		   CS_LOOKUPS                   LKT
    WHERE    CTG.Coverage_id              = l_coverage_id
    AND      CTG.Business_Process_Id      = p_business_process_id
    AND      CTG.Coverage_Txn_Group_Id    = CBT.Coverage_Txn_Group_Id
    AND      TBT.Txn_Billing_Type_Id      = CBT.Txn_Billing_Type_Id
    AND      TBT.Billing_Type             = 'L'
    AND      CBR.Coverage_Billing_Type_Id = CBT.Coverage_Billing_Type_Id
    AND      CBR.Unit_of_Measure_Code     = p_unit_of_measure_code
    AND      CBR.Rate_Type_Code           = p_bill_rate_code
    AND      LKT.Lookup_Code              = CBR.Rate_Type_Code
    AND      LKT.Lookup_Type              = 'BILLING_RATE';

    CURSOR   Bill_Rate_Null_UOM_csr IS
    SELECT   CBR.Flat_Rate,
		   CBR.Percent_Rate
    FROM     CS_COV_BILL_RATES            CBR,
		   CS_COVERAGE_TXN_GROUPS       CTG,
		   CS_COV_BILLING_TYPES         CBT,
		   CS_TXN_BILLING_TYPES         TBT,
		   CS_LOOKUPS                   LKT
    WHERE    CTG.Coverage_id              = l_coverage_id
    AND      CTG.Business_Process_Id      = p_business_process_id
    AND      CTG.Coverage_Txn_Group_Id    = CBT.Coverage_Txn_Group_Id
    AND      TBT.Txn_Billing_Type_Id      = CBT.Txn_Billing_Type_Id
    AND      TBT.Billing_Type             = 'L'
    AND      CBR.Coverage_Billing_Type_Id = CBT.Coverage_Billing_Type_Id
    AND      CBR.Unit_of_Measure_Code     IS NULL
    AND      CBR.Rate_Type_Code           = p_bill_rate_code
    AND      LKT.Lookup_Code              = CBR.Rate_Type_Code
    AND      LKT.Lookup_Type              = 'BILLING_RATE';
    l_api_name              CONSTANT VARCHAR2(30)  := 'Get_Bill_Rates';
    l_api_version           CONSTANT  NUMBER       := 1;
    l_return_status         VARCHAR2(1)            := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status   := TAPI_DEV_KIT.START_ACTIVITY(  l_api_name,
                                                       G_PKG_NAME,
                                                       l_api_version,
                                                       p_api_version,
                                                       p_init_msg_list,
                                                       '_pub',
                                                       x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (NVL(p_exception_coverage_flag,'N') = 'Y') THEN
	 CS_GET_COVERAGE_VALUES_PUB.Get_Exception_Coverage(
					 					      1,
										      FND_API.G_FALSE,
										      FND_API.G_FALSE,
										      p_coverage_id,
										      l_coverage_id,
										      x_return_status,
										      x_msg_count,
										      x_msg_data);
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
	   FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	   FND_MESSAGE.Set_Token('VALUE','EXCEPTION COVERAGE');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR)  THEN
	   FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	   FND_MESSAGE.Set_Token('VALUE','EXCEPTION COVERAGE');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
	 l_coverage_id := p_coverage_id;
    END IF;

    OPEN     Bill_Rate_UOM_Csr;
    FETCH    Bill_Rate_UOM_Csr
    INTO     x_flat_rate,
		   x_percent_rate;

    IF Bill_Rate_UOM_Csr%NOTFOUND THEN
      OPEN     Bill_Rate_Null_UOM_Csr;
      FETCH    Bill_Rate_Null_UOM_Csr
      INTO     x_flat_rate,
		     x_percent_rate;

--    IF Bill_Rate_Null_UOM_Csr%NOTFOUND THEN
--	 FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
--	 FND_MESSAGE.Set_Token('VALUE','BILL RATES');
--      RAISE FND_API.G_EXC_ERROR;
--    END IF;

      CLOSE Bill_Rate_Null_UOM_Csr;
    END IF;
    CLOSE Bill_Rate_UOM_Csr;

    IF (x_percent_rate IS NOT NULL)  AND
	  (p_list_price   IS NOT NULL)  THEN
      x_ltem_price    := NVL(p_list_price,0) * x_percent_rate/100;
    END IF;

    TAPI_DEV_KIT.END_ACTIVITY(p_commit,
                              x_msg_count,
                              x_msg_data);
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR   THEN
      x_return_status  := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
                          (l_api_name,
                           G_PKG_NAME,
                           'FND_API.G_RET_STS_ERROR',
                           x_msg_count,
                           x_msg_data,
                           '_pub');
      APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR   THEN
      x_return_status  := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
                          (l_api_name,
                           G_PKG_NAME,
                           'FND_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count,
                           x_msg_data,
                           '_pub');
      APP_EXCEPTION.RAISE_EXCEPTION;
/*
    WHEN OTHERS   THEN
      x_return_status  := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
                          (l_api_name,
                           G_PKG_NAME,
                           'OTHERS',
                           x_msg_count,
                           x_msg_data,
                           '_pub');
*/
  END Get_Bill_Rates;

/******************************************************************************/

  -- Start of comments
  -- API name            : Get_Preferred_Engineer
  -- Type                : Public
  -- Pre-reqs            : None.
  -- Function            : This function will retrieve the preferred engineer
  --                       associated with the service coverage specified.
  --
  -- Parameters          :   Specifiying the transaction group and the coverage.
  -- IN                  :
  --                         p_api_version             NUMBER    Required
  --                         p_coverage_id             NUMBER    Required
  --        		         p_business_process_id     VARCHAR2  Required
  --                         p_exception_coverage_flag VARCHAR2
  --                         p_init_msg_list           VARCHAR2  Required
  --                         p_commit                  VARCHAR2  Required
  -- OUT                 :
  --        		         x_preferred_engineer1     VARCHAR2
  --        		         x_preferred_engineer2     VARCHAR2
  --                         x_return_status           VARCHAR2
  --                         x_msg_count               NUMBER
  --                         x_msg_data                VARCHAR2
  --End of comments

  PROCEDURE Get_Preferred_Engineer (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_coverage_id             IN  NUMBER,
			 p_business_process_id     IN  VARCHAR2,
		      p_exception_coverage_flag IN  VARCHAR2,
			 x_preferred_engineer1     OUT VARCHAR2,
			 x_preferred_engineer2     OUT VARCHAR2,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  ) IS
    l_coverage_id                         CS_COVERAGES.COVERAGE_ID%TYPE;

    CURSOR   Preferred_Engineer_csr IS
    SELECT   TXN.Preferred_Engineer1,
		   TXN.Preferred_Engineer2
    FROM     CS_COVERAGE_TXN_GROUPS       TXN
    WHERE    TXN.Coverage_id              = l_coverage_id
    AND      TXN.Business_Process_Id      = p_business_Process_id;

    l_api_name              CONSTANT VARCHAR2(30)  := 'Get_Preferred_Engineer';
    l_api_version           CONSTANT  NUMBER       := 1;
    l_return_status         VARCHAR2(1)            := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status   := TAPI_DEV_KIT.START_ACTIVITY(  l_api_name,
                                                       G_PKG_NAME,
                                                       l_api_version,
                                                       p_api_version,
                                                       p_init_msg_list,
                                                       '_pub',
                                                       x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (NVL(p_exception_coverage_flag,'N') = 'Y') THEN
	 CS_GET_COVERAGE_VALUES_PUB.Get_Exception_Coverage(
					 					      1,
										      FND_API.G_FALSE,
										      FND_API.G_FALSE,
										      p_coverage_id,
										      l_coverage_id,
										      x_return_status,
										      x_msg_count,
										      x_msg_data);
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
	   FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	   FND_MESSAGE.Set_Token('VALUE','EXCEPTION COVERAGE');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR)  THEN
	   FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	   FND_MESSAGE.Set_Token('VALUE','EXCEPTION COVERAGE');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
	 l_coverage_id := p_coverage_id;
    END IF;

    OPEN     Preferred_Engineer_csr;
    FETCH    Preferred_Engineer_csr
    INTO     x_Preferred_Engineer1,
		   x_Preferred_Engineer2;

    IF Preferred_Engineer_csr%NOTFOUND THEN
	 FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	 FND_MESSAGE.Set_Token('VALUE','PREFERRED ENGINEER');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE Preferred_Engineer_csr;

    TAPI_DEV_KIT.END_ACTIVITY(p_commit,
                              x_msg_count,
                              x_msg_data);
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR   THEN
      x_return_status  := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
                          (l_api_name,
                           G_PKG_NAME,
                           'FND_API.G_RET_STS_ERROR',
                           x_msg_count,
                           x_msg_data,
                           '_pub');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR   THEN
      x_return_status  := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
                          (l_api_name,
                           G_PKG_NAME,
                           'FND_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count,
                           x_msg_data,
                           '_pub');
    WHEN OTHERS   THEN
      x_return_status  := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
                          (l_api_name,
                           G_PKG_NAME,
                           'OTHERS',
                           x_msg_count,
                           x_msg_data,
                           '_pub');
  END Get_Preferred_Engineer;

/******************************************************************************/

  -- Start of comments
  -- API name            : Get_Exception_Coverage
  -- Type                : Public
  -- Pre-reqs            : None.
  -- Function            : This function will retrieve the Exception coverage id
  --                       for the given coverage.
  --
  -- Parameters          :
  -- IN                  :
  --                         p_api_version             NUMBER    Required
  --                         p_coverage_id             NUMBER    Required
  --                         p_init_msg_list           VARCHAR2
  --                         p_commit                  VARCHAR2
  -- OUT                 :
  --                         x_exception_coverage_id   NUMBER
  --                         x_return_status           VARCHAR2
  --                         x_msg_count               NUMBER
  --                         x_msg_data                VARCHAR2
  --End of comments

  PROCEDURE Get_Exception_coverage (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_coverage_id             IN  NUMBER,
		      x_exception_coverage_id   OUT NUMBER,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  ) IS
    CURSOR   Exception_Coverage_csr IS
    SELECT   COV2.Coverage_id
    FROM     CS_COVERAGES COV1,
             CS_COVERAGES COV2
    WHERE    COV1.Coverage_id             = p_coverage_id
    AND      COV2.Coverage_id             = COV1.Exception_Coverage_id;

    l_api_name              CONSTANT VARCHAR2(30)  := 'Get_Exception_Coverage';
    l_api_version           CONSTANT  NUMBER       := 1;
    l_return_status         VARCHAR2(1)            := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status   := TAPI_DEV_KIT.START_ACTIVITY(  l_api_name,
                                                       G_PKG_NAME,
                                                       l_api_version,
                                                       p_api_version,
                                                       p_init_msg_list,
                                                       '_pub',
                                                       x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN   Exception_Coverage_csr;
    FETCH  Exception_Coverage_csr  INTO x_exception_coverage_id;

    IF Exception_coverage_csr%NOTFOUND THEN
	 FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	 FND_MESSAGE.Set_Token('VALUE','EXCEPTION COVERAGE');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE  Exception_Coverage_csr;

    TAPI_DEV_KIT.END_ACTIVITY(p_commit,
                              x_msg_count,
                              x_msg_data);
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR   THEN
      x_return_status  := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
                          (l_api_name,
                           G_PKG_NAME,
                           'FND_API.G_RET_STS_ERROR',
                           x_msg_count,
                           x_msg_data,
                           '_pub');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR   THEN
      x_return_status  := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
                          (l_api_name,
                           G_PKG_NAME,
                           'FND_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count,
                           x_msg_data,
                           '_pub');
    WHEN OTHERS   THEN
      x_return_status  := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
                          (l_api_name,
                           G_PKG_NAME,
                           'OTHERS',
                           x_msg_count,
                           x_msg_data,
                           '_pub');
  END Get_Exception_Coverage;

END CS_GET_COVERAGE_VALUES_PUB;

/
