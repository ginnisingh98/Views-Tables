--------------------------------------------------------
--  DDL for Package Body OKL_RV_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RV_INTERFACE_PVT" AS
/* $Header: OKLRRVIB.pls 120.4 2005/07/28 06:32:21 smadhava noship $*/

  G_DEBUG                    NUMBER := 0;
------------------------------------------------------------------------------
-- PROCEDURE debug_message
--
--  This procedure prints debug message depending on DEBUG flag
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE debug_message(
                           p_message IN VARCHAR2
                          ) IS
   BEGIN
      IF ( G_DEBUG = 1 ) THEN
        fnd_file.put_line (fnd_file.output, p_message);
        --dbms_output.put_line (p_message);
      END IF;

      RETURN;
   END debug_message;

------------------------------------------------------------------------------
-- PROCEDURE Report_Error
-- It is a generalized routine to display error on Concurrent Manager Log file
-- Calls:
--   okl_api package
--   fnd_msg_pub package
-- Called by:
--   process_record
--   check_input_record
--   process_input_record
------------------------------------------------------------------------------

  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        ) IS

  x_msg_index_out NUMBER;
  x_msg_out       VARCHAR2(2000);

  BEGIN

    FOR i in 1..x_msg_count LOOP
      FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => x_msg_index_out
                     );

      fnd_file.put_line(fnd_file.output, 'Error '||to_char(i)||': '||x_msg_data);
      --dbms_output.put_line('Error '||to_char(i)||': '||x_msg_data);
    END LOOP;
    return;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Report_Error;


  PROCEDURE write_to_log(
                         p_message IN VARCHAR2
                        ) IS
  BEGIN
    --dbms_output.put_line(p_message);
    fnd_file.put_line(fnd_file.output, p_message);
  END write_to_log;


------------------------------------------------------------------------------
-- Validations for ensuring correct individual values
-- as well as enforcing unique and foriegn key constraints
-- PROCEDURE validate_item id
-- PROCEDURE org id -- incorporate check with item id
-- PROCEDURE validate_rv_percent
-- PROCEDURE validate term
-- PROCEDURE validate start date
-- PROCEDURE validate end date
--

  --------------------------------------
  -- Validate_Attributes for ITEM ID and ORG ID --
  --------------------------------------
  PROCEDURE validate_item_and_org(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_item_id                      IN NUMBER,
    p_org_id                       IN NUMBER) IS

  BEGIN
  --Stubbed out - smadhava
  NULL;
  END validate_item_and_org;

 -----------------------------------------------------
  -- Validate_Attributes for: RESIDUAL_VALUE_PERCENT --
  -----------------------------------------------------
  PROCEDURE validate_residual(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_residual_value_percent       IN NUMBER) IS
  BEGIN
  --Stubbed out - smadhava
  NULL;
  END validate_residual;

  ---------------------------------------------
  -- Validate_Attributes for: TERM_IN_MONTHS --
  ---------------------------------------------
  PROCEDURE validate_term(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_term_in_months               IN NUMBER) IS
  BEGIN
  --Stubbed out - smadhava
  NULL;
  END validate_term;


  -----------------------------------------
  -- Validate_Attributes for: START_DATE --
  -----------------------------------------
  PROCEDURE validate_start_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_start_date                   IN DATE) IS
  BEGIN
  --Stubbed out - smadhava
  NULL;
  END validate_start_date;

  -----------------------------------------
  -- Validate_Attributes for: END_DATE --
  -----------------------------------------
  PROCEDURE validate_end_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_end_date                     IN DATE,
    p_start_date                   IN DATE) IS
  BEGIN
   --Stubbed out - smadhava
  NULL;
  END validate_end_date;

  -- Enforces unique key.
  FUNCTION Validate_Record (p_rv_rec        IN  okl_rv_interface_pvt.rv_rec_type
                           ,x_return_status OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS
  BEGIN
  --Stubbed out - smadhava
  NULL;
  END Validate_Record;

------------------------------------------------------------------------------
             -- End of attribute and record validations --
------------------------------------------------------------------------------
  PROCEDURE Check_Input_Record(
                            p_init_msg_list    IN VARCHAR2,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_batch_number     IN  VARCHAR2,
                            p_org_id           IN  NUMBER,
                            x_total_checked    OUT NOCOPY NUMBER,
                            x_total_failed     OUT NOCOPY NUMBER
                           ) IS
  BEGIN
  --Stubbed out - smadhava
  NULL;
  END; -- Check_Input_Record


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
                           ,p_batch_number     IN  VARCHAR2
                           ,p_org_id           IN  NUMBER
                           ) IS

  BEGIN
  --Stubbed out - smadhava
  NULL;
   END Process_Record;



------------------------------------------------------------------------------
-- PROCEDURE Purge_Record
-- It deletes records from the rv interface table.
------------------------------------------------------------------------------
  PROCEDURE purge_record (
                          errbuf             OUT NOCOPY VARCHAR2
                         ,retcode            OUT NOCOPY VARCHAR2
                         ,p_batch_number     IN  VARCHAR2
                         ,p_org_id           IN  NUMBER
                         ,p_status           IN  VARCHAR2
                         ) IS

  BEGIN
  --Stubbed out - smadhava
  NULL;
   END purge_record;


------------------------------------------------------------------------------
-- PROCEDURE Update_Interface_Status
-- It Changes Status to Interface Table
-- Calls:
--  None
-- Called By:
--  check_input_record
--  load_input_record
------------------------------------------------------------------------------
   PROCEDURE Update_Interface_Status (p_batch_number    IN  VARCHAR2
                                     ,p_status          IN  VARCHAR2
                                     ,p_item_id         IN  NUMBER
                                     ,p_org_id          IN  NUMBER
                                     ,p_term            IN  NUMBER
                                     ,p_rv_percent      IN  NUMBER
                                     ,p_start_date      IN  DATE
                                     ,p_end_date        IN  DATE
                                     ,x_return_status   OUT NOCOPY VARCHAR2 ) IS

   BEGIN
  --Stubbed out - smadhava
  NULL;

   END Update_Interface_Status;

--*********************** check Interface **************************************

--+++++++++++++++++++++++ Load Interface +++++++++++++++++++++++++++++++++++++++


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
                            p_batch_number     IN  VARCHAR2,
                            x_total_loaded     OUT NOCOPY NUMBER
                           ) IS

  BEGIN -- Actual Procedure Starts Here
  --Stubbed out - smadhava
  NULL;

  END Load_Input_Record;

--------------------------------- Load Interface ------------------------------------
--

  PROCEDURE GENERATE_RV (
                          ERRBUF             OUT NOCOPY VARCHAR2
                         ,RETCODE            OUT NOCOPY VARCHAR2
                         ,P_BATCH_NUMBER     IN  VARCHAR2
                         ,P_ORG_ID           IN  NUMBER
                         ,P_SO_ITEMS_ONLY_YN IN  VARCHAR2 -- get only items used in quotes
                         ,P_START_DATE       IN  VARCHAR2
                         ,P_END_DATE         IN  VARCHAR2
                         ,P_TERM_LOWER_RANGE IN  NUMBER  -- MIN 0
                         ,P_TERM_UPPER_RANGE IN  NUMBER
                         ,P_TERM_INTERVAL    IN  NUMBER  -- IN MONTHS
                         ,P_INITIAL_RV       IN  NUMBER  -- MIN 1
                         ,P_DECREMENT_RV_BY  IN  NUMBER
                         ) IS

  BEGIN
  --Stubbed out - smadhava
  NULL;

  END GENERATE_RV;


PROCEDURE GENERATE_RESIDUAL_VALUES
      (
       p_init_msg_list    IN VARCHAR2
      ,x_return_status    OUT NOCOPY VARCHAR2
      ,x_msg_count        OUT NOCOPY NUMBER
      ,x_msg_data         OUT NOCOPY VARCHAR2
      ,P_ORG_ID           IN  NUMBER
      ,P_SO_ITEMS_ONLY_YN IN  VARCHAR2 -- get only items used in quoting
      ,P_START_DATE       IN  DATE
      ,P_END_DATE         IN  DATE
      ,P_TERM_LOWER_RANGE IN  NUMBER  -- MIN 1
      ,P_TERM_UPPER_RANGE IN  NUMBER
      ,P_TERM_INTERVAL    IN  NUMBER  -- IN MONTHS
      ,P_INITIAL_RV       IN  NUMBER  -- MIN 1
      ,P_DECREMENT_RV_BY  IN  NUMBER
      ,x_rv_tbl           OUT NOCOPY rv_tbl
      ) IS


BEGIN
  --Stubbed out - smadhava
  NULL;
END GENERATE_RESIDUAL_VALUES;


END OKL_RV_INTERFACE_PVT;

/
