--------------------------------------------------------
--  DDL for Package HR_SFLUTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SFLUTIL_SS" AUTHID CURRENT_USER AS
/* $Header: hrsflutlss.pkh 120.2 2006/12/04 13:27:26 rachakra noship $ */

procedure sflBlock
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2);


procedure closeSFLNotifications(p_transaction_id       IN NUMBER
                               ,p_approvalItemType     in     varchar2
                               ,p_approvalItemKey      in     varchar2);

procedure closeSFLTransaction
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2);

procedure Notify(itemtype   in varchar2,
			  itemkey    in varchar2,
      		   actid      in number,
	 		  funcmode   in varchar2,
			  resultout  in out nocopy varchar2);

procedure getSFLMsgSubject(document_id IN Varchar2,
                          display_type IN Varchar2,
                          document IN OUT NOCOPY varchar2,
                          document_type IN OUT NOCOPY Varchar2) ;

procedure getSFLTransactionDetails (
              p_transaction_id IN NUMBER
             ,p_ntfId      OUT NOCOPY NUMBER
             ,p_itemType   IN OUT NOCOPY VARCHAR2
             ,p_itemKey    OUT NOCOPY VARCHAR2 );

procedure sendSFLNotification(p_transaction_id IN NUMBER,
                              p_transaction_ref_table in varchar2,
                              p_userName in varchar2,
			      p_reentryPageFunction in varchar2,
			      p_sflWFProcessName in varchar2,
                              p_notification_id out NOCOPY number);

procedure setSFLNtfDetails
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2);


function getSubject(p_transaction_id in number,
                    p_notification_id in number) return varchar2;

function isTxnOwner(p_transaction_id in number,
                    p_person_id in number) return boolean;

function getSFLStatusForUpdate(
     p_currentTxnStatus in varchar2,
     p_proposedTxnStatus in varchar2) RETURN VARCHAR2;

function OpenNotificationsExist( nid    in Number ) return Boolean;

procedure processApprovalSubmit(p_transaction_id in number);

procedure closeOpenSFLNotification(p_transaction_id       IN NUMBER);

--5672792
function isCurrentTxnSFLClose ( p_transaction_id hr_api_transactions.transaction_id%type )
return varchar2;
--5672792

END HR_SFLUTIL_SS;

/
