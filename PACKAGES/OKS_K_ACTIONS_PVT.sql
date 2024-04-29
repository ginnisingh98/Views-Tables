--------------------------------------------------------
--  DDL for Package OKS_K_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_K_ACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSKACTS.pls 120.6.12010000.2 2008/11/04 12:35:38 kkolukul ship $ */

PROCEDURE setRemindersYn
(
 p_api_version          IN NUMBER,
 p_init_msg_list        IN VARCHAR2,
 p_chr_id               IN NUMBER,
 p_suppress_Yn		IN VARCHAR2,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
);

PROCEDURE send_email
(p_chr_id                    IN number
,p_to_address                IN VARCHAR2
,p_cc_address                IN VARCHAR2
,p_from_address              IN VARCHAR2
,p_reply_to_address          IN VARCHAR2
,p_subject                   IN VARCHAR2
,p_message_template_id       IN number
,p_attachment_template_id   IN number
,p_email_text                IN VARCHAR2
,p_contract_status_code      IN VARCHAR2
,x_request_id                OUT NOCOPY number
,x_return_status             OUT NOCOPY VARCHAR2
,x_msg_count                 OUT NOCOPY NUMBER
,x_msg_data                  OUT NOCOPY varchar2
);

PROCEDURE execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    p_override_flag                IN  VARCHAR2);

FUNCTION get_to_email (p_contract_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE launch_qa_report
(
 p_api_version          IN NUMBER,
 p_init_msg_list        IN VARCHAR2,
 p_contract_list        IN VARCHAR2,
 x_cp_request_id        OUT NOCOPY NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) ;


/*
This function checks if the contract is valid for Renewal Workbench Table Action
s. This check is done before doing following Actions
Enable Reminders, Disable Reminders, Submit for Approval and Publish to Customer
Parameter: contract id
Returns: Y or N. If the ste_code is ENTERED then returns Y else returns N
*/
FUNCTION validateForRenewalAction (p_chr_id NUMBER, p_called_from VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

/*
This method will insert the email details
into OKS_EMAIL_DETAILS table and
will return email_id as the output parameter value.- Bug#4911901
*/

PROCEDURE STORE_EMAIL_DTLS
(
 p_from_address             IN  VARCHAR2,
 p_to_address               IN  VARCHAR2,
 p_cc_address               IN  VARCHAR2,
 p_reply_to_address         IN  VARCHAR2,
 p_message_template_id      IN  NUMBER,
 p_attachment_template_id   IN  NUMBER,
 p_email_subject            IN  VARCHAR2,
 p_email_body               IN  VARCHAR2,
 p_email_contract_status    IN  VARCHAR2,
 x_email_id                 OUT NOCOPY NUMBER,
 x_return_status	    OUT NOCOPY VARCHAR2,
 x_msg_data	            OUT NOCOPY VARCHAR2,
 x_msg_count	            OUT NOCOPY NUMBER
);

/*
This API will retrieve email details from OKS_EMAIL_DETAILS table.- Bug#4911901
*/

PROCEDURE GET_EMAIL_DTLS
(
 p_email_id                 IN  NUMBER,
 x_email_body               OUT NOCOPY VARCHAR2,
 x_return_status	    OUT NOCOPY VARCHAR2,
 x_msg_data	            OUT NOCOPY VARCHAR2,
 x_msg_count	            OUT NOCOPY NUMBER
);

/*
This API will delete email details from OKS_EMAIL_DETAILS table.- Bug#4911901
*/
PROCEDURE DEL_EMAIL_DTLS
(
 p_email_id                 IN  NUMBER,
 x_return_status	    OUT NOCOPY VARCHAR2,
 x_msg_data	            OUT NOCOPY VARCHAR2,
 x_msg_count	            OUT NOCOPY NUMBER
);

/* Overloaded send_email API that has been already defined.- Bug#4911901*/
PROCEDURE send_email
(p_chr_id                    IN NUMBER
,p_email_Id                  IN NUMBER
,p_to_address                IN VARCHAR2
,p_cc_address                IN VARCHAR2
,p_from_address              IN VARCHAR2
,p_reply_to_address          IN VARCHAR2
,p_subject                   IN VARCHAR2
,p_message_template_id       IN NUMBER
,p_attachment_template_id    IN NUMBER
,p_contract_status_code      IN VARCHAR2
,x_request_id                OUT NOCOPY NUMBER
,x_return_status             OUT NOCOPY VARCHAR2
,x_msg_count                 OUT NOCOPY NUMBER
,x_msg_data                  OUT NOCOPY VARCHAR2
);

/*
This API will update contract status, followup, forecast, notes for Mass and Single update contract action
*/
PROCEDURE update_single_contracts
                      (
			p_chr_id         IN OKC_K_HEADERS_ALL_B.ID%TYPE,
			p_status_code    IN OKC_K_HEADERS_ALL_B.STS_CODE%TYPE default NULL,
			p_reason_code    IN OKC_K_HEADERS_ALL_B.TRN_CODE%TYPE default NULL,
			p_comments       IN VARCHAR2 default NULL,
			p_due_date       IN OKS_K_HEADERS_B.FOLLOW_UP_DATE%TYPE default NULL,
			p_action         IN OKS_K_HEADERS_B.FOLLOW_UP_ACTION%TYPE default NULL,
			p_est_percent    IN OKS_K_HEADERS_B.EST_REV_PERCENT%TYPE default NULL,
			p_est_date       IN OKS_K_HEADERS_B.EST_REV_DATE%TYPE default NULL,
			p_contract_notes IN JTF_NOTES_TL.NOTES%TYPE default NULL,
                        p_renewal_notes  IN OKS_K_HEADERS_B.RENEWAL_COMMENT%TYPE default NULL,
                        x_succ_err_contract  OUT NOCOPY VARCHAR2,
    			x_return_status  OUT NOCOPY VARCHAR2,
    			x_msg_data       OUT NOCOPY VARCHAR2,
    			x_msg_count      OUT NOCOPY NUMBER
                      );


END OKS_K_ACTIONS_PVT;


/
