--------------------------------------------------------
--  DDL for Package Body IGR_IMP_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_IMP_004" AS
/* $Header: IGSRT15B.pls 120.2 2006/06/27 12:07:06 rghosh noship $ */

/* ------------------------------------------------------------------------------------------------------------------------
  ||  Created By : rbezawad
  ||  Created On : 28-Feb-05
  ||  Purpose : Extract of IGR related references from Admissions Import process packages (IGSAD98B.pls)
  ||            to get rid of probable compilation errors for non-IGR customers.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  WHO             WHEN                   WHAT
      9-Mar-05      rbezawad    Modified logic to Validated Pakcage items for APC Integration Build. Bug: 3973942.
                                Also obsoelted usage of Entry Status/Program/Unit Set code columns.
---------------------------------------------------------------------------------------------------------------------------*/

-- lb_validation is set to true if the particular record in the interface
-- table passes all the validation meant for it, othewise it is set to false
  lb_validation          BOOLEAN;

    cst_s_val_1    CONSTANT VARCHAR2(1) := '1';
    cst_s_val_2    CONSTANT VARCHAR2(1) := '2';
    cst_s_val_3    CONSTANT VARCHAR2(1) := '3';
    cst_s_val_4    CONSTANT VARCHAR2(1) := '4';

    cst_ec_val_E322 CONSTANT VARCHAR2(4) := 'E322';
    cst_ec_val_E014 CONSTANT VARCHAR2(4) := 'E014';
    cst_ec_val_E702 CONSTANT VARCHAR2(4) := 'E702';
    cst_ec_val_e700 CONSTANT VARCHAR2(4) := 'E700';

-- The cursor c_inq_info is used, to select all the records from the Inquiry Information
-- Interface table that are pending for processing and the parent
-- Inquiry Application record status is completed ('1')and the parent
-- Interface Record has a status of Completed ('1') or Warning ('4')

  CURSOR c_inq_info (cp_interface_run_id igr_i_info_int.interface_run_id%TYPE) IS
    SELECT  inq.rowid,inq.*
    FROM      igr_i_info_int  inq
    WHERE  inq.interface_run_id = cp_interface_run_id
    AND         inq.status = '2';


-- The cursor c_inq_char is used, to select all the records from the Inquiry Characteristics
-- Interface table that are pending for processing and the parent
-- Inquiry Application record's status is completed ('1')and the parent
-- Interface Record has a status of Completed ('1') or Warning ('4')

  CURSOR c_inq_char  (cp_interface_run_id igr_i_char_int.interface_run_id%TYPE) IS
    SELECT chi.rowid,chi.*
    FROM      igr_i_char_int chi
    WHERE  chi.interface_run_id = cp_interface_run_id
    AND         chi.status = '2';


-- The cursor c_inq_pkg is used, to select all the records from the Inquiry Packages
-- Interface table that are pending for processing and the parent
-- Inquiry Application record's status is completed ('1')and the parent
-- Interface Record has status of Completed ('1') or Warning ('4')

  CURSOR  c_inq_pkg  (cp_interface_run_id igr_i_pkg_int.interface_run_id%TYPE)IS
    SELECT  pkg.rowid,pkg.*
    FROM      igr_i_pkg_int pkg
    WHERE  pkg.interface_run_id = cp_interface_run_id
    AND         pkg.status = '2';

-------------Local Procedure Get_Meaning-----------------------------------------------
  FUNCTION get_meaning(
    p_lookup_code   VARCHAR2,
    p_lookup_type   VARCHAR2
  )
  RETURN VARCHAR2 AS
  /*******************************************************************************
  Created By:         Annamalai Muthu
  Date Created By:   06-12-2001 (MM-DD-YYYY)
  Purpose:           This fucntion is used to return the meaning for
                   a particular lookup_type and lookup_code combination.
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

  *******************************************************************************/
  -------------------------Variable Declaration------------------------------------
  lv_meaning igs_lookups_view.meaning%TYPE;
   -------------------------End Variable Declaration------------------------------------

  ---------------------------Cursor Declarations----------------------------------------
  -- Cursor c_lkup is used to select the record (if any) that matches the
  -- criteria passed  via the parameters to the fucntion
    CURSOR c_lkup (cp_lookup_type IGS_LOOKUPS_VIEW.LOOKUP_TYPE%TYPE,
                       cp_lookup_code IGS_LOOKUPS_VIEW.LOOKUP_CODE%TYPE)  IS
      SELECT meaning
      FROM igs_lookups_view
      WHERE lookup_type = cp_lookup_type
      AND lookup_code = cp_lookup_code;
  ---------------------------End Cursor Declarations----------------------------------------
  BEGIN
    OPEN c_lkup (P_lookup_code, p_lookup_type);
    FETCH c_lkup INTO lv_meaning;

    IF c_lkup%NOTFOUND  THEN
    -- No records are found that match the criteria passed via the parameters
    -- hence closing the cursor and returning null value.
      CLOSE c_lkup;
      RETURN NULL;
    END IF;

    -- The control will come to this point only if a matching record is found
    -- Hence closing the cursor and returning the value.
    CLOSE c_lkup;
    RETURN lv_meaning;
  END get_meaning;
-------------------------------------------------------------------------------


  PROCEDURE validate_inq_info(
    p_inq_info_rec IN  c_inq_info%ROWTYPE,
    p_validation   OUT NOCOPY BOOLEAN
  ) AS
  /*******************************************************************************
  Created By:         Annamalai Muthu
  Date Created By:   06-12-2001 (MM-DD-YYYY)
  Purpose:           To Validate the Inquiry Information record being processed
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

  *******************************************************************************/

    -------------------------Variable Delcaration---------------------------------
    lv_var                 VARCHAR2(1);

    l_error_text VARCHAR2(2000);
    -------------------------End Variable Delcaration---------------------------------


    ----------------------------Cursor Declaration--------------------------------------
    -- The cursor c_inq_info_typ is used to validate the column INQUIRY_INFORMATION_TYPE
    -- in the interface table. This cursor checks to see if the value is being
    -- properly referenced from the appropriate parent table.
    CURSOR c_inq_info_typ (cp_info_type_id igr_i_info_int.info_type_id%TYPE) IS
    SELECT
         'X'
    FROM
      igr_i_info_types_v
    WHERE
          TRUNC(actual_avail_from_date) <= TRUNC(SYSDATE)
      AND TRUNC(actual_avail_to_date) >= TRUNC(SYSDATE)
      AND info_type_id = cp_info_type_id;
    ----------------------------End Cursor Declaration--------------------------------------
  BEGIN

    OPEN c_inq_info_typ(p_inq_info_rec.info_type_id);
    FETCH c_inq_info_typ INTO lv_var;

    IF c_inq_info_typ%NOTFOUND THEN
      -- The control will come to this point only when there are is no referrence
      -- to this value in the parent, hence this is an error and validation must fail.
      p_validation := FALSE;

      -- Setting the status of the interface record to failed and the appropriate
      -- error code meant for the particular column.
      l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E318', 8405);
      UPDATE igr_i_info_int
      SET
        ERROR_CODE = 'E318',
        STATUS = '3',
        error_text = l_error_text
      WHERE INTERFACE_INQ_INFO_ID = p_inq_info_rec.INTERFACE_INQ_INFO_ID ;

    ELSE
      -- if the validation succeeds then continue processing normally
      p_validation := TRUE;
    END IF;
    -- closing the cursor that was opened before the IF block
    CLOSE c_inq_info_typ;
  END validate_inq_info;

  -------------------------------------------------------------------------------
  PROCEDURE create_inq_info(
    p_inq_info_rec IN  c_inq_info%ROWTYPE
  ) AS
  /*******************************************************************************
  Created By:         Annamalai Muthu
  Date Created By:   06-12-2001 (MM-DD-YYYY)
  Purpose:           To Insert the Inquiry Information record
                   in to the system tables using a TBH call
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
  *******************************************************************************/

    -----------------------------Variable Declaration-----------------------------------------
    lv_rowid           VARCHAR2(25);

   l_prog_label  VARCHAR2(100);
  p_error_code VARCHAR2(30);
  p_status VARCHAR2(1);
  l_error_code VARCHAR2(30);
  l_request_id NUMBER;
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
        l_enable_log VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_error_text VARCHAR2(2000);
  l_type VARCHAR2(1);
  l_status VARCHAR2(1);
  l_acad_int_id NUMBER;

  l_msg_at_index                NUMBER := 0;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

  l_records_processed    NUMBER := 0;

    -----------------------------End Variable Declaration-----------------------------------------

  BEGIN -- procedure create_inq_info

    -- Validate the record using the procedure validate_inq_info.
    validate_inq_info(p_inq_info_rec, lb_validation);

    IF lb_validation THEN
      -- the validation succeeds then
      -- call the TBH to insert the values from the
      -- Interface table igr_i_info_int.
      igr_i_a_itype_pkg.insert_row(
        x_mode                      => 'R',
        x_rowid                      => lv_rowid,
        x_person_id                 =>  p_inq_info_rec.person_id,
        x_enquiry_appl_number       =>  p_inq_info_rec.enquiry_appl_number,
        x_info_type_id              =>  p_inq_info_rec.info_type_id);

      igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

       IF l_msg_count > 0 THEN
     l_error_text := l_msg_data;
      l_type := l_hash_msg_name_text_type_tab(l_msg_count-1).type;
END IF;

      IF l_type = 'E'  THEN
        ROLLBACK TO  inqinfo_save;
        UPDATE igr_i_info_int
        SET status = cst_s_val_3,
                 error_code = cst_ec_val_E322,
                 error_text = l_error_text
        WHERE  rowid = p_inq_info_rec.rowid;

      IF l_enable_log = 'Y'   THEN
          igs_ad_imp_001.logerrormessage(p_inq_info_rec.interface_inq_info_id,l_msg_data);
      END IF;

      ELSIF l_type = 'S'  THEN
        UPDATE igr_i_info_int
        SET status = cst_s_val_4,
                error_code = cst_ec_val_E702,
                error_text = l_error_text
        WHERE  rowid = p_inq_info_rec.rowid;

        IF l_enable_log = 'Y'   THEN
            igs_ad_imp_001.logerrormessage(p_inq_info_rec.interface_inq_info_id,l_msg_data);
        END IF;

      ELSIF l_type IS NULL THEN
        UPDATE igr_i_info_int
        SET status = cst_s_val_1,
                 error_code = NULL,
                 error_text = NULL
        WHERE  rowid = p_inq_info_rec.rowid;

      END IF;

      l_records_processed := l_records_processed +1;

  END IF; -- lb_validation

  EXCEPTION
    WHEN OTHERS THEN

                        l_status := '3';
                        l_error_code := 'E322';

      igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      l_error_text := l_msg_data;

      IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
         IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(p_inq_info_rec.interface_inq_info_id,l_msg_data);
        END IF;
      ELSE

        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
          l_label :=  'igs.plsql.igr_imp_004.create_inq_info.exception '||'E322';

                    fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
                      fnd_message.set_token('CONTEXT',p_inq_info_rec.interface_inq_info_id);
                                  fnd_message.set_token('ERROR', l_error_text);

                            l_debug_str :=  fnd_message.get;

                fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,
                                                                                                                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;
      END IF;

      ROLLBACK TO  inqinfo_save;

      UPDATE igr_i_info_int
      SET status = cst_s_val_3,
               error_code = l_error_code ,
               error_text = l_error_text
      WHERE rowid = p_inq_info_rec.rowid;

      l_records_processed := l_records_processed + 1;

  END create_inq_info; -- procedure create_inq_info.

PROCEDURE prc_inq_info (
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_rule             IN VARCHAR2) AS
/*******************************************************************************
Created By:         Annamalai Muthu
Date Created By:   06-12-2001 (MM-DD-YYYY)
Purpose:           To Process the Inquiry Information records in the Interface table
Known limitations,enhancements,remarks:
Change History
Who     When       What

*******************************************************************************/
 l_records_processed NUMBER := 0;

l_request_id NUMBER;
l_error_text VARCHAR2(2000);
l_error_code VARCHAR2(30);

BEGIN  -- Procedure PRC_INQ_INFO.

/**********************************************************************************
This procedure is used to import the data from the interface table
igr_i_info_int to the System table

1. This procedure will loop through all the records in the table igr_i_info_int
with the STATUS = 2 -'Pending AND the parent IGS_AD_INTERFACE RECORD has
been successfully imported (Status = 1 - 'Completed')
***********************************************************************************/
  IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
   END IF;

  FOR lr_inq_info_rec IN c_inq_info (p_interface_run_id)
  LOOP
    l_records_processed := l_records_processed + 1;
    SAVEPOINT inqinfo_save;
    create_inq_info(lr_inq_info_rec);
    IF l_records_processed = 100 THEN
      COMMIT;
      l_records_processed := 0;
    END IF;
  l_error_text := NULL;
  l_error_code := NULL;
  END LOOP;
  IF l_records_processed < 100 AND l_records_processed > 0  THEN
    COMMIT;
  END IF;
END prc_inq_info;


PROCEDURE validate_inq_char(
    p_inq_char_rec IN  c_inq_char%ROWTYPE,
    p_validation   OUT NOCOPY BOOLEAN
  ) AS
  /*******************************************************************************
  Created By:         Annamalai Muthu
  Date Created By:   06-12-2001 (MM-DD-YYYY)
  Purpose:           To Validate the Inquiry Characteristics being porcessed
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

  *******************************************************************************/
  ---------------------------Variable Delcation----------------------------------------
  lv_var                 VARCHAR2(1);

  l_error_text VARCHAR2(2000);
  ---------------------------End Variable Delcation----------------------------------------

  ---------------------------------Cursor Declaration--------------------------------------
 -- The cursor c_inq_char_typ is used to validate the column INQUIRY_CHARACTERISTIC_TYPE
 -- in the interface table. This cursor checks to see if the value is being
 -- properly referenced from the appropriate parent table.

  CURSOR c_inq_char_typ (cp_INQUIRY_CHARACTERISTIC_TYPE igr_i_char_int.inquiry_characteristic_type%TYPE)IS
  SELECT
    'X'
  FROM
    igr_i_e_chartyp
  WHERE
        closed_ind ='N'
   AND enquiry_characteristic_type = cp_inquiry_characteristic_type;
  ---------------------------------End Cursor Declaration--------------------------------------
 BEGIN -- Validate_inq_char

    OPEN c_inq_char_typ(p_inq_char_rec.INQUIRY_CHARACTERISTIC_TYPE);
    FETCH c_inq_char_typ INTO lv_var;

    IF c_inq_char_typ%NOTFOUND THEN
      -- The control will come to this point only when there are is no referrence
      -- to this value in the parent, hence this is an error and validation must fail.
      p_validation := FALSE;

      -- Setting the status of the interface record to failed and the appropriate
      -- error code meant for the particular column.
      l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E319', 8405);
      UPDATE igr_i_char_int
      SET
        error_code = 'E319',
        status = '3',
        error_text = l_error_text
      WHERE interface_inq_char_id = p_inq_char_rec.interface_inq_char_id;

    ELSE
      -- if the validation succeeds then continue processing normally
      p_validation := TRUE;
    END IF;
    -- closing the cursor that was opened before the if block.
    CLOSE c_inq_char_typ;
  END validate_inq_char;

  PROCEDURE create_inq_char(
    p_inq_char_rec IN  c_inq_char%ROWTYPE
  ) AS
  /*******************************************************************************
  Created By:         Annamalai Muthu
  Date Created By:   06-12-2001 (MM-DD-YYYY)
  Purpose:           To Insert the Inquiry Characteristics record being processed
                   in to the system tables using a TBH call
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

 *******************************************************************************/
   lv_rowid                 VARCHAR2(25);

   l_prog_label  VARCHAR2(100);
  p_error_code VARCHAR2(30);
  p_status VARCHAR2(1);
  l_error_code VARCHAR2(30);
  l_request_id NUMBER;
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
        l_enable_log VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_error_text VARCHAR2(2000);
  l_type VARCHAR2(1);
  l_status VARCHAR2(1);
  l_acad_int_id NUMBER;

  l_msg_at_index                NUMBER := 0;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

  l_records_processed    NUMBER := 0;

 BEGIN -- create_inq_char

    -- Validate the record using the procedure validate_inq_char.
   Validate_inq_char(p_inq_char_rec, lb_validation);

    IF lb_validation THEN
      -- call the TBH to insert the values from the
      -- Interface table igr_i_char_int.

      igr_i_a_chartyp_pkg.insert_row(
        x_rowid                       =>  lv_rowid,
        x_person_id                   =>  p_inq_char_rec.person_id,
        x_enquiry_appl_number         =>  p_inq_char_rec.enquiry_appl_number,
        x_enquiry_characteristic_type =>  p_inq_char_rec.inquiry_characteristic_type,
        x_mode                        =>  'R');

      -- If the Insert succeeds then update the Interface records as completed.
           igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_msg_count > 0 THEN
      l_error_text := l_msg_data;
      l_type := l_hash_msg_name_text_type_tab(l_msg_count-1).type;
END IF;

      IF l_type = 'E'  THEN
        ROLLBACK TO  inqchar_save;
        UPDATE igr_i_char_int
        SET status = cst_s_val_3,
                 error_code = cst_ec_val_E322,
                 error_text = l_error_text
        WHERE  rowid = p_inq_char_rec.rowid;

      IF l_enable_log = 'Y'   THEN
          igs_ad_imp_001.logerrormessage(p_inq_char_rec.interface_inq_char_id,l_msg_data);
      END IF;

      ELSIF l_type = 'S'  THEN
        UPDATE igr_i_char_int
        SET status = cst_s_val_4,
                error_code = cst_ec_val_E702,
                error_text = l_error_text
        WHERE  rowid = p_inq_char_rec.rowid;

      IF l_enable_log = 'Y'   THEN
          igs_ad_imp_001.logerrormessage(p_inq_char_rec.interface_inq_char_id,l_msg_data);
      END IF;

      ELSIF l_type IS NULL THEN
        UPDATE igr_i_char_int
        SET status = cst_s_val_1,
                 error_code = NULL,
                 error_text = NULL
        WHERE  rowid = p_inq_char_rec.rowid;

      END IF;

      l_records_processed := l_records_processed +1;

  END IF; -- lb_validation

  EXCEPTION
    WHEN OTHERS THEN

                        l_status := '3';
                        l_error_code := 'E322';

      igs_ad_gen_016.extract_msg_from_stack (
                                    p_msg_at_index                => l_msg_at_index,
                                    p_return_status               => l_return_status,
                                    p_msg_count                   => l_msg_count,
                                    p_msg_data                    => l_msg_data,
                                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      l_error_text := l_msg_data;

      IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
         IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(p_inq_char_rec.interface_inq_char_id,l_msg_data);
        END IF;
      ELSE

        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
          l_label :=  'igs.plsql.igr_imp_004.create_inq_char.exception '||'E322';

                    fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
                      fnd_message.set_token('CONTEXT',p_inq_char_rec.interface_inq_char_id);
                                  fnd_message.set_token('ERROR', l_error_text);

                            l_debug_str :=  fnd_message.get;

                fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,
                                                                                                                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;
      END IF;

      ROLLBACK TO  inqchar_save;

      UPDATE igr_i_char_int
      SET status = cst_s_val_3,
               error_code = l_error_code ,
               error_text = l_error_text
      WHERE rowid = p_inq_char_rec.rowid;

      l_records_processed := l_records_processed + 1;
  END  create_inq_char;

PROCEDURE prc_inq_char (
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_rule             IN VARCHAR2) AS
 /*******************************************************************************
 Created By:       Annamalai Muthu
 Date Created By: 06-12-2001 (MM-DD-YYYY)
 Purpose:         To Process Inquiry Characteristics in the Interface Table
 Known limitations,enhancements,remarks:
 Change History
 Who   When       What

 *******************************************************************************/
 l_records_processed NUMBER := 0;

 l_request_id NUMBER;
l_error_text VARCHAR2(2000);
l_error_code VARCHAR2(30);

BEGIN -- prc_inq_char
/*-----------------------------------------------------------------------------
 This procedure is used to import the data from the interface table
 igr_i_char_int to the System table

 1. This procedure will loop through all the records in the table igr_i_char_int
 with the STATUS = 2 -'Pending AND the parent IGS_AD_INTERFACE RECORD has
 been successfully imported (Status = 1 - 'Completed')
*******************************************************************/
  IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
  END IF;

  FOR lr_inq_char_rec IN c_inq_char (p_interface_run_id)
  LOOP
    l_records_processed := l_records_processed + 1;
    SAVEPOINT inqchar_save;
    create_inq_char(lr_inq_char_rec);
    IF l_records_processed = 100 THEN
      COMMIT;
      l_records_processed := 0;
    END IF;
  l_error_text := NULL;
  l_error_code := NULL;
  END LOOP;
  IF l_records_processed < 100 AND l_records_processed > 0  THEN
    COMMIT;
  END IF;
END prc_inq_char;

PROCEDURE validate_inq_pkg(
  p_inq_pkg_rec IN  c_inq_pkg%ROWTYPE,
  p_validation  OUT NOCOPY BOOLEAN
 ) AS
 /*******************************************************************************
 Created By:       Annamalai Muthu
 Date Created By: 06-12-2001 (MM-DD-YYYY)
 Purpose:         To Validate the Inquiry  Packages Record being processed
 Known limitations,enhancements,remarks:
 Change History
 Who   When       What

 *******************************************************************************/
 -----------------------Variable declaration-------------------------------------
l_exists                  VARCHAR2(1);
l_request_id NUMBER;
l_error_text VARCHAR2(2000);
l_error_code VARCHAR2(30);

 -------------------------End variable declaration-------------------------------

 ------------------------Cursor declaration--------------------------------------
   -- Cursor to validate the package items (This cursor is changed as a part of the SQL tuning
   -- bug 4991561)
   CURSOR c_package_item(cp_sales_lead_id      as_sales_lead_lines.sales_lead_id%TYPE,
                         cp_inquiry_type_id    igr_i_appl_int.inquiry_type_id%TYPE,
                         cp_package_reduct_ind igr_i_appl_int.pkg_reduct_ind%TYPE) IS
     SELECT 'X'
     FROM   IGR_I_PKG_ITEM PKGITM,
            AMS_P_DELIVERABLES_V DELIV
     WHERE  pkgitm.package_item_id = p_inq_pkg_rec.package_item_id
     AND    PKGITM.PACKAGE_ITEM_ID = DELIV.DELIVERABLE_ID
     AND    DELIV.KIT_FLAG = 'N'
     AND    (TRUNC(DELIV.actual_avail_from_date) <= TRUNC(SYSDATE) AND
             TRUNC(DELIV.actual_avail_to_date) >= TRUNC(SYSDATE)  )
     AND    (
              -- Validate Package item against Inquiry Type => Associated with Information Type/Deliverable Kit => With Package items in it.
	     EXISTS ( SELECT 1
                       FROM   ams_p_deliv_kit_items_v kitems,igr_i_inquiry_types inq
                       WHERE  kitems.deliverable_kit_part_id =  pkgitm.package_item_id
                       AND    kitems.deliverable_kit_id  = inq.info_type_id
		       AND    inq.inquiry_type_id = cp_inquiry_type_id
                     )
              -- Don't Validate package items against Academic Interest Category when Package Reduction Indicator is not set('N' or NULL).
	     OR NVL(cp_package_reduct_ind,'N') = 'N'
              -- Don't Validate package items when there are no Academic Interest Categories associated.
             OR NOT EXISTS ( SELECT 1
                              FROM as_sales_lead_lines
                              WHERE sales_lead_id = cp_sales_lead_id
                              AND category_id IS NOT NULL
                              AND category_set_id IS NOT NULL
                             )
              -- Validate package items against Academic Interest Category when Package Reduction Indicator is set to 'Y'.
             OR ( cp_package_reduct_ind = 'Y' AND
                   EXISTS ( SELECT 1
                            FROM  igr_i_pkgitm_assign pia, as_sales_lead_lines lines
                            WHERE pia.package_item_id = pkgitm.package_item_id
                            AND  pia.product_category_id = lines.category_id
			    AND  pia.product_category_set_id = lines.category_set_id
			    AND  lines.sales_lead_id = cp_sales_lead_id
                            AND pia.enabled_flag = 'Y'
                          )
                 )
             );

    --Cursor to get the inquiry_type_id and package_reduct_ind from IGR_I_APPL_INT table.
    CURSOR c_appl_int (cp_interface_inq_appl_id igr_i_pkg_int.interface_inq_appl_id%TYPE) IS
      SELECT inquiry_type_id, pkg_reduct_ind
      FROM   igr_i_appl_int
      WHERE  interface_inq_appl_id = cp_interface_inq_appl_id;

    l_appl_int_rec c_appl_int%ROWTYPE;

  ------------------------End Cursor declaration--------------------------------------
  BEGIN -- Validate_inq_pkg

    l_appl_int_rec := NULL;
    OPEN c_appl_int (p_inq_pkg_rec.interface_inq_appl_id);
    FETCH c_appl_int INTO l_appl_int_rec;
    CLOSE c_appl_int;

    OPEN c_package_item(p_inq_pkg_rec.sales_lead_id,l_appl_int_rec.inquiry_type_id,l_appl_int_rec.pkg_reduct_ind);
    FETCH c_package_item INTO l_exists;
    IF c_package_item%NOTFOUND THEN
      l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E321', 8405);
      UPDATE
        igr_i_pkg_int
      SET
        status = '3', -- 'Error'
        error_code = 'E321',
        error_text = l_error_text
      WHERE
        INTERFACE_INQ_PKG_ID = p_inq_pkg_rec.INTERFACE_INQ_PKG_ID;

      p_validation := FALSE;
      RETURN;
    END IF;
    p_validation := TRUE;
 END  validate_inq_pkg;

  PROCEDURE create_inq_pkg(
    p_inq_pkg_rec IN  c_inq_pkg%ROWTYPE
  ) AS
 /*******************************************************************************
 Created By:         Annamalai Muthu
 Date Created By:   06-12-2001 (MM-DD-YYYY)
 Purpose:           To Insert the Inquiry Packages record
                   in to the system tables using a TBH call
 Known limitations,enhancements,remarks:
 Change History
 Who     When       What

 *******************************************************************************/

  ----------------Variable delcarations-------------------------------------------
  lv_rowid  VARCHAR2(25);
  lb_validation BOOLEAN;
  lv_msg_count NUMBER ;
  lv_msg_data      VARCHAR2(2000);
  lv_return_status VARCHAR2(1);

  l_prog_label  VARCHAR2(100);
  l_error_code VARCHAR2(30);
  l_request_id NUMBER;
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_enable_log VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_error_text VARCHAR2(2000);
  l_type VARCHAR2(1);
  l_status VARCHAR2(1);
  l_sqlerrm VARCHAR2(2000);

  l_msg_at_index                NUMBER := 0;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

  -------------------End variable declarations-----------------------------------
 BEGIN -- create_inq_pkg

    l_msg_at_index := igs_ge_msg_stack.count_msg;

    Validate_inq_pkg(p_inq_pkg_rec, lb_validation);

    IF lb_validation THEN

      -- call the TBH  to insert the values from the
      -- Interface table igr_i_pkg_int.

      igr_i_a_pkgitm_pkg.insert_row(
        x_rowid                  =>  lv_rowid,
        x_person_id              =>  p_inq_pkg_rec.person_id,
        x_enquiry_appl_number    =>  p_inq_pkg_rec.enquiry_appl_number,
        x_package_item_id        =>  p_inq_pkg_rec.package_item_id,
        x_mailed_dt              =>  NULL,
        x_donot_mail_ind         =>  p_inq_pkg_rec.donot_mail_ind,  -- added as part of idopa2
        x_mode                   =>  'R',
        x_ret_status             => lv_return_status,
        x_msg_data               => lv_msg_data,
        x_msg_count              => lv_msg_count,
        x_action                 => 'Import'
      );

      IF lv_return_status <>'U'  AND lv_msg_data IS NOT NULL THEN
        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(p_inq_pkg_rec.interface_inq_pkg_id,lv_msg_data);
        END IF;

      ELSIF lv_return_status = 'U' THEN
        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
          l_label :=  'igs.plsql.igr_imp_004.create_inq_pkg.exception '||'E322';

          fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
                      fnd_message.set_token('CONTEXT',p_inq_pkg_rec.interface_inq_pkg_id);
                      fnd_message.set_token('ERROR', l_error_text);

                      l_debug_str :=  fnd_message.get;

          fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;
      END IF;

      IF lv_msg_data IS NOT NULL THEN
       /* Return status of Null should be treated as Success */
        IF NVL(lv_return_status,'S') = 'S'  THEN
          UPDATE igr_i_pkg_int
          SET status = '4',
                   error_code = 'E702',
                         error_text = lv_msg_data
          WHERE rowid = p_inq_pkg_rec.rowid;
        ELSE
           ROLLBACK TO inqpkg_save;
          UPDATE igr_i_pkg_int
          SET status = '3',
                  error_code = 'E322',
                        error_text = lv_msg_data
          WHERE rowid = p_inq_pkg_rec.rowid;
        END IF;
      ELSE
        /* Return status of Null should be treated as Success */
        IF NVL(lv_return_status,'S') = 'S'  THEN
          UPDATE igr_i_pkg_int
          SET status = '1',
                   error_code = NULL,
                   error_text = NULL
          WHERE rowid = p_inq_pkg_rec.rowid;
        ELSE
          l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E322', 8405);
          ROLLBACK TO inqpkg_save;
          UPDATE igr_i_pkg_int
          SET status = '3',
                   error_code = 'E322',
                   error_text = l_error_text
                WHERE rowid = p_inq_pkg_rec.rowid;
        END IF;
      END IF;

    END IF; -- lb_validation
  EXCEPTION
    WHEN OTHERS THEN

      igs_ad_gen_016.extract_msg_from_stack (
                                       p_msg_at_index                => l_msg_at_index,
                                       p_return_status               => l_return_status,
                                       p_msg_count                   => l_msg_count,
                                       p_msg_data                    => l_msg_data,
                                       p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_msg_data IS NOT NULL THEN
        l_error_text := l_msg_data;
      ELSE
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E322', 8405);
      END IF;

      ROLLBACK TO inqpkg_save;
      UPDATE igr_i_pkg_int
      SET error_code = 'E322',
               status = '3',
               error_text = l_error_text
      WHERE interface_inq_pkg_id = p_inq_pkg_rec.interface_inq_pkg_id;

  END create_inq_pkg;

 PROCEDURE prc_inq_pkg (
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_rule             IN VARCHAR2) AS
  /*******************************************************************************
  Created By:         Annamalai Muthu
  Date Created By:   06-12-2001 (MM-DD-YYYY)
  Purpose:           To Process the Inquiry Packages record in the Interface table
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
  *******************************************************************************/
   l_records_processed NUMBER := 0;

   l_request_id NUMBER;
   l_error_text VARCHAR2(2000);
   l_error_code VARCHAR2(30);

  BEGIN -- prc_inq_pkg
 /*-----------------------------------------------------------------------------
 This procedure is used to import the data from the interface table
 igr_i_pkg_int to the System table

 1. This procedure will loop through all the records in the table igr_i_pkg_int
 with the STATUS = 2 -'Pending AND the parent IGS_AD_INTERFACE RECORD has
 been successfully imported (Status = 1 - 'Completed')
 -------------------------------------------------------------------------------*/
    IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
   END IF;

    FOR lr_inq_pkg_rec IN c_inq_pkg (p_interface_run_id)
    LOOP
      l_records_processed := l_records_processed + 1;
      SAVEPOINT inqpkg_save;

      create_inq_pkg(lr_inq_pkg_rec);

      IF l_records_processed = 100 THEN
        COMMIT;
        l_records_processed := 0;
      END IF;
    l_error_text := NULL;
    l_error_code := NULL;
    END LOOP;
    IF l_records_processed < 100 AND l_records_processed > 0  THEN
      COMMIT;
    END IF;
  END prc_inq_pkg;

END IGR_IMP_004;

/
