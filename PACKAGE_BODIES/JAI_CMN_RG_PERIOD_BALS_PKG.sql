--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RG_PERIOD_BALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RG_PERIOD_BALS_PKG" AS
/* $Header: jai_cmn_rg_pbal.plb 120.4 2007/05/04 04:51:42 bduvarag ship $ */

 /* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_cmn_rg_pbal -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.
17/04/2007	  bduvarag for the Bug#5989740, file version 120.11
		  Forward porting the changes done in 11i bug#5907436

*/

procedure consolidate_balances
  (
    errbuf OUT NOCOPY varchar2,
    retcode OUT NOCOPY varchar2,
    p_period_type             in  varchar2,
    p_register_type           in  varchar2,
    pv_consolidate_till        in   varchar2 /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
  )
  is

   /* Added by Ramananda for bug#4407165 */
   lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_period_bals_pkg.consolidate_balances';

    ld_consolidate_from       date;
    ld_consolidate_till       date;

    ld_start_date             date;
    ld_end_date               date;
    ln_period_opening_bal     number;
    ln_period_closing_bal     number;
    ln_fin_year               JAI_CMN_RG_PERIOD_BALS.fin_year%type;
    lv_register_type          JAI_CMN_RG_PERIOD_BALS.register_type%type;

    ln_previous_closing_bal   number;
    ld_previous_end_date      date;

    ln_total_rg_amount        number;
    r_last_record             JAI_CMN_RG_PERIOD_BALS%rowtype;

   /* rallamse bug#4336482 */
    p_consolidate_till DATE;  -- DEFAULT fnd_date.canonical_to_date(pv_consolidate_till) File.Sql.35 by Brathod
   /* End of Bug# 4336482 */

    lc_end_date               date ; -- := to_date('31-MAR-2003', 'dd-mon-yyyy') File.Sql.35 by Brathod

    CURSOR c_last_record(cp_organization_id IN NUMBER, cp_location_id IN NUMBER, cp_register_type IN VARCHAR2) IS
      SELECT  *
      FROM    JAI_CMN_RG_PERIOD_BALS
      WHERE   organization_id = cp_organization_id
      AND     location_id = cp_location_id
      AND     register_type = cp_register_type
      AND     (start_date, end_date) =
              (
                SELECT  max(start_date), max(end_date)
                FROM    JAI_CMN_RG_PERIOD_BALS
                WHERE   organization_id = cp_organization_id
                AND     location_id = cp_location_id
                AND     register_type = cp_register_type
        );

    CURSOR c_total_rg_amount
    (cp_organization_id in number, cp_location_id in number, cp_register_type in varchar2,
     cp_start_date in date, cp_end_date in date)
     IS
     /* bgowrava for forward porting bug#5674376. additional_cvd column added */
      SELECT sum(nvl(cr_basic_ed,0)+ nvl(cr_additional_ed,0) + nvl(cr_other_ed,0) + nvl(cr_additional_cvd,0)
                - nvl(dr_basic_ed,0) - nvl(dr_additional_ed,0) - nvl(dr_other_ed,0) - nvl(dr_additional_cvd,0)) total_modvat_amount,
              min(fin_year)
      FROM    JAI_CMN_RG_23AC_II_TRXS
      WHERE   organization_id = cp_organization_id
      AND     location_id = cp_location_id
      AND     register_type = cp_register_type
      AND     trunc(creation_date) between cp_start_date and cp_end_date
      and     period_balance_id is null
      and     inventory_item_id <> 0;


      /* following cursors added by bgowrava for forward porting bug#5674376 */
			    CURSOR c_total_cess_amount
			    (cp_organization_id in number, cp_location_id in number, cp_register_type in varchar2,
			     cp_start_date in date, cp_end_date in date, cp_tax_type in varchar2)
			     IS
			      SELECT sum(nvl(b.credit,0) - nvl(b.debit,0)) total_cess
			      FROM    JAI_CMN_RG_23AC_II_TRXS  a, JAI_CMN_RG_OTHERS b
			      WHERE   a.organization_id = cp_organization_id
			      AND     a.location_id = cp_location_id
			      AND     a.register_type = cp_register_type
			      AND     trunc(a.creation_date) between cp_start_date and cp_end_date
			      and     a.period_balance_id is null
			      and     a.inventory_item_id <> 0
			      and b.source_register_id = a.register_id
			      and b.source_type = 1
			      and b.tax_type = cp_tax_type;

			      CURSOR c_get_fin_year(cp_organization_id IN NUMBER, cp_period_start_date in date) IS
			        SELECT fin_year
			        FROM JAI_CMN_FIN_YEARS
			        WHERE organization_id = cp_organization_id
			        AND cp_period_start_date between fin_year_start_date and fin_year_end_date;
    /* end bgowrava for forward porting bug#5674376 */

CURSOR    c_min_rg_date( cp_organization_id  IN NUMBER,
                             cp_location_id      IN NUMBER,
                             cp_register_type    IN VARCHAR2,
                             cp_consolidate_till IN DATE)/*bug 5241875.Added
this parameter*/
        IS
    SELECT min(creation_date)
      FROM JAI_CMN_RG_23AC_II_TRXS
     WHERE organization_id = cp_organization_id
       AND location_id = cp_location_id
       AND register_type = cp_register_type
       AND period_balance_id is null
       AND trunc(creation_date) <= cp_consolidate_till;/*bug 5241875*/

    cursor    c_get_period_balance_id is
      select  JAI_CMN_RG_PERIOD_BALS_S.nextval
      from    dual;

    ln_period_balance_id            JAI_CMN_RG_PERIOD_BALS.period_balance_id%type;
    ln_no_balances_updated          number;

    ln_cumulative_adjustment        number := 0;

     /* Start bgowrava for forward porting bug#5674376 */
		ln_exc_edu_cess_cl_bal      number;
		ln_cvd_edu_cess_cl_bal      number;
		ln_prev_exc_edu_cess_cl_bal      number;
		ln_prev_cvd_edu_cess_cl_bal      number;
		ln_total_exc_edu_cess       number;
    ln_total_cvd_edu_cess       number;
    /*end bgowrava for forward porting bug#5674376 */
/*Bug 5989740 bduvarag start*/
    ln_sh_exc_edu_cess_cl_bal           number;
		ln_sh_cvd_edu_cess_cl_bal           number;
		ln_prev_sh_exc_edu_cess_cl_bal      number;
		ln_prev_sh_cvd_edu_cess_cl_bal      number;
		ln_total_sh_exc_edu_cess            number;
    ln_total_sh_cvd_edu_cess            number;
/*Bug 5989740 bduvarag end*/
  BEGIN

  lc_end_date          := to_date(' 31/03/2003', 'dd/mm/yyyy');     -- File.Sql.35 by Brathod
  p_consolidate_till  := fnd_date.canonical_to_date(pv_consolidate_till);  -- File.Sql.35 by Brathod

/*--------------------------------------------------------------------------------------------------------------------------------
Change History for Filename - jai_cmn_rg_period_bals_pkg.sql
S.No   dd/mm/yyyy  Author and Details
----------------------------------------------------------------------------------------------------------------------------------
1      14/08/2004  Vijay Shankar for Bug# 3810344 Version : 115.1
                    Created the Package to populate data into JAI_CMN_RG_PERIOD_BALS
                    Huge Dependency
                    The Whole Patch should accompany this patch.

2      28/04/2005  rallamse for Bug#4336482, Version 116.1
            For SEED there is a change in concurrent "JAINRGPB" to use FND_STANDARD_DATE with STANDARD_DATE format
            Procedure  ja_in_rg_period_balance_pkg.consolidate_balances signature modified by converting p_consolidate_till of DATE datatype
            to pv_consolidate_till of varchar2 datatype. The varchar2 values are converted to DATE fromat
            using fnd_date.canonical_to_date function.


3.    26-FEB-2007   SSAWANT , File version 120.2
		    Forward porting the change in 11.5 bug  5060037 to R12 bug no 5241875.
		    Issue:
                      The concurrent is poulating wrong balances when it is run for the first time.
                     Fix:
                       Consider the following case:
                         A first record created in JAI_CMN_RG_23AC_II_TRXS table is in 2nd August 2006.
                         Now if we run the RG23 part II report it would ask the user to run
                         the "India RG Period balance calculation" concurrent till July 31. If we run this concurrent
                         it would do the following steps:

                             It would fetch the previous balances which are NULL in our case.
                             Since these are NULL it would get the minimum of creation date using c_min_rg_date cursor.
                             In our case it would be 2nd august.
                             So it would get the sum of the transaction amounts in the month of august and populate
                             the balances for august which is wrong.
                             It should populate 0 balance for July in our case.
                             So added a check in cursor c_min_rg_date to fetch the minimum of creation date of only those
                             records which are created before the consolidate till date.
                             So in our case the minimum of creation date of only those records which are created before
                             31st July would be NULL and so the start date would be taken as 1 March 2003 and
                             end date as 31 March 2003 as per existing code. So the balances fetched would be zero for
                             July and would be populated as zero.

4.  28-FEB-2007   bgowrava for forward porting bug#5674376. File Version 120.3
                 Issue:
                 Rounding entries are not consolidated properly when generated in next month.
                 Fix:
                 In consolidate_balances procedure cursor is used to fetch all the rounding entries generated
                 before the consolidate till date. This is wrong as all the rounding entries should be consolidated
                 even if they are generated after the consolidate till date. So commented a condition in the
                 cursor to achieve this.

                 cbabu Implemented the functionality for CESS balances
                 - added required code in consolidate_balances and adjust_rounding
                 - New function get_cess_opening_balance is created. this is used in report for getting the balances


                Dependancy due to this bug: Yes (introduced new columns for cess balances calculation)

--------------------------------------------------------------------------------------------------------------------------------*/

    IF p_consolidate_till <> LAST_DAY(p_consolidate_till) THEN
      FND_FILE.put_line( FND_FILE.log, 'Please enter the last day of month for RG Period Balance consolidation');
      retcode := '2';
      RETURN;
    ELSIF p_consolidate_till >= trunc(sysdate) THEN
      FND_FILE.put_line( FND_FILE.log, 'Consolidate Till value cannot be more than or equal to SYSTEM date');
      retcode := '2';
      RETURN;
    END IF;

    IF p_consolidate_till IS NULL THEN
      ld_consolidate_till := to_date('31/03/2004', 'dd/mm/yyyy');
    ELSE
      ld_consolidate_till := p_consolidate_till;
    END IF;

    IF p_register_type = 'A' THEN
      lv_register_type := 'RG23A';
    ELSIF p_register_type = 'C' THEN
      lv_register_type := 'RG23C';
    ELSE
      lv_register_type := 'XXX';
    END IF;

    FOR org IN (select    organization_id, location_id
                from      JAI_CMN_INVENTORY_ORGS
                where     location_id > 0
                order by  organization_id, location_id)
    LOOP

      r_last_record           := NULL;
      ld_previous_end_date    := NULL;
      ln_previous_closing_bal := 0;

      /* bgowrava for forward porting bug#5674376 */
			ln_prev_exc_edu_cess_cl_bal := 0;
			ln_prev_cvd_edu_cess_cl_bal := 0;
/*Bug 5989740 bduvarag*/
      ln_prev_sh_exc_edu_cess_cl_bal := 0;
      ln_prev_sh_cvd_edu_cess_cl_bal := 0;



      OPEN c_last_record(org.organization_id, org.location_id, lv_register_type);
      FETCH c_last_record INTO r_last_record;
      CLOSE c_last_record;

      IF r_last_record.opening_balance IS NULL THEN

OPEN c_min_rg_date(org.organization_id, org.location_id,
p_register_type,ld_consolidate_till);/*for bug 5241875*/
        FETCH c_min_rg_date INTO ld_previous_end_date;
        CLOSE c_min_rg_date;

        IF ld_previous_end_date IS NOT NULL THEN
          -- this will give 30-NOV-2004 if min(creation_date) is >= '1-DEC-2004' and <= '31-DEC-2004'
          ld_previous_end_date    := trunc(ld_previous_end_date, 'MM')-1;
        ELSE
          ld_previous_end_date    := LC_END_DATE;
        END IF;
        ln_previous_closing_bal := 0;
         /* bgowrava for forward porting bug#5674376 */
				ln_prev_exc_edu_cess_cl_bal := 0;
				ln_prev_cvd_edu_cess_cl_bal := 0;
	/*Bug 5989740 bduvarag*/
        ln_prev_sh_exc_edu_cess_cl_bal := 0;
        ln_prev_sh_cvd_edu_cess_cl_bal := 0;


      ELSIF r_last_record.end_date >= ld_consolidate_till THEN

        FND_FILE.put_line( FND_FILE.log, 'Balances have already been consolidated till '||r_last_record.end_date
          ||' for organization '||org.organization_id||' and location '||org.location_id
        );
        GOTO next_org;

      ELSE

        ld_previous_end_date      := r_last_record.end_date;
        ln_previous_closing_bal   := r_last_record.closing_balance;
        /* bgowrava for forward porting bug#5674376 */
				ln_prev_exc_edu_cess_cl_bal := nvl(r_last_record.exc_edu_cess_cl_bal,0);
        ln_prev_cvd_edu_cess_cl_bal := nvl(r_last_record.cvd_edu_cess_cl_bal,0);
/*Bug 5989740 bduvarag*/
		ln_prev_sh_exc_edu_cess_cl_bal := nvl(r_last_record.sh_exc_edu_cess_cl_bal,0);
        ln_prev_sh_cvd_edu_cess_cl_bal := nvl(r_last_record.sh_cvd_edu_cess_cl_bal,0);

      END IF;

      LOOP

        ld_start_date         := ld_previous_end_date + 1;
        ld_end_date           := last_day(ld_start_date);
        ln_period_opening_bal := ln_previous_closing_bal;

        ln_total_rg_amount    := 0;
        ln_fin_year           := NULL;

        OPEN c_total_rg_amount(org.organization_id, org.location_id, p_register_type, ld_start_date, ld_end_date);
        FETCH c_total_rg_amount INTO ln_total_rg_amount, ln_fin_year;
        CLOSE c_total_rg_amount;

        ln_period_closing_bal := ln_period_opening_bal + nvl(ln_total_rg_amount, 0);

        /* start, bgowrava for forward porting bug#5674376 */
				 if ln_fin_year is null then
				   OPEN c_get_fin_year(org.organization_id, ld_start_date);
				   FETCH c_get_fin_year INTO ln_fin_year;
				   CLOSE c_get_fin_year;
				 end if;

				 OPEN c_total_cess_amount(org.organization_id, org.location_id, p_register_type,
				       ld_start_date, ld_end_date, JAI_CONSTANTS.TAX_TYPE_EXC_EDU_CESS);/*Bug 5989740 bduvarag*/
				 FETCH c_total_cess_amount INTO ln_total_exc_edu_cess;
				 CLOSE c_total_cess_amount;
				 ln_exc_edu_cess_cl_bal := ln_prev_exc_edu_cess_cl_bal + nvl(ln_total_exc_edu_cess, 0);

				 OPEN c_total_cess_amount(org.organization_id, org.location_id, p_register_type,
				       ld_start_date, ld_end_date, JAI_CONSTANTS.TAX_TYPE_CVD_EDU_CESS);/*Bug 5989740 bduvarag*/
				 FETCH c_total_cess_amount INTO ln_total_cvd_edu_cess;
				 CLOSE c_total_cess_amount;
				 ln_cvd_edu_cess_cl_bal := ln_prev_cvd_edu_cess_cl_bal + nvl(ln_total_cvd_edu_cess, 0);
        /* end, bgowrava for forward porting bug#5674376 */
        /*Bug 5989740 bduvarag start*/
	        OPEN c_total_cess_amount(org.organization_id, org.location_id, p_register_type,
              ld_start_date, ld_end_date, JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS);
        FETCH c_total_cess_amount INTO ln_total_sh_exc_edu_cess;
        CLOSE c_total_cess_amount;
        ln_sh_exc_edu_cess_cl_bal := ln_prev_sh_exc_edu_cess_cl_bal + nvl(ln_total_sh_exc_edu_cess, 0);

        OPEN c_total_cess_amount(org.organization_id, org.location_id, p_register_type,
              ld_start_date, ld_end_date, JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS);
        FETCH c_total_cess_amount INTO ln_total_sh_cvd_edu_cess;
        CLOSE c_total_cess_amount;
        ln_sh_cvd_edu_cess_cl_bal := ln_prev_sh_cvd_edu_cess_cl_bal + nvl(ln_total_sh_cvd_edu_cess, 0);
/*Bug 5989740 bduvarag end*/
        ln_period_balance_id:= null;
        open  c_get_period_balance_id;
        fetch c_get_period_balance_id into ln_period_balance_id;
        close c_get_period_balance_id;


        insert into JAI_CMN_RG_PERIOD_BALS
        (
          period_balance_id,
          organization_id,
          location_id,
          register_type,
          start_date,
          end_date,
          fin_year,
          opening_balance,
          closing_balance,
          misc_adjustment,
          rounding_adjustment,
          cumulative_misc_adjustment,
          cumulative_rounding_adjustment,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
           /*following columns added by bgowrava for forward porting bug#5674376 */
					, exc_edu_cess_cl_bal
					, exc_edu_cess_adj
					, exc_edu_cess_adj_op_bal
					, cvd_edu_cess_cl_bal
					, cvd_edu_cess_adj
          , cvd_edu_cess_adj_op_bal
	  /*Bug 5989740 bduvarag*/
	  					, sh_exc_edu_cess_cl_bal
					, sh_exc_edu_cess_adj
					, sh_exc_edu_cess_adj_op_bal
					, sh_cvd_edu_cess_cl_bal
					, sh_cvd_edu_cess_adj
          , sh_cvd_edu_cess_adj_op_bal


        )
        values
        (
          ln_period_balance_id,
          org.organization_id,
          org.location_id,
          lv_register_type,
          ld_start_date,
          ld_end_date,
          ln_fin_year,
          ln_period_opening_bal,
          ln_period_closing_bal,
          0,
          0,
          nvl(r_last_record.cumulative_misc_adjustment, 0)+ nvl(r_last_record.misc_adjustment, 0),
          nvl(r_last_record.cumulative_rounding_adjustment, 0)+nvl(r_last_record.rounding_adjustment, 0),
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id
          /*following columns added by bgowrava for forward porting bug#5674376 */
					, ln_exc_edu_cess_cl_bal
					, 0
					, nvl(r_last_record.exc_edu_cess_adj_op_bal,0) + nvl(r_last_record.exc_edu_cess_adj,0)
					, ln_cvd_edu_cess_cl_bal
					, 0
          , nvl(r_last_record.cvd_edu_cess_adj_op_bal,0) + nvl(r_last_record.cvd_edu_cess_adj,0)
	  /*Bug 5989740 bduvarag*/
	            , ln_sh_exc_edu_cess_cl_bal
          , 0
          , nvl(r_last_record.sh_exc_edu_cess_adj_op_bal,0) + nvl(r_last_record.sh_exc_edu_cess_adj,0)
          , ln_sh_cvd_edu_cess_cl_bal
          , 0
          , nvl(r_last_record.sh_cvd_edu_cess_adj_op_bal,0) + nvl(r_last_record.sh_cvd_edu_cess_adj,0)

        );

        -- Punch the PERIOD_BALANCE_ID aginst all the records that have been considered
        -- for consolidation
        update  JAI_CMN_RG_23AC_II_TRXS
        set     period_balance_id = ln_period_balance_id
        WHERE   organization_id = org.organization_id
        AND     location_id = org.location_id
        AND     register_type = p_register_type
        AND     trunc(creation_date) between ld_start_date and ld_end_date
        and     period_balance_id is null
        and     inventory_item_id <> 0;


        EXIT WHEN ld_end_date >= ld_consolidate_till;

        ld_previous_end_date    := ld_end_date;
        ln_previous_closing_bal := ln_period_closing_bal;


        /* bgowrava for forward porting bug#5674376 */
        ln_prev_exc_edu_cess_cl_bal := ln_exc_edu_cess_cl_bal;
        ln_prev_cvd_edu_cess_cl_bal := ln_cvd_edu_cess_cl_bal;
/*Bug 5989740 bduvarag*/
        ln_prev_sh_exc_edu_cess_cl_bal := ln_sh_exc_edu_cess_cl_bal;
        ln_prev_sh_cvd_edu_cess_cl_bal := ln_sh_cvd_edu_cess_cl_bal;

      END LOOP;

      <<next_org>>
      NULL;

    END LOOP;

    -- loop thru all the rounding entries in the register that has not been consolidated.
    for cur_rounding_rec in
    (
    select register_id
    from   JAI_CMN_RG_23AC_II_TRXS
    where  inventory_item_id = 0
    and    period_balance_id is null
    and    register_type = p_register_type  /* added by bgowrava for forward porting bug#5674376*/
    --and    trunc(creation_date) <= ld_consolidate_till /*commented by bgowrava for forward porting bug#5674376 */
    )
    loop

      /* Call the rounding adjustment proc for each of the rounding */
      ln_period_balance_id    := null;
      ln_no_balances_updated  := null;

      adjust_rounding
      (
      p_register_id_rounding  =>     cur_rounding_rec.register_id,
      p_period_balance_id     =>     ln_period_balance_id,
      p_no_balances_updated   =>     ln_no_balances_updated
      );

    end loop;

    /* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    errbuf  := sqlerrm;
    retcode := null;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

  END consolidate_balances;

  /* ****************************************************************************************** */

  procedure adjust_rounding
  (
  p_register_id_rounding      in        number,
  p_period_balance_id OUT NOCOPY number,
  p_no_balances_updated OUT NOCOPY number
  )
  is

   /* Added by Ramananda for bug#4407165 */
   lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_period_bals_pkg.adjust_rounding';

    cursor    c_get_parent_balance_id (cp_register_id number) is
      select  period_balance_id
      from    JAI_CMN_RG_23AC_II_TRXS
      where   register_id = cp_register_id;


    cursor c_get_round_amount(cp_register_id number) is
    /* bgowrava for forward porting bug#5674376. additional_cvd column added */
      select (nvl(cr_basic_ed,0)+ nvl(cr_additional_ed,0) + nvl(cr_other_ed,0)+ nvl(cr_additional_cvd,0)
              - nvl(dr_basic_ed,0) - nvl(dr_additional_ed,0) - nvl(dr_other_ed,0) - nvl(dr_additional_cvd,0)) rounding_amount
      from   JAI_CMN_RG_23AC_II_TRXS
      where  register_id = cp_register_id;

    cursor  c_get_start_balance_detail(cp_starting_period_balance_id number) is
      select  organization_id, location_id, register_type, end_date
      from    JAI_CMN_RG_PERIOD_BALS
      where   period_balance_id = cp_starting_period_balance_id;

    r_get_start_balance_detail      c_get_start_balance_detail%rowtype;
    ln_parent_register_id           JAI_CMN_RG_23AC_II_TRXS.register_id%type;
    ln_parent_period_balance_id     JAI_CMN_RG_PERIOD_BALS.period_balance_id%type;
    lv_error_flag                   varchar(1); -- := 'N' -- File.Sql.35 by Brathod
    lv_error_message                varchar2(100);
    ln_round_amount                 number;

    /* bgowrava for forward porting bug#5674376 */
		  ln_exc_edu_cess_adj number;
		  ln_cvd_edu_cess_adj number;
		  cursor c_get_cess_rnd_amount(cp_register_id number, cp_tax_type varchar2) is
		  select nvl(credit,0) - nvl(debit,0)
		  from   JAI_CMN_RG_OTHERS
		  where  source_register_id = cp_register_id
		  and source_type = 1
      and tax_type = cp_tax_type;
/*Bug 5989740 bduvarag*/
	  ln_sh_exc_edu_cess_adj number;
    ln_sh_cvd_edu_cess_adj number;


  begin
    lv_error_flag := 'N'; -- File.Sql.35 by Brathod
    ln_parent_register_id := null;
    ln_parent_register_id :=
      jai_rcv_rnd_pkg.get_parent_register_id(p_register_id_rounding);

    if ln_parent_register_id is null then
      lv_error_message := 'Parent register id not found, cannot proceed';
      lv_error_flag:='Y';
      fnd_file.put_line(fnd_file.log, lv_error_message);
      goto exit_adjust_rounding;
    end if;

    open  c_get_parent_balance_id(ln_parent_register_id);
    fetch c_get_parent_balance_id into ln_parent_period_balance_id;
    close c_get_parent_balance_id;

    if ln_parent_period_balance_id is null then
      lv_error_message := 'Parent has not been consolidated, cannot proceed';
      lv_error_flag:='Y';
      fnd_file.put_line(fnd_file.log, lv_error_message);
      goto exit_adjust_rounding;
    end if;

    /* get the round amount */
    open c_get_round_amount(p_register_id_rounding);
    fetch c_get_round_amount into ln_round_amount;
    close c_get_round_amount;

    /* Start bgowrava for forward porting bug#5674376 */
			ln_round_amount := nvl(ln_round_amount,0);

    open c_get_cess_rnd_amount(p_register_id_rounding,JAI_CONSTANTS.TAX_TYPE_EXC_EDU_CESS);/*Bug 5989740 bduvarag*/
			fetch c_get_cess_rnd_amount into ln_exc_edu_cess_adj;
			close c_get_cess_rnd_amount;

    open c_get_cess_rnd_amount(p_register_id_rounding, JAI_CONSTANTS.TAX_TYPE_CVD_EDU_CESS);/*Bug 5989740 bduvarag*/
			fetch c_get_cess_rnd_amount into ln_cvd_edu_cess_adj;
			close c_get_cess_rnd_amount;

			ln_exc_edu_cess_adj := nvl(ln_exc_edu_cess_adj,0);
			ln_cvd_edu_cess_adj := nvl(ln_cvd_edu_cess_adj,0);
    /* End bgowrava for forward porting bug#5674376 */
    /*Bug 5989740 bduvarag start*/
     open c_get_cess_rnd_amount(p_register_id_rounding, JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS);
     fetch c_get_cess_rnd_amount into ln_sh_exc_edu_cess_adj;
     close c_get_cess_rnd_amount;

     open c_get_cess_rnd_amount(p_register_id_rounding, JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS);
     fetch c_get_cess_rnd_amount into ln_sh_cvd_edu_cess_adj;
     close c_get_cess_rnd_amount;

    ln_sh_exc_edu_cess_adj := nvl(ln_sh_exc_edu_cess_adj,0);
    ln_sh_cvd_edu_cess_adj := nvl(ln_sh_cvd_edu_cess_adj,0);
/*Bug 5989740 bduvarag end*/
    if ln_round_amount = 0
    /* following cess conditions added by bgowrava for forward porting bug#5674376 */
		  and ln_exc_edu_cess_adj = 0
      and ln_cvd_edu_cess_adj = 0
/*Bug 5989740 bduvarag*/
	    and ln_sh_exc_edu_cess_adj = 0
      and ln_sh_cvd_edu_cess_adj = 0

    then
      /* There is no rounding amount, no need to adjust */
      fnd_file.put_line(fnd_file.log, '0 Zero rounding');
      goto exit_adjust_rounding;
    end if;

    /* update the parent_balance record */
    update JAI_CMN_RG_PERIOD_BALS
    set    rounding_adjustment = nvl(rounding_adjustment, 0) + ln_round_amount
        , exc_edu_cess_adj = nvl(exc_edu_cess_adj, 0) + ln_exc_edu_cess_adj  -- bgowrava for forward porting bug#5674376
        , cvd_edu_cess_adj = nvl(cvd_edu_cess_adj, 0) + ln_cvd_edu_cess_adj  -- bgowrava for forward porting bug#5674376
	        , sh_exc_edu_cess_adj = nvl(sh_exc_edu_cess_adj, 0) + ln_sh_exc_edu_cess_adj  /*Bug 5989740 bduvarag*/
				, sh_cvd_edu_cess_adj = nvl(sh_cvd_edu_cess_adj, 0) + ln_sh_cvd_edu_cess_adj  /*Bug 5989740 bduvarag*/

    where  period_balance_id = ln_parent_period_balance_id;

    /* punch the balance id in the register rounding record */
    update  JAI_CMN_RG_23AC_II_TRXS
    set     period_balance_id = ln_parent_period_balance_id
    where   register_id = p_register_id_rounding;

    /* update all subsequent balance records */
    open  c_get_start_balance_detail(ln_parent_period_balance_id);
    fetch c_get_start_balance_detail into r_get_start_balance_detail;
    close c_get_start_balance_detail;

    update JAI_CMN_RG_PERIOD_BALS
    set    cumulative_rounding_adjustment =
           nvl(cumulative_rounding_adjustment, 0) + ln_round_amount
           -- bgowrava for forward porting bug#5674376
					 , exc_edu_cess_adj_op_bal = nvl(exc_edu_cess_adj_op_bal, 0) + ln_exc_edu_cess_adj
           , cvd_edu_cess_adj_op_bal = nvl(cvd_edu_cess_adj_op_bal, 0) + ln_cvd_edu_cess_adj
	              , sh_exc_edu_cess_adj_op_bal = nvl(sh_exc_edu_cess_adj_op_bal, 0) + ln_sh_exc_edu_cess_adj/*Bug 5989740 bduvarag*/
           , sh_cvd_edu_cess_adj_op_bal = nvl(sh_cvd_edu_cess_adj_op_bal, 0) + ln_sh_cvd_edu_cess_adj/*Bug 5989740 bduvarag*/

    where  organization_id  = r_get_start_balance_detail.organization_id
    and    location_id      = r_get_start_balance_detail.location_id
    and    register_type    = r_get_start_balance_detail.register_type
    and    start_date       > r_get_start_balance_detail.end_date;

    << exit_adjust_rounding >>
    return;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    p_period_balance_id    := null;
    p_no_balances_updated  := null;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

end adjust_rounding;

 /* function created by bgowrava for forward porting bug#5674376 */
  function get_cess_opening_balance(
    cp_organization_id    in number,
    cp_location_id        in number,
    cp_register_type      in varchar2,
    cp_period_start_date  in date,
    cp_tax_type           in varchar2
  ) return number is

    /* get the period balance record of previous period to know the opening cess balances */
    cursor c_period_balance_record is
      select *
      from JAI_CMN_RG_PERIOD_BALS
      where organization_id = cp_organization_id
      and location_id = cp_location_id
      and register_type = cp_register_type
      and end_date = cp_period_start_date-1;
    r_period_bal_rec JAI_CMN_RG_PERIOD_BALS%rowtype;

    ln_cess_op_bal number;
        ln_sh_cess_op_bal number; /*Bug 5989740 bduvarag*/

  begin

    open c_period_balance_record;
    fetch c_period_balance_record into r_period_bal_rec;
    close c_period_balance_record;

    if r_period_bal_rec.period_balance_id is null then
      ln_cess_op_bal := 0;
    else
      if cp_tax_type = 'EXCISE_EDUCATION_CESS' then
        ln_cess_op_bal := r_period_bal_rec.exc_edu_cess_cl_bal;
      elsif cp_tax_type = 'CVD_EDUCATION_CESS' then
        ln_cess_op_bal := r_period_bal_rec.cvd_edu_cess_cl_bal;
/*Bug 5989740 bduvarag start*/
	      elsif cp_tax_type = JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS then
        ln_cess_op_bal := r_period_bal_rec.sh_exc_edu_cess_cl_bal;
      elsif cp_tax_type = JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS then
        ln_cess_op_bal := r_period_bal_rec.sh_cvd_edu_cess_cl_bal;
/*Bug 5989740 bduvarag end*/
      else
        ln_cess_op_bal := 0;
      end if;
    end if;

    return ln_cess_op_bal;

  end get_cess_opening_balance;

end jai_cmn_rg_period_bals_pkg;

/
