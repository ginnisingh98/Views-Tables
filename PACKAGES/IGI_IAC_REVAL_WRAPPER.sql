--------------------------------------------------------
--  DDL for Package IGI_IAC_REVAL_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVAL_WRAPPER" AUTHID CURRENT_USER AS
-- $Header: igiiarws.pls 120.4.12000000.1 2007/08/01 16:18:41 npandya ship $

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

/* function to do the revaluation calculation once the structures are initialized.
** Note, use a dummy variable to deal with the fp_reval_output_asset params */
-- This routine would be called from additions and reclass
function do_reval_calc_asset ( L_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params
                             , fp_reval_output_asset  IN OUT NOCOPY IGI_IAC_TYPES.iac_reval_output_asset
                             )
return boolean
;
/*
-- function to do the process of the revaluation at the asset level!
-- this function is called by the REvaluation concurrent programs, additions and reclass
-- routines.
-- The calling program has to be set properly for the initialization.
*/

function do_revaluation_asset
         ( fp_revaluation_id in number
         , fp_asset_id       in number
         , fp_book_type_code in varchar2
         , fp_reval_mode     in varchar2
         , fp_reval_rate     in number
         , fp_period_counter in number
         , fp_calling_program   in varchar2
         , fp_reval_output_asset in out NOCOPY IGI_IAC_TYPES.iac_reval_output_asset
         , fp_reval_messages    in out NOCOPY IGI_IAC_TYPES.iac_reval_mesg
         , fp_reval_messages_idx  in out NOCOPY IGI_IAC_TYPES.iac_reval_mesg_idx
         , fp_reval_exceptions in out NOCOPY IGI_IAC_TYPES.iac_reval_exceptions
         , fp_reval_exceptions_idx in out NOCOPY IGI_IAC_TYPES.iac_reval_exceptions_idx
         )
return  boolean;

function do_calculation_asset
                   (  fp_revaluation_id  number
                   ,  fp_asset_id        number
                   ,  fp_book_type_code  varchar2
                   ,  fp_reval_mode      varchar2
                   ,  fp_reval_rate      number
                   ,  fp_period_counter  number
                   ,  fp_iac_reval_output_asset out NOCOPY IGI_IAC_TYPES.iac_reval_output_asset
                   )
return boolean;

END;

 

/
