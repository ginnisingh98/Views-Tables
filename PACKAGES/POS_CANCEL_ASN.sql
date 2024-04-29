--------------------------------------------------------
--  DDL for Package POS_CANCEL_ASN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_CANCEL_ASN" AUTHID CURRENT_USER AS
/* $Header: POSASNCS.pls 115.5 2004/05/07 18:49:46 abtrived ship $*/

PROCEDURE cancel_asn  (
	p_shipment_num		IN 	VARCHAR2,
        p_invoice_num		IN	VARCHAR2,
        p_processing_status	IN	VARCHAR2,
 	p_vendor_id		IN	NUMBER,
	p_vendor_site_id	IN	NUMBER,
 	p_result		IN OUT NOCOPY 	NUMBER,
 	p_error_code		IN OUT NOCOPY 	VARCHAR2);


FUNCTION get_processing_status  (
	p_shipment_num		VARCHAR2,
 	p_vendor_id		NUMBER,
	p_vendor_site_id	NUMBER	 )
return VARCHAR2;


FUNCTION get_cancellation_status  (
	p_shipment_num		VARCHAR2,
 	p_vendor_id		NUMBER,
	p_vendor_site_id	NUMBER	 )
return VARCHAR2;

PROCEDURE find_processing_cancellation (
       p_shipment_num  IN      VARCHAR2,
       p_vendor_id     IN      NUMBER,
       p_vendor_site_id   IN   NUMBER,
       x_processing_status OUT NOCOPY VARCHAR2,
       x_processing_dsp OUT NOCOPY VARCHAR2,
       x_cancellation_status OUT NOCOPY VARCHAR2,
       x_cancellation_dsp OUT NOCOPY VARCHAR2);


PROCEDURE find_processing_cancellation (
       p_shipment_num  IN      VARCHAR2,
       p_header_id IN NUMBER,
       p_vendor_id     IN      NUMBER,
       p_vendor_site_id   IN   NUMBER,
       x_processing_status OUT NOCOPY VARCHAR2,
       x_processing_dsp OUT NOCOPY VARCHAR2,
       x_cancellation_status OUT NOCOPY VARCHAR2,
       x_cancellation_dsp OUT NOCOPY VARCHAR2);

FUNCTION get_line_status  (
	p_shipment_line_id	NUMBER)
RETURN VARCHAR2;

END POS_CANCEL_ASN;


 

/
