--------------------------------------------------------
--  DDL for Package INV_INTER_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INTER_INVOICE" AUTHID CURRENT_USER AS
/* $Header: INVITCIS.pls 120.0.12000000.1 2007/01/17 16:18:14 appldev ship $ */

PROCEDURE update_invoice_flag(p_header_id IN NUMBER,
			      p_line_id   IN NUMBER );

END INV_INTER_INVOICE;


 

/
