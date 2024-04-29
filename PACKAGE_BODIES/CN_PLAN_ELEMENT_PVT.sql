--------------------------------------------------------
--  DDL for Package Body CN_PLAN_ELEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PLAN_ELEMENT_PVT" AS
   /*$Header: cnvpeb.pls 120.24 2007/11/14 15:40:42 hanaraya ship $*/
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_PLAN_ELEMENT_PVT';

   -- Returns a plan element record type given a quota_id
   FUNCTION get_plan_element (
      p_quota_id                          NUMBER
   )
      RETURN plan_element_rec_type
   IS
      CURSOR c_plan_element_csr
      IS
         SELECT pe.quota_id,
                pe.NAME,
                pe.description,
                pe.quota_type_code,
                pe.target,
                pe.payment_amount,
                pe.performance_goal,
                pe.incentive_type_code,
                pe.start_date,
                pe.end_date,
                pe.credit_type_id,
                pe.interval_type_id,
                pe.calc_formula_id,
                pe.liability_account_id,
                pe.expense_account_id,
                'liability_account_cc',
                'expense_account_cc',
                pe.vesting_flag,
                pe.quota_group_code,
                pe.payment_group_code,
                pe.attribute_category,
                pe.attribute1,
                pe.attribute2,
                pe.attribute3,
                pe.attribute4,
                pe.attribute5,
                pe.attribute6,
                pe.attribute7,
                pe.attribute8,
                pe.attribute9,
                pe.attribute10,
                pe.attribute11,
                pe.attribute12,
                pe.attribute13,
                pe.attribute14,
                pe.attribute15,
                pe.addup_from_rev_class_flag,
                pe.payee_assign_flag,
                pe.package_name,
                pe.object_version_number,
                pe.org_id,
                pe.indirect_credit,
                pe.quota_status,
                pe.salesreps_enddated_flag,
                NULL
           FROM cn_quotas_v pe
          WHERE pe.quota_id = p_quota_id;

      l_plan_element                plan_element_rec_type;
   BEGIN
      -- fetch the old record
      OPEN c_plan_element_csr;

      FETCH c_plan_element_csr
       INTO l_plan_element;

      IF c_plan_element_csr%NOTFOUND
      THEN
         fnd_message.set_name ('CN', 'CN_INVALID_UPDATE_REC');
         fnd_msg_pub.ADD;

         CLOSE c_plan_element_csr;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_plan_element_csr;

      RETURN l_plan_element;
   END;

-------------------------------------------------------------------------+++++++++++++++++++++++
-- Procedure   : is_valid_org
-- Description :  validates that the org id is valid and consistent with that of the planelement
-------------------------------------------------------------------------++++++++++++++++++++++++
   FUNCTION is_valid_org (
      p_org_id                            NUMBER,
      p_quota_id                          NUMBER := NULL
   )
      RETURN BOOLEAN
   IS
      l_return                      VARCHAR2 (100) := NULL;
      l_dummy                       NUMBER;
      l_ret_val                     BOOLEAN := FALSE;
   BEGIN
      l_return := mo_global.check_valid_org (p_org_id);

      IF l_return = 'Y'
      THEN
         l_ret_val := TRUE;

         IF p_quota_id IS NOT NULL
         THEN
            BEGIN
               SELECT 1
                 INTO l_dummy
                 FROM DUAL
                WHERE EXISTS (SELECT 1
                                FROM cn_quotas_v
                               WHERE quota_id = p_quota_id AND org_id = p_org_id);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                  THEN
                     fnd_message.set_name ('FND', 'MO_ORG_INVALID');
                     fnd_msg_pub.ADD;
                  END IF;

                  RETURN FALSE;
            END;
         END IF;
      END IF;

      RETURN l_ret_val;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END is_valid_org;

-- -------------------------------------------------------------------------+-+
--| Procedure:   add_system_note
--| Description: Insert notes for the create, update and delete
--| operations.
--| Called From: Create_plan_Element, Update_Plan_Element
--| Delete_Plan_Element
-- -------------------------------------------------------------------------+-+
   PROCEDURE add_system_note(
      p_plan_element_old         IN OUT NOCOPY plan_element_rec_type,
      p_plan_element_new         IN OUT NOCOPY plan_element_rec_type,
      p_operation                IN VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS

    l_note_msg VARCHAR2 (2000);
    l_consolidated_note VARCHAR2(2000);
    l_plan_element_id NUMBER;
    l_note_id NUMBER;
    l_temp_old VARCHAR2 (200);
    l_temp_new VARCHAR2 (200);
    l_temp_1   VARCHAR2 (200);
    l_temp_2   VARCHAR2 (200);

   BEGIN
     -- Initialize to success
     x_return_status := fnd_api.g_ret_sts_success;
     -- Initialize other fields
     x_msg_data := fnd_api.g_null_char;
     x_msg_count := fnd_api.g_null_num;

     IF (p_operation <> 'update') THEN
       IF (p_operation = 'create') THEN
         fnd_message.set_name('CN','CNR12_NOTE_PE_NAME_CREATE');
         fnd_message.set_token('PE_NAME', p_plan_element_new.NAME);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_temp_new := 'CN_QUOTAS';
       END IF;
       IF (p_operation = 'delete') THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_NAME_DELETE');
         fnd_message.set_token('PE_NAME', p_plan_element_old.NAME);
         l_plan_element_id := p_plan_element_old.org_id;
         l_temp_new := 'CN_DELETED_OBJECTS';
       END IF;
       l_note_msg := fnd_message.get;
       jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => l_temp_new,
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );
     ELSIF (p_operation = 'update') THEN
       l_consolidated_note := '';
       -- CHECK IF PE NAME WAS UPDATED
       IF (p_plan_element_old.NAME <> p_plan_element_new.NAME) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_NAME_UPDATE');
         fnd_message.set_token('PE_NAME_OLD', p_plan_element_old.NAME);
         fnd_message.set_token('PE_NAME_NEW', p_plan_element_new.NAME);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;
       -- CHECK IF START DATE WAS UPDATED
       IF (p_plan_element_old.start_date <> p_plan_element_new.start_date) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_STDATE_UPDATE');
         fnd_message.set_token('PE_START_OLD', p_plan_element_old.start_date);
         fnd_message.set_token('PE_START_NEW', p_plan_element_new.start_date);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;
       -- CHECK IF END DATE WAS UPDATED
       IF (NVL(p_plan_element_old.end_date, fnd_api.g_miss_date)
          <> NVL(p_plan_element_new.end_date, fnd_api.g_miss_date)) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_ENDATE_UPDATE');
         IF (p_plan_element_old.end_date IS NULL) THEN
           fnd_message.set_token('PE_END_OLD', 'NULL');
         ELSE
           fnd_message.set_token('PE_END_OLD', p_plan_element_old.end_date);
         END IF;
         IF (p_plan_element_new.end_date IS NULL) THEN
           fnd_message.set_token('PE_END_NEW', 'NULL');
         ELSE
           fnd_message.set_token('PE_END_NEW', p_plan_element_new.end_date);
         END IF;
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;
       -- CHECK IF DESCRIPTION WAS UPDATED
       IF (p_plan_element_old.description <> p_plan_element_new.description) THEN
         fnd_message.set_name ('CN','CNR12_NOTE_PE_DESC_UPDATE');
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;

       -- CHECK IF INTERVAL TYPE WAS UPDATED
       IF (p_plan_element_old.interval_type_id <> p_plan_element_new.interval_type_id) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_INTTYPE_UPDATE');
         l_plan_element_id := p_plan_element_new.quota_id;
         select NAME into l_temp_old from CN_INTERVAL_TYPES
         where interval_type_id = p_plan_element_old.interval_type_id
         and org_id = p_plan_element_old.org_id;
         select NAME into l_temp_new from CN_INTERVAL_TYPES
         where interval_type_id = p_plan_element_new.interval_type_id
         and org_id = p_plan_element_new.org_id;
         fnd_message.set_token('PE_OLD_INTERVAL', l_temp_old);
         fnd_message.set_token('PE_NEW_INTERVAL', l_temp_new);
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;

       -- CHECK IF FORMULA TYPE WAS UPDATED
       IF (p_plan_element_old.quota_type_code <> p_plan_element_new.quota_type_code) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_FORTYPE_UPDATE');
         l_plan_element_id := p_plan_element_new.quota_id;
         l_temp_1 := cn_api.get_lkup_meaning(p_plan_element_old.quota_type_code, 'QUOTA_TYPE');
         l_temp_2 := cn_api.get_lkup_meaning(p_plan_element_new.quota_type_code, 'QUOTA_TYPE');
         fnd_message.set_token('PE_OLD_FOR', l_temp_1);
         fnd_message.set_token('PE_NEW_FOR', l_temp_2);
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;

       -- CHECK IF FORMULA TYPE/NAME WAS UPDATED
       IF (p_plan_element_old.quota_type_code <> p_plan_element_new.quota_type_code
            OR p_plan_element_old.calc_formula_id <> p_plan_element_new.calc_formula_id
            OR p_plan_element_old.package_name <> p_plan_element_new.package_name) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_FOR_TYPE_UPDATE');
         l_plan_element_id := p_plan_element_new.quota_id;
         IF (p_plan_element_old.quota_type_code = 'FORMULA') THEN
           IF (p_plan_element_old.calc_formula_id IS NULL) THEN
              l_temp_old := '';
           ELSE
             SELECT NAME INTO l_temp_old FROM CN_CALC_FORMULAS
             WHERE CALC_FORMULA_ID = p_plan_element_old.calc_formula_id;
           END IF;
         ELSE
           l_temp_old := p_plan_element_old.package_name;
         END IF;
         IF (p_plan_element_new.quota_type_code = 'FORMULA') THEN
           SELECT NAME INTO l_temp_new FROM CN_CALC_FORMULAS
           WHERE CALC_FORMULA_ID = p_plan_element_new.calc_formula_id;
         ELSE
           l_temp_new := p_plan_element_new.package_name;
         END IF;
         l_temp_1 := cn_api.get_lkup_meaning(p_plan_element_old.quota_type_code, 'QUOTA_TYPE');
         l_temp_2 := cn_api.get_lkup_meaning(p_plan_element_new.quota_type_code, 'QUOTA_TYPE');
         fnd_message.set_token('FORMULA_TYPE_OLD', l_temp_1);
         fnd_message.set_token('FORMULA_NAME_OLD', l_temp_old);
         fnd_message.set_token('FORMULA_TYPE_NEW', l_temp_2);
         fnd_message.set_token('FORMULA_NAME_NEW', l_temp_new);
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;

       -- CHECK IF PAYMENT GROUP WAS UPDATED
       IF (p_plan_element_old.payment_group_code <> p_plan_element_new.payment_group_code) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_PAYGRP_UPDATE');
         fnd_message.set_token('PAYGRP_OLD', p_plan_element_old.payment_group_code);
         fnd_message.set_token('PAYGRP_NEW', p_plan_element_new.payment_group_code);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;

       -- CHECK IF CREDIT TYPE WAS UPDATED
       IF (p_plan_element_old.credit_type_id <> p_plan_element_new.credit_type_id) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_CRTYPE_UPDATE');
         select name into l_temp_old from cn_credit_types_vl
         where credit_type_id = p_plan_element_old.credit_type_id
         and org_id = p_plan_element_old.org_id;
         select name into l_temp_new from cn_credit_types_vl
         where credit_type_id = p_plan_element_new.credit_type_id
         and org_id = p_plan_element_new.org_id;
         fnd_message.set_token('PE_OLD_CREDIT', l_temp_old);
         fnd_message.set_token('PE_NEW_CREDIT', l_temp_new);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;

       -- CHECK IF PAID THRU PARTY WAS UPDATED
       IF (p_plan_element_old.payee_assign_flag <> p_plan_element_new.payee_assign_flag) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_THIRDPARY_UPDATE');
         select meaning into l_temp_old from cn_lookups
         where lookup_code = NVL(p_plan_element_old.payee_assign_flag, 'N')
         and lookup_type = 'YES_NO';
         select meaning into l_temp_new from cn_lookups
         where lookup_code = NVL(p_plan_element_new.payee_assign_flag, 'N')
         and lookup_type = 'YES_NO';
         fnd_message.set_token('PE_OLD_PAYEE', l_temp_old);
         fnd_message.set_token('PE_NEW_PAYEE', l_temp_new);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*        jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;

       -- CHECK IF LIABILITY A/C WAS UPDATED
       IF (p_plan_element_old.liability_account_id <> p_plan_element_new.liability_account_id) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_LIA_UPDATE');
         SELECT
         DECODE(LA.CODE_COMBINATION_ID,NULL,NULL, LA.SEGMENT1||'-'||LA.SEGMENT2||'-'||LA.SEGMENT3||'-'||LA.SEGMENT4 ||'-'||LA.SEGMENT5)
         INTO l_temp_old FROM GL_CODE_COMBINATIONS LA
         WHERE LA.CODE_COMBINATION_ID = p_plan_element_old.liability_account_id;
         SELECT
         DECODE(LA.CODE_COMBINATION_ID,NULL,NULL, LA.SEGMENT1||'-'||LA.SEGMENT2||'-'||LA.SEGMENT3||'-'||LA.SEGMENT4 ||'-'||LA.SEGMENT5)
         INTO l_temp_new FROM GL_CODE_COMBINATIONS LA
         WHERE LA.CODE_COMBINATION_ID = p_plan_element_new.liability_account_id;
         fnd_message.set_token('PE_OLD_LIA', l_temp_old);
         fnd_message.set_token('PE_NEW_LIA', l_temp_new);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;

       -- CHECK IF EXPENSE A/C WAS UPDATED
       IF (p_plan_element_old.expense_account_id <> p_plan_element_new.expense_account_id) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_EXP_UPDATE');
         SELECT
         DECODE(LA.CODE_COMBINATION_ID,NULL,NULL, LA.SEGMENT1||'-'||LA.SEGMENT2||'-'||LA.SEGMENT3||'-'||LA.SEGMENT4 ||'-'||LA.SEGMENT5)
         INTO l_temp_old FROM GL_CODE_COMBINATIONS LA
         WHERE LA.CODE_COMBINATION_ID = p_plan_element_old.expense_account_id;
         SELECT
         DECODE(LA.CODE_COMBINATION_ID,NULL,NULL, LA.SEGMENT1||'-'||LA.SEGMENT2||'-'||LA.SEGMENT3||'-'||LA.SEGMENT4 ||'-'||LA.SEGMENT5)
         INTO l_temp_new FROM GL_CODE_COMBINATIONS LA
         WHERE LA.CODE_COMBINATION_ID = p_plan_element_new.expense_account_id;
         fnd_message.set_token('PE_EXP_OLD', l_temp_old);
         fnd_message.set_token('PE_EXP_NEW', l_temp_new);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;

       -- CHECK IF CREDIT ROLLUP WAS UPDATED
       IF (p_plan_element_old.indirect_credit_code <> p_plan_element_new.indirect_credit_code) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_CRROLL_UPDATE');
         l_temp_old := cn_api.get_lkup_meaning(p_plan_element_old.indirect_credit_code, 'INDIRECT_CREDIT_TYPE');
         l_temp_new := cn_api.get_lkup_meaning(p_plan_element_new.indirect_credit_code, 'INDIRECT_CREDIT_TYPE');
         fnd_message.set_token('PE_CR_ROLL_OLD', l_temp_old);
         fnd_message.set_token('PE_CR_ROLL_NEW', l_temp_new);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;
       -- CHECK IF VARIABLE 1- TARGET IS CHANGED
       IF (p_plan_element_old.target <> p_plan_element_new.target) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_VAR1_UPD');
         fnd_message.set_token('OLD_VAL', p_plan_element_old.target);
         fnd_message.set_token('NEW_VAL', p_plan_element_new.target);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;
       -- CHECK IF VARIABLE 2- PAYMENT AMOUNT IS CHANGED
       IF (p_plan_element_old.payment_amount <> p_plan_element_new.payment_amount) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_VAR2_UPD');
         fnd_message.set_token('OLD_VAL', p_plan_element_old.payment_amount);
         fnd_message.set_token('NEW_VAL', p_plan_element_new.payment_amount);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;
       -- CHECK IF VARIABLE 3- PERFORMANCE GOAL IS CHANGED
       IF (p_plan_element_old.performance_goal <> p_plan_element_new.performance_goal) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_VAR3_UPD');
         fnd_message.set_token('OLD_VAL', p_plan_element_old.performance_goal);
         fnd_message.set_token('NEW_VAL', p_plan_element_new.performance_goal);
         l_plan_element_id := p_plan_element_new.quota_id;
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
       END IF;

       IF LENGTH(l_consolidated_note) > 1 THEN
       jtf_notes_pub.create_note (p_api_version          => 1.0,
	                           x_return_status           => x_return_status,
	                           x_msg_count               => x_msg_count,
	                           x_msg_data                => x_msg_data,
	                           p_source_object_id        => l_plan_element_id,
	                           p_source_object_code      => 'CN_QUOTAS',
	                           p_notes                   => l_consolidated_note,
	                           p_notes_detail            => l_consolidated_note,
	                           p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
	                           x_jtf_note_id             => l_note_id                                                                 -- returned
                               );
       END IF;


     END IF;

     EXCEPTION
       WHEN fnd_api.g_exc_error
       THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
       WHEN fnd_api.g_exc_unexpected_error
       THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
       WHEN OTHERS
       THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, 'add_system_note');
         END IF;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);

   END add_system_note;

-------------------------------------------------------------------------+-+
--- Add message
-------------------------------------------------------------------------+-+
   PROCEDURE set_message (
      p_plan_name                         VARCHAR2,
      p_pe_name                           VARCHAR2,
      message_name                        VARCHAR2,
      token_name                          VARCHAR2,
      token_value                         VARCHAR2
   )
   IS
   BEGIN
      cn_message_pkg.set_message (appl_short_name      => 'CN',
                                  message_name         => message_name,
                                  token_name1          => 'QUOTA_NAME',
                                  token_value1         => p_pe_name,
                                  token_name2          => 'PLAN_NAME',
                                  token_value2         => p_plan_name,
                                  token_name3          => token_name,
                                  token_value3         => token_value,
                                  token_name4          => NULL,
                                  token_value4         => NULL,
                                  TRANSLATE            => TRUE
                                 );
      fnd_msg_pub.ADD;
   END set_message;

-- -------------------------------------------------------------------------+-+
--| Procedure:   Insert_rate_quotas
--| Description: Rate_quotas is a local procedure to create the Default rate
--| Quota Assigns if the quota type is formula and the formula has the rates in
--| formula rate Assigns. Another important thing is if you pass the custom
--| Quota Rate it will ignore the default create. it will use the custom one you
--| Pass through your API.
--| Called From: Create_plan_Element and Update_Plan_Element
-- -------------------------------------------------------------------------+-+

   PROCEDURE update_rate_quotas (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       plan_element_rec_type,
      p_pe_rec_old               IN       plan_element_rec_type,
      p_rt_quota_asgns_rec_tbl   IN       cn_plan_element_pub.rt_quota_asgns_rec_tbl_type := g_miss_rt_quota_asgns_rec_tbl,
      p_quota_name               IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Rate_Quotas';
      l_object_version_number NUMBER;
   BEGIN
      -- Record inserted successfully, check for rt_quota_assigns
      -- Insert Rate Quota Assigs
      -- first table count is 0

      -- Set Status
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      IF p_pe_rec.quota_type_code <> 'NONE'
      THEN
         -- Check if the Count is O and the QUOTA TYPE IS FORMULA
         -- Call the Chk_formula_rate_date Procedure to check all the Start
         -- Date and End date of Rate QUota assigns falls user the Quota Start
         -- and end Date then insert through a batch by calling the Table Handler
         IF NVL (p_pe_rec_old.calc_formula_id, 0) <> NVL (p_pe_rec.calc_formula_id, 0)
         THEN
            -- Call the Table Handler to Delete the Old Period quotas
            cn_rt_quota_asgns_pkg.DELETE_RECORD (x_quota_id => p_pe_rec_old.quota_id, x_calc_formula_id => NULL, x_rt_quota_asgn_id => NULL);
         END IF;

         IF p_rt_quota_asgns_rec_tbl.COUNT = 0
         THEN
            IF p_pe_rec.calc_formula_id IS NOT NULL AND NVL (p_pe_rec_old.calc_formula_id, 0) <> NVL (p_pe_rec.calc_formula_id, 0)
            THEN
               -- if called from public api then we need to insert defaults
               -- else the defaults are inserted by direct rate tables assignment calls
               --IF p_pe_rec.call_type = cn_plan_element_pvt.g_public_api
               --THEN
                  cn_rt_quota_asgns_pkg.INSERT_RECORD (x_quota_id => p_pe_rec.quota_id, x_calc_formula_id => p_pe_rec.calc_formula_id);
               --END IF;
            END IF;
         -- if the rt_table_count is > 0 and the quota type  is FORMULA
         ELSIF p_rt_quota_asgns_rec_tbl.COUNT > 0
         THEN
            -- call create_rt_quota_asgns_pvt package to validate and create
            -- the rate Quota Assigns
            /*cn_rt_quota_asgns_pvt.update_rt_quota_asgns (p_api_version                 => p_api_version,
                                                         p_init_msg_list               => 'T',
                                                         p_commit                      => p_commit,
                                                         p_validation_level            => p_validation_level,
                                                         x_return_status               => x_return_status,
                                                         x_msg_count                   => x_msg_count,
                                                         x_msg_data                    => x_msg_data,
                                                         p_quota_name                  => p_quota_name,
                                                         p_rt_quota_asgns_rec_tbl      => p_rt_quota_asgns_rec_tbl,
                                                         x_loading_status              => x_loading_status
                                                        );*/
cn_rt_quota_asgns_pvt.update_rt_quota_asgns (p_api_version                 => p_api_version,
                                                         p_init_msg_list               => 'T',
                                                         p_commit                      => p_commit,
                                                         p_validation_level            => p_validation_level,
                                                         x_return_status               => x_return_status,
                                                         x_msg_count                   => x_msg_count,
                                                         x_msg_data                    => x_msg_data,
                                                         p_quota_name                  => p_quota_name,
                                                         p_rt_quota_asgns_rec_tbl      => p_rt_quota_asgns_rec_tbl,
                                                         x_loading_status              => x_loading_status,
                                                         p_org_id                      => p_pe_rec.org_id,
                                                         x_object_version_number       => l_object_version_number
                                                        );


            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSIF p_rt_quota_asgns_rec_tbl.COUNT > 0
      THEN
         -- if table count is > 0 but the quota type code is NONE
         -- then raise an error
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_QUOTA_CANNOT_HAVE_RATES');
            fnd_message.set_token ('PLAN_NAME', p_quota_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'QUOTA_CANNOT_HAVE_RATES';
         RAISE fnd_api.g_exc_error;
      END IF;
-- End of rate_quotas
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END update_rate_quotas;

-- -------------------------------------------------------------------------+-+
--| Procedure   : update_exprs
--| Description : Syncs expressions that are using a particular plan element
--| if the name is changed
-- -------------------------------------------------------------------------+-+
   PROCEDURE update_exprs (
      p_quota_id                          NUMBER,
      p_old_name                          VARCHAR2,
      p_new_name                          VARCHAR2
   )
   IS
      CURSOR get_exps
      IS
         SELECT calc_sql_exp_id,
                DBMS_LOB.SUBSTR (piped_sql_select) sql_select,
                DBMS_LOB.SUBSTR (piped_expression_disp) expr_disp
           FROM cn_calc_sql_exps
          WHERE '|' || DBMS_LOB.SUBSTR (piped_sql_select) LIKE '%|(' || p_quota_id || 'PE.%';

      l_ss_start                    NUMBER;
      l_ss_end                      NUMBER;
      l_ed_start                    NUMBER;
      l_ed_end                      NUMBER;
      l_quota_id_len                NUMBER := LENGTH ('' || p_quota_id);
      l_quota_name_len              NUMBER := LENGTH (p_old_name);
      CONTINUE                      BOOLEAN;
      l_ss_seg                      VARCHAR2 (4000);
      l_ed_seg                      VARCHAR2 (80);
      l_new_expr_disp               VARCHAR2 (4000);
      l_new_pexpr_disp              VARCHAR2 (4000);
   BEGIN
      -- get all expressions using p_quota_id
      FOR e IN get_exps
      LOOP
         l_ss_start := 1;
         l_ed_start := 1;
         l_new_expr_disp := NULL;
         l_new_pexpr_disp := NULL;
         CONTINUE := TRUE;

         WHILE CONTINUE
         LOOP
            l_ss_end := INSTR (e.sql_select, '|', l_ss_start + 1);
            l_ed_end := INSTR (e.expr_disp, '|', l_ed_start + 1);

            IF l_ss_end = 0
            THEN
               CONTINUE := FALSE;
            ELSE
               l_ss_seg := SUBSTR (e.sql_select, l_ss_start, l_ss_end - l_ss_start);
               l_ed_seg := SUBSTR (e.expr_disp, l_ed_start, l_ed_end - l_ed_start);

               IF     SUBSTR (l_ss_seg, 1, l_quota_id_len + 4) = '(' || p_quota_id || 'PE.'
                  AND SUBSTR (l_ed_seg, 1, l_quota_name_len + 1) = p_old_name || '.'
               THEN
                  l_new_expr_disp := l_new_expr_disp || p_new_name || SUBSTR (l_ed_seg, l_quota_name_len + 1);
                  l_new_pexpr_disp := l_new_pexpr_disp || p_new_name || SUBSTR (l_ed_seg, l_quota_name_len + 1) || '|';
               ELSE
                  l_new_expr_disp := l_new_expr_disp || l_ed_seg;
                  l_new_pexpr_disp := l_new_pexpr_disp || l_ed_seg || '|';
               END IF;
            END IF;

            l_ss_start := l_ss_end + 1;
            l_ed_start := l_ed_end + 1;
         END LOOP;

         -- update table
         UPDATE cn_calc_sql_exps
            SET expression_disp = l_new_expr_disp,
                piped_expression_disp = l_new_pexpr_disp
          WHERE calc_sql_exp_id = e.calc_sql_exp_id;
      END LOOP;
   END update_exprs;

--------------------------------------------------------------------

--------------------------------------------------------------------
   PROCEDURE validate_types (
      p_plan_element             IN       plan_element_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2
   )
   IS
      --l_api_name           CONSTANT VARCHAR2 (30) := 'Valid_Lookup_Code';
      l_tmp_exist                   NUMBER := 0;
      l_temp                        VARCHAR2 (1000) := NULL;
      l_plan_element            CN_CHK_PLAN_ELEMENT_PKG.pe_rec_type;
      l_lookup_type                 CN_LOOKUPS.lookup_type%TYPE;
   BEGIN
      -- set the Status
      x_return_status := fnd_api.g_ret_sts_success;
      l_lookup_type := '';
      -- Check/Valid quota_type_code
      IF p_plan_element.quota_type_code NOT IN ('EXTERNAL', 'FORMULA')
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', cn_chk_plan_element_pkg.g_element_type);
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check/Valid Incentive Type
      l_lookup_type := 'INCENTIVE_TYPE';
      SELECT COUNT (*)
        INTO l_tmp_exist
        FROM cn_lookups
       WHERE lookup_type = l_lookup_type
       AND lookup_code = p_plan_element.incentive_type_code;

      IF (l_tmp_exist = 0)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', cn_chk_plan_element_pkg.g_incentive_type_code);
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      l_lookup_type := 'PAYMENT_GROUP_CODE';
      SELECT COUNT (*)
        INTO l_tmp_exist
        FROM cn_lookups
       WHERE lookup_type = l_lookup_type
       AND lookup_code = p_plan_element.payment_group_code;

      IF (l_tmp_exist = 0)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('PAYMENT_GROUP', 'PE_OBJECT_TYPE'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      BEGIN
         SELECT lookup_code
           INTO l_temp
           FROM cn_lookups
          WHERE lookup_type = 'QUOTA_GROUP_CODE' AND lookup_code = p_plan_element.quota_group_code;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_DATA');
               fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('QUOTA_GROUP', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         WHEN OTHERS
         THEN
            RAISE fnd_api.g_exc_error;
      END;

      BEGIN
         SELECT lookup_code
           INTO l_temp
           FROM cn_lookups
          WHERE lookup_type = 'PLAN_ELEMENT_STATUS_TYPE' AND lookup_code = p_plan_element.quota_status;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_DATA');
               fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('STATUS', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         WHEN OTHERS
         THEN
            RAISE fnd_api.g_exc_error;
      END;

      -- Validate Indirect Credit
      l_lookup_type := 'INDIRECT_CREDIT_TYPE';
      SELECT COUNT (*)
        INTO l_tmp_exist
        FROM cn_lookups
       WHERE lookup_type = l_lookup_type
       AND lookup_code = p_plan_element.indirect_credit_code;

      IF (l_tmp_exist = 0)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('INDIRECT_CREDIT_TYPE', 'PE_OBJECT_TYPE'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- validate that the formula is okay
      IF (p_plan_element.calc_formula_id IS NOT NULL OR p_plan_element.quota_status <> g_new_status)
      THEN
         l_plan_element.quota_id := p_plan_element.quota_id;
         l_plan_element.name     := p_plan_element.name;
         l_plan_element.description := p_plan_element.description;
         l_plan_element.start_date := p_plan_element.start_date;
         l_plan_element.end_date := p_plan_element.end_date;
         l_plan_element.quota_status := p_plan_element.quota_status;
         l_plan_element.object_version_number := p_plan_element.object_version_number;
         l_plan_element.org_id := p_plan_element.org_id;
         l_plan_element.indirect_credit := p_plan_element.indirect_credit_code;
         l_plan_element.quota_type_code := p_plan_element.quota_type_code;
         l_plan_element.target := p_plan_element.target;
         l_plan_element.payment_amount       := p_plan_element.payment_amount;
         l_plan_element.performance_goal     := p_plan_element.performance_goal;
         l_plan_element.incentive_type_code  := p_plan_element.incentive_type_code;
         l_plan_element.credit_type_id       := p_plan_element.credit_type_id;
         l_plan_element.interval_type_id     := p_plan_element.calc_formula_id;
         l_plan_element.calc_formula_id      := p_plan_element.calc_formula_id;
         l_plan_element.vesting_flag         := p_plan_element.vesting_flag;
         l_plan_element.addup_from_rev_class_flag := p_plan_element.addup_from_rev_class_flag;
         l_plan_element.payee_assign_flag := p_plan_element.payee_assign_flag;
         l_plan_element.package_name := p_plan_element.package_name;

         cn_chk_plan_element_pkg.validate_formula (l_plan_element);
      END IF;

      --- the following are not validated on a new row
      IF (p_plan_element.credit_type_id IS NOT NULL)
      THEN
         SELECT COUNT (1)
           INTO l_tmp_exist
           FROM cn_credit_types
          WHERE credit_type_id = p_plan_element.credit_type_id AND org_id = p_plan_element.org_id;

         IF (l_tmp_exist = 0)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_DATA');
               fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('CREDIT_TYPE', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF (p_plan_element.interval_type_id IS NOT NULL)
      THEN
         SELECT COUNT (*)
           INTO l_tmp_exist
           FROM cn_interval_types
          WHERE interval_type_id = p_plan_element.interval_type_id AND org_id = p_plan_element.org_id;

         -- FROM:chk_pe_required  Check interval_type_id can not be missing or NULL
         IF (l_tmp_exist = 0)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_DATA');
               fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('PERIOD_TYPE', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- verify that the columns below are valid when not new
      IF p_plan_element.quota_status = cn_plan_element_pvt.g_new_status
      THEN
         RETURN;
      END IF;

      IF (p_plan_element.credit_type_id IS NULL)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('CREDIT_TYPE', 'PE_OBJECT_TYPE'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- FROM:chk_pe_required  Check interval_type_id can not be missing or NULL
      IF (p_plan_element.interval_type_id IS NULL)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('PERIOD_TYPE', 'PE_OBJECT_TYPE'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_plan_element.calc_formula_id IS NULL AND p_plan_element.quota_type_code = 'FORMULA')
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('FORMULA', 'QUOTA_TYPE'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;
   END validate_types;

   -- clku
   -- procedure that validates the Liability account ID and Expense Account ID.
   -- clku
   -- procedure that validates the Liability account ID and Expense Account ID.
   PROCEDURE check_ccids (
      p_account_type             IN       VARCHAR2,
      p_account_input            IN       VARCHAR2,
      x_ccid                     OUT NOCOPY NUMBER
   )
   IS
      kff                           fnd_flex_key_api.flexfield_type;
      str                           fnd_flex_key_api.structure_type;
      seg                           fnd_flex_key_api.segment_type;
      seg_list                      fnd_flex_key_api.segment_list;
      j                             NUMBER;
      i                             NUMBER;
      nsegs                         NUMBER;
      l_count                       NUMBER;
      l_ccid                        NUMBER;
      segment_descr                 VARCHAR2 (2000);
      sql_stmt                      VARCHAR2 (2000);
      where_stmt                    VARCHAR2 (2000);
      l_chart_of_accounts_id        gl_sets_of_books.chart_of_accounts_id%TYPE;
      ccid                          NUMBER;
      ccid_value                    VARCHAR2 (2000);
      l_account_type                gl_code_combinations.account_type%TYPE;

      TYPE curtype IS REF CURSOR;

      ccid_cur                      curtype;
   BEGIN
      SELECT chart_of_accounts_id
        INTO l_chart_of_accounts_id
        FROM gl_sets_of_books gsb,
             cn_repositories cr
       WHERE cr.set_of_books_id = gsb.set_of_books_id;

      fnd_flex_key_api.set_session_mode ('customer_data');
      kff := fnd_flex_key_api.find_flexfield ('SQLGL', 'GL#');
      str := fnd_flex_key_api.find_structure (kff, l_chart_of_accounts_id);
      fnd_flex_key_api.get_segments (kff, str, TRUE, nsegs, seg_list);
      --
      -- The segments in the seg_list array are sorted in display order.
      -- i.e. sorted by segment number.
      --
      sql_stmt := 'SELECT COUNT(*)';
      where_stmt := ' ';

      FOR i IN 1 .. nsegs
      LOOP
         seg := fnd_flex_key_api.find_segment (kff, str, seg_list (i));
         segment_descr := segment_descr || seg.segment_name;
         where_stmt := where_stmt || seg.column_name;

         IF i <> nsegs
         THEN
            segment_descr := segment_descr || str.segment_separator;
            where_stmt := where_stmt || '||''' || str.segment_separator || '''||';
         END IF;
      END LOOP;

      sql_stmt :=
            sql_stmt
         || ' FROM gl_code_combinations '
         ||
            -- Modified By Hithanki for Bug Fix : 2938387 05-May-2003
            -- ' WHERE chart_of_accounts_id = '||l_chart_of_accounts_id||
            ' WHERE chart_of_accounts_id = :1 '
         || ' AND enabled_flag = ''Y'''
         -- Modified By Hithanki for Bug Fhix : 2938387 05-May-2003
         -- || ' AND ' || where_stmt || ' = ''' || p_account_input || '''';
         || ' AND '
         || where_stmt
         || ' = :2 ';

      -- OPEN ccid_cur FOR sql_stmt;
      -- Modified By Hithanki for Bug Fix : 2938387 05-May-2003
      OPEN ccid_cur
       FOR sql_stmt USING l_chart_of_accounts_id, p_account_input;

      FETCH ccid_cur
       INTO l_count;

      CLOSE ccid_cur;

      IF (l_count = 0 AND p_account_type = 'L')
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            -- Need to define message 'CN_E_CANNOT_REF_ITSEF' in SEED115
            fnd_message.set_name ('CN', 'CN_INV_ACC_NO');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_count = 0 AND p_account_type = 'E')
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            -- Need to define message 'CN_E_CANNOT_REF_ITSEF' in SEED115
            fnd_message.set_name ('CN', 'CN_INV_ACC_NO');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      sql_stmt := 'SELECT code_combination_id';
      where_stmt := ' ';

      FOR i IN 1 .. nsegs
      LOOP
         seg := fnd_flex_key_api.find_segment (kff, str, seg_list (i));
         segment_descr := segment_descr || seg.segment_name;
         where_stmt := where_stmt || seg.column_name;

         IF i <> nsegs
         THEN
            segment_descr := segment_descr || str.segment_separator;
            where_stmt := where_stmt || '||''' || str.segment_separator || '''||';
         END IF;
      END LOOP;

      sql_stmt :=
            sql_stmt
         || ' FROM gl_code_combinations '
         ||
            -- Modified By Hithanki for Bug Fix : 2938387 05-May-2003
            -- ' WHERE chart_of_accounts_id = '||l_chart_of_accounts_id||
            ' WHERE chart_of_accounts_id = :1 '
         || ' AND enabled_flag = ''Y'''
         -- Modified By Hithanki for Bug Fix : 2938387 05-May-2003
         -- || ' AND ' || where_stmt || ' = ''' || p_account_input || '''';
         || ' AND '
         || where_stmt
         || ' = :2 ';

      -- OPEN ccid_cur FOR sql_stmt;
      -- Modified By Hithanki for Bug Fix : 2938387 05-May-2003
      OPEN ccid_cur
       FOR sql_stmt USING l_chart_of_accounts_id, p_account_input;

      FETCH ccid_cur
       INTO l_ccid;

      CLOSE ccid_cur;

      x_ccid := l_ccid;
   END check_ccids;

   /*
    *  Get the account id given the code combination
    */
   PROCEDURE validate_and_update_ccids (
      p_plan_element             IN OUT NOCOPY plan_element_rec_type
   )
   IS
      l_id                          NUMBER;
   BEGIN
      --clku
      -- validate the code combination and get the ccid only if the ccid is NULL
      -- For Liability Account
      IF (p_plan_element.liability_account_id IS NULL)
      THEN
         IF (p_plan_element.liability_account_cc IS NOT NULL)
         THEN
            check_ccids (p_account_type       => 'L', p_account_input => p_plan_element.liability_account_cc,
                         x_ccid               => p_plan_element.liability_account_id);
         END IF;
      ELSE
         BEGIN
            SELECT code_combination_id
              INTO l_id
              FROM gl_code_combinations
             WHERE code_combination_id = p_plan_element.liability_account_id AND account_type = 'L';
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_IMP_INVLD_LIABLTY_CODE');
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
         END;
      END IF;

      --clku
       -- validate the code combination and get the ccid only if the ccid is NULL
       -- For Expense Account
      IF (p_plan_element.expense_account_id IS NULL)
      THEN
         IF (p_plan_element.expense_account_cc IS NOT NULL)
         THEN
            check_ccids (p_account_type => 'E', p_account_input => p_plan_element.expense_account_cc, x_ccid => p_plan_element.expense_account_id);
         END IF;
      ELSE
         BEGIN
            SELECT code_combination_id
              INTO l_id
              FROM gl_code_combinations
             WHERE code_combination_id = p_plan_element.expense_account_id AND account_type = 'E';
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_IMP_INVLD_EXPENS_CODE');
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
         END;
      END IF;
   END validate_and_update_ccids;

   -- Start of comments
   --    API name        : Create_Plan_Element
   --    Type            : Private.
   --    Function        :
   --    Pre-reqs        : None.
   --    Parameters      :
   --    IN              : p_api_version         IN NUMBER       Required
   --                      p_init_msg_list       IN VARCHAR2     Optional
   --                        Default = FND_API.G_FALSE
   --                      p_commit              IN VARCHAR2     Optional
   --                        Default = FND_API.G_FALSE
   --                      p_validation_level    IN NUMBER       Optional
   --                        Default = FND_API.G_VALID_LEVEL_FULL
   --                      p_plan_element        IN  plan_element_rec_type
   --    OUT             : x_return_status       OUT     VARCHAR2(1)
   --                      x_msg_count           OUT     NUMBER
   --                      x_msg_data            OUT     VARCHAR2(2000)
   --                      x_plan_element_id        OUT     NUMBER
   --    Version :         Current version       1.0
   --    Notes           : Note text
   --
   -- End of comments
   PROCEDURE create_plan_element (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_plan_element             IN OUT NOCOPY plan_element_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Plan_Element';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_temp_count                  NUMBER;
      l_loading_status              VARCHAR2 (50);
      l_credit_type_name            cn_credit_types.NAME%TYPE := NULL;
      l_calc_formula_name           cn_calc_formulas.NAME%TYPE := NULL;
      l_interval_type_name          cn_interval_types.NAME%TYPE := NULL;
      l_formula_type                cn_calc_formulas.formula_type%TYPE := NULL;
      g_last_update_date            DATE := SYSDATE;
      g_last_updated_by             NUMBER := fnd_global.user_id;
      g_creation_date               DATE := SYSDATE;
      g_created_by                  NUMBER := fnd_global.user_id;
      g_last_update_login           NUMBER := fnd_global.login_id;
      g_remove_this                 VARCHAR2 (1) := '#';
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_plan_element;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- API body
      IF p_plan_element.quota_id IS NULL
      THEN
         SELECT cn_quotas_s.NEXTVAL
           INTO p_plan_element.quota_id
           FROM DUAL;
      END IF;

      -- validate plan element
      validate_plan_element (p_api_version        => p_api_version,
                             p_plan_element       => p_plan_element,
                             p_action             => 'CREATE',
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data
                            );

      -- raise an error if validate was not successful
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- update the account ids the UIs give a concatenated code
      validate_and_update_ccids (p_plan_element);
      -- update the table
      cn_quotas_pkg.begin_record (x_operation                      => 'INSERT',
                                  x_rowid                          => g_remove_this,
                                  x_quota_id                       => p_plan_element.quota_id,
                                  x_object_version_number          => p_plan_element.object_version_number,
                                  x_name                           => p_plan_element.NAME,
                                  x_target                         => NVL (p_plan_element.target, 0),
                                  x_quota_type_code                => p_plan_element.quota_type_code,
                                  x_usage_code                     => NULL,
                                  x_payment_amount                 => NVL (p_plan_element.payment_amount, 0),
                                  x_description                    => p_plan_element.description,
                                  x_start_date                     => p_plan_element.start_date,
                                  x_end_date                       => p_plan_element.end_date,
                                  x_quota_status                   => p_plan_element.quota_status,
                                  x_calc_formula_id                => p_plan_element.calc_formula_id,
                                  x_incentive_type_code            => p_plan_element.incentive_type_code,
                                  x_credit_type_id                 => p_plan_element.credit_type_id,
                                  x_rt_sched_custom_flag           => NULL,
                                  x_package_name                   => p_plan_element.package_name,
                                  x_performance_goal               => NVL (p_plan_element.performance_goal, 0),
                                  x_interval_type_id               => p_plan_element.interval_type_id,
                                  x_payee_assign_flag              => p_plan_element.payee_assign_flag,
                                  x_vesting_flag                   => p_plan_element.vesting_flag,
                                  x_expense_account_id             => p_plan_element.expense_account_id,
                                  x_liability_account_id           => p_plan_element.liability_account_id,
                                  x_quota_group_code               => p_plan_element.quota_group_code,
                                  --clku PAYMENT ENHANCEMENT
                                  x_payment_group_code             => p_plan_element.payment_group_code,
                                  x_quota_unspecified              => NULL,
                                  x_last_update_date               => g_last_update_date,
                                  x_last_updated_by                => g_last_updated_by,
                                  x_creation_date                  => g_creation_date,
                                  x_created_by                     => g_created_by,
                                  x_last_update_login              => g_last_update_login,
                                  x_program_type                   => NULL,
                                  --x_status_code                   => NULL,
                                  x_period_type_code               => NULL,
                                  x_start_num                      => NULL,
                                  x_end_num                        => NULL,
                                  x_addup_from_rev_class_flag      => p_plan_element.addup_from_rev_class_flag,
                                  x_attribute_category             => p_plan_element.attribute_category,
                                  x_attribute1                     => p_plan_element.attribute1,
                                  x_attribute2                     => p_plan_element.attribute2,
                                  x_attribute3                     => p_plan_element.attribute3,
                                  x_attribute4                     => p_plan_element.attribute4,
                                  x_attribute5                     => p_plan_element.attribute5,
                                  x_attribute6                     => p_plan_element.attribute6,
                                  x_attribute7                     => p_plan_element.attribute7,
                                  x_attribute8                     => p_plan_element.attribute8,
                                  x_attribute9                     => p_plan_element.attribute9,
                                  x_attribute10                    => p_plan_element.attribute10,
                                  x_attribute11                    => p_plan_element.attribute11,
                                  x_attribute12                    => p_plan_element.attribute12,
                                  x_attribute13                    => p_plan_element.attribute13,
                                  x_attribute14                    => p_plan_element.attribute14,
                                  x_attribute15                    => p_plan_element.attribute15,
                                  x_indirect_credit                => p_plan_element.indirect_credit_code,
                                  x_org_id                         => p_plan_element.org_id,
                                  x_salesrep_end_flag              => p_plan_element.sreps_enddated_flag
                                 );
      -- Record inserted successfully
      -- insert the periods given that we always have a start and end date
      cn_period_quotas_pkg.distribute_target (p_plan_element.quota_id);

      IF p_plan_element.quota_status <> cn_plan_element_pvt.g_new_status
      THEN
         -- Call the Rate_quotas Procedure to create rate quota Assigns
         cn_rt_quota_asgns_pkg.INSERT_RECORD (x_quota_id => p_plan_element.quota_id, x_calc_formula_id => p_plan_element.calc_formula_id);
      END IF;

      -- Raise an Error if the Status is Failedx
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      -- Calling proc to add system note for create
      add_system_note(
            p_plan_element,
            p_plan_element,
            'create',
            x_return_status,
            x_msg_count,
            x_msg_data
            );
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_plan_element;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_plan_element;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_plan_element;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END create_plan_element;

-- Start of comments
--      API name        : Update_Plan_Element
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_plan_element      IN plan_element_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_plan_element (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_plan_element             IN OUT NOCOPY plan_element_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR l_old_plan_element_cr (
         qid                                 NUMBER
      )
      IS
         SELECT pe.quota_id,
                pe.NAME,
                pe.description,
                pe.quota_type_code,
                pe.target,
                pe.payment_amount,
                pe.performance_goal,
                pe.incentive_type_code,
                pe.start_date,
                pe.end_date,
                pe.credit_type_id,
                pe.interval_type_id,
                pe.calc_formula_id,
                pe.liability_account_id,
                pe.expense_account_id,
                'liability_account_cc',
                'expense_account_cc',
                pe.vesting_flag,
                pe.quota_group_code,
                pe.payment_group_code,
                pe.attribute_category,
                pe.attribute1,
                pe.attribute2,
                pe.attribute3,
                pe.attribute4,
                pe.attribute5,
                pe.attribute6,
                pe.attribute7,
                pe.attribute8,
                pe.attribute9,
                pe.attribute10,
                pe.attribute11,
                pe.attribute12,
                pe.attribute13,
                pe.attribute14,
                pe.attribute15,
                pe.addup_from_rev_class_flag,
                pe.payee_assign_flag,
                pe.package_name,
                pe.object_version_number,
                pe.org_id,
                pe.indirect_credit,
                pe.quota_status,
                pe.salesreps_enddated_flag,
                NULL
           FROM cn_quotas_v pe
          WHERE pe.quota_id = qid;

      CURSOR get_number_dim (
         l_quota_id                          NUMBER
      )
      IS
         SELECT ccf.number_dim
           FROM cn_quotas_v cq,
                cn_calc_formulas ccf
          WHERE cq.quota_id = l_quota_id AND cq.calc_formula_id = ccf.calc_formula_id;

      CURSOR c_srp_period_quota_csr (
         pe_quota_id                         cn_quotas.quota_id%TYPE
      )
      IS
         SELECT srp_period_quota_id
           FROM cn_srp_period_quotas
          WHERE quota_id = pe_quota_id;

      g_last_update_date            DATE := SYSDATE;
      g_last_updated_by             NUMBER := fnd_global.user_id;
      g_creation_date               DATE := SYSDATE;
      g_created_by                  NUMBER := fnd_global.user_id;
      g_last_update_login           NUMBER := fnd_global.login_id;
      g_row_id                      NUMBER;
      l_old_plan_element            plan_element_rec_type;
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Plan_Element';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_ccid                        NUMBER (15);
      l_la_ccid                     NUMBER (15);
      l_ea_ccid                     NUMBER (15);
      l_payeechk                    NUMBER;
      l_credit_type_name            cn_credit_types.NAME%TYPE := NULL;
      l_calc_formula_name           cn_calc_formulas.NAME%TYPE := NULL;
      l_interval_type_name          cn_interval_types.NAME%TYPE := NULL;
      l_formula_type                cn_calc_formulas.formula_type%TYPE := NULL;
      l_number_dim_old              NUMBER;
      l_number_dim_new              NUMBER;
      l_number_dim                  NUMBER;
      s_tot_target                  NUMBER;
      s_tot_payment_amount          NUMBER;
      s_tot_performance_goal        NUMBER;
      l_loading_status              VARCHAR2 (100);
      x_loading_status              VARCHAR (100);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_plan_element;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      l_old_plan_element := get_plan_element (p_plan_element.quota_id);
      -- validate the plan element
      validate_plan_element (p_api_version           => p_api_version,
                             p_plan_element          => p_plan_element,
                             p_old_plan_element      => l_old_plan_element,
                             p_action                => 'UPDATE',
                             x_return_status         => x_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data
                            );

      -- in case of error, raise exception
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

         -- Check the Plan Element start date and end date fall with in the rt_formula_asgns
         IF p_plan_element.calc_formula_id IS NOT NULL
         THEN
            IF p_plan_element.calc_formula_id = l_old_plan_element.calc_formula_id
            THEN
               cn_chk_plan_element_pkg.chk_rate_quota_date (x_return_status       => x_return_status,
                                                            p_start_date          => p_plan_element.start_date,
                                                            p_end_date            => p_plan_element.end_date,
                                                            p_quota_name          => p_plan_element.NAME,
                                                            p_quota_id            => p_plan_element.quota_id,
                                                            p_loading_status      => x_loading_status,
                                                            x_loading_status      => l_loading_status
                                                           );
               x_loading_status := l_loading_status;
            END IF;

            -- error if the status is not success
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;


      -- 4. Select the Target, Fixed Amount and Goal
      IF p_plan_element.addup_from_rev_class_flag = 'Y'
      THEN
         SELECT SUM (target)
           INTO p_plan_element.target
           FROM cn_quota_rules
          WHERE quota_id = p_plan_element.quota_id;

         SELECT SUM (payment_amount)
           INTO p_plan_element.payment_amount
           FROM cn_quota_rules
          WHERE quota_id = p_plan_element.quota_id;

         SELECT SUM (performance_goal)
           INTO p_plan_element.performance_goal
           FROM cn_quota_rules
          WHERE quota_id = p_plan_element.quota_id;
      END IF;

      -- update the accounts data
      validate_and_update_ccids (p_plan_element);

      -- call the table handler
      cn_quotas_pkg.begin_record (x_operation                      => 'UPDATE',
                                  x_rowid                          => g_row_id,
                                  x_quota_id                       => p_plan_element.quota_id,
                                  x_object_version_number          => p_plan_element.object_version_number,
                                  x_name                           => p_plan_element.NAME,
                                  x_target                         => NVL (p_plan_element.target, 0),
                                  x_quota_type_code                => p_plan_element.quota_type_code,
                                  x_usage_code                     => NULL,
                                  x_payment_amount                 => NVL (p_plan_element.payment_amount, 0),
                                  x_description                    => p_plan_element.description,
                                  x_start_date                     => p_plan_element.start_date,
                                  x_end_date                       => p_plan_element.end_date,
                                  x_quota_status                   => p_plan_element.quota_status,
                                  x_calc_formula_id                => p_plan_element.calc_formula_id,
                                  x_incentive_type_code            => p_plan_element.incentive_type_code,
                                  x_credit_type_id                 => p_plan_element.credit_type_id,
                                  x_rt_sched_custom_flag           => NULL,
                                  x_package_name                   => p_plan_element.package_name,
                                  x_performance_goal               => NVL (p_plan_element.performance_goal, 0),
                                  x_interval_type_id               => p_plan_element.interval_type_id,
                                  x_payee_assign_flag              => p_plan_element.payee_assign_flag,
                                  x_vesting_flag                   => p_plan_element.vesting_flag,
                                  x_expense_account_id             => p_plan_element.expense_account_id,
                                  x_liability_account_id           => p_plan_element.liability_account_id,
                                  x_quota_group_code               => p_plan_element.quota_group_code,
                                  x_payment_group_code             => p_plan_element.payment_group_code,
                                  x_quota_unspecified              => NULL,
                                  x_last_update_date               => g_last_update_date,
                                  x_last_updated_by                => g_last_updated_by,
                                  x_creation_date                  => NULL,
                                  x_created_by                     => NULL,
                                  x_last_update_login              => g_last_update_login,
                                  x_program_type                   => NULL,
                                  --x_status_code                   => p_plan_element.quota_status,
                                  x_period_type_code               => NULL,
                                  x_start_num                      => NULL,
                                  x_end_num                        => NULL,
                                  x_addup_from_rev_class_flag      => p_plan_element.addup_from_rev_class_flag,
                                  x_attribute_category             => p_plan_element.attribute_category,
                                  x_attribute1                     => p_plan_element.attribute1,
                                  x_attribute2                     => p_plan_element.attribute2,
                                  x_attribute3                     => p_plan_element.attribute3,
                                  x_attribute4                     => p_plan_element.attribute4,
                                  x_attribute5                     => p_plan_element.attribute5,
                                  x_attribute6                     => p_plan_element.attribute6,
                                  x_attribute7                     => p_plan_element.attribute7,
                                  x_attribute8                     => p_plan_element.attribute8,
                                  x_attribute9                     => p_plan_element.attribute9,
                                  x_attribute10                    => p_plan_element.attribute10,
                                  x_attribute11                    => p_plan_element.attribute11,
                                  x_attribute12                    => p_plan_element.attribute12,
                                  x_attribute13                    => p_plan_element.attribute13,
                                  x_attribute14                    => p_plan_element.attribute14,
                                  x_attribute15                    => p_plan_element.attribute15,
                                  x_indirect_credit                => p_plan_element.indirect_credit_code,
                                  x_org_id                         => p_plan_element.org_id,
                                  x_salesrep_end_flag              =>p_plan_element.sreps_enddated_flag
                                 );

      -- update expressions using this plan element
      IF (p_plan_element.NAME <> l_old_plan_element.NAME)
      THEN
         update_exprs (p_plan_element.quota_id, l_old_plan_element.NAME, p_plan_element.NAME);
      END IF;
-- Commented out for Bug 4722521------------------------------------------------
      -- delete period quotas and distribute them again
      IF    l_old_plan_element.start_date <> p_plan_element.start_date
         OR NVL (p_plan_element.end_date, fnd_api.g_miss_date)
         <> NVL (l_old_plan_element.end_date, fnd_api.g_miss_date)
      THEN
         -- Call the Table Handler to Delete the Old Period quotas
--         cn_period_quotas_pkg.DELETE_RECORD (p_plan_element.quota_id);
         cn_period_quotas_pkg.distribute_target (p_plan_element.quota_id);
      END IF;
-- Commented out for Bug 4722521------------------------------------------------
      -- check if we need to update the cn_srp_period_quotas ext table. If yes, update the table
      -- if the new assignement is external package, we do not do anything
      IF p_plan_element.quota_type_code <> 'EXTERNAL'
      THEN
         -- if the old assignement is external package, we wipe out the ext table and re-insert the record
         IF l_old_plan_element.quota_type_code = 'EXTERNAL'
         THEN
            OPEN get_number_dim (l_old_plan_element.quota_id);

            FETCH get_number_dim
             INTO l_number_dim;

            CLOSE get_number_dim;

            IF l_number_dim > 1
            THEN
               FOR l_srp_period_quota_id IN c_srp_period_quota_csr (l_old_plan_element.quota_id)
               LOOP
                  cn_srp_period_quotas_pkg.populate_srp_period_quotas_ext ('DELETE',
                                                                           l_srp_period_quota_id.srp_period_quota_id,
                                                                           l_old_plan_element.org_id
                                                                          );
               END LOOP;

               FOR l_srp_period_quota_id IN c_srp_period_quota_csr (l_old_plan_element.quota_id)
               LOOP
                  cn_srp_period_quotas_pkg.populate_srp_period_quotas_ext ('INSERT',
                                                                           l_srp_period_quota_id.srp_period_quota_id,
                                                                           l_old_plan_element.org_id,
                                                                           l_number_dim
                                                                          );
               END LOOP;
            END IF;
         ELSIF p_plan_element.calc_formula_id <> l_old_plan_element.calc_formula_id
         THEN
            SELECT number_dim
              INTO l_number_dim_old
              FROM cn_calc_formulas
             WHERE calc_formula_id = l_old_plan_element.calc_formula_id;

            SELECT number_dim
              INTO l_number_dim_new
              FROM cn_calc_formulas
             WHERE calc_formula_id = p_plan_element.calc_formula_id;

            IF l_number_dim_new <> l_number_dim_old
            THEN
               IF l_number_dim_new < l_number_dim_old
               THEN
                  FOR l_srp_period_quota_id IN c_srp_period_quota_csr (l_old_plan_element.quota_id)
                  LOOP
                     cn_srp_period_quotas_pkg.populate_srp_period_quotas_ext ('DELETE',
                                                                              l_srp_period_quota_id.srp_period_quota_id,
                                                                              l_old_plan_element.org_id
                                                                             );
                  END LOOP;
               END IF;

               -- if reduce # dims to 1, then no longer need _ext records
               IF l_number_dim_new > 1
               THEN
                  FOR l_srp_period_quota_id IN c_srp_period_quota_csr (l_old_plan_element.quota_id)
                  LOOP
                     cn_srp_period_quotas_pkg.populate_srp_period_quotas_ext ('INSERT',
                                                                              l_srp_period_quota_id.srp_period_quota_id,
                                                                              l_old_plan_element.org_id,
                                                                              l_number_dim_new
                                                                             );
                  END LOOP;
               END IF;
            END IF;
         END IF;
      END IF;

      -- if necessary attach the default rate tables from the formula
      update_rate_quotas (p_api_version                 => p_api_version,
                          p_init_msg_list               => p_init_msg_list,
                          p_commit                      => p_commit,
                          p_validation_level            => p_validation_level,
                          x_return_status               => x_return_status,
                          x_msg_count                   => x_msg_count,
                          x_msg_data                    => x_msg_data,
                          p_pe_rec                      => p_plan_element,
                          p_pe_rec_old                  => l_old_plan_element,
                          p_rt_quota_asgns_rec_tbl      => g_miss_rt_quota_asgns_rec_tbl,
                          p_quota_name                  => p_plan_element.NAME,
                          p_loading_status              => x_loading_status,
                          x_loading_status              => l_loading_status
                         );
      x_loading_status := l_loading_status;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Calling proc to add system note for update
      add_system_note(
            l_old_plan_element,
            p_plan_element,
            'update',
            x_return_status,
            x_msg_count,
            x_msg_data
            );
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_plan_element;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_plan_element;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_plan_element;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_plan_element;

-- Start of comments
--      API name        : Delete_Plan_Element
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_plan_element       IN plan_element_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_plan_element (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_plan_element             IN OUT NOCOPY plan_element_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Plan_Element';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_quota_name                  cn_quotas.NAME%TYPE;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_plan_element;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- validate plan element
      validate_plan_element (p_api_version        => p_api_version,
                             p_plan_element       => p_plan_element,
                             p_action             => 'DELETE',
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data
                            );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- API body
      SELECT NAME
        INTO l_quota_name
        FROM cn_quotas_v
       WHERE quota_id = p_plan_element.quota_id;

      -- Call the Delete Record Table Handler
      cn_quotas_pkg.DELETE_RECORD (x_quota_id => p_plan_element.quota_id, x_name => l_quota_name);

      -- Calling proc to add system note for delete
      add_system_note(
            p_plan_element,
            p_plan_element,
            'delete',
            x_return_status,
            x_msg_count,
            x_msg_data
            );
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO delete_plan_element;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_plan_element;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_plan_element;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END delete_plan_element;

-- Start of comments
--      API name        : Validate_Plan_Element
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_plan_element       IN plan_element_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE validate_plan_element (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_action                   IN       VARCHAR2,
      p_plan_element             IN OUT NOCOPY plan_element_rec_type,
      p_old_plan_element         IN       plan_element_rec_type := NULL,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS

	--Added by hanaraya for bug 6505174
	CURSOR uplift_curs(p_quota_id cn_quotas.quota_id%TYPE, p_start_date cn_quotas.start_date%TYPE, p_end_date cn_quotas.end_date%TYPE)
	IS
         SELECT COUNT (1)
           FROM cn_quota_rule_uplifts qru,
                cn_quota_rules qr
          WHERE qr.quota_id = p_quota_id
            AND qr.quota_rule_id = qru.quota_rule_id
            AND (qru.start_date < p_start_date OR (p_end_date IS NOT NULL AND qru.end_date IS NULL) OR qru.end_date > p_end_date);

      l_api_name           CONSTANT VARCHAR2 (30) := 'Validate_Plan_Element';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_formula_type                cn_calc_formulas.formula_type%TYPE := NULL;
      l_temp_count                  NUMBER;
      l_quota_id                    NUMBER;
      l_payeechk                    NUMBER;
      l_uplift_dt_range             NUMBER; --Added by hanaraya for bug 6505174
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_plan_element;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      p_plan_element.start_date := TRUNC (p_plan_element.start_date);
      p_plan_element.end_date := TRUNC (p_plan_element.end_date);


      -- API body
      IF (p_action = 'DELETE')
      THEN
         SELECT COUNT (*)
           INTO l_temp_count
           FROM cn_quotas_v
          WHERE quota_id = p_plan_element.quota_id;

         IF l_temp_count = 0
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_DEL_REC');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         -- check whether the plan element is already assigned to a complan
         BEGIN
            SELECT 1
              INTO l_temp_count
              FROM SYS.DUAL
             WHERE NOT EXISTS (SELECT 1
                                 FROM cn_quota_assigns
                                WHERE quota_id = p_plan_element.quota_id);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'PLN_QUOTA_DELETE_NA');
                  fnd_msg_pub.ADD;
               END IF;
               RAISE fnd_api.g_exc_error;
         END;
      ELSE
         -- check whether user has access to this org
         IF (p_action = 'UPDATE')
         THEN
            -- better check that org_id first or you will cry
            IF NOT is_valid_org (p_plan_element.org_id, p_plan_element.quota_id)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            -- 1. check object version number
            IF p_old_plan_element.object_version_number <> p_plan_element.object_version_number
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
            END IF;

            -- 2. plan element name must be unique
            SELECT COUNT (1)
              INTO l_temp_count
              FROM cn_quotas_all pe
             WHERE NAME = p_plan_element.NAME AND p_plan_element.quota_id <> pe.quota_id AND p_plan_element.org_id = pe.org_id AND delete_flag = 'N';

            IF l_temp_count <> 0
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_INPUT_MUST_UNIQUE');
                  fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('PE_NAME', 'INPUT_TOKEN'));
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
            END IF;

	    --Added by hanaraya for bug 6505174
	    -- Check for date range overlap between plan element and quota rule uplifts

            OPEN uplift_curs(p_plan_element.quota_id, p_plan_element.start_date, p_plan_element.end_date);

            FETCH uplift_curs
            INTO l_uplift_dt_range;

            CLOSE uplift_curs;

            IF l_uplift_dt_range > 0
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_UPLIFT_DT_NOT_WIN_QUOTA');
                  fnd_msg_pub.ADD;
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;

         ELSIF (p_action = 'CREATE')
         THEN
            -- better check that org_id first or you will cry
            IF NOT is_valid_org (p_plan_element.org_id)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            -- 2. plan element name must be unique
            SELECT COUNT (1)
              INTO l_temp_count
              FROM cn_quotas_all pe
             WHERE NAME = p_plan_element.NAME AND org_id = p_plan_element.org_id AND delete_flag = 'N';

            IF l_temp_count <> 0
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_INPUT_MUST_UNIQUE');
                  fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('PE_NAME', 'INPUT_TOKEN'));
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

--###########################################################################
--## VALIDATION FOR BOTH UPDATE AND CREATE
--###########################################################################

         -- 1. name can not be null
         IF (p_plan_element.NAME IS NULL) OR (p_plan_element.NAME = fnd_api.g_miss_char)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
               fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('PE_NAME', 'INPUT_TOKEN'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         -- start date is not null
         IF (p_plan_element.start_date IS NULL) OR (p_plan_element.start_date = fnd_api.g_miss_date)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
               fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('SD', 'INPUT_TOKEN'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         -- start date > end date
         IF (p_plan_element.end_date IS NOT NULL) AND (p_plan_element.start_date > p_plan_element.end_date)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_DATE_RANGE_ERROR');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;



----------------------------------------------------
   -- Validate All lookup codes, must have valid value
   ----------------------------------------------------
         validate_types (p_plan_element => p_plan_element, x_return_status => x_return_status);



         IF (p_plan_element.target IS NULL)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
               fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('VARIABLE(S)', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_plan_element.payment_amount IS NULL)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
               fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('VARIABLE(S)', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_plan_element.performance_goal IS NULL)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
               fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('VARIABLE(S)', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_plan_element.payee_assign_flag NOT IN ('Y', 'N'))
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_DATA');
               fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('PAYEE_ASSIGN', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_plan_element.addup_from_rev_class_flag NOT IN ('Y', 'N')
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_DATA');
               fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('ADD_FROM_REVCLASS', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;


         ---changes made for fixing the bug # 2739896
         IF p_plan_element.payee_assign_flag = 'Y'
         THEN
            SELECT COUNT (*)
              INTO l_payeechk
              FROM cn_quota_assigns cqa
             WHERE cqa.quota_id = p_plan_element.quota_id
               AND EXISTS (SELECT 1
                             FROM cn_srp_plan_assigns cspa
                            WHERE cspa.comp_plan_id = cqa.comp_plan_id AND EXISTS (SELECT 1
                                                                                     FROM cn_srp_roles csr
                                                                                    WHERE csr.salesrep_id = cspa.salesrep_id AND csr.role_id = 54));

            IF (l_payeechk > 0)
            THEN
               fnd_message.set_name ('CN', 'CN_PAYEE_ASGN_FLAG_CHECK');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;                                                                                                              -- END OF DELETE VALIDATION

      -- End of API body.
      <<end_api_body>>
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO validate_plan_element;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO validate_plan_element;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO validate_plan_element;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END validate_plan_element;

-- Start of comments
--      API name        : Duplicate_Plan_Element
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
   PROCEDURE duplicate_plan_element (
      p_api_version              IN       NUMBER := cn_api.g_miss_num,
      p_init_msg_list            IN       VARCHAR2 := cn_api.g_false,
      p_commit                   IN       VARCHAR2 := cn_api.g_false,
      p_validation_level         IN       NUMBER := cn_api.g_valid_level_full,
      p_quota_id                 IN       cn_quotas.quota_id%TYPE := NULL,
      x_plan_element             OUT NOCOPY plan_element_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
   BEGIN
      NULL;
   END duplicate_plan_element;

   PROCEDURE check_rate_dim (
      p_quota_id                 IN       NUMBER
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'check_rate_dim';
      l_same_pe                     NUMBER;

      CURSOR c_rate_schedule_csr (
         pe_quota_id                         cn_quotas.quota_id%TYPE
      )
      IS
         SELECT qa.rate_schedule_id
           FROM cn_rt_quota_asgns qa
          WHERE qa.quota_id = pe_quota_id;

      CURSOR c_rt_formula_csr (
         pe_quota_id                         cn_quotas.quota_id%TYPE,
         pe_rate_schedule_id                 cn_rt_quota_asgns.rate_schedule_id%TYPE
      )
      IS
         SELECT rtq.calc_formula_id
           FROM cn_rt_quota_asgns rtq
          WHERE rtq.quota_id = pe_quota_id AND rtq.rate_schedule_id = pe_rate_schedule_id;

      CURSOR c_formula_input_csr (
         pe_calc_formula_id                  cn_formula_inputs.calc_formula_id%TYPE
      )
      IS
         SELECT fi.formula_input_id
           FROM cn_formula_inputs fi
          WHERE fi.calc_formula_id = pe_calc_formula_id;

      l_cumulative_flag             cn_formula_inputs.cumulative_flag%TYPE;
      l_split_flag                  cn_formula_inputs.split_flag%TYPE;
      l_rate_dim_sequence           cn_formula_inputs.rate_dim_sequence%TYPE;
      l_dim_unit_code               cn_rate_dimensions.dim_unit_code%TYPE;
      l_quota_name                  cn_quotas.NAME%TYPE;
   BEGIN
      --  Initialize API return status to success
      FOR l_rate_schedule_id IN c_rate_schedule_csr (p_quota_id)
      LOOP
         FOR l_calc_formula_id IN c_rt_formula_csr (p_quota_id, l_rate_schedule_id.rate_schedule_id)
         LOOP
            FOR l_formula_input_id IN c_formula_input_csr (l_calc_formula_id.calc_formula_id)
            LOOP
               SELECT cumulative_flag,
                      split_flag,
                      rate_dim_sequence
                 INTO l_cumulative_flag,
                      l_split_flag,
                      l_rate_dim_sequence
                 FROM cn_formula_inputs
                WHERE formula_input_id = l_formula_input_id.formula_input_id;

               IF (l_cumulative_flag = 'Y') OR (l_split_flag = 'Y')
               THEN
                  SELECT cd.dim_unit_code
                    INTO l_dim_unit_code
                    FROM cn_rate_dimensions cd,
                         cn_rate_sch_dims cs
                   WHERE cs.rate_dim_sequence = l_rate_dim_sequence
                     AND cs.rate_schedule_id = l_rate_schedule_id.rate_schedule_id
                     AND cd.rate_dimension_id = cs.rate_dimension_id;

                  -- clku bug 2426405
                  IF (l_dim_unit_code <> 'PERCENT') AND (l_dim_unit_code <> 'AMOUNT') AND (l_dim_unit_code <> 'EXPRESSION')
                  THEN
                     SELECT NAME
                       INTO l_quota_name
                       FROM cn_quotas
                      WHERE quota_id = p_quota_id;

                     cn_message_pkg.set_message (appl_short_name      => 'CN',
                                                 message_name         => 'CN_RATE_DIM_MUST_NUMERIC',
                                                 token_name1          => 'QUOTA_NAME',
                                                 token_value1         => l_quota_name,
                                                 token_name2          => NULL,
                                                 token_value2         => NULL,
                                                 token_name3          => NULL,
                                                 token_value3         => NULL,
                                                 token_name4          => NULL,
                                                 token_value4         => NULL,
                                                 TRANSLATE            => TRUE
                                                );
                     fnd_msg_pub.ADD;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;
      END LOOP;
   END check_rate_dim;

-- Check that the plan element is valid
   PROCEDURE validate_plan_element (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_comp_plan_id             IN       NUMBER := NULL,
      p_quota_id                 IN       NUMBER,
      x_status_code              OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR rt_quota_asgns_curs
      IS
         SELECT rqa.rate_schedule_id,
                rs.NAME
           FROM cn_rt_quota_asgns rqa,
                cn_rate_schedules rs
          WHERE rqa.quota_id = p_quota_id AND rqa.rate_schedule_id = rs.rate_schedule_id;

      CURSOR rules
      IS
         SELECT qr.quota_rule_id,
                qr.revenue_class_id,
                rc.NAME rev_class_name,
                q.quota_type_code
           FROM cn_quotas q,
                cn_quota_rules_all qr,
                cn_revenue_classes_all rc
          WHERE qr.quota_id = p_quota_id
            AND qr.revenue_class_id = rc.revenue_class_id
            AND q.quota_id = qr.quota_id
            AND q.quota_type_code IN ('FORMULA', 'EXTERNAL');

      CURSOR factors (
         p_quota_rule_id                     NUMBER
      )
      IS
         SELECT event_factor,
                trx_type
           FROM cn_trx_factors
          WHERE quota_rule_id = p_quota_rule_id;

      l_api_name           CONSTANT VARCHAR2 (30) := 'Validate_Plan_Element';
      l_api_version        CONSTANT NUMBER := 1.0;
      factor_rec                    factors%ROWTYPE;
      key_factor_total              NUMBER := 0;
      rule_rec                      rules%ROWTYPE;
      recinfo                       rt_quota_asgns_curs%ROWTYPE;
      x_formula_name                cn_calc_formulas.NAME%TYPE;
      x_calc_formula_id             cn_calc_formulas.calc_formula_id%TYPE;
      l_tmp                         NUMBER;
      l_plan_name                   cn_comp_plans.NAME%TYPE;
      l_plan_element                plan_element_rec_type;
      g_incomplete                  VARCHAR2 (30) := 'INCOMPLETE';
      g_complete                    VARCHAR2 (30) := 'COMPLETE';
      l_temp_status_code            VARCHAR2 (30) := g_complete;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_plan_element_2;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- fill the rec
      l_plan_element := get_plan_element (p_quota_id);
      -- validate the plan element
      validate_plan_element (p_api_version           => p_api_version,
                             p_plan_element          => l_plan_element,
                             p_old_plan_element      => l_plan_element,
                             p_action                => 'UPDATE',
                             x_return_status         => x_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data
                            );

      -- in case of error, raise exception
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         l_temp_status_code := g_incomplete;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_comp_plan_id IS NOT NULL
      THEN
         SELECT NAME
           INTO l_plan_name
           FROM cn_comp_plans
          WHERE comp_plan_id = p_comp_plan_id;
      END IF;

      SELECT cf.NAME,
             q.calc_formula_id
        INTO x_formula_name,
             x_calc_formula_id
        FROM cn_quotas q,
             cn_calc_formulas cf
       WHERE q.quota_id = p_quota_id AND q.calc_formula_id = cf.calc_formula_id(+) AND q.quota_type_code IN ('EXTERNAL', 'FORMULA');

      IF l_plan_element.quota_type_code IN ('FORMULA', 'EXTERNAL')
      THEN
         IF l_plan_element.quota_type_code = 'FORMULA'
         THEN
            check_rate_dim (p_quota_id);
         END IF;

         IF l_plan_element.calc_formula_id IS NULL AND l_plan_element.quota_type_code = 'FORMULA'
         THEN
            l_temp_status_code := g_incomplete;
            set_message (p_plan_name       => l_plan_name,
                         p_pe_name         => l_plan_element.NAME,
                         message_name      => 'PLN_QUOTA_NO_FORMULA',
                         token_name        => NULL,
                         token_value       => NULL
                        );
         ELSIF l_plan_element.package_name IS NULL AND l_plan_element.quota_type_code = 'EXTERNAL'
         THEN
            l_temp_status_code := g_incomplete;
            set_message (p_plan_name       => l_plan_name,
                         p_pe_name         => l_plan_element.NAME,
                         message_name      => 'PLN_QUOTA_NO_PACKAGE',
                         token_name        => NULL,
                         token_value       => NULL
                        );
         END IF;

         -- Check Schedule exists.
         IF l_plan_element.quota_type_code IN ('FORMULA', 'EXTERNAL')
         THEN
            SELECT COUNT (1)
              INTO l_tmp
              FROM cn_rt_quota_asgns
             WHERE quota_id = p_quota_id;

            IF (l_tmp = 0)
            THEN
               l_temp_status_code := g_incomplete;
               set_message (p_plan_name       => l_plan_name,
                            p_pe_name         => l_plan_element.NAME,
                            message_name      => 'PLN_QUOTA_NO_SCHEDULE',
                            token_name        => NULL,
                            token_value       => NULL
                           );
            END IF;
         END IF;

         IF l_temp_status_code = g_complete AND l_plan_element.incentive_type_code <> 'BONUS'
         THEN
            OPEN rules;

            LOOP
               FETCH rules
                INTO rule_rec;


               -- Need to distinguish between no rows and the all rows found
               IF rules%ROWCOUNT = 0
               THEN
                  l_temp_status_code := g_incomplete;
                  set_message (p_plan_name       => l_plan_name,
                               p_pe_name         => l_plan_element.NAME,
                               message_name      => 'PLN_QUOTA_NO_RULES',
                               token_name        => NULL,
                               token_value       => NULL
                              );
                  EXIT;                                                                                                                   -- exit loop
               ELSE
                  IF rules%NOTFOUND
                  THEN
                     EXIT;
                  ELSE
                     IF l_temp_status_code = g_complete
                     THEN
			key_factor_total := 0;
                        OPEN factors (rule_rec.quota_rule_id);

                        LOOP
                           FETCH factors
                            INTO factor_rec;

                           IF factors%ROWCOUNT = 0
                           THEN
                              l_temp_status_code := g_incomplete;
                              set_message (p_plan_name       => l_plan_name,
                                           p_pe_name         => l_plan_element.NAME,
                                           message_name      => 'PLN_QUOTA_RULE_NO_FACTORS',
                                           token_name        => 'REV_CLASS_NAME',
                                           token_value       => rule_rec.rev_class_name
                                          );
                              EXIT;                                                                                                       -- exit loop
                           ELSE
                              IF factors%NOTFOUND
                              THEN
                                 IF key_factor_total <> 100
                                 THEN
                                    l_temp_status_code := g_incomplete;
                                    set_message (p_plan_name       => l_plan_name,
                                                 p_pe_name         => l_plan_element.NAME,
                                                 message_name      => 'PLN_QUOTA_RULE_FACTORS_NOT_100',
                                                 token_name        => 'REV_CLASS_NAME',
                                                 token_value       => rule_rec.rev_class_name
                                                );
                                 END IF;

                                 EXIT;
                              ELSE
                                 IF (factor_rec.trx_type = 'ORD' OR factor_rec.trx_type = 'INV' OR factor_rec.trx_type = 'PMT')
                                 THEN
                                    key_factor_total := key_factor_total + factor_rec.event_factor;
                                 END IF;
                              END IF;
                           END IF;
                        END LOOP;

                        CLOSE factors;
                     END IF;
                  END IF;                                                                                                               -- sqlnotfound
               END IF;                                                                                                                     -- rowcount
            END LOOP;

            CLOSE rules;
         END IF;
      END IF;

      -- pass the status back to the calling program.
      -- all problems will be written to a table for review
      -- we just need to tell the comp plan that it is invalid
      x_status_code := l_temp_status_code;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO validate_plan_element_2;
         x_return_status := fnd_api.g_ret_sts_error;
         x_status_code := g_incomplete;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO validate_plan_element_2;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_status_code := g_incomplete;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO validate_plan_element_2;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_status_code := g_incomplete;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END validate_plan_element;
END cn_plan_element_pvt;

/
