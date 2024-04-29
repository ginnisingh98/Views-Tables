--------------------------------------------------------
--  DDL for Package OKC_TERMS_TMPL_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_TMPL_APPROVAL_PVT" AUTHID CURRENT_USER as
/* $Header: OKCVTMPLAPPS.pls 120.0.12000000.2 2007/10/10 12:36:28 kkolukul ship $ */

    --
    --
    -- Procedure
    --    selector
    --
    -- Description
    --
    -- IN
    --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
    --   itemkey   - A string generated from the application object's primary key.
    --   itemuserkey - A string generated from the application object user-friendly
    --               primary key.
    --   actid     - The function activity(instance id).
    --   processowner - The username owner for this item instance.
    --   funcmode  - Run/Cancel
    -- OUT
    --   resultout    - Name of workflow process to run
    --
    PROCEDURE selector (
        itemtype    in varchar2,
        itemkey      in varchar2,
        actid        in number,
        funcmode    in varchar2,
        resultout    out nocopy varchar2    );


    /* added 2 new IN params and 1 out param
        p_validation_level  : 'A' or 'E' do all checks or checks with severity = E
        p_check_for_drafts  : 'Y' or 'N' if Y checks for drafts and inserts them
                              in the OKC_TMPL_DRAFT_CLAUSES table
        x_sequence_id       : contains the sequence id for table OKC_QA_ERRORS_T
                               that contains the validation results

        Existing out param  x_qa_return_status will change to
        have the following statues
        x_qa_return_status  : S if the template was succesfully submitted
                              W if qa check resulted in warnings. Use x_sequence_id
                                to display the qa results.
                              E if qa check resulted in errors. Use x_sequence_id
                                to display the qa results
                              D if there are draft articles and the user should be
                                redirected to the new submit page. Use x_sequence_id
                                if not null, to display a warnings link on the
                                 new submit page.

                                p_validation_level      p_check_for_drafts
        Search/View/Update  :   A                       Y
        New Submit Page     :   A                       N
        Validation Page     :   E                       N

    */
    PROCEDURE start_approval     (
        p_api_version                IN    Number,
        p_init_msg_list                IN    Varchar2 default FND_API.G_FALSE,
        p_commit                    IN    Varchar2 default FND_API.G_FALSE,
        p_template_id                IN    Number,
        p_object_version_number        IN    Number default NULL,
        x_return_status                OUT    NOCOPY Varchar2,
        x_msg_data                    OUT    NOCOPY Varchar2,
        x_msg_count                    OUT    NOCOPY Number,
        x_qa_return_status            OUT    NOCOPY Varchar2,

        p_validation_level            IN VARCHAR2 DEFAULT 'A',
        p_check_for_drafts          IN VARCHAR2 DEFAULT 'N',
        x_sequence_id                OUT NOCOPY NUMBER);

    --
    -- Procedure
    --    Approve_Template
    --
    -- Description
    --
    -- IN
    --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
    --   itemkey   - A string generated from the application object's primary key.
    --   itemuserkey - A string generated from the application object user-friendly
    --               primary key.
    --   actid     - The function activity(instance id).
    --   processowner - The username owner for this item instance.
    --   funcmode  - Run/Cancel
    -- OUT
    --   resultout    - Name of workflow process to run
    --
    PROCEDURE approve_template (
        itemtype    in varchar2,
        itemkey      in varchar2,
        actid        in number,
        funcmode    in varchar2,
        resultout    out nocopy varchar2    );

    --
    -- Procedure
    --    Reject_Template
    --
    -- Description
    --
    -- IN
    --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
    --   itemkey   - A string generated from the application object's primary key.
    --   itemuserkey - A string generated from the application object user-friendly
    --               primary key.
    --   actid     - The function activity(instance id).
    --   processowner - The username owner for this item instance.
    --   funcmode  - Run/Cancel
    -- OUT
    --   resultout    - Name of workflow process to run
    --
    PROCEDURE reject_template (
        itemtype    in varchar2,
        itemkey      in varchar2,
        actid        in number,
        funcmode    in varchar2,
        resultout    out nocopy varchar2    );

    --
    -- SelectApprover
    -- IN
    --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
    --   itemkey   - A string generated from the application object's primary key.
    --   actid     - The function activity(instance id).
    --   funcmode  - Run/Cancel
    -- OUT
    --   Resultout    - 'COMPLETE:T' if employee has a manager
    --          - 'COMPLETE:F' if employee does not have a manager
    --
    -- USED BY ACTIVITIES
    --  <ITEM_TYPE> <ACTIVITY>
    --
    PROCEDURE select_approver (
        itemtype    in varchar2,
        itemkey      in varchar2,
        actid        in number,
        funcmode    in varchar2,
        resultout    out nocopy varchar2    );


    PROCEDURE attachment_exists (
        itemtype    in varchar2,
        itemkey      in varchar2,
        actid        in number,
        funcmode    in varchar2,
        resultout    out nocopy varchar2    );

    PROCEDURE layout_template_exists (
        itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out nocopy varchar2     );

    /* 11.5.10+
        new procedure to change the status of articles submitted with a template
        Fecthes the article versions from table OKC_TMPL_DRAFT_CLAUSES and then
        calls article bulk api's to do the actual status changes.

        The following status changes are allowed
            DRAFT               -> PENDING_APPROVAL
            PENDING_APPROVAL    -> APPROVED/REJECTED

        p_template_id   Maps to document_id column in table OKC_TMPL_DRAFT_CLAUSES.
        p_wf_seq_id     Maps to WF_SEQ_ID column in table OKC_TMPL_DRAFT_CLAUSES.
        p_status        The status that the articles should be updated to,
                        can be one of 3 values - 'PENDING_APPROVAL', 'APPROVED', 'REJECTED'.
                        Error is thrown if the status is something else.

        p_validation_level meaningful only for p_status = PENDING_APPROVAL.
                        The pending approval blk api accepts a validation level parameter
                        to either do complete or no validation. Passed as it is to the
                        pending approval blk api.

        x_validation_results    If for any clauses fail the validation check the results
                        are returned in this table
    */
    PROCEDURE change_clause_status     (
        p_api_version               IN    NUMBER,
        p_init_msg_list             IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit                    IN    VARCHAR2 DEFAULT FND_API.G_FALSE,

        x_return_status             OUT    NOCOPY VARCHAR2,
        x_msg_data                  OUT    NOCOPY VARCHAR2,
        x_msg_count                 OUT    NOCOPY NUMBER,

        p_template_id               IN NUMBER,
        p_wf_seq_id                 IN NUMBER DEFAULT NULL,
        p_status                    IN VARCHAR2,
        p_validation_level          IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_validation_results        OUT    NOCOPY OKC_ART_BLK_PVT.validation_tbl_type);

    FUNCTION get_error_string(
        l_validation_results IN OKC_ART_BLK_PVT.validation_tbl_type)  RETURN VARCHAR2 ;

    /* 11.5.10+ */
    PROCEDURE set_notified_list(
    	itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out nocopy varchar2);

    /* 11.5.10+ */
    PROCEDURE set_notified(
    	itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out nocopy varchar2);

    /* 11.5.10+ */
    PROCEDURE decrement_counter(
    	itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out nocopy varchar2);

    /* 11.5.10+ */
    PROCEDURE global_articles_exist(
    	itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out nocopy varchar2);

    /* 11.5.10+ */
    PROCEDURE select_draft_clauses(
        p_api_version               IN    NUMBER,
        p_init_msg_list             IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit                    IN    VARCHAR2 DEFAULT FND_API.G_FALSE,

        x_return_status             OUT    NOCOPY VARCHAR2,
        x_msg_data                  OUT    NOCOPY VARCHAR2,
        x_msg_count                 OUT    NOCOPY NUMBER,

        p_template_id               IN NUMBER);

/*Bug 6329229*/

PROCEDURE set_context_info(
itemtype in varchar2,
itemkey in varchar2,
actid in number,
funcmode in varchar2,
resultout out nocopy varchar2);


END OKC_TERMS_TMPL_APPROVAL_PVT;

 

/
