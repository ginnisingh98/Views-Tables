--------------------------------------------------------
--  DDL for Package HR_WIP_LCKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WIP_LCKS" 
/* $Header: hrwiplck.pkh 115.1 2002/12/10 10:21:11 raranjan ship $ */
AUTHID CURRENT_USER AS
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
         );
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
     );
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
     );
--
END hr_wip_lcks;

 

/
