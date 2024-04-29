--------------------------------------------------------
--  DDL for Package PAY_US_TAX_BALS_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAX_BALS_ADJ_PKG" AUTHID CURRENT_USER AS
/* $Header: pyustxba.pkh 120.0 2005/05/29 10:00:43 appldev noship $ */
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
/* ------------------------------------------------------------------------
  NAME
      pyustxba.pkh
  --
  DESCRIPTION
      See description in pyustxba.pkb
  --
  Version	MODIFIED  Date		  Description
  -------	--------  -----------	  ---------------------
  0		S Panwar  23-OCT-1995     Created

  40.0		S Desai	  17-Nov-1995	  Initial arcs version

  40.1		S Desai	  20-Nov-1995	  Use city, state, county and zip
  					  to derive the jurisdiction.
					  Use assignment_number, bg_name,
					  consolidation_set instead of the
					  system keys.
					  Added parameter for net amount.

  40.2		S Desai	  22-Nov-1995	  Cleaned up code

  40.3		R Murthy  10-Sep-1996	  Added the parameter p_FIT_THIRD
					  to allow for adjusting the balance
					  for FIT Withheld by Third Party.

  110.2         S Billing 28-Apr-1998     added extra parameter p_cost,
                                          used to pass value of costed
                                          checkbox

  110.3         S Billing 15-Jul-1998     added the extra paramters:
                                          - p_futa_er
                                          - p_sui_er
                                          - p_sdi_er
                                          - p_sch_dist_wh_ee
                                          - p_sch_dist_jur

					  These relate to new fields added to
					  PAYWSTBA.fmb.  If null is passed through
					  any of these paramters, the corresponding
					  tax element is not processed.
  115.1		R Murthy	  Added new parameter, p_tax_unit_id.
  115.5		A Handa 	  Added commit before exit statement.

----------------------------------------------------------------------------- */


PROCEDURE create_tax_balance_adjustment(
	--
	-- Common parameters
	--
	p_adjustment_date	DATE,
	p_business_group_name	varchar2,
	p_assignment_number	varchar2,
	p_tax_unit_id     	NUMBER,
	p_consolidation_set	varchar2,
	--
	-- Earnings
	--
	p_earning_element_type	varchar2 	default null,
	p_gross_amount		NUMBER		default 0,
	p_net_amount		NUMBER		default 0,
	--
	-- Taxes withheld
	--
	p_FIT			NUMBER		default 0,
	p_FIT_THIRD		varchar2	default null,
	p_SS			NUMBER		default 0,
	p_Medicare		NUMBER		default 0,
	p_SIT			NUMBER		default 0,
	p_SUI			NUMBER		default 0,
	p_SDI			NUMBER		default 0,
	p_County		NUMBER		default 0,
	p_City			NUMBER		default 0,
	--
	-- Location parameters
	--
	p_city_name		varchar2	default null,
	p_state_abbrev		varchar2	default null,
	p_county_name		varchar2	default null,
	p_zip_code		varchar2	default null,
	p_cost			varchar2	default null,
        p_futa_er               NUMBER          DEFAULT 0,
        p_sui_er                NUMBER          DEFAULT 0,
        p_sdi_er                NUMBER          DEFAULT 0,
        p_sch_dist_wh_ee        NUMBER          DEFAULT 0,
        p_sch_dist_jur          varchar2        default null
	)
;

END pay_us_tax_bals_adj_pkg;

 

/
