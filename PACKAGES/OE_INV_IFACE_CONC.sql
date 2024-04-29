--------------------------------------------------------
--  DDL for Package OE_INV_IFACE_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INV_IFACE_CONC" AUTHID CURRENT_USER AS
/* $Header: OEXCIIFS.pls 120.1 2005/06/12 05:19:19 appldev  $ */

-- Results for Workflow

Procedure Request
(ERRBUF                OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 RETCODE               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 /* Moac */
 p_org_id	       IN  NUMBER,
 p_order_number_low    IN  NUMBER,
 p_order_number_high   IN  NUMBER,
 p_request_date_low    IN  DATE,
 p_request_date_high   IN  DATE,
 p_customer_po_number  IN  VARCHAR2,
 p_ship_from_org_id    IN  VARCHAR2,
 p_order_type          IN  VARCHAR2,
 p_customer            IN  VARCHAR2,
 p_item                IN  VARCHAR2
);

END OE_INV_IFACE_CONC;

 

/
