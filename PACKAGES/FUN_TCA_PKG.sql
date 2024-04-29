--------------------------------------------------------
--  DDL for Package FUN_TCA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_TCA_PKG" AUTHID CURRENT_USER AS
/* $Header: FUNSTCAS.pls 120.5.12000000.5 2007/07/20 09:35:29 srampure ship $*/

PROCEDURE find_party(p_party_name IN VARCHAR2  , p_party_type IN VARCHAR2   , p_dqm_context OUT NOCOPY NUMBER  , p_dqm_count OUT NOCOPY NUMBER);
FUNCTION is_intercompany_org (p_party_id NUMBER)   RETURN VARCHAR2;
FUNCTION is_intercompany_org_valid (p_party_id NUMBER , p_as_date DATE default null ) RETURN VARCHAR2;
PROCEDURE get_ic_org_valid_dates (p_party_id IN NUMBER , effective_start_date OUT NOCOPY DATE, effective_end_date OUT NOCOPY DATE );
FUNCTION get_le_id (p_party_id in NUMBER, p_as_date in DATE default null) RETURN NUMBER;
FUNCTION get_ou_id (p_party_id in NUMBER  , p_as_date in DATE default null)     RETURN NUMBER;
FUNCTION get_system_reference(p_party_id NUMBER)    RETURN VARCHAR2;
FUNCTION CF_TRANSACTING_ENTITY_FLAG(p_party_id in NUMBER, p_date DATE default null) RETURN VARCHAR2;
PROCEDURE is_party_exist (l_party_name in VARCHAR2, flag out NOCOPY VARCHAR2);
end FUN_TCA_PKG;

 

/
