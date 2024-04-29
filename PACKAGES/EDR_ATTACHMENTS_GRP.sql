--------------------------------------------------------
--  DDL for Package EDR_ATTACHMENTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_ATTACHMENTS_GRP" AUTHID CURRENT_USER AS
/*  $Header: EDRGATCS.pls 120.2.12000000.1 2007/01/18 05:53:21 appldev ship $ */

-- Bug 4381237: Start

PROCEDURE copy_attachments(X_from_entity_name IN VARCHAR2,
			X_from_pk1_value IN VARCHAR2,
			X_from_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk5_value IN VARCHAR2 DEFAULT NULL,
			X_to_entity_name IN VARCHAR2,
			X_to_pk1_value IN VARCHAR2,
			X_to_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk5_value IN VARCHAR2 DEFAULT NULL,
			X_created_by IN NUMBER DEFAULT NULL,
			X_last_update_login IN NUMBER DEFAULT NULL,
			X_program_application_id IN NUMBER DEFAULT NULL,
			X_program_id IN NUMBER DEFAULT NULL,
			X_request_id IN NUMBER DEFAULT NULL,
			X_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
			X_from_category_id IN NUMBER DEFAULT NULL,
			X_to_category_id IN NUMBER DEFAULT NULL);

PROCEDURE copy_one_attachment(X_from_entity_name IN VARCHAR2,
			X_from_pk1_value IN VARCHAR2,
			X_from_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk5_value IN VARCHAR2 DEFAULT NULL,
			X_to_entity_name IN VARCHAR2,
			X_to_pk1_value IN VARCHAR2,
			X_to_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk5_value IN VARCHAR2 DEFAULT NULL,
			X_document_id IN NUMBER,
			X_created_by IN NUMBER DEFAULT NULL,
			X_last_update_login IN NUMBER DEFAULT NULL,
			X_program_application_id IN NUMBER DEFAULT NULL,
			X_program_id IN NUMBER DEFAULT NULL,
			X_request_id IN NUMBER DEFAULT NULL,
			X_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
			X_from_category_id IN NUMBER DEFAULT NULL,
			X_to_category_id IN NUMBER DEFAULT NULL);

-- Bug 4381237: End

--Bug 3893101: Start
--Create new record type to store attachment details
TYPE ERES_ATTACHMENT_REC_TYPE IS RECORD
(         ENTITY_NAME   VARCHAR2(240),
			    PK1_VALUE     VARCHAR2(100),
			    PK2_VALUE     VARCHAR2(100),
			    PK3_VALUE     VARCHAR2(100),
			    PK4_VALUE     VARCHAR2(100),
			    PK5_VALUE     VARCHAR2(100),
			    CATEGORY      VARCHAR2(100)
);

--This would be a table of the above record type.

TYPE ERES_ATTACHMENT_TBL_TYPE IS TABLE OF ERES_ATTACHMENT_REC_TYPE INDEX BY BINARY_INTEGER;

--Bug 3893101: End


PROCEDURE ATTACH_ERP_AUT( p_entity_name VARCHAR2,
			        p_pk1_value VARCHAR2,
			        p_pk2_value VARCHAR2,
			        p_pk3_value VARCHAR2,
			        p_pk4_value VARCHAR2,
			        p_pk5_value VARCHAR2,
				  p_category VARCHAR2,
                          p_target_value VARCHAR2
			      );

PROCEDURE ATTACH_ERP (p_entity_name VARCHAR2,
			    p_pk1_value VARCHAR2,
			    p_pk2_value VARCHAR2,
			    p_pk3_value VARCHAR2,
			    p_pk4_value VARCHAR2,
			    p_pk5_value VARCHAR2,
			    p_category VARCHAR2
			   );



PROCEDURE EVENT_POST_OP(p_file_id VARCHAR2);

PROCEDURE GET_CATEGORY_NAME (P_CATEGORY_NAME IN VARCHAR2,
				     P_DISPLAY_NAME in out nocopy VARCHAR2);

PROCEDURE GET_DESC_FLEX_ALL_PROMPTS(P_APPLICATION_ID IN VARCHAR2,
						P_DESC_FLEX_DEF_NAME IN  VARCHAR2,
						P_DESC_FLEX_CONTEXT IN VARCHAR2,
						P_PROMPT_TYPE IN VARCHAR2,
						P_COLUMN1_NAME IN VARCHAR2,
						P_COLUMN2_NAME IN VARCHAR2,
						P_COLUMN3_NAME IN VARCHAR2,
						P_COLUMN4_NAME IN VARCHAR2,
						P_COLUMN5_NAME IN VARCHAR2,
						P_COLUMN6_NAME IN VARCHAR2,
						P_COLUMN7_NAME IN VARCHAR2,
						P_COLUMN8_NAME IN VARCHAR2,
						P_COLUMN9_NAME IN VARCHAR2,
						P_COLUMN10_NAME IN VARCHAR2,
						P_COLUMN1_PROMPT out nocopy VARCHAR2,
						P_COLUMN2_PROMPT out nocopy VARCHAR2,
						P_COLUMN3_PROMPT out nocopy VARCHAR2,
						P_COLUMN4_PROMPT out nocopy VARCHAR2,
						P_COLUMN5_PROMPT out nocopy VARCHAR2,
						P_COLUMN6_PROMPT out nocopy VARCHAR2,
						P_COLUMN7_PROMPT out nocopy VARCHAR2,
						P_COLUMN8_PROMPT out nocopy VARCHAR2,
						P_COLUMN9_PROMPT out nocopy VARCHAR2,
						P_COLUMN10_PROMPT out nocopy VARCHAR2);

-- Bug 4501520 :rvsingh :start
PROCEDURE GET_DESC_FLEX_ALL_VALUES(P_APPLICATION_ID IN VARCHAR2,
						P_DESC_FLEX_DEF_NAME IN  VARCHAR2,
						P_DESC_FLEX_CONTEXT IN VARCHAR2,
						P_COLUMN1_NAME IN VARCHAR2,
						P_COLUMN2_NAME IN VARCHAR2,
						P_COLUMN3_NAME IN VARCHAR2,
						P_COLUMN4_NAME IN VARCHAR2,
						P_COLUMN5_NAME IN VARCHAR2,
						P_COLUMN6_NAME IN VARCHAR2,
						P_COLUMN7_NAME IN VARCHAR2,
						P_COLUMN8_NAME IN VARCHAR2,
						P_COLUMN9_NAME IN VARCHAR2,
						P_COLUMN10_NAME IN VARCHAR2,
						P_COLUMN1_ID_VAL  IN VARCHAR2,
						P_COLUMN2_ID_VAL IN VARCHAR2,
						P_COLUMN3_ID_VAL IN VARCHAR2,
						P_COLUMN4_ID_VAL IN VARCHAR2,
						P_COLUMN5_ID_VAL IN VARCHAR2,
						P_COLUMN6_ID_VAL IN VARCHAR2,
						P_COLUMN7_ID_VAL IN VARCHAR2,
						P_COLUMN8_ID_VAL IN VARCHAR2,
						P_COLUMN9_ID_VAL IN VARCHAR2,
						P_COLUMN10_ID_VAL IN VARCHAR2,
						P_COLUMN1_VAL out nocopy VARCHAR2,
						P_COLUMN2_VAL out nocopy VARCHAR2,
						P_COLUMN3_VAL out nocopy VARCHAR2,
						P_COLUMN4_VAL out nocopy VARCHAR2,
						P_COLUMN5_VAL out nocopy VARCHAR2,
						P_COLUMN6_VAL out nocopy VARCHAR2,
						P_COLUMN7_VAL out nocopy VARCHAR2,
						P_COLUMN8_VAL out nocopy VARCHAR2,
						P_COLUMN9_VAL out nocopy VARCHAR2,
						P_COLUMN10_VAL out nocopy VARCHAR2);

-- Bug 4501520 :rvsingh :end

PROCEDURE ATTACH_FILE (p_document_id VARCHAR2);

PROCEDURE ATTACH_FILE_AUT (p_document_id in VARCHAR2, p_target_value in VARCHAR2);

--Bug 3893101: Start
--This function would parse a given attachment String.
FUNCTION PARSE_ATTACHMENT_STRING(P_ATTACHMENT_STRING IN VARCHAR2)
RETURN ERES_ATTACHMENT_TBL_TYPE;

--This function would take an attachment String and create the
--attachment as per the attribute values defined.
PROCEDURE ADD_ERP_ATTACH(P_ATTACHMENT_STRING IN VARCHAR2);

--Bug 3893101: End

END EDR_ATTACHMENTS_GRP;

 

/
