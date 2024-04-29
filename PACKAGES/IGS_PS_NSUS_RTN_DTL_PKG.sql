--------------------------------------------------------
--  DDL for Package IGS_PS_NSUS_RTN_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_NSUS_RTN_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3OS.pls 120.0 2005/06/01 17:42:58 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_non_std_usec_rtn_dtl_id           IN OUT NOCOPY NUMBER,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_offset_value                      IN     NUMBER,
    x_retention_percent                 IN     NUMBER,
    x_retention_amount                  IN     NUMBER,
    x_offset_date                       IN     DATE,
    x_override_date_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_rtn_dtl_id           IN     NUMBER,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_offset_value                      IN     NUMBER,
    x_retention_percent                 IN     NUMBER,
    x_retention_amount                  IN     NUMBER,
    x_offset_date                       IN     DATE,
    x_override_date_flag                IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_rtn_dtl_id           IN     NUMBER,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_offset_value                      IN     NUMBER,
    x_retention_percent                 IN     NUMBER,
    x_retention_amount                  IN     NUMBER,
    x_offset_date                       IN     DATE,
    x_override_date_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_non_std_usec_rtn_dtl_id           IN OUT NOCOPY NUMBER,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_offset_value                      IN     NUMBER,
    x_retention_percent                 IN     NUMBER,
    x_retention_amount                  IN     NUMBER,
    x_offset_date                       IN     DATE,
    x_override_date_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_non_std_usec_rtn_dtl_id           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_offset_value                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_nsus_rtn (
    x_non_std_usec_rtn_id               IN     NUMBER
  );

  PROCEDURE Check_Constraints(
                                Column_Name     IN      VARCHAR2        DEFAULT NULL,
                                Column_Value    IN      VARCHAR2        DEFAULT NULL);

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_non_std_usec_rtn_dtl_id           IN     NUMBER      DEFAULT NULL,
    x_non_std_usec_rtn_id               IN     NUMBER      DEFAULT NULL,
    x_offset_value                      IN     NUMBER      DEFAULT NULL,
    x_retention_percent                 IN     NUMBER      DEFAULT NULL,
    x_retention_amount                  IN     NUMBER      DEFAULT NULL,
    x_offset_date                       IN     DATE        DEFAULT NULL,
    x_override_date_flag                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_nsus_rtn_dtl_pkg;

 

/
