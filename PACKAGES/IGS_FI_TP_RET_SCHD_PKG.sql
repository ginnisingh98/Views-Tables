--------------------------------------------------------
--  DDL for Package IGS_FI_TP_RET_SCHD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_TP_RET_SCHD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIE7S.pls 120.0 2005/06/01 22:46:30 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ftci_teach_retention_id           IN OUT NOCOPY NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_ret_percentage                    IN     NUMBER,
    x_ret_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ftci_teach_retention_id           IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_ret_percentage                    IN     NUMBER,
    x_ret_amount                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ftci_teach_retention_id           IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_ret_percentage                    IN     NUMBER,
    x_ret_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ftci_teach_retention_id           IN OUT NOCOPY NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_ret_percentage                    IN     NUMBER,
    x_ret_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );


  FUNCTION get_pk_for_validation (
    x_ftci_teach_retention_id           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ftci_teach_retention_id           IN     NUMBER      DEFAULT NULL,
    x_teach_cal_type                    IN     VARCHAR2    DEFAULT NULL,
    x_teach_ci_sequence_number          IN     NUMBER      DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_dt_alias                          IN     VARCHAR2    DEFAULT NULL,
    x_dai_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_ret_percentage                    IN     NUMBER      DEFAULT NULL,
    x_ret_amount                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE get_fk_igs_ca_da_inst (
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );
  PROCEDURE Check_Constraints (
   	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
  );
END igs_fi_tp_ret_schd_pkg;

 

/
