--------------------------------------------------------
--  DDL for Package RCV_BUSINESS_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_BUSINESS_EVENTS" AUTHID CURRENT_USER AS
/* $Header: RCVBZEVS.pls 120.0.12000000.1 2007/01/16 23:28:11 appldev ship $ */

PROCEDURE Raise_Receive_Txn (
		p_group_id		NUMBER,
		p_request_id	NUMBER);
END RCV_BUSINESS_EVENTS;

 

/
