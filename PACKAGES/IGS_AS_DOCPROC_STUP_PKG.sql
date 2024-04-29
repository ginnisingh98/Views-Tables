--------------------------------------------------------
--  DDL for Package IGS_AS_DOCPROC_STUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_DOCPROC_STUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI67S.pls 115.2 2002/11/28 23:27:59 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tpset_id                          IN OUT NOCOPY NUMBER,
    x_lifetime_trans_fee_ind            IN     VARCHAR2,
    x_provide_transcript_ind            IN     VARCHAR2,
    x_trans_request_if_hold_ind         IN     VARCHAR2,
    x_all_acad_hist_in_one_doc_ind      IN     VARCHAR2,
    x_hold_deliv_ind                    IN     VARCHAR2,
    x_allow_enroll_cert_ind             IN     VARCHAR2,
    x_bill_me_later_ind                 IN     VARCHAR2,
    x_edi_capable_ind                   IN     VARCHAR2,
    x_always_send_docs_via_edi          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_provide_duplicate_doc_ind    IN     VARCHAR2    DEFAULT 'N',
    x_charge_document_fee_ind           IN     VARCHAR2    DEFAULT 'N',
    x_charge_delivery_fee_ind           IN     VARCHAR2    DEFAULT 'N',
    x_administrator_id                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_tpset_id                          IN     NUMBER,
    x_lifetime_trans_fee_ind            IN     VARCHAR2,
    x_provide_transcript_ind            IN     VARCHAR2,
    x_trans_request_if_hold_ind         IN     VARCHAR2,
    x_all_acad_hist_in_one_doc_ind      IN     VARCHAR2,
    x_hold_deliv_ind                    IN     VARCHAR2,
    x_allow_enroll_cert_ind             IN     VARCHAR2,
    x_bill_me_later_ind                 IN     VARCHAR2,
    x_edi_capable_ind                   IN     VARCHAR2,
    x_always_send_docs_via_edi          IN     VARCHAR2,
    x_provide_duplicate_doc_ind    IN     VARCHAR2,
    x_charge_document_fee_ind           IN     VARCHAR2,
    x_charge_delivery_fee_ind           IN     VARCHAR2,
    x_administrator_id                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_tpset_id                          IN     NUMBER,
    x_lifetime_trans_fee_ind            IN     VARCHAR2,
    x_provide_transcript_ind            IN     VARCHAR2,
    x_trans_request_if_hold_ind         IN     VARCHAR2,
    x_all_acad_hist_in_one_doc_ind      IN     VARCHAR2,
    x_hold_deliv_ind                    IN     VARCHAR2,
    x_allow_enroll_cert_ind             IN     VARCHAR2,
    x_bill_me_later_ind                 IN     VARCHAR2,
    x_edi_capable_ind                   IN     VARCHAR2,
    x_always_send_docs_via_edi          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_provide_duplicate_doc_ind    IN     VARCHAR2    DEFAULT 'N',
    x_charge_document_fee_ind           IN     VARCHAR2    DEFAULT 'N',
    x_charge_delivery_fee_ind           IN     VARCHAR2    DEFAULT 'N',
    x_administrator_id                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tpset_id                          IN OUT NOCOPY NUMBER,
    x_lifetime_trans_fee_ind            IN     VARCHAR2,
    x_provide_transcript_ind            IN     VARCHAR2,
    x_trans_request_if_hold_ind         IN     VARCHAR2,
    x_all_acad_hist_in_one_doc_ind      IN     VARCHAR2,
    x_hold_deliv_ind                    IN     VARCHAR2,
    x_allow_enroll_cert_ind             IN     VARCHAR2,
    x_bill_me_later_ind                 IN     VARCHAR2,
    x_edi_capable_ind                   IN     VARCHAR2,
    x_always_send_docs_via_edi          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_provide_duplicate_doc_ind    IN     VARCHAR2    DEFAULT 'N',
    x_charge_document_fee_ind           IN     VARCHAR2    DEFAULT 'N',
    x_charge_delivery_fee_ind           IN     VARCHAR2    DEFAULT 'N',
    x_administrator_id                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_tpset_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_tpset_id                          IN     NUMBER      DEFAULT NULL,
    x_lifetime_trans_fee_ind            IN     VARCHAR2    DEFAULT NULL,
    x_provide_transcript_ind            IN     VARCHAR2    DEFAULT NULL,
    x_trans_request_if_hold_ind         IN     VARCHAR2    DEFAULT NULL,
    x_all_acad_hist_in_one_doc_ind      IN     VARCHAR2    DEFAULT NULL,
    x_hold_deliv_ind                    IN     VARCHAR2    DEFAULT NULL,
    x_allow_enroll_cert_ind             IN     VARCHAR2    DEFAULT NULL,
    x_bill_me_later_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_edi_capable_ind                   IN     VARCHAR2    DEFAULT NULL,
    x_always_send_docs_via_edi          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_provide_duplicate_doc_ind    IN     VARCHAR2    DEFAULT 'N',
    x_charge_document_fee_ind           IN     VARCHAR2    DEFAULT 'N',
    x_charge_delivery_fee_ind           IN     VARCHAR2    DEFAULT 'N',
    x_administrator_id                  IN     VARCHAR2    DEFAULT NULL
  );

END igs_as_docproc_stup_pkg;

 

/
