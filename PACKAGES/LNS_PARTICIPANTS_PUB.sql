--------------------------------------------------------
--  DDL for Package LNS_PARTICIPANTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_PARTICIPANTS_PUB" AUTHID CURRENT_USER AS
/* $Header: LNS_PART_PUBP_S.pls 120.6 2006/01/18 20:29:00 karamach noship $ */

TYPE loan_participant_rec_type IS RECORD(
 PARTICIPANT_ID                  NUMBER,
 LOAN_ID                         NUMBER,
 HZ_PARTY_ID                     NUMBER,
 LOAN_PARTICIPANT_TYPE           VARCHAR2(30),
 START_DATE_ACTIVE               DATE,
 END_DATE_ACTIVE                 DATE,
 CUST_ACCOUNT_ID                 NUMBER,
 BILL_TO_ACCT_SITE_ID            NUMBER,
 OBJECT_VERSION_NUMBER		 NUMBER,
 ATTRIBUTE_CATEGORY              VARCHAR2(30),
 ATTRIBUTE1                      VARCHAR2(150),
 ATTRIBUTE2                      VARCHAR2(150),
 ATTRIBUTE3                      VARCHAR2(150),
 ATTRIBUTE4                      VARCHAR2(150),
 ATTRIBUTE5                      VARCHAR2(150),
 ATTRIBUTE6                      VARCHAR2(150),
 ATTRIBUTE7                      VARCHAR2(150),
 ATTRIBUTE8                      VARCHAR2(150),
 ATTRIBUTE9                      VARCHAR2(150),
 ATTRIBUTE10                     VARCHAR2(150),
 ATTRIBUTE11                     VARCHAR2(150),
 ATTRIBUTE12                     VARCHAR2(150),
 ATTRIBUTE13                     VARCHAR2(150),
 ATTRIBUTE14                     VARCHAR2(150),
 ATTRIBUTE15                     VARCHAR2(150),
 ATTRIBUTE16                     VARCHAR2(150),
 ATTRIBUTE17                     VARCHAR2(150),
 ATTRIBUTE18                     VARCHAR2(150),
 ATTRIBUTE19                     VARCHAR2(150),
 ATTRIBUTE20                     VARCHAR2(150),
 CONTACT_REL_PARTY_ID            NUMBER,
 CONTACT_PERS_PARTY_ID           NUMBER,
 CREDIT_REQUEST_ID							 NUMBER,
 CASE_FOLDER_ID									 NUMBER,
 REVIEW_TYPE										 VARCHAR2(30),
 CREDIT_CLASSIFICATION 					 VARCHAR2(30)
 );

procedure validateParticipant(p_loan_participant_rec IN loan_participant_rec_type,
															p_mode IN VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE createParticipant(p_init_msg_list        IN VARCHAR2,
														p_validation_level		 IN NUMBER,
														p_loan_participant_rec IN loan_participant_rec_type,
                            x_participant_id       OUT NOCOPY NUMBER,
                            x_return_status        OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE updateParticipant(p_init_msg_list        IN VARCHAR2,
														p_validation_level		 IN NUMBER,
														p_loan_participant_rec IN loan_participant_rec_type,
                            x_object_version_number IN OUT NOCOPY NUMBER,
                            x_return_status        OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2);

----------------------------------------------------------------
--This procedure changes all credit requests that have been created
--for the loan participants in SAVE status to SUBMIT status
--and changes the loan secondary status to IN_CREDIT_REVIEW
----------------------------------------------------------------
PROCEDURE submitCreditRequest(p_loan_id IN NUMBER,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2);

----------------------------------------------------------------
--This procedure changes resubmit/appeal the credit request that has been created
--for the primary borrower after the case folder has been closed and when loan secondary status is CREDIT_REVIEW_COMPLETE
--and changes the loan secondary status to null
----------------------------------------------------------------
PROCEDURE createAppealCreditRequest(p_loan_id IN NUMBER,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2);

----------------------------------------------------------------
-- This is function updates lns_participants with the case_folder_id
-- if credit management case folder has been submitted with recommendations
-- for the loan application that submitted credit request
-- This is called from workflow business event from credit management
-- and also from the approval page UI if the loan is currently IN_CREDIT_REVIEW secondary status
-- This function returns 'Y' for Successful update, 'N' for update failure/error and 'I' for invalid condition
-- 'I' is returned when the loan has already changed status and case_folder_id has already been updated before
----------------------------------------------------------------
FUNCTION CASE_FOLDER_UPDATE(p_loan_id IN NUMBER) RETURN VARCHAR2;


----------------------------------------------------------------
--This is rule function, that is subscribed to the Oracle Workflow
-- Business Event CreditRequest.Recommendation.implement
--to implement recomendations of the AR CRedit Management Review
----------------------------------------------------------------
FUNCTION OCM_WORKFLOW_CREDIT_RECO_EVENT(p_subscription_guid IN RAW,
					p_event IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2;

END LNS_PARTICIPANTS_PUB;

 

/
