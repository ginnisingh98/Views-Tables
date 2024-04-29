--------------------------------------------------------
--  DDL for Package HR_ICX_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ICX_RKU" AUTHID CURRENT_USER as
/* $Header: hricxrhi.pkh 120.0 2005/05/31 00:51:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_object_version_number        in number
  ,p_item_context_id              in number
  ,p_id_flex_num                  in number
  ,p_summary_flag                 in varchar2
  ,p_enabled_flag                 in varchar2
  ,p_start_date_active            in date
  ,p_end_date_active              in date
  ,p_segment1                     in varchar2
  ,p_segment2                     in varchar2
  ,p_segment3                     in varchar2
  ,p_segment4                     in varchar2
  ,p_segment5                     in varchar2
  ,p_segment6                     in varchar2
  ,p_segment7                     in varchar2
  ,p_segment8                     in varchar2
  ,p_segment9                     in varchar2
  ,p_segment10                    in varchar2
  ,p_segment11                    in varchar2
  ,p_segment12                    in varchar2
  ,p_segment13                    in varchar2
  ,p_segment14                    in varchar2
  ,p_segment15                    in varchar2
  ,p_segment16                    in varchar2
  ,p_segment17                    in varchar2
  ,p_segment18                    in varchar2
  ,p_segment19                    in varchar2
  ,p_segment20                    in varchar2
  ,p_segment21                    in varchar2
  ,p_segment22                    in varchar2
  ,p_segment23                    in varchar2
  ,p_segment24                    in varchar2
  ,p_segment25                    in varchar2
  ,p_segment26                    in varchar2
  ,p_segment27                    in varchar2
  ,p_segment28                    in varchar2
  ,p_segment29                    in varchar2
  ,p_segment30                    in varchar2
  ,p_object_version_number_o      in number
  ,p_id_flex_num_o                in number
  ,p_summary_flag_o               in varchar2
  ,p_enabled_flag_o               in varchar2
  ,p_start_date_active_o          in date
  ,p_end_date_active_o            in date
  ,p_segment1_o                   in varchar2
  ,p_segment2_o                   in varchar2
  ,p_segment3_o                   in varchar2
  ,p_segment4_o                   in varchar2
  ,p_segment5_o                   in varchar2
  ,p_segment6_o                   in varchar2
  ,p_segment7_o                   in varchar2
  ,p_segment8_o                   in varchar2
  ,p_segment9_o                   in varchar2
  ,p_segment10_o                  in varchar2
  ,p_segment11_o                  in varchar2
  ,p_segment12_o                  in varchar2
  ,p_segment13_o                  in varchar2
  ,p_segment14_o                  in varchar2
  ,p_segment15_o                  in varchar2
  ,p_segment16_o                  in varchar2
  ,p_segment17_o                  in varchar2
  ,p_segment18_o                  in varchar2
  ,p_segment19_o                  in varchar2
  ,p_segment20_o                  in varchar2
  ,p_segment21_o                  in varchar2
  ,p_segment22_o                  in varchar2
  ,p_segment23_o                  in varchar2
  ,p_segment24_o                  in varchar2
  ,p_segment25_o                  in varchar2
  ,p_segment26_o                  in varchar2
  ,p_segment27_o                  in varchar2
  ,p_segment28_o                  in varchar2
  ,p_segment29_o                  in varchar2
  ,p_segment30_o                  in varchar2
  );
--
end hr_icx_rku;

 

/
