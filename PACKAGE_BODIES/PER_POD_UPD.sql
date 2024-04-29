--------------------------------------------------------
--  DDL for Package Body PER_POD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POD_UPD" as
/* $Header: pepodrhi.pkb 115.6 2002/12/04 10:56:05 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pod_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure convert_defs(p_rec in out nocopy per_pod_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.id_flex_num = hr_api.g_number) then
    p_rec.id_flex_num :=
    per_pod_shd.g_old_rec.id_flex_num;
  End If;
  If (p_rec.summary_flag = hr_api.g_varchar2) then
    p_rec.summary_flag :=
    per_pod_shd.g_old_rec.summary_flag;
  End If;
  If (p_rec.enabled_flag = hr_api.g_varchar2) then
    p_rec.enabled_flag :=
    per_pod_shd.g_old_rec.enabled_flag;
  End If;
  If (p_rec.start_date_active = hr_api.g_date) then
    p_rec.start_date_active :=
    per_pod_shd.g_old_rec.start_date_active;
  End If;
  If (p_rec.end_date_active = hr_api.g_date) then
    p_rec.end_date_active :=
    per_pod_shd.g_old_rec.end_date_active;
  End If;
  If (p_rec.segment1 = hr_api.g_varchar2) then
    p_rec.segment1 :=
    per_pod_shd.g_old_rec.segment1;
  End If;
  If (p_rec.segment2 = hr_api.g_varchar2) then
    p_rec.segment2 :=
    per_pod_shd.g_old_rec.segment2;
  End If;
  If (p_rec.segment3 = hr_api.g_varchar2) then
    p_rec.segment3 :=
    per_pod_shd.g_old_rec.segment3;
  End If;
  If (p_rec.segment4 = hr_api.g_varchar2) then
    p_rec.segment4 :=
    per_pod_shd.g_old_rec.segment4;
  End If;
  If (p_rec.segment5 = hr_api.g_varchar2) then
    p_rec.segment5 :=
    per_pod_shd.g_old_rec.segment5;
  End If;
  If (p_rec.segment6 = hr_api.g_varchar2) then
    p_rec.segment6 :=
    per_pod_shd.g_old_rec.segment6;
  End If;
  If (p_rec.segment7 = hr_api.g_varchar2) then
    p_rec.segment7 :=
    per_pod_shd.g_old_rec.segment7;
  End If;
  If (p_rec.segment8 = hr_api.g_varchar2) then
    p_rec.segment8 :=
    per_pod_shd.g_old_rec.segment8;
  End If;
  If (p_rec.segment9 = hr_api.g_varchar2) then
    p_rec.segment9 :=
    per_pod_shd.g_old_rec.segment9;
  End If;
  If (p_rec.segment10 = hr_api.g_varchar2) then
    p_rec.segment10 :=
    per_pod_shd.g_old_rec.segment10;
  End If;
  If (p_rec.segment11 = hr_api.g_varchar2) then
    p_rec.segment11 :=
    per_pod_shd.g_old_rec.segment11;
  End If;
  If (p_rec.segment12 = hr_api.g_varchar2) then
    p_rec.segment12 :=
    per_pod_shd.g_old_rec.segment12;
  End If;
  If (p_rec.segment13 = hr_api.g_varchar2) then
    p_rec.segment13 :=
    per_pod_shd.g_old_rec.segment13;
  End If;
  If (p_rec.segment14 = hr_api.g_varchar2) then
    p_rec.segment14 :=
    per_pod_shd.g_old_rec.segment14;
  End If;
  If (p_rec.segment15 = hr_api.g_varchar2) then
    p_rec.segment15 :=
    per_pod_shd.g_old_rec.segment15;
  End If;
  If (p_rec.segment16 = hr_api.g_varchar2) then
    p_rec.segment16 :=
    per_pod_shd.g_old_rec.segment16;
  End If;
  If (p_rec.segment17 = hr_api.g_varchar2) then
    p_rec.segment17 :=
    per_pod_shd.g_old_rec.segment17;
  End If;
  If (p_rec.segment18 = hr_api.g_varchar2) then
    p_rec.segment18 :=
    per_pod_shd.g_old_rec.segment18;
  End If;
  If (p_rec.segment19 = hr_api.g_varchar2) then
    p_rec.segment19 :=
    per_pod_shd.g_old_rec.segment19;
  End If;
  If (p_rec.segment20 = hr_api.g_varchar2) then
    p_rec.segment20 :=
    per_pod_shd.g_old_rec.segment20;
  End If;
  If (p_rec.segment21 = hr_api.g_varchar2) then
    p_rec.segment21 :=
    per_pod_shd.g_old_rec.segment21;
  End If;
  If (p_rec.segment22 = hr_api.g_varchar2) then
    p_rec.segment22 :=
    per_pod_shd.g_old_rec.segment22;
  End If;
  If (p_rec.segment23 = hr_api.g_varchar2) then
    p_rec.segment23 :=
    per_pod_shd.g_old_rec.segment23;
  End If;
  If (p_rec.segment24 = hr_api.g_varchar2) then
    p_rec.segment24 :=
    per_pod_shd.g_old_rec.segment24;
  End If;
  If (p_rec.segment25 = hr_api.g_varchar2) then
    p_rec.segment25 :=
    per_pod_shd.g_old_rec.segment25;
  End If;
  If (p_rec.segment26 = hr_api.g_varchar2) then
    p_rec.segment26 :=
    per_pod_shd.g_old_rec.segment26;
  End If;
  If (p_rec.segment27 = hr_api.g_varchar2) then
    p_rec.segment27 :=
    per_pod_shd.g_old_rec.segment27;
  End If;
  If (p_rec.segment28 = hr_api.g_varchar2) then
    p_rec.segment28 :=
    per_pod_shd.g_old_rec.segment28;
  End If;
  If (p_rec.segment29 = hr_api.g_varchar2) then
    p_rec.segment29 :=
    per_pod_shd.g_old_rec.segment29;
  End If;
  If (p_rec.segment30 = hr_api.g_varchar2) then
    p_rec.segment30 :=
    per_pod_shd.g_old_rec.segment30;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< upd_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure upd_or_sel
         (p_segment1               in     varchar2 default hr_api.g_varchar2,
          p_segment2               in     varchar2 default hr_api.g_varchar2,
          p_segment3               in     varchar2 default hr_api.g_varchar2,
          p_segment4               in     varchar2 default hr_api.g_varchar2,
          p_segment5               in     varchar2 default hr_api.g_varchar2,
          p_segment6               in     varchar2 default hr_api.g_varchar2,
          p_segment7               in     varchar2 default hr_api.g_varchar2,
          p_segment8               in     varchar2 default hr_api.g_varchar2,
          p_segment9               in     varchar2 default hr_api.g_varchar2,
          p_segment10              in     varchar2 default hr_api.g_varchar2,
          p_segment11              in     varchar2 default hr_api.g_varchar2,
          p_segment12              in     varchar2 default hr_api.g_varchar2,
          p_segment13              in     varchar2 default hr_api.g_varchar2,
          p_segment14              in     varchar2 default hr_api.g_varchar2,
          p_segment15              in     varchar2 default hr_api.g_varchar2,
          p_segment16              in     varchar2 default hr_api.g_varchar2,
          p_segment17              in     varchar2 default hr_api.g_varchar2,
          p_segment18              in     varchar2 default hr_api.g_varchar2,
          p_segment19              in     varchar2 default hr_api.g_varchar2,
          p_segment20              in     varchar2 default hr_api.g_varchar2,
          p_segment21              in     varchar2 default hr_api.g_varchar2,
          p_segment22              in     varchar2 default hr_api.g_varchar2,
          p_segment23              in     varchar2 default hr_api.g_varchar2,
          p_segment24              in     varchar2 default hr_api.g_varchar2,
          p_segment25              in     varchar2 default hr_api.g_varchar2,
          p_segment26              in     varchar2 default hr_api.g_varchar2,
          p_segment27              in     varchar2 default hr_api.g_varchar2,
          p_segment28              in     varchar2 default hr_api.g_varchar2,
          p_segment29              in     varchar2 default hr_api.g_varchar2,
          p_segment30              in     varchar2 default hr_api.g_varchar2,
          p_business_group_id      in     number,
          p_position_definition_id in out nocopy number,
          p_name                      out nocopy varchar2,
          p_validate               in     boolean default false) is
--
  l_proc          varchar2(72) := g_package||'upd_or_sel';
  l_rec           per_pod_shd.g_rec_type;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- convert args into record format
  --
  l_rec :=
    per_pod_shd.convert_args
      (p_position_definition_id,
       null,
       null,
       null,
       null,
       null,
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
  --
  -- check to see if we are updating a row
  --
  if per_pod_shd.api_updating
       (p_position_definition_id => l_rec.position_definition_id) then
    --
    hr_utility.set_location(l_proc, 10);
    --
    -- the current row exists and we have populated the g_old_rec
    -- we must now build up the new record by converting the
    -- arguments into a record structure and converting any of the
    -- system default values
    --
    per_pod_upd.convert_defs(p_rec => l_rec);
  else
    --
    -- as we are actually doing an insert we need to reset the
    -- arguments if they are using a system default value
    -- to null otherwise the segments will have the system default
    -- values when being inserted
    --
    if (l_rec.segment1 = hr_api.g_varchar2) then
      l_rec.segment1 := null;
    end if;
    if (l_rec.segment2 = hr_api.g_varchar2) then
      l_rec.segment2 := null;
    end if;
    if (l_rec.segment3 = hr_api.g_varchar2) then
      l_rec.segment3 := null;
    end if;
    if (l_rec.segment4 = hr_api.g_varchar2) then
      l_rec.segment4 := null;
    end if;
    if (l_rec.segment5 = hr_api.g_varchar2) then
      l_rec.segment5 := null;
    end if;
    if (l_rec.segment6 = hr_api.g_varchar2) then
      l_rec.segment6 := null;
    end if;
    if (l_rec.segment7 = hr_api.g_varchar2) then
      l_rec.segment7 := null;
    end if;
    if (l_rec.segment8 = hr_api.g_varchar2) then
      l_rec.segment8 := null;
    end if;
    if (l_rec.segment9 = hr_api.g_varchar2) then
      l_rec.segment9 := null;
    end if;
    if (l_rec.segment10 = hr_api.g_varchar2) then
      l_rec.segment10 := null;
    end if;
    if (l_rec.segment11 = hr_api.g_varchar2) then
      l_rec.segment11 := null;
    end if;
    if (l_rec.segment12 = hr_api.g_varchar2) then
      l_rec.segment12 := null;
    end if;
    if (l_rec.segment13 = hr_api.g_varchar2) then
      l_rec.segment13 := null;
    end if;
    if (l_rec.segment14 = hr_api.g_varchar2) then
      l_rec.segment14 := null;
    end if;
    if (l_rec.segment15 = hr_api.g_varchar2) then
      l_rec.segment15 := null;
    end if;
    if (l_rec.segment16 = hr_api.g_varchar2) then
      l_rec.segment16 := null;
    end if;
    if (l_rec.segment17 = hr_api.g_varchar2) then
      l_rec.segment17 := null;
    end if;
    if (l_rec.segment18 = hr_api.g_varchar2) then
      l_rec.segment18 := null;
    end if;
    if (l_rec.segment19 = hr_api.g_varchar2) then
      l_rec.segment19 := null;
    end if;
    if (l_rec.segment20 = hr_api.g_varchar2) then
      l_rec.segment20 := null;
    end if;
    if (l_rec.segment21 = hr_api.g_varchar2) then
      l_rec.segment21 := null;
    end if;
    if (l_rec.segment22 = hr_api.g_varchar2) then
      l_rec.segment22 := null;
    end if;
    if (l_rec.segment23 = hr_api.g_varchar2) then
      l_rec.segment23 := null;
    end if;
    if (l_rec.segment24 = hr_api.g_varchar2) then
      l_rec.segment24 := null;
    end if;
    if (l_rec.segment25 = hr_api.g_varchar2) then
      l_rec.segment25 := null;
    end if;
    if (l_rec.segment26 = hr_api.g_varchar2) then
      l_rec.segment26 := null;
    end if;
    if (l_rec.segment27 = hr_api.g_varchar2) then
      l_rec.segment27 := null;
    end if;
    if (l_rec.segment28 = hr_api.g_varchar2) then
      l_rec.segment28 := null;
    end if;
    if (l_rec.segment29 = hr_api.g_varchar2) then
      l_rec.segment29 := null;
    end if;
    if (l_rec.segment30 = hr_api.g_varchar2) then
      l_rec.segment30 := null;
    end if;
  end if;
  hr_utility.set_location(l_proc, 15);
  --
  -- call the ins_or_sel process
  --
  per_pod_ins.ins_or_sel
    (p_segment1              => l_rec.segment1,
     p_segment2              => l_rec.segment2,
     p_segment3              => l_rec.segment3,
     p_segment4              => l_rec.segment4,
     p_segment5              => l_rec.segment5,
     p_segment6              => l_rec.segment6,
     p_segment7              => l_rec.segment7,
     p_segment8              => l_rec.segment8,
     p_segment9              => l_rec.segment9,
     p_segment10             => l_rec.segment10,
     p_segment11             => l_rec.segment11,
     p_segment12             => l_rec.segment12,
     p_segment13             => l_rec.segment13,
     p_segment14             => l_rec.segment14,
     p_segment15             => l_rec.segment15,
     p_segment16             => l_rec.segment16,
     p_segment17             => l_rec.segment17,
     p_segment18             => l_rec.segment18,
     p_segment19             => l_rec.segment19,
     p_segment20             => l_rec.segment20,
     p_segment21             => l_rec.segment21,
     p_segment22             => l_rec.segment22,
     p_segment23             => l_rec.segment23,
     p_segment24             => l_rec.segment24,
     p_segment25             => l_rec.segment25,
     p_segment26             => l_rec.segment26,
     p_segment27             => l_rec.segment27,
     p_segment28             => l_rec.segment28,
     p_segment29             => l_rec.segment29,
     p_segment30             => l_rec.segment30,
     p_business_group_id     => p_business_group_id,
     p_position_definition_id => l_rec.position_definition_id,
     p_name                  => p_name,
     p_validate              => p_validate);
  --
  -- set the out argument
  --
  p_position_definition_id := l_rec.position_definition_id;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
end upd_or_sel;
--
end per_pod_upd;

/
