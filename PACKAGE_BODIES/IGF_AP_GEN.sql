--------------------------------------------------------
--  DDL for Package Body IGF_AP_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_GEN" AS
/* $Header: IGFAP36B.pls 120.2 2005/12/11 03:59:59 appldev ship $ */

  FUNCTION validate_cal_inst(
                             p_cal_cat         IN            igs_ca_type.s_cal_cat%TYPE,
                             p_alt_code_one    IN            igs_ca_inst.alternate_code%TYPE,
                             p_alt_code_two    IN            igs_ca_inst.alternate_code%TYPE,
                             p_cal_type        IN OUT NOCOPY igs_ca_inst.cal_type%TYPE,
                             p_sequence_number IN OUT NOCOPY igs_ca_inst.sequence_number%TYPE
                            ) RETURN BOOLEAN AS

      /*
      ||  Created By : brajendr
      ||  Created On : 03-June-2003
      ||  Purpose : Routine will verify whethere the metnioned alternate code (one) is a valid calendar instance or not.
      ||            If valid calendar instance then checks whether alternate code two is under alternate code one.
      ||            Valid values for cal category are AWARD, LOAD, TEACHING. Returns TRUE if sucessful else FALSE.
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */

      -- Get the details of
      CURSOR check_cal_inst(
                            cp_cal_cat       igs_ca_type.s_cal_cat%TYPE,
                            cp_alternate_code igs_ca_inst.alternate_code%TYPE
                           ) IS
      SELECT cainst.alternate_code, cainst.cal_type, cainst.sequence_number
        FROM igs_ca_inst cainst, igs_ca_type catyp
       WHERE catyp.s_cal_cat = cp_cal_cat
         AND cainst.cal_type = catyp.cal_type
         AND cainst.ALTERNATE_CODE = cp_alternate_code
         AND ROWNUM = 1;

      check_cal_inst_rec check_cal_inst%ROWTYPE;

      -- Get the details of
      CURSOR check_awd_load_rel(
                                cp_alternate_code     igs_ca_inst.alternate_code%TYPE,
                                cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                                cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                               ) IS
      SELECT 'X' val
        FROM igs_ca_inst_rel rel,
             igs_ca_inst ca
       WHERE rel.sup_cal_type = ca.cal_type
         AND rel.sup_ci_sequence_number = ca.sequence_number
         AND ca.alternate_code = cp_alternate_code
         AND sub_cal_type = cp_ld_cal_type
         AND sub_ci_sequence_number = cp_ld_sequence_number
         AND ROWNUM = 1;

      check_awd_load_rel_rec check_awd_load_rel%ROWTYPE;

      -- Get the details of
      CURSOR check_load_teach_rel(
                                  cp_alternate_code_load  igs_ca_inst.alternate_code%TYPE,
                                  cp_alternate_code_teach igs_ca_inst.alternate_code%TYPE
                                 ) IS
      SELECT 'X' val
        FROM igs_ca_load_to_teach_v
       WHERE load_alternate_code  = cp_alternate_code_load
         AND teach_alternate_code = cp_alternate_code_teach
         AND ROWNUM = 1;

      check_load_teach_rel_rec check_load_teach_rel%ROWTYPE;

      return_val        BOOLEAN;

    BEGIN

      return_val := FALSE;
      p_cal_type        := NULL;
      p_sequence_number := NULL;

      IF p_cal_cat = 'AWARD' THEN

        OPEN check_cal_inst(p_cal_cat, p_alt_code_one);
        FETCH check_cal_inst INTO check_cal_inst_rec;
        IF check_cal_inst%FOUND THEN
          return_val := TRUE;
          p_cal_type        := check_cal_inst_rec.cal_type;
          p_sequence_number := check_cal_inst_rec.sequence_number;
        END IF;
        CLOSE check_cal_inst;

      ELSIF p_cal_cat = 'LOAD'  THEN

        OPEN check_cal_inst(p_cal_cat, p_alt_code_two);
        FETCH check_cal_inst INTO check_cal_inst_rec;
        IF check_cal_inst%FOUND THEN

          p_cal_type        := check_cal_inst_rec.cal_type;
          p_sequence_number := check_cal_inst_rec.sequence_number;

          OPEN check_awd_load_rel(p_alt_code_one, p_cal_type, p_sequence_number );
          FETCH check_awd_load_rel INTO check_awd_load_rel_rec;
          IF check_awd_load_rel%FOUND AND check_awd_load_rel_rec.val = 'X' THEN
            return_val := TRUE;
          END IF;
          CLOSE check_awd_load_rel;

        END IF;
        CLOSE check_cal_inst;

      ELSIF p_cal_cat = 'TEACHING' THEN

        OPEN check_cal_inst(p_cal_cat, p_alt_code_two);
        FETCH check_cal_inst INTO check_cal_inst_rec;
        IF check_cal_inst%FOUND THEN

          p_cal_type        := check_cal_inst_rec.cal_type;
          p_sequence_number := check_cal_inst_rec.sequence_number;

          OPEN check_load_teach_rel(p_alt_code_one, p_alt_code_two );
          FETCH check_load_teach_rel INTO check_load_teach_rel_rec;
          IF check_load_teach_rel%FOUND AND check_load_teach_rel_rec.val = 'X' THEN
            return_val := TRUE;
          END IF;
          CLOSE check_load_teach_rel;

        END IF;
        CLOSE check_cal_inst;

      ELSE
        return_val := FALSE;

      END IF;


      RETURN return_val;

    END validate_cal_inst;


  PROCEDURE check_person ( p_person_number     IN                         igf_aw_li_coa_ints.person_number%TYPE,
                           p_ci_cal_type         IN                         igs_ca_inst.cal_type%TYPE,
                           p_ci_sequence_number  IN                         igs_ca_inst.sequence_number%TYPE,
                           p_person_id           OUT  NOCOPY                         igf_ap_fa_base_rec_all.person_id%TYPE,
                           p_fa_base_id          OUT  NOCOPY                         igf_ap_fa_base_rec_all.base_id%TYPE )  IS

    /*
    ||  Created By : masehgal
    ||  Created On : 28-May-2003
    ||  Purpose    : check person's existence, fa base rec existence
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

      -- check person existence
      CURSOR  c_person_exist ( cp_person_number
  igs_pe_person_base_v.person_number%TYPE ) IS
         SELECT hz.party_id  person_id
           FROM igs_pe_hz_parties  hz,
                hz_parties hz1
          WHERE hz1.party_number = cp_person_number
          AND   hz.party_id = hz1.party_id;
      l_person_id    c_person_exist%ROWTYPE;

      -- check for fa base rec existence
      CURSOR c_fabase_exist ( cp_person_id
  igf_ap_fa_base_rec_all.person_id%TYPE ) IS
         SELECT base_id   fa_base_id
           FROM igf_ap_fa_base_rec_all
          WHERE person_id          = cp_person_id
            AND ci_cal_type        = p_ci_cal_type
            AND ci_sequence_number = p_ci_sequence_number ;
      l_fa_base_id    c_fabase_exist%ROWTYPE;


     BEGIN  -- check person
        -- check for person number existence
        IF p_person_number IS NULL THEN
            p_person_id := NULL;
            p_fa_base_id   := NULL;
            RETURN;
        END IF;

        OPEN  c_person_exist (p_person_number) ;
        FETCH c_person_exist INTO l_person_id ;
        IF c_person_exist%FOUND THEN
           p_person_id := l_person_id.person_id ;

           IF (p_ci_cal_type IS NULL) OR (p_ci_sequence_number IS NULL) THEN
              p_fa_base_id := NULL;
              RETURN;
           END IF;
                   -- check for fa base rec existence
           OPEN  c_fabase_exist (l_person_id.person_id) ;
           FETCH c_fabase_exist INTO l_fa_base_id ;
           IF c_fabase_exist%FOUND THEN

              p_fa_base_id  := l_fa_base_id.fa_base_id  ;
           ELSE

              p_fa_base_id := NULL ;
           END IF ;  -- fa base check
           CLOSE c_fabase_exist ;
        ELSE

           p_person_id := NULL ;
           p_fa_base_id := NULL;
        END IF ; -- person check
        CLOSE c_person_exist ;

    END check_person ;







  FUNCTION get_lookup_meaning (p_lookup_type  IN VARCHAR2,
                               p_lookup_code  IN VARCHAR2)
  RETURN VARCHAR2 IS

  /*
      ||  Created By : cdcruz
      ||  Created On : 03-June-2003
      ||  Purpose :
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */


  l_meaning igf_lookups_view.meaning%TYPE;

  l_hash_code    NUMBER;
  l_hash_type    NUMBER;
  l_db_hash_code NUMBER;
  l_is_code_valid   BOOLEAN;
  l_is_lktype_chc   BOOLEAN;

  CURSOR c_lookup (lv_lookup_type VARCHAR2)
  IS
  SELECT
    lookup_type,
    lookup_code,
    meaning
  FROM
    igf_lookups_view
  WHERE
    lookup_type = lv_lookup_type
    AND enabled_flag='Y';

  l_lookup_rec c_lookup%rowtype;

  BEGIN

    l_meaning := NULL;

    -- If parameters are not valid return

    IF p_lookup_code IS NULL OR p_lookup_type IS NULL THEN

       return(NULL);

    END IF;

      -- Get the hash value of the Type + Code
      l_hash_code := DBMS_UTILITY.get_hash_value(
                                           p_lookup_type||'@*?'||p_lookup_code,
                                           1000,
                                           25000);

      IF l_lookups_rec.EXISTS(l_hash_code) THEN
          l_meaning := l_lookups_rec(l_hash_code);
          return(l_meaning);
      END IF;

      -- Check if the Type is already cached
      l_hash_type := DBMS_UTILITY.get_hash_value(
                                           p_lookup_type,
                                           1000,
                                           25000);

      IF l_lookups_type_rec.EXISTS(l_hash_type) THEN
          return(NULL);
      END IF;

      --Type not cached so cache it.

      l_is_code_valid  := FALSE;
      l_is_lktype_chc  := FALSE;
      OPEN c_lookup(p_lookup_type);
      LOOP

       FETCH c_lookup into l_lookup_rec;
       EXIT WHEN c_lookup%NOTFOUND;

      -- Cache the Lookup Type only once
      IF NOT l_is_lktype_chc THEN
        l_is_lktype_chc  := TRUE;
        l_hash_type := DBMS_UTILITY.get_hash_value(
                                                   p_lookup_type,
                                                   1000,
                                                   25000
                                                  );
        l_lookups_type_rec(l_hash_type) := p_lookup_type;

      END IF;

       l_db_hash_code := DBMS_UTILITY.get_hash_value(
                                           l_lookup_rec.lookup_type||'@*?'||l_lookup_rec.lookup_code,
                                           1000,
                                           25000);

       l_lookups_rec(l_db_hash_code) := l_lookup_rec.meaning;

       IF l_db_hash_code = l_hash_code THEN
           l_is_code_valid := TRUE;
           l_meaning := l_lookup_rec.meaning;
       END IF;

      END LOOP;
      CLOSE c_lookup;

      return(l_meaning);

  END get_lookup_meaning;


  FUNCTION get_aw_lookup_meaning (p_lookup_type  IN VARCHAR2,
                                  p_lookup_code  IN VARCHAR2,
                                  p_sys_award_year IN VARCHAR2)
  RETURN VARCHAR2 IS

    /*
      ||  Created By : brajendr
      ||  Created On : 03-June-2003
      ||  Purpose :
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */


  l_meaning igf_lookups_view.meaning%TYPE;

  l_hash_code    NUMBER;
  l_hash_type    NUMBER;
  l_db_hash_code NUMBER;
  l_is_code_valid   BOOLEAN;
  l_is_lktype_chc   BOOLEAN;

  CURSOR c_lookup (lv_lookup_type VARCHAR2,
                   lv_sys_award_year VARCHAR2)
  IS
  SELECT
    lookup_type,
    lookup_code,
    meaning
  FROM
    igf_aw_lookups_view
  WHERE
    lookup_type    = lv_lookup_type and
    sys_award_year = lv_sys_award_year
    AND enabled_flag='Y';

  l_lookup_rec c_lookup%rowtype;

  BEGIN

    l_meaning := NULL;

    -- If parameters are not valid return
    IF p_lookup_code IS NULL OR p_lookup_type IS NULL OR p_sys_award_year IS NULL THEN
      return(NULL);
    END IF;

    -- Get the hash value of the Type + Code
    l_hash_code := DBMS_UTILITY.get_hash_value(
                                         p_lookup_type||'@*?'||p_lookup_code||'@*?'||p_sys_award_year,
                                         1000,
                                         25000);

    IF l_lookups_rec.EXISTS(l_hash_code) THEN
        l_meaning := l_lookups_rec(l_hash_code);
        return(l_meaning);
    END IF;

    -- Check if the Type is already cached
    l_hash_type := DBMS_UTILITY.get_hash_value(
                                         p_lookup_type||'@*?'||p_sys_award_year,
                                         1000,
                                         25000);

    IF l_lookups_type_rec.EXISTS(l_hash_type) THEN
      return(NULL);
    END IF;

    --Type not cached so cache it.
    l_is_code_valid  := FALSE;
    l_is_lktype_chc  := FALSE;
    OPEN c_lookup(p_lookup_type,p_sys_award_year);
    LOOP

     FETCH c_lookup INTO l_lookup_rec;
     EXIT WHEN c_lookup%NOTFOUND;

      -- Cache the Lookup Type only once
      IF NOT l_is_lktype_chc THEN
        l_is_lktype_chc  := TRUE;
        l_hash_type := DBMS_UTILITY.get_hash_value(
                                                   p_lookup_type||'@*?'||p_sys_award_year,
                                                   1000,
                                                   25000
                                                  );
        l_lookups_type_rec(l_hash_type) := p_lookup_type;

      END IF;

      l_db_hash_code := DBMS_UTILITY.get_hash_value(
                                           l_lookup_rec.lookup_type||'@*?'||l_lookup_rec.lookup_code||'@*?'||p_sys_award_year,
                                           1000,
                                           25000);

      l_lookups_rec(l_db_hash_code) := l_lookup_rec.meaning;

      IF l_db_hash_code = l_hash_code THEN
        l_is_code_valid := TRUE;
        l_meaning := l_lookup_rec.meaning;
      END IF;

    END LOOP;
    CLOSE c_lookup;

    return(l_meaning);

  END get_aw_lookup_meaning;

  FUNCTION check_profile
  RETURN VARCHAR2
  IS
    /*
      ||  Created By : rasahoo
      ||  Created On : 03-June-2003
      ||  Purpose : Checks the profile set to US country code and participating in financial aid programme.
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */

  lv_cntry_code  VARCHAR2(100);
  lv_fin_aid         VARCHAR2(100);

  lv_retval  VARCHAR2(10);

  BEGIN

           lv_retval := 'NULL';

           fnd_profile.get('OSS_COUNTRY_CODE',lv_cntry_code);
           fnd_profile.get('IGS_PS_PARTICIPATE_FA_PROG',lv_fin_aid);

          IF lv_cntry_code ='US' AND lv_fin_aid      = 'Y'    THEN
                lv_retval     := 'Y';
          ELSE
                lv_retval     := 'N';
          END IF;


  RETURN     lv_retval;

  END check_profile;

  FUNCTION check_batch(p_batch_id   IN  NUMBER,
                       p_batch_type IN  VARCHAR2)
  RETURN VARCHAR2
  IS
   /*
      ||  Created By : bkkumar
      ||  Created On : 03-June-2003
      ||  Purpose : Routine will verify whether the batch id is valid for
      ||            the current batch type.
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */
  CURSOR c_chk_batch(cp_batch_num NUMBER,
                   cp_batch_type VARCHAR2)
  IS
  SELECT 'x'
  FROM   igf_ap_li_bat_ints
  WHERE  batch_num = cp_batch_num
  AND    batch_type = cp_batch_type
  AND    rownum = 1;

  l_chk_batch c_chk_batch%ROWTYPE;

  l_retval  VARCHAR2(1) := 'Y';

  BEGIN

     OPEN c_chk_batch(p_batch_id,p_batch_type);
     FETCH c_chk_batch INTO l_chk_batch;
     IF c_chk_batch%NOTFOUND OR c_chk_batch%NOTFOUND IS NULL THEN
        l_retval := 'N';
     END IF;
     CLOSE c_chk_batch;

  RETURN     l_retval;

  END check_batch;

  FUNCTION get_isir_value(
                          p_base_id          IN igf_ap_fa_base_rec_all.base_id%TYPE,
                          p_sar_field_name   IN igf_fc_sar_cd_mst.sar_field_name%TYPE
                         ) RETURN VARCHAR2 AS

    /*
    ||  Created By : brajendr
    ||  Created On : 16-Oct-2003
    ||  Purpose    : Gets the Payment ISIR Value, it is used in the
    ||               Verification SS pages to display the payment isir value.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    lv_cur               PLS_INTEGER;
    lv_retval            igf_ap_isir_corr.original_value%TYPE;
    lv_stmt              VARCHAR2(2000);
    lv_rows              integer;

  BEGIN

    IF p_base_id IS NULL OR p_sar_field_name IS NULL THEN
      RETURN NULL;

    ELSE

      IF p_sar_field_name IS NOT NULL THEN
        lv_cur  := DBMS_SQL.OPEN_CURSOR;
        lv_stmt := 'SELECT '||p_sar_field_name ||' FROM igf_ap_isir_matched_all WHERE payment_isir = ''Y'' AND system_record_type = ''ORIGINAL'' AND base_id =  '||to_char(p_base_id);

        DBMS_SQL.PARSE(lv_cur, lv_stmt, 2);
        DBMS_SQL.DEFINE_COLUMN(lv_cur, 1, lv_retval, 30);
        lv_rows := DBMS_SQL.EXECUTE_AND_FETCH(lv_cur);
        DBMS_SQL.COLUMN_VALUE(lv_cur,1,lv_retval);
        DBMS_SQL.CLOSE_CURSOR(lv_cur);

        RETURN lv_retval;

      END IF;

    END IF;

    RETURN NULL;

  EXCEPTION
    WHEN others THEN
      RETURN NULL;
  END get_isir_value;


  FUNCTION get_indv_efc_4_term(
                               p_base_id         IN igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_cal_type        IN igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                               p_sequence_number IN igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                               p_isir_id         IN igf_ap_isir_matched_all.isir_id%TYPE
                              ) RETURN NUMBER AS
   /*
    ||  Created By : rasahoo
    ||  Created On : 15-10-2003
    ||  Purpose    : get individual family contribution for a term
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  rasahoo         20-NOV-2003    Changed the cursor c_cum_efc as part of
    ||                                 Build ISIR update 2004 - 05
    */

    CURSOR c_cum_efc(
                     cp_base_id  igf_ap_fa_base_rec_all.base_id%TYPE,
                     cp_isir_id  igf_ap_isir_matched_all.isir_id%TYPE
                    ) IS
    SELECT distinct ca.alternate_code,
           ca.start_dt ld_start_dt,
           ca.end_dt ld_end_dt,
           igf_ap_gen.get_individual_coa_amt(ca.start_dt,fa.base_id) coa,
           ca.cal_type ld_cal_type, ca.sequence_number ld_sequence_number,
           DECODE(fa.AWARD_FMLY_CONTRIBUTION_TYPE, '2',
             DECODE ( igf_ap_efc_calc.get_efc_no_of_months(ca.end_dt, coa.base_id ),
                 1 , SEC_ALTERNATE_MONTH_1,
                 2 , SEC_ALTERNATE_MONTH_2,
                 3 , SEC_ALTERNATE_MONTH_3,
                 4 , SEC_ALTERNATE_MONTH_4,
                 5 , SEC_ALTERNATE_MONTH_5,
                 6 , SEC_ALTERNATE_MONTH_6,
                 7 , SEC_ALTERNATE_MONTH_7,
                 8 , SEC_ALTERNATE_MONTH_8,
                 9 , SECONDARY_EFC,
                 10, SEC_ALTERNATE_MONTH_10,
                 11, SEC_ALTERNATE_MONTH_11,
                 12, SEC_ALTERNATE_MONTH_12 ) ,
             DECODE ( igf_ap_efc_calc.get_efc_no_of_months(ca.end_dt, coa.base_id ),
                 1 , PRIMARY_ALTERNATE_MONTH_1,
                 2 , PRIMARY_ALTERNATE_MONTH_2,
                 3 , PRIMARY_ALTERNATE_MONTH_3,
                 4 , PRIMARY_ALTERNATE_MONTH_4,
                 5 , PRIMARY_ALTERNATE_MONTH_5,
                 6 , PRIMARY_ALTERNATE_MONTH_6,
                 7 , PRIMARY_ALTERNATE_MONTH_7,
                 8 , PRIMARY_ALTERNATE_MONTH_8,
                 9 , PRIMARY_EFC,
                 10, PRIMARY_ALTERNATE_MONTH_10,
                 11, PRIMARY_ALTERNATE_MONTH_11,
                 12, PRIMARY_ALTERNATE_MONTH_12 ) ) efc
      FROM igf_ap_isir_matched_all isir,
           igf_ap_fa_base_rec_all fa,
           igs_ca_inst_all ca,
           igf_aw_coa_itm_terms coa
     WHERE coa.base_id = fa.base_id
       AND coa.base_id = isir.base_id
       AND fa.base_id = cp_base_id
       AND isir.isir_id = cp_isir_id
       AND coa.ld_sequence_number = ca.sequence_number
       AND coa.ld_cal_type = ca.cal_type
       ORDER BY ca.start_dt;

    l_prev_efc  NUMBER := 0;
    l_efc       NUMBER := 0;

  BEGIN

    FOR lc_cum_efc IN c_cum_efc(p_base_id, p_isir_id) LOOP

      IF (lc_cum_efc.LD_CAL_TYPE = p_cal_type) AND (lc_cum_efc.LD_SEQUENCE_NUMBER = p_sequence_number) THEN
        l_efc := (lc_cum_efc.efc - l_prev_efc);
        IF l_efc < 0 THEN
          return 0;
        ELSE
          return l_efc;
        END IF;
      ELSE
        l_prev_efc := lc_cum_efc.efc;
      END IF;

    END LOOP;

    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END get_indv_efc_4_term;


  FUNCTION get_cumulative_coa_amt(
                                  p_ld_start_dt    IN  DATE,
                                  p_base_id        IN  igf_ap_fa_base_rec_all.base_id%TYPE
                                 ) RETURN NUMBER IS
    /*
    ||  Created By : rasahoo
    ||  Created On : 27-NOV-2003
    ||  Purpose    : get Cumulative COA Amount for the student based on the start date
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  rasahoo         27-NOV-2003    Created the file
    */

    CURSOR sel_coa_amt_cur(
                           cp_ld_start_dt    IN  DATE,
                           cp_base_id        IN  igf_ap_fa_base_rec_all.base_id%TYPE
                          )IS
    SELECT SUM(coait.amount) coa
      FROM igf_aw_coa_itm_terms coait,
           igs_ca_inst ca
     WHERE ca.cal_type   = coait.ld_cal_type
       AND ca.sequence_number = coait.ld_sequence_number
       AND ca.start_dt   <= cp_ld_start_dt
       AND coait.base_id =  cp_base_id;

    l_tot_coa_amt   NUMBER := 0;

  BEGIN

    OPEN sel_coa_amt_cur(p_ld_start_dt, p_base_id);
    FETCH sel_coa_amt_cur  INTO l_tot_coa_amt;

    -- If no Data Found return the default value 0
    IF sel_coa_amt_cur%NOTFOUND  THEN
      CLOSE  sel_coa_amt_cur;
      RETURN 0;
    ELSE
      CLOSE sel_coa_amt_cur;
      RETURN l_tot_coa_amt;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_GEN.GET_CUMULATIVE_COA_AMT'||SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END get_cumulative_coa_amt ;


  FUNCTION get_individual_coa_amt(
                                  p_ld_start_dt    IN  DATE,
                                  p_base_id        IN  igf_ap_fa_base_rec_all.base_id%TYPE
                                 ) RETURN NUMBER IS
    /*
    ||  Created By : rasahoo
    ||  Created On : 27-NOV-2003
    ||  Purpose    : get Individual COA Amount for the student based on the start date
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  rasahoo         27-NOV-2003    Created the file
    */

    CURSOR sel_coa_amt_cur(
                           cp_ld_start_dt    IN  DATE,
                           cp_base_id        IN  igf_ap_fa_base_rec_all.base_id%TYPE
                          )IS
    SELECT SUM(coait.amount) coa
      FROM igf_aw_coa_itm_terms coait,
           igs_ca_inst ca
     WHERE ca.cal_type   = coait.ld_cal_type
       AND ca.sequence_number = coait.ld_sequence_number
       AND ca.start_dt   = cp_ld_start_dt
       AND coait.base_id = cp_base_id;

    l_tot_coa_amt   NUMBER := 0;

  BEGIN

    OPEN sel_coa_amt_cur(p_ld_start_dt, p_base_id);
    FETCH sel_coa_amt_cur  INTO l_tot_coa_amt;

    -- If no Data Found return the default value 0
    IF sel_coa_amt_cur%NOTFOUND  THEN
      CLOSE  sel_coa_amt_cur;
      RETURN 0;
    ELSE
      CLOSE sel_coa_amt_cur;
      RETURN l_tot_coa_amt;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_GEN.GET_INDIVIDUAL_COA_AMT'||SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END get_individual_coa_amt;

  PROCEDURE update_preflend_todo_status ( p_person_id	     IN igf_ap_fa_base_rec_all.person_id%TYPE,
                                          p_return_status  OUT NOCOPY VARCHAR2
                                        ) IS
  ------------------------------------------------------------------
  --Created by  : bvisvana, Oracle India
  --Date created: 09-Dec-2005
  --
  --Purpose: Bug 4773795 - To update the PREFLEND todo status when user assigns a preferred lender through the Manage Preferred Lender page
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    CURSOR get_active_preflend(cp_person_id igf_ap_fa_base_rec_all.person_id%TYPE) IS
      SELECT clprl_id FROM igf_sl_cl_pref_lenders WHERE
      person_id = cp_person_id AND TRUNC(SYSDATE) BETWEEN start_date AND NVL(end_date,TRUNC(SYSDATE));

    CURSOR preflend_todo_item_dtls (cp_person_id igf_ap_fa_base_rec_all.person_id%TYPE) IS
      SELECT clprl_id,base_id,item_sequence_number,status FROM igf_ap_td_item_inst_v WHERE
      person_id = cp_person_id AND system_todo_type_code='PREFLEND';

    preflend_todo_item_rec preflend_todo_item_dtls%ROWTYPE;
    l_status	      VARCHAR2(10);
    l_return_status VARCHAR2(10);
    l_clprl_id	    NUMBER;
    l_update	      BOOLEAN := FALSE;

  BEGIN
    -- 1. If there is an active preferred lender for the person. Check if it is in REQ or INC, if so make it 'COM'
    -- 2. If No active Pref lender but there exists a system to do item of PREFLEND with COM , then make it REQ
    p_return_status := 'S';
    OPEN get_active_preflend(cp_person_id => p_person_id);
    FETCH get_active_preflend INTO l_clprl_id;

    IF get_active_preflend%FOUND THEN -- Active Preflender is there

      OPEN preflend_todo_item_dtls(cp_person_id => p_person_id);
      FETCH  preflend_todo_item_dtls INTO preflend_todo_item_rec;
      IF preflend_todo_item_dtls%FOUND THEN
        IF (preflend_todo_item_rec.status IN ('REQ','INC')) THEN
          l_status := 'COM';
          l_update := TRUE;
        END IF;
      END IF;

    ELSE -- No Active Preflender is there

      OPEN preflend_todo_item_dtls(cp_person_id => p_person_id);
      FETCH  preflend_todo_item_dtls INTO preflend_todo_item_rec;
      IF preflend_todo_item_dtls%FOUND THEN
        IF (preflend_todo_item_rec.status = 'COM') THEN
          l_status := 'REQ';
          l_update := TRUE;
          preflend_todo_item_rec.clprl_id := NULL;
        END IF;
      END IF;
    END IF;

    IF l_update THEN
      update_td_status( p_base_id		           => preflend_todo_item_rec.base_id,
                        p_item_sequence_number => preflend_todo_item_rec.item_sequence_number,
                        p_status               => l_status,
                        p_clprl_id             => preflend_todo_item_rec.clprl_id,
                        p_return_status        => l_return_status
                      );
      p_return_status := l_return_status;
    END IF;
    CLOSE get_active_preflend;
    CLOSE preflend_todo_item_dtls;

    EXCEPTION
      WHEN OTHERS THEN
        p_return_status := 'F';
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_GEN.UPDATE_PREFLEND_TODO_STATUS'||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END update_preflend_todo_status;

  PROCEDURE update_td_status(
                             p_base_id                IN         igf_ap_fa_base_rec_all.base_id%TYPE,
                             p_item_sequence_number   IN         igf_ap_td_item_inst_all.item_sequence_number%TYPE,
                             p_status                 IN         igf_ap_td_item_inst_all.status%TYPE,
                             p_clprl_id               IN         igf_sl_cl_pref_lenders.clprl_id%TYPE DEFAULT NULL,
                             p_return_status          OUT NOCOPY VARCHAR2
                            ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get the item
  CURSOR c_inst(
                cp_base_id              igf_ap_fa_base_rec_all.base_id%TYPE,
                cp_item_sequence_number igf_ap_td_item_inst_all.item_sequence_number%TYPE
               ) IS
    SELECT td.ROWID row_id,
           td.*
      FROM igf_ap_td_item_inst_all td
     WHERE base_id = cp_base_id
       AND item_sequence_number = cp_item_sequence_number;
   l_inst c_inst%ROWTYPE;

   -- Get the system to do type code of the item
   CURSOR c_system_todo_type(
                             cp_todo_number igf_ap_td_item_mst_all.todo_number%TYPE
                            ) IS
     SELECT system_todo_type_code
       FROM igf_ap_td_item_mst_all
      WHERE todo_number = cp_todo_number;
    l_system_todo_type c_system_todo_type%ROWTYPE;

   l_seq_val       NUMBER;

   l_wf_event_t           WF_EVENT_T;
   l_wf_parameter_list_t  WF_PARAMETER_LIST_T;

   lv_event_name          VARCHAR2(4000);

   -- Get person number
   CURSOR c_person_number(
                          cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                         ) IS
     SELECT hz.party_number
       FROM hz_parties hz,
            igf_ap_fa_base_rec_all fa
      WHERE fa.person_id = hz.party_id
        AND fa.base_id = cp_base_id;
    l_person_number hz_parties.party_number%TYPE;

    -- Get item description
    CURSOR c_td_item(
                     cp_item_sequence_number igf_ap_td_item_inst_all.item_sequence_number%TYPE
                    ) IS
      SELECT description
        FROM igf_ap_td_item_mst_all
       WHERE todo_number = cp_item_sequence_number;
    l_desc igf_ap_td_item_mst_all.description%TYPE;

    -- Get award year alternate code
    CURSOR c_award_year(
                        cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                       ) IS
      SELECT ca.alternate_code
        FROM igs_ca_inst_all ca,
             igf_ap_fa_base_rec_all fa
       WHERE fa.base_id = cp_base_id
         AND fa.ci_cal_type = ca.cal_type
         AND fa.ci_sequence_number = ca.sequence_number;
    l_alternate_code igs_ca_inst_all.alternate_code%TYPE;

  BEGIN
    OPEN c_inst(p_base_id,p_item_sequence_number);
    FETCH c_inst INTO l_inst;
    CLOSE c_inst;

    OPEN c_system_todo_type(p_item_sequence_number);
    FETCH c_system_todo_type INTO l_system_todo_type;
    CLOSE c_system_todo_type;

    IF l_system_todo_type.system_todo_type_code = 'PREFLEND' THEN
      l_inst.clprl_id := p_clprl_id;
    END IF;

    igf_ap_td_item_inst_pkg.update_row(
                                       x_rowid                    => l_inst.row_id,
                                       x_base_id                  => l_inst.base_id,
                                       x_item_sequence_number     => l_inst.item_sequence_number,
                                       x_status                   => p_status,
                                       x_status_date              => TRUNC(SYSDATE),
                                       x_add_date                 => l_inst.add_date,
                                       x_corsp_date               => l_inst.corsp_date,
                                       x_corsp_count              => l_inst.corsp_count,
                                       x_inactive_flag            => l_inst.inactive_flag,
                                       x_freq_attempt             => l_inst.freq_attempt,
                                       x_max_attempt              => l_inst.max_attempt,
                                       x_required_for_application => l_inst.required_for_application,
                                       x_mode                     => 'R',
                                       x_legacy_record_flag       => l_inst.legacy_record_flag,
                                       x_clprl_id                 => l_inst.clprl_id
                                      );
    IF p_status IN ('COM','REC') THEN
      OPEN c_person_number(p_base_id);
      FETCH c_person_number INTO l_person_number;
      CLOSE c_person_number;

      OPEN c_td_item(p_item_sequence_number);
      FETCH c_td_item INTO l_desc;
      CLOSE c_td_item;

      OPEN c_award_year(p_base_id);
      FETCH c_award_year INTO l_alternate_code;
      CLOSE c_award_year;

      SELECT igs_pe_res_chg_s.nextval INTO l_seq_val FROM DUAL;

      -- Initialize the wf_event_t object
      WF_EVENT_T.Initialize(l_wf_event_t);

      -- Set the event name
      IF p_status = 'COM' THEN
        lv_event_name := 'oracle.apps.igf.td.ToDoCompleted';

      ELSIF p_status = 'REC' THEN
        lv_event_name :=  'oracle.apps.igf.td.ToDoReceived';
      END IF;
      l_wf_event_t.setEventName(pEventName => lv_event_name);

      -- Set the event key
        l_wf_event_t.setEventKey(
                                 pEventKey => lv_event_name || l_seq_val
                                );

      -- Set the parameter list
      l_wf_event_t.setParameterList(
                                    pParameterList => l_wf_parameter_list_t
                                   );

      -- Set the message's subject
      IF p_status = 'COM' THEN
        fnd_message.set_name('IGF','IGF_AP_TD_COMPLTD_SUBJ');
      ELSIF p_status = 'REC' THEN
        fnd_message.set_name('IGF','IGF_AP_TD_RECD_SUBJ');
      END IF;
      wf_event.addparametertolist(
                                  p_name          => 'SUBJECT',
                                  p_value         => fnd_message.get,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      -- Set the person number
      wf_event.addparametertolist(
                                  p_name          => 'STUDENT_NUMBER',
                                  p_value         => l_person_number,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      -- Set the to do item description
      wf_event.addparametertolist(
                                  p_name          => 'TO_DO_ITEM',
                                  p_value         => l_desc,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      -- Set the award year alternate code
      wf_event.addparametertolist(
                                  p_name          => 'AWARD_YEAR',
                                  p_value         => l_alternate_code,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      wf_Event.raise(
                     p_event_name => lv_event_name,
                     p_event_key  => lv_event_name || l_seq_val,
                     p_parameters => l_wf_parameter_list_t
                    );
    END IF;
    p_return_status := 'S';

    EXCEPTION
      WHEN OTHERS THEN
        p_return_status := 'F';
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_GEN.UPDATE_TD_STATUS'||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END update_td_status;

END igf_ap_gen;

/
