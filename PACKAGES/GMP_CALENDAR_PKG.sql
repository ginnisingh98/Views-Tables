--------------------------------------------------------
--  DDL for Package GMP_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_CALENDAR_PKG" AUTHID CURRENT_USER as
/* $Header: GMPDCALS.pls 120.3.12010000.2 2008/11/01 22:19:24 rpatangy ship $ */

g_in_str_org       VARCHAR2(32767) := NULL;
G_ALL_ORG          CONSTANT VARCHAR2(1024) := '-999' ;

PROCEDURE rsrc_extract(p_instance_id IN PLS_INTEGER,
                       p_db_link IN VARCHAR2,
                       return_status OUT NOCOPY BOOLEAN);

/* Bug# 1494939 - Initial changes for Resource Calendar */
PROCEDURE update_trading_partners(p_org_id IN PLS_INTEGER,
                                  p_cal_code IN varchar2,
                                  return_status OUT NOCOPY BOOLEAN);

PROCEDURE retrieve_calendar_detail( p_calendar_code IN VARCHAR2,
                                    p_cal_desc in varchar2,
                                    p_run_date IN date,
                                    p_db_link IN varchar2,
                                    p_instance_id IN PLS_INTEGER,
                                    p_usage IN varchar2,
                                    return_status OUT NOCOPY BOOLEAN);

PROCEDURE net_rsrc_insert(p_org_id IN PLS_INTEGER,
                          p_orgn_code IN varchar2,
                          p_simulation_set IN varchar2,
                          p_db_link  IN varchar2,
                          p_instance_id IN PLS_INTEGER,
                          p_run_date IN DATE ,
                          p_calendar_code IN varchar2,
                          p_usage IN varchar2,
                          return_status OUT NOCOPY BOOLEAN);

PROCEDURE populate_rsrc_cal(p_run_date IN date,
                            p_instance_id IN PLS_INTEGER,
                            p_delimiter IN varchar2,
                            p_db_link IN varchar2,
                            p_nra_enabled IN NUMBER,
                            return_status OUT NOCOPY BOOLEAN);
PROCEDURE time_stamp ;

PROCEDURE log_message( pbuff  IN  VARCHAR2) ;

PROCEDURE insert_gmp_resource_avail( errbuf        OUT NOCOPY varchar2,
                                     retcode       OUT NOCOPY number  ,
                                     p_org_id      IN PLS_INTEGER ,
                                     p_from_rsrc   IN varchar2 ,
                                     p_to_rsrc     IN varchar2 ,
                                     p_calendar_code IN VARCHAR2  ) ;

PROCEDURE net_rsrc_avail_calculate(p_instance_id IN PLS_INTEGER,
                          p_org_id      IN PLS_INTEGER ,
                          p_calendar_code IN VARCHAR2,
                          p_db_link   IN varchar2,
                          return_status OUT NOCOPY BOOLEAN) ;

PROCEDURE net_rsrc_avail_insert(p_instance_id IN PLS_INTEGER,
                   p_org_id IN PLS_INTEGER,
                   p_resource_instance_id IN PLS_INTEGER,
                   p_calendar_code IN VARCHAR2,
                   p_resource_id IN PLS_INTEGER,
                   p_assigned_qty IN number,
                   p_shift_num IN PLS_INTEGER,
                   p_calendar_date IN DATE,
                   p_from_time IN NUMBER,
                   p_to_time IN NUMBER )  ;

FUNCTION ORG_STRING(instance_id IN PLS_INTEGER) return BOOLEAN ;

END gmp_calendar_pkg;

/
