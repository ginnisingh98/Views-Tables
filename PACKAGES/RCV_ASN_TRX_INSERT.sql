--------------------------------------------------------
--  DDL for Package RCV_ASN_TRX_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ASN_TRX_INSERT" AUTHID CURRENT_USER as
/* $Header: RCVAHTXS.pls 115.2 2002/11/25 21:46:10 sbull ship $ */
/*===========================================================================
  PACKAGE NAME:		RCV_ASN_TRX_INSERT

  DESCRIPTION:          Contains the procedure for going thru the pl/sql
                        table. The procedure deletes the original row and
                        inserts the pl/sql table rows into rcv_transactions_interface


  CLIENT/SERVER:	Server

  LIBRARY NAME          NONE

  OWNER:                Raj Bhakta

  PROCEDURES/FUNCTIONS:

============================================================================*/

PROCEDURE HANDLE_RCV_ASN_TRANSACTIONS (V_TRANS_TAB        IN OUT NOCOPY RCV_SHIPMENT_OBJECT_SV.CASCADED_TRANS_TAB_TYPE,
                                       V_header_record    IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.HEADERRECTYPE);

PROCEDURE INSERT_CANCELLED_ASN_LINES   (V_header_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.HEADERRECTYPE);

END RCV_ASN_TRX_INSERT;

 

/
