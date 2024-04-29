--------------------------------------------------------
--  DDL for Package Body PAY_HR_OTC_RETRIEVAL_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HR_OTC_RETRIEVAL_INTERFACE" AS
/* $Header: pytshpri.pkb 120.8.12010000.4 2010/04/03 12:23:29 asrajago ship $ */
   -- Global package name
   g_package     CONSTANT package_name   := 'pay_hr_otc_retrieval_interface.';
   -- Global variables
   g_retro_batch_suffix   VARCHAR2 (10)                        := '_RETRO';
   g_batches_created      batches_type_table;
   -- Global Exceptions
   e_continue             EXCEPTION;
   e_halt                 EXCEPTION;
   g_assignment_id        pay_batch_lines.assignment_id%TYPE;
   l_since_date           VARCHAR2 (20);

   /*
   || Function that can be used to convert "internal" values (LOV Codes etc.) to
   || their respective "display" values (LOV Meaning etc.).
   */
   FUNCTION display_value (
      p_element_type_id        IN   pay_batch_lines.element_type_id%TYPE,
      p_internal_input_value   IN   pay_batch_lines.value_1%TYPE,
      p_iv_number              IN   PLS_INTEGER,
      p_session_date           IN   DATE,
      p_bg_id                  IN   hr_all_organization_units.business_group_id%TYPE
   )
      RETURN VARCHAR2
   IS
      l_proc   CONSTANT proc_name             := g_package || 'display_value';
      l_display_value   VARCHAR2 (80);

      /*
      || This odd looking query was created to be able to retrieve the nth
      || (p_iv_number) Input Value of an Element Type without having to loop over
      || all of them and then stop at the nth position.
      */
      CURSOR csr_iv_info (
         p_element_type_id   pay_element_types_f.element_type_id%TYPE,
         p_iv_number         PLS_INTEGER,
         p_session_date      DATE
      )
      IS
         SELECT *
           FROM (SELECT iv_data.*, ROWNUM r
                   FROM (SELECT   inv.uom, inv.lookup_type, inv.value_set_id,
                                  etp.input_currency_code
                             FROM pay_input_values_f inv,
                                  pay_element_types_f etp
                            WHERE inv.element_type_id = p_element_type_id
                              AND etp.element_type_id = p_element_type_id
                              AND p_session_date
                                     BETWEEN inv.effective_start_date
                                         AND inv.effective_end_date
                              AND p_session_date
                                     BETWEEN etp.effective_start_date
                                         AND etp.effective_end_date
                         ORDER BY inv.display_sequence, inv.NAME) iv_data
                  WHERE ROWNUM < (p_iv_number + 1))
          WHERE r > (p_iv_number - 1);

      rec_iv_info       csr_iv_info%ROWTYPE;

      FUNCTION lookup_meaning (
         p_lookup_type   IN   hr_lookups.lookup_type%TYPE,
         p_lookup_code   IN   hr_lookups.lookup_code%TYPE
      )
         RETURN hr_lookups.meaning%TYPE
      AS
         CURSOR csr_valid_lookup (
            p_lookup_type   VARCHAR2,
            p_lookup_code   VARCHAR2
         )
         IS
            SELECT hl.meaning
              FROM hr_lookups hl
             WHERE hl.lookup_type = p_lookup_type
               AND hl.lookup_code = p_lookup_code;

         l_lookup_meaning   hr_lookups.meaning%TYPE;
      BEGIN
         OPEN csr_valid_lookup (p_lookup_type, p_lookup_code);

         FETCH csr_valid_lookup
          INTO l_lookup_meaning;

         CLOSE csr_valid_lookup;

         hr_utility.set_location (   '      l_lookup_meaning = '
                                  || l_lookup_meaning,
                                  10
                                 );
         RETURN l_lookup_meaning;
      END lookup_meaning;

      FUNCTION valueset_meaning (
         p_value_set_id     IN   fnd_flex_values.flex_value_set_id%TYPE,
         p_valueset_value   IN   fnd_flex_values.flex_value%TYPE
      )
         RETURN fnd_flex_values_vl.description%TYPE
      AS
         l_valueset_meaning   fnd_flex_values_vl.description%TYPE;
      BEGIN
         l_valueset_meaning :=
            pay_input_values_pkg.decode_vset_value (p_value_set_id,
                                                    p_valueset_value
                                                   );
         hr_utility.set_location (   '      l_valueset_meaning = '
                                  || l_valueset_meaning,
                                  10
                                 );
         RETURN l_valueset_meaning;
      END valueset_meaning;
   BEGIN
      hr_utility.set_location ('Entering: ' || l_proc, 10);
      l_display_value := p_internal_input_value;

      IF (p_internal_input_value IS NOT NULL)
      THEN
         hr_utility.set_location
                               (   '   Converting p_internal_input_value = '
                                || p_internal_input_value,
                                20
                               );
         hr_utility.set_location ('   using: ', 30);
         hr_utility.set_location (   '      p_element_type_id  = '
                                  || p_element_type_id,
                                  40
                                 );
         hr_utility.set_location ('      p_iv_number        = ' || p_iv_number,
                                  50
                                 );
         hr_utility.set_location (   '      p_session_date     = '
                                  || p_session_date,
                                  60
                                 );
         hr_utility.set_location ('      p_bg_id            = ' || p_bg_id,
                                  70);

         OPEN csr_iv_info (p_element_type_id, p_iv_number, p_session_date);

         FETCH csr_iv_info
          INTO rec_iv_info;

         IF (csr_iv_info%FOUND)
         THEN
            IF (rec_iv_info.lookup_type IS NOT NULL)
            THEN
               l_display_value :=
                  lookup_meaning (p_lookup_type      => rec_iv_info.lookup_type,
                                  p_lookup_code      => p_internal_input_value
                                 );
            ELSIF (rec_iv_info.value_set_id IS NOT NULL)
            THEN
               l_display_value :=
                  valueset_meaning
                                 (p_value_set_id        => rec_iv_info.value_set_id,
                                  p_valueset_value      => p_internal_input_value
                                 );
            -- Bug 8411771
            -- Commenting the below code.  Henceforth, all Date, Number,
            -- Currency input values would go thru in Internal format
            -- and BEE would take care of the conversion.
            /*
            ELSE
               hr_chkfmt.changeformat (p_internal_input_value,
                                       l_display_value,
                                       rec_iv_info.uom,
                                       rec_iv_info.input_currency_code
                                      );
            */
            END IF;
         END IF;
      END IF;

      hr_utility.set_location (   '   returning l_display_value = '
                               || l_display_value,
                               90
                              );
      hr_utility.set_location ('Leaving: ' || l_proc, 100);
      RETURN l_display_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.set_message ('PAY', 'PAY_6306_INPUT_VALUE_FORMAT');
         hr_utility.set_message_token
                                   ('UNIT_OF_MEASURE',
                                    hr_general.decode_lookup ('UNITS',
                                                              rec_iv_info.uom
                                                             )
                                   );
         hr_utility.raise_error;
   END display_value;

   FUNCTION retro_batch_suffix
      RETURN VARCHAR2
   IS
      l_proc   CONSTANT proc_name := g_package || 'retro_batch_suffix';
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      hr_utility.set_location (   '   returning g_retro_batch_suffix = '
                               || g_retro_batch_suffix,
                               20
                              );
      hr_utility.set_location ('Leaving:' || l_proc, 100);
      RETURN g_retro_batch_suffix;
   END retro_batch_suffix;

   PROCEDURE set_retro_batch_suffix (p_retro_batch_suffix IN VARCHAR2)
   IS
      l_proc   CONSTANT proc_name := g_package || 'set_retro_batch_suffix';
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      hr_utility.set_location (   '   setting g_retro_batch_suffix to '
                               || p_retro_batch_suffix,
                               20
                              );
      g_retro_batch_suffix := p_retro_batch_suffix;
      hr_utility.set_location ('Leaving:' || l_proc, 100);
   END set_retro_batch_suffix;

   PROCEDURE record_batch_info (p_batch_rec IN batches_type_rec)
   IS
      l_proc   CONSTANT proc_name := g_package || 'record_batch_info';
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      g_batches_created (NVL (g_batches_created.LAST, 0) + 1) := p_batch_rec;
      hr_utility.set_location ('Leaving:' || l_proc, 100);
   END record_batch_info;

   PROCEDURE record_batch_info (
      p_batch_id            IN   pay_batch_headers.batch_id%TYPE,
      p_business_group_id   IN   pay_batch_headers.business_group_id%TYPE,
      p_batch_reference     IN   pay_batch_headers.batch_reference%TYPE,
      p_batch_name          IN   pay_batch_headers.batch_name%TYPE
   )
   IS
      l_proc   CONSTANT proc_name
                             := g_package || 'record_batch_info (Overloaded)';
      l_batch_created   batches_type_rec;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      l_batch_created.batch_id := p_batch_id;
      l_batch_created.business_group_id := p_business_group_id;
      l_batch_created.batch_reference := p_batch_reference;
      l_batch_created.batch_name := p_batch_name;
      record_batch_info (p_batch_rec => l_batch_created);
      hr_utility.set_location ('Leaving:' || l_proc, 100);
   END record_batch_info;

   FUNCTION batches_created
      RETURN batches_type_table
   IS
      l_proc   CONSTANT proc_name := g_package || 'batches_created';
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      hr_utility.set_location (   '   g_batches_created.count = '
                               || g_batches_created.COUNT,
                               20
                              );
      hr_utility.set_location ('Leaving:' || l_proc, 100);
      RETURN g_batches_created;
   END batches_created;

   PROCEDURE start_bee_process (
      p_mode      IN   VARCHAR2,
      p_batches   IN   batches_type_table
   )
   IS
      l_proc   CONSTANT proc_name         := g_package || 'start_bee_process';
      l_batches_idx     PLS_INTEGER                        := p_batches.FIRST;
      l_request_id      fnd_concurrent_requests.request_id%TYPE;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);

      <<start_conc_prog_for_batches>>
      LOOP
         EXIT start_conc_prog_for_batches WHEN NOT p_batches.EXISTS
                                                               (l_batches_idx);
         l_request_id :=
            pay_paywsqee_pkg.paylink_request_id
               (p_business_group_id      => p_batches (l_batches_idx).business_group_id,
                p_mode                   => p_mode,
                p_batch_id               => p_batches (l_batches_idx).batch_id
               );
         l_batches_idx := p_batches.NEXT (l_batches_idx);
      END LOOP start_conc_prog_for_batches;

      hr_utility.set_location ('Leaving:' || l_proc, 100);
   END start_bee_process;

   PROCEDURE validate_bee_batches (p_batches IN batches_type_table)
   IS
      l_proc   CONSTANT proc_name := g_package || 'validate_bee_batches';
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      start_bee_process (p_mode => 'VALIDATE', p_batches => p_batches);
      hr_utility.set_location ('Leaving:' || l_proc, 100);
   END validate_bee_batches;

   PROCEDURE transfer_bee_batches (p_batches IN batches_type_table)
   IS
      l_proc   CONSTANT proc_name   := g_package || 'transfer_bee_batches';
      l_batches_idx     PLS_INTEGER := p_batches.FIRST;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      start_bee_process (p_mode => 'TRANSFER', p_batches => p_batches);
      hr_utility.set_location ('Leaving:' || l_proc, 100);
   END transfer_bee_batches;

   PROCEDURE process_bee_batches (
      p_batches         IN   batches_type_table DEFAULT batches_created,
      p_status_in_bee   IN   VARCHAR2
   )
   IS
      l_proc   CONSTANT proc_name   := g_package || 'process_bee_batches';
      l_batches_idx     PLS_INTEGER := p_batches.FIRST;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);

      IF (p_status_in_bee = 'V')
      THEN
         validate_bee_batches (p_batches);
      ELSIF (p_status_in_bee = 'T')
      THEN
         transfer_bee_batches (p_batches);
      END IF;

      hr_utility.set_location ('Leaving:' || l_proc, 100);
   END process_bee_batches;

   FUNCTION where_clause (
      p_bg_id             IN   hr_all_organization_units.business_group_id%TYPE,
      p_location_id       IN   per_all_assignments_f.location_id%TYPE,
      p_payroll_id        IN   per_all_assignments_f.payroll_id%TYPE,
      p_organization_id   IN   per_all_assignments_f.organization_id%TYPE,
      p_person_id         IN   per_all_people_f.person_id%TYPE,
      p_gre_id            IN   hr_soft_coding_keyflex.segment1%TYPE
   )
      RETURN VARCHAR2
   IS
      l_proc   CONSTANT proc_name              := g_package || 'where_clause';
      l_where_clause    hxt_interface_utilities.max_varchar := NULL;
      l_payroll         hxt_interface_utilities.varchar_256 := NULL;
      l_person          hxt_interface_utilities.varchar_256 := NULL;
      l_org             hxt_interface_utilities.varchar_256 := NULL;
      l_location        hxt_interface_utilities.varchar_256 := NULL;

      -- local functions
      FUNCTION clause_part (p_id IN NUMBER, p_clause VARCHAR2)
         RETURN VARCHAR2
      IS
         l_clause_part   hxt_interface_utilities.max_varchar := NULL;
      BEGIN
         IF p_id IS NOT NULL
         THEN
            l_clause_part := p_clause || TO_CHAR (p_id);
         ELSE
            l_clause_part := NULL;
         END IF;

         RETURN l_clause_part;
      END clause_part;
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);
      l_location := clause_part (p_location_id, ' and paa.location_id = ');
      l_payroll := clause_part (p_payroll_id, ' and paa.payroll_id = ');
      l_org := clause_part (p_organization_id, ' and paa.organization_id = ');
      l_person := clause_part (p_person_id, ' and paa.person_id = ');

      IF (    p_gre_id IS NULL
          AND p_location_id IS NULL
          AND p_payroll_id IS NULL
          AND p_organization_id IS NULL
          AND p_person_id IS NULL
         )
      THEN
         l_where_clause :=
               '[DETAIL_BLOCK.RESOURCE_TYPE] {=''PERSON'' AND}
                            [DETAIL_BLOCK.RESOURCE_ID]
                            {in (select peo.person_id
                                   from per_all_people_f peo
                                  where peo.business_group_id = '
            || p_bg_id
            || ')}';
      ELSIF p_gre_id IS NULL
      THEN
         l_where_clause :=
               '[DETAIL_BLOCK.RESOURCE_TYPE] {=''PERSON'' AND}
                            [DETAIL_BLOCK.RESOURCE_ID]
                            {in (select paa.person_id
                                   from per_all_assignments_f paa
                                  where paa.business_group_id = '
            || p_bg_id
            || l_person
            || l_payroll
            || l_location
            || l_org
            || ')}';
      ELSE
         l_where_clause :=
               '[DETAIL_BLOCK.RESOURCE_TYPE] {=''PERSON'' AND}
                      [DETAIL_BLOCK.RESOURCE_ID]
                   {in (select paa.person_id
                          from per_all_assignments_f paa,
                               hr_soft_coding_keyflex hsk
                         where paa.business_group_id = '
            || p_bg_id
            || l_person
            || l_payroll
            || l_location
            || ' and paa.soft_coding_keyflex_id = hsk.soft_coding_keyflex_id
                    and hsk.segment1 = '''
            || p_gre_id
            || ''')}';
      END IF;

      hr_utility.set_location ('Leaving ' || l_proc, 100);
      RETURN l_where_clause;
   END where_clause;

   PROCEDURE set_transaction_detail (
      p_tbb_idx     IN   PLS_INTEGER,
      p_status      IN   hxc_transactions.status%TYPE,
      p_exception   IN   hxc_transactions.exception_description%TYPE
   )
   IS
      l_proc   CONSTANT proc_name := g_package || 'set_transaction_detail';
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);
      hxc_generic_retrieval_pkg.t_tx_detail_status (p_tbb_idx) := p_status;
      hxc_generic_retrieval_pkg.t_tx_detail_exception (p_tbb_idx) :=
                                  SUBSTR (p_exception, 1, g_max_message_size);
      hr_utility.set_location ('Leaving ' || l_proc, 100);
   END set_transaction_detail;

   PROCEDURE set_transaction (
      p_process_name   IN   hxc_retrieval_processes.NAME%TYPE,
      p_status         IN   hxc_transactions.status%TYPE,
      p_exception      IN   hxc_transactions.exception_description%TYPE
   )
   IS
      l_proc   CONSTANT proc_name := g_package || 'set_transaction';
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);
      hxc_generic_retrieval_utils.set_parent_statuses;
      hxc_generic_retrieval_pkg.update_transaction_status
                      (p_process                    => p_process_name,
                       p_status                     => p_status,
                       p_exception_description      => SUBSTR
                                                           (p_exception,
                                                            1,
                                                            g_max_message_size
                                                           ),
                       p_rollback                   => FALSE
                      );
      hr_utility.set_location ('Leaving ' || l_proc, 100);
   END set_transaction;

   PROCEDURE set_successfull_trx_detail (p_tbb_idx IN PLS_INTEGER)
   IS
      l_proc   CONSTANT proc_name
                                 := g_package || 'set_successfull_trx_detail';
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);
      fnd_message.set_name (g_hxc_app_short_name, g_trx_detail_success_msg);
      set_transaction_detail (p_tbb_idx        => p_tbb_idx,
                              p_status         => g_trx_success,
                              p_exception      => fnd_message.get
                             );
      hr_utility.set_location ('Leaving ' || l_proc, 100);
   END set_successfull_trx_detail;

   PROCEDURE set_successfull_trx (
      p_process_name   IN   hxc_retrieval_processes.NAME%TYPE
   )
   IS
      l_proc   CONSTANT proc_name := g_package || 'set_successfull_trx';
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);
      fnd_message.set_name (g_hxc_app_short_name, g_trx_success_msg);
      set_transaction (p_process_name      => p_process_name,
                       p_status            => g_trx_success,
                       p_exception         => fnd_message.get
                      );
      hr_utility.set_location ('Leaving ' || l_proc, 100);
   END set_successfull_trx;

   PROCEDURE set_sqlerror_trx_detail (p_tbb_idx IN PLS_INTEGER)
   IS
      l_proc   CONSTANT proc_name := g_package || 'set_sqlerror_trx_detail';
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);
      hr_utility.set_location ('   Error found = ' || SQLERRM, 20);
      set_transaction_detail (p_tbb_idx        => p_tbb_idx,
                              p_status         => g_trx_error,
                              p_exception      =>    'The error is : '
                                                  || TO_CHAR (SQLCODE)
                                                  || ' '
                                                  || SQLERRM
                             );
      hr_utility.set_location ('Leaving ' || l_proc, 100);
   END set_sqlerror_trx_detail;

   PROCEDURE set_sqlerror_trx (
      p_process_name   IN   hxc_retrieval_processes.NAME%TYPE
   )
   IS
      l_proc   CONSTANT proc_name := g_package || 'set_sqlerror_trx';
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);
      set_transaction (p_process_name      => p_process_name,
                       p_status            => g_trx_error,
                       p_exception         =>    'The error is : '
                                              || TO_CHAR (SQLCODE)
                                              || ' '
                                              || SQLERRM
                      );
      hr_utility.set_location ('Leaving ' || l_proc, 100);
   END set_sqlerror_trx;

   PROCEDURE process_otlr_employees (
      p_bg_id                        IN              hr_all_organization_units.business_group_id%TYPE,
      p_session_date                 IN              DATE, -- Bug 6121705, need date for reversal batch creation
      p_start_date                   IN              VARCHAR2,
      --hxc_time_building_blocks.start_time%TYPE,
      p_end_date                     IN              VARCHAR2,
      --hxc_time_building_blocks.stop_time%TYPE,
      p_where_clause                 IN              hxt_interface_utilities.max_varchar,
      p_retrieval_transaction_code   IN              hxc_transactions.transaction_code%TYPE,
      p_batch_ref                    IN              pay_batch_headers.batch_reference%TYPE,
      p_unique_params                IN              hxt_interface_utilities.max_varchar,
      p_incremental                  IN              hxt_interface_utilities.flag_varchar
            DEFAULT 'Y',
      p_transfer_to_bee              IN              hxt_interface_utilities.flag_varchar
            DEFAULT 'N',
      p_no_otm                       IN OUT NOCOPY   hxt_interface_utilities.flag_varchar
   )
   AS
      l_proc   CONSTANT proc_name := g_package || 'process_otlr_employees';

      l_dup_count NUMBER; -- Bug 6121705

   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);
      -- transfer the employees with OTM Rules = Yes
      hxt_otc_retrieval_interface.transfer_to_otm
               (p_bg_id                           => p_bg_id,
                p_incremental                     => p_incremental,
                p_start_date                      => p_start_date,
                p_end_date                        => p_end_date,
                p_where_clause                    => p_where_clause,
                p_transfer_to_bee                 => p_transfer_to_bee,
                p_retrieval_transaction_code      => p_retrieval_transaction_code,
                p_batch_ref                       => p_batch_ref,
                p_no_otm                          => p_no_otm,
                p_unique_params                   => p_unique_params,
                p_since_date                      => l_since_date
               );

      -- Bug 6121705
      --  For automatic reversal batch creation if there is a rule evaluation pref
      --  change.

      -- Earlier hxc_gen_retrieve_utils.chk_retrieve would have populated
      -- HXC_BEE_PREF_ADJ_LINES with the details that were previously transferred
      -- and had a preference change before transfer this time.
      -- Check the count of those records which are for time store. Now we
      -- are running OTM batches. Meaning, if there was an earlier batch, it would
      -- have been from time store. There needs to be reverse batches for those.

      -- The rownum condition is put there especially for performance. On worst
      -- case there could be thousands of records in there, and you just wanna
      -- know if there is atleast one. If the optimizer is not set to take the first
      -- n rows, your count(*) would wait until all rows are returned. With the rownum
      -- it will only pull out your first record if there exists one, else zero. So
      -- the result is only 1 or 0.

      SELECT COUNT(*)
        INTO l_dup_count
        FROM hxc_bee_pref_adj_lines
       WHERE batch_source = 'Time Store'
         AND ROWNUM < 2 ;


      -- This condition will call a proc to create reverse Time Store batches for the
      -- details in there.
      IF l_dup_count > 0
      THEN
           make_adjustments_bee(p_batch_ref,     -- we need the current batch reference for our adj batch
                                p_bg_id,         -- bg_id to create batch
                                p_session_date); -- batch is created with this session date
      END IF;

      hr_utility.set_location ('Leaving ' || l_proc, 100);
   END process_otlr_employees;

   PROCEDURE extract_data_from_attr_tbl (
      p_bg_id            IN              hr_all_organization_units.business_group_id%TYPE,
      p_attr_tbl         IN              hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id           IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_det_tbb_idx      IN              PLS_INTEGER,
      p_cost_flex_id     IN              per_business_groups_perf.cost_allocation_structure%TYPE,
      p_effective_date   IN              pay_element_types_f.effective_start_date%TYPE,
      p_attr_tbl_idx     IN OUT NOCOPY   PLS_INTEGER,
      p_bee_rec          IN OUT NOCOPY   hxt_interface_utilities.bee_rec
   )
   AS
      l_proc        CONSTANT proc_name
                                 := g_package || 'extract_data_from_attr_tbl';
      e_no_element_type_id   EXCEPTION;
      l_start_attr_tbl_idx   PLS_INTEGER;
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);

      IF (hxt_interface_utilities.is_in_sync
                   (p_check_tbb_id        => p_attr_tbl (NVL (p_attr_tbl_idx,
                                                              p_attr_tbl.FIRST
                                                             )
                                                        ).bb_id,
                    p_against_tbb_id      => p_tbb_id
                   )
         )
      THEN
         -- We first have to find the element_id cause we need that for converting
         -- the associated IVs.
         p_bee_rec.pay_batch_line.element_type_id :=
            hxt_interface_utilities.find_element_id_in_attr_tbl
                                          (p_att_table           => p_attr_tbl,
                                           p_tbb_id              => p_tbb_id,
                                           p_start_position      => p_attr_tbl_idx
                                          );

         IF (p_bee_rec.pay_batch_line.element_type_id IS NULL)
         THEN
            RAISE e_no_element_type_id;
         END IF;

         l_start_attr_tbl_idx := p_attr_tbl_idx;
         -- Now find all the other data (IVs, Asg Data and Cost Segments)
         hxt_interface_utilities.find_other_in_attr_tbl
               (p_bg_id                => p_bg_id,
                p_att_table            => p_attr_tbl,
                p_tbb_id               => p_tbb_id,
                p_element_type_id      => p_bee_rec.pay_batch_line.element_type_id,
                p_cost_flex_id         => p_cost_flex_id,
                p_effective_date       => p_effective_date,
                p_start_position       => l_start_attr_tbl_idx,
                p_ending_position      => p_attr_tbl_idx,
                p_bee_rec              => p_bee_rec
               );
      ELSE
         fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token ('PROCEDURE', l_proc);
         fnd_message.set_token ('STEP', 'tbb mismatch');
         fnd_message.raise_error;
      END IF;

      hr_utility.set_location ('Leaving ' || l_proc, 100);
   EXCEPTION
      WHEN e_no_element_type_id
      THEN
         fnd_message.set_name (g_hxc_app_short_name,
                               'HXC_HRPAY_RET_NO_ELE_TYPE_ID'
                              );
         set_transaction_detail (p_tbb_idx        => p_det_tbb_idx,
                                 p_status         => g_trx_error,
                                 p_exception      => fnd_message.get
                                );
         RAISE e_continue;
   END extract_data_from_attr_tbl;

   PROCEDURE parse_cost_flex (
      p_business_group_id   IN              pay_batch_headers.business_group_id%TYPE,
      p_bee_rec             IN OUT NOCOPY   hxt_interface_utilities.bee_rec
   )
   AS
      l_proc   CONSTANT proc_name := g_package || 'parse_cost_flex';
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);

      IF NOT (hxt_interface_utilities.cost_segments_all_null (p_bee_rec))
      THEN
         -- get the cost_allocation_flexfield_id (we can do this after the COST
         -- segments have been set) ...
         p_bee_rec.pay_batch_line.cost_allocation_keyflex_id :=
            hxt_interface_utilities.cost_allocation_kff_id
                                 (p_business_group_id      => p_business_group_id,
                                  p_bee_rec                => p_bee_rec
                                 );
         -- ... and the concatinated segments
         p_bee_rec.pay_batch_line.concatenated_segments :=
            hxt_interface_utilities.costflex_concat_segments
               (p_cost_allocation_keyflex_id      => p_bee_rec.pay_batch_line.cost_allocation_keyflex_id
               );
      ELSE
         p_bee_rec.pay_batch_line.cost_allocation_keyflex_id := NULL;
         p_bee_rec.pay_batch_line.concatenated_segments := NULL;
      END IF;

      hr_utility.set_location ('Leaving ' || l_proc, 100);
   END parse_cost_flex;

   PROCEDURE bee_batch_line (
      p_bg_id          IN              pay_batch_headers.business_group_id%TYPE,
      p_tbb_rec        IN              hxc_generic_retrieval_pkg.r_building_blocks,
      p_det_tbb_idx    IN              PLS_INTEGER,
      p_attr_tbl       IN              hxc_generic_retrieval_pkg.t_time_attribute,
      p_attr_tbl_idx   IN OUT NOCOPY   PLS_INTEGER,
      p_bee_rec        OUT NOCOPY      hxt_interface_utilities.bee_rec,
      p_cost_flex_id   IN              per_business_groups_perf.cost_allocation_structure%TYPE,
      p_is_old         IN              BOOLEAN DEFAULT FALSE
   )
   AS
      l_proc              CONSTANT proc_name := g_package || 'bee_batch_line';
      l_effective_date             DATE       := TRUNC (p_tbb_rec.start_time);
      e_no_assignment              EXCEPTION;
      l_geocode                    VARCHAR2 (21);
      l_hours_iv_position          PLS_INTEGER;
      l_jurisdiction_iv_position   PLS_INTEGER;
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);
      extract_data_from_attr_tbl (p_bg_id               => p_bg_id,
                                  p_attr_tbl            => p_attr_tbl,
                                  p_tbb_id              => p_tbb_rec.bb_id,
                                  p_det_tbb_idx         => p_det_tbb_idx,
                                  p_cost_flex_id        => p_cost_flex_id,
                                  p_effective_date      => l_effective_date,
                                  p_attr_tbl_idx        => p_attr_tbl_idx,
                                  p_bee_rec             => p_bee_rec
                                 );
      -- get input value sequence for Hours and Jurisdiction
      hxt_interface_utilities.hours_iv_position
               (p_element_type_id               => p_bee_rec.pay_batch_line.element_type_id,
                p_effective_date                => l_effective_date,
                p_hours_iv_position             => l_hours_iv_position,
                p_jurisdiction_iv_position      => l_jurisdiction_iv_position,
                p_iv_type                       => hxt_interface_utilities.g_hour_juris_iv
               );
      -- Assign Hours to the right input value
      hxt_interface_utilities.assign_iv
                (p_iv_seq       => l_hours_iv_position,
                 p_value        =>   (p_tbb_rec.measure --Days Vs Hour Enhancement
                                     )
                                   * hxt_interface_utilities.hours_factor
                                                                     (p_is_old),
                 p_bee_rec      => p_bee_rec
                );

      -- get geocode if its input value sequence is not null
      IF (l_jurisdiction_iv_position IS NOT NULL)
      THEN
         l_geocode :=
            hxt_interface_utilities.get_geocode_from_attr_tab
                                                            (p_attr_tbl,
                                                             p_tbb_rec.bb_id,
                                                             NULL
                                                            );

         IF (l_geocode <> '00-000-0000')
         THEN
            hxt_interface_utilities.assign_iv
                                     (p_iv_seq       => l_jurisdiction_iv_position,
                                      p_value        => l_geocode,
                                      p_bee_rec      => p_bee_rec
                                     );
         END IF;
      END IF;

      -- set the assignment if it has not bee set yet (i.e. there was no
      -- assignment attribute)
      IF (p_bee_rec.pay_batch_line.assignment_id IS NULL)
      THEN
         hxt_interface_utilities.assignment_info
            (p_tbb_rec                => p_tbb_rec,
             p_assignment_id          => p_bee_rec.pay_batch_line.assignment_id,
             p_assignment_number      => p_bee_rec.pay_batch_line.assignment_number
            );
      END IF;

      IF (p_bee_rec.pay_batch_line.assignment_id IS NULL)
      THEN
         RAISE e_no_assignment;
      END IF;

      parse_cost_flex (p_business_group_id      => p_bg_id,
                       p_bee_rec                => p_bee_rec);
      hr_utility.set_location ('Leaving ' || l_proc, 100);
   EXCEPTION
      WHEN e_no_assignment
      THEN
         fnd_message.set_name (g_hxc_app_short_name,
                               'HXC_HRPAY_RET_NO_ASSIGN'
                              );
         set_transaction_detail (p_tbb_idx        => p_det_tbb_idx,
                                 p_status         => g_trx_error,
                                 p_exception      => fnd_message.get
                                );
         RAISE e_continue;
   END bee_batch_line;

   FUNCTION batch_name (
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN pay_batch_headers.batch_name%TYPE
   AS
      l_proc   CONSTANT proc_name                := g_package || 'batch_name';
      l_batch_suffix    pay_batch_headers.batch_name%TYPE;         -- NUMBER;
      l_batch_name      pay_batch_headers.batch_name%TYPE;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      l_batch_suffix :=
                     TO_CHAR (hxt_interface_utilities.conc_request_id_suffix);
      l_batch_suffix :=
            l_batch_suffix
         || hxt_interface_utilities.batchname_suffix_connector
         || hxt_interface_utilities.free_batch_suffix
                                      (p_batch_reference      => p_batch_reference,
                                       p_bg_id                => p_bg_id
                                      );
      l_batch_name :=
            p_batch_reference
         || hxt_interface_utilities.batchname_suffix_connector
         || l_batch_suffix;
      hr_utility.set_location ('   returning batch name: ' || l_batch_name,
                               20);
      hr_utility.set_location ('Leaving:' || l_proc, 100);
      RETURN l_batch_name;
   END batch_name;

   FUNCTION create_batch_header (
      p_batch_name        IN   pay_batch_headers.batch_name%TYPE,
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_batch_source      IN   pay_batch_headers.batch_source%TYPE
            DEFAULT g_time_store_batch_source,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE,
      p_session_date      IN   DATE,
      p_det_tbb_idx       IN   PLS_INTEGER
   )
      RETURN pay_batch_headers.batch_id%TYPE
   AS
      l_proc           CONSTANT proc_name
                                        := g_package || 'create_batch_header';
      l_object_version_number   pay_batch_headers.object_version_number%TYPE;
      l_new_batch               pay_batch_headers.batch_id%TYPE;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      pay_batch_element_entry_api.create_batch_header
                          (p_session_date               => p_session_date,
                           p_batch_name                 => p_batch_name,
                           p_business_group_id          => p_bg_id,
                           p_action_if_exists           => g_insert_if_exist,
                           p_batch_reference            => p_batch_reference,
                           p_batch_source               => p_batch_source,
                           p_batch_id                   => l_new_batch,
                           p_object_version_number      => l_object_version_number
                          );
      record_batch_info (p_batch_id               => l_new_batch,
                         p_business_group_id      => p_bg_id,
                         p_batch_reference        => p_batch_reference,
                         p_batch_name             => p_batch_name
                        );
      hr_utility.set_location ('   returning batch_id = :' || l_new_batch, 20);
      hr_utility.set_location ('Leaving:' || l_proc, 100);
      RETURN l_new_batch;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name (g_hxc_app_short_name,
                               'HXC_HRPAY_RET_BATCH_HDR_API'
                              );
         set_transaction_detail (p_tbb_idx        => p_det_tbb_idx,
                                 p_status         => g_trx_error,
                                 p_exception      => fnd_message.get
                                );
         RAISE e_halt;
   END create_batch_header;

   FUNCTION create_batch_header (
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_batch_source      IN   pay_batch_headers.batch_source%TYPE
            DEFAULT g_time_store_batch_source,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE,
      p_session_date      IN   DATE,
      p_det_tbb_idx       IN   PLS_INTEGER
   )
      RETURN pay_batch_headers.batch_id%TYPE
   AS
      l_proc           CONSTANT proc_name
                                        := g_package || 'create_batch_header';
      l_object_version_number   pay_batch_headers.object_version_number%TYPE;
      l_batch_name              pay_batch_headers.batch_name%TYPE;
      l_new_batch               pay_batch_headers.batch_id%TYPE;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      l_batch_name :=
         batch_name (p_batch_reference      => p_batch_reference,
                     p_bg_id                => p_bg_id
                    );
      -- I might need to add a check here for max_lines_exceeded if I add
      -- functionality to add data to existing batches...
      l_new_batch :=
         create_batch_header (p_batch_name           => l_batch_name,
                              p_batch_reference      => p_batch_reference,
                              p_batch_source         => p_batch_source,
                              p_bg_id                => p_bg_id,
                              p_session_date         => p_session_date,
                              p_det_tbb_idx          => p_det_tbb_idx
                             );
      hr_utility.set_location ('   returning batch_id = :' || l_new_batch, 20);
      hr_utility.set_location ('Leaving:' || l_proc, 100);
      RETURN l_new_batch;
   END create_batch_header;

   -- Bug 9494444
   -- Added new paramter to separately record the batch and line
   -- information for a retro batch.
   PROCEDURE create_batch_line (
      p_batch_id         IN   pay_batch_headers.batch_id%TYPE,
      p_det_tbb_idx      IN   PLS_INTEGER,
      p_session_date     IN   DATE,
      p_effective_date   IN   DATE,
      p_batch_sequence   IN   pay_batch_lines.batch_sequence%TYPE,
      p_bee_rec          IN   hxt_interface_utilities.bee_rec,
      p_bg_id            IN   pay_batch_headers.business_group_id%TYPE,
      p_is_retro         IN   BOOLEAN DEFAULT FALSE     -- Bug 9494444
   )
   AS
      l_proc           CONSTANT proc_name := g_package || 'create_batch_line';
      l_total_lines             NUMBER;
      l_batch_line_id           pay_batch_lines.batch_line_id%TYPE;
      l_object_version_number   pay_batch_lines.object_version_number%TYPE;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      pay_batch_element_entry_api.create_batch_line
         (p_session_date                    => p_session_date,
          p_batch_id                        => p_batch_id,
          p_assignment_id                   => p_bee_rec.pay_batch_line.assignment_id,
          p_assignment_number               => p_bee_rec.pay_batch_line.assignment_number,
          p_batch_sequence                  => p_batch_sequence,
          p_concatenated_segments           => p_bee_rec.pay_batch_line.concatenated_segments,
          p_cost_allocation_keyflex_id      => p_bee_rec.pay_batch_line.cost_allocation_keyflex_id,
          p_date_earned                     => p_effective_date,
          p_effective_date                  => p_effective_date,
          p_effective_start_date            => p_effective_date,
          p_effective_end_date              => p_effective_date,
          p_element_name                    => p_bee_rec.pay_batch_line.element_name,
          p_element_type_id                 => p_bee_rec.pay_batch_line.element_type_id,
          p_segment1                        => p_bee_rec.pay_batch_line.segment1,
          p_segment2                        => p_bee_rec.pay_batch_line.segment2,
          p_segment3                        => p_bee_rec.pay_batch_line.segment3,
          p_segment4                        => p_bee_rec.pay_batch_line.segment4,
          p_segment5                        => p_bee_rec.pay_batch_line.segment5,
          p_segment6                        => p_bee_rec.pay_batch_line.segment6,
          p_segment7                        => p_bee_rec.pay_batch_line.segment7,
          p_segment8                        => p_bee_rec.pay_batch_line.segment8,
          p_segment9                        => p_bee_rec.pay_batch_line.segment9,
          p_segment10                       => p_bee_rec.pay_batch_line.segment10,
          p_segment11                       => p_bee_rec.pay_batch_line.segment11,
          p_segment12                       => p_bee_rec.pay_batch_line.segment12,
          p_segment13                       => p_bee_rec.pay_batch_line.segment13,
          p_segment14                       => p_bee_rec.pay_batch_line.segment14,
          p_segment15                       => p_bee_rec.pay_batch_line.segment15,
          p_segment16                       => p_bee_rec.pay_batch_line.segment16,
          p_segment17                       => p_bee_rec.pay_batch_line.segment17,
          p_segment18                       => p_bee_rec.pay_batch_line.segment18,
          p_segment19                       => p_bee_rec.pay_batch_line.segment19,
          p_segment20                       => p_bee_rec.pay_batch_line.segment20,
          p_segment21                       => p_bee_rec.pay_batch_line.segment21,
          p_segment22                       => p_bee_rec.pay_batch_line.segment22,
          p_segment23                       => p_bee_rec.pay_batch_line.segment23,
          p_segment24                       => p_bee_rec.pay_batch_line.segment24,
          p_segment25                       => p_bee_rec.pay_batch_line.segment25,
          p_segment26                       => p_bee_rec.pay_batch_line.segment26,
          p_segment27                       => p_bee_rec.pay_batch_line.segment27,
          p_segment28                       => p_bee_rec.pay_batch_line.segment28,
          p_segment29                       => p_bee_rec.pay_batch_line.segment29,
          p_segment30                       => p_bee_rec.pay_batch_line.segment30,
          p_value_1                         => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_1,
                                                   1,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_2                         => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_2,
                                                   2,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_3                         => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_3,
                                                   3,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_4                         => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_4,
                                                   4,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_5                         => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_5,
                                                   5,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_6                         => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_6,
                                                   6,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_7                         => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_7,
                                                   7,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_8                         => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_8,
                                                   8,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_9                         => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_9,
                                                   9,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_10                        => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_10,
                                                   10,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_11                        => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_11,
                                                   11,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_12                        => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_12,
                                                   12,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_13                        => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_13,
                                                   13,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_14                        => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_14,
                                                   14,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_value_15                        => display_value
                                                  (p_bee_rec.pay_batch_line.element_type_id,
                                                   p_bee_rec.pay_batch_line.value_15,
                                                   15,
                                                   p_session_date,
                                                   p_bg_id
                                                  ),
          p_batch_line_id                   => l_batch_line_id,
          p_object_version_number           => l_object_version_number
         );

      -- Bug 9494444
      -- Record the line and the batch in the respective table to be passed back to
      -- OTL.
      IF p_is_retro
      THEN
         hxc_generic_retrieval_pkg.t_old_detail_rec_lines(p_det_tbb_idx).rec_id := l_batch_line_id;
         hxc_generic_retrieval_pkg.t_old_detail_rec_lines(p_det_tbb_idx).batch_id := p_batch_id;
      ELSE
         hxc_generic_retrieval_pkg.t_detail_rec_lines(p_det_tbb_idx).rec_id := l_batch_line_id;
         hxc_generic_retrieval_pkg.t_detail_rec_lines(p_det_tbb_idx).batch_id := p_batch_id;
      END IF;


      hr_utility.set_location ('Leaving:' || l_proc, 100);
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name (g_hxc_app_short_name,
                               'HXC_HRPAY_RET_BATCH_LINE_API'
                              );
         set_transaction_detail (p_tbb_idx        => p_det_tbb_idx,
                                 p_status         => g_trx_error,
                                 p_exception      => SQLERRM
                                );
         RAISE e_continue;
   END create_batch_line;

   -- Bug 9494444
   -- Added new parameter for marking retro lines.
   PROCEDURE add_to_batch (
      p_batch_reference   IN              pay_batch_headers.batch_reference%TYPE,
      p_batch_id          IN OUT NOCOPY   pay_batch_headers.batch_id%TYPE,
      p_det_tbb_idx       IN              PLS_INTEGER,
      p_batch_sequence    IN OUT NOCOPY   pay_batch_lines.batch_sequence%TYPE,
      p_batch_lines       IN OUT NOCOPY   PLS_INTEGER,
      p_bg_id             IN              pay_batch_headers.business_group_id%TYPE,
      p_session_date      IN              DATE,
      p_effective_date    IN              DATE,
      p_bee_rec           IN              hxt_interface_utilities.bee_rec,
      p_is_retro          IN              BOOLEAN DEFAULT FALSE
   )
   AS
      l_proc        CONSTANT proc_name := g_package || 'add_to_batch';
      l_max_lines_exceeded   BOOLEAN;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);

      IF (p_batch_id IS NULL)
      THEN                                                      -- first call
         p_batch_id :=
            create_batch_header (p_batch_reference      => p_batch_reference,
                                 p_bg_id                => p_bg_id,
                                 p_session_date         => p_session_date,
                                 p_det_tbb_idx          => p_det_tbb_idx
                                );
         p_batch_sequence := 1;
         p_batch_lines := 0;
      ELSE
         IF (    g_assignment_id <> p_bee_rec.pay_batch_line.assignment_id
             AND g_assignment_id <> -1
            )
         THEN
            hxt_interface_utilities.max_lines_exceeded
                                (p_batch_id                => p_batch_id,
                                 p_number_lines            => p_batch_lines,
                                 p_max_lines_exceeded      => l_max_lines_exceeded
                                );

            IF (l_max_lines_exceeded)
            THEN
               p_batch_id :=
                  create_batch_header
                                     (p_batch_reference      => p_batch_reference,
                                      p_bg_id                => p_bg_id,
                                      p_session_date         => p_session_date,
                                      p_det_tbb_idx          => p_det_tbb_idx
                                     );
               p_batch_sequence := 1;
               p_batch_lines := 0;
            END IF;                                      -- max_lines_exceeded
         END IF;                                       -- (p_batch_id IS NULL)
      END IF;                                          -- g_assignment_id test

      create_batch_line (p_batch_id            => p_batch_id,
                         p_det_tbb_idx         => p_det_tbb_idx,
                         p_session_date        => p_session_date,
                         p_effective_date      => p_effective_date,
                         p_batch_sequence      => p_batch_sequence,
                         p_bee_rec             => p_bee_rec,
                         p_bg_id               => p_bg_id,
                         p_is_retro            => p_is_retro  -- Bug 9394444
                        );
      g_assignment_id := p_bee_rec.pay_batch_line.assignment_id;
      p_batch_lines := p_batch_lines + 1;
      p_batch_sequence := p_batch_sequence + 1;
      hr_utility.set_location ('   OUT p_batch_id = ' || p_batch_id, 20);
      hr_utility.set_location ('   OUT p_batch_sequence = '
                               || p_batch_sequence,
                               30
                              );
      hr_utility.set_location ('   OUT p_batch_lines = ' || p_batch_lines, 40);
      hr_utility.set_location ('Leaving:' || l_proc, 100);
   END add_to_batch;

   PROCEDURE add_lines_to_bee_batch (
      p_batch_reference   IN              pay_batch_headers.batch_reference%TYPE,
      p_bg_id             IN              pay_batch_headers.business_group_id%TYPE,
      p_session_date      IN              DATE,
      p_tbb_tbl           IN              hxc_generic_retrieval_pkg.t_building_blocks,
      p_attr_tbl          IN              hxc_generic_retrieval_pkg.t_time_attribute,
      p_old_tbb_tbl       IN              hxc_generic_retrieval_pkg.t_building_blocks,
      p_old_attr_tbl      IN              hxc_generic_retrieval_pkg.t_time_attribute,
      p_batch_id          IN OUT NOCOPY   NUMBER,
      p_retro_batch_id    IN OUT NOCOPY   NUMBER
   )
   AS
      l_proc          CONSTANT proc_name
                                     := g_package || 'add_lines_to_bee_batch';
      l_det_tbb_idx            PLS_INTEGER;
      l_det_old_tbb_idx        PLS_INTEGER                               := 0;
      l_det_attr_idx           PLS_INTEGER;
      l_det_old_attr_idx       PLS_INTEGER;
      l_bee_rec                hxt_interface_utilities.bee_rec;
      l_old_bee_rec            hxt_interface_utilities.bee_rec;
      l_empty_bee_rec          hxt_interface_utilities.bee_rec;
      l_cost_flex_id           per_business_groups_perf.cost_allocation_structure%TYPE
                  := hxt_interface_utilities.cost_flex_structure_id (p_bg_id);
      l_batch_id               pay_batch_headers.batch_reference%TYPE;
      l_batch_sequence         pay_batch_lines.batch_sequence%TYPE;
      l_retro_batch_id         pay_batch_headers.batch_reference%TYPE;
      l_retro_batch_sequence   pay_batch_lines.batch_sequence%TYPE;
      l_batch_lines            PLS_INTEGER;
      l_retro_batch_lines      PLS_INTEGER;
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);
      l_batch_id := p_batch_id;
      l_retro_batch_id := p_retro_batch_id;
      l_det_tbb_idx := p_tbb_tbl.FIRST;

      <<process_all_detail_tbb>>
      LOOP

         <<processing_tbb>>
         BEGIN
            EXIT process_all_detail_tbb WHEN NOT p_tbb_tbl.EXISTS
                                                               (l_det_tbb_idx);

            IF (hxt_interface_utilities.is_changed (p_tbb_tbl (l_det_tbb_idx))
               )
            THEN                            -- get previously transferred line
               l_det_old_tbb_idx := l_det_old_tbb_idx + 1;

               IF (hxt_interface_utilities.is_in_sync
                      (p_check_tbb_id        => p_old_tbb_tbl
                                                            (l_det_old_tbb_idx).bb_id,
                       p_against_tbb_id      => p_tbb_tbl (l_det_tbb_idx).bb_id
                      )
                  )
               THEN
                  bee_batch_line
                              (p_bg_id             => p_bg_id,
                               p_tbb_rec           => p_old_tbb_tbl
                                                            (l_det_old_tbb_idx),
                               p_det_tbb_idx       => l_det_old_tbb_idx,
                               p_attr_tbl          => p_old_attr_tbl,
                               p_attr_tbl_idx      => l_det_old_attr_idx,
                               p_bee_rec           => l_old_bee_rec,
                               p_cost_flex_id      => l_cost_flex_id,
                               p_is_old            => TRUE
                              );
                  -- add to retro batch for backing out
                  -- Bug 9494444
                  -- This is a call for retro batch, so pass the flag.
                  add_to_batch
                     (p_batch_reference      =>    p_batch_reference
                                                || retro_batch_suffix,
                      p_batch_id             => l_retro_batch_id,
                      p_det_tbb_idx          => l_det_old_tbb_idx,
                      p_batch_sequence       => l_retro_batch_sequence,
                      p_batch_lines          => l_retro_batch_lines,
                      p_bg_id                => p_bg_id,
                      p_session_date         => p_session_date,
                      p_effective_date       => TRUNC
                                                   (p_old_tbb_tbl
                                                            (l_det_old_tbb_idx).start_time
                                                   ),
                      p_bee_rec              => l_old_bee_rec,
                      p_is_retro             => TRUE    -- Bug 9494444
                     );

                  IF NOT (hxt_interface_utilities.is_deleted
                                                     (p_tbb_tbl (l_det_tbb_idx)
                                                     )
                         )
                  THEN           -- must be an update to an existing BEE entry
                     bee_batch_line (p_bg_id             => p_bg_id,
                                     p_tbb_rec           => p_tbb_tbl
                                                                (l_det_tbb_idx),
                                     p_det_tbb_idx       => l_det_tbb_idx,
                                     p_attr_tbl          => p_attr_tbl,
                                     p_attr_tbl_idx      => l_det_attr_idx,
                                     p_bee_rec           => l_bee_rec,
                                     p_cost_flex_id      => l_cost_flex_id
                                    );

                     -- Temporary switch allowing simulation of old usage
                     -- Old usage = New and Update rows go into New Batch
                     --             Previously Transferred rows go into Retro Batch
                     -- New usage = New rows go into New Batch
                     --             Previously Transferred and Updated rows go into
                     --             Retro Batch
                     IF (hxt_interface_utilities.use_old_retro_batches)
                     THEN
                        add_to_batch
                           (p_batch_reference      => p_batch_reference,
                            p_batch_id             => l_batch_id,
                            p_det_tbb_idx          => l_det_tbb_idx,
                            p_batch_sequence       => l_batch_sequence,
                            p_batch_lines          => l_batch_lines,
                            p_bg_id                => p_bg_id,
                            p_session_date         => p_session_date,
                            p_effective_date       => TRUNC
                                                         (p_tbb_tbl
                                                                (l_det_tbb_idx).start_time
                                                         ),
                            p_bee_rec              => l_bee_rec
                           );
                     ELSE
                        add_to_batch
                           (p_batch_reference      =>    p_batch_reference
                                                      || retro_batch_suffix,
                            p_batch_id             => l_retro_batch_id,
                            p_det_tbb_idx          => l_det_tbb_idx,
                            p_batch_sequence       => l_retro_batch_sequence,
                            p_batch_lines          => l_retro_batch_lines,
                            p_bg_id                => p_bg_id,
                            p_session_date         => p_session_date,
                            p_effective_date       => TRUNC
                                                         (p_tbb_tbl
                                                                (l_det_tbb_idx).start_time
                                                         ),
                            p_bee_rec              => l_bee_rec
                           );
                     END IF;
                  ELSE
                     -- Delete, so we only need to backout the previously
                     -- transferred data which we already did so nothing to do
                     l_det_attr_idx :=
                        hxt_interface_utilities.skip_attributes
                                 (p_att_table           => p_attr_tbl,
                                  p_tbb_id              => p_tbb_tbl
                                                                (l_det_tbb_idx).bb_id,
                                  p_start_position      => l_det_attr_idx
                                 );
                     l_bee_rec := l_empty_bee_rec;
                  END IF;
               ELSE             -- IF (hxt_interface_utilities.is_in_sync ...)
                  fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                  fnd_message.set_token ('PROCEDURE', l_proc);
                  fnd_message.set_token ('STEP', 'tbb mismatch');
                  fnd_message.raise_error;
               END IF;
            ELSE          -- new record (i.e. never transferred to BEE before)
               IF NOT (hxt_interface_utilities.is_deleted
                                                     (p_tbb_tbl (l_det_tbb_idx)
                                                     )
                      )
               THEN
                  bee_batch_line (p_bg_id             => p_bg_id,
                                  p_tbb_rec           => p_tbb_tbl
                                                                (l_det_tbb_idx),
                                  p_det_tbb_idx       => l_det_tbb_idx,
                                  p_attr_tbl          => p_attr_tbl,
                                  p_attr_tbl_idx      => l_det_attr_idx,
                                  p_bee_rec           => l_bee_rec,
                                  p_cost_flex_id      => l_cost_flex_id
                                 );
                  add_to_batch
                     (p_batch_reference      => p_batch_reference,
                      p_batch_id             => l_batch_id,
                      p_det_tbb_idx          => l_det_tbb_idx,
                      p_batch_sequence       => l_batch_sequence,
                      p_batch_lines          => l_batch_lines,
                      p_bg_id                => p_bg_id,
                      p_session_date         => p_session_date,
                      p_effective_date       => TRUNC
                                                   (p_tbb_tbl (l_det_tbb_idx).start_time
                                                   ),
                      p_bee_rec              => l_bee_rec
                     );
               ELSE
                  -- deleted but never existed in BEE so we don't have to do anything
                  l_det_attr_idx :=
                     hxt_interface_utilities.skip_attributes
                                 (p_att_table           => p_attr_tbl,
                                  p_tbb_id              => p_tbb_tbl
                                                                (l_det_tbb_idx).bb_id,
                                  p_start_position      => l_det_attr_idx
                                 );
                  l_bee_rec := l_empty_bee_rec;
               END IF;
            END IF;

            set_successfull_trx_detail (p_tbb_idx => l_det_tbb_idx);
            l_det_tbb_idx := p_tbb_tbl.NEXT (l_det_tbb_idx);
         EXCEPTION
            WHEN e_continue
            THEN
               l_det_attr_idx :=
                  hxt_interface_utilities.skip_attributes
                                 (p_att_table           => p_attr_tbl,
                                  p_tbb_id              => p_tbb_tbl
                                                                (l_det_tbb_idx).bb_id,
                                  p_start_position      => l_det_attr_idx
                                 );
               l_det_old_attr_idx :=
                  hxt_interface_utilities.skip_attributes
                                  (p_att_table           => p_old_attr_tbl,
                                   p_tbb_id              => p_tbb_tbl
                                                                (l_det_tbb_idx).bb_id,
                                   p_start_position      => l_det_old_attr_idx
                                  );
               l_bee_rec := l_empty_bee_rec;
               l_det_tbb_idx := p_tbb_tbl.NEXT (l_det_tbb_idx);
            WHEN e_halt
            THEN
               RAISE;
            WHEN OTHERS
            THEN
               set_sqlerror_trx_detail (p_tbb_idx => l_det_tbb_idx);
               l_det_tbb_idx := p_tbb_tbl.NEXT (l_det_tbb_idx);
         END processing_tbb;
      END LOOP process_all_detail_tbb;

      set_successfull_trx (g_bee_retrieval_process);
      hxt_interface_utilities.perform_commit;
      p_batch_id := l_batch_id;
      p_retro_batch_id := l_retro_batch_id;
      hr_utility.set_location ('Leaving ' || l_proc, 100);
   END add_lines_to_bee_batch;

   PROCEDURE process_non_otlr_employees (
      p_bg_id                        IN   hr_all_organization_units.business_group_id%TYPE,
      p_start_date                   IN   hxc_time_building_blocks.start_time%TYPE,
      p_end_date                     IN   hxc_time_building_blocks.stop_time%TYPE,
      p_session_date                 IN   DATE,
      p_where_clause                 IN   hxt_interface_utilities.max_varchar,
      p_retrieval_transaction_code   IN   hxc_transactions.transaction_code%TYPE,
      p_batch_ref                    IN   pay_batch_headers.batch_reference%TYPE,
      p_unique_params                IN   hxt_interface_utilities.max_varchar,
      p_status_in_bee                IN   VARCHAR2,
      p_incremental                  IN   hxt_interface_utilities.flag_varchar
            DEFAULT 'Y',
      p_transfer_to_bee              IN   hxt_interface_utilities.flag_varchar
            DEFAULT 'N',
      p_no_otm                       IN   hxt_interface_utilities.flag_varchar
            DEFAULT 'N'
   )
   AS
      l_proc               CONSTANT proc_name
                                 := g_package || 'process_non_otlr_employees';
      l_supa_chunk_batch_id         pay_batch_headers.batch_reference%TYPE
                                                                      := NULL;
      l_supa_chunk_retro_batch_id   pay_batch_headers.batch_reference%TYPE
                                                                      := NULL;

      l_dup_count NUMBER; -- Bug 6121705

   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);

      <<retrieve_in_chuncks>>
      LOOP
         -- call generic retrieval to get the non-OTM employees Timecards
         -- The retrieval process will only retrieve part of the population
         -- as set by the profile option OTL: Transfer Batch Size which is why
         -- it is called in a loop
         hxc_generic_retrieval_pkg.execute_retrieval_process
                         (p_process               => g_bee_retrieval_process,
                          p_transaction_code      => p_retrieval_transaction_code,
                          p_start_date            => p_start_date,
                          p_end_date              => p_end_date,
                          p_incremental           => p_incremental,
                          p_rerun_flag            => 'N',
                          p_where_clause          => p_where_clause,
                          p_scope                 => hxc_timecard.c_day_scope,
                          p_clusive               => g_inclusive,
                          p_unique_params         => p_unique_params,
                          p_since_date            => l_since_date
                         );

         IF (hxt_interface_utilities.detail_lines_retrieved
                                  (hxc_generic_retrieval_pkg.t_detail_bld_blks)
            )
         THEN
            add_lines_to_bee_batch
                          (p_batch_ref,
                           p_bg_id,
                           p_session_date,
                           hxc_generic_retrieval_pkg.t_detail_bld_blks,
                           hxc_generic_retrieval_pkg.t_detail_attributes,
                           hxc_generic_retrieval_pkg.t_old_detail_bld_blks,
                           hxc_generic_retrieval_pkg.t_old_detail_attributes,
                           l_supa_chunk_batch_id,
                           l_supa_chunk_retro_batch_id
                          );
         ELSE
            hxc_generic_retrieval_pkg.update_transaction_status
                                       (p_process                    => 'BEE Retrieval Process',
                                        p_status                     => 'SUCCESS',
                                        p_exception_description      => NULL
                                       );
            EXIT retrieve_in_chuncks;
         END IF;

         -- Bug 6121705
         -- For automatic reversal of batches transferred for rules evaluation pref change
         -- Check the count of OTM details to be reversed and call the adjustments procedure.
         -- Count(*) and rownum as in process_otlr_employees for returning 0 or 1 if data
         -- exists or not. We dont want the exact number, just wanna know if it exists or not.

         SELECT COUNT(*)
           INTO l_dup_count
           FROM hxc_bee_pref_adj_lines
          WHERE batch_source = 'OTM'
            AND ROWNUM < 2;


          -- If this is true, it means you have to make adjustments. Call the proc.
          IF ( l_dup_count > 0)
          THEN
              make_adjustments_otm( p_bg_id,
                                    p_batch_ref);
          END IF;

          -- --


         hxt_interface_utilities.empty_cache;
      END LOOP retrieve_in_chuncks;

      hxt_interface_utilities.perform_commit;
      -- Transfer or Validate the batches that were created
      --(if requested by user)
      process_bee_batches (p_status_in_bee => p_status_in_bee);
      hr_utility.set_location ('Leaving ' || l_proc, 100);
   EXCEPTION
      WHEN OTHERS
      THEN
         set_sqlerror_trx (g_bee_retrieval_process);
         hxc_generic_retrieval_utils.set_parent_statuses;
         hxc_generic_retrieval_pkg.update_transaction_status
                      (p_process                    => g_bee_retrieval_process,
                       p_status                     => 'ERRORS',
                       p_exception_description      => SUBSTR
                                                           (SQLERRM,
                                                            1,
                                                            g_max_message_size
                                                           ),
                       p_rollback                   => FALSE
                      );

         IF (SQLERRM NOT LIKE '%HXC%')
         THEN
            fnd_message.raise_error;
         ELSE
            IF (p_no_otm = 'Y')
            THEN
               fnd_message.raise_error;
            END IF;
         END IF;

         RETURN;
   END process_non_otlr_employees;

   PROCEDURE transfer_to_hr_payroll (
      errbuf                         OUT NOCOPY      VARCHAR2,
      retcode                        OUT NOCOPY      NUMBER,
      p_bg_id                        IN              NUMBER,
      p_session_date                 IN              VARCHAR2,
      p_start_date                   IN              VARCHAR2,
      p_end_date                     IN              VARCHAR2,
      p_start_batch_id               IN              NUMBER DEFAULT NULL,
      p_end_batch_id                 IN              NUMBER DEFAULT NULL,
      p_gre_id                       IN              NUMBER DEFAULT NULL,
      p_organization_id              IN              NUMBER DEFAULT NULL,
      p_location_id                  IN              NUMBER DEFAULT NULL,
      p_payroll_id                   IN              NUMBER DEFAULT NULL,
      p_person_id                    IN              NUMBER DEFAULT NULL,
      p_retrieval_transaction_code   IN              VARCHAR2,
      p_batch_selection              IN              VARCHAR2 DEFAULT NULL,
      p_is_old                       IN              VARCHAR2 DEFAULT NULL,
      p_old_batch_ref                IN              VARCHAR2 DEFAULT NULL,
      p_new_batch_ref                IN              VARCHAR2 DEFAULT NULL,
      p_new_specified                IN              VARCHAR2 DEFAULT NULL,
      p_status_in_bee                IN              VARCHAR2,
      p_otlr_to_bee                  IN              VARCHAR2,
      p_since_date                   IN              VARCHAR2
   )
   AS
      l_where_clause        hxt_interface_utilities.max_varchar;
      l_unique_params       hxt_interface_utilities.max_varchar;
      l_batch_ref           pay_batch_headers.batch_reference%TYPE;
      l_no_otm              hxt_interface_utilities.flag_varchar       := 'N';
      l_retrieval_options   fnd_profile_option_values.profile_option_value%TYPE
                               := fnd_profile.VALUE ('HXC_RETRIEVAL_OPTIONS');
   BEGIN
      -- Set session date
      hxc_generic_retrieval_pkg.g_ret_criteria.location_id := p_location_id;
      hxc_generic_retrieval_pkg.g_ret_criteria.payroll_id := p_payroll_id;
      hxc_generic_retrieval_pkg.g_ret_criteria.organization_id :=
                                                            p_organization_id;
      hxc_generic_retrieval_pkg.g_ret_criteria.gre_id := p_gre_id;
      l_since_date := p_since_date;
      pay_db_pay_setup.set_session_date (SYSDATE);
      l_batch_ref := NVL (p_old_batch_ref, p_new_batch_ref);
      l_where_clause :=
         where_clause (p_bg_id,
                       p_location_id,
                       p_payroll_id,
                       p_organization_id,
                       p_person_id,
                       p_gre_id
                      );
      l_unique_params :=
            p_retrieval_transaction_code
         || ':'
         || NVL (p_new_batch_ref, 'OLD')
         || ':'
         || l_batch_ref;

      IF ((l_retrieval_options <> 'BEE') OR (l_retrieval_options IS NULL))
      THEN
         process_otlr_employees
                   (p_bg_id,
                    fnd_date.canonical_to_date(p_session_date), -- Bug 6121705, new parameter; needs
                                                                -- type conversion from VARCHAR2
                    p_start_date, --fnd_date.canonical_to_date (p_start_date),
                    p_end_date,     --fnd_date.canonical_to_date (p_end_date),
                    l_where_clause,
                    p_retrieval_transaction_code,
                    l_batch_ref,
                    l_unique_params,
                    p_no_otm      => l_no_otm
                   );
      ELSE
         l_no_otm := 'Y';
      END IF;

      IF ((l_retrieval_options <> 'OTLR') OR (l_retrieval_options IS NULL))
      THEN
         process_non_otlr_employees
                                 (p_bg_id,
                                  fnd_date.canonical_to_date (p_start_date),
                                  fnd_date.canonical_to_date (p_end_date),
                                  fnd_date.canonical_to_date (p_session_date),
                                  l_where_clause,
                                  p_retrieval_transaction_code,
                                  l_batch_ref,
                                  l_unique_params,
                                  p_status_in_bee      => p_status_in_bee,
                                  p_no_otm             => l_no_otm
                                 );
      END IF;
   END transfer_to_hr_payroll;


-- Bug 6121705
-- Proc created to make adjustments in BEE for batch lines with source as Time Store.
-- chk_retrieve function would have populated the details which are already transferred
-- with a different rules evaluation preference and need adjustments. Now there has
-- to be a second time retrieval and creation of batches, but with negative entries in
-- BEE with batch source as Time Store.


PROCEDURE make_adjustments_bee ( p_batch_ref IN VARCHAR2,
                                 p_bg_id IN NUMBER,
                                 p_session_date IN DATE)
IS


  l_sqlcode       NUMBER;
  l_sqlmsg        VARCHAR2(2000);

  l_att_cnt    NUMBER;

  tnull_old_detail_bld_blks   hxc_generic_retrieval_pkg.t_building_blocks;
  tnull_old_detail_attributes hxc_generic_retrieval_pkg.t_time_attribute;

  l_adj_batch_id       pay_batch_headers.batch_reference%TYPE       := NULL;
  l_retro_adj_batch_id pay_batch_headers.batch_reference%TYPE       := NULL;


  -- Private procedure create_bld_blk_table
  -- populates the detail bld blks plsql table like gen. retrieval
  -- 1. Pull out the bb details from hxc_time_building_blocks table
  --    which has an entry in hxc_bee_pref_adj_lines table, with
  --    batch_source as Time Store.
  -- 2. Update hxc_bee_pref_adj_lines table with these values for
  --    the corresponding bb_ids and ovns.
  -- 3. Pull out these into a plsql table for the format prescribed in
  --    hxc_generic_retrieval_pkg, so that it can use the batch creation API.


  PROCEDURE create_bld_blk_table
  IS

      CURSOR get_bb_details
          IS
          SELECT time_building_block_id,
                 object_Version_number,
                 type,
                 DECODE(type,'MEASURE',measure,'RANGE',(stop_time-start_time)*24),
                 start_time,
                 stop_time,
                 parent_building_block_id ,
                 scope,
                 resource_type,
                 comment_text,
                 unit_of_measure,
                 'N',
                 'N'
            FROM hxc_time_building_blocks
           WHERE (time_building_block_id,object_version_number)
              IN ( SELECT detail_bb_id,
                          detail_bb_ovn
                     FROM hxc_bee_pref_adj_lines
                    WHERE batch_source = 'Time Store');

      CURSOR get_blocks
          IS
          SELECT detail_bb_id,
                 type,
                 -1*hours,   -- To create reverse entries, you need negative hours.
                 TRUNC(NVL(start_time,date_earned)),
                 TRUNC(NVL(stop_time,date_earned)),
                 parent_bb_id ,
                 scope,
                 resource_id,
                 resource_type,
                 comment_text,
                 uom,
                 detail_bb_ovn,
                 changed,
                 deleted,
                 timecard_id,
                 timecard_ovn
            FROM hxc_bee_pref_adj_lines
           WHERE batch_source = 'Time Store'
           order by detail_bb_id
           ;

  BEGIN	                                    --- create_bld_blk_table
      OPEN get_bb_details;

      FETCH get_bb_details
       BULK COLLECT INTO t_bb_details;

      CLOSE get_bb_details;

      FOR i IN t_bb_details.FIRST..t_bb_details.LAST
      LOOP
          UPDATE hxc_bee_pref_adj_lines
      	   SET type	     = t_bb_details(i).type,
      	       scope         = t_bb_details(i).scope,
      	       hours         = t_bb_details(i).measure     ,
      	       start_time    = t_bb_details(i).start_time  ,
      	       stop_time     = t_bb_details(i).stop_time   ,
      	       resource_type = t_bb_details(i).resource_type ,
      	       uom 	     = t_bb_details(i).uom 	      ,
      	       changed	     = t_bb_details(i).changed	,
      	       deleted	     = t_bb_details(i).deleted	,
      	       comment_text  = t_bb_details(i).comment_text  ,
      	       parent_bb_id  = t_bb_details(i).parent_bb_id
      	 WHERE detail_bb_id  = t_bb_details(i).bb_id
      	   AND detail_bb_ovn = t_bb_details(i).ovn;
      END LOOP;

      OPEN get_blocks;

      FETCH get_blocks BULK COLLECT INTO t_detail_blocks;

      CLOSE get_blocks;

  END create_bld_blk_table;



  -- Private Procedure gather_attributes
  -- gathers the attribute information for the blocks into the plsql table
  -- again like gen.retrieval.

  PROCEDURE gather_attributes
  is

      CURSOR get_attributes
      IS
      SELECT hat.attribute_category,
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
             attribute30,
             hau.time_building_block_id,
             hau.time_building_block_ovn,
             hat.bld_blk_info_type_id
        FROM hxc_time_attribute_usages hau,
             hxc_time_attributes hat
       WHERE hau.time_attribute_id = hat.time_attribute_id
         AND (hau.time_building_block_id,
              hau.time_building_block_ovn) IN ( SELECT detail_bb_id, detail_bb_ovn
                                                  FROM hxc_bee_pref_adj_lines
                                                 WHERE batch_source = 'Time Store')
        ORDER BY hau.time_building_block_id,
              hat.bld_blk_info_type_id;

  BEGIN

      OPEN get_attributes;

      FETCH get_attributes BULK COLLECT INTO t_attr_info;

      CLOSE get_attributes;

  END gather_attributes ;


  -- Private Procedure create_attributes_table
  -- From the gathered raw list of attributes, creates the plsql table
  -- structure that gen. retrieval returns. Loops thru the attributes and
  -- matches the mappings to get the required table structure.


  PROCEDURE create_attributes_table
  IS
    l_att_cnt    NUMBER := 0;

  BEGIN
      -- LOOP thru all detail attribute records ---
      FOR i IN t_attr_info.FIRST..t_attr_info.LAST
      LOOP
        -- Loop thru all the field mappings ---
        -- You already have the mappings in this global pl/sql table for gen retrieval.
        -- Use it, no need to query again.
     	FOR MAP IN hxc_generic_retrieval_pkg.g_field_mappings_table.FIRST..
     	           hxc_generic_retrieval_pkg.g_field_mappings_table.LAST
     	LOOP
              IF (t_attr_info(i).bld_blk_info_type_id =
     	                      hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).
     	                                                       bld_blk_info_type_id)
     	        -- If there is a valid mapping for the bld blk info type id --
     	    THEN
     	        l_att_cnt := l_att_cnt + 1;
     	        -- copy the the context,category AND the field name into the attribute info table --
     	        t_dtl_attributes(l_att_cnt).bb_id      := t_attr_info(i).bb_id;
     	        t_dtl_attributes(l_att_cnt).field_name := hxc_generic_retrieval_pkg.
     	                                                   g_field_mappings_table(MAP).field_name;
     	        t_dtl_attributes(l_att_cnt).context    := hxc_generic_retrieval_pkg.
     	                                                   g_field_mappings_table(MAP).context;
     	        t_dtl_attributes(l_att_cnt).category   := hxc_generic_retrieval_pkg.
     	                                                   g_field_mappings_table(MAP).category;
     	        -- check which attribute this mapping belongs to AND copy down that attribute --

     	        IF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).
     	                                              ATTRIBUTE = 'ATTRIBUTE_CATEGORY')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   hxc_deposit_wrapper_utilities.get_dupdff_name(t_attr_info(i).attribute_category);
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE1')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute1;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE2')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute2;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE3')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute3;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE4')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute4;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE5')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute5;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE6')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute6;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE7')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute7;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE8')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute8;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE9')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute9;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE10')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute10;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE11')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute11;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE12')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute12;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE13')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute13;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE14')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute14;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE15')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute15;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE16')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute16;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE17')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute17;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE18')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute18;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE19')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute19;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE20')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute20;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE21')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute21;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE22')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute22;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE23')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute23;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE24')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute24;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE25')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute25;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE26')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute26;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE27')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute27;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE28')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute28;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE29')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute29;
     	        ELSIF (hxc_generic_retrieval_pkg.g_field_mappings_table(MAP).ATTRIBUTE = 'ATTRIBUTE30')
     	        THEN
     	           t_dtl_attributes(l_att_cnt).value :=
     	                   t_attr_info(i).attribute30;
     	        END IF;
     	    ELSE
     	        NULL;
     	    END IF;

     	END LOOP;
      END LOOP;

  END create_attributes_table;

BEGIN   --- Make adjustments Main

    -- Create your bld blk table structure
    -- Gather your attribute info
    -- create the attribute table structure with the mapping info.
    -- Call add_lines_to bee_batch function with these values.
    -- The adjustment batch that is created will have a batch reference
    -- prefixed with 'adjdup' to identify these in future.

    create_bld_blk_table;

    gather_attributes;

    create_attributes_table;

    add_lines_to_bee_batch
                      ('adjdup'||p_batch_ref,
                       p_bg_id,
                       p_session_date,
                       t_detail_blocks,
                       t_dtl_attributes,
                       tnull_old_detail_bld_blks,
                       tnull_old_detail_attributes,
                       l_adj_batch_id,
                       l_retro_adj_batch_id
                      );

      -- you dont need the duplicate adjustment lines of this batch source, so delete them.
      DELETE FROM hxc_bee_pref_adj_lines
            WHERE batch_source = 'Time Store';

EXCEPTION
   WHEN OTHERS THEN
      l_sqlmsg := SUBSTR(SQLERRM,1,1500)||SQLCODE;
      hr_utility.trace('Sql error in make_adjustments :'||l_sqlmsg);
      RAISE;

END;



-- Bug 6121705
-- This procedure is used to create reversal batches with Batch source as OTM
-- for the details in hxc_bee_pref_adj_lines table with OTM as batch source.
-- hxc_generic_retrieval_utils.chk_retrieve would have populated these
-- records for which there is a history of a different preference for rules
-- evaluation.


PROCEDURE make_adjustments_otm( p_bg_id     IN hr_all_organization_units.business_group_id%TYPE,
                                p_batch_ref IN VARCHAR2)
IS

  l_new_batch     NUMBER;
  l_batch_ovn     NUMBER;
  l_sqlmsg        VARCHAR2(2000);
  l_rec_count       NUMBER;


  -- Private procedure delete_non_transferred_hours
  -- Deletes hours that are transferred earlier to HXT
  -- and have not been transferred to BEE.

  PROCEDURE delete_non_transferred_hours
  IS
  BEGIN
       DELETE FROM hxt_det_hours_worked_F
             WHERE ( date_worked,
                     assignment_id )
                               in ( SELECT date_earned,
                                           assignment_id
                                      FROM hxc_bee_pref_adj_lines,
	                                   per_all_assignments_f paf,
                                           per_assignment_status_types pas
                                     WHERE resource_id               = person_id
                                       AND batch_source              = 'OTM'
                                       AND paf.effective_end_date    = hr_general.end_of_time
                                       AND paf.effective_start_date <= date_earned
                                       AND paf.primary_flag          = 'Y'
                                       AND paf.assignment_status_type_id =
                                                        pas.assignment_status_type_id
                                       AND pas.per_system_status     = 'ACTIVE_ASSIGN')
                AND pay_status         <> 'C'
                AND effective_end_date = hr_general.end_of_time;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  null;
  END;


  -- Private procedure create_batch_line
  -- creates the batch lines for the adjustment batch that is created.

  PROCEDURE create_batch_line(p_batch_id NUMBER)
  IS
      CURSOR get_batch_rec
      IS
      SELECT *
        FROM hxt_batch_values_v
       WHERE (date_worked ,assignment_id) in
                      ( SELECT date_earned,
                               paf.assignment_id
                          FROM hxc_bee_pref_adj_lines hoa,
                               per_all_assignments_f paf
                         WHERE hoa.resource_id = paf.person_id
                           AND hoa.date_earned BETWEEN paf.effective_start_date
                                                   AND paf.effective_end_date
                           AND paf.primary_flag = 'Y');
      p_batch_rec            hxt_batch_values_v%ROWTYPE;
      l_sum_retcode          NUMBER := 0;
      l_batch_sequence       NUMBER;

  BEGIN
         l_batch_sequence := pay_paywsqee_pkg.next_batch_sequence(p_batch_id);
         OPEN get_batch_rec;
         LOOP
                 FETCH get_batch_rec
                  INTO p_batch_rec;
                 EXIT WHEN get_batch_rec%NOTFOUND;

                 p_batch_rec.batch_id  := p_batch_id;
                 p_batch_rec.hours     := -1*p_batch_rec.hours;

                 IF (l_sum_retcode = 0)
                 THEN
                     hxt_batch_process.dtl_to_bee(p_batch_rec,l_sum_retcode,l_batch_sequence);
                     l_batch_sequence := l_batch_sequence + 1;
                 END IF;
          END LOOP;
          CLOSE get_batch_rec;

  END;

BEGIN                    ---- make_adjustments_otm

      -- In case the timecard is still with HXT, no need to create reversal batches.
      -- But see that they are deleted from the system, so that they can never be
      -- transferred. Delete the non transferred hours first.
      -- Create a batch header, and then create the batch lines taking values from
      -- HXT_BATCH_VALUES_V. There could have been a timecard edit in HXT, and the changed
      -- hours could have gone to BEE. The reversal batch lines has to reverse these, rather
      -- than the hours you pulled out from HXC. HXT_BATCH_VALUES_V is a view on hxt detail hours
      -- and pay batch lines, so what you get from there would be the transferred values.
      -- So after you pull out the batch records, turn around the hours with a negative sign
      -- and create the lines.
      delete_non_transferred_hours;

      -- Check if there is anything left there. If no TC was transferred, no need of the
      -- adj dup batch.
      SELECT COUNT(*)
        INTO l_rec_count
        FROM hxc_bee_pref_adj_lines
       WHERE batch_source = 'OTM'
         AND rownum < 2;

      IF l_rec_count > 0
      THEN
          l_batch_ovn := 1;
      	  PAY_BATCH_ELEMENT_ENTRY_API.create_batch_header
		  (p_session_date                  => sysdate
		  ,p_batch_name                    => 'adjdup'||p_batch_ref
		  ,p_batch_status                  => 'U'
		  ,p_business_group_id             => p_bg_id
		  ,p_action_if_exists              => 'I'
		  ,p_batch_reference               => 'adjdup'||p_batch_ref
		  ,p_batch_source                  => 'OTM'
		  ,p_purge_after_transfer          => 'N'
		  ,p_reject_if_future_changes      => 'N'
		  ,p_batch_id                      => l_new_batch
		  ,p_object_version_number         => l_batch_ovn
		  );

      	  create_batch_line(p_batch_id => l_new_batch);


      	  DELETE FROM hxc_bee_pref_adj_lines
      	        WHERE batch_source = 'OTM';
       END IF;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
       NULL;
    WHEN others THEN
      l_sqlmsg := SUBSTR(SQLERRM,1,1500)||SQLCODE;
      hr_utility.trace('Sql error in make_adjustments :'||l_sqlmsg);
      RAISE;
END;


END pay_hr_otc_retrieval_interface;

/
