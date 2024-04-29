--------------------------------------------------------
--  DDL for Package JAI_CMN_RG_MASTER_ORG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RG_MASTER_ORG_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rg_mst.pls 120.1 2005/07/20 12:57:19 avallabh ship $ */

PROCEDURE insert_rg23_others
(ERRBUF OUT NOCOPY VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2,
 p_previous_serial_no IN JAI_CMN_RG_23AC_II_TRXS.slno%TYPE,
 p_tax_type           IN JAI_CMN_RG_OTHERS.tax_type%TYPE,
 p_register_id        IN JAI_CMN_RG_23AC_II_TRXS.register_id%TYPE) ;

Procedure insert_pla_others
(ERRBUF OUT NOCOPY VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2,
 p_previous_serial_no IN JAI_CMN_RG_PLA_TRXS.slno%TYPE,
 p_tax_type           IN JAI_CMN_RG_OTHERS.tax_type%TYPE,
 p_register_id        IN JAI_CMN_RG_PLA_TRXS.register_id%TYPE);

PROCEDURE consolidate_rg23_part_i
(errbuf OUT NOCOPY VARCHAR2,
retcode OUT NOCOPY VARCHAR2,
p_organization_id IN NUMBER,
p_location_id IN NUMBER);

PROCEDURE consolidate_rg23_part_ii
(ERRBUF OUT NOCOPY VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2,
 p_organization_id IN NUMBER,
 p_location_id IN NUMBER);

PROCEDURE consolidate_pla
(ERRBUF OUT NOCOPY VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2,
 p_organization_id IN NUMBER,
 p_location_id IN NUMBER) ;

PROCEDURE consolidate_rg_i
(errbuf OUT NOCOPY VARCHAR2,
 retcode OUT NOCOPY VARCHAR2,
 p_organization_id IN NUMBER,
 p_location_id IN NUMBER ) ;


END jai_cmn_rg_master_org_pkg ;
 

/
