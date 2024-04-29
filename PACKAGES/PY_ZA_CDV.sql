--------------------------------------------------------
--  DDL for Package PY_ZA_CDV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_CDV" AUTHID CURRENT_USER AS
/* $Header: pyzacdv1.pkh 120.0.12010000.1 2008/07/28 00:02:52 appldev ship $ */

FUNCTION common_validation
(x_branch_code     IN varchar2,
 x_account_number  IN varchar2,
 x_account_type    IN number)
 RETURN VARCHAR2;

Pragma restrict_references (common_validation, WNPS, WNDS);

END py_za_cdv;

/
