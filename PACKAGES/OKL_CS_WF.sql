--------------------------------------------------------
--  DDL for Package OKL_CS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CS_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRCSWS.pls 120.3 2005/10/30 04:33:08 appldev noship $ */

  TYPE inv_days_rec_type IS RECORD (
    consolidated_invoice_number          okl_cnsld_ar_hdrs_b.consolidated_invoice_number%TYPE,
    days                                  NUMBER,
    amount_due_remaining                  ar_payment_schedules_all.amount_due_remaining%TYPE,
    khr_id                                okc_k_headers_b.id%TYPE);


  TYPE inv_days_tbl_type IS TABLE OF inv_days_rec_type INDEX BY BINARY_INTEGER;

  TYPE product_rec_type IS RECORD (
    product_id                  okl_products.id%TYPE,
    product_name                okl_products.name%TYPE,
    product_description         okl_products.description%TYPE);

  TYPE address_rec_type IS RECORD (
    address1                    okx_cust_site_uses_v.address1%TYPE,
    address2                    okx_cust_site_uses_v.address2%TYPE,
    address3                    okx_cust_site_uses_v.address3%TYPE,
    address4                    okx_cust_site_uses_v.address4%TYPE,
    city                        okx_cust_site_uses_v.city%TYPE,
    postal_code                 okx_cust_site_uses_v.postal_code%TYPE,
    state                       okx_cust_site_uses_v.state%TYPE,
    province                    okx_cust_site_uses_v.province%TYPE,
    county                      okx_cust_site_uses_v.county%TYPE,
    country                     okx_cust_site_uses_v.country%TYPE,
    description                 okx_cust_site_uses_v.description%TYPE);

 ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                           CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE                     CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN             CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN             CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN          CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_ERROR                       CONSTANT VARCHAR2(200) := 'OKL_ERROR';
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'call_center_integration';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  'OKL';

   ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
	G_EXCEPTION EXCEPTION;


  PROCEDURE raise_equipment_exchange_event ( p_tas_id   IN NUMBER);

  procedure exchange_equipment (itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	);
  procedure check_for_request ( itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	);
  PROCEDURE check_exchange_type ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);
  PROCEDURE check_temp_exchange ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);


 --Transfer and Assumption WF Subprograms

 PROCEDURE Raise_TransferAsu_Event(p_trx_id      IN NUMBER);
 PROCEDURE Populate_TandA_attributes(itemtype          in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out nocopy varchar2);

 Procedure Send_Cust_Fulfill(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);

 Procedure Send_Vendor_Fulfill(itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);

 Procedure Approve_Request(itemtype          in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);
  PROCEDURE Update_Request_Internal( itemtype          in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);
  PROCEDURE Customer_Post( itemtype          in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out nocopy varchar2);
  PROCEDURE Vendor_Post( itemtype          in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out nocopy varchar2);

  Procedure Check_Vendor_Pgm(itemtype          in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);

  Procedure Check_Cust_Delinquency(itemtype          in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funcmode        in varchar2,
                                   resultout       out nocopy varchar2);

  Procedure Apply_Service_Fees(itemtype          in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);


  Procedure Credit_post(itemtype          in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       out nocopy varchar2);

  Procedure Collections_post(itemtype          in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       out nocopy varchar2);

--Call Center integration utility APIs

PROCEDURE days_cust_balance_overdue ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE get_contract_balance ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE get_customer_balance ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);
PROCEDURE get_product ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE get_bill_to_address ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

---------------------------------------------------------------
-- The following APIS are utility APIs for getting information
-- for a contract.
---------------------------------------------------------------

PROCEDURE days_cust_balance_overdue
(p_contract_id          IN      NUMBER
,x_inv_days_tbl         OUT NOCOPY     inv_days_tbl_type
,x_return_status        OUT NOCOPY     VARCHAR2);

PROCEDURE get_contract_balance (
     p_contract_id              IN  NUMBER,
     x_outstanding_balance      OUT NOCOPY NUMBER,
     x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE get_customer_balance (
     p_cust_account_id          IN  NUMBER,
     x_outstanding_balance      OUT NOCOPY NUMBER,
     x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE get_product (
     p_contract_id              IN  NUMBER,
     x_product_rec              OUT NOCOPY product_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE get_bill_to_address (
     p_contract_id              IN  NUMBER,
     x_address_rec              OUT NOCOPY address_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2);



--Lease Renewal Work flow APIs

PROCEDURE raise_lease_renewal_event(p_request_id   IN NUMBER);

PROCEDURE populate_lease_renew_attrib(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE approve_lease_renewal ( itemtype      in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE post_notify_lease_renewal(itemtype    in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE post_reject_lease_renewal(itemtype    in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);
--Principal Paydown Work flow APIs

PROCEDURE raise_principal_paydown_event(p_request_id   IN NUMBER);

PROCEDURE populate_ppd_attrib(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE post_notify_ppd(itemtype    in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

--Added the following APIs as part of 11.5.10+
PROCEDURE invoice_bill_apply(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE update_ppd_processed_status(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);


--Issue Credit Memo  Work flow APIs

PROCEDURE raise_credit_memo_event(p_request_id   IN NUMBER);

PROCEDURE populate_credit_memo_attribs(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE create_credit_memo_invoice(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE update_crm_approved_status(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE update_crm_rejected_status(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE update_crm_success_status(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);

PROCEDURE update_crm_error_status(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2);


END OKL_CS_WF;

 

/
