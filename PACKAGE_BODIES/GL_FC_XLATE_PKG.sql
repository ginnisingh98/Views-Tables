--------------------------------------------------------
--  DDL for Package Body GL_FC_XLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FC_XLATE_PKG" AS
/* $Header: glfcxltb.pls 120.8 2005/05/05 02:05:19 kvora ship $ */

  FUNCTION get_unique_name(ldg_name IN VARCHAR2,
                      ldg_id   IN NUMBER,
                      tcurr_code IN VARCHAR2) RETURN VARCHAR2 IS
    dummy  number;
    target_lname VARCHAR2(30);
    CURSOR unique_name(target_lname VARCHAR2) IS
       SELECT 1
       FROM DUAL
       WHERE EXISTS
          (SELECT primary_ledger_id
           FROM gl_ledger_relationships
           WHERE target_ledger_name = target_lname);
  BEGIN
    target_lname := substrb(ldg_name,1,(27-lengthb(tcurr_code)))
                     ||' ('||tcurr_code||')';

    OPEN unique_name(target_lname);
    FETCH unique_name INTO dummy;

    IF(dummy = 1) THEN
       SELECT decode(sign(26-lengthb(to_char(ldg_id))-lengthb(tcurr_code)),
                1,substrb(ldg_name,1,
                                   (26-lengthb(ldg_id)-lengthb(tcurr_code)))||
                  ' ','')||to_char(ldg_id)||' ('||
                  decode(sign(27-lengthb(to_char(ldg_id))-lengthb(tcurr_code)),
                         -1,substrb(tcurr_code,1,
                                               (27-lengthb(to_char(ldg_id))))||
                  ')',tcurr_code||')')
       INTO target_lname
       FROM DUAL;
    END IF;

    RETURN target_lname;

  END get_unique_name;


  FUNCTION get_unique_short_name(ldg_short_name IN VARCHAR2,
                      ldg_id   IN NUMBER,
                      tcurr_code IN VARCHAR2) RETURN VARCHAR2 IS
    dummy  number;
    target_lshort_name VARCHAR2(30);
    CURSOR unique_name(target_lshort_name VARCHAR2) IS
       SELECT 1
       FROM DUAL
       WHERE EXISTS
          (SELECT primary_ledger_id
           FROM gl_ledger_relationships
           WHERE target_ledger_short_name = target_lshort_name);
  BEGIN
    target_lshort_name := substrb(ldg_short_name,1,(17-lengthb(tcurr_code)))
                     ||' ('||tcurr_code||')';

    OPEN unique_name(target_lshort_name);
    FETCH unique_name INTO dummy;

    IF(dummy = 1) THEN
       SELECT decode(sign(16-lengthb(to_char(ldg_id))-lengthb(tcurr_code)),
                1,substrb(ldg_short_name,1,
                          (16-lengthb(ldg_id)-lengthb(tcurr_code)))||' ','')||
                  to_char(ldg_id)||' ('||
                  decode(sign(17-lengthb(to_char(ldg_id))-lengthb(tcurr_code)),
                    -1,substrb(tcurr_code,1,(17-lengthb(to_char(ldg_id))))||
                  ')',tcurr_code||')')
       INTO target_lshort_name
       FROM DUAL;
    END IF;

    RETURN target_lshort_name;

  END get_unique_short_name;


  FUNCTION get_ledger_name(ldg_name IN VARCHAR2,
                      ldg_id   IN NUMBER,
                      tcurr_code IN VARCHAR2) RETURN VARCHAR2 IS
    tgt_ldg_name	VARCHAR2(30);

    CURSOR get_existing_ledger_name IS
    SELECT	target_ledger_name
    FROM	gl_ledger_relationships
    WHERE	target_ledger_id = ldg_id
    AND		target_currency_code = tcurr_code
    AND		application_id = 101
    AND		org_id = -99
    AND		relationship_enabled_flag = 'Y';

  BEGIN
    -- Stat is a special case where you just get the original ledger name
    IF tcurr_code = 'STAT' THEN
      return ldg_name;
    END IF;

    OPEN get_existing_ledger_name;
    FETCH get_existing_ledger_name INTO tgt_ldg_name;
    IF get_existing_ledger_name%NOTFOUND THEN
      tgt_ldg_name := get_unique_name(ldg_name, ldg_id, tcurr_code);
    END IF;
    CLOSE get_existing_ledger_name;

    return tgt_ldg_name;

  END get_ledger_name;


  FUNCTION get_ledger_short_name(ldg_short_name IN VARCHAR2,
                      ldg_id   IN NUMBER,
                      tcurr_code IN VARCHAR2) RETURN VARCHAR2 IS
    tgt_ldg_short_name	VARCHAR2(30);

    CURSOR get_existing_ledger_short_name IS
    SELECT	target_ledger_short_name
    FROM	gl_ledger_relationships
    WHERE	target_ledger_id = ldg_id
    AND		target_currency_code = tcurr_code
    AND		application_id = 101
    AND		org_id = -99
    AND		relationship_enabled_flag = 'Y';

  BEGIN
    -- Stat is a special case where you just get the original ledger short name
    IF tcurr_code = 'STAT' THEN
      return ldg_short_name;
    END IF;

    OPEN get_existing_ledger_short_name;
    FETCH get_existing_ledger_short_name INTO tgt_ldg_short_name;
    IF get_existing_ledger_short_name%NOTFOUND THEN
      tgt_ldg_short_name :=
          get_unique_short_name(ldg_short_name, ldg_id, tcurr_code);
    END IF;
    CLOSE get_existing_ledger_short_name;

    return tgt_ldg_short_name;

  END get_ledger_short_name;


  FUNCTION relation_exist(ldg_id IN NUMBER,
                          tcurr_code IN VARCHAR2) RETURN VARCHAR2 IS
    dummy  NUMBER;
    CURSOR relation IS
      select l.ledger_id
      from gl_ledgers l, gl_ledger_set_assignments lsa
      where lsa.ledger_set_id = ldg_id
      and l.ledger_id = lsa.ledger_id
      and l.object_type_code = 'L'
      and l.ledger_category_code in ('PRIMARY','SECONDARY')
      and not exists
         (select 1
          from gl_ledger_relationships lr
          where lr.source_ledger_id = l.ledger_id
          and lr.target_ledger_id = l.ledger_id
          and lr.target_ledger_category_code = 'ALC'
          and lr.relationship_type_code = 'BALANCE'
          and lr.target_currency_code = tcurr_code
          and lr.application_id = 101
          and lr.org_id = -99);

  BEGIN
    OPEN relation;
    FETCH relation INTO dummy;

    IF (relation%FOUND) THEN
       RETURN 'N';
    ELSE
       RETURN 'Y';
    END IF;

    CLOSE relation;

  END relation_exist;


  FUNCTION xlated_ever(ldg_id IN NUMBER,
                       tcurr_code IN VARCHAR2,
                       bal_seg_val IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    dummy  NUMBER;
    CURSOR spec_bal IS
      select l.ledger_id
      from gl_ledgers l, gl_ledger_set_assignments lsa
      where lsa.ledger_set_id = ldg_id
      and l.ledger_id = lsa.ledger_id
      and l.object_type_code = 'L'
      and not exists
         (select 1
          from gl_translation_tracking tt
          where tt.ledger_id = l.ledger_id
          and tt.target_currency = tcurr_code
          and tt.bal_seg_value = bal_seg_val);

    CURSOR all_bal IS
      select l.ledger_id
      from gl_ledgers l, gl_ledger_set_assignments lsa
      where lsa.ledger_set_id = ldg_id
      and l.ledger_id = lsa.ledger_id
      and l.object_type_code = 'L'
      and not exists
         (select 1
          from gl_translation_tracking tt
          where tt.ledger_id = l.ledger_id
          and tt.target_currency = tcurr_code);

  BEGIN
     IF(bal_seg_val IS NULL) THEN
        OPEN all_bal;
        FETCH all_bal INTO dummy;
        IF (all_bal%FOUND) THEN
            RETURN 'N';
        ELSE
            RETURN 'Y';
        END IF;
        CLOSE all_bal;
     ELSE
        OPEN spec_bal;
        FETCH spec_bal INTO dummy;
        IF(spec_bal%FOUND) THEN
           RETURN 'N';
        ELSE
           RETURN 'F';
        END IF;
        CLOSE spec_bal;
     END IF;

  END xlated_ever;


  FUNCTION  FIRST_EVER_PERIOD_CHECK (x_ledger_id NUMBER, x_period VARCHAR2)
                  RETURN BOOLEAN IS
     l_first_ever_period NUMBER;
     l_object_type_code  VARCHAR2(1);
     l_period_set_name   VARCHAR2(15);
     l_period_type       VARCHAR2(15);

     l_ledger_id         NUMBER;
     CURSOR first_period IS
                      SELECT 1
                      FROM   gl_period_statuses gps
                      WHERE  gps.application_id = 101
                      AND    gps.ledger_id = l_ledger_id
                      AND    EXISTS
                            (SELECT (gp1.period_year*10000+ gp1.period_num)
                      FROM GL_PERIODS gp1
                      WHERE gp1.period_name =  x_period
                      AND   gp1.period_set_name = l_period_set_name
                      AND   gps.effective_period_num <
                            (gp1.period_year*10000+ gp1.period_num))
                      AND ROWNUM = 1;


  BEGIN
     l_first_ever_period := 0;

     -- Find out the the ledger id passed is a ledger or a set.

     SELECT gll.period_set_name,
            gll.accounted_period_type,
            gll.object_type_code
     INTO   l_period_set_name,
            l_period_type,
            l_object_type_code
     FROM gl_ledgers gll
     WHERE ledger_id = x_ledger_id;

     IF (l_object_type_code = 'S') THEN

        SELECT glsa.ledger_id
        INTO   l_ledger_id
        FROM GL_LEDGER_SET_ASSIGNMENTS glsa,
             GL_LEDGERS l
        WHERE glsa.ledger_set_id = x_ledger_id
        AND   glsa.ledger_id  = l.ledger_id
        AND   l.object_type_Code = 'L'
        AND   ROWNUM = 1;
     ELSE
        l_ledger_id := x_ledger_id;
     END IF;

     -- Check is the period passed is first defined period in the calendar.
     -- If there are no periods defined prior to the passed period, then
     -- the passed period is first defined period.

        OPEN First_period;
        FETCH First_period INTO l_first_ever_period;
        IF(First_period%FOUND) THEN
           RETURN  FALSE;
        ELSE
           RETURN  TRUE;
        END IF;

        CLOSE First_Period;


  END FIRST_EVER_PERIOD_CHECK;

END GL_FC_XLATE_PKG;

/
