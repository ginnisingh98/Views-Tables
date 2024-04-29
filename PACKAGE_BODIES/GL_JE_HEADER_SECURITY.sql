--------------------------------------------------------
--  DDL for Package Body GL_JE_HEADER_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JE_HEADER_SECURITY" AS
/* $Header: gluhdsvb.pls 120.2 2003/04/24 01:38:12 djogg noship $ */

--
-- PUBLIC FUNCTIONS
--

-- **********************************************************************

  --   NAME
  --     check_header_valid_lsv
  --   DESCRIPTION
  --     Return 'Y' if all the ledger segment values are valid
  --     for the given header and a date.
  --     If no date is provided, the date is ignored.
  FUNCTION check_header_valid_lsv ( x_je_header_id          IN NUMBER,
                                    x_edate                 IN DATE)  RETURN VARCHAR2
  IS
    CURSOR has_all_lsv( p_je_header_id  NUMBER )
    IS
      SELECT ldg.ledger_id,
             ldg.bal_seg_value_option_code,
             ldg.mgt_seg_value_option_code
      FROM   GL_LEDGERS ldg,
             GL_JE_HEADERS h
      WHERE  ldg.ledger_id = h.ledger_id
        AND  h.je_header_id = p_je_header_id;

    CURSOR is_invalid_lsv( p_je_header_id         NUMBER,
                           p_segment_type_code    VARCHAR2,
                           p_edate                DATE,
                           p_ledger_id            NUMBER)
    IS
      SELECT  'Invalid'
      FROM    GL_JE_SEGMENT_VALUES jsv
      WHERE   jsv.segment_type_code = p_segment_type_code
        AND   jsv.je_header_id = p_je_header_id
        AND   NOT EXISTS (SELECT 'Valid'
                          FROM   GL_LEDGER_SEGMENT_VALUES sv
                          WHERE  NVL(trunc(p_edate), NVL(sv.start_date,TO_DATE('1950/01/01','YYYY/MM/DD')))
                                 BETWEEN NVL(sv.start_date,TO_DATE('1950/01/01','YYYY/MM/DD'))
                                     AND NVL(sv.end_date,TO_DATE('9999/01/01','YYYY/MM/DD'))
                            AND  sv.segment_value = jsv.segment_value
                            AND  sv.segment_type_code = p_segment_type_code
                            AND  sv.ledger_id = p_ledger_id);

    CURSOR is_invalid( p_je_header_id         NUMBER,
                       p_edate                DATE,
                       p_ledger_id            NUMBER)
    IS
      SELECT  'Invalid'
      FROM    GL_JE_SEGMENT_VALUES jsv
      WHERE   jsv.je_header_id = p_je_header_id
        AND   NOT EXISTS (SELECT 'Valid'
                          FROM   GL_LEDGER_SEGMENT_VALUES sv
                          WHERE  NVL(trunc(p_edate), NVL(sv.start_date,TO_DATE('1950/01/01','YYYY/MM/DD')))
                                 BETWEEN NVL(sv.start_date,TO_DATE('1950/01/01','YYYY/MM/DD'))
                                     AND NVL(sv.end_date,TO_DATE('9999/01/01','YYYY/MM/DD'))
                            AND  sv.segment_value = jsv.segment_value
                            AND  sv.segment_type_code = jsv.segment_type_code
                            AND  sv.ledger_id = p_ledger_id);

    dummy          VARCHAR2(30);
    x_ledger_id    NUMBER(15);
    bsv_option     VARCHAR2(1);
    msv_option     VARCHAR2(1);
    valid_lsv      VARCHAR2(1) := 'N';

    INVALID_JE_HEADER_ID    EXCEPTION;

  BEGIN
    OPEN has_all_lsv( x_je_header_id );
    FETCH has_all_lsv INTO x_ledger_id,
                           bsv_option,
                           msv_option;

    IF (has_all_lsv%NOTFOUND) THEN
      CLOSE has_all_lsv;
      RAISE INVALID_JE_HEADER_ID;
    ELSE
      CLOSE has_all_lsv;
    END IF;

    IF (bsv_option = 'A' AND msv_option = 'A') THEN
      -- All the lsvs are allowed, return Yes.
      valid_lsv := 'Y';
      RETURN(valid_lsv);

    ELSIF (bsv_option = 'I' AND msv_option = 'A') THEN
      -- All the msvs are allowed.
      -- Check if all the bsvs of the header are allowed.
      OPEN is_invalid_lsv(x_je_header_id,
                          'B',
                          x_edate,
                          x_ledger_id);
      FETCH is_invalid_lsv INTO dummy;

      IF is_invalid_lsv%FOUND THEN
        CLOSE is_invalid_lsv;
        RETURN(valid_lsv);
      ELSE
        CLOSE is_invalid_lsv;
        valid_lsv := 'Y';
        RETURN(valid_lsv);
      END IF;

    ELSIF (bsv_option = 'A' AND msv_option = 'I') THEN
      -- All the bsvs are allowed.
      -- Check if all the msvs of the header are allowed.
      OPEN is_invalid_lsv(x_je_header_id,
                          'M',
                          x_edate,
                          x_ledger_id);
      FETCH is_invalid_lsv INTO dummy;

      IF is_invalid_lsv%FOUND THEN
        CLOSE is_invalid_lsv;
        RETURN(valid_lsv);
      ELSE
        CLOSE is_invalid_lsv;
        valid_lsv := 'Y';
        RETURN(valid_lsv);
      END IF;

    ELSIF (bsv_option = 'I' AND msv_option = 'I') THEN

      -- Check if all the lsvs of the header are allowed.
      OPEN is_invalid(x_je_header_id,
                      x_edate,
                      x_ledger_id);
      FETCH is_invalid INTO dummy;

      IF is_invalid%FOUND THEN
        CLOSE is_invalid;
        RETURN(valid_lsv);
      ELSE
        CLOSE is_invalid;
        valid_lsv := 'Y';
        RETURN(valid_lsv);
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      app_exception.raise_exception;
  END check_header_valid_lsv;

-- **********************************************************************

  -- NAME
  --   check_header_write_all
  -- DESCRIPTION
  --   Check both the valid ledger segment values and whether the user has write access.
  --   The valid ledger segment values are checked first, then if they are valid,
  --   the access privilege is checked.
  FUNCTION check_header_write_all ( x_access_set_id    IN NUMBER,
                                    x_je_header_id     IN NUMBER,
                                    x_edate            IN DATE)  RETURN VARCHAR2
  IS
    valid_lsv                VARCHAR2(1);
    access_privilege_code    VARCHAR2(1) := 'Z';
    x_je_batch_id            NUMBER;

  BEGIN
    -- Check the header segment values
    valid_lsv := gl_je_header_security.check_header_valid_lsv ( x_je_header_id      => x_je_header_id,
                                                                   x_edate             => x_edate);
    IF (valid_lsv = 'N') THEN
      RETURN (access_privilege_code);
    END IF;

    SELECT je_batch_id
    INTO x_je_batch_id
    FROM gl_je_headers
    WHERE je_header_id = x_je_header_id;

    -- Check if the user has write access to the header
    access_privilege_code :=  gl_access_set_security_pkg.get_journal_access(
          access_set_id => x_access_set_id,
          header_only => FALSE,
          check_mode => gl_access_set_security_pkg.WRITE_ACCESS,
          je_id  => x_je_batch_id);

    IF (access_privilege_code=gl_access_set_security_pkg.WRITE_ACCESS) THEN
      access_privilege_code := 'Y';
    ELSE
      access_privilege_code := 'N';
    END IF;

    RETURN (access_privilege_code);

  EXCEPTION
    WHEN OTHERS THEN
      app_exception.raise_exception;
  END check_header_write_all;

END gl_je_header_security;

/
