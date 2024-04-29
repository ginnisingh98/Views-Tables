--------------------------------------------------------
--  DDL for Package GMD_QC_ERES_CHANGE_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_ERES_CHANGE_STATUS_PVT" AUTHID CURRENT_USER as
/* $Header: GMDVERES.pls 115.0 2002/09/19 22:17:26 txdaniel noship $ */

  PROCEDURE set_spec_status(p_spec_id IN NUMBER,
                            p_from_status IN VARCHAR2,
                            p_to_status IN VARCHAR2,
                            p_signature_status IN VARCHAR2) ;

  PROCEDURE set_spec_vr_status(p_spec_vr_id IN NUMBER,
                               p_entity_type IN VARCHAR2,
                               p_from_status IN VARCHAR2,
                               p_to_status IN VARCHAR2,
                               p_signature_status IN VARCHAR2) ;

  PROCEDURE update_vr_status(pentity_type IN VARCHAR2,
		             pspec_vr_id  IN NUMBER,
		             p_to_status IN NUMBER) ;
  FUNCTION chek_spec_validity_eres (p_spec_id IN NUMBER,
                                    p_to_status IN VARCHAR2,
                                    p_event  IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION esig_required (p_event IN VARCHAR2,
                          p_event_key IN VARCHAR2,
                          p_to_status IN VARCHAR2)
RETURN BOOLEAN;
END GMD_QC_ERES_CHANGE_STATUS_PVT;

 

/
