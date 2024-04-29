--------------------------------------------------------
--  DDL for Package POS_URL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_URL_PKG" AUTHID CURRENT_USER AS
/* $Header: POSURLS.pls 120.1.12010000.2 2011/11/01 18:23:43 jatraman ship $ */

TYPE url_parameter_rec IS RECORD (name VARCHAR2(240),value VARCHAR2(240));
TYPE url_parameters_tab IS TABLE OF url_parameter_rec INDEX BY BINARY_INTEGER;

TYPE menu_function_parameter_rec IS RECORD (OAHP VARCHAR2(240),OASF VARCHAR2(240));

-- Return the url for the external web server for suppliers.
-- Example: http://host.example.com:8888/
FUNCTION get_external_url RETURN VARCHAR2;

-- Return the url for an internal web server.
-- Example value, http://host.example.com:8888/
FUNCTION get_internal_url RETURN VARCHAR2;

-- Return the login url at the external web server for suppliers.
-- Example: http://host.example.com:8888/oa_servlets/oracle.apps.fnd.sso.AppsLogin
FUNCTION get_external_login_url RETURN VARCHAR2;

-- Return the login url at an internal web server
-- Example: http://host.example.com:8888/oa_servlets/oracle.apps.fnd.sso.AppsLogin
FUNCTION get_internal_login_url RETURN VARCHAR2;

FUNCTION get_dest_page_url (p_dest_func IN VARCHAR2, p_notif_performer IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_ntf_vendor_id (p_ntf_id IN NUMBER) RETURN NUMBER;

FUNCTION get_buyer_login_url RETURN VARCHAR2;

END pos_url_pkg;

/
