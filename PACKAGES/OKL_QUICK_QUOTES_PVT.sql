--------------------------------------------------------
--  DDL for Package OKL_QUICK_QUOTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QUICK_QUOTES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRQQHS.pls 120.4 2006/02/15 12:56:51 viselvar noship $ */

  SUBTYPE qqhv_rec_type IS okl_qqh_pvt.qqhv_rec_type;

  SUBTYPE qqlv_rec_type IS okl_qql_pvt.qqlv_rec_type;

  SUBTYPE qqlv_tbl_type IS okl_qql_pvt.qqlv_tbl_type;

  -- sub types for cashflow records
  SUBTYPE cashflow_hdr_rec IS OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_header_rec_type;
  SUBTYPE cashflow_level_rec IS OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_rec_type;
  SUBTYPE cashflow_level_tbl IS OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type;

  TYPE payment_rec_type IS RECORD(
  subsidy_amount  number,
  financed_amount number,
  arrears_yn      varchar2(1),
  frequency_code  varchar2(1),
  pre_tax_irr     number,
  after_tax_irr   number,
  book_yield      number,
  iir             number,
  sub_pre_tax_irr number,
  sub_after_tax_irr number,
  sub_book_yield  number,
  sub_iir         number
  );

  TYPE rent_payments_rec IS RECORD(
  rate          number,
  stub_amt      number,
  stub_days     number,
  periods       number,
  periodic_amount number,
  start_date    date
  );
  TYPE rent_payments_tbl IS TABLE OF rent_payments_rec INDEX BY binary_integer;

  TYPE fee_service_payments_rec IS RECORD(
  payment_type  varchar2(30),
  periods       number,
  periodic_amt  number,
  start_date    date
  );
  TYPE fee_service_payments_tbl IS TABLE OF fee_service_payments_rec INDEX BY binary_integer;


  TYPE item_order_estimate_rec IS RECORD(
  Item_Category         varchar2(240),
  description           varchar2(240),
  cost                  number,
  purchase_option_value number,
  rate_factor           number,
  periods               number,
  periodic_amt          number,
  start_date            date
  );
  TYPE item_order_estimate_tbl IS TABLE OF item_order_estimate_rec INDEX by binary_integer;
  ------------------------------------------------------------------------------
  -- Global Variables

  g_pkg_name         CONSTANT varchar2(200) := 'OKL_QUICK_QUOTES_PVT';
  g_app_name         CONSTANT varchar2(3) := okl_api.g_app_name;
  g_api_type         CONSTANT varchar2(4) := '_PVT';

  ------------------------------------------------------------------------------
  --Global Exception
  ------------------------------------------------------------------------------

  g_exception_halt_validation EXCEPTION;

  ------------------------------------------------------------------------------

  PROCEDURE create_quick_qte(p_api_version      IN             number
			      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
			      ,x_return_status     OUT NOCOPY  varchar2
			      ,x_msg_count         OUT NOCOPY  number
			      ,x_msg_data          OUT NOCOPY  varchar2
			      ,p_qqhv_rec_type  IN             qqhv_rec_type
			      ,x_qqhv_rec_type      OUT NOCOPY qqhv_rec_type
			      ,p_qqlv_tbl_type  IN             qqlv_tbl_type
			      ,x_qqlv_tbl_type     OUT NOCOPY  qqlv_tbl_type);

  PROCEDURE update_quick_qte(p_api_version      IN             number
			      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
			      ,x_return_status     OUT NOCOPY  varchar2
			      ,x_msg_count         OUT NOCOPY  number
			      ,x_msg_data          OUT NOCOPY  varchar2
			      ,p_qqhv_rec_type  IN             qqhv_rec_type
			      ,x_qqhv_rec_type      OUT NOCOPY qqhv_rec_type
			      ,p_qqlv_tbl_type  IN             qqlv_tbl_type
			      ,x_qqlv_tbl_type     OUT NOCOPY  qqlv_tbl_type);

  PROCEDURE delete_qql(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_qqlv_rec_type   IN            qqlv_rec_type);

  PROCEDURE delete_qql(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_qqlv_tbl_type  IN             qqlv_tbl_type);

  PROCEDURE handle_quick_quote(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_qqhv_rec_type  IN             qqhv_rec_type
                      ,p_qqlv_tbl_type  IN             qqlv_tbl_type
                      ,p_cfh_rec_type   IN             cashflow_hdr_rec
                      ,p_cfl_tbl_type   IN             cashflow_level_tbl
                      ,p_commit         IN             varchar2
                      ,create_yn        IN             varchar2
                      ,x_payment_rec       OUT NOCOPY  payment_rec_type
                      ,x_rent_payments_tbl OUT NOCOPY  rent_payments_tbl
                      ,x_fee_payments_tbl  OUT NOCOPY  fee_service_payments_tbl
                      ,x_item_tbl          OUT NOCOPY  item_order_estimate_tbl
                      ,x_qqhv_rec_type     OUT NOCOPY  qqhv_rec_type  --viselvar added
                      ,x_qqlv_tbl_type     OUT NOCOPY  qqlv_tbl_type -- viselvar added
                      );

  procedure cancel_quick_quote(p_api_version   IN             NUMBER
                      ,p_init_msg_list  IN             VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  VARCHAR2
                      ,x_msg_count         OUT NOCOPY  NUMBER
                      ,x_msg_data          OUT NOCOPY  VARCHAR2
                      ,p_qqhv_rec_type  IN             qqhv_rec_type
                      ,x_qqhv_rec_type     OUT NOCOPY  qqhv_rec_type);

  ------------------------------------------------------------------------------
  -- PROCEDURE duplicate_quick_qte
  ------------------------------------------------------------------------------
  -- Procedure Name  : duplicate_quick_qte
  -- Description     : This procedure is a wrapper that duplicates estimates of a
  --                   particular lease opportunity
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-FEB-2006 viselvar created

  PROCEDURE duplicate_estimate ( p_api_version         IN  NUMBER,
                                 p_init_msg_list       IN  VARCHAR2,
                                 source_lopp_id        IN  NUMBER,
                                 target_lopp_id        IN  NUMBER,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2);

END okl_quick_quotes_pvt;

/
