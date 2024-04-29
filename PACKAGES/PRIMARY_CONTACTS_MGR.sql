--------------------------------------------------------
--  DDL for Package PRIMARY_CONTACTS_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PRIMARY_CONTACTS_MGR" AUTHID CURRENT_USER AS
/* $Header: JTFAPRMS.pls 120.1 2005/07/02 02:00:27 appldev ship $ */

  FUNCTION query_primary_contacts(API_VERSION IN NUMBER DEFAULT 1.0,
                                  P_PARTY_ID  IN NUMBER DEFAULT 1) RETURN VARCHAR2;

  PROCEDURE test(API_VERSION  IN NUMBER DEFAULT 1.0,
                 P_PARTY_ID  IN NUMBER DEFAULT 1);

END PRIMARY_CONTACTS_MGR;

 

/
