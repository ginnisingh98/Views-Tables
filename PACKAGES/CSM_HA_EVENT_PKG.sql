--------------------------------------------------------
--  DDL for Package CSM_HA_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_HA_EVENT_PKG" AUTHID CURRENT_USER  AS
/* $Header: csmehas.pls 120.0.12010000.2 2010/04/16 08:44:56 saradhak noship $*/

G_HA_SESSION_SEQUENCE NUMBER := NULL;
G_HA_START_TIME TIMESTAMP;
G_HA_PAYLOAD_SEQUENCE_START NUMBER;

G_HA_END_TIME  TIMESTAMP;
G_HA_PAYLOAD_SEQUENCE_END NUMBER;
G_CURRENT_PAYLOAD_ID NUMBER;

PROCEDURE BEGIN_HA_TRACKING(x_RETURN_STATUS OUT NOCOPY VARCHAR2,
                            x_ERROR_MESSAGE OUT NOCOPY VARCHAR2);

PROCEDURE END_HA_TRACKING(x_RETURN_STATUS OUT NOCOPY VARCHAR2,
                          x_ERROR_MESSAGE OUT NOCOPY VARCHAR2);

PROCEDURE SAVE_SEQUENCE(p_session_id   IN NUMBER, p_action IN VARCHAR2,
                        p_payload_start IN NUMBER DEFAULT NULL,p_payload_end IN NUMBER DEFAULT NULL);

PROCEDURE GET_XML_PAYLOAD(p_TABLE_NAME    IN VARCHAR2,
                          p_PK_NAME_LIST  IN  CSM_VARCHAR_LIST,
                          p_PK_TYPE_LIST  IN  CSM_VARCHAR_LIST,
                          p_PK_CHAR_LIST  IN  CSM_VARCHAR_LIST,
                          x_XML_PAYLOAD   OUT NOCOPY CLOB,
                          x_XML_CONTEXT   OUT NOCOPY CLOB,
                          x_RETURN_STATUS OUT NOCOPY VARCHAR2,
                          x_ERROR_MESSAGE OUT NOCOPY VARCHAR2);

PROCEDURE TRACK_HA_RECORD(p_TABLE_NAME VARCHAR2,p_PK_NAME_LIST CSM_VARCHAR_LIST, p_PK_TYPE_LIST CSM_VARCHAR_LIST,p_PK_VALUE_LIST CSM_VARCHAR_LIST,
                          p_dml_type VARCHAR2,p_mobile_data VARCHAR2:='N',p_parent_payload_id IN NUMBER:=NULL);

PROCEDURE TRACK_HA_ATTACHMENTS;

FUNCTION get_pk_column_name(p_object_name IN VARCHAR2) return VARCHAR2;

FUNCTION GET_HA_PROFILE_VALUE return VARCHAR2;

FUNCTION get_predicate_clause(p_cols IN VARCHAR2,p_values IN VARCHAR2) return VARCHAR2;

FUNCTION get_listfrom_String(p_object_name IN VARCHAR2) return CSM_VARCHAR_LIST;

END CSM_HA_EVENT_PKG; -- Package spec

/
