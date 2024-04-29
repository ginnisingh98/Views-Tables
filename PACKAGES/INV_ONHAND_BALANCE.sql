--------------------------------------------------------
--  DDL for Package INV_ONHAND_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ONHAND_BALANCE" AUTHID CURRENT_USER AS
/* $Header: INVEINVS.pls 120.0.12010000.4 2010/04/07 23:47:17 kdong noship $ */

PROCEDURE Raise_Event  ( p_txn_hist_record   IN     INV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type,
                         p_xml_document_id   IN     NUMBER DEFAULT NULL,
                         x_return_status     IN OUT NOCOPY  VARCHAR2);

PROCEDURE Send_Onhand_Document (P_Entity_ID        IN  NUMBER,
                                P_Entity_Type      IN  VARCHAR2,
                                P_Action_Type      IN  VARCHAR2,
                                P_Document_Type    IN  VARCHAR2,
                                P_Org_ID           IN  NUMBER,
                                P_client_code      IN VARCHAR2 DEFAULT NULL,
                                p_xml_document_id  IN NUMBER DEFAULT NULL,
                                X_Return_Status    OUT NOCOPY  VARCHAR2 );

PROCEDURE send_onhand   (x_errbuf          OUT  NOCOPY VARCHAR2,
                         x_retcode         OUT  NOCOPY NUMBER,
                         p_org_id          IN NUMBER,
                         p_deploy_mode     IN NUMBER DEFAULT null,
                         p_client_code     IN VARCHAR2,
                         p_warehouse_id    IN NUMBER,
                         p_client          IN VARCHAR2,
                         p_item_id         IN NUMBER,
                         p_subinventory    IN VARCHAR2,
                         p_locator         IN VARCHAR2,
                         p_lot             IN VARCHAR2,
                         p_grp             IN NUMBER DEFAULT 1,
                         p_display_lot     IN NUMBER DEFAULT 2);

END inv_onhand_balance;

/
