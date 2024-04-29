--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_023" AS
/* $Header: IGSADA1B.pls 120.1 2006/02/23 06:11:12 gmaheswa noship $ */
FUNCTION get_discrepancy_result (
                                 p_attribute_name      IN VARCHAR2, -- For Eg. 'SURNAME'
                                 p_ad_col_value        IN VARCHAR2, -- For Eg. 'Navin'
                                 p_int_col_value       IN VARCHAR2, -- For Eg. 'Navinkrs'
                                 p_source_type_id      IN NUMBER,   -- For Eg. 27
                                 p_category            IN VARCHAR2  -- For Eg. 'PERSON'
                                ) RETURN VARCHAR2
AS
      /*
      ||  Created By : Prabhat.Patel@Oracle.com
      ||  Created On : 21-Jun-2001
      ||  Purpose : This function gets the Discrepancy Rule for the column(i.e, p_attribute_name).
      ||    Evaluates the Discrepancy Rule and based on it's value (i.e, 'I'- 'Import' or 'E'- 'Keep'),
      ||    function returns either p_int_col_value or p_ad_col_value.
      ||  Known limitations, enhancements or remarks : Overloaded for VARCHAR2 values.
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */

       l_vc_return_val  VARCHAR2(2000);

       -- Define cursor to get the Detail Level Discrepancy Rule.
       CURSOR get_discrepancy_rule_cur IS
       SELECT discrepancy_rule_cd
       FROM   igs_ad_dscp_attr
       WHERE  UPPER(attribute_name) = UPPER(p_attribute_name)
       AND    src_cat_id =    (SELECT src_cat_id
                               FROM   igs_ad_source_cat
                               WHERE  source_type_id = p_source_type_id
                               AND    category_name  = p_category);
     get_discrepancy_rule_rec get_discrepancy_rule_cur%ROWTYPE;

     -- Evaluates the Discrepancy Rule

    BEGIN
     OPEN  get_discrepancy_rule_cur;
     FETCH get_discrepancy_rule_cur INTO get_discrepancy_rule_rec;
     CLOSE get_discrepancy_rule_cur;

      IF get_discrepancy_rule_rec.discrepancy_rule_cd = 'E' THEN
         l_vc_return_val := p_ad_col_value ;
      ELSIF get_discrepancy_rule_rec.discrepancy_rule_cd = 'I' THEN
         l_vc_return_val := NVL(p_int_col_value,p_ad_col_value);
      ELSE
         l_vc_return_val := p_ad_col_value;
          END IF;

     RETURN l_vc_return_val;
END get_discrepancy_result;

FUNCTION get_discrepancy_result (
                                 p_attribute_name      IN VARCHAR2, -- For Eg. 'LEVEL_OF_QUAL_ID'
                                 p_ad_col_value        IN NUMBER,   -- For Eg. 5
                                 p_int_col_value       IN NUMBER,   -- For Eg. 22
                                 p_source_type_id      IN NUMBER,   -- For Eg. 27
                                 p_category            IN VARCHAR2  -- For Eg. 'PERSON'
                                ) RETURN NUMBER
AS
    /*
      ||  Created By : Prabhat.Patel@Oracle.com
      ||  Created On : 21-Jun-2001
      ||  Purpose : This function gets the Discrepancy Rule for the column(i.e, p_attribute_name).
      ||    Evaluates the Discrepancy Rule and based on it's value (i.e, 'I'- 'Import' or 'E'- 'Keep'),
      ||    function returns either p_int_col_value or p_ad_col_value.
      ||  Known limitations, enhancements or remarks : Overloaded for NUMBER values.
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
    */

       l_n_return_val  NUMBER;

      -- Define cursor to get the Detail Level Discrepancy Rule.
       CURSOR get_discrepancy_rule_cur IS
       SELECT discrepancy_rule_cd
       FROM   igs_ad_dscp_attr
       WHERE  UPPER(attribute_name) = UPPER(p_attribute_name)
       AND    src_cat_id =    (SELECT src_cat_id
                               FROM   igs_ad_source_cat
                               WHERE  source_type_id = p_source_type_id
                               AND    category_name  = p_category);
       get_discrepancy_rule_rec get_discrepancy_rule_cur%ROWTYPE;

       -- Evaluates the Discrepancy Rule

    BEGIN
      OPEN  get_discrepancy_rule_cur;
      FETCH get_discrepancy_rule_cur INTO get_discrepancy_rule_rec;
      CLOSE get_discrepancy_rule_cur;

      IF get_discrepancy_rule_rec.discrepancy_rule_cd = 'E' THEN
         l_n_return_val := p_ad_col_value ;
      ELSIF get_discrepancy_rule_rec.discrepancy_rule_cd = 'I' THEN
         l_n_return_val := NVL(p_int_col_value,p_ad_col_value);
      ELSE
         l_n_return_val := p_ad_col_value;
          END IF;

      RETURN l_n_return_val;
END get_discrepancy_result;

FUNCTION get_discrepancy_result (
                                 p_attribute_name      IN VARCHAR2, -- For Eg. 'BIRTH_DT'
                                 p_ad_col_value        IN DATE,     -- For Eg.  SYSDATE
                                 p_int_col_value       IN DATE,     -- For Eg.  SYSDATE - 1
                                 p_source_type_id      IN NUMBER,   -- For Eg. 27
                                 p_category            IN VARCHAR2  -- For Eg. 'PERSON'
                                ) RETURN DATE
AS
      /*
      ||  Created By : Prabhat.Patel@Oracle.com
      ||  Created On : 21-Jun-2001
      ||  Purpose : This function gets the Discrepancy Rule for the column(i.e, p_attribute_name).
      ||    Evaluates the Discrepancy Rule and based on it's value (i.e, 'I'- 'Import' or 'E'- 'Keep'),
      ||    function returns either p_int_col_value or p_ad_col_value.
      ||  Known limitations, enhancements or remarks : Overloaded for DATE values.
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */

       l_d_return_val  DATE;

       -- Define cursor to get the Detail Level Discrepancy Rule.
       CURSOR get_discrepancy_rule_cur IS
       SELECT discrepancy_rule_cd
       FROM   igs_ad_dscp_attr
       WHERE  UPPER(attribute_name) = UPPER(p_attribute_name)
       AND    src_cat_id =    (SELECT src_cat_id
                               FROM   igs_ad_source_cat
                               WHERE  source_type_id = p_source_type_id
                               AND    category_name  = p_category);
       get_discrepancy_rule_rec get_discrepancy_rule_cur%ROWTYPE;

       -- Evaluates the Discrepancy Rule
    BEGIN
      OPEN  get_discrepancy_rule_cur;
      FETCH get_discrepancy_rule_cur INTO get_discrepancy_rule_rec;
      CLOSE get_discrepancy_rule_cur;

      IF get_discrepancy_rule_rec.discrepancy_rule_cd = 'E' THEN
         l_d_return_val := p_ad_col_value;
      ELSIF get_discrepancy_rule_rec.discrepancy_rule_cd = 'I' THEN
         l_d_return_val := NVL(p_int_col_value,p_ad_col_value);
      ELSE
         l_d_return_val := p_ad_col_value;
          END IF;

      RETURN l_d_return_val;
END get_discrepancy_result;

FUNCTION prepare_pk_where_clause(
                                      p_param1 VARCHAR2 DEFAULT NULL, -- First PK column Name.
                                      p_param2 VARCHAR2 DEFAULT NULL, -- First PK column value.
                                      p_param3 VARCHAR2 DEFAULT NULL, -- Second PK column Name.
                                      p_param4 VARCHAR2 DEFAULT NULL, -- Second PK column value.
                                      p_param5 VARCHAR2 DEFAULT NULL, -- Third PK column Name.
                                      p_param6 VARCHAR2 DEFAULT NULL, -- Third PK column value.
                                      p_param7 VARCHAR2 DEFAULT NULL, -- Forth PK column Name.
                                      p_param8 VARCHAR2 DEFAULT NULL, -- Forth PK column value.
                                      p_param9 VARCHAR2 DEFAULT NULL, -- Fifth PK column Name.
                                      p_param10 VARCHAR2 DEFAULT NULL -- Fifth PK column value.
                                    ) RETURN VARCHAR2
AS
      /*
      ||  Created By : Prabhat.Patel@Oracle.com
      ||  Created On : 21-Jun-2001
      ||  Purpose : This function accepts a set of input Primary Key(PK) column names
      ||    and their values in VARCHAR2 format and returns a string 'WHERE clause' values.
      ||  Known limitations, enhancements or remarks : Currently this function supports only
      ||                                               five column names along with their values.
      ||  Change History :
      ||  Who             When            What
      ||  gmaheswa	  23-Feb-2006	  Stubbed As part of literal usage fix.
      ||  (reverse chronological order - newest change first)
      */
    BEGIN
       NULL;
END prepare_pk_where_clause;

FUNCTION find_detail_discrepancy_rule (
                                       p_source_type_id      IN NUMBER,   -- For Eg. 27
                                       p_category            IN VARCHAR2, -- For Eg. 'PERSON'
                                       p_int_pk_where_clause IN VARCHAR2, -- For Eg. 'INTERFACE_ID = 55'
                                       p_ad_pk_where_clause  IN VARCHAR2  -- For Eg. 'PERSON_ID = 9855582'
                                      ) RETURN BOOLEAN
AS
      /*
      ||  Created By : Prabhat.Patel@Oracle.com
      ||  Created On : 21-Jun-2001
      ||  Purpose : This function evaluates the 'Review' Discrepancy Rules at
      ||    column for a category(i.e, p_category). If column level
      ||    discrepancy exists this function returns TRUE otherwise it returns FALSE.
      ||  Known limitations, enhancements or remarks : Uses REF cursor for checking the Detail
      ||                                               Level Discrepancy Rule.
      ||  Change History :
      ||  Who             When            What
      ||  pkpatel         18-DEC-2003     Bug 3091707 (Moved the log messages from FND_FILE to FND_LOG_REPOSITORY)
      ||  gmaheswa	  23-Feb-2006	  Stubbed and created a new overloaded function. as part of literal usage fix.
      ||  (reverse chronological order - newest change first)
      */

BEGIN
       	null;
END find_detail_discrepancy_rule;

FUNCTION find_detail_discrepancy_rule (
                                       p_source_type_id      IN NUMBER,   -- For Eg. 27
                                       p_category            IN VARCHAR2, -- For Eg. 'PERSON'
                                       p_int_pk_col_name     IN VARCHAR2, -- Interface Table PK column Name.'INTERFACE_ID'
                                       p_int_pk_col_val      IN VARCHAR2, -- Interface Table PK column value.7
                                       p_ad_pk_col_name      IN VARCHAR2, -- Admission Table PK column Name.'PERSON_ID'
                                       p_ad_pk_col_val       IN VARCHAR2  -- Admission Table PK column value.123
                                      ) RETURN BOOLEAN
AS
      /*
      ||  Created By : gayam.maheswari@Oracle.com
      ||  Created On : 23-Feb-2006
      ||  Purpose : This function evaluates the 'Review' Discrepancy Rules at
      ||    column for a category(i.e, p_category). If column level
      ||    discrepancy exists this function returns TRUE otherwise it returns FALSE.
      ||  Known limitations, enhancements or remarks : Uses REF cursor for checking the Detail
      ||                                               Level Discrepancy Rule.
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */

       -- Define the REF cursor for checking the Detail Level Discrepancy Rule.
       TYPE discrepancy_check_cur IS REF CURSOR;
       discrepancy_check_ref_cur  discrepancy_check_cur;
       l_ref_cur_sql              VARCHAR2(2000);
       l_discrepancy_exists       NUMBER(1) :=0;
       l_admission_sql            VARCHAR2(2000);
       l_interface_sql            VARCHAR2(2000);
       l_ad_column_null           NUMBER(1) :=0;
       l_int_column_null          NUMBER(1) :=0;

       -- Variables for FND logging
       l_request_id NUMBER(15) := fnd_global.conc_request_id;
       l_prog_label VARCHAR2(100) := 'igs.plsql.igs_ad_imp_002.prc_pe_dtls';
       l_label VARCHAR2(100)   := 'igs.plsql.igs_ad_imp_023.find_detail_discrepancy_rule.';
       l_debug_str VARCHAR2(10000);

       -- Get the SRC_CAT_ID, AD_TAB_NAME, INT_TAB_NAME from igs_ad_source_cat table.
       CURSOR source_cat_cur IS
       SELECT *
       FROM   igs_ad_source_cat
       WHERE  source_type_id = p_source_type_id
       AND    category_name  = p_category;

       source_cat_rec   source_cat_cur%ROWTYPE;

       -- Get the ATTRIBUTE_NAME for which discrepancy rule is marked for Review.
       CURSOR detail_discrepancy_cur(cp_src_cat_id igs_ad_source_cat.src_cat_id%TYPE) IS
       SELECT *
       FROM   igs_ad_dscp_attr
       WHERE  src_cat_id = cp_src_cat_id
       AND    NVL(discrepancy_rule_cd,'I') = 'R';

       detail_discrepancy_rec     detail_discrepancy_cur%ROWTYPE;


    BEGIN


	   -- Get the values of SRC_CAT_ID, AD_TAB_NAME, INT_TAB_NAME
       OPEN  source_cat_cur;
       FETCH source_cat_cur INTO source_cat_rec;
       CLOSE source_cat_cur;

       -- Loop through all the columns of the current processing table.
       -- And check discrepancy rule for each column.
   FOR detail_discrepancy_rec IN detail_discrepancy_cur(source_cat_rec.src_cat_id) LOOP
         /* Prepare the sql string to check for discrepancy rule for the current column.
         ** SQL String will be like :
         ** ' SELECT 1
         **   FROM   IGS_PE_PERSON
         **   WHERE  PERSON_ID = 9855582
         **   AND    BIRTH_DT  =   SELECT  BIRTH_DT
         **                        FROM   IGS_AD_INTERFACE_DTL_DSCP_V
         **                        WHERE  INTERFACE_ID = 55 ) '
         */
                   --Dynamic SQL  statements are declared for both Admission and Interface columns to check for NULL values.
             l_admission_sql:='SELECT 1 FROM ' ||source_cat_rec.ad_tab_name
                                    ||' WHERE  ' || p_ad_pk_col_name || '= :cp_ad_pk_col_value AND '
                                    || detail_discrepancy_rec.attribute_name
                                    ||' IS NULL';

             l_interface_sql :='SELECT 1 FROM ' ||source_cat_rec.int_tab_name
                                    ||' WHERE  ' || p_int_pk_col_name || '= :cp_int_pk_col_value AND '
                                    || detail_discrepancy_rec.attribute_name
                                    ||' IS NULL';
             --Assign 1 to the counters if the column value IS NULL
         OPEN discrepancy_check_ref_cur FOR l_admission_sql USING p_ad_pk_col_val;
         FETCH discrepancy_check_ref_cur INTO l_ad_column_null;
         CLOSE discrepancy_check_ref_cur;

         OPEN discrepancy_check_ref_cur FOR l_interface_sql USING p_int_pk_col_val;
         FETCH discrepancy_check_ref_cur INTO l_int_column_null;
         CLOSE discrepancy_check_ref_cur;

     --If only  one of the counters is  '1' then discrepancy exists RETURN TRUE
     --If both of them = 0 then compare the values in both the fields in both the tables.
     --If both the counters are '1',then Both values are NULL. Hence NO discrepancy, proceed for the next record

     IF (l_ad_column_null = 1 AND  l_int_column_null <> 1) OR (l_ad_column_null <> 1 AND  l_int_column_null = 1) THEN

		  -- Discrepancy exists, match indicator for this record should be updated to '20'.
          IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

            l_label := l_label || 'discpNULL';
            l_debug_str :=  p_int_pk_col_name||' = '|| p_int_pk_col_val || ' Discrepancy exists as only one of the  value IS NULL for : '|| detail_discrepancy_rec.attribute_name;

            fnd_log.string_with_context( fnd_log.level_procedure,l_label, l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

          RETURN TRUE;
     ELSIF l_ad_column_null = 0 AND l_int_column_null = 0 THEN
         --Dynamic SQL statement to compare the values in both the Tables
         l_ref_cur_sql := ' SELECT 1 FROM   ' || source_cat_rec.ad_tab_name
           || ' WHERE  ' || p_ad_pk_col_name || '= :cp_ad_pk_col_value AND '
           || detail_discrepancy_rec.attribute_name
           || ' = ' || '  ( SELECT ' || detail_discrepancy_rec.attribute_name
           || ' FROM   ' || source_cat_rec.int_tab_name
           || ' WHERE  ' || p_int_pk_col_name || '= :cp_int_pk_col_value )' ;

         OPEN discrepancy_check_ref_cur FOR l_ref_cur_sql  USING p_ad_pk_col_val, p_int_pk_col_val;
         FETCH discrepancy_check_ref_cur INTO l_discrepancy_exists;
         IF discrepancy_check_ref_cur%FOUND THEN

              -- Discrepancy does not exist, give me more..
              CLOSE discrepancy_check_ref_cur;
         ELSE
              -- Discrepancy exists, match indicator for this record should be updated to '20'.
			   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

				 l_label := l_label || 'discpNOTNULL';
				 l_debug_str := p_int_pk_col_name||' = '|| p_int_pk_col_val ||' Discrepancy exists, Value of l_ref_cur_sql is :***>>'|| l_ref_cur_sql;

				 fnd_log.string_with_context( fnd_log.level_procedure,l_label, l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
			   END IF;

              CLOSE discrepancy_check_ref_cur;
              RETURN TRUE;
         END IF;
          --ELSE   l_ad_column_null=1 AND  l_int_column_null=1 THEN
          -- Discrepancy does not exist, give me more..
     END IF;
          --refreshing the counter values
          l_ad_column_null := 0;
          l_int_column_null := 0;
  END LOOP;

      -- Discrepancy does not exist, match indicator for this record should be updated to '23'.
       RETURN FALSE;

     EXCEPTION WHEN OTHERS THEN
        -- Some SQL execution problem occurred. Mark this record for Discrepancy check.
        -- Discrepancy exists, match indicator for this record should be updated to '20'.
        -- Capture the error details in the logfile.

		   IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

				 l_label := l_label || 'Exception';
				 l_debug_str :=  p_int_pk_col_name||' = '|| p_int_pk_col_val ||' When Other Exception Raised. To be on safer side Returning TRUE. Value of l_ref_cur_sql is :***>>'|| l_ref_cur_sql||
				                ' Value of SQLERRM is :***>> '||SQLERRM;

				 fnd_log.string_with_context( fnd_log.level_procedure,l_label, l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
		   END IF;

        RETURN TRUE;
END find_detail_discrepancy_rule;

FUNCTION find_attribute_rule(
    p_Source_type_id IN NUMBER,
    p_Category IN VARCHAR2 ) RETURN VARCHAR2
AS
      /*
      ||  Created By : Prabhat.Patel@Oracle.com
      ||  Created On : 21-Jun-2001
      ||  Purpose : This function returns one of the following :
      ||            'I' : If Discrepancy rule for some of the columns are marked for Import: 'I'.
      ||            'R' : If Discrepancy rule for some of the columns are marked for Review: 'R'.
      ||            'E' : If Discrepancy rule for all the columns are marked for Keep: 'E'.
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */
       l_rec_rev_count NUMBER;
       l_rec_import_count NUMBER;

    -- Check if any column discrepancy rule is marked for Review : 'R'.
       CURSOR check_dtl_for_rev_cur IS
       SELECT count(ROWID)
       FROM   igs_ad_dscp_attr
       WHERE  src_cat_id = (SELECT src_cat_id
                            FROM   igs_ad_source_cat
                            WHERE  category_name = p_category
                            AND    source_type_id = p_Source_type_id)
       AND    NVL(discrepancy_rule_cd,'E') = 'R';

    -- Check if any column discrepancy rule is marked for Import : 'I'.
     CURSOR check_dtl_for_import_cur IS
       SELECT count(ROWID)
       FROM   igs_ad_dscp_attr
       WHERE  src_cat_id = (SELECT src_cat_id
                            FROM   igs_ad_source_cat
                            WHERE  category_name = p_category
                            AND    source_type_id = p_Source_type_id)
       AND    NVL(discrepancy_rule_cd,'E') = 'I';

    BEGIN

      -- Check if any column discrepancy rule is marked for Review : 'R'.
      OPEN  check_dtl_for_rev_cur;
      FETCH check_dtl_for_rev_cur INTO l_rec_rev_count;
      CLOSE check_dtl_for_rev_cur;
      -- Check if any column discrepancy rule is marked for Import : 'I'.
      OPEN  check_dtl_for_import_cur;
      FETCH check_dtl_for_import_cur INTO l_rec_import_count;
      CLOSE check_dtl_for_import_cur;

      IF l_rec_rev_count > 0 THEN
        -- Discrepancy rule for some of the columns are marked for Review: 'R'.
        RETURN 'R';
      ELSIF l_rec_import_count > 0 THEN
        -- Discrepancy rule for some of the columns are marked for Import: 'I'.
        RETURN 'I';
      ELSE
        -- Discrepancy rule for all the columns are marked for Keep: 'E'.
        RETURN 'E';
      END IF;

END find_attribute_rule;

END Igs_Ad_Imp_023;

/
