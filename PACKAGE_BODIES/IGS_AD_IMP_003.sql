--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_003" AS
/* $Header: IGSAD81B.pls 120.3 2006/07/31 06:25:35 apadegal noship $ */

-- Start of Main Procedure Process Applicant Academic Interests
/*----------------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  samaresh      24-JAN-2002      The table Igs_ad_appl_int has been obsoleted
  ||                                 new table igs_ad_apl_int has been created
  ||                                 as a part of build ADI - Import Prc Changes
  ||                                 bug# 2191058
  ||  kumma         17-OCT-2002      Replaced eligibility_status_id with eligibility_status_cd and
  ||				     replaced athletic_prg_cd with athletic_prg_code.
  ||			             Replaced igs_ad_code_classes with igs_lookup_values 2608360
  || npalanis       30-OCT-2002      Bug : 2608360
  ||                                 upper function written for eligibility_status_cd and athletic_prg_code
  || pkpatel        6-NOV-2003       Bug 3130316 (Import Process Enhancement) MOved all the Athletics related code to IGSAD90B.pls
  --------------------------------------------------------------------------------*/

    cst_s_val_1    CONSTANT VARCHAR2(1) := '1';
    cst_s_val_2    CONSTANT VARCHAR2(1) := '2';
	  cst_s_val_3    CONSTANT VARCHAR2(1) := '3';
	  cst_s_val_4    CONSTANT VARCHAR2(1) := '4';

    cst_mi_val_11  CONSTANT VARCHAR2(2) := '11';
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

    cst_ec_val_E322 CONSTANT VARCHAR2(4) := 'E322';
    cst_ec_val_E014 CONSTANT VARCHAR2(4) := 'E014';
    cst_ec_val_E702 CONSTANT VARCHAR2(4) := 'E702';
	  cst_ec_val_e700 CONSTANT VARCHAR2(4) := 'E700';
    cst_ec_val_e701 CONSTANT VARCHAR2(4) := 'E701';

    cst_insert       CONSTANT VARCHAR2(6) :=  'INSERT';
    cst_update     CONSTANT VARCHAR2(6) :=  'UPDATE';
    cst_unique_record   CONSTANT NUMBER :=  1;

 PROCEDURE prc_acad_int(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_category_meaning IN VARCHAR2,
                                   p_rule             IN VARCHAR2)
  AS

  CURSOR  c_acadint IS
    SELECT rowid,a.*
    FROM igs_ad_acadint_int a
    WHERE interface_run_id = p_interface_run_id
    AND status = '2';

  l_acadint_rec c_acadint%ROWTYPE;

  l_records_processed NUMBER := 0;

  l_msg_at_index                NUMBER := 0;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

  l_prog_label  VARCHAR2(100);
  p_error_code VARCHAR2(30);
  p_status VARCHAR2(1);
  l_error_code VARCHAR2(30);
  l_request_id NUMBER;
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
	l_enable_log VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_error_text VARCHAR2(2000);
  l_error_text1 VARCHAR2(2000);
  l_type VARCHAR2(1);
  l_status VARCHAR2(1);
  l_acad_int_id NUMBER;

  l_admission_cat VARCHAR2(10);
  l_s_admission_process_type VARCHAR2(30);

BEGIN

  l_msg_at_index := igs_ge_msg_stack.count_msg;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

     IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
     END IF;

     l_label := 'igs.plsql.igs_ad_imp_003.prc_acad_int.begin';

     l_debug_str :=  'Interface Academic Interest ID: '|| l_acadint_rec.interface_acadint_id;

     fnd_log.string_with_context( fnd_log.level_procedure, l_label,l_debug_str, NULL, NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

   l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E678', 8405);

   UPDATE igs_ad_acadint_int a
   SET status = '3',
            error_code = 'E678',
            error_text = l_error_text1
   WHERE
            interface_run_id = p_interface_run_id
   AND status = '2'
   AND EXISTS (SELECT 1 FROM igs_ad_acad_interest b
                             WHERE b.person_id = a.person_id
                             AND b.admission_appl_number = a.admission_appl_number
                             AND b.field_of_study = a.field_of_study );

    l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E420', 8405);

   UPDATE igs_ad_acadint_int a
   SET status = '3',
            error_code = 'E420',
            error_text = l_error_text1
   WHERE interface_run_id = p_interface_run_id
   AND status = '2'
   AND NOT EXISTS ( SELECT 'X'
                                       FROM   igs_ps_fld_of_study_all b
                                       WHERE b.field_of_study = a.field_of_study
                                       AND b.closed_ind = 'N' );

  FOR c_acadint_rec IN c_acadint   LOOP
     BEGIN

        SAVEPOINT acadint_save;

       IF igs_ad_gen_016.get_appl_type_apc (p_application_type         => c_acadint_rec.admission_application_type,
                                                                                 p_admission_cat            => l_admission_cat,
                                                                                 p_s_admission_process_type => l_s_admission_process_type) = 'TRUE' THEN

         IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                               p_s_admission_process_type => l_s_admission_process_type,
                                                               p_s_admission_step_type    => 'ACAD-INTEREST') = 'FALSE' THEN

           FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', c_acadint_rec.admission_application_type);

           l_error_text := FND_MESSAGE.GET;
           l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);

           UPDATE igs_ad_acadint_int
            SET status = cst_s_val_3,
                 error_code = cst_ec_val_E701,
                 error_text = NVL(l_error_text,l_error_text1)
           WHERE  rowid = c_acadint_rec.rowid;

           l_error_text := NULL;
           l_error_text1 := NULL;

       ELSE
         l_rowid := NULL;
         igs_ad_acad_interest_pkg.insert_row
                               (
                                        x_rowid => l_rowid,
                                        x_acad_interest_id => l_acad_int_id,
                                        x_person_id => c_acadint_rec.person_id ,
                                        x_admission_appl_number => c_acadint_rec.admission_appl_number,
                                        x_field_of_study => c_acadint_rec.field_of_study ,
                                        x_mode =>  'R'
                                );

      igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_msg_count > 0 THEN
        l_error_text := l_msg_data;
        l_type := l_hash_msg_name_text_type_tab(l_msg_count-1).type;
      END IF;

      IF l_type = 'E'  THEN
        ROLLBACK TO  acadint_save;
        UPDATE igs_ad_acadint_int
        SET status = cst_s_val_3,
                 error_code = cst_ec_val_E322,
                 error_text = l_error_text
        WHERE  rowid = c_acadint_rec.rowid;

       IF l_enable_log = 'Y'   THEN
          igs_ad_imp_001.logerrormessage(c_acadint_rec.interface_acadint_id,l_msg_data);
      END IF;

      ELSIF l_type = 'S'  THEN
        UPDATE igs_ad_acadint_int
        SET status = cst_s_val_4,
                error_code = cst_ec_val_E702,
                error_text = l_error_text
        WHERE  rowid = c_acadint_rec.rowid;

         IF l_enable_log = 'Y'   THEN
          igs_ad_imp_001.logerrormessage(c_acadint_rec.interface_acadint_id,l_msg_data);
        END IF;

      ELSIF l_type IS NULL THEN
        UPDATE igs_ad_acadint_int
        SET status = cst_s_val_1,
                 error_code = NULL,
                 error_text = NULL
        WHERE  rowid = c_acadint_rec.rowid;

      l_error_text := NULL;

      END IF;

      END IF;

      ELSE

           FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', c_acadint_rec.admission_application_type);

           l_error_text := FND_MESSAGE.GET;
           l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);

           UPDATE igs_ad_acadint_int
            SET status = cst_s_val_3,
                 error_code = cst_ec_val_E701,
                 error_text = NVL(l_error_text,l_error_text1)
           WHERE  rowid = c_acadint_rec.rowid;

      END IF;

      l_error_text := NULL;
      l_records_processed := l_records_processed +1;

  EXCEPTION

       WHEN OTHERS THEN

			l_status := '3';
			l_error_code := 'E322';

      igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

      IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
         IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(c_acadint_rec.interface_acadint_id,l_msg_data);
        END IF;
      ELSE

        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
          l_label :=  'igs.plsql.igs_ad_imp_003.prc_acad_int.exception '||'E322';

  		    fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
		      fnd_message.set_token('CONTEXT',c_acadint_rec.interface_appl_id);
				  fnd_message.set_token('ERROR', l_error_text);

			    l_debug_str :=  fnd_message.get;

       		fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,
                                           									  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;
      END IF;

      ROLLBACK TO  acadint_save;

      UPDATE igs_ad_acadint_int
      SET status = cst_s_val_3,
               error_code = l_error_code ,
               error_text = l_error_text
      WHERE rowid = c_acadint_rec.rowid;

      l_error_text := NULL;
      l_records_processed := l_records_processed + 1;
    END;

       IF l_records_processed = 100 THEN
         COMMIT;
          l_records_processed := 0;
       END IF;
   END LOOP
--   IF l_records_processed < 100 AND l_records_processed > 0 THEN
     COMMIT;
--   END IF;

 END prc_acad_int;

--
-- End of Main Procedure PRC_ACAD_INT

  PROCEDURE prc_apcnt_indt(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_category_meaning IN VARCHAR2,
                                   p_rule             IN VARCHAR2)
  AS

  CURSOR  c_appint IS
    SELECT rowid,a.*
    FROM igs_ad_appint_int a
    WHERE interface_run_id = p_interface_run_id
    AND status = '2';

  l_appint_rec c_appint%ROWTYPE;

  l_records_processed NUMBER := 0;

  l_msg_at_index                NUMBER := 0;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

  l_prog_label  VARCHAR2(100);
  p_error_code VARCHAR2(30);
  p_status VARCHAR2(1);
  l_error_code VARCHAR2(30);
  l_request_id NUMBER;
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
	l_enable_log VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_error_text VARCHAR2(2000);
  l_error_text1 VARCHAR2(2000);
  l_type VARCHAR2(1);
  l_status VARCHAR2(1);
  l_app_int_id NUMBER;

  l_admission_cat VARCHAR2(10);
  l_s_admission_process_type VARCHAR2(30);

BEGIN

  l_msg_at_index := igs_ge_msg_stack.count_msg;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

     IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
     END IF;

     l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_indt.begin';

     l_debug_str :=  'Interface Application Intent ID: '|| l_appint_rec.interface_appint_id;

     fnd_log.string_with_context( fnd_log.level_procedure, l_label,l_debug_str, NULL, NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

   l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E678', 8405);

   UPDATE igs_ad_appint_int a
   SET status = '3',
            error_code = 'E678',
            error_text = l_error_text1
   WHERE
            interface_run_id = p_interface_run_id
   AND status = '2'
   AND EXISTS (SELECT 1 FROM igs_ad_app_intent b
                             WHERE b.person_id = a.person_id
                             AND b.admission_appl_number = a.admission_appl_number
                             AND b.intent_type_id = a.intent_type_id);

  FOR l_appint_rec IN c_appint   LOOP
     l_error_code := NULL;   -- 5386694 - re-intialize this var to null

     BEGIN

       SAVEPOINT appint_save;

       igs_ge_msg_stack.initialize;


       IF igs_ad_gen_016.get_appl_type_apc (p_application_type         => l_appint_rec.admission_application_type,
                                                                                 p_admission_cat            => l_admission_cat,
                                                                                 p_s_admission_process_type => l_s_admission_process_type) = 'TRUE' THEN

         IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                               p_s_admission_process_type => l_s_admission_process_type,
                                                               p_s_admission_step_type    => 'APPL-INTENT') = 'FALSE' THEN

           FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_appint_rec.admission_application_type);
           l_error_text := FND_MESSAGE.GET;
           l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);

           UPDATE igs_ad_appint_int
           SET status = cst_s_val_3,
                    error_code = cst_ec_val_E701,
                    error_text = NVL(l_error_text,l_error_code)
           WHERE  rowid = l_appint_rec.rowid;

           l_error_text := NULL;
           l_error_text1 := NULL;

         ELSE

          IF NOT IGS_AD_IMP_018.validate_desc_flex
          (
                                p_attribute_category    => l_appint_rec.attribute_category,
                                p_attribute1            => l_appint_rec.attribute1,
                                p_attribute2            => l_appint_rec.attribute2,
                                p_attribute3            => l_appint_rec.attribute3,
                                p_attribute4            => l_appint_rec.attribute4,
                                p_attribute5            => l_appint_rec.attribute5,
                                p_attribute6            => l_appint_rec.attribute6,
                                p_attribute7            => l_appint_rec.attribute7,
                                p_attribute8            => l_appint_rec.attribute8,
                                p_attribute9            => l_appint_rec.attribute9,
                                p_attribute10           => l_appint_rec.attribute10,
                                p_attribute11           => l_appint_rec.attribute11,
                                p_attribute12           => l_appint_rec.attribute12,
                                p_attribute13           => l_appint_rec.attribute13,
                                p_attribute14           => l_appint_rec.attribute14,
                                p_attribute15           => l_appint_rec.attribute15,
                                p_attribute16           => l_appint_rec.attribute16,
                                p_attribute17           => l_appint_rec.attribute17,
                                p_attribute18           => l_appint_rec.attribute18,
                                p_attribute19           => l_appint_rec.attribute19,
                                p_attribute20           => l_appint_rec.attribute20,
                                p_desc_flex_name        => 'IGS_AD_APP_INTENT_FLEX'
         ) THEN

        l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E423', 8405);

       UPDATE igs_ad_appint_int
       SET status = '3',
                error_code = 'E423',
                error_text = l_error_text1
       WHERE rowid = l_appint_rec.rowid;

       l_error_text1 := NULL;

     END IF;
      IF l_error_code IS NULL  THEN
      l_rowid := NULL;
    	  igs_ad_app_intent_pkg.insert_row (
                        x_rowid => l_rowid,
                        x_app_intent_id => l_app_int_id,
                        x_person_id => l_appint_rec.person_id,
                        x_admission_appl_number => l_appint_rec.admission_appl_number,
                        x_intent_type_id => l_appint_rec.intent_type_id,
                        x_attribute_category => l_appint_rec.attribute_category,
                        x_attribute1 => l_appint_rec.attribute1,
                        x_attribute2 => l_appint_rec.attribute2,
                        x_attribute3 => l_appint_rec.attribute3,
                        x_attribute4 => l_appint_rec.attribute4,
                        x_attribute5 => l_appint_rec.attribute5,
                        x_attribute6 => l_appint_rec.attribute6,
                        x_attribute7 => l_appint_rec.attribute7,
                        x_attribute8 => l_appint_rec.attribute8,
                        x_attribute9 => l_appint_rec.attribute9,
                        x_attribute10 => l_appint_rec.attribute10,
                        x_attribute11 => l_appint_rec.attribute11,
                        x_attribute12 => l_appint_rec.attribute12,
                        x_attribute13 => l_appint_rec.attribute13,
                        x_attribute14 => l_appint_rec.attribute14,
                        x_attribute15 => l_appint_rec.attribute15,
                        x_attribute16 => l_appint_rec.attribute16,
                        x_attribute17 => l_appint_rec.attribute17,
                        x_attribute18 => l_appint_rec.attribute18,
                        x_attribute19 => l_appint_rec.attribute19,
                        x_attribute20 => l_appint_rec.attribute20,
                        x_mode => 'R'
                        );

        igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_msg_count > 0 THEN
        l_error_text := l_msg_data;
        l_type := l_hash_msg_name_text_type_tab(l_msg_count-1).type;
      END IF;

      IF l_type = 'E'  THEN
        ROLLBACK TO   appint_save;
        UPDATE igs_ad_appint_int
        SET status = cst_s_val_3,
                 error_code = cst_ec_val_E322,
                 error_text = l_error_text
        WHERE  rowid = l_appint_rec.rowid;

      IF l_enable_log = 'Y'  THEN
          igs_ad_imp_001.logerrormessage(l_appint_rec.interface_appint_id,l_msg_data);
      END IF;

      ELSIF l_type = 'S'  THEN
        UPDATE igs_ad_appint_int
        SET status = cst_s_val_4,
                error_code = cst_ec_val_E702,
                error_text = l_error_text
        WHERE  rowid = l_appint_rec.rowid;

      IF l_enable_log = 'Y'  THEN
          igs_ad_imp_001.logerrormessage(l_appint_rec.interface_appint_id,l_msg_data);
      END IF;

      ELSIF l_type IS NULL THEN
        UPDATE igs_ad_appint_int
        SET status = cst_s_val_1,
                 error_code = NULL,
                 error_text = NULL
        WHERE  rowid = l_appint_rec.rowid;

      END IF;
    END IF;
  END IF;
    ELSE

      FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
      FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
      FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_appint_rec.admission_application_type);

      l_error_text := FND_MESSAGE.GET;
      l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);

      UPDATE igs_ad_appint_int
      SET status = cst_s_val_3,
                 error_code = cst_ec_val_E701,
                 error_text = NVL(l_error_text,l_error_text1)
      WHERE  rowid = l_appint_rec.rowid;

      END IF;

      l_error_text := NULL;
      l_error_text1 := NULL;

      l_records_processed := l_records_processed +1;

      EXCEPTION

       WHEN OTHERS THEN
			l_status := '3';
			l_error_code := 'E322';

      igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

      IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
         IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(l_appint_rec.interface_appint_id,l_msg_data);
        END IF;

      ELSE

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
        l_label :=  'igs.plsql.igs_ad_imp_003.prc_acad_int.exception '||'E322';

  		  fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
		    fnd_message.set_token('CONTEXT',l_appint_rec.interface_appl_id);
				fnd_message.set_token('ERROR', l_error_text);

			  l_debug_str :=  fnd_message.get;

     		fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,
                                           									  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;
      END IF;

      ROLLBACK  TO appint_save;

      UPDATE igs_ad_appint_int
      SET status = cst_s_val_3,
               error_code = l_error_code ,
               error_text = l_error_text
      WHERE rowid = l_appint_rec.rowid;

      l_error_text := NULL;

      l_records_processed := l_records_processed + 1;
    END;

       IF l_records_processed = 100 THEN
         COMMIT;
          l_records_processed := 0;
       END IF;
   END LOOP
--   IF l_records_processed < 100 AND l_records_processed > 0 THEN
     COMMIT;
--   END IF;


 END prc_apcnt_indt;

PROCEDURE prc_apcnt_oth_inst_apld(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_category_meaning IN VARCHAR2,
                                   p_rule             IN VARCHAR2)
  AS

  CURSOR  c_oth_inst IS
    SELECT rowid,a.*
    FROM igs_ad_othinst_int a
    WHERE interface_run_id = p_interface_run_id
    AND status = '2';

  l_oth_inst_rec c_oth_inst%ROWTYPE;

  l_records_processed NUMBER := 0;

  l_msg_at_index                NUMBER := 0;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

  l_prog_label  VARCHAR2(100);
  p_error_code VARCHAR2(30);
  p_status VARCHAR2(1);
  l_error_code VARCHAR2(30);
  l_request_id NUMBER;
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
	l_enable_log VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_error_text VARCHAR2(2000);
  l_error_text1 VARCHAR2(2000);
  l_type VARCHAR2(1);
  l_status VARCHAR2(1);
  l_oth_inst_id NUMBER;

  l_admission_cat VARCHAR2(10);
  l_s_admission_process_type VARCHAR2(30);

BEGIN

  l_msg_at_index := igs_ge_msg_stack.count_msg;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

     IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
     END IF;

     l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_oth_inst_apld.begin';

     l_debug_str :=  'Interface Other Institution ID: '|| l_oth_inst_rec.interface_othinst_id;

     fnd_log.string_with_context( fnd_log.level_procedure, l_label,
				                                                 l_debug_str, NULL, NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

   l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E678', 8405);

   UPDATE igs_ad_othinst_int a
   SET status = '3',
            error_code = 'E678',
            error_text = l_error_text1
   WHERE
            interface_run_id = p_interface_run_id
   AND status = '2'
   AND EXISTS (SELECT 1 FROM igs_ad_other_inst b
                             WHERE b.person_id = a.person_id
                             AND b.admission_appl_number = a.admission_appl_number
                             AND b.institution_code = a.institution_cd );

   l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E425', 8405);

  UPDATE igs_ad_othinst_int a
  SET status = '3',
           error_code = 'E425',
           error_text = l_error_text1
  WHERE interface_run_id = p_interface_run_id
  AND        status = '2'
  AND        NOT EXISTS (SELECT  'X'
                         FROM IGS_OR_INST_ORG_BASE_V b
                         WHERE a.institution_cd =  b.party_number -- 5386694 (was wrongly compared with "ou_institution_cd" from the bug 4947103)
		         AND b.inst_org_ind = 'I'
                         AND institution_status IN
				(SELECT institution_status
                                 FROM     igs_or_inst_stat
                                 WHERE s_institution_status = 'ACTIVE')
                        );

  FOR l_oth_inst_rec IN c_oth_inst   LOOP
     BEGIN

         SAVEPOINT oth_inst_save;

         IF igs_ad_gen_016.get_appl_type_apc (p_application_type         => l_oth_inst_rec.admission_application_type,
                                                                                 p_admission_cat            => l_admission_cat,
                                                                                 p_s_admission_process_type => l_s_admission_process_type) = 'TRUE' THEN

         IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                               p_s_admission_process_type => l_s_admission_process_type,
                                                               p_s_admission_step_type    => 'OTH-INST-APPL') = 'FALSE' THEN

           FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_oth_inst_rec.admission_application_type);

           l_error_text := FND_MESSAGE.GET;
           l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);

           UPDATE igs_ad_othinst_int
           SET status = cst_s_val_3,
                    error_code = cst_ec_val_E701,
                    error_text = NVL(l_error_text,l_error_text1)
           WHERE  rowid = l_oth_inst_rec.rowid;

           l_error_text := NULL;

         ELSE
	 l_rowid := NULL;

         igs_ad_other_inst_pkg.insert_row
                               (
                                       x_rowid => l_rowid,
                                       x_other_inst_id => l_oth_inst_id,
                                       x_person_id => l_oth_inst_rec.person_id,
                                       x_admission_appl_number  => l_oth_inst_rec.admission_appl_number,
                                       x_institution_code => l_oth_inst_rec.institution_cd,
                                       x_mode => 'R'
                                );
           igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_msg_count > 0 THEN
        l_error_text := l_msg_data;
        l_type := l_hash_msg_name_text_type_tab(l_msg_count-1).type;
      END IF;

      IF l_type = 'E'  THEN
        ROLLBACK TO  oth_inst_save;
        UPDATE igs_ad_othinst_int
        SET status = cst_s_val_3,
                 error_code = cst_ec_val_E322,
                 error_text = l_error_text
        WHERE  rowid = l_oth_inst_rec.rowid;

       IF l_enable_log = 'Y'   THEN
           igs_ad_imp_001.logerrormessage(l_oth_inst_rec.interface_othinst_id,l_msg_data);
       END IF;

      ELSIF l_type = 'S'  THEN
        UPDATE igs_ad_othinst_int
        SET status = cst_s_val_4,
                error_code =cst_ec_val_E702,
                error_text = l_error_text
        WHERE  rowid = l_oth_inst_rec.rowid;

         IF l_enable_log = 'Y'   THEN
          igs_ad_imp_001.logerrormessage(l_oth_inst_rec.interface_othinst_id,l_msg_data);
        END IF;

      ELSIF l_type IS NULL THEN
        UPDATE igs_ad_othinst_int
        SET status = cst_s_val_1,
                 error_code = NULL,
                 error_text = NULL
        WHERE  rowid = l_oth_inst_rec.rowid;

      l_error_text := NULL;

      END IF;

      END IF;

      ELSE
           FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_oth_inst_rec.admission_application_type);

           l_error_text := FND_MESSAGE.GET;
           l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);

           UPDATE igs_ad_othinst_int
           SET status = cst_s_val_3,
                    error_code = cst_ec_val_E701,
                    error_text = NVL(l_error_text,l_error_text1)
           WHERE  rowid = l_oth_inst_rec.rowid;

      END IF;

      l_error_text := NULL;
      l_records_processed := l_records_processed +1;

      EXCEPTION
       WHEN OTHERS THEN
        l_status := '3';
      	l_error_code := 'E322';

        igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

      IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
         IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(l_oth_inst_rec.interface_othinst_id,l_msg_data);
        END IF;
     ELSE
      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
        l_label :=  'igs.plsql.igs_ad_imp_003.prc_apcnt_oth_inst_apld.exception '||'E322';

  		  fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
		    fnd_message.set_token('CONTEXT',l_oth_inst_rec.interface_appl_id);
				fnd_message.set_token('ERROR', l_error_text);

			  l_debug_str :=  fnd_message.get;

     		fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,
                                           									  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;
      END IF;

      ROLLBACK TO  oth_inst_save;

      UPDATE igs_ad_othinst_int
      SET status = cst_s_val_3,
               error_code = l_error_code ,
               error_text = l_error_text
      WHERE rowid = l_oth_inst_rec.rowid;

      l_error_text := NULL;
     l_records_processed := l_records_processed + 1;
    END;

       IF l_records_processed = 100 THEN
         COMMIT;
          l_records_processed := 0;
       END IF;
   END LOOP
--   IF l_records_processed < 100 AND l_records_processed > 0 THEN
     COMMIT;
--   END IF;

 END prc_apcnt_oth_inst_apld;


 PROCEDURE prc_apcnt_spl_intrst(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_category_meaning IN VARCHAR2,
                                   p_rule             IN VARCHAR2)
  AS

  CURSOR  c_spl_intrst IS
    SELECT rowid,a.*
    FROM igs_ad_splint_int a
    WHERE interface_run_id = p_interface_run_id
    AND status = '2';

  l_spl_intrst_rec c_spl_intrst%ROWTYPE;

  l_records_processed NUMBER := 0;

  l_msg_at_index                NUMBER := 0;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

  l_prog_label  VARCHAR2(100);
  p_error_code VARCHAR2(30);
  p_status VARCHAR2(1);
  l_error_code VARCHAR2(30);
  l_request_id NUMBER;
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
	l_enable_log VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_error_text VARCHAR2(2000);
  l_error_text1 VARCHAR2(2000);
  l_type VARCHAR2(1);
  l_status VARCHAR2(1);
  l_spl_int_id  NUMBER;

  l_admission_cat VARCHAR2(10);
  l_s_admission_process_type VARCHAR2(30);

BEGIN

  l_msg_at_index := igs_ge_msg_stack.count_msg;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

     IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
     END IF;

     l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_spl_intrst.begin';

     l_debug_str :=  'Interface Special Interests ID: '|| l_spl_intrst_rec.interface_splint_id;

     fnd_log.string_with_context( fnd_log.level_procedure, l_label,
				                         l_debug_str, NULL, NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

   l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E678', 8405);

   UPDATE IGS_AD_SPLINT_INT a
   SET status = '3',
            error_code = 'E678',
            error_text = l_error_text1
   WHERE
            interface_run_id = p_interface_run_id
   AND status = '2'
   AND EXISTS (SELECT 1 FROM igs_ad_spl_interests b
                             WHERE b.person_id = a.person_id
                             AND b.admission_appl_number = a.admission_appl_number
                             AND b.special_interest_type_id = a.special_interest_type_id);

  FOR l_spl_intrst_rec IN c_spl_intrst   LOOP
     BEGIN

        SAVEPOINT spl_intrst_save;

       IF igs_ad_gen_016.get_appl_type_apc (p_application_type         => l_spl_intrst_rec.admission_application_type,
                                                                                 p_admission_cat            => l_admission_cat,
                                                                                 p_s_admission_process_type => l_s_admission_process_type) = 'TRUE' THEN

         IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                               p_s_admission_process_type => l_s_admission_process_type,
                                                               p_s_admission_step_type    => 'SPL-INTEREST') = 'FALSE' THEN

           FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_spl_intrst_rec.admission_application_type);

           l_error_text := FND_MESSAGE.GET;
           l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);

           UPDATE igs_ad_splint_int
           SET status = cst_s_val_3,
                    error_code = cst_ec_val_E701,
                    error_text =  NVL(l_error_text,l_error_text1)
           WHERE  rowid = l_spl_intrst_rec.rowid;

           l_error_text := NULL;

       ELSE
                l_rowid := NULL;
        	igs_ad_spl_interests_pkg.insert_row (
      			x_rowid => l_rowid,
       			x_spl_interest_id => l_spl_int_id ,
       			x_person_id  => l_spl_intrst_rec.person_id ,
       			x_admission_appl_number  => l_spl_intrst_rec.admission_appl_number ,
       			x_special_interest_type_id  => l_spl_intrst_rec.special_interest_type_id ,
       			x_mode => 'R'
    			);

        igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_msg_count > 0 THEN
        l_error_text := l_msg_data;
        l_type := l_hash_msg_name_text_type_tab(l_msg_count-1).type;
      END IF;

      IF l_type = 'E'  THEN
        ROLLBACK TO  spl_intrst_save;
        UPDATE IGS_AD_SPLINT_INT
        SET status = cst_s_val_3,
                 error_code = cst_ec_val_E322,
                 error_text = l_error_text
        WHERE  rowid = l_spl_intrst_rec.rowid;

        IF l_enable_log = 'Y'  THEN
          igs_ad_imp_001.logerrormessage(l_spl_intrst_rec.interface_splint_id,l_msg_data);
        END IF;


      ELSIF l_type = 'S'  THEN
        UPDATE IGS_AD_SPLINT_INT
        SET status = cst_s_val_4,
                error_code = cst_ec_val_E702,
                error_text = l_error_text
        WHERE  rowid = l_spl_intrst_rec.rowid;

        IF l_enable_log = 'Y'   THEN
          igs_ad_imp_001.logerrormessage(l_spl_intrst_rec.interface_splint_id,l_msg_data);
        END IF;

      ELSIF l_type IS NULL THEN
        UPDATE IGS_AD_SPLINT_INT
        SET status = cst_s_val_1,
                 error_code = NULL,
                 error_text = NULL
        WHERE  rowid = l_spl_intrst_rec.rowid;

        l_error_text := NULL;

      END IF;
      END IF;

     ELSE

           FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_spl_intrst_rec.admission_application_type);

           l_error_text := FND_MESSAGE.GET;
           l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);

           UPDATE igs_ad_splint_int
           SET status = cst_s_val_3,
                    error_code = cst_ec_val_E701,
                    error_text = NVL(l_error_text,l_error_text1)
           WHERE  rowid = l_spl_intrst_rec.rowid;
        END IF;

      l_error_text := NULL;
      l_records_processed := l_records_processed +1;

      EXCEPTION

       WHEN OTHERS THEN

			l_status := '3';
			l_error_code := 'E322';

      igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

      IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
         IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(l_spl_intrst_rec.interface_splint_id,l_msg_data);
        END IF;

      ELSE

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
        l_label :=  'igs.plsql.igs_ad_imp_003.prc_apcnt_spl_intrst.exception '||'E322';

  		  fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
		    fnd_message.set_token('CONTEXT',l_spl_intrst_rec.interface_appl_id);
				fnd_message.set_token('ERROR', l_error_text);

			  l_debug_str :=  fnd_message.get;

     		fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,
                                           									  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;
      END IF;

      ROLLBACK TO  spl_intrst_save;

      UPDATE IGS_AD_SPLINT_INT
      SET status = cst_s_val_3,
               error_code = l_error_code ,
               error_text = l_error_text
      WHERE rowid = l_spl_intrst_rec.rowid;

      l_error_text := NULL;
      l_records_processed := l_records_processed + 1;
    END;

       IF l_records_processed = 100 THEN
         COMMIT;
          l_records_processed := 0;
       END IF;
   END LOOP
--   IF l_records_processed < 100 AND l_records_processed > 0 THEN
     COMMIT;
--   END IF;

 END prc_apcnt_spl_intrst;

   PROCEDURE prc_apcnt_spl_tal(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_category_meaning IN VARCHAR2,
                                   p_rule             IN VARCHAR2)
  AS

  CURSOR  c_spl_tal IS
    SELECT rowid,a.*
    FROM igs_ad_spltal_int a
    WHERE interface_run_id = p_interface_run_id
    AND status = '2';

  l_spl_tal_rec c_spl_tal%ROWTYPE;

  l_records_processed NUMBER := 0;

  l_msg_at_index                NUMBER := 0;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

  l_prog_label  VARCHAR2(100);
  p_error_code VARCHAR2(30);
  p_status VARCHAR2(1);
  l_error_code VARCHAR2(30);
  l_request_id NUMBER;
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
	l_enable_log VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_error_text VARCHAR2(2000);
  l_error_text1 VARCHAR2(2000);
  l_type VARCHAR2(1);
  l_status VARCHAR2(1);
  l_spl_tal_id NUMBER;

  l_admission_cat VARCHAR2(10);
  l_s_admission_process_type VARCHAR2(30);

BEGIN

  l_msg_at_index := igs_ge_msg_stack.count_msg;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

     IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
     END IF;

     l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_spl_tal.begin';

     l_debug_str :=  'Interface Special Talent ID: '|| l_spl_tal_rec.interface_spltal_id;

     fnd_log.string_with_context( fnd_log.level_procedure, l_label,l_debug_str, NULL, NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

   l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E678', 8405);

   UPDATE IGS_AD_SPLTAL_INT a
   SET status = '3',
            error_code = 'E678',
            error_text = l_error_text1
   WHERE
            interface_run_id = p_interface_run_id
   AND status = '2'
   AND EXISTS (SELECT 1 FROM igs_ad_spl_talents b
                             WHERE b.person_id = a.person_id
                             AND b.admission_appl_number = a.admission_appl_number
                             AND b.special_talent_type_id = a.special_talent_type_id);

  FOR l_spl_tal_rec IN c_spl_tal   LOOP
     BEGIN

        SAVEPOINT spl_tal_save;

       IF igs_ad_gen_016.get_appl_type_apc (p_application_type         => l_spl_tal_rec.admission_application_type,
                                                                                 p_admission_cat            => l_admission_cat,
                                                                                 p_s_admission_process_type => l_s_admission_process_type) = 'TRUE' THEN

         IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                               p_s_admission_process_type => l_s_admission_process_type,
                                                               p_s_admission_step_type    => 'SPL-TALENT') = 'FALSE' THEN

           FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_spl_tal_rec.admission_application_type);

           l_error_text := FND_MESSAGE.GET;
           l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);

        UPDATE igs_ad_spltal_int
        SET status = cst_s_val_3,
                 error_code = cst_ec_val_E701,
                 error_text = NVL(l_error_text,l_error_text1)
        WHERE  rowid = l_spl_tal_rec.rowid;

        l_error_text := NULL;

       ELSE
                l_rowid := NULL;
		igs_ad_spl_talents_pkg.insert_row(
		 x_rowid => l_rowid,
		 x_spl_talent_id => l_spl_tal_id,
		 x_person_id => l_spl_tal_rec.person_id,
		 x_admission_appl_number  => l_spl_tal_rec.admission_appl_number ,
		 x_special_talent_type_id => l_spl_tal_rec.special_talent_type_id,
		 x_mode => 'R' );

        igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_msg_count > 0 THEN
        l_error_text := l_msg_data;
        l_type := l_hash_msg_name_text_type_tab(l_msg_count-1).type;
      END IF;

      IF l_type = 'E'  THEN
        ROLLBACK TO  spl_tal_save;
        UPDATE IGS_AD_SPLTAL_INT
        SET status = cst_s_val_3,
                 error_code = cst_ec_val_E322,
                 error_text = l_error_text
        WHERE  rowid = l_spl_tal_rec.rowid;

      IF l_enable_log = 'Y'  THEN
          igs_ad_imp_001.logerrormessage(l_spl_tal_rec.interface_spltal_id,l_msg_data);
      END IF;


      ELSIF l_type = 'S'  THEN
        UPDATE IGS_AD_SPLTAL_INT
        SET status = cst_s_val_4,
                error_code = cst_ec_val_E702,
                error_text = l_error_text
        WHERE  rowid = l_SPL_TAL_REC.rowid;

         IF l_enable_log = 'Y'   THEN
          igs_ad_imp_001.logerrormessage(l_spl_tal_rec.interface_spltal_id,l_msg_data);
        END IF;

      ELSIF l_type IS NULL THEN
        UPDATE igs_ad_spltal_int
        SET status = cst_s_val_1,
                 error_code = NULL,
                 error_text = NULL
        WHERE  rowid = l_spl_tal_rec.rowid;

      END IF;
      END IF;

ELSE

           FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_spl_tal_rec.admission_application_type);

           l_error_text := FND_MESSAGE.GET;
           l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);

        UPDATE igs_ad_spltal_int
        SET status = cst_s_val_3,
                 error_code = cst_ec_val_E701,
                 error_text =  NVL(l_error_text,l_error_text1)
        WHERE  rowid = l_spl_tal_rec.rowid;

    END IF;

      l_error_text := NULL;
      l_records_processed := l_records_processed +1;

      EXCEPTION

       WHEN OTHERS THEN

			l_status := '3';
			l_error_code := 'E322';

      igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      l_error_text :=  NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

      IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
         IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(l_spl_tal_rec.interface_spltal_id,l_msg_data);
        END IF;

      ELSE

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
        l_label :=  'igs.plsql.igs_ad_imp_003.prc_apcnt_spl_tal.exception '||'E322';

  		  fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
		    fnd_message.set_token('CONTEXT',l_spl_tal_rec.interface_appl_id);
				fnd_message.set_token('ERROR', l_error_text);

			  l_debug_str :=  fnd_message.get;

     		fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,
                                           									  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;
      END IF;

      ROLLBACK TO  spl_tal_save;

      UPDATE IGS_AD_SPLTAL_INT
      SET status = cst_s_val_3,
               error_code = l_error_code ,
               error_text = l_error_text
      WHERE rowid = l_spl_tal_rec.rowid;

      l_error_text := NULL;
      l_records_processed := l_records_processed + 1;
    END;

       IF l_records_processed = 100 THEN
         COMMIT;
          l_records_processed := 0;
       END IF;
   END LOOP
--   IF l_records_processed < 100 AND l_records_processed > 0 THEN
     COMMIT;
--   END IF;


 END prc_apcnt_spl_tal;


 PROCEDURE prc_pe_persstat_details(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_rule             IN VARCHAR2)
  AS

  CURSOR  c_appl_pers IS
    SELECT rowid,a.*
    FROM igs_ad_perstmt_int a
    WHERE interface_run_id = p_interface_run_id
    AND status = '2';

  l_appl_pers_rec c_appl_pers%ROWTYPE;

  l_records_processed NUMBER := 0;

  l_msg_at_index                NUMBER := 0;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

  l_prog_label  VARCHAR2(100);
  p_error_code VARCHAR2(30);
  p_status VARCHAR2(1);
  l_error_code VARCHAR2(30);
  l_request_id NUMBER;
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
	l_enable_log VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_error_text VARCHAR2(2000);
  l_error_text1 VARCHAR2(2000);
  l_type VARCHAR2(1);
  l_status VARCHAR2(1);
  l_appl_perstat_id NUMBER;



BEGIN

  l_msg_at_index := igs_ge_msg_stack.count_msg;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

     IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
     END IF;

     l_label := 'igs.plsql.igs_ad_imp_003.prc_persstat_details.begin';

     l_debug_str :=  'Interface Personal Statement ID: '|| l_appl_pers_rec.interface_perstmt_id;

     fnd_log.string_with_context( fnd_log.level_procedure, l_label,
				                         l_debug_str, NULL, NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

   l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E678', 8405);

   UPDATE igs_ad_perstmt_int a
   SET status = '3',
            error_code = 'E678',
            error_text = l_error_text1
   WHERE
            interface_run_id = p_interface_run_id
   AND status = '2'
   AND EXISTS (SELECT 1 FROM igs_ad_appl_perstat b
                             WHERE b.person_id = a.person_id
                             AND b.admission_appl_number = a.admission_appl_number
                             AND b.persl_stat_type = a.persl_stat_type
			     AND  TRUNC(b.date_received) =  TRUNC(a.date_received));

  FOR l_appl_pers_rec IN c_appl_pers   LOOP
     BEGIN

        SAVEPOINT appl_pers_save;
         l_rowid := NULL;
  	 igs_ad_appl_perstat_pkg.insert_row(
                                x_rowid                => l_rowid,
                                x_appl_perstat_id      => l_appl_perstat_id,
                                x_person_id           => l_appl_pers_rec.person_id,
                                x_admission_appl_number => l_appl_pers_rec.admission_appl_number,
                                x_persl_stat_type      => l_appl_pers_rec.persl_stat_type,
                                x_date_received        => TRUNC(l_appl_pers_rec.date_received),
                                x_mode                 => 'R');

        igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_msg_count > 0 THEN
        l_error_text := l_msg_data;
        l_type := l_hash_msg_name_text_type_tab(l_msg_count-1).type;
      END IF;

      IF l_type = 'E'  THEN
        ROLLBACK TO  appl_pers_save;
        UPDATE igs_ad_perstmt_int
        SET status = cst_s_val_3,
                 error_code = cst_ec_val_E322,
                 error_text = l_error_text
        WHERE  rowid = l_appl_pers_rec.rowid;

         IF l_enable_log = 'Y'   THEN
          igs_ad_imp_001.logerrormessage(l_appl_pers_rec.interface_perstmt_id,l_msg_data);
        END IF;

      ELSIF l_type = 'S'  THEN
        UPDATE igs_ad_perstmt_int
        SET status = cst_s_val_4,
                error_code = cst_ec_val_E702,
                error_text = l_error_text
        WHERE  rowid = l_appl_pers_rec.rowid;

         IF l_enable_log = 'Y'   THEN
          igs_ad_imp_001.logerrormessage(l_appl_pers_rec.interface_perstmt_id,l_msg_data);
        END IF;

      ELSIF l_type IS NULL THEN
        UPDATE igs_ad_perstmt_int
        SET status = cst_s_val_1,
                 error_code = NULL,
                 error_text = NULL
        WHERE  rowid = l_appl_pers_rec.rowid;

      END IF;

      l_error_text := NULL;
      l_records_processed := l_records_processed +1;

      EXCEPTION

       WHEN OTHERS THEN

			l_status := '3';
			l_error_code := 'E322';

      igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

      IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
         IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(l_appl_pers_rec.interface_perstmt_id,l_msg_data);
        END IF;

      ELSE

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
        l_label :=  'igs.plsql.igs_ad_imp_003.prc_persstat_details.exception '||'E322';

  		  fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
		    fnd_message.set_token('CONTEXT',l_appl_pers_rec.interface_appl_id);
				fnd_message.set_token('ERROR', l_error_text);

			  l_debug_str :=  fnd_message.get;

     		fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,
                                           									  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;
      END IF;

      ROLLBACK TO  appl_pers_save;

      UPDATE igs_ad_perstmt_int
      SET status = cst_s_val_3,
               error_code = l_error_code ,
               error_text = l_error_text
      WHERE rowid = l_appl_pers_rec.rowid;

      l_error_text := NULL;
      l_records_processed := l_records_processed + 1;
    END;

       IF l_records_processed = 100 THEN
         COMMIT;
          l_records_processed := 0;
       END IF;
   END LOOP
--   IF l_records_processed < 100 AND l_records_processed > 0 THEN
     COMMIT;
--   END IF;

 END prc_pe_persstat_details;

 PROCEDURE prc_appl_fees(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_rule             IN VARCHAR2)
  AS

    CURSOR  c_appl_fee IS
      SELECT cst_insert dmlmode,rowid,a.*
      FROM igs_ad_fee_int a
      WHERE interface_run_id = p_interface_run_id
      AND status = '2'
      AND (
                  ( NVL(match_ind,'15') = '15'
                    AND NOT EXISTS (SELECT 1 FROM igs_ad_app_req b
                                                       WHERE b.person_id = a.person_id
                                                       AND b.admission_appl_number = a.admission_appl_number
                                                       AND b.applicant_fee_type = a.applicant_fee_type_id
                                                       AND  b.applicant_fee_status = a.applicant_fee_status_id
                                                      AND  TRUNC(b.fee_date) = TRUNC(a.fee_date))
		  )
              OR (p_rule = 'R'
                       AND match_ind IN ('16','25')
                       )
              )
     UNION ALL
     SELECT  cst_update dmlmode, rowid, a.*
     FROM igs_ad_fee_int a
     WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND (
                (p_rule = 'I')
                 OR (p_rule = 'R' AND match_ind = '21')
	       )
     AND EXISTS  (  SELECT 1 FROM igs_ad_app_req b
                                 WHERE b.person_id = a.person_id
                                 AND b.admission_appl_number = a.admission_appl_number
                                 AND b.applicant_fee_type = a.applicant_fee_type_id
                                 AND  b.applicant_fee_status = a.applicant_fee_status_id
                                 AND  TRUNC(b.fee_date) = TRUNC(a.fee_date)
                               );

    CURSOR c_dup_recd  (l_fee_int_rec c_appl_fee%ROWTYPE)  IS
                      SELECT  rowid, appreq.*
                      FROM igs_ad_app_req appreq
                      WHERE person_id = l_fee_int_rec.person_id
                      AND  admission_appl_number = l_fee_int_rec.admission_appl_number
                      AND  applicant_fee_type = l_fee_int_rec.applicant_fee_type_id
                      AND  applicant_fee_status = l_fee_int_rec.applicant_fee_status_id
                      AND  TRUNC(fee_date) = TRUNC(l_fee_int_rec.fee_date);

       l_dup_recd c_dup_recd%ROWTYPE;


       l_records_processed NUMBER := 0;

       l_msg_at_index                NUMBER := 0;
       l_return_status               VARCHAR2(1);
       l_msg_count                   NUMBER;
       l_msg_data                    VARCHAR2(2000);
       l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

       l_prog_label  VARCHAR2(100);
       p_error_code VARCHAR2(30);
       p_status VARCHAR2(1);
       l_error_code VARCHAR2(30);
       l_request_id NUMBER;
       l_label  VARCHAR2(100);
       l_debug_str VARCHAR2(2000);
       l_enable_log VARCHAR2(1);
       l_rowid VARCHAR2(25);
       l_error_text VARCHAR2(2000);
       l_error_text1 VARCHAR2(2000);
       l_type VARCHAR2(1);
       l_status VARCHAR2(1);
       l_app_req_id NUMBER;

  BEGIN

    l_msg_at_index := igs_ge_msg_stack.count_msg;

    IF p_rule IN ('E' ,'I' ) THEN

      l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405);

      UPDATE  igs_ad_fee_int
      SET  status = '3',
                error_code = 'E700',
                error_text = l_error_text1
      WHERE  interface_run_id = p_interface_run_id
      AND  status = '2'
      AND  NVL(match_ind,'15') <> '15';
    END IF;

    IF p_rule = 'R' THEN
      UPDATE igs_ad_fee_int
      SET    status = '1',
                  error_code = NULL,
                  error_text = NULL
      WHERE interface_run_id = p_interface_run_id
      AND  status = '2'
      AND match_ind IN ('17','18','19','22','23','24','27');
    END IF;

    IF p_rule IN ( 'R', 'I') THEN
      l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E681', 8405);
      UPDATE igs_ad_fee_int  a
      SET status = '3'
               ,error_code = 'E681',
               error_text = l_error_text1
      WHERE  interface_run_id = p_interface_run_id
      AND  status = '2'
      AND 1 < (SELECT COUNT (*) FROM igs_ad_app_req b
                       WHERE  b.person_id = a.person_id
                       AND b.admission_appl_number = a.admission_appl_number
                       AND b.applicant_fee_type = a.applicant_fee_type_id
                       AND  b.applicant_fee_status = a.applicant_fee_status_id
                       AND  TRUNC(b.fee_date) = TRUNC(a.fee_date));
    END IF;

    IF  p_rule = 'E' THEN
      UPDATE igs_ad_fee_int a
      SET status = '1',
               error_code = NULL,
               error_text = NULL,
               match_ind = '19'
      WHERE interface_run_id = p_interface_run_id
      AND status = '2'
      AND EXISTS ( SELECT 1 FROM igs_ad_app_req b
                                 WHERE b.person_id = a.person_id
                                 AND b.admission_appl_number = a.admission_appl_number
                                 AND b.applicant_fee_type = a.applicant_fee_type_id
                                 AND  b.applicant_fee_status = a.applicant_fee_status_id
                                 AND  TRUNC(b.fee_date) = TRUNC(a.fee_date));
    END IF;

   FOR l_fee_int_rec IN c_appl_fee   LOOP
     BEGIN

        SAVEPOINT fee_int_save;

        IF l_fee_int_rec.dmlmode = cst_insert THEN
          l_rowid := NULL;
          igs_ad_app_req_pkg.insert_row(
                                        x_rowid                        => l_rowid,
                                        x_app_req_id                   => l_app_req_id,
                                        x_person_id                    =>  l_fee_int_rec.person_id,
                                        x_admission_appl_number        =>  l_fee_int_rec.admission_appl_number,
                                        x_applicant_fee_type           =>  l_fee_int_rec.applicant_fee_type_id,
                                        x_applicant_fee_status         =>  l_fee_int_rec.applicant_fee_status_id,
                                        x_fee_date                     =>  TRUNC(l_fee_int_rec.fee_date),
                                        x_fee_payment_method           => NULL,
                                        x_fee_amount                   =>  l_fee_int_rec.fee_amount,
                                        x_reference_num                =>  l_fee_int_rec.reference_num,
                                        x_mode                         =>   'R',
                                        x_credit_card_code             =>   NULL,
                                        x_credit_card_holder_name      =>    NULL,
                                        x_credit_card_number           =>       NULL,
                                        x_credit_card_expiration_date  =>         NULL,
                                        x_rev_gl_ccid                  =>      NULL,
                                        x_cash_gl_ccid                 =>      NULL,
                                        x_rev_account_cd               =>      NULL,
                                        x_cash_account_cd              =>      NULL,
                                        x_gl_date                      =>      NULL,
                                        x_gl_posted_date               =>       NULL,
                                        x_posting_control_id           =>       NULL,
                                        x_credit_card_tangible_cd      =>  NULL,
                                        x_credit_card_payee_cd         =>  NULL,
                                        x_credit_card_status_code      =>  NULL
                                        );

        ELSIF l_fee_int_rec.dmlmode = cst_update THEN
            OPEN c_dup_recd(l_fee_int_rec);
            FETCH c_dup_recd  INTO l_dup_recd;
            CLOSE c_dup_recd ;
          igs_ad_app_req_pkg.update_row(
                                        x_rowid                        => l_dup_recd.rowid,
                                        x_app_req_id                   => l_dup_recd.app_req_id,
                                        x_person_id                    => l_fee_int_rec.PERSON_ID,
                                        x_admission_appl_numbeR        =>  l_fee_int_rec.admission_appl_number,
                                        x_applicant_fee_type           =>  NVL(l_fee_int_rec.applicant_fee_type_id,   l_dup_recd.applicant_fee_type),
                                        x_applicant_fee_status         =>  NVL(l_fee_int_rec.applicant_fee_status_id, l_dup_recd.applicant_fee_status),
                                        x_fee_date                     =>  TRUNC(NVL(l_fee_int_rec.fee_date, l_dup_recd.fee_date)),
                                        x_fee_payment_method           => l_dup_recd.fee_payment_method,
                                        x_fee_amount                   =>  NVL(l_fee_int_rec.fee_amount, l_dup_recd.fee_amount),
                                        x_reference_num                =>  NVL(l_fee_int_rec.reference_num, l_dup_recd.reference_num),
                                        x_mode                         =>   'R',
                                        x_credit_card_code             =>   l_dup_recd.credit_card_code,
                                        x_credit_card_holder_name      =>   l_dup_recd.credit_card_holder_name,
                                        x_credit_card_number           =>  l_dup_recd.credit_card_number,
                                        x_credit_card_expiration_date  =>      l_dup_recd.credit_card_expiration_date,
                                        x_rev_gl_ccid                  =>   l_dup_recd.rev_gl_ccid,
                                        x_cash_gl_ccid                 =>      l_dup_recd.cash_gl_ccid,
                                        x_rev_account_cd               =>      l_dup_recd.rev_account_cd,
                                        x_cash_account_cd              =>      l_dup_recd.cash_account_cd,
                                        x_gl_date                      =>      l_dup_recd.gl_date,
                                        x_gl_posted_date               =>      l_dup_recd.gl_posted_date,
                                        x_posting_control_id           =>      l_dup_recd.posting_control_id,
                                        x_credit_card_tangible_cd      =>  l_dup_recd.credit_card_tangible_cd,
                                        x_credit_card_payee_cd         =>  l_dup_recd.credit_card_payee_cd,
                                        x_credit_card_status_code      =>  l_dup_recd.credit_card_status_code
                                        );
        END IF;

        UPDATE igs_ad_fee_int
        SET status = cst_s_val_1,
                 error_code = NULL,
                 error_text = NULL,
                 match_ind = DECODE (l_fee_int_rec.dmlmode,  cst_update, cst_mi_val_18,cst_insert, cst_mi_val_11)
        WHERE  rowid = l_fee_int_rec.rowid;

        l_records_processed := l_records_processed +1;

      EXCEPTION
       WHEN OTHERS THEN

			l_status := '3';

      IF l_fee_int_rec.dmlmode = cst_update THEN
        l_error_code := 'E014';
      ELSIF l_fee_int_rec.dmlmode = cst_insert THEN
        l_error_code := 'E322';
      END IF;

      igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

      IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
         IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(l_fee_int_rec.interface_fee_id,l_msg_data);
        END IF;

      ELSE

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
        l_label :=  'igs.plsql.igs_ad_imp_003.prc_acad_int.exception '||l_error_code;

  		  fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
		    fnd_message.set_token('CONTEXT',l_fee_int_rec.interface_appl_id);
				fnd_message.set_token('ERROR', l_error_text);

			  l_debug_str :=  fnd_message.get;

     		fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,
                                           									  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;
      END IF;

      ROLLBACK TO  fee_int_save;

      UPDATE igs_ad_fee_int
      SET status = cst_s_val_3,
               error_code = l_error_code ,
               error_text = l_error_text
      WHERE rowid = l_fee_int_rec.rowid;

      l_error_text := NULL;
      l_records_processed := l_records_processed + 1;
    END;


       IF l_records_processed = 100 THEN
         COMMIT;
          l_records_processed := 0;
       END IF;
   END LOOP;
--   IF l_records_processed < 100 AND l_records_processed > 0 THEN
     COMMIT;
--   END IF;


   UPDATE igs_ad_fee_int a
     SET status = cst_s_val_1,
              error_code = NULL,
              error_text = NULL,
              match_ind = cst_mi_val_23
     WHERE interface_run_id = p_interface_run_id
     AND p_rule = 'R'
     AND NVL (match_ind, cst_mi_val_15) = cst_mi_val_15
     AND EXISTS (
                SELECT rowid FROM igs_ad_app_req  b
                WHERE  b.person_id = a.person_id
                AND         b.admission_appl_number = a.admission_appl_number
                AND b.applicant_fee_type = a.applicant_fee_type_id
                AND  b.applicant_fee_status = a.applicant_fee_status_id
                AND  TRUNC(b.fee_date) = TRUNC(a.fee_date)
		AND NVL(b.reference_num, '-1') =  NVL( NVL(a.reference_num, b.reference_num ) , -1)
		AND b.fee_amount = a.fee_amount);


 IF p_rule = 'R'  THEN
     UPDATE igs_ad_fee_int a
     SET
       status = cst_s_val_3
     , match_ind = cst_mi_val_20
     , dup_app_req_id = ( SELECT APP_REQ_ID FROM igs_ad_app_req b
                              WHERE b.person_id = a.person_id
                              AND         b.admission_appl_number = a.admission_appl_number
                              AND b.applicant_fee_type = a.applicant_fee_type_id
                              AND  b.applicant_fee_status = a.applicant_fee_status_id
                              AND  TRUNC(b.fee_date) = TRUNC(a.fee_date))
     WHERE interface_run_id = p_interface_run_id
     AND status = cst_s_val_2
     AND NVL (match_ind, cst_mi_val_15) = cst_mi_val_15
     AND EXISTS (  SELECT rowid FROM igs_ad_app_req b
                              WHERE b.person_id = a.person_id
                               AND         b.admission_appl_number = a.admission_appl_number
                              AND b.applicant_fee_type = a.applicant_fee_type_id
                              AND  b.applicant_fee_status = a.applicant_fee_status_id
                              AND  TRUNC(b.fee_date) = TRUNC(a.fee_date));
     COMMIT;
  END IF;

  -- Set STATUS to 3 for interface records with RULE = R and invalid MATCH IND
  IF p_rule  = 'R' THEN
     l_error_text1 := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405);

     UPDATE igs_ad_fee_int
     SET
     status = cst_s_val_3
     , error_code = cst_ec_val_E700,
     error_text = l_error_text1
     WHERE interface_run_id = p_interface_run_id
     AND status = cst_s_val_2
     AND match_ind IS NOT NULL;
     COMMIT;
  END IF;

 END prc_appl_fees;

END igs_ad_imp_003;

/
