--------------------------------------------------------
--  DDL for Package GCS_DATASUB_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DATASUB_WF_PKG" AUTHID CURRENT_USER as
  /* $Header: gcs_datasub_wfs.pls 120.6 2006/11/10 12:01:16 smatam noship $ */

  -- Header level information regarding datasubmission details
  TYPE r_datasub_info IS RECORD(
    load_id                NUMBER(15),
    load_name              VARCHAR2(50),
    entity_id              NUMBER,
    ledger_id              NUMBER(15),
    cal_period_id          NUMBER,
    currency_code          VARCHAR2(30),
    balance_type_code      VARCHAR2(30),
    load_method_code       VARCHAR2(30),
    currency_type_code     VARCHAR2(30),
    amount_type_code       VARCHAR2(30),
    measure_type_code      VARCHAR2(30),
    notify_options_code    VARCHAR2(30),
    ledger_display_code    VARCHAR2(150),
    entity_display_code    VARCHAR2(150),
    transform_rule_set_id  NUMBER(15),
    validation_rule_set_id NUMBER(15),
    balances_rule_id       NUMBER(15),
    source_system_code     NUMBER(15),
    dataset_code           NUMBER(15),
    ds_balance_type_code   VARCHAR2(30),
    budget_id              NUMBER,
    budget_display_code    VARCHAR2(150),
    encumbrance_type_id    NUMBER,
    encumbrance_type_code  VARCHAR2(150));

  PROCEDURE submit_datasub(x_errbuf  OUT NOCOPY VARCHAR2,
                           x_retcode OUT NOCOPY VARCHAR2,
                           p_load_id IN NUMBER);

  PROCEDURE init_datasub_process(p_itemtype IN VARCHAR2,
                                 p_itemkey  IN VARCHAR2,
                                 p_actid    IN NUMBER,
                                 p_funcmode IN VARCHAR2,
                                 p_result   IN OUT NOCOPY VARCHAR2);

  PROCEDURE check_idt_required(p_itemtype IN VARCHAR2,
                               p_itemkey  IN VARCHAR2,
                               p_actid    IN NUMBER,
                               p_funcmode IN VARCHAR2,
                               p_result   IN OUT NOCOPY VARCHAR2);

  PROCEDURE check_validation_required(p_itemtype IN VARCHAR2,
                                      p_itemkey  IN VARCHAR2,
                                      p_actid    IN NUMBER,
                                      p_funcmode IN VARCHAR2,
                                      p_result   IN OUT NOCOPY VARCHAR2);

  PROCEDURE update_amounts(p_itemtype IN VARCHAR2,
                           p_itemkey  IN VARCHAR2,
                           p_actid    IN NUMBER,
                           p_funcmode IN VARCHAR2,
                           p_result   IN OUT NOCOPY VARCHAR2);

  PROCEDURE update_status(p_load_id IN NUMBER);

  PROCEDURE transfer_data_to_interface(p_itemtype IN VARCHAR2,
                                       p_itemkey  IN VARCHAR2,
                                       p_actid    IN NUMBER,
                                       p_funcmode IN VARCHAR2,
                                       p_result   IN OUT NOCOPY VARCHAR2);

  PROCEDURE raise_impact_analysis_event(p_load_id   IN NUMBER,
                                        p_ledger_id IN NUMBER);

  PROCEDURE execute_validation(p_itemtype IN VARCHAR2,
                               p_itemkey  IN VARCHAR2,
                               p_actid    IN NUMBER,
                               p_funcmode IN VARCHAR2,
                               p_result   IN OUT NOCOPY VARCHAR2);

  PROCEDURE execute_idt(p_itemtype IN VARCHAR2,
                        p_itemkey  IN VARCHAR2,
                        p_actid    IN NUMBER,
                        p_funcmode IN VARCHAR2,
                        p_result   IN OUT NOCOPY VARCHAR2);

  PROCEDURE submit_ogl_datasub(p_load_id    IN NUMBER,
                               p_request_id OUT NOCOPY NUMBER);

  PROCEDURE validate_member_values(p_itemtype IN VARCHAR2,
                                   p_itemkey  IN VARCHAR2,
                                   p_actid    IN NUMBER,
                                   p_funcmode IN VARCHAR2,
                                   p_result   IN OUT NOCOPY VARCHAR2);
  --
  -- function
  --   populate_ogl_datasub_dtls
  -- Purpose
  --   An API to populate the gcs_dats_sub_dtls.
  --   This API has subscription with the business event "oracle.apps.fem.oglintg.balrule.execute"
  -- Arguments
  --   p_subscription_guid - This subscription GUID is passed when the event is raised
  --   p_event             - wf_event_t param
  -- Notes
  --

  FUNCTION populate_ogl_datasub_dtls(p_subscription_guid IN RAW,
                                     p_event             IN OUT NOCOPY wf_event_t)
    RETURN VARCHAR2;

  --
  -- function
  --   handle_undo_event
  -- Purpose
  --   An API to handle the UNDO Event submitted via EPF.
  --   This API has subscription with the business event "oracle.apps.fem.ud.complete"
  -- Arguments
  --   p_subscription_guid - This subscription GUID is passed when the event is raised
  --   p_event             - wf_event_t param
  -- Notes
  -- Bug Fix : 5647099
  FUNCTION handle_undo_event(p_subscription_guid IN RAW,
                             p_event             IN OUT NOCOPY wf_event_t)
    RETURN VARCHAR2;

END GCS_DATASUB_WF_PKG;

/
