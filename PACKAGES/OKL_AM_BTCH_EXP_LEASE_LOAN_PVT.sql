--------------------------------------------------------
--  DDL for Package OKL_AM_BTCH_EXP_LEASE_LOAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_BTCH_EXP_LEASE_LOAN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLLBS.pls 120.2 2005/09/20 22:42:39 rmunjulu noship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_BTCH_EXP_LEASE_LOAN_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';


  -- RMUNJULU 05-MAR-03 Fixed msg constant
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_APP_NAME_1       CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  G_EXCEPTION_HALT       EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  SUBTYPE term_rec_type IS OKL_AM_LEASE_LOAN_TRMNT_PUB.term_rec_type;
  SUBTYPE term_tbl_type IS OKL_AM_LEASE_LOAN_TRMNT_PUB.term_tbl_type;
  SUBTYPE tcnv_rec_type IS OKL_AM_LEASE_LOAN_TRMNT_PUB.tcnv_rec_type;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------
  PROCEDURE check_if_quotes_existing(
            p_term_rec             IN      term_rec_type,
            x_return_status        OUT     NOCOPY VARCHAR2,
            x_quotes_found         OUT     NOCOPY VARCHAR2);

  PROCEDURE get_trn_rec(
            p_contract_id          IN      NUMBER,
            x_return_status        OUT     NOCOPY VARCHAR2,
            x_trn_exists           OUT     NOCOPY VARCHAR2,
            x_tcnv_rec             OUT     NOCOPY tcnv_rec_type);

  PROCEDURE batch_expire_lease_loan(
            p_api_version          IN      NUMBER,
            p_init_msg_list        IN      VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status        OUT     NOCOPY VARCHAR2,
            x_msg_count            OUT     NOCOPY NUMBER,
            x_msg_data             OUT     NOCOPY VARCHAR2,
            p_contract_id          IN      NUMBER DEFAULT OKL_API.G_MISS_NUM,
            x_term_tbl             OUT     NOCOPY term_tbl_type);

   PROCEDURE concurrent_expire_lease_loan(
            ERRBUF                 OUT NOCOPY 	  VARCHAR2,
            RETCODE                OUT NOCOPY    VARCHAR2,
            p_api_version          IN  	  NUMBER,
           	p_init_msg_list        IN  	  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_contract_id          IN     NUMBER DEFAULT OKL_API.G_MISS_NUM);


  -- RMUNJULU 2730738 Added Rec Types and Tbl Types for proper output file


  TYPE msg_rec_type IS RECORD (
           msg      VARCHAR2(2000));

  TYPE msg_tbl_type IS TABLE OF msg_rec_type INDEX BY BINARY_INTEGER;

  TYPE message_rec_type  IS RECORD (
           id               NUMBER,
           contract_number  VARCHAR2(300),
           start_date       DATE,
           end_date         DATE,
           status           VARCHAR2(300));
-- SECHAWLA 26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions of db/Pl Sql
-- Commented out the pl/sql field as it was not being used to display messages.
-- ,msg_tbl          msg_tbl_type);

  TYPE message_tbl_type IS TABLE OF message_rec_type INDEX BY BINARY_INTEGER;

  G_MSG_TBL_COUNTER NUMBER := 1;

  ASSET_MSG_TBL  msg_tbl_type;

  PROCEDURE POP_ASSET_MSG_TBL;

  -- RMUNJULU PERF
  PROCEDURE child_process(
                            errbuf                      OUT NOCOPY VARCHAR2,
                            retcode                     OUT NOCOPY NUMBER,
                            p_assigned_processes        IN VARCHAR2--,
                            --p_api_version               IN NUMBER,
           	                --p_init_msg_list             IN VARCHAR2 DEFAULT OKL_API.G_FALSE
                          );

  -- RMUNJULU PERF
  PROCEDURE Process_Spawner (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_num_processes    IN NUMBER,
                            p_term_date        IN VARCHAR2
                           );

END OKL_AM_BTCH_EXP_LEASE_LOAN_PVT;

 

/
