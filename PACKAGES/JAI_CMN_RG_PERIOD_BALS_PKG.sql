--------------------------------------------------------
--  DDL for Package JAI_CMN_RG_PERIOD_BALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RG_PERIOD_BALS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rg_pbal.pls 120.3 2007/04/24 11:48:45 bduvarag ship $ */

  procedure consolidate_balances
  (
    errbuf OUT NOCOPY varchar2,
    retcode OUT NOCOPY varchar2,
    p_period_type                 in      varchar2,
    p_register_type               in      varchar2,
    pv_consolidate_till            in       varchar2 /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
  );

  procedure adjust_rounding
  (
    p_register_id_rounding        in        number,
    p_period_balance_id OUT NOCOPY number,
    p_no_balances_updated OUT NOCOPY number
  );

 /* function created by bgowrava for forward porting bug#5674376 */
function get_cess_opening_balance (
    cp_organization_id    in number,
    cp_location_id        in number,
    cp_register_type      in varchar2,
    cp_period_start_date  in date,
    cp_tax_type           in varchar2
  ) return number;


end jai_cmn_rg_period_bals_pkg;

/
