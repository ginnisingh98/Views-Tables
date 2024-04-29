--------------------------------------------------------
--  DDL for Package Body AR_CLE_STUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CLE_STUB_PKG" 
-- $Header: ARCLESTUBB.pls 120.1.12010000.2 2008/09/17 14:08:11 tthangav ship $
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--   Source control header
--
-- PROGRAM NAME
--  ARCLESTUBB.pls
--
-- DESCRIPTION
--  This script creates the package body of AR_CLE_STUB_PKG
--  This checks where the localization program exists or not and to submit the localization program if exists.
--
-- USAGE
--   To install       sqlplus <apps_user>/<apps_pwd> @ARCLESTUBB.pls
--   To execute       sqlplus <apps_user>/<apps_pwd> AR_CLE_STUB_PKG
--
-- PROGRAM LIST                DESCRIPTION
-- localization_prog_exists    It is a function of AR_CLE_STUB_PKG package.
--                             This checks where the localization program exists or not.
-- submit_prog                 It is a procedure of AR_CLE_STUB_PKG package.
--                             This is used to submit the localization program if exists.
--
-- DEPENDENCIES
--   None
--
-- CALLED BY
--   Statement Generation Program.
--
-- LAST UPDATE DATE   24-Jun-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- ------------------------------------
-- Draft1A 02-Feb-2007 Sajana Doma     Initial Creation
--         11-Apr-2007 TTHANGAV        Modified localization_prog_exists to return
--                                     true only for EMEA Countries
--************************************************************************
AS
   FUNCTION localization_prog_exists RETURN BOOLEAN
   IS
   lb_prog_exists BOOLEAN;
   lv_def_country VARCHAR2(200);
   ln_count NUMBER;
   BEGIN
     select default_country into lv_def_country from AR_SYSTEM_PARAMETERS;

     SELECT count(*) INTO ln_count
     FROM   ar_lookups
     WHERE  lookup_type = 'AR_EMEA_COUNTRIES'
     AND    lookup_code = lv_def_country
     AND    enabled_flag = 'Y'
     AND    SYSDATE BETWEEN start_date_active AND NVL(end_date_active,SYSDATE);

     IF (ln_count > 0) THEN
        RETURN(TRUE);
     ELSE
        RETURN(FALSE);
     END IF;
   END;

   PROCEDURE submit_prog
   IS
      ln_request_id    NUMBER;
      lb_layout        BOOLEAN;
      lc_phase         VARCHAR2(50);
      lc_status        VARCHAR2(50);
      lc_dev_phase     VARCHAR2(50);
      lc_dev_status    VARCHAR2(50);
      lc_message       VARCHAR2(100);
      lb_wait          BOOLEAN;
   BEGIN

      lb_layout :=  FND_REQUEST.ADD_LAYOUT
	                        ('CLE',
							 'CLE_F_ARCUSBALSL',
							 'en',
							 'US',
							 'PDF');
      IF lb_layout THEN
         ln_request_id := FND_REQUEST.SUBMIT_REQUEST
                            ('AR',
                             'ARCUSBALSL',
                             'AR Customer Balance Statement Letter',
                              NULL,
                              FALSE,'','','',
                              '', '', '', '', '', '', '',
                              '', '', '', '', '', '', '', '', '', '',
                              '', '', '', '', '', '', '', '', '', '',
                              '', '', '', '', '', '', '', '', '', '',
                              '', '', '', '', '', '', '', '', '', '',
                              '', '', '', '', '', '', '', '', '', '',
                              '', '', '', '', '', '', '', '', '', '',
                              '', '', '', '', '', '', '', '', '', '',
                              '', '', '', '', '', '', '', '', '', '',
                              '', '', '', '', '', '', '', '', '', '');

         COMMIT;

         lb_wait:= FND_CONCURRENT.WAIT_FOR_REQUEST
                    (ln_request_id,
                     60,
                     0,
                     lc_phase,
                     lc_status,
                     lc_dev_phase,
                     lc_dev_status,
                     lc_message);
         COMMIT;

	  END IF;

   END;

END AR_CLE_STUB_PKG;

/
