--------------------------------------------------------
--  DDL for Package ASO_APR_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_APR_WF_PVT" AUTHID CURRENT_USER AS
  /*   $Header: asovwaps.pls 120.2.12010000.4 2016/01/14 21:37:18 vidsrini ship $ */
  TYPE aso_attribute_label_tbl_type IS TABLE OF VARCHAR2 (80);

  PROCEDURE start_aso_approvals (
    P_Object_approval_id  IN  NUMBER,
    P_itemtype_name       IN  VARCHAR2,
    P_sender_name         IN  VARCHAR2
   );

  PROCEDURE submit_approval (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE check_rejected (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE submit_next_batch (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE approved (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE rejected (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE timedout (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE cancelapproval (
    approval_id                 IN       NUMBER,
    p_itemtype                  IN       VARCHAR2,
    p_user_id                   IN       NUMBER
  );

  PROCEDURE send_notification (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE send_cancel_notification (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE update_approver_list (
    p_object_approval_id        IN       NUMBER
  );

  PROCEDURE last_approver_timeout_check (
    p_object_approval_id        IN       NUMBER
  );

  PROCEDURE approver_details_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE quote_summary_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE requester_comments_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE rule_details_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE quote_detail_url (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE get_attribute_label (
    p_approval_id               IN       NUMBER,
    p_attribute_tbl             OUT NOCOPY /* file.sql.39 change */       aso_attribute_label_tbl_type
  );

 FUNCTION GetRunFuncURL
 (
    p_function_name     IN     VARCHAR2
  , p_resp_appl_id      IN     NUMBER    DEFAULT NULL
  , p_resp_id           IN     NUMBER    DEFAULT NULL
  , p_security_group_id IN     NUMBER    DEFAULT NULL
  , p_parameters        IN     VARCHAR2  DEFAULT NULL
 ) RETURN VARCHAR2;

  PROCEDURE set_attributes (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE update_entity (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE update_approval_status (
    p_update_header_or_detail_flag IN     VARCHAR2,
    p_object_approval_id           IN      NUMBER,
    p_approval_det_id              IN       NUMBER,
    p_status                         IN       VARCHAR2,
    note                           IN       VARCHAR2
  );

-- Start : Code change done for Bug 18288445
PROCEDURE EscapeString
(p_str IN OUT NOCOPY VARCHAR2);
-- End : Code change done for Bug 18288445

Function Get_Formatted_number (l_currency_code IN varchar2, l_number_to_format IN Number)
    Return varchar2;
Function Show_Margin_Check return varchar2;

Procedure get_quote_total(
                   p_quote_header_id number,
     	       p_user_id         number,
     	       xquote_total   IN OUT NOCOPY /* file.sql.39 change */   varchar2);


END aso_apr_wf_pvt;

/
