--------------------------------------------------------
--  DDL for Package Body IBY_TIME_OF_PURCHASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_TIME_OF_PURCHASE_PKG" as
/*$Header: ibytopb.pls 115.7 2002/11/20 00:19:29 jleybovi ship $*/


    procedure eval_factor( i_payeeid in varchar2,
                          i_hours in integer,
                          i_minutes in integer,
                          o_score out nocopy integer)
    is

    l_not_found boolean;
    l_hours integer;
    l_score varchar2(10);
    l_cnt integer;
    l_payeeid varchar2(80);
    l_lower_range integer;
    l_upper_range integer;

    cursor c_get_factor_config(ci_payeeid in varchar2) is

    select duration_from, duration_to, score
    from iby_irf_timeof_purchase
    where ( ( payeeid is null and ci_payeeid is null ) or
          payeeid = ci_payeeid)
    order by seq;

    begin


        /*
        ** check whether this payeeid has any entry in
        ** for time of purchase configuration.
        ** if not the set payeeid to null.
        */

        select count(1) into l_cnt
        from iby_irf_timeof_purchase
        where payeeid = i_payeeid;

        if ( l_cnt = 0 ) then
            l_payeeid := null;
        else
            l_payeeid := i_payeeid;
        end if;

        l_not_found := true;

        -- round the hours value to nearest hour based on the
        -- time value passed.

        -- if minutes value is greater than 0 then
        -- add 1 to hours value. After adding 1 if hours value bcome
        -- more than or equal to 24 then assign hours value 0.
        -- if minutes is 0 then hours will remain same.
        if ( i_minutes > 0 ) then
            if ( i_hours + 1 = 24 ) then
                l_hours := 0;
            else
                l_hours := i_hours + 1;
            end if;
        else
            l_hours := i_hours;
        end if;

        if ( c_get_factor_config%isopen ) then
            close c_get_factor_config;
        end if;

        <<l_ranges_loop>>
        for i in c_get_factor_config(l_payeeid) loop
            l_lower_range := i.duration_from;
            l_upper_range := i.duration_to;

            -- if lower range and upper range are in sameday, i.e
            -- upper is greater than lower.
            if ( l_upper_range >= l_lower_range ) then
                  if ( ( l_lower_range < l_hours ) and
                     ( l_upper_range >= l_hours ) ) then
                     l_not_found := false;
                     l_score := i.score;
                     exit l_ranges_loop;
                  end if;
            -- if range falls in two different days.
            -- i.e lower is greater than upper.
            else
                if ( ( ( l_hours <= 24 )  and ( l_hours > l_lower_range ) ) or
                     ( ( l_hours >= 0 ) and ( l_hours <= l_upper_range ) ) ) then
                    l_not_found := false;
                    l_score := i.score;
                    exit l_ranges_loop;
                end if;
            end if;
        end loop l_ranges_loop;

        if ( l_not_found ) then
            raisE_application_error(-20000, 'IBY_204232#');
        end if;

        o_score := iby_risk_scores_pkg.getScore(i_payeeid, l_score);

    end eval_factor;

end iby_time_of_purchase_pkg;


/
