--------------------------------------------------------
--  DDL for Package Body WF_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENTS_PKG" as
/* $Header: WFEVEVTB.pls 120.11 2008/02/15 09:35:21 sstomar ship $ */
m_table_name       varchar2(255) := 'WF_EVENTS';
m_package_version  varchar2(30)  := '1.0';

m_null varchar2(10) := '*NULL*';

procedure fetch_custom_level(X_GUID in raw,
			       X_CUSTOMIZATION_LEVEL out nocopy varchar2);

procedure INSERT_ROW (
  X_ROWID              in out nocopy varchar2,
  X_GUID               in     raw,
  X_NAME               in     varchar2,
  X_TYPE               in     varchar2,
  X_STATUS             in     varchar2,
  X_GENERATE_FUNCTION  in     varchar2,
  X_OWNER_NAME         in     varchar2,
  X_OWNER_TAG          in     varchar2,
  X_DISPLAY_NAME       in     varchar2,
  X_DESCRIPTION        in     varchar2,
  X_CUSTOMIZATION_LEVEL in    varchar2,
  X_LICENSED_FLAG      in     varchar2,
  X_JAVA_GENERATE_FUNC in     varchar2,
  X_IREP_ANNOTATION    in     varchar2
) is
  cursor C is select rowid from wf_events where guid = X_GUID;
  l_licensed_flag varchar2(1);
begin
  l_licensed_flag := is_product_licensed (X_OWNER_TAG);
  insert into wf_events (
    guid,
    name,
    type,
    status,
    generate_function,
    owner_name,
    owner_tag,
    customization_level,
    licensed_flag,
    java_generate_func,
    irep_annotation
  ) values (
    X_GUID,
    X_NAME,
    X_TYPE,
    X_STATUS,
    X_GENERATE_FUNCTION,
    X_OWNER_NAME,
    X_OWNER_TAG,
    X_CUSTOMIZATION_LEVEL,
    l_licensed_flag,
    X_JAVA_GENERATE_FUNC,
    X_IREP_ANNOTATION
  );

  insert into wf_events_tl (
    guid,
    language,
    display_name,
    description,
    source_lang)
  select X_GUID,
         L.CODE,
         X_DISPLAY_NAME,
         X_DESCRIPTION,
         userenv('LANG')
  from wf_languages l
  where l.installed_flag = 'Y'
  and not exists
    (select null
     from   wf_events_tl t
     where  t.guid = X_GUID
     and    t.language = l.code);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  else
    wf_event.raise('oracle.apps.wf.event.event.create',x_guid);
  end if;
  close c;
exception
  when others then
    wf_core.context('Wf_Events_Pkg', 'Insert_Row', x_guid, x_name, x_type);
    raise;
end INSERT_ROW;
----------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_GUID               in  raw,
  X_NAME               in  varchar2,
  X_TYPE               in  varchar2,
  X_STATUS             in  varchar2,
  X_GENERATE_FUNCTION  in  varchar2,
  X_OWNER_NAME         in  varchar2,
  X_OWNER_TAG          in  varchar2,
  X_DISPLAY_NAME       in  varchar2,
  X_DESCRIPTION        in  varchar2,
  X_CUSTOMIZATION_LEVEL in varchar2,
  X_LICENSED_FLAG      in  varchar2,
  X_JAVA_GENERATE_FUNC in  varchar2,
  X_IREP_ANNOTATION    in  varchar2
) is
 l_custom_level varchar2(1);
 l_update_allowed varchar2(1);
 l_licensed_flag varchar2(1);
 l_raise_event_flag varchar2(1) := 'N';

 CURSOR c_getguid(p_name in varchar2) IS
 SELECT guid
 FROM   wf_events
 WHERE  name = p_name;

 l_guid  raw(16);

begin

  open c_getguid(x_name);
  fetch c_getguid into l_guid;
  if (c_getguid%notfound) then
    l_guid := x_guid;
  end if;
  close c_getguid;

  l_licensed_flag := is_product_licensed (X_OWNER_TAG);

  if g_Mode = 'FORCE' then
	update wf_events set
	name              = X_NAME,
	type              = X_TYPE,
	status            = X_STATUS,
	generate_function = X_GENERATE_FUNCTION,
	owner_name        = X_OWNER_NAME,
	owner_tag         = X_OWNER_TAG,
        licensed_flag      = l_licensed_flag,
	customization_level = X_CUSTOMIZATION_LEVEL,
	java_generate_func = X_JAVA_GENERATE_FUNC,
        irep_annotation   = X_IREP_ANNOTATION
	where guid = l_guid;

	update wf_events_tl set
	display_name = X_DISPLAY_NAME,
	description  = X_DESCRIPTION,
	source_lang  = userenv('LANG')
	where guid = l_guid
	and userenv('LANG') in (language, source_lang);

  	if (sql%notfound) then
    		raise no_data_found;
  	else
	-- Only raise if all if no no_data_found
		wf_event.raise('oracle.apps.wf.event.event.update',l_guid);
	end if;

  else
	-- User logged in is not seed. Its either the UI or the Loader
	fetch_custom_level(l_guid, l_custom_level);
	l_update_allowed := is_update_allowed(X_CUSTOMIZATION_LEVEL, l_custom_level);

	if l_update_allowed = 'N' then
		-- Set up the Error Stack
 		wf_core.context('WF_EVENTS_PKG','UPDATE_ROW',
			  x_name,
			  l_custom_level,
			  X_CUSTOMIZATION_LEVEL);
		return;
	end if;

	if X_CUSTOMIZATION_LEVEL = 'C' then
		if g_Mode = 'UPGRADE' then
		-- The Loader can update as the Custom Level is C
			update wf_events set
			name              = X_NAME,
			type              = X_TYPE,
			status            = X_STATUS,
			generate_function = X_GENERATE_FUNCTION,
			owner_name        = X_OWNER_NAME,
			owner_tag         = X_OWNER_TAG,
			customization_level = X_CUSTOMIZATION_LEVEL,
			licensed_flag     = l_licensed_flag,
                        java_generate_func = X_JAVA_GENERATE_FUNC,
                        irep_annotation   = X_IREP_ANNOTATION
			where guid = l_guid;

			update wf_events_tl set
			display_name = X_DISPLAY_NAME,
			description  = X_DESCRIPTION,
			source_lang  = userenv('LANG')
			where guid = l_guid
			and userenv('LANG') in (language, source_lang);

    			l_raise_event_flag := 'Y';
		else
			-- UI users cannot update Core events
			null;

		end if;
	elsif X_CUSTOMIZATION_LEVEL = 'L' then
		if g_Mode = 'UPGRADE' then
		-- Limit events can have only a status change..
		-- When the loader is loading the events the
		-- users changes must be preserved. Update all
		-- fields EXCEPT the status field.
			update wf_events set
			name              = X_NAME,
			type              = X_TYPE,
			generate_function = X_GENERATE_FUNCTION,
			owner_name        = X_OWNER_NAME,
			owner_tag         = X_OWNER_TAG,
			customization_level = X_CUSTOMIZATION_LEVEL,
			licensed_flag     = l_licensed_flag,
                        java_generate_func = X_JAVA_GENERATE_FUNC,
                        irep_annotation   = X_IREP_ANNOTATION
			where guid = l_guid;

			update wf_events_tl set
			display_name = X_DISPLAY_NAME,
			description  = X_DESCRIPTION,
			source_lang  = userenv('LANG')
			where guid = l_guid
			and userenv('LANG') in (language, source_lang);

    			l_raise_event_flag := 'Y';
		else
		-- Caller of the Update is the UI
		-- Limit events can have only a status change..
		-- When the user is updating the event using the UI
		-- Updates are allowed ONLY to the status field.
			update wf_events set
			status         = X_STATUS
			where guid = l_guid;

    			l_raise_event_flag := 'Y';
		end if;
	elsif X_CUSTOMIZATION_LEVEL = 'U' then
	-- Here are the updates allowed for extensible and User defined events
	-- only when the caller is the UI
		if g_Mode = 'CUSTOM' then
			update wf_events set
			name              = X_NAME,
			type              = X_TYPE,
			status            = X_STATUS,
			generate_function = X_GENERATE_FUNCTION,
			owner_name        = X_OWNER_NAME,
			owner_tag         = X_OWNER_TAG,
			customization_level = X_CUSTOMIZATION_LEVEL,
			licensed_flag     = l_licensed_flag,
                        java_generate_func = X_JAVA_GENERATE_FUNC,
                        irep_annotation   = X_IREP_ANNOTATION
			where guid = l_guid;

			update wf_events_tl set
			display_name = X_DISPLAY_NAME,
			description  = X_DESCRIPTION,
			source_lang  = userenv('LANG')
			where guid = l_guid
			and userenv('LANG') in (language, source_lang);

    			l_raise_event_flag := 'Y';
		else
			-- The caller is Loader and the only way of
			-- Uploading the data is in FORCE mode
			null;
		end if;
	else
		-- Raise error..
		Wf_Core.Token('REASON','Invalid Customization Level:' ||
		l_custom_level);
		Wf_Core.Raise('WFSQL_INTERNAL');
  	end if;

        -- Only raise if update has succeeded.
  	if (l_raise_event_flag = 'Y') then
		wf_event.raise('oracle.apps.wf.event.event.update',l_guid);
	end if;

  end if;


exception
  when no_data_found then
    raise;
  when others then
    wf_core.context('Wf_Events_Pkg', 'Update_Row', l_guid, x_name, x_type);
    raise;
end UPDATE_ROW;
----------------------------------------------------------------------------
procedure DELETE_ROW (
  X_GUID in raw
) is
begin
  wf_event.raise('oracle.apps.wf.event.event.delete',x_guid);


  delete from wf_events_tl where guid = X_GUID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


  delete from wf_events where guid = X_GUID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- Invalidate cache
  wf_bes_cache.SetMetaDataUploaded();
exception
  when others then
    wf_core.context('Wf_Events_Pkg', 'Delete_Row', x_guid);
    raise;
end DELETE_ROW;
----------------------------------------------------------------------------
procedure LOAD_ROW (
  X_GUID               in  raw,
  X_NAME               in  varchar2,
  X_TYPE               in  varchar2,
  X_STATUS             in  varchar2,
  X_GENERATE_FUNCTION  in  varchar2,
  X_OWNER_NAME         in  varchar2,
  X_OWNER_TAG          in  varchar2,
  X_DISPLAY_NAME       in  varchar2,
  X_DESCRIPTION        in  varchar2,
  X_CUSTOMIZATION_LEVEL in varchar2,
  X_LICENSED_FLAG      in  varchar2,
  X_JAVA_GENERATE_FUNC in  varchar2,
  X_IREP_ANNOTATION    in  varchar2
) is
  row_id  varchar2(64);
begin
  begin
    WF_EVENTS_PKG.UPDATE_ROW (
      X_GUID               => X_GUID,
      X_NAME               => X_NAME,
      X_TYPE               => X_TYPE,
      X_STATUS             => X_STATUS,
      X_GENERATE_FUNCTION  => X_GENERATE_FUNCTION,
      X_OWNER_NAME         => X_OWNER_NAME,
      X_OWNER_TAG          => X_OWNER_TAG,
      X_DISPLAY_NAME       => X_DISPLAY_NAME,
      X_DESCRIPTION        => X_DESCRIPTION,
      X_CUSTOMIZATION_LEVEL  => X_CUSTOMIZATION_LEVEL,
      X_LICENSED_FLAG      => X_LICENSED_FLAG,
      X_JAVA_GENERATE_FUNC =>  X_JAVA_GENERATE_FUNC,
      X_IREP_ANNOTATION    => X_IREP_ANNOTATION
      );

    -- Invalidate cache
    wf_bes_cache.SetMetaDataUploaded();
  exception
    when no_data_found then
    begin
      WF_EVENTS_PKG.INSERT_ROW(
        X_ROWID              => row_id,
        X_GUID               => X_GUID,
        X_NAME               => X_NAME,
        X_TYPE               => X_TYPE,
        X_STATUS             => X_STATUS,
        X_GENERATE_FUNCTION  => X_GENERATE_FUNCTION,
        X_OWNER_NAME         => X_OWNER_NAME,
        X_OWNER_TAG          => X_OWNER_TAG,
        X_DISPLAY_NAME       => X_DISPLAY_NAME,
        X_DESCRIPTION        => X_DESCRIPTION,
        X_CUSTOMIZATION_LEVEL  => X_CUSTOMIZATION_LEVEL,
        X_LICENSED_FLAG      => X_LICENSED_FLAG,
        X_JAVA_GENERATE_FUNC =>  X_JAVA_GENERATE_FUNC,
        X_IREP_ANNOTATION    => X_IREP_ANNOTATION
      );
     exception
       when DUP_VAL_ON_INDEX then
         wf_core.token('EVENT',X_NAME);
         Wf_Core.Raise('WFE_UNIQUE_CONSTRAINT');
     end;
  end;

exception
  when others then
    wf_core.context('Wf_Events_Pkg', 'Load_Row', x_guid, x_name, x_type);
    raise;
end LOAD_ROW;
----------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
/**
 Commenting off the costly pl/sql code
  delete from wf_events_tl t
  where not exists
    (select 'baserow'
     from   wf_events b
     where  b.guid = t.guid);

  update wf_events_tl t set (display_name, description)
  = (select b.display_name, b.description
     from   wf_events_tl b
     where  b.guid = t.guid
     and    b.language = t.source_lang)
  where (t.guid, t.language) in
    (select subt.guid,
            subt.language
     from   wf_events_tl subb, wf_events_tl subt
     where  subb.guid = subt.guid
     and    subb.language = subt.source_lang
     and   (subb.display_name <> subt.display_name
            or subb.description <> subt.description
            or (subb.description is null and subt.description is not null)
            or (subb.description is not null and subt.description is null))
  );

**/

  insert into wf_events_tl (
    guid,
    language,
    display_name,
    description,
    source_lang)
  select b.guid,
         l.code,
         b.display_name,
         b.description,
         b.source_lang
  from wf_events_tl b, wf_languages l
  where l.installed_flag = 'Y'
  and   b.language = userenv('LANG')
  and (b.guid , l.code) NOT IN
   (select /*+ hash_aj index_ffs(T,WF_EVENTS_TL_U1) */
       t.guid ,T.LANGUAGE
      from wf_events_tl T) ;
exception
  when others then
    wf_core.context('Wf_Events_Pkg', 'Add_language');
    raise;
end ADD_LANGUAGE;
----------------------------------------------------------------------------
function GENERATE (
  X_GUID               in raw
) return varchar2 is
  buf              varchar2(32000);
  l_doc            xmldom.DOMDocument;
  l_element        xmldom.DOMElement;
  l_root           xmldom.DOMNode;
  l_node           xmldom.DOMNode;
  l_header         xmldom.DOMNode;

  l_NAME               varchar2(240);
  l_type               varchar2(8);
  l_status             varchar2(8);
  l_generate_function  varchar2(240);
  l_owner_name         varchar2(30);
  l_owner_tag          varchar2(30);
  l_customization_level varchar2(1);
  l_licensed_flag      varchar2(1);
  l_display_name       varchar2(80);
  l_description        varchar2(2000);
  l_javagenerate       varchar2(240);
  l_irep_annotation    varchar2(2000);
begin
  select NAME, TYPE, STATUS, GENERATE_FUNCTION, OWNER_NAME,
         OWNER_TAG, DISPLAY_NAME, DESCRIPTION, CUSTOMIZATION_LEVEL,
	 LICENSED_FLAG,JAVA_GENERATE_FUNC, IREP_ANNOTATION
    into L_NAME, L_TYPE, L_STATUS, L_GENERATE_FUNCTION, L_OWNER_NAME,
         L_OWNER_TAG, L_DISPLAY_NAME, L_DESCRIPTION, l_customization_level,
	 l_licensed_flag,l_javagenerate, l_irep_annotation
    from wf_events_vl
  where guid = x_guid;

  l_doc := xmldom.newDOMDocument;
  l_root := xmldom.makeNode(l_doc);
  l_root := wf_event_xml.newtag (l_doc, l_root, wf_event_xml.masterTagName);
  l_header := wf_event_xml.newtag(l_doc, l_root, m_table_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, wf_event_xml.versionTagName,
                                                 m_package_version);
  -- l_node := wf_event_xml.newtag(l_doc, l_header, 'GUID',
  --                                  rawtohex(x_GUID));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'GUID', '#NEW');
  l_node := wf_event_xml.newtag(l_doc, l_header, 'NAME',
                                    l_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'TYPE',
                                    l_type);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'STATUS',
                                    l_status);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'GENERATE_FUNCTION',
                                    l_generate_function);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'OWNER_NAME',
                                    l_owner_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'OWNER_TAG',
                                    l_owner_tag);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'CUSTOMIZATION_LEVEL',
                                    NVL(l_customization_level, 'L'));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'LICENSED_FLAG',
                                    NVL(l_licensed_flag, 'Y'));

  --Bug 3328673
  --New tag for loader <JAVA_GENERATE_FUNC> nullable field
  l_node := wf_event_xml.newtag(l_doc, l_header, 'JAVA_GENERATE_FUNC',
                                     l_javagenerate);

  l_node := wf_event_xml.newtag(l_doc, l_header, 'DISPLAY_NAME',
                                    l_display_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'DESCRIPTION',
                                    l_description);

  if (l_irep_annotation is null) then
    -- create an annotation template
    l_irep_annotation := wf_core.newline ||
                        '/*#'||wf_core.newline||
                        ' * '||l_description||wf_core.newline||
                        ' * '||wf_core.newline||
                        ' * @rep:scope public '||wf_core.newline||
                        ' * @rep:displayname '||l_display_name||wf_core.newline||
                        ' * @rep:product '||l_owner_tag||wf_core.newline||
                        ' * @rep:category BUSINESS_ENTITY '||wf_core.newline||
                        ' */'||wf_core.newline;

  elsif (trim(l_irep_annotation) = m_null) then
    -- event was reviewed for annotation and decided not to be annotated
    l_irep_annotation := null;
  end if;

  -- l_node := wf_event_xml.newCDATATag(l_doc, l_header, 'IREP_ANNOTATION', l_irep_annotation);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'IREP_ANNOTATION', l_irep_annotation);

  xmldom.writeToBuffer(l_root, buf);

  return buf;
exception
  when others then
    wf_core.context('Wf_Events_Pkg', 'Generate', x_guid);
    raise;
end GENERATE;
----------------------------------------------------------------------------
procedure RECEIVE (
  X_MESSAGE            in varchar2
) is
  l_guid    	      varchar2(32);
  l_name              varchar2(240);
  l_type    	      varchar2(8);
  l_status            varchar2(8);
  l_generate_function varchar2(240);
  l_owner_name        varchar2(30);
  l_owner_tag         varchar2(30);
  l_display_name      varchar2(80);
  l_description       varchar2(2000);
  l_version	      varchar2(80);
  l_message        varchar2(32000);
  l_customization_level	varchar2(1) := 'L';
  l_licensed_flag     varchar2(1) := 'Y';

  l_node_name        varchar2(255);
  l_node             xmldom.DOMNode;
  l_child            xmldom.DOMNode;
  l_value            varchar2(32000);
  l_length           integer;
  l_node_list        xmldom.DOMNodeList;
  l_javagenerate     varchar2(240);
  l_irep_annotation  varchar2(2000);
begin

  l_message := x_message;
  l_message := WF_EVENT_SYNCHRONIZE_PKG.SetGUID(l_message); -- update #NEW
  l_message := WF_EVENT_SYNCHRONIZE_PKG.SetSYSTEMGUID(l_message); -- update #LOCAL
  l_message := WF_EVENT_SYNCHRONIZE_PKG.SetSID(l_message); -- update #SID

  l_node_list := wf_event_xml.findTable(l_message, m_table_name);
  l_length := xmldom.getLength(l_node_list);

  -- loop through elements that we received.
  for i in 0..l_length-1 loop
     l_node := xmldom.item(l_node_list, i);
     l_node_name := xmldom.getNodeName(l_node);
     if xmldom.hasChildNodes(l_node) then
        l_child := xmldom.GetFirstChild(l_node);
        l_value := xmldom.getNodevalue(l_child);
     else
        l_value := NULL;
     end if;

     if(l_node_name = 'GUID') then
       l_guid := l_value;
     elsif(l_node_name = 'NAME') then
       l_NAME := l_value;
     elsif(l_node_name = 'TYPE') then
       l_TYPE := l_value;
     elsif(l_node_name = 'STATUS') then
       l_STATUS := l_value;
     elsif(l_node_name = 'GENERATE_FUNCTION') then
       l_GENERATE_FUNCTION := l_value;
     elsif(l_node_name = 'OWNER_NAME') then
       l_OWNER_NAME := l_value;
     elsif(l_node_name = 'OWNER_TAG') then
       l_OWNER_TAG := l_value;
     elsif(l_node_name = 'DISPLAY_NAME') then
       l_DISPLAY_NAME := l_value;
     elsif(l_node_name = 'DESCRIPTION') then
       l_DESCRIPTION := l_value;
     elsif(l_node_name = 'CUSTOMIZATION_LEVEL') then
       l_CUSTOMIZATION_LEVEL := l_value;
     elsif(l_node_name = 'LICENSED_FLAG') then
       l_LICENSED_FLAG := l_value;
     elsif(l_node_name = wf_event_xml.versionTagName) then
       l_version := l_value;
     elsif(l_node_name = 'JAVA_GENERATE_FUNC') then
       l_javagenerate := l_value;
     elsif(l_node_name = 'IREP_ANNOTATION') then
       -- if empty tags are provided in the WFX the event was reviewed for
       -- annotation and hence does not require the template next time it
       -- is downloaded
       if (l_value is null or length(trim(l_value)) <= 0) then
         l_irep_annotation := m_null;
       else
         l_irep_annotation := l_value;
       end if;
     else
       Wf_Core.Token('REASON', 'Invalid column name found:' ||
           l_node_name || ' with value:'||l_value);
       Wf_Core.Raise('WFSQL_INTERNAL');
     end if;
  end loop;

  if (L_OWNER_NAME is null)
  or (L_OWNER_TAG is null) then
    if WF_EVENTS_PKG.g_Mode <> 'UPGRADE' then
       Wf_Core.Token('REASON','Event Owner Name and Owner Tag cannot be null');
       Wf_Core.Raise('WFSQL_INTERNAL');
    else
       wf_core.context('Wf_Events_Pkg', 'Receive',
	'WARNING! WARNING! Event OWNER_NAME/OWNER_TAG cannot be null for Event ' || l_name);
    end if;
  end if;

  load_row(l_guid, L_NAME, L_TYPE, L_STATUS, L_GENERATE_FUNCTION,
            L_OWNER_NAME, L_OWNER_TAG, L_DISPLAY_NAME, l_DESCRIPTION,
	    l_CUSTOMIZATION_LEVEL, l_LICENSED_FLAG ,l_javagenerate, l_irep_annotation);
exception
  when others then
    wf_core.context('Wf_Events_Pkg', 'Receive', x_message);
    raise;
end RECEIVE;


procedure fetch_custom_level(X_GUID in raw,
			     X_CUSTOMIZATION_LEVEL out nocopy varchar2)
is
  cursor c_getCustomLevel is
  select CUSTOMIZATION_LEVEL from
  WF_EVENTS
  where guid = X_GUID;

 l_custom_level varchar2(1);
 l_found varchar2(1) := 'N';

begin
  for v_customlevel in c_getCustomLevel loop
	X_CUSTOMIZATION_LEVEL := v_customlevel.customization_level;
	l_found := 'Y';
  end loop;

  if l_found = 'N' then
	-- The Event  was not found...
	raise no_data_found;
  end if;

end fetch_custom_level;

----------------------------------------------------------------------------
function is_product_licensed( X_OWNER_TAG in varchar2)
return varchar2
is
 l_licensed_flag varchar2(1);
 l_schema varchar2(30);
 l_industry varchar2(1);
 l_appl_id number;

 e_package_not_found EXCEPTION;
 PRAGMA EXCEPTION_INIT(e_package_not_found, -06550);
begin
   /* Customer defined Data should not have impact licensing
   if g_Mode = 'CUSTOM' then
	return ('Y');
   end if; */

   begin
	execute immediate 'begin if NOT FND_INSTALLATION.get_app_info(:a, :b, :c,:d) then raise FND_API.G_EXC_ERROR; end if; end;'

	using X_OWNER_TAG, out l_licensed_flag, out l_industry, out l_schema;

	-- The possible values for l_licensed_flag from the API are:
	-- I: Installed : licensed_flag must be set to 'Y'
	-- N: Not Installed : licensed_flag must be set to 'N'
	-- S: Shared Install : licensed_flag must be set to 'Y'
	if l_licensed_flag in('S', 'I') then
		l_licensed_flag := 'Y';
    else
        begin
           select application_id
	       into l_appl_id
           from  fnd_application
           where application_short_name = X_OWNER_TAG;

           If l_appl_id >= 20000 then
              l_licensed_flag := 'Y';
           end if;
        exception
           when no_data_found then
                 null;
        end;
	end if;

   exception
   when e_package_not_found then
	l_licensed_flag := 'Y';
   end;
	return (l_licensed_flag);

end is_product_licensed;

----------------------------------------------------------------------------
function is_update_allowed(X_CUSTOM_LEVEL_NEW in varchar2,
			   X_CUSTOM_LEVEL_OLD in varchar2) return varchar2
is
begin

  -- Cannot overwrite data with a higher customization level
  if X_CUSTOM_LEVEL_NEW = 'U' then
	if X_CUSTOM_LEVEL_OLD in ('C','L') then
		-- Error will be logged
		return ('N');
	elsif X_CUSTOM_LEVEL_OLD = 'U' then
		-- Return Y. Update is based on the caller
		return ('Y');
	end if;
  elsif X_CUSTOM_LEVEL_NEW = 'L' then
        if X_CUSTOM_LEVEL_OLD = 'C' then
		-- Error will be logged
                return('N');
        elsif X_CUSTOM_LEVEL_OLD = 'U' then
		-- Override it
                return('Y');
        else
		-- Customization Level is L
                return('Y');
        end if;
  elsif X_CUSTOM_LEVEL_NEW = 'C' then
	-- Override the values in the database irrespective of the value
	-- Return Y. Update is based on the caller
	return('Y');
  end if;

end is_update_allowed;
----------------------------------------------------------------------------
-- This is called by the SSA Framework (wfehtmb.pls) only before calling any
-- table handlers

procedure setMode
is
 uname varchar2(320);
begin
 /*if g_Mode is null then
	wfa_sec.GetSession(uname);
 end if;

 if uname = g_SeedUser then
	g_Mode := 'FORCE';
 else
	g_Mode := 'CUSTOM';
 end if;
 */
 WF_EVENTS_APPS_PKG.setMode;
end setMode;

----------------------------------------------------------------------------
-- This is called by the OA Framework code before calling the table handlers

procedure FWKsetMode
is
 uname varchar2(320);
begin
 /*if g_Mode is null then
	uname  := wfa_sec.GetFWKUserName;
 end if;

 if uname = g_SeedUser then
	g_Mode := 'FORCE';
 else
	g_Mode := 'CUSTOM';
 end if;
 */
 WF_EVENTS_APPS_PKG.FWKsetMode;
end FWKsetMode;
----------------------------------------------------------------------------
-- This is called by the Loader before calling any table handlers

procedure LoadersetMode(x_mode in varchar2)
is
begin
	g_Mode := x_mode;
end LoadersetMode;
----------------------------------------------------------------------------

end WF_EVENTS_PKG;

/
