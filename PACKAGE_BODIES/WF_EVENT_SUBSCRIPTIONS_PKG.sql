--------------------------------------------------------
--  DDL for Package Body WF_EVENT_SUBSCRIPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENT_SUBSCRIPTIONS_PKG" as
/* $Header: WFEVSUBB.pls 120.6.12010000.2 2009/05/27 20:44:09 alepe ship $ */
m_table_name       varchar2(255) := 'WF_EVENT_SUBSCRIPTIONS';
m_package_version  varchar2(30)  := '1.0';


procedure validate_subscription (X_EVENT_FILTER_GUID in raw,
				 X_CUSTOMIZATION_LEVEL in varchar2,
                                 X_STATUS in varchar2);         -- Bug 2756800

procedure fetch_custom_level(X_GUID in raw,
			       X_CUSTOMIZATION_LEVEL out nocopy varchar2);

function find_subscription(x_subscription_guid in varchar2,
                           x_system_guid       in raw,
                           x_source_type       in varchar2,
                           x_source_agent_guid in raw,
                           x_event_filter_guid in raw,
                           x_phase             in number,
                           x_rule_data         in varchar2,
                           x_priority          in number,
                           x_rule_function     in varchar2,
                           x_wf_process_type   in varchar2,
                           x_wf_process_name   in varchar2,
                           x_parameters        in varchar2,
                           x_owner_name        in varchar2,
                           x_owner_tag         in varchar2) return raw;

----------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID              in out nocopy varchar2,
  X_GUID               in     raw,
  X_SYSTEM_GUID        in     raw,
  X_SOURCE_TYPE        in     varchar2,
  X_SOURCE_AGENT_GUID  in     raw,
  X_EVENT_FILTER_GUID  in     raw,
  X_PHASE              in     number,
  X_STATUS             in     varchar2,
  X_RULE_DATA          in     varchar2,
  X_OUT_AGENT_GUID     in     raw,
  X_TO_AGENT_GUID      in     raw,
  X_PRIORITY           in     number,
  X_RULE_FUNCTION      in     varchar2,
  X_WF_PROCESS_TYPE    in     varchar2,
  X_WF_PROCESS_NAME    in     varchar2,
  X_PARAMETERS         in     varchar2,
  X_OWNER_NAME         in     varchar2,
  X_OWNER_TAG          in     varchar2,
  X_CUSTOMIZATION_LEVEL in     varchar2,
  X_LICENSED_FLAG       in     varchar2,
  X_DESCRIPTION        in     varchar2,
  X_EXPRESSION         in     varchar2,
  X_ACTION_CODE        in     varchar2,
  X_ON_ERROR_CODE      in     varchar2,
  X_JAVA_RULE_FUNC     in     varchar2,
  X_MAP_CODE           in     varchar2,
  X_STANDARD_CODE      in     varchar2,
  X_STANDARD_TYPE      in     varchar2
) is

  l_guid raw(16);
  l_event_name varchar2(240);
  cursor C is select ROWID from wf_event_subscriptions where guid = x_guid;
  l_licensed_flag varchar2(1);
  l_rule_func     varchar2(240);
begin
  validate_subscription (X_EVENT_FILTER_GUID,
			 X_CUSTOMIZATION_LEVEL,
                         X_STATUS);     -- Bug 2756800

  l_licensed_flag := WF_EVENTS_PKG.is_product_licensed (X_OWNER_TAG);
  if (X_RULE_FUNCTION is null and X_JAVA_RULE_FUNC is null) then
     l_rule_func := 'WF_RULE.DEFAULT_RULE';
  elsif (x_rule_function is not null) then
     l_rule_func := x_rule_function;
  end if;

  -- Get the GUID of the subscription if one is already there with the same information
  l_guid := Find_Subscription(x_subscription_guid => insert_row.x_guid,
                              x_system_guid       => insert_row.x_system_guid,
                              x_source_type       => insert_row.x_source_type,
                              x_source_agent_guid => insert_row.x_source_agent_guid,
                              x_event_filter_guid => insert_row.x_event_filter_guid,
                              x_phase             => insert_row.x_phase,
                              x_rule_data         => insert_row.x_rule_data,
                              x_priority          => insert_row.x_priority,
                              x_rule_function     => insert_row.x_rule_function,
                              x_wf_process_type   => insert_row.x_wf_process_type,
                              x_wf_process_name   => insert_row.x_wf_process_name,
                              x_parameters        => insert_row.x_parameters,
                              x_owner_name        => insert_row.x_owner_name,
                              x_owner_tag         => insert_row.x_owner_tag);

  if (l_guid <> x_guid) then
    -- If l_guid is not same as x_guid, we already have a subscription with same information.
    -- Throw an error to the UI.
    begin
      SELECT name
      INTO   l_event_name
      FROM   wf_events
      WHERE  guid = x_event_filter_guid;
    exception
      when no_data_found then
        null;
    end;
    Wf_Core.Token('EVENT', l_event_name);
    Wf_Core.Token('SOURCE', x_source_type);
    Wf_Core.Token('PHASE', x_phase);
    Wf_Core.Token('OWNERNAME', x_owner_name);
    Wf_Core.Token('OWNERTAG', x_owner_tag);
    Wf_Core.Raise('WFE_DUPLICATE_SUB');
  else
    insert into wf_event_subscriptions (
    guid,
    system_guid,
    source_type,
    source_agent_guid,
    event_filter_guid,
    phase,
    status,
    rule_data,
    out_agent_guid,
    to_agent_guid,
    priority,
    rule_function,
    wf_process_type,
    wf_process_name,
    parameters,
    owner_name,
    owner_tag,
    customization_level,
    licensed_flag,
    description,
    expression,
    action_code,
    on_error_code,
    java_rule_func,
    map_code,
    standard_code,
    standard_type
  ) select  X_GUID,
            X_SYSTEM_GUID,
            X_SOURCE_TYPE,
            X_SOURCE_AGENT_GUID,
            X_EVENT_FILTER_GUID,
            X_PHASE,
            X_STATUS,
            X_RULE_DATA,
            X_OUT_AGENT_GUID,
            X_TO_AGENT_GUID,
            X_PRIORITY,
            l_rule_func,
            X_WF_PROCESS_TYPE,
            X_WF_PROCESS_NAME,
            X_PARAMETERS,
            X_OWNER_NAME,
            X_OWNER_TAG,
            X_CUSTOMIZATION_LEVEL,
            l_licensed_flag,
            X_DESCRIPTION,
            X_EXPRESSION,
            X_ACTION_CODE,
            X_ON_ERROR_CODE,
            X_JAVA_RULE_FUNC,
            X_MAP_CODE,
            X_STANDARD_CODE,
            X_STANDARD_TYPE
    from dual where not exists (
        select 'duplicate'
        from   wf_event_subscriptions
        where  guid = X_GUID);
  end if;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  else
    wf_event.raise('oracle.apps.wf.event.subscription.create', x_guid);
  end if;
  close c;

exception
  when others then
    wf_core.context('Wf_Events_Subscriptions_Pkg', 'Insert_Row', x_guid,
       x_system_guid, X_SOURCE_TYPE, X_SOURCE_AGENT_GUID);
    raise;

end INSERT_ROW;
----------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_GUID               in     raw,
  X_SYSTEM_GUID        in     raw,
  X_SOURCE_TYPE        in     varchar2,
  X_SOURCE_AGENT_GUID  in     raw,
  X_EVENT_FILTER_GUID  in     raw,
  X_PHASE              in     number,
  X_STATUS             in     varchar2,
  X_RULE_DATA          in     varchar2,
  X_OUT_AGENT_GUID     in     raw,
  X_TO_AGENT_GUID      in     raw,
  X_PRIORITY           in     number,
  X_RULE_FUNCTION      in     varchar2,
  X_WF_PROCESS_TYPE    in     varchar2,
  X_WF_PROCESS_NAME    in     varchar2,
  X_PARAMETERS         in     varchar2,
  X_OWNER_NAME         in     varchar2,
  X_OWNER_TAG          in     varchar2,
  X_CUSTOMIZATION_LEVEL in     varchar2,
  X_LICENSED_FLAG       in     varchar2,
  X_DESCRIPTION        in     varchar2,
  X_EXPRESSION         in     varchar2,
  X_ACTION_CODE        in     varchar2,
  X_ON_ERROR_CODE      in     varchar2,
  X_JAVA_RULE_FUNC     in     varchar2,
  X_MAP_CODE           in     varchar2,
  X_STANDARD_CODE      in     varchar2,
  X_STANDARD_TYPE      in     varchar2
) is
 l_custom_level varchar2(1);
 l_update_allowed varchar2(1) := 'Y';
 l_licensed_flag varchar2(1) := 'N';
 l_raise_event_flag varchar2(1) := 'N';
 l_guid raw(16);
 l_event_name varchar2(240);
 l_rule_func VARCHAR2(240);
begin
  validate_subscription (X_EVENT_FILTER_GUID,
			 X_CUSTOMIZATION_LEVEL,
                         X_STATUS);     -- Bug 2756800

  l_licensed_flag := WF_EVENTS_PKG.is_product_licensed (X_OWNER_TAG);
  if (X_RULE_FUNCTION is null and X_JAVA_RULE_FUNC is null) then
     l_rule_func := 'WF_RULE.DEFAULT_RULE';
  elsif (x_rule_function is not null) then
     l_rule_func := x_rule_function;
  end if;

  -- Check if the subscription is duplicate.
  l_guid := Find_Subscription(x_subscription_guid => update_row.x_guid,
                              x_system_guid       => update_row.x_system_guid,
                              x_source_type       => update_row.x_source_type,
                              x_source_agent_guid => update_row.x_source_agent_guid,
                              x_event_filter_guid => update_row.x_event_filter_guid,
                              x_phase             => update_row.x_phase,
                              x_rule_data         => update_row.x_rule_data,
                              x_priority          => update_row.x_priority,
                              x_rule_function     => update_row.x_rule_function,
                              x_wf_process_type   => update_row.x_wf_process_type,
                              x_wf_process_name   => update_row.x_wf_process_name,
                              x_parameters        => update_row.x_parameters,
                              x_owner_name        => update_row.x_owner_name,
                              x_owner_tag         => update_row.x_owner_tag);

 if (l_guid <> x_guid) then
    -- If l_guid is not same as x_guid, we already have a subscription with same information.
    -- Throw an error to the UI.
    begin
      SELECT name
      INTO   l_event_name
      FROM   wf_events
      WHERE  guid = x_event_filter_guid;
    exception
      when no_data_found then
        null;
    end;
    Wf_Core.Context('Wf_Event_Subscriptions_Pkg', 'Update_Row');
    Wf_Core.Token('EVENT', l_event_name);
    Wf_Core.Token('SOURCE', x_source_type);
    Wf_Core.Token('PHASE', x_phase);
    Wf_Core.Token('OWNERNAME', x_owner_name);
    Wf_Core.Token('OWNERTAG', x_owner_tag);
    Wf_Core.Raise('WFE_DUPLICATE_SUB');
  end if;

  if WF_EVENTS_PKG.g_Mode = 'FORCE' then
  	update wf_event_subscriptions set
    	system_guid        = X_SYSTEM_GUID,
    	source_type        = X_SOURCE_TYPE,
    	source_agent_guid  = X_SOURCE_AGENT_GUID,
    	event_filter_guid  = X_EVENT_FILTER_GUID,
    	phase              = X_PHASE,
    	status             = X_STATUS,
    	rule_data          = X_RULE_DATA,
    	out_agent_guid     = X_OUT_AGENT_GUID,
    	to_agent_guid      = X_TO_AGENT_GUID,
    	priority           = X_PRIORITY,
    	rule_function      = l_rule_func,
    	wf_process_type    = X_WF_PROCESS_TYPE,
    	wf_process_name    = X_WF_PROCESS_NAME,
    	parameters         = X_PARAMETERS,
    	owner_name         = X_OWNER_NAME,
    	owner_tag          = X_OWNER_TAG,
    	description        = X_DESCRIPTION,
        customization_level = X_CUSTOMIZATION_LEVEL,
        licensed_flag      = l_licensed_flag,
    	expression         = X_EXPRESSION,
        action_code        = X_ACTION_CODE,
        on_error_code      = X_ON_ERROR_CODE,
        java_rule_func     = X_JAVA_RULE_FUNC,
        map_code           = X_MAP_CODE,
        standard_code      = X_STANDARD_CODE,
        standard_type      = X_STANDARD_TYPE
  	where guid = X_GUID;

  	if (sql%notfound) then
    		raise no_data_found;
  	else
    		wf_event.raise('oracle.apps.wf.event.subscription.update', X_GUID);
  	end if;

  else
	-- User logged in is not seed
	fetch_custom_level(X_GUID, l_custom_level);
	l_update_allowed := WF_EVENTS_PKG.is_update_allowed(X_CUSTOMIZATION_LEVEL, l_custom_level);

	if l_update_allowed = 'N' then
		-- Set up the Error Stack
 		wf_core.context('WF_EVENT_SUBSCRIPTIONS_PKG','UPDATE_ROW',
			  X_EVENT_FILTER_GUID,
			  l_custom_level,
			  X_CUSTOMIZATION_LEVEL);
		return;
	end if;

	if X_CUSTOMIZATION_LEVEL = 'C'then
		if WF_EVENTS_PKG.g_Mode = 'UPGRADE' then
			-- Here are the updates allowed when the caller is the Loader
  			update wf_event_subscriptions set
    			system_guid        = X_SYSTEM_GUID,
    			source_type        = X_SOURCE_TYPE,
    			source_agent_guid  = X_SOURCE_AGENT_GUID,
    			event_filter_guid  = X_EVENT_FILTER_GUID,
    			phase              = X_PHASE,
    			status             = X_STATUS,
    			rule_data          = X_RULE_DATA,
    			out_agent_guid     = X_OUT_AGENT_GUID,
    			to_agent_guid      = X_TO_AGENT_GUID,
    			priority           = X_PRIORITY,
    			rule_function      = l_rule_func,
    			wf_process_type    = X_WF_PROCESS_TYPE,
    			wf_process_name    = X_WF_PROCESS_NAME,
    			parameters         = X_PARAMETERS,
    			owner_name         = X_OWNER_NAME,
    			owner_tag          = X_OWNER_TAG,
    			description        = X_DESCRIPTION,
        		customization_level = X_CUSTOMIZATION_LEVEL,
        		licensed_flag      = l_licensed_flag,
    			expression         = X_EXPRESSION,
                        action_code        = X_ACTION_CODE,
                        on_error_code      = X_ON_ERROR_CODE,
                        java_rule_func     = X_JAVA_RULE_FUNC,
                        map_code           = X_MAP_CODE,
                        standard_code      = X_STANDARD_CODE,
                        standard_type      = X_STANDARD_TYPE
  			where guid = X_GUID;

    			l_raise_event_flag := 'Y';
		else
			-- UI users cannot update Core events
			null;

		end if;
  	elsif X_CUSTOMIZATION_LEVEL = 'L' then
		if WF_EVENTS_PKG.g_Mode = 'UPGRADE' then
		-- Limit events can have only a status change..
		-- When the loader is loading the events the
		-- users changes must be preserved. Update all
		-- fields EXCEPT the status field.
  			update wf_event_subscriptions set
    			system_guid        = X_SYSTEM_GUID,
    			source_type        = X_SOURCE_TYPE,
    			source_agent_guid  = X_SOURCE_AGENT_GUID,
    			event_filter_guid  = X_EVENT_FILTER_GUID,
    			phase              = X_PHASE,
    			rule_data          = X_RULE_DATA,
    			out_agent_guid     = X_OUT_AGENT_GUID,
    			to_agent_guid      = X_TO_AGENT_GUID,
    			priority           = X_PRIORITY,
    			rule_function      = l_rule_func,
    			wf_process_type    = X_WF_PROCESS_TYPE,
    			wf_process_name    = X_WF_PROCESS_NAME,
    			parameters         = X_PARAMETERS,
    			owner_name         = X_OWNER_NAME,
    			owner_tag          = X_OWNER_TAG,
    			description        = X_DESCRIPTION,
        		customization_level = X_CUSTOMIZATION_LEVEL,
        		licensed_flag      = l_licensed_flag,
    			expression         = X_EXPRESSION,
                        action_code        = X_ACTION_CODE,
                        on_error_code      = X_ON_ERROR_CODE,
                        java_rule_func     = X_JAVA_RULE_FUNC,
                        map_code           = X_MAP_CODE,
                        standard_code      = X_STANDARD_CODE,
                        standard_type      = X_STANDARD_TYPE
  			where guid = X_GUID;

    			l_raise_event_flag := 'Y';

		else -- Caller of the Update is UI
		-- Limit events can have only a status change..
		-- When the user is updating the event using the UI
		-- Updates are allowed ONLY to the status field.
			update wf_event_subscriptions set
			status            = X_STATUS,
        		licensed_flag      = l_licensed_flag
			where guid = X_GUID;

    			l_raise_event_flag := 'Y';

		end if;

	elsif X_CUSTOMIZATION_LEVEL = 'U' then
	-- Here are the updates allowed for extensible and User defined events
	-- only when the caller is the UI

		if WF_EVENTS_PKG.g_Mode = 'CUSTOM' then
  			update wf_event_subscriptions set
    			system_guid        = X_SYSTEM_GUID,
    			source_type        = X_SOURCE_TYPE,
    			source_agent_guid  = X_SOURCE_AGENT_GUID,
    			event_filter_guid  = X_EVENT_FILTER_GUID,
    			phase              = X_PHASE,
    			status             = X_STATUS,
    			rule_data          = X_RULE_DATA,
    			out_agent_guid     = X_OUT_AGENT_GUID,
    			to_agent_guid      = X_TO_AGENT_GUID,
    			priority           = X_PRIORITY,
    			rule_function      = l_rule_func,
    			wf_process_type    = X_WF_PROCESS_TYPE,
    			wf_process_name    = X_WF_PROCESS_NAME,
    			parameters         = X_PARAMETERS,
    			owner_name         = X_OWNER_NAME,
    			owner_tag          = X_OWNER_TAG,
    			description        = X_DESCRIPTION,
        		customization_level = X_CUSTOMIZATION_LEVEL,
        		licensed_flag      = l_licensed_flag,
    			expression         = X_EXPRESSION,
                        action_code        = X_ACTION_CODE,
                        on_error_code      = X_ON_ERROR_CODE,
                        java_rule_func     = X_JAVA_RULE_FUNC,
                        map_code           = X_MAP_CODE,
                        standard_code      = X_STANDARD_CODE,
                        standard_type      = X_STANDARD_TYPE
  			where guid = X_GUID;

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

	-- Only raise if all if no raise_event_flag is set to 'Y'
	-- fetch_custom_level will raise no_data_found if the subscription is not found
  	if (l_raise_event_flag = 'Y') then
    		wf_event.raise('oracle.apps.wf.event.subscription.update', X_GUID);
  	end if;

  end if;

  -- Invalidate cache
  wf_bes_cache.SetMetaDataUploaded();
end UPDATE_ROW;
-----------------------------------------------------------------------------
procedure LOAD_ROW (
  X_GUID               in     raw,
  X_SYSTEM_GUID        in     raw,
  X_SOURCE_TYPE        in     varchar2,
  X_SOURCE_AGENT_GUID  in     raw,
  X_EVENT_FILTER_GUID  in     raw,
  X_PHASE              in     number,
  X_STATUS             in     varchar2,
  X_RULE_DATA          in     varchar2,
  X_OUT_AGENT_GUID     in     raw,
  X_TO_AGENT_GUID      in     raw,
  X_PRIORITY           in     number,
  X_RULE_FUNCTION      in     varchar2,
  X_WF_PROCESS_TYPE    in     varchar2,
  X_WF_PROCESS_NAME    in     varchar2,
  X_PARAMETERS         in     varchar2,
  X_OWNER_NAME         in     varchar2,
  X_OWNER_TAG          in     varchar2,
  X_CUSTOMIZATION_LEVEL in     varchar2,
  X_LICENSED_FLAG       in     varchar2,
  X_DESCRIPTION        in     varchar2,
  X_EXPRESSION         in     varchar2,
  X_ACTION_CODE        in     varchar2,
  X_ON_ERROR_CODE      in     varchar2,
  X_JAVA_RULE_FUNC     in     varchar2,
  X_MAP_CODE           in     varchar2,
  X_STANDARD_CODE      in     varchar2,
  X_STANDARD_TYPE      in     varchar2
) is
  row_id  varchar2(64);
begin
  begin
    WF_EVENT_SUBSCRIPTIONS_PKG.UPDATE_ROW (
      X_GUID               => X_GUID,
      X_SYSTEM_GUID        => X_SYSTEM_GUID,
      X_SOURCE_TYPE        => X_SOURCE_TYPE,
      X_SOURCE_AGENT_GUID  => X_SOURCE_AGENT_GUID,
      X_EVENT_FILTER_GUID  => X_EVENT_FILTER_GUID,
      X_PHASE              => X_PHASE,
      X_STATUS             => X_STATUS,
      X_RULE_DATA          => X_RULE_DATA,
      X_OUT_AGENT_GUID     => X_OUT_AGENT_GUID,
      X_TO_AGENT_GUID      => X_TO_AGENT_GUID,
      X_PRIORITY           => X_PRIORITY,
      X_RULE_FUNCTION      => X_RULE_FUNCTION,
      X_WF_PROCESS_TYPE    => X_WF_PROCESS_TYPE,
      X_WF_PROCESS_NAME    => X_WF_PROCESS_NAME,
      X_PARAMETERS         => X_PARAMETERS,
      X_OWNER_NAME         => X_OWNER_NAME,
      X_OWNER_TAG          => X_OWNER_TAG,
      X_CUSTOMIZATION_LEVEL => X_CUSTOMIZATION_LEVEL,
      X_LICENSED_FLAG       => X_LICENSED_FLAG,
      X_DESCRIPTION        => X_DESCRIPTION,
      X_EXPRESSION         => X_EXPRESSION,
      X_ACTION_CODE        => X_ACTION_CODE,
      X_ON_ERROR_CODE      => X_ON_ERROR_CODE,
      X_JAVA_RULE_FUNC     => X_JAVA_RULE_FUNC,
      X_MAP_CODE           => X_MAP_CODE,
      X_STANDARD_CODE      => X_STANDARD_CODE,
      X_STANDARD_TYPE      => X_STANDARD_TYPE
    );
  exception
    when no_data_found then
      WF_EVENT_SUBSCRIPTIONS_PKG.INSERT_ROW(
        X_ROWID              => row_id,
        X_GUID               => X_GUID,
        X_SYSTEM_GUID        => X_SYSTEM_GUID,
        X_SOURCE_TYPE        => X_SOURCE_TYPE,
        X_SOURCE_AGENT_GUID  => X_SOURCE_AGENT_GUID,
        X_EVENT_FILTER_GUID  => X_EVENT_FILTER_GUID,
        X_PHASE              => X_PHASE,
        X_STATUS             => X_STATUS,
        X_RULE_DATA          => X_RULE_DATA,
        X_OUT_AGENT_GUID     => X_OUT_AGENT_GUID,
        X_TO_AGENT_GUID      => X_TO_AGENT_GUID,
        X_PRIORITY           => X_PRIORITY,
        X_RULE_FUNCTION      => X_RULE_FUNCTION,
        X_WF_PROCESS_TYPE    => X_WF_PROCESS_TYPE,
        X_WF_PROCESS_NAME    => X_WF_PROCESS_NAME,
        X_PARAMETERS         => X_PARAMETERS,
        X_OWNER_NAME         => X_OWNER_NAME,
        X_OWNER_TAG          => X_OWNER_TAG,
        X_CUSTOMIZATION_LEVEL => X_CUSTOMIZATION_LEVEL,
        X_LICENSED_FLAG       => X_LICENSED_FLAG,
        X_DESCRIPTION        => X_DESCRIPTION,
        X_EXPRESSION         => X_EXPRESSION,
        X_ACTION_CODE        => X_ACTION_CODE,
        X_ON_ERROR_CODE      => X_ON_ERROR_CODE,
        X_JAVA_RULE_FUNC     => X_JAVA_RULE_FUNC,
        X_MAP_CODE           => X_MAP_CODE,
        X_STANDARD_CODE      => X_STANDARD_CODE,
        X_STANDARD_TYPE      => X_STANDARD_TYPE
      );
  end;

  -- Invalidate cache
  wf_bes_cache.SetMetaDataUploaded();
exception
  when others then
    wf_core.context('Wf_Event_Subscriptions_Pkg', 'Load_Row', x_guid,
        x_source_type, X_SOURCE_AGENT_GUID);
    raise;
end LOAD_ROW;
-----------------------------------------------------------------------------
procedure DELETE_ROW (X_GUID in raw) is
begin
  wf_event.raise('oracle.apps.wf.event.subscription.delete',x_guid);

  delete from wf_event_subscriptions
  where guid = X_GUID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- Invalidate cache
  wf_bes_cache.SetMetaDataUploaded();
exception
  when others then
    wf_core.context('Wf_Events_Subscriptions_Pkg', 'Delete_Row', x_guid);
    raise;
end DELETE_ROW;
----------------------------------------------------------------------------
procedure DELETE_SET (
  X_SYSTEM_GUID        in     raw,
  X_SOURCE_TYPE        in     varchar2,
  X_SOURCE_AGENT_GUID  in     raw,
  X_EVENT_FILTER_GUID  in     raw,
  X_PHASE              in     number,
  X_STATUS             in     varchar2,
  X_RULE_DATA          in     varchar2,
  X_OUT_AGENT_GUID     in     raw,
  X_TO_AGENT_GUID      in     raw,
  X_PRIORITY           in     number,
  X_RULE_FUNCTION      in     varchar2,
  X_WF_PROCESS_TYPE    in     varchar2,
  X_WF_PROCESS_NAME    in     varchar2,
  X_PARAMETERS         in     varchar2,
  X_OWNER_NAME         in     varchar2,
  X_OWNER_TAG          in     varchar2,
  X_DESCRIPTION        in     varchar2,
  X_EXPRESSION         in     varchar2,
  X_ACTION_CODE        in     varchar2,
  X_ON_ERROR_CODE      in     varchar2,
  X_JAVA_RULE_FUNC     in     varchar2,
  X_MAP_CODE           in     varchar2,
  X_STANDARD_CODE      in     varchar2,
  X_STANDARD_TYPE      in     varchar2
) is
begin
  delete from wf_event_subscriptions
  where  (X_SYSTEM_GUID       is null or (X_SYSTEM_GUID        is not null
        and system_guid       like        X_SYSTEM_GUID))
  and    (X_SOURCE_TYPE       is null or (X_SOURCE_TYPE        is not null
        and source_type       like        X_SOURCE_TYPE))
  and    (X_SOURCE_AGENT_GUID is null or (X_SOURCE_AGENT_GUID  is not null
        and source_agent_guid like        X_SOURCE_AGENT_GUID))
  and    (X_EVENT_FILTER_GUID is null or (X_EVENT_FILTER_GUID  is not null
        and event_filter_guid like        X_EVENT_FILTER_GUID))
  and    (X_PHASE             is null or (X_PHASE              is not null
        and phase             like        X_PHASE))
  and    (X_STATUS            is null or (X_STATUS             is not null
        and status            like        X_STATUS))
  and    (X_RULE_DATA         is null or (X_RULE_DATA          is not null
        and rule_data         like        X_RULE_DATA))
  and    (X_OUT_AGENT_GUID    is null or (X_OUT_AGENT_GUID     is not null
        and out_agent_guid    like        X_OUT_AGENT_GUID))
  and    (X_TO_AGENT_GUID     is null or (X_TO_AGENT_GUID      is not null
        and to_agent_guid     like        X_TO_AGENT_GUID))
  and    (X_PRIORITY          is null or (X_PRIORITY           is not null
        and priority          like        X_PRIORITY))
  and    (X_RULE_FUNCTION     is null or (X_RULE_FUNCTION      is not null
        and rule_function     like        X_RULE_FUNCTION))
  and    (X_WF_PROCESS_TYPE   is null or (X_WF_PROCESS_TYPE    is not null
        and wf_process_type   like        X_WF_PROCESS_TYPE))
  and    (X_WF_PROCESS_NAME   is null or (X_WF_PROCESS_NAME    is not null
        and wf_process_name   like        X_WF_PROCESS_NAME))
  and    (X_PARAMETERS        is null or (X_PARAMETERS         is not null
        and parameters        like        X_PARAMETERS))
  and    (X_OWNER_NAME        is null or (X_OWNER_NAME         is not null
        and owner_name        like        X_OWNER_NAME))
  and    (X_OWNER_TAG         is null or (X_OWNER_TAG          is not null
        and owner_tag         like        X_OWNER_TAG))
  and    (X_DESCRIPTION       is null or (X_DESCRIPTION        is not null
        and description       like        X_DESCRIPTION))
  and    (X_EXPRESSION        is null or (X_EXPRESSION        is not null
        and expression        like        X_EXPRESSION))
  and    (X_ACTION_CODE       is null or (X_ACTION_CODE       is not null
        and action_code       like        X_ACTION_CODE))
  and    (X_ON_ERROR_CODE     is null or (X_ON_ERROR_CODE     is not null
        and on_error_code     like        X_ON_ERROR_CODE))
  and    (X_JAVA_RULE_FUNC    is null or (X_JAVA_RULE_FUNC    is not null
        and java_rule_func    like        X_JAVA_RULE_FUNC))
  and    (X_MAP_CODE          is null or (X_MAP_CODE          is not null
        and map_code          like        X_MAP_CODE))
  and    (X_STANDARD_CODE     is null or (X_STANDARD_CODE     is not null
        and standard_code     like        X_STANDARD_CODE))
  and    (X_STANDARD_TYPE     is null or (X_STANDARD_TYPE     is not null
        and standard_type     like        X_STANDARD_TYPE));

  -- Invalidate cache
  wf_bes_cache.SetMetaDataUploaded();
exception
  when others then
    wf_core.context('Wf_Events_Subscriptions_Pkg', 'Delete_Set',
      x_system_guid, X_source_type, X_Event_Filter_GUID);
    raise;
end DELETE_SET;
----------------------------------------------------------------------------
function GENERATE (
  X_GUID  in  raw
) return varchar2 is
  buf              varchar2(32000);
  l_doc            xmldom.DOMDocument;
  l_element        xmldom.DOMElement;
  l_root           xmldom.DOMNode;
  l_node           xmldom.DOMNode;
  l_header         xmldom.DOMNode;

  l_guid    	      raw(16);
  l_system_guid       raw(16);
  l_source_type       varchar2(80);
  l_source_agent_guid raw(16);
  l_event_filter_name varchar2(240);
  l_phase             number;
  l_status            varchar2(8);
  l_rule_data	      varchar2(8);
  l_out_agent_guid    raw(16);
  l_to_agent_guid     raw(16);
  l_priority          number;
  l_rule_function     varchar2(240);
  l_wf_process_type   varchar2(30);
  l_wf_process_name   varchar2(30);
  l_parameters        varchar2(4000);
  l_owner_name        varchar2(30);
  l_owner_tag         varchar2(30);
  l_customization_level          varchar2(1);
  l_licensed_flag          varchar2(1);
  l_description       varchar2(240);
  l_version           varchar2(80);
  l_expression        varchar2(4000);

  --Bug 3328673
  --JBES Support for loader
  l_standardtype      varchar2(30);
  l_standardcode      varchar2(30);
  l_javarulefunc      varchar2(240);
  l_onerror           varchar2(30);
  l_actioncode        varchar2(30);
begin

  select s.system_guid, s.source_type, s.source_agent_guid,
         e.name, s.phase, s.status, s.rule_data,
         s.out_agent_guid, s.to_agent_guid, s.priority,
         s.rule_function, s.wf_process_type, s.wf_process_name,
         s.parameters, s.owner_name, s.owner_tag, s.description, s.expression,
	 nvl(s.customization_level, 'L'), nvl(s.licensed_flag, 'Y'),
         s.standard_type , s.standard_code , s.java_rule_func , s.on_error_code,
         s.action_code
  into   l_system_guid, l_source_type, l_source_agent_guid,
         l_event_filter_name, l_phase, l_status, l_rule_data,
         l_out_agent_guid, l_to_agent_guid, l_priority,
         l_rule_function, l_wf_process_type, l_wf_process_name,
         l_parameters, l_owner_name, l_owner_tag, l_description, l_expression,
	 l_customization_level, l_licensed_flag,l_standardtype,l_standardcode,
         l_javarulefunc,l_onerror , l_actioncode
  from   wf_event_subscriptions s, wf_events e
  where  s.guid = x_guid
  and    e.guid = s.event_filter_guid;

  l_doc := xmldom.newDOMDocument;
  l_root := xmldom.makeNode(l_doc);
  l_root := wf_event_xml.newtag (l_doc, l_root, wf_event_xml.masterTagName);
  l_header := wf_event_xml.newtag(l_doc, l_root, m_table_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, wf_event_xml.versionTagName,
                                                 m_package_version);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'GUID',
                                    rawtohex(x_guid));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'SYSTEM_GUID',
                                    rawtohex(l_system_guid));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'SOURCE_TYPE',
                                    l_source_type);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'SOURCE_AGENT_GUID',
                                    rawtohex(l_source_agent_guid));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'EVENT_FILTER_GUID', l_event_filter_name);

  l_node := wf_event_xml.newtag(l_doc, l_header, 'PHASE',
                                    l_phase);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'STATUS',
                                    l_status);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'RULE_DATA',
                                    l_rule_data);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'OUT_AGENT_GUID',
                                    rawtohex(l_out_agent_guid));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'TO_AGENT_GUID',
                                    rawtohex(l_to_agent_guid));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'PRIORITY',
                                    l_PRIORITY);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'RULE_FUNCTION',
                                    l_RULE_FUNCTION);
  --Bug 3328673
  --Add new tags for JBES support
  l_node := wf_event_xml.newtag(l_doc, l_header, 'JAVA_RULE_FUNC',
                                   l_javarulefunc);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'STANDARD_TYPE',
                                   l_standardtype);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'STANDARD_CODE',
                                   l_standardcode);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'ON_ERROR_CODE',
                                   l_onerror);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'ACTION_CODE',
                                   l_actioncode);

  l_node := wf_event_xml.newtag(l_doc, l_header, 'WF_PROCESS_TYPE',
                                    l_wf_process_type);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'WF_PROCESS_NAME',
                                    l_wf_process_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'PARAMETERS',
                                    l_PARAMETERS);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'OWNER_NAME',
                                    l_OWNER_NAME);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'OWNER_TAG',
                                    l_OWNER_TAG);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'CUSTOMIZATION_LEVEL',
                                    NVL(l_customization_level, 'L'));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'LICENSED_FLAG',
                                    NVL(l_licensed_flag, 'Y'));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'DESCRIPTION',
                                    l_DESCRIPTION);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'EXPRESSION',
                                    l_EXPRESSION);
  xmldom.writeToBuffer(l_root, buf);

  return buf;
exception
  when others then
    wf_core.context('Wf_Events_Subscriptions_Pkg', 'Generate', x_guid);
    raise;
end GENERATE;
-----------------------------------------------------------------------------
procedure RECEIVE (
  X_MESSAGE     in varchar2
) is
  l_guid    	      raw(16);
  l_system_guid       raw(16);
  l_source_type       varchar2(80);
  l_source_agent_guid raw(16);
  l_event_filter_guid raw(16);
  l_phase             number;
  l_status            varchar2(8);
  l_rule_data	      varchar2(8);
  l_out_agent_guid    raw(16);
  l_to_agent_guid     raw(16);
  l_priority          number;
  l_rule_function     varchar2(240);
  l_wf_process_type   varchar2(30);
  l_wf_process_name   varchar2(30);
  l_parameters        varchar2(4000);
  l_owner_name        varchar2(30);
  l_owner_tag         varchar2(30);
  l_description       varchar2(240);
  l_version           varchar2(80);
  l_message           varchar2(32000);
  l_customization_level varchar2(1) := 'L';
  l_licensed_flag           varchar2(1) := 'Y';
  l_subscription_guid varchar2(32);
  l_expression        varchar2(4000);

  l_node_name        varchar2(255);
  l_node             xmldom.DOMNode;
  l_child            xmldom.DOMNode;
  l_value            varchar2(32000);
  l_length           integer;
  l_node_list        xmldom.DOMNodeList;

  l_num              number;
  --Bug 3328673
  --JBES Support for loader
  l_standardtype      varchar2(30);
  l_standardcode      varchar2(30);
  l_javarulefunc      varchar2(240);
  l_onerror           varchar2(30);
  l_actioncode        varchar2(30);

  -- Identical Row checks from this procedure are now moved to Find_Subscription
begin

  l_message := x_message;
  --l_message := WF_EVENT_SYNCHRONIZE_PKG.SetGUID(l_message); -- update #NEW
  l_message := WF_EVENT_SYNCHRONIZE_PKG.SetSYSTEMGUID(l_message); -- update #LOCAL
  l_message := WF_EVENT_SYNCHRONIZE_PKG.SetSID(l_message); -- update #SID
  --Bug 3191978
  --Replace agent names by their GUIDs
  l_message := WF_EVENT_SYNCHRONIZE_PKG.SetAgent2('<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>',l_message); -- update #WF_IN, #WF_OUT, #WF_ERROR
  l_message := WF_EVENT_SYNCHRONIZE_PKG.SetAgent2('<TO_AGENT_GUID>','</TO_AGENT_GUID>',l_message);
  l_message := WF_EVENT_SYNCHRONIZE_PKG.SetAgent2('<OUT_AGENT_GUID>','</OUT_AGENT_GUID>',l_message);
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
       --l_guid := l_value;
       l_subscription_guid := l_value;
     elsif(l_node_name = 'SYSTEM_GUID') then
       l_SYSTEM_GUID := l_value;
     elsif(l_node_name = 'SOURCE_TYPE') then
       l_source_type := l_value;
     elsif(l_node_name = 'SOURCE_AGENT_GUID') then
       l_source_agent_guid := l_value;
     elsif(l_node_name = 'EVENT_FILTER_GUID') then
       -- Check if the value is event name, get the GUID
       begin
         SELECT guid
         INTO   l_event_filter_guid
         FROM   wf_events
         WHERE  name = l_value;
       exception
         when no_data_found then
           -- Value is a event GUID (older wfx files)
           l_event_filter_guid := l_value;
       end;
     elsif(l_node_name = 'PHASE') then
       l_phase := to_number(l_value);
     elsif(l_node_name = 'STATUS') then
       l_status := l_value;
     elsif(l_node_name = 'RULE_DATA') then
       l_rule_data := l_value;
     elsif(l_node_name = 'OUT_AGENT_GUID') then
       l_out_agent_guid := l_value;
     elsif(l_node_name = 'TO_AGENT_GUID') then
       l_to_agent_guid := l_value;
     elsif(l_node_name = 'PRIORITY') then
       l_priority := to_number(l_value);
     elsif(l_node_name = 'RULE_FUNCTION') then
       l_rule_function := l_value;
     elsif(l_node_name = 'WF_PROCESS_TYPE') then
       l_wf_process_type := l_value;
     elsif(l_node_name = 'WF_PROCESS_NAME') then
       l_wf_process_name := l_value;
     elsif(l_node_name = 'PARAMETERS') then
       l_parameters := l_value;
     elsif(l_node_name = 'OWNER_NAME') then
       l_owner_name := l_value;
     elsif(l_node_name = 'OWNER_TAG') then
       l_owner_tag := l_value;
     elsif(l_node_name = 'CUSTOMIZATION_LEVEL') then
       l_customization_level := l_value;
     elsif(l_node_name = 'LICENSED_FLAG') then
       l_licensed_flag := l_value;
     elsif(l_node_name = 'DESCRIPTION') then
       l_description := l_value;
     elsif(l_node_name = 'VERSION') then
       l_version := l_value;
     elsif(l_node_name = 'EXPRESSION') then
       l_expression := l_value;
     --Bug 3328673
     --JBES Support for loader
     elsif(l_node_name = 'JAVA_RULE_FUNC') then
       l_javarulefunc := l_value;
     elsif(l_node_name = 'STANDARD_TYPE') then
       l_standardtype := l_value;
     elsif(l_node_name = 'STANDARD_CODE') then
       l_standardcode := l_value;
    elsif(l_node_name = 'ON_ERROR_CODE') then
       l_onerror := l_value;
    elsif(l_node_name = 'ACTION_CODE') then
       l_actioncode := l_value;
    else
       Wf_Core.Token('REASON', 'Invalid column name found:' ||
           l_node_name || ' with value:'||l_value);
       Wf_Core.Raise('WFSQL_INTERNAL');
     end if;
  end loop;

  -- Validate Subscription
  -- Phase must not be null
  if L_PHASE is null then
    -- For backward compatibility of the WFXLoad do not raise any errors when
    -- the caller is the Loader. Throw a warning only
    if WF_EVENTS_PKG.g_Mode <> 'UPGRADE' then
       Wf_Core.Token('REASON','Subscription Phase cannot be null');
       Wf_Core.Raise('WFSQL_INTERNAL');
    else
       wf_core.context('Wf_Events_Subscriptions_Pkg', 'Receive',
	'WARNING! WARNING! Subscription Phase CANNOT be null for Event GUID '
        || l_event_filter_guid || ' defaulting to 50');
	l_Phase := 50;
    end if;
  end if;

  -- Validate Subscription
  -- Owner Name and Owner Tag must not be null
  if (L_OWNER_NAME is null)
  or (L_OWNER_TAG is null) then

    -- For backward compatibility of the WFXLoad do not raise any errors when
    -- the caller is the Loader. Throw a warning only
    if WF_EVENTS_PKG.g_Mode <> 'UPGRADE' then
       Wf_Core.Token('REASON','Subscription Owner Name and Owner Tag cannot be null');
       Wf_Core.Raise('WFSQL_INTERNAL');
    else
       wf_core.context('Wf_Events_Subscriptions_Pkg', 'Receive',
	'WARNING! WARNING! Subscription OWNER_NAME/OWNER_TAG CANNOT be null for Event GUID '
       || l_event_filter_guid);
    end if;
  end if;

  -- Check if the subscription is duplicate. If there is one already, use the GUID
  -- of the existing subscription
  l_guid := Find_Subscription(x_subscription_guid => l_subscription_guid,
                              x_system_guid       => l_system_guid,
                              x_source_type       => l_source_type,
                              x_source_agent_guid => l_source_agent_guid,
                              x_event_filter_guid => l_event_filter_guid,
                              x_phase             => l_phase,
                              x_rule_data         => l_rule_data,
                              x_priority          => l_priority,
                              x_rule_function     => l_rule_function,
                              x_wf_process_type   => l_wf_process_type,
                              x_wf_process_name   => l_wf_process_name,
                              x_parameters        => l_parameters,
                              x_owner_name        => l_owner_name,
                              x_owner_tag         => l_owner_tag);

  wf_event_subscriptions_pkg.load_row(
      X_GUID               => l_guid,
      X_SYSTEM_GUID        => l_system_guid,
      X_SOURCE_TYPE        => l_source_type,
      X_SOURCE_AGENT_GUID  => l_source_agent_guid,
      X_EVENT_FILTER_GUID  => l_event_filter_guid,
      X_PHASE              => l_phase,
      X_STATUS             => l_status,
      X_RULE_DATA          => l_rule_data,
      X_OUT_AGENT_GUID     => l_out_agent_guid,
      X_TO_AGENT_GUID      => l_to_agent_guid,
      X_PRIORITY           => l_priority,
      X_RULE_FUNCTION      => l_rule_function,
      X_WF_PROCESS_TYPE    => l_wf_process_type,
      X_WF_PROCESS_NAME    => l_wf_process_name,
      X_PARAMETERS         => l_parameters,
      X_OWNER_NAME         => l_owner_name,
      X_OWNER_TAG          => l_owner_tag,
      X_CUSTOMIZATION_LEVEL => l_customization_level,
      X_LICENSED_FLAG       => l_licensed_flag,
      X_DESCRIPTION        => l_description,
      X_EXPRESSION         => l_expression,
      X_ACTION_CODE        => l_actioncode,
      X_ON_ERROR_CODE      => l_onerror ,
      X_JAVA_RULE_FUNC     => l_javarulefunc,
      X_STANDARD_CODE      => l_standardcode,
      X_STANDARD_TYPE      => l_standardtype
    );

exception
  when others then
    wf_core.context('Wf_Events_Subscriptions_Pkg', 'Receive', x_message);
    raise;
end RECEIVE;
-----------------------------------------------------------------------------
procedure validate_subscription (X_EVENT_FILTER_GUID in raw,
				 X_CUSTOMIZATION_LEVEL in varchar2,
                                 X_STATUS in varchar2)  -- Bug 2756800
is

 cursor c_geteventcustom is
   select customization_level
    from wf_events
   where guid = X_EVENT_FILTER_GUID;

 l_custom_level varchar2(1);
 l_trns1 varchar2(4000);
 l_trns2 varchar2(4000);
 e_invalid_sub exception;
begin

  for v_getcustom in c_geteventcustom loop
	l_custom_level := v_getcustom.customization_level;
  end loop;

  -- Subscription Validity Matrix

  if X_CUSTOMIZATION_LEVEL in ('C', 'L') then
	if l_custom_level in ('X', 'U') then
		raise e_invalid_sub;
	end if;
	if X_CUSTOMIZATION_LEVEL = 'C' and l_custom_level = 'L' and
           X_STATUS <> 'DISABLED' 		-- Bug 2756800
	then
		raise e_invalid_sub;
	end if;
  elsif X_CUSTOMIZATION_LEVEL = 'X' then
	if l_custom_level = 'U' then
		raise e_invalid_sub;
	end if;
  end if;
exception
when e_invalid_sub then
	l_trns1 := wf_core.translate('WFE_CUSTOM_LEVEL_' || X_CUSTOMIZATION_LEVEL);
	l_trns2 := wf_core.translate('WFE_CUSTOM_LEVEL_' || l_custom_level);
	wf_core.token('SUB_CUSTOM_LEVEL', l_trns1);
	wf_core.token('EVT_CUSTOM_LEVEL', l_trns2);
    	wf_core.raise('WFE_INVALID_SUBSCRIPTION');
end validate_subscription;

procedure fetch_custom_level(X_GUID in raw,
			     X_CUSTOMIZATION_LEVEL out nocopy varchar2)
is
  cursor c_getCustomLevel is
  select CUSTOMIZATION_LEVEL from
  WF_EVENT_SUBSCRIPTIONS
  where guid = X_GUID;

 l_found varchar2(1) := 'N';
begin
  for v_customlevel in c_getCustomLevel loop
	X_CUSTOMIZATION_LEVEL := v_customlevel.customization_level;
	l_found := 'Y';
  end loop;

  if l_found = 'N' then
	-- The subscription was not found...
	raise no_data_found;
  end if;

end fetch_custom_level;

-- Find_Subscription
--   Function to check if there is a duplicate subscription. The logic in this procedure
--   is moved from Receive procedure to be used from Insert_Row and Update_Row
function Find_Subscription(x_subscription_guid in varchar2,
                           x_system_guid       in raw,
                           x_source_type       in varchar2,
                           x_source_agent_guid in raw,
                           x_event_filter_guid in raw,
                           x_phase             in number,
                           x_rule_data         in varchar2,
                           x_priority          in number,
                           x_rule_function     in varchar2,
                           x_wf_process_type   in varchar2,
                           x_wf_process_name   in varchar2,
                           x_parameters        in varchar2,
                           x_owner_name        in varchar2,
                           x_owner_tag         in varchar2)
return raw
is
  -- Identical Row Cursor
  -- A row is considered identical if it for the same system same event,
  -- same source type, same phase, same owner name same owner tag. We also
  -- need to take care of cases where both values are null.

  CURSOR identical_row1 IS
  SELECT guid
  FROM   wf_event_subscriptions
  WHERE  system_guid = x_system_guid
  AND    source_type = x_source_type
  AND    event_filter_guid = x_event_filter_guid
  AND    (((source_agent_guid is null) AND (x_source_agent_guid is null))
         OR source_agent_guid = x_source_agent_guid)
  AND    (((phase is null) AND (x_phase is null))
         OR phase = x_phase)
  AND    (((owner_name is null) AND (x_owner_name is null))
         OR owner_name = x_owner_name)
  AND    (((owner_tag is null) AND (x_owner_tag is null))
         OR owner_tag = x_owner_tag);

  CURSOR identical_row2 IS
  SELECT guid
  FROM   wf_event_subscriptions
  WHERE  system_guid = x_system_guid
  AND    source_type = x_source_type
  AND    event_filter_guid = x_event_filter_guid
  AND    (phase is null OR phase = x_phase)
  AND    owner_name is null
  AND    owner_tag is null
  AND    rule_data = x_rule_data
  AND    priority = x_priority
  AND    (((rule_function is null) AND (x_rule_function is null))
         OR rule_function = x_rule_function)
  AND    (((wf_process_type is null) AND (x_wf_process_type is null))
         OR wf_process_type = x_wf_process_type)
  AND    (((wf_process_name is null) AND (x_wf_process_name is null))
         OR wf_process_name = x_wf_process_name)
  AND    (((parameters is null) AND (x_parameters is null))
         OR parameters = x_parameters);

  l_guid raw(16);
begin
    -- A row is considered identical if it for the same system
    -- same event, same source type, same phase, same owner name
    -- same owner tag

    open identical_row1;
    fetch identical_row1 into l_guid;
    if (identical_row1%notfound) then
      -- An additional check in case the original row did not have the phase
      -- and/or owner name and owner tag fields defined
      -- Note: identical_row2 will not return any rows if only ONE
      -- of the 2 columns owner_name, owner_tag is null and the files contains
      -- a not null values

      open identical_row2;
      fetch identical_row2 into l_guid;
      if (identical_row2%notfound) then
        if (x_subscription_guid = '#NEW') then
          l_guid := sys_guid();
        else
          l_guid := x_subscription_guid;
        end if;
      end if;
      close identical_row2;
    end if;
    close identical_row1;
    return l_guid;
end Find_Subscription;

end WF_EVENT_SUBSCRIPTIONS_PKG;

/
