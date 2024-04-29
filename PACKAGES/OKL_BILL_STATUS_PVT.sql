--------------------------------------------------------
--  DDL for Package OKL_BILL_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BILL_STATUS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRBISS.pls 120.2 2005/08/11 13:49:51 abindal noship $ */
--
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

  ------------------------------------------------------------------------------
  TYPE bill_stat_rec_type IS RECORD (
    transaction_type        VARCHAR2(200),
    last_bill_date          DATE,
    last_schedule_bill_date DATE);

  TYPE bill_stat_tbl_type IS TABLE OF bill_stat_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE line_items_rec_type IS RECORD (
    line_id        NUMBER);

  TYPE line_items_tbl_type IS TABLE OF line_items_rec_type
        INDEX BY BINARY_INTEGER;

  -- abindal bug 4396207 start --
  TYPE valid_stm_rec_type IS RECORD (
      stm_id        NUMBER);

  TYPE valid_stm_tbl_type IS TABLE OF valid_stm_rec_type
      INDEX BY BINARY_INTEGER;

  TYPE valid_sel_rec_type IS RECORD (
      sel_id        NUMBER);

  TYPE valid_sel_tbl_type IS TABLE OF valid_sel_rec_type
      INDEX BY BINARY_INTEGER;
  -- abindal bug 4396207 end --


  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_BILL_STATUS_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  ------------------------------------------------------------------------------
   --Global Exception
  ------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ------------------------------------------------------------------------------

  l_msg_data VARCHAR2(4000);

  PROCEDURE billing_status(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,x_bill_stat_tbl                OUT NOCOPY bill_stat_tbl_type
    ,p_khr_id                       IN  NUMBER
    ,p_transaction_date             IN  DATE
    );

END OKL_BILL_STATUS_PVT; -- Package spec


 

/
