--------------------------------------------------------
--  DDL for Package OKL_BILL_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BILL_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPBISS.pls 115.1 2004/01/07 18:36:05 sanahuja noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_BILL_STATUS_PUB';
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

  SUBTYPE bill_stat_tbl_type  is OKL_BILL_STATUS_PVT.bill_stat_tbl_type;

  --PROCEDURE ADD_LANGUAGE;

  --Object type procedure for calling calculate_late_charge

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

END OKL_BILL_STATUS_PUB; -- Package spec






 

/
