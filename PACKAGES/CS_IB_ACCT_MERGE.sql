--------------------------------------------------------
--  DDL for Package CS_IB_ACCT_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_IB_ACCT_MERGE" AUTHID CURRENT_USER AS
/* $Header: csimergs.pls 115.9 2003/01/28 19:53:47 rmamidip noship $ */

   PROCEDURE MERGE(req_id   IN NUMBER,
                   set_number   IN NUMBER,
                   process_mode IN VARCHAR2);

   PROCEDURE CUSTOMER_PRODUCTS_MERGE(req_id   IN NUMBER,
	   					       set_number   IN NUMBER,
						       process_mode IN VARCHAR2);

   PROCEDURE SYSTEMS_ALL_MERGE(req_id   IN NUMBER,
					      set_number   IN NUMBER,
					      process_mode IN VARCHAR2);
END CS_IB_ACCT_MERGE;

 

/
