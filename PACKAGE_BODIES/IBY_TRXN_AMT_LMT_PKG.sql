--------------------------------------------------------
--  DDL for Package Body IBY_TRXN_AMT_LMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_TRXN_AMT_LMT_PKG" as
/*$Header: ibytxnab.pls 120.3.12000000.2 2007/09/06 09:56:06 lmallick ship $*/

    G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.iby_trxn_amt_lmt_pkg';

    procedure eval_factor
	(
	i_ecappid	IN	iby_trxn_summaries_all.ecappid%TYPE,
	i_payeeid	IN	iby_trxn_summaries_all.payeeid%TYPE,
	i_amount	IN	iby_trxn_summaries_all.amount%TYPE,
	i_instrid	IN	iby_trxn_summaries_all.payerinstrid%TYPE,
	i_ccNumber	IN	iby_trxn_summaries_all.instrnumber%TYPE,
	i_master_key	IN	iby_payee.master_key%TYPE,
	o_score		OUT NOCOPY INTEGER
	)
    IS

    l_payeeid varchar2(80);
    l_fromDate date;
    l_max_amount number;
    l_purchases_amount number;
    l_purchases_counter NUMBER;
    l_duration int;
    l_duration_type varchar2(10);
    l_count integer;
    l_ccnum_hash iby_trxn_summaries_all.instrnum_hash%TYPE;
    l_ccnum_obfs iby_trxn_summaries_all.instrnumber%TYPE;

    cursor c_get_config(ci_payeeid varchar2) is
    select duration, duration_type, amount
    from iby_irf_trxn_amt_limit
    where ( payeeid = ci_payeeid ) or
          ( payeeid is null and ci_payeeid is null);

    CURSOR c_get_fop_instrnum(
		     ci_payeeid iby_trxn_summaries_all.payeeid%TYPE,
                     ci_ccNumber varchar2,
		     ci_ccNumHash iby_trxn_summaries_all.instrnum_hash%TYPE,
                     ci_fromDate date
		    ) IS
    SELECT NVL(sum(amount),0)
	FROM iby_trxn_summaries_all tx
	WHERE ((ci_ccNumber = instrNumber) OR (ci_ccNumHash = instrnum_hash))
	   AND reqdate >= ci_fromDate
           AND reqType = 'ORAPMTREQ'
	   AND (status IN (0,11,100,111))
           AND payeeid = ci_payeeid;

     CURSOR c_get_fop_instrid(
		     ci_payeeid iby_trxn_summaries_all.payeeid%TYPE,
		     ci_instrid int,
                     ci_fromDate date
		    ) IS
     SELECT NVL(sum(amount),0)
	FROM iby_trxn_summaries_all tx
	WHERE (ci_instrid = payerInstrid)
          AND reqdate >= ci_fromDate
          AND reqType = 'ORAPMTREQ'
          AND (status IN (0,11,100,111))
          AND payeeid = ci_payeeid;

    l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.eval_factor';


    begin
             iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

        /*
        ** Check if payee has any configuration in
        ** Transaction amount limit table.
        ** otherwise set l_payeeid to null, so that
        ** site level configuration will be retrieved.
        */

        if ( c_get_fop_instrnum%isopen ) then
            close c_get_fop_instrnum;
        end if;
        if ( c_get_fop_instrid%isopen ) then
            close c_get_fop_instrid;
        end if;

        select count(1) into l_count
        from iby_irf_trxn_amt_limit
        where payeeid = i_payeeid;

        if ( l_count = 0 ) then
            l_payeeid := null;
        else
            l_payeeid := i_payeeid;
        end if;

        /*
        ** get the duration information;
        */

        if ( c_get_config%isopen )then
            close c_get_config;
        end if;

        open c_get_config(l_payeeid);
        fetch c_get_config into l_duration, l_duration_type, l_max_amount;
        if ( c_get_config%notfound ) then
            close c_Get_config;
            raise_application_error(-20000, 'IBY_204233#');
        end if;

        /*
        ** select the number of purchases after "fromDate" value
        */

        l_fromDate := sysdate;
        if ( l_duration_type = 'D' ) then
            l_fromDate := l_fromDate - l_duration;
        elsif ( l_duration_type = 'W' ) then
            l_fromDate := l_fromDate - (l_duration * 7);
        elsif ( l_duration_type = 'M' ) then
            l_fromDate := add_months(l_fromDate, (-1 * l_duration));
        end if;

        if (NOT i_ccNumber IS NULL) then
          l_ccnum_hash := iby_security_pkg.get_hash(i_ccNumber,'F');
          l_ccnum_obfs := iby_utility_pvt.encode64(i_ccNumber);
        end if;
	iby_debug_pub.add('earliest from date:=' || TO_CHAR(l_fromDate),
          iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);


        /*
        ** get the total amount of purhcases made during that
        ** duration configured.
        */
        l_purchases_amount := 0;
        IF (NOT i_instrid IS NULL) THEN
          OPEN c_get_fop_instrid(i_payeeid,i_instrid,l_fromdate);
          FETCH c_get_fop_instrid into l_purchases_counter;
          CLOSE c_get_fop_instrid;

          l_purchases_amount := l_purchases_amount + l_purchases_counter;
          iby_debug_pub.add('matching instrid amount:=' || l_purchases_counter,
            iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
        END IF;

	IF (NOT i_ccNumber IS NULL) THEN
           OPEN c_get_fop_instrnum(i_payeeid,i_ccNumber,l_ccnum_hash,l_fromdate);
          FETCH c_get_fop_instrnum into l_purchases_counter;
          CLOSE c_get_fop_instrnum;

          l_purchases_amount := l_purchases_amount + l_purchases_counter;
          iby_debug_pub.add('matching instrnum amount:=' || l_purchases_counter,
            iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
	END IF;

        iby_debug_pub.add('max purchase amount:=' || l_max_amount,
        iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

        if ( ( i_amount + l_purchases_amount ) >= l_max_amount ) then
            /*
            ** get the value for high risk and return
            */
            o_score := iby_risk_scores_pkg.getScore(i_payeeid, 'H');
        else
            o_score := 0;
        end if;

    end eval_factor;

end iby_trxn_amt_lmt_pkg;


/
