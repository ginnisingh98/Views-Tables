--------------------------------------------------------
--  DDL for Package CHV_INQ_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_INQ_SV" AUTHID CURRENT_USER as
/* $Header: CHVSIN1S.pls 115.2 2002/11/26 23:39:08 sbull ship $ */

/*===========================================================================
  PACKAGE NAME:		CHV_INQ_SV

  DESCRIPTION:		This package contains the server side CHV Inquiry
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Sri Rumalla

  FUNCTION/PROCEDURE:
===========================================================================*/

/*===========================================================================
  PROCEDURE NAME: 	get_receipt_quantity()

  DESCRIPTION:	        This procedure will return the last receipt
		        info to the calling module including the converted
			quantity in purchasing unit_of_measure


   PARAMETERS:          p_last_receipt_transaction_id in  number
			p_item_id		      in  number
			p_purchasing_unit_of_measure  in  varchar2
			p_purchasing_quantity         in out number
			p_shipment_number	      in out varchar2
			p_receipt_transaction_date    in out date



  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		11-MAY-95       SRUMALLA
===========================================================================*/
PROCEDURE get_receipt_qty(p_last_receipt_transaction_id in number,
	                  p_item_id                     in number,
			  p_purchasing_unit_of_measure  in varchar2,
			  p_purchasing_quantity       in out NOCOPY number,
			  p_shipment_number           in out NOCOPY varchar2,
			  p_receipt_transaction_date  in out NOCOPY date) ;

/*===========================================================================

  PROCEDURE NAME: 	get_bucket_dates()

  DESCRIPTION:		This procedure will get the column name from
                        and will select the bucket start date and end date
		        from chv_horizontal_schedules and return to the
		        workbench form.

   PARAMETERS:          p_schedule_id
                        p_schedule_item_id
			p_column_name
		        p_bucket_descriptor
			p_bucket_start_date
			p_bucket_end_date

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		29-MAY-95       SRUMALLA
===========================================================================*/
PROCEDURE  get_bucket_dates(p_schedule_id        IN      NUMBER,
                            p_schedule_item_id	 IN      NUMBER,
                            p_column_name        IN      VARCHAR2,
	    		    p_bucket_descriptor  IN OUT NOCOPY  VARCHAR2,
			    p_bucket_start_date  IN OUT NOCOPY  DATE,
			    p_bucket_end_date    IN OUT NOCOPY  DATE) ;

/*===========================================================================
  FUNCTION NAME: 	get_asl_org()

  DESCRIPTION:		This function will retreive the local organization
			id from po_asl_attributes based on the supplier/site/
			item/org.  If the local does not exist the function
			will return -1(global org).


   PARAMETERS:



  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		11-MAY-95       SRUMALLA
===========================================================================*/
FUNCTION  get_asl_org(p_organization_id	   IN   NUMBER,
		      p_vendor_id          IN   NUMBER,
		      p_vendor_site_id     IN   NUMBER,
		      p_item_id            IN   NUMBER)
					     RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(get_asl_org,WNDS,RNPS,WNPS);


/*===========================================================================
  FUNCTION NAME:        get_last_receipt_id()

  DESCRIPTION:          This function will get the last receipt id which is
                        used by the CHVSSCUM for to retrieve the last receipt
                        details


   PARAMETERS:



  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:


  CHANGE HISTORY:       Created         7/30/96       SASMITH
===========================================================================*/
function get_last_receipt_id(x_vendor_id      in number,
                                   x_vendor_site_id  in number,
                                   x_item_id         in number,
                                   x_organization_id in number,
                                   x_cum_period_start_date in date,
                                   x_cum_period_end_date in date)
                 return number;
--PRAGMA RESTRICT_REFERENCES(get_last_receipt_id,WNDS,RNPS,WNPS);

/*===========================================================================
  FUNCTION NAME: 	get_bucket_type()

  DESCRIPTION:          This function will retreive the displayed field
			for the bucket.


   PARAMETERS:          p_bucket_type_code


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		08-AUG-96       SRUMALLA
===========================================================================*/

FUNCTION get_bucket_type(p_bucket_type_code in varchar2)
                                RETURN VARCHAR2 ;

--PRAGMA RESTRICT_REFERENCES(get_bucket_type,WNDS,RNPS,WNPS);

END CHV_INQ_SV ;

 

/
