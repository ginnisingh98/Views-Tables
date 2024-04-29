--------------------------------------------------------
--  DDL for Package Body BEN_DM_INPUT_FILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_INPUT_FILE_PKG" as
/* $Header: benfdmdmfile.pkb 120.0 2006/05/04 04:48:06 nkkrishn noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
-- Package Globals
--
type numTab  is table of number(15) index by binary_integer;
type charTab is table of varchar2(80) index by binary_integer;
Type inpRec is Record
(source_bg           varchar2(80),
 source_ssn          varchar2(80),
 source_person_id    number,
 target_bg           varchar2(80),
 target_ssn          varchar2(80),
 group_order         number,
 person_type         varchar2(1),
 data_source         varchar2(1),
 process_flag        varchar2(1));
Type inpTab is Table of inpRec index by binary_integer;
--
Type contactRec is Record
(person_id           number,
 ssn                 varchar2(80),
 ind                 number);
Type contactTab is Table of contactRec index by binary_integer;
--
g_debug          boolean := hr_utility.debug_enabled;
g_package        varchar2(33) := 'ben_dm_input_file.';
g_missing_fields exception;
g_invalid_record exception;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< split_line>------------------------------|
-- ----------------------------------------------------------------------------
--
function split_line(p_text  varchar2,p_delimiter varchar2,p_min_fields number)
return charTab is

l_fields    charTab;
l_start_pos number := 1;
l_end_pos   number;
l_counter   number :=1;

begin

  loop
    l_end_pos := nvl(instr(p_text,p_delimiter,1,l_counter),0);
    if l_end_pos =0 and l_counter =1 then
       l_fields(l_counter) := p_text;
       l_start_pos := nvl(length(p_text),0)+1;
    elsif l_end_pos =0 then
       l_fields(l_counter) := substr(p_text,l_start_pos);
       l_start_pos := nvl(length(p_text),0)+1;
    elsif l_end_pos > 0 and l_start_pos = l_end_pos then
       l_fields(l_counter) := null;
       l_start_pos := l_end_pos +1;
    elsif l_end_pos > 0 and l_start_pos < l_end_pos then
       l_fields(l_counter) := substr(p_text,l_start_pos,l_end_pos-l_start_pos);
       l_start_pos := l_end_pos +1;
    end if;

    if l_start_pos >= nvl(length(p_text),0) then
       exit;
    end if;
    l_counter := l_counter +1;
  end loop;

  if l_fields.count < p_min_fields then
     for i in l_fields.count+1..p_min_fields
     loop
        l_fields(i) := null;
     end loop;
  end if;

  return l_fields;

exception
  when others then
    hr_utility.set_location('error encountered ',10);
end split_line;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< add_to_set>------------------------------|
-- ----------------------------------------------------------------------------
--
procedure add_to_set(p_text  varchar2,
                     p_collection in out nocopy charTab) is

begin

  for i in 1..p_collection.count
  loop

    if p_collection(i) = p_text then
       return;
    end if;

  end loop;
  p_collection(p_collection.count+1) := p_text;

end add_to_set;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< read_file>------------------------------|
-- ----------------------------------------------------------------------------
--
procedure read_file
(p_migration_data ben_dm_utility.r_migration_rec,
 p_delimiter      in varchar2 default ';'
) is

l_proc             varchar2(255) := g_package||'read_file';
l_file_handle      utl_file.file_type;
l_max_ext          number := 32767;
l_line_text        varchar2(32767);
l_line_count       number := 0;
l_group_order      number;
l_duplicate_rec    boolean;
l_fields           charTab;
l_inp_rec          inpTab;
l_inp_rec2         inpTab;
l_contact_rec      contactTab;
l_skip_count       number := 0;
l_migration_id     number := p_migration_data.migration_id;
l_file_name        varchar2(60) := p_migration_data.input_parameter_file_name;
l_dir_name         varchar2(60) := p_migration_data.input_parameter_file_path;
l_dummy            varchar2(1);

cursor c_chk_per(p_person_id             number,
                 p_national_identifier   varchar2,
                 p_name                  varchar2) is
select null
  from per_all_people_f per,
       per_business_groups bg
 where per.person_id = p_person_id
   and per.national_identifier = p_national_identifier
   and per.business_group_id = bg.business_group_id
   and bg.name = p_name;

cursor c_get_contact(p_person_id  number) is
select distinct
       per1.person_id,
       per1.national_identifier ssn,
       -1
  from per_all_people_f per1,
       per_contact_relationships pcr
 where pcr.person_id = p_person_id
   and per1.person_id = pcr.contact_person_id
   and per1.effective_start_date =
               (select min(per2.effective_start_date)
                  from per_all_people_f per2
                 where per2.person_id = per1.person_id);

begin
  hr_utility.set_location('Entering '||l_proc,5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'l_migration_id',
                             p_argument_value => l_migration_id);

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'l_file_name',
                             p_argument_value => l_file_name);

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'l_dir_name',
                             p_argument_value => l_dir_name);

  --
  -- get the file handle
  --
  l_file_handle := utl_file.fopen(l_dir_name,l_file_name,'r',l_max_ext);

  --
  -- fetch records from the file
  --
  loop
    --
    begin
    --
    utl_file.get_line(l_file_handle,l_line_text);
    l_line_count := l_line_count +1;
    l_fields := split_line(l_line_text,p_delimiter,5);

    l_inp_rec(l_line_count).source_bg        := rtrim(ltrim(l_fields(1)));
    l_inp_rec(l_line_count).source_ssn       := rtrim(ltrim(l_fields(2)));
    l_inp_rec(l_line_count).source_person_id := rtrim(ltrim(l_fields(3)));
    l_inp_rec(l_line_count).target_bg        := rtrim(ltrim(l_fields(4)));
    l_inp_rec(l_line_count).target_ssn       := rtrim(ltrim(l_fields(5)));
    l_inp_rec(l_line_count).data_source      := 'I';

    --
    -- check for required fields in the record
    --
    if (l_inp_rec(l_line_count).source_bg is null or
        l_inp_rec(l_line_count).target_bg is null or
        l_inp_rec(l_line_count).source_ssn is null or
        l_inp_rec(l_line_count).source_person_id is null
       ) then
       raise g_missing_fields;
    end if;

    --
    -- check if the fields have valid values
    --
    open c_chk_per(l_inp_rec(l_line_count).source_person_id,
                   l_inp_rec(l_line_count).source_ssn,
                   l_inp_rec(l_line_count).source_bg);
    fetch c_chk_per into l_dummy;
    if c_chk_per%notfound then
       close c_chk_per;
       raise g_invalid_record;
    end if;
    close c_chk_per;

    --
    exception
    --
    when no_data_found then
         --
         -- EOF reached
         --
         exit;
    end;
  end loop;
  --
  utl_file.fclose(l_file_handle);
  --
  for i in 1..l_inp_rec.count
  loop

    if l_inp_rec(i).group_order is null then
       --
       l_contact_rec.delete;
       l_group_order := null;
       --
       open c_get_contact(l_inp_rec(i).source_person_id);
       fetch c_get_contact bulk collect into l_contact_rec;
       close c_get_contact;
       --
       for j in 1..l_contact_rec.count
       loop
           for k in 1..l_inp_rec.count
           loop
             if l_inp_rec(k).source_person_id = l_contact_rec(j).person_id then
                if l_inp_rec(k).group_order is not null then
                   --
                   l_duplicate_rec := false;
                   --
                   for m in 1..l_inp_rec.count
                   loop
                      if l_inp_rec(m).group_order = l_inp_rec(k).group_order and
                         l_inp_rec(m).data_source = 'I' and
                         l_inp_rec(m).source_ssn = l_inp_rec(i).source_ssn and
                         (l_inp_rec(m).target_bg <> l_inp_rec(i).target_bg or
                          nvl(l_inp_rec(m).target_ssn,l_inp_rec(m).source_ssn) <> nvl(l_inp_rec(i).target_ssn,l_inp_rec(i).source_ssn)) then
                         l_duplicate_rec := true;
                         exit;
                      end if;
                   end loop;
                   --
                   if not l_duplicate_rec then
                      l_group_order := nvl(l_inp_rec(k).group_order,l_group_order);
                      l_contact_rec(j).ind := k;
                   end if;
                   --
                else
                   --
                   --There is a person record in the file for the dependent. not yet processed for group order
                   l_duplicate_rec := false;
                   --
                   for m in 1..l_inp_rec.count
                   loop
                      if -- l_inp_rec(m).group_order = l_inp_rec(k).group_order and
                         l_inp_rec(m).data_source = 'I' and
                         l_inp_rec(m).source_ssn = l_inp_rec(i).source_ssn and
                         (l_inp_rec(m).target_bg <> l_inp_rec(i).target_bg or
                          nvl(l_inp_rec(m).target_ssn,l_inp_rec(m).source_ssn) <> nvl(l_inp_rec(i).target_ssn,l_inp_rec(i).source_ssn)) then
                         l_duplicate_rec := true;
                         exit;
                      end if;
                   end loop;
                   --
                   if not l_duplicate_rec then
                      -- l_group_order := nvl(l_inp_rec(k).group_order,l_group_order);
                      l_contact_rec(j).ind := k;
                   end if;
                   --entry for the dependent.
                   --
                end if;
                exit;
             end if;
           end loop;
       end loop;
       -- Check if this person is already got created as dependent to another person. If so mark the dependent person status
       -- such that it won't be selected in the subsequent process.

       --
       if l_group_order is null then
          select ben_dm_group_order_s.nextval
            into l_group_order
            from dual;
       end if;

       l_inp_rec(i).group_order := l_group_order;

       for j in 1..l_contact_rec.count
       loop
         if l_contact_rec(j).ind <> -1 then
            l_inp_rec(l_contact_rec(j).ind).group_order := l_group_order;
         else
            l_line_count := l_inp_rec.count +1;
            l_inp_rec(l_line_count).source_bg        := l_inp_rec(i).source_bg;
            l_inp_rec(l_line_count).source_ssn       := l_contact_rec(j).ssn;
            l_inp_rec(l_line_count).source_person_id := l_contact_rec(j).person_id;
            l_inp_rec(l_line_count).target_bg        := l_inp_rec(i).target_bg;
            l_inp_rec(l_line_count).group_order      := l_group_order;
            l_inp_rec(l_line_count).data_source      := 'D';
            l_inp_rec(l_line_count).person_type      := 'D';

         end if;

       end loop;
    end if;


  end loop;
  --
  hr_utility.set_location('deleting existing records',10);
  --
  delete from ben_dm_input_file;
  --
  hr_utility.set_location('bulk inserting new records',10);
  --
  l_line_count := l_inp_rec.count;
  --
  -- skip groups that have one or more person records with null SSN
  --
  for i in 1..l_line_count
  loop
      --
      if l_inp_rec(i).process_flag = 'N' then
         null;
      else
         if l_inp_rec(i).source_ssn is null then
            l_group_order := l_inp_rec(i).group_order;
            for j in 1..l_line_count
            loop
               if l_group_order = l_inp_rec(j).group_order then
                  l_inp_rec(j).process_flag := 'N';
               end if;
            end loop;
         end if;
      end if;
      --
  end loop;
  --
  for i in 1..l_line_count
  loop
      if nvl(l_inp_rec(i).process_flag,'Y') <> 'N' then
         insert into ben_dm_input_file
         (input_file_id,
          status,
          source_business_group_name,
          source_national_identifier,
          source_person_id,
          target_business_group_name,
          target_national_identifier,
          group_order,
          person_type,
          data_source)
         values
         (ben_dm_input_file_s.nextval,
          'NS',
          l_inp_rec(i).source_bg,
          l_inp_rec(i).source_ssn,
          l_inp_rec(i).source_person_id,
          l_inp_rec(i).target_bg,
          l_inp_rec(i).target_ssn,
          l_inp_rec(i).group_order,
          nvl(l_inp_rec(i).person_type,'P'),
          l_inp_rec(i).data_source);
      end if;
  end loop;
  --
  --Check to remove the duplicate records from the ben_dm_input_file
  --There should be always only one record for the following record combination
  --   source_business_group_name
  --   source_national_identifier
  --   source_person_id
  --   target_national_identifier
  --   target_business_group_name
  --
  DELETE FROM ben_dm_input_file mas
      WHERE ROWID > ( SELECT min(rowid)
	                    FROM ben_dm_input_file chi
                       WHERE mas.source_business_group_name = chi.source_business_group_name
                         and mas.source_national_identifier = chi.source_national_identifier
                         and mas.source_person_id = chi.source_person_id
                         and mas.group_order = chi.group_order
                         and mas.target_business_group_name = chi.target_business_group_name
                         AND nvl(mas.target_national_identifier,mas.source_national_identifier) =
                             nvl(chi.target_national_identifier,chi.source_national_identifier)
                      ) ;
  --
  commit;
  --
  -- Report groups skipped
  --
  for i in 1..l_inp_rec.count
  loop
      if l_inp_rec(i).data_source = 'I' and
         l_inp_rec(i).process_flag = 'N' then

         l_skip_count := nvl(l_skip_count,0) +1;
         if l_skip_count = 1 then
            fnd_file.put_line(fnd_file.output,'Following records from the input file have been skipped because one or more of the dependents do not have an SSN');
         end if;
         fnd_file.put_line(fnd_file.output,
                           l_inp_rec(i).source_bg||p_delimiter||
                           l_inp_rec(i).source_ssn||p_delimiter||
                           l_inp_rec(i).source_person_id||p_delimiter||
                           l_inp_rec(i).target_bg||p_delimiter||
                           l_inp_rec(i).target_ssn);

      end if;

  end loop;

  hr_utility.set_location('Leaving '||l_proc,5);
exception
    when utl_file.invalid_path then
        rollback;
        fnd_message.set_name('BEN', 'BEN_91874_EXT_DRCTRY_ERR'); --9999
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.invalid_mode then
        rollback;
        fnd_message.set_name('BEN', 'BEN_92249_UTL_INVLD_MODE');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.invalid_filehandle then
        rollback;
        fnd_message.set_name('BEN', 'BEN_92250_UTL_INVLD_FILEHANDLE');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.invalid_operation then
        rollback;
        fnd_message.set_name('BEN', 'BEN_92251_UTL_INVLD_OPER');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.read_error then
        rollback;
        fnd_message.set_name('BEN', 'BEN_92252_UTL_READ_ERROR');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.internal_error then
        rollback;
        fnd_message.set_name('BEN', 'BEN_92253_UTL_INTRNL_ERROR');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.invalid_maxlinesize  then
        rollback;
        fnd_message.set_name ('BEN' ,'BEN_92492_UTL_LINESIZE_ERROR');
        fnd_file.put_line(fnd_file.log , fnd_message.get );
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error ;
    --
    when g_missing_fields then
        rollback;
        fnd_file.put_line(fnd_file.log , 'One ore more fields missing in this Record: '||substr(l_line_text,1,80));
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        raise;
    --
    when g_invalid_record then
        rollback;
        fnd_file.put_line(fnd_file.log , 'Invalid fields in this Record: '||substr(l_line_text,1,80));
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        raise;
    --
    when others then
        rollback;
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        raise;

end read_file;

end ben_dm_input_file_pkg;

/
