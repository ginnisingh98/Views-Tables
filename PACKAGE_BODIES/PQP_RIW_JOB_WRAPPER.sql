--------------------------------------------------------
--  DDL for Package Body PQP_RIW_JOB_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_RIW_JOB_WRAPPER" as
/* $Header: pqpriwjbwr.pkb 120.0.12010000.3 2009/08/20 10:40:19 psengupt noship $ */
-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
g_package  varchar2(33) := 'PQP_RIW_JOB_WRAPPER';
g_interface_code              varchar2(150);

type job_record is record
(
business_group_id                 number(15)
,date_from                         date
,comments                          long
,date_to                           date
,approval_authority                number(38)
,benchmark_job_flag                varchar2(30)
,benchmark_job_id                  number(15)
,emp_rights_flag                   varchar2(30)
,job_group_id                      number(15)
,attribute_category                varchar2(30)
,attribute1                        varchar2(150)
,attribute2                        varchar2(150)
,attribute3                        varchar2(150)
,attribute4                        varchar2(150)
,attribute5                        varchar2(150)
,attribute6                        varchar2(150)
,attribute7                        varchar2(150)
,attribute8                        varchar2(150)
,attribute9                        varchar2(150)
,attribute10                       varchar2(150)
,attribute11                       varchar2(150)
,attribute12                       varchar2(150)
,attribute13                       varchar2(150)
,attribute14                       varchar2(150)
,attribute15                       varchar2(150)
,attribute16                       varchar2(150)
,attribute17                       varchar2(150)
,attribute18                       varchar2(150)
,attribute19                       varchar2(150)
,attribute20                       varchar2(150)
,job_information_category          varchar2(30)
,job_information1                  varchar2(150)
,job_information2                  varchar2(150)
,job_information3                  varchar2(150)
,job_information4                  varchar2(150)
,job_information5                  varchar2(150)
,job_information6                  varchar2(150)
,job_information7                  varchar2(150)
,job_information8                  varchar2(150)
,job_information9                  varchar2(150)
,job_information10                 varchar2(150)
,job_information11                 varchar2(150)
,job_information12                 varchar2(150)
,job_information13                 varchar2(150)
,job_information14                 varchar2(150)
,job_information15                 varchar2(150)
,job_information16                 varchar2(150)
,job_information17                 varchar2(150)
,job_information18                 varchar2(150)
,job_information19                 varchar2(150)
,job_information20                 varchar2(150)
,segment1                          varchar2(60)
,segment2                          varchar2(60)
,segment3                          varchar2(60)
,segment4                          varchar2(60)
,segment5                          varchar2(60)
,segment6                          varchar2(60)
,segment7                          varchar2(60)
,segment8                          varchar2(60)
,segment9                          varchar2(60)
,segment10                         varchar2(60)
,segment11                         varchar2(60)
,segment12                         varchar2(60)
,segment13                         varchar2(60)
,segment14                         varchar2(60)
,segment15                         varchar2(60)
,segment16                         varchar2(60)
,segment17                         varchar2(60)
,segment18                         varchar2(60)
,segment19                         varchar2(60)
,segment20                         varchar2(60)
,segment21                         varchar2(60)
,segment22                         varchar2(60)
,segment23                         varchar2(60)
,segment24                         varchar2(60)
,segment25                         varchar2(60)
,segment26                         varchar2(60)
,segment27                         varchar2(60)
,segment28                         varchar2(60)
,segment29                         varchar2(60)
,segment30                         varchar2(60)
,concat_segments                   varchar2(60)
,language_code                     varchar2(10)
,job_id                            number(15)
,job_definition_id                 number(15));


g_job_rec job_record;

-- =============================================================================
-- Default_Record_Values:
-- =============================================================================

function get_default_job_rec
return job_record is
  l_proc_name    constant varchar2(150) := g_package||'get_default_job_rec';
  l_job_rec     job_record;
begin
  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
  /*
   ==========================================================================
   g_varchar2  constant varchar2(9) := '$Sys_Def$';
   g_number  constant number        := -987123654;
   g_date  constant date            := to_date('01-01-4712', 'DD-MM-SYYYY');
   ==========================================================================
  */
l_job_rec.business_group_id             :=  hr_api.g_number;
l_job_rec.date_from                     :=  hr_api.g_date;
l_job_rec.comments                      :=  hr_api.g_varchar2;
l_job_rec.date_to                       :=  hr_api.g_date;
l_job_rec.approval_authority            :=  hr_api.g_number;
l_job_rec.benchmark_job_flag            :=  hr_api.g_varchar2;
l_job_rec.benchmark_job_id              :=  hr_api.g_number;
l_job_rec.emp_rights_flag               :=  hr_api.g_varchar2;
l_job_rec.job_group_id                  :=  hr_api.g_number;
l_job_rec.attribute_category            :=  hr_api.g_varchar2;
l_job_rec.attribute1                    :=  hr_api.g_varchar2;
l_job_rec.attribute2                    :=  hr_api.g_varchar2;
l_job_rec.attribute3                    :=  hr_api.g_varchar2;
l_job_rec.attribute4                    :=  hr_api.g_varchar2;
l_job_rec.attribute5                    :=  hr_api.g_varchar2;
l_job_rec.attribute6                    :=  hr_api.g_varchar2;
l_job_rec.attribute7                    :=  hr_api.g_varchar2;
l_job_rec.attribute8                    :=  hr_api.g_varchar2;
l_job_rec.attribute9                    :=  hr_api.g_varchar2;
l_job_rec.attribute10                   :=  hr_api.g_varchar2;
l_job_rec.attribute11                   :=  hr_api.g_varchar2;
l_job_rec.attribute12                   :=  hr_api.g_varchar2;
l_job_rec.attribute13                   :=  hr_api.g_varchar2;
l_job_rec.attribute14                   :=  hr_api.g_varchar2;
l_job_rec.attribute15                   :=  hr_api.g_varchar2;
l_job_rec.attribute16                   :=  hr_api.g_varchar2;
l_job_rec.attribute17                   :=  hr_api.g_varchar2;
l_job_rec.attribute18                   :=  hr_api.g_varchar2;
l_job_rec.attribute19                   :=  hr_api.g_varchar2;
l_job_rec.attribute20                   :=  hr_api.g_varchar2;
l_job_rec.job_information_category      :=  hr_api.g_varchar2;
l_job_rec.job_information1              :=  hr_api.g_varchar2;
l_job_rec.job_information2              :=  hr_api.g_varchar2;
l_job_rec.job_information3              :=  hr_api.g_varchar2;
l_job_rec.job_information4              :=  hr_api.g_varchar2;
l_job_rec.job_information5              :=  hr_api.g_varchar2;
l_job_rec.job_information6              :=  hr_api.g_varchar2;
l_job_rec.job_information7              :=  hr_api.g_varchar2;
l_job_rec.job_information8              :=  hr_api.g_varchar2;
l_job_rec.job_information9              :=  hr_api.g_varchar2;
l_job_rec.job_information10             :=  hr_api.g_varchar2;
l_job_rec.job_information11             :=  hr_api.g_varchar2;
l_job_rec.job_information12             :=  hr_api.g_varchar2;
l_job_rec.job_information13             :=  hr_api.g_varchar2;
l_job_rec.job_information14             :=  hr_api.g_varchar2;
l_job_rec.job_information15             :=  hr_api.g_varchar2;
l_job_rec.job_information16             :=  hr_api.g_varchar2;
l_job_rec.job_information17             :=  hr_api.g_varchar2;
l_job_rec.job_information18             :=  hr_api.g_varchar2;
l_job_rec.job_information19             :=  hr_api.g_varchar2;
l_job_rec.job_information20             :=  hr_api.g_varchar2;
l_job_rec.segment1              := hr_api.g_varchar2;
l_job_rec.segment2              := hr_api.g_varchar2;
l_job_rec.segment3              := hr_api.g_varchar2;
l_job_rec.segment4              := hr_api.g_varchar2;
l_job_rec.segment5              := hr_api.g_varchar2;
l_job_rec.segment6              := hr_api.g_varchar2;
l_job_rec.segment7              := hr_api.g_varchar2;
l_job_rec.segment8              := hr_api.g_varchar2;
l_job_rec.segment9              := hr_api.g_varchar2;
l_job_rec.segment10             := hr_api.g_varchar2;
l_job_rec.segment11             := hr_api.g_varchar2;
l_job_rec.segment12             := hr_api.g_varchar2;
l_job_rec.segment13             := hr_api.g_varchar2;
l_job_rec.segment14             := hr_api.g_varchar2;
l_job_rec.segment15             := hr_api.g_varchar2;
l_job_rec.segment16             := hr_api.g_varchar2;
l_job_rec.segment17             := hr_api.g_varchar2;
l_job_rec.segment18             := hr_api.g_varchar2;
l_job_rec.segment19             := hr_api.g_varchar2;
l_job_rec.segment20             := hr_api.g_varchar2;
l_job_rec.segment21             := hr_api.g_varchar2;
l_job_rec.segment22             := hr_api.g_varchar2;
l_job_rec.segment23             := hr_api.g_varchar2;
l_job_rec.segment24             := hr_api.g_varchar2;
l_job_rec.segment25             := hr_api.g_varchar2;
l_job_rec.segment26             := hr_api.g_varchar2;
l_job_rec.segment27             := hr_api.g_varchar2;
l_job_rec.segment28             := hr_api.g_varchar2;
l_job_rec.segment29             := hr_api.g_varchar2;
l_job_rec.segment30             := hr_api.g_varchar2;
l_job_rec.concat_segments       := hr_api.g_varchar2;
l_job_rec.job_id                :=  hr_api.g_number;
l_job_rec.job_definition_id     :=  hr_api.g_number;

return l_job_rec;

exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;
end get_default_job_rec;


-- =============================================================================
-- Get_Record_Values:
-- =============================================================================
function Get_Job_Record_Values
        (p_interface_code in varchar2 default null)
         return job_record is

  cursor bne_cols(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='Y';

  -- To query cols which are not displayed (DFF segments)
   cursor bne_cols_no_disp(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='N';

  l_job_rec            job_record;
  col_name             varchar2(150);
  l_proc_name constant varchar2(150) := g_package||'.Get_Job_Record_Values';
begin
  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
  l_job_rec := get_default_job_rec;
  for col_rec in bne_cols (g_interface_code)
  loop
  hr_utility.set_location(' col_rec.interface_col_name : ' || col_rec.interface_col_name, 15);
   case col_rec.interface_col_name

    when 'p_business_group_id' then
          l_job_rec.business_group_id := g_job_rec.business_group_id;
    when 'p_date_from' then
          l_job_rec.date_from := g_job_rec.date_from;
    when 'p_comments' then
          l_job_rec.comments := g_job_rec.comments;
    when 'p_date_to' then
          l_job_rec.date_to := g_job_rec.date_to;
    when 'p_approval_authority' then
          l_job_rec.approval_authority := g_job_rec.approval_authority;
    when 'p_benchmark_job_flag' then
          l_job_rec.benchmark_job_flag := g_job_rec.benchmark_job_flag;
    when 'p_benchmark_job_id' then
          l_job_rec.benchmark_job_id := g_job_rec.benchmark_job_id;
    when 'p_emp_rights_flag' then
          l_job_rec.emp_rights_flag := g_job_rec.emp_rights_flag;
    when 'p_job_group_id' then
          l_job_rec.job_group_id := g_job_rec.job_group_id;
    when 'p_attribute_category' then
          l_job_rec.attribute_category := g_job_rec.attribute_category;

         if l_job_rec.attribute_category is not null then
          for col_rec1 in bne_cols_no_disp(g_interface_code) loop

             case col_rec1.interface_col_name
    when 'p_attribute1' then
          l_job_rec.attribute1 := g_job_rec.attribute1;
    when 'p_attribute2' then
          l_job_rec.attribute2 := g_job_rec.attribute2;
    when 'p_attribute3' then
          l_job_rec.attribute3 := g_job_rec.attribute3;
    when 'p_attribute4' then
          l_job_rec.attribute4 := g_job_rec.attribute4;
    when 'p_attribute5' then
          l_job_rec.attribute5 := g_job_rec.attribute5;
    when 'p_attribute6' then
          l_job_rec.attribute6 := g_job_rec.attribute6;
    when 'p_attribute7' then
          l_job_rec.attribute7 := g_job_rec.attribute7;
    when 'p_attribute8' then
          l_job_rec.attribute8 := g_job_rec.attribute8;
    when 'p_attribute9' then
          l_job_rec.attribute9 := g_job_rec.attribute9;
    when 'p_attribute10' then
          l_job_rec.attribute10 := g_job_rec.attribute10;
    when 'p_attribute1' then
          l_job_rec.attribute11 := g_job_rec.attribute11;
    when 'p_attribute12' then
          l_job_rec.attribute12 := g_job_rec.attribute12;
    when 'p_attribute13' then
          l_job_rec.attribute13 := g_job_rec.attribute13;
    when 'p_attribute14' then
          l_job_rec.attribute14 := g_job_rec.attribute14;
    when 'p_attribute15' then
          l_job_rec.attribute15 := g_job_rec.attribute15;
    when 'p_attribute16' then
          l_job_rec.attribute16 := g_job_rec.attribute16;
    when 'p_attribute17' then
          l_job_rec.attribute17 := g_job_rec.attribute17;
    when 'p_attribute18' then
          l_job_rec.attribute18 := g_job_rec.attribute18;
    when 'p_attribute19' then
          l_job_rec.attribute19 := g_job_rec.attribute19;
    when 'p_attribute20' then
          l_job_rec.attribute20 := g_job_rec.attribute20;
    else
          null;
    end case;
          end loop;
          end if;


    when 'job_information_category' then
          l_job_rec.job_information_category := g_job_rec.job_information_category;

         if l_job_rec.job_information_category is not null then
          for col_rec1 in bne_cols_no_disp(g_interface_code) loop

             case col_rec1.interface_col_name

    when 'job_information1' then
          l_job_rec.job_information1 := g_job_rec.job_information1;
    when 'job_information2' then
          l_job_rec.job_information2 := g_job_rec.job_information2;
    when 'job_information3' then
          l_job_rec.job_information3 := g_job_rec.job_information3;
    when 'job_information4' then
          l_job_rec.job_information4 := g_job_rec.job_information4;
    when 'job_information5' then
          l_job_rec.job_information5 := g_job_rec.job_information5;
    when 'job_information6' then
          l_job_rec.job_information6 := g_job_rec.job_information6;
    when 'job_information7' then
          l_job_rec.job_information7 := g_job_rec.job_information7;
    when 'job_information8' then
          l_job_rec.job_information8 := g_job_rec.job_information8;
    when 'job_information9' then
          l_job_rec.job_information9 := g_job_rec.job_information9;
    when 'job_information10' then
          l_job_rec.job_information10 := g_job_rec.job_information10;
    when 'job_information11' then
          l_job_rec.job_information11 := g_job_rec.job_information11;
    when 'job_information12' then
          l_job_rec.job_information12 := g_job_rec.job_information12;
    when 'job_information13' then
          l_job_rec.job_information13 := g_job_rec.job_information13;
    when 'job_information14' then
          l_job_rec.job_information14 := g_job_rec.job_information14;
    when 'job_information15' then
          l_job_rec.job_information15 := g_job_rec.job_information15;
    when 'job_information16' then
          l_job_rec.job_information16 := g_job_rec.job_information16;
    when 'job_information17' then
          l_job_rec.job_information17 := g_job_rec.job_information17;
    when 'job_information18' then
          l_job_rec.job_information18 := g_job_rec.job_information18;
    when 'job_information19' then
          l_job_rec.job_information19 := g_job_rec.job_information19;
    when 'job_information20' then
          l_job_rec.job_information20 := g_job_rec.job_information20;
    else
          null;

          end case;

        end loop;
      end if;

    when 'p_concat_segments' then
          l_job_rec.concat_segments := g_job_rec.concat_segments;

   for col_rec1 in bne_cols_no_disp(g_interface_code) loop
   case col_rec1.interface_col_name

    when 'segment1' then
          l_job_rec.segment1 := g_job_rec.segment1;
    when 'segment2' then
          l_job_rec.segment2 := g_job_rec.segment2;
    when 'segment3' then
          l_job_rec.segment3 := g_job_rec.segment3;
    when 'segment4' then
          l_job_rec.segment4 := g_job_rec.segment4;
    when 'segment5' then
          l_job_rec.segment5 := g_job_rec.segment5;
    when 'segment6' then
          l_job_rec.segment6 := g_job_rec.segment6;
    when 'segment7' then
          l_job_rec.segment7 := g_job_rec.segment7;
    when 'segment8' then
          l_job_rec.segment8 := g_job_rec.segment8;
    when 'segment9' then
          l_job_rec.segment9 := g_job_rec.segment9;
    when 'segment10' then
          l_job_rec.segment10 := g_job_rec.segment10;
    when 'segment11' then
          l_job_rec.segment11 := g_job_rec.segment11;
    when 'segment12' then
          l_job_rec.segment12 := g_job_rec.segment12;
    when 'segment13' then
          l_job_rec.segment13 := g_job_rec.segment13;
    when 'segment14' then
          l_job_rec.segment14 := g_job_rec.segment14;
    when 'segment15' then
          l_job_rec.segment15 := g_job_rec.segment15;
    when 'segment16' then
          l_job_rec.segment16 := g_job_rec.segment16;
    when 'segment17' then
          l_job_rec.segment17 := g_job_rec.segment17;
    when 'segment18' then
          l_job_rec.segment18 := g_job_rec.segment18;
    when 'segment19' then
          l_job_rec.segment19 := g_job_rec.segment19;
    when 'segment20' then
          l_job_rec.segment20 := g_job_rec.segment20;
    when 'segment21' then
          l_job_rec.segment21 := g_job_rec.segment21;
    when 'segment22' then
          l_job_rec.segment22 := g_job_rec.segment22;
    when 'segment23' then
          l_job_rec.segment23 := g_job_rec.segment23;
    when 'segment24' then
          l_job_rec.segment24 := g_job_rec.segment24;
    when 'segment25' then
          l_job_rec.segment25 := g_job_rec.segment25;
    when 'segment26' then
          l_job_rec.segment26 := g_job_rec.segment26;
    when 'segment27' then
          l_job_rec.segment27 := g_job_rec.segment27;
    when 'segment28' then
          l_job_rec.segment28 := g_job_rec.segment28;
    when 'segment29' then
          l_job_rec.segment29 := g_job_rec.segment29;
    when 'segment30' then
          l_job_rec.segment30 := g_job_rec.segment30;
    else
          null;

          end case;

        end loop;

    when 'p_job_id' then
          l_job_rec.job_id := g_job_rec.job_id;
    when 'p_job_definition_id' then
          l_job_rec.job_definition_id := g_job_rec.job_definition_id;
    else
          null;
    end case;
  end loop;

  Hr_Utility.set_location(' Leaving: '||l_proc_name, 20);
  return l_job_rec;
end Get_Job_Record_Values;

procedure Set_Current_Job_record_Values
    (p_business_group_id             in     number
    ,p_date_from                     in     date
    ,p_comments                      in     varchar2
    ,p_date_to                       in     date
    ,p_approval_authority            in     number
    ,p_benchmark_job_flag            in     varchar2
    ,p_benchmark_job_id              in     number
    ,p_emp_rights_flag               in     varchar2
    ,p_job_group_id                  in     number
    ,p_attribute_category            in     varchar2
    ,p_attribute1                    in     varchar2
    ,p_attribute2                    in     varchar2
    ,p_attribute3                    in     varchar2
    ,p_attribute4                    in     varchar2
    ,p_attribute5                    in     varchar2
    ,p_attribute6                    in     varchar2
    ,p_attribute7                    in     varchar2
    ,p_attribute8                    in     varchar2
    ,p_attribute9                    in     varchar2
    ,p_attribute10                   in     varchar2
    ,p_attribute11                   in     varchar2
    ,p_attribute12                   in     varchar2
    ,p_attribute13                   in     varchar2
    ,p_attribute14                   in     varchar2
    ,p_attribute15                   in     varchar2
    ,p_attribute16                   in     varchar2
    ,p_attribute17                   in     varchar2
    ,p_attribute18                   in     varchar2
    ,p_attribute19                   in     varchar2
    ,p_attribute20                   in     varchar2
    ,p_job_information_category      in     varchar2
    ,p_job_information1              in     varchar2
    ,p_job_information2              in     varchar2
    ,p_job_information3              in     varchar2
    ,p_job_information4              in     varchar2
    ,p_job_information5              in     varchar2
    ,p_job_information6              in     varchar2
    ,p_job_information7              in     varchar2
    ,p_job_information8              in     varchar2
    ,p_job_information9              in     varchar2
    ,p_job_information10             in     varchar2
    ,p_job_information11             in     varchar2
    ,p_job_information12             in     varchar2
    ,p_job_information13             in     varchar2
    ,p_job_information14             in     varchar2
    ,p_job_information15             in     varchar2
    ,p_job_information16             in     varchar2
    ,p_job_information17             in     varchar2
    ,p_job_information18             in     varchar2
    ,p_job_information19             in     varchar2
    ,p_job_information20             in     varchar2
    ,p_segment1                      in     varchar2
    ,p_segment2                      in     varchar2
    ,p_segment3                      in     varchar2
    ,p_segment4                      in     varchar2
    ,p_segment5                      in     varchar2
    ,p_segment6                      in     varchar2
    ,p_segment7                      in     varchar2
    ,p_segment8                      in     varchar2
    ,p_segment9                      in     varchar2
    ,p_segment10                     in     varchar2
    ,p_segment11                     in     varchar2
    ,p_segment12                     in     varchar2
    ,p_segment13                     in     varchar2
    ,p_segment14                     in     varchar2
    ,p_segment15                     in     varchar2
    ,p_segment16                     in     varchar2
    ,p_segment17                     in     varchar2
    ,p_segment18                     in     varchar2
    ,p_segment19                     in     varchar2
    ,p_segment20                     in     varchar2
    ,p_segment21                     in     varchar2
    ,p_segment22                     in     varchar2
    ,p_segment23                     in     varchar2
    ,p_segment24                     in     varchar2
    ,p_segment25                     in     varchar2
    ,p_segment26                     in     varchar2
    ,p_segment27                     in     varchar2
    ,p_segment28                     in     varchar2
    ,p_segment29                     in     varchar2
    ,p_segment30                     in     varchar2
    ,p_concat_segments               in     varchar2
    ,p_language_code                 in     varchar2
    ,p_job_id                        in     number
    ,p_job_definition_id             in     number
    ,p_interface_code                in     varchar2
    ) is
begin
hr_utility.trace('job id set in set current is : ' || p_job_id);
g_interface_code := nvl(p_interface_code,'PQP_RIW_JOB_INTF');
g_job_rec.business_group_id             := p_business_group_id;
g_job_rec.date_from                     := p_date_from;
g_job_rec.comments                      := p_comments;
g_job_rec.date_to                       := p_date_to;
g_job_rec.approval_authority            := p_approval_authority;
g_job_rec.benchmark_job_flag            := p_benchmark_job_flag;
g_job_rec.benchmark_job_id              := p_benchmark_job_id;
g_job_rec.emp_rights_flag               := p_emp_rights_flag;
g_job_rec.job_group_id                  := p_job_group_id;
g_job_rec.attribute_category            := p_attribute_category;
g_job_rec.attribute1                    := p_attribute1;
g_job_rec.attribute2                    := p_attribute2;
g_job_rec.attribute3                    := p_attribute3;
g_job_rec.attribute4                    := p_attribute4;
g_job_rec.attribute5                    := p_attribute5;
g_job_rec.attribute6                    := p_attribute6;
g_job_rec.attribute7                    := p_attribute7;
g_job_rec.attribute8                    := p_attribute8;
g_job_rec.attribute9                    := p_attribute9;
g_job_rec.attribute10                   := p_attribute10;
g_job_rec.attribute11                   := p_attribute11;
g_job_rec.attribute12                   := p_attribute12;
g_job_rec.attribute13                   := p_attribute13;
g_job_rec.attribute14                   := p_attribute14;
g_job_rec.attribute15                   := p_attribute15;
g_job_rec.attribute16                   := p_attribute16;
g_job_rec.attribute17                   := p_attribute17;
g_job_rec.attribute18                   := p_attribute18;
g_job_rec.attribute19                   := p_attribute19;
g_job_rec.attribute20                   := p_attribute20;
g_job_rec.job_information_category      := p_job_information_category;
g_job_rec.job_information1              := p_job_information1;
g_job_rec.job_information2              := p_job_information2;
g_job_rec.job_information3              := p_job_information3;
g_job_rec.job_information4              := p_job_information4;
g_job_rec.job_information5              := p_job_information5;
g_job_rec.job_information6              := p_job_information6;
g_job_rec.job_information7              := p_job_information7;
g_job_rec.job_information8              := p_job_information8;
g_job_rec.job_information9              := p_job_information9;
g_job_rec.job_information10             := p_job_information10;
g_job_rec.job_information11             := p_job_information11;
g_job_rec.job_information12             := p_job_information12;
g_job_rec.job_information13             := p_job_information13;
g_job_rec.job_information14             := p_job_information14;
g_job_rec.job_information15             := p_job_information15;
g_job_rec.job_information16             := p_job_information16;
g_job_rec.job_information17             := p_job_information17;
g_job_rec.job_information18             := p_job_information18;
g_job_rec.job_information19             := p_job_information19;
g_job_rec.job_information20             := p_job_information20;
g_job_rec.job_id                        := p_job_id;
g_job_rec.job_definition_id             := p_job_definition_id;
g_job_rec.segment1              := p_segment1;
g_job_rec.segment2              := p_segment2;
g_job_rec.segment3              := p_segment3;
g_job_rec.segment4              := p_segment4;
g_job_rec.segment5              := p_segment5;
g_job_rec.segment6              := p_segment6;
g_job_rec.segment7              := p_segment7;
g_job_rec.segment8              := p_segment8;
g_job_rec.segment9              := p_segment9;
g_job_rec.segment10             := p_segment10;
g_job_rec.segment11             := p_segment11;
g_job_rec.segment12             := p_segment12;
g_job_rec.segment13             := p_segment13;
g_job_rec.segment14             := p_segment14;
g_job_rec.segment15             := p_segment15;
g_job_rec.segment16             := p_segment16;
g_job_rec.segment17             := p_segment17;
g_job_rec.segment18             := p_segment18;
g_job_rec.segment19             := p_segment19;
g_job_rec.segment20             := p_segment20;
g_job_rec.segment21            := p_segment21;
g_job_rec.segment22            := p_segment22;
g_job_rec.segment23            := p_segment23;
g_job_rec.segment24            := p_segment24;
g_job_rec.segment25            := p_segment25;
g_job_rec.segment26            := p_segment26;
g_job_rec.segment27            := p_segment27;
g_job_rec.segment28            := p_segment28;
g_job_rec.segment29            := p_segment29;
g_job_rec.segment30            := p_segment30;

end Set_Current_Job_record_Values;



procedure update_job
    (p_date_from                     in     date
    ,p_comments                      in     varchar2 default null
    ,p_date_to                       in     date     default null
    ,p_approval_authority            in     number   default null
    ,p_benchmark_job_flag            in     varchar2 default 'N'
    ,p_benchmark_job_id              in     number   default null
    ,p_emp_rights_flag               in     varchar2 default 'N'
    ,p_attribute_category            in     varchar2 default null
    ,p_attribute1                    in     varchar2 default null
    ,p_attribute2                    in     varchar2 default null
    ,p_attribute3                    in     varchar2 default null
    ,p_attribute4                    in     varchar2 default null
    ,p_attribute5                    in     varchar2 default null
    ,p_attribute6                    in     varchar2 default null
    ,p_attribute7                    in     varchar2 default null
    ,p_attribute8                    in     varchar2 default null
    ,p_attribute9                    in     varchar2 default null
    ,p_attribute10                   in     varchar2 default null
    ,p_attribute11                   in     varchar2 default null
    ,p_attribute12                   in     varchar2 default null
    ,p_attribute13                   in     varchar2 default null
    ,p_attribute14                   in     varchar2 default null
    ,p_attribute15                   in     varchar2 default null
    ,p_attribute16                   in     varchar2 default null
    ,p_attribute17                   in     varchar2 default null
    ,p_attribute18                   in     varchar2 default null
    ,p_attribute19                   in     varchar2 default null
    ,p_attribute20                   in     varchar2 default null
    ,p_job_information_category      in     varchar2 default null
    ,p_job_information1              in     varchar2 default null
    ,p_job_information2              in     varchar2 default null
    ,p_job_information3              in     varchar2 default null
    ,p_job_information4              in     varchar2 default null
    ,p_job_information5              in     varchar2 default null
    ,p_job_information6              in     varchar2 default null
    ,p_job_information7              in     varchar2 default null
    ,p_job_information8              in     varchar2 default null
    ,p_job_information9              in     varchar2 default null
    ,p_job_information10             in     varchar2 default null
    ,p_job_information11             in     varchar2 default null
    ,p_job_information12             in     varchar2 default null
    ,p_job_information13             in     varchar2 default null
    ,p_job_information14             in     varchar2 default null
    ,p_job_information15             in     varchar2 default null
    ,p_job_information16             in     varchar2 default null
    ,p_job_information17             in     varchar2 default null
    ,p_job_information18             in     varchar2 default null
    ,p_job_information19             in     varchar2 default null
    ,p_job_information20             in     varchar2 default null
    ,p_segment1                      in     varchar2 default null
    ,p_segment2                      in     varchar2 default null
    ,p_segment3                      in     varchar2 default null
    ,p_segment4                      in     varchar2 default null
    ,p_segment5                      in     varchar2 default null
    ,p_segment6                      in     varchar2 default null
    ,p_segment7                      in     varchar2 default null
    ,p_segment8                      in     varchar2 default null
    ,p_segment9                      in     varchar2 default null
    ,p_segment10                     in     varchar2 default null
    ,p_segment11                     in     varchar2 default null
    ,p_segment12                     in     varchar2 default null
    ,p_segment13                     in     varchar2 default null
    ,p_segment14                     in     varchar2 default null
    ,p_segment15                     in     varchar2 default null
    ,p_segment16                     in     varchar2 default null
    ,p_segment17                     in     varchar2 default null
    ,p_segment18                     in     varchar2 default null
    ,p_segment19                     in     varchar2 default null
    ,p_segment20                     in     varchar2 default null
    ,p_segment21                     in     varchar2 default null
    ,p_segment22                     in     varchar2 default null
    ,p_segment23                     in     varchar2 default null
    ,p_segment24                     in     varchar2 default null
    ,p_segment25                     in     varchar2 default null
    ,p_segment26                     in     varchar2 default null
    ,p_segment27                     in     varchar2 default null
    ,p_segment28                     in     varchar2 default null
    ,p_segment29                     in     varchar2 default null
    ,p_segment30                     in     varchar2 default null
    ,p_concat_segments               in     varchar2 default null
    ,p_language_code                 in     varchar2 default hr_api.userenv_lang
    ,p_job_id                        in     number default null
    ,p_job_definition_id          in out nocopy number
    ) is

   l_validate boolean := false;
   l_obj_ver_num    number(3);
   l_name           per_jobs.name%TYPE;
   l_valid_grades_changed_warning boolean;
begin
  hr_utility.trace('job id : ' || p_job_id);
  select object_version_number into l_obj_ver_num from per_jobs
    where JOB_ID=p_job_id;
hr_job_api.update_job
    (p_validate                     => l_validate
    ,p_job_id                       => p_job_id
    ,p_object_version_number        => l_obj_ver_num
    ,p_date_from                    => p_date_from
    ,p_comments                     => p_comments
    ,p_date_to                      => p_date_to
    ,p_benchmark_job_flag           => p_benchmark_job_flag
    ,p_benchmark_job_id             => p_benchmark_job_id
    ,p_emp_rights_flag              => p_emp_rights_flag
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_job_information_category     => p_job_information_category
    ,p_job_information1             => p_job_information1
    ,p_job_information2             => p_job_information2
    ,p_job_information3             => p_job_information3
    ,p_job_information4             => p_job_information4
    ,p_job_information5             => p_job_information5
    ,p_job_information6             => p_job_information6
    ,p_job_information7             => p_job_information7
    ,p_job_information8             => p_job_information8
    ,p_job_information9             => p_job_information9
    ,p_job_information10            => p_job_information10
    ,p_job_information11            => p_job_information11
    ,p_job_information12            => p_job_information12
    ,p_job_information13            => p_job_information13
    ,p_job_information14            => p_job_information14
    ,p_job_information15            => p_job_information15
    ,p_job_information16            => p_job_information16
    ,p_job_information17            => p_job_information17
    ,p_job_information18            => p_job_information18
    ,p_job_information19            => p_job_information19
    ,p_job_information20            => p_job_information20
    ,p_segment1                     => p_segment1
    ,p_segment2                     => p_segment2
    ,p_segment3                     => p_segment3
    ,p_segment4                     => p_segment4
    ,p_segment5                     => p_segment5
    ,p_segment6                     => p_segment6
    ,p_segment7                     => p_segment7
    ,p_segment8                     => p_segment8
    ,p_segment9                     => p_segment9
    ,p_segment10                    => p_segment10
    ,p_segment11                    => p_segment11
    ,p_segment12                    => p_segment12
    ,p_segment13                    => p_segment13
    ,p_segment14                    => p_segment14
    ,p_segment15                    => p_segment15
    ,p_segment16                    => p_segment16
    ,p_segment17                    => p_segment17
    ,p_segment18                    => p_segment18
    ,p_segment19                    => p_segment19
    ,p_segment20                    => p_segment20
    ,p_segment21                    => p_segment21
    ,p_segment22                    => p_segment22
    ,p_segment23                    => p_segment23
    ,p_segment24                    => p_segment24
    ,p_segment25                    => p_segment25
    ,p_segment26                    => p_segment26
    ,p_segment27                    => p_segment27
    ,p_segment28                    => p_segment28
    ,p_segment29                    => p_segment29
    ,p_segment30                    => p_segment30
    ,p_concat_segments              => p_concat_segments
    ,p_approval_authority           => p_approval_authority
    ,p_job_definition_id            => p_job_definition_id
    ,p_name                         => l_name
    ,p_valid_grades_changed_warning => l_valid_grades_changed_warning
    ,p_effective_date		    => sysdate
    );
end update_job;

procedure check_job_exists
    (p_business_group_id in number
    ,p_segment1                      in     varchar2 default null
    ,p_segment2                      in     varchar2 default null
    ,p_segment3                      in     varchar2 default null
    ,p_segment4                      in     varchar2 default null
    ,p_segment5                      in     varchar2 default null
    ,p_segment6                      in     varchar2 default null
    ,p_segment7                      in     varchar2 default null
    ,p_segment8                      in     varchar2 default null
    ,p_segment9                      in     varchar2 default null
    ,p_segment10                     in     varchar2 default null
    ,p_segment11                     in     varchar2 default null
    ,p_segment12                     in     varchar2 default null
    ,p_segment13                     in     varchar2 default null
    ,p_segment14                     in     varchar2 default null
    ,p_segment15                     in     varchar2 default null
    ,p_segment16                     in     varchar2 default null
    ,p_segment17                     in     varchar2 default null
    ,p_segment18                     in     varchar2 default null
    ,p_segment19                     in     varchar2 default null
    ,p_segment20                     in     varchar2 default null
    ,p_segment21                     in     varchar2 default null
    ,p_segment22                     in     varchar2 default null
    ,p_segment23                     in     varchar2 default null
    ,p_segment24                     in     varchar2 default null
    ,p_segment25                     in     varchar2 default null
    ,p_segment26                     in     varchar2 default null
    ,p_segment27                     in     varchar2 default null
    ,p_segment28                     in     varchar2 default null
    ,p_segment29                     in     varchar2 default null
    ,p_segment30                     in     varchar2 default null
    ,p_job_id                        out nocopy number
    ,p_job_definition_id          in out nocopy number
    ,p_job_group_id                  in     number
    ) is

  l_proc    varchar2(72) := g_package ||'.check_job_exists';
  l_name                    per_jobs.name%TYPE;
  l_flex_num                number;
   cursor idsel is
       select pjg.ID_FLEX_NUM
       from per_job_groups pjg
       where pjg.job_group_id = p_job_group_id;

begin
  hr_utility.trace('entering ' || l_proc);
  open idsel;
  fetch idsel into l_flex_num;
  if idsel%notfound
  then
     close idsel;
     --
     -- the flex structure has not been found
     --
     hr_utility.set_message(801, 'HR_6039_ALL_CANT_GET_FFIELD');
     hr_utility.raise_error;
  end if;
  close idsel;

     hr_kflex_utility.ins_or_sel_keyflex_comb
       (p_appl_short_name       => 'PER'
       ,p_flex_code             => 'JOB'
       ,p_flex_num              => l_flex_num
       ,p_segment1              => p_segment1
       ,p_segment2              => p_segment2
       ,p_segment3              => p_segment3
       ,p_segment4              => p_segment4
       ,p_segment5              => p_segment5
       ,p_segment6              => p_segment6
       ,p_segment7              => p_segment7
       ,p_segment8              => p_segment8
       ,p_segment9              => p_segment9
       ,p_segment10             => p_segment10
       ,p_segment11             => p_segment11
       ,p_segment12             => p_segment12
       ,p_segment13             => p_segment13
       ,p_segment14             => p_segment14
       ,p_segment15             => p_segment15
       ,p_segment16             => p_segment16
       ,p_segment17             => p_segment17
       ,p_segment18             => p_segment18
       ,p_segment19             => p_segment19
       ,p_segment20             => p_segment20
       ,p_segment21             => p_segment21
       ,p_segment22             => p_segment22
       ,p_segment23             => p_segment23
       ,p_segment24             => p_segment24
       ,p_segment25             => p_segment25
       ,p_segment26             => p_segment26
       ,p_segment27             => p_segment27
       ,p_segment28             => p_segment28
       ,p_segment29             => p_segment29
       ,p_segment30             => p_segment30
       ,p_concat_segments_in    => null
       ,p_ccid                  => p_job_definition_id
       ,p_concat_segments_out   => l_name
       );

    select job_id into p_job_id
    from per_jobs
    where business_group_id = p_business_group_id
    and   name = l_name;

Exception
When others then
p_job_id := null;
end check_job_exists;


procedure insupd_job
    (p_business_group_id             in     number
    ,p_date_from                     in     date
    ,p_comments                      in     varchar2 default null
    ,p_date_to                       in     date     default null
    ,p_approval_authority            in     number   default null
    ,p_benchmark_job_flag            in     varchar2 default 'N'
    ,p_benchmark_job_id              in     number   default null
    ,p_emp_rights_flag               in     varchar2 default 'N'
    ,p_job_group_id                  in     number
    ,p_attribute_category            in     varchar2 default null
    ,p_attribute1                    in     varchar2 default null
    ,p_attribute2                    in     varchar2 default null
    ,p_attribute3                    in     varchar2 default null
    ,p_attribute4                    in     varchar2 default null
    ,p_attribute5                    in     varchar2 default null
    ,p_attribute6                    in     varchar2 default null
    ,p_attribute7                    in     varchar2 default null
    ,p_attribute8                    in     varchar2 default null
    ,p_attribute9                    in     varchar2 default null
    ,p_attribute10                   in     varchar2 default null
    ,p_attribute11                   in     varchar2 default null
    ,p_attribute12                   in     varchar2 default null
    ,p_attribute13                   in     varchar2 default null
    ,p_attribute14                   in     varchar2 default null
    ,p_attribute15                   in     varchar2 default null
    ,p_attribute16                   in     varchar2 default null
    ,p_attribute17                   in     varchar2 default null
    ,p_attribute18                   in     varchar2 default null
    ,p_attribute19                   in     varchar2 default null
    ,p_attribute20                   in     varchar2 default null
    ,p_job_information_category      in     varchar2 default null
    ,p_job_information1              in     varchar2 default null
    ,p_job_information2              in     varchar2 default null
    ,p_job_information3              in     varchar2 default null
    ,p_job_information4              in     varchar2 default null
    ,p_job_information5              in     varchar2 default null
    ,p_job_information6              in     varchar2 default null
    ,p_job_information7              in     varchar2 default null
    ,p_job_information8              in     varchar2 default null
    ,p_job_information9              in     varchar2 default null
    ,p_job_information10             in     varchar2 default null
    ,p_job_information11             in     varchar2 default null
    ,p_job_information12             in     varchar2 default null
    ,p_job_information13             in     varchar2 default null
    ,p_job_information14             in     varchar2 default null
    ,p_job_information15             in     varchar2 default null
    ,p_job_information16             in     varchar2 default null
    ,p_job_information17             in     varchar2 default null
    ,p_job_information18             in     varchar2 default null
    ,p_job_information19             in     varchar2 default null
    ,p_job_information20             in     varchar2 default null
    ,p_segment1                      in     varchar2 default null
    ,p_segment2                      in     varchar2 default null
    ,p_segment3                      in     varchar2 default null
    ,p_segment4                      in     varchar2 default null
    ,p_segment5                      in     varchar2 default null
    ,p_segment6                      in     varchar2 default null
    ,p_segment7                      in     varchar2 default null
    ,p_segment8                      in     varchar2 default null
    ,p_segment9                      in     varchar2 default null
    ,p_segment10                     in     varchar2 default null
    ,p_segment11                     in     varchar2 default null
    ,p_segment12                     in     varchar2 default null
    ,p_segment13                     in     varchar2 default null
    ,p_segment14                     in     varchar2 default null
    ,p_segment15                     in     varchar2 default null
    ,p_segment16                     in     varchar2 default null
    ,p_segment17                     in     varchar2 default null
    ,p_segment18                     in     varchar2 default null
    ,p_segment19                     in     varchar2 default null
    ,p_segment20                     in     varchar2 default null
    ,p_segment21                     in     varchar2 default null
    ,p_segment22                     in     varchar2 default null
    ,p_segment23                     in     varchar2 default null
    ,p_segment24                     in     varchar2 default null
    ,p_segment25                     in     varchar2 default null
    ,p_segment26                     in     varchar2 default null
    ,p_segment27                     in     varchar2 default null
    ,p_segment28                     in     varchar2 default null
    ,p_segment29                     in     varchar2 default null
    ,p_segment30                     in     varchar2 default null
    ,p_concat_segments               in     varchar2 default null
    ,p_language_code                 in     varchar2 default hr_api.userenv_lang
    ,p_job_id                        in     number default null
    ,p_job_definition_id          in out nocopy number
    ,P_CRT_UPD			  in 	 varchar2   default null
    ,p_migration_flag                in     varchar2
    ,p_interface_code                in     varchar2
     ) is

   l_validate boolean := false;
   l_job_id                   per_jobs.job_id%TYPE;
   l_job_definition_id        per_jobs.job_definition_id%TYPE                      := p_job_definition_id;
   l_name                     per_jobs.name%TYPE;
   l_object_version_number    per_jobs.object_version_number%TYPE;
   l_job_rec                  job_record;


  l_proc    varchar2(72) := g_package ||'.insupd_job';


  l_error_msg              varchar2(4000);
  l_create_flag    number(2) := 1;
  e_upl_not_allowed exception; -- when mode is 'View Only'
  e_crt_not_allowed exception; -- when mode is 'Update Only'
  g_upl_err_msg varchar2(100) := 'Upload NOT allowed.';
  g_crt_err_msg varchar2(100) := 'Creating NOT allowed.';
  g_crt_upd                 varchar2 (1):= 'D'; -- By default 'Download only'
  l_migration_allowed      varchar2(1) := 'Y';
  l_crt_upd                varchar2(1);


  Begin

  --l_migration_allowed := SUBSTR(p_crt_upd,3,1);
  l_migration_allowed := p_migration_flag;
  l_crt_upd := SUBSTR(p_crt_upd,1,1);
		if (l_crt_upd is not null) then
			  g_crt_upd      := l_crt_upd;
		end if;
  check_job_exists
    (p_business_group_id
    ,p_segment1
    ,p_segment2
    ,p_segment3
    ,p_segment4
    ,p_segment5
    ,p_segment6
    ,p_segment7
    ,p_segment8
    ,p_segment9
    ,p_segment10
    ,p_segment11
    ,p_segment12
    ,p_segment13
    ,p_segment14
    ,p_segment15
    ,p_segment16
    ,p_segment17
    ,p_segment18
    ,p_segment19
    ,p_segment20
    ,p_segment21
    ,p_segment22
    ,p_segment23
    ,p_segment24
    ,p_segment25
    ,p_segment26
    ,p_segment27
    ,p_segment28
    ,p_segment29
    ,p_segment30
    ,l_job_id
    ,p_job_definition_id
    ,p_job_group_id
    );
  if l_migration_allowed = 'Y' or p_job_id is null then
      if l_job_id is not null then
        l_create_flag := 2; --$ Update Mode
      else
        l_create_flag := 1; --$ Create Mode
      end if;
  elsif p_job_id is not null then
      if l_job_id is null then
        l_job_id := p_job_id;
      end if;
      l_create_flag := 2; --$ update Mode
  end if;

  Set_Current_Job_Record_Values
    (p_business_group_id            => p_business_group_id
    ,p_date_from                    => p_date_from
    ,p_comments                     => p_comments
    ,p_date_to                      => p_date_to
    ,p_approval_authority           => p_approval_authority
    ,p_benchmark_job_flag           => p_benchmark_job_flag
    ,p_benchmark_job_id             => p_benchmark_job_id
    ,p_emp_rights_flag              => p_emp_rights_flag
    ,p_job_group_id                 => p_job_group_id
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_job_information_category     => p_job_information_category
    ,p_job_information1             => p_job_information1
    ,p_job_information2             => p_job_information2
    ,p_job_information3             => p_job_information3
    ,p_job_information4             => p_job_information4
    ,p_job_information5             => p_job_information5
    ,p_job_information6             => p_job_information6
    ,p_job_information7             => p_job_information7
    ,p_job_information8             => p_job_information8
    ,p_job_information9             => p_job_information9
    ,p_job_information10            => p_job_information10
    ,p_job_information11            => p_job_information11
    ,p_job_information12            => p_job_information12
    ,p_job_information13            => p_job_information13
    ,p_job_information14            => p_job_information14
    ,p_job_information15            => p_job_information15
    ,p_job_information16            => p_job_information16
    ,p_job_information17            => p_job_information17
    ,p_job_information18            => p_job_information18
    ,p_job_information19            => p_job_information19
    ,p_job_information20            => p_job_information20
    ,p_segment1                     => p_segment1
    ,p_segment2                     => p_segment2
    ,p_segment3                     => p_segment3
    ,p_segment4                     => p_segment4
    ,p_segment5                     => p_segment5
    ,p_segment6                     => p_segment6
    ,p_segment7                     => p_segment7
    ,p_segment8                     => p_segment8
    ,p_segment9                     => p_segment9
    ,p_segment10                    => p_segment10
    ,p_segment11                    => p_segment11
    ,p_segment12                    => p_segment12
    ,p_segment13                    => p_segment13
    ,p_segment14                    => p_segment14
    ,p_segment15                    => p_segment15
    ,p_segment16                    => p_segment16
    ,p_segment17                    => p_segment17
    ,p_segment18                    => p_segment18
    ,p_segment19                    => p_segment19
    ,p_segment20                    => p_segment20
    ,p_segment21                    => p_segment21
    ,p_segment22                    => p_segment22
    ,p_segment23                    => p_segment23
    ,p_segment24                    => p_segment24
    ,p_segment25                    => p_segment25
    ,p_segment26                    => p_segment26
    ,p_segment27                    => p_segment27
    ,p_segment28                    => p_segment28
    ,p_segment29                    => p_segment29
    ,p_segment30                    => p_segment30
    ,p_concat_segments              => p_concat_segments
    ,p_language_code                => p_language_code
    ,p_job_id                       => l_job_id
    ,p_job_definition_id            => p_job_definition_id
    ,p_interface_code               => p_interface_code
    );




  if (g_crt_upd = 'D') then
   raise e_upl_not_allowed;  -- View only flag is enabled but Trying to Upload
  end if;
  if (g_crt_upd = 'U' and l_create_flag = 1) then
   raise e_crt_not_allowed;  -- Update only flag is enabled but Trying to Create
  end if;

     if l_create_flag = 1 then
     hr_job_api.create_job
    (p_validate                      => l_validate
    ,p_business_group_id             => p_business_group_id
    ,p_date_from                     => p_date_from
    ,p_comments                      => p_comments
    ,p_date_to                       => p_date_to
    ,p_approval_authority            => p_approval_authority
    ,p_benchmark_job_flag            => p_benchmark_job_flag
    ,p_benchmark_job_id              => p_benchmark_job_id
    ,p_emp_rights_flag               => p_emp_rights_flag
    ,p_job_group_id                  => p_job_group_id
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2		    						 => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_job_information_category      => p_job_information_category
    ,p_job_information1              => p_job_information1
    ,p_job_information2              => p_job_information2
    ,p_job_information3              => p_job_information3
    ,p_job_information4              => p_job_information4
    ,p_job_information5              => p_job_information5
    ,p_job_information6              => p_job_information6
    ,p_job_information7              => p_job_information7
    ,p_job_information8              => p_job_information8
    ,p_job_information9              => p_job_information9
    ,p_job_information10             => p_job_information10
    ,p_job_information11             => p_job_information11
    ,p_job_information12             => p_job_information12
    ,p_job_information13             => p_job_information13
    ,p_job_information14             => p_job_information14
    ,p_job_information15             => p_job_information15
    ,p_job_information16             => p_job_information16
    ,p_job_information17             => p_job_information17
    ,p_job_information18             => p_job_information18
    ,p_job_information19             => p_job_information19
    ,p_job_information20             => p_job_information20
    ,p_segment1                      => p_segment1
    ,p_segment2                      => p_segment2
    ,p_segment3                      => p_segment3
    ,p_segment4                      => p_segment4
    ,p_segment5                      => p_segment5
    ,p_segment6                      => p_segment6
    ,p_segment7                      => p_segment7
    ,p_segment8                      => p_segment8
    ,p_segment9                      => p_segment9
    ,p_segment10                     => p_segment10
    ,p_segment11                     => p_segment11
    ,p_segment12                     => p_segment12
    ,p_segment13                     => p_segment13
    ,p_segment14                     => p_segment14
    ,p_segment15                     => p_segment15
    ,p_segment16                     => p_segment16
    ,p_segment17                     => p_segment17
    ,p_segment18                     => p_segment18
    ,p_segment19                     => p_segment19
    ,p_segment20                     => p_segment20
    ,p_segment21                     => p_segment21
    ,p_segment22                     => p_segment22
    ,p_segment23                     => p_segment23
    ,p_segment24                     => p_segment24
    ,p_segment25                     => p_segment25
    ,p_segment26                     => p_segment26
    ,p_segment27                     => p_segment27
    ,p_segment28                     => p_segment28
    ,p_segment29                     => p_segment29
    ,p_segment30                     => p_segment30
    ,p_concat_segments               => p_concat_segments
    ,p_language_code                 => p_language_code
    ,p_job_id                        => l_job_id
    ,p_object_version_number         => l_object_version_number
    ,p_job_definition_id             => l_job_definition_id
    ,p_name                          => l_name);
    end if;

if l_create_flag = 2 then
    l_job_rec := Get_Job_Record_Values(p_interface_code);
update_job
    (p_job_id                       => l_job_rec.job_id
    ,p_date_from                    => l_job_rec.date_from
    ,p_comments                     => l_job_rec.comments
    ,p_date_to                      => l_job_rec.date_to
    ,p_benchmark_job_flag           => l_job_rec.benchmark_job_flag
    ,p_benchmark_job_id             => l_job_rec.benchmark_job_id
    ,p_emp_rights_flag              => l_job_rec.emp_rights_flag
    ,p_attribute_category           => l_job_rec.attribute_category
    ,p_attribute1                   => l_job_rec.attribute1
    ,p_attribute2                   => l_job_rec.attribute2
    ,p_attribute3                   => l_job_rec.attribute3
    ,p_attribute4                   => l_job_rec.attribute4
    ,p_attribute5                   => l_job_rec.attribute5
    ,p_attribute6                   => l_job_rec.attribute6
    ,p_attribute7                   => l_job_rec.attribute7
    ,p_attribute8                   => l_job_rec.attribute8
    ,p_attribute9                   => l_job_rec.attribute9
    ,p_attribute10                  => l_job_rec.attribute10
    ,p_attribute11                  => l_job_rec.attribute11
    ,p_attribute12                  => l_job_rec.attribute12
    ,p_attribute13                  => l_job_rec.attribute13
    ,p_attribute14                  => l_job_rec.attribute14
    ,p_attribute15                  => l_job_rec.attribute15
    ,p_attribute16                  => l_job_rec.attribute16
    ,p_attribute17                  => l_job_rec.attribute17
    ,p_attribute18                  => l_job_rec.attribute18
    ,p_attribute19                  => l_job_rec.attribute19
    ,p_attribute20                  => l_job_rec.attribute20
    ,p_job_information_category     => l_job_rec.job_information_category
    ,p_job_information1             => l_job_rec.job_information1
    ,p_job_information2             => l_job_rec.job_information2
    ,p_job_information3             => l_job_rec.job_information3
    ,p_job_information4             => l_job_rec.job_information4
    ,p_job_information5             => l_job_rec.job_information5
    ,p_job_information6             => l_job_rec.job_information6
    ,p_job_information7             => l_job_rec.job_information7
    ,p_job_information8             => l_job_rec.job_information8
    ,p_job_information9             => l_job_rec.job_information9
    ,p_job_information10            => l_job_rec.job_information10
    ,p_job_information11            => l_job_rec.job_information11
    ,p_job_information12            => l_job_rec.job_information12
    ,p_job_information13            => l_job_rec.job_information13
    ,p_job_information14            => l_job_rec.job_information14
    ,p_job_information15            => l_job_rec.job_information15
    ,p_job_information16            => l_job_rec.job_information16
    ,p_job_information17            => l_job_rec.job_information17
    ,p_job_information18            => l_job_rec.job_information18
    ,p_job_information19            => l_job_rec.job_information19
    ,p_job_information20            => l_job_rec.job_information20
    ,p_segment1                     => l_job_rec.segment1
    ,p_segment2                     => l_job_rec.segment2
    ,p_segment3                     => l_job_rec.segment3
    ,p_segment4                     => l_job_rec.segment4
    ,p_segment5                     => l_job_rec.segment5
    ,p_segment6                     => l_job_rec.segment6
    ,p_segment7                     => l_job_rec.segment7
    ,p_segment8                     => l_job_rec.segment8
    ,p_segment9                     => l_job_rec.segment9
    ,p_segment10                    => l_job_rec.segment10
    ,p_segment11                    => l_job_rec.segment11
    ,p_segment12                    => l_job_rec.segment12
    ,p_segment13                    => l_job_rec.segment13
    ,p_segment14                    => l_job_rec.segment14
    ,p_segment15                    => l_job_rec.segment15
    ,p_segment16                    => l_job_rec.segment16
    ,p_segment17                    => l_job_rec.segment17
    ,p_segment18                    => l_job_rec.segment18
    ,p_segment19                    => l_job_rec.segment19
    ,p_segment20                    => l_job_rec.segment20
    ,p_segment21                    => l_job_rec.segment21
    ,p_segment22                    => l_job_rec.segment22
    ,p_segment23                    => l_job_rec.segment23
    ,p_segment24                    => l_job_rec.segment24
    ,p_segment25                    => l_job_rec.segment25
    ,p_segment26                    => l_job_rec.segment26
    ,p_segment27                    => l_job_rec.segment27
    ,p_segment28                    => l_job_rec.segment28
    ,p_segment29                    => l_job_rec.segment29
    ,p_segment30                    => l_job_rec.segment30
    ,p_concat_segments              => l_job_rec.concat_segments
    ,p_approval_authority           => l_job_rec.approval_authority
    ,p_job_definition_id            => l_job_definition_id
    );
end if;
Exception

  when e_upl_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_upl_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc, 90);
    hr_utility.raise_error;
  when e_crt_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_crt_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc, 100);
    hr_utility.raise_error;
  when others then
   --l_error_msg := Substr(SQLERRM,1,2000);
   hr_utility.set_location('SQLCODE :' || SQLCODE,90);
   hr_utility.set_location('SQLERRM :' || SQLERRM,90);
   --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   --hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,50) );
   hr_utility.set_location(' Leaving:' || l_proc,50);
   hr_utility.raise_error;



end INSUPD_JOB;


end PQP_RIW_JOB_WRAPPER;

/
