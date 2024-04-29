--------------------------------------------------------
--  DDL for Package Body FARX_C_WD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_C_WD" as
/* $Header: farxcwdb.pls 120.12.12010000.4 2009/12/21 08:21:28 deemitta ship $ */

      g_print_debug boolean := fa_cache_pkg.fa_print_debug;


PROCEDURE WHATIF (
  argument1        in  varchar2,                -- book
  argument20       in  varchar2,                -- set_of_books_id /* added for enhancement bug 3037321 */
  argument2        in  varchar2,                -- begin_period
  argument3        in  varchar2,                -- num_periods
  argument4        in  varchar2  default  null, -- begin_asset
  argument5        in  varchar2  default  null, -- end_asset
  argument6        in  varchar2  default  null, -- begin_dpis
  argument7        in  varchar2  default  null, -- end_dpis
  argument8        in  varchar2  default  null, -- description
  argument9        in  varchar2  default  null, -- category flex struct
  argument10       in  varchar2  default  null, -- category_id
  argument11       in  varchar2  default  null, -- new method
  argument12       in  varchar2  default  null, -- new life in months
  argument13       in  varchar2  default  null, -- new rate
  argument14       in  varchar2  default  null, -- new prorate convention
  argument15       in  varchar2  default  null, -- new salvage percentage
  argument16       in  varchar2  default  null, -- AMORTIZED yes_no
  argument17       in  varchar2  default  null, -- fully reserved yes_no
  argument18       in  varchar2  default  'NO', -- hypothetical NO
  argument19       in  varchar2  default  null, -- bonus_rule
  argument21       in  varchar2  default  'N', -- calc_extend_flag NO  -- ERnos  6612615  what-if  start
  argument22       in  varchar2  default  null, -- first_period                 -- ERnos  6612615  what-if  end
  p_parent_request_id    in      number,
  p_total_requests       in      number,
  p_request_number       in      number,
  x_success_count  out  NOCOPY   number,
  x_failure_count  out  NOCOPY   number,
  x_worker_jobs    out  NOCOPY   number,
  x_return_status  out  NOCOPY   number,
  argument28       in  varchar2  default  null,
  argument29       in  varchar2  default  null,
  argument30       in  varchar2  default  null,
  argument31       in  varchar2  default  null,
  argument32       in  varchar2  default  null,
  argument33       in  varchar2  default  null,
  argument34       in  varchar2  default  null,
  argument35       in  varchar2  default  null,
  argument36       in  varchar2  default  null,
  argument37       in  varchar2  default  null,
  argument38       in  varchar2  default  null,
  argument39       in  varchar2  default  null,
  argument40       in  varchar2  default  null,
  argument41       in  varchar2  default  null,
  argument42       in  varchar2  default  null,
  argument43       in  varchar2  default  null,
  argument44       in  varchar2  default  null,
  argument45       in  varchar2  default  null,
  argument46       in  varchar2  default  null,
  argument47       in  varchar2  default  null,
  argument48       in  varchar2  default  null,
  argument49       in  varchar2  default  null,
  argument50       in  varchar2  default  null,
  argument51       in  varchar2  default  null,
  argument52       in  varchar2  default  null,
  argument53       in  varchar2  default  null,
  argument54       in  varchar2  default  null,
  argument55       in  varchar2  default  null,
  argument56       in  varchar2  default  null,
  argument57       in  varchar2  default  null,
  argument58       in  varchar2  default  null,
  argument59       in  varchar2  default  null,
  argument60       in  varchar2  default  null,
  argument61       in  varchar2  default  null,
  argument62       in  varchar2  default  null,
  argument63       in  varchar2  default  null,
  argument64       in  varchar2  default  null,
  argument65       in  varchar2  default  null,
  argument66       in  varchar2  default  null,
  argument67       in  varchar2  default  null,
  argument68       in  varchar2  default  null,
  argument69       in  varchar2  default  null,
  argument70       in  varchar2  default  null,
  argument71       in  varchar2  default  null,
  argument72       in  varchar2  default  null,
  argument73       in  varchar2  default  null,
  argument74       in  varchar2  default  null,
  argument75       in  varchar2  default  null,
  argument76       in  varchar2  default  null,
  argument77       in  varchar2  default  null,
  argument78       in  varchar2  default  null,
  argument79       in  varchar2  default  null,
  argument80       in  varchar2  default  null,
  argument81       in  varchar2  default  null,
  argument82       in  varchar2  default  null,
  argument83       in  varchar2  default  null,
  argument84       in  varchar2  default  null,
  argument85       in  varchar2  default  null,
  argument86       in  varchar2  default  null,
  argument87       in  varchar2  default  null,
  argument88       in  varchar2  default  null,
  argument89       in  varchar2  default  null,
  argument90       in  varchar2  default  null,
  argument91       in  varchar2  default  null,
  argument92       in  varchar2  default  null,
  argument93       in  varchar2  default  null,
  argument94       in  varchar2  default  null,
  argument95       in  varchar2  default  null,
  argument96       in  varchar2  default  null,
  argument97       in  varchar2  default  null,
  argument98       in  varchar2  default  null,
  argument99       in  varchar2  default  null,
  argument100      in  varchar2  default  null) is


-- Arguments as follows:   ('M' indicated mandatory; others are optional)
-- argument1            book    (M)
-- argument2            begin_period   (M)
-- argument3            num_periods    (M)
-- argument4            begin_asset
-- argument5            end_asset
-- argument6            begin_dpis
-- argument7            end_dpis
-- argument8            description
-- argument9            category_id
-- argument11           new method
-- argument12           new life
-- argument13           new adjusted_rate
-- argument14           new prorate convention
-- argument15           new salvage percentage
-- argument16           EXPENSED or AMORTIZED
-- argument17           check fully reserved assets flag
-- argument18           hypothetical not used
-- argument19           bonus_rule
-- argument20           set_of_books_id (M) /* added for enhancement bug 3037321 */
-- argument21       calc_extend_flag NO    -- ERnos  6612615  what-if  start
-- argument22       first_period                        -- ERnos  6612615  what-if  end

  h_request_id     number;
  h_user_id     varchar2(20);
  ret              boolean;

  h_assets         fa_std_types.number_tbl_type;
  h_num_assets     number;

  h_begin_dpis          date;
  h_date_in_service     date;
  h_end_dpis            date;
  h_begin_str           varchar2(25);
  h_end_str             varchar2(25);
  h_date_format         varchar2(25);

  h_begin_per           varchar2(25);

  h_exp_amt             varchar2(10);
  h_cat_id              number;
  h_cat_struct          number;

  h_adj_rate            number;

  h_count               number;

  h_sqlstmt             varchar2(400);


  h_mesg_name           varchar2(30);
  h_mesg_str            varchar2(2000);
  h_param_error         varchar2(30);
  h_value_error         varchar2(240);

  h_check               varchar2(5);

  l_mode                varchar2(10);  -- This stores value of h_exp_amt or 'PROJ'
                                       -- if user didn't provide any parameters.
  /*Added for parallelization*/
  l_batch_size          number;

  l_unassigned_cnt      number := 0;
  l_failed_cnt          number := 0;
  l_wip_cnt             number := 0;
  l_completed_cnt       number := 0;
  l_total_cnt           number := 0;
  l_count               number := 0;
  l_start_range         number := 0;
  l_end_range           number := 0;

  l_calling_fn          varchar2(40) := 'FARX_C_WD.WHATIF';

  done_exc              exception;
  error_found           exception;

  begin

  /*Added for parallelization*/
  x_success_count := 0;
  x_failure_count := 0;
  x_worker_jobs   := 0;
  x_return_status := 0;

 -- dbms_session.reset_package;

  -- VALIDATE THE ARGUMENTS.  SINCE RX CLIENT CURRENTLY DOES NO
  -- VALIDATION, USER CAN ENTER GARBAGE STRINGS IF THEY WANT.  NEED
  -- TO VALIDATE EVERYTHING RIGHT HERE.


  -- BOOK

  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
  h_value_error := argument1;
  h_param_error := 'BOOK';

  h_count := 0;

  if argument1 is null then

        fnd_message.set_name('OFA','FA_WHATIF_PARAM_REQUIRED');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;

  end if;

  select count(*) into h_count
  from fa_book_controls
  where book_Type_code = argument1 and rownum < 2;

  if h_count = 0 then
        fnd_message.set_name('OFA','FA_WHATIF_PARAM_REQUIRED');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;
  end if;

  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
  h_value_error := argument20;
  h_param_error := 'SET OF BOOKS ID';

  -- Enhancement Bug 3037321
  FARX_C_WD.sob_id := to_number(argument20);
  select mrc_sob_type_code,currency_code
  into FARX_C_WD.mrc_sob_type,FARX_C_WD.currency
  from gl_sets_of_books
  where set_of_books_id = to_number(argument20);

  -- Enhancement Bug 3037321
  if(FARX_C_WD.mrc_sob_type = 'R') then
    fnd_client_info.set_currency_context(FARX_C_WD.sob_id);
  end if;

  -- PERIOD NAME
  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
  h_value_error := argument2;
  h_param_error := 'PERIOD NAME';


  if argument2 is null then
        fnd_message.set_name('OFA','FA_WHATIF_PARAM_REQUIRED');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;
  end if;

  h_count := 0;
  select count(*) into h_count
  from fa_book_controls bc, fa_calendar_periods cp
  where bc.book_type_code = argument1
  and bc.deprn_calendar = cp.calendar_type
  and cp.period_name = argument2 and rownum < 2;

  if h_count = 0 then

        fnd_message.set_name('OFA','FA_WHATIF_PARAM_REQUIRED');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;
  end if;



  -- NUM PERIODS

  if ((argument3 is null) OR (to_number(argument3) <= 0  OR
        to_number(argument3) <> floor(to_number(argument3)))) then

        fnd_message.set_name('OFA','FA_WHATIF_PARAM_REQUIRED');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;
  end if;


  -- Make sure calendar is defined for duration of projection.

  select count(*) into h_count
  from fa_book_controls bc, fa_calendar_types ct,
  fa_calendar_periods cp
  where bc.book_type_code = argument1
  and bc.deprn_calendar = ct.calendar_type
  and ct.calendar_type = cp.calendar_type
  and cp.start_date >= (select cp1.start_date from
        fa_calendar_periods cp1
        where cp1.calendar_type = cp.calendar_type
        and cp1.period_name = argument2);

  if h_count < to_number(argument3) then
        fnd_message.set_name('OFA','FA_PROJ_CALS_UNDEFINED');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);
        x_return_status := 2;
        return;
  end if;


  --
  -- NOT hypothetical case
  --
  if (upper(argument18) in ('NO', 'N')) then

      -- BEGIN/END ASSET

      if (argument4 is not null and argument5 is not null AND
        argument5 < argument4) then

        fnd_message.set_name('OFA','FA_WHATIF_BEGIN_END_ASSET');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;
      end if;

      -- NOTE: DATE FORMATTING PROBLEMS SHOULD BE FEW AND FAR BETWEEN.
      -- THIS IS ONE OF THE FEW THINGS THAT THE RX CLIENT CURRENTLY CHECKS
      -- FOR.  MOREOVER, CM WILL PUT ANY UNHANDLED DATE FORMATTING
      -- EXCEPTIONS INTO THE LOG FILE.

      -- CATEGORY: FIRST GET CATEGORY_ID, THEN CHECK IF EXISTS, ENABLED, ETC.

      if (argument10 is not null) then
        h_cat_id := to_number(argument10);
      end if;

      /* ********************************************************************
       Commenting out all code to validate and get category_id since this
       is passed from SRS in argument 10

      h_mesg_name := 'FA_FE_LOOKUP_IN_SYSTEM_CTLS';
      select category_flex_structure into h_cat_struct
              from fa_system_controls;

      h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
      h_value_error := argument9;
      h_param_error := 'CATEGORY';

      if fnd_flex_keyval.validate_segs (
          operation => 'CHECK_COMBINATION',
          appl_short_name => 'OFA',
          key_flex_code => 'CAT#',
          structure_number => h_cat_struct,
          concat_segments => argument9,
          values_or_ids  => 'V',
          validation_date  =>SYSDATE,
          displayable  => 'ALL',
          data_set => NULL,
          vrule => NULL,
          where_clause => NULL,
          get_columns => NULL,
          allow_nulls => FALSE,
          allow_orphans => FALSE,
          resp_appl_id => NULL,
          resp_id => NULL,
          user_id => NULL) = FALSE then

             fnd_message.set_name('OFA','FA_WHATIF_NO_CAT');
             fnd_message.set_token('CAT',argument9,FALSE);
             h_mesg_str := fnd_message.get;
             fa_rx_conc_mesg_pkg.log(h_mesg_str);

             x_return_status := 2;
             return;
      end if;
       h_cat_id := fnd_flex_keyval.combination_id;
       h_count := 0;

       select count(*) into h_count from fa_categories cat,
                                         fa_category_books cb
       where cat.category_id = h_cat_id
       and cat.enabled_flag = 'Y' and cat.capitalize_flag = 'YES'
       and sysdate between nvl(cat.start_date_active,sysdate-1) and
           nvl(cat.end_date_active,sysdate+1)
       and cat.category_id = cb.category_id
       and cb.book_type_code = argument1 and rownum < 2;

       if h_count = 0 then
          fnd_message.set_name('OFA','FA_WHATIF_CAT_NOT_SET_UP');
          fnd_message.set_token('CAT',argument9,FALSE);
          h_mesg_str := fnd_message.get;
          fa_rx_conc_mesg_pkg.log(h_mesg_str);

          x_return_status := 2;
          return;
       end if;
      end if;
     ********************************************************************* */


      -- CHECK_FULLY_RESERVED_FLAG

      h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
      h_value_error := argument17;
      h_param_error := 'FULLY_RSVD_FLAG';

      if (argument17 not in ('Y','N','YES','NO')) then

          fnd_message.set_name('OFA',h_mesg_name);
          if h_mesg_name = 'FA_WHATIF_PARAM_ERROR' then
                fnd_message.set_token('VALUE',h_value_error,FALSE);
                fnd_message.set_token('PARAM',h_param_error,FALSE);
          end if;
          h_mesg_str := fnd_message.get;
          fa_rx_conc_mesg_pkg.log(h_mesg_str);
          x_return_status := 2;

        return;
      end if;

      -- CONVERT DPIS'S INTO DATE-TYPED VARIABLES
      -- THIS IS THE APPS STANDARD.  SUBMISSION FORM DOES THE SAME THING.

      if (argument6 is not null) then
          h_begin_dpis := to_date(argument6, 'YYYY/MM/DD HH24:MI:SS');
      end if;

      if (argument7 is not null) then
         h_end_dpis := to_date(argument7, 'YYYY/MM/DD HH24:MI:SS');
      end if;

      if (argument6 is not null and argument7 is not null) then
         if h_end_dpis < h_begin_dpis then
           fnd_message.set_name('OFA','FA_SHARED_BAD_END_DATE');
           h_mesg_str := fnd_message.get;
           fa_rx_conc_mesg_pkg.log(h_mesg_str);
           x_return_status := 2;
           return;
         end if;
      end if;

  end if;   -- NOT hypothetical case

  -- METHOD
  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
  h_value_error := argument10;
  h_param_error := 'METHOD';

  if (argument11 is not null) then


  h_count := 0;
  select count(*) into h_count
  from fa_methods
  where method_code = argument11 and rownum < 2;

  if h_count = 0 then
        fnd_message.set_name('OFA','FA_WHATIF_NO_METHOD');
        fnd_message.set_token('METHOD',argument11,FALSE);
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;
  end if;
  end if;



  if (argument11 is not null) then

  -- LIFE
  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
  h_value_error := argument12;
  h_param_error := 'LIFE';

  h_count := 0;
  select count(*) into h_count from fa_methods
  where method_code = argument11
  and rate_source_rule in ('TABLE','CALCULATED','FORMULA')
  and rownum < 2;

  if h_count > 0 then     -- this is a life-based method

    if (argument12 is null) then

        fnd_message.set_name('OFA','FA_MASSCHG_LIFE_BASED_METHOD');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;
    end if;

    h_count := 0;
    select count(*) into h_count from fa_methods
    where method_code = argument11 and life_in_months = to_number(argument12)
        and rownum < 2;

    if h_count = 0 then
        fnd_message.set_name('OFA','FA_SHARED_INVALID_METHOD_LIFE');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;
    end if;

    if (argument13 is not null) then
        fnd_message.set_name('OFA','FA_METHOD_NO_RATES');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;

    end if;

  end if;

 -- RATE
  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
  h_value_error := argument13;
  h_param_error := 'RATE';


  h_count := 0;
  select count(*) into h_count from fa_methods m
  where m.method_code = argument11
  and m.rate_source_rule = 'FLAT' and rownum < 2;

  if h_count > 0 then     -- this is a rate-based method

    if (argument13 is null) then
        fnd_message.set_name('OFA','FA_MASSCHG_RATE_BASED_METHOD');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;
    end if;

    h_adj_rate := to_number(argument13) / 100;

    h_count := 0;
    select count(*) into h_count from fa_methods m, fa_flat_rates r
    where m.method_code = argument11
    and m.method_id = r.method_id
    and r.adjusted_rate = h_adj_rate and rownum < 2;

    if h_count = 0 then
        fnd_message.set_name('OFA','FA_SHARED_INVALID_METHOD_RATE');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;

    end if;

    if (argument12 is not null) then
        fnd_message.set_name('OFA','FA_METHOD_NO_LIFE');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;


    end if;

  end if;

  end if;

 -- PRORATE CONVENTION

  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
  h_value_error := argument14;
  h_param_error := 'CONVENTION';

  if argument14 is not null then

  h_count := 0;
  select count(*) into h_count from fa_conventions
  where prorate_convention_code = argument14 and rownum < 2;

  if h_count = 0 then
        fnd_message.set_name('OFA','FA_WHATIF_NO_CONVENTION');
        fnd_message.set_token('CONV',argument14,FALSE);
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;
  end if;
  end if;

 -- SALVAGE_VALUE_PERCENTAGE

  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
  h_value_error := argument15;
  h_param_error := 'SALVAGE VALUE';

  if argument15 is not null then

  if (to_number(argument15) < 0  OR  to_number(argument15) > 100) then
        fnd_message.set_name('OFA','FA_SHARED_BAD_PERCENT');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return;
  end if;
  end if;

 -- AMORTIZE_FLAG

  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
  h_value_error := argument16;
  h_param_error := 'AMORTIZE_FLAG';


  if (upper(argument16) not in ('Y','N','YES','NO','EXPENSED','AMORTIZED'))
        then

          fnd_message.set_name('OFA',h_mesg_name);
          if h_mesg_name = 'FA_WHATIF_PARAM_ERROR' then
                fnd_message.set_token('VALUE',h_value_error,FALSE);
                fnd_message.set_token('PARAM',h_param_error,FALSE);
          end if;
          h_mesg_str := fnd_message.get;
          fa_rx_conc_mesg_pkg.log(h_mesg_str);
          x_return_status := 2;

        return;

  end if;


  -- USER_ID

  /* ***************************************************
  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
  h_value_error := argument17;
  h_param_error := 'USER_ID';

  h_count := 0;
  select count(*) into h_count from fnd_user
  where user_id = to_number(argument17) and rownum < 2;

  if (h_count = 0 and to_number(nvl(argument17,'0')) <> 0) then

          fnd_message.set_name('OFA',h_mesg_name);
          if h_mesg_name = 'FA_WHATIF_PARAM_ERROR' then
                fnd_message.set_token('VALUE',h_value_error,FALSE);
                fnd_message.set_token('PARAM',h_param_error,FALSE);
          end if;
          h_mesg_str := fnd_message.get;
          fa_rx_conc_mesg_pkg.log(h_mesg_str);
          x_return_status := 2;
        return;
  end if;
  ******************************************************* */

  h_request_id := fnd_global.conc_request_id;
  fnd_profile.get('USER_ID',h_user_id);

  -- CHECK AMORTIZE_FLAG

  if (upper(argument16) in ('YES','Y')) then h_exp_amt := 'AMORTIZED';
  elsif (upper(argument16) in ('NO','N')) then h_exp_amt := 'EXPENSED';
  elsif (argument16 is null) then h_exp_amt := 'EXPENSED';
  else h_exp_amt := upper(argument16);
  end if;


 -- BONUS RULE

  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
  h_value_error := argument19;
  h_param_error := 'BONUS RULE';

  if argument19 is not null then

  h_count := 0;
  select count(*) into h_count from fa_bonus_rules
  where bonus_rule = argument19 and rownum < 2;

  if h_count = 0 then


          fnd_message.set_name('OFA',h_mesg_name);
          if h_mesg_name = 'FA_WHATIF_PARAM_ERROR' then
                fnd_message.set_token('VALUE',h_value_error,FALSE);
                fnd_message.set_token('PARAM',h_param_error,FALSE);
          end if;
          h_mesg_str := fnd_message.get;
          fa_rx_conc_mesg_pkg.log(h_mesg_str);
          x_return_status := 2;
        return;

  end if;
  end if;

/*Added for parallelism start */
 if (p_total_requests > 1) then

   select nvl(sum(decode(status,'UNASSIGNED', 1, 0)),0),
          nvl(sum(decode(status,'FAILED', 1, 0)),0),
          nvl(sum(decode(status,'IN PROCESS', 1, 0)),0),
          nvl(sum(decode(status,'COMPLETED',1 , 0)),0),
          count(*)
   into   l_unassigned_cnt,
          l_failed_cnt,
          l_wip_cnt,
          l_completed_cnt,
          l_total_cnt
   from   fa_worker_jobs
   where  request_id = p_parent_request_id;

   if g_print_debug then
      fa_debug_pkg.add(l_calling_fn, 'Job status - Unassigned: ', l_unassigned_cnt);
      fa_debug_pkg.add(l_calling_fn, 'Job status - In Process: ', l_wip_cnt);
      fa_debug_pkg.add(l_calling_fn, 'Job status - Completed: ',  l_completed_cnt);
      fa_debug_pkg.add(l_calling_fn, 'Job status - Failed: ',     l_failed_cnt);
      fa_debug_pkg.add(l_calling_fn, 'Job status - Total: ',      l_total_cnt);
   end if;

   if (l_failed_cnt > 0) then
      if g_print_debug then
        fa_debug_pkg.add(l_calling_fn, 'another worker has errored out: ', 'stop processing');
      end if;
      raise error_found;  -- probably not
   elsif (l_unassigned_cnt = 0) then
      if g_print_debug then
         fa_debug_pkg.add(l_calling_fn, 'no more jobs left', 'terminating.');
      end if;
      raise done_exc;
   elsif (l_completed_cnt = l_total_cnt) then
      if g_print_debug then
         fa_debug_pkg.add(l_calling_fn, 'all jobs completed, no more jobs. ', 'terminating');
      end if;
      raise done_exc;
   elsif (l_unassigned_cnt > 0) then
      update fa_worker_jobs
      set    status = 'IN PROCESS',
             worker_num = p_request_number
      where  status = 'UNASSIGNED'
      and    request_id = p_parent_request_id
      and    rownum < 2;
      if g_print_debug then
         fa_debug_pkg.add(l_calling_fn, 'taking job from job queue',  sql%rowcount);
      end if;
      l_count := sql%rowcount;
      x_worker_jobs := l_unassigned_cnt;
      commit;
   end if;
end if;     --  if (p_total_requests > 1) then

/*end parallelism*/

if (l_count > 0 or p_total_requests < 2) then

--begin

  begin

  select start_range
        ,end_range
   into l_start_range
       ,l_end_range
   from fa_worker_jobs
  where request_id = p_parent_request_id
    and worker_num = p_request_number
    and  status = 'IN PROCESS';

  exception

    when no_data_found then
     fa_debug_pkg.add(l_calling_fn, 'selecting', 'null ranges');
  end;


  -- NOT hypothetical case

  if (upper(argument18) in ('NO', 'N')) then

     -- If user doesn't provide value for any of following parameter
     -- user just wants to see projected amount so any validation in
     -- whatif_get_assets should not be performed.
     --
     --   method        => argument11    life          => argument12
     --   adjusted_rate => h_adj_rate    prorate_conv  => argument14
     --   salvage_pct   => argument15    bonus_rule    => argument19
     --
     if (argument11 is null) and
        (argument12 is null) and
        (h_adj_rate is null) and
        (argument14 is null) and
        (argument15 is null) and
        (argument19 is null) then
        l_mode := 'PROJ';
     else
        l_mode := h_exp_amt;
     end if;

-- GENERATE LIST OF ASSETS ON WHICH TO PERFORM WHAT-IF

     h_mesg_name := 'FA_WHATIF_GET_ASSETS_ERR';

    if(p_total_requests > 1) then
     ret := fa_whatif_deprn2_pkg.whatif_get_assets (
                  X_book        => argument1,
                  X_begin_asset => argument4,
                  X_end_asset   => argument5,
                  X_begin_dpis  => h_begin_dpis,
                  X_end_dpis    => h_end_dpis,
                  X_description => argument8,
                  X_category_id => h_cat_id,
                  X_mode        => l_mode,
                  X_rsv_flag    => argument17,
                  X_good_assets => h_assets,
                  X_num_good    => h_num_assets,
                  X_start_range => l_start_range,
                  X_end_range   => l_end_range,
                  x_return_status => x_return_status);
    else
     ret := fa_whatif_deprn2_pkg.whatif_get_assets (
                  X_book        => argument1,
                  X_begin_asset => argument4,
                  X_end_asset   => argument5,
                  X_begin_dpis  => h_begin_dpis,
                  X_end_dpis    => h_end_dpis,
                  X_description => argument8,
                  X_category_id => h_cat_id,
                  X_mode        => l_mode,
                  X_rsv_flag    => argument17,
                  X_good_assets => h_assets,
                  X_num_good    => h_num_assets,
                  X_start_range => null,
                  X_end_range   => null,
                  x_return_status => x_return_status);
    end if;
  -- IF NO ASSETS RETURNED, EXIT WITH WARNING.
  -- NO NEED TO RUN WHATIF.  NO ROWS WOULD GET GENERATED ANYWAYS.
  -- Bug 8930129, changing the return status to 0 so that no error is raised
  -- when there is NO ASSET is there to process.
     if h_num_assets = 0 then
        fnd_message.set_name('OFA','FA_WHATIF_NO_ASSETS');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

          if (p_total_requests > 1) then
              update fa_worker_jobs
                 set status     = 'COMPLETED'
               where request_id = p_parent_request_id
                 and worker_num = p_request_number
                 and status     = 'IN PROCESS';

              commit;
          end if;
        x_return_status := 0;
        return;
     end if;

     -- DO WHAT-IF
     h_mesg_name := 'FA_WHATIF_RUN_WHATIF_ERR';

     ret := fa_whatif_deprn2_pkg.whatif_deprn (
        X_assets        => h_assets,
        X_num_assets    => h_num_assets,
        X_method        => argument11,
        X_life          => to_number(argument12),
        X_adjusted_rate => h_adj_rate,
        X_prorate_conv  => argument14,
        X_salvage_pct   => to_number(argument15),
        X_exp_amt       => h_exp_amt,
        X_book          => argument1,
        X_start_per     => argument2,
        X_num_per       => to_number(argument3),
        X_request_id    => nvl(p_parent_request_id,h_request_id),
        X_user_id       => to_number(h_user_id),
        X_hypo          => upper(argument18),
        X_dpis          => NULL,
        X_cost          => NULL,
        X_deprn_rsv     => NULL,
        X_cat_id        => NULL,
        X_bonus_rule    => argument19,
        x_return_status         => x_return_status,
        X_fullresv_flg => argument17,                   -- ERnos  6612615  what-if  start
        X_extnd_deprn_flg => argument21,
        X_first_period => argument22);                  -- ERnos  6612615  what-if  end

        --  x_return_status := 0;

       fa_whatif_deprn_pkg.g_deprn.delete;
       if (ret) then

            if (p_total_requests < 2 ) then
                raise done_exc;
            else
                update fa_worker_jobs
                   set status     = 'COMPLETED'
                 where request_id = p_parent_request_id
                  and worker_num = p_request_number
                  and status     = 'IN PROCESS';

               commit;
            end if;

       else

            if (p_total_requests < 2 ) then
                raise error_found;
            else
                update fa_worker_jobs
                   set status     = 'FAILED'
                 where request_id = p_parent_request_id
                  and worker_num = p_request_number
                  and status     = 'IN PROCESS';

               commit;

            end if;
       end if;
  else  -- hypothetical case

  --fa_rx_conc_mesg_pkg.log('calling whatif deprn package');

  if (argument4 is not null) then
     h_date_in_service := fnd_date.canonical_to_date(argument4);
  end if;

    if (argument7 is not null) then
       h_cat_id := to_number(argument7);
    end if;

    /* *********************************************************
       h_count := 0;

       h_mesg_name := 'FA_FE_LOOKUP_IN_SYSTEM_CTLS';
       select category_flex_structure into h_cat_struct
              from fa_system_controls;

       h_mesg_name := 'FA_WHATIF_PARAM_ERROR';
       h_value_error := argument7;
       h_param_error := 'CATEGORY';

       if fnd_flex_keyval.validate_segs (
          operation => 'CHECK_COMBINATION',
          appl_short_name => 'OFA',
          key_flex_code => 'CAT#',
          structure_number => h_cat_struct,
          concat_segments => argument7,
          values_or_ids  => 'V',
          validation_date  =>SYSDATE,
          displayable  => 'ALL',
          data_set => NULL,
          vrule => NULL,
          where_clause => NULL,
          get_columns => NULL,
          allow_nulls => FALSE,
          allow_orphans => FALSE,
          resp_appl_id => NULL,
          resp_id => NULL,
          user_id => NULL) = FALSE then

             fnd_message.set_name('OFA','FA_WHATIF_NO_CAT');
             fnd_message.set_token('CAT',argument7,FALSE);
             h_mesg_str := fnd_message.get;
             fa_rx_conc_mesg_pkg.log(h_mesg_str);

             x_return_status := 2;
             return;
       end if;
       h_cat_id := fnd_flex_keyval.combination_id;

       h_count := 0;

       select count(*) into h_count from fa_categories cat,
                                         fa_category_books cb
       where cat.category_id = h_cat_id
       and cat.enabled_flag = 'Y' and cat.capitalize_flag = 'YES'
       and sysdate between nvl(cat.start_date_active,sysdate-1) and
           nvl(cat.end_date_active,sysdate+1)
       and cat.category_id = cb.category_id
       and cb.book_type_code = argument1 and rownum < 2;

       if h_count = 0 then
          fnd_message.set_name('OFA','FA_WHATIF_CAT_NOT_SET_UP');
          fnd_message.set_token('CAT',argument7,FALSE);
          h_mesg_str := fnd_message.get;
          fa_rx_conc_mesg_pkg.log(h_mesg_str);

          x_return_status := 2;
          return;
      end if;
    end if;
    ********************************************************** */
    /*Bug 9048083 Passed the correct value of category ID below via argument8
      Correct val of category ID is passed through argument 8 when program is
      run from rxi report but argument 8 is null when program is called from what if form*/

    h_cat_id := NVL (argument8,h_cat_id);

    --fa_rx_conc_mesg_pkg.log(h_date_in_service);
    ret := fa_whatif_deprn2_pkg.whatif_deprn (
        X_assets        => h_assets,
        X_num_assets    => NULL,
        X_method        => argument11,
        X_life          => to_number(argument12),
        X_adjusted_rate => h_adj_rate,
        X_prorate_conv  => argument14,
        X_salvage_pct   => to_number(argument15),
        X_exp_amt       => h_exp_amt,
        X_book          => argument1,
        X_start_per     => argument2,
        X_num_per       => to_number(argument3),
        X_request_id    => h_request_id,
        X_user_id       => to_number(h_user_id),
        X_hypo          => upper(argument18),
        X_dpis          => h_date_in_service ,
        X_cost          => to_number(argument5),
        X_deprn_rsv     => to_number(argument6),
        X_cat_id        => h_cat_id, --argument8,
        X_bonus_rule    => argument19,
        x_return_status         => x_return_status,
        X_fullresv_flg => argument17,                   -- ERnos  6612615  what-if  start
        X_extnd_deprn_flg => argument21,
        X_first_period => argument22);                  -- ERnos  6612615  what-if  end

     if (ret) then
          if (p_total_requests < 2 ) then
              raise done_exc;
          else
                update fa_worker_jobs
                   set status     = 'COMPLETED'
                 where request_id = p_parent_request_id
                  and worker_num = p_request_number
                  and status     = 'IN PROCESS';

               commit;

          end if;
       else
          if (p_total_requests < 2 ) then
              raise error_found;
          else
                update fa_worker_jobs
                   set status     = 'FAILED'
                 where request_id = p_parent_request_id
                  and worker_num = p_request_number
                  and status     = 'IN PROCESS';

               commit;

          end if;
       end if;
  end if; -- NOT hypothetical case
end if; /* if (l_count > 0 or p_total_requests=1) */
/*End parallelism */

EXCEPTION
  WHEN done_exc then
       if (p_total_requests > 1) then

           update fa_worker_jobs
              set status     = 'COMPLETED'
            where request_id = p_parent_request_id
              and worker_num = p_request_number
              and status     = 'IN PROCESS';
            commit;

           if g_print_debug then
              fa_debug_pkg.add(l_calling_fn, 'updating', 'worker jobs');
           end if;
       end if;

        x_success_count := x_success_count + 1;
        if (g_print_debug) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
        end if;
        x_return_status := 0;
        return;

   WHEN error_found then

       update fa_worker_jobs
           set status     = 'FAILED'
         where request_id = p_parent_request_id
          and worker_num = p_request_number
          and status     = 'IN PROCESS';

       commit;

        x_failure_count := x_failure_count + 1;
        fa_srvr_msg.add_message(calling_fn => 'FARX_C_WD.WHATIF');
        if (g_print_debug) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
        end if;
        x_return_status := 2;
        return;

   WHEN OTHERS THEN

       update fa_worker_jobs
           set status     = 'FAILED'
         where request_id = p_parent_request_id
          and worker_num = p_request_number
          and status     = 'IN PROCESS';

       commit;

        x_failure_count := x_failure_count + 1;
        fa_srvr_msg.add_sql_error(calling_fn => 'FARX_C_WD.WHATIF');
        if (g_print_debug) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
        end if;
        x_return_status := 2;
        fa_whatif_deprn_pkg.g_deprn.delete;
        return;
/*
        if SQLCODE <> 0 then
           fa_Rx_conc_mesg_pkg.log(SQLERRM);
        end if;

        fnd_message.set_name('OFA',h_mesg_name);
        if h_mesg_name = 'FA_WHATIF_PARAM_ERROR' then
          fnd_message.set_token('VALUE',h_value_error,FALSE);
          fnd_message.set_token('PARAM',h_param_error,FALSE);
        end if;
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
*/
  end WHATIF;


PROCEDURE Load_Workers(
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_worker_jobs           OUT NOCOPY NUMBER,
                x_return_status         OUT NOCOPY number
               ) is

   l_batch_size         number;
   l_calling_fn         varchar2(60) := 'FARX_C_WD.Load_Workers';

   error_found          exception;

BEGIN

  l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 1000);

  if (p_total_requests > 1) then

   insert into fa_worker_jobs
          (start_range, end_range, worker_num, status,request_id)
   select min(asset_id), max(asset_id), 0,
          'UNASSIGNED', p_parent_request_id  from ( select /*+ parallel(dh) */
          asset_id, floor(rank()
          over (order by asset_id)/l_batch_size ) unit_id
     from fa_books
    where book_type_code = p_book_type_code )
    group by unit_id;

   if g_print_debug then
      fa_debug_pkg.add(l_calling_fn, 'rows inserted into worker jobs: ', SQL%ROWCOUNT);
   end if;

    x_worker_jobs := sql%rowcount;

    commit;
  end if;

   if g_print_debug then
      fa_debug_pkg.add(l_calling_fn, 'rows inserted into worker jobs: ', x_worker_jobs);
   end if;

   x_return_status := 0;

EXCEPTION
   when OTHERS then
        fa_srvr_msg.add_sql_error(calling_fn => 'FARX_C_WD.WHATIF');
        rollback;
        if (g_print_debug) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
        end if;
        x_return_status := 2;

END Load_Workers;

END FARX_C_WD;

/
