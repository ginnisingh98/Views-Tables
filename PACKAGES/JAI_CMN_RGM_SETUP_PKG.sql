--------------------------------------------------------
--  DDL for Package JAI_CMN_RGM_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RGM_SETUP_PKG" 
/* $Header: jai_cmn_rgm_setp.pls 120.1 2005/07/20 12:57:33 avallabh ship $ */
AUTHID CURRENT_USER as
PROCEDURE Gen_Invoice_number(
        p_regime_id                     JAI_RGM_DEFINITIONS.REGIME_ID%Type,
        p_organization_id               HR_ALL_ORGANIZATION_UNITS.ORGANIZATION_ID%Type,
        p_location_id                   HR_LOCATIONS.LOCATION_ID%Type,
        p_date                          DATE,
        p_doc_class                     JAI_RGM_DOC_SEQ_DTLS.DOCUMENT_CLASS%Type   ,
        p_doc_type_id                   JAI_RGM_DOC_SEQ_DTLS.DOCUMENT_CLASS_TYPE_ID%Type,
        P_invoice_number OUT NOCOPY varchar2,   /*  Caller should call with parameter of size varchar2(100)*/
        p_process_flag OUT NOCOPY varchar2,   /*  Caller should call with parameter of size varchar2(2)*/
        p_process_msg OUT NOCOPY varchar2);
end jai_cmn_rgm_setup_pkg;
 

/
