--------------------------------------------------------
--  DDL for Package RCV_TRX_INTERFACE_TRX_INS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_TRX_INTERFACE_TRX_INS_PKG" AUTHID CURRENT_USER as
/* $Header: RCVTIR5S.pls 115.1 2002/11/23 00:57:58 sbull ship $ */

   PROCEDURE insert_rcv_transaction (
           rcv_trx IN OUT NOCOPY rcv_transactions_interface%ROWTYPE);

END RCV_TRX_INTERFACE_TRX_INS_PKG;

 

/
