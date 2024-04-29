--------------------------------------------------------
--  DDL for Package Body HR_WIP_TXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WIP_TXNS" 
/* $Header: hrwiptxn.pkb 120.1 2005/06/28 02:33:11 cnholmes noship $ */
AS
  g_start_state                 VARCHAR2(5)  := 'START';
  g_save_for_later_state        VARCHAR2(14) := 'SAVE_FOR_LATER';
  g_pending_approval_state      VARCHAR2(16) := 'PENDING_APPROVAL';
  g_reject_for_correction_state VARCHAR2(21) := 'REJECT_FOR_CORRECTION';
  g_manual_sub_state            VARCHAR2(6)  := 'MANUAL';
  g_automatic_sub_state         VARCHAR2(9)  := 'AUTO';
  g_query_only_dml_mode         VARCHAR2(10) := 'QUERY_ONLY';
  g_insert_dml_mode             VARCHAR2(6)  := 'INSERT';
  g_update_dml_mode             VARCHAR2(6)  := 'UPDATE';
  g_delete_dml_mode             VARCHAR2(6)  := 'DELETE';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_item_type_item_key_mand >---------------------|
-- ----------------------------------------------------------------------------
Procedure chk_item_type_item_key_mand
                    (p_item_type in wf_items.item_type%TYPE,
                     p_item_key  in wf_items.item_key%TYPE)
is
begin
 --
  If p_item_type is null
  then
    fnd_message.set_name('PER','PER_289658_TXN_ITEM_TYPE_MND');
    fnd_message.raise_error;
  ElsIf p_item_key is null
  then
    fnd_message.set_name('PER','PER_289659_TXN_ITEM_KEY_MND');
    fnd_message.raise_error;
  End if;
end chk_item_type_item_key_mand;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_item_type_item_key_exists >-------------------|
-- ----------------------------------------------------------------------------
procedure chk_item_type_item_key_exists
                    (p_item_type IN wf_items.item_type%TYPE,
                     p_item_key  IN wf_items.item_key%TYPE)
is
  --
  l_end_date wf_items.end_date%TYPE;
  --
  cursor csr_item_type_exists is
    select end_date
    from   wf_items
    where  item_type = p_item_type
    and    item_key  = p_item_key;
  --
begin
  open csr_item_type_exists;
  fetch csr_item_type_exists into l_end_date;
  If csr_item_type_exists%notfound
  then
    close csr_item_type_exists;
    fnd_message.set_name('PER','PER_289660_TXN_INV_WFL');
    fnd_message.raise_error;
  End if;
  close csr_item_type_exists;
  If l_end_date is not null
  then
    fnd_message.set_name('PER','PER_289661_TXN_WFL_END');
    fnd_message.raise_error;
  End if;
exception
  when others then
    If csr_item_type_exists%isopen
    then
      close csr_item_type_exists;
    end if;
    raise;
end chk_item_type_item_key_exists;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_creator_user_id >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_creator_user_id
                    (p_creator_user_id in fnd_user.user_id%TYPE)
is
--
  l_end_date fnd_user.end_date%TYPE;
  cursor csr_creator_user_id is
    select end_date
    from   fnd_user
    where  user_id = p_creator_user_id;
--
begin
  If p_creator_user_id is null
  then
    fnd_message.set_name('PER','PER_289662_TXN_INV_CREATOR');
    fnd_message.raise_error;
  End if;
  open csr_creator_user_id;
  fetch csr_creator_user_id into l_end_date;
  If csr_creator_user_id%notfound
  then
    close csr_creator_user_id;
    fnd_message.set_name('PER','PER_289663_TXN_INV_USER');
    fnd_message.raise_error;
  End if;
  close csr_creator_user_id;
  If ((l_end_date is not null) and (l_end_date < sysdate))
  then
    fnd_message.set_name('PER','PER_289664_TXN_USER_END');
    fnd_message.raise_error;
  End if;
exception
  when others then
    If csr_creator_user_id%isopen
    then
      close csr_creator_user_id;
    end if;
    raise;
End chk_creator_user_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_function_id >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_function_id
                    (p_function_id in fnd_form_functions.function_id%TYPE)
is
  l_function_id varchar2(1);
  cursor csr_function_id is
    select null
    from   fnd_form_functions
    where  function_id = p_function_id;
begin
  If p_function_id is not null
  then
    open csr_function_id;
    fetch csr_function_id into l_function_id;
    If csr_function_id%notfound
    then
      close csr_function_id;
      fnd_message.set_name('PER','PER_289665_TXN_INV_FORM');
      fnd_message.raise_error;
    End if;
    close csr_function_id;
  Else
    fnd_message.set_name('PER','PER_289666_TXN_FORM_MND');
    fnd_message.raise_error;
  End if;
exception
  when others then
    If csr_function_id%isopen
    then
      close csr_function_id;
    end if;
    raise;
end chk_function_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_transaction_creator >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_transaction_creator(p_creator_user_id in fnd_user.user_id%TYPE
                                 ,p_current_user_id in fnd_user.user_id%TYPE
                                 )is
begin
  If p_creator_user_id <> p_current_user_id
  then
    fnd_message.set_name('PER','PER_289667_TXN_MOD_CREATOR');
    fnd_message.raise_error;
  End if;
end chk_transaction_creator;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_state >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_state
                  (p_state     IN hr_wip_transactions.state%TYPE
                  )is
begin
  If p_state not in (g_start_state,g_save_for_later_state
                    ,g_pending_approval_state,g_reject_for_correction_state)
  then
    fnd_message.set_name('PER','PER_289676_TXN_INV_STATE');
    fnd_message.raise_error;
  End if;
end chk_state;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_sub_state >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_sub_state
                    (p_state     IN hr_wip_transactions.state%TYPE
                    ,p_sub_state IN hr_wip_transactions.sub_state%TYPE)is
begin
    If (p_state <> g_save_for_later_state and p_sub_state is not null)
    then
      fnd_message.set_name('PER','PER_289668_TXN_INV_SUBSTATE');
      fnd_message.raise_error;
    Elsif (p_state = g_save_for_later_state and nvl(p_sub_state,-1)
            not in (g_automatic_sub_state,g_manual_sub_state))
    then
      fnd_message.set_name('PER','PER_289669_TXN_SUBSTATE_VAL');
      fnd_message.raise_error;
    End if;
end chk_sub_state;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_and_chk_and_return_dml_mode >----------------|
-- ----------------------------------------------------------------------------
Function get_and_chk_and_ret_dml_mode
    (p_new_dml_mode IN hr_wip_transactions.dml_mode%TYPE
    ,p_old_dml_mode IN hr_wip_transactions.dml_mode%TYPE)
    RETURN hr_wip_transactions.dml_mode%TYPE is
  begin
    If p_new_dml_mode = hr_api.g_varchar2 THEN
      RETURN(p_old_dml_mode);
    end if;
    -- a new dml_mode has been specified
    -- check the dml_mode
    If p_old_dml_mode = g_query_only_dml_mode
    then
      -- the current transaction is in QUERY_ONLY mode
      If p_new_dml_mode <> g_query_only_dml_mode
      then
        fnd_message.set_name('PER','PER_289681_TXN_DML_QUERY_MODE');
        fnd_message.raise_error;
      else
        RETURN(g_query_only_dml_mode);
      end if;
    end if;
    -- set the dml_mode
    -- check to ensure that the dml_mode has a valid value
    IF p_new_dml_mode = g_query_only_dml_mode OR
       p_new_dml_mode = g_insert_dml_mode OR
       p_new_dml_mode = g_update_dml_mode OR
       p_new_dml_mode = g_delete_dml_mode
    then
      -- dml_mode was specified
      RETURN(p_new_dml_mode);
    else
      fnd_message.set_name('PER','PER_289682_TXN_DML_INV_MODE');
      fnd_message.raise_error;
    end if;
end get_and_chk_and_ret_dml_mode;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_context_display_text >-----------------------|
-- ----------------------------------------------------------------------------
Function get_context_display_text
   (p_new_context_display_text IN hr_wip_transactions.context_display_text%TYPE
   ,p_old_context_display_text IN hr_wip_transactions.context_display_text%TYPE)
    RETURN hr_wip_transactions.context_display_text%TYPE IS
  begin
    -- set the correct context_display_text
    If p_new_context_display_text = hr_api.g_varchar2
    then
      -- the context_display_text was not specified
      RETURN(p_old_context_display_text);
    else
      -- context_display_text was specified
      RETURN(p_new_context_display_text);
    END IF;
end get_context_display_text;
-- ----------------------------------------------------------------------------
-- |-----------------------< ins >-----------------------|
-- ----------------------------------------------------------------------------
Function ins
     (p_item_type            IN wf_items.item_type%TYPE
     ,p_item_key             IN wf_items.item_key%TYPE
     ,p_function_id          IN fnd_form_functions.function_id%TYPE
     ,p_creator_user_id      IN fnd_user.user_id%TYPE
     ,p_dml_mode             IN hr_wip_transactions.dml_mode%TYPE
     ,p_vo_xml               IN VARCHAR2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
     ) RETURN hr_wip_transactions.transaction_id%TYPE is
--
     l_tran_id hr_wip_transactions.transaction_id%TYPE;
--
begin
  chk_item_type_item_key_mand(p_item_type => p_item_type
                             ,p_item_key  => p_item_key
                             );
  chk_item_type_item_key_exists
          (p_item_type => p_item_type
          ,p_item_key  => p_item_key
          );
  chk_creator_user_id(p_creator_user_id => p_creator_user_id);
  chk_function_id(p_function_id => p_function_id);
  insert into hr_wip_transactions(transaction_id
                                 ,creator_user_id
                                 ,item_type
                                 ,item_key
                                 ,function_id
                                 ,state
                                 ,sub_state
                                 ,vo_cache
                                 ,context_display_text
                                 ,dml_mode
                                 )
                           values(hr_wip_transactions_s.nextval
                                 ,p_creator_user_id
                                 ,p_item_type
                                 ,p_item_key
                                 ,p_function_id
                                 ,g_start_state
                                 ,null
                                 ,p_vo_xml
                                 ,p_context_display_text
                                 ,p_dml_mode
                                 )returning transaction_id into l_tran_id;
  return l_tran_id;
  exception
    when dup_val_on_index then
      fnd_message.set_name('PER','PER_289670_TXN_WFL_EXIST');
      fnd_message.raise_error;
    when others then
      raise;
end ins;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< upd >-----------------------|
-- ----------------------------------------------------------------------------
Procedure upd
       (p_transaction_id       IN hr_wip_transactions.transaction_id%TYPE
       ,p_state                IN hr_wip_transactions.state%TYPE
       ,p_sub_state            IN hr_wip_transactions.sub_state%TYPE
       ,p_vo_xml               IN VARCHAR2
       ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                                  default hr_api.g_varchar2
       ,p_dml_mode             IN hr_wip_transactions.dml_mode%TYPE
                                  default hr_api.g_varchar2
       )is
--
begin
  update hr_wip_transactions
  set    state = p_state
        ,sub_state = p_sub_state
        ,vo_cache = p_vo_xml
        ,context_display_text = p_context_display_text
        ,dml_mode = p_dml_mode
  where  transaction_id = p_transaction_id;
end upd;
-- ----------------------------------------------------------------------------
-- |-----------------------< create_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Function create_transaction
     (p_item_type            IN wf_items.item_type%TYPE
     ,p_item_key             IN wf_items.item_key%TYPE
     ,p_function_id          IN fnd_form_functions.function_id%TYPE
     ,p_creator_user_id      IN fnd_user.user_id%TYPE
     ,p_dml_mode             IN hr_wip_transactions.dml_mode%TYPE
     ,p_vo_xml               IN VARCHAR2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
     ) RETURN hr_wip_transactions.transaction_id%TYPE
     is
PRAGMA AUTONOMOUS_TRANSACTION;
l_transaction_id number;
begin
 l_transaction_id := ins
    (p_item_type => p_item_type
    ,p_item_key => p_item_key
    ,p_function_id => p_function_id
    ,p_creator_user_id => p_creator_user_id
    ,p_dml_mode => p_dml_mode
    ,p_vo_xml => p_vo_xml
    ,p_context_display_text => p_context_display_text
    );
  commit;
  return l_transaction_id;
end create_transaction;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure create_transaction
     (p_item_type             IN wf_items.item_type%TYPE
     ,p_item_key              IN wf_items.item_key%TYPE
     ,p_function_id           IN fnd_form_functions.function_id%TYPE
     ,p_creator_user_id       IN fnd_user.user_id%TYPE
     ,p_dml_mode              IN hr_wip_transactions.dml_mode%TYPE
     ,p_vo_xml                IN VARCHAR2
     ,p_context_display_text  IN hr_wip_transactions.context_display_text%TYPE
     ,p_transaction_id        OUT NOCOPY hr_wip_transactions.transaction_id%TYPE
     )is
PRAGMA AUTONOMOUS_TRANSACTION;
begin
   p_transaction_id := ins
      (p_item_type => p_item_type
      ,p_item_key => p_item_key
      ,p_function_id => p_function_id
      ,p_creator_user_id => p_creator_user_id
      ,p_dml_mode => p_dml_mode
      ,p_vo_xml => p_vo_xml
      ,p_context_display_text => p_context_display_text
      );
   commit;
end create_transaction;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_query_only_transaction >-----------------|
-- ----------------------------------------------------------------------------
Function create_query_only_transaction
     (p_item_type            IN wf_items.item_type%TYPE
     ,p_item_key             IN wf_items.item_key%TYPE
     ,p_function_id          IN fnd_form_functions.function_id%TYPE
     ,p_creator_user_id      IN fnd_user.user_id%TYPE
     ,p_vo_xml               IN VARCHAR2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
     ) RETURN hr_wip_transactions.transaction_id%TYPE is
PRAGMA AUTONOMOUS_TRANSACTION;
l_transaction_id hr_wip_transactions.transaction_id%TYPE;
begin
 l_transaction_id := ins
    (p_item_type => p_item_type
    ,p_item_key => p_item_key
    ,p_function_id => p_function_id
    ,p_creator_user_id => p_creator_user_id
    ,p_dml_mode => g_query_only_dml_mode
    ,p_vo_xml => p_vo_xml
    ,p_context_display_text => p_context_display_text
    );
    commit;
    return l_transaction_id;
end create_query_only_transaction;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_query_only_transaction >-----------------|
-- ----------------------------------------------------------------------------
Procedure create_query_only_transaction
     (p_item_type            IN wf_items.item_type%TYPE
     ,p_item_key             IN wf_items.item_key%TYPE
     ,p_function_id          IN fnd_form_functions.function_id%TYPE
     ,p_creator_user_id      IN fnd_user.user_id%TYPE
     ,p_vo_xml               IN VARCHAR2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
     ,p_transaction_id       OUT NOCOPY hr_wip_transactions.transaction_id%TYPE
     )is
PRAGMA AUTONOMOUS_TRANSACTION;
begin
  p_transaction_id := ins
        (p_item_type => p_item_type
        ,p_item_key => p_item_key
        ,p_function_id => p_function_id
        ,p_creator_user_id => p_creator_user_id
        ,p_dml_mode => g_query_only_dml_mode
        ,p_vo_xml => p_vo_xml
        ,p_context_display_text => p_context_display_text
        );
  commit;
end create_query_only_transaction;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< save_for_later >-----------------------|
-- ----------------------------------------------------------------------------
Procedure save_for_later
      (p_transaction_id        IN hr_wip_transactions.transaction_id%TYPE
      ,p_current_user_id       IN hr_wip_transactions.creator_user_id%TYPE
      ,p_creator_user_id       IN hr_wip_transactions.creator_user_id%TYPE
      ,p_state                 IN hr_wip_transactions.state%TYPE
      ,p_vo_xml                IN VARCHAR2
      ,p_sub_state             IN hr_wip_transactions.sub_state%TYPE
      ,p_context_display_text  IN hr_wip_transactions.context_display_text%TYPE
      ,p_dml_mode              IN hr_wip_transactions.dml_mode%TYPE) is
    --
    begin
      --
      chk_transaction_creator
        (p_creator_user_id => p_creator_user_id
        ,p_current_user_id => p_current_user_id);
      --
      chk_sub_state
              (p_state     => g_save_for_later_state
              ,p_sub_state => p_sub_state);
      --
      If p_state = g_pending_approval_state then
        fnd_message.set_name('PER','PER_289672_TXN_INV_STATE');
        fnd_message.raise_error;
      End if;
      --
      upd(p_transaction_id       => p_transaction_id
         ,p_state                => g_save_for_later_state
         ,p_sub_state            => p_sub_state
         ,p_vo_xml               => p_vo_xml
         ,p_dml_mode             => p_dml_mode
         ,p_context_display_text => p_context_display_text
         );
end save_for_later;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< save_for_later >-----------------------|
-- ----------------------------------------------------------------------------
Procedure save_for_later
     (p_item_type       IN wf_items.item_type%TYPE
     ,p_item_key        IN wf_items.item_key%TYPE
     ,p_current_user_id IN fnd_user.user_id%TYPE
     ,p_vo_xml          IN VARCHAR2
     ,p_sub_state       IN hr_wip_transactions.sub_state%TYPE
     ,p_dml_mode        IN hr_wip_transactions.dml_mode%TYPE
                            default hr_api.g_varchar2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                            default hr_api.g_varchar2
     ,p_transaction_id  OUT NOCOPY hr_wip_transactions.transaction_id%TYPE
              )is
PRAGMA AUTONOMOUS_TRANSACTION;
l_creator_user_id hr_wip_transactions.creator_user_id%TYPE;
l_state hr_wip_transactions.state%TYPE;
l_dml_mode hr_wip_transactions.dml_mode%TYPE;
l_context_display_text hr_wip_transactions.context_display_text%TYPE;
cursor csr_user_id is
            select creator_user_id
                   ,transaction_id
                   ,state,dml_mode
                   ,context_display_text
              from hr_wip_transactions
             where item_type = p_item_type
               and item_key  = p_item_key;
begin
  chk_item_type_item_key_mand
          (p_item_type => p_item_type
          ,p_item_key  => p_item_key
          );
  chk_item_type_item_key_exists(p_item_type => p_item_type
  			       ,p_item_key  => p_item_key
  			       );
  open csr_user_id;
  fetch csr_user_id into l_creator_user_id,
                         p_transaction_id,
                         l_state,
                         l_dml_mode,
                         l_context_display_text;
  if csr_user_id%NOTFOUND THEN
    close csr_user_id;
    fnd_message.set_name('PER','PER_289680_TXN_INV_WFL');
    fnd_message.raise_error;
  end if;
  close csr_user_id;
  save_for_later
          (p_transaction_id       => p_transaction_id
          ,p_current_user_id      => p_current_user_id
          ,p_creator_user_id      => l_creator_user_id
          ,p_state                => l_state
          ,p_vo_xml               => p_vo_xml
          ,p_sub_state            => p_sub_state
          ,p_context_display_text =>
                   get_context_display_text
                      (p_new_context_display_text => p_context_display_text
                      ,p_old_context_display_text => l_context_display_text)
          ,p_dml_mode             =>
                   get_and_chk_and_ret_dml_mode
                       (p_new_dml_mode => p_dml_mode
                       ,p_old_dml_mode => l_dml_mode)
          );
  commit;
exception
  when others then
    If csr_user_id%isopen
    then
      close csr_user_id;
    end if;
    raise;
end save_for_later;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< save_for_later >-----------------------|
-- ----------------------------------------------------------------------------
Procedure save_for_later
       (p_transaction_id  IN hr_wip_transactions.transaction_id%TYPE
       ,p_current_user_id IN fnd_user.user_id%TYPE
       ,p_vo_xml          IN VARCHAR2
       ,p_sub_state       IN hr_wip_transactions.sub_state%TYPE
       ,p_dml_mode        IN hr_wip_transactions.dml_mode%TYPE
	                     default hr_api.g_varchar2
       ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                             default hr_api.g_varchar2
       )is
PRAGMA AUTONOMOUS_TRANSACTION;
l_creator_user_id hr_wip_transactions.creator_user_id%TYPE;
l_state hr_wip_transactions.state%TYPE;
l_dml_mode hr_wip_transactions.dml_mode%TYPE;
l_context_display_text hr_wip_transactions.context_display_text%TYPE;
cursor csr_user_id is
            select creator_user_id,
                   state,
                   dml_mode,
                   context_display_text
              from hr_wip_transactions
             where transaction_id = p_transaction_id;
begin
  open csr_user_id;
  fetch csr_user_id into l_creator_user_id,
                         l_state,
                         l_dml_mode,
                         l_context_display_text;
  if csr_user_id%NOTFOUND THEN
    close csr_user_id;
    fnd_message.set_name('PER','PER_289671_TXN_INV');
    fnd_message.raise_error;
  end if;
  close csr_user_id;
  save_for_later
            (p_transaction_id       => p_transaction_id
            ,p_current_user_id      => p_current_user_id
            ,p_creator_user_id      => l_creator_user_id
            ,p_state                => l_state
            ,p_vo_xml               => p_vo_xml
            ,p_sub_state            => p_sub_state
            ,p_context_display_text =>
                     get_context_display_text
                        (p_new_context_display_text => p_context_display_text
                        ,p_old_context_display_text => l_context_display_text)
            ,p_dml_mode             =>
                     get_and_chk_and_ret_dml_mode
                         (p_new_dml_mode => p_dml_mode
                         ,p_old_dml_mode => l_dml_mode)
            );
  commit;
exception
  when others then
    If csr_user_id%isopen
    then
      close csr_user_id;
    end if;
    raise;
end save_for_later;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< save_for_later_append >-----------------------|
-- ----------------------------------------------------------------------------
Procedure save_for_later_append
       (p_transaction_id  IN hr_wip_transactions.transaction_id%TYPE
       ,p_vo_xml          IN VARCHAR2
       )is
PRAGMA AUTONOMOUS_TRANSACTION;

  l_db_clob hr_wip_transactions.vo_cache%type;
  cursor csr_vo_cache is
            select vo_cache
              from hr_wip_transactions
             where transaction_id = p_transaction_id
            for update nowait;
begin

  open csr_vo_cache;
  fetch csr_vo_cache into l_db_clob;
  if csr_vo_cache%NOTFOUND THEN
    close csr_vo_cache;
    fnd_message.set_name('PER','PER_289671_TXN_INV');
    fnd_message.raise_error;
  end if;
  close csr_vo_cache;

  DBMS_LOB.WRITE(l_db_clob,
                 length(p_vo_xml),
                 DBMS_LOB.GETLENGTH(l_db_clob)+1,
                 p_vo_xml);

  update hr_wip_transactions
  set    vo_cache = l_db_clob
  where  transaction_id = p_transaction_id;

  commit;

exception
  when others then
    raise;
end save_for_later_append;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< pending_approval >-----------------------|
-- ----------------------------------------------------------------------------
Procedure pending_approval
      (p_transaction_id        IN hr_wip_transactions.transaction_id%TYPE
      ,p_current_user_id       IN hr_wip_transactions.creator_user_id%TYPE
      ,p_creator_user_id       IN hr_wip_transactions.creator_user_id%TYPE
      ,p_state                 IN hr_wip_transactions.state%TYPE
      ,p_vo_xml                IN VARCHAR2
      ,p_sub_state             IN hr_wip_transactions.sub_state%TYPE
      ,p_context_display_text  IN hr_wip_transactions.context_display_text%TYPE
      ,p_dml_mode              IN hr_wip_transactions.dml_mode%TYPE) is
begin
  chk_transaction_creator(p_creator_user_id => p_creator_user_id
                         ,p_current_user_id => p_current_user_id
                         );
  chk_sub_state
        (p_state     => g_pending_approval_state
        ,p_sub_state => p_sub_state);
--
  If p_dml_mode = g_query_only_dml_mode
  then
    fnd_message.set_name('PER','PER_289673_TXN_QUERY');
    fnd_message.raise_error;
  End if;
--
  If p_state = g_pending_approval_state
  then
    fnd_message.set_name('PER','PER_289674_TXN_PENDING');
    fnd_message.raise_error;
  End if;
  upd(p_transaction_id       => p_transaction_id
     ,p_state                => g_pending_approval_state
     ,p_sub_state            => null
     ,p_vo_xml               => p_vo_xml
     ,p_dml_mode             => p_dml_mode
     ,p_context_display_text => p_context_display_text
     );
end pending_approval;
-- ----------------------------------------------------------------------------
-- |-----------------------< pending_approval >-----------------------|
-- ----------------------------------------------------------------------------
Procedure pending_approval
       (p_item_type       IN wf_items.item_type%TYPE
       ,p_item_key        IN wf_items.item_key%TYPE
       ,p_current_user_id IN fnd_user.user_id%TYPE
       ,p_vo_xml          IN VARCHAR2
       ,p_dml_mode        IN hr_wip_transactions.dml_mode%TYPE
                             default hr_api.g_varchar2
       ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                             default hr_api.g_varchar2
       )is
PRAGMA AUTONOMOUS_TRANSACTION;
l_creator_user_id hr_wip_transactions.creator_user_id%TYPE;
l_transaction_id hr_wip_transactions.transaction_id%TYPE;
l_state hr_wip_transactions.state%TYPE;
l_dml_mode hr_wip_transactions.dml_mode%TYPE;
l_context_display_text hr_wip_transactions.context_display_text%TYPE;
cursor csr_user_id is
      select creator_user_id,
             transaction_id,
             state,
             dml_mode,
             context_display_text
      from hr_wip_transactions
      where item_type = p_item_type
        and item_key  = p_item_key;
begin
  chk_item_type_item_key_mand
            (p_item_type => p_item_type
            ,p_item_key  => p_item_key
            );
  chk_item_type_item_key_exists(p_item_type => p_item_type
    			       ,p_item_key  => p_item_key
  			       );
  open csr_user_id;
  fetch csr_user_id into l_creator_user_id,
                         l_transaction_id,
                         l_state,
                         l_dml_mode,
                         l_context_display_text;
  if csr_user_id%NOTFOUND THEN
      close csr_user_id;
      fnd_message.set_name('PER','PER_289680_TXN_INV_WFL');
      fnd_message.raise_error;
  end if;
  close csr_user_id;
  pending_approval
            (p_transaction_id       => l_transaction_id
            ,p_current_user_id      => p_current_user_id
            ,p_creator_user_id      => l_creator_user_id
            ,p_state                => l_state
            ,p_vo_xml               => p_vo_xml
            ,p_sub_state            => null
            ,p_context_display_text =>
                     get_context_display_text
                        (p_new_context_display_text => p_context_display_text
                        ,p_old_context_display_text => l_context_display_text)
            ,p_dml_mode             =>
                     get_and_chk_and_ret_dml_mode
                         (p_new_dml_mode => p_dml_mode
                         ,p_old_dml_mode => l_dml_mode)
            );
  commit;
exception
  when others then
    If csr_user_id%isopen
    then
      close csr_user_id;
    end if;
    raise;
end pending_approval;
-- ----------------------------------------------------------------------------
-- |-----------------------< pending_approval >-----------------------|
-- ----------------------------------------------------------------------------
Procedure pending_approval
       (p_transaction_id  IN hr_wip_transactions.transaction_id%TYPE
       ,p_current_user_id IN fnd_user.user_id%TYPE
       ,p_vo_xml          IN VARCHAR2
       ,p_dml_mode        IN hr_wip_transactions.dml_mode%TYPE
                             default hr_api.g_varchar2
       ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                             default hr_api.g_varchar2
              )is
PRAGMA AUTONOMOUS_TRANSACTION;
l_creator_user_id hr_wip_transactions.creator_user_id%TYPE;
l_state hr_wip_transactions.state%TYPE;
l_dml_mode hr_wip_transactions.dml_mode%TYPE;
l_context_display_text hr_wip_transactions.context_display_text%TYPE;
cursor csr_user_id is
      select creator_user_id,
             state,
             dml_mode,
             context_display_text
        from hr_wip_transactions
       where transaction_id = p_transaction_id;
begin
  open csr_user_id;
  fetch csr_user_id into l_creator_user_id,
                         l_state,
                         l_dml_mode,
                         l_context_display_text;
  if csr_user_id%NOTFOUND THEN
    close csr_user_id;
    fnd_message.set_name('PER','PER_289671_TXN_INV');
    fnd_message.raise_error;
  end if;
  close csr_user_id;
  pending_approval
            (p_transaction_id       => p_transaction_id
            ,p_current_user_id      => p_current_user_id
            ,p_creator_user_id      => l_creator_user_id
            ,p_state                => l_state
            ,p_vo_xml               => p_vo_xml
            ,p_sub_state            => null
            ,p_context_display_text =>
                     get_context_display_text
                        (p_new_context_display_text => p_context_display_text
                        ,p_old_context_display_text => l_context_display_text)
            ,p_dml_mode             =>
                     get_and_chk_and_ret_dml_mode
                         (p_new_dml_mode => p_dml_mode
                         ,p_old_dml_mode => l_dml_mode)
            );
  commit;
exception
  when others then
    If csr_user_id%isopen
    then
      close csr_user_id;
    end if;
    raise;
end pending_approval;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< reject_for_correction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure reject_for_correction
      (p_transaction_id        IN hr_wip_transactions.transaction_id%TYPE
      ,p_state                 IN hr_wip_transactions.state%TYPE
      ,p_vo_xml                IN clob
      ,p_sub_state             IN hr_wip_transactions.sub_state%TYPE
      ,p_context_display_text  IN hr_wip_transactions.context_display_text%TYPE
      ,p_dml_mode              IN hr_wip_transactions.dml_mode%TYPE) is
l_vo_xml_var varchar(32767);
l_amount number;
begin
  If p_state <> g_pending_approval_state
  then
    fnd_message.set_name('PER','PER_289675_TXN_PEN_REJ_CORR');
    fnd_message.raise_error;
  End if;
  --
  -- Convert clob to varchar2 datatype for comparision
  --
    l_amount := dbms_lob.getlength(p_vo_xml);
    dbms_lob.read(p_vo_xml,l_amount,1,l_vo_xml_var);
  --
  upd(p_transaction_id       => p_transaction_id
     ,p_state                => g_reject_for_correction_state
     ,p_sub_state            => null
     ,p_vo_xml               => l_vo_xml_var
     ,p_dml_mode             => p_dml_mode
     ,p_context_display_text => p_context_display_text
     );
end reject_for_correction;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< reject_for_correction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure reject_for_correction
              (p_item_type       IN wf_items.item_type%TYPE
              ,p_item_key        IN wf_items.item_key%TYPE
              )is
PRAGMA AUTONOMOUS_TRANSACTION;
l_state hr_wip_transactions.state%TYPE;
l_dml_mode hr_wip_transactions.dml_mode%TYPE;
l_context_display_text hr_wip_transactions.context_display_text%TYPE;
l_transaction_id hr_wip_transactions.transaction_id%TYPE;
l_vo_xml clob;
cursor csr_user_id is
            select transaction_id,
                   state,
                   vo_cache,
                   dml_mode,
                   context_display_text
              from hr_wip_transactions
             where item_type = p_item_type
               and item_key  = p_item_key;
begin
  chk_item_type_item_key_mand
            (p_item_type => p_item_type
            ,p_item_key  => p_item_key
            );
  chk_item_type_item_key_exists(p_item_type => p_item_type
    			       ,p_item_key  => p_item_key
  			       );
  open csr_user_id;
  fetch csr_user_id into l_transaction_id,
                         l_state,
                         l_vo_xml,
                         l_dml_mode,
                         l_context_display_text;
  if csr_user_id%NOTFOUND THEN
      close csr_user_id;
      fnd_message.set_name('PER','PER_289680_TXN_INV_WFL');
      fnd_message.raise_error;
  end if;
  close csr_user_id;
  reject_for_correction(p_transaction_id        => l_transaction_id
                       ,p_state                 => l_state
                       ,p_vo_xml                => l_vo_xml
                       ,p_sub_state             => null
                       ,p_context_display_text  => l_context_display_text
                       ,p_dml_mode              => l_dml_mode
                       );
  commit;
exception
  when others then
    If csr_user_id%isopen
    then
      close csr_user_id;
    end if;
    raise;
end reject_for_correction;
-- ----------------------------------------------------------------------------
-- |-----------------------< reject_for_correction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure reject_for_correction
              (p_transaction_id  IN hr_wip_transactions.transaction_id%TYPE
              )is
PRAGMA AUTONOMOUS_TRANSACTION;
l_state hr_wip_transactions.state%TYPE;
l_dml_mode hr_wip_transactions.dml_mode%TYPE;
l_context_display_text hr_wip_transactions.context_display_text%TYPE;
l_vo_xml clob;
cursor csr_user_id is
            select state,
                   vo_cache,
                   dml_mode,
                   context_display_text
              from hr_wip_transactions
             where transaction_id = p_transaction_id;
begin
  open csr_user_id;
  fetch csr_user_id into l_state,
                         l_vo_xml,
                         l_dml_mode,
                         l_context_display_text;
  if csr_user_id%NOTFOUND THEN
    close csr_user_id;
    fnd_message.set_name('PER','PER_289671_TXN_INV');
    fnd_message.raise_error;
  end if;
  close csr_user_id;
  reject_for_correction(p_transaction_id          => p_transaction_id
                         ,p_state                 => l_state
                         ,p_vo_xml                => l_vo_xml
                         ,p_sub_state             => null
                         ,p_context_display_text  => l_context_display_text
                         ,p_dml_mode              => l_dml_mode
                       );
  commit;
exception
  when others then
    If csr_user_id%isopen
    then
      close csr_user_id;
    end if;
    raise;
end reject_for_correction;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_transaction
              (p_item_type             IN wf_items.item_type%TYPE
              ,p_item_key              IN wf_items.item_key%TYPE
              )is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_transaction_id hr_wip_transactions.transaction_id%TYPE;
  cursor csr_transaction is
    select transaction_id
      from hr_wip_transactions
     where item_type = p_item_type
       and  item_key = p_item_key;
begin
--
  chk_item_type_item_key_mand
            (p_item_type => p_item_type
            ,p_item_key  => p_item_key
            );

  open csr_transaction;
  fetch csr_transaction into l_transaction_id;
  If csr_transaction%notfound
  then
    close csr_transaction;
    fnd_message.set_name('PER','PER_289680_TXN_INV_WFL');
    fnd_message.raise_error;
  End if;
  close csr_transaction;
--
  delete from hr_wip_locks
  where transaction_id = l_transaction_id;
--
  delete from hr_wip_transactions
  where transaction_id = l_transaction_id;
--
  commit;
exception
  when others then
    If csr_transaction%isopen
    then
      close csr_transaction;
    end if;
    raise;
end delete_transaction;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_transaction
             (p_transaction_id        IN hr_wip_transactions.transaction_id%TYPE
             )is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_transaction_id varchar2(1);
  cursor csr_transaction is
    select null
      from hr_wip_transactions
     where transaction_id = p_transaction_id;
begin
--
  open csr_transaction;
  fetch csr_transaction into l_transaction_id;
  If csr_transaction%notfound
  then
    close csr_transaction;
    fnd_message.set_name('PER','PER_289671_TXN_INV');
    fnd_message.raise_error;
  End if;
  close csr_transaction;
  delete from hr_wip_locks
  where transaction_id = p_transaction_id;
--
  delete from hr_wip_transactions
  where transaction_id = p_transaction_id;
--
  commit;
exception
  when others then
    If csr_transaction%isopen
    then
      close csr_transaction;
    end if;
    raise;
end delete_transaction;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure update_transaction
     (p_item_type            IN wf_items.item_type%TYPE
     ,p_item_key             IN wf_items.item_key%TYPE
     ,p_state                IN hr_wip_transactions.state%TYPE
     ,p_sub_state            IN hr_wip_transactions.sub_state%TYPE
     ,p_dml_mode             IN hr_wip_transactions.dml_mode%TYPE
                                default hr_api.g_varchar2
     ,p_vo_xml               IN VARCHAR2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                                default hr_api.g_varchar2
     )is
PRAGMA AUTONOMOUS_TRANSACTION;
l_transaction_id hr_wip_transactions.transaction_id%TYPE;
l_dml_mode hr_wip_transactions.dml_mode%TYPE;
l_context_display_text hr_wip_transactions.context_display_text%TYPE;
cursor csr_transaction is
        select transaction_id
               ,dml_mode
               ,context_display_text
          from hr_wip_transactions
         where item_type = p_item_type
           and item_key  = p_item_key;
begin
  chk_item_type_item_key_mand
            (p_item_type => p_item_type
            ,p_item_key  => p_item_key
            );
  chk_item_type_item_key_exists(p_item_type => p_item_type
    			       ,p_item_key  => p_item_key
  			       );
  open csr_transaction;
  fetch csr_transaction into l_transaction_id,
                             l_dml_mode,
                             l_context_display_text;
  If csr_transaction%notfound
    then
      close csr_transaction;
      fnd_message.set_name('PER','PER_289680_TXN_INV_WFL');
      fnd_message.raise_error;
    End if;
  close csr_transaction;
  chk_state(p_state => p_state);
  chk_sub_state(p_state     => p_state
               ,p_sub_state => p_sub_state
               );
  upd(p_transaction_id       => l_transaction_id
     ,p_state                => p_state
     ,p_sub_state            => p_sub_state
     ,p_vo_xml               => p_vo_xml
     ,p_context_display_text =>
                         get_context_display_text
                         (p_new_context_display_text => p_context_display_text
                         ,p_old_context_display_text => l_context_display_text
                         )
     ,p_dml_mode             =>
                         get_and_chk_and_ret_dml_mode
                         (p_new_dml_mode => p_dml_mode
                         ,p_old_dml_mode => l_dml_mode
                         )
     );
  commit;
exception
  when others then
    If csr_transaction%isopen
    then
      close csr_transaction;
    end if;
    raise;
end update_transaction;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure update_transaction
     (p_transaction_id       IN hr_wip_transactions.transaction_id%TYPE
     ,p_state                IN hr_wip_transactions.state%TYPE
     ,p_sub_state            IN hr_wip_transactions.sub_state%TYPE
     ,p_dml_mode             IN hr_wip_transactions.dml_mode%TYPE
                                default hr_api.g_varchar2
     ,p_vo_xml               IN VARCHAR2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                                default hr_api.g_varchar2
     )is
PRAGMA AUTONOMOUS_TRANSACTION;
l_dml_mode hr_wip_transactions.dml_mode%TYPE;
l_context_display_text hr_wip_transactions.context_display_text%TYPE;
  cursor csr_transaction is
    select dml_mode,
           context_display_text
      from hr_wip_transactions
     where transaction_id = p_transaction_id;
begin
  chk_state(p_state => p_state);
  chk_sub_state(p_state     => p_state
               ,p_sub_state => p_sub_state
               );
  open csr_transaction;
  fetch csr_transaction into l_dml_mode,
                             l_context_display_text;
  If csr_transaction%notfound
  then
    close csr_transaction;
    fnd_message.set_name('PER','PER_289671_TXN_INV');
    fnd_message.raise_error;
  End if;
  close csr_transaction;
  upd(p_transaction_id       => p_transaction_id
     ,p_state                => p_state
     ,p_sub_state            => p_sub_state
     ,p_vo_xml               => p_vo_xml
     ,p_context_display_text =>
                         get_context_display_text
                         (p_new_context_display_text => p_context_display_text
                         ,p_old_context_display_text => l_context_display_text)
     ,p_dml_mode             =>
                         get_and_chk_and_ret_dml_mode
                         (p_new_dml_mode => p_dml_mode
                         ,p_old_dml_mode => l_dml_mode)
     );
  commit;
exception
  when others then
    If csr_transaction%isopen
    then
      close csr_transaction;
    end if;
    raise;
end update_transaction;
--
--
END hr_wip_txns;

/
