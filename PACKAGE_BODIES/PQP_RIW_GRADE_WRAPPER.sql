--------------------------------------------------------
--  DDL for Package Body PQP_RIW_GRADE_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_RIW_GRADE_WRAPPER" as
/* $Header: pqpriwgrwr.pkb 120.0.12010000.2 2009/07/24 11:09:49 sravikum noship $ */
-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
g_package  varchar2(33) := 'pqp_riw_grade_wrapper';
g_interface_code              varchar2(150);

type grade_record is record
(
business_group_id                  number(15)
,date_from                          date
,sequence			   number(15)
,effective_date		           date
,date_to                            date
,request_id			   number(15)
,program_application_id         	   number(15)
,program_id                     	   number(15)
,program_update_date            	   date
,last_update_date               	   date
,last_updated_by                	   number(15)
,last_update_login              	   number(15)
,created_by                     	   number(15)
,creation_date                  	   date
,attribute_category                 varchar2(30)
,attribute1                         varchar2(150)
,attribute2                         varchar2(150)
,attribute3                         varchar2(150)
,attribute4                         varchar2(150)
,attribute5                         varchar2(150)
,attribute6                         varchar2(150)
,attribute7                         varchar2(150)
,attribute8                         varchar2(150)
,attribute9                         varchar2(150)
,attribute10                        varchar2(150)
,attribute11                        varchar2(150)
,attribute12                        varchar2(150)
,attribute13                        varchar2(150)
,attribute14                        varchar2(150)
,attribute15                        varchar2(150)
,attribute16                        varchar2(150)
,attribute17                        varchar2(150)
,attribute18                        varchar2(150)
,attribute19                        varchar2(150)
,attribute20                        varchar2(150)
,information_category               varchar2(30)
,information1 	                varchar2(150)
,information2 	                varchar2(150)
,information3 	                varchar2(150)
,information4 	                varchar2(150)
,information5 	                varchar2(150)
,information6 	                varchar2(150)
,information7 	                varchar2(150)
,information8 	                varchar2(150)
,information9 	                varchar2(150)
,information10 	                varchar2(150)
,information11 	                varchar2(150)
,information12 	                varchar2(150)
,information13 	                varchar2(150)
,information14 	                varchar2(150)
,information15 	                varchar2(150)
,information16 	                varchar2(150)
,information17 	                varchar2(150)
,information18 	                varchar2(150)
,information19 	                varchar2(150)
,information20 	                varchar2(150)
,segment1                           varchar2(60)
,segment2                           varchar2(60)
,segment3                           varchar2(60)
,segment4                           varchar2(60)
,segment5                           varchar2(60)
,segment6                           varchar2(60)
,segment7                           varchar2(60)
,segment8                           varchar2(60)
,segment9                           varchar2(60)
,segment10                          varchar2(60)
,segment11                          varchar2(60)
,segment12                          varchar2(60)
,segment13                          varchar2(60)
,segment14                          varchar2(60)
,segment15                          varchar2(60)
,segment16                          varchar2(60)
,segment17                          varchar2(60)
,segment18                          varchar2(60)
,segment19                          varchar2(60)
,segment20                          varchar2(60)
,segment21                          varchar2(60)
,segment22                          varchar2(60)
,segment23                          varchar2(60)
,segment24                          varchar2(60)
,segment25                          varchar2(60)
,segment26                          varchar2(60)
,segment27                          varchar2(60)
,segment28                          varchar2(60)
,segment29                          varchar2(60)
,segment30                          varchar2(60)
,language_code                      varchar2(60)
,concat_segments                    varchar2(60)
,short_name		           varchar2(60)
,grade_id                           number(15)
,grade_definition_id                number(15)
);

g_grade_rec grade_record;

-- =============================================================================
-- Default_Record_Values:
-- =============================================================================

function get_default_grade_rec
return grade_record is
  l_proc_name    constant varchar2(150) := g_package||'.get_default_grade_rec';
  l_grade_rec     grade_record;
begin
  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
  /*
   ==========================================================================
   g_varchar2  constant varchar2(9) := '$Sys_Def$';
   g_number  constant number        := -987123654;
   g_date  constant date            := to_date('01-01-4712', 'DD-MM-SYYYY');
   ==========================================================================
  */
l_grade_rec.business_group_id           := hr_api.g_number;
l_grade_rec.date_from                  := hr_api.g_date;
l_grade_rec.sequence			:= hr_api.g_number;
l_grade_rec.effective_date		    := hr_api.g_date;
l_grade_rec.date_to                    := hr_api.g_date;
l_grade_rec.request_id			:= hr_api.g_number;
l_grade_rec.program_application_id     := hr_api.g_number;
l_grade_rec.program_id                 := hr_api.g_number;
l_grade_rec.program_update_date        := hr_api.g_date;
l_grade_rec.last_update_date           := hr_api.g_date;
l_grade_rec.last_updated_by            := hr_api.g_number;
l_grade_rec.last_update_login          := hr_api.g_number;
l_grade_rec.created_by                 := hr_api.g_number;
l_grade_rec.creation_date              := hr_api.g_date;
l_grade_rec.attribute_category         := hr_api.g_varchar2;
l_grade_rec.attribute1                 := hr_api.g_varchar2;
l_grade_rec.attribute2                 := hr_api.g_varchar2;
l_grade_rec.attribute3                 := hr_api.g_varchar2;
l_grade_rec.attribute4                 := hr_api.g_varchar2;
l_grade_rec.attribute5                 := hr_api.g_varchar2;
l_grade_rec.attribute6                 := hr_api.g_varchar2;
l_grade_rec.attribute7                 := hr_api.g_varchar2;
l_grade_rec.attribute8                 := hr_api.g_varchar2;
l_grade_rec.attribute9                 := hr_api.g_varchar2;
l_grade_rec.attribute10                := hr_api.g_varchar2;
l_grade_rec.attribute11                := hr_api.g_varchar2;
l_grade_rec.attribute12                := hr_api.g_varchar2;
l_grade_rec.attribute13                := hr_api.g_varchar2;
l_grade_rec.attribute14                := hr_api.g_varchar2;
l_grade_rec.attribute15                := hr_api.g_varchar2;
l_grade_rec.attribute16                := hr_api.g_varchar2;
l_grade_rec.attribute17                := hr_api.g_varchar2;
l_grade_rec.attribute18                := hr_api.g_varchar2;
l_grade_rec.attribute19                := hr_api.g_varchar2;
l_grade_rec.attribute20                := hr_api.g_varchar2;
l_grade_rec.information_category       := hr_api.g_varchar2;
l_grade_rec.information1 	            := hr_api.g_varchar2;
l_grade_rec.information2 	            := hr_api.g_varchar2;
l_grade_rec.information3 	            := hr_api.g_varchar2;
l_grade_rec.information4 	            := hr_api.g_varchar2;
l_grade_rec.information5 	            := hr_api.g_varchar2;
l_grade_rec.information6 	            := hr_api.g_varchar2;
l_grade_rec.information7 	            := hr_api.g_varchar2;
l_grade_rec.information8 	            := hr_api.g_varchar2;
l_grade_rec.information9 	            := hr_api.g_varchar2;
l_grade_rec.information10 	            := hr_api.g_varchar2;
l_grade_rec.information11 	            := hr_api.g_varchar2;
l_grade_rec.information12 	            := hr_api.g_varchar2;
l_grade_rec.information13 	            := hr_api.g_varchar2;
l_grade_rec.information14 	            := hr_api.g_varchar2;
l_grade_rec.information15 	            := hr_api.g_varchar2;
l_grade_rec.information16 	            := hr_api.g_varchar2;
l_grade_rec.information17 	            := hr_api.g_varchar2;
l_grade_rec.information18 	            := hr_api.g_varchar2;
l_grade_rec.information19 	            := hr_api.g_varchar2;
l_grade_rec.information20 	            := hr_api.g_varchar2;
l_grade_rec.segment1                   := hr_api.g_varchar2;
l_grade_rec.segment2                   := hr_api.g_varchar2;
l_grade_rec.segment3                   := hr_api.g_varchar2;
l_grade_rec.segment4                   := hr_api.g_varchar2;
l_grade_rec.segment5                   := hr_api.g_varchar2;
l_grade_rec.segment6                   := hr_api.g_varchar2;
l_grade_rec.segment7                   := hr_api.g_varchar2;
l_grade_rec.segment8                   := hr_api.g_varchar2;
l_grade_rec.segment9                   := hr_api.g_varchar2;
l_grade_rec.segment10                  := hr_api.g_varchar2;
l_grade_rec.segment11                  := hr_api.g_varchar2;
l_grade_rec.segment12                  := hr_api.g_varchar2;
l_grade_rec.segment13                  := hr_api.g_varchar2;
l_grade_rec.segment14                  := hr_api.g_varchar2;
l_grade_rec.segment15                  := hr_api.g_varchar2;
l_grade_rec.segment16                  := hr_api.g_varchar2;
l_grade_rec.segment17                  := hr_api.g_varchar2;
l_grade_rec.segment18                  := hr_api.g_varchar2;
l_grade_rec.segment19                  := hr_api.g_varchar2;
l_grade_rec.segment20                  := hr_api.g_varchar2;
l_grade_rec.segment21                  := hr_api.g_varchar2;
l_grade_rec.segment22                  := hr_api.g_varchar2;
l_grade_rec.segment23                  := hr_api.g_varchar2;
l_grade_rec.segment24                  := hr_api.g_varchar2;
l_grade_rec.segment25                  := hr_api.g_varchar2;
l_grade_rec.segment26                  := hr_api.g_varchar2;
l_grade_rec.segment27                  := hr_api.g_varchar2;
l_grade_rec.segment28                  := hr_api.g_varchar2;
l_grade_rec.segment29                  := hr_api.g_varchar2;
l_grade_rec.segment30                  := hr_api.g_varchar2;
l_grade_rec.language_code              := hr_api.g_varchar2;
l_grade_rec.concat_segments            := hr_api.g_varchar2;
l_grade_rec.short_name		    := hr_api.g_varchar2;
l_grade_rec.grade_id                   := hr_api.g_number;
l_grade_rec.grade_definition_id        := hr_api.g_number;

return l_grade_rec;

exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;
end get_default_grade_rec;

-- =============================================================================
-- Get_Record_Values:
-- =============================================================================
function Get_Grade_Record_Values
        (p_interface_code in varchar2 default null)
         return grade_record is

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

  l_grade_rec            grade_record;
  col_name             varchar2(150);
  l_proc_name constant varchar2(150) := g_package||'.Get_Grade_Record_Values';
begin
  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
  l_grade_rec := get_default_grade_rec;
  for col_rec in bne_cols (g_interface_code)
  loop


   case col_rec.interface_col_name

    when 'p_business_group_id' then
          l_grade_rec.business_group_id := g_grade_rec.business_group_id;
    when 'p_date_from' then
          l_grade_rec.date_from := g_grade_rec.date_from;
    when 'p_sequence' then
          l_grade_rec.sequence := g_grade_rec.sequence;
    when 'p_effective_date' then
          l_grade_rec.effective_date := g_grade_rec.effective_date;
    when 'p_date_to' then
          l_grade_rec.date_to := g_grade_rec.date_to;
    when 'p_request_id' then
          l_grade_rec.request_id := g_grade_rec.request_id;
    when 'p_program_application_id' then
          l_grade_rec.program_application_id := g_grade_rec.program_application_id;
    when 'p_program_id' then
          l_grade_rec.program_id := g_grade_rec.program_id;
    when 'p_program_update_date' then
          l_grade_rec.program_update_date := g_grade_rec.program_update_date;
    when 'p_last_update_date' then
          l_grade_rec.last_update_date := g_grade_rec.last_update_date;
    when 'p_last_updated_by' then
          l_grade_rec.last_updated_by := g_grade_rec.last_updated_by;
    when 'p_last_update_login' then
          l_grade_rec.last_update_login := g_grade_rec.last_update_login;
    when 'p_created_by' then
          l_grade_rec.created_by := g_grade_rec.created_by;
    when 'p_creation_date' then
          l_grade_rec.creation_date := g_grade_rec.creation_date;
    when 'add_grade_descflex' then
          l_grade_rec.attribute_category := g_grade_rec.attribute_category;


          for col_rec1 in bne_cols_no_disp(g_interface_code) loop

             case col_rec1.interface_col_name

    when 'attribute1' then
          l_grade_rec.attribute1 := g_grade_rec.attribute1;
    when 'attribute2' then
          l_grade_rec.attribute2 := g_grade_rec.attribute2;
    when 'attribute3' then
          l_grade_rec.attribute3 := g_grade_rec.attribute3;
    when 'attribute4' then
          l_grade_rec.attribute4 := g_grade_rec.attribute4;
    when 'attribute5' then
          l_grade_rec.attribute5 := g_grade_rec.attribute5;
    when 'attribute6' then
          l_grade_rec.attribute6 := g_grade_rec.attribute6;
    when 'attribute7' then
          l_grade_rec.attribute7 := g_grade_rec.attribute7;
    when 'attribute8' then
          l_grade_rec.attribute8 := g_grade_rec.attribute8;
    when 'attribute9' then
          l_grade_rec.attribute9 := g_grade_rec.attribute9;
    when 'attribute10' then
          l_grade_rec.attribute10 := g_grade_rec.attribute10;
    when 'attribute11' then
          l_grade_rec.attribute11 := g_grade_rec.attribute11;
    when 'attribute12' then
          l_grade_rec.attribute12 := g_grade_rec.attribute12;
    when 'attribute13' then
          l_grade_rec.attribute13 := g_grade_rec.attribute13;
    when 'attribute14' then
          l_grade_rec.attribute14 := g_grade_rec.attribute14;
    when 'attribute15' then
          l_grade_rec.attribute15 := g_grade_rec.attribute15;
    when 'attribute16' then
          l_grade_rec.attribute16 := g_grade_rec.attribute16;
    when 'attribute17' then
          l_grade_rec.attribute17 := g_grade_rec.attribute17;
    when 'attribute18' then
          l_grade_rec.attribute18 := g_grade_rec.attribute18;
    when 'attribute19' then
          l_grade_rec.attribute19 := g_grade_rec.attribute19;
    when 'attribute20' then
          l_grade_rec.attribute20 := g_grade_rec.attribute20;
    else
          null;
    end case;
          end loop;


    when 'fur_grade_descflex' then
          l_grade_rec.information_category := g_grade_rec.information_category;

         if l_grade_rec.information_category is not null then
          for col_rec1 in bne_cols_no_disp(g_interface_code) loop

             case col_rec1.interface_col_name

    when 'information1' then
          l_grade_rec.information1 := g_grade_rec.information1;
    when 'information2' then
          l_grade_rec.information2 := g_grade_rec.information2;
    when 'information3' then
          l_grade_rec.information3 := g_grade_rec.information3;
    when 'information4' then
          l_grade_rec.information4 := g_grade_rec.information4;
    when 'information5' then
          l_grade_rec.information5 := g_grade_rec.information5;
    when 'information6' then
          l_grade_rec.information6 := g_grade_rec.information6;
    when 'information7' then
          l_grade_rec.information7 := g_grade_rec.information7;
    when 'information8' then
          l_grade_rec.information8 := g_grade_rec.information8;
    when 'information9' then
          l_grade_rec.information9 := g_grade_rec.information9;
    when 'information10' then
          l_grade_rec.information10 := g_grade_rec.information10;
    when 'information11' then
          l_grade_rec.information11 := g_grade_rec.information11;
    when 'information12' then
          l_grade_rec.information12 := g_grade_rec.information12;
    when 'information13' then
          l_grade_rec.information13 := g_grade_rec.information13;
    when 'information14' then
          l_grade_rec.information14 := g_grade_rec.information14;
    when 'information15' then
          l_grade_rec.information15 := g_grade_rec.information15;
    when 'information16' then
          l_grade_rec.information16 := g_grade_rec.information16;
    when 'information17' then
          l_grade_rec.information17 := g_grade_rec.information17;
    when 'information18' then
          l_grade_rec.information18 := g_grade_rec.information18;
    when 'information19' then
          l_grade_rec.information19 := g_grade_rec.information19;
    when 'information20' then
          l_grade_rec.information20 := g_grade_rec.information20;
    else
          null;
    end case;
          end loop;
          end if;

    when 'p_concat_segments' then
          l_grade_rec.concat_segments := g_grade_rec.concat_segments;

          for col_rec1 in bne_cols_no_disp(g_interface_code) loop

             case col_rec1.interface_col_name

    when 'segment1' then
          l_grade_rec.segment1 := g_grade_rec.segment1;
    when 'segment2' then
          l_grade_rec.segment2 := g_grade_rec.segment2;
    when 'segment3' then
          l_grade_rec.segment3 := g_grade_rec.segment3;
    when 'segment4' then
          l_grade_rec.segment4 := g_grade_rec.segment4;
    when 'segment5' then
          l_grade_rec.segment5 := g_grade_rec.segment5;
    when 'segment6' then
          l_grade_rec.segment6 := g_grade_rec.segment6;
    when 'segment7' then
          l_grade_rec.segment7 := g_grade_rec.segment7;
    when 'segment8' then
          l_grade_rec.segment8 := g_grade_rec.segment8;
    when 'segment9' then
          l_grade_rec.segment9 := g_grade_rec.segment9;
    when 'segment10' then
          l_grade_rec.segment10 := g_grade_rec.segment10;
    when 'segment11' then
          l_grade_rec.segment11 := g_grade_rec.segment11;
    when 'segment12' then
          l_grade_rec.segment12 := g_grade_rec.segment12;
    when 'segment13' then
          l_grade_rec.segment13 := g_grade_rec.segment13;
    when 'segment14' then
          l_grade_rec.segment14 := g_grade_rec.segment14;
    when 'segment15' then
          l_grade_rec.segment15 := g_grade_rec.segment15;
    when 'segment16' then
          l_grade_rec.segment16 := g_grade_rec.segment16;
    when 'segment17' then
          l_grade_rec.segment17 := g_grade_rec.segment17;
    when 'segment18' then
          l_grade_rec.segment18 := g_grade_rec.segment18;
    when 'segment19' then
          l_grade_rec.segment19 := g_grade_rec.segment19;
    when 'segment20' then
          l_grade_rec.segment20 := g_grade_rec.segment20;
    when 'segment21' then
          l_grade_rec.segment21 := g_grade_rec.segment21;
    when 'segment22' then
          l_grade_rec.segment22 := g_grade_rec.segment22;
    when 'segment23' then
          l_grade_rec.segment23 := g_grade_rec.segment23;
    when 'segment24' then
          l_grade_rec.segment24 := g_grade_rec.segment24;
    when 'segment25' then
          l_grade_rec.segment25 := g_grade_rec.segment25;
    when 'segment26' then
          l_grade_rec.segment26 := g_grade_rec.segment26;
    when 'segment27' then
          l_grade_rec.segment27 := g_grade_rec.segment27;
    when 'segment28' then
          l_grade_rec.segment28 := g_grade_rec.segment28;
    when 'segment29' then
          l_grade_rec.segment29 := g_grade_rec.segment29;
    when 'segment30' then
          l_grade_rec.segment30 := g_grade_rec.segment30;
    else
          null;
    end case;
          end loop;


    when 'p_language_code' then
          l_grade_rec.language_code := g_grade_rec.language_code;
    when 'p_concat_segments' then
          l_grade_rec.concat_segments := g_grade_rec.concat_segments;
    when 'p_short_name' then
          l_grade_rec.short_name := g_grade_rec.short_name;
    when 'p_grade_id' then
          l_grade_rec.grade_id := g_grade_rec.grade_id;
    when 'p_grade_definition_id' then
          l_grade_rec.grade_definition_id := g_grade_rec.grade_definition_id;
    else
           null;

    end case;
  end loop;
          hr_utility.trace('returning grade record');
  return l_grade_rec;
end Get_grade_Record_Values;

procedure Set_Cur_Grade_record_Values
  (p_business_group_id             in     number
  ,p_date_from                     in     date
  ,p_sequence			   in	  number
  ,p_effective_date		   in     date     default null
  ,p_date_to                       in     date     default null
  ,p_request_id			   in 	  number   default null
  ,p_program_application_id        in 	  number   default null
  ,p_program_id                    in 	  number   default null
  ,p_program_update_date           in 	  date     default null
  ,p_last_update_date              in 	  date     default null
  ,p_last_updated_by               in 	  number   default null
  ,p_last_update_login             in 	  number   default null
  ,p_created_by                    in 	  number   default null
  ,p_creation_date                 in 	  date     default null
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
  ,p_information_category          in     varchar2 default null
  ,p_information1 	           in     varchar2 default null
  ,p_information2 	           in     varchar2 default null
  ,p_information3 	           in     varchar2 default null
  ,p_information4 	           in     varchar2 default null
  ,p_information5 	           in     varchar2 default null
  ,p_information6 	           in     varchar2 default null
  ,p_information7 	           in     varchar2 default null
  ,p_information8 	           in     varchar2 default null
  ,p_information9 	           in     varchar2 default null
  ,p_information10 	           in     varchar2 default null
  ,p_information11 	           in     varchar2 default null
  ,p_information12 	           in     varchar2 default null
  ,p_information13 	           in     varchar2 default null
  ,p_information14 	           in     varchar2 default null
  ,p_information15 	           in     varchar2 default null
  ,p_information16 	           in     varchar2 default null
  ,p_information17 	           in     varchar2 default null
  ,p_information18 	           in     varchar2 default null
  ,p_information19 	           in     varchar2 default null
  ,p_information20 	           in     varchar2 default null
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
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_concat_segments               in     varchar2 default null
  ,p_short_name			   in     varchar2 default null
  ,p_grade_id                      in     number
  ,p_grade_definition_id           in out nocopy number
  ,p_interface_code                in     varchar2
  ) is
begin

g_interface_code := nvl(p_interface_code,'PQP_RIW_GRADE_INTF');
g_grade_rec.business_group_id             :=  p_business_group_id;
g_grade_rec.date_from                     :=  p_date_from;
g_grade_rec.sequence			   :=	p_sequence;
g_grade_rec.effective_date		   :=  p_effective_date;
g_grade_rec.date_to                       :=  p_date_to;
g_grade_rec.request_id			   := 	p_request_id;
g_grade_rec.program_application_id        := 	p_program_application_id;
g_grade_rec.program_id                    := 	p_program_id;
g_grade_rec.program_update_date           := 	p_program_update_date;
g_grade_rec.last_update_date              := 	p_last_update_date;
g_grade_rec.last_updated_by               := 	p_last_updated_by;
g_grade_rec.last_update_login             := 	p_last_update_login;
g_grade_rec.created_by                    := 	p_created_by;
g_grade_rec.creation_date                 := 	p_creation_date;
g_grade_rec.attribute_category            :=  p_attribute_category;
g_grade_rec.attribute1                    :=  p_attribute1;
g_grade_rec.attribute2                    :=  p_attribute2;
g_grade_rec.attribute3                    :=  p_attribute3;
g_grade_rec.attribute4                    :=  p_attribute4;
g_grade_rec.attribute5                    :=  p_attribute5;
g_grade_rec.attribute6                    :=  p_attribute6;
g_grade_rec.attribute7                    :=  p_attribute7;
g_grade_rec.attribute8                    :=  p_attribute8;
g_grade_rec.attribute9                    :=  p_attribute9;
g_grade_rec.attribute10                   :=  p_attribute10;
g_grade_rec.attribute11                   :=  p_attribute11;
g_grade_rec.attribute12                   :=  p_attribute12;
g_grade_rec.attribute13                   :=  p_attribute13;
g_grade_rec.attribute14                   :=  p_attribute14;
g_grade_rec.attribute15                   :=  p_attribute15;
g_grade_rec.attribute16                   :=  p_attribute16;
g_grade_rec.attribute17                   :=  p_attribute17;
g_grade_rec.attribute18                   :=  p_attribute18;
g_grade_rec.attribute19                   :=  p_attribute19;
g_grade_rec.attribute20                   :=  p_attribute20;
g_grade_rec.information_category          :=  p_information_category;
g_grade_rec.information1 	           :=  p_information1;
g_grade_rec.information2 	           :=  p_information2;
g_grade_rec.information3 	           :=  p_information3;
g_grade_rec.information4 	           :=  p_information4;
g_grade_rec.information5 	           :=  p_information5;
g_grade_rec.information6 	           :=  p_information6;
g_grade_rec.information7 	           :=  p_information7;
g_grade_rec.information8 	           :=  p_information8;
g_grade_rec.information9 	           :=  p_information9;
g_grade_rec.information10 	           :=  p_information10;
g_grade_rec.information11 	           :=  p_information11;
g_grade_rec.information12 	           :=  p_information12;
g_grade_rec.information13 	           :=  p_information13;
g_grade_rec.information14 	           :=  p_information14;
g_grade_rec.information15 	           :=  p_information15;
g_grade_rec.information16 	           :=  p_information16;
g_grade_rec.information17 	           :=  p_information17;
g_grade_rec.information18 	           :=  p_information18;
g_grade_rec.information19 	           :=  p_information19;
g_grade_rec.information20 	           :=  p_information20;
g_grade_rec.segment1                      :=  p_segment1;
g_grade_rec.segment2                      :=  p_segment2;
g_grade_rec.segment3                      :=  p_segment3;
g_grade_rec.segment4                      :=  p_segment4;
g_grade_rec.segment5                      :=  p_segment5;
g_grade_rec.segment6                      :=  p_segment6;
g_grade_rec.segment7                      :=  p_segment7;
g_grade_rec.segment8                      :=  p_segment8;
g_grade_rec.segment9                      :=  p_segment9;
g_grade_rec.segment10                     :=  p_segment10;
g_grade_rec.segment11                     :=  p_segment11;
g_grade_rec.segment12                     :=  p_segment12;
g_grade_rec.segment13                     :=  p_segment13;
g_grade_rec.segment14                     :=  p_segment14;
g_grade_rec.segment15                     :=  p_segment15;
g_grade_rec.segment16                     :=  p_segment16;
g_grade_rec.segment17                     :=  p_segment17;
g_grade_rec.segment18                     :=  p_segment18;
g_grade_rec.segment19                     :=  p_segment19;
g_grade_rec.segment20                     :=  p_segment20;
g_grade_rec.segment21                     :=  p_segment21;
g_grade_rec.segment22                     :=  p_segment22;
g_grade_rec.segment23                     :=  p_segment23;
g_grade_rec.segment24                     :=  p_segment24;
g_grade_rec.segment25                     :=  p_segment25;
g_grade_rec.segment26                     :=  p_segment26;
g_grade_rec.segment27                     :=  p_segment27;
g_grade_rec.segment28                     :=  p_segment28;
g_grade_rec.segment29                     :=  p_segment29;
g_grade_rec.segment30                     :=  p_segment30;
g_grade_rec.language_code                 :=  p_language_code;
g_grade_rec.concat_segments               :=  p_concat_segments;
g_grade_rec.short_name			   :=  p_short_name;
g_grade_rec.grade_id                      :=  p_grade_id;
g_grade_rec.grade_definition_id           :=  p_grade_definition_id;

end Set_Cur_Grade_record_Values;




procedure check_grade_exists
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
    ,p_grade_id                        out nocopy number
    ,p_grade_definition_id           in out nocopy number
    ) is

  l_proc    varchar2(72) := g_package ||'.check_grade_exists';
  l_name                    per_jobs.name%TYPE;
  l_flex_num                number;
cursor isdel is
       select pbg.grade_structure
       from per_business_groups_perf pbg
       where pbg.business_group_id = p_business_group_id;

begin
  hr_utility.trace('entering ' || l_proc);
  --
  -- check that flex structure is valid
  --
  open isdel;
  fetch isdel into l_flex_num;
  if isdel%notfound
  then
     close isdel;
     --
     -- the flex structure has not been found
     --
     hr_utility.set_message(801, 'HR_6039_ALL_CANT_GET_FFIELD');
     hr_utility.raise_error;
  end if;
  close isdel;

     hr_kflex_utility.ins_or_sel_keyflex_comb
       (p_appl_short_name       => 'PER'
       ,p_flex_code             => 'GRD'
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
       ,p_ccid                  => p_grade_definition_id
       ,p_concat_segments_out   => l_name
       );

    select grade_id into p_grade_id
    from per_grades
    where business_group_id = p_business_group_id
    and   name = l_name;

Exception
When others then
p_grade_id := null;
  end check_grade_exists;





procedure insupd_grade
  (p_business_group_id             in     number
  ,p_date_from                     in     date
  ,p_sequence			   in	  number
  ,p_effective_date		   in     date     default null
  ,p_date_to                       in     date     default null
  ,p_request_id			   in 	  number   default null
  ,p_program_application_id        in 	  number   default null
  ,p_program_id                    in 	  number   default null
  ,p_program_update_date           in 	  date     default null
  ,p_last_update_date              in 	  date     default null
  ,p_last_updated_by               in 	  number   default null
  ,p_last_update_login             in 	  number   default null
  ,p_created_by                    in 	  number   default null
  ,p_creation_date                 in 	  date     default null
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
  ,p_information_category          in     varchar2 default null
  ,p_information1 	           in     varchar2 default null
  ,p_information2 	           in     varchar2 default null
  ,p_information3 	           in     varchar2 default null
  ,p_information4 	           in     varchar2 default null
  ,p_information5 	           in     varchar2 default null
  ,p_information6 	           in     varchar2 default null
  ,p_information7 	           in     varchar2 default null
  ,p_information8 	           in     varchar2 default null
  ,p_information9 	           in     varchar2 default null
  ,p_information10 	           in     varchar2 default null
  ,p_information11 	           in     varchar2 default null
  ,p_information12 	           in     varchar2 default null
  ,p_information13 	           in     varchar2 default null
  ,p_information14 	           in     varchar2 default null
  ,p_information15 	           in     varchar2 default null
  ,p_information16 	           in     varchar2 default null
  ,p_information17 	           in     varchar2 default null
  ,p_information18 	           in     varchar2 default null
  ,p_information19 	           in     varchar2 default null
  ,p_information20 	           in     varchar2 default null
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
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_concat_segments               in     varchar2 default null
  ,p_short_name			   in     varchar2 default null
  ,p_grade_id                      in     number
  ,p_grade_definition_id           in out nocopy number
  ,P_CRT_UPD			  in 	 varchar2   default null
  ,p_migration_flag                in     varchar2
  ,p_interface_code                in     varchar2
   ) is


   l_grade_rec grade_record;
   l_proc    varchar2(72) := g_package ||'.insupd_grade';
   l_validate boolean := false;
   l_grade_id                   per_grades.grade_id%TYPE;
   l_grade_definition_id        per_grades.grade_definition_id%TYPE                      := p_grade_definition_id;
   l_name                     per_grades.name%TYPE;
   l_object_version_number    per_grades.object_version_number%TYPE;
 	 l_concat_segments					varchar2(30);
   l_error_msg              varchar2(4000);
   l_create_flag    number(2) := 1;
   e_upl_not_allowed exception; -- when mode is 'View Only'
   e_crt_not_allowed exception; -- when mode is 'Update Only'
   g_upl_err_msg varchar2(100) := 'Upload NOT allowed.';
   g_crt_err_msg varchar2(100) := 'Creating NOT allowed.';
   l_obj_ver_num    number(3);

  Begin

  check_grade_exists
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
    ,l_grade_id
    ,l_grade_definition_id
    );
  if p_migration_flag = 'Y' or p_grade_id is null then
      if l_grade_id is not null then
        l_create_flag := 2; --$ Update Mode
      else
        l_create_flag := 1; --$ Create Mode
      end if;
  elsif p_grade_id is not null then
      if l_grade_id is null then
        l_grade_id := p_grade_id;
      end if;
      l_create_flag := 2; --$ update Mode
  end if;

  if (P_CRT_UPD = 'D') then
   raise e_upl_not_allowed;  -- View only flag is enabled but Trying to Upload
  end if;
  if (P_CRT_UPD = 'U' and l_create_flag = 1) then
   raise e_crt_not_allowed;  -- Update only flag is enabled but Trying to Create
  end if;

  set_cur_grade_record_values
  (p_business_group_id             =>  p_business_group_id
  ,p_date_from                     =>  p_date_from
  ,p_sequence			   =>	p_sequence
  ,p_effective_date		   =>  p_effective_date
  ,p_date_to                       =>  p_date_to
  ,p_request_id			   => 	p_request_id
  ,p_program_application_id        => 	p_program_application_id
  ,p_program_id                    => 	p_program_id
  ,p_program_update_date           => 	p_program_update_date
  ,p_last_update_date              => 	p_last_update_date
  ,p_last_updated_by               => 	p_last_updated_by
  ,p_last_update_login             => 	p_last_update_login
  ,p_created_by                    => 	p_created_by
  ,p_creation_date                 => 	p_creation_date
  ,p_attribute_category            =>  p_attribute_category
  ,p_attribute1                    =>  p_attribute1
  ,p_attribute2                    =>  p_attribute2
  ,p_attribute3                    =>  p_attribute3
  ,p_attribute4                    =>  p_attribute4
  ,p_attribute5                    =>  p_attribute5
  ,p_attribute6                    =>  p_attribute6
  ,p_attribute7                    =>  p_attribute7
  ,p_attribute8                    =>  p_attribute8
  ,p_attribute9                    =>  p_attribute9
  ,p_attribute10                   =>  p_attribute10
  ,p_attribute11                   =>  p_attribute11
  ,p_attribute12                   =>  p_attribute12
  ,p_attribute13                   =>  p_attribute13
  ,p_attribute14                   =>  p_attribute14
  ,p_attribute15                   =>  p_attribute15
  ,p_attribute16                   =>  p_attribute16
  ,p_attribute17                   =>  p_attribute17
  ,p_attribute18                   =>  p_attribute18
  ,p_attribute19                   =>  p_attribute19
  ,p_attribute20                   =>  p_attribute20
  ,p_information_category          =>  p_information_category
  ,p_information1 	           =>  p_information1
  ,p_information2 	           =>  p_information2
  ,p_information3 	           =>  p_information3
  ,p_information4 	           =>  p_information4
  ,p_information5 	           =>  p_information5
  ,p_information6 	           =>  p_information6
  ,p_information7 	           =>  p_information7
  ,p_information8 	           =>  p_information8
  ,p_information9 	           =>  p_information9
  ,p_information10 	           =>  p_information10
  ,p_information11 	           =>  p_information11
  ,p_information12 	           =>  p_information12
  ,p_information13 	           =>  p_information13
  ,p_information14 	           =>  p_information14
  ,p_information15 	           =>  p_information15
  ,p_information16 	           =>  p_information16
  ,p_information17 	           =>  p_information17
  ,p_information18 	           =>  p_information18
  ,p_information19 	           =>  p_information19
  ,p_information20 	           =>  p_information20
  ,p_segment1                      =>  p_segment1
  ,p_segment2                      =>  p_segment2
  ,p_segment3                      =>  p_segment3
  ,p_segment4                      =>  p_segment4
  ,p_segment5                      =>  p_segment5
  ,p_segment6                      =>  p_segment6
  ,p_segment7                      =>  p_segment7
  ,p_segment8                      =>  p_segment8
  ,p_segment9                      =>  p_segment9
  ,p_segment10                     =>  p_segment10
  ,p_segment11                     =>  p_segment11
  ,p_segment12                     =>  p_segment12
  ,p_segment13                     =>  p_segment13
  ,p_segment14                     =>  p_segment14
  ,p_segment15                     =>  p_segment15
  ,p_segment16                     =>  p_segment16
  ,p_segment17                     =>  p_segment17
  ,p_segment18                     =>  p_segment18
  ,p_segment19                     =>  p_segment19
  ,p_segment20                     =>  p_segment20
  ,p_segment21                     =>  p_segment21
  ,p_segment22                     =>  p_segment22
  ,p_segment23                     =>  p_segment23
  ,p_segment24                     =>  p_segment24
  ,p_segment25                     =>  p_segment25
  ,p_segment26                     =>  p_segment26
  ,p_segment27                     =>  p_segment27
  ,p_segment28                     =>  p_segment28
  ,p_segment29                     =>  p_segment29
  ,p_segment30                     =>  p_segment30
  ,p_language_code                 =>  p_language_code
  ,p_concat_segments               =>  p_concat_segments
  ,p_short_name			               =>  p_short_name
  ,p_grade_id                      =>  l_grade_id
  ,p_grade_definition_id           =>  p_grade_definition_id
  ,p_interface_code                =>  p_interface_code
  );



     if l_create_flag = 1 then
     l_grade_definition_id := null;
     HR_GRADE_API.CREATE_GRADE
    (p_validate                => l_validate
    ,p_business_group_id       => p_business_group_id
    ,p_date_from               => p_date_from
    ,p_sequence		       => p_sequence
    ,p_effective_date	       => p_effective_date
    ,p_date_to                 => p_date_to
    ,p_request_id	       => p_request_id
    ,p_program_application_id  => p_program_application_id
    ,p_program_id              => p_program_id
    ,p_program_update_date     => p_program_update_date
    ,p_last_update_date        => p_last_update_date
    ,p_last_updated_by         => p_last_updated_by
    ,p_last_update_login       => p_last_update_login
    ,p_created_by              => p_created_by
    ,p_creation_date           => p_creation_date
    ,p_attribute_category      => p_attribute_category
    ,p_attribute1              => p_attribute1
    ,p_attribute2              => p_attribute2
    ,p_attribute3              => p_attribute3
    ,p_attribute4              => p_attribute4
    ,p_attribute5              => p_attribute5
    ,p_attribute6              => p_attribute6
    ,p_attribute7              => p_attribute7
    ,p_attribute8              => p_attribute8
    ,p_attribute9              => p_attribute9
    ,p_attribute10             => p_attribute10
    ,p_attribute11             => p_attribute11
    ,p_attribute12             => p_attribute12
    ,p_attribute13             => p_attribute13
    ,p_attribute14             => p_attribute14
    ,p_attribute15             => p_attribute15
    ,p_attribute16             => p_attribute16
    ,p_attribute17             => p_attribute17
    ,p_attribute18             => p_attribute18
    ,p_attribute19             => p_attribute19
    ,p_attribute20             => p_attribute20
    ,p_information_category    => p_information_category
    ,p_information1 	       => p_information1
    ,p_information2 	       => p_information2
    ,p_information3 	       => p_information3
    ,p_information4 	       => p_information4
    ,p_information5 	       => p_information5
    ,p_information6 	       => p_information6
    ,p_information7 	       => p_information7
    ,p_information8 	       => p_information8
    ,p_information9 	       => p_information9
    ,p_information10 	       => p_information10
    ,p_information11 	       => p_information11
    ,p_information12 	       => p_information12
    ,p_information13 	       => p_information13
    ,p_information14 	       => p_information14
    ,p_information15 	       => p_information15
    ,p_information16 	       => p_information16
    ,p_information17 	       => p_information17
    ,p_information18 	       => p_information18
    ,p_information19 	       => p_information19
    ,p_information20 	       => p_information20
    ,p_segment1                => p_segment1
    ,p_segment2                => p_segment2
    ,p_segment3                => p_segment3
    ,p_segment4                => p_segment4
    ,p_segment5                => p_segment5
    ,p_segment6                => p_segment6
    ,p_segment7                => p_segment7
    ,p_segment8                => p_segment8
    ,p_segment9                => p_segment9
    ,p_segment10               => p_segment10
    ,p_segment11               => p_segment11
    ,p_segment12               => p_segment12
    ,p_segment13               => p_segment13
    ,p_segment14               => p_segment14
    ,p_segment15               => p_segment15
    ,p_segment16               => p_segment16
    ,p_segment17               => p_segment17
    ,p_segment18               => p_segment18
    ,p_segment19               => p_segment19
    ,p_segment20               => p_segment20
    ,p_segment21               => p_segment21
    ,p_segment22               => p_segment22
    ,p_segment23               => p_segment23
    ,p_segment24               => p_segment24
    ,p_segment25               => p_segment25
    ,p_segment26               => p_segment26
    ,p_segment27               => p_segment27
    ,p_segment28               => p_segment28
    ,p_segment29               => p_segment29
    ,p_segment30               => p_segment30
    ,p_language_code           => p_language_code
    ,p_concat_segments         => p_concat_segments
    ,p_short_name	       => p_short_name
    ,p_grade_id                => l_grade_id
    ,p_object_version_number   => l_object_version_number
    ,p_grade_definition_id     => l_grade_definition_id
    ,p_name		      					 => l_name);
    end if;

if l_create_flag = 2 then
  l_grade_rec := Get_grade_Record_Values(p_interface_code);

  l_grade_definition_id := null;
  select object_version_number into l_obj_ver_num from per_grades
    where GRADE_ID=l_grade_rec.grade_id;
  HR_GRADE_API.UPDATE_GRADE
    (p_validate               => l_validate
    ,p_grade_id               => l_grade_rec.grade_id
    ,p_sequence               => l_grade_rec.sequence
    ,p_date_from              => l_grade_rec.date_from
    ,p_effective_date         => l_grade_rec.effective_date
    ,p_date_to                => l_grade_rec.date_to
    ,p_request_id             => l_grade_rec.request_id
    ,p_program_application_id => l_grade_rec.program_application_id
    ,p_program_id             => l_grade_rec.program_id
    ,p_program_update_date    => l_grade_rec.program_update_date
    ,p_attribute_category     => l_grade_rec.attribute_category
    ,p_attribute1             => l_grade_rec.attribute1
    ,p_attribute2             => l_grade_rec.attribute2
    ,p_attribute3             => l_grade_rec.attribute3
    ,p_attribute4             => l_grade_rec.attribute4
    ,p_attribute5             => l_grade_rec.attribute5
    ,p_attribute6             => l_grade_rec.attribute6
    ,p_attribute7             => l_grade_rec.attribute7
    ,p_attribute8             => l_grade_rec.attribute8
    ,p_attribute9             => l_grade_rec.attribute9
    ,p_attribute10            => l_grade_rec.attribute10
    ,p_attribute11            => l_grade_rec.attribute11
    ,p_attribute12            => l_grade_rec.attribute12
    ,p_attribute13            => l_grade_rec.attribute13
    ,p_attribute14            => l_grade_rec.attribute14
    ,p_attribute15            => l_grade_rec.attribute15
    ,p_attribute16            => l_grade_rec.attribute16
    ,p_attribute17            => l_grade_rec.attribute17
    ,p_attribute18            => l_grade_rec.attribute18
    ,p_attribute19            => l_grade_rec.attribute19
    ,p_attribute20            => l_grade_rec.attribute20
    ,p_information_category   => l_grade_rec.information_category
    ,p_information1           => l_grade_rec.information1
    ,p_information2           => l_grade_rec.information2
    ,p_information3           => l_grade_rec.information3
    ,p_information4           => l_grade_rec.information4
    ,p_information5           => l_grade_rec.information5
    ,p_information6           => l_grade_rec.information6
    ,p_information7           => l_grade_rec.information7
    ,p_information8           => l_grade_rec.information8
    ,p_information9           => l_grade_rec.information9
    ,p_information10          => l_grade_rec.information10
    ,p_information11          => l_grade_rec.information11
    ,p_information12          => l_grade_rec.information12
    ,p_information13          => l_grade_rec.information13
    ,p_information14          => l_grade_rec.information14
    ,p_information15          => l_grade_rec.information15
    ,p_information16          => l_grade_rec.information16
    ,p_information17          => l_grade_rec.information17
    ,p_information18          => l_grade_rec.information18
    ,p_information19          => l_grade_rec.information19
    ,p_information20          => l_grade_rec.information20
    ,p_last_update_date       => l_grade_rec.last_update_date
    ,p_last_updated_by        => l_grade_rec.last_updated_by
    ,p_last_update_login      => l_grade_rec.last_update_login
    ,p_created_by             => l_grade_rec.created_by
    ,p_creation_date          => l_grade_rec.creation_date
    ,p_segment1               => l_grade_rec.segment1
    ,p_segment2               => l_grade_rec.segment2
    ,p_segment3               => l_grade_rec.segment3
    ,p_segment4               => l_grade_rec.segment4
    ,p_segment5               => l_grade_rec.segment5
    ,p_segment6               => l_grade_rec.segment6
    ,p_segment7               => l_grade_rec.segment7
    ,p_segment8               => l_grade_rec.segment8
    ,p_segment9               => l_grade_rec.segment9
    ,p_segment10              => l_grade_rec.segment10
    ,p_segment11              => l_grade_rec.segment11
    ,p_segment12              => l_grade_rec.segment12
    ,p_segment13              => l_grade_rec.segment13
    ,p_segment14              => l_grade_rec.segment14
    ,p_segment15              => l_grade_rec.segment15
    ,p_segment16              => l_grade_rec.segment16
    ,p_segment17              => l_grade_rec.segment17
    ,p_segment18              => l_grade_rec.segment18
    ,p_segment19              => l_grade_rec.segment19
    ,p_segment20              => l_grade_rec.segment20
    ,p_segment21              => l_grade_rec.segment21
    ,p_segment22              => l_grade_rec.segment22
    ,p_segment23              => l_grade_rec.segment23
    ,p_segment24              => l_grade_rec.segment24
    ,p_segment25              => l_grade_rec.segment25
    ,p_segment26              => l_grade_rec.segment26
    ,p_segment27              => l_grade_rec.segment27
    ,p_segment28              => l_grade_rec.segment28
    ,p_segment29              => l_grade_rec.segment29
    ,p_segment30              => l_grade_rec.segment30
    ,p_language_code          => l_grade_rec.language_code
    ,p_short_name             => l_grade_rec.short_name
    ,p_concat_segments        => l_concat_segments
    ,p_name                   => l_name
    ,p_object_version_number  => l_obj_ver_num
    ,p_grade_definition_id    => l_grade_definition_id);

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
   hr_utility.set_location('SQLCODE :' || SQLCODE,90);
   hr_utility.set_location('SQLERRM :' || SQLERRM,90);
   hr_utility.set_location(' Leaving:' || l_proc,50);
   hr_utility.raise_error;


end INSUPD_GRADE;
end PQP_RIW_GRADE_WRAPPER;

/
