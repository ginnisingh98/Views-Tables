--------------------------------------------------------
--  DDL for Package Body IBY_RISK_SCORES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_RISK_SCORES_PKG" as
/*$Header: ibyriskb.pls 120.2 2005/10/30 05:50:42 appldev ship $*/


    function getScore( i_payeeid in varchar2,
                        i_score in varchar2 )
    return integer
    is

    l_score integer;

    cursor c_getscore(ci_payeeid in varchar2,
                      ci_code in varchar2)
    is
    select value
    from iby_mappings
    where ( ( payeeid is null and ci_payeeid is null ) or
            payeeid = ci_payeeid )
    and mapping_type = 'IBY_RISK_SCORE_TYPE'
    and mapping_code = ci_code;

    begin

        -- initialize the variables
        l_score := 0;

        -- if cursor is already open then close the connection.
        --
        if ( c_getScore%isopen ) then
            close c_getScore;
        end if;

        -- open the cursor.
        open c_getScore(i_payeeid, i_score);
        fetch c_getScore into l_score;
        -- if values are not found then try to get
        -- the default values by passing payeeid as null to
        -- the cursor.
        if ( c_getScore%notfound ) then
            close c_getScore;
       -- bug 4107078. The default payee id has been changed to -99
            open c_getScore('-99', i_score);
            fetch c_getScore into l_score;
            -- if cursor does not return any thing then raise exception.
            if ( c_getScore%notfound ) then
                close c_getScore;
                raise_application_error(-20000, 'IBY_204236#CODE#'
                    || i_score || '#');
            end if;
        end if;
        -- close the cursor in case everything goes smooth.
        close c_getScore;
        return l_score;
    end getScore;

end iby_risk_scores_pkg;


/
