--------------------------------------------------------
--  DDL for Package Body EDW_ORGANIZATION_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_ORGANIZATION_M_SIZING" AS
/* $Header: hriezorg.pkb 120.1 2005/06/08 02:47:42 anmajumd noship $ */

/******************************************************************************/
/* Sets p_row_count to the number of rows which would be collected between    */
/* the given dates                                                            */
/******************************************************************************/
PROCEDURE count_source_rows( p_from_date IN  DATE,
                             p_to_date   IN  DATE,
                             p_row_count OUT NOCOPY NUMBER )
IS

  /* Cursor description */
  CURSOR row_count_cur IS
  SELECT COUNT(*) total
  FROM
   hr_all_organization_units            org
  ,per_business_groups                  bgr
  ,hr_organization_information          oi1
  ,hr_all_organization_units            ou
  ,mtl_parameters                       mp
  ,hr_organization_information          oi2
  ,hri_primary_hrchys                   tree
  WHERE org.business_group_id           = bgr.business_group_id
  AND   org.organization_id             = oi1.organization_id (+)
  AND   oi1.org_information_context (+) = 'Accounting Information'
  AND   to_number(oi1.org_information3) = ou.organization_id (+)
  AND   org.organization_id             = mp.organization_id (+)
  AND   org.organization_id             = oi2.organization_id (+)
  AND   oi2.org_information_context (+) = 'CLASS'
  AND   oi2.org_information1 (+)        = 'OPERATING_UNIT'
  AND   oi2.org_information2 (+)        = 'Y'
  AND   tree.organization_id (+)        = org.organization_id
  AND greatest( NVL(org.last_update_date, to_date('01-01-2000','DD-MM-YYYY')),
                NVL(ou.last_update_date,  to_date('01-01-2000','DD-MM-YYYY')),
                NVL(tree.org_last_updated,to_date('01-01-2000','DD-MM-YYYY')),
                NVL(oi1.last_update_date, to_date('01-01-2000','DD-MM-YYYY')),
                NVL(mp.last_update_date,  to_date('01-01-2000','DD-MM-YYYY')),
                NVL(oi2.last_update_date, to_date('01-01-2000','DD-MM-YYYY')))
    BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN row_count_cur;
  FETCH row_count_cur INTO p_row_count;
  CLOSE row_count_cur;

END count_source_rows;


/******************************************************************************/
/* Estimates row lengths.                                                     */
/******************************************************************************/
PROCEDURE estimate_row_length( p_from_date       IN  DATE,
                               p_to_date         IN  DATE,
                               p_avg_row_length  OUT NOCOPY NUMBER )
IS

  x_date                   NUMBER := 7;

  x_total_business_grp     NUMBER;
  x_total_leg_entity       NUMBER;
  x_total_oper_unit        NUMBER;
  x_total_tree1_lvl8       NUMBER;
  x_total_tree1_lvl7       NUMBER;
  x_total_tree1_lvl6       NUMBER;
  x_total_tree1_lvl5       NUMBER;
  x_total_tree1_lvl4       NUMBER;
  x_total_tree1_lvl3       NUMBER;
  x_total_tree1_lvl2       NUMBER;
  x_total_tree1_lvl1       NUMBER;
  x_total_organization     NUMBER;

/* Business Group Level */
  x_business_group_dp      NUMBER := 0;
  x_business_group_pk      NUMBER := 0;
  x_creation_date          NUMBER := x_date;
  x_date_from              NUMBER := x_date;
  x_date_to                NUMBER := x_date;
  x_instance               NUMBER := 0;
  x_int_ext_flag           NUMBER := 0;
  x_last_update_date       NUMBER := x_date;
  x_bg_name                NUMBER := 0;
  x_org_code               NUMBER := 0;
  x_org_type               NUMBER := 0;
  x_primary_cst_mthd       NUMBER := 0;
  x_business_group_id      NUMBER := 0;
  x_cost_allocation        NUMBER := 0;
  x_legislation            NUMBER := 0;

/* Level Entity Level */
  x_business_group_fk      NUMBER := 0;
  x_legal_entity_dp        NUMBER := 0;
  x_legal_entity_pk        NUMBER := 0;
  x_level_name             NUMBER := 2;
  x_lg_name                NUMBER := 0;
  x_set_of_books           NUMBER := 0;

/* Operating Unit Level */
  x_business_grp           NUMBER := 0;
  x_legal_entity_fk        NUMBER := 0;
  x_ou_name                NUMBER := 0;
  x_operating_unit_dp      NUMBER := 0;
  x_operating_unit_pk      NUMBER := 0;

/* Organization Level */
  x_org_name               NUMBER := 0;
  x_operating_unit_fk      NUMBER := 0;
  x_organization_pk        NUMBER := 0;
  x_organization_dp        NUMBER := 0;
  x_org_tree1_lvl1_fk      NUMBER := 0;

/* Tree 1 Level 8 */
  x_l8_name                NUMBER := 0;
  x_org_tree1_lvl8_pk      NUMBER := 0;

/* Tree 1 Level 7 */
  x_l7_name                NUMBER := 0;
  x_org_tree1_lvl7_pk      NUMBER := 0;
  x_org_tree1_lvl8_fk      NUMBER := 0;

/* Tree 1 Level 6 */
  x_l6_name                NUMBER := 0;
  x_org_tree1_lvl6_pk      NUMBER := 0;
  x_org_tree1_lvl7_fk      NUMBER := 0;

/* Tree 1 Level 5 */
  x_l5_name                NUMBER := 0;
  x_org_tree1_lvl5_pk      NUMBER := 0;
  x_org_tree1_lvl6_fk      NUMBER := 0;

/* Tree 1 Level 4 */
  x_l4_name                NUMBER := 0;
  x_org_tree1_lvl4_pk      NUMBER := 0;
  x_org_tree1_lvl5_fk      NUMBER := 0;

/* Tree 1 Level 3 */
  x_l3_name                NUMBER := 0;
  x_org_tree1_lvl3_pk      NUMBER := 0;
  x_org_tree1_lvl4_fk      NUMBER := 0;

/* Tree 1 Level 2 */
  x_l2_name                NUMBER := 0;
  x_org_tree1_lvl2_pk      NUMBER := 0;
  x_org_tree1_lvl3_fk      NUMBER := 0;

/* Tree 1 Level 1 */
  x_l1_name                NUMBER := 0;
  x_org_tree1_lvl1_pk      NUMBER := 0;
  x_org_tree1_lvl2_fk      NUMBER := 0;

/* Selects the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl(vsize(instance_code),0))
  FROM edw_local_instance;

  CURSOR org_cur IS
  SELECT
   avg(nvl(vsize(name),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('INTL_EXTL',internal_external_flag)),0))
  ,avg(nvl(vsize(type),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('ORG_TYPE',type)),0))
  ,avg(nvl(vsize(organization_id),0))
  FROM hr_all_organization_units
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR pcm_cur IS
  SELECT avg(nvl(vsize(primary_cost_method),0))
  FROM mtl_parameters
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR cst_cur IS
  SELECT avg(nvl(vsize(id_flex_structure_name),0))
  FROM fnd_id_flex_structures_vl
  WHERE application_id = 801
  AND id_flex_code = 'COST'
  AND last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR leg_cur IS
  SELECT avg(nvl(vsize(territory_short_name),0))
  FROM fnd_territories_vl
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR sob_cur IS
  SELECT avg(nvl(vsize(name),0))
  FROM gl_sets_of_books
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

  OPEN org_cur;
  FETCH org_cur INTO x_bg_name, x_int_ext_flag, x_org_code, x_org_type, x_business_group_id;
  CLOSE org_cur;

  OPEN pcm_cur;
  FETCH pcm_cur INTO x_primary_cst_mthd;
  CLOSE pcm_cur;

  OPEN cst_cur;
  FETCH cst_cur INTO x_cost_allocation;
  CLOSE cst_cur;

  OPEN leg_cur;
  FETCH leg_cur INTO x_legislation;
  CLOSE leg_cur;

  OPEN sob_cur;
  FETCH sob_cur INTO x_set_of_books;
  CLOSE sob_cur;

/* Business Group Level */

  x_business_group_pk := x_business_group_id + x_instance;
  x_business_group_dp := x_bg_name;

  x_total_business_grp := NVL (ceil(x_business_group_pk + 1), 0)
                        + NVL (ceil(x_business_group_dp + 1), 0)
                        + NVL (ceil(x_creation_date + 1), 0)
                        + NVL (ceil(x_date_from + 1), 0)
                        + NVL (ceil(x_date_to + 1), 0)
                        + NVL (ceil(x_instance + 1), 0)
                        + NVL (ceil(x_int_ext_flag + 1), 0)
                        + NVL (ceil(x_last_update_date + 1), 0)
                        + NVL (ceil(x_bg_name + 1), 0)
                        + NVL (ceil(x_org_type + 1), 0)
                        + NVL (ceil(x_org_code + 1), 0)
                        + NVL (ceil(x_primary_cst_mthd + 1), 0)
                        + NVL (ceil(x_business_group_id + 1), 0)
                        + NVL (ceil(x_cost_allocation + 1), 0)
                        + NVL (ceil(x_legislation + 1), 0);

/* Legal Entity Level */

  x_legal_entity_pk := x_business_group_id + x_instance;
  x_business_group_fk := x_business_group_pk;
  x_lg_name := 2 * x_bg_name;
  x_legal_entity_dp := x_lg_name;

  x_total_leg_entity :=  NVL (ceil(x_business_group_fk + 1), 0)
                       + NVL (ceil(x_creation_date + 1), 0)
                       + NVL (ceil(x_date_from + 1), 0)
                       + NVL (ceil(x_date_to + 1), 0)
                       + NVL (ceil(x_instance + 1), 0)
                       + NVL (ceil(x_int_ext_flag + 1), 0)
                       + NVL (ceil(x_last_update_date + 1), 0)
                       + NVL (ceil(x_legal_entity_dp + 1), 0)
                       + NVL (ceil(x_legal_entity_pk + 1), 0)
                       + NVL (ceil(x_level_name + 1), 0)
                       + NVL (ceil(x_lg_name + 1), 0)
                       + NVL (ceil(x_org_type + 1), 0)
                       + NVL (ceil(x_org_code + 1), 0)
                       + NVL (ceil(x_primary_cst_mthd + 1), 0)
                       + NVL (ceil(x_set_of_books + 1), 0)
                       + NVL (ceil(x_business_group_id + 1), 0);

/* Operating Unit Level */

  x_operating_unit_pk := x_business_group_id + x_instance;
  x_business_grp := x_bg_name;
  x_legal_entity_fk := x_legal_entity_pk;
  x_ou_name := x_lg_name;
  x_operating_unit_dp := x_ou_name;

  x_total_oper_unit :=  NVL (ceil(x_business_grp + 1), 0)
                      + NVL (ceil(x_creation_date + 1), 0)
                      + NVL (ceil(x_date_from + 1), 0)
                      + NVL (ceil(x_date_to + 1), 0)
                      + NVL (ceil(x_instance + 1), 0)
                      + NVL (ceil(x_int_ext_flag + 1), 0)
                      + NVL (ceil(x_last_update_date + 1), 0)
                      + NVL (ceil(x_legal_entity_fk + 1), 0)
                      + NVL (ceil(x_level_name + 1), 0)
                      + NVL (ceil(x_ou_name + 1), 0)
                      + NVL (ceil(x_operating_unit_dp + 1), 0)
                      + NVL (ceil(x_operating_unit_pk + 1), 0)
                      + NVL (ceil(x_org_type + 1), 0)
                      + NVL (ceil(x_org_code + 1), 0)
                      + NVL (ceil(x_primary_cst_mthd + 1), 0)
                      + NVL (ceil(x_business_group_id + 1), 0);

/* Organization Level */

  x_organization_pk := x_business_group_id + x_instance;
  x_operating_unit_fk := x_operating_unit_pk;
  x_org_tree1_lvl1_fk := x_business_group_id + x_instance;
  x_org_name := x_ou_name;
  x_organization_dp := x_org_name;

  x_total_organization :=  NVL (ceil(x_business_grp + 1), 0)
                         + NVL (ceil(x_creation_date + 1), 0)
                         + NVL (ceil(x_date_from + 1), 0)
                         + NVL (ceil(x_date_to + 1), 0)
                         + NVL (ceil(x_instance + 1), 0)
                         + NVL (ceil(x_int_ext_flag + 1), 0)
                         + NVL (ceil(x_last_update_date + 1), 0)
                         + NVL (ceil(x_level_name + 1), 0)
                         + NVL (ceil(x_org_name + 1), 0)
                         + NVL (ceil(x_operating_unit_fk + 1), 0)
                         + NVL (ceil(x_organization_dp + 1), 0)
                         + NVL (ceil(x_organization_pk + 1), 0)
                         + NVL (ceil(x_org_type + 1), 0)
                         + NVL (ceil(x_org_code + 1), 0)
                         + NVL (ceil(x_primary_cst_mthd + 1), 0)
                         + NVL (ceil(x_business_group_id + 1), 0)
                         + NVL (ceil(x_org_tree1_lvl1_fk + 1), 0);

/* Tree 1 Level 8 */

  x_org_tree1_lvl8_pk := x_business_group_id + x_instance;
  x_l8_name := x_org_name;

  x_total_tree1_lvl8 :=  NVL (ceil(x_business_grp + 1), 0)
                       + NVL (ceil(x_creation_date + 1), 0)
                       + NVL (ceil(x_instance + 1), 0)
                       + NVL (ceil(x_last_update_date + 1), 0)
                       + NVL (ceil(x_l8_name + 1), 0)
                       + NVL (ceil(x_business_group_id + 1), 0)
                       + NVL (ceil(x_org_tree1_lvl8_pk + 1), 0)
                       + NVL (ceil(x_l8_name + 1), 0);

/* Tree 1 Level 7 */

  x_org_tree1_lvl7_pk := x_business_group_id + x_instance;
  x_org_tree1_lvl8_fk := x_org_tree1_lvl8_pk;
  x_l7_name := x_org_name;

  x_total_tree1_lvl7 :=  NVL (ceil(x_business_grp + 1), 0)
                       + NVL (ceil(x_creation_date + 1), 0)
                       + NVL (ceil(x_instance + 1), 0)
                       + NVL (ceil(x_last_update_date + 1), 0)
                       + NVL (ceil(x_l7_name + 1), 0)
                       + NVL (ceil(x_business_group_id + 1), 0)
                       + NVL (ceil(x_org_tree1_lvl7_pk + 1), 0)
                       + NVL (ceil(x_org_tree1_lvl8_fk + 1), 0)
                       + NVL (ceil(x_l8_name + 1), 0);

/* Tree 1 Level 1 - 6 (same as Level 7) */

/* TOTAL */

  p_avg_row_length :=  x_total_business_grp
                     + x_total_leg_entity
                     + x_total_oper_unit
                     + x_total_organization
                     + x_total_tree1_lvl8
                     + (7 * x_total_tree1_lvl7);

END estimate_row_length;

END edw_organization_m_sizing;

/
