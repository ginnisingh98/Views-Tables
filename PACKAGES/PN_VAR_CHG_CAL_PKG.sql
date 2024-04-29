--------------------------------------------------------
--  DDL for Package PN_VAR_CHG_CAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_CHG_CAL_PKG" AUTHID CURRENT_USER as
-- $Header: PNCHCALS.pls 120.0 2007/10/03 14:24:48 rthumma noship $

procedure copy_var_rent_agreement (
   p_old_var_rent_id IN NUMBER,
   p_start_date IN DATE DEFAULT NULL,
   p_end_date IN DATE DEFAULT NULL,
   p_proration_rule IN VARCHAR2 DEFAULT 'STD',
   p_create_periods IN VARCHAR2 DEFAULT 'N',
   x_var_rent_id OUT NOCOPY NUMBER,
   x_var_rent_num OUT NOCOPY VARCHAR2) ;

procedure copy_parent_constraints (
    X_VAR_RENT_ID         in NUMBER,
    X_CHG_VAR_RENT_ID     in NUMBER
    );
procedure copy_parent_lines (
    X_VAR_RENT_ID         in NUMBER,
    X_CHG_VAR_RENT_ID     in NUMBER
    );

procedure copy_parent_volhist (
    X_VAR_RENT_ID         in NUMBER,
    X_CHG_VAR_RENT_ID     in NUMBER
    ) ;

PROCEDURE populate_transactions (p_var_rent_id IN NUMBER,
                                 p_period_id IN NUMBER DEFAULT NULL,
                                 p_line_item_id IN NUMBER DEFAULT NULL);

PROCEDURE update_ytd_bkpts(p_var_Rent_id IN NUMBER,
                           p_period_id IN NUMBER DEFAULT NULL,
                           p_start_date  IN DATE DEFAULT NULL,
                           p_end_date    IN DATE DEFAULT NULL);

PROCEDURE determine_reset_flag ( p_var_rent_id    IN NUMBER,
                                 p_period_id      IN NUMBER,
                                 p_item_category_code IN VARCHAR2 DEFAULT NULL,
                                 p_sales_type_code  IN VARCHAR2  DEFAULT NULL,
                                 p_start_date     IN DATE ,
                                 x_reset_flag     OUT NOCOPY VARCHAR2);

PROCEDURE update_blended_period ( p_var_rent_id IN NUMBER);

PROCEDURE update_blended_period ( p_var_rent_id IN NUMBER,
                                   p_start_date  IN DATE,
                                   p_proration_rule IN VARCHAR2);

Function get_last_complete_period_id ( p_var_rent_id IN NUMBER)
RETURN NUMBER ;

Function get_ly_365_start_date ( p_var_rent_id IN NUMBER)
RETURN DATE ;

Function get_fy_365_end_date ( p_var_rent_id IN NUMBER)
RETURN DATE ;

Procedure process_calendar_change (
   p_var_rent_id     IN NUMBER ,
   p_old_var_rent_id IN NUMBER ,
   p_effective_date  IN DATE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_return_message  OUT NOCOPY VARCHAR2
  );

PROCEDURE copy_line_defaults(p_old_var_rent_id NUMBER
,p_new_var_rent_id NUMBER
,p_effective_date DATE );

procedure copy_constr_defaults (
    p_old_var_rent_id in NUMBER,
    p_new_var_rent_id in NUMBER,
    p_effective_date  in DATE
    )   ;

PROCEDURE  create_credit_invoice ( p_var_rent_id NUMBER,
                                   p_effective_date  DATE);

end PN_VAR_CHG_CAL_PKG;

/
