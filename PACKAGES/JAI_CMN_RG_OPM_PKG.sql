--------------------------------------------------------
--  DDL for Package JAI_CMN_RG_OPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RG_OPM_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rg_opm.pls 120.2 2005/07/29 10:48:25 rpokkula ship $ */
/*-----------------------------------------------------------------------------------------------------
Change History
08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old DB Entity Names,
              as required for CASE COMPLAINCE. Version 116.1
08-July-2005  Brathod,
              Issue:  Inventory Convergence Uptake
              Solution:
              -  Signature of procedure CREATE_RG23_ENTRY is modified.  p_orgn_code is removed and
                 a new argument organization_id is introduced
              -  Signature of procedure CREATE_RG_I_ENTRY is modified.  p_orgn_code and p_item_id are
                 removed and introduced p_organization_id and p_inventory_item_id

29-Jul-2005   Ramananda for bug#4523064, File Version 120.2
              Removed the procedure calculate_pla_balances, as it is commented in the package body
--------------------------------------------------------------------------------------------------------*/
procedure create_rg23_entry
(
p_iss_recpt_mode          varchar2,
--p_orgn_code             varchar2,
p_location_id             NUMBER, --p_whse_code
p_ospheader               number,
p_vendor_id               number,
p_trans_date              date,
p_reg_type                Varchar2,
p_amount                  Number default 0,
p_post_rg23_i             Varchar2,
p_organization_id         Number --File.Sql.35 Cbabu  default 'Y'
);


procedure create_rg_i_entry
(
--p_orgn_code           varchar2,
p_location_id           NUMBER,--p_whse_code
p_ospheader           number,
p_trans_date          date,
--p_item_id             number,
p_qty                 number,
p_uom_code            varchar2,
p_created_by          number,
p_organization_id     number,
p_inventory_item_id   number
);

END jai_cmn_rg_opm_pkg;
 

/
