--------------------------------------------------------
--  DDL for Package IGF_AP_TD_INST_REQRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_TD_INST_REQRS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI14S.pls 115.6 2002/11/28 13:56:02 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_tdirr_req_reason_flag             IN     VARCHAR2,
    x_tdirr_req_reason_code             IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_override_by                       IN     NUMBER,
    x_override_date                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_tdirr_req_reason_flag             IN     VARCHAR2,
    x_tdirr_req_reason_code             IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_override_by                       IN     NUMBER,
    x_override_date                     IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_tdirr_req_reason_flag             IN     VARCHAR2,
    x_tdirr_req_reason_code             IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_override_by                       IN     NUMBER,
    x_override_date                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_tdirr_req_reason_flag             IN     VARCHAR2,
    x_tdirr_req_reason_code             IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_override_by                       IN     NUMBER,
    x_override_date                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_tdirr_req_reason_code             IN     VARCHAR2,
    x_tdirr_req_reason_flag             IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_ap_td_item_inst (
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_item_sequence_number              IN     NUMBER      DEFAULT NULL,
    x_tdirr_req_reason_flag             IN     VARCHAR2    DEFAULT NULL,
    x_tdirr_req_reason_code             IN     VARCHAR2    DEFAULT NULL,
    x_override_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_override_by                       IN     NUMBER      DEFAULT NULL,
    x_override_date                     IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_td_inst_reqrs_pkg;

 

/
