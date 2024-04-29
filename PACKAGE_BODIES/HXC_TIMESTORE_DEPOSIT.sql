--------------------------------------------------------
--  DDL for Package Body HXC_TIMESTORE_DEPOSIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMESTORE_DEPOSIT" AS
/* $Header: hxctsdp.pkb 120.7.12010000.2 2009/11/20 10:04:40 bbayragi ship $ */

   -- Global package name
   g_package   CONSTANT VARCHAR2 (33) := 'hxc_timestore_deposit.';
   g_debug              BOOLEAN       := hr_utility.debug_enabled;

   PROCEDURE get_timecard_tables (
      p_building_block_id     IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_deposit_process       IN              hxc_deposit_processes.NAME%TYPE,
      p_clear_mapping_cache   IN              BOOLEAN DEFAULT FALSE,
      p_app_blocks            OUT NOCOPY      hxc_block_table_type,
      p_app_attributes        OUT NOCOPY      hxc_self_service_time_deposit.app_attributes_info
   )
   IS
   BEGIN
      hxc_timestore_deposit_util.get_timecard_tables (p_building_block_id,
                                                      p_deposit_process,
                                                      p_clear_mapping_cache,
                                                      p_app_blocks,
                                                      p_app_attributes
                                                     );
   END get_timecard_tables;

   PROCEDURE get_timecard_tables (
      p_building_block_id     IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_deposit_process       IN              hxc_deposit_processes.NAME%TYPE,
      p_clear_mapping_cache   IN              BOOLEAN DEFAULT FALSE,
      p_app_blocks            OUT NOCOPY      hxc_self_service_time_deposit.timecard_info,
      p_app_attributes        OUT NOCOPY      hxc_self_service_time_deposit.app_attributes_info
   )
   IS
   BEGIN
      hxc_timestore_deposit_util.get_timecard_tables (p_building_block_id,
                                                      p_deposit_process,
                                                      p_clear_mapping_cache,
                                                      p_app_blocks,
                                                      p_app_attributes
                                                     );
   END get_timecard_tables;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_bb
-- IN Parameters:  p_time building_block_id -> Dummy TBB Id for the TBB, this
--                                            is needed to link potential child
--                                            TBBs to this TBB.
--                 p_type -> 'MEASURE' or 'RANGE'
--                 p_measure -> The actual time recorded, e.g. 8 Only provide
--                              when type is MEASURE
--                 p_unit_of_measure -> Units of measure for previous parameter
--                                      defaults to 'HOURS', use default
--                 p_start_time -> The IN time Only provide when type is RANGE
--                 p_stop_time -> The OUT time Only provide when type is RANGE
--                 p_parent_building_block_id -> Id of the TBB to which this TBB
--                                                needs to be attached
--                 p_parent_is_new -> Set to 'Y', if parent does not exist yet
--                                    in the database, i.e. gets created together
--                                    with this TBB
--                 p_scope -> 'TIMECARD', 'DAY' or 'DETAIL'
--                 p_object_version_number -> ovn of the TBB you try to create
--                                            Defaults to 1, use detault
--                 p_approval_status -> 'WORKING' or 'SUBMITTED'
--                 p_resource_id -> Person Id to which the TBB needs to be attached
--                 p_resource_type -> 'PERSON'
--                 p_approval_style_id -> The Id of the approval style used
--                                        to approve the TBB
--                 p_date_from -> date from which the TBB is valid. defaults
--                                to SYSDATE, use default
--                 p_date_to -> date till which the TBB is valid. defaults to
--                                to hr_general.end_of_time, use default
--                 p_comment_text -> comment to be saved with TBB
--                 p_parent_building_block_ovn -> ovn of the parent TBB, should
--                                                always be the highest ovn
--                                                as we do not allow attaching
--                                                TBBs to old TBBs
--                 p_new -> For new TBBs this needs to be Y, defaults to 'Y',
--                          use default
--                 p_changed ->  For new TBBs this needs to be N, defaults to
--                               'N', use default
-- INOUT Parameters: p_app_blocks -> TBB Type Table to which the new TBB will be
--                                   added.
--
-- Description:    This procedure will allow you to add a TBB of any type to
--                 the TBB PL/SQL table (passed in).    The BB will be added
--                 to the same TC as all the other BB already in the table
--                 If you want to add BBs to another table, please clear it
--                 first and start afresh
--
-----------------------------------------------------------------------------
   PROCEDURE create_bb (
      p_time_building_block_id      IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_type                        IN              hxc_time_building_blocks.TYPE%TYPE,
      p_measure                     IN              hxc_time_building_blocks.measure%TYPE,
      p_unit_of_measure             IN              hxc_time_building_blocks.unit_of_measure%TYPE,
      p_start_time                  IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                   IN              hxc_time_building_blocks.stop_time%TYPE,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE,
      p_parent_is_new               IN              VARCHAR2,
      p_scope                       IN              hxc_time_building_blocks.SCOPE%TYPE,
      p_object_version_number       IN              hxc_time_building_blocks.object_version_number%TYPE,
      p_approval_status             IN              hxc_time_building_blocks.approval_status%TYPE,
      p_resource_id                 IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type               IN              hxc_time_building_blocks.resource_type%TYPE,
      p_approval_style_id           IN              hxc_time_building_blocks.approval_style_id%TYPE,
      p_date_from                   IN              hxc_time_building_blocks.date_from%TYPE,
      p_date_to                     IN              hxc_time_building_blocks.date_to%TYPE,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE,
      p_new                         IN              VARCHAR2,
      p_changed                     IN              VARCHAR2,
      p_app_blocks                  IN OUT NOCOPY   hxc_block_table_type
   )
   IS
      l_proc                       VARCHAR2 (72);
      l_count_building_block       PLS_INTEGER;
      l_parent_building_block_id   hxc_time_building_blocks.time_building_block_id%TYPE;
      l_parent_ovn                 hxc_time_building_blocks.parent_building_block_ovn%TYPE;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_bb';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_count_building_block := NVL (p_app_blocks.LAST, 0);
      p_app_blocks.EXTEND;
      p_app_blocks (p_app_blocks.LAST) :=
         hxc_block_type (p_time_building_block_id,
                         p_type,
                         p_measure,
                         p_unit_of_measure,
                         fnd_date.date_to_canonical (p_start_time),
                         fnd_date.date_to_canonical (p_stop_time),
                         p_parent_building_block_id,
                         p_parent_is_new,
                         p_scope,
                         p_object_version_number,
                         p_approval_status,
                         p_resource_id,
                         p_resource_type,
                         p_approval_style_id,
                         fnd_date.date_to_canonical (p_date_from),
                         fnd_date.date_to_canonical (p_date_to),
                         p_comment_text,
                         p_parent_building_block_ovn,
                         p_new,
                         p_changed,
                         NULL,                                      -- Process
                         NULL,
                         -- Will now get populated in execute_deposit_process
                         NULL
                        -- Unable to set the display here - could expose it? a row num for example?
                        );

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END create_bb;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_bb
-- IN Parameters:  See overloaded Procedure
-- INOUT Parameters: p_app_blocks -> TBB Type to which the new TBB will be
--                                   added.
--
-- Description:    Overloading the main procedure. This one will accept the old
--                 TBB PL/SQL table (passed in), convert it to the new TYPE
--                 call the create_bb procedure that accepts the new TYPE
--                 and then convert it back to the old PL/SQL table.
-----------------------------------------------------------------------------
   PROCEDURE create_bb (
      p_time_building_block_id      IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_type                        IN              hxc_time_building_blocks.TYPE%TYPE,
      p_measure                     IN              hxc_time_building_blocks.measure%TYPE,
      p_unit_of_measure             IN              hxc_time_building_blocks.unit_of_measure%TYPE,
      p_start_time                  IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                   IN              hxc_time_building_blocks.stop_time%TYPE,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE,
      p_parent_is_new               IN              VARCHAR2,
      p_scope                       IN              hxc_time_building_blocks.SCOPE%TYPE,
      p_object_version_number       IN              hxc_time_building_blocks.object_version_number%TYPE,
      p_approval_status             IN              hxc_time_building_blocks.approval_status%TYPE,
      p_resource_id                 IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type               IN              hxc_time_building_blocks.resource_type%TYPE,
      p_approval_style_id           IN              hxc_time_building_blocks.approval_style_id%TYPE,
      p_date_from                   IN              hxc_time_building_blocks.date_from%TYPE,
      p_date_to                     IN              hxc_time_building_blocks.date_to%TYPE,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE,
      p_new                         IN              VARCHAR2,
      p_changed                     IN              VARCHAR2,
      p_app_blocks                  IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_bb (Overload)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks :=
         hxc_timestore_deposit_util.convert_tbb_to_type
                                                     (p_blocks      => p_app_blocks);
      create_bb (p_time_building_block_id         => p_time_building_block_id,
                 p_type                           => p_type,
                 p_measure                        => p_measure,
                 p_unit_of_measure                => p_unit_of_measure,
                 p_start_time                     => p_start_time,
                 p_stop_time                      => p_stop_time,
                 p_parent_building_block_id       => p_parent_building_block_id,
                 p_parent_is_new                  => p_parent_is_new,
                 p_scope                          => p_scope,
                 p_object_version_number          => p_object_version_number,
                 p_approval_status                => p_approval_status,
                 p_resource_id                    => p_resource_id,
                 p_resource_type                  => p_resource_type,
                 p_approval_style_id              => p_approval_style_id,
                 p_date_from                      => p_date_from,
                 p_date_to                        => p_date_to,
                 p_comment_text                   => p_comment_text,
                 p_parent_building_block_ovn      => p_parent_building_block_ovn,
                 p_new                            => p_new,
                 p_changed                        => p_changed,
                 p_app_blocks                     => l_blocks
                );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END create_bb;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_timecard_bb
-- IN Parameters:  p_start_time -> The first day of the TIMECARD
--                 p_stop_time -> The last day of the TIMECARD
--                 p_approval_status -> 'WORKING' or 'SUBMITTED', you can leave
--                                      this parameter blank and it will work it
--                                      out automatically, based on the mode used
--                                      when depositing the TC
--                 p_resource_id -> Person Id to which the TBB needs to be attached
--                 p_resource_type -> 'PERSON'
--                 p_approval_style_id -> The Id of the approval style used
--                                        to approve the TBB
--                 p_comment_text -> comment to be saved with TBB
-- INOUT Parameters: p_app_blocks -> TBB Type table to which the new TBB will be
--                                   added
-- OUT Parameters: p_time building_block_id -> TBB id of the just created TBB
--
-- Description:    This procedure will allow you to add a TBB of type TIMECARD
--                 the TBB Type table (passed in).    The BB will be added
--                 to the same TC as all the other BB already in the table
--                 If you want to add BBs to another table, please clear it
--                 first and start afresh
--
-----------------------------------------------------------------------------
   PROCEDURE create_timecard_bb (
      p_start_time               IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                IN              hxc_time_building_blocks.stop_time%TYPE,
      -- We will set this automatic, depending on the mode used when depositing the TC
      -- p_approval_status            IN       hxc_time_building_blocks.approval_status%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      -- default to person because there is no other resource type at the moment.
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE,
      -- We cannot use approval_style_name because that is not unique.
      -- if NULL we will get it of the preferences
      p_approval_style_id        IN              hxc_time_building_blocks.approval_style_id%TYPE,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE,
      p_app_blocks               IN OUT NOCOPY   hxc_block_table_type,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc                   VARCHAR2 (72);
      l_count_building_block   PLS_INTEGER;
      -- l_tc_days                PLS_INTEGER;
      l_day_bb_id              hxc_time_building_blocks.time_building_block_id%TYPE;
   -- l_building_block_index   PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_timecard_bb';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- We are starting with a new timecard so clear the global tables
      hxc_self_service_time_deposit.initialize_globals;
      -- Also clear the local PL/SQL table
      hxc_timestore_deposit_util.clear_building_block_table
                                                 (p_app_blocks      => p_app_blocks);
      l_count_building_block := p_app_blocks.LAST;

      -- 'generate' a TBB ID
      IF (l_count_building_block IS NULL)
      THEN
         p_time_building_block_id := -2;
      -- never start at -1 because that has a special meaning in the deposit
      ELSE
         p_time_building_block_id := - (l_count_building_block) - 2;
      END IF;

      create_bb (p_time_building_block_id        => p_time_building_block_id,
                 p_type                          => hxc_timecard.c_range_type,
                 -- p_measure                     => DEFAULTS TO NULL,
                 p_unit_of_measure               => NULL,
                 p_start_time                    => p_start_time,
                 p_stop_time                     => p_stop_time,
                 p_parent_building_block_id      => NULL,
                 -- Timecard does not have a parent
                 p_parent_is_new                 => NULL,
                 p_scope                         => hxc_timecard.c_timecard_scope,
                 -- p_object_version_number       => DEFAULTS TO 1,
                 -- p_approval_status=> p_approval_status
                 p_resource_id                   => p_resource_id,
                 p_resource_type                 => p_resource_type,
                 p_approval_style_id             => p_approval_style_id,
                 -- p_date_from                   => DEFAULTS TO SYSDATE,
                 -- p_date_to                     => DEFAULTS TO hr_general.end_of_time,
                 p_comment_text                  => p_comment_text,
                 -- p_parent_building_block_ovn   => DEFAULTS TO NULL,
                 -- new                           => DEFAULTS TO 'Y',
                 -- changed                       => DEFAULTS TO 'N',
                 p_app_blocks                    => p_app_blocks
                );

      -- We can automatically insert the DAY TBBs if we want
      -- but that would make it difficult for the user to add DETAIL TBBs
      -- because they would not have a handle to the DAY TBBs, therefore this is
      -- commented out for now until we find a mechanism to return the handles
      -- in a userfriendly way
      /*************************************************
      -- calculate the number of days in the timecard
      l_tc_days :=   TRUNC (p_stop_time)
                   - TRUNC (p_start_time);

      FOR i IN 0 .. l_tc_days
      LOOP
         create_day_bb (
            p_day =>   p_start_time
                     + i,
            p_parent_building_block_id=> p_app_blocks (1).time_building_block_id,
            -- p_comment_text                => DEFAULTS TO NULL,
            -- p_parent_building_block_ovn   => DEFAULTS TO 1,
            p_app_blocks=> p_app_blocks,
            p_time_building_block_id=> l_day_bb_id
         );
      END LOOP;
      *************************************************/
      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_timecard_bb;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_timecard_bb
-- IN Parameters:  See original procedure
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL to which the new TBB will be
--                                   added
-- OUT Parameters: See original procedure
--
-- Description:    Overloading the main procedure. This one will accept the old
--                 TBB PL/SQL table (passed in), convert it to the new TYPE
--                 call the overloaded create_timecard_bb procedure that accepts
--                 the new TYPE and then convert it back to the old PL/SQL table.
--
-----------------------------------------------------------------------------
   PROCEDURE create_timecard_bb (
      p_start_time               IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                IN              hxc_time_building_blocks.stop_time%TYPE,
      -- We will set this automatic, depending on the mode used when depositing the TC
      -- p_approval_status            IN       hxc_time_building_blocks.approval_status%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      -- default to person because there is no other resource type at the moment.
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE,
      -- We cannot use approval_style_name because that is not unique.
      -- if NULL we will get it of the preferences
      p_approval_style_id        IN              hxc_time_building_blocks.approval_style_id%TYPE,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE,
      p_app_blocks               IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_timecard_bb (Overloaded)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks :=
         hxc_timestore_deposit_util.convert_tbb_to_type
                                                     (p_blocks      => p_app_blocks);
      -- Call overloaded procedure
      create_timecard_bb (p_start_time                  => p_start_time,
                          p_stop_time                   => p_stop_time,
                          p_resource_id                 => p_resource_id,
                          p_resource_type               => p_resource_type,
                          p_approval_style_id           => p_approval_style_id,
                          p_comment_text                => p_comment_text,
                          p_app_blocks                  => l_blocks,
                          p_time_building_block_id      => p_time_building_block_id
                         );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_timecard_bb;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_day_bb
-- IN Parameters:  p_day -> Day for which you want to create the DAY TBB
--                 p_resource_id -> Person Id to which the TBB needs to be attached
--                 p_resource_type -> 'PERSON'
--                 p_comment_text -> comment to be saved with TBB
--                 p_deposit_process -> Name of the deposit process which we will
--                                      use the mapping of
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL to which the new TBB will be
--                                   added
-- OUT Parameters: p_time building_block_id -> TBB id of the just created TBB
--
-- Description:    This procedure will allow you to add a TBB of type DAY
--                 the TBB PL/SQL table (passed in).  This instance of the procedure
--                 does not need a parent (TIMECARD) TBB, the parent will be worked
--                 out automatically based on the day and resource id.
--                 The BB will be added to the same TC as all the other BB already
--                 in the table.  If you want to add BBs to another table, please
--                 clear it first and start afresh.
--
-----------------------------------------------------------------------------
   PROCEDURE create_day_bb (
      p_day                      IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks               IN OUT NOCOPY   hxc_block_table_type,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc                         VARCHAR2 (72);
      l_timecard_building_block_id   hxc_time_building_blocks.parent_building_block_id%TYPE;
      l_timecard_ovn                 hxc_time_building_blocks.parent_building_block_ovn%TYPE;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_day_bb (overload)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- First find the TIMECARD TBB to which this DAY TBB belongs
      hxc_timestore_deposit_util.find_parent_building_block
                            (p_start_time          => p_day,
                             p_resource_id         => p_resource_id,
                             p_resource_type       => p_resource_type,
                             p_scope               => hxc_timecard.c_timecard_scope,
                             p_app_blocks          => p_app_blocks,
                             p_timecard_bb_id      => l_timecard_building_block_id,
                             p_timecard_ovn        => l_timecard_ovn
                            );
      -- Now call the overloaded procedure
      create_day_bb
                  (p_day                            => p_day,
                   p_parent_building_block_id       => l_timecard_building_block_id,
                   p_comment_text                   => p_comment_text,
                   p_parent_building_block_ovn      => l_timecard_ovn,
                   p_deposit_process                => p_deposit_process,
                   p_app_blocks                     => p_app_blocks,
                   p_time_building_block_id         => p_time_building_block_id
                  );

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_day_bb;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_day_bb
-- IN Parameters:  See overloaded Procedure
-- INOUT Parameters: p_app_blocks -> TBB Type to which the new TBB will be
--                                   added
-- OUT Parameters: See overloaded Procedure
--
-- Description:    Overloading the main procedure. This one will accept the old
--                 TBB PL/SQL table (passed in), convert it to the new TYPE,
--                 call the overloaded create_timecard_bb procedure that accepts
--                 the new TYPE and then convert it back to the old PL/SQL table.
--
-----------------------------------------------------------------------------
   PROCEDURE create_day_bb (
      p_day                      IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks               IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_day_bb (overload)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks :=
         hxc_timestore_deposit_util.convert_tbb_to_type
                                                     (p_blocks      => p_app_blocks);
      -- Call overloaded procedure
      create_day_bb (p_day                         => p_day,
                     p_resource_id                 => p_resource_id,
                     p_resource_type               => p_resource_type,
                     p_comment_text                => p_comment_text,
                     p_deposit_process             => p_deposit_process,
                     p_app_blocks                  => l_blocks,
                     p_time_building_block_id      => p_time_building_block_id
                    );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_day_bb;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_day_bb
-- IN Parameters:  p_day -> Day for which you want to create the DAY TBB
--                 p_parent_building_block_id -> Id of the TBB to which this TBB
--                                               needs to be attached, should be
--                                               set to a TIMECARD TBB id as a
--                                               DAY TBB needs to be attached to
--                                               TIMECARD TBB.
--                 p_comment_text -> comment to be saved with TBB
--                 p_parent_building_block_ovn -> ovn of the parent TBB, should
--                                                always be the highest ovn
--                                                as we do not allow attaching
--                                                TBBs to old TBBs
--                 p_deposit_process -> Name of the deposit process which we will
--                                      use the mapping of
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL to which the new TBB will be
--                                   added
-- OUT Parameters: p_time building_block_id -> TBB id of the just created TBB
--
-- Description:    This procedure will allow you to add a TBB of type TIMECARD
--                 the TBB PL/SQL table (passed in).  This instance of the procedure
--                 needs a parent (TIMECARD) TBB so you have to know what it is.
--                 The BB will be added to the same TC as all the other BB already
--                 in the table.  If you want to add BBs to another table, please
--                 clear it first and start afresh.
--
-----------------------------------------------------------------------------
   PROCEDURE create_day_bb (
      p_day                         IN              hxc_time_building_blocks.start_time%TYPE,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE,
      p_deposit_process             IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks                  IN OUT NOCOPY   hxc_block_table_type,
      p_time_building_block_id      OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc                          VARCHAR2 (72);
      l_count_building_block          PLS_INTEGER;
      -- l_building_block_index          PLS_INTEGER;
      l_parent_building_block_index   PLS_INTEGER;
      l_parent_is_new                 VARCHAR2 (1);
      -- l_timecard_building_block_id    hxc_time_building_blocks.parent_building_block_id%TYPE;
      -- l_timecard_ovn                  hxc_time_building_blocks.parent_building_block_ovn%TYPE;
      l_app_attributes                hxc_self_service_time_deposit.app_attributes_info;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_day_bb';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- check if a timecard is already present in PL/SQL tables
      IF (p_app_blocks.COUNT = 0)
      THEN       -- No Timecard is loaded yet, lets load it form the TimeStore
         -- First clear the global tables so no garbage gets loaded with the
         -- updated TC
         hxc_self_service_time_deposit.initialize_globals;
         -- then get the TC and attributes out of the DB into the PL/SQL Tables
         hxc_timestore_deposit_util.get_timecard_tables
                          (p_building_block_id      => p_parent_building_block_id,
                           p_deposit_process        => p_deposit_process,
                           p_app_blocks             => p_app_blocks,
                           p_app_attributes         => l_app_attributes
                          -- not needed in this procedure
                          );
      END IF;

      l_count_building_block := p_app_blocks.LAST;

      -- 'generate' a TBB ID
      IF (l_count_building_block IS NULL)
      THEN
         p_time_building_block_id := -2;
      -- never start at -1 because that has a special meaning in the deposit
      ELSE
         p_time_building_block_id := - (l_count_building_block) - 2;
      END IF;

      -- lets find the parent of this BB, we will use this to set some attributes = parents attributes
      l_parent_building_block_index :=
         hxc_timestore_deposit_util.get_index_in_bb_table
                                (p_bb_table           => p_app_blocks,
                                 p_bb_id_to_find      => p_parent_building_block_id
                                );

      -- set the parent_is_new flag for the new BB
      -- if the parent BB id is negative (less than -1), it was just created and is therefore
      -- not present in the db yet, so parent is new
      IF (p_parent_building_block_id < -1)
      THEN
         l_parent_is_new := hxc_timecard.c_yes;
      ELSIF (p_parent_building_block_id = -1)
      THEN           -- We did not find the parent present in the table, ERROR
         NULL;
      ELSE        -- The parent BB was retrieved from the DB, so it is not new
         l_parent_is_new := hxc_timecard.c_no;
      END IF;

      create_bb
         (p_time_building_block_id         => p_time_building_block_id,
          p_type                           => hxc_timecard.c_range_type,
          -- p_measure                     => DEFAULTS TO NULL,
          p_unit_of_measure                => NULL,
          p_start_time                     => TO_DATE
                                                    (   TO_CHAR (p_day,
                                                                 'DD-MON-YYYY'
                                                                )
                                                     || ' 00:00:00',
                                                     'DD-MON-YYYY HH24:MI:SS'
                                                    ),
          p_stop_time                      => TO_DATE
                                                    (   TO_CHAR (p_day,
                                                                 'DD-MON-YYYY'
                                                                )
                                                     || ' 23:59:59',
                                                     'DD-MON-YYYY HH24:MI:SS'
                                                    ),
          p_parent_building_block_id       => p_parent_building_block_id,
          p_parent_is_new                  => l_parent_is_new,
          p_scope                          => hxc_timecard.c_day_scope,
          -- p_object_version_number       => DEFAULTS TO 1,
          -- set the next 4 fields to the parents equivalant, we do not want the users to set these manually for now.
          -- This can be changed later.  This is not a functional requirement, it just makes the API interface easier
          p_approval_status                => p_app_blocks
                                                 (l_parent_building_block_index
                                                 ).approval_status,
          p_resource_id                    => p_app_blocks
                                                 (l_parent_building_block_index
                                                 ).resource_id,
          p_resource_type                  => p_app_blocks
                                                 (l_parent_building_block_index
                                                 ).resource_type,
          p_approval_style_id              => p_app_blocks
                                                 (l_parent_building_block_index
                                                 ).approval_style_id,
          -- p_date_from                   => DEFAULTS TO SYSDATE,
          -- p_date_to                     => DEFAULTS TO hr_general.end_of_time,
          p_comment_text                   => p_comment_text,
          p_parent_building_block_ovn      => p_parent_building_block_ovn,
          -- new                           => DEFAULTS TO 'Y',
          -- changed                       => DEFAULTS TO 'N',
          p_app_blocks                     => p_app_blocks
         );

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_day_bb;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_day_bb
-- IN Parameters:  See overloaded Procedure
-- INOUT Parameters: p_app_blocks -> TBB Type to which the new TBB will be
--                                   added
-- OUT Parameters: See overloaded Procedure
--
-- Description:    Overloading the main procedure. This one will accept the old
--                 TBB PL/SQL table (passed in), convert it to the new TYPE,
--                 call the overloaded create_timecard_bb procedure that accepts
--                 the new TYPE and then convert it back to the old PL/SQL table.
--
-----------------------------------------------------------------------------
   PROCEDURE create_day_bb (
      p_day                         IN              hxc_time_building_blocks.start_time%TYPE,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE,
      p_deposit_process             IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks                  IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_time_building_block_id      OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_day_bb (overload)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks :=
         hxc_timestore_deposit_util.convert_tbb_to_type
                                                     (p_blocks      => p_app_blocks);
      -- Call overloaded procedure
      create_day_bb
                  (p_day                            => p_day,
                   p_parent_building_block_id       => p_parent_building_block_id,
                   p_comment_text                   => p_comment_text,
                   p_parent_building_block_ovn      => p_parent_building_block_ovn,
                   p_deposit_process                => p_deposit_process,
                   p_app_blocks                     => l_blocks,
                   p_time_building_block_id         => p_time_building_block_id
                  );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_day_bb;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Private
-- Name:           auto_create_timecard
-- IN Parameters:  p_resource_id -> Person for which the timecard needs to be created
--                 p_resource_type -> 'PERSON'
--                 p_day -> Day for which you want to create the timecard
--                 p_deposit_process -> Name of the deposit process which we will
--                                      use the mapping off.
-- INOUT Parameters: p_app_blocks -> TBB Type to which the new TBB will be
--                                   added (and contain complete timecard)
--                   p_app_attributes -> Attribute PL/SQL to which the new attribure
--                                       will be added
-- OUT Parameters: p_time building_block_id -> TBB id of the DAY TBB (identified
--                                             by p_day) just created.
--
-- Description:    This procedure can be used to create a timecard completely
--                 automatically.  Based on the day and resource information passed
--                 in, it works out the preferences for this resource and creates
--                 the timecard.  The period for the timecard is read from the
--                 preferences.  Then a DAY TBB is created for every day in the
--                 timecard period.  The TBB id passed back, is the Id of the DAY
--                 TBB, with a start date = the day passed in.
--
-----------------------------------------------------------------------------
   PROCEDURE auto_create_timecard (
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE,
      p_day                      IN              hxc_time_building_blocks.start_time%TYPE,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks               IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes           IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc                         VARCHAR2 (72);
      l_timecard_building_block_id   hxc_time_building_blocks.time_building_block_id%TYPE;
      l_day_bb_id                    hxc_time_building_blocks.time_building_block_id%TYPE;
      l_period_start                 DATE;
      l_period_end                   DATE;
      l_tc_days                      PLS_INTEGER;
      l_start_time                   hxc_time_building_blocks.start_time%TYPE;
      l_stop_time                    hxc_time_building_blocks.stop_time%TYPE;
   BEGIN
      IF g_debug
      THEN
         l_proc := g_package || 'auto_create_timecard';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- clear tables
      hxc_timestore_deposit_util.clear_building_block_table
                                                 (p_app_blocks      => p_app_blocks);
      hxc_timestore_deposit_util.clear_attribute_table
                                         (p_app_attributes      => p_app_attributes);
      hxc_timestore_deposit_util.find_current_period
                                              (p_resource_id        => p_resource_id,
                                               p_resource_type      => 'PERSON',
                                               p_day                => p_day,
                                               p_start_time         => l_start_time,
                                               p_stop_time          => l_stop_time
                                              );
      create_timecard_bb
                     (p_start_time                  => l_start_time,
                      p_stop_time                   => l_stop_time,
                      p_resource_id                 => p_resource_id,
                      p_resource_type               => p_resource_type,
                      p_app_blocks                  => p_app_blocks,
                      p_time_building_block_id      => l_timecard_building_block_id
                     );
      -- And its associated DAY TBBs, one for every day of the TIMECARD period
      -- calculate the number of days in the timecard
      l_tc_days := TRUNC (l_stop_time) - TRUNC (l_start_time);

      IF g_debug
      THEN
         hr_utility.set_location (   '   We will need to create '
                                  || TO_CHAR (l_tc_days + 1)
                                  || ' DAY TBBs',
                                  30
                                 );
      END IF;

      FOR i IN 0 .. l_tc_days
      LOOP
         create_day_bb
                 (p_day                           => l_start_time + i,
                  p_parent_building_block_id      => l_timecard_building_block_id,
                  p_deposit_process               => p_deposit_process,
                  p_app_blocks                    => p_app_blocks,
                  p_time_building_block_id        => l_day_bb_id
                 );

         -- Return the TBB_ID of the TBB to which we need to attache the DETAIL TBB
         -- That initiated this procedure
         IF ((TRUNC (l_start_time) + i) = TRUNC (p_day))
         THEN
            p_time_building_block_id := l_day_bb_id;
         END IF;
      END LOOP;

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END auto_create_timecard;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_detail_bb
-- IN Parameters:  p_type -> 'MEASURE' or 'RANGE'
--                 p_measure -> The actual time recorded, e.g. 8 Only provide
--                              when type is MEASURE
--                 p_start_time -> The IN time Only provide when type is RANGE
--                 p_stop_time -> The OUT time Only provide when type is RANGE
--                 p_parent_building_block_id -> Id of the TBB to which this TBB
--                                               needs to be attached, should be
--                                               set to a DAY TBB id as a DETAIL
--                                               TBB needs to be attached to
--                                               DAY TBB.
--                 p_comment_text -> comment to be saved with TBB
--                 p_parent_building_block_ovn -> ovn of the parent TBB, should
--                                                always be the highest ovn
--                                                as we do not allow attaching
--                                                TBBs to old TBBs
--                 p_deposit_process -> Name of the deposit process which we will
--                                      use the mapping of
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL to which the new TBB will be
--                                   added
--                   p_app_attributes -> Attribute PL/SQL to which the new attribure
--                                       will be added
-- OUT Parameters: p_time building_block_id -> TBB id of the just created TBB
--
-- Description:    This procedure will allow you to add a TBB of type DAY
--                 the TBB PL/SQL table (passed in).  This instance of the procedure
--                 needs a parent (DAY) TBB so you have to know what it is.
--                 The BB will be added to the same TC as all the other BB already
--                 in the table.  If you want to add BBs to another table, please
--                 clear it first and start afresh.
--
-----------------------------------------------------------------------------
   PROCEDURE create_detail_bb (
      p_type                        IN              hxc_time_building_blocks.TYPE%TYPE,
      p_measure                     IN              hxc_time_building_blocks.measure%TYPE,
      p_start_time                  IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                   IN              hxc_time_building_blocks.stop_time%TYPE,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE,
      -- For now, these need to be the same as the parent BB (the TIMECARD BB).  We set this in the code,
      -- the user cannot manipulate this.
      -- p_approval_status            IN       hxc_time_building_blocks.approval_status%TYPE,
      -- p_resource_id                IN       hxc_time_building_blocks.resource_id%TYPE,
      -- p_resource_type              IN       hxc_time_building_blocks.resource_type%TYPE,
      -- p_approval_style_id          IN       hxc_time_building_blocks.approval_style_id%TYPE,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE,
      p_deposit_process             IN              hxc_deposit_processes.NAME%TYPE,
      p_unit_of_measure             IN              hxc_time_building_blocks.unit_of_measure%TYPE,
      p_app_blocks                  IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes              IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id      OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc                          VARCHAR2 (72);
      l_count_building_block          PLS_INTEGER;
      l_parent_building_block_index   PLS_INTEGER;
      l_parent_is_new                 VARCHAR2 (1);
      l_unit_of_measure               hxc_time_building_blocks.unit_of_measure%TYPE;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_detail_bb';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- check if a timecard is already present in PL/SQL tables
      IF (p_app_blocks.COUNT = 0)
      THEN       -- No Timecard is loaded yet, lets load it form the TimeStore
         -- First clear the global tables so no garbage gets loaded with the
         -- updated TC
         hxc_self_service_time_deposit.initialize_globals;
         -- then get the TC and attributes out of the DB into the PL/SQL Tables
         hxc_timestore_deposit_util.get_timecard_tables
                          (p_building_block_id      => p_parent_building_block_id,
                           p_deposit_process        => p_deposit_process,
                           p_app_blocks             => p_app_blocks,
                           p_app_attributes         => p_app_attributes
                          );
      END IF;

      l_count_building_block := p_app_blocks.LAST;

      -- 'generate' a TBB ID
      IF (l_count_building_block IS NULL)
      THEN
         p_time_building_block_id := -2;
      -- never start at -1 because that has a special meaning in the deposit
      ELSE
         p_time_building_block_id := - (l_count_building_block) - 2;
      END IF;

      -- set the parent_is_new flag for the new BB
      -- if the parent BB id is negative, it was just created and is therefore not present in the db yet
      -- so parent is new
      IF (p_parent_building_block_id < 0)
      THEN
         l_parent_is_new := hxc_timecard.c_yes;
      ELSE        -- The parent BB was retrieved from the DB, so it is not new
         l_parent_is_new := hxc_timecard.c_no;
      END IF;

      -- If the user does not provide a UOM, we assume he wants to use HOURS
      -- This is a pretty save assumption as it is the only UOM we support at
      -- the moment. Should we start supporting more UOMs in the future, we need
      -- to rewrite this.
      IF (p_unit_of_measure IS NULL)
      THEN
         IF (p_measure IS NULL)
         THEN
            l_unit_of_measure := NULL;
         ELSE
            l_unit_of_measure := c_hours_uom;
         END IF;
      ELSE                                              -- user knows best ...
         l_unit_of_measure := p_unit_of_measure;
      END IF;

      -- lets find the parent of this BB, we will use this to set some attributes = parents attributes
      l_parent_building_block_index :=
         hxc_timestore_deposit_util.get_index_in_bb_table
                                (p_bb_table           => p_app_blocks,
                                 p_bb_id_to_find      => p_parent_building_block_id
                                );
      create_bb
         (p_time_building_block_id         => p_time_building_block_id,
          p_type                           => p_type,
          p_measure                        => p_measure,
          p_unit_of_measure                => l_unit_of_measure,
          p_start_time                     => p_start_time,
          p_stop_time                      => p_stop_time,
          p_parent_building_block_id       => p_parent_building_block_id,
          p_parent_is_new                  => l_parent_is_new,
          p_scope                          => hxc_timecard.c_detail_scope,
          -- p_object_version_number       => DEFAULTS TO 1,
          -- set the next 4 fields to the parents equivalant, we do not want the users to set these manually for now.
          -- This can be changed later.  This is not a functional requirement, it just makes the API interface easier
          p_approval_status                => p_app_blocks
                                                 (l_parent_building_block_index
                                                 ).approval_status,
          p_resource_id                    => p_app_blocks
                                                 (l_parent_building_block_index
                                                 ).resource_id,
          p_resource_type                  => p_app_blocks
                                                 (l_parent_building_block_index
                                                 ).resource_type,
          p_approval_style_id              => p_app_blocks
                                                 (l_parent_building_block_index
                                                 ).approval_style_id,
          -- p_date_from                   => DEFAULTS TO SYSDATE,
          -- p_date_to                     => DEFAULTS TO hr_general.end_of_time,
          p_comment_text                   => p_comment_text,
          p_parent_building_block_ovn      => p_parent_building_block_ovn,
          -- new                           => DEFAULTS TO 'Y',
          -- changed                       => DEFAULTS TO 'N',
          p_app_blocks                     => p_app_blocks
         );

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_detail_bb;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_detail_bb
-- IN Parameters:  See Overloaded procedure
-- INOUT Parameters: p_app_blocks -> TBB Type to which the new TBB will be
--                                   added
--                   p_app_attributes -> Attribute PL/SQL to which the new attribure
--                                       will be added
-- OUT Parameters: See Overloaded procedure
--
-- Description:    Overloading the main procedure. This one will accept the old
--                 TBB PL/SQL table (passed in), convert it to the new TYPE,
--                 call the overloaded create_timecard_bb procedure that accepts
--                 the new TYPE and then convert it back to the old PL/SQL table.
--
-----------------------------------------------------------------------------
   PROCEDURE create_detail_bb (
      p_type                        IN              hxc_time_building_blocks.TYPE%TYPE,
      p_measure                     IN              hxc_time_building_blocks.measure%TYPE,
      p_start_time                  IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                   IN              hxc_time_building_blocks.stop_time%TYPE,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE,
      -- For now, these need to be the same as the parent BB (the TIMECARD BB).  We set this in the code,
      -- the user cannot manipulate this.
      -- p_approval_status            IN       hxc_time_building_blocks.approval_status%TYPE,
      -- p_resource_id                IN       hxc_time_building_blocks.resource_id%TYPE,
      -- p_resource_type              IN       hxc_time_building_blocks.resource_type%TYPE,
      -- p_approval_style_id          IN       hxc_time_building_blocks.approval_style_id%TYPE,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE,
      p_deposit_process             IN              hxc_deposit_processes.NAME%TYPE,
      p_unit_of_measure             IN              hxc_time_building_blocks.unit_of_measure%TYPE,
      p_app_blocks                  IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes              IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id      OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_detail_bb (Overloaded)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks :=
         hxc_timestore_deposit_util.convert_tbb_to_type
                                                     (p_blocks      => p_app_blocks);
      create_detail_bb
                  (p_type                           => p_type,
                   p_measure                        => p_measure,
                   p_unit_of_measure                => p_unit_of_measure,
                   p_start_time                     => p_start_time,
                   p_stop_time                      => p_stop_time,
                   p_parent_building_block_id       => p_parent_building_block_id,
                   -- For now, these need to be the same as the parent BB (the TIMECARD BB).  We set this in the code,
                   -- the user cannot manipulate this.
                   -- p_approval_status    => p_approval_status,
                   -- p_resource_id        => p_resource_id,
                   -- p_resource_type      => p_resource_type,
                   -- p_approval_style_id  => p_approval_style_id,
                   p_comment_text                   => p_comment_text,
                   p_parent_building_block_ovn      => p_parent_building_block_ovn,
                   p_deposit_process                => p_deposit_process,
                   p_app_blocks                     => l_blocks,
                   p_app_attributes                 => p_app_attributes,
                   p_time_building_block_id         => p_time_building_block_id
                  );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_detail_bb;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_time_entry
-- IN Parameters:  p_measure -> The actual time recorded, e.g. 8
--                 p_day -> Day to which you want to link the DETAIL TBB
--                 p_resource_id -> Person for which the timecard needs to be created
--                 p_resource_type -> 'PERSON'
--                 p_comment_text -> comment to be saved with TBB
--                 p_parent_building_block_ovn -> ovn of the parent TBB, should
--                                                always be the highest ovn
--                                                as we do not allow attaching
--                                                TBBs to old TBBs
--                 p_deposit_process -> Name of the deposit process which we will
--                                      use the mapping of
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL to which the new TBB will be
--                                   added
--                   p_app_attributes -> Attribute PL/SQL to which the new attribure
--                                       will be added
-- OUT Parameters: p_time building_block_id -> TBB id of the just created TBB
--
-- Description:    This procedure will allow you to add a TBB of type DAY
--                 the TBB PL/SQL table (passed in).  This instance of the procedure
--                 can be used for creating DAY TBBs for which you have a measure.
--                 The BB will be added to the same TC as all the other BB already
--                 in the table.  If you want to add BBs to another table, please
--                 clear it first and start afresh.
--
-----------------------------------------------------------------------------
   PROCEDURE create_time_entry (
      p_measure                  IN              hxc_time_building_blocks.measure%TYPE,
      p_day                      IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks               IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes           IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc                     VARCHAR2 (72);
      l_time_building_block_id   hxc_time_building_blocks.parent_building_block_id%TYPE;
      l_timecard_ovn             hxc_time_building_blocks.parent_building_block_ovn%TYPE;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_time_entry';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- First find the DAY TBB to which this DETAIL TBB belongs
      hxc_timestore_deposit_util.find_parent_building_block
                                (p_start_time          => p_day,
                                 p_resource_id         => p_resource_id,
                                 p_resource_type       => p_resource_type,
                                 p_scope               => hxc_timecard.c_day_scope,
                                 p_app_blocks          => p_app_blocks,
                                 p_timecard_bb_id      => l_time_building_block_id,
                                 p_timecard_ovn        => l_timecard_ovn
                                );

      IF l_time_building_block_id IS NULL
      THEN                 -- We did not find the timecard so let's create one
         auto_create_timecard
                       (p_resource_id                 => p_resource_id,
                        p_resource_type               => p_resource_type,
                        p_day                         => p_day,
                        p_deposit_process             => p_deposit_process,
                        p_time_building_block_id      => l_time_building_block_id,
                        p_app_blocks                  => p_app_blocks,
                        p_app_attributes              => p_app_attributes
                       );
         l_timecard_ovn := 1;
      END IF;

      -- Now call the actual create procedure
      create_detail_bb
                      (p_type                           => hxc_timecard.c_measure_type,
                       p_measure                        => p_measure,
                       p_unit_of_measure                => c_hours_uom,
                       p_start_time                     => NULL,
                       p_stop_time                      => NULL,
                       p_parent_building_block_id       => l_time_building_block_id,
                       p_comment_text                   => p_comment_text,
                       p_deposit_process                => p_deposit_process,
                       p_parent_building_block_ovn      => l_timecard_ovn,
                       p_app_blocks                     => p_app_blocks,
                       p_app_attributes                 => p_app_attributes,
                       p_time_building_block_id         => p_time_building_block_id
                      );

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_time_entry;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_time_entry
-- IN Parameters:  See Overloaded procedure
-- INOUT Parameters: p_app_blocks -> TBB Type to which the new TBB will be
--                                   added
--                   p_app_attributes -> Attribute PL/SQL to which the new attribure
--                                       will be added
-- OUT Parameters: p_time building_block_id -> TBB id of the just created TBB
--
-- Description:    Overloading the main procedure. This one will accept the old
--                 TBB PL/SQL table (passed in), convert it to the new TYPE,
--                 call the overloaded create_timecard_bb procedure that accepts
--                 the new TYPE and then convert it back to the old PL/SQL table.
--
-----------------------------------------------------------------------------
   PROCEDURE create_time_entry (
      p_measure                  IN              hxc_time_building_blocks.measure%TYPE,
      p_day                      IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks               IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes           IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_time_entry (Overloaded)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks :=
         hxc_timestore_deposit_util.convert_tbb_to_type
                                                     (p_blocks      => p_app_blocks);
      create_time_entry (p_measure                     => p_measure,
                         p_day                         => p_day,
                         p_resource_id                 => p_resource_id,
                         p_resource_type               => p_resource_type,
                         p_comment_text                => p_comment_text,
                         p_deposit_process             => p_deposit_process,
                         p_app_blocks                  => l_blocks,
                         p_app_attributes              => p_app_attributes,
                         p_time_building_block_id      => p_time_building_block_id
                        );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_time_entry;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_time_entry (Overload)
-- IN Parameters:  p_start_time -> The IN time
--                 p_stop_time -> The OUT time
--                 p_resource_id -> Person for which the timecard needs to be created
--                 p_resource_type -> 'PERSON'
--                 p_comment_text -> comment to be saved with TBB
--                 p_parent_building_block_ovn -> ovn of the parent TBB, should
--                                                always be the highest ovn
--                                                as we do not allow attaching
--                                                TBBs to old TBBs
--                 p_deposit_process -> Name of the deposit process which we will
--                                      use the mapping of
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL to which the new TBB will be
--                                   added
--                   p_app_attributes -> Attribute PL/SQL to which the new attribure
--                                       will be added
-- OUT Parameters: p_time building_block_id -> TBB id of the just created TBB
--
-- Description:    This procedure will allow you to add a TBB of type DAY
--                 the TBB PL/SQL table (passed in).  This instance of the procedure
--                 can be used for creating DAY TBBs for which you have a range,
--                 so you provide a start (IN) and stop (OUT) time.
--                 The BB will be added to the same TC as all the other BB already
--                 in the table.  If you want to add BBs to another table, please
--                 clear it first and start afresh.
--
-----------------------------------------------------------------------------
   PROCEDURE create_time_entry (
      p_start_time               IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks               IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes           IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc                     VARCHAR2 (72);
      l_time_building_block_id   hxc_time_building_blocks.parent_building_block_id%TYPE;
      l_timecard_ovn             hxc_time_building_blocks.parent_building_block_ovn%TYPE;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_time_entry (overloaded range)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- First find the DAY TBB to which this DETAIL TBB belongs
      hxc_timestore_deposit_util.find_parent_building_block
                                (p_start_time          => p_start_time,
                                 p_resource_id         => p_resource_id,
                                 p_resource_type       => p_resource_type,
                                 p_scope               => hxc_timecard.c_day_scope,
                                 p_app_blocks          => p_app_blocks,
                                 p_timecard_bb_id      => l_time_building_block_id,
                                 p_timecard_ovn        => l_timecard_ovn
                                );

      IF l_time_building_block_id IS NULL
      THEN                 -- We did not find the timecard so let's create one
         auto_create_timecard
                       (p_resource_id                 => p_resource_id,
                        p_resource_type               => p_resource_type,
                        p_day                         => p_start_time,
                        p_deposit_process             => p_deposit_process,
                        p_time_building_block_id      => l_time_building_block_id,
                        p_app_blocks                  => p_app_blocks,
                        p_app_attributes              => p_app_attributes
                       );
         l_timecard_ovn := 1;
      END IF;

      -- Now call the actual create procedure
      create_detail_bb
                      (p_type                           => hxc_timecard.c_range_type,
                       p_measure                        => NULL,
                       p_unit_of_measure                => NULL,
                       p_start_time                     => p_start_time,
                       p_stop_time                      => p_stop_time,
                       p_parent_building_block_id       => l_time_building_block_id,
                       p_comment_text                   => p_comment_text,
                       p_deposit_process                => p_deposit_process,
                       p_parent_building_block_ovn      => l_timecard_ovn,
                       p_app_blocks                     => p_app_blocks,
                       p_app_attributes                 => p_app_attributes,
                       p_time_building_block_id         => p_time_building_block_id
                      );

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_time_entry;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_time_entry
-- IN Parameters:  See Overloaded procedure
-- INOUT Parameters: p_app_blocks -> TBB Type to which the new TBB will be
--                                   added
--                   p_app_attributes -> Attribute PL/SQL to which the new attribure
--                                       will be added
-- OUT Parameters: p_time building_block_id -> TBB id of the just created TBB
--
-- Description:    Overloading the main procedure. This one will accept the old
--                 TBB PL/SQL table (passed in), convert it to the new TYPE,
--                 call the overloaded create_timecard_bb procedure that accepts
--                 the new TYPE and then convert it back to the old PL/SQL table.
--
-----------------------------------------------------------------------------
   PROCEDURE create_time_entry (
      p_start_time               IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks               IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes           IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_time_entry (Overloaded)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks :=
         hxc_timestore_deposit_util.convert_tbb_to_type
                                                     (p_blocks      => p_app_blocks);
      create_time_entry (p_start_time                  => p_start_time,
                         p_stop_time                   => p_stop_time,
                         p_resource_id                 => p_resource_id,
                         p_resource_type               => p_resource_type,
                         p_comment_text                => p_comment_text,
                         p_deposit_process             => p_deposit_process,
                         p_app_blocks                  => l_blocks,
                         p_app_attributes              => p_app_attributes,
                         p_time_building_block_id      => p_time_building_block_id
                        );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);

      IF g_debug
      THEN
         hr_utility.set_location (   'Leaving:'
                                  || l_proc
                                  || ' p_time_building_block_id = '
                                  || p_time_building_block_id,
                                  100
                                 );
      END IF;
   END create_time_entry;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           create_attribute
-- IN Parameters:  p_building_block_id -> TBB Id to which you want to attach the
--                                        attribute
--                 p_attribute_name -> Name of the attribute
--                 p_attribute_value -> Value you want to store in the attribute
--                 p_deposit_process -> Name of the deposit process which we will
--                                      use the mapping of
--                 p_attribute_id -> Used to group attributes, use default (NULL)
--                                   if you only have one type of attribute/TBB
-- INOUT Parameters: p_app_attributes -> Attribute PL/SQL to which the new attribure
--                                       will be added
--
-- Description:    This procedure will allow you to add an attribute to the
--                 attributre PL/SQL table (passed in).
--                 The attribute will be added to the same TC as all the other
--                 attribute already in the table.  If you want to add attributes
--                 to another timecard, please clear it first and start afresh.
--
--                 In this procedure we now assume that only 1 attribute of the
--                 same building block info type can be attached to a TBB.  E.g.
--                 you cannot add 2 PROJECT attributes to one and the same TBB
--                 We need to make this assumption so we can group the attributes
--                 by building block info type.  If the user really wants to have
--                 multiple attributes of the same building block info type attached
--                 to one TBB, he will have to do the grouping manually by using
--                 the p_attribute_id parameter.  For every attribute field that
--                 belongs to the same group, this needs to be the same id.
--
-----------------------------------------------------------------------------
   PROCEDURE create_attribute (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_attribute_name      IN              hxc_mapping_components.field_name%TYPE,
      p_attribute_value     IN              hxc_time_attributes.attribute1%TYPE,
      -- p_category            IN       hxc_bld_blk_info_type_usages.building_block_category%TYPE,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_attribute_id        IN              hxc_time_attributes.time_attribute_id%TYPE,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_proc                VARCHAR2 (72);
      l_attribute_count     PLS_INTEGER;
      l_bld_blk_info_type   hxc_bld_blk_info_types.bld_blk_info_type%TYPE;
      l_attribute_id        hxc_time_attributes.time_attribute_id%TYPE
                                                                      := NULL;
      l_segment             hxc_mapping_components.SEGMENT%TYPE;
      attr_index            PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'create_attribute';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      hxc_timestore_deposit_util.get_bld_blk_info_type
                                  (p_attribute_name         => p_attribute_name,
                                   p_deposit_process        => p_deposit_process,
                                   p_bld_blk_info_type      => l_bld_blk_info_type,
                                   p_segment                => l_segment
                                  );

      -- We need to group the attributes per TBB and per bld_blk_info_type
      -- We use the attribute_id to do this, all attributes that belong to the
      -- same TBB and have the same bld_blk_info_type, will get the same
      -- attribute_id.  There can be only 1 type/TBB for this to work.  If the
      -- user wants more of the same type per TBB than he will have to group those
      -- attributes manually, this is done using the p_attribute_id parameter of
      -- this procedure.  In that case we do not perform the automatic assignment
      IF (p_attribute_id IS NULL)
      THEN
         -- see if you can find an existing TBB/bld_blk_info_type combination
         -- already present in the p_app_attributes table.
         attr_index := p_app_attributes.FIRST;

         <<find_attribute_id>>
         LOOP
            EXIT find_attribute_id WHEN (   NOT p_app_attributes.EXISTS
                                                                   (attr_index)
                                         OR l_attribute_id IS NOT NULL
                                        );

            IF (    (p_app_attributes (attr_index).bld_blk_info_type =
                                                           l_bld_blk_info_type
                    )
                AND (p_app_attributes (attr_index).building_block_id =
                                                           p_building_block_id
                    )
                AND (p_app_attributes (attr_index).attribute_index IS NULL)
               )
            THEN           -- Found existing bld_blk_info_type/TBB combination
               -- Use the same attribute_id from the existing attribute for
               -- our new attribute
               l_attribute_id :=
                              p_app_attributes (attr_index).time_attribute_id;
            END IF;

            attr_index := p_app_attributes.NEXT (attr_index);
         END LOOP find_attribute_id;

         IF (l_attribute_id IS NULL)
         THEN
            -- We never found an existing combination, so this must be the first
            -- one, lets generate a new, unique id for it
            l_attribute_id := p_app_attributes.COUNT;
         END IF;
      ELSE                                       -- p_attribute_id is not null
         -- user knows best!
         l_attribute_id := p_attribute_id;
      END IF;

      l_attribute_count := NVL (p_app_attributes.LAST, 0) + 1;
      p_app_attributes (l_attribute_count).time_attribute_id := l_attribute_id;
      p_app_attributes (l_attribute_count).building_block_id :=
                                                           p_building_block_id;
      p_app_attributes (l_attribute_count).attribute_name := p_attribute_name;
      p_app_attributes (l_attribute_count).attribute_value :=
                                                             p_attribute_value;
      p_app_attributes (l_attribute_count).bld_blk_info_type :=
                                                           l_bld_blk_info_type;
      p_app_attributes (l_attribute_count).CATEGORY := l_bld_blk_info_type;
      p_app_attributes (l_attribute_count).SEGMENT := l_segment;
      p_app_attributes (l_attribute_count).updated := hxc_timecard.c_no;
      p_app_attributes (l_attribute_count).changed := hxc_timecard.c_no;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END create_attribute;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           update_building_block
-- IN Parameters:  p_building_block_id -> Id of TBB you want to update
--                 p_measure -> New value for measure
--                 p_unit_of_measure -> Leave defaulted to HOURS
--                 p_start_time -> New value for start time
--                 p_stop_time -> New value for stop time
--                 p_comment_text -> New value for comment
--                 p_deposit_process -> Name of the deposit process which we will
--                                      use the mapping of
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL table in which the update will
--                                   take place.
--                   p_app_attributes -> Attribute PL/SQL table holding attributes
--                                       returned from the database. Although not
--                                       really needed here, it is necessary for
--                                       re-depositing the timecard.
--
-- Description:    This procedure will allow you to update the measure, start time
--                 stop time or comment of a TBB.
--                 The attribute will be updated in the same TC as all the other
--                 attribute already in the table.  If you want to update attributes
--                 on another timecard, please clear it first and start afresh.
--
-----------------------------------------------------------------------------
   PROCEDURE update_building_block (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_measure             IN              hxc_time_building_blocks.measure%TYPE,
      p_unit_of_measure     IN              hxc_time_building_blocks.unit_of_measure%TYPE,
      p_start_time          IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time           IN              hxc_time_building_blocks.stop_time%TYPE,
      p_comment_text        IN              hxc_time_building_blocks.comment_text%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks          IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_proc                   VARCHAR2 (72);
      l_building_block_index   PLS_INTEGER;
      l_load_new_timecard      BOOLEAN;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'update_building_block';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_load_new_timecard := FALSE;

      -- check if a timecard is loaded
      IF (p_app_blocks.COUNT <> 0)
      THEN
         -- check to see if you can find the BB in the loaded timecard
         l_building_block_index :=
            hxc_timestore_deposit_util.get_index_in_bb_table
                                      (p_bb_table           => p_app_blocks,
                                       p_bb_id_to_find      => p_building_block_id
                                      );

         IF (l_building_block_index < 0)
         THEN                                                     -- not found
            -- User must be updating another timecard retrieve the new timecard
            -- from the database. Lets hope the user did a deposit of his data
            -- if not, he will have lost it now!!!
            l_load_new_timecard := TRUE;
         ELSE                                                     -- TBB found
            NULL;
         END IF;                              -- IF l_building_block_index < 0
      ELSE                                            -- no timecard is loaded
         l_load_new_timecard := TRUE;
      END IF;                                    -- IF p_app_blocks.COUNT <> 0

      IF l_load_new_timecard
      THEN
         -- First clear the global tables so no garbage gets loaded with the
         -- updated TC
         hxc_self_service_time_deposit.initialize_globals;
         -- then get the TC and attributes out of the DB into the PL/SQL Tables
         hxc_timestore_deposit_util.get_timecard_tables
                                 (p_building_block_id      => p_building_block_id,
                                  -- p_time_recipient_id=> p_time_recipient_id,
                                  p_deposit_process        => p_deposit_process,
                                  p_app_blocks             => p_app_blocks,
                                  p_app_attributes         => p_app_attributes
                                 );
         -- now find where in the p_app_blocks table our TBB is situated
         l_building_block_index :=
            hxc_timestore_deposit_util.get_index_in_bb_table
                                       (p_bb_table           => p_app_blocks,
                                        p_bb_id_to_find      => p_building_block_id
                                       );

         IF g_debug
         THEN
            hr_utility.set_location (   ' - l_building_block_index = '
                                     || l_building_block_index,
                                     20
                                    );
         END IF;
      END IF;

      -- only change the values if something is passed in the procedure
      -- We need to do this workaround to avoid updating values to NULL
      -- If a system default is being used then we must not update the argument
      -- value.
      IF ((p_measure <> hr_api.g_number) OR (p_measure IS NULL))
      THEN
         p_app_blocks (l_building_block_index).measure := p_measure;
      END IF;

      IF (   (p_unit_of_measure <> hr_api.g_varchar2)
          OR (p_unit_of_measure IS NULL)
         )
      THEN
         p_app_blocks (l_building_block_index).unit_of_measure :=
                                                            p_unit_of_measure;
      END IF;

      IF ((p_start_time <> hr_api.g_date) OR (p_start_time IS NULL))
      THEN
         -- Adding fix for Bug. no. 3327697
         p_app_blocks (l_building_block_index).start_time :=
                                    fnd_date.date_to_canonical (p_start_time);
      END IF;

      IF ((p_stop_time <> hr_api.g_date) OR (p_stop_time IS NULL))
      THEN
         -- Adding fix for Bug. no. 3327697
         p_app_blocks (l_building_block_index).stop_time :=
                                     fnd_date.date_to_canonical (p_stop_time);
      END IF;

      p_app_blocks (l_building_block_index).parent_is_new := hxc_timecard.c_no;
      -- Don't know yet if I need this here or not
      -- p_app_blocks ( l_building_block_index).object_version_number := 1;
      p_app_blocks (l_building_block_index).date_from :=
                                          fnd_date.date_to_canonical (SYSDATE);
      p_app_blocks (l_building_block_index).date_to :=
                           fnd_date.date_to_canonical (hr_general.end_of_time);

      IF ((p_comment_text <> hr_api.g_varchar2) OR (p_comment_text IS NULL))
      THEN
         p_app_blocks (l_building_block_index).comment_text := p_comment_text;
      END IF;

      -- Indicate that this is an updated TBB, not a new one
      p_app_blocks (l_building_block_index).NEW := hxc_timecard.c_no;
      p_app_blocks (l_building_block_index).changed := hxc_timecard.c_yes;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 30);
      END IF;
   END update_building_block;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           update_building_block
-- IN Parameters:  See Overloaded procedure
-- INOUT Parameters: p_app_blocks -> TBB Type table in which the update will
--                                   take place.
--                   p_app_attributes -> Attribute PL/SQL table holding attributes
--                                       returned from the database. Although not
--                                       really needed here, it is necessary for
--                                       re-depositing the timecard.
--
-- Description:    Overloading the main procedure. This one will accept the old
--                 TBB PL/SQL table (passed in), convert it to the new TYPE,
--                 call the overloaded create_timecard_bb procedure that accepts
--                 the new TYPE and then convert it back to the old PL/SQL table.
--
-----------------------------------------------------------------------------
   PROCEDURE update_building_block (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_measure             IN              hxc_time_building_blocks.measure%TYPE,
      p_unit_of_measure     IN              hxc_time_building_blocks.unit_of_measure%TYPE,
      p_start_time          IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time           IN              hxc_time_building_blocks.stop_time%TYPE,
      p_comment_text        IN              hxc_time_building_blocks.comment_text%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks          IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'update_building_block (Overloaded)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks :=
         hxc_timestore_deposit_util.convert_tbb_to_type
                                                     (p_blocks      => p_app_blocks);
      update_building_block (p_building_block_id      => p_building_block_id,
                             p_measure                => p_measure,
                             p_unit_of_measure        => p_unit_of_measure,
                             p_start_time             => p_start_time,
                             p_stop_time              => p_stop_time,
                             p_comment_text           => p_comment_text,
                             -- p_time_recipient_id  => p_time_recipient_id,
                             p_deposit_process        => p_deposit_process,
                             p_app_blocks             => l_blocks,
                             p_app_attributes         => p_app_attributes
                            );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END update_building_block;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           delete_detail_bb
-- IN Parameters:  p_building_block_id -> Id of TBB you want to delete, this
--                                        needs to be a DETAIL TBB
--                 p_deposit_process -> Name of the deposit process which we will
--                                      use the mapping of
--                 p_effective_date -> date as of which the TBB will be deleted
--                                     defaults to sysdate, use default
-- INOUT Parameters: p_app_blocks -> TBB Type table in which the update will
--                                   take place.
--                   p_app_attributes -> Attribute PL/SQL table holding attributes
--                                       returned from the database. Although not
--                                       really needed here, it is necessary for
--                                       re-depositing the timecard.
--
-- Description:    This procedure will allow you to delete a DETAIL TBB.  The
--                 delete is a soft delete, so the TBB is not actually purged
--                 from the database, it is just end dated.  That is why you
--                 have to perform a deposit to get the delete through.
--
-----------------------------------------------------------------------------
   PROCEDURE delete_detail_bb (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_effective_date      IN              hxc_time_building_blocks.stop_time%TYPE,
      p_app_blocks          IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_proc                   VARCHAR2 (72);
      l_building_block_index   PLS_INTEGER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'delete_detail_bb';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- First clear the global tables so no garbage gets loaded with the updated TC
      hxc_self_service_time_deposit.initialize_globals;
      -- then get the TC and attributes out of the DB into the PL/SQL Tables
      hxc_timestore_deposit_util.get_timecard_tables
                                  (p_building_block_id      => p_building_block_id,
--         p_time_recipient_id=> p_time_recipient_id,
                                   p_deposit_process        => p_deposit_process,
                                   p_app_blocks             => p_app_blocks,
                                   p_app_attributes         => p_app_attributes
                                  );
      -- now find where in the p_app_blocks table our TBB is situated
      l_building_block_index :=
         hxc_timestore_deposit_util.get_index_in_bb_table
                                       (p_bb_table           => p_app_blocks,
                                        p_bb_id_to_find      => p_building_block_id
                                       );
      -- Set the date_to of the TBB to the sysdate, that will 'delete' the TBB
      -- This is, as you can see a soft delete, the TBB will not be visible for the
      -- user anymore, but it will stay in the DB (with a date_to of sysdate)
      p_app_blocks (l_building_block_index).date_to :=
                                 fnd_date.date_to_canonical (p_effective_date);
      -- indicate that this TBB has changed (delete)
      p_app_blocks (l_building_block_index).NEW := hxc_timecard.c_no;
      p_app_blocks (l_building_block_index).changed := hxc_timecard.c_yes;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END delete_detail_bb;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           delete_detail_bb
-- IN Parameters:  see overloaded procedure
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL table in which the update will
--                                   take place.
--                   p_app_attributes -> Attribute PL/SQL table holding attributes
--                                       returned from the database. Although not
--                                       really needed here, it is necessary for
--                                       re-depositing the timecard.
--
-- Description:    Overloading the main procedure. This one will accept the old
--                 TBB PL/SQL table (passed in), convert it to the new TYPE,
--                 call the overloaded create_timecard_bb procedure that accepts
--                 the new TYPE and then convert it back to the old PL/SQL table.
--
-----------------------------------------------------------------------------
   PROCEDURE delete_detail_bb (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_effective_date      IN              hxc_time_building_blocks.stop_time%TYPE,
      p_app_blocks          IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'delete_detail_bb (Overloaded)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks :=
         hxc_timestore_deposit_util.convert_tbb_to_type
                                                     (p_blocks      => p_app_blocks);
      delete_detail_bb (p_building_block_id      => p_building_block_id,
                        -- p_time_recipient_id   => p_time_recipient_id,
                        p_deposit_process        => p_deposit_process,
                        p_effective_date         => p_effective_date,
                        p_app_blocks             => l_blocks,
                        p_app_attributes         => p_app_attributes
                       );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END delete_detail_bb;

   -- Use to delete a complete timecard, TBB id passed in has to be a TIMECARD TBB
   -- This is just a wrapper for HXC_SELF_SERVICE_TIME_DEPOSIT.delete_timecard
-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           delete_timecard
-- IN Parameters:  p_building_block_id -> Id of TBB you want to delete, this
--                                        needs to be a TIMECARD TBB
--                 p_mode -> Needs to be DELETE, use default
--                 p_deposit_process -> Name of the deposit process which we will
--                                      use the mapping of
--                 p_effective_date -> date as of which the TBB will be deleted
--                                     defaults to sysdate, use default
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL table in which the update will
--                                   take place.
--
-- Description:    This procedure will allow you to delete a complete timecard.
--                 The delete is a soft delete, so the TC is not actually purged
--                 from the database, it is just end dated.  That is why you
--                 have to perform a deposit to get the delete through (this is
--                 done automatically by hxc_self_service_time_deposit.delete_timecard
--                 in this case).
--
-----------------------------------------------------------------------------
   PROCEDURE delete_timecard (
      p_building_block_id   IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_mode                IN   VARCHAR2,
      p_deposit_process     IN   hxc_deposit_processes.NAME%TYPE,
      -- Not used anymore, left in for backwards compatibility
      p_retrieval_process   IN   VARCHAR2,
      -- Not used anymore, left in for backwards compatibility
      p_effective_date      IN   hxc_time_building_blocks.stop_time%TYPE,
      -- Not used anymore, left in for backwards compatibility
      p_template            IN   VARCHAR2
   )
   IS
      l_proc    VARCHAR2 (72);
      l_dummy   VARCHAR2 (10);
   BEGIN
      g_debug := hr_utility.debug_enabled;
      l_dummy := 'N';

      IF g_debug
      THEN
         l_proc := g_package || 'delete_timecard';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      IF (NOT hxc_timestore_deposit_util.cla_enabled
                                   (p_building_block_id      => p_building_block_id)
         )
      THEN
         hxc_timecard.delete_timecard (p_mode             => p_mode,
                                       p_template         => p_template,
                                       p_timecard_id      => p_building_block_id,
                                       p_timecard_ok      => l_dummy
                                      );
         -- Clear the PL/SQL tables as to similate a delete of the timecard.
         hxc_self_service_time_deposit.initialize_globals;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END delete_timecard;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           update_attribute
-- IN Parameters:  p_time_attribute_id -> Id of the attribute you want to update
--                 p_attribute_value -> New value you want to store in the attribute
--                 p_deposit_process -> Name of the deposit process which we will
--                                      use the mapping of
-- INOUT Parameters: p_app_attributes -> Attribute Type in which the update
--                                       will take place.
--
-- Description:    This procedure will allow you to update an attribute in
--                 attributre PL/SQL table (passed in).  You can only update the
--                 value on the attribute record.
--                 The attribute will be updated on the same TC as all the other
--                 attribute already in the table.  If you want to update attributes
--                 of another timecard, please clear it first and start afresh.
--
-----------------------------------------------------------------------------
   PROCEDURE update_attribute (
      p_time_attribute_id   IN              hxc_time_attributes.time_attribute_id%TYPE,
      -- p_building_block_id   IN       hxc_time_building_blocks.time_building_block_id%TYPE,
      p_attribute_name      IN              hxc_mapping_components.field_name%TYPE,
      p_attribute_value     IN              hxc_time_attributes.attribute1%TYPE,
      -- p_category            IN       hxc_bld_blk_info_type_usages.building_block_category%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks          IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_proc                VARCHAR2 (72);
      l_attribute_index     PLS_INTEGER;
      -- l_app_blocks          hxc_self_service_time_deposit.timecard_info;
      l_load_new_timecard   BOOLEAN;

      CURSOR csr_tbb_id (
         v_time_attribute_id   hxc_time_attributes.time_attribute_id%TYPE
      )
      IS
         SELECT time_building_block_id
           FROM hxc_time_attribute_usages
          WHERE time_attribute_id = v_time_attribute_id;

      l_tbb_id              hxc_time_building_blocks.time_building_block_id%TYPE;
   --csr_tbb_id%ROWTYPE;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'update_attribute';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_load_new_timecard := FALSE;

      -- check if a timecard is loaded
      IF (p_app_attributes.COUNT <> 0)
      THEN
         -- check to see if you can find the attribute in the loaded timecard
         l_attribute_index :=
            hxc_timestore_deposit_util.get_index_in_attr_table
                                (p_attr_table                  => p_app_attributes,
                                 p_attr_id_to_find             => p_time_attribute_id,
                                 p_attribute_name_to_find      => p_attribute_name
                                );

         IF (l_attribute_index < 0)
         THEN                                                     -- not found
            -- User must be updating another timecard, retrieve the new timecard
            -- from the database. Lets hope the user did a deposit of his data
            -- if not, he will have lost it now!!!
            l_load_new_timecard := TRUE;
         ELSE                                                     -- TBB found
            NULL;
         END IF;                                   -- IF l_attribute_index < 0
      ELSE                                            -- no timecard is loaded
         l_load_new_timecard := TRUE;
      END IF;                                -- IF p_app_attributes.COUNT <> 0

      IF l_load_new_timecard
      THEN
         -- First clear the global tables so no garbage gets loaded with the updated TC
         hxc_self_service_time_deposit.initialize_globals;

         -- Find the TBB to which this attribute belongs
         OPEN csr_tbb_id (p_time_attribute_id);

         FETCH csr_tbb_id
          INTO l_tbb_id;

         CLOSE csr_tbb_id;

         -- then get the TC and attributes out of the DB into the PL/SQL Tables
         -- ARR: Modified for 5096926; after we have constructed the blocks and
         -- attributes for the existing timecard, we must clear the mapping cache
         -- as only the mapping components for non-null attribute values are created
         -- and we may be creating a new attribute, or updating a null attribute
         -- in this procedure.  Thus, we should regenerate the app attribute
         -- mapping cache for deposit and validation.
         hxc_timestore_deposit_util.get_timecard_tables
                                     (p_building_block_id        => l_tbb_id,
                                             -- p_app_attributes (l_attribute_index).building_block_id,
                                      -- p_time_recipient_id=> p_time_recipient_id,
                                      p_deposit_process          => p_deposit_process,
                                      p_clear_mapping_cache      => TRUE,
                                      p_app_blocks               => p_app_blocks,
                                      p_app_attributes           => p_app_attributes
                                     );
         -- Now locate our attribute in the PL/SQL table
         l_attribute_index :=
            hxc_timestore_deposit_util.get_index_in_attr_table
                                 (p_attr_table                  => p_app_attributes,
                                  p_attr_id_to_find             => p_time_attribute_id,
                                  p_attribute_name_to_find      => p_attribute_name
                                 );
      END IF;                                        -- IF l_load_new_timecard

      IF (l_attribute_index <> -1)
      THEN
         -- ARR: Can only do this if we actually found the app attribute in the
         -- table.
         -- only change the values if something is passed in the procedure
         -- We need to do this workaround to avoid updating values to NULL
         -- If a system default is being used then we must not update the argument
         -- value.
         IF (   (p_attribute_value <> hr_api.g_varchar2)
             OR (p_attribute_value IS NULL)
            )
         THEN
            p_app_attributes (l_attribute_index).attribute_value :=
                                                            p_attribute_value;

            IF g_debug
            THEN
               hr_utility.set_location
                     (   '   modifying '
                      || p_app_attributes (l_attribute_index).attribute_value
                      || ' to '
                      || NVL (p_attribute_value, 'NULL'),
                      20
                     );
            END IF;
         END IF;

         p_app_attributes (l_attribute_index).updated := hxc_timecard.c_no;
         p_app_attributes (l_attribute_index).changed := hxc_timecard.c_yes;
      ELSE
         -- ARR:
         -- We didn't find the app attribute, so we should create it.
         --
         IF (l_tbb_id IS NOT NULL)
         THEN
            create_attribute (p_building_block_id      => l_tbb_id,
                              p_attribute_name         => p_attribute_name,
                              p_attribute_value        => p_attribute_value,
                              p_deposit_process        => p_deposit_process,
                              p_attribute_id           => p_time_attribute_id,
                              p_app_attributes         => p_app_attributes
                             );
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 100);
      END IF;
   END update_attribute;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           update_attribute
-- IN Parameters:  See overloaded procedure
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL table in which the update will
--                                   take place.
--                   p_app_attributes -> Attribute PL/SQL table holding attributes
--                                       returned from the database. Although not
--                                       really needed here, it is necessary for
--                                       re-depositing the timecard.
--
-- Description:    Overloading the main procedure. This one will accept the old
--                 TBB PL/SQL table (passed in), convert it to the new TYPE,
--                 call the overloaded create_timecard_bb procedure that accepts
--                 the new TYPE and then convert it back to the old PL/SQL table.
--
-----------------------------------------------------------------------------
   PROCEDURE update_attribute (
      p_time_attribute_id   IN              hxc_time_attributes.time_attribute_id%TYPE,
      -- p_building_block_id   IN       hxc_time_building_blocks.time_building_block_id%TYPE,
      p_attribute_name      IN              hxc_mapping_components.field_name%TYPE,
      p_attribute_value     IN              hxc_time_attributes.attribute1%TYPE,
      -- p_category            IN       hxc_bld_blk_info_type_usages.building_block_category%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE,
      p_app_blocks          IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
      l_proc     VARCHAR2 (72);
      l_blocks   hxc_block_table_type;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'update_attribute';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks :=
         hxc_timestore_deposit_util.convert_tbb_to_type
                                                     (p_blocks      => p_app_blocks);
      update_attribute (p_time_attribute_id      => p_time_attribute_id,
                        -- p_building_block_id   => p_building_block_id,
                        p_attribute_name         => p_attribute_name,
                        p_attribute_value        => p_attribute_value,
                        -- p_category            => p_category,
                        -- p_time_recipient_id  => p_time_recipient_id,
                        p_deposit_process        => p_deposit_process,
                        p_app_blocks             => l_blocks,
                        p_app_attributes         => p_app_attributes
                       );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END update_attribute;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           execute_deposit_process
--
-- IN Parameters: p_validate-> if false, no commit will happen, only validation
--                p_mode-> 'SUBMIT', 'SAVE', 'MIGRATION', 'FORCE_SAVE' or
--                         'FORCE_SUBMIT'
--                p_deposit_process-> process for deposit
--                p_retrieval_process-> process for retrieval
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL table you want to deposit
--                   p_app_attributes-> Attr PL/SQL table you want to deposit
-- OUT Parameters: p_messages-> TBB PL/SQL table containing msg from deposit process
--                 p_timecard_id-> new TC ID
--                 p_timecard_ovn-> new TC OVN
--
-- Description:    Wrapper for the execute_deposit_process in old API
--
-----------------------------------------------------------------------------
   PROCEDURE execute_deposit_process (
      p_validate                       IN              BOOLEAN,
      p_mode                           IN              VARCHAR2,
      p_deposit_process                IN              VARCHAR2,
      p_retrieval_process              IN              VARCHAR2,
      -- p_add_security        IN              BOOLEAN DEFAULT TRUE,
      p_app_attributes                 IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_app_blocks                     IN OUT NOCOPY   hxc_block_table_type,
      -- hxc_self_service_time_deposit.timecard_info,
      p_messages                       OUT NOCOPY      hxc_message_table_type,
      -- hxc_self_service_time_deposit.message_table,
      p_timecard_id                    OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn                   OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE,
      p_template                       IN              VARCHAR2,
      p_item_type                      IN              wf_items.item_type%TYPE,
      p_approval_prc                   IN              wf_process_activities.process_name%TYPE,
      p_process_terminated_employees   IN              BOOLEAN,
      p_approve_term_emps_on_submit    IN              BOOLEAN
   )
   IS
      l_proc                   VARCHAR2 (72);
      l_building_block_count   PLS_INTEGER;
      l_attributes             hxc_attribute_table_type;
      l_validate               VARCHAR2 (1);
      i                        PLS_INTEGER;
      l_message                fnd_new_messages.MESSAGE_TEXT%TYPE;
      l_approval_style_id      NUMBER;
      l_locked_success         BOOLEAN;
      l_released_success       BOOLEAN;
      l_row_lock_id            ROWID;
      l_appl_set_id            NUMBER;
   BEGIN
      g_debug := hr_utility.debug_enabled;
      l_attributes := hxc_attribute_table_type ();

      IF g_debug
      THEN
         l_proc := g_package || 'execute_deposit_process';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      -- issue savepoint in case running in validate mode
      SAVEPOINT validation_only;
      hxc_timecard_block_utils.initialize_timecard_index;

      -- assign p_validate in global variable.
      g_validate := p_validate;

      -- take out a lock on the period
      hxc_timestore_deposit_util.request_lock
                                        (p_app_blocks          => p_app_blocks,
                                         p_messages            => p_messages,
                                         p_locked_success      => l_locked_success,
                                         p_row_lock_id         => l_row_lock_id
                                        );

      IF (l_locked_success)
      THEN
         -- before doing anything, we need to populate the approval_status of the
         -- TBBs. This used to be set manually but now we derive it from the mode
         -- passed in here. Since we did not have the mode handy when building up
         -- the TC, we left the approval_status empty. Now we will set it here.
         -- We set all approval_status of all TBBs of the timecard to the same
         -- value (as it should be).
         IF ((p_mode = c_migration) OR (p_process_terminated_employees))
         THEN
            hxc_preference_evaluation.set_migration_mode
                                                    (p_migration_mode      => TRUE);
         ELSE
            hxc_preference_evaluation.set_migration_mode
                                                   (p_migration_mode      => FALSE);
         END IF;

         IF (p_mode = c_migration)
         THEN
            l_approval_style_id :=
               hxc_timestore_deposit_util.approval_style_id
                                (p_approval_style_name      => c_auto_approve_name);
         ELSE                                -- from the employee's preference
            IF (    (p_approve_term_emps_on_submit)
                AND (hxc_preference_evaluation.employment_ended
                        (p_person_id      => p_app_blocks (p_app_blocks.FIRST).resource_id
                        )
                    )
                AND (   (p_mode = hxc_timecard.c_submit)
                     OR (p_mode = c_tk_submit)
                    )
               )
            THEN
               l_approval_style_id :=
                  hxc_timestore_deposit_util.approval_style_id
                          (p_approval_style_name      => c_approval_on_submit_name);
            ELSE
               l_approval_style_id :=
                  hxc_preference_evaluation.resource_preferences
                     (p_resource_id          => p_app_blocks
                                                           (p_app_blocks.FIRST).resource_id,
                      p_pref_code            => 'TS_PER_APPROVAL_STYLE',
                      p_attribute_n          => 1,
                      p_evaluation_date      => SYSDATE
                     );
            END IF;
         END IF;

         l_appl_set_id :=
            TO_NUMBER
               (hxc_preference_evaluation.resource_preferences
                   (p_resource_id          => p_app_blocks (p_app_blocks.FIRST).resource_id,
                    p_pref_code            => 'TS_PER_APPLICATION_SET',
                    p_attribute_n          => 1,
                    p_evaluation_date      => fnd_date.canonical_to_date
                                                 (p_app_blocks
                                                           (p_app_blocks.FIRST).start_time
                                                 )
                   )
               );
         l_building_block_count := p_app_blocks.FIRST;

         LOOP
            EXIT WHEN (NOT p_app_blocks.EXISTS (l_building_block_count));
            p_app_blocks (l_building_block_count).approval_status :=
                      hxc_timestore_deposit_util.get_approval_status (p_mode);

            -- In case of MIGRATION we just override what that user passes in as
            -- approval style (we set it to Auto Approve regardless), in all other
            -- cases we never override, only if nothing is provided we put
            -- something
            IF (   (p_app_blocks (l_building_block_count).approval_style_id IS NULL
                   )
                OR (p_mode = c_migration)
               )
            THEN
               p_app_blocks (l_building_block_count).approval_style_id :=
                                                          l_approval_style_id;
            END IF;

            p_app_blocks (l_building_block_count).application_set_id :=
                                                                 l_appl_set_id;
            l_building_block_count :=
                                    p_app_blocks.NEXT (l_building_block_count);
         END LOOP;

         -- convert the app_attributes into attributes that the DPWR understands
         hxc_timestore_deposit_util.convert_app_attributes_to_type
                                         (p_attributes          => l_attributes,
                                          p_app_attributes      => p_app_attributes
                                         );

         IF g_debug
         THEN
            hr_utility.TRACE ('l_attributes.count = ' || l_attributes.COUNT);
            hr_utility.TRACE (   'p_app_attributes.count = '
                              || p_app_attributes.COUNT
                             );
         END IF;

         -- perform the deposit using NEW DPWR
         IF (p_mode = hxc_timecard.c_save)
         THEN
            hxc_timestore_deposit_util.save_timecard
                                            (p_blocks            => p_app_blocks,
                                             p_attributes        => l_attributes,
                                             p_messages          => p_messages,
                                             p_timecard_id       => p_timecard_id,
                                             p_timecard_ovn      => p_timecard_ovn
                                            );
         ELSIF (p_mode = hxc_timecard.c_submit)
         THEN
            hxc_timestore_deposit_util.submit_timecard
                                           (p_item_type         => p_item_type,
                                            p_approval_prc      => p_approval_prc,
                                            p_template          => p_template,
                                            p_mode              => p_mode,
                                            p_blocks            => p_app_blocks,
                                            p_attributes        => l_attributes,
                                            p_messages          => p_messages,
                                            p_timecard_id       => p_timecard_id,
                                            p_timecard_ovn      => p_timecard_ovn
                                           );
         ELSIF (p_mode = c_tk_save)
         THEN
            hxc_timekeeper.save_timecard (p_blocks            => p_app_blocks,
                                          p_attributes        => l_attributes,
                                          p_messages          => p_messages,
                                          p_timecard_id       => p_timecard_id,
                                          p_timecard_ovn      => p_timecard_ovn
                                         );
         ELSIF (p_mode = c_tk_submit)
         THEN
            hxc_timekeeper.submit_timecard (p_blocks            => p_app_blocks,
                                            p_attributes        => l_attributes,
                                            p_messages          => p_messages,
                                            p_timecard_id       => p_timecard_id,
                                            p_timecard_ovn      => p_timecard_ovn
                                           );
         ELSIF (p_mode = c_migration)
         THEN
            IF (p_retrieval_process IS NOT NULL)
            THEN
               hxc_timestore_deposit_util.submit_timecard
                                 (p_item_type              => 'HXCEMP',
                                  p_approval_prc           => 'HXC_APPROVAL',
                                  p_template               => p_template,
                                  p_mode                   => p_mode,
                                  p_retrieval_process      => p_retrieval_process,
                                  p_blocks                 => p_app_blocks,
                                  p_attributes             => l_attributes,
                                  p_messages               => p_messages,
                                  p_timecard_id            => p_timecard_id,
                                  p_timecard_ovn           => p_timecard_ovn
                                 );
            ELSE
               fnd_message.set_name ('HXC', 'HXC_0075_HDP_DPROC_NAME_MAND');
               fnd_msg_pub.ADD;
            END IF;
         END IF;

         hxc_timestore_deposit_util.release_lock
                                    (p_app_blocks            => p_app_blocks,
                                     p_messages              => p_messages,
                                     p_released_success      => l_released_success,
                                     p_row_lock_id           => l_row_lock_id
                                    );

         -- The Projects Migration needs to have the content of these tables so
         -- we don't clear them for mode Migration. For all the other modes,
         -- we do clear the tables. This is done for useability so the users don't
         -- have to do this themselves every time. The clearing of the tables can
         -- always be removed if other modes also want to use the content of the
         -- tables but then the docs will have to be updated telling users to clear
         -- the table manually themselves (by calling these clear procedures in
         -- their wrappers as below.
         IF (p_mode <> c_migration)
         THEN
            -- Finished, clean up
            hxc_timestore_deposit_util.clear_building_block_table
                                                (p_app_blocks      => p_app_blocks);
            hxc_timestore_deposit_util.clear_attribute_table
                                        (p_app_attributes      => p_app_attributes);
         -- We don't really wanna clear this as the user might want to read them.
         -- clear_message_table (p_messages => p_messages);
         END IF;
      END IF;                      -- lock was unsuccessfull, nothing was done

      IF (p_validate)
      THEN
         RAISE hr_api.validate_enabled;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   EXCEPTION
      --
      WHEN hr_api.validate_enabled
      THEN
         -- As the Validate_Enabled exception has been raised
         -- we must rollback to the savepoint
         ROLLBACK TO validation_only;

         IF g_debug
         THEN
            hr_utility.set_location ('Leaving (validation mode):' || l_proc,
                                     30
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- make sure we release the lock
         hxc_timestore_deposit_util.release_lock
                                   (p_app_blocks            => p_app_blocks,
                                    p_messages              => p_messages,
                                    p_released_success      => l_released_success,
                                    p_row_lock_id           => l_row_lock_id
                                   );
         RAISE;
   END execute_deposit_process;

-----------------------------------------------------------------------------
-- Type:           Procedure
-- Scope:          Public
-- Name:           execute_deposit_process
--
-- IN Parameters: p_validate-> if false, no commit will happen, only validation
--                p_mode-> 'SUBMIT', 'SAVE' or 'MIGRATION'
--                p_deposit_process-> process for deposit
--                p_retrieval_process-> process for retrieval
-- INOUT Parameters: p_app_blocks -> TBB PL/SQL table you want to deposit
--                   p_app_attributes-> Attr PL/SQL table you want to deposit
-- OUT Parameters: p_messages-> TBB PL/SQL table containing msg from deposit process
--                 p_timecard_id-> new TC ID
--                 p_timecard_ovn-> new TC OVN
--
-- Description:    Wrapper for the execute_deposit_process in old API
--
-----------------------------------------------------------------------------
   PROCEDURE execute_deposit_process (
      p_validate                       IN              BOOLEAN,
      p_mode                           IN              VARCHAR2,
      p_deposit_process                IN              VARCHAR2,
      p_retrieval_process              IN              VARCHAR2,
      -- p_add_security        IN              BOOLEAN DEFAULT TRUE,
      p_app_attributes                 IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_app_blocks                     IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_messages                       OUT NOCOPY      hxc_self_service_time_deposit.message_table,
      p_timecard_id                    OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn                   OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE,
      p_template                       IN              VARCHAR2,
      p_item_type                      IN              wf_items.item_type%TYPE,
      p_approval_prc                   IN              wf_process_activities.process_name%TYPE,
      p_process_terminated_employees   IN              BOOLEAN,
      p_approve_term_emps_on_submit    IN              BOOLEAN
   )
   IS
      l_blocks     hxc_block_table_type;
      l_messages   hxc_message_table_type;
      l_proc       VARCHAR2 (72);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'execute_deposit_process (Overloaded)';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      l_blocks :=
         hxc_timestore_deposit_util.convert_tbb_to_type
                                                     (p_blocks      => p_app_blocks);
      execute_deposit_process
            (p_validate                          => p_validate,
             p_mode                              => p_mode,
             p_deposit_process                   => p_deposit_process,
             p_retrieval_process                 => p_retrieval_process,
             -- p_add_security=>p_add_security,
             p_app_attributes                    => p_app_attributes,
             p_app_blocks                        => l_blocks,
             p_messages                          => l_messages,
             p_timecard_id                       => p_timecard_id,
             p_timecard_ovn                      => p_timecard_ovn,
             p_template                          => p_template,
             p_item_type                         => p_item_type,
             p_approval_prc                      => p_approval_prc,
             p_process_terminated_employees      => p_process_terminated_employees,
             p_approve_term_emps_on_submit       => p_approve_term_emps_on_submit
            );
      p_app_blocks :=
         hxc_timecard_block_utils.convert_to_dpwr_blocks (p_blocks      => l_blocks);
      p_messages :=
         hxc_timestore_deposit_util.convert_to_dpwr_messages
                                                     (p_messages      => l_messages);

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 20);
      END IF;
   END execute_deposit_process;

   PROCEDURE clear_building_block_table (
      p_app_blocks   IN OUT NOCOPY   hxc_block_table_type
   )
   IS
   BEGIN
      hxc_timestore_deposit_util.clear_building_block_table (p_app_blocks);
   END clear_building_block_table;

   PROCEDURE clear_attribute_table (
      p_app_attributes   IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
   BEGIN
      hxc_timestore_deposit_util.clear_attribute_table (p_app_attributes);
   END clear_attribute_table;

   PROCEDURE clear_message_table (
      p_messages   IN OUT NOCOPY   hxc_message_table_type
   )
   IS
   BEGIN
      hxc_timestore_deposit_util.clear_message_table (p_messages);
   END clear_message_table;

   PROCEDURE log_timecard (
      p_app_blocks       IN   hxc_block_table_type,
      p_app_attributes   IN   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
   BEGIN
      hxc_timestore_deposit_util.log_timecard (p_app_blocks,
                                               p_app_attributes);
   END log_timecard;

   PROCEDURE log_timecard (
      p_app_blocks       IN   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes   IN   hxc_self_service_time_deposit.app_attributes_info
   )
   IS
   BEGIN
      hxc_timestore_deposit_util.log_timecard (p_app_blocks,
                                               p_app_attributes);
   END log_timecard;

   PROCEDURE log_messages (p_messages IN hxc_message_table_type)
   IS
   BEGIN
      hxc_timestore_deposit_util.log_messages (p_messages);
   END log_messages;

   PROCEDURE log_messages (
      p_messages   IN   hxc_self_service_time_deposit.message_table
   )
   IS
   BEGIN
      hxc_timestore_deposit_util.log_messages (p_messages);
   END log_messages;
END hxc_timestore_deposit;

/
