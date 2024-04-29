--------------------------------------------------------
--  DDL for Package PY_AUDIT_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_AUDIT_REP_PKG" AUTHID CURRENT_USER as
/* $Header: pyadyn.pkh 120.1.12000000.1 2007/01/17 15:19:43 appldev ship $ */
   procedure py_audit_rep_proc
   (p_table       VARCHAR2,
    p_primary     VARCHAR2,
    p_session_id  NUMBER,
    p_start_date  VARCHAR2,
    p_end_date    VARCHAR2,
    p_username    VARCHAR2,
    p_table_type  VARCHAR2);
end py_audit_rep_pkg;

 

/
