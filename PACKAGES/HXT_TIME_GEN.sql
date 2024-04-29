--------------------------------------------------------
--  DDL for Package HXT_TIME_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_TIME_GEN" AUTHID CURRENT_USER AS
/* $Header: hxttgen.pkh 120.0.12010000.2 2009/02/25 15:50:21 asrajago ship $ */

  -- Declare globals
  g_payroll_id		per_time_periods.payroll_id%TYPE;
  g_time_period_id	per_time_periods.time_period_id%TYPE;
  g_user_id		fnd_user.user_id%TYPE := FND_GLOBAL.User_Id;
  g_user_name		fnd_user.user_name%TYPE := HXT_UTIL.Fnd_Username( g_user_id );
  g_bus_group_id	hr_organization_units.business_group_id%TYPE :=
				FND_PROFILE.Value( 'PER_BUSINESS_GROUP_ID' );
  g_batch_size		NUMBER := FND_PROFILE.Value( 'HXT_BATCH_SIZE' );
  g_sysdate		DATE := trunc(SYSDATE);
  g_sysdatetime         DATE := SYSDATE;
  g_login_id            fnd_user.last_update_login%TYPE := FND_GLOBAL.login_id;
  g_err_loc		hxt_errors.location%TYPE;
  g_sub_loc		hxt_errors.location%TYPE;
  g_errors		BOOLEAN := FALSE;
  g_sqlerrm		hxt_errors.ora_message%TYPE;
  g_autogen_error	hxt_errors.error_msg%TYPE;
  g_date_worked_error	EXCEPTION;
  g_form_level_error    EXCEPTION;
  g_del_obs_tim_error   EXCEPTION;  --SIR216
  g_osp_id	        hxt_work_shifts.off_shift_prem_id%TYPE;
  g_sdf_id	        hxt_work_shifts.shift_diff_ovrrd_id%TYPE;


  -- Bug 7359347
  -- New global variable for session date

  g_gen_session_date    DATE;



------------------------------------------------------------------
PROCEDURE Generate_Time( errbuf OUT NOCOPY VARCHAR2
                       , retcode OUT NOCOPY NUMBER
                       , a_payroll_id IN NUMBER
                       , a_time_period_id IN NUMBER
		       , a_reference_number IN VARCHAR2);
------------------------------------------------------------------

PROCEDURE Gen_Work_Plan( a_start DATE
		       , a_end DATE
		       , a_tws_id NUMBER );

------------------------------------------------------------------

PROCEDURE Gen_Rot_Plan( a_start DATE
		      , a_end DATE
	 	      , a_rtp_id NUMBER );

------------------------------------------------------------------

FUNCTION Create_Batch( a_tim_cntr NUMBER, a_reference_num VARCHAR2 ) RETURN NUMBER;

------------------------------------------------------------------

FUNCTION Create_Timecard( a_batch_id NUMBER default null) RETURN NUMBER;

------------------------------------------------------------------

PROCEDURE Create_HRW( a_assignment_id NUMBER
		    , a_date_worked DATE
		    , a_tim_id NUMBER
		    , a_time_in DATE
		    , a_time_out DATE
		    , a_start DATE
		    , a_hours NUMBER);
                    -- , a_group_id IN NUMBER);

------------------------------------------------------------------

FUNCTION Get_HXT_Seqno RETURN NUMBER;

------------------------------------------------------------------

-- PROCEDURE Get_Group_ID (a_group_id OUT NUMBER);

------------------------------------------------------------------

FUNCTION  Get_Next_Batch_Id RETURN NUMBER;

------------------------------------------------------------------
--BEGIN SPR C389 BY BC
PROCEDURE Get_Work_Day( a_date IN DATE
			, a_work_id IN NUMBER
			, a_osp_id OUT NOCOPY NUMBER
			, a_sdf_id OUT NOCOPY NUMBER
			, a_standard_start OUT NOCOPY NUMBER
			, a_standard_stop OUT NOCOPY NUMBER
			, a_early_start OUT NOCOPY NUMBER
			, a_late_stop OUT NOCOPY NUMBER
			, a_hours OUT NOCOPY NUMBER);
------------------------------------------------------------------
END hxt_time_gen;

/
