--------------------------------------------------------
--  DDL for Package JAI_AR_EER1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_EER1_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ar_eer1_pkg.pls 120.2.12010000.2 2008/11/19 11:49:40 mbremkum ship $ */

  v_filehandle      UTL_FILE.FILE_TYPE;
  v_utl_file_dir    VARCHAR2(512);
  v_utl_file_name   VARCHAR2(50);

  -- Padding Variables
  v_pad_char        VARCHAR2(1) := ' ';
  v_pad_date        VARCHAR2(1) := ' ';
  v_pad_number      VARCHAR2(1) := '0';
  v_quart_pad       VARCHAR2(1) := ' ';
  v_q_noval_filler  VARCHAR2(1) := '-';
  v_q_null_filler   VARCHAR2(1) := '*';
  v_underline_char  VARCHAR2(1) := '-';
  v_delimeter       VARCHAR2(1) := ',' ;
  v_append          VARCHAR2(1) := '"' ;

  -- Length Variables
  sq_len_2          number := 2;
  sq_len_3          number := 3;
  sq_len_6          number := 6;
  sq_len_7          number := 7;
  sq_len_8          number := 8;
  sq_len_10         number := 10;
  sq_len_11         number := 11;
  sq_len_12         number := 12;
  sq_len_13         number := 13;
  sq_len_15         number := 15;
  sq_len_20         number := 20;
  sq_len_40         number := 40;
  sq_len_50         number :=50;
  sq_len_255        number := 255;

  p_str             varchar2(2000);
  p_action          varchar2(2);

  lv_last_flag      varchar2(1) := 'Y';



  -- The Procedure which will be called first

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
  ) ;

  FUNCTION format_action(f_field_name varchar2, f_len_field number, f_action varchar2, f_last_flag varchar2 DEFAULT 'N')
  RETURN varchar2;

  PROCEDURE openFile(
    p_directory IN VARCHAR2,
    p_filename  IN VARCHAR2 );

  PROCEDURE closeFile;

  PROCEDURE create_ceth_header;

  PROCEDURE create_duty_header;

  PROCEDURE create_input_header;

  PROCEDURE create_cenvat_header;

  PROCEDURE create_payment_header;

  PROCEDURE create_sam_header;


  PROCEDURE populate_duty_paid_details (  p_end_date    IN  DATE,
    p_location_id   IN  NUMBER,
    p_organization_id IN  NUMBER,
    p_start_date    IN  DATE );

  PROCEDURE populate_ceth_wise_details( p_organization_id IN  NUMBER,
    p_location_id   IN  NUMBER,
    p_start_date    IN  DATE,
    p_end_date    IN  DATE
  );

  PROCEDURE populate_cenvat_credit_details (  p_end_date    IN  DATE,
  p_location_id   IN  NUMBER,
  p_operating_unit  IN  NUMBER,
  p_organization_id IN  NUMBER,
  p_registration_number IN  VARCHAR2,
  p_start_date    IN  DATE );

  PROCEDURE populate_input_details
  (   p_end_date        IN  DATE,
      p_location_id     IN  NUMBER,
      p_organization_id IN  NUMBER,
      p_start_date      IN  DATE
  ) ;

  PROCEDURE populate_payment_details
  (p_start_date   in DATE
  ) ;

  PROCEDURE populate_sam_details
   (
      p_organization_id IN NUMBER,
      p_location_id     IN NUMBER,
      p_start_date      IN DATE,
      p_end_date        IN DATE,
      p_auth_sign       IN VARCHAR2,
      p_place           IN VARCHAR2
   ) ;

END jai_ar_eer1_pkg;

/
