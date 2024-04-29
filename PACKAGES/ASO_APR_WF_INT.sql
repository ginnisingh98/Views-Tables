--------------------------------------------------------
--  DDL for Package ASO_APR_WF_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_APR_WF_INT" AUTHID CURRENT_USER AS
  /*   $Header: asoiapws.pls 120.1 2005/06/29 12:32:18 appldev noship $ */

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

  /* The following APIs are for Quoting Specific use and
     should NOT be used by any other applications */

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

END  aso_apr_wf_int;

 

/
