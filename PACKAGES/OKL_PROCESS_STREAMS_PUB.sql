--------------------------------------------------------
--  DDL for Package OKL_PROCESS_STREAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_STREAMS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPSRS.pls 115.5 2002/06/14 17:00:43 pkm ship        $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_PROCESS_STREAMS_PUB';

  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
  G_API_TYPE	CONSTANT VARCHAR(4) := '_PUB';
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;


  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR			  		EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;


  SUBTYPE selv_tbl_type IS Okl_Process_Streams_Pvt.selv_tbl_type;
  SUBTYPE stmv_rec_type IS Okl_Process_Streams_Pvt.stmv_rec_type;
  SUBTYPE stmv_tbl_type IS Okl_Process_Streams_Pvt.stmv_tbl_type;

  PROCEDURE process_stream_results(p_api_version        IN     NUMBER
                                 ,p_init_msg_list      IN     VARCHAR2
                                 ,x_return_status      OUT    NOCOPY VARCHAR2
                                 ,x_msg_count          OUT    NOCOPY NUMBER
                                 ,x_msg_data           OUT    NOCOPY VARCHAR2
 	                         ,p_transaction_number IN     NUMBER
 	                         );

  PROCEDURE PROCESS_REST_STRM_RESLTS(p_api_version        IN     NUMBER
                                        ,p_init_msg_list      IN     VARCHAR2
	                                    ,p_transaction_number IN     NUMBER
                                        ,x_return_status      OUT    NOCOPY VARCHAR2
                                        ,x_msg_count          OUT    NOCOPY NUMBER
                                        ,x_msg_data           OUT    NOCOPY VARCHAR2);

END OKL_PROCESS_STREAMS_PUB;

 

/
