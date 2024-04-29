--------------------------------------------------------
--  DDL for Package JAI_EXCISE_SCRIPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_EXCISE_SCRIPTS_PKG" AUTHID CURRENT_USER AS
/* $Header: jaiexscr.pls 120.0.12000000.2 2007/10/25 02:31:36 rallamse noship $ */

  PROCEDURE validate_period_balances( p_organization_id NUMBER,
                                      p_location_id     NUMBER,
                                      p_register_type   VARCHAR2,
                                      p_date            DATE) ;

  PROCEDURE pla_validation (
                              p_organization_id    IN  JAI_CMN_RG_PLA_TRXS.ORGANIZATION_ID%TYPE ,
                              p_location_id        IN  JAI_CMN_RG_PLA_TRXS.LOCATION_ID%TYPE     ,
                              p_fin_year           IN  JAI_CMN_RG_PLA_TRXS.FIN_YEAR%TYPE
                            )  ;

  PROCEDURE rg23_part_ii_validation
                            ( p_organization_id    IN  JAI_CMN_RG_23AC_II_TRXS.ORGANIZATION_ID%TYPE ,
                              p_location_id        IN  JAI_CMN_RG_23AC_II_TRXS.LOCATION_ID%TYPE     ,
                              p_fin_year           IN  JAI_CMN_RG_23AC_II_TRXS.FIN_YEAR%TYPE        ,
                              p_register_type      IN  JAI_CMN_RG_23AC_II_TRXS.REGISTER_TYPE%TYPE
                             ) ;

  PROCEDURE process_rg_trx
                        (    errbuf out nocopy varchar2,
                             retcode out nocopy varchar2,
                             p_date            VARCHAR2   ,
                             p_organization_id NUMBER ,
                             p_location_id     NUMBER ,
                             p_register_type   VARCHAR2 ,
                             p_action          NUMBER   ,
                             p_debug           VARCHAR2 DEFAULT NULL ,
                             p_backup          VARCHAR2 DEFAULT NULL
                        ) ;

 PROCEDURE validate_rg_others
                        (    p_organization_id number,
                             p_location_id     number,
                             p_register_type   varchar2,
                             p_date            date
                        ) ;

 PROCEDURE capture_error
                    ( p_organization_id    number,
                      p_location_id        number,
                      p_register_type      varchar2,
                      p_fin_year           number,
                      p_opening_balance    number,
                      p_error_codes        varchar2,
                      p_slno               number,
                      p_register_id        number,
                      p_rowcount           number,
                      p_tax_type           varchar2,
                      p_date               date,
                      p_month              varchar2,
                      p_year               number
                     ) ;

END jai_excise_scripts_pkg;
 

/
