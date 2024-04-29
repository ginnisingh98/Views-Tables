--------------------------------------------------------
--  DDL for Package RCV_GML_CONV_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_GML_CONV_MIG" AUTHID CURRENT_USER AS
/* $Header: RCVMGGMS.pls 120.0 2005/06/08 13:21:48 pbamb noship $ */
Procedure rcv_mig_gml_data;


PROCEDURE Update_rcv_lot_transactions;
PROCEDURE Update_rcv_supply;
PROCEDURE Update_rcv_lots_supply;


END RCV_GML_CONV_MIG;


 

/
