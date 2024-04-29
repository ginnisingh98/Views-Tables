--------------------------------------------------------
--  DDL for Package BIX_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: bixxutls.pls 115.24 2002/11/27 00:27:06 djambula ship $*/

FUNCTION get_null_lookup RETURN VARCHAR2;
FUNCTION get_icx_session_id RETURN NUMBER;
FUNCTION get_hrmiss_frmt(seconds IN NUMBER) RETURN VARCHAR2;
FUNCTION get_hrmi_frmt(seconds IN NUMBER) RETURN VARCHAR2;
FUNCTION get_uwq_refresh_date(p_context in varchar2 default null ) RETURN VARCHAR2;
FUNCTION get_calls_refresh_date(p_context in varchar2 default null ) RETURN VARCHAR2;
FUNCTION get_start_date(p_end_date IN varchar2,
				    p_period IN VARCHAR2,
				    p_date_format IN VARCHAR2,
				    p_numperiods IN NUMBER)
RETURN VARCHAR2;
FUNCTION get_group_by  (p_end_date IN varchar2,
				    p_period IN VARCHAR2,
				    p_date_format IN VARCHAR2
                        )
RETURN VARCHAR2;
PROCEDURE get_time_range(p_time_id in number, p_from_date out nocopy date, p_to_date out nocopy date);
FUNCTION bix_dm_get_footer(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION bix_dm_get_agent_footer(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION bix_dm_get_call_footer(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION bix_dm_get_agent_refresh_date(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION bix_dm_get_call_refresh_date(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION bix_real_get_footer(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION get_uwq_footer(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION get_uwq_duration_footer(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION get_realtime_footer(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
PROCEDURE get_prev_period(p_period_set_name IN VARCHAR2,
					      p_period_type     IN VARCHAR2,
					      p_date            IN DATE,
                          p_period_start_date OUT nocopy DATE,
                          p_period_end_date   OUT nocopy DATE);
PROCEDURE get_curr_period(p_period_set_name IN VARCHAR2,
					      p_period_type     IN VARCHAR2,
					      p_date            IN DATE,
                          p_period_start_date OUT nocopy DATE,
                          p_period_end_date   OUT nocopy DATE);
PROCEDURE get_time_period(p_period_ind   IN VARCHAR2,
					 p_start_date   IN VARCHAR2,
					 p_start_time   IN VARCHAR2,
					 p_end_date     IN VARCHAR2,
					 p_end_time     IN VARCHAR2,
					 p_start_period OUT nocopy VARCHAR2,
					 p_end_period   OUT nocopy VARCHAR2);
PROCEDURE get_conversion_rate ( p_from_currency IN VARCHAR2,
						  p_to_currency  IN VARCHAR2,
						  p_conversion_type IN VARCHAR2,
						  p_denom_rate OUT nocopy NUMBER,
						  p_num_rate OUT nocopy NUMBER,
						  p_status OUT nocopy NUMBER );
PROCEDURE get_conversion_rate ( p_from_currency IN VARCHAR2,
						  p_to_currency  IN VARCHAR2,
                                p_conversion_date IN DATE,
						  p_conversion_type IN VARCHAR2,
						  p_denom_rate OUT nocopy NUMBER,
						  p_num_rate OUT nocopy NUMBER,
						  p_status OUT nocopy NUMBER );
FUNCTION  GET_PARAMETER_VALUE(p_param_str  IN varchar2,
                              p_param_name IN varchar2,
                              p_param_sep  IN varchar2 default '&',
                              p_value_sep  IN varchar2 default '=') RETURN VARCHAR2;
END BIX_UTIL_PKG;

 

/
