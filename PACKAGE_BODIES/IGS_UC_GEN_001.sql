--------------------------------------------------------
--  DDL for Package Body IGS_UC_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_GEN_001" AS
/* $Header: IGSUC01B.pls 120.3 2006/08/21 03:51:26 jbaber noship $ */


PROCEDURE cvname_references(p_type        IN  VARCHAR2,
                            p_appno       IN  NUMBER,
			    p_surname     IN  VARCHAR2,
			    p_birthdate   IN  DATE,
			    p_system_code IN  igs_uc_ucas_control.system_code%TYPE,
			    l_result      OUT NOCOPY igs_uc_gen_001.cur_step_def) IS

  /******************************************************************
   Created By      : pmarada
   Date Created By :
   Purpose         : This procedure returns the cursor values to the IGSUC009 pld.

   Known limitations,enhancements,remarks:
   Change History
   Who       When       What
   jbaber    12-Jul-05  Included check_digit in appno for post 2005 configuration
   jbaber    19-Aug-05  Modified for UC307 - HERCULES Small System Support
                        NOTE: Should be coded with dynamic ref cursor but this does
                        not work when called from Oracle Forms. WebIV - Note 170881.1
  ***************************************************************** */

-- get configured cycle
CURSOR c_cycle IS
  SELECT configured_cycle
    FROM IGS_UC_DEFAULTS
   WHERE system_code = NVL(p_system_code, 'U');

l_cycle  IGS_UC_DEFAULTS.configured_cycle%TYPE;

l_appno_pad  IGS_UC_U_CVNAME_2003.appno%TYPE;
l_appno      IGS_UC_U_CVNAME_2003.appno%TYPE;

BEGIN

   OPEN c_cycle;
   FETCH c_cycle INTO l_cycle;
   CLOSE c_cycle;

   IF l_cycle < 2006  THEN

       IF p_type = 'CVNAMEDET' THEN  -- Used this cursor in Enqdet block When New block instance procedure
         OPEN  l_result FOR SELECT appno, checkdigit, surname, forenames, birthdate, sex, title FROM igs_uc_u_cvname_2003 WHERE appno = p_appno;
       ELSIF p_type = 'FOUND' THEN   -- Used this cursor in post forms commit.
         OPEN l_result FOR SELECT appno FROM igs_uc_u_cvname_2003 WHERE appno = p_appno;
       ELSIF p_type = 'QUERYFIND' THEN  -- this cursor Used in the query find procedure
         OPEN l_result FOR  SELECT appno FROM igs_uc_u_cvname_2003 WHERE (INDEXSURN = UPPER(p_surname) AND TRUNC(BIRTHDATE) = TRUNC(p_birthdate)) OR appno = p_appno;
       ELSIF p_type = 'CVCOUNT' THEN  -- This cursor is used in the queryfind for name search
         OPEN l_result FOR SELECT count(*) count1 FROM igs_uc_u_cvname_2003 WHERE INDEXSURN = UPPER(p_surname) AND TRUNC(BIRTHDATE) = TRUNC(p_birthdate);
       END IF;
   ELSE

       -- use padded and unpadded versions of appno as appno in cvnames may not have leading zero
       -- alternate method would be to LPAD the where column of the query but this would remove indexing
       l_appno_pad := LPAD(p_appno || igs_uc_mv_data_upld.get_check_digit(p_appno),9,0);
       l_appno     := p_appno || igs_uc_mv_data_upld.get_check_digit(p_appno);

       IF p_system_code = 'U' THEN

           IF p_type = 'CVNAMEDET' THEN  -- Used this cursor in Enqdet block When New block instance procedure
             OPEN  l_result FOR SELECT SUBSTR(LPAD(appno,9,0),1,8), checkdigit, surname, forenames, birthdate, sex, title FROM igs_uc_u_cvname_2003 WHERE appno IN (l_appno, l_appno_pad);
           ELSIF p_type = 'FOUND' THEN   -- Used this cursor in post forms commit.
             OPEN l_result FOR SELECT SUBSTR(LPAD(appno,9,0),1,8) FROM igs_uc_u_cvname_2003 WHERE appno IN (l_appno, l_appno_pad);
           ELSIF p_type = 'QUERYFIND' THEN  -- this cursor Used in the query find procedure
             OPEN l_result FOR  SELECT SUBSTR(LPAD(appno,9,0),1,8) FROM igs_uc_u_cvname_2003 WHERE (UPPER(surname) = UPPER(p_surname) AND TRUNC(BIRTHDATE) = TRUNC(p_birthdate)) OR appno IN (l_appno, l_appno_pad);
           ELSIF p_type = 'CVCOUNT' THEN  -- This cursor is used in the queryfind for name search
             OPEN l_result FOR SELECT count(*) count1 FROM igs_uc_u_cvname_2003 WHERE UPPER(surname) = UPPER(p_surname) AND TRUNC(BIRTHDATE) = TRUNC(p_birthdate);
           END IF;

       ELSIF p_system_code = 'G' THEN

           IF p_type = 'CVNAMEDET' THEN  -- Used this cursor in Enqdet block When New block instance procedure
             OPEN  l_result FOR SELECT SUBSTR(LPAD(appno,9,0),1,8), checkdigit, surname, forenames, birthdate, sex, title FROM igs_uc_g_cvgname_2006 WHERE appno IN (l_appno, l_appno_pad);
           ELSIF p_type = 'FOUND' THEN   -- Used this cursor in post forms commit.
             OPEN l_result FOR SELECT SUBSTR(LPAD(appno,9,0),1,8) FROM igs_uc_g_cvgname_2006 WHERE appno IN (l_appno, l_appno_pad);
           ELSIF p_type = 'QUERYFIND' THEN  -- this cursor Used in the query find procedure
             OPEN l_result FOR  SELECT SUBSTR(LPAD(appno,9,0),1,8) FROM igs_uc_g_cvgname_2006 WHERE (UPPER(surname) = UPPER(p_surname) AND TRUNC(BIRTHDATE) = TRUNC(p_birthdate)) OR appno IN (l_appno, l_appno_pad);
           ELSIF p_type = 'CVCOUNT' THEN  -- This cursor is used in the queryfind for name search
             OPEN l_result FOR SELECT count(*) count1 FROM igs_uc_g_cvgname_2006 WHERE UPPER(surname) = UPPER(p_surname) AND TRUNC(BIRTHDATE) = TRUNC(p_birthdate);
           END IF;

       ELSIF p_system_code = 'N' THEN

           IF p_type = 'CVNAMEDET' THEN  -- Used this cursor in Enqdet block When New block instance procedure
             OPEN  l_result FOR SELECT SUBSTR(LPAD(appno,9,0),1,8), checkdigit, surname, forenames, birthdate, sex, title FROM igs_uc_n_cvnname_2006 WHERE appno IN (l_appno, l_appno_pad);
           ELSIF p_type = 'FOUND' THEN   -- Used this cursor in post forms commit.
             OPEN l_result FOR SELECT SUBSTR(LPAD(appno,9,0),1,8) FROM igs_uc_n_cvnname_2006 WHERE appno IN (l_appno, l_appno_pad);
           ELSIF p_type = 'QUERYFIND' THEN  -- this cursor Used in the query find procedure
             OPEN l_result FOR  SELECT SUBSTR(LPAD(appno,9,0),1,8) FROM igs_uc_n_cvnname_2006 WHERE (UPPER(surname) = UPPER(p_surname) AND TRUNC(BIRTHDATE) = TRUNC(p_birthdate)) OR appno IN (l_appno, l_appno_pad);
           ELSIF p_type = 'CVCOUNT' THEN  -- This cursor is used in the queryfind for name search
             OPEN l_result FOR SELECT count(*) count1 FROM igs_uc_n_cvnname_2006 WHERE UPPER(surname) = UPPER(p_surname) AND TRUNC(BIRTHDATE) = TRUNC(p_birthdate);
           END IF;

       END IF;

   END IF;

END cvname_references;


PROCEDURE ss_identify_trans_page(p_uc_tran_id IN VARCHAR2,
                                 p_page_function  OUT NOCOPY VARCHAR2) IS

  /******************************************************************
   Created By      : pmarada
   Date Created By : 08-Nov-03
   Purpose         : This procedure returns target source page function,
                     Used in admissions Enter Decision Outcomes page

   Known limitations,enhancements,remarks:
   Change History
   Who       When          What
   ayedubat  24-Nov-2003   To add a new cursor, trans_dtls_cur for deriving decision and system code
  ***************************************************************** */
  l_system_code igs_uc_transactions.system_code%TYPE;
  l_decision igs_uc_transactions.decision%TYPE;

  -- Get decision and system code from the transaction record
  CURSOR trans_dtls_cur( p_uc_tran_id IGS_UC_TRANSACTIONS.uc_tran_id%TYPE) IS
    SELECT decision, system_code
      FROM igs_uc_transactions
     WHERE uc_tran_id = p_uc_tran_id;

  BEGIN

    -- Get the Decision and System Code from the transaction record
    OPEN trans_dtls_cur ( TO_NUMBER(p_uc_tran_id));
    FETCH trans_dtls_cur INTO l_decision, l_system_code;
    CLOSE trans_dtls_cur;

    IF ((l_system_code = 'S' AND l_decision = 'R') OR
        (l_system_code = 'G' AND l_decision = 'R') OR
        (l_system_code = 'G' AND l_decision = 'S') OR
        (l_system_code = 'G' AND l_decision = 'M') OR
        (l_system_code = 'G' AND l_decision = 'E') OR
        (l_system_code = 'G' AND l_decision = 'G') OR
        (l_system_code = 'G' AND l_decision = 'X')) THEN

      p_page_function := 'IGS_UC_REVIEW_TRANSACTIONS';

    ELSE

      p_page_function := 'IGS_UC_ENTER_TRANS_DTLS_PAGE';

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- Incase if there is any exception, raise the exception
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_GEN_001.SS_IDENTIFY_TRANS_PAGE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END ss_identify_trans_page;

 PROCEDURE get_transaction_toy(p_system_code     IN  VARCHAR2,
                               p_ucas_cycle      IN  NUMBER,
                               p_transaction_toy OUT NOCOPY VARCHAR2 ) IS

  /******************************************************************
   Created By      : pmarada
   Date Created By : 10-Mar-04
   Purpose         : This procedure returns the transaction time of year
                    and used in IGSUC21B and IGSUC23B procedures

   Known limitations,enhancements,remarks:
   Change History
   Who       When          What
  ***************************************************************** */

    CURSOR c_uc_control IS
    SELECT time_of_year, extra_start_date, last_le_date, transaction_toy_code
      FROM igs_uc_ucas_control
     WHERE system_code = p_system_code
       AND ucas_cycle = p_ucas_cycle;

      l_uc_control c_uc_control%ROWTYPE;

  BEGIN

    OPEN c_uc_control;
    FETCH c_uc_control INTO l_uc_control;
    CLOSE c_uc_control;

    p_transaction_toy := NULL;
    p_transaction_toy := l_uc_control.transaction_toy_code;

  END get_transaction_toy;

 FUNCTION validate_personal_id(p_personal_id  IN VARCHAR2) RETURN BOOLEAN IS
  /******************************************************************
   Created By      : jbaber
   Date Created By : 10-Jul-06
   Purpose         : This procedure validates the personal id

   Known limitations,enhancements,remarks:
   Change History
   Who       When       What
  ***************************************************************** */

personal_id  NUMBER;

BEGIN

    -- Make sure personal id is a number
    personal_id := TO_NUMBER(p_personal_id);

    -- Check it is within range 1000000000 to 8999999999
    IF personal_id >= 1000000000 AND personal_id <= 8999999999 THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;

END validate_personal_id;


END igs_uc_gen_001;

/
