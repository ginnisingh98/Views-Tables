--------------------------------------------------------
--  DDL for Package IGF_SL_CL_RESP_R3_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_RESP_R3_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI38S.pls 120.0 2005/06/02 15:50:16 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clresp3_id                        IN OUT NOCOPY NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code_txt                   IN     VARCHAR2,
    x_message_1_text                    IN     VARCHAR2,
    x_message_2_text                    IN     VARCHAR2,
    x_message_3_text                    IN     VARCHAR2,
    x_message_4_text                    IN     VARCHAR2,
    x_message_5_text                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_clresp3_id                        IN     NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code_txt                   IN     VARCHAR2,
    x_message_1_text                    IN     VARCHAR2,
    x_message_2_text                    IN     VARCHAR2,
    x_message_3_text                    IN     VARCHAR2,
    x_message_4_text                    IN     VARCHAR2,
    x_message_5_text                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_clresp3_id                        IN     NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code_txt                   IN     VARCHAR2,
    x_message_1_text                    IN     VARCHAR2,
    x_message_2_text                    IN     VARCHAR2,
    x_message_3_text                    IN     VARCHAR2,
    x_message_4_text                    IN     VARCHAR2,
    x_message_5_text                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clresp3_id                        IN OUT NOCOPY NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code_txt                   IN     VARCHAR2,
    x_message_1_text                    IN     VARCHAR2,
    x_message_2_text                    IN     VARCHAR2,
    x_message_3_text                    IN     VARCHAR2,
    x_message_4_text                    IN     VARCHAR2,
    x_message_5_text                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_clresp3_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_sl_cl_resp_r1 (
    x_clrp1_id                            IN     NUMBER
  ) ;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clresp3_id                        IN     NUMBER      DEFAULT NULL,
    x_clrp1_id                          IN     NUMBER      DEFAULT NULL,
    x_record_code_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_message_1_text                    IN     VARCHAR2    DEFAULT NULL,
    x_message_2_text                    IN     VARCHAR2    DEFAULT NULL,
    x_message_3_text                    IN     VARCHAR2    DEFAULT NULL,
    x_message_4_text                    IN     VARCHAR2    DEFAULT NULL,
    x_message_5_text                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_cl_resp_r3_dtls_pkg;

 

/
