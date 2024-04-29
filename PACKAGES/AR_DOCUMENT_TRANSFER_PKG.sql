--------------------------------------------------------
--  DDL for Package AR_DOCUMENT_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_DOCUMENT_TRANSFER_PKG" AUTHID CURRENT_USER as
/*$Header: ARDCUMTS.pls 115.1 2002/09/26 00:49:14 tkoshio noship $ */


procedure insertRow(P_DOCUMENT_TRANSFER_REC IN AR_DOCUMENT_TRANSFERS%ROWTYPE);

procedure deleteRow(P_DOCUMENT_TRANSFER_ID  IN NUMBER);

procedure updateRow(P_DOCUMENT_TRANSFER_REC IN AR_DOCUMENT_TRANSFERS%ROWTYPE);

end;

 

/
