--------------------------------------------------------
--  DDL for Package QA_SS_ATTACHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SS_ATTACHMENT" AUTHID CURRENT_USER AS
/* $Header: qltssatb.pls 115.4 2002/11/27 19:30:43 jezheng ship $ */

    --
    -- Attachment Entry Points for Collection Plans.
    --

    --
    -- This function whether there is attachment for the plan.
    -- Returns DISABLED if there is attachment cannot be used.
    --         FULL if attachment can be used and there is an attachment.
    --         EMPTY if attachment can be used but there is no attachment.
    --
    FUNCTION qa_plans_attachment_status(plan_id number) RETURN varchar2;

    --
    -- This function calls the fnd_webattach.summary procedure to start
    -- viewing the attachment.  If from_url is specified, then the Back
    -- icon in the attachment form will take user back to this URL.
    --
    PROCEDURE qa_plans_view_attachment(plan_id number,
        from_url varchar2 DEFAULT null);

    --
    -- This function whether there is attachment for the specification.
    -- Returns DISABLED if there is attachment cannot be used.
    --         FULL if attachment can be used and there is an attachment.
    --         EMPTY if attachment can be used but there is no attachment.
    --
    FUNCTION qa_specs_attachment_status(spec_id number) RETURN varchar2;

    --
    -- This function calls the fnd_webattach.summary procedure to start
    -- viewing the attachment.  If from_url is specified, then the Back
    -- icon in the attachment form will take user back to this URL.
    --
    PROCEDURE qa_specs_view_attachment(spec_id number,
        from_url varchar2 DEFAULT null);

END qa_ss_attachment;


 

/
