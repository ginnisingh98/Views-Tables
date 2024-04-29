--------------------------------------------------------
--  DDL for Package OKC_TERMS_TMPL_APPROVAL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_TMPL_APPROVAL_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGTMPLAPPS.pls 120.0 2005/05/25 22:40:29 appldev noship $ */

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
		p_api_version				IN	Number,
		p_init_msg_list				IN	Varchar2 default FND_API.G_FALSE,
		p_commit					IN	Varchar2 default FND_API.G_FALSE,
		p_template_id				IN    Number,
		p_object_version_number		IN    Number default NULL,
		x_return_status				OUT	NOCOPY Varchar2,
		x_msg_data					OUT	NOCOPY Varchar2,
		x_msg_count					OUT	NOCOPY Number,
		x_qa_return_status			OUT	NOCOPY Varchar2,

		p_validation_level			IN VARCHAR2 DEFAULT 'A',
        p_check_for_drafts          IN VARCHAR2 DEFAULT 'N',
		x_sequence_id				OUT NOCOPY NUMBER);


END OKC_TERMS_TMPL_APPROVAL_GRP;

 

/
