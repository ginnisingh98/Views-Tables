--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_013
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_013" AS
/* $Header: IGSAD91B.pls 120.1 2006/04/13 05:52:25 stammine noship $ */
/*Change History
||  Who          When              What
|| ssaleem       13_OCT_2003     Bug : 3130316
||                               Logging is modified to include logging mechanism
||  pkpatel      18-MAY-2003       Bug 2853521
||                                 Removed the procedure prc_address_usages since it was not getting used anywhere
*/


/***************************Status,Discrepancy Rule, Match Indicators, Error Codes********************/
-- Added the local package variables as part of Import process enhancements
	cst_rule_val_I  CONSTANT VARCHAR2(1) := 'I';
	cst_rule_val_E CONSTANT VARCHAR2(1) := 'E';
	cst_rule_val_R CONSTANT VARCHAR2(1) := 'R';


	cst_mi_val_11 CONSTANT  VARCHAR2(2) := '11';
	cst_mi_val_12  CONSTANT VARCHAR2(2) := '12';
	cst_mi_val_13  CONSTANT VARCHAR2(2) := '13';
	cst_mi_val_14  CONSTANT VARCHAR2(2) := '14';
	cst_mi_val_15  CONSTANT VARCHAR2(2) := '15';
	cst_mi_val_16  CONSTANT VARCHAR2(2) := '16';
	cst_mi_val_17  CONSTANT VARCHAR2(2) := '17';
        cst_mi_val_18  CONSTANT VARCHAR2(2) := '18';
	cst_mi_val_19  CONSTANT VARCHAR2(2) := '19';
	cst_mi_val_20  CONSTANT VARCHAR2(2) := '20';
        cst_mi_val_21  CONSTANT VARCHAR2(2) := '21';
	cst_mi_val_22  CONSTANT VARCHAR2(2) := '22';
	cst_mi_val_23  CONSTANT VARCHAR2(2) := '23';
	cst_mi_val_24  CONSTANT VARCHAR2(2) := '24';
	cst_mi_val_25  CONSTANT VARCHAR2(2) := '25';
        cst_mi_val_27  CONSTANT VARCHAR2(2) := '27';

	cst_s_val_1  CONSTANT   VARCHAR2(1) := '1';
        cst_s_val_2  CONSTANT VARCHAR2(1) := '2';
	cst_s_val_3  CONSTANT VARCHAR2(1) := '3';
	cst_s_val_4  CONSTANT VARCHAR2(1) := '4';

       cst_ec_val_E322 CONSTANT VARCHAR2(4) := 'E322';
       cst_ec_val_E014 CONSTANT VARCHAR2(4) := 'E014';
       cst_ec_val_NULL CONSTANT VARCHAR2(4)  := NULL;

       cst_insert  CONSTANT VARCHAR2(20) :=  'INSERT';
       cst_update CONSTANT VARCHAR2(20) :=  'UPDATE';
       cst_first_row CONSTANT VARCHAR2(20) :=  'FIRST ROW';
       cst_partial_update CONSTANT VARCHAR2(20) :=  'PARTIAL UPDATE';
       cst_unique_record  CONSTANT  NUMBER :=  1;
       l_request_id  CONSTANT NUMBER :=  fnd_global.conc_request_id;
/***************************Status,Discrepancy Rule, Match Indicators, Error Codes*******************/

PROCEDURE prc_pe_type(
 p_source_type_id IN NUMBER,
 p_batch_id IN NUMBER
 )
AS
 /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 06-Jul-2001
  ||  Purpose : This procedure is for importing person type Information.
  ||            DLD: Import Person Type.  Enh Bug# 2853521.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
 */

   l_rule                     VARCHAR2(1);
   l_staff_person_type_code   igs_pe_person_types.person_type_code%TYPE;
   l_faculty_person_type_code igs_pe_person_types.person_type_code%TYPE;
   l_system_type              igs_pe_person_types.system_type%TYPE;
   l_error_code               VARCHAR2(30);
   l_discp_exists             VARCHAR2(1);
   l_processed_records        NUMBER(5) := 0;
   l_var                      VARCHAR2(1);
   l_default_date             DATE ;
   l_hr_installed             VARCHAR2(1);

   l_prog_label  VARCHAR2(100);
   l_label  VARCHAR2(100);
   l_debug_str VARCHAR2(2000);
   l_enable_log VARCHAR2(1);
   l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
   -- Cursor to select all the pending records.
   CURSOR per_type_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
   SELECT pty.*, i.person_id
   FROM   igs_pe_type_int pty,
          igs_ad_interface_all i
   WHERE pty.interface_id = i.interface_id AND
         pty.status = '2' AND
         pty.interface_run_id = cp_interface_run_id AND
	 i.interface_run_id = cp_interface_run_id;

   -- Cursor to check for duplicate record
   CURSOR dup_per_type_cur(cp_person_id igs_ad_interface_all.person_id%TYPE,
                           cp_person_type_code igs_pe_type_int.person_type_code%TYPE,
                           cp_start_date igs_pe_type_int.start_date%TYPE) IS
   SELECT rowid,type_instance_id, end_date,emplmnt_category_code
   FROM   igs_pe_typ_instances_all
   WHERE person_id = cp_person_id AND
         UPPER(person_type_code) = UPPER(cp_person_type_code) AND
         TRUNC(start_date) = TRUNC(cp_start_date);

   dup_per_type_rec dup_per_type_cur%ROWTYPE;


   -- Cursor to check HR Mapping
   CURSOR hr_map_cur(cp_system_type igs_pe_person_types.system_type%TYPE) IS
   SELECT person_type_code
   FROM   igs_pe_per_type_map_v
   WHERE  system_type = cp_system_type;

   -- Cursor to check whether any Staff/Faculty records are present
   CURSOR type_exist_cur(cp_person_type_code igs_pe_person_types.person_type_code%TYPE,
                         cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
   SELECT 'X'
   FROM   igs_pe_type_int pty
   WHERE  pty.status = '2' AND
          pty.person_type_code = cp_person_type_code AND
          pty.interface_run_id = cp_interface_run_id;


  -- Private procedure to create person type
  PROCEDURE create_person_type(
               p_person_type_rec IN per_type_cur%ROWTYPE,
               p_system_type    IN igs_pe_person_types.system_type%TYPE,
               p_default_date   IN DATE
             )
   AS
   lv_rowid  ROWID;
   l_ended_by    fnd_user.user_name%TYPE;
   l_end_method  VARCHAR2(30);
   l_type_instance_id igs_pe_typ_instances_all.type_instance_id%TYPE;
   l_message_name VARCHAR2(30);
   l_app          VARCHAR2(50);
   l_error_code   VARCHAR2(30);
   l_exists       VARCHAR2(1);

   CURSOR user_name_cur(cp_user_id fnd_user.user_id%TYPE) IS
   SELECT user_name
   FROM  fnd_user
   WHERE user_id = cp_user_id;

   CURSOR date_overlap(cp_person_id igs_ad_interface.person_id%TYPE,
                       cp_person_type_code igs_pe_type_int.person_type_code%TYPE,
                       cp_start_date igs_pe_type_int.start_date%TYPE,
                       cp_end_date   igs_pe_type_int.end_date%TYPE,
					   cp_default_date DATE) IS
   SELECT 'Y'
   FROM   igs_pe_typ_instances_all
   WHERE  person_id = cp_person_id AND
          person_type_code = cp_person_type_code AND
        ( NVL(cp_end_date,cp_default_date) BETWEEN start_date AND NVL(end_date,cp_default_date)
          OR  cp_start_date BETWEEN start_date AND NVL(end_date,cp_default_date)
          OR ( cp_start_date < start_date AND
          NVL(end_date,cp_default_date) < NVL(cp_end_date,cp_default_date)));

   CURSOR emp_cat_status(cp_person_id igs_ad_interface.person_id%TYPE,
                         cp_start_date igs_pe_type_int.start_date%TYPE,
                         cp_end_date   igs_pe_type_int.end_date%TYPE,
  			 cp_default_date DATE) IS
   SELECT NULL
   FROM igs_pe_typ_instances_all typ,igs_pe_person_types sys
   WHERE typ.person_id = cp_person_id AND
         sys.person_type_code = typ.person_type_code AND
         sys.system_type IN ('FACULTY','STAFF')  AND
	 ( NVL(cp_end_date,cp_default_date) BETWEEN typ.start_date AND  NVL(typ.end_date,cp_default_date)
         OR  cp_start_date BETWEEN typ.start_date AND NVL(typ.end_date,cp_default_date)
         OR ( cp_start_date < typ.start_date AND
         NVL(typ.end_date,cp_default_date) < NVL(cp_end_date,cp_default_date))) AND
         typ.emplmnt_category_code IS  NOT NULL;

   BEGIN

	-- Overlap check need not be done for 'USER_DEFINED' system type
        IF p_system_type <> 'USER_DEFINED' THEN
           OPEN date_overlap(p_person_type_rec.person_id,
                             p_person_type_rec.person_type_code,
                             p_person_type_rec.start_date,
                             p_person_type_rec.end_date,
							 p_default_date);
           FETCH date_overlap INTO l_exists;
             IF date_overlap%FOUND THEN
                CLOSE date_overlap;
                UPDATE igs_pe_type_int
                SET status = '3',
                    error_code = 'E295'
                WHERE interface_person_type_id = p_person_type_rec.interface_person_type_id;
                IF l_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(p_person_type_rec.interface_person_type_id,'E295');
                END IF;
                RETURN;
             END IF;
             CLOSE date_overlap;
        END IF;

        IF p_person_type_rec.emplmnt_category_code IS NOT NULL THEN
           IF p_system_type IN ('FACULTY','STAFF') THEN
              OPEN emp_cat_status(p_person_type_rec.person_id,
                             p_person_type_rec.start_date,
                             p_person_type_rec.end_date,
		   	     p_default_date);
              FETCH emp_cat_status INTO l_exists;
              IF emp_cat_status%FOUND THEN
                CLOSE emp_cat_status;

                UPDATE igs_pe_type_int
                SET status = '3',
                    error_code = 'E585'
                WHERE interface_person_type_id = p_person_type_rec.interface_person_type_id;

                IF l_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(p_person_type_rec.interface_person_type_id,'E585');
                END IF;
                RETURN;
             END IF;
           CLOSE emp_cat_status;
           END IF;
        END IF;

     IF p_person_type_rec.end_date IS NOT NULL THEN

	l_ended_by   := fnd_global.user_id;
        l_end_method := 'END_IMPORT';
     ELSE
        l_ended_by := NULL;
        l_end_method := NULL;
     END IF;

        igs_pe_typ_instances_pkg.insert_row
                (
                 x_rowid                        => lv_rowid,
                 x_person_id                    => p_person_type_rec.person_id,
                 x_course_cd                    => null,
                 x_type_instance_id             => l_type_instance_id,
                 x_person_type_code             => p_person_type_rec.person_type_code,
                 x_cc_version_number            => null,
                 x_funnel_status                => null,
                 x_admission_appl_number        => null,
                 x_nominated_course_cd          => null,
                 x_ncc_version_number           => null,
                 x_sequence_number              => null,
                 x_start_date                   => p_person_type_rec.start_date,
                 x_end_date                     => p_person_type_rec.end_date,
                 x_create_method                => 'CREATE_IMPORT',
                 x_ended_by                     => l_ended_by,
                 x_end_method                   => l_end_method,
                 x_org_id                       => null,
                 x_emplmnt_category_code        => p_person_type_rec.emplmnt_category_code
                 );

        UPDATE igs_pe_type_int
        SET    status = '1'
        WHERE  interface_person_type_id = p_person_type_rec.interface_person_type_id;

   EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

        IF l_message_name IN ('IGS_AD_PROSPCT_XST_NO_EVAL','IGS_AD_EVAL_XST_NO_PROSPCT') THEN
            l_error_code := 'E294';
        ELSE
            l_error_code := 'E322';

            IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN


               l_label := 'igs.plsql.igs_ad_imp_013.prc_pe_type.exception';

               fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
               fnd_message.set_token('INTERFACE_ID',p_person_type_rec.interface_person_type_id);
               fnd_message.set_token('ERROR_CD',l_error_code);

               l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

               fnd_log.string_with_context( fnd_log.level_exception,
                                            l_label,
		      	                    l_debug_str, NULL,
			                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
            END IF;
        END IF;

        IF l_enable_log = 'Y' THEN
             igs_ad_imp_001.logerrormessage(p_person_type_rec.interface_person_type_id,l_error_code);
        END IF;


        UPDATE igs_pe_type_int
        SET    status = '3',
               error_code = l_error_code
        WHERE  interface_person_type_id = p_person_type_rec.interface_person_type_id;

   END create_person_type;

  -- Private procedure to update person type
   PROCEDURE update_person_type(p_person_type_rec IN per_type_cur%ROWTYPE,
                p_type_instance_id IN igs_pe_typ_instances_all.type_instance_id%TYPE,
   	        p_rowid           IN  ROWID,
                p_end_date        IN igs_pe_typ_instances_all.end_date%TYPE,
                p_emplmnt_category_code IN igs_pe_typ_instances_all.emplmnt_category_code%TYPE,
                p_system_type     IN igs_pe_person_types.system_type%TYPE,
                p_default_date     IN DATE)
   AS

   l_ended_by    fnd_user.user_id%TYPE;
   l_end_method  VARCHAR2(30);
   l_type_instance_id igs_pe_typ_instances_all.type_instance_id%TYPE;
   l_message_name VARCHAR2(30);
   l_app          VARCHAR2(50);
   l_error_code   VARCHAR2(30);
   l_exists       VARCHAR2(1);

   CURSOR user_name_cur(cp_user_id fnd_user.user_id%TYPE) IS
   SELECT user_name
   FROM  fnd_user
   WHERE user_id = cp_user_id;

   CURSOR date_overlap(cp_person_id igs_ad_interface.person_id%TYPE,
                       cp_person_type_code igs_pe_type_int.person_type_code%TYPE,
                       cp_start_date igs_pe_type_int.start_date%TYPE,
                       cp_end_date   igs_pe_type_int.end_date%TYPE,
		       cp_default_date DATE) IS
   SELECT 'Y'
   FROM   igs_pe_typ_instances_all
   WHERE  person_id = cp_person_id AND
          person_type_code = cp_person_type_code AND
          start_date <> cp_start_date AND
        ( NVL(cp_end_date,cp_default_date) BETWEEN start_date AND NVL(end_date,cp_default_date)
          OR  cp_start_date BETWEEN start_date AND NVL(end_date,cp_default_date)
          OR ( cp_start_date < start_date AND
          NVL(end_date,cp_default_date) < NVL(cp_end_date,cp_default_date)));

   CURSOR emp_cat_status(cp_person_id igs_ad_interface.person_id%TYPE,
                         cp_start_date igs_pe_type_int.start_date%TYPE,
                         cp_end_date   igs_pe_type_int.end_date%TYPE,
  					     cp_default_date DATE) IS
   SELECT null FROM igs_pe_typ_instances_all typ,igs_pe_person_types sys
   WHERE
         typ.person_id = cp_person_id AND
         sys.person_type_code = typ.person_type_code AND
         sys.system_type in ('FACULTY','STAFF')  AND
         p_rowid <> typ.rowid AND
	 ( NVL(cp_end_date,cp_default_date) BETWEEN typ.start_date AND  NVL(typ.end_date,cp_default_date)
         OR  cp_start_date BETWEEN typ.start_date AND NVL(typ.end_date,cp_default_date)
         OR ( cp_start_date < typ.start_date AND
         NVL(typ.end_date,cp_default_date) < NVL(cp_end_date,cp_default_date))) AND
         typ.emplmnt_category_code IS  NOT NULL;

   BEGIN

      -- Update only if end date is given and its different from what present in the OSS

        IF p_system_type <> 'USER_DEFINED' THEN
           OPEN date_overlap(p_person_type_rec.person_id,
                             p_person_type_rec.person_type_code,
                             p_person_type_rec.start_date,
                             p_person_type_rec.end_date,
							 p_default_date);
           FETCH date_overlap INTO l_exists;
             IF date_overlap%FOUND THEN
                CLOSE date_overlap;

                UPDATE igs_pe_type_int
                SET status = '3',
                    error_code = 'E295'
                WHERE interface_person_type_id = p_person_type_rec.interface_person_type_id;

                IF l_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(p_person_type_rec.interface_person_type_id,'E295');
                END IF;

                RETURN;
             END IF;
           CLOSE date_overlap;
        END IF;

        IF p_person_type_rec.emplmnt_category_code IS NOT NULL THEN
           IF p_system_type IN ('FACULTY','STAFF') THEN
              OPEN emp_cat_status(p_person_type_rec.person_id,
                             p_person_type_rec.start_date,
                             p_person_type_rec.end_date,
							 p_default_date);
              FETCH emp_cat_status INTO l_exists;
              IF emp_cat_status%FOUND THEN
                CLOSE emp_cat_status;

                UPDATE igs_pe_type_int
                SET status = '3',
                    error_code = 'E585'
                WHERE interface_person_type_id = p_person_type_rec.interface_person_type_id;

                IF l_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(p_person_type_rec.interface_person_type_id,'E585');
                END IF;

                RETURN;
             END IF;
           CLOSE emp_cat_status;
           END IF;
        END IF;

        IF p_person_type_rec.end_date IS NOT NULL AND
        (NVL(p_end_date,p_default_date) <> p_person_type_rec.end_date) THEN
                l_end_method := 'END_IMPORT';
        		l_ended_by   := fnd_global.user_id;
        END IF;

        igs_pe_typ_instances_pkg.update_row
                (
                 x_rowid                        => p_rowid,
                 x_person_id                    => p_person_type_rec.person_id,
                 x_course_cd                    => null,
                 x_type_instance_id             => p_type_instance_id,
                 x_person_type_code             => p_person_type_rec.person_type_code,
                 x_cc_version_number            => null,
                 x_funnel_status                => null,
                 x_admission_appl_number        => null,
                 x_nominated_course_cd          => null,
                 x_ncc_version_number           => null,
                 x_sequence_number              => null,
                 x_start_date                   => p_person_type_rec.start_date,
                 x_end_date                     => nvl(p_person_type_rec.end_date,p_end_date),
                 x_create_method                => 'CREATE_IMPORT',
                 x_ended_by                     => l_ended_by,
                 x_end_method                   => l_end_method,
                 x_emplmnt_category_code        => nvl(p_person_type_rec.emplmnt_category_code,p_emplmnt_category_code)
                 );

  --   END IF;

        UPDATE igs_pe_type_int
        SET    status = '1',
               match_ind = '18'
        WHERE  interface_person_type_id = p_person_type_rec.interface_person_type_id;

   EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

        IF l_message_name IN ('IGS_AD_PROSPCT_XST_NO_EVAL','IGS_AD_EVAL_XST_NO_PROSPCT') THEN
            l_error_code := 'E294';

        ELSE
            l_error_code := 'E014';

            IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN


               l_label := 'igs.plsql.igs_ad_imp_013.update_person_type.exception1';

               fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
               fnd_message.set_token('INTERFACE_ID',p_person_type_rec.interface_person_type_id);
               fnd_message.set_token('ERROR_CD',l_error_code);

               l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

               fnd_log.string_with_context( fnd_log.level_exception,
                                            l_label,
		      	                    l_debug_str, NULL,
			                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
            END IF;
        END IF;

        IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(p_person_type_rec.interface_person_type_id,l_error_code);
        END IF;

        UPDATE igs_pe_type_int
        SET    status = '3',
               error_code = l_error_code
        WHERE  interface_person_type_id = p_person_type_rec.interface_person_type_id;

   END update_person_type;

   PROCEDURE validate_record(p_person_type_rec IN per_type_cur%ROWTYPE,
                             p_system_type     OUT NOCOPY VARCHAR2,
                             p_error_code      OUT NOCOPY VARCHAR2,
                             p_hr_installed    IN VARCHAR2
                           )
   IS
     l_birth_date  igs_pe_person_base_v.birth_date%TYPE;

     CURSOR system_type_cur(cp_person_type_code igs_pe_type_int.person_type_code%TYPE)
     IS
     SELECT system_type
     FROM   igs_pe_person_types
     WHERE  person_type_code = cp_person_type_code
     AND    closed_ind = 'N';

     CURSOR birth_date_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE)
     IS
     SELECT birth_date
     FROM   igs_pe_person_base_v
     WHERE  person_id = cp_person_id;

     CURSOR chk_lkup_code(l_lookup_code igs_lookup_values.lookup_code%TYPE,
                    l_lookup_type igs_lookup_values.lookup_type%TYPE,
                    l_enabled_flag VARCHAR2)IS
     SELECT NULL FROM IGS_LOOKUP_VALUES
     WHERE lookup_type = l_lookup_type AND
           lookup_code = l_lookup_code AND
           enabled_flag = l_enabled_flag;

     l_var VARCHAR2(1);

   BEGIN

     -- person type code should be defined in OSS and active.
     OPEN system_type_cur(p_person_type_rec.person_type_code);
     FETCH system_type_cur INTO p_system_type;
        IF system_type_cur%NOTFOUND THEN
           p_error_code := 'E291';
           CLOSE system_type_cur;
           RETURN;
        END IF;
     CLOSE system_type_cur;

        -- person type code should not be a system defined one.
     IF p_system_type NOT IN('ADVISOR','EVALUATOR','EXTERNAL_CONTACT','FACULTY','STAFF','USER_DEFINED','INTERVIEWER') THEN
       p_error_code := 'E292';
       RETURN;
     END IF;

     -- Validation for Employment Category
     IF p_person_type_rec.emplmnt_category_code IS NOT NULL THEN

       -- check to see whether HR is installed and used
       IF P_HR_INSTALLED = 'Y' THEN
          p_error_code := 'E298';
          RETURN;
       END IF;

       --Validation to check that the person type imported is STAFF of FACULTY if the employment category is not null
       IF p_system_type NOT IN('FACULTY','STAFF') THEN
          p_error_code := 'E299';
          RETURN;
       END IF;

       -- <nsidana  9/23/2003 Commenting this code to validate the lookup as now we'll call the function to validate the code.>

/*     -- validation to check the employment category lookupcode
       OPEN chk_lkup_code(p_person_type_rec.emplmnt_category_code,'PE_EMP_CATEGORIES','Y');
       FETCH chk_lkup_code INTO l_var;
       IF chk_lkup_code%NOTFOUND THEN
          p_error_code := 'E297';
          CLOSE chk_lkup_code;
          RETURN;
       END IF;
       CLOSE chk_lkup_code;
*/

       -- Make a call to the function which checks for valid lookup type / code combination.

       IF NOT(igs_pe_pers_imp_001.validate_lookup_type_code('PE_EMP_CATEGORIES',p_person_type_rec.emplmnt_category_code,8405))
       THEN
            p_error_code := 'E297';
            RETURN;
       END IF;
    END IF;

     -- person type start date must not be a futire date
    IF p_person_type_rec.start_date > TRUNC(SYSDATE) THEN
       p_error_code := 'E296';
       RETURN;
    END IF;

     OPEN birth_date_cur(p_person_type_rec.person_id);
     FETCH birth_date_cur INTO l_birth_date;
     CLOSE birth_date_cur;

     -- person type start date must not be less than birth date of the person
     IF l_birth_date IS NOT NULL THEN
       IF p_person_type_rec.start_date < l_birth_date THEN
           p_error_code := 'E222';
           RETURN;
       END IF;
     END IF;

     -- person type end date must not be less than start date
     IF p_person_type_rec.end_date IS NOT NULL THEN
       IF p_person_type_rec.start_date > p_person_type_rec.end_date THEN
           p_error_code := 'E208';
           RETURN;
       END IF;
     END IF;

   END validate_record;

BEGIN
   l_default_date := igs_ge_date.igsdate('9999/01/01');

  l_prog_label := 'igs.plsql.igs_ad_imp_013.prc_pe_type';
  l_label := 'igs.plsql.igs_ad_imp_013.prc_pe_type.';
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_interface_run_id:=igs_ad_imp_001.g_interface_run_id; -- fetching the interface run ID from the AD imp process.
                                                         -- Every child records needs to be updated with this value.

    -- If HRMS is installed and HR mapping is done then update all the staff/faculty records as invalid.
    IF igs_en_gen_001.check_hrms_installed = 'Y' THEN
        OPEN  hr_map_cur('STAFF');
        FETCH hr_map_cur INTO l_staff_person_type_code;
        CLOSE hr_map_cur;

        IF l_staff_person_type_code IS NOT NULL THEN

		   OPEN type_exist_cur(l_staff_person_type_code,l_interface_run_id);
		   FETCH type_exist_cur INTO l_var;

			 IF type_exist_cur%FOUND THEN
                               UPDATE igs_pe_type_int pti
                               SET pti.status = '3',
                                    pti.error_code = 'E293'
                               WHERE person_type_code = l_staff_person_type_code AND
                                    status = '2' AND
                                    pti.interface_run_id = l_interface_run_id;

                IF l_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(l_staff_person_type_code,'E293');
                END IF;
		END IF;

                CLOSE type_exist_cur;

        END IF;


        OPEN  hr_map_cur('FACULTY');
        FETCH hr_map_cur INTO l_faculty_person_type_code;
        CLOSE hr_map_cur;

        IF l_faculty_person_type_code IS NOT NULL THEN
		   OPEN type_exist_cur(l_faculty_person_type_code,l_interface_run_id);
		   FETCH type_exist_cur INTO l_var;

		   IF type_exist_cur%FOUND THEN

			UPDATE igs_pe_type_int pti
			SET pti.status = '3',
			    pti.error_code = 'E293'
			WHERE person_type_code = l_faculty_person_type_code AND
			      status = '2' AND
			      interface_run_id = l_interface_run_id;

                    IF l_enable_log = 'Y' THEN
                      igs_ad_imp_001.logerrormessage(l_faculty_person_type_code,'E293');
                    END IF;
                  END IF;
          CLOSE type_exist_cur;
        END IF;
    END IF;

   l_hr_installed := IGS_PE_GEN_002.GET_HR_INSTALLED;

    -- <nsidana 9/24/2003 Import process enhancements>
    -- Fetching the discrepency rule before the loop.

    l_rule := igs_ad_imp_001.find_source_cat_rule(p_source_type_id, 'PERSON_TYPE');


    -- 1. If the rule is E or I, and the match ind column is not null, update all the records to status 3 as they are invalids.

    IF ((l_rule='E') OR (l_rule='I')) THEN
        UPDATE igs_pe_type_int pti
        SET status     = '3',
            error_code = 'E695'
        WHERE pti.status           = '2' AND
              pti.interface_run_id = l_interface_run_id AND
              pti.match_ind        IS NOT NULL;
    END IF;

       -- 2 . If rule is E and the match ind is null, we update the interface table for all duplicate records with status 1 and match ind 19.

    IF (l_rule = 'E') THEN
            UPDATE igs_pe_type_int pti
            SET    status    = '1',
                   match_ind = '19'
            WHERE  pti.status           = '2' AND
                   pti.interface_run_id = l_interface_run_id AND
                   pti.match_ind        IS NULL AND
                   EXISTS (SELECT 1
			    FROM igs_pe_typ_instances_all pi,
				 igs_ad_interface_all ai
	                    WHERE pti.interface_id    = ai.interface_id AND
			          ai.interface_run_id = l_interface_run_id AND
				  ai.person_id        = pi.person_id AND
	                          UPPER(pti.person_type_code) = UPPER(pi.person_type_code) AND
		                  TRUNC(pti.start_date)  = TRUNC(pi.start_date));
    END IF;

         -- 3. If rule is R and the record status is 18,19,22,23 these records have been processed, but didn't get updated. Update them to 1

    IF (l_rule='R') THEN
      UPDATE igs_pe_type_int pti
      SET status = '1'
      WHERE pti.status           = '2' AND
	   pti.interface_run_id = l_interface_run_id AND
	   pti.match_ind        IN ('18','19','22','23');
    END IF;


         -- 4. If rule is R and the match ind is not null and is neither 21 nor 25, update it to errored record.

    IF (l_rule = 'R') THEN
      UPDATE igs_pe_type_int pti
      SET    status = '3',
	     error_code = 'E695'
      WHERE  pti.status = '2' AND
	     pti.interface_run_id = l_interface_run_id AND
	     (pti.match_ind IS NOT NULL AND pti.match_ind NOT IN ('21','25'));
    END IF;


         -- 5. If rule = 'R' and there is no discprepency in duplicate records, update them to status 1 and match ind 23.

    IF (l_rule ='R') THEN
      UPDATE igs_pe_type_int pti
      SET   status = '1',
	    match_ind = '23'
      WHERE pti.status = '2' AND
	    pti.interface_run_id = l_interface_run_id AND
	    pti.match_ind IS NULL AND
	    EXISTS
	    (SELECT 1
	     FROM   igs_pe_typ_instances_all pi,
		    igs_ad_interface_all ai
	     WHERE  pti.interface_id     = ai.interface_id AND
	            ai.interface_run_id  = l_interface_run_id AND
		    ai.person_id         = pi.person_id AND
		    NVL(UPPER(pti.emplmnt_category_code),'*!*') = NVL(UPPER(pi.emplmnt_category_code),'*!*') AND
		    UPPER(pti.person_type_code) = UPPER(pi.person_type_code) AND
		    TRUNC(pti.start_date)= TRUNC(pi.start_date) AND
		    ((pti.end_date IS NULL AND pi.end_date IS NULL)
		      OR (TRUNC(pti.end_date) = TRUNC(pi.end_date)) ));
    END IF;

         -- 6. If rule is R and there are still some records, they are the ones for which there is some discrepency existing. Update them to status 3
         -- and value from the OSS table.

    IF (l_rule ='R') THEN
      UPDATE igs_pe_type_int pti
      SET   status='3',
	    match_ind='20',
	    dup_type_instance_id=(SELECT pi.type_instance_id
				  FROM   igs_pe_typ_instances_all pi,
					 igs_ad_interface_all ai
				  WHERE  pti.interface_id = ai.interface_id AND
				         ai.interface_run_id = l_interface_run_id AND
					 ai.person_id = pi.person_id AND
					 UPPER(pti.person_type_code)=UPPER(pi.person_type_code) AND
					 TRUNC(pti.start_date)=TRUNC(pi.start_date))
      WHERE  pti.status='2' AND
	    pti.interface_run_id = l_interface_run_id AND
	    pti.match_ind IS NULL AND
	    EXISTS
	    (SELECT 1
	     FROM igs_pe_typ_instances_all pi,
		  igs_ad_interface_all     ai
	     WHERE pti.interface_id=ai.interface_id AND
		  ai.interface_run_id = l_interface_run_id AND
		  ai.person_id = pi.person_id AND
		  UPPER(pti.person_type_code) = UPPER(pi.person_type_code) AND
		  TRUNC(pti.start_date) = TRUNC(pi.start_date));
    END IF;

    -- process the rest of the records.

    FOR per_type_rec IN per_type_cur(l_interface_run_id)
    LOOP
       l_processed_records := l_processed_records + 1;

       per_type_rec.start_date := TRUNC(per_type_rec.start_date);
       per_type_rec.end_date   := TRUNC(per_type_rec.end_date);
       per_type_rec.emplmnt_category_code := UPPER(per_type_rec.emplmnt_category_code);

       l_error_code := NULL;

        validate_record(per_type_rec,
                       l_system_type,
                       l_error_code,
                       l_hr_installed);

         -- All validation passed.
         IF l_error_code IS NULL THEN

            dup_per_type_rec.type_instance_id := NULL;
            dup_per_type_rec.end_date := NULL;

            -- Check for duplicate record.
            OPEN  dup_per_type_cur(per_type_rec.person_id,
                                   per_type_rec.person_type_code,
                                   per_type_rec.start_date);
            FETCH dup_per_type_cur INTO dup_per_type_rec;
            CLOSE dup_per_type_cur;

             -- Duplicate record. Process as per the rule defined.
            IF dup_per_type_rec.type_instance_id IS NOT NULL THEN
               IF l_rule = 'I' THEN
                   update_person_type(per_type_rec,
                                      dup_per_type_rec.type_instance_id,
             				dup_per_type_rec.rowid,
                                      dup_per_type_rec.end_date,
                                      dup_per_type_rec.emplmnt_category_code,
                                      l_system_type,
                                      l_default_date);

               ELSIF l_rule = 'R' THEN
                    IF per_type_rec.match_ind = '21' THEN
                         update_person_type(per_type_rec,
                                            dup_per_type_rec.type_instance_id,
					    dup_per_type_rec.rowid,
                                            dup_per_type_rec.end_date,
                                            dup_per_type_rec.emplmnt_category_code,
                                            l_system_type,
                                            l_default_date);
                    END IF;
               END IF;
            ELSE
               -- not found in OSS. Create a new one.
               create_person_type(per_type_rec,
                                  l_system_type,
                                  l_default_date);

            END IF;
         ELSE
		       -- Validation failed. Update with proper error code.

                UPDATE igs_pe_type_int
                SET    status = '3',
                       error_code = l_error_code
                WHERE  interface_person_type_id = per_type_rec.interface_person_type_id;

                IF l_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(per_type_rec.interface_person_type_id,l_error_code);
                END IF;
         END IF;

	     -- Commit for every 100 records..
	     IF l_processed_records >= 100 THEN
		    COMMIT;
	     END IF;
    END LOOP;

    -- Commit at the end if the staff/faculty records are processed or l_processed_records < 100
    COMMIT;
END prc_pe_type;

PROCEDURE prc_address_usages (
 p_source_type_id IN NUMBER,
 p_batch_id IN NUMBER )
IS
 /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 06-Jul-2001
  ||  Purpose : Stubbed the procedure since its not being used any where.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
 */
BEGIN
  NULL;
END prc_address_usages;



PROCEDURE PRC_PE_ACAD_HIST (
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2
) AS

-- Added to overcome snapshot-old error {Rollback segment Error }

l_min_interface_acadhis_id  igs_ad_acadhis_int_all.interface_acadhis_id%TYPE;
l_max_interface_acadhis_id  igs_ad_acadhis_int_all.interface_acadhis_id%TYPE;
l_count_interface_acadhis_id NUMBER;
l_total_records_prcessed NUMBER;
 CURSOR acad_hist(cp_min_interface_acadhis_id  igs_ad_acadhis_int_all.interface_acadhis_id%TYPE,
                  cp_max_interface_acadhis_id  igs_ad_acadhis_int_all.interface_acadhis_id%TYPE)
  IS
 -- Institution does not match so creating
     SELECT  cst_insert dmlmode, rowid, a.*
     FROM IGS_AD_ACADHIS_INT_ALL a
     WHERE a.interface_run_id = p_interface_run_id
     AND  a.status = '2'
     AND   (  NOT EXISTS (SELECT 1 FROM hz_Education h1, hz_parties h2
                         WHERE  h1.party_id = a.person_id
                         AND h2.party_number = a.institution_code
                         AND h2.party_id = h1.school_party_id  )
                OR ( p_rule = 'R'  AND a.match_ind IN ('16', '25') )
              )
     AND UPDATE_EDUCATION_ID IS NULL
     AND a.interface_acadhis_id BETWEEN cp_min_interface_acadhis_id AND cp_max_interface_acadhis_id

--Exact match
     UNION ALL
     SELECT  cst_update dmlmode, rowid, a.*
     FROM IGS_AD_ACADHIS_INT_ALL a
     WHERE a.interface_run_id = p_interface_run_id
     AND  a.status = '2'
    AND (       p_rule = 'I'  OR (p_rule = 'R' AND a.match_ind = cst_mi_val_21))
     AND   (  EXISTS (SELECT 1 FROM hz_Education h1, hz_parties h2
                         WHERE  h1.party_id = a.person_id
                         AND h2.party_number = a.institution_code
                         AND h2.party_id = h1.school_party_id
                         AND TRUNC(NVL(h1.start_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.start_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                         AND TRUNC(NVL(h1.last_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.end_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                           )
               OR UPDATE_EDUCATION_ID IS NOT NULL
              )
      AND a.interface_acadhis_id BETWEEN cp_min_interface_acadhis_id AND cp_max_interface_acadhis_id
--First record update
--  ( matching instituion code but dates do not match and no partial match
--   ( both start date and end date for all OSS matching records is NULL))
     UNION ALL
     SELECT  cst_first_row dmlmode, rowid, a.*
     FROM IGS_AD_ACADHIS_INT_ALL a
     WHERE a.interface_run_id = p_interface_run_id
     AND  a.status = '2'
     AND  UPDATE_EDUCATION_ID IS NULL
     AND NVL(a.start_date,a.end_date) IS NOT NULL
     AND  EXISTS (SELECT 1 FROM hz_Education h1, hz_parties h2
                      WHERE  h1.party_id = a.person_id
                      AND h2.party_id = h1.school_party_id
                      AND h2.party_number = a.institution_code
                      AND h1.start_date_attended IS NULL
                      AND h1.last_date_attended IS NULL
                      )
     AND NOT EXISTS ( SELECT 1 FROM hz_Education h1, hz_parties h2
                    WHERE  h1.party_id = a.person_id
                      AND h2.party_number = a.institution_code
                      AND h2.party_id = h1.school_party_id
                    AND NVL(h1.start_date_attended,
                         h1.last_date_attended) IS NOT NULL
                 )
     AND a.interface_acadhis_id BETWEEN cp_min_interface_acadhis_id AND cp_max_interface_acadhis_id
-- Partial match finds single record, hence update if discrepancy rule is 'I'/'R-21' - per bug 3417941
     UNION ALL
     SELECT  cst_partial_update dmlmode, rowid, a.*
     FROM IGS_AD_ACADHIS_INT_ALL a
     WHERE a.interface_run_id = p_interface_run_id
     AND  a.status = '2'
     AND  UPDATE_EDUCATION_ID IS NULL
     AND  (p_rule = 'I'  OR (p_rule = 'R' AND a.match_ind = cst_mi_val_21))
     AND  1 = (SELECT count(*) FROM hz_Education h1, hz_parties h2
                      WHERE  h1.party_id = a.person_id
                      AND h2.party_id = h1.school_party_id
                      AND h2.party_number = a.institution_code
                      AND NVL(h1.start_date_attended,h1.last_date_attended) IS NOT NULL
                      AND (TRUNC(NVL(h1.start_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) <>
                             TRUNC(NVL(a.start_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                         OR TRUNC(NVL(h1.last_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) <>
                             TRUNC(NVL(a.end_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))))
                      )
    AND NOT EXISTS (SELECT 1 FROM hz_Education h1, hz_parties h2
                      WHERE  h1.party_id = a.person_id
                      AND h2.party_number = a.institution_code
                      AND h2.party_id = h1.school_party_id
                      AND TRUNC(NVL(h1.start_date_attended,
                            TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                          TRUNC(NVL(a.start_date,
                            TO_DATE('01-01-0001','DD-MM-YYYY')))
                      AND TRUNC(NVL(h1.last_date_attended,
                            TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                          TRUNC(NVL(a.end_date,
                            TO_DATE('01-01-0001','DD-MM-YYYY')))
                    )
    AND UPDATE_EDUCATION_ID IS NULL
    AND a.interface_acadhis_id BETWEEN cp_min_interface_acadhis_id AND cp_max_interface_acadhis_id;

   CURSOR c_dup_cur (acad_hist_rec  acad_hist%ROWTYPE ) IS
                SELECT  ah.*
                FROM  igs_ad_acad_history_v ah
                WHERE
                     ( acad_hist_rec.update_education_id IS NULL
                       AND person_id = acad_hist_rec.person_id
                       AND institution_code  = acad_hist_rec.institution_code
                       AND TRUNC(NVL(start_date,
                                     TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                                  TRUNC(NVL(acad_hist_rec.start_date,
                                      TO_DATE('01-01-0001','DD-MM-YYYY')))
                      AND TRUNC(NVL(end_date,
                                      TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                                  TRUNC(NVL(acad_hist_rec.end_date,
                                      TO_DATE('01-01-0001','DD-MM-YYYY')))
                      )
                OR (acad_hist_rec.update_education_id IS NOT NULL
                      AND ah.education_id = acad_hist_rec.update_education_id
                     );
  dup_cur_rec  c_dup_cur %ROWTYPE;
  --This cursor will opened in case of first record updates.
   CURSOR c_dup_cur_first (acad_hist_rec  acad_hist%ROWTYPE ) IS
        SELECT   ah.*
        FROM  igs_ad_acad_history_v ah
        WHERE person_id = acad_hist_rec.person_id
        AND institution_code  = acad_hist_rec.institution_code
        AND CREATION_DATE =
              (SELECT MIN(he.creation_date) FROM  hz_education he, hz_parties hz
                WHERE  he.party_id = acad_hist_rec.person_id
                AND  hz.party_id = he.school_party_id
                 AND hz.party_number =  acad_hist_rec.institution_code );


   CURSOR c_dup_cur_partial (acad_hist_rec  acad_hist%ROWTYPE ) IS
                SELECT  ah.*
                FROM  igs_ad_acad_history_v ah
                WHERE person_id = acad_hist_rec.person_id
                AND institution_code  = acad_hist_rec.institution_code;


  person_history_rec  acad_hist%ROWTYPE;
  l_rowid             VARCHAR2(25);
  l_error_code        VARCHAR2(10);
  l_records_processed NUMBER := 0;
  l_prog_label  VARCHAR2(100) ;
  l_processed_records NUMBER(5) := 0;
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);

  --start of local validation procedure
  PROCEDURE Validate_ACADHIS(
              PERSON_HISTORY_REC IN acad_hist%ROWTYPE,
              p_error_code OUT NOCOPY VARCHAR2,
	      p_status OUT NOCOPY VARCHAR2
  ) AS
    l_var VARCHAR2(1);

     CURSOR c_val_inst_cd_non_uk_cur IS
     SELECT hp.rowid  row_id
     FROM
        hz_parties p,
        igs_pe_hz_parties hp
     WHERE hp.party_id = p.party_id
     AND   hp.inst_org_ind = 'I'
     AND p.party_number = person_history_rec.institution_code;

     CURSOR c_val_inst_cd_uk_cur IS
     SELECT HP.rowid  row_id
     FROM  HZ_PARTIES P,
               IGS_PE_HZ_PARTIES HP,
               IGS_OR_ORG_INST_TYPE_ALL OIT
     WHERE HP.PARTY_ID = P.PARTY_ID
     AND      HP.INST_ORG_IND = 'I'
     AND   p.party_number = person_history_rec.institution_code
     AND      HP.OI_INSTITUTION_TYPE = OIT.INSTITUTION_TYPE (+)
     AND      OIT.SYSTEM_INST_TYPE IN ('POST-SECONDARY','SECONDARY');


     c_val_inst_cd_rec c_val_inst_cd_non_uk_cur%ROWTYPE;

  BEGIN
    -- log header

     c_val_inst_cd_rec.row_id := NULL;
    --1. Institution Code
    IF PERSON_HISTORY_REC.INSTITUTION_CODE IS NOT NULL THEN
      IF FND_PROFILE.VALUE('OSS_COUNTRY_CODE')  <> 'GB' THEN
         OPEN c_val_inst_cd_non_uk_cur;
         FETCH c_val_inst_cd_non_uk_cur INTO c_val_inst_cd_rec;
	 CLOSE c_val_inst_cd_non_uk_cur;
      ELSE
          OPEN c_val_inst_cd_uk_cur;
          FETCH c_val_inst_cd_uk_cur INTO c_val_inst_cd_rec;
          CLOSE c_val_inst_cd_uk_cur;
      END IF;
      IF c_val_inst_cd_rec.row_id IS NULL THEN
         p_error_code := 'E401';
         p_status := '3';
         RETURN;
      END IF;
    END IF;

    --4. PROGRAM_CODE

    --5. VERSION_NUMBER

    --6. START_DATE
    IF  PERSON_HISTORY_REC.START_DATE IS NOT NULL THEN
      IF  NOT PERSON_HISTORY_REC.START_DATE < SYSDATE THEN
        p_error_code := 'E405';
        p_status := '3';
        RETURN;
      END IF;
    END IF;

    --7. END_DATE
    IF PERSON_HISTORY_REC.END_DATE  IS NOT NULL
		   AND PERSON_HISTORY_REC.START_DATE IS NOT NULL THEN
      IF  NOT PERSON_HISTORY_REC.END_DATE >= PERSON_HISTORY_REC.START_DATE THEN
        p_error_code := 'E406';
        p_status := '3';
      RETURN;

      END IF;
    END IF;

    --8. PLANNED_COMPLETION_DATE
    IF PERSON_HISTORY_REC.PLANNED_COMPLETION_DATE  IS NOT NULL THEN
      IF  NOT PERSON_HISTORY_REC.PLANNED_COMPLETION_DATE >= PERSON_HISTORY_REC.START_DATE THEN
        p_error_code := 'E408';
        p_status := '3';
      RETURN;
      END IF;
    END IF;

    --9. SELFREP_TOTAL_CP_ATTEMPTED
    IF PERSON_HISTORY_REC.SELFREP_TOTAL_CP_ATTEMPTED  IS NOT NULL THEN
      IF  NOT PERSON_HISTORY_REC.SELFREP_TOTAL_CP_ATTEMPTED >= 0 THEN
      p_error_code := 'E409';
      p_status := '3';
      RETURN;
      END IF;
    END IF;

    --10. SELFREP_TOTAL_CP_EARNED
    IF PERSON_HISTORY_REC.SELFREP_TOTAL_CP_EARNED  IS NOT NULL THEN
      IF  NOT PERSON_HISTORY_REC.SELFREP_TOTAL_CP_EARNED  >= 0 THEN
      p_error_code := 'E410';
      p_status := '3';
      RETURN;
      END IF;
    END IF;

    --11. SELFREP_TOTAL_GP_UNITS_ATTEMP
    IF PERSON_HISTORY_REC.SELFREP_TOTAL_GP_UNITS_ATTEMP  IS NOT NULL THEN
      IF  NOT PERSON_HISTORY_REC.SELFREP_TOTAL_GP_UNITS_ATTEMP >= 0 THEN
      p_error_code := 'E411';
      p_status := '3';
      RETURN;
      END IF;
    END IF;

    --12. SELFREP_INST_GPA
    IF PERSON_HISTORY_REC.SELFREP_INST_GPA IS NOT NULL THEN
      IF  NOT PERSON_HISTORY_REC.SELFREP_INST_GPA >= 0 THEN
      p_error_code := 'E412';
      p_status := '3';
      RETURN;
      END IF;
    END IF;

    --13. SELFREP_GRADING_SCALE_ID
    IF PERSON_HISTORY_REC.SELFREP_GRADING_SCALE_ID IS NOT NULL THEN
      IF  NOT PERSON_HISTORY_REC.SELFREP_GRADING_SCALE_ID > 0 THEN
      p_error_code := 'E413';
      p_status := '3';
      RETURN;
      END IF;
    END IF;

    --14. SELFREP_WEIGHTED_GPA
    IF PERSON_HISTORY_REC.SELFREP_WEIGHTED_GPA IS NOT NULL THEN
      IF NOT PERSON_HISTORY_REC.SELFREP_WEIGHTED_GPA IN('Y','N') THEN
      p_error_code := 'E414';
      p_status := '3';
      RETURN;
      END IF;
    END IF;

    --15. SELFREP_RANK_IN_CLASS
    IF PERSON_HISTORY_REC.SELFREP_RANK_IN_CLASS IS NOT NULL THEN
      IF  NOT PERSON_HISTORY_REC.SELFREP_RANK_IN_CLASS > 0 THEN
      p_error_code := 'E415';
      p_status := '3';
      RETURN;
      END IF;
    END IF;

    --16. SELFREP_WEIGHTED_RANK
    IF PERSON_HISTORY_REC.SELFREP_WEIGHTED_RANK IS NOT NULL THEN
      IF NOT PERSON_HISTORY_REC.SELFREP_WEIGHTED_RANK IN('Y','N') THEN
      p_error_code := 'E416';
      p_status := '3';
      RETURN;
      END IF;
    END IF;

/*-------------------------------------------------------------------------
The code from this point onwards was written as part of the
ID prospective applicant part 2 of 1.
--------------------------------------------------------------------------*/
    --17. SELFREP_CLASS_SIZE
    IF PERSON_HISTORY_REC.CLASS_SIZE IS NOT NULL THEN
      IF NOT PERSON_HISTORY_REC.CLASS_SIZE > 0 THEN
      p_error_code := 'E417';
      p_status := '3';
      RETURN;
      END IF;
    END IF;
/*-------------------------------------------------------------------------
The code upto this point was written as part of the ID prospective
applicant part 2 of 1. The starting point is mentioned above.
--------------------------------------------------------------------------*/
     --
     -- Added the call to validate the descriptive flexfield columns as a part of Admissions 1.8 DLD // kamohan
     --
    -- 18. DESCRIPTIVE FLEX FIELDS
    IF NOT Igs_Ad_Imp_018.validate_desc_flex (
                 p_attribute_category  => PERSON_HISTORY_REC.attribute_category,
                 p_attribute1    => PERSON_HISTORY_REC.attribute1,
                 p_attribute2    => PERSON_HISTORY_REC.attribute2,
                 p_attribute3    => PERSON_HISTORY_REC.attribute3,
                 p_attribute4    => PERSON_HISTORY_REC.attribute4,
                 p_attribute5    => PERSON_HISTORY_REC.attribute5,
                 p_attribute6    => PERSON_HISTORY_REC.attribute6,
                 p_attribute7    => PERSON_HISTORY_REC.attribute7,
                 p_attribute8    => PERSON_HISTORY_REC.attribute8,
                 p_attribute9    => PERSON_HISTORY_REC.attribute9,
                 p_attribute10    => PERSON_HISTORY_REC.attribute10,
                 p_attribute11    => PERSON_HISTORY_REC.attribute11,
                 p_attribute12    => PERSON_HISTORY_REC.attribute12,
                 p_attribute13    => PERSON_HISTORY_REC.attribute13,
                 p_attribute14    => PERSON_HISTORY_REC.attribute14,
                 p_attribute15    => PERSON_HISTORY_REC.attribute15,
                 p_attribute16    => PERSON_HISTORY_REC.attribute16,
                 p_attribute17    => PERSON_HISTORY_REC.attribute17,
                 p_attribute18    => PERSON_HISTORY_REC.attribute18,
                 p_attribute19    => PERSON_HISTORY_REC.attribute19,
                 p_attribute20    => PERSON_HISTORY_REC.attribute20,
                 p_desc_flex_name        => 'IGS_AD_ACAD_HISTORY_FLEX'
               )
    THEN
      p_error_code := 'E418';
      p_status := '3';
      RETURN;
    END IF;

    --19. Transcript REquired
    IF PERSON_HISTORY_REC.TRANSCRIPT_REQUIRED IS NOT NULL THEN
      IF NOT PERSON_HISTORY_REC.TRANSCRIPT_REQUIRED IN ('Y', 'N') THEN
      p_error_code := 'E419';
      p_status := '3';
      RETURN;
      END IF;
    END IF;

    p_error_code :=  NULL;
    p_status := '1';

    RETURN ;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code :=  'E518';
      p_status := '3';
      -- log detail
      RETURN;
  END Validate_ACADHIS;
  --end of local validation procedure
---------------------------------------------------------------------------
  -- local procedure to insert the academic history record

  PROCEDURE crc_pe_acad_hist(
            PERSON_HISTORY_REC IN acad_hist%ROWTYPE
  ) AS
  l_msg_at_index   NUMBER := 0;
  l_return_status   VARCHAR2(1);
  l_msg_count      NUMBER ;
  l_msg_data       VARCHAR2(2000);
  l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
    l_error_text VARCHAR2(2000);
    l_education_id NUMBER;
    l_status VARCHAR2(10);
    l_object_version_number   hz_education.object_version_number%TYPE := NULL;
  BEGIN
  l_status := '1';
  l_error_code := NULL;
  l_error_text  := NULL;
    validate_acadhis(person_history_rec,l_error_code, l_status );
    IF l_Status =  '1' THEN
      -- Bug no 2452444
      -- If any exception occurs during insert
      -- catch the error and display it in the log file and update the error code to E322 and status to 3
      BEGIN
       l_msg_at_index := igs_ge_msg_stack.count_msg;
       SAVEPOINT before_create_hist;
        Igs_Ad_Acad_History_Pkg.Insert_Row (
            x_rowid                         => l_RowId,
            x_attribute14                   => PERSON_HISTORY_REC.attribute14,
            x_attribute15                   => PERSON_HISTORY_REC.attribute15,
            x_attribute16                   => PERSON_HISTORY_REC.attribute16,
            x_attribute17                   => PERSON_HISTORY_REC.attribute17,
            x_attribute18                   => PERSON_HISTORY_REC.attribute18,
            x_attribute19                   => PERSON_HISTORY_REC.attribute19,
            x_attribute20                   => PERSON_HISTORY_REC.attribute20,
            x_attribute13                   => PERSON_HISTORY_REC.attribute13,
            x_attribute11                   => PERSON_HISTORY_REC.attribute11,
            x_attribute12                   => PERSON_HISTORY_REC.attribute12,
            x_education_id                  => l_education_id,
            x_person_id                     => PERSON_HISTORY_REC.Person_Id,
            x_current_inst                  => PERSON_HISTORY_REC.current_inst,
            x_degree_attempted        => PERSON_HISTORY_REC.degree_attempted,
            x_program_code                  => PERSON_HISTORY_REC.Program_Code,
            x_degree_earned           => PERSON_HISTORY_REC.degree_earned,
            x_comments                      => PERSON_HISTORY_REC.Comments,
            x_start_date                    =>  TRUNC(PERSON_HISTORY_REC.Start_Date),
            x_end_date                      => TRUNC(PERSON_HISTORY_REC.End_Date),
            x_planned_completion_date       => TRUNC(person_history_rec.planned_completion_date),
            x_recalc_total_cp_attempted     => NULL,
            x_recalc_total_cp_earned        => NULL,
            x_recalc_total_unit_gp          => NULL,
            x_recalc_tot_gpa_units_attemp   => NULL,--recalc_tot_gpa_units_attemp,
            x_recalc_inst_gpa               => NULL, --recalc_inst_gpa,
            x_recalc_grading_scale_id       => NULL,
            x_selfrep_total_cp_attempted    => PERSON_HISTORY_REC.selfrep_total_cp_attempted,
            x_selfrep_total_cp_earned       =>  PERSON_HISTORY_REC.selfrep_total_cp_earned,
            x_selfrep_total_unit_gp         => NULL, --selfrep_total_unit_gp,
            x_selfrep_tot_gpa_uts_attemp    => NULL,
            x_selfrep_inst_gpa              => PERSON_HISTORY_REC.selfrep_inst_gpa,
            x_selfrep_grading_scale_id      => PERSON_HISTORY_REC.selfrep_grading_scale_id,
            x_selfrep_weighted_gpa          => PERSON_HISTORY_REC.selfrep_weighted_gpa,
            x_selfrep_rank_in_class         => PERSON_HISTORY_REC.selfrep_rank_in_class,
            x_selfrep_weighed_rank          => PERSON_HISTORY_REC.selfrep_weighted_rank,
            x_type_of_school                => PERSON_HISTORY_REC.type_of_school,
            x_institution_code              => PERSON_HISTORY_REC.institution_code,
            x_attribute_category            => PERSON_HISTORY_REC.attribute_category,
            x_attribute1                    => PERSON_HISTORY_REC.attribute1,
            x_attribute2                    => PERSON_HISTORY_REC.attribute2,
            x_attribute3                    => PERSON_HISTORY_REC.attribute3,
            x_attribute4                    => PERSON_HISTORY_REC.attribute4,
            x_attribute5                    => PERSON_HISTORY_REC.attribute5,
            x_attribute6                    => PERSON_HISTORY_REC.attribute6,
            x_attribute7                    => PERSON_HISTORY_REC.attribute7,
            x_attribute8                    => PERSON_HISTORY_REC.attribute8,
            x_attribute9                    => PERSON_HISTORY_REC.attribute9,
            x_attribute10                   => PERSON_HISTORY_REC.attribute10,
            -- Added Class Size As part of the ID Prospective Applicant part 2 of 1
            x_selfrep_class_size            => PERSON_HISTORY_REC.class_size,
            -- Added Transcript Required as a part of DLD_ADSR_IMPORT_TEST_RESULTS
            x_transcript_required           => NVL(PERSON_HISTORY_REC.transcript_required,'Y'),
            x_object_version_number     => l_object_version_number,
            x_msg_data                      => l_msg_data,
            x_return_status                 => l_return_status,
            x_mode                          => 'R');
	EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK TO  before_create_hist;
                igs_ad_gen_016.extract_msg_from_stack (
                          p_msg_at_index                => l_msg_at_index,
                          p_return_status               => l_return_status,
                          p_msg_count                   => l_msg_count,
                          p_msg_data                    => l_msg_data,
                          p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
               IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                   l_error_text := l_msg_data;
                   l_error_Code := NULL;

                   IF p_enable_log = 'Y' THEN
                       igs_ad_imp_001.logerrormessage(person_history_rec.interface_acadhis_id,l_msg_data,'IGS_AD_ACAD_HIS_INT');
                   END IF;
               ELSE
                    l_error_text := NULL;
                    l_error_Code := 'E518';
                    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		          l_label := 'igs.plsql.igs_ad_imp_028.crc_pe_acad_hist.exception '||l_msg_data;

			  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			  fnd_message.set_token('INTERFACE_ID',person_history_rec.interface_acadhis_id);
			  fnd_message.set_token('ERROR_CD','E322');

		          l_debug_str :=  fnd_message.get;

                     fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                      END IF;

               END IF;


            UPDATE
	      IGS_AD_ACADHIS_INT_ALL
            SET
	      error_code = l_error_Code,
              error_text  = l_error_text,
              status = cst_s_val_3,
              match_ind = DECODE (
                                       person_history_rec.match_ind,
                                              NULL, cst_mi_val_11,
                                       match_ind)
           WHERE
	    INTERFACE_ACADHIS_ID = PERSON_HISTORY_REC.INTERFACE_ACADHIS_ID;
	   RETURN;
        END;

      IF l_return_status IN ('E','U') THEN
        UPDATE  IGS_AD_ACADHIS_INT_ALL
        SET  error_code = 'E322',
                 error_text =  l_msg_data,
             status = '3',
              match_ind = DECODE (
                                       person_history_rec.match_ind,
                                              NULL, cst_mi_val_11,
                                       match_ind)
        WHERE   INTERFACE_ACADHIS_ID = PERSON_HISTORY_REC.INTERFACE_ACADHIS_ID;

        --log detail
      ELSE
        -- BUG 2385289 BY RRENGARA ON 24-MAY-2002
	-- updated education_id after successful insert
        UPDATE  IGS_AD_ACADHIS_INT_ALL
        SET    status = cst_s_val_1,
	       error_code = cst_ec_val_NULL,
	       education_id = l_education_id
        WHERE   INTERFACE_ACADHIS_ID = PERSON_HISTORY_REC.INTERFACE_ACADHIS_ID;
      END IF;
    ELSE  -- validation fails
        UPDATE  IGS_AD_ACADHIS_INT_ALL
        SET  error_code = l_error_code,
          error_Text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405),
             status = l_status,
              match_ind = DECODE (
                                       person_history_rec.match_ind,
                                              NULL, cst_mi_val_11,
                                       match_ind)
        WHERE   INTERFACE_ACADHIS_ID = PERSON_HISTORY_REC.INTERFACE_ACADHIS_ID;
        IF p_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(person_history_rec.interface_acadhis_id,l_error_code,'IGS_AD_ACAD_HIS_INT');
         END IF;
    END IF;   -- end of ( l_error_code IS NULL )
  END crc_pe_acad_hist;


  PROCEDURE upd_pe_acad_hist (
   PERSON_HISTORY_REC IN acad_hist%ROWTYPE,
    c_null_hdlg_acad_hist_cur_rec c_dup_cur%ROWTYPE) AS

    l_msg_at_index   NUMBER := 0;
    l_return_status   VARCHAR2(1);
    l_msg_count      NUMBER ;
    l_msg_data       VARCHAR2(2000);
    l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
    l_error_text VARCHAR2(2000);
    l_education_id NUMBER;
    l_status VARCHAR2(10);
    l_object_version_number   hz_education.object_version_number%TYPE;
    NO_MATCH_RECORD_FOUND EXCEPTION;
 BEGIN
    l_object_version_number  := c_null_hdlg_acad_hist_cur_rec.object_version_number;

      validate_acadhis(person_history_rec,l_error_code, l_status );
      IF l_error_code IS NULL THEN
         BEGIN
          SAVEPOINT  before_update_hist;
           l_msg_at_index := igs_ge_msg_stack.count_msg;
            Igs_Ad_Acad_History_Pkg.update_row (
             x_rowid                       => c_null_hdlg_acad_hist_cur_rec.row_id,
             x_attribute14                 => c_null_hdlg_acad_hist_cur_rec.attribute14,
             x_attribute15                 => c_null_hdlg_acad_hist_cur_rec.attribute15,
             x_attribute16                 => c_null_hdlg_acad_hist_cur_rec.attribute16,
             x_attribute17                 => c_null_hdlg_acad_hist_cur_rec.attribute17,
             x_attribute18                 => c_null_hdlg_acad_hist_cur_rec.attribute18,
             x_attribute19                 => c_null_hdlg_acad_hist_cur_rec.attribute19,
             x_attribute20                 => c_null_hdlg_acad_hist_cur_rec.attribute20,
             x_attribute13                 => c_null_hdlg_acad_hist_cur_rec.attribute13,
             x_attribute11                 => c_null_hdlg_acad_hist_cur_rec.attribute11,
             x_attribute12                 => c_null_hdlg_acad_hist_cur_rec.attribute12,
             x_education_id                => c_null_hdlg_acad_hist_cur_rec.Education_Id,
             x_person_id                   => NVL(PERSON_HISTORY_REC.Person_Id,c_null_hdlg_acad_hist_cur_rec.person_id),
             x_current_inst                => NVL(PERSON_HISTORY_REC.current_inst,c_null_hdlg_acad_hist_cur_rec.current_inst),
             x_degree_attempted      => NVL(PERSON_HISTORY_REC.degree_attempted,c_null_hdlg_acad_hist_cur_rec.degree_attempted),
             x_program_code                => NVL(PERSON_HISTORY_REC.Program_Code,c_null_hdlg_acad_hist_cur_rec.Program_Code),
             x_degree_earned         => NVL(PERSON_HISTORY_REC.degree_earned,c_null_hdlg_acad_hist_cur_rec.degree_earned),
             x_comments                    => NVL(PERSON_HISTORY_REC.Comments,c_null_hdlg_acad_hist_cur_rec.Comments),
             x_start_date                  =>  TRUNC(NVL(PERSON_HISTORY_REC.Start_Date,c_null_hdlg_acad_hist_cur_rec.Start_Date)),
             x_end_date                    => TRUNC(NVL(PERSON_HISTORY_REC.End_Date,c_null_hdlg_acad_hist_cur_rec.End_Date)),
             x_planned_completion_date     => NVL(person_history_rec.planned_completion_date,c_null_hdlg_acad_hist_cur_rec.planned_completion_date),
             x_recalc_total_cp_attempted   => c_null_hdlg_acad_hist_cur_rec.recalc_total_cp_attempted,
             x_recalc_total_cp_earned      => c_null_hdlg_acad_hist_cur_rec.recalc_total_cp_earned,
             x_recalc_total_unit_gp        => c_null_hdlg_acad_hist_cur_rec.recalc_total_unit_gp,
             x_recalc_tot_gpa_units_attemp => c_null_hdlg_acad_hist_cur_rec.recalc_total_gpa_units_attemp,
             x_recalc_inst_gpa             => c_null_hdlg_acad_hist_cur_rec.recalc_inst_gpa,
             x_recalc_grading_scale_id     => c_null_hdlg_acad_hist_cur_rec.recalc_grading_scale_id,
             x_selfrep_total_cp_attempted  => NVL(PERSON_HISTORY_REC.selfrep_total_cp_attempted,c_null_hdlg_acad_hist_cur_rec.selfrep_total_cp_attempted),
             x_selfrep_total_cp_earned     =>  NVL(PERSON_HISTORY_REC.selfrep_total_cp_earned,c_null_hdlg_acad_hist_cur_rec.selfrep_total_cp_earned),
             x_selfrep_total_unit_gp       => c_null_hdlg_acad_hist_cur_rec.selfrep_total_unit_gp,
             x_selfrep_tot_gpa_uts_attemp  =>  NVL(person_history_rec.selfrep_total_gp_units_attemp,c_null_hdlg_acad_hist_cur_rec.selfrep_total_gpa_units_attemp),
             x_selfrep_inst_gpa            =>   NVL(PERSON_HISTORY_REC.selfrep_inst_gpa,c_null_hdlg_acad_hist_cur_rec.selfrep_inst_gpa),
             x_selfrep_grading_scale_id    => NVL(PERSON_HISTORY_REC.selfrep_grading_scale_id,c_null_hdlg_acad_hist_cur_rec.selfrep_grading_scale_id),
             x_selfrep_weighted_gpa        => NVL(PERSON_HISTORY_REC.selfrep_weighted_gpa,c_null_hdlg_acad_hist_cur_rec.selfrep_weighted_gpa),
             x_selfrep_rank_in_class       => NVL(PERSON_HISTORY_REC.selfrep_rank_in_class,c_null_hdlg_acad_hist_cur_rec.selfrep_rank_in_class),
             x_selfrep_weighed_rank        => NVL(PERSON_HISTORY_REC.selfrep_weighted_rank,c_null_hdlg_acad_hist_cur_rec.selfrep_weighed_rank),
             x_type_of_school              => NVL(PERSON_HISTORY_REC.type_of_school,c_null_hdlg_acad_hist_cur_rec.type_of_school),
             x_institution_code            => NVL(PERSON_HISTORY_REC.institution_code,c_null_hdlg_acad_hist_cur_rec.institution_code),
             x_attribute_category          => c_null_hdlg_acad_hist_cur_rec.attribute_category,
             x_attribute1                  => c_null_hdlg_acad_hist_cur_rec.attribute1,
             x_attribute2                  => c_null_hdlg_acad_hist_cur_rec.attribute2,
             x_attribute3                  => c_null_hdlg_acad_hist_cur_rec.attribute3,
             x_attribute4                  => c_null_hdlg_acad_hist_cur_rec.attribute4,
             x_attribute5                  => c_null_hdlg_acad_hist_cur_rec.attribute5,
             x_attribute6                  => c_null_hdlg_acad_hist_cur_rec.attribute6,
             x_attribute7                  => c_null_hdlg_acad_hist_cur_rec.attribute7,
             x_attribute8                  => c_null_hdlg_acad_hist_cur_rec.attribute8,
             x_attribute9                  => c_null_hdlg_acad_hist_cur_rec.attribute9,
             x_attribute10                 => c_null_hdlg_acad_hist_cur_rec.attribute10,
             -- Added Class Size As part of the ID Prospective Applicant part 2 of 1
             x_selfrep_class_size          => NVL(PERSON_HISTORY_REC.class_size,c_null_hdlg_acad_hist_cur_rec.SELFREP_CLASS_SIZE),
             -- Added Transcript Required as a part of the DLD_ADRS_IMPORT_TEST_RESULTS DLD
             x_transcript_required         => NVL(PERSON_HISTORY_REC.transcript_required,c_null_hdlg_acad_hist_cur_rec.transcript_required),
             x_msg_data                    => l_msg_data,
             x_return_status               => l_return_status,
             x_object_version_number => l_object_version_number,
             x_mode                        => 'R');
          EXCEPTION
          WHEN OTHERS THEN
          ROLLBACK TO before_update_hist;
                igs_ad_gen_016.extract_msg_from_stack (
                          p_msg_at_index                => l_msg_at_index,
                          p_return_status               => l_return_status,
                          p_msg_count                   => l_msg_count,
                          p_msg_data                    => l_msg_data,
                          p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
               IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                   l_error_text := l_msg_data;
                   l_error_Code := 'E014';

                   IF p_enable_log = 'Y' THEN
                       igs_ad_imp_001.logerrormessage(person_history_rec.interface_acadhis_id,l_msg_data,'IGS_AD_ACAD_HIS_INT');
                   END IF;
               ELSE
                    l_error_text :=  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405);
                    l_error_Code := 'E518';
                    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		          l_label := 'igs.plsql.igs_ad_imp_028.crc_pe_acad_hist.exception '||l_msg_data;

			  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			  fnd_message.set_token('INTERFACE_ID',person_history_rec.interface_acadhis_id);
			  fnd_message.set_token('ERROR_CD','E322');

		          l_debug_str :=  fnd_message.get;

                       fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                      END IF;

               END IF;



            UPDATE
	      IGS_AD_ACADHIS_INT_ALL
            SET
	      error_code = l_error_Code,
              error_text  =l_error_text,
              status = '3',
              match_ind = DECODE (
                                       person_history_rec.match_ind,
                                              NULL, cst_mi_val_12,
                                       match_ind)
           WHERE
	    INTERFACE_ACADHIS_ID = PERSON_HISTORY_REC.INTERFACE_ACADHIS_ID;
	   RETURN;
          END;


           IF l_return_status IN ('E','U') THEN
             UPDATE       IGS_AD_ACADHIS_INT_ALL
             SET          error_code = 'E014',
                          status = '3',
                          error_text = l_msg_data,
                          match_ind = DECODE (
                                       person_history_rec.match_ind,
                                              NULL, cst_mi_val_12,
                                       match_ind)
             WHERE        INTERFACE_ACADHIS_ID = PERSON_HISTORY_REC.INTERFACE_ACADHIS_ID;
             --log detail
           ELSE
	    -- BUG 2385289 BY RRENGARA ON 24-MAY-2002
	    -- updated education_id after successful update
	     UPDATE	IGS_AD_ACADHIS_INT_ALL
             SET       match_ind = decode ( person_history_rec.dmlmode,
	                                    cst_partial_update, cst_mi_val_12,
					    decode ( person_history_rec.match_ind ,
					             NULL, cst_mi_val_18,
					             person_history_rec.match_ind)),
                       status = cst_s_val_1,
			      education_id = c_null_hdlg_acad_hist_cur_rec.Education_Id
             WHERE     INTERFACE_ACADHIS_ID = PERSON_HISTORY_REC.INTERFACE_ACADHIS_ID;
            END IF;
      ELSE
          UPDATE	IGS_AD_ACADHIS_INT_ALL
            SET     status = cst_s_val_3,
                       error_code = l_error_code,
                       error_Text  = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405),
                       match_ind = DECODE (
                                       person_history_rec.match_ind,
                                              NULL, cst_mi_val_12,
                                       match_ind),
                       education_id = c_null_hdlg_acad_hist_cur_rec.Education_Id
            WHERE     INTERFACE_ACADHIS_ID = PERSON_HISTORY_REC.INTERFACE_ACADHIS_ID;
             IF p_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(person_history_rec.interface_acadhis_id,l_error_code,'IGS_AD_ACAD_HIS_INT');
             END IF;
      END IF;   --validation fails

END upd_pe_acad_hist;


  -- end of local procedure

BEGIN

   l_prog_label  := 'igs.plsql.igs_ad_imp_013.prc_pe_acad_hist';

 --If given invalid update education ID then error out.
   UPDATE IGS_AD_ACADHIS_INT_ALL  acad
   SET
      status = '3',  error_code =  'E711',
      error_Text  = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E711', 8405)
      WHERE  update_education_id IS NOT NULL
      AND NOT EXISTS ( SELECT 1 FROM HZ_EDUCATION
                                     WHERE party_id = acad.person_id
                                     AND    education_id = NVL(acad.update_education_id ,education_id)
                                   ) ;
   COMMIT;

  IF p_rule IN ('E', 'I')  THEN
           UPDATE IGS_AD_ACADHIS_INT_ALL
           SET
           status = '3'
           , error_code = 'E700'
           ,error_Text  = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405)
           WHERE interface_run_id = p_interface_run_id
           AND status = '2'
          AND NVL (match_ind, '15') <> '15';
   END IF;
   COMMIT;

   --	2. Set STATUS to 1 for interface records with RULE = R and MATCH IND = 17,18,19,22,23,24,27
   IF p_rule = 'R'  THEN
      UPDATE IGS_AD_ACADHIS_INT_ALL
      SET
      status = '1',  error_code = NULL
      WHERE interface_run_id = p_interface_run_id
      AND status = '2'
      AND match_ind IN ('17', '18', '19', '22', '23', '24', '27');
   END IF;
   COMMIT;

--  3.	Set STATUS to 3 for interface records with multiple matching duplicate system records for RULE = I
   IF  p_rule = 'I' THEN
     UPDATE IGS_AD_ACADHIS_INT_ALL a
     SET
     status = '3'
     , match_ind = '13'
     WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND UPDATE_EDUCATION_ID IS NULL
     AND 1  <  ( SELECT COUNT (*)
                       FROM hz_Education h1, hz_parties h2
                         WHERE  h1.party_id = a.person_id
                         AND h2.party_number = a.institution_code
                         AND h2.party_id = h1.school_party_id
                         AND TRUNC(NVL(h1.start_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.start_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                         AND TRUNC(NVL(h1.last_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.end_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                    );

     END IF;
    COMMIT;
--  4.	Set STATUS to 3 for interface records with multiple matching duplicate system record for RULE = R
--   and either MATCH IND IN (15, 21) OR IS NULL
 IF  p_rule = 'R' THEN
    UPDATE IGS_AD_ACADHIS_INT_ALL a
    SET
    status = '3'
    , match_ind = '13'
    WHERE interface_run_id = p_interface_run_id
    AND status = '2'
    AND UPDATE_EDUCATION_ID IS NULL
    AND NVL(match_ind, '15')  IN ('15', '21')
    AND 1  <  ( SELECT COUNT (*)
                      FROM hz_Education h1, hz_parties h2
                         WHERE  h1.party_id = a.person_id
                         AND h2.party_number = a.institution_code
                         AND h2.party_id = h1.school_party_id
                         AND TRUNC(NVL(h1.start_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.start_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                         AND TRUNC(NVL(h1.last_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.end_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                   );

 END IF;
 COMMIT;
 -- 5. Set STATUS to 1 and MATCH IND to 19 for interface records with RULE = E matching OSS record(s)
  IF  p_rule = 'E' THEN
      UPDATE IGS_AD_ACADHIS_INT_ALL  a
      SET
         status = '1'
        , match_ind = '19'
        , education_id = update_education_id
      WHERE update_education_id IS NOT NULL;
      COMMIT;

      UPDATE IGS_AD_ACADHIS_INT_ALL  a
      SET
         status = '3'
        , match_ind = '19'
        ,error_code = 'E708'
        ,error_Text  = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E708', 8405)
      WHERE interface_run_id = p_interface_run_id
      AND status = '2'
      AND   1 < (SELECT count(*)  FROM hz_Education h1, hz_parties h2
                         WHERE  h1.party_id = a.person_id
                         AND h2.party_number = a.institution_code
                         AND h2.party_id = h1.school_party_id
                         AND TRUNC(NVL(h1.start_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.start_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                         AND TRUNC(NVL(h1.last_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.end_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                     )
         AND EXISTS (SELECT 1 FROM igs_ad_txcpt_int
                WHERE interface_acadhis_id = a.interface_acadhis_id
                AND status = '2');
         COMMIT;

      UPDATE IGS_AD_ACADHIS_INT_ALL  a
      SET
         status = '1'
        , match_ind = '19'
        , education_id =
                        ( SELECT h1.education_id FROM hz_Education h1, hz_parties h2
                         WHERE  h1.party_id = a.person_id
                         AND h2.party_number = a.institution_code
                         AND h2.party_id = h1.school_party_id
                         AND TRUNC(NVL(h1.start_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.start_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                         AND TRUNC(NVL(h1.last_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.end_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                        AND rownum <= 1 )
      WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND EXISTS (SELECT 1 FROM hz_Education h1, hz_parties h2
                         WHERE  h1.party_id = a.person_id
                         AND h2.party_number = a.institution_code
                         AND h2.party_id = h1.school_party_id
                         AND TRUNC(NVL(h1.start_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.start_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                         AND TRUNC(NVL(h1.last_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) =
                             TRUNC(NVL(a.end_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                        );

-- Partial match finds single record, hence success if discrepancy rule is 'E' - per bug 3417941
      UPDATE IGS_AD_ACADHIS_INT_ALL  a
      SET
         status = '1'
        , match_ind = '19'
        , education_id =
                        ( SELECT h1.education_id FROM hz_Education h1, hz_parties h2
                         WHERE  h1.party_id = a.person_id
                         AND h2.party_number = a.institution_code
                         AND h2.party_id = h1.school_party_id
                         AND NVL(h1.start_date_attended,h1.last_date_attended) IS NOT NULL
                         AND (TRUNC(NVL(h1.start_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) <>
                             TRUNC(NVL(a.start_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                         OR TRUNC(NVL(h1.last_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) <>
                             TRUNC(NVL(a.end_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))))
                        )
      WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND 1 = (SELECT count(*) FROM hz_Education h1, hz_parties h2
                         WHERE  h1.party_id = a.person_id
                         AND h2.party_number = a.institution_code
                         AND h2.party_id = h1.school_party_id
                         AND NVL(h1.start_date_attended,h1.last_date_attended) IS NOT NULL
                         AND (TRUNC(NVL(h1.start_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) <>
                             TRUNC(NVL(a.start_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY')))
                         OR TRUNC(NVL(h1.last_date_attended,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))) <>
                             TRUNC(NVL(a.end_date,
                                 TO_DATE('01-01-0001','DD-MM-YYYY'))))
                        );
  END IF;
  COMMIT;


/**********************************************************************************
6. Create / Update the OSS record after validating successfully the interface record
Create
    If RULE I (match indicator will be 15 or NULL by now no need to check) and matching system record not found OR
    RULE = R and MATCH IND = 16, 25
Update
    If RULE = I (match indicator will be 15 or NULL by now no need to check) OR
    RULE = R and MATCH IND = 21
UPdate
     If all the partilly matched OSS records have both start date and end date NULL THEN
     update First OSS record which partilaly matched.

Selecting together the interface records for INSERT / UPDATE with DMLMODE identifying the DML operation.
This is done to have one code section for record validation, exception handling and interface table update.
This avoids call to separate PLSQL blocks, tuning performance on stack maintenance during the process.

**********************************************************************************/

SELECT COUNT(interface_acadhis_id)
INTO l_count_interface_acadhis_id
FROM IGS_AD_ACADHIS_INT_ALL
WHERE interface_run_id = p_interface_run_id
AND status =2 ;

l_total_records_prcessed := 0;

LOOP
EXIT WHEN l_total_records_prcessed >= l_count_interface_acadhis_id;

SELECT
    MIN(interface_acadhis_id) , MAX(interface_acadhis_id)
INTO l_min_interface_acadhis_id , l_max_interface_acadhis_id
FROM IGS_AD_ACADHIS_INT_ALL
WHERE interface_run_id = p_interface_run_id
AND status =2
AND rownum < =100;


  FOR acad_hist_rec IN acad_hist (l_min_interface_acadhis_id, l_max_interface_acadhis_id)
LOOP

       IF acad_hist_rec.dmlmode =  cst_insert  THEN
          crc_pe_acad_hist(acad_hist_rec);
       ELSIF  acad_hist_rec.dmlmode = cst_update THEN
          dup_cur_rec.education_id  := NULL;
          OPEN c_dup_cur(acad_hist_rec);
          FETCH c_dup_cur INTO dup_cur_rec;
          CLOSE c_dup_cur;
          upd_pe_acad_hist(acad_hist_rec, dup_cur_rec);
       ELSIF  acad_hist_rec.dmlmode = cst_first_row THEN
          OPEN c_dup_cur_first(acad_hist_rec);
          FETCH c_dup_cur_first INTO dup_cur_rec;
          CLOSE c_dup_cur_first;
          upd_pe_acad_hist(acad_hist_rec, dup_cur_rec);
       ELSIF acad_hist_rec.dmlmode = cst_partial_update THEN
          OPEN c_dup_cur_partial(acad_hist_rec);
          FETCH c_dup_cur_partial INTO dup_cur_rec;
          CLOSE c_dup_cur_partial;
          upd_pe_acad_hist(acad_hist_rec, dup_cur_rec);
       END IF;
       l_total_records_prcessed :=  l_total_records_prcessed + 1;

   END LOOP; -- End for loop
   COMMIT;

 END LOOP; -- End While loop



--  7. Set STATUS to 1 and MATCH IND to 23 for interface records with RULE = R matching OSS record(s)
--      in ALL updateable column values

  IF p_rule = 'R'  THEN
       UPDATE IGS_AD_ACADHIS_INT_ALL  acad
       SET
         status = '1'
         , match_ind = '23'
       WHERE interface_run_id = p_interface_run_id
       AND status = '2'
       AND NVL (match_ind, '15') = '15'
       AND EXISTS (SELECT 1 FROM igs_ad_acad_history_v WHERE
                    person_id =  acad.person_id
                    AND NVL(current_inst, 'X') = NVL(NVL(acad.current_inst, current_inst),  'X')
                    AND STATUS = acad.status
                    AND NVL(degree_attempted, 'X') = NVL(NVL(acad.degree_attempted , degree_attempted ), 'X')
                    AND NVL(program_code, 'X') = NVL(NVL(acad.program_code,  program_code), 'X')
                    AND NVL(degree_earned, 'X') = NVL(NVL(acad.degree_earned, degree_earned ), 'X')
                    AND NVL(comments, 'X') = NVL(NVL(acad.comments,comments),  'X')
                    AND NVL(to_char(start_date,'DDMMYYYY'), '01011900') = NVL(NVL(to_char(acad.start_date,'DDMMYYYY'), to_char(start_date,'DDMMYYYY')),'01011900')
                    AND NVL(to_char(end_date,'DDMMYYYY'), '01011900') = NVL(NVL(to_char(acad.end_date,'DDMMYYYY'), to_char(end_date,'DDMMYYYY') ), '01011900')
                    AND NVL(to_char(planned_completion_date,'DDMMYYYY'), '01011900') =
                                                NVL(NVL(to_char(acad.planned_completion_date, 'DDMMYYYY'), to_char(planned_completion_date,'DDMMYYYY') ), '01011900')
                    AND NVL(selfrep_total_cp_attempted, -1) = NVL(NVL(acad.selfrep_total_cp_attempted, selfrep_total_cp_attempted),  -1)
                    AND NVL(selfrep_total_cp_earned, -1) = NVL(NVL(acad.selfrep_total_cp_earned, selfrep_total_cp_earned),  -1)
                    AND NVL(SELFREP_TOTAL_GPA_UNITS_ATTEMP, -1) = NVL(NVL(acad.SELFREP_TOTAL_GP_UNITS_ATTEMP, SELFREP_TOTAL_GP_UNITS_ATTEMP),  -1)
                    AND NVL(selfrep_inst_gpa, 'X') = NVL(NVL(acad.selfrep_inst_gpa, selfrep_inst_gpa), 'X')
                    AND NVL(selfrep_grading_scale_id, -1) = NVL(NVL(acad.selfrep_grading_scale_id,selfrep_grading_scale_id),  -1)
                    AND NVL(selfrep_weighted_gpa, 'X') = NVL(NVL(acad.selfrep_weighted_gpa, selfrep_weighted_gpa), 'X')
                    AND NVL(selfrep_rank_in_class, -1) = NVL(NVL(acad.selfrep_rank_in_class, selfrep_rank_in_class), -1)
                    AND NVL(selfrep_weighed_rank, 'X') = NVL(NVL(acad.selfrep_weighted_rank, selfrep_weighted_rank), 'X')
                    AND NVL(type_of_school, 'X') = NVL(NVL(acad.type_of_school, type_of_school), 'X')
                    AND NVL(ATTRIBUTE_CATEGORY, 'X') = NVL( NVL(acad.ATTRIBUTE_CATEGORY,ATTRIBUTE_CATEGORY), 'X')
                    AND NVL(ATTRIBUTE1, 'X') = NVL(NVL(acad.ATTRIBUTE1, ATTRIBUTE1), 'X')
                    AND NVL(ATTRIBUTE2, 'X') = NVL(NVL(acad.ATTRIBUTE2, ATTRIBUTE2),'X')
                    AND NVL(ATTRIBUTE3, 'X') = NVL(NVL(acad.ATTRIBUTE3,ATTRIBUTE3),  'X')
                    AND NVL(ATTRIBUTE4, 'X') = NVL(NVL(acad.ATTRIBUTE4,ATTRIBUTE4),  'X')
                    AND NVL(ATTRIBUTE5, 'X') = NVL(NVL(acad.ATTRIBUTE5,ATTRIBUTE5), 'X')
                    AND NVL(ATTRIBUTE6, 'X') = NVL(NVL(acad.ATTRIBUTE6,ATTRIBUTE6), 'X')
                    AND NVL(ATTRIBUTE7, 'X') = NVL(NVL(acad.ATTRIBUTE7, ATTRIBUTE7),'X')
                    AND NVL(ATTRIBUTE8, 'X') = NVL(NVL(acad.ATTRIBUTE8, ATTRIBUTE8),'X')
                    AND NVL(ATTRIBUTE9, 'X') = NVL(NVL(acad.ATTRIBUTE9, ATTRIBUTE9),'X')
                    AND NVL(ATTRIBUTE10, 'X') = NVL(NVL(acad.ATTRIBUTE10, ATTRIBUTE10),'X')
                    AND NVL(ATTRIBUTE11, 'X') = NVL(NVL(acad.ATTRIBUTE11, ATTRIBUTE11),'X')
                    AND NVL(ATTRIBUTE12, 'X') = NVL(NVL(acad.ATTRIBUTE12,ATTRIBUTE12), 'X')
                    AND NVL(ATTRIBUTE13, 'X') = NVL(NVL(acad.ATTRIBUTE13, ATTRIBUTE13),'X')
                    AND NVL(ATTRIBUTE14, 'X') = NVL(NVL(acad.ATTRIBUTE14, ATTRIBUTE14),'X')
                    AND NVL(ATTRIBUTE15, 'X') = NVL(NVL(acad.ATTRIBUTE15, ATTRIBUTE15),'X')
                    AND NVL(ATTRIBUTE16, 'X') = NVL(NVL(acad.ATTRIBUTE16,ATTRIBUTE16), 'X')
                    AND NVL(ATTRIBUTE17, 'X') = NVL(NVL(acad.ATTRIBUTE17,ATTRIBUTE17), 'X')
                    AND NVL(ATTRIBUTE18, 'X') = NVL(NVL(acad.ATTRIBUTE18,ATTRIBUTE18), 'X')
                    AND NVL(ATTRIBUTE19, 'X') = NVL(NVL(acad.ATTRIBUTE19,ATTRIBUTE19), 'X')
                    AND NVL(ATTRIBUTE20, 'X') = NVL(NVL(acad.ATTRIBUTE20,ATTRIBUTE20), 'X')
                    -- Added Class Size As part of the ID Prospective Applicant part 2 of 1
                    AND NVL(selfrep_class_size,-1) = NVL(NVL(acad.class_size, class_size),-1)
               );
  END IF;
  COMMIT;
   --  Set STATUS to 3 and MATCH IND = 20 for interface records with RULE = R and MATCH IND <> 21, 25, ones failed discrepancy check

   IF p_rule = 'R'  THEN
        UPDATE IGS_AD_ACADHIS_INT_ALL  acad
        SET
        status = '3'
        , match_ind = '20'
        , dup_acad_history_id =   ( SELECT  hz_acad_hist_id   FROM  igs_Ad_Hz_Acad_Hist
                                               WHERE education_id =     acad.update_education_id
                                             )
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND NVL (match_ind, '15') = '15'
        AND update_Education_id IS NOT NULL;

      COMMIT;

       UPDATE IGS_AD_ACADHIS_INT_ALL  acad
        SET
        status = '3'
        , match_ind = '20'
        , dup_acad_history_id =   ( SELECT  hz_acad_hist_id   FROM  igs_Ad_Hz_Acad_Hist
                                               WHERE education_id =
                                                               (SELECT education_id  FROM  hz_Education h1, hz_parties h2
                                                                WHERE  h1.party_id = acad.person_id
                                                               AND h2.party_number = acad.institution_code
                                                              AND h2.party_id = h1.school_party_id
                                                              AND NVL(h1.start_date_attended,
                                                                        TO_DATE('01-01-0001','DD-MM-YYYY')) =
                                                                     NVL(acad.start_date,
                                                                          TO_DATE('01-01-0001','DD-MM-YYYY'))
                                                             AND NVL(h1.last_date_attended,
                                                                        TO_DATE('01-01-0001','DD-MM-YYYY')) =
                                                                  NVL(acad.end_date,
                                                                        TO_DATE('01-01-0001','DD-MM-YYYY'))
                                                             )
                                               )



        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND NVL (match_ind, '15') = '15'
        AND (  EXISTS (SELECT 1 FROM  hz_Education h1, hz_parties h2
                                         WHERE  h1.party_id = acad.person_id
                                        AND h2.party_number = acad.institution_code
                                        AND h2.party_id = h1.school_party_id
                                        AND NVL(h1.start_date_attended,
                                                TO_DATE('01-01-0001','DD-MM-YYYY')) =
                                               NVL(acad.start_date,
                                                 TO_DATE('01-01-0001','DD-MM-YYYY'))
                                       AND NVL(h1.last_date_attended,
                                            TO_DATE('01-01-0001','DD-MM-YYYY')) =
                                         NVL(acad.end_date,
                                      TO_DATE('01-01-0001','DD-MM-YYYY'))
                              )
               );
   END IF;
   COMMIT;
   -- Multiple Partial (do not need to compare dates as date are already compared
   --                           and only partial matching records are in status '2'
     UPDATE IGS_AD_ACADHIS_INT_ALL  acad
       SET
       status = '3'
      , match_ind = '14'
      WHERE interface_run_id = p_interface_run_id
       AND status = '2'
       AND 1<  ( SELECT COUNT(*)  FROM  hz_Education h1, hz_parties h2
                                         WHERE  h1.party_id = acad.person_id
                                        AND h2.party_number = acad.institution_code
                                        AND h2.party_id = h1.school_party_id
                           );
     COMMIT;

  -- Partial match finds single record, hence '20,3' for discrepancy rule 'R' - per bug 3417941
     UPDATE IGS_AD_ACADHIS_INT_ALL  acad
       SET
       status = '3'
      , match_ind = '20'
      WHERE interface_run_id = p_interface_run_id
       AND status = '2'
       AND EXISTS ( SELECT 1 FROM  hz_Education h1, hz_parties h2
                                         WHERE  h1.party_id = acad.person_id
                                        AND h2.party_number = acad.institution_code
                                        AND h2.party_id = h1.school_party_id
                       );
      COMMIT;

       --Set STATUS to 3 for interface records with RULE = R and invalid MATCH IND
     IF p_rule = 'R'  THEN
        UPDATE IGS_AD_ACADHIS_INT_ALL  acad
        SET
        status = '3'
        , error_code = 'E700'
        ,error_Text  = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405)
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND match_ind IS NOT NULL;
     END IF;
     COMMIT;


  END PRC_PE_ACAD_HIST;



PROCEDURE prc_pe_cred_details  (
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2
)  AS

	/***********************************************
	||   Created By :Praveen Bondugula
	||  Date Created By :24-apr-2003
	||  Purpose : Import person credentials
	|| Known limitations, enhancements or remarks
	||  Change History
	||  Who             When            What
	||
	**********************************************/



     CURSOR c_pe_cr_cur IS
     SELECT  cst_insert dmlmode, cred.rowid, ad.person_id, cred.*
     FROM IGS_AD_INTERFACE_ALL ad , IGS_PE_CRED_INT  cred
     WHERE cred.interface_run_id = p_interface_run_id
     AND  ad.status IN ('1', '4')
     AND  cred.interface_id = ad.interface_id
     AND  cred.status = '2'
     AND (          NOT EXISTS (SELECT 1 FROM IGS_PE_CREDENTIALS
                         WHERE  person_id = ad.person_id
	     	         AND credential_type_id = cred.credential_type_id
		         AND TRUNC(NVL(date_received, IGS_GE_DATE.IGSDATE('1700/01/01'))) =
                         TRUNC(NVL(cred.date_received,  IGS_GE_DATE.IGSDATE('1700/01/01')))   )
                  OR ( p_rule = 'R'  AND cred.match_ind IN ('16', '25') )
            )
     UNION ALL
     SELECT  cst_update dmlmode, cred.rowid, ad.person_id, cred.*
     FROM IGS_AD_INTERFACE_ALL ad , IGS_PE_CRED_INT  cred
     WHERE cred.interface_run_id = p_interface_run_id
     AND  ad.status IN ('1', '4')
     AND  cred.interface_id = ad.interface_id
     AND  cred.status = '2'
     AND (       p_rule = 'I'  OR (p_rule = 'R' AND cred.match_ind = cst_mi_val_21))
     AND EXISTS  (SELECT 1 FROM IGS_PE_CREDENTIALS
                          WHERE  person_id = ad.person_id
       	     	          AND credential_type_id = cred.credential_type_id
     		          AND TRUNC(NVL(date_received, IGS_GE_DATE.IGSDATE('1700/01/01'))) =
                           TRUNC(NVL(cred.date_received,  IGS_GE_DATE.IGSDATE('1700/01/01')))
            );

     CURSOR  c_dup_cur(cp_pe_cr_rec  c_pe_cr_cur%ROWTYPE) IS
	SELECT
	  pcreds.rowid, pcreds.*
	FROM
	  igs_pe_credentials pcreds
	WHERE
	  person_id = cp_pe_cr_rec.person_id
	AND credential_type_id = cp_pe_cr_rec.credential_type_id
	AND TRUNC(NVL(date_received, IGS_GE_DATE.IGSDATE('1700/01/01'))) = TRUNC(NVL(cp_pe_cr_rec.date_received,  IGS_GE_DATE.IGSDATE('1700/01/01')));


		  /*************************************************
					END   Cursor Declarations
		 *************************************************/


		 l_processed_records NUMBER(5) := 0;
		 dup_cur_rec    c_dup_cur%ROWTYPE;
                 l_prog_label  VARCHAR2(100) ;
                 l_label  VARCHAR2(150)  ;
                l_debug_str  VARCHAR2(150) ;
                l_error_text VARCHAR2(2000) := NULL;

                  l_msg_at_index   NUMBER := 0;
                  l_return_status   VARCHAR2(1);
                  l_msg_count      NUMBER ;
                  l_msg_data       VARCHAR2(2000);
                  l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;


		/*************************************************
					Local  Procedures
		*************************************************/
		PROCEDURE  validate_pe_cred(cp_pe_cr_rec  c_pe_cr_cur%ROWTYPE,
					p_status OUT   NOCOPY varchar2,
					p_error_code OUT  NOCOPY varchar2)   AS
		/***********************************************
		||   Created By :Praveen Bondugula
		||  Date Created By :24-apr-2003
		||  Purpose : Validates the credentials columns
		|| Known limitations, enhancements or remarks
		||  Change History
		||  Who             When            What
		||
		**********************************************/
			CURSOR  c_credential_type_id (cp_pe_cr_rec  c_pe_cr_cur%ROWTYPE) IS
			SELECT
			'X'
			FROM
			igs_ad_cred_types
			WHERE
			credential_type_id = cp_pe_cr_rec.credential_type_id
			AND closed_ind = 'N';

			CURSOR  c_rating(cp_pe_cr_rec  c_pe_cr_cur%ROWTYPE)IS
			SELECT
			'X'
			FROM
			igs_lookup_values
			WHERE lookup_type = 'PE_CRE_RATING' AND
			  lookup_code = cp_pe_cr_rec.rating_code AND
			  enabled_flag = 'Y';

			CURSOR   c_reviewer_id (cp_pe_cr_rec  c_pe_cr_cur%ROWTYPE) IS
			SELECT
			'X'
			FROM
			  hz_parties
			WHERE
			party_id = cp_pe_cr_rec.reviewer_id;

			credential_type_id_rec  c_credential_type_id%ROWTYPE;
			rating_rec	 c_rating%ROWTYPE;
		BEGIN
			/*************Validate credential_type_id************************/
			OPEN c_credential_type_id(	cp_pe_cr_rec);
			FETCH c_credential_type_id INTO credential_type_id_rec;
			IF c_credential_type_id%NOTFOUND THEN
				p_status :='3';
				p_error_code :=  'E635';
				CLOSE c_credential_type_id;
				RETURN;
			END IF;
			CLOSE c_credential_type_id;

			/*************Validate DATE_RECEIVED************************/
			IF (cp_pe_cr_rec.date_received IS NOT NULL AND (cp_pe_cr_rec.date_received > SYSDATE)) THEN
				p_status :='3';
				p_error_code :=  'E636';
				RETURN;
			END IF;

			/*************Validate rating************************/
			IF cp_pe_cr_rec.rating_code IS NOT NULL THEN
				OPEN c_rating(	cp_pe_cr_rec);
				FETCH c_rating INTO rating_rec;
				IF c_rating%NOTFOUND THEN
					p_status :='3';
					p_error_code :=  'E637';
					CLOSE c_rating;
					RETURN;
				END IF;
				CLOSE c_rating;
			END IF;

			/*************Validate REVIEWER_ID****************/
			IF cp_pe_cr_rec.reviewer_id IS NOT NULL THEN
				IF (IGS_EN_GEN_003.Get_Staff_Ind(cp_pe_cr_rec.reviewer_id)='N') THEN
					p_status :='3';
					p_error_code :=  'E638';
					RETURN;
				END IF;
			END IF;


			p_status :='1';
			p_error_code := NULL;

		END validate_pe_cred;


		PROCEDURE  update_pe_cred(cp_pe_cr_rec  c_pe_cr_cur%ROWTYPE, cp_dup_cur_rec  c_dup_cur%ROWTYPE) AS
		/***********************************************
		||   Created By :Praveen Bondugula
		||  Date Created By :24-apr-2003
		||  Purpose : update  person credentials in the existing record
		|| Known limitations, enhancements or remarks
		||  Change History
		||  Who             When            What
		||
		**********************************************/
		  l_status           VARCHAR2(1);
		  l_error_code       VARCHAR2(30);
		BEGIN
                IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
                     l_label := 'igs.plsql.igs_ad_imp_028.update_pe_cred.begin';
                     l_debug_str :=  'igs_ad_imp_028.update_pe_cred';

                     fnd_log.string_with_context( fnd_log.level_procedure,
  			       l_label,
			       l_debug_str, NULL,
			       NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                 END IF;

			validate_pe_cred(
					cp_pe_cr_rec => cp_pe_cr_rec,
					p_status => l_status,
					p_error_code =>l_error_code
					);
			IF l_status ='1'  THEN
				igs_pe_credentials_pkg.update_row(
				x_rowid                => dup_cur_rec.rowid,
				x_credential_id       =>  dup_cur_rec.credential_id,
				x_person_id                    => cp_dup_cur_rec.person_id,
				x_credential_type_id           => cp_dup_cur_rec.credential_type_id,
				x_date_received                => TRUNC (NVL( cp_pe_cr_rec.date_received, cp_dup_cur_rec.date_received)),
				x_reviewer_id                  =>  NVL(cp_pe_cr_rec.reviewer_id, cp_dup_cur_rec.reviewer_id),
				x_reviewer_notes               =>  NVL(cp_pe_cr_rec.reviewer_notes, cp_dup_cur_rec.reviewer_notes),
				x_recommender_name          =>  NVL( cp_pe_cr_rec.recommender_name, cp_dup_cur_rec.recommender_name),
				x_recommender_title            =>  NVL( cp_pe_cr_rec.recommender_title, cp_dup_cur_rec.recommender_title),
				x_recommender_organization=>  NVL( cp_pe_cr_rec.recommender_organization, cp_dup_cur_rec.recommender_organization),
				x_mode                         => 'R',
				x_rating_code                  =>  NVL( cp_pe_cr_rec.rating_code,cp_dup_cur_rec.rating_code)
				);

					UPDATE igs_pe_cred_int
					SET status = cst_s_val_1, error_code = cst_ec_val_NULL, match_ind = cst_mi_val_18
					WHERE   interface_cred_id = cp_pe_cr_rec.interface_cred_id;
			ELSE

                               UPDATE igs_pe_cred_int
                                SET
                                status = cst_s_val_3
                                , match_ind = DECODE (
                                                     cp_pe_cr_rec.match_ind,
                                                            NULL, cst_mi_val_12,
                                                     match_ind)
                                , error_code = l_error_code
                                WHERE rowid = cp_pe_cr_rec.rowid ;
			   -- Here it is assumed that validate_pe_cred procedure can only return status values '1' or '3'
        	              IF p_enable_log = 'Y' THEN
                                     igs_ad_imp_001.logerrormessage(cp_pe_cr_rec.interface_cred_id,l_error_code,'IGS_PE_CRED_INT');
        	              END IF;

			END IF;

		EXCEPTION
			WHEN OTHERS THEN
			l_status := '3';
			l_error_code := 'E014';

                         l_msg_at_index := igs_ge_msg_stack.count_msg;
                          igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
                         IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                             l_error_text := l_msg_data;
                             IF p_enable_log = 'Y' THEN
                                 igs_ad_imp_001.logerrormessage(cp_pe_cr_rec.interface_cred_id,l_msg_data,'IGS_PE_CRED_INT');
                             END IF;
                         ELSE
                              l_error_text := NULL;
                              IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

			          l_label := 'igs.plsql.igs_ad_imp_028.update_pe_cred.exception '|| l_msg_data;

				  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
				  fnd_message.set_token('INTERFACE_ID',cp_pe_cr_rec.interface_cred_id);
				  fnd_message.set_token('ERROR_CD','E014');

			          l_debug_str :=  fnd_message.get;

     		                  fnd_log.string_with_context( fnd_log.level_exception,
									  l_label,
									  l_debug_str, NULL,
									  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    	                        END IF;

                        END IF;

                        UPDATE igs_pe_cred_int
                        SET
                             status = cst_s_val_3
                             , match_ind = DECODE (
                                                     cp_pe_cr_rec.match_ind,
                                                            NULL, cst_mi_val_12,
                                                     match_ind)
                                , error_code = l_error_code
                                ,error_text = l_error_text
                                WHERE rowid = cp_pe_cr_rec.rowid ;



		END update_pe_cred;


		PROCEDURE insert_pe_cred(cp_pe_cr_rec  c_pe_cr_cur%ROWTYPE) AS
		/***********************************************
		||   Created By :Praveen Bondugula
		||  Date Created By :24-apr-2003
		||  Purpose : Inserts the credentials into the OSS table.
		|| Known limitations, enhancements or remarks
		||  Change History
		||  Who             When            What
		||
		**********************************************/
		  l_status           VARCHAR2(1);
		  l_error_code       VARCHAR2(30);
		   l_rowid           VARCHAR2(25);
		   l_credential_id	   igs_pe_credentials.credential_id%TYPE;

                BEGIN
                 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
                     l_label := 'igs.plsql.igs_ad_imp_028.insert_pe_cred.begin';
                     l_debug_str :=  'igs_ad_imp_028.insert_pe_cred';

                     fnd_log.string_with_context( fnd_log.level_procedure,
  			       l_label,
			       l_debug_str, NULL,
			       NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                 END IF;
			validate_pe_cred(
					cp_pe_cr_rec => cp_pe_cr_rec,
					p_status => l_status,
					p_error_code =>l_error_code
					);
			IF l_status ='1'  THEN
				l_rowid := NULL;
				l_credential_id := NULL;
				igs_pe_credentials_pkg.insert_row(
				x_rowid                => l_rowid,
				x_credential_id       =>  l_credential_id,
				x_person_id                    => cp_pe_cr_rec.person_id,
				x_credential_type_id           => cp_pe_cr_rec.credential_type_id,
				x_date_received                => TRUNC (cp_pe_cr_rec.date_received),
				x_reviewer_id                  => cp_pe_cr_rec.reviewer_id,
				x_reviewer_notes               => cp_pe_cr_rec.reviewer_notes,
				x_recommender_name          => cp_pe_cr_rec.recommender_name,
				x_recommender_title            => cp_pe_cr_rec.recommender_title,
				x_recommender_organization=> cp_pe_cr_rec.recommender_organization,
				x_mode                         => 'R',
				x_rating_code                  => cp_pe_cr_rec.rating_code);

					UPDATE igs_pe_cred_int
					SET status = cst_s_val_1,
                                        error_code = cst_ec_val_NULL,
                                        match_ind = cst_mi_val_11
					WHERE   interface_cred_id = cp_pe_cr_rec.interface_cred_id;
			ELSE
                               UPDATE igs_pe_cred_int
                                SET
                                status = cst_s_val_3
                                , match_ind = DECODE (
                                                     cp_pe_cr_rec.match_ind,
                                                            NULL, cst_mi_val_11,
                                                     match_ind)
                                , error_code = l_error_code
                                WHERE rowid = cp_pe_cr_rec.rowid ;

  		          -- Here it is assumed that validate_pe_cred procedure can only return status values '1' or '3'
                               IF p_enable_log = 'Y' THEN
                                      igs_ad_imp_001.logerrormessage(cp_pe_cr_rec.interface_cred_id,'E322','IGS_PE_CRED_INT');
                               END IF;

				IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

				   l_label := 'igs.plsql.igs_ad_imp_028.insert_pe_cred.exception'||l_msg_data;

			      	    fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			      	    fnd_message.set_token('INTERFACE_ID',cp_pe_cr_rec.interface_cred_id);
			            fnd_message.set_token('ERROR_CD',l_error_code);

				    l_debug_str :=  fnd_message.get;

   		        	    fnd_log.string_with_context( fnd_log.level_exception,
										  l_label,
			      						  l_debug_str, NULL,
			      						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    	                        END IF;
			END IF;

		EXCEPTION
			WHEN OTHERS THEN
		        l_status := '3';
			l_error_code := 'E322';
                        l_msg_at_index := igs_ge_msg_stack.count_msg;
                          igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
                         IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                             l_error_text := l_msg_data;
                             IF p_enable_log = 'Y' THEN
                                 igs_ad_imp_001.logerrormessage(cp_pe_cr_rec.interface_cred_id,l_msg_data,'IGS_PE_CRED_INT');
                             END IF;
                         ELSE
                              l_error_text := NULL;
                              IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

			          l_label := 'igs.plsql.igs_ad_imp_028.update_pe_cred.exception '||'E322';

				  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
				  fnd_message.set_token('INTERFACE_ID',cp_pe_cr_rec.interface_cred_id);
				  fnd_message.set_token('ERROR_CD','E322');

			          l_debug_str :=  fnd_message.get;

     		                  fnd_log.string_with_context( fnd_log.level_exception,
									  l_label,
									  l_debug_str, NULL,
									  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    	                        END IF;

                          END IF;

                        UPDATE igs_pe_cred_int
                        SET
                             status = cst_s_val_3
                             , match_ind = DECODE (
                                                     cp_pe_cr_rec.match_ind,
                                                            NULL, cst_mi_val_11,
                                                     match_ind)
                                , error_code = l_error_code
                                ,error_text = l_error_text
                                WHERE rowid = cp_pe_cr_rec.rowid ;


		END insert_pe_cred;



BEGIN
                 l_prog_label   := 'igs.plsql.igs_ad_imp_028.prc_pe_cred_details';
                 l_label    := 'igs.plsql.igs_ad_imp_008.prc_pe_cred_details.';
                l_debug_str    := 'igs.plsql.igs_ad_imp_008.prc_pe_cred_details.';

 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
  l_label := 'igs.plsql.igs_ad_imp_028.prc_pe_cred_details.begin';
  l_debug_str :=  'igs_ad_imp_028.prc_pe_cred_details';

  fnd_log.string_with_context( fnd_log.level_procedure,
  			       l_label,
			       l_debug_str, NULL,
			       NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
 END IF;
    --	1. Set STATUS to 3 for interface records with RULE = E or I and MATCH IND is not null and not '15'
     IF p_rule IN ('E', 'I')  THEN
             UPDATE IGS_PE_CRED_INT
             SET
             status = '3'
             , error_code = 'E700'
             WHERE interface_run_id = p_interface_run_id
             AND status = '2'
            AND NVL (match_ind, '15') <> '15';
     END IF;
      COMMIT;

     --	2. Set STATUS to 1 for interface records with RULE = R and MATCH IND = 17,18,19,22,23,24,27
     IF p_rule = 'R'  THEN
        UPDATE igs_pe_cred_int
        SET
        status = '1',  error_code = NULL
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND match_ind IN ('17', '18', '19', '22', '23', '24', '27');
     END IF;
      COMMIT;

--  3.	Set STATUS to 3 for interface records with multiple matching duplicate system records for RULE = I
   IF  p_rule = 'I' THEN
     UPDATE igs_pe_cred_int cred
     SET
     status = '3'
     , match_ind = '13'
     WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND 1  <  ( SELECT COUNT(*)
                        FROM igs_pe_credentials  cred_oss
                        WHERE  person_id = (SELECT person_id FROM igs_ad_interface_all
                                                       WHERE interface_id = cred.interface_id)
	AND credential_type_id = cred.credential_type_id
	AND TRUNC(NVL(date_received, IGS_GE_DATE.IGSDATE('1700/01/01'))) =
                         TRUNC(NVL(cred.date_received,  IGS_GE_DATE.IGSDATE('1700/01/01')))
                   );

     END IF;
    COMMIT;
--  4.	Set STATUS to 3 for interface records with multiple matching duplicate system record for RULE = R
--   and either MATCH IND IN (15, 21) OR IS NULL
 IF  p_rule = 'R' THEN
     UPDATE igs_pe_cred_int cred
     SET
     status = '3'
     , match_ind = '13'
    WHERE interface_run_id = p_interface_run_id
    AND status = '2'
    AND NVL(match_ind, '15')  IN ('15', '21')
     AND 1  <  ( SELECT COUNT(*)
                        FROM igs_pe_credentials  cred_oss
                        WHERE  person_id = (SELECT person_id FROM igs_ad_interface_all
                                                       WHERE interface_id = cred.interface_id)
	AND credential_type_id = cred.credential_type_id
	AND TRUNC(NVL(date_received, IGS_GE_DATE.IGSDATE('1700/01/01'))) =
                                TRUNC(NVL(cred.date_received,  IGS_GE_DATE.IGSDATE('1700/01/01')))
                   );

 END IF;
 COMMIT;
    -- 3. Set STATUS to 1 and MATCH IND to 19 for interface records with RULE = E matching OSS record(s)
  IF  p_rule = 'E' THEN
      UPDATE IGS_PE_CRED_INT  cred
      SET
         status = '1'
        , match_ind = '19'
      WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND EXISTS (  SELECT 1 FROM IGS_PE_CREDENTIALS
                         WHERE  person_id IN  (SELECT PERSON_ID FROM IGS_AD_INTERFACE_ALL
                                                WHERE interface_id = cred.interface_id AND interface_run_id = p_interface_run_id)
        		              AND credential_type_id = cred.credential_type_id
 		                      AND TRUNC(NVL(date_received, IGS_GE_DATE.IGSDATE('1700/01/01'))) =
                                      TRUNC(NVL(cred.date_received,  IGS_GE_DATE.IGSDATE('1700/01/01')))
                         );
  END IF;
  COMMIT;

/**********************************************************************************
Create / Update the OSS record after validating successfully the interface record
Create
    If RULE I (match indicator will be 15 or NULL by now no need to check) and matching system record not found OR
    RULE = R and MATCH IND = 16, 25
Update
    If RULE = I (match indicator will be 15 or NULL by now no need to check) OR
    RULE = R and MATCH IND = 21

Selecting together the interface records for INSERT / UPDATE with DMLMODE identifying the DML operation.
This is done to have one code section for record validation, exception handling and interface table update.
This avoids call to separate PLSQL blocks, tuning performance on stack maintenance during the process.

**********************************************************************************/
FOR pe_cr_cur_rec IN c_pe_cr_cur
LOOP
       IF pe_cr_cur_rec.dmlmode =  cst_insert  THEN
           insert_pe_cred(pe_cr_cur_rec);
       ELSIF  pe_cr_cur_rec.dmlmode = cst_update THEN
          OPEN c_dup_cur(pe_cr_cur_rec);
          FETCH c_dup_cur INTO dup_cur_rec;
          CLOSE c_dup_cur;
           update_pe_cred(pe_cr_cur_rec, dup_cur_rec);
       END IF;
       l_processed_records := l_processed_records + 1;
       IF l_processed_records = 100 THEN
          COMMIT;
          l_processed_records := 0;
       END IF;

 END LOOP;
       IF l_processed_records < 100 AND l_processed_records > 0  THEN
         COMMIT;
       END IF;

 /*Set STATUS to 1 and MATCH IND to 23 for interface records with RULE = R matching OSS record(s) in
   ALL updateable column values, if column nullification is not allowed then the 2 DECODE should be replaced by a single NVL*/
     IF p_rule = 'R'  THEN
       UPDATE IGS_PE_CRED_INT  cred
       SET
         status = '1'
         , match_ind = '23'
       WHERE interface_run_id = p_interface_run_id
       AND status = '2'
       AND NVL (match_ind, '15') = '15'
       AND EXISTS ( SELECT   'x'
	  FROM
	   igs_pe_credentials
	  WHERE person_id  IN  (SELECT PERSON_ID FROM IGS_AD_INTERFACE_ALL
                                                WHERE interface_id = cred.interface_id
                                                AND interface_run_id = p_interface_run_id)
	  AND credential_type_id = cred.credential_type_id
	  AND TRUNC(NVL(date_received, IGS_GE_DATE.IGSDATE('1700/01/01'))) =
                           TRUNC(NVL(cred.date_received, NVL(date_received, IGS_GE_DATE.IGSDATE('1700/01/01'))))
	  AND NVL(RATING_CODE, '-1')                         = NVL(cred.rating_code, NVL(RATING_CODE, '-1'))
	  AND NVL(REVIEWER_ID, -1)                    = NVL(cred.reviewer_id, NVL(REVIEWER_ID, -1))
	  AND NVL(REVIEWER_NOTES, '-1')                 = NVL(cred.reviewer_notes, NVL(REVIEWER_NOTES, '-1'))
	  AND NVL(RECOMMENDER_NAME, '-1')               = NVL(cred.recommender_name, NVL(RECOMMENDER_NAME, '-1'))
	  AND NVL(RECOMMENDER_TITLE , '-1')             = NVL(cred.recommender_title, NVL(RECOMMENDER_TITLE , '-1'))
	  AND NVL(recommender_organization, '-1')       = NVL(cred.recommender_organization,NVL(recommender_organization, '-1'))
                );
     END IF;
      COMMIT;

 --Set STATUS to 3 and MATCH IND = 20 for interface records with RULE = R and
 --MATCH IND <> 21, 25, ones failed above discrepancy check
     IF p_rule = 'R'  THEN
        UPDATE IGS_PE_CRED_INT  cred
        SET
        status = '3'
        , match_ind = '20'
        , dup_credential_id= (SELECT credential_id  FROM igs_pe_credentials
                                      WHERE  person_id IN  (SELECT PERSON_ID FROM IGS_AD_INTERFACE_ALL
                                                        WHERE interface_id = cred.interface_id AND interface_run_id = p_interface_run_id)
                                      AND credential_type_id = cred.credential_type_id
                                     AND TRUNC(NVL(date_received, IGS_GE_DATE.IGSDATE('1700/01/01'))) =
                                              TRUNC(NVL(cred.date_received,  IGS_GE_DATE.IGSDATE('1700/01/01'))))
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND NVL (match_ind, '15') = '15'
        AND EXISTS (SELECT credential_id  FROM igs_pe_credentials
                              WHERE  person_id IN  (SELECT PERSON_ID FROM IGS_AD_INTERFACE_ALL
                                                            WHERE interface_id = cred.interface_id AND interface_run_id = p_interface_run_id)
                              AND credential_type_id = cred.credential_type_id
                              AND TRUNC(NVL(date_received, IGS_GE_DATE.IGSDATE('1700/01/01'))) =
                                        TRUNC(NVL(cred.date_received,  IGS_GE_DATE.IGSDATE('1700/01/01'))));

     END IF;
     COMMIT;



  --Set STATUS to 3 for interface records with RULE = R and invalid MATCH IND
     IF p_rule = 'R'  THEN
        UPDATE IGS_PE_CRED_INT  cred
        SET
        status = '3'
        , error_code = 'E700'
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND match_ind IS NOT NULL;
     END IF;
     COMMIT;


END prc_pe_cred_details;


END IGS_AD_IMP_013;

/
