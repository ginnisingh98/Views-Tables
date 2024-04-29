--------------------------------------------------------
--  DDL for Package AS_CARD_RULE_QUAL_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_CARD_RULE_QUAL_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: asxtcqvs.pls 120.1 2005/06/24 16:58:32 appldev ship $ */
     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY  VARCHAR2
        , x_qual_value_id                    NUMBER
        , x_last_update_date                 DATE
        , x_last_updated_by                  NUMBER
        , x_creation_date                    DATE
        , x_created_by                       NUMBER
        , x_last_update_login                NUMBER
        , x_scorecard_id                     NUMBER
        , x_score                            NUMBER
        , x_card_rule_id                     NUMBER
        , x_seed_qual_id                     NUMBER
        , x_high_value_number                NUMBER
        , x_low_value_number                 NUMBER
        , x_high_value_char                  VARCHAR2
        , x_low_value_char                   VARCHAR2
        , x_currency_code                    VARCHAR2
        , x_low_value_date                   DATE
        , x_high_value_date                  DATE
        , x_start_date_active                DATE
        , x_end_date_active                  DATE
     );

     PROCEDURE delete_row(
        x_qual_value_id                    NUMBER
     );

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_qual_value_id                  NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_last_update_login              NUMBER
        , x_scorecard_id                     NUMBER
        , x_score                            NUMBER
        , x_card_rule_id                   NUMBER
        , x_seed_qual_id                   NUMBER
        , x_high_value_number              NUMBER
        , x_low_value_number               NUMBER
        , x_high_value_char                VARCHAR2
        , x_low_value_char                 VARCHAR2
        , x_currency_code                  VARCHAR2
        , x_low_value_date                 DATE
        , x_high_value_date                DATE
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     );

     PROCEDURE update_row(
          x_qual_value_id                  NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_last_update_login              NUMBER
        , x_scorecard_id                     NUMBER
        , x_score                            NUMBER
        , x_card_rule_id                   NUMBER
        , x_seed_qual_id                   NUMBER
        , x_high_value_number              NUMBER
        , x_low_value_number               NUMBER
        , x_high_value_char                VARCHAR2
        , x_low_value_char                 VARCHAR2
        , x_currency_code                  VARCHAR2
        , x_low_value_date                 DATE
        , x_high_value_date                DATE
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     );

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_qual_value_id                  NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_creation_date                  DATE
        , x_created_by                     NUMBER
        , x_last_update_login              NUMBER
        , x_scorecard_id                     NUMBER
        , x_score                            NUMBER
        , x_card_rule_id                   NUMBER
        , x_seed_qual_id                   NUMBER
        , x_high_value_number              NUMBER
        , x_low_value_number               NUMBER
        , x_high_value_char                VARCHAR2
        , x_low_value_char                 VARCHAR2
        , x_currency_code                  VARCHAR2
        , x_low_value_date                 DATE
        , x_high_value_date                DATE
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     );


     PROCEDURE load_row(
          x_qual_value_id                  NUMBER
        , x_scorecard_id                   NUMBER
        , x_score                          NUMBER
        , x_card_rule_id                   NUMBER
        , x_seed_qual_id                   NUMBER
        , x_high_value_number              NUMBER
        , x_low_value_number               NUMBER
        , x_high_value_char                VARCHAR2
        , x_low_value_char                 VARCHAR2
        , x_currency_code                  VARCHAR2
        , x_low_value_date                 DATE
        , x_high_value_date                DATE
        , x_start_date_active              DATE
        , x_end_date_active                DATE
        , x_owner                          VARCHAR2
     );

END as_card_rule_qual_values_pkg;

 

/
