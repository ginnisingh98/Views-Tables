--------------------------------------------------------
--  DDL for Package FUN_NET_APAR_UTILS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_NET_APAR_UTILS_GRP" AUTHID CURRENT_USER AS
/* $Header: funntutils.pls 120.0.12010000.2 2008/10/29 06:02:41 ychandra noship $ */
  FUNCTION Get_Invoice_Netted_status (p_invoice_id IN Number) RETURN VARCHAR2;



   PROCEDURE Get_Netting_Batch_Info(p_invoice_id IN Number,x_batch_id OUT NOCOPY Number,x_batch_status OUT NOCOPY VARCHAR2,x_return_status OUT NOCOPY VARCHAR2,x_msg_data OUT NOCOPY VARCHAR2);

END FUN_NET_APAR_UTILS_GRP;

/
