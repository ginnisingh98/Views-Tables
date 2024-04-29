--------------------------------------------------------
--  DDL for Package Body IGC_CC_ARCHIVE_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_ARCHIVE_PURGE_PKG" AS
/* $Header: IGCCAPRB.pls 120.14.12010000.2 2008/08/29 13:08:10 schakkin ship $ */

-- Types :

-- Constants :

   g_pkg_name             CONSTANT VARCHAR2(30) := 'IGC_CC_ARCHIVE_PURGE_PKG';

-- Private Global Variables :

   g_debug_msg            VARCHAR2(10000) := NULL;
   g_update_login         igc_cc_headers.last_update_login%TYPE;
   g_update_by            igc_cc_headers.last_updated_by%TYPE;
   g_mrc_installed        VARCHAR2(1);
   g_mode                 VARCHAR2(2);
   g_last_activity_date   igc_cc_archive_history.user_req_last_activity_date%TYPE;
   g_org_id               igc_cc_headers.org_id%TYPE;
   g_sob_id               igc_cc_headers.set_of_books_id%TYPE;
   g_cc_num               igc_cc_headers.cc_num%TYPE;
   g_maxloops             CONSTANT   NUMBER(2) := 20;
   g_seconds              CONSTANT   NUMBER(2) := 10;
   g_validation_error     BOOLEAN := FALSE;

--   g_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
   g_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
    g_ledger_name               GL_LEDGERS.Name%TYPE;  /*Added this param during MOAC uptake to just call MO_UTILS.GET_LEDGER_INFO.*/
--Variables for ATG Central logging
   g_debug_level       NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_state_level       NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
   g_proc_level        NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
   g_event_level       NUMBER	:=	FND_LOG.LEVEL_EVENT;
   g_excep_level       NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
   g_error_level       NUMBER	:=	FND_LOG.LEVEL_ERROR;
   g_unexp_level       NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
   g_path              VARCHAR2(255) := 'IGC.PLSQL.IGCCAPRB.IGC_CC_ARCHIVE_PURGE_PKG.';

-- ---------------------------------------------------------------------
-- Private Function Definition:
-- ---------------------------------------------------------------------

--
-- Main procedure that performs the operation of the chosen mode.
--
PROCEDURE Arch_Pur_CC
(
   p_api_version          IN NUMBER,
   p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
   p_last_activity_date   IN igc_cc_archive_history.user_req_last_activity_date%TYPE,
   p_mode                 IN VARCHAR2,
   p_debug_flag           IN VARCHAR2 := FND_API.G_FALSE,
   p_commit_work          IN VARCHAR2 := FND_API.G_FALSE,
   x_Return_Status       OUT NOCOPY VARCHAR2
);

--
-- Archive CC Procedure
--
PROCEDURE Archive_CC (
   x_Return_Status       OUT NOCOPY VARCHAR2
);

--
-- Archive NON MRC tables Procedure
--
PROCEDURE Archive_NON_MRC_Tbls (
   x_return_status       OUT NOCOPY VARCHAR2
);

--
-- Archive MRC Tables Procedure
--
PROCEDURE Archive_MRC_Tbls (
   x_return_status       OUT NOCOPY VARCHAR2
);

--
-- Build Candidate List Procedure
--
PROCEDURE Build_Candidate_List (
   x_return_status       OUT NOCOPY VARCHAR2
);

--
-- Check for MRC being enabled procedure
--
PROCEDURE Check_MRC (
   x_Return_Status       OUT NOCOPY VARCHAR2
);

--
-- Cleanup archive MRC tables of existing records before Archive is done
--
PROCEDURE Cleanup_MRC_Arc_Tbls (
   x_return_status       OUT NOCOPY VARCHAR2
);

--
-- Cleanup archive tables of existing records before Archive is done
--
PROCEDURE Cleanup_NON_MRC_Arc_Tbls (
   x_return_status       OUT NOCOPY VARCHAR2
);

--
-- Initializing History Record procedure
--
PROCEDURE Initialize_History_Record (
   p_cc_header_id         IN igc_cc_archive_history.cc_header_id%TYPE,
   p_History_Rec      IN OUT NOCOPY igc_cc_archive_history%ROWTYPE,
   x_Return_Status       OUT NOCOPY VARCHAR2
);

--
-- Procedure designed to insert history records for all records archived.
--
PROCEDURE Insert_Archive_History (
   x_Return_Status       OUT NOCOPY VARCHAR2
);

--
-- Procedure to lock the temp table IGC_CC_ARC_PUR_CANDIDATES.  If the table
-- can be locked then the process can proceed.
--
FUNCTION Lock_Candidates RETURN BOOLEAN;

--
-- Generic Procedure for putting out debug information
--
PROCEDURE Output_Debug (
   p_path             IN VARCHAR2,
   p_debug_msg        IN VARCHAR2
);

--
-- Purge CC Procedure
--
PROCEDURE Purge_CC (
   x_Return_Status       OUT NOCOPY VARCHAR2
);

--
-- Purge NON MRC tables Procedure
--
PROCEDURE Purge_NON_MRC_Tbls (
   x_return_status       OUT NOCOPY VARCHAR2
);

--
-- Purge MRC Tables Procedure
--
PROCEDURE Purge_MRC_Tbls (
   x_return_status       OUT NOCOPY VARCHAR2
);

--
-- Procedure for Updating the CC ARCHIVE History table
--
PROCEDURE Update_History
(
   p_History_Rec          IN igc_cc_archive_history%ROWTYPE,  -- History Record
   x_Return_Status        OUT NOCOPY VARCHAR2                         -- Status of procedure
);

--
-- Validation on Inputs procedure
--
PROCEDURE Validate_Inputs (
   x_Return_Status       OUT NOCOPY VARCHAR2
);

--
-- Function to return the Set Of Books ID to the caller.
--
-- Parameters :
--     None
--
FUNCTION Get_SOB_ID
RETURN NUMBER
IS

BEGIN
   RETURN (g_sob_id);
END Get_SOB_ID;


--
-- Function to return the ORG ID to the caller
--
-- Parameters :
--     None
--
FUNCTION Get_ORG_ID
RETURN NUMBER
IS

BEGIN
   RETURN (g_org_id);
END Get_ORG_ID;

--
-- Function to return the input of the last activity date to be archived / purged
--
-- Parameters :
--     None
--
FUNCTION Get_Last_Activity_Date
RETURN DATE
IS

BEGIN
   RETURN (g_last_activity_date);
END Get_Last_Activity_Date;

--
-- Request Procedure called from Concurrent Request Operation
--
-- Parameters :
--
-- errbuf                   ==> Error Buffer for Concurrent Request.
-- retcode                  ==> Return Code for the Concurrent Request.
-- p_req_mode               ==> P = Purge A = Archive B = Both
-- p_req_last_activity_date ==> last activity date that is to be archievd/purged.
-- p_req_commit_work        ==> Boolean indicating if this process should commit work or not
--

PROCEDURE Archive_Purge_CC_Request
(
   errbuf                  OUT NOCOPY VARCHAR2,
   retcode                 OUT NOCOPY NUMBER,
   p_req_mode               IN VARCHAR2,
   p_req_last_activity_date IN VARCHAR2
) IS
-- --------------------------------------------------------------------
-- Define Local Variables to be used.
-- --------------------------------------------------------------------
   l_debug          VARCHAR2 (1);
   l_Return_Status  VARCHAR2 (1);
   l_init_msg       VARCHAR2 (1) := FND_API.G_TRUE;
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(12000);
   l_error_text     VARCHAR2(12000);
   l_api_version    NUMBER := 1.0;
   l_commit_work    VARCHAR2(1);
   l_date_request   DATE;

   l_option_name    VARCHAR2(80);
   lv_message       VARCHAR2(1000);
   l_full_path         VARCHAR2(255);
BEGIN

  l_full_path := g_path || 'Archive_Purge_CC_Request';

   -- 01/03/02, check to see if CC is installed
   -- code will remain commented out for now

   IF igi_gen.is_req_installed('CC',mo_global.get_current_org_id) = 'N' THEN

      SELECT meaning
      INTO l_option_name
      FROM igi_lookups
      WHERE lookup_code = 'CC'
      AND lookup_type = 'GCC_DESCRIPTION';

      FND_MESSAGE.SET_NAME('IGI', 'IGI_GEN_PROD_NOT_INSTALLED');
      FND_MESSAGE.SET_TOKEN('OPTION_NAME', l_option_name);
      lv_message := fnd_message.get;
      IF (g_error_level >=  g_debug_level ) THEN
          FND_LOG.MESSAGE (g_error_level , l_full_path,FALSE);
      END IF;
      errbuf := lv_message;
      retcode := 2;
      return;
   END IF;

--   l_debug       := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');
   l_commit_work := FND_API.G_TRUE;

--   IF (l_debug = 'Y') THEN
   IF (g_debug_mode = 'Y') THEN
      l_debug := FND_API.G_TRUE;
   ELSE
      l_debug := FND_API.G_FALSE;
   END IF;

   l_date_request := to_date (p_req_last_activity_date, 'YYYY/MM/DD HH24:MI:SS');

   Arch_Pur_CC (p_api_version        => l_api_version,
                p_init_msg_list      => l_init_msg,
	        p_mode               => p_req_mode,
                p_last_activity_date => l_date_request,
                p_debug_flag         => l_debug,
                p_commit_work        => l_commit_work,
                x_return_status      => l_Return_Status);

   IF (l_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN

      errbuf  := 'Normal Completion For Request';
      retcode := 0;

   ELSE

      errbuf  := 'Abnormal Completion For Request.  Check file for Errors.';
      retcode := 2;

   END IF;

   FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                               p_data  => l_msg_data );

   IF (l_msg_count > 0) THEN

      l_error_text := '';
      FOR l_cur IN 1..l_msg_count LOOP
--         l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
         l_error_text := l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
         IF (g_excep_level >=  g_debug_level ) THEN
            FND_LOG.STRING (g_excep_level,l_full_path,l_error_text);
		 END IF;
         fnd_file.put_line (FND_FILE.LOG,
                            l_error_text);
      END LOOP;

   ELSE

      IF (g_validation_error) THEN
         l_error_text := 'Error Returned but Error stack has no data';
         IF (g_excep_level >=  g_debug_level ) THEN
            FND_LOG.STRING (g_excep_level,l_full_path,l_error_text);
		 END IF;
         fnd_file.put_line (FND_FILE.LOG,
                            l_error_text);
      END IF;

   END IF;


   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Arch_Pur_CBC procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN OTHERS THEN
      errbuf  := 'Abnormal Completion For Request';
      retcode := 2;
      IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Archive_Purge_CC_Request');
      END IF;

      FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                  p_data  => l_msg_data );

      IF (l_msg_count > 0) THEN

         l_error_text := '';
         FOR l_cur IN 1..l_msg_count LOOP
--            l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
            l_error_text := l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
            IF (g_excep_level >=  g_debug_level ) THEN
                FND_LOG.STRING (g_excep_level,l_full_path,l_error_text);
		    END IF;
            fnd_file.put_line (FND_FILE.LOG,
                               l_error_text);
         END LOOP;
      ELSE
         l_error_text := 'Error Returned but Error stack has no data';
         fnd_file.put_line (FND_FILE.LOG,
                            l_error_text);
      END IF;
      RETURN;

END Archive_Purge_CC_Request;

--
-- Main Procedure for Archiving and Purging the CC tables
--
-- Parameters :
--
-- p_api_version        ==> Version of procedure to be executed if available.
-- p_init_msg_list      ==> Variable to determine if the message stack is to be initialized.
-- p_last_activity_date ==> last date record activity took place
-- p_mode               ==> Archive ("AR"), Pre-Purge ("PP"), Purge ("PU")
-- p_debug_flag         ==> Is debug enabled
-- p_commit_work        ==> Boolean indicating if this process should commit work or not
-- x_Return_Status      ==> Status of procedure returned to caller
--
PROCEDURE Arch_Pur_CC
(
   p_api_version          IN NUMBER,
   p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
   p_last_activity_date   IN igc_cc_archive_history.user_req_last_activity_date%TYPE,
   p_mode                 IN VARCHAR2,
   p_debug_flag           IN VARCHAR2 := FND_API.G_FALSE,
   p_commit_work          IN VARCHAR2 := FND_API.G_FALSE,
   x_Return_Status        OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Define local variables to be used
-- --------------------------------------------------------------------
   l_Return_Status            VARCHAR2(1);
   l_api_name                 CONSTANT VARCHAR2(30) := 'Arch_Pur_CC';
   l_stage1_parent_req        NUMBER;
   l_stage1_wait_for_request  BOOLEAN;
   l_stage1_phase             VARCHAR2(240);
   l_stage1_status            VARCHAR2(240);
   l_stage1_dev_phase         VARCHAR2(240);
   l_stage1_dev_status        VARCHAR2(240);
   l_stage1_message           VARCHAR2(240);
   l_api_version              NUMBER := 1.0;

--Variable for holding error message
   l_error_text               VARCHAR2(500);
   l_full_path         VARCHAR2(255);
   -- Varibles used for xml report
   l_terr                     VARCHAR2(10):='US';
   l_lang                     VARCHAR2(10):='en';
   l_layout                   BOOLEAN;

-- --------------------------------------------------------------------
-- Define cursors to be used in main archive/purge procedure
-- --------------------------------------------------------------------

BEGIN

   l_full_path := g_path || 'Arch_Pur_CC';

   SAVEPOINT Archive_Purge_CC_PVT;

-- --------------------------------------------------------------------
-- Make sure that the appropriate version is being used and initialize
-- the message stack if required.
-- --------------------------------------------------------------------
   IF (NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   IF (FND_API.to_Boolean ( p_init_msg_list )) THEN
      FND_MSG_PUB.initialize ;
   END IF;

-- --------------------------------------------------------------------
-- Attempt to lock the table and if able to lock continue with process
-- otherwise exit after too long a wait.
-- --------------------------------------------------------------------
   IF (NOT Lock_Candidates) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

-- --------------------------------------------------------------------
-- Initialize Return status and other local variables.
-- --------------------------------------------------------------------
   x_Return_Status           := FND_API.G_RET_STS_SUCCESS;
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(p_debug_flag);
   g_update_login            := FND_GLOBAL.LOGIN_ID;
   g_update_by               := FND_GLOBAL.USER_ID;
   g_mode                    := p_mode;
   g_last_activity_date      := p_last_activity_date;
   /* Commented below two lines during r12 MOAC uptake
   g_org_id                  := TO_NUMBER (FND_PROFILE.value ('ORG_ID'));
   g_sob_id                  := TO_NUMBER (FND_PROFILE.value ('GL_SET_OF_BKS_ID')); */
	g_org_id := mo_global.get_current_org_id;
   	mo_utils.get_ledger_info(p_operating_unit => g_org_id,
                           	 p_ledger_id      => g_sob_id,
                           	 p_ledger_name    => g_ledger_name);
	/*	Select set_of_books_id into g_sob_id
	FROM hr_operating_units WHERE organization_id = p_org_id;*/

   IF p_debug_flag = FND_API.G_TRUE THEN
      g_debug_mode := 'Y';
   ELSE
      g_debug_mode := 'N';
   END IF;
-- --------------------------------------------------------------------
-- Initialize debug information if the user has requested debug to
-- be turned on.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' ************ Starting ARCHIVE / PURGE CC '||
                     to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************';
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      g_debug_msg := ' Parameters Activity Date:' || g_last_activity_date ||
                     ' Org ID : ' || g_org_id ||
                     ' SOB ID : ' || g_sob_id ||
                     ' Mode : ' || g_mode;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Make sure that all the inputs that are given are valid and make
-- sure that the values given and obtained are ok to continue with the
-- archive / purge process.
-- --------------------------------------------------------------------
   Validate_Inputs (x_return_status => l_return_status);

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

-- --------------------------------------------------------------------
-- Determine if MRC is available and set global variables accordingly.
-- --------------------------------------------------------------------
   Check_MRC (x_return_status => l_return_status);

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

-- --------------------------------------------------------------------
-- Build the table for candidate CC Header IDS that can be archived
-- and or purged.
-- --------------------------------------------------------------------
   Build_Candidate_List (x_return_status => l_return_status);

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

-- --------------------------------------------------------------------
-- Archive Process is to be run if user has given the mode to be 'A' or
-- 'B'.  This process will archive the LINES and BATCHES for CC.  The
-- records to be archived will be for NON MRC and MRC records.
-- --------------------------------------------------------------------
   IF (NOT g_validation_error) THEN

      IF (g_mode = 'AR') THEN

--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := ' Calling Procedure to Archive for Last Activity Date : ' ||
                           g_last_activity_date;
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;

         Archive_CC (x_Return_Status => l_Return_Status);

         IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
            raise FND_API.G_EXC_ERROR;
         END IF;

-- --------------------------------------------------------------------
-- Purge process is to be run if user has given the mode to be 'P' or
-- 'B'.  This process will purge the LINES and BATCHES for CC.  The
-- records to be purged will be for NON MRC and MRC records.
-- --------------------------------------------------------------------
      ELSIF (g_mode = 'PU') THEN

--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := ' Calling Procedure to Purge for Last Activity Date : ' ||
                           g_last_activity_date;
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;

         Purge_CC (x_Return_Status => l_Return_Status);

         IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
            raise FND_API.G_EXC_ERROR;
         END IF;

      END IF;

   ELSE

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' Validation error happened for Last Activity Date : ' ||
                        g_last_activity_date;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

   END IF;

-- --------------------------------------------------------------------
-- Run the appropriate report to give the user insight into what has
-- or will be done for the archive/purge process.
-- --------------------------------------------------------------------
   l_stage1_parent_req := FND_REQUEST.SUBMIT_REQUEST
                          ('IGC',
                           'IGCCAPRR',
                           NULL,
                           NULL,
                           FALSE,
                           to_char(g_last_activity_date),
                           g_mode,
                           to_char(g_sob_id),
                           to_char(g_org_id)
                          );

   IF (l_stage1_parent_req > 0) THEN
      /*FND_FILE.PUT_LINE (FND_FILE.LOG,
                         'IGC_CC_ARCHIVE_PURGE_PKG -  IGCCAPRR request Submitted ');*/
	  IF(g_event_level >= g_debug_level) THEN
		    	FND_LOG.STRING(g_event_level, l_full_path, 'IGC_CC_ARCHIVE_PURGE_PKG -  IGCCAPRR request Submitted ');
	  END IF;
      COMMIT;
   ELSE

      FND_FILE.PUT_LINE (FND_FILE.LOG,
                         'IGC_CC_ARCHIVE_PURGE_PKG - IGCCAPRR error submitting request');
      /*raise_application_error (-20000,
                               'IGC_CC_ARCHIVE_PURGE_PKG - error submitting IGCCAPRR '||
                               SQLERRM || '-' || SQLCODE);*/

           IF ( g_unexp_level >= g_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( g_unexp_level,l_full_path,TRUE);
           END IF;

	  FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_USER_ERROR');
	  l_error_text := FND_MESSAGE.GET;
      raise_application_error (-20000, l_error_text);

   END IF;

   /*FND_FILE.PUT_LINE (FND_FILE.LOG,
                      'IGC_CC_ARCHIVE_PURGE_PKG - waiting for IGCCAPRR request to finish... ');*/
	  IF(g_state_level >= g_debug_level) THEN
		    	FND_LOG.STRING(g_state_level, l_full_path, 'IGC_CC_ARCHIVE_PURGE_PKG - waiting for IGCCAPRR request to finish... ');
	  END IF;

   l_stage1_wait_for_request := FND_CONCURRENT.WAIT_FOR_REQUEST (l_stage1_parent_req,
                                                                 05,
                                                                 0,
                                                                 l_stage1_phase,
                                                                 l_stage1_status,
                                                                 l_stage1_dev_phase,
                                                                 l_stage1_dev_status,
                                                                 l_stage1_message);
   /*FND_FILE.PUT_LINE (FND_FILE.LOG,
                      'IGC_CC_ARCHIVE_PURGE_PKG - finished... checking status of IGCCAPRR request');*/

   IF(g_event_level >= g_debug_level) THEN
	   FND_LOG.STRING(g_event_level, l_full_path, 'IGC_CC_ARCHIVE_PURGE_PKG - finished... checking status of IGCCAPRR request');
   END IF;

   IF ((l_stage1_dev_phase = 'COMPLETE') AND
       (l_stage1_dev_status = 'NORMAL')) THEN
      FND_FILE.PUT_LINE (FND_FILE.LOG,
                         'IGC_CC_ARCHIVE_PURGE_PKG - COMPLETE / NORMAL status of IGCCAPRR request');

	  IF(g_event_level >= g_debug_level) THEN
		   FND_LOG.STRING(g_event_level, l_full_path, 'IGC_CC_ARCHIVE_PURGE_PKG - COMPLETE / NORMAL status of IGCCAPRR request');
	  END IF;
   ELSE
      /*FND_FILE.PUT_LINE (FND_FILE.LOG,
                         'IGC_CC_ARCHIVE_PURGE_PKG - FAILED status of IGCCAPRR request');*/
      raise FND_API.G_EXC_ERROR;
   END IF;

-- --------------------------------------------------------------------
-- Run the xml report to give the user insight into what has
-- or will be done for the archive/purge process in the xml format.
-- --------------------------------------------------------------------

  IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCAPRR_XML',
                                            'IGC',
                                            'IGCCAPRR_XML' );

               l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCAPRR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');

               IF l_layout then
                   l_stage1_parent_req := FND_REQUEST.SUBMIT_REQUEST
                          ('IGC',
                           'IGCCAPRR_XML',
                           NULL,
                           NULL,
                           FALSE,
                           to_char(g_last_activity_date),
                           g_mode,
                           to_char(g_sob_id),
                           to_char(g_org_id)
                          );
               END if;
        IF (l_stage1_parent_req > 0) THEN
      /*FND_FILE.PUT_LINE (FND_FILE.LOG,
                         'IGC_CC_ARCHIVE_PURGE_PKG -  IGCCAPRR request Submitted ');*/
	         IF(g_event_level >= g_debug_level) THEN
		    	FND_LOG.STRING(g_event_level, l_full_path, 'IGC_CC_ARCHIVE_PURGE_PKG -  IGCCAPRR_XML request Submitted ');
	         END IF;
              COMMIT;
        ELSE

           FND_FILE.PUT_LINE (FND_FILE.LOG,
                         'IGC_CC_ARCHIVE_PURGE_PKG - IGCCAPRR_XML error submitting request');
                 /*raise_application_error (-20000,
                               'IGC_CC_ARCHIVE_PURGE_PKG - error submitting IGCCAPRR_XML '||
                               SQLERRM || '-' || SQLCODE);*/

           IF ( g_unexp_level >= g_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( g_unexp_level,l_full_path,TRUE);
           END IF;

	   FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_USER_ERROR');
	   l_error_text := FND_MESSAGE.GET;
           raise_application_error (-20000, l_error_text);
        END IF;
          /*FND_FILE.PUT_LINE (FND_FILE.LOG,
                      'IGC_CC_ARCHIVE_PURGE_PKG - waiting for IGCCAPRR_XML request to finish... ');*/
	IF(g_state_level >= g_debug_level) THEN
	 	FND_LOG.STRING(g_state_level, l_full_path, 'IGC_CC_ARCHIVE_PURGE_PKG - waiting for IGCCAPRR_XML request to finish... ');
	END IF;

        l_stage1_wait_for_request := FND_CONCURRENT.WAIT_FOR_REQUEST (l_stage1_parent_req,
                                                                 05,
                                                                 0,
                                                                 l_stage1_phase,
                                                                 l_stage1_status,
                                                                 l_stage1_dev_phase,
                                                                 l_stage1_dev_status,
                                                                 l_stage1_message);
              /*FND_FILE.PUT_LINE (FND_FILE.LOG,
                      'IGC_CC_ARCHIVE_PURGE_PKG - finished... checking status of IGCCAPRR_XML request');*/

         IF(g_event_level >= g_debug_level) THEN
 	      FND_LOG.STRING(g_event_level, l_full_path, 'IGC_CC_ARCHIVE_PURGE_PKG - finished... checking status of IGCCAPRR_XML request');
         END IF;

        IF ((l_stage1_dev_phase = 'COMPLETE') AND
         (l_stage1_dev_status = 'NORMAL')) THEN
           FND_FILE.PUT_LINE (FND_FILE.LOG,'IGC_CC_ARCHIVE_PURGE_PKG - COMPLETE / NORMAL status of IGCCAPRR_XML request');

	       IF(g_event_level >= g_debug_level) THEN
		   FND_LOG.STRING(g_event_level, l_full_path, 'IGC_CC_ARCHIVE_PURGE_PKG - COMPLETE / NORMAL status of IGCCAPRR_XML request');
	       END IF;
         ELSE
      /*FND_FILE.PUT_LINE (FND_FILE.LOG,
                         'IGC_CC_ARCHIVE_PURGE_PKG - FAILED status of IGCCAPRR_XML request');*/
               raise FND_API.G_EXC_ERROR;
         END IF;
  END IF;

-- -----------------
-- End of XML Report
-- -----------------


-- --------------------------------------------------------------------
-- Cleanup the candidate list table before exiting.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_arc_pur_candidates;

-- --------------------------------------------------------------------
-- Commit the cleanup that has been performed.
-- --------------------------------------------------------------------
   COMMIT;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Arch_Pur_CC procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       ROLLBACK TO Archive_Purge_CC_PVT;
       IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
       END IF;
       RETURN;

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       ROLLBACK TO Archive_Purge_CC_PVT;
       IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       ROLLBACK TO Archive_Purge_CC_PVT;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Arch_Pur_CC;

--
-- Archive CC Procedure
--
-- Parameters :
--
-- x_Return_Status       ==> Status of procedure returned to caller
--
PROCEDURE Archive_CC (
   x_Return_Status       OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Declare local variables to be used in this procedure.
-- --------------------------------------------------------------------
   l_api_name            CONSTANT VARCHAR2(30)   := 'Archive_CC';
   l_Return_Status       VARCHAR2(1);
   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Archive_CC';

-- --------------------------------------------------------------------
-- Initialize Return status and other local variables.
-- --------------------------------------------------------------------
   x_Return_Status       := FND_API.G_RET_STS_SUCCESS;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Beginning Archive process for Last Activity Date : ' ||
                     g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Cleanup MRC Archive tables of records that could be present.
-- --------------------------------------------------------------------
   IF (g_mrc_installed = 'Y') THEN

      Cleanup_MRC_Arc_Tbls (x_return_status => l_return_status);

      IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

   ELSE

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' NOT deleting records from Archive MRC tables for' ||
                        ' Last Activity Date : ' || g_last_activity_date;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         g_debug_msg := ' MRC is not enabled or installed for SOB ID : ' ||
                        to_char(g_sob_id);
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

   END IF;

-- -------------------------------------------------------------------
-- Delete any records in the archive tables that may be present for
-- the Header, set_of_books, and cc_number.
-- -------------------------------------------------------------------
   Cleanup_NON_MRC_Arc_Tbls (x_return_status => l_return_status);

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

-- ------------------------------------------------------------------
-- Now that the tables have been cleaned up of any pre-existing data
-- begin the archiving / copying of data into the archive tables.
-- ------------------------------------------------------------------
   IF (g_mrc_installed = 'Y') THEN

      Archive_MRC_Tbls (x_return_status => l_return_status);

      IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

   ELSE

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' NOT Archiving records from MRC tables for' ||
                        ' Last Activity Date : ' || g_last_activity_date;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         g_debug_msg := ' MRC is not enabled or installed for SOB ID : ' ||
                        to_char(g_sob_id);
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

   END IF;

-- -------------------------------------------------------------------
-- Archive any records from the original NON MRC tables that have not
-- been updated since the date entered for the ORG ID given.
-- -------------------------------------------------------------------
   Archive_NON_MRC_Tbls (x_return_status => l_return_status);

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

-- --------------------------------------------------------------------
-- For all the Headers that were just archived insert the corresponding
-- records into the Archive History Table.
-- --------------------------------------------------------------------
   Insert_Archive_History (x_return_status => l_return_status);

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Archive_CC procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
       END IF;
       RETURN;

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Archive_CC;

--
-- Archive_MRC_Tbls Procedure
--
-- Parameters :
--
-- x_Return_Status       ==> Status of procedure returned to caller
--
PROCEDURE Archive_MRC_Tbls (
   x_return_status       OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Declare local variables to be used in this procedure.
-- --------------------------------------------------------------------
   l_api_name            CONSTANT VARCHAR2(30)   := 'Archive_MRC_Tbls';
   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Archive_MRC_Tbls';

-- --------------------------------------------------------------------
-- Initialize Return status and other local variables.
-- --------------------------------------------------------------------
   x_Return_Status       := FND_API.G_RET_STS_SUCCESS;

-- --------------------------------------------------------------------
-- Insert all records that are able to be inserted based upon the
-- last activity date and org id from the original MRC tables into the
-- archive MRC tables.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_mc_headers
	(CC_HEADER_ID,
	SET_OF_BOOKS_ID,
	CONVERSION_TYPE,
	CONVERSION_DATE,
	CONVERSION_RATE)
   SELECT
	CC_HEADER_ID,
	SET_OF_BOOKS_ID,
	CONVERSION_TYPE,
	CONVERSION_DATE,
	CONVERSION_RATE
     FROM igc_cc_mc_headers CMH
    WHERE CMH.cc_header_id IN
          ( SELECT ICV.cc_header_id
              FROM igc_arc_pur_candidates ICV
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows in MC Headers Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Make sure that only the period that is closed and matches the period
-- name are inserted into the IGC_CC_ARCHIVE_MC_JE_LINES table.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_mc_header_hist
	(CC_HEADER_ID,
	SET_OF_BOOKS_ID,
	CC_VERSION_NUM,
	CC_VERSION_ACTION,
	CONVERSION_TYPE,
	CONVERSION_DATE,
	CONVERSION_RATE)
   SELECT
	CC_HEADER_ID,
	SET_OF_BOOKS_ID,
	CC_VERSION_NUM,
	CC_VERSION_ACTION,
	CONVERSION_TYPE,
	CONVERSION_DATE,
	CONVERSION_RATE
     FROM igc_cc_mc_header_history CMHH
    WHERE CMHH.cc_header_id IN
          ( SELECT ICV.cc_header_id
              FROM igc_arc_pur_candidates ICV
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows in MC Headers Hist Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Insert all records that are able to be inserted based upon the
-- last activity date and org id from the original MRC tables into the
-- archive MRC tables.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_mc_acct_lines
	(CC_ACCT_LINE_ID,
	SET_OF_BOOKS_ID,
	CC_ACCT_FUNC_AMT ,
	CC_ACCT_ENCMBRNC_AMT,
	CONVERSION_TYPE,
	CONVERSION_DATE,
	CONVERSION_RATE,
	CC_FUNC_WITHHELD_AMT)
   SELECT
	CC_ACCT_LINE_ID,
	SET_OF_BOOKS_ID,
	CC_ACCT_FUNC_AMT ,
	CC_ACCT_ENCMBRNC_AMT,
	CONVERSION_TYPE,
	CONVERSION_DATE,
	CONVERSION_RATE,
	CC_FUNC_WITHHELD_AMT
     FROM igc_cc_mc_acct_lines CML
    WHERE CML.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id IN
                   ( SELECT ICV1.cc_header_id
                       FROM igc_arc_pur_candidates ICV1
                   )
          )
       OR CML.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id IN
                   ( SELECT ICV2.cc_header_id
                       FROM igc_arc_pur_candidates ICV2
                   )
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows in MC Acct Line Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Make sure that only the period that is closed and matches the period
-- name are inserted into the IGC_CC_ARCHIVE_MC_JE_LINES table.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_mc_acct_line_hist
	( CC_ACCT_LINE_ID,
	 SET_OF_BOOKS_ID,
	 CC_ACCT_FUNC_AMT,
	 CC_ACCT_ENCMBRNC_AMT,
	 CC_ACCT_VERSION_NUM,
	 CC_ACCT_VERSION_ACTION,
	 CONVERSION_TYPE,
	 CONVERSION_DATE,
	 CONVERSION_RATE,
	 CC_FUNC_WITHHELD_AMT)
   SELECT
	 CC_ACCT_LINE_ID,
	 SET_OF_BOOKS_ID,
	 CC_ACCT_FUNC_AMT,
	 CC_ACCT_ENCMBRNC_AMT,
	 CC_ACCT_VERSION_NUM,
	 CC_ACCT_VERSION_ACTION,
	 CONVERSION_TYPE,
	 CONVERSION_DATE,
	 CONVERSION_RATE,
	 CC_FUNC_WITHHELD_AMT
     FROM igc_cc_mc_acct_line_history CMLH
    WHERE CMLH.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id IN
                   ( SELECT ICV1.cc_header_id
                       FROM igc_arc_pur_candidates ICV1
                   )
          )
       OR CMLH.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id IN
                   ( SELECT ICV2.cc_header_id
                       FROM igc_arc_pur_candidates ICV2
                   )
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows in MC Acct Line Hist Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Insert all records that are able to be inserted based upon the
-- last activity date and org id from the original MRC tables into the
-- archive MRC tables.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_mc_det_pf
	 (CC_DET_PF_LINE_ID,
	 SET_OF_BOOKS_ID,
	 CC_DET_PF_FUNC_AMT ,
	 CC_DET_PF_ENCMBRNC_AMT,
	 CONVERSION_TYPE,
	 CONVERSION_DATE,
	 CONVERSION_RATE )
   SELECT
	 CC_DET_PF_LINE_ID,
	 SET_OF_BOOKS_ID,
	 CC_DET_PF_FUNC_AMT ,
	 CC_DET_PF_ENCMBRNC_AMT,
	 CONVERSION_TYPE,
	 CONVERSION_DATE,
	 CONVERSION_RATE
     FROM igc_cc_mc_det_pf CMDP
    WHERE CMDP.cc_det_pf_line_id IN
          ( SELECT DPFH.cc_det_pf_line_id
              FROM igc_cc_det_pf_history DPFH
             WHERE DPFH.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id IN
                            ( SELECT ICV1.cc_header_id
                                FROM igc_arc_pur_candidates ICV1
                            )
                   )
                OR DPFH.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id IN
                            ( SELECT ICV2.cc_header_id
                                FROM igc_arc_pur_candidates ICV2
                            )
                   )
          )
       OR CMDP.cc_det_pf_line_id IN
          ( SELECT DPF.cc_det_pf_line_id
              FROM igc_cc_det_pf DPF
             WHERE DPF.cc_acct_line_id IN
                   ( SELECT ACLH1.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH1
                      WHERE ACLH1.cc_header_id IN
                            ( SELECT ICV3.cc_header_id
                                FROM igc_arc_pur_candidates ICV3
                            )
                   )
                OR DPF.cc_acct_line_id IN
                   ( SELECT ACL1.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL1
                      WHERE ACL1.cc_header_id IN
                            ( SELECT ICV4.cc_header_id
                                FROM igc_arc_pur_candidates ICV4
                            )
                   )
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows in MC Det PF Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Make sure that only the period that is closed and matches the period
-- name are inserted into the IGC_CC_ARCHIVE_MC_JE_LINES table.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_mc_det_pf_hist
	( CC_DET_PF_LINE_ID,
	 SET_OF_BOOKS_ID,
	 CC_DET_PF_FUNC_AMT,
	 CC_DET_PF_ENCMBRNC_AMT,
	 CC_DET_PF_VERSION_NUM ,
	 CC_DET_PF_VERSION_ACTION,
	 CONVERSION_TYPE,
	 CONVERSION_DATE ,
	 CONVERSION_RATE)
   SELECT
	 CC_DET_PF_LINE_ID,
	 SET_OF_BOOKS_ID,
	 CC_DET_PF_FUNC_AMT,
	 CC_DET_PF_ENCMBRNC_AMT,
	 CC_DET_PF_VERSION_NUM ,
	 CC_DET_PF_VERSION_ACTION,
	 CONVERSION_TYPE,
	 CONVERSION_DATE ,
	 CONVERSION_RATE
     FROM igc_cc_mc_det_pf_history CMDPH
    WHERE CMDPH.cc_det_pf_line_id IN
          ( SELECT DPFH.cc_det_pf_line_id
              FROM igc_cc_det_pf_history DPFH
             WHERE DPFH.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id IN
                            ( SELECT ICV1.cc_header_id
                                FROM igc_arc_pur_candidates ICV1
                            )
                   )
                OR DPFH.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id IN
                            ( SELECT ICV2.cc_header_id
                                FROM igc_arc_pur_candidates ICV2
                            )
                   )
          )
       OR CMDPH.cc_det_pf_line_id IN
          ( SELECT DPF.cc_det_pf_line_id
              FROM igc_cc_det_pf DPF
             WHERE DPF.cc_acct_line_id IN
                   ( SELECT ACLH1.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH1
                      WHERE ACLH1.cc_header_id IN
                            ( SELECT ICV3.cc_header_id
                                FROM igc_arc_pur_candidates ICV3
                            )
                   )
                OR DPF.cc_acct_line_id IN
                   ( SELECT ACL1.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL1
                      WHERE ACL1.cc_header_id IN
                            ( SELECT ICV4.cc_header_id
                                FROM igc_arc_pur_candidates ICV4
                            )
                   )
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows into MC Det PF Hist Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Archive_MRC_Tbls procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
       END IF;
       RETURN;

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Archive_MRC_Tbls;

--
-- Archive_NON_MRC_Tbls Procedure
--
-- Parameters :
--
-- x_Return_Status       ==> Status of procedure returned to caller
--
PROCEDURE Archive_NON_MRC_Tbls (
   x_return_status       OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Declare local variables to be used in this procedure.
-- --------------------------------------------------------------------
   l_api_name            CONSTANT VARCHAR2(30)   := 'Archive_NON_MRC_Tbls';
   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Archive_NON_MRC_Tbls';

-- --------------------------------------------------------------------
-- Initialize Return status and other local variables.
-- --------------------------------------------------------------------
   x_Return_Status       := FND_API.G_RET_STS_SUCCESS;

-- --------------------------------------------------------------------
-- Insert all records that are able to be inserted based upon the
-- last activity date and org id from the original MRC tables into the
-- archive MRC tables.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_headers_all
	 (CC_HEADER_ID     ,
	 ORG_ID           ,
	 CC_TYPE          ,
	 CC_NUM           ,
	 CC_REF_NUM       ,
	 CC_VERSION_NUM   ,
	 PARENT_HEADER_ID ,
	 CC_STATE         ,
	 CC_CTRL_STATUS   ,
	 CC_ENCMBRNC_STATUS,
	 CC_APPRVL_STATUS  ,
	 VENDOR_ID         ,
	 VENDOR_SITE_ID    ,
	 VENDOR_CONTACT_ID ,
	 TERM_ID           ,
	 LOCATION_ID       ,
	 SET_OF_BOOKS_ID   ,
	 CC_ACCT_DATE      ,
	 CC_DESC           ,
	 CC_START_DATE     ,
	 CC_END_DATE       ,
	 CC_OWNER_USER_ID  ,
	 CC_PREPARER_USER_ID,
	 CURRENCY_CODE      ,
	 CONVERSION_TYPE    ,
	 CONVERSION_DATE    ,
	 CONVERSION_RATE    ,
	 LAST_UPDATE_DATE   ,
	 LAST_UPDATED_BY    ,
	 LAST_UPDATE_LOGIN  ,
	 CREATED_BY         ,
	 CREATION_DATE      ,
	 CC_CURRENT_USER_ID ,
	 WF_ITEM_TYPE       ,
	 WF_ITEM_KEY        ,
	 CONTEXT            ,
	 ATTRIBUTE1         ,
	 ATTRIBUTE2         ,
	 ATTRIBUTE3         ,
	 ATTRIBUTE4         ,
	 ATTRIBUTE5         ,
	 ATTRIBUTE6         ,
	 ATTRIBUTE7         ,
	 ATTRIBUTE8         ,
	 ATTRIBUTE9         ,
	 ATTRIBUTE10        ,
	 ATTRIBUTE11        ,
	 ATTRIBUTE12        ,
	 ATTRIBUTE13        ,
	 ATTRIBUTE14        ,
	 ATTRIBUTE15        ,
	 CC_GUARANTEE_FLAG  )

   SELECT
	 CC_HEADER_ID     ,
	 ORG_ID           ,
	 CC_TYPE          ,
	 CC_NUM           ,
	 CC_REF_NUM       ,
	 CC_VERSION_NUM   ,
	 PARENT_HEADER_ID ,
	 CC_STATE         ,
	 CC_CTRL_STATUS   ,
	 CC_ENCMBRNC_STATUS,
	 CC_APPRVL_STATUS  ,
	 VENDOR_ID         ,
	 VENDOR_SITE_ID    ,
	 VENDOR_CONTACT_ID ,
	 TERM_ID           ,
	 LOCATION_ID       ,
	 SET_OF_BOOKS_ID   ,
	 CC_ACCT_DATE      ,
	 CC_DESC           ,
	 CC_START_DATE     ,
	 CC_END_DATE       ,
	 CC_OWNER_USER_ID  ,
	 CC_PREPARER_USER_ID,
	 CURRENCY_CODE      ,
	 CONVERSION_TYPE    ,
	 CONVERSION_DATE    ,
	 CONVERSION_RATE    ,
	 LAST_UPDATE_DATE   ,
	 LAST_UPDATED_BY    ,
	 LAST_UPDATE_LOGIN  ,
	 CREATED_BY         ,
	 CREATION_DATE      ,
	 CC_CURRENT_USER_ID ,
	 WF_ITEM_TYPE       ,
	 WF_ITEM_KEY        ,
	 CONTEXT            ,
	 ATTRIBUTE1         ,
	 ATTRIBUTE2         ,
	 ATTRIBUTE3         ,
	 ATTRIBUTE4         ,
	 ATTRIBUTE5         ,
	 ATTRIBUTE6         ,
	 ATTRIBUTE7         ,
	 ATTRIBUTE8         ,
	 ATTRIBUTE9         ,
	 ATTRIBUTE10        ,
	 ATTRIBUTE11        ,
	 ATTRIBUTE12        ,
	 ATTRIBUTE13        ,
	 ATTRIBUTE14        ,
	 ATTRIBUTE15        ,
	 CC_GUARANTEE_FLAG
     FROM igc_cc_headers CH
    WHERE CH.cc_header_id IN
          ( SELECT cc_header_id
              FROM igc_arc_pur_candidates
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows in Headers Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Make sure that only the period that is closed and matches the period
-- name are inserted into the IGC_CC_ARCHIVE_MC_JE_LINES table.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_header_hist_all
	 (CC_HEADER_ID          ,
	 ORG_ID                ,
	 CC_TYPE               ,
	 CC_NUM                ,
	 CC_REF_NUM            ,
	 CC_VERSION_NUM        ,
	 CC_VERSION_ACTION     ,
	 CC_STATE              ,
	 PARENT_HEADER_ID      ,
	 CC_CTRL_STATUS        ,
	 CC_ENCMBRNC_STATUS    ,
	 CC_APPRVL_STATUS      ,
	 VENDOR_ID             ,
	 VENDOR_SITE_ID        ,
	 VENDOR_CONTACT_ID     ,
	 TERM_ID               ,
	 LOCATION_ID           ,
	 SET_OF_BOOKS_ID       ,
	 CC_ACCT_DATE          ,
	 CC_DESC               ,
	 CC_START_DATE         ,
	 CC_END_DATE           ,
	 CC_OWNER_USER_ID      ,
	 CC_PREPARER_USER_ID   ,
	 CURRENCY_CODE         ,
	 CONVERSION_TYPE       ,
	 CONVERSION_DATE       ,
	 CONVERSION_RATE       ,
	 LAST_UPDATE_DATE      ,
	 LAST_UPDATED_BY       ,
	 LAST_UPDATE_LOGIN     ,
	 CREATED_BY            ,
	 CREATION_DATE         ,
	 WF_ITEM_TYPE          ,
	 WF_ITEM_KEY           ,
	 CC_CURRENT_USER_ID    ,
	 CONTEXT               ,
	 ATTRIBUTE1            ,
	 ATTRIBUTE2            ,
	 ATTRIBUTE3            ,
	 ATTRIBUTE4            ,
	 ATTRIBUTE5            ,
	 ATTRIBUTE6            ,
	 ATTRIBUTE7            ,
	 ATTRIBUTE8            ,
	 ATTRIBUTE9            ,
	 ATTRIBUTE10           ,
	 ATTRIBUTE11           ,
	 ATTRIBUTE12           ,
	 ATTRIBUTE13           ,
	 ATTRIBUTE14           ,
	 ATTRIBUTE15           ,
	 CC_GUARANTEE_FLAG          )
   SELECT
	 CC_HEADER_ID          ,
	 ORG_ID                ,
	 CC_TYPE               ,
	 CC_NUM                ,
	 CC_REF_NUM            ,
	 CC_VERSION_NUM        ,
	 CC_VERSION_ACTION     ,
	 CC_STATE              ,
	 PARENT_HEADER_ID      ,
	 CC_CTRL_STATUS        ,
	 CC_ENCMBRNC_STATUS    ,
	 CC_APPRVL_STATUS      ,
	 VENDOR_ID             ,
	 VENDOR_SITE_ID        ,
	 VENDOR_CONTACT_ID     ,
	 TERM_ID               ,
	 LOCATION_ID           ,
	 SET_OF_BOOKS_ID       ,
	 CC_ACCT_DATE          ,
	 CC_DESC               ,
	 CC_START_DATE         ,
	 CC_END_DATE           ,
	 CC_OWNER_USER_ID      ,
	 CC_PREPARER_USER_ID   ,
	 CURRENCY_CODE         ,
	 CONVERSION_TYPE       ,
	 CONVERSION_DATE       ,
	 CONVERSION_RATE       ,
	 LAST_UPDATE_DATE      ,
	 LAST_UPDATED_BY       ,
	 LAST_UPDATE_LOGIN     ,
	 CREATED_BY            ,
	 CREATION_DATE         ,
	 WF_ITEM_TYPE          ,
	 WF_ITEM_KEY           ,
	 CC_CURRENT_USER_ID    ,
	 CONTEXT               ,
	 ATTRIBUTE1            ,
	 ATTRIBUTE2            ,
	 ATTRIBUTE3            ,
	 ATTRIBUTE4            ,
	 ATTRIBUTE5            ,
	 ATTRIBUTE6            ,
	 ATTRIBUTE7            ,
	 ATTRIBUTE8            ,
	 ATTRIBUTE9            ,
	 ATTRIBUTE10           ,
	 ATTRIBUTE11           ,
	 ATTRIBUTE12           ,
	 ATTRIBUTE13           ,
	 ATTRIBUTE14           ,
	 ATTRIBUTE15           ,
	 CC_GUARANTEE_FLAG
     FROM igc_cc_header_history CHH
    WHERE CHH.cc_header_id IN
          ( SELECT cc_header_id
              FROM igc_arc_pur_candidates
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows into Headers Hist Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Insert all records that are able to be inserted based upon the
-- last activity date and org id from the original MRC tables into the
-- archive MRC tables.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_acct_lines
	( CC_ACCT_LINE_ID                 ,
	 CC_HEADER_ID                    ,
	 PARENT_HEADER_ID                ,
	 PARENT_ACCT_LINE_ID             ,
	 CC_CHARGE_CODE_COMBINATION_ID   ,
	 CC_ACCT_LINE_NUM                ,
	 CC_BUDGET_CODE_COMBINATION_ID   ,
	 CC_ACCT_ENTERED_AMT             ,
	 CC_ACCT_FUNC_AMT                ,
	 CC_ACCT_DESC                    ,
	 CC_ACCT_BILLED_AMT              ,
	 CC_ACCT_UNBILLED_AMT            ,
	 CC_ACCT_TAXABLE_FLAG            ,
	 TAX_ID                          ,
	 CC_ACCT_ENCMBRNC_AMT            ,
	 CC_ACCT_ENCMBRNC_DATE           ,
	 CC_ACCT_ENCMBRNC_STATUS         ,
	 PROJECT_ID                      ,
	 TASK_ID                         ,
	 EXPENDITURE_TYPE                ,
	 EXPENDITURE_ORG_ID              ,
	 EXPENDITURE_ITEM_DATE           ,
	 LAST_UPDATE_DATE                ,
	 LAST_UPDATED_BY                 ,
	 LAST_UPDATE_LOGIN               ,
	 CREATION_DATE                   ,
	 CREATED_BY                      ,
	 CONTEXT                         ,
	 ATTRIBUTE1                      ,
	 ATTRIBUTE2                      ,
	 ATTRIBUTE3                      ,
	 ATTRIBUTE4                      ,
	 ATTRIBUTE5                      ,
	 ATTRIBUTE6                      ,
	 ATTRIBUTE7                      ,
	 ATTRIBUTE8                      ,
	 ATTRIBUTE9                      ,
	 ATTRIBUTE10                     ,
	 ATTRIBUTE11                     ,
	 ATTRIBUTE12                     ,
	 ATTRIBUTE13                     ,
	 ATTRIBUTE14                     ,
	 ATTRIBUTE15                     ,
	 CC_FUNC_WITHHELD_AMT            ,
	 CC_ENT_WITHHELD_AMT             ,
	 TAX_CLASSIF_CODE -- Added for Bug 6472296 EB Tax uptake
	 )
   SELECT
	 CC_ACCT_LINE_ID                 ,
	 CC_HEADER_ID                    ,
	 PARENT_HEADER_ID                ,
	 PARENT_ACCT_LINE_ID             ,
	 CC_CHARGE_CODE_COMBINATION_ID   ,
	 CC_ACCT_LINE_NUM                ,
	 CC_BUDGET_CODE_COMBINATION_ID   ,
	 CC_ACCT_ENTERED_AMT             ,
	 CC_ACCT_FUNC_AMT                ,
	 CC_ACCT_DESC                    ,
	 CC_ACCT_BILLED_AMT              ,
	 CC_ACCT_UNBILLED_AMT            ,
	 CC_ACCT_TAXABLE_FLAG            ,
	 TAX_ID                          ,
	 CC_ACCT_ENCMBRNC_AMT            ,
	 CC_ACCT_ENCMBRNC_DATE           ,
	 CC_ACCT_ENCMBRNC_STATUS         ,
	 PROJECT_ID                      ,
	 TASK_ID                         ,
	 EXPENDITURE_TYPE                ,
	 EXPENDITURE_ORG_ID              ,
	 EXPENDITURE_ITEM_DATE           ,
	 LAST_UPDATE_DATE                ,
	 LAST_UPDATED_BY                 ,
	 LAST_UPDATE_LOGIN               ,
	 CREATION_DATE                   ,
	 CREATED_BY                      ,
	 CONTEXT                         ,
	 ATTRIBUTE1                      ,
	 ATTRIBUTE2                      ,
	 ATTRIBUTE3                      ,
	 ATTRIBUTE4                      ,
	 ATTRIBUTE5                      ,
	 ATTRIBUTE6                      ,
	 ATTRIBUTE7                      ,
	 ATTRIBUTE8                      ,
	 ATTRIBUTE9                      ,
	 ATTRIBUTE10                     ,
	 ATTRIBUTE11                     ,
	 ATTRIBUTE12                     ,
	 ATTRIBUTE13                     ,
	 ATTRIBUTE14                     ,
	 ATTRIBUTE15                     ,
	 CC_FUNC_WITHHELD_AMT            ,
	 CC_ENT_WITHHELD_AMT		 ,
	 TAX_CLASSIF_CODE -- Added for Bug 6472296 EB Tax uptake
     FROM igc_cc_acct_lines CL
    WHERE CL.cc_header_id IN
          ( SELECT ICV1.cc_header_id
              FROM igc_arc_pur_candidates ICV1
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows into Acct Line Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Make sure that only the period that is closed and matches the period
-- name are inserted into the IGC_CC_ARCHIVE_MC_JE_LINES table.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_acct_line_hist
	( CC_ACCT_LINE_ID                ,
	 CC_HEADER_ID                    ,
	 PARENT_HEADER_ID                ,
	 PARENT_ACCT_LINE_ID             ,
	 CC_ACCT_LINE_NUM                ,
	 CC_ACCT_VERSION_NUM             ,
	 CC_ACCT_VERSION_ACTION          ,
	 CC_CHARGE_CODE_COMBINATION_ID   ,
	 CC_BUDGET_CODE_COMBINATION_ID   ,
	 CC_ACCT_ENTERED_AMT             ,
	 CC_ACCT_FUNC_AMT                ,
	 CC_ACCT_DESC                    ,
	 CC_ACCT_BILLED_AMT              ,
	 CC_ACCT_UNBILLED_AMT            ,
	 CC_ACCT_TAXABLE_FLAG            ,
	 TAX_ID                          ,
	 CC_ACCT_ENCMBRNC_AMT            ,
	 CC_ACCT_ENCMBRNC_DATE           ,
	 CC_ACCT_ENCMBRNC_STATUS         ,
	 PROJECT_ID                      ,
	 TASK_ID                         ,
	 EXPENDITURE_TYPE                ,
	 EXPENDITURE_ORG_ID              ,
	 EXPENDITURE_ITEM_DATE           ,
	 LAST_UPDATE_DATE                ,
	 LAST_UPDATED_BY                 ,
	 LAST_UPDATE_LOGIN               ,
	 CREATION_DATE                   ,
	 CREATED_BY                      ,
	 CONTEXT                         ,
	 ATTRIBUTE1                      ,
	 ATTRIBUTE2                      ,
	 ATTRIBUTE3                      ,
	 ATTRIBUTE4                      ,
	 ATTRIBUTE5                      ,
	 ATTRIBUTE6                      ,
	 ATTRIBUTE7                      ,
	 ATTRIBUTE8                      ,
	 ATTRIBUTE9                      ,
	 ATTRIBUTE10                     ,
	 ATTRIBUTE11                     ,
	 ATTRIBUTE12                     ,
	 ATTRIBUTE13                     ,
	 ATTRIBUTE14                     ,
	 ATTRIBUTE15                     ,
	 CC_FUNC_WITHHELD_AMT            ,
	 CC_ENT_WITHHELD_AMT		 ,
	 TAX_CLASSIF_CODE -- Added for Bug 6472296 EB Tax uptake
	 )
   SELECT
	 CC_ACCT_LINE_ID                ,
	 CC_HEADER_ID                    ,
	 PARENT_HEADER_ID                ,
	 PARENT_ACCT_LINE_ID             ,
	 CC_ACCT_LINE_NUM                ,
	 CC_ACCT_VERSION_NUM             ,
	 CC_ACCT_VERSION_ACTION          ,
	 CC_CHARGE_CODE_COMBINATION_ID   ,
	 CC_BUDGET_CODE_COMBINATION_ID   ,
	 CC_ACCT_ENTERED_AMT             ,
	 CC_ACCT_FUNC_AMT                ,
	 CC_ACCT_DESC                    ,
	 CC_ACCT_BILLED_AMT              ,
	 CC_ACCT_UNBILLED_AMT            ,
	 CC_ACCT_TAXABLE_FLAG            ,
	 TAX_ID                          ,
	 CC_ACCT_ENCMBRNC_AMT            ,
	 CC_ACCT_ENCMBRNC_DATE           ,
	 CC_ACCT_ENCMBRNC_STATUS         ,
	 PROJECT_ID                      ,
	 TASK_ID                         ,
	 EXPENDITURE_TYPE                ,
	 EXPENDITURE_ORG_ID              ,
	 EXPENDITURE_ITEM_DATE           ,
	 LAST_UPDATE_DATE                ,
	 LAST_UPDATED_BY                 ,
	 LAST_UPDATE_LOGIN               ,
	 CREATION_DATE                   ,
	 CREATED_BY                      ,
	 CONTEXT                         ,
	 ATTRIBUTE1                      ,
	 ATTRIBUTE2                      ,
	 ATTRIBUTE3                      ,
	 ATTRIBUTE4                      ,
	 ATTRIBUTE5                      ,
	 ATTRIBUTE6                      ,
	 ATTRIBUTE7                      ,
	 ATTRIBUTE8                      ,
	 ATTRIBUTE9                      ,
	 ATTRIBUTE10                     ,
	 ATTRIBUTE11                     ,
	 ATTRIBUTE12                     ,
	 ATTRIBUTE13                     ,
	 ATTRIBUTE14                     ,
	 ATTRIBUTE15                     ,
	 CC_FUNC_WITHHELD_AMT            ,
	 CC_ENT_WITHHELD_AMT		 ,
	 TAX_CLASSIF_CODE -- Added for Bug 6472296 EB Tax uptake
     FROM igc_cc_acct_line_history CLH
    WHERE CLH.cc_header_id IN
          ( SELECT ICV1.cc_header_id
              FROM igc_arc_pur_candidates ICV1
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows into Acct Line Hist Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Insert all records that are able to be inserted based upon the
-- last activity date and org id from the original MRC tables into the
-- archive MRC tables.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_det_pf
	 (CC_DET_PF_LINE_ID        ,
	 CC_DET_PF_LINE_NUM       ,
	 CC_ACCT_LINE_ID          ,
	 PARENT_ACCT_LINE_ID      ,
	 PARENT_DET_PF_LINE_ID    ,
	 CC_DET_PF_ENTERED_AMT    ,
	 CC_DET_PF_FUNC_AMT       ,
	 CC_DET_PF_DATE           ,
	 CC_DET_PF_BILLED_AMT     ,
	 CC_DET_PF_UNBILLED_AMT   ,
	 CC_DET_PF_ENCMBRNC_AMT   ,
	 CC_DET_PF_ENCMBRNC_DATE  ,
	 CC_DET_PF_ENCMBRNC_STATUS,
	 LAST_UPDATE_DATE         ,
	 LAST_UPDATED_BY          ,
	 LAST_UPDATE_LOGIN        ,
	 CREATION_DATE            ,
	 CREATED_BY               ,
	 CONTEXT                  ,
	 ATTRIBUTE1               ,
	 ATTRIBUTE2               ,
	 ATTRIBUTE3               ,
	 ATTRIBUTE4               ,
	 ATTRIBUTE5               ,
	 ATTRIBUTE6               ,
	 ATTRIBUTE7               ,
	 ATTRIBUTE8               ,
	 ATTRIBUTE9               ,
	 ATTRIBUTE10              ,
	 ATTRIBUTE11              ,
	 ATTRIBUTE12              ,
	 ATTRIBUTE13              ,
	 ATTRIBUTE14              ,
	 ATTRIBUTE15              )
   SELECT
	 CC_DET_PF_LINE_ID        ,
	 CC_DET_PF_LINE_NUM       ,
	 CC_ACCT_LINE_ID          ,
	 PARENT_ACCT_LINE_ID      ,
	 PARENT_DET_PF_LINE_ID    ,
	 CC_DET_PF_ENTERED_AMT    ,
	 CC_DET_PF_FUNC_AMT       ,
	 CC_DET_PF_DATE           ,
	 CC_DET_PF_BILLED_AMT     ,
	 CC_DET_PF_UNBILLED_AMT   ,
	 CC_DET_PF_ENCMBRNC_AMT   ,
	 CC_DET_PF_ENCMBRNC_DATE  ,
	 CC_DET_PF_ENCMBRNC_STATUS,
	 LAST_UPDATE_DATE         ,
	 LAST_UPDATED_BY          ,
	 LAST_UPDATE_LOGIN        ,
	 CREATION_DATE            ,
	 CREATED_BY               ,
	 CONTEXT                  ,
	 ATTRIBUTE1               ,
	 ATTRIBUTE2               ,
	 ATTRIBUTE3               ,
	 ATTRIBUTE4               ,
	 ATTRIBUTE5               ,
	 ATTRIBUTE6               ,
	 ATTRIBUTE7               ,
	 ATTRIBUTE8               ,
	 ATTRIBUTE9               ,
	 ATTRIBUTE10              ,
	 ATTRIBUTE11              ,
	 ATTRIBUTE12              ,
	 ATTRIBUTE13              ,
	 ATTRIBUTE14              ,
	 ATTRIBUTE15
     FROM igc_cc_det_pf CDP
    WHERE CDP.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id IN
                   ( SELECT ICV1.cc_header_id
                       FROM igc_arc_pur_candidates ICV1
                   )
          )
       OR CDP.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id IN
                   ( SELECT ICV2.cc_header_id
                       FROM igc_arc_pur_candidates ICV2
                   )
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows into Det PF Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Make sure that only the period that is closed and matches the period
-- name are inserted into the IGC_CC_ARC_DET_PF_HIST table.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_det_pf_hist
	( CC_DET_PF_LINE_ID             ,
	 CC_DET_PF_LINE_NUM            ,
	 CC_ACCT_LINE_ID               ,
	 PARENT_ACCT_LINE_ID           ,
	 PARENT_DET_PF_LINE_ID         ,
	 CC_DET_PF_VERSION_NUM         ,
	 CC_DET_PF_VERSION_ACTION      ,
	 CC_DET_PF_ENTERED_AMT         ,
	 CC_DET_PF_FUNC_AMT            ,
	 CC_DET_PF_DATE                ,
	 CC_DET_PF_BILLED_AMT          ,
	 CC_DET_PF_UNBILLED_AMT        ,
	 CC_DET_PF_ENCMBRNC_AMT        ,
	 CC_DET_PF_ENCMBRNC_DATE       ,
	 CC_DET_PF_ENCMBRNC_STATUS     ,
	 LAST_UPDATE_DATE              ,
	 LAST_UPDATED_BY               ,
	 LAST_UPDATE_LOGIN             ,
	 CREATION_DATE                 ,
	 CREATED_BY                    ,
	 CONTEXT                       ,
	 ATTRIBUTE1                    ,
	 ATTRIBUTE2                    ,
	 ATTRIBUTE3                    ,
	 ATTRIBUTE4                    ,
	 ATTRIBUTE5                    ,
	 ATTRIBUTE6                    ,
	 ATTRIBUTE7                    ,
	 ATTRIBUTE8                    ,
	 ATTRIBUTE9                    ,
	 ATTRIBUTE10                   ,
	 ATTRIBUTE11                   ,
	 ATTRIBUTE12                   ,
	 ATTRIBUTE13                   ,
	 ATTRIBUTE14                   ,
	 ATTRIBUTE15  )
   SELECT
	 CC_DET_PF_LINE_ID             ,
	 CC_DET_PF_LINE_NUM            ,
	 CC_ACCT_LINE_ID               ,
	 PARENT_ACCT_LINE_ID           ,
	 PARENT_DET_PF_LINE_ID         ,
	 CC_DET_PF_VERSION_NUM         ,
	 CC_DET_PF_VERSION_ACTION      ,
	 CC_DET_PF_ENTERED_AMT         ,
	 CC_DET_PF_FUNC_AMT            ,
	 CC_DET_PF_DATE                ,
	 CC_DET_PF_BILLED_AMT          ,
	 CC_DET_PF_UNBILLED_AMT        ,
	 CC_DET_PF_ENCMBRNC_AMT        ,
	 CC_DET_PF_ENCMBRNC_DATE       ,
	 CC_DET_PF_ENCMBRNC_STATUS     ,
	 LAST_UPDATE_DATE              ,
	 LAST_UPDATED_BY               ,
	 LAST_UPDATE_LOGIN             ,
	 CREATION_DATE                 ,
	 CREATED_BY                    ,
	 CONTEXT                       ,
	 ATTRIBUTE1                    ,
	 ATTRIBUTE2                    ,
	 ATTRIBUTE3                    ,
	 ATTRIBUTE4                    ,
	 ATTRIBUTE5                    ,
	 ATTRIBUTE6                    ,
	 ATTRIBUTE7                    ,
	 ATTRIBUTE8                    ,
	 ATTRIBUTE9                    ,
	 ATTRIBUTE10                   ,
	 ATTRIBUTE11                   ,
	 ATTRIBUTE12                   ,
	 ATTRIBUTE13                   ,
	 ATTRIBUTE14                   ,
	 ATTRIBUTE15
     FROM igc_cc_det_pf_history CDPH
    WHERE CDPH.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id IN
                   ( SELECT ICV1.cc_header_id
                       FROM igc_arc_pur_candidates ICV1
                   )
          )
       OR CDPH.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id IN
                   ( SELECT ICV2.cc_header_id
                       FROM igc_arc_pur_candidates ICV2
                   )
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows into Det PF Hist Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Make sure that the CC Actions table is archived for the CC Header
-- IDs that are candidates for archiving.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_actions
	( CC_HEADER_ID              ,
	 CC_ACTION_NUM             ,
	 CC_ACTION_VERSION_NUM     ,
	 CC_ACTION_TYPE            ,
	 CC_ACTION_STATE           ,
	 CC_ACTION_CTRL_STATUS     ,
	 CC_ACTION_APPRVL_STATUS   ,
	 CC_ACTION_NOTES           ,
	 LAST_UPDATE_DATE          ,
	 LAST_UPDATED_BY           ,
	 LAST_UPDATE_LOGIN         ,
	 CREATION_DATE             ,
	 CREATED_BY                )
   SELECT
	 CC_HEADER_ID              ,
	 CC_ACTION_NUM             ,
	 CC_ACTION_VERSION_NUM     ,
	 CC_ACTION_TYPE            ,
	 CC_ACTION_STATE           ,
	 CC_ACTION_CTRL_STATUS     ,
	 CC_ACTION_APPRVL_STATUS   ,
	 CC_ACTION_NOTES           ,
	 LAST_UPDATE_DATE          ,
	 LAST_UPDATED_BY           ,
	 LAST_UPDATE_LOGIN         ,
	 CREATION_DATE             ,
	 CREATED_BY
     FROM igc_cc_actions CA
    WHERE CA.cc_header_id IN
          ( SELECT ICV.cc_header_id
              FROM igc_arc_pur_candidates ICV
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows into Actions Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Archive the appropriate PO tables that contain the information on
-- the CC Headers that have already been archived.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_cc_arc_po_headers_all
          (po_header_id,
           agent_id,
           type_lookup_code,
           last_update_date,
           last_updated_by,
           segment1,
           summary_flag,
           enabled_flag,
           segment2,
           segment3,
           segment4,
           segment5,
           start_date_active,
           end_date_active,
           last_update_login,
           creation_date,
           created_by,
           vendor_id,
           vendor_site_id,
           vendor_contact_id,
           ship_to_location_id,
           bill_to_location_id,
           terms_id,
           ship_via_lookup_code,
           fob_lookup_code,
           freight_terms_lookup_code,
           status_lookup_code,
           currency_code,
           rate_type,
           rate_date,
           rate,
           from_header_id,
           from_type_lookup_code,
           start_date,
           end_date,
           blanket_total_amount,
           authorization_status,
           revision_num,
           revised_date,
           approved_flag,
           approved_date,
           amount_limit,
           min_release_amount,
           note_to_authorizer,
           note_to_vendor,
           note_to_receiver,
           print_count,
           printed_date,
           vendor_order_num,
           confirming_order_flag,
           comments,
           reply_date,
           reply_method_lookup_code,
           rfq_close_date,
           quote_type_lookup_code,
           quotation_class_code,
           quote_warning_delay_unit,
           quote_warning_delay,
           quote_vendor_quote_number,
           acceptance_required_flag,
           acceptance_due_date,
           closed_date,
           user_hold_flag,
           approval_required_flag,
           cancel_flag,
           firm_status_lookup_code,
           firm_date,
           frozen_flag,
           supply_agreement_flag,
           edi_processed_flag,
           edi_processed_status,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           closed_code,
           ussgl_transaction_code,
           government_context,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           org_id,
           global_attribute_category,
           global_attribute1,
           global_attribute2,
           global_attribute3,
           global_attribute4,
           global_attribute5,
           global_attribute6,
           global_attribute7,
           global_attribute8,
           global_attribute9,
           global_attribute10,
           global_attribute11,
           global_attribute12,
           global_attribute13,
           global_attribute14,
           global_attribute15,
           global_attribute16,
           global_attribute17,
           global_attribute18,
           global_attribute19,
           global_attribute20,
           interface_source_code,
           reference_num,
           wf_item_type,
           wf_item_key,
           mrc_rate_type,
           mrc_rate_date,
           mrc_rate,
           pcard_id,
           price_update_tolerance,
           pay_on_code
          )
   SELECT po_header_id,
          agent_id,
          type_lookup_code,
          last_update_date,
          last_updated_by,
          segment1,
          summary_flag,
          enabled_flag,
          segment2,
          segment3,
          segment4,
          segment5,
          start_date_active,
          end_date_active,
          last_update_login,
          creation_date,
          created_by,
          vendor_id,
          vendor_site_id,
          vendor_contact_id,
          ship_to_location_id,
          bill_to_location_id,
          terms_id,
          ship_via_lookup_code,
          fob_lookup_code,
          freight_terms_lookup_code,
          status_lookup_code,
          currency_code,
          rate_type,
          rate_date,
          rate,
          from_header_id,
          from_type_lookup_code,
          start_date,
          end_date,
          blanket_total_amount,
          authorization_status,
          revision_num,
          revised_date,
          approved_flag,
          approved_date,
          amount_limit,
          min_release_amount,
          note_to_authorizer,
          note_to_vendor,
          note_to_receiver,
          print_count,
          printed_date,
          vendor_order_num,
          confirming_order_flag,
          comments,
          reply_date,
          reply_method_lookup_code,
          rfq_close_date,
          quote_type_lookup_code,
          quotation_class_code,
          quote_warning_delay_unit,
          quote_warning_delay,
          quote_vendor_quote_number,
          acceptance_required_flag,
          acceptance_due_date,
          closed_date,
          user_hold_flag,
          approval_required_flag,
          cancel_flag,
          firm_status_lookup_code,
          firm_date,
          frozen_flag,
          supply_agreement_flag,
          edi_processed_flag,
          edi_processed_status,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          closed_code,
          ussgl_transaction_code,
          government_context,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          org_id,
          global_attribute_category,
          global_attribute1,
          global_attribute2,
          global_attribute3,
          global_attribute4,
          global_attribute5,
          global_attribute6,
          global_attribute7,
          global_attribute8,
          global_attribute9,
          global_attribute10,
          global_attribute11,
          global_attribute12,
          global_attribute13,
          global_attribute14,
          global_attribute15,
          global_attribute16,
          global_attribute17,
          global_attribute18,
          global_attribute19,
          global_attribute20,
          interface_source_code,
          reference_num,
          wf_item_type,
          wf_item_key,
          mrc_rate_type,
          mrc_rate_date,
          mrc_rate,
          pcard_id,
          price_update_tolerance,
          pay_on_code
     FROM po_headers PHA
-- ssmales 11/07/03 bug 2885953 - amended where clause below for performance issues
--    WHERE PHA.po_header_id IN
--          ( SELECT PHA1.po_header_id
--              FROM po_headers_all PHA1
--             WHERE PHA1.segment1 IN
      WHERE PHA.segment1 IN
                   ( SELECT ICV.cc_num
                       FROM igc_arc_pur_candidates ICV
                   );
--          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows into PO Headers ALL Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   INSERT
     INTO igc_cc_arc_po_lines_all
          (po_line_id,
           last_update_date,
           last_updated_by,
           po_header_id,
           line_type_id,
           line_num,
           last_update_login,
           creation_date,
           created_by,
           item_id,
           item_revision,
           category_id,
           item_description,
           unit_meas_lookup_code,
           quantity_committed,
           committed_amount,
           allow_price_override_flag,
           not_to_exceed_price,
           list_price_per_unit,
           unit_price,
           quantity,
           un_number_id,
           hazard_class_id,
           note_to_vendor,
           from_header_id,
           from_line_id,
           min_order_quantity,
           max_order_quantity,
           qty_rcv_tolerance,
           over_tolerance_error_flag,
           market_price,
           unordered_flag,
           closed_flag,
           user_hold_flag,
           cancel_flag,
           cancelled_by,
           cancel_date,
           cancel_reason,
           firm_status_lookup_code,
           firm_date,
           vendor_product_num,
           contract_num,
           taxable_flag,
           tax_name,
           type_1099,
           capital_expense_flag,
           negotiated_by_preparer_flag,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           reference_num,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           min_release_amount,
           price_type_lookup_code,
           closed_code,
           price_break_lookup_code,
           ussgl_transaction_code,
           government_context,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           closed_date,
           closed_reason,
           closed_by,
           transaction_reason_code,
           org_id,
           qc_grade,
           base_uom,
           base_qty,
           secondary_uom,
           secondary_qty,
           global_attribute_category,
           global_attribute1,
           global_attribute2,
           global_attribute3,
           global_attribute4,
           global_attribute5,
           global_attribute6,
           global_attribute7,
           global_attribute8,
           global_attribute9,
           global_attribute10,
           global_attribute11,
           global_attribute12,
           global_attribute13,
           global_attribute14,
           global_attribute15,
           global_attribute16,
           global_attribute17,
           global_attribute18,
           global_attribute19,
           global_attribute20,
           line_reference_num,
           project_id,
           task_id,
           expiration_date,
           tax_code_id
          )
   SELECT po_line_id,
          last_update_date,
          last_updated_by,
          po_header_id,
          line_type_id,
          line_num,
          last_update_login,
          creation_date,
          created_by,
          item_id,
          item_revision,
          category_id,
          item_description,
          unit_meas_lookup_code,
          quantity_committed,
          committed_amount,
          allow_price_override_flag,
          not_to_exceed_price,
          list_price_per_unit,
          unit_price,
          quantity,
          un_number_id,
          hazard_class_id,
          note_to_vendor,
          from_header_id,
          from_line_id,
          min_order_quantity,
          max_order_quantity,
          qty_rcv_tolerance,
          over_tolerance_error_flag,
          market_price,
          unordered_flag,
          closed_flag,
          user_hold_flag,
          cancel_flag,
          cancelled_by,
          cancel_date,
          cancel_reason,
          firm_status_lookup_code,
          firm_date,
          vendor_product_num,
          contract_num,
          taxable_flag,
          tax_name,
          type_1099,
          capital_expense_flag,
          negotiated_by_preparer_flag,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          reference_num,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          min_release_amount,
          price_type_lookup_code,
          closed_code,
          price_break_lookup_code,
          ussgl_transaction_code,
          government_context,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          closed_date,
          closed_reason,
          closed_by,
          transaction_reason_code,
          org_id,
          qc_grade,
          base_uom,
          base_qty,
          secondary_uom,
          secondary_qty,
          global_attribute_category,
          global_attribute1,
          global_attribute2,
          global_attribute3,
          global_attribute4,
          global_attribute5,
          global_attribute6,
          global_attribute7,
          global_attribute8,
          global_attribute9,
          global_attribute10,
          global_attribute11,
          global_attribute12,
          global_attribute13,
          global_attribute14,
          global_attribute15,
          global_attribute16,
          global_attribute17,
          global_attribute18,
          global_attribute19,
          global_attribute20,
          line_reference_num,
          project_id,
          task_id,
          expiration_date,
          tax_code_id
     FROM po_lines PLA
    WHERE PLA.po_header_id IN
          ( SELECT PHA.po_header_id
              FROM po_headers PHA
             WHERE PHA.segment1 IN
                   ( SELECT ICV.cc_num
                       FROM igc_arc_pur_candidates ICV
                   )
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows into PO Lines ALL Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   INSERT
     INTO igc_cc_arc_po_line_loc_all
          (line_location_id,
           last_update_date,
           last_updated_by,
           po_header_id,
           po_line_id,
           last_update_login,
           creation_date,
           created_by,
           quantity,
           quantity_received,
           quantity_accepted,
           quantity_rejected,
           quantity_billed,
           quantity_cancelled,
           unit_meas_lookup_code,
           po_release_id,
           ship_to_location_id,
           ship_via_lookup_code,
           need_by_date,
           promised_date,
           last_accept_date,
           price_override,
           encumbered_flag,
           encumbered_date,
           unencumbered_quantity,
           fob_lookup_code,
           freight_terms_lookup_code,
           taxable_flag,
           tax_name,
           estimated_tax_amount,
           from_header_id,
           from_line_id,
           from_line_location_id,
           start_date,
           end_date,
           lead_time,
           lead_time_unit,
           price_discount,
           terms_id,
           approved_flag,
           approved_date,
           closed_flag,
           cancel_flag,
           cancelled_by,
           cancel_date,
           cancel_reason,
           firm_status_lookup_code,
           firm_date,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           unit_of_measure_class,
           encumber_now,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           inspection_required_flag,
           receipt_required_flag,
           qty_rcv_tolerance,
           qty_rcv_exception_code,
           enforce_ship_to_location_code,
           allow_substitute_receipts_flag,
           days_early_receipt_allowed,
           days_late_receipt_allowed,
           receipt_days_exception_code,
           invoice_close_tolerance,
           receive_close_tolerance,
           ship_to_organization_id,
           shipment_num,
           source_shipment_id,
           shipment_type,
           closed_code,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           ussgl_transaction_code,
           government_context,
           receiving_routing_id,
           accrue_on_receipt_flag,
           closed_reason,
           closed_date,
           closed_by,
           org_id,
           global_attribute1,
           global_attribute2,
           global_attribute3,
           global_attribute4,
           global_attribute5,
           global_attribute6,
           global_attribute7,
           global_attribute8,
           global_attribute9,
           global_attribute10,
           global_attribute11,
           global_attribute12,
           global_attribute13,
           global_attribute14,
           global_attribute15,
           global_attribute16,
           global_attribute17,
           global_attribute18,
           global_attribute19,
           global_attribute20,
           global_attribute_category,
           quantity_shipped,
           country_of_origin_code,
           tax_user_override_flag,
           match_option,
           tax_code_id,
           calculate_tax_flag,
           change_promised_date_reason
          )
   SELECT line_location_id,
          last_update_date,
          last_updated_by,
          po_header_id,
          po_line_id,
          last_update_login,
          creation_date,
          created_by,
          quantity,
          quantity_received,
          quantity_accepted,
          quantity_rejected,
          quantity_billed,
          quantity_cancelled,
          unit_meas_lookup_code,
          po_release_id,
          ship_to_location_id,
          ship_via_lookup_code,
          need_by_date,
          promised_date,
          last_accept_date,
          price_override,
          encumbered_flag,
          encumbered_date,
          unencumbered_quantity,
          fob_lookup_code,
          freight_terms_lookup_code,
          taxable_flag,
          tax_name,
          estimated_tax_amount,
          from_header_id,
          from_line_id,
          from_line_location_id,
          start_date,
          end_date,
          lead_time,
          lead_time_unit,
          price_discount,
          terms_id,
          approved_flag,
          approved_date,
          closed_flag,
          cancel_flag,
          cancelled_by,
          cancel_date,
          cancel_reason,
          firm_status_lookup_code,
          firm_date,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          unit_of_measure_class,
          encumber_now,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          inspection_required_flag,
          receipt_required_flag,
          qty_rcv_tolerance,
          qty_rcv_exception_code,
          enforce_ship_to_location_code,
          allow_substitute_receipts_flag,
          days_early_receipt_allowed,
          days_late_receipt_allowed,
          receipt_days_exception_code,
          invoice_close_tolerance,
          receive_close_tolerance,
          ship_to_organization_id,
          shipment_num,
          source_shipment_id,
          shipment_type,
          closed_code,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          ussgl_transaction_code,
          government_context,
          receiving_routing_id,
          accrue_on_receipt_flag,
          closed_reason,
          closed_date,
          closed_by,
          org_id,
          global_attribute1,
          global_attribute2,
          global_attribute3,
          global_attribute4,
          global_attribute5,
          global_attribute6,
          global_attribute7,
          global_attribute8,
          global_attribute9,
          global_attribute10,
          global_attribute11,
          global_attribute12,
          global_attribute13,
          global_attribute14,
          global_attribute15,
          global_attribute16,
          global_attribute17,
          global_attribute18,
          global_attribute19,
          global_attribute20,
          global_attribute_category,
          quantity_shipped,
          country_of_origin_code,
          tax_user_override_flag,
          match_option,
          tax_code_id,
          calculate_tax_flag,
          change_promised_date_reason
     FROM po_line_locations PLLA
    WHERE PLLA.po_header_id IN
          ( SELECT po_header_id
              FROM po_headers PHA
             WHERE PHA.segment1 IN
                   ( SELECT ICV.cc_num
                       FROM igc_arc_pur_candidates ICV
                   )
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows into PO Line Loc ALL Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   INSERT
     INTO igc_cc_arc_po_distribution_all
          (po_distribution_id,
           last_update_date,
           last_updated_by,
           po_header_id,
           po_line_id,
           line_location_id,
           set_of_books_id,
           code_combination_id,
           quantity_ordered,
           last_update_login,
           creation_date,
           created_by,
           po_release_id,
           quantity_delivered,
           quantity_billed,
           quantity_cancelled,
           req_header_reference_num,
           req_line_reference_num,
           req_distribution_id,
           deliver_to_location_id,
           deliver_to_person_id,
           rate_date,
           rate,
           amount_billed,
           accrued_flag,
           encumbered_flag,
           encumbered_amount,
           unencumbered_quantity,
           unencumbered_amount,
           failed_funds_lookup_code,
           gl_encumbered_date,
           gl_encumbered_period_name,
           gl_cancelled_date,
           destination_type_code,
           destination_organization_id,
           destination_subinventory,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           wip_entity_id,
           wip_operation_seq_num,
           wip_resource_seq_num,
           wip_repetitive_schedule_id,
           wip_line_id,
           bom_resource_id,
           budget_account_id,
           accrual_account_id,
           variance_account_id,
           prevent_encumbrance_flag,
           ussgl_transaction_code,
           government_context,
           destination_context,
           distribution_num,
           source_distribution_id,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           project_id,
           task_id,
           expenditure_type,
           project_accounting_context,
           expenditure_organization_id,
           gl_closed_date,
           accrue_on_receipt_flag,
           expenditure_item_date,
           org_id,
           kanban_card_id,
           award_id,
           mrc_rate_date,
           mrc_rate,
           mrc_encumbered_amount,
           mrc_unencumbered_amount,
           end_item_unit_number,
           tax_recovery_override_flag,
           recoverable_tax,
           nonrecoverable_tax,
           recovery_rate
          )
   SELECT po_distribution_id,
          last_update_date,
          last_updated_by,
          po_header_id,
          po_line_id,
          line_location_id,
          set_of_books_id,
          code_combination_id,
          quantity_ordered,
          last_update_login,
          creation_date,
          created_by,
          po_release_id,
          quantity_delivered,
          quantity_billed,
          quantity_cancelled,
          req_header_reference_num,
          req_line_reference_num,
          req_distribution_id,
          deliver_to_location_id,
          deliver_to_person_id,
          rate_date,
          rate,
          amount_billed,
          accrued_flag,
          encumbered_flag,
          encumbered_amount,
          unencumbered_quantity,
          unencumbered_amount,
          failed_funds_lookup_code,
          gl_encumbered_date,
          gl_encumbered_period_name,
          gl_cancelled_date,
          destination_type_code,
          destination_organization_id,
          destination_subinventory,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          wip_entity_id,
          wip_operation_seq_num,
          wip_resource_seq_num,
          wip_repetitive_schedule_id,
          wip_line_id,
          bom_resource_id,
          budget_account_id,
          accrual_account_id,
          variance_account_id,
          prevent_encumbrance_flag,
          ussgl_transaction_code,
          government_context,
          destination_context,
          distribution_num,
          source_distribution_id,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          project_id,
          task_id,
          expenditure_type,
          project_accounting_context,
          expenditure_organization_id,
          gl_closed_date,
          accrue_on_receipt_flag,
          expenditure_item_date,
          org_id,
          kanban_card_id,
          award_id,
          mrc_rate_date,
          mrc_rate,
          mrc_encumbered_amount,
          mrc_unencumbered_amount,
          end_item_unit_number,
          tax_recovery_override_flag,
          recoverable_tax,
          nonrecoverable_tax,
          recovery_rate
     FROM po_distributions PDA
    WHERE PDA.po_header_id IN
          ( SELECT po_header_id
              FROM po_headers PHA
             WHERE PHA.segment1 IN
                   ( SELECT ICV.cc_num
                       FROM igc_arc_pur_candidates ICV
                   )
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Inserted ' || SQL%ROWCOUNT || ' number rows into PO Dist ALL Table for ' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Archive_NON_MRC_Tbls procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
       END IF;
       RETURN;

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Archive_NON_MRC_Tbls;

--
-- Build_Candidate_List Procedure to designed for retrieving the CC Header
-- IDs that are candidates for Archiving and Purging.  Once these values are
-- retrieved then they will be inserted into the temporary table used for tracking
-- the candidates for Archiving and Purging.
--
-- Parameters :
--
-- x_return_status       ==>  Status returned from Procedure.
--
PROCEDURE Build_Candidate_List (
   x_return_status     OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Define local variables to be used
-- --------------------------------------------------------------------
   l_api_name            CONSTANT VARCHAR2(30) := 'Build_Candidate_List';
   l_count               NUMBER := 0;

-- --------------------------------------------------------------------
-- Define cursor to get count inserted into table.
-- --------------------------------------------------------------------
   CURSOR c_cand_count IS
      SELECT count(*)
        FROM igc_arc_pur_candidates;

   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Build_Candidate_List';

-- --------------------------------------------------------------------
-- Initialize local variables.
-- --------------------------------------------------------------------
   x_Return_Status := FND_API.G_RET_STS_SUCCESS;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Building the Candidate List......';
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Clean up the temp table of any records being present.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_arc_pur_candidates;

-- --------------------------------------------------------------------
-- Insert all candidates that are closed / cancelled and all invoices
-- that have been paid for the contract.
-- --------------------------------------------------------------------
   INSERT
     INTO igc_arc_pur_candidates
          (cc_header_id,
           cc_num,
           cc_acct_line_id,
           cc_det_pf_line_id,
           last_activity_date
          )
   SELECT ICCCHV.cc_hd_id,
          ICCCHV.cc_num_val,
          ICCCHV.cc_act_id,
          ICCCHV.cc_pf_id,
          ICCCHV.max_dt
     FROM igc_cc_closed_canc_hdrs_v ICCCHV,
          igc_cc_headers_all            ICH
    WHERE ICH.cc_header_id         = ICCCHV.cc_hd_id
      AND ICH.set_of_books_id      = g_sob_id
      AND ICH.org_id               = g_org_id
      AND trunc (ICCCHV.max_dt)   <= trunc (g_last_activity_date)
      AND ICH.cc_header_id NOT IN
          ( SELECT ICH1.cc_header_id
              FROM igc_cc_headers               ICH1,
                   po_headers_all               PHA1,
                   po_distributions_all         PDA,
                   ap_invoice_distributions_all AIDA,
                   ap_invoices_all              AIA1
             WHERE /*ICH1.set_of_books_id      = g_sob_id
               AND ICH1.org_id               = g_org_id
               AND --Commented during MOAC uptake */
		 PHA1.segment1             = ICH1.cc_num
               AND PDA.po_header_id          = PHA1.po_header_id
               AND AIDA.po_distribution_id   = PDA.po_distribution_id
               AND AIA1.invoice_id           = AIDA.invoice_id
               AND AIA1.payment_status_flag  = 'N'
               AND AIA1.cancelled_date       IS NULL
          );

   IF (SQL%ROWCOUNT <= 0) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' No Candidates Found to be inserted into table......';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

      IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                  p_tokval  => g_sob_id);
      IGC_MSGS_PKG.message_token (p_tokname => 'INPUT_DATE',
                                  p_tokval  => FND_DATE.DATE_TO_CHARDATE (g_last_activity_date));
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_NO_ARC_PUR_CANDIDATES');
      g_validation_error := TRUE;
   ELSE

-- --------------------------------------------------------------------
-- Now that the candidates have been chosen ensure that all the releases
-- for each cover are closed / cancelled.  Remove all cover candidates
-- chosen from above that are not closed / cancelled.
-- --------------------------------------------------------------------
      DELETE
        FROM igc_arc_pur_candidates
       WHERE cc_header_id IN
             ( SELECT parent_header_id
                 FROM igc_cc_headers
                WHERE parent_header_id IS NOT NULL
                  AND cc_header_id NOT IN
                      ( SELECT cc_header_id
                          FROM igc_arc_pur_candidates
                      )
             );

-- --------------------------------------------------------------------
-- Now that the candidates have been chosen ensure that all the releases
-- for each cover are closed / cancelled.  Remove all release candidates
-- chosen from above that are not closed / cancelled.
-- --------------------------------------------------------------------
      DELETE
        FROM igc_arc_pur_candidates
       WHERE cc_header_id IN
             ( SELECT cc_header_id
                 FROM igc_cc_headers
                WHERE parent_header_id IS NOT NULL
                  AND parent_header_id NOT IN
                      ( SELECT cc_header_id
                          FROM igc_arc_pur_candidates
                      )
             );

-- --------------------------------------------------------------------
-- Validate that there are candidates to be archived / purged from the
-- system.  If there are none then exit procedure with failure.
-- --------------------------------------------------------------------
       OPEN c_cand_count;
      FETCH c_cand_count
       INTO l_count;

      CLOSE c_cand_count;

      IF (l_count <= 0) THEN
         g_validation_error := TRUE;
--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := ' No Candidates Found to be inserted into table......';
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;
      END IF;

   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Build_Candidate_List procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (c_cand_count%ISOPEN) THEN
          CLOSE c_cand_count;
       END IF;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
       END IF;
       RETURN;

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (c_cand_count%ISOPEN) THEN
          CLOSE c_cand_count;
       END IF;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_cand_count%ISOPEN) THEN
          CLOSE c_cand_count;
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Build_Candidate_List;

--
-- Check_MRC Procedure to determine if MRC is installed/enabled.
--
-- Parameters :
--
-- x_return_status       ==>  Status returned from Procedure.
--
PROCEDURE Check_MRC (
   x_return_status     OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Define local variables to be used
-- --------------------------------------------------------------------
   l_api_name            CONSTANT VARCHAR2(30) := 'Check_MRC';
   l_full_path           VARCHAR2(255);
   l_igc_application_id  NUMBER;

BEGIN

   l_full_path := g_path || 'Check_MRC';

-- --------------------------------------------------------------------
-- Initialize local variables.
-- --------------------------------------------------------------------
   x_Return_Status := FND_API.G_RET_STS_SUCCESS;

-- --------------------------------------------------------------------
-- Get the information to determine if MRC is installed and enabled for
-- the set_of_books_id given
-- --------------------------------------------------------------------
   -- Replaced the call to mrc_isntalled with call to mrc_enabled
   -- for Bug 3448645
   -- gl_mc_info.mrc_installed ( mrc_install => g_mrc_installed );

   SELECT application_id
   INTO   l_igc_application_id
   FROM   fnd_application
   WHERE  application_short_name = 'IGC';

   gl_mc_info.mrc_enabled (n_sob_id         =>  g_sob_id,
                           n_appl_id        =>  l_igc_application_id,
                           n_org_id         =>  g_org_id,
                           n_fa_book_code   =>  NULL,
                           n_mrc_enabled    =>  g_mrc_installed);

   IF (g_mrc_installed <> 'Y') THEN
      g_mrc_installed := 'N';
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' MRC is NOT installed thus NOT enabled';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
   ELSE
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' MRC is installed so will be checking for ENABLED.';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Check_MRC procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
       END IF;
       RETURN;

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Check_MRC;

--
-- Cleanup_MRC_Arc_Tbls Procedure to cleanup any data that may be present for the
-- last activity date entered by the user.
--
-- Parameters :
--
-- x_return_status       ==>  Status returned from Procedure.
--
PROCEDURE Cleanup_MRC_Arc_Tbls (
   x_return_status     OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Define local variables to be used
-- --------------------------------------------------------------------
   l_api_name            CONSTANT VARCHAR2(30) := 'Cleanup_MRC_Arc_Tbls';
   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Cleanup_MRC_Arc_Tbls';

-- --------------------------------------------------------------------
-- Initialize local variables.
-- --------------------------------------------------------------------
   x_Return_Status := FND_API.G_RET_STS_SUCCESS;

-- --------------------------------------------------------------------
-- Delete MRC Archive Header records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive MRC Headers table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_mc_headers CMH
    WHERE CMH.cc_header_id IN
          ( SELECT ICV.cc_header_id
              FROM igc_arc_pur_candidates ICV
          );

-- --------------------------------------------------------------------
-- Delete MRC Archive Account Line records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive MRC Acct Lines table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_mc_acct_lines CML
    WHERE CML.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id  IN
                   ( SELECT ICV1.cc_header_id
                       FROM igc_arc_pur_candidates ICV1
                   )
          )
       OR CML.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id  IN
                   ( SELECT ICV2.cc_header_id
                       FROM igc_arc_pur_candidates ICV2
                   )
          );

-- --------------------------------------------------------------------
-- Delete MRC Archive Detail Payment Forcast records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive MRC DET PF table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_mc_det_pf CMP
    WHERE CMP.cc_det_pf_line_id IN
          ( SELECT DPFH.cc_det_pf_line_id
              FROM igc_cc_det_pf_history DPFH
             WHERE DPFH.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id IN
                            ( SELECT ICV1.cc_header_id
                                FROM igc_arc_pur_candidates ICV1
                            )
                   )
                OR DPFH.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id IN
                            ( SELECT ICV2.cc_header_id
                                FROM igc_arc_pur_candidates ICV2
                            )
                   )
          )
       OR CMP.cc_det_pf_line_id IN
          ( SELECT DPF.cc_det_pf_line_id
              FROM igc_cc_det_pf DPF
             WHERE DPF.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id IN
                            ( SELECT ICV1.cc_header_id
                                FROM igc_arc_pur_candidates ICV1
                            )
                   )
                OR DPF.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id IN
                            ( SELECT ICV2.cc_header_id
                                FROM igc_arc_pur_candidates ICV2
                            )
                   )
          );

-- --------------------------------------------------------------------
-- Delete MRC Archive Header History records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive MRC Header History table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_mc_header_hist CMHH
    WHERE CMHH.cc_header_id IN
          ( SELECT ICV.cc_header_id
              FROM igc_arc_pur_candidates ICV
          );

-- --------------------------------------------------------------------
-- Delete MRC Archive Account Line History records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive MRC Acct Line History table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_mc_acct_line_hist CMLH
    WHERE CMLH.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id  IN
                   ( SELECT ICV1.cc_header_id
                       FROM igc_arc_pur_candidates ICV1
                   )
          )
       OR CMLH.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id  IN
                   ( SELECT ICV2.cc_header_id
                       FROM igc_arc_pur_candidates ICV2
                   )
          );

-- --------------------------------------------------------------------
-- Delete MRC Archive Payment Forcast History records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive MRC DET PF History table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_mc_det_pf_hist CMPH
    WHERE CMPH.cc_det_pf_line_id IN
          ( SELECT DPFH.cc_det_pf_line_id
              FROM igc_cc_det_pf_history DPFH
             WHERE DPFH.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id IN
                            ( SELECT ICV1.cc_header_id
                                FROM igc_arc_pur_candidates ICV1
                            )
                   )
                OR DPFH.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id IN
                            ( SELECT ICV2.cc_header_id
                                FROM igc_arc_pur_candidates ICV2
                            )
                   )
          )
       OR CMPH.cc_det_pf_line_id IN
          ( SELECT DPF.cc_det_pf_line_id
              FROM igc_cc_det_pf DPF
             WHERE DPF.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id IN
                            ( SELECT ICV1.cc_header_id
                                FROM igc_arc_pur_candidates ICV1
                            )
                   )
                OR DPF.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id IN
                            ( SELECT ICV2.cc_header_id
                                FROM igc_arc_pur_candidates ICV2
                            )
                   )
          );

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Cleanup_MRC_Arc_Tbls procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
       END IF;
       RETURN;

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Cleanup_MRC_Arc_Tbls;

--
-- Cleanup_NON_MRC_Arc_Tbls Procedure to cleanup any data that may be present in
-- the tables that needs to be removed before adding the same records.
--
-- Parameters :
--
-- x_return_status       ==>  Status returned from Procedure.
--
PROCEDURE Cleanup_NON_MRC_Arc_Tbls (
   x_return_status     OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Define local variables to be used
-- --------------------------------------------------------------------
   l_api_name            CONSTANT VARCHAR2(30) := 'Cleanup_NON_MRC_Arc_Tbls';
   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Cleanup_NON_MRC_Arc_Tbls';

-- --------------------------------------------------------------------
-- Initialize local variables.
-- --------------------------------------------------------------------
   x_Return_Status := FND_API.G_RET_STS_SUCCESS;

-- --------------------------------------------------------------------
-- Delete Archive Header records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive Headers table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_headers_all CMH
    WHERE CMH.cc_header_id IN
          ( SELECT ICV.cc_header_id
              FROM igc_arc_pur_candidates ICV
          );

-- --------------------------------------------------------------------
-- Delete Archive Header History records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive Headers History table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_header_hist_all CAHH
    WHERE CAHH.cc_header_id IN
          ( SELECT ICV.cc_header_id
              FROM igc_arc_pur_candidates ICV
          );

-- --------------------------------------------------------------------
-- Delete Archive Account Line records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive Acct Lines table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_acct_lines CML
    WHERE CML.cc_header_id IN
          ( SELECT ICV.cc_header_id
              FROM igc_arc_pur_candidates ICV
          );

-- --------------------------------------------------------------------
-- Delete Archive Account Line History records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive Acct Lines History table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_acct_line_hist CML
    WHERE CML.cc_header_id IN
          ( SELECT ICV.cc_header_id
              FROM igc_arc_pur_candidates ICV
          );

-- --------------------------------------------------------------------
-- Delete Archive Payment Forcast records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive MRC DET PF table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_det_pf CDP
    WHERE CDP.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id IN
                   ( SELECT ICV1.cc_header_id
                       FROM igc_arc_pur_candidates ICV1
                   )
          )
       OR CDP.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id IN
                   ( SELECT ICV2.cc_header_id
                       FROM igc_arc_pur_candidates ICV2
                   )
          );

-- --------------------------------------------------------------------
-- Delete Archive Payment Forcast History records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive MRC DET PF History table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_det_pf_hist CDPH
    WHERE CDPH.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id IN
                   ( SELECT ICV1.cc_header_id
                       FROM igc_arc_pur_candidates ICV1
                   )
          )
       OR CDPH.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id IN
                   ( SELECT ICV1.cc_header_id
                       FROM igc_arc_pur_candidates ICV1
                   )
          );

-- --------------------------------------------------------------------
-- Delete Archive Action records before adding again.
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive Actions table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_actions CAA
    WHERE CAA.cc_header_id IN
          ( SELECT ICV.cc_header_id
              FROM igc_arc_pur_candidates ICV
          );

-- --------------------------------------------------------------------
-- Delete Archived PO Header records that may exist
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive PO Headers table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_po_headers IPHA
    WHERE IPHA.po_header_id IN
          ( SELECT PHA1.po_header_id
              FROM po_headers_all PHA1
             WHERE PHA1.segment1 IN
                   ( SELECT ICV.cc_num
                       FROM igc_arc_pur_candidates ICV
                   )
          );

-- --------------------------------------------------------------------
-- Delete Archived PO Line records that may exist
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive PO Lines table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_po_lines IPLA
    WHERE IPLA.po_header_id IN
          ( SELECT PHA.po_header_id
              FROM po_headers_all PHA
             WHERE PHA.segment1 IN
                   ( SELECT ICV.cc_num
                       FROM igc_arc_pur_candidates ICV
                   )
          );

-- --------------------------------------------------------------------
-- Delete Archived PO Line Location records that may exist
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive PO Line Locations table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_po_line_loc IPLLA
    WHERE IPLLA.po_header_id IN
          ( SELECT PHA.po_header_id
              FROM po_headers_all PHA
             WHERE PHA.segment1 IN
                   ( SELECT ICV.cc_num
                       FROM igc_arc_pur_candidates ICV
                   )
          );

-- --------------------------------------------------------------------
-- Delete Archived PO Distribution records that may exist
-- --------------------------------------------------------------------
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Deleting records from Archive PO Distributions table for' ||
                     ' Last Activity Date : ' || g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   DELETE
     FROM igc_cc_arc_po_distribution IPDA
    WHERE IPDA.po_header_id IN
          ( SELECT PHA.po_header_id
              FROM po_headers_all PHA
             WHERE PHA.segment1 IN
                   ( SELECT ICV.cc_num
                       FROM igc_arc_pur_candidates ICV
                   )
          );

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Cleanup_NON_MRC_Arc_Tbls procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
       END IF;
       RETURN;

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Cleanup_NON_MRC_Arc_Tbls;

--
-- Initializing History Record procedure that will setup the record that is to eventually
-- be inserted or updated in the Archive History Table.
--
-- Parameters :
--
-- p_cc_header_id      ==> CC Header ID to be archived / purged and added to the History Record
-- p_History_Rec       ==> Record that is to be returned initialized for IGC_CC_ARCHIVE_HISTORY table
-- x_Return_Status     ==> Status of procedure returned to caller
--
PROCEDURE Initialize_History_Record (
   p_cc_header_id         IN igc_cc_archive_history.cc_header_id%TYPE,
   p_History_Rec      IN OUT NOCOPY igc_cc_archive_history%ROWTYPE,
   x_Return_Status       OUT NOCOPY VARCHAR2
) IS

   l_api_name              CONSTANT VARCHAR2(30) := 'Initialize_History_Record';
   l_head_id               igc_cc_archive_history.cc_header_id%TYPE;
   l_sob_id                igc_cc_archive_history.set_of_books_id%TYPE;
   l_org_id                igc_cc_archive_history.org_id%TYPE;
   l_parent_id             igc_cc_archive_history.parent_header_id%TYPE;
   l_cc_type               igc_cc_archive_history.cc_type%TYPE;
   l_lines_arc             igc_cc_archive_history.num_acct_lines_arc%TYPE;
   l_pf_lines_arc          igc_cc_archive_history.num_det_pf_lines_arc%TYPE;
   l_mc_lines_arc          igc_cc_archive_history.num_mc_acct_lines_arc%TYPE;
   l_mc_pf_lines_arc       igc_cc_archive_history.num_mc_det_pf_lines_arc%TYPE;
   l_archive_date          igc_cc_archive_history.archive_date%TYPE;
   l_update_by             igc_cc_archive_history.last_updated_by%TYPE;
   l_archive_done          igc_cc_archive_history.archive_done_flag%TYPE;
   l_last_activity_date    igc_cc_archive_history.user_req_last_activity_date%TYPE;
   l_created_by            igc_cc_archive_history.created_by%TYPE;
   l_created_date          igc_cc_archive_history.creation_date%TYPE;

-- --------------------------------------------------------------------
-- Declare cursors to be used by this procedure.
-- --------------------------------------------------------------------
   CURSOR c_archive_history IS
      SELECT cc_header_id,
             set_of_books_id,
             org_id,
             parent_header_id,
             cc_num,
             cc_type,
             num_acct_lines_arc,
             num_det_pf_lines_arc,
             num_mc_acct_lines_arc,
             num_mc_det_pf_lines_arc,
             archive_date,
             last_updated_by,
             archive_done_flag,
             user_req_last_activity_date,
             created_by,
             creation_date
        FROM IGC_CC_ARCHIVE_HISTORY CAH
       WHERE CAH.cc_header_id      = p_cc_header_id
         AND CAH.org_id            = g_org_id
         AND CAH.set_of_books_id   = g_sob_id;

   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Initialize_History_Record';

-- --------------------------------------------------------------------
-- Initialize Return status and other local variables.
-- --------------------------------------------------------------------
   x_Return_Status   := FND_API.G_RET_STS_SUCCESS;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Initializing History Record for Archive / Purge Process';
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

    OPEN c_archive_history;
   FETCH c_archive_history
    INTO l_head_id,
         l_sob_id,
         l_org_id,
         l_parent_id,
         g_cc_num,
         l_cc_type,
         l_lines_arc,
         l_pf_lines_arc,
         l_mc_lines_arc,
         l_mc_pf_lines_arc,
         l_archive_date,
         l_update_by,
         l_archive_done,
         l_last_activity_date,
         l_created_by,
         l_created_date;

   p_History_Rec.set_of_books_id               := g_sob_id;
   p_History_Rec.org_id                        := g_org_id;
   p_History_Rec.last_update_date              := SYSDATE;
   p_History_Rec.last_updated_by               := g_update_by;
   p_History_Rec.last_update_login             := g_update_by;

   IF (c_archive_history%FOUND) THEN

      p_History_Rec.cc_header_id                  := l_head_id;
      p_History_Rec.parent_header_id              := l_parent_id;
      p_History_Rec.cc_num                        := g_cc_num;
      p_History_Rec.cc_type                       := l_cc_type;
      p_History_Rec.user_req_last_activity_date   := l_last_activity_date;
      p_History_Rec.last_cc_activity_date         := NULL;
      p_History_Rec.created_by                    := l_created_by;
      p_History_Rec.creation_date                 := l_created_date;

      IF (g_mode = 'AR') THEN
         p_History_Rec.num_acct_lines_arc            := 0;
         p_History_Rec.num_det_pf_lines_arc          := 0;
         p_History_Rec.num_mc_acct_lines_arc         := 0;
         p_History_Rec.num_mc_det_pf_lines_arc       := 0;
         p_History_Rec.archive_date                  := SYSDATE;
         p_History_Rec.archived_by                   := g_update_by;
         p_History_Rec.archive_done_flag             := 'N';
         p_History_Rec.purge_date                    := NULL;
         p_History_Rec.purged_by                     := NULL;
         p_History_Rec.purge_done_flag               := 'N';
      ELSE
         p_History_Rec.num_acct_lines_arc            := l_lines_arc;
         p_History_Rec.num_det_pf_lines_arc          := l_pf_lines_arc;
         p_History_Rec.num_mc_acct_lines_arc         := l_mc_lines_arc;
         p_History_Rec.num_mc_det_pf_lines_arc       := l_mc_pf_lines_arc;
         p_History_Rec.archive_date                  := l_archive_date;
         p_History_Rec.archived_by                   := l_update_by;
         p_History_Rec.archive_done_flag             := l_archive_done;
         p_History_Rec.purge_date                    := SYSDATE;
         p_History_Rec.purged_by                     := g_update_by;
         p_History_Rec.purge_done_flag               := 'N';
      END IF;

   ELSE

      IF (g_mode = 'AR') THEN

         p_History_Rec.cc_header_id                  := p_cc_header_id;
         p_History_Rec.parent_header_id              := NULL;
         p_History_Rec.cc_num                        := NULL;
         p_History_Rec.cc_type                       := NULL;
         p_History_Rec.num_acct_lines_arc            := 0;
         p_History_Rec.num_det_pf_lines_arc          := 0;
         p_History_Rec.num_mc_acct_lines_arc         := 0;
         p_History_Rec.num_mc_det_pf_lines_arc       := 0;
         p_History_Rec.archive_date                  := SYSDATE;
         p_History_Rec.archived_by                   := g_update_by;
         p_History_Rec.archive_done_flag             := 'N';
         p_History_Rec.purge_date                    := NULL;
         p_History_Rec.purged_by                     := NULL;
         p_History_Rec.purge_done_flag               := 'N';
         p_History_Rec.last_cc_activity_date         := NULL;
         p_History_Rec.user_req_last_activity_date   := g_last_activity_date;
         p_History_Rec.created_by                    := g_update_by;
         p_History_Rec.creation_date                 := SYSDATE;

      ELSE

--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := ' Not allowed to initialize history record as not found in History Table';
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            g_debug_msg := ' and activity is not archive.  CC Header id : ' || p_cc_header_id;
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;

         IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                     p_tokval  => g_sob_id);
         IGC_MSGS_PKG.message_token (p_tokname => 'VALUE1',
                                     p_tokval  => p_cc_header_id);
         IGC_MSGS_PKG.message_token (p_tokname => 'VALUE2',
                                     p_tokval  => FND_DATE.DATE_TO_CHARDATE (g_last_activity_date));
         IGC_MSGS_PKG.message_token (p_tokname => 'COMPONENT',
                                     p_tokval  => 'CC');
         IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                   p_msgname => 'IGC_NUM_PUR_NO_MATCH_ARC');
         raise FND_API.G_EXC_ERROR;

      END IF;

   END IF;

   CLOSE c_archive_history;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Initialize_History_Record procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_archive_history%ISOPEN) THEN
          CLOSE c_archive_history;
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Initialize_History_Record;


--
-- Insert_Archive_History Procedure is designed to ensure that there are history records
-- created for all the records that have been archived based upon the last activity date
-- given by the user
--
-- Parameters :
--
-- x_Return_Status ==>  Status of the procedure returned to caller.
--
PROCEDURE Insert_Archive_History (
   x_Return_Status  OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Declare local variables to be used in this procedure.
-- --------------------------------------------------------------------
   l_return_status          VARCHAR2(1);
   l_cc_header_id           igc_cc_headers.cc_header_id%TYPE;
   l_cc_type                igc_cc_headers.cc_type%TYPE;
   l_parent_id              igc_cc_headers.parent_header_id%TYPE;
   l_history_rec            igc_cc_archive_history%ROWTYPE;
   l_max_date               igc_arc_pur_candidates.last_activity_date%TYPE;

   l_api_name               CONSTANT VARCHAR2(30) := 'Insert_Archive_History';

-- --------------------------------------------------------------------
-- Declare cursors to be used in this procedure.
-- --------------------------------------------------------------------
   CURSOR c_get_archived_hdrs IS
      SELECT distinct (cc_header_id),
             cc_num,
             last_activity_date
        FROM igc_arc_pur_candidates;

   CURSOR c_cc_header_info IS
      SELECT cc_header_id,
             cc_num,
             cc_type,
             parent_header_id
        FROM igc_cc_headers
       WHERE cc_header_id    = l_cc_header_id;
 	/*AND set_of_books_id = g_sob_id
         AND org_id          = g_org_id; --Commented during MOAC uptake*/

   CURSOR c_acct_line_count IS
      SELECT count(*)
        FROM igc_cc_arc_acct_lines
       WHERE cc_header_id = l_cc_header_id;

   CURSOR c_pf_line_count IS
      SELECT count(*)
        FROM igc_cc_arc_det_pf ICADP
       WHERE ICADP.cc_acct_line_id IN
             ( SELECT ICAAL.cc_acct_line_id
                 FROM igc_cc_arc_acct_lines ICAAL
                WHERE ICAAL.cc_header_id = l_cc_header_id
             );

   CURSOR c_mc_acct_line_count IS
      SELECT count(*)
        FROM igc_cc_arc_mc_acct_lines ICAMAL
       WHERE ICAMAL.cc_acct_line_id IN
             ( SELECT ICAAL.cc_acct_line_id
                 FROM igc_cc_arc_acct_lines ICAAL
                WHERE ICAAL.cc_header_id = l_cc_header_id
             );

   CURSOR c_mc_pf_line_count IS
      SELECT count(*)
        FROM igc_cc_arc_mc_det_pf ICAMDP
       WHERE ICAMDP.cc_det_pf_line_id IN
             ( SELECT ICADP.cc_det_pf_line_id
                 FROM igc_cc_arc_det_pf ICADP
                WHERE ICADP.cc_acct_line_id IN
                      ( SELECT ICAAL.cc_acct_line_id
                          FROM igc_cc_arc_acct_lines ICAAL
                         WHERE ICAAL.cc_header_id = l_cc_header_id
                      )
             );
   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Insert_Archive_History';

-- --------------------------------------------------------------------
-- Initialize Return status and other local variables.
-- --------------------------------------------------------------------
   x_Return_Status       := FND_API.G_RET_STS_SUCCESS;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Beginning Inserting Archive History Records for Last Activity Date : ' ||
                       g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Open the cursor to obtain all the records that have been added into
-- the appropriate archive CC Header table and then begin to insert
-- the corresponding history record.
-- --------------------------------------------------------------------
    OPEN c_get_archived_hdrs;
   FETCH c_get_archived_hdrs
    INTO l_cc_header_id,
         g_cc_num,
         l_max_date;

   IF (c_get_archived_hdrs%FOUND) THEN

      WHILE (c_get_archived_hdrs%FOUND) LOOP

--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := ' Inserting Archive History Record for CC Header ID : ' ||
                             l_cc_header_id;
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;

-- -------------------------------------------------------------------
-- Initialize the record that will be inserted into the Archive
-- History Table.
-- -------------------------------------------------------------------
         Initialize_History_Record (p_cc_header_id   => l_cc_header_id,
                                    p_History_Rec    => l_history_rec,
                                    x_Return_Status  => l_return_status
                                   );

         IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
            raise FND_API.G_EXC_ERROR;
         END IF;

          OPEN c_cc_header_info;
         FETCH c_cc_header_info
          INTO l_cc_header_id,
               g_cc_num,
               l_cc_type,
               l_parent_id;

         IF (c_cc_header_info%FOUND) THEN

            l_history_rec.parent_header_id      := l_parent_id;
            l_history_rec.cc_type               := l_cc_type;
            l_history_rec.cc_num                := g_cc_num;
            l_history_rec.last_cc_activity_date := l_max_date;
            l_history_rec.archive_done_flag     := 'Y';

-- -------------------------------------------------------------------
-- Get the number of account lines that were archived.
-- -------------------------------------------------------------------
             OPEN c_acct_line_count;
            FETCH c_acct_line_count
             INTO l_history_rec.num_acct_lines_arc;

            CLOSE c_acct_line_count;

-- -------------------------------------------------------------------
-- Get the number of Det PF lines that were archived.
-- -------------------------------------------------------------------
             OPEN c_pf_line_count;
            FETCH c_pf_line_count
             INTO l_history_rec.num_det_pf_lines_arc;

            CLOSE c_pf_line_count;

-- -------------------------------------------------------------------
-- Get the Number of MRC Acct Lines that were archived.
-- -------------------------------------------------------------------
             OPEN c_mc_acct_line_count;
            FETCH c_mc_acct_line_count
             INTO l_history_rec.num_mc_acct_lines_arc;

            CLOSE c_mc_acct_line_count;

-- -------------------------------------------------------------------
-- Get the number of MRC DET PF Lines that were archived.
-- -------------------------------------------------------------------
             OPEN c_mc_pf_line_count;
            FETCH c_mc_pf_line_count
             INTO l_history_rec.num_mc_det_pf_lines_arc;

            CLOSE c_mc_pf_line_count;

-- -------------------------------------------------------------------
-- Update or insert the appropriate record in the history table.
-- -------------------------------------------------------------------
            Update_History (p_History_Rec    => l_history_rec,
                            x_Return_Status  => l_return_status
                           );

            IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
               raise FND_API.G_EXC_ERROR;
            END IF;

         ELSE

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'View returned CC Header ID : ' ||
                           l_cc_header_id || ' But could not find it in Cursor.';
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

            IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                        p_tokval  => g_sob_id);
            IGC_MSGS_PKG.message_token (p_tokname => 'VALUE1',
                                        p_tokval  => g_cc_num);
            IGC_MSGS_PKG.message_token (p_tokname => 'VALUE2',
                                        p_tokval  => FND_DATE.DATE_TO_CHARDATE (g_last_activity_date));
            IGC_MSGS_PKG.message_token (p_tokname => 'COMPONENT',
                                        p_tokval  => 'CC');
            IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                      p_msgname => 'IGC_NUM_PUR_NO_MATCH_ARC');
            raise FND_API.G_EXC_ERROR;

         END IF;

         IF (c_cc_header_info%ISOPEN) THEN
            CLOSE c_cc_header_info;
         END IF;

         FETCH c_get_archived_hdrs
          INTO l_cc_header_id,
               g_cc_num,
               l_max_date;

      END LOOP;

   ELSE

      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := 'No Archive Candidates to insert into history table.';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

      IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                  p_tokval  => g_sob_id);
      IGC_MSGS_PKG.message_token (p_tokname => 'VALUE1',
                                  p_tokval  => g_cc_num);
      IGC_MSGS_PKG.message_token (p_tokname => 'VALUE2',
                                  p_tokval  => FND_DATE.DATE_TO_CHARDATE (g_last_activity_date));
      IGC_MSGS_PKG.message_token (p_tokname => 'COMPONENT',
                                  p_tokval  => 'CC');
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_NO_ARC_RECORDS');

   END IF;

-- -------------------------------------------------------------------------
--  Close any and all cursors before returning.
-- -------------------------------------------------------------------------
   IF (c_get_archived_hdrs%ISOPEN) THEN
      CLOSE c_get_archived_hdrs;
   END IF;
   IF (c_cc_header_info%ISOPEN) THEN
      CLOSE c_cc_header_info;
   END IF;
   IF (c_acct_line_count%ISOPEN) THEN
      CLOSE c_acct_line_count;
   END IF;
   IF (c_mc_acct_line_count%ISOPEN) THEN
      CLOSE c_mc_acct_line_count;
   END IF;
   IF (c_pf_line_count%ISOPEN) THEN
      CLOSE c_pf_line_count;
   END IF;
   IF (c_mc_pf_line_count%ISOPEN) THEN
      CLOSE c_mc_pf_line_count;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Insert_Archive_History procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (c_get_archived_hdrs%ISOPEN) THEN
          CLOSE c_get_archived_hdrs;
       END IF;
       IF (c_cc_header_info%ISOPEN) THEN
          CLOSE c_cc_header_info;
       END IF;
       IF (c_acct_line_count%ISOPEN) THEN
          CLOSE c_acct_line_count;
       END IF;
       IF (c_mc_acct_line_count%ISOPEN) THEN
          CLOSE c_mc_acct_line_count;
       END IF;
       IF (c_pf_line_count%ISOPEN) THEN
          CLOSE c_pf_line_count;
       END IF;
       IF (c_mc_pf_line_count%ISOPEN) THEN
          CLOSE c_mc_pf_line_count;
       END IF;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_get_archived_hdrs%ISOPEN) THEN
          CLOSE c_get_archived_hdrs;
       END IF;
       IF (c_cc_header_info%ISOPEN) THEN
          CLOSE c_cc_header_info;
       END IF;
       IF (c_acct_line_count%ISOPEN) THEN
          CLOSE c_acct_line_count;
       END IF;
       IF (c_mc_acct_line_count%ISOPEN) THEN
          CLOSE c_mc_acct_line_count;
       END IF;
       IF (c_pf_line_count%ISOPEN) THEN
          CLOSE c_pf_line_count;
       END IF;
       IF (c_mc_pf_line_count%ISOPEN) THEN
          CLOSE c_mc_pf_line_count;
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Insert_Archive_History;

--
-- Lock_Candidates Function is designed to ensure that if one process is already
-- performing the Archive Purge process that another one can not be started.
--
-- Parameters :
--     NONE
--
FUNCTION Lock_Candidates
RETURN BOOLEAN IS

-- --------------------------------------------------------------------
-- Declare local variables to be used.
-- --------------------------------------------------------------------
   l_counter       NUMBER(1) := 0;
   l_cc_header     igc_cc_headers.cc_header_id%TYPE;
   l_api_name      CONSTANT VARCHAR2(30)   := 'Lock_Candidates';

   CURSOR c_lock_candidates IS
      SELECT cc_header_id
        FROM igc_arc_pur_candidates
      FOR UPDATE NOWAIT;

   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Lock_Candidates';

   WHILE l_counter < g_maxloops LOOP   -- Loop in case we need to retry lock
      BEGIN    -- loop block

         OPEN c_lock_candidates;

         FETCH c_lock_candidates
          INTO l_cc_header;

         IF (c_lock_candidates%NOTFOUND) THEN

            CLOSE c_lock_candidates;
--            IF (IGC_MSGS_PKG.g_debug_mode) THEN
            IF (g_debug_mode = 'Y') THEN
               Output_Debug (l_full_path, 'No records found to lock in IGC_CC_ARC_PUR_CANDIDATES');
            END IF;
            RETURN TRUE;

         ELSE		-- lock, with records, has been obtained

            CLOSE c_lock_candidates;
            RETURN TRUE;

         END IF;

         EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
               IF (c_lock_candidates%ISOPEN) THEN
                  CLOSE c_lock_candidates;
               END IF;
               IF (g_excep_level >=  g_debug_level ) THEN
                  FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
               END IF;
               RETURN FALSE;

            WHEN OTHERS THEN
               IF (SQLCODE = -54) THEN          -- Record(s) are already locked
                  l_counter := l_counter + 1;

                  IF (l_counter >= g_maxloops) THEN -- Tried max number of times
                     IGC_MSGS_PKG.message_token (p_tokname => 'VALUE',
                                                 p_tokval  => to_char(g_maxloops));
                     IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                               p_msgname => 'IGC_CC_UNABLE_TO_LOCK');

                     IF (c_lock_candidates%ISOPEN) THEN
                        CLOSE c_lock_candidates;
                     END IF;
--                     IF (IGC_MSGS_PKG.g_debug_mode) THEN
                     IF (g_debug_mode = 'Y') THEN
                        Output_Debug (l_full_path, 'Maximum tries reached: unable to lock IGC_CC_ARC_PUR_CANDIDATES');
                     END IF;
                     RETURN FALSE;
                  END IF;

                  DBMS_LOCK.SLEEP (g_seconds);   -- Wait, then try again

               ELSE

                  IF (c_lock_candidates%ISOPEN) THEN
                     CLOSE c_lock_candidates;
                  END IF;
                  IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
                     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,l_api_name);
                  END IF;
               END IF;
               IF ( g_unexp_level >= g_debug_level ) THEN
                  FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                  FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                  FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                  FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
               END IF;

      END;     -- inner block

   END LOOP; -- WHILE loop


EXCEPTION
   WHEN OTHERS THEN
     IF (c_lock_candidates%ISOPEN) THEN
       CLOSE c_lock_candidates;
     END IF;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,l_api_name);
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
       FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
       FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
       FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     RETURN FALSE;

END Lock_Candidates;

--
-- Output_Debug Procedure is the Generic procedure designed for outputting debug
-- information that is required from this procedure.
--
-- Parameters :
--
-- p_debug_msg ==> Record to be output into the debug log file.
--
PROCEDURE Output_Debug (
   p_path           IN VARCHAR2,
   p_debug_msg      IN VARCHAR2
) IS

-- Constants :

/*   l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(6)           := 'CC_ARC';
   l_profile_name     VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';
   l_Return_Status    VARCHAR2(1);*/
   l_api_name         CONSTANT VARCHAR2(30) := 'Output_Debug';

BEGIN

/*   IGC_MSGS_PKG.Put_Debug_Msg (p_debug_message    => p_debug_msg,
                               p_profile_log_name => l_profile_name,
                               p_prod             => l_prod,
                               p_sub_comp         => l_sub_comp,
                               p_filename_val     => NULL,
                               x_Return_Status    => l_Return_Status
                              );

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;*/

   IF(g_state_level >= g_debug_level) THEN
        FND_LOG.STRING(g_state_level, p_path, p_debug_msg);
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Output_Debug procedure.
-- --------------------------------------------------------------------
EXCEPTION

   /*WHEN FND_API.G_EXC_ERROR THEN
       RETURN;*/

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       RETURN;

END Output_Debug;

--
-- Purge_CC Procedure is the main process designed for deleting the CC Header IDs
-- from the system that have met the criteria for purging.
--
-- Parameters :
--
-- x_Return_Status       ==> Status of procedure returned to caller
--
PROCEDURE Purge_CC (
   x_Return_Status       OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Declare local variables to be used in this procedure.
-- --------------------------------------------------------------------
   l_return_status          VARCHAR2(1);
   l_api_name               CONSTANT VARCHAR2(30) := 'Purge_CC';
   l_full_path              VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Purge_CC';

-- --------------------------------------------------------------------
-- Initialize Return status and other local variables.
-- --------------------------------------------------------------------
   x_Return_Status       := FND_API.G_RET_STS_SUCCESS;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Beginning Purge process for Last Activity Date : ' ||
                       g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- -------------------------------------------------------------------
-- Determine if MRC has been installed and enabled and if this is the
-- case then call the appropriate procedure to remove any MRC records
-- that are candidates for removal and the correct number of records
-- were previously archived.
-- -------------------------------------------------------------------
   IF (g_mrc_installed = 'Y') THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' Attempt delete records in MRC tables. Last Activity Date : ' ||
                        g_last_activity_date;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

      Purge_MRC_Tbls (x_return_status => l_return_status);

      IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

   ELSE

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' NOT deleting records from MRC tables. Last Activity Date : ' ||
                        g_last_activity_date;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         g_debug_msg := ' MRC is not enabled or installed.';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

   END IF;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Attempt delete records in NON MRC tables. Last Activity Date : ' ||
                     g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- -------------------------------------------------------------------
-- Call the appropriate procedure to remove any NON MRC records that
-- are candidates for removal and the correct number of records were
-- previously archived.
-- -------------------------------------------------------------------
   Purge_NON_MRC_Tbls (x_return_status => l_return_status);

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Purge_CC procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Purge_CC;

--
-- Purge_MRC_Tbls Procedure is designed to purge ONLY the MRC related data for the CC
-- Header IDs that have been found to be valid candidates for purging.
--
-- Parameters :
--
-- x_Return_Status       ==> Status of procedure returned to caller
--
PROCEDURE Purge_MRC_Tbls (
   x_Return_Status       OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Declare local variables to be used in this procedure.
-- --------------------------------------------------------------------
   l_cc_header_id           igc_cc_headers.cc_header_id%TYPE;
   l_num_mc_acct_arc        igc_cc_archive_history.num_mc_acct_lines_arc%TYPE;
   l_num_mc_pf_arc          igc_cc_archive_history.num_mc_det_pf_lines_arc%TYPE;
   l_num_mc_acct_pur        igc_cc_archive_history.num_mc_acct_lines_arc%TYPE;
   l_num_mc_pf_pur          igc_cc_archive_history.num_mc_det_pf_lines_arc%TYPE;
   l_api_name               CONSTANT VARCHAR2(30) := 'Purge_MRC_Tbls';

-- --------------------------------------------------------------------
-- Declare any cursors to be used.
-- --------------------------------------------------------------------
   CURSOR c_get_arc_hist_info IS
     SELECT num_mc_acct_lines_arc,
            num_mc_det_pf_lines_arc
       FROM igc_cc_archive_history
      WHERE cc_header_id      = l_cc_header_id
        AND set_of_books_id   = g_sob_id
        AND org_id            = g_org_id
        AND archive_done_flag = 'Y';

   CURSOR c_get_purge_candidate IS
      SELECT distinct (ICAP.cc_header_id)
        FROM igc_arc_pur_candidates ICAP;
   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Purge_MRC_Tbls';

-- --------------------------------------------------------------------
-- Initialize Return status and other local variables.
-- --------------------------------------------------------------------
   x_Return_Status       := FND_API.G_RET_STS_SUCCESS;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Beginning Purge MRC Tables process for Last Activity Date : ' ||
                       g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

    OPEN c_get_purge_candidate;
   FETCH c_get_purge_candidate
    INTO l_cc_header_id;

   IF (c_get_purge_candidate%FOUND) THEN

      WHILE (c_get_purge_candidate%FOUND) LOOP

         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := '********** Deleting MRC CC Header ID : ' ||
                        l_cc_header_id || ' SOB ID : ' || g_sob_id || ' *************';
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;

-- --------------------------------------------------------------------
-- Get CC Header information on record previously archived.
-- --------------------------------------------------------------------
         OPEN c_get_arc_hist_info;
         FETCH c_get_arc_hist_info
          INTO l_num_mc_acct_arc,
               l_num_mc_pf_arc;

         IF (c_get_arc_hist_info%FOUND) THEN

-- --------------------------------------------------------------------
-- Delete all MRC PF History Lines for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_mc_det_pf_history DPH
             WHERE DPH.cc_det_pf_line_id IN
                   ( SELECT DPFH.cc_det_pf_line_id
                       FROM igc_cc_det_pf_history DPFH
                      WHERE DPFH.cc_acct_line_id IN
                            ( SELECT ACLH.cc_acct_line_id
                                FROM igc_cc_acct_line_history ACLH
                               WHERE ACLH.cc_header_id = l_cc_header_id
                            )
                         OR DPFH.cc_acct_line_id IN
                            ( SELECT ACL.cc_acct_line_id
                                FROM igc_cc_acct_lines ACL
                               WHERE ACL.cc_header_id = l_cc_header_id
                            )
                   )
                OR DPH.cc_det_pf_line_id IN
                   ( SELECT DPF.cc_det_pf_line_id
                       FROM igc_cc_det_pf DPF
                      WHERE DPF.cc_acct_line_id IN
                            ( SELECT ACLH.cc_acct_line_id
                                FROM igc_cc_acct_line_history ACLH
                               WHERE ACLH.cc_header_id = l_cc_header_id
                            )
                         OR DPF.cc_acct_line_id IN
                            ( SELECT ACL.cc_acct_line_id
                                FROM igc_cc_acct_lines ACL
                               WHERE ACL.cc_header_id = l_cc_header_id
                            )
                   );

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_MC_DET_PF_HISTORY for CC Header ID : ' ||
                           l_cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all MRC PF History Lines for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_mc_det_pf DP
             WHERE DP.cc_det_pf_line_id IN
                   ( SELECT DPFH.cc_det_pf_line_id
                       FROM igc_cc_det_pf_history DPFH
                      WHERE DPFH.cc_acct_line_id IN
                            ( SELECT ACLH.cc_acct_line_id
                                FROM igc_cc_acct_line_history ACLH
                               WHERE ACLH.cc_header_id = l_cc_header_id
                            )
                         OR DPFH.cc_acct_line_id IN
                            ( SELECT ACL.cc_acct_line_id
                                FROM igc_cc_acct_lines ACL
                               WHERE ACL.cc_header_id = l_cc_header_id
                            )
                   )
                OR DP.cc_det_pf_line_id IN
                   ( SELECT DPF.cc_det_pf_line_id
                       FROM igc_cc_det_pf DPF
                      WHERE DPF.cc_acct_line_id IN
                            ( SELECT ACLH.cc_acct_line_id
                                FROM igc_cc_acct_line_history ACLH
                               WHERE ACLH.cc_header_id = l_cc_header_id
                            )
                         OR DPF.cc_acct_line_id IN
                            ( SELECT ACL.cc_acct_line_id
                                FROM igc_cc_acct_lines ACL
                               WHERE ACL.cc_header_id = l_cc_header_id
                            )
                   );

            l_num_mc_pf_pur := SQL%ROWCOUNT;
            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_MC_DET_PF for CC Header ID : ' ||
                           l_cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all MRC Account Line History Lines for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_mc_acct_line_history CALH
             WHERE CALH.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id = l_cc_header_id
                   )
                OR CALH.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id = l_cc_header_id
                   );

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_MC_ACCT_LINE_HISTORY CC Header ID : ' ||
                           l_cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all MRC Account Line History Lines for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_mc_acct_lines CAL
             WHERE CAL.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id = l_cc_header_id
                   )
                OR CAL.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id = l_cc_header_id
                   );

            l_num_mc_acct_pur := SQL%ROWCOUNT;
            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_MC_ACCT_LINES for CC Header ID : ' ||
                           l_cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all MRC Header History records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_mc_header_history
             WHERE cc_header_id = l_cc_header_id;

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_MC_HEADER_HISTORY for CC Header ID : ' ||
                           l_cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all MRC Header records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_mc_headers
             WHERE cc_header_id = l_cc_header_id;

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_MC_HEADERS for CC Header ID : ' ||
                           l_cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- -------------------------------------------------------------------
-- Make sure that the values being checked are set to 0 if NULL.
-- -------------------------------------------------------------------
            l_num_mc_acct_pur := NVL (l_num_mc_acct_pur, 0);
            l_num_mc_pf_pur   := NVL (l_num_mc_pf_pur, 0);

-- -------------------------------------------------------------------
-- Check to make sure that the # of records purged match the number
-- of records that were previously archived.
-- -------------------------------------------------------------------
            IF ((l_num_mc_acct_arc <> l_num_mc_acct_pur) OR
                (l_num_mc_pf_arc <> l_num_mc_pf_pur)) THEN

               IF (g_debug_mode = 'Y') THEN
                  g_debug_msg := ' Number MRC Acct Lines Archived : ' || l_num_mc_acct_arc ||
                              ' Number MRC Acct Lines Purged : ' || l_num_mc_acct_pur ||
                              ' Number MRC PF Lines Archived : ' || l_num_mc_pf_arc ||
                              ' Number MRC PF Lines Purged : ' || l_num_mc_pf_pur ||
                              ' Does not match for CC Header ID : ' ||
                              l_cc_header_id || ' SOB ID : ' || g_sob_id ||
                              '.  Thus no Purge can be done for Header ID.';
                  Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
               END IF;

               IGC_MSGS_PKG.message_token (p_tokname => 'CC_NUM',
                                           p_tokval  => g_cc_num);
               IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                           p_tokval  => g_sob_id);
               IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                         p_msgname => 'IGC_NUM_MC_PUR_NO_MATCH_ARC');
               raise FND_API.G_EXC_ERROR;

            END IF;

         ELSE

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Header ID Not found in Archive History Table for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id ||
                           '.  Thus no Purge can be done for Header ID.';
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

            IGC_MSGS_PKG.message_token (p_tokname => 'CC_NUM',
                                        p_tokval  => g_cc_num);
            IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                        p_tokval  => g_sob_id);
            IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                      p_msgname => 'IGC_NUM_MC_PUR_NO_MATCH_ARC');
            raise FND_API.G_EXC_ERROR;

         END IF;

-- -------------------------------------------------------------------
-- Close the cursor opened.
-- -------------------------------------------------------------------
         IF (c_get_arc_hist_info%ISOPEN) THEN
            CLOSE c_get_arc_hist_info;
         END IF;

         FETCH c_get_purge_candidate
          INTO l_cc_header_id;

      END LOOP;

   ELSE

      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := 'View returned CC Header ID : ' ||
                     l_cc_header_id || ' But could not find it in Cursor.';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

      IGC_MSGS_PKG.message_token (p_tokname => 'CC_NUM',
                                  p_tokval  => g_cc_num);
      IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                  p_tokval  => g_sob_id);
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_NUM_MC_PUR_NO_MATCH_ARC');
      raise FND_API.G_EXC_ERROR;

   END IF;

-- -------------------------------------------------------------------
-- Close the cursors opened.
-- -------------------------------------------------------------------
   IF (c_get_purge_candidate%ISOPEN) THEN
      CLOSE c_get_purge_candidate;
   END IF;
   IF (c_get_arc_hist_info%ISOPEN) THEN
      CLOSE c_get_arc_hist_info;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Purge_CC procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (c_get_purge_candidate%ISOPEN) THEN
          CLOSE c_get_purge_candidate;
       END IF;
       IF (c_get_arc_hist_info%ISOPEN) THEN
          CLOSE c_get_arc_hist_info;
       END IF;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_get_purge_candidate%ISOPEN) THEN
          CLOSE c_get_purge_candidate;
       END IF;
       IF (c_get_arc_hist_info%ISOPEN) THEN
          CLOSE c_get_arc_hist_info;
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Purge_MRC_Tbls;

--
-- Purge_NON_MRC_Tbls Procedure is designed for purging all the tables that are not
-- related to MRC for the CC Header IDs that were found to be valid for purging.
--
-- Parameters :
--
-- x_Return_Status       ==> Status of procedure returned to caller
--
PROCEDURE Purge_NON_MRC_Tbls (
   x_Return_Status       OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Declare local variables to be used in this procedure.
-- --------------------------------------------------------------------
   l_cc_header_id           igc_cc_headers.cc_header_id%TYPE;
   l_sob_id                 igc_cc_headers.set_of_books_id%TYPE;
   l_num_acct_arc           igc_cc_archive_history.num_acct_lines_arc%TYPE;
   l_num_pf_arc             igc_cc_archive_history.num_det_pf_lines_arc%TYPE;
   l_num_acct_pur           igc_cc_archive_history.num_acct_lines_arc%TYPE;
   l_num_pf_pur             igc_cc_archive_history.num_det_pf_lines_arc%TYPE;
   l_api_name               CONSTANT VARCHAR2(30) := 'Purge_NON_MRC_Tbls';
   l_history_rec            igc_cc_archive_history%ROWTYPE;
   l_return_status          VARCHAR2(1);

-- --------------------------------------------------------------------
-- Declare any cursors to be used.
-- --------------------------------------------------------------------
   CURSOR c_get_arc_hist_info IS
     SELECT num_acct_lines_arc,
            num_det_pf_lines_arc
       FROM igc_cc_archive_history
      WHERE cc_header_id      = l_cc_header_id
        /* AND set_of_books_id   = g_sob_id
        AND org_id            = g_org_id --Commented for MOAC uptake */
        AND archive_done_flag = 'Y';

   CURSOR c_get_purge_candidate IS
      SELECT distinct (ICAP.cc_header_id)
        FROM igc_arc_pur_candidates ICAP;

   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Purge_NON_MRC_Tbls';

-- --------------------------------------------------------------------
-- Initialize Return status and other local variables.
-- --------------------------------------------------------------------
   x_Return_Status       := FND_API.G_RET_STS_SUCCESS;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Beginning Purge NON MRC Tables process for Last Activity Date : ' ||
                       g_last_activity_date;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

    OPEN c_get_purge_candidate;
   FETCH c_get_purge_candidate
    INTO l_cc_header_id;

   IF (c_get_purge_candidate%FOUND) THEN

      WHILE (c_get_purge_candidate%FOUND) LOOP

         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := '********** Deleting NON MRC CC Header ID : ' ||
                        l_cc_header_id || ' SOB ID : ' || g_sob_id || ' *************';
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;

-- --------------------------------------------------------------------
-- Get CC Header information on record previously archived.
-- --------------------------------------------------------------------
         OPEN c_get_arc_hist_info;
         FETCH c_get_arc_hist_info
          INTO l_num_acct_arc,
               l_num_pf_arc;

         IF (c_get_arc_hist_info%FOUND) THEN

-- --------------------------------------------------------------------
-- Delete all CC Action records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_actions
             WHERE cc_header_id = l_cc_header_id;

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_ACTIONS for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all PO Distribution records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM po_distributions_all PDA
             WHERE PDA.po_header_id IN
                   ( SELECT PHA.po_header_id
                       FROM po_headers_all PHA
                      WHERE PHA.segment1 IN
                            ( SELECT ICV.cc_num
                                FROM igc_arc_pur_candidates ICV
                               WHERE ICV.cc_header_id = l_cc_header_id
                            )
                   );

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from PO_DISTRIBUTIONS_ALL for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all PO Line Location records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM po_line_locations_all PLLA
             WHERE PLLA.po_header_id IN
                   ( SELECT PHA.po_header_id
                       FROM po_headers_all PHA
                      WHERE PHA.segment1 IN
                            ( SELECT ICV.cc_num
                                FROM igc_arc_pur_candidates ICV
                               WHERE ICV.cc_header_id = l_cc_header_id
                            )
                   );

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from PO_LINE_LOCATIONS_ALL for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all PO Lines records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM po_lines_all     PLA
             WHERE PLA.po_header_id IN
                   ( SELECT PHA.po_header_id
                       FROM po_headers_all PHA
                      WHERE PHA.segment1 IN
                            ( SELECT ICV.cc_num
                                FROM igc_arc_pur_candidates ICV
                               WHERE ICV.cc_header_id = l_cc_header_id
                            )
                   );

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from PO_LINES_ALL for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all PO Header records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM po_headers_all PHA
             WHERE PHA.po_header_id IN
                   ( SELECT PHA1.po_header_id
                       FROM po_headers_all PHA1
                      WHERE PHA1.segment1 IN
                            ( SELECT ICV.cc_num
                                FROM igc_arc_pur_candidates ICV
                               WHERE ICV.cc_header_id = l_cc_header_id
                            )
                   );

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from PO_HEADERS_ALL for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all PF Line History records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_det_pf_history CDPH
             WHERE CDPH.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id = l_cc_header_id
                   )
                OR CDPH.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id = l_cc_header_id
                   );

            IF (g_debug_mode = 'Y') THEN
                g_debug_msg := 'Number Rows Deleted from IGC_CC_DET_PF_HISTORY for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all PF Line records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_det_pf CDP
             WHERE CDP.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id = l_cc_header_id
                   )
                OR CDP.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id = l_cc_header_id
                   );

            l_num_pf_pur := SQL%ROWCOUNT;
            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_DET_PF for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all Acct Line History records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_acct_line_history ALH
             WHERE ALH.cc_header_id = l_cc_header_id;

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_ACCT_LINE_HISTORY for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all Acct Line records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_acct_lines AL
             WHERE AL.cc_header_id = l_cc_header_id;

            l_num_acct_pur := SQL%ROWCOUNT;
            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_ACCT_LINES for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all CC Interface records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_interface CI
             WHERE CI.cc_header_id    = l_cc_header_id
               AND CI.set_of_books_id = g_sob_id;

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_INTERFACE for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all Header History records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_header_history CHH
             WHERE CHH.cc_header_id    = l_cc_header_id
               AND CHH.set_of_books_id = g_sob_id;

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_HEADER_HISTORY for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- --------------------------------------------------------------------
-- Delete all Header records for related CC Header IDs.
-- --------------------------------------------------------------------
            DELETE
              FROM igc_cc_headers CH
             WHERE CH.cc_header_id    = l_cc_header_id
               AND CH.set_of_books_id = g_sob_id;

            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := 'Number Rows Deleted from IGC_CC_HEADERS for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || l_sob_id || ' is : ' ||
                           to_char(SQL%ROWCOUNT);
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

-- -------------------------------------------------------------------
-- Make sure that the values are set to 0 if NULL for comparison.
-- -------------------------------------------------------------------
            l_num_acct_pur := NVL (l_num_acct_pur, 0);
            l_num_pf_pur   := NVL (l_num_pf_pur, 0);

-- -------------------------------------------------------------------
-- Check to make sure that the # of records purged match the number
-- of records that were previously archived.
-- -------------------------------------------------------------------
            IF ((l_num_acct_arc <> l_num_acct_pur) OR
                (l_num_pf_arc <> l_num_pf_pur)) THEN

               IF (g_debug_mode = 'Y') THEN
                  g_debug_msg := ' Number Acct Lines Archived : ' || l_num_acct_arc ||
                              ' Number Acct Lines Purged : ' || l_num_acct_pur ||
                              ' Number PF Lines Archived : ' || l_num_pf_arc ||
                              ' Number PF Lines Purged : ' || l_num_pf_pur ||
                              ' Does not match for CC Header ID : ' ||
                              l_cc_header_id || ' SOB ID : ' || g_sob_id ||
                              '.  Thus no Purge can be done for Header ID.';
                  Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
               END IF;

               IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                           p_tokval  => g_sob_id);
               IGC_MSGS_PKG.message_token (p_tokname => 'VALUE1',
                                           p_tokval  => l_cc_header_id);
               IGC_MSGS_PKG.message_token (p_tokname => 'VALUE2',
                                           p_tokval  => FND_DATE.DATE_TO_CHARDATE (g_last_activity_date));
               IGC_MSGS_PKG.message_token (p_tokname => 'COMPONENT',
                                           p_tokval  => 'CC');
               IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                         p_msgname => 'IGC_NUM_PUR_NO_MATCH_ARC');
               raise FND_API.G_EXC_ERROR;

            END IF;

-- -------------------------------------------------------------------
-- Make sure that the History Record is updated to indicate that the
-- header ID has been purged from the system.
-- -------------------------------------------------------------------
            Initialize_History_Record (p_cc_header_id   => l_cc_header_id,
                                       p_History_Rec    => l_history_rec,
                                       x_Return_Status  => l_return_status
                                      );
            IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
               raise FND_API.G_EXC_ERROR;
            END IF;

-- -------------------------------------------------------------------
-- Update the record initialized so that it now indicates that the CC
-- Header ID has been purged.
-- -------------------------------------------------------------------
            l_history_rec.purge_date      := SYSDATE;
            l_history_rec.purged_by       := g_update_by;
            l_history_rec.purge_done_flag := 'Y';

-- -------------------------------------------------------------------
-- Update the History table indicating that this record has been
-- purged from the system.
-- -------------------------------------------------------------------
            Update_History (p_History_Rec    => l_history_rec,
                            x_Return_Status  => l_return_status
                           );

            IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
               raise FND_API.G_EXC_ERROR;
            END IF;

         ELSE

            IF (g_debug_mode = 'Y') THEN
                g_debug_msg := 'Header ID Not found in Archive History Table for CC Header ID : ' ||
                           l_cc_header_id || ' SOB ID : ' || g_sob_id ||
                           '.  Thus no Purge can be done for Header ID.';
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;

            IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                        p_tokval  => g_sob_id);
            IGC_MSGS_PKG.message_token (p_tokname => 'VALUE1',
                                        p_tokval  => l_cc_header_id);
            IGC_MSGS_PKG.message_token (p_tokname => 'VALUE2',
                                        p_tokval  => FND_DATE.DATE_TO_CHARDATE (g_last_activity_date));
            IGC_MSGS_PKG.message_token (p_tokname => 'COMPONENT',
                                        p_tokval  => 'CC');
            IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                      p_msgname => 'IGC_NUM_PUR_NO_MATCH_ARC');
            raise FND_API.G_EXC_ERROR;

         END IF;

-- -------------------------------------------------------------------
-- Close the cursor opened.
-- -------------------------------------------------------------------
         IF (c_get_arc_hist_info%ISOPEN) THEN
            CLOSE c_get_arc_hist_info;
         END IF;

         FETCH c_get_purge_candidate
          INTO l_cc_header_id;

      END LOOP;

   ELSE

      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := 'View returned CC Header ID : ' ||
                     l_cc_header_id || ' But could not find it in Cursor.';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

      IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                  p_tokval  => g_sob_id);
      IGC_MSGS_PKG.message_token (p_tokname => 'VALUE1',
                                  p_tokval  => l_cc_header_id);
      IGC_MSGS_PKG.message_token (p_tokname => 'VALUE2',
                                  p_tokval  => FND_DATE.DATE_TO_CHARDATE (g_last_activity_date));
      IGC_MSGS_PKG.message_token (p_tokname => 'COMPONENT',
                                  p_tokval  => 'CC');
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_NUM_PUR_NO_MATCH_ARC');
      raise FND_API.G_EXC_ERROR;

   END IF;

-- -------------------------------------------------------------------
-- Close the cursors opened.
-- -------------------------------------------------------------------
   IF (c_get_purge_candidate%ISOPEN) THEN
      CLOSE c_get_purge_candidate;
   END IF;
   IF (c_get_arc_hist_info%ISOPEN) THEN
      CLOSE c_get_arc_hist_info;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Purge_CC procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (c_get_purge_candidate%ISOPEN) THEN
          CLOSE c_get_purge_candidate;
       END IF;
       IF (c_get_arc_hist_info%ISOPEN) THEN
          CLOSE c_get_arc_hist_info;
       END IF;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_get_purge_candidate%ISOPEN) THEN
          CLOSE c_get_purge_candidate;
       END IF;
       IF (c_get_arc_hist_info%ISOPEN) THEN
          CLOSE c_get_arc_hist_info;
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Purge_NON_MRC_Tbls;

--
-- Update_History Procedure is designed for Updating or Inserting the CC ARCHIVE History
-- record into the appropriate History table.
--
-- Parameters :
--
-- p_History_Rec         ==> Record to be inserted into the IGC_CC_ARCHIVE_HISTORY table
-- x_Return_Status       ==> Status of procedure returned to caller
--
PROCEDURE Update_History
(
   p_History_Rec          IN igc_cc_archive_history%ROWTYPE,  -- History Record
   x_Return_Status       OUT NOCOPY VARCHAR2                         -- Status of procedure
) IS

-- --------------------------------------------------------------------
-- Declare cursors to be used in this procedure.
-- --------------------------------------------------------------------
   CURSOR c_archive_history IS
      SELECT CAH.cc_header_id
        FROM igc_cc_archive_history CAH
       WHERE CAH.cc_header_id      = p_History_Rec.cc_header_id
         AND CAH.cc_num            = p_History_Rec.cc_num
         AND CAH.cc_type           = p_History_Rec.cc_type;
       /*  AND CAH.org_id            = p_History_Rec.org_id
         AND CAH.set_of_books_id   = p_History_Rec.set_of_books_id; --Commented for MOAC uptake */

-- --------------------------------------------------------------------
-- Declare local variables to be used in this procedure.
-- --------------------------------------------------------------------
   l_header_id     igc_cc_archive_history.cc_header_id%TYPE;
   l_api_name      CONSTANT VARCHAR2(30) := 'Update_History';

   l_full_path         VARCHAR2(255);
BEGIN

   l_full_path := g_path || 'Update_History';

-- --------------------------------------------------------------------
-- Initialize Return status and other local variables.
-- --------------------------------------------------------------------
   x_Return_Status := FND_API.G_RET_STS_SUCCESS;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' Calling Update History for CC Header ID : ' ||
                     p_History_Rec.cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Determine if there is already a record present in the table
-- IGC_CC_ARCHIVE_HISTORY.  If there is already a record present then
-- update the record otherwise insert a new record.
-- --------------------------------------------------------------------
   OPEN c_archive_history;

   FETCH c_archive_history
    INTO l_header_id;

-- --------------------------------------------------------------------
-- If the record is not found then insert new record into the table.
-- --------------------------------------------------------------------
   IF (c_archive_history%NOTFOUND) THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' Inserting Archive History Record for CC Header ID : ' ||
                        p_History_Rec.cc_header_id ||
                        ' Set Of Books ID : ' || p_History_Rec.set_of_books_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

      INSERT
        INTO IGC_CC_ARCHIVE_HISTORY_ALL
           ( cc_header_id,
             set_of_books_id,
             org_id,
             parent_header_id,
             cc_num,
             cc_type,
             archive_date,
             archived_by,
             archive_done_flag,
             purge_date,
             purged_by,
             purge_done_flag,
             num_acct_lines_arc,
             num_det_pf_lines_arc,
             num_mc_acct_lines_arc,
             num_mc_det_pf_lines_arc,
             last_cc_activity_date,
             user_req_last_activity_date,
             last_update_date,
             last_updated_by,
             last_update_login,
             created_by,
             creation_date
           )
         VALUES
           ( p_History_Rec.cc_header_id,
             p_History_Rec.set_of_books_id,
             p_History_Rec.org_id,
             NVL (p_History_Rec.parent_header_id, 0),
             p_History_Rec.cc_num,
             p_History_Rec.cc_type,
             p_History_Rec.archive_date,
             p_History_Rec.archived_by,
             p_History_Rec.archive_done_flag,
             p_History_Rec.purge_date,
             p_History_Rec.purged_by,
             p_History_Rec.purge_done_flag,
             NVL (p_History_Rec.num_acct_lines_arc, 0),
             NVL (p_History_Rec.num_det_pf_lines_arc, 0),
             NVL (p_History_Rec.num_mc_acct_lines_arc, 0),
             NVL (p_History_Rec.num_mc_det_pf_lines_arc, 0),
             p_History_Rec.last_cc_activity_date,
             p_History_Rec.user_req_last_activity_date,
             p_History_Rec.last_update_date,
             p_History_Rec.last_updated_by,
             p_History_Rec.last_update_login,
             p_History_Rec.created_by,
             p_History_Rec.creation_date
           );

      IF (SQL%ROWCOUNT <> 1) THEN
         IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                     p_tokval  => p_History_Rec.set_of_books_id);
         IGC_MSGS_PKG.message_token (p_tokname => 'VALUE',
                                     p_tokval  => p_History_Rec.cc_num);
         IGC_MSGS_PKG.message_token (p_tokname => 'COMPONENT',
                                     p_tokval  => 'CC');
         IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                   p_msgname => 'IGC_INSERT_ARC_PUR_HISTORY');
         raise FND_API.G_EXC_ERROR;
      END IF;

   ELSE -- Update existing record

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' Updating Archive History Record for CC Header ID : ' ||
                        p_History_Rec.cc_header_id ||
                        ' Set Of Books ID : ' || p_History_Rec.set_of_books_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

-- --------------------------------------------------------------------
-- Update the existing fields in the history table for non MRC record.
-- --------------------------------------------------------------------
      UPDATE IGC_CC_ARCHIVE_HISTORY AH
         SET last_update_date        = p_History_Rec.last_update_date,
             last_updated_by         = p_History_Rec.last_updated_by,
             purge_done_flag         = p_History_Rec.purge_done_flag,
             purge_date              = p_History_Rec.purge_date,
             purged_by               = p_History_Rec.purged_by,
             archive_done_flag       = p_History_Rec.archive_done_flag,
             archive_date            = p_History_Rec.archive_date,
             archived_by             = p_History_Rec.archived_by,
             num_acct_lines_arc      = NVL (p_History_Rec.num_acct_lines_arc, 0),
             num_det_pf_lines_arc    = NVL (p_History_Rec.num_det_pf_lines_arc, 0),
             num_mc_acct_lines_arc   = NVL (p_History_Rec.num_mc_acct_lines_arc, 0),
             num_mc_det_pf_lines_arc = NVL (p_History_Rec.num_mc_det_pf_lines_arc, 0)
       WHERE cc_header_id             = p_History_Rec.cc_header_id
        /* AND org_id                   = p_History_Rec.org_id
         AND set_of_books_id          = p_History_Rec.set_of_books_id
	--Commented for MOAC uptake */
         AND NVL(parent_header_id, 0) = NVL(p_History_Rec.parent_header_id, 0)
         AND cc_num                   = p_History_Rec.cc_num
         AND cc_type                  = p_History_Rec.cc_type;

      IF (SQL%ROWCOUNT <> 1) THEN
         IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                     p_tokval  => p_History_Rec.set_of_books_id);
         IGC_MSGS_PKG.message_token (p_tokname => 'VALUE',
                                     p_tokval  => p_History_Rec.cc_num);
         IGC_MSGS_PKG.message_token (p_tokname => 'COMPONENT',
                                     p_tokval  => 'CC');
         IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                   p_msgname => 'IGC_UPDATE_ARC_PUR_HISTORY');
         raise FND_API.G_EXC_ERROR;
      END IF;

   END IF;

-- --------------------------------------------------------------------
-- Close all cursors used by this function here.
-- --------------------------------------------------------------------
   IF (c_archive_history%ISOPEN) THEN
      CLOSE c_archive_history;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Update_History procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (c_archive_history%ISOPEN) THEN
          CLOSE c_archive_history;
       END IF;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
       END IF;
       RETURN;

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (c_archive_history%ISOPEN) THEN
          CLOSE c_archive_history;
       END IF;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_archive_history%ISOPEN) THEN
          CLOSE c_archive_history;
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Update_History;

--
-- Validate_Inputs Procedure is designed to ensure that the inputs that were given by
-- the user are valid and will enable this Archive / Purge procedure to work properly.
--
-- Parameters :
--
-- x_return_status       ==>  Status returned from Procedure.
--
PROCEDURE Validate_Inputs (
   x_return_status     OUT NOCOPY VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Define local variables to be used
-- --------------------------------------------------------------------
   l_cc_header_id        igc_cc_headers.cc_header_id%TYPE;
   l_api_name            CONSTANT VARCHAR2(30) := 'Validate_Inputs';

-- --------------------------------------------------------------------
-- Define cursors to be used in main archive/purge procedure
-- --------------------------------------------------------------------
   CURSOR c_validate_sob_org IS
      SELECT ICCH.cc_header_id
        FROM igc_cc_headers ICCH
       WHERE ICCH.set_of_books_id = g_sob_id
         AND ICCH.org_id          = g_org_id;

   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Validate_Inputs';

-- --------------------------------------------------------------------
-- Initialize local variables.
-- --------------------------------------------------------------------
   x_Return_Status := FND_API.G_RET_STS_SUCCESS;

-- --------------------------------------------------------------------
-- Make sure that the input mode of the process is a valid input.  The
-- set of values allowed are 'A' Archive or 'P' Purge.
-- --------------------------------------------------------------------
   IF (g_mode NOT IN ('AR', 'PP', 'PU')) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' Invalid Archive / Purge mode passed in : ' || g_mode ||
                        ' Exiting process.';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                  p_tokval  => g_sob_id);
      IGC_MSGS_PKG.message_token (p_tokname => 'VALUE',
                                  p_tokval  => FND_DATE.DATE_TO_CHARDATE (g_last_activity_date));
      IGC_MSGS_PKG.message_token (p_tokname => 'MODE',
                                  p_tokval  => g_mode);
      IGC_MSGS_PKG.message_token (p_tokname => 'COMPONENT',
                                  p_tokval  => 'CC');
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_INVALID_ARC_PUR_MODE');
      raise FND_API.G_EXC_ERROR;
   END IF;

-- --------------------------------------------------------------------
-- Make sure that the set of books ID is valid and that there are
-- records present for the SOB and the ORG ID given.
-- --------------------------------------------------------------------
   IF g_sob_id is NULL THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' Set of books ID is NULL.  Exiting.';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

      IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                  p_tokval  => 'NULL');
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_INVALID_SOB_ARCHIVE');
      g_validation_error := TRUE;

   ELSE

-- -------------------------------------------------------------------
-- Make sure that there are records in the IGC_CC_HEADERS table that
-- can be reviewed for the SOB ID and the ORG ID.
-- -------------------------------------------------------------------
       OPEN c_validate_sob_org;
      FETCH c_validate_sob_org
       INTO l_cc_header_id;

      IF (c_validate_sob_org%NOTFOUND) THEN

--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := ' Set of books ID : ' || g_sob_id ||
                           ' and ORG ID : ' || g_org_id ||
                           ' Combination not found in IGC_CC_HEADERS.  Exiting.';
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;

         IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                     p_tokval  => g_sob_id);
         IGC_MSGS_PKG.message_token (p_tokname => 'ORG_ID',
                                     p_tokval  => g_org_id);
         IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                   p_msgname => 'IGC_NO_SOB_ORG_COMBO');
         g_validation_error := TRUE;
      END IF;

-- --------------------------------------------------------------------
-- Make sure that the cursor opened for validation has been closed.
-- --------------------------------------------------------------------
      CLOSE c_validate_sob_org;

   END IF;

-- --------------------------------------------------------------------
-- Make sure that the last activity date that has been given is not a
-- date in the future.  This is not a valid date for archiving or
-- purging.
-- --------------------------------------------------------------------
   IF (sign(sysdate - nvl(g_last_activity_date, sysdate)) < 0) THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' Last Activity date is not valid.  Future Date : ' ||
                        g_last_activity_date;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

      IGC_MSGS_PKG.message_token (p_tokname => 'SOB_ID',
                                  p_tokval  => g_sob_id);
      IGC_MSGS_PKG.message_token (p_tokname => 'INPUT_DATE',
                                  p_tokval  => FND_DATE.DATE_TO_CHARDATE (g_last_activity_date));
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_INVALID_DATE_INPUT');
      g_validation_error := TRUE;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Validate_Inputs procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (c_validate_sob_org%ISOPEN) THEN
          CLOSE c_validate_sob_org;
       END IF;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
       END IF;
       RETURN;

   WHEN FND_API.G_EXC_ERROR THEN
       x_Return_Status := FND_API.G_RET_STS_ERROR;
       IF (c_validate_sob_org%ISOPEN) THEN
          CLOSE c_validate_sob_org;
       END IF;
       IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       RETURN;

   WHEN OTHERS THEN
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_validate_sob_org%ISOPEN) THEN
          CLOSE c_validate_sob_org;
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       RETURN;

END Validate_Inputs;

END IGC_CC_ARCHIVE_PURGE_PKG;


/
