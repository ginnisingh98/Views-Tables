--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_009
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_009" AS
/* $Header: IGSAD87B.pls 120.3 2006/03/24 02:34:32 gmaheswa noship $ */

/*************************************
|| Change History
||  who           when        what
|| ssaleem        13_OCT_2003     Bug : 3130316
||                                Logging is modified to include logging mechanism
|| npalanis       22-APR-2003 BUG:2832980 location_id is not selected in form_dup where clause because it is not used any where
||  pkpatel       22-JUN-2001 Bug no.2702536
||                            Added the parameters p_match_ind, p_person_id, p_addr_type and p_person_id_type to IGS_AD_IMP_FIND_DUP_PERSONS
||                            And implemented the new record level duplicate check.
|| gmuralid      4 -DEC-2002  Change by gmuralid, removed reference to table igs_ad_intl_int,
||                            igs_pe_fund_dep_int.Included references to igs_pe_visa_int,
||                            igs_pe_vst_hist_int,igs_pe_passport_int,igs_pe_eit_int
||                            As a part of BUG 2599109, SEVIS Build
||
||  ssawhney   21-may-2002   Bug 2381539, %imp_p% procedures, incorrect ref to variable x_lvcExactSelectClause in case of partial match
||                           because of which it was not going into match at all.
||  pkpatel    30-MAY-2002   Bug 2377580, parameters were missing in the call to Igs_Pe_Identify_Dups.form_dup_whereclause
||  npalanis   5-Jun-2002    Bug 2397849 , The function for match indicator 15 ,16 and 17 are handled.
||  pkpatel    10-OCT-2002   Bug No: 2603065
||                           Increased the size of variable x_lvcExactSelectClause and x_lvcPartialSelectClause from 500 to 2000
||  ssawhney   22-oct-2002   SWS104, Bug 2630860. Introduced validations from making STATISTICS not mandatory.
||                           modified for ACADHONORS.SWS104 obsoleted IGS_AD_REFS_INT
|| sjalasut    31st oct    SWS105 ad_collact table obsoleted
|| sjalasut    Jan 20, 2003 changed the references of IGS_AD_INQ_CHAR_INT to IGS_RC_I_CHAR_INT for RCT101 Build. bug 2664699
|| rrengara    14 Feb 2003  changes for RCT Build. Removed the obsolete table names and replaced the new table names
|| ssawhney    24-feb-2003   REF CUR dup_matches_cur was not being closed for exact match of DUP_MATCHES_P and PP
|| vrathi      26-Jun-2003   Bug 3001974 Added specific messages in duplicate check fiunctions. + sswhney - valriable lenght increased
                             for whereclause execution.
|| asbala      23-SEP-2003     Bug 3130316, Duplicate Person Matching Performance Improvements
|| gmaheswa    9-OCT-2003      Bug 3146324, Match Criteria sets Enhancement
*/

-- constants to replace match indicator values for sql performance tuning
cst_mi_val_11 CONSTANT  VARCHAR2(2) := '11';
cst_mi_val_12 CONSTANT  VARCHAR2(2) := '12';
cst_mi_val_13 CONSTANT  VARCHAR2(2) := '13';
cst_mi_val_14 CONSTANT  VARCHAR2(2) := '14';
cst_mi_val_24 CONSTANT  VARCHAR2(2) := '24';

cst_err_val_1 CONSTANT  VARCHAR2(4) := 'E001';
cst_err_val_2 CONSTANT  VARCHAR2(4) := 'E002';
cst_err_val_3 CONSTANT  VARCHAR2(4) := 'E003';

cst_stat_val_3 CONSTANT  VARCHAR2(2) := '3';

lnOrg_ID  NUMBER := igs_ge_gen_003.get_org_id;
lnParty_Site_ID NUMBER;

  PROCEDURE igs_ad_find_duplicates_imp_p
        (p_d_match_set_id IN NUMBER,
         p_d_interface_id IN NUMBER,
         p_d_batch_id IN NUMBER,
         p_c_addr_type IN VARCHAR2,
         p_c_person_id_type IN VARCHAR2,
         p_person_id   OUT NOCOPY igs_ad_interface.person_id%TYPE,
         p_match_ind   OUT NOCOPY igs_ad_interface.match_ind%TYPE)
  AS
 /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel         10-OCT-2002     Bug NO: 2603065
  ||                                  Increased the size of variable x_lvcExactSelectClause and x_lvcPartialSelectClause from 500 to 2000
  ||  pkpatel         22-JUN-2001     Bug no.2702536
  ||                                  Added the parameters p_match_ind, p_person_id
  ||  pkpatel         4-MAY-2003      Bug 3004858 (PKM Issue to use bind variable)
  ||  (reverse chronological order - newest change first)
  */
  CURSOR imp_person_cur(cp_d_interface_id igs_ad_imp_matches_p_v.interface_id%TYPE) IS
  SELECT *
  FROM   igs_ad_imp_matches_p_v
  WHERE  interface_id = cp_d_interface_id;

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER;

  x_lvcExactSelectClause     VARCHAR2(32000);
  x_lvcPartialSelectClause   VARCHAR2(32000);
  x_match_cnt                NUMBER := 0;

  i NUMBER(3):=0;
  l_rowid VARCHAR2(25);
  l_pk NUMBER(15);
  l_person_id     igs_pe_person.person_id%TYPE;
  l_errbuf VARCHAR2(10);
  l_retcode NUMBER;

  l_cursor_id  NUMBER(15);
  l_cursor_id1  NUMBER(15);
  l_num_of_rows NUMBER(15);
  l_dsql_debug  VARCHAR2(4000);

  BEGIN

   l_prog_label := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_p';
   l_label      := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_p.';
   l_enable_log := igs_ad_imp_001.g_enable_log;

   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

	 IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
	 END IF;

	 l_label := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_p.begin';
	 l_debug_str := 'igs_ad_imp_009.igs_ad_find_duplicates_imp_p';

	 fnd_log.string_with_context( fnd_log.level_procedure,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;


    FOR imp_person_rec IN imp_person_cur(p_d_interface_id) LOOP

      i := i+1;

        -- First call the form_dup_whereclause with Exact match
        --  for that pass x_match_category as 'E'

      Igs_Pe_Identify_Dups.form_dup_whereclause(
                x_errbuf                => l_errbuf,
                x_retcode               => l_retcode,
                x_match_set_id          =>p_d_match_set_id,
                x_match_category        =>'E',
                x_view_name             =>'IGS_PE_DUP_MATCHES_P_V',
                x_surname               =>imp_person_rec.surname,
                x_given_names           =>imp_person_rec.given_names,
                x_pref_alternate_id     =>imp_person_rec.pref_alternate_id,
                x_birth_dt              =>imp_person_rec.birth_dt,
                x_sex                   =>imp_person_rec.sex,
                x_ethnic_origin         =>imp_person_rec.ethnic_origin,
                x_select_clause         => x_lvcExactSelectClause);

                -- The above procedure will return 'PARTIAL_MATCH', if the exact match is not found

      IF x_lvcExactSelectClause <> 'PARTIAL_MATCH' THEN
           -- Open the Dynamic Cursor with the select statement returned for Exact Match

        l_cursor_id := dbms_sql.open_cursor;
        fnd_dsql.set_cursor(l_cursor_id);

        dbms_sql.parse(l_cursor_id, x_lvcExactSelectClause, dbms_sql.native);
        fnd_dsql.do_binds;

        dbms_sql.define_column(l_cursor_id, 1, l_person_id);

        l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);

/* This will print the Dynamic SQL statement prepared. Can be uncommented when testing.*/
            l_dsql_debug := fnd_dsql.get_text(TRUE);

          LOOP
         -- fetch a row
          IF dbms_sql.fetch_rows(l_cursor_id) > 0 THEN
            x_match_cnt := x_match_cnt+1;
            dbms_sql.column_value(l_cursor_id, 1, l_person_id);

            Igs_Ad_Imp_Near_Mtch_Pkg.insert_row
                        (x_rowid =>l_rowid,
                         x_org_id => lnOrg_ID,
                         x_near_mtch_id=>l_pk,
                         x_interface_id=>p_d_interface_id,
                         x_person_id=>l_person_id,
                         x_match_ind=>'E',
                         x_action=>'D',
                         x_addr_type=> p_c_addr_type,
                         x_person_id_type=>p_c_person_id_type,
                         x_match_set_id=>p_d_match_set_id,
                         x_mode =>'I',
                         x_Party_Site_ID => NULL);
                -- fetch columns from the row
          ELSE
            EXIT;
          END IF;
        END LOOP;
        dbms_sql.close_cursor(l_cursor_id);

                        /*If the dynamic Query returns only one row, then Update the
                                  igs_ad_interface_table */

        IF x_match_cnt = 1 THEN  /* Only One Match is Found  Match_Ind 12 is - Match to a Single Person*/
          UPDATE igs_ad_interface
          SET   match_ind = cst_mi_val_12,
               person_id = l_person_id
          WHERE interface_id = imp_person_rec.interface_id;

          p_person_id := l_person_id;
          p_match_ind := '12';
          RETURN;
        ELSIF x_match_cnt > 1 THEN   -- if more than one duplicate is found then update match_ind to 13
                                                     -- 13 -  Match to Multiple Persons
          UPDATE igs_ad_interface
          SET match_ind = cst_mi_val_13,
             ERROR_CODE = cst_err_val_2,
             STATUS = cst_stat_val_3
          WHERE interface_id = imp_person_rec.interface_id;

          p_match_ind := '13';

          IF l_enable_log = 'Y' THEN
    		 igs_ad_imp_001.logerrormessage(p_record => imp_person_rec.interface_id, p_error => 'E002', p_match_ind => '13');
	      END IF;

          RETURN;
        END IF;
      END IF;
                -- If partial Match returns 0 records or the select clause from
                -- form_dup_where cluase is 'PARTIAL_MATCH' then the control come here
      IF x_match_cnt = 0 THEN

                        /* If Exact Match is not found then go for Partial Match . pass the match_category as 'P'*/
        Igs_Pe_Identify_Dups.form_dup_whereclause(
                        x_errbuf                => l_errbuf,
                        x_retcode               => l_retcode,
                        x_match_set_id          =>p_d_match_set_id,
                        x_match_category        =>'P',
                        x_view_name             =>'IGS_PE_DUP_MATCHES_P_V',
                        x_surname               =>imp_person_rec.surname,
                        x_given_names           =>imp_person_rec.given_names,
                        x_pref_alternate_id     =>imp_person_rec.pref_alternate_id,
                        x_birth_dt              =>imp_person_rec.birth_dt,
                        x_sex                   =>imp_person_rec.sex,
                        x_ethnic_origin         =>imp_person_rec.ethnic_origin,
                        x_select_clause         => x_lvcPartialSelectClause);

        IF x_lvcPartialSelectClause IS NOT NULL THEN

                -- Execute the Dynamic SQL
          l_cursor_id1 := dbms_sql.open_cursor;
          fnd_dsql.set_cursor(l_cursor_id1);

          dbms_sql.parse(l_cursor_id1, x_lvcPartialSelectClause, dbms_sql.native);
          fnd_dsql.do_binds;

          dbms_sql.define_column(l_cursor_id1, 1, l_person_id);

          l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id1);

/* This will print the Dynamic SQL statement prepared. Can be uncommented when testing.*/
                                l_dsql_debug := fnd_dsql.get_text(TRUE);

          LOOP
                -- fetch a row
            IF dbms_sql.fetch_rows(l_cursor_id1) > 0 THEN
              x_match_cnt := x_match_cnt+1;
              dbms_sql.column_value(l_cursor_id1, 1, l_person_id);

              Igs_Ad_Imp_Near_Mtch_Pkg.insert_row
                                (x_rowid =>l_rowid,
                                 x_org_id => lnOrg_ID,
                                 x_near_mtch_id=>l_pk,
                                 x_interface_id=>p_d_interface_id,
                                 x_person_id=>l_person_id,
                                 x_match_ind=>'P',
                                 x_action=>'D',
                                 x_addr_type=> p_c_addr_type,
                                 x_person_id_type=>p_c_person_id_type,
                                 x_match_set_id=>p_d_match_set_id,
                                 x_mode =>'R',
                                 x_Party_Site_ID => NULL);
            ELSE
              EXIT;
            END IF;
          END LOOP;

          dbms_sql.close_cursor(l_cursor_id1);
          IF x_match_cnt = 0 THEN  /* Partial match not found */
            UPDATE igs_ad_interface
            SET    match_ind = cst_mi_val_11
            WHERE  interface_id = imp_person_rec.interface_id;
            p_match_ind := '11';
            RETURN;
          ELSE
            UPDATE igs_ad_interface
            SET   match_ind = cst_mi_val_14,
                  ERROR_CODE = cst_err_val_3,
                  STATUS = cst_stat_val_3
            WHERE interface_id = imp_person_rec.interface_id;
            p_match_ind := '14';

	       IF l_enable_log = 'Y' THEN
    		 igs_ad_imp_001.logerrormessage(p_record => imp_person_rec.interface_id, p_error => 'E003', p_match_ind => '14');
	       END IF;

            RETURN;
          END IF;
        END IF;
      END IF;
    END LOOP;
    IF i = 0 THEN
      UPDATE igs_ad_interface
      SET     status = cst_stat_val_3,
              match_ind = cst_mi_val_24,
              ERROR_CODE = cst_err_val_1
      WHERE interface_id = p_d_interface_id;
      p_match_ind := '24';

       IF l_enable_log = 'Y' THEN
   		 igs_ad_imp_001.logerrormessage(p_record => p_d_interface_id, p_error => 'E001', p_match_ind => '24');
       END IF;

    END IF;
  END igs_ad_find_duplicates_imp_p;

  PROCEDURE igs_ad_find_duplicates_imp_pp
        (p_d_match_set_id IN NUMBER,
        p_d_interface_id IN NUMBER,
        p_d_batch_id IN NUMBER,
        p_c_addr_type IN VARCHAR2,
        p_c_person_id_type IN VARCHAR2,
        p_person_id   OUT NOCOPY igs_ad_interface.person_id%TYPE,
        p_match_ind   OUT NOCOPY igs_ad_interface.match_ind%TYPE)
  AS
 /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel          10-OCT-2002    Bug No: 2603065
  ||                                  Increased the size of variable x_lvcExactSelectClause and x_lvcPartialSelectClause from 500 to 2000
  ||  pkpatel         22-JUN-2001     Bug no.2702536
  ||                                  Added the parameters p_match_ind, p_person_id
  ||  pkpatel         4-MAY-2003      Bug 3004858 (PKM Issue to use bind variable)
  ||  (reverse chronological order - newest change first)
  */

    l_prog_label  VARCHAR2(100);
    l_label  VARCHAR2(100);
    l_debug_str VARCHAR2(2000);
    l_enable_log VARCHAR2(1);
    l_request_id NUMBER;

    CURSOR imp_person_cur(cp_d_interface_id igs_ad_imp_matches_pp_v.interface_id%TYPE,
	          cp_c_person_id_type igs_ad_imp_matches_pp_v.person_id_type%TYPE) IS
    SELECT  *
    FROM    igs_ad_imp_matches_pp_v
    WHERE   interface_id = cp_d_interface_id AND
            ( person_id_type = cp_c_person_id_type OR person_id_type IS NULL );

    x_lvcExactSelectClause     VARCHAR2(32000);
    x_lvcPartialSelectClause   VARCHAR2(32000);
    x_match_cnt                NUMBER := 0;
    l_errbuf VARCHAR2(10);
    l_retcode NUMBER;
    l_person_id  igs_pe_person.person_id%TYPE;
    i NUMBER(3):=0;
    l_rowid VARCHAR2(25);
    l_pk NUMBER(15);

    l_cursor_id  NUMBER(15);
    l_cursor_id1  NUMBER(15);
    l_num_of_rows NUMBER(15);
    l_dsql_debug  VARCHAR2(4000);

  BEGIN

    -- Call Log header

    l_prog_label := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_pp';
    l_label      := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_pp.';
    l_enable_log := igs_ad_imp_001.g_enable_log;

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

	 IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
	 END IF;

	 l_label := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_pp.begin';
	 l_debug_str := 'Igs_Ad_Imp_009.igs_ad_find_duplicates_imp_pp';

	 fnd_log.string_with_context( fnd_log.level_procedure,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

    FOR imp_person_rec IN imp_person_cur(p_d_interface_id,p_c_person_id_type) LOOP
      IF ((Igs_Pe_Identify_Dups.g_person_id_type_din = 'N')  AND
         ((imp_person_rec.ALTERNATE_ID IS NULL) OR (imp_person_rec.PERSON_ID_TYPE IS NULL))) THEN
        i:= 0;
      ELSE
        i := i+1;
        Igs_Pe_Identify_Dups.form_dup_whereclause(
                        x_errbuf                => l_errbuf,
                        x_retcode               => l_retcode,
                        x_match_set_id          =>p_d_match_set_id,
                        x_match_category        =>'E',
                        x_view_name             =>'IGS_PE_DUP_MATCHES_PP_V',
                        x_surname               =>imp_person_rec.surname,
                        x_given_names           =>imp_person_rec.given_names,
                        x_pref_alternate_id     =>imp_person_rec.pref_alternate_id,
                        x_birth_dt              =>imp_person_rec.birth_dt,
                        x_sex                   =>imp_person_rec.sex,
                        x_ethnic_origin         =>imp_person_rec.ethnic_origin,
                        x_select_clause         => x_lvcExactSelectClause,
                        x_api_person_id         =>imp_person_rec.alternate_id,
                        x_person_id_type        =>imp_person_rec.person_id_type
                                      );
                -- The above procedure will return 'PARTIAL_MATCH', if the exact match is not found

        IF x_lvcExactSelectClause <> 'PARTIAL_MATCH' THEN

          l_cursor_id := dbms_sql.open_cursor;
          fnd_dsql.set_cursor(l_cursor_id);

          dbms_sql.parse(l_cursor_id, x_lvcExactSelectClause, dbms_sql.native);
          fnd_dsql.do_binds;

          dbms_sql.define_column(l_cursor_id, 1, l_person_id);

          l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);
/* This will print the Dynamic SQL statement prepared. Can be uncommented when testing.
            l_dsql_debug := fnd_dsql.get_text(TRUE);
            Igs_Ad_Imp_001.logDetail('l_dsql_debug :'||l_dsql_debug);
*/
            LOOP
                                  -- fetch a row
              IF dbms_sql.fetch_rows(l_cursor_id) > 0 THEN
                 x_match_cnt := x_match_cnt+1;
                 dbms_sql.column_value(l_cursor_id, 1, l_person_id);

		 /* Insert into igs_ad_imp_near_match, all the duplicate records */
                 Igs_Ad_Imp_Near_Mtch_Pkg.insert_row
                                                (x_rowid =>l_rowid,
                                                 x_Org_ID => lnOrg_ID,
                                                 x_near_mtch_id=>l_pk,
                                                 x_interface_id=>p_d_interface_id,
                                                 x_person_id=> l_person_id,
                                                 x_match_ind=>'E',
                                                 x_action=>'D',
                                                 x_addr_type=>p_c_addr_type,
                                                 x_person_id_type=>p_c_person_id_type,
                                                 x_match_set_id=>p_d_match_set_id,
                                                 x_mode =>'R',
                                                 x_Party_Site_ID => NULL);

               ELSE
                 EXIT;
               END IF;
             END LOOP; /* End Loop for dup_matches_cur */
             dbms_sql.close_cursor(l_cursor_id);
                        /*If the dynamic Query returns only one row, then Update the igs_ad_interface_table */
             IF x_match_cnt = 1 THEN  /* Only One Match is Found */
               UPDATE igs_ad_interface
               SET    match_ind = cst_mi_val_12,
                      person_id = l_person_id
               WHERE  interface_id = imp_person_rec.interface_id;
               p_person_id := l_person_id;
               p_match_ind := '12';
               RETURN;
             ELSIF x_match_cnt > 1 THEN
               UPDATE igs_ad_interface
               SET    match_ind = cst_mi_val_13,
                      error_code = cst_err_val_2,
                      STATUS = cst_stat_val_3
               WHERE  interface_id = imp_person_rec.interface_id;
               p_match_ind := '13';

		IF l_enable_log = 'Y' THEN
   		   igs_ad_imp_001.logerrormessage(p_record => imp_person_rec.interface_id, p_error => 'E002', p_match_ind => '13');
        END IF;

               RETURN;
             END IF;
          END IF;

          IF x_match_cnt = 0 THEN
                /* If Exact Match is not found then go for Partial Match */
            Igs_Pe_Identify_Dups.form_dup_whereclause(
                                x_errbuf                => l_errbuf,
                                x_retcode               => l_retcode,
                                x_match_set_id          =>p_d_match_set_id,
                                x_match_category        =>'P',
                                x_view_name             =>'IGS_PE_DUP_MATCHES_PP_V',
                                x_surname               =>imp_person_rec.surname,
                                x_given_names           =>imp_person_rec.given_names,
                                x_pref_alternate_id     =>imp_person_rec.pref_alternate_id,
                                x_birth_dt              =>imp_person_rec.birth_dt,
                                x_sex                   =>imp_person_rec.sex,
                                x_ethnic_origin         =>imp_person_rec.ethnic_origin,
                                x_api_person_id         =>imp_person_rec.alternate_id,
                                x_person_id_type        =>imp_person_rec.person_id_type,
                                x_select_clause         => x_lvcPartialSelectClause);


            IF x_lvcPartialSelectClause IS NOT NULL THEN

                                /* Exceute the Partial Select Clause */
                                l_cursor_id1 := dbms_sql.open_cursor;
                                fnd_dsql.set_cursor(l_cursor_id1);

                                dbms_sql.parse(l_cursor_id1, x_lvcPartialSelectClause, dbms_sql.native);
                                fnd_dsql.do_binds;

                                dbms_sql.define_column(l_cursor_id1, 1, l_person_id);

                                l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id1);

/* This will print the Dynamic SQL statement prepared. Can be uncommented when testing.
                                l_dsql_debug := fnd_dsql.get_text(TRUE);
                Igs_Ad_Imp_001.logDetail('l_dsql_debug :'||l_dsql_debug);
*/

                        LOOP
                          -- fetch a row
                          IF dbms_sql.fetch_rows(l_cursor_id1) > 0 THEN

                                x_match_cnt := x_match_cnt+1;

                dbms_sql.column_value(l_cursor_id1, 1, l_person_id);

                                        /* Insert into igs_ad_imp_near_match_int, all the duplicate records */
                                        Igs_Ad_Imp_Near_Mtch_Pkg.insert_row
                                                (x_rowid =>l_rowid,
                                                 x_Org_ID => lnOrg_ID,
                                                 x_near_mtch_id=>l_pk,
                                                 x_interface_id=>p_d_interface_id,
                                                 x_person_id=> l_person_id,
                                                 x_match_ind=>'P',
                                                 x_action=>'D',
                                                 x_addr_type=>p_c_addr_type,
                                                 x_person_id_type=>p_c_person_id_type,
                                                 x_match_set_id=>p_d_match_set_id,
                                                 x_mode =>'R',
                                                 x_party_Site_ID => NULL);

                          ELSE
                            EXIT;
                          END IF;

                        END LOOP; /* End Loop for dup_matches_cur */

                        dbms_sql.close_cursor(l_cursor_id1);

                        IF x_match_cnt = 0 THEN  /* No Partial match not found */
                          UPDATE igs_ad_interface
                          SET    match_ind = cst_mi_val_11
                          WHERE  interface_id = imp_person_rec.interface_id;

                          p_match_ind := '11';

                          RETURN;
                        ELSE
                          UPDATE igs_ad_interface
                          SET match_ind = cst_mi_val_14,
                                ERROR_CODE = cst_err_val_3,
                                STATUS = cst_stat_val_3
                          WHERE  interface_id = imp_person_rec.interface_id;

                          p_match_ind := '14';

			  IF l_enable_log = 'Y' THEN
        		 igs_ad_imp_001.logerrormessage(p_record => imp_person_rec.interface_id, p_error => 'E003', p_match_ind => '14');
			  END IF;

                          RETURN;
                        END IF;
                  END IF;
                END IF;
          END IF;
        END LOOP;
        IF i = 0 THEN
          UPDATE igs_ad_interface
          SET   status = cst_stat_val_3,
                match_ind = cst_mi_val_24,
                error_code = cst_err_val_1
          WHERE interface_id = p_d_interface_id;
          p_match_ind := '24';
	  IF l_enable_log = 'Y' THEN
                 --vrathi: Add specific message to log
         Igs_Ad_Imp_001.set_message('IGS_PE_PID_INFO_MISS');
   		 igs_ad_imp_001.logerrormessage(p_record => p_d_interface_id, p_error => 'E001', p_match_ind => '24');
	  END IF;
   END IF;
END igs_ad_find_duplicates_imp_pp;

PROCEDURE igs_ad_find_duplicates_imp_pa
        (p_d_match_set_id IN NUMBER,
        p_d_interface_id IN NUMBER,
        p_d_batch_id IN NUMBER,
        p_c_addr_type IN VARCHAR2,
        p_c_person_id_type IN VARCHAR2,
    p_person_id   OUT NOCOPY igs_ad_interface.person_id%TYPE,
    p_match_ind   OUT NOCOPY igs_ad_interface.match_ind%TYPE) AS

  /*
  ||  Created By : pkpatel
  ||  Created On : 10-DEC-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pkpatel          14-MAY-2002    Bug No: 2373468
  ||                                  Removed the CLOSE imp_person_cur inside the FOR LOOP.
  ||  ssawhney         21 may         Bug 2381539, incorrect variables usages with dup match check
  ||  pkpatel          30-MAY-2002    Bug 2377580, The addr_type was added in the WHERE clause of CURSOR imp_person_cur
  ||                                  The parameter ethnic_origin was passed in the call to the procedure Igs_Pe_Identify_Dups.form_dup_whereclause
  ||  pkpatel          10-OCT-2002    Bug No: 2603065
  ||                                  Increased the size of variable x_lvcExactSelectClause and x_lvcPartialSelectClause from 500 to 2000
  ||  pkpatel         22-JUN-2001     Bug no.2702536
  ||                                  Added the parameters p_match_ind, p_person_id
  ||  pkpatel         4-MAY-2003      Bug 3004858 (PKM Issue to use bind variable)
  */


	l_prog_label  VARCHAR2(100);
	l_label  VARCHAR2(100);
	l_debug_str VARCHAR2(2000);
	l_enable_log VARCHAR2(1);
	l_request_id NUMBER;

        CURSOR imp_person_cur(cp_d_interface_id igs_ad_imp_matches_pa_v.interface_id%TYPE,
	                      cp_c_addr_type igs_ad_imp_matches_pa_v.addr_type%TYPE)
        IS
        SELECT *
        FROM   igs_ad_imp_matches_pa_v
        WHERE  interface_id = cp_d_interface_id
        AND
        ( addr_type = cp_c_addr_type OR addr_type IS NULL OR Igs_Pe_Identify_Dups.g_primary_addr_flag = 'Y');


	CURSOR party_site_cur(cp_person_id igs_pe_person.person_id%TYPE,
	             cp_addr_type igs_ad_imp_matches_pa_v.addr_type%TYPE) IS
	SELECT PS.party_site_id
	FROM hz_party_sites PS,hz_party_site_uses PSU
	WHERE PS.party_site_id = PSU.party_site_id AND
	PS.party_id = cp_person_id AND
	PSU.site_use_type = cp_addr_type;

        CURSOR prim_party_site_cur(cp_person_id igs_pe_person.person_id%TYPE) IS
	SELECT PS.party_site_id
	FROM hz_party_sites PS
	WHERE PS.party_id = cp_person_id AND
	PS.identifying_address_flag = 'Y';

	 x_lvcExactSelectClause     VARCHAR2(32000);
	 x_lvcPartialSelectClause   VARCHAR2(32000);
	 x_match_cnt                NUMBER := 0;
	 l_errbuf VARCHAR2(10);
	 l_retcode NUMBER;
	 l_person_id  igs_pe_person.person_id%TYPE;
	 i NUMBER(3):=0;
	 l_rowid VARCHAR2(25);
	 l_pk NUMBER(15);

     l_cursor_id  NUMBER(15);
     l_cursor_id1  NUMBER(15);
     l_num_of_rows NUMBER(15);
     l_dsql_debug  VARCHAR2(4000);
     l_view_passed VARCHAR2(50);
BEGIN
    -- Call Log header

	l_prog_label := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_pa';
        l_label      := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_pa.';
        l_enable_log := igs_ad_imp_001.g_enable_log;

	 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_pa.begin';
		 l_debug_str := 'Igs_Ad_Imp_009.igs_ad_find_duplicates_imp_pa';

		 fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	 END IF;


        IF (Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N') THEN
	    l_view_passed := 'IGS_PE_DUP_MATCHES_PA_V';
	ELSE
	    l_view_passed := 'IGS_PE_DUP_MATCHES_PRIM_PA_V';
	END IF;

        FOR imp_person_rec IN imp_person_cur(p_d_interface_id,p_c_addr_type) LOOP

          IF ((Igs_Pe_Identify_Dups.g_addr_type_din = 'N' AND Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N')
	     AND((imp_person_rec.COUNTRY IS NULL) OR (imp_person_rec.ADDR_TYPE IS NULL)))-- new code
            THEN
	      i:= 0;
	  ELSE
            i := i+1;
	    Igs_Pe_Identify_Dups.form_dup_whereclause(
                        x_errbuf                => l_errbuf,
                        x_retcode               => l_retcode,
                        x_match_set_id          =>p_d_match_set_id,
                        x_match_category        =>'E',
                        x_view_name             =>l_view_passed,
                        x_surname               =>imp_person_rec.surname,
                        x_given_names           =>imp_person_rec.given_names,
                        x_pref_alternate_id     =>imp_person_rec.pref_alternate_id,
                        x_addr_line_1           =>imp_person_rec.addr_line_1,
                        x_addr_line_2           =>imp_person_rec.addr_line_2,
                        x_addr_line_3           =>imp_person_rec.addr_line_3,
                        x_addr_line_4           =>imp_person_rec.addr_line_4,
                        x_birth_dt              =>imp_person_rec.birth_dt,
                        x_sex                   =>imp_person_rec.sex,
                        x_ethnic_origin         =>imp_person_rec.ethnic_origin,
                        x_select_clause         => x_lvcExactSelectClause,
                        x_addr_type             =>imp_person_rec.addr_type,
                        x_city                  =>imp_person_rec.city,
                        x_state                 =>imp_person_rec.state,
                        x_province              =>imp_person_rec.province,
                        x_county                =>imp_person_rec.county,
                        x_country               =>imp_person_rec.country,
                        x_postcode              =>imp_person_rec.postcode
                        );

                IF x_lvcExactSelectClause <> 'PARTIAL_MATCH' THEN
		  l_cursor_id := dbms_sql.open_cursor;
                  fnd_dsql.set_cursor(l_cursor_id);

                  dbms_sql.parse(l_cursor_id, x_lvcExactSelectClause, dbms_sql.native);
                  fnd_dsql.do_binds;

                  dbms_sql.define_column(l_cursor_id, 1, l_person_id);

                  l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);
/* This will print the Dynamic SQL statement prepared. Can be uncommented when testing.
                                l_dsql_debug := fnd_dsql.get_text(TRUE);
                Igs_Ad_Imp_001.logDetail('l_dsql_debug :'||l_dsql_debug);
*/
                        LOOP
                          -- fetch a row
                          IF dbms_sql.fetch_rows(l_cursor_id) > 0 THEN
                            x_match_cnt := x_match_cnt+1;
                            dbms_sql.column_value(l_cursor_id, 1, l_person_id);

				IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
                                   FOR temp_cur IN Party_Site_Cur(l_person_ID,p_c_addr_type) LOOP
                                         lnParty_Site_ID := temp_cur.Party_Site_ID;
                                   END LOOP;
                                ELSIF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'Y' THEN
                                   FOR temp_cur IN prim_Party_Site_Cur(l_person_ID) LOOP
                                         lnParty_Site_ID := temp_cur.Party_Site_ID;
                                   END LOOP;
				END IF;


                                /* Insert into igs_ad_imp_near_match, all the duplicate records */
                                Igs_Ad_Imp_Near_Mtch_Pkg.insert_row
                                        (x_rowid =>l_rowid,
                                         x_Org_ID => lnOrg_ID,
                                         x_near_mtch_id=>l_pk,
                                         x_interface_id=>p_d_interface_id,
                                         x_person_id=>l_person_id,
                                         x_match_ind=>'E',
                                         x_action=>'D',
                                         x_addr_type=>p_c_addr_type,
                                         x_person_id_type=>p_c_person_id_type,
                                         x_match_set_id=>p_d_match_set_id,
                                         x_mode =>'R',
                                         x_party_SITE_ID => lnParty_Site_ID);

                  ELSE
                        EXIT;
                  END IF;
        END LOOP; /* End Loop for dup_matches_cur */
        dbms_sql.close_cursor(l_cursor_id);

                        /*If the dynamic Query returns only one row, then Update the igs_ad_interface_table */
                        IF x_match_cnt = 1 THEN  /* Only One Match is Found */
                                UPDATE igs_ad_interface
                                SET    match_ind = cst_mi_val_12,
                                       person_id = l_person_id
                                WHERE  interface_id = imp_person_rec.interface_id;

                p_person_id := l_person_id;
                p_match_ind := '12';
                                RETURN;

                        ELSIF x_match_cnt > 1 THEN
                                UPDATE igs_ad_interface
                                SET match_ind = cst_mi_val_13,
                                        error_code = cst_err_val_2,
                                        STATUS = cst_stat_val_3
                                WHERE interface_id = imp_person_rec.interface_id;

                p_match_ind := '13';

                	   IF l_enable_log = 'Y' THEN
                		 igs_ad_imp_001.logerrormessage(p_record => imp_person_rec.interface_id, p_error => 'E002', p_match_ind => '13');
        		       END IF;


                                RETURN;
                        END IF;
                END IF;

                IF x_match_cnt = 0 THEN
                        /* If Exact Match is not found then go for Partial Match */
                        Igs_Pe_Identify_Dups.form_dup_whereclause(
                                x_errbuf                => l_errbuf,
                                x_retcode               => l_retcode,
                                x_match_set_id          =>p_d_match_set_id,
                                x_match_category        =>'P',  -- bug  Bug 2381539, it was being passed as E
                                x_view_name             =>l_view_passed,
                                x_surname               =>imp_person_rec.surname,
                                x_given_names           =>imp_person_rec.given_names,
                                x_pref_alternate_id     =>imp_person_rec.pref_alternate_id,
                                x_birth_dt              =>imp_person_rec.birth_dt,
                                x_sex                   =>imp_person_rec.sex,
                                x_ethnic_origin         =>imp_person_rec.ethnic_origin,
                                x_select_clause         => x_lvcPartialSelectClause,  -- bug  Bug 2381539, it was being taken as exactselect
                                x_addr_type             =>imp_person_rec.addr_type,
                                x_addr_line_1           =>imp_person_rec.addr_line_1,
                                x_addr_line_2           =>imp_person_rec.addr_line_2,
                                x_addr_line_3           =>imp_person_rec.addr_line_3,
                                x_addr_line_4           =>imp_person_rec.addr_line_4,
                                x_city                  =>imp_person_rec.city,
                                x_state                 =>imp_person_rec.state,
                                x_province              =>imp_person_rec.province,
                                x_county                =>imp_person_rec.county,
                                x_country               =>imp_person_rec.country,
                                x_postcode              =>imp_person_rec.postcode
                               );

                IF x_lvcPartialSelectClause IS NOT NULL THEN

                                        /* Execute the Partial Select Clause */
                        l_cursor_id1 := dbms_sql.open_cursor;
                                fnd_dsql.set_cursor(l_cursor_id1);

                                dbms_sql.parse(l_cursor_id1, x_lvcPartialSelectClause, dbms_sql.native);
                                fnd_dsql.do_binds;

                                dbms_sql.define_column(l_cursor_id1, 1, l_person_id);

                                l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id1);

/* This will print the Dynamic SQL statement prepared. Can be uncommented when testing.
                                l_dsql_debug := fnd_dsql.get_text(TRUE);
                Igs_Ad_Imp_001.logDetail('l_dsql_debug :'||l_dsql_debug);
*/
                        LOOP
                          -- fetch a row
                          IF dbms_sql.fetch_rows(l_cursor_id1) > 0 THEN

                                        x_match_cnt := x_match_cnt+1;

                                        dbms_sql.column_value(l_cursor_id1, 1, l_person_id);

                                        --Get Party_Site_ID From the Cursor
                                        IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
                                           FOR temp_cur IN Party_Site_Cur(l_person_id,p_c_addr_type) LOOP
                                              lnParty_Site_ID := temp_cur.Party_Site_ID;
                                           END LOOP;
                                        ELSIF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'Y' THEN
                                           FOR temp_cur IN prim_Party_Site_Cur(l_person_id) LOOP
                                              lnParty_Site_ID := temp_cur.Party_Site_ID;
                                           END LOOP;
				        END IF;

                                        /* Insert into igs_ad_imp_near_match_int, all the duplicate records */
                                        Igs_Ad_Imp_Near_Mtch_Pkg.insert_row
                                                (x_rowid =>l_rowid,
                                                 x_Org_ID => lnOrg_ID,
                                                 x_near_mtch_id=>l_pk,
                                                 x_interface_id=>p_d_interface_id,
                                                 x_person_id=>l_person_id,
                                                 x_match_ind=>'P',
                                                 x_action=>'D',
                                                 x_addr_type=>p_c_addr_type,
                                                 x_person_id_type=>p_c_person_id_type,
                                                 x_match_set_id=>p_d_match_set_id,
                                                 x_mode =>'R',
                                                 x_party_Site_ID => lnParty_Site_ID);

                          ELSE
                                EXIT;
                          END IF;

                 END LOOP; /* End Loop for dup_matches_cur */

                       dbms_sql.close_cursor(l_cursor_id1);

                          IF x_match_cnt = 0 THEN  /* No Partial match not found */
                                        UPDATE igs_ad_interface
                                        SET    match_ind = cst_mi_val_11
                                        WHERE  interface_id = imp_person_rec.interface_id;

                      p_match_ind := '11';

                      RETURN;
                                 ELSE
                                        UPDATE igs_ad_interface
                                        SET match_ind = '14',
                                                ERROR_CODE = 'E003',
                                                STATUS = '3'
                                        WHERE interface_id = imp_person_rec.interface_id;

                    p_match_ind := '14';

		       IF l_enable_log = 'Y' THEN
        		 igs_ad_imp_001.logerrormessage(p_record => imp_person_rec.interface_id, p_error => 'E003', p_match_ind => '14');
		       END IF;

                                        RETURN;
                                END IF;
                        END IF;
                END IF;
     END IF;
        END LOOP;

        IF i = 0 THEN
                UPDATE igs_ad_interface
                SET     status = '3',
                    match_ind = '24',
                        error_code = 'E001'
                WHERE interface_id = p_d_interface_id;

                p_match_ind := '24';

	       IF l_enable_log = 'Y' THEN
                --vrathi: Add specific message to log
             Igs_Ad_Imp_001.set_message('IGS_PE_ADDR_INFO_MISS');
    		 igs_ad_imp_001.logerrormessage(p_record => p_d_interface_id, p_error => 'E001', p_match_ind => '24');
	       END IF;

        END IF;

END igs_ad_find_duplicates_imp_pa;

PROCEDURE igs_ad_find_duplicates_imp_ppa
        (p_d_match_set_id IN NUMBER,
        p_d_interface_id IN NUMBER,
        p_d_batch_id IN NUMBER,
        p_c_addr_type IN VARCHAR2,
        p_c_person_id_type IN VARCHAR2,
    p_person_id   OUT NOCOPY igs_ad_interface.person_id%TYPE,
    p_match_ind   OUT NOCOPY igs_ad_interface.match_ind%TYPE)
AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 10-DEC-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pkpatel          30-MAY-2002    Bug 2377580, The parameters x_person_id_type,x_api_person_id were passed in the call
  ||                                               to the procedure Igs_Pe_Identify_Dups.form_dup_whereclause
  ||  pkpatel          10-OCT-2002    Bug No: 2603065
  ||                                  Increased the size of variable x_lvcExactSelectClause and x_lvcPartialSelectClause from 500 to 2000
  ||  pkpatel         22-JUN-2001     Bug no.2702536
  ||                                  Added the parameters p_match_ind, p_person_id
  ||  pkpatel         4-MAY-2003      Bug 3004858 (PKM Issue to use bind variable)
  ||  gmaheswa	      24-March-2006   Bug 4218763 Modified imp_person_cur to condsider Igs_Pe_Identify_Dups.g_primary_addr_flag = 'Y' condition.
  */


         l_prog_label  VARCHAR2(100);
         l_label  VARCHAR2(100);
         l_debug_str VARCHAR2(2000);
         l_enable_log VARCHAR2(1);
         l_request_id NUMBER;

        CURSOR imp_person_cur(cp_d_interface_id igs_ad_imp_matches_ppa_v.interface_id%TYPE,
                          cp_c_addr_type igs_ad_imp_matches_ppa_v.addr_type%TYPE,
			  cp_c_person_id_type igs_ad_imp_matches_ppa_v.person_id_type%TYPE )IS
        SELECT *
        FROM   igs_ad_imp_matches_ppa_v
        WHERE interface_id = cp_d_interface_id
         AND (addr_type = cp_c_addr_type OR addr_type IS NULL OR Igs_Pe_Identify_Dups.g_primary_addr_flag = 'Y')
         AND (person_id_type = cp_c_person_id_type OR person_id_type IS NULL);


	CURSOR party_site_cur(cp_person_id igs_pe_person.person_id%TYPE,
	             cp_addr_type igs_ad_imp_matches_pa_v.addr_type%TYPE) IS
	SELECT PS.party_site_id
	FROM hz_party_sites PS,hz_party_site_uses PSU
	WHERE PS.party_site_id = PSU.party_site_id AND
	PS.party_id = cp_person_id AND
	PSU.site_use_type = cp_addr_type;

        CURSOR prim_party_site_cur(cp_person_id igs_pe_person.person_id%TYPE) IS
	SELECT PS.party_site_id
	FROM hz_party_sites PS
	WHERE PS.party_id = cp_person_id AND
	PS.identifying_address_flag = 'Y';

	 x_match_cnt                NUMBER := 0;
         l_errbuf VARCHAR2(10);
         l_retcode NUMBER;
         x_lvcExactSelectClause     VARCHAR2(32000);
         x_lvcPartialSelectClause   VARCHAR2(32000);
         l_person_id IGS_PE_PERSON.PERSON_ID%TYPE;
         i NUMBER(3):=0;
         l_rowid VARCHAR2(25);
         l_pk NUMBER(15);

     l_cursor_id  NUMBER(15);
     l_cursor_id1  NUMBER(15);
     l_num_of_rows NUMBER(15);
     l_dsql_debug  VARCHAR2(4000);
     l_view_passed VARCHAR2(50);
BEGIN

    -- Call Log header

      l_prog_label := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_ppa';
      l_label      := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_ppa.';
      l_enable_log := igs_ad_imp_001.g_enable_log;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_009.igs_ad_find_duplicates_imp_ppa.begin';
		 l_debug_str := 'Igs_Ad_Imp_009.igs_ad_find_duplicates_imp_ppa';

		 fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

      IF (Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N')THEN
         l_view_passed := 'IGS_PE_DUP_MATCHES_PPA_V';
      ELSE
	 l_view_passed := 'IGS_PE_DUP_MATCHES_PRIM_PPA_V';
      END IF;

      FOR imp_person_rec IN imp_person_cur(p_d_interface_id,p_c_addr_type,p_c_person_id_type) LOOP

       IF ((Igs_Pe_Identify_Dups.g_addr_type_din = 'N' AND
            Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N')AND
          ((imp_person_rec.COUNTRY IS NULL) OR
          (imp_person_rec.ADDR_TYPE IS NULL))) OR
         ((Igs_Pe_Identify_Dups.g_person_id_type_din = 'N')  AND
         ((imp_person_rec.ALTERNATE_ID IS NULL)
         OR (imp_person_rec.PERSON_ID_TYPE IS NULL)))

       THEN
                i:= 0;
       ELSE

                i := i+1;
                Igs_Pe_Identify_Dups.form_dup_whereclause(
                        x_errbuf                => l_errbuf,
                        x_retcode               => l_retcode,
                        x_match_set_id          =>p_d_match_set_id,
                        x_match_category        =>'E',
                        x_view_name             => l_view_passed,
                        x_surname               =>imp_person_rec.surname,
                        x_given_names           =>imp_person_rec.given_names,
                        x_pref_alternate_id     =>imp_person_rec.pref_alternate_id,
                        x_person_id_type        =>imp_person_rec.person_id_type,
                        x_api_person_id         =>imp_person_rec.alternate_id,
                        x_addr_line_1           =>imp_person_rec.addr_line_1,
                        x_addr_line_2           =>imp_person_rec.addr_line_2,
                        x_addr_line_3           =>imp_person_rec.addr_line_3,
                        x_addr_line_4           =>imp_person_rec.addr_line_4,
                        x_birth_dt              =>imp_person_rec.birth_dt,
                        x_sex                   =>imp_person_rec.sex,
                        x_ethnic_origin         =>imp_person_rec.ethnic_origin,
                        x_select_clause         =>x_lvcExactSelectClause,
                        x_addr_type             =>imp_person_rec.addr_type,
                        x_city                  =>imp_person_rec.city,
                        x_state                 =>imp_person_rec.state,
                        x_province              =>imp_person_rec.province,
                        x_county                =>imp_person_rec.county,
                        x_country               =>imp_person_rec.country,
                        x_postcode              =>imp_person_rec.postcode
                     );

                IF x_lvcExactSelectClause <> 'PARTIAL_MATCH' THEN
                        l_cursor_id := dbms_sql.open_cursor;
            fnd_dsql.set_cursor(l_cursor_id);

                        dbms_sql.parse(l_cursor_id, x_lvcExactSelectClause, dbms_sql.native);
            fnd_dsql.do_binds;

            dbms_sql.define_column(l_cursor_id, 1, l_person_id);

            l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);
/* This will print the Dynamic SQL statement prepared. Can be uncommented when testing.
                                l_dsql_debug := fnd_dsql.get_text(TRUE);
                Igs_Ad_Imp_001.logDetail('l_dsql_debug :'||l_dsql_debug);
*/
                        LOOP
                          -- fetch a row
                          IF dbms_sql.fetch_rows(l_cursor_id) > 0 THEN

                                x_match_cnt := x_match_cnt+1;

                dbms_sql.column_value(l_cursor_id, 1, l_person_id);

                                --Get Party_Site_ID From the Cursor based on primary address indicator
				IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
                                   FOR temp_cur IN Party_Site_Cur(l_person_ID,p_c_addr_type) LOOP
                                         lnParty_Site_ID := temp_cur.Party_Site_ID;
                                   END LOOP;
                                ELSIF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'Y' THEN
                                   FOR temp_cur IN prim_Party_Site_Cur(l_person_ID) LOOP
                                         lnParty_Site_ID := temp_cur.Party_Site_ID;
                                   END LOOP;
				END IF;

                                /* Insert into igs_ad_imp_near_match, all the duplicate records */
                                Igs_Ad_Imp_Near_Mtch_Pkg.insert_row
                                        (x_rowid =>l_rowid,
                                         x_Org_ID => lnOrg_ID,
                                         x_near_mtch_id=>l_pk,
                                         x_interface_id=>p_d_interface_id,
                                         x_person_id=>l_person_id,
                                         x_match_ind=>'E',
                                         x_action=>'D',
                                         x_addr_type=>p_c_addr_type,
                                         x_person_id_type=>p_c_person_id_type,
                                         x_match_set_id=>p_d_match_set_id,
                                         x_mode =>'R',
                                         x_party_Site_ID => lnParty_Site_ID);

                          ELSE
                                EXIT;
                          END IF;
                END LOOP; /* End Loop for dup_matches_cur */
               dbms_sql.close_cursor(l_cursor_id);

                     /*If the dynamic Query returns only one row, then Update the igs_ad_interface_table */
                        IF x_match_cnt = 1 THEN  /* Only One Match is Found */

                                UPDATE igs_ad_interface
                                SET    match_ind = cst_mi_val_12,
                                       person_id = l_person_id
                                WHERE  interface_id = imp_person_rec.interface_id;

                p_person_id := l_person_id;
                p_match_ind := '12';

                                RETURN;
                        ELSIF x_match_cnt > 1 THEN
                                UPDATE igs_ad_interface
                                SET match_ind = '13',
                                        ERROR_CODE = 'E002',
                                        STATUS = '3'
                                WHERE interface_id = imp_person_rec.interface_id;

                p_match_ind := '13';

		       IF l_enable_log = 'Y' THEN
        		 igs_ad_imp_001.logerrormessage(p_record => imp_person_rec.interface_id, p_error => 'E002', p_match_ind => '13');
		       END IF;

                                RETURN;
                        END IF;
                END IF;
                IF x_match_cnt = 0 THEN
                        /* If Exact Match is not found then go for Partial Match */

            -- Bug 2377580, the parameters x_person_id_type and x_api_person_id were added
                        Igs_Pe_Identify_Dups.form_dup_whereclause(
                                x_errbuf                => l_errbuf,
                                x_retcode               => l_retcode,
                                x_match_set_id          =>p_d_match_set_id,
                                x_match_category        =>'P', -- bug  Bug 2381539, this was being passed as E.
                                x_view_name             =>l_view_passed,
                                x_surname               =>imp_person_rec.surname,
                                x_given_names           =>imp_person_rec.given_names,
                                x_pref_alternate_id     =>imp_person_rec.pref_alternate_id,
                                x_birth_dt              =>imp_person_rec.birth_dt,
                                x_sex                   =>imp_person_rec.sex,
                                x_person_id_type        =>imp_person_rec.person_id_type,
                                x_api_person_id         =>imp_person_rec.alternate_id,
                                x_ethnic_origin         =>imp_person_rec.ethnic_origin,
                                x_select_clause         =>x_lvcPartialSelectClause,  -- bug  Bug 2381539, it was being taken as exactselect
                                x_addr_type             =>imp_person_rec.addr_type,
                                x_addr_line_1           =>imp_person_rec.addr_line_1,
                                x_addr_line_2           =>imp_person_rec.addr_line_2,
                                x_addr_line_3           =>imp_person_rec.addr_line_3,
                                x_addr_line_4           =>imp_person_rec.addr_line_4,
                                x_city                  =>imp_person_rec.city,
                                x_state                 =>imp_person_rec.state,
                                x_province              =>imp_person_rec.province,
                                x_county                =>imp_person_rec.county,
                                x_country               =>imp_person_rec.country,
                                x_postcode              =>imp_person_rec.postcode
                                                              );

             IF x_lvcPartialSelectClause IS NOT NULL THEN
                                /* Exceute the Partial Select Clause */
                                l_cursor_id1 := dbms_sql.open_cursor;
                                fnd_dsql.set_cursor(l_cursor_id1);

                                dbms_sql.parse(l_cursor_id1, x_lvcPartialSelectClause, dbms_sql.native);
                                fnd_dsql.do_binds;

                                dbms_sql.define_column(l_cursor_id1, 1, l_person_id);

                                l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id1);

/* This will print the Dynamic SQL statement prepared. Can be uncommented when testing.
                                l_dsql_debug := fnd_dsql.get_text(TRUE);
                Igs_Ad_Imp_001.logDetail('l_dsql_debug :'||l_dsql_debug);
*/
                        LOOP
                          -- fetch a row
                          IF dbms_sql.fetch_rows(l_cursor_id1) > 0 THEN

                                        x_match_cnt := x_match_cnt+1;

                                        dbms_sql.column_value(l_cursor_id1, 1, l_person_id);

                                        --Get Party_Site_ID From the Cursor Based on primary address indicator
                                        IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
                                            FOR temp_cur IN Party_Site_Cur(l_person_ID,p_c_addr_type) LOOP
                                               lnParty_Site_ID := temp_cur.Party_Site_ID;
                                            END LOOP;
                                        ELSIF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'Y' THEN
                                            FOR temp_cur IN prim_Party_Site_Cur(l_person_ID) LOOP
                                               lnParty_Site_ID := temp_cur.Party_Site_ID;
                                            END LOOP;
				        END IF;

					Igs_Ad_Imp_Near_Mtch_Pkg.insert_row
                                                (x_rowid =>l_rowid,
                                                x_Org_ID => lnOrg_ID,
                                                x_near_mtch_id=>l_pk,
                                                x_interface_id=>p_d_interface_id,
                                                x_person_id=>l_person_id,
                                                x_match_ind=>'P',
                                                x_action=>'D',
                                                x_addr_type=>p_c_addr_type,
                                                x_person_id_type=>p_c_person_id_type,
                                                x_match_set_id=>p_d_match_set_id,
                                                x_mode =>'R',
                                                x_party_Site_ID => lnParty_Site_ID );
                          ELSE
                                EXIT;
                          END IF;
                        END LOOP; /* End Loop for dup_matches_cur */

               dbms_sql.close_cursor(l_cursor_id1);

                                IF x_match_cnt = 0 THEN  /* No Partial match not found */
                                        UPDATE igs_ad_interface
                                        SET   match_ind = cst_mi_val_11
                                        WHERE interface_id = imp_person_rec.interface_id;

                    p_match_ind := '11';

                            RETURN;
                                ELSE
                                        UPDATE igs_ad_interface
                                        SET match_ind = cst_mi_val_14,
                                                ERROR_CODE = cst_err_val_3,
                                                STATUS = cst_stat_val_3
                                        WHERE interface_id = imp_person_rec.interface_id;

                                    p_match_ind := '14';

			       IF l_enable_log = 'Y' THEN
            		  igs_ad_imp_001.logerrormessage(p_record => imp_person_rec.interface_id, p_error => 'E003', p_match_ind => '14');
			       END IF;

                                        RETURN;
                                END IF;
                        END IF;
                END IF;
          END IF;
        END LOOP;
        IF i = 0 THEN
                UPDATE igs_ad_interface
                SET     status = cst_stat_val_3,
                    match_ind = cst_mi_val_24,
                        error_code = cst_err_val_1
                WHERE interface_id = p_d_interface_id;

                p_match_ind := '24';
                --vrathi: Add specific message to log

  	        IF l_enable_log = 'Y' THEN
              Igs_Ad_Imp_001.set_message('IGS_PE_ADDR_PID_MISS');
      		  igs_ad_imp_001.logerrormessage(p_record => p_d_interface_id, p_error => 'E001', p_match_ind => '24');
             END IF;
        END IF;

END igs_ad_find_duplicates_imp_ppa;

PROCEDURE igs_ad_imp_find_dup_persons
        (p_d_batch_id IN NUMBER,
         p_d_source_type_id IN NUMBER,
         p_d_match_set_id IN NUMBER,
         p_interface_id   IN igs_ad_interface.interface_id%TYPE,
         p_match_ind      IN OUT  NOCOPY igs_ad_interface.match_ind%TYPE,
         p_person_id      OUT     NOCOPY igs_ad_interface.person_id%TYPE,
         p_addr_type      IN igs_pe_mtch_set_data.VALUE%TYPE,
         p_person_id_type IN igs_pe_mtch_set_data.VALUE%TYPE) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 10-DEC-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pkpatel         30-MAY-2002    Bug 2377580, The parameters x_person_id_type,x_api_person_id were passed in the call
  ||                                               to the procedure Igs_Pe_Identify_Dups.form_dup_whereclause
  ||  pkpatel         10-OCT-2002    Bug No: 2603065
  ||                                  Increased the size of variable x_lvcExactSelectClause and x_lvcPartialSelectClause from 500 to 2000
  ||  pkpatel         22-JUN-2001     Bug no.2702536
  ||                                  Added the parameters p_match_ind, p_person_id
  ||  pkpatel         22-JUN-2001    Bug no.2702536
  ||                                 Added the parameters p_match_ind, p_person_id, p_addr_type and p_person_id_type.
  ||                                 Implemented the new record level duplicate check.
  ||  asbala          23-SEP-2003     Bug 3130316, Duplicate Person Matching Performance Improvements
                                     Calling the logic to DELETE from igs_ad_near_mtch for the interface ids at one shot.
  */

	l_prog_label  VARCHAR2(100);
	l_label  VARCHAR2(100);
	l_debug_str VARCHAR2(2000);
	l_enable_log VARCHAR2(1);
	l_request_id NUMBER;

        -- ssawhney SWS104, check for ethnic origin if it exists in the matchset.
        CURSOR c_stat_data_element(cp_d_match_set_id igs_pe_mtch_set_data.match_set_id%TYPE,
	                               cp_lookup_code igs_pe_mtch_set_data.data_element%TYPE,
								   cp_din VARCHAR2)
		IS
        SELECT md.exact_include
    	FROM igs_pe_mtch_set_data md
        WHERE md.match_set_id = cp_d_match_set_id
        AND   md.data_element = cp_lookup_code
		AND   md.drop_if_null = cp_din;

        CURSOR c_stat_data_exists (cp_interface_id IGS_AD_INTERFACE.INTERFACE_ID%TYPE,
	                           cp_status IGS_AD_INTERFACE.STATUS%TYPE) IS
        SELECT 'X'
	    FROM igs_ad_stat_int
        WHERE   interface_id = cp_interface_id AND
                status = cp_status;

        stat_data_element_rec   c_stat_data_element%ROWTYPE;
        stat_data_exists_rec    c_stat_data_exists%ROWTYPE;

BEGIN

    -- Call Log header

        l_prog_label := 'igs.plsql.igs_ad_imp_009.igs_ad_imp_find_dup_persons';
        l_label      := 'igs.plsql.igs_ad_imp_009.igs_ad_imp_find_dup_persons.';
        l_enable_log := igs_ad_imp_001.g_enable_log;

        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_009.igs_ad_find_dup_persons.begin';
		 l_debug_str := 'Igs_Ad_Imp_009.igs_ad_find_dup_persons for Interface ID: '||p_interface_id||' with Address type: '||p_addr_type
		 ||' Person ID Type: '||p_person_id_type;

		 fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;

        IF p_match_ind IN ('15','16','17') THEN
          NULL;
    	ELSE
		--ssawhney SWS104, remove statistics to be mandatory.
          OPEN c_stat_data_element(p_d_match_set_id,'ETHNIC_ORIGIN','N');
          FETCH c_stat_data_element INTO stat_data_element_rec;
          IF stat_data_element_rec.exact_include ='Y' THEN
                  -- this means ethnic origin is included in the matchset.check if stat data exists in interface table
            OPEN c_stat_data_exists(p_interface_id,'2');
            FETCH c_stat_data_exists INTO stat_data_exists_rec;
            IF c_stat_data_exists%NOTFOUND THEN
                               -- this means ethnic origin is included but there is no statistics record in the interface table.ERROR
              CLOSE c_stat_data_exists;
              RAISE no_data_found;
            END IF;
            IF c_stat_data_exists%ISOPEN THEN
              CLOSE c_stat_data_exists;
            END IF;
          END IF;
          CLOSE c_stat_data_element;

          IF p_addr_type IS NULL AND p_person_id_type IS NULL  AND IGS_PE_IDENTIFY_DUPS.g_primary_addr_flag = 'N' THEN
            igs_ad_find_duplicates_imp_p(p_d_match_set_id   =>p_d_match_set_id,
                                         p_d_batch_id            =>p_d_batch_id,
                                         p_d_interface_id        =>p_interface_id,
                                         p_c_addr_type           =>p_addr_type,
                                         p_c_person_id_type      =>p_person_id_type,
                                         p_person_id         =>p_person_id,
                                         p_match_ind         =>p_match_ind);

          ELSIF (p_person_id_type IS NULL) AND ( p_addr_type IS NOT NULL OR IGS_PE_IDENTIFY_DUPS.g_primary_addr_flag = 'Y') THEN
            igs_ad_find_duplicates_imp_pa(p_d_match_set_id   =>p_d_match_set_id,
                                                         p_d_batch_id           =>p_d_batch_id,
                                                         p_d_interface_id       =>p_interface_id,
                                                         p_c_addr_type          =>p_addr_type,
                                                         p_c_person_id_type     =>p_person_id_type,
                                                         p_person_id            =>p_person_id,
                                                         p_match_ind            =>p_match_ind);
          ELSIF p_addr_type IS NULL AND p_person_id_type IS NOT NULL AND IGS_PE_IDENTIFY_DUPS.g_primary_addr_flag = 'N' THEN
            igs_ad_find_duplicates_imp_pp(p_d_match_set_id   =>p_d_match_set_id,
                                                         p_d_batch_id           =>p_d_batch_id,
                                                         p_d_interface_id       =>p_interface_id,
                                                         p_c_addr_type          =>p_addr_type,
                                                         p_c_person_id_type     =>p_person_id_type,
                                                         p_person_id            =>p_person_id,
                                                         p_match_ind            =>p_match_ind);
          ELSIF p_person_id_type IS NOT NULL AND (p_addr_type IS NOT NULL OR IGS_PE_IDENTIFY_DUPS.g_primary_addr_flag = 'Y') THEN
            igs_ad_find_duplicates_imp_ppa(p_d_match_set_id   =>p_d_match_set_id,
                                                                p_d_batch_id      =>p_d_batch_id,
                                                                p_d_interface_id  =>p_interface_id,
                                                                p_c_addr_type     =>p_addr_type,
                                                                p_c_person_id_type=>p_person_id_type,
                                                                p_person_id         =>p_person_id,
                                                                p_match_ind         =>p_match_ind);
          END IF;
        END IF;


EXCEPTION
WHEN NO_DATA_FOUND THEN
   IF c_stat_data_exists%ISOPEN THEN
      CLOSE c_stat_data_exists;
   END IF;
   IF c_stat_data_element%ISOPEN THEN
      CLOSE c_stat_data_element;
   END IF;
   UPDATE igs_ad_interface
   SET status='3', ERROR_CODE='E177'
   WHERE interface_id = p_interface_id;

   IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

	 IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
	 END IF;

	 l_label := 'igs_ad_imp_009.igs_ad_imp_find_dup_persons.exception';

	 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
	 fnd_message.set_token('INTERFACE_ID',p_interface_id);
	 fnd_message.set_token('ERROR_CD','E177');

	 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

	 fnd_log.string_with_context( fnd_log.level_exception,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  IF l_enable_log = 'Y' THEN
	 igs_ad_imp_001.logerrormessage(p_interface_id,'E177');
  END IF;

END igs_ad_imp_find_dup_persons;
-- 2
/*removed the procedure SET_STAT_MATC_RVW_DIS_RCDS as part of bug 3191401*/

END Igs_Ad_Imp_009;

/
