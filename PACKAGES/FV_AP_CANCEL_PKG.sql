--------------------------------------------------------
--  DDL for Package FV_AP_CANCEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_AP_CANCEL_PKG" AUTHID CURRENT_USER AS
/* $Header: FVAPCANS.pls 120.0 2006/01/04 21:48:18 ksriniva noship $ */

FUNCTION Open_PO_Shipment(P_Invoice_Id 	IN   NUMBER,
			  P_Return_Code OUT NOCOPY VARCHAR2
			 ) return BOOLEAN ;


END FV_AP_CANCEL_PKG;


 

/
