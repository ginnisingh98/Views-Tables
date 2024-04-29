--------------------------------------------------------
--  DDL for Package HXC_LOCK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_LOCK_API" AUTHID CURRENT_USER AS
/* $Header: hxclockapi.pkh 115.1 2003/08/14 17:31:23 jdupont noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------------< request_lock          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE request_lock
         (p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN NUMBER DEFAULT NULL
         ,p_start_time			IN DATE DEFAULT NULL
         ,p_stop_time 			IN DATE DEFAULT NULL
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_transaction_lock_id		IN NUMBER DEFAULT NULL
         ,p_expiration_time		IN NUMBER DEFAULT hxc_lock_util.c_ss_expiration_time
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_row_lock_id			IN OUT NOCOPY ROWID
         ,p_locked_success		OUT NOCOPY BOOLEAN
         );

-- ----------------------------------------------------------------------------
-- |---------------------------< request_lock          > ----------------------|
-- ----------------------------------------------------------------------------
-- this request lock is going to be used in SS
-- locked success is in varchar.
PROCEDURE request_lock
         (p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN NUMBER DEFAULT NULL
         ,p_start_time			IN DATE DEFAULT NULL
         ,p_stop_time 			IN DATE DEFAULT NULL
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_transaction_lock_id		IN NUMBER DEFAULT NULL
         ,p_expiration_time		IN NUMBER DEFAULT hxc_lock_util.c_ss_expiration_time
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_row_lock_id			IN OUT NOCOPY ROWID
         ,p_locked_success		OUT NOCOPY VARCHAR2
         );

-- ----------------------------------------------------------------------------
-- |---------------------------< request_lock          > ----------------------|
-- ----------------------------------------------------------------------------
-- this request lock is going to be used in timekeeper
-- forms since we cannot passed the HXC_MESSAGE_TABLE_TYPE
-- as a type
PROCEDURE request_lock
         (p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN NUMBER DEFAULT NULL
         ,p_start_time			IN DATE DEFAULT NULL
         ,p_stop_time 			IN DATE DEFAULT NULL
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_transaction_lock_id		IN NUMBER DEFAULT NULL
         ,p_expiration_time		IN NUMBER DEFAULT hxc_lock_util.c_ss_expiration_time
         ,p_messages			IN OUT NOCOPY hxc_self_service_time_deposit.message_table
         ,p_row_lock_id			IN OUT NOCOPY ROWID
         ,p_locked_success		OUT NOCOPY BOOLEAN
         );

-- ----------------------------------------------------------------------------
-- |---------------------------< check_lock          > ----------------------|
-- ----------------------------------------------------------------------------
-- if p_row_id is not null then
-- the message table will be populated
PROCEDURE check_lock
         (p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN OUT NOCOPY NUMBER
         ,p_start_time			IN OUT NOCOPY DATE
         ,p_stop_time 			IN OUT NOCOPY DATE
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_timecard_locked		OUT NOCOPY BOOLEAN
         ,p_time_building_block_scope   OUT NOCOPY VARCHAR2
         ,p_process_locker_type_id      OUT NOCOPY NUMBER
         );

-- ----------------------------------------------------------------------------
-- |---------------------------< check_lock          > ----------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_lock (p_row_lock_id	IN ROWID)
	 RETURN BOOLEAN;


-- ----------------------------------------------------------------------------
-- |---------------------------< check_lock          > ----------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_lock
         (p_process_locker_type        	IN VARCHAR2
         ,p_transaction_lock_id         IN NUMBER
         ,p_resource_id			IN NUMBER)
         RETURN ROWID;
-- ----------------------------------------------------------------------------
-- |---------------------------< check_lock          > ----------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_lock
         (p_row_lock_id			IN ROWID
         ,p_resource_id			IN NUMBER
         ,p_start_time			IN DATE
         ,p_stop_time 			IN DATE)
         RETURN BOOLEAN;
-- ----------------------------------------------------------------------------
-- |---------------------------< release_lock          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE release_lock
         (p_row_lock_id			IN ROWID
         ,p_process_locker_type        	IN VARCHAR2
         ,p_transaction_lock_id         IN NUMBER DEFAULT NULL
         ,p_released_success		OUT NOCOPY BOOLEAN
        );

-- ----------------------------------------------------------------------------
-- |---------------------------< release_lock          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE release_lock
         (p_row_lock_id			IN ROWID);


-- ----------------------------------------------------------------------------
-- |---------------------------< release_lock          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE release_lock
         (p_row_lock_id			IN ROWID
         ,p_process_locker_type        	IN VARCHAR2
         ,p_transaction_lock_id         IN NUMBER DEFAULT NULL
         ,p_resource_id			IN NUMBER DEFAULT NULL
         ,p_start_time			IN DATE DEFAULT NULL
         ,p_stop_time 			IN DATE DEFAULT NULL
         ,p_time_building_block_id 	IN NUMBER DEFAULT NULL
         ,p_time_building_block_ovn 	IN NUMBER DEFAULT NULL
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_released_success		OUT NOCOPY BOOLEAN
        );


END HXC_LOCK_API;

 

/
