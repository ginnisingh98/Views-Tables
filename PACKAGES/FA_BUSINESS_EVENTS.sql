--------------------------------------------------------
--  DDL for Package FA_BUSINESS_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_BUSINESS_EVENTS" AUTHID CURRENT_USER AS
/* $Header: fawfbevs.pls 120.1.12010000.2 2009/07/19 10:41:43 glchen ship $ */

/*
** test - Verifies the specified event is enabled.  Then, tests if there
**        is an enabled LOCAL subscription for this event, or an enabled
**        subscription for an enabled group that contains this event.
**
**        Returns the most costly data requirement for active subscriptions
**        on the event:
**          NONE     no subscription or no event           (best)
**          KEY      subscription requiring event key only
**          MESSAGE  subscription requiring event message  (worst)
*/
FUNCTION test(p_event_name in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return varchar2;

/*
** raise - raise a local event to the event manager
**        -- Below Moved to Dispatcher --
**        Calls TEST to determine whether a MESSAGE type subscription
**        exists.  If a MESSAGE is required, and none is specified by
**        the caller, we generate one using the GENERATE_FUNCTION
**        identified for the event in the WF_EVENTS table.  If no
**        GENERATE_FUNCTION is found, we create a default message using
**        the event name and event key data.
**        -- Above moved to Dispatcher --
**
**        Event is passed to the dispatcher.
**
**        Note: If the event is not defined, no error will be raised.
*/
PROCEDURE raise(p_event_name      in varchar2,
                p_event_key        in varchar2,
                p_event_data       in clob default NULL,
                p_parameter_name1  in varchar2 default NULL,
                p_parameter_value1 in varchar2 default NULL,
                p_parameter_name2  in varchar2 default NULL,
                p_parameter_value2 in varchar2 default NULL,
                p_parameter_name3  in varchar2 default NULL,
                p_parameter_value3 in varchar2 default NULL,
                p_parameter_name4  in varchar2 default NULL,
                p_parameter_value4 in varchar2 default NULL,
                p_parameter_name5  in varchar2 default NULL,
                p_parameter_value5 in varchar2 default NULL,
                p_parameter_name6  in varchar2 default NULL,
                p_parameter_value6 in varchar2 default NULL,
                p_parameter_name7  in varchar2 default NULL,
                p_parameter_value7 in varchar2 default NULL,
                p_parameter_name8  in varchar2 default NULL,
                p_parameter_value8 in varchar2 default NULL,
                p_parameter_name9  in varchar2 default NULL,
                p_parameter_value9 in varchar2 default NULL,
                p_parameter_name10  in varchar2 default NULL,
                p_parameter_value10 in varchar2 default NULL,
                p_parameter_name11  in varchar2 default NULL,
                p_parameter_value11 in varchar2 default NULL,
                p_parameter_name12  in varchar2 default NULL,
                p_parameter_value12 in varchar2 default NULL,
                p_parameter_name13  in varchar2 default NULL,
                p_parameter_value13 in varchar2 default NULL,
                p_parameter_name14  in varchar2 default NULL,
                p_parameter_value14 in varchar2 default NULL,
                p_parameter_name15  in varchar2 default NULL,
                p_parameter_value15 in varchar2 default NULL,
                p_parameter_name16  in varchar2 default NULL,
                p_parameter_value16 in varchar2 default NULL,
                p_parameter_name17  in varchar2 default NULL,
                p_parameter_value17 in varchar2 default NULL,
                p_parameter_name18  in varchar2 default NULL,
                p_parameter_value18 in varchar2 default NULL,
                p_parameter_name19  in varchar2 default NULL,
                p_parameter_value19 in varchar2 default NULL,
                p_parameter_name20  in varchar2 default NULL,
                p_parameter_value20 in varchar2 default NULL,
                p_send_date         in date default NULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


END FA_BUSINESS_EVENTS;

/
