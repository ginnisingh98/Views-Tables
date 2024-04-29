--------------------------------------------------------
--  DDL for Package Body ASO_APR_WF_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_APR_WF_INT" AS
  /*   $Header: asoiapwb.pls 120.1 2005/06/29 12:32:15 appldev noship $ */


  PROCEDURE submit_approval (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) is
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.submit_approval ',1,'N');

    END IF;
     aso_apr_wf_pvt.submit_approval(itemtype,
                                 itemkey,
						   actid,
						   funcmode,
						   resultout);
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.submit_approval ',1,'N');

    END IF;

  END;


  PROCEDURE check_rejected (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.check_rejected ',1,'N');

    END IF;

  aso_apr_wf_pvt.check_rejected(itemtype,
                                 itemkey,
                                 actid,
                                 funcmode,
                                 resultout);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.check_rejected ',1,'N');

    END IF;

  END;


  PROCEDURE submit_next_batch (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS

  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.submit_next_batch ',1,'N');

    END IF;

  aso_apr_wf_pvt.submit_next_batch(itemtype,
                                 itemkey,
                                 actid,
                                 funcmode,
                                 resultout);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.submit_next_batch ',1,'N');

    END IF;

  END;




  PROCEDURE approved (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.approved ',1,'N');

    END IF;

  aso_apr_wf_pvt.approved(itemtype,
                                 itemkey,
                                 actid,
                                 funcmode,
                                 resultout);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.approved ',1,'N');

    END IF;

  END;




  PROCEDURE rejected (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.rejected ',1,'N');

    END IF;

  aso_apr_wf_pvt.rejected(itemtype,
                                 itemkey,
                                 actid,
                                 funcmode,
                                 resultout);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.rejected ',1,'N');

    END IF;

  END;


  PROCEDURE timedout (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.timedout ',1,'N');

    END IF;

  aso_apr_wf_pvt.timedout(itemtype,
                                 itemkey,
                                 actid,
                                 funcmode,
                                 resultout);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.timedout ',1,'N');

    END IF;

  END;


  PROCEDURE send_notification (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.send_notification ',1,'N');

    END IF;

  aso_apr_wf_pvt.send_notification(itemtype,
                                 itemkey,
                                 actid,
                                 funcmode,
                                 resultout);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.send_notification ',1,'N');

    END IF;


  END;

  PROCEDURE send_cancel_notification (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.send_cancel_notification ',1,'N');

    END IF;
  aso_apr_wf_pvt.send_cancel_notification(itemtype,
                                 itemkey,
                                 actid,
                                 funcmode,
                                 resultout);


    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.send_cancel_notification ',1,'N');

    END IF;

  END;

  /* The following APIs are for Quoting Specific use and
     should NOT be used by any other applications */

  PROCEDURE approver_details_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.approver_details_doc ',1,'N');

    END IF;

  aso_apr_wf_pvt.approver_details_doc(document_id,
                                 display_type,
                                 document,
                                 document_type);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.approver_details_doc ',1,'N');

    END IF;

  END;

  PROCEDURE quote_summary_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.quote_summary_doc ',1,'N');

    END IF;

  aso_apr_wf_pvt.quote_summary_doc(document_id,
                                 display_type,
                                 document,
                                 document_type);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.quote_summary_doc ',1,'N');

    END IF;

  END;

  PROCEDURE requester_comments_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.requester_comments_doc ',1,'N');

    END IF;

  aso_apr_wf_pvt.requester_comments_doc(document_id,
                                 display_type,
                                 document,
                                 document_type);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.requester_comments_doc ',1,'N');

    END IF;

  END;

  PROCEDURE rule_details_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.rule_details_doc ',1,'N');

    END IF;

  aso_apr_wf_pvt.rule_details_doc(document_id,
                                 display_type,
                                 document,
                                 document_type);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.rule_details_doc ',1,'N');

    END IF;

  END;

  PROCEDURE quote_detail_url (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.quote_detail_url ',1,'N');

    END IF;

  aso_apr_wf_pvt.quote_detail_url(document_id,
                                 display_type,
                                 document,
                                 document_type);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.quote_detail_url ',1,'N');

    END IF;


  END;

  PROCEDURE set_attributes (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.set_attributes ',1,'N');

    END IF;

  aso_apr_wf_pvt. set_attributes(itemtype,
                                 itemkey,
                                 actid,
                                 funcmode,
                                 resultout);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.set_attributes ',1,'N');

    END IF;


  END;

  PROCEDURE update_entity (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
   ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Before calling aso_apr_wf_pvt.update_entity ',1,'N');

    END IF;

  aso_apr_wf_pvt.update_entity(itemtype,
                                 itemkey,
                                 actid,
                                 funcmode,
                                 resultout);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('After calling aso_apr_wf_pvt.update_entity ',1,'N');

    END IF;

  END;

END  aso_apr_wf_int;

/
