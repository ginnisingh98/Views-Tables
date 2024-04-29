--------------------------------------------------------
--  DDL for Package IGS_CO_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_GEN_004" AUTHID CURRENT_USER AS
/* $Header: IGSCO23S.pls 120.0 2005/06/01 16:00:45 appldev noship $ */

/*  +=======================================================================+
    |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
    |                         All rights reserved.                          |
    +=======================================================================+
    |  NAME                                                                 |
    |    IGSCO23B.pls                                                       |
    |                                                                       |
    |  DESCRIPTION                                                          |
    |    This package provides service functions and procedures to          |
    |    correspondence forms for sending test mails, resending requests    |
    |                                    and view attachments .             |
    |                                                                       |
    |  NOTES
    |  HISTORY                                                              |
    |  who      when               what
    |  ssawhney  3-may-04          IBC.C patchset changes bug 3565861 + 3442719
    +==========================================================================*/

     TYPE T_VARCHAR_100 IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
     TYPE T_VARCHAR_300 IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;
     TYPE T_VARCHAR_4000 IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
     TYPE T_NUMBER IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

 PROCEDURE resend_request
 (
     X_ROWID			      IN OUT NOCOPY VARCHAR2,
     X_STUDENT_ID			      IN     NUMBER,
     X_DOCUMENT_ID			      IN     NUMBER,
     X_DOCUMENT_TYPE		      IN     VARCHAR2,
     X_SYS_LTR_CODE		      IN     VARCHAR2,
     X_ADM_APPLICATION_NUMBER	      IN     NUMBER,
     X_NOMINATED_COURSE_CD               IN     VARCHAR2,
     X_SEQUENCE_NUMBER                   IN     NUMBER,
     X_CAL_TYPE                          IN     VARCHAR2,
     X_CI_SEQUENCE_NUMBER                IN     NUMBER,
     X_REQUESTED_DATE                    IN     DATE,
     X_DELIVERY_TYPE                     IN     VARCHAR2,
     X_OLD_REQUEST_ID		      IN     NUMBER,
     X_NEW_REQUEST_ID		      OUT    NOCOPY NUMBER,
     X_MSG_COUNT			      OUT    NOCOPY NUMBER,
     X_MSG_DATA			      OUT    NOCOPY VARCHAR2,
     X_RETURN_STATUS		      OUT    NOCOPY VARCHAR2,
     P_COMMIT			      IN     VARCHAR2 := FND_API.G_FALSE,
     X_VERSION_ID                     IN     NUMBER    -- ssawhney 3565861
 );


 PROCEDURE send_test_mail
 (
     X_MAIL_ID                        IN     VARCHAR2,
     X_SUBJECT                        IN     VARCHAR2,
     X_CRM_USER_ID                    IN     NUMBER,
     X_TEMPLATE_ID                    IN     NUMBER,
     X_VERSION_ID                     IN     NUMBER,
     X_MSG_COUNT		      OUT    NOCOPY NUMBER,
     X_MSG_DATA			      OUT    NOCOPY VARCHAR2,
     X_RETURN_STATUS		      OUT    NOCOPY VARCHAR2,
     X_REQUEST_ID                     OUT    NOCOPY NUMBER,
     P_COMMIT			      IN     VARCHAR2 := FND_API.G_FALSE
 ) ;


  PROCEDURE get_attachments
  (
     p_version_id		IN NUMBER,   -- this should pass the IBC_CITEMS_V.CITEM_VER_ID, ssawhney
     x_item_id                  OUT NOCOPY NUMBER,
     x_item_name                OUT NOCOPY VARCHAR2,
     x_version                  OUT NOCOPY NUMBER,
     x_item_description         OUT NOCOPY VARCHAR2,
     x_type_code                OUT NOCOPY VARCHAR2,
     x_type_name                OUT NOCOPY VARCHAR2,
     x_attribute_type_codes	OUT NOCOPY T_VARCHAR_100,
     x_attribute_type_names	OUT NOCOPY T_VARCHAR_300,
     x_attributes		OUT NOCOPY T_VARCHAR_4000,
     x_component_citems		OUT NOCOPY T_NUMBER,
     x_component_attrib_types	OUT NOCOPY T_VARCHAR_100,
     x_component_citem_names	OUT NOCOPY T_VARCHAR_300,
     x_component_owner_ids	OUT NOCOPY T_NUMBER,
     x_component_owner_types	OUT NOCOPY T_VARCHAR_100,
     x_component_sort_orders	OUT NOCOPY T_NUMBER,
     x_return_status		OUT NOCOPY VARCHAR2,
     x_msg_count		OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2
  );

 PROCEDURE get_list_query (
	p_file_id	IN	NUMBER,
	p_query_text    OUT NOCOPY VARCHAR2
 );


 PROCEDURE create_associations (
        p_doc_id              IN NUMBER,
        p_assoc_type_codes    IN VARCHAR2,
        p_letter_code         IN VARCHAR2,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2
	) ;

END IGS_CO_GEN_004;

 

/
