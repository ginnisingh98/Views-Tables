--------------------------------------------------------
--  DDL for Package IGI_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_GEN" AUTHID CURRENT_USER AS
-- $Header: igigccas.pls 120.6.12010000.2 2008/08/04 13:02:10 sasukuma ship $

FUNCTION is_req_installed
                (p_option_name VARCHAR2,
     p_org_id      NUMBER) RETURN VARCHAR2;

FUNCTION is_req_installed
                (p_option_name VARCHAR2
    ) RETURN BOOLEAN;  --code modified for MOAC uptake to return Boolean in place of varchar2

PRAGMA RESTRICT_REFERENCES(is_req_installed, WNDS);

PROCEDURE get_option_status
                ( p_option_name IN  VARCHAR2
                , p_status_flag OUT NOCOPY VARCHAR2
                , p_error_num   OUT NOCOPY NUMBER
                );
PROCEDURE DEBUG
                ( p_module          IN VARCHAR2
                , p_module_variable IN VARCHAR2
                , p_variable_value  IN VARCHAR2
                , P_message         IN VARCHAR2
                );


FUNCTION GET_LOOKUP_MEANING  ( l_lookup_type  VARCHAR2) RETURN VARCHAR2;

PROCEDURE IGI_EFC_CHECK_OPTIONS ( p_sob                NUMBER,
                                  p_efc1 IN OUT NOCOPY VARCHAR2 );


FUNCTION get_ap_sob_id RETURN NUMBER;

FUNCTION get_ar_sob_id RETURN NUMBER;

FUNCTION get_po_sob_id RETURN NUMBER;

FUNCTION Get_Igi_Prompt (p_lookup_code In Varchar2) RETURN VARCHAR2;

/*function added to get resonsibility for user in window title*/
FUNCTION get_igi_window_title return varchar2;
END;

/
