--------------------------------------------------------
--  DDL for Package IGI_IAC_REVAL_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVAL_VALIDATION" AUTHID CURRENT_USER AS
-- $Header: igiiarvs.pls 120.5.12000000.1 2007/08/01 16:18:31 npandya ship $

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

function validate_reval_type     ( fp_asset_id       number
                                 , fp_revaluation_id number
                                 , fp_book_type_code varchar2
                                 , fp_reval_type     varchar2
                                 , fp_period_counter number
                                 )
return  boolean;

function validate_fa_revals   ( fp_asset_id       number
                              , fp_book_type_code varchar2
                              )
return boolean;

function  validate_new_fa_txns ( fp_asset_id       number
                               , fp_book_type_code varchar2
                               , fp_period_counter number
                               )
return  boolean;

function  not_retired_in_curr_year ( fp_asset_id       number
                               , fp_book_type_code varchar2
                               )
return  boolean;

function  not_adjusted_asset      ( fp_asset_id       number
                               , fp_book_type_code varchar2
                               )
return  boolean;

FUNCTION Validate_Multiple_Previews( fp_asset_id       number
                              , fp_book_type_code varchar2
                              , fp_period_counter number
                              , fp_revaluation_id number
                              , fp_preview_reval_id OUT NOCOPY number
                               )
RETURN BOOLEAN;

function  validate_asset      ( fp_asset_id       number
                              , fp_book_type_code varchar2
                              , fp_period_counter number
                              , fp_reval_type     varchar2
                              , fp_revaluation_id number
                               )
return  boolean;

function  validate_asset      ( fp_asset_id       number
                              , fp_book_type_code varchar2
                              , fp_period_counter number
                              , fp_reval_type     varchar2
                              , fp_revaluation_id number
                              , fp_exceptions          IN OUT NOCOPY    IGI_IAC_TYPES.iac_reval_exceptions
                              , fp_exceptions_idx      IN OUT NOCOPY    IGI_IAC_TYPES.iac_reval_exceptions_idx
                              )
return  boolean;

function validate_cost        ( fp_asset_id       number
                              , fp_book_type_code varchar2
                              , fp_revaluation_id number
                              )
return boolean;



END;

 

/
