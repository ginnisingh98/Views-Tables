--------------------------------------------------------
--  DDL for Package IGS_UC_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_TRANSACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI32S.pls 120.2 2006/08/21 03:36:43 jbaber noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_uc_tran_id                        IN OUT NOCOPY NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_updater                           IN     VARCHAR2,
    x_error_code                        IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_decision                          IN     VARCHAR2,
    x_program_code                      IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     NUMBER,
    x_soc                               IN     VARCHAR2,
    x_comments_in_offer                 IN     VARCHAR2,
    x_return1                           IN     NUMBER,
    x_return2                           IN     VARCHAR2,
    x_hold_flag                         IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_test_cond_cat                     IN     VARCHAR2,
    x_test_cond_name                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added inst_reference Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_inst_reference                    IN     VARCHAR2    DEFAULT NULL ,
    -- smaddali added column auto generated flag for bug 2603384
    x_auto_generated_flag               IN     VARCHAR2  DEFAULT 'N' ,
    x_system_code                       IN     VARCHAR2  DEFAULT NULL,
    x_ucas_cycle                        IN     VARCHAR2,
    x_modular                           IN     VARCHAR2  DEFAULT NULL,
    x_part_time                         IN     VARCHAR2  DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_uc_tran_id                        IN     NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_updater                           IN     VARCHAR2,
    x_error_code                        IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_decision                          IN     VARCHAR2,
    x_program_code                      IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     NUMBER,
    x_soc                               IN     VARCHAR2,
    x_comments_in_offer                 IN     VARCHAR2,
    x_return1                           IN     NUMBER,
    x_return2                           IN     VARCHAR2,
    x_hold_flag                         IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_test_cond_cat                     IN     VARCHAR2,
    x_test_cond_name                    IN     VARCHAR2,
    -- Added inst_reference Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_inst_reference                    IN     VARCHAR2    DEFAULT NULL ,
    -- smaddali added column auto generated flag for bug 2603384
    x_auto_generated_flag               IN     VARCHAR2  DEFAULT 'N',
    x_system_code                       IN     VARCHAR2  DEFAULT NULL,
    x_ucas_cycle                        IN     VARCHAR2,
    x_modular                           IN     VARCHAR2  DEFAULT NULL,
    x_part_time                         IN     VARCHAR2  DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_uc_tran_id                        IN     NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_updater                           IN     VARCHAR2,
    x_error_code                        IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_decision                          IN     VARCHAR2,
    x_program_code                      IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     NUMBER,
    x_soc                               IN     VARCHAR2,
    x_comments_in_offer                 IN     VARCHAR2,
    x_return1                           IN     NUMBER,
    x_return2                           IN     VARCHAR2,
    x_hold_flag                         IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_test_cond_cat                     IN     VARCHAR2,
    x_test_cond_name                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added inst_reference Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_inst_reference                    IN     VARCHAR2    DEFAULT NULL ,
    -- smaddali added column auto generated flag for bug 2603384
    x_auto_generated_flag               IN     VARCHAR2 DEFAULT 'N' ,
    x_system_code                       IN     VARCHAR2  DEFAULT NULL,
    x_ucas_cycle                        IN     VARCHAR2,
    x_modular                           IN     VARCHAR2  DEFAULT NULL,
    x_part_time                         IN     VARCHAR2  DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_uc_tran_id                        IN OUT NOCOPY NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_updater                           IN     VARCHAR2,
    x_error_code                        IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_decision                          IN     VARCHAR2,
    x_program_code                      IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     NUMBER,
    x_soc                               IN     VARCHAR2,
    x_comments_in_offer                 IN     VARCHAR2,
    x_return1                           IN     NUMBER,
    x_return2                           IN     VARCHAR2,
    x_hold_flag                         IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_test_cond_cat                     IN     VARCHAR2,
    x_test_cond_name                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added inst_reference Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_inst_reference                    IN     VARCHAR2    DEFAULT NULL ,
    -- smaddali added column auto generated flag for bug 2603384
    x_auto_generated_flag               IN     VARCHAR2  DEFAULT 'N',
    x_system_code                       IN     VARCHAR2  DEFAULT NULL,
    x_ucas_cycle                        IN     VARCHAR2,
    x_modular                           IN     VARCHAR2  DEFAULT NULL,
    x_part_time                         IN     VARCHAR2  DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_uc_tran_id                        IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_uc_tran_id                        IN     NUMBER      DEFAULT NULL,
    x_transaction_id                    IN     NUMBER      DEFAULT NULL,
    x_datetimestamp                     IN     DATE        DEFAULT NULL,
    x_updater                           IN     VARCHAR2    DEFAULT NULL,
    x_error_code                        IN     NUMBER      DEFAULT NULL,
    x_transaction_type                  IN     VARCHAR2    DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_choice_no                         IN     NUMBER      DEFAULT NULL,
    x_decision                          IN     VARCHAR2    DEFAULT NULL,
    x_program_code                      IN     VARCHAR2    DEFAULT NULL,
    x_campus                            IN     VARCHAR2    DEFAULT NULL,
    x_entry_month                       IN     NUMBER      DEFAULT NULL,
    x_entry_year                        IN     NUMBER      DEFAULT NULL,
    x_entry_point                       IN     NUMBER      DEFAULT NULL,
    x_soc                               IN     VARCHAR2    DEFAULT NULL,
    x_comments_in_offer                 IN     VARCHAR2    DEFAULT NULL,
    x_return1                           IN     NUMBER      DEFAULT NULL,
    x_return2                           IN     VARCHAR2    DEFAULT NULL,
    x_hold_flag                         IN     VARCHAR2    DEFAULT NULL,
    x_sent_to_ucas                      IN     VARCHAR2    DEFAULT NULL,
    x_test_cond_cat                     IN     VARCHAR2    DEFAULT NULL,
    x_test_cond_name                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    -- Added inst_reference Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_inst_reference                    IN     VARCHAR2    DEFAULT NULL ,
    -- smaddali added column auto generated flag for bug 2603384
    x_auto_generated_flag               IN     VARCHAR2  DEFAULT 'N' ,
    x_system_code                       IN     VARCHAR2  DEFAULT NULL,
    x_ucas_cycle                        IN     VARCHAR2  DEFAULT NULL,
    x_modular                           IN     VARCHAR2  DEFAULT NULL,
    x_part_time                         IN     VARCHAR2  DEFAULT NULL
  );

END igs_uc_transactions_pkg;

 

/
