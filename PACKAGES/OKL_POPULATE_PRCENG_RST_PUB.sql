--------------------------------------------------------
--  DDL for Package OKL_POPULATE_PRCENG_RST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_POPULATE_PRCENG_RST_PUB" AUTHID CURRENT_USER AS
/*$Header: OKLPPRSS.pls 120.1 2005/05/30 12:27:05 kthiruva noship $*/

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_POPULATE_PR_ENG_RESULT_PUB';

  G_APP_NAME				  CONSTANT VARCHAR2(3)  :=  OKL_API.G_APP_NAME;
  G_MISS_NUM				  CONSTANT NUMBER   	:=  OKL_API.G_MISS_NUM;
  G_MISS_CHAR				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_MISS_CHAR;
  G_MISS_DATE				  CONSTANT DATE   	    :=  OKL_API.G_MISS_DATE;
  G_TRUE				      CONSTANT VARCHAR2(1)	:=  OKL_API.G_TRUE;
  G_FALSE				      CONSTANT VARCHAR2(1)	:=  OKL_API.G_FALSE;

  G_EXC_NAME_ERROR		      CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	  CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	          CONSTANT VARCHAR2(6)  := 'OTHERS';
  G_API_TYPE			      CONSTANT VARCHAR(4)   := '_PUB';
  G_RET_STS_SUCCESS		      CONSTANT VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		      CONSTANT VARCHAR2(1)  := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		  CONSTANT VARCHAR2(1)  := OKL_API.G_RET_STS_UNEXP_ERROR;


  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR			  		EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;

  --Added by KTHIRUVA for the Inbound Parser Changes
  G_XMLG_RECEIVE_EVENT        CONSTANT VARCHAR2(50) := 'oracle.apps.okl.inbound.lease.receive';

  --Added by BKATRAGA
  --Bug - Start of Changes
  TYPE strm_rec_type IS RECORD (
    strm_name   OKL_SIF_RET_STRMS.STREAM_TYPE_NAME%TYPE,
    strm_desc   VARCHAR2(150),
    sre_date    VARCHAR2(30),
    amount      NUMBER,
    --Added by kthiruva for Streams Performance
    --Bug 4346646 - Start of Changes
    index_number NUMBER
    --Bug 4346646 - End of Changes
    );

  TYPE strm_tbl_type IS TABLE OF strm_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE strm_excp_rec_type IS RECORD (
    error_code     OKL_SIF_RET_ERRORS.ERROR_CODE%TYPE,
    error_message  OKL_SIF_RET_ERRORS.ERROR_MESSAGE%TYPE,
    tag_name       OKL_SIF_RET_ERRORS.TAG_NAME%TYPE
    );

  TYPE strm_excp_tbl_type IS TABLE OF strm_excp_rec_type
        INDEX BY BINARY_INTEGER;

  SUBTYPE srsv_tbl_type IS okl_srs_pvt.srsv_tbl_type;
  --Bug - End of Changes

  SUBTYPE sirv_rec_type IS okl_sir_pvt.sirv_rec_type;
  SUBTYPE srsv_rec_type IS okl_srs_pvt.srsv_rec_type;
  SUBTYPE srmv_rec_type IS okl_srm_pvt.srmv_rec_type;
  SUBTYPE sifv_rec_type IS okl_sif_pvt.sifv_rec_type;
  SUBTYPE srlv_rec_type IS okl_srl_pvt.okl_sif_ret_levels_v_rec_type;
  SUBTYPE LOG_MSG_TBL_TYPE IS Okl_Streams_Util.LOG_MSG_TBL;

	-- mvasudev, 04/24/2002 added
  PROCEDURE populate_sif_rets (
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_id                             OUT NOCOPY NUMBER,
    p_transaction_number             IN NUMBER := OKC_API.G_MISS_NUM,
    p_srt_code                       IN OKL_SIF_RETS.SRT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    p_effective_pre_tax_yield        IN NUMBER := OKC_API.G_MISS_NUM,
    p_yield_name                     IN OKL_SIF_RETS.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
    p_index_number                   IN NUMBER := OKC_API.G_MISS_NUM,
    p_effective_after_tax_yield      IN NUMBER := OKC_API.G_MISS_NUM,
    p_nominal_pre_tax_yield          IN NUMBER := OKC_API.G_MISS_NUM,
    p_nominal_after_tax_yield        IN NUMBER := OKC_API.G_MISS_NUM,
    p_implicit_interest_rate         IN NUMBER := OKC_API.G_MISS_NUM
    );
	-- mvasudev, 04/24/2002 end

	-- mvasudev, 04/24/2002 added
  PROCEDURE update_sif_rets (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER,
    p_implicit_interest_rate       IN NUMBER := OKC_API.G_MISS_NUM);
	-- mvasudev, 04/24/2002 end

	-- mvasudev, 04/24/2002 added
  PROCEDURE update_sif_rets (
    p_id                 IN NUMBER,
    p_yield_name         IN VARCHAR2,
    p_amount             IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2);
	-- mvasudev, 04/24/2002 end

  --Modified by BKATRAGA
  --Bug - Start of Changes
  PROCEDURE populate_sif_ret_strms (
    x_return_status                  OUT NOCOPY VARCHAR2,
    p_index_number                   IN NUMBER := OKC_API.G_MISS_NUM,
    p_strm_tbl                       IN strm_tbl_type,
    p_sir_id                         IN NUMBER := OKC_API.G_MISS_NUM);

  PROCEDURE populate_sif_ret_errors (
    x_return_status          OUT NOCOPY VARCHAR2,
    x_id                     OUT NOCOPY NUMBER,
    p_sir_id                 IN NUMBER := OKC_API.G_MISS_NUM,
    p_error_code             IN OKL_SIF_RET_ERRORS.ERROR_CODE%TYPE := OKC_API.G_MISS_CHAR,
    p_error_message          IN OKL_SIF_RET_ERRORS.ERROR_MESSAGE%TYPE := OKC_API.G_MISS_CHAR,
    p_tag_name               IN OKL_SIF_RET_ERRORS.TAG_NAME%TYPE := OKC_API.G_MISS_CHAR,
    p_tag_attribute_name     IN OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    p_tag_attribute_value    IN OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_VALUE%TYPE := OKC_API.G_MISS_CHAR,
    p_description            IN OKL_SIF_RET_ERRORS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR);


  PROCEDURE populate_sif_ret_errors (
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_id                             OUT NOCOPY NUMBER,
    p_sir_id                         IN NUMBER := OKC_API.G_MISS_NUM,
    p_strm_excp_tbl                  IN strm_excp_tbl_type,
    p_tag_attribute_name             IN OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    p_tag_attribute_value            IN OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_VALUE%TYPE := OKC_API.G_MISS_CHAR,
    p_description                    IN OKL_SIF_RET_ERRORS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR);
  -- Bug -End Of Changes

  -- mvasudev, 04/24/2002 added
  PROCEDURE populate_insured_residual (
    p_transaction_number           IN NUMBER,
	p_amount					   IN NUMBER,
	p_sir_id					   IN NUMBER,
	x_return_status                OUT NOCOPY VARCHAR2);
	-- mvasudev, 04/24/2002 end

	-- mvasudev, 04/24/2002 added
  PROCEDURE update_status (
    p_transaction_number		   IN NUMBER,
    p_sis_code			   		   IN VARCHAR2, -- outbound status
    p_srt_code					   IN VARCHAR2, -- inbound status
	p_log_file_name  			   IN VARCHAR2,
    x_return_status				   OUT NOCOPY VARCHAR2);
	-- mvasudev, 04/24/2002 end

  PROCEDURE check_status (
    p_transaction_number		   IN NUMBER,
	x_ok_to_proceed                OUT NOCOPY VARCHAR2,
    x_return_status				   OUT NOCOPY VARCHAR2);

  PROCEDURE log_error_messages (
    p_transaction_number           IN NUMBER,
	x_return_status                OUT NOCOPY VARCHAR2
  );

  PROCEDURE populate_sif_ret_levels (
    p_sir_id                         IN NUMBER := OKC_API.G_MISS_NUM,
    p_index_number                   IN NUMBER := OKC_API.G_MISS_NUM,
    p_level_index_number             IN NUMBER := OKC_API.G_MISS_NUM,
    p_number_of_periods              IN NUMBER := OKC_API.G_MISS_NUM,
    p_level_type                     IN OKL_SIF_RET_LEVELS.LEVEL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    p_amount                         IN NUMBER := OKC_API.G_MISS_NUM,
    p_advance_or_arrears             IN OKL_SIF_RET_LEVELS.ADVANCE_OR_ARREARS%TYPE := OKC_API.G_MISS_CHAR,
    p_period                         IN OKL_SIF_RET_LEVELS.PERIOD%TYPE := OKC_API.G_MISS_CHAR,
    p_lock_level_step                IN OKL_SIF_RET_LEVELS.LOCK_LEVEL_STEP%TYPE := OKC_API.G_MISS_CHAR,
    p_days_in_period                 IN NUMBER := OKC_API.G_MISS_NUM,
    p_first_payment_date             IN VARCHAR2,
    p_rate                           IN NUMBER := OKC_API.G_MISS_NUM,
    x_return_status                  OUT NOCOPY VARCHAR2
	);

  --Added by RIRAWAT
  -- This procedure has been added to replace the call to the Inbound Workflow.
  -- The method Okl_Process_Streams_Pvt.process_stream_results is now being called
  -- directly instead of invoking it through the workflow.
  PROCEDURE process(   p_transaction_number		   IN NUMBER,
                       resultout   OUT NOCOPY VARCHAR2);

   FUNCTION correct_feb_date (p_date VARCHAR2)
   RETURN VARCHAR2;

  --Added by KTHIRUVA
  -- This procedure has been added to raise a business event once the call to
  -- Okl_Process_Streams_Pvt.process_stream_results completes
  PROCEDURE raise_business_event(p_transaction_number  IN NUMBER,
                                 x_return_status       OUT NOCOPY VARCHAR2);

END OKL_POPULATE_PRCENG_RST_PUB;

 

/
