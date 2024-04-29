--------------------------------------------------------
--  DDL for Package FV_ASSIGN_REASON_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_ASSIGN_REASON_CODES_PKG" AUTHID CURRENT_USER AS
--$Header: FVXPPRCS.pls 120.2 2005/12/05 05:14:32 anvijaya ship $

    PROCEDURE interest_reason_codes;
    PROCEDURE get_quick_payments;
    procedure set_org(x_org_id IN number);

END fv_assign_reason_codes_pkg;

 

/
