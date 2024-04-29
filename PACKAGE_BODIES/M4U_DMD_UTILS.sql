--------------------------------------------------------
--  DDL for Package Body M4U_DMD_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_DMD_UTILS" AS
/* $Header: M4UDUTLB.pls 120.1 2007/07/17 07:08:31 bsaratna noship $ */

    PROCEDURE handle_error(
                p_err_api       IN VARCHAR2,
                p_err_msg       IN VARCHAR2,
                p_sql_cod       IN VARCHAR2,
                p_sql_err       IN VARCHAR2,
                x_ret_sts       OUT NOCOPY VARCHAR2,
                x_ret_msg       OUT NOCOPY VARCHAR2)
    IS
    BEGIN

        log('Error api/msg - ' || p_err_api || '/' || p_err_msg,6);
        log('Error cod/err - ' || p_sql_cod || '/' || p_sql_err,6);

        IF p_err_msg IS NOT NULL THEN
                x_ret_msg := substr(p_err_msg,1,400);
        ELSE
                fnd_message.set_name('CLN','M4U_DMD_API_FAIL');
                fnd_message.set_name('API' ,nvl(p_err_api,'M4U'));
                fnd_message.set_name('ERRM',substr(p_sql_cod || '-' || p_sql_err,1,400));
                x_ret_msg := fnd_message.get;
        END IF;

        x_ret_sts := fnd_api.g_ret_sts_error;
        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
                x_ret_sts := fnd_api.g_ret_sts_error;
                x_ret_msg := 'Unexpected error - ' || p_err_api;
                RETURN;
    END handle_error;

    PROCEDURE log
    (
        p_stmt  IN VARCHAR2,
        p_level IN NUMBER
    )
    AS
    BEGIN
        -- TBD: replace with fnd api
        -- TBD: check module log level
        -- cln_debug_pub.add(substr(p_log_stmt,1,255),1);
        IF p_level <= 6 THEN
                cln_debug_pub.add(p_stmt,6);
        END IF;

        IF p_level >=  fnd_log.g_current_runtime_level THEN
                fnd_log.string
                (
                        log_level => p_level,
                        module    => 'CLN.M4UD.PLSQL.',
                        message   => p_stmt
                );
                cln_debug_pub.add(p_stmt,p_level);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
                null; -- gobble exception
    END log;

    FUNCTION valid_gln
    (
        p_gln           IN VARCHAR2,
        p_null_allowed  IN BOOLEAN := true
    )
    RETURN BOOLEAN IS
        len1 NUMBER;
        len2 NUMBER;
        tmp  NUMBER;
    BEGIN
        IF p_gln IS NULL and p_null_allowed THEN
                RETURN true;
        ELSE
                len1 := length(p_gln);
                len2 := length(translate(p_gln,'0123456789.^+-','0123456789'));
                tmp := to_number(p_gln);
                IF len1 = len2 AND len1 = c_gln_len THEN
                        RETURN true;
                END IF;
        END IF;

        RETURN false;

    EXCEPTION
        WHEN OTHERS THEN
                RETURN false;
    END;

    FUNCTION valid_gtin
    (
        p_gtin          IN VARCHAR2,
        p_null_allowed  IN BOOLEAN := true
    )
    RETURN BOOLEAN IS
        len1 NUMBER;
        len2 NUMBER;
        tmp  NUMBER;
    BEGIN
        IF p_gtin IS NULL and p_null_allowed THEN
                RETURN true;
        ELSE
                len1 := length(p_gtin);
                len2 := length(translate(p_gtin,'0123456789.+-^','0123456789'));
                tmp := to_number(p_gtin);
                IF len1 = len2 AND len1 = c_gtin_len THEN
                        RETURN true;
                END IF;
        END IF;

        RETURN false;

    EXCEPTION
        WHEN OTHERS THEN
                RETURN false;
    END valid_gtin;

    FUNCTION date_xml_to_db
    (
        p_datetime   IN    VARCHAR2
    ) RETURN DATE
    AS
    BEGIN
        RETURN to_date(translate(p_datetime,'0123456789T:-','0123456789'),'YYYYMMDDHH24MISS');
    EXCEPTION
        WHEN OTHERS THEN
                RAISE;
    END date_xml_to_db;

    FUNCTION valid_type
    (
        p_param         IN VARCHAR2,
        p_value         IN VARCHAR2,
        p_null_allowed  IN BOOLEAN  := true
    ) RETURN BOOLEAN
    AS
    BEGIN
        IF p_null_allowed AND p_value IS NULL THEN
                RETURN true;
        END IF;

        IF p_param = 'DOC_STATUS' AND
           p_value IN (c_sts_ready,c_sts_in_process,c_sts_sent,c_sts_success,
           c_sts_fail,c_sts_error )THEN
           RETURN true;
        END IF;

        IF p_param = 'MSG_STATUS' AND
           p_value IN (c_sts_ready,c_sts_sent,c_sts_in_process,c_sts_success,
           c_sts_fail,c_sts_error )THEN
           RETURN true;
        END IF;

        IF p_param = 'PAYLOAD_TYPE' AND
           p_value IN (c_type_cin,c_type_rfcin,c_type_cic,c_type_cis,
           c_type_cin_ack,c_type_cis_ack,c_type_cic_ack,c_type_rfcin_ack,
           c_type_item_ebm,c_type_resp_ebm)THEN
           RETURN true;
        END IF;

        IF p_param = 'DOC_TYPE' AND
           p_value IN (c_type_cin,c_type_rfcin,
           c_type_cic,c_type_cis)THEN
           RETURN true;
        END IF;

        IF p_param = 'MSG_TYPE' AND
           p_value IN (c_type_cin,c_type_cin_ack,c_type_rfcin,
           c_type_cic,c_type_cis)THEN
           RETURN true;
        END IF;

        IF p_param = 'ACTION' AND
           p_value IN (c_action_add,c_action_delete,c_action_accepted,
           c_action_rejected,c_action_sync,c_action_review,
           c_action_new,c_action_init_load,c_action_modify,
           c_action_correct)THEN
           RETURN true;
        END IF;

        IF p_param = 'DIRECTION' AND
           p_value IN (c_dir_out,c_dir_in)THEN
           RETURN true;
        END IF;

        IF p_param = 'RETRY_MODE' AND
           p_value IN (c_retry_all,c_retry_err,c_retry_timeout)THEN
           RETURN true;
        END IF;

        RETURN false;

    END valid_type;

    FUNCTION valid_len
    (
        p_value         IN VARCHAR2,
        p_min_len       IN NUMBER,
        p_max_len       IN NUMBER,
        p_null_allowed  IN BOOLEAN := false
    ) RETURN BOOLEAN
    AS
    BEGIN
        IF p_null_allowed AND p_value IS NULL THEN
                RETURN true;
        ELSIF length(p_value) >= p_min_len AND
              length(p_value) <= p_max_len THEN
                RETURN true;
        END IF;
        RETURN false;
    EXCEPTION
        WHEN OTHERS THEN
                RETURN false;
    END valid_len;

    FUNCTION valid_payload_id
    (
        p_payload_id    IN VARCHAR2,
        p_null_allowed  IN BOOLEAN := true
    ) RETURN BOOLEAN
    AS
        l_count NUMBER;
    BEGIN
        IF p_null_allowed AND p_payload_id IS NULL THEN
                RETURN true;
        END IF;

        SELECT  count(*)
        INTO    l_count
        FROM    m4u_dmd_payloads
          WHERE payload_id = p_payload_id;

        IF l_count = 1 THEN
                RETURN true;
        END IF;
        RETURN false;
    EXCEPTION
        WHEN OTHERS THEN
                RETURN false;
    END valid_payload_id;

    FUNCTION valid_doc_id
    (
        p_doc_id        IN VARCHAR2,
        p_null_allowed  IN BOOLEAN := true
    ) RETURN BOOLEAN
    AS
        l_count NUMBER;
    BEGIN
        IF p_null_allowed AND p_doc_id IS NULL THEN
                RETURN true;
        END IF;

        SELECT  count(*)
        INTO    l_count
        FROM    m4u_dmd_documents
          WHERE doc_id = p_doc_id;

        IF l_count = 1 THEN
                RETURN true;
        END IF;
        RETURN false;
    EXCEPTION
        WHEN OTHERS THEN
                RETURN false;
    END valid_doc_id;

    FUNCTION valid_msg_id
    (
        p_msg_id        IN VARCHAR2,
        p_null_allowed  IN BOOLEAN := true
    ) RETURN BOOLEAN
    AS
        l_count NUMBER;
    BEGIN
        IF p_null_allowed AND p_msg_id IS NULL THEN
                RETURN true;
        END IF;

        SELECT  count(*)
        INTO    l_count
        FROM    m4u_dmd_messages
          WHERE msg_id = p_msg_id;

        IF l_count = 1 THEN
                RETURN true;
        END IF;
        RETURN false;
    EXCEPTION
        WHEN OTHERS THEN
                RETURN false;
    END valid_msg_id;

    FUNCTION valid_orig_doc_id
    (
        p_orig_doc_id   IN VARCHAR2,
        p_null_allowed  IN BOOLEAN := true
    ) RETURN BOOLEAN
    AS
        l_count NUMBER;
    BEGIN
        IF p_null_allowed AND p_orig_doc_id IS NULL THEN
                RETURN true;
        END IF;

        SELECT  count(*)
        INTO    l_count
        FROM    m4u_dmd_documents
          WHERE orig_doc_id = p_orig_doc_id;

        IF l_count = 1 THEN
                RETURN true;
        END IF;
        RETURN false;
    EXCEPTION
        WHEN OTHERS THEN
                RETURN false;
    END valid_orig_doc_id;

    FUNCTION valid_orig_msg_id
    (
        p_orig_msg_id   IN VARCHAR2,
        p_null_allowed  IN BOOLEAN := true
    ) RETURN BOOLEAN
    AS
        l_count NUMBER;
    BEGIN
        IF p_null_allowed AND p_orig_msg_id IS NULL THEN
                RETURN true;
        END IF;

        SELECT  count(*)
        INTO    l_count
        FROM    m4u_dmd_messages
          WHERE orig_msg_id = p_orig_msg_id;

        IF l_count = 1 THEN
                RETURN true;
        END IF;
        RETURN false;
    EXCEPTION
        WHEN OTHERS THEN
                RETURN false;
    END valid_orig_msg_id;


    FUNCTION get_inv_param_msg
    (
        p_api           IN VARCHAR2,
        p_param         IN VARCHAR2,
        p_value         IN VARCHAR2
    ) RETURN VARCHAR2
    AS
    BEGIN

        log('Validation failure in api -|' || p_api   || '|',6);
        log('                    param -|' || p_param || '|',6);
        log('                    value -|' || p_value || '|',6);


        fnd_message.set_name ('CLN',  'M4U_DMD_INV_PARAM_VALUE');
        fnd_message.set_token('API'   ,nvl(p_api,'M4U'));
        fnd_message.set_token('PARAM' ,nvl(p_param,'UNKNOWN'));
        fnd_message.set_token('VALUE' ,nvl(p_value,'null'));
        RETURN fnd_message.get;

    EXCEPTION
        WHEN OTHERS THEN
                RETURN 'Invalid input for - ' || p_param;
    END get_inv_param_msg;

    FUNCTION get_gln_user
    (
        p_gln           IN VARCHAR2
    ) RETURN VARCHAR2
    AS
        l_user_id VARCHAR2(100);
    BEGIN
                SELECT meaning
                INTO   l_user_id
                FROM   fnd_lookup_values
                WHERE  lookup_type = 'M4U_USER_GLNS'
                   AND language    = userenv('lang')
                   AND lookup_code = p_gln;

                RETURN l_user_id;
    EXCEPTION
        WHEN OTHERS THEN
                --RAISE;
                RETURN p_gln;
    END get_gln_user;

END m4u_dmd_utils;

/
