--------------------------------------------------------
--  DDL for Package EDW_TIME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_TIME_PKG" AUTHID CURRENT_USER AS
/* $Header: FIICATMS.pls 120.0 2002/08/24 04:50:26 appldev noship $  */
VERSION    CONSTANT CHAR(80) := '$Header: FIICATMS.pls 120.0 2002/08/24 04:50:26 appldev noship $';

-- ------------------------
-- Public Functions
-- ------------------------

-- --------------------------------------------------------------
-- Name: cal_day_fk
-- Desc: This gives foreign key to the fiscal calendar day level in
--       the Time dimension for a given day and set of book.
-- Input : cal_date : Fiscal period name
--         p_set_of_books_id: The owning set of book for the transaction
-- Output: Date - Period Set - 'FIN' - Set of book id - instance - 'CD'
-- Error: If p_set_of_books_id is invalid or any sql errors occurs during
--        execution, an exception is raised.  However, we don't check
--        if cal_date fails within a valid fiscal period.  If this happens,
--        the record will get rejected in the warehouse
-- --------------------------------------------------------------
Function cal_day_fk(cal_date              date,
		            p_set_of_books_id     number,
                    p_instance_code    in VARCHAR2:=NULL) return VARCHAR2;

-- --------------------------------------------------------------
-- Name: cal_period_fk
-- Desc: This gives foreign key to the fiscal period level pushed down
--       to the fiscal calendar day level give the fiscal period name
--       and set of books id.  Mostly used for GL data stored
--       at the fiscal period level.
-- Input : cal_period : Fiscal period name for the transaction
--         p_set_of_books_id: set of books id
-- Output: Period Set - 'FIN' - Fiscal period - Instance - 'GL';
-- Error: If p_set_of_books_id is invalid or any sql errors occurs
--        during execution, exception is raised.  However, we don't
--        check if cal_period is a valid period name.
-- --------------------------------------------------------------
Function cal_period_fk(cal_period           varchar2,
                       p_set_of_books_id    number,
                       p_instance_code   in VARCHAR2:=NULL) return VARCHAR2;


-- ------------------------------------------------------------------
-- Name: cal_da_to_cal_period_fk
-- Desc: This gives foreign key to the fiscal period level pushed down
--       to the fiscal calendar day level given the calendar date
--       and set of book id.  It uses the start/end dates of a fiscal
--       period to determine which period a calendar day belongs to.
--       Adjustment periods are excluded.
-- Input: cal_date - Date of the transaction
--        p_set_of_book_id - The owning set of book for the transaction
-- Output: Period Set - 'FIN' - Fiscal period - Instance - 'GL'
-- Error: If p_set_of_books_id or cal_date are invalid.  An exception is
--        raised.  Likewise if any sql errors occurs during execution
-- -------------------------------------------------------------------
Function cal_day_to_cal_period_fk(cal_date              date,
                                  p_set_of_books_id     number,
                                  p_instance_code    in VARCHAR2:=NULL) return VARCHAR2;


-- -------------------------------------------------------------------
-- Name: pa_cal_day_fk
-- Desc: Returns the foreign key mapping to the fiscal calendar
--       day level of the Time dimension for PA related transactions.
--       The fiscal calendar day level holds a record for each
--       day in all financial calendars, including PA calendars.
--       This API returns the foreign keys which points to the
--       PA calendar days.
-- Input: cal_date - Date of the transaction
--        p_org_id - The owning operating unit for the PA transaction
--                   NULL if single-org implementation
-- Output: Date - Period Set - Period Type - 'FIN' - Instance - 'PD'
-- Error: If p_org_id is invalid or any sql errors occurs during
--        execution, an exception is raised.  However, we don't check
--        if p_cal_date fails within a valid PA period.  If this happens,
--        the record will get rejected in the warehouse
-- --------------------------------------------------------------------
Function pa_cal_day_fk(p_cal_date       IN date,
                       p_org_id	        IN number DEFAULT NULL,
                       p_instance_code  in VARCHAR2:=NULL) return VARCHAR2;

PRAGMA RESTRICT_REFERENCES (cal_day_fk,WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES (cal_period_fk,WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES (cal_day_to_cal_period_fk,WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES (pa_cal_day_fk,WNDS, WNPS, RNPS);

end;

 

/
