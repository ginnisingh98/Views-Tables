--------------------------------------------------------
--  DDL for Package Body HXT_RETRO_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_RETRO_VAL" AS
/* $Header: hxtrval.pkb 120.4 2007/01/05 18:24:05 nissharm noship $ */
   -- Global package name
   g_package   CONSTANT VARCHAR2 (33) := 'hxt_retro_val.';
   g_debug boolean := hr_utility.debug_enabled;
   -- ancient relic that we need to remove later and place in hxt_batch_process,
   -- the only code that calss this thing.
   PROCEDURE mark_rows_complete (p_batch_id IN NUMBER)
   IS
      l_user_id   fnd_user.user_id%TYPE   := fnd_global.user_id;
   BEGIN

-- the following sql has been condensed from the view creation statements
-- for HXT_BATCH_SUM_HOURS_V
--     HXT_BATCH_SUM_AMOUNTS_V
--     HXT_BATCH_SUM_AMOUNTS_HOURS_V
-- The views were used to transfer to paymix just prior to the call to
-- this function.  This SQL could be further condensed, but I don't want
-- to do that yet, if ever.  That's because if the above views change,
-- for whatever reason, leaving this sql as is will make it easier to make
-- changes here to reflect those changes.

      UPDATE hxt_det_hours_worked_f
         SET pay_status = 'C',
             last_update_login = l_user_id,
             last_update_date = SYSDATE
       WHERE ROWID IN
                   (
/* batch_sum_amounts  rows with override Amount<>0, Hours=0*/
                    SELECT hrw.ROWID
                      FROM hxt_timecards_x tim, -- commenting out. using sysdate view, now. RTF
                                               hxt_det_hours_worked_x hrw -- commenting out. using sysdate view, now. RTF

-- begin OHMPERFFIX - performance fix done by Bryan Crissman and Damon
--                    Grube at OHM.  the Where rowid in () or rowid in ()
--                    construct was causing large numbers of rows to be
--                    returned.
                     WHERE hrw.parent_id > 0
                       AND tim.id = hrw.tim_id
                       AND tim.batch_id = p_batch_id
                       AND (   (    NVL (hrw.amount, 0) <> 0
                                AND NVL (hrw.hours, 0) = 0
                               )

/* batch_sum_amounts_hours  rows with override Amount=0, Hours <>0*/
                            OR (    NVL (hrw.amount, 0) = 0
                                AND NVL (hrw.hours, 0) <> 0
                               )
                           ));
   END;

   PROCEDURE val_retro_timecard (
      p_batch_id        IN              NUMBER,
      p_tim_id          IN              NUMBER,
      p_valid_retcode   IN OUT NOCOPY   NUMBER,
      p_merge_flag	IN		VARCHAR2 DEFAULT '0',
      p_merge_batches   OUT NOCOPY      HXT_BATCH_PROCESS.MERGE_BATCHES_TYPE_TABLE
   )
   IS
      l_proc       VARCHAR2 (72);
      l_cnt        BINARY_INTEGER;

      CURSOR csr_additional_info (p_tim_id hxt_timecards_f.id%TYPE)
      IS
         SELECT DISTINCT htx.for_person_id, htx.time_period_id,
                         htx.approv_person_id, htx.auto_gen_flag
                    FROM hxt_timecards_x htx
                   WHERE htx.id = p_tim_id;

      rec_additional_info   csr_additional_info%ROWTYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
      	     l_proc :=    g_package
                             || 'val_retro_timecard';
      	     hr_utility.set_location (   'Entering:'
                                      || l_proc, 10);
      end if;
      hxt_batch_val.reset_error_level;
      hxt_batch_val.delete_prev_val_errors (p_tim_id => p_tim_id);
      OPEN csr_additional_info (p_tim_id);
      FETCH csr_additional_info INTO rec_additional_info;

      IF (hxt_batch_val.errors_exist (p_tim_id => p_tim_id))
      THEN
         p_valid_retcode := 2;
      ELSE
         hxt_batch_val.validate_tc (
            p_batch_id=> p_batch_id,
            p_tim_id=> p_tim_id,
            p_person_id=> rec_additional_info.for_person_id,
            p_period_id=> rec_additional_info.time_period_id,
            p_approv_person_id=> rec_additional_info.approv_person_id,
            p_auto_gen_flag=> rec_additional_info.auto_gen_flag,
            p_error_level=> p_valid_retcode
         );
      END IF;

      /********Bug: 4620315 **********/
      /*** To record the validated timecards details ***/

      IF p_merge_flag = '1' THEN
	 if g_debug then
	    hr_utility.trace('Populating merge_batches record'||' batch_id: '||p_batch_id||' tc_id '||p_tim_id);
	 end if;
         l_cnt := NVL(p_merge_batches.LAST,0) +1;

	 p_merge_batches(l_cnt).batch_id	      := p_batch_id;
	 p_merge_batches(l_cnt).tc_id		      := p_tim_id;
	 p_merge_batches(l_cnt).valid_tc_retcode      := p_valid_retcode;

      END IF;

      /********Bug: 4620315 **********/

      CLOSE csr_additional_info;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END val_retro_timecard;
END hxt_retro_val;

/
