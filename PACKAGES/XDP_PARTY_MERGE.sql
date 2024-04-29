--------------------------------------------------------
--  DDL for Package XDP_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_PARTY_MERGE" AUTHID CURRENT_USER AS
/* $Header: XDPMERGS.pls 120.4 2006/04/10 23:21:12 dputhiye noship $ */
-- PL/SQL Specification
-- Datastructure Definitions

G_COUNT NUMBER;

PROCEDURE account_merge( request_id NUMBER,
		     set_number NUMBER,
	             process_mode VARCHAR2 );

END XDP_PARTY_MERGE;

 

/
