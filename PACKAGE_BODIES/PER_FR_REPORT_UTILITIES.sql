--------------------------------------------------------
--  DDL for Package Body PER_FR_REPORT_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_REPORT_UTILITIES" as
/* $Header: pefrutil.pkb 120.2 2005/10/03 02:36 sbairagi noship $ */
function get_job_names (p_job_id in number
                       , p_job_definition_id in number
		       , p_report_name in varchar2 default null)
		       return varchar2 is
Type segment_values is ref cursor;
csr_segment_values segment_values;
  cursor get_segments is
  select fsav.application_column_name,
         fifst.concatenated_segment_delimiter delimeter
    from fnd_segment_attribute_values fsav,
         fnd_id_flex_segments fifs,
         per_job_definitions pjd,
         per_jobs pj,
         fnd_id_flex_structures fifst
   where pj.job_id = p_job_id
     and pj.job_definition_id = p_job_definition_id
     and pjd.job_definition_id = pj.job_definition_id
     and fsav.id_flex_code = 'JOB'
     and fsav.id_flex_num = pjd.id_flex_num
     and fsav.attribute_value = 'Y'
     and fsav.segment_attribute_type = 'FR_REPORTING'
     and fifs.id_flex_code = fsav.id_flex_code
     and fifs.id_flex_num = fsav.id_flex_num
     and fifs.application_id = fsav.application_id
     and fifs.application_column_name = fsav.application_column_name
     and fifst.id_flex_code = fsav.id_flex_code
     and fifst.id_flex_num = pjd.id_flex_num
     and fifst.application_id = fsav.application_id
order by fifs.segment_num;
l_column_name   varchar2(200);
l_select        varchar2(50);
l_resultant     per_jobs_tl.name%type;
l_sql_statement varchar2(1000);
l_delimeter     fnd_id_flex_structures.concatenated_segment_delimiter%type;
l_proc          varchar2(400);
BEGIN
l_proc := 'pay_fr_report_utilities.get_job_names';
hr_utility.set_location('Entering '||l_proc, 10);
l_column_name   := NULL;
l_select        := NULL;
hr_utility.set_location('Obtaining segment names '||l_proc, 20);
open get_segments;
loop
   fetch get_segments into l_select, l_delimeter;
   exit when get_segments%notfound;
   if (p_report_name is not null and p_report_name = 'DADS') then
      l_delimeter := '.';
   end if;
   l_column_name := l_column_name ||
                    'nvl(' || l_select ||', ''_NULL_'')'||
                    ' || '''|| l_delimeter||''' ||';
end loop;
hr_utility.set_location('Obtaining segment values '||l_proc, 30);
if l_column_name is not null then
   l_column_name := substr(l_column_name, 1, length(l_column_name) - 10);
   open csr_segment_values for 'select '||l_column_name||
                                ' from per_job_definitions
                                 where job_definition_id = '||p_job_definition_id;
   fetch csr_segment_values into l_resultant;
   close csr_segment_values;
   l_resultant := replace(l_resultant, l_delimeter||'_NULL_', NULL);
   -- to replace, when _NULL_ comes at the first segment
   l_resultant := replace(l_resultant, '_NULL_'||l_delimeter, NULL);
   /* 4428595 Commented because, substr is used only for RUP and it is already
              present in rdf file */
--   return substr(l_resultant, 1, 20);
   return l_resultant;
else
   hr_utility.set_location('No segment names '||l_proc, 40);
   return null;
end if;
hr_utility.set_location('Leaving '||l_proc, 50);
exception
when others then
hr_utility.set_location('Errored out in '||l_proc, 50);
hr_utility.set_location('Error is '||sqlerrm, 60);
end get_job_names;
end per_fr_report_utilities;

/
