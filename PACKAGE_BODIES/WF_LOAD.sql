--------------------------------------------------------
--  DDL for Package Body WF_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_LOAD" as
/* $Header: wfldrb.pls 120.6 2006/08/24 07:03:06 hgandiko ship $ */

--
-- UPLOAD_ITEM_TYPE
--
procedure UPLOAD_ITEM_TYPE (
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_wf_selector in varchar2,
  x_read_role in varchar2,
  x_write_role in varchar2,
  x_execute_role in varchar2,
  x_persistence_type in varchar2,
  x_persistence_days in varchar2,
  x_level_error out NOCOPY number
) is
  row_id varchar2(30);
  protection_level number;
  customization_level number;
  conflict_name varchar2(8);
  l_persistence_days number;
  l_dname varchar2(80);
  n_dname varchar2(80);
  l_name  varchar2(8);
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  n_dname := x_display_name;
  begin
    select NAME, DISPLAY_NAME, NAME
    into conflict_name, l_dname, l_name
    from WF_ITEM_TYPES_VL
    where DISPLAY_NAME = x_display_name
    and NAME <> x_name;

    n_dname := substrb('@'||l_dname, 1, 80);

    -- this loop will make sure no duplicate with n_dname
    loop
      begin
        select NAME, DISPLAY_NAME
        into conflict_name, l_dname
        from WF_ITEM_TYPES_VL
        where DISPLAY_NAME = n_dname
        and NAME <> l_name;

        n_dname := substrb('@'||l_dname, 1, 80);

        if ( n_dname = l_dname ) then
          Wf_Core.Token('DNAME', x_display_name);
          Wf_Core.Token('NAME', x_name);
          Wf_Core.Token('CONFLICT_NAME', conflict_name);
          Wf_Core.Raise('WFSQL_UNIQUE_NAME');
          exit;
        end if;
      exception
        when no_data_found then
          exit;
      end;
    end loop;

    -- ### Not needed any more
    -- update the old data with the new display name
    -- begin
    --   update WF_ITEM_TYPES_TL
    --      set display_name = n_dname
    --    where NAME = l_name
    --      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    -- exception
    --   when others then
    --     Wf_Core.Token('TABLE', 'ITEM_TYPES_TL');
    --     Wf_Core.Token('VALUE', l_name);
    --     Wf_Core.Raise('WFSQL_UPDATE_FAIL');
    -- end;
  exception
    when no_data_found then
      null;
  end;

  l_persistence_days := to_number(x_persistence_days);

  -- Check protection level
  x_level_error := 0;
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL
    into protection_level, customization_level
    from WF_ITEM_TYPES_VL
    where NAME = x_name;

    if ((wf_core.upload_mode <> 'FORCE') and
        (protection_level < wf_core.session_level)) then
      x_level_error := 1;
      return;
    end if;

    if ((wf_core.upload_mode = 'UPGRADE') and
        (customization_level > wf_core.session_level)) then
      x_level_error := 2;
      return;
    end if;

    -- Update existing row
    Wf_Item_Types_Pkg.Update_Row(
      x_name => x_name,
      x_protect_level => x_protect_level,
      x_custom_level => x_custom_level,
      x_wf_selector => x_wf_selector,
      x_read_role => x_read_role,
      x_write_role => x_write_role,
      x_execute_role => x_execute_role,
      x_display_name => n_dname,
      x_description => x_description,
      x_persistence_type => x_persistence_type,
      x_persistence_days => l_persistence_days
    );
  exception
    when NO_DATA_FOUND then
      -- Check protection level for new row
      if ((wf_core.upload_mode <> 'FORCE') and
          (x_protect_level < wf_core.session_level)) then
        x_level_error := 4+1;
        return;
      end if;

      if ((wf_core.upload_mode = 'UPGRADE') and
          (x_custom_level > wf_core.session_level)) then
        x_level_error := 4+2;
        return;
      end if;

      -- Insert new row
      Wf_Item_Types_Pkg.Insert_Row(
         x_rowid => row_id,
         x_name => x_name,
         x_protect_level => x_protect_level,
         x_custom_level => x_custom_level,
         x_wf_selector => x_wf_selector,
         x_read_role => x_read_role,
         x_write_role => x_write_role,
         x_execute_role => x_execute_role,
         x_display_name => n_dname,
         x_description => x_description,
         x_persistence_type => x_persistence_type,
         x_persistence_days => l_persistence_days
      );
  end;


exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Upload_Item_Type', x_name);
    raise;
end UPLOAD_ITEM_TYPE;

--
-- Reseq_Item_Attribute (PRIVATE)
--   Resequence attributes in the db to match the sequence of attrs
--   being uploaded.  This is needed to avoid unique index violations
--   on the sequence when uploading reordered attributes.
-- IN
--   itemtype - Item type owning attrs
--   oldseq - Original sequence number of attr being uploaded
--   newseq - New sequence number of attribute
--
procedure Reseq_Item_Attribute(
  itemtype in varchar2,
  oldseq in number,
  newseq in number)
is
begin
  -- Move attr being updated to a placeholder out of the way.
  update WF_ITEM_ATTRIBUTES set
    SEQUENCE = -1
  where ITEM_TYPE = itemtype
  and SEQUENCE = oldseq;

  if (oldseq < newseq) then
    -- Move attrs DOWN in sequence to make room at higher position
    for i in (oldseq + 1) .. newseq loop
      update WF_ITEM_ATTRIBUTES set
        SEQUENCE = SEQUENCE - 1
      where ITEM_TYPE = itemtype
      and SEQUENCE = i;
    end loop;
  elsif (oldseq > newseq) then
    -- Move attrs UP in sequence to make room at lower position
    for i in reverse newseq .. (oldseq - 1) loop
      update WF_ITEM_ATTRIBUTES set
        SEQUENCE = SEQUENCE + 1
      where ITEM_TYPE = itemtype
      and SEQUENCE = i;
    end loop;
  end if;

  -- Move attr being updated into new sequence position
  update WF_ITEM_ATTRIBUTES set
    SEQUENCE = newseq
  where ITEM_TYPE = itemtype
  and SEQUENCE = -1;

exception
  when others then
    Wf_Core.Context('Wf_Load', 'Reseq_Item_Attribute', itemtype,
        to_char(oldseq), to_char(newseq));
    raise;
end Reseq_Item_Attribute;

--
-- UPLOAD_ITEM_ATTRIBUTE
--
procedure UPLOAD_ITEM_ATTRIBUTE (
  x_item_type in varchar2,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_sequence in number,
  x_type in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_subtype in varchar2,
  x_format in varchar2,
  x_default in varchar2,
  x_level_error out NOCOPY number
) is
  row_id varchar2(30);
  protection_level number;
  customization_level number;
  l_text_default varchar2(4000) := '';
  l_number_default number := '';
  l_date_default date := '';
  conflict_name varchar2(40);
  l_dname varchar2(80);
  n_dname varchar2(80);
  l_name  varchar2(30);
  old_sequence number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check for unique index violations
  --   try to resolve the problem by appending '@'
  --   to the incoming display name
  n_dname := x_display_name;
  begin
    -- l_name will be the old data to update
    select ITEM_TYPE||':'||NAME, DISPLAY_NAME, NAME
    into conflict_name, l_dname, l_name
    from WF_ITEM_ATTRIBUTES_VL
    where DISPLAY_NAME = x_display_name
    and ITEM_TYPE = x_item_type
    and NAME <> x_name;

    n_dname := substrb('@'||l_dname, 1, 80);

    -- this loop will make sure no duplicate with n_dname
    loop
      begin
        select ITEM_TYPE||':'||NAME, DISPLAY_NAME
        into conflict_name, l_dname
        from WF_ITEM_ATTRIBUTES_VL
        where DISPLAY_NAME = n_dname
        and ITEM_TYPE = x_item_type
        and NAME <> l_name;

        n_dname := substrb('@'||l_dname, 1, 80);

        if ( n_dname = l_dname ) then
          Wf_Core.Token('DNAME', x_display_name);
          Wf_Core.Token('NAME', x_item_type||':'||x_name);
          Wf_Core.Token('CONFLICT_NAME', conflict_name);
          Wf_Core.Raise('WFSQL_UNIQUE_NAME');
          exit;
        end if;
      exception
        when no_data_found then
          exit;
      end;
    end loop;

    -- ### Not needed any more
    -- update the old data with the new display name
    -- begin
    --   update WF_ITEM_ATTRIBUTES_TL
    --      set display_name = n_dname
    --    where ITEM_TYPE = x_item_type
    --      and NAME = l_name
    --      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    -- exception
    --   when others then
    --     Wf_Core.Token('TABLE', 'ITEM_ATTRIBUTES_TL');
    --     Wf_Core.Token('VALUE', l_name);
    --     Wf_Core.Raise('WFSQL_UPDATE_FAIL');
    -- end;
  exception
    when no_data_found then
      null;

    when others then
      raise;
  end;

  -- Translate x_default to appropriate type
  if (x_type = 'NUMBER') then
    l_number_default := to_number(x_default);
  elsif (x_type = 'DATE') then
    l_date_default := to_date(x_default, 'YYYY/MM/DD HH24:MI:SS');
  else
    l_text_default := x_default;
  end if;

  -- Check protection level
  x_level_error := 0;
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL, SEQUENCE
    into protection_level, customization_level, old_sequence
    from WF_ITEM_ATTRIBUTES_VL
    where ITEM_TYPE = x_item_type
    and NAME = x_name;

    if ((wf_core.upload_mode <> 'FORCE') and
        (protection_level < wf_core.session_level)) then
      x_level_error := 1;
      return;
    end if;

    if ((wf_core.upload_mode = 'UPGRADE') and
        (customization_level > wf_core.session_level)) then
      x_level_error := 2;
      return;
    end if;

    -- Resequence attrs in db to match sequence being uploaded
    if (old_sequence <> x_sequence) then
      Wf_Load.Reseq_Item_Attribute(
          itemtype => x_item_type,
          oldseq => old_sequence,
          newseq => x_sequence);
    end if;

    -- Update existing row
    Wf_Item_Attributes_Pkg.Update_Row(
      x_item_type => x_item_type,
      x_name => x_name,
      x_sequence => x_sequence,
      x_type => x_type,
      x_protect_level => x_protect_level,
      x_custom_level => x_custom_level,
      x_subtype => x_subtype,
      x_format => x_format,
      x_text_default => l_text_default,
      x_number_default => l_number_default,
      x_date_default => l_date_default,
      x_display_name => n_dname,
      x_description => x_description
    );
  exception
    when NO_DATA_FOUND then
      -- Check protection level for new row
      -- ### Relax the checking on attributes, lookup_code, transitions
      if ((wf_core.upload_mode <> 'FORCE') and
          (x_protect_level < wf_core.session_level)) then
        x_level_error := 1;
        return;
      end if;

      if ((wf_core.upload_mode = 'UPGRADE') and
          (x_custom_level > wf_core.session_level)) then
        x_level_error := 2;
        return;
      end if;

      -- Resequence attrs so that everything below the attr being
      -- inserted is shoved out of the way.
      select nvl(max(SEQUENCE), -1)+1
      into old_sequence
      from WF_ITEM_ATTRIBUTES
      where ITEM_TYPE = x_item_type;

      if (old_sequence <> x_sequence) then
        Wf_Load.Reseq_Item_Attribute(
            itemtype => x_item_type,
            oldseq => old_sequence,
            newseq => x_sequence);
      end if;

      -- Insert new row
      Wf_Item_Attributes_Pkg.Insert_Row(
        x_rowid => row_id,
        x_item_type => x_item_type,
        x_name => x_name,
        x_sequence => x_sequence,
        x_type => x_type,
        x_protect_level => x_protect_level,
        x_custom_level => x_custom_level,
        x_subtype => x_subtype,
        x_format => x_format,
        x_text_default => l_text_default,
        x_number_default => l_number_default,
        x_date_default => l_date_default,
        x_display_name => n_dname,
        x_description => x_description
      );
  end;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Upload_Item_Attribute', x_item_type, x_name);
    raise;
end UPLOAD_ITEM_ATTRIBUTE;

--
-- UPLOAD_LOOKUP_TYPE
--
procedure UPLOAD_LOOKUP_TYPE (
  x_lookup_type in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_item_type in varchar2,
  x_level_error out NOCOPY number
) is
  row_id varchar2(30);
  protection_level number;
  customization_level number;
  conflict_name varchar2(30);
  l_dname varchar2(80);
  n_dname varchar2(80);
  l_name  varchar2(30);
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Set the new display name
  n_dname := x_display_name;

  -- Check for unique index violations
  --   try to resolve the problem by appending '@'
  --   to the incoming display name
  begin
    select LOOKUP_TYPE, DISPLAY_NAME, LOOKUP_TYPE
    into conflict_name, l_dname, l_name
    from WF_LOOKUP_TYPES
    where DISPLAY_NAME = x_display_name
    and LOOKUP_TYPE <> x_lookup_type;

    n_dname := substrb('@'||l_dname, 1, 80);

    -- this loop will make sure no duplicate with n_dname
    loop
      begin
        select LOOKUP_TYPE, DISPLAY_NAME
        into conflict_name, l_dname
        from WF_LOOKUP_TYPES
        where DISPLAY_NAME = n_dname
        and LOOKUP_TYPE <> l_name;

        n_dname := substrb('@'||l_dname, 1, 80);

        if ( n_dname = l_dname ) then
          Wf_Core.Token('DNAME', x_display_name);
          Wf_Core.Token('NAME', x_lookup_type);
          Wf_Core.Token('CONFLICT_NAME', conflict_name);
          Wf_Core.Raise('WFSQL_UNIQUE_NAME');
          exit;
        end if;
      exception
        when no_data_found then
          exit;
      end;
    end loop;
    -- ### No need to do this
    -- update the old data with the new meaning
    -- begin
    --   update WF_LOOKUP_TYPES_TL
    --      set DISPLAY_NAME = n_dname
    --    where LOOKUP_TYPE = l_name
    --      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    -- exception
    --   when others then
    --     Wf_Core.Token('TABLE', 'LOOKUP_TYPES_TL');
    --     Wf_Core.Token('VALUE', l_name);
    --     Wf_Core.Raise('WFSQL_UPDATE_FAIL');
    -- end;
  exception
    when no_data_found then
      null;
  end;

  -- Check protection level
  x_level_error := 0;
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL
    into protection_level, customization_level
    from WF_LOOKUP_TYPES
    where LOOKUP_TYPE = x_lookup_type;

    if ((wf_core.upload_mode <> 'FORCE') and
        (protection_level < wf_core.session_level)) then
      x_level_error := 1;
      return;
    end if;

    if ((wf_core.upload_mode = 'UPGRADE') and
        (customization_level > wf_core.session_level)) then
      x_level_error := 2;
      return;
    end if;

    -- Update existing row
    Wf_Lookup_Types_Pkg.Update_Row(
      x_lookup_type => x_lookup_type,
      x_item_type => x_item_type,
      x_protect_level => x_protect_level,
      x_custom_level => x_custom_level,
      x_display_name => n_dname,
      x_description => x_description
    );
  exception
    when NO_DATA_FOUND then
      -- Check protection level for new row
      if ((wf_core.upload_mode <> 'FORCE') and
          (x_protect_level < wf_core.session_level)) then
        x_level_error := 4+1;
        return;
      end if;

      if ((wf_core.upload_mode = 'UPGRADE') and
          (x_custom_level > wf_core.session_level)) then
        x_level_error := 4+2;
        return;
      end if;

      -- Insert new row
      Wf_Lookup_Types_Pkg.Insert_Row(
        x_rowid => row_id,
        x_lookup_type => x_lookup_type,
        x_item_type => x_item_type,
        x_protect_level => x_protect_level,
        x_custom_level => x_custom_level,
        x_display_name => n_dname,
        x_description => x_description
      );
  end;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Upload_Lookup_Type', x_lookup_type);
    raise;
end UPLOAD_LOOKUP_TYPE;

--
-- UPLOAD_LOOKUP
--
procedure UPLOAD_LOOKUP (
  x_lookup_type in varchar2,
  x_lookup_code in varchar2,
  x_meaning in varchar2,
  x_description in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_level_error out NOCOPY number
) is
  row_id varchar2(30) := '';
  protection_level number;
  customization_level number;
  conflict_name varchar2(80);
  l_dname varchar2(80);
  n_dname varchar2(80);
  l_name  varchar2(30);
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check for unique index violations
  --   try to resolve the problem by appending '@'
  --   to the incoming meaning
  n_dname := x_meaning;
  begin
    -- l_name will be the old data to update
    select LOOKUP_TYPE||':'||LOOKUP_CODE, MEANING, LOOKUP_CODE
    into conflict_name, l_dname, l_name
    from WF_LOOKUPS
    where MEANING = x_meaning
    and LOOKUP_TYPE = x_lookup_type
    and LOOKUP_CODE <> x_lookup_code;

    n_dname := substrb('@'||l_dname, 1, 80);

    -- this loop will make sure no duplicate with n_dname
    loop
      begin
        select LOOKUP_TYPE||':'||LOOKUP_CODE, MEANING
        into conflict_name, l_dname
        from WF_LOOKUPS
        where MEANING = n_dname
        and LOOKUP_TYPE = x_lookup_type
        and LOOKUP_CODE <> l_name;

        n_dname := substrb('@'||l_dname, 1, 80);

        if ( n_dname = l_dname ) then
          Wf_Core.Token('DNAME', x_meaning);
          Wf_Core.Token('NAME', x_lookup_code);
          Wf_Core.Token('CONFLICT_NAME', conflict_name);
          Wf_Core.Raise('WFSQL_UNIQUE_NAME');
          exit;
        end if;
      exception
        when no_data_found then
          exit;
      end;
    end loop;

    -- ### No need to do this
    -- update the old data with the new meaning
    -- begin
    --   update WF_LOOKUPS_TL
    --      set MEANING = n_dname
    --    where LOOKUP_TYPE = x_lookup_type
    --      and LOOKUP_CODE = l_name
    --      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    -- exception
    --   when others then
    --     Wf_Core.Token('TABLE', 'LOOKUPS_TL');
    --     Wf_Core.Token('VALUE', l_name);
    --     Wf_Core.Raise('WFSQL_UPDATE_FAIL');
    -- end;
  exception
    when no_data_found then
      null;

    when others then
      raise;
  end;

  -- Check protection level
  x_level_error := 0;
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL
    into protection_level, customization_level
    from WF_LOOKUPS
    where LOOKUP_TYPE = x_lookup_type
    and LOOKUP_CODE = x_lookup_code;

    if ((wf_core.upload_mode <> 'FORCE') and
        (protection_level < wf_core.session_level)) then
      x_level_error := 1;
      return;
    end if;

    if ((wf_core.upload_mode = 'UPGRADE') and
        (customization_level > wf_core.session_level)) then
      x_level_error := 2;
      return;
    end if;

    -- Update existing row
    Wf_Lookups_Pkg.Update_Row(
      x_lookup_type => x_lookup_type,
      x_lookup_code => x_lookup_code,
      x_protect_level => x_protect_level,
      x_custom_level => x_custom_level,
      x_meaning => n_dname,
      x_description => x_description
    );
  exception
    when NO_DATA_FOUND then
      -- Check protection level for new row
      -- ### Relax the checking on attributes, lookup_code, transitions
      if ((wf_core.upload_mode <> 'FORCE') and
          (x_protect_level < wf_core.session_level)) then
        x_level_error := 1;
        return;
      end if;

      if ((wf_core.upload_mode = 'UPGRADE') and
          (x_custom_level > wf_core.session_level)) then
        x_level_error := 2;
        return;
      end if;

      -- Insert new row
      Wf_Lookups_Pkg.Insert_Row(
        x_rowid => row_id,
        x_lookup_type => x_lookup_type,
        x_lookup_code => x_lookup_code,
        x_protect_level => x_protect_level,
        x_custom_level => x_custom_level,
        x_meaning => n_dname,
        x_description => x_description
      );
  end;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Upload_Lookup', x_lookup_type, x_lookup_code);
    raise;
end UPLOAD_LOOKUP;

--
-- UPLOAD_MESSAGE
--
procedure UPLOAD_MESSAGE (
  x_type in varchar2,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_subject in varchar2,
  x_body in varchar2,
  x_html_body in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_default_priority in number,
  x_read_role in varchar2,
  x_write_role in varchar2,
  x_level_error out NOCOPY number
) is
  row_id varchar2(30);
  protection_level number;
  customization_level number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL
    into protection_level, customization_level
    from WF_MESSAGES_VL
    where TYPE = x_type
    and NAME = x_name;

    if ((wf_core.upload_mode <> 'FORCE') and
        (protection_level < wf_core.session_level)) then
      x_level_error := 1;
      return;
    end if;

    if ((wf_core.upload_mode = 'UPGRADE') and
        (customization_level > wf_core.session_level)) then
      x_level_error := 2;
      return;
    end if;

    -- Update existing row
    Wf_Messages_Pkg.Update_Row(
      x_type => x_type,
      x_name => x_name,
      x_protect_level => x_protect_level,
      x_custom_level => x_custom_level,
      x_default_priority => x_default_priority,
      x_read_role => x_read_role,
      x_write_role => x_write_role,
      x_display_name => x_display_name,
      x_description => x_description,
      x_subject => x_subject,
      x_body => x_body,
      x_html_body => x_html_body
    );
  exception
    when NO_DATA_FOUND then
      -- Check protection level for new row
      if ((wf_core.upload_mode <> 'FORCE') and
          (x_protect_level < wf_core.session_level)) then
        x_level_error := 4+1;
        return;
      end if;

      if ((wf_core.upload_mode = 'UPGRADE') and
          (x_custom_level > wf_core.session_level)) then
        x_level_error := 4+2;
        return;
      end if;

      -- Insert new row
      Wf_Messages_Pkg.Insert_Row(
        x_rowid => row_id,
        x_type => x_type,
        x_name => x_name,
        x_protect_level => x_protect_level,
        x_custom_level => x_custom_level,
        x_default_priority => x_default_priority,
        x_read_role => x_read_role,
        x_write_role => x_write_role,
        x_display_name => x_display_name,
        x_description => x_description,
        x_subject => x_subject,
        x_body => x_body,
        x_html_body => x_html_body
      );
  end;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Upload_Message', x_type, x_name);
    raise;
end UPLOAD_MESSAGE;

--
-- Reseq_Message_Attribute (PRIVATE)
--   Resequence attributes in the db to match the sequence of attrs
--   being uploaded.  This is needed to avoid unique index violations
--   on the sequence when uploading reordered attributes.
-- IN
--   msgtype - Message type of msg owning attrs
--   msgname - Message name of msg owning attrs
--   oldseq - Original sequence number of attr being uploaded
--   newseq - New sequence number of attribute
--
procedure Reseq_Message_Attribute(
  msgtype in varchar2,
  msgname in varchar2,
  oldseq in number,
  newseq in number)
is
begin
  -- Move attr being updated to a placeholder out of the way.
  update WF_MESSAGE_ATTRIBUTES set
    SEQUENCE = -1
  where MESSAGE_TYPE = msgtype
  and MESSAGE_NAME = msgname
  and SEQUENCE = oldseq;

  if (oldseq < newseq) then
    -- Move attrs DOWN in sequence to make room at higher position
    for i in (oldseq + 1) .. newseq loop
      update WF_MESSAGE_ATTRIBUTES set
        SEQUENCE = SEQUENCE - 1
      where MESSAGE_TYPE = msgtype
      and MESSAGE_NAME = msgname
      and SEQUENCE = i;
    end loop;
  elsif (oldseq > newseq) then
    -- Move attrs UP in sequence to make room at lower position
    for i in reverse newseq .. (oldseq - 1) loop
      update WF_MESSAGE_ATTRIBUTES set
        SEQUENCE = SEQUENCE + 1
      where MESSAGE_TYPE = msgtype
      and MESSAGE_NAME = msgname
      and SEQUENCE = i;
    end loop;
  end if;

  -- Move attr being updated into new sequence position
  update WF_MESSAGE_ATTRIBUTES set
    SEQUENCE = newseq
  where MESSAGE_TYPE = msgtype
  and MESSAGE_NAME = msgname
  and SEQUENCE = -1;

exception
  when others then
    Wf_Core.Context('Wf_Load', 'Reseq_Message_Attribute', msgtype,
        msgname, to_char(oldseq), to_char(newseq));
    raise;
end Reseq_Message_Attribute;

--
-- UPLOAD_MESSAGE_ATTRIBUTE
--
procedure UPLOAD_MESSAGE_ATTRIBUTE (
  x_message_type in varchar2,
  x_message_name in varchar2,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_sequence in number,
  x_type in varchar2,
  x_subtype in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_format in varchar2,
  x_default in varchar2,
  x_value_type in varchar2,
  x_attach  in varchar2,
  x_level_error out NOCOPY number
) is
  row_id varchar2(30);
  protection_level number;
  customization_level number;
  l_text_default varchar2(4000) := '';
  l_number_default number := '';
  l_date_default date := '';
  conflict_name varchar2(80);
  l_dname varchar2(80);
  n_dname varchar2(80);
  l_name  varchar2(30);
  old_sequence number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check for unique index violations
  --   try to resolve the problem by appending '@'
  --   to the incoming display name
  n_dname := x_display_name;
  begin
    -- l_name will be the old data to update
    select MESSAGE_TYPE||':'||MESSAGE_NAME||':'||NAME, DISPLAY_NAME, NAME
    into conflict_name, l_dname, l_name
    from WF_MESSAGE_ATTRIBUTES_VL
    where DISPLAY_NAME = n_dname
    and MESSAGE_TYPE = x_message_type
    and MESSAGE_NAME = x_message_name
    and NAME <> x_name;

    n_dname := substrb('@'||l_dname, 1, 80);

    -- this loop will make sure no duplicate with n_dname
    loop
      begin
        select MESSAGE_TYPE||':'||MESSAGE_NAME||':'||NAME, DISPLAY_NAME
        into conflict_name, l_dname
        from WF_MESSAGE_ATTRIBUTES_VL
        where DISPLAY_NAME = n_dname
        and MESSAGE_TYPE = x_message_type
        and MESSAGE_NAME = x_message_name
        and NAME <> l_name;

        n_dname := substrb('@'||l_dname, 1, 80);

        if ( n_dname = l_dname ) then
          Wf_Core.Token('DNAME', x_display_name);
          Wf_Core.Token('NAME', x_message_type||':'||x_message_name||':'
                        ||x_name);
          Wf_Core.Token('CONFLICT_NAME', conflict_name);
          Wf_Core.Raise('WFSQL_UNIQUE_NAME');
          exit;
        end if;
      exception
        when no_data_found then
          exit;
      end;
    end loop;

    -- ### No need to do this
    -- update the old data with the new display name
    -- begin
    --   update WF_MESSAGE_ATTRIBUTES_TL
    --      set display_name = n_dname
    --    where MESSAGE_TYPE = x_message_type
    --      and MESSAGE_NAME = x_message_name
    --      and NAME = l_name
    --   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    -- exception
    --   when others then
    --     Wf_Core.Token('TABLE', 'MESSAGE_ATTRIBUTES_TL');
    --     Wf_Core.Token('VALUE', l_name);
    --     Wf_Core.Raise('WFSQL_UPDATE_FAIL');
    -- end;
  exception
    when no_data_found then
      null;

    when others then
      raise;
  end;

  -- Translate x_default to appropriate type
  if ((x_value_type = 'CONSTANT') and (x_type = 'NUMBER')) then
    l_number_default := to_number(x_default);
  elsif ((x_value_type = 'CONSTANT') and (x_type = 'DATE')) then
    l_date_default := to_date(x_default, 'YYYY/MM/DD HH24:MI:SS');
  else
    l_text_default := x_default;
  end if;

  -- Check protection level
  x_level_error := 0;
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL, SEQUENCE
    into protection_level, customization_level, old_sequence
    from WF_MESSAGE_ATTRIBUTES_VL
    where MESSAGE_TYPE = x_message_type
    and MESSAGE_NAME = x_message_name
    and NAME = x_name;

    if ((wf_core.upload_mode <> 'FORCE') and
        (protection_level < wf_core.session_level)) then
      x_level_error := 1;
      return;
    end if;

    if ((wf_core.upload_mode = 'UPGRADE') and
        (customization_level > wf_core.session_level)) then
      x_level_error := 2;
      return;
    end if;

    -- Resequence attrs in db to match sequence being uploaded
    if (old_sequence <> x_sequence) then
      Wf_Load.Reseq_Message_Attribute(
          msgtype => x_message_type,
          msgname => x_message_name,
          oldseq => old_sequence,
          newseq => x_sequence);
    end if;

    Wf_Message_Attributes_Pkg.Update_Row(
      x_message_type => x_message_type,
      x_message_name => x_message_name,
      x_name => x_name,
      x_sequence => x_sequence,
      x_type => x_type,
      x_subtype => x_subtype,
      x_protect_level => x_protect_level,
      x_custom_level => x_custom_level,
      x_format => x_format,
      x_text_default => l_text_default,
      x_number_default => l_number_default,
      x_date_default => l_date_default,
      x_value_type => x_value_type,
      x_display_name => n_dname,
      x_description => x_description,
      x_attach => x_attach
    );
  exception
    when NO_DATA_FOUND then
      -- Resequence attrs so that everything below the attr being
      -- inserted is shoved out of the way.
      select nvl(max(SEQUENCE), -1)+1
      into old_sequence
      from WF_MESSAGE_ATTRIBUTES
      where MESSAGE_TYPE = x_message_type
      and MESSAGE_NAME = x_message_name;

      if (old_sequence <> x_sequence) then
        Wf_Load.Reseq_Message_Attribute(
            msgtype => x_message_type,
            msgname => x_message_name,
            oldseq => old_sequence,
            newseq => x_sequence);
      end if;

      Wf_Message_Attributes_Pkg.Insert_Row(
        x_rowid => row_id,
        x_message_type => x_message_type,
        x_message_name => x_message_name,
        x_name => x_name,
        x_sequence => x_sequence,
        x_type => x_type,
        x_subtype => x_subtype,
        x_protect_level => x_protect_level,
        x_custom_level => x_custom_level,
        x_format => x_format,
        x_text_default => l_text_default,
        x_number_default => l_number_default,
        x_date_default => l_date_default,
        x_value_type => x_value_type,
        x_display_name => n_dname,
        x_description => x_description,
        x_attach => x_attach
      );
  end;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Upload_Message_Attribute', x_message_type,
                    x_message_name, x_name);
    raise;
end UPLOAD_MESSAGE_ATTRIBUTE;

--
-- UPLOAD_ACTIVITY
--
procedure UPLOAD_ACTIVITY (
  x_item_type in varchar2,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_type in varchar2,
  x_rerun in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_effective_date in date,
  x_function in varchar2,
  x_function_type in varchar2,
  x_result_type in varchar2,
  x_cost in number,
  x_read_role in varchar2,
  x_write_role in varchar2,
  x_execute_role in varchar2,
  x_icon_name in varchar2,
  x_message in varchar2,
  x_error_process in varchar2,
  x_expand_role in varchar2,
  x_error_item_type in varchar2,
  x_runnable_flag in varchar2,
  x_event_filter in varchar2 ,
  x_event_type in varchar2 ,
  x_log_message out NOCOPY varchar2,
  x_version out NOCOPY number,
  x_level_error out NOCOPY number
) is
  row_id varchar2(30);
  protection_level number;
  customization_level number;
  old_version number := '';
  old_begin_date date := '';
  old_end_date date := '';
  new_version number;
  dummy pls_integer;
  noinsert pls_integer := -1;     /* always insert by default */
  dummy_log_message varchar2(32000);
  dummy_version number;
  dummy_level_error number;
  conflict_name varchar2(240);
  l_dname varchar2(240);
  n_dname varchar2(240);
  l_name  varchar2(30);
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level,
  -- and get version number and begin/end-dates for version currently
  -- active for x_effective_date.
  x_level_error := 0;
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL, VERSION, BEGIN_DATE, END_DATE
    into protection_level, customization_level,
         old_version, old_begin_date, old_end_date
    from WF_ACTIVITIES_VL
    where ITEM_TYPE = x_item_type
    and NAME = x_name
    and x_effective_date >= BEGIN_DATE
    and x_effective_date < nvl(END_DATE, x_effective_date+1);

    if (x_type <> 'FOLDER') then
      if ((wf_core.upload_mode <> 'FORCE') and
          (protection_level < wf_core.session_level)) then
        x_level_error := 1;
        return;
      end if;

      if ((wf_core.upload_mode = 'UPGRADE') and
          (customization_level > wf_core.session_level)) then
        x_level_error := 2;
        return;
      end if;
    end if;
  exception
    when NO_DATA_FOUND then
      -- No version active.  Check for begin_date of next version
      -- after this one in the timeline and use that as the end date
      -- of the new version.
      -- If this still returns null, then either this is the first version
      -- to be entered or a previously deleted activity is being
      -- recreated.  OK to leave end_date as null.
      select min(BEGIN_DATE)
      into old_end_date
      from WF_ACTIVITIES_VL
      where ITEM_TYPE = x_item_type
      and NAME = x_name
      and BEGIN_DATE >= x_effective_date;

      -- Check protection level for new row
      if (x_type <> 'FOLDER') then
        if ((wf_core.upload_mode <> 'FORCE') and
            (x_protect_level < wf_core.session_level)) then
          x_level_error := 4+1;
          return;
        end if;

        if ((wf_core.upload_mode = 'UPGRADE') and
            (x_custom_level > wf_core.session_level)) then
          x_level_error := 4+2;
          return;
        end if;
      end if;
  end;


  -- ### When it is ROOT FOLDER:
  -- ### New version is always the last version, 1 if no last version found.
  -- ### Instead of updating the end date according to the effective date,
  -- ### null the end date.
  -- ### Don't insert a row if it already exists.

  if (x_name = 'ROOT' and x_type = 'FOLDER') then
    -- Get current version number, if not exist, use 1
    -- If version exists, noinsert is positive, that is not to insert.
    select nvl(max(VERSION), 1), count(1)
    into new_version, noinsert
    from WF_ACTIVITIES
    where ITEM_TYPE = x_item_type
    and NAME = x_name;

  else
    -- Get a new version number
    select nvl(max(VERSION), 0) + 1
    into new_version
    from WF_ACTIVITIES
    where ITEM_TYPE = x_item_type
    and NAME = x_name;

    -- Set the end_date of the old version covering x_effective_date to
    -- x_effective_date.
    update WF_ACTIVITIES set
      END_DATE = x_effective_date
    where ITEM_TYPE = x_item_type
    and NAME = x_name
    and VERSION = old_version;
  end if;

  -- Check for unique index violations
  --   try to resolve the problem by appending '@'
  --   to the incoming display name
  --   for activity, we must have the specific version first.
  n_dname := x_display_name;
  begin
    -- l_name will be the old data to update
    select ITEM_TYPE||':'||NAME||':'||to_char(VERSION), DISPLAY_NAME, NAME
    into conflict_name, l_dname, l_name
    from WF_ACTIVITIES_VL
    where DISPLAY_NAME = n_dname
    and ITEM_TYPE = x_item_type
    and x_effective_date >= BEGIN_DATE
    and x_effective_date < nvl(END_DATE, x_effective_date+1)
    and NAME <> x_name;

    n_dname := substrb('@'||l_dname, 1, 240);

    -- this loop will make sure no duplicate with n_dname
    loop
      begin
        select ITEM_TYPE||':'||NAME||':'||to_char(VERSION), DISPLAY_NAME
        into conflict_name, l_dname
        from WF_ACTIVITIES_VL
        where DISPLAY_NAME = n_dname
        and ITEM_TYPE = x_item_type
        and x_effective_date >= BEGIN_DATE
        and x_effective_date < nvl(END_DATE, x_effective_date+1)
        and NAME <> l_name;

        n_dname := substrb('@'||l_dname, 1, 240);

        if ( n_dname = l_dname ) then
          Wf_Core.Token('DNAME', x_display_name);
          Wf_Core.Token('NAME', x_item_type||':'||x_name||':'||new_version);
          Wf_Core.Token('CONFLICT_NAME', conflict_name);
          Wf_Core.Raise('WFSQL_UNIQUE_NAME');
          exit;
        end if;
      exception
        when no_data_found then
          exit;
      end;
    end loop;

    -- ### Not needed any more
    -- update the old data with the new display name
    -- begin
    --   update WF_ACTIVITIES_TL
    --      set display_name = n_dname
    --    where NAME = l_name
    --      and ITEM_TYPE = x_item_type
    --      and VERSION = new_version
    --   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    -- exception
    --   when others then
    --     Wf_Core.Token('TABLE', 'ACTIVITIES_TL');
    --     Wf_Core.Token('VALUE', l_name);
    --     Wf_Core.Raise('WFSQL_UPDATE_FAIL');
    -- end;
  exception
    when no_data_found then
      null;

    when others then
      raise;
  end;

  --
  -- Insert a new row for the new version, starting at x_effective_date
  -- and ending at the end_date of the old version covering x_effective_date.
  if (noinsert <= 0) then
    if (x_event_filter is null and x_event_type = null) then

      Wf_Activities_Pkg.Insert_Row(
        x_rowid => row_id,
        x_item_type => x_item_type,
        x_name => x_name,
        x_version => new_version,
        x_type => x_type,
        x_rerun => x_rerun,
        x_expand_role => x_expand_role,
        x_protect_level => x_protect_level,
        x_custom_level => x_custom_level,
        x_begin_date => x_effective_date,
        x_end_date => old_end_date,
        x_function => x_function,
        x_function_type => x_function_type,
        x_result_type => x_result_type,
        x_cost => x_cost,
        x_read_role => x_read_role,
        x_write_role => x_write_role,
        x_execute_role => x_execute_role,
        x_icon_name => x_icon_name,
        x_message => x_message,
        x_error_process => x_error_process,
        x_display_name => n_dname,
        x_description => x_description,
        x_error_item_type => x_error_item_type,
        x_runnable_flag => x_runnable_flag
      );

    else

      Wf_Activities_Pkg.Insert_Row(
        x_rowid => row_id,
        x_item_type => x_item_type,
        x_name => x_name,
        x_version => new_version,
        x_type => x_type,
        x_rerun => x_rerun,
        x_expand_role => x_expand_role,
        x_protect_level => x_protect_level,
        x_custom_level => x_custom_level,
        x_begin_date => x_effective_date,
        x_end_date => old_end_date,
        x_function => x_function,
        x_function_type => x_function_type,
        x_result_type => x_result_type,
        x_cost => x_cost,
        x_read_role => x_read_role,
        x_write_role => x_write_role,
        x_execute_role => x_execute_role,
        x_icon_name => x_icon_name,
        x_message => x_message,
        x_error_process => x_error_process,
        x_display_name => n_dname,
        x_description => x_description,
        x_error_item_type => x_error_item_type,
        x_runnable_flag => x_runnable_flag,
        x_event_filter => x_event_filter,
        x_event_type => x_event_type
      );
    end if;

    -- handle the extra log message for display name conflict
    x_log_message := Wf_Load.logbuf;
    -- if the message is not empty, there is a conflict.
    if (x_log_message is not null or x_log_message <> '') then
      x_level_error  := 16;
      Wf_Load.logbuf := '';  -- clear the buffer now
    end if;

    if (not (x_name = 'ROOT' and x_type = 'FOLDER')) then
      WF_LOAD.UPLOAD_ACTIVITY(
        x_item_type=>x_item_type,
        x_name=>'ROOT',
        x_type=>'FOLDER',
        x_display_name=>'ROOT',
        x_description=>'',
        x_rerun=>'RESET',
        x_protect_level=>x_protect_level,
        x_custom_level=>x_custom_level,
        x_effective_date=>x_effective_date,
        x_function=>'',
        x_function_type=>'',
        x_result_type=>'*',
        x_cost=>0,
        x_read_role=>'',
        x_write_role=>'',
        x_execute_role=>'',
        x_icon_name=>'ROOT',
        x_message=>'',
        x_error_process=>'',
        x_expand_role=>'N',
        x_error_item_type =>'WFERROR',
        x_runnable_flag =>'N',
        x_log_message=>dummy_log_message,
        x_version=>dummy_version,
        x_level_error=>dummy_level_error);
    end if;
  else
    -- If you got here, this must be a ROOT FOLDER.
    -- Null the end_date of the new version of ROOT FOLDER,
    -- in case it was set (deleted but not purged previously).

    if (old_begin_date is null) then
      -- only have future definition, need to update the begin date also
      update WF_ACTIVITIES
        set  BEGIN_DATE = x_effective_date,
             END_DATE = to_date(NULL)
      where ITEM_TYPE = x_item_type
      and NAME = x_name
      and VERSION = new_version;

      -- since we move the begin date, we'd better make sure to
      -- delete all the previous root versions that fall into this
      -- date range.  This is a safe guard for old data from
      -- pre WF 2.5 days where there maybe multiple root versions.
      -- ### umm... maybe we should skip this.
      -- ### most customer would not have such problem.
      -- ### in order to delete these, we may need to do a more
      -- ### complicated cursor query.
    else
      update WF_ACTIVITIES
        set  END_DATE = to_date(NULL)
      where ITEM_TYPE = x_item_type
      and NAME = x_name
      and VERSION = new_version;
    end if;
  end if;

  x_version := new_version;

/* ### Should not have a commit in this API */
/* ### commit; */
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Upload_Activity', x_item_type, x_name);
    raise;
end UPLOAD_ACTIVITY;

--
-- provide the old 2.5 version of signature for forward compatibility
-- this is used by other product teams
--
procedure UPLOAD_ACTIVITY (
  x_item_type in varchar2,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_type in varchar2,
  x_rerun in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_effective_date in date,
  x_function in varchar2,
  x_function_type in varchar2,
  x_result_type in varchar2,
  x_cost in number,
  x_read_role in varchar2,
  x_write_role in varchar2,
  x_execute_role in varchar2,
  x_icon_name in varchar2,
  x_message in varchar2,
  x_error_process in varchar2,
  x_expand_role in varchar2,
  x_error_item_type in varchar2,
  x_runnable_flag in varchar2,
  x_version out NOCOPY number,
  x_level_error out NOCOPY number
) is
  dummy_log_message varchar2(32000);
begin
  -- call the real UPLOAD_ACTIVITY and ignore the dummy_log_message
  WF_LOAD.UPLOAD_ACTIVITY(
    x_item_type=>x_item_type,
    x_name=>x_name,
    x_type=>x_type,
    x_display_name=>x_display_name,
    x_description=>x_description,
    x_rerun=>x_rerun,
    x_protect_level=>x_protect_level,
    x_custom_level=>x_custom_level,
    x_effective_date=>x_effective_date,
    x_function=>x_function,
    x_function_type=>x_function_type,
    x_result_type=>x_result_type,
    x_cost=>x_cost,
    x_read_role=>x_read_role,
    x_write_role=>x_write_role,
    x_execute_role=>x_execute_role,
    x_icon_name=>x_icon_name,
    x_message=>x_message,
    x_error_process=>x_error_process,
    x_expand_role=>x_expand_role,
    x_error_item_type =>x_error_item_type,
    x_runnable_flag =>x_runnable_flag,
    x_event_filter => null,
    x_event_type => null,
    x_log_message=>dummy_log_message,
    x_version=>x_version,
    x_level_error=>x_level_error
  );
end UPLOAD_ACTIVITY;

--
-- Reseq_Activity_Attribute (PRIVATE)
--   Resequence attributes in the db to match the sequence of attrs
--   being uploaded.  This is needed to avoid unique index violations
--   on the sequence when uploading reordered attributes.
-- IN
--   acttype - Activity type of activity owning attrs
--   actname - Activity name of activity owning attrs
--   actver - Activity version of activity owning attrs
--   oldseq - Original sequence number of attr being uploaded
--   newseq - New sequence number of attribute
-- NOTE
--   This isn't technically necessary for activity attrs yet, since
--   new versions are always created.  This is only in case we ever
--   decide to merge activity versions instead of always creating
--   new ones.
--
--
procedure Reseq_Activity_Attribute(
  acttype in varchar2,
  actname in varchar2,
  actver in number,
  oldseq in number,
  newseq in number)
is
begin
  -- Move attr being updated to a placeholder out of the way.
  update WF_ACTIVITY_ATTRIBUTES set
    SEQUENCE = -1
  where ACTIVITY_ITEM_TYPE = acttype
  and ACTIVITY_NAME = actname
  and ACTIVITY_VERSION = actver
  and SEQUENCE = oldseq;

  if (oldseq < newseq) then
    -- Move attrs DOWN in sequence to make room at higher position
    for i in (oldseq + 1) .. newseq loop
      update WF_ACTIVITY_ATTRIBUTES set
        SEQUENCE = SEQUENCE - 1
      where ACTIVITY_ITEM_TYPE = acttype
      and ACTIVITY_NAME = actname
      and ACTIVITY_VERSION = actver
      and SEQUENCE = i;
    end loop;
  elsif (oldseq > newseq) then
    -- Move attrs UP in sequence to make room at lower position
    for i in reverse newseq .. (oldseq - 1) loop
      update WF_ACTIVITY_ATTRIBUTES set
        SEQUENCE = SEQUENCE + 1
      where ACTIVITY_ITEM_TYPE = acttype
      and ACTIVITY_NAME = actname
      and ACTIVITY_VERSION = actver
      and SEQUENCE = i;
    end loop;
  end if;

  -- Move attr being updated into new sequence position
  update WF_ACTIVITY_ATTRIBUTES set
    SEQUENCE = newseq
  where ACTIVITY_ITEM_TYPE = acttype
  and ACTIVITY_NAME = actname
  and ACTIVITY_VERSION = actver
  and SEQUENCE = -1;

exception
  when others then
    Wf_Core.Context('Wf_Load', 'Reseq_Activity_Attribute', acttype,
        actname, to_char(actver), to_char(oldseq), to_char(newseq));
    raise;
end Reseq_Activity_Attribute;

--
-- UPLOAD_ACTIVITY_ATTRIBUTE
--
procedure UPLOAD_ACTIVITY_ATTRIBUTE (
  x_activity_item_type in varchar2,
  x_activity_name in varchar2,
  x_activity_version in number,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_sequence in number,
  x_type in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_subtype in varchar2,
  x_format in varchar2,
  x_default in varchar2,
  x_value_type in varchar2,
  x_level_error out NOCOPY number
) is
  row_id varchar2(30);
  protection_level number;
  customization_level number;
  l_text_default varchar2(4000) := '';
  l_number_default number := '';
  l_date_default date := '';
  old_sequence number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Translate x_default to appropriate type
  if ((x_value_type = 'CONSTANT') and (x_type = 'NUMBER')) then
    l_number_default := to_number(x_default);
  elsif ((x_value_type = 'CONSTANT') and (x_type = 'DATE')) then
    l_date_default := to_date(x_default, 'YYYY/MM/DD HH24:MI:SS');
  else
    l_text_default := x_default;
  end if;

  -- Check protection level
  x_level_error := 0;
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL, SEQUENCE
    into protection_level, customization_level, old_sequence
    from WF_ACTIVITY_ATTRIBUTES_VL
    where ACTIVITY_ITEM_TYPE = x_activity_item_type
    and ACTIVITY_NAME = x_activity_name
    and ACTIVITY_VERSION = x_activity_version
    and NAME = x_name;

    if ((wf_core.upload_mode <> 'FORCE') and
        (protection_level < wf_core.session_level)) then
      x_level_error := 1;
      return;
    end if;

    if ((wf_core.upload_mode = 'UPGRADE') and
        (customization_level > wf_core.session_level)) then
      x_level_error := 2;
      return;
    end if;

    -- Resequence attrs in db to match sequence being uploaded
    if (old_sequence <> x_sequence) then
      Wf_Load.Reseq_Activity_Attribute(
          acttype => x_activity_item_type,
          actname => x_activity_name,
          actver => x_activity_version,
          oldseq => old_sequence,
          newseq => x_sequence);
    end if;

    -- Update existing row
    Wf_Activity_Attributes_Pkg.Update_Row(
      x_activity_item_type => x_activity_item_type,
      x_activity_name => x_activity_name,
      x_activity_version => x_activity_version,
      x_name => x_name,
      x_sequence => x_sequence,
      x_type => x_type,
      x_value_type => x_value_type,
      x_protect_level => x_protect_level,
      x_custom_level => x_custom_level,
      x_subtype => x_subtype,
      x_format => x_format,
      x_text_default => l_text_default,
      x_number_default => l_number_default,
      x_date_default => l_date_default,
      x_display_name => x_display_name,
      x_description => x_description
    );
  exception
    when NO_DATA_FOUND then
      -- Check protection level for new row
      -- ### Relax the checking on attributes, lookup_code, transitions
      if ((wf_core.upload_mode <> 'FORCE') and
          (x_protect_level < wf_core.session_level)) then
        x_level_error := 1;
        return;
      end if;

      if ((wf_core.upload_mode = 'UPGRADE') and
          (x_custom_level > wf_core.session_level)) then
        x_level_error := 2;
        return;
      end if;

      -- Resequence attrs so that everything below the attr being
      -- inserted is shoved out of the way.
      select nvl(max(SEQUENCE), -1)+1
      into old_sequence
      from WF_ACTIVITY_ATTRIBUTES
      where ACTIVITY_ITEM_TYPE = x_activity_item_type
      and ACTIVITY_NAME = x_activity_name
      and ACTIVITY_VERSION = x_activity_version;

      if (old_sequence <> x_sequence) then
        Wf_Load.Reseq_Activity_Attribute(
            acttype => x_activity_item_type,
            actname => x_activity_name,
            actver => x_activity_version,
            oldseq => old_sequence,
            newseq => x_sequence);
      end if;

      -- Insert new row
      Wf_Activity_Attributes_Pkg.Insert_Row(
        x_rowid => row_id,
        x_activity_item_type => x_activity_item_type,
        x_activity_name => x_activity_name,
        x_activity_version => x_activity_version,
        x_name => x_name,
        x_sequence => x_sequence,
        x_type => x_type,
        x_value_type => x_value_type,
        x_protect_level => x_protect_level,
        x_custom_level => x_custom_level,
        x_subtype => x_subtype,
        x_format => x_format,
        x_text_default => l_text_default,
        x_number_default => l_number_default,
        x_date_default => l_date_default,
        x_display_name => x_display_name,
        x_description => x_description
      );
  end;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Upload_Activity_Attribute',
                    x_activity_item_type, x_activity_name,
                    to_char(x_activity_version), x_name);
    raise;
end UPLOAD_ACTIVITY_ATTRIBUTE;

--
-- UPLOAD_PROCESS_ACTIVITY
--
procedure UPLOAD_PROCESS_ACTIVITY (
  x_process_item_type in varchar2,
  x_process_name in varchar2,
  x_process_version in number,
  x_activity_item_type in varchar2,
  x_activity_name in varchar2,
  x_instance_id in out NOCOPY number,
  x_instance_label in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_start_end in varchar2,
  x_default_result in varchar2,
  x_icon_geometry in varchar2,
  x_perform_role in varchar2,
  x_perform_role_type in varchar2,
  x_user_comment in varchar2,
  x_level_error out NOCOPY number
) is
  protection_level number;
  customization_level number;
  new_version number;
  root_instance_id number := 0;
  noinsert  pls_integer := 1;
  dummy_log_message varchar2(32000);
  dummy_version number;
  dummy_level_error number;
--  has_performer number := 0;
  l_perform_role varchar2(320);
  l_perform_role_type varchar2(8);

  role_info_tbl wf_directory.wf_local_roles_tbl_type;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;
  begin
    -- instance_id of zero means generate locally
    if (x_instance_id = 0) then
        select WF_PROCESS_ACTIVITIES_S.NEXTVAL
        into   x_instance_id
        from   sys.dual;

        raise NO_DATA_FOUND;  --jump to insert
    else
        select PROTECT_LEVEL, CUSTOM_LEVEL
        into protection_level, customization_level
        from WF_PROCESS_ACTIVITIES
        where INSTANCE_ID = x_instance_id;

        if (x_process_name <> 'ROOT') then
          if ((wf_core.upload_mode <> 'FORCE') and
              (protection_level < wf_core.session_level)) then
            x_level_error := 1;
            return;
          end if;

          if ((wf_core.upload_mode = 'UPGRADE') and
              (customization_level > wf_core.session_level)) then
            x_level_error := 2;
            return;
          end if;
        end if;
    end if;

    -- Validate PERFORM_ROLE
    l_perform_role_type := substr(x_perform_role_type, 1, 8);
    l_perform_role := substr(x_perform_role, 1, 320);
    if (l_perform_role_type = 'DEFER') then
      begin
        select NAME into l_perform_role
          from WF_ROLES
         where DISPLAY_NAME = x_perform_role
           and rownum < 2;
      exception
        when NO_DATA_FOUND then
          null;
      end;
      l_perform_role_type := 'CONSTANT';  -- reset to CONSTANT
    end if;

    -- if a performer is defined, check the validity and report error
    -- don't bother to make sure that tye activity type is NOTICE
    if (l_perform_role_type = 'CONSTANT' and l_perform_role is not null) then
      Wf_Directory.GetRoleInfo2(l_perform_role,role_info_tbl);
      if (role_info_tbl(1).name is null) then
        x_level_error := 8;
      end if;
    end if;

    -- Update existing row
    update WF_PROCESS_ACTIVITIES set
      PROCESS_ITEM_TYPE = x_process_item_type,
      PROCESS_NAME = x_process_name,
      PROCESS_VERSION = x_process_version,
      ACTIVITY_ITEM_TYPE = x_activity_item_type,
      ACTIVITY_NAME = x_activity_name,
      INSTANCE_LABEL = x_instance_label,
      PROTECT_LEVEL = x_protect_level,
      CUSTOM_LEVEL = x_custom_level,
      START_END = x_start_end,
      DEFAULT_RESULT = x_default_result,
      ICON_GEOMETRY = x_icon_geometry,
      PERFORM_ROLE = l_perform_role,
      PERFORM_ROLE_TYPE = l_perform_role_type,
      USER_COMMENT = x_user_comment
    where INSTANCE_ID = x_instance_id;
  exception
    when NO_DATA_FOUND then
      -- Check protection level for new row
      if ((wf_core.upload_mode <> 'FORCE') and
          (x_protect_level < wf_core.session_level)) then
        x_level_error := 4+1;
        return;
      end if;

      if ((wf_core.upload_mode = 'UPGRADE') and
          (x_custom_level > wf_core.session_level)) then
        x_level_error := 4+2;
        return;
      end if;

      -- Validate PERFORM_ROLE
      l_perform_role_type := substr(x_perform_role_type, 1, 8);
      l_perform_role := substr(x_perform_role, 1, 320);
      if (l_perform_role_type = 'DEFER') then
        begin
          select NAME into l_perform_role
            from WF_ROLES
           where DISPLAY_NAME = x_perform_role
             and rownum < 2;
        exception
          when NO_DATA_FOUND then
            null;
        end;
        l_perform_role_type := 'CONSTANT';  -- reset to CONSTANT
      end if;
      if (l_perform_role_type = 'CONSTANT' and l_perform_role is not null) then
        Wf_Directory.GetRoleInfo2(l_perform_role,role_info_tbl);
        if (role_info_tbl(1).name is null) then
          x_level_error := 8;
        end if;
      end if;

/* ### may not needed it, but just in case */
      -- Create a ROOT FOLDER if it does not exist
      --
      -- If version exists, noinsert is positive, that is not to insert.
      select nvl(max(VERSION), 1), count(1)
      into new_version, noinsert
      from WF_ACTIVITIES
      where ITEM_TYPE = x_process_item_type
      and NAME = 'ROOT';

      if (noinsert <= 0) then
        WF_LOAD.UPLOAD_ACTIVITY(
          x_item_type=>x_process_item_type,
          x_name=>'ROOT',
          x_type=>'FOLDER',
          x_display_name=>'ROOT',
          x_description=>'',
          x_rerun=>'RESET',
          x_protect_level=>x_protect_level,
          x_custom_level=>x_custom_level,
          x_effective_date=>sysdate,
          x_function=>'',
          x_function_type =>'',
          x_result_type=>'*',
          x_cost=>0,
          x_read_role=>'',
          x_write_role=>'',
          x_execute_role=>'',
          x_icon_name=>'ROOT',
          x_message=>'',
          x_error_process=>'',
          x_expand_role=>'N',
          x_error_item_type =>'WFERROR',
          x_runnable_flag =>'N',
          x_event_filter => '',
          x_event_type => '',
          x_log_message=>dummy_log_message,
          x_version=>dummy_version,
          x_level_error=>dummy_level_error);
      end if;

      -- If noinsert is positive, that is not to insert.
      -- Check if ROOT process of such activity has already been inserted,
      -- since each process activity must be attached to ROOT.
      select count(1)
        into noinsert
        from WF_PROCESS_ACTIVITIES
       where PROCESS_NAME = 'ROOT'
         and ACTIVITY_ITEM_TYPE = x_process_item_type
         and ACTIVITY_NAME = x_activity_name
         and  rownum=1;

      -- no need to insert when ROOT already exists (noinsert > 0)
      if (x_process_name <> 'ROOT' or noinsert <= 0) then
        -- Insert new row
        insert into WF_PROCESS_ACTIVITIES (
          PROCESS_ITEM_TYPE,
          PROCESS_NAME,
          PROCESS_VERSION,
          ACTIVITY_ITEM_TYPE,
          ACTIVITY_NAME,
          INSTANCE_ID,
          INSTANCE_LABEL,
          PROTECT_LEVEL,
          CUSTOM_LEVEL,
          START_END,
          DEFAULT_RESULT,
          ICON_GEOMETRY,
          PERFORM_ROLE,
          PERFORM_ROLE_TYPE,
          USER_COMMENT
         ) values (
          x_process_item_type,
          x_process_name,
          x_process_version,
          x_activity_item_type,
          x_activity_name,
          x_instance_id,
          x_instance_label,
          x_protect_level,
          x_custom_level,
          x_start_end,
          x_default_result,
          x_icon_geometry,
          l_perform_role,
          l_perform_role_type,
          x_user_comment
        );
      end if;

      --
      -- Create a new ROOT process if it does not exist
      -- if process name is ROOT, it should be inserted by the above
      -- statement.
      --
      if (x_process_name <> 'ROOT' and noinsert <= 0) then
        -- Insert a root process activity
        WF_LOAD.UPLOAD_PROCESS_ACTIVITY(
          x_process_item_type=>x_process_item_type,
          x_process_name=>'ROOT',
          x_process_version=>new_version,
          x_activity_item_type=>x_process_item_type,
          x_activity_name=>x_process_name,
          x_instance_id=>root_instance_id,
          x_instance_label=>x_process_name,
          x_protect_level=>x_protect_level,
          x_custom_level=>x_custom_level,
          x_start_end=>'',
          x_default_result=>'',
          x_icon_geometry=>'',
          x_perform_role=>'',
          x_perform_role_type=>'CONSTANT',
          x_user_comment=>'',
          x_level_error=>dummy_level_error
        );
      end if;

  end;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Upload_Process_Activity',x_process_name,
                    x_activity_name,
                    to_char(x_instance_id));
    raise;
end UPLOAD_PROCESS_ACTIVITY;

--
-- UPLOAD_ACTIVITY_ATTR_VALUE
--
procedure UPLOAD_ACTIVITY_ATTR_VALUE (
  x_process_activity_id in number,
  x_name in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_value in varchar2,
  x_value_type in varchar2,
  x_effective_date in date,
  x_level_error out NOCOPY number
) is
  protection_level number;
  customization_level number;
  l_type varchar2(8);
  l_text_value varchar2(4000) := '';
  l_number_value number := '';
  l_date_value date := '';
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Translate x_value to appropriate type.
  -- First have to get the type of this activity attr.
  --
  -- Special handles the hidden attributes first.
  --   add future hidden attributes here.
  if (x_name = '#TIMEOUT' or
      x_name = '#PRIORITY') then
    l_type := 'NUMBER';
  elsif (x_name = '#EVENTNAME' or x_name = '#EVENTKEY' or
        x_name = '#EVENTMESSAGE' or x_name = '#EVENTOUTAGENT' or
        x_name = '#EVENTTOAGENT') then
    l_type := 'TEXT';
  else
    --
    -- Handle regular attributes here
    --
    begin
      select WAA.TYPE
      into l_type
      from WF_PROCESS_ACTIVITIES WPA, WF_ACTIVITIES WA,
           WF_ACTIVITY_ATTRIBUTES WAA
      where WPA.INSTANCE_ID = x_process_activity_id
      and WPA.ACTIVITY_ITEM_TYPE = WA.ITEM_TYPE
      and WPA.ACTIVITY_NAME = WA.NAME
      and x_effective_date >= WA.BEGIN_DATE
      and x_effective_date < nvl(WA.END_DATE, x_effective_date+1)
      and WA.ITEM_TYPE = WAA.ACTIVITY_ITEM_TYPE
      and WA.NAME = WAA.ACTIVITY_NAME
      and WA.VERSION = WAA.ACTIVITY_VERSION
      and WAA.NAME = x_name;
    exception
      when no_data_found then
        -- If not found, then activity must not have this attr defined.
        -- (This can happen if process and activity uploaded with inconsistent
        -- protection levels.)
        -- In this case ignore the attr value setting.
        return;
    end;
  end if;

  -- Note for hidden attributes:
  --  When x_value_type is 'CONSTANT', l_type is always 'NUMBER'
  --  When x_value_type is 'ITEMATTR', l_type is always 'TEXT'
  --
  if ((x_value_type = 'CONSTANT') and (l_type = 'NUMBER')) then
    l_number_value := to_number(x_value);
  elsif ((x_value_type = 'CONSTANT') and (l_type = 'DATE')) then
    l_date_value := to_date(x_value, 'YYYY/MM/DD HH24:MI:SS');
  else
    l_text_value := x_value;
  end if;

  -- Check protection level
  x_level_error := 0;
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL
    into protection_level, customization_level
    from WF_ACTIVITY_ATTR_VALUES
    where PROCESS_ACTIVITY_ID = x_process_activity_id
    and NAME = x_name;

    if ((wf_core.upload_mode <> 'FORCE') and
        (protection_level < wf_core.session_level)) then
      x_level_error := 1;
      return;
    end if;

    if ((wf_core.upload_mode = 'UPGRADE') and
        (customization_level > wf_core.session_level)) then
      x_level_error := 2;
      return;
    end if;

    -- Update existing row
    update WF_ACTIVITY_ATTR_VALUES set
      PROTECT_LEVEL = x_protect_level,
      CUSTOM_LEVEL = x_custom_level,
      TEXT_VALUE = l_text_value,
      NUMBER_VALUE = l_number_value,
      DATE_VALUE = l_date_value,
      VALUE_TYPE = x_value_type
    where PROCESS_ACTIVITY_ID = x_process_activity_id
    and NAME = x_name;
  exception
    when NO_DATA_FOUND then
      -- Check protection level for new row
      -- ### Relax the checking on attributes, lookup_code, transitions
      if ((wf_core.upload_mode <> 'FORCE') and
          (x_protect_level < wf_core.session_level)) then
        x_level_error := 1;
        return;
      end if;

      if ((wf_core.upload_mode = 'UPGRADE') and
          (x_custom_level > wf_core.session_level)) then
        x_level_error := 2;
        return;
      end if;

      -- Insert new row
      insert into WF_ACTIVITY_ATTR_VALUES (
        PROCESS_ACTIVITY_ID,
        NAME,
        PROTECT_LEVEL,
        CUSTOM_LEVEL,
        TEXT_VALUE,
        NUMBER_VALUE,
        DATE_VALUE,
        VALUE_TYPE
      ) values (
        x_process_activity_id,
        x_name,
        x_protect_level,
        x_custom_level,
        l_text_value,
        l_number_value,
        l_date_value,
        x_value_type
      );
  end;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Upload_Activity_Attr_Value',
                    to_char(x_process_activity_id), x_name);
    raise;
end UPLOAD_ACTIVITY_ATTR_VALUE;

--
-- UPLOAD_ACTIVITY_TRANSITION
--
procedure UPLOAD_ACTIVITY_TRANSITION (
  x_from_process_activity in number,
  x_result_code in varchar2,
  x_to_process_activity in number,
  x_protect_level in number,
  x_custom_level in number,
  x_arrow_geometry in varchar2,
  x_level_error out  NOCOPY number
) is
  protection_level number;
  customization_level number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL
    into protection_level, customization_level
    from WF_ACTIVITY_TRANSITIONS
    where FROM_PROCESS_ACTIVITY = x_from_process_activity
    and RESULT_CODE = x_result_code
    and TO_PROCESS_ACTIVITY = x_to_process_activity;

    if ((wf_core.upload_mode <> 'FORCE') and
        (protection_level < wf_core.session_level)) then
      x_level_error := 1;
      return;
    end if;

    if ((wf_core.upload_mode = 'UPGRADE') and
        (customization_level > wf_core.session_level)) then
      x_level_error := 2;
      return;
    end if;

    -- Update existing row
    update WF_ACTIVITY_TRANSITIONS set
      FROM_PROCESS_ACTIVITY = x_from_process_activity,
      RESULT_CODE = x_result_code,
      TO_PROCESS_ACTIVITY = x_to_process_activity,
      PROTECT_LEVEL = x_protect_level,
      CUSTOM_LEVEL = x_custom_level,
      ARROW_GEOMETRY = x_arrow_geometry
    where FROM_PROCESS_ACTIVITY = x_from_process_activity
    and RESULT_CODE = x_result_code
    and TO_PROCESS_ACTIVITY = x_to_process_activity;
  exception
    when NO_DATA_FOUND then
      -- Check protection level for new row
      -- ### Relax the checking on attributes, lookup_code, transitions
      if ((wf_core.upload_mode <> 'FORCE') and
          (x_protect_level < wf_core.session_level)) then
        x_level_error := 1;
        return;
      end if;

      if ((wf_core.upload_mode = 'UPGRADE') and
          (x_custom_level > wf_core.session_level)) then
        x_level_error := 2;
        return;
      end if;

      -- Insert new row
      insert into WF_ACTIVITY_TRANSITIONS (
        FROM_PROCESS_ACTIVITY,
        RESULT_CODE,
        TO_PROCESS_ACTIVITY,
        PROTECT_LEVEL,
        CUSTOM_LEVEL,
        ARROW_GEOMETRY
      ) values (
        x_from_process_activity,
        x_result_code,
        x_to_process_activity,
        x_protect_level,
        x_custom_level,
        x_arrow_geometry
      );
  end;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Upload_Activity_Transition',
                    to_char(x_from_process_activity),
                    x_result_code,
                    to_char(x_to_process_activity));
    raise;
end UPLOAD_ACTIVITY_TRANSITION;

--
-- UPLOAD_RESOURCE
--
procedure UPLOAD_RESOURCE (
  x_type in varchar2,
  x_name in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_id in number,
  x_text in varchar2,
  x_level_error out NOCOPY number
) is

begin
  WF_RESOURCE_LOAD.UPLOAD_RESOURCE(x_type,
                                   x_name,
                                   x_protect_level,
                                   x_custom_level,
                                   x_id,
                                   x_text,
                                   x_level_error);

exception
  when others then
    Wf_Core.Context('Wf_Load', 'Upload_Resource', x_name, x_type);
    raise;
end UPLOAD_RESOURCE;

--
-- DELETE_LOOKUP_TYPE
--
procedure DELETE_LOOKUP_TYPE(
  x_lookup_type in varchar2,
  x_level_error out NOCOPY number
) is
  protection_level number;
  customization_level number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;
  select PROTECT_LEVEL, CUSTOM_LEVEL
  into protection_level, customization_level
  from WF_LOOKUP_TYPES
  where LOOKUP_TYPE = x_lookup_type;

  if ((wf_core.upload_mode <> 'FORCE') and
      (protection_level < wf_core.session_level)) then
    x_level_error := 1;
    return;
  end if;

  if ((wf_core.upload_mode = 'UPGRADE') and
      (customization_level > wf_core.session_level)) then
    x_level_error := 2;
    return;
  end if;

  -- Delete child lookups of this type
  Delete_Lookups(x_lookup_type, x_level_error);

  Wf_Lookup_Types_Pkg.Delete_Row(x_lookup_type => x_lookup_type);

exception
  when NO_DATA_FOUND then
    null;
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Delete_Lookup_Type', x_lookup_type);
    raise;
end DELETE_LOOKUP_TYPE;

--
-- DELETE_LOOKUP
--
procedure DELETE_LOOKUP(
  x_lookup_type in varchar2,
  x_lookup_code in varchar2,
  x_level_error out NOCOPY number
) is
  protection_level number;
  customization_level number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;
  select PROTECT_LEVEL, CUSTOM_LEVEL
  into protection_level, customization_level
  from WF_LOOKUPS
  where LOOKUP_TYPE = x_lookup_type
  and LOOKUP_CODE = x_lookup_code;

  if ((wf_core.upload_mode <> 'FORCE') and
      (protection_level < wf_core.session_level)) then
    x_level_error := 1;
    return;
  end if;

  if ((wf_core.upload_mode = 'UPGRADE') and
      (customization_level > wf_core.session_level)) then
    x_level_error := 2;
    return;
  end if;

  Wf_Lookups_Pkg.Delete_Row(
      x_lookup_type => x_lookup_type,
      x_lookup_code => x_lookup_code
  );

exception
  when NO_DATA_FOUND then
    null;
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Delete_Lookup', x_lookup_type, x_lookup_code);
    raise;
end DELETE_LOOKUP;

--
-- DELETE_LOOKUPS
--
procedure DELETE_LOOKUPS(
  x_lookup_type in varchar2,
  x_level_error out NOCOPY number
) is
  protection_level number;
  customization_level number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  X_LEVEL_ERROR := 0;
  select MIN(protect_level), MAX(custom_level)
  into protection_level, customization_level
  from WF_LOOKUP_TYPES_TL
  where LOOKUP_TYPE = X_LOOKUP_TYPE;

  if ((wf_core.upload_mode <> 'FORCE') and
      (protection_level < wf_core.session_level)) then
    x_level_error := 1;
    return;
  end if;

  if ((wf_core.upload_mode = 'UPGRADE') and
      (customization_level > wf_core.session_level)) then
    x_level_error := 2;
    return;
  end if;

  delete from WF_LOOKUPS_TL
  where LOOKUP_TYPE = X_LOOKUP_TYPE;

exception
  when NO_DATA_FOUND then
    null;
  when OTHERS then
    wf_core.context('WF_LOAD', 'DELETE_LOOKUPS');
    raise;
end DELETE_LOOKUPS;

--
-- DELETE_ITEM_TYPE
--
procedure DELETE_ITEM_TYPE(
  x_name in varchar2,
  x_level_error out NOCOPY number
) is
  protection_level number;
  customization_level number;
  l_persistence_type  varchar2(8);

  dummy number;
  fk_violation exception;
  pragma exception_init(fk_violation, -2292);

begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;
  select PROTECT_LEVEL, CUSTOM_LEVEL, PERSISTENCE_TYPE
  into protection_level, customization_level, l_persistence_type
  from WF_ITEM_TYPES_VL
  where NAME = x_name;

  if ((wf_core.upload_mode <> 'FORCE') and
      (protection_level < wf_core.session_level)) then
    x_level_error := 1;
    return;
  end if;

  if ((wf_core.upload_mode = 'UPGRADE') and
      (customization_level > wf_core.session_level)) then
    x_level_error := 2;
    return;
  end if;

  -- Set what persistence type to purge first
  Wf_Purge.persistence_type := l_persistence_type;

  -- Purge obsolete and unused activities in this itemtype.
  -- This is to give some hope of being able to delete the itemtype
  -- if it is really no longer in use, without interference from
  -- obsolete activity versions.
  Wf_Purge.Activities(itemtype => x_name);

  -- Delete item attributes
  Delete_Item_Attributes(x_name, x_level_error);

  -- Double check for fk references before the actual delete,
  -- just in case constraints are missing or disabled.
  begin
    select 1
    into dummy
    from sys.dual
    where not exists
      (select 1
      from WF_LOOKUP_TYPES
      where ITEM_TYPE = x_name)
    and not exists
      (select 1
      from WF_ACTIVITIES
      where ITEM_TYPE = x_name)
    and not exists
      (select 1
      from WF_MESSAGES
      where TYPE = x_name);
  exception
    when no_data_found then
      -- Bad row found.  Raise exception back to loader.
      raise fk_violation;
  end;

  Wf_Item_Types_Pkg.Delete_Row(x_name=>x_name);

exception
  when NO_DATA_FOUND then
    null;
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Delete_Item_Type', x_name);
    raise;
end DELETE_ITEM_TYPE;

--
-- DELETE_ITEM_ATTRIBUTE
--
procedure DELETE_ITEM_ATTRIBUTE(
  x_item_type in varchar2,
  x_name in varchar2,
  x_level_error out NOCOPY number
) is
  protection_level number;
  customization_level number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;
  select PROTECT_LEVEL, CUSTOM_LEVEL
  into protection_level, customization_level
  from WF_ITEM_ATTRIBUTES_VL
  where ITEM_TYPE = x_item_type
  and NAME = x_name;

  if ((wf_core.upload_mode <> 'FORCE') and
      (protection_level < wf_core.session_level)) then
    x_level_error := 1;
    return;
  end if;

  if ((wf_core.upload_mode = 'UPGRADE') and
      (customization_level > wf_core.session_level)) then
    x_level_error := 2;
    return;
  end if;

  Wf_Item_Attributes_Pkg.Delete_Row(
    x_item_type => x_item_type,
    x_name => x_name);

exception
  when NO_DATA_FOUND then
    null;
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Delete_Item_Attribute', x_item_type, x_name);
    raise;
end DELETE_ITEM_ATTRIBUTE;

--
-- DELETE_ITEM_ATTRIBUTES
--
procedure DELETE_ITEM_ATTRIBUTES(
  x_item_type in varchar2,
  x_level_error out NOCOPY number
) is
  protection_level number;
  customization_level number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;
  select PROTECT_LEVEL, CUSTOM_LEVEL
  into protection_level, customization_level
  from WF_ITEM_TYPES_VL
  where NAME = x_item_type;

  if ((wf_core.upload_mode <> 'FORCE') and
      (protection_level < wf_core.session_level)) then
    x_level_error := 1;
    return;
  end if;

  if ((wf_core.upload_mode = 'UPGRADE') and
      (customization_level > wf_core.session_level)) then
    x_level_error := 2;
    return;
  end if;

  delete from WF_ITEM_ATTRIBUTES_TL
  where ITEM_TYPE = X_ITEM_TYPE;

  delete from WF_ITEM_ATTRIBUTES
  where ITEM_TYPE = X_ITEM_TYPE;
exception
  when NO_DATA_FOUND then
    null;
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Delete_Item_Attributes', x_item_type);
    raise;
end DELETE_ITEM_ATTRIBUTES;

--
-- DELETE_MESSAGE
--
procedure DELETE_MESSAGE(
  x_type in varchar2,
  x_name in varchar2,
  x_level_error out NOCOPY number
) is
  protection_level number;
  customization_level number;

  dummy number;
  fk_violation exception;
  pragma exception_init(fk_violation, -2292);

begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;
  select PROTECT_LEVEL, CUSTOM_LEVEL
  into protection_level, customization_level
  from WF_MESSAGES
  where TYPE = x_type
  and NAME = x_name;

  if ((wf_core.upload_mode <> 'FORCE') and
      (protection_level < wf_core.session_level)) then
    x_level_error := 1;
    return;
  end if;

  if ((wf_core.upload_mode = 'UPGRADE') and
      (customization_level > wf_core.session_level)) then
    x_level_error := 2;
    return;
  end if;

  -- Delete message attributes
  Delete_Message_Attributes(x_type, x_name, x_level_error);

  -- Double check for fk references before the actual delete,
  -- just in case constraints are missing or disabled.
  begin
    select 1
    into dummy
    from sys.dual
    where not exists
      (select 1
      from WF_ACTIVITIES
      where ITEM_TYPE = x_type
      and MESSAGE = x_name)
    and not exists
      (select 1
      from WF_NOTIFICATIONS
      where MESSAGE_TYPE = x_type
      and MESSAGE_NAME = x_name);
  exception
    when no_data_found then
      -- Bad row found.  Raise exception back to loader.
      raise fk_violation;
  end;

  Wf_Messages_Pkg.Delete_Row(x_type => x_type, x_name => x_name);

exception
  when NO_DATA_FOUND then
    null;
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Delete_Message', x_type, x_name);
    raise;
end DELETE_MESSAGE;

--
-- DELETE_MESSAGE_ATTRIBUTE
--
procedure DELETE_MESSAGE_ATTRIBUTE(
  x_message_type in varchar2,
  x_message_name in varchar2,
  x_name in varchar2,
  x_level_error out NOCOPY number
) is
  protection_level number;
  customization_level number;
begin

  -- Check protection level
  x_level_error := 0;
  select PROTECT_LEVEL, CUSTOM_LEVEL
  into protection_level, customization_level
  from WF_MESSAGE_ATTRIBUTES_VL
  where MESSAGE_TYPE = x_message_type
  and MESSAGE_NAME = x_message_name
  and NAME = x_name;

  if ((wf_core.upload_mode <> 'FORCE') and
      (protection_level < wf_core.session_level)) then
    x_level_error := 1;
    return;
  end if;

  if ((wf_core.upload_mode = 'UPGRADE') and
      (customization_level > wf_core.session_level)) then
    x_level_error := 2;
    return;
  end if;

  Wf_Message_Attributes_Pkg.Delete_Row(
      x_message_type => x_message_type,
      x_message_name => x_message_name,
      x_name => x_name);

exception
  when NO_DATA_FOUND then
    null;
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Delete_Message_Attribute', x_message_type,
        x_message_name, x_name);
    raise;
end DELETE_MESSAGE_ATTRIBUTE;

--
-- DELETE_MESSAGE_ATTRIBUTES
--
procedure DELETE_MESSAGE_ATTRIBUTES(
  x_message_type in varchar2,
  x_message_name in varchar2,
  x_level_error out NOCOPY number
) is
  protection_level NUMBER;
  customization_level NUMBER;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;
  select PROTECT_LEVEL, CUSTOM_LEVEL
  into protection_level, customization_level
  from WF_MESSAGES
  where TYPE = x_message_type
  and NAME = x_message_name;

  if ((wf_core.upload_mode <> 'FORCE') and
      (protection_level < wf_core.session_level)) then
    x_level_error := 1;
    return;
  end if;

  if ((wf_core.upload_mode = 'UPGRADE') and
      (customization_level > wf_core.session_level)) then
    x_level_error := 2;
    return;
  end if;

  delete from WF_MESSAGE_ATTRIBUTES_TL
  where MESSAGE_TYPE = x_message_type
  and MESSAGE_NAME = x_message_name;

  delete from WF_MESSAGE_ATTRIBUTES
  where MESSAGE_TYPE = x_message_type
  and MESSAGE_NAME = x_message_name;

exception
  when NO_DATA_FOUND then
      null;
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Delete_Message_Attributes', x_message_type,
                    x_message_name);
    raise;
end DELETE_MESSAGE_ATTRIBUTES;

--
-- DELETE_ACTIVITY
--
procedure DELETE_ACTIVITY(
  x_item_type in varchar2,
  x_name in varchar2,
  x_level_error out NOCOPY number
) is
  protection_level number;
  customization_level number;
  l_persistence_type varchar2(8);
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;

  select PROTECT_LEVEL, CUSTOM_LEVEL
  into protection_level, customization_level
  from WF_ACTIVITIES_VL
  where ITEM_TYPE = x_item_type
  and NAME = x_name
  and END_DATE is null;

  if ((wf_core.upload_mode <> 'FORCE') and
      (protection_level < wf_core.session_level)) then
    x_level_error := 1;
    return;
  end if;

  if ((wf_core.upload_mode = 'UPGRADE') and
      (customization_level > wf_core.session_level)) then
    x_level_error := 2;
    return;
  end if;

  -- Do not delete, only set end_date
  update WF_ACTIVITIES set
    end_date = sysdate
  where ITEM_TYPE = x_item_type
  and NAME = x_name
  and END_DATE is null;

  -- Find out what persistence type it belongs
  select PERSISTENCE_TYPE
  into   l_persistence_type
  from   WF_ITEM_TYPES
  where  NAME = x_item_type;

  Wf_Purge.persistence_type := l_persistence_type;

  -- Purge obsolete and unused versions of the activity
  Wf_Purge.Activities(
    itemtype => x_item_type,
    name => x_name);

exception
  when NO_DATA_FOUND then
    null;
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Delete_Activity', x_item_type, x_name);
    raise;
end DELETE_ACTIVITY;

--
-- WebDB Integration
--

--
-- Delete_Transition
-- IN
--   p_previous_step - instance id of the FROM process activity
--   p_next_step     - instance id of the TO process activity
--   P_result_code   - result code of this transition
-- NOTE
--   It is possible to leave an invalid Workflow definition after this
-- call.
--   Ignores the criteria with a null arguement.
--   p_previous_step and p_next_step cannot be both null.
procedure Delete_Transition(
  p_previous_step in number ,
  p_next_step     in number ,
  p_result_code   in varchar2 )
is
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  if (p_previous_step is null and p_next_step is null) then
    -- do not delete anything if both are null
    return;
  end if;

  if (p_next_step is null) then
    delete WF_ACTIVITY_TRANSITIONS
      where FROM_PROCESS_ACTIVITY = p_previous_step
        and RESULT_CODE = nvl(p_result_code, RESULT_CODE);
  else
    if (p_previous_step is null) then
      delete WF_ACTIVITY_TRANSITIONS
        where TO_PROCESS_ACTIVITY = p_next_step
          and RESULT_CODE = nvl(p_result_code, RESULT_CODE);
    else
      -- both are non-null
      delete WF_ACTIVITY_TRANSITIONS
        where FROM_PROCESS_ACTIVITY = p_previous_step
          and RESULT_CODE = nvl(p_result_code, RESULT_CODE)
          and TO_PROCESS_ACTIVITY = p_next_step;
    end if;
  end if;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Delete_Transition', p_previous_step,
                    p_next_step, p_result_code);
    raise;
end;

--
-- Get_Process_Activity
-- IN
--   p_activity_instance - instance id of a process activity
-- OUT
--   p_xcor          - X coordinate of the icon geometry
--   p_ycor          - Y coordinate of the icon geometry
--   p_activity_name - internal name of this process activity
-- NOTE
--
procedure Get_Process_Activity(
  p_activity_instance in  number,
  p_xcor              out NOCOPY number,
  p_ycor              out NOCOPY number,
  p_activity_name     out NOCOPY varchar2,
  p_instance_label    out NOCOPY varchar2)
is
  l_icon_geometry  varchar2(2000);
  comma_position   number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  select ICON_GEOMETRY, ACTIVITY_NAME, INSTANCE_LABEL
    into l_icon_geometry, p_activity_name, p_instance_label
    from WF_PROCESS_ACTIVITIES
   where instance_id = p_activity_instance;

  comma_position := instr(l_icon_geometry, ',');
  p_xcor := to_number(substr(l_icon_geometry, 1, comma_position - 1));
  p_ycor := to_number(substr(l_icon_geometry, comma_position + 1));

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Process_Activity', p_activity_instance);
    raise;
end;

--
-- Update_Message
-- IN
--   p_type  - item type of message
--   p_name  - message name
--   p_subject  - message subject
--   p_body  - text body
--   p_html_body  - html formated body
-- OUT
--   x_level_error - the output of error level
-- NOTE
--   It first selects the values related to the message
--   and then calls UPLOAD_MESSAGE to update the value.
--
procedure UPDATE_MESSAGE (
  p_type in varchar2,
  p_name in varchar2,
  p_subject in varchar2,
  p_body in varchar2,
  p_html_body in varchar2,
  p_level_error out NOCOPY number
)
is
  l_protect_level     number;
  l_custom_level      number;
  l_default_priority  number;
  l_display_name      varchar2(80);
  l_description       varchar2(240);
  l_subject           varchar2(240);
  l_body              varchar2(4000);
  l_html_body         varchar2(4000);
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  Wf_Load.Get_Message(p_type, p_name, l_protect_level, l_custom_level,
                      l_default_priority, l_display_name, l_description,
                      l_subject, l_body, l_html_body);

  if (p_subject is not null) then
    l_subject := p_subject;
  end if;

  if (p_body is not null) then
    l_body := p_body;
  end if;

  if (p_html_body is not null) then
    l_html_body := p_html_body;
  end if;

  Wf_Load.UPLOAD_MESSAGE(
    x_type => p_type,
    x_name => p_name,
    x_display_name => l_display_name,
    x_description => l_description,
    x_subject => l_subject,
    x_body => l_body,
    x_html_body => l_html_body,
    x_protect_level => l_protect_level,
    x_custom_level => l_custom_level,
    x_default_priority => l_default_priority,
    x_read_role => null,
    x_write_role => null,
    x_level_error => p_level_error);

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Message', p_type, p_name);
    raise;
end;

--
-- Get_MESSAGE
-- IN
--   p_type  - message item type
--   p_name  - message name
-- OUT
--   p_protect_level -
--   p_custom_level  -
--   p_default_priority -
--   p_display_name  - 80
--   p_description   - 240
--   p_subject       - 240
--   p_body          - 4000
--   p_html_body     - 4000
--
procedure GET_MESSAGE (
  p_type             in  varchar2,
  p_name             in  varchar2,
  p_protect_level    out NOCOPY number,
  p_custom_level     out NOCOPY number,
  p_default_priority out NOCOPY number,
  p_display_name     out NOCOPY varchar2,
  p_description      out NOCOPY varchar2,
  p_subject          out NOCOPY varchar2,
  p_body             out NOCOPY varchar2,
  p_html_body        out NOCOPY varchar2
)
is
begin
  select PROTECT_LEVEL,
         CUSTOM_LEVEL,
         DEFAULT_PRIORITY,
         DISPLAY_NAME,
         DESCRIPTION,
         SUBJECT,
         BODY,
         HTML_BODY
    into
         p_protect_level,
         p_custom_level,
         p_default_priority,
         p_display_name,
         p_description,
         p_subject,
         p_body,
         p_html_body
    from WF_MESSAGES_VL
   where TYPE = p_type
     and NAME = p_name;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Message', p_type, p_name);
    raise;
end;

--
-- COPY_ITEM_TYPE
-- IN
--   p_item_type            - item type to copy from.
--   p_destination_item_type- new item type.
--   p_new_suffix           - suffix to use append to internal names
--                            of new entities.
-- NOTE
--
procedure COPY_ITEM_TYPE(
  p_item_type             in  varchar2,
  p_destination_item_type in  varchar2,
  p_new_suffix            in  varchar2)
is
  type t_ittRecord is record (
    protect_level     number,
    custom_level      number,
    name              varchar2(8),
    display_name      varchar2(80),
    description       varchar2(240),
    wf_selector       varchar2(240),
    read_role         varchar2(320),
    write_role        varchar2(320),
    execute_role      varchar2(320),
    persistence_type  varchar2(8),
    persistence_days  varchar2(8));

  v_itt t_ittRecord;

  cursor itacur(itt in varchar2) is
  select PROTECT_LEVEL, CUSTOM_LEVEL, NAME, DISPLAY_NAME, DESCRIPTION,
         TYPE, SUBTYPE, FORMAT, TEXT_DEFAULT,
         to_char(NUMBER_DEFAULT) NUMBER_DEFAULT,
         to_char(DATE_DEFAULT, 'YYYY/MM/DD HH24:MI:SS') DATE_DEFAULT,
         SEQUENCE
  from   WF_ITEM_ATTRIBUTES_VL
  where  ITEM_TYPE = itt
  order by SEQUENCE;

  cursor lutcur(itt in varchar2) is
  select PROTECT_LEVEL, CUSTOM_LEVEL, LOOKUP_TYPE, DISPLAY_NAME,
         DESCRIPTION
  from   WF_LOOKUP_TYPES
  where  ITEM_TYPE = itt
  order by LOOKUP_TYPE;

  type t_lutTable is table of WF_LOOKUP_TYPES.LOOKUP_TYPE%TYPE
    index by binary_integer;

  v_lut t_lutTable;

  cursor luccur(lut in varchar2) is
  select PROTECT_LEVEL, CUSTOM_LEVEL, LOOKUP_CODE, MEANING, DESCRIPTION
  from   WF_LOOKUPS
  where  LOOKUP_TYPE = lut
  order by LOOKUP_CODE;

  cursor msgcur(itt in varchar2) is
  select PROTECT_LEVEL, CUSTOM_LEVEL, NAME, DISPLAY_NAME, DESCRIPTION,
         SUBJECT, BODY, DEFAULT_PRIORITY, READ_ROLE, WRITE_ROLE,
         HTML_BODY
  from   WF_MESSAGES_VL
  where  TYPE = itt
  order by TYPE, NAME;

  type t_msgTable is table of WF_MESSAGES.NAME%TYPE
    index by binary_integer;

  v_msg t_msgTable;

  cursor msacur(itt in varchar2, msg in varchar2) is
  select PROTECT_LEVEL, CUSTOM_LEVEL, NAME, DISPLAY_NAME, DESCRIPTION,
         TYPE, SUBTYPE, FORMAT, TEXT_DEFAULT,
         to_char(NUMBER_DEFAULT) NUMBER_DEFAULT,
         to_char(DATE_DEFAULT, 'YYYY/MM/DD HH24:MI:SS') DATE_DEFAULT,
         VALUE_TYPE, ATTACH, SEQUENCE
  from   WF_MESSAGE_ATTRIBUTES_VL
  where  MESSAGE_TYPE = itt and MESSAGE_NAME = msg
  order by SEQUENCE;

  cursor actcur(itt in varchar2) is
  select PROTECT_LEVEL, CUSTOM_LEVEL, NAME, DISPLAY_NAME, DESCRIPTION,
         ITEM_TYPE, VERSION, TYPE, RERUN, FUNCTION, RESULT_TYPE, COST,
         ICON_NAME, MESSAGE, ERROR_PROCESS, EXPAND_ROLE,
         READ_ROLE, WRITE_ROLE, EXECUTE_ROLE,
         to_char(BEGIN_DATE, 'YYYY/MM/DD HH24:MI:SS') EFFECTIVE_DATE,
         ERROR_ITEM_TYPE, RUNNABLE_FLAG, FUNCTION_TYPE,
         EVENT_NAME, DIRECTION
  from   WF_ACTIVITIES_VL
  where  sysdate >= BEGIN_DATE
  and    (sysdate < END_DATE or END_DATE is null)
  and    ITEM_TYPE = itt
  order by item_type, name;

  type t_actRecord is record (
    name              varchar2(30),
    version           number);

  type t_actTable is table of t_actRecord index by binary_integer;

  v_act t_actTable;

  cursor atacur(itt in varchar2, actname in varchar2, ver in number) is
  select PROTECT_LEVEL, CUSTOM_LEVEL, NAME, DISPLAY_NAME, DESCRIPTION,
         TYPE, SUBTYPE, FORMAT, TEXT_DEFAULT,
         to_char(NUMBER_DEFAULT) NUMBER_DEFAULT,
         to_char(DATE_DEFAULT, 'YYYY/MM/DD HH24:MI:SS') DATE_DEFAULT,
         VALUE_TYPE, SEQUENCE
  from   WF_ACTIVITY_ATTRIBUTES_VL
  where  ACTIVITY_ITEM_TYPE = itt
  and    ACTIVITY_NAME = actname
  and    ACTIVITY_VERSION = ver
  order by SEQUENCE;

  type t_pacTable is table of WF_PROCESS_ACTIVITIES.INSTANCE_ID%TYPE
    index by binary_integer;

  v_opac t_pacTable;
  v_npac t_pacTable;

  cursor paccur(itt in varchar2, actname in varchar2, ver in number) is
  select ACTIVITY_ITEM_TYPE, ACTIVITY_NAME, INSTANCE_ID, START_END,
         DEFAULT_RESULT, ICON_GEOMETRY, PERFORM_ROLE,
         USER_COMMENT, PERFORM_ROLE_TYPE, INSTANCE_LABEL,
         PROTECT_LEVEL, CUSTOM_LEVEL
  from   WF_PROCESS_ACTIVITIES
  where  PROCESS_ITEM_TYPE = itt
  and    PROCESS_NAME = actname
  and    PROCESS_VERSION = ver
  order by INSTANCE_ID;

  cursor patcur(id in number) is
  select RESULT_CODE, TO_PROCESS_ACTIVITY, ARROW_GEOMETRY,
         PROTECT_LEVEL, CUSTOM_LEVEL
  from   WF_ACTIVITY_TRANSITIONS
  where  FROM_PROCESS_ACTIVITY = id
  order by RESULT_CODE;

  cursor aavcur(id in number) is
  select NAME, VALUE_TYPE, PROTECT_LEVEL, CUSTOM_LEVEL,
         TEXT_VALUE,
         to_char(NUMBER_VALUE) NUMBER_VALUE,
         to_char(DATE_VALUE, 'YYYY/MM/DD HH24:MI:SS') DATE_VALUE
  from   WF_ACTIVITY_ATTR_VALUES
  where  PROCESS_ACTIVITY_ID = id;

  l_item_type   varchar2(8);
  l_default     varchar2(4000);
  l_value       varchar2(4000);
  l_format      varchar2(240);
  l_result_type varchar2(30);
  l_message     varchar2(30);
  l_pname       varchar2(30);
  l_name        varchar2(30);
  l_dname       varchar2(80);
  l_performer   varchar2(30);
  l_version     number;
  l_level_error number;
  i             pls_integer;
  toid          pls_integer;
  ismatch       boolean := false;
  no_match      exception;
  dummy_log_message varchar2(32000);
begin
  -- Copying Item Type
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL, NAME, DISPLAY_NAME, DESCRIPTION,
           WF_SELECTOR, READ_ROLE, WRITE_ROLE, EXECUTE_ROLE,
           PERSISTENCE_TYPE,
           to_char(PERSISTENCE_DAYS) PERSISTENCE_DAYS
    into   v_itt
    from   WF_ITEM_TYPES_VL
    where  NAME = p_item_type;
  exception
    when others then
      Wf_Core.Context('Wf_Load', 'Selecting ITEM_TYPE', p_item_type);
      raise;
  end;

  begin
    select DISPLAY_NAME
    into   l_dname
    from   WF_ITEM_TYPES_VL
    where  NAME = p_destination_item_type;
  exception
    when NO_DATA_FOUND then
      l_dname := substr(v_itt.display_name||p_new_suffix,1,80);

    when OTHERS then
      raise;
  end;

  Wf_Load.UPLOAD_ITEM_TYPE(
    x_name=> p_destination_item_type,
    x_display_name=> l_dname,
    x_description=> v_itt.description,
    x_protect_level=> v_itt.protect_level,
    x_custom_level=> v_itt.custom_level,
    x_wf_selector=> v_itt.wf_selector,
    x_read_role=> v_itt.read_role,
    x_write_role=> v_itt.write_role,
    x_execute_role=> v_itt.execute_role,
    x_persistence_type=> v_itt.persistence_type,
    x_persistence_days=> v_itt.persistence_days,
    x_level_error=> l_level_error
  );
  l_dname := null;

  if (l_level_error <> 0) then
    Wf_Core.Token('ENTITY', 'ITEM_TYPE');
    Wf_Core.Token('TYPE', '');
    Wf_Core.Token('NAME', p_destination_item_type);
    Wf_Core.Raise('WFLDRSD_UPI');
  end if;


  -- Copy Lookup Types
  i := 1;
  for lutr in lutcur(p_item_type) loop
    v_lut(i) := lutr.LOOKUP_TYPE;
    Wf_Load.UPLOAD_LOOKUP_TYPE (
      x_lookup_type=>substr(lutr.lookup_type||p_new_suffix, 1, 30),
      x_display_name=>substr(lutr.display_name||p_new_suffix, 1, 80),
      x_description=>lutr.description,
      x_protect_level=>lutr.protect_level,
      x_custom_level=>lutr.custom_level,
      x_item_type=>p_destination_item_type,
      x_level_error=>l_level_error
    );
    if (l_level_error <> 0) then
      Wf_Core.Token('ENTITY', 'LOOKUP_TYPE');
      Wf_Core.Token('TYPE', p_destination_item_type);
      Wf_Core.Token('NAME', substr(lutr.lookup_type||p_new_suffix, 1, 30));
      Wf_Core.Raise('WFLDRSD_UPI');
    end if;
    i := i + 1;
  end loop;

  -- Copy Lookup Codes
  for j in 1..v_lut.count loop
    for lucr in luccur(v_lut(j)) loop
      Wf_Load.UPLOAD_LOOKUP (
        x_lookup_type=>substr(v_lut(j)||p_new_suffix, 1, 30),
        x_lookup_code=>lucr.lookup_code,
        x_meaning=>lucr.meaning,
        x_description=>lucr.description,
        x_protect_level=>lucr.protect_level,
        x_custom_level=>lucr.custom_level,
        x_level_error=>l_level_error
      );
      if (l_level_error <> 0) then
        Wf_Core.Token('ENTITY', 'LOOKUP_CODE');
        Wf_Core.Token('TYPE', substr(v_lut(j)||p_new_suffix, 1, 30));
        Wf_Core.Token('NAME', lucr.lookup_code);
        Wf_Core.Raise('WFLDRSD_UPI');
      end if;
    end loop;
  end loop;

  -- Copy Item Attributes
  for itar in itacur(p_item_type) loop
    l_format := itar.format;
    if (itar.type = 'LOOKUP') then
      for k in 1..v_lut.count loop
        if (itar.format = v_lut(k)) then
          l_format := substr(v_lut(k)||p_new_suffix, 1, 30);
        end if;
      end loop;
    end if;
    if (itar.type = 'NUMBER') then
      l_default := itar.number_default;
    elsif (itar.type = 'DATE') then
      l_default := itar.date_default;
    else
      l_default := itar.text_default;
    end if;

    Wf_Load.UPLOAD_ITEM_ATTRIBUTE(
      x_item_type=>p_destination_item_type,
      x_name=>substr(itar.name||p_new_suffix, 1, 30),
      x_display_name=>substr(itar.display_name||p_new_suffix, 1, 80),
      x_description=>itar.description,
      x_sequence=>itar.sequence,
      x_type=>itar.type,
      x_protect_level=>itar.protect_level,
      x_custom_level=>itar.custom_level,
      x_subtype=>itar.subtype,
      x_format=>l_format,
      x_default=>l_default,
      x_level_error=>l_level_error
    );
    if (l_level_error <> 0) then
      Wf_Core.Token('ENTITY', 'ITEM_ATTRIBUTE');
      Wf_Core.Token('TYPE', p_destination_item_type);
      Wf_Core.Token('NAME', itar.name);
      Wf_Core.Raise('WFLDRSD_UPI');
    end if;
  end loop;

  -- Copy Message
  i := 1;
  for msgr in msgcur(p_item_type) loop
    v_msg(i) := msgr.name;
    Wf_Load.UPLOAD_MESSAGE (
      x_type=>p_destination_item_type,
      x_name=>substr(msgr.name||p_new_suffix,1,30),
      x_display_name=>substr(msgr.display_name||p_new_suffix,1,80),
      x_description=>msgr.description,
      x_subject=>msgr.subject,
      x_body=>msgr.body,
      x_html_body=>msgr.html_body,
      x_protect_level=>msgr.protect_level,
      x_custom_level=>msgr.custom_level,
      x_default_priority=>msgr.default_priority,
      x_read_role=>msgr.read_role,
      x_write_role=>msgr.write_role,
      x_level_error=>l_level_error
    );
    if (l_level_error <> 0) then
      Wf_Core.Token('ENTITY', 'MESSAGE');
      Wf_Core.Token('TYPE', p_destination_item_type);
      Wf_Core.Token('NAME', msgr.name);
      Wf_Core.Raise('WFLDRSD_UPI');
    end if;
    i := i + 1;
  end loop;

  for j in 1..v_msg.count loop
    for msar in msacur(p_item_type,v_msg(j)) loop
      l_format := msar.format;
      l_name := msar.name;
      if (msar.type = 'LOOKUP') then
        for k in 1..v_lut.count loop
          if (msar.format = v_lut(k)) then
            l_format := substr(v_lut(k)||p_new_suffix, 1, 30);
          end if;
        end loop;
      end if;
      if (msar.value_type = 'CONSTANT') then
        if (msar.type = 'NUMBER') then
          l_default := msar.number_default;
        elsif (msar.type = 'DATE') then
          l_default := msar.date_default;
        else
          l_default := msar.text_default;
        end if;
      else
        -- must be ITEMATTR
        l_default := substr(msar.text_default||p_new_suffix, 1, 30);
        -- message attribute name needs to be changed for RESPOND attribute
        -- that is not RESULT
        if (msar.subtype = 'RESPOND' and msar.name <> 'RESULT') then
          l_name := substr(msar.name||p_new_suffix, 1, 30);
        end if;
      end if;

      Wf_Load.UPLOAD_MESSAGE_ATTRIBUTE(
        x_message_type=>p_destination_item_type,
        x_message_name=>substr(v_msg(j)||p_new_suffix,1,30),
        x_name=>l_name,
        x_display_name=>msar.display_name,
        x_description=>msar.description,
        x_sequence=>msar.sequence,
        x_type=>msar.type,
        x_subtype=>msar.subtype,
        x_protect_level=>msar.protect_level,
        x_custom_level=>msar.custom_level,
        x_format=>l_format,
        x_default=>l_default,
        x_value_type=>msar.value_type,
        x_attach=>msar.attach,
        x_level_error=>l_level_error
      );
      if (l_level_error <> 0) then
        Wf_Core.Token('ENTITY', 'MESSAGE_ATTRIBUTE');
        Wf_Core.Token('TYPE', v_msg(j));
        Wf_Core.Token('NAME', msar.name);
        Wf_Core.Raise('WFLDRSD_UPI');
      end if;
    end loop;
  end loop;

  -- Copy Activity
  i := 1;
  for actr in actcur(p_item_type) loop
    v_act(i).name := actr.name;
    v_act(i).version := actr.version;

    l_result_type := actr.result_type;
    for k in 1..v_lut.count loop
      if (actr.result_type = v_lut(k)) then
        l_result_type := substr(v_lut(k)||p_new_suffix, 1, 30);
      end if;
    end loop;

    if (actr.type = 'NOTICE') then
      l_message := substr(actr.message||p_new_suffix,1,30);
    else
      l_message := actr.message;
    end if;

    if (actr.name = 'ROOT') then
      l_name := actr.name;
      l_dname := actr.display_name;
    else
      l_name := substr(actr.name||p_new_suffix,1,30);
      l_dname := substr(actr.display_name||p_new_suffix,1,80);
    end if;

    Wf_Load.UPLOAD_ACTIVITY (
      x_item_type=>p_destination_item_type,
      x_name=>l_name,
      x_display_name=>l_dname,
      x_description=>actr.description,
      x_type=>actr.type,
      x_rerun=>actr.rerun,
      x_protect_level=>actr.protect_level,
      x_custom_level=>actr.custom_level,
      x_effective_date=>sysdate,
      x_function=>actr.function,
      x_function_type=>actr.function_type,
      x_result_type=>l_result_type,
      x_cost=>actr.cost,
      x_read_role=>actr.read_role,
      x_write_role=>actr.write_role,
      x_execute_role=>actr.execute_role,
      x_icon_name=>actr.icon_name,
      x_message=>l_message,
      x_error_process=>actr.error_process,
      x_expand_role=>actr.expand_role,
      x_error_item_type=>actr.error_item_type,
      x_runnable_flag=>actr.runnable_flag,
      x_event_filter => actr.event_name,
      x_event_type => actr.direction,
      x_log_message=>dummy_log_message,
      x_version=>l_version,
      x_level_error=>l_level_error
    );
    if (l_level_error <> 0) then
      Wf_Core.Token('ENTITY', 'ACTIVITY');
      Wf_Core.Token('TYPE', p_destination_item_type);
      Wf_Core.Token('NAME', actr.name);
      Wf_Core.Raise('WFLDRSD_UPI');
    end if;
    i := i + 1;
  end loop;

  for j in 1..v_act.count loop
    for atar in atacur(p_item_type,v_act(j).name,v_act(j).version) loop
      l_format := atar.format;
      if (atar.type = 'LOOKUP') then
        for k in 1..v_lut.count loop
          if (atar.format = v_lut(k)) then
            l_format := substr(v_lut(k)||p_new_suffix, 1, 30);
          end if;
        end loop;
      end if;
      if (atar.value_type = 'CONSTANT') then
        if (atar.type = 'NUMBER') then
          l_default := atar.number_default;
        elsif (atar.type = 'DATE') then
          l_default := atar.date_default;
        else
          l_default := atar.text_default;
        end if;
      else
        -- must be ITEMATTR
        l_default := substr(atar.text_default||p_new_suffix, 1, 30);
      end if;

      -- version below is always 1, the first one.
      Wf_Load.UPLOAD_ACTIVITY_ATTRIBUTE(
        x_activity_item_type=>p_destination_item_type,
        x_activity_name=>substr(v_act(j).name||p_new_suffix,1,30),
        x_activity_version=>1,
        x_name=>atar.name,
        x_display_name=>atar.display_name,
        x_description=>atar.description,
        x_sequence=>atar.sequence,
        x_type=>atar.type,
        x_protect_level=>atar.protect_level,
        x_custom_level=>atar.custom_level,
        x_subtype=>atar.subtype,
        x_format=>l_format,
        x_default=>l_default,
        x_value_type=>atar.value_type,
        x_level_error=>l_level_error
      );
      if (l_level_error <> 0) then
        Wf_Core.Token('ENTITY', 'ACTIVITY_ATTRIBUTE');
        Wf_Core.Token('TYPE', substr(v_act(j).name,1,30));
        Wf_Core.Token('NAME', atar.name);
        Wf_Core.Raise('WFLDRSD_UPI');
      end if;
    end loop;
  end loop;

  -- Copy Process Activity
  i := 1;
  for j in 1..v_act.count loop
    for pacr in paccur(p_item_type,v_act(j).name,v_act(j).version) loop
      v_opac(i) := pacr.instance_id;
      v_npac(i) := 0;
      -- make sure activity_item_type is consistant
      if (pacr.activity_item_type = p_item_type) then
        l_item_type := p_destination_item_type;
        l_name := substr(pacr.activity_name||p_new_suffix,1,30);
      else
        l_item_type := pacr.activity_item_type;
        l_name := pacr.activity_name;
      end if;

      if (v_act(j).name = 'ROOT') then
        l_pname := v_act(j).name;
      else
        l_pname := substr(v_act(j).name||p_new_suffix,1,30);
      end if;

      if (pacr.perform_role_type = 'ITEMATTR') then
        l_performer := substr(pacr.perform_role||p_new_suffix,1,30);
      else
        l_performer := pacr.perform_role;
      end if;

      -- check if process activity already exists
      begin
        select INSTANCE_ID into v_npac(i)
        from   WF_PROCESS_ACTIVITIES
        where  INSTANCE_LABEL = pacr.instance_label
        and    PROCESS_ITEM_TYPE = p_destination_item_type
        and    PROCESS_NAME = l_pname
        and    PROCESS_VERSION = 1;
      exception
        when NO_DATA_FOUND then
          v_npac(i) := 0;

          Wf_Load.UPLOAD_PROCESS_ACTIVITY (
            x_process_item_type=>p_destination_item_type,
            x_process_name=>l_pname,
            x_process_version=>1,
            x_activity_item_type=>l_item_type,
            x_activity_name=>l_name,
            x_instance_id=>v_npac(i),
            x_instance_label=>pacr.instance_label,
            x_protect_level=>pacr.protect_level,
            x_custom_level=>pacr.custom_level,
            x_start_end=>pacr.start_end,
            x_default_result=>pacr.default_result,
            x_icon_geometry=>pacr.icon_geometry,
            x_perform_role=>l_performer,
            x_perform_role_type=>pacr.perform_role_type,
            x_user_comment=>pacr.user_comment,
            x_level_error=>l_level_error
          );
          if (l_level_error <> 0) then
            Wf_Core.Token('ENTITY', 'PROCESS_ACTIVITY');
            Wf_Core.Token('TYPE', v_act(j).name);
            Wf_Core.Token('NAME', pacr.activity_name);
            Wf_Core.Raise('WFLDRSD_UPI');
          end if;
      end;
      i := i + 1;
    end loop;
  end loop;

  for j in 1..v_opac.count loop

    -- Copy Activity Transitions
    for patr in patcur(v_opac(j)) loop
      ismatch := false;
      for k in 1..v_opac.count loop
        -- find the index of to_process_activity
        if v_opac(k) = patr.to_process_activity then
          toid := k;
          ismatch := true;
          exit;
        end if;
      end loop;
      if (not ismatch) then
        -- ### dbms_output.put_line('no match for transition: '||
        -- ###                     to_char(patr.to_process_activity));
        -- ### should raise error here.
        raise no_match;
      end if;

      Wf_Load.UPLOAD_ACTIVITY_TRANSITION (
        x_from_process_activity=>v_npac(j),
        x_result_code=>patr.result_code,
        x_to_process_activity=>v_npac(toid),
        x_protect_level=>patr.protect_level,
        x_custom_level=>patr.custom_level,
        x_arrow_geometry=>patr.arrow_geometry,
        x_level_error=>l_level_error
      );
      if (l_level_error <> 0) then
        Wf_Core.Token('ENTITY', 'ACTIVITY_TRANSITION');
        Wf_Core.Token('TYPE', '');
        Wf_Core.Token('NAME', to_char(v_npac(j))||'-'||to_char(v_npac(toid)));
        Wf_Core.Raise('WFLDRSD_UPI');
      end if;
    end loop;

    -- Copy Activity Attr Values
    for aavr in aavcur(v_opac(j)) loop
      if (aavr.value_type = 'CONSTANT') then
        -- just pick a non-null value
        l_value := nvl(aavr.date_value,
                       nvl(aavr.number_value, aavr.text_value));
      else
        -- must be ITEMATTR
        l_value := substr(aavr.text_value||p_new_suffix, 1, 30);
      end if;


      Wf_Load.UPLOAD_ACTIVITY_ATTR_VALUE (
        x_process_activity_id=>v_npac(j),
        x_name=>aavr.name,
        x_protect_level=>aavr.protect_level,
        x_custom_level=>aavr.custom_level,
        x_value=>l_value,
        x_value_type=>aavr.value_type,
        x_effective_date=>sysdate,
        x_level_error=>l_level_error
      );
      if (l_level_error <> 0) then
        Wf_Core.Token('ENTITY', 'ACTIVITY_ATTR_VALUE');
        Wf_Core.Token('TYPE', to_char(v_npac(j)));
        Wf_Core.Token('NAME', aavr.name);
        Wf_Core.Raise('WFLDRSD_UPI');
      end if;
    end loop;
  end loop;

exception
  when OTHERS then
    if (itacur%isopen) then
      close itacur;
    end if;
    if (lutcur%isopen) then
      close itacur;
    end if;
    if (luccur%isopen) then
      close itacur;
    end if;
    if (msgcur%isopen) then
      close msgcur;
    end if;
    if (msacur%isopen) then
      close msacur;
    end if;
    Wf_Core.Context('Wf_Load', 'COPY_ITEM_TYPE', p_item_type,
                    p_destination_item_type,
                    p_new_suffix);
    raise;
end;

-- Delete_Process_Activity
-- IN
--   p_item_type - item type of this process activity (used in making
--                 sure the process activity has not been run).
--   p_step - instance id of the process activity
-- NOTE
--   It is possible to leave an invalid Workflow definition after this
-- call.
--   Make sure it does not exist in wf_item_activity_statuses, ie. has
-- not been run.
--   It needs to make sure all transitions are cleaned up first.
--   It also needs to clean up all activity attribute values.
procedure Delete_Process_Activity(
  p_step in number)
is
  dummy number;
begin

  -- ###
  -- The following check causes full table scans.  Since it is controlled by
  -- constraints already, we skipped the check here.
  -- begin
  --   select 1 into dummy
  --   from sys.dual
  --   where not exists (
  --     select 1
  --     from   WF_ITEM_ACTIVITY_STATUSES_V
  --     where  ACTIVITY_ID = p_step
  --   );
  -- exception
  --   when NO_DATA_FOUND then
  --     -- ### activity started
  --     raise;
  -- end;

  -- Delete all transitions to and from this process activity
  Wf_Load.Delete_Transition(p_previous_step=>p_step);
  Wf_Load.Delete_Transition(p_next_step=>p_step);

  -- Delete all related attribute values
  delete from WF_ACTIVITY_ATTR_VALUES where PROCESS_ACTIVITY_ID = p_step;

  -- Delete the process activity
  delete from WF_PROCESS_ACTIVITIES where INSTANCE_ID = p_step;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Delete_Process_Activity',
                    to_char(p_step));
    raise;
end;

--
-- Get_Activity_Attr_Val
-- IN
--   p_process_instance_id  - instance id of the process activity
--   p_attribute_name       - name of the attribute
-- OUT
--   p_attribute_value_type - value type like 'CONSTANT' or 'ITEMATTR'
--   p_attribute_value      - value of the attribute
--
procedure GET_ACTIVITY_ATTR_VAL(
  p_process_instance_id  in  number,
  p_attribute_name       in  varchar2,
  p_attribute_value_type out NOCOPY varchar2,
  p_attribute_value      out NOCOPY varchar2)
is
begin
  select VALUE_TYPE,
         nvl(nvl(TEXT_VALUE, to_char(NUMBER_VALUE)),
             to_char(DATE_VALUE, 'YYYY/MM/DD HH24:MI:SS'))
  into   p_attribute_value_type,
         p_attribute_value
  from   WF_ACTIVITY_ATTR_VALUES
  where  PROCESS_ACTIVITY_ID = p_process_instance_id
  and    NAME = p_attribute_name;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Activity_Attr_Val',
                    to_char(p_process_instance_id), p_attribute_name);
    raise;
end;

--
-- Get_Item_Attribute
-- IN
--   p_item_type            - item type
--   p_attribute_name       - name of the attribute
-- OUT
--   p_attribute_type       - type like 'NUMBER', 'TEXT' and so on
--   p_attribute_value      - value of the attribute
--
procedure GET_ITEM_ATTRIBUTE(
  p_item_type            in  varchar2,
  p_attribute_name       in  varchar2,
  p_attribute_type       out NOCOPY varchar2,
  p_attribute_value      out NOCOPY varchar2)
is
  l_text    varchar2(4000);
  l_number  varchar2(100);
  l_date    varchar2(30);
begin
  select TYPE,
         TEXT_DEFAULT,
         to_char(NUMBER_DEFAULT),
         to_char(DATE_DEFAULT, 'YYYY/MM/DD HH24:MI:SS')
  into   p_attribute_type,
         p_attribute_value,
         l_number,
         l_date
  from   WF_ITEM_ATTRIBUTES
  where  ITEM_TYPE = p_item_type
  and    NAME = p_attribute_name;

  if (p_attribute_type = 'DATE') then
    p_attribute_value := l_date;
  elsif (p_attribute_type = 'NUMBER') then
    p_attribute_value := l_number;
  end if;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Item_Attribute',
                    p_item_type, p_attribute_name);
    raise;
end;

--
-- Get_Activity
-- IN
--   p_item_type -
--   p_name -
-- OUT
--   p_display_name -
--   p_description -
--   p_type -
--   p_rerun -
--   p_protect_level -
--   p_custom_level -
--   p_begin_date -
--   p_function -
--   p_function_type -
--   p_result_type -
--   p_cost      -
--   p_read_role -
--   p_write_role -
--   p_execute_role -
--   p_icon_name -
--   p_message -
--   p_error_process -
--   p_expand_role -
--   p_error_item_type -
--   p_runnable_flag -
--   p_version -
procedure GET_ACTIVITY (
  p_item_type     in     varchar2,
  p_name          in     varchar2,
  p_display_name  out    NOCOPY varchar2,
  p_description   out    NOCOPY varchar2,
  p_type          out    NOCOPY varchar2,
  p_rerun         out    NOCOPY varchar2,
  p_protect_level out    NOCOPY number,
  p_custom_level  out    NOCOPY number,
  p_begin_date    out    NOCOPY date,
  p_function      out    NOCOPY varchar2,
  p_function_type out    NOCOPY varchar2,
  p_result_type   out    NOCOPY varchar2,
  p_cost          out    NOCOPY number,
  p_read_role     out    NOCOPY varchar2,
  p_write_role    out    NOCOPY varchar2,
  p_execute_role  out    NOCOPY varchar2,
  p_icon_name     out    NOCOPY varchar2,
  p_message       out    NOCOPY varchar2,
  p_error_process out    NOCOPY varchar2,
  p_expand_role   out    NOCOPY varchar2,
  p_error_item_type out  NOCOPY varchar2,
  p_runnable_flag out    NOCOPY varchar2,
  p_version       out    NOCOPY number
)
is
begin
  select DISPLAY_NAME,
         DESCRIPTION,
         TYPE,
         RERUN,
         PROTECT_LEVEL,
         CUSTOM_LEVEL,
         BEGIN_DATE,
         FUNCTION,
         FUNCTION_TYPE,
         RESULT_TYPE,
         COST,
         READ_ROLE,
         WRITE_ROLE,
         EXECUTE_ROLE,
         ICON_NAME,
         MESSAGE,
         ERROR_PROCESS,
         EXPAND_ROLE,
         ERROR_ITEM_TYPE,
         RUNNABLE_FLAG,
         VERSION
  into   p_display_name,
         p_description,
         p_type,
         p_rerun,
         p_protect_level,
         p_custom_level,
         p_begin_date,
         p_function,
         p_function_type,
         p_result_type,
         p_cost,
         p_read_role,
         p_write_role,
         p_execute_role,
         p_icon_name,
         p_message,
         p_error_process,
         p_expand_role,
         p_error_item_type,
         p_runnable_flag,
         p_version
  from   WF_ACTIVITIES_VL
  where  ITEM_TYPE = p_item_type
  and    NAME = p_name
  and    END_DATE is null;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Activity', p_item_type, p_name);
    raise;
end;

--
-- Update_Activity
-- IN
--   p_item_type  - item type of the activity
--   p_name  - activity name
--   p_display_name - activity display name
--   p_description  - activity description
--   p_expand_role  - flag to indicate expand role or not
-- OUT
--   p_level_error - the output of error level
-- NOTE
--   Cannot use UPLOAD_ACTIVITY because activity is normally versioned.
--   Update only the latest version.
--
procedure UPDATE_ACTIVITY (
  p_item_type in varchar2,
  p_name in varchar2,
  p_display_name in varchar2,
  p_description in varchar2 ,
  p_expand_role in varchar2 ,
  p_level_error out NOCOPY number)
is
  conflict_name       varchar2(240);
  l_name              varchar2(30);
  l_dname             varchar2(80);
  n_dname             varchar2(80);
  l_display_name      varchar2(80);
  l_description       varchar2(240);
  l_type              varchar2(8);
  l_rerun             varchar2(8);
  l_protect_level     number;
  l_custom_level      number;
  l_begin_date        date;
  l_function          varchar2(240);
  l_function_type     varchar2(30);
  l_result_type       varchar2(30);
  l_cost              number;
  l_read_role         varchar2(320);
  l_write_role        varchar2(320);
  l_execute_role      varchar2(320);
  l_icon_name         varchar2(30);
  l_message           varchar2(30);
  l_error_process     varchar2(30);
  l_expand_role       varchar2(1);
  l_error_item_type   varchar2(8);
  l_runnable_flag     varchar2(1);
  l_version           number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  begin
    Wf_Load.GET_ACTIVITY (
      p_item_type=>p_item_type,
      p_name=>p_name,
      p_display_name=>l_display_name,
      p_description=>l_description,
      p_type=>l_type,
      p_rerun=>l_rerun,
      p_protect_level=>l_protect_level,
      p_custom_level=>l_custom_level,
      p_begin_date=>l_begin_date,
      p_function=>l_function,
      p_function_type=>l_function_type,
      p_result_type=>l_result_type,
      p_cost=>l_cost,
      p_read_role=>l_read_role,
      p_write_role=>l_write_role,
      p_execute_role=>l_execute_role,
      p_icon_name=>l_icon_name,
      p_message=>l_message,
      p_error_process=>l_error_process,
      p_expand_role=>l_expand_role,
      p_error_item_type=>l_error_item_type,
      p_runnable_flag=>l_runnable_flag,
      p_version=>l_version
    );
    -- Check protect and custom level
    if (l_type <> 'FOLDER') then
      if ((wf_core.upload_mode <> 'FORCE') and
          (l_protect_level < wf_core.session_level)) then
        p_level_error := 1;
        return;
      end if;

      if ((wf_core.upload_mode = 'UPGRADE') and
          (l_custom_level > wf_core.session_level)) then
        p_level_error := 2;
        return;
      end if;
    end if;
  exception
    when OTHERS then
      -- Don't proceed
      Wf_Core.Context('Wf_Load', 'Update_Activity Get_Activity');
      raise;
  end;

  if (p_display_name is not null) then
    l_display_name := p_display_name;
  end if;
  if (p_description is not null) then
    l_description := p_description;
  end if;
  if (p_expand_role is not null) then
    l_expand_role := p_expand_role;
  end if;

  -- Check for unique index violations
  --   try to resolve the problem by appending '@'
  --   to the incoming display name
  --   for activity, we must have the specific version first.
  n_dname := l_display_name;
  begin
    -- l_name will be the old data to update
    select ITEM_TYPE||':'||NAME||':'||to_char(VERSION), DISPLAY_NAME, NAME
    into conflict_name, l_dname, l_name
    from WF_ACTIVITIES_VL
    where DISPLAY_NAME = n_dname
    and ITEM_TYPE = p_item_type
    and l_begin_date >= BEGIN_DATE
    and l_begin_date < nvl(END_DATE, l_begin_date+1)
    and NAME <> p_name;

    n_dname := substrb('@'||l_dname, 1, 240);

    -- this loop will make sure no duplicate with n_dname
    loop
      begin
        select ITEM_TYPE||':'||NAME||':'||to_char(VERSION), DISPLAY_NAME
        into conflict_name, l_dname
        from WF_ACTIVITIES_VL
        where DISPLAY_NAME = n_dname
        and ITEM_TYPE = p_item_type
        and l_begin_date >= BEGIN_DATE
        and l_begin_date < nvl(END_DATE, l_begin_date+1)
        and NAME <> l_name;

        n_dname := substrb('@'||l_dname, 1, 80);

        if ( n_dname = l_dname ) then
          Wf_Core.Token('DNAME', l_display_name);
          Wf_Core.Token('NAME', p_item_type||':'||p_name||':'||
                        to_char(l_version));
          Wf_Core.Token('CONFLICT_NAME', conflict_name);
          Wf_Core.Raise('WFSQL_UNIQUE_NAME');
          exit;
        end if;
      exception
        when no_data_found then
          exit;
      end;
    end loop;
  exception
    when no_data_found then
      null;

    when others then
      raise;
  end;

  -- Do the Update
  update  WF_ACTIVITIES
  set     expand_role = l_expand_role
  where   ITEM_TYPE = p_item_type
  and     NAME = p_name
  and     VERSION = l_version;

  update  WF_ACTIVITIES_TL
  set     DISPLAY_NAME = n_dname,
          DESCRIPTION  = l_description
  where   ITEM_TYPE = p_item_type
  and     NAME = p_name
  and     VERSION = l_version;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Update_Activity', p_item_type, p_name,
                    p_display_name);
    raise;
end;

--
-- Get_Activity_Instance
--   Return the instance id for an activity based on its label of a
-- given process and activity
-- IN
--   p_process_item_type  -
--   p_process_name       -
--   p_process_version    -
--   p_activity_item_type -
--   p_activity_name      -
--   p_instance_label     -
function Get_Activity_Instance(
    p_process_item_type          in varchar2,
    p_process_name               in varchar2,
    p_process_version            in number ,
    p_activity_item_type         in varchar2 ,
    p_activity_name              in varchar2 ,
    p_instance_label             in varchar2 )
  return number
is
  id number;
begin
  -- p_activity_item_type and p_activity_name pair are non-null or
  -- p_instance_label is non-null.  Otherwise return -1.
  if (p_instance_label is null and
      (p_activity_item_type is null or p_activity_name is null)) then
    return (-1);
  end if;

  if (p_instance_label is not null) then
    select INSTANCE_ID into id
    from   WF_PROCESS_ACTIVITIES
    where  INSTANCE_LABEL = p_instance_label
    and    PROCESS_NAME = p_process_name
    and    PROCESS_ITEM_TYPE = p_process_item_type
    and    PROCESS_VERSION = p_process_version;

    return id;
  end if;

  -- return only the first row if there are more.
  select INSTANCE_ID into id
  from   WF_PROCESS_ACTIVITIES
  where  PROCESS_NAME = p_process_name
  and    PROCESS_ITEM_TYPE = p_process_item_type
  and    PROCESS_VERSION = p_process_version
  and    ACTIVITY_ITEM_TYPE = p_activity_item_type
  and    ACTIVITY_NAME = p_activity_name
  and    rownum = 1;

  return id;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Activity_Instance', p_process_item_type,
                    p_process_name, p_process_version);
    return (-1);
end;

/* ### Get_Process_Activity include this function
--
-- GetActNameFromInstId
-- IN
--   p_instance_id - instance id of an activity
-- RET
--   Name of the activity in varchar2
--
function GetActNameFromInstId (
  p_instance_id    in  number)
return varchar2
is
  l_actname  varchar2(30);
begin
  select ACTIVITY_NAME
  into   l_actname
  from   WF_PROCESS_ACTIVITIES
  where  INSTANCE_ID = p_instance_id;

  return l_actname;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'GetActNameFromInstId',
                    to_char(p_instance_id));
    return null;
end;
*/

--
-- Get_Activity_Transition
-- IN
--   p_from_activity    -
--   p_to_activity      -
--   p_result_code      -
-- OUT
--   p_result_codes     - table of all matched result codes
--   p_activities       - table of all matched activity instance ids
-- NOTE
--   Depend on what the parameter given return the appropriate result
--   p_from_activity + p_to_activity => p_result_codes
--   p_from_activity + p_result_code => p_activities (of to activity)
--   p_to_activity   + p_result_code => p_activities (of from activity)
--   p_from_activity => p_result_codes + p_activities (of to activity)
--   p_to_activity   => p_result_codes + p_activities (of from activity)
procedure Get_Activity_Transition (
    p_from_activity  in     number   ,
    p_to_activity    in     number   ,
    p_result_code    in     varchar2 ,
    p_activities     out    NOCOPY t_instanceidTab,
    p_result_codes   out    NOCOPY t_resultcodeTab)
is
  cursor rccur(from_act in number, to_act in number) is
  select RESULT_CODE
  from   WF_ACTIVITY_TRANSITIONS
  where  FROM_PROCESS_ACTIVITY = from_act
  and    TO_PROCESS_ACTIVITY = to_act;

  cursor tpcur(from_act in number, res_code in varchar2) is
  select TO_PROCESS_ACTIVITY
  from   WF_ACTIVITY_TRANSITIONS
  where  FROM_PROCESS_ACTIVITY = from_act
  and    RESULT_CODE = res_code;

  cursor tp2cur(from_act in number) is
  select TO_PROCESS_ACTIVITY, RESULT_CODE
  from   WF_ACTIVITY_TRANSITIONS
  where  FROM_PROCESS_ACTIVITY = from_act;

  cursor fpcur(to_act in number, res_code in varchar2) is
  select FROM_PROCESS_ACTIVITY
  from   WF_ACTIVITY_TRANSITIONS
  where  TO_PROCESS_ACTIVITY = to_act
  and    RESULT_CODE = res_code;

  cursor fp2cur(to_act in number) is
  select FROM_PROCESS_ACTIVITY, RESULT_CODE
  from   WF_ACTIVITY_TRANSITIONS
  where  TO_PROCESS_ACTIVITY = to_act;

  i pls_integer;
begin
  if (p_from_activity is null and p_to_activity is null and
      p_result_code is null) then
    return;
  end if;
  if (p_from_activity is not null and p_to_activity is not null) then
    i := 1;
    for rcr in rccur(p_from_activity, p_to_activity) loop
      p_result_codes(i) := rcr.RESULT_CODE;
      i := i + 1;
    end loop;
  elsif (p_to_activity is null) then
    i := 1;
    if (p_result_code is null) then
      for tpr in tp2cur(p_from_activity) loop
        p_activities(i)   := tpr.TO_PROCESS_ACTIVITY;
        p_result_codes(i) := tpr.RESULT_CODE;
        i := i + 1;
      end loop;
    else
      for tpr in tpcur(p_from_activity, p_result_code) loop
        p_activities(i) := tpr.TO_PROCESS_ACTIVITY;
        i := i + 1;
      end loop;
    end if;
  else
    i := 1;
    if (p_result_code is null) then
      for fpr in fp2cur(p_to_activity) loop
        p_activities(i) := fpr.FROM_PROCESS_ACTIVITY;
        p_result_codes(i) := fpr.RESULT_CODE;
        i := i + 1;
      end loop;
    else
      for fpr in fpcur(p_to_activity, p_result_code) loop
        p_activities(i) := fpr.FROM_PROCESS_ACTIVITY;
        i := i + 1;
      end loop;
    end if;
  end if;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Activity_Transition',
                    to_char(p_from_activity),
                    to_char(p_to_activity),
                    p_result_code
                   );
end;

--
-- Get_Item_Attribute_Names
--   select all the item attributes that match the specified suffix
-- IN
--   p_item_type - item type of the item attributes
--   p_suffix    - suffix that the internal names of item attributes endded in
-- OUT
--   p_names     - table of internal names that returned
--
procedure Get_Item_Attribute_Names(
  p_item_type    in  varchar2,
  p_suffix       in  varchar2,
  p_names        out NOCOPY t_nameTab
)is
  cursor itancur is
  select NAME
  from   WF_ITEM_ATTRIBUTES
  where  ITEM_TYPE = p_item_type
  and    NAME like '%'||p_suffix;

  i pls_integer;
begin
  i := 1;
  for itanr in itancur loop
    p_names(i) := itanr.name;
    i := i + 1;
  end loop;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Attribute_Names', p_item_type, p_suffix);
    raise;
end;


--
-- Get_Notif_Activity_Names
--   select all the notification activities that match the specified suffix
-- IN
--   p_item_type - item type of the activities
--   p_suffix    - suffix that the internal names of activities endded in
-- OUT
--   p_names     - table of internal names that returned
--
procedure Get_Notif_Activity_Names(
  p_item_type    in  varchar2,
  p_suffix       in  varchar2,
  p_names        out NOCOPY t_nameTab
)is
  cursor notfcur is
  select NAME
  from   WF_ACTIVITIES
  where  NAME like '%'||p_suffix
  and    ITEM_TYPE = p_item_type
  and    TYPE = 'NOTICE'
  and    END_DATE is null;

  i pls_integer;
begin
  i := 1;
  for notfr in notfcur loop
    p_names(i) := notfr.name;
    i := i + 1;
  end loop;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Notif_Activity_Names',
                    p_item_type, p_suffix);
    raise;
end;

-- Get_Message_Names
--   select all the messages that match the specified suffix
-- IN
--   p_item_type - item type of the messages
--   p_suffix    - suffix that the internal names of messages endded in
-- OUT
--   p_names     - table of internal names that returned
--
procedure Get_Message_Names(
  p_item_type    in  varchar2,
  p_suffix       in  varchar2,
  p_names        out NOCOPY t_nameTab
)is
  cursor msgcur is
  select NAME
  from   WF_MESSAGES
  where  NAME like '%'||p_suffix
  and    TYPE = p_item_type;

  i pls_integer;
begin
  i := 1;
  for msgr in msgcur loop
    p_names(i) := msgr.name;
    i := i + 1;
  end loop;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Message_Names', p_item_type, p_suffix);
    raise;
end;

-- Get_Process_Activity_Instances
--   select all the process activities of activity of type process
-- IN
--   p_process_item_type - item type of the process which includes these
--                         activities.
--   p_process_name      - process name
--   p_process_version   - process version which defaults to 1
-- OUT
--   p_instance_ids      - table of instance ids that returned
--
procedure Get_Process_Activity_Instances(
  p_process_item_type  in  varchar2,
  p_process_name       in  varchar2,
  p_process_version    in  number ,
  p_instance_ids       out NOCOPY t_instanceidTab
)is
  cursor paccur is
  select INSTANCE_ID
  from   WF_PROCESS_ACTIVITIES
  where  PROCESS_NAME = p_process_name
  and    PROCESS_ITEM_TYPE = p_process_item_type
  and    PROCESS_VERSION   = p_process_version;

  i pls_integer;
begin
  i := 1;
  for pacr in paccur loop
    p_instance_ids(i) := pacr.instance_id;
    i := i + 1;
  end loop;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Process_Activity_Instances',
                    p_process_item_type, p_process_name, p_process_version);
    raise;
end;

--
-- GET_LOOKUP
--   Get the Lookup definition
-- IN
--   x_lookup_type   - item type of lookup
--   x_lookup_code   - internal name of lookup code
-- OUT
--   x_meaning       - display name of lookup code
--   x_description   - description of lookup code
--   x_protect_level -
--   x_custom_level  -
--
procedure Get_Lookup(
  x_lookup_type       in varchar2,
  x_lookup_code       in varchar2,
  x_meaning           out NOCOPY varchar2,
  x_description       out NOCOPY varchar2,
  x_protect_level     out NOCOPY number,
  x_custom_level      out NOCOPY number
)
is
begin
  select MEANING, DESCRIPTION, PROTECT_LEVEL, CUSTOM_LEVEL
  into   x_meaning, x_description, x_protect_level, x_custom_level
  from   WF_LOOKUPS
  where  LOOKUP_TYPE = x_lookup_type
  and    LOOKUP_CODE = x_lookup_code;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Lookup', x_lookup_type, x_lookup_code);
    raise;
end;

--
-- UPDATE_LOOKUP
--   Update the provided fields for Lookup
-- IN
--   x_lookup_type   - item type of lookup
--   x_lookup_code   - internal name of lookup code
--   x_meaning       - display name of lookup code
--   x_description   - description of lookup code
--   x_protect_level -
--   x_custom_level  -
-- OUT
--   x_level_error   - level of error returned from UPLOAD_LOOKUP
-- NOTE
--   Calls GET_LOOKUP to get the default value before calling
-- UPLOAD_LOOKUP.
--
procedure UPDATE_LOOKUP(
  x_lookup_type       in varchar2,
  x_lookup_code       in varchar2,
  x_meaning           in varchar2 ,
  x_description       in varchar2 ,
  x_protect_level     in number ,
  x_custom_level      in number ,
  x_level_error       out NOCOPY number
)
is
  l_meaning       varchar2(80);
  l_description   varchar2(240);
  l_protect_level number;
  l_custom_level  number;
begin
  -- Reset any caches that might be running.
  WF_CACHE.Reset;

  -- Get Lookup
  Wf_Load.Get_Lookup(x_lookup_type, x_lookup_code,
    l_meaning, l_description, l_protect_level, l_custom_level);

  -- Upload Lookup
  if (x_meaning is not null) then
    l_meaning := x_meaning;
  end if;
  if (x_description is not null) then
    l_description := x_description;
  end if;
  if (x_protect_level is not null) then
    l_protect_level := x_protect_level;
  end if;
  if (x_custom_level is not null) then
    l_custom_level := x_custom_level;
  end if;
  Wf_Load.UPLOAD_LOOKUP(
    x_lookup_type=>x_lookup_type,
    x_lookup_code=>x_lookup_code,
    x_meaning=>l_meaning,
    x_description=>l_description,
    x_protect_level=>l_protect_level,
    x_custom_level=>l_custom_level,
    x_level_error=>x_level_error
  );
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Update_Lookup', x_lookup_type, x_lookup_code);
    raise;
end;


--
-- GET_LOOKUP_CODES
--   Get lookup codes for a lookup type
-- IN
--   p_lookup_type   - item type of lookup
-- OUT
--   p_lookup_codes  - table of lookup codes
--
procedure Get_Lookup_Codes(
p_lookup_type in varchar2,
p_lookup_codes out NOCOPY t_resultcodeTab)
is
  cursor luccur is
  select LOOKUP_CODE
  from   WF_LOOKUPS
  where  LOOKUP_TYPE = p_lookup_type;

  i pls_integer;
begin
  i := 1;
  for lucr in luccur loop
    p_lookup_codes(i) := lucr.lookup_code;
    i := i + 1;
  end loop;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Get_Lookup_Codes', p_lookup_type);
    raise;
end;

--
-- Activity_Exist_In_Process (Deprecated, use WF_ENGINE.Activity_Exist instead)
--   Check if an activity exist in a process
-- IN
--   p_process_item_type
--   p_process_name
--   p_activity_item_type
--   p_anctivity_name
--   active_date
--   iteration  - maximum 8 level deep (0-7)
-- RET
--   TRUE if activity exist, FALSE otherwise
--
function Activity_Exist_In_Process (
  p_process_item_type  in  varchar2,
  p_process_name       in  varchar2,
  p_activity_item_type in  varchar2 ,
  p_activity_name      in  varchar2,
  active_date          in  date ,
  iteration            in  number )
return boolean
is
  m_version  number;
  n          number;

  cursor actcur(ver number) is
  select WPA.ACTIVITY_ITEM_TYPE, WPA.ACTIVITY_NAME
  from   WF_PROCESS_ACTIVITIES WPA,
         WF_ACTIVITIES WA
  where  WPA.PROCESS_ITEM_TYPE = p_process_item_type
  and    WPA.PROCESS_NAME = p_process_name
  and    WPA.PROCESS_VERSION = ver
  and    WPA.ACTIVITY_ITEM_TYPE = WA.ITEM_TYPE
  and    WPA.ACTIVITY_NAME = WA.NAME
  and    WA.TYPE = 'PROCESS'
  and    active_date >= WA.BEGIN_DATE
  and    active_date < nvl(WA.END_DATE, active_date+1);

begin
  -- first check the iteration to avoid infinite loop
  if (iteration > 7) then
    -- debug only
--    Wf_Core.Context('Wf_Load', 'Activity_Exist_In_Process_Overflown',
--                    p_process_item_type, p_process_name,
--                    nvl(p_activity_item_type, p_process_item_type),
--                    p_activity_name);
    return FALSE;
  end if;

  -- then get the active version
  begin
    select VERSION into m_version
    from   WF_ACTIVITIES
    where  ITEM_TYPE = p_process_item_type
    and    NAME = p_process_name
    and    active_date >= BEGIN_DATE
    and    active_date <  nvl(END_DATE, active_date + 1);
  exception
    -- no active version exist
    when NO_DATA_FOUND then
      return FALSE;

    when OTHERS then
      raise;
  end;

  -- then check to see if such activity exist
  select count(1) into n
  from   WF_PROCESS_ACTIVITIES
  where  PROCESS_ITEM_TYPE = p_process_item_type
  and    PROCESS_NAME = p_process_name
  and    PROCESS_VERSION = m_version
  and    ACTIVITY_ITEM_TYPE = nvl(p_activity_item_type, p_process_item_type)
  and    ACTIVITY_NAME = p_activity_name;

  if (n = 0) then
    -- recursively check subprocesses
    for actr in actcur(m_version) loop
      if (Wf_Load.Activity_Exist_In_Process(
          actr.activity_item_type,
          actr.activity_name,
          nvl(p_activity_item_type, p_process_item_type),
          p_activity_name,
          active_date,
          iteration+1)
         ) then
        return TRUE;
      end if;
    end loop;

    return FALSE;
  else
    return TRUE;
  end if;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Load', 'Activity_Exist_In_Process',
                    p_process_item_type, p_process_name,
                    nvl(p_activity_item_type, p_process_item_type),
                    p_activity_name);
    raise;
end;

--
-- BeginTransaction
-- (PRIVATE)
--  Calls WF_CACHE.BeginTransaction() to control the calls to WF_CACHE.Reset()
--  so there is not unnecessary locking or update to WFCACHE_META_UPD.
--  Calling this api mandates that EndTransaction is called BEFORE control is
--  returned.
PROCEDURE BeginTransaction
is
begin
  if (NOT WF_CACHE.BeginTransaction) then
    NULL;  --We are ignoring a false condition but may later need to handle.
  end if;
end;

--
-- EndTransaction
-- (PRIVATE)
-- Calls WF_CACHE.EndTransaction() to signal the end of the transaction and to
-- call WF_CACHE.Reset() which will update WFCACHE_META_UPD.
-- WARNING: THIS API WILL ISSUE A COMMIT!
PROCEDURE EndTransaction
is
begin
  if (NOT WF_CACHE.EndTransaction) then
    NULL;  --We are ignoring a false condition but may later need to handle.
  end if;
  commit; --Commit the work.
end;

end WF_LOAD;

/
