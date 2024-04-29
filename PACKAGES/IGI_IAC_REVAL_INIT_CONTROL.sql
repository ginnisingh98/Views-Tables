--------------------------------------------------------
--  DDL for Package IGI_IAC_REVAL_INIT_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVAL_INIT_CONTROL" AUTHID CURRENT_USER AS
-- $Header: igiiaris.pls 120.4.12000000.1 2007/08/01 16:17:19 npandya ship $
l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

/*
-- initialize the control array if submitted from the IGIIARVC concurrent program!
-- this is done for each asset.
*/

function init_control_for_srs    ( fp_asset_id               in number
                                 , fp_book_type_code         in varchar2
                                 , fp_revaluation_id         in number
                                 , fp_revaluation_mode       in varchar2
                                 , fp_period_counter         in number
                                 , fp_iac_reval_control_type out NOCOPY IGI_IAC_TYPES.iac_reval_control_type
                                 )
return  boolean;

/*
-- initialize if called for calculation from the form
*/

function init_control_for_calc    ( fp_asset_id               in number
                                  , fp_book_type_code         in varchar2
                                  , fp_revaluation_id         in number
                                  , fp_revaluation_mode       in varchar2
                                  , fp_period_counter         in number
                                  , fp_iac_reval_control_type out NOCOPY IGI_IAC_TYPES.iac_reval_control_type
                                 )
return  boolean;

END;

 

/
