--------------------------------------------------------
--  DDL for Package Body BOM_COPY_BILL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_COPY_BILL" AS
-- $Header: BOMCPYBB.pls 120.42.12010000.9 2011/08/02 03:57:50 gliang ship $
-- +==============================================================================+
-- |   Copyright (c) 1995 Oracle Corporation, California, USA                     |
-- |                          All rights reserved.                                |
-- +==============================================================================+
-- |                                                                              |
-- | File Name    : BOMCPYBB.pls                                                  |
-- | Description  : Bill copy package   [BODY]                                    |
-- | Created By   : Manu Chadha                                                   |
-- | Updatded By  : Refai Farook (13-SEP-01) Copy the additional operations       |
-- |                also along with other entities (one to many changes)          |
-- |                                                                              |
-- |    from_org_id             Copy from org id                                  |
-- |    to_org_id               Copy to org id                                    |
-- |    from_sequence_id        Copy from bill sequence id                        |
-- |    to_sequence_id          Copy to bill sequence id                          |
-- |    display_option          copy option                                       |
-- |                            1 - all (not supported from form)                 |
-- |                            2 - current                                       |
-- |                            3 - current + future                              |
-- |    user_id                 user id                                           |
-- |    to_item_id              Copy to item id                                   |
-- |    direction               direction of copy                                 |
-- |                            1 - BOM to BOM                                    |
-- |                            2 - BOM to ENG                                    |
-- |                            3 - ENG to ENG                                    |
-- |                            4 - ENG to BOM                                    |
-- |    to_alternate            Copy to alternate designator                      |
-- |    rev_date                Revision date to copy                             |
-- |                                                                              |
-- |    01/09/2003              kIRAN kONADA                                      |
-- |                            BUGFIX 2740820                                    |
-- |                            NEW COLUMNS ADDED IN BOM_INVENTORY_COMPONENTS     |
-- |                            FOR CTO NEED TO COPIED DURING COPY_BILL PROCESS   |
-- |    01/10/2003              Kiran Konada                                      |
-- |                            bugfix 2740820                                    |
-- |                            cpoying another attribute plan_level              |
-- |                                                                              |
-- | 15-SEP-2003  Ezhilarasan   Added overloaded copy_bill                        |
-- |                            procedure for specific components,                |
-- |                            reference designators, substitute components      |
-- |                            copy etc.,                                        |
-- | 11-MAY-2004  Ezhilarasan   R12 ENH Transfer To Multiple Orgs (TTM)           |
-- |                                                                              |
-- +==============================================================================+
   PROCEDURE bill_get_msg_info (
      total_inventory_components    OUT NOCOPY      NUMBER,
      total_assembly_comments       OUT NOCOPY      NUMBER,
      total_reference_designators   OUT NOCOPY      NUMBER,
      total_substitute_components   OUT NOCOPY      NUMBER,
      from_bill_seq_id              IN              NUMBER,
      revision_date                 IN              DATE,
      display_option                IN              NUMBER,
      unit_number                   IN              VARCHAR2 DEFAULT NULL,
      from_org_id                   IN              NUMBER,
      from_item_id                  IN              NUMBER,
      unit_assembly                 IN              VARCHAR2
   )
   IS
      sql_stmt_num      NUMBER;
      err_msg           VARCHAR2 (2000);
      x_unit_assembly   VARCHAR2 (2)    := unit_assembly;
   BEGIN
      sql_stmt_num := 1;

      SELECT COUNT (*)
        INTO total_inventory_components
        FROM bom_inventory_components
       WHERE bill_sequence_id = from_bill_seq_id
         AND NVL (eco_for_production, 2) = 2
         AND ((x_unit_assembly = 'N'
               AND ((display_option = 1)                                -- ALL
                    OR (display_option = 2
                        AND (effectivity_date <= revision_date
                             AND (disable_date > revision_date
                                  OR disable_date IS NULL
                                 )
                            )
                       )
                    OR                                              -- CURRENT
                      (display_option = 3
                       AND (disable_date > revision_date
                            OR disable_date IS NULL
                           )
                      )
                   )                                       -- CURRENT + FUTURE
              )
              OR (x_unit_assembly = 'Y'
                  AND ((display_option = 1)                             -- ALL
                       OR (display_option = 2
                           AND disable_date IS NULL
                           AND (from_end_item_unit_number <= unit_number
                                AND (to_end_item_unit_number >= unit_number
                                     OR to_end_item_unit_number IS NULL
                                    )
                               )
                          )
                       OR                                           -- CURRENT
                         (display_option = 3
                          AND disable_date IS NULL
                          AND (to_end_item_unit_number >= unit_number
                               OR to_end_item_unit_number IS NULL
                              )
                         )
                      )                                    -- CURRENT + FUTURE
                 )
             );

      sql_stmt_num := 2;

      SELECT COUNT (*)
        INTO total_assembly_comments
        FROM fnd_attached_documents
       WHERE entity_name = 'BOM_BILL_OF_MATERIALS'
         AND pk1_value = to_char(from_bill_seq_id);

      sql_stmt_num := 3;

      SELECT COUNT (*)
        INTO total_reference_designators
        FROM bom_reference_designators brd,
             bom_inventory_components bic
       WHERE bic.bill_sequence_id = from_bill_seq_id
         AND NVL (bic.eco_for_production, 2) = 2
         AND bic.component_sequence_id = brd.component_sequence_id
         AND ((x_unit_assembly = 'N'
               AND ((display_option = 1)                                -- ALL
                    OR (display_option = 2
                        AND (bic.effectivity_date <= revision_date
                             AND (bic.disable_date > revision_date
                                  OR bic.disable_date IS NULL
                                 )
                            )
                       )
                    OR                                              -- CURRENT
                      (display_option = 3
                       AND (bic.disable_date > revision_date
                            OR bic.disable_date IS NULL
                           )
                      )                                    -- CURRENT + FUTURE
                   )
              )
              OR (x_unit_assembly = 'Y'
                  AND ((display_option = 1)                             -- ALL
                       OR (display_option = 2
                           AND bic.disable_date IS NULL
                           AND (bic.from_end_item_unit_number <= unit_number
                                AND (bic.to_end_item_unit_number >=
                                                                   unit_number
                                     OR bic.to_end_item_unit_number IS NULL
                                    )
                               )
                          )
                       OR                                           -- CURRENT
                         (display_option = 3
                          AND bic.disable_date IS NULL
                          AND (bic.to_end_item_unit_number >= unit_number
                               OR bic.to_end_item_unit_number IS NULL
                              )
                         )
                      )                                    -- CURRENT + FUTURE
                 )
             );

      sql_stmt_num := 4;

      SELECT COUNT (*)
        INTO total_substitute_components
        FROM bom_substitute_components bsc,
             bom_inventory_components bic
       WHERE bic.bill_sequence_id = from_bill_seq_id
         AND NVL (bic.eco_for_production, 2) = 2
         AND bic.component_sequence_id = bsc.component_sequence_id
         AND ((x_unit_assembly = 'N'
               AND ((display_option = 1)                                -- ALL
                    OR (display_option = 2
                        AND (bic.effectivity_date <= revision_date
                             AND (bic.disable_date > revision_date
                                  OR bic.disable_date IS NULL
                                 )
                            )
                       )
                    OR                                              -- CURRENT
                      (display_option = 3
                       AND (bic.disable_date > revision_date
                            OR bic.disable_date IS NULL
                           )
                      )
                   )                                       -- CURRENT + FUTURE
              )
              OR (x_unit_assembly = 'Y'
                  AND ((display_option = 1)                             -- ALL
                       OR (display_option = 2
                           AND bic.disable_date IS NULL
                           AND (bic.from_end_item_unit_number <= unit_number
                                AND (bic.to_end_item_unit_number >=
                                                                   unit_number
                                     OR bic.to_end_item_unit_number IS NULL
                                    )
                               )
                          )
                       OR                                           -- CURRENT
                         (display_option = 3
                          AND bic.disable_date IS NULL
                          AND (bic.to_end_item_unit_number >= unit_number
                               OR bic.to_end_item_unit_number IS NULL
                              )
                         )
                      )                                    -- CURRENT + FUTURE
                 )
             );
   EXCEPTION
      WHEN OTHERS
      THEN
         err_msg := 'BILL_GET_MSG_INFO (' || sql_stmt_num || ') ' || SQLERRM;
         fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
         fnd_message.set_token ('ENTITY', err_msg);
         ROLLBACK TO begin_bill_copy;
         app_exception.raise_exception;
   END bill_get_msg_info;

   PROCEDURE bill_get_msg_info_compops (
      total_component_operations   OUT NOCOPY      NUMBER,
      from_bill_seq_id             IN              NUMBER,
      revision_date                IN              DATE,
      display_option               IN              NUMBER,
      unit_number                  IN              VARCHAR2 DEFAULT NULL,
      from_org_id                  IN              NUMBER,
      from_item_id                 IN              NUMBER,
      unit_assembly                IN              VARCHAR2
   )
   IS
      sql_stmt_num      NUMBER;
      err_msg           VARCHAR2 (2000);
      x_unit_assembly   VARCHAR2 (2)    := unit_assembly;
   BEGIN
      sql_stmt_num := 1;

      SELECT COUNT (*)
        INTO total_component_operations
        FROM bom_inventory_components bic,
             bom_component_operations bco
       WHERE bic.bill_sequence_id = from_bill_seq_id
         AND NVL (bic.eco_for_production, 2) = 2
         AND bic.component_sequence_id = bco.component_sequence_id
         AND ((x_unit_assembly = 'N'
               AND ((display_option = 1)                                -- ALL
                    OR (display_option = 2
                        AND (bic.effectivity_date <= revision_date
                             AND (bic.disable_date > revision_date
                                  OR bic.disable_date IS NULL
                                 )
                            )
                       )
                    OR                                              -- CURRENT
                      (display_option = 3
                       AND (bic.disable_date > revision_date
                            OR bic.disable_date IS NULL
                           )
                      )
                   )                                       -- CURRENT + FUTURE
              )
              OR (x_unit_assembly = 'Y'
                  AND ((display_option = 1)                             -- ALL
                       OR (display_option = 2
                           AND bic.disable_date IS NULL
                           AND (bic.from_end_item_unit_number <= unit_number
                                AND (bic.to_end_item_unit_number >=
                                                                   unit_number
                                     OR bic.to_end_item_unit_number IS NULL
                                    )
                               )
                          )
                       OR                                           -- CURRENT
                         (display_option = 3
                          AND bic.disable_date IS NULL
                          AND (bic.to_end_item_unit_number >= unit_number
                               OR bic.to_end_item_unit_number IS NULL
                              )
                         )
                      )                                    -- CURRENT + FUTURE
                 )
             );
   EXCEPTION
      WHEN OTHERS
      THEN
         err_msg :=
             'BILL_GET_MSG_INFO_COMPOPS (' || sql_stmt_num || ') ' || SQLERRM;
         fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
         fnd_message.set_token ('ENTITY', err_msg);
         ROLLBACK TO begin_bill_copy;
         app_exception.raise_exception;
   END bill_get_msg_info_compops;

   PROCEDURE copy_bill (
      to_sequence_id     IN   NUMBER,
      from_sequence_id   IN   NUMBER,
      from_org_id        IN   NUMBER,
      to_org_id          IN   NUMBER,
      display_option     IN   NUMBER DEFAULT 2,
      user_id            IN   NUMBER DEFAULT -1,
      to_item_id         IN   NUMBER,
      direction          IN   NUMBER DEFAULT 1,
      to_alternate       IN   VARCHAR2,
      rev_date           IN   DATE,
      e_change_notice    IN   VARCHAR2,
      rev_item_seq_id    IN   NUMBER,
      bill_or_eco        IN   NUMBER,
      eco_eff_date       IN   DATE,
      eco_unit_number    IN   VARCHAR2 DEFAULT NULL,
      unit_number        IN   VARCHAR2 DEFAULT NULL,
      from_item_id       IN   NUMBER
   )
   IS
   BEGIN
      /*
       * Call the over loaded procedure with the default values for parameters
       * in the over loaded procedure.
       */
      copy_bill (to_sequence_id                  => to_sequence_id,
                 from_sequence_id                => from_sequence_id,
                 from_org_id                     => from_org_id,
                 to_org_id                       => to_org_id,
                 display_option                  => display_option,
                 user_id                         => user_id,
                 to_item_id                      => to_item_id,
                 direction                       => direction,
                 to_alternate                    => to_alternate,
                 rev_date                        => rev_date,
                 e_change_notice                 => e_change_notice,
                 rev_item_seq_id                 => rev_item_seq_id,
                 bill_or_eco                     => bill_or_eco,
                 eco_eff_date                    => eco_eff_date,
                 eco_unit_number                 => eco_unit_number,
                 unit_number                     => unit_number,
                 from_item_id                    => from_item_id,
                 specific_copy_flag              => 'N',
                 copy_attach_flag                => 'Y',
                 p_copy_request_id               => NULL,
                 eco_end_item_rev_id             => NULL,
                 context_eco                     => NULL,
                 p_end_item_rev_id               => NULL,
                 trgt_comps_eff_date             => NULL,
                 trgt_comps_unit_number          => NULL,
                 trgt_comps_end_item_rev_id      => NULL,
                 p_parent_sort_order             => NULL,
                 p_cpy_disable_fields            => 'N'
                );
   END copy_bill;

   FUNCTION get_current_item_rev (
      p_item_id    IN   NUMBER,
      p_org_id     IN   NUMBER,
      p_rev_date   IN   DATE
   )
      RETURN VARCHAR2
   IS
      l_current_rev        VARCHAR2 (10);

      CURSOR item_rev_cursor (
         p_item_id    IN   NUMBER,
         p_org_id     IN   NUMBER,
         p_rev_date   IN   DATE
      )
      IS
         SELECT REVISION
         FROM (
           SELECT revision
             FROM mtl_item_revisions_b mir
            WHERE mir.inventory_item_id = p_item_id
              AND mir.organization_id = p_org_id
              AND mir.effectivity_date <= p_rev_date
         ORDER BY mir.effectivity_date DESC)
         WHERE ROWNUM < 2;

      no_item_rev_exists   EXCEPTION;
   BEGIN
      OPEN item_rev_cursor (p_item_id, p_org_id, p_rev_date);

      LOOP
         FETCH item_rev_cursor
          INTO l_current_rev;

         EXIT WHEN item_rev_cursor%NOTFOUND;
      END LOOP;

      IF l_current_rev IS NULL
         OR '' = l_current_rev
      THEN
         CLOSE item_rev_cursor;

         RAISE no_item_rev_exists;
      END IF;

      IF item_rev_cursor%ISOPEN THEN
	    CLOSE item_rev_cursor;
	  END IF;

      RETURN l_current_rev;
   END get_current_item_rev;

   /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ** Function: revision_exists
   ** Scope   : Local
   ** Purpose : This function was added to get around 8i compatibility issues
   **           This function replaces the CASE statement with a decode and a call
   **       to this function
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION revision_exists (
      p_from_item_id   IN   NUMBER,
      p_from_org_id    IN   NUMBER,
      p_revision_id    IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      l_return   VARCHAR2 (1);
   BEGIN
      l_return := 'T';

      SELECT 'T'
        INTO l_return
        FROM DUAL
       WHERE EXISTS (
                SELECT revision_id
                  FROM mtl_item_revisions_b
                 WHERE inventory_item_id = p_from_item_id
                   AND organization_id = p_from_org_id
                   AND revision_id = p_revision_id);

      RETURN l_return;
   END revision_exists;

   /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ** Function: Get_Max_Revision
   ** Scope   : Local
   ** Purpose: This function was added to get around the 8i compatibility issues.
   **
   *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION get_max_minorrev (
      p_item_id       IN   NUMBER,
      p_org_id        IN   NUMBER,
      p_revision_id   IN   NUMBER
   )
      RETURN NUMBER
   IS
      l_minor_rev_id   NUMBER;
   BEGIN
      SELECT NVL (MAX (minor_revision_id), 0)
        INTO l_minor_rev_id
        FROM ego_minor_revisions
       WHERE obj_name = 'EGO_ITEM'
         AND pk1_value = p_item_id
         AND NVL (pk2_value, '-1') = NVL (p_org_id, '-1')
         AND NVL (pk3_value, '-1') = NVL (p_revision_id, '-1');

      RETURN l_minor_rev_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_max_minorrev;

   /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ** Function: Get_Revision
   ** Scope   : Local
   ** Purpiose: This function was added to get around the 8i compatibility issues.
   **
   *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION get_revision (
      p_item_id       IN   NUMBER,
      p_org_id        IN   NUMBER,
      p_revision_id   IN   NUMBER
   )
      RETURN NUMBER
   IS
      l_revision_id   NUMBER;
   BEGIN
      SELECT tmirb.revision_id
        INTO l_revision_id
        FROM mtl_item_revisions_b fmirb,
             mtl_item_revisions_b tmirb
       WHERE tmirb.inventory_item_id = p_item_id
         AND tmirb.organization_id = p_org_id
         AND tmirb.revision = fmirb.revision
         AND fmirb.revision_id = p_revision_id;

      RETURN l_revision_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END get_revision;

   /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ** Function: Get_Minor_Rev_Code
   ** Scope   : Local
   ** Purpose: This function was added to get around the 8i compatibility issues.
   **
   *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION get_minor_rev_code (
      p_end_item_rev_id         IN   NUMBER,
      p_end_item_minor_rev_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      l_rev_code   NUMBER;
   BEGIN
      SELECT CONCAT (TO_CHAR (effectivity_date, 'yyyymmddhh24miss'),
                     TO_CHAR (NVL (p_end_item_minor_rev_id, 9999999999999999))
                    )
        INTO l_rev_code
        FROM mtl_item_revisions_b
       WHERE revision_id = p_end_item_rev_id;

      RETURN l_rev_code;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END get_minor_rev_code;

/* This procedure can be used in following scenarios:
 * i)  Specific components, reference designators and substitute components have to be copied.
 * ii) Where attachments have to be copied for the bill.
 * iii) If some of the components in the destination bill has to be replaced with some other components.
 * iv) If only components, reference designators or substitute components needs to be copied.
 * specific_copy_flag  -- This flag species whether we need to copy all components or specific.
 * copy_all_comps_flag -- Flag specifies whether all the components needs to be copied.
 * copy_all_rfds_flag -- Flag specifies whether all the reference designators for the components needs to be copied.
 * copy_all_sub_comps_flag -- Flag specifies whether all the substitute components for the components needs to be copied.
 * copy_attach_flag -- Specifies whether attachments needs to be copied.
 */
   PROCEDURE copy_bill (
      to_sequence_id               IN   NUMBER,
      from_sequence_id             IN   NUMBER,
      from_org_id                  IN   NUMBER,
      to_org_id                    IN   NUMBER,
      display_option               IN   NUMBER DEFAULT 2,
      user_id                      IN   NUMBER DEFAULT -1,
      to_item_id                   IN   NUMBER,
      direction                    IN   NUMBER DEFAULT 1,
      to_alternate                 IN   VARCHAR2,
      rev_date                     IN   DATE,
      e_change_notice              IN   VARCHAR2,
      rev_item_seq_id              IN   NUMBER,
      bill_or_eco                  IN   NUMBER,
      eco_eff_date                 IN   DATE,
      eco_unit_number              IN   VARCHAR2 DEFAULT NULL,
      unit_number                  IN   VARCHAR2 DEFAULT NULL,
      from_item_id                 IN   NUMBER,
      --  to_minor_rev_id         IN NUMBER DEFAULT NULL,
      -- Flag, which specifies the type of copy. Default value takes care of the existing API call
      -- from ERP. 'Y' Selective copy 'N' Copy all components
      specific_copy_flag           IN   VARCHAR2,
      copy_all_comps_flag          IN   VARCHAR2 DEFAULT 'N',
      copy_all_rfds_flag           IN   VARCHAR2 DEFAULT 'N',
      copy_all_subcomps_flag       IN   VARCHAR2 DEFAULT 'N',
      --  copy_all_compops_flag IN VARCHAR2 DEFAULT 'N',
      copy_attach_flag             IN   VARCHAR2 DEFAULT 'Y',
      -- Request Id for this copy operation.  Value from BOM_COPY_STRUCTURE_REQUEST_S
      -- To populate the errors in MTL_INTERFACE_ERRORS with this transaction id
      p_copy_request_id            IN   NUMBER,
      --  Unit number for copy to item
      eco_end_item_rev_id          IN   NUMBER DEFAULT NULL,
      -- Structure has been exploded in context of this ECO for copying
      context_eco                  IN   VARCHAR2 DEFAULT NULL,
      p_end_item_rev_id            IN   NUMBER DEFAULT NULL,
      -- Effectivity Date, End Item Unit Number and End Item Rev Id
      -- for the components which are getting copied.  Components from effectivity boundary.
      trgt_comps_eff_date          IN   DATE DEFAULT NULL,
      trgt_comps_unit_number       IN   VARCHAR2 DEFAULT NULL,
      trgt_comps_end_item_rev_id   IN   NUMBER DEFAULT NULL,
      -- Since the JOIN occurs with bom_copy_explosions_v, there could be multiple
      -- sub-assemblies (items) in the exploded structure at different levels
      -- but if we copy once that will be suffice
      p_parent_sort_order          IN   VARCHAR2 DEFAULT NULL,
      p_cpy_disable_fields         IN   VARCHAR2 DEFAULT 'N',
      p_trgt_str_eff_ctrl          IN   NUMBER DEFAULT 1,
	  p_trgt_str_type_id           IN   NUMBER DEFAULT NULL
   )
   IS
      bom_to_bom              CONSTANT NUMBER                        := 1;
      bom_to_eng              CONSTANT NUMBER                        := 2;
      eng_to_eng              CONSTANT NUMBER                        := 3;
      eng_to_bom              CONSTANT NUMBER                        := 4;
      model                   CONSTANT NUMBER                        := 1;
      option_class            CONSTANT NUMBER                        := 2;
      planning                CONSTANT NUMBER                        := 3;
      STANDARD                CONSTANT NUMBER                        := 4;
      phantom                 CONSTANT NUMBER                        := 6;
      x_from_sequence_id               NUMBER             := from_sequence_id;
      x_from_org_id                    NUMBER                  := from_org_id;
      to_rtg_seq_id                    NUMBER;
      itm_cat_grp_id                   NUMBER;
      dummy                            NUMBER;
      sql_stmt_num                     NUMBER;
      base_item_flag                   NUMBER;
      itm_type                         NUMBER;
      copy_comps                       NUMBER;
      copy_comts                       NUMBER;
      copy_subs                        NUMBER;
      copy_desgs                       NUMBER;
      copy_compops                     NUMBER;
      copy_atts                        NUMBER;
      err_msg                          VARCHAR (2000);
      atp_comp_flag                    VARCHAR2 (1);
      rto_flag                         VARCHAR2 (1);
      old_max                          NUMBER                        := 0;
      new_seq_num                      NUMBER                        := 0;
      processed                        NUMBER                        := 0;
      tmp_var                          NUMBER                        := 0;
      total_inventory_components       NUMBER                        := 0;
      total_assembly_comments          NUMBER                        := 0;
      total_reference_designators      NUMBER                        := 0;
      total_substitute_components      NUMBER                        := 0;
      total_component_operations       NUMBER                        := 0;
      l_to_item_rev_id                 NUMBER                        := -1;
      l_to_item_minor_rev_id           NUMBER                        := 0;
      error_status                     VARCHAR2 (1)                  := 'F';
      msg_count                        NUMBER                        := 0;
      item_rev                         VARCHAR2 (3)                  := NULL;
      l_item_rev_date                  DATE                        := SYSDATE;
      l_from_item_rev_id               NUMBER;
      l_from_item_rev                  VARCHAR2 (3)                  := NULL;
      l_return_status                  VARCHAR2 (1)                  := 'S';
      l_item_number                    VARCHAR2 (80)                 := NULL;
      l_org_code                       VARCHAR2 (3)                  := NULL;
      l_uom_code                       VARCHAR2 (3)                  := NULL;
      p_commit                         VARCHAR2 (8)                := 'FALSE';
      l_msg_count                      NUMBER                        := 0;
      l_item_rec_in                    inv_item_grp.item_rec_type;
      l_item_rec_out                   inv_item_grp.item_rec_type;
      l_error_tbl                      inv_item_grp.error_tbl_type;
      l_dest_pk_col_name_val_pairs     ego_col_name_value_pair_array;
      l_src_pk_col_name_val_pairs      ego_col_name_value_pair_array;
      l_new_str_type                   ego_col_name_value_pair_array;
      l_str_type                       NUMBER;
      l_errorcode                      NUMBER;
      l_msg_data                       VARCHAR2 (100);
      x_acd_type                       NUMBER;
      x_rev_item_seq_id                NUMBER;
      x_e_change_notice                VARCHAR2 (10);
      x_effectivity_date               DATE;
      x_unit_number                    VARCHAR2 (30);
      x_end_item_rev_id                NUMBER;
      x_unit_assembly                  VARCHAR2 (2)                  := 'N';
      overlap_error                    EXCEPTION;
      common_error                     EXCEPTION;
      no_item_rev_exists               EXCEPTION;
      no_minor_rev_exists              EXCEPTION;
      no_minor_rev_code_exists         EXCEPTION;
      l_count1                         NUMBER;
      l_count2                         NUMBER;
      l_count3                         NUMBER;
      l_comp_ctr                       NUMBER;
      /*
      l_copied_comp_seq                num_varray            := num_varray
                                                                          ();
      l_copied_comp_item_id            num_varray            := num_varray
                                                                          ();
      l_copied_op_seq_num              num_varray            := num_varray
                                                                          ();
      l_mapped_comp_seq                num_varray            := num_varray
                                                                          ();
      */
--    l_from_end_item_minor_rev_code VARCHAR2(30);
--      l_from_bom_item_minor_rev_code   VARCHAR2 (30);
      l_from_eff_ctrl                  bom_structures_b.effectivity_control%TYPE;
      l_to_eff_ctrl                    bom_structures_b.effectivity_control%TYPE;
      l_no_access_comp_cnt             NUMBER;
      l_fixed_rev                      mtl_item_revisions_b.revision%TYPE;
      l_current_item_rev               mtl_item_revisions_b.revision%TYPE;
      l_current_item_rev_id            mtl_item_revisions_b.revision_id%TYPE;
	  l_use_eco_flag                   varchar2(1) := 'N';
	  l_error_msg_tbl                  Error_Handler.Error_Tbl_Type;

    l_default_wip_params NUMBER;
--    l_from_end_item_id NUMBER;
--    l_to_end_item_min_revision_id NUMBER;
    ---- Bug Fix 4279959 Install testing issue
      /*
                                                                          ();
      copy_rfds_arr                    num_varray            := num_varray
                                                                          ();
      copy_subcomps_arr                num_varray            := num_varray
                                                                          ();
      */
      l_from_comps                     num_varray            := num_varray
                                                                          ();
      l_to_comps                       num_varray            := num_varray
                                                                          ();
      l_data_level_name_comp VARCHAR2(30) := 'COMPONENTS_LEVEL';
      l_data_level_id_comp   NUMBER;
      l_old_dtlevel_col_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
      l_new_dtlevel_col_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;


      CURSOR l_common_csr
      IS
         SELECT 1
           FROM DUAL
          WHERE EXISTS (
                   SELECT NULL
                     FROM bom_structures_b bom,
                          bom_inventory_components bic
                    WHERE bom.organization_id <> to_org_id
                      AND bom.common_bill_sequence_id = to_sequence_id
                      AND bic.bill_sequence_id = to_sequence_id
                      AND NOT EXISTS (
                            SELECT NULL
                              FROM mtl_system_items cmsi,
                                   mtl_system_items bmsi
                             WHERE cmsi.organization_id = bom.organization_id
                               AND cmsi.inventory_item_id =
                                                         bic.component_item_id
                               AND bmsi.organization_id = bom.organization_id
                               AND bmsi.inventory_item_id =
                                                          bom.assembly_item_id
                               AND cmsi.eng_item_flag =
                                     DECODE (bom.assembly_type,
                                             1, 'N',
                                             2, cmsi.eng_item_flag
                                            )
                               AND cmsi.bom_enabled_flag = 'Y'
                               AND cmsi.inventory_item_id <>
                                                          bom.assembly_item_id
                               AND ((bmsi.bom_item_type = 1
                                     AND cmsi.bom_item_type <> 3
                                    )
                                    OR (bmsi.bom_item_type = 2
                                        AND cmsi.bom_item_type <> 3
                                       )
                                    OR (bmsi.bom_item_type = 3)
                                    OR (bmsi.bom_item_type = 4
                                        AND (cmsi.bom_item_type = 4
                                             OR (cmsi.bom_item_type IN (1, 2)
                                                 AND cmsi.replenish_to_order_flag =
                                                                           'Y'
                                                 AND bmsi.base_item_id IS NOT NULL
                                                 AND bmsi.replenish_to_order_flag =
                                                                           'Y'
                                                )
                                            )
                                       )
                                   )
                               AND (bmsi.bom_item_type = 3
                                    OR bmsi.pick_components_flag = 'Y'
                                    OR cmsi.pick_components_flag = 'N'
                                   )
                               AND (bmsi.bom_item_type = 3
                                    OR NVL (cmsi.bom_item_type, 4) <> 2
                                    OR (cmsi.bom_item_type = 2
                                        AND ((bmsi.pick_components_flag = 'Y'
                                              AND cmsi.pick_components_flag =
                                                                           'Y'
                                             )
                                             OR (bmsi.replenish_to_order_flag =
                                                                           'Y'
                                                 AND cmsi.replenish_to_order_flag =
                                                                           'Y'
                                                )
                                            )
                                       )
                                   )
                               AND NOT (bmsi.bom_item_type = 4
                                        AND bmsi.pick_components_flag = 'Y'
                                        AND cmsi.bom_item_type = 4
                                        AND cmsi.replenish_to_order_flag = 'Y'
                                       )));

      CURSOR item_rev_cursor (
         p_item_id    IN   NUMBER,
         p_org_id     IN   NUMBER,
         p_rev_date   IN   DATE
      -- , P_IMPL_FLAG IN NUMBER
      )
      IS
         SELECT   revision_id,
                  revision
             FROM mtl_item_revisions_b mir
            WHERE mir.inventory_item_id = p_item_id
              AND mir.organization_id = p_org_id
              AND mir.effectivity_date <= p_rev_date
              AND ROWNUM < 2
--       AND (P_IMPL_FLAG = 2  OR (P_IMPL_FLAG = 1 AND mir.implementation_date IS NOT NULL) )
         ORDER BY mir.effectivity_date DESC;

      CURSOR item_minor_rev_cursor (
         p_pk1_value   IN   VARCHAR2,
         p_pk2_value   IN   VARCHAR2,
         p_pk3_value   IN   VARCHAR2
      )
      IS
         SELECT NVL (MAX (minor_revision_id), 0) minor_revision_id
           FROM ego_minor_revisions
          WHERE obj_name = 'EGO_ITEM'
            AND pk1_value = p_pk1_value
            AND NVL (pk2_value, '-1') = NVL (p_pk2_value, '-1')
            AND NVL (pk3_value, '-1') = NVL (p_pk3_value, '-1');

      CURSOR l_org_item_csr (p_item_id IN NUMBER, p_org_id IN NUMBER)
      IS
         SELECT concatenated_segments,
                primary_uom_code
           FROM mtl_system_items_b_kfv
          WHERE inventory_item_id = p_item_id
            AND organization_id = p_org_id;

      CURSOR getcurrentminorrevcode (
         p_item_rev_id   IN   NUMBER,
         -- p_obj_name IN VARCHAR2,
         p_pk1_value     IN   VARCHAR2,
         p_pk2_value     IN   VARCHAR2
      )
      IS
         SELECT CONCAT (TO_CHAR (r.effectivity_date, 'yyyymmddhh24miss'),
                        maxr.minor_rev_id
                       ) mrev_code
           FROM mtl_item_revisions_b r,
                (SELECT NVL (MAX (minor_revision_id), 0) minor_rev_id
                   FROM ego_minor_revisions
                  WHERE obj_name = 'EGO_ITEM'                     --p_obj_name
                    AND pk1_value = p_pk1_value
                    AND NVL (pk2_value, '-1') = NVL (p_pk2_value, '-1')
                    AND NVL (pk3_value, '-1') =
                                           NVL (TO_CHAR (p_item_rev_id), '-1')) maxr
          WHERE revision_id = p_item_rev_id;

/*
 * This cursor returns the coponent_item_id, comp_seq_id and op_seq_num
 * of the copied components.
 */
      CURSOR get_copied_comps (
         p_comp_seq_num       NUMBER,
         p_display_option     NUMBER,
         p_direction          NUMBER,
         p_unit_assembly      VARCHAR2,
         p_itm_type           NUMBER,
         p_base_item_flag     NUMBER,
         p_from_sequence_id   NUMBER,
         p_to_item_id         NUMBER,
         p_to_org_id          NUMBER,
         p_rev_date           DATE,
         p_unit_number        VARCHAR2
      )
      IS
         SELECT bic.component_sequence_id,
                bic.component_item_id,
                bic.operation_seq_num
           FROM bom_inventory_components bic,
                mtl_system_items msi
          WHERE bic.bill_sequence_id = p_from_sequence_id
            AND bic.component_item_id = msi.inventory_item_id
            AND bic.component_item_id <> p_to_item_id
            AND NVL (bic.eco_for_production, 2) = 2
            AND msi.organization_id = p_to_org_id
            --  AND MSI.BOM_ENABLED_FLAG = 'Y'
            AND ((p_direction = eng_to_bom
                  AND msi.eng_item_flag = 'N')
                 OR (p_direction <> eng_to_bom)
                )
            AND ((p_unit_assembly = 'N'
                  AND ((p_display_option = 1)                           -- ALL
                       OR (p_display_option = 2
                           AND (effectivity_date <= p_rev_date
                                AND
                                    -- Added condition of sysdate for Bug 2161841
                                (    (disable_date > p_rev_date
                                      AND disable_date > SYSDATE
                                     )
                                     OR disable_date IS NULL
                                    )
                               )
                          )
                       OR                                           -- CURRENT
                         (p_display_option = 3
                          AND
                              -- Added condition of sysdate for Bug 2161841
                          (    (disable_date > p_rev_date
                                AND disable_date > SYSDATE
                               )
                               OR disable_date IS NULL
                              )
                         )
                      )                                    -- CURRENT + FUTURE
                 )
                 OR (p_unit_assembly = 'Y'
                     AND ((p_display_option = 1)                        -- ALL
                          OR (p_display_option = 2
                              AND disable_date IS NULL
                              AND (from_end_item_unit_number <= p_unit_number
                                   AND (to_end_item_unit_number >=
                                                                 p_unit_number
                                        OR to_end_item_unit_number IS NULL
                                       )
                                  )
                             )
                          OR                                        -- CURRENT
                            (p_display_option = 3
                             AND disable_date IS NULL
                             AND (to_end_item_unit_number >= p_unit_number
                                  OR to_end_item_unit_number IS NULL
                                 )
                            )
                         )                                 -- CURRENT + FUTURE
                    )
                )
            AND ((p_base_item_flag = -1
                  AND p_itm_type = 4
                  AND msi.bom_item_type = 4
                 )
                 OR p_base_item_flag <> -1
                 OR p_itm_type <> 4
                )
            AND implementation_date IS NOT NULL
            AND component_sequence_id = p_comp_seq_num;

      /*
       * This cursor gets the component in the dest structure
       * copied from a particular source component.
       */
      CURSOR get_mapped_components (
         p_to_bill_sequence_id   NUMBER,
         p_copied_comp_item_id   NUMBER,
         p_copied_op_seq_num     NUMBER
      )
      IS
         /*Ideally we should be doing an effectivity check here as well
           Left for later*/
         SELECT component_sequence_id
           FROM bom_inventory_components bic
          WHERE bill_sequence_id = p_to_bill_sequence_id
            AND component_item_id = p_copied_comp_item_id
            AND operation_seq_num = p_copied_op_seq_num;

      CURSOR l_from_to_comps_csr (
         p_from_seq_id   IN   NUMBER,
         p_to_seq_id     IN   NUMBER
      )
      IS
         SELECT bcb1.component_sequence_id from_component_seq_id,
                bcb2.component_sequence_id to_sequence_id
           FROM bom_components_b bcb1,
                bom_components_b bcb2
          WHERE bcb1.bill_sequence_id = p_from_seq_id
            AND bcb1.component_sequence_id = bcb2.created_by
            AND bcb2.bill_sequence_id = p_to_seq_id;
        l_index NUMBER := 0;

      CURSOR l_mark_components_csr (
         p_change_notice IN VARCHAR2,
         p_local_org_id IN NUMBER,
         p_bill_seq_id IN NUMBER
      )
      IS
         SELECT eec.change_id,
                bcb.component_sequence_id
           FROM eng_engineering_changes eec,
                bom_components_b bcb
          WHERE eec.change_notice = p_change_notice
            AND eec.organization_id = p_local_org_id
            AND bcb.bill_sequence_id = p_bill_seq_id;
      CURSOR l_fixed_rev_comp_csr (
         p_parent_sort_order IN VARCHAR2
      )
      IS
         SELECT bev.comp_fixed_rev_code
           FROM bom_copy_explosions_v bev
          WHERE bev.sort_order = p_parent_sort_order;
      CURSOR l_eff_date_for_rev_csr (
         p_inventory_item_id IN NUMBER,
         p_organization_id   IN NUMBER,
         p_revision          IN VARCHAR2
      )
      IS
         SELECT effectivity_date
           FROM mtl_item_revisions_b
          WHERE inventory_item_id = p_inventory_item_id
            AND organization_id = p_organization_id
            AND revision = p_revision;

    CURSOR C_DATA_LEVEL(p_data_level_name VARCHAR2) IS
      SELECT DATA_LEVEL_ID
        FROM EGO_DATA_LEVEL_B
       WHERE DATA_LEVEL_NAME = p_data_level_name;

   BEGIN
      SAVEPOINT begin_bill_copy;



      -- dbms_profiler.start_profiler(' COPY BILL CALL ' || to_char(sysdate,'dd-mm-yyyy hh24:mi:ss'));
         /*
          Debug values
          a_debug('to_sequence_id '||    to_sequence_id);
          a_debug('from_sequence_id '|| from_sequence_id);
          a_debug('from_org_id '|| from_org_id);
          a_debug('to_org_id '||to_org_id);
          a_debug('display option ' || display_option);
          a_debug('user_id '|| user_id);
          a_debug('direction '||direction);
          a_debug('rev_date ' || to_char(rev_date,'DD-MON-YYYY HH24:MI:SS'));
          a_debug('change notice ' || e_change_notice);
          a_debug('bill_or_eco ' || bill_or_eco);
          a_debug('from item id '||from_item_id);
          a_debug('specific copy flag '||specific_copy_flag);
          a_debug(' copy_all_comps_flag '|| copy_all_comps_flag);
          a_debug('unit number '|| unit_number);
      --  a_debug('from_end_item_id ' || from_end_item_id);
      --  a_debug('from_end_item_revision_id '||from_end_item_revision_id);
      --  a_debug('from_end_item_min_revision_id '|| from_end_item_min_revision_id);
      --  a_debug('to_end_item_id '||  to_end_item_id);
      --  a_debug('to_end_item_revision_id '||to_end_item_revision_id);
      --  a_debug('to_end_item_min_revision_id '||to_end_item_min_revision_id);

          */

      /* End Item Rev Eff components are not supported as of now.
      IF to_end_item_min_revision_id IS NOT NULL THEN
         l_to_end_item_min_revision_id := to_end_item_min_revision_id;
      ELSE
         OPEN item_minor_rev_cursor(to_char(to_end_item_id), to_char(to_org_id),to_char(to_end_item_revision_id));

         LOOP
            FETCH item_minor_rev_cursor INTO l_to_end_item_min_revision_id;
            EXIT WHEN item_minor_rev_cursor%NOTFOUND;
         END LOOP;
         IF l_to_end_item_min_revision_id IS NULL OR '' = l_to_end_item_min_revision_id THEN
            CLOSE item_minor_rev_cursor;
            RAISE NO_MINOR_REV_EXISTS;
         END IF;

         CLOSE item_minor_rev_cursor;
      END IF;
      */

      --bug:5364225 When copying across orgs, wip supply type will be copied from
      --component/component operation. If Default Wip Values profile is set to Yes, then
      --supply subinventory and supply locator will be defaulted from item otherwise they
      --will be nulled out. When copying within same org, the values will be copied from comp/comp operation.
      FND_PROFILE.GET('BOM:DEFAULT_WIP_VALUES', l_default_wip_params);

      -- reset from_sequence_id to common_bill_sequence_id
      sql_stmt_num := 10;

      SELECT common_bill_sequence_id,
             NVL (common_organization_id, organization_id)
        INTO x_from_sequence_id,
             x_from_org_id
        FROM bom_structures_b
       WHERE bill_sequence_id = x_from_sequence_id;

      SELECT structure_type_id, effectivity_control
        INTO l_str_type, l_from_eff_ctrl
        FROM bom_structures_b
       WHERE bill_sequence_id = from_sequence_id;

      FOR c_comp_level IN C_DATA_LEVEL(l_data_level_name_comp) LOOP
        l_data_level_id_comp := c_comp_level.DATA_LEVEL_ID;
      END LOOP;


      l_to_eff_ctrl := p_trgt_str_eff_ctrl;

      /* End Item Rev Eff components are not supported as of now.
      IF from_end_item_id IS NULL THEN
         l_from_end_item_id := from_item_id;
      ELSE
         l_from_end_item_id := from_end_item_id;
      END IF;
      */

      /* Serial Effectivity Implementation */
      IF (bom_eamutil.enabled = 'Y'
          AND bom_eamutil.serial_effective_item (item_id      => from_item_id,
                                                 org_id       => x_from_org_id
                                                ) = 'Y'
         )
         OR (pjm_unit_eff.enabled = 'Y'
             AND pjm_unit_eff.unit_effective_item
                                           (x_item_id              => from_item_id,
                                            x_organization_id      => x_from_org_id
                                           ) = 'Y'
            )
      THEN
         x_unit_assembly := 'Y';
      ELSE
         x_unit_assembly := 'N';
      END IF;

      --if interorg copy then fetch values for max rows to copy
      --    if (X_from_org_id <> to_org_id) then                    -Bug 1825873
      bill_get_msg_info (total_inventory_components,
                         total_assembly_comments,
                         total_reference_designators,
                         total_substitute_components,
                         x_from_sequence_id,
                         rev_date,
                         display_option,
                         unit_number,
                         x_from_org_id,
                         from_item_id,
                         x_unit_assembly
                        );
      --    end if;                                                -Bug 1825873
      -- find out the max rows ro copy for component operations. This is done seperately
      -- from the previous procedure since we need the max rows for
      -- component operations though the from_org_id and to_org_id are same
      bill_get_msg_info_compops (total_component_operations,
                                 x_from_sequence_id,
                                 rev_date,
                                 display_option,
                                 unit_number,
                                 x_from_org_id,
                                 from_item_id,
                                 x_unit_assembly
                                );
      --Load host variables, bill_atp_comps_flag and bill_rto_flag
      sql_stmt_num := 15;

      SELECT atp_components_flag,
             replenish_to_order_flag,
             DECODE (base_item_id, NULL, -1, 0),
             bom_item_type,
             item_catalog_group_id
        INTO atp_comp_flag,
             rto_flag,
             base_item_flag,
             itm_type,
             itm_cat_grp_id
        FROM mtl_system_items
       WHERE organization_id = to_org_id
         AND inventory_item_id = to_item_id;

      sql_stmt_num := 18;

      -- These lines were added for the eco form
      IF bill_or_eco = 2
      THEN                                                    -- 2 is from eco
         x_acd_type := 1;
         x_e_change_notice := e_change_notice;
         x_rev_item_seq_id := rev_item_seq_id;
         x_effectivity_date := eco_eff_date;
         x_unit_number := eco_unit_number;
         x_end_item_rev_id := eco_end_item_rev_id;
      ELSIF bill_or_eco <> 2
      THEN
         x_e_change_notice := NULL;
         x_acd_type := NULL;
         x_rev_item_seq_id := NULL;
         x_effectivity_date := NULL;
         x_unit_number := NULL;
         x_end_item_rev_id := NULL;
      END IF;

      IF specific_copy_flag = 'Y'
      THEN
          OPEN l_fixed_rev_comp_csr(p_parent_sort_order);
          l_fixed_rev := NULL;
          LOOP
             FETCH l_fixed_rev_comp_csr
              INTO l_fixed_rev;
             EXIT WHEN l_fixed_rev_comp_csr%NOTFOUND;
          END LOOP;
		  IF l_fixed_rev_comp_csr%ISOPEN THEN
		    CLOSE l_fixed_rev_comp_csr;
		  END IF;

      END IF;

      IF bill_or_eco = 1 THEN
        OPEN item_rev_cursor (to_item_id, to_org_id, trgt_comps_eff_date);

        LOOP
          FETCH item_rev_cursor
          INTO l_current_item_rev_id,
               l_current_item_rev;

          EXIT WHEN item_rev_cursor%NOTFOUND;
        END LOOP;
      ELSE
        OPEN item_rev_cursor (to_item_id, to_org_id, x_effectivity_date);

        LOOP
          FETCH item_rev_cursor
          INTO l_current_item_rev_id,
               l_current_item_rev;

          EXIT WHEN item_rev_cursor%NOTFOUND;
        END LOOP;
      END IF;

      IF item_rev_cursor%ISOPEN THEN
        CLOSE item_rev_cursor;
      END IF;

      IF l_fixed_rev IS NOT NULL AND trgt_comps_eff_date IS NOT NULL
      THEN
         OPEN l_eff_date_for_rev_csr( to_item_id, to_org_id, l_fixed_rev);
         LOOP
           FETCH l_eff_date_for_rev_csr
           INTO l_item_rev_date;
           EXIT WHEN l_eff_date_for_rev_csr%NOTFOUND;
         END LOOP;
		 IF l_eff_date_for_rev_csr%ISOPEN THEN
		   CLOSE l_eff_date_for_rev_csr;
		 END IF;
      END IF;
      OPEN item_rev_cursor (to_item_id, to_org_id, l_item_rev_date);

      LOOP
         FETCH item_rev_cursor
          INTO l_to_item_rev_id,
               item_rev;

         EXIT WHEN item_rev_cursor%NOTFOUND;
      END LOOP;

      IF item_rev IS NULL
         OR '' = item_rev
      THEN
         CLOSE item_rev_cursor;

         RAISE no_item_rev_exists;
      END IF;

      IF item_rev_cursor%ISOPEN THEN
        CLOSE item_rev_cursor;
	  END IF;

      OPEN item_rev_cursor (from_item_id, from_org_id, rev_date);

      LOOP
         FETCH item_rev_cursor
          INTO l_from_item_rev_id,
               l_from_item_rev;

         EXIT WHEN item_rev_cursor%NOTFOUND;
      END LOOP;

      IF l_from_item_rev IS NULL
         OR '' = l_from_item_rev
      THEN
         CLOSE item_rev_cursor;

         RAISE no_item_rev_exists;
      END IF;

      IF item_rev_cursor%ISOPEN THEN
        CLOSE item_rev_cursor;
	  END IF;

      OPEN item_minor_rev_cursor (TO_CHAR (to_item_id),
                                  TO_CHAR (to_org_id),
                                  TO_CHAR (l_to_item_rev_id)
                                 );

      LOOP
         FETCH item_minor_rev_cursor
          INTO l_to_item_minor_rev_id;

         EXIT WHEN item_minor_rev_cursor%NOTFOUND;
      END LOOP;

      IF l_to_item_minor_rev_id IS NULL
         OR '' = l_to_item_minor_rev_id
      THEN
         CLOSE item_minor_rev_cursor;

         RAISE no_minor_rev_exists;
      END IF;

      IF item_minor_rev_cursor%ISOPEN THEN
        CLOSE item_minor_rev_cursor;
	  END IF;

      /* Not Required Commented on Oct 14 2005
      IF (l_eff_ctrl = 4)
      THEN
         OPEN GetCurrentMinorRevCode(from_end_item_revision_id,
                                     to_char(l_from_end_item_id),
                     to_char(from_org_id)
                     );

         LOOP
           FETCH GetCurrentMinorRevCode INTO l_from_end_item_minor_rev_code;
           EXIT WHEN GetCurrentMinorRevCode%NOTFOUND;
         END LOOP;
         IF l_from_end_item_minor_rev_code IS NULL OR '' = l_from_end_item_minor_rev_code THEN
         CLOSE GetCurrentMinorRevCode;
         RAISE NO_MINOR_REV_CODE_EXISTS;
         END IF;

         CLOSE GetCurrentMinorRevCode;
         OPEN getcurrentminorrevcode (l_from_item_rev_id,
                                      TO_CHAR (from_item_id),
                                      TO_CHAR (from_org_id)
                                     );

         LOOP
            FETCH getcurrentminorrevcode
             INTO l_from_bom_item_minor_rev_code;

            EXIT WHEN getcurrentminorrevcode%NOTFOUND;
         END LOOP;

         IF l_from_bom_item_minor_rev_code IS NULL
            OR '' = l_from_bom_item_minor_rev_code
         THEN
            CLOSE getcurrentminorrevcode;

            RAISE no_minor_rev_code_exists;
         END IF;

         CLOSE getcurrentminorrevcode;
      END IF;
      */

      -- Copies the components if the API is called for selective component copy.
      sql_stmt_num := 20;

      IF specific_copy_flag = 'Y'
      THEN

         /* Bug : 4185500   Structure Level Attribute copy */
         l_src_pk_col_name_val_pairs :=
            ego_col_name_value_pair_array
                      (ego_col_name_value_pair_obj ('BILL_SEQUENCE_ID',
                                                    TO_CHAR (from_sequence_id)
                                                   )
                      );
         l_dest_pk_col_name_val_pairs :=
            ego_col_name_value_pair_array
                         (ego_col_name_value_pair_obj ('BILL_SEQUENCE_ID',
                                                       TO_CHAR (to_sequence_id)
                                                      )
                         );
         l_new_str_type :=
            ego_col_name_value_pair_array
                            (ego_col_name_value_pair_obj ('STRUCTURE_TYPE_ID',
                                                          TO_CHAR (l_str_type)
                                                         )
                            );
         ego_user_attrs_data_pub.copy_user_attrs_data
                    (p_api_version                 => 1.0,
                     p_application_id              => bom_application_id,
                     p_object_name                 => 'BOM_STRUCTURE',
                     p_old_pk_col_value_pairs      => l_src_pk_col_name_val_pairs,
                     p_new_pk_col_value_pairs      => l_dest_pk_col_name_val_pairs,
                     p_new_cc_col_value_pairs      => l_new_str_type,
                     x_return_status               => l_return_status,
                     x_errorcode                   => l_errorcode,
                     x_msg_count                   => l_msg_count,
                     x_msg_data                    => l_msg_data
                    );
		 IF l_return_status <> fnd_api.g_ret_sts_success THEN
		   error_handler.get_message_list(l_error_msg_tbl);
		   IF l_error_msg_tbl.FIRST IS NOT NULL THEN
		     l_msg_count := l_error_msg_tbl.FIRST;
		     WHILE l_msg_count IS NOT NULL
		     LOOP
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
                 SELECT from_item_id,
                        to_org_id,
                        p_copy_request_id,
                        NULL,
                        get_current_item_rev (from_item_id,
                                            from_org_id,
                                            rev_date
                                           ),
                        l_error_msg_tbl(l_msg_count).message_text,
                        'BOM_COPY',
                        SYSDATE,
                        user_id,
                        SYSDATE,
                        user_id,
                        'E',
                        fnd_global.conc_request_id,
                        NULL,
                        fnd_global.conc_program_id,
                        sysdate
                   FROM dual;
               l_msg_count := l_error_msg_tbl.next(l_msg_count);
			 END LOOP;
		   END IF;
		 END IF;
         --turn off the trigger BOMTBICX
         bom_globals.g_skip_bomtbicx := 'Y';

         IF l_from_eff_ctrl = 1 AND l_to_eff_ctrl = 1 THEN -- Date - Date


	   INSERT INTO bom_components_b
                     (shipping_allowed,
                      required_to_ship,
                      required_for_revenue,
                      include_on_ship_docs,
                      include_on_bill_docs,
                      low_quantity,
                      high_quantity,
                      acd_type,
                      component_sequence_id,
                      old_component_sequence_id,
                      bill_sequence_id,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      wip_supply_type,
                      pick_components,
                      supply_subinventory,
                      supply_locator_id,
                      operation_lead_time_percent,
                      revised_item_sequence_id,
                      cost_factor,
                      operation_seq_num,
                      component_item_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      item_num,
                      component_quantity,
                      component_yield_factor,
                      component_remarks,
                      effectivity_date,
                      change_notice,
                      implementation_date,
                      disable_date,
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
                      planning_factor,
                      quantity_related,
                      so_basis,
                      optional,
                      mutually_exclusive_options,
                      include_in_cost_rollup,
                      check_atp,
                      bom_item_type,
                      from_end_item_unit_number,
                      to_end_item_unit_number,
                      optional_on_model,
                      --BUGFIX 2740820
                      parent_bill_seq_id,                     --BUGFIX 2740820
                      model_comp_seq_id,                      --BUGFIX 2740820
                      plan_level,
                      --BUGFIX 2740820
                      enforce_int_requirements,               --BUGFIX 2991472
                      from_object_revision_id,
                      from_minor_revision_id,
                      pk1_value,
                      pk2_value,
                      auto_request_material,
                      -- Bug 3662214 : Added following 4 fields
                      suggested_vendor_name,
                      vendor_id,
                      unit_price,
                      from_end_item_rev_id,
                      to_end_item_rev_id,
                      from_end_item_minor_rev_id,
                      to_end_item_minor_rev_id,
                      component_item_revision_id,
                      component_minor_revision_id,
                      basis_type,
                      to_object_revision_id,
                      to_minor_revision_id
                     )
            SELECT bic.shipping_allowed,
                   bic.required_to_ship,
                   bic.required_for_revenue,
                   bic.include_on_ship_docs,
                   bic.include_on_bill_docs,
                   --bic.low_quantity,
                   --bic.high_quantity,
		   DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.low_quantity,
			  DECODE(BIC.low_quantity,null,null,              --Added this inner Deocde for Bug 6847530
                          inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.low_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure))) Comp_low_qty,
		   DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.high_quantity,
                          DECODE(BIC.high_quantity,null,null,             --Added this inner Deocde for Bug 6847530
			  inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.high_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure))) Comp_high_qty,
                   x_acd_type,
                   bom_inventory_components_s.NEXTVAL,
                   DECODE (x_acd_type,
                           NULL, NULL,
                           bom_inventory_components_s.CURRVAL
                          ),
                   to_sequence_id,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bic.wip_supply_type,
                   DECODE (rto_flag, 'Y', 2, bic.pick_components),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_subinventory,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_locator_id,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_locator_id, NULL )
                          ),
                   bic.operation_lead_time_percent,
                   x_rev_item_seq_id,
                   bic.cost_factor,
                   bic.operation_seq_num,
                   bic.component_item_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   bic.component_sequence_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.item_num,
                   --bic.component_quantity,
		   DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.component_quantity,
                          inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.component_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure)) Comp_qty,
                   bic.component_yield_factor,
                   bic.component_remarks,
                   -- R12 TTM ENH
                   CASE
                   -- The WHEN sequence is important
                   -- For When display option is set to 2 then what ever comps are target date we need to
                   -- take that
                   -- ECO conditions should be in sync with BomCopyStructureAM
                   -- for creating revised item by grouping based on effectivity
                   WHEN display_option = 2 AND bill_or_eco = 2
                     THEN x_effectivity_date
                   WHEN display_option = 2
                     THEN trgt_comps_eff_date
                   WHEN bill_or_eco = 1 -- Inline and explosion date is past
                     AND ( bic.effectivity_date < trgt_comps_eff_date AND rev_date < trgt_comps_eff_date )
                     -- Explosion in the Past and Effectivity Date is also in the past, then the components
                     -- which are past effective will be effective from trgt_comps_eff_date
                     THEN trgt_comps_eff_date
                   WHEN bill_or_eco = 1 -- Inline and explosion date is future
                     AND ( bic.effectivity_date = rev_date AND rev_date > trgt_comps_eff_date )
                     -- Explosion in the future and Effectivity Date is also in the future, then the components
                     -- which are effective at the explosion time alone will be effective from trgt_comps_eff_date
                     THEN trgt_comps_eff_date
                     -- Past effective components should be target data effective
                   WHEN bill_or_eco = 1
                     AND bic.effectivity_date < trgt_comps_eff_date
                    THEN trgt_comps_eff_date
                   ELSE
                     bic.effectivity_date
                   END AS effectivity_date,
                   x_e_change_notice,
                   -- Implementation date will be NULL for ECO flow and SYSDATE for inline copy
                   DECODE (bill_or_eco, 2, TO_DATE (NULL), SYSDATE),
                   CASE
                   -- For current never disable the components
                   WHEN display_option = 2
                     THEN TO_DATE (NULL)
                   -- Past disabled components will be copied with disable date as null
                   WHEN bill_or_eco = 2 AND ( bic.disable_date < x_effectivity_date )
                     THEN TO_DATE (NULL)
                   -- Past disabled components will be copied with disable date as null
                   WHEN bill_or_eco = 1 AND ( bic.disable_date < trgt_comps_eff_date )
                     THEN TO_DATE (NULL)
                   ELSE
                     -- Future disabled components should be disabled as per the disable date of component
                     bic.disable_date
                   END AS disable_date,
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15,
                   bic.planning_factor,
                   bic.quantity_related,
                   bic.so_basis,
                   bic.optional,
                   bic.mutually_exclusive_options,
                   bic.include_in_cost_rollup,
                   bic.check_atp,
                   msi.bom_item_type,
                   to_char(NULL) AS from_end_item_unit_number, -- Date Eff Bill will not have from_end_item_unit_numbers
                   to_char(NULL) AS to_end_item_unit_number, -- Date Eff Bill will not have to_end_item_unit_numbers
                   bic.optional_on_model,
                   --BUGFIX 2740820
                   bic.parent_bill_seq_id,                    --BUGFIX 2740820
                   bic.model_comp_seq_id,
                   --BUGFIX 2740820
                   bic.plan_level,                            --BUGFIX 2740820
                   bic.enforce_int_requirements,
                   -- Either Fixed or Floating rev, the components will be from when its created, current item rev
                   l_current_item_rev_id,
                   -- Minor rev is not supported. Populated the first minor rev
                   0,
                   bic.component_item_id,
                   to_org_id,
                   bic.auto_request_material,
                   -- Bug 3662214 : Added following 4 fields
                   bic.suggested_vendor_name,
                   bic.vendor_id,
                   bic.unit_price,
                   to_number(NULL) AS from_end_item_rev_id, -- From End Item Rev Ids won't be set for Date Eff Bill
                   to_number(NULL) AS to_end_item_rev_id, -- To End Item Rev Ids won't be set for Date Eff Bill
                   -- For Minor rev Ids
                   0 AS from_end_item_minor_rev_id,
                   0 AS to_end_item_minor_rev_id,
                   (
                      SELECT tmirb.revision_id
                        FROM mtl_item_revisions_b fmirb,
                             mtl_item_revisions_b tmirb
                       WHERE tmirb.inventory_item_id = bic.component_item_id
                         AND tmirb.organization_id = to_org_id
                         AND tmirb.revision = fmirb.revision
                         AND fmirb.revision_id = bic.component_item_revision_id
                   ) AS component_item_revision_id,
                   CASE
                   WHEN bic.component_item_revision_id IS NULL
                    THEN to_number(NULL)
                   ELSE
                   -- Minor revision is not supported
                    0
                   END AS component_minor_revision_id,
                   bic.basis_type,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                   -- For fixed rev copy the components as fixed rev
                     THEN l_to_item_rev_id
                   ELSE
                     to_number(NULL)
                   END AS to_object_revision_id,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                     THEN 0
                   ELSE
                     to_number(NULL)
                   END AS to_minor_revision_id
              FROM bom_components_b bic,
                   mtl_system_items msi,
		    MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = x_from_sequence_id
               AND bic.component_item_id = msi.inventory_item_id
               AND bic.component_item_id <> to_item_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND msi.organization_id = to_org_id
	       AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
	       AND AA.organization_id = from_org_id                 -- Added corresponding to Bug 6510185
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND ((base_item_flag = -1
                     AND itm_type = 4
                     AND msi.bom_item_type = 4
                    )
                    OR base_item_flag <> -1
                    OR itm_type <> 4
                   )
               AND ((bic.implementation_date IS NOT NULL)
                    OR (bic.implementation_date IS NULL
                        AND bic.change_notice = context_eco
                        AND ( bic.acd_type = 1 OR bic.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb
				   WHERE bcb.old_component_sequence_id = bic.component_sequence_id
					 AND bcb.change_notice = context_eco
					 AND bcb.acd_type = 3
					 AND bcb.effectivity_date <= trgt_comps_eff_date
					 AND bcb.implementation_date IS NULL
					 AND bcb.bill_sequence_id = bic.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bic.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND bic.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bic.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
				  );
         ELSIF ( ( l_from_eff_ctrl = 2 AND l_to_eff_ctrl = 2 ) -- Unit
                 OR ( l_from_eff_ctrl = 3 AND l_to_eff_ctrl = 3 ) -- Serial
                 ) THEN


	   INSERT INTO bom_components_b
                     (shipping_allowed,
                      required_to_ship,
                      required_for_revenue,
                      include_on_ship_docs,
                      include_on_bill_docs,
                      low_quantity,
                      high_quantity,
                      acd_type,
                      component_sequence_id,
                      old_component_sequence_id,
                      bill_sequence_id,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      wip_supply_type,
                      pick_components,
                      supply_subinventory,
                      supply_locator_id,
                      operation_lead_time_percent,
                      revised_item_sequence_id,
                      cost_factor,
                      operation_seq_num,
                      component_item_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      item_num,
                      component_quantity,
                      component_yield_factor,
                      component_remarks,
                      effectivity_date,
                      change_notice,
                      implementation_date,
                      disable_date,
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
                      planning_factor,
                      quantity_related,
                      so_basis,
                      optional,
                      mutually_exclusive_options,
                      include_in_cost_rollup,
                      check_atp,
                      bom_item_type,
                      from_end_item_unit_number,
                      to_end_item_unit_number,
                      optional_on_model,
                      --BUGFIX 2740820
                      parent_bill_seq_id,                     --BUGFIX 2740820
                      model_comp_seq_id,                      --BUGFIX 2740820
                      plan_level,
                      --BUGFIX 2740820
                      enforce_int_requirements,               --BUGFIX 2991472
                      from_object_revision_id,
                      from_minor_revision_id,
                      pk1_value,
                      pk2_value,
                      auto_request_material,
                      -- Bug 3662214 : Added following 4 fields
                      suggested_vendor_name,
                      vendor_id,
                      unit_price,
                      from_end_item_rev_id,
                      to_end_item_rev_id,
                      from_end_item_minor_rev_id,
                      to_end_item_minor_rev_id,
                      component_item_revision_id,
                      component_minor_revision_id,
                      basis_type,
                      to_object_revision_id,
                      to_minor_revision_id
                     )
            SELECT bic.shipping_allowed,
                   bic.required_to_ship,
                   bic.required_for_revenue,
                   bic.include_on_ship_docs,
                   bic.include_on_bill_docs,
		   --bic.low_quantity,    -- Commented for bug-6510185
                   --bic.high_quantity,   -- Commented for bug-6510185
  	           DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.low_quantity,
                          DECODE(BIC.low_quantity,null,null,              --Added this inner Deocde for Bug 6847530
			  inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.low_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure))) Comp_low_qty,
		   DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.high_quantity,
                          DECODE(BIC.high_quantity,null,null,             --Added this inner Deocde for Bug 6847530
			  inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.high_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure))) Comp_high_qty,
                   x_acd_type,
                   bom_inventory_components_s.NEXTVAL,
                   DECODE (x_acd_type,
                           NULL, NULL,
                           bom_inventory_components_s.CURRVAL
                          ),
                   to_sequence_id,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bic.wip_supply_type,
                   DECODE (rto_flag, 'Y', 2, bic.pick_components),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_subinventory,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_locator_id,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_locator_id, NULL )
                          ),
                   bic.operation_lead_time_percent,
                   x_rev_item_seq_id,
                   bic.cost_factor,
                   bic.operation_seq_num,
                   bic.component_item_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   bic.component_sequence_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.item_num,
                  --bic.component_quantity,
  	           DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.component_quantity,
                          inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.component_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure)) Comp_qty,
                   bic.component_yield_factor,
                   bic.component_remarks,
                   -- R12 TTM ENH
                   -- For Unit/Serial it eff date will be sysdate
                   sysdate AS effectivity_date,
                   x_e_change_notice,
                   -- Implementation date will be NULL for ECO flow and SYSDATE for inline copy
                   DECODE (bill_or_eco, 2, TO_DATE (NULL), SYSDATE),
                   -- For Unit/Serial Eff disable date will be null
                   to_date(NULL) AS disable_date,
                   -- Bug 4208139 Currently only CURRENT components are copied.(11.5.10-E)
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15,
                   bic.planning_factor,
                   bic.quantity_related,
                   bic.so_basis,
                   bic.optional,
                   bic.mutually_exclusive_options,
                   bic.include_in_cost_rollup,
                   --DECODE(atp_comp_flag, 'Y', CHECK_ATP, 2),  fixed bug 2249375
                   bic.check_atp,
                   msi.bom_item_type,
                   CASE
                   WHEN bic.from_end_item_unit_number IS NULL
                     THEN to_char(NULL)
                   -- ECO conditions should be in sync with BomCopyStructureAM
                   -- for creating revised item by grouping based on effectivity
                   WHEN display_option = 2 AND bill_or_eco = 2
                     THEN x_unit_number
                   WHEN display_option = 2
                     THEN trgt_comps_unit_number
                   WHEN bill_or_eco = 1 -- Inline and explosion unit number is smaller
                     AND ( bic.from_end_item_unit_number < trgt_comps_unit_number AND unit_number < trgt_comps_unit_number )
                     -- Explosion unit number is smaller and from_end_item_unit_number is also smaller, then the components
                     -- which are with smaller unit number effective will be effective from trgt_comps_unit_number
                     THEN trgt_comps_unit_number
                   WHEN bill_or_eco = 1 -- Inline explosion unit number is greater
                     AND ( bic.from_end_item_unit_number = unit_number AND unit_number > trgt_comps_unit_number )
                     -- Explosion unit number it greater and from_end_item_unit_number is also greater, then the components
                     -- which are effective on explosion unit number will be effective from trgt_comps_unit_number
                     THEN trgt_comps_unit_number
                     -- Past effective should be effective from the target unit number
                   WHEN bill_or_eco = 2
                    AND bic.from_end_item_unit_number < x_unit_number
                    THEN trgt_comps_unit_number
                   ELSE
                     bic.from_end_item_unit_number
                   END AS from_end_item_unit_number,
                   CASE
				   -- For current never disable components
                   WHEN display_option = 2
                     THEN to_char(NULL)
                   WHEN bill_or_eco = 2 AND ( bic.to_end_item_unit_number < x_unit_number )
                     -- Disabled components should be copied with to end item unit number as null
                     THEN to_char(NULL)
                   WHEN bill_or_eco = 1 AND ( bic.to_end_item_unit_number < trgt_comps_unit_number )
                     -- Disabled components should be copied with to end item unit number as null
                     THEN to_char(NULL)
                   ELSE
                     -- Future disabled components should be disabled as per the to_end_item_unit_number of component
                     bic.to_end_item_unit_number
                   END AS to_end_item_unit_number,
                   bic.optional_on_model,
                   --BUGFIX 2740820
                   bic.parent_bill_seq_id,                    --BUGFIX 2740820
                   bic.model_comp_seq_id,
                   --BUGFIX 2740820
                   bic.plan_level,                            --BUGFIX 2740820
                   bic.enforce_int_requirements,
                   -- Either Fixed or Floating rev, the components will be from when its created, current item rev
                   l_current_item_rev_id,
                   -- Minor rev is not supported. Populated the first minor rev
                   0,
                   bic.component_item_id,
                   to_org_id,
                   bic.auto_request_material,
                   -- Bug 3662214 : Added following 4 fields
                   bic.suggested_vendor_name,
                   bic.vendor_id,
                   bic.unit_price,
                   to_number(NULL) AS from_end_item_rev_id,
                   to_number(NULL) AS to_end_item_rev_id,
                   -- For Minor rev Ids
                   0 AS from_end_item_minor_rev_id,
                   0 AS to_end_item_minor_rev_id,
                   (
                     SELECT tmirb.revision_id
                       FROM mtl_item_revisions_b fmirb,
                            mtl_item_revisions_b tmirb
                      WHERE tmirb.inventory_item_id = bic.component_item_id
                        AND tmirb.organization_id = to_org_id
                        AND tmirb.revision = fmirb.revision
                        AND fmirb.revision_id = bic.component_item_revision_id
                   ) AS component_item_revision_id,
                   CASE
                   WHEN bic.component_item_revision_id IS NULL
                    THEN to_number(NULL)
                   ELSE
                   -- Minor revision is not supported
                    0
                   END AS component_minor_revision_id,
                   bic.basis_type,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                   -- For fixed rev copy the components as fixed rev
                     THEN l_to_item_rev_id
                   ELSE
                     to_number(NULL)
                   END AS to_object_revision_id,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                     THEN 0
                   ELSE
                     to_number(NULL)
                   END AS to_minor_revision_id
              FROM bom_components_b bic,
                   mtl_system_items msi,
		   MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = x_from_sequence_id
               AND bic.component_item_id = msi.inventory_item_id
               AND bic.component_item_id <> to_item_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND msi.organization_id = to_org_id
--              AND MSI.BOM_ENABLED_FLAG = 'Y'  Bug 3595979
               AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
	       AND AA.organization_id = from_org_id                 -- Added corresponding to Bug 6510185
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND ((base_item_flag = -1
                     AND itm_type = 4
                     AND msi.bom_item_type = 4
                    )
                    OR base_item_flag <> -1
                    OR itm_type <> 4
                   )
               AND ((bic.implementation_date IS NOT NULL)
                    OR (bic.implementation_date IS NULL
                        AND bic.change_notice = context_eco
                        AND ( bic.acd_type = 1 OR bic.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb
				   WHERE bcb.old_component_sequence_id = bic.component_sequence_id
					 AND bcb.change_notice = context_eco
					 AND bcb.acd_type = 3
					 AND bcb.effectivity_date <= trgt_comps_eff_date
					 AND bcb.implementation_date IS NULL
					 AND bcb.bill_sequence_id = bic.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bic.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND bic.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bic.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                         AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
				  );


         ELSIF l_from_eff_ctrl = 4 AND l_to_eff_ctrl = 4 THEN -- Rev - Rev


	   INSERT INTO bom_components_b
                     (shipping_allowed,
                      required_to_ship,
                      required_for_revenue,
                      include_on_ship_docs,
                      include_on_bill_docs,
                      low_quantity,
                      high_quantity,
                      acd_type,
                      component_sequence_id,
                      old_component_sequence_id,
                      bill_sequence_id,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      wip_supply_type,
                      pick_components,
                      supply_subinventory,
                      supply_locator_id,
                      operation_lead_time_percent,
                      revised_item_sequence_id,
                      cost_factor,
                      operation_seq_num,
                      component_item_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      item_num,
                      component_quantity,
                      component_yield_factor,
                      component_remarks,
                      effectivity_date,
                      change_notice,
                      implementation_date,
                      disable_date,
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
                      planning_factor,
                      quantity_related,
                      so_basis,
                      optional,
                      mutually_exclusive_options,
                      include_in_cost_rollup,
                      check_atp,
                      bom_item_type,
                      from_end_item_unit_number,
                      to_end_item_unit_number,
                      optional_on_model,
                      --BUGFIX 2740820
                      parent_bill_seq_id,                     --BUGFIX 2740820
                      model_comp_seq_id,                      --BUGFIX 2740820
                      plan_level,
                      --BUGFIX 2740820
                      enforce_int_requirements,               --BUGFIX 2991472
                      from_object_revision_id,
                      from_minor_revision_id,
                      pk1_value,
                      pk2_value,
                      auto_request_material,
                      -- Bug 3662214 : Added following 4 fields
                      suggested_vendor_name,
                      vendor_id,
                      unit_price,
                      from_end_item_rev_id,
                      to_end_item_rev_id,
                      from_end_item_minor_rev_id,
                      to_end_item_minor_rev_id,
                      component_item_revision_id,
                      component_minor_revision_id,
                      basis_type,
                      to_object_revision_id,
                      to_minor_revision_id
                     )
            SELECT bic.shipping_allowed,
                   bic.required_to_ship,
                   bic.required_for_revenue,
                   bic.include_on_ship_docs,
                   bic.include_on_bill_docs,
  	         --bic.low_quantity,    -- Commented for bug-6510185
                 --bic.high_quantity,   -- Commented for bug-6510185
	      DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
		     AA.primary_unit_of_measure,BIC.low_quantity,
	             DECODE(BIC.low_quantity,null,null,       --Added this inner Deocde for Bug 6847530
		     inv_convert.INV_UM_CONVERT(BIC.component_item_id,
		                                NULL,
			                        BIC.low_quantity,
				                NULL,
					        NULL,
						AA.primary_unit_of_measure,
		                                MSI.primary_unit_of_measure))) Comp_low_qty,
	      DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
		     AA.primary_unit_of_measure,BIC.high_quantity,
	             DECODE(BIC.high_quantity,null,null,             --Added this inner Deocde for Bug 6847530
		     inv_convert.INV_UM_CONVERT(BIC.component_item_id,
		                                NULL,
			                        BIC.high_quantity,
				                NULL,
					        NULL,
						AA.primary_unit_of_measure,
	                                        MSI.primary_unit_of_measure))) Comp_high_qty,

		   x_acd_type,
                   bom_inventory_components_s.NEXTVAL,
                   DECODE (x_acd_type,
                           NULL, NULL,
                           bom_inventory_components_s.CURRVAL
                          ),
                   to_sequence_id,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bic.wip_supply_type,
                   DECODE (rto_flag, 'Y', 2, bic.pick_components),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_subinventory,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_locator_id,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_locator_id, NULL )
                          ),
                   bic.operation_lead_time_percent,
                   x_rev_item_seq_id,
                   bic.cost_factor,
                   bic.operation_seq_num,
                   bic.component_item_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   bic.component_sequence_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.item_num,
                   --bic.component_quantity,
                   DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                         AA.primary_unit_of_measure,BIC.component_quantity,
                         inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                             NULL,
                                             BIC.component_quantity,
                                             NULL,
                                             NULL,
                                             AA.primary_unit_of_measure,
                                             MSI.primary_unit_of_measure)) Comp_qty,
                   bic.component_yield_factor,
                   bic.component_remarks,
                   -- R12 TTM ENH
                   -- For Rev Eff Structure the eff date will be sysdate
                   sysdate AS effectivity_date,
                   x_e_change_notice,
                   -- Implementation date will be NULL for ECO flow and SYSDATE for inline copy
                   DECODE (bill_or_eco, 2, TO_DATE (NULL), SYSDATE),
                   -- For Rev Eff structure the disable date will be null
                   to_date(NULL) AS disable_date,
                   -- Bug 4208139 Currently only CURRENT components are copied.(11.5.10-E)
                   --DECODE(bill_or_eco,2,to_date(NULL),GREATEST(IMPLEMENTATION_DATE,SYSDATE)),
                   --DECODE(bill_or_eco,2,to_date(NULL), DECODE(GREATEST(DISABLE_DATE,SYSDATE),SYSDATE, NULL, DISABLE_DATE)),
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15,
                   bic.planning_factor,
                   bic.quantity_related,
                   bic.so_basis,
                   bic.optional,
                   bic.mutually_exclusive_options,
                   bic.include_in_cost_rollup,
                   bic.check_atp,
                   msi.bom_item_type,
                   to_char(NULL) AS from_end_item_unit_number,
                   to_char(NULL) AS to_end_item_unit_number,
                   bic.optional_on_model,
                   --BUGFIX 2740820
                   bic.parent_bill_seq_id,                    --BUGFIX 2740820
                   bic.model_comp_seq_id,
                   --BUGFIX 2740820
                   bic.plan_level,                            --BUGFIX 2740820
                   bic.enforce_int_requirements,
                   -- Either Fixed or Floating rev, the components will be from when its created, current item rev
                   l_current_item_rev_id,
                   -- Minor rev is not supported. Populated the first minor rev
                   0,
                   bic.component_item_id,
                   to_org_id,
                   bic.auto_request_material,
                   -- Bug 3662214 : Added following 4 fields
                   bic.suggested_vendor_name,
                   bic.vendor_id,
                   bic.unit_price,
                   CASE
                   WHEN bic.from_end_item_rev_id IS NULL
                     THEN NULL
                   -- ECO conditions should be in sync with BomCopyStructureAM
                   -- for creating revised item by grouping based on effectivity
                   WHEN display_option = 2 AND bill_or_eco = 2
                     THEN eco_end_item_rev_id
                   WHEN display_option = 2
                     THEN trgt_comps_end_item_rev_id
                   WHEN bill_or_eco = 1 -- Inline and explosion rev is past or smaller
                     -- Explosion rev is smaller and from_end_item_rev is also smaller, then the components
                     -- which are with smaller revision effective will be effective from eco_end_item_rev_id
                    AND bic.from_end_item_rev_id IS NOT NULL
                    AND trgt_comps_end_item_rev_id IS NOT NULL
                    AND p_end_item_rev_id IS NOT NULL
                    AND (  (
                            SELECT REVISION
                              FROM MTL_ITEM_REVISIONS_B
                             WHERE REVISION_ID = bic.from_end_item_rev_id
                            ) < (
                            SELECT REVISION
                              FROM MTL_ITEM_REVISIONS_B
                             WHERE REVISION_ID = trgt_comps_end_item_rev_id
                            )
                            AND
                           (
                            SELECT REVISION
                              FROM MTL_ITEM_REVISIONS_B
                             WHERE REVISION_ID = p_end_item_rev_id
                            ) < (
                            SELECT REVISION
                              FROM MTL_ITEM_REVISIONS_B
                             WHERE REVISION_ID = trgt_comps_end_item_rev_id
                            )
                        )
                    THEN trgt_comps_end_item_rev_id
                   WHEN bill_or_eco = 1 -- Inline and explosion rev is future and greater
				    AND bic.from_end_item_rev_id IS NOT NULL
                     -- Explosion rev is greater and from_end_item_rev is also greater, then the components
                     -- which are effective on exploded revision will be effective from trgt_comps_end_item_rev_id
                    AND trgt_comps_end_item_rev_id IS NOT NULL
                    AND p_end_item_rev_id IS NOT NULL
                    AND (  (
                            SELECT REVISION
                              FROM MTL_ITEM_REVISIONS_B
                             WHERE REVISION_ID = bic.from_end_item_rev_id
                            ) = (
                            SELECT REVISION
                              FROM MTL_ITEM_REVISIONS_B
                             WHERE REVISION_ID = trgt_comps_end_item_rev_id
                            )
                            AND
                           (
                            SELECT REVISION
                              FROM MTL_ITEM_REVISIONS_B
                             WHERE REVISION_ID = p_end_item_rev_id
                            ) > (
                            SELECT REVISION
                              FROM MTL_ITEM_REVISIONS_B
                             WHERE REVISION_ID = trgt_comps_end_item_rev_id
                            )
                        )
                    THEN trgt_comps_end_item_rev_id
                    -- Past Revision Effective should be effective from target revision
                    WHEN bill_or_eco = 1
                     AND eco_end_item_rev_id IS NOT NULL
                     AND (
                          SELECT REVISION
                            FROM MTL_ITEM_REVISIONS_B
                           WHERE REVISION_ID = bic.from_end_item_rev_id
                        ) < (
                          SELECT REVISION
                            FROM MTL_ITEM_REVISIONS_B
                           WHERE REVISION_ID = eco_end_item_rev_id
                         )
                    THEN trgt_comps_end_item_rev_id
					ELSE
                      NVL((
                        SELECT tmirb.revision_id
                          FROM mtl_item_revisions_b fmirb,
                               mtl_item_revisions_b tmirb
                         WHERE tmirb.inventory_item_id = to_item_id
                           AND tmirb.organization_id = to_org_id
                           AND tmirb.revision = fmirb.revision
                           AND fmirb.revision_id = bic.from_end_item_rev_id
                      ),trgt_comps_end_item_rev_id)
                   END AS from_end_item_rev_id,
                   CASE
                   WHEN ( bic.to_end_item_rev_id IS NULL OR display_option = 2)
                     THEN NULL
                    WHEN bill_or_eco = 1
                     AND
                       (
                        SELECT REVISION
                          FROM MTL_ITEM_REVISIONS_B
                         WHERE REVISION_ID = bic.to_end_item_rev_id
                       ) <
                       (
                        SELECT REVISION
                          FROM MTL_ITEM_REVISIONS_B
                         WHERE REVISION_ID = trgt_comps_end_item_rev_id
                       )
                     THEN NULL
                   ELSE
                     (
                       SELECT tmirb.revision_id
                         FROM mtl_item_revisions_b fmirb,
                              mtl_item_revisions_b tmirb
                        WHERE tmirb.inventory_item_id = to_item_id
                          AND tmirb.organization_id = to_org_id
                          AND tmirb.revision = fmirb.revision
                          AND fmirb.revision_id = bic.to_end_item_rev_id
                     )
                   -- When No Item Rev Exists for the to item then populate to item rev as also null
                   END AS to_end_item_rev_id,
                   -- For Minor rev Ids
                   0 AS from_end_item_minor_rev_id,
                   0 AS to_end_item_minor_rev_id,
                   (
                     SELECT tmirb.revision_id
                       FROM mtl_item_revisions_b fmirb,
                            mtl_item_revisions_b tmirb
                      WHERE tmirb.inventory_item_id = bic.component_item_id
                        AND tmirb.organization_id = to_org_id
                        AND tmirb.revision = fmirb.revision
                        AND fmirb.revision_id = bic.component_item_revision_id
                   ) AS component_item_revision_id,
                   CASE
                   WHEN bic.component_item_revision_id IS NULL
                    THEN to_number(NULL)
                   ELSE
                   -- Minor revision is not supported
                    0
                   END AS component_minor_revision_id,
                   bic.basis_type,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                   -- For fixed rev copy the components as fixed rev
                     THEN l_to_item_rev_id
                   ELSE
                     to_number(NULL)
                   END AS to_object_revision_id,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                     THEN 0
                   ELSE
                     to_number(NULL)
                   END AS to_minor_revision_id
              FROM bom_components_b bic,
                   mtl_system_items msi,
 		   MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = x_from_sequence_id
               AND bic.component_item_id = msi.inventory_item_id
               AND bic.component_item_id <> to_item_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND msi.organization_id = to_org_id
       	       AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
               AND AA.organization_id = from_org_id                 -- Added corresponding to Bug 6510185
--              AND MSI.BOM_ENABLED_FLAG = 'Y'  Bug 3595979
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND ((base_item_flag = -1
                     AND itm_type = 4
                     AND msi.bom_item_type = 4
                    )
                    OR base_item_flag <> -1
                    OR itm_type <> 4
                   )
               AND ((bic.implementation_date IS NOT NULL)
                    OR (bic.implementation_date IS NULL
                        AND bic.change_notice = context_eco
                        AND ( bic.acd_type = 1 OR bic.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb
				   WHERE bcb.old_component_sequence_id = bic.component_sequence_id
					 AND bcb.change_notice = context_eco
					 AND bcb.acd_type = 3
					 AND bcb.effectivity_date <= trgt_comps_eff_date
					 AND bcb.implementation_date IS NULL
					 AND bcb.bill_sequence_id = bic.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bic.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND bic.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bic.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
				  );
         ELSIF l_from_eff_ctrl = 4 AND l_to_eff_ctrl = 1 THEN -- Rev - Date



	   INSERT INTO bom_components_b
                     (shipping_allowed,
                      required_to_ship,
                      required_for_revenue,
                      include_on_ship_docs,
                      include_on_bill_docs,
                      low_quantity,
                      high_quantity,
                      acd_type,
                      component_sequence_id,
                      old_component_sequence_id,
                      bill_sequence_id,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      wip_supply_type,
                      pick_components,
                      supply_subinventory,
                      supply_locator_id,
                      operation_lead_time_percent,
                      revised_item_sequence_id,
                      cost_factor,
                      operation_seq_num,
                      component_item_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      item_num,
                      component_quantity,
                      component_yield_factor,
                      component_remarks,
                      effectivity_date,
                      change_notice,
                      implementation_date,
                      disable_date,
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
                      planning_factor,
                      quantity_related,
                      so_basis,
                      optional,
                      mutually_exclusive_options,
                      include_in_cost_rollup,
                      check_atp,
                      bom_item_type,
                      from_end_item_unit_number,
                      to_end_item_unit_number,
                      optional_on_model,
                      --BUGFIX 2740820
                      parent_bill_seq_id,                     --BUGFIX 2740820
                      model_comp_seq_id,                      --BUGFIX 2740820
                      plan_level,
                      --BUGFIX 2740820
                      enforce_int_requirements,               --BUGFIX 2991472
                      from_object_revision_id,
                      from_minor_revision_id,
                      pk1_value,
                      pk2_value,
                      auto_request_material,
                      -- Bug 3662214 : Added following 4 fields
                      suggested_vendor_name,
                      vendor_id,
                      unit_price,
                      from_end_item_rev_id,
                      to_end_item_rev_id,
                      from_end_item_minor_rev_id,
                      to_end_item_minor_rev_id,
                      component_item_revision_id,
                      component_minor_revision_id,
                      basis_type,
                      to_object_revision_id,
                      to_minor_revision_id
                     )
            SELECT bic.shipping_allowed,
                   bic.required_to_ship,
                   bic.required_for_revenue,
                   bic.include_on_ship_docs,
                   bic.include_on_bill_docs,
                   --bic.low_quantity,
                   --bic.high_quantity,
  		    DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
	             AA.primary_unit_of_measure,BIC.low_quantity,
		     DECODE(BIC.low_quantity,null,null,                    --Added this inner Deocde for Bug 6847530
		     inv_convert.INV_UM_CONVERT(BIC.component_item_id,
			                        NULL,
				                BIC.low_quantity,
					        NULL,
						NULL,
	                                        AA.primary_unit_of_measure,
		                                MSI.primary_unit_of_measure))) Comp_low_qty,
	            DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
		     AA.primary_unit_of_measure,BIC.high_quantity,
	             DECODE(BIC.high_quantity,null,null,                   --Added this inner Deocde for Bug 6847530
		     inv_convert.INV_UM_CONVERT(BIC.component_item_id,
		                                NULL,
			                        BIC.high_quantity,
				                NULL,
					        NULL,
						AA.primary_unit_of_measure,
	                                        MSI.primary_unit_of_measure))) Comp_high_qty,
                   x_acd_type,
                   bom_inventory_components_s.NEXTVAL,
                   DECODE (x_acd_type,
                           NULL, NULL,
                           bom_inventory_components_s.CURRVAL
                          ),
                   to_sequence_id,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bic.wip_supply_type,
                   DECODE (rto_flag, 'Y', 2, bic.pick_components),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_subinventory,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_locator_id,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_locator_id, NULL )
                          ),
                   bic.operation_lead_time_percent,
                   x_rev_item_seq_id,
                   bic.cost_factor,
                   bic.operation_seq_num,
                   bic.component_item_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   bic.component_sequence_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.item_num,
                 --  bic.component_quantity,
		 DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
		      AA.primary_unit_of_measure,BIC.component_quantity,
	              inv_convert.INV_UM_CONVERT(BIC.component_item_id,
			                         NULL,
				                 BIC.component_quantity,
					         NULL,
	                                         NULL,
						 AA.primary_unit_of_measure,
		                                 MSI.primary_unit_of_measure)) Comp_qty,
                   bic.component_yield_factor,
                   bic.component_remarks,
                   -- R12 TTM ENH
                   CASE
                   -- The WHEN sequence is important
                   -- For When display option is set to 2 then what ever comps are targer date we need to
                   -- take that
                   -- ECO conditions should be in sync with BomCopyStructureAM
                   -- for creating revised item by grouping based on effectivity
                   WHEN display_option = 2 AND bill_or_eco = 2
                     THEN x_effectivity_date
                   WHEN display_option = 2
                     THEN trgt_comps_eff_date
                   -- Rev to Date conversion with current and future option
                   -- Convert the dates based on from item's revision
                   WHEN bill_or_eco = 1 -- Inline and explosion date is past
                     AND bic.from_end_item_rev_id IS NOT NULL
                     AND p_end_item_rev_id IS NOT NULL
                     AND (
                          (
                            SELECT fmirb.effectivity_date
                              FROM mtl_item_revisions_b fmirb
                             WHERE fmirb.revision_id = bic.from_end_item_rev_id
                           )  < trgt_comps_eff_date
                          AND (
                               SELECT fmirb.effectivity_date
                                 FROM mtl_item_revisions_b fmirb
                                WHERE fmirb.revision_id = p_end_item_rev_id
                              ) < trgt_comps_eff_date
                          )
                     -- Explosion in the Past and Effectivity Date is also in the past, then the components
                     -- which are past effective will be effective from trgt_comps_eff_date
                     THEN trgt_comps_eff_date
                   WHEN bill_or_eco = 1 -- Inline and explosion date is future
                     AND bic.from_end_item_rev_id IS NOT NULL
                     AND p_end_item_rev_id IS NOT NULL
                     AND bic.from_end_item_rev_id = p_end_item_rev_id -- Future Exploded Rev
                     AND (
                               SELECT fmirb.effectivity_date
                                 FROM mtl_item_revisions_b fmirb
                                WHERE fmirb.revision_id = p_end_item_rev_id
                         ) > trgt_comps_eff_date
                     -- Explosion in the future and Effectivity Rev is also in the future, then the components
                     -- which are effective at the explosion rev alone will be effective from trgt_comps_eff_date
                     THEN trgt_comps_eff_date
                     -- Past effective components should be target data effective
                   WHEN bill_or_eco = 1
                     AND bic.from_end_item_rev_id IS NOT NULL
                     AND (
                          SELECT fmirb.effectivity_date
                            FROM mtl_item_revisions_b fmirb
                           WHERE fmirb.revision_id = bic.from_end_item_rev_id
                          ) < trgt_comps_eff_date
                    THEN trgt_comps_eff_date
                   ELSE
				    (
                     SELECT fmirb.effectivity_date
                       FROM mtl_item_revisions_b fmirb
                      WHERE fmirb.revision_id = bic.from_end_item_rev_id
                    )
                   END AS effectivity_date,
                   x_e_change_notice,
                   -- Implementation date will be NULL for ECO flow and SYSDATE for inline copy
                   DECODE (bill_or_eco, 2, TO_DATE (NULL), SYSDATE),
                   CASE
                   WHEN ( bic.to_end_item_rev_id IS NULL OR display_option = 2 )
                     THEN TO_DATE (NULL)
                   -- Past disabled components will be copied with disable date as null
                   WHEN bill_or_eco = 2
                     AND (
                          ( SELECT fmirb.effectivity_date
                              FROM mtl_item_revisions_b fmirb
                             WHERE fmirb.revision_id = bic.to_end_item_rev_id
                           ) < x_effectivity_date
                         )
                     THEN TO_DATE (NULL)
                   -- Past disabled components will be copied with disable date as null
                   WHEN bill_or_eco = 1
                    AND (
                         ( SELECT fmirb.effectivity_date
                             FROM mtl_item_revisions_b fmirb
                            WHERE fmirb.revision_id = bic.to_end_item_rev_id
                         ) < trgt_comps_eff_date
                        )
                     THEN TO_DATE (NULL)
                     -- Future disabled components should be disabled as per the disable date of component
                   ELSE
				    (
                     SELECT fmirb.effectivity_date
                       FROM mtl_item_revisions_b fmirb
                      WHERE fmirb.revision_id = bic.to_end_item_rev_id
                    )
                   END AS disable_date,
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15,
                   bic.planning_factor,
                   bic.quantity_related,
                   bic.so_basis,
                   bic.optional,
                   bic.mutually_exclusive_options,
                   bic.include_in_cost_rollup,
                   bic.check_atp,
                   msi.bom_item_type,
                   to_char(NULL) AS from_end_item_unit_number, -- Date Eff Bill will not have from_end_item_unit_numbers
                   to_char(NULL) AS to_end_item_unit_number, -- Date Eff Bill will not have to_end_item_unit_numbers
                   bic.optional_on_model,
                   --BUGFIX 2740820
                   bic.parent_bill_seq_id,                    --BUGFIX 2740820
                   bic.model_comp_seq_id,
                   --BUGFIX 2740820
                   bic.plan_level,                            --BUGFIX 2740820
                   bic.enforce_int_requirements,
                   -- Either Fixed or Floating rev, the components will be from when its created, current item rev
                   l_current_item_rev_id,
                   -- Minor rev is not supported. Populated the first minor rev
                   0,
                   bic.component_item_id,
                   to_org_id,
                   bic.auto_request_material,
                   -- Bug 3662214 : Added following 4 fields
                   bic.suggested_vendor_name,
                   bic.vendor_id,
                   bic.unit_price,
                   to_number(NULL) AS from_end_item_rev_id, -- From End Item Rev Ids won't be set for Date Eff Bill
                   to_number(NULL) AS to_end_item_rev_id, -- To End Item Rev Ids won't be set for Date Eff Bill
                   -- For Minor rev Ids
                   0 AS from_end_item_minor_rev_id,
                   0 AS to_end_item_minor_rev_id,
                   (
                     SELECT tmirb.revision_id
                       FROM mtl_item_revisions_b fmirb,
                            mtl_item_revisions_b tmirb
                      WHERE tmirb.inventory_item_id = bic.component_item_id
                        AND tmirb.organization_id = to_org_id
                        AND tmirb.revision = fmirb.revision
                        AND fmirb.revision_id = bic.component_item_revision_id
                   ) AS component_item_revision_id,
                   CASE
                   WHEN bic.component_item_revision_id IS NULL
                    THEN to_number(NULL)
                   ELSE
                   -- Minor revision is not supported
                    0
                   END AS component_minor_revision_id,
                   bic.basis_type,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                   -- For fixed rev copy the components as fixed rev
                     THEN l_to_item_rev_id
                   ELSE
                     to_number(NULL)
                   END AS to_object_revision_id,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                     THEN 0
                   ELSE
                     to_number(NULL)
                   END AS to_minor_revision_id
              FROM bom_components_b bic,
                   mtl_system_items msi,
		   MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = x_from_sequence_id
               AND bic.component_item_id = msi.inventory_item_id
               AND bic.component_item_id <> to_item_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND msi.organization_id = to_org_id
       	       AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
               AND AA.organization_id = from_org_id                 -- Added corresponding to Bug 6510185
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND ((base_item_flag = -1
                     AND itm_type = 4
                     AND msi.bom_item_type = 4
                    )
                    OR base_item_flag <> -1
                    OR itm_type <> 4
                   )
               AND ((bic.implementation_date IS NOT NULL)
                    OR (bic.implementation_date IS NULL
                        AND bic.change_notice = context_eco
                        AND ( bic.acd_type = 1 OR bic.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb
				   WHERE bcb.old_component_sequence_id = bic.component_sequence_id
					 AND bcb.change_notice = context_eco
					 AND bcb.acd_type = 3
					 AND bcb.effectivity_date <= trgt_comps_eff_date
					 AND bcb.implementation_date IS NULL
					 AND bcb.bill_sequence_id = bic.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bic.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND bic.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bic.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
				  );
         ELSIF l_from_eff_ctrl = 1 AND l_to_eff_ctrl = 4 THEN -- Date - Rev


	   INSERT INTO bom_components_b
                     (shipping_allowed,
                      required_to_ship,
                      required_for_revenue,
                      include_on_ship_docs,
                      include_on_bill_docs,
                      low_quantity,
                      high_quantity,
                      acd_type,
                      component_sequence_id,
                      old_component_sequence_id,
                      bill_sequence_id,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      wip_supply_type,
                      pick_components,
                      supply_subinventory,
                      supply_locator_id,
                      operation_lead_time_percent,
                      revised_item_sequence_id,
                      cost_factor,
                      operation_seq_num,
                      component_item_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      item_num,
                      component_quantity,
                      component_yield_factor,
                      component_remarks,
                      effectivity_date,
                      change_notice,
                      implementation_date,
                      disable_date,
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
                      planning_factor,
                      quantity_related,
                      so_basis,
                      optional,
                      mutually_exclusive_options,
                      include_in_cost_rollup,
                      check_atp,
                      bom_item_type,
                      from_end_item_unit_number,
                      to_end_item_unit_number,
                      optional_on_model,
                      --BUGFIX 2740820
                      parent_bill_seq_id,                     --BUGFIX 2740820
                      model_comp_seq_id,                      --BUGFIX 2740820
                      plan_level,
                      --BUGFIX 2740820
                      enforce_int_requirements,               --BUGFIX 2991472
--            COMPONENT_ITEM_REVISION_ID,
                      from_object_revision_id,
                      from_minor_revision_id,
--          FROM_BILL_REVISION_ID,
                      pk1_value,
                      pk2_value,
                      auto_request_material,
                      -- Bug 3662214 : Added following 4 fields
                      suggested_vendor_name,
                      vendor_id,
                      unit_price,
                      from_end_item_rev_id,
                      to_end_item_rev_id,
                      from_end_item_minor_rev_id,
                      to_end_item_minor_rev_id,
                      component_item_revision_id,
                      component_minor_revision_id,
                      basis_type,
                      to_object_revision_id,
                      to_minor_revision_id
                     )
            SELECT bic.shipping_allowed,
                   bic.required_to_ship,
                   bic.required_for_revenue,
                   bic.include_on_ship_docs,
                   bic.include_on_bill_docs,
                --   bic.low_quantity,
                --  bic.high_quantity,
		  DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                         AA.primary_unit_of_measure,BIC.low_quantity,
	                 DECODE(BIC.low_quantity,null,null,           --Added this inner Deocde for Bug 6847530
			 inv_convert.INV_UM_CONVERT(BIC.component_item_id,
		                                NULL,
			                        BIC.low_quantity,
				                NULL,
					        NULL,
						AA.primary_unit_of_measure,
	                                        MSI.primary_unit_of_measure))) Comp_low_qty,
                 DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
	             AA.primary_unit_of_measure,BIC.high_quantity,
		     DECODE(BIC.high_quantity,null,null,              --Added this inner Deocde for Bug 6847530
		     inv_convert.INV_UM_CONVERT(BIC.component_item_id,
			                        NULL,
				                BIC.high_quantity,
					        NULL,
						NULL,
	                                        AA.primary_unit_of_measure,
		                                MSI.primary_unit_of_measure))) Comp_high_qty,
                   x_acd_type,
                   bom_inventory_components_s.NEXTVAL,
                   DECODE (x_acd_type,
                           NULL, NULL,
                           bom_inventory_components_s.CURRVAL
                          ),
                   to_sequence_id,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bic.wip_supply_type,
                   DECODE (rto_flag, 'Y', 2, bic.pick_components),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_subinventory,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_locator_id,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_locator_id, NULL )
                          ),
                   bic.operation_lead_time_percent,
                   x_rev_item_seq_id,
                   bic.cost_factor,
                   bic.operation_seq_num,
                   bic.component_item_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   bic.component_sequence_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.item_num,
                   --bic.component_quantity,
  	           DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
	              AA.primary_unit_of_measure,BIC.component_quantity,
		      inv_convert.INV_UM_CONVERT(BIC.component_item_id,
			                         NULL,
				                 BIC.component_quantity,
					         NULL,
						 NULL,
		                                 AA.primary_unit_of_measure,
			                         MSI.primary_unit_of_measure)) Comp_qty,
                   bic.component_yield_factor,
                   bic.component_remarks,
                   -- R12 TTM ENH
                   -- For Rev Eff Structure the eff date will be sysdate
                   sysdate AS effectivity_date,
                   x_e_change_notice,
                   -- Implementation date will be NULL for ECO flow and SYSDATE for inline copy
                   DECODE (bill_or_eco, 2, TO_DATE (NULL), SYSDATE),
                   -- For Rev Eff structure the disable date will be null
                   to_date(NULL) AS disable_date,
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15,
                   bic.planning_factor,
                   bic.quantity_related,
                   bic.so_basis,
                   bic.optional,
                   bic.mutually_exclusive_options,
                   bic.include_in_cost_rollup,
                   bic.check_atp,
                   msi.bom_item_type,
                   to_char(NULL) AS from_end_item_unit_number,
                   to_char(NULL) AS to_end_item_unit_number,
                   bic.optional_on_model,
                   --BUGFIX 2740820
                   bic.parent_bill_seq_id,                    --BUGFIX 2740820
                   bic.model_comp_seq_id,
                   --BUGFIX 2740820
                   bic.plan_level,                            --BUGFIX 2740820
                   bic.enforce_int_requirements,
                   -- Either Fixed or Floating rev, the components will be from when its created, current item rev
                   l_current_item_rev_id,
                   -- Minor rev is not supported. Populated the first minor rev
                   0,
                   bic.component_item_id,
                   to_org_id,
                   bic.auto_request_material,
                   -- Bug 3662214 : Added following 4 fields
                   bic.suggested_vendor_name,
                   bic.vendor_id,
                   bic.unit_price,
                   CASE
                   -- ECO conditions should be in sync with BomCopyStructureAM
                   -- for creating revised item by grouping based on effectivity
                   WHEN display_option = 2 AND bill_or_eco = 2
                     THEN eco_end_item_rev_id
                   WHEN display_option = 2
                     THEN trgt_comps_end_item_rev_id
                   WHEN bill_or_eco = 1 -- Inline and explosion rev is past or smaller
                     -- Explosion Date is past
                     -- which are with smaller revision effective will be effective from eco_end_item_rev_id
                    AND EXISTS
                          (
                            SELECT tmirb.REVISION
                              FROM MTL_ITEM_REVISIONS_B tmirb
                             WHERE tmirb.REVISION_ID = trgt_comps_end_item_rev_id
                               AND tmirb.revision > get_current_item_rev(from_item_id, from_org_id, bic.effectivity_date)
                          )
                     AND EXISTS
                       (
                           SELECT tmirb.REVISION
                             FROM MTL_ITEM_REVISIONS_B tmirb
                            WHERE tmirb.REVISION_ID = trgt_comps_end_item_rev_id
                              AND tmirb.revision > get_current_item_rev(from_item_id, from_org_id, rev_date)
                          )
                    THEN trgt_comps_end_item_rev_id
                   WHEN bill_or_eco = 1 -- Inline and explosion Date is future
                     -- Explosion rev is greater and from_end_item_rev is also greater, then the components
                     -- which are effective on exploded revision will be effective from trgt_comps_end_item_rev_id
                    AND trgt_comps_end_item_rev_id IS NOT NULL
                    AND bic.effectivity_date = rev_date
                    AND EXISTS
                     (
                       SELECT tmirb.REVISION
                         FROM MTL_ITEM_REVISIONS_B tmirb
                        WHERE tmirb.REVISION_ID = trgt_comps_end_item_rev_id
                          AND tmirb.revision < get_current_item_rev(from_item_id, from_org_id, rev_date)
                     )
                    THEN trgt_comps_end_item_rev_id
                    -- Past Effective should be effective from target revision
                    WHEN bill_or_eco = 1
                     AND EXISTS
                      (
                        SELECT tmirb.REVISION
                          FROM MTL_ITEM_REVISIONS_B tmirb
                            WHERE tmirb.REVISION_ID = trgt_comps_end_item_rev_id
                              AND tmirb.revision > get_current_item_rev(from_item_id, from_org_id, bic.effectivity_date)
                       )
                    THEN trgt_comps_end_item_rev_id
                   ELSE
                    (
                     SELECT tmirb.revision_id
                       FROM mtl_item_revisions_b tmirb
                      WHERE tmirb.inventory_item_id = to_item_id
                        AND tmirb.organization_id = to_org_id
                        AND tmirb.revision = get_current_item_rev(from_item_id, from_org_id, bic.effectivity_date)
                    )
                   END AS from_end_item_rev_id,
                   CASE
                    WHEN ( bic.disable_date IS NULL OR display_option = 2)
                     THEN to_number(NULL)
                    WHEN bill_or_eco = 1
                     AND bic.disable_date IS NOT NULL
                     AND EXISTS
                         (
                            SELECT tmirb.revision_id
                              FROM mtl_item_revisions_b tmirb
                             WHERE tmirb.inventory_item_id = to_item_id
                               AND tmirb.organization_id = to_org_id
                               AND tmirb.revision = get_current_item_rev( from_item_id, from_org_id, bic.disable_date)
                         )
                     AND EXISTS
                           (
                             SELECT mirb.REVISION
                               FROM MTL_ITEM_REVISIONS_B mirb
                              WHERE mirb.REVISION_ID = trgt_comps_end_item_rev_id
                                AND mirb.revision > get_current_item_rev( from_item_id, from_org_id, bic.disable_date)
                            )
                        THEN to_number(NULL)
                    WHEN
                       bic.disable_date IS NOT NULL
                     THEN
                       (
                          SELECT tmirb.revision_id
                            FROM mtl_item_revisions_b tmirb
                           WHERE tmirb.inventory_item_id = to_item_id
                             AND tmirb.organization_id = to_org_id
                             AND tmirb.revision = get_current_item_rev( from_item_id, from_org_id, bic.disable_date)
                        )
                   -- When No Item Rev Exists for the to item then populate to item rev as also null
                   ELSE
                     to_number(NULL)
                   END AS to_end_item_rev_id,
                   -- For Minor rev Ids
                   0 AS from_end_item_minor_rev_id,
                   0 AS to_end_item_minor_rev_id,
                   (
                     SELECT tmirb.revision_id
                       FROM mtl_item_revisions_b fmirb,
                            mtl_item_revisions_b tmirb
                      WHERE tmirb.inventory_item_id = bic.component_item_id
                        AND tmirb.organization_id = to_org_id
                        AND tmirb.revision = fmirb.revision
                        AND fmirb.revision_id = bic.component_item_revision_id
                   ) AS component_item_revision_id,
                   CASE
                   WHEN bic.component_item_revision_id IS NULL
                    THEN to_number(NULL)
                   ELSE
                   -- Minor revision is not supported
                    0
                   END AS component_minor_revision_id,
                   bic.basis_type,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                   -- For fixed rev copy the components as fixed rev
                     THEN l_to_item_rev_id
                   ELSE
                     to_number(NULL)
                   END AS to_object_revision_id,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                     THEN 0
                   ELSE
                     to_number(NULL)
                   END AS to_minor_revision_id
              FROM bom_components_b bic,
                   mtl_system_items msi,
		   MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = x_from_sequence_id
               AND bic.component_item_id = msi.inventory_item_id
               AND bic.component_item_id <> to_item_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND msi.organization_id = to_org_id
	       AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
               AND AA.organization_id = from_org_id                 -- Added corresponding to Bug 6510185

--              AND MSI.BOM_ENABLED_FLAG = 'Y'  Bug 3595979
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND ((base_item_flag = -1
                     AND itm_type = 4
                     AND msi.bom_item_type = 4
                    )
                    OR base_item_flag <> -1
                    OR itm_type <> 4
                   )
               AND ((bic.implementation_date IS NOT NULL)
                    OR (bic.implementation_date IS NULL
                        AND bic.change_notice = context_eco
                        AND ( bic.acd_type = 1 OR bic.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb
				   WHERE bcb.old_component_sequence_id = bic.component_sequence_id
					 AND bcb.change_notice = context_eco
					 AND bcb.acd_type = 3
					 AND bcb.effectivity_date <= trgt_comps_eff_date
					 AND bcb.implementation_date IS NULL
					 AND bcb.bill_sequence_id = bic.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bic.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND bic.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bic.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
				  );
         END IF;


         --Turn on the trigger BOMTBICX
         bom_globals.g_skip_bomtbicx := 'N';

         /*
         --find list of actually copied comps
         l_comp_ctr := 1;

         FOR j IN 1 .. copy_comps_arr.COUNT
         LOOP
            l_copied_comp_seq.EXTEND ();
            l_copied_comp_item_id.EXTEND ();
            l_copied_op_seq_num.EXTEND ();
            l_copied_comp_seq (l_comp_ctr) := -1;
            l_copied_comp_item_id (l_comp_ctr) := -1;
            l_copied_op_seq_num (l_comp_ctr) := -1;

            OPEN get_copied_comps (copy_comps_arr (j),
                                   display_option,
                                   direction,
                                   x_unit_assembly,
                                   itm_type,
                                   base_item_flag,
                                   x_from_sequence_id,
                                   to_item_id,
                                   to_org_id,
                                   rev_date,
                                   unit_number
                                  );

            --if get_copied_comps%rowcount > 0 then
            FETCH get_copied_comps
             INTO l_copied_comp_seq (l_comp_ctr),
                  l_copied_comp_item_id (l_comp_ctr),
                  l_copied_op_seq_num (l_comp_ctr);

            --end if;
            IF l_copied_comp_seq (l_comp_ctr) <> -1
            THEN
               l_comp_ctr := l_comp_ctr + 1;
            END IF;

            --this should take care of the no_data_found
            CLOSE get_copied_comps;
         END LOOP;

         --We have a contiguous list of all copied comps. Now get the destn str components.
         FOR i IN 1 .. l_comp_ctr - 1
         LOOP
            l_mapped_comp_seq.EXTEND ();

            OPEN get_mapped_components (to_sequence_id,
                                        l_copied_comp_item_id (i),
                                        l_copied_op_seq_num (i)
                                       );

            --          if get_mapped_components%rowcount > 0 then
            FETCH get_mapped_components
             INTO l_mapped_comp_seq (i);

            --          end if;
            CLOSE get_mapped_components;
         END LOOP;
         */
         OPEN l_from_to_comps_csr (from_sequence_id, to_sequence_id);

         FETCH l_from_to_comps_csr
         BULK COLLECT INTO l_from_comps,
                l_to_comps;

         IF l_from_to_comps_csr%ISOPEN THEN
		   CLOSE l_from_to_comps_csr;
		 END IF;

--          X_Copied_comp_seq_id := l_copied_comp_seq;
--          X_mapped_comp_seq := l_mapped_comp_seq;

         --Start copying user attrs
         IF l_from_comps.FIRST IS NOT NULL
         THEN
            l_index := l_from_comps.FIRST;
            WHILE l_index IS NOT NULL
            LOOP
               l_src_pk_col_name_val_pairs :=
                  ego_col_name_value_pair_array
                      (ego_col_name_value_pair_obj ('COMPONENT_SEQUENCE_ID',
                                                    TO_CHAR (l_from_comps (l_index))
                                                   ),
                       ego_col_name_value_pair_obj ('BILL_SEQUENCE_ID',
                                                    TO_CHAR (from_sequence_id)
                                                   )
                      );
               l_dest_pk_col_name_val_pairs :=
                  ego_col_name_value_pair_array
                       (ego_col_name_value_pair_obj ('COMPONENT_SEQUENCE_ID',
                                                     TO_CHAR (l_to_comps (l_index))
                                                    ),
                        ego_col_name_value_pair_obj ('BILL_SEQUENCE_ID',
                                                     TO_CHAR (to_sequence_id)
                                                    )
                       );
               l_new_str_type :=
                  ego_col_name_value_pair_array
                            (ego_col_name_value_pair_obj ('STRUCTURE_TYPE_ID',
                                                          TO_CHAR (l_str_type)
                                                         )
                            );

               l_old_dtlevel_col_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID', ''));
               l_new_dtlevel_col_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID', ''));

               ego_user_attrs_data_pvt.copy_user_attrs_data
                    (p_api_version                 => 1.0,
                     p_application_id              => bom_application_id,
                     p_object_name                 => 'BOM_COMPONENTS',
                     p_old_pk_col_value_pairs      => l_src_pk_col_name_val_pairs,
                     p_new_pk_col_value_pairs      => l_dest_pk_col_name_val_pairs,
                     p_new_cc_col_value_pairs      => l_new_str_type,
                     p_old_data_level_id           => l_data_level_id_comp,
                     p_new_data_level_id           => l_data_level_id_comp,
                     p_old_dtlevel_col_value_pairs => l_old_dtlevel_col_value_pairs,
                     p_new_dtlevel_col_value_pairs => l_new_dtlevel_col_value_pairs,
                     x_return_status               => l_return_status,
                     x_errorcode                   => l_errorcode,
                     x_msg_count                   => l_msg_count,
                     x_msg_data                    => l_msg_data
                    );
				 IF l_return_status <> fnd_api.g_ret_sts_success THEN
				   error_handler.get_message_list(l_error_msg_tbl);
				   IF l_error_msg_tbl.FIRST IS NOT NULL THEN
				     l_msg_count := l_error_msg_tbl.FIRST;
					 WHILE l_msg_count IS NOT NULL
					 LOOP
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
						 SELECT bcb.component_item_id,
								to_org_id,
								p_copy_request_id,
								NULL,
								get_current_item_rev (bcb.component_item_id,
													from_org_id,
													rev_date
												   ),
								l_error_msg_tbl(l_msg_count).message_text,
								'BOM_COPY',
								SYSDATE,
								user_id,
								SYSDATE,
								user_id,
								'E',
                                fnd_global.conc_request_id,
                                NULL,
                                fnd_global.conc_program_id,
                                sysdate
						   FROM bom_components_b bcb
						  WHERE bcb.component_sequence_id = l_from_comps(l_index);
                       l_msg_count := l_error_msg_tbl.next(l_msg_count);
					 END LOOP;
				   END IF;
				 END IF;
                l_index := l_from_comps.next(l_index);
              -- Mark the components as processed if the components are added to existing eco
              -- and the explosion is in context of that eco
              IF  e_change_notice IS NOT NULL AND e_change_notice = context_eco
              THEN
                FOR l_mark_comp_rec IN l_mark_components_csr(e_change_notice, from_org_id, from_sequence_id)
                LOOP
                  eng_propagation_log_util.mark_component_change_transfer
                  (
                    p_api_version => 1.0
                    ,p_init_msg_list => FND_API.G_FALSE
                    ,p_commit => FND_API.G_FALSE
                    ,x_return_status => l_return_status
                    ,x_msg_count => l_msg_count
                    ,x_msg_data => l_msg_data
                    ,p_change_id => l_mark_comp_rec.change_id
                    ,p_revised_item_sequence_id => rev_item_seq_id
                    ,p_component_sequence_id => l_mark_comp_rec.component_sequence_id
                    ,p_local_organization_id => to_org_id
                  );
                END LOOP;
               END IF; -- IF e_change_notice = context_eco

            END LOOP;
         END IF;

         SELECT COUNT (*)
           INTO l_no_access_comp_cnt
           FROM bom_components_b bcb,
                mtl_system_items_b_kfv msbk1,
                bom_copy_explosions_v bev
          WHERE bcb.bill_sequence_id = x_from_sequence_id
            AND bcb.component_item_id = msbk1.inventory_item_id
            AND bcb.component_item_id <> to_item_id
            AND 'T' <>
                  bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (from_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
            AND msbk1.organization_id = from_org_id
            AND bcb.component_sequence_id = bev.component_sequence_id
            AND bev.bill_sequence_id = from_sequence_id
            AND bev.parent_sort_order = p_parent_sort_order
            AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= trgt_comps_eff_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
            AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  );

         IF l_no_access_comp_cnt > 0
         THEN
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
               SELECT from_item_id,
                      to_org_id,
                      p_copy_request_id,
                      NULL,
                      get_current_item_rev (from_item_id,
                                            from_org_id,
                                            rev_date
                                           ),
                      get_cnt_message ('BOM_COPY_ERR_COMP_NO_ACCESS',
                                       msbk1.concatenated_segments,
                                       TO_NUMBER (l_no_access_comp_cnt)
                                      ),
                      'BOM_COPY',
                      SYSDATE,
                      user_id,
                      SYSDATE,
                      user_id,
                      'E',
                      fnd_global.conc_request_id,
                      NULL,
                      fnd_global.conc_program_id,
                      sysdate
                 FROM mtl_system_items_b_kfv msbk1
                WHERE msbk1.inventory_item_id = from_item_id
                  AND msbk1.organization_id = from_org_id;
         END IF;

         IF (from_org_id <> to_org_id)
         THEN
            SELECT COUNT (*)
              INTO l_no_access_comp_cnt
              FROM bom_components_b bcb,
                   mtl_system_items_b_kfv msbk1,
                   bom_copy_explosions_v bev
             WHERE bcb.bill_sequence_id = x_from_sequence_id
               AND bcb.component_item_id = msbk1.inventory_item_id
               AND bcb.component_item_id <> to_item_id
               AND 'T' <>
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND msbk1.organization_id = from_org_id
               AND bcb.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
			                  AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= trgt_comps_eff_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  );

            IF l_no_access_comp_cnt > 0
            THEN
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
                  SELECT from_item_id,
                         to_org_id,
                         p_copy_request_id,
                         NULL,
                         get_current_item_rev (from_item_id,
                                               from_org_id,
                                               rev_date
                                              ),
                         get_cnt_message ('BOM_COPY_ERR_CMPDEST_NO_ACCESS',
                                          msbk1.concatenated_segments,
                                          TO_NUMBER (l_no_access_comp_cnt)
                                         ),
                         'BOM_COPY',
                         SYSDATE,
                         user_id,
                         SYSDATE,
                         user_id,
                         'E',
                         fnd_global.conc_request_id,
                         NULL,
                         fnd_global.conc_program_id,
                         sysdate
                    FROM mtl_system_items_b_kfv msbk1
                   WHERE msbk1.inventory_item_id = from_item_id
                     AND msbk1.organization_id = from_org_id;
            END IF;
         END IF;

         -- Insert Error messages to MTL_INTERFACE_ERRORS for each error while copying
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_ENG_COMP_MFG_BILL',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib,                  -- component
                   bom_copy_explosions_v bev
             WHERE bcb.bill_sequence_id = x_from_sequence_id
               AND bcb.component_item_id = msib.inventory_item_id
               AND bcb.component_item_id <> to_item_id
               AND msib.organization_id = to_org_id
               AND (direction = eng_to_bom
                    AND msib.eng_item_flag = 'Y')
               AND bcb.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
			   AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= trgt_comps_eff_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_COMP_FOR_WIP_JOB',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   bom_copy_explosions_v bev
             WHERE bcb.bill_sequence_id = x_from_sequence_id
               AND bcb.component_item_id <> to_item_id
               AND bcb.eco_for_production <> 2
               AND bcb.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
			   AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= trgt_comps_eff_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  );

       /* This message need not be logged at all.  When impl only is selected there won't be
          any unimplemented component or if there is a context eco, we need not log the message, because
          unimplemented components will be copied as implemented components
       IF ( context_eco IS NULL AND bill_or_eco = 1 )
       THEN
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
                      message_type
                     )
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (msbk1.inventory_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_UNIMPL_COMP',
                                msbk1.concatenated_segments,
                                msbk2.concatenated_segments
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E'
              FROM bom_components_b bcb,
                   mtl_system_items_b_kfv msbk1,
                   mtl_system_items_b_kfv msbk2,
                   bom_copy_explosions_v bev
             WHERE bcb.bill_sequence_id = x_from_sequence_id
               AND bcb.component_item_id = msbk1.inventory_item_id
               AND bcb.component_item_id <> to_item_id
               AND bcb.implementation_date IS NULL
               AND msbk1.organization_id = to_org_id
               AND bcb.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND msbk2.inventory_item_id = to_item_id
               AND msbk2.organization_id = to_org_id;
         END IF;
         */

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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_COMP_NOT_STANDARD',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib,
                   bom_copy_explosions_v bev
             WHERE bcb.bill_sequence_id = x_from_sequence_id
               AND bcb.component_item_id = msib.inventory_item_id
               AND bcb.component_item_id <> to_item_id
               AND bcb.implementation_date IS NOT NULL
               AND msib.organization_id = to_org_id
               AND bcb.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND (base_item_flag = -1
                    AND itm_type = 4
                    AND msib.bom_item_type <> 4
                   )
			   AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= trgt_comps_eff_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
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
			SELECT bcb.component_item_id,
				   to_org_id,
				   p_copy_request_id,
				   NULL, -- MSBK1.CONCATENATED_SEGMENTS,
				   get_current_item_rev(bcb.component_item_id, from_org_id, rev_date),
                   check_component_type_rules(bcb.component_item_id,
				         to_item_id, to_org_id),
				   'BOM_COPY',
				   SYSDATE,
				   user_id,
				   SYSDATE,
				   user_id,
				   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
			  FROM bom_components_b bcb,
                   bom_copy_explosions_v bev
			 WHERE bcb.bill_sequence_id = x_from_sequence_id
			   AND bcb.component_item_id <> to_item_id
			   AND bcb.implementation_date IS NOT NULL
			   AND bcb.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
			                  AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= trgt_comps_eff_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
			   AND check_component_type_rules(bcb.component_item_id,
				         to_item_id, to_org_id) IS NOT NULL; -- Component Type validation fails

         -- For Item Revision Change Policy throw the errors if the components change requires
		 -- change order or not allowed
		 IF bill_or_eco = 1 THEN
		   l_use_eco_flag := 'N';
		 ELSE
		   l_use_eco_flag := 'Y';
		 END IF;
         IF l_to_eff_ctrl = 1 THEN
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE (
				    'BOM_CPY_REV_CHANGE_POLICY_ERR',
                    bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                    bom_globals.get_item_name(to_item_id, from_org_id)
                   ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND bcb.component_item_id = msib.inventory_item_id
               AND msib.organization_id = to_org_id
               AND 'Y' <>
			     bom_globals.check_change_policy_range(
				   to_item_id,
				   to_org_id,
				   NULL, -- p_start_revision
				   NULL, -- p_end_revision
				   NULL, -- p_start_rev_id
				   NULL, -- p_end_rev_id
				   bcb.effectivity_date, -- p_effective_date
				   bcb.disable_date, -- p_disable_date
				   bom_globals.get_change_policy_val(to_item_id, to_org_id,
				     BOM_Revisions.Get_Item_Revision_Id_Fn('ALL','ALL',to_org_id,
					   to_item_id, NVL(x_effectivity_date, trgt_comps_eff_date)),
					   null, -- rev id
					   p_trgt_str_type_id), -- p_current_chg_pol
				   p_trgt_str_type_id, -- p_structure_type_id
				   l_use_eco_flag -- p_use_eco
				   );
		 ELSIF l_to_eff_ctrl = 4 THEN
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE (
				    'BOM_CPY_REV_CHANGE_POLICY_ERR',
                     bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                     bom_globals.get_item_name(to_item_id, from_org_id)
                   ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND bcb.component_item_id = msib.inventory_item_id
               AND msib.organization_id = to_org_id
               AND 'Y' <>
			     bom_globals.check_change_policy_range(
				   to_item_id,
				   to_org_id,
				   NULL, -- p_start_revision
				   NULL, -- p_end_revision
				   bcb.from_end_item_rev_id, -- p_start_rev_id
				   bcb.to_end_item_rev_id, -- p_end_rev_id
				   NULL, -- p_effective_date
				   NULL, -- p_disable_date
				   bom_globals.get_change_policy_val(to_item_id, to_org_id,
				     NVL(eco_end_item_rev_id, trgt_comps_end_item_rev_id),
					   null, -- rev id
					   p_trgt_str_type_id), -- p_current_chg_pol
				   p_trgt_str_type_id, -- p_structure_type_id
				   l_use_eco_flag -- p_use_eco
				   );
		 END IF;

         -- For Rev Eff structure and copy is across org then add the error message for fixed revision components
         -- if revision does not exist.
         IF l_from_eff_ctrl = 4 AND l_to_eff_ctrl = 4
            AND from_org_id <> to_org_id
         THEN
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
               SELECT bcb.component_item_id,
                      to_org_id,
                      p_copy_request_id,
                      NULL,
                      get_current_item_rev (bcb.component_item_id,
                                            from_org_id,
                                            rev_date
                                           ),
                      GET_MESSAGE
                               ('BOM_COPY_ERR_COMP_REV_DIFF',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id),
                                get_current_item_rev (bcb.component_item_id,
                                                      from_org_id,
                                                      rev_date
                                                     )
                               ),
                      'BOM_COPY',
                      SYSDATE,
                      user_id,
                      SYSDATE,
                      user_id,
                      'E',
                      fnd_global.conc_request_id,
                      NULL,
                      fnd_global.conc_program_id,
                      sysdate
                 FROM bom_components_b bcb,
                      bom_copy_explosions_v bev
                WHERE bcb.bill_sequence_id = x_from_sequence_id
                  AND bcb.component_item_id <> to_item_id
                  AND bcb.implementation_date IS NOT NULL
                  AND bcb.component_sequence_id = bev.component_sequence_id
                  -- Error needs to be logged only for fixed revision components
                  AND bcb.component_item_revision_id IS NOT NULL
                  AND bev.bill_sequence_id = from_sequence_id
                  AND bev.parent_sort_order = p_parent_sort_order
				  AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			      AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			     (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= trgt_comps_eff_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
                AND NOT EXISTS (
                        SELECT tmirb.revision_id
                          FROM mtl_item_revisions_b fmirb,
                               mtl_item_revisions_b tmirb
                         WHERE tmirb.inventory_item_id = bcb.component_item_id
                           AND tmirb.organization_id = to_org_id
                           AND tmirb.revision = fmirb.revision
                           AND fmirb.revision_id =
                                                bcb.component_item_revision_id);
         END IF;
      ELSIF (specific_copy_flag = 'N'
             OR (specific_copy_flag = 'Y'
                 AND copy_all_comps_flag = 'Y')
            )
      THEN


	 INSERT INTO bom_components_b
                     (shipping_allowed,
                      required_to_ship,
                      required_for_revenue,
                      include_on_ship_docs,
                      include_on_bill_docs,
                      low_quantity,
                      high_quantity,
                      acd_type,
                      component_sequence_id,
                      old_component_sequence_id,
                      bill_sequence_id,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      wip_supply_type,
                      pick_components,
                      supply_subinventory,
                      supply_locator_id,
                      operation_lead_time_percent,
                      revised_item_sequence_id,
                      cost_factor,
                      operation_seq_num,
                      component_item_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      item_num,
                      component_quantity,
                      component_yield_factor,
                      component_remarks,
                      effectivity_date,
                      change_notice,
                      implementation_date,
                      disable_date,
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
                      planning_factor,
                      quantity_related,
                      so_basis,
                      optional,
                      mutually_exclusive_options,
                      include_in_cost_rollup,
                      check_atp,
                      bom_item_type,
                      from_end_item_unit_number,
                      to_end_item_unit_number,
                      optional_on_model,
                      --BUGFIX 2740820
                      parent_bill_seq_id,                     --BUGFIX 2740820
                      model_comp_seq_id,                      --BUGFIX 2740820
                      plan_level,
                      --BUGFIX 2740820
                      enforce_int_requirements,               --BUGFIX 2991472
                      pk1_value,
                      /* Added to prevent BOMTSTRC from */
                      pk2_value,
                      /* giving errors while defaulting */
                      auto_request_material,
                      -- Bug 3662214 : Added following 4 fields
                      suggested_vendor_name,
                      vendor_id,
                      unit_price,
                      basis_type
                     )
            SELECT shipping_allowed,
                   required_to_ship,
                   required_for_revenue,
                   include_on_ship_docs,
                   include_on_bill_docs,
                --   low_quantity,
                --   high_quantity,
                    DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
       		           AA.primary_unit_of_measure,BIC.low_quantity,
		           DECODE(BIC.low_quantity,null,null,              --Added this inner Deocde for Bug 6847530
			   inv_convert.INV_UM_CONVERT(BIC.component_item_id,
			                                NULL,
				                        BIC.low_quantity,
					                NULL,
						        NULL,
						        AA.primary_unit_of_measure,
							MSI.primary_unit_of_measure))) Comp_low_qty,
                      DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
			     AA.primary_unit_of_measure,BIC.high_quantity,
			     DECODE(BIC.high_quantity,null,null,             --Added this inner Deocde for Bug 6847530
			     inv_convert.INV_UM_CONVERT(BIC.component_item_id,
				                        NULL,
					                BIC.high_quantity,
						        NULL,
							NULL,
		                                        AA.primary_unit_of_measure,
			                                MSI.primary_unit_of_measure))) Comp_high_qty,
                   x_acd_type,
                   bom_inventory_components_s.NEXTVAL,
                   DECODE (x_acd_type,
                           NULL, NULL,
                           bom_inventory_components_s.CURRVAL
                          ),
                   to_sequence_id,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bic.wip_supply_type,
                   DECODE (rto_flag, 'Y', 2, pick_components),
                   DECODE (x_from_org_id,
                           to_org_id, supply_subinventory,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, supply_locator_id,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_locator_id, NULL )
                           ),
                   operation_lead_time_percent,
                   x_rev_item_seq_id,
                   cost_factor,
                   operation_seq_num,
                   component_item_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   component_sequence_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   item_num,
         --          component_quantity,
  	          DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                         AA.primary_unit_of_measure,BIC.component_quantity,
                         inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                    NULL,
                                                    BIC.component_quantity,
                                                    NULL,
                                                    NULL,
                                                    AA.primary_unit_of_measure,
                                                    MSI.primary_unit_of_measure)) Comp_qty,
                   component_yield_factor,
                   component_remarks,
                   -- Bug 2161841
                   DECODE (bill_or_eco,
                           2, x_effectivity_date,
                           GREATEST (effectivity_date, SYSDATE)
                          ),
                           --This is replaced by the next line to handle the bug 1636829
                           --DECODE(bill_or_eco,2,X_EFFECTIVITY_DATE,EFFECTIVITY_DATE),
                           -- Bug 2161841
                   --      GREATEST(EFFECTIVITY_DATE,SYSDATE),This was the orig line, was modified for eco's as per bug 315166
                   x_e_change_notice,
                   DECODE (bill_or_eco,
                           2, TO_DATE (NULL),
                           implementation_date
                          ),
                   DECODE (bill_or_eco, 2, TO_DATE (NULL), disable_date),
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15,
                   planning_factor,
                   quantity_related,
                   so_basis,
                   optional,
                   mutually_exclusive_options,
                   include_in_cost_rollup,
                   --DECODE(atp_comp_flag, 'Y', CHECK_ATP, 2),  fixed bug 2249375
                   check_atp,
                   msi.bom_item_type,
                   DECODE (bill_or_eco,
                           2, x_unit_number,
                           bic.from_end_item_unit_number
                          ),
                   bic.to_end_item_unit_number,
                   bic.optional_on_model,
                   --BUGFIX 2740820
                   bic.parent_bill_seq_id,                    --BUGFIX 2740820
                   bic.model_comp_seq_id,
                   --BUGFIX 2740820
                   bic.plan_level,                            --BUGFIX 2740820
                   bic.enforce_int_requirements,
                   --BUGFIX 2991472
                   bic.component_item_id,
                   to_org_id,
                   bic.auto_request_material,
                   -- Bug 3662214 : Added following 4 fields
                   bic.suggested_vendor_name,
                   bic.vendor_id,
                   bic.unit_price,
                   bic.basis_type
              FROM bom_inventory_components bic,
                   mtl_system_items msi,
  		   MTL_SYSTEM_ITEMS AA         -- Added corresponding to Bug 6510185
             WHERE bic.bill_sequence_id = x_from_sequence_id
               AND bic.component_item_id = msi.inventory_item_id
               AND bic.component_item_id <> to_item_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND msi.organization_id = to_org_id
               AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
	       AND AA.organization_id = from_org_id                 -- Added corresponding to Bug 6510185
--                          AND MSI.BOM_ENABLED_FLAG = 'Y'  Bug 3595979
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND ((x_unit_assembly = 'N'
                     AND ((display_option = 1)                          -- ALL
                          OR (display_option = 2
                              AND (effectivity_date <= rev_date
                                   AND
                                       -- Added condition of sysdate for Bug 2161841
                                   (    (disable_date > rev_date
                                         AND disable_date > SYSDATE
                                        )
                                        OR disable_date IS NULL
                                       )
                                  )
                             )
                          OR                                        -- CURRENT
                            (display_option = 3
                             AND
                                 -- Added condition of sysdate for Bug 2161841
                             (    (disable_date > rev_date
                                   AND disable_date > SYSDATE
                                  )
                                  OR disable_date IS NULL
                                 )
                            )
                         )                                 -- CURRENT + FUTURE
                    )
                    OR (x_unit_assembly = 'Y'
                        AND ((display_option = 1)                       -- ALL
                             OR (display_option = 2
                                 AND disable_date IS NULL
                                 AND (from_end_item_unit_number <= unit_number
                                      AND (to_end_item_unit_number >=
                                                                   unit_number
                                           OR to_end_item_unit_number IS NULL
                                          )
                                     )
                                )
                             OR                                     -- CURRENT
                               (display_option = 3
                                AND disable_date IS NULL
                                AND (to_end_item_unit_number >= unit_number
                                     OR to_end_item_unit_number IS NULL
                                    )
                               )
                            )                              -- CURRENT + FUTURE
                       )
                   )
               AND ((base_item_flag = -1
                     AND itm_type = 4
                     AND msi.bom_item_type = 4
                    )
                    OR base_item_flag <> -1
                    OR itm_type <> 4
                   )
               AND implementation_date IS NOT NULL;
      END IF;

      copy_comps := SQL%ROWCOUNT;

      /*
        Uncomment this part of code when Enable in Org component action is supported.
      -- Replace the components in the destination bill with the list.
      IF specific_copy_flag = 'Y' THEN
          IF replace_comps_arr IS NOT NULL AND replacement_items_arr IS NOT NULL AND replacement_items_rev_ids_arr IS NOT NULL THEN
              l_count1 := replace_comps_arr.FIRST;
              l_count2 := replacement_items_arr.FIRST;
              l_count3 := replacement_items_rev_ids_arr.FIRST;
              IF (l_count1 IS NOT NULL AND l_count2 IS NOT NULL) THEN
              FORALL j IN replace_comps_arr.FIRST..replace_comps_arr.LAST
                     UPDATE BOM_COMPONENTS_B
                     SET COMPONENT_ITEM_ID = replacement_items_arr(j),
                     COMPONENT_ITEM_REVISION_ID = replacement_items_rev_ids_arr(j)
                     WHERE BILL_SEQUENCE_ID = to_sequence_id
                     AND CREATED_BY  = replace_comps_arr(j);
              END IF;
          END IF;
      END IF;
      */

      -- Bug 1825873
--    if(X_from_org_id = to_org_id) then
--      total_inventory_components := SQL%ROWCOUNT;
--   end if;
-- Bug 1825873--determine if routing exists.  If not exists, then reset--operation_sequence_num to 1.  If exists then, reset only missing--operation_seq_num to 1
      BEGIN
         sql_stmt_num := 25;

         SELECT common_routing_sequence_id
           INTO to_rtg_seq_id
           FROM bom_operational_routings
          WHERE organization_id = to_org_id
            AND assembly_item_id = to_item_id
            AND (NVL (alternate_routing_designator, 'NONE') =
                                                    NVL (to_alternate, 'NONE')
                 OR (to_alternate IS NOT NULL
                     AND alternate_routing_designator IS NULL
                     AND NOT EXISTS (
                           SELECT NULL
                             FROM bom_operational_routings bor2
                            WHERE bor2.organization_id = to_org_id
                              AND bor2.assembly_item_id = to_item_id
                              AND bor2.alternate_routing_designator =
                                                                  to_alternate)
                    )
                );
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            to_rtg_seq_id := -1;
         WHEN OTHERS
         THEN
            err_msg := 'COPY_BILL (' || sql_stmt_num || ') ' || SQLERRM;
            fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
            fnd_message.set_token ('ENTITY', err_msg);
            ROLLBACK TO begin_bill_copy;
            app_exception.raise_exception;
      END;

      BEGIN
         --Turn off trigger BOMTBICX
         bom_globals.g_skip_bomtbicx := 'Y';

         IF (to_rtg_seq_id = -1)
         THEN
            sql_stmt_num := 30;

            UPDATE bom_inventory_components
               SET operation_seq_num = 1
             WHERE bill_sequence_id = to_sequence_id;
         ELSE
            sql_stmt_num := 35;

            UPDATE bom_inventory_components bic
               SET operation_seq_num = 1
             WHERE bill_sequence_id = to_sequence_id
               AND NOT EXISTS (
                     SELECT NULL
                       FROM bom_operation_sequences bos
                      WHERE routing_sequence_id = to_rtg_seq_id
                        AND bos.operation_seq_num = bic.operation_seq_num);
         END IF;

         --Turn on trigger BOMTBICX
         bom_globals.g_skip_bomtbicx := 'N';
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            RAISE overlap_error;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      --check for overlapping rows if teh above updated any rows
      IF (SQL%FOUND)
      THEN
         BEGIN
            sql_stmt_num := 40;

            /* Serial Effectivity Implementation */
            IF (bom_eamutil.enabled = 'Y'
                AND bom_eamutil.serial_effective_item (item_id      => to_item_id,
                                                       org_id       => to_org_id
                                                      ) = 'Y'
               )
               OR (pjm_unit_eff.enabled = 'Y'
                   AND pjm_unit_eff.unit_effective_item
                                               (x_item_id              => to_item_id,
                                                x_organization_id      => to_org_id
                                               ) = 'Y'
                  )
            THEN
               SELECT COUNT (*)
                 INTO dummy
                 FROM bom_inventory_components bic
                WHERE bic.bill_sequence_id = to_sequence_id
                  AND EXISTS (
                        SELECT NULL
                          FROM bom_inventory_components bic2
                         WHERE bic2.bill_sequence_id = to_sequence_id
                           AND bic2.ROWID <> bic.ROWID
                           AND bic2.operation_seq_num = bic.operation_seq_num
                           AND bic2.component_item_id = bic.component_item_id
                           AND bic2.disable_date IS NULL
                           AND (bic.to_end_item_unit_number IS NULL
                                OR (bic.to_end_item_unit_number >=
                                                bic2.from_end_item_unit_number
                                   )
                               )
                           AND (bic2.to_end_item_unit_number IS NULL
                                OR (bic.from_end_item_unit_number <=
                                                  bic2.to_end_item_unit_number
                                   )
                               ));
            ELSIF l_to_eff_ctrl = 4
            THEN
               SELECT COUNT (*)
                 INTO dummy
                 FROM bom_components_b bcb
                WHERE bcb.bill_sequence_id = to_sequence_id
                  AND EXISTS (
                        SELECT NULL
                          FROM bom_components_b bcb2
                         WHERE bcb2.bill_sequence_id = to_sequence_id
                           AND bcb2.ROWID <> bcb.ROWID
                           AND bcb2.operation_seq_num = bcb.operation_seq_num
                           AND bcb2.component_item_id = bcb.component_item_id
                           AND bcb2.disable_date IS NULL
                           AND (bcb.to_end_item_rev_id IS NULL
                                OR (get_minor_rev_code
                                                 (bcb.to_end_item_rev_id,
                                                  bcb.to_end_item_minor_rev_id
                                                 ) >=
                                       get_minor_rev_code
                                              (bcb2.from_end_item_rev_id,
                                               bcb2.from_end_item_minor_rev_id
                                              )
                                   )
                               )
                           AND (bcb2.to_end_item_rev_id IS NULL
                                OR (get_minor_rev_code
                                               (bcb.from_end_item_rev_id,
                                                bcb.from_end_item_minor_rev_id
                                               ) >=
                                       get_minor_rev_code
                                                (bcb2.to_end_item_rev_id,
                                                 bcb2.to_end_item_minor_rev_id
                                                )
                                   )
                               ));
            ELSE
               SELECT COUNT (*)
                 INTO dummy
                 FROM bom_inventory_components bic
                WHERE bic.bill_sequence_id = to_sequence_id
                  AND EXISTS (
                        SELECT NULL
                          FROM bom_inventory_components bic2
                         WHERE bic2.bill_sequence_id = to_sequence_id
                           AND bic2.ROWID <> bic.ROWID
                           AND bic2.operation_seq_num = bic.operation_seq_num
                           AND bic2.component_item_id = bic.component_item_id
                           AND bic2.effectivity_date <= bic.effectivity_date
                           AND NVL (bic2.disable_date,
                                    bic.effectivity_date + 1
                                   ) > bic.effectivity_date);
            END IF;

            IF (dummy <> 0)
            THEN
               -- Added for bug 3801212: Check if rows fetched to raise overlap_error
               RAISE overlap_error;
            END IF;
         EXCEPTION
            WHEN overlap_error
            THEN
               RAISE;
            WHEN NO_DATA_FOUND
            THEN
               NULL;
            WHEN OTHERS
            THEN
               err_msg := 'COPY_BILL (' || sql_stmt_num || ') ' || SQLERRM;
               fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
               fnd_message.set_token ('ENTITY', err_msg);
               ROLLBACK TO begin_bill_copy;
               app_exception.raise_exception;
         END;
      END IF;

--  Other organizations who use our bills as common bills must have the
--  component items in their organization as well.
--
      FOR l_common_rec IN l_common_csr
      LOOP
         RAISE common_error;
      END LOOP;

--     Ensure the following rule matrix is observed
--
--     Y = Allowed  N = Not Allowed
--     P = Must be Phantom  O = Must be Optional
--     Configured items are ATO standard items that have a base item id.
--     ATO items have Replenish to Order flags set to "Y".
--     PTO items have Pick Component flags set to "Y".
--
--                                     Parent
-- Child         |Config  ATO Mdl  ATO Opt  ATO Std  PTO Mdl  PTO Opt  PTO Std
-- ---------------------------------------------------------------------------
-- Planning      |   N       N        N        N        N        N        N
-- Configured    |   Y       Y        Y        Y        Y        Y        Y
-- ATO Model     |   P       P        P        N        P        P        N
-- ATO Opt Class |   P       P        P        N        N        N        N
-- ATO Standard  |   Y       Y        Y        Y        O        O        N
-- PTO Model     |   N       N        N        N        P        P        N
-- PTO Opt Class |   N       N        N        N        P        P        N
-- PTO Standard  |   N       N        N        N        Y        Y        Y
--
--
  -- Log errors for multi level structure copy.
      IF specific_copy_flag = 'Y'
      THEN
         -- Planning bill should contain only planning components
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_NO_PLANNING_COMPS',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,
                   mtl_system_items_b msib2
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND (msib1.bom_item_type = planning
                    AND msib2.bom_item_type <> planning
                   )
               AND msib2.inventory_item_id = to_item_id
               AND msib2.organization_id = to_org_id
               AND msib1.inventory_item_id = bcb.component_item_id
               AND msib1.organization_id = to_org_id;

         -- Standard bill without base model cannot have Option class or Model components.
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_NO_OPT_MODEL_COMP',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,
                   mtl_system_items_b msib2
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND (msib1.bom_item_type IN (model, option_class)
                    AND msib2.bom_item_type = STANDARD
                    AND msib2.base_item_id IS NULL
                   )
               AND msib2.inventory_item_id = to_item_id
               AND msib2.organization_id = to_org_id
               AND msib1.inventory_item_id = bcb.component_item_id
               AND msib1.organization_id = to_org_id;

         -- No ATO Optional components in PTO bill
         --modified the following for BOM ER 9904085
         if(nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1)
         then
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_NO_ATO_OPT_COMPS',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,                       -- Comp
                   mtl_system_items_b msib2                   -- Structure
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND (msib1.replenish_to_order_flag = 'Y'
                    AND msib1.bom_item_type = option_class
                    AND msib2.pick_components_flag = 'Y'
                   )
               AND msib2.inventory_item_id = to_item_id
               AND msib2.organization_id = to_org_id
               AND msib1.inventory_item_id = bcb.component_item_id
               AND msib1.organization_id = to_org_id;

         -- No ATO standard items for PTO standard bills
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_NO_ATO_STD_COMPS',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,                       -- Comp
                   mtl_system_items_b msib2                   -- Structure
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND (msib1.replenish_to_order_flag = 'Y'
                    AND msib1.bom_item_type = STANDARD
                    AND msib2.pick_components_flag = 'Y'
                    AND msib2.bom_item_type = STANDARD
                   )
               AND msib2.inventory_item_id = to_item_id
               AND msib2.organization_id = to_org_id
               AND msib1.inventory_item_id = bcb.component_item_id
               AND msib1.organization_id = to_org_id;
         end if;
         --end of BOM ER 9904085

         -- No PTO components in ATO bill
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_NO_PTO_COMPS',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,                       -- Comp
                   mtl_system_items_b msib2                   -- Structure
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND (msib1.pick_components_flag = 'Y'
                    AND msib2.replenish_to_order_flag = 'Y'
                   )
               AND msib2.inventory_item_id = to_item_id
               AND msib2.organization_id = to_org_id
               AND msib1.inventory_item_id = bcb.component_item_id
               AND msib1.organization_id = to_org_id;
      END IF;

      sql_stmt_num := 41;

      DELETE FROM bom_inventory_components bic
            WHERE bic.bill_sequence_id = to_sequence_id
              AND EXISTS (
                    SELECT NULL
                      FROM mtl_system_items msi1,                       -- bom
                           mtl_system_items msi2                  -- component
                     WHERE ((msi2.bom_item_type = planning
                             AND msi1.bom_item_type <> planning
                            )
                            OR (msi2.bom_item_type IN (model, option_class)
                                AND msi1.bom_item_type = STANDARD
                                AND msi1.base_item_id IS NULL
                               )
                            OR (msi2.replenish_to_order_flag = 'Y'
                                AND msi2.bom_item_type = option_class
                                AND msi1.pick_components_flag = 'Y'
                               )
                            OR (
                                 (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1)
                                  and
                                 (msi2.replenish_to_order_flag = 'Y'
                                  AND msi2.bom_item_type = STANDARD
                                  AND msi1.pick_components_flag = 'Y'
                                  AND msi1.bom_item_type = STANDARD
                                 )
                               )--modified for BOM ER 9904085
                            OR (msi2.pick_components_flag = 'Y'
                                AND msi1.replenish_to_order_flag = 'Y'
                               )
                           )
                       AND msi1.inventory_item_id = to_item_id
                       AND msi1.organization_id = to_org_id
                       AND msi2.inventory_item_id = bic.component_item_id
                       AND msi2.organization_id = to_org_id);

      copy_comps := copy_comps - SQL%ROWCOUNT;
      sql_stmt_num := 43;
      --Turn off trigger BOMTBICX
      bom_globals.g_skip_bomtbicx := 'Y';

      UPDATE bom_components_b bic
         SET bic.wip_supply_type = phantom
       WHERE bic.bill_sequence_id = to_sequence_id
         AND EXISTS (
               SELECT NULL
                 FROM mtl_system_items msi1,                       -- assembly
                      mtl_system_items msi2                       -- component
                WHERE msi2.bom_item_type IN (model, option_class)
                  AND msi2.inventory_item_id = bic.component_item_id
                  AND msi2.organization_id = to_org_id
                  AND msi1.inventory_item_id = to_item_id
                  AND msi1.organization_id = to_org_id);

      bom_globals.g_skip_bomtbicx := 'N';
      sql_stmt_num := 44;
      bom_globals.g_skip_bomtbicx := 'Y';

      UPDATE bom_components_b bic
         SET bic.optional = 1
       WHERE bic.bill_sequence_id = to_sequence_id
         AND nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1 --added for BOM ER 9904085
         AND EXISTS (
               SELECT NULL
                 FROM mtl_system_items msi1,                       -- assembly
                      mtl_system_items msi2                       -- component
                WHERE msi2.base_item_id IS NULL
                  AND msi2.replenish_to_order_flag = 'Y'
                  AND msi2.bom_item_type = STANDARD
                  AND msi1.pick_components_flag = 'Y'
                  AND msi1.bom_item_type = model
                  AND msi2.inventory_item_id = bic.component_item_id
                  AND msi2.organization_id = to_org_id
                  AND msi1.inventory_item_id = to_item_id
                  AND msi1.organization_id = to_org_id);

    --separated out model and option class sections
    UPDATE bom_components_b bic
         SET bic.optional = 1
       WHERE bic.bill_sequence_id = to_sequence_id
         AND EXISTS (
               SELECT NULL
                 FROM mtl_system_items msi1,                       -- assembly
                      mtl_system_items msi2                       -- component
                WHERE msi2.base_item_id IS NULL
                  AND msi2.replenish_to_order_flag = 'Y'
                  AND msi2.bom_item_type = STANDARD
                  AND msi1.pick_components_flag = 'Y'
                  AND msi1.bom_item_type = option_class
                  AND msi2.inventory_item_id = bic.component_item_id
                  AND msi2.organization_id = to_org_id
                  AND msi1.inventory_item_id = to_item_id
                  AND msi1.organization_id = to_org_id);


      --Turn on trigger BOMTBICX
      bom_globals.g_skip_bomtbicx := 'N';
      sql_stmt_num := 46;

      IF specific_copy_flag = 'Y'
      THEN
         INSERT INTO bom_reference_designators
                     (component_reference_designator,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      ref_designator_comment,
                      change_notice,
                      component_sequence_id,
                      acd_type,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
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
                      attribute15
                     )
            SELECT component_reference_designator,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   user_id, /*NULL,bug fix:8639515*/
                   ref_designator_comment,
                   x_e_change_notice,
                   bic.component_sequence_id,
                   x_acd_type,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   brd.attribute_category,
                   brd.attribute1,
                   brd.attribute2,
                   brd.attribute3,
                   brd.attribute4,
                   brd.attribute5,
                   brd.attribute6,
                   brd.attribute7,
                   brd.attribute8,
                   brd.attribute9,
                   brd.attribute10,
                   brd.attribute11,
                   brd.attribute12,
                   brd.attribute13,
                   brd.attribute14,
                   brd.attribute15
              FROM bom_reference_designators brd,
                   bom_components_b bic,
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = to_sequence_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND brd.component_sequence_id = bic.created_by
               AND NVL (brd.acd_type, 1) <> 3
               AND bic.created_by = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order;
      ELSIF (specific_copy_flag = 'N'
             OR (specific_copy_flag = 'Y'
                 AND copy_all_rfds_flag = 'Y')
            )
      THEN
         INSERT INTO bom_reference_designators
                     (component_reference_designator,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      ref_designator_comment,
                      change_notice,
                      component_sequence_id,
                      acd_type,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
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
                      attribute15
                     )
            SELECT component_reference_designator,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   user_id,/*NULL,Bugfix:8639515*/
                   ref_designator_comment,
                   x_e_change_notice,
                   bic.component_sequence_id,
                   x_acd_type,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   brd.attribute_category,
                   brd.attribute1,
                   brd.attribute2,
                   brd.attribute3,
                   brd.attribute4,
                   brd.attribute5,
                   brd.attribute6,
                   brd.attribute7,
                   brd.attribute8,
                   brd.attribute9,
                   brd.attribute10,
                   brd.attribute11,
                   brd.attribute12,
                   brd.attribute13,
                   brd.attribute14,
                   brd.attribute15
              FROM bom_reference_designators brd,
                   bom_inventory_components bic
             WHERE bic.bill_sequence_id = to_sequence_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND brd.component_sequence_id = bic.created_by
               AND NVL (brd.acd_type, 1) <> 3;
      END IF;

      copy_desgs := SQL%ROWCOUNT;

      IF (x_from_org_id = to_org_id)
      THEN
         total_reference_designators := SQL%ROWCOUNT;
      END IF;

      sql_stmt_num := 50;

      IF specific_copy_flag = 'Y'
      THEN
         INSERT INTO bom_substitute_components
                     (substitute_component_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      substitute_item_quantity,
                      component_sequence_id,
                      acd_type,
                      change_notice,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
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
					  enforce_int_requirements
                     )
            SELECT substitute_component_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   --substitute_item_quantity,
  	           DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,Bsc.substitute_item_quantity,
                          inv_convert.INV_UM_CONVERT(bsc.substitute_component_id,
			                             NULL,
		 		                     Bsc.substitute_item_quantity,
				                     NULL,
				     	             NULL,
						     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure)) Sub_Comp_qty,
                   bic.component_sequence_id,
                   x_acd_type,
                   x_e_change_notice,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bsc.attribute_category,
                   bsc.attribute1,
                   bsc.attribute2,
                   bsc.attribute3,
                   bsc.attribute4,
                   bsc.attribute5,
                   bsc.attribute6,
                   bsc.attribute7,
                   bsc.attribute8,
                   bsc.attribute9,
                   bsc.attribute10,
                   bsc.attribute11,
                   bsc.attribute12,
                   bsc.attribute13,
                   bsc.attribute14,
                   bsc.attribute15,
				   bsc.enforce_int_requirements
              FROM bom_substitute_components bsc,
                   bom_components_b bic,
                   mtl_system_items msi,
		   MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = to_sequence_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND bsc.component_sequence_id = bic.created_by
               AND NVL (bsc.acd_type, 1) <> 3
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND msi.inventory_item_id = bsc.substitute_component_id
               AND msi.organization_id = to_org_id
               AND bic.created_by = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
	       AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
               AND AA.organization_id = from_org_id                 -- Added corresponding to Bug 6510185
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Substitute Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
			   );
      ELSIF (specific_copy_flag = 'N'
             OR (specific_copy_flag = 'Y'
                 AND copy_all_subcomps_flag = 'Y')
            )
      THEN
         INSERT INTO bom_substitute_components
                     (substitute_component_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      substitute_item_quantity,
                      component_sequence_id,
                      acd_type,
                      change_notice,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
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
					  enforce_int_requirements
                     )
            SELECT substitute_component_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   --substitute_item_quantity,
  	           DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,Bsc.substitute_item_quantity,
                          inv_convert.INV_UM_CONVERT(bsc.substitute_component_id,
			                             NULL,
		 		                     Bsc.substitute_item_quantity,
				                     NULL,
				     	             NULL,
						     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure))  Sub_Comp_qty,
                   bic.component_sequence_id,
                   x_acd_type,
                   x_e_change_notice,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bsc.attribute_category,
                   bsc.attribute1,
                   bsc.attribute2,
                   bsc.attribute3,
                   bsc.attribute4,
                   bsc.attribute5,
                   bsc.attribute6,
                   bsc.attribute7,
                   bsc.attribute8,
                   bsc.attribute9,
                   bsc.attribute10,
                   bsc.attribute11,
                   bsc.attribute12,
                   bsc.attribute13,
                   bsc.attribute14,
                   bsc.attribute15,
				   bsc.enforce_int_requirements
              FROM bom_substitute_components bsc,
                   bom_inventory_components bic,
                   mtl_system_items msi,
   		   MTL_SYSTEM_ITEMS AA         -- Added corresponding to Bug 6510185
             WHERE bic.bill_sequence_id = to_sequence_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND bsc.component_sequence_id = bic.created_by
               AND NVL (bsc.acd_type, 1) <> 3
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND msi.inventory_item_id = bsc.substitute_component_id
               AND msi.organization_id = to_org_id
	       AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
               AND AA.organization_id = from_org_id;                 -- Added corresponding to Bug 6510185;
      END IF;

      copy_subs := SQL%ROWCOUNT;

      IF (x_from_org_id = to_org_id)
      THEN
         total_substitute_components := SQL%ROWCOUNT;
      END IF;

      sql_stmt_num := 51;

      /* Copy the component operations (One To Many changes) */
      IF specific_copy_flag = 'Y'
      THEN
         INSERT INTO bom_component_operations
                     (comp_operation_seq_id,
                      operation_seq_num,
                      operation_sequence_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      component_sequence_id,
                      bill_sequence_id,
                      consuming_operation_flag,
                      consumption_quantity,
                      supply_subinventory,
                      supply_locator_id,
                      wip_supply_type,
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
            SELECT bom_component_operations_s.NEXTVAL,
                   bco.operation_seq_num,
                   bos.operation_sequence_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.component_sequence_id,
                   bic.bill_sequence_id,
                   bco.consuming_operation_flag,
                   bco.consumption_quantity,
                   DECODE (x_from_org_id,
                           to_org_id, bco.supply_subinventory,
                           DECODE( l_default_wip_params, 1, bic.supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bco.supply_locator_id,
                           DECODE( l_default_wip_params, 1, bic.supply_locator_id, NULL )
                           ),
                   bco.wip_supply_type,
                   bco.attribute_category,
                   bco.attribute1,
                   bco.attribute2,
                   bco.attribute3,
                   bco.attribute4,
                   bco.attribute5,
                   bco.attribute6,
                   bco.attribute7,
                   bco.attribute8,
                   bco.attribute9,
                   bco.attribute10,
                   bco.attribute11,
                   bco.attribute12,
                   bco.attribute13,
                   bco.attribute14,
                   bco.attribute15,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_component_operations bco,
                   bom_components_b bic,
                   bom_operation_sequences bos,
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = to_sequence_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND bco.component_sequence_id = bic.created_by
               AND bos.routing_sequence_id = to_rtg_seq_id
               AND bos.operation_seq_num = bco.operation_seq_num
               AND bic.created_by = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order;
      ELSIF (specific_copy_flag = 'N'
             OR (specific_copy_flag = 'Y'
                 AND copy_all_comps_flag = 'Y')
            )
      THEN
         INSERT INTO bom_component_operations
                     (comp_operation_seq_id,
                      operation_seq_num,
                      operation_sequence_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      component_sequence_id,
                      bill_sequence_id,
                      consuming_operation_flag,
                      consumption_quantity,
                      supply_subinventory,
                      supply_locator_id,
                      wip_supply_type,
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
            SELECT bom_component_operations_s.NEXTVAL,
                   bco.operation_seq_num,
                   bos.operation_sequence_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.component_sequence_id,
                   bic.bill_sequence_id,
                   bco.consuming_operation_flag,
                   bco.consumption_quantity,
                   DECODE (x_from_org_id,
                           to_org_id, bco.supply_subinventory,
                           DECODE( l_default_wip_params, 1, bic.supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bco.supply_locator_id,
                           DECODE( l_default_wip_params, 1, bic.supply_locator_id, NULL )
                           ),
                   bco.wip_supply_type,
                   bco.attribute_category,
                   bco.attribute1,
                   bco.attribute2,
                   bco.attribute3,
                   bco.attribute4,
                   bco.attribute5,
                   bco.attribute6,
                   bco.attribute7,
                   bco.attribute8,
                   bco.attribute9,
                   bco.attribute10,
                   bco.attribute11,
                   bco.attribute12,
                   bco.attribute13,
                   bco.attribute14,
                   bco.attribute15,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_component_operations bco,
                   bom_inventory_components bic,
                   bom_operation_sequences bos
             WHERE bic.bill_sequence_id = to_sequence_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND bco.component_sequence_id = bic.created_by
               AND bos.routing_sequence_id = to_rtg_seq_id
               AND bos.operation_seq_num = bco.operation_seq_num;
      END IF;

      copy_compops := SQL%ROWCOUNT;

      IF (itm_type = model
          OR itm_type = option_class)
      THEN
         sql_stmt_num := 55;

         INSERT INTO bom_dependent_desc_elements
                     (bill_sequence_id,
                      element_name,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      program_application_id,
                      program_id,
                      program_update_date,
                      request_id
                     )
            SELECT to_sequence_id,
                   bdde.element_name,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   user_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   fnd_global.conc_request_id
              FROM bom_dependent_desc_elements bdde
             WHERE bdde.bill_sequence_id = x_from_sequence_id
               AND ((itm_type = model
                     AND EXISTS (
                           SELECT NULL
                             FROM mtl_descriptive_elements mde
                            WHERE mde.item_catalog_group_id = itm_cat_grp_id
                              AND mde.element_name = bdde.element_name)
                    )
                    OR itm_type = option_class
                   );
      END IF;

      sql_stmt_num := 70;

      IF (specific_copy_flag = 'N'
          OR (specific_copy_flag = 'Y'
              AND copy_attach_flag = 'Y')
         )
      THEN
         fnd_attached_documents2_pkg.copy_attachments
                              (x_from_entity_name            => 'BOM_BILL_OF_MATERIALS',
                               x_from_pk1_value              => x_from_sequence_id,
                               x_from_pk2_value              => '',
                               x_from_pk3_value              => '',
                               x_from_pk4_value              => '',
                               x_from_pk5_value              => '',
                               x_to_entity_name              => 'BOM_BILL_OF_MATERIALS',
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
      END IF;

      sql_stmt_num := 80;
      -- Update the created by column only when specific copy flag is no..
      -- If specific copy flag is 'Y', then after copy_bill, call update_created_by.
      IF  specific_copy_flag = 'N' THEN
        --Turn off trigger BOMTBICX
        bom_globals.g_skip_bomtbicx := 'Y';

        UPDATE bom_components_b bic
           SET created_by = user_id
         WHERE bic.bill_sequence_id = to_sequence_id;

        --Turn on trigger BOMTBICX
        bom_globals.g_skip_bomtbicx := 'N';
      END IF;
      sql_stmt_num := 85;

      SELECT COUNT (*)
        INTO copy_comts
        FROM fnd_attached_documents
       WHERE entity_name = 'BOM_BILL_OF_MATERIALS'
         AND pk1_value = to_char(to_sequence_id);  --Bug 12569030, Added to_char

      IF (x_from_org_id = to_org_id)
      THEN
         sql_stmt_num := 87;
         total_assembly_comments := copy_comts;
      END IF;

      fnd_message.set_name ('BOM', 'BOM_BILL_COPY_DONE');
      fnd_message.set_token ('ENTITY1', copy_comps);
      fnd_message.set_token ('ENTITY2', total_inventory_components);
      fnd_message.set_token ('ENTITY3', copy_comts);
      fnd_message.set_token ('ENTITY4', total_assembly_comments);
      fnd_message.set_token ('ENTITY5', copy_desgs);
      fnd_message.set_token ('ENTITY6', total_reference_designators);
      fnd_message.set_token ('ENTITY7', copy_subs);
      fnd_message.set_token ('ENTITY8', total_substitute_components);
      fnd_message.set_token ('ENTITY9', copy_compops);
      fnd_message.set_token ('ENTITY10', total_component_operations);
	--  dbms_profiler.stop_profiler();
   EXCEPTION
      WHEN overlap_error
      THEN
         bom_globals.g_skip_bomtbicx := 'N';
         fnd_message.set_name ('BOM', 'BOM_BAD_COPY_GUI');

         IF specific_copy_flag = 'Y'
         THEN
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
                 VALUES (to_item_id,
                         to_org_id,
                         p_copy_request_id,
                         NULL,
                         get_current_item_rev (to_item_id,
                                               from_org_id,
                                               SYSDATE
                                              ),
                         fnd_message.get,
                         'BOM_COPY',
                         SYSDATE,
                         user_id,
                         SYSDATE,
                         user_id,
                         'E',
                         fnd_global.conc_request_id,
                         NULL,
                         fnd_global.conc_program_id,
                         sysdate
                        );
         ELSE
            ROLLBACK TO begin_bill_copy;
            app_exception.raise_exception;
         END IF;
      WHEN common_error
      THEN
         bom_globals.g_skip_bomtbicx := 'N';
         fnd_message.set_name ('BOM', 'BOM_COMMON_OTHER_ORGS2');

         IF specific_copy_flag = 'Y'
         THEN
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
                 VALUES (to_item_id,
                         to_org_id,
                         p_copy_request_id,
                         NULL,
                         get_current_item_rev (to_item_id,
                                               from_org_id,
                                               SYSDATE
                                              ),
                         fnd_message.get,
                         'BOM_COPY',
                         SYSDATE,
                         user_id,
                         SYSDATE,
                         user_id,
                         'E',
                         fnd_global.conc_request_id,
                         NULL,
                         fnd_global.conc_program_id,
                         sysdate
                        );
         ELSE
            ROLLBACK TO begin_bill_copy;
            app_exception.raise_exception;
         END IF;
      WHEN OTHERS
      THEN
         bom_globals.g_skip_bomtbicx := 'N';
         err_msg := 'COPY_BILL (' || sql_stmt_num || ') ' || SQLERRM;
         fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
         fnd_message.set_token ('ENTITY', err_msg);
         ROLLBACK TO begin_bill_copy;
         app_exception.raise_exception;
   END copy_bill;

/* This function is no longer required.  03-Jan-2006 Bug 4916826
   FUNCTION get_component_path (
      p_item_id          IN   NUMBER,
      p_org_id           IN   NUMBER,
      p_explode_grp_id   IN   NUMBER,
      p_sort_order       IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_component_path   VARCHAR2 (4820);
      l_component_name   VARCHAR2 (240);

      CURSOR c_component_cur (
         c_sort_order         IN   VARCHAR2,
         c_explode_group_id   IN   NUMBER
      )
      IS
         SELECT     component_item_id
               FROM bom_copy_explosions_v bs
              WHERE bs.sort_order <> c_sort_order
                AND bs.GROUP_ID = c_explode_group_id
         START WITH bs.sort_order = c_sort_order
                AND bs.GROUP_ID = c_explode_group_id
         CONNECT BY PRIOR bs.parent_sort_order = bs.sort_order
                AND bs.GROUP_ID = c_explode_group_id;
   BEGIN
      l_component_path := '';

      FOR component_rec IN c_component_cur (p_sort_order, p_explode_grp_id)
      LOOP
         SELECT concatenated_segments
           INTO l_component_name
           FROM mtl_system_items_b_kfv msbk
          WHERE msbk.inventory_item_id = component_rec.component_item_id
            AND msbk.organization_id = p_org_id;

         IF (l_component_path IS NULL)
         THEN
            l_component_path := l_component_name;
         ELSE
            l_component_path := l_component_name || '>' || l_component_path;
         END IF;
      END LOOP;

      RETURN l_component_path;
   END get_component_path;*/

   FUNCTION GET_MESSAGE (p_msg_name IN VARCHAR2, p_comp_item IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      fnd_message.set_name ('BOM', p_msg_name);
      fnd_message.set_token ('COMP_ITEM', p_comp_item);
      RETURN fnd_message.get;
   END;

   FUNCTION GET_MESSAGE (
      p_msg_name        IN   VARCHAR2,
      p_comp_item       IN   VARCHAR2,
      p_assembly_item   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      fnd_message.set_name ('BOM', p_msg_name);
      fnd_message.set_token ('COMP_ITEM', p_comp_item);
      fnd_message.set_token ('ASSEMBLY_ITEM', p_assembly_item);
      RETURN fnd_message.get;
   END;

   FUNCTION GET_MESSAGE (
      p_msg_name        IN   VARCHAR2,
      p_comp_item       IN   VARCHAR2,
      p_assembly_item   IN   VARCHAR2,
      p_comp_rev        IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      fnd_message.set_name ('BOM', p_msg_name);
      fnd_message.set_token ('COMP_ITEM', p_comp_item);
      fnd_message.set_token ('ASSEMBLY_ITEM', p_assembly_item);
      fnd_message.set_token ('COMP_REV', p_comp_rev);
      RETURN fnd_message.get;
   END;

   FUNCTION get_cnt_message (
      p_msg_name        IN   VARCHAR2,
      p_assembly_item   IN   VARCHAR2,
      p_comp_count      IN   NUMBER
   )
      RETURN VARCHAR2
   IS
   BEGIN
      fnd_message.set_name ('BOM', p_msg_name);
      fnd_message.set_token ('ASSEMBLY_ITEM', p_assembly_item);
      fnd_message.set_token ('COMP_CNT', p_comp_count);
      RETURN fnd_message.get;
   END;

   PROCEDURE assign_items_to_copy_to_org (
      p_cp_request_id     IN   NUMBER,
      p_copy_request_id   IN   NUMBER,
      p_from_org_id       IN   NUMBER,
      p_to_org_id         IN   NUMBER,
      p_to_org_code       IN   VARCHAR2,
      p_usr_id            IN   NUMBER,
      p_context_eco       IN   VARCHAR2,
      p_to_item_id        IN   NUMBER,
      p_master_org_id     IN   NUMBER
   )
   IS
      TYPE item_table IS TABLE OF mtl_system_items_interface%ROWTYPE;

      l_item_tbl              item_table;
      l_set_process_id        NUMBER                                     := 0;
      x_item_table            ego_item_pub.item_tbl_type;
      x_inventory_item_id     mtl_system_items_b.inventory_item_id%TYPE;
      x_organization_id       mtl_system_items_b.organization_id%TYPE;
      x_return_status         VARCHAR2 (1);
      x_msg_count             NUMBER (10);
      x_msg_data              VARCHAR2 (2000);
      x_message_list          error_handler.error_tbl_type;
      l_program_appl_id       NUMBER;
      l_program_id            NUMBER;
      l_program_update_date   DATE;
      err_msg                 VARCHAR2 (2000);
      l_return_status         VARCHAR2 (1)                             := 'S';
      l_item_rec_in           inv_item_grp.item_rec_type;
      l_item_rec_out          inv_item_grp.item_rec_type;
      l_error_tbl             inv_item_grp.error_tbl_type;
      x_msg_list              error_handler.error_tbl_type;
      l_item_org_assign_tbl   system.EGO_ITEM_ORG_ASSIGN_TABLE := new system.EGO_ITEM_ORG_ASSIGN_TABLE();
      l_trgt_item_uom_code    mtl_system_items_b.primary_uom_code%TYPE;
      l_trgt_item_name        mtl_system_items_b_kfv.concatenated_segments%TYPE;
	  l_secondary_uom_code    mtl_system_items_b_kfv.secondary_uom_code%TYPE;
	  l_dual_uom_deviation_high mtl_system_items_b_kfv.dual_uom_deviation_high%TYPE;
	  l_dual_uom_deviation_low mtl_system_items_b_kfv.dual_uom_deviation_low%TYPE;
	  l_secondary_default_ind mtl_system_items_b_kfv.secondary_default_ind%TYPE;
	  l_tracking_quantity_ind mtl_system_items_b_kfv.tracking_quantity_ind%TYPE;
	  l_ont_pricing_qty_source mtl_system_items_b_kfv.ont_pricing_qty_source%TYPE;
      l_not_exists            NUMBER := 0;
      l_msg_count             NUMBER := 0;
      l_item_count            NUMBER := 1;
	  l_index                 NUMBER := 0;

      CURSOR l_item_org_csr (
         c_org_id        IN   NUMBER,
         c_org_code      IN   VARCHAR2,
         c_context_eco   IN   VARCHAR2
      )
      IS
         SELECT msibk.inventory_item_id,
                concatenated_segments item_number,
                -- c_org_id organization_id,
                -- c_org_code organization_code,
                msibk.primary_uom_code,
		        msibk.secondary_uom_code,
				msibk.dual_uom_deviation_high,
				msibk.dual_uom_deviation_low,
			    msibk.secondary_default_ind,
				msibk.tracking_quantity_ind,
				msibk.ont_pricing_qty_source
           FROM mtl_system_items_b_kfv msibk,
                bom_copy_explosions_v bev
          WHERE msibk.inventory_item_id = bev.component_item_id
            AND msibk.organization_id = bev.organization_id
            AND (bev.implementation_date IS NOT NULL
                 OR (bev.implementation_date IS NULL
                     AND bev.change_notice = c_context_eco
                     AND bev.acd_type = 1
                    )
                )
			/*
			Pass trgt_comps_eff_date and do this validation
			AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			(
			  SELECT 1
			    FROM bom_components_b bcb
			   WHERE bcb.old_component_sequence_id = bev.component_sequence_id
				 AND bcb.change_notice = context_eco
				 AND bcb.acd_type = 3
			     AND bcb.effectivity_date <= trgt_comps_eff_date
				 AND bcb.implementation_date IS NULL
				 AND bcb.bill_sequence_id = bic.bill_sequence_id
			)
			*/
            AND NOT EXISTS (
                  SELECT 1
                    FROM mtl_system_items_b msib
                   WHERE msib.inventory_item_id = bev.component_item_id
                     AND msib.organization_id = c_org_id)
           AND ( NOT EXISTS (
                     -- Direct Component Action is exclude
                  SELECT 1
                    FROM bom_copy_structure_actions bcsa
                   WHERE bcsa.copy_request_id = p_copy_request_id
                     AND bcsa.organization_id = p_to_org_id
					 AND bcsa.component_sequence_id = bev.component_sequence_id
                     AND bcsa.component_exception_action = 1
                   )
                 OR NOT EXISTS (
                     -- Structure Action is exclude
                  SELECT 1
                    FROM bom_copy_structure_actions bcsa, bom_copy_explosions_v bcev
                   WHERE bcsa.copy_request_id = p_copy_request_id
                     AND bcsa.organization_id = p_to_org_id
                     AND bcsa.structure_exception_action = 1
					 AND bcsa.component_sequence_id = bcev.component_sequence_id
				   START WITH bcev.bill_sequence_id = bev.bill_sequence_id
				 CONNECT BY PRIOR bcev.bill_sequence_id = bcev.comp_bill_seq_id
				     AND bcev.bill_sequence_id <> bev.top_bill_sequence_id
                   )
				)
		  ;
      -- This cursor will select primory uom only when Item does not exist in the destination organization
      CURSOR l_uom_in_master_org_csr
        ( p_item_id IN NUMBER,
          p_master_org_id IN NUMBER,
          p_org_id  IN NUMBER )
      IS
        SELECT mmsib.primary_uom_code, 1 l_not_exists, concatenated_segments,
		       mmsib.secondary_uom_code, mmsib.dual_uom_deviation_high, mmsib.dual_uom_deviation_low,
			   mmsib.secondary_default_ind, mmsib.tracking_quantity_ind, mmsib.ont_pricing_qty_source
          FROM mtl_system_items_b_kfv mmsib
         WHERE mmsib.inventory_item_id = p_item_id
           AND mmsib.organization_id = p_master_org_id
           AND NOT EXISTS
             ( SELECT 1
                 FROM mtl_system_items_b msib
                WHERE msib.inventory_item_id = mmsib.inventory_item_id
                  AND msib.organization_id = p_org_id
              );
   BEGIN
      SAVEPOINT begin_assign_items_to_org;

      IF p_cp_request_id IS NOT NULL
      THEN
         l_program_appl_id := -1;
         l_program_id := -1;
         l_program_update_date := SYSDATE;
      END IF;

      -- First assign the top item and continue with other items if it is successful
      OPEN l_uom_in_master_org_csr (p_to_item_id, p_master_org_id, p_to_org_id);

      LOOP
         FETCH l_uom_in_master_org_csr
          INTO l_trgt_item_uom_code, l_not_exists, l_trgt_item_name,
		       l_secondary_uom_code, l_dual_uom_deviation_high, l_dual_uom_deviation_low,
			   l_secondary_default_ind, l_tracking_quantity_ind, l_ont_pricing_qty_source;

         EXIT WHEN l_uom_in_master_org_csr%NOTFOUND;
      END LOOP;

      IF l_not_exists = 1
      THEN

        l_item_org_assign_tbl.extend();
        l_item_org_assign_tbl(l_item_count) := system.EGO_ITEM_ORG_ASSIGN_REC(1,1,'1','1',1,'1','1',NULL,NULL,NULL,NULL,NULL,NULL);
        l_item_org_assign_tbl(l_item_count).master_organization_id := p_master_org_id;
        l_item_org_assign_tbl(l_item_count).organization_id := p_to_org_id;
        l_item_org_assign_tbl(l_item_count).organization_code := p_to_org_code;
        l_item_org_assign_tbl(l_item_count).primary_uom_code := l_trgt_item_uom_code;
        l_item_org_assign_tbl(l_item_count).inventory_item_id := p_to_item_id;
        l_item_org_assign_tbl(l_item_count).secondary_uom_code := l_secondary_uom_code;
        l_item_org_assign_tbl(l_item_count).dual_uom_deviation_high := l_dual_uom_deviation_high;
        l_item_org_assign_tbl(l_item_count).dual_uom_deviation_low := l_dual_uom_deviation_low;
        l_item_org_assign_tbl(l_item_count).secondary_default_ind := l_secondary_default_ind;
        l_item_org_assign_tbl(l_item_count).tracking_quantity_ind := l_tracking_quantity_ind;
        l_item_org_assign_tbl(l_item_count).ont_pricing_qty_source := l_ont_pricing_qty_source;
      --  l_item_org_assign_tbl(l_item_count).bom_api := 'Y'; -- Not Required. Need to pass p_context for API
        l_item_count := l_item_count + 1; -- As of now one item at a time
      END IF; -- l_not_exists = 1         l_item_rec_in.inventory_item_id := p_to_item_id;
      CLOSE l_uom_in_master_org_csr;
      -- As of now items API does not support grouping of error messages
      -- Once that API is ready we call assign item api in a single call till that time it will be
      -- one for each item.
      FOR item_rec IN l_item_org_csr (p_to_org_id,
                                      p_to_org_code,
                                      p_context_eco
                                     )
      LOOP
         l_item_org_assign_tbl.extend();
         l_item_org_assign_tbl(l_item_count) := system.EGO_ITEM_ORG_ASSIGN_REC(1,1,'1','1',1,'1','1',NULL,NULL,NULL,NULL,NULL,NULL);
         l_item_org_assign_tbl(l_item_count).master_organization_id := p_master_org_id;
         l_item_org_assign_tbl(l_item_count).organization_id := p_to_org_id;
         l_item_org_assign_tbl(l_item_count).organization_code := p_to_org_code;
         l_item_org_assign_tbl(l_item_count).primary_uom_code := item_rec.primary_uom_code;
         l_item_org_assign_tbl(l_item_count).inventory_item_id := item_rec.inventory_item_id;
         l_item_org_assign_tbl(l_item_count).secondary_uom_code := item_rec.secondary_uom_code;
         l_item_org_assign_tbl(l_item_count).dual_uom_deviation_high := item_rec.dual_uom_deviation_high;
         l_item_org_assign_tbl(l_item_count).dual_uom_deviation_low := item_rec.dual_uom_deviation_low;
         l_item_org_assign_tbl(l_item_count).secondary_default_ind := item_rec.secondary_default_ind;
         l_item_org_assign_tbl(l_item_count).tracking_quantity_ind := item_rec.tracking_quantity_ind;
         l_item_org_assign_tbl(l_item_count).ont_pricing_qty_source := item_rec.ont_pricing_qty_source;
         l_item_count := l_item_count + 1; -- As of now one item at a time
      END LOOP; -- FOR item_rec IN l_item_org_csr
	  -- Call the Item's Org Assignment API for all the items together
      ego_item_org_assign_pvt.process_org_assignments
      ( p_item_org_assign_tab => l_item_org_assign_tbl
        ,p_commit => FND_API.G_FALSE
		,p_context => 'BOM'
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
       );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        IF l_item_org_assign_tbl.FIRST IS NOT NULL
		THEN
          l_index := l_item_org_assign_tbl.FIRST;
          WHILE l_index IS NOT NULL
          LOOP
		    IF l_item_org_assign_tbl(l_index).status <> FND_API.G_RET_STS_SUCCESS
			THEN
              INSERT INTO mtl_interface_errors
               ( unique_id,
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
               VALUES (l_item_org_assign_tbl(l_index).inventory_item_id,
                 p_from_org_id,
                 p_copy_request_id,
                 NULL,
                 get_current_item_rev(l_item_org_assign_tbl(l_index).inventory_item_id,

                   p_from_org_id,
                   SYSDATE
                  ),
                 l_item_org_assign_tbl(l_index).error_code,
                 'BOM_COPY',
                 SYSDATE,
                 p_usr_id,
                 SYSDATE,
                 p_usr_id,
                 'E',
                 fnd_global.conc_request_id,
                 NULL,
                 fnd_global.conc_program_id,
                 sysdate
               );
			END IF; -- l_item_org_assign_rec.status <> FND_API.G_RET_STS_SUCCESS
		    l_index := l_item_org_assign_tbl.NEXT(l_index);
          END LOOP; -- WHILE l_index IS NOT NULL End Loop for items
		END IF; -- l_item_org_assign_tbl.FIRST IS NOT NULL
      END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS When API returns non-success status

      -- Sync up the index after item creation
      inv_item_pvt.sync_im_index;
   EXCEPTION
      WHEN OTHERS
      THEN
         err_msg := 'COPY_BILL ( assign_items_to_org )' || SQLERRM;
         fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
         fnd_message.set_token ('ENTITY', err_msg);
         ROLLBACK TO begin_assign_items_to_org;
         app_exception.raise_exception;
   END assign_items_to_copy_to_org;

   PROCEDURE purge_processed_copy_requests (p_request_status IN VARCHAR2)
   IS
   BEGIN
      DELETE FROM bom_copy_structure_actions
            WHERE copy_request_id IN (
                                      SELECT copy_request_id
                                        FROM bom_copy_structure_request
                                       WHERE request_status = p_request_status);

      DELETE FROM bom_copy_organization_list
            WHERE copy_request_id IN (SELECT copy_request_id
                                        FROM bom_copy_structure_request
                                       WHERE request_status = p_request_status);

      DELETE FROM bom_copy_structure_request
            WHERE request_status = p_request_status;
   END purge_processed_copy_requests;

   PROCEDURE purge_processed_request_errors (p_request_status IN VARCHAR2)
   IS
   BEGIN
      DELETE FROM mtl_interface_errors mie
            WHERE EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_request bscr
                      WHERE bscr.copy_request_id = mie.transaction_id
                        AND bscr.request_status = p_request_status
                        AND mie.bo_identifier = 'BOM_COPY');
   END purge_processed_request_errors;

   PROCEDURE get_org_list_for_hierarchy (
      p_hierarchy_name    IN   VARCHAR2,
      p_org_id            IN   NUMBER,
      p_item_id           IN   NUMBER,
      p_structure_name    IN   VARCHAR2,
      p_effectivity_date  IN   DATE,
      x_org_list_tbl      OUT  NOCOPY num_varray,
      x_org_code_tbl      OUT  NOCOPY varchar2_varray,
      x_org_name_tbl      OUT  NOCOPY varchar2_varray,
      x_org_structure_tbl OUT  NOCOPY num_varray,
      x_assembly_type_tbl OUT  NOCOPY num_varray,
      x_item_rev_tbl      OUT  NOCOPY varchar2_varray,
      x_item_rev_id_tbl   OUT  NOCOPY num_varray,
      x_item_rev_lbl_tbl  OUT  NOCOPY varchar2_varray,
      x_item_exists_tbl   OUT  NOCOPY varchar2_varray,
	  x_return_status     OUT NOCOPY VARCHAR2,
	  x_error_msg         OUT NOCOPY VARCHAR2
   )
   IS
      x_org_id_tbl INV_ORGHIERARCHY_PVT.orgID_tbl_type;
      l_count NUMBER := 0;
      l_index NUMBER := 0;
      l_effectivity_date DATE;
   BEGIN
	  x_return_status := fnd_api.G_RET_STS_SUCCESS;
        IF p_effectivity_date < sysdate THEN
          l_effectivity_date := sysdate;
        ELSE
          l_effectivity_date := p_effectivity_date;
        END IF;
        INV_ORGHIERARCHY_PVT.ORG_HIERARCHY_LIST
        ( p_org_hierarchy_name => p_hierarchy_name,
          p_org_hier_level_id => p_org_id,
          x_org_code_list => x_org_id_tbl
        );
        IF x_org_id_tbl.FIRST IS NOT NULL THEN
            x_org_list_tbl := new num_varray();
            x_org_code_tbl := new varchar2_varray();
            x_org_name_tbl := new varchar2_varray();
            x_org_structure_tbl := new num_varray();
            x_assembly_type_tbl := new num_varray();
            x_item_rev_tbl := new varchar2_varray();
            x_item_rev_id_tbl := new num_varray();
            x_item_rev_lbl_tbl := new varchar2_varray();
            x_item_exists_tbl := new varchar2_varray();
            l_index := x_org_id_tbl.FIRST;
            WHILE l_index IS NOT NULL
            LOOP
                x_org_list_tbl.extend();
                x_org_code_tbl.extend();
                x_org_name_tbl.extend();
                x_org_structure_tbl.extend();
                x_assembly_type_tbl.extend();
                x_item_rev_tbl.extend();
                x_item_rev_id_tbl.extend();
                x_item_rev_lbl_tbl.extend();
                x_item_exists_tbl.extend();
                x_org_list_tbl(l_index) := x_org_id_tbl(l_index);
                l_index := x_org_id_tbl.next(l_index);
--              a_debug(' org id ' || i || ' is ' ||x_org_id_tbl(i) || ' list ' || x_org_list_tbl(i));
                l_count := l_count + 1;
            END LOOP;
            IF x_org_list_tbl.FIRST IS NOT NULL THEN
                l_index := x_org_list_tbl.FIRST;
                WHILE l_index IS NOT NULL
                LOOP
                  BEGIN
                    SELECT oav.organization_code, oav.organization_name,
                        CASE
                        WHEN EXISTS ( SELECT 1
                                      FROM bom_structures_b bsb
                                      WHERE bsb.organization_id = oav.organization_id
                                      AND bsb.assembly_item_id = p_item_id
                                      AND NVL(bsb.alternate_bom_designator,bom_globals.get_primary_ui) = NVL(p_structure_name,bom_globals.get_primary_ui)
                                      AND bsb.bill_sequence_id = bsb.common_bill_sequence_id
                                     ) THEN
                            1 -- Structure already exists
                        WHEN EXISTS ( SELECT 1
                                      FROM bom_structures_b bsb
                                      WHERE bsb.organization_id = oav.organization_id
                                      AND bsb.assembly_item_id = p_item_id
                                      AND NVL(bsb.alternate_bom_designator,bom_globals.get_primary_ui) = NVL(p_structure_name,bom_globals.get_primary_ui)
                                      AND bsb.bill_sequence_id <> bsb.common_bill_sequence_id
                                     ) THEN
                            2 -- Structure already exists and it is common structure
                        ELSE
                            0 -- Structure does not exist
                        END AS structure_exists,
                        NVL((SELECT assembly_type
                                     FROM bom_structures_b bsb
                                     WHERE bsb.organization_id = x_org_list_tbl(l_index)
                                     AND bsb.assembly_item_id = p_item_id
                                     AND NVL(bsb.alternate_bom_designator,bom_globals.get_primary_ui) = NVL(p_structure_name,bom_globals.get_primary_ui)
                         ),2) AS assembly_type,
                        (SELECT revision
                           FROM (SELECT revision
                                   FROM mtl_item_revisions_b mir
                                  WHERE inventory_item_id = p_item_id
                                    AND organization_id = x_org_list_tbl(l_index)
                                    AND mir.effectivity_date  <= p_effectivity_date
                                  ORDER BY effectivity_date DESC, revision DESC)
                          WHERE rownum < 2) AS current_item_rev,
                        (SELECT revision_id
                           FROM (SELECT revision_id
                                   FROM mtl_item_revisions_b mir
                                  WHERE inventory_item_id = p_item_id
                                    AND organization_id = x_org_list_tbl(l_index)
                                    AND mir.effectivity_date  <= p_effectivity_date
                                  ORDER BY effectivity_date DESC, revision DESC)
                          WHERE rownum < 2) AS current_item_rev_id,
                        (SELECT revision_label
                           FROM (SELECT revision_label
                                   FROM mtl_item_revisions_b mir
                                  WHERE inventory_item_id = p_item_id
                                    AND organization_id = x_org_list_tbl(l_index)
                                    AND mir.effectivity_date  <= p_effectivity_date
                                  ORDER BY effectivity_date DESC, revision DESC)
                          WHERE rownum < 2) AS current_item_rev_label,
                        CASE
                          WHEN EXISTS
                          (
                             SELECT 1
                             FROM mtl_system_items_b msib
                             WHERE msib.inventory_item_id = p_item_id
                             AND msib.organization_id = x_org_list_tbl(l_index)
                          ) THEN
                          'Y'
                          ELSE
                          'N'
                          END AS item_exists
                        INTO x_org_code_tbl(l_index), x_org_name_tbl(l_index),
                             x_org_structure_tbl(l_index), x_assembly_type_tbl(l_index),
                             x_item_rev_tbl(l_index), x_item_rev_id_tbl(l_index),
                             x_item_rev_lbl_tbl(l_index), x_item_exists_tbl(l_index)
                       FROM org_access_view oav
                     WHERE oav.organization_id = x_org_list_tbl(l_index)
                      AND oav.responsibility_id = fnd_profile.value('RESP_ID')
                      AND oav.resp_application_id = fnd_profile.value('RESP_APPL_ID');
                      l_index := x_org_list_tbl.next(l_index);
					  x_return_status := fnd_api.G_RET_STS_SUCCESS;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         fnd_message.set_name ('BOM', 'BOM_CPY_IP_NO_ORG_IN_HRCHY');
						 x_return_status := fnd_api.G_RET_STS_ERROR;
						 x_error_msg := fnd_message.get;
						 RETURN;
                  END;
               END LOOP;
            END IF;
        END IF;
   END get_org_list_for_hierarchy;


   FUNCTION get_item_exists_in (
      p_item_id           IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000);

      CURSOR c1 (cp_item_id IN NUMBER, cp_copy_request_id IN NUMBER)
      IS
         SELECT mp.organization_code
           FROM mtl_system_items_b msib,
                mtl_parameters mp,
                bom_copy_organization_list bcol
          WHERE msib.inventory_item_id = cp_item_id
            AND msib.organization_id = mp.organization_id
            AND bcol.copy_request_id = cp_copy_request_id
            AND bcol.organization_id = mp.organization_id;

      l_count     NUMBER          := 0;
   BEGIN
      FOR c1_rec IN c1 (p_item_id, p_copy_request_id)
      LOOP
         IF l_count = 0
         THEN
            ret_value := c1_rec.organization_code;
         ELSE
            ret_value := ret_value || ',' || c1_rec.organization_code;
         END IF;

         l_count := l_count + 1;
      END LOOP;

      RETURN ret_value;
   END get_item_exists_in;

   FUNCTION get_structure_exists_in (
      p_item_id           IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000);

      CURSOR c1 (cp_item_id IN NUMBER, cp_copy_request_id IN NUMBER)
      IS
         SELECT mp.organization_code
           FROM mtl_parameters mp,
                bom_copy_organization_list bcol,
                bom_structures_b bsb,
                bom_copy_structure_request bcsr
          WHERE bsb.assembly_item_id = cp_item_id
            AND bcsr.copy_request_id = cp_copy_request_id
            AND bsb.organization_id = bcol.organization_id
            AND NVL (bsb.alternate_bom_designator, bom_globals.get_primary_ui) =
                                 NVL (bcsr.trgt_structure_name, bom_globals.get_primary_ui)
            AND bcol.copy_request_id = bcsr.copy_request_id
            AND bcol.organization_id = mp.organization_id;

      l_count     NUMBER          := 0;
   BEGIN
      FOR c1_rec IN c1 (p_item_id, p_copy_request_id)
      LOOP
         IF l_count = 0
         THEN
            ret_value := c1_rec.organization_code;
         ELSE
            ret_value := ret_value || ',' || c1_rec.organization_code;
         END IF;

         l_count := l_count + 1;
      END LOOP;

      RETURN ret_value;
   END get_structure_exists_in;

   /*
    * This function is not required.  We can display one column for the structure exists info.
    * If we need to provide the common information we may need to provide the other details.
    */
   FUNCTION get_common_structure_exists_in (
      p_item_id       IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000);

      CURSOR c1 (cp_item_id IN NUMBER, cp_copy_request_id IN NUMBER)
      IS
         SELECT mp.organization_code
           FROM mtl_parameters mp,
                bom_copy_organization_list bcol,
                bom_structures_b bsb,
                bom_copy_structure_request bcsr
          WHERE bsb.bill_sequence_id <> bsb.source_bill_sequence_id
            AND bsb.assembly_item_id = cp_item_id
            AND bcsr.copy_request_id = cp_copy_request_id
            AND bsb.organization_id = bcol.organization_id
            AND NVL (bsb.alternate_bom_designator, bom_globals.get_primary_ui) =
                                 NVL (bcsr.trgt_structure_name, bom_globals.get_primary_ui)
            AND bcol.copy_request_id = bcsr.copy_request_id
            AND bcol.organization_id = mp.organization_id;

      l_count     NUMBER          := 0;
   BEGIN
      FOR c1_rec IN c1 (p_item_id, p_copy_request_id)
      LOOP
         IF l_count = 0
         THEN
            ret_value := c1_rec.organization_code;
         ELSE
            ret_value := ret_value || ',' || c1_rec.organization_code;
         END IF;

         l_count := l_count + 1;
      END LOOP;

      RETURN ret_value;
   END get_common_structure_exists_in;

   FUNCTION get_assign_items_in (
      p_item_id           IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000);

      CURSOR c1 (cp_item_id IN NUMBER, cp_copy_request_id IN NUMBER)
      IS
         SELECT mp.organization_code
           FROM mtl_parameters mp,
                bom_copy_organization_list bcol
          WHERE bcol.copy_request_id = cp_copy_request_id
            AND bcol.organization_id = mp.organization_id
            AND NOT EXISTS (
                  SELECT 1
                    FROM mtl_system_items_b msib
                   WHERE msib.inventory_item_id = cp_item_id
                     AND msib.organization_id = bcol.organization_id);

      l_count     NUMBER          := 0;
   BEGIN

      FOR c1_rec IN c1 (p_item_id, p_copy_request_id)
      LOOP
         IF l_count = 0
         THEN
            ret_value := c1_rec.organization_code;
         ELSE
            ret_value := ret_value || ',' || c1_rec.organization_code;
         END IF;

         l_count := l_count + 1;
      END LOOP;

      RETURN ret_value;
   END get_assign_items_in;

   FUNCTION get_copy_structures_in (
      p_item_id       IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000);

      CURSOR c1 (cp_item_id IN NUMBER, cp_copy_request_id IN NUMBER)
      IS
         SELECT mp.organization_code
           FROM mtl_parameters mp,
                bom_copy_organization_list bcol
          WHERE bcol.copy_request_id = cp_copy_request_id
            AND bcol.organization_id = mp.organization_id
            AND bcol.common_structure = 'N'
            AND NOT EXISTS (
                  SELECT 1
                    FROM bom_copy_structure_request bcsr,
                         bom_structures_b bsb
                   WHERE bsb.assembly_item_id = cp_item_id
                     AND bcsr.copy_request_id = bcol.copy_request_id
                     AND bsb.organization_id = bcol.organization_id
                     AND NVL (bsb.alternate_bom_designator, bom_globals.get_primary_ui) =
                                 NVL (bcsr.trgt_structure_name, bom_globals.get_primary_ui));

      l_count     NUMBER          := 0;
   BEGIN
      FOR c1_rec IN c1 (p_item_id, p_copy_request_id)
      LOOP
         IF l_count = 0
         THEN
            ret_value := c1_rec.organization_code;
         ELSE
            ret_value := ret_value || ',' || c1_rec.organization_code;
         END IF;

         l_count := l_count + 1;
      END LOOP;

      RETURN ret_value;
   END get_copy_structures_in;

   FUNCTION get_common_structures_in (
      p_item_id       IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000);

      CURSOR c1 (cp_item_id IN NUMBER, cp_copy_request_id IN NUMBER)
      IS
         SELECT mp.organization_code
           FROM mtl_parameters mp,
                bom_copy_organization_list bcol
          WHERE bcol.copy_request_id = cp_copy_request_id
            AND bcol.organization_id = mp.organization_id
            AND bcol.common_structure = 'Y'
            AND NOT EXISTS (
                  SELECT 1
                    FROM bom_copy_structure_request bcsr,
                         bom_structures_b bsb
                   WHERE bcsr.copy_request_id = bcol.copy_request_id
                     AND bsb.organization_id = bcol.organization_id
                     AND bsb.assembly_item_id = cp_item_id
                     AND NVL (bsb.alternate_bom_designator, bom_globals.get_primary_ui) =
                                 NVL (bcsr.trgt_structure_name, bom_globals.get_primary_ui));

      l_count     NUMBER          := 0;
   BEGIN
      FOR c1_rec IN c1 (p_item_id, p_copy_request_id)
      LOOP
         IF l_count = 0
         THEN
            ret_value := c1_rec.organization_code;
         ELSE
            ret_value := ret_value || ',' || c1_rec.organization_code;
         END IF;

         l_count := l_count + 1;
      END LOOP;

      RETURN ret_value;
   END get_common_structures_in;

    PROCEDURE update_created_by (
      p_user_id IN NUMBER
      ,p_to_bill_sequence_id IN NUMBER )
    IS
    BEGIN
      bom_globals.g_skip_bomtbicx := 'Y';

      UPDATE bom_components_b bic
         SET created_by = p_user_id
       WHERE bic.bill_sequence_id = p_to_bill_sequence_id;

      --Turn on trigger BOMTBICX
      bom_globals.g_skip_bomtbicx := 'N';

    END;

/* This procedure can be used in following scenario
 * When the copy operation creates the new eco or revised items are added to existing eco
 * with current and future option.  In that flow we need to create separate revised items
 * for different effectivity dates
 */
    PROCEDURE copy_bill_for_revised_item
    (
      to_sequence_id               IN   NUMBER,
      from_sequence_id             IN   NUMBER,
      from_org_id                  IN   NUMBER,
      to_org_id                    IN   NUMBER,
      user_id                      IN   NUMBER DEFAULT -1,
      to_item_id                   IN   NUMBER,
      direction                    IN   NUMBER DEFAULT 1,
      to_alternate                 IN   VARCHAR2,
      rev_date                     IN   DATE,
      e_change_notice              IN   VARCHAR2,
      rev_item_seq_id              IN   NUMBER,
      eco_eff_date                 IN   DATE,
      eco_unit_number              IN   VARCHAR2 DEFAULT NULL,
      unit_number                  IN   VARCHAR2 DEFAULT NULL,
      from_item_id                 IN   NUMBER,
      -- Request Id for this copy operation.  Value from BOM_COPY_STRUCTURE_REQUEST_S
      -- To populate the errors in MTL_INTERFACE_ERRORS with this transaction id
      p_copy_request_id            IN   NUMBER,
      --  Unit number for copy to item
      eco_end_item_rev_id          IN   NUMBER DEFAULT NULL,
      -- Structure has been exploded in context of this ECO for copying
      context_eco                  IN   VARCHAR2 DEFAULT NULL,
      p_end_item_rev_id            IN   NUMBER DEFAULT NULL,
      -- Since the JOIN occurs with bom_copy_explosions_v, there could be multiple
      -- sub-assemblies (items) in the exploded structure at different levels
      -- but if we copy once that will be suffice
      p_parent_sort_order          IN   VARCHAR2 DEFAULT NULL,
      p_trgt_str_eff_ctrl          IN   NUMBER DEFAULT 1,
      -- Flag which specifies whether past effective component needs to be copied
      -- This will be 'Y' only for first revised item created
      p_cpy_past_eff_comps         IN   VARCHAR2 DEFAULT 'Y',
	  p_trgt_str_type_id           IN   NUMBER   DEFAULT NULL
    )
	IS
      bom_to_bom              CONSTANT NUMBER                        := 1;
      bom_to_eng              CONSTANT NUMBER                        := 2;
      eng_to_eng              CONSTANT NUMBER                        := 3;
      eng_to_bom              CONSTANT NUMBER                        := 4;
      model                   CONSTANT NUMBER                        := 1;
      option_class            CONSTANT NUMBER                        := 2;
      planning                CONSTANT NUMBER                        := 3;
      STANDARD                CONSTANT NUMBER                        := 4;
      phantom                 CONSTANT NUMBER                        := 6;
      x_from_sequence_id               NUMBER             := from_sequence_id;
      x_from_org_id                    NUMBER                  := from_org_id;
      to_rtg_seq_id                    NUMBER;
      itm_cat_grp_id                   NUMBER;
      dummy                            NUMBER;
      sql_stmt_num                     NUMBER;
      base_item_flag                   NUMBER;
      itm_type                         NUMBER;
      copy_comps                       NUMBER;
      copy_comts                       NUMBER;
      copy_subs                        NUMBER;
      copy_desgs                       NUMBER;
      copy_compops                     NUMBER;
      copy_atts                        NUMBER;
      err_msg                          VARCHAR (2000);
      atp_comp_flag                    VARCHAR2 (1);
      rto_flag                         VARCHAR2 (1);
      old_max                          NUMBER                        := 0;
      new_seq_num                      NUMBER                        := 0;
      processed                        NUMBER                        := 0;
      tmp_var                          NUMBER                        := 0;
      l_to_item_rev_id                 NUMBER                        := -1;
      l_to_item_minor_rev_id           NUMBER                        := 0;
      error_status                     VARCHAR2 (1)                  := 'F';
      msg_count                        NUMBER                        := 0;
      item_rev                         VARCHAR2 (3)                  := NULL;
      l_item_rev_date                  DATE                        := SYSDATE;
      l_from_item_rev_id               NUMBER;
      l_from_item_rev                  VARCHAR2 (3)                  := NULL;
      l_return_status                  VARCHAR2 (1)                  := 'S';
      l_item_number                    VARCHAR2 (80)                 := NULL;
      l_org_code                       VARCHAR2 (3)                  := NULL;
      l_uom_code                       VARCHAR2 (3)                  := NULL;
      p_commit                         VARCHAR2 (8)                := 'FALSE';
      l_msg_count                      NUMBER                        := 0;
      l_item_rec_in                    inv_item_grp.item_rec_type;
      l_item_rec_out                   inv_item_grp.item_rec_type;
      l_error_tbl                      inv_item_grp.error_tbl_type;
      l_dest_pk_col_name_val_pairs     ego_col_name_value_pair_array;
      l_src_pk_col_name_val_pairs      ego_col_name_value_pair_array;
      l_new_str_type                   ego_col_name_value_pair_array;
      l_str_type                       NUMBER;
      l_errorcode                      NUMBER;
      l_msg_data                       VARCHAR2 (100);
      x_acd_type                       NUMBER;
      x_rev_item_seq_id                NUMBER;
      x_e_change_notice                VARCHAR2 (10);
      x_effectivity_date               DATE;
      x_unit_number                    VARCHAR2 (30);
      x_end_item_rev_id                NUMBER;
      x_unit_assembly                  VARCHAR2 (2)                  := 'N';
      overlap_error                    EXCEPTION;
      common_error                     EXCEPTION;
      no_item_rev_exists               EXCEPTION;
      no_minor_rev_exists              EXCEPTION;
      no_minor_rev_code_exists         EXCEPTION;
      l_count1                         NUMBER;
      l_count2                         NUMBER;
      l_count3                         NUMBER;
      l_comp_ctr                       NUMBER;
      l_from_eff_ctrl                  bom_structures_b.effectivity_control%TYPE;
      l_to_eff_ctrl                    bom_structures_b.effectivity_control%TYPE;
      l_no_access_comp_cnt             NUMBER;
      l_fixed_rev                      mtl_item_revisions_b.revision%TYPE;
      l_current_item_rev               mtl_item_revisions_b.revision%TYPE;
      l_current_item_rev_id            mtl_item_revisions_b.revision_id%TYPE;
      l_from_comps                     num_varray            := num_varray();
      l_to_comps                       num_varray            := num_varray();
	    l_last_copied_comp_seq_id        NUMBER                := -1;
      l_default_wip_params             NUMBER;
      l_data_level_name_comp VARCHAR2(30) := 'COMPONENTS_LEVEL';
      l_data_level_id_comp   NUMBER;
      l_old_dtlevel_col_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
      l_new_dtlevel_col_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;


      CURSOR l_common_csr
      IS
         SELECT 1
           FROM DUAL
          WHERE EXISTS (
                   SELECT NULL
                     FROM bom_structures_b bom,
                          bom_inventory_components bic
                    WHERE bom.organization_id <> to_org_id
                      AND bom.common_bill_sequence_id = to_sequence_id
                      AND bic.bill_sequence_id = to_sequence_id
                      AND NOT EXISTS (
                            SELECT NULL
                              FROM mtl_system_items cmsi,
                                   mtl_system_items bmsi
                             WHERE cmsi.organization_id = bom.organization_id
                               AND cmsi.inventory_item_id =
                                                         bic.component_item_id
                               AND bmsi.organization_id = bom.organization_id
                               AND bmsi.inventory_item_id =
                                                          bom.assembly_item_id
                               AND cmsi.eng_item_flag =
                                     DECODE (bom.assembly_type,
                                             1, 'N',
                                             2, cmsi.eng_item_flag
                                            )
                               AND cmsi.bom_enabled_flag = 'Y'
                               AND cmsi.inventory_item_id <>
                                                          bom.assembly_item_id
                               AND ((bmsi.bom_item_type = 1
                                     AND cmsi.bom_item_type <> 3
                                    )
                                    OR (bmsi.bom_item_type = 2
                                        AND cmsi.bom_item_type <> 3
                                       )
                                    OR (bmsi.bom_item_type = 3)
                                    OR (bmsi.bom_item_type = 4
                                        AND (cmsi.bom_item_type = 4
                                             OR (cmsi.bom_item_type IN (1, 2)
                                                 AND cmsi.replenish_to_order_flag =
                                                                           'Y'
                                                 AND bmsi.base_item_id IS NOT NULL
                                                 AND bmsi.replenish_to_order_flag =
                                                                           'Y'
                                                )
                                            )
                                       )
                                   )
                               AND (bmsi.bom_item_type = 3
                                    OR bmsi.pick_components_flag = 'Y'
                                    OR cmsi.pick_components_flag = 'N'
                                   )
                               AND (bmsi.bom_item_type = 3
                                    OR NVL (cmsi.bom_item_type, 4) <> 2
                                    OR (cmsi.bom_item_type = 2
                                        AND ((bmsi.pick_components_flag = 'Y'
                                              AND cmsi.pick_components_flag =
                                                                           'Y'
                                             )
                                             OR (bmsi.replenish_to_order_flag =
                                                                           'Y'
                                                 AND cmsi.replenish_to_order_flag =
                                                                           'Y'
                                                )
                                            )
                                       )
                                   )
                               AND NOT (bmsi.bom_item_type = 4
                                        AND bmsi.pick_components_flag = 'Y'
                                        AND cmsi.bom_item_type = 4
                                        AND cmsi.replenish_to_order_flag = 'Y'
                                       )));

      CURSOR item_rev_cursor (
         p_item_id    IN   NUMBER,
         p_org_id     IN   NUMBER,
         p_rev_date   IN   DATE
      )
      IS
         SELECT   revision_id,
                  revision
             FROM mtl_item_revisions_b mir
            WHERE mir.inventory_item_id = p_item_id
              AND mir.organization_id = p_org_id
              AND mir.effectivity_date <= p_rev_date
              AND ROWNUM < 2
         ORDER BY mir.effectivity_date DESC;

      CURSOR item_minor_rev_cursor (
         p_pk1_value   IN   VARCHAR2,
         p_pk2_value   IN   VARCHAR2,
         p_pk3_value   IN   VARCHAR2
      )
      IS
         SELECT NVL (MAX (minor_revision_id), 0) minor_revision_id
           FROM ego_minor_revisions
          WHERE obj_name = 'EGO_ITEM'
            AND pk1_value = p_pk1_value
            AND NVL (pk2_value, '-1') = NVL (p_pk2_value, '-1')
            AND NVL (pk3_value, '-1') = NVL (p_pk3_value, '-1');

      CURSOR l_org_item_csr (p_item_id IN NUMBER, p_org_id IN NUMBER)
      IS
         SELECT concatenated_segments,
                primary_uom_code
           FROM mtl_system_items_b_kfv
          WHERE inventory_item_id = p_item_id
            AND organization_id = p_org_id;

      CURSOR l_from_to_comps_csr (
         p_from_seq_id   IN   NUMBER,
         p_to_seq_id     IN   NUMBER,
		 p_last_copied_comp_seq_id IN NUMBER
      )
      IS
         SELECT bcb1.component_sequence_id from_component_seq_id,
                bcb2.component_sequence_id to_sequence_id
           FROM bom_components_b bcb1,
                bom_components_b bcb2
          WHERE bcb1.bill_sequence_id = p_from_seq_id
            AND bcb1.component_sequence_id = bcb2.created_by
            AND bcb2.bill_sequence_id = p_to_seq_id
			AND bcb2.component_sequence_id > p_last_copied_comp_seq_id;
        l_index NUMBER := 0;

      CURSOR l_mark_components_csr (
         p_change_notice IN VARCHAR2,
         p_local_org_id IN NUMBER,
         p_bill_seq_id IN NUMBER
      )
      IS
         SELECT eec.change_id,
                bcb.component_sequence_id
           FROM eng_engineering_changes eec,
                bom_components_b bcb
          WHERE eec.change_notice = p_change_notice
            AND eec.organization_id = p_local_org_id
            AND bcb.bill_sequence_id = p_bill_seq_id;
      CURSOR l_fixed_rev_comp_csr (
         p_parent_sort_order IN VARCHAR2
      )
      IS
         SELECT bev.comp_fixed_rev_code
           FROM bom_copy_explosions_v bev
          WHERE bev.sort_order = p_parent_sort_order;
      CURSOR l_eff_date_for_rev_csr (
         p_inventory_item_id IN NUMBER,
         p_organization_id   IN NUMBER,
         p_revision          IN VARCHAR2
      )
      IS
         SELECT effectivity_date
           FROM mtl_item_revisions_b
          WHERE inventory_item_id = p_inventory_item_id
            AND organization_id = p_organization_id
            AND revision = p_revision;

	  CURSOR l_last_copied_comp_seq_id_csr (
	     p_bill_seq_id IN NUMBER
	  )
	  IS
	     SELECT max(bcb.component_sequence_id)
		   FROM bom_components_b bcb
		  WHERE bcb.bill_sequence_id = p_bill_seq_id;

      CURSOR C_DATA_LEVEL(p_data_level_name VARCHAR2) IS
        SELECT DATA_LEVEL_ID
          FROM EGO_DATA_LEVEL_B
         WHERE DATA_LEVEL_NAME = p_data_level_name;

   BEGIN
      SAVEPOINT begin_revised_item_bill_copy;

      FND_PROFILE.GET('BOM:DEFAULT_WIP_VALUES', l_default_wip_params);

      -- reset from_sequence_id to common_bill_sequence_id
      sql_stmt_num := 10;

      SELECT common_bill_sequence_id,
             NVL (common_organization_id, organization_id)
        INTO x_from_sequence_id,
             x_from_org_id
        FROM bom_structures_b
       WHERE bill_sequence_id = x_from_sequence_id;

      SELECT structure_type_id, effectivity_control
        INTO l_str_type, l_from_eff_ctrl
        FROM bom_structures_b
       WHERE bill_sequence_id = from_sequence_id;

      l_to_eff_ctrl := p_trgt_str_eff_ctrl;

      /* Serial Effectivity Implementation */
      IF (bom_eamutil.enabled = 'Y'
          AND bom_eamutil.serial_effective_item (item_id      => from_item_id,
                                                 org_id       => x_from_org_id
                                                ) = 'Y'
         )
         OR (pjm_unit_eff.enabled = 'Y'
             AND pjm_unit_eff.unit_effective_item
                                           (x_item_id              => from_item_id,
                                            x_organization_id      => x_from_org_id
                                           ) = 'Y'
            )
      THEN
         x_unit_assembly := 'Y';
      ELSE
         x_unit_assembly := 'N';
      END IF;

      --Load host variables, bill_atp_comps_flag and bill_rto_flag
      sql_stmt_num := 15;

      SELECT atp_components_flag,
             replenish_to_order_flag,
             DECODE (base_item_id, NULL, -1, 0),
             bom_item_type,
             item_catalog_group_id
        INTO atp_comp_flag,
             rto_flag,
             base_item_flag,
             itm_type,
             itm_cat_grp_id
        FROM mtl_system_items
       WHERE organization_id = to_org_id
         AND inventory_item_id = to_item_id;

      sql_stmt_num := 18;

      x_acd_type := 1;
      x_e_change_notice := e_change_notice;
      x_rev_item_seq_id := rev_item_seq_id;
      x_effectivity_date := eco_eff_date;
      x_unit_number := eco_unit_number;
      x_end_item_rev_id := eco_end_item_rev_id;

      OPEN l_fixed_rev_comp_csr(p_parent_sort_order);
      l_fixed_rev := NULL;
      LOOP
         FETCH l_fixed_rev_comp_csr
          INTO l_fixed_rev;
         EXIT WHEN l_fixed_rev_comp_csr%NOTFOUND;
      END LOOP;
      IF l_fixed_rev_comp_csr%ISOPEN THEN
        CLOSE l_fixed_rev_comp_csr;
      END IF;


      OPEN l_last_copied_comp_seq_id_csr (to_sequence_id);

      LOOP
        FETCH l_last_copied_comp_seq_id_csr
        INTO l_last_copied_comp_seq_id;

        EXIT WHEN l_last_copied_comp_seq_id_csr%NOTFOUND;
      END LOOP;

      IF l_last_copied_comp_seq_id_csr%ISOPEN THEN
        CLOSE l_last_copied_comp_seq_id_csr;
      END IF;

	  IF l_last_copied_comp_seq_id IS NULL THEN
	     l_last_copied_comp_seq_id := -1;
	  END IF;

    FOR c_comp_level IN C_DATA_LEVEL(l_data_level_name_comp) LOOP
      l_data_level_id_comp := c_comp_level.DATA_LEVEL_ID;
    END LOOP;


      OPEN item_rev_cursor (to_item_id, to_org_id, x_effectivity_date);

      LOOP
        FETCH item_rev_cursor
        INTO l_current_item_rev_id,
             l_current_item_rev;

        EXIT WHEN item_rev_cursor%NOTFOUND;
      END LOOP;

      IF item_rev_cursor%ISOPEN THEN
        CLOSE item_rev_cursor;
      END IF;

      /*
      IF l_fixed_rev IS NOT NULL AND trgt_comps_eff_date IS NOT NULL
      THEN
         OPEN l_eff_date_for_rev_csr( to_item_id, to_org_id, l_fixed_rev);
         LOOP
           FETCH l_eff_date_for_rev_csr
           INTO l_item_rev_date;
           EXIT WHEN l_eff_date_for_rev_csr%NOTFOUND;
         END LOOP;
      END IF;
	  */
      OPEN item_rev_cursor (to_item_id, to_org_id, l_item_rev_date);

      LOOP
         FETCH item_rev_cursor
          INTO l_to_item_rev_id,
               item_rev;

         EXIT WHEN item_rev_cursor%NOTFOUND;
      END LOOP;

      IF item_rev IS NULL
         OR '' = item_rev
      THEN
         CLOSE item_rev_cursor;

         RAISE no_item_rev_exists;
      END IF;

      IF item_rev_cursor%ISOPEN THEN
        CLOSE item_rev_cursor;
      END IF;

      OPEN item_rev_cursor (from_item_id, from_org_id, rev_date);

      LOOP
         FETCH item_rev_cursor
          INTO l_from_item_rev_id,
               l_from_item_rev;

         EXIT WHEN item_rev_cursor%NOTFOUND;
      END LOOP;

      IF l_from_item_rev IS NULL
         OR '' = l_from_item_rev
      THEN
         CLOSE item_rev_cursor;

         RAISE no_item_rev_exists;
      END IF;

      IF item_rev_cursor%ISOPEN THEN
        CLOSE item_rev_cursor;
      END IF;

      OPEN item_minor_rev_cursor (TO_CHAR (to_item_id),
                                  TO_CHAR (to_org_id),
                                  TO_CHAR (l_to_item_rev_id)
                                 );

      LOOP
         FETCH item_minor_rev_cursor
          INTO l_to_item_minor_rev_id;

         EXIT WHEN item_minor_rev_cursor%NOTFOUND;
      END LOOP;

      IF l_to_item_minor_rev_id IS NULL
         OR '' = l_to_item_minor_rev_id
      THEN
         CLOSE item_minor_rev_cursor;

         RAISE no_minor_rev_exists;
      END IF;

      IF item_minor_rev_cursor%ISOPEN THEN
        CLOSE item_minor_rev_cursor;
      END IF;


      -- Copies the components if the API is called for selective component copy.
      sql_stmt_num := 20;

         /* Bug : 4185500   Structure Level Attribute copy */
         l_src_pk_col_name_val_pairs :=
            ego_col_name_value_pair_array
                      (ego_col_name_value_pair_obj ('BILL_SEQUENCE_ID',
                                                    TO_CHAR (from_sequence_id)
                                                   )
                      );
         l_dest_pk_col_name_val_pairs :=
            ego_col_name_value_pair_array
                         (ego_col_name_value_pair_obj ('BILL_SEQUENCE_ID',
                                                       TO_CHAR (to_sequence_id)
                                                      )
                         );
         l_new_str_type :=
            ego_col_name_value_pair_array
                            (ego_col_name_value_pair_obj ('STRUCTURE_TYPE_ID',
                                                          TO_CHAR (l_str_type)
                                                         )
                            );
         ego_user_attrs_data_pub.copy_user_attrs_data
                    (p_api_version                 => 1.0,
                     p_application_id              => bom_application_id,
                     p_object_name                 => 'BOM_STRUCTURE',
                     p_old_pk_col_value_pairs      => l_src_pk_col_name_val_pairs,
                     p_new_pk_col_value_pairs      => l_dest_pk_col_name_val_pairs,
                     p_new_cc_col_value_pairs      => l_new_str_type,
                     x_return_status               => l_return_status,
                     x_errorcode                   => l_errorcode,
                     x_msg_count                   => l_msg_count,
                     x_msg_data                    => l_msg_data
                    );
         --turn off the trigger BOMTBICX
         bom_globals.g_skip_bomtbicx := 'Y';

         IF l_from_eff_ctrl = 1 AND l_to_eff_ctrl = 1 THEN -- Date - Date


	   INSERT INTO bom_components_b
                     (shipping_allowed,
                      required_to_ship,
                      required_for_revenue,
                      include_on_ship_docs,
                      include_on_bill_docs,
                      low_quantity,
                      high_quantity,
                      acd_type,
                      component_sequence_id,
                      old_component_sequence_id,
                      bill_sequence_id,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      wip_supply_type,
                      pick_components,
                      supply_subinventory,
                      supply_locator_id,
                      operation_lead_time_percent,
                      revised_item_sequence_id,
                      cost_factor,
                      operation_seq_num,
                      component_item_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      item_num,
                      component_quantity,
                      component_yield_factor,
                      component_remarks,
                      effectivity_date,
                      change_notice,
                      implementation_date,
                      disable_date,
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
                      planning_factor,
                      quantity_related,
                      so_basis,
                      optional,
                      mutually_exclusive_options,
                      include_in_cost_rollup,
                      check_atp,
                      bom_item_type,
                      from_end_item_unit_number,
                      to_end_item_unit_number,
                      optional_on_model,
                      --BUGFIX 2740820
                      parent_bill_seq_id,                     --BUGFIX 2740820
                      model_comp_seq_id,                      --BUGFIX 2740820
                      plan_level,
                      --BUGFIX 2740820
                      enforce_int_requirements,               --BUGFIX 2991472
                      from_object_revision_id,
                      from_minor_revision_id,
                      pk1_value,
                      pk2_value,
                      auto_request_material,
                      -- Bug 3662214 : Added following 4 fields
                      suggested_vendor_name,
                      vendor_id,
                      unit_price,
                      from_end_item_rev_id,
                      to_end_item_rev_id,
                      from_end_item_minor_rev_id,
                      to_end_item_minor_rev_id,
                      component_item_revision_id,
                      component_minor_revision_id,
                      basis_type,
                      to_object_revision_id,
                      to_minor_revision_id
                     )
            SELECT bic.shipping_allowed,
                   bic.required_to_ship,
                   bic.required_for_revenue,
                   bic.include_on_ship_docs,
                   bic.include_on_bill_docs,
                  -- bic.low_quantity,
                  -- bic.high_quantity,
		  DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
		           AA.primary_unit_of_measure,BIC.low_quantity,
		           DECODE(BIC.low_quantity,null,null,          --Added this inner Deocde for Bug 6847530
			   inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                        NULL,
                                        BIC.low_quantity,
                                        NULL,
                                        NULL,
                                        AA.primary_unit_of_measure,
                                        MSI.primary_unit_of_measure))) Comp_low_qty,
		 DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
		           AA.primary_unit_of_measure,BIC.high_quantity,
		           DECODE(BIC.high_quantity,null,null,         --Added this inner Deocde for Bug 6847530
			   inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                        NULL,
                                        BIC.high_quantity,
                                        NULL,
                                        NULL,
                                        AA.primary_unit_of_measure,
                                        MSI.primary_unit_of_measure))) Comp_high_qty,
                   x_acd_type,
                   bom_inventory_components_s.NEXTVAL,
                   DECODE (x_acd_type,
                           NULL, NULL,
                           bom_inventory_components_s.CURRVAL
                          ),
                   to_sequence_id,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bic.wip_supply_type,
                   DECODE (rto_flag, 'Y', 2, bic.pick_components),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_subinventory,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_locator_id,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_locator_id, NULL )
                          ),
                   bic.operation_lead_time_percent,
                   x_rev_item_seq_id,
                   bic.cost_factor,
                   bic.operation_seq_num,
                   bic.component_item_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   bic.component_sequence_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.item_num,
                  -- bic.component_quantity,
		   DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
	                  AA.primary_unit_of_measure,BIC.component_quantity,
		          inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.component_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure)) Comp_qty,
                   bic.component_yield_factor,
                   bic.component_remarks,
                   -- R12 TTM ENH
                   x_effectivity_date,
                   x_e_change_notice,
                   -- Implementation date will be NULL for ECO flow
                   TO_DATE (NULL),
                   CASE
                   -- This flag will be set when current and future option is selected with
                   -- copy through ECO
                   WHEN bic.disable_date IS NOT NULL
                     AND bic.disable_date > x_effectivity_date
                    THEN bic.disable_date
                   ELSE
                     TO_DATE (NULL)
                   END AS disable_date,
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15,
                   bic.planning_factor,
                   bic.quantity_related,
                   bic.so_basis,
                   bic.optional,
                   bic.mutually_exclusive_options,
                   bic.include_in_cost_rollup,
                   bic.check_atp,
                   msi.bom_item_type,
                   to_char(NULL) AS from_end_item_unit_number, -- Date Eff Bill will not have from_end_item_unit_numbers
                   to_char(NULL) AS to_end_item_unit_number, -- Date Eff Bill will not have to_end_item_unit_numbers
                   bic.optional_on_model,
                   --BUGFIX 2740820
                   bic.parent_bill_seq_id,                    --BUGFIX 2740820
                   bic.model_comp_seq_id,
                   --BUGFIX 2740820
                   bic.plan_level,                            --BUGFIX 2740820
                   bic.enforce_int_requirements,
                   -- Either Fixed or Floating rev, the components will be from when its created, current item rev
                   l_current_item_rev_id,
                   -- Minor rev is not supported. Populated the first minor rev
                   0,
                   bic.component_item_id,
                   to_org_id,
                   bic.auto_request_material,
                   -- Bug 3662214 : Added following 4 fields
                   bic.suggested_vendor_name,
                   bic.vendor_id,
                   bic.unit_price,
                   to_number(NULL) AS from_end_item_rev_id, -- From End Item Rev Ids won't be set for Date Eff Bill
                   to_number(NULL) AS to_end_item_rev_id, -- To End Item Rev Ids won't be set for Date Eff Bill
                   -- For Minor rev Ids
                   0 AS from_end_item_minor_rev_id,
                   0 AS to_end_item_minor_rev_id,
                   (
                     SELECT tmirb.revision_id
                       FROM mtl_item_revisions_b fmirb,
                            mtl_item_revisions_b tmirb
                      WHERE tmirb.inventory_item_id = bic.component_item_id
                        AND tmirb.organization_id = to_org_id
                        AND tmirb.revision = fmirb.revision
                        AND fmirb.revision_id = bic.component_item_revision_id
                   ) AS component_item_revision_id,
                   CASE
                   WHEN bic.component_item_revision_id IS NULL
                    THEN to_number(NULL)
                   ELSE
                   -- Minor revision is not supported
                    0
                   END AS component_minor_revision_id,
                   bic.basis_type,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                   -- For fixed rev copy the components as fixed rev
                     THEN l_to_item_rev_id
                   ELSE
                     to_number(NULL)
                   END AS to_object_revision_id,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                     THEN 0
                   ELSE
                     to_number(NULL)
                   END AS to_minor_revision_id
              FROM bom_components_b bic,
                   mtl_system_items msi,
		   MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = x_from_sequence_id
               AND bic.component_item_id = msi.inventory_item_id
               AND bic.component_item_id <> to_item_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND msi.organization_id = to_org_id
       	       AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
               AND AA.organization_id = from_org_id   -- Added corresponding to Bug 6510185

               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND ((base_item_flag = -1
                     AND itm_type = 4
                     AND msi.bom_item_type = 4
                    )
                    OR base_item_flag <> -1
                    OR itm_type <> 4
                   )
               AND ((bic.implementation_date IS NOT NULL)
                    OR (bic.implementation_date IS NULL
                        AND bic.change_notice = context_eco
                        AND ( bic.acd_type = 1 OR bic.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb
				   WHERE bcb.old_component_sequence_id = bic.component_sequence_id
					 AND bcb.change_notice = context_eco
					 AND bcb.acd_type = 3
					 AND bcb.effectivity_date <= x_effectivity_date
					 AND bcb.implementation_date IS NULL
					 AND bcb.bill_sequence_id = bic.bill_sequence_id
			   )
			   AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bic.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND bic.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bic.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
			   AND ( ( p_cpy_past_eff_comps = 'Y' AND bev.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			     OR ( p_cpy_past_eff_comps = 'N' AND bev.effectivity_date = rev_date )
			   )
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
				  );
         ELSIF ( ( l_from_eff_ctrl = 2 AND l_to_eff_ctrl = 2 ) -- Unit
                 OR ( l_from_eff_ctrl = 3 AND l_to_eff_ctrl = 3 ) -- Serial
                 ) THEN


	   INSERT INTO bom_components_b
                     (shipping_allowed,
                      required_to_ship,
                      required_for_revenue,
                      include_on_ship_docs,
                      include_on_bill_docs,
                      low_quantity,
                      high_quantity,
                      acd_type,
                      component_sequence_id,
                      old_component_sequence_id,
                      bill_sequence_id,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      wip_supply_type,
                      pick_components,
                      supply_subinventory,
                      supply_locator_id,
                      operation_lead_time_percent,
                      revised_item_sequence_id,
                      cost_factor,
                      operation_seq_num,
                      component_item_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      item_num,
                      component_quantity,
                      component_yield_factor,
                      component_remarks,
                      effectivity_date,
                      change_notice,
                      implementation_date,
                      disable_date,
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
                      planning_factor,
                      quantity_related,
                      so_basis,
                      optional,
                      mutually_exclusive_options,
                      include_in_cost_rollup,
                      check_atp,
                      bom_item_type,
                      from_end_item_unit_number,
                      to_end_item_unit_number,
                      optional_on_model,
                      --BUGFIX 2740820
                      parent_bill_seq_id,                     --BUGFIX 2740820
                      model_comp_seq_id,                      --BUGFIX 2740820
                      plan_level,
                      --BUGFIX 2740820
                      enforce_int_requirements,               --BUGFIX 2991472
                      from_object_revision_id,
                      from_minor_revision_id,
                      pk1_value,
                      pk2_value,
                      auto_request_material,
                      -- Bug 3662214 : Added following 4 fields
                      suggested_vendor_name,
                      vendor_id,
                      unit_price,
                      from_end_item_rev_id,
                      to_end_item_rev_id,
                      from_end_item_minor_rev_id,
                      to_end_item_minor_rev_id,
                      component_item_revision_id,
                      component_minor_revision_id,
                      basis_type,
                      to_object_revision_id,
                      to_minor_revision_id
                     )
            SELECT bic.shipping_allowed,
                   bic.required_to_ship,
                   bic.required_for_revenue,
                   bic.include_on_ship_docs,
                   bic.include_on_bill_docs,
                   --bic.low_quantity,
                   --bic.high_quantity,
		   DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.low_quantity,
                          DECODE(BIC.low_quantity,null,null,          --Added this inner Deocde for Bug 6847530
			  inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                        NULL,
                                        BIC.low_quantity,
                                        NULL,
                                        NULL,
                                        AA.primary_unit_of_measure,
                                        MSI.primary_unit_of_measure))) Comp_low_qty,
                  DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                         AA.primary_unit_of_measure,BIC.high_quantity,
                         DECODE(BIC.high_quantity,null,null,             --Added this inner Deocde for Bug 6847530
			 inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                        NULL,
                                        BIC.high_quantity,
                                        NULL,
                                        NULL,
                                        AA.primary_unit_of_measure,
                                        MSI.primary_unit_of_measure))) Comp_high_qty,
                   x_acd_type,
                   bom_inventory_components_s.NEXTVAL,
                   DECODE (x_acd_type,
                           NULL, NULL,
                           bom_inventory_components_s.CURRVAL
                          ),
                   to_sequence_id,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bic.wip_supply_type,
                   DECODE (rto_flag, 'Y', 2, bic.pick_components),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_subinventory,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_locator_id,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_locator_id, NULL )
                          ),
                   bic.operation_lead_time_percent,
                   x_rev_item_seq_id,
                   bic.cost_factor,
                   bic.operation_seq_num,
                   bic.component_item_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   bic.component_sequence_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.item_num,
                 --  bic.component_quantity,
                  DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                         AA.primary_unit_of_measure,BIC.component_quantity,
                         inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                    NULL,
                                                    BIC.component_quantity,
                                                    NULL,
                                                    NULL,
                                                    AA.primary_unit_of_measure,
                                                    MSI.primary_unit_of_measure)) Comp_qty,
                   bic.component_yield_factor,
                   bic.component_remarks,
                   -- R12 TTM ENH
                   -- For Unit/Serial it eff date will be sysdate
                   sysdate AS effectivity_date,
                   x_e_change_notice,
                   -- Implementation date will be NULL for ECO flow and SYSDATE for inline copy
                   TO_DATE (NULL),
                   -- For Unit/Serial Eff disable date will be null
                   to_date(NULL) AS disable_date,
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15,
                   bic.planning_factor,
                   bic.quantity_related,
                   bic.so_basis,
                   bic.optional,
                   bic.mutually_exclusive_options,
                   bic.include_in_cost_rollup,
                   bic.check_atp,
                   msi.bom_item_type,
                   x_unit_number,
                   CASE
				   WHEN bic.to_end_item_unit_number IS NOT NULL
                     AND bic.to_end_item_unit_number > x_unit_number
                    THEN bic.to_end_item_unit_number
                   ELSE
                     to_char(NULL)
                   END AS to_end_item_unit_number,
                   bic.optional_on_model,
                   --BUGFIX 2740820
                   bic.parent_bill_seq_id,                    --BUGFIX 2740820
                   bic.model_comp_seq_id,
                   --BUGFIX 2740820
                   bic.plan_level,                            --BUGFIX 2740820
                   bic.enforce_int_requirements,
                   -- Either Fixed or Floating rev, the components will be from when its created, current item rev
                   l_current_item_rev_id,
                   -- Minor rev is not supported. Populated the first minor rev
                   0,
                   bic.component_item_id,
                   to_org_id,
                   bic.auto_request_material,
                   -- Bug 3662214 : Added following 4 fields
                   bic.suggested_vendor_name,
                   bic.vendor_id,
                   bic.unit_price,
                   to_number(NULL) AS from_end_item_rev_id,
                   to_number(NULL) AS to_end_item_rev_id,
                   -- For Minor rev Ids
                   0 AS from_end_item_minor_rev_id,
                   0 AS to_end_item_minor_rev_id,
                   (
                     SELECT tmirb.revision_id
                       FROM mtl_item_revisions_b fmirb,
                            mtl_item_revisions_b tmirb
                      WHERE tmirb.inventory_item_id = bic.component_item_id
                        AND tmirb.organization_id = to_org_id
                        AND tmirb.revision = fmirb.revision
                        AND fmirb.revision_id = bic.component_item_revision_id
                   ) AS component_item_revision_id,
                   CASE
                   WHEN bic.component_item_revision_id IS NULL
                    THEN to_number(NULL)
                   ELSE
                   -- Minor revision is not supported
                    0
                   END AS component_minor_revision_id,
                   bic.basis_type,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                   -- For fixed rev copy the components as fixed rev
                     THEN l_to_item_rev_id
                   ELSE
                     to_number(NULL)
                   END AS to_object_revision_id,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                     THEN 0
                   ELSE
                     to_number(NULL)
                   END AS to_minor_revision_id
              FROM bom_components_b bic,
                   mtl_system_items msi,
		   MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = x_from_sequence_id
               AND bic.component_item_id = msi.inventory_item_id
               AND bic.component_item_id <> to_item_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND msi.organization_id = to_org_id
       	       AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
               AND AA.organization_id = from_org_id   -- Added corresponding to Bug 6510185
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND ((base_item_flag = -1
                     AND itm_type = 4
                     AND msi.bom_item_type = 4
                    )
                    OR base_item_flag <> -1
                    OR itm_type <> 4
                   )
               AND ((bic.implementation_date IS NOT NULL)
                    OR (bic.implementation_date IS NULL
                        AND bic.change_notice = context_eco
                        AND ( bic.acd_type = 1 OR bic.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb
				   WHERE bcb.old_component_sequence_id = bic.component_sequence_id
					 AND bcb.change_notice = context_eco
					 AND bcb.acd_type = 3
					 AND bcb.effectivity_date <= x_effectivity_date
					 AND bcb.implementation_date IS NULL
					 AND bcb.bill_sequence_id = bic.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bic.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND bic.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bic.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                         AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
			   AND ( ( p_cpy_past_eff_comps = 'Y' AND bev.from_end_item_unit_number <= unit_number) -- For first revised item we can have past eff comps as eff on the target date
			     OR ( p_cpy_past_eff_comps = 'N' AND bev.from_end_item_unit_number = unit_number )
			   )
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
				  );
         ELSIF l_from_eff_ctrl = 4 AND l_to_eff_ctrl = 4 THEN -- Rev - Rev


	   INSERT INTO bom_components_b
                     (shipping_allowed,
                      required_to_ship,
                      required_for_revenue,
                      include_on_ship_docs,
                      include_on_bill_docs,
                      low_quantity,
                      high_quantity,
                      acd_type,
                      component_sequence_id,
                      old_component_sequence_id,
                      bill_sequence_id,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      wip_supply_type,
                      pick_components,
                      supply_subinventory,
                      supply_locator_id,
                      operation_lead_time_percent,
                      revised_item_sequence_id,
                      cost_factor,
                      operation_seq_num,
                      component_item_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      item_num,
                      component_quantity,
                      component_yield_factor,
                      component_remarks,
                      effectivity_date,
                      change_notice,
                      implementation_date,
                      disable_date,
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
                      planning_factor,
                      quantity_related,
                      so_basis,
                      optional,
                      mutually_exclusive_options,
                      include_in_cost_rollup,
                      check_atp,
                      bom_item_type,
                      from_end_item_unit_number,
                      to_end_item_unit_number,
                      optional_on_model,
                      --BUGFIX 2740820
                      parent_bill_seq_id,                     --BUGFIX 2740820
                      model_comp_seq_id,                      --BUGFIX 2740820
                      plan_level,
                      --BUGFIX 2740820
                      enforce_int_requirements,               --BUGFIX 2991472
                      from_object_revision_id,
                      from_minor_revision_id,
                      pk1_value,
                      pk2_value,
                      auto_request_material,
                      -- Bug 3662214 : Added following 4 fields
                      suggested_vendor_name,
                      vendor_id,
                      unit_price,
                      from_end_item_rev_id,
                      to_end_item_rev_id,
                      from_end_item_minor_rev_id,
                      to_end_item_minor_rev_id,
                      component_item_revision_id,
                      component_minor_revision_id,
                      basis_type,
                      to_object_revision_id,
                      to_minor_revision_id
                     )
            SELECT bic.shipping_allowed,
                   bic.required_to_ship,
                   bic.required_for_revenue,
                   bic.include_on_ship_docs,
                   bic.include_on_bill_docs,
                   --bic.low_quantity,
                   --bic.high_quantity,
                  DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                         AA.primary_unit_of_measure,BIC.low_quantity,
                         DECODE(BIC.low_quantity,null,null,             --Added this inner Deocde for Bug 6847530
			 inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                            NULL,
                                            BIC.low_quantity,
                                            NULL,
                                            NULL,
                                            AA.primary_unit_of_measure,
                                            MSI.primary_unit_of_measure))) Comp_low_qty,
                 DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                        AA.primary_unit_of_measure,BIC.high_quantity,
                        DECODE(BIC.high_quantity,null,null,            --Added this inner Deocde for Bug 6847530
			inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                            NULL,
                                            BIC.high_quantity,
                                            NULL,
                                            NULL,
                                            AA.primary_unit_of_measure,
                                            MSI.primary_unit_of_measure))) Comp_high_qty,
                   x_acd_type,
                   bom_inventory_components_s.NEXTVAL,
                   DECODE (x_acd_type,
                           NULL, NULL,
                           bom_inventory_components_s.CURRVAL
                          ),
                   to_sequence_id,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bic.wip_supply_type,
                   DECODE (rto_flag, 'Y', 2, bic.pick_components),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_subinventory,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_locator_id,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_locator_id, NULL )
                          ),
                   bic.operation_lead_time_percent,
                   x_rev_item_seq_id,
                   bic.cost_factor,
                   bic.operation_seq_num,
                   bic.component_item_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   bic.component_sequence_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.item_num,
                   --bic.component_quantity,
		   DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.component_quantity,
                          inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.component_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure)) Comp_qty,
                   bic.component_yield_factor,
                   bic.component_remarks,
                   -- R12 TTM ENH
                   -- For Rev Eff Structure the eff date will be sysdate
                   sysdate AS effectivity_date,
                   x_e_change_notice,
                   -- Implementation date will be NULL for ECO flow and SYSDATE for inline copy
                   TO_DATE (NULL),
                   -- For Rev Eff structure the disable date will be null
                   to_date(NULL) AS disable_date,
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15,
                   bic.planning_factor,
                   bic.quantity_related,
                   bic.so_basis,
                   bic.optional,
                   bic.mutually_exclusive_options,
                   bic.include_in_cost_rollup,
                   --DECODE(atp_comp_flag, 'Y', CHECK_ATP, 2),  fixed bug 2249375
                   bic.check_atp,
                   msi.bom_item_type,
                   to_char(NULL) AS from_end_item_unit_number,
                   to_char(NULL) AS to_end_item_unit_number,
                   bic.optional_on_model,
                   --BUGFIX 2740820
                   bic.parent_bill_seq_id,                    --BUGFIX 2740820
                   bic.model_comp_seq_id,
                   --BUGFIX 2740820
                   bic.plan_level,                            --BUGFIX 2740820
                   bic.enforce_int_requirements,
                   -- Either Fixed or Floating rev, the components will be from when its created, current item rev
                   l_current_item_rev_id,
                   -- Minor rev is not supported. Populated the first minor rev
                   0,
                   bic.component_item_id,
                   to_org_id,
                   bic.auto_request_material,
                   -- Bug 3662214 : Added following 4 fields
                   bic.suggested_vendor_name,
                   bic.vendor_id,
                   bic.unit_price,
				   x_end_item_rev_id,
                   -- This release we are not supporting transformation -- 14 Mar 2005
                   -- This case is to handle the revised item creation from TTM flow
                   -- This is the first case
                   CASE
                   WHEN bic.to_end_item_rev_id IS NOT NULL
                     AND (
                         EXISTS
                             (
                                SELECT tmirb.revision_id
                                  FROM mtl_item_revisions_b fmirb,
                                       mtl_item_revisions_b tmirb
                                 WHERE tmirb.inventory_item_id = to_item_id
                                   AND tmirb.organization_id = to_org_id
                                   AND tmirb.revision = fmirb.revision
                                   AND fmirb.revision_id = bic.to_end_item_rev_id
                             )
                       AND
                             (
                               SELECT REVISION
                                 FROM MTL_ITEM_REVISIONS_B
                                WHERE REVISION_ID = bic.to_end_item_rev_id
                             ) >
                             (
                               SELECT REVISION
                                 FROM MTL_ITEM_REVISIONS_B
                                WHERE REVISION_ID = x_end_item_rev_id
                             )
                            )
                   THEN
                         (
                           SELECT tmirb.revision_id
                             FROM mtl_item_revisions_b fmirb,
                                  mtl_item_revisions_b tmirb
                            WHERE tmirb.inventory_item_id = to_item_id
                              AND tmirb.organization_id = to_org_id
                              AND tmirb.revision = fmirb.revision
                              AND fmirb.revision_id = bic.to_end_item_rev_id
                         )
                   ELSE
                      to_number(NULL)
                   END AS to_end_item_rev_id,
                   -- For Minor rev Ids
                   0 AS from_end_item_minor_rev_id,
                   0 AS to_end_item_minor_rev_id,
                   (
                     SELECT tmirb.revision_id
                       FROM mtl_item_revisions_b fmirb,
                            mtl_item_revisions_b tmirb
                      WHERE tmirb.inventory_item_id = bic.component_item_id
                        AND tmirb.organization_id = to_org_id
                        AND tmirb.revision = fmirb.revision
                        AND fmirb.revision_id = bic.component_item_revision_id
                   ) AS component_item_revision_id,
                   CASE
                   WHEN bic.component_item_revision_id IS NULL
                    THEN to_number(NULL)
                   ELSE
                   -- Minor revision is not supported
                    0
                   END AS component_minor_revision_id,
                   bic.basis_type,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                   -- For fixed rev copy the components as fixed rev
                     THEN l_to_item_rev_id
                   ELSE
                     to_number(NULL)
                   END AS to_object_revision_id,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                     THEN 0
                   ELSE
                     to_number(NULL)
                   END AS to_minor_revision_id
              FROM bom_components_b bic,
                   mtl_system_items msi,
		   MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = x_from_sequence_id
               AND bic.component_item_id = msi.inventory_item_id
               AND bic.component_item_id <> to_item_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND msi.organization_id = to_org_id
               AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
               AND AA.organization_id = from_org_id   -- Added corresponding to Bug 6510185
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND ((base_item_flag = -1
                     AND itm_type = 4
                     AND msi.bom_item_type = 4
                    )
                    OR base_item_flag <> -1
                    OR itm_type <> 4
                   )
               AND ((bic.implementation_date IS NOT NULL)
                    OR (bic.implementation_date IS NULL
                        AND bic.change_notice = context_eco
                        AND ( bic.acd_type = 1 OR bic.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb
				   WHERE bcb.old_component_sequence_id = bic.component_sequence_id
					 AND bcb.change_notice = context_eco
					 AND bcb.acd_type = 3
					 AND bcb.effectivity_date <= x_effectivity_date
					 AND bcb.implementation_date IS NULL
					 AND bcb.bill_sequence_id = bic.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bic.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND bic.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bic.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
			   AND ( p_cpy_past_eff_comps = 'Y' AND ( ( SELECT mirb.revision
			                                              FROM mtl_item_revisions_b mirb
														 WHERE mirb.revision_id = bev.from_end_item_rev_id
													    )
														<=
														(
                                                        SELECT mirb.revision
			                                              FROM mtl_item_revisions_b mirb
														 WHERE mirb.revision_id = p_end_item_rev_id
														 )
														) -- For first revised item we can have past eff comps as eff on the target date
			     OR ( p_cpy_past_eff_comps = 'N' AND bev.from_end_item_rev_id = p_end_item_rev_id )
			   )
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
				  );
         ELSIF l_from_eff_ctrl = 4 AND l_to_eff_ctrl = 1 THEN -- Rev - Date


	   INSERT INTO bom_components_b
                     (shipping_allowed,
                      required_to_ship,
                      required_for_revenue,
                      include_on_ship_docs,
                      include_on_bill_docs,
                      low_quantity,
                      high_quantity,
                      acd_type,
                      component_sequence_id,
                      old_component_sequence_id,
                      bill_sequence_id,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      wip_supply_type,
                      pick_components,
                      supply_subinventory,
                      supply_locator_id,
                      operation_lead_time_percent,
                      revised_item_sequence_id,
                      cost_factor,
                      operation_seq_num,
                      component_item_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      item_num,
                      component_quantity,
                      component_yield_factor,
                      component_remarks,
                      effectivity_date,
                      change_notice,
                      implementation_date,
                      disable_date,
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
                      planning_factor,
                      quantity_related,
                      so_basis,
                      optional,
                      mutually_exclusive_options,
                      include_in_cost_rollup,
                      check_atp,
                      bom_item_type,
                      from_end_item_unit_number,
                      to_end_item_unit_number,
                      optional_on_model,
                      --BUGFIX 2740820
                      parent_bill_seq_id,                     --BUGFIX 2740820
                      model_comp_seq_id,                      --BUGFIX 2740820
                      plan_level,
                      --BUGFIX 2740820
                      enforce_int_requirements,               --BUGFIX 2991472
                      from_object_revision_id,
                      from_minor_revision_id,
                      pk1_value,
                      pk2_value,
                      auto_request_material,
                      -- Bug 3662214 : Added following 4 fields
                      suggested_vendor_name,
                      vendor_id,
                      unit_price,
                      from_end_item_rev_id,
                      to_end_item_rev_id,
                      from_end_item_minor_rev_id,
                      to_end_item_minor_rev_id,
                      component_item_revision_id,
                      component_minor_revision_id,
                      basis_type,
                      to_object_revision_id,
                      to_minor_revision_id
                     )
            SELECT bic.shipping_allowed,
                   bic.required_to_ship,
                   bic.required_for_revenue,
                   bic.include_on_ship_docs,
                   bic.include_on_bill_docs,
                   --bic.low_quantity,
                   --bic.high_quantity,
                   DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.low_quantity,
                          DECODE(BIC.low_quantity,null,null,       --Added this inner Deocde for Bug 6847530
			  inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.low_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure))) Comp_low_qty,
	           DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
			  AA.primary_unit_of_measure,BIC.high_quantity,
		          DECODE(BIC.high_quantity,null,null,          --Added this inner Deocde for Bug 6847530
			  inv_convert.INV_UM_CONVERT(BIC.component_item_id,
			                        NULL,
				                BIC.high_quantity,
					        NULL,
						NULL,
	                                        AA.primary_unit_of_measure,
		                                MSI.primary_unit_of_measure))) Comp_high_qty,

		   x_acd_type,
                   bom_inventory_components_s.NEXTVAL,
                   DECODE (x_acd_type,
                           NULL, NULL,
                           bom_inventory_components_s.CURRVAL
                          ),
                   to_sequence_id,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bic.wip_supply_type,
                   DECODE (rto_flag, 'Y', 2, bic.pick_components),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_subinventory,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_locator_id,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_locator_id, NULL )
                          ),
                   bic.operation_lead_time_percent,
                   x_rev_item_seq_id,
                   bic.cost_factor,
                   bic.operation_seq_num,
                   bic.component_item_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   bic.component_sequence_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.item_num,
                   --bic.component_quantity,
   	           DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.component_quantity,
                          inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.component_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure)) Comp_qty,
                   bic.component_yield_factor,
                   bic.component_remarks,
		   x_effectivity_date,
                   x_e_change_notice,
                   -- Implementation date will be NULL for ECO flow and SYSDATE for inline copy
                   TO_DATE (NULL),
                   CASE
                   WHEN bic.to_end_item_rev_id IS NULL
                     THEN to_date(NULL)
                   -- This flag will be set when current and future option is selected with
                   -- copy through ECO
                   WHEN bic.to_end_item_rev_id IS NOT NULL
                     AND (
                          (
                           SELECT fmirb.effectivity_date
                             FROM mtl_item_revisions_b fmirb
                            WHERE fmirb.revision_id = bic.to_end_item_rev_id
                          ) > x_effectivity_date
                         )
                    THEN (
                          SELECT fmirb.effectivity_date
                            FROM mtl_item_revisions_b fmirb
                           WHERE fmirb.revision_id = bic.to_end_item_rev_id
                         )
                   -- Past disabled components will be copied with disable date as null
                   WHEN  (
                          ( SELECT fmirb.effectivity_date
                              FROM mtl_item_revisions_b fmirb
                             WHERE fmirb.revision_id = bic.to_end_item_rev_id
                           ) < x_effectivity_date
                         )
                     THEN TO_DATE (NULL)
                   -- Past disabled components will be copied with disable date as null
                   ELSE
                     -- Future disabled components should be disabled as per the disable date of component
                     bic.disable_date
                   END AS disable_date,
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15,
                   bic.planning_factor,
                   bic.quantity_related,
                   bic.so_basis,
                   bic.optional,
                   bic.mutually_exclusive_options,
                   bic.include_in_cost_rollup,
                   bic.check_atp,
                   msi.bom_item_type,
                   to_char(NULL) AS from_end_item_unit_number, -- Date Eff Bill will not have from_end_item_unit_numbers
                   to_char(NULL) AS to_end_item_unit_number, -- Date Eff Bill will not have to_end_item_unit_numbers
                   bic.optional_on_model,
                   --BUGFIX 2740820
                   bic.parent_bill_seq_id,                    --BUGFIX 2740820
                   bic.model_comp_seq_id,
                   --BUGFIX 2740820
                   bic.plan_level,                            --BUGFIX 2740820
                   bic.enforce_int_requirements,
                   -- Either Fixed or Floating rev, the components will be from when its created, current item rev
                   l_current_item_rev_id,
                   -- Minor rev is not supported. Populated the first minor rev
                   0,
                   bic.component_item_id,
                   to_org_id,
                   bic.auto_request_material,
                   -- Bug 3662214 : Added following 4 fields
                   bic.suggested_vendor_name,
                   bic.vendor_id,
                   bic.unit_price,
                   to_number(NULL) AS from_end_item_rev_id, -- From End Item Rev Ids won't be set for Date Eff Bill
                   to_number(NULL) AS to_end_item_rev_id, -- To End Item Rev Ids won't be set for Date Eff Bill
                   -- For Minor rev Ids
                   0 AS from_end_item_minor_rev_id,
                   0 AS to_end_item_minor_rev_id,
                   (
                     SELECT tmirb.revision_id
                       FROM mtl_item_revisions_b fmirb,
                            mtl_item_revisions_b tmirb
                      WHERE tmirb.inventory_item_id = bic.component_item_id
                        AND tmirb.organization_id = to_org_id
                        AND tmirb.revision = fmirb.revision
                        AND fmirb.revision_id = bic.component_item_revision_id
                   ) AS component_item_revision_id,
                   CASE
                   WHEN bic.component_item_revision_id IS NULL
                    THEN to_number(NULL)
                   ELSE
                   -- Minor revision is not supported
                    0
                   END AS component_minor_revision_id,
                   bic.basis_type,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                   -- For fixed rev copy the components as fixed rev
                     THEN l_to_item_rev_id
                   ELSE
                     to_number(NULL)
                   END AS to_object_revision_id,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                     THEN 0
                   ELSE
                     to_number(NULL)
                   END AS to_minor_revision_id
              FROM bom_components_b bic,
                   mtl_system_items msi,
		    MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = x_from_sequence_id
               AND bic.component_item_id = msi.inventory_item_id
               AND bic.component_item_id <> to_item_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND msi.organization_id = to_org_id
               AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
               AND AA.organization_id = from_org_id   -- Added corresponding to Bug 6510185
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND ((base_item_flag = -1
                     AND itm_type = 4
                     AND msi.bom_item_type = 4
                    )
                    OR base_item_flag <> -1
                    OR itm_type <> 4
                   )
               AND ((bic.implementation_date IS NOT NULL)
                    OR (bic.implementation_date IS NULL
                        AND bic.change_notice = context_eco
                        AND ( bic.acd_type = 1 OR bic.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb
				   WHERE bcb.old_component_sequence_id = bic.component_sequence_id
					 AND bcb.change_notice = context_eco
					 AND bcb.acd_type = 3
					 AND bcb.effectivity_date <= x_effectivity_date
					 AND bcb.implementation_date IS NULL
					 AND bcb.bill_sequence_id = bic.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bic.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND bic.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bic.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
			   AND ( ( p_cpy_past_eff_comps = 'Y' AND ( SELECT mirb.effectivity_date
			                                              FROM mtl_item_revisions_b mirb
														 WHERE mirb.revision_id = bev.from_end_item_rev_id
													    ) <= ( SELECT mirb.effectivity_date
			                                              FROM mtl_item_revisions_b mirb
														 WHERE mirb.revision_id = p_end_item_rev_id
													    )) -- For first revised item we can have past eff comps as eff on the target date
			     OR ( p_cpy_past_eff_comps = 'N' AND ( SELECT mirb.effectivity_date
			                                              FROM mtl_item_revisions_b mirb
														 WHERE mirb.revision_id = bev.from_end_item_rev_id
													    ) = ( SELECT mirb.effectivity_date
			                                              FROM mtl_item_revisions_b mirb
														 WHERE mirb.revision_id = p_end_item_rev_id
													    ) )
			   )
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
				  );
         ELSIF l_from_eff_ctrl = 1 AND l_to_eff_ctrl = 4 THEN -- Date - Rev


	   INSERT INTO bom_components_b
                     (shipping_allowed,
                      required_to_ship,
                      required_for_revenue,
                      include_on_ship_docs,
                      include_on_bill_docs,
                      low_quantity,
                      high_quantity,
                      acd_type,
                      component_sequence_id,
                      old_component_sequence_id,
                      bill_sequence_id,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
                      wip_supply_type,
                      pick_components,
                      supply_subinventory,
                      supply_locator_id,
                      operation_lead_time_percent,
                      revised_item_sequence_id,
                      cost_factor,
                      operation_seq_num,
                      component_item_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      item_num,
                      component_quantity,
                      component_yield_factor,
                      component_remarks,
                      effectivity_date,
                      change_notice,
                      implementation_date,
                      disable_date,
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
                      planning_factor,
                      quantity_related,
                      so_basis,
                      optional,
                      mutually_exclusive_options,
                      include_in_cost_rollup,
                      check_atp,
                      bom_item_type,
                      from_end_item_unit_number,
                      to_end_item_unit_number,
                      optional_on_model,
                      --BUGFIX 2740820
                      parent_bill_seq_id,                     --BUGFIX 2740820
                      model_comp_seq_id,                      --BUGFIX 2740820
                      plan_level,
                      --BUGFIX 2740820
                      enforce_int_requirements,               --BUGFIX 2991472
                      from_object_revision_id,
                      from_minor_revision_id,
                      pk1_value,
                      pk2_value,
                      auto_request_material,
                      -- Bug 3662214 : Added following 4 fields
                      suggested_vendor_name,
                      vendor_id,
                      unit_price,
                      from_end_item_rev_id,
                      to_end_item_rev_id,
                      from_end_item_minor_rev_id,
                      to_end_item_minor_rev_id,
                      component_item_revision_id,
                      component_minor_revision_id,
                      basis_type,
                      to_object_revision_id,
                      to_minor_revision_id
                     )
            SELECT bic.shipping_allowed,
                   bic.required_to_ship,
                   bic.required_for_revenue,
                   bic.include_on_ship_docs,
                   bic.include_on_bill_docs,
                  -- bic.low_quantity,
                  -- bic.high_quantity,
  	           DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.low_quantity,
                          DECODE(BIC.low_quantity,null,null,             --Added this inner Deocde for Bug 6847530
			  inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.low_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure))) Comp_low_qty,
	          DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                         AA.primary_unit_of_measure,BIC.high_quantity,
                         DECODE(BIC.high_quantity,null,null,            --Added this inner Deocde for Bug 6847530
			 inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                    NULL,
                                                    BIC.high_quantity,
                                                    NULL,
                                                    NULL,
                                                    AA.primary_unit_of_measure,
                                                    MSI.primary_unit_of_measure))) Comp_high_qty,
                   x_acd_type,
                   bom_inventory_components_s.NEXTVAL,
                   DECODE (x_acd_type,
                           NULL, NULL,
                           bom_inventory_components_s.CURRVAL
                          ),
                   to_sequence_id,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bic.wip_supply_type,
                   DECODE (rto_flag, 'Y', 2, bic.pick_components),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_subinventory,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bic.supply_locator_id,
                           DECODE( l_default_wip_params, 1, msi.wip_supply_locator_id, NULL )
                          ),
                   bic.operation_lead_time_percent,
                   x_rev_item_seq_id,
                   bic.cost_factor,
                   bic.operation_seq_num,
                   bic.component_item_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   bic.component_sequence_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.item_num,
                   --bic.component_quantity,
                   DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,BIC.component_quantity,
                          inv_convert.INV_UM_CONVERT(BIC.component_item_id,
                                                     NULL,
                                                     BIC.component_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure)) Comp_qty,
                   bic.component_yield_factor,
                   bic.component_remarks,
                   -- R12 TTM ENH
                   -- For Rev Eff Structure the eff date will be sysdate
                   sysdate AS effectivity_date,
                   x_e_change_notice,
                   -- Implementation date will be NULL for ECO flow
                   TO_DATE (NULL),
                   -- For Rev Eff structure the disable date will be null
                   to_date(NULL) AS disable_date,
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15,
                   bic.planning_factor,
                   bic.quantity_related,
                   bic.so_basis,
                   bic.optional,
                   bic.mutually_exclusive_options,
                   bic.include_in_cost_rollup,
                   bic.check_atp,
                   msi.bom_item_type,
                   to_char(NULL) AS from_end_item_unit_number,
                   to_char(NULL) AS to_end_item_unit_number,
                   bic.optional_on_model,
                   --BUGFIX 2740820
                   bic.parent_bill_seq_id,                    --BUGFIX 2740820
                   bic.model_comp_seq_id,
                   --BUGFIX 2740820
                   bic.plan_level,                            --BUGFIX 2740820
                   bic.enforce_int_requirements,
                   -- Either Fixed or Floating rev, the components will be from when its created, current item rev
                   l_current_item_rev_id,
                   -- Minor rev is not supported. Populated the first minor rev
                   0,
                   bic.component_item_id,
                   to_org_id,
                   bic.auto_request_material,
                   -- Bug 3662214 : Added following 4 fields
                   bic.suggested_vendor_name,
                   bic.vendor_id,
                   bic.unit_price,
                   eco_end_item_rev_id,
                   CASE
                   WHEN bic.disable_date IS NOT NULL
                     AND EXISTS
                             (
                                SELECT tmirb.revision_id
                                  FROM mtl_item_revisions_b tmirb
                                 WHERE tmirb.inventory_item_id = to_item_id
                                   AND tmirb.organization_id = to_org_id
                                   AND tmirb.revision = get_current_item_rev(from_item_id, from_org_id, bic.disable_date)
                             )
                     AND EXISTS
                           (
                             SELECT mirb.REVISION
                               FROM MTL_ITEM_REVISIONS_B mirb
                              WHERE mirb.REVISION_ID = eco_end_item_rev_id
                                AND mirb.revision < get_current_item_rev(from_item_id, from_org_id, bic.disable_date)
                            )
                   THEN
                      (
                        SELECT tmirb.revision_id
                          FROM mtl_item_revisions_b tmirb
                         WHERE tmirb.inventory_item_id = to_item_id
                           AND tmirb.organization_id = to_org_id
                           AND tmirb.revision = get_current_item_rev(from_item_id, from_org_id, bic.disable_date)
                       )
                   ELSE
                      to_number(NULL)
                   END AS to_end_item_rev_id,
                   -- For Minor rev Ids
                   0 AS from_end_item_minor_rev_id,
                   0 AS to_end_item_minor_rev_id,
                   (
                     SELECT tmirb.revision_id
                       FROM mtl_item_revisions_b fmirb,
                            mtl_item_revisions_b tmirb
                      WHERE tmirb.inventory_item_id = bic.component_item_id
                        AND tmirb.organization_id = to_org_id
                        AND tmirb.revision = fmirb.revision
                        AND fmirb.revision_id = bic.component_item_revision_id
                   ) AS component_item_revision_id,
                   CASE
                   WHEN bic.component_item_revision_id IS NULL
                    THEN to_number(NULL)
                   ELSE
                   -- Minor revision is not supported
                    0
                   END AS component_minor_revision_id,
                   bic.basis_type,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                   -- For fixed rev copy the components as fixed rev
                     THEN l_to_item_rev_id
                   ELSE
                     to_number(NULL)
                   END AS to_object_revision_id,
                   CASE
                   WHEN l_fixed_rev IS NOT NULL
                     THEN 0
                   ELSE
                     to_number(NULL)
                   END AS to_minor_revision_id
              FROM bom_components_b bic,
                   mtl_system_items msi,
 		   MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                  bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = x_from_sequence_id
               AND bic.component_item_id = msi.inventory_item_id
               AND bic.component_item_id <> to_item_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND msi.organization_id = to_org_id
	       AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
               AND AA.organization_id = from_org_id   -- Added corresponding to Bug 6510185
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND ((base_item_flag = -1
                     AND itm_type = 4
                     AND msi.bom_item_type = 4
                    )
                    OR base_item_flag <> -1
                    OR itm_type <> 4
                   )
               AND ((bic.implementation_date IS NOT NULL)
                    OR (bic.implementation_date IS NULL
                        AND bic.change_notice = context_eco
                        AND ( bic.acd_type = 1 OR bic.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb
				   WHERE bcb.old_component_sequence_id = bic.component_sequence_id
					 AND bcb.change_notice = context_eco
					 AND bcb.acd_type = 3
					 AND bcb.effectivity_date <= x_effectivity_date
					 AND bcb.implementation_date IS NULL
					 AND bcb.bill_sequence_id = bic.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bic.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND bic.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bic.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
			   AND ( ( p_cpy_past_eff_comps = 'Y' AND bev.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			     OR ( p_cpy_past_eff_comps = 'N' AND bev.effectivity_date = rev_date )
			   )
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
				  );
         END IF;


         --Turn on the trigger BOMTBICX
         bom_globals.g_skip_bomtbicx := 'N';

         OPEN l_from_to_comps_csr (from_sequence_id, to_sequence_id, l_last_copied_comp_seq_id);

         FETCH l_from_to_comps_csr
         BULK COLLECT INTO l_from_comps,
                l_to_comps;

         IF l_from_to_comps_csr%ISOPEN THEN
           CLOSE l_from_to_comps_csr;
		 END IF;

         --Start copying user attrs
         IF l_from_comps.FIRST IS NOT NULL
         THEN
            l_index := l_from_comps.FIRST;
            WHILE l_index IS NOT NULL
            LOOP
               l_src_pk_col_name_val_pairs :=
                  ego_col_name_value_pair_array
                      (ego_col_name_value_pair_obj ('COMPONENT_SEQUENCE_ID',
                                                    TO_CHAR (l_from_comps (l_index))
                                                   ),
                       ego_col_name_value_pair_obj ('BILL_SEQUENCE_ID',
                                                    TO_CHAR (from_sequence_id)
                                                   )
                      );
               l_dest_pk_col_name_val_pairs :=
                  ego_col_name_value_pair_array
                       (ego_col_name_value_pair_obj ('COMPONENT_SEQUENCE_ID',
                                                     TO_CHAR (l_to_comps (l_index))
                                                    ),
                        ego_col_name_value_pair_obj ('BILL_SEQUENCE_ID',
                                                     TO_CHAR (to_sequence_id)
                                                    )
                       );
               l_new_str_type :=
                  ego_col_name_value_pair_array
                            (ego_col_name_value_pair_obj ('STRUCTURE_TYPE_ID',
                                                          TO_CHAR (l_str_type)
                                                         )
                            );

               l_old_dtlevel_col_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID', ''));
               l_new_dtlevel_col_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID', ''));

               ego_user_attrs_data_pvt.copy_user_attrs_data
                    (p_api_version                 => 1.0,
                     p_application_id              => bom_application_id,
                     p_object_name                 => 'BOM_COMPONENTS',
                     p_old_pk_col_value_pairs      => l_src_pk_col_name_val_pairs,
                     p_new_pk_col_value_pairs      => l_dest_pk_col_name_val_pairs,
                     p_new_cc_col_value_pairs      => l_new_str_type,
                     p_old_data_level_id           => l_data_level_id_comp,
                     p_new_data_level_id           => l_data_level_id_comp,
                     p_old_dtlevel_col_value_pairs => l_old_dtlevel_col_value_pairs,
                     p_new_dtlevel_col_value_pairs => l_new_dtlevel_col_value_pairs,
                     x_return_status               => l_return_status,
                     x_errorcode                   => l_errorcode,
                     x_msg_count                   => l_msg_count,
                     x_msg_data                    => l_msg_data
                    );
                l_index := l_from_comps.next(l_index);
              -- Mark the components as processed if the components are added to existing eco
              -- and the explosion is in context of that eco
              IF  e_change_notice IS NOT NULL AND e_change_notice = context_eco
              THEN
                FOR l_mark_comp_rec IN l_mark_components_csr(e_change_notice, from_org_id, from_sequence_id)
                LOOP
                  eng_propagation_log_util.mark_component_change_transfer
                  (
                    p_api_version => 1.0
                    ,p_init_msg_list => FND_API.G_FALSE
                    ,p_commit => FND_API.G_FALSE
                    ,x_return_status => l_return_status
                    ,x_msg_count => l_msg_count
                    ,x_msg_data => l_msg_data
                    ,p_change_id => l_mark_comp_rec.change_id
                    ,p_revised_item_sequence_id => rev_item_seq_id
                    ,p_component_sequence_id => l_mark_comp_rec.component_sequence_id
                    ,p_local_organization_id => to_org_id
                  );
                END LOOP;
               END IF; -- IF e_change_notice = context_eco

            END LOOP;
         END IF;

         SELECT COUNT (*)
           INTO l_no_access_comp_cnt
           FROM bom_components_b bcb,
                mtl_system_items_b_kfv msbk1,
                bom_copy_explosions_v bev
          WHERE bcb.bill_sequence_id = x_from_sequence_id
            AND bcb.component_item_id = msbk1.inventory_item_id
            AND bcb.component_item_id <> to_item_id
            AND 'T' <>
                  bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (from_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
            AND msbk1.organization_id = from_org_id
            AND bcb.component_sequence_id = bev.component_sequence_id
            AND bev.bill_sequence_id = from_sequence_id
            AND bev.parent_sort_order = p_parent_sort_order
			AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= x_effectivity_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
             AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
		    AND ( ( l_from_eff_ctrl = 1
			        AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			         OR ( p_cpy_past_eff_comps = 'N' AND bcb.effectivity_date = rev_date ) )
                   ) OR
				   ( ( l_from_eff_ctrl = 2 OR l_from_eff_ctrl = 3 )
			        AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_unit_number <= unit_number)
			         OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_unit_number = unit_number ) )
                   ) OR
				   ( l_from_eff_ctrl = 4
			        AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_rev_id <= p_end_item_rev_id)
			         OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_rev_id = p_end_item_rev_id ) )
                   )
			  );

         IF l_no_access_comp_cnt > 0
         THEN
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
               SELECT from_item_id,
                      to_org_id,
                      p_copy_request_id,
                      NULL,
                      get_current_item_rev (from_item_id,
                                            from_org_id,
                                            rev_date
                                           ),
                      get_cnt_message ('BOM_COPY_ERR_COMP_NO_ACCESS',
                                       msbk1.concatenated_segments,
                                       TO_NUMBER (l_no_access_comp_cnt)
                                      ),
                      'BOM_COPY',
                      SYSDATE,
                      user_id,
                      SYSDATE,
                      user_id,
                      'E',
                      fnd_global.conc_request_id,
                      NULL,
                      fnd_global.conc_program_id,
                      sysdate
                 FROM bom_components_b bcb,
                      mtl_system_items_b_kfv msbk1,
                      bom_copy_explosions_v bev
                WHERE msbk1.inventory_item_id = from_item_id
                  AND  msbk1.organization_id = from_org_id
                  AND bcb.component_sequence_id = bev.component_sequence_id
                  AND bev.bill_sequence_id = from_sequence_id
                  AND bev.parent_sort_order = p_parent_sort_order
				  AND ( ( l_from_eff_ctrl = 1
			            AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			             OR ( p_cpy_past_eff_comps = 'N' AND bcb.effectivity_date = rev_date ) )
                      ) OR
				     ( ( l_from_eff_ctrl = 2 OR l_from_eff_ctrl = 3 )
			           AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_unit_number <= unit_number)
			            OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_unit_number = unit_number ) )
                      ) OR
				     ( l_from_eff_ctrl = 4
			           AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_rev_id <= p_end_item_rev_id)
			            OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_rev_id = p_end_item_rev_id ) )
                     )
			        );

         END IF;

         IF (from_org_id <> to_org_id)
         THEN
            SELECT COUNT (*)
              INTO l_no_access_comp_cnt
              FROM bom_components_b bcb,
                   mtl_system_items_b_kfv msbk1,
                   bom_copy_explosions_v bev
             WHERE bcb.bill_sequence_id = x_from_sequence_id
               AND bcb.component_item_id = msbk1.inventory_item_id
               AND bcb.component_item_id <> to_item_id
               AND 'T' <>
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND msbk1.organization_id = from_org_id
               AND bcb.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
			   AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= x_effectivity_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
                AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
			   AND ( ( l_from_eff_ctrl = 1
			            AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			             OR ( p_cpy_past_eff_comps = 'N' AND bcb.effectivity_date = rev_date ) )
                      ) OR
				     ( ( l_from_eff_ctrl = 2 OR l_from_eff_ctrl = 3 )
			           AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_unit_number <= unit_number)
			            OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_unit_number = unit_number ) )
                      ) OR
				     ( l_from_eff_ctrl = 4
			           AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_rev_id <= p_end_item_rev_id)
			            OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_rev_id = p_end_item_rev_id ) )
                     )
			        );

            IF l_no_access_comp_cnt > 0
            THEN
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
                  SELECT from_item_id,
                         to_org_id,
                         p_copy_request_id,
                         NULL,
                         get_current_item_rev (from_item_id,
                                               from_org_id,
                                               rev_date
                                              ),
                         get_cnt_message ('BOM_COPY_ERR_CMPDEST_NO_ACCESS',
                                          msbk1.concatenated_segments,
                                          TO_NUMBER (l_no_access_comp_cnt)
                                         ),
                         'BOM_COPY',
                         SYSDATE,
                         user_id,
                         SYSDATE,
                         user_id,
                         'E',
                         fnd_global.conc_request_id,
                         NULL,
                         fnd_global.conc_program_id,
                         sysdate
                    FROM bom_components_b bcb,
                         mtl_system_items_b_kfv msbk1,
                         bom_copy_explosions_v bev
                   WHERE msbk1.inventory_item_id = from_item_id
                     AND msbk1.organization_id = from_org_id
                     AND bcb.component_sequence_id = bev.component_sequence_id
                     AND bev.bill_sequence_id = from_sequence_id
                     AND bev.parent_sort_order = p_parent_sort_order
					 AND ( ( l_from_eff_ctrl = 1
			            AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			             OR ( p_cpy_past_eff_comps = 'N' AND bcb.effectivity_date = rev_date ) )
                        ) OR
				        ( ( l_from_eff_ctrl = 2 OR l_from_eff_ctrl = 3 )
			             AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_unit_number <= unit_number)
			              OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_unit_number = unit_number ) )
                        ) OR
				        ( l_from_eff_ctrl = 4
			              AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_rev_id <= p_end_item_rev_id)
			              OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_rev_id = p_end_item_rev_id ) )
                        )
			          );
            END IF;
         END IF;

         -- Insert Error messages to MTL_INTERFACE_ERRORS for each error while copying
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_ENG_COMP_MFG_BILL',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,                  -- component
                   bom_copy_explosions_v bev
             WHERE bcb.bill_sequence_id = x_from_sequence_id
               AND bcb.component_item_id = msib1.inventory_item_id
               AND bcb.component_item_id <> to_item_id
               AND msib1.organization_id = to_org_id
               AND (direction = eng_to_bom
                    AND msib1.eng_item_flag = 'Y')
               AND bcb.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= x_effectivity_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
			   AND ( ( l_from_eff_ctrl = 1
			      AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			       OR ( p_cpy_past_eff_comps = 'N' AND bcb.effectivity_date = rev_date ) )
                  ) OR
				   ( ( l_from_eff_ctrl = 2 OR l_from_eff_ctrl = 3 )
			       AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_unit_number <= unit_number)
			        OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_unit_number = unit_number ) )
                  ) OR
				   ( l_from_eff_ctrl = 4
			        AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_rev_id <= p_end_item_rev_id)
			        OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_rev_id = p_end_item_rev_id ) )
                  )
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_COMP_FOR_WIP_JOB',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   bom_copy_explosions_v bev
             WHERE bcb.bill_sequence_id = x_from_sequence_id
               AND bcb.component_item_id <> to_item_id
               AND bcb.eco_for_production <> 2
               AND bcb.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= x_effectivity_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
			   AND ( ( l_from_eff_ctrl = 1
			     AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			       OR ( p_cpy_past_eff_comps = 'N' AND bcb.effectivity_date = rev_date ) )
                  ) OR
				   ( ( l_from_eff_ctrl = 2 OR l_from_eff_ctrl = 3 )
			       AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_unit_number <= unit_number)
			        OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_unit_number = unit_number ) )
                  ) OR
				   ( l_from_eff_ctrl = 4
			        AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_rev_id <= p_end_item_rev_id)
			        OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_rev_id = p_end_item_rev_id ) )
                  )
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_COMP_NOT_STANDARD',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,
                   bom_copy_explosions_v bev
             WHERE bcb.bill_sequence_id = x_from_sequence_id
               AND bcb.component_item_id = msib1.inventory_item_id
               AND bcb.component_item_id <> to_item_id
               AND bcb.implementation_date IS NOT NULL
               AND msib1.organization_id = to_org_id
               AND bcb.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= x_effectivity_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
               AND (base_item_flag = -1
                    AND itm_type = 4
                    AND msib1.bom_item_type <> 4
                   )
			   AND ( ( l_from_eff_ctrl = 1
			     AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			       OR ( p_cpy_past_eff_comps = 'N' AND bcb.effectivity_date = rev_date ) )
                  ) OR
				   ( ( l_from_eff_ctrl = 2 OR l_from_eff_ctrl = 3 )
			       AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_unit_number <= unit_number)
			        OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_unit_number = unit_number ) )
                  ) OR
				   ( l_from_eff_ctrl = 4
			        AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_rev_id <= p_end_item_rev_id)
			        OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_rev_id = p_end_item_rev_id ) )
                  )
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
			SELECT bcb.component_item_id,
				   to_org_id,
				   p_copy_request_id,
				   NULL,
				   get_current_item_rev(bcb.component_item_id, from_org_id, rev_date),
                   check_component_type_rules(bcb.component_item_id,
				         to_item_id, to_org_id),
				   'BOM_COPY',
				   SYSDATE,
				   user_id,
				   SYSDATE,
				   user_id,
				   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
			  FROM bom_components_b bcb,
				   bom_copy_explosions_v bev
			 WHERE bcb.bill_sequence_id = x_from_sequence_id
			   AND bcb.component_item_id <> to_item_id
			   AND bcb.implementation_date IS NOT NULL
			   AND bcb.component_sequence_id = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
               AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			   AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			   (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= x_effectivity_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			   )
               AND 'T' = bev.access_flag
               AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
               AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
			   AND check_component_type_rules(bcb.component_item_id,
				         to_item_id, to_org_id) IS NOT NULL -- Component Type validation fails
			   AND ( ( l_from_eff_ctrl = 1
			     AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.effectivity_date <= rev_date) -- For first revised item we can have past eff comps as eff on the target date
			       OR ( p_cpy_past_eff_comps = 'N' AND bcb.effectivity_date = rev_date ) )
                  ) OR
				   ( ( l_from_eff_ctrl = 2 OR l_from_eff_ctrl = 3 )
			       AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_unit_number <= unit_number)
			        OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_unit_number = unit_number ) )
                  ) OR
				   ( l_from_eff_ctrl = 4
			        AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_rev_id <= p_end_item_rev_id)
			        OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_rev_id = p_end_item_rev_id ) )
                  )
			    );

         -- For Item Revision Change Policy throw the errors if the components change not allowed
         IF l_to_eff_ctrl = 1 THEN
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE (
				    'BOM_CPY_REV_CHANGE_POLICY_ERR',
                    bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                    bom_globals.get_item_name(to_item_id, from_org_id)
                   ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND bcb.component_item_id = msib.inventory_item_id
               AND msib.organization_id = to_org_id
               AND 'Y' <>
			     bom_globals.check_change_policy_range(
				   to_item_id,
				   to_org_id,
				   NULL, -- p_start_revision
				   NULL, -- p_end_revision
				   NULL, -- p_start_rev_id
				   NULL, -- p_end_rev_id
				   bcb.effectivity_date, -- p_effective_date
				   bcb.disable_date, -- p_disable_date
				   bom_globals.get_change_policy_val(to_item_id, to_org_id,
				     BOM_Revisions.Get_Item_Revision_Id_Fn('ALL','ALL',to_org_id,
					   to_item_id,x_effectivity_date),
					   null, -- rev id
					   p_trgt_str_type_id), -- p_current_chg_pol
				   p_trgt_str_type_id, -- p_structure_type_id
				   'Y' -- p_use_eco
				   );
		 ELSIF l_to_eff_ctrl = 4 THEN
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE (
				    'BOM_CPY_REV_CHANGE_POLICY_ERR',
                    bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                    bom_globals.get_item_name(to_item_id, from_org_id)
                   ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND bcb.component_item_id = msib.inventory_item_id
               AND msib.organization_id = to_org_id
               AND 'Y' <>
			     bom_globals.check_change_policy_range(
				   to_item_id,
				   to_org_id,
				   NULL, -- p_start_revision
				   NULL, -- p_end_revision
				   bcb.from_end_item_rev_id, -- p_start_rev_id
				   bcb.to_end_item_rev_id, -- p_end_rev_id
				   NULL, -- p_effective_date
				   NULL, -- p_disable_date
				   bom_globals.get_change_policy_val(to_item_id, to_org_id,
				     eco_end_item_rev_id,
					   null, -- rev id
					   p_trgt_str_type_id), -- p_current_chg_pol
				   p_trgt_str_type_id, -- p_structure_type_id
				   'Y' -- p_use_eco
				   );
		 END IF;


         -- For Rev Eff structure and copy is across org then add the error message for fixed revision components
         -- if revision does not exist.
         IF l_from_eff_ctrl = 4 AND l_to_eff_ctrl = 4
            AND from_org_id <> to_org_id
         THEN
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
               SELECT bcb.component_item_id,
                      to_org_id,
                      p_copy_request_id,
                      NULL,
                      get_current_item_rev (bcb.component_item_id,
                                            from_org_id,
                                            rev_date
                                           ),
                      GET_MESSAGE
                               ('BOM_COPY_ERR_COMP_REV_DIFF',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id),
                                get_current_item_rev (bcb.component_item_id,
                                                      from_org_id,
                                                      rev_date
                                                     )
                               ),
                      'BOM_COPY',
                      SYSDATE,
                      user_id,
                      SYSDATE,
                      user_id,
                      'E',
                      fnd_global.conc_request_id,
                      NULL,
                      fnd_global.conc_program_id,
                      sysdate
                 FROM bom_components_b bcb,
                      bom_copy_explosions_v bev
                WHERE bcb.bill_sequence_id = x_from_sequence_id
                  AND bcb.component_item_id <> to_item_id
                  AND bcb.implementation_date IS NOT NULL
                  AND bcb.component_sequence_id = bev.component_sequence_id
                  -- Error needs to be logged only for fixed revision components
                  AND bcb.component_item_revision_id IS NOT NULL
                  AND bev.bill_sequence_id = from_sequence_id
                  AND bev.parent_sort_order = p_parent_sort_order
                  AND ((bcb.implementation_date IS NOT NULL)
                    OR (bcb.implementation_date IS NULL
                        AND bcb.change_notice = context_eco
                        AND ( bcb.acd_type = 1 OR bcb.acd_type = 2 )
                       )
                   )
			      AND NOT EXISTS -- Bug 5151332 Disabled components should not get copied in ECO context
			      (
			      SELECT 1
				    FROM bom_components_b bcb1
				   WHERE bcb1.old_component_sequence_id = bcb.component_sequence_id
					 AND bcb1.change_notice = context_eco
					 AND bcb1.acd_type = 3
					 AND bcb1.effectivity_date <= x_effectivity_date
					 AND bcb1.implementation_date IS NULL
					 AND bcb1.bill_sequence_id = bcb.bill_sequence_id
			      )
                  AND 'T' = bev.access_flag
                  AND 'T' =
                     bom_security_pub.check_item_privilege
                                              ('EGO_VIEW_ITEM',
                                               TO_CHAR (bcb.component_item_id),
                                               TO_CHAR (to_org_id),
                                               bom_exploder_pub.get_ego_user
                                              )
                  AND NOT EXISTS (
                     SELECT 1
                       FROM bom_copy_structure_actions bcsa
                      WHERE bcsa.component_sequence_id =
                                                     bcb.component_sequence_id
                        AND bcsa.copy_request_id = p_copy_request_id
                        AND bcsa.organization_id = to_org_id
                        AND ( bcsa.component_exception_action = 1 OR bcsa.component_exception_action = 3)
                                                               -- Component Action is exclude or enable
                                                               -- we need not copy.
                  )
                  AND NOT EXISTS (
                        SELECT tmirb.revision_id
                          FROM mtl_item_revisions_b fmirb,
                               mtl_item_revisions_b tmirb
                         WHERE tmirb.inventory_item_id = bcb.component_item_id
                           AND tmirb.organization_id = to_org_id
                           AND tmirb.revision = fmirb.revision
                           AND fmirb.revision_id =
                                                bcb.component_item_revision_id)
			      AND (
				      ( l_from_eff_ctrl = 4
			           AND ( ( p_cpy_past_eff_comps = 'Y' AND bcb.from_end_item_rev_id <= p_end_item_rev_id)
			           OR ( p_cpy_past_eff_comps = 'N' AND bcb.from_end_item_rev_id = p_end_item_rev_id ) )
                      )
			        );

         END IF;
      copy_comps := SQL%ROWCOUNT;



-- Bug 1825873--determine if routing exists.  If not exists, then reset--operation_sequence_num to 1.  If exists then, reset only missing--operation_seq_num to 1
      BEGIN
         sql_stmt_num := 25;

	  IF ( p_cpy_past_eff_comps = 'Y' ) THEN

         SELECT common_routing_sequence_id
           INTO to_rtg_seq_id
           FROM bom_operational_routings
          WHERE organization_id = to_org_id
            AND assembly_item_id = to_item_id
            AND (NVL (alternate_routing_designator, 'NONE') =
                                                    NVL (to_alternate, 'NONE')
                 OR (to_alternate IS NOT NULL
                     AND alternate_routing_designator IS NULL
                     AND NOT EXISTS (
                           SELECT NULL
                             FROM bom_operational_routings bor2
                            WHERE bor2.organization_id = to_org_id
                              AND bor2.assembly_item_id = to_item_id
                              AND bor2.alternate_routing_designator =
                                                                  to_alternate)
                    )
                );
	  END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            to_rtg_seq_id := -1;
         WHEN OTHERS
         THEN
            err_msg := 'COPY_BILL (' || sql_stmt_num || ') ' || SQLERRM;
            fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
            fnd_message.set_token ('ENTITY', err_msg);
            ROLLBACK TO begin_revised_item_bill_copy;
            app_exception.raise_exception;
      END;

      BEGIN
         --Turn off trigger BOMTBICX
         bom_globals.g_skip_bomtbicx := 'Y';

         IF (to_rtg_seq_id = -1)
         THEN
            sql_stmt_num := 30;

            UPDATE bom_inventory_components
               SET operation_seq_num = 1
             WHERE bill_sequence_id = to_sequence_id;
         ELSE
            sql_stmt_num := 35;

            UPDATE bom_inventory_components bic
               SET operation_seq_num = 1
             WHERE bill_sequence_id = to_sequence_id
               AND NOT EXISTS (
                     SELECT NULL
                       FROM bom_operation_sequences bos
                      WHERE routing_sequence_id = to_rtg_seq_id
                        AND bos.operation_seq_num = bic.operation_seq_num);
         END IF;

         --Turn on trigger BOMTBICX
         bom_globals.g_skip_bomtbicx := 'N';
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            RAISE overlap_error;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      --check for overlapping rows if teh above updated any rows
      IF (SQL%FOUND)
      THEN
         BEGIN
            sql_stmt_num := 40;

            /* Serial Effectivity Implementation */
            IF (bom_eamutil.enabled = 'Y'
                AND bom_eamutil.serial_effective_item (item_id      => to_item_id,
                                                       org_id       => to_org_id
                                                      ) = 'Y'
               )
               OR (pjm_unit_eff.enabled = 'Y'
                   AND pjm_unit_eff.unit_effective_item
                                               (x_item_id              => to_item_id,
                                                x_organization_id      => to_org_id
                                               ) = 'Y'
                  )
            THEN
               SELECT COUNT (*)
                 INTO dummy
                 FROM bom_inventory_components bic
                WHERE bic.bill_sequence_id = to_sequence_id
                  AND EXISTS (
                        SELECT NULL
                          FROM bom_inventory_components bic2
                         WHERE bic2.bill_sequence_id = to_sequence_id
                           AND bic2.ROWID <> bic.ROWID
                           AND bic2.operation_seq_num = bic.operation_seq_num
                           AND bic2.component_item_id = bic.component_item_id
                           AND bic2.disable_date IS NULL
                           AND (bic.to_end_item_unit_number IS NULL
                                OR (bic.to_end_item_unit_number >=
                                                bic2.from_end_item_unit_number
                                   )
                               )
                           AND (bic2.to_end_item_unit_number IS NULL
                                OR (bic.from_end_item_unit_number <=
                                                  bic2.to_end_item_unit_number
                                   )
                               ))
						   AND bic.revised_item_sequence_id = rev_item_seq_id;
            ELSIF l_to_eff_ctrl = 4
            THEN
               SELECT COUNT (*)
                 INTO dummy
                 FROM bom_components_b bcb
                WHERE bcb.bill_sequence_id = to_sequence_id
                  AND EXISTS (
                        SELECT NULL
                          FROM bom_components_b bcb2
                         WHERE bcb2.bill_sequence_id = to_sequence_id
                           AND bcb2.ROWID <> bcb.ROWID
                           AND bcb2.operation_seq_num = bcb.operation_seq_num
                           AND bcb2.component_item_id = bcb.component_item_id
                           AND bcb2.disable_date IS NULL
                           AND (bcb.to_end_item_rev_id IS NULL
                                OR (get_minor_rev_code
                                                 (bcb.to_end_item_rev_id,
                                                  bcb.to_end_item_minor_rev_id
                                                 ) >=
                                       get_minor_rev_code
                                              (bcb2.from_end_item_rev_id,
                                               bcb2.from_end_item_minor_rev_id
                                              )
                                   )
                               )
                           AND (bcb2.to_end_item_rev_id IS NULL
                                OR (get_minor_rev_code
                                               (bcb.from_end_item_rev_id,
                                                bcb.from_end_item_minor_rev_id
                                               ) >=
                                       get_minor_rev_code
                                                (bcb2.to_end_item_rev_id,
                                                 bcb2.to_end_item_minor_rev_id
                                                )
                                   )
                               ))
						   AND bcb.revised_item_sequence_id = rev_item_seq_id;
            ELSE
               SELECT COUNT (*)
                 INTO dummy
                 FROM bom_inventory_components bic
                WHERE bic.bill_sequence_id = to_sequence_id
                  AND EXISTS (
                        SELECT NULL
                          FROM bom_inventory_components bic2
                         WHERE bic2.bill_sequence_id = to_sequence_id
                           AND bic2.ROWID <> bic.ROWID
                           AND bic2.operation_seq_num = bic.operation_seq_num
                           AND bic2.component_item_id = bic.component_item_id
                           AND bic2.effectivity_date <= bic.effectivity_date
                           AND NVL (bic2.disable_date,
                                    bic.effectivity_date + 1
                                   ) > bic.effectivity_date)
						   AND bic.revised_item_sequence_id = rev_item_seq_id;
            END IF;

            IF (dummy <> 0)
            THEN
               -- Added for bug 3801212: Check if rows fetched to raise overlap_error
               RAISE overlap_error;
            END IF;
         EXCEPTION
            WHEN overlap_error
            THEN
               RAISE;
            WHEN NO_DATA_FOUND
            THEN
               NULL;
            WHEN OTHERS
            THEN
               err_msg := 'COPY_BILL (' || sql_stmt_num || ') ' || SQLERRM;
               fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
               fnd_message.set_token ('ENTITY', err_msg);
               ROLLBACK TO begin_bill_copy;
               app_exception.raise_exception;
         END;
      END IF;

--  Other organizations who use our bills as common bills must have the
--  component items in their organization as well.
--
      FOR l_common_rec IN l_common_csr
      LOOP
         RAISE common_error;
      END LOOP;

--     Ensure the following rule matrix is observed
--
--     Y = Allowed  N = Not Allowed
--     P = Must be Phantom  O = Must be Optional
--     Configured items are ATO standard items that have a base item id.
--     ATO items have Replenish to Order flags set to "Y".
--     PTO items have Pick Component flags set to "Y".
--
--                                     Parent
-- Child         |Config  ATO Mdl  ATO Opt  ATO Std  PTO Mdl  PTO Opt  PTO Std
-- ---------------------------------------------------------------------------
-- Planning      |   N       N        N        N        N        N        N
-- Configured    |   Y       Y        Y        Y        Y        Y        Y
-- ATO Model     |   P       P        P        N        P        P        N
-- ATO Opt Class |   P       P        P        N        N        N        N
-- ATO Standard  |   Y       Y        Y        Y        O        O        N
-- PTO Model     |   N       N        N        N        P        P        N
-- PTO Opt Class |   N       N        N        N        P        P        N
-- PTO Standard  |   N       N        N        N        Y        Y        Y
--
--
  -- Log errors for multi level structure copy.
         -- Planning bill should contain only planning components
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_NO_PLANNING_COMPS',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,
                   mtl_system_items_b msib2
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND (msib1.bom_item_type = planning
                    AND msib2.bom_item_type <> planning
                   )
               AND msib2.inventory_item_id = to_item_id
               AND msib2.organization_id = to_org_id
               AND msib1.inventory_item_id = bcb.component_item_id
               AND msib1.organization_id = to_org_id
		       AND bcb.revised_item_sequence_id = rev_item_seq_id;

         -- Standard bill without base model cannot have Option class or Model components.
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_NO_OPT_MODEL_COMP',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,
                   mtl_system_items_b msib2
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND (msib1.bom_item_type IN (model, option_class)
                    AND msib2.bom_item_type = STANDARD
                    AND msib2.base_item_id IS NULL
                   )
               AND msib2.inventory_item_id = to_item_id
               AND msib2.organization_id = to_org_id
               AND msib1.inventory_item_id = bcb.component_item_id
               AND msib1.organization_id = to_org_id
		       AND bcb.revised_item_sequence_id = rev_item_seq_id;

         -- No ATO Optional components in PTO bill
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_NO_ATO_OPT_COMPS',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,                       -- Comp
                   mtl_system_items_b msib2                   -- Structure
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND (msib1.replenish_to_order_flag = 'Y'
                    AND msib1.bom_item_type = option_class
                    AND msib2.pick_components_flag = 'Y'
                   )
               AND msib2.inventory_item_id = to_item_id
               AND msib2.organization_id = to_org_id
               AND msib1.inventory_item_id = bcb.component_item_id
               AND msib1.organization_id = to_org_id
		       AND bcb.revised_item_sequence_id = rev_item_seq_id;

         -- No ATO standard items for PTO standard bills
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_NO_ATO_STD_COMPS',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,                       -- Comp
                   mtl_system_items_b msib2                   -- Structure
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND (msib1.replenish_to_order_flag = 'Y'
                    AND msib1.bom_item_type = STANDARD
                    AND msib2.pick_components_flag = 'Y'
                    AND msib2.bom_item_type = STANDARD
                   )
               AND msib2.inventory_item_id = to_item_id
               AND msib2.organization_id = to_org_id
               AND msib1.inventory_item_id = bcb.component_item_id
               AND msib1.organization_id = to_org_id
		       AND bcb.revised_item_sequence_id = rev_item_seq_id;

         -- No PTO components in ATO bill
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
            SELECT bcb.component_item_id,
                   to_org_id,
                   p_copy_request_id,
                   NULL,
                   get_current_item_rev (bcb.component_item_id,
                                         from_org_id,
                                         rev_date
                                        ),
                   GET_MESSAGE ('BOM_COPY_ERR_NO_PTO_COMPS',
                                bom_globals.get_item_name(bcb.component_item_id, from_org_id),
                                bom_globals.get_item_name(to_item_id, from_org_id)
                               ),
                   'BOM_COPY',
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   'E',
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_components_b bcb,
                   mtl_system_items_b msib1,                       -- Comp
                   mtl_system_items_b msib2                   -- Structure
             WHERE bcb.bill_sequence_id = to_sequence_id
               AND (msib1.pick_components_flag = 'Y'
                    AND msib2.replenish_to_order_flag = 'Y'
                   )
               AND msib2.inventory_item_id = to_item_id
               AND msib2.organization_id = to_org_id
               AND msib1.inventory_item_id = bcb.component_item_id
               AND msib1.organization_id = to_org_id
		       AND bcb.revised_item_sequence_id = rev_item_seq_id;

      sql_stmt_num := 41;

      DELETE FROM bom_inventory_components bic
            WHERE bic.bill_sequence_id = to_sequence_id
              AND EXISTS (
                    SELECT NULL
                      FROM mtl_system_items msi1,                       -- bom
                           mtl_system_items msi2                  -- component
                     WHERE ((msi2.bom_item_type = planning
                             AND msi1.bom_item_type <> planning
                            )
                            OR (msi2.bom_item_type IN (model, option_class)
                                AND msi1.bom_item_type = STANDARD
                                AND msi1.base_item_id IS NULL
                               )
                            OR (msi2.replenish_to_order_flag = 'Y'
                                AND msi2.bom_item_type = option_class
                                AND msi1.pick_components_flag = 'Y'
                               )
                            OR (msi2.replenish_to_order_flag = 'Y'
                                AND msi2.bom_item_type = STANDARD
                                AND msi1.pick_components_flag = 'Y'
                                AND msi1.bom_item_type = STANDARD
                               )
                            OR (msi2.pick_components_flag = 'Y'
                                AND msi1.replenish_to_order_flag = 'Y'
                               )
                           )
                       AND msi1.inventory_item_id = to_item_id
                       AND msi1.organization_id = to_org_id
                       AND msi2.inventory_item_id = bic.component_item_id
                       AND msi2.organization_id = to_org_id)
		  AND bic.revised_item_sequence_id = rev_item_seq_id;

      copy_comps := copy_comps - SQL%ROWCOUNT;
      sql_stmt_num := 43;
      --Turn off trigger BOMTBICX
      bom_globals.g_skip_bomtbicx := 'Y';

      UPDATE bom_components_b bic
         SET bic.wip_supply_type = phantom
       WHERE bic.bill_sequence_id = to_sequence_id
         AND EXISTS (
               SELECT NULL
                 FROM mtl_system_items msi1,                       -- assembly
                      mtl_system_items msi2                       -- component
                WHERE msi2.bom_item_type IN (model, option_class)
                  AND msi2.inventory_item_id = bic.component_item_id
                  AND msi2.organization_id = to_org_id
                  AND msi1.inventory_item_id = to_item_id
                  AND msi1.organization_id = to_org_id)
       AND bic.revised_item_sequence_id = rev_item_seq_id;

      bom_globals.g_skip_bomtbicx := 'N';
      sql_stmt_num := 44;
      bom_globals.g_skip_bomtbicx := 'Y';

      UPDATE bom_components_b bic
         SET bic.optional = 1
       WHERE bic.bill_sequence_id = to_sequence_id
         AND EXISTS (
               SELECT NULL
                 FROM mtl_system_items msi1,                       -- assembly
                      mtl_system_items msi2                       -- component
                WHERE msi2.base_item_id IS NULL
                  AND msi2.replenish_to_order_flag = 'Y'
                  AND msi2.bom_item_type = STANDARD
                  AND msi1.pick_components_flag = 'Y'
                  AND msi1.bom_item_type IN (model, option_class)
                  AND msi2.inventory_item_id = bic.component_item_id
                  AND msi2.organization_id = to_org_id
                  AND msi1.inventory_item_id = to_item_id
                  AND msi1.organization_id = to_org_id)
        AND bic.revised_item_sequence_id = rev_item_seq_id;

      --Turn on trigger BOMTBICX
      bom_globals.g_skip_bomtbicx := 'N';
      sql_stmt_num := 46;

         INSERT INTO bom_reference_designators
                     (component_reference_designator,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      ref_designator_comment,
                      change_notice,
                      component_sequence_id,
                      acd_type,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
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
                      attribute15
                     )
            SELECT component_reference_designator,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   user_id,/*NULL,bugfix:8639515*/
                   ref_designator_comment,
                   x_e_change_notice,
                   bic.component_sequence_id,
                   x_acd_type,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   brd.attribute_category,
                   brd.attribute1,
                   brd.attribute2,
                   brd.attribute3,
                   brd.attribute4,
                   brd.attribute5,
                   brd.attribute6,
                   brd.attribute7,
                   brd.attribute8,
                   brd.attribute9,
                   brd.attribute10,
                   brd.attribute11,
                   brd.attribute12,
                   brd.attribute13,
                   brd.attribute14,
                   brd.attribute15
              FROM bom_reference_designators brd,
                   bom_components_b bic,
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = to_sequence_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND brd.component_sequence_id = bic.created_by
               AND NVL (brd.acd_type, 1) <> 3
               AND bic.created_by = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
		       AND bic.revised_item_sequence_id = rev_item_seq_id;

      copy_desgs := SQL%ROWCOUNT;


      sql_stmt_num := 50;

         INSERT INTO bom_substitute_components
                     (substitute_component_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      substitute_item_quantity,
                      component_sequence_id,
                      acd_type,
                      change_notice,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date,
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
					  enforce_int_requirements
                     )
            SELECT substitute_component_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   NULL,
                   --substitute_item_quantity,
		   DECODE(MSI.primary_unit_of_measure,                    --  Added corresponding to Bug 6510185
                          AA.primary_unit_of_measure,Bsc.substitute_item_quantity,
                          inv_convert.INV_UM_CONVERT(bsc.substitute_component_id,
                                                     NULL,
                                                     Bsc.substitute_item_quantity,
                                                     NULL,
                                                     NULL,
                                                     AA.primary_unit_of_measure,
                                                     MSI.primary_unit_of_measure)) Sub_Comp_qty,
                   bic.component_sequence_id,
                   x_acd_type,
                   x_e_change_notice,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   bsc.attribute_category,
                   bsc.attribute1,
                   bsc.attribute2,
                   bsc.attribute3,
                   bsc.attribute4,
                   bsc.attribute5,
                   bsc.attribute6,
                   bsc.attribute7,
                   bsc.attribute8,
                   bsc.attribute9,
                   bsc.attribute10,
                   bsc.attribute11,
                   bsc.attribute12,
                   bsc.attribute13,
                   bsc.attribute14,
                   bsc.attribute15,
				   bsc.enforce_int_requirements
              FROM bom_substitute_components bsc,
                   bom_components_b bic,
                   mtl_system_items msi,
 		   MTL_SYSTEM_ITEMS AA ,        -- Added corresponding to Bug 6510185
                  bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = to_sequence_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND bsc.component_sequence_id = bic.created_by
               AND NVL (bsc.acd_type, 1) <> 3
               AND ((direction = eng_to_bom
                     AND msi.eng_item_flag = 'N')
                    OR (direction <> eng_to_bom)
                   )
               AND msi.inventory_item_id = bsc.substitute_component_id
               AND msi.organization_id = to_org_id
               AND bic.created_by = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
	       AND bic.revised_item_sequence_id = rev_item_seq_id
	       AND MSI.inventory_item_id = AA.inventory_item_id     -- Added corresponding to Bug 6510185
               AND AA.organization_id = from_org_id   -- Added corresponding to Bug 6510185
               AND EXISTS
               (
				  SELECT 1
				    FROM fnd_lookup_values_vl flv,
				         ego_criteria_templates_v ectv,
				         ego_criteria_v ecv,
				         mtl_system_items_b msibs -- to assembly item
				   WHERE ecv.customization_application_id = 702
				     AND ecv.region_application_id = 702
				     AND ecv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND ecv.customization_code = ectv.customization_code
				     AND flv.lookup_type = 'ITEM_TYPE'
				     AND flv.enabled_flag = 'Y'
				     AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				     AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				     AND flv.lookup_code = ectv.classification1
				     AND ectv.customization_application_id = 702
				     AND ectv.region_application_id = 702
				     AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				     AND flv.lookup_code = msibs.item_type
				     AND msibs.inventory_item_id = to_item_id
				     AND msibs.organization_id = to_org_id
				     AND ecv.value_varchar2 = msi.item_type -- Substitute Component
				  UNION ALL
				  SELECT 1
				    FROM DUAL
				   WHERE NOT EXISTS
				   (
				     SELECT 1
					   FROM fnd_lookup_values_vl flv,
				            ego_criteria_templates_v ectv,
				            mtl_system_items_b msibs -- to assembly item
				      WHERE flv.lookup_type = 'ITEM_TYPE'
				        AND flv.enabled_flag = 'Y'
				        AND (flv.start_date_active IS NULL OR flv.start_date_active < sysdate)
				        AND (flv.end_date_active IS NULL OR flv.end_date_active > sysdate)
				        AND flv.lookup_code = ectv.classification1
				        AND ectv.customization_application_id = 702
				        AND ectv.region_application_id = 702
				        AND ectv.region_code = 'BOM_ITEM_TYPE_REGION'
				        AND flv.lookup_code = msibs.item_type
				        AND msibs.inventory_item_id = to_item_id
				        AND msibs.organization_id = to_org_id
				    )
			   );

      copy_subs := SQL%ROWCOUNT;

      sql_stmt_num := 51;

      /* Copy the component operations (One To Many changes) */
         INSERT INTO bom_component_operations
                     (comp_operation_seq_id,
                      operation_seq_num,
                      operation_sequence_id,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      component_sequence_id,
                      bill_sequence_id,
                      consuming_operation_flag,
                      consumption_quantity,
                      supply_subinventory,
                      supply_locator_id,
                      wip_supply_type,
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
            SELECT bom_component_operations_s.NEXTVAL,
                   bco.operation_seq_num,
                   bos.operation_sequence_id,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   /*NULL comment for bug8431772,change NULL to user_id*/user_id,
                   bic.component_sequence_id,
                   bic.bill_sequence_id,
                   bco.consuming_operation_flag,
                   bco.consumption_quantity,
                   DECODE (x_from_org_id,
                           to_org_id, bco.supply_subinventory,
                           DECODE( l_default_wip_params, 1, bic.supply_subinventory, NULL )
                          ),
                   DECODE (x_from_org_id,
                           to_org_id, bco.supply_locator_id,
                           DECODE( l_default_wip_params, 1, bic.supply_locator_id, NULL )
                           ),
                   bco.wip_supply_type,
                   bco.attribute_category,
                   bco.attribute1,
                   bco.attribute2,
                   bco.attribute3,
                   bco.attribute4,
                   bco.attribute5,
                   bco.attribute6,
                   bco.attribute7,
                   bco.attribute8,
                   bco.attribute9,
                   bco.attribute10,
                   bco.attribute11,
                   bco.attribute12,
                   bco.attribute13,
                   bco.attribute14,
                   bco.attribute15,
                   fnd_global.conc_request_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate
              FROM bom_component_operations bco,
                   bom_components_b bic,
                   bom_operation_sequences bos,
                   bom_copy_explosions_v bev
             WHERE bic.bill_sequence_id = to_sequence_id
               AND NVL (bic.eco_for_production, 2) = 2
               AND bco.component_sequence_id = bic.created_by
               AND bos.routing_sequence_id = to_rtg_seq_id
               AND bos.operation_seq_num = bco.operation_seq_num
               AND bic.created_by = bev.component_sequence_id
               AND bev.bill_sequence_id = from_sequence_id
               AND bev.parent_sort_order = p_parent_sort_order
		       AND bic.revised_item_sequence_id = rev_item_seq_id;

      copy_compops := SQL%ROWCOUNT;

      IF (itm_type = model
          OR itm_type = option_class) AND p_cpy_past_eff_comps = 'Y' -- Copy desc elements only once
      THEN
         sql_stmt_num := 55;

         INSERT INTO bom_dependent_desc_elements
                     (bill_sequence_id,
                      element_name,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      program_application_id,
                      program_id,
                      program_update_date,
                      request_id
                     )
            SELECT to_sequence_id,
                   bdde.element_name,
                   SYSDATE,
                   user_id,
                   SYSDATE,
                   user_id,
                   user_id,
                   NULL,
                   fnd_global.conc_program_id,
                   sysdate,
                   fnd_global.conc_request_id
              FROM bom_dependent_desc_elements bdde
             WHERE bdde.bill_sequence_id = x_from_sequence_id
               AND ((itm_type = model
                     AND EXISTS (
                           SELECT NULL
                             FROM mtl_descriptive_elements mde
                            WHERE mde.item_catalog_group_id = itm_cat_grp_id
                              AND mde.element_name = bdde.element_name)
                    )
                    OR itm_type = option_class
                   );
      END IF;

      -- Update the created by column only when specific copy flag is no..
      -- If specific copy flag is 'Y', then after copy_bill, call update_created_by.


   EXCEPTION
      WHEN overlap_error
      THEN
         bom_globals.g_skip_bomtbicx := 'N';
         fnd_message.set_name ('BOM', 'BOM_BAD_COPY_GUI');

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
                 VALUES (to_item_id,
                         to_org_id,
                         p_copy_request_id,
                         NULL,
                         get_current_item_rev (to_item_id,
                                               from_org_id,
                                               SYSDATE
                                              ),
                         fnd_message.get,
                         'BOM_COPY',
                         SYSDATE,
                         user_id,
                         SYSDATE,
                         user_id,
                         'E',
                         fnd_global.conc_request_id,
                         NULL,
                         fnd_global.conc_program_id,
                         sysdate
                        );
      WHEN common_error
      THEN
         bom_globals.g_skip_bomtbicx := 'N';
         fnd_message.set_name ('BOM', 'BOM_COMMON_OTHER_ORGS2');

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
                 VALUES (to_item_id,
                         to_org_id,
                         p_copy_request_id,
                         NULL,
                         get_current_item_rev (to_item_id,
                                               from_org_id,
                                               SYSDATE
                                              ),
                         fnd_message.get,
                         'BOM_COPY',
                         SYSDATE,
                         user_id,
                         SYSDATE,
                         user_id,
                         'E',
                         fnd_global.conc_request_id,
                         NULL,
                         fnd_global.conc_program_id,
                         sysdate
                        );
      WHEN OTHERS
      THEN
         bom_globals.g_skip_bomtbicx := 'N';
         err_msg := 'copy_bill_for_revised_item (' || sql_stmt_num || ') ' || SQLERRM;
         fnd_message.set_name ('BOM', 'BOM_SQL_ERR');
         fnd_message.set_token ('ENTITY', err_msg);
         ROLLBACK TO begin_revised_item_bill_copy;
         app_exception.raise_exception;
    END copy_bill_for_revised_item;

	PROCEDURE copy_attachments(p_from_sequence_id IN NUMBER,
	                            p_to_sequence_id   IN NUMBER,
								p_user_id          IN NUMBER)
    IS
    BEGIN
         fnd_attached_documents2_pkg.copy_attachments
                              (x_from_entity_name            => 'BOM_BILL_OF_MATERIALS',
                               x_from_pk1_value              => p_from_sequence_id,
                               x_from_pk2_value              => '',
                               x_from_pk3_value              => '',
                               x_from_pk4_value              => '',
                               x_from_pk5_value              => '',
                               x_to_entity_name              => 'BOM_BILL_OF_MATERIALS',
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
	END;

	FUNCTION get_comp_type_rule_message(p_msg_name IN VARCHAR2,
	    p_assembly_item IN VARCHAR2, p_parent_item_type IN VARCHAR2,
        p_component_item IN VARCHAR2, p_component_item_type IN VARCHAR2)
	  RETURN VARCHAR2
    IS
    BEGIN
      fnd_message.set_name('BOM',p_msg_name);
      fnd_message.set_token('PARENT_ITEM_NAME',p_assembly_item);
      fnd_message.set_token('PARENT_ITEM_TYPE',p_parent_item_type);
      fnd_message.set_token('COMPONENT_ITEM_NAME',p_component_item);
      fnd_message.set_token('COMPONENT_ITEM_TYPE',p_component_item_type);
      RETURN fnd_message.get;
    END get_comp_type_rule_message;

	-- Start of comments
	--	API name 	: check_component_type_rules
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Checks the component type rules and returns the error msg
	--                if the validation fails
	--	Parameters	:
	--	IN	  	    : p_component_item_id IN NUMBER Required
	--				   Component Item Name
	--                p_assembly_item_id IN NUMBER Required
	--                 Assembly Item Name
	--                p_organization_id IN NUMBER Required
	--                 Organization Id
	-- Returns      : Error Message if validation fails else null
	-- Purpose      : To validate the components and insert error messages
	--                to errors table if required.
	-- End of comments
	FUNCTION check_component_type_rules(p_component_item_id IN NUMBER,
	                                    p_assembly_item_id IN NUMBER,
										p_org_id IN NUMBER
									    ) RETURN VARCHAR2
    IS
	l_return_status VARCHAR2(1);
	l_error_msg VARCHAR2(2000);
	BEGIN
	   bom_validate_bom_component.check_component_type_rule(
	          l_return_status,
			  l_error_msg,
			  TRUE,
			  p_assembly_item_id,
			  p_component_item_id,
			  p_org_id );
       IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	     return NULL;
	   ELSE
	     return l_error_msg;
	   END IF;
	END check_component_type_rules;

-- Bug 11868441 - sun: issue with bom commoning when any subassembly is on unimplemented eco
   PROCEDURE ASSIGN_ECO_COMP_TO_ORGS(
        p_api_version                   IN  NUMBER,
        p_organization_id               IN  NUMBER,
        p_bill_sequence_id              IN  NUMBER    DEFAULT NULL,
        x_return_status                 OUT NOCOPY   VARCHAR2,
        x_msg_data                      OUT NOCOPY  VARCHAR2)
   IS
     l_return_status    VARCHAR2(1):= 'Y';
     l_msg_count number;
     l_item_org_assignment_tbl    EGO_Item_PUB.Item_Org_Assignment_Tbl_Type;

     l_conc_request_id        number := FND_GLOBAL.CONC_REQUEST_ID;

     CURSOR l_un_assign_eco_comps (  p_bill_seq_id NUMBER
                                 , p_org_id NUMBER)
     IS
       SELECT  bic.component_item_id component_item_id
             , bic.change_notice change_notice
             , bic.implementation_date implementation_date
       FROM bom_inventory_components bic,
            bom_structures_b bsb
       WHERE bic.bill_sequence_id = bsb.bill_sequence_id
       AND bsb.bill_sequence_id = p_bill_seq_id
       --Bug 10331803. Should not validate currently disabled components.
       AND (bic.disable_date is null OR bic.disable_date > NVL(BOM_EXPLODER_PUB.Get_Explosion_Date, SYSDATE))
       AND not exists
          (
       SELECT 'x'
          FROM mtl_system_items s1,
          mtl_system_items s2
          WHERE s1.organization_id = p_org_id
          AND s1.inventory_item_id = bic.component_item_id
          and s2.organization_id = bsb.organization_id
          and s2.inventory_item_id = bsb.assembly_item_id
          AND ((bsb.assembly_type = 1 AND s1.eng_item_flag = 'N')
                OR (bsb.assembly_type = 2))
          AND s1.inventory_item_id <> bsb.assembly_item_id
          AND ((s2.bom_item_type = 1 AND s1.bom_item_type <> 3)
                OR (s2.bom_item_type = 2 AND s1.bom_item_type <> 3)
                OR (s2.bom_item_type = 3)
                OR (s2.bom_item_type = 4
                AND (s1.bom_item_type = 4
                    OR
                    ( s1.bom_item_type IN (2, 1)
                    AND s1.replenish_to_order_flag = 'Y'
                    AND s2.base_item_id IS NOT NULL
                    AND s2.replenish_to_order_flag = 'Y' ))))
                    AND (s2.bom_item_type = 3
                          OR
                          s2.pick_components_flag = 'Y'
                          OR
                          s1.pick_components_flag = 'N')
                    AND (s2.bom_item_type = 3
                    OR
                    NVL(s1.bom_item_type, 4) <> 2
                    OR
                    (s1.bom_item_type = 2
                      AND (( s2.pick_components_flag = 'Y'
                      AND s1.pick_components_flag = 'Y')
                    OR ( s2.replenish_to_order_flag = 'Y'
                    AND s1.replenish_to_order_flag = 'Y'))))
                    AND( (nvl(fnd_profile.VALUE('BOM:MANDATORY_ATO_IN_PTO'),2) <> 1
                             AND
                           NOT(s2.bom_item_type = 4 AND s2.pick_components_flag = 'Y' AND s1.bom_item_type = 4 AND s1.replenish_to_order_flag = 'Y')
                           )
                             OR
                           (nvl(fnd_profile.VALUE('BOM:MANDATORY_ATO_IN_PTO'),2) = 1)
                        )
                     /* BOM ER 9904085,10175288,ATO Item under PTO Model*/
                    AND(   ((nvl(fnd_profile.VALUE('BOM:MANDATORY_ATO_IN_PTO'),    2) <> 1)
                         AND
                   (NOT(s2.bom_item_type = 1 AND s2.pick_components_flag = 'Y' AND nvl(bic.optional, 1) = 2  AND s1.bom_item_type = 4 AND s1.replenish_to_order_flag = 'Y'))
                   )
                        OR
                             (nvl(fnd_profile.VALUE('BOM:MANDATORY_ATO_IN_PTO'),    2) = 1)
                        )
                           /* END BOM ER 9904085,10175288,ATO Item under PTO Model*/
       );


   BEGIN
     IF p_api_version = 1 then
        -- set request id -1 to avoid raising EGO_WF_WRAPPER_PVT.G_ITEM_BULKLOAD_EVENT event
        fnd_global.initialize(FND_CONST.CONC_REQUEST_ID, -1);

        FOR comps_rec IN l_un_assign_eco_comps(p_bill_sequence_id, p_organization_id) LOOP
            IF ( comps_rec.change_notice is not null AND comps_rec.implementation_date is null) THEN
               l_item_org_assignment_tbl(1).Inventory_Item_Id  :=  comps_rec.component_item_id;
	             l_item_org_assignment_tbl(1).Organization_Id    :=  p_organization_id ;

               EGO_Item_PUB.Process_Item_Org_Assignments(
                  p_api_version             =>  1.0
               ,  p_commit                  =>  FND_API.G_FALSE
               ,  p_Item_Org_Assignment_Tbl =>  l_item_org_assignment_tbl
               ,  x_msg_count               =>  l_msg_count
               ,  x_return_status           =>  l_return_status);
            END IF;
        END LOOP;

        fnd_global.initialize(FND_CONST.CONC_REQUEST_ID, l_conc_request_id);

     END IF; -- p_api_version = 1.0

     x_return_status := l_return_status;

     EXCEPTION
       WHEN OTHERS THEN
         FND_MSG_PUB.Count_And_Get
         ( p_count        =>      l_msg_count
          ,p_data         =>      x_msg_data );
         x_return_status := FND_API.G_RET_STS_ERROR;
   END ASSIGN_ECO_COMP_TO_ORGS;

END bom_copy_bill;

/
