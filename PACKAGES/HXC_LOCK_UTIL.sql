--------------------------------------------------------
--  DDL for Package HXC_LOCK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_LOCK_UTIL" AUTHID CURRENT_USER AS
/* $Header: hxclockutil.pkh 120.1 2005/07/25 13:41:09 jdupont noship $ */

c_self_service           CONSTANT VARCHAR2(20) := 'SELF_SERVICE';
c_pui	                 CONSTANT VARCHAR2(20) := 'PUI';
c_plsql                  CONSTANT VARCHAR2(20) := 'PLSQL';
c_timecard_action        CONSTANT VARCHAR2(20) := 'TIMECARD_ACTION';
c_timecard_view          CONSTANT VARCHAR2(20) := 'TIMECARD_VIEW';
c_approval_action        CONSTANT VARCHAR2(20) := 'APPROVAL_ACTION';
c_timekeeper_action      CONSTANT VARCHAR2(20) := 'TIMEKEEPER_ACTION';
c_pa_retrieval_action       CONSTANT VARCHAR2(20) := 'PA_RETRIEVAL_ACTION';
c_pay_retrieval_action       CONSTANT VARCHAR2(20) := 'PAY_RETRIEVAL_ACTION';
c_eam_retrieval_action       CONSTANT VARCHAR2(20) := 'EAM_RETRIEVAL_ACTION';
c_po_retrieval_action       CONSTANT VARCHAR2(20) := 'PO_RETRIEVAL_ACTION';
c_deposit_action       	 CONSTANT VARCHAR2(20) := 'DEPOSIT_ACTION';
c_coa_action		 CONSTANT VARCHAR2(20) := 'COA_ACTION';
c_ar_action CONSTANT VARCHAR2(30) := 'ARCHIVE_RESTORE_ACTION';


c_ss_timecard_action CONSTANT VARCHAR2(18) := 'SS_TIMECARD_ACTION';
c_ss_timecard_view   CONSTANT VARCHAR2(16) := 'SS_TIMECARD_VIEW';
c_ss_approval_action CONSTANT VARCHAR2(18) := 'SS_APPROVAL_ACTION';

c_pui_timekeeper_action CONSTANT VARCHAR2(21) := 'PUI_TIMEKEEPER_ACTION';

c_plsql_pay_retrieval_action CONSTANT VARCHAR2(80) := 'PLSQL_PAY_RETRIEVAL_ACTION';
c_plsql_pa_retrieval_action CONSTANT VARCHAR2(80) := 'PLSQL_PA_RETRIEVAL_ACTION';
c_plsql_eam_retrieval_action CONSTANT VARCHAR2(80) := 'PLSQL_EAM_RETRIEVAL_ACTION';
c_plsql_po_retrieval_action CONSTANT VARCHAR2(80) := 'PLSQL_PO_RETRIEVAL_ACTION';

c_plsql_deposit_action   CONSTANT VARCHAR2(20) := 'PLSQL_DEPOSIT_ACTION';
c_plsql_coa_action   CONSTANT VARCHAR2(20) := 'PLSQL_COA_ACTION';
c_plsql_ar_action   CONSTANT VARCHAR2(35) := 'PLSQL_ARCHIVE_RESTORE_ACTION';


c_ss_expiration_time	CONSTANT NUMBER := 10;
c_plsql_retrieval_time  CONSTANT NUMBER := 60;
c_pui_timekeeper_save_time CONSTANT NUMBER := 30;
c_pui_timekeeper_submit_time CONSTANT NUMBER := 60;
c_plsql_ar_time		 CONSTANT NUMBER := 60;

-- ----------------------------------------------------------------------------
-- |---------------------------< check_parameters          > ----------------------|
-- ----------------------------------------------------------------------------
-- if p_row_id is not null then
-- the message table will be populated
PROCEDURE check_parameters
         (p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN OUT NOCOPY NUMBER
         ,p_start_time			IN OUT NOCOPY DATE
         ,p_stop_time 			IN OUT NOCOPY DATE
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_time_scope			IN OUT NOCOPY VARCHAR2
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_passed_check                OUT NOCOPY BOOLEAN
         );

-- ----------------------------------------------------------------------------
-- |---------------------------< check_grant          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE check_grant(p_locker_type_owner_id 	 IN NUMBER
                     ,p_locker_type_requestor_id IN NUMBER
                     ,p_messages  	         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
                     ,p_grant_lock               OUT NOCOPY VARCHAR2);
/*
-- ----------------------------------------------------------------------------
-- |---------------------------< validate_lock          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE validate_lock
          (p_locker_type_owner_id 	 IN OUT NOCOPY NUMBER
          ,p_locker_type_requestor_id IN OUT NOCOPY NUMBER
          ,p_lock_date		      IN OUT NOCOPY DATE
          ,p_messages  	              IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
          ,p_valid_lock               IN OUT NOCOPY BOOLEAN);
*/
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_lock          > ----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE insert_lock (p_locker_type_id IN NUMBER
         	      ,p_resource_id	IN NUMBER
         	      ,p_start_time	IN DATE
         	      ,p_stop_time	IN DATE
         	      ,p_time_building_block_id  IN NUMBER
         	      ,p_time_building_block_ovn IN NUMBER
         	      ,p_transaction_lock_id	 IN NUMBER
                      ,p_expiration_time	 IN NUMBER
         	      ,p_row_lock_id             IN OUT NOCOPY ROWID);

-- ----------------------------------------------------------------------------
-- |---------------------------< delete_lock          > ----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE delete_lock(p_rowid               IN ROWID
                     ,p_locker_type_id      IN NUMBER
                     ,p_process_locker_type IN VARCHAR2
                     ,p_messages            IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE);


-- ----------------------------------------------------------------------------
-- |------------------------< delete_transaction_lock >  ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_transaction_lock
                     (p_transaction_lock_id IN NUMBER
                     ,p_process_locker_type IN VARCHAR2
                     ,p_messages            IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE);

--PROCEDURE delete_lock(p_rowid               IN ROWID);
-- ----------------------------------------------------------------------------
-- |---------------------------< get_locker_type_req_id > ----------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_locker_type_req_id
                     (p_process_locker_type      IN VARCHAR
                     ,p_messages  	         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE)
                     RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |---------------------------< checking_lock         > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE check_row_lock
         (p_locker_type_requestor_id    IN NUMBER
         ,p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN NUMBER
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_row_locked                  OUT NOCOPY BOOLEAN);
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_tbb_lock      > ----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE delete_tbb_lock (p_locker_type_id          IN NUMBER
          	          ,p_time_building_block_id  IN NUMBER
         	          ,p_time_building_block_ovn IN NUMBER);

-- ----------------------------------------------------------------------------
-- |---------------------------< delete_period_lock    > ----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE delete_period_lock
                      (p_locker_type_id   IN NUMBER
         	      ,p_resource_id	IN NUMBER
         	      ,p_start_time	IN DATE
         	      ,p_stop_time	IN DATE);


-- ----------------------------------------------------------------------------
-- |---------------------------< check_date_lock         > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE check_date_lock
         (p_locker_type_requestor_id    IN NUMBER
         ,p_locker_type_owner_id	IN NUMBER
         ,p_process_locker_type        	IN VARCHAR2
         ,p_lock_date		 	IN DATE
         ,p_lock_start_time             IN DATE
         ,p_lock_stop_time              IN DATE
         ,p_start_time			IN DATE
         ,p_stop_time			IN DATE
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn     IN NUMBER
         ,p_resource_id 		IN NUMBER
         ,p_process_id			IN NUMBER
         ,p_attribute2			IN VARCHAR2
         ,p_rowid			IN ROWID
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_row_locked                  OUT NOCOPY BOOLEAN) ;


END HXC_LOCK_UTIL;

 

/
