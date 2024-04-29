--------------------------------------------------------
--  DDL for Package FA_CDE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CDE_PKG" AUTHID CURRENT_USER as
/* $Header: FACDES.pls 120.15.12010000.3 2009/07/19 12:27:46 glchen ship $ */

last_book    varchar2(16);
last_divide_evenly_flag boolean;
last_pro_cal varchar2(16);
p_pers_per_yr number;

/*
 --------------------------------------------------------------------------
 *
 * Name
 *              faxgpr
 *
 * Description
 *
 * Parameters
 *              X_dpr_ptr - Depreciation structure
 *              X_period - Structure containing period information
 *              X_projecting_flag - Flag indicating depreciation projection
 *              X_prodn - production (OUT)
 *
 * Modifies
 *              X_prodn
 *              fa_periodic_production.used_flag
 *
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION faxgpr (X_dpr_ptr fa_std_types.dpr_struct,
        X_period fa_std_types.fa_cp_struct,
        X_projecting_flag BOOLEAN, X_prodn in out nocopy NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
        return boolean;


/*
 --------------------------------------------------------------------------
 *
 * Name
 *              faxgtr
 *
 * Description
 *              Get table-based depreciation rate
 *
 * Parameters
 *              X_method_id - Depreciation method id
 *              X_year_of_life - Year
 *              X_prorate_period - Prorate period
 *              X_rate out - Depreciation rate (OUT)
 *
 * Modifies
 *              X_rate
 *
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION faxgtr (X_method_id number, X_year_of_life number,
        X_prorate_period number, X_rate out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return boolean;



/*
 --------------------------------------------------------------------------
 *
 * Name
 *              faxcfyf
 *
 * Description
 *              Returns the fraction of depreciation to be taken during
 *              the first fiscal year of an asset's life and the year
 *              retired for use under Straight-Line and Flat-Rate methods
 *
 * Parameters
 *              X_dpr -                 Depreciation structure (IN OUT)
 *              X_d_pers_per_yr - # of periods/year in deprn calendar
 *              X_rate_source_rule - Rate source rule
 *              X_y_begin -     Year to begin calculation
 *              X_y_dead -      Year in which the asset will be fully reserved
 *              X_y_ret -       Year in which the asset will be retired
 *              X_dp_begin -    Depreciation start period
 *              X_dpp_begin -   Depreciation start prorate period
 *              X_dp_d_ptr -    Deprn Period in which the asset will be
 *                              fully reserved (IN OUT)
 *              X_dp_r_ptr -    Deprn Period in which the asset will be
 *                              fully retired
 *              X_dpp_r_ptr -   Deprn prorate period in which the asset will be
 *                              fully retired
 *              X_pp_begin -    Prorate period to begin calculation
 *              X_pp_dead -     Prorate period in which asset will be fully
 *                              reserved
 *              X_pp_ret -      Prorate period in which asset will be fully
 *                              retired
 *              X_by_factor -   Factor used to calc first year deprn without
 *                              considering deprn ceilings (IN OUT)
 *              X_bp_frac -     fraction of annual deprn to be allocated to
 *                              first period of life (IN OUT)
 *              X_dp_frac -     fraction of annual deprn to be allocated to
 *                              last period of life (IN OUT)
 *              X_rp_frac -     fraction of annual deprn to be allocated to
 *                              retirement period (IN OUT)
 *              X_by_frac -     fraction of annual deprn to be allocated to
 *                              first year (IN OUT)
 *              X_dy_frac -     fraction of annual deprn to be allocated to
 *                              last year of life (IN OUT)
 *              X_ry_frac -     fraction of annual deprn to be allocated to
 *                              retirement year (IN OUT)
 *
 * Modifies
 *              X_dpr
 *              X_dp_d_ptr
 *              X_by_factor
 *              X_bp_frac
 *              X_dp_frac
 *              X_rp_frac
 *              X_by_frac
 *              X_dy_frac
 *              X_ry_frac
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
--Bug8620551
--Added additional parameter x_prd_flag to check for retirement in period of addition
FUNCTION faxcfyf (X_dpr in out nocopy fa_std_types.dpr_struct, X_d_pers_per_yr number,
        X_rate_source_rule varchar2, X_y_begin number,
        X_y_dead number, X_y_ret number, X_dp_begin number,
        X_dpp_begin number, X_dp_d_ptr in out nocopy number,
        X_dp_r_ptr number, X_dpp_r_ptr number, X_pp_begin number,
        X_pp_dead number, X_pp_ret number, X_by_factor in out nocopy number,
        X_bp_frac in out nocopy number, X_dp_frac in out number,
        X_rp_frac in out nocopy number, X_by_frac in out number,
        X_dy_frac in out nocopy number, X_ry_frac in out number,
        x_prd_flag varchar2,
        p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return boolean;

/*
 --------------------------------------------------------------------------
 *
 * Name
 *              faxcde
 *
 * Description
 *              Calculate Depreciation Expense
 *
 * Parameters
 *              dpr_in - Depreciation "in" structure
 *              dpr_arr - (IN OUT)
 *              dpr_out - Depreciation "out" structure (OUT)
 *              fmode
 *
 * Modifies
 *              dpr_out
 *              dpr_arr
 *
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 *              Variable names have been changed from the C version
 *              See table in body code that maps new names to old
 *              names.
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION faxcde ( dpr_in  in out nocopy fa_std_types.dpr_struct
                , dpr_arr in out nocopy fa_std_types.dpr_arr_type
                , dpr_out in out nocopy fa_std_types.dpr_out_struct
                , fmode                 number
                , p_ind                 binary_integer default 0, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
        return boolean;

/*
 --------------------------------------------------------------------------
 *
 * Name
 *              faprds
 *
 * Description
 *              Print depreciation IN structure
 *
 * Parameters
 *              X_dpr - Depreciation "in" structure
 *
 * Modifies
 *
 * Returns
 *              True on successful completion. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION faprds (X_dpr fa_std_types.dpr_struct, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return boolean;

/*
 --------------------------------------------------------------------------
 *
 * Name
 *              faprdos
 *
 * Description
 *              Print depreciation OUT structure
 *
 * Parameters
 *              X_dpr - Depreciation "out" structure
 *
 * Modifies
 *
 * Returns
 *              True on successful completion. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION faprdos (X_dpr fa_std_types.dpr_out_struct, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return boolean;

procedure faxgfr (X_Book_Type_Code         IN            VARCHAR2,
                  X_Asset_Id               IN            NUMBER,
                  X_Short_Fiscal_Year_Flag IN            VARCHAR2,
                  X_Conversion_Date        IN            DATE := NULL,
                  X_Prorate_Date           IN            DATE := NULL,
                  X_Orig_Deprn_Start_Date  IN            DATE := NULL,
                  C_Prorate_Date           IN            VARCHAR2 := NULL,
                  C_Conversion_Date        IN            VARCHAR2 := NULL,
                  C_Orig_Deprn_Start_Date  IN            VARCHAR2 := NULL,
                  X_Method_Code            IN            VARCHAR2,
                  X_Life_In_Months         IN            INTEGER,
                  X_Fiscal_Year            IN            NUMBER,
                  X_Current_Period         IN            NUMBER,

                  -- Bug:5930979:Japan Tax Reform Project
                  X_calling_interface      IN            VARCHAR2 DEFAULT NULL,
                  X_new_cost               IN            NUMBER DEFAULT NULL,
                  X_adjusted_cost          IN            NUMBER DEFAULT NULL,

                  X_Rate                      OUT NOCOPY NUMBER,
                  X_Method_Type               OUT NOCOPY NUMBER,
                  X_Success                   OUT NOCOPY INTEGER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

FUNCTION faxgrl(
                X_Asset_Id                      IN      NUMBER,
                X_Book_Type_Code                IN      VARCHAR2,
                X_Short_Fiscal_Year_Flag        IN      VARCHAR2,
                X_Prorate_Date                  IN      DATE,
                X_Conversion_Date               IN      DATE,
                X_Orig_Deprn_Start_Date         IN      DATE,
                X_Fiscal_Year                   IN      NUMBER,
                X_Life_In_Months                IN      NUMBER,
                X_Method_Code                   IN      VARCHAR2,
                X_Current_Period                IN      NUMBER,
                X_rem_life1                     OUT     NOCOPY NUMBER,
                X_rem_life2                     OUT     NOCOPY NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return boolean;

/*
 --------------------------------------------------------------------------
 *
 * Name
 *              fadgpoar()
 *
 * Description
 *              Get the Profile Option of Annual Rounding
 * Parameters
 *
 * Modifies
 *
 * Returns
 *              returns integer. (1-always round   0-round with restrictions)
 *
 * Notes
 *
 * History
 *              Mar 1, 2001  astakaha created
 *--------------------------------------------------------------------------
*/
FUNCTION fadgpoar
        return integer;

/*
 --------------------------------------------------------------------------
 *
 * Name
 *              faodda()
 *
 * Description
 *              Override the Default Depreciation Amounts
 * Parameters
 *
 * Modifies
 *
 * Returns
 *              True on successful completion. Otherwise False.
 *
 * Notes
 *              p_recoverable_cost and p_salvage_value are used
 *              only when used_by_adjustment is true.
 *
 * History
 *              SEP 1, 2001  astakaha created
 *              OCT 2, 2002  ynatsui  added parameters
 *              DEC 5, 2002  ynatsui  added ytd parameters
 *              DEC 19, 2002 ynatsui  added p_update_override_status
 *--------------------------------------------------------------------------
*/
FUNCTION faodda(Book IN VARCHAR2,
                Used_By_Adjustment IN BOOLEAN,
                Asset_ID IN NUMBER,
                Bonus_Rule IN VARCHAR2,
                Fyctr IN NUMBER,
                Perd_Ctr IN NUMBER,
                Prod_Rate_Src_Flag IN BOOLEAN,
                Deprn_Projecting_Flag IN BOOLEAN,
                p_ytd_deprn         IN NUMBER,
                p_bonus_ytd_deprn   IN NUMBER,
                Override_Depr_Amt OUT NOCOPY NUMBER,
                Override_Bonus_Amt OUT NOCOPY NUMBER,
                Deprn_Override_Flag OUT NOCOPY VARCHAR2,
                Return_Code OUT NOCOPY NUMBER,
                p_mrc_sob_type_code IN VARCHAR2 DEFAULT NULL,
                p_set_of_books_id IN NUMBER,
                p_recoverable_cost IN NUMBER DEFAULT NULL,
                p_salvage_value          IN NUMBER DEFAULT NULL,
                p_update_override_status IN BOOLEAN DEFAULT TRUE,
                p_over_depreciate_option IN NUMBER DEFAULT NULL, --Bug 8487934
                p_asset_type             IN VARCHAR2 DEFAULT NULL, --Bug 8487934
                p_deprn_rsv          IN NUMBER DEFAULT NULL, --Bug 8487934
                p_cur_adj_cost       IN NUMBER DEFAULT NULL, --Bug 8487934
                p_override_period_counter IN NUMBER DEFAULT NULL -- Bug 8211842
                , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

------------------------------------------------------------------
-- Function:
--           FATRKM
--
-- Description:
--           Main entry to call Tracking feature
--           This function will call TRACK_MEMBER function
--
------------------------------------------------------------------
FUNCTION fatrkm(p_dpr                     in fa_std_types.dpr_struct,
                p_perd_deprn_exp          in number,
                p_perd_bonus_deprn_amount in number,
                p_perd_ctr                in number,
                p_fyctr                   in number,
                p_loop_end_year           in number default null,
                p_loop_end_period         in number default null,
                p_exclude_salvage_value_flag in boolean,
                p_deprn_basis_rule        in varchar2,
                p_deprn_override_flag     in out nocopy varchar2,
                p_subtract_ytd_flag       in varchar2,
                p_life_complete_flag      in boolean,
                p_fully_reserved_flag     in boolean,
                p_year_deprn_exp          in number,
                p_recoverable_cost        in number,
                p_adj_rec_cost            in number,
                p_current_deprn_reserve   in number,
                p_nbv_threshold           in number,
                p_nbv_thresh_amount       in number,
                p_rec_cost_abs_value      in number,
                p_mode                    in varchar2 default NULL,
                x_new_perd_exp            out nocopy number,
                x_new_perd_bonus_deprn_amount out nocopy number,
                x_life_complete_flag      out nocopy boolean,
                x_fully_reserved_flag     out nocopy boolean
                , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

procedure faxgpolr (X_Book_Type_Code         IN            VARCHAR2,
                    X_Asset_Id               IN            NUMBER,
                    X_Polish_Rule            IN            NUMBER,
                    X_Deprn_Factor           IN            NUMBER,
                    X_Alternate_Deprn_Factor IN            NUMBER,
                    X_Polish_Adj_Calc_Basis_Flag
                                             IN            VARCHAR2,
                    X_Recoverable_Cost       IN            NUMBER,
                    X_Fiscal_Year            IN            NUMBER,
                    X_Current_Period         IN            NUMBER,
                    X_Periods_Per_Year       IN            NUMBER,
                    X_Year_Retired           IN            BOOLEAN,
                    X_Projecting_Flag        IN            BOOLEAN,
                    X_MRC_Sob_Type_Code      IN            VARCHAR2,
                    X_set_of_books_id        IN            NUMBER,
                    X_Rate                   IN OUT NOCOPY NUMBER,
                    X_Depreciate_Flag        IN OUT NOCOPY BOOLEAN,
                    X_Current_Adjusted_Cost  IN OUT NOCOPY NUMBER,
                    X_Adjusted_Recoverable_Cost
                                             IN OUT NOCOPY NUMBER,
                    X_Success                   OUT NOCOPY INTEGER,
                    X_Calling_Fn             IN            VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_CDE_PKG;

/
