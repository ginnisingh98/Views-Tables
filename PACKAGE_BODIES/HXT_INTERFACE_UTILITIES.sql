--------------------------------------------------------
--  DDL for Package Body HXT_INTERFACE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_INTERFACE_UTILITIES" AS
/* $Header: hxtinterfaceutil.pkb 120.7.12010000.2 2009/07/15 07:52:31 asrajago ship $ */

   -- Global package name
   g_debug boolean := hr_utility.debug_enabled;
   g_package             CONSTANT package_name  := 'hxt_interface_utilities.';
   g_current_element              pay_element_types_f.element_type_id%TYPE
                                                                      := NULL;
   -- GLOBAL SWITCHES --
   -- Controls whether we do commits or not during the run
   g_do_commit                    BOOLEAN                             := TRUE;                                                                                -- Should always be TRUE except for testing!
                                                                               -- Controls whether we use the old method of creating retro batches vs the
                                                                               -- new method
   g_use_old_retro_batches        BOOLEAN                             := TRUE;                                                                                -- For now, this should be set to TRUE!
                                                                               -- Controls whether we do local caching of data or not
   g_caching                      BOOLEAN                             := TRUE;
   -- caching tables
   g_element_type_ivs             input_value_name_table;
   g_iv_translations              iv_translation_table;
   g_primary_assignments          primary_assignment_table;
   g_flex_values                  flex_value_table;
   g_assignment_info              assignment_info_table;
   g_concatenated_segments        concatenated_segment_table;
   g_batch_info                   batch_info_table;
   -- cached variables
   g_conc_request_id_suffix       fnd_concurrent_requests.request_id%TYPE;
   --
   g_batchname_suffix_connector   VARCHAR2 (1)                         := '_';
   g_max_batch_size               NUMBER                                := -1;
   g_tbb_index 			  NUMBER;
   g_tbb 		 	  NUMBER;

   FUNCTION current_element
      RETURN pay_element_types_f.element_type_id%TYPE
   IS
      l_proc    proc_name ;
   BEGIN

      if g_debug then
	      l_proc :=    g_package
                             || 'current_element';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
	      hr_utility.set_location (   '   returning g_current_element = '
				       || g_current_element,
				       20
				      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN g_current_element;
   END current_element;

   PROCEDURE set_current_element (
      p_current_element   IN   pay_element_types_f.element_type_id%TYPE
   )
   IS
      l_proc    proc_name ;
   BEGIN

      if g_debug then
	      l_proc :=    g_package
                              || 'set_current_element';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
	      hr_utility.set_location (   '   setting g_current_element to '
				       || p_current_element,
				       20
				      );
      end if;
      g_current_element := p_current_element;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END set_current_element;

   FUNCTION do_commit
      RETURN BOOLEAN
   IS
      l_proc    proc_name ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'do_commit';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (g_do_commit)
      THEN
         if g_debug then
         	 hr_utility.set_location ('   returning g_do_commit = TRUE', 20);
         end if;
      ELSE
         if g_debug then
         	 hr_utility.set_location ('   returning g_do_commit = FALSE', 30);
         end if;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN g_do_commit;
   END do_commit;

   PROCEDURE set_do_commit (p_do_commit IN BOOLEAN)
   IS
      l_proc  proc_name ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'set_do_commit';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (p_do_commit)
      THEN
         if g_debug then
         	 hr_utility.set_location ('   setting g_do_commit to TRUE', 20);
         end if;
      ELSE
         if g_debug then
         	 hr_utility.set_location ('   setting g_do_commit to FALSE', 30);
         end if;
      END IF;

      g_do_commit := p_do_commit;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END set_do_commit;

   PROCEDURE perform_commit
   IS
      l_proc   proc_name ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'perform_commit';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (do_commit)
      THEN
         if g_debug then
         	 hr_utility.set_location ('   Commiting', 20);
         end if;
         COMMIT;
      ELSE
         NULL; -- No Commit
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END perform_commit;

   FUNCTION use_old_retro_batches
      RETURN BOOLEAN
   IS
      l_proc   proc_name ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'use_old_retro_batches';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (g_use_old_retro_batches)
      THEN
         if g_debug then
		 hr_utility.set_location ('   returning g_use_old_retro_batches = TRUE',
					  20
					 );
         end if;
      ELSE
         if g_debug then
		 hr_utility.set_location ('   returning g_use_old_retro_batches = FALSE',
					  30
					 );
         end if;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN g_use_old_retro_batches;
   END use_old_retro_batches;

   PROCEDURE set_use_old_retro_batches (p_use_old_retro_batches IN BOOLEAN)
   IS
      l_proc   proc_name ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'set_use_old_retro_batches';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (p_use_old_retro_batches)
      THEN
         if g_debug then
		 hr_utility.set_location ('   setting g_use_old_retro_batches to TRUE',
					  20
					 );
         end if;
      ELSE
         if g_debug then
		 hr_utility.set_location ('   setting g_use_old_retro_batches to FALSE',
					  30
					 );
         end if;
      END IF;

      g_use_old_retro_batches := p_use_old_retro_batches;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END set_use_old_retro_batches;

   FUNCTION caching
      RETURN BOOLEAN
   IS
      l_proc    proc_name ;
   BEGIN

      if g_debug then
	      l_proc :=    g_package
                             || 'caching';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (g_caching)
      THEN
         if g_debug then
         	 hr_utility.set_location ('   returning g_caching = TRUE', 20);
         end if;
      ELSE
         if g_debug then
         	 hr_utility.set_location ('   returning g_caching = FALSE', 30);
         end if;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN g_caching;
   END caching;

   PROCEDURE set_caching (p_caching IN BOOLEAN)
   IS
      l_proc    proc_name ;
   BEGIN

      if g_debug then
	      l_proc :=    g_package
                             || 'set_caching';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (p_caching)
      THEN
         if g_debug then
         	 hr_utility.set_location ('   setting g_caching to TRUE', 20);
         end if;
      ELSE
         if g_debug then
         	 hr_utility.set_location ('   setting g_caching to FALSE', 30);
         end if;
      END IF;

      g_caching := p_caching;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END set_caching;

   FUNCTION batchname_suffix_connector
      RETURN VARCHAR2
   IS
      l_proc    proc_name;

   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'batchname_suffix_connector';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
	      hr_utility.set_location (   '   returning g_batchname_suffix_connector = '
				       || g_batchname_suffix_connector,
				       20
				      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN g_batchname_suffix_connector;
   END batchname_suffix_connector;

   PROCEDURE set_batchname_suffix_connector (
      p_batchname_suffix_connector   IN   VARCHAR2
   )
   IS
      l_proc    proc_name;

   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'set_batchname_suffix_connector';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
	      hr_utility.set_location (   '   setting g_batchname_suffix_connector to '
				       || p_batchname_suffix_connector,
				       20
				      );
      end if;
      g_batchname_suffix_connector := p_batchname_suffix_connector;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END set_batchname_suffix_connector;

   FUNCTION hashval (p_str IN VARCHAR2)
      RETURN PLS_INTEGER
   IS
      l_proc        proc_name  ;
      l_hashval             PLS_INTEGER;
      c_maxrange   CONSTANT PLS_INTEGER := 2147483647; -- POWER (2, 31) - 1;
      c_start      CONSTANT PLS_INTEGER := 2;
   BEGIN

      if g_debug then
	      l_proc :=    g_package
                              || 'hashval';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      l_hashval := DBMS_UTILITY.get_hash_value (p_str, c_start, c_maxrange);
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_hashval;
   END hashval;

   PROCEDURE empty_asg_cache
   IS
      l_proc                proc_name;

      l_empty_primary_assignments   primary_assignment_table;
      l_empty_assignment_info       assignment_info_table;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'empty_asg_cache';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      g_primary_assignments := l_empty_primary_assignments;
      g_assignment_info := l_empty_assignment_info;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END empty_asg_cache;

   PROCEDURE empty_batch_suffix_cache
   IS
      l_proc       proc_name;

      l_empty_batch_info   batch_info_table;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'empty_batch_suffix_cache';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      g_batch_info := l_empty_batch_info;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END empty_batch_suffix_cache;

   PROCEDURE empty_cache
   IS
      l_proc    proc_name ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'empty_cache';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      empty_asg_cache;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END empty_cache;

   FUNCTION max_batch_size
      RETURN NUMBER
   IS
      l_proc    proc_name ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'max_batch_size';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (g_max_batch_size = -1)
      THEN
         g_max_batch_size := fnd_profile.VALUE (g_otl_batchsize_profile);
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   returning max batch size: '
				       || g_max_batch_size,
				       20
				      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN g_max_batch_size;
   END max_batch_size;

   FUNCTION conc_request_id_suffix (p_from_last IN PLS_INTEGER DEFAULT 4)
      RETURN NUMBER
   IS
      l_proc             proc_name;

      l_conc_request_id_suffix   NUMBER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'conc_request_id_suffix';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (g_conc_request_id_suffix IS NULL)
      THEN
         SELECT SUBSTR (fnd_global.conc_request_id,
                           -1
                         * (LEAST (p_from_last,
                                   LENGTH (fnd_global.conc_request_id)
                                  )
                           )
                       )
           INTO l_conc_request_id_suffix
           FROM DUAL;

         g_conc_request_id_suffix := l_conc_request_id_suffix;
      ELSE
         l_conc_request_id_suffix := g_conc_request_id_suffix;
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   returning l_conc_request_id_suffix: '
				       || l_conc_request_id_suffix,
				       20
				      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_conc_request_id_suffix;
   END conc_request_id_suffix;

   FUNCTION batch_name (
      p_batch_ref              IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id                  IN   pay_batch_headers.business_group_id%TYPE,
      p_invalid_batch_status   IN   pay_batch_headers.batch_status%TYPE
            DEFAULT NULL
   )
      RETURN pay_batch_headers.batch_name%TYPE
   AS
      l_proc    proc_name  ;

      CURSOR csr_max_batch_id (
         p_batch_ref              pay_batch_headers.batch_reference%TYPE,
         p_bg_id                  pay_batch_headers.business_group_id%TYPE,
         p_invalid_batch_status   pay_batch_headers.batch_status%TYPE
      )
      IS
         SELECT MAX (pbh.batch_id) batch_id
           FROM pay_batch_headers pbh
          WHERE pbh.batch_reference = p_batch_ref
            AND pbh.business_group_id = p_bg_id
            AND (   (pbh.batch_status <> p_invalid_batch_status)
                 OR (p_invalid_batch_status IS NULL)
                );

      CURSOR csr_batch_name (p_batch_id pay_batch_headers.batch_id%TYPE)
      IS
         SELECT batch_name
           FROM pay_batch_headers pbh
          WHERE pbh.batch_id = p_batch_id;

      l_batch_id        pay_batch_headers.batch_id%TYPE;
      l_batch_name      pay_batch_headers.batch_name%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'batch_name';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (csr_max_batch_id%ISOPEN)
      THEN
         CLOSE csr_max_batch_id;
      END IF;

      OPEN csr_max_batch_id (p_batch_ref, p_bg_id, p_invalid_batch_status);
      FETCH csr_max_batch_id INTO l_batch_id;
      CLOSE csr_max_batch_id;

      IF (csr_batch_name%ISOPEN)
      THEN
         CLOSE csr_batch_name;
      END IF;

      OPEN csr_batch_name (l_batch_id);
      FETCH csr_batch_name INTO l_batch_name;
      CLOSE csr_batch_name;
      if g_debug then
	      hr_utility.set_location (   '   returning batch name: '
				       || l_batch_name, 20);
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_batch_name;
   END batch_name;

   FUNCTION max_batch_id (
      p_batch_name   IN   pay_batch_headers.batch_name%TYPE,
      p_bg_id        IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN pay_batch_headers.batch_id%TYPE
   AS
      l_proc    proc_name   ;

      CURSOR csr_max_batch_id (
         p_batch_name   IN   pay_batch_headers.batch_name%TYPE,
         p_bg_id        IN   pay_batch_headers.business_group_id%TYPE
      )
      IS
         SELECT MAX (pbh.batch_id) -- we need to do max because name is not unique
           FROM pay_batch_headers pbh
          WHERE pbh.batch_name = p_batch_name
            AND pbh.business_group_id = p_bg_id;

      l_batch_id        pay_batch_headers.batch_id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'max_batch_id';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (csr_max_batch_id%ISOPEN)
      THEN
         CLOSE csr_max_batch_id;
      END IF;

      OPEN csr_max_batch_id (p_batch_name, p_bg_id);
      FETCH csr_max_batch_id INTO l_batch_id;
      CLOSE csr_max_batch_id;
      if g_debug then
	      hr_utility.set_location (   '   returning batch id: '
				       || l_batch_id, 20);
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_batch_id;
   END max_batch_id;

   FUNCTION max_batch_id (
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN pay_batch_headers.batch_id%TYPE
   AS
      l_proc    proc_name ;

      CURSOR csr_max_batch_id (
         p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
         p_bg_id             IN   pay_batch_headers.business_group_id%TYPE
      )
      IS
         SELECT MAX (pbh.batch_id) -- we need to do max because name is not unique
           FROM pay_batch_headers pbh
          WHERE pbh.batch_name = p_batch_reference
            AND pbh.business_group_id = p_bg_id;

      l_batch_id        pay_batch_headers.batch_id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'max_batch_id';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (csr_max_batch_id%ISOPEN)
      THEN
         CLOSE csr_max_batch_id;
      END IF;

      OPEN csr_max_batch_id (p_batch_reference, p_bg_id);
      FETCH csr_max_batch_id INTO l_batch_id;
      CLOSE csr_max_batch_id;
      if g_debug then
	      hr_utility.set_location (   '   returning batch id: '
				       || l_batch_id, 20);
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_batch_id;
   END max_batch_id;

   FUNCTION count_batch_lines (p_batch_id IN pay_batch_headers.batch_id%TYPE)
      RETURN NUMBER
   AS
      l_proc    proc_name ;

      CURSOR csr_batch_lines (p_batch_id IN pay_batch_headers.batch_name%TYPE)
      IS
         SELECT COUNT (pbl.batch_line_id)
           FROM pay_batch_lines pbl
          WHERE pbl.batch_id = p_batch_id;

      l_batch_lines     NUMBER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'count_batch_lines';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      OPEN csr_batch_lines (p_batch_id);
      FETCH csr_batch_lines INTO l_batch_lines;
      CLOSE csr_batch_lines;
      if g_debug then
	      hr_utility.set_location (   '   returning number of batch lines: '
				       || l_batch_lines,
				       20
				      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_batch_lines;
   END count_batch_lines;

   FUNCTION count_batch_lines (
      p_batch_name   IN   pay_batch_headers.batch_name%TYPE,
      p_bg_id        IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN NUMBER
   AS
      l_proc    proc_name  ;
      l_batch_id        pay_batch_headers.batch_name%TYPE;
      l_batch_lines     NUMBER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'count_batch_lines';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      l_batch_id :=
               max_batch_id (p_batch_name      => p_batch_name,
                             p_bg_id           => p_bg_id);
      l_batch_lines := count_batch_lines (p_batch_id => l_batch_id);
      if g_debug then
	      hr_utility.set_location (   '   returning number of batch lines: '
				       || l_batch_lines,
				       20
				      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_batch_lines;
   END count_batch_lines;

   FUNCTION total_batch_lines (
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN NUMBER
   AS
      l_proc    proc_name ;

      CURSOR csr_batch_lines (
         p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
         p_bg_id             IN   pay_batch_headers.business_group_id%TYPE
      )
      IS
         SELECT COUNT (pbl.batch_line_id)
           FROM pay_batch_lines pbl, pay_batch_headers pbh
          WHERE pbl.batch_id = pbh.batch_id
            AND pbh.business_group_id = p_bg_id
            AND batch_reference = p_batch_reference;

      l_batch_lines     NUMBER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                                     || 'total_batch_lines';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      OPEN csr_batch_lines (p_batch_reference, p_bg_id);
      FETCH csr_batch_lines INTO l_batch_lines;
      CLOSE csr_batch_lines;
      if g_debug then
	      hr_utility.set_location (   '   returning number of batch lines: '
				       || l_batch_lines,
				       20
				      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_batch_lines;
   END total_batch_lines;

   FUNCTION max_lines_exceeded (
      p_batch_id   IN   pay_batch_headers.batch_reference%TYPE
   )
      RETURN BOOLEAN
   IS
      l_proc         proc_name ;
      l_max_lines_exceeded   BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'max_lines_exceeded';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (count_batch_lines (p_batch_id => p_batch_id) >= max_batch_size)
      THEN
         l_max_lines_exceeded := TRUE;
         if g_debug then
         	 hr_utility.set_location ('   Maximum lines in batch exceeded!', 20);
         end if;
      ELSE
         l_max_lines_exceeded := FALSE;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_max_lines_exceeded;
   END max_lines_exceeded;

   PROCEDURE max_lines_exceeded (
      p_batch_id             IN              pay_batch_headers.batch_reference%TYPE,
      p_number_lines         IN OUT NOCOPY   PLS_INTEGER,
      p_max_lines_exceeded   OUT NOCOPY      BOOLEAN
   )
   IS
      l_proc         proc_name ;
      l_max_lines_exceeded   BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'max_lines_exceeded';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (p_number_lines IS NULL)
      THEN
         p_number_lines := count_batch_lines (p_batch_id => p_batch_id);
      END IF;

      IF (p_number_lines >= max_batch_size)
      THEN
         p_max_lines_exceeded := TRUE;
         if g_debug then
         	 hr_utility.set_location ('   Maximum lines in batch exceeded!', 20);
         end if;
      ELSE
         p_max_lines_exceeded := FALSE;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END max_lines_exceeded;

   FUNCTION max_lines_exceeded (
      p_batch_ref   IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id       IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN BOOLEAN
   IS
      l_proc         proc_name   ;
      l_batch_name           pay_batch_headers.batch_name%TYPE;
      l_max_lines_exceeded   BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'max_lines_exceeded';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      l_batch_name :=
         batch_name (p_batch_ref                 => p_batch_ref,
                     p_bg_id                     => p_bg_id,
                     p_invalid_batch_status      => g_batch_status_transferred
                    );

      IF (count_batch_lines (p_batch_name      => l_batch_name,
                             p_bg_id           => p_bg_id) > max_batch_size
         )
      THEN
         l_max_lines_exceeded := TRUE;
         if g_debug then
         	 hr_utility.set_location ('   Maximum lines in batch exceeded!', 20);
         end if;
      ELSE
         l_max_lines_exceeded := FALSE;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_max_lines_exceeded;
   END max_lines_exceeded;

   FUNCTION isnumber (p_value VARCHAR2)
      RETURN BOOLEAN
   IS
      l_proc    proc_name ;
      l_number          NUMBER;
      l_isnumber        BOOLEAN   := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'isnumber';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      BEGIN
         l_number := p_value;
         l_isnumber := TRUE;
      EXCEPTION
         WHEN OTHERS
         THEN
            if g_debug then
		    hr_utility.set_location (   'Leaving:'
					     || l_proc, 50);
            end if;
            RETURN l_isnumber;
      END;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_isnumber;
   END isnumber;

   FUNCTION detail_lines_retrieved (
      p_tbb_tbl   IN   hxc_generic_retrieval_pkg.t_building_blocks
   )
      RETURN BOOLEAN
   IS
      l_proc             proc_name;

      l_detail_lines_retrieved   BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'detail_lines_retrieved';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (p_tbb_tbl.COUNT <> 0)
      THEN
         l_detail_lines_retrieved := TRUE;
         if g_debug then
         	 hr_utility.set_location ('   Detail lines retrieved!', 20);
         end if;
      ELSE
         l_detail_lines_retrieved := FALSE;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_detail_lines_retrieved;
   END detail_lines_retrieved;

   FUNCTION gre (
      p_assignment_id    IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date   IN   per_all_assignments_f.effective_start_date%TYPE
   )
      RETURN hr_soft_coding_keyflex.segment1%TYPE
   IS
      l_proc    proc_name   ;

      CURSOR csr_gre (
         p_assignment_id    per_all_assignments_f.assignment_id%TYPE,
         p_effective_date   per_all_assignments_f.effective_start_date%TYPE
      )
      IS
         SELECT hsck.segment1 gre
           FROM per_all_assignments_f paaf, hr_soft_coding_keyflex hsck
          WHERE paaf.assignment_id = p_assignment_id
            AND p_effective_date BETWEEN paaf.effective_start_date
                                     AND paaf.effective_end_date
            AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id;

      l_gre             hr_soft_coding_keyflex.segment1%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'gre';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (csr_gre%ISOPEN)
      THEN
         CLOSE csr_gre;
      END IF;

      OPEN csr_gre (p_assignment_id, p_effective_date);
      FETCH csr_gre INTO l_gre;
      CLOSE csr_gre;
      if g_debug then
	      hr_utility.set_location (   '   returning gre = '
				       || l_gre, 90);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_gre;
   END gre;

   FUNCTION table_to_comma (p_asg_type IN asg_type_table)
      RETURN VARCHAR2
   AS
      l_proc    proc_name ;
      l_asg_types_idx   PLS_INTEGER;
      l_var_asg_types   DBMS_UTILITY.uncl_array;
      l_tablen          BINARY_INTEGER;
      l_list            VARCHAR2 (4000);
   BEGIN

      if g_debug then
	      l_proc :=    g_package
                               || 'table_to_comma';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_asg_types_idx := p_asg_type.FIRST;

      LOOP
         EXIT WHEN NOT p_asg_type.EXISTS (l_asg_types_idx);
         l_var_asg_types (l_asg_types_idx) :=
                                        p_asg_type (l_asg_types_idx).asg_type;
         l_asg_types_idx := p_asg_type.NEXT (l_asg_types_idx);
      END LOOP;

      DBMS_UTILITY.table_to_comma (tab         => l_var_asg_types,
                                   tablen      => l_tablen,
                                   LIST        => l_list
                                  );
      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_list;
   END table_to_comma;

   FUNCTION table_to_comma (p_asg_system_type IN asg_system_status_table)
      RETURN VARCHAR2
   AS
      l_proc           proc_name    ;
      l_asg_system_types_idx   PLS_INTEGER;
      l_var_asg_system_types   DBMS_UTILITY.uncl_array;
      l_tablen                 BINARY_INTEGER;
      l_list                   VARCHAR2 (4000);
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'table_to_comma';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_asg_system_types_idx := p_asg_system_type.FIRST;

      LOOP
         EXIT WHEN NOT p_asg_system_type.EXISTS (l_asg_system_types_idx);
         l_var_asg_system_types (l_asg_system_types_idx) :=
                 p_asg_system_type (l_asg_system_types_idx).asg_system_status;
         l_asg_system_types_idx :=
                              p_asg_system_type.NEXT (l_asg_system_types_idx);
      END LOOP;

      DBMS_UTILITY.table_to_comma (tab         => l_var_asg_system_types,
                                   tablen      => l_tablen,
                                   LIST        => l_list
                                  );
      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_list;
   END table_to_comma;

   FUNCTION valid_assignment_type (
      p_asg_type         IN   per_all_assignments_f.assignment_type%TYPE,
      p_validation_tbl   IN   asg_type_table
   )
      RETURN BOOLEAN
   AS
      l_proc    proc_name   ;
      l_val_tbl_idx     PLS_INTEGER;
      l_valid           BOOLEAN     := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'valid_assignment_type';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (p_validation_tbl.COUNT <> 0) -- values passed, start comparing
      THEN
         l_val_tbl_idx := p_validation_tbl.FIRST;

         LOOP
            EXIT WHEN NOT (p_validation_tbl.EXISTS (l_val_tbl_idx));

            IF (p_validation_tbl (l_val_tbl_idx).asg_type = p_asg_type)
            THEN
               l_valid := TRUE;
               if g_debug then
               	       hr_utility.set_location ('   Valid Assignment!', 20);
               end if;
            END IF;

            l_val_tbl_idx := p_validation_tbl.NEXT (l_val_tbl_idx);
         END LOOP;
      ELSE -- no values in table passed means everything is valid
         l_valid := TRUE;
         if g_debug then
         	 hr_utility.set_location ('   Valid Assignment!', 30);
         end if;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 40);
      end if;
      RETURN l_valid;
   END valid_assignment_type;

   FUNCTION valid_assignment_system_status (
      p_asg_system_status   IN   per_assignment_status_types.per_system_status%TYPE,
      p_validation_tbl      IN   asg_system_status_table
   )
      RETURN BOOLEAN
   AS
      l_proc    proc_name;

      l_val_tbl_idx     PLS_INTEGER;
      l_valid           BOOLEAN     := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'valid_assignment_system_status';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (p_validation_tbl.COUNT <> 0) -- values passed, start comparing
      THEN
         l_val_tbl_idx := p_validation_tbl.FIRST;

         LOOP
            EXIT WHEN NOT (p_validation_tbl.EXISTS (l_val_tbl_idx));

            IF (p_validation_tbl (l_val_tbl_idx).asg_system_status =
                                                           p_asg_system_status
               )
            THEN
               l_valid := TRUE;
               if g_debug then
               	       hr_utility.set_location ('   Valid Assignment!', 20);
               end if;
            END IF;

            l_val_tbl_idx := p_validation_tbl.NEXT (l_val_tbl_idx);
         END LOOP;
      ELSE -- no values in table passed means everything is valid
         l_valid := TRUE;
         if g_debug then
         	 hr_utility.set_location ('   Valid Assignment!', 30);
         end if;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 40);
      end if;
      RETURN l_valid;
   END valid_assignment_system_status;

   FUNCTION primary_assignment_id (
      p_person_id                IN   per_people_f.person_id%TYPE,
      p_effective_date           IN   DATE,
      p_valid_asg_types          IN   asg_type_table,
      p_valid_asg_status_types   IN   asg_system_status_table
   )
      RETURN per_all_assignments_f.assignment_id%TYPE
   IS
      l_proc     proc_name  ;

      CURSOR csr_prim_asg (
         p_person_id              per_people_f.person_id%TYPE,
         p_asg_type_list          VARCHAR2,
         p_asg_system_type_list   VARCHAR2,
         p_effective_date         DATE
      )
      IS
         SELECT paf.assignment_id, paf.assignment_type,
                past.per_system_status, paf.effective_start_date,
                paf.effective_end_date
           FROM per_assignments_f paf, per_assignment_status_types past
          WHERE p_effective_date BETWEEN paf.effective_start_date
                                     AND paf.effective_end_date
            AND paf.primary_flag = c_primary_assignment
            AND paf.person_id = p_person_id
            AND (   INSTR (p_asg_type_list, paf.assignment_type) <> 0
                 OR LENGTH (p_asg_type_list) IS NULL -- if the list is empty ALL asg are valid
                )
            AND past.assignment_status_type_id = paf.assignment_status_type_id
            AND (   INSTR (p_asg_system_type_list, past.per_system_status) <>
                                                                             0
                 OR LENGTH (p_asg_system_type_list) IS NULL -- if the list is empty ALL asg are valid
                );

      l_rec_prim_asg     csr_prim_asg%ROWTYPE;
      l_prim_asg_id      per_all_assignments_f.assignment_id%TYPE   := NULL;
      l_found_in_cache   BOOLEAN                                    := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'primary_assignment_id';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF ((caching) AND (g_primary_assignments.EXISTS (p_person_id)))
      THEN
         IF (    (p_effective_date
                     BETWEEN g_primary_assignments (p_person_id).effective_start_date
                         AND g_primary_assignments (p_person_id).effective_end_date
                 )
             AND (valid_assignment_type (g_primary_assignments (p_person_id).assignment_type,
                                         p_valid_asg_types
                                        )
                 )
             AND (valid_assignment_system_status (g_primary_assignments (p_person_id
                                                                        ).per_system_status,
                                                  p_valid_asg_status_types
                                                 )
                 )
            )
         THEN
            l_prim_asg_id :=
                            g_primary_assignments (p_person_id).assignment_id;
            l_found_in_cache := TRUE;
         END IF;
      END IF;

      IF (NOT l_found_in_cache)
      THEN
         IF (csr_prim_asg%ISOPEN)
         THEN
            CLOSE csr_prim_asg;
         END IF;

         OPEN csr_prim_asg (p_person_id,
                            table_to_comma (p_valid_asg_types),
                            table_to_comma (p_valid_asg_status_types),
                            p_effective_date
                           );
         FETCH csr_prim_asg INTO l_rec_prim_asg;

         IF (csr_prim_asg%FOUND)
         THEN
            l_prim_asg_id := l_rec_prim_asg.assignment_id;

            IF (caching)
            THEN
               g_primary_assignments (p_person_id).assignment_id :=
                                                 l_rec_prim_asg.assignment_id;
               g_primary_assignments (p_person_id).effective_start_date :=
                                          l_rec_prim_asg.effective_start_date;
               g_primary_assignments (p_person_id).effective_end_date :=
                                            l_rec_prim_asg.effective_end_date;
               g_primary_assignments (p_person_id).assignment_type :=
                                               l_rec_prim_asg.assignment_type;
               g_primary_assignments (p_person_id).per_system_status :=
                                             l_rec_prim_asg.per_system_status;
            END IF;
         END IF;
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   returning '
				       || l_prim_asg_id, 20);
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN l_prim_asg_id;
   END primary_assignment_id;

   PROCEDURE get_assignment_info (
      p_assignment_id       IN              per_all_assignments_f.assignment_id%TYPE,
      p_effective_date      IN              per_all_assignments_f.effective_end_date%TYPE,
      p_assignment_number   OUT NOCOPY      per_all_assignments_f.assignment_number%TYPE,
      p_payroll_id          OUT NOCOPY      per_all_assignments_f.payroll_id%TYPE,
      p_org_id              OUT NOCOPY      per_all_assignments_f.organization_id%TYPE,
      p_location_id         OUT NOCOPY      per_all_assignments_f.location_id%TYPE,
      p_bg_id               OUT NOCOPY      per_all_assignments_f.business_group_id%TYPE
   )
   IS
      l_proc      proc_name     ;

      CURSOR csr_assignment_info (
         p_assignment_id    per_all_assignments_f.assignment_id%TYPE,
         p_effective_date   per_all_assignments_f.effective_end_date%TYPE
      )
      IS
         SELECT paaf.assignment_number, paaf.payroll_id, paaf.organization_id,
                paaf.location_id, paaf.business_group_id,
                paaf.assignment_type, paaf.effective_start_date,
                paaf.effective_end_date
           FROM per_all_assignments_f paaf
          WHERE paaf.assignment_id = p_assignment_id
            AND p_effective_date BETWEEN paaf.effective_start_date
                                     AND paaf.effective_end_date;

      l_assignment_info   csr_assignment_info%ROWTYPE;
      l_found_in_cache    BOOLEAN                       := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'get_assignment_info';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF ((caching) AND (g_assignment_info.EXISTS (p_assignment_id)))
      THEN
         IF ((p_effective_date
                 BETWEEN g_assignment_info (p_assignment_id).effective_start_date
                     AND g_assignment_info (p_assignment_id).effective_end_date
             )
            )
         THEN
            p_assignment_number :=
                        g_assignment_info (p_assignment_id).assignment_number;
            p_payroll_id := g_assignment_info (p_assignment_id).payroll_id;
            p_org_id := g_assignment_info (p_assignment_id).organization_id;
            p_location_id := g_assignment_info (p_assignment_id).location_id;
            p_bg_id := g_assignment_info (p_assignment_id).business_group_id;
            l_found_in_cache := TRUE;
         END IF;
      END IF;

      IF (NOT l_found_in_cache)
      THEN
         IF (csr_assignment_info%ISOPEN)
         THEN
            CLOSE csr_assignment_info;
         END IF;

         OPEN csr_assignment_info (p_assignment_id, p_effective_date);
         FETCH csr_assignment_info INTO l_assignment_info;

         IF (csr_assignment_info%FOUND)
         THEN
            p_assignment_number := l_assignment_info.assignment_number;
            p_payroll_id := l_assignment_info.payroll_id;
            p_org_id := l_assignment_info.organization_id;
            p_location_id := l_assignment_info.location_id;
            p_bg_id := l_assignment_info.business_group_id;

            IF (caching)
            THEN
               g_assignment_info (p_assignment_id).effective_start_date :=
                                       l_assignment_info.effective_start_date;
               g_assignment_info (p_assignment_id).effective_end_date :=
                                         l_assignment_info.effective_end_date;
               g_assignment_info (p_assignment_id).assignment_number :=
                                          l_assignment_info.assignment_number;
               g_assignment_info (p_assignment_id).payroll_id :=
                                                 l_assignment_info.payroll_id;
               g_assignment_info (p_assignment_id).organization_id :=
                                            l_assignment_info.organization_id;
               g_assignment_info (p_assignment_id).location_id :=
                                                l_assignment_info.location_id;
               g_assignment_info (p_assignment_id).business_group_id :=
                                          l_assignment_info.business_group_id;
            END IF;
         END IF;

         CLOSE csr_assignment_info;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END get_assignment_info;

   PROCEDURE get_primary_assignment_info (
      p_person_id           IN              per_all_assignments_f.person_id%TYPE,
      p_effective_date      IN              per_all_assignments_f.effective_end_date%TYPE,
      p_assignment_id       OUT NOCOPY      per_all_assignments_f.assignment_id%TYPE,
      p_assignment_number   OUT NOCOPY      per_all_assignments_f.assignment_number%TYPE,
      p_payroll_id          OUT NOCOPY      per_all_assignments_f.payroll_id%TYPE,
      p_org_id              OUT NOCOPY      per_all_assignments_f.organization_id%TYPE,
      p_location_id         OUT NOCOPY      per_all_assignments_f.location_id%TYPE,
      p_bg_id               OUT NOCOPY      per_all_assignments_f.business_group_id%TYPE
   )
   IS
      l_proc             proc_name;

      l_valid_asg_types          asg_type_table;
      l_valid_asg_status_types   asg_system_status_table;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'get_primary_assignment_info';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      l_valid_asg_types (1).asg_type := g_asg_type_employed;
      p_assignment_id :=
         primary_assignment_id (p_person_id                   => p_person_id,
                                p_effective_date              => p_effective_date,
                                p_valid_asg_types             => l_valid_asg_types,
                                p_valid_asg_status_types      => l_valid_asg_status_types
                               );
      get_assignment_info (p_assignment_id          => p_assignment_id,
                           p_effective_date         => p_effective_date,
                           p_assignment_number      => p_assignment_number,
                           p_payroll_id             => p_payroll_id,
                           p_org_id                 => p_org_id,
                           p_location_id            => p_location_id,
                           p_bg_id                  => p_bg_id
                          );
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END get_primary_assignment_info;

   FUNCTION is_assignment (
      p_tbb_rec   IN   hxc_generic_retrieval_pkg.r_building_blocks
   )
      RETURN BOOLEAN
   IS
      l_proc    proc_name ;
      l_is_assignment   BOOLEAN   := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'is_assignment';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (p_tbb_rec.resource_type = hxc_timecard.c_assignment_resource)
      THEN
         if g_debug then
         	 hr_utility.set_location ('   resource_type = ASSIGNMENT ', 20);
         end if;
         l_is_assignment := TRUE;
      ELSE
         l_is_assignment := FALSE;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_is_assignment;
   END is_assignment;

   FUNCTION is_person (p_tbb_rec IN hxc_generic_retrieval_pkg.r_building_blocks)
      RETURN BOOLEAN
   IS
      l_proc    proc_name ;
      l_is_person       BOOLEAN   := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'is_person';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (p_tbb_rec.resource_type = hxc_timecard.c_person_resource)
      THEN
         if g_debug then
         	 hr_utility.set_location ('   resource_type = PERSON ', 20);
         end if;
         l_is_person := TRUE;
      ELSE
         l_is_person := FALSE;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_is_person;
   END is_person;

   PROCEDURE assignment_info (
      p_tbb_rec             IN              hxc_generic_retrieval_pkg.r_building_blocks,
      p_assignment_id       OUT NOCOPY      per_all_assignments_f.assignment_id%TYPE,
      p_assignment_number   OUT NOCOPY      per_all_assignments_f.assignment_number%TYPE
   )
   AS
      l_proc    proc_name  ;
      l_payroll_id      per_all_assignments_f.payroll_id%TYPE;
      l_org_id          per_all_assignments_f.organization_id%TYPE;
      l_location_id     per_all_assignments_f.location_id%TYPE;
      l_bg_id           per_all_assignments_f.business_group_id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'assignment_info';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (is_assignment (p_tbb_rec))
      THEN
         p_assignment_id := p_tbb_rec.resource_id;
      /* Overkill as we are not using any of the other variables yet
      get_assignment_info (
         p_assignment_id=> p_tbb_rec.resource_id,
         p_effective_date=> TRUNC (p_tbb_rec.start_time),
         p_assignment_number=> p_assignment_number,
         p_payroll_id=> l_payroll_id,
         p_org_id=> l_org_id,
         p_location_id=> l_location_id,
         p_bg_id=> l_bg_id
      ); */
      ELSIF (is_person (p_tbb_rec))
      THEN
         get_primary_assignment_info (p_person_id              => p_tbb_rec.resource_id,
                                      p_effective_date         => TRUNC (p_tbb_rec.start_time
                                                                        ),
                                      p_assignment_id          => p_assignment_id,
                                      p_assignment_number      => p_assignment_number,
                                      p_payroll_id             => l_payroll_id,
                                      p_org_id                 => l_org_id,
                                      p_location_id            => l_location_id,
                                      p_bg_id                  => l_bg_id
                                     );
      ELSE
         NULL; -- unsupported resource_type!
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   OUT p_assignment_id     = '
				       || p_assignment_id,
				       20
				      );
	      hr_utility.set_location (   '   OUT p_assignment_number = '
				       || p_assignment_number,
				       30
				      );
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
   END assignment_info;

   FUNCTION attribute_is (
      p_attr_rec         IN   hxc_generic_retrieval_pkg.r_time_attributes,
      p_is_what          IN   hxc_mapping_components.field_name%TYPE,
      p_case_sensitive   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN BOOLEAN
   IS
      l_proc    proc_name ;
      l_it_is           BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'attribute_is';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (p_case_sensitive)
      THEN
         IF (p_attr_rec.field_name LIKE p_is_what)
         THEN
            if g_debug then
		    hr_utility.set_location (   '   (Case Sensitive) Attribute is '
					     || p_is_what,
					     20
					    );
            end if;
            l_it_is := TRUE;
         ELSE
            l_it_is := FALSE;
         END IF;
      ELSE
         IF (UPPER (p_attr_rec.field_name) LIKE UPPER (p_is_what))
         THEN
            if g_debug then
		    hr_utility.set_location (   '   (Case In-sensitive) Attribute is '
					     || p_is_what,
					     30
					    );
            end if;
            l_it_is := TRUE;
         ELSE
            l_it_is := FALSE;
         END IF;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_it_is;
   END attribute_is;

   FUNCTION attribute_is_element (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN BOOLEAN
   IS
      l_proc    proc_name ;
      l_element         BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'attribute_is_element';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_element :=
         attribute_is (p_attr_rec      => p_attr_rec,
                       p_is_what       => g_element_attribute
                      );
      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_element;
   END attribute_is_element;

   FUNCTION attribute_is_cost_segment (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN BOOLEAN
   IS
      l_proc    proc_name ;
      l_cost_segment    BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'attribute_is_cost_segment';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_cost_segment :=
         attribute_is (p_attr_rec      => p_attr_rec,
                       p_is_what       =>    g_cost_attribute
                                          || g_wildcard
                      );
      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_cost_segment;
   END attribute_is_cost_segment;

   FUNCTION attribute_is_input_value (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN BOOLEAN
   IS
      l_proc    proc_name ;
      l_input_value     BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'attribute_is_input_value';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_input_value :=
         attribute_is (p_attr_rec      => p_attr_rec,
                       p_is_what       =>    g_iv_attribute
                                          || g_wildcard
                      );
      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_input_value;
   END attribute_is_input_value;

   FUNCTION attribute_is_asg_id (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN BOOLEAN
   IS
      l_proc    proc_name ;
      l_asg_id          BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'attribute_is_asg_id';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_asg_id :=
         attribute_is (p_attr_rec      => p_attr_rec,
                       p_is_what       => g_asg_id_attribute
                      );
      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_asg_id;
   END attribute_is_asg_id;

   FUNCTION attribute_is_asg_num (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN BOOLEAN
   IS
      l_proc    proc_name ;
      l_asg_num         BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'attribute_is_asg_num';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_asg_num :=
         attribute_is (p_attr_rec      => p_attr_rec,
                       p_is_what       => g_asg_num_attribute
                      );
      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_asg_num;
   END attribute_is_asg_num;

   FUNCTION extract_number (
      p_extract_from     IN   max_varchar,
      p_sub_string       IN   max_varchar,
      p_case_sensitive   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN PLS_INTEGER
   IS
      l_proc    proc_name     ;
      l_char_number     VARCHAR2 (30);
      l_number          PLS_INTEGER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                               || 'extract_number';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (p_case_sensitive)
      THEN
         l_char_number := REPLACE (p_extract_from, p_sub_string);
      ELSE
         l_char_number :=
                       REPLACE (UPPER (p_extract_from), UPPER (p_sub_string));
      END IF;

      IF isnumber (l_char_number)
      THEN
         l_number := TO_NUMBER (l_char_number);
      ELSE
         l_number := NULL;
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   Returning '
				       || l_number, 20);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 30);
      end if;
      RETURN l_number;
   END extract_number;

   FUNCTION cost_segment_number (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN PLS_INTEGER
   IS
      l_proc               proc_name;

      l_char_cost_segment_number   VARCHAR2 (30);
      l_cost_segment_number        PLS_INTEGER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'cost_segment_number';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_cost_segment_number :=
         extract_number (p_extract_from      => p_attr_rec.field_name,
                         p_sub_string        => g_cost_attribute
                        );
      if g_debug then
	      hr_utility.set_location (   '   Returning '
				       || l_cost_segment_number, 20);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 30);
      end if;
      RETURN l_cost_segment_number;
   END cost_segment_number;

   FUNCTION input_value_number (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN PLS_INTEGER
   IS
      l_proc              proc_name;

      l_char_input_value_number   VARCHAR2 (30);
      l_input_value_number        PLS_INTEGER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'input_value_number';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_input_value_number :=
         extract_number (p_extract_from      => p_attr_rec.field_name,
                         p_sub_string        => g_iv_attribute
                        );
      if g_debug then
	      hr_utility.set_location (   '   Returning '
				       || l_input_value_number, 20);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 30);
      end if;
      RETURN l_input_value_number;
   END input_value_number;

   FUNCTION element_type_id (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN pay_element_types_f.element_type_id%TYPE
   IS
      l_proc           proc_name    ;
      l_char_element_type_id   VARCHAR2 (30);
      l_element_type_id        pay_element_types_f.element_type_id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                               || 'element_type_id';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_char_element_type_id :=
                  REPLACE (UPPER (p_attr_rec.VALUE), c_element_context_prefix);

      IF (isnumber (l_char_element_type_id))
      THEN
         l_element_type_id := TO_NUMBER (l_char_element_type_id);
      ELSE
         l_element_type_id := NULL;
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   Returning '
				       || l_element_type_id, 20);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 30);
      end if;
      RETURN l_element_type_id;
   END element_type_id;

   FUNCTION element_flex_context_code (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE
   )
      RETURN fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE
   IS
      l_proc                proc_name;

      l_element_flex_context_code   fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'element_flex_context_code';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (p_element_type_id IS NOT NULL)
      THEN
         l_element_flex_context_code :=
                                    c_element_context_prefix
                                 || p_element_type_id;
      ELSE
         l_element_flex_context_code := NULL;
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   Returning '
				       || l_element_flex_context_code,
				       20
				      );
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 30);
      end if;
      RETURN l_element_flex_context_code;
   END element_flex_context_code;

   FUNCTION element_name (
      p_ele_type_id      IN   pay_element_types_f.element_type_id%TYPE,
      p_effective_date   IN   pay_element_types_f.effective_start_date%TYPE
   )
      RETURN pay_element_types_f.element_name%TYPE
   IS
      l_proc    proc_name ;
      CURSOR csr_element_name (
         p_ele_type_id      pay_element_types_f.element_type_id%TYPE,
         p_effective_date   pay_element_types_f.effective_start_date%TYPE
      )
      IS
         SELECT petft.element_name
           FROM pay_element_types_f petf, pay_element_types_f_tl petft
          WHERE petf.element_type_id = p_ele_type_id
            AND petft.element_type_id = petf.element_type_id
            AND USERENV ('LANG') = petft.LANGUAGE
            AND p_effective_date BETWEEN petf.effective_start_date
                                     AND petf.effective_end_date;
      l_element_name    pay_element_types_f.element_name%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'element_name';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      OPEN csr_element_name (p_ele_type_id, p_effective_date);
      FETCH csr_element_name INTO l_element_name;
      CLOSE csr_element_name;
      if g_debug then
	      hr_utility.set_location (   '   Returning '
				       || l_element_name, 20);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 30);
      end if;
      RETURN l_element_name;
   END element_name;


   FUNCTION hours_worked (
      p_detail_tbb   IN   hxc_generic_retrieval_pkg.r_building_blocks
   )
      RETURN NUMBER
   AS
      l_proc    proc_name ;
      l_hours_worked    NUMBER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'hours_worked';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (p_detail_tbb.TYPE = hxc_timecard.c_measure_type)
      THEN
         l_hours_worked := p_detail_tbb.measure;
      ELSE
         l_hours_worked :=
                         (  p_detail_tbb.stop_time
                          - p_detail_tbb.start_time
                         )
                       * 24;
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   Returning '
				       || l_hours_worked, 20);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 30);
      end if;
      RETURN l_hours_worked;
   END hours_worked;

   FUNCTION element_type_ivs (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE,
      p_effective_date    IN   pay_element_types_f.effective_start_date%TYPE
   )
      RETURN input_value_name_table
   AS
      l_proc       proc_name  ;

      CURSOR csr_element_type_ivs (
         p_element_type_id   pay_element_types_f.element_type_id%TYPE,
         p_effective_date    pay_element_types_f.effective_start_date%TYPE
      )
      IS
         SELECT   piv.NAME
             FROM pay_input_values_f piv
            WHERE piv.element_type_id = p_element_type_id
              AND p_effective_date BETWEEN piv.effective_start_date
                                       AND piv.effective_end_date
         ORDER BY piv.display_sequence, piv.NAME;

      l_element_type_ivs   input_value_name_table;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'element_type_ivs';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (p_element_type_id = current_element)
      THEN
         if g_debug then
         	 hr_utility.set_location ('   retrieving from cache', 20);
         end if;
         l_element_type_ivs := g_element_type_ivs;
      ELSE
         if g_debug then
         	 hr_utility.set_location ('   retrieving from DB', 30);
         end if;

         IF (csr_element_type_ivs%ISOPEN)
         THEN
            CLOSE csr_element_type_ivs;
         END IF;

         OPEN csr_element_type_ivs (p_element_type_id, p_effective_date);
         FETCH csr_element_type_ivs BULK COLLECT INTO l_element_type_ivs;
         CLOSE csr_element_type_ivs;
         g_element_type_ivs := l_element_type_ivs;
         set_current_element (p_element_type_id);
      END IF;

      if g_debug then
 	      hr_utility.set_location (   '   returning # IVs'
				       || l_element_type_ivs.COUNT,
				       40
				      );
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_element_type_ivs;
   END element_type_ivs;

   FUNCTION ddf_input_value_name (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE,
      p_attr_rec          IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN fnd_descr_flex_column_usages.end_user_column_name%TYPE
   AS
      l_proc           proc_name;


      CURSOR csr_ddf_input_value_name (
         p_context      fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE,
         p_field_name   hxc_mapping_components.field_name%TYPE
      )
      IS
         SELECT fdfcu.end_user_column_name
           FROM fnd_descr_flex_column_usages fdfcu,
                hxc_mapping_components mpc
          WHERE fdfcu.application_id = g_hxc_app_id
            AND fdfcu.descriptive_flexfield_name = g_otl_info_types_ddf
            AND fdfcu.descriptive_flex_context_code = p_context
            AND fdfcu.application_column_name = mpc.SEGMENT
            AND UPPER (mpc.field_name) = UPPER (p_field_name);

      l_ddf_input_value_name   fnd_descr_flex_column_usages.end_user_column_name%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'ddf_input_value_name';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
	      hr_utility.set_location (   '   IN p_element_type_id '
				       || p_element_type_id,
				       20
				      );
	      hr_utility.set_location (   '   IN p_attr_rec.field_name '
				       || p_attr_rec.field_name,
				       30
				      );
      end if;
      IF (csr_ddf_input_value_name%ISOPEN)
      THEN
         CLOSE csr_ddf_input_value_name;
      END IF;

      OPEN csr_ddf_input_value_name (element_flex_context_code (p_element_type_id
                                                               ),
                                     p_attr_rec.field_name
                                    );
      FETCH csr_ddf_input_value_name INTO l_ddf_input_value_name;
      CLOSE csr_ddf_input_value_name;
      if g_debug then
	      hr_utility.set_location (   '   returning '
				       || l_ddf_input_value_name, 100);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 110);
      end if;
      RETURN l_ddf_input_value_name;
   END ddf_input_value_name;

   FUNCTION accr_plan_added_date_ivs (
      p_accrual_plan_id   IN   pay_accrual_plans.accrual_plan_id%TYPE,
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE,
      p_effective_date    IN   pay_element_types_f.effective_start_date%TYPE
   )
      RETURN input_value_name_table
   AS
      l_proc       proc_name ;

      -- This cursor returns IVs of an element that have been ADDED to the
      -- net calculation rules of an accrual plan as Date Input Values.  It
      -- ignores the 2 net calculation rules (one Substract and one Add) that
      -- get created automatically when submitting the Accrual Plan. It can do
      -- this because these 2 IVs IDs get denormalized on the Accrual Plan table
      -- as pto_input_value_id (Substract) and co_input_value_id (Add). Probably
      -- The pto_input_value_id can even be ignored as it never seems to have a
      -- Date Input Value, so that will get filtered anyway by
      -- pncr.date_input_value_id = piv.input_value_id, but I will leave it for
      -- now.
      CURSOR csr_accrual_plan_ivs (
         p_accrual_plan_id   pay_accrual_plans.accrual_plan_id%TYPE,
         p_effective_date    pay_element_types_f.effective_start_date%TYPE,
         p_element_type_id   pay_element_types_f.element_type_id%TYPE
      )
      IS
         SELECT DISTINCT piv.NAME
                    FROM pay_input_values_f piv,
                         pay_accrual_plans pap,
                         pay_net_calculation_rules pncr
                   WHERE piv.element_type_id = p_element_type_id
                     AND p_effective_date BETWEEN piv.effective_start_date
                                              AND piv.effective_end_date
                     AND pncr.date_input_value_id = piv.input_value_id
                     AND pncr.input_value_id <> pap.pto_input_value_id
                     AND pncr.input_value_id <> pap.co_input_value_id
                     AND pncr.accrual_plan_id = pap.accrual_plan_id
                     AND pap.accrual_plan_id = p_accrual_plan_id;

      l_accrual_plan_ivs   input_value_name_table;
   BEGIN

      if g_debug then
	      l_proc :=    g_package
                              || 'accrual_plan_added_ivs';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (csr_accrual_plan_ivs%ISOPEN)
      THEN
         CLOSE csr_accrual_plan_ivs;
      END IF;

      OPEN csr_accrual_plan_ivs (p_accrual_plan_id,
                                 p_effective_date,
                                 p_element_type_id
                                );
      FETCH csr_accrual_plan_ivs BULK COLLECT INTO l_accrual_plan_ivs;
      CLOSE csr_accrual_plan_ivs;
      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_accrual_plan_ivs;
   END accr_plan_added_date_ivs;

   FUNCTION accrual_plan_ids (
      p_assignment_id    IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date   IN   pay_element_types_f.effective_start_date%TYPE
   )
      RETURN accrual_plan_id_table
   AS
      l_proc       proc_name  ;

      CURSOR csr_accrual_plan_ids (
         p_assignment_id    per_all_assignments_f.assignment_id%TYPE,
         p_effective_date   pay_element_types_f.effective_start_date%TYPE
      )
      IS
         SELECT   pap.accrual_plan_id
             FROM pay_accrual_plans pap,
                  pay_element_links_f pelf,
                  pay_element_entries_f peef
            WHERE pelf.element_type_id = pap.accrual_plan_element_type_id
              AND p_effective_date BETWEEN pelf.effective_start_date
                                       AND pelf.effective_end_date
              AND peef.element_link_id = pelf.element_link_id
              AND peef.assignment_id = p_assignment_id
              AND p_effective_date BETWEEN peef.effective_start_date
                                       AND peef.effective_end_date
         ORDER BY accrual_plan_id;

      l_accrual_plan_ids   accrual_plan_id_table;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'accrual_plan_ids';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (csr_accrual_plan_ids%ISOPEN)
      THEN
         CLOSE csr_accrual_plan_ids;
      END IF;

      OPEN csr_accrual_plan_ids (p_assignment_id, p_effective_date);
      FETCH csr_accrual_plan_ids BULK COLLECT INTO l_accrual_plan_ids;
      CLOSE csr_accrual_plan_ids;
      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_accrual_plan_ids;
   END accrual_plan_ids;

   FUNCTION accrual_plan_exists (
      p_assignment_id     IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date    IN   pay_element_types_f.effective_start_date%TYPE,
      p_accrual_plan_id   IN   pay_accrual_plans.accrual_plan_id%TYPE
   )
      RETURN BOOLEAN
   AS
      l_proc          proc_name ;
      l_accrual_plan_ids      accrual_plan_id_table;
      l_accrual_plan_index    PLS_INTEGER;
      l_accrual_plan_exists   BOOLEAN               := FALSE;
   BEGIN

      if g_debug then
	      l_proc :=    g_package
                              || 'accrual_plan_exists';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_accrual_plan_ids :=
         accrual_plan_ids (p_assignment_id       => p_assignment_id,
                           p_effective_date      => p_effective_date
                          );
      l_accrual_plan_index := l_accrual_plan_ids.FIRST;

      LOOP
         EXIT WHEN (   NOT (l_accrual_plan_ids.EXISTS (l_accrual_plan_index))
                    OR (l_accrual_plan_exists)
                   );

         IF (l_accrual_plan_ids (l_accrual_plan_index) = p_accrual_plan_id)
         THEN
            if g_debug then
		    hr_utility.set_location (   '   Accrual Plan exists'
					     || l_proc, 20);
            end if;
            l_accrual_plan_exists := TRUE;
         END IF;

         l_accrual_plan_index :=
                                l_accrual_plan_ids.NEXT (l_accrual_plan_index);
      END LOOP;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_accrual_plan_exists;
   END accrual_plan_exists;

   PROCEDURE assign_iv (
      p_iv_seq    IN              NUMBER,
      p_value     IN              VARCHAR2,
      p_bee_rec   IN OUT NOCOPY   bee_rec
   )
   AS
   BEGIN
      IF (p_iv_seq = 1)
      THEN
         p_bee_rec.pay_batch_line.value_1 := p_value;
      ELSIF (p_iv_seq = 2)
      THEN
         p_bee_rec.pay_batch_line.value_2 := p_value;
      ELSIF (p_iv_seq = 3)
      THEN
         p_bee_rec.pay_batch_line.value_3 := p_value;
      ELSIF (p_iv_seq = 4)
      THEN
         p_bee_rec.pay_batch_line.value_4 := p_value;
      ELSIF (p_iv_seq = 5)
      THEN
         p_bee_rec.pay_batch_line.value_5 := p_value;
      ELSIF (p_iv_seq = 6)
      THEN
         p_bee_rec.pay_batch_line.value_6 := p_value;
      ELSIF (p_iv_seq = 7)
      THEN
         p_bee_rec.pay_batch_line.value_7 := p_value;
      ELSIF (p_iv_seq = 8)
      THEN
         p_bee_rec.pay_batch_line.value_8 := p_value;
      ELSIF (p_iv_seq = 9)
      THEN
         p_bee_rec.pay_batch_line.value_9 := p_value;
      ELSIF (p_iv_seq = 10)
      THEN
         p_bee_rec.pay_batch_line.value_10 := p_value;
      ELSIF (p_iv_seq = 11)
      THEN
         p_bee_rec.pay_batch_line.value_11 := p_value;
      ELSIF (p_iv_seq = 12)
      THEN
         p_bee_rec.pay_batch_line.value_12 := p_value;
      ELSIF (p_iv_seq = 13)
      THEN
         p_bee_rec.pay_batch_line.value_13 := p_value;
      ELSIF (p_iv_seq = 14)
      THEN
         p_bee_rec.pay_batch_line.value_14 := p_value;
      ELSIF (p_iv_seq = 15)
      THEN
         p_bee_rec.pay_batch_line.value_15 := p_value;
      END IF;
   END assign_iv;

   PROCEDURE convert_attr_to_ivs (
      p_attr_rec          IN              hxc_generic_retrieval_pkg.r_time_attributes,
      p_element_type_id   IN              pay_element_types_f.element_type_id%TYPE,
      p_effective_date    IN              pay_element_types_f.effective_start_date%TYPE,
      p_bee_rec           IN OUT NOCOPY   bee_rec
   )
   AS
      l_proc    proc_name       ;
      l_iv_table        input_value_name_table;
      l_iv_tbl_idx      PLS_INTEGER;
      l_ddf_iv_name     fnd_descr_flex_column_usages.end_user_column_name%TYPE;
      l_iv_found        BOOLEAN                                       := FALSE;
      l_iv_seq          PLS_INTEGER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'convert_attr_to_ivs';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (attribute_is_input_value (p_attr_rec))
      THEN
         l_ddf_iv_name :=
            ddf_input_value_name (p_attr_rec             => p_attr_rec,
                                  p_element_type_id      => p_element_type_id
                                 );
         l_iv_table :=
            element_type_ivs (p_element_type_id      => p_element_type_id,
                              p_effective_date       => p_effective_date
                             );
         l_iv_tbl_idx := l_iv_table.FIRST;

         <<compare_ivs>>
         LOOP
            EXIT compare_ivs WHEN (   (NOT l_iv_table.EXISTS (l_iv_tbl_idx))
                                   OR (l_iv_found)
                                  );

            IF (l_iv_table (l_iv_tbl_idx) = l_ddf_iv_name)
            THEN
               if g_debug then
		       hr_utility.set_location (   '   iv found, seq = '
						|| l_iv_tbl_idx,
						20
					       );
               end if;
               l_iv_found := TRUE;
               l_iv_seq := l_iv_tbl_idx;
            END IF;

            l_iv_tbl_idx := l_iv_table.NEXT (l_iv_tbl_idx);
         END LOOP compare_ivs;

         IF (l_iv_found)
         THEN
            assign_iv (p_iv_seq       => l_iv_seq,
                       p_value        => p_attr_rec.VALUE,
                       p_bee_rec      => p_bee_rec
                      );
         END IF;
      ELSE
         NULL; -- Error, you should not have called this procedure
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
   END convert_attr_to_ivs;

   PROCEDURE convert_attr_to_costsegment (
      p_attr_rec       IN              hxc_generic_retrieval_pkg.r_time_attributes,
      p_cost_flex_id   IN              per_business_groups_perf.cost_allocation_structure%TYPE,
      p_bee_rec        IN OUT NOCOPY   bee_rec
   )
   AS
      l_proc          proc_name;

      l_cost_segment_number   PLS_INTEGER;
      l_value                 pay_batch_lines.segment1%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'convert_attr_to_costsegment';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (attribute_is_cost_segment (p_attr_rec))
      THEN
         l_cost_segment_number := cost_segment_number (p_attr_rec);
         l_value :=
            costflex_value (p_id_flex_num        => p_cost_flex_id,
                            p_segment_name       =>    g_segment
                                                    || l_cost_segment_number,
                            p_flex_value_id      => p_attr_rec.VALUE
                           );

         IF (l_cost_segment_number = 1)
         THEN
            p_bee_rec.pay_batch_line.segment1 := l_value;
         ELSIF (l_cost_segment_number = 2)
         THEN
            p_bee_rec.pay_batch_line.segment2 := l_value;
         ELSIF (l_cost_segment_number = 3)
         THEN
            p_bee_rec.pay_batch_line.segment3 := l_value;
         ELSIF (l_cost_segment_number = 4)
         THEN
            p_bee_rec.pay_batch_line.segment4 := l_value;
         ELSIF (l_cost_segment_number = 5)
         THEN
            p_bee_rec.pay_batch_line.segment5 := l_value;
         ELSIF (l_cost_segment_number = 6)
         THEN
            p_bee_rec.pay_batch_line.segment6 := l_value;
         ELSIF (l_cost_segment_number = 7)
         THEN
            p_bee_rec.pay_batch_line.segment7 := l_value;
         ELSIF (l_cost_segment_number = 8)
         THEN
            p_bee_rec.pay_batch_line.segment8 := l_value;
         ELSIF (l_cost_segment_number = 9)
         THEN
            p_bee_rec.pay_batch_line.segment9 := l_value;
         ELSIF (l_cost_segment_number = 10)
         THEN
            p_bee_rec.pay_batch_line.segment10 := l_value;
         ELSIF (l_cost_segment_number = 11)
         THEN
            p_bee_rec.pay_batch_line.segment11 := l_value;
         ELSIF (l_cost_segment_number = 12)
         THEN
            p_bee_rec.pay_batch_line.segment12 := l_value;
         ELSIF (l_cost_segment_number = 13)
         THEN
            p_bee_rec.pay_batch_line.segment13 := l_value;
         ELSIF (l_cost_segment_number = 14)
         THEN
            p_bee_rec.pay_batch_line.segment14 := l_value;
         ELSIF (l_cost_segment_number = 15)
         THEN
            p_bee_rec.pay_batch_line.segment15 := l_value;
         ELSIF (l_cost_segment_number = 16)
         THEN
            p_bee_rec.pay_batch_line.segment16 := l_value;
         ELSIF (l_cost_segment_number = 17)
         THEN
            p_bee_rec.pay_batch_line.segment17 := l_value;
         ELSIF (l_cost_segment_number = 18)
         THEN
            p_bee_rec.pay_batch_line.segment18 := l_value;
         ELSIF (l_cost_segment_number = 19)
         THEN
            p_bee_rec.pay_batch_line.segment19 := l_value;
         ELSIF (l_cost_segment_number = 20)
         THEN
            p_bee_rec.pay_batch_line.segment20 := l_value;
         ELSIF (l_cost_segment_number = 21)
         THEN
            p_bee_rec.pay_batch_line.segment21 := l_value;
         ELSIF (l_cost_segment_number = 22)
         THEN
            p_bee_rec.pay_batch_line.segment22 := l_value;
         ELSIF (l_cost_segment_number = 23)
         THEN
            p_bee_rec.pay_batch_line.segment23 := l_value;
         ELSIF (l_cost_segment_number = 24)
         THEN
            p_bee_rec.pay_batch_line.segment24 := l_value;
         ELSIF (l_cost_segment_number = 25)
         THEN
            p_bee_rec.pay_batch_line.segment25 := l_value;
         ELSIF (l_cost_segment_number = 26)
         THEN
            p_bee_rec.pay_batch_line.segment26 := l_value;
         ELSIF (l_cost_segment_number = 27)
         THEN
            p_bee_rec.pay_batch_line.segment27 := l_value;
         ELSIF (l_cost_segment_number = 28)
         THEN
            p_bee_rec.pay_batch_line.segment28 := l_value;
         ELSIF (l_cost_segment_number = 29)
         THEN
            p_bee_rec.pay_batch_line.segment29 := l_value;
         ELSIF (l_cost_segment_number = 30)
         THEN
            p_bee_rec.pay_batch_line.segment30 := l_value;
         END IF;
      ELSE
         NULL; -- you should not have called this procedure
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
   END convert_attr_to_costsegment;

   FUNCTION translated_iv (
      p_iv_name       IN   hr_lookups.meaning%TYPE,
      p_date_active   IN   hr_lookups.start_date_active%TYPE
   )
      RETURN hr_lookups.lookup_code%TYPE
   IS
      l_proc      proc_name ;

      CURSOR csr_translated_info (
         p_meaning       hr_lookups.meaning%TYPE,
         p_date_active   hr_lookups.start_date_active%TYPE
      )
      IS
         SELECT lookup_code, start_date_active, end_date_active
           FROM hr_lookups
          WHERE meaning = p_meaning
            AND lookup_type = g_element_iv_translations
            AND application_id = g_per_app_id
            AND enabled_flag = g_lookup_enabled
            AND p_date_active BETWEEN NVL (start_date_active, p_date_active)
                                  AND NVL (end_date_active, p_date_active);

      l_translated_info   csr_translated_info%ROWTYPE;
      l_translated_iv     hr_lookups.lookup_code%TYPE;
      l_hashed_id         PLS_INTEGER;
      l_found_in_cache    BOOLEAN                       := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc  :=    g_package
                                || 'translated_iv';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_hashed_id := hashval (p_iv_name);

      IF ((caching) AND (g_iv_translations.EXISTS (l_hashed_id)))
      THEN
         IF (p_date_active
                BETWEEN NVL (g_iv_translations (l_hashed_id).start_date_active,
                             p_date_active
                            )
                    AND NVL (g_iv_translations (l_hashed_id).end_date_active,
                             p_date_active
                            )
            )
         THEN
            l_translated_iv := g_iv_translations (l_hashed_id).lookup_code;
            l_found_in_cache := TRUE;
         END IF;
      END IF;

      IF (NOT l_found_in_cache)
      THEN
         IF (csr_translated_info%ISOPEN)
         THEN
            CLOSE csr_translated_info;
         END IF;

         OPEN csr_translated_info (p_iv_name, p_date_active);
         FETCH csr_translated_info INTO l_translated_info;

         IF (csr_translated_info%FOUND)
         THEN
            l_translated_iv := l_translated_info.lookup_code;

            IF (caching)
            THEN
               g_iv_translations (l_hashed_id).lookup_code :=
                                                l_translated_info.lookup_code;
               g_iv_translations (l_hashed_id).start_date_active :=
                                          l_translated_info.start_date_active;
               g_iv_translations (l_hashed_id).end_date_active :=
                                            l_translated_info.end_date_active;
            END IF;
         END IF;

         CLOSE csr_translated_info;
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   returning '
				       || l_translated_iv, 20);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_translated_iv;
   END translated_iv;



   PROCEDURE hours_iv_position (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE,
      p_effective_date    IN   pay_element_types_f.effective_start_date%TYPE,
      p_hours_iv_position OUT NOCOPY PLS_INTEGER,
      p_jurisdiction_iv_position OUT NOCOPY PLS_INTEGER,
      p_iv_type           IN VARCHAR2
   )
   AS
      l_proc        proc_name     ;
      l_iv_table            input_value_name_table;
      l_hours_found         BOOLEAN                := FALSE;
      l_jurisdiction_found  BOOLEAN                := FALSE;
      l_iv_tbl_idx          PLS_INTEGER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'hours_iv_position';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      p_hours_iv_position := NULL;
      p_jurisdiction_iv_position := NULL;


      l_iv_table :=
         element_type_ivs (p_element_type_id      => p_element_type_id,
                           p_effective_date       => p_effective_date
                          );
      l_iv_tbl_idx := l_iv_table.FIRST;

      IF(p_iv_type = g_hours_iv) THEN

	      <<find_hours_iv>>
	      LOOP
		 EXIT find_hours_iv WHEN (   (NOT l_iv_table.EXISTS (l_iv_tbl_idx))
					  OR (l_hours_found)
					 );
                 if g_debug then
                 	 hr_utility.trace('in find_hours_iv');
                 end if;
		 IF (translated_iv (p_iv_name          => l_iv_table (l_iv_tbl_idx),
				    p_date_active      => p_effective_date
				   ) = g_hours_iv
		    )
		 THEN
                    if g_debug then
			    hr_utility.set_location (   '   "HOURS" IV found, seq = '
						     || l_iv_tbl_idx,
						     20
						    );
		    end if;
		    l_hours_found := TRUE;
		    p_hours_iv_position := l_iv_tbl_idx;
		 END IF;

		 l_iv_tbl_idx := l_iv_table.NEXT (l_iv_tbl_idx);
	      END LOOP find_hours_iv;

      ELSIF(p_iv_type = g_jurisdiction_iv)THEN

	      <<find_jurisdiction_iv>>
	      LOOP
		 EXIT find_jurisdiction_iv WHEN (   (NOT l_iv_table.EXISTS (l_iv_tbl_idx))
					  OR (l_jurisdiction_found)
					 );
                 if g_debug then
                 	 hr_utility.trace('find_jurisdiction_iv');
                 end if;
		 IF (translated_iv (p_iv_name          => l_iv_table (l_iv_tbl_idx),
				    p_date_active      => p_effective_date
				   ) = g_jurisdiction_iv
		    )
		 THEN
                    if g_debug then
			    hr_utility.set_location (   '   "HOURS" IV found, seq = '
						     || l_iv_tbl_idx,
						     20
						    );
                    end if;
		    l_jurisdiction_found := TRUE;
		    p_jurisdiction_iv_position := l_iv_tbl_idx;
		 END IF;

		 l_iv_tbl_idx := l_iv_table.NEXT (l_iv_tbl_idx);
	      END LOOP find_jurisdiction_iv;

       ELSIF(p_iv_type = g_hour_juris_iv)THEN

		<<find_hours_juris_iv>>
	      LOOP
		 EXIT find_hours_juris_iv WHEN (   (NOT l_iv_table.EXISTS (l_iv_tbl_idx))
					  OR (l_hours_found AND l_jurisdiction_found)
					 );
                 if g_debug then
                 	 hr_utility.trace('find_hours_juris_iv');
                 end if;
		 IF (translated_iv (p_iv_name          => l_iv_table (l_iv_tbl_idx),
				    p_date_active      => p_effective_date
				   ) = g_hours_iv
		    )
		 THEN
                    if g_debug then
			    hr_utility.set_location (   '   "HOURS" IV found, seq = '
						     || l_iv_tbl_idx,
						     20
						    );
                    end if;
		    l_hours_found := TRUE;
		    p_hours_iv_position := l_iv_tbl_idx;
		 END IF;

		 IF (translated_iv (p_iv_name          => l_iv_table (l_iv_tbl_idx),
				    p_date_active      => p_effective_date
				   ) = g_jurisdiction_iv
		    )
		 THEN
                    if g_debug then
			    hr_utility.set_location (   '   "HOURS" IV found, seq = '
						     || l_iv_tbl_idx,
						     20
						    );
                    end if;
		    l_jurisdiction_found := TRUE;
		    p_jurisdiction_iv_position := l_iv_tbl_idx;
		 END IF;

		 l_iv_tbl_idx := l_iv_table.NEXT (l_iv_tbl_idx);
	      END LOOP find_hours_juris_iv;
       END IF;


    if g_debug then
	    --  hr_utility.set_location (   '   returning '
	      --                         || p_jurisdiction_iv_position, 20);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
    end if;
   END hours_iv_position;


   FUNCTION find_element_id_in_attr_tbl (
      p_att_table        IN   hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id           IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_start_position   IN   PLS_INTEGER
   )
      RETURN pay_element_types_f.element_type_id%TYPE
   AS
      l_proc       proc_name;

      l_att_idx            PLS_INTEGER
                                  := NVL (p_start_position, p_att_table.FIRST);
      l_element_id_found   BOOLEAN                                    := FALSE;
      l_element_type_id    pay_element_types_f.element_type_id%TYPE   := NULL;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'find_element_id_in_attr_tbl';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      LOOP
         EXIT WHEN (   NOT p_att_table.EXISTS (l_att_idx)
                    OR (p_att_table (l_att_idx).bb_id <> p_tbb_id)
                    OR (l_element_id_found)
                   );

         IF (attribute_is_element (p_att_table (l_att_idx)))
         THEN
            l_element_type_id := element_type_id (p_att_table (l_att_idx));
            l_element_id_found := TRUE;
         END IF;

         l_att_idx := p_att_table.NEXT (l_att_idx);
      END LOOP;

      if g_debug then
	      hr_utility.set_location (   '   returning '
				       || l_element_type_id, 30);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_element_type_id;
   END find_element_id_in_attr_tbl;

   PROCEDURE find_other_in_attr_tbl (
      p_bg_id             IN              pay_batch_headers.business_group_id%TYPE,
      p_att_table         IN              hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id            IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_element_type_id   IN              pay_element_types_f.element_type_id%TYPE,
      p_cost_flex_id      IN              per_business_groups_perf.cost_allocation_structure%TYPE,
      p_effective_date    IN              pay_element_types_f.effective_start_date%TYPE,
      p_start_position    IN              PLS_INTEGER,
      p_ending_position   OUT NOCOPY      PLS_INTEGER, -- will return NULL if end-of-table was reached
      p_bee_rec           IN OUT NOCOPY   bee_rec
   )
   AS
      l_proc    proc_name   ;
      l_att_idx         PLS_INTEGER
                                  := NVL (p_start_position, p_att_table.FIRST);

      FUNCTION asg_id (
         p_bg_id            IN   pay_batch_headers.business_group_id%TYPE,
         p_effective_date   IN   DATE,
         p_bee_rec          IN   bee_rec
      )
         RETURN per_all_assignments_f.assignment_id%TYPE
      AS
         l_proc    proc_name   ;
         CURSOR csr_asg_id (
            p_bg_id               pay_batch_headers.business_group_id%TYPE,
            p_effective_date      DATE,
            p_assignment_number   per_all_assignments_f.assignment_number%TYPE
         )
         IS
            SELECT assignment_id
              FROM per_all_assignments_f
             WHERE assignment_number = p_assignment_number
               AND business_group_id = p_bg_id
               AND p_effective_date BETWEEN effective_start_date
                                        AND effective_end_date;

         l_asg_id   per_all_assignments_f.assignment_id%TYPE;
      BEGIN

         if g_debug then
		 l_proc :=    g_package
                                 || 'asg_id';
		 hr_utility.set_location (   'Entering '
					  || l_proc, 10);
		 hr_utility.set_location (   'p_bg_id =  '
					  || p_bg_id, 20);
		 hr_utility.set_location (   'p_effective_date =  '
					  || p_effective_date, 30);
		 hr_utility.set_location (   'p_bee_rec.pay_batch_line.assignment_number =  '
					  || p_bee_rec.pay_batch_line.assignment_number, 40);
         end if;
         OPEN csr_asg_id (p_bg_id,
                          p_effective_date,
                          p_bee_rec.pay_batch_line.assignment_number
                         );
         FETCH csr_asg_id INTO l_asg_id;
         CLOSE csr_asg_id;
         if g_debug then
		 hr_utility.set_location (   '   Returning Asg ID: '
					  || l_asg_id, 20);
		 hr_utility.set_location (   'Leaving '
					  || l_proc, 100);
         end if;
         RETURN l_asg_id;
      END asg_id;

      FUNCTION asg_num (p_effective_date IN DATE, p_bee_rec IN bee_rec)
         RETURN per_all_assignments_f.assignment_number%TYPE
      AS
         l_proc    proc_name   ;
         CURSOR csr_asg_num (
            p_effective_date   DATE,
            p_assignment_id    per_all_assignments_f.assignment_id%TYPE
         )
         IS
            SELECT assignment_number
              FROM per_all_assignments_f
             WHERE assignment_id = p_assignment_id
               AND p_effective_date BETWEEN effective_start_date
                                        AND effective_end_date;

         l_asg_num   per_all_assignments_f.assignment_number%TYPE;
      BEGIN

         if g_debug then
		 l_proc :=    g_package
                                 || 'asg_num';
		 hr_utility.set_location (   'Entering '
					  || l_proc, 10);
         end if;
         OPEN csr_asg_num (p_effective_date,
                           p_bee_rec.pay_batch_line.assignment_id
                          );
         FETCH csr_asg_num INTO l_asg_num;
         CLOSE csr_asg_num;
         if g_debug then
		 hr_utility.set_location (   '   Returning Asg Num: '
					  || l_asg_num, 20);
		 hr_utility.set_location (   'Leaving '
					  || l_proc, 100);
         end if;
         RETURN l_asg_num;
      END asg_num;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'find_other_in_attr_tbl';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      LOOP
         EXIT WHEN (   NOT p_att_table.EXISTS (l_att_idx)
                    OR (p_att_table (l_att_idx).bb_id <> p_tbb_id)
                   );

-- ADDED FOR PERF ...
         IF (p_att_table (l_att_idx).VALUE IS NOT NULL)
         THEN
            IF (attribute_is_input_value (p_att_table (l_att_idx)))
            THEN
               convert_attr_to_ivs (p_attr_rec             => p_att_table (l_att_idx
                                                                          ),
                                    p_element_type_id      => p_element_type_id,
                                    p_effective_date       => p_effective_date,
                                    p_bee_rec              => p_bee_rec
                                   );
            END IF;

            IF (attribute_is_cost_segment (p_att_table (l_att_idx)))
            THEN
               convert_attr_to_costsegment (p_attr_rec          => p_att_table (l_att_idx
                                                                               ),
                                            p_cost_flex_id      => p_cost_flex_id,
                                            p_bee_rec           => p_bee_rec
                                           );
            END IF;

            IF (attribute_is_asg_id (p_att_table (l_att_idx)))
            THEN
               p_bee_rec.pay_batch_line.assignment_id :=
                                                p_att_table (l_att_idx).VALUE;
               p_bee_rec.pay_batch_line.assignment_number :=
                                        asg_num (p_effective_date, p_bee_rec);
            END IF;

            IF (attribute_is_asg_num (p_att_table (l_att_idx)))
            THEN
               p_bee_rec.pay_batch_line.assignment_number :=
                                                p_att_table (l_att_idx).VALUE;
               p_bee_rec.pay_batch_line.assignment_id :=
                                asg_id (p_bg_id, p_effective_date, p_bee_rec);
            END IF;
         END IF;

         l_att_idx := p_att_table.NEXT (l_att_idx);
      END LOOP;

      p_ending_position := l_att_idx;
      if g_debug then
	      hr_utility.set_location (   '   returning p_ending_position '
				       || p_ending_position,
				       20
				      );
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
   END find_other_in_attr_tbl;

   FUNCTION skip_attributes (
      p_att_table        IN   hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id           IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_start_position   IN   PLS_INTEGER
   )
      RETURN PLS_INTEGER
   AS
      l_proc    proc_name   ;
      l_att_idx         PLS_INTEGER
                                  := NVL (p_start_position, p_att_table.FIRST);
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'skip_attributes';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      LOOP
         EXIT WHEN (   NOT p_att_table.EXISTS (l_att_idx)
                    OR (p_att_table (l_att_idx).bb_id <> p_tbb_id)
                   );
         l_att_idx := p_att_table.NEXT (l_att_idx);
      END LOOP;

      if g_debug then
	      hr_utility.set_location (   '   returning ending position '
				       || l_att_idx,
				       20
				      );
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_att_idx;
   END skip_attributes;

/*   PROCEDURE find_asg_in_attr_tbl (
      p_att_table        IN              hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id           IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_start_position   IN              PLS_INTEGER,
      p_bee_rec          IN OUT NOCOPY   bee_rec
   )
   AS
      l_proc            proc_name :=    g_package
                                         || 'find_asg_in_attr_tbl';
      l_att_idx         PLS_INTEGER   := p_start_position;
      l_asg_id_found    BOOLEAN       := FALSE;
      l_asg_num_found   BOOLEAN       := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      LOOP
         EXIT WHEN (   NOT p_att_table.EXISTS (l_att_idx)
                    OR (p_att_table (l_att_idx).bb_id <> p_tbb_id)
                    OR (l_asg_id_found AND l_asg_num_found)
                   );

         IF (attribute_is_asg_id (p_att_table (l_att_idx)))
         THEN
            p_bee_rec.pay_batch_line.assignment_id :=
                                                p_att_table (l_att_idx).VALUE;
            l_asg_id_found := TRUE;
         ELSIF (attribute_is_asg_num (p_att_table (l_att_idx)))
         THEN
            p_bee_rec.pay_batch_line.assignment_number :=
                                                p_att_table (l_att_idx).VALUE;
            l_asg_num_found := TRUE;
         END IF;

         l_att_idx := p_att_table.NEXT (l_att_idx);
      END LOOP;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
   END find_asg_in_attr_tbl;
*/
   FUNCTION cost_flex_structure_id (
      p_business_group_id   IN   per_all_organization_units.business_group_id%TYPE
   )
      RETURN per_business_groups_perf.cost_allocation_structure%TYPE
   IS
      l_proc                   proc_name;

      l_cost_allocation_structure_id   per_business_groups_perf.cost_allocation_structure%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'cost_flex_structure_id';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      pay_paywsqee_pkg.populate_context_items (p_business_group_id,
                                               l_cost_allocation_structure_id
                                              );
      if g_debug then
	      hr_utility.set_location (   '   Returning '
				       || l_cost_allocation_structure_id,
				       20
				      );
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 30);
      end if;
      RETURN l_cost_allocation_structure_id;
   END cost_flex_structure_id;

   FUNCTION costflex_value (
      p_id_flex_num       IN   fnd_id_flex_segments.id_flex_num%TYPE,
      p_segment_name      IN   fnd_id_flex_segments.application_column_name%TYPE,
      p_validation_type   IN   fnd_flex_value_sets.validation_type%TYPE
            DEFAULT g_independant,
      p_flex_value_id     IN   hxc_time_attributes.attribute1%TYPE
   )
      RETURN fnd_flex_values.flex_value%TYPE
   IS
      l_proc     proc_name  ;


      -- Bug 8666411
      -- Commented out validation type from the below cursor.
      -- With this query, we are letting only Independant type value sets
      -- to pass thru, because the calling code never passes any type parameter.


      CURSOR csr_flex_value (
         p_id_flex_num       fnd_id_flex_segments.id_flex_num%TYPE,
         p_segment_name      fnd_id_flex_segments.application_column_name%TYPE,
         p_validation_type   fnd_flex_value_sets.validation_type%TYPE,
         p_flex_value_id     fnd_flex_values.flex_value_id%TYPE
      )
      IS
         SELECT ffv.flex_value
           FROM fnd_id_flex_segments fifs,
                fnd_flex_value_sets ffvs,
                fnd_flex_values ffv
          WHERE fifs.application_id = g_pay_app_id
            AND fifs.id_flex_code = g_cost_flex_code
            AND fifs.id_flex_num = p_id_flex_num
            AND fifs.application_column_name = p_segment_name
            AND fifs.flex_value_set_id = ffvs.flex_value_set_id
            --AND ffvs.validation_type = p_validation_type
            AND ffvs.flex_value_set_id = ffv.flex_value_set_id
            AND ffv.flex_value_id = p_flex_value_id;

      l_costflex_value   per_business_groups_perf.cost_allocation_structure%TYPE;
      l_found_in_cache   BOOLEAN                                      := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'costflex_value';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (isnumber (p_flex_value_id))
      THEN
         IF ((caching) AND (g_flex_values.EXISTS (p_flex_value_id)))
         THEN
            IF (    (p_segment_name =
                                  g_flex_values (p_flex_value_id).segment_name
                    )
                AND (p_validation_type =
                               g_flex_values (p_flex_value_id).validation_type
                    )
                AND (p_id_flex_num =
                                   g_flex_values (p_flex_value_id).id_flex_num
                    )
               )
            THEN
               l_costflex_value := g_flex_values (p_flex_value_id).flex_value;
               l_found_in_cache := TRUE;
            END IF;
         END IF;

         IF (NOT l_found_in_cache)
         THEN
            IF (csr_flex_value%ISOPEN)
            THEN
               CLOSE csr_flex_value;
            END IF;

            OPEN csr_flex_value (p_id_flex_num,
                                 p_segment_name,
                                 p_validation_type,
                                 p_flex_value_id
                                );
            FETCH csr_flex_value INTO l_costflex_value;

            IF (csr_flex_value%NOTFOUND)
            THEN
               l_costflex_value := p_flex_value_id;
            ELSE
               IF (caching)
               THEN
                  g_flex_values (p_flex_value_id).segment_name :=
                                                               p_segment_name;
                  g_flex_values (p_flex_value_id).validation_type :=
                                                            p_validation_type;
                  g_flex_values (p_flex_value_id).id_flex_num :=
                                                                p_id_flex_num;
                  g_flex_values (p_flex_value_id).flex_value :=
                                                             l_costflex_value;
               END IF;
            END IF;

            CLOSE csr_flex_value;
         END IF;
      ELSE
         l_costflex_value := p_flex_value_id;
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   returning l_costflex_value = '
				       || l_costflex_value,
				       20
				      );
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 30);
      end if;
      RETURN l_costflex_value;
   END costflex_value;

   FUNCTION costflex_concat_segments (
      p_cost_allocation_keyflex_id   IN   pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
   )
      RETURN pay_cost_allocation_keyflex.concatenated_segments%TYPE
   IS
      l_proc               proc_name;


      CURSOR csr_costflex_concat_segments (
         p_cost_allocation_keyflex_id   pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
      )
      IS
         SELECT concatenated_segments
           FROM pay_cost_allocation_keyflex
          WHERE cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;

      l_costflex_concat_segments   pay_cost_allocation_keyflex.concatenated_segments%TYPE;
      l_found_in_cache             BOOLEAN                            := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'costflex_concat_segments';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (    (caching)
          AND (g_concatenated_segments.EXISTS (p_cost_allocation_keyflex_id))
         )
      THEN
         l_costflex_concat_segments :=
            g_concatenated_segments (p_cost_allocation_keyflex_id).concatenated_segment;
         l_found_in_cache := TRUE;
      END IF;

      IF (NOT l_found_in_cache)
      THEN
         IF (csr_costflex_concat_segments%ISOPEN)
         THEN
            CLOSE csr_costflex_concat_segments;
         END IF;

         OPEN csr_costflex_concat_segments (p_cost_allocation_keyflex_id);
         FETCH csr_costflex_concat_segments INTO l_costflex_concat_segments;

         IF ((csr_costflex_concat_segments%FOUND) AND (caching))
         THEN
            g_concatenated_segments (p_cost_allocation_keyflex_id).concatenated_segment :=
                                                   l_costflex_concat_segments;
         END IF;

         CLOSE csr_costflex_concat_segments;
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   returning '
				       || l_costflex_concat_segments,
				       20
				      );
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 30);
      end if;
      RETURN l_costflex_concat_segments;
   END costflex_concat_segments;

   FUNCTION cost_segments_all_null (
      p_segment_1    IN   pay_cost_allocation_keyflex.segment1%TYPE,
      p_segment_2    IN   pay_cost_allocation_keyflex.segment2%TYPE,
      p_segment_3    IN   pay_cost_allocation_keyflex.segment3%TYPE,
      p_segment_4    IN   pay_cost_allocation_keyflex.segment4%TYPE,
      p_segment_5    IN   pay_cost_allocation_keyflex.segment5%TYPE,
      p_segment_6    IN   pay_cost_allocation_keyflex.segment6%TYPE,
      p_segment_7    IN   pay_cost_allocation_keyflex.segment7%TYPE,
      p_segment_8    IN   pay_cost_allocation_keyflex.segment8%TYPE,
      p_segment_9    IN   pay_cost_allocation_keyflex.segment9%TYPE,
      p_segment_10   IN   pay_cost_allocation_keyflex.segment10%TYPE,
      p_segment_11   IN   pay_cost_allocation_keyflex.segment11%TYPE,
      p_segment_12   IN   pay_cost_allocation_keyflex.segment12%TYPE,
      p_segment_13   IN   pay_cost_allocation_keyflex.segment13%TYPE,
      p_segment_14   IN   pay_cost_allocation_keyflex.segment14%TYPE,
      p_segment_15   IN   pay_cost_allocation_keyflex.segment15%TYPE,
      p_segment_16   IN   pay_cost_allocation_keyflex.segment16%TYPE,
      p_segment_17   IN   pay_cost_allocation_keyflex.segment17%TYPE,
      p_segment_18   IN   pay_cost_allocation_keyflex.segment18%TYPE,
      p_segment_19   IN   pay_cost_allocation_keyflex.segment19%TYPE,
      p_segment_20   IN   pay_cost_allocation_keyflex.segment20%TYPE,
      p_segment_21   IN   pay_cost_allocation_keyflex.segment21%TYPE,
      p_segment_22   IN   pay_cost_allocation_keyflex.segment22%TYPE,
      p_segment_23   IN   pay_cost_allocation_keyflex.segment23%TYPE,
      p_segment_24   IN   pay_cost_allocation_keyflex.segment24%TYPE,
      p_segment_25   IN   pay_cost_allocation_keyflex.segment25%TYPE,
      p_segment_26   IN   pay_cost_allocation_keyflex.segment26%TYPE,
      p_segment_27   IN   pay_cost_allocation_keyflex.segment27%TYPE,
      p_segment_28   IN   pay_cost_allocation_keyflex.segment28%TYPE,
      p_segment_29   IN   pay_cost_allocation_keyflex.segment29%TYPE,
      p_segment_30   IN   pay_cost_allocation_keyflex.segment30%TYPE
   )
      RETURN BOOLEAN
   IS
      l_proc             proc_name;

      l_cost_segments_all_null   BOOLEAN   := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'cost_segments_all_null';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (    (p_segment_1 IS NULL)
          AND (p_segment_2 IS NULL)
          AND (p_segment_3 IS NULL)
          AND (p_segment_4 IS NULL)
          AND (p_segment_5 IS NULL)
          AND (p_segment_6 IS NULL)
          AND (p_segment_7 IS NULL)
          AND (p_segment_8 IS NULL)
          AND (p_segment_9 IS NULL)
          AND (p_segment_10 IS NULL)
          AND (p_segment_11 IS NULL)
          AND (p_segment_12 IS NULL)
          AND (p_segment_13 IS NULL)
          AND (p_segment_14 IS NULL)
          AND (p_segment_15 IS NULL)
          AND (p_segment_16 IS NULL)
          AND (p_segment_17 IS NULL)
          AND (p_segment_18 IS NULL)
          AND (p_segment_19 IS NULL)
          AND (p_segment_20 IS NULL)
          AND (p_segment_21 IS NULL)
          AND (p_segment_22 IS NULL)
          AND (p_segment_23 IS NULL)
          AND (p_segment_24 IS NULL)
          AND (p_segment_25 IS NULL)
          AND (p_segment_26 IS NULL)
          AND (p_segment_27 IS NULL)
          AND (p_segment_28 IS NULL)
          AND (p_segment_29 IS NULL)
          AND (p_segment_30 IS NULL)
         )
      THEN
         l_cost_segments_all_null := TRUE;
      ELSE
         l_cost_segments_all_null := FALSE;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN (l_cost_segments_all_null);
   END cost_segments_all_null;

   FUNCTION cost_segments_all_null (p_bee_rec IN bee_rec)
      RETURN BOOLEAN
   IS
      l_proc             proc_name;

      l_cost_segments_all_null   BOOLEAN   := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'cost_segments_all_null';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_cost_segments_all_null :=
         cost_segments_all_null (p_segment_1       => p_bee_rec.pay_batch_line.segment1,
                                 p_segment_2       => p_bee_rec.pay_batch_line.segment2,
                                 p_segment_3       => p_bee_rec.pay_batch_line.segment3,
                                 p_segment_4       => p_bee_rec.pay_batch_line.segment4,
                                 p_segment_5       => p_bee_rec.pay_batch_line.segment5,
                                 p_segment_6       => p_bee_rec.pay_batch_line.segment6,
                                 p_segment_7       => p_bee_rec.pay_batch_line.segment7,
                                 p_segment_8       => p_bee_rec.pay_batch_line.segment8,
                                 p_segment_9       => p_bee_rec.pay_batch_line.segment9,
                                 p_segment_10      => p_bee_rec.pay_batch_line.segment10,
                                 p_segment_11      => p_bee_rec.pay_batch_line.segment11,
                                 p_segment_12      => p_bee_rec.pay_batch_line.segment12,
                                 p_segment_13      => p_bee_rec.pay_batch_line.segment13,
                                 p_segment_14      => p_bee_rec.pay_batch_line.segment14,
                                 p_segment_15      => p_bee_rec.pay_batch_line.segment15,
                                 p_segment_16      => p_bee_rec.pay_batch_line.segment16,
                                 p_segment_17      => p_bee_rec.pay_batch_line.segment17,
                                 p_segment_18      => p_bee_rec.pay_batch_line.segment18,
                                 p_segment_19      => p_bee_rec.pay_batch_line.segment19,
                                 p_segment_20      => p_bee_rec.pay_batch_line.segment20,
                                 p_segment_21      => p_bee_rec.pay_batch_line.segment21,
                                 p_segment_22      => p_bee_rec.pay_batch_line.segment22,
                                 p_segment_23      => p_bee_rec.pay_batch_line.segment23,
                                 p_segment_24      => p_bee_rec.pay_batch_line.segment24,
                                 p_segment_25      => p_bee_rec.pay_batch_line.segment25,
                                 p_segment_26      => p_bee_rec.pay_batch_line.segment26,
                                 p_segment_27      => p_bee_rec.pay_batch_line.segment27,
                                 p_segment_28      => p_bee_rec.pay_batch_line.segment28,
                                 p_segment_29      => p_bee_rec.pay_batch_line.segment29,
                                 p_segment_30      => p_bee_rec.pay_batch_line.segment30
                                );
      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN (l_cost_segments_all_null);
   END cost_segments_all_null;

   FUNCTION cost_allocation_kff_id (
      p_business_group_id   IN   per_all_organization_units.business_group_id%TYPE,
      p_segment_1           IN   pay_cost_allocation_keyflex.segment1%TYPE,
      p_segment_2           IN   pay_cost_allocation_keyflex.segment2%TYPE,
      p_segment_3           IN   pay_cost_allocation_keyflex.segment3%TYPE,
      p_segment_4           IN   pay_cost_allocation_keyflex.segment4%TYPE,
      p_segment_5           IN   pay_cost_allocation_keyflex.segment5%TYPE,
      p_segment_6           IN   pay_cost_allocation_keyflex.segment6%TYPE,
      p_segment_7           IN   pay_cost_allocation_keyflex.segment7%TYPE,
      p_segment_8           IN   pay_cost_allocation_keyflex.segment8%TYPE,
      p_segment_9           IN   pay_cost_allocation_keyflex.segment9%TYPE,
      p_segment_10          IN   pay_cost_allocation_keyflex.segment10%TYPE,
      p_segment_11          IN   pay_cost_allocation_keyflex.segment11%TYPE,
      p_segment_12          IN   pay_cost_allocation_keyflex.segment12%TYPE,
      p_segment_13          IN   pay_cost_allocation_keyflex.segment13%TYPE,
      p_segment_14          IN   pay_cost_allocation_keyflex.segment14%TYPE,
      p_segment_15          IN   pay_cost_allocation_keyflex.segment15%TYPE,
      p_segment_16          IN   pay_cost_allocation_keyflex.segment16%TYPE,
      p_segment_17          IN   pay_cost_allocation_keyflex.segment17%TYPE,
      p_segment_18          IN   pay_cost_allocation_keyflex.segment18%TYPE,
      p_segment_19          IN   pay_cost_allocation_keyflex.segment19%TYPE,
      p_segment_20          IN   pay_cost_allocation_keyflex.segment20%TYPE,
      p_segment_21          IN   pay_cost_allocation_keyflex.segment21%TYPE,
      p_segment_22          IN   pay_cost_allocation_keyflex.segment22%TYPE,
      p_segment_23          IN   pay_cost_allocation_keyflex.segment23%TYPE,
      p_segment_24          IN   pay_cost_allocation_keyflex.segment24%TYPE,
      p_segment_25          IN   pay_cost_allocation_keyflex.segment25%TYPE,
      p_segment_26          IN   pay_cost_allocation_keyflex.segment26%TYPE,
      p_segment_27          IN   pay_cost_allocation_keyflex.segment27%TYPE,
      p_segment_28          IN   pay_cost_allocation_keyflex.segment28%TYPE,
      p_segment_29          IN   pay_cost_allocation_keyflex.segment29%TYPE,
      p_segment_30          IN   pay_cost_allocation_keyflex.segment30%TYPE
   )
      RETURN pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
   IS
      l_proc             proc_name;

      l_cost_allocation_kff_id   pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'cost_allocation_kff_id';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (NOT cost_segments_all_null (p_segment_1       => p_segment_1,
                                      p_segment_2       => p_segment_2,
                                      p_segment_3       => p_segment_3,
                                      p_segment_4       => p_segment_4,
                                      p_segment_5       => p_segment_5,
                                      p_segment_6       => p_segment_6,
                                      p_segment_7       => p_segment_7,
                                      p_segment_8       => p_segment_8,
                                      p_segment_9       => p_segment_9,
                                      p_segment_10      => p_segment_10,
                                      p_segment_11      => p_segment_11,
                                      p_segment_12      => p_segment_12,
                                      p_segment_13      => p_segment_13,
                                      p_segment_14      => p_segment_14,
                                      p_segment_15      => p_segment_15,
                                      p_segment_16      => p_segment_16,
                                      p_segment_17      => p_segment_17,
                                      p_segment_18      => p_segment_18,
                                      p_segment_19      => p_segment_19,
                                      p_segment_20      => p_segment_20,
                                      p_segment_21      => p_segment_21,
                                      p_segment_22      => p_segment_22,
                                      p_segment_23      => p_segment_23,
                                      p_segment_24      => p_segment_24,
                                      p_segment_25      => p_segment_25,
                                      p_segment_26      => p_segment_26,
                                      p_segment_27      => p_segment_27,
                                      p_segment_28      => p_segment_28,
                                      p_segment_29      => p_segment_29,
                                      p_segment_30      => p_segment_30
                                     )
         )
      THEN
         l_cost_allocation_kff_id :=
            hr_entry.maintain_cost_keyflex (p_cost_keyflex_structure          => cost_flex_structure_id (p_business_group_id      => p_business_group_id
                                                                                                        ),
                                            p_cost_allocation_keyflex_id      => -1,
                                            p_concatenated_segments           => NULL,
                                            p_summary_flag                    => 'N',
                                            p_start_date_active               => NULL,
                                            p_end_date_active                 => NULL,
                                            p_segment1                        => p_segment_1,
                                            p_segment2                        => p_segment_2,
                                            p_segment3                        => p_segment_3,
                                            p_segment4                        => p_segment_4,
                                            p_segment5                        => p_segment_5,
                                            p_segment6                        => p_segment_6,
                                            p_segment7                        => p_segment_7,
                                            p_segment8                        => p_segment_8,
                                            p_segment9                        => p_segment_9,
                                            p_segment10                       => p_segment_10,
                                            p_segment11                       => p_segment_11,
                                            p_segment12                       => p_segment_12,
                                            p_segment13                       => p_segment_13,
                                            p_segment14                       => p_segment_14,
                                            p_segment15                       => p_segment_15,
                                            p_segment16                       => p_segment_16,
                                            p_segment17                       => p_segment_17,
                                            p_segment18                       => p_segment_18,
                                            p_segment19                       => p_segment_19,
                                            p_segment20                       => p_segment_20,
                                            p_segment21                       => p_segment_21,
                                            p_segment22                       => p_segment_22,
                                            p_segment23                       => p_segment_23,
                                            p_segment24                       => p_segment_24,
                                            p_segment25                       => p_segment_25,
                                            p_segment26                       => p_segment_26,
                                            p_segment27                       => p_segment_27,
                                            p_segment28                       => p_segment_28,
                                            p_segment29                       => p_segment_29,
                                            p_segment30                       => p_segment_30
                                           );
      ELSE
         l_cost_allocation_kff_id := NULL;
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   returning  '
				       || l_cost_allocation_kff_id,
				       20
				      );
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN (l_cost_allocation_kff_id);
   END cost_allocation_kff_id;

   FUNCTION cost_allocation_kff_id (
      p_business_group_id   IN   per_all_organization_units.business_group_id%TYPE,
      p_bee_rec             IN   bee_rec
   )
      RETURN pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
   IS
      l_proc             proc_name;

      l_cost_allocation_kff_id   pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                            || 'cost_allocation_kff_id (p_bee_rec)';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_cost_allocation_kff_id :=
         cost_allocation_kff_id (p_business_group_id      => p_business_group_id,
                                 p_segment_1              => p_bee_rec.pay_batch_line.segment1,
                                 p_segment_2              => p_bee_rec.pay_batch_line.segment2,
                                 p_segment_3              => p_bee_rec.pay_batch_line.segment3,
                                 p_segment_4              => p_bee_rec.pay_batch_line.segment4,
                                 p_segment_5              => p_bee_rec.pay_batch_line.segment5,
                                 p_segment_6              => p_bee_rec.pay_batch_line.segment6,
                                 p_segment_7              => p_bee_rec.pay_batch_line.segment7,
                                 p_segment_8              => p_bee_rec.pay_batch_line.segment8,
                                 p_segment_9              => p_bee_rec.pay_batch_line.segment9,
                                 p_segment_10             => p_bee_rec.pay_batch_line.segment10,
                                 p_segment_11             => p_bee_rec.pay_batch_line.segment11,
                                 p_segment_12             => p_bee_rec.pay_batch_line.segment12,
                                 p_segment_13             => p_bee_rec.pay_batch_line.segment13,
                                 p_segment_14             => p_bee_rec.pay_batch_line.segment14,
                                 p_segment_15             => p_bee_rec.pay_batch_line.segment15,
                                 p_segment_16             => p_bee_rec.pay_batch_line.segment16,
                                 p_segment_17             => p_bee_rec.pay_batch_line.segment17,
                                 p_segment_18             => p_bee_rec.pay_batch_line.segment18,
                                 p_segment_19             => p_bee_rec.pay_batch_line.segment19,
                                 p_segment_20             => p_bee_rec.pay_batch_line.segment20,
                                 p_segment_21             => p_bee_rec.pay_batch_line.segment21,
                                 p_segment_22             => p_bee_rec.pay_batch_line.segment22,
                                 p_segment_23             => p_bee_rec.pay_batch_line.segment23,
                                 p_segment_24             => p_bee_rec.pay_batch_line.segment24,
                                 p_segment_25             => p_bee_rec.pay_batch_line.segment25,
                                 p_segment_26             => p_bee_rec.pay_batch_line.segment26,
                                 p_segment_27             => p_bee_rec.pay_batch_line.segment27,
                                 p_segment_28             => p_bee_rec.pay_batch_line.segment28,
                                 p_segment_29             => p_bee_rec.pay_batch_line.segment29,
                                 p_segment_30             => p_bee_rec.pay_batch_line.segment30
                                );
      if g_debug then
	      hr_utility.set_location (   '   returning  '
				       || l_cost_allocation_kff_id,
				       20
				      );
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN (l_cost_allocation_kff_id);
   END cost_allocation_kff_id;

   FUNCTION hours_factor (p_is_old IN BOOLEAN)
      RETURN NUMBER
   IS
      l_proc    proc_name  ;
      l_hours_factor    NUMBER (1);
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'hours_factor';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (p_is_old)
      THEN
         l_hours_factor := -1;
      ELSE
         l_hours_factor := 1;
      END IF;

      if g_debug then
	      hr_utility.set_location (   '   Returning '
				       || l_hours_factor, 20);
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 30);
      end if;
      RETURN l_hours_factor;
   END hours_factor;

/* These 3 procedures were commented out because the pipes were causing
   issues with the SGA.  The pipe grew out-of-control for no apparent reason.
   Anyway, for now, we will NOT allow multithreading of this process so we do
   not need pipes!!!
*/
/*   PROCEDURE write_pipe_batch_info (p_batch_info IN piped_batch_info_table)
   IS
      l_proc          proc_name   :=    g_package
                                             || 'write_pipe_batch_info';
      l_send_message_status   INTEGER;
      l_batch_info_idx        PLS_INTEGER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_batch_info_idx := p_batch_info.FIRST;
      DBMS_PIPE.reset_buffer;

      LOOP
         EXIT WHEN NOT p_batch_info.EXISTS (l_batch_info_idx);
         DBMS_PIPE.pack_message (p_batch_info (l_batch_info_idx).batch_ref);
         DBMS_PIPE.pack_message (
            p_batch_info (l_batch_info_idx).business_group_id
         );
         DBMS_PIPE.pack_message (
            p_batch_info (l_batch_info_idx).free_batch_suffix
         );
         l_batch_info_idx := p_batch_info.NEXT (l_batch_info_idx);
      END LOOP;

      l_send_message_status :=
            DBMS_PIPE.send_message (
               pipename=> g_total_lines_pipe_name,
               TIMEOUT=> 0
            );

      IF l_send_message_status != 0
      THEN
         NULL; -- RAISE ERROR
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
   END write_pipe_batch_info;

   FUNCTION read_pipe_batch_info
      RETURN piped_batch_info_table
   IS
      l_proc             proc_name              :=    g_package
                                                           || 'read_pipe_batch_info';
      l_recieve_message_status   INTEGER;
      l_batch_info               piped_batch_info_table;
      l_batch_info_idx           PLS_INTEGER            := 1;
      e_pipe_empty               EXCEPTION;
      PRAGMA EXCEPTION_INIT (e_pipe_empty,  -6556);
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_recieve_message_status :=
            DBMS_PIPE.receive_message (
               pipename=> g_total_lines_pipe_name,
               TIMEOUT=> 0
            );

      LOOP
         DBMS_PIPE.unpack_message (l_batch_info (l_batch_info_idx).batch_ref);
         DBMS_PIPE.unpack_message (
            l_batch_info (l_batch_info_idx).business_group_id
         );
         DBMS_PIPE.unpack_message (
            l_batch_info (l_batch_info_idx).free_batch_suffix
         );

         l_batch_info_idx :=   l_batch_info_idx
                             + 1;
      END LOOP;
   EXCEPTION
      WHEN e_pipe_empty
      THEN
         if g_debug then
		 hr_utility.set_location (
		       '   returning '
		    || l_batch_info.COUNT
		    || ' batch_info lines',
		    20
		 );
		 hr_utility.set_location (   'Leaving '
					  || l_proc, 100);
         end if;
         DBMS_PIPE.reset_buffer;
         DBMS_PIPE.PURGE (hxt_interface_utilities.g_total_lines_pipe_name);
         RETURN l_batch_info;
   END read_pipe_batch_info;

   FUNCTION purge_pipe
      RETURN BOOLEAN
   AS
      cannot_use_pipe   EXCEPTION;
      PRAGMA EXCEPTION_INIT (cannot_use_pipe,  -23322);
      l_purged          BOOLEAN   := FALSE;
   BEGIN
      DBMS_PIPE.PURGE (hxt_interface_utilities.g_total_lines_pipe_name);
      l_purged := TRUE;
      RETURN l_purged;
   EXCEPTION
      WHEN cannot_use_pipe
      THEN
         RETURN l_purged;
      WHEN OTHERS
      THEN
         RETURN l_purged;
   END purge_pipe;
*/
   FUNCTION free_batch_suffix (
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN NUMBER
   IS
      l_proc        proc_name  ;
      l_batch_info_idx      PLS_INTEGER;
      l_batch_ref_found     BOOLEAN     := FALSE;
      l_free_batch_suffix   NUMBER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                               || 'free_batch_suffix';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      l_batch_info_idx := g_batch_info.FIRST;

      IF (l_batch_info_idx IS NOT NULL)
      THEN
         LOOP
            EXIT WHEN NOT (g_batch_info.EXISTS (l_batch_info_idx))
                  OR l_batch_ref_found;

            IF (    (g_batch_info (l_batch_info_idx).batch_ref =
                                                             p_batch_reference
                    )
                AND (g_batch_info (l_batch_info_idx).business_group_id =
                                                                       p_bg_id
                    )
                AND (g_batch_info (l_batch_info_idx).request_id =
                                                        conc_request_id_suffix
                    )
               )
            THEN
               l_free_batch_suffix :=
                            g_batch_info (l_batch_info_idx).free_batch_suffix;
               g_batch_info (l_batch_info_idx).free_batch_suffix :=
                                                         l_free_batch_suffix
                                                       + 1;
               l_batch_ref_found := TRUE;
            END IF;

            l_batch_info_idx := g_batch_info.NEXT (l_batch_info_idx);
         END LOOP;
      END IF;

      IF (NOT l_batch_ref_found)
      THEN
         if g_debug then
         	 hr_utility.set_location ('   new batch reference', 20);
         end if;
         l_batch_info_idx :=   NVL (g_batch_info.LAST, 0)
                             + 1;
         g_batch_info (l_batch_info_idx).batch_ref := p_batch_reference;
         g_batch_info (l_batch_info_idx).business_group_id := p_bg_id;
         g_batch_info (l_batch_info_idx).request_id := conc_request_id_suffix;
         l_free_batch_suffix := 1;
         g_batch_info (l_batch_info_idx).free_batch_suffix :=
                                                          l_free_batch_suffix
                                                        + 1;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 100);
      end if;
      RETURN l_free_batch_suffix;
   END free_batch_suffix;

-- Action                      Changed Deleted
-- --------------------------- ------- -------
-- new TBB                           N       N
-- changed TBB (never xfered)        N       N
-- changed TBB (xfered)              Y       N
-- DELETED (never xfered)            N       Y
-- DELETED (xfered)                  Y       Y
-- --------------------------- ------- -------
   FUNCTION is_changed (
      p_tbb_rec   IN   hxc_generic_retrieval_pkg.r_building_blocks
   )
      RETURN BOOLEAN
   AS
      l_proc    proc_name ;
      l_is_changed      BOOLEAN   := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'is_changed';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (UPPER (p_tbb_rec.changed) = g_tbb_changed)
      THEN
         l_is_changed := TRUE;
         if g_debug then
		 hr_utility.set_location (   '   TBB '
					  || p_tbb_rec.bb_id
					  || ' changed',
					  20
					 );
         end if;
      ELSE
         l_is_changed := FALSE;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 40);
      end if;
      RETURN l_is_changed;
   END is_changed;

   FUNCTION is_deleted (
      p_tbb_rec   IN   hxc_generic_retrieval_pkg.r_building_blocks
   )
      RETURN BOOLEAN
   AS
      l_proc    proc_name ;
      l_is_deleted      BOOLEAN   := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'is_deleted';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (UPPER (p_tbb_rec.deleted) = g_tbb_deleted)
      THEN
         l_is_deleted := TRUE;
         if g_debug then
		 hr_utility.set_location (   '   TBB '
					  || p_tbb_rec.bb_id
					  || ' deleted',
					  20
					 );
         end if;
      ELSE
         l_is_deleted := FALSE;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 40);
      end if;
      RETURN l_is_deleted;
   END is_deleted;

   FUNCTION is_in_sync (
      p_check_tbb_id     hxc_time_building_blocks.time_building_block_id%TYPE,
      p_against_tbb_id   hxc_time_building_blocks.time_building_block_id%TYPE
   )
      RETURN BOOLEAN
   AS
      l_proc    proc_name ;
      l_is_in_sync      BOOLEAN   := FALSE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'is_in_sync';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      IF (p_check_tbb_id = p_against_tbb_id)
      THEN
         l_is_in_sync := TRUE;
      ELSE
         l_is_in_sync := FALSE;
         if g_debug then
		 hr_utility.set_location (   p_check_tbb_id
					  || ' is NOT in sync with TBB '
					  || p_against_tbb_id,
					  30
					 );
         end if;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving '
				       || l_proc, 40);
      end if;
      RETURN l_is_in_sync;
   END is_in_sync;



FUNCTION get_geocode_from_attr_tab (
      p_att_table        IN   hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id           IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_start_position   IN   PLS_INTEGER
   )
      RETURN VARCHAR2
   AS
      l_proc       proc_name;

      l_att_idx            PLS_INTEGER
                                  := NVL (p_start_position, p_att_table.FIRST);
      l_jurisdiction_code   VARCHAR2(11):=NULL;
      l_state_name pay_us_states.state_name%TYPE;
      l_county_name pay_us_counties.county_name%TYPE;
      l_city_name pay_us_city_names.city_name%TYPE;
      l_zip_code pay_us_zip_codes.zip_start%TYPE;

    BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'get_geocode_from_attr_tab';
	      hr_utility.set_location (   'Entering '
				       || l_proc, 10);
      end if;
      LOOP
         EXIT WHEN (   NOT p_att_table.EXISTS (l_att_idx)
				);
           IF( p_att_table (l_att_idx).bb_id = p_tbb_id) THEN

		 IF(p_att_table(l_att_idx).field_name='NA_STATE_NAME') THEN
		 l_state_name:=p_att_table(l_att_idx).value;
		   IF(l_state_name IS NULL) THEN
		     return '00-000-0000';
                   END IF;
		 END IF;

		 IF(p_att_table(l_att_idx).field_name='NA_COUNTY_NAME') THEN
		 l_county_name:=p_att_table(l_att_idx).value;
		 END IF;

		 IF(p_att_table(l_att_idx).field_name='NA_CITY_NAME' ) THEN
		 l_city_name:=p_att_table(l_att_idx).value;
		 END IF;

		 IF(p_att_table(l_att_idx).field_name='NA_ZIP_CODE' ) THEN
		 l_zip_code:=p_att_table(l_att_idx).value;
		 END IF;

	   END IF;
         l_att_idx := p_att_table.NEXT (l_att_idx);
      END LOOP;

      l_jurisdiction_code:=pay_ac_utility.get_geocode(l_state_name,l_county_name,l_city_name,l_zip_code);
      RETURN l_jurisdiction_code;
   END get_geocode_from_attr_tab;

END hxt_interface_utilities;

/
