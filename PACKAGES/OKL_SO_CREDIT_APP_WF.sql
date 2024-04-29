--------------------------------------------------------
--  DDL for Package OKL_SO_CREDIT_APP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SO_CREDIT_APP_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRCRQS.pls 115.7 2003/04/17 18:30:35 rgalipo noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  G_CREDIT_CHKLST_TPL CONSTANT VARCHAR2(30) := 'LACCLH';
  G_CREDIT_CHKLST_TPL_RULE1 CONSTANT VARCHAR2(30) := 'LACCLT';
  G_CREDIT_CHKLST_TPL_RULE2 CONSTANT VARCHAR2(30) := 'LACCLD';

  TYPE l_chr_rec IS RECORD
      (party_id          NUMBER
      ,cust_acct_id      NUMBER
      ,cust_acct_site_id NUMBER
      ,site_use_id       NUMBER
      ,contract_id       NUMBER
      ,credit_khr_id     NUMBER
      ,currency          VARCHAR2(15)
      ,txn_amount        NUMBER
      ,requested_amount  NUMBER
      ,term              NUMBER
      ,party_contact_id  NUMBER
      ,org_id            NUMBER
      );

  ---------------------------------------------------------------------------

  PROCEDURE create_credit_app_event
( p_quote_id   IN NUMBER,
  p_requestor_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2);

  procedure create_credit_app ( itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	);

   procedure CREATE_CREDIT_LINE ( itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2);

     procedure UPDATE_STATUS ( itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2);


    procedure send_message ( itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	);

  PROCEDURE SET_REQUESTOR(itemtype  IN VARCHAR2,
                          itemkey   IN VARCHAR2,
                          actid     IN NUMBER,
                          funcmode  IN VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2);

  PROCEDURE SET_APPROVER (itemtype  IN VARCHAR2,
                          itemkey   IN VARCHAR2,
                          actid     IN NUMBER,
                          funcmode  IN VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2);

  PROCEDURE CREDIT_APP_DETAILS( itemtype  IN VARCHAR2,
                          itemkey   IN VARCHAR2,
                          actid     IN NUMBER,
                          funcmode  IN VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2);

  PROCEDURE CREDIT_K_END_DATED
                         (itemtype  IN VARCHAR2,
                          itemkey   IN VARCHAR2,
                          actid     IN NUMBER,
                          funcmode  IN VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2);

END OKL_SO_CREDIT_APP_WF;

 

/
