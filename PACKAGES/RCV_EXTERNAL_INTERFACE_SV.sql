--------------------------------------------------------
--  DDL for Package RCV_EXTERNAL_INTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_EXTERNAL_INTERFACE_SV" AUTHID CURRENT_USER AS
/* $Header: RCVRSEVS.pls 120.0.12010000.4 2010/01/20 09:21:23 smididud noship $ */


PROCEDURE Raise_Event ( p_txn_hist_record   IN     RCV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type,
                        p_xml_document_id   IN     NUMBER DEFAULT NULL,
                        x_return_status     IN OUT NOCOPY  VARCHAR2
                      );


END RCV_EXTERNAL_INTERFACE_SV;

/
