--------------------------------------------------------
--  DDL for Package Body PER_DRT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DRT_SWI" as
/* $Header: pedrtswi.pkb 120.0.12010000.4 2019/04/05 10:09:34 pkgandi noship $ */

-- Package Variables
--
g_package  varchar2(33) := '  PER_DRT_SWI.';
g_debug boolean := hr_utility.debug_enabled;

procedure insert_tables_details
  (p_product_code								in varchar2
  ,p_schema											in varchar2
  ,p_table_name            			in varchar2
  ,p_table_phase			        	in number default '100'
  ,p_record_identifier					in varchar2 default null
  ,p_entity_type                in varchar2 default null
  ,p_table_id                   in out nocopy number
  ,p_return_status              out nocopy varchar2
  ) is
l_proc    										varchar2(72);
begin
  if g_debug then
	l_proc := g_package||'insert_tables_details';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

 savepoint insert_tables_details_sp;

 hr_multi_message.enable_message_list;

 if g_debug then
	hr_utility.set_location('Multi Message Enabled:'|| l_proc, 20);
  end if;

 PER_DRT_API.insert_tables_details
  (p_product_code	=> p_product_code
  ,p_schema		=> p_schema
  ,p_table_name => p_table_name
  ,p_table_phase	=> p_table_phase
  ,p_record_identifier	=> p_record_identifier
  ,p_entity_type => p_entity_type
  ,p_table_id => p_table_id
 );

 if g_debug then
	hr_utility.set_location('After API call'|| l_proc, 30);
  end if;
 p_return_status := hr_multi_message.get_return_status_disable;
 hr_utility.trace(p_return_status);
 hr_utility.set_location(' Leaving:' || l_proc, 40);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to insert_tables_details_sp;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc, 50);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to insert_tables_details_sp;
    --
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,60);
       raise;
    end if;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc,70);
    --

end insert_tables_details;

procedure insert_columns_details
  (p_table_id                  	in number
	,p_column_name								in varchar2
  ,p_column_phase            		in number	default '1'
  ,p_attribute			    				in varchar2 default null
  ,p_ff_type             				in varchar2 default 'NONE'
  ,p_rule_type                  in varchar2 default null
  ,p_parameter_1								in varchar2 default null
  ,p_parameter_2            		in varchar2 default null
  ,p_comments			            	in varchar2 default null
  ,p_column_id                  in out nocopy number
  ,p_return_status              out nocopy varchar2
 ) is
l_proc    										varchar2(72);
begin
  if g_debug then
	l_proc := g_package||'insert_columns_details';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

 savepoint insert_columns_details_sp;

 hr_multi_message.enable_message_list;

 if g_debug then
	hr_utility.set_location('Multi Message Enabled:'|| l_proc, 20);
  end if;

 PER_DRT_API.insert_columns_details
  (p_table_id => p_table_id
	,p_column_name => p_column_name
  ,p_column_phase => p_column_phase
  ,p_attribute	=> p_attribute
  ,p_ff_type  => p_ff_type
  ,p_rule_type => p_rule_type
  ,p_parameter_1 => p_parameter_1
  ,p_parameter_2 => p_parameter_2
  ,p_comments	=> p_comments
  ,p_column_id => p_column_id
 );
 if g_debug then
	hr_utility.set_location('After API call'|| l_proc, 30);
  end if;
p_return_status := hr_multi_message.get_return_status_disable;
 hr_utility.trace(p_return_status);
 hr_utility.set_location(' Leaving:' || l_proc, 40);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to insert_columns_details_sp;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc, 50);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to insert_columns_details_sp;
    --
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,60);
       raise;
    end if;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc,70);
    --

end insert_columns_details;

procedure insert_col_contexts_details
  (p_column_id                  in number
  ,p_ff_name             				in varchar2
  ,p_context_name             	in varchar2
	,p_column_name								in varchar2
  ,p_column_phase            		in number
  ,p_attribute			    				in varchar2 default null
  ,p_rule_type                  in varchar2	default null
  ,p_parameter_1								in varchar2	default null
  ,p_parameter_2            		in varchar2	default null
  ,p_comments			            	in varchar2	default null
  ,p_ff_column_id              	in out nocopy number
  ,p_return_status              out nocopy varchar2
 )is
l_proc    										varchar2(72);
begin
  if g_debug then
	l_proc := g_package||'insert_col_contexts_details';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

 savepoint insert_col_contexts_details_sp;

 hr_multi_message.enable_message_list;

 if g_debug then
	hr_utility.set_location('Multi Message Enabled:'|| l_proc, 20);
  end if;

 PER_DRT_API.insert_col_contexts_details
  (p_column_id  => p_column_id
  ,p_ff_name  => p_ff_name
  ,p_context_name  => p_context_name
	,p_column_name	 => p_column_name
  ,p_column_phase  => p_column_phase
  ,p_attribute	 => p_attribute
  ,p_rule_type  => p_rule_type
  ,p_parameter_1	 => p_parameter_1
  ,p_parameter_2  => p_parameter_2
  ,p_comments		 => p_comments
  ,p_ff_column_id  => p_ff_column_id
  );
 if g_debug then
	hr_utility.set_location('After API call'|| l_proc, 30);
  end if;
p_return_status := hr_multi_message.get_return_status_disable;
 hr_utility.trace(p_return_status);
 hr_utility.set_location(' Leaving:' || l_proc, 40);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to insert_col_contexts_details_sp;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc, 50);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to insert_col_contexts_details_sp;
    --
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,60);
       raise;
    end if;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc,70);
END insert_col_contexts_details;


procedure update_tables_details
  (p_table_id										in number
	,p_product_code								in varchar2
  ,p_schema											in varchar2
  ,p_table_name            			in varchar2
  ,p_table_phase			        	in number default '100'
  ,p_record_identifier					in varchar2	default hr_api.g_varchar2
  ,p_entity_type                in varchar2	default hr_api.g_varchar2
  ,p_return_status              out nocopy varchar2
  )is
l_proc    										varchar2(72);
begin
  if g_debug then
	l_proc := g_package||'update_tables_details';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

 savepoint update_tables_details_sp;

 hr_multi_message.enable_message_list;

 if g_debug then
	hr_utility.set_location('Multi Message Enabled:'|| l_proc, 20);
  end if;

 PER_DRT_API.update_tables_details
  (p_table_id => p_table_id
  ,p_product_code	=> p_product_code
  ,p_schema		=> p_schema
  ,p_table_name => p_table_name
  ,p_table_phase	=> p_table_phase
  ,p_record_identifier	=> p_record_identifier
  ,p_entity_type => p_entity_type
 );

 if g_debug then
	hr_utility.set_location('After API call'|| l_proc, 30);
  end if;
 p_return_status := hr_multi_message.get_return_status_disable;
 hr_utility.trace(p_return_status);
 hr_utility.set_location(' Leaving:' || l_proc, 40);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_tables_details_sp;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc, 50);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_tables_details_sp;
    --
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,60);
       raise;
    end if;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc,70);
    --

end update_tables_details;

procedure update_columns_details
  (p_column_id						in number
	,p_table_id							in number
  ,p_column_name					in varchar2
  ,p_column_phase					in number	default '1'
  ,p_attribute			    	in varchar2 default hr_api.g_varchar2
  ,p_ff_type             	in varchar2 default 'NONE'
  ,p_rule_type            in varchar2 default hr_api.g_varchar2
  ,p_parameter_1					in varchar2 default hr_api.g_varchar2
  ,p_parameter_2          in varchar2 default hr_api.g_varchar2
  ,p_comments			        in varchar2 default hr_api.g_varchar2
  ,p_return_status              out nocopy varchar2
  )is
l_proc    										varchar2(72);
begin
  if g_debug then
	l_proc := g_package||'update_columns_details';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

 savepoint update_columns_details_sp;

 hr_multi_message.enable_message_list;

 if g_debug then
	hr_utility.set_location('Multi Message Enabled:'|| l_proc, 20);
  end if;

 PER_DRT_API.update_columns_details
  (p_column_id	=> p_column_id
	,p_table_id	=> p_table_id
  ,p_column_name => p_column_name
  ,p_column_phase	=> p_column_phase
  ,p_attribute	=> p_attribute
  ,p_ff_type  => p_ff_type
  ,p_rule_type  => p_rule_type
  ,p_parameter_1=> p_parameter_1
  ,p_parameter_2 => p_parameter_2
  ,p_comments	=> p_comments
  );

 if g_debug then
	hr_utility.set_location('After API call'|| l_proc, 30);
  end if;
 p_return_status := hr_multi_message.get_return_status_disable;
 hr_utility.trace(p_return_status);
 hr_utility.set_location(' Leaving:' || l_proc, 40);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_columns_details_sp;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc, 50);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_columns_details_sp;
    --
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,60);
       raise;
    end if;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc,70);
    --

end update_columns_details;




procedure update_col_contexts_details
  (p_ff_column_id					in number
	,p_column_id						in number
  ,p_ff_name             	in varchar2
  ,p_context_name         in varchar2
  ,p_column_name					in varchar2
  ,p_column_phase					in number
  ,p_attribute			    	in varchar2 default hr_api.g_varchar2
  ,p_rule_type            in varchar2	default hr_api.g_varchar2
  ,p_parameter_1					in varchar2	default hr_api.g_varchar2
  ,p_parameter_2          in varchar2	default hr_api.g_varchar2
  ,p_comments			        in varchar2	default hr_api.g_varchar2
  ,p_return_status              out nocopy varchar2
  )is
l_proc    										varchar2(72);
begin
  if g_debug then
	l_proc := g_package||'update_col_contexts_details';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

 savepoint update_col_contexts_details_sp;

 hr_multi_message.enable_message_list;

 if g_debug then
	hr_utility.set_location('Multi Message Enabled:'|| l_proc, 20);
  end if;

 PER_DRT_API.update_col_contexts_details
  (p_ff_column_id => p_ff_column_id
	,p_column_id	=> p_column_id
  ,p_ff_name          => p_ff_name
  ,p_context_name  => p_context_name
  ,p_column_name => p_column_name
  ,p_column_phase => p_column_phase
  ,p_attribute	=> p_attribute
  ,p_rule_type  => p_rule_type
  ,p_parameter_1	=> p_parameter_1
  ,p_parameter_2 => p_parameter_2
  ,p_comments		=> p_comments
  );

 if g_debug then
	hr_utility.set_location('After API call'|| l_proc, 30);
  end if;
 p_return_status := hr_multi_message.get_return_status_disable;
 hr_utility.trace(p_return_status);
 hr_utility.set_location(' Leaving:' || l_proc, 40);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_col_contexts_details_sp;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc, 50);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_col_contexts_details_sp;
    --
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,60);
       raise;
    end if;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc,70);
    --

end update_col_contexts_details;

procedure delete_drt_details
  (p_table_id					           in 		number default null
	,p_column_id					         in 		number default null
	,p_ff_column_id					       in 		number default null
  ,p_return_status              out nocopy varchar2
  ) is
l_proc    										varchar2(72);
begin
  if g_debug then
	l_proc := g_package||'delete_drt_details';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

 savepoint delete_drt_details_sp;

 hr_multi_message.enable_message_list;

 if g_debug then
	hr_utility.set_location('Multi Message Enabled:'|| l_proc, 20);
  end if;

 PER_DRT_API.delete_drt_details
  (p_table_id	=> p_table_id
	,p_column_id => p_column_id
	,p_ff_column_id		=> p_ff_column_id
  );

 if g_debug then
	hr_utility.set_location('After API call'|| l_proc, 30);
  end if;
 p_return_status := hr_multi_message.get_return_status_disable;
 hr_utility.trace(p_return_status);
 hr_utility.set_location(' Leaving:' || l_proc, 40);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_drt_details_sp;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc, 50);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_drt_details_sp;
    --
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,60);
       raise;
    end if;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    --
    hr_utility.set_location(' Leaving:' || l_proc,70);
    --

end delete_drt_details;


function getTableName(p_table_id in NUMBER
) return VARCHAR2 is
l_tblName varchar2(100) := null;
l_return varchar2(100) := null;
cursor get_table is
  select table_name from per_drt_tables where table_id = p_table_id;
BEGIN
   open get_table;
      FETCH get_table into l_tblName;
        IF get_table%FOUND THEN
          l_return := l_tblName;
        END IF;
   close get_table;
 return l_return;
END getTableName;


Procedure getColumnDetails(p_tableName in varchar2, p_schema in varchar2,
                           p_colName in varchar2, p_dt  out nocopy varchar2,
              p_na  out nocopy varchar2, p_ffTye out nocopy varchar2, p_ffName out nocopy varchar2) is
cursor c_details is
	SELECT  decode (data_type
               ,'VARCHAR2'
               ,'VARCHAR2('
                || data_length
                || ')'
               ,'NUMBER'
               ,'NUMBER('
                || to_char (data_precision)
                || nvl2 (data_scale
                        ,','
                         || data_scale
                        ,NULL)
                || ')'
               ,data_type) data_type
       ,nullable
       ,getflexfieldname (table_name
                                        ,column_name) flex_field_name
       ,getflexfieldtype (table_name
                                         ,column_name) flex_field_type
	FROM    all_tab_columns
	WHERE   table_name =p_tableName
    AND column_name = p_colName
	AND owner = p_schema;
	BEGIN
  open c_details;
    fetch c_details into p_dt,p_na,p_ffName,p_ffTye;
  close c_details;
end getColumnDetails;


function getdataType(p_tableId in Number,
                          p_colName in VARCHAR2
) return VARCHAR2
is
 l_schema varchar2(10) := null;
 l_tableName varchar2(100) := null;
 l_dt varchar2(100) := null;
 l_nullable varchar2(1) := null;
 l_return varchar2(100) := null;
cursor getTableName is
   select schema, table_name from per_drt_tables
   where table_id = p_tableId;

cursor getDataType is
SELECT  decode (DATA_TYPE
               ,'VARCHAR2'
               ,'VARCHAR2('
                || DATA_LENGTH
                || ')'
               ,'NUMBER'
               ,'NUMBER('
                || to_char (DATA_PRECISION)
                || nvl2 (DATA_SCALE
                        ,','
                         || DATA_SCALE
                        ,NULL)
                || ')'
               ,DATA_TYPE) data_type,
         nullable
FROM    all_tab_columns
where table_name = l_tableName
AND column_name = p_colName
AND owner = l_schema;
begin
  open getTableName;
     fetch getTableName into l_schema, l_tableName;
  close getTableName;
 open getDataType;
   fetch getDataType into l_dt, l_nullable;
    IF getDataType%FOUND THEN
      l_return := l_dt;
    END IF;
  close getDataType;

  return l_dt;
end getdataType;

function getnullable(p_tableId in Number,
                          p_colName in VARCHAR2
) return VARCHAR2 is
 l_schema varchar2(10) := null;
 l_dt varchar2(100) := null;
 l_nullable varchar2(1) := null;
 l_return varchar2(1) := null;
 l_tableName varchar2(100) := null;
cursor getTableName is
   select schema,table_name from per_drt_tables
   where table_id = p_tableId;

cursor getDataType is
SELECT  decode (DATA_TYPE
               ,'VARCHAR2'
               ,'VARCHAR2('
                || DATA_LENGTH
                || ')'
               ,'NUMBER'
               ,'NUMBER('
                || to_char (DATA_PRECISION)
                || nvl2 (DATA_SCALE
                        ,','
                         || DATA_SCALE
                        ,NULL)
                || ')'
               ,DATA_TYPE) data_type,
         nullable
FROM    all_tab_columns
where table_name = l_tableName
AND column_name = p_colName
AND owner= l_schema;
begin
 open getTableName;
     fetch getTableName into l_schema,l_tableName;
  close getTableName;
 open getDataType;
   fetch getDataType into l_dt, l_nullable;
     IF getDataType%FOUND THEN
      l_return := l_nullable;
    END IF;
  close getDataType;

  return l_nullable;

end getnullable;

function getFlexFieldType(p_tableName in VARCHAR2,
                          p_colName in VARCHAR2
) return VARCHAR2 is

 l_fftype varchar2(7) := 'NONE';
 l_ff_name  VARCHAR2(30);
 	cursor get_kff is
   SELECT distinct(FLEXFIELD_NAME) from per_drt_kffs
   WHERE APPLICATION_TABLE_NAME = p_tableName
   AND   APPLICATION_COLUMN_NAME = p_colName;

  cursor get_dff is
   SELECT distinct(FLEXFIELD_NAME) from per_drt_dffs
   WHERE APPLICATION_TABLE_NAME = p_tableName
   AND   APPLICATION_COLUMN_NAME = p_colName;

BEGIN

   open get_kff;
  	FETCH get_kff into l_ff_name;
			IF get_kff%FOUND THEN
    			l_fftype := 'KFF';
	 		END IF;
		close get_kff;

     open get_dff;
  			FETCH get_dff into l_ff_name;
       		 IF get_dff%FOUND THEN
             IF (INSTR(p_colName,'ATTRIBUTE')>0) THEN
        		 l_fftype := 'DFF';
             ELSE
             l_fftype := 'DDF';
             END IF;
        END IF;
     close get_dff;

 return l_fftype;
END getFlexFieldType;

function getFlexFieldName(p_tableName in VARCHAR2,
                          p_colName in VARCHAR2
) return VARCHAR2 is
 l_ffName VARCHAR2(30) := null;
 return_ff_name  VARCHAR2(30);
 cursor get_kff is
   SELECT distinct(FLEXFIELD_NAME) from per_drt_kffs
   WHERE APPLICATION_TABLE_NAME = p_tableName
   AND   APPLICATION_COLUMN_NAME = p_colName;

 cursor get_dff is
   SELECT distinct(FLEXFIELD_NAME) from per_drt_dffs
   WHERE APPLICATION_TABLE_NAME = p_tableName
   AND   APPLICATION_COLUMN_NAME = p_colName;

BEGIN
  IF(INSTR(p_colName,'SEGMENT')>0) THEN
     open get_kff;
      FETCH get_kff into  l_ffName;
        IF get_kff%FOUND THEN
         return_ff_name := l_ffName;
        END IF;
     close get_kff;

  ELSE
    open get_dff;
      FETCH get_dff into  l_ffName;
        IF get_dff%FOUND THEN
         return_ff_name := l_ffName;
        END IF;
     close get_dff;
  END IF;

return return_ff_name;
END getFlexFieldName;


function getTableNameForFlex(p_col_id in NUMBER
) return VARCHAR2 is
l_tblName varchar2(100) := null;
l_return varchar2(100) := null;
cursor get_table is
  select table_name from per_drt_tables tab ,per_drt_columns col
  where tab.table_id = col.table_id and
  col.column_id = p_col_id;
BEGIN
   open get_table;
      FETCH get_table into l_tblName;
        IF get_table%FOUND THEN
          l_return := l_tblName;
        END IF;
   close get_table;
 return l_return;
END getTableNameForFlex;

procedure getFlexColumnForValidation(p_ffType in varchar2,
                                    p_flexName in varchar2,
                                    p_contextCode in varchar2,
                                    p_contextColName out nocopy varchar2,
                                    p_kffFlexNum out nocopy varchar2) is
l_contextColName varchar2(200) := null;
l_return varchar2(200) := null;
l_kffFlexNum varchar2(200) := null;
l_flexName varchar2(200) :=  UPPER(p_flexName);
cursor getKFFColumn is
  select context_column_name from per_drt_kffs
  where UPPER(flexfield_name) = l_flexName and context_code = UPPER(p_contextCode);
cursor getDFFColumn is
  select context_column_name from per_drt_dffs
  where UPPER(flexfield_name) = l_flexName and context_code = UPPER(p_contextCode) and rownum=1;
cursor getFlexNum is
  SELECT  ID_FLEX_NUM FROM  fnd_id_flex_structures_tl
  WHERE   language = userenv ('lang')
  AND     id_flex_structure_name IN
        (
        SELECT  DISTINCT
                context_name
        FROM    per_drt_kffs
        WHERE   UPPER(flexfield_name) = l_flexName
        AND     context_code = p_contextCode
        )
 AND     rownum = 1;
BEGIN
  IF(p_ffType = 'DFF' OR p_ffType = 'DDF') THEN
    open getDFFColumn;
       FETCH getDFFColumn into l_contextColName;
        IF getDFFColumn%FOUND THEN
          p_contextColName := l_contextColName;
        END IF;
   close getDFFColumn;
  END IF;

 IF(p_ffType = 'KFF') THEN
    open getKFFColumn;
       FETCH getKFFColumn into l_contextColName;
        IF getKFFColumn%FOUND THEN
          p_contextColName := l_contextColName;
        END IF;
    open getFlexNum;
       FETCH getFlexNum into l_kffFlexNum;
        IF getFlexNum%FOUND THEN
          p_kffFlexNum := l_contextColName;
        END IF;
   close getFlexNum;

  END IF;
end getFlexColumnForValidation;
END PER_DRT_SWI;


/
