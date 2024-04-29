--------------------------------------------------------
--  DDL for Package OPI_DBI_BOUNDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_BOUNDS_PKG" AUTHID CURRENT_USER AS
--$Header: OPIINVBNDS.pls 120.3 2005/11/29 05:18:34 srayadur noship $

PROCEDURE maintain_opi_dbi_logs(p_etl_type  IN  VARCHAR2,
                                p_load_type  VARCHAR2);

PROCEDURE call_etl_specific_bound(p_etl_type  IN  VARCHAR2,
                          				p_load_type  VARCHAR2);

PROCEDURE setup_inv_mmt_bounds(p_load_type  VARCHAR2);

PROCEDURE setup_cogs_mmt_bounds(p_load_type  VARCHAR2);

PROCEDURE create_first_mmt_bounds(p_etl_type  IN  VARCHAR2);

PROCEDURE set_mmt_new_bounds(p_etl_type  IN  VARCHAR2,p_load_type IN VARCHAR2);

PROCEDURE setup_inv_wta_bounds(p_load_type  IN  VARCHAR2);

PROCEDURE set_sysdate_bounds(p_load_type  IN  VARCHAR2, p_etl_type IN VARCHAR2, p_driving_table_code IN VARCHAR2);

PROCEDURE setup_cc_mmt_bounds(p_load_type  IN  VARCHAR2);

PROCEDURE set_load_successful(p_etl_type  IN  VARCHAR2,
                              p_load_type  VARCHAR2);

PROCEDURE print_opi_org_bounds(p_etl_type IN VARCHAR2,
				p_load_type IN VARCHAR2);

FUNCTION bounds_uncosted(p_etl_type IN VARCHAR2, p_load_type IN VARCHAR2) return BOOLEAN;

-- Forward declaration
PROCEDURE write (p_pkg_name    IN VARCHAR2,
                 p_proc_name   IN VARCHAR2,
                 p_stmt_no     IN NUMBER  ,
                 p_debug_msg   IN VARCHAR2);

PROCEDURE load_opm_org_ledger_data;

END opi_dbi_bounds_pkg;

 

/
