--------------------------------------------------------
--  DDL for Package Body IBY_PMT_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PMT_HISTORY_PKG" as
/*$Header: ibypmthb.pls 120.3.12000000.2 2007/09/06 09:54:36 lmallick ship $*/
    G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.iby_pmt_history_pkg';
    PROCEDURE eval_factor
	(
	i_ecappid	IN	iby_trxn_summaries_all.ecappid%TYPE,
	i_payeeid	IN	iby_trxn_summaries_all.payeeid%TYPE,
	i_payerid	IN	iby_trxn_summaries_all.payerid%TYPE,
	i_instrid	IN	iby_trxn_summaries_all.payerinstrid%TYPE,
	i_ccNumber	IN	iby_trxn_summaries_all.instrnumber%TYPE,
	i_master_key	IN	iby_payee.master_key%TYPE,
	o_score		OUT NOCOPY INTEGER
	)
    IS

    l_fromDate date;
    l_count integer;
    l_duration integer;
    l_duration_type varchar2(10);
    l_pmt_hist_id integer;
    l_not_found boolean;
    l_score varchar2(10);
    l_payeeid varchar2(80);
    l_no_of_purchases integer;
    l_purchases_counter INT;
    l_ccnum_hash iby_trxn_summaries_all.instrnum_hash%TYPE;
    l_ccnum_obfs iby_trxn_summaries_all.instrnumber%TYPE;

    cursor c_get_ranges(ci_pmt_hist_id integer) is
    select frequency_low_range lower_limit,
           frequency_high_range upper_limit, score
    from iby_irf_pmt_hist_range
    where payment_hist_id = ci_pmt_hist_id
    order by seq;

    cursor c_get_config(ci_payeeid varchar2) is
    select duration, duration_type, id
    from iby_irf_pmt_history
    where ( payeeid is null and ci_payeeid is null )
         or (payeeid = ci_payeeid);

    --
    -- divide payment history count query into 3 independent queries
    -- to avoid expensive, unnecessary queries
    --
    CURSOR c_get_history_instrnum
        (
        ci_payeeid  iby_trxn_summaries_all.payeeid%TYPE,
        ci_ccNum    iby_trxn_summaries_all.instrnumber%TYPE,
	ci_ccNumHash iby_trxn_summaries_all.instrnum_hash%TYPE,
        ci_fromDate iby_trxn_summaries_all.reqdate%TYPE
        )
    IS
    SELECT count(1)
    FROM iby_trxn_summaries_all
    WHERE ((instrnumber = ci_ccNum) OR (instrnum_hash = ci_ccNumHash))
       AND reqdate >= ci_fromDate
       AND reqtype = 'ORAPMTREQ'
       AND (status IN (0,11,10,111))
       AND (payeeid = ci_payeeid);

    CURSOR c_get_history_payer
        (
        ci_payeeid iby_trxn_summaries_all.payeeid%TYPE,
        ci_payerid  iby_trxn_summaries_all.payerid%TYPE,
        ci_fromDate iby_trxn_summaries_all.reqdate%TYPE
        )
    IS
    SELECT count(1)
    FROM iby_trxn_summaries_all
    WHERE (payerid = ci_payerid)
       AND reqdate >= ci_fromDate
       AND reqtype = 'ORAPMTREQ'
       AND (status IN (0,11,10,111))
       AND (payeeid = ci_payeeid);

    CURSOR c_get_history_payerinstr
        (
        ci_payeeid iby_trxn_summaries_all.payeeid%TYPE,
        ci_instrid  iby_trxn_summaries_all.payerinstrid%TYPE,
        ci_fromDate iby_trxn_summaries_all.reqdate%TYPE
        )
    IS
    SELECT count(1)
    FROM iby_trxn_summaries_all
    WHERE (payerinstrid = ci_instrid)
       AND reqdate >= ci_fromDate
       AND reqtype = 'ORAPMTREQ'
       AND (status IN (0,11,10,111))
       AND (payeeid = ci_payeeid);

    l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.eval_factor';


    begin
            iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

        if ( c_get_history_instrnum%isopen ) then
            close c_get_history_instrnum;
        end if;
        if ( c_get_history_payer%isopen ) then
            close c_get_history_payer;
        end if;
        if ( c_get_history_payerinstr%isopen ) then
            close c_get_history_payerinstr;
        end if;


        select count(1) into l_count
        from iby_irf_pmt_history
        where payeeid = i_payeeid;

        if ( l_count = 0 ) then
            l_payeeid := null;
        else
            l_payeeid := i_payeeid;
        end if;

        /*
        ** get Payment history configuration information.
        */

        if ( c_get_config%isopen ) then
            close c_get_config;
        end if;

        open c_get_config(l_payeeid);
        fetch c_get_config into l_duration, l_duration_type, l_pmt_hist_id;
        if ( c_get_config%notfound) then
            close c_get_config;
            raise_application_error(-20000, 'IBY_204234#');
        end if;
        close c_get_config;

        l_fromDate := sysdate;
        if ( l_duration_type = 'D' ) then
            l_fromDate := l_fromDate - l_duration;
        elsif ( l_duration_type = 'W' ) then
            l_fromDate := l_fromDate - (l_duration * 7);
        elsif ( l_duration_type = 'M' ) then
            l_fromDate := add_months(l_fromDate, (-1 * l_duration));
        elsif ( l_duration_type = 'Y' ) then
            l_fromDate := add_months(l_fromDate, (-1 * (l_duration * 12)));
        end if;

        if (NOT i_ccNumber IS NULL) then
          l_ccnum_hash := iby_security_pkg.get_hash(i_ccNumber,'F');
          l_ccnum_obfs := iby_utility_pvt.encode64(i_ccNumber);
        end if;
	        iby_debug_pub.add('earliest from date:=' || TO_CHAR(l_fromDate),
          iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);


        /*
        ** get the payment history information of either
        ** based on payerId or CC Number.
        */

    	l_no_of_purchases := 0;
        IF (NOT i_payerid IS NULL) THEN
          OPEN c_get_history_payer
              (i_payeeid,i_payerid,l_fromdate);
          FETCH c_get_history_payer into l_purchases_counter;
          CLOSE c_get_history_payer;
          l_no_of_purchases := l_purchases_counter + l_no_of_purchases;
          iby_debug_pub.add('matching payer count:=' || l_purchases_counter,
            iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
        END IF;

        IF (NOT i_instrid IS NULL) THEN
          OPEN c_get_history_payerinstr
              (i_payeeid,i_instrid,l_fromdate);
          FETCH c_get_history_payerinstr into l_purchases_counter;
          CLOSE c_get_history_payerinstr;

          l_no_of_purchases := l_purchases_counter + l_no_of_purchases;
          iby_debug_pub.add('matching pyr instr cnt:=' || l_purchases_counter,
            iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
        END IF;

	IF (NOT i_ccNumber IS NULL) THEN
	   OPEN c_get_history_instrnum
	      (i_payeeid,i_ccNumber,l_ccnum_hash,l_fromDate);
	   FETCH c_get_history_instrnum into l_purchases_counter;
	   CLOSE c_get_history_instrnum;

           l_no_of_purchases := l_purchases_counter + l_no_of_purchases;
           iby_debug_pub.add('matching cc_num cnt:=' || l_purchases_counter,
            iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
        END IF;


        /*
        ** compare the history with the configured value
        ** and reture appropriate score.
        */

        l_not_found := true;

        if ( c_get_ranges%isopen ) then
            close c_get_ranges;
        end if;

        <<l_ranges_loop>>
        for i in c_get_ranges(l_pmt_hist_id) loop
            if ( ( ( i.lower_limit = -1 ) or
                      ( i.lower_limit <= l_no_of_purchases ) )
                 and ( ( i.upper_limit = -1 ) or
                       ( l_no_of_purchases < i.upper_limit ) ) )
                then
                l_not_found := false;
                l_score := i.score;
                exit l_ranges_loop;
            end if;
        end loop l_ranges_loop;

        if ( l_not_found ) then
            raise_application_error(-20000, 'IBY_204235#');
        end if;

        o_score := iby_risk_scores_pkg.getScore(i_payeeid, l_score);
	iby_debug_pub.add('Exit',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

    end eval_factor;

end iby_pmt_history_pkg;


/
