--------------------------------------------------------
--  DDL for Package Body FA_WHATIF_DEPRN2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_WHATIF_DEPRN2_PKG" as
/* $Header: FAWDPR2B.pls 120.16.12010000.2 2009/07/19 14:18:22 glchen ship $ */


function whatif_deprn (
	X_assets	in out nocopy fa_std_types.number_tbl_type,
	X_num_assets	in number,
	X_method	in varchar2,
	X_life		in number,
	X_adjusted_rate in number,
	X_prorate_conv	in varchar2,
	X_salvage_pct	in number,
	X_exp_amt	in out nocopy varchar2,
	X_book		in varchar2,
	X_start_per	in varchar2,
	X_num_per	in number,
	X_request_id	in number,
	X_user_id	in number,
	X_hypo          in varchar2,
	X_dpis          in date,
	X_cost          in number,
	X_deprn_rsv     in number,
    X_cat_id        in number,
	X_bonus_rule	in varchar2,
	x_return_status out nocopy number,
	X_fullresv_flg in varchar2,			-- ERnos  6612615  what-if  start
	X_extnd_deprn_flg in varchar2,
	X_first_period in varchar2)			--ERnos  6612615  what-if  end
return boolean is


--  Implementation Overview:
--  Performs a loop, for each asset:
--		Run whatif_deprn_asset in NORMAL mode.
--		Run whatif_deprn_asset in adjusted mode.
--		Run whatif_insert_itf


h_key_struct	number;
h_loc_struct	number;
h_cat_struct	number;
h_acct_struct   number;
h_precision     number;
h_login_id	number;
h_sal		number;
h_check		varchar2(3);
h_count		number;
ret		boolean;
h_mesg_name  varchar2(30);
h_mesg_str   varchar2(2000);
h_cat_segs   fa_rx_shared_pkg.Seg_Array;
h_concat_str varchar2(200);
h_currency   varchar2(15);
h_basic_rate    number;
x_errbuf		varchar2(200);
x_retcode		number;

--ERnos  6612615  what-if  start
h_cntr1		 binary_integer	:= 1;
h_cntr3		 binary_integer	:= 1;
TYPE tp_asset IS RECORD ( period		VARCHAR2(30),
						  book 	    	VARCHAR2(30),
						  asset_id		NUMBER,
						  method		VARCHAR2(30),
						  adj_cost		NUMBER,
						  cost			NUMBER,
						  life			NUMBER,
						  rate			NUMBER,
						  deprn_lmt		NUMBER
						 );

   TYPE tp_ast_typ IS TABLE OF tp_asset
      INDEX BY BINARY_INTEGER;
t_ast_typ			tp_ast_typ;
t_extnd_deprn_asset             tp_ast_typ;
-- ERnos  6612615 end
  cursor c_segs is
    select 'GL_CODE_COMBINATIONS' , c.table_id, g.application_column_name,
g.segment_num,	s.concatenated_segment_delimiter
    from fnd_columns c, fnd_id_flex_segments g, fnd_id_flex_structures s
    where g.application_id = 101
	  and g.id_flex_code = 'GL#'
	  and g.id_flex_num = (
		  select accounting_flex_structure
		  from fa_book_controls where book_type_code = X_book)
	  and g.enabled_flag = 'Y'
	  and c.application_id = g.application_id
	  and c.table_id = (select table_id
			    from fnd_tables
			    where table_name = 'GL_CODE_COMBINATIONS'
			    and application_id = 101)
	  and c.column_name = g.application_column_name
	  and s.application_id = g.application_id
       	  and s.id_flex_code = g.id_flex_code
          and s.id_flex_num = g.id_flex_num
    union -- asset key
    select 'FA_ASSET_KEYWORDS', c.table_id,g.application_column_name, g.segment_num, s.concatenated_segment_delimiter
    from fnd_columns c, fnd_id_flex_segments g, fnd_id_flex_structures s
    where g.application_id = 140
	  and g.id_flex_code = 'KEY#'
	  and g.id_flex_num = ( select asset_key_flex_structure
				from fa_system_controls)
	  and g.enabled_flag = 'Y'
	  and c.application_id = 140
	  and c.table_id = (select table_id
			    from fnd_tables
			    where table_name = 'FA_ASSET_KEYWORDS'
			    and application_id = 140)
	  and c.column_name = g.application_column_name
	  and s.application_id = g.application_id
       	  and s.id_flex_code = g.id_flex_code
          and s.id_flex_num = g.id_flex_num
     union -- location
     select 'FA_LOCATIONS', c.table_id, g.application_column_name, g.segment_num, s.concatenated_segment_delimiter
    from fnd_columns c, fnd_id_flex_segments g, fnd_id_flex_structures s
     where g.application_id = 140
	  and g.id_flex_code = 'LOC#'
	  and g.id_flex_num =  ( select location_flex_structure
				 from fa_system_controls)
	  and g.enabled_flag = 'Y'
	  and c.application_id = 140
	  and c.table_id = (select table_id
			    from fnd_tables
			    where table_name = 'FA_LOCATIONS'
			    and application_id = 140)
	  AND c.column_name = g.application_column_name
	  and s.application_id = g.application_id
       	  and s.id_flex_code = g.id_flex_code
          and s.id_flex_num = g.id_flex_num
     union -- category
     select 'FA_CATEGORIES_B', c.table_id, g.application_column_name, g.segment_num, s.concatenated_segment_delimiter
    from fnd_columns c, fnd_id_flex_segments g, fnd_id_flex_structures s
     where g.application_id = 140
	  and g.id_flex_code = 'CAT#'
	  and g.id_flex_num =   (select category_flex_structure
				 from fa_system_controls)
	  and g.enabled_flag = 'Y'
	  and c.application_id = 140
	  and c.table_id = (select table_id
			    from fnd_tables
			    where table_name = 'FA_CATEGORIES_B'
			    and application_id = 140)
	  and c.column_name = g.application_column_name
	  and s.application_id = g.application_id
       	  and s.id_flex_code = g.id_flex_code
          and s.id_flex_num = g.id_flex_num
	ORDER BY 1, 4;

--ERnos  6612615  what-if  start
	cursor c_aset(x_book_type varchar2, x_asset_id NUMBER) is
	  select to_char(fb.date_placed_in_service) dtin_srv,fb.book_type_code,
		  fb.asset_id,fb.deprn_method_code,fb.adjusted_cost,fb.cost,fb.life_in_months,fb.rate_in_use,
		  fb.allowed_deprn_limit_amount
      from fa_books fb
      where deprn_method_code like 'JP%250DB%'
	  	and fb.date_ineffective is null
		and period_counter_fully_reserved is null
	    and fb.book_type_code = x_book_type
	    and fb.asset_id = x_asset_id;

--ERnos  6612615  what-if extnd deprn start
	cursor c_extnd_asset(x_book_type varchar2, x_asset_id NUMBER) is
	  select fb.book_type_code,
		  fb.asset_id
          from fa_books fb
          where fb.date_ineffective is null
          and fb.book_type_code = x_book_type
	  and fb.asset_id = x_asset_id
	  AND   FB.deprn_method_code <> 'JP-STL-EXTND'
          AND   FB.allowed_deprn_limit_amount > 1;
--ERnos  6612615  end
slask1	varchar2(100);
slask2 varchar2(100);

begin

  --fa_rx_conc_mesg_pkg.log('IN HERE IN HERE 1');

  ret := TRUE;

  fa_whatif_deprn_pkg.t_request_id.delete;
  fa_whatif_deprn_pkg.t_book_type_code.delete;
  fa_whatif_deprn_pkg.t_asset_id.delete;
  fa_whatif_deprn_pkg.t_asset_number.delete;
  fa_whatif_deprn_pkg.t_description.delete;
  fa_whatif_deprn_pkg.t_tag_number.delete;
  fa_whatif_deprn_pkg.t_serial_number.delete;
  fa_whatif_deprn_pkg.t_period_name.delete;
  fa_whatif_deprn_pkg.t_fiscal_year.delete;
  fa_whatif_deprn_pkg.t_expense_acct.delete;
  fa_whatif_deprn_pkg.t_location.delete;
  fa_whatif_deprn_pkg.t_units.delete;
  fa_whatif_deprn_pkg.t_employee_name.delete;
  fa_whatif_deprn_pkg.t_employee_number.delete;
  fa_whatif_deprn_pkg.t_asset_key.delete;
  fa_whatif_deprn_pkg.t_current_cost.delete;
  fa_whatif_deprn_pkg.t_current_prorate_conv.delete;
  fa_whatif_deprn_pkg.t_current_method.delete;
  fa_whatif_deprn_pkg.t_current_life.delete;
  fa_whatif_deprn_pkg.t_current_basic_rate.delete;
  fa_whatif_deprn_pkg.t_current_adjusted_rate.delete;
  fa_whatif_deprn_pkg.t_current_salvage_value.delete;
  fa_whatif_deprn_pkg.t_depreciation.delete;
  fa_whatif_deprn_pkg.t_new_depreciation.delete;
  fa_whatif_deprn_pkg.t_created_by.delete;
  fa_whatif_deprn_pkg.t_creation_date.delete;
  fa_whatif_deprn_pkg.t_last_update_date.delete;
  fa_whatif_deprn_pkg.t_last_updated_by.delete;
  fa_whatif_deprn_pkg.t_last_update_login.delete;
  fa_whatif_deprn_pkg.t_date_placed_in_service.delete;
  fa_whatif_deprn_pkg.t_category.delete;
  fa_whatif_deprn_pkg.t_accumulated_deprn.delete;
  fa_whatif_deprn_pkg.t_bonus_depreciation.delete;
  fa_whatif_deprn_pkg.t_new_bonus_depreciation.delete;
  fa_whatif_deprn_pkg.t_current_bonus_rule.delete;
  fa_whatif_deprn_pkg.t_period_num.delete;
  fa_whatif_deprn_pkg.t_currency_code.delete;

  if (X_exp_amt = 'YES') then X_exp_amt := 'AMORTIZED';
  elsif (X_exp_amt = 'NO') then X_exp_amt := 'EXPENSED';
  end if;

  -- MAKE SURE AMORTIZED ADJ ARE ALLOWED FOR THIS BOOK

  if (X_exp_amt = 'AMORTIZED') then

    select amortize_flag into h_check from fa_book_controls
    where book_type_code = X_book;

    if h_check = 'NO' then
	fnd_message.set_name('OFA','FA_BOOK_AMORTIZED_NOT_ALLOW');
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);

	x_return_status := 2;
	return FALSE;
    end if;
  end if;

  --fa_rx_conc_mesg_pkg.log('IN HERE IN HERE 2');

  -- SELECT VALUES THAT WILL REMAIN CONSTANT FOR ALL ASSETS:
  -- FLEX STRUCTURES, PRECISION, LOGIN_ID

  h_mesg_name := 'FA_FA_LOOKUP_IN_SYSTEM_CTLS';

  select location_flex_structure, category_flex_structure,
	asset_key_flex_structure
  into h_loc_struct, h_cat_struct, h_key_struct
  from fa_system_controls;

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select accounting_flex_structure into h_acct_struct
  from fa_book_controls where book_type_code = X_book;

  h_mesg_name := 'FA_DYN_CURRENCY';


  select cur.precision into h_precision
  from fa_book_controls bc, gl_sets_of_books sob, fnd_currencies cur
  where bc.book_type_code = X_book
  --and sob.set_of_books_id = bc.set_of_books_id
  and sob.set_of_books_id = FARX_C_WD.sob_id -- Enhancement bug 3037321
  and sob.currency_code = cur.currency_code;

  if (nvl(X_request_id,0) <> 0) then
    select fcr.last_update_login into h_login_id
    from fnd_concurrent_requests fcr
    where fcr.request_id = X_request_id;
  else
    h_login_id := 0;
  end if;


-- Aggregate selects here:

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  open c_segs;
  loop

    FETCH c_segs into fa_rx_shared_pkg.g_seg_struct.tabname,
			fa_rx_shared_pkg.g_seg_struct.table_id,
			fa_rx_shared_pkg.g_seg_struct.colname,
			fa_rx_shared_pkg.g_seg_struct.segment_num,
			fa_rx_shared_pkg.g_seg_struct.delimiter;

	if (c_segs%NOTFOUND) then
	   exit;
	end if;

	    -- load the table.
        if (fa_rx_shared_pkg.g_seg_count = 0) then  /* initialize the table. */
	       fa_rx_shared_pkg.g_seg_table.delete;
	end if;
	fa_rx_shared_pkg.g_seg_count := fa_rx_shared_pkg.g_seg_count + 1;

	fa_rx_shared_pkg.g_seg_table(fa_rx_shared_pkg.g_seg_count) := fa_rx_shared_pkg.g_seg_struct;


  end loop;
  close c_segs;

-- end aggregate selects.

  --fa_rx_conc_mesg_pkg.log('IN HERE IN HERE 3');

  if (upper(X_hypo) in ('NO', 'N')) then

  h_count := 0;

  loop   -- for each asset

    if h_count >= X_num_assets then exit;   end if;

--ERnos  6612615  what-if  start
  for c_asset in c_aset(X_book,X_assets(h_count))
  loop
	t_ast_typ(h_cntr1).period   := c_asset.dtin_srv;
	t_ast_typ(h_cntr1).book		:= c_asset.book_type_code;
	t_ast_typ(h_cntr1).asset_id := c_asset.asset_id;
	t_ast_typ(h_cntr1).method   := c_asset.deprn_method_code;
	t_ast_typ(h_cntr1).adj_cost := c_asset.adjusted_cost;
	t_ast_typ(h_cntr1).cost     := c_asset.cost;
	t_ast_typ(h_cntr1).life     := c_asset.life_in_months;
	t_ast_typ(h_cntr1).rate     := c_asset.rate_in_use;
	t_ast_typ(h_cntr1).deprn_lmt := c_asset.allowed_deprn_limit_amount;
	h_cntr1 := h_cntr1 + 1;
  end loop;
  for c_extnd_asset_rec in c_extnd_asset(X_book,X_assets(h_count))
  loop
      t_extnd_deprn_asset(h_cntr3).asset_id := c_extnd_asset_rec.asset_id;
      h_cntr3 := h_cntr3 + 1;
  end loop;
 --ERnos  6612615  what-if  end
  -- RUN IN NORMAL MODE TO GET DEPRN GIVEN CURRENT STATE
  -- STORES RESULTS IN FA_WHATIF_DEPRN_PKG.G_DEPRN

    h_mesg_name := 'FA_WHATIF_ASSET_NORMAL_MODE';

    ret := fa_whatif_deprn_pkg.whatif_deprn_asset (
	X_asset_id	=> X_assets(h_count),
	X_mode		=> 'NORMAL',
	X_book		=> X_book,
	X_start_per	=> X_start_per,
	X_num_pers	=> X_num_per,
	X_dpis		=> null,
	X_prorate_date  => null,
	X_prorate_conv  => null,
	X_deprn_start_date  => null,
	X_ceiling_name	=> null,
	X_bonus_rule	=> null,
	X_method_code	=> null,
	X_cost		=> null,
	X_old_cost	=> null,
	X_adj_cost	=> null,
	X_rec_cost	=> null,
	X_raf		=> null,
	X_adj_rate	=> null,
	X_reval_amo_basis  => null,
	X_capacity	=> null,
	X_adj_capacity	=> null,
	X_life		=> null,
	X_adj_rec_cost	=> null,
	X_salvage_value	=> null,
	X_salvage_pct   => null,
	X_category_id	=> null,
	X_deprn_rnd_flag  => null,
	X_calendar_type => null,
	X_prior_fy_exp	=> null,
	X_deprn_rsv	=> null,
	X_reval_rsv	=> null,
	X_ytd_deprn	=> null,
	X_ltd_prod	=> null,
	x_return_status => x_return_status);

   if (ret = FALSE) then
	x_return_status := 2;

	fa_whatif_deprn_pkg.g_deprn.delete;
	fnd_message.set_name('OFA','FA_WHATIF_ASSET_NORMAL_MODE');
	fnd_message.set_token('ASSET_ID',X_assets(h_count),FALSE);
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);
	return (FALSE);
   end if;


  -- RUN IN EXPENSED/AMORTIZED MODE TO GET DEPRN IN ADJUSTED STATE
  -- STORES RESULTS IN FA_WHATIF_DEPRN_PKG.G_DEPRN

   h_mesg_name := 'FA_WHATIF_ASSET_ADJ_MODE';

   if (X_prorate_conv is not null) or
      (X_bonus_rule is not null) or
      (X_method is not null) or
      (X_adjusted_rate is not null) or
      (X_life is not null) or
      (X_salvage_pct is not null) then
--tk_util.debug('Processing');

    ret := fa_whatif_deprn_pkg.whatif_deprn_asset (
	X_asset_id	=> X_assets(h_count),
	X_mode		=> X_exp_amt,
	X_book		=> X_book,
	X_start_per	=> X_start_per,
	X_num_pers	=> X_num_per,
	X_dpis		=> null,
	X_prorate_date  => null,
	X_prorate_conv  => X_prorate_conv,
	X_deprn_start_date  => null,
	X_ceiling_name	=> null,
	X_bonus_rule	=> X_bonus_rule,
	X_method_code	=> X_method,
	X_cost		=> null,
	X_old_cost	=> null,
	X_adj_cost	=> null,
	X_rec_cost	=> null,
	X_raf		=> null,
	X_adj_rate	=> X_adjusted_rate,
	X_reval_amo_basis  => null,
	X_capacity	=> null,
	X_adj_capacity	=> null,
	X_life		=> X_life,
	X_adj_rec_cost	=> null,
	X_salvage_value	=> null,
	X_salvage_pct   => X_salvage_pct,
	X_category_id	=> null,
	X_deprn_rnd_flag  => null,
	X_calendar_type => null,
	X_prior_fy_exp	=> null,
	X_deprn_rsv	=> null,
	X_reval_rsv	=> null,
	X_ytd_deprn	=> null,
	X_ltd_prod	=> null,
	x_return_status => x_return_status);

      if (ret = FALSE) then
         x_return_status := 2;

         fa_whatif_deprn_pkg.g_deprn.delete;
         fnd_message.set_name('OFA','FA_WHATIF_ASSET_ADJ_MODE');
         fnd_message.set_token('ASSET_ID',X_assets(h_count),FALSE);
         h_mesg_str := fnd_message.get;
         fa_rx_conc_mesg_pkg.log(h_mesg_str);
         return (FALSE);
      end if;
   end if;  -- (X_prorate_conv is not null) or


  -- COMMIT DEPRN RESULTS TO INTERFACE TABLE

   h_mesg_name := 'FA_WHATIF_ASSET_COMMIT';

--tk_util.debug('h_count:X_num_assets: '||to_char(h_count)||':'||to_char(X_num_assets));
    ret := fa_whatif_deprn_pkg.whatif_insert_itf (
	X_asset_id => X_assets(h_count),
	X_book	=> X_book,
	X_request_id => X_request_id,
	X_num_pers => X_num_per,
	X_acct_struct => h_acct_struct,
	X_key_struct => h_key_struct,
	X_cat_struct => h_cat_struct,
	X_loc_struct => h_loc_struct,
	X_precision =>  h_precision,
	X_user_id => X_user_id,
	X_login_id  =>  h_login_id,
        X_last_asset => (h_count = (X_num_assets - 1)),
	x_return_status => x_return_status);

--	X_seg_table => seg_table,
   if (ret = FALSE) then
	x_return_status := 2;

	fa_whatif_deprn_pkg.g_deprn.delete;
	fnd_message.set_name('OFA','FA_WHATIF_ASSET_COMMIT');
	fnd_message.set_token('ASSET_ID',X_assets(h_count),FALSE);
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);
	return (FALSE);
   end if;

    h_count := h_count + 1;
  end loop;

  --ERnos  6612615  what-if  start
-- BUG# 7193797 : Commented the below peice of code to make use of the standard Depreciation Functionality.
/*if t_ast_typ.FIRST is not null
then
  for j in 1..t_ast_typ.count
  loop
     FA_JP_TAX_EXTN_PVT.calc_jp250db (X_request_id => X_request_id,
										   X_asset_id => t_ast_typ(j).asset_id,
										   X_book	=> X_book,
										   X_method	=> t_ast_typ(j).method,
										   X_cost	=> t_ast_typ(j).adj_cost,
										   X_cur_cost	=> t_ast_typ(j).cost,
										   X_life	=> t_ast_typ(j).life,
										   X_rate_in_use => t_ast_typ(j).rate,
										   X_deprn_lmt => t_ast_typ(j).deprn_lmt,
										   X_start_prd => X_start_per,
										   X_dtin_serv => t_ast_typ(j).period,
										   X_num_per   => X_num_per
										   );

  end loop;
end if; */

 -- BUG# 7193797 :   End of the Comment

if t_extnd_deprn_asset.FIRST is not null
then
  for j in 1..t_extnd_deprn_asset.COUNT
  loop

      --ERnos  6612615  what-if  start
      	 FA_JP_TAX_EXTN_PVT.deprn_main (  x_errbuf
      			                        ,x_retcode
      			                        ,X_request_id
      			                        ,X_book
      			                        ,X_first_period
      			                        ,X_num_per
      			                        ,X_start_per
      			                        ,X_extnd_deprn_flg
      			                        ,X_fullresv_flg
      					        ,t_extnd_deprn_asset(j).asset_id
      			                        );
       --ERnos  6612615  what-if  end
  end loop;
end if;

--ERnos  6612615  what-if  end

  else
-- HYPOTHETICAL ASSET

  --fa_rx_conc_mesg_pkg.log('IN HERE IN HERE');

    ret := fa_whatif_deprn_pkg.whatif_deprn_asset (
	X_asset_id	=> 0,
	X_mode		=> 'HYPOTHETICAL',
	X_book		=> X_book,
	X_start_per	=> X_start_per,
	X_num_pers	=> X_num_per,
	X_dpis		=> X_dpis,
	X_prorate_date  => null,
	X_prorate_conv  => X_prorate_conv,
	X_deprn_start_date  => null,
	X_ceiling_name	=> null,
	X_bonus_rule	=> X_bonus_rule,
	X_method_code	=> X_method,
	X_cost		=> X_cost,
	X_old_cost	=> X_cost,
	X_adj_cost	=> null,
	X_rec_cost	=> null,
	X_raf		=> null,
	X_adj_rate	=> X_adjusted_rate,
	X_reval_amo_basis  => null,
	X_capacity	=> null,
	X_adj_capacity	=> null,
	X_life		=> X_life,
	X_adj_rec_cost	=> null,
	X_salvage_value	=> null,
	X_salvage_pct   => X_salvage_pct,
	X_category_id	=> X_cat_id,
	X_deprn_rnd_flag  => null,
	X_calendar_type => null,
	X_prior_fy_exp	=> null,
	X_deprn_rsv	=> X_deprn_rsv,
	X_reval_rsv	=> null,
	X_ytd_deprn	=> null,
	X_ltd_prod	=> null,
	x_return_status => x_return_status);

  --fa_rx_conc_mesg_pkg.log('OUT');

   if (ret = FALSE) then
	x_return_status := 2;

	fa_whatif_deprn_pkg.g_deprn.delete;
	fnd_message.set_name('OFA','FA_WHATIF_ASSET_NORMAL_MODE');
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);
	return (FALSE);
   end if;

      if (X_adjusted_rate is not null) then

        select r.basic_rate
        into   h_basic_rate
        from   fa_methods m, fa_flat_rates r
        where  m.method_code = X_method
        and    m.method_id = r.method_id
        and    r.adjusted_rate = X_adjusted_rate and rownum < 2;

      end if;

      -- Enhancement bug 3037321
      select currency_code
      into h_currency
      from gl_sets_of_books
      where set_of_books_id = FARX_C_WD.sob_id;

   fa_rx_shared_pkg.concat_category(h_cat_struct,
				    X_cat_id,
				    h_concat_str,
				    h_cat_segs);

--			            seg_table,

   h_sal := X_cost * (X_salvage_pct / 100);
   h_count := 0;
   loop  -- for each period

      if h_count >= X_num_per then exit;   end if;

	-- insert the Currency_code - for Enhancement bug 3037321
      insert into fa_whatif_itf (
        request_id, asset_id, asset_number, description, tag_number,
        serial_number, period_name, fiscal_year, expense_acct,
        depreciation, new_depreciation, location, units, employee_name,
        employee_number, asset_key,
        current_cost, current_prorate_conv, current_method, current_life,
        current_basic_rate, current_adjusted_rate, current_salvage_value,
	bonus_depreciation, new_bonus_depreciation,
        created_by, creation_date, last_update_date,
        last_updated_by, last_update_login,category,date_placed_in_service,
        accumulated_deprn,currency_code
        ) values (
        X_request_id, NULL, NULL, NULL, NULL, NULL,
        fa_whatif_deprn_pkg.g_deprn(h_count).period_name,
        fa_whatif_deprn_pkg.g_deprn(h_count).fiscal_year, NULL,
        fa_whatif_deprn_pkg.g_deprn(h_count).deprn,
	fa_whatif_deprn_pkg.g_deprn(h_count).new_deprn,
        NULL, NULL, NULL, NULL,
        NULL, X_cost, X_prorate_conv, X_method,
        X_life, h_basic_rate, X_adjusted_rate, h_sal,
	fa_whatif_deprn_pkg.g_deprn(h_count).bonus_deprn,
	fa_whatif_deprn_pkg.g_deprn(h_count).new_bonus_deprn,
        X_user_id, sysdate, sysdate, X_user_id, h_login_id,
        h_concat_str, X_dpis,
	fa_whatif_deprn_pkg.g_deprn(h_count).new_rsv,h_currency);

	h_count := h_count + 1;
  end loop;

  end if;

  fa_whatif_deprn_pkg.g_deprn.delete;

--  errbuf := '';
  return ret;

  exception when others then

  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;

	fa_whatif_deprn_pkg.g_deprn.delete;
	fnd_message.set_name('OFA',h_mesg_name);
	if h_mesg_name like 'FA_WHATIF_ASSET%' then
	  fnd_message.set_token('ASSET_ID',X_assets(h_count),FALSE);
	end if;
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);

	x_return_status := 2;
	return FALSE;

end whatif_deprn;


function whatif_get_assets (
	X_book		in varchar2,
	X_begin_asset	in varchar2,
	X_end_asset	in varchar2,
	X_begin_dpis	in date,
	X_end_dpis	in date,
	X_description   in varchar2,
	X_category_id	in number,
	X_mode		in varchar2,
	X_rsv_flag	in varchar2,
	X_good_assets out nocopy fa_std_types.number_tbl_type,
	X_num_good out nocopy number,
	X_start_range   in number,
	X_end_range     in number,
	x_return_status out nocopy number)
return boolean is


-- SELECTS ASSETS GIVEN PARAMETERS AS CRITERIA.  IF A PARAM IS
-- NULL, ASSUME NO CRITERION.
--
-- FURTHER CRITERIA:
-- 1. NO 'PRODUCTION' ASSETS (CURRENTLY NOT SUPPORTED)
-- 2. MUST BE CAPITALIZED AND DEPRECIATING.
-- 3. CAN'T BE FULLY RETIRED OR HAVE RETIREMENT PENDING

  h_mesg_name  varchar2(30);
  h_mesg_str   varchar2(2000);

cursor assets is
  select bk.asset_id, bk.deprn_method_code, ad.asset_number
  from fa_books bk, fa_additions ad
  where ad.asset_category_id = nvl(X_category_id,ad.asset_category_id)
  and ad.description like nvl(X_description,ad.description)
  and ad.asset_number >= nvl(X_begin_asset,ad.asset_number)
  and ad.asset_number <= nvl(X_end_asset,ad.asset_number)
  and ad.asset_type in ('CAPITALIZED', 'GROUP')
  and bk.asset_id = ad.asset_id
  and bk.asset_id >= nvl(X_start_range,bk.asset_id)
  and bk.asset_id <= nvl(X_end_range,bk.asset_id)
  and bk.book_type_code = X_book
  and bk.production_capacity is null
  and bk.depreciate_flag = 'YES'
  and bk.transaction_header_id_out is null
  and bk.period_counter_fully_retired is null
  and bk.date_placed_in_service >=
	nvl(X_begin_dpis,bk.date_placed_in_service)
  and bk.date_placed_in_service <=
	nvl(X_end_dpis,bk.date_placed_in_service)
  and nvl(BK.Period_Counter_Fully_Reserved, -1)
	= decode(X_rsv_flag, 'YES',
		nvl(BK.Period_Counter_Fully_Reserved, -1),-1)
  and bk.group_asset_id is null;

  CURSOR c_check_amortized (c_asset_id   number
                          , c_book_type_code  varchar2) IS
    select 1
    from   fa_transaction_headers
    where  asset_id = c_asset_id
    and    book_type_code = c_book_type_code
    and    transaction_subtype = 'AMORTIZED';



  h_asset_id   number;
  h_asset_number varchar2(15);
  h_method_code varchar2(25);
  h_good_ctr   number;
  h_check      number;
  ret  boolean;

  l_amortized   binary_integer;

begin

  ret := TRUE;
  h_good_ctr := 0;

  h_mesg_name := 'FA_DEPRN_SQL_DCUR';
  open assets;


  loop

    h_check := 0;

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch assets into h_asset_id, h_method_code, h_asset_number;
    if (assets%NOTFOUND) then exit;  end if;


    -- SCREEN OUT ASSETS FOR WHICH AN AMORTIZED ADJUSTMENT HAS ALREADY
    -- OCCURRED (FOR EXPENSED ONLY)


    if (X_mode = 'EXPENSED' and h_check = 0) then

       open c_check_amortized (h_asset_id,X_book);
       fetch c_check_amortized into l_amortized;

        if (c_check_amortized%FOUND) then
           close c_check_amortized;
           h_check := 1;
     	   fnd_message.set_name('OFA','FA_WHATIF_ASSET_EXP_AMT');
     	   fnd_message.set_token('ASSET_NUM',h_asset_number,FALSE);
     	   h_mesg_str := fnd_message.get;
     	   fa_rx_conc_mesg_pkg.log(h_mesg_str);
        else
           close c_check_amortized;
           h_check := 0;
        end if;

    end if;

    -- CAN'T AMORTIZE ADJUST AN ASSET THAT HASN'T DEPRECIATED YET.

    if (X_mode = 'AMORTIZED' and h_check = 0) then

       h_mesg_name := 'FA_WHATIF_ASSET_CHK_DEPRN';

       select count(*) into h_check
       from fa_deprn_detail
       where asset_id = h_asset_id
       and book_type_code = X_book
       and deprn_source_code = 'B'
       and not exists (select 1
                       from fa_deprn_detail dd1
                       where asset_id = h_asset_id
                       and book_type_code = X_book
                       and deprn_source_code = 'D'
                       and deprn_amount <> 0 );  -- bugfix 2223451 commented  deprn_amount > 0;

       if h_check > 0 then
     	  fnd_message.set_name('OFA','FA_WHATIF_ASSET_NO_DEPRN_YET');
     	  fnd_message.set_token('ASSET_NUM',h_asset_number,FALSE);
     	  h_mesg_str := fnd_message.get;
     	  fa_rx_conc_mesg_pkg.log(h_mesg_str);
       end if;
    end if;



-- SCREEN OUT ASSETS ADDED IN CURRENT PERIOD;
-- THESE WOULD JUST GET ADDITION,ADDITION/VOID TRX'S ANYWAYS.

--    select count(*) into h_check_cur_add
--    from  fa_books bk, fa_deprn_periods dp, fa_deprn_periods bdp
--    where bdp.period_counter = dp.period_counter
--    and dp.period_close_date is not null
--    and bk.date_placed_in_service between
--	bdp.period_open_date and nvl(bdp.period_close_date, sysdate)
--    and bk.asset_id = X_asset_id;
--


    if h_check = 0 then
	X_good_assets(h_good_ctr) := h_asset_id;
	h_good_ctr := h_good_ctr + 1;
    end if;


  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';
  close assets;

  X_num_good := h_good_ctr;

--  errbuf := '';
  return ret;


  exception when others then

  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
 	fnd_message.set_name('OFA',h_mesg_name);
	if h_mesg_name like 'FA_WHATIF_ASSET%' then
	  fnd_message.set_token('ASSET_ID',h_asset_id,FALSE);
	end if;
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);

	x_return_status := 2;
	return FALSE;


end whatif_get_assets;


END FA_WHATIF_DEPRN2_PKG;

/
