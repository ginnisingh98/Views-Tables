--------------------------------------------------------
--  DDL for Package MSD_STRIPE_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_STRIPE_CUSTOM" AUTHID CURRENT_USER as
/* $Header: msdstrcs.pls 115.0 2003/10/29 02:01:58 pinamati noship $ */

    --
    -- Public procedure
    --

    -- Parameters :
    -- (1) errbuf : Standard error logging variable.
    -- (2) retcode : Standard error status variable.
    -- (3) p_demand_plan_id : Id of Demand Plan.
    -- (4) p_event : Possible values include
    --
    --                    PRE-PROCESSING
    --                    This event occurs before stripe
    --                    processing begins. If called
    --                    with this event and
    --                    if procedure returns p_status
    --                    with PROCESSED, program will
    --                    not continue and assume all
    --                    striping has taken place.
    --
    --                    POST-PROCESSING
    --                    This event occurs after stripe
    --                    processing has taken place. The value of
    --                    status is insignificant at this point.
    --                    This is useful for User Defined Dims.
    --
    -- (5) p_status : Possible value include
    --
    --                     PROCESSED
    --                     If this value is passed
    --                     to program at PRE-PROCESSING
    --                     stage, then DP standard
    --                     level value striping will
    --                     not take place.


    Procedure custom_populate( errbuf out nocopy varchar2,
                               retcode out nocopy varchar2,
                               p_demand_plan_id in number,
                               p_event in varchar2,
                               p_status out nocopy varchar2,
			       p_param1 in varchar2,
			       p_param2 in varchar2,
			       p_param3 in varchar2,
			       p_param4 in varchar2,
			       p_param5 in varchar2);

End;

 

/
