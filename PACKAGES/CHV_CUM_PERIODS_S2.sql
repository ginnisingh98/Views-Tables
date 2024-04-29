--------------------------------------------------------
--  DDL for Package CHV_CUM_PERIODS_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_CUM_PERIODS_S2" AUTHID CURRENT_USER as
/*$Header: CHVCUMPS.pls 115.1 2002/11/23 04:10:47 sbull ship $ */

/*===========================================================================
  PACKAGE NAME:  CHV_CREATE_ITEMS
  DESCRIPTION:   This package contains the server side of Supplier Scheduling
		 APIs to select cum information.

  CLIENT/SERVER: Server

  OWNER:         Shawna Liu

  FUNCTION/
		 get_cum_info()

============================================================================*/

/*===========================================================================
  PROCEDURE NAME      :  get_cum_info

  DESCRIPTION         :  GET_CUM_INFO is an API to retrieve cum information
                         such as cum_enable flag and the cum period to be used
                         for the organization and item.

  PARAMETERS          :    p_organization_id             IN      NUMBER,
			   p_vendor_id                   IN      NUMBER,
			   p_vendor_site_id              IN      NUMBER,
                           p_item_id                     IN      NUMBER,
			   p_horizon_start_date          IN      DATE,
			   p_purch_unit_of_measure       IN      VARCHAR2,
			   p_last_receipt_transaction_id IN OUT  NUMBER,
                           p_cum_quantity_received       IN OUT  NUMBER,
                           p_quantity_received_primary   IN OUT  NUMBER,
                           p_cum_period_end_date         IN OUT  DATE

  DESIGN REFERENCES   :

  ALGORITHM           :  Select enable_cum_flag from CHV_ORG_OPTIONS for the
                         organization.
                         If x_enable_cum_flag = 'Y' then do the following:
                           Select cum_period_id, cum_period_end_date from
                           CHV_CUM_PERIODS based on the organization and
                           x_horizon_start_date which should be between
                           cum_period_start_date and cum_period_end_date.

                           Select cum_quantity_received, cum_qty_primary based
                           on the cum_period_id selected from the item.

                           If the record does not exist in CHV_CUM_PERIOD_ITEMS
                           for the supplier item then insert a new record.

  NOTES               :  Two quantity parameters are in out rather than out,
                         because the select into statement requires that.

  OPEN ISSUES         :  1. Should we consider TOO_MANY_ROWS exception for
                            the selects in this procedure?
                         2. What is the exact name of the sequence number for
                            cum_period_item_id?
                         3. Can we get purchasing_unit_of_measure and
                            primary_unit_of_measure from po_approved_supplier_list
                            table with the combination of key of organization_id,
                            vendor_id, vendor_site_id, and item_id?
                         4. Where to get last_updated_by, created_by,
                            last_update_login, request_id, program_application_id,
                            program_id, and program_udpate_date?

  CLOSED ISSUES       :

  CHANGE HISTORY      :  Created            1-APR-1995     SXLIU
==========================================================================*/
PROCEDURE get_cum_info    (x_organization_id               IN      NUMBER,
			   x_vendor_id                     IN      NUMBER,
			   x_vendor_site_id                IN      NUMBER,
                           x_item_id                       IN      NUMBER,
			   x_horizon_start_date            IN      DATE,
			   x_horizon_end_date		   IN      DATE,
			   x_purchasing_unit_of_measure    IN      VARCHAR2,
			   x_primary_unit_of_measure       IN      VARCHAR2,
			   x_last_receipt_transaction_id   IN OUT NOCOPY  NUMBER,
                           x_cum_quantity_received         IN OUT NOCOPY  NUMBER,
                           x_cum_quantity_received_prim    IN OUT NOCOPY  NUMBER,
                           x_cum_period_end_date           IN OUT NOCOPY  DATE);

END CHV_CUM_PERIODS_S2;

 

/
