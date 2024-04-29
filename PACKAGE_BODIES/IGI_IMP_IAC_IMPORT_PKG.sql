--------------------------------------------------------
--  DDL for Package Body IGI_IMP_IAC_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IMP_IAC_IMPORT_PKG" AS
-- $Header: igiimipb.pls 120.11.12000000.1 2007/08/01 16:21:21 npandya ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiimipb.igi_imp_iac_import_pkg.';

--===========================FND_LOG.END=====================================
   --
   -- Check current module name
   --
   FUNCTION Is_IGI_Program (p_program_name VARCHAR2) RETURN BOOLEAN
   IS
      -- Check program name
      CURSOR c_check_program IS
         SELECT COUNT(*)
         FROM   fnd_concurrent_programs
         WHERE  concurrent_program_name = p_program_name
         AND    concurrent_program_id = FND_GLOBAL.Conc_Program_Id
         AND    application_id = FND_GLOBAL.Prog_Appl_Id;

      l_count   NUMBER;
      l_message VARCHAR2(1000);

   BEGIN
      OPEN c_check_program;
      FETCH c_check_program INTO l_count;
      CLOSE c_check_program;

      IF l_count = 1 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;

   END Is_IGI_Program;

   --
   -- Spawn an instance of the SQL*Loader program to load a file
   --
   PROCEDURE Spawn_Loader ( p_file_name IN  VARCHAR2 ) IS

      l_message          VARCHAR2(1000);
      l_file_name        VARCHAR2(1000);
      l_request_id       NUMBER;
      l_phase            VARCHAR2(100);
      l_status           VARCHAR2(100);
      l_dev_phase        VARCHAR2(100);
      l_dev_status       VARCHAR2(100);

      e_request_submit_error   EXCEPTION;
      e_request_wait_error     EXCEPTION;
      e_loader_failure         EXCEPTION;
      l_path_name VARCHAR2(150) := g_path||'spawn_loader';

   BEGIN
      l_file_name := p_file_name;

      l_request_id := FND_REQUEST.SUBMIT_REQUEST
            (APPLICATION  => 'IGI',
             PROGRAM      => 'IGIIMPID',
             DESCRIPTION  => 'Inflation Accounting: Load Data from Data File',
             START_TIME   => NULL,
             SUB_REQUEST  => FALSE,
             ARGUMENT1    => l_file_name,
             ARGUMENT2    => CHR(0),
             ARGUMENT3    => NULL, ARGUMENT4    => NULL, ARGUMENT5    => NULL,
             ARGUMENT6    => NULL, ARGUMENT7    => NULL, ARGUMENT8    => NULL,
             ARGUMENT9    => NULL, ARGUMENT10   => NULL, ARGUMENT11   => NULL,
             ARGUMENT12   => NULL, ARGUMENT13   => NULL, ARGUMENT14   => NULL,
             ARGUMENT15   => NULL, ARGUMENT16   => NULL, ARGUMENT17   => NULL,
             ARGUMENT18   => NULL, ARGUMENT19   => NULL, ARGUMENT20   => NULL,
             ARGUMENT21   => NULL, ARGUMENT22   => NULL, ARGUMENT23   => NULL,
             ARGUMENT24   => NULL, ARGUMENT25   => NULL, ARGUMENT26   => NULL,
             ARGUMENT27   => NULL, ARGUMENT28   => NULL, ARGUMENT29   => NULL,
             ARGUMENT30   => NULL, ARGUMENT31   => NULL, ARGUMENT32   => NULL,
             ARGUMENT33   => NULL, ARGUMENT34   => NULL, ARGUMENT35   => NULL,
             ARGUMENT36   => NULL, ARGUMENT37   => NULL, ARGUMENT38   => NULL,
             ARGUMENT39   => NULL, ARGUMENT40   => NULL, ARGUMENT41   => NULL,
             ARGUMENT42   => NULL, ARGUMENT43   => NULL, ARGUMENT44   => NULL,
             ARGUMENT45   => NULL, ARGUMENT46   => NULL, ARGUMENT47   => NULL,
             ARGUMENT48   => NULL, ARGUMENT49   => NULL, ARGUMENT50   => NULL,
             ARGUMENT51   => NULL, ARGUMENT52   => NULL, ARGUMENT53   => NULL,
             ARGUMENT54   => NULL, ARGUMENT55   => NULL, ARGUMENT56   => NULL,
             ARGUMENT57   => NULL, ARGUMENT58   => NULL, ARGUMENT59   => NULL,
             ARGUMENT60   => NULL, ARGUMENT61   => NULL, ARGUMENT62   => NULL,
             ARGUMENT63   => NULL, ARGUMENT64   => NULL, ARGUMENT65   => NULL,
             ARGUMENT66   => NULL, ARGUMENT67   => NULL, ARGUMENT68   => NULL,
             ARGUMENT69   => NULL, ARGUMENT70   => NULL, ARGUMENT71   => NULL,
             ARGUMENT72   => NULL, ARGUMENT73   => NULL, ARGUMENT74   => NULL,
             ARGUMENT75   => NULL, ARGUMENT76   => NULL, ARGUMENT77   => NULL,
             ARGUMENT78   => NULL, ARGUMENT79   => NULL, ARGUMENT80   => NULL,
             ARGUMENT81   => NULL, ARGUMENT82   => NULL, ARGUMENT83   => NULL,
             ARGUMENT84   => NULL, ARGUMENT85   => NULL, ARGUMENT86   => NULL,
             ARGUMENT87   => NULL, ARGUMENT88   => NULL, ARGUMENT89   => NULL,
             ARGUMENT90   => NULL, ARGUMENT91   => NULL, ARGUMENT92   => NULL,
             ARGUMENT93   => NULL, ARGUMENT94   => NULL, ARGUMENT95   => NULL,
             ARGUMENT96   => NULL, ARGUMENT97   => NULL, ARGUMENT98   => NULL,
             ARGUMENT99   => NULL, ARGUMENT100  => NULL);

      IF l_request_id = 0 THEN
         RAISE e_request_submit_error;
      ELSE
         COMMIT;
      END IF;

      -- Wait for request completion
      IF NOT FND_CONCURRENT.Wait_For_Request (l_request_id,
                                              10, -- interval seconds
                                              0,  -- max wait seconds
                                              l_phase,
                                              l_status,
                                              l_dev_phase,
                                              l_dev_status,
                                              l_message) THEN
         RAISE e_request_wait_error;
      END IF;

      -- Check request completion status
      IF l_dev_phase <> 'COMPLETE' OR
         l_dev_status <> 'NORMAL' THEN
         RAISE e_loader_failure;
      END IF;

      -- Update concurrent process details to loaded records
      UPDATE igi_imp_iac_intermediate
      SET    request_id             = l_request_id
            ,program_id             = FND_GLOBAL.Conc_Program_Id
            ,program_application_id = FND_GLOBAL.Prog_Appl_Id
            ,program_update_date    = SYSDATE
      WHERE  errored_flag IS NULL;

      COMMIT;

   EXCEPTION

      WHEN e_request_submit_error THEN
         FND_MESSAGE.Retrieve(l_message);
  	 igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_remove_from_stack => FALSE);
         --FND_FILE.Put_Line(FND_FILE.Log,l_message);
         RAISE;

      WHEN e_request_wait_error THEN
         FND_MESSAGE.Retrieve(l_message);
  	 igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_remove_from_stack => FALSE);
         --FND_FILE.Put_Line(FND_FILE.Log,l_message);
         RAISE;

      WHEN e_loader_failure THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_NOT_NORM_COMPLETE');
         FND_MESSAGE.Set_Token('FILE_NAME',l_file_name);
  	 igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_remove_from_stack => FALSE);
         l_message := FND_MESSAGE.Get;
         --FND_FILE.Put_Line(FND_FILE.Log,l_message);
         RAISE;

      WHEN OTHERS THEN
         FND_MESSAGE.Retrieve(l_message);
  	 igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_remove_from_stack => FALSE);
         --FND_FILE.Put_Line(FND_FILE.Log,l_message);
         RAISE;

   END Spawn_Loader;

   --
   -- Validate and Update intermediate records to interface
   --
   PROCEDURE Validate_Update_IMP_Data ( p_file_name      IN  VARCHAR2
                                      , p_book_type_code IN  VARCHAR2
                                      , p_category_id    IN  NUMBER
                                      ) IS

       -- Count records to process
      CURSOR c_count_recs IS
         SELECT COUNT(*)
         FROM   igi_imp_iac_intermediate
         WHERE  errored_flag IS NULL;

      -- Get records to process
      CURSOR c_recs_to_process IS
         SELECT asset_id
               ,asset_number
               ,book_type_code
               ,category_id
               ,cost_mhca
               ,ytd_mhca
               ,accum_deprn_mhca
               ,reval_reserve_mhca
               ,backlog_mhca
               ,general_fund_mhca
               ,operating_account_cost
               ,operating_account_backlog
               ,request_id
               ,program_application_id
               ,program_id
               ,program_update_date
         FROM   igi_imp_iac_intermediate
         WHERE  errored_flag IS NULL;

      -- Validate the asset
      CURSOR c_validate_asset (cp_asset_id       igi_imp_iac_interface.asset_id%TYPE,
                               cp_asset_number   igi_imp_iac_interface.asset_number%TYPE,
                               cp_book_type_code igi_imp_iac_interface.book_type_code%TYPE,
                               cp_category_id    igi_imp_iac_interface.category_id%TYPE) IS
         SELECT COUNT(*)
         FROM   igi_imp_iac_interface
         WHERE  asset_id       = cp_asset_id
         AND    asset_number   = cp_asset_number
         AND    book_type_code = cp_book_type_code
         AND    category_id    = cp_category_id;

--
-- Bug 2499880 Start(1)
--
      -- Check transfer to IAC
      CURSOR c_chk_transfer_to_iac
                           (cp_book_type_code igi_imp_iac_interface.book_type_code%TYPE,
                            cp_category_id    igi_imp_iac_interface.category_id%TYPE) IS
         SELECT transfer_status
         FROM   igi_imp_iac_interface_ctrl
         WHERE  book_type_code = cp_book_type_code
         AND    category_id    = cp_category_id;

         Cursor C_book_class( cp_book_type_code igi_imp_iac_interface.book_type_code%TYPE) is
         Select book_class
         from fa_booK_controls
         where book_type_code = cp_book_type_code;

         cursor c_deprn_flag(cp_book_type_code igi_imp_iac_interface.book_type_code%TYPE,
                            cp_asset_id    igi_imp_iac_interface.asset_id%TYPE ) is
           select depreciate_flag
           from fa_books
            where book_type_code =cp_book_type_code
             and  asset_id =cp_asset_id
             and transaction_header_id_out is null;

-- Bug 2499880 End(1)
--

      l_book_type_code  igi_imp_iac_interface.book_type_code%TYPE;
      l_category_id     igi_imp_iac_interface.category_id%TYPE;

--
-- Bug 2499880 Start(2)
--
      l_transfer_status igi_imp_iac_interface_ctrl.transfer_status%TYPE;
--
-- Bug 2499880 End(2)
--
        l_deprn_flag  fa_books.depreciate_flag%type;
        l_book_class  fa_booK_controls.book_class%type;

      l_count        NUMBER;
      l_message      VARCHAR2(1000);
      l_file_name    VARCHAR2(1000);
      l_igiimpip     BOOLEAN;
      l_valid        BOOLEAN;
      l_any_err_recs BOOLEAN := FALSE;
      l_path_name VARCHAR2(150) := g_path||'validate_update_imp_data';

    BEGIN

      l_file_name      := p_file_name;
      l_book_type_code := p_book_type_code;
      l_category_id    := p_category_id;
      l_igiimpip       := is_igi_program('IGIIMPIP');

      -- Log count of records to process
      OPEN c_count_recs;
      FETCH c_count_recs INTO l_count;
      CLOSE c_count_recs;
      FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_RECORDS_TO_PROCESS');
      FND_MESSAGE.Set_Token('RECORD_COUNT',l_count);
      FND_MESSAGE.Set_Token('FILE_NAME',l_file_name);
      igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_remove_from_stack => FALSE);
      l_message := FND_MESSAGE.Get;
      --FND_FILE.Put_Line(FND_FILE.Log,l_message);

      -- Process records
      FOR cv_recs_to_process IN c_recs_to_process LOOP
         l_valid := TRUE;

         -- If IGIIMPIP, validate the record's book type code
         IF l_igiimpip THEN
            IF l_book_type_code <> cv_recs_to_process.book_type_code THEN
               FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_WRONG_BOOK');
               FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',cv_recs_to_process.book_type_code);
               FND_MESSAGE.Set_Token('ASSET_ID',cv_recs_to_process.asset_id);
               FND_MESSAGE.Set_Token('ASSET_NUMBER',cv_recs_to_process.asset_number);
      	       FND_MESSAGE.Set_Token('P_BOOK_TYPE_CODE',l_book_type_code);
      	       igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_remove_from_stack => FALSE);
               l_message := FND_MESSAGE.Get;
               --FND_FILE.Put_Line(FND_FILE.Log,l_message);

               l_valid := FALSE;
            END IF;
         END IF;

         -- If IGIIMPIP, validate the record's category id
         IF l_valid AND l_igiimpip THEN
            IF l_category_id <> cv_recs_to_process.category_id THEN
               FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_WRONG_CATEGORY_ID');
               FND_MESSAGE.Set_Token('CATEGORY_ID',cv_recs_to_process.category_id);
               FND_MESSAGE.Set_Token('ASSET_ID',cv_recs_to_process.asset_id);
               FND_MESSAGE.Set_Token('ASSET_NUMBER',cv_recs_to_process.asset_number);
               FND_MESSAGE.Set_Token('P_CATEGORY_ID',l_category_id);
      	       igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_remove_from_stack => FALSE);
               l_message := FND_MESSAGE.Get;
               --FND_FILE.Put_Line(FND_FILE.Log,l_message);

               l_valid := FALSE;
            END IF;
         END IF;

         IF l_valid THEN
            -- Validate the asset
            OPEN c_validate_asset(cv_recs_to_process.asset_id,
                                  cv_recs_to_process.asset_number,
                                  cv_recs_to_process.book_type_code,
                                  cv_recs_to_process.category_id);
            FETCH c_validate_asset INTO l_count;
            CLOSE c_validate_asset;

            IF l_count <> 1 THEN
               -- Log the invalid asset
               FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_INTFACE_ASSET_ERR');
               FND_MESSAGE.Set_Token('ASSET_ID',cv_recs_to_process.asset_id);
               FND_MESSAGE.Set_Token('ASSET_NUMBER',cv_recs_to_process.asset_number);
      	       igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_remove_from_stack => FALSE);
               l_message := FND_MESSAGE.Get;
               --FND_FILE.Put_Line(FND_FILE.Log,l_message);

               l_valid := FALSE;
            END IF; -- asset count
         END IF; -- valid record

--
-- Bug 2499880 Start(3)
--
         IF l_valid THEN
            -- Check transfer to IAC
            OPEN c_chk_transfer_to_iac(cv_recs_to_process.book_type_code,
                                       cv_recs_to_process.category_id);
            FETCH c_chk_transfer_to_iac INTO l_transfer_status;
            CLOSE c_chk_transfer_to_iac;

            IF l_transfer_status = 'C' THEN
               -- Log the transfer already completed message.
               FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_TRNSFRD_TO_IAC');
               FND_MESSAGE.Set_Token('ASSET_ID',cv_recs_to_process.asset_id);
               FND_MESSAGE.Set_Token('ASSET_NUMBER',cv_recs_to_process.asset_number);
               FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',cv_recs_to_process.book_type_code);
               FND_MESSAGE.Set_Token('CATEGORY_ID',cv_recs_to_process.category_id);
      	       igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_remove_from_stack => FALSE);
               l_message := FND_MESSAGE.Get;
               --FND_FILE.Put_Line(FND_FILE.Log,l_message);

               l_valid := FALSE;
            END IF; -- transfer status
         END IF; -- valid record
--
-- Bug 2499880 End(3)
--

         IF l_valid THEN

                l_deprn_flag := 'YES';
                --open c_booK_class(cv_recs_to_process.book_type_code);
                --Fetch c_booK_class into l_booK_class;
                --IF l_book_class = 'CORPORATE' THEN
                    open c_deprn_flag(cv_recs_to_process.book_type_code,cv_recs_to_process.asset_id);
        			fetch c_deprn_flag into l_deprn_flag;
		            close c_deprn_flag;
               -- END IF;
               -- Close c_book_class;

            IF l_deprn_flag = 'YES' THEN
            -- Update the asset data to interface
            UPDATE igi_imp_iac_interface
            SET    cost_mhca = cv_recs_to_process.cost_mhca
                  ,ytd_mhca = cv_recs_to_process.ytd_mhca
                  ,accum_deprn_mhca = cv_recs_to_process.accum_deprn_mhca
                  ,reval_reserve_mhca = cv_recs_to_process.reval_reserve_mhca
                  ,backlog_mhca = cv_recs_to_process.backlog_mhca
                  ,general_fund_mhca = cv_recs_to_process.general_fund_mhca
                  ,operating_account_cost = (-1) * cv_recs_to_process.operating_account_cost
                  ,operating_account_backlog = (-1) * cv_recs_to_process.operating_account_backlog
                  ,import_file = l_file_name
                  ,import_date = SYSDATE
                  ,request_id = cv_recs_to_process.request_id
                  ,program_id = cv_recs_to_process.program_id
                  ,program_application_id = cv_recs_to_process.program_application_id
                  ,program_update_date = cv_recs_to_process.program_update_date
		  ,valid_flag = 'N'
            WHERE  asset_id = cv_recs_to_process.asset_id
            AND    asset_number = cv_recs_to_process.asset_number
            AND    book_type_code = cv_recs_to_process.book_type_code
            AND    category_id = cv_recs_to_process.category_id;
 	ELSE

            UPDATE igi_imp_iac_interface
            SET    cost_mhca = cv_recs_to_process.cost_mhca
                  ,reval_reserve_mhca = cv_recs_to_process.reval_reserve_mhca
                  ,operating_account_cost = (-1) * cv_recs_to_process.operating_account_cost
                  ,import_file = l_file_name
                  ,import_date = SYSDATE
                  ,request_id = cv_recs_to_process.request_id
                  ,program_id = cv_recs_to_process.program_id
                  ,program_application_id = cv_recs_to_process.program_application_id
                  ,program_update_date = cv_recs_to_process.program_update_date
		  ,valid_flag = 'N'
            WHERE  asset_id = cv_recs_to_process.asset_id
            AND    asset_number = cv_recs_to_process.asset_number
            AND    book_type_code = cv_recs_to_process.book_type_code
            AND    category_id = cv_recs_to_process.category_id;



          END IF;
            -- Delete the successful record from intermediate
            DELETE FROM igi_imp_iac_intermediate
            WHERE  asset_id = cv_recs_to_process.asset_id
            AND    asset_number = cv_recs_to_process.asset_number
            AND    book_type_code = cv_recs_to_process.book_type_code
            AND    category_id = cv_recs_to_process.category_id;

         ELSE -- not a valid record

            -- Update the error status to intermediate
            UPDATE igi_imp_iac_intermediate
            SET    errored_flag = 'Y'
            WHERE  asset_id       = cv_recs_to_process.asset_id
            AND    asset_number   = cv_recs_to_process.asset_number
            AND    book_type_code = cv_recs_to_process.book_type_code
            AND    category_id    = cv_recs_to_process.category_id;

            l_any_err_recs := TRUE;
         END IF; -- not valid rec

      END LOOP; -- loop through records to process

      IF l_any_err_recs THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_FAILED_RECS');
         FND_MESSAGE.Set_Token('FILE_NAME',l_file_name);
      	 igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
	     		p_full_path => l_path_name,
	     		p_remove_from_stack => FALSE);
         l_message := FND_MESSAGE.Get;
         --FND_FILE.Put_Line(FND_FILE.Log,l_message);
      END IF;

      FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_FILE_COMPLETE');
      FND_MESSAGE.Set_Token('FILE_NAME',l_file_name);
      igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
	     		p_full_path => l_path_name,
	     		p_remove_from_stack => FALSE);
      l_message := FND_MESSAGE.Get;
      --FND_FILE.Put_Line(FND_FILE.Log,l_message);

   EXCEPTION

      WHEN OTHERS THEN
         FND_MESSAGE.Retrieve(l_message);
         igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
	     		p_full_path => l_path_name,
	     		p_remove_from_stack => FALSE);
         --FND_FILE.Put_Line(FND_FILE.Log,l_message);
         RAISE;

   END Validate_Update_IMP_Data;

   --
   -- Implementation Import Data Process
   --
   PROCEDURE Import_IMP_Data_Process ( errbuf            OUT NOCOPY VARCHAR2
                                     , retcode           OUT NOCOPY NUMBER
                                     , p_book_type_code  IN  VARCHAR2
                                     , p_category_id     IN  NUMBER
                                     , p_category_name   IN  VARCHAR2
                                     ) IS

      -- Cursor to validate book type code
      CURSOR c_book_type_code (cp_book_type_code
                               igi_imp_iac_controls.book_type_code%TYPE) IS
         SELECT request_status
         FROM   igi_imp_iac_controls
         WHERE  book_type_code = cp_book_type_code;

      -- Cursor to validate category id
      CURSOR c_category_id (cp_book_type_code
                               igi_imp_iac_interface_ctrl.book_type_code%TYPE,
                            cp_category_id
                               igi_imp_iac_interface_ctrl.category_id%TYPE) IS
         SELECT COUNT(*)
         FROM   igi_imp_iac_interface_ctrl
         WHERE  book_type_code = cp_book_type_code
         AND    category_id = cp_category_id;

      -- Cursor for count of files to process
      CURSOR c_group_count (cp_book_type_code igi_imp_iac_interface.book_type_code%TYPE,
                            cp_category_id    igi_imp_iac_interface.category_id%TYPE) IS
         SELECT COUNT(DISTINCT group_id)
         FROM   igi_imp_iac_interface
         WHERE  book_type_code = cp_book_type_code
         AND    category_id = cp_category_id
         AND    group_id IS NOT NULL;

      -- Cursor to build file names to import
      CURSOR c_group_id (cp_book_type_code igi_imp_iac_interface.book_type_code%TYPE,
                         cp_category_id    igi_imp_iac_interface.category_id%TYPE) IS
         SELECT DISTINCT group_id
         FROM   igi_imp_iac_interface
         WHERE  book_type_code = cp_book_type_code
         AND    category_id = cp_category_id
         AND    group_id IS NOT NULL;

      l_book_type_code     igi_imp_iac_interface.book_type_code%TYPE;
--      l_new_book_type_code igi_imp_iac_interface.book_type_code%TYPE;		-- Bug No. 2843747 (Tpradhan) - Coommented since no longer in use
      l_category_id        igi_imp_iac_interface.category_id%TYPE;
      l_category_name      VARCHAR2(350);

      l_request_status   igi_imp_iac_controls.request_status%TYPE;
      l_message          VARCHAR2(1000);
      l_file_path        VARCHAR2(1000);
      l_file_name        VARCHAR2(1000);
      l_count            NUMBER := 0;

      e_iac_not_enabled        EXCEPTION;
      e_not_null_params        EXCEPTION;
      e_invalid_book           EXCEPTION;
      e_incomplete_preparation EXCEPTION;
      e_invalid_category_id    EXCEPTION;
      e_no_files               EXCEPTION;
      l_path_name VARCHAR2(150) := g_path||'import_imp_data_process';
   BEGIN
      l_book_type_code := p_book_type_code;
      l_category_id    := p_category_id;
      l_category_name  := p_category_name;

      -- Check if IAC is switched on
      IF NOT igi_gen.is_req_installed('IAC') THEN
         RAISE e_iac_not_enabled;
      END IF;

      -- Check for mandatory values
      IF TRIM(l_book_type_code) IS NULL OR
         l_category_id          IS NULL OR
         TRIM(l_category_name)  IS NULL THEN
         RAISE e_not_null_params;
      END IF;

      -- Validate book type code
      OPEN c_book_type_code(l_book_type_code);
      FETCH c_book_type_code INTO l_request_status;
      IF c_book_type_code%NOTFOUND THEN
         CLOSE c_book_type_code;
         RAISE e_invalid_book;
      END IF;
      CLOSE c_book_type_code;

      -- Check preparation status
      IF UPPER(l_request_status) <> 'C' THEN
         RAISE e_incomplete_preparation;
      END IF;

      -- Validate the category id
      OPEN c_category_id(l_book_type_code,l_category_id);
      FETCH c_category_id INTO l_count;
      CLOSE c_category_id;
      IF l_count = 0 THEN
         RAISE e_invalid_category_id;
      END IF;

      -- Delete old records from the intermediate table
      DELETE FROM igi_imp_iac_intermediate;
      COMMIT;

      -- Strip book type code blank spaces
--      l_new_book_type_code := strip_blank_spaces(l_book_type_code);	-- Commented since check is performed using the function igi_imp_iac_export_pkg.trim_invalid_chars

      -- Check count of files to process
      OPEN c_group_count(l_book_type_code,l_category_id);
      FETCH c_group_count INTO l_count;
      CLOSE c_group_count;
      IF l_count = 0 THEN
         RAISE e_no_files;
      END IF;

      -- Get file location
      FND_PROFILE.Get('IGI_IMP_IAC_FILE_LOCN',l_file_path);

      -- Build file names to be processed
      FOR cv_group_id IN c_group_id(l_book_type_code,l_category_id) LOOP
         l_file_name := l_file_path||igi_imp_iac_export_pkg.trim_invalid_chars(l_book_type_code)|| '_' ||
                        igi_imp_iac_export_pkg.trim_invalid_chars(l_category_name)|| '_' ||
                        TO_CHAR(cv_group_id.group_id)|| '_' ||
                        'in.csv';

         -- Write file name to log file
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_FILE_LOG');
         FND_MESSAGE.Set_Token('FILE_NAME',l_file_name);
         igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
	     		p_full_path => l_path_name,
	     		p_remove_from_stack => FALSE);
         l_message := FND_MESSAGE.Get;
         --FND_FILE.Put_Line(FND_FILE.Log,l_message);

         -- Invoking SQL*Loader to upload the file to the intermediate table.
         spawn_loader( l_file_name
                     );

         -- Invoke the validate and update PL/SQL Program
         Validate_Update_IMP_Data( l_file_name
                                 , l_book_type_code
                                 , l_category_id
                                 );

      END LOOP; -- Group Ids

      COMMIT;

   EXCEPTION
      WHEN e_iac_not_enabled THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IAC_NOT_INSTALLED');
         igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
	     		p_full_path => l_path_name,
	     		p_remove_from_stack => FALSE);
         retcode := 2;
         errbuf := FND_MESSAGE.Get;

      WHEN e_not_null_params THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_MANDATORY_PARAMS');
         FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',l_book_type_code);
         FND_MESSAGE.Set_Token('CATEGORY_ID',l_category_id);
         FND_MESSAGE.Set_Token('CATEGORY_NAME',l_category_name);
         igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
	     		p_full_path => l_path_name,
	     		p_remove_from_stack => FALSE);
         retcode := 2;
         errbuf := FND_MESSAGE.Get;

      WHEN e_invalid_book THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_INVALID_BOOK');
         FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',l_book_type_code);
         igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
	     		p_full_path => l_path_name,
	     		p_remove_from_stack => FALSE);
         retcode := 2;
         errbuf := FND_MESSAGE.Get;

      WHEN e_incomplete_preparation THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_PREP_NOT_COMPLETE');
         FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',l_book_type_code);
         igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
	     		p_full_path => l_path_name,
	     		p_remove_from_stack => FALSE);
         retcode := 2;
         errbuf := FND_MESSAGE.Get;

      WHEN e_invalid_category_id THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_INVALID_CAT_ID');
         FND_MESSAGE.Set_Token('CATEGORY_ID',l_category_id);
         FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',l_book_type_code);
         igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
	     		p_full_path => l_path_name,
	     		p_remove_from_stack => FALSE);
         retcode := 2;
         errbuf := FND_MESSAGE.Get;

      WHEN e_no_files THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_NO_FILES_TO_IMPORT');
         FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',l_book_type_code);
         FND_MESSAGE.Set_Token('CATEGORY_ID',l_category_id);
         igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
	     		p_full_path => l_path_name,
	     		p_remove_from_stack => FALSE);
         retcode := 1;
         errbuf := FND_MESSAGE.Get;

      WHEN OTHERS THEN
         FND_MESSAGE.Retrieve(l_message);
         igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
	     		p_full_path => l_path_name,
	     		p_remove_from_stack => FALSE);
         retcode := 2;
         errbuf := l_message;

   END Import_IMP_Data_Process;

END igi_imp_iac_import_pkg;

/
