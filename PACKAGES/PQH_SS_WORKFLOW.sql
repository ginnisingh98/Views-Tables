--------------------------------------------------------
--  DDL for Package PQH_SS_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SS_WORKFLOW" AUTHID CURRENT_USER as
/* $Header: pqwftswi.pkh 120.0.12010000.1 2008/07/28 13:18:21 appldev ship $*/

-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

--
FUNCTION get_transaction_id (
        p_itemType      IN VARCHAR2
       ,p_itemKey       IN VARCHAR2 ) RETURN NUMBER ;
--
--
FUNCTION get_notified_activity (
        p_itemType      IN VARCHAR2
       ,p_itemKey       IN VARCHAR2
       ,p_ntfId         IN VARCHAR2
       ) RETURN NUMBER ;
--
--
FUNCTION get_notified_activity (
        p_itemType      IN VARCHAR2
       ,p_itemKey       IN VARCHAR2
       ) RETURN NUMBER;
--
--
PROCEDURE start_approval_wf (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 );
--
--
PROCEDURE complete_wf_activity (
      p_itemType    IN VARCHAR2,
      p_itemKey     IN VARCHAR2,
      p_activity    IN NUMBER,
      p_otherAct    IN VARCHAR2,
      p_resultCode  IN VARCHAR2,
      p_commitFlag  IN VARCHAR2 DEFAULT 'N' );
--
--
PROCEDURE get_transaction_info (
    p_itemType       IN VARCHAR2
   ,p_itemKey        IN VARCHAR2
   ,p_loginPerson    IN VARCHAR2
   ,p_whatchecks     IN VARCHAR2 DEFAULT 'EPIG'
   ,p_calledFrom     IN VARCHAR2 DEFAULT 'REQUEST'
   ,p_personId      OUT NOCOPY VARCHAR2
   ,p_assignmentId  OUT NOCOPY VARCHAR2
   ,p_state         OUT NOCOPY VARCHAR2
   ,p_status        OUT NOCOPY VARCHAR2
   ,p_txnId         OUT NOCOPY VARCHAR2
   ,p_businessGrpId OUT NOCOPY VARCHAR2
   ,p_editAllowed   OUT NOCOPY VARCHAR2
   ,p_futureChange  OUT NOCOPY VARCHAR2
   ,p_pendingTxn    OUT NOCOPY VARCHAR2
   ,p_interAction   OUT NOCOPY VARCHAR2
   ,p_effDateOption IN OUT NOCOPY VARCHAR2
   ,p_effectiveDate IN OUT NOCOPY VARCHAR2
   ,p_isPersonElig  OUT NOCOPY VARCHAR2
   ,p_rptgGrpId     OUT NOCOPY VARCHAR2
   ,p_planId        OUT NOCOPY VARCHAR2
   ,p_processName   OUT NOCOPY VARCHAR2
   ,p_dateParmExist OUT NOCOPY VARCHAR2
   ,p_rateParmExist OUT NOCOPY VARCHAR2
   ,p_slryParmExist OUT NOCOPY VARCHAR2
   ,p_rateMessage   OUT NOCOPY VARCHAR2
   ,p_terminateFlag OUT NOCOPY VARCHAR2 );
--
--
PROCEDURE revert_to_last_save (
    p_txnId         IN NUMBER
   ,p_itemType      IN VARCHAR2
   ,p_itemKey       IN VARCHAR2
   ,p_status        IN VARCHAR2
   ,p_state         IN VARCHAR2
   ,p_revertFlag    IN VARCHAR2      ) ;
--
--
PROCEDURE get_url_for_edit (
    p_itemType      IN VARCHAR2
   ,p_itemKey       IN VARCHAR2
   ,p_activityId   OUT NOCOPY VARCHAR2
   ,p_functionName OUT NOCOPY VARCHAR2
   ,p_url          OUT NOCOPY VARCHAR2  );
--
--
  PROCEDURE reset_txn_current_values (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2  ) ;
--
--
  PROCEDURE return_for_correction (
       p_itemType        IN VARCHAR2
     , p_itemKey         IN VARCHAR2
     , p_userId          IN VARCHAR2
     , p_userName        IN VARCHAR2
     , p_userDisplayName IN VARCHAR2
     , p_ntfId           IN VARCHAR2
     , p_note            IN VARCHAR2
     , p_approverIndex   IN NUMBER
     , p_txnId           IN VARCHAR2 );
--
--
PROCEDURE check_initial_save_for_later (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2  );
--
--
PROCEDURE set_transaction_status (
      p_itemtype        IN     VARCHAR2,
      p_itemkey         IN     VARCHAR2,
      p_activityId      IN     VARCHAR2 DEFAULT NULL,
      p_action          IN     VARCHAR2,
      p_result          OUT NOCOPY    VARCHAR2  ) ;
--
--
PROCEDURE set_txn_submit_status (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2  );
--
--
PROCEDURE set_txn_approve_status (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2  );
--
--
PROCEDURE set_txn_rfc_status (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2  );
--
--
PROCEDURE set_txn_sfl_status (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2  ) ;
--
--
/* 22-May-2003:ns: commenting as it is no longer used
PROCEDURE check_eligibility (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2  ) ;
--
--
PROCEDURE apply_or_approve_only (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2  ) ;
*/
--
--
PROCEDURE get_edit_link(
      document_id   IN     VARCHAR2,
      display_type  IN     VARCHAR2,
      document      IN OUT NOCOPY VARCHAR2,
      document_type IN OUT NOCOPY VARCHAR2);
--
--
/*
procedure Notify_HR_Rep(
          itemtype   IN VARCHAR2,
	  itemkey    IN VARCHAR2,
      	    actid    IN NUMBER,
	  funcmode   IN VARCHAR2,
	  resultout  IN OUT NOCOPY VARCHAR2) ;
--
*/
--
PROCEDURE  set_effective_date_and_option (
           p_txnId               IN VARCHAR2
          ,p_effectiveDate       IN DATE
          ,p_effectiveDateOption IN VARCHAR2 );
--
--
PROCEDURE check_for_warning_error (
      document_id   IN     VARCHAR2,
      display_type  IN     VARCHAR2,
      document      IN OUT NOCOPY VARCHAR2,
      document_type IN OUT NOCOPY VARCHAR2) ;
--
--
PROCEDURE set_date_if_as_of_approval (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2  );
--
--
FUNCTION is_notification_closed (
      p_ntfId        IN VARCHAR2 ) RETURN VARCHAR2;
--
--
FUNCTION complete_custom_rfc (
      p_ntfId  IN VARCHAR2 ) RETURN VARCHAR2  ;
--
--
PROCEDURE validation_on_final_approval (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 ) ;
--
--
FUNCTION get_errors_and_warnings (
      p_itemType     IN        VARCHAR2,
      p_itemKey      IN        VARCHAR2,
      p_calledFrom   IN        VARCHAR2  DEFAULT NULL,
      p_addToPub     IN        VARCHAR2  DEFAULT 'NO',
      p_sendToHr    OUT NOCOPY VARCHAR2,
      p_hasErrors   OUT NOCOPY VARCHAR2) RETURN VARCHAR2;
--
--
procedure delete_txn_notification(
        p_itemType      IN VARCHAR2
       ,p_itemKey       IN VARCHAR2
       ,p_transactionId IN VARCHAR2
       );
--
--
PROCEDURE set_hr_rep_role (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 );

--
--
procedure approval_block(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2);
--
--
PROCEDURE approval_history (
      document_id   in     varchar2,
      display_type  in     varchar2,
      document      in out nocopy varchar2,
      document_type in out nocopy varchar2 );
--
--
PROCEDURE reset_process_section_attr (
      itemtype        IN         VARCHAR2,
      itemkey         IN         VARCHAR2,
      actid           IN         NUMBER,
      funcmode        IN         VARCHAR2,
      result          OUT NOCOPY VARCHAR2 );
--
--
PROCEDURE set_image_source (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 ) ;
--
--
PROCEDURE get_item_type_and_key (
              p_ntfId       IN NUMBER
             ,p_itemType   OUT NOCOPY VARCHAR2
             ,p_itemKey    OUT NOCOPY VARCHAR2 ) ;
--
--
FUNCTION set_developer_ntf_msg (
              p_itemType IN VARCHAR2
             ,p_itemKey  IN VARCHAR2) RETURN VARCHAR;
--
--
END; -- Package Specification PQH_SS_WORKFLOW

/
