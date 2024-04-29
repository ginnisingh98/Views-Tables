--------------------------------------------------------
--  DDL for Package Body PAY_BATCH_OBJECT_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BATCH_OBJECT_STATUS_PKG" AS
/* $Header: pybos.pkb 120.2 2006/09/27 17:44:31 thabara noship $ */

--
-- ----------------------------------------------------------------------------
-- get_status
--
-- Returns the status of the specified object.
-- ----------------------------------------------------------------------------
function get_status
  (p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ) return varchar2
is
  cursor csr_obj
  is
  select
     bos.object_status
  from
    pay_batch_object_status bos
  where
      bos.object_type = p_object_type
  and bos.object_id   = p_object_id
  ;
  l_object_status       pay_batch_object_status.object_status%type;
begin
  open csr_obj;
  fetch csr_obj into l_object_status;
  close csr_obj;
  --
  return l_object_status;

end get_status;
--
-- ----------------------------------------------------------------------------
-- get_status_meaning
--
-- Returns the status meaning of the specified object.
-- ----------------------------------------------------------------------------
function get_status_meaning
  (p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_default_status               in     varchar2 default null
  ) return varchar2
is
  l_object_status       pay_batch_object_status.object_status%type;
begin
  --
  l_object_status := nvl(get_status(p_object_type, p_object_id)
                        ,p_default_status);
  --
  return hr_general.decode_lookup('ACTION_STATUS', l_object_status);

end get_status_meaning;
--
-- ----------------------------------------------------------------------------
-- lock_batch_object_internal
--
-- Locks the object record. If the caller is not the owner payroll action
-- and the object is being processed, this will raise an error.
--
-- ----------------------------------------------------------------------------
procedure lock_batch_object_internal
  (p_object_type                  in            varchar2
  ,p_object_id                    in            number
  ,p_payroll_action_id            in            number   default null
  ,p_object_status                   out nocopy varchar2
  )
is
  cursor csr_obj
  is
  select
     bos.object_status
    ,bos.payroll_action_id
  from
    pay_batch_object_status bos
  where
      bos.object_type = p_object_type
  and bos.object_id   = p_object_id
  for update nowait
  ;
  --
  cursor csr_ppa(p_pact_id number)
  is
  select 1
  from  pay_payroll_actions
  where payroll_action_id = p_pact_id
  ;
  --
  l_rec                     csr_obj%rowtype;
  l_dummy                   number;
  l_object_name             hr_lookups.meaning%type;
  --
begin
  --
  open csr_obj;
  fetch csr_obj into l_rec;
  if csr_obj%found then
    close csr_obj;
    --
    -- Check if the object is being processed by another process.
    --
    if l_rec.payroll_action_id <> nvl(p_payroll_action_id, -99999) then

      --
      -- Check if it is being processed.
      --
      if l_rec.object_status = 'P' then
        --
        -- Ensure if the processing payroll action exists.
        --
        open csr_ppa(l_rec.payroll_action_id);
        fetch csr_ppa into l_dummy;
        if csr_ppa%found then
          close csr_ppa;
          --
          l_object_name
            := hr_general.decode_lookup('PAY_BATCH_OBJECT_TYPE', p_object_type);
          --
          -- You cannot lock the object that is being processed
          -- by another batch process.
          --
          hr_utility.set_message(801, 'PAY_33446_BAT_OBJ_LOCKED');
          hr_utility.set_message_token('OBJECT_NAME', l_object_name);
          hr_utility.raise_error;
        end if;
        close csr_ppa;
      end if;
    end if;
  else
    close csr_obj;
  end if;

  --
  -- Set out variables
  --
  p_object_status        := l_rec.object_status;
  --
end lock_batch_object_internal;
--
-- ----------------------------------------------------------------------------
-- lock_batch_object
--
-- Locks the object status record.
-- If p_object_status is specified, see if the status is up to date.
-- If the batch object does not exist, the default status will be used instead.
--
-- NOTE: This should be called from a generic interface ie Forms instead of
--       a payroll process.
-- ----------------------------------------------------------------------------
procedure lock_batch_object
  (p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_object_status                in     varchar2 default null
  ,p_default_status               in     varchar2 default null
  )
is
  l_object_status                 pay_batch_object_status.object_status%type;
begin
  --
  -- Lock the batch object.
  --
  lock_batch_object_internal
    (p_object_type         => p_object_type
    ,p_object_id           => p_object_id
    ,p_payroll_action_id   => null
    ,p_object_status       => l_object_status
    );
  --
  -- Compare the status if p_object_status is specified.
  --
  if p_object_status is not null then
    --
    if (p_object_status = nvl(l_object_status, p_default_status)) then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
  end if;

end lock_batch_object;
--
-- ----------------------------------------------------------------------------
-- chk_complete_status
--
-- Locks the object record and see if the status is complete.
-- ----------------------------------------------------------------------------
procedure chk_complete_status
  (p_object_type                  in            varchar2
  ,p_object_id                    in            number
  )
is
  l_object_status           pay_batch_object_status.object_status%type;
  l_object_name             hr_lookups.meaning%type;
begin
  --
  -- Lock the batch object.
  --
  lock_batch_object_internal
    (p_object_type         => p_object_type
    ,p_object_id           => p_object_id
    ,p_payroll_action_id   => null
    ,p_object_status       => l_object_status
    );
  --
  -- Raise an error if the status is not complete.
  --
  if l_object_status <> 'C' then
    --
    l_object_name
      := hr_general.decode_lookup('PAY_BATCH_OBJECT_TYPE', p_object_type);
    --
    hr_utility.set_message(801, 'PAY_33447_BAT_OBJ_INCOMP');
    hr_utility.set_message_token('OBJECT_NAME', l_object_name);
    hr_utility.raise_error;
  end if;

end chk_complete_status;
--
-- ----------------------------------------------------------------------------
-- set_status
--
-- Sets the object status.
-- ----------------------------------------------------------------------------
procedure set_status
  (p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_object_status                in     varchar2
  ,p_payroll_action_id            in     number   default null
  )
is
  l_object_status                 pay_batch_object_status.object_status%type;
begin
  --
  -- Note: In order to lock a batch object with a payroll action,
  --       the same payroll_action_id has to be specified.
  --

  --
  -- Lock the batch object.
  --
  lock_batch_object_internal
    (p_object_type         => p_object_type
    ,p_object_id           => p_object_id
    ,p_payroll_action_id   => p_payroll_action_id
    ,p_object_status       => l_object_status
    );

  if l_object_status is not null then

    --
    -- Update the batch object status.
    --
    update pay_batch_object_status
    set object_status     = p_object_status
       ,payroll_action_id = p_payroll_action_id
    where
        object_type = p_object_type
    and object_id   = p_object_id;

  else
    --
    -- Insert a new row.
    --
    insert into pay_batch_object_status
      (object_type
      ,object_id
      ,object_status
      ,payroll_action_id
      )
      values
        (p_object_type
        ,p_object_id
        ,p_object_status
        ,p_payroll_action_id
        );
  end if;
end set_status;
--
-- ----------------------------------------------------------------------------
-- delete_object_status
--
-- Deletes the object status record.
-- ----------------------------------------------------------------------------
procedure delete_object_status
  (p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_payroll_action_id            in     number default null
  )
is
  l_object_status                 pay_batch_object_status.object_status%type;
begin
  --
  -- Lock the batch object.
  --
  lock_batch_object_internal
    (p_object_type         => p_object_type
    ,p_object_id           => p_object_id
    ,p_payroll_action_id   => p_payroll_action_id
    ,p_object_status       => l_object_status
    );

  delete from pay_batch_object_status
  where
      object_type = p_object_type
  and object_id   = p_object_id;

end delete_object_status;
--
-------------------------------------------------------------------------------

end pay_batch_object_status_pkg;

/
