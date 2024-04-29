--------------------------------------------------------
--  DDL for Package PO_CUSTOM_SUBMISSION_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CUSTOM_SUBMISSION_CHECK_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_CUSTOM_SUBMISSION_CHECK_PVT.pls 120.0.12010000.2 2009/01/12 07:04:03 mugoel noship $*/

  ------------------------------------------------------------------------------
  -- Declare public procedures.
  ------------------------------------------------------------------------------

  -- Procedure called just before standard submission checks.
  PROCEDURE do_pre_submission_check(
    p_api_version                    IN             NUMBER,
    p_document_id                    IN             NUMBER,
    p_action_requested               IN             VARCHAR2,
    p_document_type                  IN             VARCHAR2,
    p_document_subtype               IN             VARCHAR2,
    p_document_level                 IN             VARCHAR2,
    p_document_level_id              IN             NUMBER,
    p_requested_changes              IN             PO_CHANGES_REC_TYPE,
    p_check_asl                      IN             BOOLEAN,
    p_req_chg_initiator              IN             VARCHAR2,
    p_origin_doc_id                  IN             NUMBER,
    p_online_report_id               IN             NUMBER,
    p_user_id                        IN             NUMBER,
    p_login_id                       IN             NUMBER,
    p_sequence                       IN OUT NOCOPY  NUMBER,
    x_return_status                  OUT NOCOPY     VARCHAR2
  );

  -- Procedure called just after standard submission checks.
  PROCEDURE do_post_submission_check(
    p_api_version                    IN             NUMBER,
    p_document_id                    IN             NUMBER,
    p_action_requested               IN             VARCHAR2,
    p_document_type                  IN             VARCHAR2,
    p_document_subtype               IN             VARCHAR2,
    p_document_level                 IN             VARCHAR2,
    p_document_level_id              IN             NUMBER,
    p_requested_changes              IN             PO_CHANGES_REC_TYPE,
    p_check_asl                      IN             BOOLEAN,
    p_req_chg_initiator              IN             VARCHAR2,
    p_origin_doc_id                  IN             NUMBER,
    p_online_report_id               IN             NUMBER,
    p_user_id                        IN             NUMBER,
    p_login_id                       IN             NUMBER,
    p_sequence                       IN OUT NOCOPY  NUMBER,
    x_return_status                  OUT NOCOPY     VARCHAR2
  );

END PO_CUSTOM_SUBMISSION_CHECK_PVT;

/
