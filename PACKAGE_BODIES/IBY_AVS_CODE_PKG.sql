--------------------------------------------------------
--  DDL for Package Body IBY_AVS_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_AVS_CODE_PKG" as
/*$Header: ibyavscb.pls 120.1.12010000.2 2009/08/07 12:58:18 sugottum ship $*/


    procedure eval_factor( i_payeeid in varchar2,
                          i_avs_code in varchar2,
                          o_score out nocopy integer )
    is

    l_score varchar2(10);
    l_cnt integer;
    l_payeeid varchar2(80);

    -- Bug# 8768305
    -- There can be multiple mapping codes for a particular payeeid + mapping_type
    -- combination..So, included INSTR function to handle this scenario
    -- If INSTR is not used and if there are mutliple values defined for mapping_code
    -- then value would be always null
    cursor c_get_factor_config(ci_payeeid varchar2, ci_avs_code varchar2)
    is
    select value
    from iby_mappings
    where ( ( payeeid is null and ci_payeeid is null ) or
          payeeid = ci_payeeid)
    and mapping_type = 'AVS_CODE_TYPE'
    and INSTR(mapping_code, ci_avs_code, 1)>0;

    begin

        /*
        ** check whether this payeeid has any entry in
        ** for AVScodes.
        ** if not the set payeeid to null.
        */

        select count(1) into l_cnt
        from iby_mappings
        where mapping_type = 'AVS_CODE_TYPE'
        and payeeid = i_payeeid;

        if ( l_cnt = 0 ) then
            l_payeeid := null;
        else
            l_payeeid := i_payeeid;
        end if;

        -- close the cursor if it already open.
        if ( c_get_factor_config%isopen ) then
            close c_get_factor_config;
        end if;

        open c_get_factor_config(l_payeeid, i_avs_code);
        -- fetch the values
        fetch c_get_factor_config into l_score;
        -- if avscode is not present then assign norisk value
        -- otherwise get the corresponding value by calling
        -- iby_risk_scores_pkg.getScore method.
        if ( c_get_factor_config%notfound) then
            o_score := 0;
        else
            o_score := iby_risk_scores_pkg.getScore(i_payeeid, l_score);
        end if;
        close c_get_factor_config;

    end eval_factor;

end iby_avs_code_pkg;

/
