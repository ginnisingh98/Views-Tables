--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_SCORECARDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_SCORECARDS_PKG" AUTHID CURRENT_USER AS
/* $Header: asxtscds.pls 115.6 2002/11/22 08:05:00 ckapoor ship $ */
     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_scorecard_id                     NUMBER
        , x_last_update_date                 DATE
        , x_last_updated_by                  NUMBER
        , x_creation_date                    DATE
        , x_created_by                       NUMBER
        , x_last_update_login                NUMBER
        , x_description                      VARCHAR2
        , x_enabled_flag                     VARCHAR2
        , x_start_date_active                DATE
        , x_end_date_active                  DATE
     );

     PROCEDURE delete_row(
        x_scorecard_id                     NUMBER
     );

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_scorecard_id                   NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_creation_date                  DATE
        , x_created_by                     NUMBER
        , x_last_update_login              NUMBER
        , x_description                    VARCHAR2
        , x_enabled_flag                   VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     );


     PROCEDURE update_row(
          x_scorecard_id                   NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_last_update_login              NUMBER
        , x_description                    VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     );

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_scorecard_id                   NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_creation_date                  DATE
        , x_created_by                     NUMBER
        , x_last_update_login              NUMBER
        , x_description                    VARCHAR2
        , x_enabled_flag                   VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     );

     PROCEDURE load_row(
          x_scorecard_id                   NUMBER
        , x_description                    VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
        , x_owner                          VARCHAR2
     );

END as_sales_lead_scorecards_pkg;

 

/
