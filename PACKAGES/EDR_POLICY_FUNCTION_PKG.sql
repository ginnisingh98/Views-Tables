--------------------------------------------------------
--  DDL for Package EDR_POLICY_FUNCTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_POLICY_FUNCTION_PKG" AUTHID CURRENT_USER AS
/*  $Header: EDRSECVS.pls 120.0.12000000.1 2007/01/18 05:55:21 appldev ship $ */

FUNCTION psig_view (owner VARCHAR2, objname VARCHAR2) RETURN
    VARCHAR2;

FUNCTION psig_modify (owner VARCHAR2, objname VARCHAR2) RETURN
    VARCHAR2;

FUNCTION psig_delete (owner VARCHAR2, objname VARCHAR2) RETURN
    VARCHAR2;

END edr_policy_function_pkg;

 

/
