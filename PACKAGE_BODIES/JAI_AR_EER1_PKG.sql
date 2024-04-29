--------------------------------------------------------
--  DDL for Package Body JAI_AR_EER1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_EER1_PKG" AS
/*$Header: jai_ar_eer1_pkg.plb 120.2.12010000.2 2008/11/19 11:41:35 mbremkum ship $*/
/*------------------------------------------------------------------------------------------
FILENAME: jai_ar_eer1_pkg.plb
CHANGE HISTORY:

Sl. YYYY/MM/DD  Author and Details
------------------------------------------------------------------------------------------
1   2007/01/04  CSahoo BUG#5745509 . File Version 120.2
								Forward porting of BUG#5637136. The table and view names were changed.
---------------------------------------------------------------------------------------------*/


  lv_ecc                       varchar2(15);

  PROCEDURE generate_flat_file
  (
    p_err_buf OUT NOCOPY VARCHAR2,
    p_ret_code OUT NOCOPY NUMBER,
    p_organization_id     IN  NUMBER,
    p_location_id         IN  NUMBER,
    pv_start_date          IN  VARCHAR2,
    pv_end_date            IN  VARCHAR2,
    p_registration_number IN  VARCHAR2,
    p_operating_unit      IN  NUMBER,
    p_auth_sign           IN VARCHAR2,
    p_place               IN VARCHAR2,
    p_file_path           IN VARCHAR2,
    p_filename            IN VARCHAR2,
    p_action_flg          IN VARCHAR2 DEFAULT 'N'
  )
  IS
   p_start_date DATE ;
   p_end_date   DATE ;

    CURSOR cur_ecc(p_organization_id IN NUMBER, p_location_id IN NUMBER)
    IS
      SELECT substr(ec_code,1,15) FROM JAI_CMN_INVENTORY_ORGS
      WHERE  organization_id = p_organization_id
      AND location_id = p_location_id;

  BEGIN

    p_start_date    := fnd_date.canonical_to_date(pv_start_date);
    p_end_date      := fnd_date.canonical_to_date(pv_end_date);

    jai_ar_eer1_pkg.p_action := p_action_flg;
    openFile(p_file_path,p_filename);

    OPEN  cur_ecc( p_organization_id, p_location_id);
    FETCH cur_ecc into lv_ecc;
    CLOSE cur_ecc;  -- for registration number

    IF p_action_flg = 'Y'  THEN
      FND_FILE.put_line(FND_FILE.log, 'Cetsh Header') ;
      create_ceth_header;
    END IF;

    FND_FILE.put_line(FND_FILE.log, 'Cetsh Dtl') ;

    populate_ceth_wise_details(
      p_organization_id   =>  p_organization_id,
      p_location_id       =>  p_location_id,
      p_start_date        =>  p_start_date,
      p_end_date          =>  p_end_date
     );

    IF p_action_flg = 'Y'  THEN
      FND_FILE.put_line(FND_FILE.log, 'Duty Header') ;
      create_duty_header;
    END IF;

    FND_FILE.put_line(FND_FILE.log, 'Duty Detail') ;
    populate_duty_paid_details(
      p_end_date          =>  p_end_date,
      p_location_id       =>  p_location_id,
      p_organization_id   =>  p_organization_id,
      p_start_date        =>  p_start_date);


    IF p_action_flg = 'Y'  THEN
      FND_FILE.put_line(FND_FILE.log, 'Input Header') ;
      create_input_header;
    END IF;

    FND_FILE.put_line(FND_FILE.log, 'Input Detail') ;
    populate_input_details
    ( p_end_date          =>  p_end_date,
      p_location_id       =>  p_location_id,
      p_organization_id   =>  p_organization_id,
      p_start_date        =>  p_start_date);

    IF p_action_flg = 'Y'  THEN
      FND_FILE.put_line(FND_FILE.log, 'Cenvat Header') ;
      create_cenvat_header;
    END IF;

    FND_FILE.put_line(FND_FILE.log, 'Cenavt Detail') ;
    populate_cenvat_credit_details (
      p_end_date            =>  p_end_date,
      p_location_id         =>  p_location_id,
      p_operating_unit      =>  p_operating_unit,
      p_organization_id     =>  p_organization_id,
      p_registration_number =>  p_registration_number,
      p_start_date          =>  p_start_date);


    IF p_action_flg = 'Y'  THEN
      FND_FILE.put_line(FND_FILE.log, 'Payment Header') ;
      create_payment_header;
    END IF;

    FND_FILE.put_line(FND_FILE.log, 'Payment Detail') ;
    populate_payment_details
     (p_start_date        =>  p_start_date) ;

    IF p_action_flg = 'Y'  THEN
     FND_FILE.put_line(FND_FILE.log, 'SAM Header') ;
      create_sam_header;
    END IF;

    FND_FILE.put_line(FND_FILE.log, 'SAM Detail') ;
    populate_sam_details
     (
        p_organization_id =>  p_organization_id,
        p_location_id     =>  p_location_id,
        p_start_date      =>  p_start_date ,
        p_end_date        =>  p_end_date,
        p_auth_sign       =>  p_auth_sign  ,
        p_place           =>  p_place
     ) ;

    FND_FILE.put_line(FND_FILE.log, 'Close File') ;

    closeFile;
    FND_FILE.put_line(FND_FILE.log, 'End ') ;

  -- Body for Generate Returns

  END generate_flat_file;


  -- Procedure to open a file for writing

  PROCEDURE openFile(
    p_directory IN VARCHAR2,
    p_filename IN VARCHAR2
    )
  IS

  BEGIN

    v_filehandle := UTL_FILE.fopen(p_directory, p_filename, 'W',32767);

    v_utl_file_dir  := p_directory;
    v_utl_file_name := p_filename;

  END openFile;

  -- Procedure to close the file

  PROCEDURE closeFile
  IS
  BEGIN
    UTL_FILE.fclose(v_filehandle);
  END closeFile;


  -- Procedure to Create the CETH header in the file

  PROCEDURE create_ceth_header
  IS
  BEGIN
    UTL_FILE.PUT_LINE(v_filehandle, ' ' ) ;

    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD('Record Header', sq_len_50, v_quart_pad) || v_pad_char ||
      LPAD('RT', sq_len_2, v_quart_pad)             || v_pad_char ||
      LPAD('Reg No', sq_len_15, v_quart_pad)        || v_pad_char ||
      LPAD('YM', sq_len_6, v_quart_pad)             || v_pad_char ||
      LPAD('RN', sq_len_3, v_quart_pad)             || v_pad_char ||
      LPAD('DP', sq_len_2, v_quart_pad)             || v_pad_char ||
      LPAD('CETH', sq_len_8, v_quart_pad)           || v_pad_char ||
      LPAD('CTSH', sq_len_8, v_quart_pad)           || v_pad_char ||
      LPAD('UQC', sq_len_8, v_quart_pad)            || v_pad_char ||
      LPAD('QTY MNF', sq_len_15, v_quart_pad)       || v_pad_char ||
      LPAD('QTY CLR TYPE', sq_len_15, v_quart_pad)  || v_pad_char ||
      LPAD('QTY CLR', sq_len_15, v_quart_pad)       || v_pad_char ||
      LPAD('ASSESS VAL', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('NOTF1', sq_len_8, v_quart_pad)          || v_pad_char ||
      LPAD('NOTF SNO1', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('NOTF2', sq_len_8, v_quart_pad)          || v_pad_char ||
      LPAD('NOTF SNO2', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('NOTF3', sq_len_8, v_quart_pad)          || v_pad_char ||
      LPAD('NOTF SNO3', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('NOTF4', sq_len_8, v_quart_pad)          || v_pad_char ||
      LPAD('NOTF SNO4', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('NOTF5', sq_len_8, v_quart_pad)          || v_pad_char ||
      LPAD('NOTF SNO5', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('NOTF6', sq_len_8, v_quart_pad)          || v_pad_char ||
      LPAD('NOTF SNO6', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('ADV CENVAT', sq_len_11, v_quart_pad)    || v_pad_char ||
      LPAD('SP CENVAT', sq_len_11, v_quart_pad)     || v_pad_char ||
      LPAD('DP CENVAT', sq_len_15, v_quart_pad)     || v_pad_char ||
      LPAD('PA CEN', sq_len_7, v_quart_pad)         || v_pad_char ||
      LPAD('ADV SED', sq_len_11, v_quart_pad)       || v_pad_char ||
      LPAD('SP SED', sq_len_11, v_quart_pad)        || v_pad_char ||
      LPAD('DP SED', sq_len_15, v_quart_pad)        || v_pad_char ||
      LPAD('PA SED', sq_len_7, v_quart_pad)         || v_pad_char ||
      LPAD('ADV AED GSI', sq_len_11, v_quart_pad)   || v_pad_char ||
      LPAD('SP AED GSI', sq_len_11, v_quart_pad)    || v_pad_char ||
      LPAD('DP AED GSI', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('PA GSI', sq_len_7, v_quart_pad)         || v_pad_char ||
      LPAD('ADV NCCD', sq_len_11, v_quart_pad)      || v_pad_char ||
      LPAD('SP NCCD', sq_len_11, v_quart_pad)       || v_pad_char ||
      LPAD('DP NCCD', sq_len_15, v_quart_pad)       || v_pad_char ||
      LPAD('PA NCCD', sq_len_7, v_quart_pad)        || v_pad_char ||
      LPAD('ADV AED TTA', sq_len_11, v_quart_pad)   || v_pad_char ||
      LPAD('SP AED TTA', sq_len_11, v_quart_pad)    || v_pad_char ||
      LPAD('DP AED TTA', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('PA TTA', sq_len_7, v_quart_pad)         || v_pad_char ||
      LPAD('ADV AED PMT', sq_len_11, v_quart_pad)   || v_pad_char ||
      LPAD('SP AED PMT', sq_len_11, v_quart_pad)    || v_pad_char ||
      LPAD('DP AED PMT', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('PA PMT', sq_len_7, v_quart_pad)         || v_pad_char ||
      LPAD('ADV SAED', sq_len_11, v_quart_pad)      || v_pad_char ||
      LPAD('SP SAED', sq_len_11, v_quart_pad)       || v_pad_char ||
      LPAD('DP SAED', sq_len_15, v_quart_pad)       || v_pad_char ||
      LPAD('PA SAED', sq_len_7, v_quart_pad)        || v_pad_char ||
      LPAD('ADV ADE', sq_len_11, v_quart_pad)       || v_pad_char ||
      LPAD('SP ADE', sq_len_11, v_quart_pad)        || v_pad_char ||
      LPAD('DP ADE', sq_len_15, v_quart_pad)        || v_pad_char ||
      LPAD('PA ADE', sq_len_7, v_quart_pad)         || v_pad_char ||
      LPAD('ADV ADET', sq_len_11, v_quart_pad)      || v_pad_char ||
      LPAD('SP ADET', sq_len_11, v_quart_pad)       || v_pad_char ||
      LPAD('DP ADET', sq_len_15, v_quart_pad)       || v_pad_char ||
      LPAD('PA ADET', sq_len_7, v_quart_pad)        || v_pad_char ||
      LPAD('ADV CESS', sq_len_11, v_quart_pad)      || v_pad_char ||
      LPAD('SP CESS', sq_len_11, v_quart_pad)       || v_pad_char ||
      LPAD('DP CESS', sq_len_15, v_quart_pad)       || v_pad_char ||
      LPAD('PA CESS', sq_len_7, v_quart_pad)        || v_pad_char ||
      LPAD('ADV EDUCES', sq_len_11, v_quart_pad)    || v_pad_char ||
      LPAD('SP EDUCES', sq_len_11, v_quart_pad)     || v_pad_char ||
      LPAD('DP EDUCES', sq_len_15, v_quart_pad)     || v_pad_char ||
      LPAD('PA EC', sq_len_7, v_quart_pad)
      );

    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD(v_underline_char, sq_len_50, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_2,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_6,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_3,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_2,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_11, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char)
      );

  END create_ceth_header;

      -- Procedure to create DUTY PAID headers

  PROCEDURE create_duty_header IS
  BEGIN
    UTL_FILE.PUT_LINE(v_filehandle, ' ' ) ;

    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD('Record Header', sq_len_50, v_quart_pad) || v_pad_char ||
      LPAD('RT', sq_len_2, v_quart_pad)             || v_pad_char ||
      LPAD('Reg No', sq_len_15, v_quart_pad)        || v_pad_char ||
      LPAD('YM', sq_len_6, v_quart_pad)             || v_pad_char ||
      LPAD('RN', sq_len_3, v_quart_pad)             || v_pad_char ||
      LPAD('DP', sq_len_2, v_quart_pad)             || v_pad_char ||
      LPAD('DP CR CEN', sq_len_15, v_quart_pad)     || v_pad_char ||
      LPAD('DP CU CEN', sq_len_15, v_quart_pad)     || v_pad_char ||
      LPAD('CN CEN', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('CD CEN', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('BC CEN', sq_len_7, v_quart_pad)         || v_pad_char ||
      LPAD('DP TOT CEN', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('DP CR SED', sq_len_15, v_quart_pad)     || v_pad_char ||
      LPAD('DP CU SED', sq_len_15, v_quart_pad)     || v_pad_char ||
      LPAD('CN SED', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('CD SED', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('BC SED', sq_len_7, v_quart_pad)         || v_pad_char ||
      LPAD('DP TOT SED', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('DP CR AEDGSI', sq_len_15, v_quart_pad)  || v_pad_char ||
      LPAD('DP CU AEDGSI', sq_len_15, v_quart_pad)  || v_pad_char ||
      LPAD('CN AEDGSI', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('CD AEDGSI', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('BC AGSI', sq_len_7, v_quart_pad)        || v_pad_char ||
      LPAD('DP TOT AEDGSI', sq_len_15, v_quart_pad) || v_pad_char ||
      LPAD('DP CR NCCD', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('DP CU NCCD', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('CN NCCD', sq_len_10, v_quart_pad)       || v_pad_char ||
      LPAD('CD NCCD', sq_len_10, v_quart_pad)       || v_pad_char ||
      LPAD('BC NCCD', sq_len_7, v_quart_pad)        || v_pad_char ||
      LPAD('DP TOT NCCD', sq_len_15, v_quart_pad)   || v_pad_char ||
      LPAD('DP CR AEDTTA', sq_len_15, v_quart_pad)  || v_pad_char ||
      LPAD('DP CU AEDTTA', sq_len_15, v_quart_pad)  || v_pad_char ||
      LPAD('CN AEDTTA', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('CD AEDTTA', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('BC ATTA', sq_len_7, v_quart_pad)        || v_pad_char ||
      LPAD('DP TOT AEDTTA', sq_len_15, v_quart_pad) || v_pad_char ||
      LPAD('DP CR AEDPMT', sq_len_15, v_quart_pad)  || v_pad_char ||
      LPAD('DP CU AEDPMT', sq_len_15, v_quart_pad)  || v_pad_char ||
      LPAD('CN AEDPMT', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('CD AEDPMT', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('BC APMT', sq_len_7, v_quart_pad)        || v_pad_char ||
      LPAD('DP TOT AEDPMT', sq_len_15, v_quart_pad) || v_pad_char ||
      LPAD('DP CR SAED', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('DP CU SAED', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('CN SAED', sq_len_10, v_quart_pad)       || v_pad_char ||
      LPAD('CD SAED', sq_len_10, v_quart_pad)       || v_pad_char ||
      LPAD('BC SAED', sq_len_7, v_quart_pad)        || v_pad_char ||
      LPAD('DP TOT SAED', sq_len_15, v_quart_pad)   || v_pad_char ||
      LPAD('DP CR ADE', sq_len_15, v_quart_pad)     || v_pad_char ||
      LPAD('DP CU ADE', sq_len_15, v_quart_pad)     || v_pad_char ||
      LPAD('CN ADE', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('CD ADE', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('BC ADE', sq_len_7, v_quart_pad)         || v_pad_char ||
      LPAD('DP TOT ADE', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('DP CR ADET', sq_len_15, v_quart_pad)    || v_pad_char ||
      LPAD('DP CU ADET', sq_len_15, v_quart_pad)
      );

    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD(v_underline_char, sq_len_50, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_2,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_6,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_3,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_2,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char)
      );

  END create_duty_header;

  -- Procedure to create the Input Details Header

  PROCEDURE create_input_header
  IS
  BEGIN
    UTL_FILE.PUT_LINE(v_filehandle, ' ' ) ;

    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD('Record Header', sq_len_50, v_quart_pad) || v_pad_char ||
      LPAD('RT', sq_len_2, v_quart_pad)             || v_pad_char ||
      LPAD('Reg No', sq_len_15, v_quart_pad)        || v_pad_char ||
      LPAD('YM', sq_len_6, v_quart_pad)             || v_pad_char ||
      LPAD('RN', sq_len_3, v_quart_pad)             || v_pad_char ||
      LPAD('CETH', sq_len_8, v_quart_pad)           || v_pad_char ||
      LPAD('CTSH', sq_len_8, v_quart_pad)           || v_pad_char ||
      LPAD('UQC', sq_len_8, v_quart_pad)            || v_pad_char ||
      LPAD('TOT QTY RECD', sq_len_15, v_quart_pad)  || v_pad_char ||
      LPAD('VAL RECD', sq_len_15, v_quart_pad)      || v_pad_char ||
      LPAD('NOTF', sq_len_8, v_quart_pad)           || v_pad_char ||
      LPAD('NOTF SNO', sq_len_10, v_quart_pad)
      );

    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD(v_underline_char, sq_len_50, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_2,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_6,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_3,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_8,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char)
      );

  END create_input_header;

     -- Procedure to create CENVAT credit headers

  PROCEDURE create_cenvat_header
  IS
  BEGIN
    UTL_FILE.PUT_LINE(v_filehandle, ' ' ) ;

    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD('Record Header', sq_len_50, v_quart_pad) || v_pad_char ||
      LPAD('RT', sq_len_2, v_quart_pad)             || v_pad_char ||
      LPAD('Reg No', sq_len_15, v_quart_pad)        || v_pad_char ||
      LPAD('YM', sq_len_6, v_quart_pad)             || v_pad_char ||
      LPAD('RN', sq_len_3, v_quart_pad)             || v_pad_char ||
      LPAD('DP', sq_len_2, v_quart_pad)             || v_pad_char ||
      LPAD('OP BAL CEN', sq_len_13, v_quart_pad)    || v_pad_char ||
      LPAD('CR IN CEN', sq_len_13, v_quart_pad)     || v_pad_char ||
      LPAD('CR IND CEN', sq_len_13, v_quart_pad)    || v_pad_char ||
      LPAD('CR CA CEN', sq_len_13, v_quart_pad)     || v_pad_char ||
      LPAD('CR SE CEN', sq_len_13, v_quart_pad)     || v_pad_char ||
      LPAD('CR TOT CEN', sq_len_13, v_quart_pad)    || v_pad_char ||
      LPAD('CR UT CEN', sq_len_13, v_quart_pad)     || v_pad_char ||
      LPAD('CR UIC CEN', sq_len_13, v_quart_pad)    || v_pad_char ||
      LPAD('CR UDS CEN', sq_len_13, v_quart_pad)    || v_pad_char ||
      LPAD('CL BAL CEN', sq_len_13, v_quart_pad)    || v_pad_char ||
      LPAD('OP BAL ATTA', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR IN ATTA', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR IND ATTA', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR CA ATTA', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR SE ATTA', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR TOT ATTA', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UT ATTA', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR UIC ATTA', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UDS ATTA', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CL BAL ATTA', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('OP BAL APMT', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR IN APMT', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR IND APMT', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR CA APMT', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR SE APMT', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR TOT APMT', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UT APMT', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR UIC APMT', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UDS APMT', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CL BAL APMT', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('OP BAL NCCD', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR IN NCCD', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR IND NCCD', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR CA NCCD', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR SE NCCD', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR TOT NCCD', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UT NCCD', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR UIC NCCD', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UDS NCCD', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CL BAL NCCD', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('OP BAL ADET', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR IN ADET', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR IND ADET', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR CA ADET', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR SE ADET', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR TOT ADET', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UT ADET', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR UIC ADET', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UDS ADET', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CL BAL ADET', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('OP BAL ECES', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR IN ECES', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR IND ECES', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR CA ECES', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR SE ECES', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR TOT ECES', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UT ECES', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR UIC ECES', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UDS ECES', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CL BAL ECES', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('OP BAL ST', sq_len_12, v_quart_pad)     || v_pad_char ||
      LPAD('CR IN ST', sq_len_12, v_quart_pad)      || v_pad_char ||
      LPAD('CR IND ST', sq_len_12, v_quart_pad)     || v_pad_char ||
      LPAD('CR CA ST', sq_len_12, v_quart_pad)      || v_pad_char ||
      LPAD('CR SE ST', sq_len_12, v_quart_pad)      || v_pad_char ||
      LPAD('CR TOT ST', sq_len_12, v_quart_pad)     || v_pad_char ||
      LPAD('CR UT ST', sq_len_12, v_quart_pad)      || v_pad_char ||
      LPAD('CR UIC ST', sq_len_12, v_quart_pad)     || v_pad_char ||
      LPAD('CR UDS ST', sq_len_12, v_quart_pad)     || v_pad_char ||
      LPAD('CL BAL ST', sq_len_12, v_quart_pad)     || v_pad_char ||
      LPAD('OP BAL STEC', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR IN STEC', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR IND STEC', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR CA STEC', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR SE STEC', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR TOT STEC', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UT STEC', sq_len_12, v_quart_pad)    || v_pad_char ||
      LPAD('CR UIC STEC', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CR UDS STEC', sq_len_12, v_quart_pad)   || v_pad_char ||
      LPAD('CL BAL STEC', sq_len_12, v_quart_pad)
      );

    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD(v_underline_char, sq_len_50, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_2,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_6,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_3,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_2,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_12, v_underline_char)
      );

   END create_cenvat_header ;

       -- Procedure to create PAYMENT Header

  PROCEDURE create_payment_header
  IS
  BEGIN
    UTL_FILE.PUT_LINE(v_filehandle, ' ' ) ;

    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD('Record Header', sq_len_50, v_quart_pad) || v_pad_char ||
      LPAD('RT', sq_len_2, v_quart_pad)             || v_pad_char ||
      LPAD('Reg No', sq_len_15, v_quart_pad)        || v_pad_char ||
      LPAD('YM', sq_len_6, v_quart_pad)             || v_pad_char ||
      LPAD('RN', sq_len_3, v_quart_pad)             || v_pad_char ||
      LPAD('ARR R8 CU', sq_len_13, v_quart_pad)     || v_pad_char ||
      LPAD('ARR R8 CR', sq_len_13, v_quart_pad)     || v_pad_char ||
      LPAD('ARR R8 CN', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('ARR R8 CD', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('AR R8BC', sq_len_7, v_quart_pad)        || v_pad_char ||
      LPAD('ARR R8 SRCNO', sq_len_40, v_quart_pad)  || v_pad_char ||
      LPAD('ARR R8 SDT', sq_len_10, v_quart_pad)    || v_pad_char ||
      LPAD('ARR CU', sq_len_13, v_quart_pad)        || v_pad_char ||
      LPAD('ARR CR', sq_len_13, v_quart_pad)        || v_pad_char ||
      LPAD('ARR CN', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('ARR CD', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('ARR BC', sq_len_7, v_quart_pad)         || v_pad_char ||
      LPAD('ARR SRCNO', sq_len_40, v_quart_pad)     || v_pad_char ||
      LPAD('ARR SDT', sq_len_10, v_quart_pad)       || v_pad_char ||
      LPAD('INT R8 CU', sq_len_13, v_quart_pad)     || v_pad_char ||
      LPAD('INT R8 CR', sq_len_13, v_quart_pad)     || v_pad_char ||
      LPAD('INT R8 CN', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INT R8 CD', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('IN R8BC', sq_len_7, v_quart_pad)        || v_pad_char ||
      LPAD('INT R8 SRCNO', sq_len_40, v_quart_pad)  || v_pad_char ||
      LPAD('INT R8 SDT', sq_len_10, v_quart_pad)    || v_pad_char ||
      LPAD('INT CU', sq_len_13, v_quart_pad)        || v_pad_char ||
      LPAD('INT CR', sq_len_13, v_quart_pad)        || v_pad_char ||
      LPAD('INT CN', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('INT CD', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('IN BC', sq_len_7, v_quart_pad)          || v_pad_char ||
      LPAD('INT SRCNO', sq_len_40, v_quart_pad)     || v_pad_char ||
      LPAD('INT SDT', sq_len_10, v_quart_pad)       || v_pad_char ||
      LPAD('MIS CU', sq_len_13, v_quart_pad)        || v_pad_char ||
      LPAD('MIS CR', sq_len_13, v_quart_pad)        || v_pad_char ||
      LPAD('MIS CN', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('MIS CD', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('MI BC', sq_len_7, v_quart_pad)          || v_pad_char ||
      LPAD('MIS SRCNO', sq_len_40, v_quart_pad)     || v_pad_char ||
      LPAD('MIS SDT', sq_len_10, v_quart_pad)
      );

    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD(v_underline_char, sq_len_50, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_2,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_6,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_3,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_40, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_40, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_40, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_40, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_13, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_7,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_40, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char)
      );

  END create_payment_header;


       -- Procedure to create SELF ASSESSMENT MEMORANDUM headers

  PROCEDURE create_sam_header IS
  BEGIN
    UTL_FILE.PUT_LINE(v_filehandle, ' ' ) ;

    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD('Record Header', sq_len_50, v_quart_pad) || v_pad_char ||
      LPAD('RT', sq_len_2, v_quart_pad)             || v_pad_char ||
      LPAD('Reg No', sq_len_15, v_quart_pad)        || v_pad_char ||
      LPAD('YM', sq_len_6, v_quart_pad)             || v_pad_char ||
      LPAD('RN', sq_len_3, v_quart_pad)             || v_pad_char ||
      LPAD('TR6 TOT AMT', sq_len_15, v_quart_pad)   || v_pad_char ||
      LPAD('INV ISSF1', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INV ISST1', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INV ISSF2', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INV ISST2', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INV ISSF3', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INV ISST3', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INV ISSF4', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INV ISST4', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INV ISSF5', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INV ISST5', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INV ISSF6', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('INV ISST6', sq_len_10, v_quart_pad)     || v_pad_char ||
      LPAD('REMARKS', sq_len_255, v_quart_pad)      || v_pad_char ||
      LPAD('PLACE', sq_len_20, v_quart_pad)         || v_pad_char ||
      LPAD('DT FIL', sq_len_10, v_quart_pad)        || v_pad_char ||
      LPAD('NAME AUTH SIGN', sq_len_40, v_quart_pad)
      );


    UTL_FILE.PUT_LINE(v_filehandle,
      LPAD(v_underline_char, sq_len_50, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_2,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_6,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_3,  v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_15, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_255,v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_20, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_10, v_underline_char) || v_pad_char ||
      LPAD(v_underline_char, sq_len_40, v_underline_char)
      );

  END create_sam_header;


    -- Function to create a string with the data for appropriate formatting

  FUNCTION format_action(f_field_name varchar2, f_len_field number, f_action varchar2, f_last_flag varchar2 DEFAULT 'N')
  RETURN varchar2 IS
    v_final_str varchar2(2000);
  BEGIN
    IF f_action = 'Y' THEN
      v_final_str := LPAD(nvl(substr(f_field_name,1,f_len_field),v_pad_char), f_len_field, v_quart_pad) || v_pad_char;
    ELSE
      v_final_str := v_append || substr(f_field_name,1,f_len_field) || v_append ;

      IF f_last_flag = 'N' THEN
        v_final_str := v_final_str || v_delimeter;
      END IF ;
    END IF;
    RETURN v_final_str;
  END format_action;

    -- The Records

  PROCEDURE create_ceth_details (
    p_record_header           varchar2,
    p_rt_type                 varchar2,
    p_ecc                     varchar2,
    p_yyyymm                  number,
    p_return_no               varchar2,
    p_data_prd_type           varchar2,
    p_ceth                    varchar2,
    p_ctsh                    varchar2,
    p_uqc                     varchar2,
    p_qty_mnf                 number,
    p_qty_clr_type            varchar2,
    p_qty_clr                 number,
    p_ass_val                 number,
    p_notf_no_1               varchar2,
    p_notf_sno_1              varchar2,
    p_notf_no_2               varchar2,
    p_notf_sno_2              varchar2,
    p_notf_no_3               varchar2,
    p_notf_sno_3              varchar2,
    p_notf_no_4               varchar2,
    p_notf_sno_4              varchar2,
    p_notf_no_5               varchar2,
    p_notf_sno_5              varchar2,
    p_notf_no_6               varchar2,
    p_notf_sno_6              varchar2,
    p_duty_rate_adv_cenvat    number,
    p_duty_rate_sp_cenvat     number,
    p_duty_payable_cenvat     number,
    p_pa_no_cenvat            number,
    p_duty_rate_adv_sed       number,
    p_duty_rate_sp_sed        number,
    p_duty_payable_sed        number,
    p_pa_no_sed               number,
    p_duty_rate_adv_aed_gsi   number,
    p_duty_rate_sp_aed_gsi    number,
    p_duty_payable_aed_gsi    number,
    p_pa_no_aed_gsi           number,
    p_duty_rate_adv_nccd      number,
    p_duty_rate_sp_nccd       number,
    p_duty_payable_nccd       number,
    p_pa_no_nccd              number,
    p_duty_rate_adv_aed_tta   number,
    p_duty_rate_sp_aed_tta    number,
    p_duty_payable_aed_tta    number,
    p_pa_no_aed_tta           number,
    p_duty_rate_adv_aed_pmt   number,
    p_duty_rate_sp_aed_pmt    number,
    p_duty_payable_aed_pmt    number,
    p_pa_no_aed_pmt           number,
    p_duty_rate_adv_saed      number,
    p_duty_rate_sp_saed       number,
    p_duty_payable_saed       number,
    p_pa_no_saed              number,
    p_duty_rate_adv_ade       number,
    p_duty_rate_sp_ade        number,
    p_duty_payable_ade        number,
    p_pa_no_ade               number,
    p_duty_rate_adv_adet      number,
    p_duty_rate_sp_adet       number,
    p_duty_payable_adet       number,
    p_pa_no_adet              number,
    p_duty_rate_adv_cess      number,
    p_duty_rate_sp_cess       number,
    p_duty_payable_cess       number,
    p_pa_no_cess              number,
    p_duty_rate_adv_edu_cess  number,
    p_duty_rate_sp_edu_cess   number,
    p_duty_payable_edu_cess   number,
    p_pa_no_edu_cess          number
    )

  IS
  BEGIN

    p_str :=          format_action( p_record_header           ,sq_len_50, p_action);
    p_str := p_str || format_action( p_rt_type                 ,sq_len_2,  p_action);
    p_str := p_str || format_action( p_ecc                     ,sq_len_15, p_action);
    p_str := p_str || format_action( p_yyyymm                  ,sq_len_6,  p_action);
    p_str := p_str || format_action( p_return_no               ,sq_len_3,  p_action);
    p_str := p_str || format_action( p_data_prd_type           ,sq_len_2,  p_action);
    p_str := p_str || format_action( p_ceth                    ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_ctsh                    ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_uqc                     ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_qty_mnf                 ,sq_len_15, p_action);
    p_str := p_str || format_action( p_qty_clr_type            ,sq_len_15, p_action);
    p_str := p_str || format_action( p_qty_clr                 ,sq_len_15, p_action);
    p_str := p_str || format_action( p_ass_val                 ,sq_len_15, p_action);
    p_str := p_str || format_action( p_notf_no_1               ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_notf_sno_1              ,sq_len_10, p_action);
    p_str := p_str || format_action( p_notf_no_2               ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_notf_sno_2              ,sq_len_10, p_action);
    p_str := p_str || format_action( p_notf_no_3               ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_notf_sno_3              ,sq_len_10, p_action);
    p_str := p_str || format_action( p_notf_no_4               ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_notf_sno_4              ,sq_len_10, p_action);
    p_str := p_str || format_action( p_notf_no_5               ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_notf_sno_5              ,sq_len_10, p_action);
    p_str := p_str || format_action( p_notf_no_6               ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_notf_sno_6              ,sq_len_10, p_action);
    p_str := p_str || format_action( p_duty_rate_adv_cenvat    ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_rate_sp_cenvat     ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_payable_cenvat     ,sq_len_15, p_action);
    p_str := p_str || format_action( p_pa_no_cenvat            ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_rate_adv_sed       ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_rate_sp_sed        ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_payable_sed        ,sq_len_15, p_action);
    p_str := p_str || format_action( p_pa_no_sed               ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_rate_adv_aed_gsi   ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_rate_sp_aed_gsi    ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_payable_aed_gsi    ,sq_len_15, p_action);
    p_str := p_str || format_action( p_pa_no_aed_gsi           ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_rate_adv_nccd      ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_rate_sp_nccd       ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_payable_nccd       ,sq_len_15, p_action);
    p_str := p_str || format_action( p_pa_no_nccd              ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_rate_adv_aed_tta   ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_rate_sp_aed_tta    ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_payable_aed_tta    ,sq_len_15, p_action);
    p_str := p_str || format_action( p_pa_no_aed_tta           ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_rate_adv_aed_pmt   ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_rate_sp_aed_pmt    ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_payable_aed_pmt    ,sq_len_15, p_action);
    p_str := p_str || format_action( p_pa_no_aed_pmt           ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_rate_adv_saed      ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_rate_sp_saed       ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_payable_saed       ,sq_len_15, p_action);
    p_str := p_str || format_action( p_pa_no_saed              ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_rate_adv_ade       ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_rate_sp_ade        ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_payable_ade        ,sq_len_15, p_action);
    p_str := p_str || format_action( p_pa_no_ade               ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_rate_adv_adet      ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_rate_sp_adet       ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_payable_adet       ,sq_len_15, p_action);
    p_str := p_str || format_action( p_pa_no_adet              ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_rate_adv_cess      ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_rate_sp_cess       ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_payable_cess       ,sq_len_15, p_action);
    p_str := p_str || format_action( p_pa_no_cess              ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_rate_adv_edu_cess  ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_rate_sp_edu_cess   ,sq_len_11, p_action);
    p_str := p_str || format_action( p_duty_payable_edu_cess   ,sq_len_15, p_action);
    p_str := p_str || format_action( p_pa_no_edu_cess          ,sq_len_7,  p_action, lv_last_flag);


    UTL_FILE.PUT_LINE(v_filehandle,p_str);
    p_str:= NULL;

  END create_ceth_details;

  PROCEDURE create_duty_paid_details(
    p_record_header               varchar2,
    p_rt_type                     varchar2,
    p_ecc                         varchar2,
    p_yyyymm                      number,
    p_return_no                   varchar2,
    p_data_prd_type               varchar2,
    p_duty_paid_credit_cenvat     number,
    p_duty_paid_current_cenvat    number,
    p_challan_no_cenvat           varchar2,
    p_challan_date_cenvat         date,
    p_bank_code_cenvat            varchar2,
    p_duty_paid_total_cenvat      number,
    p_duty_paid_credit_sed        number,
    p_duty_paid_current_sed       number,
    p_challan_no_sed              varchar2,
    p_challan_date_sed            date,
    p_bank_code_sed               varchar2,
    p_duty_paid_total_sed         number,
    p_duty_paid_credit_aed_gsi    number,
    p_duty_paid_current_aed_gsi   number,
    p_challan_no_aed_gsi          varchar2,
    p_challan_date_aed_gsi        date,
    p_bank_code_aed_gsi           varchar2,
    p_duty_paid_total_aed_gsi     number,
    p_duty_paid_credit_nccd       number,
    p_duty_paid_current_nccd      number,
    p_challan_no_nccd             varchar2,
    p_challan_date_nccd           date,
    p_bank_code_nccd              varchar2,
    p_duty_paid_total_nccd        number,
    p_duty_paid_credit_aed_tta    number,
    p_duty_paid_current_aed_tta   number,
    p_challan_no_aed_tta          varchar2,
    p_challan_date_aed_tta        date,
    p_bank_code_aed_tta           varchar2,
    p_duty_paid_total_aed_tta     number,
    p_duty_paid_credit_aed_pmt    number,
    p_duty_paid_current_aed_pmt   number,
    p_challan_no_aed_pmt          varchar2,
    p_challan_date_aed_pmt        date,
    p_bank_code_aed_pmt           varchar2,
    p_duty_paid_total_aed_pmt     number,
    p_duty_paid_credit_saed       number,
    p_duty_paid_current_saed      number,
    p_challan_no_saed             varchar2,
    p_challan_date_saed           date,
    p_bank_code_saed              varchar2,
    p_duty_paid_total_saed        number,
    p_duty_paid_credit_ade        number,
    p_duty_paid_current_ade       number,
    p_challan_no_ade              varchar2,
    p_challan_date_ade            date,
    p_bank_code_ade               varchar2,
    p_duty_paid_total_ade         number,
    p_duty_paid_credit_adet       number,
    p_duty_paid_current_adet      number
    )

  IS
  BEGIN

    p_str :=          format_action( p_record_header             ,sq_len_50, p_action);
    p_str := p_str || format_action( p_rt_type                   ,sq_len_2,  p_action);
    p_str := p_str || format_action( p_ecc                       ,sq_len_15, p_action);
    p_str := p_str || format_action( p_yyyymm                    ,sq_len_6,  p_action);
    p_str := p_str || format_action( p_return_no                 ,sq_len_3,  p_action);
    p_str := p_str || format_action( p_data_prd_type             ,sq_len_2,  p_action);
    p_str := p_str || format_action( p_duty_paid_credit_cenvat   ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_current_cenvat  ,sq_len_15, p_action);
    p_str := p_str || format_action( p_challan_no_cenvat         ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_challan_date_cenvat,'DD/MM/YYYY')       ,sq_len_10, p_action);
    p_str := p_str || format_action( p_bank_code_cenvat          ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_paid_total_cenvat    ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_credit_sed      ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_current_sed     ,sq_len_15, p_action);
    p_str := p_str || format_action( p_challan_no_sed            ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_challan_date_sed ,'DD/MM/YYYY')          ,sq_len_10, p_action);
    p_str := p_str || format_action( p_bank_code_sed             ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_paid_total_sed       ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_credit_aed_gsi  ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_current_aed_gsi ,sq_len_15, p_action);
    p_str := p_str || format_action( p_challan_no_aed_gsi        ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_challan_date_aed_gsi,'DD/MM/YYYY')      ,sq_len_10, p_action);
    p_str := p_str || format_action( p_bank_code_aed_gsi         ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_paid_total_aed_gsi   ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_credit_nccd     ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_current_nccd    ,sq_len_15, p_action);
    p_str := p_str || format_action( p_challan_no_nccd           ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_challan_date_nccd,'DD/MM/YYYY')         ,sq_len_10, p_action);
    p_str := p_str || format_action( p_bank_code_nccd            ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_paid_total_nccd      ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_credit_aed_tta  ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_current_aed_tta ,sq_len_15, p_action);
    p_str := p_str || format_action( p_challan_no_aed_tta        ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_challan_date_aed_tta,'DD/MM/YYYY')      ,sq_len_10, p_action);
    p_str := p_str || format_action( p_bank_code_aed_tta         ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_paid_total_aed_tta   ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_credit_aed_pmt  ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_current_aed_pmt ,sq_len_15, p_action);
    p_str := p_str || format_action( p_challan_no_aed_pmt        ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_challan_date_aed_pmt,'DD/MM/YYYY')      ,sq_len_10, p_action);
    p_str := p_str || format_action( p_bank_code_aed_pmt         ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_paid_total_aed_pmt   ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_credit_saed     ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_current_saed    ,sq_len_15, p_action);
    p_str := p_str || format_action( p_challan_no_saed           ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_challan_date_saed,'DD/MM/YYYY')         ,sq_len_10, p_action);
    p_str := p_str || format_action( p_bank_code_saed            ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_paid_total_saed      ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_credit_ade      ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_current_ade     ,sq_len_15, p_action);
    p_str := p_str || format_action( p_challan_no_ade            ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_challan_date_ade,'DD/MM/YYYY')          ,sq_len_10, p_action);
    p_str := p_str || format_action( p_bank_code_ade             ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_duty_paid_total_ade       ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_credit_adet     ,sq_len_15, p_action);
    p_str := p_str || format_action( p_duty_paid_current_adet    ,sq_len_15, p_action, lv_last_flag);

    UTL_FILE.PUT_LINE(v_filehandle,p_str);
    p_str:= NULL;

  END  create_duty_paid_details;

  PROCEDURE create_input_details(
    p_record_header     varchar2,
    p_rt_type           varchar2,
    p_ecc               varchar2,
    p_yyyymm            number,
    p_return_no         varchar2,
    p_ceth              varchar2,
    p_ctsh              varchar2,
    p_uqc               varchar2,
    p_ln_total_qty_recd number,
    p_value_good_recd   number,
    p_notf_no           varchar2,
    p_notf_sno          varchar2)


  IS
  BEGIN
    p_str :=          format_action( p_record_header    ,sq_len_50, p_action);
    p_str := p_str || format_action( p_rt_type          ,sq_len_2,  p_action);
    p_str := p_str || format_action( p_ecc              ,sq_len_15, p_action);
    p_str := p_str || format_action( p_yyyymm           ,sq_len_6,  p_action);
    p_str := p_str || format_action( p_return_no        ,sq_len_3,  p_action);
    p_str := p_str || format_action( p_ceth             ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_ctsh             ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_uqc              ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_ln_total_qty_recd,sq_len_15, p_action);
    p_str := p_str || format_action( p_value_good_recd  ,sq_len_15, p_action);
    p_str := p_str || format_action( p_notf_no          ,sq_len_8,  p_action);
    p_str := p_str || format_action( p_notf_sno         ,sq_len_10, p_action, lv_last_flag);


    UTL_FILE.PUT_LINE(v_filehandle,p_str);
    p_str:= NULL;

  END create_input_details;

  PROCEDURE create_cenvat_details(
    p_record_header                  varchar2,
    p_rt_type                        varchar2,
    p_ecc                            varchar2,
    p_yyyymm                         number,
    p_return_no                      varchar2,
    p_data_prd_type                  varchar2,
    p_op_bal_cenvat                  number,
    p_credit_input_cenvat            number,
    p_credit_input_dlr_cenvat        number,
    p_credit_capital_cenvat          number,
    p_credit_service_cenvat          number,
    p_credit_total_cenvat            number,
    p_credit_utilised_cenvat         number,
    p_credit_utilised_ic_cenvat      number,
    p_credit_utilised_ds_cenvat      number,
    p_clos_bal_cenvat                number,
    p_op_bal_aed_tta                 number,
    p_credit_input_aed_tta           number,
    p_credit_input_dlr_aed_tta       number,
    p_credit_capital_aed_tta         number,
    p_credit_service_aed_tta         number,
    p_credit_total_aed_tta           number,
    p_credit_utilised_aed_tta        number,
    p_credit_utilised_ic_aed_tta     number,
    p_credit_utilised_ds_aed_tta     number,
    p_clos_bal_aed_tta               number,
    p_op_bal_aed_pmt                 number,
    p_credit_input_aed_pmt           number,
    p_credit_input_dlr_aed_pmt       number,
    p_credit_capital_aed_pmt         number,
    p_credit_service_aed_pmt         number,
    p_credit_total_aed_pmt           number,
    p_credit_utilised_aed_pmt        number,
    p_credit_utilised_ic_aed_pmt     number,
    p_credit_utilised_ds_aed_pmt     number,
    p_clos_bal_aed_pmt               number,
    p_op_bal_nccd                    number,
    p_credit_input_nccd              number,
    p_credit_input_dlr_nccd          number,
    p_credit_capital_nccd            number,
    p_credit_service_nccd            number,
    p_credit_total_nccd              number,
    p_credit_utilised_nccd           number,
    p_credit_utilised_ic_nccd        number,
    p_credit_utilised_ds_nccd        number,
    p_clos_bal_nccd                  number,
    p_op_bal_adet                    number,
    p_credit_input_adet              number,
    p_credit_input_dlr_adet          number,
    p_credit_capital_adet            number,
    p_credit_service_adet            number,
    p_credit_total_adet              number,
    p_credit_utilised_adet           number,
    p_credit_utilised_ic_adet        number,
    p_credit_utilised_ds_adet        number,
    p_clos_bal_adet                  number,
    p_op_bal_edu_cess                number,
    p_credit_input_edu_cess          number,
    p_credit_input_dlr_edu_cess      number,
    p_credit_capital_edu_cess        number,
    p_credit_service_edu_cess        number,
    p_credit_total_edu_cess          number,
    p_credit_utilised_edu_cess       number,
    p_credit_utilised_ic_edu_cess    number,
    p_credit_utilised_ds_edu_cess    number,
    p_clos_bal_edu_cess              number,
    p_op_bal_st                      number,
    p_credit_input_st                number,
    p_credit_input_dlr_st            number,
    p_credit_capital_st              number,
    p_credit_service_st              number,
    p_credit_total_st                number,
    p_credit_utilised_st             number,
    p_credit_utilised_ic_st          number,
    p_credit_utilised_ds_st          number,
    p_clos_bal_st                    number,
    p_op_bal_st_edu_cess             number,
    p_credit_input_st_edu_cess       number,
    p_cre_input_dlr_st_edu_cess      number,
    p_credit_capital_st_edu_cess     number,
    p_credit_service_st_edu_cess     number,
    p_credit_total_st_edu_cess       number,
    p_creln_dit_uti_st_edu_cess      number,
    p_credit_uti_ic_st_edu_cess      number,
    p_credit_uti_ds_st_edu_cess      number,
    p_clos_bal_st_edu_cess           number
    )

  IS
  BEGIN
    p_str :=          format_action( p_record_header                ,sq_len_50, p_action);
    p_str := p_str || format_action( p_rt_type                      ,sq_len_2,  p_action);
    p_str := p_str || format_action( p_ecc                          ,sq_len_15, p_action);
    p_str := p_str || format_action( p_yyyymm                       ,sq_len_6,  p_action);
    p_str := p_str || format_action( p_return_no                    ,sq_len_3,  p_action);
    p_str := p_str || format_action( p_data_prd_type                ,sq_len_2,  p_action);
    p_str := p_str || format_action( p_op_bal_cenvat                ,sq_len_13, p_action);
    p_str := p_str || format_action( p_credit_input_cenvat          ,sq_len_13, p_action);
    p_str := p_str || format_action( p_credit_input_dlr_cenvat      ,sq_len_13, p_action);
    p_str := p_str || format_action( p_credit_capital_cenvat        ,sq_len_13, p_action);
    p_str := p_str || format_action( p_credit_service_cenvat        ,sq_len_13, p_action);
    p_str := p_str || format_action( p_credit_total_cenvat          ,sq_len_13, p_action);
    p_str := p_str || format_action( p_credit_utilised_cenvat       ,sq_len_13, p_action);
    p_str := p_str || format_action( p_credit_utilised_ic_cenvat    ,sq_len_13, p_action);
    p_str := p_str || format_action( p_credit_utilised_ds_cenvat    ,sq_len_13, p_action);
    p_str := p_str || format_action( p_clos_bal_cenvat              ,sq_len_13, p_action);
    p_str := p_str || format_action( p_op_bal_aed_tta               ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_aed_tta         ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_dlr_aed_tta     ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_capital_aed_tta       ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_service_aed_tta       ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_total_aed_tta         ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_aed_tta      ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ic_aed_tta   ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ds_aed_tta   ,sq_len_12, p_action);
    p_str := p_str || format_action( p_clos_bal_aed_tta             ,sq_len_12, p_action);
    p_str := p_str || format_action( p_op_bal_aed_pmt               ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_aed_pmt         ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_dlr_aed_pmt     ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_capital_aed_pmt       ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_service_aed_pmt       ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_total_aed_pmt         ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_aed_pmt      ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ic_aed_pmt   ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ds_aed_pmt   ,sq_len_12, p_action);
    p_str := p_str || format_action( p_clos_bal_aed_pmt             ,sq_len_12, p_action);
    p_str := p_str || format_action( p_op_bal_nccd                  ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_nccd            ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_dlr_nccd        ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_capital_nccd          ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_service_nccd          ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_total_nccd            ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_nccd         ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ic_nccd      ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ds_nccd      ,sq_len_12, p_action);
    p_str := p_str || format_action( p_clos_bal_nccd                ,sq_len_12, p_action);
    p_str := p_str || format_action( p_op_bal_adet                  ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_adet            ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_dlr_adet        ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_capital_adet          ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_service_adet          ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_total_adet            ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_adet         ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ic_adet      ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ds_adet      ,sq_len_12, p_action);
    p_str := p_str || format_action( p_clos_bal_adet                ,sq_len_12, p_action);
    p_str := p_str || format_action( p_op_bal_edu_cess              ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_edu_cess        ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_dlr_edu_cess    ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_capital_edu_cess      ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_service_edu_cess      ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_total_edu_cess        ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_edu_cess     ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ic_edu_cess  ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ds_edu_cess  ,sq_len_12, p_action);
    p_str := p_str || format_action( p_clos_bal_edu_cess            ,sq_len_12, p_action);
    p_str := p_str || format_action( p_op_bal_st                    ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_st              ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_dlr_st          ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_capital_st            ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_service_st            ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_total_st              ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_st           ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ic_st        ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_utilised_ds_st        ,sq_len_12, p_action);
    p_str := p_str || format_action( p_clos_bal_st                  ,sq_len_12, p_action);
    p_str := p_str || format_action( p_op_bal_st_edu_cess           ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_input_st_edu_cess     ,sq_len_12, p_action);
    p_str := p_str || format_action( p_cre_input_dlr_st_edu_cess    ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_capital_st_edu_cess   ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_service_st_edu_cess   ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_total_st_edu_cess     ,sq_len_12, p_action);
    p_str := p_str || format_action( p_creln_dit_uti_st_edu_cess    ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_uti_ic_st_edu_cess    ,sq_len_12, p_action);
    p_str := p_str || format_action( p_credit_uti_ds_st_edu_cess    ,sq_len_12, p_action);
    p_str := p_str || format_action( p_clos_bal_st_edu_cess         ,sq_len_12, p_action, lv_last_flag);



    UTL_FILE.PUT_LINE(v_filehandle,p_str);
    p_str:= NULL;

  END create_cenvat_details;

  PROCEDURE create_payment_details(
    p_record_header              varchar2,
    p_rt_type                    varchar2,
    p_ecc                        varchar2,
    p_yyyymm                     number,
    p_return_no                  varchar2,
    p_arrear_rule8_current       number,
    p_arrear_rule8_credit        number,
    p_arrear_rule8_challan_no    varchar2,
    p_arrear_rule8_challan_date  date,
    p_arrear_rule8_bank_code     varchar2,
    p_arrear_rule8_source_no     varchar2,
    p_arrear_rule8_source_date   date,
    p_arrear_current             number,
    p_arrear_credit              number,
    p_arrear_challan_no          varchar2,
    p_arrear_challan_date        date,
    p_arrear_bank_code           varchar2,
    p_arrear_source_no           varchar2,
    p_arrear_source_date         date,
    p_int_rule8_current          number,
    p_int_rule8_credit           number,
    p_int_rule8_challan_no       varchar2,
    p_int_rule8_challan_date     date,
    p_int_rule8_bank_code        varchar2,
    p_int_rule8_source_no        varchar2,
    p_int_rule8_source_date      date,
    p_int_current                number,
    p_int_credit                 number,
    p_int_challan_no             varchar2,
    p_int_challan_date           date,
    p_int_bank_code              varchar2,
    p_int_source_no              varchar2,
    p_int_source_date            date,
    p_misc_current               number,
    p_misc_credit                number,
    p_misc_challan_no            varchar2,
    p_misc_challan_date          date,
    p_misc_bank_code             varchar2,
    p_misc_source_no             varchar2,
    p_misc_source_date           date
    )

  IS
  BEGIN
    p_str :=          format_action( p_record_header            ,sq_len_50, p_action);
    p_str := p_str || format_action( p_rt_type                  ,sq_len_2,  p_action);
    p_str := p_str || format_action( p_ecc                      ,sq_len_15, p_action);
    p_str := p_str || format_action( p_yyyymm                   ,sq_len_6,  p_action);
    p_str := p_str || format_action( p_return_no                ,sq_len_3,  p_action);
    p_str := p_str || format_action( p_arrear_rule8_current     ,sq_len_13, p_action);
    p_str := p_str || format_action( p_arrear_rule8_credit      ,sq_len_13, p_action);
    p_str := p_str || format_action( p_arrear_rule8_challan_no  ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_arrear_rule8_challan_date, 'DD/MM/YYYY'),sq_len_10, p_action);
    p_str := p_str || format_action( p_arrear_rule8_bank_code   ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_arrear_rule8_source_no   ,sq_len_40, p_action);
    p_str := p_str || format_action( to_char(p_arrear_rule8_source_date, 'DD/MM/YYYY') ,sq_len_10, p_action);
    p_str := p_str || format_action( p_arrear_current           ,sq_len_13, p_action);
    p_str := p_str || format_action( p_arrear_credit            ,sq_len_13, p_action);
    p_str := p_str || format_action( p_arrear_challan_no        ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_arrear_challan_date, 'DD/MM/YYYY')      ,sq_len_10, p_action);
    p_str := p_str || format_action( p_arrear_bank_code         ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_arrear_source_no         ,sq_len_40, p_action);
    p_str := p_str || format_action( to_char(p_arrear_source_date, 'DD/MM/YYYY')       ,sq_len_10, p_action);
    p_str := p_str || format_action( p_int_rule8_current        ,sq_len_13, p_action);
    p_str := p_str || format_action( p_int_rule8_credit         ,sq_len_13, p_action);
    p_str := p_str || format_action( p_int_rule8_challan_no     ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_int_rule8_challan_date, 'DD/MM/YYYY')   ,sq_len_10, p_action);
    p_str := p_str || format_action( p_int_rule8_bank_code      ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_int_rule8_source_no      ,sq_len_40, p_action);
    p_str := p_str || format_action( to_char(p_int_rule8_source_date, 'DD/MM/YYYY')    ,sq_len_10, p_action);
    p_str := p_str || format_action( p_int_current              ,sq_len_13, p_action);
    p_str := p_str || format_action( p_int_credit               ,sq_len_13, p_action);
    p_str := p_str || format_action( p_int_challan_no           ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_int_challan_date, 'DD/MM/YYYY')         ,sq_len_10, p_action);
    p_str := p_str || format_action( p_int_bank_code            ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_int_source_no            ,sq_len_40, p_action);
    p_str := p_str || format_action( to_char(p_int_source_date, 'DD/MM/YYYY')          ,sq_len_10, p_action);
    p_str := p_str || format_action( p_int_rule8_source_date    ,sq_len_10, p_action);
    p_str := p_str || format_action( p_misc_current             ,sq_len_13, p_action);
    p_str := p_str || format_action( p_misc_credit              ,sq_len_13, p_action);
    p_str := p_str || format_action( p_misc_challan_no          ,sq_len_10, p_action);
    p_str := p_str || format_action( to_char(p_misc_challan_date, 'DD/MM/YYYY')        ,sq_len_10, p_action);
    p_str := p_str || format_action( p_misc_bank_code           ,sq_len_7,  p_action);
    p_str := p_str || format_action( p_misc_source_no           ,sq_len_40, p_action);
    p_str := p_str || format_action( to_char(p_misc_source_date, 'DD/MM/YYYY')         ,sq_len_10, p_action, lv_last_flag);


    UTL_FILE.PUT_LINE(v_filehandle,p_str);
    p_str:= NULL;

  END create_payment_details;


  PROCEDURE create_sam_details(
    p_record_header     varchar2,
    p_rt_type           varchar2,
    p_ecc               varchar2,
    p_yyyymm            number,
    p_return_no         varchar2,
    p_tr6_total_amount  number,
    p_inv_issue_from1   varchar2,
    p_inv_issue_to1     varchar2,
    p_inv_issue_from2   varchar2,
    p_inv_issue_to2     varchar2,
    p_inv_issue_from3   varchar2,
    p_inv_issue_to3     varchar2,
    p_inv_issue_from4   varchar2,
    p_inv_issue_to4     varchar2,
    p_inv_issue_from5   varchar2,
    p_inv_issue_to5     varchar2,
    p_inv_issue_from6   varchar2,
    p_inv_issue_to6     varchar2,
    p_remarks           varchar2,
    p_place             varchar2,
    p_date_filing       date,
    p_name_auth_sign    varchar2
    )

  IS
  BEGIN
    p_str :=          format_action( p_record_header     ,sq_len_50, p_action);
    p_str := p_str || format_action( p_rt_type           ,sq_len_2,  p_action);
    p_str := p_str || format_action( p_ecc               ,sq_len_15, p_action);
    p_str := p_str || format_action( p_yyyymm            ,sq_len_6,  p_action);
    p_str := p_str || format_action( p_return_no         ,sq_len_3,  p_action);
    p_str := p_str || format_action( p_tr6_total_amount  ,sq_len_15, p_action);
    p_str := p_str || format_action( p_inv_issue_from1   ,sq_len_10, p_action);
    p_str := p_str || format_action( p_inv_issue_to1     ,sq_len_10, p_action);
    p_str := p_str || format_action( p_inv_issue_from2   ,sq_len_10, p_action);
    p_str := p_str || format_action( p_inv_issue_to2     ,sq_len_10, p_action);
    p_str := p_str || format_action( p_inv_issue_from3   ,sq_len_10, p_action);
    p_str := p_str || format_action( p_inv_issue_to3     ,sq_len_10, p_action);
    p_str := p_str || format_action( p_inv_issue_from4   ,sq_len_10, p_action);
    p_str := p_str || format_action( p_inv_issue_to4     ,sq_len_10, p_action);
    p_str := p_str || format_action( p_inv_issue_from5   ,sq_len_10, p_action);
    p_str := p_str || format_action( p_inv_issue_to5     ,sq_len_10, p_action);
    p_str := p_str || format_action( p_inv_issue_from6   ,sq_len_10, p_action);
    p_str := p_str || format_action( p_inv_issue_to6     ,sq_len_10, p_action);
    p_str := p_str || format_action( p_remarks           ,sq_len_255,p_action);
    p_str := p_str || format_action( p_place             ,sq_len_20, p_action);
    p_str := p_str || format_action( to_char(p_date_filing,'DD/MM/YYYY')       ,sq_len_10, p_action);
    p_str := p_str || format_action( p_name_auth_sign    ,sq_len_40, p_action, lv_last_flag);


    UTL_FILE.PUT_LINE(v_filehandle,p_str);
    p_str:= NULL;

  END create_sam_details;


  --procedure to populate the data for DUTY PAID DETAILS


  PROCEDURE populate_duty_paid_details (
    p_end_date        IN  DATE,
    p_location_id     IN  NUMBER,
    p_organization_id IN  NUMBER,
    p_start_date      IN  DATE )

  IS

    lv_record_header             varchar2(50);
    lv_rt_type                   varchar2(2);
    p_ecc                       varchar2(15);
    ln_yyyymm                    number;
    lv_return_no                 varchar2(3);
    lv_data_prd_type             varchar2(2);
    ln_duty_paid_credit_cenvat   number;
    ln_duty_paid_current_cenvat  number;
    lv_challan_no_cenvat         varchar2(10);
    ld_challan_date_cenvat       date;
    lv_bank_code_cenvat          varchar2(7);
    ln_duty_paid_total_cenvat    number;
    ln_duty_paid_credit_sed      number;
    ln_duty_paid_current_sed     number;
    lv_challan_no_sed            varchar2(10);
    ld_challan_date_sed          date;
    lv_bank_code_sed             varchar2(7);
    ln_duty_paid_total_sed       number;
    ln_duty_paid_credit_aed_gsi  number;
    ln_duty_paid_current_aed_gsi number;
    lv_challan_no_aed_gsi        varchar2(10);
    ld_challan_date_aed_gsi      date;
    lv_bank_code_aed_gsi         varchar2(7);
    ln_duty_paid_total_aed_gsi   number;
    ln_duty_paid_credit_nccd     number;
    ln_duty_paid_current_nccd    number;
    lv_challan_no_nccd           varchar2(10);
    ld_challan_date_nccd         date;
    lv_bank_code_nccd            varchar2(7);
    ln_duty_paid_total_nccd      number;
    ln_duty_paid_credit_aed_tta  number;
    ln_duty_paid_current_aed_tta number;
    lv_challan_no_aed_tta        varchar2(10);
    ld_challan_date_aed_tta      date;
    lv_bank_code_aed_tta         varchar2(7);
    ln_duty_paid_total_aed_tta   number;
    ln_duty_paid_credit_aed_pmt  number;
    ln_duty_paid_current_aed_pmt number;
    lv_challan_no_aed_pmt        varchar2(10);
    ld_challan_date_aed_pmt      date;
    lv_bank_code_aed_pmt         varchar2(7);
    ln_duty_paid_total_aed_pmt   number;
    ln_duty_paid_credit_saed     number;
    ln_duty_paid_current_saed    number;
    lv_challan_no_saed           varchar2(10);
    ld_challan_date_saed         date;
    lv_bank_code_saed            varchar2(7);
    ln_duty_paid_total_saed      number;
    ln_duty_paid_credit_ade      number;
    ln_duty_paid_current_ade     number;
    lv_challan_no_ade            varchar2(10);
    ld_challan_date_ade          date;
    lv_bank_code_ade             varchar2(7);
    ln_duty_paid_total_ade       number;
    ln_duty_paid_credit_adet     number;
    ln_duty_paid_current_adet    number;

    -- Cursor for registration number

    CURSOR get_pla_amount
    IS
      SELECT round(nvl(sum(nvl(cr_basic_ed,0) + nvl(cr_additional_ed,0) + nvl(cr_other_ed,0)),0),0)
      FROM JAI_CMN_RG_PLA_TRXS
      WHERE organization_id = p_organization_id
      AND location_id     = p_location_id
      AND trunc(creation_date)   >= p_start_date
      AND trunc(creation_date)   <= trunc(nvl(p_end_date,sysdate))
      AND TRANSACTION_SOURCE_NUM  = 91
      AND to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm ;

    CURSOR cur_other_credit
    IS
      SELECT round(sum(nvl(debit,0)),0)
      FROM JAI_CMN_RG_OTHERS
      WHERE tax_type in ( jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_cvd_edu_cess )
       AND source_type = 1
       AND source_register_id in
         ( SELECT register_id
           FROM JAI_CMN_RG_23AC_II_TRXS
           WHERE location_id           = P_Location_id
            AND organization_id        = p_Organization_id
            AND trunc(creation_date)  >= p_start_date
            AND trunc(creation_date)  <= trunc(nvl(p_end_date,sysdate))
            AND to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm
         );

    CURSOR cur_other_current IS
    SELECT round(SUM(nvl(credit,0)),0)
      FROM JAI_CMN_RG_OTHERS
     WHERE source_type=2
       AND tax_type in ( jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_cvd_edu_cess )
       AND source_register_id in ( SELECT register_id
                                     FROM JAI_CMN_RG_PLA_TRXS
                                    WHERE organization_id = p_organization_id
                                      AND location_id     = p_location_id
                                      AND trunc(creation_date)  >= p_start_date
                                      AND trunc(creation_date)  <= trunc(nvl(p_end_date,sysdate))
                                      AND TRANSACTION_SOURCE_NUM = 91
                                      AND to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm
                                  );


    CURSOR cur_dtls(
      p_location_id     IN NUMBER,
      p_organization_id IN NUMBER,
      p_start_date      IN DATE,
      p_end_date        IN DATE)
    IS
      SELECT ROUND(SUM(nvl(dr_basic_ed,0) + nvl(dr_additional_ed,0) + nvl(dr_other_ed,0)), 0) credit_utilized,
             to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') year_month
      FROM JAI_CMN_RG_23AC_II_TRXS
      WHERE location_id = p_location_id
      AND organization_id = p_organization_id
      AND trunc(creation_date) >= p_start_date
      AND trunc(creation_date) <= trunc(nvl(p_end_date,sysdate))
      group by
        to_char(creation_date, 'MM'),
        to_char(creation_date, 'YYYY')
      ORDER BY
        to_char(creation_date, 'YYYY'),
        to_char(creation_date, 'MM') ;

  BEGIN

    lv_record_header := 'DUTY_PAID_DETAIL' ;
    lv_rt_type       := 1 ;
    lv_return_no     := 1 ;
    lv_data_prd_type := 'M' ;

    FOR dtl IN cur_dtls(p_location_id, p_organization_id, p_start_date, p_end_date)

    LOOP
      ln_duty_paid_credit_cenvat  := NULL;
      ln_duty_paid_current_cenvat := NULL;
      ln_duty_paid_total_cenvat   := NULL;
      ln_yyyymm                   := NULL;
      ln_duty_paid_current_aed_gsi := NULL;
      ln_duty_paid_credit_aed_gsi := NULL;
      ln_duty_paid_total_aed_gsi  := NULL;

      ln_duty_paid_credit_cenvat := dtl.credit_utilized;  -- for credit account (CENVAT)
      ln_yyyymm                  := dtl.year_month ;

      OPEN  get_pla_amount;
      FETCH get_pla_amount INTO ln_duty_paid_current_cenvat;  -- for current account(CENVAT)
      CLOSE get_pla_amount;

      ln_duty_paid_total_cenvat := round(nvl(ln_duty_paid_credit_cenvat,0) + nvl(ln_duty_paid_current_cenvat, 0)) ;

      OPEN cur_other_credit;
      FETCH cur_other_credit INTO ln_duty_paid_credit_aed_gsi;
      CLOSE cur_other_credit;

      OPEN  cur_other_current;
      FETCH cur_other_current INTO ln_duty_paid_current_aed_gsi;
      CLOSE cur_other_current;

      ln_duty_paid_total_aed_gsi := round(nvl(ln_duty_paid_credit_aed_gsi,0) + nvl(ln_duty_paid_current_aed_gsi, 0)) ;

      create_duty_paid_details (
       p_record_header             => lv_record_header,
       p_rt_type                   => lv_rt_type,
       p_ecc                       => lv_ecc ,
       p_yyyymm                    => ln_yyyymm,
       p_return_no                 => lv_return_no,
       p_data_prd_type             => lv_data_prd_type,
       p_duty_paid_credit_cenvat   => ln_duty_paid_credit_cenvat,
       p_duty_paid_current_cenvat  => ln_duty_paid_current_cenvat,
       p_challan_no_cenvat         => lv_challan_no_cenvat,
       p_challan_date_cenvat       => ld_challan_date_cenvat,
       p_bank_code_cenvat          => lv_bank_code_cenvat,
       p_duty_paid_total_cenvat    => ln_duty_paid_total_cenvat,
       p_duty_paid_credit_sed      => ln_duty_paid_credit_sed,
       p_duty_paid_current_sed     => ln_duty_paid_current_sed,
       p_challan_no_sed            => lv_challan_no_sed,
       p_challan_date_sed          => ld_challan_date_sed,
       p_bank_code_sed             => lv_bank_code_sed,
       p_duty_paid_total_sed       => ln_duty_paid_total_sed,
       p_duty_paid_credit_aed_gsi  => ln_duty_paid_credit_aed_gsi,
       p_duty_paid_current_aed_gsi => ln_duty_paid_current_aed_gsi,
       p_challan_no_aed_gsi        => lv_challan_no_aed_gsi,
       p_challan_date_aed_gsi      => ld_challan_date_aed_gsi,
       p_bank_code_aed_gsi         => lv_bank_code_aed_gsi,
       p_duty_paid_total_aed_gsi   => ln_duty_paid_total_aed_gsi,
       p_duty_paid_credit_nccd     => ln_duty_paid_credit_nccd,
       p_duty_paid_current_nccd    => ln_duty_paid_current_nccd,
       p_challan_no_nccd           => lv_challan_no_nccd,
       p_challan_date_nccd         => ld_challan_date_nccd,
       p_bank_code_nccd            => lv_bank_code_nccd,
       p_duty_paid_total_nccd      => ln_duty_paid_total_nccd,
       p_duty_paid_credit_aed_tta  => ln_duty_paid_credit_aed_tta,
       p_duty_paid_current_aed_tta => ln_duty_paid_current_aed_tta,
       p_challan_no_aed_tta        => lv_challan_no_aed_tta,
       p_challan_date_aed_tta      => ld_challan_date_aed_tta,
       p_bank_code_aed_tta         => lv_bank_code_aed_tta,
       p_duty_paid_total_aed_tta   => ln_duty_paid_total_aed_tta,
       p_duty_paid_credit_aed_pmt  => ln_duty_paid_credit_aed_pmt,
       p_duty_paid_current_aed_pmt => ln_duty_paid_current_aed_pmt,
       p_challan_no_aed_pmt        => lv_challan_no_aed_pmt,
       p_challan_date_aed_pmt      => ld_challan_date_aed_pmt,
       p_bank_code_aed_pmt         => lv_bank_code_aed_pmt,
       p_duty_paid_total_aed_pmt   => ln_duty_paid_total_aed_pmt,
       p_duty_paid_credit_saed     => ln_duty_paid_credit_saed,
       p_duty_paid_current_saed    => ln_duty_paid_current_saed,
       p_challan_no_saed           => lv_challan_no_saed,
       p_challan_date_saed         => ld_challan_date_saed,
       p_bank_code_saed            => lv_bank_code_saed,
       p_duty_paid_total_saed      => ln_duty_paid_total_saed,
       p_duty_paid_credit_ade      => ln_duty_paid_credit_ade,
       p_duty_paid_current_ade     => ln_duty_paid_current_ade,
       p_challan_no_ade            => lv_challan_no_ade,
       p_challan_date_ade          => ld_challan_date_ade,
       p_bank_code_ade             => lv_bank_code_ade,
       p_duty_paid_total_ade       => ln_duty_paid_total_ade,
       p_duty_paid_credit_adet     => ln_duty_paid_credit_adet,
       p_duty_paid_current_adet    => ln_duty_paid_current_adet);  -- procedure for formatting and adding the value in flat file

    END LOOP;

  END populate_duty_paid_details;




  -- to populate ceth wise details

  PROCEDURE populate_ceth_wise_details( p_organization_id IN  NUMBER,
                                        p_location_id     IN  NUMBER,
                                        p_start_date      IN  DATE,
                                        p_end_date        IN  DATE
                                      )

  IS
    lv_record_header            varchar2(50);
    lv_rt_type                  varchar2(2);
    p_ecc                       varchar2(15);
    ln_yyyymm                   number;
    lv_return_no                varchar2(3);
    lv_data_prd_type            varchar2(2);
    lv_ceth                     varchar2(8);
    lv_ctsh                     varchar2(8);
    lv_uqc                      varchar2(8);
    ln_qty_mnf                  number;
    lv_qty_clr_type             varchar2(15);
    ln_qty_clr                  number;
    ln_ass_val                  number;
    lv_notf_no_1                varchar2(8);
    lv_notf_sno_1               varchar2(10);
    lv_notf_no_2                varchar2(8);
    lv_notf_sno_2               varchar2(10);
    lv_notf_no_3                varchar2(8);
    lv_notf_sno_3               varchar2(10);
    lv_notf_no_4                varchar2(8);
    lv_notf_sno_4               varchar2(10);
    lv_notf_no_5                varchar2(8);
    lv_notf_sno_5               varchar2(10);
    lv_notf_no_6                varchar2(8);
    lv_notf_sno_6               varchar2(10);
    ln_duty_rate_adv_cenvat     number  ;
    ln_duty_rate_sp_cenvat      number  ;
    ln_duty_payable_cenvat      number  ;
    ln_pa_no_cenvat             number  ;
    ln_duty_rate_adv_sed        number  ;
    ln_duty_rate_sp_sed         number  ;
    ln_duty_payable_sed         number  ;
    ln_pa_no_sed                number  ;
    ln_duty_rate_adv_aed_gsi    number  ;
    ln_duty_rate_sp_aed_gsi     number  ;
    ln_duty_payable_aed_gsi     number  ;
    ln_pa_no_aed_gsi            number  ;
    ln_duty_rate_adv_nccd       number  ;
    ln_duty_rate_sp_nccd        number  ;
    ln_duty_payable_nccd        number  ;
    ln_pa_no_nccd               number  ;
    ln_duty_rate_adv_aed_tta    number  ;
    ln_duty_rate_sp_aed_tta     number  ;
    ln_duty_payable_aed_tta     number  ;
    ln_pa_no_aed_tta            number  ;
    ln_duty_rate_adv_aed_pmt    number  ;
    ln_duty_rate_sp_aed_pmt     number  ;
    ln_duty_payable_aed_pmt     number  ;
    ln_pa_no_aed_pmt            number  ;
    ln_duty_rate_adv_saed       number  ;
    ln_duty_rate_sp_saed        number  ;
    ln_duty_payable_saed        number  ;
    ln_pa_no_saed               number  ;
    ln_duty_rate_adv_ade        number  ;
    ln_duty_rate_sp_ade         number  ;
    ln_duty_payable_ade         number  ;
    ln_pa_no_ade                number  ;
    ln_duty_rate_adv_adet       number  ;
    ln_duty_rate_sp_adet        number  ;
    ln_duty_payable_adet        number  ;
    ln_pa_no_adet               number  ;
    ln_duty_rate_adv_cess       number  ;
    ln_duty_rate_sp_cess        number  ;
    ln_duty_payable_cess        number  ;
    ln_pa_no_cess               number  ;
    ln_duty_rate_adv_edu_cess   number  ;
    ln_duty_rate_sp_edu_cess    number  ;
    ln_duty_payable_edu_cess    number  ;
    ln_pa_no_edu_cess           number  ;
    ln_pla_duty                 NUMBER ;
    ln_rg23_duty                NUMBER ;


    CURSOR Cur_item_desc( p_inventory_item_id IN JAI_CMN_RG_I_TRXS.inventory_item_id%type)
    IS
      SELECT MSI.description
      FROM   mtl_system_items MSI
      WHERE  MSI.inventory_item_id = p_inventory_item_id
      AND    MSI.organization_id   = p_organization_id;


    -- Cursor for quantity manufactured
    CURSOR cur_qty_mftrd(
      p_inventory_item_id IN JAI_CMN_RG_I_TRXS.inventory_item_id%type,
      p_excise_duty_rate  IN NUMBER,
      p_cetsh             IN JAI_INV_ITM_SETUPS.item_tariff%type,
      p_units             IN JAI_CMN_RG_I_TRXS.primary_uom_code%type)

    IS
      SELECT sum( NVL(MANUFACTURED_LOOSE_QTY,0)+
            NVL(FOR_HOME_USE_PAY_ED_QTY,0)+
            NVL(FOR_EXPORT_PAY_ED_QTY,0)+
            NVL(FOR_EXPORT_N_PAY_ED_QTY,0)+
            NVL(TO_OTHER_FACTORY_N_PAY_ED_QTY,0)+
            NVL(OTHER_PURPOSE_N_PAY_ED_QTY,0)+
            NVL(OTHER_PURPOSE_PAY_ED_QTY,0)) QTY_MANUFACTURED
       FROM JAI_CMN_RG_I_TRXS jrgi,
             JAI_INV_ITM_SETUPS items
       WHERE jrgi.transaction_type in ( 'R','PR','RA','IOR','CR')
       AND (jrgi.inventory_item_id  = p_inventory_item_id
        OR nvl(items.item_tariff,'xyz') = nvl(p_cetsh,'xyz'))
       AND items.inventory_item_id = jrgi.inventory_item_id
       AND jrgi.organization_id    = p_organization_id
       AND items.organization_id   = jrgi.organization_id
       AND nvl(jrgi.primary_uom_code,'XYZ') = nvl(p_units,'XYZ')
       AND nvl(round(jrgi.excise_duty_rate,0),-999.95) = nvl(p_excise_duty_rate,-999.95)
       AND jrgi.location_id        = p_location_id
       AND trunc(jrgi.creation_date) between trunc(p_start_date) and trunc(p_end_date)
       AND to_char(jrgi.creation_date, 'YYYY') || to_char(jrgi.creation_date, 'MM') = ln_yyyymm ;


    -- Cursor for quantity cleared
    CURSOR cur_qty_clrd(
      p_inventory_item_id   IN JAI_CMN_RG_I_TRXS.inventory_item_id%type,
      p_excise_duty_rate    IN NUMBER,
      p_cetsh               IN JAI_INV_ITM_SETUPS.item_tariff%type,
      p_units               IN JAI_CMN_RG_I_TRXS.primary_uom_code%type)

    IS
      SELECT sum( NVL(MANUFACTURED_LOOSE_QTY,0)+
            NVL(FOR_HOME_USE_PAY_ED_QTY,0)+
            NVL(FOR_EXPORT_PAY_ED_QTY,0)+
            NVL(FOR_EXPORT_N_PAY_ED_QTY,0)+
            NVL(TO_OTHER_FACTORY_N_PAY_ED_QTY,0)+
            NVL(OTHER_PURPOSE_N_PAY_ED_QTY,0)+
            NVL(OTHER_PURPOSE_PAY_ED_QTY,0)) QTY_MANUFACTURED
       FROM JAI_CMN_RG_I_TRXS jrgi,JAI_INV_ITM_SETUPS items
       WHERE jrgi.transaction_type in ( 'I','IA','PI','IOI')
       AND (  jrgi.inventory_item_id  = p_inventory_item_id
        OR nvl(items.item_tariff,'xyz')     = nvl(p_cetsh,'xyz'))
       AND items.inventory_item_id = jrgi.inventory_item_id
       AND jrgi.organization_id    = p_organization_id
       AND items.organization_id   = jrgi.organization_id
       AND nvl(round(jrgi.excise_duty_rate,0),-999.95) = nvl(p_excise_duty_rate,-999.95)
       AND nvl(jrgi.primary_uom_code,'xyz')   = nvl(p_units,'xyz')
       AND jrgi.location_id        = p_location_id
       AND trunc(jrgi.creation_date) between trunc(p_start_date) and trunc(p_end_date)
       AND to_char(jrgi.creation_date, 'YYYY') || to_char(jrgi.creation_date, 'MM') = ln_yyyymm ;


    -- Cursor for cenvat duty payable
    CURSOR cur_duty_payable(
      p_inventory_item_id   IN JAI_CMN_RG_I_TRXS.inventory_item_id%type,
      p_excise_duty_rate    IN NUMBER,
      p_cetsh               IN JAI_INV_ITM_SETUPS.item_tariff%type,
      p_units               IN JAI_CMN_RG_I_TRXS.primary_uom_code%type)
    IS
      SELECT round(sum( NVL(jrgi.basic_ed,0 ) + NVL(jrgi.additional_ed,0) + NVL(jrgi.other_ed,0) ),0) Duty_payable
      FROM JAI_CMN_RG_I_TRXS jrgi,JAI_INV_ITM_SETUPS items
      WHERE jrgi.transaction_type in ( 'I','PI','IA','IOI')
      AND ( jrgi.inventory_item_id  = p_inventory_item_id
        OR items.item_tariff       = p_cetsh)
      AND items.inventory_item_id = jrgi.inventory_item_id
      AND jrgi.organization_id    = p_organization_id
      AND items.organization_id   = jrgi.organization_id
      AND nvl(jrgi.primary_uom_code,'XYZ') = nvl(p_units,'XYZ')
      AND nvl(round(jrgi.excise_duty_rate,0),-999.95) = nvl(p_excise_duty_rate,-999.95)
      AND jrgi.location_id        = p_location_id
      AND trunc(jrgi.creation_date) between trunc(p_start_date) and trunc(p_end_date)
      AND to_char(jrgi.creation_date, 'YYYY') || to_char(jrgi.creation_date, 'MM') = ln_yyyymm ;

    -- Cursor for Duty Payable(CESS) and Duty Payable(EDU.CESS)
    CURSOR cur_other_duties_PLA(
      p_inventory_item_id IN JAI_CMN_RG_I_TRXS.inventory_item_id%type,
      p_excise_duty_rate  IN NUMBER,
      p_cetsh             IN JAI_INV_ITM_SETUPS.item_tariff%type,
      p_units             IN JAI_CMN_RG_I_TRXS.primary_uom_code%type
      )
    IS
      SELECT nvl(sum(debit),0) FROM JAI_CMN_RG_OTHERS
      WHERE source_register_id IN(
        SELECT register_id_part_ii
        FROM JAI_CMN_RG_I_TRXS jrgi,JAI_INV_ITM_SETUPS items
        WHERE ( jrgi.inventory_item_id  = p_inventory_item_id
        OR items.item_tariff       = p_cetsh)
        AND items.inventory_item_id = jrgi.inventory_item_id
        AND jrgi.organization_id    = p_organization_id
        AND items.organization_id   = jrgi.organization_id
        AND nvl(jrgi.primary_uom_code,'XYZ') = nvl(p_units,'XYZ')
        AND nvl(round(jrgi.excise_duty_rate,0),-999.95) = nvl(p_excise_duty_rate,-999.95)
        AND jrgi.location_id        = p_location_id
        AND trunc(jrgi.creation_date) between trunc(p_start_date) and trunc(p_end_date)
        AND to_char(jrgi.creation_date, 'YYYY') || to_char(jrgi.creation_date, 'MM') = ln_yyyymm
        AND jrgi.transaction_type in ( 'I','IA','PI','IOI')
        AND payment_register = 'PLA')
      AND source_type = 2
      AND tax_type IN (jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_cvd_edu_cess ) ;

    CURSOR cur_other_duties_RG23(
      p_inventory_item_id IN JAI_CMN_RG_I_TRXS.inventory_item_id%type,
      p_excise_duty_rate  IN NUMBER,
      p_cetsh             IN JAI_INV_ITM_SETUPS.item_tariff%type,
      p_units             IN JAI_CMN_RG_I_TRXS.primary_uom_code%type
      )
    IS
      SELECT nvl(sum(debit),0)FROM JAI_CMN_RG_OTHERS
      WHERE source_register_id IN(
        SELECT register_id_part_ii FROM JAI_CMN_RG_I_TRXS jrgi, JAI_INV_ITM_SETUPS items
        WHERE ( jrgi.inventory_item_id  = p_inventory_item_id
              OR items.item_tariff       = p_cetsh )
        AND items.inventory_item_id = jrgi.inventory_item_id
        AND jrgi.organization_id    = p_organization_id
        AND items.organization_id   = jrgi.organization_id
        AND nvl(jrgi.primary_uom_code,'XYZ') = nvl(p_units,'XYZ')
        AND nvl(round(jrgi.excise_duty_rate,0),-999.95) = nvl(p_excise_duty_rate,-999.95)
        AND jrgi.location_id        = p_location_id
        AND trunc(jrgi.creation_date) between trunc(p_start_date) and trunc(p_end_date)
        AND to_char(jrgi.creation_date, 'YYYY') || to_char(jrgi.creation_date, 'MM') = ln_yyyymm
        AND jrgi.transaction_type in ( 'I','IA','PI','IOI')
        AND payment_register IN ('RG23A','RG23C') )
      AND source_type = 1
      AND tax_type IN (jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_cvd_edu_cess ) ;

    CURSOR cur_dtls (
      p_location_id     IN NUMBER,
      p_organization_id IN NUMBER,
      p_start_date      IN DATE,
      p_end_date        IN DATE)
    IS
      SELECT
        a.primary_uom_code  units,
        c.item_tariff  cetsh ,
        substr(c.item_tariff,1,8)  cetsh_sub,
        0 inventory_item_id,
        round(excise_duty_rate,0) excise_duty_rate ,
        to_char(a.creation_date, 'YYYY') || to_char(a.creation_date, 'MM') year_month,
        sum( nvl(a.basic_ed,0 ) + nvl(a.additional_ed,0)  ) duty_payable,
        sum( nvl(a.other_ed,0)) other_duties,
        a.organization_id  -- added, Harshita for Bug 5637136
      FROM
        JAI_CMN_RG_I_TRXS a ,
        mtl_system_items b ,
        JAI_INV_ITM_SETUPS c
      WHERE a.inventory_item_id = b.inventory_item_id
      AND c.inventory_item_id = b.inventory_item_id
      AND c.organization_id = b.organization_id
      AND a.organization_id = b.organization_id
      AND a.location_id = nvl(p_location_id, a.location_id)
      AND a.organization_id = nvl(p_organization_id, a.organization_id)
      AND trunc(a.creation_date) >= trunc(p_start_date )
      AND trunc(a.creation_date) <= trunc(nvl(p_end_date,sysdate))
      GROUP BY
        c.item_tariff ,
        a.primary_uom_code,
        round(excise_duty_rate,0),
        to_char(a.creation_date, 'MM'),
        to_char(a.creation_date, 'YYYY'),
        a.organization_id  -- added, Harshita for Bug 5637136
      HAVING sum( nvl(manufactured_loose_qty,0)+
            nvl(for_home_use_pay_ed_qty,0)+
            nvl(for_export_pay_ed_qty,0)+
            nvl(for_export_n_pay_ed_qty,0)+
            nvl(to_other_factory_n_pay_ed_qty,0)+
            nvl(other_purpose_n_pay_ed_qty,0)+
      nvl(other_purpose_pay_ed_qty,0)) <> 0
      ORDER BY
        to_char(a.creation_date, 'YYYY'),
        to_char(a.creation_date, 'MM')  ;

    cursor c_other_rg23_ii
    is
    SELECT round(sum(nvl(debit,0)),0)
    FROM JAI_CMN_RG_OTHERS
    WHERE tax_type in ( jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_cvd_edu_cess )
    AND source_type = 1
    AND source_register_id in
      ( SELECT register_id
      FROM JAI_CMN_RG_23AC_II_TRXS jrgi
      WHERE location_id           = P_Location_id
      AND organization_id        = p_Organization_id
      AND trunc(creation_date)  >= p_start_date
      AND trunc(creation_date)  <= trunc(nvl(p_end_date,sysdate))
      AND to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm
      AND register_id not in
        ( select NVL(register_id_part_ii,0)
                 from JAI_CMN_RG_I_TRXS
                 where payment_register IN ( 'RG23A','RG23C' )
         )
      );

    CURSOR cur_other_pla IS
    SELECT round(SUM(nvl(credit,0)),0)
    FROM JAI_CMN_RG_OTHERS
    WHERE source_type=2
    AND tax_type in ( jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_cvd_edu_cess )
    AND source_register_id in ( SELECT register_id
                         FROM JAI_CMN_RG_PLA_TRXS
                        WHERE organization_id = p_organization_id
                          AND location_id     = p_location_id
                          AND trunc(creation_date)  >= p_start_date
                          AND trunc(creation_date)  <= trunc(nvl(p_end_date,sysdate))
                          AND TRANSACTION_SOURCE_NUM = 91
                          AND to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm
                          AND register_id not in
                           ( select NVL(register_id_part_ii,0)
                             from JAI_CMN_RG_I_TRXS
                             where payment_register = 'PLA'
                           )
                );

  cursor c_excise_uom_code( cp_organization_id IN number, cp_primary_uom_code in varchar2)
  is
  select excise_uom_code
  from jai_ar_excise_uom
  where organization_id = cp_organization_id
  and primary_uom_code = cp_primary_uom_code ;

  cursor c_duty_payable_part_i
  ( cp_inventory_item_id number,
    cp_cetsh             varchar2,
    cp_primary_uom_code varchar2
  )
  is
    SELECT sum( NVL(jrgi.basic_ed,0 ) + NVL(jrgi.other_ed,0) ) Duty_payable,
    sum( NVL(jrgi.additional_ed,0))         aed_duty_payable
  FROM JAI_CMN_RG_23AC_I_TRXS jrgi,
    JAI_INV_ITM_SETUPS items
   WHERE jrgi.transaction_type in ( 'RTV', 'I', 'IA', 'IOI', 'PI')
     and (   jrgi.inventory_item_id  = cp_inventory_item_id
          OR items.item_tariff       = cp_cetsh
         )
     and items.inventory_item_id = jrgi.inventory_item_id
     and jrgi.organization_id    = p_organization_id
     and items.organization_id   = jrgi.organization_id
     and nvl(jrgi.primary_uom_code,'XYZ') = nvl(cp_primary_uom_code,'XYZ')
     and jrgi.location_id        = p_location_id
     and trunc(jrgi.creation_date) between trunc(p_start_date) and trunc(p_end_date);

    CURSOR cur_other_duties_PLA_part_i
    ( cp_cetsh varchar2,
      cp_primary_uom_code varchar2
    )
    IS
    SELECT nvl(sum(debit),0)
      FROM JAI_CMN_RG_OTHERS
     WHERE source_register_id IN
       ( SELECT register_id_part_ii
           FROM JAI_CMN_RG_23AC_I_TRXS jrgi,
                JAI_INV_ITM_SETUPS items
          WHERE (   items.item_tariff       = cp_cetsh
                )
            and items.inventory_item_id = jrgi.inventory_item_id
            and jrgi.organization_id    = p_organization_id
            and items.organization_id   = jrgi.organization_id
            and nvl(jrgi.primary_uom_code,'XYZ') = nvl(cp_primary_uom_code,'XYZ')
            and jrgi.location_id        = p_location_id
            and trunc(jrgi.creation_date) between trunc(p_start_date) and trunc(p_end_date)
            and jrgi.transaction_type in ( 'RTV', 'I', 'IA', 'IOI', 'PI')
            and register_type = 'PLA')
     AND source_type = 2
     AND tax_type in ('EXCISE_EDUCATION_CESS','CVD_EDUCATION_CESS');

    CURSOR cur_other_duties_RG23_part_i
    ( cp_cetsh varchar2,
      cp_primary_uom_code varchar2
    )
    IS
    SELECT nvl(sum(debit),0)
      FROM JAI_CMN_RG_OTHERS
     WHERE source_register_id IN
       ( SELECT register_id_part_ii
           FROM JAI_CMN_RG_23AC_I_TRXS jrgi,
                JAI_INV_ITM_SETUPS items
          WHERE items.item_tariff       = cp_cetsh
            and items.inventory_item_id = jrgi.inventory_item_id
            and jrgi.organization_id    = p_organization_id
            and items.organization_id   = jrgi.organization_id
            and nvl(jrgi.primary_uom_code,'XYZ') = nvl(cp_primary_uom_code,'XYZ')
            and jrgi.location_id        = p_location_id
            and trunc(jrgi.creation_date) between trunc(p_start_date) and trunc(p_end_date)
            and jrgi.transaction_type in ( 'RTV', 'I', 'IA', 'IOI', 'PI')
            and register_type IN ('A','C') )
   AND source_type = 1
   AND tax_type in ('EXCISE_EDUCATION_CESS','CVD_EDUCATION_CESS');

  BEGIN

    lv_record_header := 'CETH_WISE_DETAIL' ;
    lv_rt_type       := 1 ;
    lv_return_no     := 1 ;
    lv_data_prd_type := 'M' ;

    FOR dtl IN cur_dtls( p_location_id, p_organization_id, p_start_date, p_end_date)
    LOOP
      lv_uqc                    := NULL;
      ln_qty_mnf                := NULL;
      ln_qty_clr                := NULL;
      ln_duty_rate_adv_cenvat   := NULL;
      ln_duty_payable_cenvat    := NULL;
      ln_ass_val                := NULL;
      ln_duty_payable_edu_cess  := NULL;
      lv_ceth                   := NULL;
      ln_yyyymm                 := NULL;
      ln_pla_duty               := NULL;
      ln_rg23_duty              := NULL;
      ln_duty_rate_sp_cenvat    := null ;
      ln_duty_rate_adv_edu_cess := null ;
      ln_duty_rate_sp_edu_cess  := null ;


      lv_ceth          := substr(dtl.cetsh_sub,1,8) ;
      ln_yyyymm        := dtl.year_month ;

      open c_excise_uom_code( dtl.organization_id, dtl.units) ;
      fetch c_excise_uom_code into lv_uqc ;
      close c_excise_uom_code ;

      -- lv_uqc           := dtl.UNITS;        -- for Unit of Quantity Code

      -- for quantity manufactured
      OPEN cur_qty_mftrd( dtl.inventory_item_id, dtl.excise_duty_rate, dtl.CETSH, dtl.UNITS);
      FETCH cur_qty_mftrd INTO ln_qty_mnf;
      CLOSE cur_qty_mftrd;

      -- for quantity cleared
      OPEN cur_qty_clrd( dtl.inventory_item_id, dtl.excise_duty_rate, dtl.CETSH, dtl.UNITS);
      FETCH cur_qty_clrd INTO ln_qty_clr;
      CLOSE cur_qty_clrd;

      -- for Advalorem Rate of Duty(CENVAT)
      IF ln_qty_clr IS NULL THEN
        ln_duty_rate_adv_cenvat := NULL;
      ELSE
        ln_duty_rate_adv_cenvat := dtl.excise_duty_rate;
      END IF;

      -- for cenvat duty payable
      OPEN cur_duty_payable( dtl.inventory_item_id, dtl.excise_duty_rate, dtl.CETSH, dtl.UNITS);
      FETCH cur_duty_payable INTO ln_duty_payable_cenvat;
      CLOSE cur_duty_payable;

      -- for Assesseble Value of Clearance
      IF nvl(ln_duty_rate_adv_cenvat,0) = 0 THEN
        ln_ass_val := ln_duty_rate_adv_cenvat;
      ELSE
        ln_ass_val := round((NVL(ln_duty_payable_cenvat,0)*100)/ln_duty_rate_adv_cenvat,0);
      END IF;

      -- for Duty Payable(EDU.CESS)
      OPEN cur_other_duties_PLA (dtl.inventory_item_id, dtl.excise_duty_rate, dtl.CETSH, dtl.UNITS);
      FETCH cur_other_duties_PLA INTO ln_pla_duty;
      CLOSE cur_other_duties_PLA;

      OPEN cur_other_duties_RG23(dtl.inventory_item_id, dtl.excise_duty_rate, dtl.CETSH, dtl.UNITS);
      FETCH cur_other_duties_RG23 INTO ln_rg23_duty;
      CLOSE cur_other_duties_RG23;

      ln_duty_payable_edu_cess := round((nvl(ln_pla_duty,0) + nvl(ln_rg23_duty,0)),0);

      ln_pla_duty  := null ;
      ln_rg23_duty := null ;

      IF ln_duty_payable_cenvat is not null THEN
        ln_duty_rate_sp_cenvat := 0;
      END IF ;

      IF ln_duty_payable_edu_cess is not null THEN
        ln_duty_rate_adv_edu_cess := 0 ;
        ln_duty_rate_sp_edu_cess  := 0 ;
      END IF ;


      create_ceth_details(
        p_record_header         => lv_record_header,
        p_rt_type               => lv_rt_type,
        p_ecc                   => lv_ecc,
        p_yyyymm                => ln_yyyymm,
        p_return_no             => lv_return_no,
        p_data_prd_type         => lv_data_prd_type,
        p_ceth                  => lv_ceth,
        p_ctsh                  => lv_ctsh,
        p_uqc                   => lv_uqc,
        p_qty_mnf               => nvl(ln_qty_mnf,0),
        p_qty_clr_type          => lv_qty_clr_type,
        p_qty_clr               => nvl(ln_qty_clr,0),
        p_ass_val               => nvl(ln_ass_val,0),
        p_notf_no_1             => lv_notf_no_1,
        p_notf_sno_1            => lv_notf_sno_1,
        p_notf_no_2             => lv_notf_no_2,
        p_notf_sno_2            => lv_notf_sno_2,
        p_notf_no_3             => lv_notf_no_3,
        p_notf_sno_3            => lv_notf_sno_3,
        p_notf_no_4             => lv_notf_no_4,
        p_notf_sno_4            => lv_notf_sno_4,
        p_notf_no_5             => lv_notf_no_5,
        p_notf_sno_5            => lv_notf_sno_5,
        p_notf_no_6             => lv_notf_no_6,
        p_notf_sno_6            => lv_notf_sno_6,
        p_duty_rate_adv_cenvat  => ln_duty_rate_adv_cenvat,
        p_duty_rate_sp_cenvat   => ln_duty_rate_sp_cenvat,
        p_duty_payable_cenvat   => ln_duty_payable_cenvat,
        p_pa_no_cenvat          => ln_pa_no_cenvat,
        p_duty_rate_adv_sed     => ln_duty_rate_adv_sed,
        p_duty_rate_sp_sed      => ln_duty_rate_sp_sed,
        p_duty_payable_sed      => ln_duty_payable_sed,
        p_pa_no_sed             => ln_pa_no_sed,
        p_duty_rate_adv_aed_gsi => ln_duty_rate_adv_aed_gsi,
        p_duty_rate_sp_aed_gsi  => ln_duty_rate_sp_aed_gsi,
        p_duty_payable_aed_gsi  => ln_duty_payable_aed_gsi,
        p_pa_no_aed_gsi         => ln_pa_no_aed_gsi,
        p_duty_rate_adv_nccd    => ln_duty_rate_adv_nccd,
        p_duty_rate_sp_nccd     => ln_duty_rate_sp_nccd,
        p_duty_payable_nccd     => ln_duty_payable_nccd,
        p_pa_no_nccd            => ln_pa_no_nccd,
        p_duty_rate_adv_aed_tta => ln_duty_rate_adv_aed_tta,
        p_duty_rate_sp_aed_tta  => ln_duty_rate_sp_aed_tta,
        p_duty_payable_aed_tta  => ln_duty_payable_aed_tta,
        p_pa_no_aed_tta         => ln_pa_no_aed_tta,
        p_duty_rate_adv_aed_pmt => ln_duty_rate_adv_aed_pmt,
        p_duty_rate_sp_aed_pmt  => ln_duty_rate_sp_aed_pmt,
        p_duty_payable_aed_pmt  => ln_duty_payable_aed_pmt,
        p_pa_no_aed_pmt         => ln_pa_no_aed_pmt,
        p_duty_rate_adv_saed    => ln_duty_rate_adv_saed,
        p_duty_rate_sp_saed     => ln_duty_rate_sp_saed,
        p_duty_payable_saed     => ln_duty_payable_saed,
        p_pa_no_saed            => ln_pa_no_saed,
        p_duty_rate_adv_ade     => ln_duty_rate_adv_ade,
        p_duty_rate_sp_ade      => ln_duty_rate_sp_ade,
        p_duty_payable_ade      => ln_duty_payable_ade,
        p_pa_no_ade             => ln_pa_no_ade,
        p_duty_rate_adv_adet    => ln_duty_rate_adv_adet,
        p_duty_rate_sp_adet     => ln_duty_rate_sp_adet,
        p_duty_payable_adet     => ln_duty_payable_adet,
        p_pa_no_adet            => ln_pa_no_adet,
        p_duty_rate_adv_cess    => ln_duty_rate_adv_cess,
        p_duty_rate_sp_cess     => ln_duty_rate_sp_cess,
        p_duty_payable_cess     => ln_duty_payable_cess,
        p_pa_no_cess            => ln_pa_no_cess,
        p_duty_rate_adv_edu_cess=> ln_duty_rate_adv_edu_cess,
        p_duty_rate_sp_edu_cess => ln_duty_rate_sp_edu_cess,
        p_duty_payable_edu_cess => ln_duty_payable_edu_cess,
        p_pa_no_edu_cess        => ln_pa_no_edu_cess);

    END LOOP;

    FOR dtl in
     (
       SELECT
       a.primary_uom_code  UNITS,
       c.item_tariff  CETSH ,
       Substr(c.ITEM_TARIFF,1,15)  CETSH_SUB,
       0 inventory_item_id,
       0 excise_duty_rate ,
       to_char(a.creation_date, 'YYYY') || to_char(a.creation_date, 'MM') year_month,
       sum( NVL(a.basic_ed,0 ) + NVL(a.additional_ed,0)  ) Duty_payable,
       sum( NVL(a.other_ed,0)) Other_duties,
       a.organization_id
       FROM
       JAI_CMN_RG_23AC_I_TRXS A ,
       mtl_system_items b ,
       JAI_INV_ITM_SETUPS c
       where a.inventory_item_id = b.inventory_item_id
       and c.inventory_item_id = b.inventory_item_id
       and c.organization_id = b.organization_id
       and a.organization_id = b.organization_id
       and a.location_id = nvl(P_Location_id, a.location_id)
       and a.organization_id = nvl(p_Organization_id, a.organization_id)
       and trunc(a.creation_date) >= trunc(p_start_date )
       and trunc(a.creation_date) <= trunc(nvl(p_end_date,sysdate))
      GROUP BY
        c.item_tariff ,
        a.primary_uom_code,
        a.organization_id  ,
        to_char(a.creation_date, 'MM'),
        to_char(a.creation_date, 'YYYY')
      ORDER BY
        to_char(a.creation_date, 'YYYY'),
        to_char(a.creation_date, 'MM')
     )
    LOOP

      lv_uqc                    := NULL;
      ln_qty_mnf                := NULL;
      ln_qty_clr                := NULL;
      ln_duty_rate_adv_cenvat   := NULL;
      ln_duty_payable_cenvat    := NULL;
      ln_ass_val                := NULL;
      ln_duty_payable_edu_cess  := NULL;
      lv_ceth                   := NULL;
      ln_yyyymm                 := NULL;
      ln_pla_duty               := NULL;
      ln_rg23_duty              := NULL;
      ln_duty_rate_sp_cenvat    := null ;
      ln_duty_rate_adv_edu_cess := null ;
      ln_duty_rate_sp_edu_cess  := null ;
      lv_ceth          := substr(dtl.cetsh_sub,1,8) ;
      ln_yyyymm        := dtl.year_month ;
      lv_uqc           := dtl.UNITS;
      ln_qty_mnf       := 0 ;
      ln_qty_clr       := 0 ;
      ln_duty_rate_adv_cenvat := 0 ;

      open c_duty_payable_part_i(dtl.inventory_item_id, dtl.cetsh, dtl.units ) ;
      fetch c_duty_payable_part_i into ln_duty_payable_cenvat, ln_duty_rate_adv_cenvat ;
      close c_duty_payable_part_i ;

      OPEN cur_other_duties_PLA_part_i(dtl.cetsh , dtl.units);
      FETCH cur_other_duties_PLA_part_i INTO ln_pla_duty;
      CLOSE cur_other_duties_PLA_part_i;

      OPEN cur_other_duties_RG23_part_i(dtl.cetsh , dtl.units);
      FETCH cur_other_duties_RG23_part_i INTO ln_rg23_duty;
      CLOSE cur_other_duties_RG23_part_i;

      ln_duty_payable_edu_cess := round((nvl(ln_pla_duty,0) + nvl(ln_rg23_duty,0)),0);

      IF ln_duty_payable_cenvat is not null THEN
        ln_duty_rate_sp_cenvat := 0;
      END IF ;

      IF ln_duty_payable_edu_cess is not null THEN
        ln_duty_rate_adv_edu_cess := 0 ;
        ln_duty_rate_sp_edu_cess  := 0 ;
      END IF ;

          create_ceth_details(
            p_record_header         => lv_record_header,
            p_rt_type               => lv_rt_type,
            p_ecc                   => lv_ecc,
            p_yyyymm                => ln_yyyymm,
            p_return_no             => lv_return_no,
            p_data_prd_type         => lv_data_prd_type,
            p_ceth                  => lv_ceth,
            p_ctsh                  => lv_ctsh,
            p_uqc                   => lv_uqc,
            p_qty_mnf               => nvl(ln_qty_mnf,0),
            p_qty_clr_type          => lv_qty_clr_type,
            p_qty_clr               => nvl(ln_qty_clr,0),
            p_ass_val               => nvl(ln_ass_val,0),
            p_notf_no_1             => lv_notf_no_1,
            p_notf_sno_1            => lv_notf_sno_1,
            p_notf_no_2             => lv_notf_no_2,
            p_notf_sno_2            => lv_notf_sno_2,
            p_notf_no_3             => lv_notf_no_3,
            p_notf_sno_3            => lv_notf_sno_3,
            p_notf_no_4             => lv_notf_no_4,
            p_notf_sno_4            => lv_notf_sno_4,
            p_notf_no_5             => lv_notf_no_5,
            p_notf_sno_5            => lv_notf_sno_5,
            p_notf_no_6             => lv_notf_no_6,
            p_notf_sno_6            => lv_notf_sno_6,
            p_duty_rate_adv_cenvat  => ln_duty_rate_adv_cenvat,
            p_duty_rate_sp_cenvat   => ln_duty_rate_sp_cenvat,
            p_duty_payable_cenvat   => ln_duty_payable_cenvat,
            p_pa_no_cenvat          => ln_pa_no_cenvat,
            p_duty_rate_adv_sed     => ln_duty_rate_adv_sed,
            p_duty_rate_sp_sed      => ln_duty_rate_sp_sed,
            p_duty_payable_sed      => ln_duty_payable_sed,
            p_pa_no_sed             => ln_pa_no_sed,
            p_duty_rate_adv_aed_gsi => ln_duty_rate_adv_aed_gsi,
            p_duty_rate_sp_aed_gsi  => ln_duty_rate_sp_aed_gsi,
            p_duty_payable_aed_gsi  => ln_duty_payable_aed_gsi,
            p_pa_no_aed_gsi         => ln_pa_no_aed_gsi,
            p_duty_rate_adv_nccd    => ln_duty_rate_adv_nccd,
            p_duty_rate_sp_nccd     => ln_duty_rate_sp_nccd,
            p_duty_payable_nccd     => ln_duty_payable_nccd,
            p_pa_no_nccd            => ln_pa_no_nccd,
            p_duty_rate_adv_aed_tta => ln_duty_rate_adv_aed_tta,
            p_duty_rate_sp_aed_tta  => ln_duty_rate_sp_aed_tta,
            p_duty_payable_aed_tta  => ln_duty_payable_aed_tta,
            p_pa_no_aed_tta         => ln_pa_no_aed_tta,
            p_duty_rate_adv_aed_pmt => ln_duty_rate_adv_aed_pmt,
            p_duty_rate_sp_aed_pmt  => ln_duty_rate_sp_aed_pmt,
            p_duty_payable_aed_pmt  => ln_duty_payable_aed_pmt,
            p_pa_no_aed_pmt         => ln_pa_no_aed_pmt,
            p_duty_rate_adv_saed    => ln_duty_rate_adv_saed,
            p_duty_rate_sp_saed     => ln_duty_rate_sp_saed,
            p_duty_payable_saed     => ln_duty_payable_saed,
            p_pa_no_saed            => ln_pa_no_saed,
            p_duty_rate_adv_ade     => ln_duty_rate_adv_ade,
            p_duty_rate_sp_ade      => ln_duty_rate_sp_ade,
            p_duty_payable_ade      => ln_duty_payable_ade,
            p_pa_no_ade             => ln_pa_no_ade,
            p_duty_rate_adv_adet    => ln_duty_rate_adv_adet,
            p_duty_rate_sp_adet     => ln_duty_rate_sp_adet,
            p_duty_payable_adet     => ln_duty_payable_adet,
            p_pa_no_adet            => ln_pa_no_adet,
            p_duty_rate_adv_cess    => ln_duty_rate_adv_cess,
            p_duty_rate_sp_cess     => ln_duty_rate_sp_cess,
            p_duty_payable_cess     => ln_duty_payable_cess,
            p_pa_no_cess            => ln_pa_no_cess,
            p_duty_rate_adv_edu_cess=> ln_duty_rate_adv_edu_cess,
            p_duty_rate_sp_edu_cess => ln_duty_rate_sp_edu_cess,
            p_duty_payable_edu_cess => ln_duty_payable_edu_cess,
            p_pa_no_edu_cess        => ln_pa_no_edu_cess);

    END LOOP ;

  END populate_ceth_wise_details;


  -- to populate cenvat credit details
  PROCEDURE populate_cenvat_credit_details (
    p_end_date            IN  DATE,
    p_location_id         IN  NUMBER,
    p_operating_unit      IN  NUMBER,
    p_organization_id     IN  NUMBER,
    p_registration_number IN  VARCHAR2,
    p_start_date          IN  DATE )
  IS
    lv_record_header                varchar2(50);
    lv_rt_type                      varchar2(2);
    p_ecc                          varchar2(15);
    ln_yyyymm                       number;
    lv_return_no                    varchar2(3);
    lv_data_prd_type                varchar2(2);
    ln_op_bal_cenvat                number ;
    ln_credit_input_cenvat          number ;
    ln_credit_input_dlr_cenvat      number ;
    ln_credit_capital_cenvat        number ;
    ln_credit_service_cenvat        number ;
    ln_credit_total_cenvat          number ;
    ln_credit_utilised_cenvat       number ;
    ln_credit_utilised_ic_cenvat    number ;
    ln_credit_utilised_ds_cenvat    number ;
    ln_clos_bal_cenvat              number ;
    ln_op_bal_aed_tta               number ;
    ln_credit_input_aed_tta         number ;
    ln_credit_input_dlr_aed_tta     number ;
    ln_credit_capital_aed_tta       number ;
    ln_credit_service_aed_tta       number ;
    ln_credit_total_aed_tta         number ;
    ln_credit_utilised_aed_tta      number ;
    ln_credit_utilised_ic_aed_tta   number ;
    ln_credit_utilised_ds_aed_tta   number ;
    ln_clos_bal_aed_tta             number ;
    ln_op_bal_aed_pmt               number ;
    ln_credit_input_aed_pmt         number ;
    ln_credit_input_dlr_aed_pmt     number ;
    ln_credit_capital_aed_pmt       number ;
    ln_credit_service_aed_pmt       number ;
    ln_credit_total_aed_pmt         number ;
    ln_credit_utilised_aed_pmt      number ;
    ln_credit_utilised_ic_aed_pmt   number ;
    ln_credit_utilised_ds_aed_pmt   number ;
    ln_clos_bal_aed_pmt             number ;
    ln_op_bal_nccd                  number ;
    ln_credit_input_nccd            number ;
    ln_credit_input_dlr_nccd        number ;
    ln_credit_capital_nccd          number ;
    ln_credit_service_nccd          number ;
    ln_credit_total_nccd            number ;
    ln_credit_utilised_nccd         number ;
    ln_credit_utilised_ic_nccd      number ;
    ln_credit_utilised_ds_nccd      number ;
    ln_clos_bal_nccd                number ;
    ln_op_bal_adet                  number ;
    ln_credit_input_adet            number ;
    ln_credit_input_dlr_adet        number ;
    ln_credit_capital_adet          number ;
    ln_credit_service_adet          number ;
    ln_credit_total_adet            number ;
    ln_credit_utilised_adet         number ;
    ln_credit_utilised_ic_adet      number ;
    ln_credit_utilised_ds_adet      number ;
    ln_clos_bal_adet                number ;
    ln_op_bal_edu_cess              number ;
    ln_credit_input_edu_cess        number ;
    ln_credit_input_dlr_edu_cess    number ;
    ln_credit_capital_edu_cess      number ;
    ln_credit_service_edu_cess      number ;
    ln_credit_total_edu_cess        number ;
    ln_credit_utilised_edu_cess     number ;
    ln_credit_utilised_ic_edu_cess  number ;
    ln_credit_utilised_ds_edu_cess  number ;
    ln_clos_bal_edu_cess            number ;
    ln_op_bal_st                    number ;
    ln_credit_input_st              number ;
    ln_credit_input_dlr_st          number ;
    ln_credit_capital_st            number ;
    ln_credit_service_st            number ;
    ln_credit_total_st              number ;
    ln_credit_utilised_st           number ;
    ln_credit_utilised_ic_st        number ;
    ln_credit_utilised_ds_st        number ;
    ln_clos_bal_st                  number ;
    ln_op_bal_st_edu_cess           number ;
    ln_credit_input_st_edu_cess     number ;
    ln_cre_input_dlr_st_edu_cess    number ;
    ln_credit_capital_st_edu_cess   number ;
    ln_credit_service_st_edu_cess   number ;
    ln_credit_total_st_edu_cess     number ;
    ln_creln_dit_uti_st_edu_cess    number ;
    ln_credit_uti_ic_st_edu_cess    number ;
    ln_credit_uti_ds_st_edu_cess    number ;
    ln_clos_bal_st_edu_cess         number ;
    ln_closed_input_manf            NUMBER;
    ln_closed_input_manf_iso        NUMBER;
    ln_closed_input_cust            NUMBER;
    ln_closed_input_stg             NUMBER;
    ln_closed_input_stg_iso         NUMBER;
    ln_rtv_amount                   NUMBER;
    ln_cgin_sale_amt                NUMBER;
    ln_edu_cess_excise_manf         NUMBER;
    ln_edu_cess_excise_manf_iso     NUMBER;
    ln_edu_cess_excise_cust         NUMBER;
    ln_edu_cess_excise_stg          NUMBER;
    ln_edu_cess_excise_stg_iso      NUMBER;
    ln_edu_cess_excise              NUMBER;
    ln_rtv_cess                     NUMBER;
    ln_cgin_sales_cess              NUMBER;
    lv_inv_open_bal                 NUMBER;
    lv_open_dist_bal                NUMBER;
    lv_ar_util_credit               NUMBER;
    lv_ar_ser_dist_out_debit        NUMBER;
    lv_manual_bal                   NUMBER;
    lv_manual_debit_bal             NUMBER;
    lv_manual_payment               NUMBER;
    lv_st_credit_avld               NUMBER;
    lv_cess_credit_avld             NUMBER;
    ln_ar_util_credit               NUMBER;
    ln_ar_ser_dist_out_debit        NUMBER;
    lv_manual_debit                 NUMBER;
    lv_payment                      NUMBER;


    -- Cursor for cenvat opening balance
    CURSOR cur_opening_balance_cenvat(cp_start_date IN DATE )
    IS
      SELECT  round(NVL(SUM(NVL(cr_basic_ed,0)+ NVL(cr_additional_ed,0) + NVL(cr_other_ed,0) - NVL(dr_basic_ed,0)- NVL(dr_additional_ed,0) - NVL(dr_other_ed,0)),0),0)
      FROM    JAI_CMN_RG_23AC_II_TRXS
      WHERE   location_id = p_location_id
      AND     organization_id = p_organization_id
      AND     trunc(creation_date) < cp_start_date;



     -- Cursors for Credit availed on Input on invoices issued by manufactureres
    CURSOR Cur_crdit_input_manf
    IS
      SELECT  SUM(DECODE(register_type, 'A', nvl(cr_basic_ed,0) + nvl(cr_additional_ed,0) + nvl(cr_other_ed,0),0)) credit_availed_on_inputs_vend
      FROM    JAI_CMN_RG_23AC_II_TRXS JIRP,JAI_CMN_VENDOR_SITES JIPV
      WHERE   location_id               = p_location_id
      AND     organization_id           = p_organization_id
      AND     JIRP.vendor_id            = JIPV.vendor_id
      AND     JIRP.vendor_site_id       = JIPV.vendor_site_id
      AND    (
        JIPV.vendor_type       IN ('Manufacturer', 'Importer')
        OR JIPV.vendor_type       IS NULL)
      AND     TRUNC(JIRP.creation_date) >= p_start_date
      AND     TRUNC(JIRP.creation_date) <= trunc(nvl(p_end_date,SYSDATE))
      AND     to_char(jirp.creation_date, 'YYYY') || to_char(jirp.creation_date, 'MM') = ln_yyyymm ;

    CURSOR Cur_crdit_input_cust
    IS
      SELECT  SUM(DECODE(register_type, 'A', nvl(cr_basic_ed,0) + nvl(cr_additional_ed,0) + nvl(cr_other_ed,0),0)) credit_availed_on_inputs_cust
      FROM    JAI_CMN_RG_23AC_II_TRXS       JIRP,JAI_CMN_CUS_ADDRESSES JICA,hz_cust_acct_sites_all HZCAS,hz_cust_site_uses_all HZCSU
      WHERE   HZCAS.cust_acct_site_id   = HZCSU.cust_acct_site_id
      AND     JICA.address_id           = HZCSU.cust_acct_site_id
      AND     HZCSU.site_use_id         = JIRP.customer_site_id
      AND     JIRP.customer_id          = JICA.customer_id
      AND     JIRP.location_id          = p_location_id
      AND     JIRP.organization_id      = p_organization_id
      AND     TRUNC(JIRP.creation_date) >= p_start_date
      AND     TRUNC(JIRP.creation_date) <= TRUNC(nvl(p_end_date,SYSDATE))
      AND     to_char(jirp.creation_date, 'YYYY') || to_char(jirp.creation_date, 'MM') = ln_yyyymm ;

    CURSOR Cur_crdit_input_manf_iso
    IS
      SELECT  SUM(DECODE(register_type, 'A', nvl(cr_basic_ed,0) + nvl(cr_additional_ed,0) + nvl(cr_other_ed,0),0)) credit_availed_on_inputs
      FROM    JAI_CMN_RG_23AC_II_TRXS JIRP,JAI_CMN_INVENTORY_ORGS JIHO
      WHERE   JIRP.location_id          = p_location_id
      AND     JIRP.organization_id      = p_organization_id
      AND     ABS(jirp.vendor_id)       = jiho.organization_id
      AND     ABS(jirp.vendor_site_id)  = jiho.location_id
      AND     JIHO.manufacturing        = 'Y'
      AND     TRUNC(jirp.creation_date) >= p_start_date
      AND     TRUNC(jirp.creation_date) <= trunc(nvl(p_end_date,SYSDATE))
      AND     to_char(jirp.creation_date, 'YYYY') || to_char(jirp.creation_date, 'MM') = ln_yyyymm ;

    -- Cursors for Credit availed on Input on invoices issued by I or II stage dealers

    CURSOR Cur_crdit_input_stg
    IS
      SELECT  SUM(DECODE(register_type, 'A', nvl(cr_basic_ed,0) + nvl(cr_additional_ed,0) + nvl(cr_other_ed,0),0)) credit_availed_on_inputs
      FROM    JAI_CMN_RG_23AC_II_TRXS JIRP,JAI_CMN_VENDOR_SITES JIPV
      WHERE   location_id = p_location_id
      AND     organization_id = p_organization_id
      AND     JIRP.vendor_id = JIPV.vendor_id
      AND     JIRP.vendor_site_id = JIPV.vendor_site_id
      AND     JIPV.vendor_type    IN ('First Stage Dealer', 'Second Stage Dealer')
      AND     TRUNC(JIRP.creation_date) >= p_start_date
      AND     TRUNC(JIRP.creation_date) <= trunc(nvl(p_end_date,SYSDATE))
      AND     to_char(jirp.creation_date, 'YYYY') || to_char(jirp.creation_date, 'MM') = ln_yyyymm ;

    CURSOR Cur_crdit_input_stg_iso
    IS
      SELECT  SUM(DECODE(register_type, 'A', nvl(cr_basic_ed,0) + nvl(cr_additional_ed,0) + nvl(cr_other_ed,0),0)) credit_availed_on_inputs
      FROM    JAI_CMN_RG_23AC_II_TRXS JIRP,JAI_CMN_INVENTORY_ORGS JIHO
      WHERE   JIRP.location_id          = p_location_id
      AND     JIRP.organization_id      = p_organization_id
      AND     ABS(JIRP.vendor_id)       = JIHO.organization_id
      AND     ABS(JIRP.vendor_site_id)  = JIHO.location_id
      AND     JIHO.trading              = 'Y'
      AND     TRUNC(JIRP.creation_date) >= p_start_date
      AND     TRUNC(JIRP.creation_date) <= trunc(nvl(p_end_date,SYSDATE))
      AND     to_char(jirp.creation_date, 'YYYY') || to_char(jirp.creation_date, 'MM') = ln_yyyymm ;

    -- Cursors for Credit utilised (input/capital goods)
    CURSOR get_rtv_amount
    IS
      SELECT sum(nvl(jrg23_ii.DR_BASIC_ED,0) + nvl(jrg23_ii.DR_ADDITIONAL_ED,0) + nvl(jrg23_ii.DR_OTHER_ED,0))
      FROM JAI_CMN_RG_23AC_II_TRXS jrg23_ii ,JAI_CMN_RG_23AC_I_TRXS jrg23_i
      WHERE jrg23_ii.organization_id       = p_organization_id
      AND jrg23_ii.location_id           = p_location_id
      AND trunc(jrg23_ii.creation_date) >= p_start_date
      AND trunc(jrg23_ii.creation_date) <= trunc(nvl(p_end_date,sysdate))
      AND jrg23_i.transaction_type       = 'RTV'
      AND jrg23_ii.organization_id       = jrg23_i.organization_id
      AND jrg23_ii.location_id           = jrg23_i.location_id
      AND jrg23_ii.register_id_part_i    = jrg23_i.register_id
      AND to_char(jrg23_ii.creation_date, 'YYYY') || to_char(jrg23_ii.creation_date, 'MM') = ln_yyyymm ;

    CURSOR get_cgin_sales
    IS
      SELECT sum(nvl(jrg23_ii.DR_BASIC_ED,0) + nvl(jrg23_ii.DR_ADDITIONAL_ED,0) + nvl(jrg23_ii.DR_OTHER_ED,0))
      FROM JAI_CMN_RG_23AC_II_TRXS jrg23_ii ,JAI_CMN_RG_23AC_I_TRXS jrg23_i,JAI_INV_ITM_SETUPS jmsi
      WHERE jrg23_ii.organization_id       = jrg23_i.organization_id
      AND jrg23_ii.location_id           = jrg23_i.location_id
      AND jrg23_ii.register_id_part_i    = jrg23_i.register_id
      AND jmsi.organization_id           = jrg23_ii.organization_id
      AND jmsi.item_class                like 'CG%'
      AND jmsi.inventory_item_id         = jrg23_ii.inventory_item_id
      AND jmsi.organization_id           = p_organization_id
      AND jrg23_ii.organization_id       = p_organization_id
      AND jrg23_ii.location_id           = p_location_id
      AND trunc(jrg23_ii.creation_date) >= p_start_date
      AND trunc(jrg23_ii.creation_date) <= trunc(nvl(p_end_date,sysdate))
      AND jrg23_i.transaction_type       <> 'RTV'
      AND to_char(jrg23_ii.creation_date, 'YYYY') || to_char(jrg23_ii.creation_date, 'MM') = ln_yyyymm ;

    -- Cursor for opening balance(EDU CESS)
    CURSOR cur_opening_bal_edu_cess(cp_start_date IN DATE )
    IS
      SELECT round(sum(nvl(credit,0) - nvl(debit,0)),0)
      FROM JAI_CMN_RG_OTHERS
      WHERE source_type = 1
      AND source_register_id in (
        SELECT register_id
        FROM JAI_CMN_RG_23AC_II_TRXS
        WHERE location_id        = p_location_id
        AND organization_id      = p_organization_id
        AND trunc(creation_date) < cp_start_date)
      AND tax_type in ( jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess);

    -- Cursors for Credit availed on Input on invoices issued by manufactureres (EDU CESS)
    CURSOR   Cur_cess_excise_input_manf
    IS
      SELECT NVL(SUM(credit),0) FROM JAI_CMN_RG_OTHERS JRO,JAI_CMN_RG_23AC_II_TRXS RG23,JAI_CMN_VENDOR_SITES JIPV
      WHERE jro.source_register_id  =  RG23.register_id
      AND   RG23.vendor_id          =  JIPV.vendor_id
      AND   RG23.vendor_site_id     =  JIPV.vendor_site_id
      AND   ( JIPV.vendor_type    IN ('Manufacturer', 'Importer')
        OR JIPV.vendor_type    IS NULL)
      AND rg23.location_id          =  p_location_id
      AND rg23.organization_id      =  p_organization_id
      AND TRUNC(rg23.creation_date) >= p_start_date
      AND TRUNC(rg23.creation_date) <= TRUNC(NVL(p_end_date,sysdate))
      AND RG23.register_type        = 'A'
      AND JRO.source_register       = 'RG23A_P2'
      AND JRO.tax_type              IN (jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess)
      AND to_char(rg23.creation_date, 'YYYY') || to_char(rg23.creation_date, 'MM') = ln_yyyymm ;

    CURSOR   Cur_cess_excise_input_cust
    IS
      SELECT NVL(SUM(credit),0) FROM JAI_CMN_RG_OTHERS JRO,JAI_CMN_RG_23AC_II_TRXS RG23,JAI_CMN_CUS_ADDRESSES JICA,hz_cust_acct_sites_all HZCAS,hz_cust_site_uses_all HZCSU
      WHERE hzcas.cust_acct_site_id   =  hzcsu.cust_acct_site_id
      and   jica.address_id           =  hzcsu.cust_acct_site_id
      and   hzcsu.site_use_id         =  rg23.customer_site_id
      and   rg23.customer_id          =  jica.customer_id
      and   jro.source_register_id    =  rg23.register_id
      and   rg23.location_id          =  p_location_id
      and   rg23.organization_id      =  p_organization_id
      and   trunc(rg23.creation_date) >= p_start_date
      and   trunc(rg23.creation_date) <= trunc(nvl(p_end_date,sysdate))
      and   rg23.register_type        = 'A'
      and   jro.source_register       = 'RG23A_P2'
      and   jro.tax_type              IN (jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess)
      and   to_char(rg23.creation_date, 'YYYY') || to_char(rg23.creation_date, 'MM') = ln_yyyymm ;

    CURSOR   Cur_cess_excise_input_manf_iso
    IS
      SELECT NVL(SUM(credit),0) FROM JAI_CMN_RG_OTHERS JRO,JAI_CMN_RG_23AC_II_TRXS RG23,JAI_CMN_INVENTORY_ORGS JIHO
      WHERE jro.source_register_id  =  RG23.register_id
      and abs(rg23.vendor_id)     =  jiho.organization_id
      and abs(rg23.vendor_site_id)=  jiho.location_id
      and jiho.manufacturing     = 'Y'
      and rg23.location_id          =  p_location_id
      and rg23.organization_id      =  p_organization_id
      and trunc(rg23.creation_date) >= p_start_date
      and trunc(rg23.creation_date) <= trunc(nvl(p_end_date,sysdate))
      and rg23.register_type        = 'A'
      and jro.source_register       = 'RG23A_P2'
      and jro.tax_type              IN (jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess)
      and to_char(rg23.creation_date, 'YYYY') || to_char(rg23.creation_date, 'MM') = ln_yyyymm ;


    -- Cursor for Credit availed on Input on invoices issued by I or II stage dealers (EDU CESS)
    CURSOR   Cur_cess_excise_input_stg
    IS
      SELECT NVL(SUM(credit),0) FROM JAI_CMN_RG_OTHERS JRO,JAI_CMN_RG_23AC_II_TRXS RG23,JAI_CMN_VENDOR_SITES JIPV
      WHERE jro.source_register_id  =  RG23.register_id
      and rg23.vendor_id          =  jipv.vendor_id(+)
      and rg23.vendor_site_id     =  jipv.vendor_site_id(+)
      AND JIPV.vendor_type    IN ('First Stage Dealer', 'Second Stage Dealer')
      and rg23.location_id          =  p_location_id
      and rg23.organization_id      =  p_organization_id
      and trunc(rg23.creation_date) >= p_start_date
      and trunc(rg23.creation_date) <= trunc(nvl(p_end_date,sysdate))
      and rg23.register_type        = 'A'
      and jro.source_register       = 'RG23A_P2'
      and jro.tax_type              IN (jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess)
      and to_char(rg23.creation_date, 'YYYY') || to_char(rg23.creation_date, 'MM') = ln_yyyymm ;

    CURSOR   Cur_cess_excise_input_stg_iso
    IS
      SELECT NVL(SUM(credit),0) FROM JAI_CMN_RG_OTHERS JRO,JAI_CMN_RG_23AC_II_TRXS RG23,JAI_CMN_INVENTORY_ORGS JIHO
      WHERE jro.source_register_id  =  RG23.register_id
      AND   ABS(RG23.vendor_id)     =  JIHO.organization_id
      AND   ABS(RG23.vendor_site_id)=  JIHO.location_id
      AND   JIHO.trading            = 'Y'
      AND RG23.location_id          =  p_location_id
      AND RG23.organization_id      =  p_organization_id
      AND TRUNC(RG23.creation_date) >= p_start_date
      AND TRUNC(RG23.creation_date) <= TRUNC(NVL(p_end_date,sysdate))
      AND RG23.register_type        = 'A'
      AND JRO.source_register       = 'RG23A_P2'
      AND JRO.tax_type              IN (jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess)
      and to_char(rg23.creation_date, 'YYYY') || to_char(rg23.creation_date, 'MM') = ln_yyyymm ;


    -- Cursor for Credit on capital (EDU CESS) AND Total Credit (EDU CESS)
    CURSOR cur_edu_cess_cap(p_register_type IN VARCHAR2,p_source_register IN VARCHAR2)
    IS
      SELECT round(nvl(sum(credit),0),0) FROM JAI_CMN_RG_OTHERS jro,JAI_CMN_RG_23AC_II_TRXS rg23
      WHERE jro.source_register_id = rg23.register_id
      AND rg23.location_id = p_location_id
      AND rg23.organization_id = p_organization_id
      AND trunc(rg23.creation_date) >= p_start_date
      AND trunc(rg23.creation_date) <= trunc(nvl(p_end_date,sysdate))
      AND rg23.register_type = p_register_type
      AND jro.source_register = p_source_register
      AND jro.tax_type in ( jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess)
      and to_char(rg23.creation_date, 'YYYY') || to_char(rg23.creation_date, 'MM') = ln_yyyymm ;

    -- Cursor for Credit utilised(EDU CESS)
    CURSOR cur_edu_cess_excise
    IS
      SELECT nvl(sum(debit),0) FROM JAI_CMN_RG_OTHERS jro,JAI_CMN_RG_23AC_II_TRXS rg23
      WHERE jro.source_register_id     = rg23.register_id
      AND rg23.location_id           = p_location_id
      AND rg23.organization_id       = p_organization_id
      AND trunc(rg23.creation_date) >= p_start_date
      AND trunc(rg23.creation_date) <= trunc(nvl(p_end_date,sysdate))
      AND rg23.register_type IN ('A','C')
      AND jro.source_register in ('RG23A_P2','RG23C_P2')
      AND jro.tax_type in ( jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess)
      and to_char(rg23.creation_date, 'YYYY') || to_char(rg23.creation_date, 'MM') = ln_yyyymm ;

    -- Cursor for Credit utilised (input/capital goods) (EDU CESS)
    CURSOR get_rtv_cess IS
      SELECT sum(nvl(debit,0))
      FROM JAI_CMN_RG_OTHERS
      WHERE source_type = 1
      AND tax_type in ( jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess)
      AND source_register_id in (
        SELECT jrg23_ii.register_id FROM JAI_CMN_RG_23AC_II_TRXS jrg23_ii ,JAI_CMN_RG_23AC_I_TRXS jrg23_i
        WHERE jrg23_ii.organization_id       = p_organization_id
        AND jrg23_ii.location_id           = p_location_id
        AND trunc(jrg23_ii.creation_date) >= p_start_date
        AND trunc(jrg23_ii.creation_date) <= trunc(nvl(p_end_date,sysdate))
        AND jrg23_i.transaction_type       = 'RTV'
        AND jrg23_ii.organization_id       = jrg23_i.organization_id
        AND jrg23_ii.location_id           = jrg23_i.location_id
        AND jrg23_ii.register_id_part_i    = jrg23_i.register_id
        and to_char(jrg23_ii.creation_date, 'YYYY') || to_char(jrg23_ii.creation_date, 'MM') = ln_yyyymm
        );

    CURSOR get_cgin_sales_cess IS
      SELECT sum(nvl(debit,0))
      FROM JAI_CMN_RG_OTHERS
      WHERE source_type = 1
      AND tax_type in ( jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess)
      AND source_register_id in (
        SELECT jrg23_ii.register_id FROM JAI_CMN_RG_23AC_II_TRXS jrg23_ii ,JAI_CMN_RG_23AC_I_TRXS jrg23_i,JAI_INV_ITM_SETUPS jmsi
        WHERE jrg23_ii.organization_id       = jrg23_i.organization_id
        AND jrg23_ii.location_id           = jrg23_i.location_id
        AND jrg23_ii.register_id_part_i    = jrg23_i.register_id
        AND jmsi.organization_id           = jrg23_ii.organization_id
        AND jmsi.item_class                like 'CG%'
        AND jmsi.inventory_item_id         = jrg23_ii.inventory_item_id
        AND jmsi.organization_id           = p_organization_id
        AND jrg23_ii.organization_id       = p_organization_id
        AND jrg23_ii.location_id           = p_location_id
        AND trunc(jrg23_ii.creation_date) >= p_start_date
        AND trunc(jrg23_ii.creation_date) <= trunc(nvl(p_end_date,sysdate))
        AND jrg23_i.transaction_type       <> 'RTV'
        and to_char(jrg23_ii.creation_date, 'YYYY') || to_char(jrg23_ii.creation_date, 'MM') = ln_yyyymm
        );

    -- Cursors for opening Balance (Service Tax)
    CURSOR cur_invoice_open_bal(cp_start_date IN DATE) IS
      SELECT sum(recovered_amount)
      FROM   jai_rgm_trx_refs
      WHERE  source = 'AP'
      AND    tax_type = 'Service'
      AND    trunc(creation_date) < cp_start_date
      AND    organization_id in
      (
        SELECT DISTINCT organization_id
        FROM   jai_rgm_org_regns_v
        WHERE  regime_code          = 'SERVICE'
        AND    registration_type    = 'OTHERS'
        AND    attribute_type_code  = 'PRIMARY'
        AND    attribute_code       = 'SERVICE_TAX_REGISTRATION_NO'
        AND    attribute_value      = p_registration_number
        AND    organization_id = nvl(p_operating_unit,organization_id)
      );

    CURSOR cur_dist_in(cp_start_date IN DATE) IS
      SELECT  sum(credit_amount)
      FROM jai_rgm_trx_records
      WHERE source               = 'SERVICE_DISTRIBUTE_IN'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'Service'
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(trunc(creation_date),trunc(SYSDATE))) <(NVL(cp_start_date,trunc(sysdate)));

    CURSOR cur_manual_in(cp_start_date IN DATE) IS
      SELECT sum(credit_amount)
      FROM jai_rgm_trx_records
      WHERE source               = 'MANUAL'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'Service'
      AND   source_trx_type      IN ('ADJUSTMENT-RECOVERY','RECOVERY')
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(trunc(creation_date),trunc(SYSDATE))) <(NVL(cp_start_date,trunc(sysdate)));


    CURSOR cur_ar_util_credit(cp_start_date IN DATE) IS
      SELECT SUM(recovered_amount)
      FROM   jai_rgm_trx_refs
      WHERE  source = 'AR'
      AND    tax_type = 'Service'
      AND    trunc(creation_date) < cp_start_date
      AND    organization_id IN
      (
        SELECT DISTINCT organization_id
        FROM   jai_rgm_org_regns_v
        WHERE  regime_code          = 'SERVICE'
        AND    registration_type    = 'OTHERS'
        AND    attribute_type_code  = 'PRIMARY'
        AND    attribute_code       = 'SERVICE_TAX_REGISTRATION_NO'
        AND    attribute_value      = p_registration_number
        AND    organization_id = nvl(p_operating_unit,organization_id)
      );

    CURSOR cur_ar_ser_dist_out_debit(cp_start_date IN DATE) IS
      SELECT nvl(sum(debit_amount),0)
      FROM jai_rgm_trx_records
      WHERE source               = 'SERVICE_DISTRIBUTE_OUT'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'Service'
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(trunc(creation_date),trunc(SYSDATE))) <(NVL(cp_start_date,trunc(sysdate)));

    CURSOR cur_manual_debit(cp_start_date IN DATE) IS
      SELECT nvl(sum(debit_amount),0)
      FROM jai_rgm_trx_records
      WHERE source               = 'MANUAL'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'Service'
      AND   source_trx_type      IN ( 'ADJUSTMENT-LIABILITY' , 'LIABILITY' )
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(trunc(creation_date),trunc(SYSDATE))) <(NVL(cp_start_date,trunc(sysdate)));

    CURSOR cur_payment(cp_start_date IN DATE) IS
      SELECT nvl(sum(debit_amount),0)
      FROM jai_rgm_trx_records
      WHERE source               = 'MANUAL'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = ( 'Service'  )
      AND   source_trx_type      = 'PAYMENT'
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(trunc(creation_date),trunc(SYSDATE))) <(NVL(cp_start_date,trunc(sysdate)));


    -- Cursor for Credit availed on input services (SERVICE TAX)
    CURSOR cur_st_cess IS
      SELECT nvl(sum(service_credit),0),nvl(sum(edu_cess_credit),0)
      FROM (
        SELECT jrtf1.recovered_amount service_credit ,jrtf2.recovered_amount edu_cess_credit
        FROM jai_rgm_trx_refs jrtf1 ,jai_rgm_trx_refs jrtf2
        WHERE jrtf1.source        = 'AP'
        AND     jrtf1.invoice_id    = jrtf2.invoice_id(+)
        AND     jrtf1.tax_type      = 'Service'
        AND     jrtf2.tax_type(+)   = 'SERVICE_EDUCATION_CESS'
        AND     NVL(trunc(jrtf1.creation_date),trunc(SYSDATE)) BETWEEN p_start_date AND p_end_date
        AND     to_char(jrtf1.creation_date, 'YYYY') || to_char(jrtf1.creation_date, 'MM') = ln_yyyymm
        AND     jrtf1.organization_id IN
          (
          SELECT DISTINCT organization_id
          FROM   jai_rgm_org_regns_v
          WHERE  regime_code          = 'SERVICE'
          AND    registration_type    = 'OTHERS'
          AND    attribute_type_code  = 'PRIMARY'
          AND    attribute_code       = 'SERVICE_TAX_REGISTRATION_NO'
          AND    attribute_value      = p_registration_number
          AND    organization_id = nvl(p_operating_unit,organization_id)
          )
      UNION ALL
      SELECT jrtr1.credit_amount service_credit ,jrtr2.credit_amount edu_cess_credit
      FROM jai_rgm_trx_records jrtr1,jai_rgm_trx_records jrtr2
      WHERE jrtr1.source               = 'SERVICE_DISTRIBUTE_IN'
      AND   jrtr1.regime_code          = 'SERVICE'
      AND   jrtr1.tax_type             = 'Service'
      AND   jrtr2.tax_type(+)          = 'SERVICE_EDUCATION_CESS'
      AND   jrtr1.organization_id      = jrtr2.organization_id(+)
      AND   jrtr1.source_document_id   = jrtr2.source_document_id(+)
      AND   jrtr1.regime_primary_regno = p_registration_number
      AND   (NVL(trunc(jrtr1.creation_date),trunc(SYSDATE))) BETWEEN (NVL(p_start_date,trunc(jrtr1.creation_date))) AND (NVL(p_end_date,trunc(SYSDATE)))
      AND   to_char(jrtr1.creation_date, 'YYYY') || to_char(jrtr1.creation_date, 'MM') = ln_yyyymm
      UNION ALL
      SELECT jrtr1.credit_amount service_credit ,jrtr2.credit_amount edu_cess_credit
      FROM jai_rgm_trx_records jrtr1,jai_rgm_trx_records jrtr2
      WHERE jrtr1.source               = 'MANUAL'
      AND   jrtr1.regime_code          = 'SERVICE'
      AND   jrtr1.tax_type             = 'Service'
      AND   jrtr2.tax_type(+)             = 'SERVICE_EDUCATION_CESS'
      AND   jrtr1.source_trx_type      IN ('ADJUSTMENT-RECOVERY','RECOVERY')
      AND   jrtr1.source_trx_type      = jrtr2.source_trx_type(+)
      AND   jrtr1.organization_id      = jrtr2.organization_id(+)
      AND   jrtr1.source_document_id   = jrtr2.source_document_id(+)
      AND   jrtr1.regime_primary_regno = p_registration_number
      AND   (NVL(trunc(jrtr1.creation_date),trunc(SYSDATE))) BETWEEN p_start_date AND p_end_date
      AND     to_char(jrtr1.creation_date, 'YYYY') || to_char(jrtr1.creation_date, 'MM') = ln_yyyymm
      )
      ;

    -- Cursors for Credit utilised (services)
    CURSOR cur_ar_util_credt IS
    SELECT SUM(recovered_amount) FROM   jai_rgm_trx_refs
    WHERE  source = 'AR'
    AND    tax_type = 'Service'
    AND    organization_id IN
      (
      SELECT DISTINCT organization_id
      FROM   jai_rgm_org_regns_v
      WHERE  regime_code          = 'SERVICE'
      AND    registration_type    = 'OTHERS'
      AND    attribute_type_code  = 'PRIMARY'
      AND    attribute_code       = 'SERVICE_TAX_REGISTRATION_NO'
      AND    attribute_value      = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      )
    AND   (NVL(TRUNC(creation_date),SYSDATE)) BETWEEN (NVL(p_start_date,SYSDATE)) AND (NVL(p_end_date,SYSDATE))
    AND     to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm
    ;


    CURSOR cur_ar_ser_dist_out_debt IS
      SELECT nvl(sum(debit_amount),0) FROM jai_rgm_trx_records
      WHERE source               = 'SERVICE_DISTRIBUTE_OUT'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'Service'
      AND   regime_primary_regno = p_registration_number
      AND   organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(TRUNC(creation_date),SYSDATE)) BETWEEN (NVL(p_start_date,SYSDATE)) AND (NVL(p_end_date,SYSDATE))
      AND   to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm
      ;


    CURSOR cur_manual_debt IS
      SELECT nvl(sum(debit_amount),0) FROM jai_rgm_trx_records
      WHERE source               = 'MANUAL'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'Service'
      AND   source_trx_type      IN ( 'ADJUSTMENT-LIABILITY' , 'LIABILITY' )
      AND   regime_primary_regno = p_registration_number
      AND   organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(TRUNC(creation_date),SYSDATE)) BETWEEN (NVL(p_start_date,SYSDATE)) AND (NVL(p_end_date,SYSDATE))
      AND   to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm
      ;



    CURSOR cur_paymnt IS
      SELECT nvl(sum(debit_amount),0)
      FROM jai_rgm_trx_records
      WHERE source               = 'MANUAL'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'Service'
      AND   source_trx_type      = 'PAYMENT'
      AND   regime_primary_regno = p_registration_number
      AND   organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(TRUNC(creation_date),SYSDATE)) BETWEEN (NVL(p_start_date,SYSDATE)) AND (NVL(p_end_date,SYSDATE))
      AND   to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm
      ;


    -- Cursors for opening balance
    CURSOR cur_invoice_open_bal1(cp_start_date IN DATE) IS
      SELECT sum(recovered_amount) FROM   jai_rgm_trx_refs
      WHERE  source = 'AP'
      AND    tax_type = 'SERVICE_EDUCATION_CESS'
      AND    trunc(creation_date) < cp_start_date
      AND    organization_id in
      (
        SELECT DISTINCT organization_id
        FROM   jai_rgm_org_regns_v
        WHERE  regime_code          = 'SERVICE'
        AND    registration_type    = 'OTHERS'
        AND    attribute_type_code  = 'PRIMARY'
        AND    attribute_code       = 'SERVICE_TAX_REGISTRATION_NO'
        AND    attribute_value      = p_registration_number
        AND    organization_id = nvl(p_operating_unit,organization_id)
      );

    CURSOR cur_dist_in1(cp_start_date IN DATE) IS
      SELECT sum(credit_amount) FROM jai_rgm_trx_records
      WHERE source               = 'SERVICE_DISTRIBUTE_IN'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'SERVICE_EDUCATION_CESS'
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(trunc(creation_date),trunc(SYSDATE))) <(NVL(cp_start_date,trunc(sysdate)));

    CURSOR cur_manual_in1(cp_start_date IN DATE) IS
      SELECT sum(credit_amount)
      FROM jai_rgm_trx_records
      WHERE source               = 'MANUAL'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'SERVICE_EDUCATION_CESS'
      AND   source_trx_type      IN ('ADJUSTMENT-RECOVERY','RECOVERY')
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(trunc(creation_date),trunc(SYSDATE))) <(NVL(cp_start_date,trunc(sysdate)));


    CURSOR cur_ar_util_credit1(cp_start_date IN DATE) IS
      SELECT SUM(recovered_amount)
      FROM   jai_rgm_trx_refs
      WHERE  source = 'AR'
      AND    tax_type = 'SERVICE_EDUCATION_CESS'
      AND    trunc(creation_date) < cp_start_date
      AND    organization_id IN
      (
        SELECT DISTINCT organization_id
        FROM   jai_rgm_org_regns_v
        WHERE  regime_code          = 'SERVICE'
        AND    registration_type    = 'OTHERS'
        AND    attribute_type_code  = 'PRIMARY'
        AND    attribute_code       = 'SERVICE_TAX_REGISTRATION_NO'
        AND    attribute_value      = p_registration_number
        AND    organization_id = nvl(p_operating_unit,organization_id)
      );



    CURSOR cur_ar_ser_dist_out_debit1(cp_start_date IN DATE) IS
      SELECT nvl(sum(debit_amount),0)
      FROM jai_rgm_trx_records
      WHERE source               = 'SERVICE_DISTRIBUTE_OUT'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'SERVICE_EDUCATION_CESS'
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(trunc(creation_date),trunc(SYSDATE))) <(NVL(cp_start_date,trunc(sysdate)));

    CURSOR cur_manual_debit1(cp_start_date IN DATE) IS
      SELECT nvl(sum(debit_amount),0)
      FROM jai_rgm_trx_records
      WHERE source               = 'MANUAL'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'SERVICE_EDUCATION_CESS'
      AND   source_trx_type      IN ( 'ADJUSTMENT-LIABILITY' , 'LIABILITY' )
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(trunc(creation_date),trunc(SYSDATE))) <(NVL(cp_start_date,trunc(sysdate)));

    CURSOR cur_payment1(cp_start_date IN DATE) IS
      SELECT nvl(sum(debit_amount),0)
      FROM jai_rgm_trx_records
      WHERE source               = 'MANUAL'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             =  'SERVICE_EDUCATION_CESS'
      AND   source_trx_type      = 'PAYMENT'
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(trunc(creation_date),trunc(SYSDATE))) < (NVL(cp_start_date,trunc(sysdate)));

    -- Cursors for the Credit utilised (services)
    CURSOR cur_ar_util_credt1 IS
      SELECT SUM(recovered_amount) FROM   jai_rgm_trx_refs
      WHERE  source = 'AR'
      AND    tax_type = 'SERVICE_EDUCATION_CESS'
      AND    organization_id IN
        (
        SELECT DISTINCT organization_id
        FROM   jai_rgm_org_regns_v
        WHERE  regime_code          = 'SERVICE'
        AND    registration_type    = 'OTHERS'
        AND    attribute_type_code  = 'PRIMARY'
        AND    attribute_code       = 'SERVICE_TAX_REGISTRATION_NO'
        AND    attribute_value      = p_registration_number
        AND    organization_id = nvl(p_operating_unit,organization_id)
        )
      AND   (NVL(TRUNC(creation_date),SYSDATE)) BETWEEN (NVL(p_start_date,SYSDATE)) AND (NVL(p_end_date,SYSDATE))
      AND   to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm ;


    CURSOR cur_ar_ser_dist_out_debt1 IS
      SELECT nvl(sum(debit_amount),0) FROM jai_rgm_trx_records
      WHERE source               = 'SERVICE_DISTRIBUTE_OUT'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'SERVICE_EDUCATION_CESS'
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      AND   (NVL(TRUNC(creation_date),SYSDATE)) BETWEEN (NVL(p_start_date,SYSDATE)) AND (NVL(p_end_date,SYSDATE))
      AND   to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm
      ;


    CURSOR cur_manual_debt1 IS
      SELECT nvl(sum(debit_amount),0)
      FROM jai_rgm_trx_records
      WHERE source               = 'MANUAL'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'SERVICE_EDUCATION_CESS'
      AND   source_trx_type      IN ( 'ADJUSTMENT-LIABILITY' , 'LIABILITY' )
      AND   regime_primary_regno = p_registration_number
      AND    organization_id = nvl(p_operating_unit,organization_id)
      and   (nvl(trunc(creation_date),sysdate)) between (nvl(p_start_date,sysdate)) and (nvl(p_end_date,sysdate))
      AND   to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm
      ;


    CURSOR cur_paymnt1 IS
      SELECT nvl(sum(debit_amount),0) FROM jai_rgm_trx_records
      WHERE source               = 'MANUAL'
      AND   regime_code          = 'SERVICE'
      AND   tax_type             = 'SERVICE_EDUCATION_CESS'
      AND   source_trx_type      = 'PAYMENT'
      AND   regime_primary_regno = p_registration_number
      AND   organization_id = nvl(p_operating_unit,organization_id)
      and   (nvl(trunc(creation_date),sysdate)) between (nvl(p_start_date,sysdate)) and (nvl(p_end_date,sysdate))
      AND   to_char(creation_date, 'YYYY') || to_char(creation_date, 'MM') = ln_yyyymm
      ;

    CURSOR cur_dtls(
      p_location_id     IN NUMBER,
      p_organization_id IN NUMBER,
      p_start_date      IN DATE,
      p_end_date        IN DATE)
    IS
      SELECT
        SUM(DECODE(register_type, 'A', nvl(cr_basic_ed,0) + nvl(cr_additional_ed,0) + nvl(cr_other_ed,0),0)) credit_availed_on_inputs,
        ROUND(SUM(DECODE(register_type, 'C', nvl(cr_basic_ed,0) + nvl(cr_additional_ed,0) + nvl(cr_other_ed,0),0)), 0) credit_availed_on_cap_goods,
        ROUND(SUM(NVL(cr_basic_ed,0) + nvl(cr_additional_ed,0) + nvl(cr_other_ed,0)), 0) total_credit_availed,
        ROUND(SUM(nvl(dr_basic_ed,0) + nvl(dr_additional_ed,0) + nvl(dr_other_ed,0)), 0) credit_utilized ,
        to_char(creation_date, 'YYYY') year,
        to_char(creation_date, 'MM')   month
      FROM    JAI_CMN_RG_23AC_II_TRXS
      WHERE   location_id = p_location_id
      AND     organization_id = p_organization_id
      AND     trunc(creation_date) >= p_start_date
      AND     trunc(creation_date) <= trunc(nvl(p_end_date,sysdate))
      group by
        to_char(creation_date, 'MM'),
        to_char(creation_date, 'YYYY')
      ORDER BY
        to_char(creation_date, 'YYYY'),
        to_char(creation_date, 'MM') ;

   lv_date_format VARCHAR2(10) ;
   ld_start_date  VARCHAR2(10) ;

  BEGIN

    lv_date_format := 'DD/MM/YYYY' ;
    lv_record_header := 'CENVAT_CREDIT_DETAIL' ;
    lv_rt_type       := 1 ;
    lv_return_no     := 1 ;
    lv_data_prd_type := 'M' ;

    FOR dtls IN cur_dtls( p_location_id, p_organization_id,p_start_date,p_end_date)

    LOOP

      ln_op_bal_cenvat                := NULL;
      ln_credit_input_cenvat          := NULL;
      ln_credit_input_dlr_cenvat      := NULL;
      ln_credit_capital_cenvat        := NULL;
      ln_credit_total_cenvat          := NULL;
      ln_credit_utilised_ic_cenvat    := NULL;
      ln_credit_utilised_cenvat       := NULL;
      ln_clos_bal_cenvat              := NULL;
      ln_op_bal_edu_cess              := NULL;
      ln_credit_input_edu_cess        := NULL;
      ln_credit_input_dlr_edu_cess    := NULL;
      ln_credit_capital_edu_cess      := NULL;
      ln_credit_total_edu_cess        := NULL;
      ln_credit_utilised_ic_edu_cess  := NULL;
      ln_credit_utilised_edu_cess     := NULL;
      ln_clos_bal_edu_cess            := NULL;
      ln_op_bal_st                    := NULL;
      ln_credit_service_st            := NULL;
      ln_credit_total_st              := NULL;
      ln_credit_utilised_ds_st        := NULL;
      ln_clos_bal_st                  := NULL;
      ln_op_bal_st_edu_cess           := NULL;
      ln_credit_service_st_edu_cess   := NULL;
      ln_credit_total_st_edu_cess     := NULL;
      ln_credit_uti_ds_st_edu_cess    := NULL;
      ln_clos_bal_st_edu_cess         := NULL;
--      ln_closed_input_manf            := NULL;
--      ln_closed_input_manf_iso        := NULL;
--      ln_closed_input_cust            := NULL;
      ln_closed_input_stg             := NULL;
      ln_closed_input_stg_iso         := NULL;
      ln_rtv_amount                   := NULL;
      ln_cgin_sale_amt                := NULL;
      ln_edu_cess_excise_manf         := NULL;
      ln_edu_cess_excise_manf_iso     := NULL;
      ln_edu_cess_excise_cust         := NULL;
      ln_edu_cess_excise_stg          := NULL;
      ln_edu_cess_excise_stg_iso      := NULL;
      ln_edu_cess_excise              := NULL;
      ln_rtv_cess                     := NULL;
      ln_cgin_sales_cess              := NULL;
      lv_inv_open_bal                 := NULL;
      lv_open_dist_bal                := NULL;
      lv_ar_util_credit               := NULL;
      lv_ar_ser_dist_out_debit        := NULL;
      lv_manual_bal                   := NULL;
      lv_manual_debit_bal             := NULL;
      lv_manual_payment               := NULL;
      lv_st_credit_avld               := NULL;
      lv_cess_credit_avld             := NULL;
      ln_ar_util_credit               := NULL;
      ln_ar_ser_dist_out_debit        := NULL;
      lv_manual_debit                 := NULL;
      lv_payment                      := NULL;
      ln_yyyymm                       := NULL;
      ld_start_date                   := NULL;



      ln_yyyymm := dtls.year || dtls.month ;
      ld_start_date := to_date('01-'|| dtls.month || '-' || dtls.year,'DD/MM/YYYY')  ;


      -- for cenvat opening balance
      OPEN   cur_opening_balance_cenvat(ld_start_date) ;
      FETCH  cur_opening_balance_cenvat INTO ln_op_bal_cenvat;
      CLOSE  cur_opening_balance_cenvat;

      -- for Credit availed on Input on invoices issued by manufactureres
      OPEN   Cur_crdit_input_manf;
      FETCH  Cur_crdit_input_manf INTO ln_closed_input_manf;
      CLOSE  Cur_crdit_input_manf;

      OPEN   Cur_crdit_input_manf_iso;
      FETCH  Cur_crdit_input_manf_iso INTO ln_closed_input_manf_iso;
      CLOSE  Cur_crdit_input_manf_iso;

      OPEN   Cur_crdit_input_cust;
      FETCH  Cur_crdit_input_cust INTO ln_closed_input_cust;
      CLOSE  Cur_crdit_input_cust;

      ln_credit_input_cenvat := ROUND(NVL(ln_closed_input_manf, 0) + NVL(ln_closed_input_manf_iso, 0) + NVL(ln_closed_input_cust, 0) ,0);

      -- for Credit availed on Input on invoices issued by I or II stage dealers
      OPEN  Cur_crdit_input_stg;
      FETCH Cur_crdit_input_stg INTO ln_closed_input_stg;
      CLOSE Cur_crdit_input_stg;
      OPEN  Cur_crdit_input_stg_iso;
      FETCH Cur_crdit_input_stg_iso INTO ln_closed_input_stg_iso;
      CLOSE Cur_crdit_input_stg_iso;
      ln_credit_input_dlr_cenvat:= ROUND(NVL(ln_closed_input_stg, 0) + NVL(ln_closed_input_stg_iso, 0),0);

      -- for Credit on Inputs
      --ln_credit_input_cenvat := dtls.credit_availed_on_inputs ;

      -- for Credit on capital
      ln_credit_capital_cenvat := dtls.credit_availed_on_cap_goods;

      -- for total Credit
      --ln_credit_total_cenvat := dtls.total_credit_availed;

      ln_credit_total_cenvat := ln_credit_input_cenvat + ln_credit_input_dlr_cenvat + ln_credit_capital_cenvat ;

      -- for Credit utilised (input/capital goods)
      OPEN  get_rtv_amount;
      FETCH get_rtv_amount INTO ln_rtv_amount;
      CLOSE get_rtv_amount;

      OPEN get_cgin_sales;
      FETCH get_cgin_sales INTO ln_cgin_sale_amt;
      CLOSE get_cgin_sales;

      ln_credit_utilised_ic_cenvat:= ROUND( nvl(ln_rtv_amount,0) + nvl(ln_cgin_sale_amt,0));

      -- for Credit utilised
      ln_credit_utilised_cenvat :=  round( nvl(dtls.credit_utilized,0) - nvl(ln_credit_utilised_ic_cenvat,0) );

      --for closing balance
      ln_clos_bal_cenvat := round((nvl(ln_op_bal_cenvat,0) + nvl(ln_credit_total_cenvat,0) - nvl(ln_credit_utilised_cenvat,0) - nvl(ln_credit_utilised_ic_cenvat,0)),0);

      -- for Opening Balance (EDU CESS)
      OPEN cur_opening_bal_edu_cess(ld_start_date);
      FETCH cur_opening_bal_edu_cess INTO ln_op_bal_edu_cess;
      CLOSE cur_opening_bal_edu_cess;

      -- for Credit availed on Input on invoices issued by manufactureres (EDU CESS)
      OPEN  Cur_cess_excise_input_manf;
      FETCH Cur_cess_excise_input_manf INTO ln_edu_cess_excise_manf;
      CLOSE Cur_cess_excise_input_manf;
      OPEN  Cur_cess_excise_input_manf_iso;
      FETCH Cur_cess_excise_input_manf_iso INTO ln_edu_cess_excise_manf_iso;
      CLOSE Cur_cess_excise_input_manf_iso;
      OPEN  Cur_cess_excise_input_cust;
      FETCH Cur_cess_excise_input_cust INTO ln_edu_cess_excise_cust;
      CLOSE Cur_cess_excise_input_cust;
      ln_credit_input_edu_cess := ROUND(NVL(ln_edu_cess_excise_manf, 0) + NVL(ln_edu_cess_excise_manf_iso, 0) + NVL(ln_edu_cess_excise_cust, 0), 0);

      -- for Credit availed on Input on invoices issued by I or II stage dealers (EDU CESS)
      OPEN  Cur_cess_excise_input_stg;
      FETCH Cur_cess_excise_input_stg INTO ln_edu_cess_excise_stg;
      CLOSE Cur_cess_excise_input_stg;
      OPEN  Cur_cess_excise_input_stg_iso;
      FETCH Cur_cess_excise_input_stg_iso INTO ln_edu_cess_excise_stg_iso;
      CLOSE Cur_cess_excise_input_stg_iso;
      ln_credit_input_dlr_edu_cess := ROUND(NVL(ln_edu_cess_excise_stg, 0) + NVL(ln_edu_cess_excise_stg_iso, 0),0);

      -- for Credit on capital (EDU CESS)
      OPEN  cur_edu_cess_cap('C','RG23C_P2');
      FETCH cur_edu_cess_cap INTO ln_credit_capital_edu_cess;
      CLOSE cur_edu_cess_cap;

      -- for Total Credit (EDU CESS)
      OPEN  cur_edu_cess_cap('A','RG23A_P2');
      FETCH cur_edu_cess_cap INTO ln_edu_cess_excise;
      CLOSE cur_edu_cess_cap;
      ln_credit_total_edu_cess := round((nvl( ln_edu_cess_excise,0) + nvl( ln_credit_capital_edu_cess,0)),0);

      -- for Credit utilised (input/capital goods) (EDU CESS)
      OPEN  get_rtv_cess;
      FETCH get_rtv_cess INTO ln_rtv_cess;
      CLOSE get_rtv_cess;

      OPEN  get_cgin_sales_cess;
      FETCH get_cgin_sales_cess INTO ln_cgin_sales_cess;
      CLOSE get_cgin_sales_cess;

      ln_credit_utilised_ic_edu_cess := round ( nvl(ln_rtv_cess,0) + nvl(ln_cgin_sales_cess,0) );

      -- for Credit utilised(EDU CESS)
      OPEN  cur_edu_cess_excise;
      FETCH cur_edu_cess_excise INTO ln_edu_cess_excise;
      CLOSE cur_edu_cess_excise;
      ln_credit_utilised_edu_cess := round( nvl(ln_edu_cess_excise,0) - nvl(ln_credit_utilised_ic_edu_cess,0),0 );

      -- for closing balance (EDU CESS)

      ln_clos_bal_edu_cess := round(nvl (ln_op_bal_edu_cess,0) + nvl( ln_credit_total_edu_cess,0) - nvl(ln_credit_utilised_edu_cess,0) - nvl(ln_credit_utilised_ic_edu_cess,0) ,0);

      -- for opening Balance (Service Tax)

      OPEN  cur_invoice_open_bal(ld_start_date) ;
      FETCH cur_invoice_open_bal INTO lv_inv_open_bal ;
      CLOSE cur_invoice_open_bal ;

      OPEN  cur_dist_in(ld_start_date) ;
      FETCH cur_dist_in INTO lv_open_dist_bal ;
      CLOSE cur_dist_in ;

      OPEN cur_manual_in(ld_start_date) ;
      FETCH cur_manual_in INTO lv_manual_bal ;
      CLOSE cur_manual_in ;

      OPEN cur_manual_debit(ld_start_date) ;
      FETCH cur_manual_debit INTO lv_manual_debit_bal ;
      CLOSE cur_manual_debit ;

      OPEN  cur_ar_util_credit(ld_start_date) ;
      FETCH cur_ar_util_credit INTO lv_ar_util_credit ;
      CLOSE cur_ar_util_credit ;

      OPEN cur_ar_ser_dist_out_debit(ld_start_date) ;
      FETCH cur_ar_ser_dist_out_debit INTO lv_ar_ser_dist_out_debit ;
      CLOSE cur_ar_ser_dist_out_debit ;

      OPEN cur_payment(ld_start_date) ;
      FETCH cur_payment INTO lv_manual_payment ;
      CLOSE cur_payment ;

      ln_op_bal_st := round(( nvl(lv_open_dist_bal,0) + nvl(lv_inv_open_bal,0) + nvl(lv_manual_bal,0) - nvl(lv_ar_util_credit,0) - nvl(lv_ar_ser_dist_out_debit,0) - nvl(lv_manual_debit_bal,0) + nvl(lv_manual_payment,0)),0) ;

      -- for Credit availed on input services (SERVICE TAX)
      OPEN cur_st_cess;
      FETCH cur_st_cess INTO lv_st_credit_avld,lv_cess_credit_avld;
      CLOSE cur_st_cess;
      ln_credit_service_st := ROUND(lv_st_credit_avld, 0);

      -- for total credit(SERVICE TAX)
      ln_credit_total_st := round((nvl( ln_op_bal_st,0 ) + nvl( ln_credit_service_st,0 )),0);

      -- for Credit utilised (services)
      OPEN  cur_ar_util_credt ;
      FETCH cur_ar_util_credt INTO ln_ar_util_credit ;
      CLOSE cur_ar_util_credt ;

      OPEN  cur_ar_ser_dist_out_debt ;
      FETCH cur_ar_ser_dist_out_debt INTO ln_ar_ser_dist_out_debit ;
      CLOSE cur_ar_ser_dist_out_debt ;

      OPEN  cur_manual_debt ;
      FETCH cur_manual_debt INTO lv_manual_debit;
      CLOSE cur_manual_debt ;

      OPEN  cur_paymnt ;
      FETCH cur_paymnt INTO lv_payment;
      CLOSE cur_paymnt ;

      ln_credit_utilised_ds_st := ROUND(( nvl(ln_ar_util_credit,0) + nvl(ln_ar_ser_dist_out_debit,0) + nvl(lv_manual_debit,0) - nvl(lv_payment,0)),0);

      -- for closing balance (SERVICE TAX)

      ln_clos_bal_st := round((nvl(ln_op_bal_st, 0) + nvl(ln_credit_total_st,0 ) - nvl( ln_credit_utilised_ds_st,0 )),0) ;

        -- for opening balance
      OPEN  cur_invoice_open_bal1(ld_start_date) ;
      FETCH cur_invoice_open_bal1 INTO lv_inv_open_bal ;
      CLOSE cur_invoice_open_bal1 ;

      OPEN  cur_dist_in1(ld_start_date) ;
      FETCH cur_dist_in1 INTO lv_open_dist_bal ;
      CLOSE cur_dist_in1 ;

      OPEN cur_manual_in1(ld_start_date) ;
      FETCH cur_manual_in1 INTO lv_manual_bal ;
      CLOSE cur_manual_in1 ;

      OPEN cur_manual_debit1(ld_start_date) ;
      FETCH cur_manual_debit1 INTO lv_manual_debit_bal ;
      CLOSE cur_manual_debit1 ;

      OPEN  cur_ar_util_credit1(ld_start_date) ;
      FETCH cur_ar_util_credit1 INTO lv_ar_util_credit ;
      CLOSE cur_ar_util_credit1 ;

      OPEN cur_ar_ser_dist_out_debit1(ld_start_date) ;
      FETCH cur_ar_ser_dist_out_debit1 INTO lv_ar_ser_dist_out_debit ;
      CLOSE cur_ar_ser_dist_out_debit1 ;

      OPEN cur_payment1(ld_start_date) ;
      FETCH cur_payment1 INTO lv_manual_payment ;
      CLOSE cur_payment1 ;

      ln_op_bal_st_edu_cess := round(( nvl(lv_open_dist_bal,0) + nvl(lv_inv_open_bal,0) + nvl(lv_manual_bal,0) - nvl(lv_ar_util_credit,0) - nvl(lv_ar_ser_dist_out_debit,0) - nvl(lv_manual_debit_bal,0) + nvl(lv_manual_payment,0)),0) ;

      -- for Credit availed on input services

      ln_credit_service_st_edu_cess := ROUND(lv_cess_credit_avld, 0);

      -- for total credit
      ln_credit_total_st_edu_cess := round((nvl( ln_op_bal_st_edu_cess,0 ) + nvl( ln_credit_service_st_edu_cess ,0 )),0);

      -- for the Credit utilised (services)
      OPEN  cur_ar_util_credt1 ;
      FETCH cur_ar_util_credt1 INTO ln_ar_util_credit ;
      CLOSE cur_ar_util_credt1 ;

      OPEN  cur_ar_ser_dist_out_debt1 ;
      FETCH cur_ar_ser_dist_out_debt1 INTO ln_ar_ser_dist_out_debit ;
      CLOSE cur_ar_ser_dist_out_debt1 ;

      OPEN cur_manual_debt1 ;
      FETCH cur_manual_debt1 INTO lv_manual_debit;
      CLOSE cur_manual_debt1 ;

      OPEN cur_paymnt1 ;
      FETCH cur_paymnt1 INTO lv_payment;
      CLOSE cur_paymnt1 ;

      ln_credit_uti_ds_st_edu_cess := ROUND(( nvl(ln_ar_util_credit,0) + nvl(ln_ar_ser_dist_out_debit,0) + nvl(lv_manual_debit,0) - nvl(lv_payment,0)), 0);

      -- for closing balance

      ln_clos_bal_st_edu_cess := round((nvl(ln_op_bal_st_edu_cess, 0) + nvl( ln_credit_total_st_edu_cess,0 ) - nvl( ln_credit_uti_ds_st_edu_cess,0 )),0) ;

      create_cenvat_details(
        p_record_header              => lv_record_header,
        p_rt_type                    => lv_rt_type,
        p_ecc                        => lv_ecc,
        p_yyyymm                     => ln_yyyymm,
        p_return_no                  => lv_return_no,
        p_data_prd_type              => lv_data_prd_type,
        p_op_bal_cenvat              => ln_op_bal_cenvat,
        p_credit_input_cenvat        => ln_credit_input_cenvat,
        p_credit_input_dlr_cenvat    => ln_credit_input_dlr_cenvat,
        p_credit_capital_cenvat      => ln_credit_capital_cenvat,
        p_credit_service_cenvat      => ln_credit_service_cenvat,
        p_credit_total_cenvat        => ln_credit_total_cenvat,
        p_credit_utilised_cenvat     => ln_credit_utilised_cenvat,
        p_credit_utilised_ic_cenvat  => ln_credit_utilised_ic_cenvat,
        p_credit_utilised_ds_cenvat  => ln_credit_utilised_ds_cenvat,
        p_clos_bal_cenvat            => ln_clos_bal_cenvat,
        p_op_bal_aed_tta             => ln_op_bal_aed_tta,
        p_credit_input_aed_tta       => ln_credit_input_aed_tta,
        p_credit_input_dlr_aed_tta   => ln_credit_input_dlr_aed_tta,
        p_credit_capital_aed_tta     => ln_credit_capital_aed_tta,
        p_credit_service_aed_tta     => ln_credit_service_aed_tta,
        p_credit_total_aed_tta       => ln_credit_total_aed_tta,
        p_credit_utilised_aed_tta    => ln_credit_utilised_aed_tta,
        p_credit_utilised_ic_aed_tta => ln_credit_utilised_ic_aed_tta,
        p_credit_utilised_ds_aed_tta => ln_credit_utilised_ds_aed_tta,
        p_clos_bal_aed_tta           => ln_clos_bal_aed_tta,
        p_op_bal_aed_pmt             => ln_op_bal_aed_pmt,
        p_credit_input_aed_pmt       => ln_credit_input_aed_pmt,
        p_credit_input_dlr_aed_pmt   => ln_credit_input_dlr_aed_pmt,
        p_credit_capital_aed_pmt     => ln_credit_capital_aed_pmt,
        p_credit_service_aed_pmt     => ln_credit_service_aed_pmt,
        p_credit_total_aed_pmt       => ln_credit_total_aed_pmt,
        p_credit_utilised_aed_pmt    => ln_credit_utilised_aed_pmt,
        p_credit_utilised_ic_aed_pmt => ln_credit_utilised_ic_aed_pmt,
        p_credit_utilised_ds_aed_pmt => ln_credit_utilised_ds_aed_pmt,
        p_clos_bal_aed_pmt           => ln_clos_bal_aed_pmt,
        p_op_bal_nccd                => ln_op_bal_nccd,
        p_credit_input_nccd          => ln_credit_input_nccd,
        p_credit_input_dlr_nccd      => ln_credit_input_dlr_nccd,
        p_credit_capital_nccd        => ln_credit_capital_nccd,
        p_credit_service_nccd        => ln_credit_service_nccd,
        p_credit_total_nccd          => ln_credit_total_nccd,
        p_credit_utilised_nccd       => ln_credit_utilised_nccd,
        p_credit_utilised_ic_nccd    => ln_credit_utilised_ic_nccd,
        p_credit_utilised_ds_nccd    => ln_credit_utilised_ds_nccd,
        p_clos_bal_nccd              => ln_clos_bal_nccd,
        p_op_bal_adet                => ln_op_bal_adet,
        p_credit_input_adet          => ln_credit_input_adet,
        p_credit_input_dlr_adet      => ln_credit_input_dlr_adet,
        p_credit_capital_adet        => ln_credit_capital_adet,
        p_credit_service_adet        => ln_credit_service_adet,
        p_credit_total_adet          => ln_credit_total_adet,
        p_credit_utilised_adet       => ln_credit_utilised_adet,
        p_credit_utilised_ic_adet    => ln_credit_utilised_ic_adet,
        p_credit_utilised_ds_adet    => ln_credit_utilised_ds_adet,
        p_clos_bal_adet              => ln_clos_bal_adet,
        p_op_bal_edu_cess            => ln_op_bal_edu_cess,
        p_credit_input_edu_cess      => ln_credit_input_edu_cess,
        p_credit_input_dlr_edu_cess  => ln_credit_input_dlr_edu_cess,
        p_credit_capital_edu_cess    => ln_credit_capital_edu_cess,
        p_credit_service_edu_cess    => ln_credit_service_edu_cess,
        p_credit_total_edu_cess      => ln_credit_total_edu_cess,
        p_credit_utilised_edu_cess   => ln_credit_utilised_edu_cess,
        p_credit_utilised_ic_edu_cess=> ln_credit_utilised_ic_edu_cess,
        p_credit_utilised_ds_edu_cess=> ln_credit_utilised_ds_edu_cess,
        p_clos_bal_edu_cess          => ln_clos_bal_edu_cess,
        p_op_bal_st                  => ln_op_bal_st,
        p_credit_input_st            => ln_credit_input_st,
        p_credit_input_dlr_st        => ln_credit_input_dlr_st,
        p_credit_capital_st          => ln_credit_capital_st,
        p_credit_service_st          => ln_credit_service_st,
        p_credit_total_st            => ln_credit_total_st,
        p_credit_utilised_st         => ln_credit_utilised_st,
        p_credit_utilised_ic_st      => ln_credit_utilised_ic_st,
        p_credit_utilised_ds_st      => ln_credit_utilised_ds_st,
        p_clos_bal_st                => ln_clos_bal_st,
        p_op_bal_st_edu_cess         => ln_op_bal_st_edu_cess,
        p_credit_input_st_edu_cess   => ln_credit_input_st_edu_cess,
        p_cre_input_dlr_st_edu_cess  => ln_cre_input_dlr_st_edu_cess,
        p_credit_capital_st_edu_cess => ln_credit_capital_st_edu_cess,
        p_credit_service_st_edu_cess => ln_credit_service_st_edu_cess,
        p_credit_total_st_edu_cess   => ln_credit_total_st_edu_cess,
        p_creln_dit_uti_st_edu_cess  => ln_creln_dit_uti_st_edu_cess,
        p_credit_uti_ic_st_edu_cess  => ln_credit_uti_ic_st_edu_cess,
        p_credit_uti_ds_st_edu_cess  => ln_credit_uti_ds_st_edu_cess,
        p_clos_bal_st_edu_cess       => ln_clos_bal_st_edu_cess); -- procedure for formatting and adding the value in flat file

    END LOOP;

  END populate_cenvat_credit_details;

  -- to populate input details
  PROCEDURE populate_input_details
  (   p_end_date        IN  DATE,
      p_location_id     IN  NUMBER,
      p_organization_id IN  NUMBER,
      p_start_date      IN  DATE
  )
  IS
    lv_record_header        varchar2(50);
    lv_rt_type              varchar2(2);
    p_ecc                   varchar2(15);
    ln_yyyymm               number;
    lv_return_no            varchar2(3);
    lv_ceth                 varchar2(8);
    lv_ctsh                 varchar2(8);
    lv_uqc                  varchar2(8);
    ln_ln_total_qty_recd    number;
    ln_value_good_recd      number;
    lv_notf_no              varchar2(8);
    lv_notf_sno             varchar2(10);

    Cursor c_year_month
    is
    select to_char(p_start_date, 'YYYYMM') from dual ;

    Cursor c_cur_dtls
    is
    select
      sum(nvl(basic_ed,0) + nvl(additional_ed,0) + nvl(other_ed,0)) total_value,
      sum(nvl(quantity_received,0)) total_quantity,
      msi.attribute4 item_tariff,
      msi.primary_uom_code
    from
      JAI_CMN_RG_23AC_I_TRXS jrp,
      mtl_system_items msi
    where
      jrp.organization_id = msi.organization_id
      and jrp.inventory_item_id = msi.inventory_item_id
      and jrp.location_id = p_location_id
      AND jrp.organization_id = p_organization_id
      AND trunc(jrp.creation_date) >= p_start_date
      AND trunc(jrp.creation_date) <= trunc(nvl(p_end_date,sysdate))
      group by
        to_char(jrp.creation_date, 'MM'),
        to_char(jrp.creation_date, 'YYYY'),
        msi.attribute4  , -- group by Item Tariff Head
        msi.primary_uom_code
      ORDER BY
        to_char(jrp.creation_date, 'YYYY'),
        to_char(jrp.creation_date, 'MM') ;

  BEGIN

    lv_record_header := 'INPUT_DETAIL' ;
    lv_rt_type       := 1 ;
    lv_return_no     := 1 ;

    open c_year_month ;
    fetch c_year_month into ln_yyyymm ;
    close c_year_month ;

    FOR rec in c_cur_dtls
    LOOP
      lv_ceth := null ;
      lv_uqc  := null ;
      ln_ln_total_qty_recd := null ;
      ln_value_good_recd   := null ;

      FND_FILE.put_line(FND_FILE.log, ' rec.total_quantity : ' || rec.total_quantity ||   ' rec.total_value : ' || rec.total_value ) ;

      lv_ceth := substr(rec.item_tariff,1,8) ;
      lv_uqc  := substr(rec.primary_uom_code,1,8) ;
      FND_FILE.put_line(FND_FILE.log, '1' ) ;
      ln_ln_total_qty_recd := rec.total_quantity ;
      FND_FILE.put_line(FND_FILE.log, '2' ) ;
      ln_value_good_recd   := rec.total_value ;

       FND_FILE.put_line(FND_FILE.log, '3' ) ;
      create_input_details(
        p_record_header     =>  lv_record_header,
        p_rt_type           =>  lv_rt_type,
        p_ecc               =>  lv_ecc,
        p_yyyymm            =>  ln_yyyymm,
        p_return_no         =>  lv_return_no,
        p_ceth              =>  lv_ceth,
        p_ctsh              =>  lv_ctsh,
        p_uqc               =>  lv_uqc,
        p_ln_total_qty_recd =>  ln_ln_total_qty_recd,
        p_value_good_recd   =>  ln_value_good_recd,
        p_notf_no           =>  lv_notf_no,
        p_notf_sno          =>  lv_notf_sno);

       FND_FILE.put_line(FND_FILE.log, '4' ) ;
    END LOOP ;

  END populate_input_details;

  -- to populate payment details
  PROCEDURE populate_payment_details
  (p_start_date   in DATE
  )
  IS
    lv_record_header              varchar2(50);
    lv_rt_type                    varchar2(2);
    p_ecc                        varchar2(15);
    ln_yyyymm                     number;
    lv_return_no                  varchar2(3);
    ln_arrear_rule8_current       number;
    ln_arrear_rule8_credit        number;
    lv_arrear_rule8_challan_no    varchar2(10);
    ld_arrear_rule8_challan_date  date;
    lv_arrear_rule8_bank_code     varchar2(7);
    lv_arrear_rule8_source_no     varchar2(40);
    ld_arrear_rule8_source_date   date;
    ln_arrear_current             number;
    ln_arrear_credit              number;
    lv_arrear_challan_no          varchar2(10);
    ld_arrear_challan_date        date;
    lv_arrear_bank_code           varchar2(7);
    lv_arrear_source_no           varchar2(40);
    ld_arrear_source_date         date;
    ln_int_rule8_current          number;
    ln_int_rule8_credit           number;
    lv_int_rule8_challan_no       varchar2(10);
    ld_int_rule8_challan_date     date;
    lv_int_rule8_bank_code        varchar2(7);
    lv_int_rule8_source_no        varchar2(40);
    ld_int_rule8_source_date      date;
    ln_int_current                number;
    ln_int_credit                 number;
    lv_int_challan_no             varchar2(10);
    ld_int_challan_date           date;
    lv_int_bank_code              varchar2(7);
    lv_int_source_no              varchar2(40);
    ld_int_source_date            date;
    ln_misc_current               number;
    ln_misc_credit                number;
    lv_misc_challan_no            varchar2(10);
    ld_misc_challan_date          date;
    lv_misc_bank_code             varchar2(7);
    lv_misc_source_no             varchar2(40);
    ld_misc_source_date           date;

    Cursor c_year_month
    is
    select to_char(p_start_date, 'YYYYMM') from dual ;

  BEGIN

    lv_record_header := 'PAYMENT_DETAIL' ;
    lv_rt_type       := 1 ;
    lv_return_no     := 1 ;

    open c_year_month ;
    fetch c_year_month into ln_yyyymm ;
    close c_year_month ;

    ln_arrear_rule8_current := 0 ;
    ln_arrear_rule8_credit  := 0 ;

    ln_arrear_current := 0 ;
    ln_arrear_credit  := 0 ;

    create_payment_details(
      p_record_header             =>  lv_record_header,
      p_rt_type                   =>  lv_rt_type,
      p_ecc                       =>  lv_ecc,
      p_yyyymm                    =>  ln_yyyymm,
      p_return_no                 =>  lv_return_no,
      p_arrear_rule8_current      =>  ln_arrear_rule8_current,
      p_arrear_rule8_credit       =>  ln_arrear_rule8_credit,
      p_arrear_rule8_challan_no   =>  lv_arrear_rule8_challan_no,
      p_arrear_rule8_challan_date =>  ld_arrear_rule8_challan_date,
      p_arrear_rule8_bank_code    =>  lv_arrear_rule8_bank_code,
      p_arrear_rule8_source_no    =>  lv_arrear_rule8_source_no,
      p_arrear_rule8_source_date  =>  ld_arrear_rule8_source_date,
      p_arrear_current            =>  ln_arrear_current,
      p_arrear_credit             =>  ln_arrear_credit,
      p_arrear_challan_no         =>  lv_arrear_challan_no,
      p_arrear_challan_date       =>  ld_arrear_challan_date,
      p_arrear_bank_code          =>  lv_arrear_bank_code,
      p_arrear_source_no          =>  lv_arrear_source_no,
      p_arrear_source_date        =>  ld_arrear_source_date,
      p_int_rule8_current         =>  ln_int_rule8_current,
      p_int_rule8_credit          =>  ln_int_rule8_credit,
      p_int_rule8_challan_no      =>  lv_int_rule8_challan_no,
      p_int_rule8_challan_date    =>  ld_int_rule8_challan_date,
      p_int_rule8_bank_code       =>  lv_int_rule8_bank_code,
      p_int_rule8_source_no       =>  lv_int_rule8_source_no,
      p_int_rule8_source_date     =>  ld_int_rule8_source_date,
      p_int_current               =>  ln_int_current,
      p_int_credit                =>  ln_int_credit,
      p_int_challan_no            =>  lv_int_challan_no,
      p_int_challan_date          =>  ld_int_challan_date,
      p_int_bank_code             =>  lv_int_bank_code,
      p_int_source_no             =>  lv_int_source_no,
      p_int_source_date           =>  ld_int_source_date,
      p_misc_current              =>  ln_misc_current,
      p_misc_credit               =>  ln_misc_credit,
      p_misc_challan_no           =>  lv_misc_challan_no,
      p_misc_challan_date         =>  ld_misc_challan_date,
      p_misc_bank_code            =>  lv_misc_bank_code,
      p_misc_source_no            =>  lv_misc_source_no,
      p_misc_source_date          =>  ld_misc_source_date);

  END populate_payment_details;

  -- to populate self assesment memorandum details
   PROCEDURE populate_sam_details
    (
       p_organization_id IN NUMBER,
       p_location_id     IN NUMBER,
       p_start_date      IN DATE,
       p_end_date        IN DATE,
       p_auth_sign       IN VARCHAR2,
       p_place           IN VARCHAR2
   )
  IS
    lv_record_header        varchar2(50);
    lv_rt_type              varchar2(2);
    p_ecc                   varchar2(15);
    ln_yyyymm               number;
    lv_return_no            varchar2(3);
    ln_tr6_total_amount     number;
    lv_inv_issue_from1      varchar2(10);
    lv_inv_issue_to1        varchar2(10);
    lv_inv_issue_from2      varchar2(10);
    lv_inv_issue_to2        varchar2(10);
    lv_inv_issue_from3      varchar2(10);
    lv_inv_issue_to3        varchar2(10);
    lv_inv_issue_from4      varchar2(10);
    lv_inv_issue_to4        varchar2(10);
    lv_inv_issue_from5      varchar2(10);
    lv_inv_issue_to5        varchar2(10);
    lv_inv_issue_from6      varchar2(10);
    lv_inv_issue_to6        varchar2(10);
    lv_remarks              varchar2(255);
    lv_place                varchar2(20);
    ld_date_filing          date;
    lv_name_auth_sign       varchar2(40);

    Cursor c_year_month
    is
    select to_char(p_start_date, 'YYYYMM') from dual ;

    Cursor c_tr6_challan_amt
    is
    select NVL(SUM(pla_amount),0)
    from   JAI_CMN_RG_PLA_HDRS a
    where  a.organization_id = p_organization_id
    and    a.location_id     = p_location_id
    and    trunc(a.creation_date) >= p_start_date
    and    trunc(a.creation_date) <= p_end_date
    and    a.ACK_RECVD_FLAG = 'Y';

  BEGIN

    lv_record_header := 'SELF_ASSESMENT_MEMO_DETAIL' ;
    lv_rt_type       := 1 ;
    lv_return_no     := 1 ;

    open c_year_month ;
    fetch c_year_month into ln_yyyymm ;
    close c_year_month ;

    open c_tr6_challan_amt ;
    fetch c_tr6_challan_amt into ln_tr6_total_amount ;
    close c_tr6_challan_amt ;

    lv_name_auth_sign := substr(p_auth_sign,1,40) ;
    lv_place          := substr(p_place,1,20) ;

    create_sam_details(
      p_record_header     =>  lv_record_header,
      p_rt_type           =>  lv_rt_type,
      p_ecc               =>  lv_ecc,
      p_yyyymm            =>  ln_yyyymm,
      p_return_no         =>  lv_return_no,
      p_tr6_total_amount  =>  ln_tr6_total_amount,
      p_inv_issue_from1   =>  lv_inv_issue_from1,
      p_inv_issue_to1     =>  lv_inv_issue_to1,
      p_inv_issue_from2   =>  lv_inv_issue_from2,
      p_inv_issue_to2     =>  lv_inv_issue_to2,
      p_inv_issue_from3   =>  lv_inv_issue_from3,
      p_inv_issue_to3     =>  lv_inv_issue_to3,
      p_inv_issue_from4   =>  lv_inv_issue_from4,
      p_inv_issue_to4     =>  lv_inv_issue_to4,
      p_inv_issue_from5   =>  lv_inv_issue_from5,
      p_inv_issue_to5     =>  lv_inv_issue_to5,
      p_inv_issue_from6   =>  lv_inv_issue_from6,
      p_inv_issue_to6     =>  lv_inv_issue_to6,
      p_remarks           =>  lv_remarks,
      p_place             =>  lv_place,
      p_date_filing       =>  ld_date_filing,
      p_name_auth_sign    =>  lv_name_auth_sign);

  END populate_sam_details;



END jai_ar_eer1_pkg;

/
