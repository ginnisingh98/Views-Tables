--------------------------------------------------------
--  DDL for Package FA_TRACK_MEMBER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TRACK_MEMBER_PVT" AUTHID CURRENT_USER as
/* $Header: FAVTRACKS.pls 120.11.12010000.4 2009/10/06 13:22:18 bmaddine ship $ */

-- Declare for Tracking related records

TYPE track_member_struct is RECORD (
		  group_asset_id		number(15) := NULL,
		  member_asset_id		number(15) := NULL,
		  period_counter		number(15) := NULL,
		  fiscal_year			number(15) := NULL,
                  set_of_books_id               number := NULL,
		  allocation_basis		number := NULL,
		  total_allocation_basis 	number := NULL,
		  allocated_deprn_amount	number := NULL,
		  allocated_bonus_amount	number := NULL,
	          system_deprn_amount		number := NULL,
		  system_bonus_amount	        number := NULL,
		  fully_reserved_flag		varchar2(01) := NULL,
		  fully_retired_flag		varchar2(01) := NULL,
		  override_flag			varchar2(01) := NULL,
		  cost				number := NULL,
		  adjusted_cost			number := NULL,
		  eofy_adj_cost			number := NULL,
		  recoverable_cost		number := NULL,
		  salvage_value			number := NULL,
		  adjusted_recoverable_cost	number := NULL,
		  eofy_reserve		        number := NULL,
                  deprn_reserve			number := NULL,
		  ytd_deprn			number := NULL,
		  bonus_deprn_reserve		number := NULL,
		  bonus_ytd_deprn		number := NULL,
                  eofy_recoverable_cost         number := NULL,
                  eop_recoverable_cost          number := NULL,
                  eofy_salvage_value            number := NULL,
                  eop_salvage_value             number := NULL
,                 reserve_adjustment_amount     number,
                 unplanned_deprn_amount          number := NULL
        );

TYPE track_member_eofy is RECORD (
		  group_asset_id		number(15) := NULL,
		  member_asset_id		number(15) := NULL,
                  fiscal_year                   number := NULL,
                  cost                          number := NULL,
                  salvage_value                 number := NULL,
                  recoverable_cost              number := NULL,
                  adjusted_cost                 number := NULL,
		  eofy_reserve		        number := NULL,
                  set_of_books_id               number := NULL
        );

TYPE track_member_type IS TABLE OF track_member_struct INDEX BY BINARY_INTEGER;
TYPE track_member_eofy_type IS TABLE OF track_member_eofy INDEX By BINARY_INTEGER;

null_track_member_struct       track_member_struct;
p_track_member_table           track_member_type;
p_track_member_eofy_table      track_member_eofy_type;
p_track_adj_mode               boolean := FALSE;

p_track_member_table_for_raf        track_member_type;
p_tracK_member_table_for_deprn      track_member_type;

/* Added for bug 7231274 */
type track_index_struct is TABLE of NUMBER index by VARCHAR2(152);
p_track_mem_index_table track_index_struct;

--* Update Depreciable Basis controller
l_process_deprn_for_member                      varchar2(3) := 'YES';
l_processing_member_table                       varchar2(3) := 'NO';

--------------------------------------------------------------------------
--
--   Function: track_assets
--
--   Description:
--
-- 	Main logic to track individual asset level amounts.
--
--   Returns:
--
--      0 - No error / 1 - Error
--
--------------------------------------------------------------------------
FUNCTION track_assets(P_book_type_code             in varchar2,
                      P_group_asset_id	           in number,
                      P_period_counter             in number,
                      P_fiscal_year                in number,
                      P_loop_end_year              in number default null,
                      P_loop_end_period            in number default null,
                      P_group_deprn_basis          in varchar2,
                      P_group_exclude_salvage      in varchar2 default NULL,
                      P_group_bonus_rule           in varchar2 default NULL,
                      P_group_deprn_amount         in number default 0,
                      P_group_bonus_amount         in number default 0,
                      P_tracking_method            in varchar2 default null,
                      P_allocate_to_fully_ret_flag in varchar2 default null,
                      P_allocate_to_fully_rsv_flag in varchar2 default null,
                      P_excess_allocation_option   in varchar2 default 'REDUCE',
                      P_depreciation_option        in varchar2 default null,
                      P_member_rollup_flag         in varchar2 default null,
                      P_subtraction_flag           in varchar2 default NULL,
                      P_group_level_override       in out nocopy varchar2,
                      P_update_override_status     in boolean default true,
                      P_period_of_addition         in varchar2 default NULL,
                      P_transaction_date_entered   in date default null,
                      P_mode                       in varchar2 default NULL,
                      p_mrc_sob_type_code          in varchar2 default 'N',
                      p_set_of_books_id            in number,
                      X_new_deprn_amount           out nocopy number,
                      X_new_bonus_amount           out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
  return number;

--------------------------------------------------------------------------
--
--  Function: allocate
--
--  Description:
--
--     Calculate the allocated amount based on the parameters
--
--  Returns:
--
--     True - No error / False - error
--
--------------------------------------------------------------------------

FUNCTION allocate(P_book_type_code             in varchar2,
                  P_group_asset_id             in number,
                  P_period_counter             in number,
                  P_fiscal_year                in number,
                  P_group_deprn_basis          in varchar2,
                  P_group_exclude_salvage      in varchar2 default NULL,
                  P_group_bonus_rule           in varchar2 default NULL,
                  P_group_deprn_amount         in number default 0,
                  P_group_bonus_amount         in number default 0,
                  P_allocate_to_fully_ret_flag in varchar2 default NULL,
                  P_allocate_to_fully_rsv_flag in varchar2 default NULL,
                  P_excess_allocation_option   in varchar2 default 'REDUCE',
                  P_subtraction_flag           in varchar2 default NULL,
                  P_group_level_override       in out nocopy varchar2,
                  P_update_override_status     in boolean default true,
                  P_mrc_sob_type_code          in varchar2 default 'N',
                  P_set_of_books_id            in number,
                  P_mode                       in varchar2 default NULL,
                  X_new_deprn_amount           out nocopy number,
                  X_new_bonus_amount           out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

  return boolean;

---------------------------------------------------------------------------
--
--  Function:  check_group_amounts
--
--  Description:
--
--		This function is called when system needs to update
--		Group Level Amounts as a result of tracking logic.
--		If system cannot update the group level amounts
-- 		due to some reason, this function will return false.
--
--
--  Returns:
--
--     0 - No error / 1 - error
--
---------------------------------------------------------------------------

FUNCTION check_group_amounts(P_book_type_code        in varchar2,
                           P_group_asset_id        in number,
                           P_period_counter        in number,
                           P_perd_deprn_exp        in number,
                           P_year_deprn_exp        in number,
                           P_recoverable_cost      in number,
                           P_adj_rec_cost          in number,
                           P_current_deprn_reserve in number,
                           P_nbv_threshold         in number,
                           P_nbv_thresh_amount     in number,
                           P_rec_cost_abs_value    in number,
                           X_life_complete_flag    out nocopy varchar2,
                           X_fully_reserved_flag   out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
  return number;

---------------------------------------------------------------------------
--
--  Function:  allocation_main
--
--  Description:
--
--		This function is called to allocate group level amount
--		to member assets. This is the main logic to allocate amounts
--		to members.
--
--
--  Returns:
--
--              True on successful retrieval. Otherwise False.
--
----------------------------------------------------------------------------

FUNCTION allocation_main(P_book_type_code            in varchar2,
                         P_group_asset_id            in number,
                         P_member_asset_id           in number,
                         P_period_counter            in number,
                         P_fiscal_year               in number,
                         P_group_bonus_rule          in varchar2 default null,
                         P_group_deprn_amount        in number,
                         P_group_bonus_amount        in number default 0,
                         P_allocation_basis          in number,
                         P_total_allocation_basis    in number,
                         P_ytd_deprn                 in number,
                         P_bonus_ytd_deprn           in number default 0,
                         P_track_member_in           in track_member_struct default null_track_member_struct,
                         P_check_reserve_flag        in Varchar2 default null,
                         P_subtraction_flag          in varchar2 default null,
                         P_group_level_override      in out nocopy varchar2,
                         P_update_override_status    in boolean default true,
                         P_member_override_flag      in varchar2 default null,
                         PX_difference_deprn_amount  in out nocopy number,
                         PX_difference_bonus_amount  in out nocopy number,
                         X_system_deprn_amount       out nocopy number,
                         X_system_bonus_amount       out nocopy number,
                         X_track_member_out          out nocopy track_member_struct,
                         P_mrc_sob_type_code         in varchar2 default 'N',
                         P_set_of_books_id           in number,
                         P_mode                      in Varchar2,
                         P_rec_cost_for_odda         in number default null,
                         P_sv_for_odda               in number default null, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean;

----------------------------------------------------------------------------
--
--  Function:   update_depreciable_basis
--
--  Description:
--
--		This function is called to update Depreciable Basis in some cases.
--		The case when this function is called is that the group level depreciable
--		basis rule has group level check logic, such as 50% rules for CCA or India.
--		In these logic, system needs to check group level net amount for the specified
--		period to decide if 50% reduction is applied or not.
--		This cannot be checked at member level. So after group level depreciable basis
--		updated is done, Deprn Basis Rule function will call this function to update
--		member level depreciable basis.
--		to members.
--
--
----------------------------------------------------------------------------

FUNCTION update_deprn_basis(p_group_rule_in          in fa_std_types.fa_deprn_rule_in_struct,
                            p_apply_reduction_flag   in varchar2 default NULL,
                            p_mode                   in varchar2 default NULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean;

----------------------------------------------------------------------------
--
--  Function:   ins_dd_adj
--
--  Description:
--
--              This function is called to insert allocated amount
--              into FA_ADJ or FA_DEPRN_DETAIL/SUMMARY in case
--              that Unplanned Depreciation is made.
--
--
--  Returns
--              True on successful retrieval. Otherwise False.
--
----------------------------------------------------------------------------

FUNCTION ins_dd_adj(P_book_type_code         in varchar2,
                    P_group_asset_id         in number,
                    P_period_counter         in number,
                    P_fiscal_year            in number,
                    P_period_of_addition     in varchar2 default NULL,
                    P_transaction_date_entered in date default null,
                    P_mrc_sob_type_code      in varchar2 default 'N',
                    P_set_of_books_id        in number,
                    P_mode                   in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean;

----------------------------------------------------------------------------
--
--  Function:   populate previous rows
--
--  Description:
--
--              This function is called to prepare PL/SQL table to process
--              allocation under ADJUSTMENT mode
--              If PL/SQL table doesn't exist, this function will extend the
--              table with necessary values for member assets to be processed
--              at one period before the starting period made subsequently.
--
--
--  Returns
--              True on successful retrieval. Otherwise False.
--
----------------------------------------------------------------------------

FUNCTION populate_previous_rows(p_book_type_code     in varchar2,
                                p_group_asset_id     in number,
                                p_period_counter     in number,
                                p_fiscal_year        in number,
                                p_transaction_header_id in number default null,
                                p_loop_end_year      in number default null,
                                p_loop_end_period    in number default null,
                                p_allocate_to_fully_ret_flag in varchar2,
                                p_allocate_to_fully_rsv_flag in varchar2,
                                p_mrc_sob_type_code  in varchar2, -- default 'N'
                                p_set_of_books_id    in number,
                                p_calling_fn         in varchar2 default NULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean;

--+=====================================================================
-- Function: get_member_at_start
--
--  This function will be called from adjustment engine
--  to poulate the member assets at the time of running faxcde
--  Using transaction_date_entered passed from engine,
--  member assets are defined.
--  And populate the necessary info into FA_TRACK_MEMBER table.
--+=====================================================================

FUNCTION get_member_at_start(p_period_rec                 in FA_API_TYPES.period_rec_type,
                             p_trans_rec                  in FA_API_TYPES.trans_rec_type,
                             p_asset_hdr_rec              in FA_API_TYPES.asset_hdr_rec_type,
                             p_asset_fin_rec              in FA_API_TYPES.asset_fin_rec_type,
                             p_dpr_in                     in FA_STD_TYPES.dpr_struct,
                             p_mrc_sob_type_code          in varchar2 default 'N', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean;

--+=====================================================================
-- Function: update_member_books
--
--  This function will be called from adjustment engine
--  to update FA_BOOKS for each member assets
--  Using stored adjusted_cost in FA_TRACK_MEMBERS,
--  FA_BOOKS will be updated.
--
--+=====================================================================

FUNCTION update_member_books(p_trans_rec          in FA_API_TYPES.trans_rec_type,
                             p_asset_hdr_rec      in FA_API_TYPES.asset_hdr_rec_type,
                             p_dpr_in             in FA_STD_TYPES.dpr_struct,
                             p_mrc_sob_type_code  in varchar2 default 'N', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean;

--+=====================================================================
-- Function: member_eofy_rsv
--
--  This function will be called to keep eofy_reserve for each member asset
--  during the loop of recalculation
--
--+=====================================================================

FUNCTION member_eofy_rsv(p_asset_hdr_rec      in FA_API_TYPES.asset_hdr_rec_type,
                         p_dpr_in             in FA_STD_TYPES.dpr_struct,
                         p_mrc_sob_type_code  in varchar2 default 'N', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean;

--+=====================================================================
-- Function: populate_member_assets_table
--
--  This function will be called to extend member assets PL/SQL table
--  to process faxcde correctly.
--  When this function is called, allocation calculation will be
--  made from group DPIS to one period before when recalculation will start
--
--+=====================================================================

FUNCTION populate_member_assets_table(p_asset_hdr_rec           in FA_API_TYPES.asset_hdr_rec_type,
                                      p_asset_fin_rec_new       in FA_API_TYPES.asset_fin_rec_type,
                                      p_populate_for_recalc_period in varchar2 default 'N',
                                      p_amort_start_date        in date,
                                      p_recalc_start_fy         in number,
                                      p_recalc_start_period_num in number,
                                      p_no_allocation_for_last  in varchar2 default 'Y',
                                      p_mrc_sob_type_code       in varchar2 default 'N', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean;

--+=====================================================================
-- Function: populate_member_reserve
--
--  This function will be called to query tracked reserve amount
--  for group reclassification.
--  This function is used to skip recalculation from DPIS to reclassification
--  date populating member level reserve amount tracked.
--
--+=====================================================================

FUNCTION populate_member_reserve(p_trans_rec               in FA_API_TYPES.trans_rec_type,
                                 p_asset_hdr_rec           in FA_API_TYPES.asset_hdr_rec_type,
                                 p_asset_fin_rec_new       in FA_API_TYPES.asset_fin_rec_type,
                                 p_mrc_sob_type_code       in varchar2 default 'N',
                                 x_deprn_reserve           out nocopy number,
                                 x_eofy_reserve            out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean;

--+=====================================================================
-- Function: check_reduction_application
--
--  This function will be called to check if 50% rule is applied at group
--  level or not before calling deprn basis rule function for each member
--
--+=====================================================================

FUNCTION check_reduction_application(p_rule_name           in varchar2,
                                     p_group_asset_id      in number,
                                     p_book_type_code      in varchar2,
                                     p_period_counter      in number,
                                     p_group_deprn_basis   in varchar2,
                                     p_reduction_rate      in number,
                                     p_group_eofy_rec_cost in number,
                                     p_group_eofy_salvage_value in number,
                                     p_group_eofy_reserve  in number,
                                     p_mrc_sob_type_code   in varchar2 default 'N',
                                     p_set_of_books_id     in number,
                                     x_apply_reduction_flag out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean;

--+=====================================================================
-- Function: display_debug_message
--
--  This function will be called to display debug message
--
--+=====================================================================

FUNCTION display_debug_message(fa_rule_in                  in fa_std_types.fa_deprn_rule_in_struct,
                               p_calling_fn                in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

  return boolean;

--+=====================================================================
-- Function: display_debug_message2
--
--  This function will be called to display debug message
--  This is for p_track_member_table
--+=====================================================================

FUNCTION display_debug_message2(i                  in number,
                                p_calling_fn       in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

  return boolean;

--+=====================================================================
-- Function: copy_member_table
--
--  This function will be called to backup the memory table
--  restore backuped memory table
--
--+=====================================================================

FUNCTION copy_member_table(p_backup_restore        in varchar2,
                           p_current_fiscal_year   in number default NULL,
                           p_current_period_num    in number default NULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

  return boolean;

--+=====================================================================
-- Function: create_update_books_summary
--
--  This function will be called to insert row into fa_books_summary if not exists
--  update fa_books_summary row if exists
--
--+=====================================================================

FUNCTION create_update_bs_table(p_trans_rec         in FA_API_TYPES.trans_rec_type,
                                p_book_type_code    in varchar2,
                                p_group_asset_id    in varchar2,
                                p_mrc_sob_type_code in varchar2 default 'N',
                                p_sob_id            in number, --Bug 8941132
                                p_calling_fn        in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

  return boolean;

--+=====================================================================
-- Function: override_member_amount
--
--  This function will be called to override deprn amount of member assets
--  This is called only when populate_member_assets_table calls
--
--+=====================================================================

FUNCTION override_member_amount(p_book_type_code        in varchar2,
                                p_member_asset_id       in number,
                                p_fiscal_year           in number,
                                p_period_num            in number,
                                p_ytd_deprn             in number,
                                p_bonus_ytd_deprn       in number,
                                x_override_deprn_amount out nocopy number,
                                x_override_bonus_amount out nocopy number,
                                x_deprn_override_flag   out nocopy varchar2,
                                p_calling_fn            in varchar2,
                                p_mrc_sob_type_code     in varchar2,
                                p_recoverable_cost      in number default null,
                                p_salvage_value         in number default null, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

  return boolean;


END FA_TRACK_MEMBER_PVT;

/
