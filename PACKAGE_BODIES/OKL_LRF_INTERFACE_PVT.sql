--------------------------------------------------------
--  DDL for Package Body OKL_LRF_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LRF_INTERFACE_PVT" AS
/* $Header: OKLRLRIB.pls 120.3 2005/07/05 12:32:09 asawanka noship $*/

------------------------------------------------------------------------------
-- PROCEDURE report_error
------------------------------------------------------------------------------
  PROCEDURE report_error(x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2) IS

  x_msg_index_out NUMBER;
  x_msg_out       VARCHAR2(2000);

  BEGIN

 null;

  END report_error;


  PROCEDURE validate_lrt_id( p_lrt_id        IN         NUMBER
                            ,x_return_status OUT NOCOPY VARCHAR2 ) IS

    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var         VARCHAR2(1) := '?';

    -- select the ID of the parent record from the parent table
    CURSOR c_lrt_id IS
    SELECT 'x'
    FROM   OKL_LS_RT_FCTR_SETS_B
    WHERE  ID = p_lrt_id;

  BEGIN
 null;

  END validate_lrt_id;

  -- Enforces unique key.
  FUNCTION Validate_Record (p_lrfv_rec      IN okl_lrf_interface_pvt.lrf_rec_type
                           ,x_return_status OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var                    VARCHAR2(1) := '?';

    CURSOR c_enforce_UK IS
    SELECT 'x'
    FROM   OKL_LS_RT_FCTR_ENTS
    WHERE  LRT_ID                 = p_lrfv_rec.lrt_id
      AND  TERM_IN_MONTHS         = p_lrfv_rec.term_in_months
      AND  RESIDUAL_VALUE_PERCENT = p_lrfv_rec.residual_value_percent;
      --AND  LEASE_RATE_FACTOR      = p_lrfv_rec.lease_rate_factor;
  BEGIN

 null;

  END Validate_Record;


  PROCEDURE validate_term_in_months(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_term_in_months               IN NUMBER) IS
  BEGIN
    null;
  END validate_term_in_months;


  PROCEDURE validate_residual_val(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_residual_value_percent       IN NUMBER) IS
  BEGIN
    null;
  END validate_residual_val;


  PROCEDURE validate_lease_rate_factor(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lease_rate_factor            IN NUMBER) IS
  BEGIN
   null;
  END validate_lease_rate_factor;


------------------------------------------------------------------------------
-- PROCEDURE Update_Interface_Status
-- It Changes Status to Interface Table
-- Calls:
--  None
-- Called By:
--  check_input_record
--  load_input_record
------------------------------------------------------------------------------
   PROCEDURE Update_Interface_Status (p_batch_number    IN  NUMBER
                                     ,p_status          IN  VARCHAR2
                                     ,p_lrt_id          IN  NUMBER
                                     ,p_term            IN  NUMBER
                                     ,p_interest_rate   IN  NUMBER
                                     ,p_lrf             IN  NUMBER
                                     ,p_rv_percent      IN  NUMBER
                                     ,x_return_status   OUT NOCOPY VARCHAR2 ) IS

     x_proc_name    VARCHAR2(35) := 'UPDATE_INTERFACE_STATUS';
     update_failed  EXCEPTION;

   BEGIN

 null;

   END Update_Interface_Status;


------------------------------------------------------------------------------
-- PROCEDURE Load_Input_Record
-- It Reads data from Interface Tables and Validates. During process of validation it
-- stacks Error, if any, and returns ERROR status to calling process.
-- Calls:
--  report_error
--  update_interface_status
-- Called By:
--  process_record
------------------------------------------------------------------------------
  PROCEDURE Load_Input_Record(
                            p_init_msg_list    IN VARCHAR2,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_batch_number     IN  NUMBER,
                            p_lrt_id           IN  NUMBER,
                            x_total_loaded     OUT NOCOPY NUMBER
                           ) IS

  l_proc_name      CONSTANT VARCHAR2(30) := 'LOAD_INPUT_RECORD';
  l_return_status           VARCHAR2(1)  := G_RET_STS_SUCCESS;

  lx_total_loaded   NUMBER := 0;

  l_lrf_rec             okl_lrf_pvt.lrfv_rec_type;
  lx_lrf_rec            okl_lrf_pvt.lrfv_rec_type;

  CURSOR c_validated_rec IS
  SELECT
         lease_rate_factor
        ,residual_value_percent
        ,term_in_months
        ,interest_rate
  FROM   okl_lrf_interface
  WHERE  batch_number = p_batch_number
  AND    status       = 'VALIDATED';

  BEGIN -- Actual Procedure Starts Here
   null;
  END Load_Input_Record;


------------------------------------------------------------------------------
  PROCEDURE Check_Input_Record(
                            p_init_msg_list    IN VARCHAR2,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_batch_number     IN  NUMBER,
                            p_lrt_id           IN  NUMBER,
                            x_total_checked    OUT NOCOPY NUMBER,
                            x_total_failed     OUT NOCOPY NUMBER
                           ) IS

    l_batch_number        NUMBER       := p_batch_number;
    l_record_status       VARCHAR2(3);
    l_batch_status        VARCHAR2(3);
    l_total_checked       NUMBER       := 0;
    l_rec_valid           VARCHAR2(1);

    l_return_status       VARCHAR2(1)  := G_RET_STS_SUCCESS;
    l_proc_name           CONSTANT VARCHAR2(30) := 'check_input_record';

    l_lrf_rec             okl_lrf_interface_pvt.lrf_rec_type;

    l_validation_failed   VARCHAR2(1);
    l_failed_count        NUMBER      := 0;
    validation_failed     EXCEPTION;

    -- add cursor to get lrf values
    CURSOR c_lrf_batch (b_batch_number IN NUMBER  ) IS
    SELECT term_in_months, lease_rate_factor, residual_value_percent, interest_rate
    FROM   okl_lrf_interface
    WHERE  batch_number = b_batch_number
    AND    status in ('NEW','FAILED','ERROR','AUTOGEN');

  BEGIN
   null;
  END Check_Input_Record;


------------------------------------------------------------------------------
-- PROCEDURE Process_Record
-- It Validates Input record and Load record after SUCCESSFUL validation
-- Calls:
--   Check_Inout_Record
--   Load_Input_Record
--   Report Error
-- Called by:
--   Starting point
------------------------------------------------------------------------------
  PROCEDURE Process_Record (
                            errbuf             OUT NOCOPY VARCHAR2
                           ,retcode            OUT NOCOPY VARCHAR2
                           ,p_batch_number     IN  NUMBER
                           ) IS

  X_Progress         VARCHAR2(3) := NULL;
  l_proc_name        CONSTANT VARCHAR2(30)  := 'PROCESS_RECORD';
  X_msg_count        NUMBER;
  X_msg_data         VARCHAR2(2000);
  X_return_status    VARCHAR2(200);
  x_total_checked    NUMBER := 0;
  x_total_failed     NUMBER := 0;
  x_total_loaded     NUMBER := 0;
  param_error        EXCEPTION;
  p_lrt_id           NUMBER := p_batch_number;
  l_lrt_id           NUMBER := p_batch_number;

  BEGIN

   null;
   END Process_Record;


------------------------------------------------------------------------------
-- PROCEDURE Purge_Record
-- It deletes records from the lrf interface table.
------------------------------------------------------------------------------
  PROCEDURE purge_record (
                          errbuf             OUT NOCOPY VARCHAR2
                         ,retcode            OUT NOCOPY VARCHAR2
                         ,p_batch_number     IN  NUMBER
                         ,p_status           IN  VARCHAR2
                         ) IS

  x_progress         VARCHAR2(3) := NULL;
  l_proc_name        CONSTANT VARCHAR2(30)  := 'PROCESS_RECORD';
  x_msg_count        NUMBER;
  x_msg_data         VARCHAR2(2000);
  x_return_status    VARCHAR2(200);
  x_total_purged     NUMBER := 0;
  l_batch_number     NUMBER                 := p_batch_number;
  l_status           VARCHAR2(30)           := p_status;
  param_error        EXCEPTION;

  BEGIN

    null;

   END purge_record;




--*********************** check Interface **************************************

--+++++++++++++++++++++++ Load Interface +++++++++++++++++++++++++++++++++++++++




--------------------------------- Load Interface ------------------------------------
-- Function to submit the concurrent request for Contract Import.

/* Not being used
  FUNCTION Submit_Imported_LRFs(
  		   			p_api_version     IN  NUMBER,
  		   			p_init_msg_list 	IN  VARCHAR2,
  		   			x_return_status   OUT NOCOPY VARCHAR2,
  		   			x_msg_count 		OUT NOCOPY NUMBER,
  		   			x_msg_data 			OUT NOCOPY VARCHAR2,
  		   			p_batch_number  	IN  NUMBER,
                  p_lrt_id          IN  NUMBER
                 )
   RETURN NUMBER
   IS

    x_request_id           NUMBER;

 l_start_date  VARCHAR2(30);
 l_end_date    VARCHAR2(30);


BEGIN

   null;

  END Submit_Imported_LRFs;
--not being used
*/


PROCEDURE GENERATE_LEASE_RATE_FACTORS
 (
   p_init_msg_list    IN VARCHAR2
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2
  ,P_LRT_ID           IN  NUMBER
  ,P_RATE_UPPER_RANGE IN  NUMBER
  ,P_RATE_LOWER_RANGE IN  NUMBER  -- MIN 0
  ,P_RATE_INTERVAL    IN  NUMBER
  --
  ,P_TERM_UPPER_RANGE IN  NUMBER
  ,P_TERM_LOWER_RANGE IN  NUMBER  -- MIN 0
  ,P_TERM_INTERVAL    IN  NUMBER  -- IN MONTHS
  --
  ,P_RV_UPPER_RANGE   IN  NUMBER  -- MAX 100
  ,P_RV_LOWER_RANGE   IN  NUMBER  -- MIN 0
  ,P_RV_INTERVAL      IN  NUMBER
  ,x_lease_rate_tbl   OUT NOCOPY lease_rate_tbl
 ) IS

  L_RATE_SET_ID      NUMBER := P_LRT_ID;
  L_ARREARS_YN       VARCHAR2(2);
  L_ARREARS          NUMBER;
  L_FREQ             NUMBER;
  L_LRF              NUMBER;
  L_TERM             NUMBER;
  L_RV               NUMBER;
  L_RATE             NUMBER;
  --
  L_RATE_UPPER_RANGE NUMBER := P_RATE_UPPER_RANGE;
  L_RATE_LOWER_RANGE NUMBER := P_RATE_LOWER_RANGE;  -- MIN 0
  L_RATE_INTERVAL    NUMBER := P_RATE_INTERVAL;
  --
  L_TERM_UPPER_RANGE NUMBER := P_TERM_UPPER_RANGE;
  L_TERM_LOWER_RANGE NUMBER := P_TERM_LOWER_RANGE;  -- MIN 0
  L_TERM_INTERVAL    NUMBER := P_TERM_INTERVAL;  -- IN MONTHS
  --
  L_RV_UPPER_RANGE   NUMBER := P_RV_UPPER_RANGE;  -- MAX 100
  L_RV_LOWER_RANGE   NUMBER := P_RV_LOWER_RANGE;  -- MIN 0
  L_RV_INTERVAL      NUMBER := P_RV_INTERVAL;
  --
  L_TERM_LIMIT       NUMBER := 0;
  L_RV_LIMIT         NUMBER := 0;
  L_RATE_LIMIT       NUMBER := 0;
  I                  NUMBER := 0;
  --
  L_LEASE_RATE_TBL    LEASE_RATE_TBL;
  --
  L_RETURN_STATUS VARCHAR2(1)           := G_RET_STS_SUCCESS;
  l_api_name      CONSTANT VARCHAR2(30) := 'Generate_Lease_Rate_Factors';
  l_api_version   CONSTANT NUMBER       := 1;
  param_error     EXCEPTION;
  --
  CURSOR C_RATE_SET (B_LRT_ID IN NUMBER) IS
  SELECT DECODE(ARREARS_YN,'N',1,0), DECODE(FRQ_CODE,'M',12,'Q',3,'S',2,'A',1,0)
  FROM   OKL_LS_RT_FCTR_SETS_B
  WHERE  ID = B_LRT_ID;
  --
BEGIN


 null;
END GENERATE_LEASE_RATE_FACTORS;


  ---------------
  -- generate_lrf
  ---------------
  PROCEDURE generate_lrf (errbuf             OUT NOCOPY VARCHAR2
                         ,retcode            OUT NOCOPY VARCHAR2
                         ,p_batch_number     IN NUMBER
                         ,p_term_lower_range IN NUMBER
                         ,p_term_upper_range IN NUMBER
                         ,p_term_interval    IN NUMBER
                         ,p_rv_lower_range   IN NUMBER
                         ,p_rv_upper_range   IN NUMBER
                         ,p_rv_interval      IN NUMBER) IS

    l_proc_name          CONSTANT VARCHAR2(30)  := 'generate_lrf';
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(2000);
    l_return_status      VARCHAR2(1)            := G_RET_STS_SUCCESS;
    param_error          EXCEPTION;
    p_lrt_id             NUMBER := p_batch_number;
    l_lrt_id             NUMBER := p_batch_number;
    l_hdr_rate           NUMBER;

    LX_LEASE_RATE_TBL    LEASE_RATE_TBL;

  BEGIN


 null;
  END GENERATE_LRF;

END OKL_LRF_INTERFACE_PVT;

/
