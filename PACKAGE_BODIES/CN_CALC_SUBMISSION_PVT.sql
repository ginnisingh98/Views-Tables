--------------------------------------------------------
--  DDL for Package Body CN_CALC_SUBMISSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_SUBMISSION_PVT" AS
/*$Header: cnvsbcsb.pls 120.5 2006/05/25 01:40:33 ymao ship $*/

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'CN_CALC_SUBMISSION_PVT';

TYPE sub_batch_rec_type IS RECORD
  (name                   cn_calc_submission_batches.name%TYPE,
   org_id                 cn_calc_submission_batches.org_id%TYPE,
   calc_sub_batch_id      cn_calc_submission_batches.calc_sub_batch_id%TYPE,
   calc_type              cn_calc_submission_batches.calc_type%TYPE,
   start_date             cn_calc_submission_batches.start_date%TYPE,
   end_date               cn_calc_submission_batches.end_date%TYPE,
   salesrep_option        cn_calc_submission_batches.salesrep_option%TYPE,
   hierarchy_flag         cn_calc_submission_batches.hierarchy_flag%TYPE,
   concurrent_flag        cn_calc_submission_batches.concurrent_flag%TYPE,
   intelligent_flag       cn_calc_submission_batches.intelligent_flag%TYPE,
   status                 cn_calc_submission_batches.status%TYPE,
   interval_type_id       cn_calc_submission_batches.interval_type_id%TYPE,
   process_audit_id       cn_calc_submission_batches.process_audit_id%TYPE,
   object_version_number  cn_calc_submission_batches.object_version_number%TYPE,
   concurrent_request_id  cn_process_audits.concurrent_request_id%TYPE);

TYPE rep_entry_rec_type IS RECORD
  (name                   jtf_rs_salesreps.name%TYPE,
   employee_number        jtf_rs_salesreps.salesrep_number%TYPE,
   salesrep_id            jtf_rs_salesreps.salesrep_id%TYPE,
   calc_sub_entry_id      cn_calc_submission_entries.calc_sub_entry_id%TYPE);

TYPE quota_entry_rec_type IS RECORD
  (name                   cn_quotas.name%TYPE,
   quota_id               cn_quotas.quota_id%TYPE,
   calc_sub_quota_id      cn_calc_sub_quotas.calc_sub_quota_id%TYPE);

TYPE rep_entry_tbl_type IS TABLE OF rep_entry_rec_type INDEX BY BINARY_INTEGER;
TYPE quota_entry_tbl_type IS TABLE OF quota_entry_rec_type INDEX BY BINARY_INTEGER;
TYPE name_tbl_type IS TABLE OF cn_interval_types_all_tl.name%TYPE INDEX BY BINARY_INTEGER;

--
  -- Name
  --   check_end_of_interval
  -- Purpose
  --   Returns 1 if the specified period is the end of an interval of the
  --  type listed int he X_Interval string.
  -- History
  --  06/13/95	Created 	Rjin
  --
  FUNCTION check_end_of_interval(p_period_id NUMBER,
                                 p_interval_type_id NUMBER,
                                 p_org_id NUMBER)
  RETURN BOOLEAN IS
       l_end_period_id NUMBER(15);
  BEGIN
     SELECT MAX(ps2.period_id)
       INTO l_end_period_id
       FROM cn_period_statuses_all ps1,
            cn_period_statuses_all ps2
      WHERE ps1.period_id = p_period_id
        AND ps1.org_id = p_org_id
        AND ps2.period_set_id = ps1.period_set_id
        AND ps2.org_id = p_org_id
        AND ps2.period_type_id = ps1.period_type_id
        AND ps2.period_year = ps1.period_year
        AND ( ( p_interval_type_id = -1001 AND ps2.quarter_num = ps1.quarter_num ) -- quarter interval
	     OR p_interval_type_id = -1002 ) ; -- year interval

     IF p_period_id = l_end_period_id THEN
	RETURN TRUE;
      ELSE
	RETURN FALSE;
     END IF;

  EXCEPTION
     WHEN OTHERS THEN
	   if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_calc_submission_pvt.check_end_of_interval.exception',
		       		     sqlerrm);
       end if;
	   raise ;
  END check_end_of_interval;

 --
  -- Name
  --   check_active_plan_assign
  -- Purpose
  --   Returns 1 if the specified period is the end of an interval of the
  --  type listed int he X_Interval string.
  -- History
  --  06/13/95	Created 	Tony Lower
  --
  FUNCTION check_active_plan_assign (p_salesrep_id NUMBER,
				     p_end_date DATE,
                                     p_org_id NUMBER )
    RETURN BOOLEAN IS

       CURSOR l_active_plan_csr IS
            SELECT 1
	      FROM cn_srp_plan_assigns_all spa,
	           cn_comp_plans_all plan
	     WHERE spa.salesrep_id = p_salesrep_id
               AND spa.org_id = p_org_id
	       AND ((spa.end_date IS NOT NULL
		     AND p_end_date BETWEEN spa.start_date AND spa.end_date)
		     OR (p_end_date >= spa.start_date AND spa.end_date IS NULL ) )
	       AND spa.comp_plan_id = plan.comp_plan_id
	       AND plan.status_code = 'COMPLETE';

      dummy NUMBER;

  BEGIN
     OPEN l_active_plan_csr;
     FETCH l_active_plan_csr INTO dummy;
     CLOSE l_active_plan_csr;

     IF dummy = 1 THEN
	RETURN TRUE;
      ELSE
	RETURN FALSE;
     END IF;
  END check_active_plan_assign;

-- validate the calculation request
PROCEDURE validate_submission_records
  (p_sub_batch_rec          IN  sub_batch_rec_type,
   p_rep_entry_tbl          IN  rep_entry_tbl_type,
   p_quota_entry_tbl        IN  quota_entry_tbl_type,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2)
  IS
     l_dummy NUMBER;
     l_quota_name cn_quotas.name%TYPE;

     CURSOR name_check (p_batch_name cn_calc_submission_batches.name%TYPE ) IS
	SELECT 1
	  FROM cn_calc_submission_batches_all
	  WHERE name = p_batch_name
          AND org_id = p_sub_batch_rec.org_id
	  AND (p_sub_batch_rec.calc_sub_batch_id IS NULL OR calc_sub_batch_id <> p_sub_batch_rec.calc_sub_batch_id);

     CURSOR open_period_check(p_start_date DATE) IS
	SELECT 1
	  FROM cn_period_statuses_all
	  WHERE (period_set_id, period_type_id) = (SELECT period_set_id, period_type_id FROM cn_repositories_all
                                                    WHERE org_id = p_sub_batch_rec.org_id)
	  AND period_status = 'O'
          AND org_id = p_sub_batch_rec.org_id
	  AND trunc(p_start_date) BETWEEN trunc(start_date) AND trunc(end_date);

     CURSOR quota_check(p_quota_id NUMBER) IS
	SELECT name
	  FROM cn_quotas_all
	  WHERE quota_id = p_quota_id
          AND org_id = p_sub_batch_rec.org_id
	  AND incentive_type_code = 'BONUS'
	  AND (interval_type_id = p_sub_batch_rec.interval_type_id OR
	       (p_sub_batch_rec.interval_type_id = -1003 AND interval_type_id IN (-1000, -1001, -1002)));
BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- 1. name can not be null and should be unique(there is a unique index on name)
   IF (p_sub_batch_rec.name IS NULL) THEN
	 fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	 fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('NAME', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('NAME', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;

   OPEN name_check(p_sub_batch_rec.name);
   FETCH name_check INTO l_dummy;
   IF (name_check%found) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_EXISTS');
	 fnd_message.set_token('BATCH_NAME', cn_api.get_lkup_meaning('NAME', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)	THEN
	   FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_EXISTS');
	   fnd_message.set_token('BATCH_NAME', cn_api.get_lkup_meaning('NAME', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   FND_MSG_PUB.Add;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;
   CLOSE name_check;

   -- 2. start_date and end_date can not be null and end_date >= start_date
   IF (p_sub_batch_rec.start_date IS NULL) THEN
	 fnd_message.set_name('CN', 'CN_START_DATE_CANNOT_NULL');
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN', 'CN_START_DATE_CANNOT_NULL');
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;
   IF (p_sub_batch_rec.end_date IS NULL) THEN
	 fnd_message.set_name('CN', 'CN_END_DATE_CANNOT_NULL');
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN', 'CN_END_DATE_CANNOT_NULL');
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;
   IF (p_sub_batch_rec.start_date > p_sub_batch_rec.end_date) THEN
	 fnd_message.set_name('CN', 'CN_INVALID_DATE_RANGE');
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN', 'CN_INVALID_DATE_RANGE');
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;

   -- 3. start_date and end_date must be within an open period
   OPEN open_period_check(p_sub_batch_rec.start_date);
   FETCH open_period_check INTO l_dummy;
   IF (open_period_check%notfound) THEN
	 fnd_message.set_name('CN' , 'CN_CALC_SUB_OPEN_DATE');
	 fnd_message.set_token('DATE', p_sub_batch_rec.start_date);
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN' , 'CN_CALC_SUB_OPEN_DATE');
	   fnd_message.set_token('DATE', p_sub_batch_rec.start_date);
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;
   CLOSE open_period_check;
   OPEN open_period_check(p_sub_batch_rec.end_date);
   FETCH open_period_check INTO l_dummy;
   IF (open_period_check%notfound) THEN
	 fnd_message.set_name('CN' , 'CN_CALC_SUB_OPEN_DATE');
	 fnd_message.set_token('DATE', p_sub_batch_rec.end_date);
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN' , 'CN_CALC_SUB_OPEN_DATE');
	   fnd_message.set_token('DATE', p_sub_batch_rec.end_date);
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;
   CLOSE open_period_check;

   -- 4. calc_type can not be null, must be 'COMMISSION' or 'BONUS'
   IF (p_sub_batch_rec.calc_type IS NULL) THEN
	 fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	 fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('CALC_TYPE', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('CALC_TYPE', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;
   IF (p_sub_batch_rec.calc_type NOT IN ('COMMISSION', 'BONUS')) THEN
	 fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	 fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('CALC_TYPE', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('CALC_TYPE', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;

   -- 5. salesrep_option can not be null and must be a valid value
   IF (p_sub_batch_rec.salesrep_option IS NULL) THEN
	 fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	 fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('SALESREP_OPTION', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('SALESREP_OPTION', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;
   IF (p_sub_batch_rec.salesrep_option NOT IN ('ALL_REPS', 'USER_SPECIFY', 'REPS_IN_NOTIFY_LOG') OR
       (p_sub_batch_rec.calc_type = 'BONUS' AND p_sub_batch_rec.salesrep_option = 'REPS_IN_NOTIFY_LOG'))
   THEN
	 fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	 fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('SALESREP_OPTION', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('SALESREP_OPTION', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;

   -- 6. hierarchy_flag can not be null, must be a valid value
   -- TO DO: remove this check if hierarchy flag is only supported at rep level in R12
   IF (p_sub_batch_rec.hierarchy_flag IS NULL) THEN
	 fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	 fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('HIERARCHY_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('HIERARCHY_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;
   IF (p_sub_batch_rec.hierarchy_flag NOT IN ('Y', 'N') OR
       (p_sub_batch_rec.salesrep_option IN ('ALL_REPS', 'REPS_IN_NOTIFY_LOG') AND p_sub_batch_rec.hierarchy_flag = 'Y'))
   THEN
	 fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	 fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('HIERARCHY_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('HIERARCHY_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;

   -- 7. concurrent_flag can not be null, must be a valid value
   IF (p_sub_batch_rec.concurrent_flag IS NULL) THEN
	 fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	 fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('CONCURRENT_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('CONCURRENT_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;
   IF (p_sub_batch_rec.concurrent_flag NOT IN ('Y', 'N')) THEN
	 fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	 fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('CONCURRENT_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('CONCURRENT_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;

   -- 8. intelligent_flag can not be null, must be a valid value
   IF (p_sub_batch_rec.intelligent_flag IS NULL) THEN
	 fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	 fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('INTELLIGENT_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('INTELLIGENT_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;
   IF (p_sub_batch_rec.intelligent_flag NOT IN ('Y', 'N') OR
       (p_sub_batch_rec.calc_type = 'BONUS' AND p_sub_batch_rec.intelligent_flag = 'Y') OR
       (p_sub_batch_rec.salesrep_option = 'REPS_IN_NOTIFY_LOG' AND p_sub_batch_rec.intelligent_flag = 'N'))
   THEN
	 fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	 fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('INTELLIGENT_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
     end if;

     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	   fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('INTELLIGENT_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   fnd_msg_pub.ADD;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;

   -- 9. interval_type can not be null, must be a valid value if calc_type = 'BONUS'
   IF (p_sub_batch_rec.calc_type = 'BONUS') THEN
     IF (p_sub_batch_rec.interval_type_id IS NULL) THEN
	   fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('INTERVAL_TYPE', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
       end if;

	   IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	     fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	     fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('INTERVAL_TYPE', 'CALC_SUBMISSION_OBJECT_TYPE'));
	     fnd_msg_pub.ADD;
	   END IF;
	   x_return_status := fnd_api.g_ret_sts_error;
     END IF;
     IF (p_sub_batch_rec.interval_type_id NOT IN (-1000, -1001, -1002, -1003)) THEN
	   fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	   fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('INTERVAL_TYPE', 'CALC_SUBMISSION_OBJECT_TYPE'));
	   if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
       end if;

	   IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	     fnd_message.set_name('CN' , 'CN_INVALID_DATA');
	     fnd_message.set_token('OBJ_NAME', cn_api.get_lkup_meaning('INTERVAL_TYPE', 'CALC_SUBMISSION_OBJECT_TYPE'));
	     fnd_msg_pub.ADD;
	   END IF;
	   x_return_status := fnd_api.g_ret_sts_error;
     END IF;
   END IF;

   -- 10. salesrep validation
   IF (p_sub_batch_rec.salesrep_option = 'USER_SPECIFY') THEN
     IF (p_rep_entry_tbl.COUNT = 0) THEN
	   fnd_message.set_name('CN' , 'CN_CALC_NO_SALESREP');
	   if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
       end if;

	   IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	     fnd_message.set_name('CN' , 'CN_CALC_NO_SALESREP');
	     fnd_msg_pub.ADD;
	   END IF;
	   x_return_status := fnd_api.g_ret_sts_error;
     END IF;

     IF (p_sub_batch_rec.calc_sub_batch_id IS NOT NULL AND p_rep_entry_tbl.COUNT > 0) THEN
 	   l_dummy := 0;
	   FOR i IN p_rep_entry_tbl.first..p_rep_entry_tbl.last LOOP
	     IF (p_rep_entry_tbl(i).salesrep_id IS NOT NULL) THEN
	       l_dummy := 1;
	       EXIT;
	     END IF;
	   END LOOP;

	   IF (l_dummy = 0) THEN
	     fnd_message.set_name('CN' , 'CN_CALC_NO_SALESREP');
	     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
         end if;

	     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	       fnd_message.set_name('CN' , 'CN_CALC_NO_SALESREP');
	       fnd_msg_pub.ADD;
	     END IF;
	     x_return_status := fnd_api.g_ret_sts_error;
	   END IF;
     END IF;

     IF (p_rep_entry_tbl.COUNT > 0) THEN
	   FOR i IN p_rep_entry_tbl.first..p_rep_entry_tbl.last LOOP
	     FOR j IN p_rep_entry_tbl.first..p_rep_entry_tbl.last LOOP
	       IF (j <> i) THEN
		     IF (p_rep_entry_tbl(j).salesrep_id = p_rep_entry_tbl(i).salesrep_id) THEN
		       x_return_status := fnd_api.g_ret_sts_error;

		       fnd_message.set_name('CN', 'CN_CALC_SALESREP_EXIST');
		       fnd_message.set_token('NAME', p_rep_entry_tbl(i).name);
	           if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                 FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
               end if;

	           IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
		         fnd_message.set_name('CN', 'CN_CALC_SALESREP_EXIST');
		         fnd_message.set_token('NAME', p_rep_entry_tbl(i).name);
		         fnd_msg_pub.ADD;
		       END IF;
		       EXIT;
		     END IF;
	       END IF;
	     END LOOP;
	   END LOOP;
     END IF;
   END IF;

   -- 11. plan element validation
   IF (p_sub_batch_rec.calc_type = 'BONUS' AND p_sub_batch_rec.interval_type_id IS NOT NULL AND p_quota_entry_tbl.COUNT > 0) THEN
     FOR i IN p_quota_entry_tbl.first..p_quota_entry_tbl.last LOOP
	   IF (p_quota_entry_tbl(i).quota_id IS NOT NULL) THEN
	     OPEN quota_check(p_quota_entry_tbl(i).quota_id);
	     FETCH quota_check INTO l_quota_name;
	     IF (quota_check%notfound) THEN
		   fnd_message.set_name('CN', 'CN_CALC_PE_NO_MATCH');
		   fnd_message.set_token('QUOTA_NAME', l_quota_name);
	       if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pvt.validate_submission_records.error',
	       		       TRUE);
           end if;

	       IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
		     fnd_message.set_name('CN', 'CN_CALC_PE_NO_MATCH');
		     fnd_message.set_token('QUOTA_NAME', l_quota_name);
		     fnd_msg_pub.ADD;
	       END IF;
	       x_return_status := fnd_api.g_ret_sts_error;
	     END IF;
	     CLOSE quota_check;
	   END IF;
     END LOOP;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    'validate_submission_records');
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );

	 if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      'cn.plsql.cn_calc_submission_pvt.validate_submission_records.exception',
	       		      sqlerrm);
     end if;
END validate_submission_records;

FUNCTION translate(Encoded_Message VARCHAR2) Return VARCHAR2 IS
   temp_message	    VARCHAR2(500);
   appl_short_name  VARCHAR2(3);
   translate	    BOOLEAN;
   temp_buf	    VARCHAR2(255);
   token_value	    VARCHAR2(50);
   translate_arg    VARCHAR2(10);
   pos1		    NUMBER;
   pos2		    NUMBER;
BEGIN
  temp_message := ltrim(encoded_message);

  -- Extract the Application Short Name and Message Name
  pos1 		  := instr(temp_message, ' ', 1);
  appl_short_name := substr(temp_message, 1, pos1 - 1);
  temp_message 	  := ltrim(substr(temp_message, pos1 + 1));
  pos1 		  := instr(temp_message, ' ', 1);

  -- Store the Message name in variable Temp_Buf
  IF (pos1 = 0) THEN
    -- There are no tokens, just a message name
    temp_buf 	 := temp_message;
    temp_message := NULL;

    fnd_message.set_name(appl_short_name, temp_buf);
    temp_buf := fnd_message.get;

    return(temp_buf);

  ELSE
    -- there are tokens
    temp_buf 	 := substr(temp_message, 1, pos1 - 1);
    temp_message := ltrim(substr(temp_message, pos1 + 1));
    fnd_message.set_name(appl_short_name, temp_buf);

  END IF;


  --  Extract the token information if necessary.
  IF (temp_message IS NOT NULL) THEN
    LOOP
      -- Store the token name in Temp_Buf
      pos1 := instr(temp_message, ' ', 1);
      temp_buf := substr(temp_message, 1, pos1 - 1);

      -- locate the Token Value Delimiters and extract the token value.
      pos1 := instr(temp_message, '\"', 1);
      pos2 := instr(temp_message, '\"', Pos1 + 2, 1);
      token_value := substr(temp_message, pos1 + 2, pos2 - pos1 - 2);
      temp_message := ltrim(substr(temp_message, pos2 + 2));
      pos1 := instr(temp_message, ' ', 1);

      -- Pos1 will equal 0 when Temp_Message is NULL which means that
      -- there are no more tokens to process.
      IF (Pos1 <> 0) THEN
        translate_arg := upper(substr(temp_message, 1, pos1 - 1));
        temp_message := ltrim(substr(temp_message, pos1 + 1));
      ELSE
	translate_arg := upper(temp_message);
        temp_message  := NULL;
      END IF;
      IF (translate_arg = 'TRUE') then
        Translate := True;
      ELSIF (translate_arg = 'FALSE') then
	Translate := False;
      end if;

      fnd_message.set_token(temp_buf, token_value, translate);

      EXIT WHEN (temp_message IS NULL);

    END LOOP;

  END IF;

  temp_message := fnd_message.get;
  return(temp_message);

 END translate;

-- get submission batch detail
PROCEDURE get_submission_batch
  (p_calc_sub_batch_id          IN      cn_calc_submission_batches.calc_sub_batch_id%TYPE,
   x_sub_batch_rec              OUT NOCOPY     sub_batch_rec_type,
   x_rep_entry_tbl              OUT NOCOPY     rep_entry_tbl_type,
   x_quota_entry_tbl            OUT NOCOPY     quota_entry_tbl_type,
   x_interval_type_tbl          OUT NOCOPY     name_tbl_type)
  IS
     i pls_integer := 0;

     CURSOR batch IS
	SELECT name,
               org_id,
	       calc_sub_batch_id,
	       calc_type,
	       start_date,
	       end_date,
	       salesrep_option,
	       hierarchy_flag,
	       concurrent_flag,
               intelligent_flag,
	       status,
	       interval_type_id,
	       process_audit_id,
	       object_version_number,
	       null
	  FROM cn_calc_submission_batches
	  WHERE calc_sub_batch_id = p_calc_sub_batch_id;

     CURSOR reps IS
	SELECT b.name, b.employee_number, a.salesrep_id, a.calc_sub_entry_id
	  FROM cn_calc_submission_entries a,
	       cn_salesreps b
	  WHERE a.calc_sub_batch_id = p_calc_sub_batch_id
	  AND a.salesrep_id = b.salesrep_id;

     CURSOR quotas IS
	SELECT b.name, a.quota_id, a.calc_sub_quota_id
	  FROM cn_calc_sub_quotas a,
	       cn_quotas b
	 WHERE a.calc_sub_batch_id = p_calc_sub_batch_id
	  AND a.quota_id = b.quota_id;

     CURSOR interval_types IS
	SELECT name
	  FROM cn_interval_types
	  WHERE interval_type_id IN (-1000, -1001, -1002, -1003)
	  ORDER BY interval_type_id desc;

     -- Added to retrieve concurrent request id for enhancment#2651798
     CURSOR get_conc_req_id (a_process_audit_id NUMBER) IS
	SELECT concurrent_request_id
	  FROM cn_process_audits
	 WHERE process_audit_id = a_process_audit_id;


BEGIN
   OPEN batch;
   FETCH batch INTO x_sub_batch_rec;
   CLOSE batch;


   -- Added to retrieve concurrent request id for enhancment#2651798
   IF (x_sub_batch_rec.process_audit_id  IS NOT NULL) AND
      (x_sub_batch_rec.concurrent_flag  = 'Y')
   THEN
	x_sub_batch_rec.concurrent_request_id := NULL;
	OPEN get_conc_req_id(x_sub_batch_rec.process_audit_id);
	FETCH get_conc_req_id INTO x_sub_batch_rec.concurrent_request_id;
	CLOSE get_conc_req_id;
   END IF;

   FOR rep IN reps LOOP
      x_rep_entry_tbl(i).name := rep.name;
      x_rep_entry_tbl(i).employee_number := rep.employee_number;
      x_rep_entry_tbl(i).salesrep_id := rep.salesrep_id;
      x_rep_entry_tbl(i).calc_sub_entry_id := rep.calc_sub_entry_id;
      i := i + 1;
   END LOOP;

   i := 0;
   FOR quota IN quotas LOOP
      x_quota_entry_tbl(i) := quota;
      i := i + 1;
   END LOOP;

   i := 0;
   FOR interval_type IN interval_types LOOP
      x_interval_type_tbl(i) := interval_type.name;
      i := i + 1;
   END LOOP;
END get_submission_batch;

-- This procedure should be invoked only when retrieving calculation batch records in response to a search request
-- from the calculation batch search page.
PROCEDURE maintain_batch_status IS
BEGIN
  update cn_calc_submission_batches_all sb
     set status = 'FAILED'
   where status = 'PROCESSING'
     and concurrent_flag = 'Y'
     and exists (select 1
                   from fnd_concurrent_requests
                  where request_id = (select concurrent_request_id
                                        from cn_process_audits_all
                                       where process_audit_id = sb.process_audit_id)
                    and status_code in ('E', 'X'));
  commit;
EXCEPTION
  WHEN OTHERS THEN
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_calc_submission_pvt.maintain_batch_status.exception',
	      		      sqlerrm);
    end if;
END maintain_batch_status;

PROCEDURE Validate
  (p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2,
   p_commit                     IN  VARCHAR2,
   p_validation_level           IN  NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   p_calc_sub_batch_id          IN  cn_calc_submission_batches.calc_sub_batch_id%TYPE
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Validate';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_sub_batch_rec           sub_batch_rec_type;
   l_rep_entry_tbl           rep_entry_tbl_type;
   l_quota_entry_tbl         quota_entry_tbl_type;
   l_interval_type_tbl       name_tbl_type;
BEGIN
   -- Standard Start of API savepoint

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call
     (l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pvt.validate.begin',
	      		    'Beginning of validate...'  );
   end if;

   get_submission_batch
     (p_calc_sub_batch_id          => p_calc_sub_batch_id,
      x_sub_batch_rec              => l_sub_batch_rec,
      x_rep_entry_tbl              => l_rep_entry_tbl,
      x_quota_entry_tbl            => l_quota_entry_tbl,
      x_interval_type_tbl          => l_interval_type_tbl);

   validate_submission_records(p_sub_batch_rec    => l_sub_batch_rec,
			       p_rep_entry_tbl    => l_rep_entry_tbl,
			       p_quota_entry_tbl  => l_quota_entry_tbl,
			       x_return_status    => x_return_status,
			       x_msg_count        => x_msg_count,
			       x_msg_data         => x_msg_data);
   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_proc_batches_pkg.find_srp_incomplete_plan(p_calc_sub_batch_id)) THEN
     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
       IF FND_API.To_Boolean(p_commit) THEN
         COMMIT WORK;
       END IF;

       fnd_message.set_name('CN', 'CNSBCS_INCOMPLETE_PLAN');
       fnd_msg_pub.add;
       if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                         'cn.plsql.cn_calc_submission_pvt.validate.error',
                         FALSE);
       end if;

     END IF;
     RAISE fnd_api.g_exc_error;
   END IF;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pvt.validate.end',
	      		    'End of validate.'  );
   end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    'Validate');
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );

    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_calc_submission_pvt.validate.exception',
	      		      sqlerrm);
    end if;

END Validate;

PROCEDURE Calculate
  (p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2,
   p_validation_level           IN  NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   p_calc_sub_batch_id          IN  cn_calc_submission_batches.calc_sub_batch_id%TYPE)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Calculate';
   l_api_version             CONSTANT NUMBER       := 1.0;

   l_process_audit_id        NUMBER;
   l_process_status_code     VARCHAR2(30);
   l_concurrent_flag         VARCHAR2(1);

BEGIN
   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call
     (l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pvt.calculate.begin',
	      		    'Beginning of calculate...'  );
   end if;

   validate
     (p_api_version                => 1.0,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => fnd_api.g_true,
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data,
      p_calc_sub_batch_id          => p_calc_sub_batch_id);

   IF (x_return_status = fnd_api.g_ret_sts_error) THEN
     raise fnd_api.g_exc_error;
   ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
     raise fnd_api.g_exc_unexpected_error;
   END IF;

   cn_proc_batches_pkg.calculation_submission
     (p_calc_sub_batch_id   => p_calc_sub_batch_id,
      x_process_audit_id    => l_process_audit_id,
      x_process_status_code => l_process_status_code);

   select concurrent_flag
     into l_concurrent_flag
     from cn_calc_submission_batches_all
    where calc_sub_batch_id = p_calc_sub_batch_id;

   IF (l_concurrent_flag = 'N') THEN
      IF nvl(l_process_status_code,'FAIL') = 'SUCCESS' THEN
	 fnd_message.set_name('CN','ALL_PROCESS_DONE_OK_LOG');
       ELSIF nvl(l_process_status_code,'FAIL') = 'FAIL' THEN
	 fnd_message.set_name('CN','ALL_PROCESS_DONE_FAIL_LOG');
      END IF;
    ELSE
      IF nvl(l_process_status_code,'FAIL') = 'SUCCESS' THEN
	 fnd_message.set_name('CN','ALL_PROCESS_SUBMIT_OK_LOG');
       ELSIF nvl(l_process_status_code,'FAIL') = 'FAIL' THEN
	 fnd_message.set_name('CN','ALL_PROCESS_SUBMIT_FAIL_LOG');
      END IF;
   END IF;
   fnd_message.set_token('AUDIT_ID', l_process_audit_id);
   fnd_msg_pub.ADD;

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pvt.calculate.end',
	      		    'End of calculate'  );
   end if;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    'Calculate');
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
END Calculate;

PROCEDURE CopyBatch
  	(p_api_version               IN  NUMBER,
   	p_init_msg_list              IN  VARCHAR2,
   	p_commit                     IN  VARCHAR2,
   	p_validation_level           IN  NUMBER,
   	x_return_status              OUT NOCOPY VARCHAR2,
   	x_msg_count                  OUT NOCOPY NUMBER,
   	x_msg_data                   OUT NOCOPY VARCHAR2,
   	p_calc_sub_batch_id          IN  cn_calc_submission_batches.calc_sub_batch_id%TYPE,
   	p_out_calc_sub_batch_id      OUT NOCOPY  cn_calc_submission_batches.calc_sub_batch_id%TYPE)
IS
   	l_api_name                CONSTANT VARCHAR2(30) := 'copybatch';
   	l_api_version             CONSTANT NUMBER       := 1.0;

  	seq_batchid NUMBER;
    dummy_char VARCHAR2(30);
    batch_record cn_calc_submission_batches%rowtype;
    batch_entries_record cn_calc_submission_entries%rowtype;
    batch_bonus_record cn_calc_sub_quotas%rowtype;

    temp_batch_name VARCHAR2(30);
    dummy_batch cn_calc_submission_batches%rowtype;
    dup_name_counter NUMBER := 1;
    record_checker BOOLEAN := FALSE;

    cursor batch_cursor is
        select * from cn_calc_submission_batches where calc_sub_batch_id = p_calc_sub_batch_id;

    cursor rep_cursor is
        select * from cn_calc_submission_entries where calc_sub_batch_id = p_calc_sub_batch_id;

    cursor bonus_cursor is
        select * from cn_calc_sub_quotas where calc_sub_batch_id = p_calc_sub_batch_id;

    cursor namecheck_cursor(p_batch_name_to_check cn_calc_submission_batches.name%TYPE) is
        select * from cn_calc_submission_batches where name = p_batch_name_to_check and rownum = 1;

BEGIN
   	-- Standard Start of API savepoint
   	SAVEPOINT copybatch_PVT;

   	-- Standard call to check for call compatibility
   	IF NOT FND_API.Compatible_API_Call
     		(l_api_version,
      		p_api_version,
      		l_api_name,
      		G_PKG_NAME)
   	THEN
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	END IF;

   	-- Initialize message list if p_init_msg_list is set to TRUE.
   	IF FND_API.to_Boolean( p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
   	END IF;

   	--  Initialize API return status to success
   	x_return_status := FND_API.G_RET_STS_SUCCESS;


	-- Body Begins.
    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pvt.copybatch.begin',
	      		    'Beginning of copybatch ...'  );
    end if;

    	select CN_CALC_SUBMISSION_BATCHES_S1.nextval into seq_batchid from dual;

    	open batch_cursor;
    	FETCH batch_cursor INTO batch_record;
    	if batch_cursor%NOTFOUND then
        	raise_application_error(-20000, 'Cannot continue.. Calculation Batch doesnot exist');
    	end if;
    	--batch_record.name := 'Copy of '||substr(batch_record.name,1,20);
    	batch_record.calc_sub_batch_id := seq_batchid;
    	batch_record.process_audit_id := null;
    	batch_record.object_version_number := 1;
    	batch_record.logical_batch_id := null;
    	batch_record.log_name := null;
    	batch_record.ledger_je_batch_id := null;
        batch_record.concurrent_flag := 'N';
    	batch_record.status := 'INCOMPLETE';


        LOOP
            -- First create the initial batch name
            temp_batch_name := 'Copy_'||dup_name_counter||' '||substr(batch_record.name,1,18);
            --dbms_output.put_line('The value of temp_batch_name is ' || temp_batch_name);

            if NOT namecheck_cursor%ISOPEN then
                open namecheck_cursor(temp_batch_name);
                fetch namecheck_cursor into dummy_batch;

                if  namecheck_cursor%FOUND then
                    -- duplicate record found, so increment the counter, and continue the loop
                    record_checker := FALSE;
                    dup_name_counter := dup_name_counter + 1;
                else
                    -- duplicate record not found, current record is good
                    record_checker := TRUE;
                end if;

                if (namecheck_cursor%ISOPEN) then
                    close namecheck_cursor;
                end if;

            end if;

            EXIT WHEN record_checker;
        END LOOP;

        -- Now the non duplicated value must be available
        batch_record.name := temp_batch_name;

    	insert into
    	cn_calc_submission_batches
    	(ORG_ID,CALC_SUB_BATCH_ID,NAME,CALC_FROM_PERIOD_ID,CALC_TO_PERIOD_ID,INTELLIGENT_FLAG,HIERARCHY_FLAG,
    	SALESREP_OPTION,CONCURRENT_FLAG,LOG_NAME,STATUS,LOGICAL_BATCH_ID,FORECAST_FLAG,ATTRIBUTE_CATEGORY,
    	ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,
    	ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,START_DATE,END_DATE,CALC_TYPE,
    	INTERVAL_TYPE_ID,LEDGER_JE_BATCH_ID,PROCESS_AUDIT_ID,CREATED_BY,CREATION_DATE,OBJECT_VERSION_NUMBER,
    	SECURITY_GROUP_ID)
    	values(
    	BATCH_RECORD.ORG_ID,BATCH_RECORD.CALC_SUB_BATCH_ID,BATCH_RECORD.NAME,BATCH_RECORD.CALC_FROM_PERIOD_ID,
    	BATCH_RECORD.CALC_TO_PERIOD_ID,BATCH_RECORD.INTELLIGENT_FLAG,BATCH_RECORD.HIERARCHY_FLAG,
    	BATCH_RECORD.SALESREP_OPTION,BATCH_RECORD.CONCURRENT_FLAG,BATCH_RECORD.LOG_NAME,BATCH_RECORD.STATUS,
    	BATCH_RECORD.LOGICAL_BATCH_ID,BATCH_RECORD.FORECAST_FLAG,BATCH_RECORD.ATTRIBUTE_CATEGORY,BATCH_RECORD.ATTRIBUTE1,
    	BATCH_RECORD.ATTRIBUTE2,BATCH_RECORD.ATTRIBUTE3,BATCH_RECORD.ATTRIBUTE4,BATCH_RECORD.ATTRIBUTE5,
    	BATCH_RECORD.ATTRIBUTE6,BATCH_RECORD.ATTRIBUTE7,BATCH_RECORD.ATTRIBUTE8,BATCH_RECORD.ATTRIBUTE9,
    	BATCH_RECORD.ATTRIBUTE10,BATCH_RECORD.ATTRIBUTE11,BATCH_RECORD.ATTRIBUTE12,BATCH_RECORD.ATTRIBUTE13,
    	BATCH_RECORD.ATTRIBUTE14,BATCH_RECORD.ATTRIBUTE15,BATCH_RECORD.START_DATE,BATCH_RECORD.END_DATE,
    	BATCH_RECORD.CALC_TYPE,BATCH_RECORD.INTERVAL_TYPE_ID,BATCH_RECORD.LEDGER_JE_BATCH_ID,
    	BATCH_RECORD.PROCESS_AUDIT_ID,fnd_global.user_id,sysdate,
    	BATCH_RECORD.OBJECT_VERSION_NUMBER,BATCH_RECORD.SECURITY_GROUP_ID);

   	--  Now you start working on entering the Batch Records.
   	-- if the Salesrep option is USER_SPECIFY then only you have to copy records for the Child.
   	--
   	if (batch_record.salesrep_option = 'USER_SPECIFY') then
        	-- Star
        	for calc_entries in rep_cursor
        	loop
            		-- Process the Entry Records here.
            		insert into cn_calc_submission_entries(ORG_ID,CALC_SUB_ENTRY_ID,CALC_SUB_BATCH_ID,SALESREP_ID,ATTRIBUTE_CATEGORY,
            		ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,
            		ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,CREATED_BY,
            		CREATION_DATE,SECURITY_GROUP_ID,HIERARCHY_FLAG)
            		values
            		(calc_entries.ORG_ID,CN_CALC_SUBMISSION_ENTRIES_S1.nextval,seq_batchid,calc_entries.SALESREP_ID,
            		calc_entries.ATTRIBUTE_CATEGORY,calc_entries.ATTRIBUTE1,calc_entries.ATTRIBUTE2,calc_entries.ATTRIBUTE3,
            		calc_entries.ATTRIBUTE4,calc_entries.ATTRIBUTE5,calc_entries.ATTRIBUTE6,calc_entries.ATTRIBUTE7,
            		calc_entries.ATTRIBUTE8,calc_entries.ATTRIBUTE9,calc_entries.ATTRIBUTE10,calc_entries.ATTRIBUTE11,
            		calc_entries.ATTRIBUTE12,calc_entries.ATTRIBUTE13,calc_entries.ATTRIBUTE14,calc_entries.ATTRIBUTE15,
           		fnd_global.user_id,sysdate,calc_entries.SECURITY_GROUP_ID,calc_entries.HIERARCHY_FLAG);

        	end loop;
   	end if;


    	-- Now Start processing the Bonus Plan Elements Copy
   	if (batch_record.calc_type = 'BONUS') then
        	-- Star
        	for bonus_entries in bonus_cursor
        	loop
            		-- Process the Entry Records here.
            		insert into cn_calc_sub_quotas
            		(ORG_ID,CALC_SUB_QUOTA_ID,CALC_SUB_BATCH_ID,QUOTA_ID,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,
            		ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,
            		ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,CREATED_BY,CREATION_DATE,SECURITY_GROUP_ID)
            		values
            		(bonus_entries.ORG_ID,CN_CALC_SUB_QUOTAS_S.nextval,seq_batchid,bonus_entries.QUOTA_ID,
            		bonus_entries.ATTRIBUTE_CATEGORY,bonus_entries.ATTRIBUTE1,bonus_entries.ATTRIBUTE2,
            		bonus_entries.ATTRIBUTE3,bonus_entries.ATTRIBUTE4,bonus_entries.ATTRIBUTE5,bonus_entries.ATTRIBUTE6,
            		bonus_entries.ATTRIBUTE7,bonus_entries.ATTRIBUTE8,bonus_entries.ATTRIBUTE9,bonus_entries.ATTRIBUTE10,
            		bonus_entries.ATTRIBUTE11,bonus_entries.ATTRIBUTE12,bonus_entries.ATTRIBUTE13,bonus_entries.ATTRIBUTE14,
            		bonus_entries.ATTRIBUTE15,fnd_global.user_id,sysdate,bonus_entries.SECURITY_GROUP_ID);

        	end loop;
   	end if;

    	-- Store the new batchid in the out variable.
        p_out_calc_sub_batch_id := seq_batchid;

    	-- Close all cursors.
    	if(batch_cursor%ISOPEN) then
        	close batch_cursor;
    	end if;

    	IF FND_API.To_Boolean(p_commit) THEN
         	COMMIT WORK;
       	END IF;

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pvt.copybatch.end',
	      		    'End of copybatch'  );
    end if;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  copybatch_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	   (p_count                 =>      x_msg_count             ,
	    p_data                  =>      x_msg_data              ,
	    p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  copybatch_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO copybatch_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	       FND_MSG_PUB.add_exc_msg
	        (G_PKG_NAME          ,
	        'copybatch');
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );

    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_calc_submission_pvt.CopyBatch.exception',
	      		      sqlerrm);
    end if;

END CopyBatch;

END CN_CALC_SUBMISSION_PVT;

/
