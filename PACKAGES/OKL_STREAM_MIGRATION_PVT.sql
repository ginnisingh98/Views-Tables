--------------------------------------------------------
--  DDL for Package OKL_STREAM_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAM_MIGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSMGS.pls 120.2 2005/10/30 03:17:20 appldev noship $ */

G_PKG_NAME             CONSTANT VARCHAR2(200)     := 'OKL_STREAM_MIGRATION_PVT';
G_APP_NAME             CONSTANT VARCHAR2(3)       :=  Okl_Api.G_APP_NAME;
G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200)     := 'SQLERRM';
G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200)     := 'SQLCODE';

G_MISS_NUM	        CONSTANT NUMBER   	:=  Okl_Api.G_MISS_NUM;
G_MISS_CHAR		CONSTANT VARCHAR2(1)	:=  Okl_Api.G_MISS_CHAR;
G_MISS_DATE		CONSTANT DATE   	:=  Okl_Api.G_MISS_DATE;
G_TRUE			CONSTANT VARCHAR2(1)	:=  Okl_Api.G_TRUE;
G_FALSE			CONSTANT VARCHAR2(1)	:=  Okl_Api.G_FALSE;

G_RET_STS_SUCCESS	CONSTANT VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := Okl_Api.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR	CONSTANT VARCHAR2(1) := Okl_Api.G_RET_STS_UNEXP_ERROR;
G_EXC_NAME_OTHERS	CONSTANT VARCHAR2(6)   := 'OTHERS';

G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
G_EXCEPTION_ERROR			EXCEPTION;
G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;

SUBTYPE aesv_rec_type IS Okl_Process_Tmpt_Set_Pub.aesv_rec_type;
SUBTYPE avlv_rec_type IS Okl_Process_Tmpt_Set_Pub.avlv_rec_type;
SUBTYPE atlv_rec_type IS Okl_Process_Tmpt_Set_Pub.atlv_rec_type;
SUBTYPE pdtv_rec_type IS Okl_Products_Pub.pdtv_rec_type;

-- Stream Generation Template Set
SUBTYPE gttv_rec_type IS Okl_Gtt_Pvt.gttv_rec_type;
SUBTYPE gttv_tbl_type IS Okl_Gtt_Pvt.gttv_tbl_type;

-- Stream Generation Template
SUBTYPE gtsv_rec_type IS Okl_Gts_Pvt.gtsv_rec_type;
SUBTYPE gtsv_tbl_type IS Okl_Gts_Pvt.gtsv_tbl_type;

-- Stream Generation Template Stream Types
SUBTYPE gtlv_rec_type IS Okl_Gtl_Pvt.gtlv_rec_type;
SUBTYPE gtlv_tbl_type IS Okl_Gtl_Pvt.gtlv_tbl_type;

-- Stream Generation Template Stream Types
SUBTYPE gtpv_rec_type IS Okl_Gtp_Pvt.gtpv_rec_type;
SUBTYPE gtpv_tbl_type IS Okl_Gtp_Pvt.gtpv_tbl_type;

SUBTYPE error_msgs_tbl_type IS Okl_Strm_Gen_Template_Pvt.error_msgs_tbl_type;

TYPE dep_sty_rec  IS RECORD (
  sty_id 		NUMBER  DEFAULT Okl_Api.G_MISS_NUM,
  sty_code 		okl_strm_type_b.code%TYPE  DEFAULT Okl_Api.G_MISS_CHAR,
  stream_type_purpose 	okl_strm_type_b.stream_type_purpose%TYPE  DEFAULT Okl_Api.G_MISS_CHAR
);

TYPE dep_sty_tbl IS TABLE OF dep_sty_rec  INDEX BY BINARY_INTEGER;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate_Accounting_Templates
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate_Accounting_Templates
  -- Description     : Procedure to migrate accounting templates and products
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Migrate_Accounting_Templates;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate_Streams_Process
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate_Streams_Process
  -- Description     : Procedure to create new stream templates
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Migrate_Streams_Process(p_stream_generator IN   VARCHAR2);


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate_Stream_Types
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate_Stream_Types
  -- Description     : Procedure to migrate stream types based on its usage
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Migrate_Stream_Types(x_return_status OUT NOCOPY  VARCHAR2);

  ---------------------------------------------------------------------------
  -- PROCEDURE Check_If_Used
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Check_If_Used
  -- Description     : Procedure to check if a stream type is used on a contract
  --   		       of a specific deal type
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

FUNCTION Check_If_Used (p_sty_id IN NUMBER,
		 	p_book_class IN VARCHAR2,
			p_tax_owner IN VARCHAR2)
RETURN VARCHAR2;

END OKL_STREAM_MIGRATION_PVT;


 

/
