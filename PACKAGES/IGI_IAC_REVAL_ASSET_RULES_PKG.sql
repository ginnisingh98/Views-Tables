--------------------------------------------------------
--  DDL for Package IGI_IAC_REVAL_ASSET_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVAL_ASSET_RULES_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiarrs.pls 120.4.12000000.1 2007/08/01 16:17:55 npandya ship $

  PROCEDURE insert_row (
        X_rowid                         IN OUT NOCOPY  VARCHAR2,
        X_revaluation_id                IN      NUMBER,
        X_book_type_code                IN      VARCHAR2,
        X_category_id                   IN      NUMBER,
        X_asset_id                      IN      NUMBER,
        X_revaluation_factor            IN      NUMBER,
        X_revaluation_type              IN      VARCHAR2,
        X_new_cost                      IN      NUMBER,
        X_current_cost                  IN      NUMBER,
        X_selected_for_reval_flag       IN      VARCHAR2,
        X_selected_for_calc_flag        IN      VARCHAR2,
        X_allow_prof_update             IN      VARCHAR2,
        X_mode                          IN      VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_asset_id                          IN      NUMBER,
    x_book_type_code                    IN      VARCHAR2,
    x_revaluation_id                    IN      NUMBER
  );

END igi_iac_reval_asset_rules_pkg;

 

/
