--------------------------------------------------------
--  DDL for Package QP_CUST_MRG_DATA_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CUST_MRG_DATA_CLEANUP" AUTHID CURRENT_USER AS
/* $Header: QPXCMDCS.pls 120.0 2005/06/02 00:54:59 appldev noship $ */

PROCEDURE Merge (req_id         IN  NUMBER,
		 set_num        IN  NUMBER,
		 process_mode   IN  VARCHAR2);

END QP_CUST_MRG_DATA_CLEANUP;

 

/
