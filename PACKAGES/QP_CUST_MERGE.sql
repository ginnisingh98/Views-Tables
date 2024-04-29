--------------------------------------------------------
--  DDL for Package QP_CUST_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CUST_MERGE" AUTHID CURRENT_USER AS
/* $Header: QPXCMRGS.pls 120.0.12010000.2 2009/04/23 12:17:28 smbalara ship $ */
--for bug 8399386
PROCEDURE Check_Duplicate(p_qualifier_id IN number,
			  p_qualifier_attr_value IN varchar2);

PROCEDURE Merge (req_id         IN  NUMBER,
			  set_num        IN  NUMBER,
			  process_mode   IN  VARCHAR2);

END QP_CUST_MERGE;

/
