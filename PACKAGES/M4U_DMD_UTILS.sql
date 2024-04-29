--------------------------------------------------------
--  DDL for Package M4U_DMD_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_DMD_UTILS" AUTHID CURRENT_USER AS
/* $Header: M4UDUTLS.pls 120.1 2007/07/17 07:09:12 bsaratna noship $ */
        -- TBD: add context setting

        g_dbms_output      BOOLEAN := false;

        c_app_id           CONSTANT VARCHAR2(30) := '701';

        c_sts_ready        CONSTANT VARCHAR2(30) := 'READY';
        c_sts_in_process   CONSTANT VARCHAR2(30) := 'IN_PROCESS' ;
        c_sts_success      CONSTANT VARCHAR2(30) := 'PROCESSED_SUCCESS';
        c_sts_sent         CONSTANT VARCHAR2(30) := 'SENT';
        c_sts_delivered    CONSTANT VARCHAR2(30) := 'DELIVERED';
        c_sts_fail         CONSTANT VARCHAR2(30) := 'PROCESSED_FAIL';
        c_sts_error        CONSTANT VARCHAR2(30) := 'ERROR';


        c_type_rfcin       CONSTANT VARCHAR2(30) := 'M4U_DMD_RFCIN';
        c_type_cin         CONSTANT VARCHAR2(30) := 'M4U_DMD_CIN';
        c_type_cis         CONSTANT VARCHAR2(30) := 'M4U_DMD_CIS';
        c_type_cic         CONSTANT VARCHAR2(30) := 'M4U_DMD_CIC';
        c_type_cin_ack     CONSTANT VARCHAR2(30) := 'M4U_DMD_CIN_ACK';
        c_type_cis_ack     CONSTANT VARCHAR2(30) := 'M4U_DMD_CIS_ACK';
        c_type_cic_ack     CONSTANT VARCHAR2(30) := 'M4U_DMD_CIC_ACK';
        c_type_rfcin_ack   CONSTANT VARCHAR2(30) := 'M4U_DMD_RFCIN_ACK';
        c_type_item_ebm    CONSTANT VARCHAR2(30) := 'M4U_DMD_ITEM_EBM';
        c_type_resp_ebm    CONSTANT VARCHAR2(30) := 'M4U_DMD_RESP_EBM';

        c_dir_out          CONSTANT VARCHAR2(30) :='OUT';
        c_dir_in           CONSTANT VARCHAR2(30) :='IN';

        c_action_add       CONSTANT VARCHAR2(30) :='ADD';
        c_action_delete    CONSTANT VARCHAR2(30) :='DELETE';
        c_action_accepted  CONSTANT VARCHAR2(30) :='ACCEPTED';
        c_action_rejected  CONSTANT VARCHAR2(30) :='REJECTED';
        c_action_sync      CONSTANT VARCHAR2(30) :='SYNCHRONISED';
        c_action_review    CONSTANT VARCHAR2(30) :='REVIEW';
        c_action_new       CONSTANT VARCHAR2(30) :='NEW';
        c_action_init_load CONSTANT VARCHAR2(30) :='INITIALLOAD';
        c_action_modify    CONSTANT VARCHAR2(30) :='MODIFY';
        c_action_correct   CONSTANT VARCHAR2(30) :='CORRECTION';


        --TBD: add cin actions
        --TBD: check cic actions

        c_retry_all        CONSTANT VARCHAR2(30) := 'ALL';
        c_retry_err        CONSTANT VARCHAR2(30) := 'ERROR';
        c_retry_timeout    CONSTANT VARCHAR2(30) := 'TIME_OUT';

        c_cln_event        CONSTANT VARCHAR2(50) :=  'oracle.apps.cln.m4u.dmd.collab';
        c_payload_event    CONSTANT VARCHAR2(50) :=  'oracle.apps.cln.m4u.dmd.payload';

        c_gtin_len         CONSTANT NUMBER := 14;
        c_gln_len          CONSTANT NUMBER := 13;


        PROCEDURE handle_error
        (
                p_err_api       IN VARCHAR2,
                p_err_msg       IN VARCHAR2,
                p_sql_cod       IN VARCHAR2,
                p_sql_err       IN VARCHAR2,
                x_ret_sts       OUT NOCOPY VARCHAR2,
                x_ret_msg       OUT NOCOPY VARCHAR2
        );

        PROCEDURE log
        (
                p_stmt  IN VARCHAR2,
                p_level IN NUMBER
        );

        FUNCTION valid_gln
        (
                p_gln           IN VARCHAR2,
                p_null_allowed  IN BOOLEAN  := true
        ) RETURN BOOLEAN;


        FUNCTION valid_gtin
        (
                p_gtin          IN VARCHAR2,
                p_null_allowed  IN BOOLEAN  := true
        ) RETURN BOOLEAN;

        FUNCTION date_xml_to_db
        (
                p_datetime      IN VARCHAR2
        ) RETURN DATE;

        FUNCTION valid_type
        (
                p_param         IN VARCHAR2,
                p_value         IN VARCHAR2,
                p_null_allowed  IN BOOLEAN  := true
        ) RETURN BOOLEAN;

        FUNCTION valid_len
        (
                p_value         IN VARCHAR2,
                p_min_len       IN NUMBER,
                p_max_len       IN NUMBER,
                p_null_allowed  IN BOOLEAN  := false
        ) RETURN BOOLEAN;

        FUNCTION valid_msg_id
        (
                p_msg_id        IN VARCHAR2,
                p_null_allowed  IN BOOLEAN := true
        ) RETURN BOOLEAN;

        FUNCTION valid_orig_msg_id
        (
                p_orig_msg_id   IN VARCHAR2,
                p_null_allowed  IN BOOLEAN := true
        ) RETURN BOOLEAN;

        FUNCTION valid_orig_doc_id
        (
                p_orig_doc_id   IN VARCHAR2,
                p_null_allowed  IN BOOLEAN := true
        ) RETURN BOOLEAN;

        FUNCTION valid_payload_id
        (
                p_payload_id    IN VARCHAR2,
                p_null_allowed  IN BOOLEAN := true
        ) RETURN BOOLEAN;

        FUNCTION valid_doc_id
        (
                p_doc_id        IN VARCHAR2,
                p_null_allowed  IN BOOLEAN := true
        ) RETURN BOOLEAN;

        FUNCTION get_inv_param_msg
        (
                p_api           IN VARCHAR2,
                p_param         IN VARCHAR2,
                p_value         IN VARCHAR2
        ) RETURN VARCHAR2;

        FUNCTION get_gln_user
        (
        	p_gln		IN VARCHAR2
        ) RETURN VARCHAR2;
END m4u_dmd_utils;

/
