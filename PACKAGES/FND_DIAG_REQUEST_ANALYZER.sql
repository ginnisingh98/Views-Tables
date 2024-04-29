--------------------------------------------------------
--  DDL for Package FND_DIAG_REQUEST_ANALYZER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DIAG_REQUEST_ANALYZER" AUTHID CURRENT_USER AS
/* $Header: AFCPDRAS.pls 120.0.12010000.1 2009/06/19 16:16:16 ggupta noship $*/
  PROCEDURE runtest(exec_obj IN OUT jtf_diag_execution_obj,   result OUT nocopy VARCHAR2);
  PROCEDURE gettestname(str OUT nocopy VARCHAR2);
  PROCEDURE gettestdesc(str OUT nocopy VARCHAR2);
  PROCEDURE getdefaulttestparams(defaultinputvalues OUT nocopy jtf_diag_test_inputs);
  PROCEDURE geterror(str OUT nocopy VARCHAR2);
  PROCEDURE getfixinfo(str OUT nocopy VARCHAR2);
  PROCEDURE iswarning(str OUT nocopy VARCHAR2);
  PROCEDURE isfatal(str OUT nocopy VARCHAR2);
  FUNCTION get_status(p_status_code VARCHAR2) RETURN VARCHAR2;
  FUNCTION get_phase(p_phase_code VARCHAR2) RETURN VARCHAR2;
  PROCEDURE manager_check(req_id IN NUMBER,   cd_id IN NUMBER,   mgr_defined OUT nocopy boolean,   mgr_active OUT nocopy boolean,   mgr_workshift OUT nocopy boolean,   mgr_running OUT nocopy boolean,   run_alone OUT nocopy boolean);
  PROCEDURE print_mgrs(p_req_id IN NUMBER,   inner_section IN OUT nocopy jtf_diag_section,   reportcontext IN jtf_diag_report_context);
END;

/
