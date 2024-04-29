--------------------------------------------------------
--  DDL for Package PN_VAR_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_DEFAULTS_PKG" AUTHID CURRENT_USER AS
/* $Header: PNVRDFTS.pls 120.0 2007/10/03 14:28:58 rthumma noship $ */

procedure create_default_constraints (
    X_VAR_RENT_ID         in NUMBER
    );

procedure create_default_lines (X_VAR_RENT_ID   IN NUMBER,
            X_CREATE_FLAG   IN VARCHAR2 DEFAULT 'N');

procedure delete_default_lines (x_var_rent_id           IN      NUMBER,
                                x_bkhd_default_id       IN      NUMBER DEFAULT NULL,
                                x_bkpt_header_id        IN      NUMBER DEFAULT NULL);

procedure reset_default_lines (
    X_BKHD_DEFAULT_ID         in NUMBER
    );

procedure delete_transactions ( X_VAR_RENT_ID            in    NUMBER,
                                x_bkhd_default_id       IN      NUMBER DEFAULT NULL,
                                x_bkpt_header_id        IN      NUMBER DEFAULT NULL);

FUNCTION calculate_partial_first_year (X_VAR_RENT_ID   NUMBER)
      RETURN NUMBER;

FUNCTION calculate_partial_last_year (X_VAR_RENT_ID   NUMBER)
      RETURN NUMBER;

FUNCTION calculate_default_base_rent (p_var_rent_id    NUMBER,
                                      p_base_rent_type VARCHAR2)
      RETURN NUMBER;

FUNCTION find_if_line_defaults_exist (p_var_rent_id NUMBER)
     RETURN NUMBER;

FUNCTION find_if_constr_defaults_exist (p_var_rent_id NUMBER)
     RETURN NUMBER;

PROCEDURE populate_agreement (
      X_VAR_RENT_ID            in NUMBER,
      X_LINE_ID                in NUMBER,
      X_PERIOD_ID              in NUMBER,
      X_AGREEMENT_TEMPLATE_ID  in NUMBER,
      X_LINE_TEMPLATE_ID       in NUMBER,
      X_CURRENT_BLOCK          in VARCHAR2
      );

PROCEDURE populate_default_dates (
     X_VAR_RENT_ID             in NUMBER,
     X_BKHD_DEFAULT_ID         in NUMBER,
     X_LINE_DEFAULT_ID         in NUMBER
     );


PROCEDURE put_log(p_str VARCHAR2);

procedure CREATE_SETUP_DATA (X_VAR_RENT_ID   IN NUMBER);

end PN_VAR_DEFAULTS_PKG;

/
