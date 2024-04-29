--------------------------------------------------------
--  DDL for Package PNRX_RENT_INCREASE_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNRX_RENT_INCREASE_DETAIL" AUTHID CURRENT_USER AS
/* $Header: PNRXRDRS.pls 120.1 2008/05/28 08:11:15 kkorada noship $ */
FUNCTION get_location_code (p_location_id IN NUMBER)
RETURN VARCHAR2;


PROCEDURE RENT_INCREASE_DETAIL(
		p_lease_number_low    IN             VARCHAR2 Default Null,
		p_lease_number_high   IN             VARCHAR2 Default Null,
		p_ri_number_low       IN             VARCHAR2 Default Null,
		p_ri_number_high      IN             VARCHAR2 Default Null,
	        p_assess_date_from    IN             DATE,
		p_assess_date_to      IN             DATE,
		p_lease_class	      IN             VARCHAR2 Default Null,
		p_property_id	      IN             NUMBER Default Null,
		p_building_id	      IN             NUMBER Default Null,
		p_location_id	      IN             NUMBER Default Null,
		p_include_draft       IN             VARCHAR2 Default NULL,
                p_rent_type           IN             VARCHAR2 Default NULL,
		l_request_id          IN             NUMBER,
		l_user_id             IN             NUMBER,
		retcode               OUT NOCOPY     VARCHAR2,
		errbuf                OUT NOCOPY     VARCHAR2
                   );



FUNCTION get_vendor_site (p_vendor_site_id IN NUMBER)
RETURN VARCHAR2;


FUNCTION get_customer_bill_site (p_site_use_id IN NUMBER)
RETURN VARCHAR2;
FUNCTION get_customer_ship_site (p_site_use_id IN NUMBER)
RETURN VARCHAR2;
FUNCTION get_index_name (p_index_id IN NUMBER)
RETURN VARCHAR2;
FUNCTION get_project_number (p_project_id IN NUMBER)
RETURN VARCHAR2;
FUNCTION get_task_number (p_task_id IN NUMBER)
RETURN VARCHAR2;
FUNCTION get_lookup_meaning (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2)
RETURN VARCHAR2;


TYPE vendor_rec IS RECORD (
          vendor_name	            	PO_VENDORS.vendor_name%TYPE,
          vendor_number             PO_VENDORS.segment1%TYPE
          );

TYPE customer_rec IS RECORD (
          customer_name	            	HZ_PARTIES.party_name%TYPE,
          customer_number             HZ_CUST_ACCOUNTS.account_number%TYPE
          );

FUNCTION get_vendor (p_vendor_id IN NUMBER)
RETURN vendor_rec;

FUNCTION get_customer(p_customer_id IN NUMBER)
RETURN customer_rec;

TYPE lease_detail IS RECORD (
  	 		ABSTRACTED_BY_USER 	       	        NUMBER,
  			LEASE_CLASS_CODE   			VARCHAR2(30),
  			PAYMENT_PURPOSE_CODE            	VARCHAR2(30),
  			PAYMENT_TERM_TYPE_CODE    		VARCHAR2(30),
  			FREQUENCY_CODE             		VARCHAR2(30),
  			VENDOR_ID                  	   	NUMBER,
  			VENDOR_SITE_ID            	   	NUMBER,
  			CUSTOMER_ID               	   	NUMBER,
  			CUSTOMER_SITE_USE_ID           	        NUMBER,
  			LOCATION_ID               	   	NUMBER,
  			CUST_SHIP_SITE_ID          	   	NUMBER,
  			AP_AR_TERM_ID           	   	NUMBER,
  			CUST_TRX_TYPE_ID      		   	NUMBER,
  			PROJECT_ID              	   	NUMBER,
  			TASK_ID                          	NUMBER,
  			ORGANIZATION_ID           	   	NUMBER,
  			INV_RULE_ID           		   	NUMBER,
  			ACCOUNT_RULE_ID           	   	NUMBER,
  			SALESREP_ID           		   	NUMBER,
  			INDEX_ID           			NUMBER,
  			NEGATIVE_RENT_TYPE     	   	   	VARCHAR2(30),
  			INCREASE_ON            		   	VARCHAR2(30),
			BASIS_TYPE                              VARCHAR2(30),
  			RELATIONSHIP              	   	VARCHAR2(30),
  			APPROVED_BY				NUMBER,
  			PO_HEADER_ID				NUMBER,
  			RECEIPT_METHOD_ID			NUMBER,
  			TAX_CODE_ID			        NUMBER,
  			TAX_GROUP_ID				NUMBER,
  			SPREAD_FREQUENCY			VARCHAR2(30),
			INDEX_FINDER_METHOD                     VARCHAR2(30),
  			REFERENCE_PERIOD			VARCHAR2(30),
			PRORATION_RULE                          VARCHAR2(80),
  			INDEX_LEASE_ID				NUMBER,
  			account_id			        NUMBER,
  			account_class				VARCHAR2(30)
	 	);

END;

/
