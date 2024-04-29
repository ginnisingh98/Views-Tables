--------------------------------------------------------
--  DDL for Package OE_PUR_CONC_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PUR_CONC_REQUESTS" AUTHID CURRENT_USER AS
/* $Header: OEXCDSPS.pls 120.1.12010000.1 2008/07/25 07:46:13 appldev ship $ */


-- Results for Workflow
--Bug2295434 Changed the data type of date parameters to VARCHAR2 type.
Procedure Request
(ERRBUF                OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 RETCODE               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 /* Moac */
 p_org_id	       IN  NUMBER,
 p_order_number_low    IN  NUMBER,
 p_order_number_high   IN  NUMBER,
 p_request_date_low    IN  VARCHAR2,
 p_request_date_high   IN  VARCHAR2,
 p_customer_po_number  IN  VARCHAR2,
 p_ship_to_location    IN  VARCHAR2,
 p_order_type          IN  VARCHAR2,
 p_customer            IN  VARCHAR2,
 p_item                IN  VARCHAR2
);

END OE_PUR_CONC_REQUESTS;

/
