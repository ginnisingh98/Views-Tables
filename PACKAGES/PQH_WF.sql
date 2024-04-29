--------------------------------------------------------
--  DDL for Package PQH_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WF" AUTHID CURRENT_USER AS
/* $Header: pqhwfpc.pkh 120.0.12010000.1 2008/07/28 13:01:24 appldev ship $ */
  PROCEDURE FIND_NEXT_USER (
      itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
    );
  PROCEDURE notify_requestor (
      itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
    );
  PROCEDURE SET_NEXT_USER (
        p_itemtype                       in varchar2
	  , p_itemkey                        in varchar2
      , p_route_to_user                  in varchar2
      , p_status                         in varchar2 DEFAULT NULL
      );
  PROCEDURE SET_NEXT_USER (
        p_transaction_category_id        in number
	  , p_transaction_id                 in number
      , p_route_to_user                  in varchar2
      , p_status                         in varchar2
      );
  FUNCTION post_any_txn (p_transaction_id             IN NUMBER
                       )
  RETURN VARCHAR2;
/*
  PROCEDURE StartProcess(
        p_itemkey                        in varchar2
      , p_itemtype                       in varchar2
      , p_process_name                   in varchar2
      , p_route_to_user                  in varchar2
      , p_user_status                    in varchar2
      , p_timeout_days                   in number
      , p_form_name                      in VARCHAR2
      , p_transaction_id                 in NUMBER
      , p_transaction_category_id        in NUMBER
      , p_post_txn_function              IN VARCHAR2
      , p_future_action_cd               IN VARCHAR2
      , p_post_style_cd                  IN VARCHAR2
      , p_transaction_name               IN VARCHAR2
      , p_transaction_category_name      IN VARCHAR2
  );
*/
  PROCEDURE process_user_action(
        p_transaction_category_id        IN NUMBER
      , p_transaction_id                 IN NUMBER
      , p_workflow_seq_no                IN NUMBER      DEFAULT NULL
      , p_routing_category_id            in number      DEFAULT NULL
      , p_member_cd                      IN VARCHAR2    DEFAULT NULL
      , p_user_action_cd                 in varchar2    DEFAULT 'FORWARD'
      , p_route_to_user                  IN VARCHAR2
      , p_user_status                    IN VARCHAR2    DEFAULT 'FOUND'
      , p_approval_cd                    IN VARCHAR2    DEFAULT NULL
      , p_pos_structure_version_id       in number      DEFAULT NULL
      , p_comments                       in varchar2    DEFAULT NULL
      , p_forwarded_to_user_id           in number      DEFAULT NULL
      , p_forwarded_to_role_id           in number      DEFAULT NULL
      , p_forwarded_to_position_id       in number      DEFAULT NULL
      , p_forwarded_to_assignment_id     in number      DEFAULT NULL
      , p_forwarded_to_member_id         in number      DEFAULT NULL
      , p_forwarded_by_user_id           in number      DEFAULT NULL
      , p_forwarded_by_role_id           in number      DEFAULT NULL
      , p_forwarded_by_position_id       in number      DEFAULT NULL
      , p_forwarded_by_assignment_id     in number      DEFAULT NULL
      , p_forwarded_by_member_id         in number      DEFAULT NULL
      , p_effective_date                 IN DATE        DEFAULT NULL
      , p_parameter1_name                IN varchar2    DEFAULT NULL
      , p_parameter1_value               IN varchar2    DEFAULT NULL
      , p_parameter2_name                IN varchar2    DEFAULT NULL
      , p_parameter2_value               IN varchar2    DEFAULT NULL
      , p_parameter3_name                IN varchar2    DEFAULT NULL
      , p_parameter3_value               IN varchar2    DEFAULT NULL
      , p_parameter4_name                IN varchar2    DEFAULT NULL
      , p_parameter4_value               IN varchar2    DEFAULT NULL
      , p_parameter5_name                IN varchar2    DEFAULT NULL
      , p_parameter5_value               IN varchar2    DEFAULT NULL
      , p_parameter6_name                IN varchar2    DEFAULT NULL
      , p_parameter6_value               IN varchar2    DEFAULT NULL
      , p_parameter7_name                IN varchar2    DEFAULT NULL
      , p_parameter7_value               IN varchar2    DEFAULT NULL
      , p_parameter8_name                IN varchar2    DEFAULT NULL
      , p_parameter8_value               IN varchar2    DEFAULT NULL
      , p_parameter9_name                IN varchar2    DEFAULT NULL
      , p_parameter9_value               IN varchar2    DEFAULT NULL
      , p_parameter10_name               IN varchar2    DEFAULT NULL
      , p_parameter10_value              IN varchar2    DEFAULT NULL
      , p_transaction_name               IN varchar2    DEFAULT NULL
      , p_apply_error_mesg               out nocopy varchar2
      , p_apply_error_num                out nocopy varchar2
      );
  PROCEDURE APPROVE_TXN (
      itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
    );
  PROCEDURE REROUTE_FUTURE_ACTION (
      p_transaction_category_id      in NUMBER
    , p_transaction_id                       in NUMBER
    , p_route_to_user                in VARCHAR2
    , p_user_status                  in VARCHAR2
    );
  PROCEDURE POST_TXN (
      itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
    );
  PROCEDURE CHK_EFFECTIVE_DATE (
      itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
    );
  PROCEDURE create_routing_history(
      p_transaction_category_id        IN NUMBER
    , p_transaction_id                 IN NUMBER
    , p_routing_category_id            IN NUMBER
    , p_pos_structure_version_id       IN NUMBER
    , p_user_action_cd                 IN VARCHAR2
    , p_approval_cd                    IN VARCHAR2
    , p_notification_date              IN DATE
    , p_comments                       IN VARCHAR2
    , p_forwarded_to_user_id           IN NUMBER
    , p_forwarded_to_role_id           IN NUMBER
    , p_forwarded_to_position_id       IN NUMBER
    , p_forwarded_to_assignment_id     IN NUMBER
    , p_forwarded_to_member_id         IN NUMBER
    , p_forwarded_by_user_id           IN NUMBER
    , p_forwarded_by_role_id           IN NUMBER
    , p_forwarded_by_position_id       IN NUMBER
    , p_forwarded_by_assignment_id     IN NUMBER
    , p_forwarded_by_member_id         IN NUMBER
    , p_routing_history_id            OUT NOCOPY NUMBER
  );
  PROCEDURE PROCESS_NOTIFICATION  (
      itemtype        in     varchar2,
      itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2
  );
  PROCEDURE PROCESS_RESPONSE  (
      itemtype        in     varchar2,
      itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2 );
  PROCEDURE CHECK_FYI  (
      itemtype        in     varchar2,
      itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2 );
  PROCEDURE CHK_FYI_RESULTS (
      itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
    );
  FUNCTION get_default_role (
    p_transaction_category_id   NUMBER
  , p_user_id                in NUMBER default FND_PROFILE.VALUE('USER_ID')
  )
  RETURN NUMBER;
  PROCEDURE chk_root_node (itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funcmode  in varchar2,
                          result       out nocopy varchar2) ;
  procedure complete_delegate_workflow(
     p_itemkey                      in varchar2,
     p_workflow_name                in varchar2 ) ;
  function get_workflow_name(p_transaction_category_id in number )
     return varchar2;
  procedure fyi_notification( document_id   in     varchar2,
                              display_type  in     varchar2,
                              document      in out nocopy varchar2,
                              document_type in out nocopy varchar2);
  PROCEDURE reject_notification( document_id   in     varchar2,
                                 display_type  in     varchar2,
                                 document      in out nocopy varchar2,
                                 document_type in out nocopy varchar2) ;
  PROCEDURE back_notification( document_id   in     varchar2,
                               display_type  in     varchar2,
                               document      in out nocopy varchar2,
                               document_type in out nocopy varchar2) ;
  PROCEDURE override_notification( document_id   in     varchar2,
                                   display_type  in     varchar2,
                                   document      in out nocopy varchar2,
                                   document_type in out nocopy varchar2) ;
  PROCEDURE apply_notification( document_id   in     varchar2,
                                display_type  in     varchar2,
                                document      in out nocopy varchar2,
                                document_type in out nocopy varchar2) ;
  PROCEDURE warning_notification( document_id   in     varchar2,
                                  display_type  in     varchar2,
                                  document      in out nocopy varchar2,
                                  document_type in out nocopy varchar2) ;
  PROCEDURE respond_notification( document_id   in     varchar2,
                                  display_type  in     varchar2,
                                  document      in out nocopy varchar2,
                                  document_type in out nocopy varchar2) ;
  PROCEDURE set_status      ( p_workflow_name   in     varchar2,
                              p_item_id         in     varchar2,
                              p_status          in     varchar2,
                              p_result          out nocopy    varchar2);
  procedure get_apply_error(p_transaction_id          in number,
			    p_transaction_category_id in number,
			    p_apply_error_mesg        out nocopy varchar2,
			    p_apply_error_num         out nocopy varchar2) ;
  procedure set_apply_error(p_transaction_id          in number,
			    p_transaction_category_id in number,
			    p_apply_error_mesg        in  varchar2,
			    p_apply_error_num         in  varchar2) ;
  FUNCTION get_requestor (
      p_transaction_category_id        IN NUMBER
    , p_transaction_id                 IN NUMBER
    )
    RETURN VARCHAR2 ;
  FUNCTION get_last_user (
      p_transaction_category_id        IN NUMBER
    , p_transaction_id                 IN NUMBER
    )
    RETURN VARCHAR2 ;
  FUNCTION get_current_owner(p_transaction_id          in number,
                           p_transaction_category_id in number,
                           p_status                  in varchar2) RETURN VARCHAR2 ;
  PROCEDURE WHICH_TXN_CAT  (
      itemtype        in     varchar2,
      itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2 );

  PROCEDURE FIND_NOTICE_TYPE  (
      itemtype        in     varchar2,
      itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2 );
function get_person_name(p_user_id       in number default null,
                         p_assignment_id in number default null) return varchar2 ;
END;

/
