--------------------------------------------------------
--  DDL for Package OKL_SSC_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SSC_WF" AUTHID CURRENT_USER as
/* $Header: OKLSSWFS.pls 120.5.12010000.2 2009/11/23 10:37:19 rpillay ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
 -- Bug#4274575 - smadhava - 28-Sep-2005 - Modified - Start
    procedure raise_assets_update_event (  p_event_name   in varchar2 ,
                                      parent_line_id in varchar2,
                                      requestorId  in varchar2,
                                      new_site_id1 in varchar2,
                                      new_site_id2 in varchar2,
                                      old_site_id1 in varchar2,
                                      old_site_id2 in varchar2,
                                      trx_date     in date);
 -- Bug#4274575 - smadhava - 28-Sep-2005 - Modified - End
    procedure getLocationMessage (itemtype in varchar2,
                                    itemkey in varchar2,
                                    actid in number,
                                    funcmode in varchar2,
                                    resultout out nocopy varchar2 );

    procedure getSerialNumMessage (itemtype in varchar2,
                                      itemkey in varchar2,
                                      actid in number,
                                      funcmode in varchar2,
                                      resultout out nocopy varchar2 );
    procedure getAssetReturnMessage (itemtype in varchar2,
                                      itemkey in varchar2,
                                      actid in number,
                                      funcmode in varchar2,
                                      resultout out nocopy varchar2 );

  procedure update_location_fnc (itemtype in varchar2,
                                    itemkey in varchar2,
                                    actid in number,
                                    funcmode in varchar2,
                                    resultout out nocopy varchar2 );

  procedure update_serial_fnc (itemtype in varchar2,
                                    itemkey in varchar2,
                                    actid in number,
                                    funcmode in varchar2,
                                    resultout out nocopy varchar2 );

  PROCEDURE update_serial_number( p_api_version                    IN  NUMBER,
                                p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                p_tas_id                         IN  NUMBER,
                                x_return_status                  OUT NOCOPY VARCHAR2,
                                x_msg_count                      OUT NOCOPY NUMBER,
                                x_msg_data                       OUT NOCOPY VARCHAR2);

  PROCEDURE update_location(  p_api_version                    IN  NUMBER,
                              p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              p_tas_id                         IN  NUMBER,
                              x_return_status                  OUT NOCOPY VARCHAR2,
                              x_msg_count                      OUT NOCOPY NUMBER,
                              x_msg_data                       OUT NOCOPY VARCHAR2);

  PROCEDURE  getAssetReturnDocument(  document_id    in      varchar2,
                              display_type   in      varchar2,
                              document       in out nocopy  clob,
                              document_type  in out nocopy  varchar2);

  PROCEDURE  getSerialNumDocument(  document_id    in      varchar2,
                              display_type   in      varchar2,
                              document       in out nocopy  clob,
                              document_type  in out nocopy  varchar2);

  PROCEDURE  getLocationDocument(   document_id    in      varchar2,
                              display_type   in      varchar2,
                              document       in out nocopy  clob,
                              document_type  in out nocopy  varchar2);


procedure accept_renewal_quote(quote_id in number,
                               contract_id in number,
                               user_id in number,
             x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2);

procedure process_renewal_quote(quote_id in number,
                               contract_id in number,
                               user_id in number,
                               status_mode in varchar2,
             				   x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2);

procedure submit_third_party_ins_wrapper(provider_id in number DEFAULT null,
           site_id in number DEFAULT null,
           policy_number in varchar2,
           policy_start_date in date,
           policy_end_date in date,
           coverage_amount in number DEFAULT null,
           deductible in number DEFAULT null,
           lessor_insured in varchar2 DEFAULT 'N',
           lessor_payee in varchar2 DEFAULT 'N',
                       contract_id in number,
           requestor_id in number,
           provider_name in varchar2,
           address1 in varchar2,
           address2 in varchar2 DEFAULT null,
           address3 in varchar2 DEFAULT null,
           address4 in varchar2 DEFAULT null,
           city in varchar2,
           state in varchar2,
           province in varchar2 DEFAULT null,
                 county in varchar2 DEFAULT null,
           zip in varchar2,
           country in varchar2,
           telephone in varchar2,
           email in varchar2);

procedure req_renewal_quote_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 );

procedure submit_insurance_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 );

procedure submit_ins_set_notif_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 );

procedure set_ins_provider_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 );

-- The record type in used for workflows that need to call Rules API.

subtype l_rule_rec_type is OKL_RGRP_RULES_PROCESS_PVT.rgr_rec_type;
subtype l_rule_tbl_type is OKL_RGRP_RULES_PROCESS_PVT.rgr_tbl_type;


PROCEDURE invoice_format_change_wf(itemtype in varchar2,
                itemkey in varchar2,
                actid in number,
                funcmode in varchar2,
                resultout out nocopy varchar2 );
PROCEDURE set_invoice_format_attributes (itemtype in varchar2,
                                        itemkey in varchar2,
                                        actid in number,
                                        funcmode in varchar2,
                                        resultout out nocopy varchar2 );

-- Vishal Added on 19-Sep-2002 to handle integration from EO
procedure raise_inv_format_chg_event ( contract_id in varchar2 ,
                                                   user_id in varchar2,
                                                   invoice_format_id in varchar2);


-- Vishal Added on 19-Sep-2002 to handle Billing Information Change Workflow
procedure req_billinf_change_getdata_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 );

-- Vishal Added on 19-Sep-2002 to handle Billing Information Change Workflow
procedure req_billinf_change_wrapper_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 );

-- Vishal Added on 20-Sep-2002 to handle integration from EO
procedure raise_billinf_change_event ( contract_id in varchar2 ,
                                                   user_id in varchar2,
                                                   bill_site_id in varchar2);



-- IBYON added on 20-Sep-2002 to set attributes raised from cancelinsurance event
PROCEDURE cancel_ins_set_attr_wf
          (itemtype in varchar2,
           itemkey in varchar2,
           actid in number,
           funcmode in varchar2,
           resultout out nocopy varchar2 );

-- IBYON added on 20-Sep-2002 wrapper to call cancel insurance API
SUBTYPE ipyv_rec_type IS Okl_Ipy_Pvt.ipyv_rec_type;

PROCEDURE cancel_ins_wrapper_wf
            (p_api_version                  IN NUMBER,
             p_init_msg_list                IN VARCHAR2,
             p_polid                          IN number,
             p_cancelcomment                  IN varchar2,
             p_canceldate                     IN date,
             p_canrsn_code                    IN varchar2,
             p_userid                      IN  NUMBER,
             x_return_status                OUT NOCOPY VARCHAR2,
             x_msg_count                    OUT NOCOPY NUMBER,
             x_msg_data                     OUT NOCOPY VARCHAR2
             );


-- DKHANDEL added on 20-Sep-2002 to call create claim notification


PROCEDURE create_claim_event
( p_claim_id   IN NUMBER,
  x_retrun_status OUT NOCOPY VARCHAR2
  );

-- DKHANDEL added on 20-Sep-2002 to populate claim notification  receiver
 PROCEDURE set_claim_receiver
                (itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2);


-- VAMURU added on 25-Sep-2002 to call makepayment API

PROCEDURE make_payment_wrapper_wf
            (p_api_version                  IN NUMBER,
             p_init_msg_list                IN VARCHAR2,
             p_invid                        IN NUMBER DEFAULT NULL,
             p_paymentamount                IN NUMBER,
             p_paymentcurrency              IN VARCHAR2,
             p_cctype                       IN VARCHAR2 DEFAULT NULL,
             p_expdate                      IN DATE DEFAULT NULL,
             p_ccnum                        IN VARCHAR2 DEFAULT NULL,
             p_ccname                       IN VARCHAR2 DEFAULT NULL,
             p_userid                       IN NUMBER,
             p_custid                       IN VARCHAR2 DEFAULT NULL, -- smoduga 4055222
             x_return_status                OUT NOCOPY VARCHAR2,
             x_payment_ref_number           OUT NOCOPY VARCHAR2,
             x_msg_count                    OUT NOCOPY NUMBER,
             x_msg_data                     OUT NOCOPY VARCHAR2,
             p_paymentdate                  IN DATE,
             p_conInv                       IN VARCHAR2 DEFAULT NULL,
          -- Begin - Make payment Uptake - Varangan
	     p_customer_trx_id		    IN NUMBER,
	     p_customer_id		    IN NUMBER,
	     p_customer_site_use_id         IN NUMBER,
	     p_payment_trxn_extension_id    IN NUMBER,
	     x_cash_receipt_id              OUT NOCOPY NUMBER
          -- End - Make payment Uptake - Varangan
             );

 -- VAMURU added on 30-Sep-2002 to call makepayment API

 PROCEDURE make_payment_set_attr_wf
                (itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2);

-- IBYON added on 01-OCT-2002 to call validate recipient for termination quote
  SUBTYPE qtev_rec_type IS okl_trx_quotes_pub.qtev_rec_type;
  SUBTYPE qpyv_tbl_type IS okl_quote_parties_pub.qpyv_tbl_type;
  SUBTYPE qpyv_rec_type IS okl_quote_parties_pub.qpyv_rec_type;
  SUBTYPE assn_tbl_type IS OKL_AM_CREATE_QUOTE_PVT.assn_tbl_type;
  SUBTYPE tqlv_tbl_type IS OKL_AM_CREATE_QUOTE_PVT.tqlv_tbl_type;

  SUBTYPE q_party_uv_tbl_type IS okl_AM_PARTIES_PVT.q_party_uv_tbl_type;

  PROCEDURE validate_recipient_term_quote
            (p_api_version                  IN NUMBER,
             p_init_msg_list                IN VARCHAR2,
             p_khrid                        IN number,
             p_qrs_code                     IN VARCHAR2,
             p_qtp_code                     IN VARCHAR2,
             p_comments                     IN VARCHAR2,
             x_vendor_flag                  OUT NOCOPY VARCHAR2,
             x_lessee_flag                  OUT NOCOPY VARCHAR2,
             x_cpl_id                       OUT NOCOPY VARCHAR2,
             x_email_address                OUT NOCOPY VARCHAR2,
             x_return_status                OUT NOCOPY VARCHAR2,
             x_msg_count                    OUT NOCOPY NUMBER,
             x_msg_data                     OUT NOCOPY VARCHAR2
             );

-- IBYON added on 01-OCT-2002 to raise event for termination quote
  PROCEDURE create_termqt_raise_event_wf
            (p_qte_id            IN NUMBER,
             p_user_id           IN VARCHAR2,
             x_return_status     OUT NOCOPY VARCHAR2,
             x_msg_count         OUT NOCOPY NUMBER,
             x_msg_data          OUT NOCOPY VARCHAR2
             );

-- IBYON added on 01-OCT-2002 to set attributes for termination quote notification
  PROCEDURE create_termqt_set_attr_wf
           (itemtype             in varchar2,
            itemkey              in varchar2,
            actid                in number,
            funcmode             in varchar2,
            resultout            out nocopy varchar2
            );

-- created by viselvar for bug 4754894 for asset return
procedure raise_assets_return_event ( p_event_name   in varchar2 ,
                                      requestId in varchar2,
                                      requestorId  in varchar2,
                                      requestType in varchar2
                                      );

FUNCTION mask_cc
  ( cc_number IN varchar2)
  RETURN  varchar2;

--Bug 6018784 start
procedure raise_ser_num_update_event( p_event_name   in varchar2 ,
                                      requestId in varchar2,
                                      requestorId  in varchar2,
                                      requestType in varchar2
                                      );
--Bug 6018784 end

 END okl_ssc_wf;

/
