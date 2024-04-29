--------------------------------------------------------
--  DDL for Package IGS_AS_PROD_DOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_PROD_DOC" AUTHID CURRENT_USER AS
/* $Header: IGSAS49S.pls 120.1 2005/09/19 01:34:17 appldev ship $ */

  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 21-Aug-2002
  Purpose : This process is called by the report producing the documents
            to check the readiness for production of a document.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  swaghmar	  14-Sep-2005	  Bug 4506526, added new functions get_doc_fee and get_del_fee
  ijeddy          15-feb-2004     Bug 3410409, added a new function get_hold_status
  (reverse chronological order - newest change first)
  ***************************************************************/
  --
  FUNCTION get_hold_status (
     p_person_id NUMBER
  ) RETURN VARCHAR2;

 --
  PROCEDURE asp_chk_doc_rdns (
    p_item_number                       IN   NUMBER,
    p_document_ready                    OUT NOCOPY VARCHAR2,
    p_error_mesg                        OUT NOCOPY VARCHAR2
  );
  --
  PROCEDURE notify_miss_acad_rec_prod (
    p_person_id                         IN     VARCHAR2,
    p_order_number                      IN     VARCHAR2,
    p_item_number                       IN     VARCHAR2,
    p_document_type                     IN     VARCHAR2,
    p_recipient_name                    IN     VARCHAR2,
    p_receiving_inst_name               IN     VARCHAR2,
    p_delivery_method                   IN     VARCHAR2,
    p_fulfillment_date_time             IN     VARCHAR2
  );
  --
  PROCEDURE wf_launch_as004 (
    p_user                              IN VARCHAR2,
    p_date_produced                     IN VARCHAR2,
    p_doc_type                          IN VARCHAR2
  ) ;
  --
  PROCEDURE wf_set_role (
    itemtype                            IN  VARCHAR2,
    itemkey                             IN  VARCHAR2,
    actid	                        IN  NUMBER,
    funcmode                            IN  VARCHAR2,
    resultout                           OUT NOCOPY VARCHAR2
  );
  --
  PROCEDURE asp_update_order_doc (
    p_item_number                       IN NUMBER,
    p_test_mode                         IN VARCHAR2
  );
  --
  FUNCTION get_doc_fee(
    p_order_number igs_as_doc_details.order_number%TYPE
  ) RETURN NUMBER ;
  --
  FUNCTION get_del_fee (
    p_order_number igs_as_doc_details.order_number%TYPE
  ) RETURN NUMBER;
  --
END igs_as_prod_doc;

 

/
