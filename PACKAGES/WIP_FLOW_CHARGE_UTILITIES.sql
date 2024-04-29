--------------------------------------------------------
--  DDL for Package WIP_FLOW_CHARGE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_FLOW_CHARGE_UTILITIES" AUTHID CURRENT_USER as
 /* $Header: wipworos.pls 115.7 2002/12/01 12:58:14 simishra ship $ */

/**********************************************************************
                        Private Procedures

	This package has three procedures - one for charging the
	resources (both Item and Lot based), another for charging
	only the Item based Overheads and the last one for charging
	only the lot based resources :
	1. function Charge_Resources(
			   p_txn_temp_id in number,
                           p_comp_txn_id in number) return number;
	2. function Charge_Item_Overheads(p_comp_txn_id in number);
	3. function Charge_Lot_Overheads(p_comp_txn_id in number);
***********************************************************************/

/* *********************************************************************
			Public Procedures
***********************************************************************/
function Charge_Resource_Overhead (p_header_id in number,
				   p_rtg_rev_date in varchar2) return number;

function Validate_Resource_Overhead(p_group_id in number,
				    p_err_mesg out NOCOPY varchar) return number;

end WIP_Flow_Charge_Utilities;

 

/
