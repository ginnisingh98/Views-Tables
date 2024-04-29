--------------------------------------------------------
--  DDL for Package Body IGF_SL_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_GEN" AS
/* $Header: IGFSL12B.pls 120.4 2006/08/07 13:21:12 azmohamm ship $ */


------------------------------------------------------------------------
--  Who             When            What
------------------------------------------------------------------------
--  azmohamm       03-AUG-2006      FA-163 : Added chk_cl_gplus function
------------------------------------------------------------------------
--  museshad       05-May-2005      Bug# 4346258.
--                                  Modified the function
--                                  'get_cl_version' so that it takes
--                                  into account any overriding CL version
--                                  for a specific Organization Unit in
--                                  FFELP Setup override.
------------------------------------------------------------------------
--  sjadhav        09-Nov-2004      Bug #3416936.added rel code to cl version
------------------------------------------------------------------------
--  ayedubat    20-OCT-2004      FA 149 COD-XML Standards build bug # 3416863
--                               Changed the logic as per the TD
------------------------------------------------------------------------
--  svuppala    20-Oct-2004      Bug 3416936  Added new update change status
------------------------------------------------------------------------

--  sjadhav     15-Oct-2004      Bug 3416863
--                               Added ENTITY_ID for CODXML
------------------------------------------------------------------------
--  smadathi    14-oct-2004      Bug 3416936.Added new generic functions as
--                               given in the TD.
------------------------------------------------------------------------
-- ugummall     14-NOV-2003       Bug 3102439. FA 126 - Multiple FA Offices.
--                                Added the cursor cur_get_num_applinst.
------------------------------------------------------------------------
-- ugummall     14-OCT-2003       Bug# 3102439. FA 126 Multiple FA Offices
--                                Added new routines get_associated_org and
--                                get_stu_fao_code.
------------------------------------------------------------------------
-- bkkumar      15-Sep-2003       Bug# 3104228. FA 122 Loans Enhancements
--                                Added new routine check_rel,get_person_details
--                                and check_lend_relation
------------------------------------------------------------------------
-- sjadhav      30-Apr-2003       Bug 2922549.
--                                Modified get_person_phone
--                                added code to strip phone number
--                                of special characters
------------------------------------------------------------------------
-- sjadhav      24-Feb-2003       Bug 275823.
--                                Modified get_person_phone
--                                Added CONTACT_POINT_TYPE in the
--                                query to read phone numbers
------------------------------------------------------------------------
--
-- Bug 2415041, sjadhav
-- Following fields are deemed as optional henceforth
--
-- S_PERMT_ADDR2
-- P_PERMT_ADDR2
-- S_MIDDLE_NAME
-- P_MIDDLE_NAME
-- S_PERMT_PHONE
-- P_PERMT_PHONE
--
-- set_complete_status for these fields is taken out NOCOPY
-- fill in spaces for addr2/middle initial/
-- all these fields if null are filled with spaces
-- while sending origination record [ see igfsl08bpls ]
--
-- Phone number if not available then 'N/A' is returned
-- Area Code is padded with '000' if it is null
-- Coutry Code is not padded with anythin
--
--  Created By : venagara
--  Date Created On : 2000/11/20
--  Purpose :
--  Know limitations, enhancements or remarks
--  Change History
--
--  (reverse chronological order - newest change first)
------------------------------------------------------------------------
--

  g_debug_string VARCHAR2(4000) := NULL;

FUNCTION  chk_dl_fed_fund_code(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

BEGIN

  IF UPPER(p_fed_fund_code) in ('DLS','DLU','DLP','GPLUSDL') then
    RETURN 'TRUE';
  END IF;

  RETURN 'FALSE';
END chk_dl_fed_fund_code;



FUNCTION  chk_dl_stafford(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  l_temp VARCHAR2(10);
  CURSOR c1 IS
  SELECT 'x' FROM igf_lookups_view
  WHERE lookup_type = 'IGF_SL_DL_STAFFORD'
  AND   lookup_code = UPPER(p_fed_fund_code)
  AND   enabled_flag = 'Y';
BEGIN
  OPEN c1;
  FETCH c1 into l_temp;
  IF c1%NOTFOUND THEN
     CLOSE c1;
     RETURN 'FALSE';
  END IF;

  CLOSE c1;
  RETURN 'TRUE';
END chk_dl_stafford;



FUNCTION  chk_dl_plus(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  l_temp VARCHAR2(10);
  CURSOR c1 IS
  SELECT 'x' FROM igf_lookups_view
  WHERE lookup_type = 'IGF_SL_DL_PLUS'
  AND   lookup_code = UPPER(p_fed_fund_code)
  AND   enabled_flag = 'Y';
BEGIN
  OPEN c1;
  FETCH c1 into l_temp;
  IF c1%NOTFOUND THEN
     CLOSE c1;
     RETURN 'FALSE';
  END IF;

  CLOSE c1;
  RETURN 'TRUE';
END chk_dl_plus;




FUNCTION  chk_cl_fed_fund_code(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  azmohamm       24-JUL-2006      FA-163: Included GPLUSFL funcode
  (reverse chronological order - newest change first)
  ***************************************************************/

BEGIN

  IF UPPER(p_fed_fund_code) in ('FLS','FLU','FLP','ALT','GPLUSFL') then
    RETURN 'TRUE';
  END IF;

  RETURN 'FALSE';
END chk_cl_fed_fund_code;

FUNCTION  chk_cl_gplus(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2
AS
  /*************************************************************
  Created By : azmohamm
  Date Created On : 2006/07/24
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  l_temp VARCHAR2(10);
  CURSOR c1 IS
  SELECT 'x' FROM igf_lookups_view
  WHERE lookup_type = 'IGF_SL_CL_GPLUS'
  AND   lookup_code = UPPER(p_fed_fund_code)
  AND   enabled_flag = 'Y';
BEGIN
  OPEN c1;
  FETCH c1 into l_temp;
  IF c1%NOTFOUND THEN
     CLOSE c1;
     RETURN 'FALSE';
  END IF;

  CLOSE c1;
  RETURN 'TRUE';
END chk_cl_gplus;

FUNCTION  chk_cl_stafford(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  l_temp VARCHAR2(10);
  CURSOR c1 IS
  SELECT 'x' FROM igf_lookups_view
  WHERE lookup_type = 'IGF_SL_CL_STAFFORD'
  AND   lookup_code = UPPER(p_fed_fund_code)
  AND   enabled_flag = 'Y';
BEGIN
  OPEN c1;
  FETCH c1 into l_temp;
  IF c1%NOTFOUND THEN
     CLOSE c1;
     RETURN 'FALSE';
  END IF;

  CLOSE c1;
  RETURN 'TRUE';
END chk_cl_stafford;



FUNCTION  chk_cl_plus(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  l_temp VARCHAR2(10);
  CURSOR c1 IS
  SELECT 'x' FROM igf_lookups_view
  WHERE lookup_type = 'IGF_SL_CL_PLUS'
  AND   lookup_code = UPPER(p_fed_fund_code)
  AND   enabled_flag = 'Y';
BEGIN
  OPEN c1;
  FETCH c1 into l_temp;
  IF c1%NOTFOUND THEN
     CLOSE c1;
     RETURN 'FALSE';
  END IF;

  CLOSE c1;
  RETURN 'TRUE';
END chk_cl_plus;

/* Function to check Alternative Loan */
FUNCTION  chk_cl_alt(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2
AS
  /*************************************************************
  Created By : pkpatel
  Date Created On : 2001/05/09
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

BEGIN

  IF UPPER(p_fed_fund_code) = 'ALT' then
    RETURN 'TRUE';
  END IF;

  RETURN 'FALSE';
END chk_cl_alt;



FUNCTION base10_to_base36(p_base_10   NUMBER)
RETURN VARCHAR
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  l_power     NUMBER(9);
  l_remainder NUMBER(9);
  l_base10    NUMBER(9);
  l_base36    NUMBER(9);
  l_unit      NUMBER(9);
  l_base36_char VARCHAR2(4000);
BEGIN

  -- Algorithm is given in the Appendex C of CL Release 5
  l_base10 := p_base_10;
  FOR l_power in 1..999999999 LOOP

    l_remainder := mod(l_base10, power(36,l_power));

    l_unit := l_remainder / power(36,(l_power-1));

    IF l_unit < 10 THEN
       l_base36 := l_unit + 48;
    ELSE
       l_base36 := l_unit + 55;
    END IF;

    l_base36_char := fnd_global.local_chr(l_base36) || l_base36_char;

    l_base10 := l_base10 - l_remainder;

    IF l_base10 = 0 THEN
      EXIT;
    END IF;

  END LOOP;

  RETURN l_base36_char;

END  base10_to_base36;


FUNCTION get_grade_level_desc(p_fed_fund_code    igf_aw_fund_cat_all.fed_fund_code%TYPE,
                              p_grade_level_code igf_sl_lor_all.grade_level_code%TYPE)
RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
BEGIN
   RETURN p_grade_level_code||'-'||igf_aw_gen.lookup_desc('IGF_SL_CL_GRADE_LEVEL', p_grade_level_code);
END get_grade_level_desc;


FUNCTION get_enrollment_desc(p_fed_fund_code     igf_aw_fund_cat_all.fed_fund_code%TYPE,
                             p_enrollment_code   igf_sl_lor_all.enrollment_code%TYPE)
RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
BEGIN
   RETURN p_enrollment_code||'-'||igf_aw_gen.lookup_desc('IGF_SL_CL_ENROL_STATUS', p_enrollment_code) ;
END get_enrollment_desc;



FUNCTION get_dl_version(p_ci_cal_type  igf_sl_dl_setup_all.ci_cal_type%TYPE,
                        p_ci_seq_num   igf_sl_dl_setup_all.ci_sequence_number%TYPE)
RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  l_dl_version  igf_sl_dl_setup_all.dl_version%TYPE;
  CURSOR c_dl_setup IS
  SELECT dl_version FROM igf_sl_dl_setup_all
  WHERE  ci_cal_type        = p_ci_cal_type
  AND    ci_sequence_number = p_ci_seq_num;
BEGIN

  OPEN c_dl_setup;
  FETCH c_dl_setup into l_dl_version;
  IF c_dl_setup%NOTFOUND THEN
    CLOSE c_dl_setup;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c_dl_setup;
  RETURN l_dl_version;
END get_dl_version;




FUNCTION get_cl_version(p_ci_cal_type     igf_sl_cl_setup_all.ci_cal_type%TYPE,
                        p_ci_seq_num      igf_sl_cl_setup_all.ci_sequence_number%TYPE,
                        p_relationship_cd igf_sl_cl_setup_all.relationship_cd%TYPE,
                        p_base_id         igf_ap_fa_base_rec_all.base_id%TYPE)
RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  museshad       05-May-2005     Bug #4346258
                                    1)  Added a new parameter - p_base_id to the
                                        function. This parameter is used to
                                        arrive at the associated Organization Id
                                        Note: The function has not been overloaded
                                        to yield the correct CL version number
                                    2)  Modified the function so that it takes
                                        into account any overriding CL version
                                        for a specific Organization Unit in
                                        FFELP Setup override.

  bkkumar        30-sep-2003     FA 122 Loans Enhancements
                                 Changed the entire code
  (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR cur_cl_version (p_ci_cal_type     igf_sl_cl_setup_all.ci_cal_type%TYPE,
                         p_ci_seq_num      igf_sl_cl_setup_all.ci_sequence_number%TYPE,
                         p_relationship_cd igf_sl_cl_setup_all.relationship_cd%TYPE,
                         p_party_id        hz_parties.party_id%TYPE
) IS
     SELECT cl_version
       FROM igf_sl_cl_setup_all
      WHERE ci_cal_type        = p_ci_cal_type
        AND ci_sequence_number = p_ci_seq_num
        AND relationship_cd    = p_relationship_cd
        AND NVL(PARTY_ID, -99) = NVL(p_party_id, -99);

   lv_cl_version igf_sl_cl_setup_all.cl_version%TYPE;
   l_v_party_number        hz_parties.party_number%TYPE;
   l_v_org_party_id        hz_parties.party_id%TYPE;
   l_v_module              VARCHAR2(1024);
   l_v_return_status       VARCHAR2(1024);
   l_v_msg_data            VARCHAR2(1024);

  BEGIN
     -- Get Associated Org Id
     igf_sl_gen.get_associated_org(p_base_id, l_v_party_number, l_v_org_party_id, l_v_module, l_v_return_status, l_v_msg_data);

     OPEN  cur_cl_version( p_ci_cal_type, p_ci_seq_num, p_relationship_cd, l_v_org_party_id);
     FETCH cur_cl_version INTO lv_cl_version;
     CLOSE cur_cl_version;

      -- Overriding CL Setup is missing Hence going for default setup.
     IF lv_cl_version IS NULL THEN
        OPEN  cur_cl_version (p_ci_cal_type, p_ci_seq_num, p_relationship_cd, NULL);
        FETCH cur_cl_version INTO lv_cl_version;
        CLOSE cur_cl_version ;
    END IF;
    -- END Overriding CL Setup is missing Hence going for default se
    RETURN lv_cl_version;

END get_cl_version;




FUNCTION get_dl_file_type(p_dl_version    igf_sl_dl_file_type.dl_version%TYPE,
                          p_dl_file_type  igf_sl_dl_file_type.dl_file_type%TYPE,
                          p_dl_loan_catg  igf_sl_dl_file_type.dl_loan_catg%TYPE,
                          p_return_type   VARCHAR2)
RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  l_message_class  igf_sl_dl_file_type.message_class%TYPE;
  l_batch_type     igf_sl_dl_file_type.batch_type%TYPE;
  l_cycle_year     igf_sl_dl_file_type.cycle_year%TYPE;
  l_rec_length     igf_sl_dl_file_type.rec_length%TYPE;

  CURSOR c_file_type IS
  SELECT message_class, batch_type, cycle_year, rec_length FROM igf_sl_dl_file_type
  WHERE  dl_version   = p_dl_version
  AND    dl_file_type = p_dl_file_type
  AND    dl_loan_catg = p_dl_loan_catg;
BEGIN
  OPEN c_file_type;
  FETCH c_file_type INTO l_message_class, l_batch_type, l_cycle_year, l_rec_length;
  IF c_file_type%NOTFOUND THEN
     CLOSE c_file_type;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c_file_type;

  IF    UPPER(p_return_type) = 'MESSAGE-CLASS' THEN
     RETURN l_message_class;
  ELSIF UPPER(p_return_type) = 'BATCH-TYPE' THEN
     RETURN l_batch_type;
  ELSIF UPPER(p_return_type) = 'CYCLE-YEAR' THEN
     RETURN l_cycle_year;
  ELSIF UPPER(p_return_type) = 'REC-LENGTH' THEN
     RETURN l_rec_length;
  END IF;
  RETURN NULL;

END get_dl_file_type;



PROCEDURE get_dl_batch_details(p_message_class IN  igf_sl_dl_file_type.message_class%TYPE,
                               p_batch_type    IN  igf_sl_dl_file_type.batch_type%TYPE,
                               p_dl_version    OUT NOCOPY igf_sl_dl_file_type.dl_version%TYPE,
                               p_dl_file_type  OUT NOCOPY igf_sl_dl_file_type.dl_file_type%TYPE,
                               p_dl_loan_catg  OUT NOCOPY igf_sl_dl_file_type.dl_loan_catg%TYPE)
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  l_dl_version    igf_sl_dl_file_type.dl_version%TYPE;
  l_dl_file_type  igf_sl_dl_file_type.dl_file_type%TYPE;
  l_dl_loan_catg  igf_sl_dl_file_type.dl_loan_catg%TYPE;

  CURSOR c_file_type IS
  SELECT dl_version, dl_file_type, dl_loan_catg FROM igf_sl_dl_file_type
  WHERE  message_class = p_message_class
  AND    batch_type    = p_batch_type;
BEGIN
  OPEN  c_file_type;
  FETCH c_file_type INTO l_dl_version, l_dl_file_type, l_dl_loan_catg;
  IF c_file_type%NOTFOUND THEN
     l_dl_version   := 'INVALID-FILE';
     l_dl_file_type := 'INVALID-FILE';
     l_dl_loan_catg := 'INVALID-FILE';
  END IF;
  CLOSE c_file_type;
  p_dl_version   := l_dl_version;
  p_dl_file_type := l_dl_file_type;
  p_dl_loan_catg := l_dl_loan_catg;

END get_dl_batch_details;


FUNCTION get_cl_file_type(p_cl_version    igf_sl_dl_file_type.dl_version%TYPE,
                          p_cl_file_type  igf_sl_dl_file_type.dl_file_type%TYPE,
                          p_return_type   VARCHAR2)
RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  l_file_ident_code igf_sl_cl_file_type.file_ident_code%TYPE;
  l_file_ident_name igf_sl_cl_file_type.file_ident_name%TYPE;

  CURSOR c_file_type IS
  SELECT file_ident_code, file_ident_name FROM igf_sl_cl_file_type
  WHERE  cl_version   = p_cl_version
  AND    cl_file_type = p_cl_file_type;
BEGIN
  OPEN c_file_type;
  FETCH c_file_type INTO l_file_ident_code, l_file_ident_name;
  IF c_file_type%NOTFOUND THEN
     CLOSE c_file_type;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c_file_type;

  IF    UPPER(p_return_type) = 'FILE-IDENT-CODE' THEN
     RETURN l_file_ident_code;
  ELSIF UPPER(p_return_type) = 'FILE-IDENT-NAME' THEN
     RETURN l_file_ident_name;
  END IF;
  RETURN NULL;

END get_cl_file_type;

PROCEDURE get_cl_batch_details(p_file_ident_code IN  igf_sl_cl_file_type.file_ident_code%TYPE,
                               p_file_ident_name IN  igf_sl_cl_file_type.file_ident_name%TYPE,
                               p_cl_version      OUT NOCOPY igf_sl_cl_file_type.cl_version%TYPE,
                               p_cl_file_type    OUT NOCOPY igf_sl_cl_file_type.cl_file_type%TYPE)
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  l_cl_version    igf_sl_cl_file_type.cl_version%TYPE;
  l_cl_file_type  igf_sl_cl_file_type.cl_file_type%TYPE;

  CURSOR c_file_type IS
  SELECT cl_version, cl_file_type FROM igf_sl_cl_file_type
  WHERE  file_ident_code = p_file_ident_code
  AND    file_ident_name = p_file_ident_name;
BEGIN
  OPEN  c_file_type;
  FETCH c_file_type INTO l_cl_version, l_cl_file_type;
  IF c_file_type%NOTFOUND THEN
     l_cl_version   := 'INVALID-FILE';
     l_cl_file_type := 'INVALID-FILE';
  END IF;
  CLOSE c_file_type;

  p_cl_version   := l_cl_version;
  p_cl_file_type := l_cl_file_type;

END get_cl_batch_details;

-- Function to return the Disbursement Date
FUNCTION  get_disb_date(p_loan_id  IN  igf_sl_loans.loan_id%TYPE,
                        p_disb_num  IN  igf_aw_awd_disb.disb_num%TYPE)
          RETURN  DATE
AS
  /*************************************************************
  Created By : pkpatel
  Date Created On : 2001/05/09
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
pkpatel   11-may-2001 return NULL instead of raising Exception when no data is found
  (reverse chronological order - newest change first)
  ***************************************************************/
/* Declared the CURSOR to select the disbursement date for the particular loan ID and Disbursement Number */
  CURSOR c_disb_date IS
  SELECT iaad.disb_date
  FROM   igf_sl_loans isl, igf_aw_awd_disb iaad
  WHERE  isl.loan_id = p_loan_id
  AND    iaad.disb_num = p_disb_num
  AND    isl.award_id = iaad.award_id;

  l_disb_date  IGF_AW_AWD_DISB.disb_date%TYPE; --variable declared to hold the Disbursement date
BEGIN
  OPEN c_disb_date;
  FETCH c_disb_date INTO l_disb_date;
  IF c_disb_date%notfound  THEN
        CLOSE c_disb_date;
  RETURN NULL;
  END IF;
  CLOSE c_disb_date;
  RETURN l_disb_date;
END get_disb_date;


-- Function to get the phone number of the person
FUNCTION get_person_phone(p_person_id IGS_PE_CONTACTS_V.owner_table_id%TYPE)
         RETURN   VARCHAR2
AS
--
------------------------------------------------------------------------
--  Created By : pkpatel
--  Date Created On : 2001/05/09
--  Purpose :
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
------------------------------------------------------------------------
-- sjadhav      30-Apr-2003       Bug 2922549.
--                                added code to strip phone number
--                                of special characters
------------------------------------------------------------------------
-- sjadhav      24-Feb-2003       Bug 275823.
--                                Added CONTACT_POINT_TYPE in the
--                                query to read phone numbers
------------------------------------------------------------------------
--
-- Declared the CURSOR to get the Primary Telephone Number for a particular Student */
--

  CURSOR c_person_phone
  IS
  SELECT
  phone_area_code,
  phone_number
  FROM   igs_pe_contacts_v
  WHERE  owner_table_id     = p_person_id
  AND    primary_flag       = 'Y'
  AND    status             = 'A'
  AND    contact_point_type = 'PHONE';

--
-- Declared variables to hold the phone details information */
--
  l_phone_area_code     igs_pe_contacts_v.phone_area_code%TYPE;
  l_phone_number        igs_pe_contacts_v.phone_number%TYPE;


BEGIN

  OPEN   c_person_phone;
  FETCH  c_person_phone
  INTO   l_phone_area_code, l_phone_number;

  IF  c_person_phone%NOTFOUND THEN
    CLOSE c_person_phone;
    RETURN 'N/A';
  END IF;
  CLOSE c_person_phone;

  l_phone_area_code := TRANSLATE (UPPER(LTRIM(RTRIM(l_phone_area_code))),'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ`~!@#$%^&*_+=-,./?><():; ','1234567890');
  l_phone_area_code := LPAD(l_phone_area_code,3,'0');

  l_phone_number    := TRANSLATE (UPPER(LTRIM(RTRIM(l_phone_number))),'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ`~!@#$%^&*_+=-,./?><():; ','1234567890');
  l_phone_number    := LPAD(l_phone_number,7,'0');

  RETURN ( NVL(l_phone_area_code,'000')|| l_phone_number);

END  get_person_phone;

  PROCEDURE check_lend_relation( p_person_id   IN  igf_sl_cl_pref_lenders.person_id%TYPE,
                                 p_start_date  IN  DATE,
                                 p_end_date    IN  DATE,
                                 p_message     OUT NOCOPY VARCHAR2)
  AS
    /*************************************************************
    Created By : bkkumar
    Date Created On : 05-Sep-2003
    Purpose : FA 122 Loans Enhancements.
              It checks if the lender set up is valid or not.
    Know limitations, enhancements or remarks
    Change History
    Who             When            What

    (reverse chronological order - newest change first)
    ***************************************************************/

    CURSOR c_chk_active_rec (
                             cp_person_id  igf_sl_cl_pref_lenders.person_id%TYPE
                            )
    IS
    SELECT count(*) cnt
    FROM  igf_sl_cl_pref_lenders
    WHERE person_id = cp_person_id
    AND end_date IS NULL;

    l_chk_active_rec  c_chk_active_rec%ROWTYPE;

    CURSOR c_chk_overlap_date (
                               cp_person_id  igf_sl_cl_pref_lenders.person_id%TYPE,
                               cp_start_date  DATE,
                               cp_end_date    DATE
                              )
    IS
    SELECT count(*) cnt
    FROM  igf_sl_cl_pref_lenders
    WHERE person_id = cp_person_id
    AND ( ( cp_start_date BETWEEN start_date AND NVL(end_date,TO_DATE('4712/12/31','YYYY/MM/DD')) )
    OR  ( NVL(cp_end_date,TO_DATE('4712/12/31','YYYY/MM/DD')) BETWEEN start_date AND NVL(end_date,TO_DATE('4712/12/31','YYYY/MM/DD')))
    OR  ( cp_start_date < start_date AND NVL(cp_end_date,TO_DATE('4712/12/31','YYYY/MM/DD')) > NVL(end_date,TO_DATE('4712/12/31','YYYY/MM/DD'))));

    l_chk_overlap_date  c_chk_overlap_date%ROWTYPE;

  BEGIN

    p_message := NULL;

    l_chk_active_rec := NULL;

    -- this cursor checks that there should be only one preferred lender at any point of time.
    OPEN  c_chk_active_rec(p_person_id);
    FETCH c_chk_active_rec INTO l_chk_active_rec;
    CLOSE c_chk_active_rec;

    IF l_chk_active_rec.cnt IS NOT NULL AND l_chk_active_rec.cnt > 1 THEN
      p_message := 'IGF_SL_PREF_LEND_ONE';
      RETURN;
    END IF;

    l_chk_overlap_date := NULL;

    -- this cursor checks that there should not be any overlapping dates
    OPEN c_chk_overlap_date(p_person_id,p_start_date,p_end_date);
    FETCH c_chk_overlap_date INTO l_chk_overlap_date;
    CLOSE c_chk_overlap_date;
    -- add a message to the logging framework
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_gen.check_lend_relation.debug','After the cursor to check overlapping dates');
    END IF;

    IF l_chk_overlap_date.cnt IS NOT NULL AND l_chk_overlap_date.cnt > 1 THEN
      p_message := 'IGF_SL_PREF_LEND_DATES';
    END IF;

  EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_sl_gen.check_lend_relation.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_GEN.CHECK_LEND_RELATION');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;

  END check_lend_relation;

  PROCEDURE get_person_details    ( p_person_id        IN  igf_sl_cl_pref_lenders.person_id%TYPE,
                                    p_person_dtl_rec   IN OUT NOCOPY person_dtl_cur)
  AS
    /*************************************************************
    Created By : bkkumar
    Date Created On : 05-Sep-2003
    Purpose : FA 122 Loans Enhancements.
              It gets the person details for all given person id
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    gmaheswa        24-Nov-2003    Bug : 3227107 Address active check changes
                                   Modified c_get_paddr cursor to select active records only and to select
                                   start date and end date from igs_pe_hz_pty_sites.
    (reverse chronological order - newest change first)
    **************************************************************/
     CURSOR c_get_ssn (
                      cp_person_id       igf_sl_cl_pref_lenders.person_id%TYPE,
                      cp_person_id_type  igs_pe_person_id_typ.s_person_id_type%TYPE
                     )
    IS
    SELECT api.api_person_id_uf ssn,
           api.person_id_type,
           api.start_dt,
           api.end_dt
    FROM  igs_pe_alt_pers_id api,
          igs_pe_person_id_typ pid
    WHERE api.pe_person_id = cp_person_id
    AND   api.person_id_type = pid.person_id_type
    AND   pid.s_person_id_type = cp_person_id_type --
    AND   SYSDATE BETWEEN api.start_dt AND NVL(api.end_dt,SYSDATE);

    l_get_ssn c_get_ssn%ROWTYPE;

    CURSOR c_get_name (
                       cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE
                      )
    IS
    SELECT person_id,
           person_number,
           pre_name_adjunct,
           first_name,
           middle_name,
           last_name,
           title,
           full_name,
           suffix,
           birth_date,
           gender
    FROM   igs_pe_person_base_v
    WHERE  person_id = cp_person_id;

    l_get_name c_get_name%ROWTYPE;


    CURSOR c_get_emailaddr (
                            cp_person_id    igf_sl_cl_pref_lenders.person_id%TYPE,
                            cp_primary_flag igs_pe_contacts_v.primary_flag%TYPE,
                            cp_status       igs_pe_contacts_v.status%TYPE,
                            cp_contact_point_type igs_pe_contacts_v.contact_point_type%TYPE
                           )
    IS
    SELECT email_address
    FROM   igs_pe_contacts_v
    WHERE  owner_table_id = cp_person_id
    AND    primary_flag = cp_primary_flag
    AND    status = cp_status
    AND    contact_point_type = cp_contact_point_type ;

    l_get_emailaddr c_get_emailaddr%ROWTYPE;

    CURSOR c_get_paddr (
                       cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE,
                       cp_identifying_address_flag hz_party_sites.identifying_address_flag%TYPE
                      )
    IS
    SELECT  ps.party_id,
            ps.identifying_address_flag,
            l.address1,
            l.address2,
            l.address3,
            l.address4,
            l.city,
            l.state,
            l.province,
            l.county,
            l.country,
            l.postal_code,
            l.last_update_date
    FROM  hz_party_sites     ps,
          hz_locations       l ,
          igs_pe_hz_pty_sites ihps
    WHERE ps.location_id    =  l.location_id
    AND   ps.party_site_id  = ihps.party_site_id(+)
    AND   ps.identifying_address_flag  =  cp_identifying_address_flag
    AND   ( ps.status = 'A' AND SYSDATE BETWEEN NVL(ihps.start_date,SYSDATE)
    AND   NVL(ihps.end_date,SYSDATE))
    AND   ps.party_id = cp_person_id;

    l_get_paddr c_get_paddr%ROWTYPE;


    CURSOR c_get_lic_num  (
                            cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE,
                            cp_person_id_type igs_pe_person_id_typ.s_person_id_type%TYPE
                           )
    IS
    SELECT  api.api_person_id,
            api.region_cd,
            api.person_id_type,
            api.start_dt,
            api.end_dt,
            pid.s_person_id_type
    FROM   igs_pe_alt_pers_id api,
           igs_pe_person_id_typ pid
    WHERE api.pe_person_id = cp_person_id
    AND   api.person_id_type   = pid.person_id_type
    AND   pid.s_person_id_type = cp_person_id_type
    AND   SYSDATE BETWEEN api.start_dt AND NVL(api.end_dt,SYSDATE);

    l_get_lic_num   c_get_lic_num%ROWTYPE;

    CURSOR c_get_addr (
                       cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE,
                       cp_status  hz_party_site_uses.status%TYPE,
                       cp_site_use_type  hz_party_site_uses.site_use_type%TYPE
                      )
    IS
    SELECT ps.party_id,
           psu.site_use_type,
           ps.identifying_address_flag,
           l.address1,
           l.address2,
           l.address3,
           l.address4,
           l.city,
           l.state,
           l.province,
           l.county,
           l.country,
           l.postal_code,
           l.last_update_date
    FROM  hz_party_sites ps,
          hz_locations l,
          hz_party_site_uses psu
    WHERE ps.location_id =  l.location_id
    AND   ps.party_site_id  =  psu.party_site_id
    AND   psu.status =  cp_status
    AND   psu.site_use_type = cp_site_use_type
    AND   SYSDATE BETWEEN NVL(ps.start_date_active,SYSDATE) AND NVL(ps.end_date_active,SYSDATE)
    AND   ps.party_id = cp_person_id
    ORDER BY ps.start_date_active DESC;

    l_get_addr c_get_addr%ROWTYPE;


    CURSOR c_get_reg_num (
                            cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE,
                            cp_perm_res_cntry igs_pe_eit_perm_res_v.perm_res_cntry%TYPE
                         )
    IS
    SELECT document_num
    FROM   igs_pe_eit_perm_res_v
    WHERE  perm_res_cntry = cp_perm_res_cntry
    AND    person_id = cp_person_id
    AND    SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);

    l_get_reg_num VARCHAR2(150);

    CURSOR c_get_res_state (
                            cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE,
                            cp_information_type igs_pe_eit.information_type%TYPE
                         )
    IS
    SELECT pei_information1 state_code,
           start_date
    FROM   igs_pe_eit
    WHERE  person_id = cp_person_id
    AND    information_type = cp_information_type
    AND    SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);

    l_get_res_state c_get_res_state%ROWTYPE;


    CURSOR c_get_citzn_status (
                               cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE,
                               cp_lookup_type  igs_lookup_values.lookup_type%TYPE
                              )
    IS
    SELECT lkup.tag,
           pct.restatus_code
    FROM  igs_lookup_values      lkup,
          igs_pe_eit_restatus_v  pct
    WHERE lkup.lookup_type = cp_lookup_type
    AND   lkup.lookup_code = pct.restatus_code
    AND   pct.person_id    = cp_person_id
    AND   SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE)
    AND   lkup.tag IN ('1','2','3');

    l_get_citzn_status   c_get_citzn_status%ROWTYPE;

    l_length_alien_num   NUMBER;

  BEGIN
    -- this cursor gets the license number related info
    l_get_lic_num := NULL;
    OPEN c_get_lic_num(p_person_id,'DRIVER_LIC');
    FETCH c_get_lic_num INTO l_get_lic_num;
    CLOSE c_get_lic_num;

    -- this cursor gets the citizenship status related info
    l_get_citzn_status := NULL;
    OPEN c_get_citzn_status(p_person_id,'PE_CITI_STATUS');
    FETCH c_get_citzn_status INTO l_get_citzn_status;
    CLOSE c_get_citzn_status;

    -- this cursor gets the legal residence state related info
    l_get_res_state := NULL;
    OPEN c_get_res_state(p_person_id,'PE_STAT_RES_STATE');
    FETCH c_get_res_state INTO l_get_res_state;
    CLOSE c_get_res_state;

    -- this cursor gets the registration number related info
    l_get_reg_num := NULL;
    OPEN c_get_reg_num(p_person_id,'US');
    FETCH c_get_reg_num INTO l_get_reg_num;
    CLOSE c_get_reg_num;

    -- Bug # 5006583 - If alien registration number > 10 characters then put a null.

    l_length_alien_num :=  length(l_get_reg_num);
    IF ( l_length_alien_num > 10) THEN
        l_get_reg_num := NULL;
    END IF;


    -- this cursor gets the SSN related info
    l_get_ssn := NULL;
    OPEN c_get_ssn(p_person_id,'SSN');
    FETCH c_get_ssn INTO l_get_ssn;
    CLOSE c_get_ssn;

    -- this cursor gets the person name related info
    l_get_name := NULL;
    OPEN c_get_name(p_person_id);
    FETCH c_get_name INTO l_get_name;
    CLOSE c_get_name;

    -- this cursor gets the local address related info
    l_get_addr := NULL;
    OPEN c_get_addr(p_person_id,'A','RESIDES_AT');
    FETCH c_get_addr INTO l_get_addr;
    CLOSE c_get_addr;

    -- this cursor gets the permanent address related info
    l_get_paddr := NULL;
    OPEN c_get_paddr(p_person_id,'Y');
    FETCH c_get_paddr INTO l_get_paddr;
    CLOSE c_get_paddr;

    -- this cursor gets the email address related info
    l_get_emailaddr := NULL;
    OPEN c_get_emailaddr(p_person_id,'Y','A','EMAIL');
    FETCH c_get_emailaddr INTO l_get_emailaddr;
    CLOSE c_get_emailaddr;
    -- add a message to the logging framework
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_gen.get_person_details.debug','Before opening the ref cursor');
    END IF;

    -- open the ref cursor with the values obtained from the above cursors.
    OPEN   p_person_dtl_rec FOR
    SELECT l_get_reg_num,
           l_get_citzn_status.tag,
           l_get_name.birth_date,
           l_get_emailaddr.email_address,
           l_get_name.first_name,
           l_get_name.full_name,
           l_get_name.last_name,
           l_get_res_state.start_date,
           l_get_lic_num.api_person_id,
           l_get_lic_num.region_cd,
           l_get_name.middle_name,
           l_get_paddr.address1,
           l_get_paddr.address2,
           l_get_paddr.city,
           l_get_paddr.state,
           l_get_paddr.postal_code,
           igf_gr_gen.get_ssn_digits(NVL(l_get_ssn.ssn,'')),
           l_get_res_state.state_code,
           l_get_paddr.province,
           l_get_paddr.county,
           l_get_paddr.country,
           l_get_addr.address1,
           l_get_addr.address2,
           l_get_addr.city,
           l_get_addr.state,
           l_get_addr.postal_code

    FROM  DUAL;

  EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_sl_gen.get_person_details.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_GEN.GET_PERSON_DETAILS');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;

  END get_person_details;

 PROCEDURE check_rel (
                      p_rel_code  IN  igf_sl_cl_setup_all.relationship_cd%TYPE,
                      p_flag      OUT NOCOPY VARCHAR2
                     )
  AS
    /*************************************************************
    Created By : bkkumar
    Date Created On : 05-Sep-2003
    Purpose : FA 122 Loans Enhancements.
              It checks whether the relationship exists or not.
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    bkkumar        10-apr-04       FACR116 - Added the check to select
                                   the rel_code from igf_aw_fund_cat_all
    (reverse chronological order - newest change first)
    **************************************************************/

    CURSOR c_chk_rel_code1  (
                             cp_rel_code  igf_sl_cl_setup_all.relationship_cd%TYPE
                           )
    IS
    SELECT relationship_cd
    FROM igf_sl_cl_setup_all
    WHERE relationship_cd = cp_rel_code
    AND ROWNUM = 1;

    l_chk_rel_code1  c_chk_rel_code1%ROWTYPE;

    CURSOR c_chk_rel_code2 (
                            cp_rel_code  igf_sl_cl_setup_all.relationship_cd%TYPE
                           )
    IS
    SELECT relationship_cd
    FROM igf_sl_cl_pref_lenders
    WHERE relationship_cd = cp_rel_code
    AND ROWNUM = 1;

    l_chk_rel_code2  c_chk_rel_code2%ROWTYPE;
    CURSOR c_chk_rel_code3 (
                            cp_rel_code  igf_sl_cl_setup_all.relationship_cd%TYPE
                           )
    IS
    SELECT alt_rel_code
    FROM igf_aw_fund_cat_all
    WHERE alt_rel_code = cp_rel_code
    AND ROWNUM = 1;

    l_chk_rel_code3  c_chk_rel_code3%ROWTYPE;
  BEGIN

    l_chk_rel_code1 := NULL;
    -- cursor to check whether the relationship exists in the igf_Sl_cl_setup table
    OPEN c_chk_rel_code1(p_rel_code);
    FETCH c_chk_rel_code1 INTO l_chk_rel_code1;
    CLOSE c_chk_rel_code1;

    l_chk_rel_code2 := NULL;
     -- cursor to check whether the relationship exists in the igf_sl_cl_pref_lenders table
    OPEN c_chk_rel_code2(p_rel_code);
    FETCH c_chk_rel_code2 INTO l_chk_rel_code2;
    CLOSE c_chk_rel_code2;

    l_chk_rel_code3 := NULL;
     -- cursor to check whether the relationship exists in the igf_aw_fund_cat_all table
    OPEN c_chk_rel_code3(p_rel_code);
    FETCH c_chk_rel_code3 INTO l_chk_rel_code3;
    CLOSE c_chk_rel_code3;

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_gen.check_rel.debug','After the check of three cursors');
    END IF;

    IF l_chk_rel_code1.relationship_cd IS NULL AND l_chk_rel_code2.relationship_cd IS NULL AND l_chk_rel_code3.alt_rel_code IS NULL THEN
      p_flag := 'FALSE';
    ELSE
      p_flag := 'TRUE';
    END IF;

  EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_sl_gen.check_rel.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_GEN.CHECK_REL');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;

  END check_rel;

PROCEDURE get_associated_org (p_base_id       IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                              x_org_unit_cd   OUT   NOCOPY hz_parties.party_number%TYPE,
                              x_org_party_id  OUT   NOCOPY hz_parties.party_id%TYPE,
                              x_module        OUT   NOCOPY VARCHAR2,
                              x_return_status OUT   NOCOPY VARCHAR2,
                              x_msg_data      OUT   NOCOPY VARCHAR2)
AS
  /*
  ||  Created By : ugummall
  ||  Created On : 14-OCT-2003
  ||  Purpose : Bug# 3102439. FA 126 Multiple FA Offices
  ||            For obtaining responsible org unit code that
  ||            is associated with the student.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        14-NOV-2003     Bug 3102439. FA 126 - Multiple FA Offices.
  ||                                  Added the cursor cur_get_num_applinst.
  ||  (reverse chronological order - newest change first)
  */

  -- get Org Unit from program that is obatined as key program from enrollment api
  CURSOR c_get_org_enr (cp_course_cd igs_ps_ver_all.course_cd%TYPE,
                        cp_version_number igs_ps_ver_all.version_number%TYPE) IS
  SELECT ps.responsible_org_unit_cd org_unit_cd,
         hz.party_id
  FROM   igs_ps_ver_all ps,
         hz_parties hz
  WHERE  hz.party_number = ps.responsible_org_unit_cd
    AND  ps.course_cd = cp_course_cd
    AND  ps.version_number = cp_version_number;

  c_get_org_enr_rec c_get_org_enr%ROWTYPE;

  -- get number of applications for the Person
  CURSOR cur_get_num_appl (p_person_id HZ_PARTIES.PARTY_ID%TYPE) IS
    SELECT  count(ADMISSION_APPL_NUMBER) num_of_appls
      FROM  IGS_AD_APPL_ALL appl,
            IGS_AD_APPL_STAT_V stat
     WHERE  appl.ADM_APPL_STATUS = stat.ADM_APPL_STATUS
       AND  stat.S_ADM_APPL_STATUS <> 'WITHDRAWN'
       AND  PERSON_ID = p_person_id;
  rec_get_num_appl  cur_get_num_appl%ROWTYPE;

  -- get total number of application instances.
  CURSOR cur_get_num_applinst(p_person_id HZ_PARTIES.PARTY_ID%TYPE) IS
    SELECT  count(*) num_of_records
      FROM  IGS_AD_APPL_ALL appl,
            IGS_AD_PS_APPL_INST applinst,
            IGS_AD_OU_STAT_V igsl2
     WHERE  appl.person_id = applinst.person_id
       AND  appl.admission_appl_number = applinst.admission_appl_number
       AND  igsl2.adm_outcome_status = applinst.adm_outcome_status
       AND  igsl2.s_adm_outcome_status NOT IN ('CANCELLED', 'NO-QUOTA', 'REJECTED', 'SUSPEND', 'VOIDED', 'WITHDRAWN')
       AND  applinst.person_id = p_person_id;
  rec_get_num_applinst  cur_get_num_applinst%ROWTYPE;

  -- get Org Unit from Admissions.
  CURSOR c_get_org_adm (p_person_id hz_parties.party_id%TYPE) IS
  SELECT ps.responsible_org_unit_cd,
         hz.party_name,
         hz.party_id,
         count(*) NUM_OF_RECORDS
  FROM   igs_ps_ver_all ps,
         hz_parties hz,
         igs_ad_appl_all appl,
         igs_ad_ps_appl_inst applinst,
         igs_ad_appl_stat_v igsl1,
         igs_ad_ou_stat_v igsl2
  WHERE  ps.responsible_org_unit_cd = hz.party_number
    AND  appl.person_id = applinst.person_id
    AND  appl.admission_appl_number = applinst.admission_appl_number
    AND  applinst.course_cd = ps.course_cd
    AND  applinst.crv_version_number = ps.version_number
    AND  igsl1.adm_appl_status = appl.adm_appl_status
    AND  igsl1.s_adm_appl_status <> 'WITHDRAWN'
    AND  igsl2.adm_outcome_status = applinst.adm_outcome_status
    AND  igsl2.s_adm_outcome_status not in ('CANCELLED','NO-QUOTA', 'REJECTED', 'SUSPEND', 'VOIDED', 'WITHDRAWN')
    AND  applinst.person_id = p_person_id
  GROUP BY
         responsible_org_unit_cd,
         party_name,
         party_id;
  c_get_org_adm_rec c_get_org_adm%ROWTYPE;

  -- get Org Unit from FA Base Record's assoc_org_num.
  CURSOR c_get_assoc_org IS
  SELECT fa.assoc_org_num,
         hz.party_number,
         hz.party_name,
         hz.party_id
  FROM   igf_ap_fa_base_rec_all fa,
         hz_parties hz
  WHERE  fa.base_id = p_base_id
    AND  fa.assoc_org_num = hz.party_id;
  c_get_assoc_org_rec c_get_assoc_org%ROWTYPE;

  l_person_id hz_parties.party_id%TYPE;
  x_key_program_course_cd igs_ps_ver_all.course_cd%TYPE;
  x_version_number igs_ps_ver_all.version_number%TYPE;


BEGIN
  -- initialize
  x_return_status := 'S';
  x_msg_data := NULL;
  x_module := NULL;
  x_org_unit_cd := NULL;
  x_key_program_course_cd := NULL;
  x_version_number := NULL;

  -- obtain the person_id from the base_id value
  l_person_id := igf_gr_gen.get_person_id(p_base_id);

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    g_debug_string := 'Base ID = ' || p_base_id || ' Person ID = ' || l_person_id;
  END IF;

  -- determine the key program from the api. the key program is returned if the term has a
  -- key program override at a term level, otherwise the key program at the spa table is returned
  igf_ap_gen_001.get_key_program(p_base_id, x_key_program_course_cd, x_version_number);
  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    g_debug_string := g_debug_string || 'key program = ' || x_key_program_course_cd || ' version number = '||x_version_number ||':: ';
  END IF;
  IF(x_key_program_course_cd IS NOT NULL AND l_person_id IS NOT NULL)THEN
    OPEN c_get_org_enr(x_key_program_course_cd, x_version_number);
    FETCH c_get_org_enr INTO c_get_org_enr_rec;
    CLOSE c_get_org_enr;

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      g_debug_string := g_debug_string || 'Org Unit Code(from key program) = ' || c_get_org_enr_rec.org_unit_cd || ' :: ';
    END IF;

    IF (c_get_org_enr_rec.org_unit_cd IS NOT NULL) THEN   -- means, student is having key program.
      x_module := 'EN';
      x_org_unit_cd := c_get_org_enr_rec.org_unit_cd;
      x_org_party_id := c_get_org_enr_rec.party_id;
    END IF;
  ELSE
      -- no org unit could be derived from the key program

      -- get number of applications the person has. if the person has one application and has one appl instance attached to it
      -- get the org unit of the program that he has applied for. if he has more than one application instance (this can be
      -- out of the same application or from a different application), then determine the org unit from the FA Base Record
      OPEN cur_get_num_appl(l_person_id);
      FETCH cur_get_num_appl INTO rec_get_num_appl;
      CLOSE cur_get_num_appl;

      IF (rec_get_num_appl.num_of_appls >= 1) THEN

        -- get total number of instances.
        OPEN cur_get_num_applinst(l_person_id);
        FETCH cur_get_num_applinst INTO rec_get_num_applinst;
        CLOSE cur_get_num_applinst;

        IF (rec_get_num_applinst.num_of_records = 1) THEN    -- means, One application, One instance. So get org from Admissions.

          -- get org unit from Admissions.
          OPEN c_get_org_adm(l_person_id);
          FETCH c_get_org_adm INTO c_get_org_adm_rec;
          CLOSE c_get_org_adm;

          x_module := 'AD';
          x_org_unit_cd := c_get_org_adm_rec.responsible_org_unit_cd;
          x_org_party_id := c_get_org_adm_rec.party_id;
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            g_debug_string := g_debug_string || 'Org Unit Code(from no_of_applications) = ' || c_get_org_adm_rec.responsible_org_unit_cd || ' :: ';
          END IF;
          RETURN;
        ELSE    -- means more than one instance. Applications may be one or more. So get org from FA Base.

          -- get org unit from FA Base Record.
          OPEN c_get_assoc_org;
          FETCH c_get_assoc_org INTO c_get_assoc_org_rec;
          CLOSE c_get_assoc_org;

          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            g_debug_string := g_debug_string || 'Org Unit Code(from FA Base Record form) = ' || c_get_assoc_org_rec.party_number || ' :: ';
          END IF;

          IF (c_get_assoc_org_rec.party_number IS NOT NULL) THEN
            x_module := 'FA';
            x_org_unit_cd := c_get_assoc_org_rec.party_number;
            x_org_party_id := c_get_assoc_org_rec.assoc_org_num;
          ELSE    -- means more than one instances and FA Base record says nothing about associated org.
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              g_debug_string := g_debug_string || 'Org Unit Code is not derived';
            END IF;
            x_return_status := 'E';
            x_msg_data := 'IGF_AP_NO_PERSON_ORG';
          END IF;
        END IF;
      ELSE    -- No applications for him.
        x_return_status := 'E';
        x_msg_data := 'IGF_AP_NO_PERSON_ORG';
      END IF;
    END IF;

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_gen.get_associated_org.debug', g_debug_string);
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_gen.get_associated_org.debug', SQLERRM);
    END IF;

    x_return_status := 'E';
    x_msg_data := 'IGF_AP_NO_PERSON_ORG';
    fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME', 'IGF_GR_GEN.GET_ASSOCIATED_ORG'||' '||SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END get_associated_org;


/*  The following procedure obtains school code configured at Org Unit of the student's Key Program.
    Possible values of p_office_type are: OPE_ID_NUM, FED_SCH_CD, DL_SCH_CD, ETI_DES_NUM,
                                        CAM_SER_NUM, CEEB_CD PELL_ID SCH_NON_ED_BRC_ID.
    This procedure does not through any exceptions but returns success status 'S' for SUCCESS
    or 'E' for ERROR. The calling procedure should error out based on x_return_status. Also
    x_msg_data contains the proper error message if x_return_status is 'E'
 */
PROCEDURE get_stu_fao_code (p_base_id         IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_office_type     IN    igs_lookups_view.lookup_code%TYPE,
                            x_office_cd       OUT   NOCOPY igs_or_org_alt_ids.org_alternate_id_type%TYPE,
                            x_return_status   OUT   NOCOPY VARCHAR2,
                            x_msg_data        OUT   NOCOPY VARCHAR2)
AS
  /*
  ||  Created By : ugummall
  ||  Created On : 14-OCT-2003
  ||  Purpose :   Bug # 3102439. FA 126 Multiple FA offices.
  ||              For obtaining school code configured at org unit
  ||              of the student's key program.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR c_get_fa_office( p_org_unit_cd IN  hz_parties.party_number%TYPE,
                          p_office_type IN  igs_lookups_view.lookup_code%TYPE) IS
  SELECT org.org_alternate_id office_cd
  FROM   igs_or_org_alt_ids org,
         igs_or_org_alt_idtyp idt
  WHERE  org.org_structure_id = p_org_unit_cd
    AND  org.org_alternate_id_type = idt.org_alternate_id_type
    AND  SYSDATE BETWEEN org.start_date AND NVL(org.end_date, SYSDATE)
    AND  idt.system_id_type = p_office_type;
  c_get_fa_office_rec c_get_fa_office%ROWTYPE;

  l_org_unit_cd hz_parties.party_number%TYPE;
  l_module VARCHAR2(2);
  l_ret_status VARCHAR2(1);
  l_msg_data VARCHAR2(30);
  l_org_party_id hz_parties.party_id%TYPE;

BEGIN

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    g_debug_string := 'Base ID = ' || p_base_id || ' :: Office Type = ' || p_office_type;
  END IF;

  IF (p_base_id IS NOT NULL AND p_office_type IS NOT NULL) THEN

    get_associated_org(p_base_id, l_org_unit_cd, l_org_party_id, l_module, l_ret_status, l_msg_data);

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      g_debug_string := g_debug_string || 'associated org = ' || l_org_unit_cd || ' l_module = '||l_module ||':: ';
    END IF;

    IF (l_ret_status = 'E' AND l_msg_data IS NOT NULL) THEN
      x_return_status := l_ret_status;
      x_msg_data := l_msg_data;
    ELSE
      OPEN c_get_fa_office(l_org_unit_cd, p_office_type);
      FETCH c_get_fa_office INTO c_get_fa_office_rec;
      CLOSE c_get_fa_office;

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        g_debug_string := g_debug_string || ' Office ID = ' || c_get_fa_office_rec.office_cd;
      END IF;

      IF (c_get_fa_office_rec.office_cd IS NOT NULL) THEN
        x_office_cd := c_get_fa_office_rec.office_cd;
        x_return_status := 'S';
        RETURN;
      ELSE
        x_return_status := 'E';
        IF (p_office_type = 'FED_SCH_CD') THEN
          x_msg_data := 'IGF_AP_STU_FED_SCH_CD_NFND';
        ELSIF (p_office_type = 'SCH_NON_ED_BRC_ID') THEN
          x_msg_data := 'IGF_AP_SCH_NONED_NOTFND';
        ELSIF (p_office_type = 'OPE_ID_NUM') THEN
          x_msg_data := 'IGF_SL_STU_OPE_NOTFND';
        ELSIF (p_office_type = 'DL_SCH_CD') THEN
          x_msg_data := 'IGF_SL_DL_STU_DLCD_NOTFND';
        ELSIF (p_office_type = 'PELL_ID') THEN
          x_msg_data := 'IGF_GR_NO_ATTEND_PELL';
        ELSIF (p_office_type = 'ETI_DES_NUM') THEN
          x_msg_data := 'IGF_AP_NO_ETI_DES_NUM';
        ELSIF (p_office_type = 'ENTITY_ID') THEN
          x_msg_data := 'IGF_GR_NO_ATTEND_ENTITY';
        ELSE
          x_msg_data := NULL;
        END IF;
      END IF;
    END IF;
  ELSE
    x_return_status := 'E';
  END IF;

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_gen.get_stu_fao_code.debug', g_debug_string);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_gen.get_stu_fao_code.debug', SQLERRM);
    END IF;

    x_return_status := 'E';
END get_stu_fao_code;

FUNCTION get_fed_fund_code (p_n_award_id      IN igf_aw_award_all.award_id%TYPE,
                            p_v_message_name  OUT NOCOPY VARCHAR2)
RETURN igf_aw_fund_cat_all.fed_fund_code%TYPE AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 13 October 2004
--
-- Purpose     : Generic Function to return fed fund code for the input award id
-- Invoked     :
-- Function    :
--
-- Parameters  : p_n_award_id    : IN parameter. Required.
--               p_v_message_name  : OUT parameter
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
CURSOR  c_igf_aw_award (cp_n_award_id igf_aw_award_all.award_id%TYPE) IS
SELECT  fund_id
FROM    igf_aw_award_all
WHERE   award_id = cp_n_award_id;

CURSOR  c_igf_fmast_fcat (cp_n_fund_id igf_aw_fund_mast_all.fund_id%TYPE) IS
SELECT  fcat.fed_fund_code
FROM     igf_aw_fund_mast_all fmast
        ,igf_aw_fund_cat_all  fcat
WHERE   fmast.fund_code = fcat.fund_code
AND     fmast.fund_id   = cp_n_fund_id;

l_n_fund_id        igf_aw_fund_mast_all.fund_id%TYPE;
l_v_fed_fund_code  igf_aw_fund_cat_all.fed_fund_code%TYPE;

BEGIN

  IF p_n_award_id IS NULL THEN
    p_v_message_name:= 'IGS_GE_INVALID_VALUE';
    RETURN NULL;
  END IF;

  -- get the fund id corresponding to the input award id
  OPEN  c_igf_aw_award (cp_n_award_id => p_n_award_id);
  FETCH c_igf_aw_award  INTO l_n_fund_id;
  CLOSE c_igf_aw_award ;

  OPEN  c_igf_fmast_fcat (cp_n_fund_id => l_n_fund_id);
  FETCH c_igf_fmast_fcat INTO l_v_fed_fund_code;
  CLOSE c_igf_fmast_fcat;

  p_v_message_name := NULL;
  RETURN l_v_fed_fund_code;
EXCEPTION
  WHEN OTHERS THEN
   IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
   THEN
     fnd_log.string( fnd_log.level_exception, 'igf_sl_gen.get_fed_fund_code exception', SQLERRM);
   END IF;
   fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_gen.get_fed_fund_code');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END get_fed_fund_code;

FUNCTION check_prc_chg (p_v_relationship_cd IN igf_sl_cl_setup_all.relationship_cd%TYPE,
                        p_v_cal_type        IN igf_aw_fund_mast_all.ci_cal_type%TYPE ,
                        p_n_sequence_number IN igf_aw_fund_mast_all.ci_sequence_number%TYPE
                        )
RETURN BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 13 October 2004
--
-- Purpose     : Generic Function
-- Invoked     :
-- Function    :
--
-- Parameters  : p_v_relationship_cd    : IN parameter. Required.
--               p_v_cal_type           : IN parameter. Required.
--               p_n_sequence_number    : IN parameter. Required.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
CURSOR  c_loan_num ( cp_v_relationship_cd igf_sl_cl_setup_all.relationship_cd%TYPE,
                     cp_v_cal_type        igf_aw_fund_mast_all.ci_cal_type%TYPE,
                     cp_n_sequence_number igf_aw_fund_mast_all.ci_sequence_number%TYPE
                   ) IS
SELECT loans.loan_number
FROM    igf_sl_lor_all lor
       ,igf_sl_loans_all loans
       ,igf_aw_award_all awd
       ,igf_aw_fund_mast_all fmast
WHERE  lor.relationship_cd = cp_v_relationship_cd
AND    loans.loan_id  = lor.loan_id
AND    (loans.loan_status = 'S' OR loans.loan_chg_status = 'S')
AND    awd.award_id   = loans.award_id
AND    fmast.fund_id  = awd.fund_id
AND    fmast.ci_cal_type = cp_v_cal_type
AND    fmast.ci_sequence_number = cp_n_sequence_number;

l_v_loan_number           igf_sl_loans_all.loan_number%TYPE;
BEGIN

  OPEN c_loan_num ( cp_v_relationship_cd => p_v_relationship_cd,
                    cp_v_cal_type        => p_v_cal_type,
                    cp_n_sequence_number => p_n_sequence_number
                  );
  FETCH c_loan_num INTO l_v_loan_number;
  -- if there are no FFELP Loan Records that have Loan Status or
  -- Loan Change Status in 'Sent' Status that use Relationship Code
  IF c_loan_num%NOTFOUND THEN
    CLOSE c_loan_num;
    RETURN TRUE;
  END IF;
  CLOSE c_loan_num;
  RETURN FALSE;
EXCEPTION
  WHEN OTHERS THEN
   IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
   THEN
     fnd_log.string( fnd_log.level_exception, 'igf_sl_gen.check_prc_chg exception', SQLERRM);
   END IF;
   fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_gen.check_prc_chg');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END check_prc_chg;

FUNCTION check_prc_chgm (p_v_relationship_cd IN igf_sl_cl_setup_all.relationship_cd%TYPE,
                         p_v_cal_type        IN igf_aw_fund_mast_all.ci_cal_type%TYPE ,
                         p_n_sequence_number IN igf_aw_fund_mast_all.ci_sequence_number%TYPE
                        )
RETURN BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 13 October 2004
--
-- Purpose     : Generic Function
-- Invoked     :
-- Function    :
--
-- Parameters  : p_v_relationship_cd    : IN parameter. Required.
--               p_v_cal_type           : IN parameter. Required.
--               p_n_sequence_number    : IN parameter. Required.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
CURSOR  c_loan_num ( cp_v_relationship_cd igf_sl_cl_setup_all.relationship_cd%TYPE,
                     cp_v_cal_type        igf_aw_fund_mast_all.ci_cal_type%TYPE,
                     cp_n_sequence_number igf_aw_fund_mast_all.ci_sequence_number%TYPE
                   ) IS
SELECT loans.loan_number
FROM    igf_sl_lor_all lor
       ,igf_sl_loans_all loans
       ,igf_aw_award_all awd
       ,igf_aw_fund_mast_all fmast
WHERE  lor.relationship_cd = cp_v_relationship_cd
AND    loans.loan_id  = lor.loan_id
AND    awd.award_id   = loans.award_id
AND    fmast.fund_id  = awd.fund_id
AND    fmast.ci_cal_type = cp_v_cal_type
AND    fmast.ci_sequence_number = cp_n_sequence_number;

l_v_loan_number           igf_sl_loans_all.loan_number%TYPE;

BEGIN
  OPEN c_loan_num ( cp_v_relationship_cd => p_v_relationship_cd,
                    cp_v_cal_type        => p_v_cal_type,
                    cp_n_sequence_number => p_n_sequence_number
                  );
  FETCH c_loan_num INTO l_v_loan_number;
  -- if there are no FFELP Loan Records that use Relationship Code
  IF c_loan_num%NOTFOUND THEN
    CLOSE c_loan_num;
    RETURN TRUE;
  END IF;
  CLOSE c_loan_num;
  RETURN FALSE;
EXCEPTION
  WHEN OTHERS THEN
   IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
   THEN
     fnd_log.string( fnd_log.level_exception, 'igf_sl_gen.check_prc_chgm exception', SQLERRM);
   END IF;
   fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_gen.check_prc_chgm');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END check_prc_chgm;

PROCEDURE update_cl_chg_status(p_v_loan_number IN igf_sl_loans_all.loan_number%TYPE) IS
------------------------------------------------------------------
--Created by  : svuppala, Oracle IDC
--Date created: 20-Oct-2004
--
-- Purpose     : Update Loan Change Status
-- Invoked     :
--
-- Parameters  : p_loan_id    : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------

--l_loan_chg_status igf_sl_loans_all.loan_chg_status%TYPE;
-- ROWID row_id

CURSOR  c_sl_loans (cp_loan_number_txt igf_sl_loans_all.loan_number%TYPE) IS
SELECT  igfsla.* ,igfsla.ROWID ROW_ID
FROM    igf_sl_loans_all igfsla
WHERE   loan_number = cp_loan_number_txt;

 rec_c_sl_loans c_sl_loans%ROWTYPE;

CURSOR  c_clchsn (cp_loan_number_txt igf_sl_loans_all.loan_number%TYPE) IS
SELECT  'x'
FROM    igf_sl_clchsn_dtls
WHERE   loan_number_txt = cp_loan_number_txt
AND     status_code = 'S';

rec_c_clchsn c_clchsn%ROWTYPE;

CURSOR  c_clchsn2 (cp_loan_number_txt igf_sl_loans_all.loan_number%TYPE) IS
SELECT  'x'
FROM    igf_sl_clchsn_dtls
WHERE   loan_number_txt = cp_loan_number_txt
AND     status_code = 'A'
AND     response_status_code = 'R';

rec_c_clchsn2 c_clchsn2%ROWTYPE;


CURSOR  c_clchsn3 (cp_loan_number_txt igf_sl_loans_all.loan_number%TYPE) IS
SELECT  'x'
FROM    igf_sl_clchsn_dtls
WHERE   loan_number_txt = cp_loan_number_txt
AND     status_code = 'A'
AND     (response_status_code = 'F' OR response_status_code = 'P') ;

rec_c_clchsn3 c_clchsn2%ROWTYPE;

CURSOR  c_get_clchsn_accept (cp_loan_number_txt igf_sl_loans_all.loan_number%TYPE) IS
SELECT  'x'
FROM    igf_sl_clchsn_dtls
WHERE   loan_number_txt = cp_loan_number_txt
AND     status_code = 'A'
AND     response_status_code = 'A';

rec_c_get_clchsn_accept c_get_clchsn_accept%ROWTYPE;

CURSOR  c_clchsn4 (cp_loan_number_txt igf_sl_loans_all.loan_number%TYPE) IS
SELECT  'x'
FROM    igf_sl_clchsn_dtls
WHERE   loan_number_txt = cp_loan_number_txt
AND     status_code = 'R';

rec_c_clchsn4 c_clchsn4%ROWTYPE;
lv_chg_status VARCHAR2(30);

BEGIN
  lv_chg_status := '*';

  IF lv_chg_status = '*' THEN
    OPEN  c_clchsn(p_v_loan_number);
    FETCH c_clchsn INTO rec_c_clchsn;
    IF(c_clchsn%FOUND) THEN
      -- if any of the change record in sent status update the loan change status to sent
      lv_chg_status := 'S';
    END IF;
    CLOSE c_clchsn;
  END IF;
  -- If any of the Change Record is in "Acknowledged" status and there are Reject Codes present
  -- for the transaction, then Loan Change Status would be updated to "Rejected"
  IF lv_chg_status = '*' THEN
    OPEN  c_clchsn2(p_v_loan_number);
    FETCH c_clchsn2 INTO rec_c_clchsn2;
    IF(c_clchsn2%FOUND) THEN
      lv_chg_status        := 'R';
    END IF;
    CLOSE c_clchsn2;
  END IF;
  -- If there are no "Acknowledged" Rejected Records and no "Sent" Records,
  -- the Loan Status would be updated to Sent" if any of the "Acknowledged" record
  -- is Forwarded or Pending
  IF lv_chg_status = '*' THEN
    OPEN  c_clchsn3(p_v_loan_number);
    FETCH c_clchsn3 INTO rec_c_clchsn3;
    IF(c_clchsn3%FOUND) THEN
        lv_chg_status        := 'S';
    END IF;
    CLOSE c_clchsn3;
  END IF;
  -- loan change status would be updated to "Accepted"
  -- if all of the "Acknowledged" records are Accepted
  IF lv_chg_status = '*' THEN
    OPEN  c_get_clchsn_accept (cp_loan_number_txt => p_v_loan_number);
    FETCH c_get_clchsn_accept INTO rec_c_get_clchsn_accept ;
    IF c_get_clchsn_accept%FOUND THEN
      lv_chg_status        := 'A';
    END IF;
    CLOSE c_get_clchsn_accept ;
  END IF;
  -- If there are no "Acknowledged" Records, "Sent" Records and any one Change Record
  -- is in "Ready to Send" then Loan Change Status would be "Ready to Send" else
  -- it would be "Not Ready".
  IF lv_chg_status = '*' THEN
    OPEN  c_clchsn4(cp_loan_number_txt => p_v_loan_number);
    FETCH c_clchsn4 INTO rec_c_clchsn4;
    IF(c_clchsn4%FOUND) THEN
      -- if change record is ready to send then loan change status
      -- should be G - Ready to Send
      lv_chg_status        := 'G';
    ELSE
      lv_chg_status        := 'N';
    END IF;
    CLOSE c_clchsn4;
  END IF;
  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_gen.update_cl_chg_status.debug','Loan Change Status = ' || lv_chg_status);
  END IF;
  IF lv_chg_status <> '*' THEN
    OPEN  c_sl_loans(p_v_loan_number);
    FETCH c_sl_loans INTO rec_c_sl_loans;
    CLOSE c_sl_loans;

    igf_sl_loans_pkg.update_row(
      x_rowid                => rec_c_sl_loans.row_id,
      x_loan_id               => rec_c_sl_loans.loan_id,
      x_award_id              => rec_c_sl_loans.award_id,
      x_seq_num               => rec_c_sl_loans.seq_num,
      x_loan_number           => rec_c_sl_loans.loan_number,
      x_loan_per_begin_date   => rec_c_sl_loans.loan_per_begin_date,
      x_loan_per_end_date     => rec_c_sl_loans.loan_per_end_date,
      x_loan_status           => rec_c_sl_loans.loan_status,
      x_loan_status_date      => rec_c_sl_loans.loan_status_date,
      x_loan_chg_status       => lv_chg_status,
      x_loan_chg_status_date  => rec_c_sl_loans.loan_chg_status_date,
      x_active                => rec_c_sl_loans.active,
      x_active_date           => rec_c_sl_loans.active_date,
      x_borw_detrm_code       => rec_c_sl_loans.borw_detrm_code,
      x_legacy_record_flag    => rec_c_sl_loans.legacy_record_flag,
      x_external_loan_id_txt  => rec_c_sl_loans.external_loan_id_txt
    );
   END IF;

 END update_cl_chg_status;

PROCEDURE get_stu_ant_fao_code
                             (p_base_id         IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_office_type     IN    igs_lookups_view.lookup_code%TYPE,
                              x_office_cd       OUT   NOCOPY igs_or_org_alt_ids.org_alternate_id_type%TYPE,
                              x_return_status   OUT   NOCOPY VARCHAR2,
                              x_msg_data        OUT   NOCOPY VARCHAR2)
AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 11-NOV-2004
  ||  Purpose : Bug# 3102439. FA 152 Auto Re-pkg
  ||            For obtaining responsible org unit code from Anticipated data that
  ||            is associated with the student if Actual data is not available.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  museshad        15-Jul-2005     Build FA 140.
  ||                                  Modified the logic for getting the anticipated
  ||                                  Org Unit. Anticipated Org Unit is derived by -
  ||                                  1)  Get anticipated Org Unit from anticipated
  ||                                      table (igf_ap_fa_ant_data) directly
  ||                                  2)  If step 1 does not give a valid Org Unit,
  ||                                      then get the anticipated key program and
  ||                                      get the Org Unit corresponding to this
  ||                                      key program.
  ||  (reverse chronological order - newest change first)
  */

-- This cursor gets the anticipated data for all the terms
-- We then loop thru all the terms to find out if anticipated
-- data is available for the current term
CURSOR c_ant_data_curr_term(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
IS
  SELECT fant.*
  FROM igf_ap_fa_ant_data fant
  WHERE fant.base_id = cp_base_id;

lv_ant_data_curr_term_rec c_ant_data_curr_term%ROWTYPE;

-- Scans all the terms (starting from the earliest) in the student's
-- award year for a valid anticipated Org Unit.
-- This would be used if the current term does not have anticipated data.
CURSOR c_ant_data_all_terms(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
IS
  SELECT    ant_data.*
  FROM
            igf_aw_awd_ld_cal_v     awd_year_terms,
            igf_ap_fa_ant_data      ant_data
  WHERE
            ant_data.ld_cal_type = awd_year_terms.ld_cal_type AND
            ant_data.ld_sequence_number = awd_year_terms.ld_sequence_number AND
            ant_data.base_id = cp_base_id AND
            ant_data.org_unit_cd IS NOT NULL
  ORDER BY
            igf_aw_packaging.get_term_start_date(cp_base_id, awd_year_terms.ld_cal_type, awd_year_terms.ld_sequence_number) ASC;

lv_ant_data_all_terms_rec c_ant_data_all_terms%ROWTYPE;

-- Scans all the terms (starting from the earliest) in the student's
-- award year for a valid anticipated key prgram and version. Returns the
-- Org Unit corresponding to the anticipated key prog and version
CURSOR c_get_ant_org_unit(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
IS
  SELECT    prog.*
  FROM
            igf_aw_awd_ld_cal_v     awd_year_terms,
            igf_ap_fa_ant_data      ant_data,
            igs_ps_ver_all          prog
  WHERE
            ant_data.ld_cal_type = awd_year_terms.ld_cal_type AND
            ant_data.ld_sequence_number = awd_year_terms.ld_sequence_number AND
            ant_data.base_id = cp_base_id and
            ant_data.program_cd = prog.course_cd AND
            prog.course_status = 'ACTIVE' AND
            ant_data.program_cd IS NOT NULL AND
            prog.responsible_org_unit_cd IS NOT NULL
  ORDER BY
            igf_aw_packaging.get_term_start_date(cp_base_id, awd_year_terms.ld_cal_type, awd_year_terms.ld_sequence_number) ASC,
            prog.version_number DESC;

l_get_ant_org_unit_rec c_get_ant_org_unit%ROWTYPE;

CURSOR c_get_fa_office( p_org_unit_cd IN  hz_parties.party_number%TYPE,
                        p_office_type IN  igs_lookups_view.lookup_code%TYPE) IS
  SELECT org.org_alternate_id office_cd
  FROM   igs_or_org_alt_ids org,
         igs_or_org_alt_idtyp idt
  WHERE  org.org_structure_id = p_org_unit_cd
    AND  org.org_alternate_id_type = idt.org_alternate_id_type
    AND  SYSDATE BETWEEN org.start_date AND NVL(org.end_date, SYSDATE)
    AND  idt.system_id_type = p_office_type;

c_get_fa_office_rec c_get_fa_office%ROWTYPE;

lv_start_dt DATE;
lv_end_dt   DATE;
l_person_id NUMBER;
lv_ant_org_unit_cd igf_ap_fa_ant_data.org_unit_cd%TYPE := NULL;

BEGIN
  -- initialize
  x_return_status := 'S';
  x_msg_data      := NULL;
  x_office_cd     := NULL;

  -- obtain the person_id from the base_id value
  OPEN c_ant_data_curr_term(p_base_id);
  LOOP
    FETCH c_ant_data_curr_term INTO lv_ant_data_curr_term_rec;
    EXIT when c_ant_data_curr_term%NOTFOUND;

    lv_start_dt := igs_ca_compute_da_val_pkg.cal_da_elt_val(
                                                              'FIRST_DAY_TERM',
                                                               lv_ant_data_curr_term_rec.ld_cal_type,
                                                               lv_ant_data_curr_term_rec.ld_sequence_number,
                                                               lv_ant_data_curr_term_rec.org_unit_cd,
                                                               lv_ant_data_curr_term_rec.program_type,
                                                               lv_ant_data_curr_term_rec.program_cd
                                                              );

    lv_end_dt := igs_ca_compute_da_val_pkg.cal_da_elt_val(
                                                             'LAST_DAY_TERM',
                                                               lv_ant_data_curr_term_rec.ld_cal_type,
                                                               lv_ant_data_curr_term_rec.ld_sequence_number,
                                                               lv_ant_data_curr_term_rec.org_unit_cd,
                                                               lv_ant_data_curr_term_rec.program_type,
                                                               lv_ant_data_curr_term_rec.program_cd
                                                              );

    IF sysdate BETWEEN lv_start_dt AND lv_end_dt AND (lv_ant_data_curr_term_rec.org_unit_cd IS NOT NULL) THEN
      -- Current term has anticipated data
      lv_ant_org_unit_cd := lv_ant_data_curr_term_rec.org_unit_cd;

      -- Log values
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,
                        'igf.plsql.igf_sl_gen.get_stu_ant_fao_code',
                        'Found anticipated Org Unit for the current term. Org Unit: ' ||lv_ant_org_unit_cd||
                        ', ld_cal_type: ' ||lv_ant_data_curr_term_rec.ld_cal_type||
                        ', ld_sequence_number: ' ||lv_ant_data_curr_term_rec.ld_sequence_number);
      END IF;
    END IF;

  END LOOP;
  CLOSE c_ant_data_curr_term;

  IF lv_ant_org_unit_cd IS NULL THEN
    -- Current term does not have anticipated data.
    -- Search for anticipated data
    OPEN c_ant_data_all_terms(p_base_id);
    FETCH c_ant_data_all_terms INTO lv_ant_data_all_terms_rec;
    CLOSE c_ant_data_all_terms;

    IF (lv_ant_data_all_terms_rec.org_unit_cd IS NOT NULL) THEN
      lv_ant_org_unit_cd := lv_ant_data_all_terms_rec.org_unit_cd;

      -- Log values
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,
                        'igf.plsql.igf_sl_gen.get_stu_ant_fao_code',
                        'Found anticipated Org Unit in one of the terms in the award year. Org Unit: ' ||lv_ant_org_unit_cd||
                        ', ld_cal_type: ' ||lv_ant_data_all_terms_rec.ld_cal_type||
                        ', ld_sequence_number: ' ||lv_ant_data_all_terms_rec.ld_sequence_number);
      END IF;
    ELSE
      -- Anticipated Org Unit is not available.
      -- Try to get the Org Unit from the anticipated key prog
      OPEN c_get_ant_org_unit(p_base_id);
      FETCH c_get_ant_org_unit INTO l_get_ant_org_unit_rec;

      IF (c_get_ant_org_unit%FOUND) THEN
        lv_ant_org_unit_cd := l_get_ant_org_unit_rec.responsible_org_unit_cd;

        -- Log values
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_sl_gen.get_stu_ant_fao_code',
                          'Found Org Unit for the anticipated key program. Org Unit: ' ||lv_ant_org_unit_cd||
                          ', Key prog: ' ||l_get_ant_org_unit_rec.course_cd||
                          ', Version: ' ||l_get_ant_org_unit_rec.version_number);
        END IF;
      ELSE
        x_return_status := 'E';
      END IF;

      CLOSE c_get_ant_org_unit;
    END IF;
  END IF;

 IF x_return_status <> 'E' AND lv_ant_org_unit_cd IS NOT NULL THEN
    OPEN c_get_fa_office(lv_ant_org_unit_cd, p_office_type);
    FETCH c_get_fa_office INTO c_get_fa_office_rec;
    CLOSE c_get_fa_office;
 END IF;

 IF (c_get_fa_office_rec.office_cd IS NOT NULL) THEN
     x_office_cd := c_get_fa_office_rec.office_cd;
     x_return_status := 'S';
     RETURN;
 ELSE
    x_return_status := 'E';
     IF (p_office_type = 'FED_SCH_CD') THEN
       x_msg_data := 'IGF_AP_STU_FED_SCH_CD_NFND';
     ELSIF (p_office_type = 'SCH_NON_ED_BRC_ID') THEN
       x_msg_data := 'IGF_AP_SCH_NONED_NOTFND';
     ELSIF (p_office_type = 'OPE_ID_NUM') THEN
       x_msg_data := 'IGF_SL_STU_OPE_NOTFND';
     ELSIF (p_office_type = 'DL_SCH_CD') THEN
       x_msg_data := 'IGF_SL_DL_STU_DLCD_NOTFND';
     ELSIF (p_office_type = 'PELL_ID') THEN
       x_msg_data := 'IGF_GR_NO_ATTEND_PELL';
     ELSIF (p_office_type = 'ETI_DES_NUM') THEN
       x_msg_data := 'IGF_AP_NO_ETI_DES_NUM';
     ELSIF (p_office_type = 'ENTITY_ID') THEN
       x_msg_data := 'IGF_GR_NO_ATTEND_ENTITY';
     ELSE
       x_msg_data := NULL;
     END IF;

    -- Log values
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_gen.get_stu_ant_fao_code', 'Anticipated Org Unit not defined');
    END IF;
 END IF;

END get_stu_ant_fao_code;

END igf_sl_gen;

/
