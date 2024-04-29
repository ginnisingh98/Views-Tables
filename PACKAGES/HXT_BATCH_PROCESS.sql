--------------------------------------------------------
--  DDL for Package HXT_BATCH_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_BATCH_PROCESS" AUTHID CURRENT_USER AS
/* $Header: hxtbat.pkh 120.4.12010000.3 2010/04/13 12:03:34 asrajago ship $ */

g_user_id fnd_user.user_id%TYPE := FND_GLOBAL.User_Id; -- SPR C163 by BC


-- Bug 8888777
-- Added global variables for IV processing.
g_IV_upgrade    VARCHAR2(30);
g_IV_format     VARCHAR2(50);
g_XIV_TABLE  HXT_OTC_RETRIEVAL_INTERFACE.IV_TABLE;



--
/********Bug: 4620315 **********/

TYPE merge_batches_type_rec IS RECORD (batch_id			pay_batch_headers.batch_id%TYPE,
				       tc_id			hxt_timecards_f.id%TYPE,
				       valid_tc_retcode		number,
				       tc_rowid			varchar2(500),
				       for_person_id		hxt_timecards_f.for_person_id%TYPE,
				       time_period_id		hxt_timecards_f.time_period_id%TYPE,
				       auto_gen_flag		hxt_timecards_f.auto_gen_flag%TYPE,
				       approv_person_id		hxt_timecards_f.approv_person_id%TYPE,
				       approved_timestamp	hxt_timecards_f.approved_timestamp%TYPE,
				       created_by		hxt_timecards_f.created_by%TYPE,
				       creation_date		hxt_timecards_f.creation_date%TYPE,
				       last_updated_by		hxt_timecards_f.last_updated_by%TYPE,
				       last_update_date		hxt_timecards_f.last_update_date%TYPE,
				       last_update_login	hxt_timecards_f.last_update_login%TYPE,
				       payroll_id		hxt_timecards_f.payroll_id%TYPE,
				       status			hxt_timecards_f.status%TYPE,
				       effective_start_date	hxt_timecards_f.effective_start_date%TYPE,
				       effective_end_date	hxt_timecards_f.effective_end_date%TYPE,
				       object_version_number	hxt_timecards_f.object_version_number%TYPE
				      );      /*** To record the validated timecards details ***/

TYPE merge_batches_type_table IS TABLE OF merge_batches_type_rec
INDEX BY BINARY_INTEGER;

TYPE del_empty_batches_type_rec IS RECORD (batch_id	pay_batch_headers.batch_id%TYPE,
					   batch_ovn    pay_batch_headers.object_version_number%TYPE
					  );   /*** To record the empty batches detail ***/

TYPE del_empty_batches_type_table IS TABLE OF del_empty_batches_type_rec
INDEX BY BINARY_INTEGER;

FUNCTION merge_batches
   RETURN fnd_profile_option_values.profile_option_value%TYPE;

PROCEDURE merge_batches (p_merge_batch_name	VARCHAR2,
			 p_merge_batches	MERGE_BATCHES_TYPE_TABLE,
			 p_del_empty_batches    DEL_EMPTY_BATCHES_TYPE_TABLE,
			 p_bus_group_id		NUMBER,
                         p_mode		        VARCHAR2
			);

/********Bug: 4620315 **********/

PROCEDURE Main_Process (
  errbuf                OUT NOCOPY     VARCHAR2,
  retcode               OUT NOCOPY     NUMBER,
  p_payroll_id          IN      NUMBER,
  p_date_earned         IN      VARCHAR2,
  p_time_period_id      IN      NUMBER DEFAULT NULL,
  p_from_batch_num      IN      NUMBER DEFAULT NULL,
  p_to_batch_num        IN      NUMBER DEFAULT NULL,
  p_ref_num             IN      VARCHAR2 DEFAULT NULL,
  p_process_mode        IN      VARCHAR2,
  p_bus_group_id        IN      NUMBER,
  p_merge_flag		IN	VARCHAR2 DEFAULT '0',
  p_merge_batch_name	IN	VARCHAR2 DEFAULT NULL,
  p_merge_batch_specified IN	VARCHAR2 DEFAULT null);
--
FUNCTION get_lookup_code (p_meaning IN VARCHAR2,
                         p_date_active IN DATE)
RETURN VARCHAR2;
--
PROCEDURE sum_to_mix (p_batch_id IN NUMBER,
                      p_time_period_id IN NUMBER,
                      p_sum_retcode IN OUT NOCOPY NUMBER);
--
PROCEDURE Transfer_To_Payroll( p_batch_id       IN NUMBER
                             , p_payroll_id     IN VARCHAR2
                             , p_batch_status   IN VARCHAR2
                             , p_ref_num        IN VARCHAR2
                             , p_process_mode   IN VARCHAR2
                             , p_pay_retcode    IN OUT NOCOPY NUMBER);


PROCEDURE Set_Batch_Status(p_date_earned DATE,
			   p_batch_id IN NUMBER, p_status IN VARCHAR2);

PROCEDURE rollback_paymix(p_batch_id IN NUMBER, p_time_period_id IN NUMBER,
		          p_rollback_retcode OUT NOCOPY NUMBER);

PROCEDURE Insert_Pay_Batch_Errors( p_batch_id IN NUMBER,
                                   p_error_level IN VARCHAR2,
                                   p_exception_details IN VARCHAR2,
                                   p_return_code OUT NOCOPY NUMBER);
PROCEDURE Del_Prior_Errors( p_batch_id  NUMBER );
PROCEDURE CALL_GEN_ERROR2 ( p_batch_id  IN NUMBER
                       , p_tim_id  IN NUMBER
                       , p_hrw_id  IN NUMBER
                       , p_time_period_id   IN NUMBER
                       , p_error_msg IN VARCHAR2
                       , p_loc IN VARCHAR2
                       , p_sql_err IN VARCHAR2
                       , p_TYPE IN VARCHAR2);

PROCEDURE dtl_to_bee ( p_values_rec     IN         HXT_BATCH_VALUES_V%ROWTYPE  ,
                       p_sum_retcode    IN OUT  NOCOPY   NUMBER,
                       p_batch_sequence IN         NUMBER ) ;


-- Bug 8888777
-- Added new function to pick up BEE_IV_UPGRADE status.
FUNCTION get_upgrade_status(p_batch_id     IN  NUMBER)
RETURN VARCHAR2;

-- Bug 9494444
-- Added new procedure to facilitate snapping retrieval info
-- for Dashboard
PROCEDURE snap_retrieval_details(p_batch_id  IN NUMBER);





END hxt_batch_process;

/
