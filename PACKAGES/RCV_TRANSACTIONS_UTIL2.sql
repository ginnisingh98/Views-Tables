--------------------------------------------------------
--  DDL for Package RCV_TRANSACTIONS_UTIL2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_TRANSACTIONS_UTIL2" AUTHID CURRENT_USER AS
/* $Header: RCVTXUTS.pls 120.0.12010000.5 2010/01/20 09:23:04 smididud noship $ */

PROCEDURE Send_Document( p_entity_id     IN NUMBER,
                         p_entity_type   IN VARCHAR2,
                         p_action_type   IN VARCHAR2,
                         p_document_type IN VARCHAR2,
                         p_organization_id IN NUMBER,
                         p_client_code     IN VARCHAR2 DEFAULT NULL,
                         p_xml_document_id IN NUMBER DEFAULT NULL,
                         x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE Update_Txn_Hist_Success_WF(   Item_type       IN        VARCHAR2,
                                        Item_key        IN        VARCHAR2,
                                        Actid           IN        NUMBER,
                                        Funcmode        IN        VARCHAR2,
                                        Resultout       OUT NOCOPY  VARCHAR2
                                             );

PROCEDURE Update_Txn_History(           p_item_type          IN  VARCHAR2,
                                        p_item_key           IN  VARCHAR2,
                                        p_transaction_status IN  VARCHAR2,
                                        x_return_status      OUT NOCOPY VARCHAR2
                                             );

PROCEDURE Send_Receipt_Confirmation ( P_Entity_ID        IN  NUMBER,
                                      P_Entity_Type      IN  VARCHAR2,
                                      P_Action_Type      IN  VARCHAR2,
                                      P_Document_Type    IN  VARCHAR2,
                                      P_Org_ID           IN  NUMBER,
                                      P_client_code      IN VARCHAR2 DEFAULT NULL,
                                      p_xml_document_id  IN NUMBER DEFAULT NULL,
                                      X_Return_Status    OUT NOCOPY  VARCHAR2 );


END RCV_TRANSACTIONS_UTIL2;

/
