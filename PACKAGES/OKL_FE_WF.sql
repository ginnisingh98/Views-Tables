--------------------------------------------------------
--  DDL for Package OKL_FE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FE_WF" AUTHID CURRENT_USER AS
/* $Header: OKLFEWFS.pls 120.0 2005/08/04 12:47:54 viselvar noship $ */
  G_APP_NAME     CONSTANT VARCHAR2(3) := OKL_API.G_APP_NAME;
  G_CAT_ITEM     CONSTANT VARCHAR2(30) := OKL_ITEM_RESIDUALS_PVT.G_CAT_ITEM;
  G_CAT_ITEM_CAT CONSTANT VARCHAR2(30) := OKL_ITEM_RESIDUALS_PVT.G_CAT_ITEM_CAT;
  G_CAT_RES_CAT  CONSTANT VARCHAR2(30) := OKL_ITEM_RESIDUALS_PVT.G_CAT_RES_CAT;
  G_PKG_NAME     CONSTANT VARCHAR2(200) := 'OKL_FE_WF';
  G_API_TYPE     CONSTANT VARCHAR2(200) := '_PVT';

  -- subtypes used

  SUBTYPE okl_pal_rec IS okl_pal_pvt.okl_pal_rec;

  SUBTYPE okl_srv_rec IS okl_srv_pvt.okl_srv_rec;

  SUBTYPE okl_eve_rec IS okl_eve_pvt.okl_eve_rec;

  SUBTYPE okl_icpv_rec IS okl_icp_pvt.icpv_rec_type;

  SUBTYPE okl_lrvv_rec IS okl_lrv_pvt.okl_lrvv_rec;

  -- handles the approval process for Standard Rate Template

  PROCEDURE handle_srt_approval(itemtype IN varchar2, itemkey IN varchar2,
                                actid IN number, funcmode IN varchar2,
                                resultout OUT NOCOPY varchar2);

  -- handles the approval process for Pricing Adjustment Matrix

  PROCEDURE handle_pam_approval(itemtype IN varchar2, itemkey IN varchar2,
                                actid IN number, funcmode IN varchar2,
                                resultout OUT NOCOPY varchar2);

  -- handles the approval process for End of Term Options

  PROCEDURE handle_eot_approval(itemtype IN varchar2, itemkey IN varchar2,
                                actid IN number, funcmode IN varchar2,
                                resultout OUT NOCOPY varchar2);

  -- handles the approval process for Lease Rate Set

  PROCEDURE handle_lrs_approval(itemtype IN varchar2, itemkey IN varchar2,
                                actid IN number, funcmode IN varchar2,
                                resultout OUT NOCOPY varchar2);

  -- handles the approval process Item Residuals

  PROCEDURE handle_irs_approval(itemtype IN varchar2, itemkey IN varchar2,
                                actid IN number, funcmode IN varchar2,
                                resultout OUT NOCOPY varchar2);

  -- method to set the attributes that have to be set before calling AME

  PROCEDURE adj_mat_ame(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                        actid IN NUMBER, funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);

  -- method to set the messages and the message desciption for Adjustment Matrix

  PROCEDURE adj_mat_wf(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                       actid IN NUMBER, funcmode IN VARCHAR2,
                       resultout OUT NOCOPY VARCHAR2);

  -- method to set the messages and the message desciption for Standard Rate Template

  PROCEDURE std_rate_tmpl_wf(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                             actid IN NUMBER, funcmode IN VARCHAR2,
                             resultout OUT NOCOPY VARCHAR2);

  -- method to set the attributes that have to be set before calling AME

  PROCEDURE std_rate_tmpl_ame(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                              actid IN NUMBER, funcmode IN VARCHAR2,
                              resultout OUT NOCOPY VARCHAR2);

  -- method to set the messages and the message desciption for End of Term Options

  PROCEDURE eo_term_wf(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                       actid IN NUMBER, funcmode IN VARCHAR2,
                       resultout OUT NOCOPY VARCHAR2);

  -- method to set the attributes that have to be set before calling AME

  PROCEDURE eo_term_ame(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                        actid IN NUMBER, funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);

  -- method to set the messages and the message desciption for Item Residuals

  PROCEDURE item_res_wf(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                        actid IN NUMBER, funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);

  -- method to set the attributes that have to be set before calling AME

  PROCEDURE item_res_ame(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                         actid IN NUMBER, funcmode IN VARCHAR2,
                         resultout OUT NOCOPY VARCHAR2);

  -- method to set the messages and the message desciption for Lease Rate Sets

  PROCEDURE lease_rate_set_wf(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                              actid IN NUMBER, funcmode IN VARCHAR2,
                              resultout OUT NOCOPY VARCHAR2);

  -- method to set the attributes that have to be set before calling AME

  PROCEDURE lease_rate_set_ame(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                               actid IN NUMBER, funcmode IN VARCHAR2,
                               resultout OUT NOCOPY VARCHAR2);

  -- procedure to check the approval process

  PROCEDURE check_approval_process(itemtype IN VARCHAR2,
                                   itemkey IN VARCHAR2, actid IN NUMBER,
                                   funcmode IN VARCHAR2,
                                   resultout OUT NOCOPY VARCHAR2);

  -- Get the message body for Pricing Adjustment Matrix

  PROCEDURE get_pam_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2);

  -- Get the message body for Standard Rate Template

  PROCEDURE get_srt_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2);

  -- Get the message body for End of Term Options

  PROCEDURE get_eot_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2);

  -- Get the message body for Item Residuals

  PROCEDURE get_irs_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2);

  -- Get the message body for Lease Rate Set

  PROCEDURE get_lrs_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2);

END okl_fe_wf;

 

/
