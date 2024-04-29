--------------------------------------------------------
--  DDL for Package MO_GLOBAL_SERVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MO_GLOBAL_SERVER" AUTHID CURRENT_USER AS
/* $Header: AFMOGBWS.pls 120.2 2006/10/21 00:14:42 sryu noship $ */

PROCEDURE set_policy_context_server(p_access_mode VARCHAR2,
                             p_org_id      NUMBER);

FUNCTION get_current_org_id_server RETURN NUMBER;
FUNCTION is_mo_init_done_server RETURN VARCHAR2;
FUNCTION get_ou_name_server(p_org_id NUMBER) RETURN VARCHAR2;
FUNCTION check_access_server(p_org_id NUMBER) RETURN VARCHAR2;

  PROCEDURE init_server(p_appl_short_name VARCHAR2);
  PROCEDURE set_org_context_server(p_org_id_char VARCHAR2,
                            p_sp_id_char  VARCHAR2,
                            p_appl_short_name VARCHAR2);
  FUNCTION check_valid_org_server(p_org_id NUMBER) RETURN VARCHAR2;
  FUNCTION get_access_mode_server RETURN VARCHAR2;
  FUNCTION is_multi_org_enabled_server RETURN VARCHAR2;
  FUNCTION get_ou_count_server RETURN NUMBER;
  FUNCTION get_valid_org_server(p_org_id NUMBER) RETURN NUMBER;
  PROCEDURE validate_orgid_pub_api_server(org_id IN OUT NOCOPY NUMBER,
                                   error_mesg_suppr IN VARCHAR2 DEFAULT 'N',
                                   status OUT NOCOPY VARCHAR2);


-- The following are cover for MO_UTILS

FUNCTION get_set_of_books_name_server (p_operating_unit IN NUMBER) RETURN VARCHAR2;
PROCEDURE get_set_of_books_info_server(p_operating_unit IN NUMBER,
                                p_sob_id OUT NOCOPY NUMBER,
                                p_sob_name OUT NOCOPY VARCHAR2);
FUNCTION get_ledger_name_server (p_operating_unit IN NUMBER) RETURN VARCHAR2;
PROCEDURE get_default_ou_server(p_default_org_id  OUT NOCOPY NUMBER
                              , p_default_ou_name OUT NOCOPY VARCHAR2
                              , p_ou_count        OUT NOCOPY NUMBER);
PROCEDURE get_ledger_info_server (p_operating_unit IN NUMBER,
                           p_ledger_id OUT NOCOPY NUMBER,
                           p_ledger_name OUT NOCOPY VARCHAR2);
FUNCTION get_multi_org_flag_server RETURN VARCHAR2;
FUNCTION get_child_tab_orgs_server (p_table_name IN VARCHAR2, p_where IN VARCHAR2) RETURN VARCHAR2;
FUNCTION check_org_in_sp_server (p_org_id IN NUMBER, p_org_class IN VARCHAR2) RETURN VARCHAR2;
FUNCTION check_ledger_in_sp_server (p_ledger_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_org_name_server (p_org_id IN NUMBER) RETURN VARCHAR2;

end mo_global_server;

 

/
