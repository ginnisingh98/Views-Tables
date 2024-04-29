--------------------------------------------------------
--  DDL for Package JAI_CMN_RG_OTHERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RG_OTHERS_PKG" 
/* $Header: jai_cmn_rg_oth.pls 120.2 2007/05/04 13:41:51 csahoo ship $ */
AUTHID CURRENT_USER AS

/***************************************************************************************************
CREATED BY       : ssumaith
CREATED DATE     : 11-JAN-2005
ENHANCEMENT BUG  : 4136981
PURPOSE          : To pass cess register entries
CALLED FROM      : ja_in_rg_pkg.ja_in_rg23_part_ii_entry , ja_in_rg_pkg.pla_emtry , ja_in_rg_pkg.ja_in23d_entry

***************************************************************************************************/

procedure insert_row (p_source_type       JAI_CMN_RG_OTHERS.SOURCE_TYPE%TYPE        ,
                      p_source_name       JAI_CMN_RG_OTHERS.SOURCE_REGISTER%TYPE    ,
                      p_source_id         JAI_CMN_RG_OTHERS.SOURCE_REGISTER_ID%TYPE ,
                      p_tax_type          JAI_CMN_RG_OTHERS.TAX_TYPE%TYPE           ,
                      debit_amt           JAI_CMN_RG_OTHERS.DEBIT%TYPE              ,
                      credit_amt          JAI_CMN_RG_OTHERS.CREDIT%TYPE             ,
                      p_process_flag OUT NOCOPY VARCHAR2                              ,
                      p_process_msg OUT NOCOPY VARCHAR2                              ,
                      p_attribute1        VARCHAR2 DEFAULT NULL                 ,
                      p_attribute2        VARCHAR2 DEFAULT NULL                 ,
                      p_attribute3        VARCHAR2 DEFAULT NULL                 ,
                      p_attribute4        VARCHAR2 DEFAULT NULL                 ,
                      p_attribute5        VARCHAR2 DEFAULT NULL
                     );

procedure check_balances(p_organization_id           JAI_CMN_INVENTORY_ORGS.ORGANIZATION_ID%TYPE  ,
                         p_location_id                HR_LOCATIONS.LOCATION_ID%TYPE                    ,
                         p_register_type              JAI_CMN_RG_OTH_BALANCES.REGISTER_TYPE%TYPE           ,
                         p_trx_amount                 NUMBER                                           ,
                         p_process_flag OUT NOCOPY VARCHAR2                                         ,
                         p_process_message OUT NOCOPY VARCHAR2
                       );
/*added the following procedure by vkaranam for bug #5989740*/
procedure check_sh_balances(p_organization_id          JAI_CMN_INVENTORY_ORGS.ORGANIZATION_ID%TYPE   ,
                         p_location_id                HR_LOCATIONS.LOCATION_ID%TYPE                    ,
                         p_register_type              JAI_CMN_RG_OTH_BALANCES.REGISTER_TYPE%TYPE           ,
                         p_trx_amount                 NUMBER                                           ,
                         p_process_flag OUT NOCOPY VARCHAR2                                         ,
                         p_process_message OUT NOCOPY VARCHAR2
                       );

end jai_cmn_rg_others_pkg;

/
