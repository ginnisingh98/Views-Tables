--------------------------------------------------------
--  DDL for Package IGS_AS_DOCUMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_DOCUMENTS_API" AUTHID CURRENT_USER AS
/* $Header: IGSAS42S.pls 115.2 2002/11/28 22:49:53 nsidana noship $ */

  /*******************************************************************************
  Created by   : rbezawad
  Date created : 18-Jan-2002
  Purpose      : This procedure updates the order status and the items status of the order.

  Known limitations/enhancements/remarks:

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What

  *******************************************************************************/
  PROCEDURE update_order_item_status (
    errbuf   OUT NOCOPY VARCHAR2,
    retcode  OUT NOCOPY NUMBER);


  /*******************************************************************************
    Created by   : rbezawad
    Date created : 21-Jan-2002
    Purpose      : This procedure updates Transcipt's Order, Item Statuses to INPROCESS.
                   And also inserts the Transcripts Request record into Interface table.

    Known limitations/enhancements/remarks:

    Change History: (who, when, what: NO CREATION RECORDS HERE!)
    Who             When            What

  *******************************************************************************/
  PROCEDURE update_document_details (
    p_order_number IN NUMBER,
    p_item_number IN NUMBER,
    p_init_msg_list IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
    p_return_status OUT NOCOPY VARCHAR2,
    p_msg_count     OUT NOCOPY NUMBER,
    p_msg_data      OUT NOCOPY VARCHAR2,
    P_PERSON_ID                 IN   VARCHAR2 DEFAULT NULL,
    P_FEE_AMT                   IN   NUMBER DEFAULT NULL,
    P_RECORDED_BY               IN   NUMBER DEFAULT NULL,
    P_PLAN_ID                   IN   NUMBER DEFAULT NULL,
    P_INVOICE_ID                IN   NUMBER DEFAULT NULL,
    P_PLAN_CAL_TYPE             IN   VARCHAR2 DEFAULT NULL,
    P_PLAN_CI_SEQUENCE_NUMBER   IN   NUMBER DEFAULT NULL

    );

    procedure upd_doc_fee_pmnt(
	p_person_id NUMBER,
	p_plan_id  NUMBER,
	p_num_copies NUMBER,
	p_program_on_file VARCHAR2,
	p_operation VARCHAR2
) ;

END igs_as_documents_api;

 

/
