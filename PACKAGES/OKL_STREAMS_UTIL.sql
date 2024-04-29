--------------------------------------------------------
--  DDL for Package OKL_STREAMS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAMS_UTIL" AUTHID CURRENT_USER AS
/* $Header: OKLRSULS.pls 120.9.12010000.3 2009/07/29 10:10:28 racheruv ship $ */

  SUBTYPE FILE_TYPE   IS UTL_FILE.FILE_TYPE;
  TYPE    LOG_MSG_TBL IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_APP_NAME		      CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_STREAMS_UTIL';


  G_MISS_NUM				  CONSTANT NUMBER   	:=  Okl_Api.G_MISS_NUM;
  G_MISS_CHAR				  CONSTANT VARCHAR2(1)	:=  Okl_Api.G_MISS_CHAR;
  G_MISS_DATE				  CONSTANT DATE   	:=  Okl_Api.G_MISS_DATE;
  G_TRUE				  CONSTANT VARCHAR2(1)	:=  Okl_Api.G_TRUE;
  G_FALSE				  CONSTANT VARCHAR2(1)	:=  Okl_Api.G_FALSE;

  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := Okl_Api.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := Okl_Api.G_RET_STS_UNEXP_ERROR;

  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR			EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;

  G_LOG_DIR CONSTANT VARCHAR2(30) := 'ECX_UTL_LOG_DIR';
  -- Start for Bug#2807737 changes
  ---------------------------------------------------------------------------
  -- GLOBAL PL/SQL table types for Bulk insert
  ---------------------------------------------------------------------------
  TYPE ClobTabTyp IS TABLE OF CLOB
       INDEX BY BINARY_INTEGER;

  TYPE DateTabTyp IS TABLE OF DATE
       INDEX BY BINARY_INTEGER;

  TYPE NumberTabTyp IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

  TYPE Number15TabTyp IS TABLE OF NUMBER(15)
       INDEX BY BINARY_INTEGER;

  --Added by kthiruva on 12-May-2005 for Streams Perf
  TYPE Number9TabTyp IS TABLE OF NUMBER(9)
       INDEX BY BINARY_INTEGER;

   --Added by gboomina on 14-Oct-2005 for Accruals Performance Improvement
     --Bug 4662173 - Start of Changes
     TYPE Number15NoPrecisionTabTyp IS TABLE OF NUMBER(15,0)
          INDEX BY BINARY_INTEGER;
     --Bug 4662173 - End of Changes

  TYPE Var10TabTyp IS TABLE OF VARCHAR2(10)
       INDEX BY BINARY_INTEGER;

  TYPE Var12TabTyp IS TABLE OF VARCHAR2(12)
       INDEX BY BINARY_INTEGER;

  TYPE Var120TabTyp IS TABLE OF VARCHAR2(120)
       INDEX BY BINARY_INTEGER;

  TYPE Var15TabTyp IS TABLE OF VARCHAR2(15)
       INDEX BY BINARY_INTEGER;

  TYPE Var150TabTyp IS TABLE OF VARCHAR2(150)
       INDEX BY BINARY_INTEGER;

  TYPE Var1995TabTyp IS TABLE OF VARCHAR2(1995)
       INDEX BY BINARY_INTEGER;

  TYPE Var24TabTyp IS TABLE OF VARCHAR2(24)
       INDEX BY BINARY_INTEGER;

  TYPE Var200TabTyp IS TABLE OF VARCHAR2(200)
       INDEX BY BINARY_INTEGER;

  TYPE Var240TabTyp IS TABLE OF VARCHAR2(240)
       INDEX BY BINARY_INTEGER;

  TYPE Var3TabTyp IS TABLE OF VARCHAR2(3)
       INDEX BY BINARY_INTEGER;

  TYPE Var30TabTyp IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;

  TYPE Var300TabTyp IS TABLE OF VARCHAR2(300)
       INDEX BY BINARY_INTEGER;

  TYPE Var40TabTyp IS TABLE OF VARCHAR2(40)
       INDEX BY BINARY_INTEGER;

  TYPE Var450TabTyp IS TABLE OF VARCHAR2(450)
       INDEX BY BINARY_INTEGER;

  TYPE Var50TabTyp IS TABLE OF VARCHAR2(50)
       INDEX BY BINARY_INTEGER;

  TYPE Var600TabTyp IS TABLE OF VARCHAR2(600)
       INDEX BY BINARY_INTEGER;

  TYPE Var75TabTyp IS TABLE OF VARCHAR2(75)
       INDEX BY BINARY_INTEGER;

  TYPE Var90TabTyp IS TABLE OF VARCHAR2(90)
       INDEX BY BINARY_INTEGER;

   --Added by gboomina for Accruals Performance Improvement on the 14-Oct-2005
     --Bug 4662173 - Start of Changes
     TYPE Var45TabTyp IS TABLE OF VARCHAR2(45)
          INDEX BY BINARY_INTEGER;
     --Bug 4662173 - End of Changes


  TYPE okl_strm_type_id_tbl_type IS TABLE OF okl_strm_type_b.ID%TYPE
       INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- End for Bug#2807737 changes
  -- PRCODURE  LOG_MESSAGE
  ---------------------------------------------------------------------------
  PROCEDURE LOG_MESSAGE(p_msg_name            IN     VARCHAR2,
                        p_translate           IN  VARCHAR2 DEFAULT G_TRUE,
                        p_file_name            IN     VARCHAR2,
			x_return_status 	   OUT NOCOPY VARCHAR2);

  PROCEDURE LOG_MESSAGE(p_msgs_tbl            IN  log_msg_tbl,
                        p_translate           IN  VARCHAR2 DEFAULT G_TRUE,
                        p_file_name           IN  VARCHAR2,
			x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE LOG_MESSAGE(p_msg_count            IN     NUMBER,
                        p_file_name            IN     VARCHAR2,
			x_return_status 	   OUT NOCOPY VARCHAR2
                       );

  PROCEDURE GET_FND_PROFILE_VALUE(p_name IN VARCHAR2,
                                  x_value OUT NOCOPY VARCHAR2);

-- BAKUCHIB Bug 2835092 start
--------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : round_streams_amount
-- Description          : Returns PL/SQL table of record rounded amounts
--                        of OKL_STRM_ELEMENTS type
-- Business Rules       : We sum the amounts given as I/P PL/SQL table first.
--                        And then we round the amounts using existing
--                        rounding rule and then sum them these up.
--                        If we find a difference between rounded amount
--                        and non-rounded amount then based on already existing
--                        rule we do adjustment to the first amount or
--                        last amount or the High value amount of the PL/SQL
--                        table of records.We then give the rounded values
--                        thru O/P PL/SQL table of records.
-- Parameters           : P_chr_id,
--                        p_selv_tbl of OKL_STRM_ELEMENTS type
--                        x_selv_tbl of OKL_STRM_ELEMENTS type
-- Version              : 1.0
-- History              : BAKUCHIB  31-JUL-2003 - 2835092 created
-- End of Commnets
--------------------------------------------------------------------------------
  FUNCTION Round_Streams_Amount(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_chr_id         IN okc_k_headers_b.id%TYPE,
                                p_selv_tbl       IN Okl_Streams_Pub.selv_tbl_type,
                                x_selv_tbl       OUT NOCOPY Okl_Streams_Pub.selv_tbl_type)
  RETURN VARCHAR2;
-- BAKUCHIB Bug 2835092 End

/*
-- Returns the primary stream type id for primary stream purpose for a contract
*/

PROCEDURE get_primary_stream_type
(
 p_khr_id  		   	     IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_primary_sty_id 		OUT NOCOPY okl_strm_type_b.ID%TYPE
);

/*
-- Returns the primary stream type id for primary stream purpose for a contract
--for reporting stream
*/

PROCEDURE get_primary_stream_type_rep
(
 p_khr_id  		   	     IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_primary_sty_id 		OUT NOCOPY okl_strm_type_b.ID%TYPE
);

/*
-- Returns the dep stream type id for dep stream purpose for a contract
*/


PROCEDURE get_dependent_stream_type
(
 p_khr_id  		   IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_purpose     IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 p_dependent_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status	   OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	   OUT NOCOPY okl_strm_type_b.ID%TYPE
);

PROCEDURE get_dependent_stream_type
(
 p_khr_id  		 IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_id        IN okl_strm_type_b.ID%TYPE,
 p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status	 OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE
);

-- Added for bug 6326479
PROCEDURE get_dependent_stream_type
(
 p_khr_id  		      IN okl_k_headers_full_v.id%TYPE,
 p_product_id                 IN okl_k_headers_full_v.pdt_id%TYPE,
 p_primary_sty_purpose        IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 p_dependent_sty_purpose      IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status	      OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	      OUT NOCOPY okl_strm_type_b.ID%TYPE
);

PROCEDURE get_dependent_stream_type_rep
(
 p_khr_id  		   IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_purpose     IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 p_dependent_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status	   OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	   OUT NOCOPY okl_strm_type_b.ID%TYPE
);

PROCEDURE get_dependent_stream_type_rep
(
 p_khr_id  		 IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_id        IN okl_strm_type_b.ID%TYPE,
 p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status	 OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE
);

-- Added for bug 6326479
PROCEDURE get_dependent_stream_type_rep
(
 p_khr_id  		      IN okl_k_headers_full_v.id%TYPE,
 p_product_id                 IN okl_k_headers_full_v.pdt_id%TYPE,
 p_primary_sty_purpose        IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 p_dependent_sty_purpose      IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status	      OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	      OUT NOCOPY okl_strm_type_b.ID%TYPE
);

FUNCTION strm_tmpt_contains_strm_type
(
 p_khr_id  		 IN okl_k_headers_full_v.id%TYPE,
 p_sty_id        IN okl_strm_type_b.ID%TYPE
)
RETURN VARCHAR2;

-- Gets the status of the stream generation request for external generator
PROCEDURE get_transaction_status
(
 p_transaction_number  IN okl_stream_interfaces.transaction_number%TYPE,
 x_transaction_status  OUT NOCOPY okl_stream_interfaces.sis_code%TYPE,
 x_logfile_name        OUT NOCOPY okl_stream_interfaces.log_file%TYPE,
 x_return_status       OUT NOCOPY VARCHAR2
);


-- Added by Santonyr
--------------------------------------------------------------------------------
-- Start of Commnets
-- Procedure Name       : get_pricing_engine
-- Description          : Returns pricing engine for a contract based on the product
--                        stream template
-- Business Rules       :
-- Parameters           : p_khr_id,
-- Version              : 1.0
-- History              : santonyr 10-Dec-2004 - created
-- End of Commnets
--------------------------------------------------------------------------------

FUNCTION get_pricing_engine(p_khr_id IN okl_k_headers.id%TYPE)
RETURN VARCHAR2;


-- Added by Santonyr
--------------------------------------------------------------------------------
-- Start of Commnets
-- Procedure Name       : get_pricing_engine
-- Description          : Returns pricing engine for a contract based on the product
--                        stream template
-- Business Rules       :
-- Parameters           : p_khr_id,
-- Version              : 1.0
-- History              : santonyr 10-Dec-2004 - created
-- End of Commnets
--------------------------------------------------------------------------------

PROCEDURE get_pricing_engine
	(p_khr_id IN okl_k_headers.id%TYPE,
	x_pricing_engine OUT NOCOPY VARCHAR2,
	x_return_status OUT NOCOPY VARCHAR2);


-- Added by rgooty
--------------------------------------------------------------------------------
-- Start of Commnets
-- Procedure Name       : round_streams_amount_esg
-- Description          : Returns PL/SQL table of record rounded amounts
--                        of OKL_STRM_ELEMENTS type.
--                        This function will be used in the ESG call for
--                        rounding amounts.
-- Business Rules       : Same as method round_streams_amount.
-- Parameters           : P_chr_id,
--                        p_selv_tbl of OKL_STRM_ELEMENTS type
--                        x_selv_tbl of OKL_STRM_ELEMENTS type
--                        p_org_id   of OKC_K_HEADERS_B.AUTHORING_ORG_ID type
--                        p_precision
--                        p_currency_code of okc_k_headers_b.currency_code type
--                        p_rounding_rule of okl_sys_acct_opts.stm_rounding_rule type
--                        p_apply_rnd_diff of
--                           okl_sys_acct_opts.stm_apply_rounding_difference type
-- Version              : 1.0
-- End of Commnets
--------------------------------------------------------------------------------
  --Bug 4196515 - Start of Changes
  FUNCTION round_streams_amount_esg(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_chr_id         IN okc_k_headers_b.id%TYPE,
                                p_selv_tbl       IN okl_streams_pub.selv_tbl_type,
                                x_selv_tbl       OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                p_org_id         IN okc_k_headers_b.authoring_org_id%TYPE,
                                p_precision      IN NUMBER,
                                p_currency_code  IN okc_k_headers_b.currency_code%TYPE,
                                p_rounding_rule  IN okl_sys_acct_opts.stm_rounding_rule%TYPE,
                                p_apply_rnd_diff IN okl_sys_acct_opts.stm_apply_rounding_difference%TYPE)
  RETURN VARCHAR2;
  --Bug 4196515 - End of Changes

  -- Added by RGOOTY: Start
    --------------------------------------------------------------------------------
    -- Start of Commnets
    -- Procedure Name       : get_acc_options
    -- Description          : Returns the Accounting Options to be
    --                        used for the contract with the khr_id passed.
    --
    -- Business Rules       : Returns accounting options for a contract
    -- Parameters           : P_khr_id - Id of the Contract,
    --   Returns              x_org_id - Org Id
    --                        x_precision - Precision
    --                        x_currency_code - Currency Code
    --                        x_rounding_rule - Rounding Rule
    --                        x_apply_rnd_diff - Apply rounding Difference
    --                        x_return_status - Return Status of the API
    -- Version              : 1.0
    -- End of Commnets
    --------------------------------------------------------------------------------
    PROCEDURE get_acc_options(  p_khr_id         IN  okc_k_headers_b.ID%TYPE,
                                x_org_id         OUT NOCOPY okc_k_headers_b.authoring_org_id%TYPE,
                                x_precision      OUT NOCOPY NUMBER,
                                x_currency_code  OUT NOCOPY okc_k_headers_b.currency_code%TYPE,
                                x_rounding_rule  OUT NOCOPY okl_sys_acct_opts.stm_rounding_rule%TYPE,
                                x_apply_rnd_diff OUT NOCOPY okl_sys_acct_opts.stm_apply_rounding_difference%TYPE,
                                x_return_status  OUT NOCOPY VARCHAR2 );

  -- Added by RGOOTY: End

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : accumulate_strm_elements
  -- Description          : Appends the Stream Elements obtained to an
  --                         accumulating table
  --
  -- Business Rules       : Returns accumulated Stream elements table
  -- Parameters           : p_stmv_rec      - Stream Header record to be appended
  --   Returns              x_full_stmv_tbl - Stream Headers accumulating table
  --                        x_return_status - Return Status of the API
  -- Version              : rgooty 1.0 created
  -- End of Commnets
  --------------------------------------------------------------------------------
  --Modified by kthiruva on 30-May-2005. The OUT parameter was made NOCOPY
  --Bug 4374085 - Start of Changes
  PROCEDURE accumulate_strm_headers(
    p_stmv_rec       IN            Okl_Streams_Pub.stmv_rec_type,
    x_full_stmv_tbl  IN OUT NOCOPY Okl_Streams_Pub.stmv_tbl_type,
    x_return_status  OUT NOCOPY    VARCHAR2);
  --Bug 4374085 - End of Changes

  -- Added by RGOOTY: Start
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : accumulate_strm_elements
  -- Description          : Appends the Stream Elements obtained to an
  --                         accumulating table
  --
  -- Business Rules       : Returns accumulated Stream elements table
  -- Parameters           : p_stm_index_no  - Stream Header index number
  --                        p_selv_tbl      - Intermediate Stream Elements table
  --   Returns              x_full_selv_tbl - Returns the accumulated stream elements table
  --                        x_return_status - Return Status of the API
  -- Version              : rgooty 1.0 created
  -- End of Commnets
  --------------------------------------------------------------------------------
  --Modified by kthiruva on 30-May-2005. The OUT parameter was made NOCOPY
  --Bug 4374085 - Start of Changes
  PROCEDURE accumulate_strm_elements(
    p_stm_index_no   IN            NUMBER,
    p_selv_tbl       IN            okl_streams_pub.selv_tbl_type,
    x_full_selv_tbl  IN OUT NOCOPY okl_streams_pub.selv_tbl_type,
    x_return_status  OUT NOCOPY    VARCHAR2);
  --Bug 4374085 - End of Changes

  -- Added by kthiruva on 10-Oct-2005
  -- Bug 4664698 - Start of changes
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_line_id
  -- Description          : Fetches the contract line id from the stream interface
  --                        tables during the inbound processing
  --
  -- Business Rules       : Returns kle_id
  -- Parameters           : p_trx_number    - Transaction number of the pricing
  --                                          request
  --                        p_index_number  - The index number which uniquely
  --                                          defines every asset line
  -- Returns                x_kle_id        - Id of the asset
  --                        x_return_status - Return Status of the API
  -- Version              : kthiruva 1.0 Created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE get_line_id(
    p_trx_number     IN         okl_stream_interfaces.TRANSACTION_NUMBER%TYPE,
    p_index_number   IN         okl_sif_ret_levels.INDEX_NUMBER%TYPE,
    x_kle_id         OUT NOCOPY NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2);
  -- Bug 4664698 - End of Changes

  PROCEDURE get_k_trx_state(p_trx_id       IN NUMBER,
							x_rebook_type  OUT NOCOPY VARCHAR2,
							x_rebook_date  OUT NOCOPY DATE,
							x_query_trx_state OUT NOCOPY VARCHAR2,
							x_trx_state    OUT NOCOPY CLOB);

  -- Procedure to update okl_stream_trx_data to indicate the last transaction state.
  -- p_khr_id = contract_id; p_context: can have 3 values
  -- 1. 'BOTH' 2. PRIMARY 3. REPORT

  PROCEDURE UPDATE_TRX_STATE(P_KHR_ID IN NUMBER,
                             P_CONTEXT IN VARCHAR2);

END Okl_Streams_Util;

/
