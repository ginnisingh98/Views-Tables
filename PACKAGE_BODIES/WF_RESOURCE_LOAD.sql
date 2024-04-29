--------------------------------------------------------
--  DDL for Package Body WF_RESOURCE_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_RESOURCE_LOAD" as
/* $Header: wfrsldrb.pls 120.3 2005/10/13 23:38:01 rtodi noship $ */

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
  x_level_error out nocopy number
) is
  row_id varchar2(30);
  protection_level number;
  customization_level number;
begin
  -- No need to reset cache in upload_resource
  -- WF_CACHE.Reset;

  -- Check protection level
  x_level_error := 0;
  begin
    select PROTECT_LEVEL, CUSTOM_LEVEL
    into protection_level, customization_level
    from WF_RESOURCES
    where NAME = x_name
    and TYPE = x_type
    and LANGUAGE = userenv('LANG');

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
    Wf_Resources_Pkg.Update_Row (
      x_type => x_type,
      x_name => x_name,
      x_protect_level => x_protect_level,
      x_custom_level => x_custom_level,
      x_id => x_id,
      x_text => x_text
    );

  exception
    when no_data_found then
      -- Check protection level for new row
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
      Wf_Resources_Pkg.Insert_Row (
        x_rowid => row_id,
        x_type => x_type,
        x_name => x_name,
        x_protect_level => x_protect_level,
        x_custom_level => x_custom_level,
        x_id => x_id,
        x_text => x_text
      );
  end;

exception
  when others then
    Wf_Core.Context('WF_RESOURCE_LOAD', 'Upload_Resource', x_name, x_type);
    raise;
end UPLOAD_RESOURCE;

end WF_RESOURCE_LOAD;

/
