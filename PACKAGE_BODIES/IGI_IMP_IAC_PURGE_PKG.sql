--------------------------------------------------------
--  DDL for Package Body IGI_IMP_IAC_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IMP_IAC_PURGE_PKG" AS
-- $Header: igiimpub.pls 120.6.12000000.1 2007/08/01 16:21:46 npandya ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiimpub.igi_imp_iac_purge_pkg.';

--===========================FND_LOG.END=====================================

PROCEDURE PURGE_IMP_DATA(ERRBUF OUT NOCOPY VARCHAR2,
                         RETCODE OUT NOCOPY NUMBER,
                         p_book_type_code IN VARCHAR2,
			 p_category_struct_id IN NUMBER,
                         p_category_id IN NUMBER,
                         p_asset_id IN NUMBER)IS

V_COUNT NUMBER;
l_message VARCHAR2(300);
l_path_name VARCHAR2(150) := g_path||'purge_imp_data';
category_count NUMBER;
asset_count    NUMBER;
BEGIN

SELECT COUNT(*)
INTO V_COUNT
FROM IGI_IMP_IAC_INTERFACE_CTRL
WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
AND TRANSFER_STATUS = 'C';

IF V_COUNT = 0 THEN

    IF p_category_id IS NOT NULL THEN
        SELECT count(*)
        INTO category_count
        FROM IGI_IMP_IAC_INTERFACE_CTRL
        WHERE BOOK_TYPE_CODE = p_book_type_code
          AND CATEGORY_ID <> p_category_id;

        IF p_asset_id IS NOT NULL THEN
            SELECT count(*)
            INTO asset_count
            FROM IGI_IMP_IAC_INTERFACE
            WHERE BOOK_TYPE_CODE = p_book_type_code
              AND CATEGORY_ID = p_category_id
              AND ASSET_ID <> p_asset_id;
        ELSE
            asset_count := 0;
        END IF;
    ELSE
        category_count := 0;
        asset_count := 0;
    END IF;

    IF category_count = 0 AND asset_count = 0 THEN

        DELETE FROM IGI_IMP_IAC_CONTROLS
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;

        DELETE FROM IGI_IMP_IAC_INTERFACE
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;

        DELETE FROM IGI_IMP_IAC_INTERFACE_CTRL
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;

        DELETE FROM IGI_IMP_IAC_INTERFACE_PY_ADD
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;

        DELETE FROM IGI_IMP_IAC_INTERMEDIATE
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;

    ELSIF category_count > 0 AND asset_count = 0 THEN

        DELETE FROM IGI_IMP_IAC_INTERFACE
        WHERE CATEGORY_ID = p_category_id;

        DELETE FROM IGI_IMP_IAC_INTERFACE_CTRL
        WHERE CATEGORY_ID = p_category_id;

        DELETE FROM IGI_IMP_IAC_INTERFACE_PY_ADD
        WHERE CATEGORY_ID = p_category_id;

        DELETE FROM IGI_IMP_IAC_INTERMEDIATE
        WHERE CATEGORY_ID = p_category_id;

    ELSE

        DELETE FROM IGI_IMP_IAC_INTERFACE
        WHERE ASSET_ID = p_asset_id;

        DELETE FROM IGI_IMP_IAC_INTERFACE_PY_ADD
        WHERE ASSET_ID = p_asset_id;

        DELETE FROM IGI_IMP_IAC_INTERMEDIATE
        WHERE ASSET_ID = p_asset_id;


    END IF;

ELSE

FND_MESSAGE.SET_NAME('IGI','IGI_IMP_IAC_ASSETS_TRF');
igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
		  p_full_path => l_path_name,
		  p_remove_from_stack => FALSE);
l_message := fnd_message.get;
errbuf := l_message;
fnd_file.put_line(fnd_file.log, errbuf);
END IF;

END;
END; -- package

/
