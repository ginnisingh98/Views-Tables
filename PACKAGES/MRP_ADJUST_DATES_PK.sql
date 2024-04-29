--------------------------------------------------------
--  DDL for Package MRP_ADJUST_DATES_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ADJUST_DATES_PK" AUTHID CURRENT_USER AS
    /* $Header: MRPPADTS.pls 115.1 2002/11/26 22:41:31 jhegde ship $ */
    PROCEDURE   mrp_adjust_dates_by_calendar(
                cal_code        IN      VARCHAR2,
                except_set_id   IN      NUMBER,
                user_id         IN      NUMBER,
                error_msg       IN OUT NOCOPY  VARCHAR2);
    PROCEDURE   mrp_adjust_dates_by_org(
                cal_code        IN      VARCHAR2,
                except_set_id   IN      NUMBER,
                org_id          IN      NUMBER,
                user_id         IN      NUMBER,
                error_msg       IN OUT NOCOPY  VARCHAR2);
    VERSION                 CONSTANT CHAR(80) :=
        '$Header: MRPPADTS.pls 115.1 2002/11/26 22:41:31 jhegde ship $';
END mrp_adjust_dates_pk;

 

/
