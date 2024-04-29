--------------------------------------------------------
--  DDL for Package Body QA_SS_ATTACHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SS_ATTACHMENT" AS
/* $Header: qltssatb.plb 115.5 2002/11/27 19:30:32 jezheng ship $ */

    --
    -- Some useful constants
    --

    QUERY_ONLY constant varchar2(1) := 'Y';   -- set to 'N' if writable.

    QA_PLANS_FUNCTION constant varchar2(10) := 'QAPLMDF';
    QA_PLANS_ENTITY   constant varchar2(10) := 'QA_PLANS';

    QA_SPECS_FUNCTION constant varchar2(10) := 'QASPECF';
    QA_SPECS_ENTITY   constant varchar2(10) := 'QA_SPECS';



    --
    -- Attachment Entry Points for Collection Plans.
    --

    --
    -- This function whether there is attachment for the plan.
    -- Returns DISABLED if there is attachment cannot be used.
    --         FULL if attachment can be used and there is an attachment.
    --         EMPTY if attachment can be used but there is no attachment.
    --
    FUNCTION qa_plans_attachment_status(plan_id number) RETURN varchar2 IS
        status varchar2(20);
    BEGIN
        fnd_webattch.GetSummaryStatus(
	    x_function_name => QA_PLANS_FUNCTION,
	    x_entity_name => QA_PLANS_ENTITY,
	    x_pk1_value => to_char(plan_id),      -- PK values 1 to 5
	    attchmt_status => status);
        RETURN status;
    END qa_plans_attachment_status;

    --
    -- This function calls the fnd_webattach.ReloadSummary procedure to start
    -- viewing the attachment.  If from_url is specified, then the Back
    -- icon in the attachment form will take user back to this URL.
    --
    PROCEDURE qa_plans_view_attachment(plan_id number,
        from_url varchar2 DEFAULT null) IS
    BEGIN
        fnd_webattch.ReloadSummary(
	    function_name => QA_PLANS_FUNCTION,
	    entity_name => QA_PLANS_ENTITY,
	    pk1_value => to_char(plan_id),
	    from_url => from_url,
	    query_only => QUERY_ONLY);
    END qa_plans_view_attachment;


    --
    -- Attachment Entry Points for Specifications.
    --

    --
    -- This function whether there is attachment for the spec.
    -- Returns DISABLED if there is attachment cannot be used.
    --         FULL if attachment can be used and there is an attachment.
    --         EMPTY if attachment can be used but there is no attachment.
    --
    FUNCTION qa_specs_attachment_status(spec_id number) RETURN varchar2 IS
        status varchar2(20);
    BEGIN
        fnd_webattch.GetSummaryStatus(
	    x_function_name => QA_SPECS_FUNCTION,
	    x_entity_name => QA_SPECS_ENTITY,
	    x_pk1_value => to_char(spec_id),      -- PK values 1 to 5
	    attchmt_status => status);
        RETURN status;
    END qa_specs_attachment_status;

    --
    -- This function calls the fnd_webattach.ReloadSummary procedure to start
    -- viewing the attachment.  If from_url is specified, then the Back
    -- icon in the attachment form will take user back to this URL.
    --
    PROCEDURE qa_specs_view_attachment(spec_id number,
        from_url varchar2 DEFAULT null) IS
    BEGIN
        fnd_webattch.ReloadSummary(
	    function_name => QA_SPECS_FUNCTION,
	    entity_name => QA_SPECS_ENTITY,
	    pk1_value => to_char(spec_id),
	    from_url => from_url,
	    query_only => QUERY_ONLY);
    END qa_specs_view_attachment;

END qa_ss_attachment;


/
