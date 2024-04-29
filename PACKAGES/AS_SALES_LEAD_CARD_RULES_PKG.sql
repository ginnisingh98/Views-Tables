--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_CARD_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_CARD_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: asxtscrs.pls 120.1 2005/06/24 17:00:32 appldev ship $ */
     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY  VARCHAR2
        , x_card_rule_id                     NUMBER
        , x_scorecard_id                     NUMBER
        , x_last_update_date                 DATE
        , x_last_updated_by                  NUMBER
        , x_creation_date                    DATE
        , x_created_by                       NUMBER
        , x_last_update_login                NUMBER
        , x_description                      VARCHAR2
        , x_start_date_active                DATE
        , x_end_date_active                  DATE
        , x_score                            NUMBER
     );

     PROCEDURE delete_row(
        x_card_rule_id                     NUMBER
     );

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_card_rule_id                   NUMBER
        , x_scorecard_id                   NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_creation_date                  DATE
        , x_created_by                     NUMBER
        , x_last_update_login              NUMBER
        , x_description                    VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
        , x_score                          NUMBER
     );

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_card_rule_id                   NUMBER
        , x_scorecard_id                   NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_creation_date                  DATE
        , x_created_by                     NUMBER
        , x_last_update_login              NUMBER
        , x_description                    VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
        , x_score                          NUMBER
     );
END as_sales_lead_card_rules_pkg;

 

/
