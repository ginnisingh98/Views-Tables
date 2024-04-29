--------------------------------------------------------
--  DDL for Package POR_AME_APPROVAL_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_AME_APPROVAL_LIST" AUTHID CURRENT_USER AS
/* $Header: POXAPL2S.pls 120.14.12010000.3 2013/03/14 05:08:13 rkandima ship $ */

G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'POR_AME_APPROVAL_LIST';
G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POXAPL2B.pls';

applicationId     number :=201; /* ame is using PO id  */
/* this variable is deprecated,
   kept only to avoid compilation dependency
   in FPI notifcation code POXWPA6B.pls */
transactionType   varchar2(50) := 'PURCHASE_REQ';
fieldDelimiter constant varchar2(1) := ',';
quoteChar   CONSTANT VARCHAR2(1)     := '\';

-- donot change this, middle tier depends on this value
E_SUCCESS                      CONSTANT NUMBER := 0;
E_EXCEPTION_APPROVER_FOUND     CONSTANT NUMBER := 1;
E_NO_NEXT_APPROVER_FOUND       CONSTANT NUMBER := 2;
E_INVALID_APPROVER             CONSTANT NUMBER := 3;
E_NO_AVAILABLE_INSERTION       CONSTANT NUMBER := 4;
E_OTHER_EXCEPTION              CONSTANT NUMBER := 999;

procedure get_ame_approval_list(pReqHeaderId        IN  NUMBER,
                            pDefaultFlag            IN NUMBER,
                            pApprovalListStr        OUT NOCOPY VARCHAR2,
                            pApprovalListCount      OUT NOCOPY NUMBER,
                            pQuoteChar              OUT NOCOPY VARCHAR2,
                            pFieldDelimiter         OUT NOCOPY VARCHAR2,
                            pApprovalAction         OUT NOCOPY VARCHAR2);

procedure get_old_approval_list(pReqHeaderId    IN  NUMBER,
                            pApprovalListStr    OUT NOCOPY VARCHAR2,
                            pApprovalListCount  OUT NOCOPY NUMBER,
                            pQuoteChar          OUT NOCOPY VARCHAR2,
                            pFieldDelimiter     OUT NOCOPY VARCHAR2);

procedure change_first_approver(pReqHeaderId    IN  NUMBER,
                            pPersonId         IN  NUMBER,
                            pApprovalListStr    OUT NOCOPY VARCHAR2,
                            pApprovalListCount  OUT NOCOPY NUMBER,
                            pQuoteChar              OUT NOCOPY VARCHAR2,
                            pFieldDelimiter         OUT NOCOPY VARCHAR2);

procedure insert_approver(pReqHeaderId  IN  NUMBER,
                            pPersonId IN NUMBER,
                            pAuthority             IN VARCHAR2,
                            pApproverCategory      IN VARCHAR2,
                            pPosition              IN NUMBER,
			    pApproverNumber        IN NUMBER,
			    pInsertionType         IN VARCHAR2,
			    pApproverName          IN VARCHAR2,
                            pApprovalListStr    OUT NOCOPY VARCHAR2,
                            pApprovalListCount  OUT NOCOPY NUMBER,
                            pQuoteChar              OUT NOCOPY VARCHAR2,
                            pFieldDelimiter         OUT NOCOPY VARCHAR2);

procedure delete_approver(pReqHeaderId          IN  NUMBER,
                            pPersonId         IN  NUMBER,
                            pOrigSystem       IN VARCHAR2,
                            pOrigSystemId     IN NUMBER,
                            pRecordName       IN VARCHAR2,
                            pAuthority        IN VARCHAR2,
                            pApprovalListStr    OUT NOCOPY VARCHAR2,
                            pApprovalListCount  OUT NOCOPY NUMBER,
                            pQuoteChar          OUT NOCOPY VARCHAR2,
                            pFieldDelimiter     OUT NOCOPY VARCHAR2);

function is_ame_reqapprv_workflow (pReqHeaderId    IN  NUMBER,
                                   pIsRcoApproval  IN BOOLEAN,
                                   xAmeTransactionType OUT NOCOPY VARCHAR2)
return varchar2;


procedure is_req_pre_approved(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

procedure get_first_authority_approver(pReqHeaderId    IN  NUMBER,
                                       xPersonId       OUT NOCOPY VARCHAR2);

procedure can_delete_oam_approvers(pReqHeaderId  IN NUMBER,
                                   xResult             OUT NOCOPY VARCHAR2);

procedure retrieve_approval_info( p_req_header_id in number,
                                  p_is_approval_history_flow in varchar2,
                                  x_is_ame_approval out NOCOPY varchar2,
                                  x_approval_status out NOCOPY varchar2,
                                  x_is_rco_approval out NOCOPY varchar2
                                );

procedure retrieve_approver_info( p_approver_id in number,
                                  x_title out NOCOPY varchar2,
                                  x_email out NOCOPY varchar2
                                );

function get_approval_group_name( p_group_id in number ) return varchar2;

procedure get_ame_approval_list_history( pReqHeaderId        IN  NUMBER,
                                         pCallingPage        IN VARCHAR2,
                                         pApprovalListStr    OUT NOCOPY VARCHAR2,
                                         pApprovalListCount  OUT NOCOPY NUMBER,
                                         pQuoteChar          OUT NOCOPY VARCHAR2,
                                         pFieldDelimiter     OUT NOCOPY VARCHAR2
                                       );

procedure getAmeTransactionType( pReqHeaderId          IN  NUMBER,
                                 pAmeTransactionType   OUT NOCOPY VARCHAR2
                                );

procedure get_next_approvers_info( pReqHeaderId    IN  NUMBER,
                                   x_approverId    OUT NOCOPY NUMBER,
                                   x_approverName  OUT NOCOPY VARCHAR2
                                 );

procedure get_person_info( p_origSystem   IN VARCHAR2,
                           p_origSystemId IN NUMBER,
                           p_displayName  IN VARCHAR2,
                           p_reqHeaderId  IN NUMBER,
                           p_logFlag      IN VARCHAR2,
                           x_personId    OUT NOCOPY NUMBER,
                           x_fullName    OUT NOCOPY VARCHAR2
                         );


FUNCTION  is_req_forward_valid( pReqHeaderId  IN NUMBER) RETURN VARCHAR2;

/* For bug 16064617 :: adding following proc which will be used in a New WF EVENT
   created for clearing AME approval list when approver rejects the requisition
   and Reject action gets successful just before sending FYI notification to preparer
   about rejection of document. */

procedure Clear_ame_apprv_list_reject(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

END;



/
