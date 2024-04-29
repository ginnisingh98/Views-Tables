--------------------------------------------------------
--  DDL for Package Body HR_MULTI_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MULTI_MESSAGE" AS
/* $Header: hrmulmes.pkb 120.0 2005/05/31 01:28:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< Package Private Definitions >----------------------|
-- ----------------------------------------------------------------------------
--
-- The following global variable is used to indicate if Multiple
-- Error List feature is disabled. If TRUE the Multiple Error List
-- is disabled and the procedures and functions should provide
-- "stop at first error found" functionality.
g_multi_list_disabled     boolean   default true;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< enable_message_list >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure enable_message_list is
begin
  --
  -- Clear any existing contents from the Multiple Message List
  --
  -- Call FND_MSG_PUB.INITIALIZE to ensure multiple message list
  -- is emptied.
  --
  fnd_msg_pub.initialize;
  --
  -- Enable Multiple Message Detection
  --
  g_multi_list_disabled := false;
end enable_message_list;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< disable_message_list >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure disable_message_list is
begin
  --
  -- Message List is not cleared at this stage because message retrieval
  -- is still required by the user interface. Disabling the list will
  -- prevent new messages from being added and the "verify" functions from
  -- returning FALSE. The message list will be cleared when it is enabled
  -- again.
  --
  g_multi_list_disabled := true;
end disable_message_list;
--
-- ------------------------------------------------------------------------------
-- |-------------------------< is_message_list_enabled >------------------------|
-- ------------------------------------------------------------------------------
--
function is_message_list_enabled
   return boolean is
begin
  return NOT g_multi_list_disabled;
end is_message_list_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------< no_all_inclusive_error >------------------------|
-- ----------------------------------------------------------------------------
--
function no_all_inclusive_error
  (p_check_column1                 in     varchar2
  ,p_check_column2                 in     varchar2 default null
  ,p_check_column3                 in     varchar2 default null
  ,p_check_column4                 in     varchar2 default null
  ,p_check_column5                 in     varchar2 default null
  ,p_associated_column1            in     varchar2 default null
  ,p_associated_column2            in     varchar2 default null
  ,p_associated_column3            in     varchar2 default null
  ,p_associated_column4            in     varchar2 default null
  ,p_associated_column5            in     varchar2 default null
  ) return boolean is
begin
  if hr_multi_message.g_multi_list_disabled then
    return true;
  else
    return ('T'= fnd_msg_pub.no_all_inclusive_error
                    (p_check_column1      => p_check_column1
                    ,p_check_column2      => p_check_column2
                    ,p_check_column3      => p_check_column3
                    ,p_check_column4      => p_check_column4
                    ,p_check_column5      => p_check_column5
                    ,p_associated_column1 => p_associated_column1
                    ,p_associated_column2 => p_associated_column2
                    ,p_associated_column3 => p_associated_column3
                    ,p_associated_column4 => p_associated_column4
                    ,p_associated_column5 => p_associated_column5
                    ) );
  end if;
end no_all_inclusive_error;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< no_exclusive_error >--------------------------|
-- ----------------------------------------------------------------------------
--
function no_exclusive_error
  (p_check_column1                 in     varchar2
  ,p_check_column2                 in     varchar2 default null
  ,p_check_column3                 in     varchar2 default null
  ,p_check_column4                 in     varchar2 default null
  ,p_check_column5                 in     varchar2 default null
  ,p_associated_column1            in     varchar2 default null
  ,p_associated_column2            in     varchar2 default null
  ,p_associated_column3            in     varchar2 default null
  ,p_associated_column4            in     varchar2 default null
  ,p_associated_column5            in     varchar2 default null
  ) return boolean is
begin
  if hr_multi_message.g_multi_list_disabled then
    return true;
  else
    return ('T'= fnd_msg_pub.no_exclusive_error
                    (p_check_column1      => p_check_column1
                    ,p_check_column2      => p_check_column2
                    ,p_check_column3      => p_check_column3
                    ,p_check_column4      => p_check_column4
                    ,p_check_column5      => p_check_column5
                    ,p_associated_column1 => p_associated_column1
                    ,p_associated_column2 => p_associated_column2
                    ,p_associated_column3 => p_associated_column3
                    ,p_associated_column4 => p_associated_column4
                    ,p_associated_column5 => p_associated_column5
                    ) );
  end if;
end no_exclusive_error;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< no_error_message >---------------------------|
-- ----------------------------------------------------------------------------
--
function no_error_message
  (p_check_message_name1           in     varchar2
  ,p_check_message_name2           in     varchar2 default null
  ,p_check_message_name3           in     varchar2 default null
  ,p_check_message_name4           in     varchar2 default null
  ,p_check_message_name5           in     varchar2 default null
  ,p_associated_column1            in     varchar2 default null
  ,p_associated_column2            in     varchar2 default null
  ,p_associated_column3            in     varchar2 default null
  ,p_associated_column4            in     varchar2 default null
  ,p_associated_column5            in     varchar2 default null
  ) return boolean is
begin
  if hr_multi_message.g_multi_list_disabled then
    return true;
  else
    return ('T'= fnd_msg_pub.no_error_message
                    (p_check_message_name1 => p_check_message_name1
                    ,p_check_message_name2 => p_check_message_name2
                    ,p_check_message_name3 => p_check_message_name3
                    ,p_check_message_name4 => p_check_message_name4
                    ,p_check_message_name5 => p_check_message_name5
                    ,p_associated_column1  => p_associated_column1
                    ,p_associated_column2  => p_associated_column2
                    ,p_associated_column3  => p_associated_column3
                    ,p_associated_column4  => p_associated_column4
                    ,p_associated_column5  => p_associated_column5
                    ) );
  end if;
end no_error_message;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< exception_add >---------------------------|
-- ----------------------------------------------------------------------------
--
function exception_add
  (p_associated_column1            in     varchar2 default null
  ,p_associated_column2            in     varchar2 default null
  ,p_associated_column3            in     varchar2 default null
  ,p_associated_column4            in     varchar2 default null
  ,p_associated_column5            in     varchar2 default null
  ,p_same_associated_columns       in     varchar2 default 'N'
  ) return boolean is
  l_same_associated_columns  varchar2(1);
begin
  if hr_multi_message.g_multi_list_disabled then
    return true;
  else
   --   convert p_same_associated_columns values of
   --   'Y' and 'N' to 'T' and 'F' values.
    if p_same_associated_columns = 'Y' then
      l_same_associated_columns := 'T';
    else
      l_same_associated_columns := 'F';
    end if;
    fnd_msg_pub.add_detail
                    (p_associated_column1      => p_associated_column1
                    ,p_associated_column2      => p_associated_column2
                    ,p_associated_column3      => p_associated_column3
                    ,p_associated_column4      => p_associated_column4
                    ,p_associated_column5      => p_associated_column5
                    ,p_same_associated_columns => l_same_associated_columns
                    ,p_message_type            => HR_MULTI_MESSAGE.G_ERROR_MSG
                    );
    return false;
  end if;
end exception_add;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------------< add >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure add
  (p_associated_column1            in     varchar2 default null
  ,p_associated_column2            in     varchar2 default null
  ,p_associated_column3            in     varchar2 default null
  ,p_associated_column4            in     varchar2 default null
  ,p_associated_column5            in     varchar2 default null
  ,p_same_associated_columns       in     varchar2 default 'N'
  ,p_message_type                  in     varchar2 default
                                                   hr_multi_message.g_error_msg
  ) is
  l_same_associated_columns  varchar2(1);
  l_hr_msg_name              varchar2(30);
  l_hr_msg_appl              fnd_application.application_short_name%type;
  l_fnd_msg_encoded          varchar2(2000);
  l_fnd_msg_appl             fnd_application.application_short_name%type;
  l_fnd_msg_name             varchar2(30);
begin
  if hr_multi_message.g_multi_list_disabled then
    --
    -- Provide stop at first error found behaviour
    --
    if p_message_type = hr_multi_message.g_error_msg then
      --
      -- For error messages raise a PL/SQL exception
      --
      -- Fix for 4309248:
      -- Background
      -- ==========
      -- Modification to fix bug 2661569 (changing a hardcoded
      -- call from fnd_message.raise_error to
      -- hr_utility.raise_error) was incorrect. As HRMS
      -- error messages can be setup in two ways. Either
      -- using the hr_utility or fnd_message packages. The
      -- following solution ensures that when an error is
      -- raised it is done in a consistent way to how the
      -- error was setup. i.e. If the error was setup using
      -- hr_utility then hr_utility.raise_error will be
      -- called. Otherwise if the error was setup using
      -- fnd_message then fnd_message.raise_error will
      -- be called.
      --
      -- Solution Overview
      -- =================
      -- When an error is raised using the hr_utility.raise_error
      -- the error details are not cleared from the hr_utility
      -- package. Hence we cannot just call
      -- hr_utility.get_message_details and assume that when
      -- 'NO_MESSAGE' has been called that the error has been
      -- set-up using fnd_message. This is because if one message
      -- is set-up using hr_utility then all following messages
      -- set-up using fnd_message would also look as if they
      -- have been set-up using hr_utility. The solution needs
      -- obtain the error details currently held in both
      -- hr_utility and fnd_message. If error details returned
      -- from both packages are the same then hr_utility has
      -- been used. If they are different then fnd_message must
      -- have been used for the latest message.
      --
      -- Solution Details
      -- ================
      -- Obtain the error message details from the
      -- hr_utility package to find out if the error message
      -- was raised from through that package. If the
      -- the 'NO_MESSAGE' string is returned then the error
      -- can't have been set using the hr_utility package.
      --
      -- Obtain error details from the hr_utility package
      --
      hr_utility.get_message_details
        (msg_name => l_hr_msg_name
        ,msg_appl => l_hr_msg_appl
        );
      --
      -- If the 'NO_MESSAGE' string is returned then the error
      -- can't have been setup using the hr_utility package,
      -- it must be in fnd_message.
      --
      if l_hr_msg_name = 'NO_MESSAGE' then
        fnd_message.raise_error;
      else
        --
        -- Obtain error details from fnd_message, without
        -- clearing the message in the other package.
        --
        l_fnd_msg_encoded := fnd_message.get_encoded(AUTO_LOG => 'Y');
        if l_fnd_msg_encoded is not null then
          fnd_message.parse_encoded
            (encoded_message => l_fnd_msg_encoded
            ,app_short_name  => l_fnd_msg_appl
            ,message_name    => l_fnd_msg_name
            );
        else
          l_fnd_msg_appl := null;
          l_fnd_msg_name := 'NO_MESSAGE';
        end if;
        --
        -- If the message names returned from the fnd_message
        -- and hr_utility packages are different then the
        -- latest message cannot have been setup using the
        -- hr_utility package.
        if l_fnd_msg_name <> l_hr_msg_name then
          fnd_message.raise_error;
        else
          hr_utility.raise_error;
        end if;
      end if;
    else
      -- All other message types should be ignored.
      -- Make sure fnd_message package is cleared
      -- so later messages can be set without being
      -- mixed up with previously set values.
      --
      fnd_message.clear;
    end if;
  else
    --
    -- Provide Multiple Message Detection for all types of message
    --
    --  convert p_same_associated_columns values of
    --   'Y' and 'N' to 'T' and 'F' values.
    if p_same_associated_columns = 'Y' then
      l_same_associated_columns := 'T';
    else
      l_same_associated_columns := 'F';
    end if;
    --
    fnd_msg_pub.add_detail
                    (p_associated_column1      => p_associated_column1
                    ,p_associated_column2      => p_associated_column2
                    ,p_associated_column3      => p_associated_column3
                    ,p_associated_column4      => p_associated_column4
                    ,p_associated_column5      => p_associated_column5
                    ,p_same_associated_columns => l_same_associated_columns
                    ,p_message_type            => p_message_type
                    );
  end if;
end add;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< unexpected_error_add >-------------------------|
-- ----------------------------------------------------------------------------
--
function unexpected_error_add
  (p_procedure_name                in     varchar2
  ) return boolean is
l_encoded varchar2(2000);
l_pkg_name varchar2(2000);
l_procedure_name varchar2(2000);
l_position number;
begin
  if hr_multi_message.g_multi_list_disabled then
    return true;
  else
    --
    if sqlcode = -20001 then
      l_encoded := fnd_message.get_encoded;
      if l_encoded is not null then
        fnd_message.set_encoded(l_encoded);
        fnd_msg_pub.add;
      else
        l_position := instr(p_procedure_name,'.');
        if l_position <> 0 then
          l_pkg_name := substr(p_procedure_name,1,l_position-1);
          l_procedure_name := substr(p_procedure_name,l_position+1,length(p_procedure_name));
        else
          l_pkg_name := '';
          l_procedure_name := p_procedure_name;
        end if;
        fnd_msg_pub.add_exc_msg
                        (p_pkg_name => l_pkg_name
                        ,p_procedure_name => l_procedure_name);
      end if;
    else
      l_position := instr(p_procedure_name,'.');
      if l_position <> 0 then
        l_pkg_name := substr(p_procedure_name,1,l_position-1);
        l_procedure_name := substr(p_procedure_name,l_position+1,length(p_procedure_name));
      else
        l_pkg_name := '';
        l_procedure_name := p_procedure_name;
      end if;
      fnd_msg_pub.add_exc_msg
                      (p_pkg_name => l_pkg_name
                      ,p_procedure_name => l_procedure_name);

    end if;
    return false;
  end if;
end unexpected_error_add;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< end_validation_set >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure end_validation_set is
l_encoded varchar2(2000);
l_message_type varchar2(1);
begin
  if hr_multi_message.is_message_list_enabled then
    --
    --  loop through messages to find the first message of type ERROR
    FOR I IN 1..fnd_msg_pub.count_msg LOOP
      l_encoded := fnd_msg_pub.get_detail(p_msg_index => I);
      fnd_message.set_encoded(l_encoded);
      l_message_type := fnd_message.get_token
                            (token => fnd_msg_pub.g_message_type_token_name);
      if l_message_type = hr_multi_message.g_error_msg then
        raise hr_multi_message.Error_Message_Exist;
      end if;
    end loop;
  end if;
end end_validation_set;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_return_status >--------------------------|
-- ----------------------------------------------------------------------------
--
function get_return_status return varchar2 is
begin
  --
  -- return error status if any type of message exists in the list
  -- else returns success status
  --
  if fnd_msg_pub.count_msg > 0 then
    return 'E';
  else
    return 'S';
  end if;
end get_return_status;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_return_status_disable >----------------------|
-- ----------------------------------------------------------------------------
--
function get_return_status_disable return varchar2 is
begin
  --
  -- disable the message list if enabled and return status
  g_multi_list_disabled := true;
  --
  return hr_multi_message.get_return_status;
end get_return_status_disable;
--
END HR_MULTI_MESSAGE;

/
