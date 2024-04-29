--------------------------------------------------------
--  DDL for Package Body HR_WIP_LCKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WIP_LCKS" 
/* $Header: hrwiplck.pkb 115.4 2002/12/10 10:21:23 raranjan ship $ */
AS
--
  g_start_state                 VARCHAR2(5)  := 'START';
  g_query_only_dml_mode         VARCHAR2(10) := 'QUERY_ONLY';
-- ------------------------------------------------------------------------------
-- |-----------------------< chk_lock >-----------------------|
-- ------------------------------------------------------------------------------
Procedure chk_lock
            (p_transaction_id          IN hr_wip_locks.transaction_id%TYPE
            ,p_current_user_id         IN fnd_user.user_id%TYPE
             )is
  l_state hr_wip_transactions.state%TYPE;
  l_dml_mode hr_wip_transactions.dml_mode%TYPE;
  cursor csr_state is
          select state,dml_mode
            from hr_wip_transactions
           where transaction_id = p_transaction_id;
begin
  open csr_state;
  fetch csr_state into l_state,l_dml_mode;
  If csr_state%notfound
  then
    close csr_state;
    fnd_message.set_name('PER','PER_289671_TXN_INV');
    fnd_message.raise_error;
  End if;
  close csr_state;
  If l_state <> g_start_state
  then
    fnd_message.set_name('PER','PER_289677_LCK_NOT_SAVE');
    fnd_message.raise_error;
  End if;
--
  If l_dml_mode = g_query_only_dml_mode
  then
    fnd_message.set_name('PER','PER_289678_LCK_NOT_QUERY');
    fnd_message.raise_error;
  End if;
exception
  when others then
    If csr_state%isopen
    then
      close csr_state;
    end if;
    raise;
end chk_lock;
--
-- ------------------------------------------------------------------------------
-- |-----------------------< ins >-----------------------|
-- ------------------------------------------------------------------------------
Procedure ins
  (p_transaction_id          IN hr_wip_transactions.transaction_id%TYPE
  ,p_table_name              IN hr_wip_locks.table_name%TYPE
  ,p_primary_key_val1        IN hr_wip_locks.primary_key_val1%TYPE
  ,p_primary_key_val2        IN hr_wip_locks.primary_key_val2%TYPE
  ,p_primary_key_val3        IN hr_wip_locks.primary_key_val3%TYPE
  ,p_primary_key_val4        IN hr_wip_locks.primary_key_val4%TYPE
  ,p_primary_key_val5        IN hr_wip_locks.primary_key_val5%TYPE
  ,p_commit                  IN BOOLEAN
  ,p_lock_id                 OUT NOCOPY hr_wip_locks.lock_id%TYPE
  ,p_locked                  OUT NOCOPY VARCHAR2
  ,p_locking_transaction_id  OUT NOCOPY hr_wip_transactions.transaction_id%TYPE
  ,p_locking_lock_id         OUT NOCOPY hr_wip_locks.lock_id%TYPE
  )is
  l_lock_id hr_wip_locks.lock_id%TYPE;
  l_err_msg varchar2(240);
  l_locked varchar2(1);
  l_locking_id hr_wip_locks.lock_id%TYPE;
  l_locking_trans_id hr_wip_transactions.transaction_id%TYPE;
  L_START_TOK_VAL constant number := 12;
begin
  insert into hr_wip_locks
  (lock_id
  ,transaction_id
  ,table_name
  ,primary_key_val1
  ,primary_key_val2
  ,primary_key_val3
  ,primary_key_val4
  ,primary_key_val5)
  VALUES
  (hr_wip_locks_s.nextval
  ,p_transaction_id
  ,p_table_name
  ,p_primary_key_val1
  ,p_primary_key_val2
  ,p_primary_key_val3
  ,p_primary_key_val4
  ,p_primary_key_val5)returning lock_id into l_lock_id;
  If p_commit
  then
    p_lock_id := l_lock_id;
    p_locked  := null;
    p_locking_transaction_id := null;
    p_locking_lock_id := null;
  End if;
exception
  when dup_val_on_index then
    l_err_msg := trim(substr(sqlerrm,L_START_TOK_VAL));
    If instr(l_err_msg,'HR_WIP_LOCKS_U1') <> 0
    then
      fnd_message.set_name('PER','PER_289679_LCK_ID_UNIQUE');
      fnd_message.raise_error;
    Elsif instr(l_err_msg,'HR_WIP_LOCKS_U2') <> 0
    then
      check_for_lock
           (p_table_name              => p_table_name
           ,p_primary_key_val1        => p_primary_key_val1
           ,p_primary_key_val2        => p_primary_key_val2
           ,p_primary_key_val3        => p_primary_key_val3
           ,p_primary_key_val4        => p_primary_key_val4
           ,p_primary_key_val5        => p_primary_key_val5
           ,p_locked                  => l_locked
           ,p_locking_lock_id         => l_locking_id
           ,p_locking_transaction_id  => l_locking_trans_id
           );
       If l_locked = 'Y'
       then
         If p_transaction_id = l_locking_trans_id
         then
           p_lock_id := l_locking_id;
           p_locked  := 'N';
           p_locking_transaction_id := null;
           p_locking_lock_id := null;
         Else
           p_lock_id := null;
	   p_locked  := 'Y';
	   p_locking_transaction_id := l_locking_trans_id;
           p_locking_lock_id := l_locking_id;
         End if;
       Else  -- if l_locked is N
         raise;
       End if;
    Else  -- other than constraint error occurs raise the error
      raise;
    End if;
end ins;
--
-- ------------------------------------------------------------------------------
-- |-----------------------< create_lock >-----------------------|
-- ------------------------------------------------------------------------------
Procedure create_lock
         (p_transaction_id          IN hr_wip_locks.transaction_id%TYPE
         ,p_current_user_id         IN fnd_user.user_id%TYPE
         ,p_table_name              IN hr_wip_locks.table_name%TYPE
         ,p_primary_key_val1        IN hr_wip_locks.primary_key_val1%TYPE
         ,p_primary_key_val2        IN hr_wip_locks.primary_key_val2%TYPE
         ,p_primary_key_val3        IN hr_wip_locks.primary_key_val3%TYPE
         ,p_primary_key_val4        IN hr_wip_locks.primary_key_val4%TYPE
         ,p_primary_key_val5        IN hr_wip_locks.primary_key_val5%TYPE
         ,p_lock_id                 OUT NOCOPY hr_wip_locks.lock_id%TYPE
         ,p_locked                  OUT NOCOPY VARCHAR2
         ,p_locking_transaction_id  OUT NOCOPY hr_wip_transactions.transaction_id%TYPE
         ,p_locking_lock_id         OUT NOCOPY hr_wip_locks.lock_id%TYPE
         )is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_lock_id hr_wip_locks.lock_id%TYPE;
  l_locked varchar2(1);
  l_locking_tran_id hr_wip_locks.transaction_id%TYPE;
  l_locking_lock_id hr_wip_locks.lock_id%TYPE;
begin
  chk_lock
        (p_transaction_id    => p_transaction_id
        ,p_current_user_id   => p_current_user_id
        );
--
  ins
    (p_transaction_id          => p_transaction_id
    ,p_table_name              => p_table_name
    ,p_primary_key_val1        => p_primary_key_val1
    ,p_primary_key_val2        => p_primary_key_val2
    ,p_primary_key_val3        => p_primary_key_val3
    ,p_primary_key_val4        => p_primary_key_val4
    ,p_primary_key_val5        => p_primary_key_val5
    ,p_commit                  => true
    ,p_lock_id                 => l_lock_id
    ,p_locked                  => l_locked
    ,p_locking_transaction_id  => l_locking_tran_id
    ,p_locking_lock_id         => l_locking_lock_id
    );
    If l_locked is null
    then
      commit;
    End if;
--
    If l_locked = 'Y'
    then
      p_locked := 'Y';
      p_lock_id := null;
      p_locking_transaction_id := l_locking_tran_id;
      p_locking_lock_id := l_locking_lock_id;
    else
      p_locked := 'N';
      p_lock_id := l_lock_id;
      p_locking_transaction_id := null;
      p_locking_lock_id := null;
    End if;
end create_lock;
--
-- ------------------------------------------------------------------------------
-- |-----------------------< check_for_lock >-----------------------|
-- ------------------------------------------------------------------------------
Procedure check_for_lock
     (p_transaction_id         IN hr_wip_locks.transaction_id%TYPE
     ,p_table_name             IN hr_wip_locks.table_name%TYPE
     ,p_primary_key_val1       IN hr_wip_locks.primary_key_val1%TYPE
     ,p_primary_key_val2       IN hr_wip_locks.primary_key_val2%TYPE
     ,p_primary_key_val3       IN hr_wip_locks.primary_key_val3%TYPE
     ,p_primary_key_val4       IN hr_wip_locks.primary_key_val4%TYPE
     ,p_primary_key_val5       IN hr_wip_locks.primary_key_val5%TYPE
     ,p_locked                 OUT NOCOPY VARCHAR2
     ,p_locking_lock_id        OUT NOCOPY hr_wip_locks.lock_id%TYPE
     ,p_locking_transaction_id OUT NOCOPY hr_wip_locks.transaction_id%TYPE
     )is
  l_trans_id hr_wip_locks.transaction_id%TYPE;
  l_lock_id hr_wip_locks.lock_id%TYPE;
  cursor csr_lock is
     select lck.transaction_id,
            lck.lock_id
     from   hr_wip_locks lck
     where  lck.transaction_id  <> p_transaction_id
     and    lck.table_name       = p_table_name
     and    lck.primary_key_val1 = p_primary_key_val1
     and  ((lck.primary_key_val2 = p_primary_key_val2)
     or    (lck.primary_key_val2 is null and p_primary_key_val2 is null))
     and  ((lck.primary_key_val3 = p_primary_key_val3)
     or    (lck.primary_key_val3 is null and p_primary_key_val3 is null))
     and  ((lck.primary_key_val4 = p_primary_key_val4)
     or    (lck.primary_key_val4 is null and p_primary_key_val4 is null))
     and  ((lck.primary_key_val5 = p_primary_key_val5)
     or    (lck.primary_key_val5 is null and p_primary_key_val5 is null));
begin
  open csr_lock;
  fetch csr_lock into l_trans_id,l_lock_id;
  If csr_lock%notfound then
    p_locked := 'N';
    p_locking_transaction_id := null;
    p_locking_lock_id := null;
  Else
    p_locked := 'Y';
    p_locking_transaction_id := l_trans_id;
    p_locking_lock_id := l_lock_id;
  End if;
  close csr_lock;
exception
  when others then
    If csr_lock%isopen
    then
      close csr_lock;
    end if;
    raise;
end check_for_lock;
--
-- ------------------------------------------------------------------------------
-- |-----------------------< check_for_lock >-----------------------|
-- ------------------------------------------------------------------------------
Procedure check_for_lock
     (p_table_name             IN hr_wip_locks.table_name%TYPE
     ,p_primary_key_val1       IN hr_wip_locks.primary_key_val1%TYPE
     ,p_primary_key_val2       IN hr_wip_locks.primary_key_val2%TYPE
     ,p_primary_key_val3       IN hr_wip_locks.primary_key_val3%TYPE
     ,p_primary_key_val4       IN hr_wip_locks.primary_key_val4%TYPE
     ,p_primary_key_val5       IN hr_wip_locks.primary_key_val5%TYPE
     ,p_locked                 OUT NOCOPY VARCHAR2
     ,p_locking_lock_id        OUT NOCOPY hr_wip_locks.lock_id%TYPE
     ,p_locking_transaction_id OUT NOCOPY hr_wip_locks.transaction_id%TYPE
     )is
  l_trans_id hr_wip_locks.transaction_id%TYPE;
  l_lock_id hr_wip_locks.lock_id%TYPE;
  cursor csr_lock is
  select lck.transaction_id,
         lck.lock_id
    from   hr_wip_locks lck
   where  lck.table_name       = p_table_name
     and    lck.primary_key_val1 = p_primary_key_val1
     and  ((lck.primary_key_val2 = p_primary_key_val2)
      or    (lck.primary_key_val2 is null and p_primary_key_val2 is null))
     and  ((lck.primary_key_val3 = p_primary_key_val3)
      or    (lck.primary_key_val3 is null and p_primary_key_val3 is null))
     and  ((lck.primary_key_val4 = p_primary_key_val4)
      or    (lck.primary_key_val4 is null and p_primary_key_val4 is null))
     and  ((lck.primary_key_val5 = p_primary_key_val5)
      or    (lck.primary_key_val5 is null and p_primary_key_val5 is null));
begin
  open csr_lock;
  fetch csr_lock into l_trans_id,l_lock_id;
  If csr_lock%notfound then
    p_locked := 'N';
    p_locking_transaction_id := null;
    p_locking_lock_id := null;
  Else
    p_locked := 'Y';
    p_locking_transaction_id := l_trans_id;
    p_locking_lock_id := l_lock_id;
  End if;
  close csr_lock;
exception
  when others then
    If csr_lock%isopen
    then
      close csr_lock;
    end if;
    raise;
end check_for_lock;
--
END hr_wip_lcks;

/
