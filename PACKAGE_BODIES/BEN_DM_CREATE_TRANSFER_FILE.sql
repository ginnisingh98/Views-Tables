--------------------------------------------------------
--  DDL for Package Body BEN_DM_CREATE_TRANSFER_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_CREATE_TRANSFER_FILE" AS
/* $Header: benfdmcrfl.pkb 120.0 2006/06/13 14:54:30 nkkrishn noship $ */

g_package   varchar2(60) := 'ben_dm_create_transfer_file';

procedure main
(
 p_dir_name             in   varchar2,
 p_file_name            in   varchar2,
 p_delimiter            in   varchar2
) is

cursor c_inp_file is
select 'BEN_DM_INPUT_FILE'||p_delimiter||
       input_file_id||p_delimiter||
       source_business_group_name||p_delimiter||
       source_national_identifier||p_delimiter||
       source_person_id||p_delimiter||
       target_person_id||p_delimiter||
       target_business_group_name||p_delimiter||
       target_national_identifier||p_delimiter||
       group_order||p_delimiter||
       person_type||p_delimiter||
       data_source||p_delimiter||
       status||p_delimiter
  from ben_dm_input_file;
l_inp_rec c_inp_file%rowtype;

cursor c_resolve_map is
select 'BEN_DM_RESOLVE_MAPPINGS'||p_delimiter||
       resolve_mapping_id||p_delimiter||
       table_name||p_delimiter||
       column_name||p_delimiter||
       source_id||p_delimiter||
       source_key||p_delimiter||
       target_id||p_delimiter||
       business_group_name||p_delimiter||
       mapping_type||p_delimiter||
       resolve_mapping_id1||p_delimiter||
       resolve_mapping_id2||p_delimiter||
       resolve_mapping_id3||p_delimiter||
       resolve_mapping_id4||p_delimiter||
       resolve_mapping_id5||p_delimiter||
       resolve_mapping_id6||p_delimiter||
       resolve_mapping_id7||p_delimiter
  from ben_dm_resolve_mappings;

l_proc             varchar2(255) := g_package||'main';
l_file_handle      utl_file.file_type;
l_max_ext          number := 32767;
l_text             varchar2(32767);

begin
  ben_dm_utility.message('ROUT','entry:'||l_proc, 5);
  --
  -- get the file handle
  --
  l_file_handle := utl_file.fopen(p_dir_name,p_file_name,'w',l_max_ext);
  --
  open c_inp_file;
  loop
     fetch c_inp_file into l_text;
     if c_inp_file%notfound then
        exit;
     end if;

     utl_file.put_line(l_file_handle,l_text);

  end loop;
  close c_inp_file;

  open c_resolve_map;
  loop
     fetch c_resolve_map into l_text;
     if c_resolve_map%notfound then
        exit;
     end if;

     utl_file.put_line(l_file_handle,l_text);

  end loop;
  close c_resolve_map;

  ben_dm_utility.message('ROUT','exit:'||l_proc, 5);

exception
    when utl_file.invalid_path then
        fnd_message.set_name('BEN', 'BEN_91874_EXT_DRCTRY_ERR'); --9999
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.invalid_mode then
        fnd_message.set_name('BEN', 'BEN_92249_UTL_INVLD_MODE');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.invalid_filehandle then
        fnd_message.set_name('BEN', 'BEN_92250_UTL_INVLD_FILEHANDLE');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.invalid_operation then
        fnd_message.set_name('BEN', 'BEN_92251_UTL_INVLD_OPER');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.read_error then
        fnd_message.set_name('BEN', 'BEN_92252_UTL_READ_ERROR');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.internal_error then
        fnd_message.set_name('BEN', 'BEN_92253_UTL_INTRNL_ERROR');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error;
    --
    when utl_file.invalid_maxlinesize  then
        fnd_message.set_name ('BEN' ,'BEN_92492_UTL_LINESIZE_ERROR');
        fnd_file.put_line(fnd_file.log , fnd_message.get );
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        fnd_message.raise_error ;
    --
    when others then
        if utl_file.is_open(l_file_handle) then
           utl_file.fclose(l_file_handle);
        end if;
        raise;

end main;

end ben_dm_create_transfer_file;

/
