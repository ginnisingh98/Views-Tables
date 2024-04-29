--------------------------------------------------------
--  DDL for Package IEX_CHECKLIST_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CHECKLIST_UTILITY" AUTHID CURRENT_USER AS
/* $Header: iexvchks.pls 120.1.12010000.2 2009/07/31 09:08:41 pnaveenk ship $ */

  FUNCTION GET_GO_TO_TASK_IMAGE_NAME(
    p_checklist_item_name IN VARCHAR2,
    p_checklist_item_type IN VARCHAR2,
	p_checklist_item_status IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION GET_STATUS_IMAGE_NAME(
    p_checklist_item_name IN VARCHAR2,
    p_checklist_item_type IN VARCHAR2,
	p_checklist_item_status IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION GET_RANGE_FROM_VALUE(
    p_score_comp_type_id IN NUMBER,
    p_lookup_code IN VARCHAR2) RETURN NUMBER;

  FUNCTION GET_RANGE_TO_VALUE(
    p_score_comp_type_id IN NUMBER,
    p_lookup_code IN VARCHAR2) RETURN NUMBER;

  PROCEDURE UPDATE_METRIC_RATING(
    p_score_comp_type_id IN NUMBER,
    p_low_from IN NUMBER,
    p_low_to IN NUMBER,
    p_medium_from IN NUMBER,
    p_medium_to IN NUMBER,
    p_high_from IN NUMBER,
    p_high_to IN NUMBER);

  PROCEDURE UPDATE_CHECKLIST_ITEM(
    p_checklist_item_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE CHANGE_LEASING_SETUP(
    p_leasing_enabled IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE CHANGE_LOAN_SETUP(
    p_loan_enabled IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE CHANGE_BUSINESS_LEVEL(
    p_business_level IN VARCHAR2,
    p_promise_enabled IN VARCHAR2,
    p_collections_methods IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE UPDATE_CHECKLIST_ITEM_BY_NAME(
    p_checklist_item_name IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2);

  -- Added for bug 8708271 pnaveenk multi level strategy

  PROCEDURE CHANGE_MULTIPLE_LEVEL(
    p_account_level IN VARCHAR2,
    p_billto_level IN VARCHAR2,
    p_customer_level IN VARCHAR2,
    p_delinquency_level IN VARCHAR2,
    p_override_party_level IN VARCHAR2,
    p_ou_running_level IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE UPDATE_MLSETUP;

  -- end for bug 8708271

END;

/
