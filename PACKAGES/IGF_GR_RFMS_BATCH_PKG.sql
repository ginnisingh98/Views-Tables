--------------------------------------------------------
--  DDL for Package IGF_GR_RFMS_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_RFMS_BATCH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFGI15S.pls 115.3 2002/11/28 14:18:50 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rfmb_id                           IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_data_rec_length                   IN     VARCHAR2,
    x_ope_id                            IN     VARCHAR2,
    x_software_providor                 IN     VARCHAR2,
    x_rfms_process_dt                   IN     DATE,
    x_rfms_ack_dt                       IN     DATE,
    x_rfms_ack_batch_id                 IN     VARCHAR2,
    x_reject_reason                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_data_rec_length                   IN     VARCHAR2,
    x_ope_id                            IN     VARCHAR2,
    x_software_providor                 IN     VARCHAR2,
    x_rfms_process_dt                   IN     DATE,
    x_rfms_ack_dt                       IN     DATE,
    x_rfms_ack_batch_id                 IN     VARCHAR2,
    x_reject_reason                     IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_data_rec_length                   IN     VARCHAR2,
    x_ope_id                            IN     VARCHAR2,
    x_software_providor                 IN     VARCHAR2,
    x_rfms_process_dt                   IN     DATE,
    x_rfms_ack_dt                       IN     DATE,
    x_rfms_ack_batch_id                 IN     VARCHAR2,
    x_reject_reason                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rfmb_id                           IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_data_rec_length                   IN     VARCHAR2,
    x_ope_id                            IN     VARCHAR2,
    x_software_providor                 IN     VARCHAR2,
    x_rfms_process_dt                   IN     DATE,
    x_rfms_ack_dt                       IN     DATE,
    x_rfms_ack_batch_id                 IN     VARCHAR2,
    x_reject_reason                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_rfmb_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rfmb_id                           IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_data_rec_length                   IN     VARCHAR2    DEFAULT NULL,
    x_ope_id                            IN     VARCHAR2    DEFAULT NULL,
    x_software_providor                 IN     VARCHAR2    DEFAULT NULL,
    x_rfms_process_dt                   IN     DATE        DEFAULT NULL,
    x_rfms_ack_dt                       IN     DATE        DEFAULT NULL,
    x_rfms_ack_batch_id                 IN     VARCHAR2    DEFAULT NULL,
    x_reject_reason                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_gr_rfms_batch_pkg;

 

/
