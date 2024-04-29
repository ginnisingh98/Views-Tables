--------------------------------------------------------
--  DDL for Package JAI_OM_WSH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_OM_WSH_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_om_wsh.pls 120.2 2007/04/23 05:14:24 ssawant ship $ */

procedure process_delivery
(
  errbuf OUT NOCOPY VARCHAR2 ,
  retcode OUT NOCOPY VARCHAR2 ,
  p_delivery_id   IN  NUMBER
);

function get_excise_register_with_bal
(
  p_pref_rg23a                NUMBER    ,
  p_pref_rg23c                NUMBER    ,
  p_pref_pla in               NUMBER    ,
  p_ssi_unit_flag             VARCHAR2  ,
  p_exempt_amt                NUMBER    ,
  p_rg23a_balance             NUMBER    ,
  p_rg23c_balance             NUMBER    ,
  p_pla_balance               NUMBER    ,
  p_basic_pla_balance         NUMBER    ,
  p_additional_pla_balance    NUMBER    ,
  p_other_pla_balance         NUMBER    ,
  p_basic_excise_duty_amount  NUMBER    ,
  p_add_excise_duty_amount    NUMBER    ,
  p_oth_excise_duty_amount    NUMBER    ,
  p_export_oriented_unit      VARCHAR2  ,
  p_register_code             VARCHAR2  ,
  p_delivery_id               NUMBER    ,
  p_organization_id           NUMBER    ,
  p_location_id               NUMBER    ,
  p_cess_amount               NUMBER    ,
  p_sh_cess_amount            NUMBER,  /* added by ssawant for bug 5989740 */
  p_process_flag   OUT NOCOPY VARCHAR2  ,
  p_process_msg    OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2 ;

procedure process_deliveries
(
  errbuf         OUT NOCOPY VARCHAR2 ,
  retcode        OUT NOCOPY VARCHAR2 ,
  pn_delivery_id IN   NUMBER
);

END jai_om_wsh_pkg;

/
