--------------------------------------------------------
--  DDL for Package Body PAY_PGP_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PGP_FLEX" as
/* $Header: pypgpfli.pkb 115.0 99/07/17 06:21:49 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pgp_flex.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |-------------------------------< kf >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure kf
        (p_rec               in pay_pgp_shd.g_rec_type) is
--
  l_proc             varchar2(72) := g_package||'kf';
  l_legislation_code per_business_groups.legislation_code%type;
  l_error            exception;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that p_rec.id_flex_num is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'P_ID_FLEX_NUM',
     p_argument_value => p_rec.id_flex_num);
  --
  -- branch on id_flex_num. this will be modified by users.
  --
  if p_rec.id_flex_num is not null then
      --
      -- If segment values are not null then
      -- an error must be flagged until user
      -- defined key flex validation has
      -- been entered
      --
    if p_rec.segment1 is not null then
      raise l_error;
    elsif p_rec.segment2 is not null then
      raise l_error;
    elsif p_rec.segment3 is not null then
      raise l_error;
    elsif p_rec.segment4 is not null then
      raise l_error;
    elsif p_rec.segment5 is not null then
      raise l_error;
    elsif p_rec.segment6 is not null then
      raise l_error;
    elsif p_rec.segment7 is not null then
      raise l_error;
    elsif p_rec.segment8 is not null then
      raise l_error;
    elsif p_rec.segment9 is not null then
      raise l_error;
    elsif p_rec.segment10 is not null then
      raise l_error;
    elsif p_rec.segment11 is not null then
      raise l_error;
    elsif p_rec.segment12 is not null then
      raise l_error;
    elsif p_rec.segment13 is not null then
      raise l_error;
    elsif p_rec.segment14 is not null then
      raise l_error;
    elsif p_rec.segment15 is not null then
      raise l_error;
    elsif p_rec.segment16 is not null then
      raise l_error;
    elsif p_rec.segment17 is not null then
      raise l_error;
    elsif p_rec.segment18 is not null then
      raise l_error;
    elsif p_rec.segment19 is not null then
      raise l_error;
    elsif p_rec.segment20 is not null then
      raise l_error;
    elsif p_rec.segment21 is not null then
      raise l_error;
    elsif p_rec.segment22 is not null then
      raise l_error;
    elsif p_rec.segment23 is not null then
      raise l_error;
    elsif p_rec.segment24 is not null then
      raise l_error;
    elsif p_rec.segment25 is not null then
      raise l_error;
    elsif p_rec.segment26 is not null then
      raise l_error;
    elsif p_rec.segment27 is not null then
      raise l_error;
    elsif p_rec.segment28 is not null then
      raise l_error;
    elsif p_rec.segment29 is not null then
      raise l_error;
    elsif p_rec.segment30 is not null then
      raise l_error;
    end if;
    --
  end if;
  --
exception
  when l_error then
    hr_utility.set_message(801, 'HR_51337_PGP_KEY_FLEX_SEG_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);
end kf;
--
end pay_pgp_flex;

/
