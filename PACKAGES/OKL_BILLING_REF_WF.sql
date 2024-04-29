--------------------------------------------------------
--  DDL for Package OKL_BILLING_REF_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BILLING_REF_WF" AUTHID CURRENT_USER as
  /* $Header: OKLRBRWS.pls 115.1 2002/11/30 08:44:14 spillaip noship $ */
  subtype trqv_tbl_type is okl_trq_pvt.trqv_tbl_type;
  G_APP_NAME    CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_BILLING_REF_WF';
  G_LEVEL       CONSTANT VARCHAR2(4)   := '_PVT';
  l_api_version CONSTANT NUMBER        := 1;
  G_FND_APP     CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;

  PROCEDURE raise_billing_refund_event (p_request_id  IN VARCHAR2,
                                        p_contract_id IN VARCHAR2,
                                        x_return_status OUT NOCOPY VARCHAR2);

  procedure populate_attributes(itemtype  in varchar2,
                                itemkey   in varchar2,
                                actid     in number,
                                funcmode  in varchar2,
                                resultout out nocopy varchar2);

  PROCEDURE refund_approval(itemtype  in varchar2,
                              itemkey   in varchar2,
                              actid     in number,
                              funcmode  in varchar2,
                              resultout out nocopy varchar2);


END OKL_BILLING_REF_WF;

 

/
