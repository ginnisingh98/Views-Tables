--------------------------------------------------------
--  DDL for Package Body IGS_PE_DUP_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_DUP_PERSON" AS
/* $Header: IGSPE04B.pls 120.0 2005/06/01 22:03:02 appldev noship $ */
 PROCEDURE FIND_DUPLICATES
(
     X_MATCH_SET_ID          IN  VARCHAR2,
     X_SURNAME               IN  VARCHAR2,
     X_GIVEN_NAMES           IN  VARCHAR2,
     X_BIRTH_DT              IN  DATE,
     X_SEX                   IN  VARCHAR2,
     X_DUP_FOUND             OUT NOCOPY VARCHAR2,
     X_WHERE_CLAUSE          OUT NOCOPY VARCHAR2,
     X_EXACT_PARTIAL          IN OUT NOCOPY VARCHAR2,
     X_PERSON_ID              IN NUMBER DEFAULT NULL,
     X_PREF_ALTERNATE_ID      IN VARCHAR2 DEFAULT NULL
) IS
/*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ssaleem          10-nov-2004     3877652 - Handling Inactive Persons
  ||  asbala          23-SEP-2003     Bug 3130316, Duplicate Person Matching Performance Improvements
  ||  asbala          15-SEP-2003     3049826: Added code to check value of
                                      Profile Option: Duplicate Match Criteria Source Type (Value should be 'MANUAL')
  ||  pkpatel         4-MAY-2003      PKM Issue to use bind variable
  ||  (reverse chronological order - newest change first)
*/

lv_errbuf VARCHAR2(100);
lv_retcode VARCHAR2(1);
l_Select_Clause VARCHAR2(4000);
lv_Do_Partial VARCHAR2(1);
l_Ext_Cursor NUMBER;
lnRows NUMBER(5);
l_where_clause  VARCHAR2(32767) := ' person_id IN ( ';
l_person_id     hz_parties.party_id%TYPE;
l_match_found   BOOLEAN := FALSE;
l_match_set_id  igs_pe_match_sets_all.match_set_id%TYPE;

-- Cursor to check value of Profile Option: Duplicate Match Criteria
  CURSOR  c_match_set_criteria (cp_system_source_type igs_pe_src_types.system_source_type%TYPE,
                                cp_match_set_id igs_pe_match_sets_all.match_set_id%TYPE,
								cp_closed_ind igs_pe_match_sets_all.closed_ind%TYPE) IS
  SELECT match.match_set_id
  FROM igs_pe_match_sets_all match,igs_pe_src_types src
  WHERE src.system_source_type = cp_system_source_type AND
        src.source_type_id = match.source_type_id AND
        match.match_set_id = cp_match_set_id AND
        match.closed_ind = cp_closed_ind;

  -- cursor to populate global variable g_partial_if_null
  CURSOR c_get_partial_if_null(cp_match_set_id igs_pe_match_sets.partial_if_null%TYPE) IS
  SELECT partial_if_null,exclude_inactive_ind
  FROM igs_pe_match_sets
  WHERE match_set_id = cp_match_set_id;

  partial_if_null_rec c_get_partial_if_null%ROWTYPE;

  -- cursor to populate the PL/SQL tables
  CURSOR c_matchset_data_cur(cp_match_set_id igs_pe_mtch_set_data_all.match_set_id%TYPE) IS
  SELECT data_element, drop_if_null, partial_include, exact_include
  FROM igs_pe_mtch_set_data_all
  WHERE match_set_id = cp_match_set_id;

  matchset_data_rec     c_matchset_data_cur%ROWTYPE;
  l_count_exact         NUMBER;
  l_count_partial       NUMBER;
  l_profile_value       VARCHAR2(60);
BEGIN
  -- To check value of Profile : Duplicate Match Criteria and pass appropriate error message
  l_profile_value := fnd_profile.VALUE('IGS_PE_DUP_MATCH_CRITERIA');

  IF l_profile_value IS NULL THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_PE_PROF_DUP_CRTRIA_MANUAL');
    APP_EXCEPTION.RAISE_EXCEPTION;
  ELSE
    OPEN c_match_set_criteria('MANUAL',TO_NUMBER(l_profile_value),'N');
    FETCH c_match_set_criteria INTO l_match_set_id;
      IF c_match_set_criteria%NOTFOUND THEN
        CLOSE c_match_set_criteria;
        FND_MESSAGE.SET_NAME('IGS','IGS_PE_PROF_DUP_CRTRIA_MANUAL');
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    CLOSE c_match_set_criteria;
  END IF;

  Igs_Pe_Identify_Dups.g_match_set_id := x_match_set_id;
  OPEN c_get_partial_if_null(x_match_set_id);
  FETCH c_get_partial_if_null INTO partial_if_null_rec;
  CLOSE c_get_partial_if_null;

  Igs_Pe_Identify_Dups.g_partial_if_null := partial_if_null_rec.partial_if_null;
  Igs_Pe_Identify_Dups.g_exclude_inactive_ind := partial_if_null_rec.exclude_inactive_ind;

  -- Populate the PL/SQL tables and other global variables used for caching :- Bug 3130316
  l_count_exact := 1;
  l_count_partial := 1;
  FOR matchset_data_rec IN c_matchset_data_cur(x_match_set_id) LOOP
     IF matchset_data_rec.data_element NOT IN ('SURNAME','GIVEN_NAME_1_CHAR') THEN
      IF matchset_data_rec.exact_include = 'Y' THEN
        Igs_Pe_Identify_Dups.g_matchset_exact(l_count_exact).data_element := matchset_data_rec.data_element;
        Igs_Pe_Identify_Dups.g_matchset_exact(l_count_exact).drop_if_null := matchset_data_rec.drop_if_null;
        l_count_exact := l_count_exact + 1;
      END IF;
      IF matchset_data_rec.partial_include = 'Y' THEN
        Igs_Pe_Identify_Dups.g_matchset_partial(l_count_partial).data_element := matchset_data_rec.data_element;
        Igs_Pe_Identify_Dups.g_matchset_partial(l_count_partial).drop_if_null := matchset_data_rec.drop_if_null;
        l_count_partial := l_count_partial + 1;
      END IF;
    END IF;
  END LOOP;

  Igs_Pe_Identify_Dups.form_dup_whereclause (
        x_errbuf => lv_errbuf,
        x_retcode => lv_retcode,
        x_match_set_id => x_match_set_id,
        x_match_category => x_exact_partial,
        x_view_name => 'IGS_PE_DUP_MATCHES_P_V',
        x_person_id => x_person_id,
        x_surname => x_Surname,
        x_given_names => x_Given_Names,
        x_birth_dt => x_Birth_Dt,
        x_pref_alternate_id => x_Pref_Alternate_Id,
        x_sex => x_Sex,
        x_select_clause => l_Select_Clause
          );


        --  Run the select clause to find out the duplicate records if the select statement is not null using Dynamic SQL.
  lv_Do_Partial := 'Y';
  IF l_Select_Clause IS NOT NULL AND l_Select_Clause <> 'PARTIAL_MATCH' THEN
    BEGIN
      l_ext_cursor := DBMS_SQL.OPEN_CURSOR;
      fnd_dsql.set_cursor(l_ext_cursor);

      DBMS_SQL.PARSE (l_ext_cursor, l_Select_Clause, DBMS_SQL.V7);
      fnd_dsql.do_binds;

      dbms_sql.define_column(l_ext_cursor, 1, l_person_id);

      lnRows :=  DBMS_SQL.EXECUTE (l_ext_cursor);

      LOOP
        -- fetch a row
        IF dbms_sql.fetch_rows(l_ext_cursor) > 0 THEN
          -- fetch columns from the row and prepare the where clause to pass to the form.
          dbms_sql.column_value(l_ext_cursor, 1, l_person_id);
          l_where_clause := l_where_clause || l_person_id || ',';
          l_match_found  := TRUE;
        ELSE
          EXIT;
        END IF;
      END LOOP;

        -- There are exact matched records.
      IF l_match_found THEN
        X_DUP_FOUND := 'Y';
        X_EXACT_PARTIAL := 'E';
        X_WHERE_CLAUSE :=  RTRIM(l_where_clause,',') || ')';
        RETURN;

      ELSE -- No exact matched records. Do partial match.

        lv_Do_Partial := 'Y';
        l_where_clause  := ' person_id IN ( ';
        l_match_found   := FALSE;
      END IF;

      DBMS_SQL.CLOSE_CURSOR (l_ext_cursor);

    EXCEPTION
      WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(l_Ext_Cursor) THEN
          DBMS_SQL.CLOSE_CURSOR(l_Ext_Cursor);
        END IF;
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','igs_pe_dup_person.find_duplicates'||'-'||SQLERRM);
        APP_EXCEPTION.RAISE_EXCEPTION;
    END;
  END IF;

      -- If the exact selec statement does not return any rows, go for partial match.
  IF lv_Do_Partial = 'Y' THEN
       /*change made for bug number 2158920 */
    x_exact_partial := 'P';

    Igs_Pe_Identify_Dups.form_dup_whereclause (
        x_errbuf => lv_errbuf,
        x_retcode => lv_retcode,
        x_match_set_id => x_match_set_id,
        x_match_category => x_exact_partial,
        x_view_name => 'IGS_PE_DUP_MATCHES_P_V',
        x_person_id => x_person_id,
        x_surname => x_Surname,
        x_given_names => x_Given_Names,
        x_birth_dt => x_Birth_Dt,
        x_pref_alternate_id => x_Pref_Alternate_Id,
        x_sex => x_Sex,
        x_select_clause => l_Select_Clause
        );

      -- Run the select statement using dynamic SQL to find the partial duplicate records.
    IF l_Select_Clause IS NOT NULL THEN
      BEGIN
        l_Ext_Cursor := DBMS_SQL.OPEN_CURSOR;
        fnd_dsql.set_cursor(l_ext_cursor);

        DBMS_SQL.PARSE (l_Ext_Cursor, l_Select_Clause, DBMS_SQL.V7);
        fnd_dsql.do_binds;

        dbms_sql.define_column(l_ext_cursor, 1, l_person_id);

        lnRows := DBMS_SQL.EXECUTE (l_Ext_Cursor);

        LOOP
                          -- fetch a row
        IF dbms_sql.fetch_rows(l_ext_cursor) > 0 THEN

                                -- fetch columns from the row and concatenate to for the where clause to be returned to the form
          dbms_sql.column_value(l_ext_cursor, 1, l_person_id);
          l_where_clause := l_where_clause || l_person_id || ',';
          l_match_found  := TRUE;
        ELSE
          EXIT;
        END IF;
        END LOOP;

        -- There are partial matched records.
        IF l_match_found THEN
          x_dup_found     := 'Y';
          x_exact_partial := 'P';
          x_where_clause  :=  RTRIM(l_where_clause,',')|| ')';  -- SUBSTR(l_where_clause,1,length(l_where_clause)-1);

        ELSE -- There are no matched records

          x_where_clause  := NULL;
          x_exact_partial := NULL;
          x_dup_found     := 'N';
        END IF;

        DBMS_SQL.CLOSE_CURSOR (l_Ext_Cursor);

      EXCEPTION
        WHEN OTHERS THEN
          IF DBMS_SQL.IS_OPEN(l_Ext_Cursor) THEN
            DBMS_SQL.CLOSE_CURSOR(l_Ext_Cursor);
          END IF;
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','igs_pe_dup_person.find_duplicates'||'-'||SQLERRM);
          APP_EXCEPTION.RAISE_EXCEPTION;
      END;
      END IF;
    END IF;
  END FIND_DUPLICATES;
END Igs_Pe_Dup_Person;

/
