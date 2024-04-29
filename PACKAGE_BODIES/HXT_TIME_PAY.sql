--------------------------------------------------------
--  DDL for Package Body HXT_TIME_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TIME_PAY" AS
/* $Header: hxttpay.pkb 120.8.12010000.4 2010/02/17 12:11:27 asrajago ship $ */
g_debug boolean := hr_utility.debug_enabled;

-- Bug 8855103
-- This table will manipulate a cache mechanism.
TYPE NUMBERTAB IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_abstab NUMBERTAB;

-- begin SIR020
PROCEDURE get_retro_fields( p_tim_id     IN      NUMBER
			   ,p_batch_name IN      VARCHAR2
			   ,p_batch_ref  IN      VARCHAR2
                           ,p_pay_status     OUT NOCOPY VARCHAR2
                           ,p_pa_status      OUT NOCOPY VARCHAR2
                           ,p_retro_batch_id OUT NOCOPY NUMBER
                           ,p_error_status   OUT NOCOPY NUMBER
                           ,p_sqlerrm        OUT NOCOPY VARCHAR2)  IS

--first,
--  1. look for detail rows where pay_status = R
--      set p_pay_status = R
--      set p_retro_batch_id = retro_batch_from_row; -- don't gen another.
--      done
--  2. else look for detail rows where pay_status = C
--      set p_pay_status = R
--      set p_retro_batch_id = create batch; --gen a new one for this timecard.
--      done
--  3. else -- timecard is all 'P', no retro pay transactions
--      set p_pay_status = P
--      set p_retro_batch_id = NULL; --  not a retro trans
--      done
--
--second,
--  1. look for detail rows where pa_status = R
--      set p_pa_status = R
--      done
--  2. else look for detail rows where pa_status = C
--      set p_pa_status = R
--      done
--  3. else -- timecard is all 'P', no retro PA transactions
--      set p_pa_status = P
--      done
--


-- Bug 7359347
-- Added a session date parameter and changed
-- the view to base table
CURSOR retro_pay_trans(session_date  DATE) IS
   SELECT 'R', retro_batch_id
   FROM hxt_det_hours_worked_f
   WHERE tim_id = p_tim_id
   AND session_date BETWEEN effective_start_date
                        AND effective_end_date
   AND pay_status = 'R';

CURSOR complete_pay_trans IS
   SELECT 'R'
   FROM hxt_det_hours_worked_f
   WHERE tim_id = p_tim_id
   AND pay_status = 'C';

CURSOR retro_pa_trans IS
   SELECT 'R'
   FROM hxt_det_hours_worked_f
   WHERE tim_id = p_tim_id
   AND pa_status = 'R';

CURSOR complete_pa_trans IS
   SELECT 'R'
   FROM hxt_det_hours_worked_f
   WHERE tim_id = p_tim_id
   AND pa_status = 'C';

CURSOR check_for_details IS
  SELECT 'R'
    FROM hxt_batch_states tbs,
         hxt_timecards_f  tim
   WHERE tim.id = p_tim_id
     AND tbs.batch_id = tim.batch_id
     AND tbs.status = 'VT'
     AND NOT EXISTS (SELECT '1'
                       FROM hxt_det_hours_worked_f det
                      WHERE det.tim_id = tim.id
                        AND NVL(det.hours,0) > 0);

   -- Bug 9367730
   l_no_pay_trans  BOOLEAN := FALSE;


BEGIN


   -- Bug 7359347
   -- Setting the session date to the global variable
   IF g_pay_session_date IS NULL
   THEN
      g_pay_session_date := hxt_tim_col_util.return_session_date;
   END IF;

   g_debug :=hr_utility.debug_enabled;
   if g_debug then
   	 hr_utility.set_location('hxt_time_pay.get_retro_fields',10);
   end if;

   -- Bug 7359347
   -- Added session date parameter.
   OPEN retro_pay_trans(g_pay_session_date);
   FETCH retro_pay_trans INTO p_pay_status, p_retro_batch_id;
   if g_debug then
    	 hr_utility.trace('p_pay_status     :'||p_pay_status);
   	 hr_utility.trace('p_retro_batch_id :'||p_retro_batch_id);
   end if;

   IF retro_pay_trans%NOTFOUND THEN
      if g_debug then
      	    hr_utility.set_location('hxt_time_pay.get_retro_fields',20);
      end if;
      OPEN complete_pay_trans;
      FETCH complete_pay_trans INTO p_pay_status;
      if g_debug then
      	    hr_utility.trace('p_pay_status :'||p_pay_status);
      end if;

      IF complete_pay_trans%NOTFOUND THEN
         if g_debug then
         	hr_utility.set_location('hxt_time_pay.get_retro_fields',30);
         end if;
         p_pay_status := 'P';
         p_retro_batch_id := NULL;
         -- Bug 9367730
         l_no_pay_trans := TRUE;
      ELSE
         if g_debug then
         	hr_utility.set_location('hxt_time_pay.get_retro_fields',40);
         end if;
         p_retro_batch_id := hxt_UTIL.Get_Retro_Batch_Id(p_tim_id
                                                        ,p_batch_name
							,p_batch_ref);
         if g_debug then
         	hr_utility.trace('p_retro_batch_id :'||p_retro_batch_id);
         end if;
      END IF;
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.get_retro_fields',50);
      end if;
      CLOSE complete_pay_trans;
   END IF;
   if g_debug then
   	  hr_utility.set_location('hxt_time_pay.get_retro_fields',60);
   end if;
   CLOSE retro_pay_trans;

   OPEN retro_pa_trans;
   FETCH retro_pa_trans INTO p_pa_status;
   if g_debug then
   	  hr_utility.trace('p_pa_status :'||p_pa_status);
   end if;

   IF retro_pa_trans%NOTFOUND THEN
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.get_retro_fields',70);
      end if;
      OPEN complete_pa_trans;
      FETCH complete_pa_trans INTO p_pa_status;
      if g_debug then
      	     hr_utility.trace('p_pa_status :'||p_pa_status);
      end if;

      IF complete_pa_trans%NOTFOUND THEN
         if g_debug then
         	hr_utility.set_location('hxt_time_pay.get_retro_fields',80);
         end if;
         p_pa_status := 'P';
      END IF;
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.get_retro_fields',90);
      end if;
      CLOSE complete_pa_trans;
   END IF;
   if g_debug then
   	  hr_utility.set_location('hxt_time_pay.get_retro_fields',100);
   end if;
   CLOSE retro_pa_trans;


   -- Bug No 7359347
   -- Do it only if p_pay_status is not already retrieved.
   -- Bug 9367730
   -- Added an OR condition, just in case there are no details greater than zero.
   IF   p_pay_status IS NULL
    OR  l_no_pay_trans = TRUE
   THEN
       OPEN check_for_details ;
       FETCH check_for_details INTO p_pay_status ;
       if g_debug then
   	  hr_utility.trace('p_pay_status :'||p_pay_status);
       end if;

       IF check_for_details%FOUND THEN
          if g_debug then
          	     hr_utility.set_location('hxt_time_pay.get_retro_fields',110);
          end if;
          p_retro_batch_id := HXT_UTIL.Get_Retro_Batch_Id(p_tim_id
                                                         ,p_batch_name
                                                         ,p_batch_ref);
          if g_debug then
          	     hr_utility.trace('p_retro_batch_id :'||p_retro_batch_id);
          end if;
       END IF ;
       if g_debug then
   	  hr_utility.set_location('hxt_time_pay.get_retro_fields',120);
       end if;
       close check_for_details ;

   END IF;


   p_error_status := 0;
   p_sqlerrm := '';

EXCEPTION
   WHEN OTHERS THEN
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.get_retro_fields',130);
      end if;
      p_error_status := 2;
      p_sqlerrm := sqlerrm;

END; --get_retro_fields
     --end RETROPAY

FUNCTION PAY (
   g_ep_id                      IN NUMBER,
   g_ep_type                    IN VARCHAR2,
   g_egt_id                     IN NUMBER,
   g_sdf_id                     IN NUMBER,
   g_hdp_id                     IN NUMBER,
   g_hol_id                     IN NUMBER,
   g_pep_id                     IN NUMBER,
   g_pip_id                     IN NUMBER,
   g_sdovr_id                   IN NUMBER,
   g_osp_id                     IN NUMBER,
   g_hol_yn                     IN VARCHAR2,
   g_person_id                  IN NUMBER,
   g_location                   IN VARCHAR2,
   g_ID                         IN NUMBER,
   g_TIM_ID                     IN NUMBER,
   g_DATE_WORKED                IN DATE,
   g_ASSIGNMENT_ID              IN NUMBER,
   g_HOURS                      IN NUMBER,
   g_TIME_IN                    IN DATE,
   g_TIME_OUT                   IN DATE,
   g_ELEMENT_TYPE_ID            IN NUMBER,
   g_FCL_EARN_REASON_CODE       IN VARCHAR2,
   g_FFV_COST_CENTER_ID         IN NUMBER,
   g_FFV_LABOR_ACCOUNT_ID       IN NUMBER,
   g_TAS_ID                     IN NUMBER,
   g_LOCATION_ID                IN NUMBER,
   g_SHT_ID                     IN NUMBER,
   g_HRW_COMMENT                IN VARCHAR2,
   g_FFV_RATE_CODE_ID           IN NUMBER,
   g_RATE_MULTIPLE              IN NUMBER,
   g_HOURLY_RATE                IN NUMBER,
   g_AMOUNT                     IN NUMBER,
   g_FCL_TAX_RULE_CODE          IN VARCHAR2,
   g_SEPARATE_CHECK_FLAG        IN VARCHAR2,
   g_SEQNO                      IN NUMBER,
   g_CREATED_BY                 IN NUMBER,
   g_CREATION_DATE              IN DATE,
   g_LAST_UPDATED_BY            IN NUMBER,
   g_LAST_UPDATE_DATE           IN DATE,
   g_LAST_UPDATE_LOGIN          IN NUMBER,
   g_EFFECTIVE_START_DATE       IN DATE,
   g_EFFECTIVE_END_DATE         IN DATE,
   g_PROJECT_ID                 IN NUMBER,
   g_PAY_STATUS                 IN VARCHAR2,
   g_PA_STATUS                  IN VARCHAR2,
   g_RETRO_BATCH_ID             IN NUMBER,
   g_STATE_NAME                 IN VARCHAR2 DEFAULT NULL,
   g_COUNTY_NAME                IN VARCHAR2 DEFAULT NULL,
   g_CITY_NAME                  IN VARCHAR2 DEFAULT NULL,
   g_ZIP_CODE                   IN VARCHAR2 DEFAULT NULL
   --g_GROUP_ID                   IN NUMBER
)
   RETURN NUMBER IS

   location                  VARCHAR2(120) := g_location||':PAY';

   -- Bug 8855103
   -- Variable used below.
   l_abs  NUMBER;

FUNCTION call_gen_error(p_location          IN varchar2
                       ,p_error_text        IN VARCHAR2
                       ,p_oracle_error_text IN VARCHAR2 default NULL)
   RETURN NUMBER IS

  --  calls error processing procedure  --

BEGIN

   if g_debug then
   	  hr_utility.set_location('hxt_time_pay.call_gen_error',10);
   end if;
   hxt_util.gen_error(g_tim_id,
		      g_id,
		      NULL,
		      p_error_text,
		      p_location,
		      p_oracle_error_text,
		      g_EFFECTIVE_START_DATE,
		      g_EFFECTIVE_END_DATE,
		      'ERR');
   if g_debug then
   	  hr_utility.set_location('hxt_time_pay.call_gen_error',20);
   end if;
   RETURN 2;
END;

FUNCTION call_hxthxc_gen_error
		       (p_app_short_name IN VARCHAR2,
		        p_msg_name IN VARCHAR2,
			P_msg_token IN VARCHAR2,
		        p_location IN varchar2,
                        p_error_text IN VARCHAR2,
                        p_oracle_error_text IN VARCHAR2 default NULL)
RETURN NUMBER IS
  --  calls error processing procedure  --
BEGIN

   if g_debug then
   	  hr_utility.set_location('hxt_time_pay.call_gen_error',10);
   end if;
   hxt_util.gen_error(g_tim_id,
		      g_id,
		      NULL,
		      p_error_text,
		      p_location,
		      p_oracle_error_text,
		      g_EFFECTIVE_START_DATE,
		      g_EFFECTIVE_END_DATE,
		      'ERR');

   hxc_time_entry_rules_utils_pkg.add_error_to_table (
                     p_message_table=> hxt_hxc_retrieval_process.g_otm_messages,
                     p_message_name=> p_msg_name,
                     p_message_token=> NULL,
                     p_message_level=> 'ERROR',
                     p_message_field=> NULL,
                     p_application_short_name=> p_app_short_name,
                     p_timecard_bb_id=> null,
                     p_time_attribute_id=> NULL,
                     p_timecard_bb_ovn=> NULL,
                     p_time_attribute_ovn=> NULL
                  );
   if g_debug then
   	  hr_utility.trace('Adding to g_otm_messages'||p_msg_name);
   	  hr_utility.set_location('hxt_time_pay.call_gen_error',20);
   end if;
   RETURN 2;
END;

PROCEDURE INSERT_HRS( p_return_code OUT NOCOPY NUMBER,
                      p_id          OUT NOCOPY NUMBER,
                      p_hours        IN NUMBER,
                      p_time_in      IN DATE,
                      p_time_out     IN DATE,
                      p_element_type_id IN NUMBER,
                      p_seqno        IN NUMBER,
                      p_location     IN VARCHAR2 ) IS

  --  Procedure INSERT_HRS
  --
  --  Purpose
  --    Insert a record in HXT_HOURS_WORKED.
  --
  --  Returns
  --    p_return_code - the record code (0 - no errors  2 - errors occured.
  --    p_id          - ID of record inserted
  --
  --  Arguments
  --    base record columns - The values to be inserted.
  --  Modifications
  --    2/15/96  Changed line_status field write to always be null as children
  --             hours worked records do not need their parents' status.  AVS
  --    4/23/97  Added the get_ovt_rates_cur to fetch premium types and amounts
  --             which need to be inserted into hxt_det_hours_worked table.
  --             Fixed under Oracle Bugs #465434 & #464850.
  --    1/07/98  SIR69 Cursor get_ovt_rates_cur now handles all premiums and
  --             not just overtime.  Was ignoring earn types of OTH etc.
  --    1/22/98  SIR092 Hours are not written to premium types of FIXED.
  --
   v_amount hxt_det_hours_worked.amount%type := null;           --SIR029
   l_costable_type       PAY_ELEMENT_LINKS_F.COSTABLE_TYPE%TYPE;
   l_ffv_cost_center_id  HXT_DET_HOURS_WORKED_F.FFV_COST_CENTER_ID%TYPE;

   CURSOR   next_id_cur IS
     SELECT hxt_seqno.nextval next_id
     FROM   dual;

   l_id                    NUMBER;
   l_pay_status            CHAR(1);
   l_pa_status             CHAR(1);
   l_retro_batch_id        NUMBER(15);
   l_error_status          NUMBER(15);
   l_sqlerrm               CHAR(200);
   l_rowid                 ROWID;
   l_object_version_number NUMBER DEFAULT NULL;

-- ************************************
-- ORACLE START Bugs #465434 & #464850
-- ************************************
   CURSOR  get_ovt_rates_cur IS
    SELECT eltv.hxt_premium_type,
           eltv.hxt_premium_amount,
           eltv.hxt_processing_order
    FROM   hxt_pay_element_types_f_ddf_v eltv
    WHERE  eltv.hxt_earning_category NOT IN ('REG', 'ABS')
           AND g_DATE_WORKED between eltv.effective_start_date
                                 and eltv.effective_end_date
           AND eltv.element_type_id = p_element_type_id
   ORDER by eltv.hxt_processing_order;

   premium_type     hxt_pay_element_types_f_ddf_v.hxt_premium_type%TYPE ;
   premium_amount   hxt_pay_element_types_f_ddf_v.hxt_premium_amount%TYPE ;
   processing_order hxt_pay_element_types_f_ddf_v.hxt_processing_order%TYPE ;

   l_rate_multiple  hxt_pay_element_types_f_ddf_v.hxt_premium_amount%TYPE ;
   l_hourly_rate    hxt_pay_element_types_f_ddf_v.hxt_premium_amount%TYPE ;
   l_amount         hxt_pay_element_types_f_ddf_v.hxt_premium_amount%TYPE ;

   l_hours          hxt_det_hours_worked_f.hours%TYPE ; -- SIR092
-- *********************************
-- ORACLE END Bugs #465434 & #464850
-- *********************************

BEGIN

 if g_debug then

 	hr_utility.set_location('hxt_time_pay.INSERT_HRS',10);
 end if;

--Set return code and get ID.
  p_return_code := 0;

 OPEN next_id_cur;
 FETCH next_id_cur INTO l_id;
 if g_debug then

 	hr_utility.trace('l_id :'||l_id);
 end if;
 CLOSE next_id_cur;

 p_id := l_id;

 get_retro_fields( g_tim_id
                  ,HXT_TIME_COLLECTION.g_batch_name
	          ,HXT_TIME_COLLECTION.g_batch_ref
                  ,l_pay_status
                  ,l_pa_status
                  ,l_retro_batch_id
                  ,l_error_status
                  ,l_sqlerrm);

 IF l_error_status = 0 THEN
    if g_debug then
    	   hr_utility.set_location('hxt_time_pay.INSERT_HRS',20);
    end if;

   BEGIN
-- ***********************************
-- ORACLE START Bugs #465434 & #464850
-- ***********************************

   if g_debug then
   	  hr_utility.set_location('hxt_time_pay.INSERT_HRS',30);
   end if;

   OPEN get_ovt_rates_cur ;
   FETCH get_ovt_rates_cur
   INTO premium_type, premium_amount, processing_order ;
   if g_debug then
   	  hr_utility.trace('premium_type     :'||premium_type);
   	  hr_utility.trace('premium_amount   :'||premium_amount);
   	  hr_utility.trace('processing_order :'||processing_order);
   end if;

   CLOSE get_ovt_rates_cur ;
--
-- Default the hours worked to those passed in
--
   l_hours := p_hours ; -- SIR092
   if g_debug then
   	  hr_utility.trace('l_hours :'||l_hours);
   end if;
--
-- Determine if a premium amount should apply.
--
   IF premium_type     = 'FACTOR' THEN
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.INSERT_HRS',40);
      end if;
      l_rate_multiple := premium_amount ;
   ELSIF premium_type  = 'RATE' THEN
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.INSERT_HRS',50);
      end if;
      l_hourly_rate   := premium_amount ;
   ELSIF premium_type  = 'FIXED' THEN
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.INSERT_HRS',60);
      end if;
      l_amount        := premium_amount ;
      l_hours         := 0 ; -- SIR092 Hours have no meaning with
                             -- flat amount premiums
   ELSE
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.INSERT_HRS',70);
      end if;
      NULL ;
   END IF ;
--
-- Any values passed in from globals will override retrieved values.
--
   IF g_rate_multiple IS NOT NULL THEN
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.INSERT_HRS',80);
      end if;
      l_rate_multiple := g_rate_multiple ;
      if g_debug then
      	     hr_utility.trace('l_rate_multiple :'||l_rate_multiple);
      end if;
   END IF ;
--
   IF g_hourly_rate IS NOT NULL THEN
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.INSERT_HRS',90);
      end if;
      l_hourly_rate := g_hourly_rate ;
   END IF  ;
--
   IF g_amount IS NOT NULL THEN
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.INSERT_HRS',100);
      end if;
      l_amount := g_amount ;
      if g_debug then
      	     hr_utility.trace('l_amount :'||l_amount);
      end if;
   END IF ;

-- *********************************
-- ORACLE END Bugs #465434 & #464850
-- *********************************
--
   if g_debug then
   	  hr_utility.set_location('hxt_time_pay.INSERT_HRS',110);
   end if;
   l_costable_type := HXT_UTIL.get_costable_type(p_element_type_id,
                                                 g_date_worked,
                                                 g_assignment_id);
   if g_debug then
   	  hr_utility.trace('l_costable_type :'||l_costable_type);
   end if;

   IF l_costable_type in ('C','F') THEN
     if g_debug then
     	    hr_utility.set_location('hxt_time_pay.INSERT_HRS',120);
     end if;
     l_ffv_cost_center_id := g_FFV_COST_CENTER_ID;
     if g_debug then
     	    hr_utility.trace('l_ffv_cost_center_id :'||l_ffv_cost_center_id);
     end if;
   ELSE
     if g_debug then
     	    hr_utility.set_location('hxt_time_pay.INSERT_HRS',130);
     end if;
     l_ffv_cost_center_id := NULL;
     if g_debug then
     	    hr_utility.trace('l_ffv_cost_center_id :'||l_ffv_cost_center_id);
     end if;
   END IF;

/* INSERT INTO hxt_det_hours_worked_f(id,
                      parent_id,
                      tim_id,
                      date_worked,
                      assignment_id,
                      hours,
                      time_in,
                      time_out,
                      element_type_id,
                      fcl_earn_reason_code,
                      ffv_cost_center_id,
                      tas_id,
                      location_id,
                      sht_id,
                      hrw_comment,
                      ffv_rate_code_id,
                      rate_multiple,
                      hourly_rate,
                      amount,
                      fcl_tax_rule_code,
                      separate_check_flag,
                      seqno,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login,
                      effective_start_date,
                      effective_end_date,
                      project_id,
                      pay_status,
                      pa_status,
                      retro_batch_id
                      --group_id
                  )
               VALUES(p_id,
                      g_id,
                      g_tim_id,
                      g_date_worked,
                      g_assignment_id,
                      l_hours,
                      p_time_in,
                      p_time_out,
                      p_element_type_id,
                      g_fcl_earn_reason_code,
                      l_ffv_cost_center_id,
                      g_tas_id,
                      g_location_id,
                      g_sht_id,
                      g_hrw_comment,
                      g_ffv_rate_code_id,
                      l_rate_multiple,
                      l_hourly_rate,
                      l_amount,
                      g_fcl_tax_rule_code,
                      g_separate_check_flag,
                      p_seqno,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login,
                      g_effective_start_date,
                      g_effective_end_date,
                      g_project_id,
                      l_pay_status,
                      l_pa_status,
                      l_retro_batch_id
                      --g_group_id
                      ); */


     /* Call dml to insert hours into hxt_det_hours_worked_f */
        if g_debug then
        	hr_utility.set_location('hxt_time_pay.INSERT_HRS',140);
        end if;

	hxt_dml.insert_HXT_DET_HOURS_WORKED(
	   p_rowid        		=> l_rowid,
	   p_id                     	=> p_id,
	   p_parent_id              	=> g_id,
	   p_tim_id                 	=> g_tim_id,
	   p_date_worked           	=> g_date_worked,
	   p_assignment_id         	=> g_assignment_id,
	   p_hours                 	=> l_hours,
	   p_time_in               	=> p_time_in,
	   p_time_out              	=> p_time_out,
	   p_element_type_id       	=> p_element_type_id,
	   p_fcl_earn_reason_code 	=> g_fcl_earn_reason_code,
	   p_ffv_cost_center_id   	=> l_ffv_cost_center_id,
	   p_ffv_labor_account_id	=> NULL,
	   p_tas_id             	=> g_tas_id,
	   p_location_id       		=> g_location_id,
	   p_sht_id           		=> g_sht_id,
	   p_hrw_comment     		=> g_hrw_comment,
	   p_ffv_rate_code_id      	=> g_ffv_rate_code_id,
	   p_rate_multiple        	=> l_rate_multiple,
	   p_hourly_rate         	=> l_hourly_rate,
	   p_amount             	=> l_amount,
	   p_fcl_tax_rule_code 		=> g_fcl_tax_rule_code,
	   p_separate_check_flag  	=> g_separate_check_flag,
	   p_seqno               	=> p_seqno,
	   p_created_by         	=> g_created_by,
	   p_creation_date     		=> g_creation_date,
	   p_last_updated_by  		=> g_last_updated_by,
	   p_last_update_date      	=> g_last_update_date,
	   p_last_update_login    	=> g_last_update_login,
	   p_actual_time_in     	=> NULL,
	   p_actual_time_out   		=> NULL,
	   p_effective_start_date 	=> g_effective_start_date,
	   p_effective_end_date  	=> g_effective_end_date,
	   p_project_id         	=> g_project_id,
	   p_job_id           		=> NULL,
	   p_earn_pol_id     		=> NULL,
	   p_retro_batch_id 		=> l_retro_batch_id,
	   p_pa_status     		=> l_pa_status,
	   p_pay_status   		=> l_pay_status,
	   --p_group_id			=> g_group_id,
	   p_object_version_number 	=> l_object_version_number,
           p_STATE_NAME                 => g_STATE_NAME,
	   p_COUNTY_NAME                => g_COUNTY_NAME,
	   p_CITY_NAME                  => g_CITY_NAME,
	   p_ZIP_CODE                   => g_ZIP_CODE);

        if g_debug then
               hr_utility.set_location('hxt_time_pay.INSERT_HRS',150);
        end if;

   EXCEPTION

   WHEN OTHERS THEN
       if g_debug then
       	      hr_utility.set_location('hxt_time_pay.INSERT_HRS',160);
       end if;
    -- Insert record in error table.
       FND_MESSAGE.SET_NAME('HXT','HXT_39313_OR_ERR_INS_REC');
       p_return_code := call_hxthxc_gen_error('HXT','HXT_39313_OR_ERR_INS_REC',NULL,p_location||':INS', '',sqlerrm);
       --2278400 p_return_code := call_gen_error(p_location||':INS', '',sqlerrm);
       if g_debug then
       	      hr_utility.trace('p_return_code :'||p_return_code);
       end if;
   END;

   ELSE
       if g_debug then
       	      hr_utility.set_location('hxt_time_pay.INSERT_HRS',170);
       end if;
       FND_MESSAGE.SET_NAME('HXT','HXT_39421_GET_RETRO_ERR');
       p_return_code := call_hxthxc_gen_error('HXT','HXT_39421_GET_RETRO_ERR',NULL,p_location||':INS', '',sqlerrm);
       --2278400 p_return_code := call_gen_error(p_location||':INS', '',sqlerrm);
       if g_debug then
       	      hr_utility.trace('p_return_code :'||p_return_code);
       end if;
   END IF;

END INSERT_HRS;
---------------------------------------------------------------------------
FUNCTION Gen_Premiums(
  p_sdf_id              NUMBER,
  p_sdovr_id            NUMBER,
  p_location            VARCHAR2,
  p_base_id             NUMBER,
  p_hours               NUMBER,
  p_time_in             DATE,
  p_time_out            DATE,
  p_element_type_id     NUMBER,
  p_seqno               NUMBER )

RETURN NUMBER IS
  --
  --  Function HXT_GEN_PREMIUMS
  --
  --  Updated 01-09-96 by Bob  ... Incorporated Error handling
  --
  --  Purpose
  --    Create all premium records for a base-hour entry that a person is
  --    entitled to based on earning category rules, premium eligibility for
  --    a base hour, and being linked to a person.
  --
  --  Function will:
  --       1. insert premiums for a non-overtime base-hour record
  --       2. update the override multiple or hourly rate for an
  --          overtime base-hour record
  --    Derives override multiple and fixed rate if premium is type Factor
  --    or Fixed Rate by applying premium interaction rules against premiums
  --    of lower priority that have already been inserted for this
  --    calling base-hour detail record.  Thus, we avoid re-applying the
  --    earning-category based rules when calculating the multiple.
  --    The hours on base record apply to only one shift.
  --
  --  Arguments
  --    p_base_id  - The base hours worked detail record for which to
  --                 generate premiums.
  --    p_sdf_id   - The id of any applicable shift differential premium
  --                 incl override sdf.
  --    p_location - The Procedure and/or Function path where an error occurred
  --    base_hour_columns - Columns of the base-hour record for which we
  --                        are creating premiums.
  --
  --  Modifications
  --    04/23/97 Oracle Bugs #465434 & #464850.  User no longer has to prefix
  --		 premiums with a '1' that were meant to be a percentage.
  --             (Ex. User can enter .15 for 15% instead of entering 1.15.)
  --             User can still enter 1.5 for overtime hours of time and a
  --		 half. PWM
  --    09/15/97 ORA131 Function will now handle Fixed Rate premiums as
  --             well as Factor Multiple premiums when it comes to the premium
  --             interaction rules. PWM
  --    01/16/98 SIR#9 Formula for calculting premiums amounts has been
  --             modified so that it is no longer necessary to subtract 1 from
  --             overtime premiums.
  --    01/22/98 SIR092 Hours are not written to premium types of FIXED. PWM
  --    01/30/98 Peformance tuned cursor cur_elig_prem. PWM
  --    02/27/98 SIR103 Still need to subtract 1 from overtime premiums
  --		 before interaction with other premiums. PWM
  --
  -- Define variables
  --
  l_pay_status     CHAR(1);
  l_pa_status      CHAR(1);
  l_retro_batch_id NUMBER(15);
  l_error_status   NUMBER(15);
  l_sqlerrm        CHAR(200);

  l_mult           hxt_pay_element_types_f_ddf_v.hxt_premium_amount%TYPE;
                -- Premium override multiple
  l_rate           hxt_pay_element_types_f_ddf_v.hxt_premium_amount%TYPE;
                -- Premium override rate ORA131

  l_hours          hxt_det_hours_worked_f.hours%TYPE ; -- SIR092
  l_time_in        hxt_det_hours_worked_f.time_in%TYPE ;
  l_time_out       hxt_det_hours_worked_f.time_out%TYPE ;
  l_seqno          NUMBER;                             -- Line seqno
  l_error_code     NUMBER  DEFAULT 0;  -- Default to no error
  l_location       VARCHAR2(120);      -- Current Path for locating source
                                       -- of errors
  hrw_rowid        ROWID;

  l_min_detail_seqno NUMBER;
  l_max_detail_seqno NUMBER;

  l_costable_type      pay_element_links_f.costable_type%TYPE;
  l_ffv_cost_center_id hxt_det_hours_worked_f.ffv_cost_center_id%TYPE;

  l_rowid                  ROWID;
  l_object_version_number  NUMBER     DEFAULT NULL;
  l_id  		   NUMBER;

  l_rate_multiple hxt_pay_element_types_f_ddf_v.hxt_premium_amount%TYPE ;
  l_hourly_rate   hxt_pay_element_types_f_ddf_v.hxt_premium_amount%TYPE ;
  l_amount        hxt_pay_element_types_f_ddf_v.hxt_premium_amount%TYPE ;
  --
  -- Cursor to return all premiums for a base hour entry that a person is
  -- entitled to based on earning category rules, premium eligibility
  -- for a base hour, and being linked to the person's assignment.
  -- Earning category rules enforced in where clause decode:
     -- Returns only shift diff premium p_sdf_id when processing category SDF.
     -- Returns only off shift premium g_osp_id when processing category OSP.
     -- Returns holiday premium if g_hol_yn = 'Y' when processing category HOL.

  CURSOR cur_elig_prem IS
    SELECT /* +INDEX (ell pay_pk) +INDEX(per per_pk) */
           per.elt_premium_id, eltt.element_name, eltv.hxt_earning_category,
           eltv.hxt_premium_type, eltv.hxt_premium_amount,
           eltv.hxt_processing_order
    FROM   pay_element_links_f ell,
           hxt_pay_element_types_f_ddf_v eltv,
           pay_element_types_f elt,
           pay_element_types_f_tl eltt,
           hxt_prem_eligblty_rules per,
           per_all_assignments_f asm
    WHERE asm.assignment_id = g_ASSIGNMENT_ID
      AND g_DATE_WORKED between asm.effective_start_date
                            and asm.effective_end_date
      AND per.pep_id = g_PEP_ID                    -- prem eligibility policy
      AND per.elt_base_id = p_element_type_id      -- base-hour earning
      AND g_DATE_WORKED between per.effective_start_date
                           and  per.effective_end_date
      AND per.elt_premium_id = elt.element_type_id   -- element type
      AND g_DATE_WORKED between elt.effective_start_date
                            and elt.effective_end_date
      AND elt.element_type_id =            -- allow hol prem if holiday
              decode(eltv.hxt_earning_category, 'HOL',
              decode(g_HOL_YN,'Y',elt.element_type_id,-1),elt.element_type_id)
      AND( elt.element_type_id =        -- restrict to earnings passed, if any
              decode(eltv.hxt_earning_category, 'SDF', p_sdf_id,
                                                'OSP', g_OSP_ID,
                                                 elt.element_type_id)
        -- Added the OR clause to check if the earning type
        -- is the Override earning.
           OR elt.element_type_id =   -- restrict to earnings passed, if any
              decode(eltv.hxt_earning_category, 'SDF', p_sdovr_id,
                                                'OSP', g_OSP_ID,
                                                 elt.element_type_id) )
      AND eltt.element_type_id = elt.element_type_id
      AND eltt.language = userenv('LANG')
      AND elt.element_type_id = eltv.element_type_id
      AND g_DATE_WORKED between eltv.effective_start_date
                            and eltv.effective_end_date
      AND eltv.hxt_earning_category NOT in('ABS','REG','OVT')
      AND elt.element_type_id = ell.element_type_id
      AND g_DATE_WORKED between ell.effective_start_date
                            and ell.effective_end_date
      AND nvl(ell.pay_basis_id,nvl(asm.pay_basis_id,-1)) =
                nvl(asm.pay_basis_id,-1)
      AND nvl(ell.employment_category,nvl(asm.employment_category,-1)) =
                nvl(asm.employment_category,-1)
      AND nvl(ell.payroll_id,nvl(asm.payroll_id,-1)) =
                nvl(asm.payroll_id,-1)
      AND nvl(ell.location_id,nvl(asm.location_id,-1)) =
              nvl(asm.location_id,-1)
      AND nvl(ell.grade_id,nvl(asm.grade_id,-1)) = nvl(asm.grade_id,-1)
      AND nvl(ell.position_id,nvl(asm.position_id,-1)) = nvl(asm.position_id,-1)
      AND (nvl(ell.job_id, nvl(asm.job_id,-1)) = nvl(asm.job_id,-1))
--
-- We need to link to pay_assignment_link_usages for people_group eligibility.
--
   AND (ell.people_group_id is null
       OR  EXISTS ( SELECT 1 FROM PAY_ASSIGNMENT_LINK_USAGES_F USAGE
            WHERE USAGE.ASSIGNMENT_ID = ASM.ASSIGNMENT_ID
            AND USAGE.ELEMENT_LINK_ID = ELL.ELEMENT_LINK_ID
            AND G_DATE_WORKED BETWEEN USAGE.EFFECTIVE_START_DATE
                       AND USAGE.EFFECTIVE_END_DATE))
      AND nvl(ell.organization_id,nvl(asm.organization_id,-1)) =
                nvl(asm.organization_id,-1)
      AND nvl(ell.business_group_id,nvl(asm.business_group_id,-1)) =
                nvl(asm.business_group_id,-1) -- link to assignment

    UNION ALL

 -- Second part of union handles possible overtime
    SELECT elt.element_type_id
          ,eltt.element_name
          ,eltv.hxt_earning_category  --FORMS60
          ,eltv.hxt_premium_type
          ,eltv.hxt_premium_amount
          ,eltv.hxt_processing_order
    FROM   hxt_pay_element_types_f_ddf_v eltv
          ,pay_element_types_f elt
          ,pay_element_types_f_tl eltt
    WHERE  elt.element_type_id = p_element_type_id
      AND  g_DATE_WORKED between elt.effective_start_date
                             and elt.effective_end_date
      AND  eltt.element_type_id = elt.element_type_id
      AND  eltt.language = userenv('LANG')
      AND  elt.element_type_id = eltv.element_type_id
      AND  g_DATE_WORKED between eltv.effective_start_date
                             and eltv.effective_end_date
      AND  eltv.hxt_earning_category = 'OVT' -- overtime only
    ORDER by 6;
--
-- Get the minimum sequence number of the current detail row
--

 -- Bug 7359347
 -- Changed the below cursor to work with HXT_DET_HOURS_WORKED_F
 -- rather than HXT_DET_HOURS_WORKED to avoid contention on FND_SESSIONS
 /*
 CURSOR  get_min_detail_seqno IS
  SELECT seqno
  FROM   hxt_det_hours_worked
  WHERE  id = p_BASE_ID;
--
-- Get the maximum sequence number of the current detail row
--
 CURSOR  get_max_detail_seqno IS
  SELECT nvl(min(hrw.seqno),9999)
  FROM   hxt_pay_element_types_f_ddf_v eltv
        ,pay_element_types_f elt
        ,hxt_det_hours_worked hrw
  WHERE  hrw.tim_id = g_TIM_ID
  AND    hrw.date_worked = g_DATE_WORKED
  AND    hrw.parent_id = g_ID
  AND    hrw.seqno > l_min_detail_seqno
  AND    elt.element_type_id = hrw.element_type_id
  AND    eltv.element_type_id = elt.element_type_id
  AND    g_DATE_WORKED BETWEEN eltv.effective_start_date
                           AND eltv.effective_end_date
  AND    eltv.hxt_earning_category IN ('REG','OVT','ABS');

  -- not needed. declared in for loop.
  -- elig_prem_rec   cur_elig_prem%ROWTYPE;

  -- Step through the premium detail records of type factor that were
  -- already inserted into the hours worked table.  All are lower processing
  -- order than the current premium with the possible exception of an overtime
  -- base-hour which also has a processing order.  Premium must be of type
  -- Factor to exist in hxt_prem_interact_rules.  Match them up against premium
  -- interaction rules to calculate premium.  Will need to get factor if not
  -- overridden.
  -- SIR189 - To assure that a rate or multiple gets applied to the correct
  -- row of the the detail table, we must make sure that the hrw.seqno is
  -- greater than the starting earning item's seqno and that the hrw.seqno
  -- is lesser than any other earning items of type REG, OVT or ABS.  This
  -- gives us an association between interacting premiums and the earning
  -- elements they are acting upon. PWM 08/19/98

  CURSOR cur_prem_intr( p_earn_id NUMBER
                      , p_process_order NUMBER ) IS
    SELECT --+INDEX(pir pir_pk)
           eltt.element_name,
	   eltv.hxt_premium_amount multiple,
	   hrw.element_type_id,  --FORMS60
           hrw.rowid hrwrowid,
           eltv.hxt_earning_category,
           eltv.hxt_premium_type
    FROM   hxt_pay_element_types_f_ddf_v eltv,
           pay_element_types_f elt,
           pay_element_types_f_tl eltt,
           hxt_prem_interact_rules pir,
           hxt_det_hours_worked hrw  -- C421
    WHERE  hrw.tim_id = g_TIM_ID
      AND  hrw.date_worked = g_DATE_WORKED
      AND  hrw.parent_id = g_ID                 -- same parent as base record
      AND  pir.elt_prior_prem_id = hrw.element_type_id
      AND  pir.pip_id = g_PIP_ID                -- prem interaction policy
      AND  pir.elt_earned_prem_id = p_earn_id   -- driving premium
      AND  g_DATE_WORKED between pir.effective_start_date
                             and pir.effective_end_date
      AND  pir.apply_prior_prem_yn = 'Y'
      AND  pir.elt_prior_prem_id = elt.element_type_id  -- element type
      AND  g_DATE_WORKED between elt.effective_start_date
                             and elt.effective_end_date
      AND  eltt.element_type_id = elt.element_type_id
      AND  eltt.language = userenv('LANG')
      AND  eltv.element_type_id = elt.element_type_id
      AND  g_DATE_WORKED between eltv.effective_start_date
                             and eltv.effective_end_date
      AND  eltv.hxt_processing_order < p_process_order  -- ovt may exist already
      AND  hrw.seqno > l_min_detail_seqno
      AND  hrw.seqno < l_max_detail_seqno
    ORDER BY eltv.hxt_processing_order;

*/

 CURSOR  get_min_detail_seqno IS
  SELECT seqno
  FROM   hxt_det_hours_worked_f
  WHERE  id = p_BASE_ID
    AND g_pay_session_date BETWEEN effective_start_date
                               AND effective_end_date;
--
-- Get the maximum sequence number of the current detail row
--
 CURSOR  get_max_detail_seqno IS
  SELECT nvl(min(hrw.seqno),9999)
  FROM   hxt_pay_element_types_f_ddf_v eltv
        ,pay_element_types_f elt
        ,hxt_det_hours_worked_f hrw
  WHERE  hrw.tim_id = g_TIM_ID
  AND    hrw.date_worked = g_DATE_WORKED
  AND    hrw.parent_id = g_ID
  AND    g_pay_session_date BETWEEN hrw.effective_start_date
                                AND hrw.effective_end_date
  AND    hrw.seqno > l_min_detail_seqno
  AND    elt.element_type_id = hrw.element_type_id
  AND    eltv.element_type_id = elt.element_type_id
  AND    g_DATE_WORKED BETWEEN eltv.effective_start_date
                           AND eltv.effective_end_date
  AND    eltv.hxt_earning_category IN ('REG','OVT','ABS');

  CURSOR cur_prem_intr( p_earn_id NUMBER
                      , p_process_order NUMBER ) IS
    SELECT --+INDEX(pir pir_pk)
           eltt.element_name,
	   eltv.hxt_premium_amount multiple,
	   hrw.element_type_id,  --FORMS60
           hrw.rowid hrwrowid,
           eltv.hxt_earning_category,
           eltv.hxt_premium_type
    FROM   hxt_pay_element_types_f_ddf_v eltv,
           pay_element_types_f elt,
           pay_element_types_f_tl eltt,
           hxt_prem_interact_rules pir,
           hxt_det_hours_worked_f hrw  -- C421
    WHERE  hrw.tim_id = g_TIM_ID
      AND  hrw.date_worked = g_DATE_WORKED
      AND  hrw.parent_id = g_ID                 -- same parent as base record
      AND  pir.elt_prior_prem_id = hrw.element_type_id
      AND  pir.pip_id = g_PIP_ID                -- prem interaction policy
      AND  pir.elt_earned_prem_id = p_earn_id   -- driving premium
      AND  g_pay_session_date BETWEEN hrw.effective_start_date
                                  AND hrw.effective_end_date
      AND  g_DATE_WORKED between pir.effective_start_date
                             and pir.effective_end_date
      AND  pir.apply_prior_prem_yn = 'Y'
      AND  pir.elt_prior_prem_id = elt.element_type_id  -- element type
      AND  g_DATE_WORKED between elt.effective_start_date
                             and elt.effective_end_date
      AND  eltt.element_type_id = elt.element_type_id
      AND  eltt.language = userenv('LANG')
      AND  eltv.element_type_id = elt.element_type_id
      AND  g_DATE_WORKED between eltv.effective_start_date
                             and eltv.effective_end_date
      AND  eltv.hxt_processing_order < p_process_order  -- ovt may exist already
      AND  hrw.seqno > l_min_detail_seqno
      AND  hrw.seqno < l_max_detail_seqno
    ORDER BY eltv.hxt_processing_order;



  /*  CURSOR Get_Shift_Info (p_assignment_id  NUMBER
                          ,p_date_worked    DATE  ) IS
      SELECT  aeiv.hxt_rotation_plan
             ,rts.tws_id
             ,hws.week_day
             ,hs.standard_start
             ,hs.standard_stop
      FROM    hxt_shifts hs
             ,hxt_work_shifts hws
             ,hxt_per_aei_ddf_v aeiv
             ,hxt_rotation_schedules rts
      WHERE   aeiv.assignment_id = p_ASSIGNMENT_ID
      AND     p_DATE_WORKED between aeiv.effective_start_date
                                and aeiv.effective_end_date
      AND     rts.rtp_id = aeiv.hxt_rotation_plan
      AND     rts.start_date = (SELECT MAX(start_date)
                                FROM   hxt_rotation_schedules
                                WHERE  rtp_id = rts.rtp_id
                                AND    start_date <= p_DATE_WORKED
                                )
      AND     hws.tws_id     = rts.tws_id
      AND     hws.week_day   = to_char(p_DATE_WORKED,'DY')
      AND     hws.sht_id     = hs.id;


      lv_rotation_plan  hxt_rotation_schedules.rtp_id%TYPE;
      lv_tws_id         hxt_rotation_schedules.tws_id%TYPE;
      lv_week_day       hxt_work_shifts.week_day%TYPE;
      lv_standard_start hxt_shifts.standard_start%TYPE;
      lv_standard_stop  hxt_shifts.standard_stop%TYPE;

      lv_elig_for_prem  BOOLEAN := FALSE; */

   -- Not needed.Declared in FOR loop.
   -- prem_intr_rec   cur_prem_intr%ROWTYPE;

BEGIN

  if g_debug then
  	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',10);
  end if;


  -- Bug 7359347
  -- Setting session date to global variable
  IF g_pay_session_date IS NULL
  THEN
     g_pay_session_date := hxt_tim_col_util.return_session_date;
  END IF;

--Update location path with GEN_PREMIUMS function.
  l_location := p_location||':PREM';
--Increment line seqno
  l_seqno := p_seqno + 10;
  if g_debug then
  	 hr_utility.trace('l_seqno :'||l_seqno);
  	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',20);
  end if;

  open  get_min_detail_seqno;
  fetch get_min_detail_seqno into l_min_detail_seqno;
  if g_debug then
  	 hr_utility.trace('l_min_detail_seqno:'||l_min_detail_seqno);
  end if;
  close get_min_detail_seqno;

  if g_debug then
  	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',30);
  end if;

  open  get_max_detail_seqno;
  fetch get_max_detail_seqno into l_max_detail_seqno;
  if g_debug then
  	 hr_utility.trace('l_max_detail_seqno:'||l_max_detail_seqno);
  end if;
  close get_max_detail_seqno;

--Loop through premiums person is eligible for
--in order of priority

  if g_debug then
  	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',40);
  end if;

<<elig_prem>>

  if g_debug then
	  hr_utility.set_location('hxt_time_pay.Gen_Premiums',50);
	  hr_utility.trace('g_ASSIGNMENT_ID  :'||g_ASSIGNMENT_ID);
	  hr_utility.trace('g_DATE_WORKED    :'||g_DATE_WORKED);
	  hr_utility.trace('g_PEP_ID         :'||g_PEP_ID);
	  hr_utility.trace('p_element_type_id:'||p_element_type_id);
	  hr_utility.trace('g_HOL_YN         :'||g_HOL_YN);
	  hr_utility.trace('p_sdf_id         :'||p_sdf_id);
	  hr_utility.trace('g_OSP_ID         :'||g_OSP_ID);
	  hr_utility.trace('p_sdovr_id       :'||p_sdovr_id);
	  hr_utility.trace('p_time_in        :'||to_char(p_time_in,'DD-MON-YYYY HH24:MI:SS'));
	  hr_utility.trace('p_time_out       :'||to_char(p_time_out,'DD-MON-YYYY HH24:MI:SS'));
  end if;
  FOR elig_prem_rec IN cur_elig_prem
  LOOP

    if g_debug then
    	   hr_utility.set_location('hxt_time_pay.Gen_Premiums',60);
    end if;
/*
 -- Check if the hxt_earning_category is Shift Differential Override.
 -- If yes,then check whether the employee has worked other than their
 -- regular shift ,because the employee gets paid premium only for hours
 -- worked other than their regular shifts.

  IF elig_prem_rec.hxt_earning_category <> 'SDF' THEN
     if g_debug then
     	    hr_utility.set_location('hxt_time_pay.Gen_Premiums',61);
     end if;
     lv_elig_for_prem := TRUE;
  END IF;

  IF elig_prem_rec.hxt_earning_category = 'SDF' THEN
     if g_debug then
     	    hr_utility.set_location('hxt_time_pay.Gen_Premiums',62);
     end if;

     open  Get_Shift_Info( g_ASSIGNMENT_ID,g_DATE_WORKED );
     fetch Get_Shift_Info into lv_rotation_plan ,lv_tws_id ,lv_week_day
                              ,lv_standard_start ,lv_standard_stop;

     if g_debug then
     	    hr_utility.set_location('hxt_time_pay.Gen_Premiums',63);
     end if;
     close Get_Shift_Info;

     if g_debug then
	     hr_utility.trace('lv_rotation_plan :'||lv_rotation_plan);
	     hr_utility.trace('lv_tws_id        :'||lv_tws_id);
	     hr_utility.trace('lv_week_day      :'||lv_week_day);
	     hr_utility.trace('lv_standard_start:'||lv_standard_start);
	     hr_utility.trace('lv_standard_stop :'||lv_standard_stop);
	     hr_utility.set_location('hxt_time_pay.Gen_Premiums',64);

	     hr_utility.trace('p_time_in  :'||to_char(p_time_in,'HH24MI'));
	     hr_utility.trace('p_time_out :'||to_char(p_time_out,'HH24MI'));

	     hr_utility.trace('p_time_in :'||to_number(to_char(p_time_in,'HH24MI')));
	     hr_utility.trace('p_time_out:'||to_number(to_char(p_time_out,'HH24MI')));
     end if;
     IF lv_standard_start = 0 AND lv_standard_stop = 0
        AND g_osp_id is NOT NULL THEN -- for off shift days

        if g_debug then
               hr_utility.set_location('hxt_time_pay.Gen_Premiums',64.1);
        end if;
        lv_elig_for_prem := TRUE;     -- Thus for an off day shift the
                                      -- shift prem gets paid too
                                      -- along with the off shift premium
     END IF;

      -- now the logic for Working days
      -- Checking for the time in and outs for which the employee is
      -- eligible for the Shift Differential Premium

      -- IF shift diff Override is defined for the day but is out of
      -- range of time_in and time_out OR there are no shift Overrides for
      -- the day and the shift diff policy is applicable to time_in and
      -- time_out
      IF (p_sdf_id <> g_sdovr_id OR g_sdovr_id is NULL)
       AND to_number(to_char(p_time_in,'HH24MI')) >= lv_standard_start
       AND to_number(to_char(p_time_out,'HH24MI')) <= lv_standard_stop THEN

     -- i.e., If shift differential policy is applicable to time_in and
     -- time_outs
           if g_debug then
           	  hr_utility.set_location('hxt_time_pay.Gen_Premiums',64.2);
           end if;
           lv_elig_for_prem := TRUE;

      ELSIF p_sdf_id = g_sdovr_id THEN

     -- i.e.,IF the shift differential override is applicable to the time_in and
     -- time_outs ,then p_sdf_id has been set to g_sdovr_id n hxt_time_summary.
     -- gen_details ,so that the cursor cur_elig_prem returns a row and the
     -- logic gets called to insert the data into hxt_det_hours_worked

           if g_debug then
           	  hr_utility.set_location('hxt_time_pay.Gen_Premiums',64.3);
           end if;
           lv_elig_for_prem := TRUE;
      END IF;

  if g_debug then
  	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',67);
  end if;
  END IF;

  IF lv_elig_for_prem = TRUE THEN

       if g_debug then
       	      hr_utility.set_location('hxt_time_pay.Gen_Premiums',68);
       end if;
*/
    -- Default override multiple to override multiple in summary hour
    -- record (usually null)
       l_mult := g_RATE_MULTIPLE;
       l_rate := g_HOURLY_RATE;  -- ORA131
       if g_debug then
       	      hr_utility.trace('l_mult :'||l_mult);
              hr_utility.trace('l_rate :'||l_rate);
       end if;
    --
    -- Default the hours worked zero if prem type is fixed -- SIR092
    --
            IF elig_prem_rec.hxt_premium_type = 'FIXED' and p_hours <> 0
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_pay.Gen_Premiums', 70);
               END IF;

               l_hours := 0;
               l_time_in := NULL;
               l_time_out := NULL;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_hours :' || l_hours);
                  hr_utility.TRACE ('l_time_in:' || l_time_in);
                  hr_utility.TRACE ('l_time_out:' || l_time_out);
               END IF;
	    ELSIF elig_prem_rec.hxt_premium_type = 'FIXED' and p_hours = 0
	    THEN
	       return 0;
            ELSE
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_pay.Gen_Premiums', 80);
               END IF;

               l_hours := p_hours;
               l_time_in := p_time_in;
               l_time_out := p_time_out;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_hours :' || l_hours);
                  hr_utility.TRACE (   'l_time_in:'
                                    || TO_CHAR (l_time_in,
                                                'dd-mon-yyyy hh24:mi:ss'
                                               )
                                   );
                  hr_utility.TRACE (   'l_time_out:'
                                    || TO_CHAR (l_time_out,
                                                'dd-mon-yyyy hh24:mi:ss'
                                               )
                                   );
               END IF;
            END IF;

 -- Check if override multiple is applicable
    IF elig_prem_rec.hxt_premium_type = 'FACTOR' THEN
         if g_debug then
         	hr_utility.set_location('hxt_time_pay.Gen_Premiums',90);
         end if;

      -- Step through the premium detail records of type factor that
      -- were already inserted into the hours worked table - all are
      -- lower priority than the current premium.  By matching up against
      -- the interaction rules, we can deal only with the interacting
      -- premiums.
      -- Derive override multiple

       <<prem_intr>>

         if g_debug then
         	hr_utility.set_location('hxt_time_pay.Gen_Premiums',100);
         end if;

         FOR prem_intr_rec IN cur_prem_intr(elig_prem_rec.elt_premium_id
                                           ,elig_prem_rec.hxt_processing_order)
         LOOP
           if g_debug then
           	  hr_utility.set_location('hxt_time_pay.Gen_Premiums',110);
           end if;

           IF prem_intr_rec.hxt_premium_type = 'FACTOR' THEN  --SIR190
              if g_debug then
              	     hr_utility.set_location('hxt_time_pay.Gen_Premiums',120);
              end if;

           -- SIR103 We must strip off the 1 from overtime premium
           -- so that it will be treated like any other premium in the
           -- interaction calculations. PWM

              IF elig_prem_rec.hxt_earning_category = 'OVT' THEN --SIR103 ORA131
                 if g_debug then
                 	hr_utility.set_location('hxt_time_pay.Gen_Premiums',130);
                 end if;
                 l_mult := nvl(g_RATE_MULTIPLE
                              ,elig_prem_rec.hxt_premium_amount) -1 ; --SIR103
                 if g_debug then
                 	hr_utility.trace('l_mult  :'||l_mult);
                 end if;
              ELSE                                                    --SIR103
                 if g_debug then
                 	hr_utility.set_location('hxt_time_pay.Gen_Premiums',140);
                 end if;
                 l_mult := nvl(g_RATE_MULTIPLE
                              ,elig_prem_rec.hxt_premium_amount)  ;   --SIR103
                 if g_debug then
                 	hr_utility.trace('l_mult  :'||l_mult);
                 end if;
              END IF;                                                 --SIR103

           -- SIR103 We must strip off the 1 from overtime premium
           -- so that it will be treated like any other premium in
           -- the interaction calculations. PWM

              IF prem_intr_rec.hxt_earning_category = 'OVT' THEN      --SIR103
                 if g_debug then
                 	hr_utility.set_location('hxt_time_pay.Gen_Premiums',150);
                 end if;
                 prem_intr_rec.multiple := prem_intr_rec.multiple -1 ;--SIR103
              END IF;                                                 --SIR103
           --
           -- ORACLE #464850 & #465434 don't add 1 for overtime premiums
           --
           -- If any matches are found, we switch from a null value to the
           -- percentage portion of the value.  For example, if the factor
	   -- is 1.15, then the premium is 15% of the base.  We then adjust
	   -- the multiple by applying the factors of the premium earned
	   -- previously.

              if g_debug then
              	     hr_utility.set_location('hxt_time_pay.Gen_Premiums',160);
              end if;
              l_mult := nvl(prem_intr_rec.multiple,0) + l_mult * nvl(prem_intr_rec.multiple,1);  --SIR103
              if g_debug then
              	     hr_utility.trace('l_mult :'||l_mult);
              end if;

           -- SIR103 We must add back the 1 that was stripped off before
	   -- the calculation. PWM

              IF prem_intr_rec.hxt_earning_category = 'OVT' THEN
                 if g_debug then
                 	hr_utility.set_location('hxt_time_pay.Gen_Premiums',170);
                 end if;
                 l_mult := l_mult + 1 ;
                 if g_debug then
                 	hr_utility.trace('l_mult :'||l_mult);
                 end if;
              END IF;

           ELSE
                 if g_debug then
                 	hr_utility.set_location('hxt_time_pay.Gen_Premiums',180);
                 end if;
              -- Premium was RATE or FIXED, but not FACTOR so don't
              -- change the multiple

              IF elig_prem_rec.hxt_earning_category = 'OVT' THEN
                 if g_debug then
                 	hr_utility.set_location('hxt_time_pay.Gen_Premiums',190);
                 end if;
                 l_mult := nvl(g_RATE_MULTIPLE
                              ,elig_prem_rec.hxt_premium_amount) -1 ;
                 if g_debug then
                 	hr_utility.trace('l_mult :'||l_mult);
                 end if;
              ELSE
                 if g_debug then
                 	hr_utility.set_location('hxt_time_pay.Gen_Premiums',200);
                 end if;
                 l_mult := nvl(g_RATE_MULTIPLE
                              ,elig_prem_rec.hxt_premium_amount);
                 if g_debug then
                 	hr_utility.trace('l_mult :'||l_mult);
                 end if;
              END IF;

              if g_debug then
              	     hr_utility.set_location('hxt_time_pay.Gen_Premiums',210);
              end if;
              l_rate := prem_intr_rec.multiple + (l_mult * prem_intr_rec.multiple);
              l_mult := NULL;
              if g_debug then
              	     hr_utility.trace('l_rate  :'||l_rate);
                     hr_utility.trace('l_mult  :'||l_mult);
              end if;
           END IF;

           if g_debug then
           	  hr_utility.set_location('hxt_time_pay.Gen_Premiums',220);
           end if;
           	  hrw_rowid := prem_intr_rec.hrwrowid;
           if g_debug then
                  hr_utility.trace('hrw_rowid :'||hrw_rowid);
           end if;
         END LOOP prem_intr;

    if g_debug then
    	   hr_utility.set_location('hxt_time_pay.Gen_Premiums',240);
    end if;
    END IF;  -- Factor premium

    --
    -- ORA131 MOD START(all code between start and end mark was added forORA131)
    --
       if g_debug then
       	      hr_utility.set_location('hxt_time_pay.Gen_Premiums',250);
       end if;
    --
    -- Check if override rate is applicable
    --
    IF elig_prem_rec.hxt_premium_type = 'RATE' THEN
       if g_debug then
       	      hr_utility.set_location('hxt_time_pay.Gen_Premiums',260);
       end if;
      -- Step through the premium detail records of type rate that
      -- were already inserted into the hours worked table - all are
      -- lower priority than the current premium.  By matching up against
      -- the interaction rules, we can deal only with the interacting
      -- premiums.
      -- Derive override rate

       <<prem_intr>>

         if g_debug then
         	hr_utility.set_location('hxt_time_pay.Gen_Premiums',270);
         end if;

         FOR prem_intr_rec IN cur_prem_intr(elig_prem_rec.elt_premium_id
                                           ,elig_prem_rec.hxt_processing_order)
         LOOP
             if g_debug then
             	    hr_utility.set_location('hxt_time_pay.Gen_Premiums',280);
             end if;

          -- SIR190 No calculations are needed for Rate premiums
          -- since these cannot interact with another premium,
          -- we simply write these out. PWM 08/20/98
          -- Reset override rate to override in summary hour record
          -- (usually null)

             l_rate := nvl(g_HOURLY_RATE
                          ,elig_prem_rec.hxt_premium_amount); --SIR190
             if g_debug then
             	    hr_utility.trace('l_rate :'||l_rate);
                    hr_utility.set_location('hxt_time_pay.Gen_Premiums',290);
             end if;
          -- The new rate is derived by multiplying the premium amount
          -- by the multiple of the interactive premium (which is most
          -- likely overtime)

          -- SIR103 We must strip off the 1 from overtime premium so that it
          -- will be treated like any other premium in the interaction
          -- calculations. PWM

          -- SIR103 We must add back the 1 that was stripped off before the
	  -- calculation. PWM

             hrw_rowid := prem_intr_rec.hrwrowid;
             if g_debug then
             	    hr_utility.trace('hrw_rowid :'||hrw_rowid);
                    hr_utility.set_location('hxt_time_pay.Gen_Premiums',300);
             end if;
         END LOOP prem_intr;

    if g_debug then
    	   hr_utility.set_location('hxt_time_pay.Gen_Premiums',320);
    end if;
    END IF;  -- Rate premium

 -- Check if OVT premium and override multiple was derived
    IF (l_mult is not null) THEN
        if g_debug then
        	hr_utility.set_location('hxt_time_pay.Gen_Premiums',330);
        end if;
     -- Update existing base-hour detail record

        BEGIN

          if g_debug then
          	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',340);
          end if;
          UPDATE hxt_det_hours_worked_f hrw
          SET    rate_multiple = l_mult
          WHERE  hrw.rowid     = hrw_rowid;
        EXCEPTION
          WHEN OTHERS THEN
          if g_debug then
          	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',350);
          end if;
          FND_MESSAGE.SET_NAME('HXT','HXT_39269_ORACLE_ERROR');
	  l_error_code := call_hxthxc_gen_error('HXT','HXT_39269_ORACLE_ERROR',NULL,l_location,'', sqlerrm);
          --2278400 l_error_code := call_gen_error(l_location,'', sqlerrm);
          if g_debug then
          	 hr_utility.trace('l_error_code  :'||l_error_code);
          end if;
        END;
    if g_debug then
    	   hr_utility.set_location('hxt_time_pay.Gen_Premiums',360);
    end if;
    END IF ;
--
-- ORA131 MOD START (all code between start and end mark was added for ORA131)
--
    IF (l_rate is not null) THEN
        if g_debug then
       	       hr_utility.set_location('hxt_time_pay.Gen_Premiums',370);
       	end if;

     -- Update existing base-hour detail record
        BEGIN

          if g_debug then
          	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',380);
          end if;
          UPDATE hxt_det_hours_worked_f hrw
          SET    hourly_rate = l_rate
          WHERE  hrw.rowid   = hrw_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            if g_debug then
            	   hr_utility.set_location('hxt_time_pay.Gen_Premiums',390);
            end if;
            FND_MESSAGE.SET_NAME('HXT','HXT_39269_ORACLE_ERROR');
	    l_error_code := call_hxthxc_gen_error('HXT','HXT_39269_ORACLE_ERROR',NULL,l_location,'', sqlerrm);
            --2278400 l_error_code := call_gen_error(l_location,'', sqlerrm);
            if g_debug then
            	   hr_utility.trace('l_error_code :'||l_error_code);
            end if;
        END;

    if g_debug then
    	   hr_utility.set_location('hxt_time_pay.Gen_Premiums',400);
    end if;
    END IF ;

    IF elig_prem_rec.hxt_earning_category <> 'OVT' THEN

       if g_debug then
       	      hr_utility.set_location('hxt_time_pay.Gen_Premiums',410);
       end if;
       get_retro_fields( g_tim_id
                        ,HXT_TIME_COLLECTION.g_batch_name
                        ,HXT_TIME_COLLECTION.g_batch_ref
                        ,l_pay_status
                        ,l_pa_status
                        ,l_retro_batch_id
                        ,l_error_status
                        ,l_sqlerrm);

       IF l_error_status = 0 THEN

          if g_debug then
          	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',420);
          end if;
          l_costable_type := HXT_UTIL.get_costable_type(
                                       elig_prem_rec.elt_premium_id
                                      ,g_DATE_WORKED
                                      ,g_ASSIGNMENT_ID);
          if g_debug then
          	 hr_utility.trace('l_costable_type :'||l_costable_type);
          end if;

          IF l_costable_type in ('C','F') THEN
             if g_debug then
             	    hr_utility.set_location('hxt_time_pay.Gen_Premiums',430);
             end if;
             l_ffv_cost_center_id := g_FFV_COST_CENTER_ID;
             if g_debug then
             	    hr_utility.trace('l_ffv_cost_center_id :'||l_ffv_cost_center_id);
             end if;
          ELSE
             if g_debug then
             	    hr_utility.set_location('hxt_time_pay.Gen_Premiums',440);
             end if;
             l_ffv_cost_center_id := NULL;
             if g_debug then
             	    hr_utility.trace('l_ffv_cost_center_id :'||l_ffv_cost_center_id);
             end if;
          END IF;
--
-- ORACLE Bug #464850 & #465434 Be sure the detail for time records
-- displays the premium amount for Fixed, Rate and Factor premium types.
--
   BEGIN

    if g_debug then
    	   hr_utility.set_location('hxt_time_pay.Gen_Premiums',450);
    end if;


/* INSERT into hxt_det_hours_worked_f
        (ID,PARENT_ID,TIM_ID,
          DATE_WORKED,ASSIGNMENT_ID,
          HOURS,TIME_IN,TIME_OUT,
          ELEMENT_TYPE_ID,FCL_EARN_REASON_CODE,
          FFV_COST_CENTER_ID,
          TAS_ID,LOCATION_ID,SHT_ID,
          HRW_COMMENT,FFV_RATE_CODE_ID,
          RATE_MULTIPLE,HOURLY_RATE,AMOUNT,
          FCL_TAX_RULE_CODE,SEPARATE_CHECK_FLAG,
          SEQNO,CREATED_BY,CREATION_DATE,
          LAST_UPDATED_BY,LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          EFFECTIVE_START_DATE,
          EFFECTIVE_END_DATE,
          PROJECT_ID,
          PAY_STATUS,
          PA_STATUS,
          RETRO_BATCH_ID
          --GROUP_ID
          )
        VALUES
         (hxt_seqno.nextval, g_ID, g_TIM_ID,
          g_DATE_WORKED, g_ASSIGNMENT_ID,
          l_hours, -- SIR092
          p_time_in, p_time_out,
          elig_prem_rec.elt_premium_id, '',
          l_ffv_cost_center_id,
          g_TAS_ID, g_LOCATION_ID, g_SHT_ID,
          g_HRW_COMMENT, g_FFV_RATE_CODE_ID,
          decode(elig_prem_rec.hxt_premium_type, 'FACTOR',
		 NVL(g_RATE_MULTIPLE, elig_prem_rec.hxt_premium_amount),
                 g_RATE_MULTIPLE),
          decode(elig_prem_rec.hxt_premium_type,
                 'RATE', NVL(g_HOURLY_RATE, elig_prem_rec.hxt_premium_amount),
                 g_HOURLY_RATE),
          decode(elig_prem_rec.hxt_premium_type,
                 'FIXED', NVL(g_AMOUNT, elig_prem_rec.hxt_premium_amount),
                 g_AMOUNT),
          g_FCL_TAX_RULE_CODE, g_SEPARATE_CHECK_FLAG,
          l_seqno, g_CREATED_BY, g_CREATION_DATE,
          g_LAST_UPDATED_BY, g_LAST_UPDATE_DATE,
          g_LAST_UPDATE_LOGIN,
          g_EFFECTIVE_START_DATE,
          g_EFFECTIVE_END_DATE,
          g_project_id,
          l_pay_status,
          l_pa_status,
          l_retro_batch_id
          --g_group_id
          );         */



     /* Call dml to insert hours */

        SELECT hxt_seqno.nextval,
	       decode(elig_prem_rec.hxt_premium_type, 'FACTOR',
		      NVL(g_RATE_MULTIPLE, elig_prem_rec.hxt_premium_amount),
		      g_RATE_MULTIPLE),
               decode(elig_prem_rec.hxt_premium_type, 'RATE', NVL(g_HOURLY_RATE,
                      elig_prem_rec.hxt_premium_amount), g_HOURLY_RATE),
               decode(elig_prem_rec.hxt_premium_type, 'FIXED', NVL(g_AMOUNT,
                      elig_prem_rec.hxt_premium_amount), g_AMOUNT)
        INTO l_id,
             l_rate_multiple,
             l_hourly_rate,
             l_amount
	FROM dual;

        if g_debug then
		hr_utility.trace('l_id            :'||l_id);
		hr_utility.trace('l_rate_multiple :'||l_rate_multiple);
		hr_utility.trace('l_hourly_rate   :'||l_hourly_rate);
		hr_utility.trace('l_amount        :'||l_amount);
		hr_utility.set_location('hxt_time_pay.Gen_Premiums',460);
        end if;
	hxt_dml.insert_HXT_DET_HOURS_WORKED(
	   p_rowid        		=> l_rowid,
	   p_id                     	=> l_id,
	   p_parent_id              	=> g_id,
	   p_tim_id                 	=> g_tim_id,
	   p_date_worked           	=> g_date_worked,
	   p_assignment_id         	=> g_assignment_id,
	   p_hours                 	=> l_hours,
	   p_time_in               	=> p_time_in,
	   p_time_out              	=> p_time_out,
	   p_element_type_id       	=> elig_prem_rec.elt_premium_id,
	   p_fcl_earn_reason_code 	=> NULL,
	   p_ffv_cost_center_id   	=> l_ffv_cost_center_id,
	   p_ffv_labor_account_id	=> NULL,
	   p_tas_id             	=> g_tas_id,
	   p_location_id       		=> g_location_id,
	   p_sht_id           		=> g_sht_id,
	   p_hrw_comment     		=> g_hrw_comment,
	   p_ffv_rate_code_id      	=> g_ffv_rate_code_id,
	   p_rate_multiple      	=> l_rate_multiple,
	   p_hourly_rate        	=> l_hourly_rate,
	   p_amount             	=> l_amount,
	   p_fcl_tax_rule_code 		=> g_fcl_tax_rule_code,
	   p_separate_check_flag  	=> g_separate_check_flag,
	   p_seqno               	=> l_seqno,
	   p_created_by         	=> g_created_by,
	   p_creation_date     		=> g_creation_date,
	   p_last_updated_by  		=> g_last_updated_by,
	   p_last_update_date      	=> g_last_update_date,
	   p_last_update_login    	=> g_last_update_login,
	   p_actual_time_in     	=> NULL,
	   p_actual_time_out   		=> NULL,
	   p_effective_start_date 	=> g_effective_start_date,
	   p_effective_end_date  	=> g_effective_end_date,
	   p_project_id         	=> g_project_id,
	   p_job_id           		=> NULL,
	   p_earn_pol_id     		=> NULL,
	   p_retro_batch_id 		=> l_retro_batch_id,
	   p_pa_status     		=> l_pa_status,
	   p_pay_status   		=> l_pay_status,
	   --p_group_id			=> g_group_id,
	   p_object_version_number 	=> l_object_version_number,
           p_STATE_NAME                 => g_STATE_NAME,
	   p_COUNTY_NAME                => g_COUNTY_NAME,
	   p_CITY_NAME                  => g_CITY_NAME,
	   p_ZIP_CODE                   => g_ZIP_CODE);

        if g_debug then
        	hr_utility.set_location('hxt_time_pay.Gen_Premiums',470);
        end if;


      EXCEPTION
        WHEN OTHERS THEN
          if g_debug then
          	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',480);
          end if;
          FND_MESSAGE.SET_NAME('HXT','HXT_39269_ORACLE_ERROR');
	  l_error_code := call_hxthxc_gen_error('HXT','HXT_39269_ORACLE_ERROR',NULL,l_location,'', sqlerrm);
          --2278400 l_error_code := call_gen_error(l_location,'', sqlerrm);
          if g_debug then
          	 hr_utility.trace('l_error_code :'||l_error_code);
          end if;
        END;
        ELSE
          if g_debug then
          	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',490);
          end if;
          FND_MESSAGE.SET_NAME('HXT','HXT_39421_GET_RETRO_ERR');
	  l_error_code := call_hxthxc_gen_error('HXT','HXT_39421_GET_RETRO_ERR',NULL,p_location||':INS', '',sqlerrm);
          --2278400 l_error_code := call_gen_error(p_location||':INS', '',sqlerrm);
          if g_debug then
          	 hr_utility.trace('l_error_code :'||l_error_code);
          end if;
        END IF;

      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.Gen_Premiums',500);
      end if;
   -- Increment line sequence number
      l_seqno := l_seqno + 10;
      if g_debug then
      	     hr_utility.trace('l_seqno :'||l_seqno);
      end if;
    END IF;

     if g_debug then
     	    hr_utility.set_location('hxt_time_pay.Gen_Premiums',505);
     end if;
 --  END IF; -- END IF lv_elig_for_prem := TRUE
  if g_debug then
  	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',510);
  end if;
  END LOOP  elig_prem;

  if g_debug then
  	 hr_utility.set_location('hxt_time_pay.Gen_Premiums',520);
  end if;
  RETURN  l_error_code;

  EXCEPTION
    WHEN OTHERS THEN
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.Gen_Premiums',530);
      end if;
      FND_MESSAGE.SET_NAME('HXT','HXT_39269_ORACLE_ERROR');
      RETURN call_hxthxc_gen_error('HXT','HXT_39269_ORACLE_ERROR',NULL,l_location,'', sqlerrm);
      --2278400 RETURN call_gen_error(l_location,'', sqlerrm);
END; --  gen_premiums
--

--
FUNCTION local_pay( p_hours_to_pay IN NUMBER,
              	    p_pay_element_type_id IN NUMBER,
              	    p_time_in  IN DATE,
              	    p_time_out IN DATE) RETURN NUMBER IS

--  Returns 0 for normal  2 for errors
--  Calls insert hours and gen premiums with times, hours, etc

-- Bug 7359347
-- Changed the below cursor to use base table instead of view.
/*
CURSOR next_seq_cur IS
   SELECT nvl(max(seqno),0) next_seq
   FROM hxt_det_hours_worked --C421
   WHERE parent_id = g_id
   AND tim_id = g_tim_id
   AND date_worked = g_date_worked;
*/
CURSOR next_seq_cur IS
   SELECT nvl(max(seqno),0) next_seq
   FROM hxt_det_hours_worked_f --C421
   WHERE parent_id = g_id
   AND tim_id = g_tim_id
   AND g_pay_session_date BETWEEN effective_start_date
                              AND effective_end_date
   AND date_worked = g_date_worked;


   new_record_id              NUMBER;
   pay_return_code            NUMBER;
   next_seq                   NUMBER;
   override_sd_id             NUMBER;

BEGIN

   if g_debug then
   	  hr_utility.set_location('hxt_time_pay.local_pay',10);
   end if;


   -- Bug 7359347
   -- Setting session date
   IF g_pay_session_date IS NULL
   THEN
      g_pay_session_date := hxt_tim_col_util.return_session_date;
   END IF;

-- Get next sequence number for SEQNO.
   OPEN next_seq_cur;
   FETCH next_seq_cur INTO next_seq;
   if g_debug then
   	  hr_utility.trace('next_seq :'||next_seq);
          hr_utility.set_location('hxt_time_pay.local_pay',20);
   end if;
   IF next_seq_cur%NOTFOUND THEN
      if g_debug then
      	     hr_utility.set_location('hxt_time_pay.local_pay',30);
      end if;
      FND_MESSAGE.SET_NAME('HXT','HXT_39290_NO_SEQ_NO_F_HRS_WKED');
      RETURN call_hxthxc_gen_error('HXT','HXT_39290_NO_SEQ_NO_F_HRS_WKED',NULL,location, '');
      --RETURN call_gen_error(location, '');
   END IF;

   if g_debug then
   	  hr_utility.set_location('hxt_time_pay.local_pay',40);
   end if;
   next_seq := next_seq + 10;
   if g_debug then
   	  hr_utility.trace('next_seq :'||next_seq);
   end if;

   CLOSE next_seq_cur;

   if g_debug then
	   hr_utility.trace('p_hours_to_pay        :'||p_hours_to_pay);
	   hr_utility.trace('p_time_in             :'||p_time_in);
	   hr_utility.trace('p_time_out            :'||p_time_out);
	   hr_utility.trace('p_pay_element_type_id :'||p_pay_element_type_id);
	   hr_utility.trace('next_seq              :'||next_seq);
	   hr_utility.trace('location              :'||location);
   end if;
-- Call function to insert record in to hours worked table.
   if g_debug then
   	   hr_utility.set_location('hxt_time_pay.local_pay',50);
   end if;
   insert_hrs(pay_return_code,
	      new_record_id,
	      p_hours_to_pay,
	      p_time_in,
	      p_time_out,
              p_pay_element_type_id,
	      next_seq,
	      location);

   if g_debug then
   	   hr_utility.trace('pay_return_code :'||pay_return_code);
           hr_utility.trace('new_record_id   :'||new_record_id);
   	   hr_utility.set_location('hxt_time_pay.local_pay',60);
   end if;
-- Now generate all premiums for the record just inserted if
-- premiums are to be paid.
   if g_debug then
	   hr_utility.trace('g_pep_id        :'||g_pep_id);
	   hr_utility.trace('pay_return_code :'||pay_return_code);
	   hr_utility.trace('g_sdovr_id      :'||g_sdovr_id);
	   hr_utility.trace('g_sdf_id        :'||g_sdf_id);
   end if;
   IF g_pep_id IS NOT NULL AND pay_return_code = 0 THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_pay.local_pay',70);
      end if;
   -- Commented out this and passing both sdf_id and sdovr_id to GEN_PREMIUMS
   -- because we need both the values to determine which gets applied to the
   -- incoming time_in and time_outs
   -- override_sd_id := NVL(g_sdovr_id, g_sdf_id);
      if g_debug then
	      hr_utility.trace('override_sd_id :'||override_sd_id);

	      hr_utility.trace('g_sdf_id  :'||g_sdf_id);
	      hr_utility.trace('g_sdovr_id:'||g_sdovr_id);
      end if;
      pay_return_code := gen_premiums(g_sdf_id,
                                      g_sdovr_id,
				      location,
				      new_record_id,
				      p_hours_to_pay,
                             	      p_time_in,
				      p_time_out,
				      p_pay_element_type_id,
				      next_seq);
      if g_debug then
      	      hr_utility.set_location('hxt_time_pay.local_pay',80);
      end if;
   END IF;
   if g_debug then
   	   hr_utility.set_location('hxt_time_pay.local_pay',90);
   end if;
   RETURN pay_return_code;
EXCEPTION
   WHEN OTHERS THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_pay.local_pay',100);
      end if;
      FND_MESSAGE.SET_NAME('HXT','HXT_39273_OR_ERR_IN_PAY_MDLE');
      RETURN call_hxthxc_gen_error('HXT','HXT_39273_OR_ERR_IN_PAY_MDLE',NULL,location, '', sqlerrm);
--      RETURN call_gen_error(location, '', sqlerrm);
END;   --local_pay



-- Bug 8855103
-- New function added to check whether this element is configured
-- for absences.
FUNCTION check_abs_elements( p_element_type_id IN NUMBER)
RETURN NUMBER
IS

   CURSOR get_abs_elem
       IS SELECT 1
            FROM hxc_absence_type_elements
           WHERE element_type_id = p_element_type_id;
 l_element  NUMBER;

BEGIN

     IF g_abstab.EXISTS(p_element_type_id)
     THEN
        RETURN g_abstab(p_element_type_id);
     ELSE
        OPEN get_abs_elem;
        FETCH get_abs_elem INTO l_element;
        CLOSE get_abs_elem;

        IF l_element = 1
        THEN
            g_abstab(p_element_type_id) := 1;
            RETURN 1;
        ELSE
            g_abstab(p_element_type_id) := 0;
            RETURN 0;
        END IF;
     END IF;

END check_abs_elements ;



BEGIN

   g_debug :=hr_utility.debug_enabled;
   if g_debug then
   	   hr_utility.set_location('hxt_time_pay.pay',10);
   end if;

   -- Bug 8855103
   -- Below construct added to throw error when
   -- configured absence type is included in OTLR explosion.
   IF g_debug
   THEN
       hr_utility.trace('ABS:g_element_type_id :'||g_element_type_id);
   END IF;

   l_abs := check_abs_elements(g_element_type_id);

   hr_utility.trace('ABS: l_abs :'||l_abs);

   IF l_abs = 1
   THEN
     FND_MESSAGE.SET_NAME('HXC','HXC_HXT_ABS_NO_OTLR');
     RETURN call_hxthxc_gen_error('HXC','HXC_HXT_ABS_NO_OTLR',NULL,location||':INS', FND_MESSAGE.GET, NULL);
   END IF;


   RETURN local_pay(g_hours,
		    g_element_type_id,
		    g_time_in,
		    g_time_out);
   if g_debug then
   	   hr_utility.set_location('hxt_time_pay.pay',20);
   end if;

EXCEPTION
   WHEN OTHERS THEN
     if g_debug then
     	     hr_utility.set_location('hxt_time_pay.pay',30);
     end if;
     FND_MESSAGE.SET_NAME('HXT','HXT_39269_ORACLE_ERROR');
     RETURN call_hxthxc_gen_error('HXT','HXT_39269_ORACLE_ERROR',NULL,location, '', sqlerrm);
     --2278400 RETURN call_gen_error(location, '', sqlerrm);
END;  --  END pay

--begin

END;  --  package hxt_time_pay

/
