--------------------------------------------------------
--  DDL for Package WSH_PROCESS_INTERFACED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PROCESS_INTERFACED_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHINPSS.pls 120.0.12010000.2 2009/03/24 00:01:16 brana ship $ */

   c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
   c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;

   l_trns_history_rec   wsh_transactions_history_pkg.txns_history_record_type;

/* WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type will have the following
   Important Fields.
      DOC_TYPE
      DOC_NUMBER
      TRADING_PARTNER_ID
      ACTION_TYPE
      ENTITY_TYPE
      ENTITY_NUMBER
      ORIG_DOCUMENT_NUMBER */


   PROCEDURE process_inbound (
      l_trns_history_rec   IN       WSH_TRANSACTIONS_HISTORY_PKG.txns_history_record_type,
      x_return_status      OUT NOCOPY       VARCHAR2
   );

   PROCEDURE derive_ids (
      p_delivery_interface_id   IN       NUMBER,
      p_document_type           IN       VARCHAR2,
      x_return_status           OUT NOCOPY       VARCHAR2
   );

   PROCEDURE delete_interface_records (
      p_delivery_interface_id   IN       NUMBER,
      x_return_status           OUT NOCOPY       VARCHAR2
   );

 -- R12.1.1 STANDALONE PROJECT
/*=======================================================================================

PROCEDURE NAME : Delete_Interface_Records

This Procedure will be used to delete record in the different interface tables, after data
is populated in the base tables

=======================================================================================*/
   PROCEDURE delete_interface_records (
      p_del_interface_id_tbl       IN          WSH_UTIL_CORE.Id_Tab_Type,
      p_del_det_interface_id_tbl   IN          WSH_UTIL_CORE.Id_Tab_Type,
      p_del_assgn_interface_id_tbl IN          WSH_UTIL_CORE.Id_Tab_Type,
      p_del_error_interface_id_tbl IN          WSH_UTIL_CORE.Id_Tab_Type,
      p_det_error_interface_id_tbl IN          WSH_UTIL_CORE.Id_Tab_Type,
      x_return_status              OUT NOCOPY  VARCHAR2
   );

END wsh_process_interfaced_pkg;

/
