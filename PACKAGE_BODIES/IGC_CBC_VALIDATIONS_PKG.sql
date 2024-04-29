--------------------------------------------------------
--  DDL for Package Body IGC_CBC_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CBC_VALIDATIONS_PKG" AS
/*$Header: IGCBVALB.pls 120.10.12000000.3 2007/10/08 04:09:00 mbremkum ship $*/

-- -----------------------------------------------------------------------
-- Declare global variables.
-- -----------------------------------------------------------------------
  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CBC_VALIDATIONS_PKG';

-- Variables for Central Logging
  --l_debug_mode           VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
  g_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--bug 3199488
  g_debug_level       NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_state_level       NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
  g_proc_level        NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
  g_event_level       NUMBER	:=	FND_LOG.LEVEL_EVENT;
  g_excep_level       NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
  g_error_level       NUMBER	:=	FND_LOG.LEVEL_ERROR;
  g_unexp_level       NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
  g_path              VARCHAR2(255) := 'IGC.PLSQL.IGCBVALB.IGC_CBC_VALIDATIONS_PKG.';
--bug 3199488

-- -----------------------------------------------------------------------
-- Private Functions for Procedure
-- -----------------------------------------------------------------------
PROCEDURE message_token(
   tokname         IN VARCHAR2,
   tokval          IN VARCHAR2
);

PROCEDURE add_message(
   appname           IN VARCHAR2,
   msgname           IN VARCHAR2
);

PROCEDURE Put_Debug_Msg (
   P_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
);


/*=======================================================================+
 |                       PROCEDURE message_token                         |
 |                                                                       |
 | Note : This is a private function to add tokens and values onto the   |
 |        error stack as any error could happen during the public        |
 |        procedures that are called.                                    |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   tokname      Token name for message that has been defined           |
 |   tokval       Token value to be displayed in the error message       |
 |                                                                       |
 +=======================================================================*/
PROCEDURE message_token(
   tokname IN VARCHAR2,
   tokval  IN VARCHAR2
) IS

BEGIN

  IGC_MSGS_PKG.message_token (p_tokname => tokname,
                              p_tokval  => tokval);

END message_token;


/*=======================================================================+
 |                       PROCEDURE add_message                           |
 |                                                                       |
 | Note : This is a private function to add messages onto the error stack|
 |        as any error could happen during the public procedures that are|
 |        called.                                                        |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   appname     Application name that message is for                    |
 |   msgname     Message name that has been seeded in database           |
 |                                                                       |
 +=======================================================================*/
PROCEDURE add_message(
   appname IN VARCHAR2,
   msgname IN VARCHAR2
) IS

BEGIN

   IGC_MSGS_PKG.add_message (p_appname => appname,
                             p_msgname => msgname);

END add_message;


/*=======================================================================+
 |                       PROCEDURE Put_Debug_Msg                         |
 |                                                                       |
 | Note : This is a private function to output any debug information if  |
 |        debug is enabled for the system to determine any issue that    |
 |        may be happening at customer site.                             |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_debug_msg   This is the message that is to be output to log for   |
 |                 debugging purposes.                                   |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
) IS

-- Constants :

   /*l_Return_Status    VARCHAR2(1);
   l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(3)           := 'CBC';
   l_profile_name     VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';*/
   l_api_name         CONSTANT VARCHAR2(30) := 'Put_Debug_Msg';

BEGIN

   IF(g_state_level >= g_debug_level) THEN
        FND_LOG.STRING(g_state_level, p_path, p_debug_msg);
   END IF;

   /*IGC_MSGS_PKG.Put_Debug_Msg (l_full_path, p_debug_message    => p_debug_msg,
                               p_profile_log_name => l_profile_name,
                               p_prod             => l_prod,
                               p_sub_comp         => l_sub_comp,
                               p_filename_val     => NULL,
                               x_Return_Status    => l_Return_Status
                              );
   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;*/

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Put_Debug_Msg procedure.
-- --------------------------------------------------------------------
EXCEPTION

   /*WHEN FND_API.G_EXC_ERROR THEN
       RETURN;*/

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       NULL;
       RETURN;

END Put_Debug_Msg;


/*=======================================================================+
 |                      PROCEDURE Validate_CCID                          |
 |                                                                       |
 | Note : This procedure is designed to validate the CCID that is given  |
 |        based upon the rules defined for the CCID to be entered into   |
 |        the CBC Funds Checker process and inserted into the table      |
 |        IGC_CBC_JE_LINES.                                              |
 |                                                                       |
 |        If there is to be any changes inside of this procedure then    |
 |        there needs to be analysis performed on the effect it will have|
 |        on the Funds Checker process.                                  |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_validation_type    Type of Validation FC (Funds), LC (Legacy)     |
 |   p_ccid               Code Combination ID From GL tables             |
 |   p_transaction_date   Date transaction to compare period start / end |
 |   p_det_sum_value      Detail (D) or Summary (S) transaction          |
 |   p_set_of_books_id    Set Of Books being processed                   |
 |   p_actual_flag        Actual Flag for Encumbrance or Budget.         |
 |   p_result_code        Result Code mapping for status update to user  |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Validate_CCID
(
   p_api_version         IN NUMBER,
   p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status       OUT NOCOPY VARCHAR2,
   p_msg_count           OUT NOCOPY NUMBER,
   p_msg_data            OUT NOCOPY VARCHAR2,

   p_validation_type     IN VARCHAR2,
   p_ccid                IN igc_cbc_je_lines.code_combination_id%TYPE, -- Contract ID
   p_effective_date      IN igc_cbc_je_lines.effective_date%TYPE,      -- Transaction Date
   p_det_sum_value       IN igc_cbc_je_lines.detail_summary_code%TYPE,
   p_set_of_books_id     IN gl_sets_of_books.set_of_books_id%TYPE,
   p_actual_flag         IN VARCHAR2,
   p_result_code         OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Declare the cursors to be used during this function run.
-- --------------------------------------------------------------------
   CURSOR c_validate_ccid_values IS
      SELECT GCC.detail_budgeting_allowed_flag,
             GCC.detail_posting_allowed_flag,
             GCC.enabled_flag,
             GCC.start_date_active,
             GCC.end_date_active
        FROM gl_code_combinations GCC,
             gl_sets_of_books GSB
       WHERE GCC.code_combination_id  = p_ccid
         AND GSB.set_of_books_id      = p_set_of_books_id
         AND GCC.chart_of_accounts_id = GSB.chart_of_accounts_id;

-- -------------------------------------------------------------------------
-- Declare local variables used within fuction
-- -------------------------------------------------------------------------
   l_budget_flag      gl_code_combinations.detail_budgeting_allowed_flag%TYPE;
   l_posting_flag     gl_code_combinations.detail_posting_allowed_flag%TYPE;
   l_enabled_flag     gl_code_combinations.enabled_flag%TYPE;
   l_start_date       gl_code_combinations.start_date_active%TYPE;
   l_end_date         gl_code_combinations.end_date_active%TYPE;
   l_closing_status   gl_period_statuses.closing_status%TYPE;
   l_period_name      igc_cbc_je_lines.period_name%TYPE;
   l_period_set_name  igc_cbc_je_lines.period_set_name%TYPE;
   l_quarter_num      igc_cbc_je_lines.quarter_num%TYPE;
   l_period_num       igc_cbc_je_lines.period_num%TYPE;
   l_period_year      igc_cbc_je_lines.period_year%TYPE;
   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2(2000);
   l_Return_Status    VARCHAR2(1);
   l_validation_error BOOLEAN                 := FALSE;
   l_api_name         CONSTANT VARCHAR2(30)   := 'Validate_CCID';
   l_api_version      CONSTANT NUMBER         :=  1.0;
   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Validate_CCID';

   SAVEPOINT Validate_CCID_Pub;

   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
   END IF;

-- --------------------------------------------------------------------
-- Initialize Return status
-- --------------------------------------------------------------------
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   p_result_code   := NULL;

-- --------------------------------------------------------------------
-- Retrieve data to check that the CCID is a valid to check flags that
-- indicate if the CCID will be valid for Funds Check and Reservation.
-- --------------------------------------------------------------------
   OPEN c_validate_ccid_values;

   FETCH c_validate_ccid_values
    INTO l_budget_flag,
         l_posting_flag,
         l_enabled_flag,
         l_start_date,
         l_end_date;

-- --------------------------------------------------------------------
-- Ensure that the record can be found based upon the CCID given.
-- --------------------------------------------------------------------
   IF (c_validate_ccid_values%NOTFOUND) THEN
      p_result_code      := 'F20';

   ELSIF (l_enabled_flag = 'N') THEN

-- --------------------------------------------------------------------
-- Check to see if the CCID is not enabled.  If not enabled then setup
-- the appropriate global variable indicating that there was a validation
-- error and update the status and result status for the record in the
-- IGC_CC_INTERFACE table and set the global variable which indicates an
-- error has happened during the validation.  This will prevent the funds
-- check from being performed.
-- --------------------------------------------------------------------

      p_result_code      := 'F21';

   ELSIF (
           (sign(p_effective_date - nvl(l_start_date, p_effective_date)) < 0)
           OR (sign(nvl(l_end_date, p_effective_date) - p_effective_date) < 0)
          ) THEN

-- --------------------------------------------------------------------
-- Make sure that the CCID start and end dates are in the active
-- range.  If they are not then set the status of the line to 'F21 as
-- is the case in the Standard funds check.
-- --------------------------------------------------------------------

      p_result_code      := 'F21';

   ELSIF p_validation_type ='FC' THEN

-- --------------------------------------------------------------------
-- Check to see if the CCID does not have POSTING enabled.  If not then
-- setup the appropriate global variable indicating that there was a
-- validation error and update the status and result status for the
-- record in the IGC_CC_INTERFACE table and set the global variable
-- which indicates an error has happened during the validation.  This
-- will prevent the funds check from being performed.
-- --------------------------------------------------------------------
      IF (l_posting_flag = 'N') AND  (p_det_sum_value ='D')  THEN

         p_result_code      := 'F22';

      ELSIF  (l_budget_flag = 'N')  AND (p_actual_flag = 'B') AND (p_det_sum_value ='D') THEN

-- --------------------------------------------------------------------
-- Check to see if the CCID does not have budgeting enabled.  If not
-- then setup the appropriate global variable indicating that there was
-- a validation error and update the status and result status for the
-- record in the IGC_CC_INTERFACE table and set the global variable
-- which indicates an error has happened during the validation.  This
-- will prevent the funds check from being performed.
-- ---------------------------------------------------------------------
        p_result_code      := 'F23';

      ELSIF  l_budget_flag = 'N' AND p_det_sum_value = 'D' AND p_actual_flag = 'B' THEN

        p_result_code      := 'F23';

      END IF;

   END IF;

-- --------------------------------------------------------------------
-- Close all cursors used by this function here.
-- --------------------------------------------------------------------
   IF (c_validate_ccid_values%ISOPEN) THEN
      CLOSE c_validate_ccid_values;
   END IF;

   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                               p_data  => p_msg_data );

   RETURN;

-- -------------------------------------------------------------------------
-- Exception handler section for the Validate_CCID procedure.
-- -------------------------------------------------------------------------
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Validate_CCID_Pub;
    p_return_status := FND_API.G_RET_STS_ERROR;
    p_result_code   := NULL;
    IF (c_validate_ccid_values%ISOPEN) THEN
       CLOSE c_validate_ccid_values;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;
    RETURN;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Validate_CCID_Pub;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_result_code   := NULL;
    IF (c_validate_ccid_values%ISOPEN) THEN
       CLOSE c_validate_ccid_values;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
    END IF;
    RETURN;

  WHEN OTHERS THEN

    ROLLBACK TO Validate_CCID_Pub;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_result_code   := NULL;
    IF (c_validate_ccid_values%ISOPEN) THEN
       CLOSE c_validate_ccid_values;
    END IF;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF ( g_unexp_level >= g_debug_level ) THEN
      FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
      FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    RETURN;

END Validate_CCID;


/*=======================================================================+
 |                PROCEDURE Validate_Get_CCID_Budget_Info                |
 |                                                                       |
 | Note : This procedure is designed to validate the CCID Budget Version |
 |        information based upon the rules defined for the CCID to be    |
 |        entered into the CBC Funds Checker process and inserted into   |
 |        the table IGC_CBC_JE_LINES.                                    |
 |                                                                       |
 |        If there is to be any changes inside of this procedure then    |
 |        there needs to be analysis performed on the effect it will have|
 |        on the Funds Checker process.                                  |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_efc_enabled        Enhanced Funds Checker enabled flag.           |
 |   p_set_of_books_id    GL Set Of books ID being processed             |
 |   p_actual_flag        Actual Flag for Encumbrance or Budget.         |
 |   p_ccid               GL Code Combination ID                         |
 |   p_det_sum_value      Detail (D) or Summary (S) transaction          |
 |   p_currency_code      Currency Code that transaction is for          |
 |   p_effective_date     Transaction date for period range              |
 |   p_budget_ver_id      Funding Budget Version ID if Budget CCID       |
 |   p_out_budget_ver_id  Funding Budget Version ID if available for CCID|
 |   p_amount_type        Amount type in GL for CCID                     |
 |   p_funds_level_code   What level of Funds Check required             |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Validate_Get_CCID_Budget_Info
(
   p_api_version          IN NUMBER,
   p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
   p_commit               IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level     IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status        OUT NOCOPY VARCHAR2,
   p_msg_count            OUT NOCOPY NUMBER,
   p_msg_data             OUT NOCOPY VARCHAR2,

   p_efc_enabled         IN VARCHAR2,
   p_set_of_books_id     IN gl_sets_of_books.set_of_books_id%TYPE,
   p_actual_flag         IN VARCHAR2,
   p_ccid                IN igc_cbc_je_lines.code_combination_id%TYPE,
   p_det_sum_value       IN igc_cbc_je_lines.detail_summary_code%TYPE,
   p_currency_code       IN igc_cbc_je_lines.currency_code%TYPE,
   p_effective_date      IN igc_cbc_je_lines.effective_date%TYPE,      -- Transaction Date
   p_budget_ver_id       IN igc_cbc_je_lines.budget_version_id%TYPE,
   p_out_budget_ver_id   OUT NOCOPY igc_cbc_je_lines.budget_version_id%TYPE,
   p_amount_type         OUT NOCOPY igc_cbc_je_lines.amount_type%TYPE,
   p_funds_level_code    OUT NOCOPY igc_cbc_je_lines.funds_check_level_code%TYPE
) IS

-- -------------------------------------------------------------------------
-- Declare local variables used within fuction
-- -------------------------------------------------------------------------
   l_budget_ver_id     igc_cbc_je_lines.budget_version_id%TYPE;
   l_amount_type       igc_cbc_je_lines.amount_type%TYPE;
   l_funds_level_code  igc_cbc_je_lines.funds_check_level_code%TYPE;
   l_cbc_override      igc_cbc_je_lines.funds_check_level_code%TYPE;

   l_api_name          CONSTANT VARCHAR2(30)   := 'Validate_Get_CCID_Budget_Info';
   l_api_version       CONSTANT NUMBER         :=  1.0;
   l_gl_application_id fnd_application.application_id%TYPE;

/*Commented for compilation - igc_cbc_summary_templates_v View is dummy Bug No 6341012*/

/*
   l_efc_budget_str VARCHAR2(2000) := '
      SELECT GST.amount_type,
             GST.funds_check_level_code,
             GST.cbc_override,
             ST.funding_budget_version_id
        FROM igc_cbc_summary_templates_v GST,
             psa_efc_summary_budgets ST,
             gl_budget_versions  BVR,
             gl_budgets  BUD,
             gl_period_statuses FPER,
             gl_period_statuses LPER
       WHERE GST.template_id                 IN
             ( SELECT template_id
                 FROM gl_account_hierarchies
                WHERE set_of_books_id             = :1
                  AND summary_code_combination_id = :2
             )
         AND GST.template_id                 = ST.template_id
         AND GST.set_of_books_id             = FPER.set_of_books_id
         AND ST.funding_budget_version_id    = BVR.budget_version_id
         AND BVR.budget_name                 = BUD.budget_name
         AND FPER.set_of_books_id            = :3
         AND LPER.set_of_books_id            = :4
         AND BUD.first_valid_period_name     = FPER.period_name
         AND BUD.last_valid_period_name      = LPER.period_name
         AND FPER.application_id             = :5
         AND LPER.application_id             = :6
         AND :7  BETWEEN FPER.start_date AND LPER.end_date
         ';
*/

-- --------------------------------------------------------------------
-- Declare the cursors to be used during this function run.
-- --------------------------------------------------------------------
--
-- Bug 2885953 - amended cursor below for performance enhancements
--  CURSOR c_igc_je_detail_info IS
--      SELECT GBA.amount_type,
--             GBA.funds_check_level_code,
--             BAR.cbc_override,
--             GBA.funding_budget_version_id
--        FROM gl_budget_assignments GBA,
--             igc_cbc_ba_ranges_v   BAR
--       WHERE GBA.set_of_books_id     = p_set_of_books_id
--         AND BAR.set_of_books_id     = GBA.set_of_books_id
--         AND GBA.code_combination_id = p_ccid
--         AND GBA.currency_code       = p_currency_code
--         AND GBA.range_id            = BAR.range_id
--         AND GBA.range_id IN
--             ( SELECT asg.range_id
--                FROM gl_budget_assignment_ranges asg,
--                     gl_budget_versions  bvr,
--                     gl_budgets  bud,
--                     gl_period_statuses fper,
--                     gl_period_statuses lper
--               WHERE asg.funding_budget_version_id IS NOT NULL
--                     AND asg.funding_budget_version_id=bvr.budget_version_id
--                     AND bvr.budget_name=bud.budget_name
--                     AND fper.set_of_books_id        = p_set_of_books_id
--                     AND lper.set_of_books_id        = p_set_of_books_id
--                     AND bud.first_valid_period_name = fper.period_name
--                     AND bud.last_valid_period_name  = lper.period_name
--                     AND fper.application_id         = l_gl_application_id
--                     AND lper.application_id         = l_gl_application_id
--                     AND p_effective_date BETWEEN fper.start_date AND lper.end_date
--             );
  CURSOR c_igc_je_detail_info IS
      SELECT GBA.amount_type,
             GBA.funds_check_level_code,
             BAR.cbc_override,
             GBA.funding_budget_version_id
        FROM gl_budget_assignments GBA,
             igc_cbc_ba_ranges   BAR,
             gl_budget_assignment_ranges asg,
             gl_budget_versions  bvr,
             gl_budgets  bud,
             gl_period_statuses fper,
             gl_period_statuses lper
/*R12 Uptake - Commented for compilation Bug No 6341012*/
--     WHERE GBA.set_of_books_id     = p_set_of_books_id
       WHERE GBA.ledger_id     = p_set_of_books_id
/*R12 Uptake - Commented for compilation Bug No 6341012*/
--       AND BAR.set_of_books_id(+)  = GBA.set_of_books_id
         AND BAR.set_of_books_id(+)  = GBA.ledger_id
         AND GBA.code_combination_id = p_ccid
         AND GBA.currency_code       = p_currency_code
         AND GBA.range_id            = BAR.cbc_range_id(+)
         AND GBA.range_id = asg.range_id
         AND asg.funding_budget_version_id=bvr.budget_version_id
         AND bvr.budget_name=bud.budget_name
         AND fper.set_of_books_id        = p_set_of_books_id
         AND lper.set_of_books_id        = p_set_of_books_id
         AND bud.first_valid_period_name = fper.period_name
         AND bud.last_valid_period_name  = lper.period_name
         AND fper.application_id         = l_gl_application_id
         AND lper.application_id         = l_gl_application_id
         AND p_effective_date BETWEEN fper.start_date AND lper.end_date
             ;
/*

--Commented for compilation - igc_cbc_summary_templates_v View does not exist Bug No 6341012

   CURSOR c_igc_je_summary_info IS
      SELECT GST.amount_type,
             GST.funds_check_level_code,
             GST.cbc_override,
             GST.funding_budget_version_id
        FROM igc_cbc_summary_templates_v GST,
             gl_account_hierarchies GAH
--R12 Uptake - Commented for compilation
--     WHERE GAH.set_of_books_id             = p_set_of_books_id
       WHERE GAH.ledger_id             = p_set_of_books_id
         AND GAH.summary_code_combination_id = p_ccid
         AND GST.template_id                 = GAH.template_id
--R12 Uptake - Commented for compilation
--       AND GST.set_of_books_id             = GAH.set_of_books_id;
         AND GST.set_of_books_id             = GAH.ledger_id;

*/

   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Validate_Get_CCID_Budget_Info';

   SAVEPOINT Valid_Get_CCID_Bdg_Info_Pub;

   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
   END IF;

-- -------------------------------------------------------------------
-- Initialize return status to Success.
-- -------------------------------------------------------------------
   p_return_status := FND_API.G_RET_STS_SUCCESS ;

-- --------------------------------------------------------------------
-- Obtain the application ID that will be used throughout this process.
-- --------------------------------------------------------------------
   SELECT application_id
     INTO l_gl_application_id
     FROM fnd_application
    WHERE application_short_name = 'SQLGL';

-- ------------------------------------------------------------------------
-- If this is a summary_record being inserted then get the DR_CR_CODE from
-- the corresponding summary ID.
-- ------------------------------------------------------------------------
   IF (p_det_sum_value = 'S') THEN

-- ------------------------------------------------------------------------
-- Obtain the funds_check_level_code and amount_type for the CCID that is
-- being inserted.
-- ------------------------------------------------------------------------
      OPEN c_igc_je_detail_info;

      FETCH c_igc_je_detail_info
       INTO l_amount_type,
            l_funds_level_code,
            l_cbc_override,
            l_budget_ver_id;

      IF (c_igc_je_detail_info%NOTFOUND) THEN

         l_funds_level_code := 'N';

         IF FND_API.TO_BOOLEAN(p_efc_enabled) THEN

            BEGIN

--              IF (IGC_MSGS_PKG.g_debug_mode) THEN
              IF g_debug_mode = 'Y' THEN
                 Put_Debug_Msg (l_full_path, 'Obtaining budget version from EFC tables' );
              END IF;
/*
--Commented for compilation - igc_cbc_summary_templates_v View does not exist Bug No 6341012

              EXECUTE IMMEDIATE l_efc_budget_str
                INTO l_amount_type,
                     l_funds_level_code,
                     l_cbc_override,
                     l_budget_ver_id
               USING p_set_of_books_id,
                     p_ccid,
                     p_set_of_books_id,
                     p_set_of_books_id,
                     l_gl_application_id,
                     l_gl_application_id,
                     p_effective_date;
*/
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 NULL;  --means no funding budget found for this period
	       WHEN OTHERS THEN
                 NULL;
            END;

         ELSE

--            IF (IGC_MSGS_PKG.g_debug_mode) THEN
            IF g_debug_mode = 'Y' THEN
               Put_Debug_Msg (l_full_path, 'Obtaining budget version from summary template table');
            END IF;
/*
-- Commented for compilation - cursor c_igc_je_summary_info is based on a dummy view Bug No 6341012
             OPEN c_igc_je_summary_info;
            FETCH c_igc_je_summary_info
             INTO l_amount_type,
                  l_funds_level_code,
                  l_cbc_override,
                  l_budget_ver_id;
*/
         END IF;

         IF (l_funds_level_code IS NULL) THEN

            -- Assign default level

            l_funds_level_code := 'N';

--            IF (IGC_MSGS_PKG.g_debug_mode) THEN
            IF g_debug_mode = 'Y' THEN
               Put_Debug_Msg (l_full_path, ' Detail Funds Level not found, assign N');
            END IF;

         ELSE

--            IF (IGC_MSGS_PKG.g_debug_mode) THEN
            IF g_debug_mode = 'Y' THEN
               Put_Debug_Msg (l_full_path, ' Summary Funds Level Received From Summary Templates.');
            END IF;

         END IF;

      ELSE

--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF g_debug_mode = 'Y' THEN
            Put_Debug_Msg (l_full_path, ' Summary Funds Level Received From Budget Assignments.');
         END IF;

      END IF;

   ELSE

-- ------------------------------------------------------------------------
-- Obtain the funds_check_level_code and amount_type for the CCID that is
-- being inserted.
-- ------------------------------------------------------------------------
      OPEN c_igc_je_detail_info;

      FETCH c_igc_je_detail_info
       INTO l_amount_type,
            l_funds_level_code,
            l_cbc_override,
            l_budget_ver_id;

      IF (c_igc_je_detail_info%NOTFOUND) THEN

         -- Assign default level

         l_funds_level_code := 'N';
--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF g_debug_mode = 'Y' THEN
            Put_Debug_Msg (l_full_path, ' Detail Funds Level not found, assign N');
         END IF;

      ELSE

--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF g_debug_mode = 'Y' THEN
            Put_Debug_Msg (l_full_path, ' Detail Funds Level Received From Budget Assignments');
         END IF;

      END IF;

   END IF;

   IF (NOT FND_API.TO_BOOLEAN(p_efc_enabled)) THEN

     l_funds_level_code := 'N';

--     IF (IGC_MSGS_PKG.g_debug_mode) THEN
     IF g_debug_mode = 'Y' THEN
         Put_Debug_Msg (l_full_path, ' BC is disabled, assigning severity level None ');
     END IF;

   END IF;

-- -------------------------------------------------------------------
-- Make sure that the Budget Version id is not NULL, amount type is
-- not NULL, and that the funds check level is anything but N.  If
-- this case is TRUE then the CCID can not be checked.
-- -------------------------------------------------------------------
   l_funds_level_code := NVL(l_funds_level_code, 'N');

   l_budget_ver_id := NVL(l_budget_ver_id,p_budget_ver_id);

   IF ((p_actual_flag = 'B') AND
       (p_budget_ver_id IS NOT NULL)) THEN

      l_budget_ver_id := p_budget_ver_id;

   END IF;

   IF ((p_actual_flag = 'B') AND
       (l_budget_ver_id IS NULL)) THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         Put_Debug_Msg (l_full_path, ' Actual Flag is B and Budget Version ID is NULL error.');
      END IF;
      message_token ('CCID', to_char(p_ccid));
      message_token ('SOB_ID', to_char(p_set_of_books_id));
      add_message ('IGC', 'IGC_BUDGET_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   IF ((l_funds_level_code <> 'N') AND
       (l_amount_type IS NULL) AND
       (l_budget_ver_id IS NULL)) THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         Put_Debug_Msg (l_full_path, ' Funds Check Level is : ' || l_funds_level_code );
         Put_Debug_Msg (l_full_path, ' Amount Type is NULL and Budget Version ID is NULL error.');
      END IF;
      message_token ('CCID', to_char(p_ccid));
      message_token ('SOB_ID', to_char(p_set_of_books_id));
      add_message ('IGC', 'IGC_INVALID_BUDGET_STATE');
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -------------------------------------------------------------------------
-- If the CBC-specific funds check level (cbc_override) has a value, and
-- the standard funds check level is NOT set to 'None', use the cbc_override
-- -------------------------------------------------------------------------
   IF ((l_cbc_override IS NOT NULL) AND
       (l_funds_level_code <> 'N')) THEN
       p_funds_level_code := l_cbc_override;
   ELSE
       p_funds_level_code  := l_funds_level_code;
   END IF;

   p_out_budget_ver_id := l_budget_ver_id;
   p_amount_type       := l_amount_type;

-- -------------------------------------------------------------------------
-- Close all cursors that have been opened in this procedure.
-- -------------------------------------------------------------------------
   IF (c_igc_je_detail_info%ISOPEN) THEN
      CLOSE c_igc_je_detail_info;
   END IF;
/*
-- Commented the cursor for compilation Bug No 6341012
   IF (c_igc_je_summary_info%ISOPEN) THEN
      CLOSE c_igc_je_summary_info;
   END IF;
*/

   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                               p_data  => p_msg_data );

   RETURN;

-- -------------------------------------------------------------------------
-- Exception handler section for the Get_CCID_Budget_Info procedure.
-- -------------------------------------------------------------------------
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Valid_Get_CCID_Bdg_Info_Pub;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
     IF (g_excep_level >=  g_debug_level ) THEN
         FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Valid_Get_CCID_Bdg_Info_Pub;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
     IF (g_excep_level >=  g_debug_level ) THEN
         FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;

  WHEN OTHERS THEN

    ROLLBACK TO Valid_Get_CCID_Bdg_Info_Pub;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;

END Validate_Get_CCID_Budget_Info;


/*=======================================================================+
 |                PROCEDURE Validate_Get_CCID_Period_Name                |
 |                                                                       |
 | Note : This procedure is designed to validate the CCID Period Name    |
 |        information based upon the rules defined for the CCID to be    |
 |        entered into the CBC Funds Checker process and inserted into   |
 |        the table IGC_CBC_JE_LINES.                                    |
 |                                                                       |
 |        If there is to be any changes inside of this procedure then    |
 |        there needs to be analysis performed on the effect it will have|
 |        on the Funds Checker process.                                  |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_sob_id             GL Set of Books ID to be processed             |
 |   p_effect_date        Transaction Date                               |
 |   p_check_type         Type of check Funds (FC) or Legacy (LC)        |
 |   p_period_name        Period name for CCID if found for Check type   |
 |   p_period_set_name    Period Set Name for CCID if found              |
 |   p_quarter_num        Quarter number for CCID if found               |
 |   p_period_num         Period Number for CCID if found                |
 |   p_period_year        Period Year for CCID if found                  |
 |   p_result_status      Result Code for updating line status           |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Validate_Get_CCID_Period_Name
(
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status             OUT NOCOPY VARCHAR2,
   p_msg_count                 OUT NOCOPY NUMBER,
   p_msg_data                  OUT NOCOPY VARCHAR2,

   p_sob_id                    IN gl_sets_of_books.set_of_books_id%TYPE,
   p_effect_date               IN igc_cbc_je_lines.effective_date%TYPE,
   p_check_type                IN VARCHAR2,
   p_period_name               OUT NOCOPY igc_cbc_je_lines.period_name%TYPE,
   p_period_set_name           OUT NOCOPY igc_cbc_je_lines.period_set_name%TYPE,
   p_quarter_num               OUT NOCOPY igc_cbc_je_lines.quarter_num%TYPE,
   p_period_num                OUT NOCOPY igc_cbc_je_lines.period_num%TYPE,
   p_period_year               OUT NOCOPY igc_cbc_je_lines.period_year%TYPE,
   p_result_status             OUT NOCOPY VARCHAR2
) IS

-- -------------------------------------------------------------------------
-- Declare local variables used within fuction
-- -------------------------------------------------------------------------
   l_api_name            CONSTANT VARCHAR2(30)   := 'Validate_Get_CCID_Period_Name';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_gl_application_id   fnd_application.application_id%TYPE;

-- --------------------------------------------------------------------------
-- Obtain the period information on the set of books ID and the effective
-- date range.  This is the period information to be added into the records
-- for the summary and detail account records.
-- --------------------------------------------------------------------------
   CURSOR c_igc_fc_period_info IS
      SELECT GPS.period_name,
             GP.period_set_name,
             GPS.period_num,
             GPS.period_year,
             GPS.quarter_num
        FROM gl_period_statuses GPS,
             gl_sets_of_books GP
       WHERE GPS.set_of_books_id        = p_sob_id
         AND GPS.application_id         = l_gl_application_id
         AND GPS.adjustment_period_flag = 'N'
         AND GP.set_of_books_id         = GPS.set_of_books_id
         -- AND to_date (p_effect_date)
         AND p_effect_date BETWEEN GPS.start_date AND GPS.end_date
         AND GPS.closing_status
             IN ('O','F');

-- --------------------------------------------------------------------------
-- Obtain the period information on the set of books ID and the effective
-- date range.  This is the period information to be added into the records
-- for the summary and detail account records.
-- --------------------------------------------------------------------------
   CURSOR c_igc_legacy_period_info IS
      SELECT GPS.period_name,
             GP.period_set_name,
             GPS.period_num,
             GPS.period_year,
             GPS.quarter_num
        FROM gl_period_statuses GPS,
             gl_sets_of_books GP
       WHERE GPS.set_of_books_id        = p_sob_id
         AND GPS.application_id         = l_gl_application_id
         AND GPS.adjustment_period_flag = 'N'
         AND GP.set_of_books_id         = GPS.set_of_books_id
         AND GPS.closing_status         = 'O'
         -- AND to_date (p_effect_date)
         AND p_effect_date BETWEEN GPS.start_date AND GPS.end_date;

   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Validate_Get_CCID_Period_Name';

   SAVEPOINT Valid_Get_CCID_Per_Name_Pub;

   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
    	                                l_api_name,
                                        G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
   END IF;

-- -------------------------------------------------------------------------
-- Initialize variables here.
-- -------------------------------------------------------------------------
   p_return_status   := FND_API.G_RET_STS_SUCCESS ;
   p_period_name     := NULL;
   p_period_set_name := NULL;
   p_quarter_num     := 0;
   p_period_num      := 0;
   p_period_year     := 0;
   p_result_status   := NULL;

-- --------------------------------------------------------------------
-- Obtain the application ID that will be used throughout this process.
-- --------------------------------------------------------------------
   SELECT application_id
     INTO l_gl_application_id
     FROM fnd_application
    WHERE application_short_name = 'SQLGL';

-- -------------------------------------------------------------------------
-- Based upon the type of check being performed open and fetch the period
-- information that is required using the appropriate Cursor.
-- -------------------------------------------------------------------------
   IF (p_check_type = 'FC') THEN

       OPEN c_igc_fc_period_info;
      FETCH c_igc_fc_period_info
       INTO p_period_name,
            p_period_set_name,
            p_period_num,
            p_period_year,
            p_quarter_num;

      IF (c_igc_fc_period_info%NOTFOUND) THEN
         p_result_status := 'F24';
--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF g_debug_mode = 'Y' THEN
            Put_Debug_Msg (l_full_path, ' Period Info not Found for Funds Check Open / Future Period.');
         END IF;
      END IF;

   ELSIF (p_check_type = 'LC') THEN

       OPEN c_igc_legacy_period_info;
      FETCH c_igc_legacy_period_info
       INTO p_period_name,
            p_period_set_name,
            p_period_num,
            p_period_year,
            p_quarter_num;

      IF (c_igc_legacy_period_info%NOTFOUND) THEN
         p_result_status := 'F24';
--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF g_debug_mode = 'Y' THEN
            Put_Debug_Msg (l_full_path, ' Period Info not Found for Legacy Data Open Period.');
         END IF;
      END IF;

   ELSE

      p_result_status := 'F24';
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         Put_Debug_Msg (l_full_path, ' Period Info not Found Invalid Check Type Passed in....');
      END IF;

   END IF;

-- -------------------------------------------------------------------------
-- Make sure that all cursors have been closed before leaving this procedure
-- -------------------------------------------------------------------------
   IF (c_igc_fc_period_info%ISOPEN) THEN
      CLOSE c_igc_fc_period_info;
   END IF;

   IF (c_igc_legacy_period_info%ISOPEN) THEN
      CLOSE c_igc_legacy_period_info;
   END IF;

   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                               p_data  => p_msg_data );

   RETURN;

-- -------------------------------------------------------------------------
-- Exception handler section for the Validate_Get_CCID_Period_Name procedure.
-- -------------------------------------------------------------------------
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Valid_Get_CCID_Per_Name_Pub;
    p_return_status := FND_API.G_RET_STS_ERROR;
    IF (c_igc_fc_period_info%ISOPEN) THEN
       CLOSE c_igc_fc_period_info;
    END IF;
    IF (c_igc_legacy_period_info%ISOPEN) THEN
       CLOSE c_igc_legacy_period_info;
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;
    RETURN;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Valid_Get_CCID_Per_Name_Pub;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (c_igc_fc_period_info%ISOPEN) THEN
       CLOSE c_igc_fc_period_info;
    END IF;
    IF (c_igc_legacy_period_info%ISOPEN) THEN
       CLOSE c_igc_legacy_period_info;
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
    END IF;
    RETURN;

  WHEN OTHERS THEN

    ROLLBACK TO Valid_Get_CCID_Per_Name_Pub;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (c_igc_fc_period_info%ISOPEN) THEN
       CLOSE c_igc_fc_period_info;
    END IF;
    IF (c_igc_legacy_period_info%ISOPEN) THEN
       CLOSE c_igc_legacy_period_info;
    END IF;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

    IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;

    RETURN;

END Validate_Get_CCID_Period_Name;


/*=======================================================================+
 |                  PROCEDURE Validate_Check_EFC_Enabled                 |
 |                                                                       |
 | Note : This procedure is designed to validate the CCID Period Name    |
 |        information based upon the rules defined for the CCID to be    |
 |        entered into the CBC Funds Checker process and inserted into   |
 |        the table IGC_CBC_JE_LINES.                                    |
 |                                                                       |
 |        If there is to be any changes inside of this procedure then    |
 |        there needs to be analysis performed on the effect it will have|
 |        on the Funds Checker process.                                  |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_sob_id             GL Set Of Books being processed                |
 |   p_efc_enabled        Enhanced Funds Checker enabled Flag            |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Validate_Check_EFC_Enabled
(
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status             OUT NOCOPY VARCHAR2,
   p_msg_count                 OUT NOCOPY NUMBER,
   p_msg_data                  OUT NOCOPY VARCHAR2,

   p_sob_id                    IN gl_sets_of_books.set_of_books_id%TYPE,
   p_efc_enabled               OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Declare the cursors to be used during this function run.
-- --------------------------------------------------------------------
   CURSOR c_efc_table (p_schema  VARCHAR2) IS
      SELECT '1'
        FROM all_tables
       WHERE table_name = 'PSA_EFC_OPTIONS'
       AND   owner = p_schema;

-- --------------------------------------------------------------------
-- Declare local variables used within fuction
-- --------------------------------------------------------------------
   l_api_name            CONSTANT VARCHAR2(30)   := 'Validate_Check_EFC_Enabled';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_enable              VARCHAR2(25);

   l_full_path         VARCHAR2(255);

   -- Added for Bug 3432148
   l_schema            fnd_oracle_userid.oracle_username%TYPE;
   l_prod_status       fnd_product_installations.status%TYPE;
   l_industry          fnd_product_installations.industry%TYPE;

BEGIN

   l_full_path := g_path || 'Validate_Check_EFC_Enabled';

   SAVEPOINT Validate_Check_EFC_Enabled_Pub;

   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
   END IF;

-- --------------------------------------------------------------------
-- Initialize variables here.
-- --------------------------------------------------------------------
   p_return_status   := FND_API.G_RET_STS_SUCCESS;
   p_efc_enabled     := FND_API.G_FALSE;

   -- Bug 3432148, added schema name in the query
   IF NOT fnd_installation.get_app_info (application_short_name	=> 'PSA',
			status			=> l_prod_status,
			industry		=> l_industry,
			oracle_schema		=> l_schema)
   THEN
      IF g_debug_mode = 'Y' THEN
         Put_Debug_Msg (l_full_path, 'fnd_installation.get_app_info returned FALSE  ');
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   OPEN c_efc_table(l_schema);
   FETCH c_efc_table INTO l_enable;

   IF (l_enable IS NOT NULL) THEN
     BEGIN
        EXECUTE IMMEDIATE
           'SELECT mult_funding_budgets_flag FROM psa_efc_options WHERE set_of_books_id = :1'
         INTO l_enable
        USING p_sob_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL; -- No record for this SOB: EFC is not enabled
     END;
   END IF;

   CLOSE c_efc_table;

   IF (l_enable = 'Y') THEN
      p_efc_enabled := FND_API.G_TRUE;
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         Put_Debug_Msg (l_full_path, 'EFC is enabled ');
      END IF;
   ELSE
      p_efc_enabled := FND_API.G_FALSE;
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         Put_Debug_Msg (l_full_path, 'EFC is NOT enabled ');
      END IF;
   END IF;

   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                               p_data  => p_msg_data );

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Validate_Get_CCID_Period_Name procedure.
-- --------------------------------------------------------------------
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Validate_Check_EFC_Enabled_Pub;
    p_return_status := FND_API.G_RET_STS_ERROR;
    p_efc_enabled := FND_API.G_FALSE;
    IF (c_efc_table%ISOPEN) THEN
       CLOSE c_efc_table;
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;
    RETURN;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Validate_Check_EFC_Enabled_Pub;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_efc_enabled := FND_API.G_FALSE;
    IF (c_efc_table%ISOPEN) THEN
       CLOSE c_efc_table;
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
    END IF;
    RETURN;

  WHEN OTHERS THEN

    ROLLBACK TO Validate_Check_EFC_Enabled_Pub;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_efc_enabled := FND_API.G_FALSE;
    IF (c_efc_table%ISOPEN) THEN
       CLOSE c_efc_table;
    END IF;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF ( g_unexp_level >= g_debug_level ) THEN
      FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
      FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;

    RETURN;

END Validate_Check_EFC_Enabled;


/*=======================================================================+
 |                  PROCEDURE Validate_CC_Interface                      |
 |                                                                       |
 | Note : This procedure is designed to validate the CC Interface table  |
 |        information based upon the rules defined for the CCID to be    |
 |        entered into the CBC Funds Checker process and inserted into   |
 |        the table IGC_CBC_JE_LINES.                                    |
 |                                                                       |
 |        If there is to be any changes inside of this procedure then    |
 |        there needs to be analysis performed on the effect it will have|
 |        on the Funds Checker process.                                  |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_sob_id             GL Set Or Books ID being processed             |
 |   p_cbc_enabled        Commitment Budgetary Control enabled flag      |
 |   p_cc_head_id         Contract Commitment Header ID                  |
 |   p_actl_flag          Actual Flag for GL processing                  |
 |   p_documt_type        Contract Commitment Document Type              |
 |   p_sum_line_num       Summary Template Line Number                   |
 |   p_cbc_flag           Is there CBC Lines present in table            |
 |   p_sbc_flag           Is there SBC Lines present in table            |
 |   p_packet_id          packet_id, if originated in Purchasing         |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Validate_CC_Interface
(
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status             OUT NOCOPY VARCHAR2,
   p_msg_count                 OUT NOCOPY NUMBER,
   p_msg_data                  OUT NOCOPY VARCHAR2,

   p_sob_id                    IN  gl_sets_of_books.set_of_books_id%TYPE,
   p_cbc_enabled               IN  VARCHAR2,
   p_cc_head_id                IN  igc_cbc_je_batches.cc_header_id%TYPE,
   p_actl_flag                 IN  VARCHAR2,
   p_documt_type               IN  igc_cc_interface.document_type%TYPE,
-- p_sum_line_num              OUT NOCOPY igc_cbc_je_lines.cbc_je_line_num%TYPE,
   p_cbc_flag                  OUT NOCOPY VARCHAR2,
   p_sbc_flag                  OUT NOCOPY VARCHAR2
-- p_packet_id                 IN  NUMBER
) IS

-- --------------------------------------------------------------------
-- Declare the cursors to be used during this function run.
-- --------------------------------------------------------------------
   CURSOR c_cbc_count IS    --Check if CBC records in the interface table
     SELECT count(*)
/*
	    ,max(batch_line_num)
*/
       FROM igc_cc_interface_v
      WHERE budget_dest_flag ='C'
        AND cc_header_id  = p_cc_head_id
        AND actual_flag   = p_actl_flag
        AND document_type = p_documt_type;

   CURSOR c_sbc_count IS    --Check if SBC records in the interface table
     SELECT count(*)
       FROM igc_cc_interface_v
      WHERE budget_dest_flag = 'S'
        AND cc_header_id  = p_cc_head_id
        AND actual_flag   = p_actl_flag
        AND document_type = p_documt_type;

   CURSOR c_sob_count IS    -- Check sob in the table, must be 1 or 0
     SELECT count(DISTINCT set_of_books_id)
       FROM igc_cc_interface_v
      WHERE cc_header_id     = p_cc_head_id
        AND actual_flag      = p_actl_flag
        AND document_type    = p_documt_type;

/*   THIS CHECK IS NOT REQIRED ANYMORE BECAUSE OF PA INTEGRATION
   CURSOR c_result_count IS    --Check result code in the table, must be 0
     SELECT count(*)
       FROM igc_cc_interface_v
      WHERE cc_header_id  = p_cc_head_id
        AND actual_flag   = p_actl_flag
        AND document_type = p_documt_type
        AND ( cbc_result_code IS NOT NULL
              OR status_code  IS NOT NULL );  */
/*
--R12 uptake. Encumbrance Details are seeded in R12. Bug No 6341012
   CURSOR c_enc_count IS    --Check encumbrance_type_id Must be 0
     SELECT count(*)
       FROM igc_cc_interface_v
      WHERE cc_header_id     = p_cc_head_id
        AND actual_flag      = 'E'
        AND document_type    = p_documt_type
        AND encumbrance_type_id IS NULL;
*/
-- ssmales 29/01/02 bug 2201905 - added three new cursors below
-- bug 2201905 start block
/*
--Packet ID does not exist in R12. Hence Commented. Bug No 6341012
   CURSOR c_cbc_count_packet IS    --Check if CBC records in the interface table
     SELECT count(*),
            max(batch_line_num)
       FROM igc_cc_interface_v
      WHERE budget_dest_flag ='C'
        AND reference_6   = p_packet_id
        AND actual_flag   = p_actl_flag ;

   CURSOR c_sbc_count_packet IS    --Check if SBC records in the interface table
     SELECT count(*)
       FROM igc_cc_interface_v
      WHERE budget_dest_flag = 'S'
        AND reference_6   = p_packet_id
        AND actual_flag   = p_actl_flag ;

   CURSOR c_enc_count_packet IS    --Check encumbrance_type_id Must be 0
     SELECT count(*)
       FROM igc_cc_interface_v
      WHERE reference_6      = p_packet_id
        AND actual_flag      = 'E'
        AND encumbrance_type_id IS NULL;
*/
-- bug 2201905 end block

-- -------------------------------------------------------------------------
-- Declare local variables used within fuction
-- -------------------------------------------------------------------------
   l_cbc_count     NUMBER := 0;
   l_sbc_count     NUMBER := 0;
   l_sob_count     NUMBER := 0;
   l_result_count  NUMBER := 0;
   l_enc_count     NUMBER := 0;
   l_api_name      CONSTANT VARCHAR2(30) := 'Validate_CC_Interface';
   l_api_version   CONSTANT NUMBER       :=  1.0;

   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Validate_CC_Interface';

   SAVEPOINT Validate_CC_Interface_Pub;

   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
   END IF;

-- -------------------------------------------------------------------------
-- Initialize variables here.
-- -------------------------------------------------------------------------
   p_return_status   := FND_API.G_RET_STS_SUCCESS ;
   p_cbc_flag        := FND_API.G_TRUE;
   p_sbc_flag        := FND_API.G_TRUE;


-- ssmales 29/01/02 bug 2201905 - added if block below
-- bug 2201905 start block
/*
R12 Uptake. Packet ID is obsolete. Bug No 6341012
Cursor no longer required
   IF (p_packet_id is not null) THEN

       OPEN c_cbc_count_packet;
       FETCH c_cbc_count_packet
       INTO l_cbc_count
       ,p_sum_line_num;


       CLOSE c_cbc_count_packet;

   ELSE
*/
-- bug 2201905 end block

       OPEN c_cbc_count;
       FETCH c_cbc_count
       INTO l_cbc_count;
--       ,p_sum_line_num;

       CLOSE c_cbc_count;

-- ssmales 29/01/02 bug 2201905 - added end if statement below
-- END IF ;

   IF (l_cbc_count = 0) THEN
      p_cbc_flag := FND_API.G_FALSE;
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         Put_Debug_Msg (l_full_path, ' No CBC Records in CC Interface ');
      END IF;
   END IF;

   Put_Debug_Msg (l_full_path, 'CBC flag: ' || p_cbc_flag || ' CBC Enabled: ' || p_cbc_enabled);

   IF FND_API.TO_BOOLEAN(p_cbc_flag) AND (NOT FND_API.TO_BOOLEAN(p_cbc_enabled))  THEN
      message_token ('SOB_ID', p_sob_id);
      add_message ('IGC', 'IGC_BC_NOT_ENABLED'); -- BC is disabled, no encumbrances allowed
      raise FND_API.G_EXC_ERROR;
   END IF;

-- ssmales 29/01/02 bug 2201905 - added if block below
-- bug 2201905 start block
/*
R12 Uptake. Packet ID is obsolete. Bug No 6341012
Cursor no longer required

   IF (p_packet_id is not null) THEN

      OPEN c_sbc_count_packet;
      FETCH c_sbc_count_packet
      INTO l_sbc_count;

      CLOSE c_sbc_count_packet;

   ELSE
*/
-- bug 2201905 end block

      OPEN c_sbc_count;
      FETCH c_sbc_count
      INTO l_sbc_count;

      CLOSE c_sbc_count;

-- ssmales 29/01/02 bug 2201905 - added end if statement below
-- END IF ;

   IF (l_sbc_count = 0) THEN
      p_sbc_flag := FND_API.G_FALSE;
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         Put_Debug_Msg (l_full_path, ' No SBC Records in CC Interface ');
      END IF;
   END IF;


/*   Changed per change request. No rows - no erorr thrown

   IF ((NOT FND_API.TO_BOOLEAN(p_sbc_flag)) AND
       (NOT FND_API.TO_BOOLEAN(p_cbc_flag))) THEN
      message_token ('CC_HEADER_ID', to_char(p_cc_head_id));
      message_token ('ACTUAL_FLAG', p_actl_flag);
      add_message ('IGC', 'IGC_VALIDATE_NO_ROWS'); --No rows in the interface table to check
      raise FND_API.G_EXC_ERROR;
   END IF;
*/

/*
-- Bidisha S, 2093525. Not quite sure whether this is required anymore
-- as we could have multiple set of books with MRC enabled.

    OPEN c_sob_count;
   FETCH c_sob_count
    INTO l_sob_count;

   CLOSE c_sob_count;

   IF (NVL(l_sob_count,0) > 1) THEN
      message_token ('CC_HEADER_ID', to_char(p_cc_head_id));
      message_token ('ACTUAL_FLAG', p_actl_flag);
      add_message ('IGC', 'IGC_VALIDATE_SOB'); --Not one set of books in the batch
      raise FND_API.G_EXC_ERROR;
   END IF;
*/


-- ssmales 29/01/02 bug 2201905 - added if block below
-- bug 2201905 start block
/*
R12 Uptake. Packet ID is obsolete. Bug No 6341012
Cursor no longer valid
   IF (p_packet_id is not null) THEN

      OPEN c_enc_count_packet;
      FETCH c_enc_count_packet
      INTO l_enc_count;

      CLOSE c_enc_count_packet;

   ELSE

-- bug 2201905 end block

      OPEN c_enc_count;
      FETCH c_enc_count
      INTO l_enc_count;

      CLOSE c_enc_count;

-- ssmales 29/01/02 bug 2201905 - added end if statement below
   END IF ;

   IF (l_enc_count <> 0) THEN
      message_token ('CC_HEADER_ID', to_char(p_cc_head_id));
      message_token ('ACTUAL_FLAG', 'E');
      add_message ('IGC', 'IGC_VALIDATE_ENC_CODE'); -- Records without encumbrance type id
      raise FND_API.G_EXC_ERROR;
   END IF;
*/
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                               p_data  => p_msg_data );

   RETURN;

-- -------------------------------------------------------------------------
-- Exception handler section for the Validate_Get_CCID_Period_Name procedure.
-- -------------------------------------------------------------------------
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Validate_CC_Interface_Pub;
    p_return_status := FND_API.G_RET_STS_ERROR;
    IF (c_cbc_count%ISOPEN) THEN
       CLOSE c_cbc_count;
    END IF;
    IF (c_sbc_count%ISOPEN) THEN
       CLOSE c_sbc_count;
    END IF;
    IF (c_sob_count%ISOPEN) THEN
       CLOSE c_sob_count;
    END IF;
/*
    IF (c_enc_count%ISOPEN) THEN
       CLOSE c_enc_count;
    END IF;
*/
-- ssmales 29/01/02 bug 2201905 - added block below
-- bug 2201905 start block
/*
    IF (c_cbc_count_packet%ISOPEN) THEN
       CLOSE c_cbc_count_packet;
    END IF;
    IF (c_sbc_count_packet%ISOPEN) THEN
       CLOSE c_sbc_count_packet;
    END IF;
    IF (c_enc_count_packet%ISOPEN) THEN
       CLOSE c_enc_count_packet;
    END IF;
*/
-- bug 2201905 end block
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;

    RETURN;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Validate_CC_Interface_Pub;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (c_cbc_count%ISOPEN) THEN
       CLOSE c_cbc_count;
    END IF;
    IF (c_sbc_count%ISOPEN) THEN
       CLOSE c_sbc_count;
    END IF;
    IF (c_sob_count%ISOPEN) THEN
       CLOSE c_sob_count;
    END IF;
-- ssmales 29/01/02 bug 2201905 - added block below
-- bug 2201905 start block
/*
    IF (c_cbc_count_packet%ISOPEN) THEN
       CLOSE c_cbc_count_packet;
    END IF;
    IF (c_sbc_count_packet%ISOPEN) THEN
       CLOSE c_sbc_count_packet;
    END IF;
    IF (c_enc_count_packet%ISOPEN) THEN
       CLOSE c_enc_count_packet;
    END IF;
*/
-- bug 2201905 end block
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
    END IF;

    RETURN;

  WHEN OTHERS THEN

    ROLLBACK TO Validate_CC_Interface_Pub;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (c_cbc_count%ISOPEN) THEN
       CLOSE c_cbc_count;
    END IF;
    IF (c_sbc_count%ISOPEN) THEN
       CLOSE c_sbc_count;
    END IF;
    IF (c_sob_count%ISOPEN) THEN
       CLOSE c_sob_count;
    END IF;
-- ssmales 29/01/02 bug 2201905 - added block below
-- bug 2201905 start block
/*
    IF (c_cbc_count_packet%ISOPEN) THEN
       CLOSE c_cbc_count_packet;
    END IF;
    IF (c_sbc_count_packet%ISOPEN) THEN
       CLOSE c_sbc_count_packet;
    END IF;
    IF (c_enc_count_packet%ISOPEN) THEN
       CLOSE c_enc_count_packet;
    END IF;
*/
-- bug 2201905 end block
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    IF ( g_unexp_level >= g_debug_level ) THEN
      FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
      FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;

    RETURN;

END Validate_CC_Interface;
END IGC_CBC_VALIDATIONS_PKG;


/
