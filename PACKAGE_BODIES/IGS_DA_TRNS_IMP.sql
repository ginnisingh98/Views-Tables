--------------------------------------------------------
--  DDL for Package Body IGS_DA_TRNS_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_DA_TRNS_IMP" AS
/* $Header: IGSDA12B.pls 120.19 2005/12/11 23:31:01 appldev noship $ */
   l_msg_at_index                  NUMBER                                := 0;
   l_return_status                 VARCHAR2 (1);
   l_debug_str                     VARCHAR2 (1000);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2 (2000);
   l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
   l_label                         VARCHAR2 (200)
                                               := 'igs.plsql.igs_da_trns_imp';
   g_pkg_name             CONSTANT VARCHAR2 (30)         := 'igs_da_trns_imp';

   PROCEDURE write_log (l_debug_str IN VARCHAR2, l_label IN VARCHAR2)
   AS
      l_prog_label   VARCHAR2 (100) := 'igs.plsql.igs_da_trns_imp';
   BEGIN
      ecx_debug.push (l_debug_str);
      ecx_debug.pop (l_debug_str);

      IF fnd_log.test (fnd_log.level_statement, l_prog_label)
      THEN
         fnd_log.string_with_context (fnd_log.level_statement,
                                      l_label,
                                      l_debug_str,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL
                                     );
      END IF;
   END write_log;

   PROCEDURE write_message (p_msg IN VARCHAR2)
   -- this procedure will be used to debug
   IS
   BEGIN
      write_log (p_msg, 'igs.plsql.igs_da_trns_imp.adv_stnd_import');
   END write_message;

   PROCEDURE notify_error (
      p_batch_id       IN   igs_da_rqst.batch_id%TYPE,
      p_person_id      IN   hz_parties.party_id%TYPE,
      p_program_code   IN   igs_av_lgcy_unt_int.program_cd%TYPE,
      p_msg            IN   VARCHAR2
   )
   IS

      v_report_text   VARCHAR2 (4000);
      l_error_code    VARCHAR2 (30)   := 'REPLY_ERROR';
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.NOTIFY_ERROR');

      IF p_msg IS NOT NULL
      THEN
         v_report_text :=
                ' <HTML> <BODY> Error Report <BR> <BR> '
             || p_msg
             || ' '
             || ' </BODY> </HTML> ';
      END IF;

      IF v_report_text IS NOT NULL
      THEN
         UPDATE igs_da_rqst
            SET request_status = 'COMPLETE_ERROR'
          WHERE batch_id = p_batch_id;

         UPDATE igs_da_req_stdnts
            SET report_text = v_report_text,
                ERROR_CODE = l_error_code
          WHERE batch_id = p_batch_id
            AND person_id = p_person_id
            AND program_code = p_program_code;
      END IF;

      write_message ('Calling IGS_DA_TRNS_IMP.NOTIFY_ERROR ' || p_msg);
      igs_da_xml_pkg.process_reply_failure (p_batch_id);
      ecx_debug.pop ('IGS_DA_TRNS_IMP.NOTIFY_ERROR');
   EXCEPTION
      WHEN OTHERS
      THEN
             write_message ('Error occurred. See log for Details' || sqlerrm);
 END notify_error;

   --start of local validation procedure
   PROCEDURE validate_acadhis (
      person_history_rec                trans_cur_rec,
      p_error_code         OUT NOCOPY   VARCHAR2,
      p_status             OUT NOCOPY   VARCHAR2
   )
   AS
      CURSOR c_val_inst_cd_non_uk_cur
      IS
         SELECT hp.ROWID row_id
           FROM hz_parties p, igs_pe_hz_parties hp
          WHERE hp.party_id = p.party_id
            AND hp.inst_org_ind = 'I'
            AND p.party_number = person_history_rec.prev_institution_code;

      CURSOR c_val_inst_cd_uk_cur
      IS
         SELECT hp.ROWID row_id
           FROM hz_parties p,
                igs_pe_hz_parties hp,
                igs_or_org_inst_type_all oit
          WHERE hp.party_id = p.party_id
            AND hp.inst_org_ind = 'I'
            AND p.party_number = person_history_rec.prev_institution_code
            AND hp.oi_institution_type = oit.institution_type(+)
            AND oit.system_inst_type IN ('POST-SECONDARY', 'SECONDARY');

      c_val_inst_cd_rec   c_val_inst_cd_non_uk_cur%ROWTYPE;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.VALIDATE_ACADHIS');
      -- log header
      c_val_inst_cd_rec.row_id := NULL;

      --1. Institution Code
      IF person_history_rec.prev_institution_code IS NOT NULL
      THEN
         IF fnd_profile.VALUE ('OSS_COUNTRY_CODE') <> 'GB'
         THEN
            OPEN c_val_inst_cd_non_uk_cur;
            FETCH c_val_inst_cd_non_uk_cur INTO c_val_inst_cd_rec;
            CLOSE c_val_inst_cd_non_uk_cur;
         ELSE
            OPEN c_val_inst_cd_uk_cur;
            FETCH c_val_inst_cd_uk_cur INTO c_val_inst_cd_rec;
            CLOSE c_val_inst_cd_uk_cur;
         END IF;

         IF c_val_inst_cd_rec.row_id IS NULL
         THEN
            p_error_code := 'E401';
            p_status := '3';
            RETURN;
         END IF;
      END IF;

      --6. START_DATE
      IF person_history_rec.start_date IS NOT NULL
      THEN
         IF NOT person_history_rec.start_date < SYSDATE
         THEN
            p_error_code := 'E405';
            p_status := '3';
            RETURN;
         END IF;
      END IF;

      --7. END_DATE
      IF     person_history_rec.end_date IS NOT NULL
         AND person_history_rec.start_date IS NOT NULL
      THEN
         IF NOT person_history_rec.end_date >= person_history_rec.start_date
         THEN
            p_error_code := 'E406';
            p_status := '3';
            RETURN;
         END IF;
      END IF;

      p_error_code := NULL;
      p_status := '1';
      ecx_debug.pop ('IGS_DA_TRNS_IMP.VALIDATE_ACADHIS');
      RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         ecx_debug.pop ('IGS_DA_TRNS_IMP.VALIDATE_ACADHIS');
        write_message('ERROR ' || sqlerrm);
         p_error_code := 'E518';
         p_status := '3';
         -- log detail
         RETURN;
   END validate_acadhis;

  --end of local validation procedure
---------------------------------------------------------------------------
  -- local procedure to insert the academic history record
   PROCEDURE crc_pe_acad_hist (
      person_history_rec   IN OUT NOCOPY   trans_cur_rec,
      l_error_code         IN OUT NOCOPY   VARCHAR2
   )
   AS
      l_msg_at_index                  NUMBER                             := 0;
      l_return_status                 VARCHAR2 (1);
      l_msg_count                     NUMBER;
      l_msg_data                      VARCHAR2 (2000);
      l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
      l_error_text                    VARCHAR2 (2000);
      l_education_id                  NUMBER;
      l_status                        VARCHAR2 (10);
      l_object_version_number         hz_education.object_version_number%TYPE
                                                                      := NULL;
      l_rowid                         VARCHAR2 (25);
      l_prog_label                    VARCHAR2 (100)
                                               := 'igs.plsql.igs_da_trns_imp';
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.CRC_PE_ACAD_HIST');
      l_status := '1';
      l_error_code := NULL;
      l_error_text := NULL;
      validate_acadhis (person_history_rec, l_error_code, l_status);

      IF l_status = '1'
      THEN
         BEGIN
            l_msg_at_index := igs_ge_msg_stack.count_msg;
            SAVEPOINT before_create_hist;

            IF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') =
                                                                    'EXTERNAL'
               )
            THEN
               write_message ('***** IGS_AD_ACAD_HISTORY_PKG.INSERT_ROW *****'
                             );
               igs_ad_acad_history_pkg.insert_row (x_rowid                            => l_rowid,
                                                   x_attribute14                      => NULL,
                                                   x_attribute15                      => NULL,
                                                   x_attribute16                      => NULL,
                                                   x_attribute17                      => NULL,
                                                   x_attribute18                      => NULL,
                                                   x_attribute19                      => NULL,
                                                   x_attribute20                      => NULL,
                                                   x_attribute13                      => NULL,
                                                   x_attribute11                      => NULL,
                                                   x_attribute12                      => NULL,
                                                   x_education_id                     => l_education_id,
                                                   x_person_id                        => person_history_rec.person_id,
                                                   x_current_inst                     => 'N',
                                                   x_degree_attempted                 => NULL,
                                                   x_program_code                     => NULL,
                                                   x_degree_earned                    => NULL,
                                                   x_comments                         => NULL,
                                                   x_start_date                       => TO_DATE (NULL
                                                                                                 ),
                                                   x_end_date                         => TO_DATE (NULL
                                                                                                 ),
                                                   x_planned_completion_date          => TO_DATE (NULL
                                                                                                 ),
                                                   x_recalc_total_cp_attempted        => NULL,
                                                   x_recalc_total_cp_earned           => NULL,
                                                   x_recalc_total_unit_gp             => NULL,
                                                   x_recalc_tot_gpa_units_attemp      => NULL,
                                                   x_recalc_inst_gpa                  => NULL,
                                                   x_recalc_grading_scale_id          => NULL,
                                                   x_selfrep_total_cp_attempted       => NULL,
                                                   x_selfrep_total_cp_earned          => NULL,
                                                   x_selfrep_total_unit_gp            => NULL,
                                                   x_selfrep_tot_gpa_uts_attemp       => NULL,
                                                   x_selfrep_inst_gpa                 => NULL,
                                                   x_selfrep_grading_scale_id         => NULL,
                                                   x_selfrep_weighted_gpa             => NULL,
                                                   x_selfrep_rank_in_class            => NULL,
                                                   x_selfrep_weighed_rank             => NULL,
                                                   x_type_of_school                   => NULL,
                                                   x_institution_code                 => person_history_rec.prev_institution_code,
                                                   x_attribute_category               => NULL,
                                                   x_attribute1                       => NULL,
                                                   x_attribute2                       => NULL,
                                                   x_attribute3                       => NULL,
                                                   x_attribute4                       => NULL,
                                                   x_attribute5                       => NULL,
                                                   x_attribute6                       => NULL,
                                                   x_attribute7                       => NULL,
                                                   x_attribute8                       => NULL,
                                                   x_attribute9                       => NULL,
                                                   x_attribute10                      => NULL,
                                                   x_selfrep_class_size               => NULL,
                                                   x_transcript_required              => 'Y',
                                                   x_status                           => 'A',
                                                   x_object_version_number            => l_object_version_number,
                                                   x_msg_data                         => l_msg_data,
                                                   x_return_status                    => l_return_status,
                                                   x_mode                             => 'R'
                                                  );
            END IF;

            person_history_rec.education_id := l_education_id;
            ecx_debug.pop ('IGS_DA_TRNS_IMP.CRC_PE_ACAD_HIST');
         EXCEPTION
            WHEN OTHERS
            THEN
               ecx_debug.pop ('IGS_DA_TRNS_IMP.CRC_PE_ACAD_HIST');
               write_message('ERROR ' || sqlerrm);
--               ROLLBACK TO before_create_hist;
               igs_ad_gen_016.extract_msg_from_stack (p_msg_at_index                     => l_msg_at_index,
                                                      p_return_status                    => l_return_status,
                                                      p_msg_count                        => l_msg_count,
                                                      p_msg_data                         => l_msg_data,
                                                      p_hash_msg_name_text_type_tab      => l_hash_msg_name_text_type_tab
                                                     );

               IF l_hash_msg_name_text_type_tab (l_msg_count - 1).NAME <>
                                                                         'ORA'
               THEN
                  l_error_text := l_msg_data;
                  l_error_code := NULL;
                  write_log (l_msg_data,
                             'igs.plsql.igs_da_trns_imp.crc_pe_acad_hist'
                            );
               ELSE
                  l_error_text := NULL;
                  l_error_code := 'E518';

                  IF fnd_log.test (fnd_log.level_exception, l_prog_label)
                  THEN
                     write_log (l_msg_data,
                                'igs.plsql.igs_da_trns_imp.crc_pe_acad_hist'
                               );
                     l_debug_str := fnd_message.get;
                     write_log (l_msg_data,
                                'igs.plsql.igs_da_trns_imp.crc_pe_acad_hist'
                               );
                  END IF;
               END IF;

               write_log (l_error_text,
                          'igs.plsql.igs_da_trns_imp.crc_pe_acad_hist'
                         );
               RETURN;
         END;

         IF l_return_status IN ('E', 'U')
         THEN
            write_log (l_msg_data,
                       'igs.plsql.igs_da_trns_imp.crc_pe_acad_hist'
                      );
         --log detail
         ELSE
            person_history_rec.education_id := l_education_id;
         END IF;
      ELSE -- validation fails
         write_log (igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE',
                                                     l_error_code,
                                                     8405
                                                    ),
                    'igs.plsql.igs_da_trns_imp.crc_pe_acad_hist'
                   );
         NULL;
      END IF; -- end of ( l_error_code IS NULL )       */
   EXCEPTION
      WHEN OTHERS
      THEN
          write_message('ERROR ' || sqlerrm);
   END crc_pe_acad_hist;

   PROCEDURE prc_pe_acad_hist (acad_hist_rec IN OUT NOCOPY trans_cur_rec)
   AS
      CURSOR c_dup_cur
      IS
         SELECT ah.*
           FROM igs_ad_acad_history_v ah
          WHERE (    person_id = acad_hist_rec.person_id
                 AND institution_code = acad_hist_rec.prev_institution_code
                );

      dup_cur_rec    c_dup_cur%ROWTYPE;

      CURSOR c_edu_id
      IS
         SELECT   h1.education_id
             FROM hz_education h1, hz_parties h2
            WHERE h1.party_id = acad_hist_rec.person_id
              AND h2.party_number = acad_hist_rec.prev_institution_code
              AND h2.party_id = h1.school_party_id
         ORDER BY h1.creation_date DESC;

      l_error_code   VARCHAR2 (10);
      l_prog_label   VARCHAR2 (100);
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.PRC_PE_ACAD_HIST');
      l_prog_label := 'igs.plsql.igs_da_trns_imp.crc_pe_acad_hist';
      write_log (   'Entered prc_pe_acad_hist prev_institution_code='
                 || acad_hist_rec.prev_institution_code
                 || ' person_id ='
                 || acad_hist_rec.person_id,
                 'igs.plsql.igs_da_trns_imp.prc_pe_acad_hist'
                );
      OPEN c_dup_cur;
      FETCH c_dup_cur INTO dup_cur_rec;

      IF c_dup_cur%NOTFOUND
      THEN
         write_log ('calling crc_pe_acad_hist ',
                    'igs.plsql.igs_da_trns_imp.prc_pe_acad_hist'
                   );
         crc_pe_acad_hist (acad_hist_rec, l_error_code);
      ELSE
         write_log ('Not calling crc_pe_acad_hist ',
                    'igs.plsql.igs_da_trns_imp.prc_pe_acad_hist'
                   );
         -- find the education id if acad hist exists
         OPEN c_edu_id;
         FETCH c_edu_id INTO acad_hist_rec.education_id;
         CLOSE c_edu_id;

         --If invalid education ID then error out.
         IF acad_hist_rec.education_id IS NULL
         THEN
            write_log (igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE',
                                                        'E711',
                                                        8405
                                                       ),
                       'igs.plsql.igs_da_trns_imp.crc_pe_acad_hist'
                      );
         END IF;
      ---
      END IF;

      CLOSE c_dup_cur;
      ecx_debug.pop ('IGS_DA_TRNS_IMP.PRC_PE_ACAD_HIST');
   EXCEPTION
      WHEN OTHERS
      THEN
           write_message('ERROR ' || sqlerrm);
   END prc_pe_acad_hist;

   PROCEDURE delete_adv_stnd_records (p_person_id IN hz_parties.party_id%TYPE)
   AS
      CURSOR c_edu_id
      IS
         SELECT education_id
           FROM hz_education
          WHERE party_id = p_person_id;

      CURSOR c_trans (cp_education_id igs_ad_transcript.education_id%TYPE)
      IS
         SELECT     trans_oss.ROWID, trans_oss.*
               FROM igs_ad_transcript trans_oss
              WHERE transcript_source IN (
                       SELECT code_id
                         FROM igs_ad_code_classes
                        WHERE CLASS = 'TRANSCRIPT_SOURCE'
                          AND closed_ind = 'N'
                          AND system_status = 'THIRD_PARTY_TRANSFER_EVAL')
                AND education_id = cp_education_id
         FOR UPDATE NOWAIT;

      CURSOR c_trans_term (
         p_transcript_id   igs_ad_term_details.transcript_id%TYPE
      )
      IS
         SELECT     term_oss.ROWID, term_oss.*
               FROM igs_ad_term_details term_oss
              WHERE transcript_id = p_transcript_id
         FOR UPDATE NOWAIT;

      CURSOR c_term_unit (
         p_term_details_id   igs_ad_term_unitdtls.term_details_id%TYPE
      )
      IS
         SELECT     unit_oss.ROWID, unit_oss.*
               FROM igs_ad_term_unitdtls unit_oss
              WHERE term_details_id = p_term_details_id
         FOR UPDATE NOWAIT;

      CURSOR c_adv_stnd_unt (
         p_unit_details_id   igs_ad_term_unitdtls.unit_details_id%TYPE
      )
      IS
         SELECT     unt.ROWID, unt.*
               FROM igs_av_stnd_unit_all unt
              WHERE unit_details_id = p_unit_details_id
         FOR UPDATE NOWAIT;

      CURSOR c_adv_stnd
      IS
         SELECT     adv.ROWID, adv.*
               FROM igs_av_adv_standing_all adv
              WHERE p_person_id = adv.person_id
         FOR UPDATE NOWAIT;

      CURSOR c_adv_unt
      IS
         SELECT     unt.ROWID, unt.*
               FROM igs_av_stnd_unit_all unt
              WHERE p_person_id = unt.person_id
         FOR UPDATE NOWAIT;

      CURSOR c_adv_unt_basis(cp_AV_STND_UNIT_ID  IGS_AV_STD_UNT_BASIS_ALL.AV_STND_UNIT_ID%type)
      IS
         SELECT     unt.ROWID, unt.*
               FROM IGS_AV_STD_UNT_BASIS_ALL unt
              WHERE unt.AV_STND_UNIT_ID = cp_AV_STND_UNIT_ID
         FOR UPDATE NOWAIT;

   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.DELETE_ADV_STND_RECORDS');

      FOR l_edu_id IN c_edu_id
      LOOP
--  delete transcript information
         FOR l_trans IN c_trans (l_edu_id.education_id)
         LOOP
            FOR l_trans_term IN c_trans_term (l_trans.transcript_id)
            LOOP
               FOR l_term_unit IN c_term_unit (l_trans_term.term_details_id)
               LOOP

                  FOR l_adv_stnd_unt IN

		     c_adv_stnd_unt (l_term_unit.unit_details_id)
                  LOOP
		 FOR l__adv_unt_basis IN c_adv_unt_basis(l_adv_stnd_unt.AV_STND_UNIT_ID)
		  LOOP
			IGS_AV_STD_UNT_BASIS_PKG.delete_row (l__adv_unt_basis.ROWID);
                 END LOOP;

--  delete advanced standing information
                     igs_av_stnd_unit_pkg.delete_row (l_adv_stnd_unt.ROWID);
                  END LOOP;

                  igs_ad_term_unitdtls_pkg.delete_row (l_term_unit.ROWID);
               END LOOP;

               igs_ad_term_details_pkg.delete_row (l_trans_term.ROWID);
            END LOOP;

            igs_ad_transcript_pkg.delete_row (l_trans.ROWID);
         END LOOP;
      END LOOP;

-- delete records from igs_av_adv_standing_all


      FOR l_adv_stnd_unt IN c_adv_unt
      LOOP
		 FOR l_adv_unt_basis IN c_adv_unt_basis(l_adv_stnd_unt.AV_STND_UNIT_ID)
		  LOOP
			IGS_AV_STD_UNT_BASIS_PKG.delete_row (l_adv_unt_basis.ROWID);
                 END LOOP;
         igs_av_stnd_unit_pkg.delete_row (l_adv_stnd_unt.ROWID);
      END LOOP;

      FOR l_adv_stnd IN c_adv_stnd
      LOOP
         BEGIN
            igs_av_adv_standing_pkg.delete_row (l_adv_stnd.ROWID);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END LOOP;

      ecx_debug.pop ('IGS_DA_TRNS_IMP.DELETE_ADV_STND_RECORDS');
   EXCEPTION
      WHEN OTHERS
      THEN
            write_message('ERROR ' || sqlerrm);
   END delete_adv_stnd_records;

-- Create new Transcript

   PROCEDURE create_new_transcript_details (
      p_trans_record   IN OUT NOCOPY   trans_cur_rec
   )
   AS
      l_rowid               VARCHAR2 (25);
      l_transcript_id       igs_ad_txcpt_int.transcript_id%TYPE;
      l_error_code          VARCHAR2 (4)                          := NULL;
      l_error_text          VARCHAR2 (2000)                       := NULL;
      override_ind          VARCHAR2 (1)                          := 'N';

      CURSOR c_source
      IS
         SELECT   code_id
             FROM igs_ad_code_classes
            WHERE CLASS = 'TRANSCRIPT_SOURCE'
              AND closed_ind = 'N'
              AND system_status = 'THIRD_PARTY_TRANSFER_EVAL'
         ORDER BY NVL (system_default, 'A') DESC;

      l_transcript_source   igs_ad_code_classes.code_id%TYPE;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.CREATE_NEW_TRANSCRIPT_DETAILS');
      l_transcript_id := NULL;

      BEGIN
         -- insert academic history record or find the education id if one already exists
         SAVEPOINT before_create_transcript;
         prc_pe_acad_hist (p_trans_record);
         l_msg_at_index := igs_ge_msg_stack.count_msg;

         IF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL'
            )
         THEN
            OPEN c_source;
            FETCH c_source INTO l_transcript_source;
            CLOSE c_source;
            write_message ('***** IGS_AD_TRANSCRIPT_PKG.INSERT_ROW *****');
            igs_ad_transcript_pkg.insert_row (x_rowid                  => l_rowid,
                                              x_quintile_rank          => NULL,
                                              x_percentile_rank        => NULL,
                                              x_transcript_id          => l_transcript_id,
                                              x_education_id           => p_trans_record.education_id,
                                              x_transcript_status      => 'FINAL',
                                              x_transcript_source      => l_transcript_source,
                                              x_date_of_receipt        => TRUNC (SYSDATE
                                                                                ),
                                              x_entered_gpa            => NULL,
                                              x_entered_gs_id          => fnd_profile.VALUE ('IGS_AD_INST_GRAD_SCALE'
                                                                                            ),
                                              x_conv_gpa               => NULL,
                                              x_conv_gs_id             => fnd_profile.VALUE ('IGS_AD_INST_GRAD_SCALE'
                                                                                            ),
                                              x_term_type              => p_trans_record.term_type,
                                              x_rank_in_class          => NULL,
                                              x_class_size             => NULL,
                                              x_approximate_rank       => NULL,
                                              x_weighted_rank          => NULL,
                                              x_decile_rank            => NULL,
                                              x_quartile_rank          => NULL,
                                              x_transcript_type        => 'OFFICIAL',
                                              x_mode                   => 'R',
                                              x_date_of_issue          => TRUNC (SYSDATE
                                                                                ),
                                              x_override               => NVL (override_ind,
                                                                               'N'
                                                                              ),
                                              x_override_id            => NULL,
                                              x_override_date          => NULL
                                             );
         END IF;

         p_trans_record.transcript_id := l_transcript_id;
         write_log ('igs_ad_transcript_pkg.insert_row',
                    'igs.plsql.igs_da_trns_imp.create_new_transcript_details'
                   );
         igs_ad_wf_001.transcript_entrd_event (p_trans_record.person_id,
                                               p_trans_record.education_id,
                                               l_transcript_id
                                              );
         ecx_debug.pop ('IGS_DA_TRNS_IMP.CREATE_NEW_TRANSCRIPT_DETAILS');
      EXCEPTION
         WHEN OTHERS
         THEN
            ecx_debug.pop ('IGS_DA_TRNS_IMP.CREATE_NEW_TRANSCRIPT_DETAILS');
               write_message('ERROR ' || sqlerrm);
--            ROLLBACK TO before_create_transcript;
            igs_ad_gen_016.extract_msg_from_stack (p_msg_at_index                     => l_msg_at_index,
                                                   p_return_status                    => l_return_status,
                                                   p_msg_count                        => l_msg_count,
                                                   p_msg_data                         => l_msg_data,
                                                   p_hash_msg_name_text_type_tab      => l_hash_msg_name_text_type_tab
                                                  );

            IF l_hash_msg_name_text_type_tab (l_msg_count - 1).NAME <> 'ORA'
            THEN
               l_error_text := l_msg_data;
               l_error_code := 'E322';
               write_log (l_msg_data,
                          'igs.plsql.igs_da_trns_imp.create_new_transcript_details'
                         );
            ELSE
               l_error_text :=
                  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE',
                                                   'E518',
                                                   8405
                                                  );
               l_error_code := 'E518';
               l_label :=
                      'igs.plsql.igs_da_trns_imp.create_new_transcript_details.exception '
                   || l_msg_data;
               fnd_message.set_name ('IGS', 'IGS_PE_IMP_ERROR');
               fnd_message.set_token ('INTERFACE_ID', 'Some Value');
               fnd_message.set_token ('ERROR_CD', 'E322');
               l_debug_str := fnd_message.get;
               write_log (l_debug_str,
                          'igs.plsql.igs_da_trns_imp.create_new_transcript_details'
                         );
            END IF;

            write_log (l_error_text,
                       'igs.plsql.igs_da_trns_imp.create_new_transcript_details'
                      );
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
          write_message('ERROR ' || sqlerrm);
   END create_new_transcript_details;

-- Update transcript details

   PROCEDURE update_transcript_details (
      p_trans_record   IN OUT NOCOPY   trans_cur_rec
   )
   AS
      l_transcript_id   igs_ad_txcpt_int.transcript_id%TYPE;
      l_error_code      VARCHAR2 (4)                          := NULL;
      l_error_text      VARCHAR2 (2000)                       := NULL;

      CURSOR c_dup_cur
      IS
         SELECT trans_oss.ROWID row_id, trans_oss.*
           FROM igs_ad_transcript trans_oss
          WHERE (    transcript_id = p_trans_record.transcript_id
                 AND p_trans_record.transcript_id IS NOT NULL
                )
             OR (    p_trans_record.transcript_id IS NULL
                 AND education_id = p_trans_record.education_id
                );

      CURSOR c_source
      IS
         SELECT code_id
           FROM igs_ad_code_classes
          WHERE CLASS = 'TRANSCRIPT_SOURCE'
            AND closed_ind = 'N'
            AND system_status = 'THIRD_PARTY_TRANSFER_EVAL';

      dup_cur_rec       c_dup_cur%ROWTYPE;
      l_source          igs_ad_code_classes.code_id%TYPE;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.UPDATE_TRANSCRIPT_DETAILS');
      l_transcript_id := NULL;
      OPEN c_dup_cur;
      FETCH c_dup_cur INTO dup_cur_rec;
      CLOSE c_dup_cur;
      l_msg_at_index := igs_ge_msg_stack.count_msg;
      SAVEPOINT before_update_transcript;

      IF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL')
      THEN
         OPEN c_source;
         FETCH c_source INTO l_source;
         CLOSE c_source;
         igs_ad_transcript_pkg.update_row (x_rowid                  => dup_cur_rec.row_id,
                                           x_quintile_rank          => dup_cur_rec.quintile_rank,
                                           x_percentile_rank        => dup_cur_rec.percentile_rank,
                                           x_transcript_id          => dup_cur_rec.transcript_id,
                                           x_education_id           => dup_cur_rec.education_id,
                                           x_transcript_status      => dup_cur_rec.transcript_status,
                                           x_transcript_source      => l_source,
                                           x_date_of_receipt        => TRUNC (SYSDATE
                                                                             ),
                                           x_entered_gpa            => p_trans_record.unit_grade_points,
                                           x_entered_gs_id          => fnd_profile.VALUE ('IGS_AD_INST_GRAD_SCALE'
                                                                                         ),
                                           x_conv_gpa               => dup_cur_rec.conv_gpa,
                                           x_conv_gs_id             => dup_cur_rec.conv_gs_id,
                                           x_term_type              => p_trans_record.term_type,
                                           x_rank_in_class          => dup_cur_rec.rank_in_class,
                                           x_class_size             => dup_cur_rec.class_size,
                                           x_approximate_rank       => dup_cur_rec.approximate_rank,
                                           x_weighted_rank          => dup_cur_rec.weighted_rank,
                                           x_decile_rank            => dup_cur_rec.decile_rank,
                                           x_quartile_rank          => dup_cur_rec.quartile_rank,
                                           x_transcript_type        => dup_cur_rec.transcript_type,
                                           x_date_of_issue          => dup_cur_rec.date_of_issue,
                                           x_override               => NULL,
                                           x_override_id            => NULL,
                                           x_override_date          => NULL
                                          );
      END IF;

      p_trans_record.transcript_id := dup_cur_rec.transcript_id;
      write_log ('Update trans details',
                 'igs.plsql.igs_da_trns_imp.update_transcript_details'
                );
      ecx_debug.pop ('IGS_DA_TRNS_IMP.UPDATE_TRANSCRIPT_DETAILS');
   EXCEPTION
      WHEN OTHERS
      THEN
         ecx_debug.pop ('IGS_DA_TRNS_IMP.UPDATE_TRANSCRIPT_DETAILS');
           write_message('ERROR ' || sqlerrm);
--         ROLLBACK TO before_update_transcript;
         igs_ad_gen_016.extract_msg_from_stack (p_msg_at_index                     => l_msg_at_index,
                                                p_return_status                    => l_return_status,
                                                p_msg_count                        => l_msg_count,
                                                p_msg_data                         => l_msg_data,
                                                p_hash_msg_name_text_type_tab      => l_hash_msg_name_text_type_tab
                                               );

         IF l_hash_msg_name_text_type_tab (l_msg_count - 1).NAME <> 'ORA'
         THEN
            l_error_text := l_msg_data;
            l_error_code := 'E014';
            write_log (l_msg_data,
                       'igs.plsql.igs_da_trns_imp.update_transcript_details'
                      );
         ELSE
            l_error_text :=
               igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE',
                                                'E518',
                                                8405
                                               );
            l_error_code := 'E518';
            fnd_message.set_name ('IGS', 'IGS_PE_IMP_ERROR');
            fnd_message.set_token ('INTERFACE_ID', 'Some Value');
            fnd_message.set_token ('ERROR_CD', 'E014');
            l_debug_str := fnd_message.get;
            write_log (l_debug_str,
                       'igs.plsql.igs_da_trns_imp.update_transcript_details'
                      );
         END IF;

         write_log (l_error_text,
                    'igs.plsql.igs_da_trns_imp.update_transcript_details'
                   );
   END update_transcript_details;

-- Update term unit details

   PROCEDURE update_term_unit_details (
      p_term_unitdtls_record   IN OUT NOCOPY   trans_cur_rec
   )
   AS
      l_rowid                         VARCHAR2 (25);
      l_var                           VARCHAR2 (25);
      l_msg_at_index                  NUMBER                             := 0;
      l_return_status                 VARCHAR2 (1);
      l_msg_count                     NUMBER;
      l_msg_data                      VARCHAR2 (2000);
      l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
      l_error_code                    VARCHAR2 (4)                    := NULL;
      l_error_text                    VARCHAR2 (2000)                 := NULL;

      CURSOR c_dup_cur
      IS
         SELECT unit_oss.ROWID, unit_oss.*
           FROM igs_ad_term_unitdtls unit_oss
          WHERE term_details_id = p_term_unitdtls_record.term_details_id
            AND unit = p_term_unitdtls_record.unit;

      dup_cur_rec                     c_dup_cur%ROWTYPE;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.UPDATE_TERM_UNIT_DETAILS');
      OPEN c_dup_cur;
      FETCH c_dup_cur INTO dup_cur_rec;
      CLOSE c_dup_cur;
      l_msg_at_index := igs_ge_msg_stack.count_msg;
      SAVEPOINT before_update_unit;

      IF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL')
      THEN
         igs_ad_term_unitdtls_pkg.update_row (x_rowid                  => dup_cur_rec.ROWID,
                                              x_unit_details_id        => dup_cur_rec.unit_details_id,
                                              x_term_details_id        => dup_cur_rec.term_details_id,
                                              x_unit                   => p_term_unitdtls_record.unit,
                                              x_unit_difficulty        => dup_cur_rec.unit_difficulty,
                                              x_unit_name              => p_term_unitdtls_record.unit_name,
                                              x_cp_attempted           => p_term_unitdtls_record.cp_attempted,
                                              x_cp_earned              => p_term_unitdtls_record.cp_earned,
                                              x_grade                  => p_term_unitdtls_record.grade,
                                              x_unit_grade_points      => p_term_unitdtls_record.unit_grade_points
                                             );
      END IF;

      p_term_unitdtls_record.unit_details_id := dup_cur_rec.unit_details_id;
      write_log (   'igs_ad_term_unitdtls_pkg.update_row unit_details_id='
                 || p_term_unitdtls_record.unit_details_id,
                 'igs.plsql.igs_da_trns_imp.update_term_unit_details'
                );
      ecx_debug.pop ('IGS_DA_TRNS_IMP.UPDATE_TERM_UNIT_DETAILS');
   EXCEPTION
      WHEN OTHERS
      THEN
         ecx_debug.pop ('IGS_DA_TRNS_IMP.UPDATE_TERM_UNIT_DETAILS');
          write_message('ERROR ' || sqlerrm);
--         ROLLBACK TO before_update_unit;
         igs_ad_gen_016.extract_msg_from_stack (p_msg_at_index                     => l_msg_at_index,
                                                p_return_status                    => l_return_status,
                                                p_msg_count                        => l_msg_count,
                                                p_msg_data                         => l_msg_data,
                                                p_hash_msg_name_text_type_tab      => l_hash_msg_name_text_type_tab
                                               );

         IF l_hash_msg_name_text_type_tab (l_msg_count - 1).NAME <> 'ORA'
         THEN
            l_error_text := l_msg_data;
            l_error_code := 'E014';
            write_log (l_msg_data,
                       'igs.plsql.igs_da_trns_imp.update_term_unit_details'
                      );
         ELSE
            l_error_text :=
               igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE',
                                                'E518',
                                                8405
                                               );
            l_error_code := 'E518';
            fnd_message.set_name ('IGS', 'IGS_PE_IMP_ERROR');
            fnd_message.set_token ('INTERFACE_ID',
                                   p_term_unitdtls_record.unit_details_id
                                  );
            fnd_message.set_token ('ERROR_CD', 'E014');
            l_debug_str := fnd_message.get;
            write_log (l_debug_str,
                       'igs.plsql.igs_da_trns_imp.update_term_unit_details'
                      );
         END IF;

         write_log (l_error_text,
                    'igs.plsql.igs_da_trns_imp.update_term_unit_details'
                   );
   END update_term_unit_details;

-- Create term unit details

   FUNCTION create_term_unit_details (
      p_term_unitdtls_record   IN OUT NOCOPY   trans_cur_rec
   )
      RETURN igs_ad_term_unitdtls.unit_details_id%TYPE
   AS
      CURSOR c_unit_difficulty
      IS
         SELECT code_id
           FROM igs_ad_code_classes
          WHERE CLASS = 'UNIT_DIFFICULTY' AND NAME = 'STANDARD';

      l_rowid                         VARCHAR2 (25);
      l_var                           VARCHAR2 (25);
      l_unit_details_id               igs_ad_term_unitdtls.unit_details_id%TYPE;
      l_msg_at_index                  NUMBER                             := 0;
      l_return_status                 VARCHAR2 (1);
      l_msg_count                     NUMBER;
      l_msg_data                      VARCHAR2 (2000);
      l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
      l_error_code                    VARCHAR2 (4)                    := NULL;
      l_error_text                    VARCHAR2 (2000)                 := NULL;
      l_unit_difficulty               NUMBER;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.CREATE_TERM_UNIT_DETAILS');
      l_msg_at_index := igs_ge_msg_stack.count_msg;
      SAVEPOINT before_create_unit;

      IF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL')
      THEN
         write_log ('Before igs_ad_term_unitdtls_pkg.insert_row',
                    'igs.plsql.igs_da_trns_imp.create_term_unit_details'
                   );
         OPEN c_unit_difficulty;
         FETCH c_unit_difficulty INTO l_unit_difficulty;
         CLOSE c_unit_difficulty;
         write_message ('***** IGS_AD_TERM_UNITDTLS_PKG.INSERT_ROW *****');
         igs_ad_term_unitdtls_pkg.insert_row (l_rowid,
                                              l_unit_details_id,
                                              p_term_unitdtls_record.term_details_id,
                                              p_term_unitdtls_record.unit,
                                              l_unit_difficulty,
                                              p_term_unitdtls_record.unit_name,
                                              p_term_unitdtls_record.cp_attempted,
                                              p_term_unitdtls_record.cp_earned,
                                              p_term_unitdtls_record.grade,
                                              p_term_unitdtls_record.unit_grade_points
                                             );
      END IF;

      write_log (   'After igs_ad_term_unitdtls_pkg.insert_row l_unit_details_id='
                 || l_unit_details_id,
                 'igs.plsql.igs_da_trns_imp.create_term_unit_details'
                );
      p_term_unitdtls_record.unit_details_id := l_unit_details_id;
      ecx_debug.pop ('IGS_DA_TRNS_IMP.CREATE_TERM_UNIT_DETAILS');
      RETURN l_unit_details_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_message('ERROR ' || sqlerrm);
--         ROLLBACK TO before_create_unit;
         igs_ad_gen_016.extract_msg_from_stack (p_msg_at_index                     => l_msg_at_index,
                                                p_return_status                    => l_return_status,
                                                p_msg_count                        => l_msg_count,
                                                p_msg_data                         => l_msg_data,
                                                p_hash_msg_name_text_type_tab      => l_hash_msg_name_text_type_tab
                                               );

         IF l_hash_msg_name_text_type_tab (l_msg_count - 1).NAME <> 'ORA'
         THEN
            l_error_text := l_msg_data || SQLERRM || ' ERROR';
            l_error_code := 'E322';
            write_log (l_msg_data || SQLERRM,
                       'igs.plsql.igs_da_trns_imp.create_term_unit_details'
                      );
         ELSE
            l_error_text :=
               igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE',
                                                'E518',
                                                8405
                                               );
            l_error_code := 'E518';
            l_label :=
                   'igs.plsql.igs_da_trns_imp.create_term_unit_details.exception '
                || l_msg_data;
            fnd_message.set_name ('IGS', 'IGS_PE_IMP_ERROR');
            fnd_message.set_token ('INTERFACE_ID',
                                   p_term_unitdtls_record.term_details_id
                                  );
            fnd_message.set_token ('ERROR_CD', 'E322');
            l_debug_str := fnd_message.get;
            write_log (l_debug_str,
                       'igs.plsql.igs_da_trns_imp.create_term_unit_details'
                      );
         END IF;

         write_log (l_error_text,
                    'igs.plsql.igs_da_trns_imp.create_term_unit_details'
                   );
   END create_term_unit_details;

   FUNCTION process_term_unit_details (
      p_batch_id        IN              igs_da_req_stdnts.batch_id%TYPE,
      p_person_id       IN              hz_parties.party_id%TYPE,
      p_program_cd      IN              igs_av_lgcy_unt_int.program_cd%TYPE,
      p_trans_cur_rec   IN OUT NOCOPY   trans_cur_rec
   )
      RETURN igs_ad_term_unitdtls.unit_details_id%TYPE
   AS
      l_unit_details_id   igs_ad_term_unitdtls.unit_details_id%TYPE;

      CURSOR c_dup_cur
      IS
         SELECT unit_oss.ROWID, unit_oss.*
           FROM igs_ad_term_unitdtls unit_oss
          WHERE term_details_id = p_trans_cur_rec.term_details_id
            AND unit = p_trans_cur_rec.unit
            AND unit_name = p_trans_cur_rec.unit_name;

      dup_cur_rec         c_dup_cur%ROWTYPE;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.PROCESS_TERM_UNIT_DETAILS');
      write_log ('Entering process_term_unit_details',
                 'igs.plsql.igs_da_trns_imp.process_term_unit_details'
                );
      OPEN c_dup_cur;
      FETCH c_dup_cur INTO dup_cur_rec;

      IF     c_dup_cur%NOTFOUND
         AND (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL'
             )
      THEN
         write_log ('Entering create_term_unit_details',
                    'igs.plsql.igs_da_trns_imp.process_term_unit_details'
                   );
         l_unit_details_id := create_term_unit_details (p_trans_cur_rec);
      ELSIF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL')
      THEN
         write_log ('Entering update_term_unit_details',
                    'igs.plsql.igs_da_trns_imp.process_term_unit_details'
                   );
         l_unit_details_id := dup_cur_rec.unit_details_id;
         update_term_unit_details (p_trans_cur_rec);
      ELSIF c_dup_cur%FOUND
      THEN
         l_unit_details_id := dup_cur_rec.unit_details_id;
      ELSE
         write_log ('Source Unit Not Found',
                    'igs.plsql.igs_da_trns_imp.process_term_unit_details'
                   );
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS',
                                               'IGS_DA_SRC_UNT_NOT_EXIST'
                                              )
                      );
      END IF;

      CLOSE c_dup_cur;
      write_log ('Source Unit l_unit_details_id=' || l_unit_details_id,
                 'igs.plsql.igs_da_trns_imp.process_term_unit_details'
                );
      ecx_debug.pop ('IGS_DA_TRNS_IMP.PROCESS_TERM_UNIT_DETAILS');
      RETURN l_unit_details_id;
   EXCEPTION
      WHEN OTHERS
      THEN
          write_message('ERROR ' || sqlerrm);
   END process_term_unit_details;

   PROCEDURE create_term_details (
      p_term_dtls_record   IN OUT NOCOPY   trans_cur_rec
   )
   AS
      l_rowid                         VARCHAR2 (25);
      l_term_details_id               igs_ad_trmdt_int.term_details_id%TYPE;
      l_msg_at_index                  NUMBER                             := 0;
      l_return_status                 VARCHAR2 (1);
      l_msg_count                     NUMBER;
      l_msg_data                      VARCHAR2 (2000);
      l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
      l_error_code                    VARCHAR2 (4)                    := NULL;
      l_error_text                    VARCHAR2 (2000)                 := NULL;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.CREATE_TERM_DETAILS');
      l_msg_at_index := igs_ge_msg_stack.count_msg;
      SAVEPOINT before_create_term;

      IF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL')
      THEN
         write_message (   'got p_term_dtls_record.transcript_id '
                        || p_term_dtls_record.transcript_id
                       );
         write_message ('***** IGS_AD_TERM_DETAILS_PKG.INSERT_ROW *****');
         igs_ad_term_details_pkg.insert_row (l_rowid,
                                             l_term_details_id,
                                             p_term_dtls_record.transcript_id,
                                             p_term_dtls_record.term,
                                             TRUNC (p_term_dtls_record.start_date
                                                   ),
                                             TRUNC (p_term_dtls_record.end_date
                                                   ),
                                             NULL,
                                             NULL,
                                             NULL,
                                             TO_NUMBER (NULL),
                                             --p_term_dtls_record.total_gpa_units,
                                             TO_NUMBER (NULL)
                                            --p_term_dtls_record.gpa
                                            );
      END IF;

      p_term_dtls_record.term_details_id := l_term_details_id;
      write_log (l_term_details_id,
                 'igs.plsql.igs_da_trns_imp.create_term_details'
                );
      ecx_debug.pop ('IGS_DA_TRNS_IMP.CREATE_TERM_DETAILS');
-- Update Transcript Status
   EXCEPTION
      WHEN OTHERS
      THEN
         ecx_debug.pop ('IGS_DA_TRNS_IMP.CREATE_TERM_DETAILS');
--         ROLLBACK TO before_create_term;
          write_message('ERROR ' || sqlerrm);
         igs_ad_gen_016.extract_msg_from_stack (p_msg_at_index                     => l_msg_at_index,
                                                p_return_status                    => l_return_status,
                                                p_msg_count                        => l_msg_count,
                                                p_msg_data                         => l_msg_data,
                                                p_hash_msg_name_text_type_tab      => l_hash_msg_name_text_type_tab
                                               );

         IF l_hash_msg_name_text_type_tab (l_msg_count - 1).NAME <> 'ORA'
         THEN
            l_error_text := l_msg_data;
            l_error_code := 'E322';
            write_log (l_error_text,
                       'igs.plsql.igs_da_trns_imp.create_term_details'
                      );
         ELSE
            l_error_text :=
               igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE',
                                                'E518',
                                                8405
                                               );
            l_error_code := 'E518';
            l_label :=
                   'igs.plsql.igs_da_trns_imp.create_term_details.exception '
                || l_msg_data;
            fnd_message.set_name ('IGS', 'IGS_PE_IMP_ERROR');
            fnd_message.set_token ('INTERFACE_ID',
                                   p_term_dtls_record.term_details_id
                                  );
            fnd_message.set_token ('ERROR_CD', 'E322');
            l_debug_str := fnd_message.get;
            write_log (l_debug_str,
                       'igs.plsql.igs_da_trns_imp.create_term_details'
                      );
         END IF;

         write_log (l_error_text,
                    'igs.plsql.igs_da_trns_imp.create_term_details'
                   );
   END create_term_details;

   PROCEDURE update_term_details (
      p_term_dtls_record   IN OUT NOCOPY   trans_cur_rec
   )
   AS
      l_msg_at_index                  NUMBER                             := 0;
      l_return_status                 VARCHAR2 (1);
      l_msg_count                     NUMBER;
      l_msg_data                      VARCHAR2 (2000);
      l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
      l_error_code                    VARCHAR2 (4)                    := NULL;
      l_error_text                    VARCHAR2 (2000)                 := NULL;
      l_prog_label                    VARCHAR2 (100)
                           := 'igs.plsql.igs_da_trns_imp.update_term_details';

      CURSOR c_dup_cur
      IS
         SELECT term_oss.ROWID, term_oss.*
           FROM igs_ad_term_details term_oss
          WHERE transcript_id = p_term_dtls_record.transcript_id
            AND term = p_term_dtls_record.term
            AND TRUNC (start_date) = TRUNC (p_term_dtls_record.start_date)
            AND TRUNC (end_date) = TRUNC (p_term_dtls_record.end_date);

      dup_cur_rec                     c_dup_cur%ROWTYPE;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.UPDATE_TERM_DETAILS');
      OPEN c_dup_cur;
      FETCH c_dup_cur INTO dup_cur_rec;
      CLOSE c_dup_cur;
      l_msg_at_index := igs_ge_msg_stack.count_msg;
      SAVEPOINT before_update_term;

      IF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL')
      THEN
         igs_ad_term_details_pkg.update_row (x_rowid                   => dup_cur_rec.ROWID,
                                             x_term_details_id         => dup_cur_rec.term_details_id,
                                             x_transcript_id           => dup_cur_rec.transcript_id,
                                             x_term                    => p_term_dtls_record.term,
                                             x_start_date              => TRUNC (p_term_dtls_record.start_date
                                                                                ),
                                             x_end_date                => TRUNC (p_term_dtls_record.end_date
                                                                                ),
                                             x_total_cp_attempted      => dup_cur_rec.total_cp_attempted,
                                             --dup_cur_rec.total_cp_attempted,
                                             x_total_cp_earned         => dup_cur_rec.total_cp_earned,
                                             --p_term_dtls_record.total_cp_earned,
                                             x_total_unit_gp           => dup_cur_rec.total_unit_gp,
                                             --p_term_dtls_record.total_unit_gp,
                                             x_total_gpa_units         => dup_cur_rec.total_gpa_units,
                                             --p_term_dtls_record.total_gpa_units
                                             x_gpa                     => dup_cur_rec.gpa
                                            );
      END IF;

      p_term_dtls_record.term_details_id := dup_cur_rec.term_details_id;
      write_log ('igs_ad_term_details_pkg.update_row',
                 'igs.plsql.igs_da_trns_imp.update_term_details'
                );
      ecx_debug.pop ('IGS_DA_TRNS_IMP.UPDATE_TERM_DETAILS');
   EXCEPTION
      WHEN OTHERS
      THEN
         ecx_debug.pop ('IGS_DA_TRNS_IMP.UPDATE_TERM_DETAILS');
         write_message('ERROR ' || sqlerrm);
--         ROLLBACK TO before_update_term;
         igs_ad_gen_016.extract_msg_from_stack (p_msg_at_index                     => l_msg_at_index,
                                                p_return_status                    => l_return_status,
                                                p_msg_count                        => l_msg_count,
                                                p_msg_data                         => l_msg_data,
                                                p_hash_msg_name_text_type_tab      => l_hash_msg_name_text_type_tab
                                               );

         IF l_hash_msg_name_text_type_tab (l_msg_count - 1).NAME <> 'ORA'
         THEN
            l_error_text := l_msg_data;
            l_error_code := 'E014';
            write_log (l_msg_data,
                       'igs.plsql.igs_da_trns_imp.update_term_details'
                      );
         ELSE
            l_error_text :=
               igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE',
                                                'E518',
                                                8405
                                               );
            l_error_code := 'E518';

            IF fnd_log.test (fnd_log.level_exception, l_prog_label)
            THEN
               l_label :=
                      'igs.plsql.igs_ad_imp_024.update_term_details.exception '
                   || l_msg_data;
               fnd_message.set_name ('IGS', 'IGS_PE_IMP_ERROR');
               fnd_message.set_token ('INTERFACE_ID',
                                      p_term_dtls_record.term_details_id
                                     );
               fnd_message.set_token ('ERROR_CD', 'E014');
               l_debug_str := fnd_message.get;
               write_log (l_debug_str,
                          'igs.plsql.igs_da_trns_imp.update_term_details'
                         );
            END IF;
         END IF;

         write_log ('igs_da_trns_imp.update_term_details',
                    'igs.plsql.igs_da_trns_imp.update_term_details'
                   );
   END update_term_details;

   PROCEDURE process_term_details (
      p_batch_id        IN              igs_da_req_stdnts.batch_id%TYPE,
      p_person_id       IN              hz_parties.party_id%TYPE,
      p_program_cd      IN              igs_av_lgcy_unt_int.program_cd%TYPE,
      p_trans_cur_rec   IN OUT NOCOPY   trans_cur_rec
   )
   AS
      CURSOR c_dup_cur
      IS
         SELECT term_oss.ROWID, term_oss.*
           FROM igs_ad_term_details term_oss
          WHERE transcript_id = p_trans_cur_rec.transcript_id
            AND term = p_trans_cur_rec.term
            AND TRUNC (start_date) = TRUNC (p_trans_cur_rec.start_date)
            AND TRUNC (end_date) = TRUNC (p_trans_cur_rec.end_date);

      dup_cur_rec   c_dup_cur%ROWTYPE;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.PROCESS_TERM_DETAILS');
      write_log ('process_term_details',
                 'igs.plsql.igs_da_trns_imp.process_term_details'
                );
      OPEN c_dup_cur;
      FETCH c_dup_cur INTO dup_cur_rec;

      IF     c_dup_cur%NOTFOUND
         AND NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL'
      THEN
         create_term_details (p_trans_cur_rec);
      ELSIF NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL'
      THEN
         p_trans_cur_rec.term_details_id := dup_cur_rec.term_details_id;
         update_term_details (p_trans_cur_rec);
      ELSIF c_dup_cur%FOUND
      THEN
         p_trans_cur_rec.term_details_id := dup_cur_rec.term_details_id;
      ELSE
         write_log ('ERROR :- Term details not found ',
                    'igs.plsql.igs_da_trns_imp.update_term_details'
                   );
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       'ERROR :- Term details not found '
                      );
      END IF;

      CLOSE c_dup_cur;
      write_log ('end process_term_details',
                 'igs.plsql.igs_da_trns_imp.process_term_details'
                );
      ecx_debug.pop ('IGS_DA_TRNS_IMP.PROCESS_TERM_DETAILS');
   EXCEPTION
      WHEN OTHERS
      THEN
           write_message('ERROR ' || sqlerrm);
   END process_term_details;

   PROCEDURE create_acad_hist_rec (
      p_batch_id                IN              igs_da_req_stdnts.batch_id%TYPE,
      p_program_cd              IN              igs_av_lgcy_unt_int.program_cd%TYPE,
      p_person_id_code          IN              igs_pe_alt_pers_id.api_person_id%TYPE,
      p_person_id_code_type     IN              igs_pe_alt_pers_id.api_person_id%TYPE,
      p_term_type               IN              VARCHAR2,
      p_term                    IN              igs_ad_term_details.term%TYPE,
      p_start_date              IN              VARCHAR2,
      p_end_date                IN              VARCHAR2,
      p_source_course_subject   IN              VARCHAR2,
      p_source_course_num       IN              VARCHAR2,
      p_unit_name               IN              igs_ad_term_unitdtls.unit_name%TYPE,
      p_inst_id_code            IN              igs_pe_alt_pers_id.api_person_id%TYPE,
      p_inst_id_code_type       IN              igs_pe_alt_pers_id.api_person_id%TYPE,
      p_cp_attempted            IN              igs_ad_term_unitdtls.cp_attempted%TYPE,
      p_cp_earned               IN              igs_ad_term_unitdtls.cp_earned%TYPE,
      p_grade                   IN              igs_ad_term_unitdtls.grade%TYPE,
      p_unit_grade_points       IN              igs_ad_term_unitdtls.unit_grade_points%TYPE,
      p_unit_details_id         OUT NOCOPY      igs_ad_term_unitdtls.unit_details_id%TYPE
   )
   AS
      l_return_status     VARCHAR2 (1);
      l_trans_cur_rec     trans_cur_rec;
      l_unit              igs_ad_term_unitdtls.unit%TYPE;

      CURSOR c_dup_cur
      IS
         SELECT   trans_oss.ROWID, trans_oss.*
             FROM igs_ad_transcript trans_oss
            WHERE trans_oss.term_type = l_trans_cur_rec.term_type
              AND (   (    transcript_id = l_trans_cur_rec.transcript_id
                       AND l_trans_cur_rec.transcript_id IS NOT NULL
                      )
                   OR (    l_trans_cur_rec.transcript_id IS NULL
                       AND education_id = l_trans_cur_rec.education_id
--                 AND TRUNC (date_of_issue) = TRUNC (SYSDATE)
                      )
                  )
         ORDER BY last_update_date DESC;

      CURSOR c_edu_id (
         cp_person_id        hz_education.party_id%TYPE,
         p_school_party_id   hz_education.school_party_id%TYPE
      )
      IS
         SELECT   hz.ROWID, hz.*
             FROM hz_education hz
            WHERE hz.party_id = cp_person_id
              AND hz.school_party_id = p_school_party_id
         ORDER BY hz.last_update_date DESC;

      CURSOR c_transcript_id
      IS
         SELECT   transcript_id
             FROM igs_ad_transcript
            WHERE education_id = l_trans_cur_rec.education_id
              AND transcript_status = 'FINAL'
              AND transcript_source IN (
                     SELECT code_id
                       FROM igs_ad_code_classes
                      WHERE CLASS = 'TRANSCRIPT_SOURCE'
                        AND closed_ind = 'N'
                        AND system_status = 'THIRD_PARTY_TRANSFER_EVAL')
              AND entered_gs_id = fnd_profile.VALUE ('IGS_AD_INST_GRAD_SCALE')
              AND conv_gs_id = fnd_profile.VALUE ('IGS_AD_INST_GRAD_SCALE')
              AND term_type = l_trans_cur_rec.term_type
              AND transcript_type = 'OFFICIAL'
         ORDER BY last_update_date DESC;

      CURSOR c_edu
      IS
         SELECT hz.ROWID, hz.*
           FROM hz_education hz
          WHERE education_id = l_trans_cur_rec.education_id;

      dup_cur_rec         c_dup_cur%ROWTYPE;
      l_person_number     hz_parties.party_number%TYPE;
      l_school_party_id   hz_parties.party_id%TYPE;
      l_edu_rec           c_edu%ROWTYPE;
      l_edu_id_rec        c_edu_id%ROWTYPE;
   BEGIN
      write_message ('      p_batch_id                ' || p_batch_id);
      write_message ('      p_program_cd              ' || p_program_cd);
      write_message ('      p_person_id_code          ' || p_person_id_code);
      write_message (   '      p_person_id_code_type     '
                     || p_person_id_code_type
                    );
      write_message (   '      p_term_type               '
                     || SUBSTR (p_term_type, 1, 1)
                    );
      write_message ('      p_term                    ' || p_term);
      write_message ('      p_start_date              ' || p_start_date);
      write_message ('      p_end_date                ' || p_end_date);
      write_message (   '      p_source_course_subject   '
                     || p_source_course_subject
                    );
      write_message ('      p_source_course_num       ' || p_source_course_num);
      write_message ('      p_unit_name               ' || p_unit_name);
      write_message ('      p_inst_id_code            ' || p_inst_id_code);
      write_message ('      p_inst_id_code_type       ' || p_inst_id_code_type);
      write_message ('      p_cp_attempted            ' || p_cp_attempted);
      write_message ('      p_cp_earned               ' || p_cp_earned);
      write_message ('      p_grade                   ' || p_grade);
      write_message ('      p_unit_grade_points       ' || p_unit_grade_points);
      ecx_debug.push ('IGS_DA_TRNS_IMP.CREATE_ACAD_HIST_REC');
      write_log ('start  create_acad_hist_rec',
                 'igs.plsql.igs_da_trns_imp.create_acad_hist_rec'
                );
      --initialise(trans_cur_rec);
      l_unit := p_source_course_subject || p_source_course_num;
      l_trans_cur_rec.term_type := SUBSTR (p_term_type, 1, 1);
      l_trans_cur_rec.term := p_term;
      l_trans_cur_rec.start_date :=
          TO_DATE (SUBSTR (RTRIM (LTRIM (p_start_date)), 1, 10), 'YYYY-MM-DD');
      l_trans_cur_rec.end_date :=
            TO_DATE (SUBSTR (RTRIM (LTRIM (p_end_date)), 1, 10), 'YYYY-MM-DD');
      l_trans_cur_rec.unit := l_unit;
      l_trans_cur_rec.unit_name := p_unit_name;
      l_trans_cur_rec.cp_attempted := p_cp_attempted;
      l_trans_cur_rec.cp_earned := p_cp_earned;
      l_trans_cur_rec.grade := p_grade;
      l_trans_cur_rec.unit_grade_points := p_unit_grade_points;
      -- get institution code
      igs_da_xml_pkg.get_person_details (RTRIM (LTRIM (p_inst_id_code)),
                                         RTRIM (LTRIM (p_inst_id_code_type)),
                                         l_school_party_id,
                                         l_trans_cur_rec.prev_institution_code
                                        );
      write_message (   'Got  prev_institution_code= '
                     || l_trans_cur_rec.prev_institution_code
                    );
      -- get person ID
      igs_da_xml_pkg.get_person_details (RTRIM (LTRIM (p_person_id_code)),
                                         RTRIM (LTRIM (p_person_id_code_type)),
                                         l_trans_cur_rec.person_id,
                                         l_person_number
                                        );

      -- if student ID is not found

      IF l_trans_cur_rec.person_id IS NULL
      THEN
         write_log ('ERROR Unable to validate student ID',
                    'igs.plsql.igs_da_trns_imp.create_acad_hist_rec'
                   );
         igs_da_xml_pkg.process_reply_failure (p_batch_id);
         p_unit_details_id := NULL;
      END IF;

      OPEN c_edu_id (l_trans_cur_rec.person_id, l_school_party_id);
      FETCH c_edu_id INTO l_edu_id_rec;

      IF c_edu_id%FOUND
      THEN
         l_trans_cur_rec.education_id := l_edu_id_rec.education_id;
         hz_education_pkg.update_row (x_rowid                      => l_edu_id_rec.ROWID,
                                      x_education_id               => l_edu_id_rec.education_id,
                                      x_course_major               => l_edu_id_rec.course_major,
                                      x_party_id                   => l_edu_id_rec.party_id,
                                      x_school_party_id            => l_edu_id_rec.school_party_id,
                                      x_degree_received            => l_edu_id_rec.degree_received,
                                      x_last_date_attended         => l_edu_id_rec.last_date_attended,
                                      x_school_attended_name       => l_edu_id_rec.school_attended_name,
                                      x_type_of_school             => l_edu_id_rec.type_of_school,
                                      x_start_date_attended        => l_edu_id_rec.start_date_attended,
                                      x_status                     => 'A',
                                      x_object_version_number      => l_edu_id_rec.object_version_number,
                                      x_created_by_module          => l_edu_id_rec.created_by_module,
                                      x_application_id             => l_edu_id_rec.application_id
                                     );
      ELSE
         l_trans_cur_rec.education_id := NULL;
      END IF;

      CLOSE c_edu_id;
      write_log ('Got education ID as ' || l_trans_cur_rec.education_id,
                 'igs.plsql.igs_da_trns_imp.create_acad_hist_rec'
                );
      OPEN c_dup_cur;
      FETCH c_dup_cur INTO dup_cur_rec;

      IF (    (l_trans_cur_rec.education_id IS NULL OR c_dup_cur%NOTFOUND)
          AND NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL'
         )
      THEN
         write_log ('Calling  create_new_transcript_details',
                    'igs.plsql.igs_da_trns_imp.create_acad_hist_rec'
                   );
         create_new_transcript_details (l_trans_cur_rec);
      ELSIF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL')
      THEN
         write_log (   'Calling  update_transcript_details for transcript_id='
                    || dup_cur_rec.transcript_id,
                    'igs.plsql.igs_da_trns_imp.create_acad_hist_rec'
                   );
         l_trans_cur_rec.transcript_id := dup_cur_rec.transcript_id;
         update_transcript_details (l_trans_cur_rec);
      ELSIF (c_dup_cur%NOTFOUND)
      THEN
         notify_error (p_batch_id,
                       l_trans_cur_rec.person_id,
                       p_program_cd,
                       'Unable to find transcript information.'
                      );
      END IF;

      IF (    c_dup_cur%FOUND
          AND NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') <>
                                                                    'EXTERNAL'
         )
      THEN
         l_trans_cur_rec.transcript_id := dup_cur_rec.transcript_id;
      END IF;

      CLOSE c_dup_cur;
      write_log ('Before  c_transcript_id',
                 'igs.plsql.igs_da_trns_imp.create_acad_hist_rec'
                );

      IF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL')
      THEN
         OPEN c_transcript_id;
         FETCH c_transcript_id INTO l_trans_cur_rec.transcript_id;
         CLOSE c_transcript_id;
      END IF;

      write_log (   'After  c_transcript_id transcript_id='
                 || l_trans_cur_rec.transcript_id,
                 'igs.plsql.igs_da_trns_imp.create_acad_hist_rec'
                );
      write_log ('Before  process_term_details',
                 'igs.plsql.igs_da_trns_imp.create_acad_hist_rec'
                );
      process_term_details (p_batch_id,
                            l_trans_cur_rec.person_id,
                            p_program_cd,
                            l_trans_cur_rec
                           );
      write_log ('Before  process_term_unit_details',
                 'igs.plsql.igs_da_trns_imp.create_acad_hist_rec'
                );
      p_unit_details_id :=
         process_term_unit_details (p_batch_id,
                                    l_trans_cur_rec.person_id,
                                    p_program_cd,
                                    l_trans_cur_rec
                                   );
--     set the institution rec as inactive

      OPEN c_edu;
      FETCH c_edu INTO l_edu_rec;
      hz_education_pkg.update_row (x_rowid                      => l_edu_rec.ROWID,
                                   x_education_id               => l_edu_rec.education_id,
                                   x_course_major               => l_edu_rec.course_major,
                                   x_party_id                   => l_edu_rec.party_id,
                                   x_school_party_id            => l_edu_rec.school_party_id,
                                   x_degree_received            => l_edu_rec.degree_received,
                                   x_last_date_attended         => l_edu_rec.last_date_attended,
                                   x_school_attended_name       => l_edu_rec.school_attended_name,
                                   x_type_of_school             => l_edu_rec.type_of_school,
                                   x_start_date_attended        => l_edu_rec.start_date_attended,
                                   x_status                     => 'I',
                                   x_object_version_number      => l_edu_rec.object_version_number,
                                   x_created_by_module          => l_edu_rec.created_by_module,
                                   x_application_id             => l_edu_rec.application_id
                                  );
      CLOSE c_edu;
--      COMMIT;
      ecx_debug.pop ('IGS_DA_TRNS_IMP.CREATE_ACAD_HIST_REC');
   EXCEPTION
      WHEN OTHERS
      THEN
          write_message('ERROR ' || sqlerrm);
   END create_acad_hist_rec;

/********************************************************************
Create Advanced Standing Record
********************************************************************/
   FUNCTION get_adv_stnd_granting_status (
      p_batch_id   igs_da_rqst.batch_id%TYPE
   )
      RETURN igs_av_stnd_unit_all.s_adv_stnd_granting_status%TYPE
   IS
      CURSOR c_ftr_val
      IS
         SELECT feature_value
           FROM igs_da_req_ftrs
          WHERE batch_id = p_batch_id AND feature_code = 'AUT';

      l_automatic_grant   VARCHAR2 (5);
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.GET_ADV_STND_GRANTING_STATUS');

      IF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL')
      THEN
         RETURN 'GRANTED';
      ELSE
         -- check if autmatically grant adv stnd is checked

         OPEN c_ftr_val;
         FETCH c_ftr_val INTO l_automatic_grant;
         CLOSE c_ftr_val;

         IF (NVL (l_automatic_grant, 'N') = 'Y')
         THEN
            RETURN 'GRANTED';
         ELSE
            RETURN 'APPROVED';
         END IF;
      END IF;

      ecx_debug.pop ('IGS_DA_TRNS_IMP.GET_ADV_STND_GRANTING_STATUS');
   EXCEPTION
      WHEN OTHERS
      THEN
        write_message('ERROR ' || sqlerrm);
   END get_adv_stnd_granting_status;

   FUNCTION validate_parameters (
      p_batch_id         IN   igs_da_rqst.batch_id%TYPE,
      p_person_id        IN   igs_da_rqst.person_id%TYPE,
      p_person_number    IN   igs_av_lgcy_unt_int.person_number%TYPE,
      p_program_cd       IN   igs_av_lgcy_unt_int.program_cd%TYPE,
      p_unit_cd          IN   igs_av_lgcy_unt_int.unit_cd%TYPE, --- advstnd unit
      p_version_number   IN   igs_av_lgcy_unt_int.version_number%TYPE
   )
      RETURN BOOLEAN
   IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_parameters                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This function checks all the mandatory parameters for the    |
 |                passed record type are not null ,and adds error messages to|
 |                the stack for all the parameters.                          |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-08-2005  Created                                          |
 +===========================================================================*/
      l_b_return_val     BOOLEAN       DEFAULT TRUE;
      l_s_message_name   VARCHAR2 (30);
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.VALIDATE_PARAMETERS');
      write_message ('Inside validate_parameters');

      IF p_person_number IS NULL
      THEN
         l_s_message_name := 'IGS_EN_PER_NUM_NULL';
         l_b_return_val := FALSE;
         fnd_message.set_name ('IGS', l_s_message_name);
         fnd_msg_pub.ADD;
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS', 'IGS_EN_PER_NUM_NULL')
                      );
      END IF;

      IF p_program_cd IS NULL
      THEN
         l_s_message_name := 'IGS_EN_PRGM_CD_NULL';
         l_b_return_val := FALSE;
         fnd_message.set_name ('IGS', l_s_message_name);
         fnd_msg_pub.ADD;
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS', 'IGS_EN_PRGM_CD_NULL')
                      );
      END IF;

      IF p_unit_cd IS NULL
      THEN
         l_s_message_name := 'IGS_AV_UNIT_CD_NULL';
         l_b_return_val := FALSE;
         fnd_message.set_name ('IGS', l_s_message_name);
         fnd_msg_pub.ADD;
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS', 'IGS_AV_UNIT_CD_NULL')
                      );
      END IF;

      IF p_version_number IS NULL
      THEN
         l_s_message_name := 'IGS_AV_UNIT_VER_NULL';
         l_b_return_val := FALSE;
         fnd_message.set_name ('IGS', l_s_message_name);
         fnd_msg_pub.ADD;
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS',
                                               'IGS_DA_TGT_UNT_NOT_EXIST'
                                              )
                      );
      END IF;

      write_message ('Comming Out Of validate_parameters' || l_s_message_name);
      ecx_debug.pop ('IGS_DA_TRNS_IMP.VALIDATE_PARAMETERS');
      RETURN l_b_return_val;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_message('ERROR ' || sqlerrm);
   END validate_parameters;

   FUNCTION derive_unit_data (
      p_batch_id                   IN              igs_da_rqst.batch_id%TYPE,
      p_person_number              IN              igs_av_lgcy_unt_int.person_number%TYPE,
      p_program_cd                 IN              igs_av_lgcy_unt_int.program_cd%TYPE,
      p_unit_cd                    IN              igs_av_lgcy_unt_int.unit_cd%TYPE, --- advstnd unit
      p_version_number             IN              igs_av_lgcy_unt_int.version_number%TYPE,
      p_institution_cd             IN              igs_av_lgcy_unt_int.institution_cd%TYPE,
      p_load_cal_alt_code          IN              igs_av_lgcy_unt_int.load_cal_alt_code%TYPE,
      p_avstnd_grade               IN              igs_av_lgcy_unt_int.grade%TYPE,
      p_achievable_credit_points   IN OUT NOCOPY   igs_av_lgcy_unt_int.achievable_credit_points%TYPE,
      p_person_id                  IN OUT NOCOPY   igs_pe_person.person_id%TYPE,
      p_s_adv_stnd_type            IN OUT NOCOPY   igs_av_stnd_unit_all.s_adv_stnd_type%TYPE,
      p_cal_type                   IN OUT NOCOPY   igs_ca_inst.cal_type%TYPE,
      p_seq_number                 IN OUT NOCOPY   igs_ca_inst.sequence_number%TYPE,
      p_auth_pers_id               IN OUT NOCOPY   igs_pe_person.person_id%TYPE,
      p_as_version_number          IN OUT NOCOPY   igs_en_stdnt_ps_att.version_number%TYPE
   )
      RETURN BOOLEAN
   IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              derive_unit_data                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This function derives advanced standing unit level data      |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-08-2005  Created                                          |
 +===========================================================================*/
      l_n_rec_count     NUMBER                                := 0;

      CURSOR c_credit_points (
         cp_unit_cd          igs_av_lgcy_unt_int.unit_cd%TYPE,
         cp_version_number   igs_av_lgcy_unt_int.version_number%TYPE
      )
      IS
         SELECT NVL (achievable_credit_points,
                     enrolled_credit_points
                    ) credit_points
           FROM igs_ps_unit_ver
          WHERE unit_cd = cp_unit_cd AND version_number = cp_version_number;

      l_count           NUMBER                                := 0;
      l_start_dt        igs_ad_term_details.start_date%TYPE;
      l_end_dt          igs_ad_term_details.end_date%TYPE;
      l_return_status   VARCHAR2 (1000);
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.DERIVE_UNIT_DATA');
      p_s_adv_stnd_type := 'UNIT'; -- initialise
      p_person_id := igs_ge_gen_003.get_person_id (p_person_number);
      write_message ('Got person ID as ' || p_person_id);

      IF p_person_id IS NULL
      THEN
         fnd_message.set_name ('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
         fnd_msg_pub.ADD;
         RETURN FALSE;
      END IF;

      IF p_load_cal_alt_code IS NULL
      THEN
         fnd_message.set_name ('IGS', 'IGS_AV_INVALID_CAL_ALT_CODE');
         fnd_msg_pub.ADD;
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS',
                                               'IGS_AV_INVALID_CAL_ALT_CODE'
                                              )
                      );
         RETURN FALSE;
      END IF;

      write_message (   'Calling  IGS_GE_GEN_003.get_calendar_instance '
                     || p_cal_type
                     || p_load_cal_alt_code
                    );
      igs_ge_gen_003.get_calendar_instance (p_alternate_cd            => p_load_cal_alt_code,
                                            p_s_cal_category          => '''LOAD''',
                                            p_cal_type                => p_cal_type,
                                            p_ci_sequence_number      => p_seq_number,
                                            p_start_dt                => l_start_dt,
                                            p_end_dt                  => l_end_dt,
                                            p_return_status           => l_return_status
                                           );
      write_message (   'Got p_cal_type as '
                     || p_cal_type
                     || ' and p_seq_number as'
                     || p_seq_number
                    );

      -- IF 0 or more load calendars are found
      IF p_seq_number IS NULL OR p_cal_type IS NULL
      THEN
         fnd_message.set_name ('IGS', 'IGS_AV_INVALID_CAL_ALT_CODE');
         fnd_msg_pub.ADD;
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS',
                                               'IGS_AV_INVALID_CAL_ALT_CODE'
                                              )
                      );
         RETURN FALSE;
      END IF;

      write_message ('Got p_auth_pers_id as ' || p_auth_pers_id);
      -- Get the program version number
      p_as_version_number :=
         igs_ge_gen_003.get_program_version (p_person_id       => p_person_id,
                                             p_program_cd      => p_program_cd
                                            );
      write_message ('Got p_as_version_number as ' || p_as_version_number);

      -- Default p_achievable_credit_points
      IF p_achievable_credit_points IS NULL
      THEN
         OPEN c_credit_points (p_unit_cd, p_version_number);
         FETCH c_credit_points INTO p_achievable_credit_points;
         CLOSE c_credit_points;
      END IF;

      write_message (   'Got p_achievable_credit_points as '
                     || p_achievable_credit_points
                    );
      ecx_debug.pop ('IGS_DA_TRNS_IMP.DERIVE_UNIT_DATA');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
             notify_error (p_batch_id,
                           p_person_id,
                           p_program_cd,
                           'Error has occurred.See log for Details'
                           );

            write_message('ERROR ' || sqlerrm);

   END derive_unit_data;

   FUNCTION validate_adv_std_db_cons (
      p_batch_id                   IN   igs_da_rqst.batch_id%TYPE,
      p_person_id                  IN   igs_pe_person.person_id%TYPE,
      p_person_number              IN   igs_av_lgcy_unt_int.person_number%TYPE,
      p_program_cd                 IN   igs_av_lgcy_unt_int.program_cd%TYPE,
      p_unit_cd                    IN   igs_av_lgcy_unt_int.unit_cd%TYPE, --- advstnd unit
      p_version_number             IN   igs_av_lgcy_unt_int.version_number%TYPE,
      p_load_cal_alt_code          IN   igs_av_lgcy_unt_int.load_cal_alt_code%TYPE,
      p_achievable_credit_points   IN   igs_av_lgcy_unt_int.achievable_credit_points%TYPE
   )
      RETURN BOOLEAN
   IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_adv_std_db_cons                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-08-2005  Created                                          |
 +===========================================================================*/
      x_return_status   BOOLEAN := TRUE;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.VALIDATE_ADV_STD_DB_CONS');
      x_return_status := TRUE;
      write_message ('Before igs_ps_ver_pkg.get_pk_for_validation ');

      IF NOT igs_ps_ver_pkg.get_pk_for_validation (x_course_cd           => p_program_cd,
                                                   x_version_number      => p_version_number
                                                  )
      THEN
         fnd_message.set_name ('IGS', 'IGS_AV_PRG_CD_NOT_EXISTS');
         fnd_msg_pub.ADD;
         x_return_status := FALSE;
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS',
                                               'IGS_AV_PRG_CD_NOT_EXISTS'
                                              )
                      );
      END IF;

      write_message ('Inside validate_adv_std_db_cons Got x_return_status as ');
      ecx_debug.pop ('IGS_DA_TRNS_IMP.VALIDATE_ADV_STD_DB_CONS');
      RETURN x_return_status;
   EXCEPTION
      WHEN OTHERS
      THEN
             notify_error (p_batch_id,
                           p_person_id,
                           p_program_cd,
                           'Error has occurred.See log for Details.'
                           );

	    write_message('ERROR ' || sqlerrm);

   END validate_adv_std_db_cons;

   FUNCTION validate_adv_stnd (
      p_batch_id                IN   igs_da_rqst.batch_id%TYPE,
      p_person_id               IN   igs_pe_person.person_id%TYPE,
      p_person_number           IN   igs_av_lgcy_unt_int.person_number%TYPE,
      p_program_cd              IN   igs_av_lgcy_unt_int.program_cd%TYPE,
      p_unit_cd                 IN   igs_av_lgcy_unt_int.unit_cd%TYPE, --- advstnd unit
      p_version_number          IN   igs_av_lgcy_unt_int.version_number%TYPE,
      p_prev_institution_code   IN   igs_ad_acad_history_v.institution_code%TYPE
   )
      RETURN BOOLEAN
   IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_adv_stnd                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-08-2005  Created                                          |
 |    swaghmar	09-11-2005  Bug# 4706134 - Modified the query for	     |
 |			    cursor c_validate_inst			     |
 +===========================================================================*/
      x_return_status   BOOLEAN;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.VALIDATE_ADV_STND');
      x_return_status := TRUE;

      /*
         check whether person is deceased or not
      */
      DECLARE
         CURSOR c_ind (cp_party_id igs_pe_hz_parties.party_id%TYPE)
         IS
            SELECT deceased_ind
              FROM igs_pe_hz_parties
             WHERE party_id = cp_party_id;

         l_ind   igs_pe_hz_parties.deceased_ind%TYPE;
      BEGIN
         OPEN c_ind (p_person_id);
         FETCH c_ind INTO l_ind;
         CLOSE c_ind;

         IF UPPER (l_ind) = 'Y'
         THEN
            fnd_message.set_name ('IGS', 'IGS_AV_PERSON_DECEASED');
            fnd_msg_pub.ADD;
            x_return_status := FALSE;
            notify_error (p_batch_id,
                          p_person_id,
                          p_program_cd,
                          fnd_message.get_string ('IGS',
                                                  'IGS_AV_PERSON_DECEASED'
                                                 )
                         );
         END IF;

         write_message ('l_ind :' || l_ind);
      END;

      /*
         check whether exemtion_inst_cd is valid or not
      */
      DECLARE
         CURSOR c_validate_inst (
            cp_exemption_institution_cd   igs_ad_acad_history_v.institution_code%TYPE
         )
         IS
            SELECT hp.party_number tca_party_number,
		   ihp.oss_org_unit_cd exemption_institution_cd, hp.party_name,
		   ihp.oi_institution_status, 'INSTITUTION CODE' SOURCE, hp.created_by,
		   hp.creation_date, hp.last_updated_by, hp.last_update_date,
		   hp.last_update_login
	      FROM hz_parties hp, igs_pe_hz_parties ihp
	     WHERE hp.party_id = ihp.party_id
	       AND ihp.inst_org_ind = 'I'
               AND ihp.oi_institution_status = 'ACTIVE'
	       AND ihp.oss_org_unit_cd = cp_exemption_institution_cd;

         l_validate_inst   c_validate_inst%ROWTYPE;
      BEGIN
         OPEN c_validate_inst (p_prev_institution_code);
         FETCH c_validate_inst INTO l_validate_inst;

         IF c_validate_inst%NOTFOUND
         THEN
            fnd_message.set_name ('IGS', 'IGS_AV_STND_EXMPT_INVALID');
            fnd_msg_pub.ADD;
            x_return_status := FALSE;
            notify_error (p_batch_id,
                          p_person_id,
                          p_program_cd,
                          fnd_message.get_string ('IGS',
                                                  'IGS_AV_STND_EXMPT_INVALID'
                                                 )
                         );
         END IF;

         CLOSE c_validate_inst;
         write_message ('Verified exemption_inst_cd');
      END;

      /*
         check whether program_cd is valid or not
      */
      DECLARE
         l_message_name   VARCHAR2 (2000);
      BEGIN
         IF NOT igs_av_val_as.advp_val_as_crs (p_person_id           => p_person_id,
                                               p_course_cd           => p_program_cd,
                                               p_version_number      => p_version_number,
                                               p_message_name        => l_message_name
                                              )
         THEN
            fnd_message.set_name ('IGS', 'IGS_HE_EXT_SPA_DTL_NOT_FOUND');
            fnd_msg_pub.ADD;
            x_return_status := FALSE;
            notify_error (p_batch_id,
                          p_person_id,
                          p_program_cd,
                          fnd_message.get_string ('IGS',
                                                  'IGS_HE_EXT_SPA_DTL_NOT_FOUND'
                                                 )
                         );
         END IF;
      END;

      /*
         validation for exemption credit points
      */
      DECLARE
         CURSOR c_local_inst_ind (
            cp_ins_cd   igs_or_institution.institution_cd%TYPE
         )
         IS
            SELECT ins.local_institution_ind
              FROM igs_or_institution ins
             WHERE ins.institution_cd = cp_ins_cd;

         CURSOR cur_program_exempt_totals (
            cp_course_cd        igs_ps_ver.course_cd%TYPE,
            cp_version_number   igs_ps_ver.version_number%TYPE,
            cp_local_ind        VARCHAR2
         )
         IS
            SELECT DECODE (cp_local_ind,
                           'N', NVL (cv.external_adv_stnd_limit, -1),
                           NVL (cv.internal_adv_stnd_limit, -1)
                          ) adv_stnd_limit
              FROM igs_ps_ver cv
             WHERE cv.course_cd = cp_course_cd
               AND cv.version_number = cp_version_number;

         rec_cur_program_exempt_totals   cur_program_exempt_totals%ROWTYPE;
         rec_local_inst_ind              c_local_inst_ind%ROWTYPE;
         l_message_name                  fnd_new_messages.message_name%TYPE;
      BEGIN
         OPEN c_local_inst_ind (p_prev_institution_code);
         FETCH c_local_inst_ind INTO rec_local_inst_ind;

         IF (c_local_inst_ind%NOTFOUND)
         THEN
            rec_local_inst_ind.local_institution_ind := 'N';
         END IF;

         CLOSE c_local_inst_ind;

         IF (rec_local_inst_ind.local_institution_ind = 'N')
         THEN
            l_message_name := 'IGS_AV_EXCEEDS_PRGVER_EXT_LMT';
         ELSE
            l_message_name := 'IGS_AV_EXCEEDS_PRGVER_INT_LMT';
         END IF;
      END;

      /*
         check the course_attempt_status
      */
      DECLARE
         CURSOR c_exists (
            cp_person_id   igs_en_stdnt_ps_att.person_id%TYPE,
            cp_course_cd   igs_en_stdnt_ps_att.course_cd%TYPE
         )
         IS
            SELECT 'x'
              FROM igs_en_stdnt_ps_att
             WHERE person_id = cp_person_id
               AND course_cd = cp_course_cd
               AND course_attempt_status IN
                      ('ENROLLED',
                       'INACTIVE',
                       'INTERMIT',
                       'UNCONFIRM',
                       'DISCONTIN',
                       'COMPLETED'
                      );

         l_exists   VARCHAR2 (1);
      BEGIN
         OPEN c_exists (p_person_id, p_program_cd);
         FETCH c_exists INTO l_exists;

         IF c_exists%NOTFOUND
         THEN
            fnd_message.set_name ('IGS', 'IGS_AV_PRG_ATTMPT_INVALID');
            fnd_msg_pub.ADD;
            x_return_status := FALSE;
            notify_error (p_batch_id,
                          p_person_id,
                          p_program_cd,
                          fnd_message.get_string ('IGS',
                                                  'IGS_AV_PRG_ATTMPT_INVALID'
                                                 )
                         );
         END IF;

         CLOSE c_exists;
      END;

      ecx_debug.pop ('IGS_DA_TRNS_IMP.VALIDATE_ADV_STND');
      RETURN x_return_status;
   EXCEPTION
      WHEN OTHERS
      THEN
             notify_error (p_batch_id,
                           p_person_id,
                           p_program_cd,
                           'Error has occurred.See log for Details.'
                           );

             write_message('ERROR ' || sqlerrm);

   END validate_adv_stnd;

   FUNCTION validate_std_unt_db_cons (
      p_batch_id                IN   igs_da_rqst.batch_id%TYPE,
      p_person_number           IN   igs_av_lgcy_unt_int.person_number%TYPE,
      p_program_cd              IN   igs_av_lgcy_unt_int.program_cd%TYPE,
      p_unit_cd                 IN   igs_av_lgcy_unt_int.unit_cd%TYPE, --- advstnd unit
      p_version_number          IN   igs_av_lgcy_unt_int.version_number%TYPE,
      p_institution_cd          IN   igs_av_lgcy_unt_int.institution_cd%TYPE,
      p_person_id               IN   igs_pe_person.person_id%TYPE,
      p_auth_pers_id            IN   igs_pe_person.person_id%TYPE,
      p_unit_details_id         IN   igs_ad_term_unitdtls.unit_details_id%TYPE,
      p_as_version_number       IN   igs_en_stdnt_ps_att.version_number%TYPE,
      p_prev_institution_code   IN   igs_ad_acad_history_v.institution_code%TYPE
   )
      RETURN BOOLEAN
   IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_std_unt_db_cons                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                 This function performs all the data integrity validation  |
 |                before entering into the table  IGS_AV_STND_UNIT_ ALL and  |
 |                keeps adding error message to stack as an when it encounters.|                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-08-2005  Created                                          |
 +===========================================================================*/
      x_return_status   BOOLEAN       := TRUE;
      l_c_tmp_msg       VARCHAR2 (30);
   BEGIN
--    Foreign Key with Table IGS_AV_ADV_STANDING_PKG
      ecx_debug.push ('IGS_DA_TRNS_IMP.VALIDATE_STD_UNT_DB_CONS');
      write_message (   'p_person_id='
                     || p_person_id
                     || ' p_program_cd='
                     || p_program_cd
                     || ' p_as_version_number='
                     || p_as_version_number
                     || ' p_prev_institution_code='
                     || p_prev_institution_code
                    );

      IF NOT igs_av_adv_standing_pkg.get_pk_for_validation (x_person_id                     => p_person_id,
                                                            x_course_cd                     => p_program_cd,
                                                            x_version_number                => p_as_version_number,
                                                            x_exemption_institution_cd      => p_prev_institution_code
                                                           )
      THEN
         fnd_message.set_name ('IGS', 'IGS_AV_NO_ADV_STND_DET_EXIST');
         fnd_msg_pub.ADD;
         x_return_status := FALSE;
         write_message ('validate_std_unt_db_cons IGS_AV_ADV_STANDING_PKG.GET_PK_FOR_VALIDATION '
                       );
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS',
                                               'IGS_AV_NO_ADV_STND_DET_EXIST'
                                              )
                      );
      END IF;

      write_message ('p_auth_pers_id=' || p_auth_pers_id);

      --    Foreign Key with AUTHORIZING_PERSON_ID exists in table IGS_PE_PERSON
      IF p_auth_pers_id IS NULL
      THEN
         fnd_message.set_name ('IGS', 'IGS_AV_INVALID_PERS_AUTH_NUM');
         fnd_msg_pub.ADD;
         x_return_status := FALSE;
         write_message ('validate_std_unt_db_cons p_auth_pers_id ');
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS',
                                               'IGS_AV_INVALID_PERS_AUTH_NUM'
                                              )
                      );
      END IF;

      write_message (   'igs_ps_unit_ver_pkg.get_pk_for_validation'
                     || p_unit_cd
                     || ' '
                     || p_version_number
                    );

      --   Foreign Key with Table IGS_PS_UNIT_VER
      IF NOT igs_ps_unit_ver_pkg.get_pk_for_validation (x_unit_cd             => p_unit_cd,
                                                        x_version_number      => p_version_number
                                                       )
      THEN
         fnd_message.set_name ('IGS', 'IGS_AV_ADV_STUNT_UNIT_EXISTS');
         fnd_msg_pub.ADD;
         x_return_status := FALSE;
         write_message ('validate_std_unt_db_cons IGS_PS_UNIT_VER_PKG.GET_PK_FOR_VALIDATION '
                       );
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS',
                                               'IGS_AV_ADV_STUNT_UNIT_EXISTS'
                                              )
                      );
      END IF;

      --    Check that if institution_cd is NOT NULL and unit_details_id is NULL
      IF p_institution_cd IS NOT NULL AND p_unit_details_id IS NULL
      THEN
         fnd_message.set_name ('IGS', 'IGS_AV_STUT_INST_UID_NOT_NULL');
         fnd_msg_pub.ADD;
         x_return_status := FALSE;
         write_message ('validate_std_unt_db_cons p_prev_institution_code ');
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS',
                                               'IGS_AV_STUT_INST_UID_NOT_NULL'
                                              )
                      );
      END IF;

      ecx_debug.pop ('IGS_DA_TRNS_IMP.VALIDATE_STD_UNT_DB_CONS');
      RETURN x_return_status;
   EXCEPTION
      WHEN OTHERS
      THEN
             notify_error (p_batch_id,
                           p_person_id,
                           p_program_cd,
                           'Error has occurred.See log for Details.'
                           );

	    write_message('ERROR ' || sqlerrm);

   END validate_std_unt_db_cons;

   FUNCTION validate_unit (
      p_program_cd                 IN   igs_av_lgcy_unt_int.program_cd%TYPE,
      p_unit_cd                    IN   igs_av_lgcy_unt_int.unit_cd%TYPE, --- advstnd unit
      p_version_number             IN   igs_av_lgcy_unt_int.version_number%TYPE,
      p_achievable_credit_points   IN   igs_av_lgcy_unt_int.achievable_credit_points%TYPE,
      p_person_id                  IN   igs_pe_person.person_id%TYPE,
      p_auth_pers_id               IN   igs_pe_person.person_id%TYPE,
      p_unit_details_id            IN   igs_ad_term_unitdtls.unit_details_id%TYPE,
      p_as_version_number          IN   igs_en_stdnt_ps_att.version_number%TYPE,
      p_batch_id                   IN   igs_da_rqst.batch_id%TYPE,
      p_prev_institution_code      IN   igs_ad_acad_history_v.institution_code%TYPE
   )
      RETURN BOOLEAN
   IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_unit                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This function performs all the business validations before   |
 |                inserting a record into the table  IGS_AV_STND_UNIT_ALL and|
 |                keeps adding error message to stack as an when it encounters.|
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-08-2005  Created                                          |
 +===========================================================================*/
      x_return_status             BOOLEAN                             := TRUE;
      l_total_exmptn_approved     igs_av_adv_standing_all.total_exmptn_approved%TYPE;
      l_total_exmptn_granted      igs_av_adv_standing_all.total_exmptn_granted%TYPE;
      l_total_exmptn_perc_grntd   igs_av_adv_standing_all.total_exmptn_perc_grntd%TYPE;
      l_message_name              VARCHAR2 (30);
      l_grant_status              igs_av_stnd_unit_all.s_adv_stnd_granting_status%TYPE;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.VALIDATE_UNIT');

      IF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL')
      THEN
         l_grant_status := 'GRANTED';
      ELSE
         l_grant_status := get_adv_stnd_granting_status (p_batch_id);
      END IF;

      IF NOT igs_av_val_asu.advp_val_as_totals (p_person_id                         => p_person_id,
                                                p_course_cd                         => p_program_cd,
                                                p_version_number                    => p_as_version_number,
                                                p_include_approved                  => TRUE,
                                                p_asu_unit_cd                       => p_unit_cd,
                                                p_asu_version_number                => p_version_number,
                                                p_asu_advstnd_granting_status       => l_grant_status,
                                                p_asul_unit_level                   => NULL,
                                                p_asul_exmptn_institution_cd        => p_prev_institution_code,
                                                p_asul_advstnd_granting_status      => l_grant_status,
                                                p_total_exmptn_approved             => l_total_exmptn_approved,
                                                p_total_exmptn_granted              => l_total_exmptn_granted,
                                                p_total_exmptn_perc_grntd           => l_total_exmptn_perc_grntd,
                                                p_message_name                      => l_message_name,
                                                p_unit_details_id                   => p_unit_details_id,
                                                p_tst_rslt_dtls_id                  => NULL
                                               )
      THEN
         fnd_message.set_name ('IGS', l_message_name);
         fnd_msg_pub.ADD;
         x_return_status := FALSE;
         write_message ('validate_unit IGS_AV_VAL_ASU.ADVP_VAL_AS_TOTALS ');
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS', l_message_name)
                      );
      END IF;

--    Check for person hold
      IF NOT igs_en_val_encmb.enrp_val_excld_prsn (p_person_id         => p_person_id,
                                                   p_course_cd         => p_program_cd,
                                                   p_effective_dt      => SYSDATE,
                                                   p_message_name      => l_message_name
                                                  )
      THEN
         fnd_message.set_name ('IGS', l_message_name);
         fnd_msg_pub.ADD;
         x_return_status := FALSE;
         write_message ('validate_unit IGS_EN_VAL_ENCMB.ENRP_VAL_EXCLD_PRSN ');
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS', l_message_name)
                      );
      END IF;

      write_message (   'igs_ad_val_acai.genp_val_staff_prsn  p_auth_pers_id='
                     || p_auth_pers_id
                    );

      IF NOT igs_ad_val_acai.genp_val_staff_prsn (p_person_id         => p_auth_pers_id,
                                                  p_message_name      => l_message_name
                                                 )
      THEN
         fnd_message.set_name ('IGS', 'IGS_GE_NOT_STAFF_MEMBER');
         fnd_msg_pub.ADD;
         --todo change this to false if staff validation required
         --x_return_status := false;
         write_message ('validate_unit IGS_GE_NOT_STAFF_MEMBER ');
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS',
                                               'IGS_GE_NOT_STAFF_MEMBER'
                                              )
                      );
      END IF;

      IF p_achievable_credit_points IS NULL
      THEN
         fnd_message.set_name ('IGS', 'IGS_AV_CRD_PER_CANNOT_BE_NULL');
         fnd_msg_pub.ADD;
         x_return_status := FALSE;
         write_message ('validate_unit IGS_AV_CRD_PER_CANNOT_BE_NULL  ');
         write_message ('validate_unit IGS_EN_VAL_ENCMB.ENRP_VAL_EXCLD_PRSN ');
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS',
                                               'IGS_AV_CRD_PER_CANNOT_BE_NULL'
                                              )
                      );
      END IF;

      /*
         check the course_attempt_status
      */
      DECLARE
         CURSOR c_exists (
            cp_person_id   igs_en_stdnt_ps_att.person_id%TYPE,
            cp_course_cd   igs_en_stdnt_ps_att.course_cd%TYPE
         )
         IS
            SELECT 'x'
              FROM igs_en_stdnt_ps_att
             WHERE person_id = cp_person_id
               AND course_cd = cp_course_cd
               AND course_attempt_status IN
                      ('ENROLLED',
                       'INACTIVE',
                       'INTERMIT',
                       'UNCONFIRM',
                       'DISCONTIN',
                       'COMPLETED'
                      );

         l_exists   VARCHAR2 (1);
      BEGIN
         OPEN c_exists (p_person_id, p_program_cd);
         FETCH c_exists INTO l_exists;

         IF c_exists%NOTFOUND
         THEN
            fnd_message.set_name ('IGS', 'IGS_AV_PRG_ATTMPT_INVALID');
            fnd_msg_pub.ADD;
            write_message ('validate_unit IGS_AV_PRG_ATTMPT_INVALID  ');
            x_return_status := FALSE;
            notify_error (p_batch_id,
                          p_person_id,
                          p_program_cd,
                          fnd_message.get_string ('IGS',
                                                  'IGS_AV_PRG_ATTMPT_INVALID'
                                                 )
                         );
         END IF;

         CLOSE c_exists;
      END;

      ecx_debug.pop ('IGS_DA_TRNS_IMP.VALIDATE_UNIT');
      RETURN x_return_status;
   EXCEPTION
      WHEN OTHERS
      THEN
             notify_error (p_batch_id,
                           p_person_id,
                           p_program_cd,
                           'Error has occurred.See log for Details'
                           );

            write_message('ERROR ' || sqlerrm);

   END validate_unit;

   FUNCTION create_post_unit (
      p_person_id               IN   igs_pe_person.person_id%TYPE,
      p_course_version          IN   igs_ps_ver.version_number%TYPE,
      p_unit_details_id         IN   igs_ad_term_unitdtls.unit_details_id%TYPE,
      p_program_cd              IN   igs_av_lgcy_unt_int.program_cd%TYPE,
      p_unit_cd                 IN   igs_av_lgcy_unt_int.unit_cd%TYPE, --- advstnd unit
      p_version_number          IN   igs_av_lgcy_unt_int.version_number%TYPE,
      p_batch_id                     igs_da_rqst.batch_id%TYPE,
      p_prev_institution_code   IN   igs_ad_acad_history_v.institution_code%TYPE
   )
      RETURN BOOLEAN
   IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              create_post_unit                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-08-2005  Created                                          |
 +===========================================================================*/
      CURSOR c_adv_stnd
      IS
         SELECT ROWID
           FROM igs_av_adv_standing_all
          WHERE person_id = p_person_id
            AND course_cd = p_program_cd
            AND version_number = p_course_version
            AND exemption_institution_cd = p_prev_institution_code;

      x_return_status             BOOLEAN                              := TRUE;
      l_message                   VARCHAR2 (2000);
      l_total_exmptn_approved     igs_av_adv_standing_all.total_exmptn_approved%TYPE;
      l_total_exmptn_granted      igs_av_adv_standing_all.total_exmptn_granted%TYPE;
      l_total_exmptn_perc_grntd   igs_av_adv_standing_all.total_exmptn_perc_grntd%TYPE;
      l_adv_stnd                  c_adv_stnd%ROWTYPE;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.CREATE_POST_UNIT');
      x_return_status := TRUE;
      write_message ('In create_post_unit');

      /*
      Validate whether the advanced standing approved / granted has not
      exceeded the advanced standing internal or external limits of
      the Program version
      */
      IF NOT igs_av_val_asu.advp_val_as_totals (p_person_id                         => p_person_id,
                                                p_course_cd                         => p_program_cd,
                                                p_version_number                    => p_course_version,
                                                p_include_approved                  => TRUE,
                                                p_asu_unit_cd                       => p_unit_cd,
                                                p_asu_version_number                => p_version_number,
                                                p_asu_advstnd_granting_status       => get_adv_stnd_granting_status (p_batch_id
                                                                                                                    ),
                                                p_asul_unit_level                   => NULL,
                                                p_asul_exmptn_institution_cd        => p_prev_institution_code,
                                                p_asul_advstnd_granting_status      => get_adv_stnd_granting_status (p_batch_id
                                                                                                                    ),
                                                p_total_exmptn_approved             => l_total_exmptn_approved,
                                                p_total_exmptn_granted              => l_total_exmptn_granted,
                                                p_total_exmptn_perc_grntd           => l_total_exmptn_perc_grntd,
                                                p_message_name                      => l_message,
                                                p_unit_details_id                   => p_unit_details_id,
                                                p_tst_rslt_dtls_id                  => NULL,
                                                p_asu_exmptn_institution_cd         => p_prev_institution_code
                                               )
      THEN
         fnd_message.set_name ('IGS', l_message);
         fnd_msg_pub.ADD;
         x_return_status := FALSE;
         notify_error (p_batch_id,
                       p_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS', l_message)
                      );
      ELSE -- function returns TRUE
         /*
          update IGS_AV_ADV_STANDING_ALL  with above obtained values for
          total_exmptn_approved, total_exmptn_granted   and total_exmptn_perc_grntd
         */
         OPEN c_adv_stnd;
         FETCH c_adv_stnd INTO l_adv_stnd;
         igs_av_adv_standing_pkg.update_row (x_rowid                         => l_adv_stnd.ROWID,
                                             x_person_id                     => p_person_id,
                                             x_course_cd                     => p_program_cd,
                                             x_version_number                => p_course_version,
                                             x_total_exmptn_approved         => l_total_exmptn_approved,
                                             x_total_exmptn_granted          => l_total_exmptn_granted,
                                             x_total_exmptn_perc_grntd       => l_total_exmptn_perc_grntd,
                                             x_exemption_institution_cd      => p_prev_institution_code,
                                             x_mode                          => 'R'
                                            );
         CLOSE c_adv_stnd;
      END IF;

      write_message ('Out create_post_unit');
      ecx_debug.pop ('IGS_DA_TRNS_IMP.CREATE_POST_UNIT');
      RETURN x_return_status;
   EXCEPTION
      WHEN OTHERS
      THEN
             notify_error (p_batch_id,
                           p_person_id,
                           p_program_cd,
                           'Error has occurred.See log for Details'
                           );
             write_message('ERROR ' || sqlerrm);

   END create_post_unit;

   PROCEDURE create_adv_stnd_unit (
      p_batch_id                   IN   igs_da_rqst.batch_id%TYPE,
      p_unit_details_id            IN   igs_ad_term_unitdtls.unit_details_id%TYPE,
      p_person_id_code             IN   igs_pe_alt_pers_id.api_person_id%TYPE,
      p_person_id_code_type        IN   igs_pe_alt_pers_id.person_id_type%TYPE,
      p_program_cd                 IN   igs_av_lgcy_unt_int.program_cd%TYPE,
      p_load_cal_alt_code          IN   igs_av_lgcy_unt_int.load_cal_alt_code%TYPE,
      p_avstnd_grade               IN   igs_av_lgcy_unt_int.grade%TYPE,
      p_achievable_credit_points   IN   igs_av_lgcy_unt_int.achievable_credit_points%TYPE,
      p_target_course_subject      IN   VARCHAR2,
      p_target_course_num          IN   VARCHAR2,
      p_inst_id_code               IN   igs_pe_alt_pers_id.api_person_id%TYPE,
      p_inst_id_code_type          IN   igs_pe_alt_pers_id.api_person_id%TYPE
   )
   IS
/*===========================================================================+
 | PROCEDURE                                                                 |
 |              create_adv_stnd_unit                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Creates advanced standing unit                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-08-2005  Created                                          |
 +===========================================================================*/
      l_api_name             CONSTANT VARCHAR2 (30) := 'create_adv_stnd_unit';
      l_api_version          CONSTANT NUMBER                           := 1.0;
      l_ret_status                    BOOLEAN;
      l_b_av_stnd_alt_unit_pk_exist   BOOLEAN                         := TRUE;
      l_person_id                     igs_pe_person.person_id%TYPE;
      l_s_adv_stnd_type               igs_av_stnd_unit_all.s_adv_stnd_type%TYPE;
      l_cal_type                      igs_ca_inst.cal_type%TYPE;
      l_seq_number                    igs_ca_inst.sequence_number%TYPE;
      l_auth_pers_id                  igs_pe_person.person_id%TYPE;
      l_as_version_number             igs_en_stdnt_ps_att.version_number%TYPE;
      l_av_stnd_unit_lvl_id           igs_av_stnd_unit_all.av_stnd_unit_id%TYPE;
      l_request_id                    igs_av_stnd_unit_all.request_id%TYPE;
      l_program_id                    igs_av_stnd_unit_all.program_id%TYPE;
      l_program_application_id        igs_av_stnd_unit_all.program_application_id%TYPE;
      l_program_update_date           igs_av_stnd_unit_all.program_update_date%TYPE;
      duplicate_record_exists         EXCEPTION;
      l_granted_dt                    igs_av_stnd_unit_all.granted_dt%TYPE
                                                                      := NULL;
      l_unit_cd                       igs_av_lgcy_unt_int.unit_cd%TYPE; --- advstnd unit
      l_version_number                igs_av_lgcy_unt_int.version_number%TYPE;
      l_person_number                 igs_av_lgcy_unt_int.person_number%TYPE;
      l_return_status                 VARCHAR2 (30);
      l_msg_count                     NUMBER;
      l_msg_data                      VARCHAR2 (200);
      l_prev_institution_code         igs_ad_acad_history_v.institution_code%TYPE;
      l_achievable_credit_points      igs_av_lgcy_unt_int.achievable_credit_points%TYPE;
      l_institution_cd                igs_av_lgcy_unt_int.institution_cd%TYPE;
      l_dmmy_rowid                    ROWID;

      CURSOR c_unit_ver
      IS
         SELECT version_number
           FROM igs_ps_unit_ver_all OUTER
          WHERE unit_cd = l_unit_cd
            AND unit_status = 'ACTIVE'
            AND version_number =
                   (SELECT MAX (version_number)
                      FROM igs_ps_unit_ver_all inn
                     WHERE OUTER.unit_cd = inn.unit_cd
                       AND inn.unit_status = 'ACTIVE');

      CURSOR c_present_inst
      IS
         SELECT adv_stnd_basis_inst
           FROM igs_av_stnd_conf;

      CURSOR c_requestor
      IS
         SELECT dr.requestor_id
           FROM igs_da_rqst dr, fnd_user fdu
          WHERE dr.batch_id = p_batch_id
            AND dr.requestor_id = fdu.person_party_id;

      CURSOR c_adv_stnd_unt (
         cp_person_id                  NUMBER,
         cp_exemption_institution_cd   VARCHAR2,
         cp_unit_details_id            NUMBER,
         cp_unit_cd                    VARCHAR2,
         cp_as_course_cd               VARCHAR2,
         cp_as_version_number          NUMBER,
         cp_version_number             NUMBER,
         cp_s_adv_stnd_type            VARCHAR2
      )
      IS
         SELECT     unt.ROWID, unt.*
               FROM igs_av_stnd_unit_all unt
              WHERE person_id = cp_person_id
                AND exemption_institution_cd = cp_exemption_institution_cd
                AND unit_details_id = cp_unit_details_id
                AND unit_cd = cp_unit_cd
                AND as_course_cd = cp_as_course_cd
                AND as_version_number = cp_as_version_number
                AND version_number = cp_version_number
                AND s_adv_stnd_type = cp_s_adv_stnd_type
         FOR UPDATE NOWAIT;


      CURSOR c_requestor_id
      IS
         SELECT hz_parties.party_id
           FROM hz_parties, fnd_user
          WHERE fnd_user.customer_id = hz_parties.party_id
            AND fnd_user.user_id = fnd_profile.VALUE ('IGS_DA_WF_ADMIN');



      l_adv_stnd_unt                  c_adv_stnd_unt%ROWTYPE;
      l_grant_status                  igs_av_stnd_unit_all.s_adv_stnd_granting_status%TYPE;
      v_dummy                         hz_parties.party_id%TYPE;
      v_rowid                         ROWID;
   BEGIN
      write_message ('      p_batch_id                   => ' || p_batch_id);
      write_message (   '      p_unit_details_id            => '
                     || p_unit_details_id
                    );
      write_message (   '      p_person_id_code             => '
                     || p_person_id_code
                    );
      write_message (   '      p_person_id_code_type        => '
                     || p_person_id_code_type
                    );
      write_message ('      p_program_cd                 => ' || p_program_cd);
      write_message (   '      p_load_cal_alt_code          => '
                     || p_load_cal_alt_code
                    );
      write_message ('      p_avstnd_grade               => '
                     || p_avstnd_grade
                    );
      write_message (   '      p_achievable_credit_points   => '
                     || p_achievable_credit_points
                    );
      write_message (   '      p_target_course_subject      => '
                     || p_target_course_subject
                    );
      write_message (   '      p_target_course_num          => '
                     || p_target_course_num
                    );
      write_message ('      p_inst_id_code               => '
                     || p_inst_id_code
                    );
      write_message (   '      p_inst_id_code_type          => '
                     || p_inst_id_code_type
                    );
      ecx_debug.push ('IGS_DA_TRNS_IMP.CREATE_ADV_STND_UNIT');
      OPEN c_present_inst;
      FETCH c_present_inst INTO l_institution_cd;
      CLOSE c_present_inst;

      IF l_institution_cd IS NULL
      THEN
         write_message ('ERROR The institution setup is not done in Advanced standing configuration form'
                       );
         notify_error (p_batch_id,
                       l_person_id,
                       p_program_cd,
                       fnd_message.get_string ('IGS', 'IGS_DA_INST_NOT_EXIST')
                      );
         RETURN;
      END IF;

      l_achievable_credit_points := p_achievable_credit_points;
--  get the person ID
      igs_da_xml_pkg.get_person_details (p_person_id_code,
                                         p_person_id_code_type,
                                         l_person_id,
                                         l_person_number
                                        );
      -- get institution code
      igs_da_xml_pkg.get_person_details (RTRIM (LTRIM (p_inst_id_code)),
                                         RTRIM (LTRIM (p_inst_id_code_type)),
                                         v_dummy,
                                         l_prev_institution_code
                                        );

      IF l_prev_institution_code IS NULL
      THEN
         write_message ('ERROR The institution ID must match either the OSS ID or an alternate institution ID as defined in the degree audit configuration.'
                       );
         RETURN;
      END IF;

      l_unit_cd := p_target_course_subject || p_target_course_num;
      OPEN c_unit_ver;
      FETCH c_unit_ver INTO l_version_number;
      CLOSE c_unit_ver;
      l_grant_status := get_adv_stnd_granting_status (p_batch_id);

      IF (l_grant_status = 'GRANTED')
      THEN
         l_granted_dt := TRUNC (SYSDATE);
      END IF;

      OPEN c_requestor;
      FETCH c_requestor INTO l_auth_pers_id;
      CLOSE c_requestor;


      IF l_auth_pers_id IS NULL
      THEN

        OPEN c_requestor_id;
        FETCH c_requestor_id INTO l_auth_pers_id;
        CLOSE c_requestor_id;
      END IF;

      IF l_auth_pers_id IS NULL
      THEN
         write_message ('ERROR The authorising person must match either the OSS ID or an alternate student ID as defined in the degree audit configuration.'
                       );
         RETURN;
      END IF;

      IF p_unit_details_id IS NULL
      THEN
         write_message ('ERROR Cannot add advanced standing records without a source unit being specified.'
                       );
         RETURN;
      END IF;

      write_message ('ENTERED create_adv_stnd_unit ');
      --Standard start of API savepoint
      SAVEPOINT create_adv_stnd_unit;
      fnd_msg_pub.initialize;
      --Initialize API return status to success.
      l_return_status := fnd_api.g_ret_sts_success;
      l_unit_cd := UPPER (l_unit_cd);
      l_prev_institution_code := UPPER (l_prev_institution_code);

      IF validate_parameters (p_batch_id            => p_batch_id,
                              p_person_id           => l_person_id,
                              p_person_number       => l_person_number,
                              p_program_cd          => p_program_cd,
                              p_unit_cd             => l_unit_cd,
                              p_version_number      => l_version_number
                             )
      THEN
         write_message ('Before derive_unit_data');

         IF derive_unit_data (p_batch_id                      => p_batch_id,
                              p_person_number                 => l_person_number,
                              p_program_cd                    => p_program_cd,
                              p_unit_cd                       => l_unit_cd,
                              p_version_number                => l_version_number,
                              p_institution_cd                => l_institution_cd,
                              p_load_cal_alt_code             => p_load_cal_alt_code,
                              p_avstnd_grade                  => p_avstnd_grade,
                              p_achievable_credit_points      => l_achievable_credit_points,
                              p_person_id                     => l_person_id,
                              p_s_adv_stnd_type               => l_s_adv_stnd_type,
                              p_cal_type                      => l_cal_type,
                              p_seq_number                    => l_seq_number,
                              p_auth_pers_id                  => l_auth_pers_id,
                              p_as_version_number             => l_as_version_number
                             )
         THEN
            write_message ('*****l_unit_details_id=' || p_unit_details_id);
            write_message ('Before validate_adv_std_db_cons');

            IF validate_adv_std_db_cons (p_batch_id                      => p_batch_id,
                                         p_person_id                     => l_person_id,
                                         p_person_number                 => l_person_number,
                                         p_program_cd                    => p_program_cd,
                                         p_unit_cd                       => l_unit_cd,
                                         p_version_number                => l_version_number,
                                         p_load_cal_alt_code             => p_load_cal_alt_code,
                                         p_achievable_credit_points      => l_achievable_credit_points
                                        )
            THEN
               write_message ('Before validate_adv_stnd');

               IF validate_adv_stnd (p_batch_id                   => p_batch_id,
                                     p_person_id                  => l_person_id,
                                     p_person_number              => l_person_number,
                                     p_program_cd                 => p_program_cd,
                                     p_unit_cd                    => l_unit_cd,
                                     p_version_number             => l_version_number,
                                     p_prev_institution_code      => l_prev_institution_code
                                    )
               THEN
                  write_message ('Before IGS_AV_ADV_STANDING_PKG.GET_PK_FOR_VALIDATION'
                                );

                  --    Validate that  the current record is already present in the tables IGS_AV_ADV_STANDING_ALL and IGS_AV_STND_UNIT_ALL
                  IF NOT igs_av_adv_standing_pkg.get_pk_for_validation (x_person_id                     => l_person_id,
                                                                        x_course_cd                     => p_program_cd,
                                                                        x_version_number                => l_as_version_number,
                                                                        x_exemption_institution_cd      => l_prev_institution_code
                                                                       )
                  THEN
                     write_message ('***** INSERT INTO IGS_AV_ADV_STANDING_ALL *****'
                                   );

                     igs_av_adv_standing_pkg.insert_row (x_rowid                         => v_rowid,
                                                         x_person_id                     => l_person_id,
                                                         x_course_cd                     => UPPER (p_program_cd
                                                                                                  ),
                                                         x_version_number                => l_as_version_number,
                                                         x_total_exmptn_approved         => 0,
                                                         x_total_exmptn_granted          => 0,
                                                         x_total_exmptn_perc_grntd       => 0,
                                                         x_exemption_institution_cd      => l_prev_institution_code,
                                                         x_org_id                        => igs_ge_gen_003.get_org_id ()
                                                        );

                  END IF; --IGS_AV_ADV_STANDING_PKG.GET_PK_FOR_VALIDATION

                  write_message ('Before IGS_AV_STND_UNIT_PKG.GET_UK_FOR_VALIDATION'
                                );

                  IF NOT igs_av_stnd_unit_pkg.get_uk_for_validation (x_person_id                     => l_person_id,
                                                                     x_exemption_institution_cd      => UPPER (l_prev_institution_code
                                                                                                              ),
                                                                     x_unit_details_id               => p_unit_details_id,
                                                                     x_tst_rslt_dtls_id              => NULL,
                                                                     x_unit_cd                       => UPPER (l_unit_cd
                                                                                                              ),
                                                                     x_as_course_cd                  => UPPER (p_program_cd
                                                                                                              ),
                                                                     x_as_version_number             => l_as_version_number,
                                                                     x_version_number                => l_version_number,
                                                                     x_s_adv_stnd_type               => l_s_adv_stnd_type
                                                                    )
                  THEN
                     write_message ('Before validate_std_unt_db_cons');
                     write_message (   '**** l_unit_details_id='
                                    || p_unit_details_id
                                   );

                     IF validate_std_unt_db_cons (p_batch_id                   => p_batch_id,
                                                  p_person_number              => l_person_number,
                                                  p_program_cd                 => p_program_cd,
                                                  p_unit_cd                    => l_unit_cd,
                                                  p_version_number             => l_version_number,
                                                  p_institution_cd             => l_institution_cd,
                                                  p_person_id                  => l_person_id,
                                                  p_auth_pers_id               => l_auth_pers_id,
                                                  p_unit_details_id            => p_unit_details_id,
                                                  p_as_version_number          => l_as_version_number,
                                                  p_prev_institution_code      => l_prev_institution_code
                                                 )
                     THEN
                        write_message ('Before validate_unit');

                        IF validate_unit (p_program_cd                    => p_program_cd,
                                          p_unit_cd                       => l_unit_cd,
                                          p_version_number                => l_version_number,
                                          p_achievable_credit_points      => l_achievable_credit_points,
                                          p_person_id                     => l_person_id,
                                          p_auth_pers_id                  => l_auth_pers_id,
                                          p_unit_details_id               => p_unit_details_id,
                                          p_as_version_number             => l_as_version_number,
                                          p_batch_id                      => p_batch_id,
                                          p_prev_institution_code         => l_prev_institution_code
                                         )
                        THEN
                           l_request_id := fnd_global.conc_request_id;
                           l_program_id := fnd_global.conc_program_id;
                           l_program_application_id :=
                                                      fnd_global.prog_appl_id;

                           IF (l_request_id = -1)
                           THEN
                              l_request_id := NULL;
                              l_program_id := NULL;
                              l_program_application_id := NULL;
                              l_program_update_date := NULL;
                           ELSE
                              l_program_update_date := SYSDATE;
                           END IF;

                           write_message (   '***** l_av_stnd_unit_lvl_id='
                                          || l_av_stnd_unit_lvl_id
                                         );
                           write_message ('***** INSERT INTO IGS_AV_STND_UNIT_ALL *****'
                                         );
                     DECLARE
                     CURSOR c_unitcd_ver
			     IS
			       SELECT schm.grading_schema_code,schm.grd_schm_version_number
				 FROM igs_ps_unit_grd_schm schm , IGS_AS_GRD_SCH_GRADE grd
				WHERE schm.unit_version_number = l_version_number AND schm.unit_code = l_unit_cd AND grd.grade=p_avstnd_grade
				AND  schm.grading_schema_code =  grd.grading_schema_cd
				AND  schm.grd_schm_version_number=grd.version_number;

                     rec_unitcd_ver c_unitcd_ver%ROWTYPE;
                     BEGIN
                     OPEN c_unitcd_ver;
		     FETCH c_unitcd_ver into rec_unitcd_ver;
		     BEGIN
                           igs_av_stnd_unit_pkg.insert_row (x_rowid                            => l_dmmy_rowid,
                                                            x_person_id                        => l_person_id,
                                                            x_as_course_cd                     => UPPER (p_program_cd
                                                                                                        ),
                                                            x_as_version_number                => l_as_version_number,
                                                            x_s_adv_stnd_type                  => l_s_adv_stnd_type,
                                                            x_unit_cd                          => UPPER (l_unit_cd
                                                                                                        ),
                                                            x_version_number                   => l_version_number,
                                                            x_s_adv_stnd_granting_status       => 'APPROVED',
                                                            x_credit_percentage                => NULL,
                                                            x_s_adv_stnd_recognition_type      => 'CREDIT',
                                                            x_approved_dt                      => SYSDATE,
                                                            x_authorising_person_id            => l_auth_pers_id,
                                                            x_crs_group_ind                    => 'N',
                                                            x_exemption_institution_cd         => UPPER (l_prev_institution_code
                                                                                                        ),
                                                            x_granted_dt                       => TO_DATE (NULL
                                                                                                          ),
                                                            x_expiry_dt                        => TO_DATE (NULL
                                                                                                          ),
                                                            x_cancelled_dt                     => TO_DATE (NULL
                                                                                                          ),
                                                            x_revoked_dt                       => TO_DATE (NULL
                                                                                                          ),
                                                            x_comments                         => 'Advanced Standing from external source',
                                                            x_av_stnd_unit_id                  => l_av_stnd_unit_lvl_id,
                                                            x_cal_type                         => l_cal_type,
                                                            x_ci_sequence_number               => l_seq_number,
                                                            x_institution_cd                   => UPPER (l_prev_institution_code --l_institution_cd
                                                                                                        ),
                                                            x_unit_details_id                  => p_unit_details_id,
                                                            x_grade                            => p_avstnd_grade,
                                                            x_achievable_credit_points         => l_achievable_credit_points,
                                                            x_mode                             => 'R',
                                                            x_org_id                           => igs_ge_gen_003.get_org_id (),
                                                            x_adv_stnd_trans                   => 'N',
							    x_grading_schema_cd                => rec_unitcd_ver.grading_schema_code,
							    x_grd_sch_version_number           => rec_unitcd_ver.grd_schm_version_number
                                                           );
	                   EXCEPTION
			       WHEN OTHERS THEN
			   IF (nvl(fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'INTERNAL') THEN
                           RETURN;
			   END IF;
			   END;
			   CLOSE c_unitcd_ver;
			   END;

                           IF l_grant_status <> 'APROVED'
                           THEN
			     DECLARE
			     CURSOR c_unitcd_ver
				     IS
			       SELECT schm.grading_schema_code,schm.grd_schm_version_number
				 FROM igs_ps_unit_grd_schm schm , IGS_AS_GRD_SCH_GRADE grd
				WHERE schm.unit_version_number = l_version_number AND schm.unit_code = l_unit_cd AND grd.grade=p_avstnd_grade
				AND  schm.grading_schema_code =  grd.grading_schema_cd
				AND  schm.grd_schm_version_number=grd.version_number;

			     rec_unitcd_ver c_unitcd_ver%ROWTYPE;
			     BEGIN
			     OPEN c_unitcd_ver;
			     FETCH c_unitcd_ver into rec_unitcd_ver;
                              igs_av_stnd_unit_pkg.update_row (x_rowid                            => l_dmmy_rowid,
                                                               x_person_id                        => l_person_id,
                                                               x_as_course_cd                     => UPPER (p_program_cd
                                                                                                           ),
                                                               x_as_version_number                => l_as_version_number,
                                                               x_s_adv_stnd_type                  => l_s_adv_stnd_type,
                                                               x_unit_cd                          => UPPER (l_unit_cd
                                                                                                           ),
                                                               x_version_number                   => l_version_number,
                                                               x_s_adv_stnd_granting_status       => l_grant_status,
                                                               x_credit_percentage                => TO_NUMBER (NULL
                                                                                                               ),
                                                               x_s_adv_stnd_recognition_type      => 'CREDIT',
                                                               x_approved_dt                      => SYSDATE,
                                                               x_authorising_person_id            => l_auth_pers_id,
                                                               x_crs_group_ind                    => 'N',
                                                               x_exemption_institution_cd         => UPPER (l_prev_institution_code
                                                                                                           ),
                                                               x_granted_dt                       => l_granted_dt,
                                                               x_expiry_dt                        => TO_DATE (NULL
                                                                                                             ),
                                                               x_cancelled_dt                     => TO_DATE (NULL
                                                                                                             ),
                                                               x_revoked_dt                       => TO_DATE (NULL
                                                                                                             ),
                                                               x_comments                         => 'Advanced Standing from external source',
                                                               x_av_stnd_unit_id                  => l_av_stnd_unit_lvl_id,
                                                               x_cal_type                         => l_cal_type,
                                                               x_ci_sequence_number               => l_seq_number,
                                                               x_institution_cd                   => UPPER (l_prev_institution_code --l_institution_cd
                                                                                                           ),
                                                               x_unit_details_id                  => p_unit_details_id,
                                                               x_tst_rslt_dtls_id                 => NULL,
                                                               x_grading_schema_cd                => rec_unitcd_ver.grading_schema_code,
                                                               x_grd_sch_version_number           => rec_unitcd_ver.grd_schm_version_number,
                                                               x_grade                            => p_avstnd_grade,
                                                               x_achievable_credit_points         => l_achievable_credit_points,
                                                               x_mode                             => 'R',
                                                               x_deg_aud_detail_id                => NULL
                                                              );
			   CLOSE c_unitcd_ver;
	                   END;
                           END IF;

                           write_message (   ' Inserted into IGS_AV_STND_UNIT_ALL val AV_STND_UNIT_ID ='
                                          || l_av_stnd_unit_lvl_id
                                         );
                        ELSE -- validate_unit
                           write_message ('Error 3');
                           l_return_status := fnd_api.g_ret_sts_error;
                        END IF; --validate_unit
                     ELSE -- validate_std_unt_db_cons
                        l_return_status := fnd_api.g_ret_sts_error;
                        write_message ('Error 4');
                     END IF; --validate_std_unt_db_cons
                  ELSE
                     write_message (' Updating  igs_av_stnd_unit_all');
                     OPEN c_adv_stnd_unt (l_person_id,
                                          l_prev_institution_code,
                                          p_unit_details_id,
                                          l_unit_cd,
                                          p_program_cd,
                                          l_as_version_number,
                                          l_version_number,
                                          l_s_adv_stnd_type
                                         );
                     FETCH c_adv_stnd_unt INTO l_adv_stnd_unt;

                     IF c_adv_stnd_unt%FOUND
                     THEN
                     DECLARE
                     CURSOR c_unitcd_ver
			     IS


			       SELECT schm.grading_schema_code,schm.grd_schm_version_number
				 FROM igs_ps_unit_grd_schm schm , IGS_AS_GRD_SCH_GRADE grd
				WHERE schm.unit_version_number = l_adv_stnd_unt.version_number AND schm.unit_code = l_adv_stnd_unt.unit_cd AND grd.grade=p_avstnd_grade
				AND  schm.grading_schema_code =  grd.grading_schema_cd
				AND  schm.grd_schm_version_number=grd.version_number;

                     rec_unitcd_ver c_unitcd_ver%ROWTYPE;
                     BEGIN
                     OPEN c_unitcd_ver;
		     FETCH c_unitcd_ver into rec_unitcd_ver;
                        igs_av_stnd_unit_pkg.update_row (x_rowid                            => l_adv_stnd_unt.ROWID,
                                                         x_person_id                        => l_adv_stnd_unt.person_id,
                                                         x_as_course_cd                     => l_adv_stnd_unt.as_course_cd,
                                                         x_as_version_number                => l_adv_stnd_unt.as_version_number,
                                                         x_s_adv_stnd_type                  => l_adv_stnd_unt.s_adv_stnd_type,
                                                         x_unit_cd                          => l_adv_stnd_unt.unit_cd,
                                                         x_version_number                   => l_adv_stnd_unt.version_number,
                                                         x_s_adv_stnd_granting_status       => l_grant_status,
                                                         x_credit_percentage                => l_adv_stnd_unt.credit_percentage,
                                                         x_s_adv_stnd_recognition_type      => l_adv_stnd_unt.s_adv_stnd_recognition_type,
                                                         x_approved_dt                      => l_adv_stnd_unt.approved_dt,
                                                         x_authorising_person_id            => l_auth_pers_id,
                                                         x_crs_group_ind                    => l_adv_stnd_unt.crs_group_ind,
                                                         x_exemption_institution_cd         => l_adv_stnd_unt.exemption_institution_cd,
                                                         x_granted_dt                       => l_granted_dt,
                                                         x_expiry_dt                        => l_adv_stnd_unt.expiry_dt,
                                                         x_cancelled_dt                     => l_adv_stnd_unt.cancelled_dt,
                                                         x_revoked_dt                       => l_adv_stnd_unt.revoked_dt,
                                                         x_comments                         => 'Advanced Standing from external source',
                                                         x_av_stnd_unit_id                  => l_adv_stnd_unt.av_stnd_unit_id,
                                                         x_cal_type                         => l_cal_type,
                                                         x_ci_sequence_number               => l_seq_number,
                                                         x_institution_cd                   => l_adv_stnd_unt.institution_cd,
                                                         x_unit_details_id                  => l_adv_stnd_unt.unit_details_id,
                                                         x_tst_rslt_dtls_id                 => l_adv_stnd_unt.tst_rslt_dtls_id,
                                                         x_grading_schema_cd                => rec_unitcd_ver.grading_schema_code,
                                                         x_grd_sch_version_number           => rec_unitcd_ver.grd_schm_version_number,
                                                         x_grade                            => p_avstnd_grade,
                                                         x_achievable_credit_points         => l_achievable_credit_points,
                                                         x_deg_aud_detail_id                => l_adv_stnd_unt.deg_aud_detail_id
                                                        );

                     CLOSE c_unitcd_ver;
	             END;
                        write_message ('DONE IGS_AV_STND_UNIT_PKG.UPDATE_ROW ');
                     END IF;

                     CLOSE c_adv_stnd_unt;
                  END IF; --IGS_AV_STND_UNIT_PKG.GET_UK_FOR_VALIDATION

                  IF NOT create_post_unit (p_person_id                  => l_person_id,
                                           p_course_version             => l_as_version_number,
                                           p_unit_details_id            => p_unit_details_id,
                                           p_program_cd                 => p_program_cd,
                                           p_unit_cd                    => l_unit_cd,
                                           p_version_number             => l_version_number,
                                           p_batch_id                   => p_batch_id,
                                           p_prev_institution_code      => l_prev_institution_code
                                          )
                  THEN
                     write_message ('Error 2');
                     l_return_status := fnd_api.g_ret_sts_error;
                  END IF; --create_post_unit
               ELSE -- validate_adv_stnd
                  l_return_status := fnd_api.g_ret_sts_error;
                  write_message ('Error 8');
               END IF; --validate_adv_stnd
            ELSE -- validate_adv_std_db_cons
               l_return_status := fnd_api.g_ret_sts_error;
               write_message ('Error 9');
            END IF; --validate_adv_std_db_cons
         ELSE -- derive_unit_data
            l_return_status := fnd_api.g_ret_sts_error;
            write_message ('Error 10');
         END IF; --    derive_unit_data
      ELSE -- validate_parameters
         l_return_status := fnd_api.g_ret_sts_error;
         write_message ('Error 11');
      END IF; --validate_parameters

/*      IF l_return_status IN (fnd_api.g_ret_sts_error, 'E', 'W')
      THEN
         write_message ('************************  Roll Back ********************');
         ROLLBACK TO create_adv_stnd_unit;
      END IF;*/

--      COMMIT;
      write_message ('************************ END ADVSTND  ********************'
                    );
      ecx_debug.pop ('IGS_DA_TRNS_IMP.CREATE_ADV_STND_UNIT');
      --Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                 p_data       => l_msg_data);
   EXCEPTION
      WHEN duplicate_record_exists
      THEN
         ecx_debug.pop ('IGS_DA_TRNS_IMP.CREATE_ADV_STND_UNIT');
             notify_error (p_batch_id,
                           l_person_id,
                           p_program_cd,
                           'Error has occurred.See log for Details'
                           );

	     write_message('ERROR ' || sqlerrm);
--         ROLLBACK TO create_adv_stnd_unit;
         l_return_status := 'W';
         fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                    p_data       => l_msg_data
                                   );
      WHEN fnd_api.g_exc_error
      THEN
--         ROLLBACK TO create_adv_stnd_unit;
             notify_error (p_batch_id,
                           l_person_id,
                           p_program_cd,
                           'Error has occurred.See log for Details'
                           );
         l_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                    p_data       => l_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
--         ROLLBACK TO create_adv_stnd_unit;
         l_return_status := fnd_api.g_ret_sts_unexp_error;
         notify_error (p_batch_id,
                           l_person_id,
                           p_program_cd,
                           'Error has occurred.See log for Details'
                           );
         fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                    p_data       => l_msg_data
                                   );
      WHEN OTHERS
      THEN
             notify_error (p_batch_id,
                           l_person_id,
                           p_program_cd,
                           'Error has occurred.See log for Details'
                           );
	     write_message('ERROR ' || sqlerrm);
--         ROLLBACK TO create_adv_stnd_unit;
         l_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('IGS', 'IGS_AV_UNHANDLED_ERROR');
         fnd_message.set_token ('ERROR', SQLERRM);
         fnd_msg_pub.ADD;
	 notify_error (p_batch_id,
		       l_person_id,
		       p_program_cd,
			'Error has occurred.See log for Details'
		       );

	 write_message('ERROR ' || sqlerrm);
         fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                    p_data       => l_msg_data
                                   );
   END create_adv_stnd_unit;

   PROCEDURE create_or_get_batch_id (
      p_batch_id              IN              igs_da_rqst.batch_id%TYPE,
      p_person_id_code        IN              igs_pe_alt_pers_id.api_person_id%TYPE,
      p_person_id_code_type   IN              igs_pe_alt_pers_id.person_id_type%TYPE,
      p_program_code          IN              igs_av_lgcy_unt_int.program_cd%TYPE,
      transaction_sub_type    IN              VARCHAR2,
      p_out_batch_id          OUT NOCOPY      igs_da_rqst.batch_id%TYPE
   )
   IS
      CURSOR c_template
      IS
         SELECT request_type_id
           FROM igs_da_cnfg_req_typ
          WHERE request_name = 'Transfer Evaluation External Source'
            AND request_type = 'TE'
            AND closed_ind = 'N';

      CURSOR c_batch_id
      IS
         SELECT igs_da_batch_id_s.NEXTVAL
           FROM DUAL;

      CURSOR c_requestor
      IS
         SELECT requestor_id
           FROM igs_da_rqst
          WHERE batch_id = p_batch_id;

      CURSOR c_stdnts_batch (p_person_id hz_parties.party_id%TYPE)
      IS
         SELECT 'x'
           FROM igs_da_req_stdnts
          WHERE batch_id = p_batch_id
            AND person_id = p_person_id
            AND ERROR_CODE = 'INP';

      CURSOR c_requestor_id
      IS
         SELECT hz_parties.party_id
           FROM hz_parties, fnd_user
          WHERE fnd_user.customer_id = hz_parties.party_id
            AND fnd_user.user_id = fnd_profile.VALUE ('IGS_DA_WF_ADMIN');

      l_request_type_id        igs_da_cnfg_req_typ.request_type_id%TYPE;
      l_batch_id               igs_da_rqst.batch_id%TYPE;
      l_person_id              hz_parties.party_id%TYPE;
      l_requestor_person_id    hz_parties.party_id%TYPE;
      l_person_number          hz_parties.party_number%TYPE;
      v_dummy                  VARCHAR2 (1);
      v_dummy_rowid            ROWID;
      l_return_status          VARCHAR2 (500);
      l_msg_data               VARCHAR2 (2000);
      l_msg_count              NUMBER;
      l_igs_da_req_stdnts_id   igs_da_req_stdnts.igs_da_req_stdnts_id%TYPE;
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.CREATE_OR_GET_BATCH_ID');
      write_message ('      p_batch_id             ' || p_batch_id);
      write_message ('      p_person_id_code       ' || p_person_id_code);
      write_message ('      p_person_id_code_type  ' || p_person_id_code_type);
      write_message ('      p_program_code         ' || p_program_code);
      write_message ('      transaction_sub_type   ' || transaction_sub_type);
      write_message ('      p_out_batch_id         ' || p_out_batch_id);
      igs_da_xml_pkg.get_person_details (RTRIM (LTRIM (p_person_id_code)),
                                         RTRIM (LTRIM (p_person_id_code_type)),
                                         l_person_id,
                                         l_person_number
                                        );

      IF l_person_id IS NULL
      THEN
         write_message ('ERROR The student ID must match either the OSS ID or an alternate student ID as defined in the degree audit configuration.'
                       );
         notify_error (p_batch_id,
                       l_person_id,
                       p_program_code,
                       fnd_message.get_string ('IGS', 'IGS_DA_STU_NOT_EXIST')
                      );
         RETURN;
      END IF;

      write_message (   'create_or_get_batch_id : Got person ID as '
                     || l_person_id
                    );

      IF (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') = 'EXTERNAL')
      THEN
         write_message ('create_or_get_batch_id : Source is External');
         OPEN c_stdnts_batch (l_person_id);
         FETCH c_stdnts_batch INTO v_dummy;

         IF c_stdnts_batch%NOTFOUND
         THEN
            -- this person data has not been imported before for this xml message
            -- safely delete academic history and advanced standing data
            write_message ('create_or_get_batch_id : Deleting existing records'
                          );
            delete_adv_stnd_records (l_person_id);
         END IF;

         CLOSE c_stdnts_batch;

         IF     p_batch_id IS NULL
            AND UPPER (transaction_sub_type) = UPPER ('NoRequest')
         THEN
            -- get the request template type id
            OPEN c_template;
            FETCH c_template INTO l_request_type_id;
            CLOSE c_template;

            IF l_request_type_id IS NULL
            THEN
               write_message ('Setup Template not defined');
               notify_error (p_batch_id,
                             l_person_id,
                             p_program_code,
                             'Setup Template not defined'
                            );
            END IF;

            -- create a new batch id

            OPEN c_batch_id;
            FETCH c_batch_id INTO l_batch_id;
            CLOSE c_batch_id;
            OPEN c_requestor;
            FETCH c_requestor INTO l_requestor_person_id;
            CLOSE c_requestor;

            IF l_requestor_person_id IS NULL
            THEN
               OPEN c_requestor_id;
               FETCH c_requestor_id INTO l_requestor_person_id;
               CLOSE c_requestor_id;
            END IF;

            IF l_requestor_person_id IS NULL
            THEN
               notify_error (p_batch_id,
                             l_person_id,
                             p_program_code,
                             'ERROR Could not find the authorising person ID in OSS.'
                            );
            END IF;

            write_message ('create_or_get_batch_id : Creating new request');
            write_message ('***** INSERT INTO IGS_DA_RQST *****');
            igs_da_rqst_pkg.insert_row (x_rowid                        => v_dummy_rowid,
                                        x_batch_id                     => l_batch_id,
                                        x_request_type_id              => l_request_type_id,
                                        x_request_mode                 => 'MULTI',
                                        x_program_comparison_type      => 'DP',
                                        x_request_status               => 'COMPLETED',
                                        x_person_id_group_id           => NULL,
                                        x_person_id                    => NULL,
                                        x_requestor_id                 => l_requestor_person_id,
                                        x_student_release_ind          => 'N',
                                        x_special_program              => NULL,
                                        x_special_program_catalog      => NULL,
                                        x_attribute_category           => NULL,
                                        x_attribute1                   => NULL,
                                        x_attribute2                   => NULL,
                                        x_attribute3                   => NULL,
                                        x_attribute4                   => NULL,
                                        x_attribute5                   => NULL,
                                        x_attribute6                   => NULL,
                                        x_attribute7                   => NULL,
                                        x_attribute8                   => NULL,
                                        x_attribute9                   => NULL,
                                        x_attribute10                  => NULL,
                                        x_attribute11                  => NULL,
                                        x_attribute12                  => NULL,
                                        x_attribute13                  => NULL,
                                        x_attribute14                  => NULL,
                                        x_attribute15                  => NULL,
                                        x_attribute16                  => NULL,
                                        x_attribute17                  => NULL,
                                        x_attribute18                  => NULL,
                                        x_attribute19                  => NULL,
                                        x_attribute20                  => NULL,
                                        x_mode                         => 'R',
                                        x_return_status                => l_return_status,
                                        x_msg_data                     => l_msg_data,
                                        x_msg_count                    => l_msg_count
                                       );
            p_out_batch_id := l_batch_id;
         ELSIF     UPPER (transaction_sub_type) <> UPPER ('NoRequest')
               AND p_batch_id IS NULL
         THEN
            write_message ('ERROR :- Missing Batch ID');
            notify_error (p_batch_id,
                          l_person_id,
                          p_program_code,
                          'ERROR :- Missing Batch ID.'
                         );
         ELSE
            p_out_batch_id := p_batch_id;
         END IF;

         IF     UPPER (transaction_sub_type) = UPPER ('NoRequest')
            AND (NVL (fnd_profile.VALUE ('IGS_AV_STND_SOURCE'), 'X') =
                                                                    'EXTERNAL'
                )
            AND l_batch_id IS NOT NULL
         THEN
            write_message ('create_or_get_batch_id : Adding students to request'
                          );
            write_message ('***** INSERT INTO IGS_DA_REQ_STDNTS *****');
            v_dummy_rowid := NULL;
            igs_da_req_stdnts_pkg.insert_row (x_rowid                     => v_dummy_rowid,
                                              x_batch_id                  => l_batch_id,
                                              x_igs_da_req_stdnts_id      => l_igs_da_req_stdnts_id,
                                              x_person_id                 => l_person_id,
                                              x_program_code              => p_program_code,
                                              x_wif_program_code          => NULL,
                                              x_special_program_code      => NULL,
                                              x_major_unit_set_cd         => NULL,
                                              x_program_major_code        => NULL,
                                              x_report_text               => NULL,
                                              x_wif_id                    => NULL,
                                              x_mode                      => 'R',
                                              x_error_code                => 'INP'
                                             );
         ELSE
            UPDATE igs_da_req_stdnts
               SET ERROR_CODE = 'INP'
             WHERE batch_id = p_batch_id AND person_id = l_person_id;
         END IF;
      ELSE
         IF p_batch_id IS NULL
         THEN
            write_message (' ERROR Batch ID missing ');
         ELSE
            p_out_batch_id := p_batch_id;
         END IF;

         write_message (' New Batch ID is ' || p_out_batch_id);
      END IF;

      ecx_debug.pop ('IGS_DA_TRNS_IMP.CREATE_OR_GET_BATCH_ID');
   EXCEPTION
      WHEN OTHERS
      THEN
	 ecx_debug.pop ('IGS_DA_TRNS_IMP.CREATE_OR_GET_BATCH_ID');
               notify_error (p_batch_id,
                             l_person_id,
                             p_program_code,
                             'Setup Template not defined'
                            );
	 write_message('ERROR ' || sqlerrm);
   END create_or_get_batch_id;

   PROCEDURE complete_import_process (p_batch_id IN igs_da_rqst.batch_id%TYPE)
   AS
   BEGIN
      ecx_debug.push ('IGS_DA_TRNS_IMP.COMPLETE_IMPORT_PROCESS');
      write_message (   'Entered complete_import_process p_batch_id='
                     || p_batch_id
                    );

      UPDATE igs_da_req_stdnts
         SET ERROR_CODE = NULL
       WHERE batch_id = p_batch_id AND ERROR_CODE = 'INP';

      UPDATE igs_da_req_stdnts
         SET report_text =
                    ' <HTML> <BODY> Transfer Evaluation <BR> <BR> '
                 || 'Completed Successfully'
                 || ' '
                 || ' </BODY> </HTML> '
       WHERE batch_id = p_batch_id AND report_text IS NULL;

      igs_da_xml_pkg.update_request_status (p_batch_id);
      ecx_debug.pop ('IGS_DA_TRNS_IMP.COMPLETE_IMPORT_PROCESS');
   EXCEPTION
      WHEN OTHERS
      THEN
         write_message('ERROR ' || sqlerrm);
END complete_import_process;
END igs_da_trns_imp;

/
