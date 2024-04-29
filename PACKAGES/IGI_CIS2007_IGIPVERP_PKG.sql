--------------------------------------------------------
--  DDL for Package IGI_CIS2007_IGIPVERP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS2007_IGIPVERP_PKG" AUTHID CURRENT_USER AS
-- $Header: igipvers.pls 120.0.12000000.2 2007/07/09 06:29:30 vensubra noship $

  PROCEDURE pr_po_core_update(p_header_id IN NUMBER);
  PROCEDURE pr_audit_update(p_header_id IN NUMBER);

  FUNCTION igi_cis_is_vendor_paid
  (
    l_vendor_id NUMBER,
    verify_date DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  PROCEDURE pr_po_api
  (
    p_vendor_id         IN NUMBER,
    p_verification_no   IN VARCHAR2,
    p_match_status      IN VARCHAR2,
    p_verification_date DATE,
    p_awt_group_id      IN NUMBER,
    p_utr_type          IN VARCHAR2,
    p_utr               IN NUMBER,
    p_sc_name           IN VARCHAR2,
    p_sc_ref_id         IN VARCHAR2,
    p_req_id            IN NUMBER        --Bug 5606118
  );

END igi_cis2007_igipverp_pkg;

 

/
