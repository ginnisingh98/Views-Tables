--------------------------------------------------------
--  DDL for Package ECE_CDMO_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_CDMO_UTIL" AUTHID CURRENT_USER as
-- $Header: ECCDMOS.pls 120.3 2005/09/28 07:33:23 arsriniv noship $
  PROCEDURE Update_AR ( Document_Type               IN  VARCHAR2,
                        Transaction_ID              IN  NUMBER,
                        Installment_Number          IN  NUMBER,
                        Multiple_Installments_Flag  IN  VARCHAR2,
                        Maximum_Installment_Number  IN  NUMBER,
                        Update_Date                 IN  DATE );

PROCEDURE GET_REMIT_ADDRESS (
	customer_trx_id 	IN 	NUMBER,
	remit_to_address1 	OUT NOCOPY 	VARCHAR2,
	remit_to_address2 	OUT NOCOPY 	VARCHAR2,
	remit_to_address3 	OUT NOCOPY 	VARCHAR2,
	remit_to_address4 	OUT NOCOPY 	VARCHAR2,
	remit_to_city		OUT NOCOPY	VARCHAR2,
	remit_to_county		OUT NOCOPY	VARCHAR2,
	remit_to_state		OUT NOCOPY	VARCHAR2,
	remit_to_province	OUT NOCOPY	VARCHAR2,
	remit_to_country	OUT NOCOPY	VARCHAR2,
        remit_to_code_int       OUT NOCOPY VARCHAR2,
	remit_to_postal_code	OUT NOCOPY	VARCHAR2);

PROCEDURE GET_PAYMENT (
	customer_trx_id 	    	IN 	NUMBER,
	installment_number		IN	NUMBER,
	multiple_installments_flag	OUT NOCOPY	VARCHAR2,
	maximum_installment_number	OUT NOCOPY	NUMBER,
	amount_tax_due	 		OUT NOCOPY 	NUMBER,
	amount_charges_due		OUT NOCOPY 	NUMBER,
	amount_freight_due 		OUT NOCOPY 	NUMBER,
	amount_line_items_due		OUT NOCOPY 	NUMBER,
	total_amount_due		OUT NOCOPY 	NUMBER,
        total_amount_remaining          OUT NOCOPY     NUMBER);

PROCEDURE GET_TERM_DISCOUNT (
	document_type		 IN	 VARCHAR2,
	term_id			 IN	 NUMBER,
	term_sequence_number     IN      NUMBER,
	discount_percent1        OUT NOCOPY	 NUMBER,
	discount_days1           OUT NOCOPY     NUMBER,
	discount_date1           OUT NOCOPY     DATE,
	discount_day_of_month1   OUT NOCOPY     NUMBER,
	discount_months_forward1 OUT NOCOPY     NUMBER,
	discount_percent2        OUT NOCOPY	 NUMBER,
	discount_days2           OUT NOCOPY     NUMBER,
	discount_date2           OUT NOCOPY     DATE,
	discount_day_of_month2   OUT NOCOPY     NUMBER,
	discount_months_forward2 OUT NOCOPY     NUMBER,
	discount_percent3        OUT NOCOPY	 NUMBER,
	discount_days3           OUT NOCOPY     NUMBER,
	discount_date3           OUT NOCOPY     DATE,
	discount_day_of_month3   OUT NOCOPY     NUMBER,
	discount_months_forward3 OUT NOCOPY     NUMBER);

-- Bug 1940758
PROCEDURE UPDATE_HEADER_WITH_LINE (
	p_customer_trx_id 	    	IN 	NUMBER);
end ece_cdmo_util;

 

/
