--------------------------------------------------------
--  DDL for Package Body MO_GLOBAL_SERVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MO_GLOBAL_SERVER" AS
/* $Header: AFMOGBWB.pls 120.2 2006/10/21 00:15:15 sryu noship $ */

-- Name
--   set_policy_context
PROCEDURE set_policy_context_server(p_access_mode VARCHAR2,
                                    p_org_id      NUMBER) IS
BEGIN
  mo_global.set_policy_context(p_access_mode, p_org_id);
END set_policy_context_server;
--
-- Name
--   get_current_org_id
FUNCTION get_current_org_id_server RETURN NUMBER
IS
BEGIN
   RETURN (mo_global.get_current_org_id);
END get_current_org_id_server;
--
--
FUNCTION is_mo_init_done_server RETURN VARCHAR2 IS
BEGIN
  RETURN(mo_global.is_mo_init_done);
END is_mo_init_done_server;
--
--
FUNCTION check_access_server(p_org_id NUMBER) RETURN VARCHAR2 IS
BEGIN
   RETURN(mo_global.check_access(p_org_id));
END check_access_server;
--
--
FUNCTION get_ou_name_server(p_org_id NUMBER) RETURN VARCHAR2 IS
BEGIN
   RETURN(mo_global.get_ou_name(p_org_id));
END get_ou_name_server;
--
--
PROCEDURE init_server(p_appl_short_name VARCHAR2) IS
BEGIN
   mo_global.init(p_appl_short_name);
END init_server;
--
--
PROCEDURE set_org_context_server(p_org_id_char VARCHAR2,
                            p_sp_id_char  VARCHAR2,
                            p_appl_short_name VARCHAR2) IS
BEGIN
  mo_global.set_org_context(p_org_id_char,p_sp_id_char,p_appl_short_name);
END set_org_context_server;
--
--
FUNCTION check_valid_org_server(p_org_id NUMBER) RETURN VARCHAR2 IS
BEGIN
  RETURN(mo_global.check_valid_org(p_org_id));
END check_valid_org_server;
--
--
FUNCTION get_access_mode_server RETURN VARCHAR2 IS
BEGIN
  RETURN(mo_global.get_access_mode);
END get_access_mode_server;
--
--
FUNCTION is_multi_org_enabled_server RETURN VARCHAR2 IS
BEGIN
  RETURN(mo_global.is_multi_org_enabled);
END is_multi_org_enabled_server;
--
--
FUNCTION get_ou_count_server RETURN NUMBER IS
BEGIN
  RETURN(mo_global.get_ou_count);
END get_ou_count_server;
--
--
FUNCTION get_valid_org_server(p_org_id NUMBER) RETURN NUMBER IS
BEGIN
  RETURN(mo_global.get_valid_org(p_org_id));
END get_valid_org_server;
--
--
PROCEDURE validate_orgid_pub_api_server(org_id IN OUT NOCOPY NUMBER,
                                   error_mesg_suppr IN VARCHAR2,
                                   status OUT NOCOPY VARCHAR2) IS
BEGIN
  mo_global.validate_orgid_pub_api(org_id, error_mesg_suppr, status);
END validate_orgid_pub_api_server;

--
--  The following are cover for MO_UTILS
FUNCTION get_set_of_books_name_server (p_operating_unit IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  RETURN(mo_utils.get_set_of_books_name(p_operating_unit));
END get_set_of_books_name_server;
--
PROCEDURE get_set_of_books_info_server(p_operating_unit IN NUMBER,
                                p_sob_id OUT NOCOPY NUMBER,
                                p_sob_name OUT NOCOPY VARCHAR2) IS
BEGIN
  mo_utils.get_set_of_books_info(p_operating_unit,p_sob_id,p_sob_name);
END get_set_of_books_info_server;
--
FUNCTION get_ledger_name_server (p_operating_unit IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  RETURN(mo_utils.get_ledger_name(p_operating_unit));
END get_ledger_name_server;
--
PROCEDURE get_ledger_info_server (p_operating_unit IN NUMBER,
                           p_ledger_id OUT NOCOPY NUMBER,
                           p_ledger_name OUT NOCOPY VARCHAR2) IS
BEGIN
  mo_utils.get_ledger_info(p_operating_unit, p_ledger_id, p_ledger_name);
END get_ledger_info_server;
--
PROCEDURE get_default_ou_server (  p_default_org_id  OUT NOCOPY NUMBER
                          , p_default_ou_name OUT NOCOPY VARCHAR2
                          , p_ou_count        OUT NOCOPY NUMBER) IS
BEGIN
  mo_utils.get_default_ou(p_default_org_id, p_default_ou_name, p_ou_count);
END get_default_ou_server;
--
FUNCTION get_multi_org_flag_server RETURN VARCHAR2 IS
BEGIN
  RETURN(mo_utils.get_multi_org_flag);
END get_multi_org_flag_server;
--
FUNCTION get_child_tab_orgs_server (p_table_name IN VARCHAR2, p_where IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN(mo_utils.get_child_tab_orgs(p_table_name,p_where));
END get_child_tab_orgs_server;
--
FUNCTION check_org_in_sp_server (p_org_id IN NUMBER, p_org_class IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN(mo_utils.check_org_in_sp(p_org_id,p_org_class));
END check_org_in_sp_server;
--
FUNCTION check_ledger_in_sp_server (p_ledger_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  RETURN(mo_utils.check_ledger_in_sp(p_ledger_id));
END check_ledger_in_sp_server;
--
FUNCTION get_org_name_server(p_org_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  RETURN(mo_utils.get_org_name(p_org_id));
END get_org_name_server;
--


END mo_global_server;

/
