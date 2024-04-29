--------------------------------------------------------
--  DDL for Package JAI_CMN_RG_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RG_BALANCES_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rg_bals.pls 120.1 2005/07/20 12:57:16 avallabh ship $ */

PROCEDURE insert_row(
  P_ORG_UNIT_ID                   IN  JAI_CMN_RG_BALANCES.org_unit_id%TYPE,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_BALANCES.organization_id%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_BALANCES.location_id%TYPE,
  P_PLA_BALANCE                   IN  JAI_CMN_RG_BALANCES.pla_balance%TYPE,
  P_RG23A_BALANCE                 IN  JAI_CMN_RG_BALANCES.rg23a_balance%TYPE,
  P_RG23C_BALANCE                 IN  JAI_CMN_RG_BALANCES.rg23c_balance%TYPE,
  P_CREATION_DATE                 IN  JAI_CMN_RG_BALANCES.creation_date%TYPE,
  P_CREATED_BY                    IN  JAI_CMN_RG_BALANCES.created_by%TYPE,
  P_LAST_UPDATE_DATE              IN  JAI_CMN_RG_BALANCES.last_update_date%TYPE,
  P_LAST_UPDATED_BY               IN  JAI_CMN_RG_BALANCES.last_updated_by%TYPE,
  P_LAST_UPDATE_LOGIN             IN  JAI_CMN_RG_BALANCES.last_update_login%TYPE,
  P_BASIC_PLA_BALANCE             IN  JAI_CMN_RG_BALANCES.basic_pla_balance%TYPE,
  P_ADDITIONAL_PLA_BALANCE        IN  JAI_CMN_RG_BALANCES.additional_pla_balance%TYPE,
  P_OTHER_PLA_BALANCE             IN  JAI_CMN_RG_BALANCES.other_pla_balance%TYPE,
  P_SIMULATE_FLAG                 IN  VARCHAR2,  --  DEFAULT 'N' File.Sql.35 by Brathod
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
);

PROCEDURE update_row(
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_BALANCES.organization_id%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_BALANCES.location_id%TYPE,
  p_register_type                 IN  VARCHAR2,
  p_amount_to_be_added            IN  NUMBER,
  P_SIMULATE_FLAG                 IN  VARCHAR2,   -- DEFAULT 'N' File.Sql.35 by Brathod
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
) ;

PROCEDURE get_balance(
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_BALANCES.organization_id%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_BALANCES.location_id%TYPE,
  P_REGISTER_TYPE                 IN  VARCHAR2,
  P_OPENING_BALANCE OUT NOCOPY VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
);

END jai_cmn_rg_balances_pkg;
 

/
