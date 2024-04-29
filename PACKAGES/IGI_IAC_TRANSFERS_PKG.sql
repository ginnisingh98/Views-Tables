--------------------------------------------------------
--  DDL for Package IGI_IAC_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_TRANSFERS_PKG" AUTHID CURRENT_USER AS
--  $Header: igiiatfs.pls 120.3.12000000.2 2007/10/16 14:27:46 sharoy ship $

    FUNCTION Do_Transfer(p_trans_rec		FA_API_TYPES.trans_rec_type,
			  p_asset_hdr_rec	FA_API_TYPES.asset_hdr_rec_type,
			  p_asset_cat_rec	FA_API_TYPES.asset_cat_rec_type,
			  p_calling_function	varchar2,
			  p_event_id             number    --R12 uptake
			 )RETURN BOOLEAN;
    FUNCTION  Do_prior_transfer(p_book_type_code	fa_books.book_type_code%type,
    				p_asset_id		fa_additions_b.asset_id%type,
    				p_category_id		fa_categories.category_id%type,
    				p_transaction_header_id	fa_transaction_headers.transaction_header_id%type,
    				p_cost			fa_books.cost%type,
    				p_adjusted_cost		fa_books.adjusted_cost%type,
    				p_salvage_value		fa_books.salvage_value%type,
    				p_current_units		fa_additions_b.current_units%type,
    				p_life_in_months	fa_books.life_in_months%type,
    				p_calling_function	varchar2,
    				p_event_id          number    --R12 uptake
    				) RETURN BOOLEAN;
    FUNCTION Do_Rollback_Deprn(
   				p_book_type_code                 VARCHAR2,
   				p_period_counter                 NUMBER,
   				p_calling_function               VARCHAR2
			      ) return BOOLEAN;



END IGI_IAC_TRANSFERS_PKG;

 

/
