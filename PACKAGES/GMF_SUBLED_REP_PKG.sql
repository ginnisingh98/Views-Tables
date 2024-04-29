--------------------------------------------------------
--  DDL for Package GMF_SUBLED_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_SUBLED_REP_PKG" AUTHID CURRENT_USER AS
/* $Header: GMFDSURS.pls 120.1.12010000.2 2008/11/11 16:26:42 rpatangy ship $ */

 FUNCTION BeforeReportTrigger RETURN BOOLEAN;
  /* Report parameters */
        P_REFERENCE_NO    gmf_xla_extract_headers.reference_no%TYPE;
        P_LEGAL_ENTITY    gmf_xla_extract_headers.legal_entity_id%TYPE;
        P_LEDGER          gmf_xla_extract_headers.ledger_id%TYPE;
        P_COST_TYPE       gmf_xla_extract_headers.valuation_cost_type_id%TYPE;
        P_FISCAL_YEAR     NUMBER;
        P_PERIOD          NUMBER;
        P_START_DATE      gmf_xla_extract_headers.transaction_date%TYPE;
        P_END_DATE        gmf_xla_extract_headers.transaction_date%TYPE;
        P_ENTITY_CODE     gmf_xla_extract_headers.entity_code%TYPE;
        P_EVENT_CLASS     gmf_xla_extract_headers.event_class_code%TYPE;
        P_EVENT_TYPE      gmf_xla_extract_headers.event_type_code%TYPE;

        p_where_clause  VARCHAR2(2000);
/*
 FUNCTION BeforeReportTrigger(P_REFERENCE_NO  IN NUMBER,
                                P_LEGAL_ENTITY  IN NUMBER,
                                P_LEDGER        IN NUMBER,
                                P_COST_TYPE     IN NUMBER,
                                P_FISCAL_YEAR   IN NUMBER,
                                P_PERIOD        IN NUMBER,
                                P_START_DATE    IN DATE,
                                P_END_DATE      IN DATE,
                                P_ENTITY_CODE   IN VARCHAR2,
                                P_EVENT_CLASS   IN VARCHAR2,
                                P_EVENT_TYPE    IN VARCHAR2) RETURN VARCHAR2;
*/


 FUNCTION get_le_name(p_le_id IN NUMBER) RETURN VARCHAR2;

 FUNCTION get_ledger_name(p_led_id IN NUMBER) RETURN VARCHAR2;

 FUNCTION get_cost_type(p_ct_id IN NUMBER) RETURN VARCHAR2;

 FUNCTION get_organization_code (p_org_id IN NUMBER,p_ref_no IN NUMBER) RETURN VARCHAR2;

 FUNCTION get_item_desc( p_item_id IN NUMBER, p_org_id IN NUMBER) RETURN  VARCHAR2;

 FUNCTION get_org_name( p_org_id IN NUMBER) RETURN  VARCHAR2;

 FUNCTION get_entity_code_desc(p_entity_cd IN VARCHAR2) RETURN VARCHAR2;

 FUNCTION get_event_class_desc(p_entity_cd IN VARCHAR2, p_event_class_cd IN VARCHAR2) RETURN VARCHAR2;

 FUNCTION get_event_type_desc(p_entity_cd IN VARCHAR2, p_event_class_cd IN VARCHAR2,p_event_type_cd IN VARCHAR2) RETURN VARCHAR2;

 FUNCTION get_where_clause  RETURN VARCHAR2;

END gmf_subled_rep_pkg;

/
