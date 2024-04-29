--------------------------------------------------------
--  DDL for Package Body BOM_COPY_ROUTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_COPY_ROUTING" AS
/* $Header: BOMCPYRB.pls 120.14.12010000.3 2011/01/03 19:33:37 umajumde ship $ */
/*==========================================================================+
|   Copyright (c) 1995 Oracle Corporation, California, USA                  |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCPYRB.pls                                               |
| Description  : Routing copy package                                       |
| Created By   : Manu Chadha                                                |
|                                                                           |
|   from_org_id     Copy from org id                                        |
|   to_org_id       Copy to org id                                          |
|   from_sequence_id    Copy from routing sequence id                       |
|   to_sequence_id      Copy to routing sequence id                         |
|   display_option      copy option                                         |
|               1 - all (not supported from form)                           |
|               2 - current                                                 |
|               3 - current + future                                        |
|   user_id         user id                                                 |
|   to_item_id      Copy to item id                                         |
|   direction       direction of copy                                       |
|               1 - BOM to BOM                                              |
|               2 - BOM to ENG                                              |
|               3 - ENG to ENG                                              |
|               2 - ENG to BOM                                              |
|   to_alternate        Copy to alternate designator                        |
|   rev_date        Revision date to copy                                   |
|   err_msg         Error message                                           |
|   error_code      Error code                                              |
|                                                                           |
|   30-Jun-2005    Ezhilarasan  Added new overloaded procedure to support   |
|                               copy routing in context of eco              |
+==========================================================================*/
   PROCEDURE rtg_get_msg_info (
      total_opseqs             IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
      total_resources          IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
      total_sub_resources      IN OUT NOCOPY /* file.sql.39 change */ NUMBER,                     --2991810
      total_instructions       IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
      total_hdr_instructions   IN OUT NOCOPY /* file.sql.39 change */ NUMBER,                 --bug 3473851
      from_rtg_seq_id          IN       NUMBER,
      rev_date                 IN       DATE,
      display_option           IN       NUMBER
   )
   IS
      err_msg        VARCHAR2 (2000);
      sql_stmt_num   NUMBER;
   BEGIN
      sql_stmt_num := 1;

      SELECT COUNT (*)
        INTO total_opseqs
        FROM bom_operation_sequences
       WHERE routing_sequence_id = from_rtg_seq_id
         AND NVL (eco_for_production, 2) = 2
         AND (display_option = 1
              OR (display_option = 2
                  AND effectivity_date <= rev_date
                  AND NVL (disable_date, rev_date) >= rev_date
                 )
              OR (display_option = 3
                  AND ((effectivity_date <= rev_date
                        AND NVL (disable_date, rev_date) >= rev_date
                       )
                       OR effectivity_date >= rev_date
                      )
                 )
             );

      sql_stmt_num := 2;

      SELECT COUNT (*)
        INTO total_resources
        FROM bom_operation_sequences a,
             bom_operation_resources b
       WHERE a.routing_sequence_id = from_rtg_seq_id
         AND NVL (a.eco_for_production, 2) = 2
         AND (display_option = 1
              OR (display_option = 2
                  AND a.effectivity_date <= rev_date
                  AND NVL (a.disable_date, rev_date + 1) > rev_date
                 )
              OR (display_option = 3
                  AND ((a.effectivity_date <= rev_date
                        AND NVL (a.disable_date, rev_date + 1) > rev_date
                       )
                       OR a.effectivity_date > rev_date
                      )
                 )
             )
         AND a.operation_sequence_id = b.operation_sequence_id;

-- Bug Fix 2991810
--bug 3853743 added distinct clause
      sql_stmt_num := 4;

      SELECT DISTINCT COUNT (*)
                 INTO total_sub_resources
                 FROM bom_operation_sequences a,
                      bom_operation_resources b,
                      bom_sub_operation_resources c
                WHERE a.routing_sequence_id = from_rtg_seq_id
                  AND NVL (a.eco_for_production, 2) = 2
                  AND (display_option = 1
                       OR (display_option = 2
                           AND a.effectivity_date <= rev_date
                           AND NVL (a.disable_date, rev_date + 1) > rev_date
                          )
                       OR (display_option = 3
                           AND ((a.effectivity_date <= rev_date
                                 AND NVL (a.disable_date, rev_date + 1) >
                                                                      rev_date
                                )
                                OR a.effectivity_date > rev_date
                               )
                          )
                      )
                  AND a.operation_sequence_id = b.operation_sequence_id
                  AND b.operation_sequence_id = c.operation_sequence_id
                  AND b.schedule_seq_num = c.schedule_seq_num;

-- Bug Fix 2991810
      sql_stmt_num := 3;

      SELECT COUNT (*)
        INTO total_instructions
        FROM bom_operation_sequences a,
             fnd_attached_documents b
       WHERE a.routing_sequence_id = from_rtg_seq_id
         AND NVL (a.eco_for_production, 2) = 2
         AND (display_option = 1
              OR (display_option = 2
                  AND a.effectivity_date <= rev_date
                  AND NVL (a.disable_date, rev_date + 1) > rev_date
                 )
              OR (display_option = 3
                  AND ((a.effectivity_date <= rev_date
                        AND NVL (a.disable_date, rev_date + 1) > rev_date
                       )
                       OR a.effectivity_date > rev_date
                      )
                 )
             )
         AND a.operation_sequence_id = b.pk1_value
         AND b.entity_name = 'BOM_OPERATION_SEQUENCES';

      --begin bug fix 3473851
      sql_stmt_num := 5;

      SELECT COUNT (*)
        INTO total_hdr_instructions
        FROM bom_operational_routings a,
             fnd_attached_documents b
       WHERE a.routing_sequence_id = from_rtg_seq_id
         AND a.routing_sequence_id = b.pk1_value
         AND b.entity_name = 'BOM_OPERATIONAL_ROUTINGS';
   --end bug fix 3473851
   EXCEPTION
      WHEN OTHERS
      THEN
         err_msg := 'RTG_GET_MSG_INFO (' || sql_stmt_num || ') ' || SQLERRM;
         fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
         fnd_message.set_token ('ENTITY', err_msg);
         ROLLBACK TO begin_routing_copy;
         app_exception.raise_exception;
   END rtg_get_msg_info;

   PROCEDURE copy_routing (
      to_sequence_id     IN   NUMBER,
      from_sequence_id   IN   NUMBER,
      from_org_id        IN   NUMBER,
      to_org_id          IN   NUMBER,
      display_option     IN   NUMBER DEFAULT 2,
      user_id            IN   NUMBER DEFAULT -1,
      to_item_id         IN   NUMBER,
      direction          IN   NUMBER,
      to_alternate       IN   VARCHAR2,
      rev_date                DATE
   )
   IS
   BEGIN
      copy_routing
               (to_sequence_id,
                from_sequence_id,
                from_org_id,
                to_org_id,
                display_option,
                user_id,
                to_item_id,
                direction,
                to_alternate,
                rev_date,
                NULL,                                         -- Change Notice
                NULL,                              -- Revised Item Sequence Id
                1, -- routing_or_eco ( Routing always for the existing flows )
				-- Existing routing copy will copied to sysdate
				SYSDATE,                -- Targtet Effectivity Date Bug 4863227
                NULL,                                  -- Eco Effectivity Date
                NULL,                -- Context ECO in which the copy occurs
				NULL,                -- no need to log errors
				NULL,                -- Request id will be null, this is not from TTMO
				'N'
               );
   END;

   PROCEDURE copy_routing (
      to_sequence_id          IN   NUMBER,
      from_sequence_id        IN   NUMBER,
      from_org_id             IN   NUMBER,
      to_org_id               IN   NUMBER,
      display_option          IN   NUMBER DEFAULT 2,
      user_id                 IN   NUMBER DEFAULT -1,
      to_item_id              IN   NUMBER,
      direction               IN   NUMBER,
      to_alternate            IN   VARCHAR2,
      rev_date                     DATE,
      p_e_change_notice         IN   VARCHAR2,
      p_rev_item_seq_id   IN   NUMBER,
      p_routing_or_eco          IN   NUMBER DEFAULT 1,
	  p_trgt_eff_date           IN   DATE,
      p_eco_eff_date            IN   DATE,
      p_context_eco             IN   VARCHAR2,
	  p_log_errors              IN   VARCHAR2 DEFAULT 'N',
	  p_copy_request_id         IN   NUMBER DEFAULT NULL,
	  p_cpy_disable_fields      IN   VARCHAR2 DEFAULT 'N'
   )
   IS
      x_from_sequence_id       NUMBER          := from_sequence_id;
--  X_rev_date      date   := trunc(rev_date);  -- Removed for bug 2647027
      total_opseqs             NUMBER          := 0;
      total_resources          NUMBER          := 0;
      total_sub_resources      NUMBER          := 0;
      total_instructions       NUMBER          := 0;
      total_hdr_instructions   NUMBER          := 0;
      hour_uom_code_v          VARCHAR2 (3);
      hour_uom_class_v         VARCHAR2 (10);
      sql_stmt_num             NUMBER;
      err_msg                  VARCHAR2 (2000);
      copy_resources           NUMBER          := 0;
      copy_sub_resources       NUMBER          := 0;
      copy_instrs              NUMBER;
      copy_hdr_instrs          NUMBER;
      copy_operations          NUMBER;
      p_op_seq_id              NUMBER;
      p_op_seq_num             NUMBER;
      new_p_op_seq_id          NUMBER;
      l_op_seq_id              NUMBER;
      l_op_seq_num             NUMBER;
      new_l_op_seq_id          NUMBER;
      l_curr_date              DATE;                 -- Added for bug 2718955
      -- Bug fix 3473802
      p_st_op_id               NUMBER;
      new_st_op_id             NUMBER;
      min_qty                  NUMBER;
      back_flag                NUMBER;
      opt_flag                 NUMBER;
      count_type               NUMBER;
      opr_desc                 VARCHAR2 (240);
      copy_ops_update          NUMBER;

      CURSOR source_rtg
      IS
         SELECT operation_sequence_id,
                last_updated_by
           FROM bom_operation_sequences
          WHERE routing_sequence_id = to_sequence_id
            AND NVL (eco_for_production, 2) = 2;

      CURSOR process_op
      IS
         SELECT operation_sequence_id,
                operation_seq_num
           FROM bom_operation_sequences
          WHERE routing_sequence_id = x_from_sequence_id        -- Bug 2642427
            AND NVL (eco_for_production, 2) = 2
            AND operation_type = 2;

      CURSOR line_op
      IS
         SELECT operation_sequence_id,
                operation_seq_num
           FROM bom_operation_sequences
          WHERE routing_sequence_id = x_from_sequence_id        -- Bug 2642427
            AND NVL (eco_for_production, 2) = 2
            AND operation_type = 3;

      -- Cursor Bug fix 3473802
      CURSOR update_st_op
      IS
         SELECT standard_operation_id,
                operation_sequence_id
           FROM bom_operation_sequences
          WHERE routing_sequence_id = to_sequence_id;
	  l_from_item_id NUMBER;
   BEGIN
      SAVEPOINT begin_routing_copy;
      sql_stmt_num := 1;
      fnd_profile.get ('BOM:HOUR_UOM_CODE', hour_uom_code_v);

      BEGIN
         SELECT uom_class
           INTO hour_uom_class_v
           FROM mtl_units_of_measure
          WHERE uom_code = hour_uom_code_v;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      sql_stmt_num := 10;

      SELECT common_routing_sequence_id
        INTO x_from_sequence_id
        FROM bom_operational_routings
       WHERE routing_sequence_id = from_sequence_id;

      IF (from_org_id <> to_org_id)
      THEN
         rtg_get_msg_info (total_opseqs,
                           total_resources,
                           total_sub_resources,                     -- 2991810
                           total_instructions,
                           total_hdr_instructions,               --bug 3473851
                           x_from_sequence_id,
                           rev_date,
                           display_option
                          );
      END IF;

      --copy operations
      --null out std op id, operation_offset_%
      --do not copy operations where department does not exist in to org
      --if dept_id is diff in to org, reset dept id
      -- For flow routings, we need to update the process_op_seq_id
      -- and line_op_seq_id with the new values generated.
      sql_stmt_num := 15;
	  IF p_trgt_eff_date IS NULL THEN
        l_curr_date := SYSDATE;
	  ELSE
	    l_curr_date := p_trgt_eff_date; -- Routing can be copied to particular from TTMO flow - R12
	  END IF;

      INSERT INTO bom_operation_sequences
                  (operation_sequence_id,
                   routing_sequence_id,
                   operation_seq_num,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   standard_operation_id,
                   department_id,
                   operation_lead_time_percent,
                   minimum_transfer_quantity,
                   count_point_type,
                   operation_description,
                   effectivity_date,
                   disable_date,
                   backflush_flag,
                   option_dependent_flag,
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
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date,
                   operation_type,
                   reference_flag,
                   process_op_seq_id,
                   line_op_seq_id,
                   yield,
                   cumulative_yield,
                   reverse_cumulative_yield,
                   labor_time_calc,
                   machine_time_calc,
                   total_time_calc,
                   labor_time_user,
                   machine_time_user,
                   total_time_user,
                   net_planning_percent,
                   x_coordinate,
                   y_coordinate,
                   include_in_rollup,
                   operation_yield_enabled,
                   old_operation_sequence_id,
                   acd_type,
                   revised_item_sequence_id,
                   original_system_reference,
                   change_notice,
                   implementation_date,
                   eco_for_production,
                   shutdown_type,
                   -- Added by MK 04/10/2001
                   long_description,                   -- Added for bug 2767630
                   lowest_acceptable_yield,  -- Added for MES Enhancement
                   use_org_settings,
                   queue_mandatory_flag,
                   run_mandatory_flag,
                   to_move_mandatory_flag,
                   show_next_op_by_default,
                   show_scrap_code,
                   show_lot_attrib,
                   track_multiple_res_usage_dates,
                   check_skill --added for bug 7597474
                  )
         SELECT bom_operation_sequences_s.NEXTVAL,
                to_sequence_id,
                a.operation_seq_num,
                l_curr_date,
                a.operation_sequence_id,
                l_curr_date,
                user_id,
                user_id,
                a.standard_operation_id,
                c.department_id,
                NULL,
                a.minimum_transfer_quantity,
                a.count_point_type,
                a.operation_description,
-- Bug 2161841
--      GREATEST(A.EFFECTIVITY_DATE, l_curr_date),  -- Changed for bug 2647027
                CASE
				WHEN display_option = 2 AND p_routing_or_eco = 2
				  THEN NVL(p_eco_eff_date,l_curr_date)
				WHEN display_option = 2
				  THEN NVL(p_trgt_eff_date,l_curr_date)
				-- For all don't check any effectivity, blindly copy
				WHEN display_option = 1
				  THEN a.effectivity_date
			    WHEN p_routing_or_eco = 2 -- Added through ECO and explosion date is past and effectivity date
			    -- in the past
				 AND ( a.effectivity_date < p_eco_eff_date AND rev_date < p_eco_eff_date )
				 -- Explosion in the Past and Effectivity Date is also in the past, then the operations
				 -- which are past effective will be effective from p_eco_eff_date
				  THEN NVL(p_eco_eff_date,l_curr_date)
				WHEN p_routing_or_eco = 2 -- Added through ECO and explosion date is future
				 AND ( a.effectivity_date = rev_date AND rev_date > p_eco_eff_date )
			     -- Explosion in the future and Effectivity Date is also in the future, then the operations
				 -- which are effective with that effective data will be effective from p_eco_eff_date
				  THEN NVL(p_eco_eff_date,l_curr_date)
				     -- Past effective operations should be target date effective
				WHEN p_routing_or_eco = 2
				 AND a.effectivity_date < p_eco_eff_date
				  THEN NVL(p_eco_eff_date,l_curr_date)
				WHEN p_routing_or_eco = 1 -- Inline and explosion date is past
				     AND ( a.effectivity_date < p_trgt_eff_date AND rev_date < p_trgt_eff_date )
				 -- Explosion in the Past and Effectivity Date is also in the past, then the operations
				 -- which are past effective will be effective from p_trgt_eff_date
				  THEN NVL(p_trgt_eff_date,l_curr_date)
			    WHEN p_routing_or_eco = 1 -- Inline and explosion date is future
			     AND ( a.effectivity_date = rev_date AND rev_date > p_trgt_eff_date )
				 -- Explosion in the future and Effectivity Date is also in the future, then the operations
				 -- which are effective at the explosion time alone will be effective from p_trgt_eff_date
				  THEN NVL(p_trgt_eff_date,l_curr_date)
				 -- Past effective components should be target data effective
				WHEN p_routing_or_eco = 1
				 AND a.effectivity_date < p_trgt_eff_date
				  THEN NVL(p_trgt_eff_date,l_curr_date)
				ELSE
				     a.effectivity_date
				END AS effectivity_date,
				CASE
				-- This flag will be set when current and future option is selected with
				-- copy through ECO
				WHEN p_cpy_disable_fields = 'Y'
				 AND display_option = 2
				 AND p_routing_or_eco = 2
				 AND a.disable_date IS NOT NULL
				 AND a.disable_date > p_eco_eff_date
				  THEN a.disable_date
                -- For current never disable the operations
				WHEN display_option = 2
				  THEN TO_DATE (NULL)
				-- Past disabled operations will be copied with disable date as null
				WHEN p_routing_or_eco = 2 AND ( a.disable_date < p_eco_eff_date )
  				  THEN TO_DATE (NULL)
				-- Past disabled operations will be copied with disable date as null
				WHEN p_routing_or_eco = 1 AND ( a.disable_date < p_trgt_eff_date )
				  THEN TO_DATE (NULL)
				ELSE
				-- Future disabled components should be disabled as per the disable date of component
                  a.disable_date
				END AS disable_date,

                /* Commented as part of R12 TTMO enhancement to support specific target eff date
                DECODE (p_routing_or_eco,
                        1, DECODE (display_option,
                                   1, a.effectivity_date,
                                   GREATEST (a.effectivity_date, l_curr_date)
                                  ),
                        p_eco_eff_date
                       ),                           -- Changed for bug 2788795
                a.disable_date,*/
--      TRUNC(GREATEST(A.EFFECTIVITY_DATE, SYSDATE)),/* Bug: 1636829 */
--      TRUNC(A.DISABLE_DATE),
                a.backflush_flag,
                a.option_dependent_flag,
                a.attribute_category,
                a.attribute1,
                a.attribute2,
                a.attribute3,
                a.attribute4,
                a.attribute5,
                a.attribute6,
                a.attribute7,
                a.attribute8,
                a.attribute9,
                a.attribute10,
                a.attribute11,
                a.attribute12,
                a.attribute13,
                a.attribute14,
                a.attribute15,
                fnd_global.conc_request_id,
                NULL,
                fnd_global.conc_program_id,
                sysdate,
                a.operation_type,
                DECODE (from_org_id, to_org_id, a.reference_flag, 2),
                -- Bug 3473802
                a.process_op_seq_id,
                a.line_op_seq_id,
                a.yield,
                a.cumulative_yield,
                a.reverse_cumulative_yield,
                a.labor_time_calc,
                a.machine_time_calc,
                a.total_time_calc,
                a.labor_time_user,
                a.machine_time_user,
                a.total_time_user,
                a.net_planning_percent,
                a.x_coordinate,
                a.y_coordinate,
                a.include_in_rollup,
                a.operation_yield_enabled,
                a.old_operation_sequence_id,
                DECODE (p_routing_or_eco, 1, a.acd_type, 1),
                -- When it is ECO it is Add always
                DECODE (p_routing_or_eco,
                        1, a.revised_item_sequence_id,
                        p_rev_item_seq_id
                       ),
                a.original_system_reference,
                DECODE (p_routing_or_eco, 1, a.change_notice, p_e_change_notice),
                DECODE (p_routing_or_eco, 1, a.implementation_date, NULL),
                -- When it is ECO populate NULL
                a.eco_for_production,
                a.shutdown_type,
                -- Added by MK 04/10/2001
                a.long_description,
                a.lowest_acceptable_yield,  -- Added for MES Enhancement
                a.use_org_settings,
                a.queue_mandatory_flag,
                a.run_mandatory_flag,
                a.to_move_mandatory_flag,
                a.show_next_op_by_default,
                a.show_scrap_code,
                a.show_lot_attrib,
                a.track_multiple_res_usage_dates,
                a.check_skill --added for bug 7597474
           FROM bom_operation_sequences a,                          -- from op
                bom_departments b,                           -- from op's dept
                bom_departments c                              -- to op's dept
          WHERE a.routing_sequence_id = x_from_sequence_id
            AND NVL (a.eco_for_production, 2) = 2
            AND (display_option = 1                                  /* ALL */
                 OR (display_option = 2                          /* CURRENT */
                     AND a.effectivity_date <= rev_date
                     -- Bug 2161841
                     AND ((a.disable_date >= rev_date
                           AND a.disable_date >= l_curr_date
                          )
                          OR a.disable_date IS NULL
                         )
                    )
                 OR (display_option = 3                   /* CURRENT_FUTURE */
                     AND ((a.effectivity_date <= rev_date
                           -- Bug 2161841
                           AND ((a.disable_date >= rev_date
                                 AND a.disable_date >= l_curr_date
                                )
                                OR a.disable_date IS NULL
                               )
                          )
                          OR a.effectivity_date >= rev_date
                         )
                    )
                )
            AND a.department_id = b.department_id
            AND b.department_code = c.department_code
            -- comparing departments with same name
            AND c.organization_id = to_org_id
            AND NVL (c.disable_date, l_curr_date + 1) > l_curr_date
--   AND A.IMPLEMENTATION_DATE IS NOT NULL ; /* Bug 2717982 */
            AND (a.implementation_date IS NOT NULL
                 OR (a.implementation_date IS NULL
                     AND a.change_notice = p_context_eco
                     AND ( a.acd_type = 1 OR a.acd_type = 2 )
                    )
                )
			AND NOT EXISTS -- Bug 5151332 Disabled operations should not get copied in ECO context
			(
			  SELECT 1
			    FROM bom_operation_sequences bos
			   WHERE bos.routing_sequence_id = a.routing_sequence_id
			     AND bos.old_operation_sequence_id = a.operation_sequence_id
				 AND bos.change_notice = p_context_eco
				 AND bos.acd_type = 3
				 AND bos.effectivity_date <= p_trgt_eff_date
				 AND bos.implementation_date IS NULL
			 );

    IF p_log_errors = 'Y' THEN
	     -- There should not be any no data found for this case
	     SELECT
		    assembly_item_id INTO l_from_item_id
		 FROM
		    bom_operational_routings bor
		 WHERE
		    bor.routing_sequence_id = from_sequence_id;
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		 SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_RTG_DEPT_NOT_EXISTS',
			                    a.operation_seq_num, b.department_code,'DEP'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a,                          -- from op
                bom_departments b,                           -- from op's dept
                bom_departments c                              -- to op's dept
          WHERE a.routing_sequence_id = x_from_sequence_id
            AND (display_option = 1                                  /* ALL */
                 OR (display_option = 2                          /* CURRENT */
                     AND a.effectivity_date <= rev_date
                     -- Bug 2161841
                     AND ((a.disable_date >= rev_date
                           AND a.disable_date >= l_curr_date
                          )
                          OR a.disable_date IS NULL
                         )
                    )
                 OR (display_option = 3                   /* CURRENT_FUTURE */
                     AND ((a.effectivity_date <= rev_date
                           -- Bug 2161841
                           AND ((a.disable_date >= rev_date
                                 AND a.disable_date >= l_curr_date
                                )
                                OR a.disable_date IS NULL
                               )
                          )
                          OR a.effectivity_date >= rev_date
                         )
                    )
                )
            AND a.department_id = b.department_id
            AND b.department_code = c.department_code (+)
            -- comparing departments with same name
            AND c.organization_id = to_org_id
            AND NVL (c.disable_date, l_curr_date + 1) > l_curr_date
            AND (a.implementation_date IS NOT NULL
                 OR (a.implementation_date IS NULL
                     AND a.change_notice = p_context_eco
                     AND ( a.acd_type = 1 OR a.acd_type = 2 )
                    )
                )
			AND NOT EXISTS -- Bug 5151332 Disabled operations should not get copied in ECO context
			(
			  SELECT 1
			    FROM bom_operation_sequences bos
			   WHERE bos.routing_sequence_id = a.routing_sequence_id
			     AND bos.old_operation_sequence_id = a.operation_sequence_id
				 AND bos.change_notice = p_context_eco
				 AND bos.acd_type = 3
				 AND bos.effectivity_date <= p_trgt_eff_date
				 AND bos.implementation_date IS NULL
			 )
			MINUS -- Filter the departments for which the match is found
  		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_RTG_DEPT_NOT_EXISTS',
			         a.operation_seq_num, b.department_code,'DEP'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a,                          -- from op
                bom_departments b,                           -- from op's dept
                bom_departments c                              -- to op's dept
          WHERE a.routing_sequence_id = x_from_sequence_id
            AND (display_option = 1                                  /* ALL */
                 OR (display_option = 2                          /* CURRENT */
                     AND a.effectivity_date <= rev_date
                     -- Bug 2161841
                     AND ((a.disable_date >= rev_date
                           AND a.disable_date >= l_curr_date
                          )
                          OR a.disable_date IS NULL
                         )
                    )
                 OR (display_option = 3                   /* CURRENT_FUTURE */
                     AND ((a.effectivity_date <= rev_date
                           -- Bug 2161841
                           AND ((a.disable_date >= rev_date
                                 AND a.disable_date >= l_curr_date
                                )
                                OR a.disable_date IS NULL
                               )
                          )
                          OR a.effectivity_date >= rev_date
                         )
                    )
                )
            AND a.department_id = b.department_id
            AND b.department_code = c.department_code
            -- comparing departments with same name
            AND c.organization_id = to_org_id
            AND NVL (c.disable_date, l_curr_date + 1) > l_curr_date
            AND (a.implementation_date IS NOT NULL
                 OR (a.implementation_date IS NULL
                     AND a.change_notice = p_context_eco
                     AND ( a.acd_type = 1 OR a.acd_type = 2 )
                    )
                )
			AND NOT EXISTS -- Bug 5151332 Disabled operations should not get copied in ECO context
			(
			  SELECT 1
			    FROM bom_operation_sequences bos
			   WHERE bos.routing_sequence_id = a.routing_sequence_id
			     AND bos.old_operation_sequence_id = a.operation_sequence_id
				 AND bos.change_notice = p_context_eco
				 AND bos.acd_type = 3
				 AND bos.effectivity_date <= p_trgt_eff_date
				 AND bos.implementation_date IS NULL
			 );
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		 SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_RTG_OPER_FOR_WIP_JOB',a.operation_seq_num),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a
          WHERE a.routing_sequence_id = x_from_sequence_id
            AND (display_option = 1                                  /* ALL */
                 OR (display_option = 2                          /* CURRENT */
                     AND a.effectivity_date <= rev_date
                     -- Bug 2161841
                     AND ((a.disable_date >= rev_date
                           AND a.disable_date >= l_curr_date
                          )
                          OR a.disable_date IS NULL
                         )
                    )
                 OR (display_option = 3                   /* CURRENT_FUTURE */
                     AND ((a.effectivity_date <= rev_date
                           -- Bug 2161841
                           AND ((a.disable_date >= rev_date
                                 AND a.disable_date >= l_curr_date
                                )
                                OR a.disable_date IS NULL
                               )
                          )
                          OR a.effectivity_date >= rev_date
                         )
                    )
                )
            AND a.eco_for_production <> 2
            AND (a.implementation_date IS NOT NULL
                 OR (a.implementation_date IS NULL
                     AND a.change_notice = p_context_eco
                     AND ( a.acd_type = 1 OR a.acd_type = 2 )
                    )
                )
			AND NOT EXISTS -- Bug 5151332 Disabled operations should not get copied in ECO context
			(
			  SELECT 1
			    FROM bom_operation_sequences bos
			   WHERE bos.routing_sequence_id = a.routing_sequence_id
			     AND bos.old_operation_sequence_id = a.operation_sequence_id
				 AND bos.change_notice = p_context_eco
				 AND bos.acd_type = 3
				 AND bos.effectivity_date <= p_trgt_eff_date
				 AND bos.implementation_date IS NULL
			 );
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		 SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_RTG_OPER_NOT_IMPL',a.operation_seq_num),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a
          WHERE a.routing_sequence_id = x_from_sequence_id
            AND (display_option = 1                                  /* ALL */
                 OR (display_option = 2                          /* CURRENT */
                     AND a.effectivity_date <= rev_date
                     -- Bug 2161841
                     AND ((a.disable_date >= rev_date
                           AND a.disable_date >= l_curr_date
                          )
                          OR a.disable_date IS NULL
                         )
                    )
                 OR (display_option = 3                   /* CURRENT_FUTURE */
                     AND ((a.effectivity_date <= rev_date
                           -- Bug 2161841
                           AND ((a.disable_date >= rev_date
                                 AND a.disable_date >= l_curr_date
                                )
                                OR a.disable_date IS NULL
                               )
                          )
                          OR a.effectivity_date >= rev_date
                         )
                    )
                )
            AND (a.implementation_date IS NULL
			     AND p_context_eco IS NULL);

	END IF; /* IF p_log_errors = 'Y' */


      copy_operations := SQL%ROWCOUNT;

      IF (from_org_id = to_org_id)
      THEN
         total_opseqs := SQL%ROWCOUNT;
      END IF;

      -- Begin Bug fix 3473802
      IF (from_org_id <> to_org_id)
      THEN
         OPEN update_st_op;

         copy_ops_update := 0;

         LOOP
            FETCH update_st_op
             INTO p_st_op_id,
                  p_op_seq_id;

            EXIT WHEN update_st_op%NOTFOUND;

            BEGIN
               SELECT b.standard_operation_id,
                      b.minimum_transfer_quantity,
                      b.backflush_flag,
                      b.option_dependent_flag,
                      b.count_point_type,
                      b.operation_description
                 INTO new_st_op_id,
                      min_qty,
                      back_flag,
                      opt_flag,
                      count_type,
                      opr_desc
                 FROM bom_standard_operations_v a,              -- BUG 3936049
                      bom_standard_operations_v b               -- BUG 3936049
                WHERE a.standard_operation_id = p_st_op_id
                  AND a.operation_code = b.operation_code
                  AND a.organization_id = from_org_id
                  AND b.organization_id = to_org_id
                  AND NVL (a.line_code, '@@@') = NVL (b.line_code, '@@@')
                  -- BUG 3936049
                  AND NVL (a.operation_type, -99) = NVL (b.operation_type,
                                                         -99);  -- BUG 3936049

               UPDATE bom_operation_sequences
                  SET standard_operation_id = new_st_op_id,
                      minimum_transfer_quantity = min_qty,
                      backflush_flag = back_flag,
                      option_dependent_flag = opt_flag,
                      count_point_type = count_type,
                      operation_description = opr_desc
                WHERE routing_sequence_id = to_sequence_id
                  AND operation_sequence_id = p_op_seq_id;

               copy_ops_update := copy_ops_update + 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  UPDATE bom_operation_sequences
                     SET standard_operation_id = NULL
                   WHERE routing_sequence_id = to_sequence_id
                     AND operation_sequence_id = p_op_seq_id;
            END;
         END LOOP;
      END IF;

      -- End Bug fix 3473802

--Start bug fix for bug 7597474
insert into bom_operation_skills
(LEVEL_ID,
ORGANIZATION_ID,
OPERATION_SEQUENCE_ID,
STANDARD_OPERATION_ID,
RESOURCE_ID,
COMPETENCE_ID,
RATING_LEVEL_ID,
QUALIFICATION_TYPE_ID,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
CREATED_BY,
CREATION_DATE)

select
SKL.LEVEL_ID,
to_org_id,
SEQ2.OPERATION_SEQUENCE_ID,
SKL.STANDARD_OPERATION_ID,
SKL.RESOURCE_ID,
SKL.COMPETENCE_ID,
SKL.RATING_LEVEL_ID,
SKL.QUALIFICATION_TYPE_ID,
sysdate,
user_id,
user_id,
user_id,
sysdate

from bom_operation_skills SKL, bom_operation_sequences SEQ1, bom_operation_sequences SEQ2
where SEQ1.routing_sequence_id = from_sequence_id
and SEQ2.routing_sequence_id = to_sequence_id
and SKL.operation_sequence_id = SEQ1.operation_sequence_id
and SEQ1.operation_seq_num = SEQ2.operation_seq_num

and SKL.operation_sequence_id in
  (select operation_sequence_id
  from bom_operation_sequences
  where routing_sequence_id = from_sequence_id
  );
--End bug fix for bug 7597474

      OPEN process_op;

      LOOP
         FETCH process_op
          INTO p_op_seq_id,
               p_op_seq_num;

         EXIT WHEN process_op%NOTFOUND;

         BEGIN
            SELECT operation_sequence_id
              INTO new_p_op_seq_id
              FROM bom_operation_sequences
             WHERE routing_sequence_id = to_sequence_id
               AND operation_type = 2
               AND NVL (eco_for_production, 2) = 2
               AND operation_seq_num = p_op_seq_num;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         UPDATE bom_operation_sequences
            SET process_op_seq_id = new_p_op_seq_id
          WHERE operation_type = 1
            AND routing_sequence_id = to_sequence_id
            AND process_op_seq_id = p_op_seq_id;
      END LOOP;

      OPEN line_op;

      LOOP
         FETCH line_op
          INTO l_op_seq_id,
               l_op_seq_num;

         EXIT WHEN line_op%NOTFOUND;

         BEGIN
            SELECT operation_sequence_id
              INTO new_l_op_seq_id
              FROM bom_operation_sequences
             WHERE routing_sequence_id = to_sequence_id
               AND operation_type = 3
               AND NVL (eco_for_production, 2) = 2
               AND operation_seq_num = l_op_seq_num;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         UPDATE bom_operation_sequences
            SET line_op_seq_id = new_l_op_seq_id
          WHERE operation_type = 1
            AND routing_sequence_id = to_sequence_id
            AND line_op_seq_id = l_op_seq_id;
      END LOOP;

      INSERT INTO bom_operation_networks
                  (from_op_seq_id,
                   to_op_seq_id,
                   transition_type,
                   planning_pct,
                   effectivity_date,
                   disable_date,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
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
				   request_id,
				   program_application_id,
				   program_id,
				   program_update_date
                  )
         SELECT bos3.operation_sequence_id,
                bos4.operation_sequence_id,
                bon.transition_type,
                bon.planning_pct,
				-- Operation Network effectivity will be effective from target's to operation,
				-- which will be greater than target's from operation
				bos4.effectivity_date,
				/*
                DECODE (p_routing_or_eco,
                        1, bon.effectivity_date,
                        p_eco_eff_date
                       ),*/
                bon.disable_date,
                bon.created_by,
                bon.creation_date,
                bon.last_updated_by,
                bon.last_update_date,
                bon.last_update_login,
                bon.attribute_category,
                bon.attribute1,
                bon.attribute2,
                bon.attribute3,
                bon.attribute4,
                bon.attribute5,
                bon.attribute6,
                bon.attribute7,
                bon.attribute8,
                bon.attribute9,
                bon.attribute10,
                bon.attribute11,
                bon.attribute12,
                bon.attribute13,
                bon.attribute14,
                bon.attribute15,
                fnd_global.conc_request_id,
                NULL,
                fnd_global.conc_program_id,
                sysdate
           FROM bom_operation_networks bon,
                bom_operation_sequences bos4,                    -- dest to op
                bom_operation_sequences bos3,                  -- dest from op
                bom_operation_sequences bos2,                     -- src to op
                bom_operation_sequences bos1                    -- src from op
          WHERE bon.from_op_seq_id = bos1.operation_sequence_id
            AND bon.to_op_seq_id = bos2.operation_sequence_id
            AND bos1.routing_sequence_id = bos2.routing_sequence_id
            AND bos1.routing_sequence_id = x_from_sequence_id
            AND bos3.routing_sequence_id = to_sequence_id
            AND bos3.operation_seq_num = bos1.operation_seq_num
--  AND greatest(bos1.effectivity_date, l_curr_date) = greatest(bos3.effectivity_date, l_curr_date) -- added for bug 2718955
            -- Just compare the last updated by which will have the from operation seq num
			-- If the operation is copied then we need to copy the network, the effectivity filter
			-- is already applied at the operation sequence level
			AND bos3.last_updated_by = bos1.operation_sequence_id
			AND bos4.last_updated_by = bos2.operation_sequence_id
            /* Commented as part of TTMO Enh R12
            AND DECODE (display_option,
                        1, bos1.effectivity_date,
                        GREATEST (bos1.effectivity_date, l_curr_date)
                       ) =
                  DECODE
                     (display_option,
                      1, bos3.effectivity_date,
                      GREATEST (bos3.effectivity_date, l_curr_date)
                     )                                -- added for bug 2788795
		    */
            AND NVL (bos3.operation_type, 1) = NVL (bos1.operation_type, 1)
            AND NVL (bos1.eco_for_production, 2) = 2
            AND NVL (bos2.eco_for_production, 2) = 2
            AND NVL (bos3.eco_for_production, 2) = 2
            AND NVL (bos4.eco_for_production, 2) = 2
            AND bos4.routing_sequence_id = to_sequence_id
            AND bos4.operation_seq_num = bos2.operation_seq_num
            -- Just compare the last updated by which will have the from operation seq num
			-- If the operation is copied then we need to copy the network, the effectivity filter
			-- is already applied at the operation sequence level
			/*
            AND DECODE (display_option,
                        1, bos2.effectivity_date,
                        GREATEST (bos2.effectivity_date, l_curr_date)
                       ) =
                  DECODE
                     (display_option,
                      1, bos4.effectivity_date,
                      GREATEST (bos4.effectivity_date, l_curr_date)
                     )                                -- added for bug 2788795
			*/
            AND NVL (bos4.operation_type, 1) = NVL (bos2.operation_type, 1);

      IF p_log_errors = 'Y' THEN
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_NRTG_OPTYPE_NOT_EXISTS',bos1.operation_seq_num,mfgl.meaning),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
			FROM bom_operation_networks bon,
                bom_operation_sequences bos4,                    -- dest to op
                bom_operation_sequences bos3,                  -- dest from op
                bom_operation_sequences bos2,                     -- src to op
                bom_operation_sequences bos1,                    -- src from op
				mfg_lookups mfgl
          WHERE bon.from_op_seq_id = bos1.operation_sequence_id
            AND bon.to_op_seq_id = bos2.operation_sequence_id
            AND bos1.routing_sequence_id = bos2.routing_sequence_id
            AND bos1.routing_sequence_id = x_from_sequence_id
            AND bos3.routing_sequence_id = to_sequence_id
            AND bos3.operation_seq_num = bos1.operation_seq_num
			AND bos3.last_updated_by = bos1.operation_sequence_id
			AND bos4.last_updated_by = bos2.operation_sequence_id
            AND bos3.operation_type(+) = bos1.operation_type
            AND NVL (bos1.eco_for_production, 2) = 2
            AND NVL (bos2.eco_for_production, 2) = 2
            AND NVL (bos3.eco_for_production, 2) = 2
            AND NVL (bos4.eco_for_production, 2) = 2
            AND bos4.routing_sequence_id = to_sequence_id
            AND bos4.operation_seq_num = bos2.operation_seq_num
            AND NVL (bos4.operation_type, 1) = NVL (bos2.operation_type, 1)
			AND mfgl.lookup_type = 'BOM_OPERATION_TYPE'
			AND mfgl.lookup_code = bos1.operation_type
			MINUS
		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_NRTG_OPTYPE_NOT_EXISTS',bos1.operation_seq_num, mfgl.meaning),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
			FROM bom_operation_networks bon,
                bom_operation_sequences bos4,                    -- dest to op
                bom_operation_sequences bos3,                  -- dest from op
                bom_operation_sequences bos2,                     -- src to op
                bom_operation_sequences bos1,                    -- src from op
				mfg_lookups mfgl
          WHERE bon.from_op_seq_id = bos1.operation_sequence_id
            AND bon.to_op_seq_id = bos2.operation_sequence_id
            AND bos1.routing_sequence_id = bos2.routing_sequence_id
            AND bos1.routing_sequence_id = x_from_sequence_id
            AND bos3.routing_sequence_id = to_sequence_id
            AND bos3.operation_seq_num = bos1.operation_seq_num
			AND bos3.last_updated_by = bos1.operation_sequence_id
			AND bos4.last_updated_by = bos2.operation_sequence_id
            AND bos3.operation_type = bos1.operation_type
            AND NVL (bos1.eco_for_production, 2) = 2
            AND NVL (bos2.eco_for_production, 2) = 2
            AND NVL (bos3.eco_for_production, 2) = 2
            AND NVL (bos4.eco_for_production, 2) = 2
            AND bos4.routing_sequence_id = to_sequence_id
            AND bos4.operation_seq_num = bos2.operation_seq_num
            AND NVL (bos4.operation_type, 1) = NVL (bos2.operation_type, 1)
			AND mfgl.lookup_type = 'BOM_OPERATION_TYPE'
			AND mfgl.lookup_code = bos1.operation_type;
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
					 )
		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_NRTG_OPTYPE_NOT_EXISTS',bos2.operation_seq_num,mfgl.meaning),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
            FROM bom_operation_networks bon,
                bom_operation_sequences bos4,                    -- dest to op
                bom_operation_sequences bos3,                  -- dest from op
                bom_operation_sequences bos2,                     -- src to op
                bom_operation_sequences bos1,                    -- src from op
				mfg_lookups mfgl
          WHERE bon.from_op_seq_id = bos1.operation_sequence_id
            AND bon.to_op_seq_id = bos2.operation_sequence_id
            AND bos1.routing_sequence_id = bos2.routing_sequence_id
            AND bos1.routing_sequence_id = x_from_sequence_id
            AND bos3.routing_sequence_id = to_sequence_id
            AND bos3.operation_seq_num = bos1.operation_seq_num
			AND bos3.last_updated_by = bos1.operation_sequence_id
			AND bos4.last_updated_by = bos2.operation_sequence_id
            AND NVL (bos3.operation_type, 1) = NVL (bos1.operation_type, 1)
            AND NVL (bos1.eco_for_production, 2) = 2
            AND NVL (bos2.eco_for_production, 2) = 2
            AND NVL (bos3.eco_for_production, 2) = 2
            AND NVL (bos4.eco_for_production, 2) = 2
            AND bos4.routing_sequence_id = to_sequence_id
            AND bos4.operation_seq_num = bos2.operation_seq_num
            AND bos4.operation_type(+) = bos2.operation_type
			AND mfgl.lookup_type = 'BOM_OPERATION_TYPE'
			AND mfgl.lookup_code = bos2.operation_type
			MINUS
		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_NRTG_OPTYPE_NOT_EXISTS',bos2.operation_seq_num,mfgl.meaning),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
            FROM bom_operation_networks bon,
                bom_operation_sequences bos4,                    -- dest to op
                bom_operation_sequences bos3,                  -- dest from op
                bom_operation_sequences bos2,                     -- src to op
                bom_operation_sequences bos1,                    -- src from op
				mfg_lookups mfgl
          WHERE bon.from_op_seq_id = bos1.operation_sequence_id
            AND bon.to_op_seq_id = bos2.operation_sequence_id
            AND bos1.routing_sequence_id = bos2.routing_sequence_id
            AND bos1.routing_sequence_id = x_from_sequence_id
            AND bos3.routing_sequence_id = to_sequence_id
            AND bos3.operation_seq_num = bos1.operation_seq_num
			AND bos3.last_updated_by = bos1.operation_sequence_id
			AND bos4.last_updated_by = bos2.operation_sequence_id
            AND NVL (bos3.operation_type, 1) = NVL (bos1.operation_type, 1)
            AND NVL (bos1.eco_for_production, 2) = 2
            AND NVL (bos2.eco_for_production, 2) = 2
            AND NVL (bos3.eco_for_production, 2) = 2
            AND NVL (bos4.eco_for_production, 2) = 2
            AND bos4.routing_sequence_id = to_sequence_id
            AND bos4.operation_seq_num = bos2.operation_seq_num
            AND bos4.operation_type = bos2.operation_type
			AND mfgl.lookup_type = 'BOM_OPERATION_TYPE'
			AND mfgl.lookup_code = bos2.operation_type;


	  END IF; /* IF p_log_errors = 'Y' */

      sql_stmt_num := 101;

      BEGIN
         FOR x_op IN source_rtg
         LOOP
            sql_stmt_num := 201;
            fnd_attached_documents2_pkg.copy_attachments
                            (x_from_entity_name            => 'BOM_OPERATION_SEQUENCES',
                             x_from_pk1_value              => x_op.last_updated_by,
                             x_from_pk2_value              => '',
                             x_from_pk3_value              => '',
                             x_from_pk4_value              => '',
                             x_from_pk5_value              => '',
                             x_to_entity_name              => 'BOM_OPERATION_SEQUENCES',
                             x_to_pk1_value                => x_op.operation_sequence_id,
                             x_to_pk2_value                => '',
                             x_to_pk3_value                => '',
                             x_to_pk4_value                => '',
                             x_to_pk5_value                => '',
                             x_created_by                  => user_id,
                             x_last_update_login           => '',
                             x_program_application_id      => '',
                             x_program_id                  => fnd_global.conc_program_id,
                             x_request_id                  => fnd_global.conc_request_id
                            );
            sql_stmt_num := 301;
         END LOOP;

         sql_stmt_num := 401;
      END;

      --begin bug fix 3473851
      sql_stmt_num := 501;
      fnd_attached_documents2_pkg.copy_attachments
                            (x_from_entity_name            => 'BOM_OPERATIONAL_ROUTINGS',
                             x_from_pk1_value              => x_from_sequence_id,
                             x_from_pk2_value              => '',
                             x_from_pk3_value              => '',
                             x_from_pk4_value              => '',
                             x_from_pk5_value              => '',
                             x_to_entity_name              => 'BOM_OPERATIONAL_ROUTINGS',
                             x_to_pk1_value                => to_sequence_id,
                             x_to_pk2_value                => '',
                             x_to_pk3_value                => '',
                             x_to_pk4_value                => '',
                             x_to_pk5_value                => '',
                             x_created_by                  => user_id,
                             x_last_update_login           => '',
                             x_program_application_id      => '',
                             x_program_id                  => fnd_global.conc_program_id,
                             x_request_id                  => fnd_global.conc_request_id
                            );
      --end bug fix 3473851

      --INSERT OPERATION RESOURCES
      --NULL OUT RESOURCE_OFFSET_PERCENT
      --SET ASSIGNED UNITS TO 1 IF RESOURCES IN DEPT IS 24 HRS  -- removed restriction as per bug 2661684
      --UPDATE RESOURCE_ID TO THAT OF COPY_TO_ORG
      --LEAVE OUT RESOURCES THAT DO NOT EXIST IN COPY_TO_ORG DEPT.
      sql_stmt_num := 20;

      INSERT INTO bom_operation_resources
                  (operation_sequence_id,
                   resource_seq_num,
                   resource_id,
                   activity_id,
                   standard_rate_flag,
                   assigned_units,
                   usage_rate_or_amount,
                   usage_rate_or_amount_inverse,
                   basis_type,
                   schedule_flag,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   resource_offset_percent,
                   autocharge_type,
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
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date,
                   schedule_seq_num,
                   substitute_group_num,
                   principle_flag,
                   setup_id,
                   change_notice,
                   acd_type,
                   original_system_reference
                  )
         SELECT a.operation_sequence_id,
                b.resource_seq_num,
                d.resource_id,
                b.activity_id,
                b.standard_rate_flag,
--    DECODE(E.AVAILABLE_24_HOURS_FLAG, 1, 1, B.ASSIGNED_UNITS), -- changed for bug 2661684
                b.assigned_units,
                b.usage_rate_or_amount,
                b.usage_rate_or_amount_inverse,
                b.basis_type,
                b.schedule_flag,
                SYSDATE,
                b.operation_sequence_id,         -- Instead of last_updated_by
                SYSDATE,
                NVL (b.schedule_seq_num, user_id),    -- Instead of created by
                user_id,
                NULL,
                b.autocharge_type,
                b.attribute_category,
                b.attribute1,
                b.attribute2,
                b.attribute3,
                b.attribute4,
                b.attribute5,
                b.attribute6,
                b.attribute7,
                b.attribute8,
                b.attribute9,
                b.attribute10,
                b.attribute11,
                b.attribute12,
                b.attribute13,
                b.attribute14,
                b.attribute15,
                fnd_global.conc_request_id,
                NULL,
                fnd_global.conc_program_id,
                sysdate,
                b.schedule_seq_num,
                b.substitute_group_num,
                b.principle_flag,
                b.setup_id,
                DECODE (p_routing_or_eco, 1, b.change_notice, p_e_change_notice),
                DECODE (p_routing_or_eco, 1, b.acd_type, 1),
                -- Add is the action for ECO
                b.original_system_reference
           FROM bom_operation_sequences a,
                bom_operation_resources b,
                bom_resources c,
                bom_resources d
--         ,BOM_DEPARTMENT_RESOURCES E
         WHERE  a.routing_sequence_id = to_sequence_id
            AND a.last_updated_by = b.operation_sequence_id
            AND b.resource_id = c.resource_id
            AND c.resource_code = d.resource_code
            AND d.organization_id = to_org_id
--    AND   D.RESOURCE_ID = E.RESOURCE_ID
--    AND   E.DEPARTMENT_ID = A.DEPARTMENT_ID
            AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE;

      IF p_log_errors = 'Y' THEN
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_OPER_RES_NOT_EXISTS',fbor.operation_seq_num, c.resource_code,'RES'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a,
                bom_operation_resources b,
				bom_operation_sequences fbor,
                bom_resources c,
                bom_resources d
         WHERE  a.routing_sequence_id = to_sequence_id
            AND a.last_updated_by = b.operation_sequence_id
            AND b.resource_id = c.resource_id
            AND c.resource_code = d.resource_code(+)
            AND d.organization_id = to_org_id
            AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE
			AND fbor.operation_sequence_id = b.operation_sequence_id
		MINUS
	    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_OPER_RES_NOT_EXISTS',fbor.operation_seq_num, c.resource_code,'RES'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a,
                bom_operation_resources b,
				bom_operation_sequences fbor,
                bom_resources c,
                bom_resources d
         WHERE  a.routing_sequence_id = to_sequence_id
            AND a.last_updated_by = b.operation_sequence_id
            AND b.resource_id = c.resource_id
            AND c.resource_code = d.resource_code
            AND d.organization_id = to_org_id
            AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE
			AND fbor.operation_sequence_id = b.operation_sequence_id;
	  END IF; /* IF p_log_errors = 'Y' */


      copy_resources := SQL%ROWCOUNT;

      IF (from_org_id = to_org_id)
      THEN
         total_resources := SQL%ROWCOUNT;
      END IF;

      -- UPDATE OPERATION RESOURCES TO
      -- IF ACTIVITY IS ORG DEPENDENT, NULL IT OUT
      -- IF NO CONVERSION TO HOUR UOM CLASS, SET SCHEDUEL FLAG TO NO
      -- If there exist a similar setup in the other org, copy the correct setup_id
      -- else null out the setup_id field -- bug 2751946
      -- ONLY FOR INTER ORG COPY
      IF (from_org_id <> to_org_id)
      THEN
         sql_stmt_num := 30;

         UPDATE bom_operation_resources a
            SET activity_id =
                   (SELECT DECODE (organization_id, NULL, activity_id, NULL)
                      FROM cst_activities
                     WHERE activity_id = a.activity_id),
                schedule_flag =
                   (SELECT DECODE (c.unit_of_measure,
                                   NULL, 2,
                                   hour_uom_code_v, a.schedule_flag,
                                   DECODE (b.uom_class,
                                           hour_uom_class_v, a.schedule_flag,
                                           2
                                          )
                                  )
                      FROM mtl_units_of_measure b,
                           bom_resources c
                     WHERE a.resource_id = c.resource_id
                       AND c.unit_of_measure = b.unit_of_measure(+)),
                setup_id =
                   (SELECT brs.setup_id
                      FROM bom_resource_setups brs,
                           bom_setup_types bst        -- added for bug 2751946
                     WHERE brs.resource_id = a.resource_id
                       AND brs.setup_id = bst.setup_id
                       AND bst.setup_code = (SELECT setup_code
                                               FROM bom_setup_types
                                              WHERE setup_id = a.setup_id))
          WHERE a.operation_sequence_id IN (
                                    SELECT operation_sequence_id
                                      FROM bom_operation_sequences
                                     WHERE routing_sequence_id =
                                                                to_sequence_id);
      END IF;

-- Bug Fix 2991810
      sql_stmt_num := 25;

      INSERT INTO bom_sub_operation_resources
                  (operation_sequence_id,
                   substitute_group_num,
                   resource_id,
                   schedule_seq_num,
                   replacement_group_num,
                   activity_id,
                   standard_rate_flag,
                   assigned_units,
                   usage_rate_or_amount,
                   usage_rate_or_amount_inverse,
                   basis_type,
                   schedule_flag,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   resource_offset_percent,
                   autocharge_type,
                   attribute_category,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date,
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
                   principle_flag,
                   setup_id,
                   change_notice,
                   acd_type,
                   original_system_reference
                  )
         SELECT /*DISTINCT Commented the above distinct for bug 6828461*/
	                 a.operation_sequence_id,
                         b.substitute_group_num,
                         d.resource_id,
                         b.schedule_seq_num,
                         b.replacement_group_num,
                         b.activity_id,
                         b.standard_rate_flag,
                         b.assigned_units,
                         b.usage_rate_or_amount,
                         b.usage_rate_or_amount_inverse,
                         b.basis_type,
                         b.schedule_flag,
                         SYSDATE,
                         user_id,
                         SYSDATE,
                         user_id,
                         NULL,
                         b.resource_offset_percent,
                         b.autocharge_type,
                         b.attribute_category,
                         fnd_global.conc_request_id,
                         NULL,
                         fnd_global.conc_program_id,
                         sysdate,
                         b.attribute1,
                         b.attribute2,
                         b.attribute3,
                         b.attribute4,
                         b.attribute5,
                         b.attribute6,
                         b.attribute7,
                         b.attribute8,
                         b.attribute9,
                         b.attribute10,
                         b.attribute11,
                         b.attribute12,
                         b.attribute13,
                         b.attribute14,
                         b.attribute15,
                         b.principle_flag,
                         b.setup_id,
                         DECODE (p_routing_or_eco,
                                 1, b.change_notice,
                                 p_e_change_notice
                                ),
                         DECODE (p_routing_or_eco, 1, b.acd_type, 1),
                         -- Add is the action for ECO
                         b.original_system_reference
                    FROM /*BOM_OPERATION_RESOURCES A,  Commented for Bug 6828461*/
			 bom_operation_sequences a, /*Added for Bug 6828461*/
                         bom_sub_operation_resources b,
                         bom_resources c,
                         bom_resources d
                   WHERE A.ROUTING_SEQUENCE_ID = to_sequence_id /*Added for performance improvement for bug 6828461*/
		     AND a.last_updated_by = b.operation_sequence_id
                    -- AND a.created_by = b.schedule_seq_num Bug No 6407518
                     AND b.resource_id = c.resource_id
                     AND c.resource_code = d.resource_code
                     AND d.organization_id = to_org_id
                     AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE;

	  IF p_log_errors = 'Y' THEN
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		    SELECT DISTINCT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_SUB_OPER_RES_NOT_EXISTS',fbor.operation_seq_num, c.resource_code, 'SUB'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
            FROM bom_operation_resources a,
			     bom_operation_sequences fbor,
                         bom_sub_operation_resources b,
                         bom_resources c,
                         bom_resources d
                   WHERE a.last_updated_by = b.operation_sequence_id
				     AND b.operation_sequence_id = fbor.operation_sequence_id
                     AND a.created_by = b.schedule_seq_num
                     AND b.resource_id = c.resource_id
                     AND c.resource_code = d.resource_code(+)
                     AND d.organization_id = to_org_id
                     AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE
			MINUS
		    SELECT DISTINCT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_SUB_OPER_RES_NOT_EXISTS',fbor.operation_seq_num, c.resource_code, 'SUB'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
            FROM bom_operation_resources a,
			     bom_operation_sequences fbor,
                         bom_sub_operation_resources b,
                         bom_resources c,
                         bom_resources d
                   WHERE a.last_updated_by = b.operation_sequence_id
                     AND a.created_by = b.schedule_seq_num
				     AND b.operation_sequence_id = fbor.operation_sequence_id
                     AND b.resource_id = c.resource_id
                     AND c.resource_code = d.resource_code
                     AND d.organization_id = to_org_id
                     AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE;
		END IF; /* IF p_log_errors = 'Y' */
      copy_sub_resources := SQL%ROWCOUNT;

      IF (from_org_id = to_org_id)
      THEN
         total_sub_resources := SQL%ROWCOUNT;
      END IF;

      IF (from_org_id <> to_org_id)
      THEN
         sql_stmt_num := 35;

         UPDATE bom_sub_operation_resources a
            SET activity_id =
                   (SELECT DECODE (organization_id, NULL, activity_id, NULL)
                      FROM cst_activities
                     WHERE activity_id = a.activity_id),
                schedule_flag =
                   (SELECT DECODE (c.unit_of_measure,
                                   NULL, 2,
                                   hour_uom_code_v, a.schedule_flag,
                                   DECODE (b.uom_class,
                                           hour_uom_class_v, a.schedule_flag,
                                           2
                                          )
                                  )
                      FROM mtl_units_of_measure b,
                           bom_resources c
                     WHERE a.resource_id = c.resource_id
                       AND c.unit_of_measure = b.unit_of_measure(+)),
                setup_id =
                   (SELECT brs.setup_id
                      FROM bom_resource_setups brs,
                           bom_setup_types bst
                     WHERE brs.resource_id = a.resource_id
                       AND brs.setup_id = bst.setup_id
                       AND bst.setup_code = (SELECT setup_code
                                               FROM bom_setup_types
                                              WHERE setup_id = a.setup_id))
          WHERE a.operation_sequence_id IN (
                                    SELECT operation_sequence_id
                                      FROM bom_operation_sequences
                                     WHERE routing_sequence_id =
                                                                to_sequence_id);
      END IF;

-- Bug Fix 2991810

      -- UPDATE LAST_UPDATED_BY COLUMN USED TO STORE COPY_FROM OP_SEQ_IDS
      sql_stmt_num := 55;

      UPDATE bom_operation_sequences
         SET last_updated_by = user_id
       WHERE routing_sequence_id = to_sequence_id;

-- Bug Fix 2991810
      sql_stmt_num := 65;

      UPDATE bom_operation_resources
         SET last_updated_by = user_id,
             created_by = user_id
       WHERE operation_sequence_id IN (
                                    SELECT operation_sequence_id
                                      FROM bom_operation_sequences
                                     WHERE routing_sequence_id =
                                                                to_sequence_id);

      sql_stmt_num := 39;

      SELECT COUNT (*)
        INTO copy_instrs
        FROM fnd_attached_documents b,
             bom_operation_sequences a
       WHERE a.routing_sequence_id = to_sequence_id
         AND a.operation_sequence_id = b.pk1_value
         AND b.entity_name = 'BOM_OPERATION_SEQUENCES';

      --begin bug fix 3473851
      sql_stmt_num := 40;

      SELECT COUNT (*)
        INTO copy_hdr_instrs
        FROM fnd_attached_documents b,
             bom_operational_routings a
       WHERE a.routing_sequence_id = to_sequence_id
         AND a.routing_sequence_id = b.pk1_value
         AND b.entity_name = 'BOM_OPERATIONAL_ROUTINGS';

      --end bug fix 3473851
      IF (from_org_id = to_org_id)
      THEN
         total_instructions := copy_instrs;
         total_hdr_instructions := copy_hdr_instrs;             --bug 3473851
      END IF;

      fnd_message.set_name ('BOM', 'BOM_ROUTING_COPY_DONE');
      fnd_message.set_token ('ENTITY1', copy_operations);
      fnd_message.set_token ('ENTITY2', total_opseqs);
      fnd_message.set_token ('ENTITY3', copy_resources);
      fnd_message.set_token ('ENTITY4', total_resources);
      fnd_message.set_token ('ENTITY7', copy_sub_resources);
      -- Bug2991810 the message also needs to be modified
      fnd_message.set_token ('ENTITY8', total_sub_resources);    -- Bug2991810
      fnd_message.set_token ('ENTITY5', copy_instrs);
      fnd_message.set_token ('ENTITY6', total_instructions);
      fnd_message.set_token ('ENTITY9', copy_hdr_instrs);        --bug 3473851
      fnd_message.set_token ('ENTITY10', total_hdr_instructions);
   --bug 3473851
   EXCEPTION
      WHEN OTHERS
      THEN
         err_msg :=
                 'COPY_ROUTING (' || TO_CHAR (sql_stmt_num) || ') '
                 || SQLERRM;
         fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
         fnd_message.set_token ('ENTITY', err_msg);
         ROLLBACK TO begin_routing_copy;
         app_exception.raise_exception;
   END copy_routing;

   PROCEDURE switch_to_primary_rtg (
      p_org_id                  IN   NUMBER,
      p_ass_itm_id              IN   NUMBER,
      p_alt_rtg_desg            IN   VARCHAR2,
      p_alt_desg_for_prim_rtg   IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE bom_operational_routings
         SET alternate_routing_designator = 'NONE'
       WHERE organization_id = p_org_id
         AND assembly_item_id = p_ass_itm_id
         AND alternate_routing_designator = p_alt_rtg_desg;

      UPDATE bom_operational_routings
         SET alternate_routing_designator = p_alt_desg_for_prim_rtg
       WHERE organization_id = p_org_id
         AND assembly_item_id = p_ass_itm_id
         AND NVL (alternate_routing_designator, 'NULL') = 'NULL';

      UPDATE bom_operational_routings
         SET alternate_routing_designator = NULL
       WHERE organization_id = p_org_id
         AND assembly_item_id = p_ass_itm_id
         AND alternate_routing_designator = 'NONE';
   END switch_to_primary_rtg;

/*** Added as part of Patchset I enhancement - 2544075 ***/
   PROCEDURE switch_rtg_validate (
      p_org_id                  IN              NUMBER,
      p_ass_itm_id              IN              NUMBER,
      p_alt_rtg_desg            IN              VARCHAR2,
      p_alt_desg_for_prim_rtg   IN              VARCHAR2,
      x_return_status           IN OUT NOCOPY   VARCHAR2,
      x_message_name            IN OUT NOCOPY   VARCHAR2
   )
   IS
      CURSOR validateswitch
      IS
         SELECT NULL
           FROM DUAL
          WHERE EXISTS (
                   SELECT 1
                     /* Checking for the BOM components operation seq. num. for primary */
                   FROM   bom_bill_of_materials bom,
                          bom_component_operations bco
                    WHERE bom.organization_id = p_org_id
                      AND bom.assembly_item_id = p_ass_itm_id
                      AND bom.alternate_bom_designator IS NULL
                      AND bom.bill_sequence_id = bco.bill_sequence_id)
             OR EXISTS (
                  SELECT 1
                    /* Checking for the BOM components operation seq. num. for primary*/
                  FROM   bom_bill_of_materials bom,
                         bom_inventory_components bic
                   WHERE bom.organization_id = p_org_id
                     AND bom.assembly_item_id = p_ass_itm_id
                     AND bom.alternate_bom_designator IS NULL
                     AND bom.bill_sequence_id = bic.bill_sequence_id
                     AND bic.operation_seq_num > 1)
             OR EXISTS (
                  SELECT 1
                    /* Checking for the BOM components operation seq. num. for alternate */
                  FROM   bom_bill_of_materials bom,
                         bom_component_operations bco
                   WHERE bom.organization_id = p_org_id
                     AND bom.assembly_item_id = p_ass_itm_id
                     AND bom.alternate_bom_designator = p_alt_rtg_desg
                     AND bom.bill_sequence_id = bco.bill_sequence_id)
             OR EXISTS (
                  SELECT 1
                    /* Checking for the BOM components operation seq. num. for alternate */
                  FROM   bom_bill_of_materials bom,
                         bom_inventory_components bic
                   WHERE bom.organization_id = p_org_id
                     AND bom.assembly_item_id = p_ass_itm_id
                     AND bom.alternate_bom_designator = p_alt_rtg_desg
                     AND bom.bill_sequence_id = bic.bill_sequence_id
                     AND bic.operation_seq_num > 1)
             OR EXISTS (
                  SELECT 1     /* Check if flow schedule exists for primary */
                    FROM wip_flow_schedules
                   WHERE organization_id = p_org_id
                     AND primary_item_id = p_ass_itm_id
                     AND alternate_routing_designator IS NULL)
             OR EXISTS (
                  SELECT 1   /* Check if flow schedule exists for alternate */
                    FROM wip_flow_schedules
                   WHERE organization_id = p_org_id
                     AND primary_item_id = p_ass_itm_id
                     AND alternate_routing_designator = p_alt_rtg_desg)
             OR EXISTS (
                  SELECT 1                 /* Check for WIP Jobs on primary */
                    FROM wip_discrete_jobs job --modified for bug 10431513
                         --bom_operational_routings bor
                   WHERE job.organization_id = p_org_id
                     AND job.primary_item_id = p_ass_itm_id
                     AND job.alternate_routing_designator IS NULL)
             OR EXISTS (
                  SELECT 1               /* Check for WIP Jobs on alternate */
                    FROM wip_discrete_jobs job --modified for bug 10431513
                         --bom_operational_routings bor
                   WHERE job.organization_id = p_org_id
                     AND job.primary_item_id = p_ass_itm_id
                     AND job.alternate_routing_designator = p_alt_rtg_desg);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      FOR valswitch IN validateswitch
      LOOP
         x_return_status := bom_rtg_error_handler.g_status_warning;
         x_message_name := 'BOM_SWITCH_ROUTING_WARNINGS';
      END LOOP;
   END switch_rtg_validate;

   PROCEDURE switch_to_primary_rtg (
      p_org_id                  IN              NUMBER,
      p_ass_itm_id              IN              NUMBER,
      p_alt_rtg_desg            IN              VARCHAR2,
      p_alt_desg_for_prim_rtg   IN              VARCHAR2,
      x_return_status           IN OUT NOCOPY   VARCHAR2,
      x_message_name            IN OUT NOCOPY   VARCHAR2
   )
   IS
   BEGIN
      switch_rtg_validate
                         (p_org_id                     => p_org_id,
                          p_ass_itm_id                 => p_ass_itm_id,
                          p_alt_rtg_desg               => p_alt_rtg_desg,
                          p_alt_desg_for_prim_rtg      => p_alt_desg_for_prim_rtg,
                          x_return_status              => x_return_status,
                          x_message_name               => x_message_name
                         );
      switch_to_primary_rtg
                           (p_org_id                     => p_org_id,
                            p_ass_itm_id                 => p_ass_itm_id,
                            p_alt_rtg_desg               => p_alt_rtg_desg,
                            p_alt_desg_for_prim_rtg      => p_alt_desg_for_prim_rtg
                           );
   END switch_to_primary_rtg;

   FUNCTION GET_MESSAGE (p_msg_name IN VARCHAR2, p_op_seq_num IN NUMBER)
   RETURN VARCHAR2
   IS
   BEGIN
      fnd_message.set_name ('BOM', p_msg_name);
      fnd_message.set_token ('OP_SEQ', p_op_seq_num);
      RETURN fnd_message.get;
   END;
   FUNCTION GET_MESSAGE (p_msg_name IN VARCHAR2, p_op_seq_num IN NUMBER, p_oper_type IN VARCHAR2)
   RETURN VARCHAR2
   IS
   BEGIN
      fnd_message.set_name ('BOM', p_msg_name);
      fnd_message.set_token ('OP_SEQ', p_op_seq_num);
	  fnd_message.set_token ('OP_TYPE', p_oper_type);
      RETURN fnd_message.get;
   END;
   FUNCTION GET_MESSAGE (p_msg_name IN VARCHAR2, p_op_seq_num IN NUMBER, p_entity_name IN VARCHAR2, p_type IN VARCHAR2)
   RETURN VARCHAR2
   IS
   BEGIN
     fnd_message.set_name ('BOM', p_msg_name);
     fnd_message.set_token ('OP_SEQ', p_op_seq_num);
     IF p_type = 'DEP' THEN
	  fnd_message.set_token ('FROM_DEPT', p_entity_name);
	 ELSE
	  fnd_message.set_token ('RES_CODE', p_entity_name);
	 END IF;
     RETURN fnd_message.get;
   END;

   PROCEDURE switch_common_to_primary_rtg (		-- BUG 4712488
      p_org_id                  IN   NUMBER,
      p_ass_itm_id              IN   NUMBER,
      p_alt_rtg_desg            IN   VARCHAR2,
      p_alt_desg_for_prim_rtg   IN   VARCHAR2
   )
   IS
   BEGIN

      UPDATE bom_operational_routings
         SET common_assembly_item_id =
 	     ( SELECT assembly_item_id
	       FROM bom_operational_routings
	       WHERE assembly_item_id = p_ass_itm_id
	       AND organization_id = p_org_id
	       AND alternate_routing_designator = p_alt_rtg_desg )
	 , common_routing_sequence_id =
 	     ( SELECT routing_sequence_id
	       FROM bom_operational_routings
	       WHERE assembly_item_id = p_ass_itm_id
	       AND organization_id = p_org_id
	       AND alternate_routing_designator = p_alt_rtg_desg )
         , completion_subinventory =
 	     ( SELECT completion_subinventory
	       FROM bom_operational_routings
	       WHERE assembly_item_id = p_ass_itm_id
	       AND organization_id = p_org_id
	       AND alternate_routing_designator = p_alt_rtg_desg )
         , completion_locator_id =
 	     ( SELECT completion_locator_id
	       FROM bom_operational_routings
	       WHERE assembly_item_id = p_ass_itm_id
	       AND organization_id = p_org_id
	       AND alternate_routing_designator = p_alt_rtg_desg )
	WHERE common_routing_sequence_id IN
	     ( SELECT routing_Sequence_id FROM bom_operational_routings
	       WHERE assembly_item_id = p_ass_itm_id
	       AND organization_id = p_org_id
	       AND alternate_routing_designator IS NULL )
	AND common_assembly_item_id IN
	     ( SELECT assembly_item_id FROM bom_operational_routings
	       WHERE assembly_item_id = p_ass_itm_id
	       AND organization_id = p_org_id
	       AND alternate_routing_designator IS NULL );

   END switch_common_to_primary_rtg;

   PROCEDURE switch_common_to_alternate_rtg (	-- BUG 4712488
      p_org_id                  IN   NUMBER,
      p_ass_itm_id              IN   NUMBER,
      p_alt_desg_for_prim_rtg   IN   VARCHAR2,
      p_rtg_seq_id		IN   NUMBER
   )
   IS
   BEGIN

      UPDATE bom_operational_routings
         SET common_assembly_item_id =
 	     ( SELECT assembly_item_id
	       FROM bom_operational_routings
	       WHERE assembly_item_id = p_ass_itm_id
	       AND organization_id = p_org_id
	       AND alternate_routing_designator IS NULL )
	 , common_routing_sequence_id =
 	     ( SELECT routing_sequence_id
	       FROM bom_operational_routings
	       WHERE assembly_item_id = p_ass_itm_id
	       AND organization_id = p_org_id
	       AND alternate_routing_designator IS NULL )
         , completion_subinventory =
 	     ( SELECT completion_subinventory
	       FROM bom_operational_routings
	       WHERE assembly_item_id = p_ass_itm_id
	       AND organization_id = p_org_id
	       AND alternate_routing_designator IS NULL )
         , completion_locator_id =
 	     ( SELECT completion_locator_id
	       FROM bom_operational_routings
	       WHERE assembly_item_id = p_ass_itm_id
	       AND organization_id = p_org_id
	       AND alternate_routing_designator IS NULL )
         , alternate_routing_designator =
 	     ( p_alt_desg_for_prim_rtg )
	WHERE routing_sequence_id = p_rtg_seq_id;

   END switch_common_to_alternate_rtg;

   PROCEDURE copy_routing_for_revised_item (
      to_sequence_id          IN   NUMBER,
      from_sequence_id        IN   NUMBER,
      from_org_id             IN   NUMBER,
      to_org_id               IN   NUMBER,
      user_id                 IN   NUMBER DEFAULT -1,
      to_item_id              IN   NUMBER,
      direction               IN   NUMBER,
      to_alternate            IN   VARCHAR2,
      rev_date                     DATE,
      p_e_change_notice         IN   VARCHAR2,
      p_rev_item_seq_id   IN   NUMBER,
      p_routing_or_eco          IN   NUMBER DEFAULT 1,
	  p_trgt_eff_date           IN   DATE,
      p_eco_eff_date            IN   DATE,
      p_context_eco             IN   VARCHAR2,
	  p_log_errors              IN   VARCHAR2 DEFAULT 'N',
	  p_copy_request_id         IN   NUMBER DEFAULT NULL,
	  p_cpy_disable_fields      IN   VARCHAR2 DEFAULT 'N'
   )
   IS
      x_from_sequence_id       NUMBER          := from_sequence_id;
--  X_rev_date      date   := trunc(rev_date);  -- Removed for bug 2647027
      total_opseqs             NUMBER          := 0;
      total_resources          NUMBER          := 0;
      total_sub_resources      NUMBER          := 0;
      total_instructions       NUMBER          := 0;
      total_hdr_instructions   NUMBER          := 0;
      hour_uom_code_v          VARCHAR2 (3);
      hour_uom_class_v         VARCHAR2 (10);
      sql_stmt_num             NUMBER;
      err_msg                  VARCHAR2 (2000);
      copy_resources           NUMBER          := 0;
      copy_sub_resources       NUMBER          := 0;
      copy_instrs              NUMBER;
      copy_hdr_instrs          NUMBER;
      copy_operations          NUMBER;
      p_op_seq_id              NUMBER;
      p_op_seq_num             NUMBER;
      new_p_op_seq_id          NUMBER;
      l_op_seq_id              NUMBER;
      l_op_seq_num             NUMBER;
      new_l_op_seq_id          NUMBER;
      l_curr_date              DATE;                 -- Added for bug 2718955
      -- Bug fix 3473802
      p_st_op_id               NUMBER;
      new_st_op_id             NUMBER;
      min_qty                  NUMBER;
      back_flag                NUMBER;
      opt_flag                 NUMBER;
      count_type               NUMBER;
      opr_desc                 VARCHAR2 (240);
      copy_ops_update          NUMBER;

      CURSOR source_rtg
      IS
         SELECT operation_sequence_id,
                last_updated_by
           FROM bom_operation_sequences
          WHERE routing_sequence_id = to_sequence_id
            AND NVL (eco_for_production, 2) = 2;

      CURSOR process_op
      IS
         SELECT operation_sequence_id,
                operation_seq_num
           FROM bom_operation_sequences
          WHERE routing_sequence_id = x_from_sequence_id        -- Bug 2642427
            AND NVL (eco_for_production, 2) = 2
            AND operation_type = 2;

      CURSOR line_op
      IS
         SELECT operation_sequence_id,
                operation_seq_num
           FROM bom_operation_sequences
          WHERE routing_sequence_id = x_from_sequence_id        -- Bug 2642427
            AND NVL (eco_for_production, 2) = 2
            AND operation_type = 3;

      -- Cursor Bug fix 3473802
      CURSOR update_st_op
      IS
         SELECT standard_operation_id,
                operation_sequence_id
           FROM bom_operation_sequences
          WHERE routing_sequence_id = to_sequence_id;
	  l_from_item_id NUMBER;
   BEGIN
      SAVEPOINT begin_routing_copy;
      sql_stmt_num := 1;
      fnd_profile.get ('BOM:HOUR_UOM_CODE', hour_uom_code_v);

      BEGIN
         SELECT uom_class
           INTO hour_uom_class_v
           FROM mtl_units_of_measure
          WHERE uom_code = hour_uom_code_v;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      sql_stmt_num := 10;

      SELECT common_routing_sequence_id
        INTO x_from_sequence_id
        FROM bom_operational_routings
       WHERE routing_sequence_id = from_sequence_id;

      IF (from_org_id <> to_org_id)
      THEN
         rtg_get_msg_info (total_opseqs,
                           total_resources,
                           total_sub_resources,                     -- 2991810
                           total_instructions,
                           total_hdr_instructions,               --bug 3473851
                           x_from_sequence_id,
                           rev_date,
                           2
                          );
      END IF;

      --copy operations
      --null out std op id, operation_offset_%
      --do not copy operations where department does not exist in to org
      --if dept_id is diff in to org, reset dept id
      -- For flow routings, we need to update the process_op_seq_id
      -- and line_op_seq_id with the new values generated.
      sql_stmt_num := 15;
	  IF p_trgt_eff_date IS NULL THEN
        l_curr_date := SYSDATE;
	  ELSE
	    l_curr_date := p_trgt_eff_date; -- Routing can be copied to particular from TTMO flow - R12
	  END IF;

      INSERT INTO bom_operation_sequences
                  (operation_sequence_id,
                   routing_sequence_id,
                   operation_seq_num,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   standard_operation_id,
                   department_id,
                   operation_lead_time_percent,
                   minimum_transfer_quantity,
                   count_point_type,
                   operation_description,
                   effectivity_date,
                   disable_date,
                   backflush_flag,
                   option_dependent_flag,
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
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date,
                   operation_type,
                   reference_flag,
                   process_op_seq_id,
                   line_op_seq_id,
                   yield,
                   cumulative_yield,
                   reverse_cumulative_yield,
                   labor_time_calc,
                   machine_time_calc,
                   total_time_calc,
                   labor_time_user,
                   machine_time_user,
                   total_time_user,
                   net_planning_percent,
                   x_coordinate,
                   y_coordinate,
                   include_in_rollup,
                   operation_yield_enabled,
                   old_operation_sequence_id,
                   acd_type,
                   revised_item_sequence_id,
                   original_system_reference,
                   change_notice,
                   implementation_date,
                   eco_for_production,
                   shutdown_type,
                   -- Added by MK 04/10/2001
                   long_description,                   -- Added for bug 2767630
                   lowest_acceptable_yield,  -- Added for MES Enhancement
                   use_org_settings,
                   queue_mandatory_flag,
                   run_mandatory_flag,
                   to_move_mandatory_flag,
                   show_next_op_by_default,
                   show_scrap_code,
                   show_lot_attrib,
                   track_multiple_res_usage_dates,
                   check_skill --added for bug 7597474
                  )
         SELECT bom_operation_sequences_s.NEXTVAL,
                to_sequence_id,
                a.operation_seq_num,
                l_curr_date,
                a.operation_sequence_id,
                l_curr_date,
                user_id,
                user_id,
                a.standard_operation_id,
                c.department_id,
                NULL,
                a.minimum_transfer_quantity,
                a.count_point_type,
                a.operation_description,
-- Bug 2161841
--      GREATEST(A.EFFECTIVITY_DATE, l_curr_date),  -- Changed for bug 2647027
				p_eco_eff_date,
				CASE
				-- This flag will be set when current and future option is selected with
				-- copy through ECO
				WHEN a.disable_date IS NOT NULL
				 AND a.disable_date > p_eco_eff_date
				  THEN a.disable_date
				ELSE
				  TO_DATE (NULL)
				END AS disable_date,
                a.backflush_flag,
                a.option_dependent_flag,
                a.attribute_category,
                a.attribute1,
                a.attribute2,
                a.attribute3,
                a.attribute4,
                a.attribute5,
                a.attribute6,
                a.attribute7,
                a.attribute8,
                a.attribute9,
                a.attribute10,
                a.attribute11,
                a.attribute12,
                a.attribute13,
                a.attribute14,
                a.attribute15,
                fnd_global.conc_request_id,
                NULL,
                fnd_global.conc_program_id,
                sysdate,
                a.operation_type,
                DECODE (from_org_id, to_org_id, a.reference_flag, 2),
                -- Bug 3473802
                a.process_op_seq_id,
                a.line_op_seq_id,
                a.yield,
                a.cumulative_yield,
                a.reverse_cumulative_yield,
                a.labor_time_calc,
                a.machine_time_calc,
                a.total_time_calc,
                a.labor_time_user,
                a.machine_time_user,
                a.total_time_user,
                a.net_planning_percent,
                a.x_coordinate,
                a.y_coordinate,
                a.include_in_rollup,
                a.operation_yield_enabled,
                a.old_operation_sequence_id,
                1,
                p_rev_item_seq_id,
                a.original_system_reference,
                p_e_change_notice,
                NULL,
                a.eco_for_production,
                a.shutdown_type,
                -- Added by MK 04/10/2001
                a.long_description,
                a.lowest_acceptable_yield,  -- Added for MES Enhancement
                a.use_org_settings,
                a.queue_mandatory_flag,
                a.run_mandatory_flag,
                a.to_move_mandatory_flag,
                a.show_next_op_by_default,
                a.show_scrap_code,
                a.show_lot_attrib,
                a.track_multiple_res_usage_dates,
                a.check_skill --added for bug 7597474
           FROM bom_operation_sequences a,                          -- from op
                bom_departments b,                           -- from op's dept
                bom_departments c                              -- to op's dept
          WHERE a.routing_sequence_id = x_from_sequence_id
            AND NVL (a.eco_for_production, 2) = 2
            AND a.department_id = b.department_id
            AND b.department_code = c.department_code
            -- comparing departments with same name
            AND c.organization_id = to_org_id
            AND NVL (c.disable_date, l_curr_date + 1) > l_curr_date
			AND ( ( p_cpy_disable_fields = 'Y' AND a.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			     OR ( p_cpy_disable_fields = 'N' AND a.effectivity_date = rev_date )
			   )
--   AND A.IMPLEMENTATION_DATE IS NOT NULL ; /* Bug 2717982 */
            AND (a.implementation_date IS NOT NULL
                 OR (a.implementation_date IS NULL
                     AND a.change_notice = p_context_eco
                     AND ( a.acd_type = 1 OR a.acd_type = 2 )
                    )
                )
			AND NOT EXISTS -- Bug 5151332 Disabled operations should not get copied in ECO context
			(
			  SELECT 1
			    FROM bom_operation_sequences bos
			   WHERE bos.routing_sequence_id = a.routing_sequence_id
			     AND bos.old_operation_sequence_id = a.operation_sequence_id
				 AND bos.change_notice = p_context_eco
				 AND bos.acd_type = 3
				 AND bos.effectivity_date <= p_eco_eff_date
				 AND bos.implementation_date IS NULL
			 );

    IF p_log_errors = 'Y' THEN
	     -- There should not be any no data found for this case
	     SELECT
		    assembly_item_id INTO l_from_item_id
		 FROM
		    bom_operational_routings bor
		 WHERE
		    bor.routing_sequence_id = from_sequence_id;
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		 SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_RTG_DEPT_NOT_EXISTS',
			                    a.operation_seq_num, b.department_code,'DEP'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a,                          -- from op
                bom_departments b,                           -- from op's dept
                bom_departments c                              -- to op's dept
          WHERE a.routing_sequence_id = x_from_sequence_id
			AND ( ( p_cpy_disable_fields = 'Y' AND a.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			     OR ( p_cpy_disable_fields = 'N' AND a.effectivity_date = rev_date )
			   )
            AND a.department_id = b.department_id
            AND b.department_code = c.department_code (+)
            -- comparing departments with same name
            AND c.organization_id = to_org_id
            AND NVL (c.disable_date, l_curr_date + 1) > l_curr_date
            AND (a.implementation_date IS NOT NULL
                 OR (a.implementation_date IS NULL
                     AND a.change_notice = p_context_eco
                     AND ( a.acd_type = 1 OR a.acd_type = 2 )
                    )
                )
			AND NOT EXISTS -- Bug 5151332 Disabled operations should not get copied in ECO context
			(
			  SELECT 1
			    FROM bom_operation_sequences bos
			   WHERE bos.routing_sequence_id = a.routing_sequence_id
			     AND bos.old_operation_sequence_id = a.operation_sequence_id
				 AND bos.change_notice = p_context_eco
				 AND bos.acd_type = 3
				 AND bos.effectivity_date <= p_eco_eff_date
				 AND bos.implementation_date IS NULL
			 )
			MINUS -- Filter the departments for which the match is found
  		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_RTG_DEPT_NOT_EXISTS',
			         a.operation_seq_num, b.department_code,'DEP'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a,                          -- from op
                bom_departments b                           -- from op's dept
          WHERE a.routing_sequence_id = x_from_sequence_id
			AND ( ( p_cpy_disable_fields = 'Y' AND a.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			     OR ( p_cpy_disable_fields = 'N' AND a.effectivity_date = rev_date )
			   )
            AND a.department_id = b.department_id
            AND (a.implementation_date IS NOT NULL
                 OR (a.implementation_date IS NULL
                     AND a.change_notice = p_context_eco
                     AND ( a.acd_type = 1 OR a.acd_type = 2 )
                    )
                )
			AND NOT EXISTS -- Bug 5151332 Disabled operations should not get copied in ECO context
			(
			  SELECT 1
			    FROM bom_operation_sequences bos
			   WHERE bos.routing_sequence_id = a.routing_sequence_id
			     AND bos.old_operation_sequence_id = a.operation_sequence_id
				 AND bos.change_notice = p_context_eco
				 AND bos.acd_type = 3
				 AND bos.effectivity_date <= p_eco_eff_date
				 AND bos.implementation_date IS NULL
			 );
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		 SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_RTG_OPER_FOR_WIP_JOB',a.operation_seq_num),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a
          WHERE a.routing_sequence_id = x_from_sequence_id
			AND ( ( p_cpy_disable_fields = 'Y' AND a.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			     OR ( p_cpy_disable_fields = 'N' AND a.effectivity_date = rev_date )
			   )
            AND a.eco_for_production <> 2
            AND (a.implementation_date IS NOT NULL
                 OR (a.implementation_date IS NULL
                     AND a.change_notice = p_context_eco
                     AND ( a.acd_type = 1 OR a.acd_type = 2 )
                    )
                )
 			AND NOT EXISTS -- Bug 5151332 Disabled operations should not get copied in ECO context
			(
			  SELECT 1
			    FROM bom_operation_sequences bos
			   WHERE bos.routing_sequence_id = a.routing_sequence_id
			     AND bos.old_operation_sequence_id = a.operation_sequence_id
				 AND bos.change_notice = p_context_eco
				 AND bos.acd_type = 3
				 AND bos.effectivity_date <= p_eco_eff_date
				 AND bos.implementation_date IS NULL
			 );

         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		 SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_RTG_OPER_NOT_IMPL',a.operation_seq_num),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a
          WHERE a.routing_sequence_id = x_from_sequence_id
			AND ( ( p_cpy_disable_fields = 'Y' AND a.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			     OR ( p_cpy_disable_fields = 'N' AND a.effectivity_date = rev_date )
			   )
            AND (a.implementation_date IS NULL
			     AND p_context_eco IS NULL);

	END IF; /* IF p_log_errors = 'Y' */


      copy_operations := SQL%ROWCOUNT;

      IF (from_org_id = to_org_id)
      THEN
         total_opseqs := SQL%ROWCOUNT;
      END IF;

      -- Begin Bug fix 3473802
      IF (from_org_id <> to_org_id)
      THEN
         OPEN update_st_op;

         copy_ops_update := 0;

         LOOP
            FETCH update_st_op
             INTO p_st_op_id,
                  p_op_seq_id;

            EXIT WHEN update_st_op%NOTFOUND;

            BEGIN
               SELECT b.standard_operation_id,
                      b.minimum_transfer_quantity,
                      b.backflush_flag,
                      b.option_dependent_flag,
                      b.count_point_type,
                      b.operation_description
                 INTO new_st_op_id,
                      min_qty,
                      back_flag,
                      opt_flag,
                      count_type,
                      opr_desc
                 FROM bom_standard_operations_v a,              -- BUG 3936049
                      bom_standard_operations_v b               -- BUG 3936049
                WHERE a.standard_operation_id = p_st_op_id
                  AND a.operation_code = b.operation_code
                  AND a.organization_id = from_org_id
                  AND b.organization_id = to_org_id
                  AND NVL (a.line_code, '@@@') = NVL (b.line_code, '@@@')
                  -- BUG 3936049
                  AND NVL (a.operation_type, -99) = NVL (b.operation_type,
                                                         -99);  -- BUG 3936049

               UPDATE bom_operation_sequences
                  SET standard_operation_id = new_st_op_id,
                      minimum_transfer_quantity = min_qty,
                      backflush_flag = back_flag,
                      option_dependent_flag = opt_flag,
                      count_point_type = count_type,
                      operation_description = opr_desc
                WHERE routing_sequence_id = to_sequence_id
                  AND operation_sequence_id = p_op_seq_id;

               copy_ops_update := copy_ops_update + 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  UPDATE bom_operation_sequences
                     SET standard_operation_id = NULL
                   WHERE routing_sequence_id = to_sequence_id
                     AND operation_sequence_id = p_op_seq_id;
            END;
         END LOOP;
      END IF;

      -- End Bug fix 3473802

      --Start bug fix for bug 7597474
insert into bom_operation_skills
(LEVEL_ID,
ORGANIZATION_ID,
OPERATION_SEQUENCE_ID,
STANDARD_OPERATION_ID,
RESOURCE_ID,
COMPETENCE_ID,
RATING_LEVEL_ID,
QUALIFICATION_TYPE_ID,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
CREATED_BY,
CREATION_DATE)

select
SKL.LEVEL_ID,
to_org_id,
SEQ2.OPERATION_SEQUENCE_ID,
SKL.STANDARD_OPERATION_ID,
SKL.RESOURCE_ID,
SKL.COMPETENCE_ID,
SKL.RATING_LEVEL_ID,
SKL.QUALIFICATION_TYPE_ID,
sysdate,
user_id,
user_id,
user_id,
sysdate

from bom_operation_skills SKL, bom_operation_sequences SEQ1, bom_operation_sequences SEQ2
where SEQ1.routing_sequence_id = from_sequence_id
and SEQ2.routing_sequence_id = to_sequence_id
and SKL.operation_sequence_id = SEQ1.operation_sequence_id
and SEQ1.operation_seq_num = SEQ2.operation_seq_num

and SKL.operation_sequence_id in
  (select operation_sequence_id
  from bom_operation_sequences
  where routing_sequence_id = from_sequence_id
  );
--End bug fix for bug 7597474

      OPEN process_op;

      LOOP
         FETCH process_op
          INTO p_op_seq_id,
               p_op_seq_num;

         EXIT WHEN process_op%NOTFOUND;

         BEGIN
            SELECT operation_sequence_id
              INTO new_p_op_seq_id
              FROM bom_operation_sequences
             WHERE routing_sequence_id = to_sequence_id
               AND operation_type = 2
               AND NVL (eco_for_production, 2) = 2
               AND operation_seq_num = p_op_seq_num;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         UPDATE bom_operation_sequences
            SET process_op_seq_id = new_p_op_seq_id
          WHERE operation_type = 1
            AND routing_sequence_id = to_sequence_id
            AND process_op_seq_id = p_op_seq_id;
      END LOOP;

      OPEN line_op;

      LOOP
         FETCH line_op
          INTO l_op_seq_id,
               l_op_seq_num;

         EXIT WHEN line_op%NOTFOUND;

         BEGIN
            SELECT operation_sequence_id
              INTO new_l_op_seq_id
              FROM bom_operation_sequences
             WHERE routing_sequence_id = to_sequence_id
               AND operation_type = 3
               AND NVL (eco_for_production, 2) = 2
               AND operation_seq_num = l_op_seq_num;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         UPDATE bom_operation_sequences
            SET line_op_seq_id = new_l_op_seq_id
          WHERE operation_type = 1
            AND routing_sequence_id = to_sequence_id
            AND line_op_seq_id = l_op_seq_id;
      END LOOP;

      INSERT INTO bom_operation_networks
                  (from_op_seq_id,
                   to_op_seq_id,
                   transition_type,
                   planning_pct,
                   effectivity_date,
                   disable_date,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
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
				   request_id,
				   program_application_id,
				   program_id,
				   program_update_date
                  )
         SELECT bos3.operation_sequence_id,
                bos4.operation_sequence_id,
                bon.transition_type,
                bon.planning_pct,
				-- Operation Network effectivity will be effective from target's to operation,
				-- which will be greater than target's from operation
				bos4.effectivity_date,
				/*
                DECODE (p_routing_or_eco,
                        1, bon.effectivity_date,
                        p_eco_eff_date
                       ),*/
                bon.disable_date,
                bon.created_by,
                bon.creation_date,
                bon.last_updated_by,
                bon.last_update_date,
                bon.last_update_login,
                bon.attribute_category,
                bon.attribute1,
                bon.attribute2,
                bon.attribute3,
                bon.attribute4,
                bon.attribute5,
                bon.attribute6,
                bon.attribute7,
                bon.attribute8,
                bon.attribute9,
                bon.attribute10,
                bon.attribute11,
                bon.attribute12,
                bon.attribute13,
                bon.attribute14,
                bon.attribute15,
                fnd_global.conc_request_id,
                NULL,
                fnd_global.conc_program_id,
                sysdate
           FROM bom_operation_networks bon,
                bom_operation_sequences bos4,                    -- dest to op
                bom_operation_sequences bos3,                  -- dest from op
                bom_operation_sequences bos2,                     -- src to op
                bom_operation_sequences bos1                    -- src from op
          WHERE bon.from_op_seq_id = bos1.operation_sequence_id
            AND bon.to_op_seq_id = bos2.operation_sequence_id
            AND bos1.routing_sequence_id = bos2.routing_sequence_id
            AND bos1.routing_sequence_id = x_from_sequence_id
            AND bos3.routing_sequence_id = to_sequence_id
            AND bos3.operation_seq_num = bos1.operation_seq_num
--  AND greatest(bos1.effectivity_date, l_curr_date) = greatest(bos3.effectivity_date, l_curr_date) -- added for bug 2718955
            -- Just compare the last updated by which will have the from operation seq num
			-- If the operation is copied then we need to copy the network, the effectivity filter
			-- is already applied at the operation sequence level
			AND bos3.last_updated_by = bos1.operation_sequence_id
			AND bos4.last_updated_by = bos2.operation_sequence_id
            /* Commented as part of TTMO Enh R12
            AND DECODE (display_option,
                        1, bos1.effectivity_date,
                        GREATEST (bos1.effectivity_date, l_curr_date)
                       ) =
                  DECODE
                     (display_option,
                      1, bos3.effectivity_date,
                      GREATEST (bos3.effectivity_date, l_curr_date)
                     )                                -- added for bug 2788795
		    */
            AND NVL (bos3.operation_type, 1) = NVL (bos1.operation_type, 1)
            AND NVL (bos1.eco_for_production, 2) = 2
            AND NVL (bos2.eco_for_production, 2) = 2
            AND NVL (bos3.eco_for_production, 2) = 2
            AND NVL (bos4.eco_for_production, 2) = 2
            AND bos4.routing_sequence_id = to_sequence_id
            AND bos4.operation_seq_num = bos2.operation_seq_num
            -- Just compare the last updated by which will have the from operation seq num
			-- If the operation is copied then we need to copy the network, the effectivity filter
			-- is already applied at the operation sequence level
			/*
            AND DECODE (display_option,
                        1, bos2.effectivity_date,
                        GREATEST (bos2.effectivity_date, l_curr_date)
                       ) =
                  DECODE
                     (display_option,
                      1, bos4.effectivity_date,
                      GREATEST (bos4.effectivity_date, l_curr_date)
                     )                                -- added for bug 2788795
			*/
            AND NVL (bos4.operation_type, 1) = NVL (bos2.operation_type, 1)
			AND bos2.revised_item_sequence_id = p_rev_item_seq_id;

      IF p_log_errors = 'Y' THEN
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_NRTG_OPTYPE_NOT_EXISTS',bos1.operation_seq_num,mfgl.meaning),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
            FROM bom_operation_networks bon,
                bom_operation_sequences bos4,                    -- dest to op
                bom_operation_sequences bos3,                  -- dest from op
                bom_operation_sequences bos2,                     -- src to op
                bom_operation_sequences bos1,                    -- src from op
				mfg_lookups mfgl
          WHERE bon.from_op_seq_id = bos1.operation_sequence_id
            AND bon.to_op_seq_id = bos2.operation_sequence_id
            AND bos1.routing_sequence_id = bos2.routing_sequence_id
            AND bos1.routing_sequence_id = x_from_sequence_id
            AND bos3.routing_sequence_id = to_sequence_id
            AND bos3.operation_seq_num = bos1.operation_seq_num
			AND bos3.last_updated_by = bos1.operation_sequence_id
			AND bos4.last_updated_by = bos2.operation_sequence_id
            AND bos3.operation_type(+) = bos1.operation_type
            AND NVL (bos1.eco_for_production, 2) = 2
            AND NVL (bos2.eco_for_production, 2) = 2
            AND NVL (bos3.eco_for_production, 2) = 2
            AND NVL (bos4.eco_for_production, 2) = 2
            AND bos4.routing_sequence_id = to_sequence_id
            AND bos4.operation_seq_num = bos2.operation_seq_num
            AND NVL (bos4.operation_type, 1) = NVL (bos2.operation_type, 1)
			AND mfgl.lookup_type = 'BOM_OPERATION_TYPE'
			AND mfgl.lookup_code = bos1.operation_type
			AND bos2.revised_item_sequence_id = p_rev_item_seq_id
			MINUS
		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_NRTG_OPTYPE_NOT_EXISTS',bos1.operation_seq_num, mfgl.meaning),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
            FROM bom_operation_networks bon,
                bom_operation_sequences bos4,                    -- dest to op
                bom_operation_sequences bos3,                  -- dest from op
                bom_operation_sequences bos2,                     -- src to op
                bom_operation_sequences bos1,                    -- src from op
				mfg_lookups mfgl
          WHERE bon.from_op_seq_id = bos1.operation_sequence_id
            AND bon.to_op_seq_id = bos2.operation_sequence_id
            AND bos1.routing_sequence_id = bos2.routing_sequence_id
            AND bos1.routing_sequence_id = x_from_sequence_id
            AND bos3.routing_sequence_id = to_sequence_id
            AND bos3.operation_seq_num = bos1.operation_seq_num
			AND bos3.last_updated_by = bos1.operation_sequence_id
			AND bos4.last_updated_by = bos2.operation_sequence_id
            AND bos3.operation_type = bos1.operation_type
            AND NVL (bos1.eco_for_production, 2) = 2
            AND NVL (bos2.eco_for_production, 2) = 2
            AND NVL (bos3.eco_for_production, 2) = 2
            AND NVL (bos4.eco_for_production, 2) = 2
            AND bos4.routing_sequence_id = to_sequence_id
            AND bos4.operation_seq_num = bos2.operation_seq_num
            AND NVL (bos4.operation_type, 1) = NVL (bos2.operation_type, 1)
			AND mfgl.lookup_type = 'BOM_OPERATION_TYPE'
			AND mfgl.lookup_code = bos1.operation_type
			AND bos2.revised_item_sequence_id = p_rev_item_seq_id;
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_NRTG_OPTYPE_NOT_EXISTS',bos2.operation_seq_num,mfgl.meaning),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
            FROM bom_operation_networks bon,
                bom_operation_sequences bos4,                    -- dest to op
                bom_operation_sequences bos3,                  -- dest from op
                bom_operation_sequences bos2,                     -- src to op
                bom_operation_sequences bos1,                    -- src from op
				mfg_lookups mfgl
          WHERE bon.from_op_seq_id = bos1.operation_sequence_id
            AND bon.to_op_seq_id = bos2.operation_sequence_id
            AND bos1.routing_sequence_id = bos2.routing_sequence_id
            AND bos1.routing_sequence_id = x_from_sequence_id
            AND bos3.routing_sequence_id = to_sequence_id
            AND bos3.operation_seq_num = bos1.operation_seq_num
			AND bos3.last_updated_by = bos1.operation_sequence_id
			AND bos4.last_updated_by = bos2.operation_sequence_id
            AND NVL (bos3.operation_type, 1) = NVL (bos1.operation_type, 1)
            AND NVL (bos1.eco_for_production, 2) = 2
            AND NVL (bos2.eco_for_production, 2) = 2
            AND NVL (bos3.eco_for_production, 2) = 2
            AND NVL (bos4.eco_for_production, 2) = 2
            AND bos4.routing_sequence_id = to_sequence_id
            AND bos4.operation_seq_num = bos2.operation_seq_num
            AND bos4.operation_type(+) = bos2.operation_type
			AND mfgl.lookup_type = 'BOM_OPERATION_TYPE'
			AND mfgl.lookup_code = bos2.operation_type
			AND bos2.revised_item_sequence_id = p_rev_item_seq_id
			MINUS
		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_NRTG_OPTYPE_NOT_EXISTS',bos2.operation_seq_num,mfgl.meaning),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
            FROM bom_operation_networks bon,
                bom_operation_sequences bos4,                    -- dest to op
                bom_operation_sequences bos3,                  -- dest from op
                bom_operation_sequences bos2,                     -- src to op
                bom_operation_sequences bos1,                    -- src from op
				mfg_lookups mfgl
          WHERE bon.from_op_seq_id = bos1.operation_sequence_id
            AND bon.to_op_seq_id = bos2.operation_sequence_id
            AND bos1.routing_sequence_id = bos2.routing_sequence_id
            AND bos1.routing_sequence_id = x_from_sequence_id
            AND bos3.routing_sequence_id = to_sequence_id
            AND bos3.operation_seq_num = bos1.operation_seq_num
			AND bos3.last_updated_by = bos1.operation_sequence_id
			AND bos4.last_updated_by = bos2.operation_sequence_id
            AND NVL (bos3.operation_type, 1) = NVL (bos1.operation_type, 1)
            AND NVL (bos1.eco_for_production, 2) = 2
            AND NVL (bos2.eco_for_production, 2) = 2
            AND NVL (bos3.eco_for_production, 2) = 2
            AND NVL (bos4.eco_for_production, 2) = 2
            AND bos4.routing_sequence_id = to_sequence_id
            AND bos4.operation_seq_num = bos2.operation_seq_num
            AND bos4.operation_type = bos2.operation_type
			AND mfgl.lookup_type = 'BOM_OPERATION_TYPE'
			AND mfgl.lookup_code = bos2.operation_type
			AND bos2.revised_item_sequence_id = p_rev_item_seq_id;


	  END IF; /* IF p_log_errors = 'Y' */


      --INSERT OPERATION RESOURCES
      --NULL OUT RESOURCE_OFFSET_PERCENT
      --SET ASSIGNED UNITS TO 1 IF RESOURCES IN DEPT IS 24 HRS  -- removed restriction as per bug 2661684
      --UPDATE RESOURCE_ID TO THAT OF COPY_TO_ORG
      --LEAVE OUT RESOURCES THAT DO NOT EXIST IN COPY_TO_ORG DEPT.
      sql_stmt_num := 20;

      INSERT INTO bom_operation_resources
                  (operation_sequence_id,
                   resource_seq_num,
                   resource_id,
                   activity_id,
                   standard_rate_flag,
                   assigned_units,
                   usage_rate_or_amount,
                   usage_rate_or_amount_inverse,
                   basis_type,
                   schedule_flag,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   resource_offset_percent,
                   autocharge_type,
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
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date,
                   schedule_seq_num,
                   substitute_group_num,
                   principle_flag,
                   setup_id,
                   change_notice,
                   acd_type,
                   original_system_reference
                  )
         SELECT a.operation_sequence_id,
                b.resource_seq_num,
                d.resource_id,
                b.activity_id,
                b.standard_rate_flag,
--    DECODE(E.AVAILABLE_24_HOURS_FLAG, 1, 1, B.ASSIGNED_UNITS), -- changed for bug 2661684
                b.assigned_units,
                b.usage_rate_or_amount,
                b.usage_rate_or_amount_inverse,
                b.basis_type,
                b.schedule_flag,
                SYSDATE,
                b.operation_sequence_id,         -- Instead of last_updated_by
                SYSDATE,
                NVL (b.schedule_seq_num, user_id),    -- Instead of created by
                user_id,
                NULL,
                b.autocharge_type,
                b.attribute_category,
                b.attribute1,
                b.attribute2,
                b.attribute3,
                b.attribute4,
                b.attribute5,
                b.attribute6,
                b.attribute7,
                b.attribute8,
                b.attribute9,
                b.attribute10,
                b.attribute11,
                b.attribute12,
                b.attribute13,
                b.attribute14,
                b.attribute15,
                fnd_global.conc_request_id,
                NULL,
                fnd_global.conc_program_id,
                sysdate,
                b.schedule_seq_num,
                b.substitute_group_num,
                b.principle_flag,
                b.setup_id,
                DECODE (p_routing_or_eco, 1, b.change_notice, p_e_change_notice),
                DECODE (p_routing_or_eco, 1, b.acd_type, 1),
                -- Add is the action for ECO
                b.original_system_reference
           FROM bom_operation_sequences a,
                bom_operation_resources b,
                bom_resources c,
                bom_resources d
--         ,BOM_DEPARTMENT_RESOURCES E
         WHERE  a.routing_sequence_id = to_sequence_id
            AND a.last_updated_by = b.operation_sequence_id
            AND b.resource_id = c.resource_id
            AND c.resource_code = d.resource_code
            AND d.organization_id = to_org_id
--    AND   D.RESOURCE_ID = E.RESOURCE_ID
--    AND   E.DEPARTMENT_ID = A.DEPARTMENT_ID
            AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE
			AND a.revised_item_sequence_id = p_rev_item_seq_id;

      IF p_log_errors = 'Y' THEN
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_OPER_RES_NOT_EXISTS',fbor.operation_seq_num, c.resource_code,'RES'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a,
                bom_operation_resources b,
				bom_operation_sequences fbor,
                bom_resources c,
                bom_resources d
         WHERE  a.routing_sequence_id = to_sequence_id
            AND a.last_updated_by = b.operation_sequence_id
            AND b.resource_id = c.resource_id
            AND c.resource_code = d.resource_code(+)
            AND d.organization_id = to_org_id
            AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE
			AND fbor.operation_sequence_id = b.operation_sequence_id
			AND a.revised_item_sequence_id = p_rev_item_seq_id
		MINUS
	    SELECT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_OPER_RES_NOT_EXISTS',fbor.operation_seq_num, c.resource_code,'RES'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
           FROM bom_operation_sequences a,
                bom_operation_resources b,
				bom_operation_sequences fbor,
                bom_resources c,
                bom_resources d
         WHERE  a.routing_sequence_id = to_sequence_id
            AND a.last_updated_by = b.operation_sequence_id
            AND b.resource_id = c.resource_id
            AND c.resource_code = d.resource_code
            AND d.organization_id = to_org_id
            AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE
			AND fbor.operation_sequence_id = b.operation_sequence_id
			AND a.revised_item_sequence_id = p_rev_item_seq_id;
	  END IF; /* IF p_log_errors = 'Y' */


      copy_resources := SQL%ROWCOUNT;

      IF (from_org_id = to_org_id)
      THEN
         total_resources := SQL%ROWCOUNT;
      END IF;

      -- UPDATE OPERATION RESOURCES TO
      -- IF ACTIVITY IS ORG DEPENDENT, NULL IT OUT
      -- IF NO CONVERSION TO HOUR UOM CLASS, SET SCHEDUEL FLAG TO NO
      -- If there exist a similar setup in the other org, copy the correct setup_id
      -- else null out the setup_id field -- bug 2751946
      -- ONLY FOR INTER ORG COPY
      IF (from_org_id <> to_org_id)
      THEN
         sql_stmt_num := 30;

         UPDATE bom_operation_resources a
            SET activity_id =
                   (SELECT DECODE (organization_id, NULL, activity_id, NULL)
                      FROM cst_activities
                     WHERE activity_id = a.activity_id),
                schedule_flag =
                   (SELECT DECODE (c.unit_of_measure,
                                   NULL, 2,
                                   hour_uom_code_v, a.schedule_flag,
                                   DECODE (b.uom_class,
                                           hour_uom_class_v, a.schedule_flag,
                                           2
                                          )
                                  )
                      FROM mtl_units_of_measure b,
                           bom_resources c
                     WHERE a.resource_id = c.resource_id
                       AND c.unit_of_measure = b.unit_of_measure(+)),
                setup_id =
                   (SELECT brs.setup_id
                      FROM bom_resource_setups brs,
                           bom_setup_types bst        -- added for bug 2751946
                     WHERE brs.resource_id = a.resource_id
                       AND brs.setup_id = bst.setup_id
                       AND bst.setup_code = (SELECT setup_code
                                               FROM bom_setup_types
                                              WHERE setup_id = a.setup_id))
          WHERE a.operation_sequence_id IN (
                                    SELECT operation_sequence_id
                                      FROM bom_operation_sequences
                                     WHERE routing_sequence_id =
                                                                to_sequence_id);
      END IF;

-- Bug Fix 2991810
      sql_stmt_num := 25;

      INSERT INTO bom_sub_operation_resources
                  (operation_sequence_id,
                   substitute_group_num,
                   resource_id,
                   schedule_seq_num,
                   replacement_group_num,
                   activity_id,
                   standard_rate_flag,
                   assigned_units,
                   usage_rate_or_amount,
                   usage_rate_or_amount_inverse,
                   basis_type,
                   schedule_flag,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   resource_offset_percent,
                   autocharge_type,
                   attribute_category,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date,
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
                   principle_flag,
                   setup_id,
                   change_notice,
                   acd_type,
                   original_system_reference
                  )
         SELECT DISTINCT a.operation_sequence_id,
                         b.substitute_group_num,
                         d.resource_id,
                         b.schedule_seq_num,
                         b.replacement_group_num,
                         b.activity_id,
                         b.standard_rate_flag,
                         b.assigned_units,
                         b.usage_rate_or_amount,
                         b.usage_rate_or_amount_inverse,
                         b.basis_type,
                         b.schedule_flag,
                         SYSDATE,
                         user_id,
                         SYSDATE,
                         user_id,
                         NULL,
                         b.resource_offset_percent,
                         b.autocharge_type,
                         b.attribute_category,
                         fnd_global.conc_request_id,
                         NULL,
                         fnd_global.conc_program_id,
                         sysdate,
                         b.attribute1,
                         b.attribute2,
                         b.attribute3,
                         b.attribute4,
                         b.attribute5,
                         b.attribute6,
                         b.attribute7,
                         b.attribute8,
                         b.attribute9,
                         b.attribute10,
                         b.attribute11,
                         b.attribute12,
                         b.attribute13,
                         b.attribute14,
                         b.attribute15,
                         b.principle_flag,
                         b.setup_id,
                         DECODE (p_routing_or_eco,
                                 1, b.change_notice,
                                 p_e_change_notice
                                ),
                         DECODE (p_routing_or_eco, 1, b.acd_type, 1),
                         -- Add is the action for ECO
                         b.original_system_reference
                    FROM bom_operation_resources a,
                         bom_sub_operation_resources b,
                         bom_resources c,
                         bom_resources d,
						 bom_operation_sequences bos
                   WHERE a.last_updated_by = b.operation_sequence_id
				     AND bos.operation_sequence_id = b.operation_sequence_id
					 AND bos.revised_item_sequence_id = p_rev_item_seq_id
                     AND a.created_by = b.schedule_seq_num
                     AND b.resource_id = c.resource_id
                     AND c.resource_code = d.resource_code
                     AND d.organization_id = to_org_id
                     AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE;

	  IF p_log_errors = 'Y' THEN
         INSERT INTO mtl_interface_errors
                     (unique_id,
                      organization_id,
                      transaction_id,
                      table_name,
                      column_name,
                      error_message,
                      bo_identifier,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
					  message_type,
					  request_id,
					  program_application_id,
					  program_id,
					  program_update_date
                     )
		    SELECT DISTINCT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_SUB_OPER_RES_NOT_EXISTS',fbor.operation_seq_num, c.resource_code, 'SUB'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
            FROM bom_operation_resources a,
			     bom_operation_sequences fbor,
                         bom_sub_operation_resources b,
                         bom_resources c,
                         bom_resources d
                   WHERE a.last_updated_by = b.operation_sequence_id
					 AND fbor.revised_item_sequence_id = p_rev_item_seq_id
				     AND b.operation_sequence_id = fbor.operation_sequence_id
                     AND a.created_by = b.schedule_seq_num
                     AND b.resource_id = c.resource_id
                     AND c.resource_code = d.resource_code(+)
                     AND d.organization_id = to_org_id
                     AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE
			MINUS
		    SELECT DISTINCT
		       l_from_item_id,
			   to_org_id,
			   p_copy_request_id,
			   NULL,
			   NULL,
			   bom_copy_routing.get_message('BOM_CE_SUB_OPER_RES_NOT_EXISTS',fbor.operation_seq_num, c.resource_code, 'SUB'),
			   'BOM_COPY',
			   sysdate,
			   user_id,
			   sysdate,
			   user_id,
			   'E',
               fnd_global.conc_request_id,
               NULL,
               fnd_global.conc_program_id,
               sysdate
            FROM bom_operation_resources a,
			     bom_operation_sequences fbor,
                         bom_sub_operation_resources b,
                         bom_resources c,
                         bom_resources d
                   WHERE a.last_updated_by = b.operation_sequence_id
                     AND a.created_by = b.schedule_seq_num
					 AND fbor.revised_item_sequence_id = p_rev_item_seq_id
				     AND b.operation_sequence_id = fbor.operation_sequence_id
                     AND b.resource_id = c.resource_id
                     AND c.resource_code = d.resource_code
                     AND d.organization_id = to_org_id
                     AND NVL (d.disable_date, SYSDATE + 1) > SYSDATE;
		END IF; /* IF p_log_errors = 'Y' */
      copy_sub_resources := SQL%ROWCOUNT;

      IF (from_org_id = to_org_id)
      THEN
         total_sub_resources := SQL%ROWCOUNT;
      END IF;

      IF (from_org_id <> to_org_id)
      THEN
         sql_stmt_num := 35;

         UPDATE bom_sub_operation_resources a
            SET activity_id =
                   (SELECT DECODE (organization_id, NULL, activity_id, NULL)
                      FROM cst_activities
                     WHERE activity_id = a.activity_id),
                schedule_flag =
                   (SELECT DECODE (c.unit_of_measure,
                                   NULL, 2,
                                   hour_uom_code_v, a.schedule_flag,
                                   DECODE (b.uom_class,
                                           hour_uom_class_v, a.schedule_flag,
                                           2
                                          )
                                  )
                      FROM mtl_units_of_measure b,
                           bom_resources c
                     WHERE a.resource_id = c.resource_id
                       AND c.unit_of_measure = b.unit_of_measure(+)),
                setup_id =
                   (SELECT brs.setup_id
                      FROM bom_resource_setups brs,
                           bom_setup_types bst
                     WHERE brs.resource_id = a.resource_id
                       AND brs.setup_id = bst.setup_id
                       AND bst.setup_code = (SELECT setup_code
                                               FROM bom_setup_types
                                              WHERE setup_id = a.setup_id))
          WHERE a.operation_sequence_id IN (
                                    SELECT operation_sequence_id
                                      FROM bom_operation_sequences
                                     WHERE routing_sequence_id =
                                                                to_sequence_id);
      END IF;

-- Bug Fix 2991810

      -- UPDATE LAST_UPDATED_BY COLUMN USED TO STORE COPY_FROM OP_SEQ_IDS
      sql_stmt_num := 55;

      UPDATE bom_operation_sequences
         SET last_updated_by = user_id
       WHERE routing_sequence_id = to_sequence_id;

-- Bug Fix 2991810
      sql_stmt_num := 65;

      UPDATE bom_operation_resources
         SET last_updated_by = user_id,
             created_by = user_id
       WHERE operation_sequence_id IN (
                                    SELECT operation_sequence_id
                                      FROM bom_operation_sequences
                                     WHERE routing_sequence_id =
                                                                to_sequence_id);

      sql_stmt_num := 39;

      SELECT COUNT (*)
        INTO copy_instrs
        FROM fnd_attached_documents b,
             bom_operation_sequences a
       WHERE a.routing_sequence_id = to_sequence_id
         AND a.operation_sequence_id = b.pk1_value
         AND b.entity_name = 'BOM_OPERATION_SEQUENCES';

      --begin bug fix 3473851
      sql_stmt_num := 40;

      SELECT COUNT (*)
        INTO copy_hdr_instrs
        FROM fnd_attached_documents b,
             bom_operational_routings a
       WHERE a.routing_sequence_id = to_sequence_id
         AND a.routing_sequence_id = b.pk1_value
         AND b.entity_name = 'BOM_OPERATIONAL_ROUTINGS';

      --end bug fix 3473851
      IF (from_org_id = to_org_id)
      THEN
         total_instructions := copy_instrs;
         total_hdr_instructions := copy_hdr_instrs;             --bug 3473851
      END IF;

      fnd_message.set_name ('BOM', 'BOM_ROUTING_COPY_DONE');
      fnd_message.set_token ('ENTITY1', copy_operations);
      fnd_message.set_token ('ENTITY2', total_opseqs);
      fnd_message.set_token ('ENTITY3', copy_resources);
      fnd_message.set_token ('ENTITY4', total_resources);
      fnd_message.set_token ('ENTITY7', copy_sub_resources);
      -- Bug2991810 the message also needs to be modified
      fnd_message.set_token ('ENTITY8', total_sub_resources);    -- Bug2991810
      fnd_message.set_token ('ENTITY5', copy_instrs);
      fnd_message.set_token ('ENTITY6', total_instructions);
      fnd_message.set_token ('ENTITY9', copy_hdr_instrs);        --bug 3473851
      fnd_message.set_token ('ENTITY10', total_hdr_instructions);
   --bug 3473851
   EXCEPTION
      WHEN OTHERS
      THEN
         err_msg :=
                 'COPY_ROUTING (' || TO_CHAR (sql_stmt_num) || ') '
                 || SQLERRM;
         fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
         fnd_message.set_token ('ENTITY', err_msg);
         ROLLBACK TO begin_routing_copy;
         app_exception.raise_exception;
   END copy_routing_for_revised_item;

   PROCEDURE copy_attachments(p_from_sequence_id IN NUMBER,
	                           p_to_sequence_id   IN NUMBER,
	 						   p_user_id          IN NUMBER)
   IS
      CURSOR source_rtg
      IS
         SELECT operation_sequence_id,
                last_updated_by
           FROM bom_operation_sequences
          WHERE routing_sequence_id = p_to_sequence_id
            AND NVL (eco_for_production, 2) = 2;
   BEGIN

      BEGIN
         FOR x_op IN source_rtg
         LOOP
            fnd_attached_documents2_pkg.copy_attachments
                            (x_from_entity_name            => 'BOM_OPERATION_SEQUENCES',
                             x_from_pk1_value              => x_op.last_updated_by,
                             x_from_pk2_value              => '',
                             x_from_pk3_value              => '',
                             x_from_pk4_value              => '',
                             x_from_pk5_value              => '',
                             x_to_entity_name              => 'BOM_OPERATION_SEQUENCES',
                             x_to_pk1_value                => x_op.operation_sequence_id,
                             x_to_pk2_value                => '',
                             x_to_pk3_value                => '',
                             x_to_pk4_value                => '',
                             x_to_pk5_value                => '',
                             x_created_by                  => p_user_id,
                             x_last_update_login           => '',
                             x_program_application_id      => '',
                             x_program_id                  => fnd_global.conc_program_id,
                             x_request_id                  => fnd_global.conc_request_id
                            );
         END LOOP;

      END;

      --begin bug fix 3473851
      fnd_attached_documents2_pkg.copy_attachments
                            (x_from_entity_name            => 'BOM_OPERATIONAL_ROUTINGS',
                             x_from_pk1_value              => p_from_sequence_id,
                             x_from_pk2_value              => '',
                             x_from_pk3_value              => '',
                             x_from_pk4_value              => '',
                             x_from_pk5_value              => '',
                             x_to_entity_name              => 'BOM_OPERATIONAL_ROUTINGS',
                             x_to_pk1_value                => p_to_sequence_id,
                             x_to_pk2_value                => '',
                             x_to_pk3_value                => '',
                             x_to_pk4_value                => '',
                             x_to_pk5_value                => '',
                             x_created_by                  => p_user_id,
                             x_last_update_login           => '',
                             x_program_application_id      => '',
                             x_program_id                  => fnd_global.conc_program_id,
                             x_request_id                  => fnd_global.conc_request_id
                            );
      --end bug fix 3473851
   END copy_attachments;

   PROCEDURE update_last_updated_by (
      p_user_id IN NUMBER
     ,p_to_sequence_id IN NUMBER )
   IS
   BEGIN

      UPDATE bom_operation_sequences bos
         SET last_updated_by = p_user_id
       WHERE bos.routing_sequence_id = p_to_sequence_id;

   END;

END bom_copy_routing;

/
