--------------------------------------------------------
--  DDL for Package RCV_GARBAGE_COLLECTOR_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_GARBAGE_COLLECTOR_SV" AUTHID CURRENT_USER as
/* $Header: RCVGARBS.pls 120.0.12010000.1 2008/07/24 14:35:26 appldev ship $  */
/*===========================================================================
  PACKAGE NAME:		RCV_GARBAGE_COLLECTOR_SV

  DESCRIPTION:          Contains the server side APIs which will identify
                        Garbage data.
                        eg : Invalid/Missing PO numbers
                        For Bug 2367174

  CLIENT/SERVER:	Server

  LIBRARY NAME          NONE

  OWNER:                SHVISWAN

  PROCEDURES/FUNCTIONS:

============================================================================*/

/*===========================================================================
  PROCEDURE NAME:	collect_garbage(v_request_id in  number)

  DESCRIPTION:          marks the rows in the rcv_transactions_interface and
                        rcv_headers_interface that have either invalid or
                        missing PO numbers.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Created by SHVISWAN 13-MAY-02

                        BAO   24-OCT-02  bug2626270
                              Added p_group_id as a new parameter.
                              Changed v_request_id to p_request_id

===========================================================================*/

 PROCEDURE collect_garbage (p_request_id IN NUMBER,
                            p_group_id   IN NUMBER); -- bug2626270

 END RCV_GARBAGE_COLLECTOR_SV;


/
