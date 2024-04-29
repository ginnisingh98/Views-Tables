--------------------------------------------------------
--  DDL for Package OKL_LRF_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LRF_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLRIS.pls 120.2 2005/10/30 04:34:54 appldev noship $*/

  -----------------------------------------------------------------------------
  -- PACKAGE CONSTANTS
  -----------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_LRF_INTERFACE_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_MISS_CHAR            CONSTANT VARCHAR2(1)   := FND_API.G_MISS_CHAR;
  G_MISS_NUM             CONSTANT NUMBER        := FND_API.G_MISS_NUM;
  G_MISS_DATE            CONSTANT DATE          := FND_API.G_MISS_DATE;

  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';

  ---------------------------------------------------------------------------
  -- DATA STRUCTURES
  ---------------------------------------------------------------------------
  TYPE lrt_rec_type IS RECORD
  ( LANGUAGE       OKL_LS_RT_FCTR_SETS_TL.LANGUAGE%TYPE
   ,NAME           OKL_LS_RT_FCTR_SETS_TL.NAME%TYPE
   ,DESCRIPTION    OKL_LS_RT_FCTR_SETS_TL.DESCRIPTION%TYPE
   ,ARREARS_YN     OKL_LS_RT_FCTR_SETS_B.ARREARS_YN%TYPE
   ,START_DATE     OKL_LS_RT_FCTR_SETS_B.START_DATE%TYPE
   ,END_DATE       OKL_LS_RT_FCTR_SETS_B.END_DATE%TYPE
   ,FRQ_CODE       OKL_LS_RT_FCTR_SETS_B.FRQ_CODE%TYPE
   ,BATCH_NUMER    NUMBER
  );

  TYPE lrf_rec_type IS RECORD
  ( TERM_IN_MONTHS         OKL_LS_RT_FCTR_ENTS.TERM_IN_MONTHS%TYPE
   ,RESIDUAL_VALUE_PERCENT OKL_LS_RT_FCTR_ENTS.RESIDUAL_VALUE_PERCENT%TYPE
   ,INTEREST_RATE          OKL_LS_RT_FCTR_ENTS.INTEREST_RATE%TYPE
   ,LEASE_RATE_FACTOR      OKL_LS_RT_FCTR_ENTS.LEASE_RATE_FACTOR%TYPE
   ,LRT_ID                 OKL_LS_RT_FCTR_ENTS.LRT_ID%TYPE
   ,BATCH_NUMBER           NUMBER
   ,STATUS                 VARCHAR2(30)
  );

  TYPE LEASE_RATE_REC IS RECORD
   ( TERM_IN_MONTHS         NUMBER
    ,RESIDUAL_VALUE_PERCENT NUMBER(18,15)
    ,INTEREST_RATE          NUMBER(18,15)
    ,LEASE_RATE_FACTOR      NUMBER
   );

  TYPE LEASE_RATE_TBL IS TABLE OF LEASE_RATE_REC INDEX BY BINARY_INTEGER;

  L_LEASE_RATE_TBL    LEASE_RATE_TBL;

  ---------------------------------------------------------------------------
  -- PROGRAM UNITS
  ---------------------------------------------------------------------------
  PROCEDURE purge_record (errbuf             OUT NOCOPY VARCHAR2
                         ,retcode            OUT NOCOPY VARCHAR2
                         ,p_batch_number     IN NUMBER
                         ,p_status           in  varchar2);

  PROCEDURE process_record (errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY VARCHAR2,
                            p_batch_number     IN NUMBER);


  PROCEDURE generate_lrf (errbuf             OUT NOCOPY VARCHAR2
                         ,retcode            OUT NOCOPY VARCHAR2
                         ,p_batch_number     IN NUMBER
                         ,p_term_lower_range IN NUMBER
                         ,p_term_upper_range IN NUMBER
                         ,p_term_interval    IN NUMBER
                         ,p_rv_lower_range   IN NUMBER
                         ,p_rv_upper_range   IN NUMBER
                         ,p_rv_interval      IN NUMBER
                         );

END OKL_LRF_INTERFACE_PVT;

 

/
