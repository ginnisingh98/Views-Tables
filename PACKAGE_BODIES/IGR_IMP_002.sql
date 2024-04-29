--------------------------------------------------------
--  DDL for Package Body IGR_IMP_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_IMP_002" AS
/* $Header: IGSRT13B.pls 120.0 2005/06/01 21:44:35 appldev noship $ */
/* ------------------------------------------------------------------------------------------------------------------------
  ||  Created By : rbezawad
  ||  Created On : 27-Feb-05
  ||  Purpose : Extract of IGR related references from Admissions Import process packages (IGSAD79B.pls and IGSAD93B.pls)
  ||            to get rid of probable compilation errors for non-IGR customers.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  WHO             WHEN                   WHAT
      9-Mar-05      rbezawad    Modified for APC Integration Build. Bug: 3973942.
                                Also obsoelted usage of Entry Status/Program/Unit Set code columns.
---------------------------------------------------------------------------------------------------------------------------*/

  -- These are the package variables to hold the value of whether the particular category is included or not.
  g_inquiry_inst_inc              BOOLEAN := FALSE;
  g_inquiry_dtls_inc              BOOLEAN := FALSE;
  g_inquiry_acad_int_inc          BOOLEAN := FALSE;
  g_inquiry_pkg_itm_inc           BOOLEAN := FALSE;
  g_inquiry_info_type_inc         BOOLEAN := FALSE;
  g_inquiry_char_inc              BOOLEAN := FALSE;


  PROCEDURE update_parent_record_status ( p_interface_run_id  IN NUMBER ) AS
  /*************************************************************
   Created By : rbezawad
   Date Created By :  27-Feb-05
   Purpose : Procedure to set the IGR_I_APPL_INT.STATUS value to Warning (status='4') when IGR_I_APPL_INT record
             is processed successfully (status='1') but processing of any of the child interface records is not
             successful (status<>'1').  Also set the IGS_AD_INTERFACE.STATUS to Error (Status='3') when processing any
	     of the child interface records (IGR_I_APPL_INT) is not successful (status<>'1').
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN

    -- Based upon inquiry child
    UPDATE igr_i_appl_int iappl
    SET    status = '4',
           error_code = 'E347',
           error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E347', 8405)
    WHERE  status = '1'
    AND    interface_run_id = p_interface_run_id
    AND    (
                EXISTS (SELECT 1 FROM igr_i_lines_int WHERE status <> '1' AND interface_inq_appl_id = iappl.interface_inq_appl_id)
            OR  EXISTS (SELECT 1 FROM igr_i_pkg_int WHERE status <> '1' AND interface_inq_appl_id = iappl.interface_inq_appl_id)
            OR  EXISTS (SELECT 1 FROM igr_i_info_int WHERE status <> '1' AND interface_inq_appl_id = iappl.interface_inq_appl_id)
            OR  EXISTS (SELECT 1 FROM igr_i_char_int WHERE status <> '1' AND interface_inq_appl_id = iappl.interface_inq_appl_id)
           );
    COMMIT;

    -- Based upon person child
    UPDATE igs_ad_interface ad
    SET    record_status = '3',
           status = '4',
           error_code = 'E347'
    WHERE  status = '1'
    AND    interface_run_id = p_interface_run_id
    AND    (EXISTS (SELECT 1 FROM igr_i_appl_int WHERE status <> '1' AND interface_id = ad.interface_id));
    COMMIT;

  END update_parent_record_status;


  PROCEDURE prc_ad_category (p_source_type_id IN NUMBER,
                             p_interface_run_id  IN NUMBER,
                             p_enable_log IN VARCHAR2,
                             p_schema IN VARCHAR2
  ) AS
  /*************************************************************
   Created By : rbezawad
   Date Created By :  27-Feb-05
   Purpose : This procedure is used to call the procedures in related inquiry source category (INQUIRY_INSTANCE)
             to import each entity (INQUIRY_DETAILS, INQUIRY_ACADEMIC_INTEREST, INQUIRY_PACKAGE_ITEMS, INQUIRY_INFORMATION_TYPES
	     and INQUIRY_CHARACTERISTICS).
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
  ***************************************************************/

    l_meaning     igs_lookup_values.meaning%TYPE;

  BEGIN

    g_inquiry_inst_inc            := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'INQUIRY_INSTANCE');
    IF g_inquiry_inst_inc THEN
      g_inquiry_dtls_inc            := TRUE;
      g_inquiry_acad_int_inc        := TRUE;
      g_inquiry_pkg_itm_inc         := TRUE;
      g_inquiry_info_type_inc       := TRUE;
      g_inquiry_char_inc            := TRUE;
    ELSE
      g_inquiry_dtls_inc            := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'INQUIRY_DETAILS');
      g_inquiry_acad_int_inc        := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'INQUIRY_ACADEMIC_INTEREST');
      g_inquiry_pkg_itm_inc         := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'INQUIRY_PACKAGE_ITEMS');
      g_inquiry_info_type_inc       := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'INQUIRY_INFORMATION_TYPES');
      g_inquiry_char_inc            := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'INQUIRY_CHARACTERISTICS');
    END IF;

    IF g_inquiry_inst_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'INQUIRY_INSTANCE', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;
      -- Would need to process all inquiry entities since INQUIRY_INSTANCE includes all entities
      -- Processing would take place through the below mentioned category handling
      -- g_inquiry_dtls_inc (INQUIRY_DETAILS)
      -- g_inquiry_acad_int_inc (INQUIRY_ACADEMIC_INTEREST)
      -- g_inquiry_pkg_itm_inc (INQUIRY_PACKAGE_ITEMS)
      -- g_inquiry_info_type_inc (INQUIRY_INFORMATION_TYPES)
      -- g_inquiry_char_inc (INQUIRY_CHARACTERISTICS)
    END IF; -- g_inquiry_inst_inc

    IF g_inquiry_dtls_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'INQUIRY_DETAILS', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igr_i_appl_int a
      SET    interface_run_id = p_interface_run_id,
             person_id = (SELECT person_id
                          FROM   igs_ad_interface
                          WHERE  interface_id = a.interface_id)
      WHERE  interface_id IN (SELECT interface_id
                              FROM   igs_ad_interface
                              WHERE  interface_run_id = p_interface_run_id
                              AND    status IN ('1','4'));

      -- If record failed only due to child record failure
      -- then set status back to 1 and nullify error code/text
      UPDATE igr_i_appl_int
      SET    error_code = NULL,
             error_text = NULL,
             status = '1'
      WHERE  interface_run_id = p_interface_run_id
      AND    error_code = 'E347'
      AND    status = '4';

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => p_schema,
                                   tabname => 'IGR_I_APPL_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igr_imp_003.process_person_inquiry (p_interface_run_id => p_interface_run_id,
                                          p_source_type_id   => p_source_type_id,
                                          p_enable_log       => p_enable_log,
                                          p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_inquiry_dtls_inc

    IF g_inquiry_acad_int_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'INQUIRY_ACADEMIC_INTEREST', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igr_i_lines_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,enquiry_appl_number,inquiry_date,inquiry_source_type,sales_lead_id)
             = (SELECT person_id,enquiry_appl_number,inquiry_dt,inquiry_source_type,sales_lead_id
                FROM   igr_i_appl_int
                WHERE  interface_inq_appl_id = a.interface_inq_appl_id)
      WHERE  interface_inq_appl_id IN (SELECT interface_inq_appl_id
                                       FROM   igr_i_appl_int
                                       WHERE  interface_run_id = p_interface_run_id
                                       AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => p_schema,
                                   tabname => 'IGR_I_LINES_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igr_imp_003.process_inquiry_lines (p_interface_run_id => p_interface_run_id,
                                         p_enable_log       => p_enable_log,
                                         p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_inquiry_acad_int_inc

    IF g_inquiry_pkg_itm_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'INQUIRY_PACKAGE_ITEMS', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igr_i_pkg_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,enquiry_appl_number,sales_lead_id)
             = (SELECT person_id,enquiry_appl_number,sales_lead_id
                FROM   igr_i_appl_int
                WHERE  interface_inq_appl_id = a.interface_inq_appl_id)
      WHERE  interface_inq_appl_id IN (SELECT interface_inq_appl_id
                                       FROM   igr_i_appl_int
                                       WHERE  interface_run_id = p_interface_run_id
                                       AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => p_schema,
                                   tabname => 'IGR_I_PKG_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igr_imp_004.prc_inq_pkg (p_interface_run_id => p_interface_run_id,
                               p_enable_log       => p_enable_log,
                               p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_inquiry_pkg_itm_inc

    IF g_inquiry_info_type_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'INQUIRY_INFORMATION_TYPES', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igr_i_info_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,enquiry_appl_number)
             = (SELECT person_id,enquiry_appl_number
                FROM   igr_i_appl_int
                WHERE  interface_inq_appl_id = a.interface_inq_appl_id)
      WHERE  interface_inq_appl_id IN (SELECT interface_inq_appl_id
                                       FROM   igr_i_appl_int
                                       WHERE  interface_run_id = p_interface_run_id
                                       AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => p_schema,
                                   tabname => 'IGR_I_INFO_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igr_imp_004.prc_inq_info (p_interface_run_id => p_interface_run_id,
                                   p_enable_log       => p_enable_log,
                                   p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_inquiry_info_type_inc

    IF g_inquiry_char_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'INQUIRY_CHARACTERISTICS', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igr_i_char_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,enquiry_appl_number)
             = (SELECT person_id,enquiry_appl_number
                FROM   igr_i_appl_int
                WHERE  interface_inq_appl_id = a.interface_inq_appl_id)
      WHERE  interface_inq_appl_id IN (SELECT interface_inq_appl_id
                                       FROM   igr_i_appl_int
                                       WHERE  interface_run_id = p_interface_run_id
                                       AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => p_schema,
                                   tabname => 'IGR_I_CHAR_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igr_imp_004.prc_inq_char (p_interface_run_id => p_interface_run_id,
                                   p_enable_log       => p_enable_log,
                                   p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_inquiry_char_inc

  END prc_ad_category;


  PROCEDURE del_cmpld_rct_records ( p_source_type_id IN NUMBER,
                                    p_interface_run_id  IN NUMBER  ) AS
  /*************************************************************
   Created By : rbezawad
   Date Created By :  27-Feb-05
   Purpose : Procedure is used to delete the records from the recruitment interface tables, which are processed successfully.
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF g_inquiry_acad_int_inc THEN
      DELETE FROM igr_i_lines_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_inquiry_acad_int_inc

    IF g_inquiry_pkg_itm_inc THEN
      DELETE FROM igr_i_pkg_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_inquiry_pkg_itm_inc

    IF g_inquiry_info_type_inc THEN
      DELETE FROM igr_i_info_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_inquiry_info_type_inc

    IF g_inquiry_char_inc THEN
      DELETE FROM igr_i_char_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_inquiry_char_inc

    IF g_inquiry_dtls_inc THEN
      DELETE FROM igr_i_appl_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_inquiry_dtls_inc

  END del_cmpld_rct_records;


END IGR_IMP_002;

/
