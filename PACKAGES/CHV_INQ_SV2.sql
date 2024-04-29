--------------------------------------------------------
--  DDL for Package CHV_INQ_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_INQ_SV2" AUTHID CURRENT_USER as
/* $Header: CHVSIN2S.pls 115.1 99/10/11 17:16:32 porting shi $ */

/*===========================================================================
  PACKAGE NAME:		CHV_INQ_SV2

  DESCRIPTION:		This package contains the server side CHV Inquiry
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Kim Powell

  FUNCTION/PROCEDURE:
===========================================================================*/

FUNCTION get_last_receipt_num(p_org_id in number,
			 p_item_id in number,
			 p_vendor_id in number,
			 p_vendor_site_id in number,
			 p_cum_period_start_date date,
			 p_cum_period_end_date date)
                                RETURN VARCHAR2 ;

--PRAGMA RESTRICT_REFERENCES(get_last_receipt_num,WNDS);

FUNCTION get_last_receipt_date(p_org_id in number,
			 p_item_id in number,
			 p_vendor_id in number,
			 p_vendor_site_id in number,
			 p_cum_period_start_date date,
			 p_cum_period_end_date date)
                                RETURN DATE ;

--PRAGMA RESTRICT_REFERENCES(get_last_receipt_date,WNDS);

FUNCTION get_last_receipt_quantity(p_org_id in number,
			 p_item_id in number,
			 p_vendor_id in number,
			 p_vendor_site_id in number,
			 p_cum_period_start_date date,
			 p_cum_period_end_date date,
			 p_purchasing_uom varchar2)
                                RETURN NUMBER ;

--PRAGMA RESTRICT_REFERENCES(get_last_receipt_quantity,WNDS);

FUNCTION get_cum_received_purch(X_vendor_id IN NUMBER,
                                X_vendor_site_id IN NUMBER,
                                X_item_id IN NUMBER,
                                X_organization_id IN NUMBER,
                                X_rtv_transactions_included IN VARCHAR2,
                                X_cum_period_start IN DATE,
                                X_cum_period_end IN DATE,
                                X_purchasing_unit_of_measure IN VARCHAR2)
					RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(get_cum_received_purch,WNDS);

function get_purchasing_uom_qty(x_primary_quantity in number,
				x_primary_unit_of_measure in varchar2,
				x_vendor_id in number,
				x_vendor_site_id in number,
				x_organization_id in number,
				x_item_id in number)
		 return number;

--PRAGMA RESTRICT_REFERENCES(get_purchasing_uom_qty,WNDS);


END CHV_INQ_SV2;

 

/
