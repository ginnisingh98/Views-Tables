--------------------------------------------------------
--  DDL for Package INV_EXTERNAL_INTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_EXTERNAL_INTERFACE_SV" AUTHID CURRENT_USER AS
/* $Header: INVRSEVS.pls 120.0.12010000.2 2010/02/03 20:35:48 musinha noship $ */


PROCEDURE Raise_Event ( p_txn_hist_record   IN     INV_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type,
                        P_xml_document_id   IN     VARCHAR2,
                        x_return_status     IN OUT NOCOPY  VARCHAR2
		      );


END INV_EXTERNAL_INTERFACE_SV;

/
