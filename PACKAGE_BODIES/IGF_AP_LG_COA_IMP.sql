--------------------------------------------------------
--  DDL for Package Body IGF_AP_LG_COA_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_LG_COA_IMP" AS
/* $Header: IGFAP40B.pls 120.2 2006/01/17 02:37:45 tsailaja noship $ */

g_log_tab_index   NUMBER := 0;

TYPE log_record IS RECORD ( person_number VARCHAR2(30),
                            message_text VARCHAR2(500));

-- The PL/SQL table for storing the log messages
TYPE LogTab IS TABLE OF log_record INDEX BY BINARY_INTEGER;

g_log_tab LogTab;


PROCEDURE log_input_params( p_batch_num         IN  igf_aw_li_coa_ints.batch_num%TYPE ,
                            p_alternate_code    IN  igs_ca_inst.alternate_code%TYPE   ,
                            p_delete_flag       IN  VARCHAR2 )  IS
/*
||  Created By : masehgal
||  Created On : 28-May-2003
||  Purpose    : Logs all the Input Parameters
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/

  -- cursor to get batch desc for the batch id from igf_ap_li_bat_ints
  CURSOR c_batch_desc(cp_batch_num     igf_aw_li_coa_ints.batch_num%TYPE ) IS
     SELECT batch_desc, batch_type
       FROM igf_ap_li_bat_ints
      WHERE batch_num = cp_batch_num ;

  l_lkup_type            VARCHAR2(60) ;
  l_lkup_code            VARCHAR2(60) ;
  l_batch_desc           igf_ap_li_bat_ints.batch_desc%TYPE ;
  l_batch_type           igf_ap_li_bat_ints.batch_type%TYPE ;
  l_batch_id             igf_ap_li_bat_ints.batch_type%TYPE ;
  l_yes_no               igf_lookups_view.meaning%TYPE ;
  l_award_year_pmpt      igf_lookups_view.meaning%TYPE ;
  l_params_pass_prmpt    igf_lookups_view.meaning%TYPE ;
  l_person_number_prmpt  igf_lookups_view.meaning%TYPE ;
  l_batch_num_prmpt      igf_lookups_view.meaning%TYPE ;
  l_error                igf_lookups_view.meaning%TYPE ;

  BEGIN -- begin log parameters

     -- get the batch description
     OPEN  c_batch_desc( p_batch_num) ;
     FETCH c_batch_desc INTO l_batch_desc, l_batch_type ;
     CLOSE c_batch_desc ;

    l_error               := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
    l_person_number_prmpt := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');
    l_batch_num_prmpt     := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','BATCH_ID');
    l_award_year_pmpt     := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','AWARD_YEAR');
    l_yes_no              := igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_delete_flag);
    l_params_pass_prmpt   := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PARAMETER_PASS');

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE( FND_FILE.LOG, '-------------------------------------------------------------');
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ') ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, l_params_pass_prmpt) ; --Parameters Passed
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ') ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( l_award_year_pmpt, 40)    || ' : '|| p_alternate_code ) ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( l_batch_num_prmpt, 40)     || ' : '|| TO_CHAR(p_batch_num) || '-' || l_batch_desc ) ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( FND_MESSAGE.GET_STRING('IGS','IGS_GE_ASK_DEL_REC'), 40)   || ' : '|| l_yes_no ) ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE( FND_FILE.LOG, '-------------------------------------------------------------');
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_coa_imp.log_input_params.exception','Unhandled exception in Procedure log_input_params '||SQLERRM);
      END IF;
  END log_input_params ;


  PROCEDURE print_log_process( p_person_number IN  VARCHAR2,
                               p_error         IN  VARCHAR2 ) IS
    /*
    ||  Created By : masehgal
    ||  Created On : 01-Jun-2003
    ||  Purpose : This process gets the records from the pl/sql table and print in the log file
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  l_count NUMBER(5) := g_log_tab.COUNT;
  l_old_person VARCHAR2(30) := '*******';

  BEGIN

    FOR i IN 1..l_count LOOP
      IF l_old_person <> g_log_tab(i).person_number THEN
        fnd_file.put_line(fnd_file.log,'-----------------------------------------------------------------------------');
        fnd_file.put_line(fnd_file.log,p_person_number || ' : ' || g_log_tab(i).person_number);
      END IF;
      fnd_file.put_line(fnd_file.log,g_log_tab(i).message_text);
      l_old_person := g_log_tab(i).person_number;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_coa_imp.print_log_process.exception','Unhandled exception in Procedure print_log_process'||SQLERRM);
      END IF;
  END print_log_process;



  PROCEDURE chk_per_rec_stat( p_batch_num       IN         NUMBER,
                              p_alternate_code  IN         VARCHAR2,
                              p_person_number   IN         VARCHAR2,
                              p_rec_type        OUT NOCOPY VARCHAR2 ) IS
    /*
    ||  Created By : masehgal
    ||  Created On : 07-Jun-2003
    ||  Purpose : This process gets the record type for the person from the interface table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    CURSOR  c_get_person_rec_type ( cp_alternate_code  igf_aw_li_coa_ints.ci_alternate_code%TYPE,
                                    cp_batch_num       igf_aw_li_coa_ints.batch_num%TYPE,
                                    cp_person_number   igf_aw_li_coa_ints.person_number%TYPE) IS
      SELECT DISTINCT(NVL(import_record_type,'*')) types
        FROM igf_aw_li_coa_ints
        WHERE ci_alternate_code = cp_alternate_code
          AND batch_num         = cp_batch_num
          AND person_number     = cp_person_number
          AND import_status_type IN ('R','U') ;
    l_count   c_get_person_rec_type%ROWTYPE ;
    l_update  VARCHAR2(1) ;
    l_others  VARCHAR2(1) ;

  BEGIN
     l_update := NULL ;
     l_others := NULL ;

     FOR l_count IN c_get_person_rec_type ( p_alternate_code, p_batch_num, p_person_number)
     LOOP
        IF NVL(l_count.types,'*') = 'U' THEN
           l_update := 'U' ;
        ELSE
           l_others := 'O' ;
        END IF ;
     END LOOP ;

     IF l_update is NOT NULL and l_others is not null THEN
        p_rec_type := 'E';
     ELSIF l_update is NOT NULL and l_others is null THEN
        p_rec_type := 'U';
     ELSIF l_others is not null and l_update is null THEN
        p_rec_type := 'I';
     ELSIF l_others is  null and l_update is null THEN
        p_rec_type := 'E';
     END IF ;

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_coa_imp.chk_per_rec_stat.exception','Unhandled exception in Procedure chk_per_rec_stat'||SQLERRM);
      END IF;
  END chk_per_rec_stat;



  PROCEDURE check_person_terms ( p_fa_base_id       IN           igf_ap_fa_base_rec_all.base_id%TYPE,
                                 l_per_terms_match  OUT  NOCOPY  BOOLEAN )  IS
  /*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose    : check persons existing terms, new added coa items terms
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  -- Select All COA Items for a person
  CURSOR person_coa_items (cp_base_id     igf_ap_fa_base_rec_all.base_id%TYPE ) IS
     SELECT DISTINCT item_code
       FROM igf_aw_coa_items
      WHERE base_id = cp_base_id ;
  l_item_code   person_coa_items%ROWTYPE;

  -- Count all terms for a person in the system
  CURSOR person_terms ( cp_base_id     igf_aw_coa_itm_terms.base_id%TYPE ) IS
     SELECT COUNT(DISTINCT (ld_sequence_number)) person_terms
       FROM igf_aw_coa_itm_terms
      WHERE base_id  =  cp_base_id ;
  l_person_terms   NUMBER;

  -- Count all terms for a person for a COA Item
  CURSOR person_coa_terms ( cp_base_id     igf_aw_coa_itm_terms.base_id%TYPE ,
                            cp_item_code   igf_aw_li_coa_ints.item_code%TYPE) IS
     SELECT COUNT(DISTINCT(ld_sequence_number)) coa_terms
       FROM igf_aw_coa_itm_terms
      WHERE base_id   = cp_base_id
        AND item_code = cp_item_code ;
  l_person_coa_terms    NUMBER;


  BEGIN
     l_per_terms_match := TRUE ;
     -- get total terms
     OPEN  person_terms ( p_fa_base_id );
     FETCH person_terms INTO l_person_terms ;
     IF person_terms%NOTFOUND THEN
        l_person_terms := 0 ;
     END IF ;
     CLOSE person_terms ;

     -- check person terms
     -- get diferent item codes
     FOR l_item_code IN person_coa_items ( p_fa_base_id )
     LOOP
        -- get term count for each coa item
        OPEN  person_coa_terms ( p_fa_base_id, l_item_code.item_code) ;
        FETCH person_coa_terms INTO l_person_coa_terms ;
        CLOSE person_coa_terms ;
        IF l_person_terms <> l_person_coa_terms THEN
           l_per_terms_match := FALSE ;
        END IF ;
     END LOOP ;

     EXCEPTION
        WHEN OTHERS THEN
           IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_coa_imp.check_person_terms.exception','Unhandled exception in Procedure check_person_terms'||SQLERRM);
           END IF;
           fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
           fnd_message.set_token('NAME','IGF_AP_LG_COA_IMP.CHECK_PERSON_TERMS');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;

  END check_person_terms ;


  PROCEDURE check_dup_coa ( p_item_code          IN           igf_aw_coa_itm_terms.item_code%TYPE,
                            p_base_id            IN           igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_dup_coa            OUT  NOCOPY  BOOLEAN )  IS
  /*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose    : check duplication of COA Item
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

   CURSOR chk_dup_coa ( cp_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                        cp_item_code    igf_aw_coa_items.item_code%TYPE) IS
      SELECT 1
        FROM igf_aw_coa_items
       WHERE base_id   = cp_base_id
         AND item_code = cp_item_code ;
   l_count    chk_dup_coa%ROWTYPE ;

  BEGIN
     OPEN  chk_dup_coa ( p_base_id, p_item_code) ;
     FETCH chk_dup_coa INTO l_count ;
     IF chk_dup_coa%NOTFOUND THEN
        p_dup_coa := FALSE ;
     ELSE
        p_dup_coa := TRUE ;
     END IF ;
     CLOSE chk_dup_coa ;

  EXCEPTION
     WHEN OTHERS THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_coa_imp.check_dup_coa.exception','Unhandled exception in Procedure check_dup_coa'||SQLERRM);
        END IF;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_LG_COA_IMP.CHECK_DUP_COA');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END check_dup_coa ;



  PROCEDURE check_dup_coa_term ( p_item_code          IN           igf_aw_coa_itm_terms.item_code%TYPE,
                                 p_ld_cal_type        IN           igs_ca_inst.cal_type%TYPE,
                                 p_ld_seq_num         IN           igs_ca_inst.sequence_number%TYPE,
                                 p_base_id            IN           igf_ap_fa_base_rec_all.base_id%TYPE,
                                 p_dup_term           OUT  NOCOPY  BOOLEAN )  IS
  /*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose    : check duplication of COA Item Term
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

   CURSOR chk_dup_term ( cp_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                         cp_item_code    igf_aw_coa_itm_terms.item_code%TYPE,
                         cp_ld_cal_type  igs_ca_inst.cal_type%TYPE,
                         cp_ld_seq_num   igs_ca_inst.sequence_number%TYPE) IS
      SELECT 1
        FROM igf_aw_coa_itm_terms
       WHERE base_id            = cp_base_id
         AND item_code          = cp_item_code
         AND ld_cal_type        = cp_ld_cal_type
         AND ld_sequence_number = cp_ld_seq_num ;
   l_count    chk_dup_term%ROWTYPE ;

  BEGIN
     OPEN  chk_dup_term ( p_base_id, p_item_code, p_ld_cal_type, p_ld_seq_num ) ;
     FETCH chk_dup_term INTO l_count ;
     IF chk_dup_term%NOTFOUND THEN
        p_dup_term := FALSE ;
     ELSE
        p_dup_term := TRUE ;
     END IF ;
     CLOSE chk_dup_term ;

  EXCEPTION
     WHEN OTHERS THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_coa_imp.check_dup_coa_term.exception','Unhandled exception in Procedure check_dup_coa_term'||SQLERRM);
        END IF;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_LG_COA_IMP.CHECK_DUP_COA_TERM');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END check_dup_coa_term ;


  PROCEDURE delete_coa_terms ( p_base_id       IN   igf_ap_fa_base_rec_all.base_id%TYPE) IS
  /*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose    : deletion of COA Terms
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR del_coa_terms( cp_base_id       igf_aw_coa_itm_terms.base_id%TYPE)  IS
     SELECT rowid
       FROM igf_aw_coa_itm_terms
      WHERE base_id            = cp_base_id  ;
  lv_rowid  del_coa_terms%ROWTYPE;

  BEGIN
     FOR lv_rowid IN del_coa_terms ( p_base_id)
     LOOP
        igf_aw_coa_itm_terms_pkg.delete_row( x_rowid => lv_rowid.rowid);
     END LOOP;

  EXCEPTION
     WHEN OTHERS THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_coa_imp.delete_coa_terms.exception','Unhandled exception in Procedure delete_coa_terms'||SQLERRM);
        END IF;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_LG_COA_IMP.DELETE_COA_TERMS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END delete_coa_terms ;



  PROCEDURE delete_coa_items ( p_base_id    IN   igf_ap_fa_base_rec_all.base_id%TYPE) IS
  /*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose    : deletion of COA Items
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR del_coa_items( cp_base_id    igf_aw_coa_itm_terms.base_id%TYPE) IS --,
     SELECT rowid
       FROM igf_aw_coa_items
      WHERE base_id   = cp_base_id  ;
  lv_rowid  del_coa_items%ROWTYPE;

  BEGIN
     FOR lv_rowid IN del_coa_items ( p_base_id) --, p_item_code)
     LOOP
        igf_aw_coa_items_pkg.delete_row( x_rowid => lv_rowid.rowid);
     END LOOP;

  EXCEPTION
     WHEN OTHERS THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_coa_imp.delete_coa_items.exception','Unhandled exception in Procedure delete_coa_items'||SQLERRM);
        END IF;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_LG_COA_IMP.DELETE_COA_ITEMS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END delete_coa_items ;


  PROCEDURE main ( errbuf            OUT NOCOPY VARCHAR2,
                   retcode           OUT NOCOPY NUMBER,
                   p_award_year      IN         VARCHAR2,
                   p_batch_num       IN         VARCHAR2,
                   p_delete_flag     IN         VARCHAR2 ) IS
  /*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose    : Main - called from submitted request
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
  ||  (reverse chronological order - newest change first)
  */

    l_prof_set             VARCHAR2(1) ;
    g_terminate_process    BOOLEAN  := FALSE ;
    g_skip_person          BOOLEAN  := FALSE ;
    g_skip_record          BOOLEAN  := FALSE ;
    g_skip_item_insert     BOOLEAN  := FALSE ;
    g_award_year_status    igf_ap_batch_aw_map.award_year_status_code%TYPE ;
    g_sys_award_year       igf_ap_batch_aw_map.sys_award_year%TYPE ;
    l_alternate_code       igs_ca_inst.alternate_code%TYPE ;
    l_rec_processed        NUMBER;
    l_rec_imported         NUMBER;
    l_rec_error            NUMBER;
    l_last_person_number   igf_aw_li_coa_ints.person_number%TYPE ;
    l_item_setup_found     BOOLEAN ;
    l_fa_base_id           igf_ap_fa_base_rec.base_id%TYPE;
    l_person_id            igf_ap_fa_base_rec.person_id%TYPE;
    l_dup_item_found       BOOLEAN;
    l_dup_coa_found        BOOLEAN;
    l_per_terms_match      BOOLEAN;
    l_oss_terms_match      BOOLEAN;
    l_error                igf_lookups_view.meaning%TYPE ;
    l_person_number        igf_lookups_view.meaning%TYPE ;
    l_token                VARCHAR2(60) ;
    l_item_amount          igf_aw_coa_items.amount%TYPE := 0;
    lv_rowid               ROWID ;
    lv_term_rowid          ROWID ;
    l_last_coa             igf_aw_coa_items.item_code%TYPE;
    l_per_item_count       NUMBER ;
    l_batch_valid          VARCHAR2(1) ;
    l_rec_type             VARCHAR2(1) ;
    l_recs_deleted         BOOLEAN ;
    l_term_chk             BOOLEAN ;
    l_counter_flag         BOOLEAN ;
    -- masehgal   latest ...
    -- as soon as 1 record for a person is marked as error record, we need to skip the whole person
    -- using person_all_skip flag for the same
    g_person_all_skip      BOOLEAN ;
    -- this will get set as soon as any one record for a person is errored
    -- will get reset for a new person


    -- cursor to get sys award year and award year status
    CURSOR c_get_stat IS
       SELECT award_year_status_code, sys_award_year
         FROM igf_ap_batch_aw_map   map
        WHERE map.ci_cal_type         = g_ci_cal_type
          AND map.ci_sequence_number  = g_ci_sequence_number ;

    -- cursor to get persons for import
    CURSOR  c_get_persons ( cp_alternate_code  igf_aw_li_coa_ints.ci_alternate_code%TYPE,
                            cp_batch_num       igf_aw_li_coa_ints.batch_num%TYPE ) IS
       SELECT  batch_num,
               coaint_id,
               ci_alternate_code,
               person_number,
               item_code,
               pell_coa_amt,
               alt_pell_expense_amt,
               NVL(fixed_cost_flag,'N') fixed_cost_flag,
               ld_alternate_code,
               term_amt,
               import_status_type,
               import_record_type
         FROM igf_aw_li_coa_ints
        WHERE ci_alternate_code = cp_alternate_code
          AND batch_num         = cp_batch_num
          AND import_status_type IN ('R','U')
     ORDER BY person_number , item_code, ld_alternate_code;

    person_rec    c_get_persons%ROWTYPE ;

    -- cursor to get alternate code for award year
    CURSOR c_alternate_code( cp_ci_cal_type         igs_ca_inst.cal_type%TYPE ,
                             cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE ) IS
       SELECT alternate_code
         FROM igs_ca_inst
        WHERE cal_type        = cp_ci_cal_type
          AND sequence_number = cp_ci_sequence_number ;

    -- check COA Setup done
    CURSOR c_chk_coa (p_item_code  igf_aw_li_coa_ints.item_code%TYPE) IS
       SELECT 1
         FROM igf_aw_item
        WHERE item_code = NVL(p_item_code, item_code)
          AND rownum = 1;
    l_coa_exist   NUMBER ;

    -- cursor for items update
    CURSOR cur_get_items (cp_base_id   igf_aw_coa_itm_terms.base_id%TYPE,
                          cp_item_code igf_aw_coa_itm_terms.item_code%TYPE) IS
       SELECT items.rowid,items.*
         FROM igf_aw_coa_items items
        WHERE base_id   = cp_base_id
          AND item_code = cp_item_code ;
    l_item_rec   cur_get_items%ROWTYPE ;

    CURSOR cur_get_cal_info ( cp_alternate_code  igs_ca_inst.alternate_code%TYPE )  IS
       SELECT cal_type, sequence_number
         FROM igs_ca_inst
        WHERE alternate_code = cp_alternate_code ;

    l_load_cal_type    igs_ca_inst.cal_type%TYPE ;
    l_load_seq_num     igs_ca_inst.sequence_number%TYPE ;

    l_old_item         igf_aw_coa_items.item_code%TYPE;

   BEGIN
	  igf_aw_gen.set_org_id(NULL);
      errbuf  := NULL;
      retcode := 0;
      l_prof_set := 'N' ;
      l_error    := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
      l_person_number := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');


      -- Check if the following profiles are set
      l_prof_set :=  igf_ap_gen.check_profile ;

      IF l_prof_set = 'Y' THEN
         -- profiles properly set  ....... proceed
         /**************************
         Batch Level Checks
         **************************/

         -- Get the Award Year Calender Type and the Sequence Number
         g_ci_cal_type        := RTRIM(SUBSTR(p_award_year,1,10));
         g_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));

         -- Get the Award Year Alternate Code
         OPEN  c_alternate_code( g_ci_cal_type, g_ci_sequence_number ) ;
         FETCH c_alternate_code INTO l_alternate_code ;
         CLOSE c_alternate_code ;

         -- Log input params
         log_input_params( p_batch_num, l_alternate_code , p_delete_flag);
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_coa_imp.main.debug','Completed input parameters logging in Procedure main');
         END IF;

         -- Get Award Year Status
         OPEN  c_get_stat ;
         FETCH c_get_stat INTO g_award_year_status, g_sys_award_year ;
         -- check validity of award year
         IF c_get_stat%NOTFOUND THEN
            -- Award Year setup tampered .... Log a message
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_AWD_YR_NOT_FOUND');
            FND_MESSAGE.SET_TOKEN('P_AWARD_YEAR', l_alternate_code);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            g_terminate_process := TRUE ;
         ELSE
            -- Award year exists but is it Open/Legacy Details .... check
            IF g_award_year_status NOT IN ('O','LD') THEN
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_LG_INVALID_STAT');
               FND_MESSAGE.SET_TOKEN('AWARD_STATUS', g_award_year_status);
               FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
               g_terminate_process := TRUE ;
            END IF ; -- awd ye open or legacy detail chk
         END IF ; -- award year invalid check
         CLOSE c_get_stat ;

         -- check COA Setup
         OPEN  c_chk_coa ( NULL);
         FETCH c_chk_coa INTO l_coa_exist ;
         -- if no COA Item found
         IF c_chk_coa%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_COA_SETUP_INCOM');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            -- set terminate flag
            g_terminate_process := TRUE ;
         END IF ; -- setup check in interface table
         CLOSE c_chk_coa ;

         -- check validity of batch
         l_batch_valid := igf_ap_gen.check_batch ( p_batch_num, 'COA') ;
         IF NVL(l_batch_valid,'N') <> 'Y' THEN
            FND_MESSAGE.SET_NAME('IGF','IGF_GR_BATCH_DOES_NOT_EXIST');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            g_terminate_process := TRUE ;
         END IF;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_coa_imp.main.debug','Completed batch validations in Procedure main');
         END IF;

         /***********************************************************************
         Person Level checks
         l_rec_processed  flag to monitor the number of records in the batch
         submitted for processing
         l_last_person_number Holds the last processed Person Number
         ***********************************************************************/

         -- check for terminate flag
         IF NOT g_terminate_process THEN
            l_last_person_number  := NULL ;
            l_rec_processed       := 0 ;
            l_per_item_count      := 0 ;
            l_rec_imported        := 0 ;

            -- Set an initial savepoint
            SAVEPOINT coa_person_recs ;
            l_counter_flag  := FALSE ;

            -- Select persons from interface table
            FOR person_rec IN c_get_persons (l_alternate_code, p_batch_num)
            LOOP
               -- validate each person
               l_counter_flag  := FALSE ;
               g_skip_record   := FALSE ;


               -- check if this person has been processed before ....
               -- if yes, then skip the person related validations re-check
               IF person_rec.person_number <> NVL(l_last_person_number,'*') THEN
                       -- code here for person terms validations and rollback/commit
                  IF l_last_person_number IS NOT NULL THEN

                     IF l_per_item_count > 0 THEN  -- only if some inserts have happened for the person

                        -- masehgal   latest ...
                        -- as soon as 1 record for a person is marked as error record, we need to skip the whole person
                        -- using person_all_skip flag for the same
                        -- from here  ....
                        IF g_person_all_skip THEN

                           ROLLBACK TO coa_person_recs ;

                           -- mark all person records as "E"
                           UPDATE igf_aw_li_coa_ints
                              SET import_status_type = 'E'
                            WHERE batch_num     = p_batch_num
                              AND person_number = l_last_person_number ;

                            l_rec_imported :=  l_rec_imported -  l_per_item_count;
                           COMMIT ;
                           g_skip_person := TRUE ;
                        ELSE

                           igf_aw_gen_003.updating_coa_in_fa_base(l_fa_base_id);

                           -- ELSE do the terms match check ...
                           -- This particular terms match check has to happen after the insertion of individual records
                           IF g_award_year_status = 'O' THEN

                              -- coa terms match
                              check_person_terms (  l_fa_base_id, l_per_terms_match) ;
                              IF NOT l_per_terms_match THEN

                                 FND_MESSAGE.SET_NAME('IGF','IGF_AP_COA_TERM_DIFF');
                                 g_log_tab_index := g_log_tab_index + 1;
                                 g_log_tab(g_log_tab_index).person_number := l_last_person_number;
                                 g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;

                                 --  Now rollback ....
                                 ROLLBACK TO coa_person_recs ;

                                 -- mark all person records as "E"
                                 UPDATE igf_aw_li_coa_ints
                                    SET import_status_type = 'E'
                                  WHERE batch_num     = p_batch_num
                                    AND person_number = l_last_person_number ;
                                  l_rec_imported :=  l_rec_imported -  l_per_item_count;
                                 COMMIT ;
                                 g_skip_person := TRUE ;
                              ELSE

                                 -- commit for the person --- terms matched
                                 COMMIT;
                              END IF ; -- person terms match
                              COMMIT; -- if award year is not open then no check for terms match ...direct commit
                           END IF ; -- award year status check
                        END IF ; -- no records errored check
                     END IF ;
         l_counter_flag := FALSE;
                  END IF ;

                  -- new person ..
                  -- issue SAVEPOINT
                  SAVEPOINT coa_person_recs ;
                  -- set skip flag for the new person to FALSE
                  g_skip_person := FALSE ;
                  -- masehgal   latest ...
                  -- as soon as 1 record for a person is marked as error record, we need to skip the whole person
                  -- using person_all_skip flag for the same
                  g_person_all_skip := FALSE ;

                  l_last_coa := NULL;
                  l_per_item_count := 0 ;
                  l_old_item := NULL ;
                  l_recs_deleted := FALSE ;

                  -- call procedure to check person existence and fa base rec existence
                  igf_ap_gen.check_person ( person_rec.person_number, g_ci_cal_type, g_ci_sequence_number,
                                            l_person_id, l_fa_base_id) ;

                  IF l_person_id IS NULL THEN

                     FND_MESSAGE.SET_NAME('IGF','IGF_AP_PE_NOT_EXIST');
                     g_log_tab_index := g_log_tab_index + 1;
                     g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                     g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                     g_skip_person := TRUE ;
                  ELSIF l_fa_base_id IS NULL THEN

                     FND_MESSAGE.SET_NAME('IGF','IGF_AP_FABASE_NOT_FOUND');
                     g_log_tab_index := g_log_tab_index + 1;
                     g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                     g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                     g_skip_person := TRUE ;
                  END IF ; -- person existence check

                  --check if ALL person records aer marked either for insert or for update
                  -- If not , log a message, skip the person
                  chk_per_rec_stat( p_batch_num, l_alternate_code, person_rec.person_number, l_rec_type ) ;

                  IF l_rec_type = 'E' THEN

                     FND_MESSAGE.SET_NAME('IGF','IGF_AP_PER_RECS_NOT_SAME');
                     g_log_tab_index := g_log_tab_index + 1;
                     g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                     g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                     g_skip_person := TRUE ;
                  END IF ;



               END IF ;  -- person already processed check

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_coa_imp.main.debug','Completed person validations in Procedure main');
               END IF;
               /* End Of Person level Check */
               /**************************************************
               COA Item Level checks
               ***************************************************/

               -- Check for person skip flag
               IF g_skip_person THEN

                  -- person skip flag set....
                  -- if flag set then the person related records aer to be marked as error records and skipped
                  -- update all person records to error status
                  UPDATE igf_aw_li_coa_ints
                     SET import_status_type = 'E'
                   WHERE batch_num = p_batch_num
                     AND person_number = person_rec.person_number ;

                   l_rec_imported :=  l_rec_imported -  l_per_item_count;

                  COMMIT ;

               ELSE  -- person not to b skipped

                  -- Item level validations ...
                  l_token := person_rec.item_code || ' COAINT_ID - ' || TO_CHAR(person_rec.coaint_id) ;
                  FND_MESSAGE.SET_NAME('IGF','IGF_AP_PROC_ITM');
                  FND_MESSAGE.SET_TOKEN('ITEM', l_token );
                  g_log_tab_index := g_log_tab_index + 1;
                  g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                  g_log_tab(g_log_tab_index).message_text  := fnd_message.get;

                  -- coa item present in set up
                  OPEN  c_chk_coa ( person_rec.item_code);
                  FETCH c_chk_coa INTO l_coa_exist ;
                  -- if no COA Item found

                  IF c_chk_coa%NOTFOUND THEN

                     FND_MESSAGE.SET_NAME('IGF','IGF_AP_COA_INVALID_ITM');
                     FND_MESSAGE.SET_TOKEN('ITEM', person_rec.item_code);
                     g_log_tab_index := g_log_tab_index + 1;
                     g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                     g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                     g_skip_record := TRUE ;
                     -- masehgal   latest ...
                     -- as soon as 1 record for a person is marked as error record, we need to skip the whole person
                     -- using person_all_skip flag for the same
                     g_person_all_skip := TRUE ;

                  END IF ;
                  CLOSE c_chk_coa ;

                  /*  End of COA Existence Check */
                  /******************************************
                  COA ITEM Instance related Checks
                  *******************************************/
                  l_term_chk := igf_ap_gen.validate_cal_inst( 'LOAD', l_alternate_code, person_rec.ld_alternate_code,
                                                              l_load_cal_type, l_load_seq_num) ;

                  IF (l_load_cal_type IS NULL OR l_load_seq_num IS NULL) THEN
                     FND_MESSAGE.SET_NAME('IGF','IGF_AP_INVALID_TERM');
                     FND_MESSAGE.SET_TOKEN('TERM', person_rec.ld_alternate_code);
                     g_log_tab_index := g_log_tab_index + 1;
                     g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                     g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                     g_skip_record := TRUE ;

                     -- masehgal   latest ...
                     -- as soon as 1 record for a person is marked as error record, we need to skip the whole person
                     -- using person_all_skip flag for the same
                     g_person_all_skip := TRUE ;

                     g_skip_item_insert := TRUE ;
                  ELSIF NOT l_term_chk THEN

                     FND_MESSAGE.SET_NAME('IGF','IGF_AP_AWD_TERM_INVALID');
                     FND_MESSAGE.SET_TOKEN('TERM', person_rec.ld_alternate_code);
                     FND_MESSAGE.SET_TOKEN('AWARD', l_alternate_code);
                     g_log_tab_index := g_log_tab_index + 1;
                     g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                     g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                     g_skip_record := TRUE ;
                     -- masehgal   latest ...
                     -- as soon as 1 record for a person is marked as error record, we need to skip the whole person
                     -- using person_all_skip flag for the same
                     g_person_all_skip := TRUE ;

                     g_skip_item_insert := TRUE ;
                  END IF ; --

                  -- coa item duplicate
                  check_dup_coa ( person_rec.item_code, l_fa_base_id, l_dup_coa_found) ;
                  IF l_dup_coa_found AND l_rec_type <> 'U' THEN

                     -- no message for duplicate item as term may be different
                     g_skip_item_insert := TRUE ;
                     -- do not log a message for duplicate coa item ... only for coa term
                  ELSE

                     g_skip_item_insert := FALSE ;

                  END IF ;

                  IF (NOT l_dup_coa_found) AND (NOT l_recs_deleted) AND l_rec_type = 'U'  THEN

                     -- log a message for duplicate
                     FND_MESSAGE.SET_NAME('IGF','IGF_AP_ORIG_REC_NOT_FOUND');
                     g_log_tab_index := g_log_tab_index + 1;
                     g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                     g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                     g_skip_record := TRUE ;
                     -- masehgal   latest ...
                     -- as soon as 1 record for a person is marked as error record, we need to skip the whole person
                     -- using person_all_skip flag for the same
                     g_person_all_skip := TRUE ;

                     g_skip_item_insert := TRUE ;
                  END IF ; --


                  -- coa item term duplicate
                  -- to be performed only if item is already present ...
                  IF l_dup_coa_found THEN

                     check_dup_coa_term ( person_rec.item_code, l_load_cal_type, l_load_seq_num, l_fa_base_id, l_dup_item_found) ;

                     IF l_dup_item_found AND l_rec_type <> 'U'  THEN

                        -- log a message for duplicate
                        FND_MESSAGE.SET_NAME('IGF','IGF_AP_COA_ITM_TERM_EXIST');
                        FND_MESSAGE.SET_TOKEN('TERM', person_rec.ld_alternate_code);
                        g_log_tab_index := g_log_tab_index + 1;
                        g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                        g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                        g_skip_record := TRUE ;
                        -- masehgal   latest ...
                        -- as soon as 1 record for a person is marked as error record, we need to skip the whole person
                        -- using person_all_skip flag for the same
                        g_person_all_skip := TRUE ;

                     END IF ;
                     IF (NOT l_dup_item_found) AND (NOT l_recs_deleted) AND l_rec_type = 'U'  THEN

                        -- log a message for duplicate
                        FND_MESSAGE.SET_NAME('IGF','IGF_AP_ORIG_REC_NOT_FOUND');
                        g_log_tab_index := g_log_tab_index + 1;
                        g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                        g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                        g_skip_record := TRUE ;
                        -- masehgal   latest ...
                        -- as soon as 1 record for a person is marked as error record, we need to skip the whole person
                        -- using person_all_skip flag for the same
                        g_person_all_skip := TRUE ;

                     END IF ; --
                  END IF ;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_coa_imp.main.debug','Completed record validations in Procedure main');
                  END IF;

                  -- all record validations done ...
                  -- now check for skip record flag
                  IF g_skip_record THEN

                     UPDATE igf_aw_li_coa_ints
                        SET import_status_type = 'E'
                      WHERE coaint_id = person_rec.coaint_id ;
                     --    COMMIT ;
                  ELSE

                     -- check if the person is meant to be updated or fresh insert
                     -- if updatd, delete the previously exisiting all coa items ad terms
                     IF l_rec_type = 'U' AND (NOT l_recs_deleted) THEN

                        -- records exist
                        -- have to be deleted

                        delete_coa_terms ( l_fa_base_id );

                        delete_coa_items ( l_fa_base_id );
                        -- post delete set a flag that shud prevent the existing coa check for the same person
                        l_recs_deleted := TRUE ;
                     END IF ;

                     -- Now add records
                     l_per_item_count := l_per_item_count + 1 ;


--                     l_old_item_term  := NULL ;

                     IF person_rec.item_code <> NVL ( l_old_item, '*') THEN

                        IF NOT g_skip_item_insert THEN

                           -- new item ... add item and then add terms
                           l_item_amount := 0 ;

                           BEGIN

                           igf_aw_coa_items_pkg.insert_row(
                              x_rowid              =>  lv_rowid,
                              x_base_id            =>  l_fa_base_id,
                              x_item_code          =>  person_rec.item_code,
                              x_amount             =>  l_item_amount,
                              x_pell_coa_amount    =>  person_rec.pell_coa_amt,
                              x_alt_pell_amount    =>  person_rec.alt_pell_expense_amt,
                              x_fixed_cost         =>  person_rec.fixed_cost_flag,
                              x_legacy_record_flag => 'Y',
                              x_lock_flag          => 'N',
                              x_mode               =>  'R');

                           EXCEPTION WHEN OTHERS THEN
                            -- Note : checking is done in tbh . so re-validation avoided
                            fnd_message.set_name('IGF','IGF_AW_INCON_ITM_TERMS');
                            g_log_tab_index := g_log_tab_index + 1;
                            g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                            g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                            g_skip_record := TRUE ;
                            g_person_all_skip := TRUE ;

                           END;

                           l_old_item := person_rec.item_code ;

                        END IF ; -- item insertion skip check
                     END IF ;

                     -- now insert all the pertaining terms for the item
                     IF person_rec.item_code = l_old_item THEN
                        -- insert into the terms table

                            BEGIN

                        igf_aw_coa_itm_terms_pkg.insert_row(
                               x_rowid                => lv_term_rowid,
                               x_base_id              => l_fa_base_id,
                               x_item_code            => person_rec.item_code,
                               x_amount               => person_rec.term_amt,
                               x_ld_cal_type          => l_load_cal_type,
                               x_ld_sequence_number   => l_load_seq_num,
                               x_lock_flag            => 'N',
                               x_mode                 => 'R');

                           EXCEPTION WHEN OTHERS THEN
                            -- Note : checking is done in tbh . so re-validation avoided
                            fnd_message.set_name('IGF','IGF_AW_INCON_ITM_TERMS');
                            g_log_tab_index := g_log_tab_index + 1;
                            g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                            g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                            g_skip_record := TRUE ;
                            g_person_all_skip := TRUE ;

                           END;


                        -- increment the item amount by each term amount
                        l_item_amount := NVL(l_item_amount,0) + person_rec.term_amt ;
                     END IF ;  -- new item check ...

                     -- move update after person term check

                     -- now update the item amount
                     OPEN  cur_get_items ( l_fa_base_id, person_rec.item_code ) ;
                     FETCH cur_get_items INTO l_item_rec ;
                     CLOSE cur_get_items ;

                     igf_aw_coa_items_pkg.update_row (
                            x_rowid                => l_item_rec.rowid,
                            x_base_id              => l_fa_base_id,
                            x_item_code            => l_item_rec.item_code,
                            x_amount               => l_item_amount,
                            x_pell_coa_amount      => l_item_rec.pell_coa_amount,
                            x_alt_pell_amount      => l_item_rec.alt_pell_amount,
                            x_fixed_cost           => l_item_rec.fixed_cost,
                            x_legacy_record_flag   => 'Y',
                            x_lock_flag            => 'N',
                            x_mode                 => 'R' );


                     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_coa_imp.main.debug','Inserted COA record in Procedure main');
                     END IF;

                     -- now update the record status
                     IF p_delete_flag = 'Y' THEN
                        DELETE FROM igf_aw_li_coa_ints
                         WHERE coaint_id = person_rec.coaint_id ;

                         --   COMMIT ;
                     ELSE

                        UPDATE igf_aw_li_coa_ints
                           SET import_status_type = 'I'
                         WHERE coaint_id = person_rec.coaint_id ;
                         l_counter_flag := TRUE;

                        --   COMMIT ;
                     END IF ;

                  END IF ; -- skip record check

               END IF ; -- person skip flag check
               -- Reset the Last Person Processed
                IF l_last_person_number IS NOT NULL THEN
                   l_rec_processed := l_rec_processed + 1 ;
                END IF;
               l_last_person_number := person_rec.person_number;

                IF  l_counter_flag THEN
                        l_rec_imported   := l_rec_imported + 1 ;
                END IF;

            END LOOP ; -- person selection loop

            -- code here to check for terms of last person

           IF l_last_person_number IS NOT NULL THEN
              l_rec_processed := l_rec_processed + 1 ;

              IF l_per_item_count > 0 THEN  -- only if some inserts have happened for the person

                 -- masehgal   latest ...
                 -- as soon as 1 record for a person is marked as error record, we need to skip the whole person
                 -- using person_all_skip flag for the same
                 -- from here  ....
                 IF g_person_all_skip THEN

                    ROLLBACK TO coa_person_recs ;

                    -- mark all person records as "E"
                    UPDATE igf_aw_li_coa_ints
                       SET import_status_type = 'E'
                     WHERE batch_num     = p_batch_num
                       AND person_number = l_last_person_number ;


                     l_rec_imported :=  l_rec_imported -  l_per_item_count ;
                    COMMIT ;
                    g_skip_person := TRUE ;
                 ELSE

                    igf_aw_gen_003.updating_coa_in_fa_base(l_fa_base_id);

                    -- ELSE do the terms match check ...
                    -- This particular terms match check has to happen after the insertion of individual records
                    IF g_award_year_status = 'O' THEN
                       -- coa terms match

                       check_person_terms (  l_fa_base_id, l_per_terms_match) ;

                       IF NOT l_per_terms_match THEN

                          FND_MESSAGE.SET_NAME('IGF','IGF_AP_COA_TERM_DIFF');
                          g_log_tab_index := g_log_tab_index + 1;
                          g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                          g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;

                          --  Now rollback ....
                          ROLLBACK TO coa_person_recs ;

                          -- mark all person records as "E"
                          UPDATE igf_aw_li_coa_ints
                             SET import_status_type = 'E'
                           WHERE batch_num     = p_batch_num
                             AND person_number = l_last_person_number ;
 --                          AND item_code     = person_rec.item_code;

                             l_rec_imported :=  l_rec_imported -  l_per_item_count;
                          COMMIT ;

                          g_skip_person := TRUE ;
                       ELSE
                          -- commit ofr last person whose terms matched
                          COMMIT;
                       END IF ; -- person terms match
                       COMMIT; -- if award year is not open then no check for terms match ...direct commit
                    END IF ; -- award year status check
                 END IF ; -- any record errored check !!
              END IF ;
           END IF ;  -- end of last person terms verification



            IF l_rec_processed = 0 THEN
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_AWDYR_STAT_NOT_EXISTS');
               FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            ELSE
               -- CALL THE PRINT LOG PROCESS
               print_log_process(l_person_number,l_error);
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('IGS','IGS_GE_TOTAL_REC_PROCESSED'),50)|| TO_CHAR(l_rec_processed) );
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('IGS','IGS_GE_TOTAL_REC_FAILED'),50)|| TO_CHAR(l_rec_processed - l_rec_imported));
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC'),50)|| TO_CHAR(l_rec_imported));

               IF l_rec_imported = 0 THEN
                  FND_FILE.PUT_LINE( FND_FILE.OUTPUT, ' ');
                  FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '-------------------------------------------------------------');
                  FND_FILE.PUT_LINE( FND_FILE.OUTPUT, ' ');
                  FND_MESSAGE.SET_NAME('IGS','IGS_EN_NO_DATA_IMP' );
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET);
               END IF ;
            END IF ;

         END IF ; -- terminate flag check

      ELSE -- profile check
         -- error message
         -- terminate the process .. no further processing
         FND_MESSAGE.SET_NAME('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF ; -- profile check ends

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_coa_imp.main.exception','Unhandled exception in Procedure main'||SQLERRM);
      END IF;
      RETCODE := 2 ;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP') ;
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_LG_COA_IMP.MAIN') ;
      errbuf := FND_MESSAGE.GET ;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;

   END main ;

   END  igf_ap_lg_coa_imp ;

/
