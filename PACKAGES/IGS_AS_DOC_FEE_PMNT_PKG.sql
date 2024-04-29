--------------------------------------------------------
--  DDL for Package IGS_AS_DOC_FEE_PMNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_DOC_FEE_PMNT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI72S.pls 115.2 2002/11/28 23:29:46 nsidana noship $ */
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_fee_paid_date                     IN     DATE,
    x_fee_amount                        IN     NUMBER,
    x_fee_recorded_date                 IN     DATE,
    x_fee_recorded_by                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_plan_id                           IN     NUMBER      DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_plan_discon_from                  IN     DATE        DEFAULT NULL,
    x_plan_discon_by                    IN     NUMBER      DEFAULT NULL,
    x_num_of_copies                     IN     NUMBER      DEFAULT NULL,
    x_prev_paid_plan                    IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_program_on_file                   IN     VARCHAR2    DEFAULT NULL,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_fee_paid_date                     IN     DATE,
    x_fee_amount                        IN     NUMBER,
    x_fee_recorded_date                 IN     DATE,
    x_fee_recorded_by                   IN     NUMBER,
    x_plan_id                           IN     NUMBER      DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_plan_discon_from                  IN     DATE        DEFAULT NULL,
    x_plan_discon_by                    IN     NUMBER      DEFAULT NULL,
    x_num_of_copies                     IN     NUMBER      DEFAULT NULL,
    x_prev_paid_plan                    IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_program_on_file                   IN     VARCHAR2    DEFAULT NULL,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_fee_paid_date                     IN     DATE,
    x_fee_amount                        IN     NUMBER,
    x_fee_recorded_date                 IN     DATE,
    x_fee_recorded_by                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_plan_id                           IN     NUMBER      DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_plan_discon_from                  IN     DATE        DEFAULT NULL,
    x_plan_discon_by                    IN     NUMBER      DEFAULT NULL,
    x_num_of_copies                     IN     NUMBER      DEFAULT NULL,
    x_prev_paid_plan                    IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_program_on_file                   IN     VARCHAR2    DEFAULT NULL,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_fee_paid_date                     IN     DATE,
    x_fee_amount                        IN     NUMBER,
    x_fee_recorded_date                 IN     DATE,
    x_fee_recorded_by                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_plan_id                           IN     NUMBER      DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_plan_discon_from                  IN     DATE        DEFAULT NULL,
    x_plan_discon_by                    IN     NUMBER      DEFAULT NULL,
    x_num_of_copies                     IN     NUMBER      DEFAULT NULL,
    x_prev_paid_plan                    IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_program_on_file                   IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_fee_paid_date                     IN     DATE        DEFAULT NULL,
    x_fee_amount                        IN     NUMBER      DEFAULT NULL,
    x_fee_recorded_date                 IN     DATE        DEFAULT NULL,
    x_fee_recorded_by                   IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_plan_id                           IN     NUMBER      DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_plan_discon_from                  IN     DATE        DEFAULT NULL,
    x_plan_discon_by                    IN     NUMBER      DEFAULT NULL,
    x_num_of_copies                     IN     NUMBER      DEFAULT NULL,
    x_prev_paid_plan                    IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_program_on_file                   IN     VARCHAR2    DEFAULT NULL

  );
END Igs_As_Doc_Fee_Pmnt_Pkg;

 

/
