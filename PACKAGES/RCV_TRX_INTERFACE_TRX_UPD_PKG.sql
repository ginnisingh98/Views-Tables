--------------------------------------------------------
--  DDL for Package RCV_TRX_INTERFACE_TRX_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_TRX_INTERFACE_TRX_UPD_PKG" AUTHID CURRENT_USER as
/* $Header: RCVTIR6S.pls 120.0.12010000.2 2013/01/05 16:41:25 wayin ship $ */

   PROCEDURE update_rcv_transaction (
           rcv_trx IN OUT NOCOPY rcv_transactions_interface%ROWTYPE);

  --ROI project start
  g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on;

  TYPE rti_table IS TABLE OF rcv_transactions_interface.interface_transaction_id%TYPE INDEX BY BINARY_INTEGER;

  TYPE group_table IS TABLE OF rcv_transactions_interface.group_id%TYPE INDEX BY BINARY_INTEGER;

  TYPE process_flag IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  PROCEDURE resubmit(p_rti_id_tbl       IN rti_table,
                     p_group_id_tbl     IN group_table,
                     p_process_flag_tbl IN OUT NOCOPY process_flag,
                     p_count            IN NUMBER);
  --ROI project end
END RCV_TRX_INTERFACE_TRX_UPD_PKG;

/
