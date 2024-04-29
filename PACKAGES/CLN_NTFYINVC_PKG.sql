--------------------------------------------------------
--  DDL for Package CLN_NTFYINVC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_NTFYINVC_PKG" AUTHID CURRENT_USER AS
   /* $Header: CLN3C3S.pls 120.1 2006/10/04 11:32:30 bsaratna noship $ */

   PROCEDURE Get_NotifyInvoice_Params(p_itemtype               IN              VARCHAR2,
                                      p_itemkey                IN              VARCHAR2,
                                      p_actid                  IN              NUMBER,
                                      p_funcmode               IN              VARCHAR2,
                                      x_resultout              IN OUT NOCOPY   VARCHAR2);

   PROCEDURE GET_PAYMENT_TERM_CODE(p_customer_trx_id   IN         NUMBER,
                                   x_pay_t_code        OUT NOCOPY VARCHAR2 );

   PROCEDURE GET_TAX_AMOUNT_AND_CODE  (p_customer_trx_line_id   IN         NUMBER,
                                       x_tax_amount             OUT NOCOPY NUMBER,
                                       x_tax_code               OUT NOCOPY VARCHAR2);

   PROCEDURE GET_DOC_GENERATION_DATETIME(p_doc_trnsfr_id   IN          NUMBER,
                                         x_doc_gen_dt      OUT NOCOPY  VARCHAR2 );

   PROCEDURE CLN_UPDATE_DOC_STATUS(p_itemtype               IN              VARCHAR2,
                                   p_itemkey                IN              VARCHAR2,
                                   p_actid                  IN              NUMBER,
                                   p_funcmode               IN              VARCHAR2,
                                   x_resultout              IN OUT NOCOPY   VARCHAR2);

   PROCEDURE RAISE_UPDATE      (p_document_id                  IN         VARCHAR2,
                                p_int_cnt_num                  IN         NUMBER,
                                p_org_id                       IN         NUMBER,
                                x_return_status                OUT NOCOPY VARCHAR2,
                                x_msg_data                     OUT NOCOPY VARCHAR2);

   PROCEDURE ERROR_HANDLER(p_internal_control_number    IN            NUMBER,
                           p_document_id                IN            NUMBER,
                           p_org_id                     IN            NUMBER,
                           x_notification_code          OUT NOCOPY    VARCHAR2,
                           x_notification_status        OUT NOCOPY    VARCHAR2,
                           x_return_status_tp           OUT NOCOPY    VARCHAR2,
                           x_return_desc_tp             OUT NOCOPY    VARCHAR2,
                           x_return_status              IN OUT NOCOPY VARCHAR2,
                           x_msg_data                   IN OUT NOCOPY VARCHAR2);

   PROCEDURE XGM_CHECK_STATUS ( p_itemtype                 IN         VARCHAR2,
                               p_itemkey                   IN         VARCHAR2,
                               p_actid                     IN         NUMBER,
                               p_funcmode                  IN         VARCHAR2,
                               x_resultout                 OUT NOCOPY VARCHAR2 );

   PROCEDURE INVOICE_IMPORT_STATUS_HANDLER (p_itemtype                    IN         VARCHAR2,
                                           p_itemkey                      IN         VARCHAR2,
                                           p_actid                        IN         NUMBER,
                                           p_funcmode                     IN         VARCHAR2,
                                           x_resultout                    OUT NOCOPY VARCHAR2 );

   PROCEDURE UPDATE_INV_HEADER_INTERFACE( p_invoice_id                   IN            NUMBER,
                                          p_proprietary_doc_Identifier   IN            VARCHAR2,
                                          p_inv_curr_code                IN            VARCHAR2,
                                          p_inv_amount                   IN            NUMBER,
                                          p_inv_date                     IN            VARCHAR2,
                                          p_inv_type_lookup_code         IN            VARCHAR2,
                                          x_invoice_num                  IN OUT NOCOPY VARCHAR2,
                                          x_return_status                IN OUT NOCOPY VARCHAR2,
                                          x_msg_data                     IN OUT NOCOPY VARCHAR2 );

   PROCEDURE NOTIFY_INVOICE_TO_SYSADMIN (   p_itemtype       IN VARCHAR2,
                                            p_itemkey        IN VARCHAR2,
                                            p_actid          IN NUMBER,
                                            p_funcmode       IN VARCHAR2,
                                            x_resultout      IN OUT NOCOPY VARCHAR2);
   PROCEDURE TRIGGER_REJECTION(
                                      p_invoice_id             IN              NUMBER,
                                      p_group_id               IN              NUMBER,
                                      p_request_id             IN              NUMBER,
                                      p_external_doc_ref       IN              VARCHAR2);

   PROCEDURE GET_REJECTED_INVOICE_DETAILS(
                                      p_invoice_id             IN              NUMBER,
                                      x_invoice_num            IN OUT NOCOPY   VARCHAR2,
                                      x_po_num                 IN OUT NOCOPY   VARCHAR2,
                                      x_invoice_amt            IN OUT NOCOPY   NUMBER,
                                      x_invoice_date           IN OUT NOCOPY   DATE);

   PROCEDURE GET_PO_SHIPMENT_INFO(
                              p_org_id       IN             VARCHAR2,
                              p_so_num       IN             VARCHAR2,
                              p_so_rev_num   IN             VARCHAR2,
                              p_so_lin_num   IN             VARCHAR2,
                              x_po_num       IN OUT NOCOPY  VARCHAR2,
                              x_po_line_num  IN OUT NOCOPY  VARCHAR2,
                              x_po_ship_num  IN OUT NOCOPY  VARCHAR2);

END CLN_NTFYINVC_PKG;

 

/
