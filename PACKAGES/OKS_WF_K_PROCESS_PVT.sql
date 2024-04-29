--------------------------------------------------------
--  DDL for Package OKS_WF_K_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_WF_K_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSVKWFS.pls 120.11.12010000.3 2009/05/14 09:41:48 cgopinee ship $ */

    TYPE WF_ATTR_DETAILS IS RECORD
    (
     CONTRACT_ID        NUMBER,
     CONTRACT_NUMBER    VARCHAR2(120),
     CONTRACT_MODIFIER  VARCHAR2(120),
     PROCESS_TYPE       VARCHAR2(30),  -- Online, Manual or Evergreen
     -- Valid values are Manual(M), Automatic(A), Yes(Y), No or Not required(N)
     IRR_FLAG           VARCHAR2(5),
     NEGOTIATION_STATUS VARCHAR2(30),
     ITEM_KEY           WF_ITEMS.ITEM_KEY%TYPE
     );

    TYPE WF_ATTR_DETAILS_TBL IS TABLE OF WF_ATTR_DETAILS INDEX BY BINARY_INTEGER;

    TYPE email_attr_rec IS RECORD
    (
     CONTRACT_ID        NUMBER,
     ITEM_KEY           WF_ITEMS.ITEM_KEY%TYPE,
     EMAIL_TYPE         VARCHAR2(10),
     TO_EMAIL           VARCHAR2(4000),
     SENDER_EMAIL       VARCHAR2(4000),
     EMAIL_SUBJECT      VARCHAR2(4000),
     IH_SUBJECT         VARCHAR2(4000),
     IH_MESSAGE         VARCHAR2(4000),
     EMAIL_BODY_ID      NUMBER,
     ATTACHMENT_ID      NUMBER,
     ATTACHMENT_NAME    VARCHAR2(150),
     CONTRACT_STATUS    VARCHAR2(30)
     );

    TYPE notif_attr_rec IS RECORD
    (
     CONTRACT_ID        NUMBER,
     ITEM_KEY           WF_ITEMS.ITEM_KEY%TYPE,
     PERFORMER          VARCHAR2(100),
     NTF_TYPE           VARCHAR2(30),
     NTF_SUBJECT        VARCHAR2(2000),
     MESSAGE1           VARCHAR2(2000),
     MESSAGE2           VARCHAR2(2000),
     MESSAGE3           VARCHAR2(2000),
     MESSAGE4           VARCHAR2(2000),
     MESSAGE5           VARCHAR2(2000),
     MESSAGE6           VARCHAR2(2000),
     MESSAGE7           VARCHAR2(2000),
     MESSAGE8           VARCHAR2(2000),
     MESSAGE9           VARCHAR2(2000),
     MESSAGE10          VARCHAR2(2000),
     SUBJECT            VARCHAR2(4000),
     ACCEPT_DECLINE_BY  VARCHAR2(4000),
     REQ_ASSIST_ROLE    VARCHAR2(100),
     MSGS_FROM_STACK_YN VARCHAR2(1)
     );

    PROCEDURE is_online_k_yn
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     x_online_yn OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2
     );

    PROCEDURE complete_activity
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     p_resultout IN VARCHAR2,
     p_process_status IN VARCHAR2,
     p_activity_name IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER
     );

    PROCEDURE customer_accept_quote
    (

     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER
     );

    PROCEDURE customer_decline_quote
    (

     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     p_reason_code IN VARCHAR2,
     p_comments IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER
     );

    PROCEDURE customer_request_assistance
    (

     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     p_to_email IN VARCHAR2,
     p_cc_email IN VARCHAR2,
     p_subject IN VARCHAR2,
     p_message IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER
     );

    PROCEDURE set_notification_attr
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    PROCEDURE set_notification_attr
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_contract_id IN NUMBER,
     p_performer IN VARCHAR2,
     p_notif_type IN VARCHAR2,
     p_notif_subject IN VARCHAR2,
     p_message1 IN VARCHAR2,
     p_message2 IN VARCHAR2,
     p_message3 IN VARCHAR2,
     p_message4 IN VARCHAR2,
     p_message5 IN VARCHAR2,
     p_message6 IN VARCHAR2,
     p_message7 IN VARCHAR2,
     p_message8 IN VARCHAR2,
     p_message9 IN VARCHAR2,
     p_message10 IN VARCHAR2,
     p_subject IN VARCHAR2,
     p_msgs_from_stack_yn IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY VARCHAR2,
     x_msg_data OUT NOCOPY VARCHAR2
     );

    PROCEDURE launch_k_process_wf
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_wf_attributes IN OKS_WF_K_PROCESS_PVT.WF_ATTR_DETAILS,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2
     );

    PROCEDURE submit_for_approval
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     p_validate_yn IN VARCHAR2,
     p_qa_required_yn IN VARCHAR2,
     x_negotiation_status OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2
     );

    PROCEDURE cancel_contract
    (

     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     p_cancellation_reason IN VARCHAR2,
     p_cancellation_date IN DATE,
     p_cancel_source IN VARCHAR2,
     p_comments IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER
     );

    PROCEDURE assign_new_qto_contact
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER
     );

    PROCEDURE clean_wf
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER
     );

    PROCEDURE publish_to_customer
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2
     );

    PROCEDURE initialize
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    PROCEDURE get_old_wf_status
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    procedure email_mute
    (
    itemtype	IN VARCHAR2,
    itemkey  	IN VARCHAR2,
    actid	IN number,
    funcmode	IN VARCHAR2,
    resultout   OUT NOCOPY VARCHAR2
    );

    PROCEDURE get_process_type
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    /*cgopinee bugfix for 8361496*/
    PROCEDURE get_curr_conv_date_validity
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
    );
    PROCEDURE salesrep_action
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    PROCEDURE check_qa
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    PROCEDURE process_negotiation_status
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    PROCEDURE update_negotiation_status
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_chr_id IN NUMBER,
     p_negotiation_status IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2
     );

    PROCEDURE is_approval_required
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    PROCEDURE get_approval_flag
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    PROCEDURE is_submit_for_approval_allowed
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     x_activity_name OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2
     );

    PROCEDURE customer_action
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    PROCEDURE launch_approval_wf
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    PROCEDURE accept_quote
    (

     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_contract_id IN NUMBER,
     p_item_key IN VARCHAR2,
     p_accept_confirm_yn IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER
     );

    PROCEDURE activate_contract
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

    PROCEDURE set_email_attr
    (
     itemtype IN VARCHAR2,
     itemkey IN VARCHAR2,
     actid IN NUMBER,
     funcmode IN VARCHAR2,
     resultout OUT NOCOPY VARCHAR2
     );

/*
    This procesure is a concurrent program, that launches wf for all
    ENTERED status contracts, that do not have a workflow associated with them
    and have not been submitted for approval
*/
    PROCEDURE launch_wf_conc_prog
    (
     ERRBUF OUT NOCOPY VARCHAR2,
     RETCODE OUT NOCOPY NUMBER
     );

    /* Bulk API for launching wf for ENTERED status Service Contracts
	This procedure launches the workflow for a Service Contract. From R12 onwards every
    Service Contract when created has a workflow associated with it, that routes the
    contract till it is activated.

    Parameters
        p_wf_attributes_tbl     :   table of records containg the details of the workflow to be
                                     launched
        p_update_item_key       :  Y|N indicating if oks_k_headers_b and oks_k_headers_bh are to be
                                    updated with the passed item keys

    Rules for input record fiels
        1. Contract_id must be passed, if not passed the record is ignored
        2. Contract number and modifier must be passed, they are set as item attributes for the
           workflow
        3. Process_type and irr_flag are optional, they are stamped as workflow item
            attributes. Defaulted as -  procees_type = NSR and irr_flag = Y
        4. Negotiation_status is optional, if NULL or PREDRAFT, it is defaulted as DRAFT. It is
           stamped as workflow item attribute.
        5. Item_key is optional, if not passed it is defaulted as
           contract_id || to_char(sysdate, 'YYYYMMDDHH24MISS').

    */
    PROCEDURE launch_k_process_wf_blk
    (
     p_api_version IN NUMBER DEFAULT 1.0,
     p_init_msg_list IN VARCHAR2 DEFAULT 'F',
     p_commit IN VARCHAR2 DEFAULT 'F',
     p_wf_attributes_tbl IN WF_ATTR_DETAILS_TBL,
     p_update_item_key  IN VARCHAR2 DEFAULT 'Y',
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2
     );

END OKS_WF_K_PROCESS_PVT;

/
