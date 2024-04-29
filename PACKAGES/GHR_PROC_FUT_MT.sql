--------------------------------------------------------
--  DDL for Package GHR_PROC_FUT_MT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PROC_FUT_MT" AUTHID CURRENT_USER AS
/* $Header: ghprocmt.pkh 120.1.12010000.1 2008/07/28 10:37:52 appldev ship $ */
-- ============================================================================
--                        << Procedure: execute_mt >>
--  Description:
--  	This procedure is called from concurrent program. This procedure will
--  determine the batch size and call sub programs.
-- ============================================================================
	PROCEDURE EXECUTE_MT(  p_errbuf OUT NOCOPY VARCHAR2,
                       p_retcode OUT NOCOPY NUMBER,
                       p_poi IN ghr_pois.personnel_office_id%TYPE,
					   p_batch_size IN NUMBER,
					   p_thread_size IN NUMBER);
	PROCEDURE SUB_PROC_FUTR_ACT(p_errbuf OUT NOCOPY VARCHAR2,
								p_retcode OUT NOCOPY NUMBER,
								p_session_id IN NUMBER,
								p_batch_no IN NUMBER,
								p_parent_request_id IN NUMBER);
	PROCEDURE create_ghr_errorlog(
      p_program_name           IN     ghr_process_log.program_name%type,
      p_log_text               IN     ghr_process_log.log_text%type,
      p_message_name           IN     ghr_process_log.message_name%type,
      p_log_date               IN     ghr_process_log.log_date%type
      );
	PROCEDURE Route_Errored_SF52(
	p_sf52  IN OUT NOCOPY ghr_pa_requests%rowtype,
	p_error	IN VARCHAR2,
	p_result   OUT NOCOPY VARCHAR2);


	PROCEDURE verify_355_business_rule(
        p_person_id      IN     NUMBER,
        p_effective_date IN     DATE,
        p_result         OUT NOCOPY  VARCHAR2
        );

--bug# 4896738
         g_skip_grp_box  BOOLEAN := FALSE;
 --If this variable is set to TRUE then error will not be raised when user not belonging
 --to the groupbox runs process futures.

END GHR_PROC_FUT_MT;

/
