--------------------------------------------------------
--  DDL for Package Body CN_BIS_SRP_DATA_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_BIS_SRP_DATA_GEN_PVT" AS
-- $Header: cnvbsumb.pls 115.13.1158.7 2003/07/29 17:12:47 ctoba noship $

PROCEDURE debug_msg(p_message IN VARCHAR2, p_indenting IN NUMBER) IS
BEGIN
    null;
END debug_msg;


PROCEDURE log_msg(p_message IN VARCHAR2, p_indenting IN NUMBER) IS
BEGIN
    null;
END log_msg;


FUNCTION get_refresh_mode RETURN VARCHAR2 IS
BEGIN
    RETURN null;
END get_refresh_mode;


FUNCTION get_enterprise_calendar RETURN VARCHAR2 IS
BEGIN

    RETURN null;
END get_enterprise_calendar;

FUNCTION get_global_start_date RETURN DATE IS
BEGIN

    RETURN null;
END get_global_start_date;

PROCEDURE get_last_refresh_dates (x_cp_start_date OUT NOCOPY DATE, x_cp_end_date OUT NOCOPY DATE,
   x_start_date OUT NOCOPY DATE, x_end_date OUT NOCOPY DATE) IS
BEGIN
   null;

END get_last_refresh_dates;

FUNCTION is_period_open(p_date DATE) RETURN BOOLEAN IS
    BEGIN
        RETURN false;
END is_period_open;

PROCEDURE get_refresh_dates(p_start_date_provided IN DATE, p_end_date_provided IN DATE
,    x_start_date OUT NOCOPY  DATE, x_end_date OUT NOCOPY DATE) IS
BEGIN
null;
END get_refresh_dates;

FUNCTION get_period(p_date IN DATE) RETURN NUMBER IS
BEGIN
    RETURN null;
END get_period;

FUNCTION is_currency_code_available RETURN BOOLEAN IS
BEGIN
    RETURN false;
END is_currency_code_available;

PROCEDURE set_end_date_of_prev_period IS
BEGIN
null;
END set_end_date_of_prev_period;

FUNCTION get_end_date_of_prev_period RETURN DATE IS
BEGIN
    RETURN null;
END get_end_date_of_prev_period;

FUNCTION match_calendars(p_ent_cal IN VARCHAR2) RETURN BOOLEAN IS

BEGIN

    RETURN false;
END match_calendars;

FUNCTION cn_setup RETURN BOOLEAN IS
BEGIN

    RETURN false;
END cn_setup;

FUNCTION is_exchange_rate_available(p_start_period IN NUMBER, p_end_period IN NUMBER) RETURN BOOLEAN IS
    BEGIN
        RETURN false;
END is_exchange_rate_available;

PROCEDURE truncate_table(p_table IN VARCHAR2) IS
BEGIN
null;
END truncate_table;

FUNCTION populate_table(p_refresh_start_period IN NUMBER,
                        p_refresh_end_period IN NUMBER,
                        p_last_cp_end_date IN DATE) RETURN NUMBER IS


BEGIN
return null;

END populate_table;

PROCEDURE add_info_to_log(p_start_period IN NUMBER, p_end_period IN NUMBER) IS
BEGIN
null;

END add_info_to_log;

PROCEDURE generate_base_summ_data(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2,
                                    p_start_date IN DATE, p_end_date IN DATE) IS
BEGIN
null;

END generate_base_summ_data;

PROCEDURE set_refresh_mode(p_mode IN VARCHAR2) IS

BEGIN

null;

END set_refresh_mode;

PROCEDURE generate_base_summ_data_c(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2,
                                    p_start_date IN VARCHAR2, p_end_date IN VARCHAR2) IS
    l_date1     DATE;
    l_date2     DATE;
BEGIN
null;
END generate_base_summ_data_c;

PROCEDURE generate_base_summ_data_f(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY VARCHAR2) IS
BEGIN
  null;
END generate_base_summ_data_f;

END CN_BIS_SRP_DATA_GEN_PVT;

/
