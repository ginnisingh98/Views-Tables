--------------------------------------------------------
--  DDL for Package WSH_CALENDAR_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CALENDAR_ACTIONS" AUTHID CURRENT_USER AS
/* $Header: WSHCAACS.pls 120.2 2005/08/12 14:22:06 sperera noship $ */
-------------------------------------------------------------------------------------------
-- Start of comments
-- API name                     : Get_Shift_Times
--      Type                            : public
--      Function                        : get the earliest shift times from
--                                        calendars greater than a given date/time
--                                        for a given location
--      Version                 : Initial version 1.0
--      Parameters              : IN:  p_location_id: Location for which we need the
--                                                    shift times.
--                                     p_date       : Date for which we need the
--                                                    shift times.
 --                             : OUT: x_from_time  : The start time of the earliest
--                                                    shift that ends after the given
--                                                    date time
--                                   : x_to_time    : The end time of the earliest
--                                                    shift that ends after the given
--                                                    date time
--     Notes                    : It is possible that a shift extends past midnight.
--                                In this case the x_to_time will be less than the x_from_time.
--                                If there are no shifts remaing after the date/time or
--                                Calendar not defined for the location, NULL will be
--                                returned for both the out dates.
-- End of comments
-- ------------------------------------------------------------------------------------------


Procedure Get_Shift_Times(p_location_id   IN NUMBER,
                          p_date          IN DATE,
                          x_from_time     OUT NOCOPY NUMBER,
                          x_to_time       OUT NOCOPY NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2);


END WSH_CALENDAR_ACTIONS;


 

/
