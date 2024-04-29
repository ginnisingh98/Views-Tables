--------------------------------------------------------
--  DDL for Package IGI_IAC_REVAL_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVAL_UTILITIES" AUTHID CURRENT_USER AS
-- $Header: igiiarus.pls 120.9.12000000.1 2007/08/01 16:18:21 npandya ship $
l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

function latest_adjustment       ( fp_asset_id             IN number
                                 , fp_book_type_code       in varchar2
                                 )
return number;

function Populate_Depreciation   ( fp_asset_id             IN number
                                      , fp_book_type_code       IN varchar2
                                 , fp_period_counter       IN number
                                 , fp_hist_info            IN OUT NOCOPY IGI_IAC_TYPES.fa_hist_asset_info
                                 )
return  boolean;


function split_rates             ( fp_asset_id            IN number
                                 , fp_book_type_code      IN varchar2
                                 , fp_revaluation_id      IN number
                                 , fp_period_counter      IN number
                                 , fp_current_factor      IN number
                                 , fp_reval_type          IN varchar2
                                 , fp_first_time_flag     IN boolean default false
                                 , fp_mixed_scenario             OUT NOCOPY BOOLEAN
                                 , fp_reval_prev_rate_info       IN  IGI_IAC_TYPES.iac_reval_rate_params
                                 , fp_reval_curr_rate_info_first OUT NOCOPY IGI_IAC_TYPES.iac_reval_rate_params
                                 , fp_reval_curr_rate_info_next  OUT NOCOPY IGI_IAC_TYPES.iac_reval_rate_params
                                 )
return   boolean
;
procedure log ( p_calling_code in varchar2 , p_mesg in varchar2 );

function  debug  return boolean;

function  sqlplus_mode         return boolean;
function  logfile_mode         return boolean;
function  set_logfile_mode_on  return boolean;
function  set_logfile_mode_off return boolean;

function prorate_dists ( fp_asset_id                in number
                       , fp_book_type_code          in varchar2
                       , fp_current_period_counter  in number
                       , fp_prorate_dists_tab      out NOCOPY igi_iac_types.prorate_dists_tab
                       , fp_prorate_dists_idx      out NOCOPY binary_integer
                       )
return boolean ;

FUNCTION prorate_active_dists_YTD ( fp_asset_id                in number
                       , fp_book_type_code          in varchar2
                       , fp_current_period_counter  in number
                       , fp_prorate_dists_tab      out NOCOPY igi_iac_types.prorate_dists_tab
                       , fp_prorate_dists_idx      out NOCOPY binary_integer
                       )
RETURN BOOLEAN ;

FUNCTION prorate_all_dists_YTD ( fp_asset_id                in number
                       , fp_book_type_code          in varchar2
                       , fp_current_period_counter  in number
                       , fp_prorate_dists_tab      out NOCOPY igi_iac_types.prorate_dists_tab
                       , fp_prorate_dists_idx      out NOCOPY binary_integer
                       )
RETURN BOOLEAN ;

procedure get_coa_info   (x_chart_of_accounts_id    IN     NUMBER,
                          x_segment_delimiter       IN OUT NOCOPY VARCHAR2,
                          x_enabled_segment_count   IN OUT NOCOPY NUMBER,
                          x_segment_order_by        IN OUT NOCOPY VARCHAR2,
                          x_accseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_accseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_accseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_balseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_balseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_balseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_ieaseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_left_prompt      IN OUT NOCOPY VARCHAR2);

FUNCTION Synchronize_Accounts(
        p_book_type_code    IN VARCHAR2,
        p_period_counter    IN NUMBER,
        p_calling_function  IN VARCHAR2
        )
return BOOLEAN;

END;

 

/
