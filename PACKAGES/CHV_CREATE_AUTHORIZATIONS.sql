--------------------------------------------------------
--  DDL for Package CHV_CREATE_AUTHORIZATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_CREATE_AUTHORIZATIONS" AUTHID CURRENT_USER as
/*$Header: CHVPRAUS.pls 115.0 99/07/17 01:29:36 porting ship $*/

/*===========================================================================
  PACKAGE NAME:  CHV_CREATE_AUTHORIZATIONS
  DESCRIPTION:   This package contains the server side of Supplier Scheduling
		 APIs to calculate authorization quantity.

  CLIENT/SERVER: Server

  OWNER:         Sri Rumalla

  FUNCTION:
		 insert_authorizations()
                 calc_high_auth_qty()

============================================================================*/

/*===========================================================================
  PROCEDURE NAME      :  insert_authorizations

  DESCRIPTION         :  CALC_AUTH_QTY is a procedure to calculate authorizations
                         for a scheduled item based on certain organization
                         options, ASL defaults and scheduling parameters.

  PARAMETERS          :  p_organization_id                 IN      NUMBER,
			 p_schedule_id                     IN      NUMBER,
			 p_schedule_item_id                IN      NUMBER,
                         p_asl_id                          IN      NUMBER,
			 p_horizon_start_date              IN      DATE,
			 p_horizon_end_date                IN      DATE,
                         p_vendor_id                       IN      NUMBER,
			 p_vendor_site_id                  IN      NUMBER,
                         p_item_id                         IN      NUMBER,
                         p_starting_auth_quantity          IN      NUMBER,
                         p_starting_auth_qty_primary       IN      NUMBER,
                         p_cum_period_end_date             IN      DATE,
                         p_starting_cum_quantity           IN      NUMBER,
                         p_starting_cum_qty_primary        IN      NUMBER,
                         p_purch_unit_of_measure           IN      VARCHAR2,
                         p_primary_unit_of_measure         IN      VARCHAR2,

  DESIGN REFERENCES   :

  ALGORITHM           :  Get ASL authorization enabled information from
                         PO_APPROVED_SUPPLIER_LIST based on the incoming
                         parameters.

                         If enable_authorizations_flag = 'Y' do the following:
                           Get past due quantity in purchasing and primary UOM's
                           based on the x_horizon_start_date.

                           Get cum information for the organization and supplier
                           item from CHV_ORG_OPTIONS, CHV_CUM_PERIODS and
                           CHV_CUM_PERIOD_ITEMS tables.

                           For every authorization_code in CHV_AUTHORIZATIONS
                           based on the ASL do the following:

                             Calculate authorization end date for each
                             authorization based on the x_horizon_end_date,
                             cum_period_end_date, horizon_start_date +
                             timefence_days. Authorization end date is set to
                             the earliest of the above three dates.

                             Get authorization quantities in purchasing and
                             primary UOM's from CHV_ITEM_ORDERS based on the
                             authorization end date calculated above.

                             Insert into CHV_AUTHORIZATIONs table the
                             authorization code data.

  NOTES               :

  OPEN ISSUES         :

  CLOSED ISSUES       :

  CHANGE HISTORY      :  Created            3-APR-1995     SXLIU
==========================================================================*/
PROCEDURE insert_authorizations(
			 p_organization_id                 IN      NUMBER,
			 p_schedule_id                     IN      NUMBER,
			 p_schedule_item_id                IN      NUMBER,
                         p_asl_id                          IN      NUMBER,
			 p_horizon_start_date              IN      DATE,
			 p_horizon_end_date                IN      DATE,
                         p_starting_auth_qty               IN      NUMBER,
                         p_starting_auth_qty_primary       IN      NUMBER,
			 p_starting_cum_qty                IN      NUMBER,
			 p_starting_cum_qty_primary        IN      NUMBER,
                         p_cum_period_end_date             IN      DATE,
                         p_purch_unit_of_measure           IN      VARCHAR2,
                         p_primary_unit_of_measure         IN      VARCHAR2,
			 p_enable_cum_flag                 IN      VARCHAR2);


/*===========================================================================
  PROCEDURE NAME      :  calc_high_auth_qty

  DESCRIPTION         :  CALC_HIGH_AUTH_QTY is a procedure to calculate
                         high authorizations for each authorization code
                         for the scheduled item within a cum period. It is
                         called whenever a schedule header is confirmed.

  PARAMETERS          :  p_organization_id                 IN      NUMBER,
			 p_schedule_id                     IN      NUMBER,
			 p_schedule_item_id                IN      NUMBER,
                         p_vendor_id                       IN      NUMBER,
			 p_vendor_site_id                  IN      NUMBER,
                         p_item_id                         IN      NUMBER,
                         p_asl_id                          IN      NUMBER,
			 p_horizon_start_date              IN      DATE,
                         p_cum_period_item_id              IN      NUMBER

  DESIGN REFERENCES   :

  ALGORITHM           :

  NOTES               :

  OPEN ISSUES         :

  CLOSED ISSUES       :

  CHANGE HISTORY      :  Created            14-MAY-1995     SXLIU
==========================================================================*/
PROCEDURE calc_high_auth_qty(p_organization_id                 IN      NUMBER,
			     p_schedule_id                     IN      NUMBER,
			     p_schedule_item_id                IN      NUMBER,
                             p_vendor_id                       IN      NUMBER,
			     p_vendor_site_id                  IN      NUMBER,
                             p_item_id                         IN      NUMBER,
                             p_asl_id                          IN      NUMBER,
                             p_horizon_start_date              IN      DATE,
                             p_cum_period_item_id              IN      NUMBER);

END CHV_CREATE_AUTHORIZATIONS;

 

/
