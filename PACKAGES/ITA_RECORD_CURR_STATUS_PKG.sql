--------------------------------------------------------
--  DDL for Package ITA_RECORD_CURR_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITA_RECORD_CURR_STATUS_PKG" AUTHID CURRENT_USER as
/* $Header: itarcurs.pls 120.4 2006/11/09 01:16:10 cpetriuc noship $ */

PROCEDURE enable_tracking(errbuf  OUT NOCOPY VARCHAR2,
                      retcode OUT NOCOPY VARCHAR2, p_table_name IN VARCHAR2);

FUNCTION enable_tracking_for_table
(p_application_id IN NUMBER,
 p_table_name     IN VARCHAR2)
RETURN NUMBER;

FUNCTION set_audit_start_date
(p_application_id IN NUMBER,
 p_table_name     IN VARCHAR2)
RETURN NUMBER;

FUNCTION get_shadow_table_prefix
(p_table_name     IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION create_shadow_trigger
(p_application_id IN NUMBER,
 p_table_name     IN VARCHAR2)
RETURN NUMBER;

FUNCTION record_current_state
(p_application_id IN NUMBER,
 p_table_name     IN VARCHAR2)
RETURN NUMBER;

FUNCTION record_profile_current_state
(p_application_id IN NUMBER,
 p_table_name     IN VARCHAR2)
RETURN NUMBER;

FUNCTION get_profile_value_meaning
(p_profile_sql        IN VARCHAR2,
 p_profile_value_code IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION strip_profile_query
(p_profile_sql        IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION strip_double_quotes
(p_profile_sql        IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION strip_aliases
(p_profile_sql        IN VARCHAR2)
RETURN VARCHAR2;

end ITA_RECORD_CURR_STATUS_PKG;

 

/
