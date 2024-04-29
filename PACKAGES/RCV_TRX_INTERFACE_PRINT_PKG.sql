--------------------------------------------------------
--  DDL for Package RCV_TRX_INTERFACE_PRINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_TRX_INTERFACE_PRINT_PKG" AUTHID CURRENT_USER as
/* $Header: RCVTIR7S.pls 120.1 2005/06/14 18:17:23 wkunz noship $ */

   PROCEDURE print_rcv_transaction (
      X_interface_transaction_id    IN NUMBER);


END RCV_TRX_INTERFACE_PRINT_PKG;

 

/
