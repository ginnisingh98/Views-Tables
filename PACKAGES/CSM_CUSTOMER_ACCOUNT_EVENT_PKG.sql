--------------------------------------------------------
--  DDL for Package CSM_CUSTOMER_ACCOUNT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CUSTOMER_ACCOUNT_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmecats.pls 120.0 2005/11/06 09:37:58 trajasek noship $ */

--the Accounts will get downloaded when the new party id is inserted.
PROCEDURE CUST_ACCOUNTS_INS (p_party_id NUMBER , p_user_id NUMBER);

PROCEDURE CUST_ACCOUNTS_DEL (p_party_id NUMBER , p_user_id NUMBER);

PROCEDURE CUST_ACCOUNTS_UPD (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2);


END CSM_CUSTOMER_ACCOUNT_EVENT_PKG;

 

/
