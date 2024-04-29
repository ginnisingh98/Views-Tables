--------------------------------------------------------
--  DDL for Package IPA_CLIENT_EXTENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IPA_CLIENT_EXTENSION_PKG" AUTHID CURRENT_USER AS
 /*  $Header: IPAAMCES.pls 120.2 2005/08/16 16:40:39 dlanka noship $ */
 FUNCTION unique_qualifier_to_segment(appl_id   IN NUMBER,
                                         code      IN VARCHAR2,
                                         num       IN NUMBER,
                                         qualifier IN VARCHAR2,
                                         name      IN OUT NOCOPY VARCHAR2)
 RETURN BOOLEAN;

 FUNCTION get_segment_number(appl_id  IN NUMBER,
                                code     IN VARCHAR2,
                                num      IN NUMBER,
                                segment  IN VARCHAR2,
                                sequence IN OUT NOCOPY NUMBER)
 RETURN BOOLEAN;

 procedure get_default_deprn_expense(p_book_type_code in varchar2,
                                     p_asset_category_id in number,
                                     p_location_id in number default null,
                                     p_expenditure_item_id in number default null,
                                     p_expense_ccid_out in out NOCOPY number,
                                     p_err_stack in out NOCOPY varchar2,
                                     p_err_stage in out NOCOPY varchar2,
                                     p_err_code in out NOCOPY varchar2);

 procedure build_deprn_expense_acct(p_book_type_code in varchar2,
                                    p_asset_category_id in number,
                                    p_location_id in number default null,
                                    p_expenditure_item_id in number default null,
                                    p_expense_ccid_out in out NOCOPY number,
                                    p_err_stack in out NOCOPY varchar2,
                                    p_err_stage in out NOCOPY varchar2,
                                    p_err_code in out NOCOPY varchar2);

 PROCEDURE SET_UNITS_TO_ADJUST(x_mass_addition_row   IN fa_mass_additions%ROWTYPE,
                               x_units_to_adjust     IN OUT NOCOPY NUMBER,
                               x_error_code          IN OUT NOCOPY VARCHAR2,
                               x_error_message       IN OUT NOCOPY VARCHAR2);


 END IPA_CLIENT_EXTENSION_PKG;

 

/
