--------------------------------------------------------
--  DDL for Package IGI_IAC_REVAL_CONCURRENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVAL_CONCURRENT" AUTHID CURRENT_USER AS
-- $Header: igiiarcs.pls 120.5.12000000.1 2007/08/01 16:16:45 npandya ship $

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

/*
-- Submit Revaluation Report
*/

procedure submit_revaluation_report ( p_revaluation_id in number
                                    , p_revaluation_mode in varchar2
                                    ) ;
/*
-- convert preview info to live
*/

function preview_mode_hist_transform ( fp_revaluation_id in number
                                     , fp_book_type_code in varchar2
                                     , fp_period_counter in number
                                     )
return  boolean ;

/*
--  Generate preview mode entries.
*/
function preview_mode_hist_generate  ( fp_revaluation_id in number
                                     , fp_book_type_code in varchar2
                                     , fp_period_counter in number
                                     , fp_wait_request_id in number
                                     )
return   boolean ;

/*
-- Delete preview history completely
*/

function preview_mode_hist_delete  ( fp_revaluation_id in number)
return   boolean;

/*
-- Test whether preview has been run again
*/

function preview_mode_hist_available ( fp_revaluation_id in  number )
return boolean;

/*
-- Test whether Run mode has processed successfully.
*/

function run_mode_hist_available ( fp_revaluation_id in  number )
return boolean;

/*
-- Process the revaluation run.
*/

procedure revaluation
                   ( errbuf            out NOCOPY varchar2
                   , retcode           out NOCOPY number
                   , revaluation_id    in number
                   , book_type_code    in varchar2
                   , revaluation_mode  in varchar2 -- 'P' preview, 'R' run
                   , period_counter    in  number
                   , create_request_id in number
                   )
;

END;

 

/
