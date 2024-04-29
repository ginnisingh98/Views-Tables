--------------------------------------------------------
--  DDL for Package OKL_ISG_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ISG_UTILS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRIGUS.pls 120.6 2007/10/12 20:11:24 djanaswa ship $ */

  ---------------------------------------------------------------------------
   -- Cursor Definitions
  ---------------------------------------------------------------------------
   -- Added by RGOOTY: Start
   CURSOR G_GET_K_INFO_CSR(  l_khr_id NUMBER ) IS
     SELECT
           pdt.id  pdt_id,
           chr.start_date start_date,
           khr.deal_type deal_type,
           nvl(pdt.reporting_pdt_id, -1) report_pdt_id
     FROM   okc_k_headers_v chr,
           okl_k_headers khr,
           okl_products_v pdt
     WHERE khr.id = chr.id
        AND chr.id = l_khr_id
        AND khr.pdt_id = pdt.id(+);
   -- Added by RGOOTY: End

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_ISG_UTILS_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_COL_NAME_TOKEN     	 CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';

  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';

  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'ERROR_CODE';


  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------

  G_EXCEPTION_HALT     EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

    PROCEDURE validate_strm_gen_template(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_khr_id                      IN  NUMBER);

              PROCEDURE get_primary_stream_type(
            p_khr_id  		   	     IN NUMBER,
            p_pdt_id              IN NUMBER,
            p_primary_sty_purpose    IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
            x_return_status		     OUT NOCOPY VARCHAR2,
            x_primary_sty_id 		 OUT NOCOPY okl_strm_type_b.ID%TYPE,
            x_primary_sty_name       OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE);

    PROCEDURE get_primary_stream_type(
            p_khr_id  		   	     IN NUMBER,
            p_deal_type              IN OKL_ST_GEN_TMPT_SETS.deal_type%TYPE,
            p_primary_sty_purpose    IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
            x_return_status		     OUT NOCOPY VARCHAR2,
            x_primary_sty_id 		 OUT NOCOPY okl_strm_type_b.ID%TYPE,
            x_primary_sty_name       OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE);

   PROCEDURE get_dependent_stream_type(
            p_khr_id  		   	     IN NUMBER,
            p_pdt_id              IN NUMBEr,
            p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
            x_return_status		 OUT NOCOPY VARCHAR2,
            x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE,
            x_dependent_sty_name   OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE);


    PROCEDURE get_dependent_stream_type(
            p_khr_id  		   	     IN NUMBER,
            p_deal_type              IN OKL_ST_GEN_TMPT_SETS.deal_type%TYPE,
            p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
            x_return_status		 OUT NOCOPY VARCHAR2,
            x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE,
            x_dependent_sty_name   OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE);

  PROCEDURE get_dependent_stream_type(
            p_khr_id  		   	     IN NUMBER,
            p_deal_type              IN OKL_ST_GEN_TMPT_SETS.deal_type%TYPE,
            p_primary_sty_id         IN okl_strm_type_b.ID%TYPE,
            p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
            x_return_status		 OUT NOCOPY VARCHAR2,
            x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE,
            x_dependent_sty_name   OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE);

  -- Added by RGOOTY: Start
  -- Performant APIs added which accept G_GET_K_INFO_CSR Record type
  -- as an additional parameter instead of running repeatedly.
  PROCEDURE get_dep_stream_type(
            p_khr_id  		    IN NUMBER,
            p_deal_type             IN OKL_ST_GEN_TMPT_SETS.deal_type%TYPE,
            p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
            x_return_status	    OUT NOCOPY VARCHAR2,
            x_dependent_sty_id 	    OUT NOCOPY okl_strm_type_b.ID%TYPE,
            x_dependent_sty_name    OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE,
            p_get_k_info_rec        IN G_GET_K_INFO_CSR%ROWTYPE);

  PROCEDURE get_dep_stream_type(
            p_khr_id  		    IN NUMBER,
            p_deal_type             IN OKL_ST_GEN_TMPT_SETS.deal_type%TYPE,
            p_primary_sty_id        IN okl_strm_type_b.ID%TYPE,
            p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
            x_return_status	    OUT NOCOPY VARCHAR2,
            x_dependent_sty_id 	    OUT NOCOPY okl_strm_type_b.ID%TYPE,
            x_dependent_sty_name    OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE,
            p_get_k_info_rec        IN G_GET_K_INFO_CSR%ROWTYPE);
  -- Added by RGOOTY: End


-- Added by DJANASWA for ER 6274342 start
  PROCEDURE get_arrears_pay_dates_option(
            p_khr_id                   IN  NUMBER,
            x_arrears_pay_dates_option OUT NOCOPY VARCHAR2,
            x_return_status            OUT NOCOPY VARCHAR2);
-- Added by DJANASWA for ER 6274342 end



END OKL_ISG_UTILS_PVT;

/
