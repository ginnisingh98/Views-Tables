--------------------------------------------------------
--  DDL for Package Body JA_AU_FA_BAL_CHG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_AU_FA_BAL_CHG" AS
/* $Header: jaaufasb.pls 115.11 2003/12/17 12:31:03 rbasker ship $ */

   /***********************************************************************
   PROCEDURE   	- Schedule 32
   DESCRIPTION  - Processes data for the Schedule 32 report
   ************************************************************************/
  PROCEDURE Schedule32
          (P_Book_type_code     VARCHAR2,
           P_From_Period        VARCHAR2,
           P_To_Period          VARCHAR2,
           P_Category_ID	  NUMBER ) IS
   v_book_type_code varchar2(15) := (P_Book_Type_Code);
   v_from_period    varchar2(15) := (P_From_Period);
   v_to_period      varchar2(15) := (P_To_Period);
   v_category_id    integer := to_number(P_Category_id);
   v_cat_temp       integer := 1;
   v_category       varchar2(80);
   v_from_date      fa_deprn_periods.period_open_date%type;
   v_from_counter   fa_deprn_periods.period_counter%type;
   v_from_cal_date  fa_deprn_periods.calendar_period_open_date%type;
   v_to_date        fa_deprn_periods.period_close_date%type;
   v_to_counter     fa_deprn_periods.period_counter%type;
   v_col1           fnd_id_flex_segments.application_column_name%type;
   v_col2           fnd_id_flex_segments.application_column_name%type;

CURSOR C_Get_First_Category IS
   SELECT B.Category_id
   FROM   FA_Categories_B B,
          FA_Categories_TL T
   WHERE  B.category_id = T.category_id
     AND  T.language    = userenv('LANG')
     AND  ROWNUM = 1;

CURSOR C_Get_Category (C_Category_ID    NUMBER,
                       C_First_Category NUMBER ) IS
   SELECT DECODE(v_Category_id,null,'ALL-ALL',DECODE(flex1.application_column_name,'SEGMENT7', C.SEGMENT7, 'SEGMENT6', C.SEGMENT6,
          'SEGMENT5', C.SEGMENT5, 'SEGMENT4', C.SEGMENT4, 'SEGMENT3',
          C.SEGMENT3, 'SEGMENT2', C.SEGMENT2, C.SEGMENT1) ||
          decode(nvl(flex2.application_column_name, ' '), ' ', ' ', '-') ||
          DECODE(nvl(flex2.application_column_name, ' '), 'SEGMENT7', C.SEGMENT7, 'SEGMENT6', C.SEGMENT6,
              'SEGMENT5', C.SEGMENT5, 'SEGMENT4', C.SEGMENT4, 'SEGMENT3',
              C.SEGMENT3, 'SEGMENT2', C.SEGMENT2, 'SEGMENT1', C.SEGMENT1,
              ' '))
   FROM   fa_categories C,
          fnd_id_flexs flexid,
          fnd_id_flex_segments flex1,
          fnd_id_flex_segments flex2
   WHERE  C.Category_id                 = nvl(C_category_id,C_first_category)
   and    flexid.application_id = 140
   and    flexid.id_flex_code  = 'CAT#'
   and    flex1.id_flex_code            = flexid.id_flex_code
   and    flex1.application_id = 140
   and    flex1.id_flex_code = 'CAT#'
   and    flex1.id_flex_num = 101
   and    flex1.application_column_name = 'SEGMENT1'
   and    flex1.enabled_flag            = 'Y'
   and    flex2.id_flex_code (+)        = flexid.id_flex_code
   and    flex2.application_id(+) = 140
   and    flex2.id_flex_code(+) = 'CAT#'
   and    flex2.id_flex_num(+) = 101
   and    flex2.application_column_name(+) = 'SEGMENT2'
   and    flex2.enabled_flag (+)        = 'Y';

   CURSOR C_Parameters (C_Book_type_code     VARCHAR2,
           			C_From_Period        VARCHAR2,
		           	C_To_Period          VARCHAR2 ) is
   select dp1.period_open_date,
	  dp1.period_counter,
	  dp1.calendar_period_open_date,
	  nvl(dp2.period_close_date, sysdate),
	  dp2.period_counter,
	  flex1.application_column_name,
	  nvl(flex2.application_column_name, ' ')
   from   fa_deprn_periods dp1,
          fa_deprn_periods dp2,
	  fnd_id_flexs flexid,
	  fnd_id_flex_segments flex1,
	  fnd_id_flex_segments flex2
   where  dp1.book_type_code = C_book_type_code
   and    dp1.period_name = C_from_period
   and    dp2.book_type_code = dp1.book_type_code
   and    dp2.period_name = C_to_period
   and    flexid.application_id = 140
   and    flexid.id_flex_code  = 'CAT#'
   and    flex1.id_flex_code = flexid.id_flex_code
   and    flex1.application_id = 140
   and    flex1.id_flex_code = 'CAT#'
   and    flex1.id_flex_num = 101
   and    flex1.application_column_name = 'SEGMENT1'
   and    flex1.enabled_flag = 'Y'
   and    flex2.id_flex_code (+) = flexid.id_flex_code
   and    flex2.application_id(+) = 140
   and    flex2.id_flex_code(+) = 'CAT#'
   and    flex2.id_flex_num(+) = 101
   and    flex2.application_column_name(+) = 'SEGMENT2'
   and    flex2.enabled_flag (+) = 'Y';


begin
   -- Clean up the temporary Table
   delete from ja_au_srw_tax_deprn_tmp ;

   -- DBMS_OUTPUT.PUT_LINE ('Starting');

   -- Fetch the first category ID
   OPEN C_Get_First_Category;
   FETCH C_Get_First_Category INTO V_Cat_Temp;
   CLOSE C_Get_First_Category;

   -- Get the Parameters
   OPEN C_Parameters ( C_Book_Type_Code => V_Book_Type_code,
                       C_From_Period    => V_From_Period,
                       C_To_Period      => V_To_Period );
   FETCH C_Parameters INTO  v_from_date,
	  v_from_counter,
	  v_from_cal_date,
	  v_to_date,
	  v_to_counter,
	  v_col1,
	  v_col2;
   CLOSE C_Parameters;

   -- DBMS_OUTPUT.PUT_LINE ('Found Parameters');

   -- Now get the category details
   OPEN C_Get_Category (V_Category_ID,V_cat_temp);
   FETCH C_Get_Category INTO V_Category;
   CLOSE C_Get_Category;



/* Select candidate records between selected periods */

   insert into ja_au_srw_tax_deprn_tmp
      ( asset_id,
 	asset_number,
 	asset_desc,
 	category_id,
 	category_number,
 	category_desc,
 	original_cost_start,
 	cost_start,
 	original_cost_end,
 	cost_end,
 	in_service,
 	deprn_rate,
 	deprn_basis_rule,
      Created_by,
      Creation_date,
      last_update_date,
      last_update_login,
      last_updated_by
)
   select a.asset_id,
       a.asset_number,
       a.description,
       c.category_id,
       decode(v_col1,'SEGMENT7', c.segment7, 'SEGMENT6', c.segment6,
	      'SEGMENT5', c.segment5, 'SEGMENT4', c.segment4, 'SEGMENT3',
	      c.segment3, 'SEGMENT2', c.segment2, c.segment1) ||
       decode(v_col2,' ','','-') ||
       decode(v_col2,'SEGMENT7', c.segment7, 'SEGMENT6', c.segment6,
	      'SEGMENT5', c.segment5, 'SEGMENT4', c.segment4, 'SEGMENT3',
	      c.segment3, 'SEGMENT2', c.segment2, 'SEGMENT1', c.segment1, ''),
       c.description,
       b1.original_cost,
       b1.cost,
       b2.original_cost,
       b2.cost,
       b2.date_placed_in_service,
       decode(nvl(b2.adjusted_rate,0),
	      0, decode(b2.life_in_months, 0, 0, null, 0,
		        1/(b2.life_in_months/12)),
              b2.adjusted_rate) * 100,
       m.deprn_basis_rule,
       uid,
       sysdate,
       sysdate ,
       uid,
       uid
from   fa_books b1,
       fa_books b2,
       fa_additions a,
       fa_categories c,
       fa_methods m
where  b1.asset_id = a.asset_id
and    b1.book_type_code = v_book_type_code
and    b1.date_effective =
          (select min(bk.date_effective)
	   from   fa_books bk
	   where  bk.asset_id = a.asset_id
	   and    bk.book_type_code = v_book_type_code
	   and    nvl(bk.date_ineffective,sysdate+2) > v_from_date
	   and    bk.date_effective <= v_to_date)
and    nvl(b1.date_ineffective,sysdate+2) > v_from_date
and    b2.asset_id = a.asset_id
and    b2.book_type_code = v_book_type_code
and    b2.date_effective <= v_to_date
and    nvl(b2.date_ineffective, sysdate+2) > v_to_date
and    m.method_code(+) = b2.deprn_method_code
and    nvl(m.life_in_months(+),1) = nvl(b2.life_in_months,1)
and    c.category_id = a.asset_category_id
and    decode(v_col1, 'SEGMENT7', c.segment7, 'SEGMENT6', c.segment6,
	      'SEGMENT5', c.segment5, 'SEGMENT4', c.segment4,
	      'SEGMENT3', c.segment3, 'SEGMENT2', c.segment2, c.segment1) LIKE
       decode(substr(v_category,1,(INSTR(v_category,'-')-1)),
	      'ALL', '%',
	      '', decode(v_category, '', '%', 'ALL', '%', v_category),
	      substr(v_category,1,(instr(v_category,'-')-1)))
and    (v_col2 = ' ' or
	decode(v_col2, 'SEGMENT7', c.segment7, 'SEGMENT6', c.segment6,
               'SEGMENT5', c.segment5, 'SEGMENT4', c.segment4,
	       'SEGMENT3', c.segment3, 'SEGMENT2', c.segment2, c.segment1) LIKE
        decode(nvl(INSTR(v_category, '-'),'0'), 0, '%',
	       decode(substr(v_category,(nvl(instr(v_category,'-'),0)+1)),
	       'ALL','%', '', '%',
	       substr(v_category,(nvl(instr(v_category,'-'),0)+1)))));

     -- DBMS_OUTPUT.PUT_LINE ('Found '||to_char(SQL%ROWCOUNT)||' Candidate Records');

/* Select the maximum date retired prior to the end of the chosen interval */

update ja_au_srw_tax_deprn_tmp t
set date_retired =
(select max(r.date_retired)
 from fa_transaction_headers th,
      fa_retirements r
 where th.asset_id = t.asset_id
 and   th.book_type_code = v_book_type_code
 and   th.date_effective <= v_to_date
 and   th.transaction_type_code = 'FULL RETIREMENT'
 and   not exists (select '1'
		   from fa_transaction_headers th2
		   where th2.asset_id = t.asset_id
		   and th2.book_type_code = v_book_type_code
		   and th2.date_effective <= v_to_date
                   and th2.transaction_header_id > th.transaction_header_id
		   and th2.transaction_type_code = 'REINSTATEMENT')
 and   r.transaction_header_id_in = th.transaction_header_id);

/* Delete records where the maximum date retired is less than the start of the
   interval */

delete from ja_au_srw_tax_deprn_tmp t
where t.date_retired < v_from_cal_date;

/* Select the assets that were retired in the interval and calculate the net
   book value */

update ja_au_srw_tax_deprn_tmp t
set (date_retired, net_book_value) =
(select max(r.date_retired), sum(nvl(r.nbv_retired,0))
 from fa_transaction_headers th,
      fa_retirements r
 where th.asset_id = t.asset_id
 and   th.book_type_code = v_book_type_code
 and   th.date_effective between v_from_date and v_to_date
 and   th.transaction_type_code in ('PARTIAL RETIREMENT','FULL RETIREMENT')
 and   not exists (select '1'
		   from fa_transaction_headers th2
		   where th2.asset_id = t.asset_id
		   and th2.book_type_code = v_book_type_code
		   and th2.date_effective between v_from_date and v_to_date
		   and th2.transaction_header_id > th.transaction_header_id
		   and th2.transaction_type_code = 'REINSTATEMENT')
 and   r.transaction_header_id_in = th.transaction_header_id);

/* Select the depreciation reserve at the start of the interval */

update ja_au_srw_tax_deprn_tmp t
set deprn_rsrve_start =
(select deprn_reserve
 from   fa_deprn_summary ds
 where  ds.asset_id = t.asset_id
 and    ds.period_counter =
		  (select max(dp2.period_counter)
		   from   fa_deprn_summary ds2,
			  fa_deprn_periods dp2
                   where  ds2.asset_id = t.asset_id
		   and    ds2.period_counter = dp2.period_counter
		   and    ds2.book_type_code = v_book_type_code
		   and    dp2.book_type_code = v_book_type_code
		   and    dp2.period_counter < v_from_counter)
 and    ds.book_type_code = v_book_type_code);

/* Select the depreciation reserve at the end of the interval */

update ja_au_srw_tax_deprn_tmp t
set deprn_rsrve_end =
(select deprn_reserve
 from   fa_deprn_summary ds
 where  ds.asset_id = t.asset_id
 and    ds.period_counter =
		  (select max(dp2.period_counter)
		   from   fa_deprn_summary ds2,
			  fa_deprn_periods dp2
                   where  ds2.asset_id = t.asset_id
		   and    ds2.period_counter = dp2.period_counter
		   and    ds2.book_type_code = v_book_type_code
		   and    dp2.book_type_code = v_book_type_code
		   and    dp2.period_counter between v_from_counter and
			  v_to_counter)
 and    ds.book_type_code = v_book_type_code);

/* Calculate the depreciation over the interval */

   update ja_au_srw_tax_deprn_tmp t
      set deprn_amount =
         (select sum(ds.deprn_amount)
          from fa_deprn_summary ds,
          fa_deprn_periods dp
          where ds.asset_id = t.asset_id
          and   ds.period_counter = dp.period_counter
          and   ds.book_type_code = v_book_type_code
          and   dp.book_type_code = v_book_type_code
          and   dp.period_counter between v_from_counter and v_to_counter);

   -- Select the assets that were entered in the system
   -- between the given periods

   update ja_au_srw_tax_deprn_tmp t
      set addition_date =
         (select th.date_effective
          from   fa_transaction_headers th
          where  th.asset_id = t.asset_id
          and    th.book_type_code = v_book_type_code
          and    th.transaction_type_code = 'ADDITION'
          and    th.date_effective between v_from_date and v_to_date);

   -- Select the balancing charges applied to each asset
   update ja_au_srw_tax_deprn_tmp t
   set bal_chg_applied =
      (select sum(nvl(ap.bal_chg_applied,0))
      from ja_au_bal_chg_applied ap
      where ap.asset_id  = t.asset_id
       and   ap.book_type_code  = v_book_type_code);

   -- DBMS_OUTPUT.PUT_LINE ('JAAUFS32.sql Completed...');
end;

   /***********************************************************************
   PROCEDURE   	- JAAUFRET
   DESCRIPTION  - Stub Procedure to call the original retirements program
		  followed by the Calculcate Balancing charges program
   PARAMETERS   - List of Parameters
			NAME	IN/OUT	RANGE OF VALUES
			Book	IN	Book Type Code
			Period	IN	Financial Period
   CALLED       - List of Calling Code
   HISTORY	- Created  - 	10 July 1997 SGoggin
				Created Initial Release of Code
		  Modified -
   ************************************************************************/
   PROCEDURE JAAUFRET
               (ERRBUF 		OUT NOCOPY 	VARCHAR2,
   		RETCODE 	OUT NOCOPY 	VARCHAR2,
   		BOOK 			VARCHAR2,
    		PERIOD 			VARCHAR2) IS
      V_Req_id1   number;
      V_Req_id2   number;
      Dummy_Default Boolean Default FALSE;
      phase      varchar2(255);
      status     varchar2(255);
      dev_phase  varchar2(255);
      dev_status varchar2(255);
      message    varchar2(255);

     l_balancing_charge_flag   VARCHAR2(1);

   BEGIN

      -- JA_AU_FA_BAL_CHG_FLAG profile controls execution of this program.
      FND_PROFILE.GET('JA_AU_FA_BAL_CHG_FLAG',l_balancing_charge_flag);

      l_balancing_charge_flag := nvl(l_balancing_charge_flag,'N'); -- bug603639

      -- Bug 602113 must always submit FARET process
      V_Req_id1 := FND_REQUEST.SUBMIT_REQUEST(
            application => 'OFA',
            program     =>'JAAUFRET',
            description => fnd_message.get_string('JA','JA_AU_FRET_CAL_GAN_LSS'),
            argument1   => BOOK,
           argument2   => PERIOD);

      commit;
     IF l_balancing_charge_flag ='Y' and
        FND_CONCURRENT.WAIT_FOR_REQUEST ( V_Req_id1,10,0,phase,status,dev_phase,dev_status,message ) THEN
         V_Req_id2 := FND_REQUEST.SUBMIT_REQUEST(
            application => 'JA',
            program     =>'JAAUFCB',
            description => fnd_message.get_string('JA','JA_AU_FRET_CAL_BAL_CHG'),
            argument1   => BOOK,
            argument2   => PERIOD);
      END IF;

      errbuf := 'Submitted processes ' ||to_char(V_Req_id1)||' and '||to_char( V_Req_id2);
   END;



   /***********************************************************************
   PROCEDURE   	- Name
   DESCRIPTION  - Scans for asset retirements in the specified period and
		  Book,  then creates a Balancing charge Record
   PARAMETERS   - List of Parameters
			NAME	IN/OUT	RANGE OF VALUES
   CALLED       - List of Calling Code
			FORM
			REPORT
   HISTORY	- Created  - 	10 July 1997 SGoggin
				Created Initial Release of Code
		  Modified -
   ************************************************************************/
   PROCEDURE Calc_Bal_Chg
               (ERRBUF 		OUT NOCOPY 	VARCHAR2,
   		RETCODE 	OUT NOCOPY 	VARCHAR2,
   		BOOK 			VARCHAR2,
    		PERIOD 			VARCHAR2)  IS

      v_book_type_code 		varchar2(15) := (BOOK);
      v_period_name      	varchar2(15) := (PERIOD);
      v_recoupment		number  := 0;
      v_bal_chg_applied	   	number	:= 0;
      v_bal_chg_id     	   number(15);
      v_message                  varchar2(80);
      v_reinstatements 	   number  := 0;
      v_retirements    	   number  := 0;
      v_retirement_tot 	   number  := 0;

      V_Log_Out		   number := 1;
      V_out_out		   number := 2;
      V_Bal_Charge_Enabled varchar2(10) := 'N';

      -- Declare a cursor to extract retirement numbers which have
      -- had retirements or reinstatements.

      CURSOR	C_RETIREMENTS is
  	Select  distinct
	 	r.retirement_id   ,
                r.asset_id        ,
                r.status          ,
                r.date_retired    ,
         	nvl(r.gain_loss_amount,0) gain_loss_amount,
	 	nvl(r.cost_retired,0) - nvl(r.nbv_retired,0)  deprn_retired
	from    FA_DEPRN_PERIODS DP,
	 	FA_TRANSACTION_HEADERS TH,
	 	FA_RETIREMENTS R,
	 	FA_ADDITIONS A,
	 	FA_BOOKS B
	where   dp.period_name       = (v_period_name)

	and     dp.book_type_code    = v_book_type_code
	and     th.book_type_code    = v_book_type_code
        and     th.transaction_date_entered  >=dp.calendar_period_open_date
        and     th.transaction_date_entered  <=nvl(dp.calendar_period_close_date,th.date_effective)
        and     th.transaction_type_code in ('PARTIAL RETIREMENT',
				      	     'FULL RETIREMENT',
				      	     'REINSTATEMENT')
	and     th.transaction_header_id =
         	decode(th.transaction_type_code,
		   	'PARTIAL RETIREMENT',    r.transaction_header_id_in,
	           	'FULL RETIREMENT',       r.transaction_header_id_in,
                	/*  REINSTATEMENT  */    r.transaction_header_id_out)
	and     r.asset_id           = th.asset_id
	and     r.book_type_code     = v_book_type_code
	and     a.asset_id           = r.asset_id
	and     nvl(a.property_type_code,'xxxxxxxxx') <> 'DIV 10D'
					/* Exclude Div 10D buildings */
	and     b.asset_id           = r.asset_id
	and     b.date_ineffective   is null
	and     nvl(b.depreciate_flag,'zzz')    = 'YES';
					/* Only depreciable assets */

      CURSOR C_Bal_Chg_Retirements (C_Retirement_ID   NUMBER )IS
         select 	nvl(s.bal_chg_applied,0)
         from   	ja_au_bal_chg_source s
         where  	s.retirement_id = C_retirement_id;

      CURSOR C_Bal_Chg_Enabled (C_Book_Type_code VARCHAR2) IS
         SELECT BAL_CHARGE_ENABLED
	   FROM   JA_AU_FA_BOOK_CONTROLS
   	   WHERE  Book_Type_code = C_Book_Type_code;

   BEGIN

      -- Check if this is a Balancing Charge Book
      OPEN C_Bal_Chg_Enabled (V_Book_Type_code);
      FETCH C_Bal_Chg_Enabled into V_Bal_Charge_Enabled;
      IF C_Bal_Chg_Enabled%NOTFOUND or
         V_Bal_Charge_Enabled = 'NO' THEN
         close C_Bal_Chg_Enabled;
         errbuf := 'Balancing charge is disabled for '||V_Book_type_code;
      ELSE

      close C_Bal_Chg_Enabled;
      -- Send a message to the log file for this concurrent process;
      FND_FILE.Put_Line (V_Log_Out,'Calculate Balancing Charges Starting...');
      FND_FILE.Put_Line (V_Log_Out,'...BOOK is '||V_Book_Type_code||'   Period is '||V_Period_name);

      -- Loop for all retirements in the current period
      FOR C_Retirements_REC IN C_Retirements LOOP
         -- Send a status message to the log file.
         FND_FILE.Put_Line (V_Log_Out,'Processing Retirement for Asset '||to_char(C_Retirements_REC.Asset_id));

         -- Reset Data
         V_Recoupment := 0;
         V_Bal_Chg_Applied := 0;

         -- The retirement should have a status of PROCESSED or
         -- DELETED.  If Deleted, it's a reinstatement, so there
         -- will be no new recoupment of depreciation.
         -- But a Processed retirement will have a recoupment
         -- equal to the proportion of the Gain/Loss which is
         -- depreciation retired and subsequently recouped.

         if C_Retirements_REC.status <> 'DELETED'
            AND C_Retirements_REC.Gain_loss_amount > 0  then

            -- Recoupment amount is limited by the Deprn retired amount
            if C_Retirements_REC.gain_loss_amount >= C_Retirements_REC.deprn_retired then
               v_recoupment := C_Retirements_REC.deprn_retired;
            else
               v_recoupment := C_Retirements_REC.gain_loss_amount;
            end if;
         end if;
         FND_FILE.Put_Line (V_Log_Out,'...Recoupment is '||to_char(v_recoupment));

         -- Check if a Source Record for this retired asset already exists.
         -- If it does this means that this must be a reinstatement.
         -- The Source record needs to be deleted or updated.
         OPEN C_Bal_Chg_Retirements (C_Retirements_REC.Retirement_ID);
         FETCH C_Bal_Chg_Retirements INTO V_Bal_Chg_Applied;

         IF C_Bal_Chg_Retirements%NOTFOUND AND
            v_recoupment > 0 THEN

            -- There is no pre existing balancing charge source record therefore create one
            FND_FILE.Put_Line (V_Log_Out,'...Created New Balancing Charge Source of '||to_Char(v_recoupment));

            select  ja_au_bal_chg_source_s.nextval
            into    v_bal_chg_id
	    from 	sys.dual;


		insert into JA_AU_BAL_CHG_SOURCE
		(     	bal_chg_id,
      			book_type_code,
      			asset_id,
      			retirement_id,
      			last_update_date,
      			last_updated_by,
      			created_by,
      			creation_date,
      			last_update_login,
      			bal_chg_amount,
      			bal_chg_applied,
      			date_retired,
      			bal_chg_status)
 		values
 		(    	v_bal_chg_id,
      			v_book_type_code,
      			C_Retirements_REC.asset_id,
      			C_Retirements_REC.retirement_id,
      			sysdate,
      			uid,
      			uid,
      			sysdate,
      			uid,
      			v_recoupment,
      			0,
      			C_Retirements_REC.date_retired,
      			'N');              /*  Not applied balance  */

			v_retirements    := v_retirements    + 1;
			v_retirement_tot := v_retirement_tot +
					    v_recoupment;


         ELSIF C_Bal_Chg_Retirements%FOUND THEN
            -- There is already a source record
            IF v_recoupment = 0  and
               v_bal_chg_applied = 0 then
               -- No balancing charge applications so delete it
               FND_FILE.Put_Line (V_Log_Out,'...Deleted Balancing Charge Source ');

               -- Remove the Records
               DELETE FROM  ja_au_bal_chg_source s
               WHERE        s.retirement_id = C_Retirements_REC.retirement_id;

               -- Update the couter
               v_reinstatements := v_reinstatements + 1;

            ELSE
               FND_FILE.Put_Line (V_Log_Out,'...Updated Balancing Charge Source to '||to_Char(v_recoupment));
               -- The amount applied is > 0
               -- Update the Source record for this reinstatement.
               -- This should only ever be a full reversal of the
               -- balance charge for a reinstatement.  If it's not a
               -- reinstatement then this program must have been run
               -- twice, so the Source record is simply updated to
               -- the same value.

               update ja_au_bal_chg_source s
               set 	bal_chg_amount		= v_recoupment,
    			bal_chg_status       	=
			decode(sign(v_recoupment - v_bal_chg_applied),
			+1,
			decode(v_bal_chg_applied, 0,
			        'N',    /* Not applied balance charge  */
				      'P'),   /* Partially applied BC      */
				   0, 'F',    /* Fully applied        	   */
				  -1, 'R'),   /* Reversed balance charge   */
      				last_update_date 	= sysdate,
   				last_updated_by 	= uid,
      				last_update_login 	= uid
		where 	s.retirement_id    	= C_Retirements_REC.retirement_id;


			if v_recoupment = 0  then
			   	v_reinstatements := v_reinstatements + 1;
			end if;
            END IF;

         END IF;
            Close C_Bal_Chg_Retirements;


      END LOOP;

      FND_FILE.Put_Line (V_Log_Out,'Processing Complete.');

      FND_FILE.Put_Line (V_out_Out,'Calculate Balancing Charges.');
      FND_FILE.Put_Line (V_out_Out,null);
      FND_FILE.Put_Line (V_out_Out,null);
      FND_FILE.Put_Line (V_out_Out,null);

  /* Commented By Sierra - 03/03/99 for Rel 11.5 Multi Radix Issue fixes */

/*
      FND_FILE.Put_Line (V_out_Out,'Retirements:     '||to_char(v_retirements, '9,999,990') ||
		   	' Balancing Charges generated. '  ||to_char(v_retirement_tot, '$9,999,999,990') ||
			' value.');
*/

      FND_FILE.Put_Line (V_out_Out,'Retirements:     '||to_char(v_retirements, '9G999G990') ||
		   	' Balancing Charges generated. '  ||to_char(v_retirement_tot, '$9G999G999G990') ||
			' value.');
      FND_FILE.Put_Line (V_out_Out,null);

  /* Commented By Sierra - 03/03/99 for Rel 11.5 Multi Radix Issue fixes */

/*
      FND_FILE.Put_Line (V_out_Out,'Reinstatements:  '||to_char(v_reinstatements, '9,999,990') ||
		   	' Balancing Charges reversed.');
      errbuf := 'Retirements:     '||to_char(v_retirements, '9,999,990') ||
		   	' Balancing Charges generated. '  ||to_char(v_retirement_tot, '$9,999,999,990') ||
			' value.';
*/

      FND_FILE.Put_Line (V_out_Out,'Reinstatements:  '||to_char(v_reinstatements, '9G999G990') ||
		   	' Balancing Charges reversed.');
      errbuf := 'Retirements:     '||to_char(v_retirements, '9G999G990') ||
		   	' Balancing Charges generated. '  ||to_char(v_retirement_tot, '$9G999G999G990') ||
			' value.';

   END IF;
      EXCEPTION when others then
         FND_FILE.Put_Line (V_out_Out,'Error ' || to_char(sqlcode, '999999')||' '|| sqlerrm);

   END;

END;


/
