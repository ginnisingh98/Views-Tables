--------------------------------------------------------
--  DDL for Package Body HXC_TIMESTORE_DEPOSIT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMESTORE_DEPOSIT_UTIL" AS
/* $Header: hxctsdputil.pkb 120.17.12010000.12 2010/03/05 09:17:13 sabvenug ship $ */

   -- Global package name
   g_package         CONSTANT VARCHAR2 (33)
                                           := '  hxc_timestore_deposit_util.';
   g_oit_migration   CONSTANT VARCHAR2 (30) := 'OIT_MIGRATION';
   g_debug                    BOOLEAN       := hr_utility.debug_enabled;

   FUNCTION perform_audit (
      p_props    IN   hxc_timecard_prop_table_type,
      p_blocks   IN   hxc_block_table_type
   )
      RETURN BOOLEAN
   AS
      l_cla_terg_id   NUMBER  := NULL;
      l_audit         BOOLEAN;
   BEGIN
      l_cla_terg_id :=
         TO_NUMBER
            (hxc_timecard_properties.find_property_value
                (p_props,
                 'TsPerAuditRequirementsAuditRequirements',
                 NULL,
                 NULL,
                 p_start_date      => fnd_date.canonical_to_date
                                         (p_blocks
                                             (hxc_timecard_block_utils.find_active_timecard_index
                                                                     (p_blocks)
                                             ).start_time
                                         ),
                 p_stop_date       => fnd_date.canonical_to_date
                                         (p_blocks
                                             (hxc_timecard_block_utils.find_active_timecard_index
                                                                     (p_blocks)
                                             ).stop_time
                                         )
                )
            );

      IF (l_cla_terg_id IS NOT NULL)
      THEN
         l_audit := TRUE;
      ELSE
         l_audit := FALSE;
      END IF;

      RETURN l_audit;
   END perform_audit;

-----------------------------------------------------------------------------
-- Type:           Function
-- Scope:          Public
-- Name:           get_retrieval_process_id
-- Returns:        NUMBER
-- IN Parameters:  p_retrieval_process_name -> Name of the retrieval process for
--                                             which you want to get the ID
--
-- Description:   This function will return the Id of the retrieval process
--                passed in.
--
-----------------------------------------------------------------------------
   FUNCTION get_retrieval_process_id (
      p_retrieval_process_name   IN   hxc_retrieval_processes.NAME%TYPE
   )
      RETURN hxc_retrieval_processes.retrieval_process_id%TYPE
   IS
      l_proc                   VARCHAR2 (72);

      CURSOR csr_retrieval_process_id (v_retrieval_process_name IN VARCHAR2)
      IS
         SELECT retrieval_process_id
           FROM hxc_retrieval_processes
          WHERE NAME = v_retrieval_process_name;

      l_retrieval_process_id   hxc_retrieval_processes.retrieval_process_id%TYPE;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'get_retrieval_process_id';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      OPEN csr_retrieval_process_id (p_retrieval_process_name);

      FETCH csr_retrieval_process_id
       INTO l_retrieval_process_id;

      IF csr_retrieval_process_id%NOTFOUND
      THEN
         fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token ('PROCEDURE', l_proc);
         fnd_message.set_token ('STEP', '1');
         fnd_msg_pub.ADD;
      END IF;

      CLOSE csr_retrieval_process_id;

      IF g_debug
      THEN
         hr_utility.set_location (   '   returning retrieval process id = '
                                  || l_retrieval_process_id,
                                  20
                                 );
         hr_utility.set_location ('Leaving:' || l_proc, 30);
      END IF;

      RETURN l_retrieval_process_id;
   END get_retrieval_process_id;

-----------------------------------------------------------------------------
-- Type:          Function
-- Scope:         Public
-- Name:          approval_style_id
-- Returns:       hxc_approval_styles.approval_style_id
-- IN Parameters: p_approval_style_name -> Name of the approval style for which
--                                         you want to find the ID
--
-- Description:   Private Function that return the ID of the 'OTL Auto Approve'
--                approval.
--
-----------------------------------------------------------------------------
   FUNCTION approval_style_id (
      p_approval_style_name   hxc_approval_styles.NAME%TYPE
   )
      RETURN hxc_approval_styles.approval_style_id%TYPE
   IS
      l_proc                VARCHAR2 (72);
      l_approval_style_id   hxc_approval_styles.approval_style_id%TYPE;

      CURSOR csr_approval_style_id (p_name hxc_approval_styles.NAME%TYPE)
      IS
         SELECT has.approval_style_id
           FROM hxc_approval_styles has
          WHERE has.NAME = p_name;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'approval_style_id';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      OPEN csr_approval_style_id (p_approval_style_name);

      FETCH csr_approval_style_id
       INTO l_approval_style_id;

      CLOSE csr_approval_style_id;

      IF g_debug
      THEN
         hr_utility.set_location (   '   returning approval_style_id = '
                                  || l_approval_style_id,
                                  20
                                 );
         hr_utility.set_location ('Leaving:' || l_proc, 30);
      END IF;

      RETURN l_approval_style_id;
   END approval_style_id;

-----------------------------------------------------------------------------
-- Type:          Procedure
-- Scope:         Public
-- Name:          begin_approval
-- IN Parameters: p_blocks
--
-- Description:   Public Procedure that can be used to start the approval
--                process.
--
-----------------------------------------------------------------------------
   PROCEDURE begin_approval (
      p_timecard_id   IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_blocks        IN   hxc_block_table_type
   )
   IS
      l_proc             VARCHAR2 (72);
      l_resubmit         VARCHAR2 (10)            := hxc_timecard.c_no;
      l_item_key         wf_items.item_key%TYPE   := NULL;
      l_messages         hxc_message_table_type := hxc_message_table_type();
      l_timecard_props   hxc_timecard_prop_table_type := hxc_timecard_prop_table_type();
      l_timecard_index   number;
      l_message          fnd_new_messages.message_text%type;
      TC_APPROVAL_EXCEPTION  EXCEPTION;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'begin_approval';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- set savepoint
      savepoint TC_APPROVAL_SAVEPOINT;

      l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);

      hxc_timecard_properties.get_preference_properties
        (p_validate             => hxc_timecard.c_no,
         p_resource_id          => p_blocks(l_timecard_index).resource_id,
         p_timecard_start_time  => hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).start_time),
         p_timecard_stop_time   => hxc_timecard_block_utils.date_value(p_blocks(l_timecard_index).stop_time),
         p_for_timecard         => false,
         p_timecard_bb_id       => p_timecard_id,
         p_timecard_bb_ovn      => p_blocks(l_timecard_index).object_version_number,
         p_messages             => l_messages,
         p_property_table       => l_timecard_props
         );

      hxc_timecard_message_helper.processerrors
        (p_messages => l_messages);

      -- Determine if this is a resubmitted timecard
      l_timecard_index :=
                hxc_timecard_block_utils.find_active_timecard_index (p_blocks);

      IF (hxc_timecard_block_utils.date_value
                                           (p_blocks (l_timecard_index).date_to
                                           ) = hr_general.end_of_time
         )
      THEN
         l_resubmit :=
            hxc_timecard_approval.is_timecard_resubmitted
               (p_blocks (l_timecard_index).time_building_block_id,
                p_blocks (l_timecard_index).object_version_number,
                p_blocks (l_timecard_index).resource_id,
                fnd_date.canonical_to_date
                                        (p_blocks (l_timecard_index).start_time
                                        ),
                fnd_date.canonical_to_date
                                         (p_blocks (l_timecard_index).stop_time
                                         )
               );
      ELSE
         l_resubmit := hxc_timecard.c_delete;
      END IF;

      l_item_key :=
         hxc_timecard_approval.begin_approval
                                            (p_blocks            => p_blocks,
                                             p_item_type         => 'HXCEMP',
                                             p_process_name      => 'HXC_APPROVAL',
                                             p_resubmitted       => l_resubmit,
                                             p_timecard_props    => l_timecard_props,
                                             p_messages          => l_messages
                                            );

      -- Absences start

  	 IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y')  THEN
		hr_utility.trace('ABS:Checking status of BEGIN_APPROVAL');
		hr_utility.trace('ABS:l_messages.COUNT = '||l_messages.COUNT);

		if l_messages.COUNT > 0
		then
		  hr_utility.trace('ABS:Error in POST_ABSENCES - Rollback changes');

    		  l_message := fnd_message.get_string (
           		appin      => l_messages(l_messages.last).application_short_name
        	      , namein     => l_messages(l_messages.last).message_name
         		);

    		  --dbms_output.put_line('online retrieval error : '||substr(l_message,1,255));

   	          rollback to TC_APPROVAL_SAVEPOINT;

	  	  hxc_timecard_message_helper.processerrors
  	        	    (p_messages => l_messages);
		end if;
  	  END IF;

      -- Absences end

      hxc_timecard_message_helper.processerrors
        (p_messages => l_messages);

      hxc_timecard_summary_pkg.update_summary_row
                                   (p_timecard_id                => p_timecard_id,
                                    p_approval_item_type         => 'HXCEMP',
                                    p_approval_process_name      => 'HXC_APPROVAL',
                                    p_approval_item_key          => l_item_key
                                   );

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 100);
      END IF;
   END begin_approval;

-----------------------------------------------------------------------------
-- Type:          Procedure
-- Scope:         Public
-- Name:          save_timecard
-- IN OUT Parameters: p_blocks -> The Timecard structure you want Save
--                    p_attributes -> The Timecard's attributes you want to Save
--                    p_messages -> The messages returned from the Save process
-- OUT Parameters: p_timecard_id -> The timecard_id of the saved Timecard
--                 p_timecard_ovn -> the OVN  of the saved Timecard
--
-- Description:   Private Procedure that can will be used to Save the timecard
--                (as oppose to Submit it). This will store the Timecard in the
--                DB with a status of WORKING. This whole procedure is mimicking
--                the Save as it happens in the deposit wrapper HXC_TIMECARD.
-----------------------------------------------------------------------------
   PROCEDURE save_timecard (
      p_blocks         IN OUT NOCOPY   hxc_block_table_type,
      p_attributes     IN OUT NOCOPY   hxc_attribute_table_type,
      p_messages       IN OUT NOCOPY   hxc_message_table_type,
      p_timecard_id    OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn   OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   )
   IS
      l_timecard_blocks    hxc_timecard.block_list;
      l_day_blocks         hxc_timecard.block_list;
      l_detail_blocks      hxc_timecard.block_list;
      l_transaction_info   hxc_timecard.transaction_info;
      l_timecard_props     hxc_timecard_prop_table_type;
      l_proc               VARCHAR2 (50)      := g_package || 'save_timecard';
      l_can_deposit        BOOLEAN            := TRUE;
      l_timecard_index     NUMBER;
      l_old_style_blks     hxc_self_service_time_deposit.timecard_info;
      l_old_style_attrs    hxc_self_service_time_deposit.building_block_attribute_info;
      l_old_messages       hxc_self_service_time_deposit.message_table;
      l_message            fnd_new_messages.message_text%type;

      l_resource_id      number;
      l_start_date 	 date;
      l_stop_date 	 date;
      l_tc_status        varchar2(20);


      TC_SAVE_EXCEPTION    EXCEPTION;

      l_timecard_start_time DATE;
      l_timecard_stop_time  DATE;

   BEGIN
      fnd_msg_pub.initialize;
      hxc_timecard_message_helper.initializeerrors;

      --This is done in the call to hxc_timecard_validation.deposit_validation
      --hxc_time_category_utils_pkg.push_timecard (p_blocks, p_attributes);

      p_messages := hxc_message_table_type ();
      hxc_timecard_block_utils.initialize_timecard_index;

      -- set savepoint
      savepoint TC_SAVE_SAVEPOINT;

      -- Check input parameters
      hxc_deposit_checks.check_inputs (p_blocks            => p_blocks,
                                       p_attributes        => p_attributes,
                                       p_deposit_mode      => hxc_timecard.c_save,
                                       p_template          => hxc_timecard.c_no,
                                       p_messages          => p_messages
                                      );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);
      -- First we are getting the preferences
      l_timecard_index :=
                hxc_timecard_block_utils.find_active_timecard_index (p_blocks);

      l_timecard_start_time :=
               fnd_date.canonical_to_date(p_blocks (l_timecard_index).start_time) ;

      l_timecard_stop_time :=
               fnd_date.canonical_to_date(p_blocks (l_timecard_index).stop_time) ;

      hxc_timecard_properties.get_preference_properties
         (p_validate                 => hxc_timecard.c_yes,
          p_resource_id              => p_blocks (l_timecard_index).resource_id,
          p_timecard_start_time      => l_timecard_start_time,
          p_timecard_stop_time       => l_timecard_stop_time,
          p_for_timecard             => FALSE,
          p_messages                 => p_messages,
          p_property_table           => l_timecard_props
         );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);

      -- Bug 9023209
      -- API absences validation
      hxc_retrieve_absences.verify_view_only_absences
                             (p_blocks => p_blocks,
                              p_attributes => p_attributes,
                              p_lock_rowid => hxc_retrieve_absences.g_lock_row_id,
                              p_messages => p_messages);

      -- p_messages.DELETE;
      -- Sort blocks
      hxc_timecard_block_utils.sort_blocks
                                      (p_blocks               => p_blocks,
                                       p_timecard_blocks      => l_timecard_blocks,
                                       p_day_blocks           => l_day_blocks,
                                       p_detail_blocks        => l_detail_blocks
                                      );
      --  Perform basic checks
      hxc_deposit_checks.perform_checks (p_blocks              => p_blocks,
                                         p_attributes          => p_attributes,
                                         p_timecard_props      => l_timecard_props,
                                         p_days                => l_day_blocks,
                                         p_details             => l_detail_blocks,
                                         p_messages            => p_messages
                                        );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);
      -- Add the security attributes
      -- ARR: 115.26 Add message structure
      hxc_security.add_security_attribute
                                         (p_blocks              => p_blocks,
                                          p_attributes          => p_attributes,
                                          p_timecard_props      => l_timecard_props,
                                          p_messages            => p_messages
                                         );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);
      -- Translate any aliases
      hxc_timecard_deposit_common.alias_translation
                                                (p_blocks          => p_blocks,
                                                 p_attributes      => p_attributes,
                                                 p_messages        => p_messages
                                                );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);

      -- Set the block and attribute update process flags Based on the data sent
      -- and in the db
      hxc_block_attribute_update.set_process_flags
                                                 (p_blocks          => p_blocks,
                                                  p_attributes      => p_attributes
                                                 );
      hxc_timecard_attribute_utils.remove_deleted_attributes
                                                 (p_attributes      => p_attributes);
/*
  Validate the set up for the user

  validate_setup
     (p_deposit_mode => hxc_timecard.c_save
     ,p_blocks       => p_blocks
     ,p_attributes   => p_attributes
     ,p_messages     => p_messages
     );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);
*/    -- Call time entry rules for save


/*
      l_old_style_blks :=
                    hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks);
      l_old_style_attrs :=
         hxc_timecard_attribute_utils.convert_to_dpwr_attributes (p_attributes);

      hxc_time_entry_rules_utils_pkg.execute_time_entry_rules
                                  (p_operation                 => hxc_timecard.c_save,
                                   p_time_building_blocks      => l_old_style_blks,
                                   p_time_attributes           => l_old_style_attrs,
                                   p_messages                  => l_old_messages,
                                   p_resubmit                  => hxc_timecard.c_no,
                                   p_blocks                    => p_blocks,
                                   p_attributes                => p_attributes
                                  );
      hxc_timecard_message_utils.append_old_messages
                                            (p_messages                  => p_messages,
                                             p_old_messages              => l_old_messages,
                                             p_retrieval_process_id      => NULL
                                            );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);
*/

     -- Added the following validation code for bug 8900783
     -- This validation is to check if the timecard start and stop times falls within the
     -- PAST and FUTURE number of days for which timecard create/edit is allowed
      IF g_debug THEN
      	hr_utility.trace('l_timecard_start_time = '||l_timecard_start_time);
      	hr_utility.trace('l_timecard_stop_time = '||l_timecard_stop_time);
      END IF;

      -- populate the global variables which hold the PAST and FUTURE date limits
      hxc_timestore_deposit_util.get_past_future_limits
      		(p_resource_id 	       => p_blocks (l_timecard_index).resource_id,
      		 p_timecard_start_time => trunc(l_timecard_start_time),
      		 p_timecard_stop_time  => trunc(l_timecard_stop_time),
      		 p_messages	       => p_messages
      		);

      hxc_timecard_message_helper.processerrors (p_messages => p_messages);



     -- Call  hxc_timecard_validation.deposit_validation to do this along with
     -- recipient application validation

     -- Validate blocks, attributes
      hxc_timecard_validation.deposit_validation
                                                 (p_blocks            => p_blocks,
                                                  p_attributes        => p_attributes,
                                                  p_messages          => p_messages,
                                                  p_props             => l_timecard_props,
                                                  p_deposit_mode      => hxc_timecard.c_save,
                                                  p_template          => hxc_timecard.c_no,
                                                  p_resubmit          => hxc_timecard.c_no,
                                                  p_can_deposit       => l_can_deposit
                                                 );


      hxc_timecard_message_helper.processerrors (p_messages => p_messages);

      -- Store blocks and attributes
      IF hxc_timecard_message_helper.noerrors
      THEN
         hxc_timecard_deposit.EXECUTE
                                    (p_blocks                => p_blocks,
                                     p_attributes            => p_attributes,
                                     p_timecard_blocks       => l_timecard_blocks,
                                     p_day_blocks            => l_day_blocks,
                                     p_detail_blocks         => l_detail_blocks,
                                     p_messages              => p_messages,
                                     p_transaction_info      => l_transaction_info
                                    );
         hxc_timecard_message_helper.processerrors (p_messages => p_messages);
         --
         -- Maintain summary table
         --
         hxc_timecard_summary_api.timecard_deposit
                                             (p_blocks                     => p_blocks,
                                              p_approval_item_type         => NULL,
                                              p_approval_process_name      => NULL,
                                              p_approval_item_key          => NULL,
                                              p_tk_audit_item_type         => NULL,
                                              p_tk_audit_process_name      => NULL,
                                              p_tk_audit_item_key          => NULL
                                             );
         hxc_timecard_audit.maintain_latest_details (p_blocks => p_blocks);

         /* Bug 8888904 */
         hxc_timecard_audit.maintain_rdb_snapshot
	   (p_blocks => p_blocks,
	    p_attributes => p_attributes);


         hxc_timecard_message_helper.processerrors (p_messages => p_messages);
      END IF;

      -- get all the errors
      p_messages := hxc_timecard_message_helper.getmessages;
      p_timecard_id :=
         p_blocks
                (hxc_timecard_block_utils.find_active_timecard_index (p_blocks)
                ).time_building_block_id;
      p_timecard_ovn :=
         p_blocks
                (hxc_timecard_block_utils.find_active_timecard_index (p_blocks)
                ).object_version_number;


      -- OTL-Absences Integration (Bug 8779478)
      IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y') THEN
        IF  (p_timecard_id > 0 and hxc_timecard_message_helper.noerrors
           and p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).SCOPE <> hxc_timecard.c_template_scope) THEN

	        IF g_debug THEN
		  hr_utility.trace('ABS:Initiated Online Retrieval from HXC_TIMESTORE_DEPOSIT_UTIL.SAVE_TIMECARD');
	  	END IF;

          	l_resource_id     := p_blocks (l_timecard_index).resource_id;
          	l_start_date      := fnd_date.canonical_to_date(p_blocks (l_timecard_index).start_time);
          	l_stop_date       := fnd_date.canonical_to_date(p_blocks (l_timecard_index).stop_time);
          	l_tc_status	  := p_blocks (l_timecard_index).approval_status;

	  	HXC_ABS_RETRIEVAL_PKG.POST_ABSENCES(l_resource_id,
	  	  				    l_start_date,
	  	  				    l_stop_date,
	  	  				    l_tc_status,
	  	  				    p_messages);

	  	IF g_debug THEN
	  	  hr_utility.trace('ABS:p_messages.COUNT = '||p_messages.COUNT);
	  	END IF;

	        IF p_messages.COUNT > 0 THEN
	          IF g_debug THEN
	            hr_utility.trace('ABS:Error in POST_ABSENCES - Rollback changes');
	          END IF;

    		  l_message := fnd_message.get_string (
           		appin      => p_messages(p_messages.last).application_short_name
        	      , namein     => p_messages(p_messages.last).message_name
         		);

    		  --dbms_output.put_line('online retrieval error : '||substr(l_message,1,255));

	          rollback to TC_SAVE_SAVEPOINT;

	          hxc_timecard_message_helper.processerrors
	      	    (p_messages => p_messages);

	        END IF;

	 END IF;
      END IF;

	-- Absences end


      IF g_debug THEN
        hr_utility.trace('Leaving SAVE_TIMECARD');
      END IF;

   END save_timecard;

-----------------------------------------------------------------------------
-- Type:          Procedure
-- Scope:         Public
-- Name:          submit_timecard
-- IN OUT Parameters: p_item_type -> Item Type to be used by approval process
--                    p_approval_prc -> Approval Process used for approval
--                    p_template -> Is this TC a template, Y(es) or N(o)
--                    p_mode -> 'SUBMIT' or 'AUDIT'
--                    p_blocks -> The Timecard structure you want Submit
--                    p_attributes -> The Timecard's attributes you want to
--                                    Submit
--                    p_messages -> The messages returned from the Submit
--                                  process
-- OUT Parameters: p_timecard_id -> The timecard_id of the submitted Timecard
--                 p_timecard_ovn -> the OVN of the submitted Timecard
--
-- Description:   Private Procedure that can will be used to Submit the timecard
--                This will store the Timecard in the DB with a status of
--                SUBMITTED. This whole procedure is mimicking
--                the Submit as it happens in the deposit wrapper HXC_TIMECARD.
-----------------------------------------------------------------------------
   PROCEDURE submit_timecard (
      p_item_type           IN              wf_items.item_type%TYPE,
      p_approval_prc        IN              wf_process_activities.process_name%TYPE,
      p_template            IN              VARCHAR2,
      p_mode                IN              VARCHAR2,
      p_retrieval_process   IN              hxc_retrieval_processes.NAME%TYPE,
      p_blocks              IN OUT NOCOPY   hxc_block_table_type,
      p_attributes          IN OUT NOCOPY   hxc_attribute_table_type,
      p_messages            IN OUT NOCOPY   hxc_message_table_type,
      p_timecard_id         OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn        OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   )
   IS
      l_timecard_blocks        hxc_timecard.block_list;
      l_day_blocks             hxc_timecard.block_list;
      l_detail_blocks          hxc_timecard.block_list;
      l_transaction_info       hxc_timecard.transaction_info;
      l_old_transaction_info   hxc_deposit_wrapper_utilities.t_transaction;
      l_timecard_props         hxc_timecard_prop_table_type;
      l_proc                   VARCHAR2 (50)
                                            := g_package || 'submit_timecard';
      l_can_deposit            BOOLEAN                                := TRUE;
      l_resubmit               VARCHAR2 (10)             := hxc_timecard.c_no;
      l_timecard_index         NUMBER;
      l_rollback               BOOLEAN                               := FALSE;
      l_item_key               wf_items.item_key%TYPE                 := NULL;
      l_mode                   VARCHAR2 (30);
      l_message                fnd_new_messages.message_text%type;

      TC_SUB_EXCEPTION         EXCEPTION;

      l_resource_id      number;
      l_start_date 	   date;
      l_stop_date 	   date;
      l_tc_status        varchar2(20);

      l_timecard_start_time    DATE;
      l_timecard_stop_time     DATE;

   BEGIN
      fnd_msg_pub.initialize;
      hxc_timecard_message_helper.initializeerrors;

      p_messages := hxc_message_table_type ();
      hxc_timecard_block_utils.initialize_timecard_index;

      -- set savepoint
      savepoint TC_SUB_SAVEPOINT ;

      -- Check input parameters
      hxc_deposit_checks.check_inputs
                                    (p_blocks            => p_blocks,
                                     p_attributes        => p_attributes,
                                     p_deposit_mode      => hxc_timecard.c_submit,
                                     p_template          => hxc_timecard.c_no,
                                     p_messages          => p_messages
                                    );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);
      -- Determine if this is a resubmitted timecard
      l_timecard_index :=
                hxc_timecard_block_utils.find_active_timecard_index (p_blocks);

      IF (hxc_timecard_block_utils.date_value
                                           (p_blocks (l_timecard_index).date_to
                                           ) = hr_general.end_of_time
         )
      THEN
         l_resubmit :=
            hxc_timecard_approval.is_timecard_resubmitted
               (p_blocks (l_timecard_index).time_building_block_id,
                p_blocks (l_timecard_index).object_version_number,
                p_blocks (l_timecard_index).resource_id,
                fnd_date.canonical_to_date
                                        (p_blocks (l_timecard_index).start_time
                                        ),
                fnd_date.canonical_to_date
                                         (p_blocks (l_timecard_index).stop_time
                                         )
               );
      ELSE
         l_resubmit := hxc_timecard.c_delete;
      END IF;


      l_timecard_start_time :=
               fnd_date.canonical_to_date(p_blocks (l_timecard_index).start_time) ;

      l_timecard_stop_time :=
               fnd_date.canonical_to_date(p_blocks (l_timecard_index).stop_time) ;

      -- Obtain the timecard properties
      hxc_timecard_properties.get_preference_properties
         (p_validate                 => hxc_timecard.c_yes,
          p_resource_id              => p_blocks (l_timecard_index).resource_id,
          p_timecard_start_time      => l_timecard_start_time,
          p_timecard_stop_time       => l_timecard_stop_time,
          p_for_timecard             => FALSE,
          p_messages                 => p_messages,
          p_property_table           => l_timecard_props
         );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);
      -- Sort the blocks - needed for deposit and all sorts of short cuts!

      -- Bug 9023209
      -- API absences validation
      hxc_retrieve_absences.verify_view_only_absences
                             (p_blocks => p_blocks,
                              p_attributes => p_attributes,
                              p_lock_rowid => hxc_retrieve_absences.g_lock_row_id,
                              p_messages => p_messages);

      hxc_timecard_block_utils.sort_blocks
                                      (p_blocks               => p_blocks,
                                       p_timecard_blocks      => l_timecard_blocks,
                                       p_day_blocks           => l_day_blocks,
                                       p_detail_blocks        => l_detail_blocks
                                      );
--
--  Main deposit controls
--  ^^^^^^^^^^^^^^^^^^^^^
--  Reform time data, if required
--  e.g Denormalize time data
--
      hxc_block_attribute_update.denormalize_time (p_blocks      => p_blocks,
                                                   p_mode        => 'ADD'
                                                  );

--
--  Perform basic checks, e.g.
--  Are there any other timecards for this period?
--
      IF (p_template = hxc_timecard.c_no)
      THEN
         hxc_deposit_checks.perform_checks
                                       (p_blocks              => p_blocks,
                                        p_attributes          => p_attributes,
                                        p_timecard_props      => l_timecard_props,
                                        p_days                => l_day_blocks,
                                        p_details             => l_detail_blocks,
                                        p_messages            => p_messages
                                       );
         hxc_timecard_message_helper.processerrors (p_messages => p_messages);
      END IF;

      -- Add the security attributes
      -- ARR: 115.26 Add message structure
      hxc_security.add_security_attribute
                                         (p_blocks              => p_blocks,
                                          p_attributes          => p_attributes,
                                          p_timecard_props      => l_timecard_props,
                                          p_messages            => p_messages
                                         );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);
      -- Translate any aliases
      hxc_timecard_deposit_common.alias_translation
                                                (p_blocks          => p_blocks,
                                                 p_attributes      => p_attributes,
                                                 p_messages        => p_messages
                                                );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);

      -- Set the block and attribute update process flags based on the data sent
      -- and in the db
      hxc_block_attribute_update.set_process_flags
                                                 (p_blocks          => p_blocks,
                                                  p_attributes      => p_attributes
                                                 );
      hxc_timecard_attribute_utils.remove_deleted_attributes
                                                 (p_attributes      => p_attributes);
      -- Perform process checks
      hxc_deposit_checks.perform_process_checks
                                     (p_blocks              => p_blocks,
                                      p_attributes          => p_attributes,
                                      p_timecard_props      => l_timecard_props,
                                      p_days                => l_day_blocks,
                                      p_details             => l_detail_blocks,
                                      p_template            => hxc_timecard.c_no,
                                      p_deposit_mode        => hxc_timecard.c_submit,
                                      p_messages            => p_messages
                                     );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);


     -- Added the following validation code for bug 8900783
     -- This validation is to check if the timecard start and stop times falls within the
     -- PAST and FUTURE number of days for which timecard create/edit is allowed
      IF g_debug THEN
      	hr_utility.trace('l_timecard_start_time = '||l_timecard_start_time);
      	hr_utility.trace('l_timecard_stop_time = '||l_timecard_stop_time);
      END IF;

      -- populate the global variables which hold the PAST and FUTURE date limits
      hxc_timestore_deposit_util.get_past_future_limits
      		(p_resource_id 	       => p_blocks (l_timecard_index).resource_id,
      		 p_timecard_start_time => trunc(l_timecard_start_time),
      		 p_timecard_stop_time  => trunc(l_timecard_stop_time),
      		 p_messages	       => p_messages
      		);

      hxc_timecard_message_helper.processerrors (p_messages => p_messages);

      -- Validate blocks, attributes
      IF (p_mode <> hxc_timestore_deposit.c_migration
          AND hxc_timestore_deposit.g_validate <> TRUE)
      THEN
         hxc_timecard_validation.deposit_validation
                                            (p_blocks            => p_blocks,
                                             p_attributes        => p_attributes,
                                             p_messages          => p_messages,
                                             p_props             => l_timecard_props,
                                             p_deposit_mode      => p_mode,
                                             p_template          => hxc_timecard.c_no,
                                             p_resubmit          => l_resubmit,
                                             p_can_deposit       => l_can_deposit
                                            );
      ELSE                                 -- minimal validation for migration
         hxc_timecard_validation.data_set_validation
                                                    (p_blocks        => p_blocks,
                                                     p_messages      => p_messages
                                                    );
      END IF;

      hxc_timecard_message_helper.processerrors (p_messages => p_messages);
-- Validate the set up for the user Do this only for timecards, and not
-- for templates.
/*
  hxc_timecard_deposit_common.validate_setup
       (p_deposit_mode => hxc_timecard.c_submit
       ,p_blocks       => p_blocks
       ,p_attributes   => p_attributes
       ,p_messages     => p_messages
       );

  hxc_timecard_message_helper.processerrors
    (p_messages => p_messages);
*/
      -- Reform time data, if required e.g Denormalize time data
      hxc_block_attribute_update.denormalize_time (p_blocks      => p_blocks,
                                                   p_mode        => 'REMOVE'
                                                  );

      IF perform_audit (p_props => l_timecard_props, p_blocks => p_blocks)
      THEN
         -- Get the messages to perform the audit check
         p_messages := hxc_timecard_message_helper.getmessages;
         -- Perform Audit Checks
         -- Mental Note on how this works:)
         --    hxc_timecard_validation.deposit_validation called above, raises
         --    proper errors if something is really wrong, e.g. during the
         --    project or payroll validation.  However for Change and Late Audit
         --    (CLA), it stores special messages in message table p_messages.
         --    These messages have a message_level of REASON, are not considered
         --    errors and will not be recognized by
         --    hxc_timecard_message_helper.noerrors as errors.
         --    hxc_deposit_checks.audit_checks transforms these REASON errors
         --    into proper errors that will be caught by
         --    hxc_timecard_message_helper.noerrors.
         --    So effectively what we are doing here is converting the audit
         --    message into errors when the user calls the API and AUDIT is
         --    switched on in the preferences of the employee/resource.
         --    If the user calls the API and AUDIT is not set, we completely
         --    ignore the auditmessages and continue with the submit.
         hxc_deposit_checks.audit_checks (p_blocks          => p_blocks,
                                          p_attributes      => p_attributes,
                                          p_messages        => p_messages
                                         );
         hxc_timecard_message_helper.processerrors (p_messages => p_messages);
      END IF;

      -- Store blocks and attributes
      IF hxc_timecard_message_helper.noerrors
      THEN
         hxc_timecard_deposit.EXECUTE
                                    (p_blocks                => p_blocks,
                                     p_attributes            => p_attributes,
                                     p_timecard_blocks       => l_timecard_blocks,
                                     p_day_blocks            => l_day_blocks,
                                     p_detail_blocks         => l_detail_blocks,
                                     p_messages              => p_messages,
                                     p_transaction_info      => l_transaction_info
                                    );




         hxc_timecard_message_helper.processerrors (p_messages => p_messages);
         -- set the out parameters
         p_timecard_id :=
            p_blocks
                (hxc_timecard_block_utils.find_active_timecard_index (p_blocks)
                ).time_building_block_id;
         p_timecard_ovn :=
            p_blocks
                (hxc_timecard_block_utils.find_active_timecard_index (p_blocks)
                ).object_version_number;

         IF (    (p_template <> hxc_timecard.c_yes)
             AND (hxc_timecard_message_helper.noerrors)
            )
         THEN
            --
            -- Maintain summary table
            --
            IF (p_mode = hxc_timestore_deposit.c_migration)
            THEN
               l_mode := g_oit_migration;
            ELSE
               l_mode := hxc_timecard_summary_pkg.c_normal_mode;
            END IF;

            hxc_timecard_summary_api.timecard_deposit
                                             (p_blocks                     => p_blocks,
                                              p_mode                       => l_mode,
                                              p_approval_item_type         => NULL,
                                              p_approval_process_name      => NULL,
                                              p_approval_item_key          => NULL,
                                              p_tk_audit_item_type         => NULL,
                                              p_tk_audit_process_name      => NULL,
                                              p_tk_audit_item_key          => NULL
                                             );
            hxc_timecard_audit.maintain_latest_details (p_blocks => p_blocks);

            /* Bug 8888904 */
            hxc_timecard_audit.maintain_rdb_snapshot
	    (p_blocks => p_blocks,
	     p_attributes => p_attributes);

            hxc_timecard_message_helper.processerrors
                                                     (p_messages      => p_messages);

      -- OTL-Absences Integration (Bug 8779478)
   	IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y')
   	THEN
   	  IF  (p_timecard_id > 0 and hxc_timecard_message_helper.noerrors
   	       and p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).SCOPE <> hxc_timecard.c_template_scope)
   	  THEN
   	        IF g_debug THEN
		  hr_utility.trace('ABS:Initiated Online Retrieval from HXC_TIMESTORE_DEPOSIT_UTIL.SUBMIT_TIMECARD');
		END IF;

          	l_resource_id     := p_blocks (l_timecard_index).resource_id;
          	l_start_date      := fnd_date.canonical_to_date(p_blocks (l_timecard_index).start_time);
          	l_stop_date       := fnd_date.canonical_to_date(p_blocks (l_timecard_index).stop_time);
          	l_tc_status	  := p_blocks (l_timecard_index).approval_status;

	  	HXC_ABS_RETRIEVAL_PKG.POST_ABSENCES(l_resource_id,
	  	  				    l_start_date,
	  	  				    l_stop_date,
	  	  				    l_tc_status,
	  	  				    p_messages);

		IF g_debug THEN
		  hr_utility.trace('ABS:p_messages.COUNT = '||p_messages.COUNT);
		END IF;

		if p_messages.COUNT > 0
		then
		  IF g_debug THEN
		    hr_utility.trace('ABS:Error in POST_ABSENCES - Rollback changes');
		  END IF;

    		  l_message := fnd_message.get_string (
           		appin      => p_messages(p_messages.last).application_short_name
        	      , namein     => p_messages(p_messages.last).message_name
         		);

    		  --dbms_output.put_line('online retrieval error : '||substr(l_message,1,255));

	          rollback to TC_SUB_SAVEPOINT;

	          hxc_timecard_message_helper.processerrors
	      	    (p_messages => p_messages);

		end if;

   	  END IF;
   	END IF;

        -- Absences end

            IF (p_mode <> hxc_timestore_deposit.c_migration)
            THEN
               l_item_key :=
                  hxc_timecard_approval.begin_approval
                                           (p_blocks            => p_blocks,
                                            p_item_type         => p_item_type,
                                            p_process_name      => p_approval_prc,
                                            p_resubmitted       => l_resubmit,
                                            p_timecard_props    => l_timecard_props,
                                            p_messages          => p_messages
                                           );

               hxc_timecard_message_helper.processerrors
                 (p_messages => p_messages);

      		-- Absences start

  	       IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y')  THEN
		  hr_utility.trace('ABS:Checking status of BEGIN_APPROVAL');
		  hr_utility.trace('ABS:p_messages.COUNT = '||p_messages.COUNT);

		  if p_messages.COUNT > 0 then
		    hr_utility.trace('ABS:Error in POST_ABSENCES - Rollback changes');

    		    l_message := fnd_message.get_string (
           		appin      => p_messages(p_messages.last).application_short_name
        	      , namein     => p_messages(p_messages.last).message_name
         		);

    		    --dbms_output.put_line('online retrieval error : '||substr(l_message,1,255));

   	            rollback to TC_SUB_SAVEPOINT;

	  	    hxc_timecard_message_helper.processerrors
  	        	    (p_messages => p_messages);
		  end if;
  	       END IF;

      		-- Absences end

               hxc_timecard_summary_pkg.update_summary_row
                                   (p_timecard_id                => p_timecard_id,
                                    p_approval_item_type         => p_item_type,
                                    p_approval_process_name      => p_approval_prc,
                                    p_approval_item_key          => l_item_key
                                   );
            END IF;
         ELSIF (    (p_template = hxc_timecard.c_yes)
                AND (hxc_timecard_message_helper.noerrors)
               )
         THEN
            hxc_template_summary_api.template_deposit
                                              (p_blocks           => p_blocks,
                                               p_attributes       => p_attributes,
                                               p_template_id      => p_timecard_id
                                              );
         END IF;
      END IF;

      -- Audit this transaction
      hxc_timecard_audit.audit_deposit
                                    (p_transaction_info      => l_transaction_info,
                                     p_messages              => p_messages
                                    );
      hxc_timecard_message_helper.processerrors (p_messages => p_messages);




      IF (    (p_mode = hxc_timestore_deposit.c_migration)
          AND (hxc_timecard_message_helper.noerrors)
         )
      THEN
         l_old_transaction_info :=
            convert_new_trans_info_to_old
                                    (p_transaction_info      => l_transaction_info);
         hxc_deposit_wrapper_utilities.audit_transaction
            (p_effective_date              => SYSDATE,
             p_transaction_type            => 'RETRIEVAL',
             p_transaction_process_id      => get_retrieval_process_id
                                                 (p_retrieval_process_name      => p_retrieval_process
                                                 ),
             p_overall_status              => 'SUCCESS',
             p_transaction_tab             => l_old_transaction_info
            );
         hxc_timecard_message_helper.processerrors (p_messages => p_messages);
      END IF;

      -- get all the errors
      p_messages := hxc_timecard_message_helper.getmessages;

      IF g_debug THEN
        hr_utility.trace('Leaving SUBMIT_TIMECARD');
      END IF;

   END submit_timecard;

-----------------------------------------------------------------------------
-- Type:          Function
-- Scope:         Public
-- Name:          convert_tbb_to_type
-- Returns:       hxc_block_table_type
-- IN Parameters: p_blocks -> The PL/SQL Timecard structure you want to convert
--
-- Description:   Private Function that will convert the old PL/SQL Timecard
--                structure to the new TYPE that is then returned
--                FYI: This is the reverse function of convert_to_dpwr_blocks
--                that can be found in hxc_timecard_block_utils. It is not
--                defined in that procedure as it is only needed for this API
--                hence we define it here as a provate function
-----------------------------------------------------------------------------
   FUNCTION convert_tbb_to_type (
      p_blocks   IN   hxc_self_service_time_deposit.timecard_info
   )
      RETURN hxc_block_table_type
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
      l_index    PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'convert_tbb_to_type';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- Initialize the collection
      l_blocks := hxc_block_table_type ();
      l_index := p_blocks.FIRST;

      LOOP
         EXIT WHEN NOT p_blocks.EXISTS (l_index);
         l_blocks.EXTEND;
         l_blocks (l_blocks.LAST) :=
            hxc_block_type
                   (p_blocks (l_index).time_building_block_id,
                    p_blocks (l_index).TYPE,
                    p_blocks (l_index).measure,
                    p_blocks (l_index).unit_of_measure,
                    fnd_date.date_to_canonical (p_blocks (l_index).start_time),
                    fnd_date.date_to_canonical (p_blocks (l_index).stop_time),
                    p_blocks (l_index).parent_building_block_id,
                    p_blocks (l_index).parent_is_new,
                    p_blocks (l_index).SCOPE,
                    p_blocks (l_index).object_version_number,
                    p_blocks (l_index).approval_status,
                    p_blocks (l_index).resource_id,
                    p_blocks (l_index).resource_type,
                    p_blocks (l_index).approval_style_id,
                    fnd_date.date_to_canonical (p_blocks (l_index).date_from),
                    fnd_date.date_to_canonical (p_blocks (l_index).date_to),
                    p_blocks (l_index).comment_text,
                    p_blocks (l_index).parent_building_block_ovn,
                    p_blocks (l_index).NEW,
                    p_blocks (l_index).changed,
                    NULL,                                           -- Process
                    p_blocks (l_index).application_set_id,
                    NULL  -- Can not set this from old structure at the moment
                   );
         l_index := p_blocks.NEXT (l_index);
      END LOOP;

      IF g_debug
      THEN
         hr_utility.set_location (   '   returning l_blocks.count = '
                                  || l_blocks.COUNT,
                                  20
                                 );
         hr_utility.set_location ('Leaving: ' || l_proc, 30);
      END IF;

      RETURN l_blocks;
   END convert_tbb_to_type;

-----------------------------------------------------------------------------
-- Type:          Function
-- Scope:         Public
-- Name:          convert_new_trans_info_to_old
-- Returns:       hxc_deposit_wrapper_utilities.t_transaction
-- IN Parameters: p_trans_info -> The PL/SQL Transaction info table you want to
--                                convert
-- Description:   Public Function that will convert the new PL/SQL Transaction
--                PL/SQL table to the old PL/SQL Table that is then returned
-----------------------------------------------------------------------------
   FUNCTION convert_new_trans_info_to_old (
      p_transaction_info   IN   hxc_timecard.transaction_info
   )
      RETURN hxc_deposit_wrapper_utilities.t_transaction
   IS
      l_proc               VARCHAR2 (72);
      l_transaction_info   hxc_deposit_wrapper_utilities.t_transaction;
      l_index              PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'convert_new_trans_info_to_old';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_index := p_transaction_info.FIRST;

      LOOP
         EXIT WHEN NOT p_transaction_info.EXISTS (l_index);
         l_transaction_info (l_index).txd_id :=
                           p_transaction_info (l_index).transaction_detail_id;
         l_transaction_info (l_index).tbb_id :=
                          p_transaction_info (l_index).time_building_block_id;
         l_transaction_info (l_index).tbb_ovn :=
                           p_transaction_info (l_index).object_version_number;
         l_transaction_info (l_index).status :=
                                          p_transaction_info (l_index).status;
         l_transaction_info (l_index).exception_desc :=
                                  p_transaction_info (l_index).exception_desc;
         l_index := p_transaction_info.NEXT (l_index);
      END LOOP;

      IF g_debug
      THEN
         hr_utility.set_location
                              (   '   returning l_transaction_info.count = '
                               || l_transaction_info.COUNT,
                               20
                              );
         hr_utility.set_location ('Leaving: ' || l_proc, 30);
      END IF;

      RETURN l_transaction_info;
   END convert_new_trans_info_to_old;

   PROCEDURE update_value (
      p_attributes   IN OUT NOCOPY   hxc_attribute_table_type,
      p_index        IN              NUMBER,
      p_segment      IN              hxc_mapping_components.SEGMENT%TYPE,
      p_value        IN              hxc_time_attributes.attribute1%TYPE
   )
   IS
   BEGIN
      IF (p_segment = 'ATTRIBUTE1')
      THEN
         p_attributes (p_index).attribute1 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE2')
      THEN
         p_attributes (p_index).attribute2 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE3')
      THEN
         p_attributes (p_index).attribute3 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE4')
      THEN
         p_attributes (p_index).attribute4 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE5')
      THEN
         p_attributes (p_index).attribute5 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE6')
      THEN
         p_attributes (p_index).attribute6 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE7')
      THEN
         p_attributes (p_index).attribute7 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE8')
      THEN
         p_attributes (p_index).attribute8 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE9')
      THEN
         p_attributes (p_index).attribute9 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE10')
      THEN
         p_attributes (p_index).attribute10 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE11')
      THEN
         p_attributes (p_index).attribute11 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE12')
      THEN
         p_attributes (p_index).attribute12 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE13')
      THEN
         p_attributes (p_index).attribute13 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE14')
      THEN
         p_attributes (p_index).attribute14 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE15')
      THEN
         p_attributes (p_index).attribute15 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE16')
      THEN
         p_attributes (p_index).attribute16 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE17')
      THEN
         p_attributes (p_index).attribute17 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE18')
      THEN
         p_attributes (p_index).attribute18 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE19')
      THEN
         p_attributes (p_index).attribute19 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE20')
      THEN
         p_attributes (p_index).attribute20 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE21')
      THEN
         p_attributes (p_index).attribute21 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE22')
      THEN
         p_attributes (p_index).attribute22 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE23')
      THEN
         p_attributes (p_index).attribute23 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE24')
      THEN
         p_attributes (p_index).attribute24 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE25')
      THEN
         p_attributes (p_index).attribute25 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE26')
      THEN
         p_attributes (p_index).attribute26 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE27')
      THEN
         p_attributes (p_index).attribute27 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE28')
      THEN
         p_attributes (p_index).attribute28 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE29')
      THEN
         p_attributes (p_index).attribute29 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE30')
      THEN
         p_attributes (p_index).attribute30 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE_CATEGORY')
      THEN
         p_attributes (p_index).attribute_category := p_value;
      END IF;
   END update_value;

   PROCEDURE set_new_attribute_value (
      p_attribute   IN OUT NOCOPY   hxc_attribute_type,
      p_segment     IN              hxc_mapping_components.SEGMENT%TYPE,
      p_value       IN              hxc_time_attributes.attribute1%TYPE,
      p_changed     IN              hxc_time_attributes.attribute1%TYPE
   )
   IS
   BEGIN
      IF (p_segment = 'ATTRIBUTE1')
      THEN
         p_attribute.attribute1 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE2')
      THEN
         p_attribute.attribute2 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE3')
      THEN
         p_attribute.attribute3 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE4')
      THEN
         p_attribute.attribute4 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE5')
      THEN
         p_attribute.attribute5 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE6')
      THEN
         p_attribute.attribute6 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE7')
      THEN
         p_attribute.attribute7 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE8')
      THEN
         p_attribute.attribute8 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE9')
      THEN
         p_attribute.attribute9 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE10')
      THEN
         p_attribute.attribute10 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE11')
      THEN
         p_attribute.attribute11 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE12')
      THEN
         p_attribute.attribute12 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE13')
      THEN
         p_attribute.attribute13 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE14')
      THEN
         p_attribute.attribute14 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE15')
      THEN
         p_attribute.attribute15 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE16')
      THEN
         p_attribute.attribute16 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE17')
      THEN
         p_attribute.attribute17 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE18')
      THEN
         p_attribute.attribute18 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE19')
      THEN
         p_attribute.attribute19 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE20')
      THEN
         p_attribute.attribute20 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE21')
      THEN
         p_attribute.attribute21 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE22')
      THEN
         p_attribute.attribute22 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE23')
      THEN
         p_attribute.attribute23 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE24')
      THEN
         p_attribute.attribute24 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE25')
      THEN
         p_attribute.attribute25 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE26')
      THEN
         p_attribute.attribute26 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE27')
      THEN
         p_attribute.attribute27 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE28')
      THEN
         p_attribute.attribute28 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE29')
      THEN
         p_attribute.attribute29 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE30')
      THEN
         p_attribute.attribute30 := p_value;
      ELSIF (p_segment = 'ATTRIBUTE_CATEGORY')
      THEN
         p_attribute.attribute_category := p_value;
      END IF;

      IF (p_changed = hxc_timecard.c_yes)
      THEN
         p_attribute.changed := hxc_timecard.c_yes;
         p_attribute.process := hxc_timecard.c_yes;
      END IF;
   END set_new_attribute_value;

   PROCEDURE create_new_attribute (
      p_attributes       IN OUT NOCOPY   hxc_attribute_table_type,
      p_app_attributes   IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_app_index        IN              NUMBER
   )
   IS
      l_new_time_attribute_id   NUMBER;
      l_new_attribute           hxc_attribute_type;
      l_index                   NUMBER;
      l_attribute_category      hxc_bld_blk_info_types.bld_blk_info_type%TYPE;
      l_new                     VARCHAR2 (1);
   BEGIN
      IF (INSTR (p_app_attributes (p_app_index).bld_blk_info_type, 'Dummy') <
                                                                             1
         )
      THEN
         l_attribute_category :=
             SUBSTR (p_app_attributes (p_app_index).bld_blk_info_type, 1, 30);
      ELSE
         l_attribute_category := NULL;
      END IF;

      IF (p_app_attributes (p_app_index).attribute_index IS NULL)
      THEN
         l_new := hxc_timecard.c_yes;
      ELSE
         l_new := hxc_timecard.c_no;
      END IF;

      l_new_attribute :=
         hxc_attribute_type
            (p_app_attributes (p_app_index).time_attribute_id,
             p_app_attributes (p_app_index).building_block_id,
             l_attribute_category,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             hxc_timecard_attribute_utils.get_bld_blk_info_type_id
                              (p_app_attributes (p_app_index).bld_blk_info_type
                              ),
             1,
             l_new,
             hxc_timecard.c_no,
             -- Changed: We will decide later if this is a changed Attribute
             p_app_attributes (p_app_index).bld_blk_info_type,
             hxc_timecard.c_no,
             -- Process: We will decide later if this Attribute needs to get processed
             NULL
            );
      l_index := p_app_attributes.FIRST;

      LOOP
         EXIT WHEN NOT p_app_attributes.EXISTS (l_index);

         IF (    (p_app_attributes (l_index).bld_blk_info_type =
                              p_app_attributes (p_app_index).bld_blk_info_type
                 )
             AND (p_app_attributes (l_index).time_attribute_id =
                              p_app_attributes (p_app_index).time_attribute_id
                 )
            )
         THEN
            set_new_attribute_value
                                  (l_new_attribute,
                                   p_app_attributes (l_index).SEGMENT,
                                   p_app_attributes (l_index).attribute_value,
                                   p_app_attributes (l_index).changed
                                  );
            p_app_attributes (l_index).updated := 'Y';
         END IF;

         l_index := p_app_attributes.NEXT (l_index);
      END LOOP;

      p_attributes.EXTEND ();
      p_attributes (p_attributes.LAST) := l_new_attribute;
   END create_new_attribute;

   PROCEDURE convert_app_attributes_to_type (
      p_attributes       IN OUT NOCOPY   hxc_attribute_table_type,
      p_app_attributes   IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_index   NUMBER;
   BEGIN
      l_index := p_app_attributes.FIRST;

      LOOP
         EXIT WHEN NOT p_app_attributes.EXISTS (l_index);

         IF (NVL (p_app_attributes (l_index).updated, 'N') = 'N')
         THEN
            create_new_attribute (p_attributes          => p_attributes,
                                  p_app_attributes      => p_app_attributes,
                                  p_app_index           => l_index
                                 );
            p_app_attributes (l_index).updated := 'Y';
         END IF;

         l_index := p_app_attributes.NEXT (l_index);
      END LOOP;
   END convert_app_attributes_to_type;

-----------------------------------------------------------------------------
-- Type:          Function
-- Scope:         Public
-- Name:          convert_to_dpwr_messages
-- Returns:       hxc_self_service_time_deposit.message_table
-- IN Parameters: p_messages -> The PL/SQL table structure you want to convert
--
-- Description:   Private Function that will convert the new TYPE to the old
--                PL/SQL message structure that is then returned.
--
-----------------------------------------------------------------------------
   FUNCTION convert_to_dpwr_messages (p_messages IN hxc_message_table_type)
      RETURN hxc_self_service_time_deposit.message_table
   IS
      l_proc       VARCHAR2 (72);
      l_messages   hxc_self_service_time_deposit.message_table;
      l_index      NUMBER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'convert_to_dpwr_messages';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_index := p_messages.FIRST;

      LOOP
         EXIT WHEN NOT p_messages.EXISTS (l_index);
         l_messages (l_index).message_name :=
                                            p_messages (l_index).message_name;
         l_messages (l_index).message_level :=
                                           p_messages (l_index).message_level;
         l_messages (l_index).message_field :=
                                           p_messages (l_index).message_field;
         l_messages (l_index).message_tokens :=
                                          p_messages (l_index).message_tokens;
         l_messages (l_index).application_short_name :=
                                  p_messages (l_index).application_short_name;
         l_messages (l_index).time_building_block_id :=
                                  p_messages (l_index).time_building_block_id;
         l_messages (l_index).time_building_block_ovn :=
                                 p_messages (l_index).time_building_block_ovn;
         l_messages (l_index).time_attribute_id :=
                                       p_messages (l_index).time_attribute_id;
         l_messages (l_index).time_attribute_ovn :=
                                      p_messages (l_index).time_attribute_ovn;
         l_index := p_messages.NEXT (l_index);
      END LOOP;

      IF g_debug
      THEN
         hr_utility.set_location (   '   returning l_messages.count = '
                                  || l_messages.COUNT,
                                  20
                                 );
         hr_utility.set_location ('Leaving:' || l_proc, 30);
      END IF;

      RETURN l_messages;
   END convert_to_dpwr_messages;

-----------------------------------------------------------------------------
-- Type:          Function
-- Scope:         Public
-- Name:          convert_msg_to_type
-- Returns:       hxc_message_table_type
-- IN Parameters: p_messages -> The PL/SQL msg structure you want to convert
--
-- Description:   Private Function that will convert the old PL/SQL message
--                structure to the new TYPE that is then returned.
--
-----------------------------------------------------------------------------
   FUNCTION convert_msg_to_type (
      p_messages   IN   hxc_self_service_time_deposit.message_table
   )
      RETURN hxc_message_table_type
   IS
      l_proc       VARCHAR2 (72);
      l_messages   hxc_message_table_type;
      l_index      PLS_INTEGER;
   BEGIN
      IF g_debug
      THEN
         l_proc := g_package || 'convert_msg_to_type';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- Initialize the collection
      l_messages := hxc_message_table_type ();
      l_index := p_messages.FIRST;

      LOOP
         EXIT WHEN NOT p_messages.EXISTS (l_index);
         l_messages.EXTEND;
         l_messages (l_messages.LAST) :=
            hxc_message_type (p_messages (l_index).message_name,
                              p_messages (l_index).message_level,
                              p_messages (l_index).message_field,
                              p_messages (l_index).message_tokens,
                              p_messages (l_index).application_short_name,
                              p_messages (l_index).time_building_block_id,
                              p_messages (l_index).time_building_block_ovn,
                              p_messages (l_index).time_attribute_id,
                              p_messages (l_index).time_attribute_ovn,
                              p_messages (l_index).message_extent
                             );
         l_index := p_messages.NEXT (l_index);
      END LOOP;

      IF g_debug
      THEN
         hr_utility.set_location (   '   returning l_messages.count = '
                                  || l_messages.COUNT,
                                  20
                                 );
         hr_utility.set_location ('Leaving: ' || l_proc, 30);
      END IF;

      RETURN l_messages;
   END convert_msg_to_type;

-----------------------------------------------------------------------------
-- Type:          Function
-- Scope:         Public
-- Name:          get_approval_status
-- Returns:       VARCHAR2
-- IN Parameters: p_mode -> The mode you want to find the approval status for
--
-- Description:   Private Function that will return the approval status that
--                matches a mode
--                The approval status is linked (hard coded here) to the mode
--                For P_MODE 'SAVE'             APPROVAL_STATUS = 'WORKING'
--                For P_MODE 'SUBMIT'           APPROVAL_STATUS = 'SUBMITTED'
--                For P_MODE 'FORCE_SAVE'       APPROVAL_STATUS = 'WORKING'
--                For P_MODE 'FORCE_SUBMIT'     APPROVAL_STATUS = 'SUBMITTED'
--                For P_MODE 'AUDIT'            APPROVAL_STATUS = 'SUBMITTED'
--                For P_MODE 'MIGRATION'        APPROVAL_STATUS = 'SUBMITTED'
-----------------------------------------------------------------------------
   FUNCTION get_approval_status (p_mode IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_proc        VARCHAR2 (72);
      l_appr_stat   VARCHAR2 (30);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'get_approval_status';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      IF p_mode = hxc_timecard.c_save
      THEN
         l_appr_stat := hxc_timecard.c_working_status;
      ELSIF p_mode = hxc_timecard.c_submit
      THEN
         l_appr_stat := hxc_timecard.c_submitted_status;
      ELSIF p_mode = hxc_timestore_deposit.c_tk_save
      THEN
         l_appr_stat := hxc_timecard.c_working_status;
      ELSIF p_mode = hxc_timestore_deposit.c_tk_submit
      THEN
         l_appr_stat := hxc_timecard.c_submitted_status;
      ELSIF p_mode = hxc_timecard.c_audit
      THEN
         l_appr_stat := hxc_timecard.c_submitted_status;
      ELSIF p_mode = hxc_timestore_deposit.c_migration
      THEN
         l_appr_stat := hxc_timecard.c_submitted_status;
      ELSE          -- if no mode was supplied (or the wrong one), try working
         l_appr_stat := hxc_timecard.c_working_status;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (   '   returning approval_status = '
                                  || l_appr_stat,
                                  20
                                 );
         hr_utility.set_location ('Leaving:' || l_proc, 30);
      END IF;

      RETURN l_appr_stat;
   END get_approval_status;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           find_parent_building_block
-- IN Parameters:  p_start_time -> Start Time of the TBB
--                 p_resource_id -> Resource ID (Person ID)
--                 p_resource_type -> Defaults to 'PERSON', use the default
--                 p_scope -> 'DAY' or 'DETAIL' (TIMECARD TBBs do not
--                             have parents)
--                 p_app_blocks -> The table type already holding a timecard
--                                 This might be empty
-- OUT Parameters: p_timecard_bb_id -> id of the parent TBB id
--                 p_timecard_ovn -> ovn of the parent TBB id
--
-- Description:   By passing in the details of a TBB (p_start_time,
--                p_resource_id), this procedure will
--                work out what the parent for that TBB should be.  We can do
--                this, because for a certain time and resource id, there
--                can only be one parent TBB to which this TBB can be added.
--
--                If a DAY TBB is passed in, this procedure will work out
--                to which TIMECARD TBB this DAY TBB needs to be attached,
--                if a DETAIL TBB is passed in, this procedure will work out
--                to which DAY TBB this DETAIL TBB needs to be attached.
--
--                The procedure will first scan the PL/SQL timecard table to
--                see if it can find the TBB in there.  If this table is empty
--                it will look in the DB.
--
-- Exceptions:     No Timecard found
--                 Wrong Timecard in PL/SQL Table
-----------------------------------------------------------------------------
   PROCEDURE find_parent_building_block (
      p_start_time       IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id      IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type    IN              hxc_time_building_blocks.resource_type%TYPE,
      p_scope            IN              hxc_time_building_blocks.SCOPE%TYPE,
      p_app_blocks       IN              hxc_block_table_type,
      p_timecard_bb_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn     OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   )
   IS
      l_proc                   VARCHAR2 (72);

      -- This cursor will return the BB_ID and OVN of the current TBB.
      CURSOR csr_get_timecard_id (
         v_start_time      hxc_time_building_blocks.start_time%TYPE,
         v_resource_id     hxc_time_building_blocks.resource_id%TYPE,
         v_resource_type   hxc_time_building_blocks.resource_type%TYPE,
         v_scope           hxc_time_building_blocks.SCOPE%TYPE
      )
      IS
         SELECT   tbb.time_building_block_id,
                  MAX (tbb.object_version_number)
             FROM hxc_time_building_blocks tbb, hxc_time_building_blocks parent_tbb
            WHERE tbb.SCOPE = v_scope
              AND tbb.resource_type = v_resource_type
              AND tbb.resource_id = v_resource_id
              AND v_start_time BETWEEN tbb.start_time AND tbb.stop_time
              AND tbb.date_to = hr_general.end_of_time
              AND parent_tbb.time_building_block_id = tbb.parent_building_block_id
              AND parent_tbb.object_version_number = tbb.parent_building_block_ovn
              AND parent_tbb.date_to = hr_general.end_of_time
              AND parent_tbb.SCOPE <> hxc_timecard.c_template_scope
         GROUP BY tbb.time_building_block_id;

      l_building_block_count   PLS_INTEGER;
      l_index                  PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'find_parent_building_block';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- If the PL/SQL structure is not empty, we assume the user wants to add
      -- this DAY TBB to the TIMECARD present in the PL/SQL table so first look
      -- there
      IF (p_app_blocks.COUNT <> 0)
      THEN                            -- Look for TIMECARD in PL/SQL structure
         p_timecard_bb_id := NULL;                  -- also used to exit loop
         l_building_block_count := p_app_blocks.FIRST;

         -- loop over all TBB in the PL/SQL table and see if we find a match
         LOOP
            EXIT WHEN (NOT p_app_blocks.EXISTS (l_building_block_count))
                  OR (p_timecard_bb_id IS NOT NULL);

            IF     (p_start_time
                       BETWEEN fnd_date.canonical_to_date
                                 (p_app_blocks (l_building_block_count).start_time
                                 )
                           AND fnd_date.canonical_to_date
                                 (p_app_blocks (l_building_block_count).stop_time
                                 )
                   )
               AND (p_resource_type =
                           p_app_blocks (l_building_block_count).resource_type
                   )
               AND (p_resource_id =
                             p_app_blocks (l_building_block_count).resource_id
                   )
               AND (p_app_blocks (l_building_block_count).SCOPE = p_scope)
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location
                     (   '   Found TBB in PL/SQL Table, ID = '
                      || p_app_blocks (l_building_block_count).time_building_block_id,
                      20
                     );
               END IF;

               -- found BB, set the ID and OVN
               p_timecard_bb_id :=
                  p_app_blocks (l_building_block_count).time_building_block_id;
               p_timecard_ovn :=
                   p_app_blocks (l_building_block_count).object_version_number;
            END IF;

            -- Next
            l_building_block_count :=
                                    p_app_blocks.NEXT (l_building_block_count);
         END LOOP;

         IF l_index IS NULL
         THEN                                 -- we never found the BB : ERROR
            NULL;
         END IF;
      ELSE                                          -- Look for TIMECARD in DB
         OPEN csr_get_timecard_id (p_start_time,
                                   p_resource_id,
                                   p_resource_type,
                                   p_scope
                                  );

         FETCH csr_get_timecard_id
          INTO p_timecard_bb_id, p_timecard_ovn;

         IF g_debug
         THEN
            hr_utility.set_location (   '   Found TBB in DB, ID = '
                                     || p_timecard_bb_id,
                                     30
                                    );
         END IF;

         CLOSE csr_get_timecard_id;
      END IF;                                     -- (p_app_blocks.COUNT <> 0)

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 40);
      END IF;
   END find_parent_building_block;

-----------------------------------------------------------------------------
-- Type:          Procedure
-- Scope:         Public
-- Name:          set_new_change_flags
-- IN OUT Parameters: p_attributes -> The PL/SQL attribute table type you want
--                                    to update the changed and new flags for.
--
-- Description:   Public Procedure that will set the changed and new flags for
--                the attribute structure passed in. Unfortunately, when we
--                retrieve the attributes from the database using the attribute
--                utilities, these flags are not set correctly so we need to
--                addjust them, we can do that with this function.
-----------------------------------------------------------------------------
   PROCEDURE set_new_change_flags (
      p_attributes   IN OUT NOCOPY   hxc_attribute_table_type
   )
   IS
      l_proc            VARCHAR2 (72);
      l_index           PLS_INTEGER;

      CURSOR find_attribute (
         p_attr_id   hxc_time_attributes.time_attribute_id%TYPE
      )
      IS
         SELECT   time_attribute_id, attribute_category, attribute1,
                  attribute2, attribute3, attribute4, attribute5, attribute6,
                  attribute7, attribute8, attribute9, attribute10,
                  attribute11, attribute12, attribute13, attribute14,
                  attribute15, attribute16, attribute17, attribute18,
                  attribute19, attribute20, attribute21, attribute22,
                  attribute23, attribute24, attribute25, attribute26,
                  attribute27, attribute28, attribute29, attribute30,
                  MAX (object_version_number)
             FROM hxc_time_attributes
            WHERE time_attribute_id = p_attr_id
         GROUP BY time_attribute_id,
                  attribute_category,
                  attribute1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7,
                  attribute8,
                  attribute9,
                  attribute10,
                  attribute11,
                  attribute12,
                  attribute13,
                  attribute14,
                  attribute15,
                  attribute16,
                  attribute17,
                  attribute18,
                  attribute19,
                  attribute20,
                  attribute21,
                  attribute22,
                  attribute23,
                  attribute24,
                  attribute25,
                  attribute26,
                  attribute27,
                  attribute28,
                  attribute29,
                  attribute30;

      l_attribute_rec   find_attribute%ROWTYPE;
      c_null   CONSTANT VARCHAR2 (5)             := '@@@@@';
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'set_new_change_flags';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_index := p_attributes.FIRST;

      LOOP
         EXIT WHEN NOT p_attributes.EXISTS (l_index);

         OPEN find_attribute (p_attributes (l_index).time_attribute_id);

         FETCH find_attribute
          INTO l_attribute_rec;

         IF find_attribute%FOUND
         THEN
            IF g_debug
            THEN
               hr_utility.set_location
                                 (   ' - Attribute '
                                  || p_attributes (l_index).time_attribute_id
                                  || ' Found',
                                  20
                                 );
            END IF;

            p_attributes (l_index).NEW := 'N';

            IF (    NVL (l_attribute_rec.attribute1, c_null) =
                               NVL (p_attributes (l_index).attribute1, c_null)
                AND NVL (l_attribute_rec.attribute2, c_null) =
                               NVL (p_attributes (l_index).attribute2, c_null)
                AND NVL (l_attribute_rec.attribute3, c_null) =
                               NVL (p_attributes (l_index).attribute3, c_null)
                AND NVL (l_attribute_rec.attribute4, c_null) =
                               NVL (p_attributes (l_index).attribute4, c_null)
                AND NVL (l_attribute_rec.attribute5, c_null) =
                               NVL (p_attributes (l_index).attribute5, c_null)
                AND NVL (l_attribute_rec.attribute6, c_null) =
                               NVL (p_attributes (l_index).attribute6, c_null)
                AND NVL (l_attribute_rec.attribute7, c_null) =
                               NVL (p_attributes (l_index).attribute7, c_null)
                AND NVL (l_attribute_rec.attribute8, c_null) =
                               NVL (p_attributes (l_index).attribute8, c_null)
                AND NVL (l_attribute_rec.attribute9, c_null) =
                               NVL (p_attributes (l_index).attribute9, c_null)
                AND NVL (l_attribute_rec.attribute10, c_null) =
                              NVL (p_attributes (l_index).attribute10, c_null)
                AND NVL (l_attribute_rec.attribute11, c_null) =
                              NVL (p_attributes (l_index).attribute11, c_null)
                AND NVL (l_attribute_rec.attribute12, c_null) =
                              NVL (p_attributes (l_index).attribute12, c_null)
                AND NVL (l_attribute_rec.attribute13, c_null) =
                              NVL (p_attributes (l_index).attribute13, c_null)
                AND NVL (l_attribute_rec.attribute14, c_null) =
                              NVL (p_attributes (l_index).attribute14, c_null)
                AND NVL (l_attribute_rec.attribute15, c_null) =
                              NVL (p_attributes (l_index).attribute15, c_null)
                AND NVL (l_attribute_rec.attribute16, c_null) =
                              NVL (p_attributes (l_index).attribute16, c_null)
                AND NVL (l_attribute_rec.attribute17, c_null) =
                              NVL (p_attributes (l_index).attribute17, c_null)
                AND NVL (l_attribute_rec.attribute18, c_null) =
                              NVL (p_attributes (l_index).attribute18, c_null)
                AND NVL (l_attribute_rec.attribute19, c_null) =
                              NVL (p_attributes (l_index).attribute19, c_null)
                AND NVL (l_attribute_rec.attribute20, c_null) =
                              NVL (p_attributes (l_index).attribute20, c_null)
                AND NVL (l_attribute_rec.attribute21, c_null) =
                              NVL (p_attributes (l_index).attribute21, c_null)
                AND NVL (l_attribute_rec.attribute22, c_null) =
                              NVL (p_attributes (l_index).attribute22, c_null)
                AND NVL (l_attribute_rec.attribute23, c_null) =
                              NVL (p_attributes (l_index).attribute23, c_null)
                AND NVL (l_attribute_rec.attribute24, c_null) =
                              NVL (p_attributes (l_index).attribute24, c_null)
                AND NVL (l_attribute_rec.attribute25, c_null) =
                              NVL (p_attributes (l_index).attribute25, c_null)
                AND NVL (l_attribute_rec.attribute26, c_null) =
                              NVL (p_attributes (l_index).attribute26, c_null)
                AND NVL (l_attribute_rec.attribute27, c_null) =
                              NVL (p_attributes (l_index).attribute27, c_null)
                AND NVL (l_attribute_rec.attribute28, c_null) =
                              NVL (p_attributes (l_index).attribute28, c_null)
                AND NVL (l_attribute_rec.attribute29, c_null) =
                              NVL (p_attributes (l_index).attribute29, c_null)
                AND NVL (l_attribute_rec.attribute30, c_null) =
                              NVL (p_attributes (l_index).attribute30, c_null)
               )
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location
                                 (   ' - Attribute '
                                  || p_attributes (l_index).time_attribute_id
                                  || ' Not Changed',
                                  40
                                 );
               END IF;

               p_attributes (l_index).changed := 'N';
               p_attributes (l_index).process := 'N';
            ELSE
               IF g_debug
               THEN
                  hr_utility.set_location
                                 (   ' - Attribute '
                                  || p_attributes (l_index).time_attribute_id
                                  || ' Changed',
                                  50
                                 );
               END IF;

               p_attributes (l_index).changed := 'Y';
               p_attributes (l_index).process := 'Y';
            END IF;
         ELSE
            IF g_debug
            THEN
               hr_utility.set_location
                                 (   ' - Attribute '
                                  || p_attributes (l_index).time_attribute_id
                                  || ' Not Found',
                                  60
                                 );
            END IF;

            p_attributes (l_index).NEW := 'Y';
            p_attributes (l_index).changed := 'N';
            p_attributes (l_index).process := 'Y';
         END IF;

         CLOSE find_attribute;

         l_index := p_attributes.NEXT (l_index);
      END LOOP;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving: ' || l_proc, 70);
      END IF;
   END set_new_change_flags;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           find_parent_building_block
-- IN Parameters:  p_start_time -> Start Time of the TBB
--                 p_resource_id -> Resource ID (Person ID)
--                 p_resource_type -> Defaults to 'PERSON', use the default
--                 p_scope -> 'DAY' or 'DETAIL' (TIMECARD TBBs do not
--                             have parents)
--                 p_app_blocks -> The PL/SQL table already holding a timecard
--                                 This might be empty
-- OUT Parameters: p_timecard_bb_id -> id of the parent TBB id
--                 p_timecard_ovn -> ovn of the parent TBB id
--
-- Description:   By passing in the details of a TBB (p_start_time,
--                p_resource_id), this procedure will
--                work out what the parent for that TBB should be.  We can do
--                this, because for a certain time and resource id, there
--                can only be one parent TBB to which this TBB can be added.
--
--                If a DAY TBB is passed in, this procedure will work out
--                to which TIMECARD TBB this DAY TBB needs to be attached,
--                if a DETAIL TBB is passed in, this procedure will work out
--                to which DAY TBB this DETAIL TBB needs to be attached.
--
--                The procedure will first scan the PL/SQL timecard table to
--                see if it can find the TBB in there.  If this table is empty
--                it will look in the DB.
--
-- Exceptions:     No Timecard found
--                 Wrong Timecard in PL/SQL Table
-----------------------------------------------------------------------------
   PROCEDURE find_parent_building_block (
      p_start_time       IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id      IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type    IN              hxc_time_building_blocks.resource_type%TYPE,
      p_scope            IN              hxc_time_building_blocks.SCOPE%TYPE,
      p_app_blocks       IN              hxc_self_service_time_deposit.timecard_info,
      p_timecard_bb_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn     OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'find_parent_building_block (Overload)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks := convert_tbb_to_type (p_blocks => p_app_blocks);
      find_parent_building_block (p_start_time          => p_start_time,
                                  p_resource_id         => p_resource_id,
                                  p_resource_type       => p_resource_type,
                                  p_scope               => p_scope,
                                  p_app_blocks          => l_blocks,
                                  p_timecard_bb_id      => p_timecard_bb_id,
                                  p_timecard_ovn        => p_timecard_ovn
                                 );

/*      hxc_timecard.convert_to_type
          (p_attributes => in HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info)
          return HXC_ATTRIBUTE_TABLE_TYPE is

l_attributes HXC_ATTRIBUTE_TABLE_TYPE;
l_index      NUMBER;

*/
      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 40);
      END IF;
   END find_parent_building_block;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           get_timecard_bb_id
-- IN Parameters:  p_bb_id -> Start Time of the TBB
-- OUT Parameters: p_timecard_bb_id -> id of the parent TBB id
--                 p_timecard_ovn -> ovn of the parent TBB id
--
-- Description:   By passing in the id of a TBB, this procedure will work out
--                what the TIMECARD TBB is, so it finds the highest TBB in the
--                hierarchy of a timecard.  You can pass in the id of a DAY or
--                DETAIL (even TIMECARD although that wouldn't make a lot of
--                sence) TBB and it will return the ID and OVN of the TIMECARD
--                TBB this TBB belongs to.  The procedure only looks in the DB
--                so it is only usefull for timecards stored in the TimeStore.
--
-- Exceptions:     No Timecard found
-----------------------------------------------------------------------------
   PROCEDURE get_timecard_bb_id (
      p_bb_id            IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_bb_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn     OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   )
   IS
      l_proc   VARCHAR2 (72);

      -- This cursor will return the BB_ID and OVN of the current TIMECARD BB of a BB.
      CURSOR csr_get_timecard_bb_id (
         v_tc_id   hxc_time_building_blocks.time_building_block_id%TYPE
      )
      IS
         SELECT     time_building_block_id, MAX (object_version_number)
               FROM hxc_time_building_blocks
              WHERE SCOPE = hxc_timecard.c_timecard_scope
                AND date_to = hr_general.end_of_time
         CONNECT BY PRIOR parent_building_block_id = time_building_block_id
                AND PRIOR parent_building_block_ovn = object_version_number
         START WITH time_building_block_id = v_tc_id
           GROUP BY time_building_block_id
           ORDER BY time_building_block_id;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'get_timecard_bb_id';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      OPEN csr_get_timecard_bb_id (p_bb_id);

      FETCH csr_get_timecard_bb_id
       INTO p_timecard_bb_id, p_timecard_ovn;

      CLOSE csr_get_timecard_bb_id;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END get_timecard_bb_id;

-----------------------------------------------------------------------------
-- Type:           Function
-- Scope:          Public
-- Name:           get_index_in_bb_table
-- Returns:        PLS_INTEGER
-- IN Parameters:  p_bb_table -> TBB Table Type that needs to be scanned
--                 p_bb_id_to_find -> id of the TBB that is being looked for
--
-- Description:   This function will return the index of the row in the PL/SQL
--                table (passed in) that holds the id (also passed in) of the
--                TBB that is being looked for.  In case the TBB is not found
--                in the PL/SQL Table, a negative index is being returned.
--
-----------------------------------------------------------------------------
   FUNCTION get_index_in_bb_table (
      p_bb_table        IN   hxc_block_table_type,
      p_bb_id_to_find   IN   hxc_time_building_blocks.time_building_block_id%TYPE
   )
      RETURN PLS_INTEGER
   IS
      l_proc                   VARCHAR2 (72);
      l_building_block_count   PLS_INTEGER;
      l_index                  PLS_INTEGER;
      l_current_highest_ovn    PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'get_index_in_bb_table';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_building_block_count := p_bb_table.FIRST;
      -- Initialize to zero as lowest possible ovn is 1
      l_current_highest_ovn := 0;

      LOOP
         EXIT WHEN (NOT p_bb_table.EXISTS (l_building_block_count));

         IF p_bb_table (l_building_block_count).time_building_block_id =
                                                              p_bb_id_to_find
         THEN                                                     -- found BB
            IF (l_current_highest_ovn <
                     p_bb_table (l_building_block_count).object_version_number
               )
            THEN
               -- only set the index if this is a newer TBB
               l_index := l_building_block_count;
               -- set this now as the highest ovn
               l_current_highest_ovn :=
                    p_bb_table (l_building_block_count).object_version_number;
            END IF;
         END IF;

         l_building_block_count := p_bb_table.NEXT (l_building_block_count);
      END LOOP;

      IF l_index IS NULL
      THEN                  -- we never found the BB, return a negative number
         l_index := -1;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('   returning index = ' || l_index, 20);
         hr_utility.set_location ('Leaving:' || l_proc, 30);
      END IF;

      RETURN l_index;
   END get_index_in_bb_table;

-----------------------------------------------------------------------------
-- Type:           Function
-- Scope:          Public
-- Name:           get_deposit_process_id
-- Returns:        NUMBER
-- IN Parameters:  p_deposit_process_name -> Name of the deposit process for
--                                           which you want to get the ID
--
-- Description:   This function will return the Id of the deposit process passed
--                in.
--
-----------------------------------------------------------------------------
   FUNCTION get_deposit_process_id (
      p_deposit_process_name   IN   hxc_deposit_processes.NAME%TYPE
   )
      RETURN hxc_deposit_processes.deposit_process_id%TYPE
   IS
      l_proc                 VARCHAR2 (72);

      CURSOR csr_deposit_process_id (v_deposit_process_name IN VARCHAR2)
      IS
         SELECT deposit_process_id
           FROM hxc_deposit_processes
          WHERE NAME = v_deposit_process_name;

      l_deposit_process_id   hxc_deposit_processes.deposit_process_id%TYPE;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'get_deposit_process_id';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      OPEN csr_deposit_process_id (p_deposit_process_name);

      FETCH csr_deposit_process_id
       INTO l_deposit_process_id;

      IF csr_deposit_process_id%NOTFOUND
      THEN
         CLOSE csr_deposit_process_id;

         fnd_message.set_name ('HXC', 'HXC_NO_RETRIEVAL_PROCESS');
         fnd_message.set_token ('PROCESS_NAME', p_deposit_process_name);
         fnd_message.raise_error;
      END IF;

      CLOSE csr_deposit_process_id;

      IF g_debug
      THEN
         hr_utility.set_location (   '   returning deposit process id = '
                                  || l_deposit_process_id,
                                  20
                                 );
         hr_utility.set_location ('Leaving:' || l_proc, 30);
      END IF;

      RETURN l_deposit_process_id;
   END get_deposit_process_id;

-----------------------------------------------------------------------------
-- Type:           Function
-- Scope:          Public
-- Name:           get_index_in_attr_table
-- Returns:        PLS_INTEGER
-- IN Parameters:  p_attr_table -> Attribute PL/SQL table that needs to be scanned
--                 p_attr_id_to_find -> id of the attr that is being looked for
--
-- Description:   This function will return the index of the row in the PL/SQL
--                table (passed in) that holds the id (also passed in) of the
--                attr that is being looked for.  In case the TBattrB is not
--                found in the PL/SQL Table, a negative index is being returned.
--
-----------------------------------------------------------------------------
   FUNCTION get_index_in_attr_table (
      p_attr_table               IN   hxc_self_service_time_deposit.app_attributes_info,
      p_attr_id_to_find          IN   hxc_time_attributes.time_attribute_id%TYPE,
      p_attribute_name_to_find   IN   hxc_mapping_components.field_name%TYPE
   )
      RETURN PLS_INTEGER
   IS
      l_proc              VARCHAR2 (72);
      l_attribute_count   PLS_INTEGER;
      l_index             PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'get_index_in_attr_table';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_attribute_count := p_attr_table.FIRST;

      LOOP
         EXIT WHEN (NOT p_attr_table.EXISTS (l_attribute_count))
               OR (l_index IS NOT NULL);

         IF     (p_attr_table (l_attribute_count).time_attribute_id =
                                                             p_attr_id_to_find
                )
            AND (p_attr_table (l_attribute_count).attribute_name =
                                                      p_attribute_name_to_find
                )
         THEN
            -- found BB, set the index
            l_index := l_attribute_count;
         END IF;

         l_attribute_count := p_attr_table.NEXT (l_attribute_count);
      END LOOP;

      IF l_index IS NULL
      THEN                   -- we never found the BB return a negative number
         l_index := -1;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('   returning index = ' || l_index, 20);
         hr_utility.set_location ('Leaving:' || l_proc, 30);
      END IF;

      RETURN l_index;
   END get_index_in_attr_table;

-- Use this to find the parent BB if a range is given, this can not work for a measure
-- It needs the start and stop time to find the parent
-- this saves the user from having to find the ID of the parent block themselves
-- This only works because there is no overlap in BB start and stop times
-- Should this ever change than this procedure will cease to work as it might return multiple BB rows.
/*   PROCEDURE find_parent_building_block (
      p_building_block_id       OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_object_version_number   OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE,
      p_scope                   IN       hxc_time_building_blocks.SCOPE%TYPE,
      p_start_time              IN       hxc_time_building_blocks.start_time%TYPE,
      p_stop_time               IN       hxc_time_building_blocks.stop_time%TYPE,
      p_resource_id             IN       hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type           IN       hxc_time_building_blocks.resource_type%TYPE
            DEFAULT 'PERSON'
   )
   IS
      l_proc    VARCHAR2 (72)
               :=    g_package
                  || 'find_parent_building_block';

      -- This cursor will return the BB_ID and OVN of the parent TIMECARD BB.
      -- It should always return only one row!
      -- if it does not, there is overlap in the start and stop times which should not happen!
      CURSOR csr_get_parent (

--         v_tc_id   hxc_time_building_blocks.time_building_block_id%TYPE,
         v_scope           hxc_time_building_blocks.SCOPE%TYPE,
         v_start_time      hxc_time_building_blocks.start_time%TYPE,
         v_stop_time       hxc_time_building_blocks.stop_time%TYPE,
         v_resource_id     hxc_time_building_blocks.resource_id%TYPE,
         v_resource_type   hxc_time_building_blocks.resource_type%TYPE
      )
      IS
         SELECT   time_building_block_id, MAX (object_version_number)
             FROM hxc_time_building_blocks
            WHERE SCOPE = DECODE (v_scope, 'DAY', 'TIMECARD', 'DETAIL', 'DAY')
              AND v_start_time >= start_time
              AND v_stop_time <= stop_time
              AND v_resource_id = resource_id
              AND v_resource_type = resource_type
              AND date_to = hr_general.end_of_time
         GROUP BY time_building_block_id;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
         hr_utility.set_location (   'Entering:'
                   || l_proc, 10);
      end if;
      OPEN csr_get_parent (
         p_scope,
         p_start_time,
         p_stop_time,
         p_resource_id,
         p_resource_type
      );
      FETCH csr_get_parent INTO p_building_block_id, p_object_version_number;
      CLOSE csr_get_parent;
      if g_debug then
         hr_utility.set_location (   'Leaving:'
                   || l_proc, 20);
      end if;
   END find_parent_building_block;
*/

   -----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           get_timecard_tables
-- IN Parameters:  p_building_block_id -> TBB Id for which a timecard table
--                                        needs to be retrieved
--                 p_deposit_process -> Deposit process of which the mapping
--                                      will be used to retrieve the attrs
-- OUT Parameters: p_app_blocks -> TBB Type table that that will hold all
--                                 all the TBBs found
--                 p_app_attributes -> Attribute PL/SQL table that will hold
--                                     all the attrs found
-- Description:    This function will return the index of the row in the PL/SQL
--                 table (passed in) that holds the id (also passed in) of the
--                 attr that is being looked for.  In case the TBattrB is not
--                 found in the PL/SQL Table, a negative index is being returned.
--
-----------------------------------------------------------------------------
   PROCEDURE get_timecard_tables
     (p_building_block_id   IN            hxc_time_building_blocks.time_building_block_id%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_clear_mapping_cache IN            BOOLEAN default false,
      p_app_blocks             OUT NOCOPY hxc_block_table_type,
      p_app_attributes         OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info
      )
   IS
     l_proc                    VARCHAR2 (72);
     l_timecard_bb_id          hxc_time_building_blocks.time_building_block_id%TYPE;
     l_object_version_number   hxc_time_building_blocks.object_version_number%TYPE;
     l_counter                 PLS_INTEGER;
     l_attributes              hxc_attribute_table_type;
   BEGIN
     g_debug := hr_utility.debug_enabled;

     IF g_debug
     THEN
       l_proc := g_package || 'get_timecard_tables';
       hr_utility.set_location ('Entering:' || l_proc, 10);
     END IF;

     -- find out what the ID of the TIMECARD BB for this BB is
     get_timecard_bb_id (p_bb_id               => p_building_block_id,
                         p_timecard_bb_id      => l_timecard_bb_id,
                         p_timecard_ovn        => l_object_version_number
                         );

     IF g_debug
     THEN
       hr_utility.set_location ('Timecard BB_ID = ' || l_timecard_bb_id,
                                15);
     END IF;

     -- Then get the complete TC
     --    First get all the TBBs ...
     p_app_blocks :=
       hxc_timecard.load_blocks (p_timecard_id       => l_timecard_bb_id,
                                 p_timecard_ovn      => l_object_version_number
                                 );
      --    ... then all the attributes and store them in the Type structures
     l_attributes := hxc_timecard.load_attributes (p_blocks => p_app_blocks);
     -- Finally convert the attributes to app_attributes.
     p_app_attributes :=
       hxc_app_attribute_utils.create_app_attributes
       (p_attributes                => l_attributes,
        p_retrieval_process_id      => NULL,
        p_deposit_process_id        => get_deposit_process_id(p_deposit_process)
        );

     if(p_clear_mapping_cache) then
       hxc_app_attribute_utils.clear_mapping_cache;
     end if;

     IF g_debug
     THEN
       hr_utility.set_location ('Leaving:' || l_proc, 20);
     END IF;
   END get_timecard_tables;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           get_timecard_tables
-- IN Parameters:  p_building_block_id -> TBB Id for which a timecard table
--                                        needs to be retrieved
--                 p_deposit_process -> Deposit process of which the mapping
--                                      will be used to retrieve the attrs
-- OUT Parameters: p_app_blocks -> TBB PL/SQL table that that will hold all
--                                 all the TBBs found
--                 p_app_attributes -> Attribute PL/SQL table that will hold
--                                     all the attrs found
-- Description:    Overloaded procedure, using old PL/SQL Table for TBBs.  See
--                 main get_timecard_tables for more information
-----------------------------------------------------------------------------
   PROCEDURE get_timecard_tables
     (p_building_block_id   IN            hxc_time_building_blocks.time_building_block_id%TYPE,
      --      p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN            hxc_deposit_processes.NAME%TYPE,
      p_clear_mapping_cache IN            BOOLEAN default false,
      p_app_blocks             OUT NOCOPY hxc_self_service_time_deposit.timecard_info,
      p_app_attributes         OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'get_timecard_tables (Overloaded)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      get_timecard_tables (p_building_block_id      => p_building_block_id,
                           p_deposit_process        => p_deposit_process,
                           p_clear_mapping_cache    => p_clear_mapping_cache,
                           p_app_blocks             => l_blocks,
                           p_app_attributes         => p_app_attributes
                          );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END get_timecard_tables;

-----------------------------------------------------------------------------
-- Type:          Procedure
-- Scope:         Public
-- Name:          get_bld_blk_info_type
-- Returns:       hxc_bld_blk_info_types.bld_blk_info_type%TYPE
-- IN Parameters: p_attribute_name -> Name of the attribute
--                p_deposit_process -> Name of the deposit process which we will
--                                     use the mapping of
-- OUT Parameters: p_bld_blk_info_type -> BB Info Type for the attribute name
--                 p_segment -> Segment in which the attribute value needs to
--                              get stored.
--
-- Description:   Private Procedure that will find the Building Block Info Type
--                of an attribute and the segment in which the attribute needs
--                to get stored. It uses the mapping related to the deposit
--                process (passed in) to work out what the Building Block Info
--                Type is. The approval status is linked (hard coded here) to
--                the mode.
--
-----------------------------------------------------------------------------
   PROCEDURE get_bld_blk_info_type (
      p_attribute_name      IN              hxc_mapping_components.field_name%TYPE,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_bld_blk_info_type   OUT NOCOPY      hxc_bld_blk_info_types.bld_blk_info_type%TYPE,
      p_segment             OUT NOCOPY      hxc_mapping_components.SEGMENT%TYPE
   )
   IS
      l_proc   VARCHAR2 (72);

      CURSOR csr_bld_blk_info_type (
         v_field_name           hxc_mapping_components.field_name%TYPE,
         v_deposit_process_id   hxc_deposit_processes.deposit_process_id%TYPE
      )
      IS
         SELECT bbit.bld_blk_info_type, mc.SEGMENT
           FROM hxc_mapping_components mc,
                hxc_mapping_comp_usages mcu,
                hxc_mappings m,
                hxc_deposit_processes dp,
                hxc_bld_blk_info_types bbit,
                hxc_bld_blk_info_type_usages bbui
          WHERE dp.mapping_id = m.mapping_id
            AND m.mapping_id = mcu.mapping_id
            AND mcu.mapping_component_id = mc.mapping_component_id
            AND mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id
            AND bbit.bld_blk_info_type_id = bbui.bld_blk_info_type_id
            AND mc.field_name = v_field_name
            AND dp.deposit_process_id = v_deposit_process_id;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'get_bld_blk_info_type';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      OPEN csr_bld_blk_info_type (p_attribute_name,
                                  get_deposit_process_id (p_deposit_process)
                                 );

      FETCH csr_bld_blk_info_type
       INTO p_bld_blk_info_type, p_segment;

      CLOSE csr_bld_blk_info_type;

      IF g_debug
      THEN
         hr_utility.set_location (   '   Found Building Block Info Type = '
                                  || p_bld_blk_info_type,
                                  20
                                 );
         hr_utility.set_location ('   Found Segment = ' || p_segment, 30);
         hr_utility.set_location ('Leaving:' || l_proc, 40);
      END IF;
   END get_bld_blk_info_type;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           clear_building_block_table
-- INOUT Parameters: p_app_blocks -> TBB Table Type you want to empty
--
-- Description:    This procedure will allow you to clear the TBB PL/SQL Table
--
-----------------------------------------------------------------------------
   PROCEDURE clear_building_block_table (
      p_app_blocks   IN OUT NOCOPY   hxc_block_table_type
   )
   IS
      l_proc   VARCHAR2 (72);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'clear_building_block_table';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      IF p_app_blocks.COUNT > 0
      THEN
         p_app_blocks.DELETE;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END clear_building_block_table;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           clear_attribute_table
-- INOUT Parameters: p_app_attributes -> Attr PL/SQL table you want to empty
--
-- Description:    This procedure will allow you to clear the Attr PL/SQL Table
--
-----------------------------------------------------------------------------
   PROCEDURE clear_attribute_table (
      p_app_attributes   IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_proc   VARCHAR2 (72);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'clear_attribute_table';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      IF p_app_attributes.COUNT > 0
      THEN
         p_app_attributes.DELETE;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END clear_attribute_table;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           clear_message_table
-- INOUT Parameters: p_messages -> Message PL/SQL table you want to empty
--
-- Description:    This procedure will allow you to clear the Message PL/SQL Table
--
-----------------------------------------------------------------------------
   PROCEDURE clear_message_table (
      p_messages   IN OUT NOCOPY   hxc_message_table_type
   )
   IS
      l_proc   VARCHAR2 (72);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'clear_message_table';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      IF p_messages.COUNT > 0
      THEN
         p_messages.DELETE;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END clear_message_table;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           request_lock
-- IN Parameters: p_app_blocks -> TBB PL/SQL table you want to lock
-- IN OUT Parameters: p_messages -> Message PL/SQL table
-- OUT Parameters: p_locked_success -> Lock was successful or not
--                 p_row_lock_id -> lock id of the lock
-- Description:   This procedure will allow you to lock the period for which you
--                are about to create or update a TC.
--
-----------------------------------------------------------------------------
   PROCEDURE request_lock (
      p_app_blocks       IN              hxc_block_table_type,
      p_messages         IN OUT NOCOPY   hxc_message_table_type,
      p_locked_success   OUT NOCOPY      BOOLEAN,
      p_row_lock_id      OUT NOCOPY      ROWID
   )
   IS
      l_proc       VARCHAR2 (72);
      l_tc_index   PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'request_lock';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_tc_index :=
            hxc_timecard_block_utils.find_active_timecard_index (p_app_blocks);

      IF (hxc_timecard_block_utils.is_new_block (p_app_blocks (l_tc_index)))
      THEN
         hxc_lock_api.request_lock
            (p_process_locker_type          => hxc_lock_util.c_plsql_deposit_action,
             p_resource_id                  => p_app_blocks (l_tc_index).resource_id,
             p_start_time                   => fnd_date.canonical_to_date
                                                  (p_app_blocks (l_tc_index).start_time
                                                  ),
             p_stop_time                    => fnd_date.canonical_to_date
                                                  (p_app_blocks (l_tc_index).stop_time
                                                  ),
             p_time_building_block_id       => NULL,
             p_time_building_block_ovn      => NULL,
             p_row_lock_id                  => p_row_lock_id,
             p_messages                     => p_messages,
             p_locked_success               => p_locked_success
            );
      ELSE
         hxc_lock_api.request_lock
            (p_process_locker_type          => hxc_lock_util.c_plsql_deposit_action,
             p_resource_id                  => NULL,
             p_start_time                   => NULL,
             p_stop_time                    => NULL,
             p_time_building_block_id       => p_app_blocks (l_tc_index).time_building_block_id,
             p_time_building_block_ovn      => p_app_blocks (l_tc_index).object_version_number,
             p_row_lock_id                  => p_row_lock_id,
             p_messages                     => p_messages,
             p_locked_success               => p_locked_success
            );
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END request_lock;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           release_lock
-- IN Parameters: p_app_blocks -> TBB PL/SQL table you want to release the lock
--                                for
-- IN OUT Parameters: p_messages -> Message PL/SQL table
-- OUT Parameters: p_released_success -> Lock was released successful or not
--                 p_row_lock_id -> lock id of the lock you want to release
-- Description:   This procedure will allow you to release the lock on the
--                period that you grabbed with request_lock.
--
-----------------------------------------------------------------------------
   PROCEDURE release_lock (
      p_app_blocks         IN              hxc_block_table_type,
      p_messages           IN OUT NOCOPY   hxc_message_table_type,
      p_released_success   OUT NOCOPY      BOOLEAN,
      p_row_lock_id        IN OUT NOCOPY   ROWID
   )
   IS
      l_proc       VARCHAR2 (72);
      l_tc_index   PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'release_lock';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_tc_index :=
            hxc_timecard_block_utils.find_active_timecard_index (p_app_blocks);

      IF (hxc_timecard_block_utils.is_new_block (p_app_blocks (l_tc_index)))
      THEN
         hxc_lock_api.release_lock
            (p_row_lock_id                  => p_row_lock_id,
             p_process_locker_type          => hxc_lock_util.c_plsql_deposit_action,
             p_resource_id                  => p_app_blocks (l_tc_index).resource_id,
             p_start_time                   => fnd_date.canonical_to_date
                                                  (p_app_blocks (l_tc_index).start_time
                                                  ),
             p_stop_time                    => fnd_date.canonical_to_date
                                                  (p_app_blocks (l_tc_index).stop_time
                                                  ),
             p_time_building_block_id       => NULL,
             p_time_building_block_ovn      => NULL,
             p_messages                     => p_messages,
             p_released_success             => p_released_success
            );
      ELSE
         hxc_lock_api.release_lock
            (p_row_lock_id                  => p_row_lock_id,
             p_process_locker_type          => hxc_lock_util.c_plsql_deposit_action,
             p_resource_id                  => NULL,
             p_start_time                   => NULL,
             p_stop_time                    => NULL,
             p_time_building_block_id       => p_app_blocks (l_tc_index).time_building_block_id,
             p_time_building_block_ovn      => p_app_blocks (l_tc_index).object_version_number,
             p_messages                     => p_messages,
             p_released_success             => p_released_success
            );
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END release_lock;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           log_timecard
-- IN Parameters: p_app_blocks -> TBB type you want to log
--                p_app_attributes -> Attr PL/SQL table you want to log
-- Description:   This procedure will allow you log the complete timecard and
--                all it's associated attributes in fnd_log_messages.  For this
--                to work you will have to set the the profile option
--                FND: Debug Log Enabled = Yes and FND: Debug Log Level =
--                Statement.  Also your code must contain a line in the beginning
--                that looks like this:
--                   FND_GLOBAL.APPS_INITIALIZE
--                      ( user_id      => <user id you are loggin msg under>,
--                        resp_id      => <responsibility id of the user>
--                        resp_appl_id => 809 )
--                       ;
--
--                 This procedure is provided for debugging purposes.
--
-----------------------------------------------------------------------------
   PROCEDURE log_timecard (
      p_app_blocks       IN   hxc_block_table_type,
      p_app_attributes   IN   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_proc   VARCHAR2 (72);
      i        PLS_INTEGER;
      j        PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'log_timecard';
         hr_utility.set_location ('Entering:' || l_proc, 10);
         hr_utility.set_location ('   Number of BBs:' || p_app_blocks.COUNT,
                                  15
                                 );
         hr_utility.set_location (   '   Number of Attrs:'
                                  || p_app_attributes.COUNT,
                                  16
                                 );
      END IF;

      i := p_app_blocks.FIRST;

      <<print_time_building_blocks>>
      LOOP
         EXIT print_time_building_blocks WHEN (NOT p_app_blocks.EXISTS (i));

         IF g_debug
         THEN
            hr_utility.TRACE
               (   LPAD
                       (NVL (TO_CHAR (p_app_blocks (i).time_building_block_id),
                             ' '
                            ),
                        9
                       )
                || ' '
                || RPAD (NVL (p_app_blocks (i).TYPE, ' '), 7)
                || ' '
                || LPAD (NVL (TO_CHAR (p_app_blocks (i).measure), ' '), 7)
                || ' '
                || RPAD (NVL (p_app_blocks (i).unit_of_measure, ' '), 5)
                || ' '
                || RPAD (NVL (p_app_blocks (i).start_time, ' '), 20)
                || ' '
                || RPAD (NVL (p_app_blocks (i).stop_time, ' '), 20)
                || ' '
                || LPAD
                      (NVL (TO_CHAR (p_app_blocks (i).parent_building_block_id),
                            ' '
                           ),
                       9
                      )
                || ' '
                || RPAD (NVL (p_app_blocks (i).parent_is_new, ' '), 2)
                || ' '
                || RPAD (NVL (p_app_blocks (i).SCOPE, ' '), 8)
                || ' '
                || LPAD (NVL (TO_CHAR (p_app_blocks (i).object_version_number),
                              ' '
                             ),
                         5
                        )
                || ' '
                || RPAD (NVL (p_app_blocks (i).approval_status, ' '), 10)
                || ' '
                || LPAD (NVL (TO_CHAR (p_app_blocks (i).resource_id), ' '),
                         10)
                || ' '
                || RPAD (NVL (p_app_blocks (i).resource_type, ' '), 10)
                || ' '
                || LPAD (NVL (TO_CHAR (p_app_blocks (i).approval_style_id),
                              ' '
                             ),
                         5
                        )
                || ' '
                || RPAD (p_app_blocks (i).date_from, 11)
                || ' '
                || RPAD (p_app_blocks (i).date_to, 11)
                || ' '
                || RPAD (NVL (p_app_blocks (i).comment_text, ' '), 30)
                || ' '
                || RPAD
                      (NVL
                          (TO_CHAR (p_app_blocks (i).parent_building_block_ovn),
                           ' '
                          ),
                       5
                      )
                || ' '
                || RPAD (NVL (p_app_blocks (i).NEW, ' '), 2)
                || ' '
                || RPAD (NVL (p_app_blocks (i).changed, ' '), 2)
                || ' '
               );
         END IF;

         -- Find out if this BB has any attributes
         -- if so, print them with this BB
         j := p_app_attributes.FIRST;

         <<print_attributes>>
         LOOP
            EXIT print_attributes WHEN (NOT p_app_attributes.EXISTS (j));

            IF p_app_blocks (i).time_building_block_id =
                                       p_app_attributes (j).building_block_id
            THEN
               IF g_debug
               THEN
                  hr_utility.TRACE
                              (   '         '
                               ||               --indent to indicate attribute
                                  LPAD (p_app_attributes (j).time_attribute_id,
                                        9
                                       )
                               || '  '
                               || LPAD (p_app_attributes (j).building_block_id,
                                        9
                                       )
                               || '  '
                               || RPAD (p_app_attributes (j).attribute_name,
                                        20
                                       )
                               || '  '
                               || RPAD (p_app_attributes (j).attribute_value,
                                        20
                                       )
                               || '  '
                               || RPAD (p_app_attributes (j).bld_blk_info_type,
                                        20
                                       )
                               || '  '
                               || RPAD (p_app_attributes (j).CATEGORY, 20)
                               || '  '
                               || RPAD (p_app_attributes (j).updated, 2)
                               || '  '
                               || RPAD (p_app_attributes (j).changed, 2)
                               || '  '
                              );
               END IF;
            END IF;

            j := p_app_attributes.NEXT (j);
         END LOOP print_attributes;

         i := p_app_blocks.NEXT (i);
      END LOOP print_time_building_blocks;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END log_timecard;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           log_timecard
-- IN Parameters: p_app_blocks -> TBB PL/SQL table you want to log
--                p_app_attributes -> Attr PL/SQL table you want to log
-- Description:   This procedure will allow you log the complete timecard and
--                all it's associated attributes in fnd_log_messages.  For this
--                to work you will have to set the the profile option
--                FND: Debug Log Enabled = Yes and FND: Debug Log Level =
--                Statement.  Also your code must contain a line in the beginning
--                that looks like this:
--                   FND_GLOBAL.APPS_INITIALIZE
--                      ( user_id      => <user id you are loggin msg under>,
--                        resp_id      => <responsibility id of the user>
--                        resp_appl_id => 809 )
--                       ;
--
--                 This procedure is provided for debugging purposes.
--
-----------------------------------------------------------------------------
   PROCEDURE log_timecard (
      p_app_blocks       IN   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes   IN   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'log_timecard (Overloaded)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks := convert_tbb_to_type (p_blocks => p_app_blocks);
      log_timecard (p_app_blocks          => l_blocks,
                    p_app_attributes      => p_app_attributes
                   );

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END log_timecard;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           log_messages
-- IN Parameters: p_messages -> Message type you want to log
-- Description:   This procedure will allow you log the messages returned by the
--                deposit process.
--                For this to work you will have to set the the profile option
--                FND: Debug Log Enabled = Yes and FND: Debug Log Level =
--                Statement.  Also your code must contain a line in the beginning
--                that looks like this:
--                   FND_GLOBAL.APPS_INITIALIZE
--                      ( user_id      => <user id you are loggin msg under>,
--                        resp_id      => <responsibility id of the user>
--                        resp_appl_id => 809 )
--                       ;
--
--                 This procedure is provided for debugging purposes.
--
-----------------------------------------------------------------------------
   PROCEDURE log_messages (p_messages IN hxc_message_table_type)
   IS
      l_proc      VARCHAR2 (72);
      l_message   fnd_new_messages.MESSAGE_TEXT%TYPE;
      i           PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'log_messages';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      IF (p_messages IS NOT NULL)
      THEN                                      -- messages have been returned
         i := p_messages.FIRST;

         LOOP
            EXIT WHEN (NOT p_messages.EXISTS (i));
            -- First translate the message as the messagetable returned does not give the actual
            -- message, only the message_name which doesn't mean anything to the user.
            l_message :=
               fnd_message.get_string
                              (appin       => p_messages (i).application_short_name,
                               namein      => p_messages (i).message_name
                              );

            IF g_debug
            THEN
               hr_utility.TRACE
                  (   RPAD (p_messages (i).application_short_name, 10)
                   || ' '
                   || LPAD (p_messages (i).time_building_block_id, 7)
                   || ' '
                   || LPAD
                         (NVL (TO_CHAR (p_messages (i).time_building_block_ovn),
                               ' '
                              ),
                          5
                         )
                   || ' '
                   || LPAD (NVL (TO_CHAR (p_messages (i).time_attribute_id),
                                 ' '
                                ),
                            7
                           )
                   || ' '
                   || LPAD (p_messages (i).time_attribute_ovn, 5)
                   || ' '
                   || RPAD (p_messages (i).message_name, 30)
                   || ' '
                   || RPAD (l_message, 80)
                   || ' '
                   || RPAD (p_messages (i).message_level, 10)
                   || ' '
                   || RPAD (p_messages (i).message_field, 30)
                   || ' '
                   || RPAD (p_messages (i).message_tokens, 30)
                   || ' '
                  --                              rpad(p_messages(i).on_oa_msg_stack,30)||' '
                  );
            END IF;

            i := p_messages.NEXT (i);
         END LOOP;
      ELSE
         IF g_debug
         THEN
            hr_utility.TRACE
                   (' --- No Errors Found, Timecard Deposit Successfull! ---');
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END log_messages;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           log_messages
-- IN Parameters: p_messages -> Message PL/SQL table you want to log
--                p_retrieval_process_id -> process id for retrieval
-- Description:   This procedure will allow you log the messages returned by the
--                deposit process.
--                For this to work you will have to set the the profile option
--                FND: Debug Log Enabled = Yes and FND: Debug Log Level =
--                Statement.  Also your code must contain a line in the beginning
--                that looks like this:
--                   FND_GLOBAL.APPS_INITIALIZE
--                      ( user_id      => <user id you are loggin msg under>,
--                        resp_id      => <responsibility id of the user>
--                        resp_appl_id => 809 )
--                       ;
--
--                 This procedure is provided for debugging purposes.
--
-----------------------------------------------------------------------------
   PROCEDURE log_messages (
      p_messages   IN   hxc_self_service_time_deposit.message_table
   )
   IS
      l_proc       VARCHAR2 (72);
      l_messages   hxc_message_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'log_messages (Overloaded)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      hxc_timecard_message_utils.append_old_messages
                                               (p_messages                  => l_messages,
                                                p_old_messages              => p_messages,
                                                p_retrieval_process_id      => NULL
                                               );
      log_messages (p_messages => l_messages);

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END log_messages;

-----------------------------------------------------------------------------
-- Type:           Function
-- Scope:          Public
-- Name:           translate_message_table
-- Returns:        hxc_self_service_time_deposit.message_table
-- IN Parameters: p_messages -> Message PL/SQL table you want to use for
--                              replacing tokens.
-- Description:   This procedure will take the message table from the deposit
--                wrapper and construct a new table that will have the proper
--                message in it with all tokens properly filled in.
--                This procedure is provided for debugging purposes.
--
-----------------------------------------------------------------------------
   FUNCTION translate_message_table (
      p_messages   IN   hxc_self_service_time_deposit.message_table
   )
      RETURN translated_message_table
   IS
      l_proc          VARCHAR2 (72);
      l_messages      translated_message_table;
      l_token_table   hxc_deposit_wrapper_utilities.t_simple_table;
      l_message_idx   PLS_INTEGER                         := p_messages.FIRST;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'translate_message_table';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      <<process_all_messages>>
      LOOP
         EXIT process_all_messages WHEN NOT p_messages.EXISTS (l_message_idx);
         -- set message on stack so we can work with it
         fnd_message.set_name
                           (p_messages (l_message_idx).application_short_name,
                            p_messages (l_message_idx).message_name
                           );

         IF (p_messages (l_message_idx).message_tokens IS NOT NULL)
         THEN
            hxc_deposit_wrapper_utilities.string_to_table
                                   ('&',
                                       '&'
                                    || p_messages (l_message_idx).message_tokens,
                                    l_token_table
                                   );

            FOR l_token IN 0 .. (l_token_table.COUNT / 2) - 1
            LOOP
               -- replace all tokens in the message on the stack
               fnd_message.set_token (token      => l_token_table (2 * l_token),
                                      VALUE      => l_token_table (    2
                                                                     * l_token
                                                                   + 1
                                                                  )
                                     );
            END LOOP;
         END IF;

         -- get the message back from the stack and put in the message table...
         l_messages (l_message_idx).message_name :=
                                       p_messages (l_message_idx).message_name;
         -- ... and just copy the other fields for convinience.
         l_messages (l_message_idx).MESSAGE_TEXT := fnd_message.get;
         l_messages (l_message_idx).time_building_block_id :=
                             p_messages (l_message_idx).time_building_block_id;
         l_messages (l_message_idx).time_building_block_ovn :=
                            p_messages (l_message_idx).time_building_block_ovn;
         l_messages (l_message_idx).time_attribute_id :=
                                  p_messages (l_message_idx).time_attribute_id;
         l_messages (l_message_idx).time_attribute_ovn :=
                                 p_messages (l_message_idx).time_attribute_ovn;
         l_message_idx := p_messages.NEXT (l_message_idx);
      END LOOP process_all_messages;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 100);
      END IF;

      RETURN l_messages;
   END translate_message_table;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           find_current_period
-- IN Parameters: p_resource_id ->
--                p_resource_type ->
--                p_day ->
-- OUT Parameters: p_start_time ->
--                 p_stop_time ->
-- Description:   This procedure will try to work out the start and end date for
--                the timecard to be created.  This can easily be worked out
--                from the TC recuring period, but we also need to take into
--                consideration the effective dates of the active assignments
--                for the resource in question, i.e. we should not let the TC
--                start before an assignment exists for the resouce.
--
-----------------------------------------------------------------------------
   PROCEDURE find_current_period (
      p_resource_id     IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type   IN              hxc_time_building_blocks.resource_type%TYPE,
      p_day             IN              hxc_time_building_blocks.start_time%TYPE,
      p_start_time      OUT NOCOPY      DATE,
      p_stop_time       OUT NOCOPY      DATE
   )
   IS
      l_proc           VARCHAR2 (72);
      l_periods        hxc_timecard_utilities.periods;
      l_period_idx     PLS_INTEGER;
      l_period_found   BOOLEAN                        DEFAULT FALSE;
   BEGIN
      IF g_debug
      THEN
         l_proc := g_package || 'find_current_period';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      hxc_timecard_utilities.init_globals (p_resource_id => p_resource_id);
      l_periods :=
         hxc_timecard_utilities.get_periods
                                          (p_resource_id                 => p_resource_id,
                                           p_resource_type               => p_resource_type,
                                           p_current_date                => p_day,
                                           p_show_existing_timecard      => 'Y'
                                          );
      l_period_idx := l_periods.FIRST;

      <<find_period>>
      LOOP
         EXIT find_period WHEN NOT l_periods.EXISTS (l_period_idx)
                           OR l_period_found;

         IF (TRUNC (p_day) BETWEEN TRUNC(l_periods (l_period_idx).start_date)
                               AND TRUNC(l_periods (l_period_idx).end_date)
            )
         THEN
            p_start_time :=
               TO_DATE (   TO_CHAR (l_periods (l_period_idx).start_date,
                                    'DD-MM-YYYY'
                                   )
                        || ' 00:00:00',
                        'DD-MM-YYYY HH24:MI:SS'
                       );
            p_stop_time :=
               TO_DATE (   TO_CHAR (l_periods (l_period_idx).end_date,
                                    'DD-MM-YYYY'
                                   )
                        || ' 23:59:59',
                        'DD-MM-YYYY HH24:MI:SS'
                       );
            l_period_found := TRUE;
         END IF;

         l_period_idx := l_periods.NEXT (l_period_idx);
      END LOOP find_period;
   END find_current_period;

   FUNCTION cla_enabled (
      p_building_block_id   IN   hxc_time_building_blocks.time_building_block_id%TYPE
   )
      RETURN BOOLEAN
   AS
      l_cla_enabled   BOOLEAN;
      l_cla_terg_id   hxc_pref_hierarchies.attribute1%TYPE;

      FUNCTION resource_id (
         p_building_block_id   IN   hxc_time_building_blocks.time_building_block_id%TYPE
      )
         RETURN hxc_time_building_blocks.resource_id%TYPE
      AS
         l_resource_id   hxc_time_building_blocks.resource_id%TYPE;
      BEGIN
         SELECT MAX (htbb.resource_id)
           INTO l_resource_id
           FROM hxc_time_building_blocks htbb
          WHERE htbb.time_building_block_id = p_building_block_id
            AND resource_type = 'PERSON';

         RETURN l_resource_id;
      END resource_id;
/*
|| MAIN
*/
   BEGIN

      <<get_cla_id>>
      BEGIN
         l_cla_terg_id :=
            hxc_preference_evaluation.resource_preferences
                          (p_resource_id          => resource_id
                                                          (p_building_block_id),
                           p_pref_code            => 'TS_PER_AUDIT_REQUIREMENTS',
                           p_attribute_n          => 1,
                           p_evaluation_date      => SYSDATE
                          );
      EXCEPTION
         WHEN OTHERS
         THEN
            -- Since we want to be as restrictive as possible, and CLA ON is more
            -- restrictive than CLA OFF, we just emulate CLA ON when no CLA
            -- preference has been found by setting the id to -1.
            l_cla_terg_id := -1;
      END get_cla_id;

      IF (l_cla_terg_id IS NOT NULL)
      THEN
         l_cla_enabled := TRUE;
      ELSE
         l_cla_enabled := FALSE;
      END IF;

      RETURN l_cla_enabled;
   END cla_enabled;


-----------------------------------------------------------------------------
-- Type:          Procedure
-- Scope:         Public
-- Name:          get_past_future_limits
-- IN Parameters: p_resource_id, p_timecard_start_time, p_timecard_stop_time
-- IN OUT Param : p_messages
--
-- Description:   Public Procedure that can be used to get the past and future
--                dates till which a timecard can be created/updated through API
--
-- Procedure added for bug 8900783
-----------------------------------------------------------------------------
   PROCEDURE get_past_future_limits (p_resource_id         IN   	 hxc_time_building_blocks.resource_id%TYPE,
            			     p_timecard_start_time IN  		 date,
            			     p_timecard_stop_time  IN  		 date,
            			     p_messages	           IN OUT NOCOPY hxc_message_table_type)
   IS
        l_index       		 BINARY_INTEGER;
  	l_pref_table  		 hxc_preference_evaluation.t_pref_table;
  	l_num_past_days          NUMBER;
  	l_num_future_days        NUMBER;
  	l_past_date_limit	 DATE;
  	l_future_date_limit	 DATE;

   BEGIN

         hxc_preference_evaluation.resource_preferences(
                 p_resource_id    => p_resource_id
        	,p_pref_code_list => 'TC_W_TCRD_ST_ALW_EDITS'
                ,p_pref_table     => l_pref_table );

         l_index := l_pref_table.FIRST;

         WHILE ( l_index IS NOT NULL )
	 LOOP

          IF ( l_pref_table(l_index).preference_code = 'TC_W_TCRD_ST_ALW_EDITS' )
	  THEN
	     l_num_future_days    :=  l_pref_table(l_index).attribute11  ;
	     l_num_past_days	  :=  l_pref_table(l_index).attribute6 ;

	  END IF;
	  l_index := l_pref_table.NEXT(l_index);

	 END LOOP;

	  IF g_debug THEN
		hr_utility.trace('l_num_past_days=' || l_num_past_days);
		hr_utility.trace('l_num_future_days=' || l_num_future_days);
	  END IF;

	  IF l_num_past_days IS NOT NULL
	  THEN
	    l_past_date_limit := SYSDATE - TO_NUMBER(l_num_past_days);
	  ELSE
	    l_past_date_limit := hr_general.START_OF_TIME;
	  END IF;

	  IF l_num_future_days IS NOT NULL
	  THEN
	    l_future_date_limit := SYSDATE + TO_NUMBER(l_num_future_days);
	  ELSE
	    l_future_date_limit := hr_general.END_OF_TIME;
	  END IF;

	  l_past_date_limit := TRUNC(l_past_date_limit);
	  l_future_date_limit := TRUNC(l_future_date_limit);

          IF (p_timecard_start_time < l_past_date_limit
              OR
              p_timecard_stop_time > l_future_date_limit ) THEN

                 hr_utility.trace('Timecard not within the allowed past and future days limit');

	         hxc_timecard_message_helper.addErrorToCollection
	            (p_messages,
	             'HXC_NO_PERIODS_TO_CREATE',
	             hxc_timecard.c_error,
	             null,
	             null,
	             hxc_timecard.c_hxc,
	             null,
	             null,
	             null,
	             null
	             );

          END IF;

	  IF g_debug THEN
		hr_utility.trace(' l_past_date_limit =' || to_char(l_past_date_limit, 'DD-MON-YYYY'));
		hr_utility.trace(' l_future_date_limit=' ||to_char(l_future_date_limit, 'DD-MON-YYYY') );
	  END IF;

   END get_past_future_limits;

END hxc_timestore_deposit_util;

/
