--------------------------------------------------------
--  DDL for Package QLTDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTDATE" AUTHID CURRENT_USER as
/* $Header: qltdateb.pls 120.0.12000000.1 2007/01/19 07:15:29 appldev ship $ */

    FUNCTION user_mask RETURN Varchar2;
    PRAGMA restrict_references(user_mask, WNDS, WNPS);
    -- See Oracle8 Server Application Developer's Guide p. 10-47

    FUNCTION output_mask RETURN Varchar2;
    PRAGMA restrict_references(output_mask, WNDS, WNPS);

    FUNCTION canon_to_date(canon Varchar2) RETURN Date;
    PRAGMA restrict_references(canon_to_date, WNDS, WNPS);

    -- canon_to_date is also over-loaded as in the case
    -- of any_to_date(). Extremely useful to hide the
    -- details of implementation from caller.
    -- rkunchal Mon Aug 26 04:34:42 PDT 2002

    FUNCTION canon_to_date(canon Date) RETURN Date;
    PRAGMA restrict_references(canon_to_date, WNDS, WNPS);

    FUNCTION canon_to_user(canon Varchar2) RETURN Varchar2;
    PRAGMA restrict_references(canon_to_user, WNDS, WNPS);

    -- canon_to_user is also over-loaded as in the case
    -- of any_to_user(). Extremely useful to hide the
    -- details of implementation from caller.
    -- rkunchal Mon Aug 26 04:34:42 PDT 2002

    FUNCTION canon_to_user(d Date) RETURN Varchar2;
    PRAGMA restrict_references(canon_to_user, WNDS, WNPS);

    FUNCTION any_to_date(flex Varchar2) RETURN Date;
    PRAGMA restrict_references(any_to_date, WNDS, WNPS);

    FUNCTION any_to_date(flex Date) RETURN Date;
    PRAGMA restrict_references(any_to_date, WNDS, WNPS);

    FUNCTION any_to_canon(flex Varchar2) RETURN Varchar2;
    PRAGMA restrict_references(any_to_canon, WNDS, WNPS);

    FUNCTION any_to_user(flex Varchar2) RETURN Varchar2;
    PRAGMA restrict_references(any_to_user, WNDS, WNPS);

    -- See bug #2503882
    -- Overloaded to treat hard-coded and soft-coded
    -- collection elements differently.
    -- Hard-coded elements donot need to be to_date()-ed.
    -- rkunchal Thu Aug 22 09:57:16 PDT 2002

    FUNCTION any_to_user(d Date) RETURN Varchar2;
    PRAGMA restrict_references(any_to_user, WNDS, WNPS);

    FUNCTION date_to_user(d Date) RETURN Varchar2;
    PRAGMA restrict_references(date_to_user, WNDS, WNPS);

    FUNCTION date_to_canon(d Date) RETURN Varchar2;
    PRAGMA restrict_references(date_to_canon, WNDS, WNPS);

    FUNCTION canon_to_number(canon Varchar2) RETURN Number;
    PRAGMA restrict_references(canon_to_number, WNDS, WNPS);

    FUNCTION canon_to_number(canon Number) RETURN Number;
    PRAGMA restrict_references(canon_to_number, WNDS, WNPS);

    FUNCTION any_to_number(n Number) RETURN Number;
    PRAGMA restrict_references(any_to_number, WNDS, WNPS);

    FUNCTION any_to_number(n Varchar2) RETURN Number;
    PRAGMA restrict_references(any_to_number, WNDS, WNPS);

    FUNCTION number_to_canon(n Number) RETURN Varchar2;
    PRAGMA restrict_references(number_to_canon, WNDS, WNPS);

    FUNCTION number_canon_to_user(canon Varchar2) RETURN Varchar2;
    PRAGMA restrict_references(number_canon_to_user, WNDS, WNPS);

    FUNCTION number_user_to_canon(n Varchar2) RETURN Varchar2;
    PRAGMA restrict_references(number_user_to_canon, WNDS, WNPS);

    FUNCTION get_sysdate RETURN date;
    PRAGMA restrict_references(get_sysdate, WNDS, WNPS);

    FUNCTION upgrade_to_canon(flex Varchar2) RETURN Varchar2;
    PRAGMA restrict_references(upgrade_to_canon, WNDS, WNPS);

    -- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
    -- Following new function are added
    --
    FUNCTION date_to_canon_dt(d Date) RETURN Varchar2;
    PRAGMA restrict_references(date_to_canon_dt, WNDS, WNPS);

    FUNCTION any_to_datetime(flex Date) RETURN Date;
    PRAGMA restrict_references(any_to_datetime, WNDS, WNPS);

    FUNCTION any_to_datetime(flex Varchar2) RETURN Date;
    PRAGMA restrict_references(any_to_datetime, WNDS, WNPS);

    FUNCTION output_DT_mask RETURN Varchar2;
    PRAGMA restrict_references(output_DT_mask, WNDS, WNPS);

    FUNCTION date_to_user_dt(d Date) RETURN Varchar2;
    PRAGMA restrict_references(date_to_user_dt, WNDS, WNPS);

    FUNCTION any_to_user_dt(flex Varchar2) RETURN Varchar2;
    PRAGMA restrict_references(any_to_user_dt, WNDS, WNPS);

END QLTDATE;


 

/
