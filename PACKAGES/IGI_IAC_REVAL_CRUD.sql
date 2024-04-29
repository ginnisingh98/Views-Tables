--------------------------------------------------------
--  DDL for Package IGI_IAC_REVAL_CRUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVAL_CRUD" AUTHID CURRENT_USER AS
-- $Header: igiiards.pls 120.4.12000000.3 2007/10/22 06:27:51 npandya ship $

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

function create_exceptions
    ( fp_reval_exceptions    in out NOCOPY IGI_IAC_TYPES.iac_reval_exception_line
    , fp_revaluation_id      in     NUMBER
    )
return boolean;

function create_txn_headers
    ( fp_reval_params    in out NOCOPY IGI_IAC_TYPES.iac_reval_params
    , fp_second_set      in boolean default false )
return boolean;

function create_asset_balances
    ( fp_reval_params    in out NOCOPY IGI_IAC_TYPES.iac_reval_params
     , fp_second_set     in boolean default false )
return boolean;

function create_det_balances
    ( fp_reval_params    in out NOCOPY IGI_IAC_TYPES.iac_reval_params
    , fp_second_set      in boolean default false
     )
return boolean;

function create_reval_rates
    ( fp_reval_params    in out NOCOPY IGI_IAC_TYPES.iac_reval_params
    , fp_second_set      in boolean default false  )
return boolean;

function update_reval_rates ( fp_adjustment_id in number )
return boolean;

function crud_iac_tables
     ( fp_reval_params   in out NOCOPY IGI_IAC_TYPES.iac_reval_params
      , fp_second_set    in boolean default false )
return boolean ;

function reval_status_to_previewed
     ( fp_reval_id       in out NOCOPY IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE  )
return boolean ;

function reval_status_to_failed_pre
     ( fp_reval_id       in out NOCOPY IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE )
return boolean ;

function reval_status_to_completed
     ( fp_reval_id       in out NOCOPY IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE,
       p_event_id      in number)
return boolean ;

function reval_status_to_failed_run
     ( fp_reval_id       in out NOCOPY IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE )
return boolean ;

function adjustment_status_to_run
     ( fp_reval_id       in  IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE
     , fp_asset_id       in  IGI_IAC_TRANSACTION_HEADERS.ASSET_ID%TYPE
     )
return boolean ;

function update_balances
     ( fp_reval_id       in  IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE
     , fp_asset_id       in  IGI_IAC_TRANSACTION_HEADERS.ASSET_ID%TYPE
     , fp_period_counter in IGI_IAC_TRANSACTION_HEADERS.PERIOD_COUNTER%TYPE
     , fp_book_type_code in IGI_IAC_TRANSACTION_HEADERS.BOOK_TYPE_CODE%TYPE
     )
return boolean ;

function allow_transfer_to_gl
     ( fp_reval_id       in  IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE
     , fp_book_type_code in  IGI_IAC_REVALUATIONS.BOOK_TYPE_CODE%TYPE
     , fp_asset_id       in  IGI_IAC_TRANSACTION_HEADERS.ASSET_ID%TYPE
     )
return boolean
;

function stamp_sla_event
     ( fp_reval_id       in  IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE
     , fp_book_type_code in  IGI_IAC_REVALUATIONS.BOOK_TYPE_CODE%TYPE
     , fp_event_id       in  IGI_IAC_REVALUATIONS.EVENT_ID%TYPE
     )
return boolean;

END;

 

/
