--------------------------------------------------------
--  DDL for Package Body PAY_COSTING_KFF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_COSTING_KFF_UTIL_PKG" AS
/* $Header: pykffutl.pkb 120.0 2005/05/29 06:22:31 appldev noship $ */
/*===========================================================================*
 |               Copyright (c) 1994 Oracle Corporation                       |
 |                       All rights reserved.                                |
*============================================================================*/
/*
rem
rem Version    Date        Author      Reason
rem 110.0      28-Aug-1998 S.Billing   Created file
rem 110.2      25-Feb-1999 S.Billing   Modified cursor behaviour,
rem                                    also return row if no segments
rem                                    qualified at passed in lvl;
rem                                    and if called from LEL form,
rem                                    check if Balancing segments
rem                                    are qualified, if not then return
rem                                    row,
rem                                    both changes avoid CAKFF errors
rem 110.4      29-Oct-1999 A.Logue     New procedure
rem                                    costing_kff_null_default_segs
rem                                    to handle issue of segment
rem                                    default values erroneously
rem                                    getting into various levels
rem                                    of costing.
rem 115.5      25-MAY-2003 A.Logue     Further qualify by id_flex_code
rem                                    = 'COST' when joining to
rem                                    FND_SEGMENT_ATTRIBUTE_VALUES.
rem                                    And NOCOPY changes.
rem                                    Bug 2961843.
rem 115.6      25-Sep-2003 swinton     Enhancement 3121279. Added:
rem                                    - cost_keyflex_segment_defined function
rem                                    - get_cost_keyflex_segment_value
rem                                      function
rem                                    - get_cost_keyflex_structure function
rem                                    - validate_costing_keyflex procedure
rem                                    The above are required to support the
rem                                    View Cost Allocation Keyflex OA
rem                                    Framework pages.
rem 115.8      05-JUL-2004 A.Logue     Bug 3744957 : if no required segments
rem                                    in the level when COST_MAND_SEG_CHECK
rem                                    set to 'Y' allow nullset
rem 115.9      09-JUL-2004 A.Logue     Bug 3756198. Performance fixes.
*/

--
-- global package name
--
g_package  VARCHAR2(33) := '  pay_costing_kff_util_pkg.';



-- ----------------------------------------------------------------------------
-- |--------------------< costing_kff_seg_behaviour >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   determines costing kff behaviour,
--
--   if HR:COST_MAND_SEG_CHECK is set to Y, the customer
--   has chosen to make required segments mandatory and not
--   nulls allowed (ie. nulls are not recognised as a valid value),
--   if required segements have been qualified at more than 1 level,
--   the costing process will take its input from the lowest level,
--   thus values defined at higher levels will be redundant,
--
--   if HR:COST_MAND_SEG_CHECK is set to N or is undefined,
--   the cursor is used to infer segment behaviour,
--   if the cursor returns no rows then required segements are made
--   mandatory and nulls are not recognised as valid values
--
-- Pre Conditions:
--   none
--
-- In Arguments:
--   level - current level the calling form is defined as,
--           ie. Assignment, Balancing, Element Link, Element,
--               Organization or Payroll
--
-- Post Success:
--   if HR:COST_MAND_SEG_CHECK is set to Y:
--   p_required = Y and p_allownulls = N
--
--   if HR:COST_MAND_SEG_CHECK is set to N or is undefined:
--   p_required = Y and p_allownulls = N if the following conditions are
--   true:
--   - no segements have been defined at multiple levels,
--   - segments have been defined at multiple levels but are not required,
--   - segments have been defined at multiple levels and are required but
--     do not apply to the current level
--
--   else p_required = N and p_allownulls = Y
--
-- Post Failure:
--   none
--
-- Access Status:
--   public
--
-- {End Of Comments}
--
PROCEDURE costing_kff_seg_behaviour(
  p_level               IN  VARCHAR2,
  p_cost_id_flex_num    IN  NUMBER,
  p_required            OUT NOCOPY VARCHAR2,
  p_allownulls          OUT NOCOPY VARCHAR2)
  IS

  l_proc  VARCHAR2(72) := g_package||'costing_kff_seg_behaviour';

  CURSOR csr_chk_qual_segments IS
      SELECT  'M'
      FROM    FND_SEGMENT_ATTRIBUTE_VALUES sa2,
              FND_ID_FLEX_SEGMENTS         fs,
              FND_SEGMENT_ATTRIBUTE_VALUES sa1
      WHERE   sa1.id_flex_num = p_cost_id_flex_num
      and     sa1.id_flex_code = 'COST'
      and     sa1.attribute_value = 'Y'
      and     sa1.segment_attribute_type <> 'BALANCING'
      and     fs.id_flex_num = p_cost_id_flex_num
      and     fs.id_flex_code = 'COST'
      and     fs.required_flag = 'Y'
      and     fs.enabled_flag  = 'Y'
      and     fs.application_id = 801
      and     fs.application_column_name =
                                         sa1.application_column_name
      and     sa2.id_flex_num = p_cost_id_flex_num
      and     sa2.id_flex_code = 'COST'
      and     sa2.attribute_value = 'Y'
      and     sa1.application_id = fs.application_id
      and     sa2.segment_attribute_type <> 'BALANCING'
      and     sa2.application_id = fs.application_id
      and     sa2.application_column_name =
                                          sa1.application_column_name
      and     sa1.segment_attribute_type <> sa2.segment_attribute_type
      and     sa1.segment_attribute_type = p_level
      UNION ALL
      /*
      ** also return a row if no segments have not been qualified at
      ** passed in lvl,
      ** avoids nasty ff error msg
      */
      SELECT  'N'
      FROM    DUAL
      WHERE   NOT EXISTS
                (SELECT 'Y'
                 FROM    FND_SEGMENT_ATTRIBUTE_VALUES sa
                 WHERE   sa.id_flex_num = p_cost_id_flex_num
                 and     sa.id_flex_code = 'COST'
                 and     sa.application_id = 801
                 and     sa.segment_attribute_type = p_level
                 and     sa.attribute_value = 'Y'
                )
      UNION ALL
      /*
      ** special check for element link form,
      ** if no balancing segments have been defined at this level
      ** then return a row
      */
      SELECT  'B'
      FROM    DUAL
      WHERE   p_level = 'ELEMENT'
      and     NOT EXISTS
              (SELECT 'Y'
               FROM    FND_SEGMENT_ATTRIBUTE_VALUES sa
               WHERE   sa.id_flex_num = p_cost_id_flex_num
               and     sa.id_flex_code = 'COST'
               and     sa.application_id = 801
               and     sa.segment_attribute_type = 'BALANCING'
               and     sa.attribute_value = 'Y'
              )
      ;

  l_chk_qual_segments  VARCHAR2(1);
  l_profile_name       VARCHAR2(60) := 'HR:COST_MAND_SEG_CHECK';
  l_profile_value      VARCHAR2(60);
  l_required           VARCHAR2(1) DEFAULT 'N';
  l_allownulls         VARCHAR2(1) DEFAULT 'Y';
  l_num_reqs_in_this_level NUMBER;

BEGIN
  Hr_Utility.Set_Location('Entering:' || l_proc, 5);

  Fnd_Profile.Get(l_profile_name, l_profile_value);
  Hr_Utility.Trace('  l_profile_value>' || l_profile_value || '<');

  --
  -- user chosen behaviour
  --
  IF (l_profile_value = 'Y') THEN
    --
    -- REQUIRED   = Y - required segments must have a value (null is valid),
    -- REQUIRED   = N - required segments can be left null,
    -- ALLOWNULLS = Y - required segments do not allow null values
    --

    SELECT  count(*)
    INTO    l_num_reqs_in_this_level
    FROM    FND_ID_FLEX_SEGMENTS         fs,
            FND_SEGMENT_ATTRIBUTE_VALUES sa1
    WHERE   sa1.id_flex_num = p_cost_id_flex_num
    and     sa1.id_flex_code = 'COST'
    and     sa1.application_id = fs.application_id
    and     sa1.attribute_value = 'Y'
    and     sa1.segment_attribute_type <> 'BALANCING'
    and     sa1.segment_attribute_type = p_level
    and     fs.id_flex_num = p_cost_id_flex_num
    and     fs.id_flex_code = 'COST'
    and     fs.required_flag = 'Y'
    and     fs.enabled_flag  = 'Y'
    and     fs.application_id = 801
    and     fs.application_column_name =
                                       sa1.application_column_name;

    -- Bug 3744957 : if no required segments in this level
    -- then don't expect anything for them

    IF (l_num_reqs_in_this_level = 0) THEN
      l_required := 'N';
      l_allownulls := 'Y';
    ELSE
      l_required := 'Y';
      l_allownulls := 'N';
    END IF;

  --
  -- decide which behaviour to implement for existing customer base
  --
  ELSE
    OPEN  csr_chk_qual_segments;
    FETCH csr_chk_qual_segments
    INTO  l_chk_qual_segments;
    CLOSE csr_chk_qual_segments;
    Hr_Utility.Trace('  l_chk_qual_segments>' || l_chk_qual_segments || '<');

    --
    -- if csr returns no rows, l_chk_qual_segments remains null,
    --   implement new behaviour,
    -- if csr returns a row, l_chk_qual_segments is not null,
    --   use old behaviour
    --
    IF (l_chk_qual_segments IS NULL) THEN
      l_required := 'Y';
      l_allownulls := 'N';
    END IF;

  END IF;

  Hr_Utility.Trace('  l_required>' || l_required || '<');
  Hr_Utility.Trace('  l_allownulls>' || l_allownulls || '<');

  p_required := l_required;
  p_allownulls := l_allownulls;

  Hr_Utility.Set_Location('Leaving:' || l_proc, 10);

EXCEPTION
  WHEN OTHERS THEN
    Raise;
END costing_kff_seg_behaviour;

-- ----------------------------------------------------------------------------
-- |--------------------< costing_kff_null_default_segs >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   It nullifies any segment values that shouldn't actually have a value
--   at the level passed in ie not qualified
--
--   This procedure should be called from the various forms used for
--   costing data entry to get around the issue whereby any segment
--   given a default value in the flexfield definition will be given
--   that value by the FND API used to handle the entry of the
--   flexfield on the screen if a value was not supplied on the screen.
--   Thus a segment not qualified at a level will be given the
--   default value thus breaking our costing
--   hierarchial approach strategy.

--
-- Pre Conditions:
--   none
--
-- In Arguments:
--   level - current level the calling form is defined as,
--           ie. Assignment, Balancing, Element Link, Element,
--               Organization or Payroll
--
--     do not apply to the current level
--
-- Access Status:
--   public
--
-- {End Of Comments}
--
PROCEDURE costing_kff_null_default_segs(
  p_level               IN     VARCHAR2,
  p_cost_id_flex_num    IN     NUMBER,
  p_segment1            IN OUT NOCOPY VARCHAR2,
  p_segment2            IN OUT NOCOPY VARCHAR2,
  p_segment3            IN OUT NOCOPY VARCHAR2,
  p_segment4            IN OUT NOCOPY VARCHAR2,
  p_segment5            IN OUT NOCOPY VARCHAR2,
  p_segment6            IN OUT NOCOPY VARCHAR2,
  p_segment7            IN OUT NOCOPY VARCHAR2,
  p_segment8            IN OUT NOCOPY VARCHAR2,
  p_segment9            IN OUT NOCOPY VARCHAR2,
  p_segment10           IN OUT NOCOPY VARCHAR2,
  p_segment11           IN OUT NOCOPY VARCHAR2,
  p_segment12           IN OUT NOCOPY VARCHAR2,
  p_segment13           IN OUT NOCOPY VARCHAR2,
  p_segment14           IN OUT NOCOPY VARCHAR2,
  p_segment15           IN OUT NOCOPY VARCHAR2,
  p_segment16           IN OUT NOCOPY VARCHAR2,
  p_segment17           IN OUT NOCOPY VARCHAR2,
  p_segment18           IN OUT NOCOPY VARCHAR2,
  p_segment19           IN OUT NOCOPY VARCHAR2,
  p_segment20           IN OUT NOCOPY VARCHAR2,
  p_segment21           IN OUT NOCOPY VARCHAR2,
  p_segment22           IN OUT NOCOPY VARCHAR2,
  p_segment23           IN OUT NOCOPY VARCHAR2,
  p_segment24           IN OUT NOCOPY VARCHAR2,
  p_segment25           IN OUT NOCOPY VARCHAR2,
  p_segment26           IN OUT NOCOPY VARCHAR2,
  p_segment27           IN OUT NOCOPY VARCHAR2,
  p_segment28           IN OUT NOCOPY VARCHAR2,
  p_segment29           IN OUT NOCOPY VARCHAR2,
  p_segment30           IN OUT NOCOPY VARCHAR2)
  IS

  l_proc  VARCHAR2(72) := g_package||'costing_kff_null_default_segs';

  PROCEDURE check_seg_value(p_segment          IN     VARCHAR2,
                            p_segment_value    IN OUT NOCOPY VARCHAR2)
  IS

    l_proc  VARCHAR2(72) := g_package||'check_seg_value';

  BEGIN
    Hr_Utility.Set_Location('Entering: '|| l_proc, 5);

    if p_segment_value is not null then

      Hr_Utility.Set_Location(l_proc, 10);

      SELECT  decode(attribute_value, 'Y', p_segment_value, null)
      INTO    p_segment_value
      FROM    FND_SEGMENT_ATTRIBUTE_VALUES sa1
      WHERE   sa1.id_flex_num = p_cost_id_flex_num
      AND     sa1.id_flex_code = 'COST'
      AND     sa1.application_id = 801
      AND     sa1.application_column_name = p_segment
      AND     sa1.segment_attribute_type = p_level;

      Hr_Utility.Set_Location(l_proc, 15);

    end if;

    Hr_Utility.Set_Location('Leaving: ' || l_proc, 20);

  END check_seg_value;


BEGIN
  Hr_Utility.Set_Location('Entering:' || l_proc, 5);

  if (p_level <> 'BALANCING' and
      p_level <> 'PAYROLL') then

      Hr_Utility.Set_Location(l_proc, 10);

      check_seg_value('SEGMENT1',  p_segment1);
      check_seg_value('SEGMENT2',  p_segment2);
      check_seg_value('SEGMENT3',  p_segment3);
      check_seg_value('SEGMENT4',  p_segment4);
      check_seg_value('SEGMENT5',  p_segment5);
      check_seg_value('SEGMENT6',  p_segment6);
      check_seg_value('SEGMENT7',  p_segment7);
      check_seg_value('SEGMENT8',  p_segment8);
      check_seg_value('SEGMENT9',  p_segment9);
      check_seg_value('SEGMENT9',  p_segment9);
      check_seg_value('SEGMENT10', p_segment10);
      check_seg_value('SEGMENT11', p_segment11);
      check_seg_value('SEGMENT12', p_segment12);
      check_seg_value('SEGMENT13', p_segment13);
      check_seg_value('SEGMENT14', p_segment14);
      check_seg_value('SEGMENT15', p_segment15);
      check_seg_value('SEGMENT16', p_segment16);
      check_seg_value('SEGMENT17', p_segment17);
      check_seg_value('SEGMENT18', p_segment18);
      check_seg_value('SEGMENT19', p_segment19);
      check_seg_value('SEGMENT20', p_segment20);
      check_seg_value('SEGMENT21', p_segment21);
      check_seg_value('SEGMENT22', p_segment22);
      check_seg_value('SEGMENT23', p_segment23);
      check_seg_value('SEGMENT24', p_segment24);
      check_seg_value('SEGMENT25', p_segment25);
      check_seg_value('SEGMENT26', p_segment26);
      check_seg_value('SEGMENT27', p_segment27);
      check_seg_value('SEGMENT28', p_segment28);
      check_seg_value('SEGMENT29', p_segment29);
      check_seg_value('SEGMENT30', p_segment30);

  end if;

  Hr_Utility.Set_Location('Leaving:' || l_proc, 20);

EXCEPTION
  WHEN OTHERS THEN
    Raise;
END costing_kff_null_default_segs;


-- ----------------------------------------------------------------------------
-- |---------------------< cost_keyflex_segment_defined >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns 'Y' if the segment specified by p_segment_name is enabled
--   and displayed for the cost allocation structure defined by
--   p_cost_id_flex_num
--   Returns 'N' otherwise
--
-- Pre Conditions:
--   none
--
-- In Arguments:
--   p_cost_id_flex_num - id of the cost allocation structure
--   p_segment_name - should be one of SEGMENT1, SEGMENT2 .. SEGMENT30
--
-- Access Status:
--   public
--
-- {End Of Comments}
--
function cost_keyflex_segment_defined (
  p_cost_id_flex_num in number,
  p_segment_name in varchar2) return varchar2
is
  --
  cursor csr_segment_exists is
  select 'Y'
  from fnd_id_flex_segments
  where application_id = 801
  and id_flex_num = p_cost_id_flex_num
  and id_flex_code = 'COST'
  and application_column_name = p_segment_name
  and enabled_flag = 'Y'
  and display_flag = 'Y';
  --
  v_segment_exists varchar2(5) := 'N';
  --
begin
  --
  open csr_segment_exists;
  fetch csr_segment_exists into v_segment_exists;
  close csr_segment_exists;
  --
  return v_segment_exists;
  --
end cost_keyflex_segment_defined;


-- ----------------------------------------------------------------------------
-- |--------------------< get_cost_keyflex_segment_value >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the appropriate value for the specified segment, cost
--   allocation structure, assignment and element entry. If the segment is
--   validated by a value set, returns the 'decoded' value, otherwise returns
--   the 'plain' value as stored in pay_people_groups.
--
-- Pre Conditions:
--   none
--
-- In Arguments:
--   p_segment_name - should be one of SEGMENT1, SEGMENT2 .. SEGMENT30
--   p_value_set_id - value set id used by the segment
--   p_value_set_application_id  - value set application id used by the segment
--   p_assignment_id - assignment id
--   p_cost_allocation_id - id of the cost allocation
--   p_element_entry_id - element entry id
--   p_effective_date - effective date
--
-- Access Status:
--   public
--
-- {End Of Comments}
--
function get_cost_keyflex_segment_value (
  p_segment_name in varchar2,
  p_value_set_id in number,
  p_value_set_application_id in number,
  p_assignment_id in number,
  p_cost_allocation_id in number,
  p_element_entry_id in number,
  p_effective_date in date) return varchar2
is
  --
  cursor csr_vset_display_value (
    p_value_set_id in number,
    p_value_set_application_id in number,
    p_value in varchar2) is
  select fnd_flex_val_util.to_display_value (
           p_value,
           format_type,
           flex_value_set_name,
           maximum_size,
           number_precision,
           alphanumeric_allowed_flag,
           uppercase_only_flag,
           'N',
           maximum_value,
           minimum_value ) display_value
  from fnd_flex_value_sets
  where flex_value_set_id = p_value_set_id;
  --
  cursor csr_cost_keyflex_segment_value (
    p_segment_name in varchar2,
    p_assignment_id in number,
    p_cost_allocation_id in number,
    p_element_entry_id in number,
    p_effective_date in date) is
  select decode (
           p_segment_name
           , 'SEGMENT1', nvl(E.segment1,  nvl(A.segment1,  nvl(O.segment1,  nvl(L.segment1,  P.segment1))))
           , 'SEGMENT2', nvl(E.segment2,  nvl(A.segment2,  nvl(O.segment2,  nvl(L.segment2,  P.segment2))))
           , 'SEGMENT3', nvl(E.segment3,  nvl(A.segment3,  nvl(O.segment3,  nvl(L.segment3,  P.segment3))))
           , 'SEGMENT4', nvl(E.segment4,  nvl(A.segment4,  nvl(O.segment4,  nvl(L.segment4,  P.segment4))))
           , 'SEGMENT5', nvl(E.segment5,  nvl(A.segment5,  nvl(O.segment5,  nvl(L.segment5,  P.segment5))))
           , 'SEGMENT6', nvl(E.segment6,  nvl(A.segment6,  nvl(O.segment6,  nvl(L.segment6,  P.segment6))))
           , 'SEGMENT7', nvl(E.segment7,  nvl(A.segment7,  nvl(O.segment7,  nvl(L.segment7,  P.segment7))))
           , 'SEGMENT8', nvl(E.segment8,  nvl(A.segment8,  nvl(O.segment8,  nvl(L.segment8,  P.segment8))))
           , 'SEGMENT9', nvl(E.segment9,  nvl(A.segment9,  nvl(O.segment9,  nvl(L.segment9,  P.segment9))))
           , 'SEGMENT10', nvl(E.segment10,  nvl(A.segment10,  nvl(O.segment10,  nvl(L.segment10,  P.segment10))))
           , 'SEGMENT11', nvl(E.segment11,  nvl(A.segment11,  nvl(O.segment11,  nvl(L.segment11,  P.segment11))))
           , 'SEGMENT12', nvl(E.segment12,  nvl(A.segment12,  nvl(O.segment12,  nvl(L.segment12,  P.segment12))))
           , 'SEGMENT13', nvl(E.segment13,  nvl(A.segment13,  nvl(O.segment13,  nvl(L.segment13,  P.segment13))))
           , 'SEGMENT14', nvl(E.segment14,  nvl(A.segment14,  nvl(O.segment14,  nvl(L.segment14,  P.segment14))))
           , 'SEGMENT15', nvl(E.segment15,  nvl(A.segment15,  nvl(O.segment15,  nvl(L.segment15,  P.segment15))))
           , 'SEGMENT16', nvl(E.segment16,  nvl(A.segment16,  nvl(O.segment16,  nvl(L.segment16,  P.segment16))))
           , 'SEGMENT17', nvl(E.segment17,  nvl(A.segment17,  nvl(O.segment17,  nvl(L.segment17,  P.segment17))))
           , 'SEGMENT18', nvl(E.segment18,  nvl(A.segment18,  nvl(O.segment18,  nvl(L.segment18,  P.segment18))))
           , 'SEGMENT19', nvl(E.segment19,  nvl(A.segment19,  nvl(O.segment19,  nvl(L.segment19,  P.segment19))))
           , 'SEGMENT20', nvl(E.segment20,  nvl(A.segment20,  nvl(O.segment20,  nvl(L.segment20,  P.segment20))))
           , 'SEGMENT21', nvl(E.segment21,  nvl(A.segment21,  nvl(O.segment21,  nvl(L.segment21,  P.segment21))))
           , 'SEGMENT22', nvl(E.segment22,  nvl(A.segment22,  nvl(O.segment22,  nvl(L.segment22,  P.segment22))))
           , 'SEGMENT23', nvl(E.segment23,  nvl(A.segment23,  nvl(O.segment23,  nvl(L.segment23,  P.segment23))))
           , 'SEGMENT24', nvl(E.segment24,  nvl(A.segment24,  nvl(O.segment24,  nvl(L.segment24,  P.segment24))))
           , 'SEGMENT25', nvl(E.segment25,  nvl(A.segment25,  nvl(O.segment25,  nvl(L.segment25,  P.segment25))))
           , 'SEGMENT26', nvl(E.segment26,  nvl(A.segment26,  nvl(O.segment26,  nvl(L.segment26,  P.segment26))))
           , 'SEGMENT27', nvl(E.segment27,  nvl(A.segment27,  nvl(O.segment27,  nvl(L.segment27,  P.segment27))))
           , 'SEGMENT28', nvl(E.segment28,  nvl(A.segment28,  nvl(O.segment28,  nvl(L.segment28,  P.segment28))))
           , 'SEGMENT29', nvl(E.segment29,  nvl(A.segment29,  nvl(O.segment29,  nvl(L.segment29,  P.segment29))))
           , 'SEGMENT30', nvl(E.segment30,  nvl(A.segment30,  nvl(O.segment30,  nvl(L.segment30,  P.segment30))))
           , null ) segment_value
  from   pay_cost_allocation_keyflex          E,
         pay_cost_allocation_keyflex          A,
         pay_cost_allocation_keyflex          O,
         pay_cost_allocation_keyflex          L,
         pay_cost_allocation_keyflex          P,
         pay_element_links_f                  EL,
         hr_all_organization_units            OU,
         pay_payrolls_f                       PP,
         pay_element_entries_f                EE,
         (
           select ASG1.assignment_id,
                  ASG1.payroll_id,
                  ASG1.organization_id,
                  CA.cost_allocation_keyflex_id
           from per_all_assignments_f        ASG1,
                pay_cost_allocations_f       CA
           where ASG1.assignment_id = CA.assignment_id (+)
           and   ASG1.assignment_id = p_assignment_id
           and   nvl( CA.cost_allocation_id, -1) = nvl( p_cost_allocation_id, -1)
           and   p_effective_date between ASG1.effective_start_date
                                  and     ASG1.effective_end_date
           and   p_effective_date between nvl(CA.effective_start_date,p_effective_date)
                                  and     nvl(CA.effective_end_date,p_effective_date)
         union all
         select to_number(ASG3.assignment_id) assignment_id,
                to_number(ASG3.payroll_id) payroll_id,
                to_number(ASG3.organization_id) organization_id,
                to_number(null) cost_allocation_keyflex_id
         from   per_all_assignments_f ASG3
         where ASG3.assignment_id = p_assignment_id
         and   p_effective_date between ASG3.effective_start_date and ASG3.effective_end_date
         and   not exists (
                 select 'X'
                 from   pay_cost_allocations_f CA2
                 where  CA2.assignment_id = ASG3.assignment_id
                 and    p_effective_date between CA2.effective_start_date and CA2.effective_end_date
                 )
         )                                    ASG2
  where  ASG2.assignment_id = EE.assignment_id
  and    EE.element_link_id = EL.element_link_id
  and    EE.element_entry_id = p_element_entry_id
  and    ASG2.payroll_id = PP.payroll_id
  and    ASG2.organization_id = OU.organization_id
  and    EE.cost_allocation_keyflex_id = E.cost_allocation_keyflex_id (+)
  and    ASG2.cost_allocation_keyflex_id = A.cost_allocation_keyflex_id (+)
  and    OU.cost_allocation_keyflex_id = O.cost_allocation_keyflex_id (+)
  and    EL.cost_allocation_keyflex_id = L.cost_allocation_keyflex_id (+)
  and    PP.cost_allocation_keyflex_id = P.cost_allocation_keyflex_id (+)
  and    p_effective_date between EE.effective_start_date and EE.effective_end_date
  and    p_effective_date between EL.effective_start_date and EL.effective_end_date
  and    p_effective_date between PP.effective_start_date and PP.effective_end_date
  and    EL.costable_type = 'C'
  union all
  select decode (
           p_segment_name
           , 'SEGMENT1', nvl(E.segment1,  nvl(L.segment1,  P.segment1))
           , 'SEGMENT2', nvl(E.segment2,  nvl(L.segment2,  P.segment2))
           , 'SEGMENT3', nvl(E.segment3,  nvl(L.segment3,  P.segment3))
           , 'SEGMENT4', nvl(E.segment4,  nvl(L.segment4,  P.segment4))
           , 'SEGMENT5', nvl(E.segment5,  nvl(L.segment5,  P.segment5))
           , 'SEGMENT6', nvl(E.segment6,  nvl(L.segment6,  P.segment6))
           , 'SEGMENT7', nvl(E.segment7,  nvl(L.segment7,  P.segment7))
           , 'SEGMENT8', nvl(E.segment8,  nvl(L.segment8,  P.segment8))
           , 'SEGMENT9', nvl(E.segment9,  nvl(L.segment9,  P.segment9))
           , 'SEGMENT10', nvl(E.segment10,  nvl(L.segment10,  P.segment10))
           , 'SEGMENT11', nvl(E.segment11,  nvl(L.segment11,  P.segment11))
           , 'SEGMENT12', nvl(E.segment12,  nvl(L.segment12,  P.segment12))
           , 'SEGMENT13', nvl(E.segment13,  nvl(L.segment13,  P.segment13))
           , 'SEGMENT14', nvl(E.segment14,  nvl(L.segment14,  P.segment14))
           , 'SEGMENT15', nvl(E.segment15,  nvl(L.segment15,  P.segment15))
           , 'SEGMENT16', nvl(E.segment16,  nvl(L.segment16,  P.segment16))
           , 'SEGMENT17', nvl(E.segment17,  nvl(L.segment17,  P.segment17))
           , 'SEGMENT18', nvl(E.segment18,  nvl(L.segment18,  P.segment18))
           , 'SEGMENT19', nvl(E.segment19,  nvl(L.segment19,  P.segment19))
           , 'SEGMENT20', nvl(E.segment20,  nvl(L.segment20,  P.segment20))
           , 'SEGMENT21', nvl(E.segment21,  nvl(L.segment21,  P.segment21))
           , 'SEGMENT22', nvl(E.segment22,  nvl(L.segment22,  P.segment22))
           , 'SEGMENT23', nvl(E.segment23,  nvl(L.segment23,  P.segment23))
           , 'SEGMENT24', nvl(E.segment24,  nvl(L.segment24,  P.segment24))
           , 'SEGMENT25', nvl(E.segment25,  nvl(L.segment25,  P.segment25))
           , 'SEGMENT26', nvl(E.segment26,  nvl(L.segment26,  P.segment26))
           , 'SEGMENT27', nvl(E.segment27,  nvl(L.segment27,  P.segment27))
           , 'SEGMENT28', nvl(E.segment28,  nvl(L.segment28,  P.segment28))
           , 'SEGMENT29', nvl(E.segment29,  nvl(L.segment29,  P.segment29))
           , 'SEGMENT30', nvl(E.segment30,  nvl(L.segment30,  P.segment30))
           , null) segment_value
  from   pay_cost_allocation_keyflex          E,
         pay_cost_allocation_keyflex          L,
         pay_cost_allocation_keyflex          P,
         pay_element_links_f                  EL,
         pay_payrolls_f                       PP,
         pay_element_entries_f                EE,
         per_all_assignments_f                ASG
  where  ASG.assignment_id = EE.assignment_id
  and    ASG.assignment_id = p_assignment_id
  and    EE.element_link_id = EL.element_link_id
  and    EE.element_entry_id = p_element_entry_id
  and    ASG.payroll_id = PP.payroll_id
  and    EE.cost_allocation_keyflex_id = E.cost_allocation_keyflex_id (+)
  and    EL.cost_allocation_keyflex_id = L.cost_allocation_keyflex_id (+)
  and    PP.cost_allocation_keyflex_id = P.cost_allocation_keyflex_id (+)
  and    p_effective_date between ASG.effective_start_date and ASG.effective_end_date
  and    p_effective_date between EE.effective_start_date and EE.effective_end_date
  and    p_effective_date between EL.effective_start_date and EL.effective_end_date
  and    p_effective_date between PP.effective_start_date and PP.effective_end_date
  and    EL.costable_type = 'F';
  --
  v_segment_value varchar2(2000);
  v_display_value varchar2(2000);
  --
begin
  --
  open csr_cost_keyflex_segment_value (
    p_segment_name ,
    p_assignment_id ,
    p_cost_allocation_id,
    p_element_entry_id ,
    p_effective_date );
  fetch csr_cost_keyflex_segment_value into v_segment_value;
  close csr_cost_keyflex_segment_value;
  --
  open csr_vset_display_value (
    p_value_set_id,
    p_value_set_application_id,
    v_segment_value );
  fetch csr_vset_display_value into v_display_value;
  close csr_vset_display_value;
  --
  -- return nvl(v_display_value, v_segment_value);
  return v_segment_value || ' - ' || v_display_value;
  --
end;

-- ----------------------------------------------------------------------------
-- |-----------------------< validate_costing_keyflex >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Pre Conditions:
--   none
--
-- Description:
--   Performs validation of the cost allocation specified by
--   p_concat_segments. A cost allocation entry is created in
--   pay_cost_allocation_keyflex if the combination is valid and doesn't
--   already exist. Returns the id of the combination if it is valid via
--   p_cost_allocation_keyflex_id, otherwise returns error information via
--   p_error_segment_num, p_error_segment_name and p_error_message.
--
-- In Arguments:
--   p_cost_id_flex_num - id of the cost allocation structure
--   p_concat_segments - the concatenated segments to be validated
--   p_validation_date - the validation date
--   p_resp_appl_id - application id of the responsibility performing the
--   validation
--   p_resp_id - id of the responsibility performing the validation.
--   p_user_id - id of the user who is performing the validation
--
-- Out Arguments:
--   p_cost_allocation_keyflex_id the id of the valid combination.
--   p_error_segment_num the number of the segment causing error in case of
--   an invalid combination (may be null).
--   p_error_segment_name the name of the segment causing error in case of
--   an invalid combination (may be null).
--   p_error_message the error message in case of an invalid combination
--   (may be null).
--
-- Access Status:
--   public
--
-- {End Of Comments}
--
procedure validate_costing_keyflex (
    p_cost_id_flex_num in number
  , p_concat_segments in varchar2
  , p_validation_date in date
  , p_resp_appl_id in number
  , p_resp_id in number
  , p_user_id in number
  , p_cost_allocation_keyflex_id out nocopy number
  , p_error_segment_num out nocopy number
  , p_error_segment_name out nocopy varchar2
  , p_application_col_name out nocopy varchar2
  , p_error_message out nocopy varchar2
  )
is
  --
  v_valid boolean;
  v_flexfield fnd_flex_key_api.flexfield_type;
  v_structure fnd_flex_key_api.structure_type;
  v_segment fnd_flex_key_api.segment_type;
  v_segment_list fnd_flex_key_api.segment_list;
  v_nsegments number;
  --
begin
  --
  v_valid := fnd_flex_keyval.validate_segs (
               operation => 'CREATE_COMBINATION'
             , appl_short_name => 'PAY'
             , key_flex_code => 'COST'
             , structure_number => p_cost_id_flex_num
             , concat_segments => p_concat_segments
             , values_or_ids => 'I'
             , validation_date => p_validation_date
             , resp_appl_id => p_resp_appl_id
             , resp_id => p_resp_id
             , user_id => p_user_id);
  --
  if v_valid then
    --
    p_cost_allocation_keyflex_id := fnd_flex_keyval.combination_id;
    p_error_segment_num := null;
    p_error_segment_name := null;
    p_error_message := null;
    --
    -- update the cost allocation keyflex table with the concatenated
    -- segments
    --
    update pay_cost_allocation_keyflex
    set concatenated_segments = p_concat_segments
    where cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;
    commit;
    --
  else
    --
    p_cost_allocation_keyflex_id := -1;
    p_error_segment_num := fnd_flex_keyval.error_segment;
    p_error_message := fnd_flex_keyval.error_message;
    --
    if p_error_segment_num is not null then
      --
      -- Get the name of the error segment
      --
      fnd_flex_key_api.set_session_mode('customer_data');
      --
      v_flexfield := fnd_flex_key_api.find_flexfield (
        appl_short_name => 'PAY',
        flex_code => 'COST'
        );
      --
      if p_error_segment_num = 0 then
        --
        p_application_col_name := v_flexfield.structure_column;
        p_error_segment_name := null;
        --
      else
        --
        v_structure := fnd_flex_key_api.find_structure (
          flexfield => v_flexfield,
          structure_number => p_cost_id_flex_num
          );
        --
        fnd_flex_key_api.get_segments (
          flexfield => v_flexfield,
          structure => v_structure,
          enabled_only => true,
          nsegments => v_nsegments,
          segments => v_segment_list
          );
        --
        p_error_segment_name := v_segment_list(p_error_segment_num);
        --
        v_segment := fnd_flex_key_api.find_segment (
          flexfield => v_flexfield,
          structure => v_structure,
          segment_name => p_error_segment_name
          );
        --
        p_application_col_name := v_segment.column_name;
        p_error_segment_name := v_segment.window_prompt;
        --
      end if;
      --
    end if;
    --
  end if;
  --
exception
  --
  when others then
    p_cost_allocation_keyflex_id := -1;
  --
end validate_costing_keyflex;

-- ----------------------------------------------------------------------------
-- |----------------------< get_cost_keyflex_structure >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the code of the cost allocation keyflex structure denoted by
--   p_cost_id_flex_num.
--
-- Pre Conditions:
--   none
--
-- In Arguments:
--   p_cost_id_flex_num - the id of the cost allocation keyflex structure
--
-- Access Status:
--   public
--
-- {End Of Comments}
--
function get_cost_keyflex_structure (
  p_cost_id_flex_num in number
  ) return varchar2
is
  --
  v_flexfield fnd_flex_key_api.flexfield_type;
  v_structure fnd_flex_key_api.structure_type;
  --
begin
  --
  fnd_flex_key_api.set_session_mode('customer_data');
  --
  v_flexfield := fnd_flex_key_api.find_flexfield (
    appl_short_name => 'PAY',
    flex_code => 'COST'
    );
  --
  v_structure := fnd_flex_key_api.find_structure (
    flexfield => v_flexfield,
    structure_number => p_cost_id_flex_num
    );
  --
  return v_structure.structure_code;
  --
end get_cost_keyflex_structure;

END pay_costing_kff_util_pkg;

/
