--------------------------------------------------------
--  DDL for Package Body PAY_CSK_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CSK_FLEX" as
/* $Header: pycskfli.pkb 115.0 99/07/17 05:55:34 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_csk_flex.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |-------------------------------< kf >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure kf
        (p_rec               in pay_csk_shd.g_rec_type) is
--
  l_proc             varchar2(72) := g_package||'kf';
  l_error      exception;
  l_legislation_code per_business_groups.legislation_code%type;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that p_rec.id_flex_num is mandatory
  --
  if (p_rec.id_flex_num is not null) then
    null;
  else
    -- *** TEMP error message ***
    hr_utility.set_message(801, 'HR_7296_API_ARG_NOT_SUP');
    hr_utility.set_message_token('ARG_NAME', 'id_flex_num');
    hr_utility.set_message_token('ARG_VALUE', to_char(p_rec.id_flex_num));
    hr_utility.raise_error;
  end if;
  --

  if p_rec.segment1 is not null then
    raise l_error;
  end if;
  if p_rec.segment2 is not null then
    raise l_error;
  end if;
  if p_rec.segment3 is not null then
    raise l_error;
  end if;
  if p_rec.segment4 is not null then
    raise l_error;
  end if;
  if p_rec.segment5 is not null then
    raise l_error;
  end if;
  if p_rec.segment6 is not null then
    raise l_error;
  end if;
  if p_rec.segment7 is not null then
    raise l_error;
  end if;
  if p_rec.segment8 is not null then
    raise l_error;
  end if;
  if p_rec.segment9 is not null then
    raise l_error;
  end if;
  if p_rec.segment10 is not null then
    raise l_error;
  end if;
  if p_rec.segment11 is not null then
    raise l_error;
  end if;
  if p_rec.segment12 is not null then
    raise l_error;
  end if;
  if p_rec.segment13 is not null then
    raise l_error;
  end if;
  if p_rec.segment14 is not null then
    raise l_error;
  end if;
  if p_rec.segment15 is not null then
    raise l_error;
  end if;
  if p_rec.segment16 is not null then
    raise l_error;
  end if;
  if p_rec.segment17 is not null then
    raise l_error;
  end if;
  if p_rec.segment18 is not null then
    raise l_error;
  end if;
  if p_rec.segment19 is not null then
    raise l_error;
  end if;
  if p_rec.segment20 is not null then
    raise l_error;
  end if;
  if p_rec.segment21 is not null then
    raise l_error;
  end if;
  if p_rec.segment22 is not null then
    raise l_error;
  end if;
  if p_rec.segment23 is not null then
    raise l_error;
  end if;
  if p_rec.segment24 is not null then
    raise l_error;
  end if;
  if p_rec.segment25 is not null then
    raise l_error;
  end if;
  if p_rec.segment26 is not null then
    raise l_error;
  end if;
  if p_rec.segment27 is not null then
    raise l_error;
  end if;
  if p_rec.segment28 is not null then
    raise l_error;
  end if;
  if p_rec.segment29 is not null then
    raise l_error;
  end if;
  if p_rec.segment30 is not null then
    raise l_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when l_error then
    hr_utility.set_message(801, 'HR_7439_FLEX_INV_ATTRIBUTE_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end kf;
--

--
FUNCTION get_cost_allocation_id(p_business_group_id          in number,
			        p_cost_allocation_keyflex_id in number,
			        p_concatenated_segments      in varchar2,
                                p_segment1        in varchar2 default NULL,
                                p_segment2        in varchar2 default NULL,
                                p_segment3        in varchar2 default NULL,
                                p_segment4        in varchar2 default NULL,
                                p_segment5        in varchar2 default NULL,
                                p_segment6        in varchar2 default NULL,
                                p_segment7        in varchar2 default NULL,
                                p_segment8        in varchar2 default NULL,
                                p_segment9        in varchar2 default NULL,
                                p_segment10       in varchar2 default NULL,
                                p_segment11       in varchar2 default NULL,
                                p_segment12       in varchar2 default NULL,
                                p_segment13       in varchar2 default NULL,
                                p_segment14       in varchar2 default NULL,
                                p_segment15       in varchar2 default NULL,
                                p_segment16       in varchar2 default NULL,
                                p_segment17       in varchar2 default NULL,
                                p_segment18       in varchar2 default NULL,
                                p_segment19       in varchar2 default NULL,
                                p_segment20       in varchar2 default NULL,
                                p_segment21       in varchar2 default NULL,
                                p_segment22       in varchar2 default NULL,
                                p_segment23       in varchar2 default NULL,
                                p_segment24       in varchar2 default NULL,
                                p_segment25       in varchar2 default NULL,
                                p_segment26       in varchar2 default NULL,
                                p_segment27       in varchar2 default NULL,
                                p_segment28       in varchar2 default NULL,
                                p_segment29       in varchar2 default NULL,
                                p_segment30       in varchar2 default NULL)
                                return number is

        l_structure                     NUMBER;

BEGIN

SELECT cost_allocation_structure
INTO   l_structure
FROM   per_business_groups pbg
WHERE  pbg.business_group_id = p_business_group_id;

if (p_cost_allocation_keyflex_id IS NOT NULL) then
   if (p_segment1 IS NOT NULL or
       p_segment2 IS NOT NULL or
       p_segment3 IS NOT NULL or
       p_segment4 IS NOT NULL or
       p_segment5 IS NOT NULL or
       p_segment6 IS NOT NULL or
       p_segment7 IS NOT NULL or
       p_segment8 IS NOT NULL or
       p_segment9 IS NOT NULL or
       p_segment10 IS NOT NULL or
       p_segment11 IS NOT NULL or
       p_segment12 IS NOT NULL or
       p_segment13 IS NOT NULL or
       p_segment14 IS NOT NULL or
       p_segment15 IS NOT NULL or
       p_segment16 IS NOT NULL or
       p_segment17 IS NOT NULL or
       p_segment18 IS NOT NULL or
       p_segment19 IS NOT NULL or
       p_segment20 IS NOT NULL or
       p_segment21 IS NOT NULL or
       p_segment22 IS NOT NULL or
       p_segment23 IS NOT NULL or
       p_segment24 IS NOT NULL or
       p_segment25 IS NOT NULL or
       p_segment26 IS NOT NULL or
       p_segment27 IS NOT NULL or
       p_segment28 IS NOT NULL or
       p_segment29 IS NOT NULL or
       p_segment30 IS NOT NULL) then
          return hr_entry.maintain_cost_keyflex (
        				   l_structure,
        				   -1,
        				   p_concatenated_segments,
        				   'N',
        				   '',
        				   '',
        				   p_segment1,
        				   p_segment2,
        				   p_segment3,
        				   p_segment4,
        				   p_segment5,
        				   p_segment6,
        				   p_segment7,
        				   p_segment8,
        				   p_segment9,
        				   p_segment10,
        				   p_segment11,
        				   p_segment12,
        				   p_segment13,
        				   p_segment14,
        				   p_segment15,
        				   p_segment16,
        				   p_segment17,
        				   p_segment18,
        				   p_segment19,
        				   p_segment20,
        				   p_segment21,
        				   p_segment22,
        				   p_segment23,
        				   p_segment24,
        				   p_segment25,
        				   p_segment26,
        				   p_segment27,
        				   p_segment28,
        				   p_segment29,
        				   p_segment30);
   end if;
else
   return null;
end if;


END get_cost_allocation_id;
--
--
end pay_csk_flex;

/
