--------------------------------------------------------
--  DDL for Package QA_ERES_DEFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_ERES_DEFER" AUTHID CURRENT_USER AS
/* $Header: qaedrdfs.pls 120.1 2006/09/14 23:33:34 shkalyan noship $ */

  -- Post Operation APIs used for eSig Deferred Approval
  --  .

  -- Post Operation API used for Specification status
  -- update.

  PROCEDURE spec_status_update
              (p_spec_id       IN  NUMBER
              );

  -- Post Operation API for updating the Approval
  -- status of the NCM logged.

  PROCEDURE ncm_approve
              (p_plan_id       IN NUMBER,
               p_collection_id IN NUMBER,
               p_occurrence    IN NUMBER
              );

  -- Post Operation API for updating the Approval
  -- status of the NCM Detail.

  PROCEDURE ncm_detail_approve
              (p_plan_id       IN NUMBER,
               p_collection_id IN NUMBER,
               p_occurrence    IN NUMBER
              );

  -- Post Operation API for updating the Approval
  -- status of the Disposition logged.

  PROCEDURE disp_approve
              (p_plan_id       IN NUMBER,
               p_collection_id IN NUMBER,
               p_occurrence    IN NUMBER
              );

  -- Post Operation API for updating the Approval
  -- status of the Disposition Detail.

  PROCEDURE disp_detail_approve
              (p_plan_id       IN NUMBER,
               p_collection_id IN NUMBER,
               p_occurrence    IN NUMBER
              );

  -- Post Operation API for updating the Approval
  -- status of the CAR Review.

  PROCEDURE car_review_approve
              (p_plan_id       IN NUMBER,
               p_collection_id IN NUMBER,
               p_occurrence    IN NUMBER
              );

  -- Post Operation API for updating the Approval
  -- status of the CAR Approval.

  PROCEDURE car_impl_approve
              (p_plan_id       IN NUMBER,
               p_collection_id IN NUMBER,
               p_occurrence    IN NUMBER
              );

  -- R12 ERES Support in Service Family. Bug 4345768
  -- START

  -- Post Operation API for updating the Approval
  -- status of the QA Results Occurrence.

  PROCEDURE qa_occurrence_approve
              (p_plan_id       IN NUMBER,
               p_collection_id IN NUMBER,
               p_occurrence    IN NUMBER
              );

  -- Post Operation API for updating the Approval
  -- status of the QA Results Collection.
  PROCEDURE qa_collection_approve
              (p_plan_id       IN NUMBER,
               p_collection_id IN NUMBER
              );

  -- END
  -- R12 ERES Support in Service Family. Bug 4345768

  -- Bug 5508639. SHKALYAN 13-Sep-2006.
  -- Overloaded Post Operation API for updating the Approval
  -- status of the QA Results Collection for a given txn_header_id.
  PROCEDURE qa_collection_approve
              (p_plan_id       IN NUMBER,
               p_collection_id IN NUMBER,
               p_txn_header_id IN NUMBER
              );

END QA_ERES_DEFER;


 

/
