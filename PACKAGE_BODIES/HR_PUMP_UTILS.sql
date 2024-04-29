--------------------------------------------------------
--  DDL for Package Body HR_PUMP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PUMP_UTILS" as
/* $Header: hrdputil.pkb 120.1 2006/01/11 08:25:50 arashid noship $ */
/*
  NOTES
    The user is referred to the header for details of any
    functions and procedures defined here.
*/
/*---------------------------------------------------------------------------*/
/*----------------------- constant definitions ------------------------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*--------------- internal Data Pump utility data structures ----------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*------------------------ Data Pump utility globals ------------------------*/
/*---------------------------------------------------------------------------*/
--
-- Is the current session is running Data Pump ?
--
g_current_session_running boolean := false;
--
-- Is Date-Track foreign key locking enforced ?
--
g_enforce_dt_foreign_locks boolean := true;
--
-- Are there multi-message utility errors ?
--
g_multi_msg_error boolean := false;
/*---------------------------------------------------------------------------*/
/*------------------ local functions and procedures -------------------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*------------------ global functions and procedures ------------------------*/
/*---------------------------------------------------------------------------*/

function create_batch_header
(
   p_batch_name          in varchar2,
   p_business_group_name in varchar2  default null,
   p_reference           in varchar2  default null,
   p_atomic_linked_calls in varchar2  default 'N'
) return number is
   l_batch_id number;
begin
   -- Get the batch_id to allow return from function.
   select hr_pump_batch_headers_s.nextval
   into   l_batch_id
   from   sys.dual;

   -- Straight-forward insert statement
   -- We don't look for an existing batch.
   insert  into hr_pump_batch_headers (
           batch_id,
           batch_name,
           batch_status,
           reference,
           business_group_name,
           atomic_linked_calls)
   values (l_batch_id,
           p_batch_name,
           'U',
           p_reference,
           p_business_group_name,
           upper(p_atomic_linked_calls));

   return(l_batch_id);

end create_batch_header;

procedure add_user_key
(
   p_user_key_value in varchar2,
   p_unique_key_id  in number
) is
begin
   -- Check arguments for validity.
   if ( p_user_key_value is null or p_unique_key_id is null ) then
      raise value_error;
   end if;

   -- Insert the values.
   insert  into hr_pump_batch_line_user_keys (
           user_key_id,
           batch_line_id,
           user_key_value,
           unique_key_id)
   values (hr_pump_batch_line_user_keys_s.nextval,
           null,
           p_user_key_value,
           p_unique_key_id);
end add_user_key;

procedure modify_user_key
(
   p_user_key_value     in varchar2,
   p_new_user_key_value in varchar2,
   p_unique_key_id      in number
) is
   l_user_key_value hr_pump_batch_line_user_keys.user_key_value%type;
   l_unique_key_id  hr_pump_batch_line_user_keys.unique_key_id%type;
begin
   -- Check input values.
   if ( p_user_key_value is null ) then
      raise value_error;
   end if;

   -- Get the current user key row.
   select user_key_value, unique_key_id
   into   l_user_key_value,
          l_unique_key_id
   from   hr_pump_batch_line_user_keys
   where  user_key_value = p_user_key_value;

   -- Update the row.
   update hr_pump_batch_line_user_keys
   set    user_key_value = nvl(p_new_user_key_value, l_user_key_value),
          unique_key_id = nvl(p_unique_key_id, l_unique_key_id)
   where  user_key_value = p_user_key_value;
end modify_user_key;

procedure name( p_module_package in  varchar2,
                p_module_name    in  varchar2,
                p_package_name   out nocopy varchar2,
                p_view_name      out nocopy varchar2 )
is
begin
  -- Very simple name generation. Names restricted to Oracle limit
  -- of 30 bytes.
  p_package_name := substrb( 'hrdpp_' || p_module_name, 1, 30 );
  p_view_name    := substrb( 'hrdpv_' || p_module_name, 1, 30 );
end name;

-------------------------------- SEED_ZAP -------------------------------------
PROCEDURE SEED_ZAP
(P_MODULE_NAME     IN     VARCHAR2
,P_API_MODULE_TYPE IN     VARCHAR2
) IS
  L_MODULE_NAME     VARCHAR2(128);
  L_API_MODULE_TYPE VARCHAR2(128);
BEGIN
  L_MODULE_NAME     := UPPER(P_MODULE_NAME);
  L_API_MODULE_TYPE := UPPER(P_API_MODULE_TYPE);
  --
  -- Delete from the data pump tables.
  --
  DELETE
  FROM   HR_PUMP_MODULE_PARAMETERS
  WHERE  UPPER(MODULE_NAME) = L_MODULE_NAME
  AND    UPPER(API_MODULE_TYPE) = L_API_MODULE_TYPE;
  --
  DELETE
  FROM   HR_PUMP_DEFAULT_EXCEPTIONS
  WHERE  UPPER(MODULE_NAME) = L_MODULE_NAME
  AND    UPPER(API_MODULE_TYPE) = L_API_MODULE_TYPE;
  --
  DELETE
  FROM   HR_PUMP_MAPPING_PACKAGES
  WHERE  UPPER(MODULE_NAME) = L_MODULE_NAME
  AND    UPPER(API_MODULE_TYPE) = L_API_MODULE_TYPE;
  --
END SEED_ZAP;

-------------------------------- SEED_API -------------------------------------
PROCEDURE SEED_API
(P_MODULE_NAME                IN     VARCHAR2
,P_API_MODULE_TYPE            IN     VARCHAR2
,P_MODULE_PACKAGE             IN     VARCHAR2
,P_DATA_WITHIN_BUSINESS_GROUP IN     VARCHAR2 DEFAULT 'Y'
,P_LEGISLATION_CODE           IN     VARCHAR2 DEFAULT NULL
) IS
  L_API_MODULE_ID              NUMBER;
  L_MODULE_NAME                VARCHAR2(128);
  L_API_MODULE_TYPE            VARCHAR2(128);
  L_MODULE_PACKAGE             VARCHAR2(128);
  L_DATA_WITHIN_BUSINESS_GROUP VARCHAR2(128);
  L_LEGISLATION_CODE           VARCHAR2(128);
  --
  CURSOR CSR_API_MODULE_ID
  (P_MODULE_NAME     IN VARCHAR2
  ,P_API_MODULE_TYPE IN VARCHAR2
  ) IS
  SELECT API_MODULE_ID
  FROM   HR_API_MODULES
  WHERE  UPPER(MODULE_NAME)     = P_MODULE_NAME
  AND    UPPER(API_MODULE_TYPE) = P_API_MODULE_TYPE;
BEGIN
  L_MODULE_NAME                := UPPER(P_MODULE_NAME);
  L_API_MODULE_TYPE            := UPPER(P_API_MODULE_TYPE);
  L_MODULE_PACKAGE             := UPPER(P_MODULE_PACKAGE);
  L_DATA_WITHIN_BUSINESS_GROUP := UPPER(P_DATA_WITHIN_BUSINESS_GROUP);
  L_LEGISLATION_CODE           := UPPER(P_LEGISLATION_CODE);
  --
  -- Get the API_MODULE_ID.
  --
  OPEN CSR_API_MODULE_ID
  (P_MODULE_NAME     => L_MODULE_NAME
  ,P_API_MODULE_TYPE => L_API_MODULE_TYPE
  );
  FETCH CSR_API_MODULE_ID
  INTO  L_API_MODULE_ID;
  --
  -- Call the appropriate API depending on whether or not a row in
  -- HR_API_MODULES exists.
  --
  IF CSR_API_MODULE_ID%NOTFOUND THEN
    CLOSE CSR_API_MODULE_ID;
    HR_API_MODULE_INTERNAL.CREATE_API_MODULE
    (P_VALIDATE                   => FALSE
    ,P_EFFECTIVE_DATE             => HR_API.G_SYS
    ,P_API_MODULE_TYPE            => L_API_MODULE_TYPE
    ,P_MODULE_NAME                => L_MODULE_NAME
    ,P_DATA_WITHIN_BUSINESS_GROUP => L_DATA_WITHIN_BUSINESS_GROUP
    ,P_LEGISLATION_CODE           => L_LEGISLATION_CODE
    ,P_MODULE_PACKAGE             => L_MODULE_PACKAGE
    ,P_API_MODULE_ID              => L_API_MODULE_ID
    );
  ELSE
    CLOSE CSR_API_MODULE_ID;
    HR_API_MODULE_INTERNAL.UPDATE_API_MODULE
    (P_VALIDATE                   => FALSE
    ,P_API_MODULE_ID              => L_API_MODULE_ID
    ,P_MODULE_NAME                => L_MODULE_NAME
    ,P_MODULE_PACKAGE             => L_MODULE_PACKAGE
    ,P_DATA_WITHIN_BUSINESS_GROUP => L_DATA_WITHIN_BUSINESS_GROUP
    ,P_EFFECTIVE_DATE             => HR_API.G_SYS
    );
  END IF;
END SEED_API;

--------------------------- SEED_DFLT_EXC -------------------------------------
PROCEDURE SEED_DFLT_EXC
(P_MODULE_NAME     IN     VARCHAR2
,P_API_MODULE_TYPE IN     VARCHAR2
) IS
  L_MODULE_NAME     VARCHAR2(128);
  L_API_MODULE_TYPE VARCHAR2(128);
BEGIN
  L_MODULE_NAME     := UPPER(P_MODULE_NAME);
  L_API_MODULE_TYPE := UPPER(P_API_MODULE_TYPE);
  --
  DELETE
  FROM   HR_PUMP_DEFAULT_EXCEPTIONS
  WHERE  UPPER(MODULE_NAME) = L_MODULE_NAME
  AND    UPPER(API_MODULE_TYPE) = L_API_MODULE_TYPE;
  --
  INSERT
  INTO HR_PUMP_DEFAULT_EXCEPTIONS
  (MODULE_NAME
  ,API_MODULE_TYPE
  )
  VALUES
  (L_MODULE_NAME
  ,L_API_MODULE_TYPE
  );
END SEED_DFLT_EXC;

------------------------------- SEED_PARM -------------------------------------
PROCEDURE SEED_PARM
(P_MODULE_NAME        IN     VARCHAR2
,P_API_MODULE_TYPE    IN     VARCHAR2
,P_PARAMETER_NAME     IN     VARCHAR2
,P_MAPPING_TYPE       IN     VARCHAR2 DEFAULT 'FUNCTION'
,P_MAPPING_DEFINITION IN     VARCHAR2 DEFAULT NULL
,P_DEFAULT_VALUE      IN     VARCHAR2 DEFAULT NULL
) IS
  L_MODULE_NAME        VARCHAR2(128);
  L_API_MODULE_TYPE    VARCHAR2(128);
  L_PARAMETER_NAME     VARCHAR2(128);
  L_MAPPING_TYPE       VARCHAR2(128);
  L_MAPPING_DEFINITION VARCHAR2(128);
  L_DEFAULT_VALUE      VARCHAR2(128);
BEGIN
  L_MODULE_NAME        := UPPER(P_MODULE_NAME);
  L_API_MODULE_TYPE    := UPPER(P_API_MODULE_TYPE);
  L_PARAMETER_NAME     := UPPER(P_PARAMETER_NAME);
  L_MAPPING_TYPE       := UPPER(P_MAPPING_TYPE);
  L_MAPPING_DEFINITION := UPPER(P_MAPPING_DEFINITION);
  L_DEFAULT_VALUE      := UPPER(P_DEFAULT_VALUE);
  --
  DELETE
  FROM   HR_PUMP_MODULE_PARAMETERS
  WHERE  UPPER(MODULE_NAME)     = L_MODULE_NAME
  AND    UPPER(API_MODULE_TYPE) = L_API_MODULE_TYPE
  AND    UPPER(API_PARAMETER_NAME)  = L_PARAMETER_NAME;
  --
  INSERT
  INTO   HR_PUMP_MODULE_PARAMETERS
  (MODULE_NAME
  ,API_MODULE_TYPE
  ,API_PARAMETER_NAME
  ,MAPPING_TYPE
  ,MAPPING_DEFINITION
  ,DEFAULT_VALUE
  )
  VALUES
  (L_MODULE_NAME
  ,L_API_MODULE_TYPE
  ,L_PARAMETER_NAME
  ,L_MAPPING_TYPE
  ,L_MAPPING_DEFINITION
  ,L_DEFAULT_VALUE
  );
END SEED_PARM;

------------------------------- SEED_MAP_PKGS ---------------------------------
PROCEDURE SEED_MAP_PKGS
(P_MAPPING_PACKAGE    IN     VARCHAR2
,P_MODULE_NAME        IN     VARCHAR2 DEFAULT NULL
,P_API_MODULE_TYPE    IN     VARCHAR2 DEFAULT NULL
,P_MODULE_PACKAGE     IN     VARCHAR2 DEFAULT NULL
,P_CHECKING_ORDER     IN     NUMBER
) IS
  L_MAPPING_PACKAGE VARCHAR2(128);
  L_MODULE_NAME     VARCHAR2(128);
  L_API_MODULE_TYPE VARCHAR2(128);
  L_MODULE_PACKAGE  VARCHAR2(128);
BEGIN
  L_MAPPING_PACKAGE := UPPER(P_MAPPING_PACKAGE);
  L_MODULE_NAME     := UPPER(P_MODULE_NAME);
  L_API_MODULE_TYPE := UPPER(P_API_MODULE_TYPE);
  L_MODULE_PACKAGE  := UPPER(P_MODULE_PACKAGE);
  --
  DELETE
  FROM   HR_PUMP_MAPPING_PACKAGES
  WHERE  UPPER(MAPPING_PACKAGE) = L_MAPPING_PACKAGE
  AND    NVL(UPPER(MODULE_NAME), HR_API.G_VARCHAR2)     =
         NVL(L_MODULE_NAME, HR_API.G_VARCHAR2)
  AND    NVL(UPPER(API_MODULE_TYPE), HR_API.G_VARCHAR2) =
         NVL(L_API_MODULE_TYPE, HR_API.G_VARCHAR2)
  AND    NVL(UPPER(MODULE_PACKAGE), HR_API.G_VARCHAR2)  =
         NVL(L_MODULE_PACKAGE, HR_API.G_VARCHAR2);
  --
  INSERT
  INTO   HR_PUMP_MAPPING_PACKAGES
  (MAPPING_PACKAGE
  ,MODULE_NAME
  ,API_MODULE_TYPE
  ,MODULE_PACKAGE
  ,CHECKING_ORDER
  )
  VALUES
  (L_MAPPING_PACKAGE
  ,L_MODULE_NAME
  ,L_API_MODULE_TYPE
  ,L_MODULE_PACKAGE
  ,P_CHECKING_ORDER
  );
END SEED_MAP_PKGS;

------------------------- set_current_session_running ------------------------
procedure set_current_session_running(p_running in boolean) is
begin
  g_current_session_running := p_running;
end set_current_session_running;

----------------------- set_dt_enforce_foreign_locks ------------------------
procedure set_dt_enforce_foreign_locks(p_enforce in boolean) is
begin
  g_enforce_dt_foreign_locks := p_enforce;
end set_dt_enforce_foreign_locks;

------------------------------- any_session_running --------------------------
function any_session_running return boolean is
cursor csr_data_pump_requests is
select request_id
from   hr_pump_requests
;
l_found      boolean := false;
l_ret        boolean;
l_phase      varchar2(2000);
l_status     varchar2(2000);
l_dev_phase  varchar2(2000);
l_dev_status varchar2(2000);
l_message    varchar2(2000);
begin
  if not g_current_session_running then
    for crec in csr_data_pump_requests loop
      l_ret :=
      fnd_concurrent.get_request_status
      (request_id      => crec.request_id
      ,phase           => l_phase
      ,status          => l_status
      ,dev_phase       => l_dev_phase
      ,dev_status      => l_dev_status
      ,message         => l_message
      );
      --
      -- Need to check success value of GET_REQUEST_STATUS. A dev status
      -- of RUNNING means that the request is running.
      --
      if l_ret then
        if l_dev_phase = 'RUNNING' then
          return true;
        end if;
      else
        fnd_message.raise_error;
      end if;
    end loop;
    --
    -- If the code got here then there are no Data Pump concurrent
    -- processes.
    --
    return false;
  end if;
  --
  -- The current session is running Data Pump.
  --
  return true;
end any_session_running;

--------------------------- current_session_running --------------------------
function current_session_running return boolean is
begin
  return g_current_session_running;
end current_session_running;

------------------------- dt_enforce_foreign_locks ---------------------------
function dt_enforce_foreign_locks return boolean is
l_dummy    varchar2(1);
l_enforced boolean;
cursor csr_unenforced_locks is
select null
from   pay_action_parameter_values pap
where  pap.parameter_name = 'PUMP_DT_ENFORCE_FOREIGN_LOCKS'
and    pap.parameter_value <> 'Y'
and    pap.parameter_value <> 'y'
;
begin
  --
  -- If this session is a Data Pump session then the value to use is
  -- G_ENFORCE_DT_FOREIGN_LOCKS as the choice is made when running Data Pump.
  --
  if g_current_session_running then
    l_enforced := g_enforce_dt_foreign_locks;
  --
  -- For a non-Data Pump session, check if there is a chance of a Data Pump
  -- session setting the lock action parameter.
  --
  else
    open csr_unenforced_locks;
    fetch csr_unenforced_locks into l_dummy;
    l_enforced := csr_unenforced_locks%notfound;
    close csr_unenforced_locks;
  end if;
  --
  return l_enforced;
exception
  when others then
    if csr_unenforced_locks%isopen then
      close csr_unenforced_locks;
    end if;
    raise;
end dt_enforce_foreign_locks;

--------------------------- set_multi_msg_error_flag -------------------------
procedure set_multi_msg_error_flag(p_value in boolean) is
begin
  g_multi_msg_error := p_value;
end set_multi_msg_error_flag;

--------------------------- multi_msg_errors_exist ----------------------------
function multi_msg_errors_exist return boolean is
begin
  return g_multi_msg_error;
end multi_msg_errors_exist;


-------------------------populate_spread_loaders_tab  -------------------------
procedure populate_spread_loaders_tab
(
 p_module_name               in varchar2
,p_integrator_code           in varchar2
,p_entity_name               in varchar2 default null
,p_module_mode               in varchar2
,p_entity_sql_column_name    in varchar2 default null
,p_entity_sql_column_id      in varchar2 default null
,p_entity_sql_addl_column    in varchar2 default null
,p_entity_sql_object_name    in varchar2 default null
,p_entity_sql_where_clause   in varchar2 default null
,p_entity_sql_parameters     in varchar2 default null
,p_entity_sql_order_by       in varchar2 default null
,p_integrator_parameters     in varchar2
)
is

cursor csr_get_api_module_id (p_module_name hr_pump_spread_loaders.module_name%type) is
  select api_module_id
   from  hr_api_modules
  where  module_name = p_module_name
    and  api_module_type in ('AI','BP');

cursor csr_chk_row_exists is
  select 1
   from hr_pump_spread_loaders
  where module_name       = p_module_name
    and integrator_code   = p_integrator_code
    and module_mode       = p_module_mode;

l_exists          number;
l_api_module_id   number;
l_api_module_name varchar2(200);
l_api_name        varchar2(200);
begin

if (p_module_name = 'USER_TABLE' and p_module_mode in ('I','IC')) then
   l_api_module_name :='CREATE_USER_TABLE';
   l_api_name        := 'PAY_USER_TABLE_API';
 --
elsif (p_module_name = 'USER_TABLE' and p_module_mode in ('U','UC')) then
   l_api_module_name :='UPDATE_USER_TABLE';
   l_api_name        := 'PAY_USER_TABLE_API';
 --
elsif (p_module_name = 'USER_COLUMN' and p_module_mode in ('I','IC')) then
   l_api_module_name :='CREATE_USER_COLUMN';
   l_api_name        := 'PAY_USER_COLUMN_API';
 --
elsif (p_module_name = 'USER_COLUMN' and p_module_mode in ('U','UC')) then
   l_api_module_name := 'UPDATE_USER_COLUMN';
   l_api_name        := 'PAY_USER_COLUMN_API';
 --
elsif (p_module_name = 'USER_ROWS' and p_module_mode in ('I','IC')) then
   l_api_module_name :='CREATE_USER_ROW';
   l_api_name        := 'PAY_USER_ROW_API';
 --
elsif (p_module_name = 'USER_ROWS' and p_module_mode in ('U','UC')) then
   l_api_module_name :='UPDATE_USER_ROW';
   l_api_name        := 'PAY_USER_ROW_API';
 --
elsif (p_module_name = 'USER_COLUMNS_INSTANCE' and p_module_mode in ('I','IC')) then
   l_api_module_name :='CREATE_USER_COLUMN_INSTANCE';
   l_api_name        := 'PAY_USER_COLUMN_INSTANCE_API';
 --
elsif (p_module_name = 'USER_COLUMNS_INSTANCE' and p_module_mode in ('U','UC')) then
   l_api_module_name :='UPDATE_USER_COLUMN_INSTANCE';
   l_api_name        := 'PAY_USER_COLUMN_INSTANCE_API';
 --
elsif (p_module_name = 'USER_COLUMN_INSTA_MATRIX' and p_module_mode = 'I') then
   l_api_module_name := 'CREATE_USER_COLUMN_INSTANCE';
   l_api_name        := 'PAY_USER_COLUMN_INSTANCE_API';
end if;

open csr_get_api_module_id(l_api_module_name);
fetch csr_get_api_module_id into l_api_module_id;

if (csr_get_api_module_id%notfound) then
   close csr_get_api_module_id;
   hr_utility.set_message('800','HR_33156_DP_NOT_IN_API_MODULES');
   hr_utility.set_message_token('API', l_api_name || '.' || l_api_module_name );
   hr_utility.raise_error;
end if;

close csr_get_api_module_id;

open csr_chk_row_exists;
fetch csr_chk_row_exists into l_exists;

if (csr_chk_row_exists%found) then
 update hr_pump_spread_loaders set
    entity_name            = p_entity_name
   ,api_module_id          = l_api_module_id
   ,entity_sql_column_name = p_entity_sql_column_name
   ,entity_sql_column_id   = p_entity_sql_column_id
   ,entity_sql_addl_column = p_entity_sql_addl_column
   ,entity_sql_object_name = p_entity_sql_object_name
   ,entity_sql_where_clause= p_entity_sql_where_clause
   ,entity_sql_parameters  = p_entity_sql_parameters
   ,entity_sql_order_by    = p_entity_sql_order_by
   ,integrator_parameters  = p_integrator_parameters

  where module_name        = p_module_name
    and integrator_code    = p_integrator_code
    and module_mode        = p_module_mode;

else
 insert into hr_pump_spread_loaders
  (
    module_name
   ,integrator_code
   ,entity_name
   ,module_mode
   ,api_module_id
   ,entity_sql_column_name
   ,entity_sql_column_id
   ,entity_sql_addl_column
   ,entity_sql_object_name
   ,entity_sql_where_clause
   ,entity_sql_parameters
   ,entity_sql_order_by
   ,integrator_parameters
  )
 values
  (
    p_module_name
   ,p_integrator_code
   ,p_entity_name
   ,p_module_mode
   ,l_api_module_id
   ,p_entity_sql_column_name
   ,p_entity_sql_column_id
   ,p_entity_sql_addl_column
   ,p_entity_sql_object_name
   ,p_entity_sql_where_clause
   ,p_entity_sql_parameters
   ,p_entity_sql_order_by
   ,p_integrator_parameters
   );
end if;

close csr_chk_row_exists;
end populate_spread_loaders_tab;

end hr_pump_utils;

/
