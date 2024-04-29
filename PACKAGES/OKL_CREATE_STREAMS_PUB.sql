--------------------------------------------------------
--  DDL for Package OKL_CREATE_STREAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREATE_STREAMS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCSMS.pls 120.1.12010000.2 2009/08/10 14:39:35 rgooty ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_TRUE		        CONSTANT VARCHAR2(1) := OKL_API.G_TRUE;
  G_FALSE		CONSTANT VARCHAR2(1) := OKL_API.G_FALSE;

  G_APP_NAME	CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME    CONSTANT VARCHAR2(30)  := 'OKL_CREATE_STREAMS_PUB';

  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';


  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
  G_API_TYPE	CONSTANT VARCHAR(4) := '_PUB';
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;


  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR			EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;

  G_ORP_CODE_BOOKING        CONSTANT VARCHAR2(4) := Okl_Create_Streams_Pvt.G_ORP_CODE_BOOKING;
  G_ORP_CODE_RESTRUCTURE_AM CONSTANT VARCHAR2(4) := Okl_Create_Streams_Pvt.G_ORP_CODE_RESTRUCTURE_AM;
  G_ORP_CODE_RESTRUCTURE_CS CONSTANT VARCHAR2(4) := Okl_Create_Streams_Pvt.G_ORP_CODE_RESTRUCTURE_CS;
  G_ORP_CODE_UPGRADE        CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_ORP_CODE_UPGRADE;
  -- mvasudev , sno, changed "QUOT" to "QUOTE"
  G_ORP_CODE_QUOTE          CONSTANT VARCHAR2(4) := Okl_Create_Streams_Pvt.G_ORP_CODE_QUOTE;
  G_ORP_CODE_VARIABLE_INTEREST        CONSTANT VARCHAR2(4) := Okl_Create_Streams_Pvt.G_ORP_CODE_VARIABLE_INTEREST;
  G_ORP_CODE_RENEWAL CONSTANT VARCHAR2(4) := Okl_Create_Streams_Pvt.G_ORP_CODE_RENEWAL;

   G_EXPENSE		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_EXPENSE;
   G_INCOME		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_INCOME;
   G_ADVANCE		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_ADVANCE;
   G_ARREARS		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_ARREARS;
   G_FND_YES		CONSTANT VARCHAR2(1)  := Okl_Create_Streams_Pvt.G_FND_YES;
   G_FND_NO		CONSTANT VARCHAR2(1)  := Okl_Create_Streams_Pvt.G_FND_NO;
   G_CSM_TRUE		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_CSM_TRUE;
   G_CSM_FALSE		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_CSM_FALSE;

   G_LOCK_AMOUNT  CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_LOCK_AMOUNT;
   G_LOCK_RATE         CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_LOCK_RATE;
   G_LOCK_BOTH         CONSTANT VARCHAR2(10) :=Okl_Create_Streams_Pvt. G_LOCK_BOTH;
   G_MODE_LESSOR  CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_MODE_LESSOR;
   G_MODE_LENDER  CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_MODE_LENDER;
   G_MODE_BOTH        CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_MODE_BOTH;
   G_SFE_LEVEL_PAYMENT	CONSTANT VARCHAR2(7) :=  Okl_Create_Streams_Pvt.G_SFE_LEVEL_PAYMENT;
   G_SFE_LEVEL_INTEREST CONSTANT VARCHAR2(8) := Okl_Create_Streams_Pvt.G_SFE_LEVEL_INTEREST;
   G_SFE_LEVEL_PRINCIPAL CONSTANT VARCHAR2(9) := Okl_Create_Streams_Pvt.G_SFE_LEVEL_PRINCIPAL;
   G_SFE_LEVEL_FUNDING CONSTANT VARCHAR2(7) := Okl_Create_Streams_Pvt.G_SFE_LEVEL_FUNDING;
   G_ADJUST            CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_ADJUST;
   G_ADJUST_LOAN       CONSTANT VARCHAR2(30) := Okl_Create_Streams_Pvt.G_ADJUST_LOAN;
   G_ADJUSTMENT_METHOD CONSTANT VARCHAR2(20) := Okl_Create_Streams_Pvt.G_ADJUSTMENT_METHOD;


  SUBTYPE sifv_rec_type 		 IS okl_stream_interfaces_pub.sifv_rec_type;
  SUBTYPE csm_lease_rec_type 		 IS Okl_Create_Streams_Pvt.csm_lease_rec_type;
  SUBTYPE csm_one_off_fee_tbl_type 	 IS Okl_Create_Streams_Pvt.csm_one_off_fee_tbl_type;
  SUBTYPE csm_periodic_expenses_tbl_type IS Okl_Create_Streams_Pvt.csm_periodic_expenses_tbl_type;
  SUBTYPE csm_yields_tbl_type 		 IS Okl_Create_Streams_Pvt.csm_yields_tbl_type;
  SUBTYPE csm_stream_types_tbl_type 	 IS Okl_Create_Streams_Pvt.csm_stream_types_tbl_type;
  SUBTYPE csm_line_details_tbl_type 	 IS Okl_Create_Streams_Pvt.csm_line_details_tbl_type;

  SUBTYPE csm_loan_rec_type   		 IS Okl_Create_Streams_Pvt.csm_loan_rec_type;
  SUBTYPE csm_loan_line_tbl_type	 IS Okl_Create_Streams_Pvt.csm_loan_line_tbl_type;
  SUBTYPE csm_loan_level_tbl_type	 IS Okl_Create_Streams_Pvt.csm_loan_level_tbl_type;

 PROCEDURE Create_Streams_Lease_Book(
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_lease_header			IN  csm_lease_rec_type
       ,p_csm_one_off_fee_tbl			IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl			IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl				IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl			IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl    	        	IN  csm_line_details_tbl_type
       ,p_rents_tbl		     		IN  csm_periodic_expenses_tbl_type
       ,x_trans_id	   			OUT NOCOPY NUMBER
       ,x_trans_status		 OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
       );


 PROCEDURE Create_Streams_Loan_Book(
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_loan_header			IN  csm_loan_rec_type
       ,p_csm_loan_lines_tbl			IN  csm_loan_line_tbl_type
       ,p_csm_loan_levels_tbl			IN  csm_loan_level_tbl_type
       ,p_csm_one_off_fee_tbl		IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl	IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl			IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl		IN  csm_stream_types_tbl_type
       ,x_trans_id	   			    OUT NOCOPY NUMBER
       ,x_trans_status	   						OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
);


   PROCEDURE invoke_pricing_engine(
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_sifv_rec				IN  sifv_rec_type
       ,x_sifv_rec				OUT NOCOPY  sifv_rec_type
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
   );

  -- 04/30/2002
  -- Procedure to Create Streams for Lease Type Contract - Restructure
  PROCEDURE Create_Streams_Lease_Restr (
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_lease_header			IN 	csm_lease_rec_type
       ,p_csm_one_off_fee_tbl			IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl			IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl				IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl			IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl    	        	IN  csm_line_details_tbl_type
       ,p_rents_tbl		     		IN  csm_periodic_expenses_tbl_type
       ,x_trans_id	   			OUT NOCOPY NUMBER
       ,x_trans_status	   						OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
       );

  -- Procedure to Create Streams for Loan Type Contract
  PROCEDURE Create_Streams_Loan_Restr (
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_loan_header			IN  csm_loan_rec_type
       ,p_csm_loan_lines_tbl			IN  csm_loan_line_tbl_type
       ,p_csm_loan_levels_tbl			IN  csm_loan_level_tbl_type
       ,p_csm_one_off_fee_tbl		IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl	IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl			IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl		IN  csm_stream_types_tbl_type
       ,x_trans_id	   			    OUT NOCOPY NUMBER
       ,x_trans_status	   						OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
	);

   -- end, 04/30/2002

 PROCEDURE Create_Streams_Lease_Quote(
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_lease_header			IN  csm_lease_rec_type
       ,p_csm_one_off_fee_tbl			IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl			IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl				IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl			IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl    	        	IN  csm_line_details_tbl_type
       ,p_rents_tbl		     		IN  csm_periodic_expenses_tbl_type
       ,x_trans_id	   			OUT NOCOPY NUMBER
       ,x_trans_status		 OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2);


END Okl_Create_Streams_Pub;

/
