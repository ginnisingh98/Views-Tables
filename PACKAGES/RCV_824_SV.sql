--------------------------------------------------------
--  DDL for Package RCV_824_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_824_SV" AUTHID CURRENT_USER AS
/* $Header: RCV824S.pls 120.2 2005/09/14 23:03:08 pchintal noship $ */

/* This procedure will call the EDI apis as required */

/*==================================================================*/

 PROCEDURE  RCV_824_INSERT (X_Interface_Header      IN  RCV_ROI_PREPROCESSOR.header_rec_type,
                            X_Type                  IN  VARCHAR2);


   PROCEDURE rcv_824_insert(
      x_interface_header IN rcv_shipment_header_sv.headerrectype,
      x_type             IN VARCHAR2);

END RCV_824_SV;

 

/
