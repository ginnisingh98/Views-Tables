--------------------------------------------------------
--  DDL for Package Body HR_CGD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CGD_INS" as
/* $Header: hrcgdrhi.pkb 115.4 2002/12/03 09:17:25 hjonnala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_cgd_ins.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
procedure ins_or_sel
         (p_segment1               in  varchar2 default null,
          p_segment2               in  varchar2 default null,
          p_segment3               in  varchar2 default null,
          p_segment4               in  varchar2 default null,
          p_segment5               in  varchar2 default null,
          p_segment6               in  varchar2 default null,
          p_segment7               in  varchar2 default null,
          p_segment8               in  varchar2 default null,
          p_segment9               in  varchar2 default null,
          p_segment10              in  varchar2 default null,
          p_segment11              in  varchar2 default null,
          p_segment12              in  varchar2 default null,
          p_segment13              in  varchar2 default null,
          p_segment14              in  varchar2 default null,
          p_segment15              in  varchar2 default null,
          p_segment16              in  varchar2 default null,
          p_segment17              in  varchar2 default null,
          p_segment18              in  varchar2 default null,
          p_segment19              in  varchar2 default null,
          p_segment20              in  varchar2 default null,
          p_id_flex_num            in  number   default null,
          p_business_group_id      in  number,
          p_cagr_grade_def_id      out nocopy number,
          p_concatenated_segments  out nocopy varchar2
          ) is
--
  l_cagr_grade_def_id      per_cagr_grades_def.cagr_grade_def_id%type;
  l_concatenated_segments  varchar2(2000);
  l_id_flex_num            per_cagr_grades_def.id_flex_num%type;
  l_proc                   varchar2(72) := g_package||'ins_or_sel';
  l_segs_changed           boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- set the client_info
  --
  hr_api.validate_bus_grp_id (p_business_group_id);
  --
  -- on insert, if any segments are set, but there is no ID_FLEX_NUM,
  -- raise an error.
  --
  IF
    (p_segment1 is not null) or
    (p_segment2 is not null) or
    (p_segment3 is not null) or
    (p_segment4 is not null) or
    (p_segment5 is not null) or
    (p_segment6 is not null) or
    (p_segment7 is not null) or
    (p_segment8 is not null) or
    (p_segment9 is not null) or
    (p_segment10 is not null) or
    (p_segment11 is not null) or
    (p_segment12 is not null) or
    (p_segment13 is not null) or
    (p_segment14 is not null) or
    (p_segment15 is not null) or
    (p_segment16 is not null) or
    (p_segment17 is not null) or
    (p_segment18 is not null) or
    (p_segment19 is not null) or
    (p_segment20 is not null) THEN
      l_segs_changed := true;
  Else
    l_segs_changed := false;
  End if;
  --
  IF l_segs_changed and p_id_flex_num is null THEN
    hr_utility.set_location(l_proc, 20);
    -- msg French legislations must supply a grade structure with the segments.
    hr_utility.set_message(800, 'PER_52819_STRUCT_WITH_SEGS');
    hr_utility.raise_error;
  End if;
  --
  IF p_id_flex_num is null and l_segs_changed = false  THEN
    null;
    hr_utility.set_location(l_proc, 30);
    -- nothing to do on insert.
  ELSE
    -- id_flex_num is true at this point.
    -- Always call AOL code here, as user may be only changing id_flex_num and
    -- not any segments, so we must ensure this is still validated.
    hr_utility.set_location(l_proc, 40);
     --
       hr_utility.set_location(l_proc, 100);
       hr_kflex_utility.ins_or_sel_keyflex_comb
      (p_appl_short_name        => 'PER',
       p_flex_code              => 'CAGR',
       p_flex_num               => p_id_flex_num,
       p_segment1               => p_segment1,
       p_segment2               => p_segment2,
       p_segment3               => p_segment3,
       p_segment4               => p_segment4,
       p_segment5               => p_segment5,
       p_segment6               => p_segment6,
       p_segment7               => p_segment7,
       p_segment8               => p_segment8,
       p_segment9               => p_segment9,
       p_segment10              => p_segment10,
       p_segment11              => p_segment11,
       p_segment12              => p_segment12,
       p_segment13              => p_segment13,
       p_segment14              => p_segment14,
       p_segment15              => p_segment15,
       p_segment16              => p_segment16,
       p_segment17              => p_segment17,
       p_segment18              => p_segment18,
       p_segment19              => p_segment19,
       p_segment20              => p_segment20,
       p_concat_segments_in     => null,
       p_ccid                   => l_cagr_grade_def_id,
       p_concat_segments_out    => l_concatenated_segments );
       --
       p_cagr_grade_def_id      := l_cagr_grade_def_id;
       p_concatenated_segments  := l_concatenated_segments;
    End if;
  hr_utility.set_location(' Leaving:'||l_proc, 60);
end ins_or_sel;
end hr_cgd_ins;

/
