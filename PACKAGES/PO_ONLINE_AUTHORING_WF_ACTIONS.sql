--------------------------------------------------------
--  DDL for Package PO_ONLINE_AUTHORING_WF_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ONLINE_AUTHORING_WF_ACTIONS" AUTHID CURRENT_USER AS
/* $Header: PO_ONLINE_AUTHORING_WF_ACTIONS.pls 120.5 2006/06/09 00:15:50 bao noship $ */


PROCEDURE start_authoring_enabled_wf(p_agreement_id       IN NUMBER,
                                    p_agreement_info     IN VARCHAR2,
                                    p_ou_name            IN VARCHAR2,
                                    p_buyer_user_id      IN NUMBER);

FUNCTION get_wf_role_for_suppliers ( p_document_id    in     NUMBER,
                                     p_document_type  in     VARCHAR2)
  return varchar2;

-- bug5249393
PROCEDURE get_wf_role_for_lock_owner
( p_po_header_id IN NUMBER,
  p_lock_owner_role IN VARCHAR2,
  p_lock_owner_user_id IN NUMBER,
  x_wf_role_name OUT NOCOPY VARCHAR2,
	x_wf_role_name_dsp OUT NOCOPY VARCHAR2
);

-- bug5090429
PROCEDURE start_changes_discarded_wf(p_agreement_id       IN NUMBER,
                                    p_agreement_info     IN VARCHAR2,
                                    p_lock_owner_role    IN VARCHAR2,
                                    p_lock_owner_user_id IN NUMBER,
                                    p_buyer_user_id      IN NUMBER);


PROCEDURE create_buyer_acceptance_wf(p_po_header_id    IN NUMBER,
				     p_role            IN VARCHAR2,
				     p_role_user_id    IN NUMBER);

END PO_ONLINE_AUTHORING_WF_ACTIONS;

 

/
