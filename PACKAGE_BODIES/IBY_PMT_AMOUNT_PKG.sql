--------------------------------------------------------
--  DDL for Package Body IBY_PMT_AMOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PMT_AMOUNT_PKG" as
/*$Header: ibypmtab.pls 115.3 2002/11/19 21:38:08 jleybovi ship $*/

    procedure eval_factor(i_payeeid varchar2,
                          i_amount in number,
                          o_score out nocopy integer)
    is

    l_not_found boolean;
    l_score varchar2(10);
    l_cnt integer;
    l_payeeid varchar2(80);

    cursor c_getfactor_config(ci_payeeid varchar2) is
    select lower_limit, upper_limit, score
    from iby_irf_pmt_amount
    where ( ( payeeid is null and ci_payeeid is null ) or
          payeeid = ci_payeeid)
    order by seq;

    begin


        /*
        ** check whether this payeeid has any entry in
        ** for Payment Amount Table.
        ** if not the set payeeid to null.
        */

        select count(1) into l_cnt
        from iby_irf_pmt_amount
        where payeeid = i_payeeid;

        if ( l_cnt = 0 ) then
            l_payeeid := null;
        else
            l_payeeid := i_payeeid;
        end if;

        l_not_found := true;

        if ( c_getfactor_config%isopen ) then
            close c_getfactor_config;
        end if;

        <<l_range_loop>>
        for i in c_getfactor_config(l_payeeid) loop
            if ( ( ( i.lower_limit = -1 ) or ( i.lower_limit <= i_amount ) )
                and ( ( i.upper_limit = -1 ) or ( i_amount < i.upper_limit ) ) )
                then
                l_not_found := false;
                l_score := i.score;
                exit l_range_loop;
            end if;
        end loop l_range_loop;

        if ( l_not_found ) then
            raise_application_error(-20000, 'IBY_204231#');
        end if;

        o_score := iby_risk_scores_pkg.getScore(i_payeeid, l_score);

    end eval_factor;

end iby_pmt_amount_pkg;


/
