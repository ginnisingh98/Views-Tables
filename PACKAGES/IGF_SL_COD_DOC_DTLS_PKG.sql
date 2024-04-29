--------------------------------------------------------
--  DDL for Package IGF_SL_COD_DOC_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_COD_DOC_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI35S.pls 120.0 2005/06/01 13:37:51 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_document_id_txt                       IN     VARCHAR2,
    x_outbound_doc                      IN     CLOB,
    x_inbound_doc                       IN     CLOB,
    x_send_date                         IN     DATE,
    x_ack_date                          IN     DATE,
    x_doc_status                        IN     VARCHAR2,
    x_doc_type                          IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_document_id_txt                       IN     VARCHAR2,
    x_outbound_doc                      IN     CLOB,
    x_inbound_doc                       IN     CLOB,
    x_send_date                         IN     DATE,
    x_ack_date                          IN     DATE,
    x_doc_status                        IN     VARCHAR2,
    x_doc_type                          IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_document_id_txt                       IN     VARCHAR2,
    x_outbound_doc                      IN     CLOB,
    x_inbound_doc                       IN     CLOB,
    x_send_date                         IN     DATE,
    x_ack_date                          IN     DATE,
    x_doc_status                        IN     VARCHAR2,
    x_doc_type                          IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_document_id_txt                       IN     VARCHAR2,
    x_outbound_doc                      IN     CLOB,
    x_inbound_doc                       IN     CLOB,
    x_send_date                         IN     DATE,
    x_ack_date                          IN     DATE,
    x_doc_status                        IN     VARCHAR2,
    x_doc_type                          IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_document_id_txt                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_document_id_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_outbound_doc                      IN     CLOB        DEFAULT NULL,
    x_inbound_doc                       IN     CLOB        DEFAULT NULL,
    x_send_date                         IN     DATE        DEFAULT NULL,
    x_ack_date                          IN     DATE        DEFAULT NULL,
    x_doc_status                        IN     VARCHAR2    DEFAULT NULL,
    x_doc_type                          IN     VARCHAR2    DEFAULT NULL,
    x_full_resp_code                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_cod_doc_dtls_pkg;

 

/
