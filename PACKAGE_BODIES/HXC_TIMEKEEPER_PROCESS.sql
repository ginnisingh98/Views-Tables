--------------------------------------------------------
--  DDL for Package Body HXC_TIMEKEEPER_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMEKEEPER_PROCESS" AS
/* $Header: hxctksta.pkb 120.12.12010000.14 2009/10/13 14:57:38 sabvenug ship $ */

g_debug boolean := hr_utility.debug_enabled;
 PROCEDURE timekeeper_query (
  p_timekeeper_data IN OUT NOCOPY t_timekeeper_table,
  p_timekeeper_id IN NUMBER,
  p_start_period IN DATE,
  p_end_period IN DATE,
  p_group_id IN NUMBER,
  p_resource_id IN NUMBER,
  p_attribute1 IN VARCHAR2,
  p_attribute2 IN VARCHAR2,
  p_attribute3 IN VARCHAR2,
  p_attribute4 IN VARCHAR2,
  p_attribute5 IN VARCHAR2,
  p_attribute6 IN VARCHAR2,
  p_attribute7 IN VARCHAR2,
  p_attribute8 IN VARCHAR2,
  p_attribute9 IN VARCHAR2,
  p_attribute10 IN VARCHAR2,
  p_attribute11 IN VARCHAR2,
  p_attribute12 IN VARCHAR2,
  p_attribute13 IN VARCHAR2,
  p_attribute14 IN VARCHAR2,
  p_attribute15 IN VARCHAR2,
  p_attribute16 IN VARCHAR2,
  p_attribute17 IN VARCHAR2,
  p_attribute18 IN VARCHAR2,
  p_attribute19 IN VARCHAR2,
  p_attribute20 IN VARCHAR2,
  p_status_code IN VARCHAR2,
  p_rec_periodid IN NUMBER,
  p_superflag
/*ADVICE(128): Unreferenced parameter [552] */
              IN VARCHAR2,
  p_reqryflg IN VARCHAR2,
  p_trx_lock_id IN NUMBER,
  p_row_lock_id IN VARCHAR2,
  p_person_type IN VARCHAR2,
  p_message_type IN VARCHAR2,
  p_query_type IN VARCHAR2,
  p_lock_profile IN VARCHAR2,
  p_message_text IN VARCHAR2,
  p_late_reason IN VARCHAR2,
  p_change_reason IN VARCHAR2,
  p_audit_enabled IN VARCHAR2,
  p_audit_history IN VARCHAR2
 ) IS
/*Cursor Modified By Mithun for CWK Terminate Bug*/
  CURSOR c_resource_info (
   p_timekeeper_id
/*ADVICE(145): This definition hides another one [556] */

/*ADVICE(147): Unreferenced parameter [552] */
                   IN NUMBER,
   p_start_period
/*ADVICE(150): This definition hides another one [556] */
                  IN DATE,
   p_end_period
/*ADVICE(153): This definition hides another one [556] */
                IN DATE,
   p_group_id
/*ADVICE(156): This definition hides another one [556] */
              IN NUMBER,
   p_resource_id
/*ADVICE(159): This definition hides another one [556] */
                 IN NUMBER,
   p_person_type
/*ADVICE(162): This definition hides another one [556] */
                 IN VARCHAR2
  ) IS
   SELECT   ppf.person_id person_id, ppf.full_name,
            NVL (ppf.employee_number, ppf.npw_number) employee_number,
            hr_person_type_usage_info.get_user_person_type (p_start_period, ppf.person_id) person_type
   FROM     hxc_tk_group_queries htgq,
            hxc_tk_groups htg,
            hxc_tk_group_query_criteria htgqc,
            per_all_people_f ppf,
            per_all_assignments_f paa,
            per_person_type_usages_f ptu,
            per_person_types ppt
   WHERE    ppf.person_id = paa.person_id
AND         ppt.person_type_id = ptu.person_type_id
AND         ppt.system_person_type IN ('EMP', 'EMP_APL', 'CWK','EX_EMP', 'EX_CWK')
AND         (   p_person_type IS NULL
             OR (    DECODE (ppt.system_person_type, 'EMP_APL', 'EMP', ppt.system_person_type) =
                                                                                           p_person_type
                 AND p_person_type IS NOT NULL
                )
            )
AND         ptu.person_id = ppf.person_id
AND         p_start_period <= ptu.effective_end_date
AND         p_end_period >= ptu.effective_start_date
AND         paa.primary_flag = 'Y'
AND         paa.assignment_type IN ('E', 'C')
AND         p_start_period <= paa.effective_end_date
AND         p_end_period >= paa.effective_start_date
AND         p_start_period <= ppf.effective_end_date
AND         p_end_period >= ppf.effective_start_date
AND         ppf.person_id = htgqc.criteria_id
AND         htgqc.tk_group_query_id = htgq.tk_group_query_id
AND         htgq.tk_group_id = htg.tk_group_id
AND         htg.business_group_id = ppf.business_group_id
AND         htg.tk_group_id = p_group_id
AND         ppf.person_id = NVL (p_resource_id, ppf.person_id)
AND         htgq.include_exclude = 'I'
AND         htgqc.criteria_type = 'PERSON'
AND         ppf.effective_end_date = (SELECT MAX (ppf2.effective_end_date)
                                      FROM   per_people_f ppf2, per_all_assignments_f paa2
                                      WHERE  ppf2.person_id = paa2.person_id
AND                                          paa2.primary_flag = 'Y'
AND                                          paa2.assignment_type IN ('E', 'C')
AND                                          p_start_period <= paa2.effective_end_date
AND                                          p_end_period >= paa2.effective_start_date
AND                                          p_start_period <= ppf2.effective_end_date
AND                                          p_end_period >= ppf2.effective_start_date
AND                                          ppf2.person_id = ppf.person_id)
   UNION
   SELECT   ppf.person_id person_id, ppf.full_name,
            NVL (ppf.employee_number, ppf.npw_number) employee_number,
            hr_person_type_usage_info.get_user_person_type (p_start_period, ppf.person_id) person_type
   FROM     hxc_tk_group_queries htgq,
            hxc_tk_groups htg,
            hxc_tk_group_query_criteria htgqc,
            per_all_people_f ppf,
            per_all_assignments_f paa,
            per_person_type_usages_f ptu,
            per_person_types ppt
   WHERE    ppf.person_id = paa.person_id
AND         ppt.person_type_id = ptu.person_type_id
AND         ppt.system_person_type IN ('EMP', 'EMP_APL', 'CWK','EX_EMP')
AND         ptu.person_id = ppf.person_id
AND         (   p_person_type IS NULL
             OR (    DECODE (ppt.system_person_type, 'EMP_APL', 'EMP', ppt.system_person_type) =
                                                                                           p_person_type
                 AND p_person_type IS NOT NULL
                )
            )
AND         p_start_period <= ptu.effective_end_date
AND         p_end_period >= ptu.effective_start_date
AND         paa.primary_flag = 'Y'
AND         paa.assignment_type IN ('E', 'C')
AND         p_start_period <= paa.effective_end_date
AND         p_end_period >= paa.effective_start_date
AND         p_start_period <= ppf.effective_end_date
AND         p_end_period >= ppf.effective_start_date
AND         ppf.person_id = p_resource_id
AND         ppf.person_id = htgqc.criteria_id
AND         htgqc.tk_group_query_id = htgq.tk_group_query_id
AND         htgq.tk_group_id = htg.tk_group_id
AND         htg.business_group_id = ppf.business_group_id
AND         htgq.include_exclude = 'I'
AND         htgqc.criteria_type = 'PERSON'
AND         ppf.effective_end_date = (SELECT MAX (ppf2.effective_end_date)
                                      FROM   per_people_f ppf2, per_all_assignments_f paa2
                                      WHERE  ppf2.person_id = paa2.person_id
AND                                          paa2.primary_flag = 'Y'
AND                                          paa2.assignment_type IN ('E', 'C')
AND                                          p_start_period <= paa2.effective_end_date
AND                                          p_end_period >= paa2.effective_start_date
AND                                          p_start_period <= ppf2.effective_end_date
AND                                          p_end_period >= ppf2.effective_start_date
AND                                          ppf2.person_id = ppf.person_id)
   ORDER BY 2;

  CURSOR c_timecard_info (
   p_resource_id
/*ADVICE(261): This definition hides another one [556] */
                 IN NUMBER,
   p_start_period
/*ADVICE(264): This definition hides another one [556] */
                  IN DATE,
   p_end_period
/*ADVICE(267): This definition hides another one [556] */
                IN DATE
  ) IS
   SELECT time_building_block_id, object_version_number, start_time, comment_text, created_by,
          creation_date, last_updated_by, last_update_date, last_update_login
   FROM   hxc_time_building_blocks
   WHERE  resource_id = p_resource_id
AND       SCOPE = 'TIMECARD'
AND       start_time = p_start_period
AND       stop_time = p_end_period
AND       date_to = hr_general.end_of_time;

  CURSOR c (
   p_detailid NUMBER
  ) IS
   SELECT *
   FROM   hxc_tk_detail_temp
   WHERE  detailid = p_detailid;

  c_row                     hxc_tk_detail_temp%ROWTYPE;

  CURSOR c_detail_info (
   timecard_id IN NUMBER,
   timecard_ovn IN NUMBER
  ) IS
   SELECT   detail.time_building_block_id detail_id, detail.object_version_number detail_ovn,
            detail.measure, DAY.start_time, detail.start_time time_in, detail.stop_time time_out,
            detail.comment_text
   FROM     hxc_time_building_blocks detail, hxc_time_building_blocks DAY
   WHERE    DAY.parent_building_block_id = timecard_id
AND         DAY.parent_building_block_ovn = timecard_ovn
AND         detail.date_to = hr_general.end_of_time
AND         detail.SCOPE = 'DETAIL'
AND         detail.parent_building_block_id = DAY.time_building_block_id
AND         detail.parent_building_block_ovn = DAY.object_version_number
AND         DAY.SCOPE = 'DAY'
AND         DAY.date_to = hr_general.end_of_time
   ORDER BY 4, 5, 1; --nitin


/*  UNCOMMENT WHEN hxc_timecard_summary is enable
    CURSOR c_timecard_status (timecard_id IN NUMBER, timecard_ovn IN NUMBER)
    IS
      SELECT approval_status
      FROM hxc_timecard_summary
      WHERE timecard_id = time_building_block_id
         AND timecard_ovn = time_building_block_ovn;
*/
  l_table_counter           NUMBER
/*ADVICE(316): NUMBER has no precision [315] */
                                                                          := 0;
  l_day_index
/*ADVICE(319): Unreferenced variable [553] */
                            NUMBER
/*ADVICE(321): NUMBER has no precision [315] */
                                  ;
  l_detail_index            NUMBER
/*ADVICE(324): NUMBER has no precision [315] */
                                  ;
  l_attribute_index         NUMBER
/*ADVICE(327): NUMBER has no precision [315] */
                                                                          := 0;
  l_index_buffer            NUMBER
/*ADVICE(330): NUMBER has no precision [315] */
                                                                          := 0;
  l_record_index_buffer     NUMBER
/*ADVICE(333): NUMBER has no precision [315] */
                                                                          := 0;
  l_attributes              hxc_attribute_table_type;
  l_timecard                hxc_block_table_type;
  l_messages                hxc_message_table_type;
  l_alias_def_list_index
/*ADVICE(339): Unreferenced variable [553] */
                            NUMBER
/*ADVICE(341): NUMBER has no precision [315] */
                                  ;
  l_alias_type
/*ADVICE(344): Unreferenced variable [553] */
                            VARCHAR2 (80);
  l_buffer_info             t_buffer_table;
  t_base_table              t_base_info;
  t_base_index              NUMBER
/*ADVICE(349): NUMBER has no precision [315] */
                                                                          := 0;

  /* Added for bug 8775740 OTL ABSENCE INTEGRATION
    Declarations
  */

  --  change start

  l_table_counter_tmp           NUMBER;  -- SVG CHANGE
  t_tk_abs_tab		    hxc_timekeeper_process.t_tk_abs_tab_type;
  l_pref_table   	    hxc_preference_evaluation.t_pref_table;
  l_pref_index			NUMBER;
  l_pref_date			DATE;
  l_abs_tc_start		DATE;
  l_abs_tc_end			DATE;

  -- change end


  l_found_hours_type        BOOLEAN;
  l_found_timecard          BOOLEAN                                       := FALSE;
  l_detail_start_time       DATE;
  l_detail_measure          NUMBER
/*ADVICE(355): NUMBER has no precision [315] */
                                  ;
  l_detail_id               NUMBER
/*ADVICE(358): NUMBER has no precision [315] */
                                  ;
  l_detail_ovn              NUMBER
/*ADVICE(361): NUMBER has no precision [315] */
                                  ;
  l_detail_time_in          DATE;
  l_detail_time_out         DATE;
  l_detail_comment_text     VARCHAR2 (2000)                               := NULL;
/*ADVICE(366): VARCHAR2 declaration with length greater than 500 characters [307] */

/*ADVICE(368): Initialization to NULL is superfluous [417] */

  l_detail_info_table       t_detail_info_table;
  l_day_id_info_table       t_day_id_info_table;
  l_timecard_id             NUMBER
/*ADVICE(373): NUMBER has no precision [315] */
                                  ;
  l_timecard_ovn            NUMBER
/*ADVICE(376): NUMBER has no precision [315] */
                                  ;
  l_timecard_start_time     DATE;
  l_timecard_comment_text   VARCHAR2 (2000)                               := NULL;
/*ADVICE(380): VARCHAR2 declaration with length greater than 500 characters [307] */

/*ADVICE(382): Initialization to NULL is superfluous [417] */

  l_last_update_date        DATE;
  l_last_updated_by         NUMBER (16);
  l_last_update_login       NUMBER (16);
  l_created_by              NUMBER (16);
  l_creation_date           DATE;
  l_query                   BOOLEAN;
  l_audit_query             BOOLEAN;
  l_approval_style_id       NUMBER
/*ADVICE(392): NUMBER has no precision [315] */
                                  ;
  l_approval_status         VARCHAR2 (80);
  l_found_detail            BOOLEAN                                       := FALSE;
  l_rec_periodid            NUMBER
/*ADVICE(397): NUMBER has no precision [315] */
                                  ;
  l_status_code             VARCHAR2 (80);
  l_timecard_status         VARCHAR2 (80);
  l_timecard_status_meaning VARCHAR2 (80);
  l_emp_negpref             VARCHAR2 (150);
  l_emp_recpref             NUMBER
/*ADVICE(404): NUMBER has no precision [315] */
                                  ;
  l_emp_appstyle            NUMBER
/*ADVICE(407): NUMBER has no precision [315] */
                                  ;
  l_emp_layout1             NUMBER
/*ADVICE(410): NUMBER has no precision [315] */
                                  ;
  l_emp_layout2             NUMBER
/*ADVICE(413): NUMBER has no precision [315] */
                                  ;
  l_emp_layout3             NUMBER
/*ADVICE(416): NUMBER has no precision [315] */
                                  ;
  l_emp_layout4             NUMBER
/*ADVICE(419): NUMBER has no precision [315] */
                                  ;
  l_emp_layout5             NUMBER
/*ADVICE(422): NUMBER has no precision [315] */
                                  ;
  l_emp_layout6             NUMBER
/*ADVICE(425): NUMBER has no precision [315] */
                                  ;
  l_emp_layout7             NUMBER
/*ADVICE(428): NUMBER has no precision [315] */
                                  ;
  l_emp_layout8             NUMBER
/*ADVICE(431): NUMBER has no precision [315] */
                                  ;
  l_emp_edits               VARCHAR2 (150);
  l_pastdt                  VARCHAR2 (30);
  l_futuredt                VARCHAR2 (30);
  num
/*ADVICE(437): Unreferenced variable [553] */
                            NUMBER
/*ADVICE(439): NUMBER has no precision [315] */
                                  ;
  n
/*ADVICE(442): Unreferenced variable [553] */
                            NUMBER
/*ADVICE(444): NUMBER has no precision [315] */
                                                                          := 0;
  changed_no                NUMBER
/*ADVICE(447): NUMBER has no precision [315] */
                                                                          := 0;
  changed                   VARCHAR2 (5)                                  := 'N';
  emp_tab_index             NUMBER
/*ADVICE(451): NUMBER has no precision [315] */
                                                                          := 0;
  tc_start                  DATE;
  tc_end                    DATE;
  emp_qry_tc_info           hxc_timekeeper_utilities.emptctab;
  l_add_index_day           NUMBER
/*ADVICE(457): NUMBER has no precision [315] */
                                                                          := 0;
  l_resource_tc_table       t_resource_tc_table;
  l_timecard_index_info     hxc_timekeeper_process.t_timecard_index_info;
  l_attribute_index_info    hxc_timekeeper_process.t_attribute_index_info;
  l_emp_start_date          DATE;
  l_emp_terminate_date      DATE;
  l_row_id                  ROWID
/*ADVICE(464): Use of ROWID [113] */
                                 ;
  l_tc_lock_success         VARCHAR2 (30)                                 := 'FALSE';
  l_tc_lock_boolean         BOOLEAN                                       := FALSE;
  l_process_lock_type       VARCHAR2 (80)                         := hxc_lock_util.c_pui_timekeeper_action;
  l_relased_success
/*ADVICE(470): Unreferenced variable [553] */
                            BOOLEAN;
  l_lock_trx_id             NUMBER (15)                                   := p_trx_lock_id;
  l_row_lock_id             VARCHAR2 (30)                                 := p_row_lock_id;
  l_timecard_message_code   VARCHAR2 (30)                                 := NULL;
/*ADVICE(475): Initialization to NULL is superfluous [417] */

  l_timecard_reason_code    VARCHAR2 (30)                                 := NULL;
/*ADVICE(478): Initialization to NULL is superfluous [417] */

  l_timecard_message        VARCHAR2 (240)                                := NULL;
/*ADVICE(481): Initialization to NULL is superfluous [417] */

  l_index                   NUMBER
/*ADVICE(484): NUMBER has no precision [315] */
                                  ;
  l_pref_exception          EXCEPTION;

  l_abs_pending_appr_notif  EXCEPTION;

  l_lock_not_obtained	      EXCEPTION;

  l_terminated_list         VARCHAR2 (32000);
/*ADVICE(488): VARCHAR2 declaration with length greater than 500 characters [307] */

  l_audit_enabled           VARCHAR2 (150)                                := NULL;
/*ADVICE(491): Initialization to NULL is superfluous [417] */



----------------------------------------------------------------------
--Private function to check if timecard has message of type queried
----------------------------------------------------------------------
  FUNCTION tc_has_message (
   p_bb_id IN NUMBER,
   p_bb_ovn IN NUMBER,
   p_msg_type IN VARCHAR2,
   p_msg_text IN VARCHAR2
  )
   RETURN BOOLEAN IS
   CURSOR csr_get_timecard IS
    SELECT detail.time_building_block_id bb_id, detail.object_version_number bb_ovn
    FROM   hxc_time_building_blocks detail, hxc_time_building_blocks DAY
    WHERE  DAY.parent_building_block_id = p_bb_id
/*ADVICE(509): Cursor references an external variable (use a parameter) [209] */

AND        DAY.parent_building_block_ovn = p_bb_ovn
/*ADVICE(512): Cursor references an external variable (use a parameter) [209] */

AND        detail.date_to = hr_general.end_of_time
AND        detail.SCOPE = 'DETAIL'
AND        detail.parent_building_block_id = DAY.time_building_block_id
AND        detail.parent_building_block_ovn = DAY.object_version_number
AND        DAY.SCOPE = 'DAY'
AND        DAY.date_to = hr_general.end_of_time;

   CURSOR c_get_warning_msg (
    bb_id NUMBER,
    bb_ovn NUMBER,
    msg_type VARCHAR2,
    msg_text VARCHAR2
   ) IS
    SELECT 'Y'
    FROM   hxc_errors
    WHERE  time_building_block_id = bb_id
AND        time_building_block_ovn = bb_ovn
AND        (date_to = hr_general.end_of_time OR date_to IS NULL)
AND        message_level = DECODE (msg_type, 'ALL', message_level, NULL, message_level, msg_type)
AND        message_name = DECODE (msg_text, NULL, message_name, msg_text);

   l_msg_flag VARCHAR2 (10) := NULL;
/*ADVICE(536): Initialization to NULL is superfluous [417] */

  BEGIN
   l_msg_flag := NULL;

-- check for timecard scope
   OPEN c_get_warning_msg (p_bb_id, p_bb_ovn, p_msg_type, p_msg_text);
   FETCH c_get_warning_msg INTO l_msg_flag;
   CLOSE c_get_warning_msg;

   IF l_msg_flag IS NOT NULL THEN
    RETURN TRUE;
   END IF;

   FOR timecard_error_rec IN csr_get_timecard LOOP
    OPEN c_get_warning_msg (timecard_error_rec.bb_id, timecard_error_rec.bb_ovn, p_msg_type, p_msg_text);
    FETCH c_get_warning_msg INTO l_msg_flag;
    CLOSE c_get_warning_msg;

    IF l_msg_flag IS NOT NULL THEN
     RETURN TRUE;
/*ADVICE(557): A RETURN statement is used in a FOR loop [504] */

    END IF;
   END LOOP;

   IF l_msg_flag IS NULL THEN
    RETURN FALSE;
   ELSE
    RETURN TRUE;
   END IF;
/*ADVICE(567): Last statement in function must be a RETURN [510] */

  END tc_has_message;
/*ADVICE(570): Function with more than one RETURN statement in the executable section [512] */


  FUNCTION tc_has_reason (
   p_bb_id IN NUMBER,
   p_bb_ovn IN NUMBER,
   p_late_reason
/*ADVICE(577): This definition hides another one [556] */
                 IN VARCHAR2,
   p_change_reason
/*ADVICE(580): This definition hides another one [556] */
                   IN VARCHAR2
  )
   RETURN BOOLEAN IS
   CURSOR csr_get_timecard IS
    SELECT detail.time_building_block_id bb_id, detail.object_version_number bb_ovn
    FROM   hxc_time_building_blocks detail, hxc_time_building_blocks DAY
    WHERE  DAY.parent_building_block_id = p_bb_id
/*ADVICE(588): Cursor references an external variable (use a parameter) [209] */

AND        DAY.parent_building_block_ovn = p_bb_ovn
/*ADVICE(591): Cursor references an external variable (use a parameter) [209] */

AND        detail.date_to = hr_general.end_of_time
AND        detail.SCOPE = 'DETAIL'
AND        detail.parent_building_block_id = DAY.time_building_block_id
AND        detail.parent_building_block_ovn = DAY.object_version_number
AND        DAY.SCOPE = 'DAY'
AND        DAY.date_to = hr_general.end_of_time;

   CURSOR c_get_reason (
    bb_id NUMBER,
    bb_ovn NUMBER,
    late_reason VARCHAR2,
    change_reason VARCHAR2,
    audit_history VARCHAR2
   ) IS
    SELECT 'Y'
    FROM   hxc_time_attributes
    WHERE  time_attribute_id IN (SELECT time_attribute_id
                                 FROM   hxc_time_attribute_usages
                                 WHERE  time_building_block_id = bb_id
AND                                     time_building_block_ovn = bb_ovn)
AND        attribute_category = 'REASON'
AND        attribute1 = DECODE (attribute3, 'CHANGE', change_reason, 'LATE', late_reason)
AND        NVL (attribute7, '-99') = DECODE (audit_history, NULL, NVL (attribute7, '-99'), audit_history);

   CURSOR c_get_reason_null (
    bb_id NUMBER,
    bb_ovn NUMBER,
    audit_history VARCHAR2
   ) IS
    SELECT 'Y'
    FROM   hxc_time_attributes
    WHERE  time_attribute_id IN (SELECT time_attribute_id
                                 FROM   hxc_time_attribute_usages
                                 WHERE  time_building_block_id = bb_id
AND                                     time_building_block_ovn = bb_ovn)
AND        attribute_category = 'REASON'
AND        attribute7 = DECODE (audit_history, NULL, attribute7, audit_history);

   l_reason_flag VARCHAR2 (10) := NULL;
/*ADVICE(632): Initialization to NULL is superfluous [417] */

  BEGIN
   g_debug :=hr_utility.debug_enabled;
   l_reason_flag := NULL;


-- check for timecard scope

   IF (p_late_reason IS NOT NULL OR p_change_reason IS NOT NULL) THEN
    FOR timecard_error_rec IN csr_get_timecard LOOP
     if g_debug then
	     hr_utility.TRACE ('timecard_error_rec.bb_id'|| timecard_error_rec.bb_id);
	     hr_utility.TRACE ('timecard_error_rec.bb_ovn'|| timecard_error_rec.bb_ovn);
	     hr_utility.TRACE ('timecard_error_rec.bb_ovn'|| p_late_reason);
	     hr_utility.TRACE ('timecard_error_rec.bb_ovn'|| p_audit_history);
     end if;
/*ADVICE(646): Local program unit references an external variable (use a parameter or pull in the
              definition) [210] */

     l_reason_flag := NULL;
     OPEN c_get_reason (
      timecard_error_rec.bb_id,
      timecard_error_rec.bb_ovn,
      p_late_reason,
      p_change_reason,
      p_audit_history
/*ADVICE(656): Local program unit references an external variable (use a parameter or pull in the
              definition) [210] */

     );
     FETCH c_get_reason INTO l_reason_flag;
     CLOSE c_get_reason;

     IF l_reason_flag IS NOT NULL THEN
      RETURN TRUE;
/*ADVICE(665): A RETURN statement is used in a FOR loop [504] */

     END IF;
    END LOOP;
   ELSE
    FOR timecard_error_rec IN csr_get_timecard LOOP
     l_reason_flag := NULL;
     OPEN c_get_reason_null (timecard_error_rec.bb_id, timecard_error_rec.bb_ovn, p_audit_history
/*ADVICE(673): Local program unit references an external variable (use a parameter or pull in the
              definition) [210] */
                                                                                                 );
     FETCH c_get_reason_null INTO l_reason_flag;
     CLOSE c_get_reason_null;

     IF l_reason_flag IS NOT NULL THEN
      RETURN TRUE;
/*ADVICE(681): A RETURN statement is used in a FOR loop [504] */

     END IF;
    END LOOP;
   END IF;

   IF l_reason_flag IS NULL THEN
    RETURN FALSE;
   ELSE
    RETURN TRUE;
   END IF;
/*ADVICE(692): Last statement in function must be a RETURN [510] */

  END tc_has_reason ;
/*ADVICE(695): Function with more than one RETURN statement in the executable section [512] */


--Main Query Begin
 BEGIN
  l_attributes := hxc_attribute_table_type ();
  l_timecard := hxc_block_table_type ();
  l_messages := hxc_message_table_type ();
  g_debug :=hr_utility.debug_enabled;


  g_resource_prepop_count:=1;

 /* Added for bug 8775740 HR OTL Absence Integration.

 Setting the value for the HR OTL Integration Profile to a
 global var.
 */
-- Change start
g_abs_intg_profile_set:= nvl(FND_PROFILE.VALUE('HR_ABS_OTL_INTEGRATION'),'N');
-- Change end


  --      DELETE FROM detail_temp;
  --get the timekeeper setup preference for details  button  to decide the category
  IF p_query_type IS NOT NULL THEN
   g_resource_tc_table.DELETE;
   g_submit_table.DELETE;
   l_index := g_timekeeper_data_query.FIRST;

   LOOP
    EXIT WHEN NOT g_timekeeper_data_query.EXISTS (l_index);

    IF ((p_query_type = 'CHECKBOX_ENABLED') --OR (p_query_type = 'SKIP_ENABLED')
                                           ) THEN
     g_timekeeper_data_query (l_index).check_box := 'Y';
    END IF;

    IF ((p_query_type = 'CHECKBOX_DISABLED') --    OR (p_query_type = 'SKIP_DISABLED')
                                            ) THEN
     g_timekeeper_data_query (l_index).check_box := 'N';
    END IF;

    IF g_timekeeper_data_query (l_index).check_box = 'Y' THEN
     g_submit_table (g_timekeeper_data_query (l_index).resource_id).resource_id :=
                                                           g_timekeeper_data_query (l_index).resource_id;
     g_submit_table (g_timekeeper_data_query (l_index).resource_id).timecard_id :=
                                                           g_timekeeper_data_query (l_index).timecard_id;
     g_submit_table (g_timekeeper_data_query (l_index).resource_id).start_time :=
                                                 g_timekeeper_data_query (l_index).timecard_start_period;
     g_submit_table (g_timekeeper_data_query (l_index).resource_id).stop_time :=
                                                   g_timekeeper_data_query (l_index).timecard_end_period;
     g_submit_table (g_timekeeper_data_query (l_index).resource_id).row_lock_id :=
                                                           g_timekeeper_data_query (l_index).row_lock_id;
    END IF;

    IF      g_resource_tc_table.EXISTS (g_timekeeper_data_query (l_index).resource_id)
        AND g_timekeeper_data_query (l_index).check_box = 'Y' THEN
     g_resource_tc_table (g_timekeeper_data_query (l_index).resource_id).no_rows :=
                         g_resource_tc_table (g_timekeeper_data_query (l_index).resource_id).no_rows + 1;
    ELSE
     IF g_timekeeper_data_query (l_index).check_box = 'Y' THEN
      g_resource_tc_table (g_timekeeper_data_query (l_index).resource_id).no_rows := 1;
     ELSE
      g_resource_tc_table (g_timekeeper_data_query (l_index).resource_id).no_rows := 0;
     END IF;
    END IF;

    l_index := g_timekeeper_data_query.NEXT (l_index);
   END LOOP;

   p_timekeeper_data := g_timekeeper_data_query;
  ELSE -- global checkbix select
   --get the timekeeper setup preference for details  button  to decide the category

   IF g_base_att IS NULL THEN
    g_base_att := hxc_preference_evaluation.resource_preferences (
                   p_resource_id => p_timekeeper_id,
                   p_pref_code => 'TK_TCARD_SETUP',
                   p_attribute_n => 4,
                   p_evaluation_date => SYSDATE
                  );
   END IF;

   IF (g_tk_finish_process) THEN
    -- set the parameter to send back
    p_timekeeper_data := g_tk_data_query_from_process;
    -- reset the data
    g_tk_data_query_from_process.DELETE;
    g_from_tk_process := FALSE;
    g_tk_finish_process := FALSE;
   ELSE
    --detail table needs to be deleted when it is queried first time
    --to store the detail associated
    --p_reqryflg   is used to check the check box which got affected in requery only.

    if g_debug then
    	    hr_utility.TRACE ('p_reqryflg'|| p_reqryflg);
    end if;
    IF p_reqryflg = 'N' THEN
     --ctk --empty the detail_temp table
     g_detail_data.DELETE;

     DELETE FROM hxc_tk_detail_temp; --4191367
/*ADVICE(786): Use of DELETE or UPDATE without WHERE clause [313] */


     g_submit_table.DELETE;
     g_lock_table.DELETE;
     g_resource_tc_table.DELETE;
    END IF;

    FOR resource_info IN c_resource_info (
                          p_timekeeper_id,
                          p_start_period,
                          p_end_period,
                          p_group_id,
                          p_resource_id,
                          p_person_type
                         ) LOOP
     BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
      	      hr_utility.TRACE ('processing for'|| resource_info.person_id);
      end if;
      IF NOT (l_resource_tc_table.EXISTS (resource_info.person_id)) THEN
       -- first thing it is to add this person into the buffer table

       l_resource_tc_table (resource_info.person_id).index_string :=
                                                            'We are creating a timecard for this person';
       g_resource_tc_table (resource_info.person_id).index_string :=
                                                            'We are creating a timecard for this person';
       ---store the employee preferences

       l_emp_negpref := NULL;
       l_emp_recpref := NULL;
       l_emp_appstyle := NULL;
       l_emp_layout1 := NULL;
       l_emp_layout2 := NULL;
       l_emp_layout3 := NULL;
       l_emp_layout4 := NULL;
       l_emp_layout5 := NULL;
       l_emp_layout6 := NULL;
       l_emp_layout7 := NULL;
       l_emp_layout8 := NULL;
       l_emp_edits := NULL;
       l_audit_enabled := NULL;

       BEGIN
        hxc_timekeeper_utilities.get_emp_pref (
         resource_info.person_id,
         l_emp_negpref,
         l_emp_recpref,
         l_emp_appstyle,
         l_emp_layout1,
         l_emp_layout2,
         l_emp_layout3,
         l_emp_layout4,
         l_emp_layout5,
         l_emp_layout6,
         l_emp_layout7,
         l_emp_layout8,
         l_emp_edits,
         l_pastdt,
         l_futuredt,
         l_emp_start_date,
         l_emp_terminate_date,
         l_audit_enabled
        );
       EXCEPTION
        WHEN OTHERS THEN
         IF l_terminated_list IS NOT NULL THEN
          l_terminated_list :=
             l_terminated_list || ' , ' || resource_info.employee_number || ' - ' || resource_info.full_name;
         ELSE
          l_terminated_list := resource_info.employee_number || ' - ' || resource_info.full_name;
         END IF;

         l_terminated_list := REPLACE (l_terminated_list, ', ,', ',');
         RAISE l_pref_exception;
/*ADVICE(859): A WHEN OTHERS clause is used in the exception section without any other specific handlers
              [201] */

       END;

       --
             --initialize the emp_qry_tc_info table used to store the saved timecards for that person



       emp_qry_tc_info.DELETE;
       --populate emp_qry_tc_info table with saved timecards in that period

       hxc_timekeeper_utilities.populate_query_tc_tab (
        resource_info.person_id,
        p_start_period,
        p_end_period,
        emp_qry_tc_info
       );
       ---now we check if he is mid period employee or normal employee
       l_audit_query := FALSE;
       if g_debug then
               hr_utility.TRACE ('l_audit_enabled'|| l_audit_enabled);
               hr_utility.TRACE ('p_audit_enabled'|| p_audit_enabled);
       end if;
       IF (   (l_audit_enabled IS NOT NULL AND p_audit_enabled = 'Y')
           OR (l_audit_enabled IS NULL AND p_audit_enabled = 'N')
           OR p_audit_enabled IS NULL
          ) THEN
        l_audit_query := TRUE;
       END IF;
/*
       IF l_audit_query THEN
        ----hr_utility.TRACE ('l_audit_query IS TRUE');
       ELSE
        ----hr_utility.TRACE ('l_audit_query IS FALSE');
       END IF;
JOEL */
       l_query := FALSE;

       IF  emp_qry_tc_info.COUNT > 1 AND NVL (l_emp_recpref, '-999') = NVL (p_rec_periodid, '-999') THEN
        if g_debug then
                hr_utility.trace('Multiple Timecard exists and he is mid period change');
        end if;
        l_query := TRUE;
       ELSIF emp_qry_tc_info.COUNT = 1 THEN
        if g_debug then
                hr_utility.trace ('Normal employee or mid period with no timecard in range');
        end if;
        l_query := TRUE;
       END IF;

       -- Now we are looping thro this table to query all the timecards.
/* JOEL
       IF l_query THEN
        ----hr_utility.TRACE ('l_query IS TRUE');
       ELSE
        ----hr_utility.TRACE ('l_query IS FALSE');
       END IF;
*/
       IF  l_query AND l_audit_query THEN
        emp_tab_index := emp_qry_tc_info.FIRST;

        LOOP
         EXIT WHEN NOT emp_qry_tc_info.EXISTS (emp_tab_index);
         l_found_timecard := FALSE;
         --tc_start   stores the timecard start period
         --tc_end     stores the timecard end period.

         tc_start := TO_DATE (emp_qry_tc_info (emp_tab_index).tc_frdt, 'DD-MM-RRRR');
         tc_end := TO_DATE (emp_qry_tc_info (emp_tab_index).tc_todt, 'DD-MM-RRRR');

         IF tc_start <> p_start_period THEN
          l_add_index_day := (tc_start - p_start_period); -- this is used to add an offset for matrix of hours
         ELSE
          l_add_index_day := 0;
         END IF;

         OPEN c_timecard_info (resource_info.person_id, tc_start, tc_end + g_one_day);
         FETCH c_timecard_info INTO l_timecard_id,
                                    l_timecard_ovn,
                                    l_timecard_start_time,
                                    l_timecard_comment_text,
                                    l_created_by,
                                    l_creation_date,
                                    l_last_updated_by,
                                    l_last_update_date,
                                    l_last_update_login;
/*ADVICE(942): FETCH into a list of variables instead of a record [204] */


         -- find the status of the timecard
         IF c_timecard_info%FOUND THEN
          -- when the hxc_timecard_summary is enable
          -- we need to open c_timecard_status instead.



          l_timecard_status :=
                        hxc_timecard_search_pkg.get_timecard_status_code (l_timecard_id, l_timecard_ovn);
          l_timecard_status_meaning :=
                                     hr_bis.bis_decode_lookup ('HXC_APPROVAL_STATUS', l_timecard_status);
         END IF;

         IF p_status_code IS NULL THEN
          l_status_code := l_timecard_status;
         ELSE
          l_status_code := p_status_code;
         END IF;

         if g_debug then
                 hr_utility.TRACE ('p_message_type'|| p_message_type);
                 hr_utility.TRACE ('p_message_text'|| p_message_text);
         end if;
         -- check for timecard message associated
         IF tc_has_message (l_timecard_id, l_timecard_ovn, p_message_type, p_message_text) THEN
          l_timecard_message_code := 'MESSAGE';
          l_timecard_message := hr_bis.bis_decode_lookup ('HXC_TK_MESSAGE', l_timecard_message_code);
         ELSE
          l_timecard_message_code := NULL;
          l_timecard_message := NULL;
         END IF;

         IF tc_has_reason (l_timecard_id, l_timecard_ovn, p_late_reason, p_change_reason) THEN
          l_timecard_reason_code := 'REASON';
          if g_debug then
                  hr_utility.TRACE ('yes tc has reason');
          end if;
/*                               l_timecard_message :=
                                    hr_bis.bis_decode_lookup(
                                       'HXC_TK_MESSAGE',
                                       l_timecard_message_code
                                    );*/
         ELSE
          if g_debug then
                  hr_utility.TRACE ('no reason'|| l_timecard_reason_code);
          end if;
          l_timecard_reason_code := NULL;

--                              l_timecard_message := NULL;
         END IF;

         IF      c_timecard_info%FOUND
             AND l_timecard_status = l_status_code
             AND (p_message_type IS NULL OR l_timecard_message_code = 'MESSAGE')
             AND (p_message_text IS NULL OR l_timecard_message_code = 'MESSAGE')
             AND (p_change_reason IS NULL OR l_timecard_reason_code = 'REASON')
             AND (p_late_reason IS NULL OR l_timecard_reason_code = 'REASON')
             AND (p_audit_history IS NULL OR l_timecard_reason_code = 'REASON') THEN
          --now we lock the timecard
          IF  p_reqryflg = 'N' AND p_lock_profile = 'Y' THEN
           --lock only when user does fresh find

           l_row_id := NULL;
           l_row_lock_id := NULL;
           l_tc_lock_success := 'FALSE';
           hxc_lock_api.request_lock (
            p_process_locker_type => l_process_lock_type,
            p_resource_id => resource_info.person_id,
            p_start_time => p_start_period,
            p_stop_time => p_end_period + g_one_day,
            p_time_building_block_id => NULL,
            p_time_building_block_ovn => NULL,
            p_transaction_lock_id => l_lock_trx_id,
            p_messages => l_messages,
            p_row_lock_id => l_row_id,
            p_locked_success => l_tc_lock_boolean
           );
           l_row_lock_id := ROWIDTOCHAR (l_row_id);

           IF l_tc_lock_boolean THEN
            l_tc_lock_success := 'TRUE';
            g_lock_table (resource_info.person_id).row_lock_id := l_row_id;
            g_lock_table (resource_info.person_id).resource_id := resource_info.person_id;
            g_lock_table (resource_info.person_id).timecard_id := l_timecard_id;
            g_lock_table (resource_info.person_id).start_time := p_start_period;
            g_lock_table (resource_info.person_id).stop_time := p_end_period + g_one_day;
           ELSE
            l_tc_lock_success := 'FALSE';
           END IF;
          --nitin check
          --l_resource_tc_table (resource_info.person_id).lockid:=l_row_lock_id;
          ELSE
           IF l_row_lock_id IS NOT NULL THEN
            l_tc_lock_success := 'TRUE';
           ELSE
            l_tc_lock_success := 'FALSE';
           END IF;
          END IF;


--    CLOSE c_timecard_info;

          l_buffer_info.DELETE;
          l_index_buffer := 0;

-- rest the l_attribute_index
          l_attribute_index := 0;
          l_found_detail := FALSE;

--populate the attribute table
          l_attributes.DELETE;
          l_detail_info_table.DELETE;

--delete l_timecard before populating
	  l_timecard.DELETE;


if g_debug then
        hr_utility.trace('l_timecard_id'||l_timecard_id||' l_timecard_onv'||l_timecard_ovn);
end if;
-- populate detail information for this timecard
          FOR detail_info IN c_detail_info (l_timecard_id, l_timecard_ovn) LOOP
           l_detail_info_table (detail_info.detail_id).detail_id := detail_info.detail_id;
           l_detail_info_table (detail_info.detail_id).detail_ovn := detail_info.detail_ovn;
           l_detail_info_table (detail_info.detail_id).measure := detail_info.measure;
           l_detail_info_table (detail_info.detail_id).start_time := detail_info.start_time;
           l_detail_info_table (detail_info.detail_id).time_in := detail_info.time_in;
           l_detail_info_table (detail_info.detail_id).time_out := detail_info.time_out;
           l_detail_info_table (detail_info.detail_id).detail_comment_text := detail_info.comment_text;
          END LOOP;
/*ADVICE(1067): Nested LOOPs should all be labeled [406] */


if g_debug then
	         hr_utility.trace('SVG REACHED HERE 1');
end if;


--      Get the data actually stored in the database.


          hxc_timekeeper_utilities.create_attribute_structure (
           p_timecard_id => l_timecard_id,
           p_timecard_ovn => l_timecard_ovn,
           p_resource_id => resource_info.person_id,
           p_start_period => tc_start,
           p_end_period => tc_end,
           p_attributes => l_attributes,
           p_add_hours_type_id => NULL,
           p_attribute_index_info => l_attribute_index_info
          );
          --create timecard block


          create_timecard_day_structure (
           p_resource_id => resource_info.person_id,
           p_start_period => tc_start,
           p_end_period => tc_end,
           p_tc_frdt => tc_start,
           p_tc_todt => tc_end,
           p_timecard => l_timecard,
           p_attributes => l_attributes,
           p_day_id_info_table => l_day_id_info_table,
           p_approval_style_id => l_approval_style_id,
           p_approval_status => l_approval_status,
           p_comment_text => l_timecard_comment_text,
           p_timecard_status => l_timecard_status,
           p_attribute_index_info => l_attribute_index_info,
           p_timecard_index_info => l_timecard_index_info,
           p_timecard_id => l_timecard_id
          );

          -- call the alias translator to translate the attributes to OTL_ALIAS_ITEM_1...

          IF (l_attributes.COUNT > 0) THEN
           if g_debug then
                   hr_utility.trace ('count is greater');
           end if;
           hxc_alias_translator.do_retrieval_translation (
            p_attributes => l_attributes,
            p_blocks => l_timecard,
            p_start_time => tc_start,
            p_stop_time => tc_end,
            p_resource_id => p_timekeeper_id,
            p_processing_mode => hxc_alias_utility.c_tk_processing,
            p_messages => l_messages
           );
           --t_base_table--used to take the output of translator and convert into matrix

           t_base_index := 1;
           t_base_table.DELETE;


/*1                                 my_debug.print_attributes(
                                    '111',
                                    l_attributes
                                 );*/
--

-- SVG ADDED

/*

 IF g_debug then

   if (l_attributes.count>0) then


 hr_utility.trace(' SVG ATTRIBUTES TABLE START ');
 hr_utility.trace(' *****************');

 l_attribute_index := l_attributes.FIRST;

  LOOP
    EXIT WHEN NOT l_attributes.EXISTS (l_attribute_index);


   hr_utility.trace(' TIME_ATTRIBUTE_ID =   '|| l_attributes(l_attribute_index).TIME_ATTRIBUTE_ID);
   hr_utility.trace(' BUILDING_BLOCK_ID =   '|| l_attributes(l_attribute_index).BUILDING_BLOCK_ID )    ;
   hr_utility.trace(' ATTRIBUTE_CATEGORY =   '|| l_attributes(l_attribute_index).ATTRIBUTE_CATEGORY)    ;
   hr_utility.trace(' ATTRIBUTE1     =       '|| l_attributes(l_attribute_index).ATTRIBUTE1        )    ;
   hr_utility.trace(' ATTRIBUTE2  (p_alias_definition_id)   =       '|| l_attributes(l_attribute_index).ATTRIBUTE2        )    ;
   hr_utility.trace(' ATTRIBUTE3  (l_alias_value_id)    =       '|| l_attributes(l_attribute_index).ATTRIBUTE3        )    ;
   hr_utility.trace(' ATTRIBUTE4  (p_alias_type)   =       '|| l_attributes(l_attribute_index).ATTRIBUTE4        )    ;
   hr_utility.trace(' ATTRIBUTE5     =       '|| l_attributes(l_attribute_index).ATTRIBUTE5        )    ;
   hr_utility.trace(' ATTRIBUTE6     =       '|| l_attributes(l_attribute_index).ATTRIBUTE6        )    ;
   hr_utility.trace(' ATTRIBUTE7     =       '|| l_attributes(l_attribute_index).ATTRIBUTE7        )    ;
   hr_utility.trace(' ATTRIBUTE8     =       '|| l_attributes(l_attribute_index).ATTRIBUTE8        )    ;
   hr_utility.trace(' ATTRIBUTE9     =       '|| l_attributes(l_attribute_index).ATTRIBUTE9        )    ;
   hr_utility.trace(' ATTRIBUTE10    =       '|| l_attributes(l_attribute_index).ATTRIBUTE10       )    ;
   hr_utility.trace(' ATTRIBUTE11    =       '|| l_attributes(l_attribute_index).ATTRIBUTE11       )    ;
   hr_utility.trace(' ATTRIBUTE12    =       '|| l_attributes(l_attribute_index).ATTRIBUTE12       )    ;
   hr_utility.trace(' ATTRIBUTE13    =       '|| l_attributes(l_attribute_index).ATTRIBUTE13       )    ;
   hr_utility.trace(' ATTRIBUTE14    =       '|| l_attributes(l_attribute_index).ATTRIBUTE14       )    ;
   hr_utility.trace(' ATTRIBUTE15    =       '|| l_attributes(l_attribute_index).ATTRIBUTE15       )    ;
   hr_utility.trace(' ATTRIBUTE16    =       '|| l_attributes(l_attribute_index).ATTRIBUTE16       )    ;
   hr_utility.trace(' ATTRIBUTE17    =       '|| l_attributes(l_attribute_index).ATTRIBUTE17       )    ;
   hr_utility.trace(' ATTRIBUTE18    =       '|| l_attributes(l_attribute_index).ATTRIBUTE18       )    ;
   hr_utility.trace(' ATTRIBUTE19    =       '|| l_attributes(l_attribute_index).ATTRIBUTE19       )    ;
   hr_utility.trace(' ATTRIBUTE20    =       '|| l_attributes(l_attribute_index).ATTRIBUTE20       )    ;
   hr_utility.trace(' ATTRIBUTE21    =       '|| l_attributes(l_attribute_index).ATTRIBUTE21       )    ;
   hr_utility.trace(' ATTRIBUTE22    =       '|| l_attributes(l_attribute_index).ATTRIBUTE22       )    ;
   hr_utility.trace(' ATTRIBUTE23    =       '|| l_attributes(l_attribute_index).ATTRIBUTE23       )    ;
   hr_utility.trace(' ATTRIBUTE24    =       '|| l_attributes(l_attribute_index).ATTRIBUTE24       )    ;
   hr_utility.trace(' ATTRIBUTE25    =       '|| l_attributes(l_attribute_index).ATTRIBUTE25       )    ;
   hr_utility.trace(' ATTRIBUTE26    =       '|| l_attributes(l_attribute_index).ATTRIBUTE26       )    ;
   hr_utility.trace(' ATTRIBUTE27    =       '|| l_attributes(l_attribute_index).ATTRIBUTE27       )    ;
   hr_utility.trace(' ATTRIBUTE28    =       '|| l_attributes(l_attribute_index).ATTRIBUTE28       )    ;
   hr_utility.trace(' ATTRIBUTE29  (p_alias_ref_object)  =       '|| l_attributes(l_attribute_index).ATTRIBUTE29       )    ;
   hr_utility.trace(' ATTRIBUTE30  (p_alias_value_name)  =       '|| l_attributes(l_attribute_index).ATTRIBUTE30       )    ;
   hr_utility.trace(' BLD_BLK_INFO_TYPE_ID = '|| l_attributes(l_attribute_index).BLD_BLK_INFO_TYPE_ID  );
   hr_utility.trace(' OBJECT_VERSION_NUMBER = '|| l_attributes(l_attribute_index).OBJECT_VERSION_NUMBER );
   hr_utility.trace(' NEW             =       '|| l_attributes(l_attribute_index).NEW                   );
   hr_utility.trace(' CHANGED              =  '|| l_attributes(l_attribute_index).CHANGED               );
   hr_utility.trace(' BLD_BLK_INFO_TYPE    =  '|| l_attributes(l_attribute_index).BLD_BLK_INFO_TYPE     );
   hr_utility.trace(' PROCESS              =  '|| l_attributes(l_attribute_index).PROCESS               );
   hr_utility.trace(' BUILDING_BLOCK_OVN   =  '|| l_attributes(l_attribute_index).BUILDING_BLOCK_OVN    );
   hr_utility.trace('------------------------------------------------------');

   l_attribute_index := l_attributes.NEXT (l_attribute_index);

   END LOOP;

     hr_utility.trace(' SVG ATTRIBUTES TABLE END ');
 hr_utility.trace(' *****************');

       end if;
   END IF;

*/





           FOR x IN c_detail_info (l_timecard_id, l_timecard_ovn) LOOP
            l_attribute_index := l_attributes.FIRST;

            LOOP
             EXIT WHEN NOT l_attributes.EXISTS (l_attribute_index);
             if g_debug then
                     hr_utility.TRACE (l_attributes (l_attribute_index).attribute_category);
	     end if;

--

             IF      l_attributes ( ---1
                                   l_attribute_index).building_block_id = x.detail_id
                 AND l_attributes (l_attribute_index).attribute_category LIKE 'OTL_ALIAS_ITEM_%' THEN
              t_base_table (t_base_index).base_id := l_attributes (l_attribute_index).building_block_id;

              IF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_1' THEN
               t_base_table (t_base_index).attribute1 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_2' THEN
               t_base_table (t_base_index).attribute2 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_3' THEN
               t_base_table (t_base_index).attribute3 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_4' THEN
               t_base_table (t_base_index).attribute4 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_5' THEN
               t_base_table (t_base_index).attribute5 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_6' THEN
               t_base_table (t_base_index).attribute6 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_7' THEN
               t_base_table (t_base_index).attribute7 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_8' THEN
               t_base_table (t_base_index).attribute8 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_9' THEN
               t_base_table (t_base_index).attribute9 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_10' THEN
               t_base_table (t_base_index).attribute10 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_11' THEN
               t_base_table (t_base_index).attribute11 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_12' THEN
               t_base_table (t_base_index).attribute12 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_13' THEN
               t_base_table (t_base_index).attribute13 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_14' THEN
               t_base_table (t_base_index).attribute14 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_15' THEN
               t_base_table (t_base_index).attribute15 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_16' THEN
               t_base_table (t_base_index).attribute16 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_17' THEN
               t_base_table (t_base_index).attribute17 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_18' THEN
               t_base_table (t_base_index).attribute18 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_19' THEN
               t_base_table (t_base_index).attribute19 := l_attributes (l_attribute_index).attribute1;
              ELSIF l_attributes (l_attribute_index).attribute_category = 'OTL_ALIAS_ITEM_20' THEN
               t_base_table (t_base_index).attribute20 := l_attributes (l_attribute_index).attribute1;
              END IF;
             ELSIF      l_attributes (l_attribute_index).building_block_id = x.detail_id
                    AND l_attributes (l_attribute_index).attribute_category LIKE 'PAEXPITDFF%' THEN
              if g_debug then
              	      hr_utility.TRACE ('100');
                      hr_utility.TRACE ('inserting='|| x.comment_text || ' for x.detail_id= ' || x.detail_id);
	      end if;

--

              IF c%ISOPEN THEN
               CLOSE c;
              END IF;

              OPEN c (x.detail_id);
              FETCH c INTO c_row;

              IF c%FOUND THEN
               UPDATE hxc_tk_detail_temp
               SET    dff_catg = l_attributes (l_attribute_index).attribute_category,
                      dff_oldcatg = l_attributes (l_attribute_index).attribute_category,
                      dff_attr1 = l_attributes (l_attribute_index).attribute1,
                      dff_attr2 = l_attributes (l_attribute_index).attribute2,
                      dff_attr3 = l_attributes (l_attribute_index).attribute3,
                      dff_attr4 = l_attributes (l_attribute_index).attribute4,
                      dff_attr5 = l_attributes (l_attribute_index).attribute5,
                      dff_attr6 = l_attributes (l_attribute_index).attribute6,
                      dff_attr7 = l_attributes (l_attribute_index).attribute7,
                      dff_attr8 = l_attributes (l_attribute_index).attribute8,
                      dff_attr9 = l_attributes (l_attribute_index).attribute9,
                      dff_attr10 = l_attributes (l_attribute_index).attribute10,
                      dff_attr11 = l_attributes (l_attribute_index).attribute11,
                      dff_attr12 = l_attributes (l_attribute_index).attribute12,
                      dff_attr13 = l_attributes (l_attribute_index).attribute13,
                      dff_attr14 = l_attributes (l_attribute_index).attribute14,
                      dff_attr15 = l_attributes (l_attribute_index).attribute15,
                      dff_attr16 = l_attributes (l_attribute_index).attribute16,
                      dff_attr17 = l_attributes (l_attribute_index).attribute17,
                      dff_attr18 = l_attributes (l_attribute_index).attribute18,
                      dff_attr19 = l_attributes (l_attribute_index).attribute19,
                      dff_attr20 = l_attributes (l_attribute_index).attribute20,
                      dff_attr21 = l_attributes (l_attribute_index).attribute21,
                      dff_attr22 = l_attributes (l_attribute_index).attribute22,
                      dff_attr23 = l_attributes (l_attribute_index).attribute23,
                      dff_attr24 = l_attributes (l_attribute_index).attribute24,
                      dff_attr25 = l_attributes (l_attribute_index).attribute25,
                      dff_attr26 = l_attributes (l_attribute_index).attribute26,
                      dff_attr27 = l_attributes (l_attribute_index).attribute27,
                      dff_attr28 = l_attributes (l_attribute_index).attribute28,
                      dff_attr29 = l_attributes (l_attribute_index).attribute29,
                      dff_attr30 = l_attributes (l_attribute_index).attribute30,
                      dff_oldattr1 = l_attributes (l_attribute_index).attribute1,
                      dff_oldattr2 = l_attributes (l_attribute_index).attribute2,
                      dff_oldattr3 = l_attributes (l_attribute_index).attribute3,
                      dff_oldattr4 = l_attributes (l_attribute_index).attribute4,
                      dff_oldattr5 = l_attributes (l_attribute_index).attribute5,
                      dff_oldattr6 = l_attributes (l_attribute_index).attribute6,
                      dff_oldattr7 = l_attributes (l_attribute_index).attribute7,
                      dff_oldattr8 = l_attributes (l_attribute_index).attribute8,
                      dff_oldattr9 = l_attributes (l_attribute_index).attribute9,
                      dff_oldattr10 = l_attributes (l_attribute_index).attribute10,
                      dff_oldattr11 = l_attributes (l_attribute_index).attribute11,
                      dff_oldattr12 = l_attributes (l_attribute_index).attribute12,
                      dff_oldattr13 = l_attributes (l_attribute_index).attribute13,
                      dff_oldattr14 = l_attributes (l_attribute_index).attribute14,
                      dff_oldattr15 = l_attributes (l_attribute_index).attribute15,
                      dff_oldattr16 = l_attributes (l_attribute_index).attribute16,
                      dff_oldattr17 = l_attributes (l_attribute_index).attribute17,
                      dff_oldattr18 = l_attributes (l_attribute_index).attribute18,
                      dff_oldattr19 = l_attributes (l_attribute_index).attribute19,
                      dff_oldattr20 = l_attributes (l_attribute_index).attribute20,
                      dff_oldattr21 = l_attributes (l_attribute_index).attribute21,
                      dff_oldattr22 = l_attributes (l_attribute_index).attribute22,
                      dff_oldattr23 = l_attributes (l_attribute_index).attribute23,
                      dff_oldattr24 = l_attributes (l_attribute_index).attribute24,
                      dff_oldattr25 = l_attributes (l_attribute_index).attribute25,
                      dff_oldattr26 = l_attributes (l_attribute_index).attribute26,
                      dff_oldattr27 = l_attributes (l_attribute_index).attribute27,
                      dff_oldattr28 = l_attributes (l_attribute_index).attribute28,
                      dff_oldattr29 = l_attributes (l_attribute_index).attribute29,
                      dff_oldattr30 = l_attributes (l_attribute_index).attribute30
               WHERE  detailid = x.detail_id;
              ELSE
               INSERT INTO hxc_tk_detail_temp
                           (detailid, timecard_id, resource_id, comment_text, dff_catg, dff_oldcatg,
                            dff_attr1, dff_attr2, dff_attr3, dff_attr4, dff_attr5, dff_attr6, dff_attr7,
                            dff_attr8, dff_attr9, dff_attr10, dff_attr11, dff_attr12, dff_attr13,
                            dff_attr14, dff_attr15, dff_attr16, dff_attr17, dff_attr18, dff_attr19,
                            dff_attr20, dff_attr21, dff_attr22, dff_attr23, dff_attr24, dff_attr25,
                            dff_attr26, dff_attr27, dff_attr28, dff_attr29, dff_attr30, dff_oldattr1,
                            dff_oldattr2, dff_oldattr3, dff_oldattr4, dff_oldattr5, dff_oldattr6,
                            dff_oldattr7, dff_oldattr8, dff_oldattr9, dff_oldattr10, dff_oldattr11,
                            dff_oldattr12, dff_oldattr13, dff_oldattr14, dff_oldattr15, dff_oldattr16,
                            dff_oldattr17, dff_oldattr18, dff_oldattr19, dff_oldattr20, dff_oldattr21,
                            dff_oldattr22, dff_oldattr23, dff_oldattr24, dff_oldattr25, dff_oldattr26,
                            dff_oldattr27, dff_oldattr28, dff_oldattr29, dff_oldattr30)
               VALUES      (x.detail_id, l_timecard_id, p_resource_id, x.comment_text,
                            l_attributes (l_attribute_index).attribute_category,
                            l_attributes (l_attribute_index).attribute_category,
                            l_attributes (l_attribute_index).attribute1,
                            l_attributes (l_attribute_index).attribute2,
                            l_attributes (l_attribute_index).attribute3,
                            l_attributes (l_attribute_index).attribute4,
                            l_attributes (l_attribute_index).attribute5,
                            l_attributes (l_attribute_index).attribute6,
                            l_attributes (l_attribute_index).attribute7,
                            l_attributes (l_attribute_index).attribute8,
                            l_attributes (l_attribute_index).attribute9,
                            l_attributes (l_attribute_index).attribute10,
                            l_attributes (l_attribute_index).attribute11,
                            l_attributes (l_attribute_index).attribute12,
                            l_attributes (l_attribute_index).attribute13,
                            l_attributes (l_attribute_index).attribute14,
                            l_attributes (l_attribute_index).attribute15,
                            l_attributes (l_attribute_index).attribute16,
                            l_attributes (l_attribute_index).attribute17,
                            l_attributes (l_attribute_index).attribute18,
                            l_attributes (l_attribute_index).attribute19,
                            l_attributes (l_attribute_index).attribute20,
                            l_attributes (l_attribute_index).attribute21,
                            l_attributes (l_attribute_index).attribute22,
                            l_attributes (l_attribute_index).attribute23,
                            l_attributes (l_attribute_index).attribute24,
                            l_attributes (l_attribute_index).attribute25,
                            l_attributes (l_attribute_index).attribute26,
                            l_attributes (l_attribute_index).attribute27,
                            l_attributes (l_attribute_index).attribute28,
                            l_attributes (l_attribute_index).attribute29,
                            l_attributes (l_attribute_index).attribute30,
                            l_attributes (l_attribute_index).attribute1,
                            l_attributes (l_attribute_index).attribute2,
                            l_attributes (l_attribute_index).attribute3,
                            l_attributes (l_attribute_index).attribute4,
                            l_attributes (l_attribute_index).attribute5,
                            l_attributes (l_attribute_index).attribute6,
                            l_attributes (l_attribute_index).attribute7,
                            l_attributes (l_attribute_index).attribute8,
                            l_attributes (l_attribute_index).attribute9,
                            l_attributes (l_attribute_index).attribute10,
                            l_attributes (l_attribute_index).attribute11,
                            l_attributes (l_attribute_index).attribute12,
                            l_attributes (l_attribute_index).attribute13,
                            l_attributes (l_attribute_index).attribute14,
                            l_attributes (l_attribute_index).attribute15,
                            l_attributes (l_attribute_index).attribute16,
                            l_attributes (l_attribute_index).attribute17,
                            l_attributes (l_attribute_index).attribute18,
                            l_attributes (l_attribute_index).attribute19,
                            l_attributes (l_attribute_index).attribute20,
                            l_attributes (l_attribute_index).attribute21,
                            l_attributes (l_attribute_index).attribute22,
                            l_attributes (l_attribute_index).attribute23,
                            l_attributes (l_attribute_index).attribute24,
                            l_attributes (l_attribute_index).attribute25,
                            l_attributes (l_attribute_index).attribute26,
                            l_attributes (l_attribute_index).attribute27,
                            l_attributes (l_attribute_index).attribute28,
                            l_attributes (l_attribute_index).attribute29,
                            l_attributes (l_attribute_index).attribute30);
              END IF;

              CLOSE c;
             ELSIF      l_attributes (l_attribute_index).building_block_id = x.detail_id
                    AND l_attributes (l_attribute_index).attribute_category = 'REASON' THEN
              if g_debug then
		      hr_utility.TRACE ('REASON');
		      hr_utility.TRACE (
		       'inserting REASON='|| x.comment_text || ' for x.detail_id= ' || x.detail_id
		      );
		      hr_utility.TRACE ('LATE/CHANGE:'|| l_attributes (l_attribute_index).attribute3);
		      hr_utility.TRACE ('LATE/CHANGE COMMENT'|| l_attributes (l_attribute_index).attribute2);
		      hr_utility.TRACE ('CODE'|| l_attributes (l_attribute_index).attribute1);
	      end if;

--

              IF c%ISOPEN THEN
               CLOSE c;
              END IF;

              OPEN c (x.detail_id);
              FETCH c INTO c_row;

              IF c%FOUND THEN
               if g_debug then
                       hr_utility.TRACE ('detail found'|| x.detail_id);
	       end if;

--

               IF (l_attributes (l_attribute_index).attribute3 = 'LATE') THEN
/* JOEL => we are missing  old_audit_datetime in the table*/
                UPDATE hxc_tk_detail_temp
                SET    late_change = 'LATE',
                       old_late_change = 'LATE',
                       change_comment = NULL,
                       old_change_comment = NULL,
                       change_reason = NULL,
                       old_change_reason = NULL, --dhar
                       late_comment = l_attributes (l_attribute_index).attribute2,
                       old_late_comment = l_attributes (l_attribute_index).attribute2,
                       late_reason = l_attributes (l_attribute_index).attribute1,
                       old_late_reason = l_attributes (l_attribute_index).attribute1,
                       audit_datetime = l_attributes (l_attribute_index).attribute6,
                       old_audit_datetime = l_attributes (l_attribute_index).attribute6,
                       audit_history = l_attributes (l_attribute_index).attribute7,
                       old_audit_history = l_attributes (l_attribute_index).attribute7
                WHERE  detailid = x.detail_id;
               --JOEL let make sure it is a change
               ELSIF (l_attributes (l_attribute_index).attribute3 = 'CHANGE') THEN  -- change

/* IF (l_attributes ( l_attribute_index   ).attribute3)='CHANGE'
THEN*/
                UPDATE hxc_tk_detail_temp
                SET    late_change = 'CHANGE',
                       old_late_change = 'CHANGE',
                       late_comment = NULL,
                       old_late_comment = NULL,
                       late_reason = NULL,
                       old_late_reason = NULL, --dhar
                       change_comment = l_attributes (l_attribute_index).attribute2,
                       old_change_comment = l_attributes (l_attribute_index).attribute2,
                       change_reason = l_attributes (l_attribute_index).attribute1,
                       old_change_reason = l_attributes (l_attribute_index).attribute1,
                       audit_datetime = l_attributes (l_attribute_index).attribute6,
                       old_audit_datetime = l_attributes (l_attribute_index).attribute6,
                       audit_history = l_attributes (l_attribute_index).attribute7,
                       old_audit_history = l_attributes (l_attribute_index).attribute7
                WHERE  detailid = x.detail_id;

               ELSIF (l_attributes (l_attribute_index).attribute3 is null) THEN

                UPDATE hxc_tk_detail_temp
                SET    late_change = NULL,
                       old_late_change = NULL,
                       late_comment = NULL,
                       old_late_comment = NULL,
                       late_reason = NULL,
                       old_late_reason = NULL, --dhar
                       change_comment = l_attributes (l_attribute_index).attribute2,
                       old_change_comment = l_attributes (l_attribute_index).attribute2,
                       change_reason = l_attributes (l_attribute_index).attribute1,
                       old_change_reason = l_attributes (l_attribute_index).attribute1,
                       audit_datetime = l_attributes (l_attribute_index).attribute6,
                       old_audit_datetime = l_attributes (l_attribute_index).attribute6,
                       audit_history = l_attributes (l_attribute_index).attribute7,
                       old_audit_history = l_attributes (l_attribute_index).attribute7
                WHERE  detailid = x.detail_id;




               END IF; -- late or change

---after adding the negative detail id, it is not present in the db..so it requires to be inserted
--while all positive detail id can be update.
              ELSE -- no detailid --so insert
               IF (l_attributes (l_attribute_index).attribute3 = 'LATE') THEN
                if g_debug then
                        hr_utility.TRACE ('late reason');
	        end if;

--

                INSERT INTO hxc_tk_detail_temp
                            (detailid, timecard_id, resource_id, comment_text, late_change, old_late_change,
                             late_reason,
                             late_comment, old_late_reason, old_late_comment, audit_datetime,
                             old_audit_datetime,
                             audit_history, old_audit_history)
                VALUES      (x.detail_id, l_timecard_id, p_resource_id, x.comment_text,
                             'LATE',
                             'LATE',
                             l_attributes (l_attribute_index).attribute1,
                             l_attributes (l_attribute_index).attribute2,
                             l_attributes (l_attribute_index).attribute1,
                             l_attributes (l_attribute_index).attribute2,
                             l_attributes (l_attribute_index).attribute6,
                             l_attributes (l_attribute_index).attribute6,
                             l_attributes (l_attribute_index).attribute7,
                             l_attributes (l_attribute_index).attribute7);

               ELSIF (l_attributes (l_attribute_index).attribute3 = 'CHANGE') THEN

                INSERT INTO hxc_tk_detail_temp
                            (detailid, timecard_id, resource_id, comment_text, late_change,old_late_change,
                             change_reason,
                             change_comment, old_change_reason, old_change_comment, audit_datetime,
                             old_audit_datetime,
                             audit_history, old_audit_history)
                VALUES      (x.detail_id, l_timecard_id, p_resource_id, x.comment_text,
                             'CHANGE','CHANGE',
                             l_attributes (l_attribute_index).attribute1,
                             l_attributes (l_attribute_index).attribute2,
                             l_attributes (l_attribute_index).attribute1,
                             l_attributes (l_attribute_index).attribute2,
                             l_attributes (l_attribute_index).attribute6,
                             l_attributes (l_attribute_index).attribute6,
                             l_attributes (l_attribute_index).attribute7,
                             l_attributes (l_attribute_index).attribute7);

               ELSIF (l_attributes (l_attribute_index).attribute3 is null) THEN

                INSERT INTO hxc_tk_detail_temp
                            (detailid, timecard_id, resource_id, comment_text, late_change,old_late_change,
                             change_reason,
                             change_comment, old_change_reason, old_change_comment, audit_datetime,
                             old_audit_datetime,
                             audit_history, old_audit_history)
                VALUES      (x.detail_id, l_timecard_id, p_resource_id, x.comment_text,
                             NULL,NULL,
                             l_attributes (l_attribute_index).attribute1,
                             l_attributes (l_attribute_index).attribute2,
                             l_attributes (l_attribute_index).attribute1,
                             l_attributes (l_attribute_index).attribute2,
                             l_attributes (l_attribute_index).attribute6,
                             l_attributes (l_attribute_index).attribute6,
                             l_attributes (l_attribute_index).attribute7,
                             l_attributes (l_attribute_index).attribute7);


               END IF; --reason is late
              END IF; --if detail is found

              CLOSE c;
             END IF; --if the attribute category

             l_attribute_index := l_attributes.NEXT (l_attribute_index);
            END LOOP;
/*ADVICE(1462): Nested LOOPs should all be labeled [406] */


            t_base_index := t_base_index + 1;
           END LOOP;
/*ADVICE(1467): Nested LOOPs should all be labeled [406] */


           -- Populate the final table based on the attribute information

           t_base_index := t_base_table.FIRST;

           LOOP
            EXIT WHEN (NOT t_base_table.EXISTS (t_base_index));

            IF (    NVL (t_base_table (t_base_index).attribute1, 1) =
                                     NVL (NVL (p_attribute1, t_base_table (t_base_index).attribute1), 1)
                AND NVL (t_base_table (t_base_index).attribute2, 1) =
                                     NVL (NVL (p_attribute2, t_base_table (t_base_index).attribute2), 1)
                AND NVL (t_base_table (t_base_index).attribute3, 1) =
                                     NVL (NVL (p_attribute3, t_base_table (t_base_index).attribute3), 1)
                AND NVL (t_base_table (t_base_index).attribute4, 1) =
                                     NVL (NVL (p_attribute4, t_base_table (t_base_index).attribute4), 1)
                AND NVL (t_base_table (t_base_index).attribute5, 1) =
                                     NVL (NVL (p_attribute5, t_base_table (t_base_index).attribute5), 1)
                AND NVL (t_base_table (t_base_index).attribute6, 1) =
                                     NVL (NVL (p_attribute6, t_base_table (t_base_index).attribute6), 1)
                AND NVL (t_base_table (t_base_index).attribute7, 1) =
                                     NVL (NVL (p_attribute7, t_base_table (t_base_index).attribute7), 1)
                AND NVL (t_base_table (t_base_index).attribute8, 1) =
                                     NVL (NVL (p_attribute8, t_base_table (t_base_index).attribute8), 1)
                AND NVL (t_base_table (t_base_index).attribute9, 1) =
                                     NVL (NVL (p_attribute9, t_base_table (t_base_index).attribute9), 1)
                AND NVL (t_base_table (t_base_index).attribute10, 1) =
                                   NVL (NVL (p_attribute10, t_base_table (t_base_index).attribute10), 1)
                AND NVL (t_base_table (t_base_index).attribute11, 1) =
                                   NVL (NVL (p_attribute11, t_base_table (t_base_index).attribute11), 1)
                AND NVL (t_base_table (t_base_index).attribute12, 1) =
                                   NVL (NVL (p_attribute12, t_base_table (t_base_index).attribute12), 1)
                AND NVL (t_base_table (t_base_index).attribute13, 1) =
                                   NVL (NVL (p_attribute13, t_base_table (t_base_index).attribute13), 1)
                AND NVL (t_base_table (t_base_index).attribute14, 1) =
                                   NVL (NVL (p_attribute14, t_base_table (t_base_index).attribute14), 1)
                AND NVL (t_base_table (t_base_index).attribute15, 1) =
                                   NVL (NVL (p_attribute15, t_base_table (t_base_index).attribute15), 1)
                AND NVL (t_base_table (t_base_index).attribute16, 1) =
                                   NVL (NVL (p_attribute16, t_base_table (t_base_index).attribute16), 1)
                AND NVL (t_base_table (t_base_index).attribute17, 1) =
                                   NVL (NVL (p_attribute17, t_base_table (t_base_index).attribute17), 1)
                AND NVL (t_base_table (t_base_index).attribute18, 1) =
                                   NVL (NVL (p_attribute18, t_base_table (t_base_index).attribute18), 1)
                AND NVL (t_base_table (t_base_index).attribute19, 1) =
                                   NVL (NVL (p_attribute19, t_base_table (t_base_index).attribute19), 1)
                AND NVL (t_base_table (t_base_index).attribute20, 1) =
                                   NVL (NVL (p_attribute20, t_base_table (t_base_index).attribute20), 1)
               ) THEN
             -- first time in the loop
             -- put the first value
             IF l_buffer_info.COUNT = 0 THEN
              l_table_counter := l_table_counter + 1;
              l_index_buffer := l_index_buffer + 1;
              l_buffer_info (l_index_buffer).row_table_index := l_table_counter;
              l_buffer_info (l_index_buffer).attribute1 := t_base_table (t_base_index).attribute1;
              l_buffer_info (l_index_buffer).attribute2 := t_base_table (t_base_index).attribute2;
              l_buffer_info (l_index_buffer).attribute3 := t_base_table (t_base_index).attribute3;
              l_buffer_info (l_index_buffer).attribute4 := t_base_table (t_base_index).attribute4;
              l_buffer_info (l_index_buffer).attribute5 := t_base_table (t_base_index).attribute5;
              l_buffer_info (l_index_buffer).attribute6 := t_base_table (t_base_index).attribute6;
              l_buffer_info (l_index_buffer).attribute7 := t_base_table (t_base_index).attribute7;
              l_buffer_info (l_index_buffer).attribute8 := t_base_table (t_base_index).attribute8;
              l_buffer_info (l_index_buffer).attribute9 := t_base_table (t_base_index).attribute9;
              l_buffer_info (l_index_buffer).attribute10 := t_base_table (t_base_index).attribute10;
              l_buffer_info (l_index_buffer).attribute11 := t_base_table (t_base_index).attribute11;
              l_buffer_info (l_index_buffer).attribute12 := t_base_table (t_base_index).attribute12;
              l_buffer_info (l_index_buffer).attribute13 := t_base_table (t_base_index).attribute13;
              l_buffer_info (l_index_buffer).attribute14 := t_base_table (t_base_index).attribute14;
              l_buffer_info (l_index_buffer).attribute15 := t_base_table (t_base_index).attribute15;
              l_buffer_info (l_index_buffer).attribute16 := t_base_table (t_base_index).attribute16;
              l_buffer_info (l_index_buffer).attribute17 := t_base_table (t_base_index).attribute17;
              l_buffer_info (l_index_buffer).attribute18 := t_base_table (t_base_index).attribute18;
              l_buffer_info (l_index_buffer).attribute19 := t_base_table (t_base_index).attribute19;
              l_buffer_info (l_index_buffer).attribute20 := t_base_table (t_base_index).attribute20;
             END IF;

             -- find detail information
             l_detail_id := l_detail_info_table (t_base_table (t_base_index).base_id).detail_id;
             l_detail_ovn := l_detail_info_table (t_base_table (t_base_index).base_id).detail_ovn;
             l_detail_measure := l_detail_info_table (t_base_table (t_base_index).base_id).measure;
             l_detail_start_time := l_detail_info_table (t_base_table (t_base_index).base_id).start_time;
             l_detail_time_in := l_detail_info_table (t_base_table (t_base_index).base_id).time_in;
             l_detail_time_out := l_detail_info_table (t_base_table (t_base_index).base_id).time_out;
             l_detail_comment_text :=
                            l_detail_info_table (t_base_table (t_base_index).base_id).detail_comment_text;
             -- remove the detail now in the table.


             l_detail_info_table.DELETE (t_base_table (t_base_index).base_id);
             l_found_detail := TRUE;
             l_index_buffer := l_buffer_info.FIRST;

             -- search if the hours type exists already
             -- in the table
             -- we are going through the table to make sure
             -- we will be on the last index of this hours type

             LOOP
              EXIT WHEN (NOT l_buffer_info.EXISTS (l_index_buffer));

              IF      NVL (l_buffer_info (l_index_buffer).attribute1, 1) =
                                                         NVL (t_base_table (t_base_index).attribute1, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute2, 1) =
                                                         NVL (t_base_table (t_base_index).attribute2, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute3, 1) =
                                                         NVL (t_base_table (t_base_index).attribute3, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute4, 1) =
                                                         NVL (t_base_table (t_base_index).attribute4, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute5, 1) =
                                                         NVL (t_base_table (t_base_index).attribute5, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute6, 1) =
                                                         NVL (t_base_table (t_base_index).attribute6, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute7, 1) =
                                                         NVL (t_base_table (t_base_index).attribute7, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute8, 1) =
                                                         NVL (t_base_table (t_base_index).attribute8, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute9, 1) =
                                                         NVL (t_base_table (t_base_index).attribute9, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute10, 1) =
                                                        NVL (t_base_table (t_base_index).attribute10, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute11, 1) =
                                                        NVL (t_base_table (t_base_index).attribute11, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute12, 1) =
                                                        NVL (t_base_table (t_base_index).attribute12, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute13, 1) =
                                                        NVL (t_base_table (t_base_index).attribute13, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute14, 1) =
                                                        NVL (t_base_table (t_base_index).attribute14, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute15, 1) =
                                                        NVL (t_base_table (t_base_index).attribute15, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute16, 1) =
                                                        NVL (t_base_table (t_base_index).attribute16, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute17, 1) =
                                                        NVL (t_base_table (t_base_index).attribute17, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute18, 1) =
                                                        NVL (t_base_table (t_base_index).attribute18, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute19, 1) =
                                                        NVL (t_base_table (t_base_index).attribute19, 1)
                  AND NVL (l_buffer_info (l_index_buffer).attribute20, 1) =
                                                        NVL (t_base_table (t_base_index).attribute20, 1) THEN
               -- the hours type has been found
               -- record the index

               l_record_index_buffer := l_index_buffer;
               l_found_hours_type := TRUE;

               -- l_table_counter  := l_buffer_info(l_index_buffer).row_table_index; ---nitin

               IF (l_timecard_start_time = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_1) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_1 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 1) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_2) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_2 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 2) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_3) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_3 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 3) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_4) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_4 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 4) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_5) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_5 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 5) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_6) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_6 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 6) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_7) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_7 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 7) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_8) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_8 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 8) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_9) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_9 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 9) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_10) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_10 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 10) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_11) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_11 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 11) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_12) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_12 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 12) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_13) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_13 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 13) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_14) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_14 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 14) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_15) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_15 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 15) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_16) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_16 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 16) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_17) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_17 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 17) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_18) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_18 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 18) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_19) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_19 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 19) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_20) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_20 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 20) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_21) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_21 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 21) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_22) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_22 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 22) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_23) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_23 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 23) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_24) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_24 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 24) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_25) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_25 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 25) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_26) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_26 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 26) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_27) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_27 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 27) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_28) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_28 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 28) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_29) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_29 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 29) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_30) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_30 := TRUE;
                END IF;
               ELSIF ((l_timecard_start_time + 30) = l_detail_start_time) THEN
                IF (l_buffer_info (l_record_index_buffer).day_31) THEN
                 l_found_hours_type := FALSE;
                ELSE
                 l_buffer_info (l_record_index_buffer).day_31 := TRUE;
                END IF;
               END IF;

               IF (l_found_hours_type) THEN
                changed := 'Y'; --nitin
                changed_no := l_table_counter; --nitin
                l_table_counter := l_buffer_info (l_index_buffer).row_table_index; ---nitin
               END IF;

               -- reset
               l_record_index_buffer := NULL;
              END IF;

              IF (l_found_hours_type) THEN
               l_index_buffer := l_buffer_info.LAST + 1;
              ELSE
               l_index_buffer := l_buffer_info.NEXT (l_index_buffer);
              END IF;
             END LOOP;
/*ADVICE(1822): Nested LOOPs should all be labeled [406] */


             -- now we need to check at this index that the detail info is not populate
             -- if it is so the we need to increment the table index.
             -- the hours type has not been found
             -- create a new row in the buffer and increment the table_counter

             IF (    l_found_hours_type = FALSE
                 AND NVL (t_base_table (t_base_index).attribute1, 1) =
                                      NVL (NVL (p_attribute1, t_base_table (t_base_index).attribute1), 1)
                 AND NVL (t_base_table (t_base_index).attribute2, 1) =
                                      NVL (NVL (p_attribute2, t_base_table (t_base_index).attribute2), 1)
                 AND NVL (t_base_table (t_base_index).attribute3, 1) =
                                      NVL (NVL (p_attribute3, t_base_table (t_base_index).attribute3), 1)
                 AND NVL (t_base_table (t_base_index).attribute4, 1) =
                                      NVL (NVL (p_attribute4, t_base_table (t_base_index).attribute4), 1)
                 AND NVL (t_base_table (t_base_index).attribute5, 1) =
                                      NVL (NVL (p_attribute5, t_base_table (t_base_index).attribute5), 1)
                 AND NVL (t_base_table (t_base_index).attribute6, 1) =
                                      NVL (NVL (p_attribute6, t_base_table (t_base_index).attribute6), 1)
                 AND NVL (t_base_table (t_base_index).attribute7, 1) =
                                      NVL (NVL (p_attribute7, t_base_table (t_base_index).attribute7), 1)
                 AND NVL (t_base_table (t_base_index).attribute8, 1) =
                                      NVL (NVL (p_attribute8, t_base_table (t_base_index).attribute8), 1)
                 AND NVL (t_base_table (t_base_index).attribute9, 1) =
                                      NVL (NVL (p_attribute9, t_base_table (t_base_index).attribute9), 1)
                 AND NVL (t_base_table (t_base_index).attribute10, 1) =
                                    NVL (NVL (p_attribute10, t_base_table (t_base_index).attribute10), 1)
                 AND NVL (t_base_table (t_base_index).attribute11, 1) =
                                    NVL (NVL (p_attribute11, t_base_table (t_base_index).attribute11), 1)
                 AND NVL (t_base_table (t_base_index).attribute12, 1) =
                                    NVL (NVL (p_attribute12, t_base_table (t_base_index).attribute12), 1)
                 AND NVL (t_base_table (t_base_index).attribute13, 1) =
                                    NVL (NVL (p_attribute13, t_base_table (t_base_index).attribute13), 1)
                 AND NVL (t_base_table (t_base_index).attribute14, 1) =
                                    NVL (NVL (p_attribute14, t_base_table (t_base_index).attribute14), 1)
                 AND NVL (t_base_table (t_base_index).attribute15, 1) =
                                    NVL (NVL (p_attribute15, t_base_table (t_base_index).attribute15), 1)
                 AND NVL (t_base_table (t_base_index).attribute16, 1) =
                                    NVL (NVL (p_attribute16, t_base_table (t_base_index).attribute16), 1)
                 AND NVL (t_base_table (t_base_index).attribute17, 1) =
                                    NVL (NVL (p_attribute17, t_base_table (t_base_index).attribute17), 1)
                 AND NVL (t_base_table (t_base_index).attribute18, 1) =
                                    NVL (NVL (p_attribute18, t_base_table (t_base_index).attribute18), 1)
                 AND NVL (t_base_table (t_base_index).attribute19, 1) =
                                    NVL (NVL (p_attribute19, t_base_table (t_base_index).attribute19), 1)
                 AND NVL (t_base_table (t_base_index).attribute20, 1) =
                                    NVL (NVL (p_attribute20, t_base_table (t_base_index).attribute20), 1)
                ) THEN
              -- increment of the index


              -- if l_table_counter < l_buffer_info(l_buffer_info.last).row_table_index then  --nitin
              --    l_table_counter :=l_buffer_info(l_buffer_info.last).row_table_index;     --nitin
              -- end if;                                                                      --nitin

              l_table_counter := l_table_counter + 1;
              l_index_buffer := l_buffer_info.LAST + 1;
              l_buffer_info (l_index_buffer).row_table_index := l_table_counter;
              l_buffer_info (l_index_buffer).attribute1 := t_base_table (t_base_index).attribute1;
              l_buffer_info (l_index_buffer).attribute2 := t_base_table (t_base_index).attribute2;
              l_buffer_info (l_index_buffer).attribute3 := t_base_table (t_base_index).attribute3;
              l_buffer_info (l_index_buffer).attribute4 := t_base_table (t_base_index).attribute4;
              l_buffer_info (l_index_buffer).attribute5 := t_base_table (t_base_index).attribute5;
              l_buffer_info (l_index_buffer).attribute6 := t_base_table (t_base_index).attribute6;
              l_buffer_info (l_index_buffer).attribute7 := t_base_table (t_base_index).attribute7;
              l_buffer_info (l_index_buffer).attribute8 := t_base_table (t_base_index).attribute8;
              l_buffer_info (l_index_buffer).attribute9 := t_base_table (t_base_index).attribute9;
              l_buffer_info (l_index_buffer).attribute10 := t_base_table (t_base_index).attribute10;
              l_buffer_info (l_index_buffer).attribute11 := t_base_table (t_base_index).attribute11;
              l_buffer_info (l_index_buffer).attribute12 := t_base_table (t_base_index).attribute12;
              l_buffer_info (l_index_buffer).attribute13 := t_base_table (t_base_index).attribute13;
              l_buffer_info (l_index_buffer).attribute14 := t_base_table (t_base_index).attribute14;
              l_buffer_info (l_index_buffer).attribute15 := t_base_table (t_base_index).attribute15;
              l_buffer_info (l_index_buffer).attribute16 := t_base_table (t_base_index).attribute16;
              l_buffer_info (l_index_buffer).attribute17 := t_base_table (t_base_index).attribute17;
              l_buffer_info (l_index_buffer).attribute18 := t_base_table (t_base_index).attribute18;
              l_buffer_info (l_index_buffer).attribute19 := t_base_table (t_base_index).attribute19;
              l_buffer_info (l_index_buffer).attribute20 := t_base_table (t_base_index).attribute20;

              -- store the day that has been populated
              IF (l_timecard_start_time = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_1 := TRUE;
              ELSIF ((l_timecard_start_time + 1) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_2 := TRUE;
              ELSIF ((l_timecard_start_time + 2) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_3 := TRUE;
              ELSIF ((l_timecard_start_time + 3) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_4 := TRUE;
              ELSIF ((l_timecard_start_time + 4) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_5 := TRUE;
              ELSIF ((l_timecard_start_time + 5) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_6 := TRUE;
              ELSIF ((l_timecard_start_time + 6) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_7 := TRUE;
              ELSIF ((l_timecard_start_time + 7) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_8 := TRUE;
              ELSIF ((l_timecard_start_time + 8) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_9 := TRUE;
              ELSIF ((l_timecard_start_time + 9) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_10 := TRUE;
              ELSIF ((l_timecard_start_time + 10) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_11 := TRUE;
              ELSIF ((l_timecard_start_time + 11) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_12 := TRUE;
              ELSIF ((l_timecard_start_time + 12) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_13 := TRUE;
              ELSIF ((l_timecard_start_time + 13) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_14 := TRUE;
              ELSIF ((l_timecard_start_time + 14) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_15 := TRUE;
              ELSIF ((l_timecard_start_time + 15) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_16 := TRUE;
              ELSIF ((l_timecard_start_time + 16) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_17 := TRUE;
              ELSIF ((l_timecard_start_time + 17) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_18 := TRUE;
              ELSIF ((l_timecard_start_time + 18) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_19 := TRUE;
              ELSIF ((l_timecard_start_time + 19) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_20 := TRUE;
              ELSIF ((l_timecard_start_time + 20) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_21 := TRUE;
              ELSIF ((l_timecard_start_time + 21) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_22 := TRUE;
              ELSIF ((l_timecard_start_time + 22) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_23 := TRUE;
              ELSIF ((l_timecard_start_time + 23) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_24 := TRUE;
              ELSIF ((l_timecard_start_time + 24) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_25 := TRUE;
              ELSIF ((l_timecard_start_time + 25) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_26 := TRUE;
              ELSIF ((l_timecard_start_time + 26) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_27 := TRUE;
              ELSIF ((l_timecard_start_time + 27) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_28 := TRUE;
              ELSIF ((l_timecard_start_time + 28) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_29 := TRUE;
              ELSIF ((l_timecard_start_time + 29) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_30 := TRUE;
              ELSIF ((l_timecard_start_time + 30) = l_detail_start_time) THEN
               l_buffer_info (l_index_buffer).day_31 := TRUE;
              END IF;
             END IF;

             l_found_hours_type := FALSE;

             --IF g_debbug THEN
             --hxc_timekeeper_utilities.dump_buffer_table(l_buffer_info);
             --END IF;
	     if g_debug then
                     hr_utility.trace ('101 -- Normal Query procedure ');
	     end if;
             IF p_reqryflg = 'N' THEN
              p_timekeeper_data (l_table_counter).check_box := 'Y';
              g_submit_table (resource_info.person_id).resource_id := resource_info.person_id;
              g_submit_table (resource_info.person_id).timecard_id := l_timecard_id;
              g_submit_table (resource_info.person_id).start_time := tc_start;
              g_submit_table (resource_info.person_id).stop_time := tc_end;
              g_submit_table (resource_info.person_id).row_lock_id := l_row_lock_id;
              g_submit_table (resource_info.person_id).no_rows :=
                                            NVL (g_submit_table (resource_info.person_id).no_rows, 0) + 1;
             ELSE
              p_timekeeper_data (l_table_counter).check_box := 'N';
              g_submit_table.DELETE (resource_info.person_id);
             END IF;

             p_timekeeper_data (l_table_counter).timecard_id := l_timecard_id;
             p_timekeeper_data (l_table_counter).timecard_start_period := tc_start;
             p_timekeeper_data (l_table_counter).timecard_end_period := tc_end;
             p_timekeeper_data (l_table_counter).last_update_date := l_last_update_date;
             p_timekeeper_data (l_table_counter).last_updated_by := l_last_updated_by;
             p_timekeeper_data (l_table_counter).last_update_login := l_last_update_login;
             p_timekeeper_data (l_table_counter).created_by := l_created_by;
             p_timekeeper_data (l_table_counter).creation_date := l_creation_date;
             p_timekeeper_data (l_table_counter).timecard_ovn := l_timecard_ovn;
             p_timekeeper_data (l_table_counter).timecard_status_code := l_status_code;
             p_timekeeper_data (l_table_counter).timecard_status := l_timecard_status_meaning;
             p_timekeeper_data (l_table_counter).timecard_message_code := l_timecard_message_code;
             p_timekeeper_data (l_table_counter).timecard_message := l_timecard_message;
             p_timekeeper_data (l_table_counter).comment_text := l_timecard_comment_text;
             p_timekeeper_data (l_table_counter).attr_id_1 := t_base_table (t_base_index).attribute1;
             p_timekeeper_data (l_table_counter).attr_id_2 := t_base_table (t_base_index).attribute2;
             p_timekeeper_data (l_table_counter).attr_id_3 := t_base_table (t_base_index).attribute3;
             p_timekeeper_data (l_table_counter).attr_id_4 := t_base_table (t_base_index).attribute4;
             p_timekeeper_data (l_table_counter).attr_id_5 := t_base_table (t_base_index).attribute5;
             p_timekeeper_data (l_table_counter).attr_id_6 := t_base_table (t_base_index).attribute6;
             p_timekeeper_data (l_table_counter).attr_id_7 := t_base_table (t_base_index).attribute7;
             p_timekeeper_data (l_table_counter).attr_id_8 := t_base_table (t_base_index).attribute8;
             p_timekeeper_data (l_table_counter).attr_id_9 := t_base_table (t_base_index).attribute9;
             p_timekeeper_data (l_table_counter).attr_id_10 := t_base_table (t_base_index).attribute10;
             p_timekeeper_data (l_table_counter).attr_id_11 := t_base_table (t_base_index).attribute11;
             p_timekeeper_data (l_table_counter).attr_id_12 := t_base_table (t_base_index).attribute12;
             p_timekeeper_data (l_table_counter).attr_id_13 := t_base_table (t_base_index).attribute13;
             p_timekeeper_data (l_table_counter).attr_id_14 := t_base_table (t_base_index).attribute14;
             p_timekeeper_data (l_table_counter).attr_id_15 := t_base_table (t_base_index).attribute15;
             p_timekeeper_data (l_table_counter).attr_id_14 := t_base_table (t_base_index).attribute14;
             p_timekeeper_data (l_table_counter).attr_id_15 := t_base_table (t_base_index).attribute15;
             p_timekeeper_data (l_table_counter).attr_id_16 := t_base_table (t_base_index).attribute16;
             p_timekeeper_data (l_table_counter).attr_id_17 := t_base_table (t_base_index).attribute17;
             p_timekeeper_data (l_table_counter).attr_id_18 := t_base_table (t_base_index).attribute18;
             p_timekeeper_data (l_table_counter).attr_id_19 := t_base_table (t_base_index).attribute19;
             p_timekeeper_data (l_table_counter).attr_id_20 := t_base_table (t_base_index).attribute20;
             p_timekeeper_data (l_table_counter).attr_oldid_1 := t_base_table (t_base_index).attribute1;
             p_timekeeper_data (l_table_counter).attr_oldid_2 := t_base_table (t_base_index).attribute2;
             p_timekeeper_data (l_table_counter).attr_oldid_3 := t_base_table (t_base_index).attribute3;
             p_timekeeper_data (l_table_counter).attr_oldid_4 := t_base_table (t_base_index).attribute4;
             p_timekeeper_data (l_table_counter).attr_oldid_5 := t_base_table (t_base_index).attribute5;
             p_timekeeper_data (l_table_counter).attr_oldid_6 := t_base_table (t_base_index).attribute6;
             p_timekeeper_data (l_table_counter).attr_oldid_7 := t_base_table (t_base_index).attribute7;
             p_timekeeper_data (l_table_counter).attr_oldid_8 := t_base_table (t_base_index).attribute8;
             p_timekeeper_data (l_table_counter).attr_oldid_9 := t_base_table (t_base_index).attribute9;
             p_timekeeper_data (l_table_counter).attr_oldid_10 := t_base_table (t_base_index).attribute10;
             p_timekeeper_data (l_table_counter).attr_oldid_11 := t_base_table (t_base_index).attribute11;
             p_timekeeper_data (l_table_counter).attr_oldid_12 := t_base_table (t_base_index).attribute12;
             p_timekeeper_data (l_table_counter).attr_oldid_13 := t_base_table (t_base_index).attribute13;
             p_timekeeper_data (l_table_counter).attr_oldid_14 := t_base_table (t_base_index).attribute14;
             p_timekeeper_data (l_table_counter).attr_oldid_15 := t_base_table (t_base_index).attribute15;
             p_timekeeper_data (l_table_counter).attr_oldid_14 := t_base_table (t_base_index).attribute14;
             p_timekeeper_data (l_table_counter).attr_oldid_15 := t_base_table (t_base_index).attribute15;
             p_timekeeper_data (l_table_counter).attr_oldid_16 := t_base_table (t_base_index).attribute16;
             p_timekeeper_data (l_table_counter).attr_oldid_17 := t_base_table (t_base_index).attribute17;
             p_timekeeper_data (l_table_counter).attr_oldid_18 := t_base_table (t_base_index).attribute18;
             p_timekeeper_data (l_table_counter).attr_oldid_19 := t_base_table (t_base_index).attribute19;
             p_timekeeper_data (l_table_counter).attr_oldid_20 := t_base_table (t_base_index).attribute20;
             p_timekeeper_data (l_table_counter).resource_id := resource_info.person_id;
             p_timekeeper_data (l_table_counter).employee_number := resource_info.employee_number;
             p_timekeeper_data (l_table_counter).person_type := resource_info.person_type;
             p_timekeeper_data (l_table_counter).audit_enabled := l_audit_enabled;
             p_timekeeper_data (l_table_counter).employee_full_name := resource_info.full_name;
             p_timekeeper_data (l_table_counter).row_lock_id := l_row_lock_id;
             p_timekeeper_data (l_table_counter).tc_lock_success := l_tc_lock_success;
             if g_debug then
		     hr_utility.TRACE ('l_detail_id'|| l_detail_id);
		     hr_utility.TRACE ('l_timecard_id'|| l_timecard_id);
		     hr_utility.TRACE ('l_detail_comment_text'|| l_detail_comment_text);
 	     end if;
             IF l_detail_comment_text IS NOT NULL THEN
              if g_debug then
		      hr_utility.TRACE ('200');
		      hr_utility.TRACE ('l_detail_idA'|| l_detail_id);
		      hr_utility.TRACE ('l_timecard_idA'|| l_timecard_id);
		      hr_utility.TRACE ('l_detail_comment_textA'|| l_detail_comment_text);
	      end if;
              IF c%ISOPEN THEN
               CLOSE c;
              END IF;

              OPEN c (l_detail_id);
              FETCH c INTO c_row;

              IF c%FOUND THEN
               UPDATE hxc_tk_detail_temp
               SET    comment_text = l_detail_comment_text
               WHERE  detailid = l_detail_id AND timecard_id = l_timecard_id;
              ELSE
               INSERT INTO hxc_tk_detail_temp
                           (detailid, timecard_id, comment_text)
               VALUES      (l_detail_id, l_timecard_id, l_detail_comment_text);
              END IF;

              CLOSE c;
             END IF;

             -- attach the detail information with the right day
             IF (l_timecard_start_time - (l_add_index_day) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_1 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_1 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_1 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_1 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_1 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 1) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_2 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_2 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_2 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_2 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_2 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 2) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_3 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_3 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_3 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_3 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_3 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 3) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_4 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_4 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_4 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_4 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_4 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 4) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_5 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_5 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_5 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_5 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_5 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 5) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_6 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_6 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_6 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_6 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_6 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 6) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_7 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_7 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_7 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_7 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_7 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 7) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_8 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_8 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_8 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_8 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_8 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 8) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_9 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_9 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_9 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_9 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_9 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 9) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_10 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_10 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_10 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_10 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_10 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 10) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_11 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_11 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_11 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_11 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_11 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 11) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_12 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_12 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_12 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_12 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_12 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 12) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_13 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_13 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_13 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_13 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_13 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 13) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_14 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_14 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_14 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_14 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_14 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 14) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_15 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_15 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_15 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_15 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_15 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 15) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_16 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_16 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_16 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_16 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_16 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 16) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_17 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_17 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_17 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_17 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_17 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 17) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_18 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_18 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_18 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_18 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_18 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 18) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_19 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_19 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_19 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_19 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_19 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 19) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_20 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_20 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_20 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_20 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_20 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 20) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_21 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_21 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_21 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_21 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_21 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 21) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_22 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_22 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_22 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_22 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_22 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 22) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_23 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_23 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_23 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_23 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_23 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 23) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_24 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_24 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_24 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_24 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_24 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 24) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_25 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_25 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_25 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_25 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_25 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 25) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_26 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_26 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_26 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_26 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_26 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 26) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_27 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_27 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_27 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_27 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_27 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 27) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_28 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_28 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_28 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_28 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_28 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 28) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_29 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_29 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_29 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_29 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_29 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 29) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_30 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_30 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_30 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_30 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_30 := l_detail_time_out;
             ELSIF ((l_timecard_start_time - l_add_index_day + 30) = l_detail_start_time) THEN
              p_timekeeper_data (l_table_counter).day_31 := l_detail_measure;
              p_timekeeper_data (l_table_counter).detail_id_31 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_31 := l_detail_ovn;
              p_timekeeper_data (l_table_counter).time_in_31 := l_detail_time_in;
              p_timekeeper_data (l_table_counter).time_out_31 := l_detail_time_out;
             END IF;
            END IF;

            IF changed = 'Y' THEN
             l_table_counter := changed_no;
            END IF;

            changed := 'N';
            t_base_index := t_base_table.NEXT (t_base_index);
           END LOOP;
/*ADVICE(2285): Nested LOOPs should all be labeled [406] */

          END IF; -- end if attribute

          -- now loop how many detail we still have to process

          -- we need to handle the detail with no attribute attached here.....

          l_detail_index := l_detail_info_table.FIRST;

          -- the timecard is there but contains not detail

          IF (    l_detail_info_table.COUNT = 0
              AND l_found_detail = FALSE
              AND p_status_code IS NULL
              AND p_message_type IS NULL
              AND p_message_text IS NULL
              AND p_change_reason IS NULL
              AND p_late_reason IS NULL
              AND p_audit_history IS NULL
              AND (    p_attribute1 IS NULL
                   AND p_attribute2 IS NULL
                   AND p_attribute3 IS NULL
                   AND p_attribute4 IS NULL
                   AND p_attribute5 IS NULL
                   AND p_attribute6 IS NULL
                   AND p_attribute7 IS NULL
                   AND p_attribute8 IS NULL
                   AND p_attribute9 IS NULL
                   AND p_attribute10 IS NULL
                   AND p_attribute11 IS NULL
                   AND p_attribute12 IS NULL
                   AND p_attribute13 IS NULL
                   AND p_attribute14 IS NULL
                   AND p_attribute15 IS NULL
                   AND p_attribute16 IS NULL
                   AND p_attribute17 IS NULL
                   AND p_attribute18 IS NULL
                   AND p_attribute19 IS NULL
                   AND p_attribute20 IS NULL
                  )
             ) THEN
           l_table_counter := l_table_counter + 1;

           IF p_reqryflg = 'N' THEN
            p_timekeeper_data (l_table_counter).check_box := 'Y';
            g_submit_table (resource_info.person_id).resource_id := resource_info.person_id;
            g_submit_table (resource_info.person_id).timecard_id := l_timecard_id;
            g_submit_table (resource_info.person_id).start_time := tc_start;
            g_submit_table (resource_info.person_id).stop_time := tc_end;
            g_submit_table (resource_info.person_id).row_lock_id := l_row_lock_id;
            g_submit_table (resource_info.person_id).no_rows :=
                                            NVL (g_submit_table (resource_info.person_id).no_rows, 0) + 1;
           ELSE
            p_timekeeper_data (l_table_counter).check_box := 'N';
            g_submit_table.DELETE (resource_info.person_id);
           END IF;

           p_timekeeper_data (l_table_counter).timecard_status_code := l_status_code;
           p_timekeeper_data (l_table_counter).timecard_status := l_timecard_status_meaning;
           p_timekeeper_data (l_table_counter).timecard_message_code := l_timecard_message_code;
           p_timekeeper_data (l_table_counter).timecard_message := l_timecard_message;
           p_timekeeper_data (l_table_counter).timecard_start_period := tc_start;
           p_timekeeper_data (l_table_counter).timecard_end_period := tc_end;
           p_timekeeper_data (l_table_counter).comment_text := l_timecard_comment_text;
           p_timekeeper_data (l_table_counter).timecard_id := l_timecard_id;
           p_timekeeper_data (l_table_counter).timecard_ovn := l_timecard_ovn;
           p_timekeeper_data (l_table_counter).resource_id := resource_info.person_id;
           p_timekeeper_data (l_table_counter).employee_number := resource_info.employee_number;
           p_timekeeper_data (l_table_counter).person_type := resource_info.person_type;
           p_timekeeper_data (l_table_counter).audit_enabled := l_audit_enabled;
           p_timekeeper_data (l_table_counter).employee_full_name := resource_info.full_name;
           p_timekeeper_data (l_table_counter).last_update_date := l_last_update_date;
           p_timekeeper_data (l_table_counter).last_updated_by := l_last_updated_by;
           p_timekeeper_data (l_table_counter).last_update_login := l_last_update_login;
           p_timekeeper_data (l_table_counter).created_by := l_created_by;
           p_timekeeper_data (l_table_counter).creation_date := l_creation_date;
           p_timekeeper_data (l_table_counter).row_lock_id := l_row_lock_id;
           p_timekeeper_data (l_table_counter).tc_lock_success := l_tc_lock_success;
          ELSE
           --  IF (p_status_code is null and p_hours_type_id is null) THEN

           IF (    p_attribute1 IS NULL
               AND p_attribute2 IS NULL
               AND p_attribute3 IS NULL
               AND p_attribute4 IS NULL
               AND p_attribute5 IS NULL
               AND p_attribute6 IS NULL
               AND p_attribute7 IS NULL
               AND p_attribute8 IS NULL
               AND p_attribute9 IS NULL
               AND p_attribute10 IS NULL
               AND p_attribute11 IS NULL
               AND p_attribute12 IS NULL
               AND p_attribute13 IS NULL
               AND p_attribute14 IS NULL
               AND p_attribute15 IS NULL
               AND p_attribute16 IS NULL
               AND p_attribute17 IS NULL
               AND p_attribute18 IS NULL
               AND p_attribute19 IS NULL
               AND p_attribute20 IS NULL
              ) THEN
            if g_debug then
                    hr_utility.trace('two'||l_detail_info_table.count);
            end if;
            l_table_counter := l_table_counter + 1;

            LOOP
             EXIT WHEN (NOT l_detail_info_table.EXISTS (l_detail_index));
             if g_debug then
		     hr_utility.trace('two row'||l_table_counter);
		     hr_utility.trace('two row'||l_detail_id);
             end if;

             p_timekeeper_data (l_table_counter).timecard_status_code := l_status_code;
             p_timekeeper_data (l_table_counter).timecard_status := l_timecard_status_meaning;
             p_timekeeper_data (l_table_counter).timecard_message_code := l_timecard_message_code;
             p_timekeeper_data (l_table_counter).timecard_message := l_timecard_message;

             if g_debug then
                     hr_utility.trace('p_reqryflg is  '||p_reqryflg);
	     end if;
             IF p_reqryflg = 'N' THEN
              p_timekeeper_data (l_table_counter).check_box := 'Y';
              g_submit_table (resource_info.person_id).resource_id := resource_info.person_id;
              g_submit_table (resource_info.person_id).timecard_id := l_timecard_id;
              g_submit_table (resource_info.person_id).start_time := tc_start;
              g_submit_table (resource_info.person_id).stop_time := tc_end;
              g_submit_table (resource_info.person_id).row_lock_id := l_row_lock_id;
              g_submit_table (resource_info.person_id).no_rows :=
                                            NVL (g_submit_table (resource_info.person_id).no_rows, 0) + 1;
             ELSE
              p_timekeeper_data (l_table_counter).check_box := 'N';
              g_submit_table.DELETE (resource_info.person_id);
             END IF;

             p_timekeeper_data (l_table_counter).timecard_start_period := tc_start;
             p_timekeeper_data (l_table_counter).timecard_end_period := tc_end;
             p_timekeeper_data (l_table_counter).timecard_id := l_timecard_id;
             p_timekeeper_data (l_table_counter).timecard_ovn := l_timecard_ovn;
             p_timekeeper_data (l_table_counter).comment_text := l_timecard_comment_text;
             p_timekeeper_data (l_table_counter).resource_id := resource_info.person_id;
             p_timekeeper_data (l_table_counter).employee_number := resource_info.employee_number;
             p_timekeeper_data (l_table_counter).audit_enabled := l_audit_enabled;
             p_timekeeper_data (l_table_counter).person_type := resource_info.person_type;
             p_timekeeper_data (l_table_counter).employee_full_name := resource_info.full_name;
             p_timekeeper_data (l_table_counter).last_update_date := l_last_update_date;
             p_timekeeper_data (l_table_counter).last_updated_by := l_last_updated_by;
             p_timekeeper_data (l_table_counter).last_update_login := l_last_update_login;
             p_timekeeper_data (l_table_counter).created_by := l_created_by;
             p_timekeeper_data (l_table_counter).creation_date := l_creation_date;
             p_timekeeper_data (l_table_counter).row_lock_id := l_row_lock_id;
             p_timekeeper_data (l_table_counter).tc_lock_success := l_tc_lock_success;
             l_detail_id := l_detail_info_table (l_detail_index).detail_id;
             l_detail_ovn := l_detail_info_table (l_detail_index).detail_ovn;
             l_detail_measure := l_detail_info_table (l_detail_index).measure;
             l_detail_start_time := l_detail_info_table (l_detail_index).start_time;
             l_detail_time_in := l_detail_info_table (l_detail_index).time_in;
             l_detail_time_out := l_detail_info_table (l_detail_index).time_out;
             l_detail_comment_text := l_detail_info_table (l_detail_index).detail_comment_text;
             -- here we need to check if the item in the table is already populated.

             if g_debug then
		     hr_utility.TRACE ('l_detail_id3'|| l_detail_id);
		     hr_utility.TRACE ('l_timecard_id3'|| l_timecard_id);
		     hr_utility.TRACE ('l_detail_comment_text3'|| l_detail_comment_text);
	     end if;

--

             IF l_detail_comment_text IS NOT NULL THEN
              if g_debug then
		      hr_utility.TRACE ('500');
		      hr_utility.TRACE ('l_detail_id4'|| l_detail_id);
		      hr_utility.TRACE ('l_timecard_id4'|| l_timecard_id);
		      hr_utility.TRACE ('l_detail_comment_text4'|| l_detail_comment_text);
	      end if;

--

              IF c%ISOPEN THEN
               CLOSE c;
              END IF;

              OPEN c (l_detail_id);
              FETCH c INTO c_row;

              IF c%FOUND THEN
               UPDATE hxc_tk_detail_temp
               SET    comment_text = l_detail_comment_text
               WHERE  detailid = l_detail_id AND timecard_id = l_timecard_id;
              ELSE
               INSERT INTO hxc_tk_detail_temp
                           (detailid, timecard_id, comment_text)
               VALUES      (l_detail_id, l_timecard_id, l_detail_comment_text);
              END IF;

              CLOSE c;
             END IF;

             IF (l_timecard_start_time - l_add_index_day = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_1 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_1 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_1 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_1 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_1 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_1 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_1 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_1 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_1 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_1 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_1 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 1) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_2 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_2 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_2 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_2 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_2 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_2 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_2 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_2 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_2 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_2 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_2 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 2) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_3 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_3 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_3 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_3 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_3 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_3 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_3 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_3 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_3 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_3 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_3 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 3) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_4 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_4 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_4 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_4 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_4 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_4 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_4 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_4 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_4 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_4 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_4 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 4) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_5 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_5 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_5 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_5 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_5 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_5 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_5 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_5 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_5 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_5 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_5 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 5) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_6 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_6 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_6 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_6 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_6 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_6 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_6 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_6 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_6 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_6 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_6 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 6) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_7 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_7 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_7 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_7 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_7 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_7 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_7 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_7 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_7 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_7 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_7 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 7) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_8 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_8 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_8 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_8 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_8 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_8 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_8 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_8 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_8 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_8 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_8 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 8) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_9 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_9 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_9 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_9 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_9 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_9 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_9 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_9 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_9 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_9 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_9 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 9) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_10 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_10 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_10 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_10 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_10 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_10 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_10 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_10 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_10 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_10 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_10 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 10) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_11 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_11 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_11 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_11 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_11 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_11 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_11 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_11 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_11 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_11 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_11 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 11) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_12 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_12 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_12 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_12 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_12 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_12 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_12 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_12 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_12 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_12 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_12 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 12) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_13 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_13 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_13 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_13 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_13 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_13 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_13 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_13 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_13 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_13 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_13 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 13) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_14 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_14 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_14 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_14 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_14 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_14 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_14 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_14 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_14 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_14 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_14 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 14) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_15 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_15 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_15 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_15 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_15 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_15 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_15 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_15 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_15 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_15 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_15 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 15) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_16 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_16 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_16 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_16 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_16 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_16 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_16 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_16 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_16 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_16 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_16 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 16) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_17 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_17 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_17 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_17 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_17 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_17 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_17 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_17 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_17 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_17 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_17 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 17) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_18 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_18 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_18 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_18 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_18 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_18 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_18 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_18 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_18 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_18 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_18 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 18) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_19 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_19 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_19 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_19 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_19 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_19 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_19 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_19 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_19 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_19 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_19 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 19) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_20 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_20 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_20 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_20 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_20 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_20 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_20 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_20 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_20 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_20 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_20 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 20) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_21 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_21 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_21 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_21 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_21 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_21 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_21 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_21 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_21 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_21 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_21 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 21) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_22 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_22 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_22 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_22 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_22 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_22 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_22 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_22 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_22 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_22 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_22 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 22) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_23 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_23 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_23 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_23 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_23 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_23 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_23 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_23 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_23 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_23 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_23 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 23) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_24 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_24 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_24 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_24 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_24 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_24 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_24 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_24 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_24 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_24 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_24 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 24) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_25 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_25 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_25 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_25 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_25 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_25 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_25 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_25 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_25 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_25 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_25 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 25) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_26 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_26 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_26 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_26 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_26 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_26 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_26 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_26 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_26 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_26 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_26 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 26) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_27 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_27 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_27 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_27 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_27 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_27 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_27 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_27 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_27 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_27 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_27 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 27) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_28 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_28 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_28 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_28 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_28 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_28 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_28 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_28 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_28 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_28 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_28 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 28) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_29 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_29 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_29 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_29 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_29 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_29 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_29 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_29 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_29 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_29 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_29 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 29) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_30 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_30 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_30 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_30 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_30 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_30 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_30 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_30 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_30 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_30 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_30 := l_detail_ovn;
             ELSIF ((l_timecard_start_time - l_add_index_day + 30) = l_detail_start_time) THEN
              IF (    p_timekeeper_data (l_table_counter).day_31 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_in_31 IS NULL
                  AND p_timekeeper_data (l_table_counter).time_out_31 IS NULL
                 ) THEN
               p_timekeeper_data (l_table_counter).day_31 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_31 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_31 := l_detail_time_out;
              ELSE
               l_table_counter := l_table_counter + 1;
               p_timekeeper_data (l_table_counter).day_31 := l_detail_measure;
               p_timekeeper_data (l_table_counter).time_in_31 := l_detail_time_in;
               p_timekeeper_data (l_table_counter).time_out_31 := l_detail_time_out;
              END IF;

              p_timekeeper_data (l_table_counter).detail_id_31 := l_detail_id;
              p_timekeeper_data (l_table_counter).detail_ovn_31 := l_detail_ovn;
             END IF;

             p_timekeeper_data (l_table_counter).timecard_status_code := l_status_code;
             p_timekeeper_data (l_table_counter).timecard_status := l_timecard_status_meaning;
             p_timekeeper_data (l_table_counter).timecard_message_code := l_timecard_message_code;
             p_timekeeper_data (l_table_counter).timecard_message := l_timecard_message;
             p_timekeeper_data (l_table_counter).comment_text := l_timecard_comment_text;
             p_timekeeper_data (l_table_counter).timecard_start_period := tc_start;
             p_timekeeper_data (l_table_counter).timecard_end_period := tc_end;

             IF p_reqryflg = 'N' THEN
              p_timekeeper_data (l_table_counter).check_box := 'Y';
              g_submit_table (resource_info.person_id).resource_id := resource_info.person_id;
              g_submit_table (resource_info.person_id).timecard_id := l_timecard_id;
              g_submit_table (resource_info.person_id).start_time := tc_start;
              g_submit_table (resource_info.person_id).stop_time := tc_end;
              g_submit_table (resource_info.person_id).row_lock_id := l_row_lock_id;
              g_submit_table (resource_info.person_id).no_rows :=
                                            NVL (g_submit_table (resource_info.person_id).no_rows, 0) + 1;
             ELSE
              p_timekeeper_data (l_table_counter).check_box := 'N';
              g_submit_table.DELETE (resource_info.person_id);
             END IF;

             p_timekeeper_data (l_table_counter).timecard_id := l_timecard_id;
             p_timekeeper_data (l_table_counter).timecard_ovn := l_timecard_ovn;
             p_timekeeper_data (l_table_counter).resource_id := resource_info.person_id;
             p_timekeeper_data (l_table_counter).employee_number := resource_info.employee_number;
             p_timekeeper_data (l_table_counter).audit_enabled := l_audit_enabled;
             p_timekeeper_data (l_table_counter).person_type := resource_info.person_type;
             p_timekeeper_data (l_table_counter).employee_full_name := resource_info.full_name;
             p_timekeeper_data (l_table_counter).row_lock_id := l_row_lock_id;
             p_timekeeper_data (l_table_counter).tc_lock_success := l_tc_lock_success;
             l_detail_index := l_detail_info_table.NEXT (l_detail_index);
            END LOOP;
/*ADVICE(3044): Nested LOOPs should all be labeled [406] */

           END IF;
          if g_debug then
                  hr_utility.TRACE ('103--end of second type');
          end if;
          END IF;
         -- handle the case that the resource does not have a timecard
         --IF (l_found_timecard = false) THEN
         ELSIF (    p_status_code IS NULL
                AND p_message_type IS NULL
                AND p_message_text IS NULL
                AND p_change_reason IS NULL
                AND p_late_reason IS NULL
                AND p_audit_history IS NULL
                AND (    p_attribute1 IS NULL
                     AND p_attribute2 IS NULL
                     AND p_attribute3 IS NULL
                     AND p_attribute4 IS NULL
                     AND p_attribute5 IS NULL
                     AND p_attribute6 IS NULL
                     AND p_attribute7 IS NULL
                     AND p_attribute8 IS NULL
                     AND p_attribute9 IS NULL
                     AND p_attribute10 IS NULL
                     AND p_attribute11 IS NULL
                     AND p_attribute12 IS NULL
                     AND p_attribute13 IS NULL
                     AND p_attribute14 IS NULL
                     AND p_attribute15 IS NULL
                     AND p_attribute16 IS NULL
                     AND p_attribute17 IS NULL
                     AND p_attribute18 IS NULL
                     AND p_attribute19 IS NULL
                     AND p_attribute20 IS NULL
                    )
               ) THEN
          if g_debug then
		  hr_utility.TRACE('104--three- no record so create blank record');
		  hr_utility.TRACE ('no records');
          end if;
          BEGIN
           --l_rec_periodid := hxc_preference_evaluation.resource_preferences(resource_info.person_id,'TC_W_TCRD_PERIOD',1,SYSDATE);
           l_rec_periodid := l_emp_recpref;
          EXCEPTION
           WHEN OTHERS THEN
            l_rec_periodid := 0;
/*ADVICE(3089): A WHEN OTHERS clause is used in the exception section without any other specific handlers
              [201] */

          END;

          l_audit_query := FALSE;
          if g_debug then
		  hr_utility.TRACE ('l_audit_enabled'|| l_audit_enabled);
		  hr_utility.TRACE ('p_audit_enabled'|| p_audit_enabled);
	  end if;
          IF (   (l_audit_enabled IS NOT NULL AND p_audit_enabled = 'Y')
              OR (l_audit_enabled IS NULL AND p_audit_enabled = 'N')
              OR p_audit_enabled IS NULL
             ) THEN
           l_audit_query := TRUE;
          END IF;

          ---add a blank row only when recurring period matches period selected.

          IF emp_qry_tc_info.COUNT > 1 THEN
           NULL; ---for mid period employee even if one timecard is found i
/*ADVICE(3109): Use of NULL statements [532] */

          ---in that period do not add an addtional blank row.
          ELSE
           IF  NVL (l_rec_periodid, '-999') = NVL (p_rec_periodid, '-999') AND l_audit_query THEN
            --now we lock the timecard
            IF  p_reqryflg = 'N' AND p_lock_profile = 'Y' THEN
             --lock only when user does fresh find

             l_row_id := NULL;
             l_row_lock_id := NULL;
             l_tc_lock_success := 'FALSE';
             hxc_lock_api.request_lock (
              p_process_locker_type => l_process_lock_type,
              p_resource_id => resource_info.person_id,
              p_start_time => p_start_period,
              p_stop_time => p_end_period + g_one_day,
              p_time_building_block_id => NULL,
              p_time_building_block_ovn => NULL,
              p_transaction_lock_id => l_lock_trx_id,
              p_messages => l_messages,
              p_row_lock_id => l_row_id,
              p_locked_success => l_tc_lock_boolean
             );
             l_row_lock_id := ROWIDTOCHAR (l_row_id);

             IF l_tc_lock_boolean THEN
              l_tc_lock_success := 'TRUE';
              g_lock_table (resource_info.person_id).row_lock_id := l_row_id;
              g_lock_table (resource_info.person_id).resource_id := resource_info.person_id;
              g_lock_table (resource_info.person_id).timecard_id := NULL;
              g_lock_table (resource_info.person_id).start_time := p_start_period;
              g_lock_table (resource_info.person_id).stop_time := p_end_period + g_one_day;
             ELSE
              l_tc_lock_success := 'FALSE';
             END IF; --lock
            --nitin check
            -- l_resource_tc_table (resource_info.person_id).lockid:=l_row_lock_id;
            ELSE --lock prof
             IF l_row_lock_id IS NOT NULL THEN
              l_tc_lock_success := 'TRUE';
             ELSE
              l_tc_lock_success := 'FALSE';
             END IF;
            END IF;

            if g_debug then
                    hr_utility.TRACE ('adding entry');
            end if;

            /* Added for bug 8775740 HR OTL Absence Integration.

            Main call to populate the p_timekeeper_data with the prepopulated
            absences. This call is governed with the profiles and the pref checks.

            */

            -- Change Start

            -- Fresh timecard Start

            BEGIN

            if  l_row_lock_id is not null then


            l_pref_date:= hxc_timekeeper_utilities.get_pref_eval_date( p_resource_id   => resource_info.person_id,
                                              p_tc_start_date => p_start_period,
                                              p_tc_end_date   => p_end_period );


            hxc_preference_evaluation.resource_preferences
	                 (p_resource_id           => resource_info.person_id,
	    	          p_start_evaluation_date => l_pref_date,
	    	          p_end_evaluation_date   => l_pref_date,
	                  p_pref_table            => l_pref_table);

	                        l_pref_index := l_pref_table.FIRST;
	    	               LOOP
	    	               IF l_pref_table(l_pref_index).preference_code = 'TS_ABS_PREFERENCES'
	    	               THEN
	    	                   g_resource_abs_enabled := l_pref_table(l_pref_index).attribute1;
	    	                   EXIT;
	    	               END IF;
	    	               l_pref_index := l_pref_table.NEXT(l_pref_index);
	    	               EXIT WHEN NOT l_pref_table.EXISTS(l_pref_index);
	                       END LOOP;

	                 if ((g_resource_abs_enabled is null or g_resource_abs_enabled <> 'Y') OR
	                     (g_abs_intg_profile_set <> 'Y') )then

	                            g_resource_abs_enabled:= 'N';
	                 else
	                            g_resource_abs_enabled:= 'Y';
	                 end if;


	                if (g_resource_abs_enabled='Y' and
	                   p_reqryflg<>'Y' ) then


                          -- Added for bug 8916345
                          -- getting the hire/terminate info

                           if p_start_period < l_emp_start_date THEN
			   	l_abs_tc_start:=   l_emp_start_date;
			   else
			   	l_abs_tc_start:=   p_start_period;
			   end if;

			   if p_end_period > nvl(l_emp_terminate_date, p_end_period) then
			   	l_abs_tc_end:=	l_emp_terminate_date;
			   else
		                l_abs_tc_end:=  p_end_period;
                           end if;




	                if g_debug then
	                hr_utility.trace('SVG ENTERING goin to call absence');
	                end if;

                        if g_debug then
	                hr_utility.trace('l_row_lock_id = '||ROWIDTOCHAR(l_row_lock_id));
                        hr_utility.trace('p_timekeeper_id = '||p_timekeeper_id);
                        hr_utility.trace('p_start_period = '||l_abs_tc_start);
                        hr_utility.trace('p_end_period = '||l_abs_tc_end);
                        hr_utility.trace('p_tc_start = '|| p_start_period);
                        hr_utility.trace('p_tc_end = '|| p_end_period);
                        end if;

	                hxc_timekeeper_utilities.PRE_POPULATE_ABSENCE_DETAILS
	    	     (p_timekeeper_id 	=>  p_timekeeper_id ,
	    	      p_start_period 	=>  l_abs_tc_start  ,
	    	      p_end_period 	=>  l_abs_tc_end + g_one_day  ,
	    	      p_tc_start	=>  p_start_period,
	    	      p_tc_end		=>  p_end_period,
	    	      p_resource_id 	=>  resource_info.person_id  ,
	    	      p_lock_row_id     =>  l_row_lock_id,
	    	      p_tk_abs_tab	=>  t_tk_abs_tab);

	              g_resource_prepop_count:=  g_resource_prepop_count + 1;

	            if g_debug then
	    	    hr_utility.trace('SVG ENTERING coming out of call absence');
	    	    end if;

	    	    end if; -- g_resource_abs_enabled


	                if g_debug then

	                hr_utility.trace('SVG printing t_tk_abs_tab table');
	                hr_utility.trace('------------------------------');

	                IF t_tk_abs_tab.count>0 THEN

	                	FOR prepop_count IN t_tk_abs_tab.FIRST .. t_tk_abs_tab.LAST
	                	LOOP

	    		hr_utility.trace('attr_id_1                     = '|| t_tk_abs_tab(prepop_count).attr_id_1                         );
	    		hr_utility.trace('attr_id_2                     = '|| t_tk_abs_tab(prepop_count).attr_id_2                         );
	    		hr_utility.trace('attr_id_3                     = '|| t_tk_abs_tab(prepop_count).attr_id_3                         );
	    		hr_utility.trace('attr_id_4                     = '|| t_tk_abs_tab(prepop_count).attr_id_4                         );
	    		hr_utility.trace('attr_id_5                     = '|| t_tk_abs_tab(prepop_count).attr_id_5                         );
	    		hr_utility.trace('attr_id_6                     = '|| t_tk_abs_tab(prepop_count).attr_id_6                         );
	    		hr_utility.trace('attr_id_7                     = '|| t_tk_abs_tab(prepop_count).attr_id_7                         );
	    		hr_utility.trace('attr_id_8                     = '|| t_tk_abs_tab(prepop_count).attr_id_8                         );
	    		hr_utility.trace('attr_id_9                     = '|| t_tk_abs_tab(prepop_count).attr_id_9                         );
	    		hr_utility.trace('attr_id_10                    = '|| t_tk_abs_tab(prepop_count).attr_id_10                        );
	    		hr_utility.trace('attr_id_11                    = '|| t_tk_abs_tab(prepop_count).attr_id_11                        );
	    		hr_utility.trace('attr_id_12                    = '|| t_tk_abs_tab(prepop_count).attr_id_12                        );
	    		hr_utility.trace('attr_id_13                    = '|| t_tk_abs_tab(prepop_count).attr_id_13                        );
	    		hr_utility.trace('attr_id_14                    = '|| t_tk_abs_tab(prepop_count).attr_id_14                        );
	    		hr_utility.trace('attr_id_15                    = '|| t_tk_abs_tab(prepop_count).attr_id_15                        );
	    		hr_utility.trace('attr_id_16                    = '|| t_tk_abs_tab(prepop_count).attr_id_16                        );
	    		hr_utility.trace('attr_id_17                    = '|| t_tk_abs_tab(prepop_count).attr_id_17                        );
	    		hr_utility.trace('attr_id_18                    = '|| t_tk_abs_tab(prepop_count).attr_id_18                        );
	    		hr_utility.trace('attr_id_19                    = '|| t_tk_abs_tab(prepop_count).attr_id_19                        );
	    		hr_utility.trace('attr_id_20                    = '|| t_tk_abs_tab(prepop_count).attr_id_20                        );
	    		hr_utility.trace('day_1                         = '|| t_tk_abs_tab(prepop_count).day_1                             );
	    		hr_utility.trace('day_2                         = '|| t_tk_abs_tab(prepop_count).day_2                             );
	    		hr_utility.trace('day_3                         = '|| t_tk_abs_tab(prepop_count).day_3                             );
	    		hr_utility.trace('day_4                         = '|| t_tk_abs_tab(prepop_count).day_4                             );
	    		hr_utility.trace('day_5                         = '|| t_tk_abs_tab(prepop_count).day_5                             );
	    		hr_utility.trace('day_6                         = '|| t_tk_abs_tab(prepop_count).day_6                             );
	    		hr_utility.trace('day_7                         = '|| t_tk_abs_tab(prepop_count).day_7                             );
	    		hr_utility.trace('day_8                         = '|| t_tk_abs_tab(prepop_count).day_8                             );
	    		hr_utility.trace('day_9                         = '|| t_tk_abs_tab(prepop_count).day_9                             );
	    		hr_utility.trace('day_10                        = '|| t_tk_abs_tab(prepop_count).day_10                            );
	    		hr_utility.trace('day_11                        = '|| t_tk_abs_tab(prepop_count).day_11                            );
	    		hr_utility.trace('day_12                        = '|| t_tk_abs_tab(prepop_count).day_12                            );
	    		hr_utility.trace('day_13                        = '|| t_tk_abs_tab(prepop_count).day_13                            );
	    		hr_utility.trace('day_14                        = '|| t_tk_abs_tab(prepop_count).day_14                            );
	    		hr_utility.trace('day_15                        = '|| t_tk_abs_tab(prepop_count).day_15                            );
	    		hr_utility.trace('day_16                        = '|| t_tk_abs_tab(prepop_count).day_16                            );
	    		hr_utility.trace('day_17                        = '|| t_tk_abs_tab(prepop_count).day_17                            );
	    		hr_utility.trace('day_18                        = '|| t_tk_abs_tab(prepop_count).day_18                            );
	    		hr_utility.trace('day_19                        = '|| t_tk_abs_tab(prepop_count).day_19                            );
	    		hr_utility.trace('day_20                        = '|| t_tk_abs_tab(prepop_count).day_20                            );
	    		hr_utility.trace('day_21                        = '|| t_tk_abs_tab(prepop_count).day_21                            );
	    		hr_utility.trace('day_22                        = '|| t_tk_abs_tab(prepop_count).day_22                            );
	    		hr_utility.trace('day_23                        = '|| t_tk_abs_tab(prepop_count).day_23                            );
	    		hr_utility.trace('day_24                        = '|| t_tk_abs_tab(prepop_count).day_24                            );
	    		hr_utility.trace('day_25                        = '|| t_tk_abs_tab(prepop_count).day_25                            );
	    		hr_utility.trace('day_26                        = '|| t_tk_abs_tab(prepop_count).day_26                            );
	    		hr_utility.trace('day_27                        = '|| t_tk_abs_tab(prepop_count).day_27                            );
	    		hr_utility.trace('day_28                        = '|| t_tk_abs_tab(prepop_count).day_28                            );
	    		hr_utility.trace('day_29                        = '|| t_tk_abs_tab(prepop_count).day_29                            );
	    		hr_utility.trace('day_30                        = '|| t_tk_abs_tab(prepop_count).day_30                            );
	    		hr_utility.trace('day_31                        = '|| t_tk_abs_tab(prepop_count).day_31                            );
	    		hr_utility.trace('time_in_1                     = '|| t_tk_abs_tab(prepop_count).time_in_1                         );
	    		hr_utility.trace('time_out_1                    = '|| t_tk_abs_tab(prepop_count).time_out_1                        );
	    		hr_utility.trace('time_in_2                     = '|| t_tk_abs_tab(prepop_count).time_in_2                         );
	    		hr_utility.trace('time_out_2                    = '|| t_tk_abs_tab(prepop_count).time_out_2                        );
	    		hr_utility.trace('time_in_3                     = '|| t_tk_abs_tab(prepop_count).time_in_3                         );
	    		hr_utility.trace('time_out_3                    = '|| t_tk_abs_tab(prepop_count).time_out_3                        );
	    		hr_utility.trace('time_in_4                     = '|| t_tk_abs_tab(prepop_count).time_in_4                         );
	    		hr_utility.trace('time_out_4                    = '|| t_tk_abs_tab(prepop_count).time_out_4                        );
	    		hr_utility.trace('time_in_5                     = '|| t_tk_abs_tab(prepop_count).time_in_5                         );
	    		hr_utility.trace('time_out_5                    = '|| t_tk_abs_tab(prepop_count).time_out_5                        );
	    		hr_utility.trace('time_in_6                     = '|| t_tk_abs_tab(prepop_count).time_in_6                         );
	    		hr_utility.trace('time_out_6                    = '|| t_tk_abs_tab(prepop_count).time_out_6                        );
	    		hr_utility.trace('time_in_7                     = '|| t_tk_abs_tab(prepop_count).time_in_7                         );
	    		hr_utility.trace('time_out_7                    = '|| t_tk_abs_tab(prepop_count).time_out_7                        );
	    		hr_utility.trace('time_in_8                     = '|| t_tk_abs_tab(prepop_count).time_in_8                         );
	    		hr_utility.trace('time_out_8                    = '|| t_tk_abs_tab(prepop_count).time_out_8                        );
	    		hr_utility.trace('time_in_9                     = '|| t_tk_abs_tab(prepop_count).time_in_9                         );
	    		hr_utility.trace('time_out_9                    = '|| t_tk_abs_tab(prepop_count).time_out_9                        );
	    		hr_utility.trace('time_in_10                    = '|| t_tk_abs_tab(prepop_count).time_in_10                        );
	    		hr_utility.trace('time_out_10                   = '|| t_tk_abs_tab(prepop_count).time_out_10                       );
	    		hr_utility.trace('time_in_11                    = '|| t_tk_abs_tab(prepop_count).time_in_11                        );
	    		hr_utility.trace('time_out_11                   = '|| t_tk_abs_tab(prepop_count).time_out_11                       );
	    		hr_utility.trace('time_in_12                    = '|| t_tk_abs_tab(prepop_count).time_in_12                        );
	    		hr_utility.trace('time_out_12                   = '|| t_tk_abs_tab(prepop_count).time_out_12                       );
	    		hr_utility.trace('time_in_13                    = '|| t_tk_abs_tab(prepop_count).time_in_13                        );
	    		hr_utility.trace('time_out_13                   = '|| t_tk_abs_tab(prepop_count).time_out_13                       );
	    		hr_utility.trace('time_in_14                    = '|| t_tk_abs_tab(prepop_count).time_in_14                        );
	    		hr_utility.trace('time_out_14                   = '|| t_tk_abs_tab(prepop_count).time_out_14                       );
	    		hr_utility.trace('time_in_15                    = '|| t_tk_abs_tab(prepop_count).time_in_15                        );
	    		hr_utility.trace('time_out_15                   = '|| t_tk_abs_tab(prepop_count).time_out_15                       );
	    		hr_utility.trace('time_in_16                    = '|| t_tk_abs_tab(prepop_count).time_in_16                        );
	    		hr_utility.trace('time_out_16                   = '|| t_tk_abs_tab(prepop_count).time_out_16                       );
	    		hr_utility.trace('time_in_17                    = '|| t_tk_abs_tab(prepop_count).time_in_17                        );
	    		hr_utility.trace('time_out_17                   = '|| t_tk_abs_tab(prepop_count).time_out_17                       );
	    		hr_utility.trace('time_in_18                    = '|| t_tk_abs_tab(prepop_count).time_in_18                        );
	    		hr_utility.trace('time_out_18                   = '|| t_tk_abs_tab(prepop_count).time_out_18                       );
	    		hr_utility.trace('time_in_19                    = '|| t_tk_abs_tab(prepop_count).time_in_19                        );
	    		hr_utility.trace('time_out_19                   = '|| t_tk_abs_tab(prepop_count).time_out_19                       );
	    		hr_utility.trace('time_in_20                    = '|| t_tk_abs_tab(prepop_count).time_in_20                        );
	    		hr_utility.trace('time_out_20                   = '|| t_tk_abs_tab(prepop_count).time_out_20                       );
	    		hr_utility.trace('time_in_21                    = '|| t_tk_abs_tab(prepop_count).time_in_21                        );
	    		hr_utility.trace('time_out_21                   = '|| t_tk_abs_tab(prepop_count).time_out_21                       );
	    		hr_utility.trace('time_in_22                    = '|| t_tk_abs_tab(prepop_count).time_in_22                        );
	    		hr_utility.trace('time_out_22                   = '|| t_tk_abs_tab(prepop_count).time_out_22                       );
	    		hr_utility.trace('time_in_23                    = '|| t_tk_abs_tab(prepop_count).time_in_23                        );
	    		hr_utility.trace('time_out_23                   = '|| t_tk_abs_tab(prepop_count).time_out_23                       );
	    		hr_utility.trace('time_in_24                    = '|| t_tk_abs_tab(prepop_count).time_in_24                        );
	    		hr_utility.trace('time_out_24                   = '|| t_tk_abs_tab(prepop_count).time_out_24                       );
	    		hr_utility.trace('time_in_25                    = '|| t_tk_abs_tab(prepop_count).time_in_25                        );
	    		hr_utility.trace('time_out_25                   = '|| t_tk_abs_tab(prepop_count).time_out_25                       );
	    		hr_utility.trace('time_in_26                    = '|| t_tk_abs_tab(prepop_count).time_in_26                        );
	    		hr_utility.trace('time_out_26                   = '|| t_tk_abs_tab(prepop_count).time_out_26                       );
	    		hr_utility.trace('time_in_27                    = '|| t_tk_abs_tab(prepop_count).time_in_27                        );
	    		hr_utility.trace('time_out_27                   = '|| t_tk_abs_tab(prepop_count).time_out_27                       );
	    		hr_utility.trace('time_in_28                    = '|| t_tk_abs_tab(prepop_count).time_in_28                        );
	    		hr_utility.trace('time_out_28                   = '|| t_tk_abs_tab(prepop_count).time_out_28                       );
	    		hr_utility.trace('time_in_29                    = '|| t_tk_abs_tab(prepop_count).time_in_29                        );
	    		hr_utility.trace('time_out_29                   = '|| t_tk_abs_tab(prepop_count).time_out_29                       );
	    		hr_utility.trace('time_in_30                    = '|| t_tk_abs_tab(prepop_count).time_in_30                        );
	    		hr_utility.trace('time_out_30                   = '|| t_tk_abs_tab(prepop_count).time_out_30                       );
	    		hr_utility.trace('time_in_31                    = '|| t_tk_abs_tab(prepop_count).time_in_31                        );
	    		hr_utility.trace('time_out_31                   = '|| t_tk_abs_tab(prepop_count).time_out_31                       );
	    		hr_utility.trace('-----------------------------------');




	                	END LOOP;



	                END IF;

	               end if;-- g_debug



	                IF g_resource_abs_enabled ='Y' THEN

	                IF t_tk_abs_tab.COUNT>0 THEN


	                FOR prepop_count IN  t_tk_abs_tab.FIRST .. t_tk_abs_tab.LAST

	                LOOP


	                l_table_counter := l_table_counter + 1;
	                p_timekeeper_data (l_table_counter).resource_id := resource_info.person_id;
	                p_timekeeper_data (l_table_counter).timecard_id := fnd_api.g_miss_num;
	                p_timekeeper_data (l_table_counter).employee_number := resource_info.employee_number;
	                p_timekeeper_data (l_table_counter).audit_enabled := l_audit_enabled;
	                p_timekeeper_data (l_table_counter).person_type := resource_info.person_type;
	                p_timekeeper_data (l_table_counter).employee_full_name := resource_info.full_name;
	                p_timekeeper_data (l_table_counter).row_lock_id := l_row_lock_id;
	                p_timekeeper_data (l_table_counter).tc_lock_success := l_tc_lock_success;
	                --p_timekeeper_data (l_table_counter).check_box := 'Y';

	                /*

	                 p_timekeeper_data (l_table_counter).timecard_status_code := 'PREPOPULATED';

	                 l_timecard_status_meaning :=
	                         hr_bis.bis_decode_lookup ('HXC_APPROVAL_STATUS', 'PREPOPULATED');


	                 p_timekeeper_data (l_table_counter).timecard_status := l_timecard_status_meaning;


	                */


	                p_timekeeper_data (l_table_counter).attr_id_1        := t_tk_abs_tab(prepop_count).attr_id_1        	;
	                p_timekeeper_data (l_table_counter).attr_id_2        := t_tk_abs_tab(prepop_count).attr_id_2        	;
	                p_timekeeper_data (l_table_counter).attr_id_3        := t_tk_abs_tab(prepop_count).attr_id_3        	;
	                p_timekeeper_data (l_table_counter).attr_id_4        := t_tk_abs_tab(prepop_count).attr_id_4        	;
	                p_timekeeper_data (l_table_counter).attr_id_5        := t_tk_abs_tab(prepop_count).attr_id_5        	;
	                p_timekeeper_data (l_table_counter).attr_id_6        := t_tk_abs_tab(prepop_count).attr_id_6        	;
	                p_timekeeper_data (l_table_counter).attr_id_7        := t_tk_abs_tab(prepop_count).attr_id_7        	;
	                p_timekeeper_data (l_table_counter).attr_id_8        := t_tk_abs_tab(prepop_count).attr_id_8        	;
	                p_timekeeper_data (l_table_counter).attr_id_9        := t_tk_abs_tab(prepop_count).attr_id_9        	;
	                p_timekeeper_data (l_table_counter).attr_id_10       := t_tk_abs_tab(prepop_count).attr_id_10       	;
	                p_timekeeper_data (l_table_counter).attr_id_11       := t_tk_abs_tab(prepop_count).attr_id_11       	;
	                p_timekeeper_data (l_table_counter).attr_id_12       := t_tk_abs_tab(prepop_count).attr_id_12       	;
	                p_timekeeper_data (l_table_counter).attr_id_13       := t_tk_abs_tab(prepop_count).attr_id_13       	;
	                p_timekeeper_data (l_table_counter).attr_id_14       := t_tk_abs_tab(prepop_count).attr_id_14       	;
	                p_timekeeper_data (l_table_counter).attr_id_15       := t_tk_abs_tab(prepop_count).attr_id_15       	;
	                p_timekeeper_data (l_table_counter).attr_id_16       := t_tk_abs_tab(prepop_count).attr_id_16       	;
	                p_timekeeper_data (l_table_counter).attr_id_17       := t_tk_abs_tab(prepop_count).attr_id_17       	 ;
	                p_timekeeper_data (l_table_counter).attr_id_18       := t_tk_abs_tab(prepop_count).attr_id_18       	;
	                p_timekeeper_data (l_table_counter).attr_id_19       := t_tk_abs_tab(prepop_count).attr_id_19       	;
	                p_timekeeper_data (l_table_counter).attr_id_20       := t_tk_abs_tab(prepop_count).attr_id_20       	;
	                p_timekeeper_data (l_table_counter).day_1            := t_tk_abs_tab(prepop_count).day_1            	 ;
	                p_timekeeper_data (l_table_counter).day_2            := t_tk_abs_tab(prepop_count).day_2            	;
	                p_timekeeper_data (l_table_counter).day_3            := t_tk_abs_tab(prepop_count).day_3            	;
	                p_timekeeper_data (l_table_counter).day_4            := t_tk_abs_tab(prepop_count).day_4            	;
	                p_timekeeper_data (l_table_counter).day_5            := t_tk_abs_tab(prepop_count).day_5            	;
	                p_timekeeper_data (l_table_counter).day_6            := t_tk_abs_tab(prepop_count).day_6            	;
	                p_timekeeper_data (l_table_counter).day_7            := t_tk_abs_tab(prepop_count).day_7            	;
	                p_timekeeper_data (l_table_counter).day_8            := t_tk_abs_tab(prepop_count).day_8            	;
	                p_timekeeper_data (l_table_counter).day_9            := t_tk_abs_tab(prepop_count).day_9            	;
	                p_timekeeper_data (l_table_counter).day_10           := t_tk_abs_tab(prepop_count).day_10           	;
	                p_timekeeper_data (l_table_counter).day_11           := t_tk_abs_tab(prepop_count).day_11           	 ;
	                p_timekeeper_data (l_table_counter).day_12           := t_tk_abs_tab(prepop_count).day_12           	;
	                p_timekeeper_data (l_table_counter).day_13           := t_tk_abs_tab(prepop_count).day_13           	 ;
	                p_timekeeper_data (l_table_counter).day_14           := t_tk_abs_tab(prepop_count).day_14           	;
	                p_timekeeper_data (l_table_counter).day_15           := t_tk_abs_tab(prepop_count).day_15           	;
	                p_timekeeper_data (l_table_counter).day_16           := t_tk_abs_tab(prepop_count).day_16           	;
	                p_timekeeper_data (l_table_counter).day_17           := t_tk_abs_tab(prepop_count).day_17           	;
	                p_timekeeper_data (l_table_counter).day_18           := t_tk_abs_tab(prepop_count).day_18           	;
	                p_timekeeper_data (l_table_counter).day_19           := t_tk_abs_tab(prepop_count).day_19           	;
	                p_timekeeper_data (l_table_counter).day_20           := t_tk_abs_tab(prepop_count).day_20           	;
	                p_timekeeper_data (l_table_counter).day_21           := t_tk_abs_tab(prepop_count).day_21           	;
	                p_timekeeper_data (l_table_counter).day_22           := t_tk_abs_tab(prepop_count).day_22           	;
	                p_timekeeper_data (l_table_counter).day_23           := t_tk_abs_tab(prepop_count).day_23           	;
	                p_timekeeper_data (l_table_counter).day_24           := t_tk_abs_tab(prepop_count).day_24           	;
	                p_timekeeper_data (l_table_counter).day_25           := t_tk_abs_tab(prepop_count).day_25           	;
	                p_timekeeper_data (l_table_counter).day_26           := t_tk_abs_tab(prepop_count).day_26           	;
	                p_timekeeper_data (l_table_counter).day_27           := t_tk_abs_tab(prepop_count).day_27           	;
	                p_timekeeper_data (l_table_counter).day_28           := t_tk_abs_tab(prepop_count).day_28           	;
	                p_timekeeper_data (l_table_counter).day_29           := t_tk_abs_tab(prepop_count).day_29           	;
	                p_timekeeper_data (l_table_counter).day_30           := t_tk_abs_tab(prepop_count).day_30           	;
	                p_timekeeper_data (l_table_counter).day_31           := t_tk_abs_tab(prepop_count).day_31           	;
	                p_timekeeper_data (l_table_counter).time_in_1        := t_tk_abs_tab(prepop_count).time_in_1        	;
	                p_timekeeper_data (l_table_counter).time_out_1       := t_tk_abs_tab(prepop_count).time_out_1       	;
	                p_timekeeper_data (l_table_counter).time_in_2        := t_tk_abs_tab(prepop_count).time_in_2        	;
	                p_timekeeper_data (l_table_counter).time_out_2       := t_tk_abs_tab(prepop_count).time_out_2       	 ;
	                p_timekeeper_data (l_table_counter).time_in_3        := t_tk_abs_tab(prepop_count).time_in_3        	;
	                p_timekeeper_data (l_table_counter).time_out_3       := t_tk_abs_tab(prepop_count).time_out_3       	 ;
	                p_timekeeper_data (l_table_counter).time_in_4        := t_tk_abs_tab(prepop_count).time_in_4        	;
	                p_timekeeper_data (l_table_counter).time_out_4       := t_tk_abs_tab(prepop_count).time_out_4       	;
	                p_timekeeper_data (l_table_counter).time_in_5        := t_tk_abs_tab(prepop_count).time_in_5        	;
	                p_timekeeper_data (l_table_counter).time_out_5       := t_tk_abs_tab(prepop_count).time_out_5       	;
	                p_timekeeper_data (l_table_counter).time_in_6        := t_tk_abs_tab(prepop_count).time_in_6        	;
	                p_timekeeper_data (l_table_counter).time_out_6       := t_tk_abs_tab(prepop_count).time_out_6       	;
	                p_timekeeper_data (l_table_counter).time_in_7        := t_tk_abs_tab(prepop_count).time_in_7        	;
	                p_timekeeper_data (l_table_counter).time_out_7       := t_tk_abs_tab(prepop_count).time_out_7       	;
	                p_timekeeper_data (l_table_counter).time_in_8        := t_tk_abs_tab(prepop_count).time_in_8        	;
	                p_timekeeper_data (l_table_counter).time_out_8       := t_tk_abs_tab(prepop_count).time_out_8       	;
	                p_timekeeper_data (l_table_counter).time_in_9        := t_tk_abs_tab(prepop_count).time_in_9        	;
	                p_timekeeper_data (l_table_counter).time_out_9       := t_tk_abs_tab(prepop_count).time_out_9       	;
	                p_timekeeper_data (l_table_counter).time_in_10       := t_tk_abs_tab(prepop_count).time_in_10       	;
	                p_timekeeper_data (l_table_counter).time_out_10      := t_tk_abs_tab(prepop_count).time_out_10      	;
	                p_timekeeper_data (l_table_counter).time_in_11       := t_tk_abs_tab(prepop_count).time_in_11       	;
	                p_timekeeper_data (l_table_counter).time_out_11      := t_tk_abs_tab(prepop_count).time_out_11      	;
	                p_timekeeper_data (l_table_counter).time_in_12       := t_tk_abs_tab(prepop_count).time_in_12       	;
	                p_timekeeper_data (l_table_counter).time_out_12      := t_tk_abs_tab(prepop_count).time_out_12     ;
	                p_timekeeper_data (l_table_counter).time_in_13       := t_tk_abs_tab(prepop_count).time_in_13       	;
	                p_timekeeper_data (l_table_counter).time_out_13      := t_tk_abs_tab(prepop_count).time_out_13      	;
	                p_timekeeper_data (l_table_counter).time_in_14       := t_tk_abs_tab(prepop_count).time_in_14       	;
	                p_timekeeper_data (l_table_counter).time_out_14      := t_tk_abs_tab(prepop_count).time_out_14      	;
	                p_timekeeper_data (l_table_counter).time_in_15       := t_tk_abs_tab(prepop_count).time_in_15       	;
	                p_timekeeper_data (l_table_counter).time_out_15      := t_tk_abs_tab(prepop_count).time_out_15      	;
	                p_timekeeper_data (l_table_counter).time_in_16       := t_tk_abs_tab(prepop_count).time_in_16       	;
	                p_timekeeper_data (l_table_counter).time_out_16      := t_tk_abs_tab(prepop_count).time_out_16      	;
	                p_timekeeper_data (l_table_counter).time_in_17       := t_tk_abs_tab(prepop_count).time_in_17       	;
	                p_timekeeper_data (l_table_counter).time_out_17      := t_tk_abs_tab(prepop_count).time_out_17      	;
	                p_timekeeper_data (l_table_counter).time_in_18       := t_tk_abs_tab(prepop_count).time_in_18       	;
	                p_timekeeper_data (l_table_counter).time_out_18      := t_tk_abs_tab(prepop_count).time_out_18      	;
	                p_timekeeper_data (l_table_counter).time_in_19       := t_tk_abs_tab(prepop_count).time_in_19       	;
	                p_timekeeper_data (l_table_counter).time_out_19      := t_tk_abs_tab(prepop_count).time_out_19      	;
	                p_timekeeper_data (l_table_counter).time_in_20       := t_tk_abs_tab(prepop_count).time_in_20       	;
	                p_timekeeper_data (l_table_counter).time_out_20      := t_tk_abs_tab(prepop_count).time_out_20      	;
	                p_timekeeper_data (l_table_counter).time_in_21       := t_tk_abs_tab(prepop_count).time_in_21       	;
	                p_timekeeper_data (l_table_counter).time_out_21      := t_tk_abs_tab(prepop_count).time_out_21      	;
	                p_timekeeper_data (l_table_counter).time_in_22       := t_tk_abs_tab(prepop_count).time_in_22       	;
	                p_timekeeper_data (l_table_counter).time_out_22      := t_tk_abs_tab(prepop_count).time_out_22      	;
	                p_timekeeper_data (l_table_counter).time_in_23       := t_tk_abs_tab(prepop_count).time_in_23       	;
	                p_timekeeper_data (l_table_counter).time_out_23      := t_tk_abs_tab(prepop_count).time_out_23      	;
	                p_timekeeper_data (l_table_counter).time_in_24       := t_tk_abs_tab(prepop_count).time_in_24       	;
	                p_timekeeper_data (l_table_counter).time_out_24      := t_tk_abs_tab(prepop_count).time_out_24      	;
	                p_timekeeper_data (l_table_counter).time_in_25       := t_tk_abs_tab(prepop_count).time_in_25       	;
	                p_timekeeper_data (l_table_counter).time_out_25      := t_tk_abs_tab(prepop_count).time_out_25      	;
	                p_timekeeper_data (l_table_counter).time_in_26       := t_tk_abs_tab(prepop_count).time_in_26       	;
	                p_timekeeper_data (l_table_counter).time_out_26      := t_tk_abs_tab(prepop_count).time_out_26      	;
	                p_timekeeper_data (l_table_counter).time_in_27       := t_tk_abs_tab(prepop_count).time_in_27       	;
	                p_timekeeper_data (l_table_counter).time_out_27      := t_tk_abs_tab(prepop_count).time_out_27      	;
	                p_timekeeper_data (l_table_counter).time_in_28       := t_tk_abs_tab(prepop_count).time_in_28       	;
	                p_timekeeper_data (l_table_counter).time_out_28      := t_tk_abs_tab(prepop_count).time_out_28      	;
	                p_timekeeper_data (l_table_counter).time_in_29       := t_tk_abs_tab(prepop_count).time_in_29       	;
	                p_timekeeper_data (l_table_counter).time_out_29      := t_tk_abs_tab(prepop_count).time_out_29      	;
	                p_timekeeper_data (l_table_counter).time_in_30       := t_tk_abs_tab(prepop_count).time_in_30       	;
	                p_timekeeper_data (l_table_counter).time_out_30      := t_tk_abs_tab(prepop_count).time_out_30      	;
	                p_timekeeper_data (l_table_counter).time_in_31       := t_tk_abs_tab(prepop_count).time_in_31       	;
	                p_timekeeper_data (l_table_counter).time_out_31      := t_tk_abs_tab(prepop_count).time_out_31      	;

	                p_timekeeper_data (l_table_counter).detail_id_1      := t_tk_abs_tab(prepop_count).detail_id_1            	 ;
	                p_timekeeper_data (l_table_counter).detail_id_2      := t_tk_abs_tab(prepop_count).detail_id_2            	;
	                p_timekeeper_data (l_table_counter).detail_id_3      := t_tk_abs_tab(prepop_count).detail_id_3            	;
	                p_timekeeper_data (l_table_counter).detail_id_4      := t_tk_abs_tab(prepop_count).detail_id_4            	;
	                p_timekeeper_data (l_table_counter).detail_id_5      := t_tk_abs_tab(prepop_count).detail_id_5            	;
	                p_timekeeper_data (l_table_counter).detail_id_6      := t_tk_abs_tab(prepop_count).detail_id_6            	;
	                p_timekeeper_data (l_table_counter).detail_id_7      := t_tk_abs_tab(prepop_count).detail_id_7            	;
	                p_timekeeper_data (l_table_counter).detail_id_8      := t_tk_abs_tab(prepop_count).detail_id_8            	;
	                p_timekeeper_data (l_table_counter).detail_id_9      := t_tk_abs_tab(prepop_count).detail_id_9            	;
	                p_timekeeper_data (l_table_counter).detail_id_10     := t_tk_abs_tab(prepop_count).detail_id_10           	;
	                p_timekeeper_data (l_table_counter).detail_id_11     := t_tk_abs_tab(prepop_count).detail_id_11           	 ;
	                p_timekeeper_data (l_table_counter).detail_id_12     := t_tk_abs_tab(prepop_count).detail_id_12           	;
	                p_timekeeper_data (l_table_counter).detail_id_13     := t_tk_abs_tab(prepop_count).detail_id_13           	 ;
	                p_timekeeper_data (l_table_counter).detail_id_14     := t_tk_abs_tab(prepop_count).detail_id_14           	;
	                p_timekeeper_data (l_table_counter).detail_id_15     := t_tk_abs_tab(prepop_count).detail_id_15           	;
	                p_timekeeper_data (l_table_counter).detail_id_16     := t_tk_abs_tab(prepop_count).detail_id_16           	;
	                p_timekeeper_data (l_table_counter).detail_id_17     := t_tk_abs_tab(prepop_count).detail_id_17           	;
	                p_timekeeper_data (l_table_counter).detail_id_18     := t_tk_abs_tab(prepop_count).detail_id_18           	;
	                p_timekeeper_data (l_table_counter).detail_id_19     := t_tk_abs_tab(prepop_count).detail_id_19           	;
	                p_timekeeper_data (l_table_counter).detail_id_20     := t_tk_abs_tab(prepop_count).detail_id_20           	;
	                p_timekeeper_data (l_table_counter).detail_id_21     := t_tk_abs_tab(prepop_count).detail_id_21           	;
	                p_timekeeper_data (l_table_counter).detail_id_22     := t_tk_abs_tab(prepop_count).detail_id_22           	;
	                p_timekeeper_data (l_table_counter).detail_id_23     := t_tk_abs_tab(prepop_count).detail_id_23           	;
	                p_timekeeper_data (l_table_counter).detail_id_24     := t_tk_abs_tab(prepop_count).detail_id_24           	;
	                p_timekeeper_data (l_table_counter).detail_id_25     := t_tk_abs_tab(prepop_count).detail_id_25           	;
	                p_timekeeper_data (l_table_counter).detail_id_26     := t_tk_abs_tab(prepop_count).detail_id_26           	;
	                p_timekeeper_data (l_table_counter).detail_id_27     := t_tk_abs_tab(prepop_count).detail_id_27           	;
	                p_timekeeper_data (l_table_counter).detail_id_28     := t_tk_abs_tab(prepop_count).detail_id_28           	;
	                p_timekeeper_data (l_table_counter).detail_id_29     := t_tk_abs_tab(prepop_count).detail_id_29           	;
	                p_timekeeper_data (l_table_counter).detail_id_30     := t_tk_abs_tab(prepop_count).detail_id_30           	;
	                p_timekeeper_data (l_table_counter).detail_id_31     := t_tk_abs_tab(prepop_count).detail_id_31           	;

	                p_timekeeper_data (l_table_counter).detail_ovn_1      := t_tk_abs_tab(prepop_count).detail_ovn_1            	 ;
	                p_timekeeper_data (l_table_counter).detail_ovn_2      := t_tk_abs_tab(prepop_count).detail_ovn_2            	;
	                p_timekeeper_data (l_table_counter).detail_ovn_3      := t_tk_abs_tab(prepop_count).detail_ovn_3            	;
	                p_timekeeper_data (l_table_counter).detail_ovn_4      := t_tk_abs_tab(prepop_count).detail_ovn_4            	;
	                p_timekeeper_data (l_table_counter).detail_ovn_5      := t_tk_abs_tab(prepop_count).detail_ovn_5            	;
	                p_timekeeper_data (l_table_counter).detail_ovn_6      := t_tk_abs_tab(prepop_count).detail_ovn_6            	;
	                p_timekeeper_data (l_table_counter).detail_ovn_7      := t_tk_abs_tab(prepop_count).detail_ovn_7            	;
	                p_timekeeper_data (l_table_counter).detail_ovn_8      := t_tk_abs_tab(prepop_count).detail_ovn_8            	;
	                p_timekeeper_data (l_table_counter).detail_ovn_9      := t_tk_abs_tab(prepop_count).detail_ovn_9            	;
	                p_timekeeper_data (l_table_counter).detail_ovn_10     := t_tk_abs_tab(prepop_count).detail_ovn_10           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_11     := t_tk_abs_tab(prepop_count).detail_ovn_11           	 ;
	                p_timekeeper_data (l_table_counter).detail_ovn_12     := t_tk_abs_tab(prepop_count).detail_ovn_12           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_13     := t_tk_abs_tab(prepop_count).detail_ovn_13           	 ;
	                p_timekeeper_data (l_table_counter).detail_ovn_14     := t_tk_abs_tab(prepop_count).detail_ovn_14           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_15     := t_tk_abs_tab(prepop_count).detail_ovn_15           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_16     := t_tk_abs_tab(prepop_count).detail_ovn_16           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_17     := t_tk_abs_tab(prepop_count).detail_ovn_17           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_18     := t_tk_abs_tab(prepop_count).detail_ovn_18           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_19     := t_tk_abs_tab(prepop_count).detail_ovn_19           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_20     := t_tk_abs_tab(prepop_count).detail_ovn_20           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_21     := t_tk_abs_tab(prepop_count).detail_ovn_21           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_22     := t_tk_abs_tab(prepop_count).detail_ovn_22           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_23     := t_tk_abs_tab(prepop_count).detail_ovn_23           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_24     := t_tk_abs_tab(prepop_count).detail_ovn_24           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_25     := t_tk_abs_tab(prepop_count).detail_ovn_25           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_26     := t_tk_abs_tab(prepop_count).detail_ovn_26           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_27     := t_tk_abs_tab(prepop_count).detail_ovn_27           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_28     := t_tk_abs_tab(prepop_count).detail_ovn_28           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_29     := t_tk_abs_tab(prepop_count).detail_ovn_29           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_30     := t_tk_abs_tab(prepop_count).detail_ovn_30           	;
	                p_timekeeper_data (l_table_counter).detail_ovn_31     := t_tk_abs_tab(prepop_count).detail_ovn_31           	;









	                IF TO_DATE (tc_start, 'dd-mm-rrrr') < TO_DATE (l_emp_start_date, 'dd-mm-rrrr') THEN
	                 p_timekeeper_data (l_table_counter).timecard_start_period :=
	                                                                     TO_DATE (l_emp_start_date, 'dd-mm-rrrr');
	                ELSE
	                 p_timekeeper_data (l_table_counter).timecard_start_period := tc_start;
	                end if;
	                /* changes done by senthil for emp terminate enhancement*/
	                IF TO_DATE (tc_end, 'dd-mm-rrrr') > TO_DATE (nvl(l_emp_terminate_date,tc_end), 'dd-mm-rrrr') THEN
	                 p_timekeeper_data (l_table_counter).timecard_end_period := TO_DATE (nvl(l_emp_terminate_date,tc_end), 'dd-mm-rrrr');
	                ELSE
	                 p_timekeeper_data (l_table_counter).timecard_end_period := tc_end;
	                END IF;
	                /* end of changes done by senthil */

	                /* added so that g_submit table has prepopulated data*/

	                IF p_reqryflg = 'N' THEN
	    	                 p_timekeeper_data (l_table_counter).check_box := 'Y';
	    	                 g_submit_table (resource_info.person_id).resource_id := resource_info.person_id;
	    	                 g_submit_table (resource_info.person_id).timecard_id := fnd_api.g_miss_num;
	    	                 g_submit_table (resource_info.person_id).start_time :=
	    	                                                   p_timekeeper_data (l_table_counter).timecard_start_period;
	    	                 g_submit_table (resource_info.person_id).stop_time :=
	    	                                                     p_timekeeper_data (l_table_counter).timecard_end_period;
	    	                 g_submit_table (resource_info.person_id).row_lock_id := l_row_lock_id;
	    	                 g_submit_table (resource_info.person_id).no_rows :=
	    	                                                NVL (g_submit_table (resource_info.person_id).no_rows, 0) + 1;
	    	     ELSE
	                 		p_timekeeper_data (l_table_counter).check_box := 'N';
	                 END IF;





	                END LOOP;

	               END IF;  -- t_tk_abs_tab

	               END IF; --g_resource_abs_enabled

	       --else

	         --fnd_message.set_name ('HXC', 'HXC_TIMECARD_LOCKED');
		 --fnd_message.set_token ('FULL_NAME', l_empname);
                 --fnd_message.show;



	       end if; -- lock_rowid being null



	    -- Change End

	    -- Checking for notification excpetion
	    -- Then we need to leap frog this employee
	    if hxc_timekeeper_utilities.g_exception_detected = 'Y' then
	         hxc_timekeeper_utilities.g_exception_detected:= 'N';
	         raise l_abs_pending_appr_notif;
	    end if;

      if   l_row_lock_id is null then
            raise l_lock_not_obtained;
      end if;


            -- Populating another empty row for the PrePopulated employee

            l_table_counter := l_table_counter + 1;
            p_timekeeper_data (l_table_counter).resource_id := resource_info.person_id;
            p_timekeeper_data (l_table_counter).timecard_id := fnd_api.g_miss_num;
            p_timekeeper_data (l_table_counter).employee_number := resource_info.employee_number;
            p_timekeeper_data (l_table_counter).audit_enabled := l_audit_enabled;
            p_timekeeper_data (l_table_counter).person_type := resource_info.person_type;
            p_timekeeper_data (l_table_counter).employee_full_name := resource_info.full_name;
            p_timekeeper_data (l_table_counter).row_lock_id := l_row_lock_id;
            p_timekeeper_data (l_table_counter).tc_lock_success := l_tc_lock_success;

            IF TO_DATE (tc_start, 'dd-mm-rrrr') < TO_DATE (l_emp_start_date, 'dd-mm-rrrr') THEN
             p_timekeeper_data (l_table_counter).timecard_start_period :=
                                                                 TO_DATE (l_emp_start_date, 'dd-mm-rrrr');
            ELSE
             p_timekeeper_data (l_table_counter).timecard_start_period := tc_start;
            end if;
            /* changes done by senthil for emp terminate enhancement*/
            IF TO_DATE (tc_end, 'dd-mm-rrrr') > TO_DATE (nvl(l_emp_terminate_date,tc_end), 'dd-mm-rrrr') THEN
             p_timekeeper_data (l_table_counter).timecard_end_period := TO_DATE (nvl(l_emp_terminate_date,tc_end), 'dd-mm-rrrr');
            ELSE
             p_timekeeper_data (l_table_counter).timecard_end_period := tc_end;
            END IF;
            /* end of changes done by senthil */


            -- End if; -- svg

            IF p_reqryflg = 'N' THEN
             p_timekeeper_data (l_table_counter).check_box := 'Y';
             g_submit_table (resource_info.person_id).resource_id := resource_info.person_id;
             g_submit_table (resource_info.person_id).timecard_id := fnd_api.g_miss_num;
             g_submit_table (resource_info.person_id).start_time :=
                                               p_timekeeper_data (l_table_counter).timecard_start_period;
             g_submit_table (resource_info.person_id).stop_time :=
                                                 p_timekeeper_data (l_table_counter).timecard_end_period;
             g_submit_table (resource_info.person_id).row_lock_id := l_row_lock_id;
             g_submit_table (resource_info.person_id).no_rows :=
                                            NVL (g_submit_table (resource_info.person_id).no_rows, 0) + 1;
            ELSE
             p_timekeeper_data (l_table_counter).check_box := 'N';
             g_submit_table.DELETE (resource_info.person_id);
            END IF;

            -- Reached a normal cycle for a timecard .
            EXCEPTION
              WHEN l_abs_pending_appr_notif THEN

                 -- we need to cache this info for the form to display
                 g_query_exception_tab(resource_info.person_id).Employee_full_name:=
                                                 resource_info.full_name;
                 g_query_exception_tab(resource_info.person_id).employee_number:=
                                                 resource_info.employee_number;
                 if hxc_timekeeper_utilities.g_abs_message_string =
                       'HXC_ABS_PEND_APPR_DELETE' then
                      g_query_exception_tab(resource_info.person_id).Message:=
                       'HXC_TK_ABS_PEND_APPR_DELETE';
                 elsif  hxc_timekeeper_utilities.g_abs_message_string =
                       'HXC_ABS_PEND_APPR_ERROR' then
                      g_query_exception_tab(resource_info.person_id).Message:=
                       'HXC_TK_ABS_PEND_APPR_ERROR';
                 end if;

              WHEN l_lock_not_obtained THEN

                 g_query_exception_tab(resource_info.person_id).Employee_full_name:=
                                                 resource_info.full_name;
                 g_query_exception_tab(resource_info.person_id).employee_number:=
                                                 resource_info.employee_number;
                 g_query_exception_tab(resource_info.person_id).Message:=
                         'HXC_TK_PREPOP_NOT_LOCKED';


            END; --   Fresh timecard End


           END IF; ---recurring period match
          END IF; ---end if for mid period add blank row
         END IF;

         CLOSE c_timecard_info;
         emp_tab_index := emp_qry_tc_info.NEXT (emp_tab_index);
        END LOOP; ----periods list
/*ADVICE(3197): Nested LOOPs should all be labeled [406] */

       END IF; --- l_query
      END IF; ------added for duplicate employee
     EXCEPTION
      WHEN l_pref_exception THEN
       NULL;
/*ADVICE(3204): Use of NULL statements [532] */

/*ADVICE(3206): Exception masked by a NULL statement [533] */

     END;
    END LOOP;

    IF p_reqryflg = 'N' THEN
     g_resource_tc_table.DELETE;
     l_index := p_timekeeper_data.FIRST;

     LOOP
      EXIT WHEN NOT p_timekeeper_data.EXISTS (l_index);

      IF      g_resource_tc_table.EXISTS (p_timekeeper_data (l_index).resource_id)
          AND p_timekeeper_data (l_index).check_box = 'Y' THEN
       IF p_timekeeper_data (l_index).check_box = 'N' THEN
        g_resource_tc_table (p_timekeeper_data (l_index).resource_id).no_rows := 0;
       ELSE
        g_resource_tc_table (p_timekeeper_data (l_index).resource_id).no_rows :=
                               g_resource_tc_table (p_timekeeper_data (l_index).resource_id).no_rows + 1;
       END IF;
      ELSE
       IF p_timekeeper_data (l_index).check_box = 'Y' THEN
        g_resource_tc_table (p_timekeeper_data (l_index).resource_id).no_rows := 1;
       ELSE
        g_resource_tc_table (p_timekeeper_data (l_index).resource_id).no_rows := 0;
       END IF;
      END IF;

      l_index := p_timekeeper_data.NEXT (l_index);
     END LOOP;
    END IF;
   END IF;

--SVG CHANGE

   /*

      IF g_debug then

        if p_timekeeper_data.count>0 then


    hr_utility.trace(' SVG timekeeper TABLE start ');
    hr_utility.trace(' *****************');

      l_table_counter_tmp := p_timekeeper_data.FIRST;

        LOOP
       EXIT WHEN NOT p_timekeeper_data.EXISTS (l_table_counter_tmp);

        hr_utility.trace(' l_table_counter_tmp = '||l_table_counter_tmp);
        hr_utility.trace(' timecard_start_period     =   :'|| p_timekeeper_data(l_table_counter_tmp).timecard_start_period        );
        hr_utility.trace(' timecard_end_period    =      :'|| p_timekeeper_data(l_table_counter_tmp).timecard_end_period                );
        hr_utility.trace(' resource_id         =         :'|| p_timekeeper_data(l_table_counter_tmp).resource_id                        );
        hr_utility.trace(' employee_number      =        :'|| p_timekeeper_data(l_table_counter_tmp).employee_number                    );
        hr_utility.trace(' employee_full_name    =       :'|| p_timekeeper_data(l_table_counter_tmp).employee_full_name                 );
        hr_utility.trace(' timecard_id            =      :'|| p_timekeeper_data(l_table_counter_tmp).timecard_id                        );
        hr_utility.trace(' timecard_ovn        =         :'|| p_timekeeper_data(l_table_counter_tmp).timecard_ovn                       );
        hr_utility.trace(' check_box            =        :'|| p_timekeeper_data(l_table_counter_tmp).check_box                          );
        hr_utility.trace(' error_status          =       :'|| p_timekeeper_data(l_table_counter_tmp).error_status                       );
        hr_utility.trace(' timecard_status        =      :'|| p_timekeeper_data(l_table_counter_tmp).timecard_status                    );
        hr_utility.trace(' timecard_status_code =        :'|| p_timekeeper_data(l_table_counter_tmp).timecard_status_code               );
        hr_utility.trace(' attr_value_1          =       :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_1                       );
        hr_utility.trace(' attr_value_2           =      :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_2                       );
        hr_utility.trace(' attr_value_3            =     :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_3                       );
        hr_utility.trace(' attr_value_4  =               :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_4                       );
        hr_utility.trace(' attr_value_5   =              :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_5                       );
        hr_utility.trace(' attr_value_6    =             :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_6                       );
        hr_utility.trace(' attr_value_7     =            :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_7                       );
        hr_utility.trace(' attr_value_8      =           :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_8                       );
        hr_utility.trace(' attr_value_9       =          :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_9                       );
        hr_utility.trace(' attr_value_10       =         :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_10                      );
        hr_utility.trace(' attr_value_11        =        :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_11                      );
        hr_utility.trace(' attr_value_12         =       :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_12                      );
        hr_utility.trace(' attr_value_13          =      :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_13                      );
        hr_utility.trace(' attr_value_14           =     :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_14                      );
        hr_utility.trace(' attr_value_15  =              :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_15                      );
        hr_utility.trace(' attr_value_16   =             :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_16                      );
        hr_utility.trace(' attr_value_17    =            :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_17                      );
        hr_utility.trace(' attr_value_18     =           :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_18                      );
        hr_utility.trace(' attr_value_19                :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_19                     );
        hr_utility.trace(' attr_value_20      =          :'|| p_timekeeper_data(l_table_counter_tmp).attr_value_20                      );
        hr_utility.trace(' attr_id_1           =         :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_1                          );
        hr_utility.trace(' attr_id_2            =        :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_2                          );
        hr_utility.trace(' attr_id_3             =       :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_3                          );
        hr_utility.trace(' attr_id_4              =      :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_4                          );
        hr_utility.trace(' attr_id_5               =     :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_5                          );
        hr_utility.trace(' attr_id_6    =                :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_6                          );
        hr_utility.trace(' attr_id_7     =               :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_7                          );
        hr_utility.trace(' attr_id_8      =              :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_8                          );
        hr_utility.trace(' attr_id_9       =             :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_9                          );
        hr_utility.trace(' attr_id_10       =            :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_10                         );
        hr_utility.trace(' attr_id_11        =           :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_11                         );
        hr_utility.trace(' attr_id_12         =          :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_12                         );
        hr_utility.trace(' attr_id_13          =         :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_13                         );
        hr_utility.trace(' attr_id_14           =        :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_14                         );
        hr_utility.trace(' attr_id_15           =        :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_15                         );
        hr_utility.trace(' attr_id_16            =       :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_16                         );
        hr_utility.trace(' attr_id_17             =      :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_17                         );
        hr_utility.trace(' attr_id_18  =                 :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_18                         );
        hr_utility.trace(' attr_id_19   =                :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_19                         );
        hr_utility.trace(' attr_id_20    =               :'|| p_timekeeper_data(l_table_counter_tmp).attr_id_20                         );
        hr_utility.trace(' attr_oldid_1   =              :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_1                       );
        hr_utility.trace(' attr_oldid_2    =             :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_2                       );
        hr_utility.trace(' attr_oldid_3     =            :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_3                       );
        hr_utility.trace(' attr_oldid_4      =           :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_4                       );
        hr_utility.trace(' attr_oldid_5       =          :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_5                       );
        hr_utility.trace(' attr_oldid_6        =         :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_6                       );
        hr_utility.trace(' attr_oldid_7         =        :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_7                       );
        hr_utility.trace(' attr_oldid_8          =       :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_8                       );
        hr_utility.trace(' attr_oldid_9           =      :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_9                       );
        hr_utility.trace(' attr_oldid_10           =     :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_10                      );
        hr_utility.trace(' attr_oldid_11            =    :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_11                      );
        hr_utility.trace(' attr_oldid_12             =   :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_12                      );
        hr_utility.trace(' attr_oldid_13  =              :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_13                      );
        hr_utility.trace(' attr_oldid_14   =             :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_14                      );
        hr_utility.trace(' attr_oldid_15    =            :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_15                      );
        hr_utility.trace(' attr_oldid_16     =           :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_16                      );
        hr_utility.trace(' attr_oldid_17      =          :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_17                      );
        hr_utility.trace(' attr_oldid_18       =         :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_18                      );
        hr_utility.trace(' attr_oldid_19        =        :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_19                      );
        hr_utility.trace(' attr_oldid_20         =       :'|| p_timekeeper_data(l_table_counter_tmp).attr_oldid_20                      );
        hr_utility.trace(' timekeeper_action      =      :'|| p_timekeeper_data(l_table_counter_tmp).timekeeper_action                  );
        hr_utility.trace(' detail_id_1             =     :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_1                        );
        hr_utility.trace(' detail_id_2              =    :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_2                        );
        hr_utility.trace(' detail_id_3               =   :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_3                        );
        hr_utility.trace(' detail_id_4                =  :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_4                        );
        hr_utility.trace(' detail_id_5   =               :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_5                        );
        hr_utility.trace(' detail_id_6    =              :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_6                        );
        hr_utility.trace(' detail_id_7     =             :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_7                        );
        hr_utility.trace(' detail_id_8      =            :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_8                        );
        hr_utility.trace(' detail_id_9       =           :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_9                        );
        hr_utility.trace(' detail_id_10       =          :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_10                       );
        hr_utility.trace(' detail_id_11        =         :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_11                       );
        hr_utility.trace(' detail_id_12         =        :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_12                       );
        hr_utility.trace(' detail_id_13          =       :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_13                       );
        hr_utility.trace(' detail_id_14           =      :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_14                       );
        hr_utility.trace(' detail_id_15            =     :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_15                       );
        hr_utility.trace(' detail_id_16             =    :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_16                       );
        hr_utility.trace(' detail_id_17              =   :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_17                       );
        hr_utility.trace(' detail_id_18               =  :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_18                       );
        hr_utility.trace(' detail_id_19  =               :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_19                       );
        hr_utility.trace(' detail_id_20   =              :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_20                       );
        hr_utility.trace(' detail_id_21    =             :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_21                       );
        hr_utility.trace(' detail_id_22     =            :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_22                       );
        hr_utility.trace(' detail_id_23      =           :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_23                       );
        hr_utility.trace(' detail_id_24       =          :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_24                       );
        hr_utility.trace(' detail_id_25       =          :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_25                       );
        hr_utility.trace(' detail_id_26        =         :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_26                       );
        hr_utility.trace(' detail_id_27         =        :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_27                       );
        hr_utility.trace(' detail_id_28          =       :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_28                       );
        hr_utility.trace(' detail_id_29           =      :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_29                       );
        hr_utility.trace(' detail_id_30            =     :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_30                       );
        hr_utility.trace(' detail_id_31             =    :'|| p_timekeeper_data(l_table_counter_tmp).detail_id_31                       );
        hr_utility.trace(' detail_ovn_1              =   :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_1                       );
        hr_utility.trace(' detail_ovn_2               =  :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_2                       );
        hr_utility.trace(' detail_ovn_3                = :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_3                       );
        hr_utility.trace(' detail_ovn_4 =                :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_4                       );
        hr_utility.trace(' detail_ovn_5  =               :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_5                       );
        hr_utility.trace(' detail_ovn_6   =              :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_6                       );
        hr_utility.trace(' detail_ovn_7    =             :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_7                       );
        hr_utility.trace(' detail_ovn_8     =            :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_8                       );
        hr_utility.trace(' detail_ovn_9      =           :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_9                       );
        hr_utility.trace(' detail_ovn_10      =          :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_10                      );
        hr_utility.trace(' detail_ovn_11       =         :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_11                      );
        hr_utility.trace(' detail_ovn_12        =        :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_12                      );
        hr_utility.trace(' detail_ovn_13         =       :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_13                      );
        hr_utility.trace(' detail_ovn_14          =      :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_14                      );
        hr_utility.trace(' detail_ovn_15           =     :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_15                      );
        hr_utility.trace(' detail_ovn_16            =    :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_16                      );
        hr_utility.trace(' detail_ovn_17             =   :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_17                      );
        hr_utility.trace(' detail_ovn_18              =  :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_18                      );
        hr_utility.trace(' detail_ovn_19               = :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_19                      );
        hr_utility.trace(' detail_ovn_20  =              :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_20                      );
        hr_utility.trace(' detail_ovn_21   =             :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_21                      );
        hr_utility.trace(' detail_ovn_22    =            :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_22                      );
        hr_utility.trace(' detail_ovn_23     =           :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_23                      );
        hr_utility.trace(' detail_ovn_24      =          :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_24                      );
        hr_utility.trace(' detail_ovn_25       =         :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_25                      );
        hr_utility.trace(' detail_ovn_26        =        :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_26                      );
        hr_utility.trace(' detail_ovn_27         =       :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_27                      );
        hr_utility.trace(' detail_ovn_28          =      :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_28                      );
        hr_utility.trace(' detail_ovn_29           =     :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_29                      );
        hr_utility.trace(' detail_ovn_30            =    :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_30                      );
        hr_utility.trace(' detail_ovn_31             =   :'|| p_timekeeper_data(l_table_counter_tmp).detail_ovn_31                      );
        hr_utility.trace(' day_1                      =  :'|| p_timekeeper_data(l_table_counter_tmp).day_1                              );
        hr_utility.trace(' day_2          =              :'|| p_timekeeper_data(l_table_counter_tmp).day_2                              );
        hr_utility.trace(' day_3           =             :'|| p_timekeeper_data(l_table_counter_tmp).day_3                              );
        hr_utility.trace(' day_4            =            :'|| p_timekeeper_data(l_table_counter_tmp).day_4                              );
        hr_utility.trace(' day_5             =           :'|| p_timekeeper_data(l_table_counter_tmp).day_5                              );
        hr_utility.trace(' day_6              =          :'|| p_timekeeper_data(l_table_counter_tmp).day_6                              );
        hr_utility.trace(' day_7               =         :'|| p_timekeeper_data(l_table_counter_tmp).day_7                              );
        hr_utility.trace(' day_8                =        :'|| p_timekeeper_data(l_table_counter_tmp).day_8                              );
        hr_utility.trace(' day_9                 =       :'|| p_timekeeper_data(l_table_counter_tmp).day_9                              );
        hr_utility.trace(' day_10                 =      :'|| p_timekeeper_data(l_table_counter_tmp).day_10                             );
        hr_utility.trace(' day_11                  =     :'|| p_timekeeper_data(l_table_counter_tmp).day_11                             );
        hr_utility.trace(' day_12                   =    :'|| p_timekeeper_data(l_table_counter_tmp).day_12                             );
        hr_utility.trace(' day_13                    =   :'|| p_timekeeper_data(l_table_counter_tmp).day_13                             );
        hr_utility.trace(' day_14                     =  :'|| p_timekeeper_data(l_table_counter_tmp).day_14                             );
        hr_utility.trace(' day_15  =                     :'|| p_timekeeper_data(l_table_counter_tmp).day_15                             );
        hr_utility.trace(' day_16   =                    :'|| p_timekeeper_data(l_table_counter_tmp).day_16                             );
        hr_utility.trace(' day_17    =                   :'|| p_timekeeper_data(l_table_counter_tmp).day_17                             );
        hr_utility.trace(' day_18     =                  :'|| p_timekeeper_data(l_table_counter_tmp).day_18                             );
        hr_utility.trace(' day_19      =                 :'|| p_timekeeper_data(l_table_counter_tmp).day_19                             );
        hr_utility.trace(' day_20       =                :'|| p_timekeeper_data(l_table_counter_tmp).day_20                             );
        hr_utility.trace(' day_21        =               :'|| p_timekeeper_data(l_table_counter_tmp).day_21                             );
        hr_utility.trace(' day_22         =              :'|| p_timekeeper_data(l_table_counter_tmp).day_22                             );
        hr_utility.trace(' day_23          =             :'|| p_timekeeper_data(l_table_counter_tmp).day_23                             );
        hr_utility.trace(' day_24           =            :'|| p_timekeeper_data(l_table_counter_tmp).day_24                             );
        hr_utility.trace(' day_25            =           :'|| p_timekeeper_data(l_table_counter_tmp).day_25                             );
        hr_utility.trace(' day_26             =          :'|| p_timekeeper_data(l_table_counter_tmp).day_26                             );
        hr_utility.trace(' day_27              =         :'|| p_timekeeper_data(l_table_counter_tmp).day_27                             );
        hr_utility.trace(' day_28               =        :'|| p_timekeeper_data(l_table_counter_tmp).day_28                             );
        hr_utility.trace(' day_29                =       :'|| p_timekeeper_data(l_table_counter_tmp).day_29                             );
        hr_utility.trace(' day_30                 =      :'|| p_timekeeper_data(l_table_counter_tmp).day_30                             );
        hr_utility.trace(' day_31                  =     :'|| p_timekeeper_data(l_table_counter_tmp).day_31                             );
        hr_utility.trace(' time_in_1                =    :'|| p_timekeeper_data(l_table_counter_tmp).time_in_1                          );
        hr_utility.trace(' time_out_1                =   :'|| p_timekeeper_data(l_table_counter_tmp).time_out_1                         );
        hr_utility.trace(' time_in_2                  =  :'|| p_timekeeper_data(l_table_counter_tmp).time_in_2                          );
        hr_utility.trace(' time_out_2 =                  :'|| p_timekeeper_data(l_table_counter_tmp).time_out_2                         );
        hr_utility.trace(' time_in_3   =                 :'|| p_timekeeper_data(l_table_counter_tmp).time_in_3                          );
        hr_utility.trace(' time_out_3   =                :'|| p_timekeeper_data(l_table_counter_tmp).time_out_3                         );
        hr_utility.trace(' time_in_4     =               :'|| p_timekeeper_data(l_table_counter_tmp).time_in_4                          );
        hr_utility.trace(' time_out_4     =              :'|| p_timekeeper_data(l_table_counter_tmp).time_out_4                         );
        hr_utility.trace(' time_in_5       =             :'|| p_timekeeper_data(l_table_counter_tmp).time_in_5                          );
        hr_utility.trace(' time_out_5       =            :'|| p_timekeeper_data(l_table_counter_tmp).time_out_5                         );
        hr_utility.trace(' time_in_6         =           :'|| p_timekeeper_data(l_table_counter_tmp).time_in_6                          );
        hr_utility.trace(' time_out_6         =          :'|| p_timekeeper_data(l_table_counter_tmp).time_out_6                         );
        hr_utility.trace(' time_in_7           =         :'|| p_timekeeper_data(l_table_counter_tmp).time_in_7                          );
        hr_utility.trace(' time_out_7           =        :'|| p_timekeeper_data(l_table_counter_tmp).time_out_7                         );
        hr_utility.trace(' time_in_8             =       :'|| p_timekeeper_data(l_table_counter_tmp).time_in_8                          );
        hr_utility.trace(' time_out_8             =      :'|| p_timekeeper_data(l_table_counter_tmp).time_out_8                         );
        hr_utility.trace(' time_in_9               =     :'|| p_timekeeper_data(l_table_counter_tmp).time_in_9                          );
        hr_utility.trace(' time_out_9               =    :'|| p_timekeeper_data(l_table_counter_tmp).time_out_9                         );
        hr_utility.trace(' time_in_10                =   :'|| p_timekeeper_data(l_table_counter_tmp).time_in_10                         );
        hr_utility.trace(' time_out_10                =  :'|| p_timekeeper_data(l_table_counter_tmp).time_out_10                        );
        hr_utility.trace(' time_in_11  =                 :'|| p_timekeeper_data(l_table_counter_tmp).time_in_11                         );
        hr_utility.trace(' time_out_11  =                :'|| p_timekeeper_data(l_table_counter_tmp).time_out_11                        );
        hr_utility.trace(' time_in_12    =               :'|| p_timekeeper_data(l_table_counter_tmp).time_in_12                         );
        hr_utility.trace(' time_out_12    =              :'|| p_timekeeper_data(l_table_counter_tmp).time_out_12                        );
        hr_utility.trace(' time_in_13      =             :'|| p_timekeeper_data(l_table_counter_tmp).time_in_13                         );
        hr_utility.trace(' time_out_13      =            :'|| p_timekeeper_data(l_table_counter_tmp).time_out_13                        );
        hr_utility.trace(' time_in_14        =           :'|| p_timekeeper_data(l_table_counter_tmp).time_in_14                         );
        hr_utility.trace(' time_out_14        =          :'|| p_timekeeper_data(l_table_counter_tmp).time_out_14                        );
        hr_utility.trace(' time_in_15          =         :'|| p_timekeeper_data(l_table_counter_tmp).time_in_15                         );
        hr_utility.trace(' time_out_15          =        :'|| p_timekeeper_data(l_table_counter_tmp).time_out_15                        );
        hr_utility.trace(' time_in_16            =       :'|| p_timekeeper_data(l_table_counter_tmp).time_in_16                         );
        hr_utility.trace(' time_out_16            =      :'|| p_timekeeper_data(l_table_counter_tmp).time_out_16                        );
        hr_utility.trace(' time_in_17              =     :'|| p_timekeeper_data(l_table_counter_tmp).time_in_17                         );
        hr_utility.trace(' time_out_17              =    :'|| p_timekeeper_data(l_table_counter_tmp).time_out_17                        );
        hr_utility.trace(' time_in_18                =   :'|| p_timekeeper_data(l_table_counter_tmp).time_in_18                         );
        hr_utility.trace(' time_out_18                =  :'|| p_timekeeper_data(l_table_counter_tmp).time_out_18                        );
        hr_utility.trace(' time_in_19   =                :'|| p_timekeeper_data(l_table_counter_tmp).time_in_19                         );
        hr_utility.trace(' time_out_19   =               :'|| p_timekeeper_data(l_table_counter_tmp).time_out_19                        );
        hr_utility.trace(' time_in_20     =              :'|| p_timekeeper_data(l_table_counter_tmp).time_in_20                         );
        hr_utility.trace(' time_out_20     =             :'|| p_timekeeper_data(l_table_counter_tmp).time_out_20                        );
        hr_utility.trace(' time_in_21       =            :'|| p_timekeeper_data(l_table_counter_tmp).time_in_21                         );
        hr_utility.trace(' time_out_21      =            :'|| p_timekeeper_data(l_table_counter_tmp).time_out_21                        );
        hr_utility.trace(' time_in_22        =           :'|| p_timekeeper_data(l_table_counter_tmp).time_in_22                         );
        hr_utility.trace(' time_out_22        =          :'|| p_timekeeper_data(l_table_counter_tmp).time_out_22                        );
        hr_utility.trace(' time_in_23          =         :'|| p_timekeeper_data(l_table_counter_tmp).time_in_23                         );
        hr_utility.trace(' time_out_23          =        :'|| p_timekeeper_data(l_table_counter_tmp).time_out_23                        );
        hr_utility.trace(' time_in_24            =       :'|| p_timekeeper_data(l_table_counter_tmp).time_in_24                         );
        hr_utility.trace(' time_out_24            =      :'|| p_timekeeper_data(l_table_counter_tmp).time_out_24                        );
        hr_utility.trace(' time_in_25              =     :'|| p_timekeeper_data(l_table_counter_tmp).time_in_25                         );
        hr_utility.trace(' time_out_25              =    :'|| p_timekeeper_data(l_table_counter_tmp).time_out_25                        );
        hr_utility.trace(' time_in_26                =   :'|| p_timekeeper_data(l_table_counter_tmp).time_in_26                         );
        hr_utility.trace(' time_out_26                =  :'|| p_timekeeper_data(l_table_counter_tmp).time_out_26                        );
        hr_utility.trace(' time_in_27  =                 :'|| p_timekeeper_data(l_table_counter_tmp).time_in_27                         );
        hr_utility.trace(' time_out_27  =                :'|| p_timekeeper_data(l_table_counter_tmp).time_out_27                        );
        hr_utility.trace(' time_in_28    =               :'|| p_timekeeper_data(l_table_counter_tmp).time_in_28                         );
        hr_utility.trace(' time_out_28    =              :'|| p_timekeeper_data(l_table_counter_tmp).time_out_28                        );
        hr_utility.trace(' time_in_29      =             :'|| p_timekeeper_data(l_table_counter_tmp).time_in_29                         );
        hr_utility.trace(' time_out_29      =            :'|| p_timekeeper_data(l_table_counter_tmp).time_out_29                        );
        hr_utility.trace(' time_in_30        =           :'|| p_timekeeper_data(l_table_counter_tmp).time_in_30                         );
        hr_utility.trace(' time_out_30        =          :'|| p_timekeeper_data(l_table_counter_tmp).time_out_30                        );
        hr_utility.trace(' time_in_31          =         :'|| p_timekeeper_data(l_table_counter_tmp).time_in_31                         );
        hr_utility.trace(' time_out_31          =        :'|| p_timekeeper_data(l_table_counter_tmp).time_out_31                        );
        hr_utility.trace(' comment_text          =       :'|| p_timekeeper_data(l_table_counter_tmp).comment_text                       );
        hr_utility.trace(' last_update_date       =      :'|| p_timekeeper_data(l_table_counter_tmp).last_update_date                   );
        hr_utility.trace(' last_updated_by         =     :'|| p_timekeeper_data(l_table_counter_tmp).last_updated_by                    );
        hr_utility.trace(' last_update_login        =    :'|| p_timekeeper_data(l_table_counter_tmp).last_update_login                  );
        hr_utility.trace(' created_by                =   :'|| p_timekeeper_data(l_table_counter_tmp).created_by                         );
        hr_utility.trace(' creation_date              =  :'|| p_timekeeper_data(l_table_counter_tmp).creation_date                      );
        hr_utility.trace(' row_lock_id                 = :'|| p_timekeeper_data(l_table_counter_tmp).row_lock_id                        );
        hr_utility.trace(' tc_lock_success =             :'|| p_timekeeper_data(l_table_counter_tmp).tc_lock_success                    );
        hr_utility.trace(' person_type      =            :'|| p_timekeeper_data(l_table_counter_tmp).person_type                        );
        hr_utility.trace(' timecard_message  =           :'|| p_timekeeper_data(l_table_counter_tmp).timecard_message                   );
        hr_utility.trace(' timecard_message_code =       :'|| p_timekeeper_data(l_table_counter_tmp).timecard_message_code              );
        hr_utility.trace(' audit_enabled          =      :'|| p_timekeeper_data(l_table_counter_tmp).audit_enabled                      );


        hr_utility.trace('-------------------------------------------------------------');


       l_table_counter_tmp := p_timekeeper_data.NEXT (l_table_counter_tmp);

          END LOOP;
        hr_utility.trace(' SVG timekeeper TABLE end ');
        end if;
   END IF;


   */


-- set in session the timekeeper_data return with query
-- if we are not from the timekeeper_process_call
-- if we are we not need to set the global table

   IF g_from_tk_process = FALSE THEN
    g_timekeeper_data_query := p_timekeeper_data;
   END IF;
  END IF;

  IF  l_terminated_list IS NOT NULL AND p_reqryflg = 'N' THEN
   g_terminated_list := substr(l_terminated_list, 1,3000);
  ELSE
   g_terminated_list := NULL;
  END IF;
 END;


---------------------------------------------------------------------------
--Add_remove_submit
---------------------------------------------------------------------------
 PROCEDURE add_remove_submit (
  p_resource_id IN NUMBER,
  p_start_period IN DATE,
  p_end_period IN DATE,
  p_timecard_id IN NUMBER,
  p_row_lock_id IN ROWID,
  p_operation IN VARCHAR2,
  p_number_rows IN NUMBER
 ) IS
 BEGIN
  IF p_operation = 'Y' THEN
   --Add the record
   g_submit_table (p_resource_id).resource_id := p_resource_id;
   g_submit_table (p_resource_id).timecard_id := p_timecard_id;
   g_submit_table (p_resource_id).start_time := p_start_period;
   g_submit_table (p_resource_id).stop_time := p_end_period;
   g_submit_table (p_resource_id).row_lock_id := p_row_lock_id;
   g_submit_table (p_resource_id).no_rows :=
                                  NVL (g_submit_table (p_resource_id).no_rows, 0) + NVL (
                                                                                     p_number_rows,
                                                                                     0
                                                                                    );

   IF g_resource_tc_table.EXISTS (p_resource_id) THEN
    g_resource_tc_table (p_resource_id).no_rows :=
                                                 NVL (g_resource_tc_table (p_resource_id).no_rows, 0) + 1;
   ELSE
    g_resource_tc_table (p_resource_id).no_rows := 1;
   END IF;
  ELSE
   --- remove the row
   IF g_resource_tc_table.EXISTS (p_resource_id) THEN
    g_resource_tc_table (p_resource_id).no_rows :=
                                                 NVL (g_resource_tc_table (p_resource_id).no_rows, 0) - 1;
   ELSE
    g_resource_tc_table (p_resource_id).no_rows := 0;
   END IF;

   IF g_submit_table.EXISTS (p_resource_id) THEN
    g_submit_table (p_resource_id).no_rows :=
                                  NVL (g_submit_table (p_resource_id).no_rows, 0) - NVL (
                                                                                     p_number_rows,
                                                                                     0
                                                                                    );
   END IF;

   IF NVL (g_resource_tc_table (p_resource_id).no_rows, 0) <= 0 THEN
    g_submit_table.DELETE (p_resource_id);
   END IF;
  END IF;
 END;


---------------------------------------------------------------------------
--Add_remove_submit
---------------------------------------------------------------------------
 PROCEDURE add_remove_lock (
  p_resource_id IN NUMBER,
  p_start_period IN DATE,
  p_end_period IN DATE,
  p_timecard_id IN NUMBER,
  p_row_lock_id IN ROWID,
  p_operation IN VARCHAR2
 ) IS
 BEGIN
  IF p_operation = 'Y' THEN
   --Add the record
   g_lock_table (p_resource_id).resource_id := p_resource_id;
   g_lock_table (p_resource_id).timecard_id := p_timecard_id;
   g_lock_table (p_resource_id).start_time := p_start_period;
   g_lock_table (p_resource_id).stop_time := p_end_period;
   g_lock_table (p_resource_id).row_lock_id := p_row_lock_id;
  ELSE
   g_lock_table.DELETE (p_resource_id);
  END IF;
 END;


----------------------------------------------
 FUNCTION check_row_lock (
  p_resource_id IN NUMBER
 )
  RETURN BOOLEAN IS
 BEGIN
  IF g_lock_table.EXISTS (p_resource_id) THEN
   RETURN TRUE;
  ELSE
   RETURN FALSE;
  END IF;
/*ADVICE(3349): Last statement in function must be a RETURN [510] */

 END;
/*ADVICE(3352): Function with more than one RETURN statement in the executable section [512] */



----------------------------------------------
 FUNCTION get_row_lock (
  p_resource_id IN NUMBER
 )
  RETURN VARCHAR2 IS
 BEGIN
  IF g_lock_table.EXISTS (p_resource_id) THEN
   RETURN ROWIDTOCHAR (g_lock_table (p_resource_id).row_lock_id);
  ELSE
   RETURN NULL;
  END IF;
/*ADVICE(3367): Last statement in function must be a RETURN [510] */

 END;
/*ADVICE(3370): Function with more than one RETURN statement in the executable section [512] */


----------------------------------------------
FUNCTION not_empty_row
  (p_insert_data IN OUT NOCOPY t_time_info)
 RETURN BOOLEAN IS

BEGIN
g_debug :=hr_utility.debug_enabled;

if g_debug then
	 hr_utility.trace('p_insert_data.timecard_end_period '||p_insert_data.timecard_end_period );
	 hr_utility.trace('p_insert_data.resource_id     '||p_insert_data.resource_id     );
	 hr_utility.trace('p_insert_data.employee_number '||p_insert_data.employee_number );
	 hr_utility.trace('p_insert_data.employee_full_name     '||p_insert_data.employee_full_name     );
	 hr_utility.trace('p_insert_data.timecard_id     '||p_insert_data.timecard_id     );
	 hr_utility.trace('p_insert_data.timecard_ovn    '||p_insert_data.timecard_ovn    );
	 hr_utility.trace('p_insert_data.check_box '||p_insert_data.check_box );
	 hr_utility.trace('p_insert_data.error_status    '||p_insert_data.error_status    );
	 hr_utility.trace('p_insert_data.timecard_status '||p_insert_data.timecard_status );
	 hr_utility.trace('p_insert_data.timecard_status_code   '||p_insert_data.timecard_status_code   );
	 hr_utility.trace('p_insert_data.attr_value_1    '||p_insert_data.attr_value_1    );
	 hr_utility.trace('p_insert_data.attr_value_2    '||p_insert_data.attr_value_2    );
	 hr_utility.trace('p_insert_data.attr_value_3    '||p_insert_data.attr_value_3    );
	 hr_utility.trace('p_insert_data.attr_value_4    '||p_insert_data.attr_value_4    );
	 hr_utility.trace('p_insert_data.attr_value_5    '||p_insert_data.attr_value_5    );
	 hr_utility.trace('p_insert_data.attr_value_6    '||p_insert_data.attr_value_6    );
	 hr_utility.trace('p_insert_data.attr_value_7    '||p_insert_data.attr_value_7    );
	 hr_utility.trace('p_insert_data.attr_value_8    '||p_insert_data.attr_value_8    );
	 hr_utility.trace('p_insert_data.attr_value_9    '||p_insert_data.attr_value_9    );
	 hr_utility.trace('p_insert_data.attr_value_10   '||p_insert_data.attr_value_10   );
	 hr_utility.trace('p_insert_data.attr_value_11   '||p_insert_data.attr_value_11   );
	 hr_utility.trace('p_insert_data.attr_value_12   '||p_insert_data.attr_value_12   );
	 hr_utility.trace('p_insert_data.attr_value_13   '||p_insert_data.attr_value_13   );
	 hr_utility.trace('p_insert_data.attr_value_14   '||p_insert_data.attr_value_14   );
	 hr_utility.trace('p_insert_data.attr_value_15   '||p_insert_data.attr_value_15   );
	 hr_utility.trace('p_insert_data.attr_value_16   '||p_insert_data.attr_value_16   );
	 hr_utility.trace('p_insert_data.attr_value_17   '||p_insert_data.attr_value_17   );
	 hr_utility.trace('p_insert_data.attr_value_18   '||p_insert_data.attr_value_18   );
	 hr_utility.trace('p_insert_data.attr_value_19   '||p_insert_data.attr_value_19   );
	 hr_utility.trace('p_insert_data.attr_value_20   '||p_insert_data.attr_value_20   );
	 hr_utility.trace('p_insert_data.attr_id_1 '||p_insert_data.attr_id_1 );
	 hr_utility.trace('p_insert_data.attr_id_2 '||p_insert_data.attr_id_2 );
	 hr_utility.trace('p_insert_data.attr_id_3 '||p_insert_data.attr_id_3 );
	 hr_utility.trace('p_insert_data.attr_id_4 '||p_insert_data.attr_id_4 );
	 hr_utility.trace('p_insert_data.attr_id_5 '||p_insert_data.attr_id_5 );
	 hr_utility.trace('p_insert_data.attr_id_6 '||p_insert_data.attr_id_6 );
	 hr_utility.trace('p_insert_data.attr_id_7 '||p_insert_data.attr_id_7 );
	 hr_utility.trace('p_insert_data.attr_id_8 '||p_insert_data.attr_id_8 );
	 hr_utility.trace('p_insert_data.attr_id_9 '||p_insert_data.attr_id_9 );
	 hr_utility.trace('p_insert_data.attr_id_10      '||p_insert_data.attr_id_10      );
	 hr_utility.trace('p_insert_data.attr_id_11      '||p_insert_data.attr_id_11      );
	 hr_utility.trace('p_insert_data.attr_id_12      '||p_insert_data.attr_id_12      );
	 hr_utility.trace('p_insert_data.attr_id_13      '||p_insert_data.attr_id_13      );
	 hr_utility.trace('p_insert_data.attr_id_14      '||p_insert_data.attr_id_14      );
	 hr_utility.trace('p_insert_data.attr_id_15      '||p_insert_data.attr_id_15      );
	 hr_utility.trace('p_insert_data.attr_id_16      '||p_insert_data.attr_id_16      );
	 hr_utility.trace('p_insert_data.attr_id_17      '||p_insert_data.attr_id_17      );
	 hr_utility.trace('p_insert_data.attr_id_18      '||p_insert_data.attr_id_18      );
	 hr_utility.trace('p_insert_data.attr_id_19      '||p_insert_data.attr_id_19      );
	 hr_utility.trace('p_insert_data.attr_id_20      '||p_insert_data.attr_id_20      );
	 hr_utility.trace('p_insert_data.attr_oldid_1    '||p_insert_data.attr_oldid_1    );
	 hr_utility.trace('p_insert_data.attr_oldid_2    '||p_insert_data.attr_oldid_2    );
	 hr_utility.trace('p_insert_data.attr_oldid_3    '||p_insert_data.attr_oldid_3    );
	 hr_utility.trace('p_insert_data.attr_oldid_4    '||p_insert_data.attr_oldid_4    );
	 hr_utility.trace('p_insert_data.attr_oldid_5    '||p_insert_data.attr_oldid_5    );
	 hr_utility.trace('p_insert_data.attr_oldid_6    '||p_insert_data.attr_oldid_6    );
	 hr_utility.trace('p_insert_data.attr_oldid_7    '||p_insert_data.attr_oldid_7    );
	 hr_utility.trace('p_insert_data.attr_oldid_8    '||p_insert_data.attr_oldid_8    );
	 hr_utility.trace('p_insert_data.attr_oldid_9    '||p_insert_data.attr_oldid_9    );
	 hr_utility.trace('p_insert_data.attr_oldid_10   '||p_insert_data.attr_oldid_10   );
	 hr_utility.trace('p_insert_data.attr_oldid_11   '||p_insert_data.attr_oldid_11   );
	 hr_utility.trace('p_insert_data.attr_oldid_12   '||p_insert_data.attr_oldid_12   );
	 hr_utility.trace('p_insert_data.attr_oldid_13   '||p_insert_data.attr_oldid_13   );
	 hr_utility.trace('p_insert_data.attr_oldid_14   '||p_insert_data.attr_oldid_14   );
	 hr_utility.trace('p_insert_data.attr_oldid_15   '||p_insert_data.attr_oldid_15   );
	 hr_utility.trace('p_insert_data.attr_oldid_16   '||p_insert_data.attr_oldid_16   );
	 hr_utility.trace('p_insert_data.attr_oldid_17   '||p_insert_data.attr_oldid_17   );
	 hr_utility.trace('p_insert_data.attr_oldid_18   '||p_insert_data.attr_oldid_18   );
	 hr_utility.trace('p_insert_data.attr_oldid_19   '||p_insert_data.attr_oldid_19   );
	 hr_utility.trace('p_insert_data.attr_oldid_20   '||p_insert_data.attr_oldid_20   );
	 hr_utility.trace('p_insert_data.timekeeper_action      '||p_insert_data.timekeeper_action      );
	 hr_utility.trace('p_insert_data.detail_id_1     '||p_insert_data.detail_id_1     );
	 hr_utility.trace('p_insert_data.detail_id_2     '||p_insert_data.detail_id_2     );
	 hr_utility.trace('p_insert_data.detail_id_3     '||p_insert_data.detail_id_3     );
	 hr_utility.trace('p_insert_data.detail_id_4     '||p_insert_data.detail_id_4     );
	 hr_utility.trace('p_insert_data.detail_id_5     '||p_insert_data.detail_id_5     );
	 hr_utility.trace('p_insert_data.detail_id_6     '||p_insert_data.detail_id_6     );
	 hr_utility.trace('p_insert_data.detail_id_7     '||p_insert_data.detail_id_7     );
	 hr_utility.trace('p_insert_data.detail_id_8     '||p_insert_data.detail_id_8     );
	 hr_utility.trace('p_insert_data.detail_id_9     '||p_insert_data.detail_id_9     );
	 hr_utility.trace('p_insert_data.detail_id_10    '||p_insert_data.detail_id_10    );
	 hr_utility.trace('p_insert_data.detail_id_11    '||p_insert_data.detail_id_11    );
	 hr_utility.trace('p_insert_data.detail_id_12    '||p_insert_data.detail_id_12    );
	 hr_utility.trace('p_insert_data.detail_id_13    '||p_insert_data.detail_id_13    );
	 hr_utility.trace('p_insert_data.detail_id_14    '||p_insert_data.detail_id_14    );
	 hr_utility.trace('p_insert_data.detail_id_15    '||p_insert_data.detail_id_15    );
	 hr_utility.trace('p_insert_data.detail_id_16    '||p_insert_data.detail_id_16    );
	 hr_utility.trace('p_insert_data.detail_id_17    '||p_insert_data.detail_id_17    );
	 hr_utility.trace('p_insert_data.detail_id_18    '||p_insert_data.detail_id_18    );
	 hr_utility.trace('p_insert_data.detail_id_19    '||p_insert_data.detail_id_19    );
	 hr_utility.trace('p_insert_data.detail_id_20    '||p_insert_data.detail_id_20    );
	 hr_utility.trace('p_insert_data.detail_id_21    '||p_insert_data.detail_id_21    );
	 hr_utility.trace('p_insert_data.detail_id_22    '||p_insert_data.detail_id_22    );
	 hr_utility.trace('p_insert_data.detail_id_23    '||p_insert_data.detail_id_23    );
	 hr_utility.trace('p_insert_data.detail_id_24    '||p_insert_data.detail_id_24    );
	 hr_utility.trace('p_insert_data.detail_id_25    '||p_insert_data.detail_id_25    );
	 hr_utility.trace('p_insert_data.detail_id_26    '||p_insert_data.detail_id_26    );
	 hr_utility.trace('p_insert_data.detail_id_27    '||p_insert_data.detail_id_27    );
	 hr_utility.trace('p_insert_data.detail_id_28    '||p_insert_data.detail_id_28    );
	 hr_utility.trace('p_insert_data.detail_id_29    '||p_insert_data.detail_id_29    );
	 hr_utility.trace('p_insert_data.detail_id_30    '||p_insert_data.detail_id_30    );
	 hr_utility.trace('p_insert_data.detail_id_31    '||p_insert_data.detail_id_31    );
	 hr_utility.trace('p_insert_data.detail_ovn_1    '||p_insert_data.detail_ovn_1    );
	 hr_utility.trace('p_insert_data.detail_ovn_2    '||p_insert_data.detail_ovn_2    );
	 hr_utility.trace('p_insert_data.detail_ovn_3    '||p_insert_data.detail_ovn_3    );
	 hr_utility.trace('p_insert_data.detail_ovn_4    '||p_insert_data.detail_ovn_4    );
	 hr_utility.trace('p_insert_data.detail_ovn_5    '||p_insert_data.detail_ovn_5    );
	 hr_utility.trace('p_insert_data.detail_ovn_6    '||p_insert_data.detail_ovn_6    );
	 hr_utility.trace('p_insert_data.detail_ovn_7    '||p_insert_data.detail_ovn_7    );
	 hr_utility.trace('p_insert_data.detail_ovn_8    '||p_insert_data.detail_ovn_8    );
	 hr_utility.trace('p_insert_data.detail_ovn_9    '||p_insert_data.detail_ovn_9    );
	 hr_utility.trace('p_insert_data.detail_ovn_10   '||p_insert_data.detail_ovn_10   );
	 hr_utility.trace('p_insert_data.detail_ovn_11   '||p_insert_data.detail_ovn_11   );
	 hr_utility.trace('p_insert_data.detail_ovn_12   '||p_insert_data.detail_ovn_12   );
	 hr_utility.trace('p_insert_data.detail_ovn_13   '||p_insert_data.detail_ovn_13   );
	 hr_utility.trace('p_insert_data.detail_ovn_14   '||p_insert_data.detail_ovn_14   );
	 hr_utility.trace('p_insert_data.detail_ovn_15   '||p_insert_data.detail_ovn_15   );
	 hr_utility.trace('p_insert_data.detail_ovn_16   '||p_insert_data.detail_ovn_16   );
	 hr_utility.trace('p_insert_data.detail_ovn_17   '||p_insert_data.detail_ovn_17   );
	 hr_utility.trace('p_insert_data.detail_ovn_18   '||p_insert_data.detail_ovn_18   );
	 hr_utility.trace('p_insert_data.detail_ovn_19   '||p_insert_data.detail_ovn_19   );
	 hr_utility.trace('p_insert_data.detail_ovn_20   '||p_insert_data.detail_ovn_20   );
	 hr_utility.trace('p_insert_data.detail_ovn_21   '||p_insert_data.detail_ovn_21   );
	 hr_utility.trace('p_insert_data.detail_ovn_22   '||p_insert_data.detail_ovn_22   );
	 hr_utility.trace('p_insert_data.detail_ovn_23   '||p_insert_data.detail_ovn_23   );
	 hr_utility.trace('p_insert_data.detail_ovn_24   '||p_insert_data.detail_ovn_24   );
	 hr_utility.trace('p_insert_data.detail_ovn_25   '||p_insert_data.detail_ovn_25   );
	 hr_utility.trace('p_insert_data.detail_ovn_26   '||p_insert_data.detail_ovn_26   );
	 hr_utility.trace('p_insert_data.detail_ovn_27   '||p_insert_data.detail_ovn_27   );
	 hr_utility.trace('p_insert_data.detail_ovn_28   '||p_insert_data.detail_ovn_28   );
	 hr_utility.trace('p_insert_data.detail_ovn_29   '||p_insert_data.detail_ovn_29   );
	 hr_utility.trace('p_insert_data.detail_ovn_30   '||p_insert_data.detail_ovn_30   );
	 hr_utility.trace('p_insert_data.detail_ovn_31   '||p_insert_data.detail_ovn_31   );
	 hr_utility.trace('p_insert_data.day_1    '||p_insert_data.day_1    );
	 hr_utility.trace('p_insert_data.day_2    '||p_insert_data.day_2    );
	 hr_utility.trace('p_insert_data.day_3    '||p_insert_data.day_3    );
	 hr_utility.trace('p_insert_data.day_4    '||p_insert_data.day_4    );
	 hr_utility.trace('p_insert_data.day_5    '||p_insert_data.day_5    );
	 hr_utility.trace('p_insert_data.day_6    '||p_insert_data.day_6    );
	 hr_utility.trace('p_insert_data.day_7    '||p_insert_data.day_7    );
	 hr_utility.trace('p_insert_data.day_8    '||p_insert_data.day_8    );
	 hr_utility.trace('p_insert_data.day_9    '||p_insert_data.day_9    );
	 hr_utility.trace('p_insert_data.day_10   '||p_insert_data.day_10   );
	 hr_utility.trace('p_insert_data.day_11   '||p_insert_data.day_11   );
	 hr_utility.trace('p_insert_data.day_12   '||p_insert_data.day_12   );
	   hr_utility.trace('p_insert_data.day_13   '||p_insert_data.day_13   );
	   hr_utility.trace('p_insert_data.day_14   '||p_insert_data.day_14   );
	   hr_utility.trace('p_insert_data.day_15   '||p_insert_data.day_15   );
	   hr_utility.trace('p_insert_data.day_16   '||p_insert_data.day_16   );
	   hr_utility.trace('p_insert_data.day_17   '||p_insert_data.day_17   );
	   hr_utility.trace('p_insert_data.day_18   '||p_insert_data.day_18   );
	   hr_utility.trace('p_insert_data.day_19   '||p_insert_data.day_19   );
	   hr_utility.trace('p_insert_data.day_20   '||p_insert_data.day_20   );
	   hr_utility.trace('p_insert_data.day_21   '||p_insert_data.day_21   );
	   hr_utility.trace('p_insert_data.day_22   '||p_insert_data.day_22   );
	   hr_utility.trace('p_insert_data.day_23   '||p_insert_data.day_23   );
	   hr_utility.trace('p_insert_data.day_24   '||p_insert_data.day_24   );
	   hr_utility.trace('p_insert_data.day_25   '||p_insert_data.day_25   );
	   hr_utility.trace('p_insert_data.day_26   '||p_insert_data.day_26   );
	   hr_utility.trace('p_insert_data.day_27   '||p_insert_data.day_27   );
	   hr_utility.trace('p_insert_data.day_28   '||p_insert_data.day_28   );
	   hr_utility.trace('p_insert_data.day_29   '||p_insert_data.day_29   );
	   hr_utility.trace('p_insert_data.day_30   '||p_insert_data.day_30   );
	   hr_utility.trace('p_insert_data.day_31   '||p_insert_data.day_31   );
	   hr_utility.trace('p_insert_data.time_in_1 '||p_insert_data.time_in_1 );
	   hr_utility.trace('p_insert_data.time_out_1      '||p_insert_data.time_out_1      );
	   hr_utility.trace('p_insert_data.time_in_2 '||p_insert_data.time_in_2 );
	   hr_utility.trace('p_insert_data.time_out_2      '||p_insert_data.time_out_2      );
	   hr_utility.trace('p_insert_data.time_in_3 '||p_insert_data.time_in_3 );
	   hr_utility.trace('p_insert_data.time_out_3      '||p_insert_data.time_out_3      );
	   hr_utility.trace('p_insert_data.time_in_4 '||p_insert_data.time_in_4 );
	   hr_utility.trace('p_insert_data.time_out_4      '||p_insert_data.time_out_4      );
	   hr_utility.trace('p_insert_data.time_in_5 '||p_insert_data.time_in_5 );
	   hr_utility.trace('p_insert_data.time_out_5      '||p_insert_data.time_out_5      );
	   hr_utility.trace('p_insert_data.time_in_6 '||p_insert_data.time_in_6 );
	   hr_utility.trace('p_insert_data.time_out_6      '||p_insert_data.time_out_6      );
	   hr_utility.trace('p_insert_data.time_in_7 '||p_insert_data.time_in_7 );
	   hr_utility.trace('p_insert_data.time_out_7      '||p_insert_data.time_out_7      );
	   hr_utility.trace('p_insert_data.time_in_8 '||p_insert_data.time_in_8 );
	   hr_utility.trace('p_insert_data.time_out_8      '||p_insert_data.time_out_8      );
	   hr_utility.trace('p_insert_data.time_in_9 '||p_insert_data.time_in_9 );
	   hr_utility.trace('p_insert_data.time_out_9      '||p_insert_data.time_out_9      );
	   hr_utility.trace('p_insert_data.time_in_10      '||p_insert_data.time_in_10      );
	   hr_utility.trace('p_insert_data.time_out_10     '||p_insert_data.time_out_10     );
	   hr_utility.trace('p_insert_data.time_in_11      '||p_insert_data.time_in_11      );
	   hr_utility.trace('p_insert_data.time_out_11     '||p_insert_data.time_out_11     );
	   hr_utility.trace('p_insert_data.time_in_12      '||p_insert_data.time_in_12      );
	   hr_utility.trace('p_insert_data.time_out_12     '||p_insert_data.time_out_12     );
	   hr_utility.trace('p_insert_data.time_in_13      '||p_insert_data.time_in_13      );
	   hr_utility.trace('p_insert_data.time_out_13     '||p_insert_data.time_out_13     );
	   hr_utility.trace('p_insert_data.time_in_14      '||p_insert_data.time_in_14      );
	   hr_utility.trace('p_insert_data.time_out_14     '||p_insert_data.time_out_14     );
	   hr_utility.trace('p_insert_data.time_in_15      '||p_insert_data.time_in_15      );
	   hr_utility.trace('p_insert_data.time_out_15     '||p_insert_data.time_out_15     );
	   hr_utility.trace('p_insert_data.time_in_16      '||p_insert_data.time_in_16      );
	   hr_utility.trace('p_insert_data.time_out_16     '||p_insert_data.time_out_16     );
	   hr_utility.trace('p_insert_data.time_in_17      '||p_insert_data.time_in_17      );
	   hr_utility.trace('p_insert_data.time_out_17     '||p_insert_data.time_out_17     );
	   hr_utility.trace('p_insert_data.time_in_18      '||p_insert_data.time_in_18      );
	   hr_utility.trace('p_insert_data.time_out_18     '||p_insert_data.time_out_18     );
	   hr_utility.trace('p_insert_data.time_in_19      '||p_insert_data.time_in_19      );
	   hr_utility.trace('p_insert_data.time_out_19     '||p_insert_data.time_out_19     );
	   hr_utility.trace('p_insert_data.time_in_20      '||p_insert_data.time_in_20      );
	   hr_utility.trace('p_insert_data.time_out_20     '||p_insert_data.time_out_20     );
	   hr_utility.trace('p_insert_data.time_in_21      '||p_insert_data.time_in_21      );
	   hr_utility.trace('p_insert_data.time_out_21     '||p_insert_data.time_out_21     );
	   hr_utility.trace('p_insert_data.time_in_22      '||p_insert_data.time_in_22      );
	   hr_utility.trace('p_insert_data.time_out_22     '||p_insert_data.time_out_22     );
	   hr_utility.trace('p_insert_data.time_in_23      '||p_insert_data.time_in_23      );
	   hr_utility.trace('p_insert_data.time_out_23     '||p_insert_data.time_out_23     );
	   hr_utility.trace('p_insert_data.time_in_24      '||p_insert_data.time_in_24      );
	   hr_utility.trace('p_insert_data.time_out_24     '||p_insert_data.time_out_24     );
	   hr_utility.trace('p_insert_data.time_in_25      '||p_insert_data.time_in_25      );
	   hr_utility.trace('p_insert_data.time_out_25     '||p_insert_data.time_out_25     );
	   hr_utility.trace('p_insert_data.time_in_26      '||p_insert_data.time_in_26      );
	   hr_utility.trace('p_insert_data.time_out_26     '||p_insert_data.time_out_26     );
	   hr_utility.trace('p_insert_data.time_in_27      '||p_insert_data.time_in_27      );
	   hr_utility.trace('p_insert_data.time_out_27     '||p_insert_data.time_out_27     );
	   hr_utility.trace('p_insert_data.time_in_28      '||p_insert_data.time_in_28      );
	   hr_utility.trace('p_insert_data.time_out_28     '||p_insert_data.time_out_28     );
	   hr_utility.trace('p_insert_data.time_in_29      '||p_insert_data.time_in_29      );
	   hr_utility.trace('p_insert_data.time_out_29     '||p_insert_data.time_out_29     );
	   hr_utility.trace('p_insert_data.time_in_30      '||p_insert_data.time_in_30      );
	   hr_utility.trace('p_insert_data.time_out_30     '||p_insert_data.time_out_30     );
	   hr_utility.trace('p_insert_data.time_in_31      '||p_insert_data.time_in_31      );
	   hr_utility.trace('p_insert_data.time_out_31     '||p_insert_data.time_out_31     );
	 hr_utility.trace('p_insert_data.comment_text    '||p_insert_data.comment_text    );
	   hr_utility.trace('p_insert_data.last_update_date '||p_insert_data.last_update_date );
	 hr_utility.trace('p_insert_data.last_updated_by '||p_insert_data.last_updated_by );
	 hr_utility.trace('p_insert_data.last_update_login      '||p_insert_data.last_update_login      );
	 hr_utility.trace('p_insert_data.created_by      '||p_insert_data.created_by      );
	   hr_utility.trace('p_insert_data.creation_date   '||p_insert_data.creation_date   );
	 hr_utility.trace('p_insert_data.row_lock_id     '||p_insert_data.row_lock_id     );
	 hr_utility.trace('p_insert_data.tc_lock_success '||p_insert_data.tc_lock_success );
	 hr_utility.trace('p_insert_data.person_type     '||p_insert_data.person_type     );
	 hr_utility.trace('p_insert_data.timecard_message '||p_insert_data.timecard_message );
	 hr_utility.trace('p_insert_data.timecard_message_code  '||p_insert_data.timecard_message_code  );
	 hr_utility.trace('p_insert_data.audit_enabled '||p_insert_data.audit_enabled );
 end if;


  IF    p_insert_data.timecard_start_period is not null OR
 p_insert_data.timecard_end_period is not null OR
-- p_insert_data.resource_id     IS NOT NULL OR
-- p_insert_data.employee_number IS NOT NULL OR
-- p_insert_data.employee_full_name     IS NOT NULL OR
 p_insert_data.timecard_id     IS NOT NULL OR
 p_insert_data.timecard_ovn    IS NOT NULL OR
 --p_insert_data.check_box IS NOT NULL OR
 p_insert_data.error_status    IS NOT NULL OR
 p_insert_data.timecard_status IS NOT NULL OR
 p_insert_data.timecard_status_code   IS NOT NULL OR
 p_insert_data.attr_value_1    IS NOT NULL OR
 p_insert_data.attr_value_2    IS NOT NULL OR
 p_insert_data.attr_value_3    IS NOT NULL OR
 p_insert_data.attr_value_4    IS NOT NULL OR
 p_insert_data.attr_value_5    IS NOT NULL OR
 p_insert_data.attr_value_6    IS NOT NULL OR
 p_insert_data.attr_value_7    IS NOT NULL OR
 p_insert_data.attr_value_8    IS NOT NULL OR
 p_insert_data.attr_value_9    IS NOT NULL OR
 p_insert_data.attr_value_10   IS NOT NULL OR
 p_insert_data.attr_value_11   IS NOT NULL OR
 p_insert_data.attr_value_12   IS NOT NULL OR
 p_insert_data.attr_value_13   IS NOT NULL OR
 p_insert_data.attr_value_14   IS NOT NULL OR
 p_insert_data.attr_value_15   IS NOT NULL OR
 p_insert_data.attr_value_16   IS NOT NULL OR
 p_insert_data.attr_value_17   IS NOT NULL OR
 p_insert_data.attr_value_18   IS NOT NULL OR
 p_insert_data.attr_value_19   IS NOT NULL OR
 p_insert_data.attr_value_20   IS NOT NULL OR
 p_insert_data.attr_id_1 IS NOT NULL OR
 p_insert_data.attr_id_2 IS NOT NULL OR
 p_insert_data.attr_id_3 IS NOT NULL OR
 p_insert_data.attr_id_4 IS NOT NULL OR
 p_insert_data.attr_id_5 IS NOT NULL OR
 p_insert_data.attr_id_6 IS NOT NULL OR
 p_insert_data.attr_id_7 IS NOT NULL OR
 p_insert_data.attr_id_8 IS NOT NULL OR
 p_insert_data.attr_id_9 IS NOT NULL OR
 p_insert_data.attr_id_10      IS NOT NULL OR
 p_insert_data.attr_id_11      IS NOT NULL OR
 p_insert_data.attr_id_12      IS NOT NULL OR
 p_insert_data.attr_id_13      IS NOT NULL OR
 p_insert_data.attr_id_14      IS NOT NULL OR
 p_insert_data.attr_id_15      IS NOT NULL OR
 p_insert_data.attr_id_16      IS NOT NULL OR
 p_insert_data.attr_id_17      IS NOT NULL OR
 p_insert_data.attr_id_18      IS NOT NULL OR
 p_insert_data.attr_id_19      IS NOT NULL OR
 p_insert_data.attr_id_20      IS NOT NULL OR
 p_insert_data.attr_oldid_1    IS NOT NULL OR
 p_insert_data.attr_oldid_2    IS NOT NULL OR
 p_insert_data.attr_oldid_3    IS NOT NULL OR
 p_insert_data.attr_oldid_4    IS NOT NULL OR
 p_insert_data.attr_oldid_5    IS NOT NULL OR
 p_insert_data.attr_oldid_6    IS NOT NULL OR
 p_insert_data.attr_oldid_7    IS NOT NULL OR
 p_insert_data.attr_oldid_8    IS NOT NULL OR
 p_insert_data.attr_oldid_9    IS NOT NULL OR
 p_insert_data.attr_oldid_10   IS NOT NULL OR
 p_insert_data.attr_oldid_11   IS NOT NULL OR
 p_insert_data.attr_oldid_12   IS NOT NULL OR
 p_insert_data.attr_oldid_13   IS NOT NULL OR
 p_insert_data.attr_oldid_14   IS NOT NULL OR
 p_insert_data.attr_oldid_15   IS NOT NULL OR
 p_insert_data.attr_oldid_16   IS NOT NULL OR
 p_insert_data.attr_oldid_17   IS NOT NULL OR
 p_insert_data.attr_oldid_18   IS NOT NULL OR
 p_insert_data.attr_oldid_19   IS NOT NULL OR
 p_insert_data.attr_oldid_20   IS NOT NULL OR
 p_insert_data.timekeeper_action      IS NOT NULL OR
   p_insert_data.detail_id_1     IS NOT NULL OR
   p_insert_data.detail_id_2     IS NOT NULL OR
   p_insert_data.detail_id_3     IS NOT NULL OR
   p_insert_data.detail_id_4     IS NOT NULL OR
   p_insert_data.detail_id_5     IS NOT NULL OR
   p_insert_data.detail_id_6     IS NOT NULL OR
   p_insert_data.detail_id_7     IS NOT NULL OR
   p_insert_data.detail_id_8     IS NOT NULL OR
   p_insert_data.detail_id_9     IS NOT NULL OR
   p_insert_data.detail_id_10    IS NOT NULL OR
   p_insert_data.detail_id_11    IS NOT NULL OR
   p_insert_data.detail_id_12    IS NOT NULL OR
   p_insert_data.detail_id_13    IS NOT NULL OR
   p_insert_data.detail_id_14    IS NOT NULL OR
   p_insert_data.detail_id_15    IS NOT NULL OR
   p_insert_data.detail_id_16    IS NOT NULL OR
   p_insert_data.detail_id_17    IS NOT NULL OR
   p_insert_data.detail_id_18    IS NOT NULL OR
   p_insert_data.detail_id_19    IS NOT NULL OR
   p_insert_data.detail_id_20    IS NOT NULL OR
   p_insert_data.detail_id_21    IS NOT NULL OR
   p_insert_data.detail_id_22    IS NOT NULL OR
   p_insert_data.detail_id_23    IS NOT NULL OR
   p_insert_data.detail_id_24    IS NOT NULL OR
   p_insert_data.detail_id_25    IS NOT NULL OR
   p_insert_data.detail_id_26    IS NOT NULL OR
   p_insert_data.detail_id_27    IS NOT NULL OR
   p_insert_data.detail_id_28    IS NOT NULL OR
   p_insert_data.detail_id_29    IS NOT NULL OR
   p_insert_data.detail_id_30    IS NOT NULL OR
   p_insert_data.detail_id_31    IS NOT NULL OR
   p_insert_data.detail_ovn_1    IS NOT NULL OR
   p_insert_data.detail_ovn_2    IS NOT NULL OR
   p_insert_data.detail_ovn_3    IS NOT NULL OR
   p_insert_data.detail_ovn_4    IS NOT NULL OR
   p_insert_data.detail_ovn_5    IS NOT NULL OR
   p_insert_data.detail_ovn_6    IS NOT NULL OR
   p_insert_data.detail_ovn_7    IS NOT NULL OR
   p_insert_data.detail_ovn_8    IS NOT NULL OR
   p_insert_data.detail_ovn_9    IS NOT NULL OR
   p_insert_data.detail_ovn_10   IS NOT NULL OR
   p_insert_data.detail_ovn_11   IS NOT NULL OR
   p_insert_data.detail_ovn_12   IS NOT NULL OR
   p_insert_data.detail_ovn_13   IS NOT NULL OR
   p_insert_data.detail_ovn_14   IS NOT NULL OR
   p_insert_data.detail_ovn_15   IS NOT NULL OR
   p_insert_data.detail_ovn_16   IS NOT NULL OR
   p_insert_data.detail_ovn_17   IS NOT NULL OR
   p_insert_data.detail_ovn_18   IS NOT NULL OR
   p_insert_data.detail_ovn_19   IS NOT NULL OR
   p_insert_data.detail_ovn_20   IS NOT NULL OR
   p_insert_data.detail_ovn_21   IS NOT NULL OR
   p_insert_data.detail_ovn_22   IS NOT NULL OR
   p_insert_data.detail_ovn_23   IS NOT NULL OR
   p_insert_data.detail_ovn_24   IS NOT NULL OR
   p_insert_data.detail_ovn_25   IS NOT NULL OR
   p_insert_data.detail_ovn_26   IS NOT NULL OR
   p_insert_data.detail_ovn_27   IS NOT NULL OR
   p_insert_data.detail_ovn_28   IS NOT NULL OR
   p_insert_data.detail_ovn_29   IS NOT NULL OR
   p_insert_data.detail_ovn_30   IS NOT NULL OR
   p_insert_data.detail_ovn_31   IS NOT NULL OR
   p_insert_data.day_1    IS NOT NULL OR
   p_insert_data.day_2    IS NOT NULL OR
   p_insert_data.day_3    IS NOT NULL OR
   p_insert_data.day_4    IS NOT NULL OR
   p_insert_data.day_5    IS NOT NULL OR
   p_insert_data.day_6    IS NOT NULL OR
   p_insert_data.day_7    IS NOT NULL OR
   p_insert_data.day_8    IS NOT NULL OR
   p_insert_data.day_9    IS NOT NULL OR
   p_insert_data.day_10   IS NOT NULL OR
   p_insert_data.day_11   IS NOT NULL OR
   p_insert_data.day_12   IS NOT NULL OR
   p_insert_data.day_13   IS NOT NULL OR
   p_insert_data.day_14   IS NOT NULL OR
   p_insert_data.day_15   IS NOT NULL OR
   p_insert_data.day_16   IS NOT NULL OR
   p_insert_data.day_17   IS NOT NULL OR
   p_insert_data.day_18   IS NOT NULL OR
   p_insert_data.day_19   IS NOT NULL OR
   p_insert_data.day_20   IS NOT NULL OR
   p_insert_data.day_21   IS NOT NULL OR
   p_insert_data.day_22   IS NOT NULL OR
   p_insert_data.day_23   IS NOT NULL OR
   p_insert_data.day_24   IS NOT NULL OR
   p_insert_data.day_25   IS NOT NULL OR
   p_insert_data.day_26   IS NOT NULL OR
   p_insert_data.day_27   IS NOT NULL OR
   p_insert_data.day_28   IS NOT NULL OR
   p_insert_data.day_29   IS NOT NULL OR
   p_insert_data.day_30   IS NOT NULL OR
   p_insert_data.day_31   IS NOT NULL OR
   p_insert_data.time_in_1 IS NOT NULL OR
   p_insert_data.time_out_1      IS NOT NULL OR
   p_insert_data.time_in_2 IS NOT NULL OR
   p_insert_data.time_out_2      IS NOT NULL OR
   p_insert_data.time_in_3 IS NOT NULL OR
   p_insert_data.time_out_3      IS NOT NULL OR
   p_insert_data.time_in_4 IS NOT NULL OR
   p_insert_data.time_out_4      IS NOT NULL OR
   p_insert_data.time_in_5 IS NOT NULL OR
   p_insert_data.time_out_5      IS NOT NULL OR
   p_insert_data.time_in_6 IS NOT NULL OR
   p_insert_data.time_out_6      IS NOT NULL OR
   p_insert_data.time_in_7 IS NOT NULL OR
   p_insert_data.time_out_7      IS NOT NULL OR
   p_insert_data.time_in_8 IS NOT NULL OR
   p_insert_data.time_out_8      IS NOT NULL OR
   p_insert_data.time_in_9 IS NOT NULL OR
   p_insert_data.time_out_9      IS NOT NULL OR
   p_insert_data.time_in_10      IS NOT NULL OR
   p_insert_data.time_out_10     IS NOT NULL OR
   p_insert_data.time_in_11      IS NOT NULL OR
   p_insert_data.time_out_11     IS NOT NULL OR
   p_insert_data.time_in_12      IS NOT NULL OR
   p_insert_data.time_out_12     IS NOT NULL OR
   p_insert_data.time_in_13      IS NOT NULL OR
   p_insert_data.time_out_13     IS NOT NULL OR
   p_insert_data.time_in_14      IS NOT NULL OR
   p_insert_data.time_out_14     IS NOT NULL OR
   p_insert_data.time_in_15      IS NOT NULL OR
   p_insert_data.time_out_15     IS NOT NULL OR
   p_insert_data.time_in_16      IS NOT NULL OR
   p_insert_data.time_out_16     IS NOT NULL OR
   p_insert_data.time_in_17      IS NOT NULL OR
   p_insert_data.time_out_17     IS NOT NULL OR
   p_insert_data.time_in_18      IS NOT NULL OR
   p_insert_data.time_out_18     IS NOT NULL OR
   p_insert_data.time_in_19      IS NOT NULL OR
   p_insert_data.time_out_19     IS NOT NULL OR
   p_insert_data.time_in_20      IS NOT NULL OR
   p_insert_data.time_out_20     IS NOT NULL OR
   p_insert_data.time_in_21      IS NOT NULL OR
   p_insert_data.time_out_21     IS NOT NULL OR
   p_insert_data.time_in_22      IS NOT NULL OR
   p_insert_data.time_out_22     IS NOT NULL OR
   p_insert_data.time_in_23      IS NOT NULL OR
   p_insert_data.time_out_23     IS NOT NULL OR
   p_insert_data.time_in_24      IS NOT NULL OR
   p_insert_data.time_out_24     IS NOT NULL OR
   p_insert_data.time_in_25      IS NOT NULL OR
   p_insert_data.time_out_25     IS NOT NULL OR
   p_insert_data.time_in_26      IS NOT NULL OR
   p_insert_data.time_out_26     IS NOT NULL OR
   p_insert_data.time_in_27      IS NOT NULL OR
   p_insert_data.time_out_27     IS NOT NULL OR
   p_insert_data.time_in_28      IS NOT NULL OR
   p_insert_data.time_out_28     IS NOT NULL OR
   p_insert_data.time_in_29      IS NOT NULL OR
   p_insert_data.time_out_29     IS NOT NULL OR
   p_insert_data.time_in_30      IS NOT NULL OR
   p_insert_data.time_out_30     IS NOT NULL OR
   p_insert_data.time_in_31      IS NOT NULL OR
   p_insert_data.time_out_31     IS NOT NULL OR
 p_insert_data.comment_text    IS NOT NULL OR
   p_insert_data.last_update_date IS NOT NULL OR
 p_insert_data.last_updated_by IS NOT NULL OR
 p_insert_data.last_update_login      IS NOT NULL OR
 p_insert_data.created_by      IS NOT NULL OR
   p_insert_data.creation_date   IS NOT NULL OR
 --p_insert_data.row_lock_id     IS NOT NULL OR
 p_insert_data.tc_lock_success IS NOT NULL OR
-- p_insert_data.person_type     IS NOT NULL OR
 p_insert_data.timecard_message IS NOT NULL OR
 p_insert_data.timecard_message_code  IS NOT NULL
 --p_insert_data.audit_enabled   IS NOT NULL
THEN
if g_debug then
        hr_utility.trace(' found data');
end if;


 RETURN TRUE;

ELSE
if g_debug then
	hr_utility.trace(' empty row');
end if;

 RETURN FALSE;

END IF;

END not_empty_row;


----------------------------------------------------------------------------
-- timekeeper_insert
----------------------------------------------------------------------------
 PROCEDURE timekeeper_insert (
  p_insert_data IN OUT NOCOPY t_timekeeper_table
 ) IS

 l_index	NUMBER;

 BEGIN

  l_index := p_insert_data.FIRST;

  LOOP
   EXIT WHEN (NOT p_insert_data.EXISTS (l_index));
    IF not_empty_row(p_insert_data(l_index))
    THEN
     populate_global_table (p_table_data => p_insert_data(l_index), p_action => 'INSERT');
    END IF;
    l_index := p_insert_data.NEXT (l_index);
  END LOOP;

 END timekeeper_insert;


-------------------------------------------------------------------------------
-- timekeeper_update
-------------------------------------------------------------------------------



 PROCEDURE timekeeper_update (
  p_update_data IN OUT NOCOPY t_timekeeper_table
 ) IS

 l_index	NUMBER;

 BEGIN

  l_index := p_update_data.FIRST;

  LOOP
   EXIT WHEN (NOT p_update_data.EXISTS (l_index));
     IF not_empty_row(p_update_data(l_index))
     THEN
      populate_global_table (p_table_data => p_update_data(l_index), p_action => 'UPDATE');
     END IF;
     l_index := p_update_data.NEXT (l_index);
  END LOOP;

 END timekeeper_update;


-------------------------------------------------------------------------------
-- timekeeper_delete
-------------------------------------------------------------------------------

 PROCEDURE timekeeper_delete (
  p_delete_data IN OUT NOCOPY t_timekeeper_table
 ) IS

 l_index	NUMBER;

 BEGIN

  l_index := p_delete_data.FIRST;

  LOOP
   EXIT WHEN (NOT p_delete_data.EXISTS (l_index));
    IF not_empty_row(p_delete_data(l_index))
    THEN
     populate_global_table (p_table_data => p_delete_data(l_index), p_action => 'DELETE');
    END IF;
    l_index := p_delete_data.NEXT (l_index);
  END LOOP;

 END timekeeper_delete;


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

 PROCEDURE timekeeper_lock (
  p_lock_data
/*ADVICE(3415): Unreferenced parameter [552] */
              IN t_timekeeper_table
 ) IS
 BEGIN
  NULL;
/*ADVICE(3420): Use of NULL statements [532] */

 END;


-------------------------------------------------------------------------------
-- populate_global_table
-------------------------------------------------------------------------------

 PROCEDURE populate_global_table (
  p_table_data IN t_time_info,
  p_action IN VARCHAR2
 ) IS
  l_global_index NUMBER
/*ADVICE(3434): NUMBER has no precision [315] */
                        := 0;
  l_index        NUMBER
/*ADVICE(3437): NUMBER has no precision [315] */
                       ;
 BEGIN
  l_global_index := g_timekeeper_data.LAST + 1;

  IF l_global_index IS NULL THEN
   l_global_index := 0;
  END IF;

  --l_index := p_table_data.FIRST;

  --LOOP
   --EXIT WHEN (NOT p_table_data.EXISTS (l_index));
   g_timekeeper_data (l_global_index) := p_table_data; --(l_index);
   g_timekeeper_data (l_global_index).timekeeper_action := p_action;
  -- l_global_index := l_global_index + 1;
   --l_index := p_table_data.NEXT (l_index);
--  END LOOP;
 END populate_global_table;


-------------------------------------------------------------------------------
-- populate_detail_global_table
-------------------------------------------------------------------------------

 PROCEDURE populate_detail_global_table (
  p_detail_data IN det_info,
  p_detail_action
/*ADVICE(3465): Unreferenced parameter [552] */
                  IN VARCHAR2
 ) IS
  l_detail_global_index
/*ADVICE(3469): Unreferenced variable [553] */
                        NUMBER
/*ADVICE(3471): NUMBER has no precision [315] */
                               := 0;
  l_detail_index
/*ADVICE(3474): Unreferenced variable [553] */
                        NUMBER
/*ADVICE(3476): NUMBER has no precision [315] */
                              ;
 BEGIN
  g_detail_data.DELETE;
  g_detail_data := p_detail_data;
 END populate_detail_global_table;
-------------------------------------------------------------------------------
--- deletes the g_timekeeper_date table when Audit Information is mandatory
--- and CLA information is not entered.

   PROCEDURE timekeeper_data_delete IS
  BEGIN
    g_timekeeper_data.delete;
  END;
------------------------------------------------------------------------------
--PROCEDURE  get det details
------------------------------------------------------------------------------
 FUNCTION get_det_details
  RETURN det_info
/*ADVICE(3489): Function has no parameters [514] */
                  IS
 BEGIN
  RETURN (g_detail_data);
 END;

 ------------------------------------------------------------------------------
--PROCEDURE  get terminated list
------------------------------------------------------------------------------
 FUNCTION get_terminated_list
  RETURN VARCHAR2
/*ADVICE(3500): Function has no parameters [514] */
                  IS
 BEGIN
  RETURN (g_terminated_list);
 END;


------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- timekeeper_process
-------------------------------------------------------------------------------
 PROCEDURE timekeeper_process (
  p_timekeeper_id IN NUMBER,
  p_superflag IN VARCHAR2,
  p_rec_periodid IN NUMBER,
  p_start_period IN DATE,
  p_end_period IN DATE,
  p_mode
/*ADVICE(3519): Unreferenced parameter [552] */
         IN VARCHAR2,
  p_messages OUT NOCOPY hxc_self_service_time_deposit.message_table,
  p_trx_lock_id IN NUMBER,
  p_lock_profile IN VARCHAR2,
  p_tk_audit_enabled IN VARCHAR2,
  p_tk_notify_to IN VARCHAR2,
  p_tk_notify_type IN VARCHAR2
 ) IS
  CURSOR c_timecard_info
/*ADVICE(3529): Unreferenced local procedure or function [557] */
                        (
   p_resource_id IN NUMBER,
   p_start_period
/*ADVICE(3533): This definition hides another one [556] */
                  IN DATE,
   p_end_period
/*ADVICE(3536): This definition hides another one [556] */
                IN DATE
  ) IS
   SELECT time_building_block_id, object_version_number, comment_text
   FROM   hxc_time_building_blocks
   WHERE  SCOPE = 'TIMECARD'
AND       date_to = hr_general.end_of_time
AND       resource_id = p_resource_id
AND       start_time = p_start_period
AND       stop_time = p_end_period;

  CURSOR c_detail_check
/*ADVICE(3548): Unreferenced local procedure or function [557] */
                       (
   p_timecard_id IN NUMBER,
   p_timecard_ovn IN NUMBER,
   p_resource_id IN NUMBER
  ) IS
   SELECT '1'
   FROM   hxc_time_building_blocks detail, hxc_time_building_blocks DAY
   WHERE  DAY.SCOPE = 'DAY'
AND       DAY.resource_id = p_resource_id
AND       DAY.parent_building_block_id = p_timecard_id
AND       DAY.parent_building_block_ovn = p_timecard_ovn
AND       DAY.time_building_block_id = detail.parent_building_block_id
AND       DAY.object_version_number = detail.parent_building_block_ovn
AND       detail.SCOPE = 'DETAIL'
AND       detail.resource_id = p_resource_id;

/*Cursor Modified By Mithun for CWK Terminate Bug*/
/* changes done by senthil for emp terminate enhancement*/
	  CURSOR c_emp_terminateinfo(
	   p_resource_id NUMBER
	  ) IS
	  SELECT final_process_date, date_start
	  FROM per_periods_of_service
	  WHERE person_id = p_resource_id
	  union all
	  select (final_process_date + NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0)) final_process_date, date_start
  	from per_periods_of_placement
  	where person_id = p_resource_id
	  ORDER BY date_start DESC;

--Added By Mithun for CWK Terminate Bug
	date_start	DATE;

        CURSOR c_tc_in_term_period_exists(
        p_resource_id number, p_start_date date, p_end_date date) IS
        SELECT 'Y'
        from hxc_time_building_blocks
        where resource_id=p_resource_id
        and scope='TIMECARD'
        and trunc(start_time)=trunc(p_start_date)
        and trunc(stop_time)=trunc(p_end_date)
        and (trunc(date_to) = hr_general.end_of_time or APPROVAL_STATUS='ERROR');
        /*end of senthil changes */
  l_tk_table_index            NUMBER
/*ADVICE(3566): NUMBER has no precision [315] */
                                    ;
  l_index_next                NUMBER
/*ADVICE(3569): NUMBER has no precision [315] */
                                    ;
  l_index_start               NUMBER
/*ADVICE(3572): NUMBER has no precision [315] */
                                    ;
  l_result                    VARCHAR2 (10);
  l_timecard_id               NUMBER
/*ADVICE(3576): NUMBER has no precision [315] */
                                                                            := NULL;
/*ADVICE(3578): Initialization to NULL is superfluous [417] */

  l_timecard_ovn              NUMBER
/*ADVICE(3581): NUMBER has no precision [315] */
                                                                            := NULL;
/*ADVICE(3583): Initialization to NULL is superfluous [417] */

  l_timecard_comment_text     VARCHAR2 (2000)                               := NULL;
/*ADVICE(3586): VARCHAR2 declaration with length greater than 500 characters [307] */

/*ADVICE(3588): Initialization to NULL is superfluous [417] */

  l_resource_tc_table         t_resource_tc_table;
  l_resource_id               NUMBER
/*ADVICE(3592): NUMBER has no precision [315] */
                                    ;
  l_string                    VARCHAR2 (32000);
  l_timecard                  hxc_block_table_type                          := hxc_block_table_type ();
  ord_timecard
/*ADVICE(3597): Unreferenced variable [553] */
                              hxc_block_table_type                          := hxc_block_table_type ();
  l_attributes                hxc_attribute_table_type                      := hxc_attribute_table_type (

                                                                               );
  l_messages                  hxc_message_table_type                        := hxc_message_table_type ();
  l_day_id_info_table         t_day_id_info_table;
  l_timecard_index            NUMBER
/*ADVICE(3605): NUMBER has no precision [315] */
                                    ;
  l_timekeeper_table          t_timekeeper_table;
  l_new_tk_data_from_process  t_timekeeper_table;
  l_old_tk_data_from_process  t_timekeeper_table;
  l_tk_data_index             NUMBER
/*ADVICE(3611): NUMBER has no precision [315] */
                                    ;
  l_new_tk_data_index         NUMBER
/*ADVICE(3614): NUMBER has no precision [315] */
                                    ;
  l_global_index              NUMBER
/*ADVICE(3617): NUMBER has no precision [315] */
                                                                            := 0;
  l_approval_style_id         NUMBER
/*ADVICE(3620): NUMBER has no precision [315] */
                                    ;
  l_approval_status           VARCHAR2 (80);
  l_delete                    BOOLEAN;
  l_dummy
/*ADVICE(3625): Unreferenced variable [553] */
                              VARCHAR2 (1);
  l_timecard_status           VARCHAR2 (10);
  num
/*ADVICE(3629): Unreferenced variable [553] */
                              NUMBER
/*ADVICE(3631): NUMBER has no precision [315] */
                                    ;
  e_error_failed
/*ADVICE(3634): Unreferenced variable [553] */
                              EXCEPTION;
  l_message_index
/*ADVICE(3637): Unreferenced variable [553] */
                              NUMBER
/*ADVICE(3639): NUMBER has no precision [315] */
                                    ;
  l_mid_index
/*ADVICE(3642): Unreferenced variable [553] */
                              NUMBER
/*ADVICE(3644): NUMBER has no precision [315] */
                                    ;
  l_tc_status                 VARCHAR2 (15)                                 := NULL;
/*ADVICE(3652): Initialization to NULL is superfluous [417] */

  att_seg_tab                 hxc_alias_utility.t_alias_att_info;
  spemp_tc_list               hxc_timecard_utilities.periods;
  spemp_tc_info               hxc_timekeeper_utilities.emptctab;
  sp_index                    NUMBER
/*ADVICE(3658): NUMBER has no precision [315] */
                                                                            := 0;
  l_timecard_index_info       hxc_timekeeper_process.t_timecard_index_info;
  l_attribute_index_info      hxc_timekeeper_process.t_attribute_index_info;
  l_mid_save                  VARCHAR2 (5)                                  := 'N';
  l_comment_made_null         BOOLEAN                                       := FALSE;
  l_row_locked_id             ROWID
/*ADVICE(3665): Use of ROWID [113] */
                                   ;
  l_process_lock_type
/*ADVICE(3668): Unreferenced variable [553] */
                              VARCHAR2 (80)                       := hxc_lock_util.c_pui_timekeeper_action;
  l_relased_success
/*ADVICE(3671): Unreferenced variable [553] */
                              BOOLEAN;
  l_lock_success
/*ADVICE(3674): Unreferenced variable [553] */
                              BOOLEAN;
  l_lock_trx_id
/*ADVICE(3677): Unreferenced variable [553] */
                              NUMBER (15)                                   := p_trx_lock_id;
  l_time_building_block_scope
/*ADVICE(3680): Unreferenced variable [553] */
                              VARCHAR2 (30);
  l_locker_type_id
/*ADVICE(3683): Unreferenced variable [553] */
                              NUMBER (15);
  l_no_details                NUMBER
/*ADVICE(3686): NUMBER has no precision [315] */
                                                                              := 0;
  l_changed_detail	      BOOLEAN := FALSE;
l_emp_terminate_date date;
l_tc_in_term_status varchar2(1) :='N';

/* Added for Bug 8775740

HR-OTL Absence Integration Declarations

*/
-- Change start
l_index 		NUMBER;   -- SVG change
-- Change end


 BEGIN
  g_debug :=hr_utility.debug_enabled;
  -- loop in the insert_table and manage the data

  g_mid_data.DELETE;

  /* Added for Bug 8775740

  HR-OTL Absence Integration

  This plsql table holds the values of negative detail ids which
  are of already prepopulated tbbs

  */
-- Change start
  g_tk_prepop_detail_id_tab.DELETE; -- svg added
-- Change end


  l_tk_table_index := g_timekeeper_data.FIRST;

  if g_debug then
  hr_utility.trace('SVG reached inside timekeeper_process 1');
  end if;

  LOOP
   EXIT WHEN (NOT g_timekeeper_data.EXISTS (l_tk_table_index));
   -- sort the table

   l_resource_id := g_timekeeper_data (l_tk_table_index).resource_id;

   IF l_resource_tc_table.EXISTS (l_resource_id) THEN
    l_string := l_resource_tc_table (l_resource_id).index_string;
   ELSE
    l_string := ''
/*ADVICE(3704): In Oracle 8, VARCHAR2 variables of zero length assigned to CHAR variables will blank-pad
              these rather than making them NULL [111] */
                  ;
   END IF;

   l_resource_tc_table (l_resource_id).index_string := l_string || '|' || l_tk_table_index;

   IF g_lock_table.EXISTS (l_resource_id) THEN
    l_resource_tc_table (l_resource_id).lockid := g_lock_table (l_resource_id).row_lock_id;
   END IF;

   /* Added for Bug 8775740

     HR-OTL Absence Integration

     Populating the plsql table which are supposed to hold the negative detail id
     values.
     This is done so that when g_negative_index is used to populate p_blocks,
     no usage of the same detail id is ensured.

     */
-- Change start
hxc_timekeeper_utilities.populate_prepop_detail_id_info
     (p_timekeeper_data_rec		=>  g_timekeeper_data(l_tk_table_index),
      p_tk_prepop_detail_id_tab 	=> g_tk_prepop_detail_id_tab);
-- Change end


   --  l_resource_tc_table (l_resource_id).lockid :=g_timekeeper_data(l_tk_table_index).row_lock_id;
   l_tk_table_index := g_timekeeper_data.NEXT (l_tk_table_index);
  END LOOP;


  IF g_debug then

      if g_tk_prepop_detail_id_tab.count>0 then

          FOR i in g_tk_prepop_detail_id_tab.FIRST .. g_tk_prepop_detail_id_tab.LAST
          LOOP

          if g_tk_prepop_detail_id_tab.EXISTS(i) then

          if g_debug then
          hr_utility.trace('index = '||i);
          hr_utility.trace('g_tk_prepop_detail_id_tab(i) = '||g_tk_prepop_detail_id_tab(i));
          end if;

          end if;

          END LOOP;

       end if;
  end if;




  --get the attributes information associated with timekeeper into  att_seg_tab table.

  att_seg_tab.DELETE;
  hxc_alias_utility.get_alias_att_info (p_timekeeper_id, att_seg_tab);
  -- Now we have a table that contains all the indexes of the insert_table
  -- by resource_id
  -- Let start to build the time_building_block and attributes table by
  -- resource_id and deposit it.

  l_resource_id := l_resource_tc_table.FIRST;

  LOOP
   EXIT WHEN (NOT l_resource_tc_table.EXISTS (l_resource_id));
   -- empty the timecard and attribute table

   --  get the timecards which fit between the range selected.
   hxc_timekeeper_utilities.populate_tc_tab (l_resource_id, p_start_period, p_end_period, spemp_tc_info);
   --  Remove the timecards which totally dosnt fit in the period
/* changes done by senthil for emp terminate enhancement*/
/*Changed By Mithun for CWK Terminate Bug*/
        OPEN c_emp_terminateinfo (p_resource_id => l_resource_id);
        FETCH c_emp_terminateinfo INTO l_emp_terminate_date, date_start;
       CLOSE c_emp_terminateinfo;

	if l_emp_terminate_date between p_start_period and p_end_period then
	  open c_tc_in_term_period_exists(l_resource_id,p_start_period,p_end_period);
	  FETCH c_tc_in_term_period_exists into l_tc_in_term_status;
	  close c_tc_in_term_period_exists;
	end if;
	if l_tc_in_term_status <> 'Y' then
	hxc_timekeeper_utilities.split_timecard (
	    l_resource_id,
	    p_start_period,
	    p_end_period,
	    spemp_tc_info,
	    spemp_tc_list
	   );
	else
	  spemp_tc_list (TO_NUMBER (TO_CHAR (TO_DATE (p_start_period, 'dd-mm-rrrr'), 'J'))).start_date := p_start_period;
	  spemp_tc_list (TO_NUMBER (TO_CHAR (TO_DATE (p_start_period, 'dd-mm-rrrr'), 'J'))).end_date := p_end_period;
	end if;
   if g_debug then
           hr_utility.trace('spemp_tc_list'||spemp_tc_list.count);
   end if;
   sp_index := spemp_tc_list.FIRST;

   LOOP
    EXIT WHEN NOT spemp_tc_list.EXISTS (sp_index);
/* changes done by senthil for emp terminate enhancement*/
    if ( nvl(l_emp_terminate_date,TO_DATE (spemp_tc_list (sp_index).start_date, 'DD-MM-RRRR') ) >=
        TO_DATE (spemp_tc_list (sp_index).start_date, 'DD-MM-RRRR') and
       nvl(l_emp_terminate_date,TO_DATE (spemp_tc_list (sp_index).end_date, 'DD-MM-RRRR')) >=
       TO_DATE (spemp_tc_list (sp_index).end_date, 'DD-MM-RRRR') )
      or (nvl(l_emp_terminate_date,TO_DATE (spemp_tc_list (sp_index).start_date, 'DD-MM-RRRR'))
      between TO_DATE (spemp_tc_list (sp_index).start_date, 'DD-MM-RRRR') and TO_DATE (spemp_tc_list (sp_index).end_date, 'DD-MM-RRRR')) then
    IF    (TO_DATE (p_start_period, 'DD-MM-RRRR') >
                                              TO_DATE (spemp_tc_list (sp_index).start_date, 'DD-MM-RRRR')
          )
       OR (TO_DATE (p_end_period, 'DD-MM-RRRR') <
                                                TO_DATE (spemp_tc_list (sp_index).end_date, 'DD-MM-RRRR')
          ) THEN
     if g_debug then
             hr_utility.trace('outside timecard');
     end if;
     NULL; --outside range
/*ADVICE(3761): Use of NULL statements [532] */

    ELSE
     l_timecard.DELETE;
     l_attributes.DELETE;
     if g_debug then
             hr_utility.trace('before create timecard day structure ');
     end if;
     --
          -- create the TIMECARD, DAY, DETAIL, ATTRIBUTE structure
       if g_debug then
               hr_utility.trace('Timekeeper Save process--20');
       end if;
     create_timecard_day_structure (
      p_resource_id => l_resource_id,
      p_start_period => TO_DATE (spemp_tc_list (sp_index).start_date, 'DD-MM-RRRR'),
      p_end_period => TO_DATE (spemp_tc_list (sp_index).end_date, 'DD-MM-RRRR'),
      p_tc_frdt => p_start_period,
      p_tc_todt => p_end_period,
      p_timecard => l_timecard,
      p_attributes => l_attributes,
      p_day_id_info_table => l_day_id_info_table,
      p_approval_style_id => l_approval_style_id,
      p_approval_status => l_approval_status,
      p_comment_text => l_timecard_comment_text,
      p_timecard_status => l_timecard_status,
      p_attribute_index_info => l_attribute_index_info,
      p_timecard_index_info => l_timecard_index_info,
      p_timecard_id => l_timecard_id
     ); --added p_timecard 2789497
     -- at this point we have the timecard structure set up
     -- now following the action on the detail, we need to reajust this structure
     -- before send it to the deposit.

     -- for each index found for the resource create the detail information
     if g_debug then
     hr_utility.trace('SVG after create_timecard_day_structure');
     end if;

     if g_debug then


       ------------------------------------------------------  --SVG insert
       if (l_timecard.count>0) then


      hr_utility.trace(' SVG P_BLOCK TABLE START ');
      hr_utility.trace(' *****************');

      l_index := l_timecard.FIRST;

       LOOP
         EXIT WHEN NOT l_timecard.EXISTS (l_index);


        hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =   '|| l_timecard(l_index).TIME_BUILDING_BLOCK_ID     );
        hr_utility.trace(' TYPE =   '|| l_timecard(l_index).TYPE )    ;
        hr_utility.trace(' MEASURE =   '|| l_timecard(l_index).MEASURE)    ;
        hr_utility.trace(' UNIT_OF_MEASURE     =       '|| l_timecard(l_index).UNIT_OF_MEASURE        )    ;
        hr_utility.trace(' START_TIME     =       '|| l_timecard(l_index).START_TIME        )    ;
        hr_utility.trace(' STOP_TIME      =       '|| l_timecard(l_index).STOP_TIME        )    ;
        hr_utility.trace(' PARENT_BUILDING_BLOCK_ID  =       '|| l_timecard(l_index).PARENT_BUILDING_BLOCK_ID        )    ;
        hr_utility.trace(' PARENT_IS_NEW     =       '|| l_timecard(l_index).PARENT_IS_NEW        )    ;
        hr_utility.trace(' SCOPE     =       '|| l_timecard(l_index).SCOPE        )    ;
        hr_utility.trace(' OBJECT_VERSION_NUMBER     =       '|| l_timecard(l_index).OBJECT_VERSION_NUMBER        )    ;
        hr_utility.trace(' APPROVAL_STATUS     =       '|| l_timecard(l_index).APPROVAL_STATUS        )    ;
        hr_utility.trace(' RESOURCE_ID     =       '|| l_timecard(l_index).RESOURCE_ID        )    ;
        hr_utility.trace(' RESOURCE_TYPE    =       '|| l_timecard(l_index).RESOURCE_TYPE       )    ;
        hr_utility.trace(' APPROVAL_STYLE_ID    =       '|| l_timecard(l_index).APPROVAL_STYLE_ID       )    ;
        hr_utility.trace(' DATE_FROM    =       '|| l_timecard(l_index).DATE_FROM       )    ;
        hr_utility.trace(' DATE_TO    =       '|| l_timecard(l_index).DATE_TO       )    ;
        hr_utility.trace(' COMMENT_TEXT    =       '|| l_timecard(l_index).COMMENT_TEXT       )    ;
        hr_utility.trace(' PARENT_BUILDING_BLOCK_OVN     =       '|| l_timecard(l_index).PARENT_BUILDING_BLOCK_OVN        )    ;
        hr_utility.trace(' NEW    =       '|| l_timecard(l_index).NEW       )    ;
        hr_utility.trace(' CHANGED    =       '|| l_timecard(l_index).CHANGED       )    ;
        hr_utility.trace(' PROCESS    =       '|| l_timecard(l_index).PROCESS       )    ;
        hr_utility.trace(' APPLICATION_SET_ID    =       '|| l_timecard(l_index).APPLICATION_SET_ID       )    ;
        hr_utility.trace(' TRANSLATION_DISPLAY_KEY    =       '|| l_timecard(l_index).TRANSLATION_DISPLAY_KEY       )    ;
        hr_utility.trace('------------------------------------------------------');

        l_index := l_timecard.NEXT (l_index);

        END LOOP;

          hr_utility.trace(' SVG l_timecard TABLE END ');
          hr_utility.trace(' *****************');

            end if;



        if (l_attributes.count>0) then


      hr_utility.trace(' SVG ATTRIBUTES TABLE START ');
      hr_utility.trace(' *****************');

      l_index := l_attributes.FIRST;

       LOOP
         EXIT WHEN NOT l_attributes.EXISTS (l_index);


        hr_utility.trace(' TIME_ATTRIBUTE_ID =   '|| l_attributes(l_index).TIME_ATTRIBUTE_ID);
        hr_utility.trace(' BUILDING_BLOCK_ID =   '|| l_attributes(l_index).BUILDING_BLOCK_ID )    ;
        hr_utility.trace(' ATTRIBUTE_CATEGORY =   '|| l_attributes(l_index).ATTRIBUTE_CATEGORY)    ;
        hr_utility.trace(' ATTRIBUTE1     =       '|| l_attributes(l_index).ATTRIBUTE1        )    ;
        hr_utility.trace(' ATTRIBUTE2  (p_alias_definition_id)   =       '|| l_attributes(l_index).ATTRIBUTE2        )    ;
        hr_utility.trace(' ATTRIBUTE3  (l_alias_value_id)    =       '|| l_attributes(l_index).ATTRIBUTE3        )    ;
        hr_utility.trace(' ATTRIBUTE4  (p_alias_type)   =       '|| l_attributes(l_index).ATTRIBUTE4        )    ;
        hr_utility.trace(' ATTRIBUTE5     =       '|| l_attributes(l_index).ATTRIBUTE5        )    ;
        hr_utility.trace(' ATTRIBUTE6     =       '|| l_attributes(l_index).ATTRIBUTE6        )    ;
        hr_utility.trace(' ATTRIBUTE7     =       '|| l_attributes(l_index).ATTRIBUTE7        )    ;
        hr_utility.trace(' ATTRIBUTE8     =       '|| l_attributes(l_index).ATTRIBUTE8        )    ;
        hr_utility.trace(' ATTRIBUTE9     =       '|| l_attributes(l_index).ATTRIBUTE9        )    ;
        hr_utility.trace(' ATTRIBUTE10    =       '|| l_attributes(l_index).ATTRIBUTE10       )    ;
        hr_utility.trace(' ATTRIBUTE11    =       '|| l_attributes(l_index).ATTRIBUTE11       )    ;
        hr_utility.trace(' ATTRIBUTE12    =       '|| l_attributes(l_index).ATTRIBUTE12       )    ;
        hr_utility.trace(' ATTRIBUTE13    =       '|| l_attributes(l_index).ATTRIBUTE13       )    ;
        hr_utility.trace(' ATTRIBUTE14    =       '|| l_attributes(l_index).ATTRIBUTE14       )    ;
        hr_utility.trace(' ATTRIBUTE15    =       '|| l_attributes(l_index).ATTRIBUTE15       )    ;
        hr_utility.trace(' ATTRIBUTE16    =       '|| l_attributes(l_index).ATTRIBUTE16       )    ;
        hr_utility.trace(' ATTRIBUTE17    =       '|| l_attributes(l_index).ATTRIBUTE17       )    ;
        hr_utility.trace(' ATTRIBUTE18    =       '|| l_attributes(l_index).ATTRIBUTE18       )    ;
        hr_utility.trace(' ATTRIBUTE19    =       '|| l_attributes(l_index).ATTRIBUTE19       )    ;
        hr_utility.trace(' ATTRIBUTE20    =       '|| l_attributes(l_index).ATTRIBUTE20       )    ;
        hr_utility.trace(' ATTRIBUTE21    =       '|| l_attributes(l_index).ATTRIBUTE21       )    ;
        hr_utility.trace(' ATTRIBUTE22    =       '|| l_attributes(l_index).ATTRIBUTE22       )    ;
        hr_utility.trace(' ATTRIBUTE23    =       '|| l_attributes(l_index).ATTRIBUTE23       )    ;
        hr_utility.trace(' ATTRIBUTE24    =       '|| l_attributes(l_index).ATTRIBUTE24       )    ;
        hr_utility.trace(' ATTRIBUTE25    =       '|| l_attributes(l_index).ATTRIBUTE25       )    ;
        hr_utility.trace(' ATTRIBUTE26    =       '|| l_attributes(l_index).ATTRIBUTE26       )    ;
        hr_utility.trace(' ATTRIBUTE27    =       '|| l_attributes(l_index).ATTRIBUTE27       )    ;
        hr_utility.trace(' ATTRIBUTE28    =       '|| l_attributes(l_index).ATTRIBUTE28       )    ;
        hr_utility.trace(' ATTRIBUTE29  (p_alias_ref_object)  =       '|| l_attributes(l_index).ATTRIBUTE29       )    ;
        hr_utility.trace(' ATTRIBUTE30  (p_alias_value_name)  =       '|| l_attributes(l_index).ATTRIBUTE30       )    ;
        hr_utility.trace(' BLD_BLK_INFO_TYPE_ID = '|| l_attributes(l_index).BLD_BLK_INFO_TYPE_ID  );
        hr_utility.trace(' OBJECT_VERSION_NUMBER = '|| l_attributes(l_index).OBJECT_VERSION_NUMBER );
        hr_utility.trace(' NEW             =       '|| l_attributes(l_index).NEW                   );
        hr_utility.trace(' CHANGED              =  '|| l_attributes(l_index).CHANGED               );
        hr_utility.trace(' BLD_BLK_INFO_TYPE    =  '|| l_attributes(l_index).BLD_BLK_INFO_TYPE     );
        hr_utility.trace(' PROCESS              =  '|| l_attributes(l_index).PROCESS               );
        hr_utility.trace(' BUILDING_BLOCK_OVN   =  '|| l_attributes(l_index).BUILDING_BLOCK_OVN    );
        hr_utility.trace('------------------------------------------------------');

        l_index := l_attributes.NEXT (l_index);

        END LOOP;

          hr_utility.trace(' SVG ATTRIBUTES TABLE END ');
          hr_utility.trace(' *****************');

            end if;


          ---------------------------------------------------------  --SVG insert


       end if;





     l_mid_save := 'N'; --2789497
     l_comment_made_null := FALSE; --2789497
     l_index_start := INSTR (l_resource_tc_table (l_resource_id).index_string, '|', 1, 1) + 1;

     LOOP
      l_index_next := INSTR (l_resource_tc_table (l_resource_id).index_string, '|', l_index_start, 1);

      IF (l_index_next = 0) THEN
       l_result := SUBSTR (
                    l_resource_tc_table (l_resource_id).index_string,
                    l_index_start,
                    LENGTH (l_resource_tc_table (l_resource_id).index_string) + 1 - l_index_start
                   );
      ELSE
       l_result := SUBSTR (
                    l_resource_tc_table (l_resource_id).index_string,
                    l_index_start,
                    l_index_next - l_index_start
                   );
      END IF;

           --create Timecard attributes  structure
      if g_debug then
              hr_utility.trace('Timekeeper Save process--30');
      end if;
      create_detail_structure (
       p_timekeeper_id => p_timekeeper_id,
       p_att_tab => att_seg_tab,
       p_resource_id => l_resource_id,
       p_start_period => TO_DATE (spemp_tc_list (sp_index).start_date, 'DD-MM-RRRR'),
       p_end_period => TO_DATE (spemp_tc_list (sp_index).end_date, 'DD-MM-RRRR'),
       p_tc_frdt => p_start_period,
       p_tc_todt => p_end_period,
       p_insert_detail => g_timekeeper_data (l_result),
       p_timecard => l_timecard,
       p_attributes => l_attributes,
       p_day_id_info_table => l_day_id_info_table,
       p_approval_style_id => l_approval_style_id,
       p_attribute_index_info => l_attribute_index_info,
       p_timecard_index_info => l_timecard_index_info,
       p_timecard_id => l_timecard_id,
       p_mid_save => l_mid_save,
       p_comment_made_null => l_comment_made_null,
       p_row_lock_id => l_row_locked_id,
       p_tk_audit_enabled => p_tk_audit_enabled
      );
      l_index_start := l_index_next + 1;
      l_result := NULL;
      EXIT WHEN l_index_next = 0;
     END LOOP; --l_index loop
/*ADVICE(3839): Nested LOOPs should all be labeled [406] */

     -- we are checking that the timecard has at least
     -- one detail valid

      if g_debug then

          hr_utility.trace('SVG after create_detail_structure');


          ------------------------------------------------------  --SVG insert
          if (l_timecard.count>0) then


           hr_utility.trace(' SVG P_BLOCK TABLE START ');
           hr_utility.trace(' *****************');

           l_index := l_timecard.FIRST;

            LOOP
              EXIT WHEN NOT l_timecard.EXISTS (l_index);


             hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =   '|| l_timecard(l_index).TIME_BUILDING_BLOCK_ID     );
             hr_utility.trace(' TYPE =   '|| l_timecard(l_index).TYPE )    ;
             hr_utility.trace(' MEASURE =   '|| l_timecard(l_index).MEASURE)    ;
             hr_utility.trace(' UNIT_OF_MEASURE     =       '|| l_timecard(l_index).UNIT_OF_MEASURE        )    ;
             hr_utility.trace(' START_TIME     =       '|| l_timecard(l_index).START_TIME        )    ;
             hr_utility.trace(' STOP_TIME      =       '|| l_timecard(l_index).STOP_TIME        )    ;
             hr_utility.trace(' PARENT_BUILDING_BLOCK_ID  =       '|| l_timecard(l_index).PARENT_BUILDING_BLOCK_ID        )    ;
             hr_utility.trace(' PARENT_IS_NEW     =       '|| l_timecard(l_index).PARENT_IS_NEW        )    ;
             hr_utility.trace(' SCOPE     =       '|| l_timecard(l_index).SCOPE        )    ;
             hr_utility.trace(' OBJECT_VERSION_NUMBER     =       '|| l_timecard(l_index).OBJECT_VERSION_NUMBER        )    ;
             hr_utility.trace(' APPROVAL_STATUS     =       '|| l_timecard(l_index).APPROVAL_STATUS        )    ;
             hr_utility.trace(' RESOURCE_ID     =       '|| l_timecard(l_index).RESOURCE_ID        )    ;
             hr_utility.trace(' RESOURCE_TYPE    =       '|| l_timecard(l_index).RESOURCE_TYPE       )    ;
             hr_utility.trace(' APPROVAL_STYLE_ID    =       '|| l_timecard(l_index).APPROVAL_STYLE_ID       )    ;
             hr_utility.trace(' DATE_FROM    =       '|| l_timecard(l_index).DATE_FROM       )    ;
             hr_utility.trace(' DATE_TO    =       '|| l_timecard(l_index).DATE_TO       )    ;
             hr_utility.trace(' COMMENT_TEXT    =       '|| l_timecard(l_index).COMMENT_TEXT       )    ;
             hr_utility.trace(' PARENT_BUILDING_BLOCK_OVN     =       '|| l_timecard(l_index).PARENT_BUILDING_BLOCK_OVN        )    ;
             hr_utility.trace(' NEW    =       '|| l_timecard(l_index).NEW       )    ;
             hr_utility.trace(' CHANGED    =       '|| l_timecard(l_index).CHANGED       )    ;
             hr_utility.trace(' PROCESS    =       '|| l_timecard(l_index).PROCESS       )    ;
             hr_utility.trace(' APPLICATION_SET_ID    =       '|| l_timecard(l_index).APPLICATION_SET_ID       )    ;
             hr_utility.trace(' TRANSLATION_DISPLAY_KEY    =       '|| l_timecard(l_index).TRANSLATION_DISPLAY_KEY       )    ;
             hr_utility.trace('------------------------------------------------------');

             l_index := l_timecard.NEXT (l_index);

             END LOOP;

               hr_utility.trace(' SVG l_timecard TABLE END ');
               hr_utility.trace(' *****************');

                 end if;








             if (l_attributes.count>0) then


           hr_utility.trace(' SVG ATTRIBUTES TABLE START ');
           hr_utility.trace(' *****************');

           l_index := l_attributes.FIRST;

            LOOP
              EXIT WHEN NOT l_attributes.EXISTS (l_index);


             hr_utility.trace(' TIME_ATTRIBUTE_ID =   '|| l_attributes(l_index).TIME_ATTRIBUTE_ID);
             hr_utility.trace(' BUILDING_BLOCK_ID =   '|| l_attributes(l_index).BUILDING_BLOCK_ID )    ;
             hr_utility.trace(' ATTRIBUTE_CATEGORY =   '|| l_attributes(l_index).ATTRIBUTE_CATEGORY)    ;
             hr_utility.trace(' ATTRIBUTE1     =       '|| l_attributes(l_index).ATTRIBUTE1        )    ;
             hr_utility.trace(' ATTRIBUTE2  (p_alias_definition_id)   =       '|| l_attributes(l_index).ATTRIBUTE2        )    ;
             hr_utility.trace(' ATTRIBUTE3  (l_alias_value_id)    =       '|| l_attributes(l_index).ATTRIBUTE3        )    ;
             hr_utility.trace(' ATTRIBUTE4  (p_alias_type)   =       '|| l_attributes(l_index).ATTRIBUTE4        )    ;
             hr_utility.trace(' ATTRIBUTE5     =       '|| l_attributes(l_index).ATTRIBUTE5        )    ;
             hr_utility.trace(' ATTRIBUTE6     =       '|| l_attributes(l_index).ATTRIBUTE6        )    ;
             hr_utility.trace(' ATTRIBUTE7     =       '|| l_attributes(l_index).ATTRIBUTE7        )    ;
             hr_utility.trace(' ATTRIBUTE8     =       '|| l_attributes(l_index).ATTRIBUTE8        )    ;
             hr_utility.trace(' ATTRIBUTE9     =       '|| l_attributes(l_index).ATTRIBUTE9        )    ;
             hr_utility.trace(' ATTRIBUTE10    =       '|| l_attributes(l_index).ATTRIBUTE10       )    ;
             hr_utility.trace(' ATTRIBUTE11    =       '|| l_attributes(l_index).ATTRIBUTE11       )    ;
             hr_utility.trace(' ATTRIBUTE12    =       '|| l_attributes(l_index).ATTRIBUTE12       )    ;
             hr_utility.trace(' ATTRIBUTE13    =       '|| l_attributes(l_index).ATTRIBUTE13       )    ;
             hr_utility.trace(' ATTRIBUTE14    =       '|| l_attributes(l_index).ATTRIBUTE14       )    ;
             hr_utility.trace(' ATTRIBUTE15    =       '|| l_attributes(l_index).ATTRIBUTE15       )    ;
             hr_utility.trace(' ATTRIBUTE16    =       '|| l_attributes(l_index).ATTRIBUTE16       )    ;
             hr_utility.trace(' ATTRIBUTE17    =       '|| l_attributes(l_index).ATTRIBUTE17       )    ;
             hr_utility.trace(' ATTRIBUTE18    =       '|| l_attributes(l_index).ATTRIBUTE18       )    ;
             hr_utility.trace(' ATTRIBUTE19    =       '|| l_attributes(l_index).ATTRIBUTE19       )    ;
             hr_utility.trace(' ATTRIBUTE20    =       '|| l_attributes(l_index).ATTRIBUTE20       )    ;
             hr_utility.trace(' ATTRIBUTE21    =       '|| l_attributes(l_index).ATTRIBUTE21       )    ;
             hr_utility.trace(' ATTRIBUTE22    =       '|| l_attributes(l_index).ATTRIBUTE22       )    ;
             hr_utility.trace(' ATTRIBUTE23    =       '|| l_attributes(l_index).ATTRIBUTE23       )    ;
             hr_utility.trace(' ATTRIBUTE24    =       '|| l_attributes(l_index).ATTRIBUTE24       )    ;
             hr_utility.trace(' ATTRIBUTE25    =       '|| l_attributes(l_index).ATTRIBUTE25       )    ;
             hr_utility.trace(' ATTRIBUTE26    =       '|| l_attributes(l_index).ATTRIBUTE26       )    ;
             hr_utility.trace(' ATTRIBUTE27    =       '|| l_attributes(l_index).ATTRIBUTE27       )    ;
             hr_utility.trace(' ATTRIBUTE28    =       '|| l_attributes(l_index).ATTRIBUTE28       )    ;
             hr_utility.trace(' ATTRIBUTE29  (p_alias_ref_object)  =       '|| l_attributes(l_index).ATTRIBUTE29       )    ;
             hr_utility.trace(' ATTRIBUTE30  (p_alias_value_name)  =       '|| l_attributes(l_index).ATTRIBUTE30       )    ;
             hr_utility.trace(' BLD_BLK_INFO_TYPE_ID = '|| l_attributes(l_index).BLD_BLK_INFO_TYPE_ID  );
             hr_utility.trace(' OBJECT_VERSION_NUMBER = '|| l_attributes(l_index).OBJECT_VERSION_NUMBER );
             hr_utility.trace(' NEW             =       '|| l_attributes(l_index).NEW                   );
             hr_utility.trace(' CHANGED              =  '|| l_attributes(l_index).CHANGED               );
             hr_utility.trace(' BLD_BLK_INFO_TYPE    =  '|| l_attributes(l_index).BLD_BLK_INFO_TYPE     );
             hr_utility.trace(' PROCESS              =  '|| l_attributes(l_index).PROCESS               );
             hr_utility.trace(' BUILDING_BLOCK_OVN   =  '|| l_attributes(l_index).BUILDING_BLOCK_OVN    );
             hr_utility.trace('------------------------------------------------------');

             l_index := l_attributes.NEXT (l_index);

             END LOOP;

               hr_utility.trace(' SVG ATTRIBUTES TABLE END ');
               hr_utility.trace(' *****************');

                 end if;

        end if; -- g_debug
          ---------------------------------------------------------     --SVG insert






     l_delete := TRUE;
     l_timecard_index := l_timecard.FIRST;

     LOOP
      EXIT WHEN (NOT l_timecard.EXISTS (l_timecard_index));
      IF l_timecard (l_timecard_index).SCOPE = 'DETAIL' THEN
       IF fnd_date.canonical_to_date (l_timecard (l_timecard_index).date_to) = hr_general.end_of_time THEN
        l_delete := FALSE;
        EXIT;
       END IF;
      END IF;

      IF l_timecard (l_timecard_index).SCOPE = 'TIMECARD' THEN
       IF      fnd_date.canonical_to_date (l_timecard (l_timecard_index).date_to) =
                                                                                  hr_general.end_of_time
           AND l_timecard (l_timecard_index).comment_text IS NOT NULL
           AND l_timecard (l_timecard_index).NEW = 'Y' THEN
        l_delete := FALSE;
        EXIT;
       END IF;
      END IF;

      IF l_timecard (l_timecard_index).SCOPE = 'TIMECARD' THEN
       l_timecard_id := l_timecard (l_timecard_index).time_building_block_id;
      END IF;

      -- next item
      l_timecard_index := l_timecard.NEXT (l_timecard_index);
     END LOOP;
/*ADVICE(3875): Presence of more than one exit point from a loop [503] */

/*ADVICE(3877): Nested LOOPs should all be labeled [406] */


     -- save the timecard

     IF (l_delete) THEN
      l_messages.DELETE;

      IF  l_timecard_id IS NOT NULL AND l_timecard_id < 0 THEN
       l_timecard.DELETE;
       l_attributes.DELETE;
      ELSE
       --delete the timecard as no detail is active
       hxc_timekeeper.delete_timecard (p_timecard_id => l_timecard_id, p_messages => l_messages);
      END IF;
     ELSE
      l_timecard_id := NULL;
      l_tc_status := NULL;
      l_messages.DELETE;
      if g_debug then
	      hr_utility.trace('Timekeeper Save process--40');
	      hr_utility.trace('l_timecard.count'||l_timecard.count);
	      hr_utility.trace('l_attributes.count'||l_attributes.count);
	      hr_utility.trace('l_messages.count'||l_messages.count);
      end if;
      IF l_mid_save = 'Y' THEN --2789497
       if g_debug then
               hr_utility.TRACE ('start');
       end if;
--                     my_debug.print_timecard('100', l_timecard);
  --                   my_debug.print_attributes('200', l_attributes);
--

       /* Added for Bug 8775740
        HR OTL Absence Integration

        Setting the Global vars so as to have the right values.

       */

       -- Change start
       HXC_RETRIEVE_ABSENCES.g_lock_row_id:= ROWIDTOCHAR(l_row_locked_id);
       HXC_RETRIEVE_ABSENCES.g_person_id:=l_resource_id;
       HXC_RETRIEVE_ABSENCES.g_start_time:=TO_DATE (spemp_tc_list (sp_index).start_date, 'DD-MM-RRRR');
       HXC_RETRIEVE_ABSENCES.g_stop_time:=TO_DATE (spemp_tc_list (sp_index).end_date, 'DD-MM-RRRR');

       HXC_RETRIEVE_ABSENCES.g_detail_trans_tab.DELETE;
       -- Change end

       if g_debug then
       hr_utility.trace('Global vars initialized in hxctksta - save timecard for hxc_retrieve_absences');
       hr_utility.trace('-----------------------------');
       hr_utility.trace('HXC_RETRIEVE_ABSENCES.g_lock_row_id = '||HXC_RETRIEVE_ABSENCES.g_lock_row_id);
       hr_utility.trace('HXC_RETRIEVE_ABSENCES.g_person_id = '||HXC_RETRIEVE_ABSENCES.g_person_id);
       hr_utility.trace('HXC_RETRIEVE_ABSENCES.g_start_time = '||HXC_RETRIEVE_ABSENCES.g_start_time);
       hr_utility.trace('HXC_RETRIEVE_ABSENCES.g_stop_time = '||HXC_RETRIEVE_ABSENCES.g_stop_time);
       end if;


       hxc_timekeeper.save_timecard (
        p_blocks => l_timecard,
        p_attributes => l_attributes,
        p_messages => l_messages,
        p_timecard_id => l_timecard_id,
        p_timecard_ovn => l_timecard_ovn,
        p_timekeeper_id => p_timekeeper_id,
        p_tk_audit_enabled => p_tk_audit_enabled,
        p_tk_notify_to => p_tk_notify_to,
        p_tk_notify_type => p_tk_notify_type
       );
      END IF;
     END IF;
    END IF;
  end if;
/* end of changes made by senthil */
    sp_index := spemp_tc_list.NEXT (sp_index);
   END LOOP;
/*ADVICE(3925): Nested LOOPs should all be labeled [406] */


   -- next timecard
   l_resource_id := l_resource_tc_table.NEXT (l_resource_id);
  END LOOP;

  -- reset global table
  if g_debug then
          hr_utility.trace('Timekeeper Save process--50');
  end if;
  g_timekeeper_data.DELETE;
  g_negative_index := -2;

-- now we need to go through the global query table and up-to-date the information
-- first set the global parameter to tell the query procedure to not update the
-- global query table.
-- get the g_timekeeper_data_query first.

-- IF it is not a submit

---start the rqquery process

-- IF p_mode <> 'SUBMIT' THEN


  l_new_tk_data_from_process.DELETE;
  l_old_tk_data_from_process := g_timekeeper_data_query;
  g_from_tk_process := TRUE;
  -- repopulate the global table that we want to send back via the query

  l_resource_id := l_resource_tc_table.FIRST;

  LOOP
   EXIT WHEN (NOT l_resource_tc_table.EXISTS (l_resource_id));
   -- call the process query to requery only the person has
    -- his timecard changed

   l_timekeeper_table.DELETE;
   timekeeper_query (
    p_timekeeper_data => l_timekeeper_table,
    p_timekeeper_id => p_timekeeper_id,
    p_start_period => p_start_period,
    p_end_period => p_end_period,
    p_group_id => NULL,
    p_resource_id => l_resource_id,
    p_attribute1 => NULL,
    p_attribute2 => NULL,
    p_attribute3 => NULL,
    p_attribute4 => NULL,
    p_attribute5 => NULL,
    p_attribute6 => NULL,
    p_attribute7 => NULL,
    p_attribute8 => NULL,
    p_attribute9 => NULL,
    p_attribute10 => NULL,
    p_attribute11 => NULL,
    p_attribute12 => NULL,
    p_attribute13 => NULL,
    p_attribute14 => NULL,
    p_attribute15 => NULL,
    p_attribute16 => NULL,
    p_attribute17 => NULL,
    p_attribute18 => NULL,
    p_attribute19 => NULL,
    p_attribute20 => NULL,
    p_status_code => NULL,
    p_rec_periodid => p_rec_periodid,
    p_superflag => p_superflag,
    p_reqryflg => 'Y',
    p_trx_lock_id => p_trx_lock_id,
    p_row_lock_id => g_lock_table (l_resource_id).row_lock_id,
    p_person_type => NULL,
    p_message_type => NULL,
    p_query_type => NULL,
    p_lock_profile => p_lock_profile,
    p_message_text => NULL,
    p_late_reason => NULL,
    p_change_reason => NULL,
    p_audit_enabled => NULL,
    p_audit_history => NULL
   );

   -- now we have the new timecard saved in the DB
   -- we need to go through the global table to replace
   -- the old timecard for this person.

   -- first we are populating all the timecard information
   -- that have changed.


   IF l_new_tk_data_from_process.COUNT > 0 THEN
    l_new_tk_data_index := l_new_tk_data_from_process.LAST + 1;
   ELSE
    l_new_tk_data_index := 1;
   END IF;

   l_tk_data_index := l_timekeeper_table.FIRST;
   g_resource_tc_table (l_resource_id).no_rows := 0;

   LOOP
    EXIT WHEN (NOT l_timekeeper_table.EXISTS (l_tk_data_index));
    l_new_tk_data_from_process (l_new_tk_data_index) := l_timekeeper_table (l_tk_data_index);
    l_new_tk_data_index := l_new_tk_data_index + 1;
    g_resource_tc_table (l_resource_id).no_rows :=
                                                 NVL (g_resource_tc_table (l_resource_id).no_rows, 0) + 1;
    l_tk_data_index := l_timekeeper_table.NEXT (l_tk_data_index);
   END LOOP;
/*ADVICE(4031): Nested LOOPs should all be labeled [406] */


   -- next timecard
   l_resource_id := l_resource_tc_table.NEXT (l_resource_id);
  END LOOP;

  -- with the new information and the old information we are going
  -- to make the up-to-date information in global table
  -- handle the case that the query did not return a row

  IF l_old_tk_data_from_process.COUNT = 0 THEN
   g_tk_data_query_from_process := l_new_tk_data_from_process;
  ELSE
   -- loop into the old table to made the new table
   l_tk_data_index := l_old_tk_data_from_process.FIRST;

   LOOP
    EXIT WHEN (NOT l_old_tk_data_from_process.EXISTS (l_tk_data_index));
    l_resource_id := l_old_tk_data_from_process (l_tk_data_index).resource_id;

    IF l_resource_tc_table.EXISTS (l_resource_id) THEN
     -- that means that we need to populate the new table with
     -- the new information contains in the new table

     l_new_tk_data_index := l_new_tk_data_from_process.FIRST;

     LOOP
      EXIT WHEN (NOT l_new_tk_data_from_process.EXISTS (l_new_tk_data_index));

      IF l_new_tk_data_from_process (l_new_tk_data_index).resource_id = l_resource_id THEN
       l_no_details := 0;
       l_global_index := l_global_index + 1;
       g_tk_data_query_from_process (l_global_index) := l_new_tk_data_from_process (l_new_tk_data_index);
       g_tk_data_query_from_process (l_global_index).check_box := 'Y';
       g_submit_table (l_resource_id).resource_id := l_resource_id;
       g_submit_table (l_resource_id).timecard_id :=
                                            l_new_tk_data_from_process (l_new_tk_data_index).timecard_id;
       g_submit_table (l_resource_id).start_time :=
                                  l_new_tk_data_from_process (l_new_tk_data_index).timecard_start_period;
       g_submit_table (l_resource_id).stop_time :=
                                    l_new_tk_data_from_process (l_new_tk_data_index).timecard_end_period;
       g_submit_table (l_resource_id).row_lock_id :=
                                            l_new_tk_data_from_process (l_new_tk_data_index).row_lock_id;
       -- delete this information since we don't need it anymore

       l_new_tk_data_from_process.DELETE (l_new_tk_data_index);
      END IF;

      -- increment the index
      l_new_tk_data_index := l_new_tk_data_from_process.NEXT (l_new_tk_data_index);
     END LOOP;
/*ADVICE(4083): Nested LOOPs should all be labeled [406] */

    ELSE
     -- populate the information with the old data

     l_global_index := l_global_index + 1;
     g_tk_data_query_from_process (l_global_index) := l_old_tk_data_from_process (l_tk_data_index);
     g_tk_data_query_from_process (l_global_index).check_box := 'N';
     g_resource_tc_table (l_resource_id).no_rows := 0;
     g_submit_table.DELETE (l_resource_id);
    END IF;

    -- increment the index

    l_tk_data_index := l_old_tk_data_from_process.NEXT (l_tk_data_index);
   END LOOP;

   -- now we need to handle the extra new information and stick them
   -- at the bottom of the pl/sql table
   -- not a pretty solution -- need to look if we can find better.

   l_new_tk_data_index := l_new_tk_data_from_process.FIRST;

   LOOP
    EXIT WHEN (NOT l_new_tk_data_from_process.EXISTS (l_new_tk_data_index));
    l_global_index := l_global_index + 1;
    g_tk_data_query_from_process (l_global_index) := l_new_tk_data_from_process (l_new_tk_data_index);
    -- increment the index
    l_new_tk_data_index := l_new_tk_data_from_process.NEXT (l_new_tk_data_index);
   END LOOP;
  END IF;

  g_tk_finish_process := TRUE;
  --END IF;

  hxc_timekeeper_utilities.convert_type_to_message_table (l_messages, p_messages);
  /* bug fix for 5229954 */
  hxc_timekeeper_utilities.populate_detail_temp(1);
  /* end of fix for 5229954 */
  COMMIT;
 END;


-------------------------------------------------------------------------------
-- call_submit
-------------------------------------------------------------------------------
 PROCEDURE call_submit (
  p_timekeeper_id IN NUMBER,
  p_start_period IN DATE,
  p_end_period IN DATE,
  p_submission_id IN NUMBER,
  p_request_id OUT NOCOPY NUMBER
 ) IS
  l_erro
/*ADVICE(4134): Unreferenced variable [553] */
             VARCHAR2 (80);
  l_err_code
/*ADVICE(4137): Unreferenced variable [553] */
             NUMBER
/*ADVICE(4139): NUMBER has no precision [315] */
                   ;
 BEGIN
  p_request_id := fnd_request.submit_request (
                   application => 'HXC',
                   program => 'HXCTKSUB',
                   description => NULL,
                   argument1 => p_timekeeper_id,
                   argument2 => fnd_date.date_to_canonical (p_start_period),
                   argument3 => fnd_date.date_to_canonical (p_end_period),
                   argument4 => p_submission_id
                  );
  COMMIT;
 END;


------------------------------------------------------------------------------
-- submit resources
------------------------------------------------------------------------------
 PROCEDURE submit_resource (
  p_timekeeper_id
/*ADVICE(4160): Unreferenced parameter [552] */
                  IN NUMBER,
  p_start_time IN DATE,
  p_stop_time IN DATE,
  p_trx_id IN NUMBER,
  p_submit_id OUT NOCOPY NUMBER,
  p_insert OUT NOCOPY BOOLEAN,
  p_submit_emp OUT NOCOPY hxc_timekeeper_process.tk_submit_tab,
  p_messages IN OUT NOCOPY hxc_self_service_time_deposit.message_table
 ) IS
  CURSOR crs_max_submit IS
   SELECT MAX (submission_id)
   FROM   hxc_tk_timekeeper_submits;

  l_max_submission_id NUMBER
/*ADVICE(4175): NUMBER has no precision [315] */
                            ;
  l_next_val          NUMBER
/*ADVICE(4178): NUMBER has no precision [315] */
                            ;
  l_index             NUMBER
/*ADVICE(4181): NUMBER has no precision [315] */
                            ;
  l_success           BOOLEAN;
  l_row_id            ROWID
/*ADVICE(4185): Use of ROWID [113] */
                           ;
  l_tc_lock_boolean   BOOLEAN;
 BEGIN
  OPEN crs_max_submit;
  FETCH crs_max_submit INTO l_max_submission_id;
  CLOSE crs_max_submit;

  IF l_max_submission_id IS NULL THEN
   l_max_submission_id := 1;
  END IF;

  SELECT hxc_tk_timekeeper_submits_s.NEXTVAL
  INTO   l_next_val
  FROM   DUAL;

  IF l_max_submission_id < l_next_val THEN
   l_max_submission_id := l_next_val;
  ELSE
   l_max_submission_id := l_max_submission_id + 1;
  END IF;

  p_insert := FALSE;
  l_index := g_submit_table.FIRST;

  LOOP
   EXIT WHEN NOT g_submit_table.EXISTS (l_index);
   hxc_tks_ins.ins (
    p_resource_id => g_submit_table (l_index).resource_id,
    p_submission_id => l_max_submission_id
   );
   p_insert := TRUE;
   hxc_lock_api.release_lock (
    p_row_lock_id => g_submit_table (l_index).row_lock_id,
    p_process_locker_type => 'PUI_TIMEKEEPER_ACTION',
    p_transaction_lock_id => p_trx_id,
    p_released_success => l_success
   );
   hxc_timekeeper_process.add_remove_lock (
    p_resource_id => g_submit_table (l_index).resource_id,
    p_start_period => p_start_time,
    p_end_period => p_stop_time + g_one_day,
    p_timecard_id => NULL,
    p_row_lock_id => g_submit_table (l_index).row_lock_id,
    p_operation => 'N'
   );
   hxc_lock_api.request_lock (
    p_process_locker_type => 'PUI_TIMEKEEPER_ACTION',
    p_resource_id => g_submit_table (l_index).resource_id,
    p_start_time => p_start_time,
    p_stop_time => p_stop_time + g_one_day,
    p_time_building_block_id => NULL,
    p_time_building_block_ovn => NULL,
    p_transaction_lock_id => l_max_submission_id,
    p_expiration_time => 60,
    p_messages => p_messages,
    p_row_lock_id => l_row_id,
    p_locked_success => l_tc_lock_boolean
   );
   hxc_timekeeper_process.add_remove_lock (
    p_resource_id => g_submit_table (l_index).resource_id,
    p_start_period => p_start_time,
    p_end_period => p_stop_time + g_one_day,
    p_timecard_id => NULL,
    p_row_lock_id => l_row_id,
    p_operation => 'Y'
   );
   l_index := g_submit_table.NEXT (l_index);
  END LOOP;

  p_submit_emp := g_submit_table;
  p_submit_id := l_max_submission_id;
  g_submit_table.DELETE;
 END submit_resource;


-------------------------------------------------------------------------------
-- run_submit
-------------------------------------------------------------------------------
 PROCEDURE run_submit (
  p_errmsg
/*ADVICE(4266): Unreferenced parameter [552] */
           OUT NOCOPY VARCHAR2,
  p_errcode
/*ADVICE(4269): Unreferenced parameter [552] */
            OUT NOCOPY NUMBER,
  p_timekeeper_id IN NUMBER,
  p_start_period IN VARCHAR2,
  p_end_period IN VARCHAR2,
  p_submission_id IN NUMBER
 ) IS
  CURSOR crs_resource_id (
   p_submit_id IN NUMBER
  ) IS
   SELECT DISTINCT (resource_id) resource_id
   FROM            hxc_tk_timekeeper_submits
   WHERE           submission_id = p_submit_id;

  CURSOR crs_employee_info (
   p_resource_id IN NUMBER,
   p_from_period IN DATE,
   p_to_period IN DATE
  ) IS
SELECT DISTINCT NVL (ppf.employee_number, ppf.npw_number) employee_number,
                     ppf.full_name,
                     ppf.effective_end_date
FROM    per_people_f ppf
WHERE   ppf.person_id = p_resource_id
AND     p_from_period < ppf.effective_end_date
AND     p_to_period > ppf.effective_start_date
AND EXISTS ( select 'x'
             from   per_all_assignments_f paa
             WHERE  ppf.person_id = paa.person_id
             AND    paa.primary_flag = 'Y'
             AND    paa.assignment_type IN ('E', 'C')
             AND    p_from_period < paa.effective_end_date
             AND    p_to_period   > paa.effective_start_date )
ORDER BY        ppf.effective_end_date DESC;

/*Cursor Modified By Mithun for CWK Terminate Bug*/
/* changes done by senthil for emp terminate enhancement*/
	  CURSOR c_emp_terminateinfo(
	   p_resource_id NUMBER
	  ) IS
	  SELECT final_process_date, date_start
	  FROM per_periods_of_service
	  WHERE person_id = p_resource_id
	  union all
	  select (final_process_date + NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0)) final_process_date, date_start
	  from per_periods_of_placement
 	  where person_id = p_resource_id
	  ORDER BY date_start DESC;

--Added By Mithun for CWK Terminate Bug
	  date_start	DATE;

        CURSOR c_tc_in_term_period_exists(
        p_resource_id number, p_start_date date, p_end_date date) IS
        SELECT 'Y'
        from hxc_time_building_blocks
        where resource_id=p_resource_id
        and scope='TIMECARD'
        and trunc(start_time)=trunc(p_start_date)
        and trunc(stop_time)=trunc(p_end_date)
        and (trunc(date_to) = hr_general.end_of_time or APPROVAL_STATUS='ERROR');
        /*end of senthil changes */

  l_timecard              hxc_block_table_type                          := hxc_block_table_type ();
  ord_timecard
/*ADVICE(4303): Unreferenced variable [553] */
                          hxc_block_table_type                          := hxc_block_table_type ();
  l_attributes            hxc_attribute_table_type                      := hxc_attribute_table_type ();
  p_messages              hxc_message_table_type                        := hxc_message_table_type ();
  l_day_id_info_table     t_day_id_info_table;
  n
/*ADVICE(4309): Unreferenced variable [553] */
                          NUMBER
/*ADVICE(4311): NUMBER has no precision [315] */
                                                                        := 0;
  l_timecard_id           NUMBER
/*ADVICE(4314): NUMBER has no precision [315] */
                                                                        := NULL;
/*ADVICE(4316): Initialization to NULL is superfluous [417] */

  l_timecard_ovn          NUMBER
/*ADVICE(4319): NUMBER has no precision [315] */
                                                                        := NULL;
/*ADVICE(4321): Initialization to NULL is superfluous [417] */

  l_approval_style_id     NUMBER
/*ADVICE(4324): NUMBER has no precision [315] */
                                                                        := NULL;
/*ADVICE(4326): Initialization to NULL is superfluous [417] */

  l_approval_status       VARCHAR2 (80)                                 := NULL;
/*ADVICE(4329): Initialization to NULL is superfluous [417] */

  l_index_next
/*ADVICE(4332): Unreferenced variable [553] */
                          NUMBER
/*ADVICE(4334): NUMBER has no precision [315] */
                                ;
  l_index_start
/*ADVICE(4337): Unreferenced variable [553] */
                          NUMBER
/*ADVICE(4339): NUMBER has no precision [315] */
                                ;
  l_result
/*ADVICE(4342): Unreferenced variable [553] */
                          VARCHAR2 (10);
  l_timecard_status       VARCHAR2 (10);
  l_resource_id
/*ADVICE(4346): Unreferenced variable [553] */
                          NUMBER
/*ADVICE(4348): NUMBER has no precision [315] */
                                ;
  l_timecard_comment_text
/*ADVICE(4351): Unreferenced variable [553] */
                          VARCHAR2 (2000)                               := NULL;
/*ADVICE(4353): VARCHAR2 declaration with length greater than 500 characters [307] */

/*ADVICE(4355): Initialization to NULL is superfluous [417] */

  l_date_to
/*ADVICE(4358): Unreferenced variable [553] */
                          DATE;
  l_date_from
/*ADVICE(4361): Unreferenced variable [553] */
                          DATE;
  sub_log_msg             VARCHAR2 (2000);
/*ADVICE(4364): VARCHAR2 declaration with length greater than 500 characters [307] */

  rej_log_msg             VARCHAR2 (2000);
/*ADVICE(4367): VARCHAR2 declaration with length greater than 500 characters [307] */

  lock_log_msg            VARCHAR2 (2000);
/*ADVICE(4370): VARCHAR2 declaration with length greater than 500 characters [307] */

  l_empnumber             VARCHAR2 (30);
  l_empname               VARCHAR2 (240);
  l_enddate               DATE;
  spemp_tc_list           hxc_timecard_utilities.periods;
  spemp_tc_info           hxc_timekeeper_utilities.emptctab;
  sp_index                NUMBER
/*ADVICE(4378): NUMBER has no precision [315] */
                                                                        := 0;
  l_timecard_index_info   hxc_timekeeper_process.t_timecard_index_info;
  l_attribute_index_info  hxc_timekeeper_process.t_attribute_index_info;
  l_process_lock_type     VARCHAR2 (80)                           := hxc_lock_util.c_pui_timekeeper_action;
  l_messages              hxc_message_table_type                        := hxc_message_table_type ();
  l_row_id                ROWID
/*ADVICE(4385): Use of ROWID [113] */
                               ;
  l_tc_lock_boolean       BOOLEAN;
  l_relased_success       BOOLEAN                                       := FALSE;
  l_lock_trx_id           NUMBER (15)                                   := p_submission_id;
  l_lock_row_id           ROWID
/*ADVICE(4391): Use of ROWID [113] */
                               ;
  l_notify_to             VARCHAR2 (30);
  l_notify_type           VARCHAR2 (20);
  l_tk_audit_enabled      VARCHAR2 (30);
  l_operating_unit_id number(15);
  l_operating_name hr_operating_units.name%type;
  l_operating_unit_cnt	number(10);
  l_emp_terminate_date    date;
  l_tc_in_term_status varchar2(1) :='N';
 BEGIN
  g_submit := TRUE;
  -- initialize the workflow


  hxc_self_service_time_deposit.set_workflow_info (
   p_item_type => 'HXCEMP',
   p_process_name => 'HXC_APPROVAL'
  );

  FOR c_resource IN crs_resource_id (p_submission_id) LOOP
  --Initialize the org_id
   BEGIN
	-- Derive the operating unit for the resource

	-- ONLY CALL THIS FOR R12 WHEN API AVAILABLE
		Begin
		l_operating_unit_id := 	hr_organization_api.get_operating_unit
					(p_effective_date                 => sysdate
					,p_person_id                      => c_resource.resource_id);

	exception
	when others then
	   MO_UTILS.get_default_ou(l_operating_unit_id,l_operating_name,l_operating_unit_cnt);
	end;

	-- now set the operating unit context

	-- ONLY CALL THIS FOR RELEASE 12

	mo_global.init('HXC');
	mo_global.set_policy_context ( 'S', l_operating_unit_id );
   End;
   hxc_timekeeper_utilities.populate_tc_tab (
    c_resource.resource_id,
    fnd_date.canonical_to_date (p_start_period),
    fnd_date.canonical_to_date (p_end_period),
    spemp_tc_info
   );
/* changes done by senthil for emp terminate enhancement*/
/*Changed By Mithun for CWK Terminate Bug*/
        OPEN c_emp_terminateinfo (p_resource_id => c_resource.resource_id);
	FETCH c_emp_terminateinfo INTO l_emp_terminate_date, date_start;
	CLOSE c_emp_terminateinfo;
	if l_emp_terminate_date between fnd_date.canonical_to_date (p_start_period) and     fnd_date.canonical_to_date (p_end_period) then
		open c_tc_in_term_period_exists(c_resource.resource_id,    fnd_date.canonical_to_date (p_start_period),   fnd_date.canonical_to_date (p_end_period));
		FETCH c_tc_in_term_period_exists into l_tc_in_term_status;
		close c_tc_in_term_period_exists;
	end if;
	if l_tc_in_term_status <> 'Y' then
	hxc_timekeeper_utilities.split_timecard (
	    c_resource.resource_id,
	    fnd_date.canonical_to_date (p_start_period),
	    fnd_date.canonical_to_date (p_end_period),
	    spemp_tc_info,
	    spemp_tc_list
	   );
	else
	  spemp_tc_list (TO_NUMBER (TO_CHAR (TO_DATE (fnd_date.canonical_to_date(p_start_period), 'dd-mm-rrrr'), 'J'))).start_date :=    fnd_date.canonical_to_date (p_start_period);
	  spemp_tc_list (TO_NUMBER (TO_CHAR (TO_DATE (fnd_date.canonical_to_date(p_start_period), 'dd-mm-rrrr'), 'J'))).end_date := fnd_date.canonical_to_date (p_end_period);
	end if;
   sp_index := spemp_tc_list.FIRST;
   LOOP
    EXIT WHEN NOT spemp_tc_list.EXISTS (sp_index);
    IF    (TO_DATE (fnd_date.canonical_to_date (p_start_period), 'DD-MM-RRRR') >
                                              TO_DATE (spemp_tc_list (sp_index).start_date, 'DD-MM-RRRR')
          )
       OR (TO_DATE (fnd_date.canonical_to_date (p_end_period), 'DD-MM-RRRR') <
                                                TO_DATE (spemp_tc_list (sp_index).end_date, 'DD-MM-RRRR')
          ) THEN
     NULL;
/*ADVICE(4432): Use of NULL statements [532] */

    ELSE
     l_attributes.DELETE;
     l_timecard.DELETE;
     l_timecard_id := NULL;
     l_row_id := NULL;
     l_tc_lock_boolean := FALSE;
     l_relased_success := FALSE;
     l_day_id_info_table.delete;
     l_timecard_index_info.delete;
     l_attribute_index_info.delete;

     create_timecard_day_structure (
      p_resource_id => c_resource.resource_id,
      p_start_period => TO_DATE (spemp_tc_list (sp_index).start_date, 'DD-MM-RRRR'),
      p_end_period => TO_DATE (spemp_tc_list (sp_index).end_date, 'DD-MM-RRRR'),
      p_tc_frdt => fnd_date.canonical_to_date (p_start_period),
      p_tc_todt => fnd_date.canonical_to_date (p_end_period),
      p_timecard => l_timecard,
      p_attributes => l_attributes,
      p_day_id_info_table => l_day_id_info_table,
      p_approval_style_id => l_approval_style_id,
      p_approval_status => l_approval_status,
      p_comment_text => NULL,
      p_timecard_status => l_timecard_status,
      p_attribute_index_info => l_attribute_index_info,
      p_timecard_index_info => l_timecard_index_info,
      p_timecard_id => l_timecard_id
     );
     --check the lock
     l_lock_row_id := hxc_lock_api.check_lock (
                       p_process_locker_type => l_process_lock_type,
                       p_transaction_lock_id => l_lock_trx_id,
                       p_resource_id => c_resource.resource_id
                      );

     IF NVL (l_timecard_status, 'xx') = 'SUBMITTED' OR NVL (l_timecard_status, 'xx') = 'APPROVED' THEN
      fnd_file.new_line (fnd_file.LOG, 1);
      fnd_message.set_name ('HXC', 'HXC_NOCHANGE_TIMECARD');

      IF sub_log_msg IS NULL THEN
       sub_log_msg := SUBSTR (fnd_message.get (), 1, 2000);
       fnd_file.put_line (fnd_file.LOG, sub_log_msg);
       rej_log_msg := NULL;
       fnd_file.new_line (fnd_file.LOG, 1);
      END IF;

      OPEN crs_employee_info (
       c_resource.resource_id,
       fnd_date.canonical_to_date (p_start_period),
       fnd_date.canonical_to_date (p_end_period)
      );
      FETCH crs_employee_info INTO l_empnumber, l_empname, l_enddate;
/*ADVICE(4482): FETCH into a list of variables instead of a record [204] */

      CLOSE crs_employee_info;
      fnd_file.put_line (fnd_file.LOG, RTRIM (l_empnumber) || ' - ' || RTRIM (l_empname));
      hxc_lock_api.release_lock (
       p_row_lock_id => l_lock_row_id,
       p_process_locker_type => l_process_lock_type,
       p_transaction_lock_id => l_lock_trx_id,
       p_resource_id => NULL,
       p_start_time => NULL,
       p_stop_time => NULL,
       p_time_building_block_id => NULL,
       p_time_building_block_ovn => NULL,
       p_messages => l_messages,
       p_released_success => l_relased_success
      );
     ELSIF NVL (l_timecard_status, 'xx') = 'xx' THEN
      l_timecard.DELETE;
      l_attributes.DELETE;
      hxc_lock_api.release_lock (
       p_row_lock_id => l_lock_row_id,
       p_process_locker_type => l_process_lock_type,
       p_transaction_lock_id => l_lock_trx_id,
       p_resource_id => NULL,
       p_start_time => NULL,
       p_stop_time => NULL,
       p_time_building_block_id => NULL,
       p_time_building_block_ovn => NULL,
       p_messages => l_messages,
       p_released_success => l_relased_success
      );
     ELSE
      --if lock is removed again request lock
      IF l_lock_row_id IS NULL THEN
       hxc_lock_api.request_lock (
        p_process_locker_type => l_process_lock_type,
        p_resource_id => c_resource.resource_id,
        p_start_time => fnd_date.canonical_to_date (p_start_period),
        p_stop_time => fnd_date.canonical_to_date (p_end_period) + g_one_day,
        p_time_building_block_id => NULL,
        p_time_building_block_ovn => NULL,
        p_transaction_lock_id => l_lock_trx_id,
        p_messages => l_messages,
        p_row_lock_id => l_lock_row_id,
        p_locked_success => l_tc_lock_boolean
       );
      END IF;

      IF l_lock_row_id IS NOT NULL THEN
            -- first insert message in log file if rejected TC is submitted without any change
       -- before subm,itting the TC.

       IF NVL (l_timecard_status, 'xx') = 'REJECTED' THEN
        fnd_file.new_line (fnd_file.LOG, 1);
        fnd_message.set_name ('HXC', 'HXC_TK_SUBMIT_UNCHANGED_TC');

        IF rej_log_msg IS NULL THEN
         rej_log_msg := SUBSTR (fnd_message.get (), 1, 2000);
         fnd_file.put_line (fnd_file.LOG, rej_log_msg);
         sub_log_msg := NULL;
         fnd_file.new_line (fnd_file.LOG, 1);
        END IF;

        OPEN crs_employee_info (
         c_resource.resource_id,
         fnd_date.canonical_to_date (p_start_period),
         fnd_date.canonical_to_date (p_end_period)
        );
        FETCH crs_employee_info INTO l_empnumber, l_empname, l_enddate;
/*ADVICE(4551): FETCH into a list of variables instead of a record [204] */

        CLOSE crs_employee_info;
        fnd_file.put_line (fnd_file.LOG, RTRIM (l_empnumber) || ' - ' || RTRIM (l_empname));
       END IF;

       l_notify_to :=
              hxc_preference_evaluation.resource_preferences (p_timekeeper_id, 'TK_TCARD_CLA', 3, SYSDATE);
       l_notify_type :=
              hxc_preference_evaluation.resource_preferences (p_timekeeper_id, 'TK_TCARD_CLA', 4, SYSDATE);
       l_tk_audit_enabled :=
              hxc_preference_evaluation.resource_preferences (p_timekeeper_id, 'TK_TCARD_CLA', 1, SYSDATE);

       hxc_timekeeper.submit_timecard (
        p_blocks => l_timecard,
        p_attributes => l_attributes,
        p_messages => p_messages,
        p_timecard_id => l_timecard_id,
        p_timecard_ovn => l_timecard_ovn,
        p_timekeeper_id => p_timekeeper_id,
        p_tk_audit_enabled => l_tk_audit_enabled,
        p_tk_notify_to => l_notify_to,
        p_tk_notify_type => l_notify_type
       );
       l_relased_success := FALSE;
       hxc_lock_api.release_lock (
        p_row_lock_id => l_lock_row_id,
        p_process_locker_type => l_process_lock_type,
        p_transaction_lock_id => l_lock_trx_id,
        p_resource_id => NULL,
        p_start_time => NULL,
        p_stop_time => NULL,
        p_time_building_block_id => NULL,
        p_time_building_block_ovn => NULL,
        p_messages => l_messages,
        p_released_success => l_relased_success
       );
      ELSE
       --put message in log file as it is not locked
       OPEN crs_employee_info (
        c_resource.resource_id,
        fnd_date.canonical_to_date (p_start_period),
        fnd_date.canonical_to_date (p_end_period)
       );
       FETCH crs_employee_info INTO l_empnumber, l_empname, l_enddate;
/*ADVICE(4595): FETCH into a list of variables instead of a record [204] */

       CLOSE crs_employee_info;
       fnd_file.new_line (fnd_file.LOG, 1);
       fnd_message.set_name ('HXC', 'HXC_TIMECARD_LOCKED');
       fnd_message.set_token ('FULL_NAME', l_empname);
       lock_log_msg := SUBSTR (fnd_message.get (), 1, 2000);
       fnd_file.put_line (fnd_file.LOG, lock_log_msg);
       lock_log_msg := NULL;
      END IF;
     END IF;
    END IF;

    sp_index := spemp_tc_list.NEXT (sp_index);
   END LOOP;
/*ADVICE(4610): Nested LOOPs should all be labeled [406] */
   COMMIT;

  END LOOP;

  g_submit := FALSE;
 END;


-------------------------------------------------------------------------------
-- this procedure create the timecard - day structure for a resource_id
-- and a period of time
-------------------------------------------------------------------------------

 PROCEDURE create_timecard_day_structure (
  p_resource_id IN NUMBER,
  p_start_period IN DATE,
  p_end_period IN DATE,
  p_tc_frdt
/*ADVICE(4629): Unreferenced parameter [552] */
            IN DATE,
  p_tc_todt
/*ADVICE(4632): Unreferenced parameter [552] */
            IN DATE,
  p_timecard IN OUT NOCOPY hxc_block_table_type,
  p_attributes IN OUT NOCOPY hxc_attribute_table_type,
  p_day_id_info_table OUT NOCOPY t_day_id_info_table,
  p_approval_style_id OUT NOCOPY NUMBER,
  p_approval_status OUT NOCOPY VARCHAR2,
  p_comment_text IN VARCHAR2,
  p_timecard_status OUT NOCOPY VARCHAR2,
  p_attribute_index_info IN OUT NOCOPY hxc_timekeeper_process.t_attribute_index_info,
  p_timecard_index_info IN OUT NOCOPY hxc_timekeeper_process.t_timecard_index_info,
  p_timecard_id OUT NOCOPY NUMBER
 ) IS
  CURSOR c_timecard_info (
   p_resource_id
/*ADVICE(4647): This definition hides another one [556] */
                 IN NUMBER,
   p_start_period
/*ADVICE(4650): This definition hides another one [556] */
                  IN DATE,
   p_end_period
/*ADVICE(4653): This definition hides another one [556] */
                IN DATE
  ) IS
   SELECT time_building_block_id, object_version_number, date_to, date_from, approval_style_id,
          approval_status, comment_text,application_set_id
   FROM   hxc_time_building_blocks
   WHERE  resource_id = p_resource_id
AND       SCOPE = 'TIMECARD'
AND       date_to = hr_general.end_of_time
AND       start_time = p_start_period
AND       stop_time = p_end_period;

  CURSOR c_day_info (
   p_resource_id
/*ADVICE(4667): This definition hides another one [556] */
                 IN NUMBER,
   p_start_period
/*ADVICE(4670): This definition hides another one [556] */
                  IN DATE,
   p_end_period
/*ADVICE(4673): This definition hides another one [556] */
                IN DATE,
   p_parent_building_block_id IN NUMBER,
   p_parent_ovn IN NUMBER
  ) IS
   SELECT time_building_block_id, object_version_number, date_to, date_from,application_set_id
   FROM   hxc_time_building_blocks
   WHERE  resource_id = p_resource_id
AND       parent_building_block_id = p_parent_building_block_id
AND       parent_building_block_ovn = p_parent_ovn
AND       date_to = hr_general.end_of_time
AND       SCOPE = 'DAY'
AND       start_time = p_start_period
AND       stop_time = p_end_period;

  CURSOR c_detail_info (
   p_resource_id
/*ADVICE(4690): This definition hides another one [556] */
                 IN NUMBER,
   p_parent_building_block_id IN NUMBER,
   p_parent_ovn IN NUMBER
  ) IS
   SELECT time_building_block_id detail_id, object_version_number detail_ovn, measure, date_to,
          date_from, start_time, stop_time, comment_text,application_set_id
   FROM   hxc_time_building_blocks
   WHERE  resource_id = p_resource_id
AND       parent_building_block_id = p_parent_building_block_id
AND       parent_building_block_ovn = p_parent_ovn
AND       date_to = hr_general.end_of_time
AND       SCOPE = 'DETAIL';

  l_find_day_also         BOOLEAN                                := TRUE;
  l_index_day             NUMBER
/*ADVICE(4706): NUMBER has no precision [315] */
                                                                 := 0;
  l_index
/*ADVICE(4709): Unreferenced variable [553] */
                          NUMBER
/*ADVICE(4711): NUMBER has no precision [315] */
                                ;
  l_timecard_id           NUMBER
/*ADVICE(4714): NUMBER has no precision [315] */
                                                                 := NULL;
/*ADVICE(4716): Initialization to NULL is superfluous [417] */

  l_timecard_ovn          NUMBER
/*ADVICE(4719): NUMBER has no precision [315] */
                                                                 := NULL;
/*ADVICE(4721): Initialization to NULL is superfluous [417] */

  l_timecard_comment_text VARCHAR2 (2000)                        := NULL;
/*ADVICE(4724): VARCHAR2 declaration with length greater than 500 characters [307] */

/*ADVICE(4726): Initialization to NULL is superfluous [417] */

  l_day_id                NUMBER
/*ADVICE(4729): NUMBER has no precision [315] */
                                                                 := 0;
  l_day_ovn               NUMBER
/*ADVICE(4732): NUMBER has no precision [315] */
                                                                 := NULL;
/*ADVICE(4734): Initialization to NULL is superfluous [417] */

  l_date_to               DATE;
  l_date_from             DATE;
  l_day_date_from         DATE;
  l_day_date_to           DATE;
  l_emp_negpref           VARCHAR2 (150);
  l_emp_recpref           NUMBER
/*ADVICE(4742): NUMBER has no precision [315] */
                                ;
  l_emp_appstyle          NUMBER
/*ADVICE(4745): NUMBER has no precision [315] */
                                ;
  l_emp_layout1           NUMBER
/*ADVICE(4748): NUMBER has no precision [315] */
                                ;
  l_emp_layout2           NUMBER
/*ADVICE(4751): NUMBER has no precision [315] */
                                ;
  l_emp_layout3           NUMBER
/*ADVICE(4754): NUMBER has no precision [315] */
                                ;
  l_emp_layout4           NUMBER
/*ADVICE(4757): NUMBER has no precision [315] */
                                ;
  l_emp_layout5           NUMBER
/*ADVICE(4760): NUMBER has no precision [315] */
                                ;
  l_emp_layout6           NUMBER
/*ADVICE(4763): NUMBER has no precision [315] */
                                ;
  l_emp_layout7           NUMBER
/*ADVICE(4766): NUMBER has no precision [315] */
                                ;
  l_emp_layout8           NUMBER
/*ADVICE(4769): NUMBER has no precision [315] */
                                ;
  l_emp_edits             VARCHAR2 (150);
  l_pastdt                VARCHAR2 (30);
  l_futuredt              VARCHAR2 (30);
  l_pref_table
/*ADVICE(4775): Unreferenced variable [553] */
                          hxc_preference_evaluation.t_pref_table;
  l_timecard_status       VARCHAR2 (10);
  l_emp_start_date        DATE;
  l_emp_terminate_date    DATE;
  l_audit_enabled         VARCHAR2 (150);
  l_application_set_id    hxc_time_building_blocks.application_set_id%type:=NULL;
  l_day_changed		VARCHAR2(1):='N';
  l_timecard_changed	VARCHAR2(1):='N';

  l_found		VARCHAR2(1):='N';   /* Bug 9014012 */
  l_tmp_index		NUMBER;     	    /* Bug 9014012 */


 BEGIN
   g_debug :=hr_utility.debug_enabled;
-- check if the resource_id has already an timecard for the
-- period.

  OPEN c_timecard_info (p_resource_id, p_start_period, p_end_period + g_one_day);
  FETCH c_timecard_info INTO l_timecard_id,
                             l_timecard_ovn,
                             l_date_to,
                             l_date_from,
                             p_approval_style_id,
                             p_approval_status,
                             l_timecard_comment_text,
			     l_application_set_id;
/*ADVICE(4793): FETCH into a list of variables instead of a record [204] */

  CLOSE c_timecard_info;

  IF NOT g_submit THEN
   l_timecard_comment_text := p_comment_text;
  END IF;

  ---store the employee preferences
  l_emp_negpref := NULL;
  l_emp_recpref := NULL;
  l_emp_appstyle := NULL;
  l_emp_layout1 := NULL;
  l_emp_layout2 := NULL;
  l_emp_layout3 := NULL;
  l_emp_layout4 := NULL;
  l_emp_layout5 := NULL;
  l_emp_layout6 := NULL;
  l_emp_layout7 := NULL;
  l_emp_layout8 := NULL;
  l_emp_edits := NULL;
  l_audit_enabled := NULL;

  -- let's get the resource preference
  -- we need to reset the approval style all the time.
  hxc_timekeeper_utilities.get_emp_pref (
    p_resource_id => p_resource_id,
    neg_pref => l_emp_negpref,
    recpref => l_emp_recpref,
    appstyle => l_emp_appstyle,
    layout1 => l_emp_layout1,
    layout2 => l_emp_layout2,
    layout3 => l_emp_layout3,
    layout4 => l_emp_layout4,
    layout5 => l_emp_layout5,
    layout6 => l_emp_layout6,
    layout7 => l_emp_layout7,
    layout8 => l_emp_layout8,
    edits => l_emp_edits,
    l_pastdate => l_pastdt,
    l_futuredate => l_futuredt,
    l_emp_start_date => l_emp_start_date,
    l_emp_terminate_date =>l_emp_terminate_date,
    l_audit_enabled => l_audit_enabled
   );
   if g_debug then
           hr_utility.TRACE ('_audit_enabled'|| l_audit_enabled);
   end if;

   p_approval_style_id := l_emp_appstyle;

if g_debug then
hr_utility.trace('SVG create_timecard_day_structure : l_timecard_id: '||l_timecard_id);
hr_utility.trace('SVG create_timecard_day_structure  : g_negative_index: '||g_negative_index);
end if;

  -- if the timecard_id is null then we need to generate one
  IF l_timecard_id IS NULL then
   g_negative_index := g_negative_index - 1;

   /*Bug 9014012*/

      l_found:= 'N';

      LOOP
      l_tmp_index:= g_negative_index * -1;
      if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

       	g_negative_index := g_negative_index - 1;
           l_found:= 'N';

      else

           l_found:='Y';

      end if;

      EXIT WHEN l_found = 'Y';
   END LOOP;


   if g_debug then
   hr_utility.trace('g_negative_index = '||g_negative_index);
   hr_utility.trace('g_resource_prepop_count 1 ='||g_resource_prepop_count);
   end if;

   l_timecard_id := g_negative_index;
   l_date_to := hr_general.end_of_time;
   l_date_from := SYSDATE;
   l_timecard_ovn := 1; --added for new deposit_wrapper null;
   l_find_day_also := FALSE;
   -- we will need to create the required attributes on the timecard as LAYOUT....
   -- first we need to find the approval_style_id and the layout information
   -- attached to user the preference.

   g_negative_index := g_negative_index - 1;

   /*Bug 9014012*/

   l_found:= 'N';

   LOOP
   l_tmp_index:= g_negative_index * -1;
   if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

    	g_negative_index := g_negative_index - 1;
        l_found:= 'N';

   else

        l_found:='Y';

   end if;

   EXIT WHEN l_found = 'Y';
   END LOOP;


   if g_debug then
   hr_utility.trace('g_negative_index = '||g_negative_index);
   end if;
--
   hxc_timekeeper_utilities.add_attribute (
    p_attribute => p_attributes,
    p_attribute_id => g_negative_index,
    p_tbb_id => l_timecard_id,
    p_tbb_ovn => l_timecard_ovn,
    p_blk_type => 'LAYOUT',
    p_blk_id => hxc_alias_utility.get_bld_blk_type_id ('LAYOUT'),
    p_att_category => 'LAYOUT',
    p_att_1 => l_emp_layout1,
    p_att_2 => l_emp_layout2,
    p_att_3 => l_emp_layout3,
    p_att_4 => l_emp_layout4,
    p_att_5 => l_emp_layout5,
    p_att_6 => l_emp_layout6,
    p_att_7 => l_emp_layout7,
    p_att_8 => l_emp_layout8,
    p_attribute_index_info => p_attribute_index_info
   );
   p_timecard_status := NULL;

   if g_debug then
   hr_utility.trace('After add_attribute for LAYOUT');
   end if;

  ELSE
   -- if the timecard is not null then we create the all attributes  table

   IF g_submit THEN
    l_timecard_status :=
                        hxc_timecard_search_pkg.get_timecard_status_code (l_timecard_id, l_timecard_ovn);
    p_timecard_status := l_timecard_status;
   END IF;

   hxc_timekeeper_utilities.create_attribute_structure (
    p_timecard_id => l_timecard_id,
    p_timecard_ovn => l_timecard_ovn,
    p_resource_id => p_resource_id,
    p_start_period => p_start_period,
    p_end_period => p_end_period,
    p_attributes => p_attributes,
    p_add_hours_type_id => NULL,
    p_attribute_index_info => p_attribute_index_info
   );
  END IF;

  p_timecard_id := l_timecard_id;
  -- create the timecard block
  /* start of fix for 5398047 */
if (not g_submit ) and p_approval_status = 'WORKING' then
    l_timecard_changed:='N';
else
    l_timecard_changed:='Y';
end if;
/* end of fix for 5398047 */
  if g_debug then
  hr_utility.trace('before add_block for TIMECARD');
  end if;

  hxc_timekeeper_utilities.add_block (
   p_timecard => p_timecard,
   p_timecard_id => l_timecard_id,
   p_ovn => l_timecard_ovn,
   p_parent_id => NULL,
   p_parent_ovn => NULL,
   p_approval_style_id => p_approval_style_id,
   p_measure => NULL,
   p_scope => 'TIMECARD',
   p_date_to => l_date_to,
   p_date_from => l_date_from,
   p_start_period => p_start_period,
   p_end_period => p_end_period + g_one_day,
   p_resource_id => p_resource_id,
   p_changed => l_timecard_changed,
   p_comment_text => l_timecard_comment_text,
   p_submit_flg => g_submit,
   p_application_set_id => l_application_set_id,
   p_timecard_index_info => p_timecard_index_info
  );

  -- create the day block
  WHILE p_start_period + l_index_day <= p_end_period
/*ADVICE(4917): Complex expression not fully parenthesized [404] */
                                                     LOOP
   -- create a day block
   -- first check if the the day already exists

   IF l_find_day_also THEN
    OPEN c_day_info (
     p_resource_id,
     p_start_period + l_index_day,
     p_start_period + l_index_day + g_one_day,
     l_timecard_id,
     l_timecard_ovn
    );
    FETCH c_day_info INTO l_day_id, l_day_ovn, l_day_date_to, l_day_date_from,l_application_set_id;
/*ADVICE(4931): FETCH into a list of variables instead of a record [204] */


    IF c_day_info%NOTFOUND THEN
     g_negative_index := g_negative_index - 1;

     /*Bug 9014012*/

     l_found:= 'N';

     LOOP
     l_tmp_index:= g_negative_index * -1;
     if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

      	g_negative_index := g_negative_index - 1;
          l_found:= 'N';

     else

          l_found:='Y';

     end if;

     EXIT WHEN l_found = 'Y';
     END LOOP;


     l_day_date_to := hr_general.end_of_time;
     l_day_date_from := SYSDATE;
     l_day_id := g_negative_index;
     l_day_ovn := 1;
    END IF;

    CLOSE c_day_info;
   ELSE

    g_negative_index := g_negative_index - 1;

    /*Bug 9014012*/

       l_found:= 'N';

       LOOP
       l_tmp_index:= g_negative_index * -1;
       if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

        	g_negative_index := g_negative_index - 1;
            l_found:= 'N';

       else

            l_found:='Y';

       end if;

       EXIT WHEN l_found = 'Y';
   END LOOP;



    l_day_date_to := hr_general.end_of_time;
    l_day_date_from := SYSDATE;
    l_day_id := g_negative_index;
    l_day_ovn := 1;
   END IF;

   -- add the day
   /* start of fix for 5398047 */
if (not g_submit ) then
    l_day_changed:='N';
else
    l_day_changed:='Y';
end if;
/* end of fix for 5398047 */
   hxc_timekeeper_utilities.add_block (
    p_timecard => p_timecard,
    p_timecard_id => l_day_id,
    p_ovn => l_day_ovn,
    p_parent_id => l_timecard_id,
    p_parent_ovn => l_timecard_ovn,
    p_approval_style_id => p_approval_style_id,
    p_measure => NULL,
    p_scope => 'DAY',
    p_date_to => l_day_date_to,
    p_date_from => l_day_date_from,
    p_start_period => p_start_period + l_index_day,
    p_end_period => p_start_period + l_index_day + g_one_day,
    p_resource_id => p_resource_id,
    p_changed => l_day_changed,
    p_comment_text => NULL,
    p_submit_flg => g_submit,
    p_application_set_id => l_application_set_id,
    p_timecard_index_info => p_timecard_index_info
   );

   -- add the detail now
   IF l_day_id > 0 THEN
    FOR detail_info IN c_detail_info (p_resource_id, l_day_id, l_day_ovn) LOOP
     -- add the detail
     hxc_timekeeper_utilities.add_block (
      p_timecard => p_timecard,
      p_timecard_id => detail_info.detail_id,
      p_ovn => detail_info.detail_ovn,
      p_parent_id => l_day_id,
      p_parent_ovn => l_day_ovn,
      p_approval_style_id => p_approval_style_id,
      p_measure => detail_info.measure,
      p_scope => 'DETAIL',
      p_date_to => detail_info.date_to,
      p_date_from => detail_info.date_from,
      p_start_period => detail_info.start_time,
      p_end_period => detail_info.stop_time,
      p_resource_id => p_resource_id,
      p_changed => 'Y',
      p_comment_text => detail_info.comment_text,
      p_submit_flg => g_submit,
      p_application_set_id => detail_info.application_set_id,
      p_timecard_index_info => p_timecard_index_info
     );
    END LOOP;
/*ADVICE(4996): Nested LOOPs should all be labeled [406] */

   END IF;

   p_day_id_info_table (l_index_day).day_id := l_day_id;
   p_day_id_info_table (l_index_day).day_ovn := l_day_ovn;
   -- increment the l_index_day of one
   l_index_day := l_index_day + 1;
  END LOOP; --day block while loop
 END create_timecard_day_structure;


-------------------------------------------------------------------------------
-- this procedure create the detail-attribute information for an existing
-- timecard structure
-------------------------------------------------------------------------------

 PROCEDURE create_detail_structure (
  p_timekeeper_id IN NUMBER,
  p_att_tab IN hxc_alias_utility.t_alias_att_info,
  p_resource_id IN NUMBER,
  p_start_period IN DATE,
  p_end_period IN DATE,
  p_tc_frdt IN DATE,
  p_tc_todt
/*ADVICE(5021): Unreferenced parameter [552] */
            IN DATE,
  p_insert_detail IN hxc_timekeeper_process.t_time_info,
  p_timecard IN OUT NOCOPY hxc_block_table_type,
  p_attributes IN OUT NOCOPY hxc_attribute_table_type,
  p_day_id_info_table IN hxc_timekeeper_process.t_day_id_info_table,
  p_approval_style_id IN NUMBER,
  p_attribute_index_info IN OUT NOCOPY hxc_timekeeper_process.t_attribute_index_info,
  p_timecard_index_info IN OUT NOCOPY hxc_timekeeper_process.t_timecard_index_info,
  p_timecard_id IN NUMBER,
  p_mid_save IN OUT NOCOPY VARCHAR2,
  p_comment_made_null IN OUT NOCOPY BOOLEAN,
  p_row_lock_id OUT NOCOPY ROWID,
  p_tk_audit_enabled    IN 		VARCHAR2
 ) IS
  l_index_day                  NUMBER
/*ADVICE(5036): NUMBER has no precision [315] */
                                                                                      := 0;
  l_measure                    NUMBER
/*ADVICE(5039): NUMBER has no precision [315] */
                                                                                      := NULL;
/*ADVICE(5041): Initialization to NULL is superfluous [417] */

  l_detail_id                  hxc_time_building_blocks.time_building_block_id%TYPE   := 0;
  l_detail_ovn                 NUMBER
/*ADVICE(5045): NUMBER has no precision [315] */
                                                                                      := 0;
  l_detail_time_in             DATE;
  l_detail_time_out            DATE;
  l_detail_comment_text        VARCHAR2 (2000)                                        := NULL;
/*ADVICE(5050): VARCHAR2 declaration with length greater than 500 characters [307] */

/*ADVICE(5052): Initialization to NULL is superfluous [417] */

  l_detail_old_comment_text    VARCHAR2 (2000);
/*ADVICE(5055): VARCHAR2 declaration with length greater than 500 characters [307] */

  l_attribute_index            NUMBER
/*ADVICE(5058): NUMBER has no precision [315] */
                                     ;
  l_att_string                 VARCHAR2 (100);
  l_action                     VARCHAR2 (80);
  l_index_next
/*ADVICE(5063): Unreferenced variable [553] */
                               NUMBER
/*ADVICE(5065): NUMBER has no precision [315] */
                                     ;
  l_index_start
/*ADVICE(5068): Unreferenced variable [553] */
                               NUMBER
/*ADVICE(5070): NUMBER has no precision [315] */
                                     ;
  l_result
/*ADVICE(5073): Unreferenced variable [553] */
                               VARCHAR2 (10);
  l_tbb_id_reference_table     hxc_alias_utility.t_tbb_id_reference;
  n
/*ADVICE(5077): Unreferenced variable [553] */
                               NUMBER
/*ADVICE(5079): NUMBER has no precision [315] */
                                                                                      := 0;
  valid_att_cat                VARCHAR2 (2000)                                        := NULL;
/*ADVICE(5082): VARCHAR2 declaration with length greater than 500 characters [307] */

/*ADVICE(5084): Initialization to NULL is superfluous [417] */

  l_add_index_day              NUMBER
/*ADVICE(5087): NUMBER has no precision [315] */
                                                                                      := 0;
  bldtyp_id                    NUMBER
/*ADVICE(5090): NUMBER has no precision [315] */
                                     ;
  reason_bldtyp_id             NUMBER
/*ADVICE(5093): NUMBER has no precision [315] */
                                     ;
  l_old_attribute_value        VARCHAR2 (150);
  l_new_attribute_value        VARCHAR2 (150);
  l_application_set_id         hxc_time_building_blocks.application_set_id%type:=NULL;

  /*
  Added for bug 8775740
  HR OTL Absence Integration.
  */
  -- Change start
    l_tmp_index		NUMBER;
    l_found		VARCHAR2(1);
  -- Change end


  CURSOR c_detail (
   p_detailid IN NUMBER
  ) IS
   SELECT *
   FROM   hxc_tk_detail_temp
   WHERE  detailid = p_detailid;

  CURSOR c_timecard_info (
   p_resource_id
/*ADVICE(5107): This definition hides another one [556] */
                 IN NUMBER,
   p_start_period
/*ADVICE(5110): This definition hides another one [556] */
                  IN DATE,
   p_end_period
/*ADVICE(5113): This definition hides another one [556] */
                IN DATE
  ) IS
   SELECT comment_text
   FROM   hxc_time_building_blocks
   WHERE  resource_id = p_resource_id
AND       SCOPE = 'TIMECARD'
AND       date_to = hr_general.end_of_time
AND       start_time = p_start_period
AND       stop_time = p_end_period;

  c_row                        hxc_tk_detail_temp%ROWTYPE;

  l_detail_reason_category     VARCHAR2 (150);
  l_detail_reason_att_1        VARCHAR2 (150);
  l_detail_reason_att_2        VARCHAR2 (150);
  l_detail_reason_att_3        VARCHAR2 (150);
  l_detail_reason_att_4        VARCHAR2 (150);
  l_detail_reason_att_5        VARCHAR2 (150);
  l_detail_reason_att_6        VARCHAR2 (150);
  l_detail_reason_att_7        VARCHAR2 (150);

  l_detail_old_reason_category VARCHAR2 (150);
  l_detail_old_reason_att_1    VARCHAR2 (150);
  l_detail_old_reason_att_2    VARCHAR2 (150);
  l_detail_old_reason_att_3    VARCHAR2 (150);
  l_detail_old_reason_att_4    VARCHAR2 (150);
  l_detail_old_reason_att_5    VARCHAR2 (150);
  l_detail_old_reason_att_6    VARCHAR2 (150);
  l_detail_old_reason_att_7    VARCHAR2 (150);

  l_detail_dff_category        VARCHAR2 (150);
  l_detail_att_1               VARCHAR2 (150);
  l_detail_att_2               VARCHAR2 (150);
  l_detail_att_3               VARCHAR2 (150);
  l_detail_att_4               VARCHAR2 (150);
  l_detail_att_5               VARCHAR2 (150);
  l_detail_att_6               VARCHAR2 (150);
  l_detail_att_7               VARCHAR2 (150);
  l_detail_att_8               VARCHAR2 (150);
  l_detail_att_9               VARCHAR2 (150);
  l_detail_att_10              VARCHAR2 (150);
  l_detail_att_11              VARCHAR2 (150);
  l_detail_att_12              VARCHAR2 (150);
  l_detail_att_13              VARCHAR2 (150);
  l_detail_att_14              VARCHAR2 (150);
  l_detail_att_15              VARCHAR2 (150);
  l_detail_att_16              VARCHAR2 (150);
  l_detail_att_17              VARCHAR2 (150);
  l_detail_att_18              VARCHAR2 (150);
  l_detail_att_19              VARCHAR2 (150);
  l_detail_att_20              VARCHAR2 (150);
  l_detail_att_21              VARCHAR2 (150);
  l_detail_att_22              VARCHAR2 (150);
  l_detail_att_23              VARCHAR2 (150);
  l_detail_att_24              VARCHAR2 (150);
  l_detail_att_25              VARCHAR2 (150);
  l_detail_att_26              VARCHAR2 (150);
  l_detail_att_27              VARCHAR2 (150);
  l_detail_att_28              VARCHAR2 (150);
  l_detail_att_29              VARCHAR2 (150);
  l_detail_att_30              VARCHAR2 (150);

  l_detail_dff_old_category    VARCHAR2 (150);
  l_detail_old_att_1           VARCHAR2 (150);
  l_detail_old_att_2           VARCHAR2 (150);
  l_detail_old_att_3           VARCHAR2 (150);
  l_detail_old_att_4           VARCHAR2 (150);
  l_detail_old_att_5           VARCHAR2 (150);
  l_detail_old_att_6           VARCHAR2 (150);
  l_detail_old_att_7           VARCHAR2 (150);
  l_detail_old_att_8           VARCHAR2 (150);
  l_detail_old_att_9           VARCHAR2 (150);
  l_detail_old_att_10          VARCHAR2 (150);
  l_detail_old_att_11          VARCHAR2 (150);
  l_detail_old_att_12          VARCHAR2 (150);
  l_detail_old_att_13          VARCHAR2 (150);
  l_detail_old_att_14          VARCHAR2 (150);
  l_detail_old_att_15          VARCHAR2 (150);
  l_detail_old_att_16          VARCHAR2 (150);
  l_detail_old_att_17          VARCHAR2 (150);
  l_detail_old_att_18          VARCHAR2 (150);
  l_detail_old_att_19          VARCHAR2 (150);
  l_detail_old_att_20          VARCHAR2 (150);
  l_detail_old_att_21          VARCHAR2 (150);
  l_detail_old_att_22          VARCHAR2 (150);
  l_detail_old_att_23          VARCHAR2 (150);
  l_detail_old_att_24          VARCHAR2 (150);
  l_detail_old_att_25          VARCHAR2 (150);
  l_detail_old_att_26          VARCHAR2 (150);
  l_detail_old_att_27          VARCHAR2 (150);
  l_detail_old_att_28          VARCHAR2 (150);
  l_detail_old_att_29          VARCHAR2 (150);
  l_detail_old_att_30          VARCHAR2 (150);

  l_detail_info_found          BOOLEAN                                                := FALSE;
  l_attribute_found            BOOLEAN                                                := FALSE;

  l_reason_info_found          BOOLEAN                                                := FALSE;
  l_cla_attribute_changed      BOOLEAN                                                := FALSE;

  l_detail_dff_found	       BOOLEAN                                                := FALSE;
  l_detail_dff_changed	       BOOLEAN                                                := FALSE;

  l_timecard_comment_text      VARCHAR2 (2000);
/*ADVICE(5235): VARCHAR2 declaration with length greater than 500 characters [307] */

  l_block_index                NUMBER
/*ADVICE(5238): NUMBER has no precision [315] */
                                     ;
  l_detail_changed	       VARCHAR2(1);

 BEGIN
  g_debug :=hr_utility.debug_enabled;

 /*JOEL  MUST CACHE THIS INFORMATION */
  BEGIN
   SELECT bld_blk_info_type_id
   INTO   bldtyp_id
   FROM   hxc_bld_blk_info_types
   WHERE  bld_blk_info_type = 'Dummy Paexpitdff Context';
   EXCEPTION
    WHEN OTHERS THEN
         NULL;
/*ADVICE(5377): Use of NULL statements [532] */

/*ADVICE(5379): Exception masked by a NULL statement [533] */

/*ADVICE(5381): A WHEN OTHERS clause is used in the exception section without any other specific handlers
              [201] */

  END;

   BEGIN
    SELECT bld_blk_info_type_id
    INTO   reason_bldtyp_id
    FROM   hxc_bld_blk_info_types
    WHERE  bld_blk_info_type = 'REASON';
    EXCEPTION
     WHEN OTHERS THEN
     NULL;

   END ;

-- added to handle comment 2789497
  IF    NVL (p_insert_detail.timecard_start_period, p_start_period) = p_start_period
     OR NVL (p_insert_detail.timecard_end_period, p_end_period) = p_end_period THEN
   p_mid_save := 'Y';
   p_row_lock_id := CHARTOROWID (p_insert_detail.row_lock_id);

   IF  p_insert_detail.timekeeper_action = 'INSERT' AND p_insert_detail.comment_text IS NULL THEN
    IF p_timecard_index_info.EXISTS (p_timecard_id) THEN
     l_block_index := p_timecard_index_info (p_timecard_id).time_block_row_index;
     OPEN c_timecard_info (p_resource_id, p_start_period, p_end_period + g_one_day);
     FETCH c_timecard_info INTO l_timecard_comment_text;
     CLOSE c_timecard_info;

     IF p_comment_made_null THEN
      l_timecard_comment_text := NULL;
     END IF;

     p_timecard (l_block_index).comment_text :=
                                   NVL (p_timecard (l_block_index).comment_text, l_timecard_comment_text);
    END IF;
   ELSE
    IF p_timecard_index_info.EXISTS (p_timecard_id) THEN
     l_block_index := p_timecard_index_info (p_timecard_id).time_block_row_index;
     p_timecard (l_block_index).comment_text := p_insert_detail.comment_text;

     IF p_insert_detail.comment_text IS NULL THEN
      p_comment_made_null := TRUE;
     END IF;
    END IF;
   END IF;


if g_debug then
        hr_utility.trace('p_mid_save'||p_mid_save);
end if;
-- get the action on this row
   l_action := p_insert_detail.timekeeper_action;

   IF l_action = 'INSERT' THEN
    p_mid_save := 'N';
   END IF;


-- end 2789497

   -- get the attribute category as base for Details
   valid_att_cat :=
     hxc_timekeeper_utilities.get_tk_dff_attrname (
      p_tkid => p_timekeeper_id,
      p_insert_detail => p_insert_detail,
      p_base_dff => hxc_timekeeper_process.g_base_att,
      p_att_tab => p_att_tab
     );
   if g_debug then
           hr_utility.TRACE ('Attribute category is '|| valid_att_cat);
   end if;

--

   IF l_action = 'UPDATE' THEN -- create the tbb_id table reference
    -- for each time_building_block_id let create a reference attribute_id table
    hxc_alias_utility.get_tbb_id_reference_table (
     p_attributes => p_attributes,
     p_tbb_id_reference_table => l_tbb_id_reference_table
    );
   END IF;

   IF p_tc_frdt <> p_start_period THEN
    l_add_index_day := (trunc(p_start_period) - trunc(p_tc_frdt));
   ELSE
    l_add_index_day := 0;
   END IF;
   -- we are going the all table by looping all day of the
   -- period
   WHILE p_start_period + l_index_day <= p_end_period
/*ADVICE(5316): Complex expression not fully parenthesized [404] */
                                                      LOOP
    -- reset the variables
    l_measure := NULL;
    l_detail_id := NULL;
    l_detail_ovn := NULL;
    l_att_string := NULL;
    l_detail_time_in := NULL;
    l_detail_time_out := NULL;

    l_detail_info_found := FALSE;
    l_reason_info_found := FALSE;

    l_detail_reason_category := NULL;
    l_detail_reason_att_1 := NULL;
    l_detail_reason_att_2 := NULL;
    l_detail_reason_att_3 := NULL;
    l_detail_reason_att_4 := NULL;
    l_detail_reason_att_5 := NULL;
    l_detail_reason_att_6 := NULL;
    l_detail_reason_att_7 := NULL;

    l_detail_old_reason_category := NULL;
    l_detail_old_reason_att_1 := NULL;
    l_detail_old_reason_att_2 := NULL;
    l_detail_old_reason_att_3 := NULL;
    l_detail_old_reason_att_4 := NULL;
    l_detail_old_reason_att_5 := NULL;
    l_detail_old_reason_att_6 := NULL;
    l_detail_old_reason_att_7 := NULL;

    l_detail_comment_text := NULL;
    l_detail_old_comment_text := NULL;

    l_detail_dff_category := NULL;
    l_detail_att_1 := NULL;
    l_detail_att_2 := NULL;
    l_detail_att_3 := NULL;
    l_detail_att_4 := NULL;
    l_detail_att_5 := NULL;
    l_detail_att_6 := NULL;
    l_detail_att_7 := NULL;
    l_detail_att_8 := NULL;
    l_detail_att_9 := NULL;
    l_detail_att_10 := NULL;
    l_detail_att_11 := NULL;
    l_detail_att_12 := NULL;
    l_detail_att_13 := NULL;
    l_detail_att_14 := NULL;
    l_detail_att_15 := NULL;
    l_detail_att_16 := NULL;
    l_detail_att_17 := NULL;
    l_detail_att_18 := NULL;
    l_detail_att_19 := NULL;
    l_detail_att_20 := NULL;
    l_detail_att_21 := NULL;
    l_detail_att_22 := NULL;
    l_detail_att_23 := NULL;
    l_detail_att_24 := NULL;
    l_detail_att_25 := NULL;
    l_detail_att_26 := NULL;
    l_detail_att_27 := NULL;
    l_detail_att_28 := NULL;
    l_detail_att_29 := NULL;
    l_detail_att_30 := NULL;

    l_detail_dff_old_category := NULL;
    l_detail_old_att_1 := NULL;
    l_detail_old_att_2 := NULL;
    l_detail_old_att_3 := NULL;
    l_detail_old_att_4 := NULL;
    l_detail_old_att_5 := NULL;
    l_detail_old_att_6 := NULL;
    l_detail_old_att_7 := NULL;
    l_detail_old_att_8 := NULL;
    l_detail_old_att_9 := NULL;
    l_detail_old_att_10 := NULL;
    l_detail_old_att_11 := NULL;
    l_detail_old_att_12 := NULL;
    l_detail_old_att_13 := NULL;
    l_detail_old_att_14 := NULL;
    l_detail_old_att_15 := NULL;
    l_detail_old_att_16 := NULL;
    l_detail_old_att_17 := NULL;
    l_detail_old_att_18 := NULL;
    l_detail_old_att_19 := NULL;
    l_detail_old_att_20 := NULL;
    l_detail_old_att_21 := NULL;
    l_detail_old_att_22 := NULL;
    l_detail_old_att_23 := NULL;
    l_detail_old_att_24 := NULL;
    l_detail_old_att_25 := NULL;
    l_detail_old_att_26 := NULL;
    l_detail_old_att_27 := NULL;
    l_detail_old_att_28 := NULL;
    l_detail_old_att_29 := NULL;
    l_detail_old_att_30 := NULL;

    -- find the detail information for the current day

    hxc_timekeeper_utilities.manage_timeinfo (
     p_day_counter => (l_add_index_day + l_index_day),
     p_insert_detail => p_insert_detail,
     p_measure => l_measure,
     p_detail_id => l_detail_id,
     p_detail_ovn => l_detail_ovn,
     p_detail_time_in => l_detail_time_in,
     p_detail_time_out => l_detail_time_out
    );

    IF  p_mid_save = 'N' AND p_insert_detail.timekeeper_action = 'INSERT' THEN
     IF l_measure IS NOT NULL OR l_detail_time_in IS NOT NULL OR l_detail_time_out IS NOT NULL THEN
      p_mid_save := 'Y';
     END IF;
    END IF;
if g_debug then
	hr_utility.trace('p_mid_save '|| p_mid_save);
end if;


    IF l_detail_id IS NOT NULL THEN
     if g_debug then
             hr_utility.TRACE (' l_detail_id is '|| l_detail_id);
     end if;

--

     IF c_detail%ISOPEN THEN
      CLOSE c_detail;
     END IF;

     OPEN c_detail (l_detail_id);
     FETCH c_detail INTO c_row;

     IF c_detail%FOUND THEN

if g_debug then
        hr_utility.TRACE (' c_row is found');
end if;



      l_detail_info_found := TRUE;

      l_detail_comment_text := c_row.comment_text;

      l_detail_reason_category := 'REASON';
      if g_debug then
	      hr_utility.TRACE (' c_row.late_change is '|| c_row.late_change);
	      hr_utility.TRACE (' change_comment '|| c_row.change_comment);
      end if;
--
      l_detail_reason_att_1 := NULL;
      l_detail_reason_att_2 := NULL;
      l_detail_reason_att_3 := NULL;
      l_detail_reason_att_4 := NULL;-- JOEL c_row.dff_attr4; --left
      l_detail_reason_att_5 := NULL; -- JOEL c_row.dff_attr5;
      l_detail_reason_att_6 := NULL; ---imp
      l_detail_reason_att_7 := NULL;

      IF (c_row.late_change = 'LATE') THEN
       l_detail_reason_att_1 := c_row.late_reason;
       l_detail_reason_att_2 := c_row.late_comment;
       l_detail_reason_att_3 := 'LATE';
       l_reason_info_found   := TRUE;

       if g_debug then
                 hr_utility.TRACE (' l_reason_info_found1 ');
       end if;
      END IF;

      IF (c_row.late_change = 'CHANGE') THEN
       l_detail_reason_att_1 := c_row.change_reason;
       l_detail_reason_att_2 := c_row.change_comment;
       l_detail_reason_att_3 := 'CHANGE';
       l_reason_info_found   := TRUE;
       l_detail_reason_att_6 := c_row.audit_datetime; ---imp
       l_detail_reason_att_7 := c_row.audit_history;
       if g_debug then
               hr_utility.TRACE (' l_reason_info_found2 ');
               hr_utility.TRACE (' l_reason_info_found '|| c_row.late_change);
       end if;
      END IF;

       l_detail_reason_att_6 := c_row.audit_datetime; ---imp
       l_detail_reason_att_7 := c_row.audit_history;

       IF l_detail_reason_att_6 is not null or l_detail_reason_att_7 is not null
       THEN
         l_reason_info_found   := TRUE;
       if g_debug then
               hr_utility.TRACE (' l_reason_info_found3 ');
       end if;
       END IF;


if g_debug then
        hr_utility.TRACE (' l_detail_id is '|| l_detail_id);
end if;
--
      -- new
      l_detail_reason_att_4 := null;-- JOEL c_row.dff_attr4; --left
      l_detail_reason_att_5 := null; -- JOEL c_row.dff_attr5;

--IF l_reason_info_found THEN
if g_debug then
        hr_utility.TRACE ('l_reason_info_found');
end if;
--END IF;


      -- JOEL check if the old and new are different,
      -- if they are we need to deposit again
      l_cla_attribute_changed := FALSE;



      IF (c_row.old_late_change = 'LATE') THEN
       l_detail_old_reason_att_1 := c_row.old_late_reason;
       l_detail_old_reason_att_2 := c_row.old_late_comment;
       l_detail_old_reason_att_3 := 'LATE';
      END IF;

      IF (c_row.old_late_change = 'CHANGE') THEN
       l_detail_old_reason_att_1 := c_row.old_change_reason;
       l_detail_old_reason_att_2 := c_row.old_change_comment;
       l_detail_old_reason_att_3 := 'CHANGE';
      END IF;

      l_detail_old_reason_att_4 := null;-- JOEL c_row.dff_attr4; --left
      l_detail_old_reason_att_5 := null; -- JOELc_row.dff_attr5;
      l_detail_old_reason_att_6 := c_row.old_audit_datetime; ---imp
      l_detail_old_reason_att_7 := c_row.old_audit_history;

if g_debug then
	hr_utility.TRACE (' l_detail_reason_att_1 '||l_detail_reason_att_1);
	hr_utility.TRACE (' l_detail_reason_att_2 '||l_detail_reason_att_2);
	hr_utility.TRACE (' l_detail_reason_att_3 '||l_detail_reason_att_3);
	hr_utility.TRACE (' l_detail_reason_att_4 '||l_detail_reason_att_4);
	hr_utility.TRACE (' l_detail_reason_att_5 '||l_detail_reason_att_5);
	hr_utility.TRACE (' l_detail_reason_att_6 '||l_detail_reason_att_6);
	hr_utility.TRACE (' l_detail_reason_att_7 '||l_detail_reason_att_7);

	hr_utility.TRACE (' l_detail_old_reason_att_1 '||l_detail_old_reason_att_1);
	hr_utility.TRACE (' l_detail_old_reason_att_2 '||l_detail_old_reason_att_2);
	hr_utility.TRACE (' l_detail_old_reason_att_3 '||l_detail_old_reason_att_3);
	hr_utility.TRACE (' l_detail_old_reason_att_4 '||l_detail_old_reason_att_4);
	hr_utility.TRACE (' l_detail_old_reason_att_5 '||l_detail_old_reason_att_5);
	hr_utility.TRACE (' l_detail_old_reason_att_6 '||l_detail_old_reason_att_6);
	hr_utility.TRACE (' l_detail_old_reason_att_7 '||l_detail_old_reason_att_7);
end if;
      IF ( nvl(l_detail_reason_att_1,'xx') <> nvl(l_detail_old_reason_att_1,'xx')
        or nvl(l_detail_reason_att_2,'xx') <> nvl(l_detail_old_reason_att_2,'xx')
        or nvl(l_detail_reason_att_3,'xx') <> nvl(l_detail_old_reason_att_3,'xx')
        or nvl(l_detail_reason_att_6,'xx') <> nvl(l_detail_old_reason_att_6,'xx')
        or nvl(l_detail_reason_att_7,'xx') <> nvl(l_detail_old_reason_att_7,'xx') ) THEN

        -- the detail has changed
        -- and we need to redeposit it.
        l_cla_attribute_changed := TRUE;
if g_debug then
	hr_utility.trace('l_cla_attribute_changed');
	hr_utility.TRACE (' l_cla_attribute_changed ');
end if;
      END IF;

      l_detail_dff_found := FALSE;
      l_detail_dff_changed := FALSE;

      -- new
      l_detail_dff_category := c_row.dff_catg;
      l_detail_att_1 := c_row.dff_attr1;
      l_detail_att_2 := c_row.dff_attr2;
      l_detail_att_3 := c_row.dff_attr3;
      l_detail_att_4 := c_row.dff_attr4;
      l_detail_att_5 := c_row.dff_attr5;
      l_detail_att_6 := c_row.dff_attr6;
      l_detail_att_7 := c_row.dff_attr7;
      l_detail_att_8 := c_row.dff_attr8;
      l_detail_att_9 := c_row.dff_attr9;
      l_detail_att_10 := c_row.dff_attr10;
      l_detail_att_11 := c_row.dff_attr11;
      l_detail_att_12 := c_row.dff_attr12;
      l_detail_att_13 := c_row.dff_attr13;
      l_detail_att_14 := c_row.dff_attr14;
      l_detail_att_15 := c_row.dff_attr15;
      l_detail_att_16 := c_row.dff_attr16;
      l_detail_att_17 := c_row.dff_attr17;
      l_detail_att_18 := c_row.dff_attr18;
      l_detail_att_19 := c_row.dff_attr19;
      l_detail_att_20 := c_row.dff_attr20;
      l_detail_att_21 := c_row.dff_attr21;
      l_detail_att_22 := c_row.dff_attr22;
      l_detail_att_23 := c_row.dff_attr23;
      l_detail_att_24 := c_row.dff_attr24;
      l_detail_att_25 := c_row.dff_attr25;
      l_detail_att_26 := c_row.dff_attr26;
      l_detail_att_27 := c_row.dff_attr27;
      l_detail_att_28 := c_row.dff_attr28;
      l_detail_att_29 := c_row.dff_attr29;
      l_detail_att_30 := c_row.dff_attr30;

      -- old
      l_detail_dff_old_category := c_row.dff_oldcatg;
      l_detail_old_att_1 := c_row.dff_oldattr1;
      l_detail_old_att_2 := c_row.dff_oldattr2;
      l_detail_old_att_3 := c_row.dff_oldattr3;
      l_detail_old_att_4 := c_row.dff_oldattr4;
      l_detail_old_att_5 := c_row.dff_oldattr5;
      l_detail_old_att_6 := c_row.dff_oldattr6;
      l_detail_old_att_7 := c_row.dff_oldattr7;
      l_detail_old_att_8 := c_row.dff_oldattr8;
      l_detail_old_att_9 := c_row.dff_oldattr9;
      l_detail_old_att_10 := c_row.dff_oldattr10;
      l_detail_old_att_11 := c_row.dff_oldattr11;
      l_detail_old_att_12 := c_row.dff_oldattr12;
      l_detail_old_att_13 := c_row.dff_oldattr13;
      l_detail_old_att_14 := c_row.dff_oldattr14;
      l_detail_old_att_15 := c_row.dff_oldattr15;
      l_detail_old_att_16 := c_row.dff_oldattr16;
      l_detail_old_att_17 := c_row.dff_oldattr17;
      l_detail_old_att_18 := c_row.dff_oldattr18;
      l_detail_old_att_19 := c_row.dff_oldattr19;
      l_detail_old_att_20 := c_row.dff_oldattr20;
      l_detail_old_att_21 := c_row.dff_oldattr21;
      l_detail_old_att_22 := c_row.dff_oldattr22;
      l_detail_old_att_23 := c_row.dff_oldattr23;
      l_detail_old_att_24 := c_row.dff_oldattr24;
      l_detail_old_att_25 := c_row.dff_oldattr25;
      l_detail_old_att_26 := c_row.dff_oldattr26;
      l_detail_old_att_27 := c_row.dff_oldattr27;
      l_detail_old_att_28 := c_row.dff_oldattr28;
      l_detail_old_att_29 := c_row.dff_oldattr29;
      l_detail_old_att_30 := c_row.dff_oldattr30;


      -- now we can check everything on the dff attributes

     -- IF l_detail_id < 0 THEN
      --g_detail_data.DELETE (l_detail_id);
     -- END IF;

      IF (--l_detail_dff_category IS NULL
           l_detail_att_1 IS NULL
           AND l_detail_att_2 IS NULL
           AND l_detail_att_3 IS NULL
           AND l_detail_att_4 IS NULL
           AND l_detail_att_5 IS NULL
           AND l_detail_att_6 IS NULL
           AND l_detail_att_7 IS NULL
           AND l_detail_att_8 IS NULL
           AND l_detail_att_9 IS NULL
           AND l_detail_att_10 IS NULL
           AND l_detail_att_11 IS NULL
           AND l_detail_att_12 IS NULL
           AND l_detail_att_13 IS NULL
           AND l_detail_att_14 IS NULL
           AND l_detail_att_15 IS NULL
           AND l_detail_att_16 IS NULL
           AND l_detail_att_17 IS NULL
           AND l_detail_att_18 IS NULL
           AND l_detail_att_19 IS NULL
           AND l_detail_att_20 IS NULL
           AND l_detail_att_21 IS NULL
           AND l_detail_att_22 IS NULL
           AND l_detail_att_23 IS NULL
           AND l_detail_att_24 IS NULL
           AND l_detail_att_25 IS NULL
           AND l_detail_att_26 IS NULL
           AND l_detail_att_27 IS NULL
           AND l_detail_att_28 IS NULL
           AND l_detail_att_29 IS NULL
           AND l_detail_att_30 IS NULL
          ) THEN

          l_detail_dff_found := FALSE;
/*ADVICE(5706): Use of NULL statements [532] */
if g_debug then
        hr_utility.trace('NOT l_detail_dff_found');
end if;
       ELSE
          l_detail_dff_found := TRUE;
if g_debug then
      hr_utility.trace('l_detail_dff_found');
end if;
       END IF;

       -- at this point we need to handle the attribute case
       IF  (l_detail_dff_old_category IS NOT NULL
       AND not(l_detail_dff_found)) THEN
        -- that mean we need to reset the l_detail_dff_found to TRUE
        l_detail_dff_found := TRUE;
if g_debug then
        hr_utility.trace('l_detail_dff_found');
end if;
       END IF;




       IF valid_att_cat IS NOT NULL THEN
        IF NVL (valid_att_cat, '-999') <> NVL (l_detail_dff_category, '-999') THEN
         l_detail_dff_category := valid_att_cat;
        END IF;
      -- ELSE
        --l_detail_dff_category := l_detail_dff_category;
       END IF;
if g_debug then
        hr_utility.trace(l_detail_dff_category);
end if;
       IF ( (NVL (l_detail_dff_category, '-999') <> NVL (l_detail_dff_old_category, '-999')
                OR NVL (l_detail_att_1, '-999') <> NVL (l_detail_old_att_1, '-999')
                OR NVL (l_detail_att_2, '-999') <> NVL (l_detail_old_att_2, '-999')
                OR NVL (l_detail_att_3, '-999') <> NVL (l_detail_old_att_3, '-999')
                OR NVL (l_detail_att_4, '-999') <> NVL (l_detail_old_att_4, '-999')
                OR NVL (l_detail_att_5, '-999') <> NVL (l_detail_old_att_5, '-999')
                OR NVL (l_detail_att_6, '-999') <> NVL (l_detail_old_att_6, '-999')
                OR NVL (l_detail_att_7, '-999') <> NVL (l_detail_old_att_7, '-999')
                OR NVL (l_detail_att_8, '-999') <> NVL (l_detail_old_att_8, '-999')
                OR NVL (l_detail_att_9, '-999') <> NVL (l_detail_old_att_9, '-999')
                OR NVL (l_detail_att_10, '-999') <> NVL (l_detail_old_att_10, '-999')
                OR NVL (l_detail_att_11, '-999') <> NVL (l_detail_old_att_11, '-999')
                OR NVL (l_detail_att_12, '-999') <> NVL (l_detail_old_att_12, '-999')
                OR NVL (l_detail_att_13, '-999') <> NVL (l_detail_old_att_13, '-999')
                OR NVL (l_detail_att_14, '-999') <> NVL (l_detail_old_att_14, '-999')
                OR NVL (l_detail_att_15, '-999') <> NVL (l_detail_old_att_15, '-999')
                OR NVL (l_detail_att_16, '-999') <> NVL (l_detail_old_att_16, '-999')
                OR NVL (l_detail_att_17, '-999') <> NVL (l_detail_old_att_17, '-999')
                OR NVL (l_detail_att_18, '-999') <> NVL (l_detail_old_att_18, '-999')
                OR NVL (l_detail_att_19, '-999') <> NVL (l_detail_old_att_19, '-999')
                OR NVL (l_detail_att_20, '-999') <> NVL (l_detail_old_att_20, '-999')
                OR NVL (l_detail_att_21, '-999') <> NVL (l_detail_old_att_21, '-999')
                OR NVL (l_detail_att_22, '-999') <> NVL (l_detail_old_att_22, '-999')
                OR NVL (l_detail_att_23, '-999') <> NVL (l_detail_old_att_23, '-999')
                OR NVL (l_detail_att_24, '-999') <> NVL (l_detail_old_att_24, '-999')
                OR NVL (l_detail_att_25, '-999') <> NVL (l_detail_old_att_25, '-999')
                OR NVL (l_detail_att_26, '-999') <> NVL (l_detail_old_att_26, '-999')
                OR NVL (l_detail_att_27, '-999') <> NVL (l_detail_old_att_27, '-999')
                OR NVL (l_detail_att_28, '-999') <> NVL (l_detail_old_att_28, '-999')
                OR NVL (l_detail_att_29, '-999') <> NVL (l_detail_old_att_29, '-999')
                OR NVL (l_detail_att_30, '-999') <> NVL (l_detail_old_att_30, '-999'))
              AND l_detail_dff_found
               ) THEN
       l_detail_dff_changed := TRUE;
if g_debug then
        hr_utility.trace('l_detail_dff_changed');
end if;
      ELSE
       l_detail_dff_changed := FALSE;
if g_debug then
        hr_utility.trace('not l_detail_dff_changed');
end if;
      END IF;

     DELETE FROM hxc_tk_detail_temp
     WHERE       detailid = l_detail_id;

     END IF;

    ELSE
     if g_debug then
             hr_utility.TRACE ('nothign to change');
     end if;
      l_detail_info_found := FALSE;

    END IF;


if g_debug then
        hr_utility.trace('l_action'||l_action);
end if;
    -- detail block is not changed
    l_detail_changed := 'N';

    IF l_action = 'QUERY' THEN -- do anything
     NULL;
/*ADVICE(5594): Use of NULL statements [532] */

    ELSIF l_action = 'INSERT' THEN

     -- the easy one just attach the new information on the  timecard/attributes structure.
     -- add the detail only if the measure has been filled.
     IF (l_measure IS NOT NULL OR l_detail_time_in IS NOT NULL OR l_detail_time_out IS NOT NULL) THEN
      -- add the detail information.
      g_negative_index := g_negative_index - 1;

      /*Bug 9014012*/

      l_found:= 'N';

      LOOP
      l_tmp_index:= g_negative_index * -1;
      if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

       	g_negative_index := g_negative_index - 1;
           l_found:= 'N';

      else

           l_found:='Y';

      end if;

      EXIT WHEN l_found = 'Y';
      END LOOP;


      l_detail_id := g_negative_index;
      l_detail_ovn := 1; ---added for new deposit

      IF l_detail_time_in > l_detail_time_out THEN
       l_detail_time_out := l_detail_time_out + 1;
      END IF;

      hxc_timekeeper_utilities.add_block (
       p_timecard => p_timecard,
       p_timecard_id => l_detail_id,
       p_ovn => l_detail_ovn,
       p_parent_id => p_day_id_info_table (l_index_day).day_id,
       p_parent_ovn => p_day_id_info_table (l_index_day).day_ovn,
       p_approval_style_id => p_approval_style_id,
       p_measure => l_measure,
       p_scope => 'DETAIL',
       p_date_to => hr_general.end_of_time,
       p_date_from => SYSDATE,
       p_start_period => l_detail_time_in,
       p_end_period => l_detail_time_out,
       p_resource_id => p_resource_id,
       p_changed => 'Y',
       p_comment_text => l_detail_comment_text,
       p_submit_flg => g_submit,
       p_application_set_id => l_application_set_id,
       p_timecard_index_info => p_timecard_index_info
      );

      -- add the attribute information.

      FOR l_index_attribute IN 1 .. 20 LOOP

       hxc_timekeeper_utilities.manage_attributes (
        p_attribute_number => l_index_attribute,
        p_insert_data_details => p_insert_detail,
        p_old_value => l_old_attribute_value,
        p_new_value => l_new_attribute_value
       );

       IF  (l_new_attribute_value IS NOT NULL)
        AND p_att_tab.EXISTS (l_index_attribute) THEN --2786991

        hxc_timekeeper_process.g_negative_index := hxc_timekeeper_process.g_negative_index - 1;

        /*Bug 9014012*/

	 l_found:= 'N';

	 LOOP
	 l_tmp_index:= hxc_timekeeper_process.g_negative_index * -1;
	 if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

	  	hxc_timekeeper_process.g_negative_index:=
	  	                    hxc_timekeeper_process.g_negative_index - 1;
	      l_found:= 'N';

	 else

	      l_found:='Y';

	 end if;

	 EXIT WHEN l_found = 'Y';
         END LOOP;


        hxc_timekeeper_utilities.add_attribute (
         p_attribute => p_attributes,
         p_attribute_id => hxc_timekeeper_process.g_negative_index,
         p_tbb_id => l_detail_id,
         p_tbb_ovn => l_detail_ovn,
         p_blk_type => 'OTL_ALIAS_ITEM_' || l_index_attribute,
         p_blk_id => NULL,
         p_att_category => 'OTL_ALIAS_ITEM_' || l_index_attribute,
         p_att_1 => l_new_attribute_value,
         p_att_2 => p_att_tab (l_index_attribute).alias_definition_id,
         p_att_3 => l_old_attribute_value,
         p_att_4 => p_att_tab (l_index_attribute).alias_type,
         p_attribute_index_info => p_attribute_index_info
        );
       END IF;
      END LOOP;
/*ADVICE(5663): Nested LOOPs should all be labeled [406] */


      --add detail info
      IF l_detail_info_found and l_detail_dff_found THEN
        if g_debug then
                hr_utility.TRACE ('DETAILDFFFOUND');
        end if;
        -- add the dff detail
        g_negative_index := g_negative_index - 1;

        /*Bug 9014012*/

	l_found:= 'N';

	LOOP
	l_tmp_index:= g_negative_index * -1;
	if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

	 	g_negative_index := g_negative_index - 1;
	     l_found:= 'N';

	else

	     l_found:='Y';

	end if;

	EXIT WHEN l_found = 'Y';
   	END LOOP;


        l_attribute_index := g_negative_index;

        hxc_timekeeper_utilities.add_dff_attribute (
         p_attribute => p_attributes,
         p_attribute_id => g_negative_index,
         p_tbb_id => l_detail_id,
         p_tbb_ovn => l_detail_ovn,
         p_blk_type => 'Dummy Paexpitdff Context',
         p_blk_id => bldtyp_id,
         p_att_category => l_detail_dff_category,
         p_att_1 => l_detail_att_1,
         p_att_2 => l_detail_att_2,
         p_att_3 => l_detail_att_3,
         p_att_4 => l_detail_att_4,
         p_att_5 => l_detail_att_5,
         p_att_6 => l_detail_att_6,
         p_att_7 => l_detail_att_7,
         p_att_8 => l_detail_att_8,
         p_att_9 => l_detail_att_9,
         p_att_10 => l_detail_att_10,
         p_att_11 => l_detail_att_11,
         p_att_12 => l_detail_att_12,
         p_att_13 => l_detail_att_13,
         p_att_14 => l_detail_att_14,
         p_att_15 => l_detail_att_15,
         p_att_16 => l_detail_att_16,
         p_att_17 => l_detail_att_17,
         p_att_18 => l_detail_att_18,
         p_att_19 => l_detail_att_19,
         p_att_20 => l_detail_att_20,
         p_att_21 => l_detail_att_21,
         p_att_22 => l_detail_att_22,
         p_att_23 => l_detail_att_23,
         p_att_24 => l_detail_att_24,
         p_att_25 => l_detail_att_25,
         p_att_26 => l_detail_att_26,
         p_att_27 => l_detail_att_27,
         p_att_28 => l_detail_att_28,
         p_att_29 => l_detail_att_29,
         p_att_30 => l_detail_att_30,
         p_attribute_index_info => p_attribute_index_info
        );


      END IF;

      IF l_detail_info_found and l_reason_info_found THEN

        g_negative_index := g_negative_index - 1;

        /*Bug 9014012*/

	l_found:= 'N';

	LOOP
	l_tmp_index:= g_negative_index * -1;
	if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

	 	g_negative_index := g_negative_index - 1;
	     l_found:= 'N';

	else

	     l_found:='Y';

	end if;

	EXIT WHEN l_found = 'Y';
   	END LOOP;



        if g_debug then
                hr_utility.TRACE ('DETAILREASONFOUND');
        end if;
--                    g_negative_index :=   g_negative_index;
-- the above statement can be mutually exclusive..check out

        l_attribute_index := g_negative_index;
        hxc_timekeeper_utilities.add_dff_attribute (
         p_attribute => p_attributes,
         p_attribute_id => g_negative_index,
         p_tbb_id => l_detail_id,
         p_tbb_ovn => l_detail_ovn,
         p_blk_type => 'REASON', --ctk
         p_blk_id => reason_bldtyp_id, --ctk
         p_att_category => l_detail_reason_category,
         p_att_1 => l_detail_reason_att_1,
         p_att_2 => l_detail_reason_att_2,
         p_att_3 => l_detail_reason_att_3,
         p_att_4 => l_detail_reason_att_4,
         p_att_5 => l_detail_reason_att_5,
         p_att_6 => l_detail_reason_att_6,
         p_att_7 => l_detail_reason_att_7,
         p_att_8 => NULL,
         p_att_9 => NULL,
         p_att_10 => NULL,
         p_att_11 => NULL,
         p_att_12 => NULL,
         p_att_13 => NULL,
         p_att_14 => NULL,
         p_att_15 => NULL,
         p_att_16 => NULL,
         p_att_17 => NULL,
         p_att_18 => NULL,
         p_att_19 => NULL,
         p_att_20 => NULL,
         p_att_21 => NULL,
         p_att_22 => NULL,
         p_att_23 => NULL,
         p_att_24 => NULL,
         p_att_25 => NULL,
         p_att_26 => NULL,
         p_att_27 => NULL,
         p_att_28 => NULL,
         p_att_29 => NULL,
         p_att_30 => NULL,
         p_attribute_index_info => p_attribute_index_info
        );
      END IF;

     END IF;

    ELSIF l_action = 'UPDATE' THEN


     IF      (l_measure IS NOT NULL OR l_detail_time_in IS NOT NULL OR l_detail_time_out IS NOT NULL)
         AND l_detail_id IS NOT NULL
         AND l_detail_id > 0 THEN
      -- we are on an existing block
      -- update the detail information with the new measure

              if g_debug then
	              hr_utility.trace('SVG - 1');
               end if;


      IF l_detail_time_in > l_detail_time_out THEN
       l_detail_time_out := l_detail_time_out + 1;
      END IF;

      -- work on the attribute information.

      FOR l_index_attribute IN 1 .. 20 LOOP

       hxc_timekeeper_utilities.manage_attributes (
        p_attribute_number => l_index_attribute,
        p_insert_data_details => p_insert_detail,
        p_old_value => l_old_attribute_value,
        p_new_value => l_new_attribute_value
       );

       IF  p_att_tab.EXISTS (l_index_attribute)
       AND ((l_new_attribute_value is not null and l_old_attribute_value is not null
        and l_old_attribute_value <>  l_new_attribute_value)
	/* start of fix for 5398047
        OR (l_new_attribute_value is null and l_old_attribute_value is null)
	 end of fix for 5398047 */
        OR (l_new_attribute_value is null and l_old_attribute_value is not null)
        OR (l_new_attribute_value is not null and l_old_attribute_value is null))
        THEN --2786991
        --IF NVL (l_new_attribute_value, -1) <> NVL (l_old_attribute_value, -1)  THEN
        hxc_timekeeper_process.g_negative_index := hxc_timekeeper_process.g_negative_index - 1;

        /*Bug 9014012*/

	l_found:= 'N';

	LOOP
	l_tmp_index:= hxc_timekeeper_process.g_negative_index * -1;
	if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

	 	hxc_timekeeper_process.g_negative_index := hxc_timekeeper_process.g_negative_index - 1;
	     l_found:= 'N';

	else

	     l_found:='Y';

	end if;

	EXIT WHEN l_found = 'Y';
   	END LOOP;



        if g_debug then
                hr_utility.trace('l_detail_changed1 '||l_detail_changed);
        end if;
        IF  l_detail_changed <> 'Y' THEN
            l_detail_changed := 'Y';

        if g_debug then
                hr_utility.trace('l_detail_changed1 '||l_detail_changed);
        end if;
        END IF;

        hxc_timekeeper_utilities.add_attribute (
         p_attribute => p_attributes,
         p_attribute_id => g_negative_index,
         p_tbb_id => l_detail_id,
         p_tbb_ovn => l_detail_ovn,
         p_blk_type => 'OTL_ALIAS_ITEM_' || l_index_attribute,
         p_blk_id => NULL,
         p_att_category => 'OTL_ALIAS_ITEM_' || l_index_attribute,
         p_att_1 => l_new_attribute_value,
         p_att_2 => p_att_tab (l_index_attribute).alias_definition_id,
         p_att_3 => l_old_attribute_value,
         p_att_4 => p_att_tab (l_index_attribute).alias_type,
         p_attribute_index_info => p_attribute_index_info
        );
       END IF;
      END LOOP;
/*ADVICE(5889): Nested LOOPs should all be labeled [406] */

      -- first we can set the flag if one of the dff att
      -- or cla attributes changed.
      IF (l_detail_info_found and l_detail_dff_changed and NVL (bldtyp_id, -999) <> -999)
      OR (l_detail_info_found AND l_reason_info_found AND l_cla_attribute_changed
      AND NVL (reason_bldtyp_id, -999) <> -999) THEN

         l_detail_changed := 'Y';
      if g_debug then
              hr_utility.trace('l_detail_changed2 '||l_detail_changed);
      end if;
      END IF;
      if g_debug then
              hr_utility.trace('l_detail_changed 3'||l_detail_changed);
      end if;


      hxc_timekeeper_utilities.add_block (
       p_timecard => p_timecard,
       p_timecard_id => l_detail_id,
       p_ovn => l_detail_ovn,
       p_parent_id => p_day_id_info_table (l_index_day).day_id,
       p_parent_ovn => p_day_id_info_table (l_index_day).day_ovn,
       p_approval_style_id => p_approval_style_id,
       p_measure => l_measure,
       p_scope => 'DETAIL',
       p_date_to => hr_general.end_of_time,
       p_date_from => SYSDATE,
       p_start_period => l_detail_time_in,
       p_end_period => l_detail_time_out,
       p_resource_id => p_resource_id,
       p_changed => l_detail_changed,
       p_comment_text => l_detail_comment_text,
       p_submit_flg => g_submit,
       p_application_set_id => l_application_set_id,
       p_timecard_index_info => p_timecard_index_info
      );

      -- check the detail changed flag again


      IF  l_detail_info_found and l_detail_dff_changed
      AND NVL (bldtyp_id, -999) <> -999 THEN  -- and l_detail_dff_found THEN

         l_attribute_found := FALSE;
         --l_attribute_index :=
         hxc_alias_utility.attribute_check (
          p_bld_blk_info_type_id => bldtyp_id,
          p_time_building_block_id => l_detail_id,
          p_attributes => p_attributes,
          p_tbb_id_reference_table => l_tbb_id_reference_table,
          p_attribute_found => l_attribute_found,
          p_attribute_index => l_attribute_index
         );

         -- now we need to check if we need to create an attribute or do an update

         -- if l_attribute_index = -1 THEN
         IF NOT (l_attribute_found) THEN
          g_negative_index := g_negative_index - 1;

          /*Bug 9014012*/

	  l_found:= 'N';

	  LOOP
	  l_tmp_index:= g_negative_index * -1;
	  if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

	   	g_negative_index := g_negative_index - 1;
	       l_found:= 'N';

	  else

	       l_found:='Y';

	  end if;

	  EXIT WHEN l_found = 'Y';
   	  END LOOP;


          l_attribute_index := g_negative_index;
         ELSE
          l_attribute_index := p_attributes (l_attribute_index).time_attribute_id;
         END IF;

          hxc_timekeeper_utilities.add_dff_attribute (
           p_attribute => p_attributes,
           p_attribute_id => l_attribute_index,
           p_tbb_id => l_detail_id,
           p_tbb_ovn => l_detail_ovn,
           p_blk_type => 'Dummy Paexpitdff Context',
           p_blk_id => bldtyp_id,
           p_att_category => l_detail_dff_category,
           p_att_1 => l_detail_att_1,
           p_att_2 => l_detail_att_2,
           p_att_3 => l_detail_att_3,
           p_att_4 => l_detail_att_4,
           p_att_5 => l_detail_att_5,
           p_att_6 => l_detail_att_6,
           p_att_7 => l_detail_att_7,
           p_att_8 => l_detail_att_8,
           p_att_9 => l_detail_att_9,
           p_att_10 => l_detail_att_10,
           p_att_11 => l_detail_att_11,
           p_att_12 => l_detail_att_12,
           p_att_13 => l_detail_att_13,
           p_att_14 => l_detail_att_14,
           p_att_15 => l_detail_att_15,
           p_att_16 => l_detail_att_16,
           p_att_17 => l_detail_att_17,
           p_att_18 => l_detail_att_18,
           p_att_19 => l_detail_att_19,
           p_att_20 => l_detail_att_20,
           p_att_21 => l_detail_att_21,
           p_att_22 => l_detail_att_22,
           p_att_23 => l_detail_att_23,
           p_att_24 => l_detail_att_24,
           p_att_25 => l_detail_att_25,
           p_att_26 => l_detail_att_26,
           p_att_27 => l_detail_att_27,
           p_att_28 => l_detail_att_28,
           p_att_29 => l_detail_att_29,
           p_att_30 => l_detail_att_30,
           p_attribute_index_info => p_attribute_index_info
          );

          -- add the new attribute in the ref table

          IF l_tbb_id_reference_table.EXISTS ( --4
                                              l_detail_id) THEN

           l_tbb_id_reference_table (l_detail_id).attribute_index :=
                         l_tbb_id_reference_table (l_detail_id).attribute_index || '|' || l_attribute_index;
          ELSE
           l_tbb_id_reference_table (l_detail_id).attribute_index := '|' || l_attribute_index;
          END IF; --4
         END IF; --3
-----------------------

       IF  l_detail_info_found AND l_reason_info_found AND l_cla_attribute_changed
       AND NVL (reason_bldtyp_id, -999) <> -999 THEN

         l_attribute_found := FALSE;
         --l_attribute_index :=
         hxc_alias_utility.attribute_check (
          p_bld_blk_info_type_id => reason_bldtyp_id, --pass reason info type id
          p_time_building_block_id => l_detail_id,
          p_attributes => p_attributes,
          p_tbb_id_reference_table => l_tbb_id_reference_table,
          p_attribute_found => l_attribute_found,
          p_attribute_index => l_attribute_index
         );

         -- now we need to check if we need to create an attribute or do an update
         IF NOT (l_attribute_found) THEN
          g_negative_index := g_negative_index - 1;

          /*Bug 9014012*/

	  l_found:= 'N';

	  LOOP
	  l_tmp_index:= g_negative_index * -1;
	  if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

	   	g_negative_index := g_negative_index - 1;
	       l_found:= 'N';

	  else

	       l_found:='Y';

	  end if;

	  EXIT WHEN l_found = 'Y';
   	  END LOOP;


          l_attribute_index := g_negative_index;
         ELSE
          l_attribute_index := p_attributes (l_attribute_index).time_attribute_id;
         END IF;


         hxc_timekeeper_utilities.add_dff_attribute (
           p_attribute => p_attributes,
           p_attribute_id => l_attribute_index,
           p_tbb_id => l_detail_id,
           p_tbb_ovn => l_detail_ovn,
           p_blk_type => 'REASON',
           p_blk_id => reason_bldtyp_id,
           p_att_category => l_detail_reason_category,
           p_att_1 => l_detail_reason_att_1,
           p_att_2 => l_detail_reason_att_2,
           p_att_3 => l_detail_reason_att_3,
           p_att_4 => l_detail_reason_att_4,
           p_att_5 => l_detail_reason_att_5,
           p_att_6 => l_detail_reason_att_6,
           p_att_7 => l_detail_reason_att_7,
           p_att_8 => NULL,
           p_att_9 => NULL,
           p_att_10 => NULL,
           p_att_11 => NULL,
           p_att_12 => NULL,
           p_att_13 => NULL,
           p_att_14 => NULL,
           p_att_15 => NULL,
           p_att_16 => NULL,
           p_att_17 => NULL,
           p_att_18 => NULL,
           p_att_19 => NULL,
           p_att_20 => NULL,
           p_att_21 => NULL,
           p_att_22 => NULL,
           p_att_23 => NULL,
           p_att_24 => NULL,
           p_att_25 => NULL,
           p_att_26 => NULL,
           p_att_27 => NULL,
           p_att_28 => NULL,
           p_att_29 => NULL,
           p_att_30 => NULL,
           p_attribute_index_info => p_attribute_index_info
          );

          -- add the new attribute in the ref table

          IF l_tbb_id_reference_table.EXISTS ( --4
                                              l_detail_id) THEN

           l_tbb_id_reference_table (l_detail_id).attribute_index :=
                         l_tbb_id_reference_table (l_detail_id).attribute_index || '|' || l_attribute_index;
          ELSE
           l_tbb_id_reference_table (l_detail_id).attribute_index := '|' || l_attribute_index;
          END IF; --4
-----------------------
       END IF; --detail is found  --1

     ELSIF      (l_measure IS NOT NULL OR l_detail_time_in IS NOT NULL OR l_detail_time_out IS NOT NULL)
            AND (l_detail_id IS NULL OR l_detail_id < 0) THEN
      -- new block the block the detail information with the new measure
           -- add the detail information.
      g_negative_index := g_negative_index - 1;


      /* Added for bug 8775740
            HR OTL Absence Integration.

            Ensuring that g_negative_index doesnt hold values which are already in
            g_tk_prepop_detail_id_tab which holds the detail ids of the prepopulated
            tbbs.

            If tbb already has a negative detail id prepopulated, ensure that
            the detail_id is used for tbbid

      */
      -- Change start
      --l_detail_id := g_negative_index;

      l_found:= 'N';

            LOOP
               l_tmp_index:= g_negative_index * -1;
               if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

                 g_negative_index := g_negative_index - 1;
                 l_found:= 'N';

               else

                 l_found:='Y';

               end if;

            EXIT WHEN l_found = 'Y';
            END LOOP;


            l_detail_id := nvl(l_detail_id,g_negative_index);

            if g_debug then
                    hr_utility.trace('HERE');
            end if;

                     if g_debug then
            	              hr_utility.trace('SVG - 2');
                     end if;

       -- Change end
      if g_debug then
        hr_utility.trace('l_detail_id = '||l_detail_id);
      end if;

      if g_debug then
              hr_utility.trace('HERE');
      end if;
      IF l_detail_time_in > l_detail_time_out THEN
       l_detail_time_out := l_detail_time_out + 1;
      END IF;

      if g_debug then
      hr_utility.trace('before add_block');
      end if;

      hxc_timekeeper_utilities.add_block (
       p_timecard => p_timecard,
       p_timecard_id => l_detail_id,
       p_ovn => l_detail_ovn,
       p_parent_id => p_day_id_info_table (l_index_day).day_id,
       p_parent_ovn => p_day_id_info_table (l_index_day).day_ovn,
       p_approval_style_id => p_approval_style_id,
       p_measure => l_measure,
       p_scope => 'DETAIL',
       p_date_to => hr_general.end_of_time,
       p_date_from => SYSDATE,
       p_start_period => l_detail_time_in,
       p_end_period => l_detail_time_out,
       p_resource_id => p_resource_id,
       p_changed => 'Y',
       p_comment_text => l_detail_comment_text,
       p_submit_flg => g_submit,
       p_application_set_id => l_application_set_id,
       p_timecard_index_info => p_timecard_index_info
      );

      if g_debug then
      hr_utility.trace('after add_block');
      end if;

      FOR l_index_attribute IN 1 .. 20 LOOP
       hxc_timekeeper_utilities.manage_attributes (
        p_attribute_number => l_index_attribute,
        p_insert_data_details => p_insert_detail,
        p_old_value => l_old_attribute_value,
        p_new_value => l_new_attribute_value
       );

        if g_debug then
        hr_utility.trace('after manage attributes');
        end if;

       IF  l_new_attribute_value IS NOT NULL AND p_att_tab.EXISTS (l_index_attribute) THEN --2786991

        hxc_timekeeper_process.g_negative_index := hxc_timekeeper_process.g_negative_index - 1;

        /*Bug 9014012*/

	l_found:= 'N';

	LOOP
	l_tmp_index:= hxc_timekeeper_process.g_negative_index * -1;
	if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

	 	hxc_timekeeper_process.g_negative_index := hxc_timekeeper_process.g_negative_index - 1;
	     l_found:= 'N';

	else

	     l_found:='Y';

	end if;

	EXIT WHEN l_found = 'Y';
        END LOOP;


        if g_debug then
        hr_utility.trace('before add attribute');
	hr_utility.trace('g_negative_index = '||hxc_timekeeper_process.g_negative_index);
        end if;

        hxc_timekeeper_utilities.add_attribute (
         p_attribute => p_attributes,
         p_attribute_id => g_negative_index,
         p_tbb_id => l_detail_id,
         p_tbb_ovn => l_detail_ovn,
         p_blk_type => 'OTL_ALIAS_ITEM_' || l_index_attribute,
         p_blk_id => NULL,
         p_att_category => 'OTL_ALIAS_ITEM_' || l_index_attribute,
         p_att_1 => l_new_attribute_value,
         p_att_2 => p_att_tab (l_index_attribute).alias_definition_id,
         p_att_3 => l_old_attribute_value,
         p_att_4 => p_att_tab (l_index_attribute).alias_type,
         p_attribute_index_info => p_attribute_index_info
        );

        if g_debug then
        hr_utility.trace('after add attribute');
        end if;

       END IF;
      END LOOP;
      --left

      IF l_detail_info_found and l_reason_info_found THEN
        if g_debug then
                hr_utility.trace('HERE 1 RESSON');
        end if;
        g_negative_index := g_negative_index - 1;

        /*Bug 9014012*/

	l_found:= 'N';

	LOOP
	l_tmp_index:= g_negative_index * -1;
	if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

	 	g_negative_index := g_negative_index - 1;
	     l_found:= 'N';

	else

	     l_found:='Y';

	end if;

	EXIT WHEN l_found = 'Y';
  	END LOOP;


        l_attribute_index := g_negative_index;
        if g_debug then
                hr_utility.trace(l_attribute_index);
        end if;
        hxc_timekeeper_utilities.add_dff_attribute (
         p_attribute => p_attributes,
         p_attribute_id => g_negative_index,
         p_tbb_id => l_detail_id,
         p_tbb_ovn => l_detail_ovn,
         p_blk_type => 'REASON', --ctk
         p_blk_id => reason_bldtyp_id, --ctk
         p_att_category => l_detail_reason_category,
         p_att_1 => l_detail_reason_att_1,
         p_att_2 => l_detail_reason_att_2,
         p_att_3 => l_detail_reason_att_3,
         p_att_4 => l_detail_reason_att_4,
         p_att_5 => l_detail_reason_att_5,
         p_att_6 => l_detail_reason_att_6,
         p_att_7 => l_detail_reason_att_7,
         p_att_8 => NULL,
         p_att_9 => NULL,
         p_att_10 => NULL,
         p_att_11 => NULL,
         p_att_12 => NULL,
         p_att_13 => NULL,
         p_att_14 => NULL,
         p_att_15 => NULL,
         p_att_16 => NULL,
         p_att_17 => NULL,
         p_att_18 => NULL,
         p_att_19 => NULL,
         p_att_20 => NULL,
         p_att_21 => NULL,
         p_att_22 => NULL,
         p_att_23 => NULL,
         p_att_24 => NULL,
         p_att_25 => NULL,
         p_att_26 => NULL,
         p_att_27 => NULL,
         p_att_28 => NULL,
         p_att_29 => NULL,
         p_att_30 => NULL,
         p_attribute_index_info => p_attribute_index_info
        );
      END IF;

      IF l_detail_info_found and l_detail_dff_found THEN
        if g_debug then
                hr_utility.trace('HERE 2');
                hr_utility.trace(l_attribute_index);
        end if;
        g_negative_index := g_negative_index - 1;

        /*Bug 9014012*/

	l_found:= 'N';

	LOOP
	l_tmp_index:= g_negative_index * -1;
	if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

	 	g_negative_index := g_negative_index - 1;
	     l_found:= 'N';

	else

	     l_found:='Y';

	end if;

	EXIT WHEN l_found = 'Y';
   	END LOOP;

        l_attribute_index := g_negative_index;

        hxc_timekeeper_utilities.add_dff_attribute (
         p_attribute => p_attributes,
         p_attribute_id => g_negative_index,
         p_tbb_id => l_detail_id,
         p_tbb_ovn => l_detail_ovn,
         p_blk_type => 'Dummy Paexpitdff Context',
         p_blk_id => bldtyp_id,
         p_att_category => l_detail_dff_category,
         p_att_1 => l_detail_att_1,
         p_att_2 => l_detail_att_2,
         p_att_3 => l_detail_att_3,
         p_att_4 => l_detail_att_4,
         p_att_5 => l_detail_att_5,
         p_att_6 => l_detail_att_6,
         p_att_7 => l_detail_att_7,
         p_att_8 => l_detail_att_8,
         p_att_9 => l_detail_att_9,
         p_att_10 => l_detail_att_10,
         p_att_11 => l_detail_att_11,
         p_att_12 => l_detail_att_12,
         p_att_13 => l_detail_att_13,
         p_att_14 => l_detail_att_14,
         p_att_15 => l_detail_att_15,
         p_att_16 => l_detail_att_16,
         p_att_17 => l_detail_att_17,
         p_att_18 => l_detail_att_18,
         p_att_19 => l_detail_att_19,
         p_att_20 => l_detail_att_20,
         p_att_21 => l_detail_att_21,
         p_att_22 => l_detail_att_22,
         p_att_23 => l_detail_att_23,
         p_att_24 => l_detail_att_24,
         p_att_25 => l_detail_att_25,
         p_att_26 => l_detail_att_26,
         p_att_27 => l_detail_att_27,
         p_att_28 => l_detail_att_28,
         p_att_29 => l_detail_att_29,
         p_att_30 => l_detail_att_30,
         p_attribute_index_info => p_attribute_index_info
        );

      END IF;

     ELSIF      (l_measure IS NULL OR (l_detail_time_in IS NULL AND l_detail_time_out IS NULL))
            AND (l_detail_id IS NOT NULL AND l_detail_id > 0) THEN
      -- terminate the block the detail information with the new measure

               if g_debug then
            	              hr_utility.trace('SVG - 3');
                     end if;

      hxc_timekeeper_utilities.add_block (
       p_timecard => p_timecard,
       p_timecard_id => l_detail_id,
       p_ovn => l_detail_ovn,
       p_parent_id => p_day_id_info_table (l_index_day).day_id,
       p_parent_ovn => p_day_id_info_table (l_index_day).day_ovn,
       p_approval_style_id => p_approval_style_id,
       p_measure => l_measure,
       p_scope => 'DETAIL',
       p_date_to => SYSDATE,
       p_date_from => NULL,
       p_start_period => l_detail_time_in, --p_start_period + l_index_day,
       p_end_period => l_detail_time_out, --p_start_period + l_index_day + g_one_day,
       p_resource_id => p_resource_id,
       p_changed => 'Y',
       p_comment_text => l_detail_comment_text,
       p_submit_flg => g_submit,
       p_application_set_id => l_application_set_id,
       p_timecard_index_info => p_timecard_index_info
      );

      IF (p_tk_audit_enabled = 'Y') THEN

         l_attribute_found := FALSE;
         --l_attribute_index :=
         hxc_alias_utility.attribute_check (
          p_bld_blk_info_type_id => reason_bldtyp_id,
          p_time_building_block_id => l_detail_id,
          p_attributes => p_attributes,
          p_tbb_id_reference_table => l_tbb_id_reference_table,
          p_attribute_found => l_attribute_found,
          p_attribute_index => l_attribute_index
         );

         -- now we need to check if we need to create an attribute or do an update

         -- if l_attribute_index = -1 THEN
         IF NOT (l_attribute_found) THEN
          g_negative_index := g_negative_index - 1;

          /*Bug 9014012*/

	  l_found:= 'N';

	  LOOP
	  l_tmp_index:= g_negative_index * -1;
	  if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

	   	g_negative_index := g_negative_index - 1;
	       l_found:= 'N';

	  else

	       l_found:='Y';

	  end if;

	  EXIT WHEN l_found = 'Y';
   	  END LOOP;

          l_attribute_index := g_negative_index;
         ELSE
          l_attribute_index := p_attributes (l_attribute_index).time_attribute_id;
         END IF;

         hxc_timekeeper_utilities.add_dff_attribute (
	        p_attribute => p_attributes,
	        p_attribute_id => l_attribute_index,
	        p_tbb_id => l_detail_id,
	        p_tbb_ovn => l_detail_ovn,
	        p_blk_type => 'REASON', --ctk
	        p_blk_id => reason_bldtyp_id, --ctk
	        p_att_category => 'REASON',
	        p_att_1 => 'TK_DEL_CHANGE_REASON',
	        p_att_2 => NULL,
	        p_att_3 => 'CHANGE',
	        p_att_4 => NULL,
	        p_att_5 => NULL,
	        p_att_6 => NULL,
	        p_att_7 => NULL,
	        p_att_8 => NULL,
	        p_att_9 => NULL,
	        p_att_10 => NULL,
	        p_att_11 => NULL,
	        p_att_12 => NULL,
	        p_att_13 => NULL,
	        p_att_14 => NULL,
	        p_att_15 => NULL,
	        p_att_16 => NULL,
	        p_att_17 => NULL,
	        p_att_18 => NULL,
	        p_att_19 => NULL,
	        p_att_20 => NULL,
	        p_att_21 => NULL,
	        p_att_22 => NULL,
	        p_att_23 => NULL,
	        p_att_24 => NULL,
	        p_att_25 => NULL,
	        p_att_26 => NULL,
	        p_att_27 => NULL,
	        p_att_28 => NULL,
	        p_att_29 => NULL,
	        p_att_30 => NULL,
	        p_attribute_index_info => p_attribute_index_info
	       );
      END IF; ---DELETE REASON


     END IF;

    ELSIF l_action = 'DELETE' THEN
     IF  l_detail_id IS NOT NULL AND l_detail_id > 0 THEN
      -- terminate the block

      if g_debug then
            	              hr_utility.trace('SVG - 5');
      end if;


      hxc_timekeeper_utilities.add_block (
       p_timecard => p_timecard,
       p_timecard_id => l_detail_id,
       p_ovn => l_detail_ovn,
       p_parent_id => p_day_id_info_table (l_index_day).day_id,
       p_parent_ovn => p_day_id_info_table (l_index_day).day_ovn,
       p_approval_style_id => p_approval_style_id,
       p_measure => l_measure,
       p_scope => 'DETAIL',
       p_date_to => SYSDATE,
       p_date_from => NULL,
       p_start_period => l_detail_time_in,
       p_end_period => l_detail_time_out,
       p_resource_id => p_resource_id,
       p_changed => 'Y',
       p_comment_text => l_detail_comment_text,
       p_submit_flg => g_submit,
       p_application_set_id => l_application_set_id,
       p_timecard_index_info => p_timecard_index_info
      );

      IF (p_tk_audit_enabled = 'Y') THEN

       l_attribute_found := FALSE;
         --l_attribute_index :=
       hxc_alias_utility.attribute_check (
          p_bld_blk_info_type_id => reason_bldtyp_id,
          p_time_building_block_id => l_detail_id,
          p_attributes => p_attributes,
          p_tbb_id_reference_table => l_tbb_id_reference_table,
          p_attribute_found => l_attribute_found,
          p_attribute_index => l_attribute_index
         );

         -- now we need to check if we need to create an attribute or do an update

         -- if l_attribute_index = -1 THEN
       IF NOT (l_attribute_found) THEN
        g_negative_index := g_negative_index - 1;

        /*Bug 9014012*/

	l_found:= 'N';

	LOOP
	l_tmp_index:= g_negative_index * -1;
	if g_tk_prepop_detail_id_tab.EXISTS(l_tmp_index) then

	 	g_negative_index := g_negative_index - 1;
	     l_found:= 'N';

	else

	     l_found:='Y';

	end if;

	EXIT WHEN l_found = 'Y';
   	END LOOP;

        l_attribute_index := g_negative_index;
       ELSE
        l_attribute_index := p_attributes (l_attribute_index).time_attribute_id;
       END IF;

       hxc_timekeeper_utilities.add_dff_attribute (
        p_attribute => p_attributes,
        p_attribute_id => l_attribute_index,
        p_tbb_id => l_detail_id,
        p_tbb_ovn => l_detail_ovn,
        p_blk_type => 'REASON', --ctk
        p_blk_id => reason_bldtyp_id, --ctk
        p_att_category => 'REASON',
        p_att_1 => 'TK_DEL_CHANGE_REASON',
        p_att_2 => NULL,
        p_att_3 => 'CHANGE',
        p_att_4 => NULL,
        p_att_5 => NULL,
        p_att_6 => NULL,
        p_att_7 => NULL,
        p_att_8 => NULL,
        p_att_9 => NULL,
        p_att_10 => NULL,
        p_att_11 => NULL,
        p_att_12 => NULL,
        p_att_13 => NULL,
        p_att_14 => NULL,
        p_att_15 => NULL,
        p_att_16 => NULL,
        p_att_17 => NULL,
        p_att_18 => NULL,
        p_att_19 => NULL,
        p_att_20 => NULL,
        p_att_21 => NULL,
        p_att_22 => NULL,
        p_att_23 => NULL,
        p_att_24 => NULL,
        p_att_25 => NULL,
        p_att_26 => NULL,
        p_att_27 => NULL,
        p_att_28 => NULL,
        p_att_29 => NULL,
        p_att_30 => NULL,
        p_attribute_index_info => p_attribute_index_info
       );
      END IF; ---DELETE REASON
     END IF;
    END IF;

    -- increment day
    l_index_day := l_index_day + 1;
   END LOOP; --while end loop for the  days
  END IF;

-- SVG Need to print out p_block and p_attribute plsql tables

/*

 IF g_debug then

   if (p_timecard.count>0) then


 hr_utility.trace(' SVG P_BLOCK TABLE START ');
 hr_utility.trace(' *****************');

 l_attribute_index := p_timecard.FIRST;

  LOOP
    EXIT WHEN NOT p_timecard.EXISTS (l_attribute_index);


   hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =   '|| p_timecard(l_attribute_index).TIME_BUILDING_BLOCK_ID     );
   hr_utility.trace(' TYPE =   '|| p_timecard(l_attribute_index).TYPE )    ;
   hr_utility.trace(' MEASURE =   '|| p_timecard(l_attribute_index).MEASURE)    ;
   hr_utility.trace(' UNIT_OF_MEASURE     =       '|| p_timecard(l_attribute_index).UNIT_OF_MEASURE        )    ;
   hr_utility.trace(' START_TIME     =       '|| p_timecard(l_attribute_index).START_TIME        )    ;
   hr_utility.trace(' STOP_TIME      =       '|| p_timecard(l_attribute_index).STOP_TIME        )    ;
   hr_utility.trace(' PARENT_BUILDING_BLOCK_ID  =       '|| p_timecard(l_attribute_index).PARENT_BUILDING_BLOCK_ID        )    ;
   hr_utility.trace(' PARENT_IS_NEW     =       '|| p_timecard(l_attribute_index).PARENT_IS_NEW        )    ;
   hr_utility.trace(' SCOPE     =       '|| p_timecard(l_attribute_index).SCOPE        )    ;
   hr_utility.trace(' OBJECT_VERSION_NUMBER     =       '|| p_timecard(l_attribute_index).OBJECT_VERSION_NUMBER        )    ;
   hr_utility.trace(' APPROVAL_STATUS     =       '|| p_timecard(l_attribute_index).APPROVAL_STATUS        )    ;
   hr_utility.trace(' RESOURCE_ID     =       '|| p_timecard(l_attribute_index).RESOURCE_ID        )    ;
   hr_utility.trace(' RESOURCE_TYPE    =       '|| p_timecard(l_attribute_index).RESOURCE_TYPE       )    ;
   hr_utility.trace(' APPROVAL_STYLE_ID    =       '|| p_timecard(l_attribute_index).APPROVAL_STYLE_ID       )    ;
   hr_utility.trace(' DATE_FROM    =       '|| p_timecard(l_attribute_index).DATE_FROM       )    ;
   hr_utility.trace(' DATE_TO    =       '|| p_timecard(l_attribute_index).DATE_TO       )    ;
   hr_utility.trace(' COMMENT_TEXT    =       '|| p_timecard(l_attribute_index).COMMENT_TEXT       )    ;
   hr_utility.trace(' PARENT_BUILDING_BLOCK_OVN     =       '|| p_timecard(l_attribute_index).PARENT_BUILDING_BLOCK_OVN        )    ;
   hr_utility.trace(' NEW    =       '|| p_timecard(l_attribute_index).NEW       )    ;
   hr_utility.trace(' CHANGED    =       '|| p_timecard(l_attribute_index).CHANGED       )    ;
   hr_utility.trace(' PROCESS    =       '|| p_timecard(l_attribute_index).PROCESS       )    ;
   hr_utility.trace(' APPLICATION_SET_ID    =       '|| p_timecard(l_attribute_index).APPLICATION_SET_ID       )    ;
   hr_utility.trace(' TRANSLATION_DISPLAY_KEY    =       '|| p_timecard(l_attribute_index).TRANSLATION_DISPLAY_KEY       )    ;
   hr_utility.trace('------------------------------------------------------');

   l_attribute_index := p_timecard.NEXT (l_attribute_index);

   END LOOP;

     hr_utility.trace(' SVG p_timecard TABLE END ');
 hr_utility.trace(' *****************');

       end if;
   END IF;






 IF g_debug then

   if (p_attributes.count>0) then


 hr_utility.trace(' SVG ATTRIBUTES TABLE START ');
 hr_utility.trace(' *****************');

 l_attribute_index := p_attributes.FIRST;

  LOOP
    EXIT WHEN NOT p_attributes.EXISTS (l_attribute_index);


   hr_utility.trace(' TIME_ATTRIBUTE_ID =   '|| p_attributes(l_attribute_index).TIME_ATTRIBUTE_ID);
   hr_utility.trace(' BUILDING_BLOCK_ID =   '|| p_attributes(l_attribute_index).BUILDING_BLOCK_ID )    ;
   hr_utility.trace(' ATTRIBUTE_CATEGORY =   '|| p_attributes(l_attribute_index).ATTRIBUTE_CATEGORY)    ;
   hr_utility.trace(' ATTRIBUTE1     =       '|| p_attributes(l_attribute_index).ATTRIBUTE1        )    ;
   hr_utility.trace(' ATTRIBUTE2  (p_alias_definition_id)   =       '|| p_attributes(l_attribute_index).ATTRIBUTE2        )    ;
   hr_utility.trace(' ATTRIBUTE3  (l_alias_value_id)    =       '|| p_attributes(l_attribute_index).ATTRIBUTE3        )    ;
   hr_utility.trace(' ATTRIBUTE4  (p_alias_type)   =       '|| p_attributes(l_attribute_index).ATTRIBUTE4        )    ;
   hr_utility.trace(' ATTRIBUTE5     =       '|| p_attributes(l_attribute_index).ATTRIBUTE5        )    ;
   hr_utility.trace(' ATTRIBUTE6     =       '|| p_attributes(l_attribute_index).ATTRIBUTE6        )    ;
   hr_utility.trace(' ATTRIBUTE7     =       '|| p_attributes(l_attribute_index).ATTRIBUTE7        )    ;
   hr_utility.trace(' ATTRIBUTE8     =       '|| p_attributes(l_attribute_index).ATTRIBUTE8        )    ;
   hr_utility.trace(' ATTRIBUTE9     =       '|| p_attributes(l_attribute_index).ATTRIBUTE9        )    ;
   hr_utility.trace(' ATTRIBUTE10    =       '|| p_attributes(l_attribute_index).ATTRIBUTE10       )    ;
   hr_utility.trace(' ATTRIBUTE11    =       '|| p_attributes(l_attribute_index).ATTRIBUTE11       )    ;
   hr_utility.trace(' ATTRIBUTE12    =       '|| p_attributes(l_attribute_index).ATTRIBUTE12       )    ;
   hr_utility.trace(' ATTRIBUTE13    =       '|| p_attributes(l_attribute_index).ATTRIBUTE13       )    ;
   hr_utility.trace(' ATTRIBUTE14    =       '|| p_attributes(l_attribute_index).ATTRIBUTE14       )    ;
   hr_utility.trace(' ATTRIBUTE15    =       '|| p_attributes(l_attribute_index).ATTRIBUTE15       )    ;
   hr_utility.trace(' ATTRIBUTE16    =       '|| p_attributes(l_attribute_index).ATTRIBUTE16       )    ;
   hr_utility.trace(' ATTRIBUTE17    =       '|| p_attributes(l_attribute_index).ATTRIBUTE17       )    ;
   hr_utility.trace(' ATTRIBUTE18    =       '|| p_attributes(l_attribute_index).ATTRIBUTE18       )    ;
   hr_utility.trace(' ATTRIBUTE19    =       '|| p_attributes(l_attribute_index).ATTRIBUTE19       )    ;
   hr_utility.trace(' ATTRIBUTE20    =       '|| p_attributes(l_attribute_index).ATTRIBUTE20       )    ;
   hr_utility.trace(' ATTRIBUTE21    =       '|| p_attributes(l_attribute_index).ATTRIBUTE21       )    ;
   hr_utility.trace(' ATTRIBUTE22    =       '|| p_attributes(l_attribute_index).ATTRIBUTE22       )    ;
   hr_utility.trace(' ATTRIBUTE23    =       '|| p_attributes(l_attribute_index).ATTRIBUTE23       )    ;
   hr_utility.trace(' ATTRIBUTE24    =       '|| p_attributes(l_attribute_index).ATTRIBUTE24       )    ;
   hr_utility.trace(' ATTRIBUTE25    =       '|| p_attributes(l_attribute_index).ATTRIBUTE25       )    ;
   hr_utility.trace(' ATTRIBUTE26    =       '|| p_attributes(l_attribute_index).ATTRIBUTE26       )    ;
   hr_utility.trace(' ATTRIBUTE27    =       '|| p_attributes(l_attribute_index).ATTRIBUTE27       )    ;
   hr_utility.trace(' ATTRIBUTE28    =       '|| p_attributes(l_attribute_index).ATTRIBUTE28       )    ;
   hr_utility.trace(' ATTRIBUTE29  (p_alias_ref_object)  =       '|| p_attributes(l_attribute_index).ATTRIBUTE29       )    ;
   hr_utility.trace(' ATTRIBUTE30  (p_alias_value_name)  =       '|| p_attributes(l_attribute_index).ATTRIBUTE30       )    ;
   hr_utility.trace(' BLD_BLK_INFO_TYPE_ID = '|| p_attributes(l_attribute_index).BLD_BLK_INFO_TYPE_ID  );
   hr_utility.trace(' OBJECT_VERSION_NUMBER = '|| p_attributes(l_attribute_index).OBJECT_VERSION_NUMBER );
   hr_utility.trace(' NEW             =       '|| p_attributes(l_attribute_index).NEW                   );
   hr_utility.trace(' CHANGED              =  '|| p_attributes(l_attribute_index).CHANGED               );
   hr_utility.trace(' BLD_BLK_INFO_TYPE    =  '|| p_attributes(l_attribute_index).BLD_BLK_INFO_TYPE     );
   hr_utility.trace(' PROCESS              =  '|| p_attributes(l_attribute_index).PROCESS               );
   hr_utility.trace(' BUILDING_BLOCK_OVN   =  '|| p_attributes(l_attribute_index).BUILDING_BLOCK_OVN    );
   hr_utility.trace('------------------------------------------------------');

   l_attribute_index := p_attributes.NEXT (l_attribute_index);

   END LOOP;

     hr_utility.trace(' SVG ATTRIBUTES TABLE END ');
 hr_utility.trace(' *****************');

       end if;
   END IF;


*/



 END; --create detail structure


-----------------------------------------------------------------------------
 PROCEDURE get_day_totals (
  p_day_total_1 OUT NOCOPY NUMBER,
  p_day_total_2 OUT NOCOPY NUMBER,
  p_day_total_3 OUT NOCOPY NUMBER,
  p_day_total_4 OUT NOCOPY NUMBER,
  p_day_total_5 OUT NOCOPY NUMBER,
  p_day_total_6 OUT NOCOPY NUMBER,
  p_day_total_7 OUT NOCOPY NUMBER,
  p_day_total_8 OUT NOCOPY NUMBER,
  p_day_total_9 OUT NOCOPY NUMBER,
  p_day_total_10 OUT NOCOPY NUMBER,
  p_day_total_11 OUT NOCOPY NUMBER,
  p_day_total_12 OUT NOCOPY NUMBER,
  p_day_total_13 OUT NOCOPY NUMBER,
  p_day_total_14 OUT NOCOPY NUMBER,
  p_day_total_15 OUT NOCOPY NUMBER,
  p_day_total_16 OUT NOCOPY NUMBER,
  p_day_total_17 OUT NOCOPY NUMBER,
  p_day_total_18 OUT NOCOPY NUMBER,
  p_day_total_19 OUT NOCOPY NUMBER,
  p_day_total_20 OUT NOCOPY NUMBER,
  p_day_total_21 OUT NOCOPY NUMBER,
  p_day_total_22 OUT NOCOPY NUMBER,
  p_day_total_23 OUT NOCOPY NUMBER,
  p_day_total_24 OUT NOCOPY NUMBER,
  p_day_total_25 OUT NOCOPY NUMBER,
  p_day_total_26 OUT NOCOPY NUMBER,
  p_day_total_27 OUT NOCOPY NUMBER,
  p_day_total_28 OUT NOCOPY NUMBER,
  p_day_total_29 OUT NOCOPY NUMBER,
  p_day_total_30 OUT NOCOPY NUMBER,
  p_day_total_31 OUT NOCOPY NUMBER
 ) IS
  l_index NUMBER
/*ADVICE(6710): NUMBER has no precision [315] */
                ;
 BEGIN
  l_index := g_timekeeper_data_query.FIRST;

  LOOP
   EXIT WHEN NOT g_timekeeper_data_query.EXISTS (l_index);
   p_day_total_1 := NVL (p_day_total_1, 0) + NVL (g_timekeeper_data_query (l_index).day_1, 0)
                    + NVL (
                       (g_timekeeper_data_query (l_index).time_out_1
                        - g_timekeeper_data_query (l_index).time_in_1
                       )
                       * 24,
                       0
                      );
   p_day_total_2 := NVL (p_day_total_2, 0) + NVL (g_timekeeper_data_query (l_index).day_2, 0)
                    + NVL (
                       (g_timekeeper_data_query (l_index).time_out_2
                        - g_timekeeper_data_query (l_index).time_in_2
                       )
                       * 24,
                       0
                      );
   p_day_total_3 := NVL (p_day_total_3, 0) + NVL (g_timekeeper_data_query (l_index).day_3, 0)
                    + NVL (
                       (g_timekeeper_data_query (l_index).time_out_3
                        - g_timekeeper_data_query (l_index).time_in_3
                       )
                       * 24,
                       0
                      );
   p_day_total_4 := NVL (p_day_total_4, 0) + NVL (g_timekeeper_data_query (l_index).day_4, 0)
                    + NVL (
                       (g_timekeeper_data_query (l_index).time_out_4
                        - g_timekeeper_data_query (l_index).time_in_4
                       )
                       * 24,
                       0
                      );
   p_day_total_5 := NVL (p_day_total_5, 0) + NVL (g_timekeeper_data_query (l_index).day_5, 0)
                    + NVL (
                       (g_timekeeper_data_query (l_index).time_out_5
                        - g_timekeeper_data_query (l_index).time_in_5
                       )
                       * 24,
                       0
                      );
   p_day_total_6 := NVL (p_day_total_6, 0) + NVL (g_timekeeper_data_query (l_index).day_6, 0)
                    + NVL (
                       (g_timekeeper_data_query (l_index).time_out_6
                        - g_timekeeper_data_query (l_index).time_in_6
                       )
                       * 24,
                       0
                      );
   p_day_total_7 := NVL (p_day_total_7, 0) + NVL (g_timekeeper_data_query (l_index).day_7, 0)
                    + NVL (
                       (g_timekeeper_data_query (l_index).time_out_7
                        - g_timekeeper_data_query (l_index).time_in_7
                       )
                       * 24,
                       0
                      );
   p_day_total_8 := NVL (p_day_total_8, 0) + NVL (g_timekeeper_data_query (l_index).day_8, 0)
                    + NVL (
                       (g_timekeeper_data_query (l_index).time_out_8
                        - g_timekeeper_data_query (l_index).time_in_8
                       )
                       * 24,
                       0
                      );
   p_day_total_9 := NVL (p_day_total_9, 0) + NVL (g_timekeeper_data_query (l_index).day_9, 0)
                    + NVL (
                       (g_timekeeper_data_query (l_index).time_out_9
                        - g_timekeeper_data_query (l_index).time_in_9
                       )
                       * 24,
                       0
                      );
   p_day_total_10 := NVL (p_day_total_10, 0) + NVL (g_timekeeper_data_query (l_index).day_10, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_10
                         - g_timekeeper_data_query (l_index).time_in_10
                        )
                        * 24,
                        0
                       );
   p_day_total_11 := NVL (p_day_total_11, 0) + NVL (g_timekeeper_data_query (l_index).day_11, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_11
                         - g_timekeeper_data_query (l_index).time_in_11
                        )
                        * 24,
                        0
                       );
   p_day_total_12 := NVL (p_day_total_12, 0) + NVL (g_timekeeper_data_query (l_index).day_12, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_12
                         - g_timekeeper_data_query (l_index).time_in_12
                        )
                        * 24,
                        0
                       );
   p_day_total_13 := NVL (p_day_total_13, 0) + NVL (g_timekeeper_data_query (l_index).day_13, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_13
                         - g_timekeeper_data_query (l_index).time_in_13
                        )
                        * 24,
                        0
                       );
   p_day_total_14 := NVL (p_day_total_14, 0) + NVL (g_timekeeper_data_query (l_index).day_14, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_14
                         - g_timekeeper_data_query (l_index).time_in_14
                        )
                        * 24,
                        0
                       );
   p_day_total_15 := NVL (p_day_total_15, 0) + NVL (g_timekeeper_data_query (l_index).day_15, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_15
                         - g_timekeeper_data_query (l_index).time_in_15
                        )
                        * 24,
                        0
                       );
   p_day_total_16 := NVL (p_day_total_16, 0) + NVL (g_timekeeper_data_query (l_index).day_16, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_16
                         - g_timekeeper_data_query (l_index).time_in_16
                        )
                        * 24,
                        0
                       );
   p_day_total_17 := NVL (p_day_total_17, 0) + NVL (g_timekeeper_data_query (l_index).day_17, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_17
                         - g_timekeeper_data_query (l_index).time_in_17
                        )
                        * 24,
                        0
                       );
   p_day_total_18 := NVL (p_day_total_18, 0) + NVL (g_timekeeper_data_query (l_index).day_18, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_18
                         - g_timekeeper_data_query (l_index).time_in_18
                        )
                        * 24,
                        0
                       );
   p_day_total_19 := NVL (p_day_total_19, 0) + NVL (g_timekeeper_data_query (l_index).day_19, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_19
                         - g_timekeeper_data_query (l_index).time_in_19
                        )
                        * 24,
                        0
                       );
   p_day_total_20 := NVL (p_day_total_20, 0) + NVL (g_timekeeper_data_query (l_index).day_20, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_20
                         - g_timekeeper_data_query (l_index).time_in_20
                        )
                        * 24,
                        0
                       );
   p_day_total_21 := NVL (p_day_total_21, 0) + NVL (g_timekeeper_data_query (l_index).day_21, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_21
                         - g_timekeeper_data_query (l_index).time_in_21
                        )
                        * 24,
                        0
                       );
   p_day_total_22 := NVL (p_day_total_22, 0) + NVL (g_timekeeper_data_query (l_index).day_22, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_22
                         - g_timekeeper_data_query (l_index).time_in_22
                        )
                        * 24,
                        0
                       );
   p_day_total_23 := NVL (p_day_total_23, 0) + NVL (g_timekeeper_data_query (l_index).day_23, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_23
                         - g_timekeeper_data_query (l_index).time_in_23
                        )
                        * 24,
                        0
                       );
   p_day_total_24 := NVL (p_day_total_24, 0) + NVL (g_timekeeper_data_query (l_index).day_24, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_24
                         - g_timekeeper_data_query (l_index).time_in_24
                        )
                        * 24,
                        0
                       );
   p_day_total_25 := NVL (p_day_total_25, 0) + NVL (g_timekeeper_data_query (l_index).day_25, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_25
                         - g_timekeeper_data_query (l_index).time_in_25
                        )
                        * 24,
                        0
                       );
   p_day_total_26 := NVL (p_day_total_26, 0) + NVL (g_timekeeper_data_query (l_index).day_26, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_26
                         - g_timekeeper_data_query (l_index).time_in_26
                        )
                        * 24,
                        0
                       );
   p_day_total_27 := NVL (p_day_total_27, 0) + NVL (g_timekeeper_data_query (l_index).day_27, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_27
                         - g_timekeeper_data_query (l_index).time_in_27
                        )
                        * 24,
                        0
                       );
   p_day_total_28 := NVL (p_day_total_28, 0) + NVL (g_timekeeper_data_query (l_index).day_28, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_28
                         - g_timekeeper_data_query (l_index).time_in_28
                        )
                        * 24,
                        0
                       );
   p_day_total_29 := NVL (p_day_total_29, 0) + NVL (g_timekeeper_data_query (l_index).day_29, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_29
                         - g_timekeeper_data_query (l_index).time_in_29
                        )
                        * 24,
                        0
                       );
   p_day_total_30 := NVL (p_day_total_30, 0) + NVL (g_timekeeper_data_query (l_index).day_30, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_30
                         - g_timekeeper_data_query (l_index).time_in_30
                        )
                        * 24,
                        0
                       );
   p_day_total_31 := NVL (p_day_total_31, 0) + NVL (g_timekeeper_data_query (l_index).day_31, 0)
                     + NVL (
                        (g_timekeeper_data_query (l_index).time_out_31
                         - g_timekeeper_data_query (l_index).time_in_31
                        )
                        * 24,
                        0
                       );
   l_index := g_timekeeper_data_query.NEXT (l_index);
  END LOOP;
 END;

 PROCEDURE get_absence_statuses ( p_resource_id  IN NUMBER,
                                  p_start_date IN DATE,
                                  p_end_date   IN DATE,
                                  p_abs_status IN OUT NOCOPY HXC_RETRIEVE_ABSENCES.ABS_STATUS_TAB)
 IS


 BEGIN

 HXC_RETRIEVE_ABSENCES.get_abs_statuses ( p_person_id  => p_resource_id,
                        	          p_start_date => p_start_date,
                        	          p_end_date   => p_end_date + g_one_day,
                        		  p_abs_status_rec => p_abs_status);


-- p_abs_status.delete(p_abs_status.first);


 END ; -- get_absence_statuses


 PROCEDURE get_pending_notif_info ( p_no_data		  OUT NOCOPY	VARCHAR2 ,
                                    p_employee_full_name  OUT NOCOPY	VARCHAR2,
    				    p_employee_number     OUT NOCOPY    VARCHAR2,
    				    p_message		  OUT NOCOPY	VARCHAR2)

  IS


  BEGIN

  if g_query_exception_tab.count > 0 then

     p_employee_full_name:= g_query_exception_tab(g_query_exception_tab.FIRST).
                                    employee_full_name;
     p_employee_number:= g_query_exception_tab(g_query_exception_tab.FIRST).
                                    employee_number;
     p_message:= g_query_exception_tab(g_query_exception_tab.FIRST).
                                    message;

     g_query_exception_tab.DELETE(g_query_exception_tab.first);

     p_no_data:='N';

  else

     p_no_data:='Y';

  end if;


  END ; --get_pending_notif_info



 PROCEDURE get_abs_ret_fail_info (  p_no_data		  OUT NOCOPY	VARCHAR2 ,
                                     p_employee_full_name  OUT NOCOPY	VARCHAR2,
      				    p_message		  OUT NOCOPY	VARCHAR2)

    IS


    BEGIN

    if hxc_abs_retrieval_pkg.g_tk_ret_messages.count > 0 then

       p_employee_full_name:= hxc_abs_retrieval_pkg.g_tk_ret_messages
                              (hxc_abs_retrieval_pkg.g_tk_ret_messages.FIRST).employee_name;

       p_message:= hxc_abs_retrieval_pkg.g_tk_ret_messages
                   (hxc_abs_retrieval_pkg.g_tk_ret_messages.FIRST).message_name;

       hxc_abs_retrieval_pkg.g_tk_ret_messages.DELETE(hxc_abs_retrieval_pkg.g_tk_ret_messages.FIRST);

       p_no_data:='N';

    else

       p_no_data:='Y';

    end if;


  END ; --  get_abs_ret_fail_info
-----------------------------------------------------------------------------

END;

/
