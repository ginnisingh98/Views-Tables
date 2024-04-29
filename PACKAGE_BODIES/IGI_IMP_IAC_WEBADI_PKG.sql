--------------------------------------------------------
--  DDL for Package Body IGI_IMP_IAC_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IMP_IAC_WEBADI_PKG" AS
-- $Header: igiimpwb.pls 120.10.12000000.1 2007/08/01 16:21:55 npandya noship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiimpwb.igi_imp_iac_webadi_pkg.';

-- ===================================================================
-- FUNCTION Validate_Book: This function is used to test if the book
-- is valid and the request status for the book
-- ===================================================================
  FUNCTION Validate_Book(n_book_code IN VARCHAR2)
  RETURN VARCHAR2 IS
     l_req_status   igi_imp_iac_controls.request_status%TYPE;
  BEGIN
     SELECT request_status
     INTO l_req_status
     FROM igi_imp_iac_controls
     WHERE book_type_code = n_book_code;

     RETURN(l_req_status);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_req_status := null;
       RETURN(l_req_status);
  END Validate_Book;

-- ===================================================================
-- FUNCTION Validate_Category: This function is used to validate the
-- category
-- ===================================================================
  FUNCTION Validate_Category(n_book_code IN VARCHAR2,
                             n_category_desc IN VARCHAR2)
  RETURN NUMBER IS
    l_count     NUMBER;
  BEGIN

    SELECT COUNT(*)
    INTO l_count
    FROM   igi_imp_iac_interface_ctrl
    WHERE  book_type_code = n_book_code
    AND    category_id = (SELECT category_id
                          FROM fa_categories_b_kfv
                          WHERE concatenated_segments = n_category_desc);

    RETURN(l_count);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_count := 0;
       RETURN(l_count);
  END Validate_Category;

-- ===================================================================
-- FUNCTION Validate_Transfer: This function is used to validate the
-- category
-- ===================================================================
   FUNCTION Validate_Transfer(n_book_code IN VARCHAR2,
                              n_category_desc IN VARCHAR2)
   RETURN VARCHAR2 IS
     l_tfr_stat    igi_imp_iac_interface_ctrl.transfer_status%TYPE;
   BEGIN
     SELECT transfer_status
     INTO l_tfr_stat
     FROM   igi_imp_iac_interface_ctrl
     WHERE  book_type_code = n_book_code
     AND    category_id    = (SELECT category_id
                              FROM fa_categories_b_kfv
                              WHERE concatenated_segments = n_category_desc);

     RETURN(l_tfr_stat);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_tfr_stat := NULL;
       RETURN(l_tfr_stat);
   END Validate_Transfer;

-- ===================================================================
-- FUNCTION Validate_Asset: This function is used to validate the
-- asset
-- ===================================================================
  FUNCTION Validate_Asset(n_book_code IN VARCHAR2,
                          n_category_desc IN VARCHAR2,
                          n_asset_number IN VARCHAR2)
  RETURN NUMBER IS
    l_count     NUMBER;
  BEGIN

     SELECT COUNT(*)
     INTO l_count
     FROM igi_imp_iac_interface
     WHERE asset_id = (SELECT asset_id
                       FROM fa_additions
                       WHERE asset_number = n_asset_number)
     AND   book_type_code = n_book_code
     AND   category_id = (SELECT category_id
                          FROM fa_categories_b_kfv
                          WHERE concatenated_segments = n_category_desc);

     RETURN(l_count);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_count := 0;
      RETURN(l_count);
  END Validate_Asset;

-- ===================================================================
-- FUNCTION Validate_GroupId: This function is used to validate the
-- asset
-- ===================================================================
  FUNCTION Validate_GroupId(n_book_code IN VARCHAR2,
                            n_category_desc IN VARCHAR2,
                            n_asset_number IN VARCHAR2,
                            n_group_id IN NUMBER)
  RETURN NUMBER IS
    l_count     NUMBER;
  BEGIN

     SELECT COUNT(*)
     INTO l_count
     FROM igi_imp_iac_interface
     WHERE asset_id = (SELECT asset_id
                       FROM fa_additions
                       WHERE asset_number = n_asset_number)
     AND   book_type_code = n_book_code
     AND   group_id = n_group_id
     AND   category_id = (SELECT category_id
                          FROM fa_categories_b_kfv
                          WHERE concatenated_segments = n_category_desc);

     RETURN(l_count);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_count := 0;
      RETURN(l_count);
  END Validate_GroupId;

-- ===================================================================
-- PROCEDURE Upload_Data: This is the main procedure that will be
-- called by Web ADI, to validate and update the data into the IMP
-- interface table
-- ===================================================================
PROCEDURE Upload_Data(

                         p_asset_number              IN    VARCHAR2,
                         p_book_code                 IN    VARCHAR2,
                         p_category_desc             IN    VARCHAR2,
                         p_cost_mhca                 IN    NUMBER,
                         p_ytd_mhca                  IN    NUMBER,
                         p_accum_deprn_mhca          IN    NUMBER,
                         p_reval_reserve_mhca        IN    NUMBER,
                         p_backlog_mhca              IN    NUMBER,
                         p_general_fund_mhca         IN    NUMBER,
                         p_operating_account_cost    IN    NUMBER,
                         p_operating_account_backlog IN    NUMBER,
                         p_group_id                  IN    NUMBER
                        )

IS
 CURSOR c_asset_exists
  IS
  SELECT COUNT(*)
  FROM igi_imp_iac_interface
  WHERE asset_id = (SELECT asset_id
                    FROM fa_additions
                    WHERE asset_number = p_asset_number)
  AND   book_type_code = p_book_code
  AND   category_id = (SELECT category_id
                       FROM fa_categories_b_kfv
                       WHERE concatenated_segments = p_category_desc);

     Cursor C_book_class( cp_book_type_code igi_imp_iac_interface.book_type_code%TYPE) is
         Select book_class
         from fa_booK_controls
         where book_type_code = cp_book_type_code;

         cursor c_deprn_flag(cp_book_type_code igi_imp_iac_interface.book_type_code%TYPE,
                            cp_asset_num    igi_imp_iac_interface.asset_number%TYPE ) is
           select depreciate_flag
           from fa_books fb,fa_additions fa
            where book_type_code =cp_book_type_code
             and fa.asset_number = cp_asset_num
            and  fb.asset_id =fa.asset_id
             and transaction_header_id_out is null;


  l_exists           VARCHAR2(1);
  l_count            NUMBER;
  l_adi_enabled      VARCHAR2(3);
  l_request_status   igi_imp_iac_controls.request_status%TYPE;
  l_transfer_status  igi_imp_iac_interface_ctrl.transfer_status%TYPE;

  l_valid            BOOLEAN  := TRUE;

        l_deprn_flag  fa_books.depreciate_flag%type;
        l_book_class  fa_booK_controls.book_class%type;

  -- exceptions
  e_iac_not_enabled        EXCEPTION;
  e_web_adi_not_enabled    EXCEPTION;
  e_invalid_book           EXCEPTION;
  e_incomplete_preparation EXCEPTION;
  e_transfer_completed     EXCEPTION;
  e_invalid_category_id    EXCEPTION;
  e_asset_invalid          EXCEPTION;
  e_groupid_invalid        EXCEPTION;
  e_update_error           EXCEPTION;

BEGIN

  l_valid := TRUE;
  -- check if IAC is enabled
  IF NOT igi_gen.is_req_installed('IAC') THEN
      RAISE e_iac_not_enabled;
  END IF;

  igi_iac_debug_pkg.debug_other_string(g_state_level, g_path||'upload_data', 'IAC is enabled');

  -- Check if the profile option to use WebADI for import/export
  -- is set to 'Y'
  l_adi_enabled := fnd_profile.value('IGI_IMP_IAC_USE_WEB_ADI');

  IF (l_adi_enabled <> 'Y') THEN
     l_valid := FALSE;
     RAISE e_web_adi_not_enabled;
  END IF;

  igi_iac_debug_pkg.debug_other_string(g_state_level, g_path||'upload_data', 'Web ADI is enabled');

  -- validate if p_book_type_code exists in control table igi_imp_iac_controls
  l_request_status := validate_book(p_book_code);
  IF (l_request_status IS NULL) THEN
     l_valid := FALSE;
     RAISE e_invalid_book;
  END IF;

  /* open c_booK_class(p_book_code);
   Fetch c_booK_class into l_booK_class;
   Close c_book_class; */

  igi_iac_debug_pkg.debug_other_string(g_state_level, g_path||'upload_data', 'Book Validated');

    -- validate the request status
  IF UPPER(l_request_status) <> 'C' THEN
     l_valid := FALSE;
     RAISE e_incomplete_preparation;
  END IF;

  igi_iac_debug_pkg.debug_other_string(g_state_level, g_path||'upload_data', 'Incomplete preparation');

  -- Validate the category id
  l_count := validate_category(p_book_code,
                               p_category_desc);
  IF l_count = 0 THEN
     l_valid := FALSE;
     RAISE e_invalid_category_id;
  END IF;

  igi_iac_debug_pkg.debug_other_string(g_state_level, g_path||'upload_data', 'Validated Category');

  -- validate the transfer, if complete, then record should not be updated
  l_transfer_status := validate_transfer(p_book_code,
                                         p_category_desc);
  IF UPPER(l_transfer_status) = 'C' THEN
     l_valid := FALSE;
     RAISE e_transfer_completed;
  END IF;

  igi_iac_debug_pkg.debug_other_string(g_state_level, g_path||'upload_data', 'Transfer Status Validated');

  -- validate the group_id
  l_count := validate_groupid(p_book_code,
                              p_category_desc,
                              p_asset_number,
                              p_group_id);
  IF (l_count = 0) THEN
       l_valid := FALSE;
       RAISE e_groupid_invalid;
  END IF;

  -- if there is no row or multiple rows for the asset return error
  -- only 1 row must exist for the asset for the book and category

  l_count := validate_asset(p_book_code,
                            p_category_desc,
                            p_asset_number);
  IF (l_count <> 1) THEN
       l_valid := FALSE;
       RAISE e_asset_invalid;
  END IF;

  igi_iac_debug_pkg.debug_other_string(g_state_level, g_path||'upload_data', 'Asset Validated');

  -- update the asset if it is has passed all validation

   l_deprn_flag := 'YES';
   --IF l_book_class = 'CORPORATE' THEN
       open c_deprn_flag(p_book_code,p_asset_number);
       fetch c_deprn_flag into l_deprn_flag;
       close c_deprn_flag;
    --END IF;


    If    l_deprn_flag = 'YES' Then
     UPDATE igi_imp_iac_interface
        SET
        cost_mhca                 =  p_cost_mhca,
           ytd_mhca                  =  p_ytd_mhca,
           accum_deprn_mhca          =  p_accum_deprn_mhca,
           reval_reserve_mhca        =  p_reval_reserve_mhca,
           backlog_mhca              =  p_backlog_mhca,
           general_fund_mhca         =  p_general_fund_mhca,
           operating_account_cost    = nvl(p_operating_account_cost,0) * -1,
           operating_account_backlog = nvl(p_operating_account_backlog,0) * -1,
           last_update_login         = fnd_global.login_id,
           last_update_date          = sysdate,
           last_updated_by           = fnd_global.login_id,
	   valid_flag                = 'N'     -- Bug 5137813
         WHERE group_id = p_group_id
     AND   asset_number = p_asset_number
     AND   book_type_code = p_book_code;
   Else
       UPDATE igi_imp_iac_interface
        SET
           cost_mhca                 =  p_cost_mhca,
           reval_reserve_mhca        =  p_reval_reserve_mhca,
	   operating_account_cost    = nvl(p_operating_account_cost,0) * -1,
           last_update_login         = fnd_global.login_id,
           last_update_date          = sysdate,
           last_updated_by           = fnd_global.login_id,
           valid_flag                = 'N' --Bug 5137813
       WHERE group_id = p_group_id
     AND   asset_number = p_asset_number
     AND   book_type_code = p_book_code;
  End if;



 IF SQL%ROWCOUNT = 0 THEN
    RAISE e_update_error;
 END IF;

 igi_iac_debug_pkg.debug_other_string(g_event_level, g_path||'upload_data', 'Update successful');


 --ROLLBACK;

EXCEPTION
      WHEN e_iac_not_enabled THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IAC_NOT_INSTALLED');
	 igi_iac_debug_pkg.debug_other_msg(g_error_level, g_path||'upload_data', FALSE);
         FND_MESSAGE.Raise_Error;

      WHEN e_web_adi_not_enabled THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_USE_IMP_BUTTON');
	 igi_iac_debug_pkg.debug_other_msg(g_error_level, g_path||'upload_data', FALSE);
         FND_MESSAGE.Raise_Error;

      WHEN e_invalid_book THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_INVALID_BOOK');
         FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',p_book_code);
	 igi_iac_debug_pkg.debug_other_msg(g_error_level, g_path||'upload_data', FALSE);
         FND_MESSAGE.Raise_Error;

      WHEN e_incomplete_preparation THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_PREP_NOT_COMPLETE');
         FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',p_book_code);
	 igi_iac_debug_pkg.debug_other_msg(g_error_level, g_path||'upload_data', FALSE);
         FND_MESSAGE.Raise_Error;

      WHEN e_transfer_completed THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_ASSET_ERR_ADI');
         FND_MESSAGE.Set_Token('ASSET_NUMBER',p_asset_number);
         FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',p_book_code);
         FND_MESSAGE.Set_Token('CATEGORY_DESC',p_category_desc);
	 igi_iac_debug_pkg.debug_other_msg(g_error_level, g_path||'upload_data', FALSE);
         FND_MESSAGE.Raise_Error;

      WHEN e_invalid_category_id THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_CAT_ERR_ADI');
         FND_MESSAGE.Set_Token('CATEGORY_DESC',p_category_desc);
         FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',p_book_code);
	 igi_iac_debug_pkg.debug_other_msg(g_error_level, g_path||'upload_data', FALSE);
         FND_MESSAGE.Raise_Error;

      WHEN e_asset_invalid THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_INTFACE_ERR_ADI');
         FND_MESSAGE.Set_Token('ASSET_NUMBER',p_asset_number);
	 igi_iac_debug_pkg.debug_other_msg(g_error_level, g_path||'upload_data', FALSE);
         FND_MESSAGE.Raise_Error;

      WHEN e_groupid_invalid THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_GROUPID_ERR_ADI');
         FND_MESSAGE.Set_Token('GROUP_ID',p_group_id);
         FND_MESSAGE.Set_Token('ASSET_NUMBER',p_asset_number);
         FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',p_book_code);
         FND_MESSAGE.Set_Token('CATEGORY_DESC',p_category_desc);
	 igi_iac_debug_pkg.debug_other_msg(g_error_level, g_path||'upload_data', FALSE);
         FND_MESSAGE.Raise_Error;

      WHEN e_update_error THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_UPDATE_ERR_ADI');
         FND_MESSAGE.Set_Token('ASSET_NUMBER',p_asset_number);
         FND_MESSAGE.Set_Token('BOOK_TYPE_CODE',p_book_code);
         FND_MESSAGE.Set_Token('CATEGORY_DESC',p_category_desc);
	 igi_iac_debug_pkg.debug_other_msg(g_error_level, g_path||'upload_data', FALSE);
         FND_MESSAGE.Raise_Error;

      WHEN OTHERS THEN
	 igi_iac_debug_pkg.debug_unexpected_msg(g_path||'upload_data');
         FND_MESSAGE.Raise_Error;
END  Upload_Data;

END IGI_IMP_IAC_WEBADI_PKG; -- Package body



/
