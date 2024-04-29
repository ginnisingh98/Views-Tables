--------------------------------------------------------
--  DDL for Package ACCOUNT_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ACCOUNT_MGR" AUTHID CURRENT_USER AS
/* $Header: JTFAACTS.pls 120.1 2005/07/02 01:59:21 appldev ship $ */

  FUNCTION query_accounts(API_VERSION IN NUMBER DEFAULT 1.0,
                          P_PARTY_ID  IN NUMBER DEFAULT 1220) RETURN VARCHAR2;

  PROCEDURE test(API_VERSION IN NUMBER DEFAULT 1.0,
                 P_PARTY_ID  IN NUMBER DEFAULT 1220);

END ACCOUNT_MGR;

 

/
