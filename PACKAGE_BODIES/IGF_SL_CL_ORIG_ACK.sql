--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_ORIG_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_ORIG_ACK" AS
/* $Header: IGFSL09B.pls 120.25 2006/08/23 11:45:09 bvisvana ship $ */
--
---------------------------------------------------------------------------------
--
--    Created By       :    mesriniv
--    Date Created By  :    2000/12/07
--    Purpose          :    To Process Common Line Acknowledgement
--                          Data
--    Known Limitations,Enhancements or Remarks
--    Change History   :
---------------------------------------------------------------------------------
--  Who         When            What
---------------------------------------------------------------------------------
--  bvisvana    10-Apr-2006     FA 161 - Bug # 5006583 - CL4 Addendum
--                              Two new columns (borrower alien reg number and e-signature source type code) +
--                              validations based on fed appl form code + TBH impact
--  bvisvana    29-Jul-2005     Bug # 4120082 - Telphone Number not created - New function created : create_person_telephone_record
--  mnade       25-Jan-2005     Bug - 4139742 - Changes to allow Status override for Guarantor
--                              Lender Statuses
--  mnade       21-Jan-2005     Bug - 4136563 - Disbursement update problems.
--                              The disbursements in @8 will be updated based on the flag and
--                              award disbursement changes status.
--  mnade       21-Jan-2005     Bug - 4136168 - @4 Cosigner DOBs were containing 0s,
--                              Handled using REPLACE
--  mnade       19-Jan-2005     Bug - 4124893, 4127320, 4115326, 4130089
--                              SCR relation creation, CL5 Loan Aceptance, Change ACK Status Update
--                              Address creation and Person creation even for Staffor Loans.
--  mnade       13-Jan-2005     Bug - 4119363
--                              Termination status was missing for CL4 added the same in status copying area.
--  mnade       12-Jan-2005     Bug - 4108463
--                              The CL 4 Final Response Type was checked wrongly
--                              Added Lender Approved Amount in Event Notification and check on the same.
--  mnade       10-Jan-2005     Bug # 4101646
--                              Reinstatement data was not picked properly.
--  mnade       20-Dec-2004     Bug 4058180
--                              B and B both will be considered as approved responsed
--                              Log will contain both Student and Borrower Details
--                              Batch Id will still continue to come blank
--                              Correction for Interest Rate
--                              Record Type Indicator corrected
--  smadathi    29-oct-2004     Bug 3416936. Added new business logic as part of
--                              CL4 changes
--  veramach    July 2004       FA 151 HR Integration (bug#3709292)
--                              Impacts of obsoleting columns from igf_aw_awd_disb_all
---------------------------------------------------------------------------------
--  sjadhav     21-Jan-2004     Bug 3387706. Lender should be updated by process
--                              Added logic to updat the Lender/Guarantor Info
--                              Added more log messages
---------------------------------------------------------------------------------
--  veramach     11-Dec-2003    Bug # 3184891
--                              removed calls to igf_ap_gen.write_log and added common logging
--  veramach     04-Nov-03      FA 125 Multiple Distr methods - changed signature of igf_aw_awd_disb_pkg.update_row(added attendance_type_code) in procedure upd_disb_details
--  ugummall    21-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
--                              removed cur_school_id and l_school_id and their
--                              references. Removed the clause which meant for selection
--                              based on school_id from the cur_Hrecord cursor as the job
--                              always runs for one specific school.
--
--  bkkumar     08-oct-2003   Bug 3104228
--                             a) Impact of adding the relationship_cd
--                             in igf_sl_lor_all table and obsoleting
--                             BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
--                             GUARANTOR_ID, DUNS_GUARNT_ID,
--                             LENDER_ID, DUNS_LENDER_ID
--                             LEND_NON_ED_BRC_ID, RECIPIENT_ID
--                             RECIPIENT_TYPE,DUNS_RECIP_ID
--                             RECIP_NON_ED_BRC_ID columns.
--                             b) The DUNS_BORW_LENDER_ID
--                             DUNS_GUARNT_ID
--                             DUNS_LENDER_ID
--                             DUNS_RECIP_ID columns are osboleted from the
--                             igf_sl_lor_loc_all table.
--                             c) Removed the hard coded strings from the cursors.
---------------------------------------------------------------------------------
--  gmuralid   03-07-2003    Bug 2995944 - Legacy Part 3 - FFELP Import
--                           Added legacy record flag as parameter to
--                           igf_sl_loans_pkg
---------------------------------------------------------------------------------
--    sjadhav     20-Jun-2003     Bug 2983181
--                                Added debug log messages
---------------------------------------------------------------------------------
--    sjadhav     11-Apr-2003     Bug 2892963
--                                Print message IGF_SL_NO_LOAN_NUMBER when
--                                Loan Number does not exist in the system
---------------------------------------------------------------------------------
--    sjadhav     27-Mar-2003     Bug 2863960
--                                Changed Disb Gross Amt to Disb Accepted Amt
--                                to insert into igf_sl_awd_disb table
---------------------------------------------------------------------------------
--    agairola    15-Mar-2002     Modified the Update Row of
--                                IGF_SL_LOANS_PKG for Borrower's
--                                Determination as part of
--                                Refunds DLD 2144600
---------------------------------------------------------------------------------
--    masehgal    17-Feb-2002     # 2216956   FACR007
--                                Added Elec_mpn_ind,Borrow_sign_ind in
--                                igf_sl_lor_pkg.update_row and igf_sl_cl_resp_r1
---------------------------------------------------------------------------------
--    npalanis    11/jan/2002     The process Common Line Origination
--                                Process( procedure place_holds_disb )
--                                is modified to pick up disbursement
--                                records that are in planned state,
--                                insert records into IGF_DB_DISB_HOLDS
--                                table with hold 'EXTERNAL' and
--                                hold type 'SYSTEM' and also
--                                update manual_hold_ind flag in
--                                IGF_AW_AWD_DISB table to 'Y'.
--                                enh bug no-2154941.
---------------------------------------------------------------------------------
--    ssawhney    2nd jan         TBH call of IGF_AW_AWD_DISB table
--                                changed in Stud Emp build
--                                en bug no 2161847
---------------------------------------------------------------------------------
--    mesriniv    13/07/2001      Bug 1806850
--                                Modified the call to
--                                igf_aw_awd_disb_pkg.update_row since 9 columns
--                                were added to the table igf_aw_awd_disb_all.
---------------------------------------------------------------------------------
--    ENH BUG NO: 1769051         ENH DESCRIPTION: Loan Processing -
--                                Nov 2001 DLD
---------------------------------------------------------------------------------
--    mesriniv    13/05/2001      1.A new Procedure by Name
--                                insert_into_reps_r4 has been
--                                defined and called from
--                                procedure insert_into_resp_r1
--                                in order to insert @4 Records.
--
--                                2.A procedure show_alt_details
--                                has been defined and is called from
--                                update_lor procedure to display the Alt
--                                Loan Borrower details.
--
--                                3.Wherever Variables referred to
--                                viewname.field%TYPE has been changed
--                                to TableName.fieldname%TYPE
--
--                                4.A global Array title_array has been
--                                  defined to get the Lookup Descriptions
--                                5.Formatting of Output was enhanced
---------------------------------------------------------------------------------
--

 --
 -- variable to store debug messages
 --

gv_debug_str VARCHAR2(4000);

g_loaded_file_ident_code           igf_sl_cl_batch_all.file_ident_code%TYPE;
g_loaded_recipient_id              igf_sl_cl_batch_all.recipient_id%TYPE;
g_loaded_recip_non_ed_brc_id       igf_sl_cl_batch_all.recip_non_ed_brc_id%TYPE;
g_file_source_id                   igf_sl_cl_batch_all.source_id%TYPE;
g_file_source_non_ed_brc_id        igf_sl_cl_batch_all.source_non_ed_brc_id%TYPE;
g_loaded_batch_id                  igf_sl_cl_batch_all.batch_id%TYPE;
g_c_update_disb_dtls               varchar2(10);
--
-- Added exceptions so that unhandled exception is not raised
-- for user defined exception
--

batch_exceptions EXCEPTION;


 -- Select the Records from Resp1 Table to process them

 CURSOR cur_resp1_records(p_cbth_id   igf_sl_cl_resp_r1.cbth_id%TYPE,
                          p_rec_status igf_sl_cl_resp_r1.resp_record_status%TYPE )
 IS
        SELECT clrp1.* FROM igf_sl_cl_resp_r1 clrp1
        WHERE  clrp1.cbth_id            = p_cbth_id
        AND    clrp1.resp_record_status = p_rec_status
        ORDER BY clrp1.clrp1_id
        FOR UPDATE OF resp_record_status NOWAIT;


 Format_1_rec           igf_sl_load_file_t%ROWTYPE;
 Format_1_rec_temp      igf_sl_load_file_t%ROWTYPE;
 loaded_1rec            cur_resp1_records%ROWTYPE;
 g_cbth_id              igf_sl_cl_batch_all.cbth_id%TYPE;
 l_loan_number          igf_sl_loans_all.loan_number%TYPE;
 p_disb_title           VARCHAR2(1000);
 p_disb_under_line      VARCHAR2(1000);

 TYPE tab_title IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

 TYPE awd_disb  IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
 TYPE loc_disb  IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
 awd_disb_array         awd_disb;
 loc_disb_array         loc_disb;

 title_array            tab_title;
 l_title_flag           VARCHAR2(1);
 p_cl_file_type         igf_sl_cl_file_type.cl_file_type%TYPE;
 g_v_cl_version         igf_sl_cl_setup_all.cl_version%TYPE;


 --Procedure Declarations

PROCEDURE insert_into_resp1(p_loan_number          igf_sl_loans_all.loan_number%TYPE,
                            p_resp_record_status   igf_sl_cl_resp_r1_all.resp_record_status%TYPE,
                            p_rec_type_ind         igf_sl_cl_resp_r1_all.rec_type_ind%TYPE);

PROCEDURE process_1_records;

PROCEDURE update_lor(p_clrp1_id     igf_sl_cl_resp_r1_all.clrp1_id%TYPE,
                     p_loan_number  igf_sl_loans_all.loan_number%TYPE,
                     p_rejected_rec BOOLEAN);

PROCEDURE compare_disbursements(p_loan_number igf_sl_loans_all.loan_number%TYPE);

--
-- Declaration of a Procedure for inserting the @4 Records as per New DLD
--

PROCEDURE insert_into_resp_r4(p_clrp1_id       igf_sl_cl_resp_r1_all.clrp1_id%TYPE,
                              p_r4_record      igf_sl_load_file_t.record_data%TYPE);

--
-- Procedure to show the difference in information bet OFA and File Details
--
PROCEDURE show_alt_details(p_clrp1_id  igf_sl_cl_resp_r1_all.clrp1_id%TYPE,
                           p_loan_id   igf_sl_loans_all.loan_id%TYPE);

-- procedure for enabling statement level logging
PROCEDURE log_to_fnd ( p_v_module IN VARCHAR2,
                       p_v_string IN VARCHAR2
                     );

PROCEDURE process_borrow_stud_rec (p_rec_resp_r1   IN  igf_sl_cl_resp_r1_all%ROWTYPE);

PROCEDURE perform_ssn_match(p_rec_resp_r1     IN  igf_sl_cl_resp_r1_all%ROWTYPE,
                            p_c_pers_typ_ind  IN  VARCHAR2,
                            p_n_person_id     OUT NOCOPY hz_parties.party_id%TYPE,
                            p_n_person_number OUT NOCOPY hz_parties.party_number%TYPE,
                            p_c_pers_exists   OUT NOCOPY BOOLEAN
                            ) ;

FUNCTION create_person_record(p_rec_resp_r1     IN  igf_sl_cl_resp_r1_all%ROWTYPE,
                              p_c_pers_typ_ind  IN  VARCHAR2,
                              p_n_person_id     OUT NOCOPY hz_parties.party_id%TYPE,
                              p_n_person_number OUT NOCOPY hz_parties.party_number%TYPE
                              ) RETURN BOOLEAN ;

FUNCTION create_person_addr_record(p_n_person_id     IN  hz_parties.party_id%TYPE,
                                   p_v_person_number IN  hz_parties.party_number%TYPE,
                                   p_rec_resp_r1     IN  igf_sl_cl_resp_r1_all%ROWTYPE
                                  ) RETURN BOOLEAN ;

-- bvisvana - Bug # 4120082 - Telphone Number not created

FUNCTION create_person_telephone_record (p_n_person_id     IN  hz_parties.party_id%TYPE,
                                         p_rec_resp_r1     IN  igf_sl_cl_resp_r1_all%ROWTYPE
                                        ) RETURN BOOLEAN;

FUNCTION create_borrow_stud_rel ( p_n_borrower_id     IN  hz_parties.party_id%TYPE,
                                  p_v_borrower_number IN  hz_parties.party_number%TYPE,
                                  p_n_student_id      IN  hz_parties.party_id%TYPE,
                                  p_v_student_number  IN  hz_parties.party_number%TYPE
                                 ) RETURN BOOLEAN;

PROCEDURE raise_scr_event  ( p_rec_resp_r1        IN igf_sl_cl_resp_r1_all%ROWTYPE,
                             p_c_borrow_created   IN VARCHAR2,
                             p_c_student_created  IN VARCHAR2,
                             p_c_rel_created      IN VARCHAR2
                           );

PROCEDURE raise_gamt_event  ( p_v_ci_alternate_code   IN igs_ca_inst_all.alternate_code%TYPE,
                              p_d_ci_start_dt         IN igs_ca_inst_all.start_dt%TYPE,
                              p_d_ci_end_dt           IN igs_ca_inst_all.end_dt%TYPE,
                              p_v_person_number       IN hz_parties.party_number%TYPE,
                              p_v_person_name         IN hz_parties.party_name%TYPE,
                              p_v_ssn                 IN igf_ap_isir_ints_all.current_ssn_txt%TYPE,
                              p_v_loan_number         IN igf_sl_loans_all.loan_number%TYPE,
                              p_d_loan_per_begin_date IN igf_sl_loans_all.loan_per_begin_date%TYPE,
                              p_d_loan_per_end_date   IN igf_sl_loans_all.loan_per_end_date%TYPE,
                              p_v_loan_type           IN igf_aw_fund_cat_all.fed_fund_code%TYPE,
                              p_n_award_accept_amt    IN igf_aw_award_all.accepted_amt%TYPE,
                              p_n_guarantee_amt       IN igf_sl_cl_resp_r1_all.guarantee_amt%TYPE,
                              p_n_approved_amt        IN igf_sl_cl_resp_r1_all.alt_approved_amt%TYPE
                            );

PROCEDURE insert_into_resp_r2(p_r2_record   IN     igf_sl_cl_resp_r2_dtls%ROWTYPE);

PROCEDURE insert_into_resp_r3(p_r3_record   IN     igf_sl_cl_resp_r3_dtls%ROWTYPE);

PROCEDURE insert_into_resp_r7(p_r7_record   IN     igf_sl_cl_resp_r7_dtls%ROWTYPE);

PROCEDURE insert_into_resp_r6(p_r6_record   IN     igf_sl_clchrs_dtls%ROWTYPE);

PROCEDURE process_change_records (p_n_clrp1_id     IN  igf_sl_cl_resp_r1_all.clrp1_id%TYPE,
                                  p_v_loan_number  IN  igf_sl_loans_all.loan_number%TYPE);

PROCEDURE log_parameters ( p_v_param_typ IN VARCHAR2,
                           p_v_param_val IN VARCHAR2
                         ) ;

PROCEDURE cl_load_file
AS
 /***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/12/07
   Purpose          :    To Load the File Data and Verify if
                       Data Format is Supported
   Known Limitations,Enhancements or Remarks
   Change History   :
   Bug Id           : 1720677 Desc : Mapping of school id in the CommonLine Setup
                          to ope_id of  FinancialAid Office Setup.
   Who              When            What
   ugummall         21-OCT-2003     Removed one clause(selection based on school_id) from
                                    cur_Hrecord cursor.
   mesriniv         05-APR-2001    Changed the occurrences of field fao_id
                         to ope_id
 ***************************************************************/


     l_row_id                           VARCHAR2(25);
     Header_rec                         igf_sl_load_file_t%ROWTYPE;
     l_trailer                          VARCHAR2(2);
     l_log_msg                          VARCHAR2(100);
     l_file_creation_date               DATE;
     l_file_trans_date                  DATE;
     l_batch_id                         igf_sl_cl_batch_all.batch_id%TYPE;
     l_n_cbth_id                        NUMBER;

      -- To Fetch the Current School Id from Setup table

      -- cursor cur_school_id is removed from here as it selects ope_id from igf_ap_fa_setup table
      -- which is being obsoleted.

     -- To Fetch the @H records from Load file Table

     CURSOR cur_Hrecord ( p_file_type  igf_sl_load_file_t.file_type%TYPE,
                          p_record_data  igf_sl_load_file_t.record_data%TYPE)
        IS
        SELECT * FROM igf_sl_load_file_t
        WHERE file_type                               = p_file_type
        AND   LTRIM(RTRIM(SUBSTR(record_data,1,2)))   = p_record_data
        AND   lort_id                                 = 1
        ORDER By lort_id;

     -- To Fetch the Trailer Record from Load File Table

     CURSOR cur_Trecord ( p_file_type  igf_sl_load_file_t.file_type%TYPE,
                          p_record_data  igf_sl_load_file_t.record_data%TYPE)
      IS
      SELECT 'x' FROM igf_sl_load_file_t
      WHERE  lort_id = (SELECT MAX(lort_id) FROM igf_sl_load_file_t
                           WHERE file_type = p_file_type)
      AND   file_type                      = p_file_type
      AND   SUBSTR(record_data,1,2)        = p_record_data ;


     -- To Fetch the Batch Id Info from CL Batch Table

     CURSOR cur_batch( p_send_resp  igf_sl_cl_batch.send_resp%TYPE )IS
     SELECT clbatch.*, clbatch.ROWID row_id
     FROM  igf_sl_cl_batch_all clbatch
     WHERE RTRIM(batch_id)                   = g_loaded_batch_id
     AND   file_creation_date            = l_file_creation_date
     AND   file_ident_code               = g_loaded_file_ident_code
     AND   recipient_id                  = g_loaded_recipient_id
     AND   NVL(recip_non_ed_brc_id,'*')  = NVL(g_loaded_recip_non_ed_brc_id,'*')
     AND   source_id                     = g_file_source_id
     AND   NVL(source_non_ed_brc_id,'*') = NVL(g_file_source_non_ed_brc_id,'*')
     AND   send_resp                     = p_send_resp;

     rec_cur_batch  cur_batch%ROWTYPE;
BEGIN

     -- Fetch the Current School Id
     gv_debug_str := 'CL_LOAD_FILE - 1' ||' ';


     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 2' ||' ';

     -- Check if the Header record is present.
     OPEN cur_Hrecord('CL_ORIG_ACK','@H');
     FETCH cur_Hrecord INTO Header_rec;
     IF cur_Hrecord%NOTFOUND THEN
           CLOSE cur_Hrecord;
           fnd_message.set_name('IGF','IGF_SL_CL_INVALID_HEADER');
-- replace IGF_GE_INVALID_FILE with new one IGF_SL_CL_INVALID_HEADER
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           fnd_file.new_line(fnd_file.log,1);
           RAISE batch_exceptions;
     END IF;
     CLOSE cur_Hrecord;

     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 3' ||' ';

     -- Check if the Trailer Record is present.
     OPEN cur_Trecord('CL_ORIG_ACK','@T');
     FETCH cur_Trecord INTO l_trailer;
     IF cur_Trecord%NOTFOUND THEN
           CLOSE cur_Trecord;
           fnd_message.set_name('IGF','IGF_SL_CL_INVALID_TRAILER');
-- replace IGF_GE_FILE_NOT_COMPLETE with new one IGF_SL_CL_INVALID_TRAILER
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           fnd_file.new_line(fnd_file.log,1);
           RAISE batch_exceptions;
     END IF;
     CLOSE cur_Trecord;

     -- Check whether it is a Valid CommonLine Response File.
     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 4' ||' ';

     igf_sl_gen.get_cl_batch_details(
                      LTRIM(RTRIM(SUBSTR(header_rec.record_data,70,5))) ,   -- File_Ident_Code
                      LTRIM(RTRIM(SUBSTR(header_rec.record_data,51,19))),   -- File_Ident_Name
                      g_v_cl_version, p_cl_file_type);

     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 5' ||' ';


     IF  p_cl_file_type  = 'CL_ORIG_ACK' THEN
          NULL;
     ELSE
       gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 6' ||' ';
       fnd_message.set_name('IGF','IGF_SL_CL_INVALID_FILE_TYPE');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       fnd_file.new_line(fnd_file.log,1);
       RAISE batch_exceptions;
     END IF;

     IF g_v_cl_version NOT IN ('RELEASE-5','RELEASE-4') THEN
        fnd_message.set_name('IGF','IGF_SL_CL_INVALID_CL_VERSION');
        fnd_message.set_token('RESP_VER',g_v_cl_version);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        RAISE batch_exceptions;
     END IF;


     fnd_message.set_name('IGF','IGF_SL_CL_ORIG_ACK');
     fnd_file.put_line(fnd_file.log, fnd_message.get);

     g_loaded_batch_id            := LTRIM(RTRIM(SUBSTR(header_rec.record_data, 11,12)));
     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 7' ||' ';
     l_file_creation_date         := fnd_date.string_to_date(LTRIM(RTRIM(SUBSTR(Header_rec.record_data,23,14))),'YYYYMMDDHH24MISS');
     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 8' ||' ';
     l_file_trans_date            := fnd_date.string_to_date(LTRIM(RTRIM(SUBSTR(Header_rec.record_data,37,14))),'YYYYMMDDHH24MISS');
     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 8a' ||' ';
     g_loaded_file_ident_code     := LTRIM(RTRIM(SUBSTR(Header_rec.record_data,70,5)));
     g_loaded_recipient_id        := LTRIM(RTRIM(SUBSTR(header_rec.record_data,107,8)));
     g_loaded_recip_non_ed_brc_id := LTRIM(RTRIM(SUBSTR(header_rec.record_data,117,4)));
     g_file_source_id             := LTRIM(RTRIM(SUBSTR(header_rec.record_data,154,8)));
     g_file_source_non_ed_brc_id  := LTRIM(RTRIM(SUBSTR(header_rec.record_data,164,4)));
     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 8b' ||' ';
      -- To fetch the Batch Id satisfying the above values taken as substrings

     OPEN cur_batch('R');
     FETCH cur_batch INTO rec_cur_batch;
     IF cur_batch%NOTFOUND THEN
     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 9' ||' ';
        l_row_id  := NULL;
        igf_sl_cl_batch_pkg.insert_row (
                     x_mode                              => 'R',
                     x_rowid                             => l_row_id,
                     x_cbth_id                           => g_cbth_id, -- generated by sequence
                     x_batch_id                          => g_loaded_batch_id,
                     x_file_creation_date                => l_file_creation_date,
                     x_file_trans_date                   => l_file_trans_date,
                     x_file_ident_code                   => g_loaded_file_ident_code,
                     x_recipient_id                      => g_loaded_recipient_id,
                     x_recip_non_ed_brc_id               => g_loaded_recip_non_ed_brc_id,
                     x_source_id                         => g_file_source_id,
                     x_source_non_ed_brc_id              => g_file_source_non_ed_brc_id,
                     x_send_resp                         => 'R',
                     x_record_count_num                  =>  NULL                          ,
                     x_total_net_disb_amt                =>  NULL                          ,
                     x_total_net_eft_amt                 =>  NULL                          ,
                     x_total_net_non_eft_amt             =>  NULL                          ,
                     x_total_reissue_amt                 =>  NULL                          ,
                     x_total_cancel_amt                  =>  NULL                          ,
                     x_total_deficit_amt                 =>  NULL                          ,
                     x_total_net_cancel_amt              =>  NULL                          ,
                     x_total_net_out_cancel_amt          =>  NULL
                          );

     ELSE
     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 9 Upd' ||' ';
     --
     -- update the batch record with new information
     --
        l_n_cbth_id  := rec_cur_batch.cbth_id;
        l_row_id     := rec_cur_batch.row_id ;
        l_batch_id   := rec_cur_batch.batch_id;
        g_cbth_id := l_n_cbth_id;
        igf_sl_cl_batch_pkg.update_row (
          x_mode                              =>  'R',
          x_rowid                             =>  l_row_id,
          x_cbth_id                           =>  l_n_cbth_id,
          x_batch_id                          =>  g_loaded_batch_id,
          x_file_creation_date                =>  l_file_creation_date,
          x_file_trans_date                   =>  l_file_trans_date,
          x_file_ident_code                   =>  g_loaded_file_ident_code,
          x_recipient_id                      =>  g_loaded_recipient_id,
          x_recip_non_ed_brc_id               =>  g_loaded_recip_non_ed_brc_id,
          x_source_id                         =>  g_file_source_id,
          x_source_non_ed_brc_id              =>  g_file_source_non_ed_brc_id,
          x_send_resp                         =>  'R',
          x_record_count_num                  =>  rec_cur_batch.record_count_num      ,
          x_total_net_disb_amt                =>  rec_cur_batch.total_net_disb_amt    ,
          x_total_net_eft_amt                 =>  rec_cur_batch.total_net_eft_amt     ,
          x_total_net_non_eft_amt             =>  rec_cur_batch.total_net_non_eft_amt ,
          x_total_reissue_amt                 =>  rec_cur_batch.total_reissue_amt     ,
          x_total_cancel_amt                  =>  rec_cur_batch.total_cancel_amt      ,
          x_total_deficit_amt                 =>  rec_cur_batch.total_deficit_amt     ,
          x_total_net_cancel_amt              =>  rec_cur_batch.total_net_cancel_amt  ,
          x_total_net_out_cancel_amt          =>  rec_cur_batch.total_net_out_cancel_amt
        );

     END IF;
     CLOSE cur_batch;

     fnd_file.new_line(fnd_file.log,1);

     -- Call Procedure to Process all the Transaction Records

     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 10' ||' ';
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.cl_load_file.debug',gv_debug_str);
     END IF;
     gv_debug_str := '';
     process_1_records;
     gv_debug_str := gv_debug_str || 'CL_LOAD_FILE - 11' ||' ';


EXCEPTION

 WHEN batch_exceptions THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.cl_load_file.debug',gv_debug_str);
      END IF;
      RAISE;
 WHEN app_exception.record_lock_exception THEN
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.cl_load_file.debug',gv_debug_str || ' Lock ');
     END IF;
     RAISE;
 WHEN OTHERS THEN

     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_CL_ORIG_ACK.CL_LOAD_FILE');
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.cl_load_file.exception',gv_debug_str||' '|| SQLERRM);
     END IF;
     gv_debug_str := '';
     igs_ge_msg_stack.add;
     app_exception.raise_exception;

END cl_load_file;



PROCEDURE  process_1_records
AS
/***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/12/07
   Purpose          :    To Call Respective procedures which
                    will insert the format file(@1 and @8) data into
                    the tables IGF_SL_CL_RESP_R1 and IGF_SL_CL_RESP_R8
                    tables correspondingly.
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who              When      What
 ***************************************************************/

  l_loan_active                   igf_sl_loans_all.active%TYPE;
  l_resp_record_status            igf_sl_cl_resp_r1_all.resp_record_status%TYPE;

  -- To select all the @1 Records from the Load Table
  CURSOR cur_1records (p_file_type  igf_sl_load_file_t.file_type%TYPE,
                          p_record_data  igf_sl_load_file_t.record_data%TYPE)
  IS
  SELECT * FROM   igf_sl_load_file_t
  WHERE  SUBSTR(record_data,1,2)= p_record_data
      AND    file_type= p_file_type
      ORDER  BY lort_id;

   CURSOR  c_loan IS
   SELECT  active
          ,loan_id
          ,award_id
   FROM   igf_sl_loans_all
   WHERE  NVL(external_loan_id_txt,loan_number) = l_loan_number;

   rec_c_loan c_loan%ROWTYPE;

  CURSOR c_igf_sl_lor (cp_v_loan_number igf_sl_loans_all.loan_number%TYPE) IS
  SELECT lor.rec_type_ind
  FROM   igf_sl_lor_all lor,
         igf_sl_loans_all loan
  WHERE  loan.loan_id     = lor.loan_id   AND
         NVL(loan.external_loan_id_txt,loan.loan_number) = cp_v_loan_number;

  rec_c_igf_sl_lor c_igf_sl_lor%ROWTYPE;

-- bug# 5045781
  CURSOR  c_igf_aw_award_v (cp_n_award_id igf_aw_award_all.award_id%TYPE) IS
    SELECT fmast.ci_cal_type ci_cal_type,
           fmast.ci_sequence_number ci_sequence_number,
           ci.alternate_code ci_alternate_code,
           ci.start_dt ci_start_dt,
           ci.end_dt ci_end_dt,
           fcat.fed_fund_code fed_fund_code,
           fcat.sys_fund_type sys_fund_type,
           facon.person_id person_id,
           pe.party_number person_number,
           pit.api_person_id ssn,
           pe.person_last_name || ',' || pe.person_first_name full_name,
           awd.accepted_amt accepted_amt
      FROM igf_aw_award_all awd,
           igf_aw_fund_mast_all fmast,
           igf_aw_fund_cat_all fcat,
           igs_ca_inst ci,
           igf_ap_fa_base_rec facon,
           (SELECT api_person_id,
                   pe_person_id
              FROM igs_pe_person_id_typ pit_2,
                   igs_pe_alt_pers_id api_2
             WHERE api_2.person_id_type = pit_2.person_id_type
               AND pit_2.s_person_id_type = 'SSN'
               AND SYSDATE BETWEEN api_2.start_dt AND NVL (api_2.end_dt,SYSDATE)) pit,
           hz_parties pe
     WHERE fmast.fund_code = fcat.fund_code
       AND fmast.ci_cal_type = ci.cal_type
       AND fmast.ci_sequence_number = ci.sequence_number
       AND awd.base_id = facon.base_id
       AND pe.party_id = facon.person_id
       AND pe.party_id = pit.pe_person_id(+)
       AND fmast.fund_id = awd.fund_id
       AND awd.award_id = cp_n_award_id;


  rec_c_igf_aw_award_v  c_igf_aw_award_v%ROWTYPE;

  l_v_cl_file_type              igf_sl_cl_file_type.cl_file_type%TYPE;
  e_skip                        EXCEPTION;
  rec_scr_sl_resp               igf_sl_cl_resp_r1_all%ROWTYPE;
  l_v_rec_type_ind              igf_sl_lor_all.rec_type_ind%TYPE;
  l_n_award_id                  igf_aw_award_all.award_id%TYPE;
  l_n_resp_guarantee_amt        igf_sl_cl_resp_r1_all.guarantee_amt%TYPE;
  l_n_resp_fls_approved_amt     igf_sl_cl_resp_r1_all.fls_approved_amt%TYPE;
  l_n_resp_flu_approved_amt     igf_sl_cl_resp_r1_all.flu_approved_amt%TYPE;
  l_n_resp_flp_approved_amt     igf_sl_cl_resp_r1_all.flp_approved_amt%TYPE;
  l_n_resp_alt_approved_amt     igf_sl_cl_resp_r1_all.alt_approved_amt%TYPE;
  l_n_resp_actual_approved_amt  igf_sl_cl_resp_r1_all.alt_approved_amt%TYPE;
  l_d_loan_per_begin_date       igf_sl_cl_resp_r1_all.loan_per_begin_date%TYPE;
  l_d_loan_per_end_date         igf_sl_cl_resp_r1_all.loan_per_end_date%TYPE;
  lv_resp_prc_type              VARCHAR2(30);
  lv_resp_rec_type              VARCHAR2(30);
  lv_sys_loan_version           VARCHAR2(30);
  lv_fed_appl_form_code         VARCHAR2(30);
  lv_loan_type                  VARCHAR2(30);
BEGIN
  --
  -- Important :
  -- As the records like @8 etc follow the @1 record, and as @8 records
  -- do not have the Loan Number to indicate that they belong to this Loan-Number,
  -- We need to process so as to upload @8 records following @1 are for this
  -- Loan Number, until the Next @1 record is encountered.
  --
  OPEN cur_1records('CL_ORIG_ACK','@1');
  LOOP
    BEGIN
      gv_debug_str := 'PROCESS_1_RECORDS - 1'  ||' ';
      FETCH cur_1records INTO Format_1_rec_temp;
      Format_1_rec := Format_1_rec_temp;
      IF cur_1records%NOTFOUND THEN
        EXIT;
      END IF;
      l_loan_number    := NULL;
      lv_resp_prc_type := NULL;
      lv_resp_rec_type := NULL;
--MN 20-Dec-2004 11:57:05 - Initialize the flag in loop instead of outside the loop.
--This will be used for later processing of Successful r1 records.
      l_resp_record_status := 'N';

      l_loan_number    := SUBSTR(Format_1_rec.record_data,208,17);
      lv_resp_rec_type := LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,3,1)));
      lv_resp_prc_type := LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,962,2)));

      gv_debug_str     := gv_debug_str || 'PROCESS_1_RECORDS - 2' ||' ';
      l_loan_active    := NULL;

      fnd_file.new_line(fnd_file.log,1);
      fnd_file.put(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PROCESSING'),40));
      fnd_file.new_line(fnd_file.log,1);

      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','CL_VERSION'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CL_VERSION',g_v_cl_version)
                     );
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_NUMBER'),40),
                       p_v_param_val => l_loan_number
                     );
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_CL_CHANGE_FIELDS','AWARD_AMOUNT'),40),
                       p_v_param_val => LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,190,6)))
                     );
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_CL_ROSTER_LOGS','RECORD_TYPE'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CL4_REC_ST_CODES',lv_resp_rec_type)
                     );
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PROCESSING_TYPE'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_PRC_TYPE_CODE',lv_resp_prc_type)
                     );
      IF g_v_cl_version  = 'RELEASE-5' THEN
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','GUARNT_STATUS_CODE'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_GUARNT_STATUS',LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,992,2))))
                     );
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LEND_STATUS_CODE'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_LEND_STATUS',LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,994,2))))
                     );
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','PNOTE_STATUS'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_PNOTE_STATUS',LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,996,2))))
                     );
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','CREDIT_OVERRIDE'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CREDIT_OVERRIDE',LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,998,2))))
                     );
      ELSIF g_v_cl_version  = 'RELEASE-4' THEN
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','CL_REC_STATUS'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CL4_REC_ST_CODES',lv_resp_rec_type)
                     );
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','APPL_LOAN_PHASE_CODE'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CL_APP_PHASE_CODES',LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,864,4))))
                     );
      END IF;
      -- new message
      -- if processing type is not CR then only check for loan existing in system
      --
      fnd_file.new_line(fnd_file.log,2);
      OPEN  c_loan;
      FETCH c_loan INTO rec_c_loan;
      l_loan_active := rec_c_loan.active;
      l_n_award_id  := rec_c_loan.award_id;
      IF c_loan%NOTFOUND THEN
        l_n_award_id := -1;
        CLOSE c_loan;
        l_resp_record_status := 'I';
        --
        -- Loan Number not found in the System
        --
        fnd_file.new_line(fnd_file.log,1);
        fnd_message.set_name('IGF','IGF_SL_CL_INS_RESP_REC');
        fnd_message.set_token('LOAN_NUMBER', l_loan_number);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - 3' ||' ';
        fnd_message.set_name('IGF','IGF_SL_NO_LOAN_NUMBER');
        fnd_message.set_token('LOAN_NUMBER',l_loan_number);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.new_line(fnd_file.log,1);
        log_to_fnd(p_v_module => 'process_1_records',
                   p_v_string => ' Loan number '||l_loan_number||' not found in the system '||
                                 ' Processing Type ' ||igf_aw_gen.lookup_desc('IGF_SL_PRC_TYPE_CODE',lv_resp_prc_type)
                  );
        IF  lv_resp_prc_type <> 'CR' THEN
          RAISE e_skip;
        END IF;
      END IF;
      IF c_loan%ISOPEN THEN
        CLOSE c_loan;
      END IF;

      IF g_v_cl_version IN ('RELEASE-5','RELEASE-4') THEN
        lv_sys_loan_version := '-1';
        lv_sys_loan_version := igf_sl_award.get_loan_cl_version(p_n_award_id => l_n_award_id);
        IF lv_sys_loan_version <> g_v_cl_version THEN
          l_resp_record_status := 'M';
          fnd_message.set_name('IGF','IGF_SL_CL_DIFF_VERSION_PRC');
          fnd_message.set_token('RESP_VER',g_v_cl_version);
          fnd_message.set_token('SYS_LOAN_VER',lv_sys_loan_version);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          RAISE e_skip;
        END IF;
      END IF;

      gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - 4' ||' ';

      IF l_loan_active = 'N' THEN
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - 7' ||' ';
        l_resp_record_status := 'I'; -- inactive loan
        fnd_message.set_name('IGF','IGF_SL_CL_LOAN_INACTIVE');
        fnd_message.set_token('LOAN_NUMBER',l_loan_number);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        RAISE e_skip;
      END IF;

      IF lv_resp_prc_type NOT IN ('GP','CR','GO') THEN
        l_resp_record_status := 'IP';
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - 4 invalid prc type' ||' ';
        fnd_message.set_name('IGF','IGF_SL_CL_RESP_INVLID_PRC');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        RAISE e_skip;
      END IF;

      -- bvisvana - FA 161 - Bug # 5006583
      lv_fed_appl_form_code := LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,510,1)));
      lv_loan_type          := LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,188,2)));
      IF ((lv_loan_type = 'PL' AND NVL(lv_fed_appl_form_code,'*') <> 'Q') OR
          (lv_loan_type IN ('CS','SF','SU') AND NVL(lv_fed_appl_form_code,'*') <> 'M') OR
          (lv_loan_type = 'AL' AND lv_fed_appl_form_code IS NOT NULL) OR
	  (lv_loan_type = 'GB' AND NVL(lv_fed_appl_form_code,'*') <> 'G')
         ) THEN
        l_resp_record_status := 'IA';
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - invalid fed appl form code' ||' ';
        fnd_file.put_line(fnd_file.log, igf_aw_gen.lookup_desc('IGF_SL_CL_ACK_REC_STATUS','IA'));
        RAISE e_skip;
      END IF;

      OPEN  c_igf_sl_lor (cp_v_loan_number => l_loan_number);
      FETCH c_igf_sl_lor  INTO rec_c_igf_sl_lor;
      CLOSE c_igf_sl_lor;

      l_v_rec_type_ind := rec_c_igf_sl_lor.rec_type_ind;
      gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - 4 send rec type ' ||l_v_rec_type_ind ||' ';
      log_to_fnd(p_v_module => 'process_1_records',
                 p_v_string => 'cl_version       : '||g_v_cl_version ||
                               'Send Record Type : '||l_v_rec_type_ind
                );
      gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - after 4 send rec type ';
      -- The response record processing is limited to following Record Types -
      -- Release 5 -
      -- M = Modification responses after the first notification of guarantee
      -- N = Response to reprint request
      -- R = Change Transaction Send response
      -- S = Application responses up to and including the first notification of guarantee and pre-approval credit request responses
      IF g_v_cl_version = 'RELEASE-4' THEN

        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - cl version is 4 lv_resp_rec_type - ' || lv_resp_rec_type
                        || ' - lv_resp_prc_type - ' || lv_resp_prc_type || ' ';
        IF lv_resp_rec_type NOT IN ('A','I','G','B','P','D','C','M','N','R','T') THEN
          l_resp_record_status := 'IR';
          fnd_message.set_name('IGF','IGF_SL_CL_RESP_INVLID_PRC');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          RAISE e_skip;
        END IF;

        IF lv_resp_prc_type IN ('GP','GO') THEN
          --
          -- do these checks only if this field is record type, for status values
          -- these checks would not be done
          --
          IF lv_resp_rec_type IN ('C','M','N','R','T') THEN
            IF lv_resp_prc_type = 'GP' THEN
              IF ((l_v_rec_type_ind = 'R' AND lv_resp_rec_type <> 'N') OR
                  (l_v_rec_type_ind <> 'R' AND lv_resp_rec_type = 'N')
                   )THEN
                l_resp_record_status := 'IC';
                fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
                fnd_file.put_line(fnd_file.log, fnd_message.get);
                RAISE e_skip;
              END IF;
            END IF;
            gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - not reprint ';
            IF l_v_rec_type_ind IN ('A','C') AND
               lv_resp_rec_type NOT IN ('R','M') THEN
              l_resp_record_status := 'IC';
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              RAISE e_skip;
            END IF;
            gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - not M,R ';
            IF l_v_rec_type_ind NOT IN ('A','C') AND
               lv_resp_rec_type IN ('R','M') THEN
              l_resp_record_status := 'IC';
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              RAISE e_skip;
            END IF;
            gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - not A,C ';
            IF l_v_rec_type_ind = 'T' AND
               lv_resp_rec_type <> 'T' THEN
              l_resp_record_status := 'IC';
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              RAISE e_skip;
            END IF;
            gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - not T ';
            IF l_v_rec_type_ind <> 'T' AND
               lv_resp_rec_type = 'T' THEN
              l_resp_record_status := 'IC';
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              RAISE e_skip;
            END IF;
          END IF; -- rec type values
        END IF; -- GO,GP

      ELSIF g_v_cl_version = 'RELEASE-5' THEN
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - Release 5 not T ';
        IF lv_resp_rec_type NOT IN ('M','N','R','S','C') THEN
          l_resp_record_status := 'IR';
          fnd_message.set_name('IGF','IGF_SL_CL_RESP_INVLID_PRC');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          RAISE e_skip;
        END IF;
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - Release 5 1 ';
        IF lv_resp_prc_type IN ('GP','GO') THEN
          IF lv_resp_prc_type = 'GP' THEN
            IF ((l_v_rec_type_ind = 'R' AND lv_resp_rec_type <> 'N') OR
                (l_v_rec_type_ind <> 'R' AND lv_resp_rec_type = 'N')
                 )THEN
              l_resp_record_status := 'IC';
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              RAISE e_skip;
            END IF;
          END IF;
          gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - Release 5 2 ';
          IF l_v_rec_type_ind IN ('A','C','T') AND
             lv_resp_rec_type NOT IN ('S','R','M') THEN
            l_resp_record_status := 'IC';
            fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            RAISE e_skip;
          END IF;
          gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - Release 5 3 ';
          IF l_v_rec_type_ind NOT IN ('A','C','T') AND
             lv_resp_rec_type IN ('S','R','M') THEN
            l_resp_record_status := 'IC';
            fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            RAISE e_skip;
          END IF;
          gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - Release 5 4 ';
          IF l_v_rec_type_ind = 'T' AND
             lv_resp_rec_type <> 'S' THEN
            l_resp_record_status := 'IC';
            fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            RAISE e_skip;
          END IF;
          --Bug 4093687 UNABLE TO UPLOAD ORIGINATION ACKNOWLEGMENT FOR CL5
          gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - Release 5 5 ';
          /*IF l_v_rec_type_ind <> 'T' AND
             lv_resp_rec_type = 'S' THEN
            l_resp_record_status := 'IC';
            fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            RAISE e_skip;
          END IF;
          */
          gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - Release 5 6 ';
        END IF;
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - Release 5 7 ';
      END IF;

      -- Person Records for Borrower and Student would be created and
      -- relation based on the information that is contained in the School Certification Request
      IF l_n_award_id = -1  AND lv_resp_prc_type = 'CR' THEN
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - CR Processing 1 ';
        log_to_fnd(p_v_module => 'process_1_records',
                   p_v_string => ' School Certification Request information'
                  );
        rec_scr_sl_resp.b_last_name             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,12,35)));
        rec_scr_sl_resp.b_first_name            :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,47,12)));
        rec_scr_sl_resp.b_middle_name           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,59,1)));
        rec_scr_sl_resp.b_ssn                   :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,60,9))));
        rec_scr_sl_resp.b_permt_addr1           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,69,30)));
        rec_scr_sl_resp.b_permt_addr2           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,99,30)));
        rec_scr_sl_resp.b_permt_city            :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,129,24)));
        rec_scr_sl_resp.b_permt_state           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,159,2)));
        rec_scr_sl_resp.b_permt_zip             :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,161,5))));
        rec_scr_sl_resp.b_permt_zip_suffix      :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,166,4))));
        rec_scr_sl_resp.b_permt_phone           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,170,10)));
        rec_scr_sl_resp.b_date_of_birth         :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,180,8),'YYYYMMDD');
        rec_scr_sl_resp.cl_loan_type            :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,188,2)));
        rec_scr_sl_resp.req_loan_amt            :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,190,6))));
        rec_scr_sl_resp.defer_req_code          :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,196,1)));
        rec_scr_sl_resp.borw_interest_ind       :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,197,1)));
        rec_scr_sl_resp.eft_auth_code           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,198,1)));
        rec_scr_sl_resp.b_signature_code        :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,199,1)));
        rec_scr_sl_resp.b_signature_date        :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,200,8),'YYYYMMDD');
        rec_scr_sl_resp.loan_number             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,208,17)));
        rec_scr_sl_resp.b_citizenship_status    :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,228,1)));
        rec_scr_sl_resp.b_state_of_legal_res    :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,229,2)));
        rec_scr_sl_resp.b_legal_res_date        :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,231,6)||'01','YYYYMMDD');
        rec_scr_sl_resp.b_default_status        :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,237,1)));
        rec_scr_sl_resp.b_outstd_loan_code      :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,238,1)));
        rec_scr_sl_resp.b_indicator_code        :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,239,1)));
        rec_scr_sl_resp.s_last_name             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,259,35)));
        rec_scr_sl_resp.s_first_name            :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,294,12)));
        rec_scr_sl_resp.s_middle_name           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,306,1)));
        rec_scr_sl_resp.s_ssn                   :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,307,9))));
        rec_scr_sl_resp.s_date_of_birth         :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,316,8),'YYYYMMDD');
        rec_scr_sl_resp.s_citizenship_status    :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,324,1)));
        rec_scr_sl_resp.s_default_code          :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,325,1)));
        rec_scr_sl_resp.s_signature_code        :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,326,1)));
        rec_scr_sl_resp.school_id               :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,347,8))));
        rec_scr_sl_resp.loan_per_begin_date     :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,357,8),'YYYYMMDD');
        rec_scr_sl_resp.loan_per_end_date       :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,365,8),'YYYYMMDD');
        rec_scr_sl_resp.alt_appl_ver_code       :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,443,4))));
        rec_scr_sl_resp.lender_id               :=  SUBSTR(Format_1_rec.record_data,458,6);
        rec_scr_sl_resp.guarantor_id            :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,507,3)));
        rec_scr_sl_resp.fed_appl_form_code      :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,510,1)));
        rec_scr_sl_resp.b_license_state         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,715,2)));
        rec_scr_sl_resp.b_license_number        :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,717,20)));
        rec_scr_sl_resp.b_ref_code              :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,737,1)));
        rec_scr_sl_resp.pnote_delivery_code     :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,765,1)));
        rec_scr_sl_resp.b_foreign_postal_code   :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,766,14)));
        rec_scr_sl_resp.lend_non_ed_brc_id      :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,781,4)));
        rec_scr_sl_resp.lender_use_txt          :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,785,20)));
        rec_scr_sl_resp.guarantor_use_txt       :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,876,23)));
        rec_scr_sl_resp.b_permt_addr_chg_date   :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,899,8),'YYYYMMDD');
        rec_scr_sl_resp.alt_prog_type_code      :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,907,3)));
        rec_scr_sl_resp.prc_type_code           :=  lv_resp_prc_type;
        -- bvisvana - FA 161 - Bug # 5006583
        rec_scr_sl_resp.esign_src_typ_cd             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,449,9)));
        rec_scr_sl_resp.b_alien_reg_num_txt          :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,240,19)));

        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - CR Processing 2 ';
        IF g_v_cl_version = 'RELEASE-4' THEN
          gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - CR Processing Release 4 3';
          rec_scr_sl_resp.mpn_confirm_ind         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,694,1)));
          rec_scr_sl_resp.guarnt_status_code      :=  NULL;
          rec_scr_sl_resp.lender_status_code      :=  NULL;
          rec_scr_sl_resp.pnote_status_code       :=  NULL;
          rec_scr_sl_resp.credit_status_code      :=  NULL;
          rec_scr_sl_resp.guarnt_status_date      :=  NULL;
          rec_scr_sl_resp.lender_status_date      :=  NULL;
          rec_scr_sl_resp.pnote_status_date       :=  NULL;
          rec_scr_sl_resp.credit_status_date      :=  NULL;
          rec_scr_sl_resp.act_serial_loan_code    :=  NULL;
          rec_scr_sl_resp.sch_non_ed_brc_id       :=  NULL;
          rec_scr_sl_resp.borr_credit_auth_code   :=  NULL;
          rec_scr_sl_resp.borr_sign_ind           :=  NULL;
          rec_scr_sl_resp.stud_sign_ind           :=  NULL;
          gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - CR Processing Release 4 4';
        ELSIF g_v_cl_version = 'RELEASE-5' THEN
          gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - CR Processing Release 5 5';
          rec_scr_sl_resp.guarnt_status_code      :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,992,2)));
          rec_scr_sl_resp.lender_status_code      :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,994,2)));
          rec_scr_sl_resp.pnote_status_code       :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,996,2)));
          rec_scr_sl_resp.credit_status_code      :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,998,2)));
          rec_scr_sl_resp.guarnt_status_date      :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,1000,14),'YYYYMMDDHH24MISS');
          rec_scr_sl_resp.lender_status_date      :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,1014,14),'YYYYMMDDHH24MISS');
          rec_scr_sl_resp.pnote_status_date       :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,1028,14),'YYYYMMDDHH24MISS');
          rec_scr_sl_resp.credit_status_date      :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,1042,14),'YYYYMMDDHH24MISS');
          rec_scr_sl_resp.act_serial_loan_code    :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,1056,1)));
          rec_scr_sl_resp.sch_non_ed_brc_id       :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,1090,4)));
          rec_scr_sl_resp.mpn_confirm_ind         :=  NULL;
          rec_scr_sl_resp.borr_credit_auth_code   :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,227,1)));
          rec_scr_sl_resp.borr_sign_ind           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,374,1)));
          rec_scr_sl_resp.stud_sign_ind           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,780,1)));
          gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - CR Processing Release 5 6';
        END IF;
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - CR Processing 7';
        -- invoke the procedure process_borrow_stud_rec to process borrower and student data in the response record
        log_to_fnd(p_v_module => 'process_1_records',
                   p_v_string => ' School Certification Request information - processing borrower student data'
                  );
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - CR Processing 8';
        process_borrow_stud_rec (p_rec_resp_r1   => rec_scr_sl_resp);
        fnd_file.new_line(fnd_file.log,1);
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - CR Processing 9';
        log_to_fnd(p_v_module => 'process_1_records',
                   p_v_string => ' School Certification Request information - processed borrower student data'
                  );
        gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - CR Processing 10';
      END IF; -- end if for CR
      --If the Response Guarantee Amount is different, it is possible that
      --the Response Disbursement Details also are different from system
      --If the Response Guarantee Amount is different from award accepted amount
      --raise the business event
      IF l_n_award_id <> -1 THEN

        --
        -- Raise this event only for final statuses
        --
        IF ( g_v_cl_version = 'RELEASE-4' AND lv_resp_rec_type IN ('B','G','D','P') ) OR  --MN 11-Jan-2005 earlier it was with l_v_rec_type_ind
           ( g_v_cl_version = 'RELEASE-5' AND TRIM(SUBSTR(Format_1_rec.record_data,992,2)) IN ('40', '30', '25') )
        THEN

          OPEN  c_igf_aw_award_v (cp_n_award_id => l_n_award_id);
          FETCH c_igf_aw_award_v INTO rec_c_igf_aw_award_v ;
          CLOSE c_igf_aw_award_v;
          gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - GaMt Diff 1';
          l_n_resp_guarantee_amt   := TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,688,5))));
          l_n_resp_fls_approved_amt    :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,464,5))));
          l_n_resp_flu_approved_amt    :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,469,5))));
          l_n_resp_flp_approved_amt    :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,474,5))));
          l_n_resp_alt_approved_amt    :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,488,5))));
          l_d_loan_per_begin_date  := fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,357,8),'YYYYMMDD');
          l_d_loan_per_end_date    := fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,365,8),'YYYYMMDD');
          --MN 11-Jan-2005 Get Actual Approved Amount based on fed und code and validate that against the Award Accepted Amount
          IF    NVL(rec_c_igf_aw_award_v.fed_fund_code, '*') = 'FLS' THEN
              l_n_resp_actual_approved_amt := l_n_resp_fls_approved_amt;
          ELSIF NVL(rec_c_igf_aw_award_v.fed_fund_code, '*') = 'FLU' THEN
              l_n_resp_actual_approved_amt := l_n_resp_flu_approved_amt;
          ELSIF NVL(rec_c_igf_aw_award_v.fed_fund_code, '*') IN ('FLP','GPLUSFL') THEN
              l_n_resp_actual_approved_amt := l_n_resp_flp_approved_amt;
          ELSIF NVL(rec_c_igf_aw_award_v.fed_fund_code, '*') = 'ALT' THEN
              l_n_resp_actual_approved_amt := l_n_resp_alt_approved_amt;
          END IF;

          IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.process_1_records.AmountComparison',
                              '|Fed Fund Type     - ' || NVL(rec_c_igf_aw_award_v.fed_fund_code, '*') ||
                              '|Guaranteed Amount - ' || l_n_resp_guarantee_amt ||
                              '|Approved Amount   - ' || l_n_resp_actual_approved_amt ||
                              '|Accepted Amount   - ' || rec_c_igf_aw_award_v.accepted_amt ||
                              '|g_v_cl_version    - ' || g_v_cl_version ||
                              '|l_v_rec_type_ind  - ' || l_v_rec_type_ind);
          END IF;
          gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - GaMt Diff 2';
          IF  NVL(l_n_resp_guarantee_amt,0) <> NVL(rec_c_igf_aw_award_v.accepted_amt,0) OR
              NVL(l_n_resp_actual_approved_amt, 0) <> NVL(rec_c_igf_aw_award_v.accepted_amt,0)
          THEN
            gv_debug_str := gv_debug_str || 'PROCESS_1_RECORDS - GaMt Diff 3';
            raise_gamt_event (
              p_v_ci_alternate_code   => rec_c_igf_aw_award_v.ci_alternate_code,
              p_d_ci_start_dt         => rec_c_igf_aw_award_v.ci_start_dt,
              p_d_ci_end_dt           => rec_c_igf_aw_award_v.ci_end_dt,
              p_v_person_number       => rec_c_igf_aw_award_v.person_number,
              p_v_person_name         => rec_c_igf_aw_award_v.full_name,
              p_v_ssn                 => rec_c_igf_aw_award_v.ssn,
              p_v_loan_number         => l_loan_number,
              p_d_loan_per_begin_date => l_d_loan_per_begin_date,
              p_d_loan_per_end_date   => l_d_loan_per_end_date,
              p_v_loan_type           => rec_c_igf_aw_award_v.fed_fund_code,
              p_n_award_accept_amt    => rec_c_igf_aw_award_v.accepted_amt,
              p_n_guarantee_amt       => l_n_resp_guarantee_amt,
              p_n_approved_amt        => l_n_resp_actual_approved_amt
            );
          END IF;
        END IF;
      END IF;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.process_1_records.debug',gv_debug_str);
      END IF;
      gv_debug_str := '';
      insert_into_resp1(l_loan_number, l_resp_record_status, l_v_rec_type_ind);
    EXCEPTION
      WHEN e_skip THEN
        insert_into_resp1(l_loan_number, l_resp_record_status, l_v_rec_type_ind);
    END ;
  END LOOP;
  CLOSE cur_1records; -- Finish inserting all the @1 and @8 Records into Resp1 and Resp2 Tables correspondingly.

EXCEPTION
 WHEN app_exception.record_lock_exception THEN
     RAISE;
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_CL_ACK.PROCESS_1_RECORDS');
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.process_1_records.exception',gv_debug_str||' '||SQLERRM);
     END IF;
     gv_debug_str := '';
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
END process_1_records;


/* Inserts Data into Resp1 ,Resp4 and Resp8 Tables*/

PROCEDURE insert_into_resp1(p_loan_number          igf_sl_loans_all.loan_number%TYPE,
                            p_resp_record_status   igf_sl_cl_resp_r1_all.resp_record_status%TYPE,
                            p_rec_type_ind         igf_sl_cl_resp_r1_all.rec_type_ind%TYPE)
AS
/***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/12/07
   Purpose          :    To Insert File data into IGF_SL_CL_RESP_R1
                    and IGF_SL_CL_RESP_R8 tables
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who              When      What
   masehgal             17-Feb-2002     # 2216956    FACR007
                                        Added borr_sign_ind , Stud_sign_ind to TBH call for insert
 ***************************************************************/


l_ind               NUMBER;
l_clrp1_id          igf_sl_cl_resp_r1_all.clrp1_id%TYPE;
l_row_id            VARCHAR2(25);
l_start_guar_pos    NUMBER;
l_start_orig_pos    NUMBER;


 --Select all the Records which are not @1 Records but @8 Records.

 CURSOR cur_other_records  ( p_file_type  igf_sl_load_file_t.file_type%TYPE)
 IS
   SELECT * FROM igf_sl_load_file_t
   WHERE  file_type  = p_file_type
   AND lort_id       > Format_1_rec.lort_id;

  TYPE r8_rec_type IS RECORD (
        clrp8_id                 igf_sl_cl_resp_r8_all.clrp8_id%TYPE,
        disb_date                igf_sl_cl_resp_r8_all.disb_date%TYPE,
        disb_gross_amt           igf_sl_cl_resp_r8_all.disb_gross_amt%TYPE,
        orig_fee                 igf_sl_cl_resp_r8_all.orig_fee%TYPE,
        guarantee_fee            igf_sl_cl_resp_r8_all.guarantee_fee%TYPE,
        net_disb_amt             igf_sl_cl_resp_r8_all.net_disb_amt%TYPE,
        disb_hold_rel_ind        igf_sl_cl_resp_r8_all.disb_hold_rel_ind%TYPE,
        disb_status              igf_sl_cl_resp_r8_all.disb_status%TYPE,
        guarnt_fee_paid          igf_sl_cl_resp_r8_all.guarnt_fee_paid%TYPE,
        orig_fee_paid            igf_sl_cl_resp_r8_all.orig_fee_paid%TYPE,
        layout_owner_code_txt    igf_sl_cl_resp_r8_all.layout_owner_code_txt%TYPE,
        layout_version_code_txt  igf_sl_cl_resp_r8_all.layout_version_code_txt%TYPE,
        record_code_txt          igf_sl_cl_resp_r8_all.record_code_txt%TYPE,
--	direct_to_borr_flag      igf_sl_cl_resp_r8_all.direct_to_borr_flag%TYPE --akomurav changes according to FA163 TD
	direct_to_borr_flag      igf_sl_cl_resp_r8_all.layout_version_code_txt%TYPE --temporarily stubbed out
     );

  r8_rec  r8_rec_type;

  TYPE r8_tab_type IS TABLE OF r8_rec%TYPE INDEX BY BINARY_INTEGER;
  r8_tab       r8_tab_type;

  rec_cl_resp_r1         igf_sl_cl_resp_r1_all%ROWTYPE;

  TYPE tab_resp_r2 IS TABLE OF igf_sl_cl_resp_r2_dtls%ROWTYPE INDEX BY BINARY_INTEGER;
  v_tab_resp_r2   tab_resp_r2;
  TYPE tab_resp_r3 IS TABLE OF igf_sl_cl_resp_r3_dtls%ROWTYPE INDEX BY BINARY_INTEGER;
  v_tab_resp_r3   tab_resp_r3;
  TYPE tab_resp_r7 IS TABLE OF igf_sl_cl_resp_r7_dtls%ROWTYPE INDEX BY BINARY_INTEGER;
  v_tab_resp_r7   tab_resp_r7;
  TYPE tab_clchrs_dtls IS TABLE OF igf_sl_clchrs_dtls%ROWTYPE INDEX BY BINARY_INTEGER;
  v_tab_clchrs_dtls   tab_clchrs_dtls;
  l_n_ctr_r2  NUMBER;
  l_n_ctr_r3  NUMBER;
  l_n_ctr_r7  NUMBER;
  l_n_ctr_r6  NUMBER;
BEGIN

  log_to_fnd(p_v_module => 'insert_into_resp_r1',
             p_v_string => 'Checking fields common to RELEASE-4 AND RELEASE-5 for loan number ='||p_loan_number
            );
  -- fields common to both the RELASE-5 and RELEASE-4
  rec_cl_resp_r1.rec_code                     :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,1,2)));
  rec_cl_resp_r1.rec_type_ind                 :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,3,1)));
  rec_cl_resp_r1.b_last_name                  :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,12,35)));
  rec_cl_resp_r1.b_first_name                 :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,47,12)));
  rec_cl_resp_r1.b_middle_name                :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,59,1)));
  rec_cl_resp_r1.b_ssn                        :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,60,9))));
  rec_cl_resp_r1.b_permt_addr1                :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,69,30)));
  rec_cl_resp_r1.b_permt_addr2                :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,99,30)));
  rec_cl_resp_r1.b_permt_city                 :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,129,24)));
  rec_cl_resp_r1.b_permt_state                :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,159,2)));
  rec_cl_resp_r1.b_permt_zip                  :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,161,5))));
  rec_cl_resp_r1.b_permt_zip_suffix           :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,166,4))));
  rec_cl_resp_r1.b_permt_phone                :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,170,10)));
  rec_cl_resp_r1.b_date_of_birth              :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,180,8),'YYYYMMDD');
  rec_cl_resp_r1.cl_loan_type                 :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,188,2)));
  rec_cl_resp_r1.req_loan_amt                 :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,190,6))));
  rec_cl_resp_r1.defer_req_code               :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,196,1)));
  rec_cl_resp_r1.borw_interest_ind            :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,197,1)));
  rec_cl_resp_r1.eft_auth_code                :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,198,1)));
  rec_cl_resp_r1.b_signature_code             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,199,1)));
  rec_cl_resp_r1.b_signature_date             :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,200,8),'YYYYMMDD');
  rec_cl_resp_r1.loan_number                  :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,208,17)));
  rec_cl_resp_r1.cl_seq_number                :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,225,2))));
  rec_cl_resp_r1.b_citizenship_status         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,228,1)));
  rec_cl_resp_r1.b_state_of_legal_res         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,229,2)));
  rec_cl_resp_r1.b_legal_res_date             :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,231,6)||'01','YYYYMMDD');
  rec_cl_resp_r1.b_default_status             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,237,1)));
  rec_cl_resp_r1.b_outstd_loan_code           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,238,1)));
  rec_cl_resp_r1.b_indicator_code             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,239,1)));
  rec_cl_resp_r1.s_last_name                  :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,259,35)));
  rec_cl_resp_r1.s_first_name                 :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,294,12)));
  rec_cl_resp_r1.s_middle_name                :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,306,1)));
  rec_cl_resp_r1.s_ssn                        :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,307,9))));
  rec_cl_resp_r1.s_date_of_birth              :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,316,8),'YYYYMMDD');
  rec_cl_resp_r1.s_citizenship_status         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,324,1)));
  rec_cl_resp_r1.s_default_code               :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,325,1)));
  rec_cl_resp_r1.s_signature_code             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,326,1)));
  rec_cl_resp_r1.school_id                    :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,347,8))));
  rec_cl_resp_r1.loan_per_begin_date          :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,357,8),'YYYYMMDD');
  rec_cl_resp_r1.loan_per_end_date            :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,365,8),'YYYYMMDD');
  rec_cl_resp_r1.grade_level_code             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,373,1)));
  rec_cl_resp_r1.enrollment_code              :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,375,1)));
  rec_cl_resp_r1.anticip_compl_date           :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,376,8),'YYYYMMDD');
  rec_cl_resp_r1.coa_amt                      :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,384,5))));
  rec_cl_resp_r1.efc_amt                      :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,389,5))));
  rec_cl_resp_r1.est_fa_amt                   :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,394,5))));
  rec_cl_resp_r1.fls_cert_amt                 :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,399,5))));
  rec_cl_resp_r1.flu_cert_amt                 :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,404,5))));
  rec_cl_resp_r1.flp_cert_amt                 :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,409,5))));
  rec_cl_resp_r1.sch_cert_date                :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,414,8),'YYYYMMDD');
  rec_cl_resp_r1.alt_cert_amt                 :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,438,5))));
  rec_cl_resp_r1.alt_appl_ver_code            :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,443,4))));
  rec_cl_resp_r1.lender_id                    :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,458,6)));
  rec_cl_resp_r1.fls_approved_amt             :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,464,5))));
  rec_cl_resp_r1.flu_approved_amt             :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,469,5))));
  rec_cl_resp_r1.flp_approved_amt             :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,474,5))));
  rec_cl_resp_r1.alt_approved_amt             :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,488,5))));
  rec_cl_resp_r1.guarantor_id                 :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,507,3)));
  rec_cl_resp_r1.fed_appl_form_code           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,510,1)));
  rec_cl_resp_r1.guarnt_adj_ind               :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,531,1)));
  rec_cl_resp_r1.guarantee_date               :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,680,8),'YYYYMMDD');
  rec_cl_resp_r1.b_license_state              :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,715,2)));
  rec_cl_resp_r1.b_license_number             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,717,20)));
  rec_cl_resp_r1.b_ref_code                   :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,737,1)));
  rec_cl_resp_r1.school_use_txt               :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,738,23)));
  rec_cl_resp_r1.pnote_delivery_code          :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,765,1)));
  rec_cl_resp_r1.b_foreign_postal_code        :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,766,14)));
  rec_cl_resp_r1.lend_non_ed_brc_id           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,781,4)));
  rec_cl_resp_r1.lender_use_txt               :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,785,20)));
  rec_cl_resp_r1.last_resort_lender           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,805,1)));
  rec_cl_resp_r1.resp_to_orig_code            :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,830,1)));
  rec_cl_resp_r1.err_mesg_1                   :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,831,3)));
  rec_cl_resp_r1.err_mesg_2                   :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,834,3)));
  rec_cl_resp_r1.err_mesg_3                   :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,837,3)));
  rec_cl_resp_r1.err_mesg_4                   :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,840,3)));
  rec_cl_resp_r1.err_mesg_5                   :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,843,3)));
  rec_cl_resp_r1.guarnt_amt_redn_code         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,846,2)));
  rec_cl_resp_r1.tot_outstd_stafford          :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,848,8))))/100;
  rec_cl_resp_r1.tot_outstd_plus              :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,856,8))))/100;
  rec_cl_resp_r1.guarantor_use_txt            :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,876,23)));
  rec_cl_resp_r1.b_permt_addr_chg_date        :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,899,8),'YYYYMMDD');
  rec_cl_resp_r1.alt_prog_type_code           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,907,3)));
  rec_cl_resp_r1.alt_borw_tot_debt            :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,910,7))));
--MN 16-Dec-2004 15:25 Interest has 3 decimal places after assumed DP.
  rec_cl_resp_r1.act_interest_rate            :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,957,5))))/1000;
  rec_cl_resp_r1.prc_type_code                :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,962,2)));
  rec_cl_resp_r1.service_type_code            :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,964,2)));
  rec_cl_resp_r1.rev_notice_of_guarnt         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,966,1)));
  rec_cl_resp_r1.sch_refund_amt               :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,967,5))))/100;
  rec_cl_resp_r1.sch_refund_date              :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,974,8),'YYYYMMDD');
  rec_cl_resp_r1.resp_record_status           :=  p_resp_record_status;
  rec_cl_resp_r1.cl_version_code              :=  g_v_cl_version;
  -- bvisvana - FA 161 - Bug # 5006583
  rec_cl_resp_r1.esign_src_typ_cd             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,449,9)));
  rec_cl_resp_r1.b_alien_reg_num_txt          :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,240,19)));

  -- fields for RELEASE-4 only

  IF g_v_cl_version = 'RELEASE-4' THEN
    log_to_fnd(p_v_module => 'insert_into_resp_r1',
               p_v_string => 'Seggrgating fields common to RELEASE-4'
              );
    rec_cl_resp_r1.borr_credit_auth_code        :=  NULL;
    rec_cl_resp_r1.borr_sign_ind                :=  NULL;
    rec_cl_resp_r1.duns_school_id               :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,449,9)));
    rec_cl_resp_r1.lend_apprv_denied_date       :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,479,8),'YYYYMMDD');
    rec_cl_resp_r1.lend_apprv_denied_code       :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,487,1)));
    rec_cl_resp_r1.duns_lender_id               :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,493,9)));
    rec_cl_resp_r1.duns_guarnt_id               :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,511,9)));
    rec_cl_resp_r1.lend_blkt_guarnt_ind         :=  NULL;
    rec_cl_resp_r1.lend_blkt_guarnt_appr_date   :=  NULL;
    rec_cl_resp_r1.guarantee_amt                :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,688,5))));
    rec_cl_resp_r1.req_serial_loan_code         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,693,1)));
    rec_cl_resp_r1.mpn_confirm_ind              :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,694,1)));
    rec_cl_resp_r1.borw_confirm_ind             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,695,1)));
    rec_cl_resp_r1.stud_sign_ind                :=  NULL;
    rec_cl_resp_r1.appl_loan_phase_code         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,864,4)));
    rec_cl_resp_r1.appl_loan_phase_code_chg     :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,868,8),'YYYYMMDD');
    rec_cl_resp_r1.guarnt_status_code           :=  NULL;
    rec_cl_resp_r1.lender_status_code           :=  NULL;
    rec_cl_resp_r1.pnote_status_code            :=  NULL;
    rec_cl_resp_r1.credit_status_code           :=  NULL;
    rec_cl_resp_r1.guarnt_status_date           :=  NULL;
    rec_cl_resp_r1.lender_status_date           :=  NULL;
    rec_cl_resp_r1.pnote_status_date            :=  NULL;
    rec_cl_resp_r1.credit_status_date           :=  NULL;
    rec_cl_resp_r1.act_serial_loan_code         :=  NULL;
    rec_cl_resp_r1.sch_non_ed_brc_id            :=  NULL;
    rec_cl_resp_r1.amt_avail_for_reinst         :=  NULL;
    rec_cl_resp_r1.uniq_layout_vend_code        :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,982,4)));
    rec_cl_resp_r1.uniq_layout_ident_code       :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,986,2)));
    IF rec_cl_resp_r1.rec_type_ind IN ('A','I','G','B','P','D','T') THEN -- MN 13-Jan-2005 - Added Termination Status T
      rec_cl_resp_r1.cl_rec_status              :=  rec_cl_resp_r1.rec_type_ind;
--MN 16-Dec-2004 15:25  The Sent Code and Received Codes are not same
--      rec_cl_resp_r1.rec_type_ind               :=  NVL(p_rec_type_ind,'S');  -- should be same as sent one
    END IF; -- else retain old status
    rec_cl_resp_r1.cl_rec_status_last_update    :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,4,8),'YYYYMMDD');

  -- fields for RELEASE-5 only
  ELSIF g_v_cl_version = 'RELEASE-5' THEN
    log_to_fnd(p_v_module => 'insert_into_resp_r1',
               p_v_string => 'Seggregating fields common to RELEASE-5'
              );
    rec_cl_resp_r1.borr_credit_auth_code        :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,227,1)));
    rec_cl_resp_r1.borr_sign_ind                :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,374,1)));
    rec_cl_resp_r1.duns_school_id               :=  NULL;
    rec_cl_resp_r1.lend_apprv_denied_date       :=  NULL;
    rec_cl_resp_r1.lend_apprv_denied_code       :=  NULL;
    rec_cl_resp_r1.duns_lender_id               :=  NULL;
    rec_cl_resp_r1.duns_guarnt_id               :=  NULL;
    rec_cl_resp_r1.lend_blkt_guarnt_ind         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,522,1)));
    rec_cl_resp_r1.lend_blkt_guarnt_appr_date   :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,523,8),'YYYYMMDD');
    rec_cl_resp_r1.guarantee_amt                :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,688,7))));
    rec_cl_resp_r1.req_serial_loan_code         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,695,1)));
    rec_cl_resp_r1.mpn_confirm_ind              :=  NULL;
    rec_cl_resp_r1.borw_confirm_ind             :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,697,1)));
    rec_cl_resp_r1.stud_sign_ind                :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,780,1)));
    rec_cl_resp_r1.appl_loan_phase_code         :=  NULL;
    rec_cl_resp_r1.appl_loan_phase_code_chg     :=  NULL;
    rec_cl_resp_r1.guarnt_status_code           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,992,2)));
    rec_cl_resp_r1.lender_status_code           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,994,2)));
    rec_cl_resp_r1.pnote_status_code            :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,996,2)));
    rec_cl_resp_r1.credit_status_code           :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,998,2)));
    rec_cl_resp_r1.guarnt_status_date           :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,1000,14),'YYYYMMDDHH24MISS');
    rec_cl_resp_r1.lender_status_date           :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,1014,14),'YYYYMMDDHH24MISS');
    rec_cl_resp_r1.pnote_status_date            :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,1028,14),'YYYYMMDDHH24MISS');
    rec_cl_resp_r1.credit_status_date           :=  fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,1042,14),'YYYYMMDDHH24MISS');
    rec_cl_resp_r1.act_serial_loan_code         :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,1056,1)));
    rec_cl_resp_r1.sch_non_ed_brc_id            :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,1090,4)));
    rec_cl_resp_r1.amt_avail_for_reinst         :=  TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,1094,7))));
    rec_cl_resp_r1.uniq_layout_vend_code        :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,1142,4)));
    rec_cl_resp_r1.uniq_layout_ident_code       :=  LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,1146,2)));
    rec_cl_resp_r1.cl_rec_status                :=  NULL;
    rec_cl_resp_r1.cl_rec_status_last_update    :=  NULL;

  END IF;

    gv_debug_str := 'INSERT_INTO_RESP1 - 1' ||' ';
    log_to_fnd(p_v_module => 'insert_into_resp_r1',
               p_v_string => 'Invoking igf_sl_cl_resp_r1_pkg.insert_row'
              );

    igf_sl_cl_resp_r1_pkg.insert_row (
     x_mode                         =>   'R'                                         ,
     x_rowid                        =>   l_row_id                                    ,
     x_clrp1_id                     =>   l_clrp1_id                                  ,
     x_cbth_id                      =>   g_cbth_id                                   ,
     x_rec_code                     =>   rec_cl_resp_r1.rec_code                     ,
     x_rec_type_ind                 =>   rec_cl_resp_r1.rec_type_ind                 ,
     x_b_last_name                  =>   rec_cl_resp_r1.b_last_name                  ,
     x_b_first_name                 =>   rec_cl_resp_r1.b_first_name                 ,
     x_b_middle_name                =>   rec_cl_resp_r1.b_middle_name                ,
     x_b_ssn                        =>   rec_cl_resp_r1.b_ssn                        ,
     x_b_permt_addr1                =>   rec_cl_resp_r1.b_permt_addr1                ,
     x_b_permt_addr2                =>   rec_cl_resp_r1.b_permt_addr2                ,
     x_b_permt_city                 =>   rec_cl_resp_r1.b_permt_city                 ,
     x_b_permt_state                =>   rec_cl_resp_r1.b_permt_state                ,
     x_b_permt_zip                  =>   rec_cl_resp_r1.b_permt_zip                  ,
     x_b_permt_zip_suffix           =>   rec_cl_resp_r1.b_permt_zip_suffix           ,
     x_b_permt_phone                =>   rec_cl_resp_r1.b_permt_phone                ,
     x_b_date_of_birth              =>   rec_cl_resp_r1.b_date_of_birth              ,
     x_cl_loan_type                 =>   rec_cl_resp_r1.cl_loan_type                 ,
     x_req_loan_amt                 =>   rec_cl_resp_r1.req_loan_amt                 ,
     x_defer_req_code               =>   rec_cl_resp_r1.defer_req_code               ,
     x_borw_interest_ind            =>   rec_cl_resp_r1.borw_interest_ind            ,
     x_eft_auth_code                =>   rec_cl_resp_r1.eft_auth_code                ,
     x_b_signature_code             =>   rec_cl_resp_r1.b_signature_code             ,
     x_b_signature_date             =>   rec_cl_resp_r1.b_signature_date             ,
     x_loan_number                  =>   rec_cl_resp_r1.loan_number                  ,
     x_cl_seq_number                =>   rec_cl_resp_r1.cl_seq_number                ,
     x_b_citizenship_status         =>   rec_cl_resp_r1.b_citizenship_status         ,
     x_b_state_of_legal_res         =>   rec_cl_resp_r1.b_state_of_legal_res         ,
     x_b_legal_res_date             =>   rec_cl_resp_r1.b_legal_res_date             ,
     x_b_default_status             =>   rec_cl_resp_r1.b_default_status             ,
     x_b_outstd_loan_code           =>   rec_cl_resp_r1.b_outstd_loan_code           ,
     x_b_indicator_code             =>   rec_cl_resp_r1.b_indicator_code             ,
     x_s_last_name                  =>   rec_cl_resp_r1.s_last_name                  ,
     x_s_first_name                 =>   rec_cl_resp_r1.s_first_name                 ,
     x_s_middle_name                =>   rec_cl_resp_r1.s_middle_name                ,
     x_s_ssn                        =>   rec_cl_resp_r1.s_ssn                        ,
     x_s_date_of_birth              =>   rec_cl_resp_r1.s_date_of_birth              ,
     x_s_citizenship_status         =>   rec_cl_resp_r1.s_citizenship_status         ,
     x_s_default_code               =>   rec_cl_resp_r1.s_default_code               ,
     x_s_signature_code             =>   rec_cl_resp_r1.s_signature_code             ,
     x_school_id                    =>   rec_cl_resp_r1.school_id                    ,
     x_loan_per_begin_date          =>   rec_cl_resp_r1.loan_per_begin_date          ,
     x_loan_per_end_date            =>   rec_cl_resp_r1.loan_per_end_date            ,
     x_grade_level_code             =>   rec_cl_resp_r1.grade_level_code             ,
     x_enrollment_code              =>   rec_cl_resp_r1.enrollment_code              ,
     x_anticip_compl_date           =>   rec_cl_resp_r1.anticip_compl_date           ,
     x_coa_amt                      =>   rec_cl_resp_r1.coa_amt                      ,
     x_efc_amt                      =>   rec_cl_resp_r1.efc_amt                      ,
     x_est_fa_amt                   =>   rec_cl_resp_r1.est_fa_amt                   ,
     x_fls_cert_amt                 =>   rec_cl_resp_r1.fls_cert_amt                 ,
     x_flu_cert_amt                 =>   rec_cl_resp_r1.flu_cert_amt                 ,
     x_flp_cert_amt                 =>   rec_cl_resp_r1.flp_cert_amt                 ,
     x_sch_cert_date                =>   rec_cl_resp_r1.sch_cert_date                ,
     x_alt_cert_amt                 =>   rec_cl_resp_r1.alt_cert_amt                 ,
     x_alt_appl_ver_code            =>   rec_cl_resp_r1.alt_appl_ver_code            ,
     x_duns_school_id               =>   rec_cl_resp_r1.duns_school_id               ,
     x_lender_id                    =>   rec_cl_resp_r1.lender_id                    ,
     x_fls_approved_amt             =>   rec_cl_resp_r1.fls_approved_amt             ,
     x_flu_approved_amt             =>   rec_cl_resp_r1.flu_approved_amt             ,
     x_flp_approved_amt             =>   rec_cl_resp_r1.flp_approved_amt             ,
     x_alt_approved_amt             =>   rec_cl_resp_r1.alt_approved_amt             ,
     x_duns_lender_id               =>   rec_cl_resp_r1.duns_lender_id               ,
     x_guarantor_id                 =>   rec_cl_resp_r1.guarantor_id                 ,
     x_fed_appl_form_code           =>   rec_cl_resp_r1.fed_appl_form_code           ,
     x_duns_guarnt_id               =>   rec_cl_resp_r1.duns_guarnt_id               ,
     x_lend_blkt_guarnt_ind         =>   rec_cl_resp_r1.lend_blkt_guarnt_ind         ,
     x_lend_blkt_guarnt_appr_date   =>   rec_cl_resp_r1.lend_blkt_guarnt_appr_date   ,
     x_guarnt_adj_ind               =>   rec_cl_resp_r1.guarnt_adj_ind               ,
     x_guarantee_date               =>   rec_cl_resp_r1.guarantee_date               ,
     x_guarantee_amt                =>   rec_cl_resp_r1.guarantee_amt                ,
     x_req_serial_loan_code         =>   rec_cl_resp_r1.req_serial_loan_code         ,
     x_borw_confirm_ind             =>   rec_cl_resp_r1.borw_confirm_ind             ,
     x_b_license_state              =>   rec_cl_resp_r1.b_license_state              ,
     x_b_license_number             =>   rec_cl_resp_r1.b_license_number             ,
     x_b_ref_code                   =>   rec_cl_resp_r1.b_ref_code                   ,
     x_pnote_delivery_code          =>   rec_cl_resp_r1.pnote_delivery_code          ,
     x_b_foreign_postal_code        =>   rec_cl_resp_r1.b_foreign_postal_code        ,
     x_lend_non_ed_brc_id           =>   rec_cl_resp_r1.lend_non_ed_brc_id           ,
     x_last_resort_lender           =>   rec_cl_resp_r1.last_resort_lender           ,
     x_resp_to_orig_code            =>   rec_cl_resp_r1.resp_to_orig_code            ,
     x_err_mesg_1                   =>   rec_cl_resp_r1.err_mesg_1                   ,
     x_err_mesg_2                   =>   rec_cl_resp_r1.err_mesg_2                   ,
     x_err_mesg_3                   =>   rec_cl_resp_r1.err_mesg_3                   ,
     x_err_mesg_4                   =>   rec_cl_resp_r1.err_mesg_4                   ,
     x_err_mesg_5                   =>   rec_cl_resp_r1.err_mesg_5                   ,
     x_guarnt_amt_redn_code         =>   rec_cl_resp_r1.guarnt_amt_redn_code         ,
     x_tot_outstd_stafford          =>   rec_cl_resp_r1.tot_outstd_stafford          ,
     x_tot_outstd_plus              =>   rec_cl_resp_r1.tot_outstd_plus              ,
     x_b_permt_addr_chg_date        =>   rec_cl_resp_r1.b_permt_addr_chg_date        ,
     x_alt_prog_type_code           =>   rec_cl_resp_r1.alt_prog_type_code           ,
     x_alt_borw_tot_debt            =>   rec_cl_resp_r1.alt_borw_tot_debt            ,
     x_act_interest_rate            =>   rec_cl_resp_r1.act_interest_rate            ,
     x_prc_type_code                =>   rec_cl_resp_r1.prc_type_code                ,
     x_service_type_code            =>   rec_cl_resp_r1.service_type_code            ,
     x_rev_notice_of_guarnt         =>   rec_cl_resp_r1.rev_notice_of_guarnt         ,
     x_sch_refund_amt               =>   rec_cl_resp_r1.sch_refund_amt               ,
     x_sch_refund_date              =>   rec_cl_resp_r1.sch_refund_date              ,
     x_guarnt_status_code           =>   rec_cl_resp_r1.guarnt_status_code           ,
     x_lender_status_code           =>   rec_cl_resp_r1.lender_status_code           ,
     x_pnote_status_code            =>   rec_cl_resp_r1.pnote_status_code            ,
     x_credit_status_code           =>   rec_cl_resp_r1.credit_status_code           ,
     x_guarnt_status_date           =>   rec_cl_resp_r1.guarnt_status_date           ,
     x_lender_status_date           =>   rec_cl_resp_r1.lender_status_date           ,
     x_pnote_status_date            =>   rec_cl_resp_r1.pnote_status_date            ,
     x_credit_status_date           =>   rec_cl_resp_r1.credit_status_date           ,
     x_act_serial_loan_code         =>   rec_cl_resp_r1.act_serial_loan_code         ,
     x_amt_avail_for_reinst         =>   rec_cl_resp_r1.amt_avail_for_reinst         ,
     x_sch_non_ed_brc_id            =>   rec_cl_resp_r1.sch_non_ed_brc_id            ,
     x_uniq_layout_vend_code        =>   rec_cl_resp_r1.uniq_layout_vend_code        ,
     x_uniq_layout_ident_code       =>   rec_cl_resp_r1.uniq_layout_ident_code       ,
     x_resp_record_status           =>   rec_cl_resp_r1.resp_record_status           ,
     x_borr_sign_ind                =>   rec_cl_resp_r1.borr_sign_ind                ,
     x_stud_sign_ind                =>   rec_cl_resp_r1.stud_sign_ind                ,
     x_borr_credit_auth_code        =>   rec_cl_resp_r1.borr_credit_auth_code        ,
     x_mpn_confirm_ind              =>   rec_cl_resp_r1.mpn_confirm_ind              ,
     x_lender_use_txt               =>   rec_cl_resp_r1.lender_use_txt               ,
     x_guarantor_use_txt            =>   rec_cl_resp_r1.guarantor_use_txt            ,
     x_appl_loan_phase_code         =>   rec_cl_resp_r1.appl_loan_phase_code         ,
     x_appl_loan_phase_code_chg     =>   rec_cl_resp_r1.appl_loan_phase_code_chg     ,
     x_cl_rec_status                =>   rec_cl_resp_r1.cl_rec_status                ,
     x_cl_rec_status_last_update    =>   rec_cl_resp_r1.cl_rec_status_last_update    ,
     x_lend_apprv_denied_code       =>   rec_cl_resp_r1.lend_apprv_denied_code       ,
     x_lend_apprv_denied_date       =>   rec_cl_resp_r1.lend_apprv_denied_date       ,
     x_cl_version_code              =>   rec_cl_resp_r1.cl_version_code              ,
     x_school_use_txt               =>   rec_cl_resp_r1.school_use_txt                ,
     x_b_alien_reg_num_txt          =>   rec_cl_resp_r1.b_alien_reg_num_txt          ,
     x_esign_src_typ_cd             =>   rec_cl_resp_r1.esign_src_typ_cd
    );

    -- Upto a Max of 4 disbursements records info can be present in @1 record.
    -- Moving this data into PL/sql table.

    gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 2' ||' ';
    l_ind := 1;
    FOR i IN 0..3 LOOP

       IF LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,(761+1*i) ,1))) IS NOT NULL THEN

           gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 3' ||' ';

           r8_tab(l_ind).clrp8_id                :=      l_ind+1;
           r8_tab(l_ind).disb_date               :=      fnd_date.string_to_date(SUBSTR(Format_1_rec.record_data,( 536 +36*i),8),'YYYYMMDD');
           r8_tab(l_ind).disb_gross_amt          :=      TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,( 544 +36*i),7))))/100;
           r8_tab(l_ind).orig_fee                :=      TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,( 551 +36*i),7))))/100;
           r8_tab(l_ind).guarantee_fee           :=      TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,( 558 +36*i),7))))/100;
           r8_tab(l_ind).net_disb_amt            :=      TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,( 565 +36*i),7))))/100;
           r8_tab(l_ind).disb_hold_rel_ind       :=      LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,( 761 +1 *i),1)));
           r8_tab(l_ind).disb_status             :=      LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,( 826 +1 *i),1)));
           r8_tab(l_ind).record_code_txt         :=      '@1';
           IF g_v_cl_version = 'RELEASE-5' THEN
             r8_tab(l_ind).guarnt_fee_paid         :=      TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,( 929 +7 *i),7))))/100;
             r8_tab(l_ind).orig_fee_paid           :=      TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,(1057 +7 *i),7))))/100;
             r8_tab(l_ind).layout_owner_code_txt   :=      LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,1142,4)));
             r8_tab(l_ind).layout_version_code_txt :=      LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,1146,2)));
           ELSIF g_v_cl_version = 'RELEASE-4' THEN
	     --akomurav changes made according to FA163 TD
	     IF (i=0) THEN
	       l_start_guar_pos := 701;
 	       l_start_orig_pos := 696;
 	     ELSIF (i=1) THEN
 	       l_start_guar_pos := 811;
 	       l_start_orig_pos := 806;
 	     ELSIF (i=2) THEN
 	       l_start_guar_pos := 821;
 	       l_start_orig_pos := 816;
 	     ELSIF (i=3) THEN
 	       l_start_guar_pos := 922;
 	       l_start_orig_pos := 917;
 	     END IF;
	     r8_tab(l_ind).direct_to_borr_flag     :=      LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,( 706 +1 *i),1)));
             r8_tab(l_ind).guarnt_fee_paid         :=      TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,l_start_guar_pos,5))))/100;
             r8_tab(l_ind).orig_fee_paid           :=      TO_NUMBER(LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,l_start_orig_pos,5))))/100;
             r8_tab(l_ind).layout_owner_code_txt   :=      LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,982,4)));
             r8_tab(l_ind).layout_version_code_txt :=      LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,986,2)));
           END IF;
           l_ind := l_ind + 1;
           gv_debug_str := '';
       END IF;
     END LOOP;


    --This Fetch is to get all the @8 Records that follow the Current Format_1 Record.
    --And @8 records are alone inserted into IGF_SL_RESP_R8 Table

    gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 4' || ' ';
    l_n_ctr_r2   := 0;
    l_n_ctr_r3   := 0;
    l_n_ctr_r7   := 0;
    l_n_ctr_r6   := 0;
    FOR other_rec IN cur_other_records('CL_ORIG_ACK') LOOP


      IF LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2))) IN ('@1','@T') THEN
         -- If the Next @1 record is Fetched, then It is the Next Loan Number.
         -- So, Otherrecords for this Loan Number are over.
         gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 5' || ' ';
         EXIT;

      ELSIF LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2)))='@8' THEN
        IF g_v_cl_version = 'RELEASE-5' THEN
          -- From @8 records, we need to get the 16 disbursement records into the PL/sql table.
          gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 6' || ' ';
          FOR i IN 0..15 LOOP

             IF LTRIM(RTRIM(SUBSTR(other_rec.record_data,(585+ 1*i),1))) IS NOT NULL THEN
                 gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 7' || ' ';
                 r8_tab(l_ind).clrp8_id                :=   l_ind;
                 r8_tab(l_ind).disb_date               :=   fnd_date.string_to_date(SUBSTR(other_rec.record_data,(9 + 8*i),8),'YYYYMMDD');
                 r8_tab(l_ind).disb_gross_amt          :=   TO_NUMBER(LTRIM(RTRIM(SUBSTR(other_rec.record_data,( 137 + 7*i),7))))/100;
                 r8_tab(l_ind).orig_fee                :=   TO_NUMBER(LTRIM(RTRIM(SUBSTR(other_rec.record_data,( 249 + 7*i),7))))/100;
                 r8_tab(l_ind).guarantee_fee           :=   TO_NUMBER(LTRIM(RTRIM(SUBSTR(other_rec.record_data,( 361 + 7*i),7))))/100;
                 r8_tab(l_ind).net_disb_amt            :=   TO_NUMBER(LTRIM(RTRIM(SUBSTR(other_rec.record_data,( 473 + 7*i),7))))/100;
                 r8_tab(l_ind).disb_hold_rel_ind       :=   LTRIM(RTRIM(SUBSTR(other_rec.record_data,( 585 + 1*i),1)));
                 r8_tab(l_ind).disb_status             :=   LTRIM(RTRIM(SUBSTR(other_rec.record_data,( 601 + 1*i),1)));
                 r8_tab(l_ind).guarnt_fee_paid         :=   TO_NUMBER(LTRIM(RTRIM(SUBSTR(other_rec.record_data,( 617 + 7*i),7))))/100;
                 r8_tab(l_ind).orig_fee_paid           :=   TO_NUMBER(LTRIM(RTRIM(SUBSTR(other_rec.record_data,( 729 + 7*i),7))))/100;
                 r8_tab(l_ind).layout_owner_code_txt   :=   LTRIM(RTRIM(SUBSTR(other_rec.record_data,3,4)));
                 r8_tab(l_ind).layout_version_code_txt :=   LTRIM(RTRIM(SUBSTR(other_rec.record_data,7,2)));
                 r8_tab(l_ind).record_code_txt         :=   '@8';
		 r8_tab(l_ind).direct_to_borr_flag     :=   LTRIM(RTRIM(SUBSTR(other_rec.record_data,(841 + 1*i),1)));--akomurav changes made according to FA163 TD
                 l_ind := l_ind + 1;
                 gv_debug_str := '';
             END IF;

          END LOOP;
        END IF;
      --Code has been added here to check if there is a @4 record format.
     --If the encountered Record is @4 and the @1 record specifies its presence then Insert else display message

      ELSIF LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2))) ='@4'  THEN

      --@1 record specifies its presence
           gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 8' || ' ';
           IF LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,188,2)))='AL'   THEN

            --Insert into igf_sl_cl_resp_r4 table
                 gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 9' || ' ';
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.insert_into_resp1.debug',gv_debug_str);
                 END IF;
                 insert_into_resp_r4(l_clrp1_id,
                                     other_rec.record_data);
                 gv_debug_str := '';

              IF l_title_flag IS NULL THEN

                  --
                  -- Default array values for Lookup Desc
                  --
                    gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 10' || ' ';
                    title_array(1)  := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FED_STAFFORD_LOAN_DEBT'),50,' ');
                    title_array(2)  := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FED_SLS_DEBT'),50,' ');
                    title_array(3)  := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','HEAL_DEBT'),50,' ');
                    title_array(4)  := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','PERKINS_DEBT'),50,' ');
                    title_array(5)  := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','OTHER_DEBT'),50,' ');
                    title_array(6)  := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','CRDT_UNDER_DIFFT_NAME'),50,' ');
                    title_array(7)  := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','BORW_GROSS_ANNUAL_SAL'),50,' ');
                    title_array(8)  := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','BORW_OTHER_INCOME'),50,' ');
                    title_array(9)  := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','STUDENT_MAJOR'),50,' ');
                    title_array(10) := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','INT_RATE_OPTION'),50,' ');
                    title_array(11) := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','REPAYMENT_OPT_CODE'),50,' ');
                    title_array(12) := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','STUD_MTH_HOUSING_PYMT'),50,' ');
                    title_array(13) := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','STUD_MTH_CRDTCARD_PYMT'),50,' ');
                    title_array(14) := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','STUD_MTH_AUTO_PYMT'),50,' ');
                    title_array(15) := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','STUD_MTH_ED_LOAN_PYMT'),50,' ');
                    title_array(16) := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','STUD_MTH_OTHER_PYMT'),50,' ');
                    title_array(17) := LPAD(igf_aw_gen.lookup_desc('IGF_SL_GEN','OFA_ALT_DETAILS'),80,' ');
                    title_array(18) := LPAD(igf_aw_gen.lookup_desc('IGF_SL_GEN','FILE_ALT_DETAILS'),40,' ');
                    l_title_flag:='Y';

              END IF;

            ELSIF LTRIM(RTRIM(SUBSTR(Format_1_rec.record_data,188,2))) <> 'AL' THEN
                 gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 11' || ' ';
                 fnd_message.set_name('IGF','IGF_SL_CL_FORMAT_NOT_SUPP');
                 fnd_message.set_token('FORMAT',LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2))));
                 fnd_file.put_line(fnd_file.log, fnd_message.get);

            END IF;

      ELSIF LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2))) ='@2'  THEN
        l_n_ctr_r2 := NVL(l_n_ctr_r2,0) + 1;
        v_tab_resp_r2(l_n_ctr_r2).clrp1_id               := l_clrp1_id;
        v_tab_resp_r2(l_n_ctr_r2).record_code_txt        := LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2)));
        v_tab_resp_r2(l_n_ctr_r2).uniq_layout_vend_code  := LTRIM(RTRIM(SUBSTR(other_rec.record_data,3,4)));
        v_tab_resp_r2(l_n_ctr_r2).uniq_layout_ident_code := LTRIM(RTRIM(SUBSTR(other_rec.record_data,7,2)));

        IF g_v_cl_version = 'RELEASE-5' THEN
          v_tab_resp_r2(l_n_ctr_r2).filler_txt           :=  LTRIM(RTRIM(SUBSTR(other_rec.record_data,9,1191)));
        ELSIF g_v_cl_version = 'RELEASE-4' THEN
          v_tab_resp_r2(l_n_ctr_r2).filler_txt           :=  LTRIM(RTRIM(SUBSTR(other_rec.record_data,9,1031)));
        END IF;

      ELSIF LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2))) ='@3'  THEN
        l_n_ctr_r3 := NVL(l_n_ctr_r3,0) + 1;
        v_tab_resp_r3(l_n_ctr_r3).clrp1_id               := l_clrp1_id;
        v_tab_resp_r3(l_n_ctr_r3).record_code_txt        := LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2)));
        v_tab_resp_r3(l_n_ctr_r3).message_1_text         := LTRIM(RTRIM(SUBSTR(other_rec.record_data,3,160)));
        v_tab_resp_r3(l_n_ctr_r3).message_2_text         := LTRIM(RTRIM(SUBSTR(other_rec.record_data,163,160)));
        v_tab_resp_r3(l_n_ctr_r3).message_3_text         := LTRIM(RTRIM(SUBSTR(other_rec.record_data,323,160)));
        v_tab_resp_r3(l_n_ctr_r3).message_4_text         := LTRIM(RTRIM(SUBSTR(other_rec.record_data,483,160)));
        v_tab_resp_r3(l_n_ctr_r3).message_5_text         := LTRIM(RTRIM(SUBSTR(other_rec.record_data,643,160)));

      ELSIF LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2))) ='@7'  THEN
        l_n_ctr_r7 := NVL(l_n_ctr_r7,0) + 1;
        v_tab_resp_r7(l_n_ctr_r7).clrp1_id                       := l_clrp1_id;
        v_tab_resp_r7(l_n_ctr_r7).record_code_txt                := LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2)));
        v_tab_resp_r7(l_n_ctr_r7).layout_owner_code_txt          := LTRIM(RTRIM(SUBSTR(other_rec.record_data,3,4)));
        v_tab_resp_r7(l_n_ctr_r7).layout_identifier_code_txt     := LTRIM(RTRIM(SUBSTR(other_rec.record_data,7,2)));
        v_tab_resp_r7(l_n_ctr_r7).email_txt                      := LTRIM(RTRIM(SUBSTR(other_rec.record_data,9,256)));
        v_tab_resp_r7(l_n_ctr_r7).valid_email_flag               := LTRIM(RTRIM(SUBSTR(other_rec.record_data,265,1)));
        v_tab_resp_r7(l_n_ctr_r7).email_effective_date           := fnd_date.string_to_date(LTRIM(RTRIM(SUBSTR(other_rec.record_data,266,8))),'YYYYMMDD');
        v_tab_resp_r7(l_n_ctr_r7).borrower_temp_add_line_1_txt   := LTRIM(RTRIM(SUBSTR(other_rec.record_data,274,30)));
        v_tab_resp_r7(l_n_ctr_r7).borrower_temp_add_line_2_txt   := LTRIM(RTRIM(SUBSTR(other_rec.record_data,304,30)));
        v_tab_resp_r7(l_n_ctr_r7).borrower_temp_add_city_txt     := LTRIM(RTRIM(SUBSTR(other_rec.record_data,334,24)));
        v_tab_resp_r7(l_n_ctr_r7).borrower_temp_add_state_txt    := LTRIM(RTRIM(SUBSTR(other_rec.record_data,358,2)));
        v_tab_resp_r7(l_n_ctr_r7).borrower_temp_add_zip_num      := TO_NUMBER(LTRIM(RTRIM(SUBSTR(other_rec.record_data,360,5))));
        v_tab_resp_r7(l_n_ctr_r7).borrower_temp_add_zip_xtn_num  := TO_NUMBER(LTRIM(RTRIM(SUBSTR(other_rec.record_data,365,4))));
        v_tab_resp_r7(l_n_ctr_r7).borrower_forgn_postal_code_txt := LTRIM(RTRIM(SUBSTR(other_rec.record_data,369,14)));

      ELSIF LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2))) ='@6'  THEN
        -- change send response details are valid for RELEASE-4
        IF g_v_cl_version = 'RELEASE-4' THEN
          l_n_ctr_r6 := NVL(l_n_ctr_r6,0) + 1;
          v_tab_clchrs_dtls(l_n_ctr_r6).clrp1_id             := l_clrp1_id;
          v_tab_clchrs_dtls(l_n_ctr_r6).record_code          := LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2)));
          v_tab_clchrs_dtls(l_n_ctr_r6).send_record_txt      := LTRIM(RTRIM(SUBSTR(other_rec.record_data,3,478)));
          v_tab_clchrs_dtls(l_n_ctr_r6).error_message_1_code := LTRIM(RTRIM(SUBSTR(other_rec.record_data,481,3)));
          v_tab_clchrs_dtls(l_n_ctr_r6).error_message_2_code := LTRIM(RTRIM(SUBSTR(other_rec.record_data,484,3)));
          v_tab_clchrs_dtls(l_n_ctr_r6).error_message_3_code := LTRIM(RTRIM(SUBSTR(other_rec.record_data,487,3)));
          v_tab_clchrs_dtls(l_n_ctr_r6).error_message_4_code := LTRIM(RTRIM(SUBSTR(other_rec.record_data,490,3)));
          v_tab_clchrs_dtls(l_n_ctr_r6).error_message_5_code := LTRIM(RTRIM(SUBSTR(other_rec.record_data,493,3)));
        ELSE
           fnd_message.set_name('IGF','IGF_SL_CL_FORMAT_NOT_SUPP');
           fnd_message.set_token('FORMAT',LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2))));
           fnd_file.put_line(fnd_file.log, fnd_message.get);
        END IF;

      ELSE  -- Display Message only for Record Formats other than @T ,@1  @8, @2,@3,@7 , @6 and @4
           gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 12' || ' ';
           -- Other Record Types are Not Supported in the Current Release.
           fnd_message.set_name('IGF','IGF_SL_CL_FORMAT_NOT_SUPP');
           fnd_message.set_token('FORMAT',LTRIM(RTRIM(SUBSTR(other_rec.record_data,1,2))));
           fnd_file.put_line(fnd_file.log, fnd_message.get);

      END IF;
      gv_debug_str := '';
    END LOOP;

    -- Insert the Disbursement records from the PL/sql table into the CL_RESP_R8 table.
    FOR i IN 1..l_ind-1 LOOP

         l_row_id := NULL;
         gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 13' || ' ';
         igf_sl_cl_resp_r8_pkg.insert_row (
               x_mode                   => 'R',
               x_rowid                  => l_row_id,
               x_clrp1_id               => l_clrp1_id,
               x_clrp8_id               => i,
               x_disb_date              => r8_tab(i).disb_date,
               x_disb_gross_amt         => r8_tab(i).disb_gross_amt,
               x_orig_fee               => r8_tab(i).orig_fee,
               x_guarantee_fee          => r8_tab(i).guarantee_fee,
               x_net_disb_amt           => r8_tab(i).net_disb_amt,
               x_disb_hold_rel_ind      => r8_tab(i).disb_hold_rel_ind,
               x_disb_status            => r8_tab(i).disb_status,
               x_guarnt_fee_paid        => r8_tab(i).guarnt_fee_paid,
               x_orig_fee_paid          => r8_tab(i).orig_fee_paid,
               x_resp_record_status     => 'N',
               x_layout_owner_code_txt  => r8_tab(i).layout_owner_code_txt,
               x_layout_version_code_txt=> r8_tab(i).layout_version_code_txt,
               x_record_code_txt        => r8_tab(i).record_code_txt
--	       x_direct_to_borr_flag     => NVL(r8_tab(i).direct_to_borr_flag,'N')
         );
         gv_debug_str := '';
    END LOOP;

  --Delete the Disbursement records from the PL/SQL Table after inserting into CL_RESP_R8 Table.
  gv_debug_str := gv_debug_str || 'INSERT_INTO_RESP1 - 14' || ' ';
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.insert_into_resp1.debug',gv_debug_str);
  END IF;
  r8_tab.delete;
  gv_debug_str := '';

   -- inserting into response r2,r3,r7 and igf_sl_clchrs_dtls tables
   IF v_tab_resp_r2.COUNT > 0 THEN
     l_n_ctr_r2 := 0;
     log_to_fnd(p_v_module => 'insert_into_resp_r1',
                p_v_string => 'looping thru v_tab_resp_r2'
               );
     FOR l_n_ctr_r2 IN v_tab_resp_r2.FIRST .. v_tab_resp_r2.LAST
     LOOP
       insert_into_resp_r2(
         p_r2_record   =>  v_tab_resp_r2(l_n_ctr_r2)
       );
     END LOOP;
     IF v_tab_resp_r2.EXISTS(1) THEN
       v_tab_resp_r2.DELETE;
     END IF;
   END IF;
   IF v_tab_resp_r3.COUNT > 0 THEN
     l_n_ctr_r3 := 0;
     log_to_fnd(p_v_module => 'insert_into_resp_r1',
                p_v_string => 'looping thru v_tab_resp_r3'
               );
     FOR l_n_ctr_r3 IN v_tab_resp_r3.FIRST .. v_tab_resp_r3.LAST
     LOOP
       insert_into_resp_r3(
         p_r3_record   =>  v_tab_resp_r3(l_n_ctr_r3)
        );
     END LOOP;
     IF v_tab_resp_r3.EXISTS(1) THEN
       v_tab_resp_r3.DELETE;
     END IF;
   END IF;
   IF v_tab_resp_r7.COUNT > 0 THEN
     l_n_ctr_r7 := 0;
      log_to_fnd(p_v_module => 'insert_into_resp_r1',
                 p_v_string => 'looping thru v_tab_resp_r7'
                );
     FOR l_n_ctr_r7 IN v_tab_resp_r7.FIRST .. v_tab_resp_r7.LAST
     LOOP
       insert_into_resp_r7(
         p_r7_record   =>  v_tab_resp_r7(l_n_ctr_r7)
       );
     END LOOP;
     IF v_tab_resp_r7.EXISTS(1) THEN
       v_tab_resp_r7.DELETE;
     END IF;
   END IF;
   IF g_v_cl_version = 'RELEASE-4' THEN
     IF v_tab_clchrs_dtls.COUNT > 0 THEN
       l_n_ctr_r6 := 0;
      log_to_fnd(p_v_module => 'insert_into_resp_r1',
                 p_v_string => 'looping thru v_tab_clchrs_dtls'
                );
       FOR l_n_ctr_r6 IN v_tab_clchrs_dtls.FIRST .. v_tab_clchrs_dtls.LAST
       LOOP
         insert_into_resp_r6(
           p_r6_record   =>  v_tab_clchrs_dtls(l_n_ctr_r6)
         );
       END LOOP;
       IF v_tab_clchrs_dtls.EXISTS(1) THEN
         v_tab_clchrs_dtls.DELETE;
       END IF;
     END IF;
   END IF;
EXCEPTION
 WHEN app_exception.record_lock_exception THEN
     RAISE;
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_CL_ACK.INSERT_INTO_RESP1');
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.insert_into_resp1.exception',gv_debug_str||' '|| SQLERRM);
     END IF;
     gv_debug_str := '';
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
END insert_into_resp1;


-- MAIN PROCEDURE

PROCEDURE process_ack(
 errbuf               OUT NOCOPY  VARCHAR2,
 retcode              OUT NOCOPY  NUMBER,
 p_c_update_disb_dtls IN          VARCHAR2
 )
AS
/***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/12/07
   Purpose          :    To process all the @1 Records
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who              When      What
   masehgal             17-Feb-2002     # 2216956  FACR007
                                        Added Elec_mpn_ind , Borrow_sign_ind in igf_sl_cl_resp_r1
 ***************************************************************/
     l_msg               NUMBER;
     l_mesg              VARCHAR2(100);
     l_rowid             VARCHAR2(25);
     l_index             NUMBER;
     lb_rejected_rec     BOOLEAN;
     -- Array to maintain the Error Messages

     TYPE t_message IS TABLE OF igf_sl_cl_resp_r1_all.err_mesg_2%TYPE
     INDEX BY BINARY_INTEGER;

     err_mesg_array      t_message;

     --Select the Error Messages from Edit Report
     CURSOR c_reject (p_chg_code igf_sl_edit_report_v.orig_chg_code%TYPE)
     IS
      SELECT rpad(field_desc,50)||sl_error_desc reject_desc FROM igf_sl_edit_report_v
      WHERE  loan_number       = loaded_1rec.loan_number
             AND orig_chg_code = p_chg_code
             ORDER BY edtr_id;

     lb_print_mess BOOLEAN;
     l_log_mesg  VARCHAR2(1000);

BEGIN

  -- Assigning to global variable as the same is being used
  -- to conditionally invoke the upd_disb_details
    g_c_update_disb_dtls := p_c_update_disb_dtls ;

    gv_debug_str := '';

    gv_debug_str := 'MAIN - 1' || ' ';
    retcode := 0;
    gv_debug_str := gv_debug_str || 'MAIN - 2' || ' ';
    igf_aw_gen.set_org_id(NULL);
    gv_debug_str := gv_debug_str || 'MAIN - 3' || ' ';

    --
    -- Load the Datafile into the Interface tables.
    --
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.process_ack.debug',gv_debug_str);
    END IF;
    cl_load_file;
    gv_debug_str := '';

    --
    -- Fetch the @1 and @8Records for Processing after the Load File procedure has inserted the data from the
    -- CommonLine Response File into the Response 1 and Response 8 Tables
    --

    FOR loaded_1rec_temp IN cur_resp1_records(g_cbth_id,'N')
    LOOP

        loaded_1rec    := loaded_1rec_temp;
        l_loan_number  := NULL;
        lb_rejected_rec := FALSE;
        lb_print_mess   := TRUE;
        l_loan_number  := loaded_1rec.loan_number;

        fnd_file.new_line(fnd_file.log,1);
        fnd_message.set_name('IGF','IGF_SL_CL_INS_RESP_REC');
        fnd_message.set_token('LOAN_NUMBER', l_loan_number);
        fnd_file.put_line(fnd_file.log,fnd_message.get);

        gv_debug_str := gv_debug_str || 'MAIN - 9' || ' ';
        l_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_SSN')      ||' : '||loaded_1rec.s_ssn;
        fnd_file.put_line(fnd_file.log, l_log_mesg);
        l_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_FULL_NAME')||' : '
                                                          ||loaded_1rec.s_first_name||' '||loaded_1rec.s_last_name;
        fnd_file.put_line(fnd_file.log, l_log_mesg);
--MN 16-Dec-2004 15:25 Log Borrower Name and SS as well.
        l_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','B_SSN')      ||' : '||loaded_1rec.b_ssn;
        fnd_file.put_line(fnd_file.log, l_log_mesg);
        l_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','B_FULL_NAME')||' : '
                                                          ||loaded_1rec.b_first_name||' '||loaded_1rec.b_last_name;
        fnd_file.put_line(fnd_file.log, l_log_mesg);
        --
        -- Delete records from Edit Report table with type="R" (Rejections) for this Loan Number
        --
        gv_debug_str := gv_debug_str || 'MAIN - 5' || ' ';
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.process_ack.debug',gv_debug_str);
        END IF;

        igf_sl_edit.delete_edit(l_loan_number, 'R');
        gv_debug_str := '';


        -- Need to insert all the Error Messages in the current @1 record into Edit Table
        -- Since there are Possiblly 5 Messages in the same record we need to insert them individually
        --
         gv_debug_str := gv_debug_str || 'MAIN - 6' || ' ';
         err_mesg_array.delete;
         gv_debug_str := gv_debug_str || 'MAIN - 7' || ' ';
         l_msg:=0;

         IF loaded_1rec.err_mesg_1 IS NOT NULL THEN
           l_msg:=l_msg+1;
           err_mesg_array(l_msg):=loaded_1rec.err_mesg_1;
         END IF;

         IF loaded_1rec.err_mesg_2 IS NOT NULL THEN
           l_msg:=l_msg+1;
           err_mesg_array(l_msg):=loaded_1rec.err_mesg_2;
         END IF;

         IF loaded_1rec.err_mesg_3 IS NOT NULL THEN
            l_msg:=l_msg+1;
            err_mesg_array(l_msg):=loaded_1rec.err_mesg_3;
         END IF;

         IF loaded_1rec.err_mesg_4 IS NOT NULL THEN
            l_msg:=l_msg+1;
            err_mesg_array(l_msg):=loaded_1rec.err_mesg_4;
         END IF;

         IF loaded_1rec.err_mesg_5 IS NOT NULL THEN
            l_msg:=l_msg+1;
            err_mesg_array(l_msg):=loaded_1rec.err_mesg_5;
         END IF;


         FOR l_index IN 1..l_msg LOOP
           --
           -- Insert Message
           --
           gv_debug_str := gv_debug_str || 'MAIN - 8' || ' ';
           igf_sl_edit.insert_edit(loaded_1rec.loan_number,
                                   'R',
                                   'IGF_SL_CL_ERROR',
                                   err_mesg_array(l_index),'','');
           gv_debug_str := '';
         END LOOP;
         FOR rej_rec IN c_reject('R') LOOP
           IF lb_print_mess THEN
             fnd_message.set_name('IGF','IGF_SL_CL_PRIN_REJ_DT');
             fnd_file.new_line(fnd_file.log,1);
             fnd_file.put_line(fnd_file.log,fnd_message.get);
             lb_rejected_rec := TRUE;
           END IF;
           lb_print_mess := FALSE;
           gv_debug_str := gv_debug_str || 'MAIN - 10' || ' ';
           fnd_file.put_line(fnd_file.log,'    '||rej_rec.reject_desc);
           gv_debug_str := '';
         END LOOP;
             --
             -- Call Procedure to update the LOR Table
             --

             gv_debug_str := gv_debug_str || 'MAIN - 11' || ' ';
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.process_ack.debug',gv_debug_str);
             END IF;
             fnd_file.new_line(fnd_file.log,1);
             update_lor(loaded_1rec.clrp1_id,l_loan_number,lb_rejected_rec);
             gv_debug_str := '';
        --
        -- Update the all the Response Record Status to 'Y'
        -- to indicate the Records have been processed for this Batch Id
        --

         igf_sl_cl_resp_r1_pkg.update_row (
           X_Mode                              => 'R',
           x_rowid                             => loaded_1rec.row_id,
           x_clrp1_id                          => loaded_1rec.clrp1_id,
           x_cbth_id                           => loaded_1rec.cbth_id,
           x_rec_code                          => loaded_1rec.rec_code,
           x_rec_type_ind                      => loaded_1rec.rec_type_ind,
           x_b_last_name                       => loaded_1rec.b_last_name,
           x_b_first_name                      => loaded_1rec.b_first_name,
           x_b_middle_name                     => loaded_1rec.b_middle_name,
           x_b_ssn                             => loaded_1rec.b_ssn,
           x_b_permt_addr1                     => loaded_1rec.b_permt_addr1,
           x_b_permt_addr2                     => loaded_1rec.b_permt_addr2,
           x_b_permt_city                      => loaded_1rec.b_permt_city,
           x_b_permt_state                     => loaded_1rec.b_permt_state,
           x_b_permt_zip                       => loaded_1rec.b_permt_zip,
           x_b_permt_zip_suffix                => loaded_1rec.b_permt_zip_suffix,
           x_b_permt_phone                     => loaded_1rec.b_permt_phone,
           x_b_date_of_birth                   => loaded_1rec.b_date_of_birth,
           x_cl_loan_type                      => loaded_1rec.cl_loan_type,
           x_req_loan_amt                      => loaded_1rec.req_loan_amt,
           x_defer_req_code                    => loaded_1rec.defer_req_code,
           x_borw_interest_ind                 => loaded_1rec.borw_interest_ind,
           x_eft_auth_code                     => loaded_1rec.eft_auth_code,
           x_b_signature_code                  => loaded_1rec.b_signature_code,
           x_b_signature_date                  => loaded_1rec.b_signature_date,
           x_loan_number                       => loaded_1rec.loan_number,
           x_cl_seq_number                     => loaded_1rec.cl_seq_number,
           x_b_citizenship_status              => loaded_1rec.b_citizenship_status,
           x_b_state_of_legal_res              => loaded_1rec.b_state_of_legal_res,
           x_b_legal_res_date                  => loaded_1rec.b_legal_res_date,
           x_b_default_status                  => loaded_1rec.b_default_status,
           x_b_outstd_loan_code                => loaded_1rec.b_outstd_loan_code,
           x_b_indicator_code                  => loaded_1rec.b_indicator_code,
           x_s_last_name                       => loaded_1rec.s_last_name,
           x_s_first_name                      => loaded_1rec.s_first_name,
           x_s_middle_name                     => loaded_1rec.s_middle_name,
           x_s_ssn                             => loaded_1rec.s_ssn,
           x_s_date_of_birth                   => loaded_1rec.s_date_of_birth,
           x_s_citizenship_status              => loaded_1rec.s_citizenship_status,
           x_s_default_code                    => loaded_1rec.s_default_code,
           x_s_signature_code                  => loaded_1rec.s_signature_code,
           x_school_id                         => loaded_1rec.school_id,
           x_loan_per_begin_date               => loaded_1rec.loan_per_begin_date,
           x_loan_per_end_date                 => loaded_1rec.loan_per_end_date,
           x_grade_level_code                  => loaded_1rec.grade_level_code,
           x_enrollment_code                   => loaded_1rec.enrollment_code,
           x_anticip_compl_date                => loaded_1rec.anticip_compl_date,
           x_coa_amt                           => loaded_1rec.coa_amt,
           x_efc_amt                           => loaded_1rec.efc_amt,
           x_est_fa_amt                        => loaded_1rec.est_fa_amt,
           x_fls_cert_amt                      => loaded_1rec.fls_cert_amt,
           x_flu_cert_amt                      => loaded_1rec.flu_cert_amt,
           x_flp_cert_amt                      => loaded_1rec.flp_cert_amt,
           x_sch_cert_date                     => loaded_1rec.sch_cert_date,
           x_alt_cert_amt                      => loaded_1rec.alt_cert_amt,
           x_alt_appl_ver_code                 => loaded_1rec.alt_appl_ver_code,
           x_duns_school_id                    => loaded_1rec.duns_school_id,
           x_lender_id                         => loaded_1rec.lender_id,
           x_fls_approved_amt                  => loaded_1rec.fls_approved_amt,
           x_flu_approved_amt                  => loaded_1rec.flu_approved_amt,
           x_flp_approved_amt                  => loaded_1rec.flp_approved_amt,
           x_alt_approved_amt                  => loaded_1rec.alt_approved_amt,
           x_duns_lender_id                    => loaded_1rec.duns_lender_id,
           x_guarantor_id                      => loaded_1rec.guarantor_id,
           x_fed_appl_form_code                => loaded_1rec.fed_appl_form_code,
           x_duns_guarnt_id                    => loaded_1rec.duns_guarnt_id,
           x_lend_blkt_guarnt_ind              => loaded_1rec.lend_blkt_guarnt_ind,
           x_lend_blkt_guarnt_appr_date        => loaded_1rec.lend_blkt_guarnt_appr_date,
           x_guarnt_adj_ind                    => loaded_1rec.guarnt_adj_ind,
           x_guarantee_date                    => loaded_1rec.guarantee_date,
           x_guarantee_amt                     => loaded_1rec.guarantee_amt,
           x_req_serial_loan_code              => loaded_1rec.req_serial_loan_code,
           x_borw_confirm_ind                  => loaded_1rec.borw_confirm_ind,
           x_b_license_state                   => loaded_1rec.b_license_state,
           x_b_license_number                  => loaded_1rec.b_license_number,
           x_b_ref_code                        => loaded_1rec.b_ref_code,
           x_pnote_delivery_code               => loaded_1rec.pnote_delivery_code,
           x_b_foreign_postal_code             => loaded_1rec.b_foreign_postal_code,
           x_lend_non_ed_brc_id                => loaded_1rec.lend_non_ed_brc_id,
           x_last_resort_lender                => loaded_1rec.last_resort_lender,
           x_resp_to_orig_code                 => loaded_1rec.resp_to_orig_code,
           x_err_mesg_1                        => loaded_1rec.err_mesg_1,
           x_err_mesg_2                        => loaded_1rec.err_mesg_2,
           x_err_mesg_3                        => loaded_1rec.err_mesg_3,
           x_err_mesg_4                        => loaded_1rec.err_mesg_4,
           x_err_mesg_5                        => loaded_1rec.err_mesg_5,
           x_guarnt_amt_redn_code              => loaded_1rec.guarnt_amt_redn_code,
           x_tot_outstd_stafford               => loaded_1rec.tot_outstd_stafford,
           x_tot_outstd_plus                   => loaded_1rec.tot_outstd_plus,
           x_b_permt_addr_chg_date             => loaded_1rec.b_permt_addr_chg_date,
           x_alt_prog_type_code                => loaded_1rec.alt_prog_type_code,
           x_alt_borw_tot_debt                 => loaded_1rec.alt_borw_tot_debt,
           x_act_interest_rate                 => loaded_1rec.act_interest_rate,
           x_prc_type_code                     => loaded_1rec.prc_type_code,
           x_service_type_code                 => loaded_1rec.service_type_code,
           x_rev_notice_of_guarnt              => loaded_1rec.rev_notice_of_guarnt,
           x_sch_refund_amt                    => loaded_1rec.sch_refund_amt,
           x_sch_refund_date                   => loaded_1rec.sch_refund_date,
           x_guarnt_status_code                => loaded_1rec.guarnt_status_code,
           x_lender_status_code                => loaded_1rec.lender_status_code,
           x_pnote_status_code                 => loaded_1rec.pnote_status_code,
           x_credit_status_code                => loaded_1rec.credit_status_code,
           x_guarnt_status_date                => loaded_1rec.guarnt_status_date,
           x_lender_status_date                => loaded_1rec.lender_status_date,
           x_pnote_status_date                 => loaded_1rec.pnote_status_date,
           x_credit_status_date                => loaded_1rec.credit_status_date,
           x_act_serial_loan_code              => loaded_1rec.act_serial_loan_code,
           x_amt_avail_for_reinst              => loaded_1rec.amt_avail_for_reinst,
           x_sch_non_ed_brc_id                 => loaded_1rec.sch_non_ed_brc_id,
           x_uniq_layout_vend_code             => loaded_1rec.uniq_layout_vend_code,
           x_uniq_layout_ident_code            => loaded_1rec.uniq_layout_ident_code,
           x_resp_record_status                => 'Y',
           x_stud_sign_ind                     => loaded_1rec.stud_sign_ind,
           x_borr_credit_auth_code             => loaded_1rec.borr_credit_auth_code,
           x_borr_sign_ind                     => loaded_1rec.borr_sign_ind,
           x_mpn_confirm_ind                   => loaded_1rec.mpn_confirm_ind,
           x_lender_use_txt                    => loaded_1rec.lender_use_txt,
           x_guarantor_use_txt                 => loaded_1rec.guarantor_use_txt,
           x_appl_loan_phase_code              => loaded_1rec.appl_loan_phase_code,
           x_appl_loan_phase_code_chg          => loaded_1rec.appl_loan_phase_code_chg,
           x_cl_rec_status                     => loaded_1rec.cl_rec_status,
           x_cl_rec_status_last_update         => loaded_1rec.cl_rec_status_last_update,
           x_lend_apprv_denied_code            => loaded_1rec.lend_apprv_denied_code,
           x_lend_apprv_denied_date            => loaded_1rec.lend_apprv_denied_date,
           x_cl_version_code                   => loaded_1rec.cl_version_code,
           x_school_use_txt                    => loaded_1rec.school_use_txt ,
           x_b_alien_reg_num_txt               => loaded_1rec.b_alien_reg_num_txt,
           x_esign_src_typ_cd                  => loaded_1rec.esign_src_typ_cd

         );

         gv_debug_str := '';

         -- invoke the procedure related to processing of change response records
         -- applicable for RELEASE-4 only.
         IF loaded_1rec.cl_version_code = 'RELEASE-4' THEN
           process_change_records (p_n_clrp1_id     =>  loaded_1rec.clrp1_id,
                                   p_v_loan_number  =>  loaded_1rec.loan_number);
           --
           -- update loan status for change record
           --
           igf_sl_gen.update_cl_chg_status(loaded_1rec.loan_number);
         END IF;

     END LOOP;

     COMMIT;


EXCEPTION

WHEN batch_exceptions THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := NULL;

WHEN app_exception.record_lock_exception THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
       igs_ge_msg_stack.conc_exception_hndl;
WHEN OTHERS THEN
       ROLLBACK;
       RETCODE := 2;
       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_SL_CL_ORIG_ACK.PROCESS_ACK');
       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.process_ack.exception',gv_debug_str||' '|| SQLERRM);
       END IF;
       gv_debug_str := '';
       errbuf := fnd_message.get;
       igs_ge_msg_stack.conc_exception_hndl;

END process_ack;


PROCEDURE update_lor(p_clrp1_id     igf_sl_cl_resp_r1_all.clrp1_id%TYPE,
                     p_loan_number  igf_sl_loans_all.loan_number%TYPE,
                     p_rejected_rec  BOOLEAN)
AS
/***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/12/07
   Purpose          :    To update the IGF_SL_LOR table
                    based on validations.
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who         When                   What
   bvisvana    21-Sep-2005            Bug # 4168692 - IGF_SL_CL_INV_COMB_RT_RC changed to IGF_SL_CL_INV_COMB_PT_RC
   ridas       17-Sep-2004            Bug #3691153: Query optimized by using the table igf_sl_cl_recipient
                                      instead of the view igf_sl_cl_recipient_v

   bkkumar     02-04-04               FACR116 - The lender related comparison not required when "ALT" Loan
   bkkumar     08-oct-2003            Bug 3104228
                                      a) Impact of adding the relationship_cd
                                      in igf_sl_lor_all table and obsoleting
                                      BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
                                      GUARANTOR_ID, DUNS_GUARNT_ID,
                                      LENDER_ID, DUNS_LENDER_ID
                                      LEND_NON_ED_BRC_ID, RECIPIENT_ID
                                      RECIPIENT_TYPE,DUNS_RECIP_ID
                                      RECIP_NON_ED_BRC_ID columns.
                                      b) The DUNS_BORW_LENDER_ID
                                      DUNS_GUARNT_ID
                                      DUNS_LENDER_ID
                                      DUNS_RECIP_ID columns are osboleted from the
                                      igf_sl_lor_loc_all table.

   bkkumar         18-sep-2003        Bug # 3104228 FA 122 Loan Enhancements
                                      In update_lor procedure changed the condition that
                                      loan status should be accepted if
                                      guarantee status is 20 or 40.
   agairola           15-Mar-2002     Modified the IGF_SL_LOANS_PKG update row call
                                      for Borrower Determination as part of Refunds DLD - 2144600
   masehgal           17-Feb-2002     # 2216956   FACR007
                                      Added Elec_mpn_ind , Borrow_sign_ind
 ***************************************************************/

l_row_id                 VARCHAR2(25);
l_log_mesg               VARCHAR2(1000);
l_loan_status            igf_sl_loans_all.loan_status%TYPE;
lv_defer_req_code           VARCHAR2(30);
lv_s_signature_code         VARCHAR2(30);
lv_stud_sign_ind            VARCHAR2(30);
lv_log_mesg                 VARCHAR2(100);

SKIP_UPDATE_LOANS EXCEPTION;
--
-- Select the LOR record for the current loan number
--

   CURSOR cur_tbh_lor
   IS
   SELECT *
   FROM   igf_sl_lor_v
   WHERE  loan_id IN (SELECT loan_id FROM igf_sl_loans_all
                      WHERE  NVL(external_loan_id_txt,loan_number) = p_loan_number);

--
-- Select the Loans Data for the particular Loan number
--
CURSOR cur_tbh_loans IS
    SELECT igf_sl_loans.* FROM igf_sl_loans
    WHERE NVL(external_loan_id_txt,loan_number)= p_loan_number FOR UPDATE OF loan_status NOWAIT;

  lv_lender_id        VARCHAR2(30);
  lv_lend_non_ed_id   VARCHAR2(30);
  lv_recipient_id     VARCHAR2(30);
  lv_recip_non_ed_id  VARCHAR2(30);
  lv_guarant_id       VARCHAR2(30);


-- Query optimized by using the table igf_sl_cl_recipient instead of the view igf_sl_cl_recipient_v (bug #3691153)
CURSOR cur_find_lender IS
  SELECT
  lender_id,
  lend_non_ed_brc_id,
  guarantor_id,
  recipient_id,
  recip_non_ed_brc_id,
  enabled,
  relationship_cd
  FROM
  igf_sl_cl_recipient
  WHERE
  lender_id            = lv_lender_id    AND
  guarantor_id         = lv_guarant_id   AND
  recipient_id         = lv_recipient_id AND
  NVL(lend_non_ed_brc_id,'*')   = NVL(lv_lend_non_ed_id,'*') AND
  NVL(recip_non_ed_brc_id,'*')  = NVL(lv_recip_non_ed_id,'*');

  find_lender_rec cur_find_lender%ROWTYPE;
  lb_info_change BOOLEAN;

CURSOR cur_find_rel_code(p_rel_code   VARCHAR2,
                         p_cal_type   VARCHAR2,
                         p_seq_number NUMBER)
IS
SELECT
relationship_cd
FROM
igf_sl_cl_setup_all
WHERE relationship_cd     =  p_rel_code
  AND ci_cal_type         =  p_cal_type
  AND ci_sequence_number  =  p_seq_number;

find_rel_code_rec  cur_find_rel_code%ROWTYPE;

CURSOR  c_igf_sl_loans (cp_v_loan_number igf_sl_loans_all.loan_number%TYPE) IS
SELECT  lar.loan_number
       ,lar.loan_status
       ,lar.loan_chg_status
FROM   igf_sl_loans_all lar
WHERE  NVL(external_loan_id_txt,loan_number) = cp_v_loan_number;

rec_c_igf_sl_loans c_igf_sl_loans%ROWTYPE;

BEGIN

    gv_debug_str := 'UPDATE_LOR - 1' || ' ';

    FOR tbh_rec IN cur_tbh_lor LOOP
        lv_lender_id       := loaded_1rec.lender_id;
        lv_guarant_id      := loaded_1rec.guarantor_id;
        lv_lend_non_ed_id  := loaded_1rec.lend_non_ed_brc_id;
        lv_recip_non_ed_id := tbh_rec.recip_non_ed_brc_id;
        lv_recipient_id    := tbh_rec.recipient_id;
        lb_info_change     := FALSE;


        IF (NOT p_rejected_rec AND tbh_rec.fed_fund_code <> 'ALT') THEN
           IF lv_lender_id IS NOT NULL
              AND tbh_rec.lender_id IS NOT NULL
              AND (lv_lender_id  <> tbh_rec.lender_id) THEN
              lb_info_change := TRUE;
              fnd_message.set_name('IGF','IGF_SL_CL_LEND_CHG_UPD');
              fnd_message.set_token('LOR_LEND_CODE',tbh_rec.lender_id);
              fnd_message.set_token('ACK_FILE_LEND',lv_lender_id);
              fnd_file.put_line(fnd_file.log,fnd_message.get);

              tbh_rec.lender_id       := lv_lender_id;
              tbh_rec.borw_lender_id  := lv_lender_id;

           END IF;
           IF lv_guarant_id IS NOT NULL
              AND tbh_rec.guarantor_id IS NOT NULL
              AND(lv_guarant_id <> tbh_rec.guarantor_id) THEN
              lb_info_change := TRUE;
              fnd_message.set_name('IGF','IGF_SL_CL_GURANT_CHG_UPD');
              fnd_message.set_token('LOR_GUARN_CODE',tbh_rec.guarantor_id);
              fnd_message.set_token('ACK_FILE_GUARN',lv_guarant_id);
              fnd_file.put_line(fnd_file.log,fnd_message.get);

              tbh_rec.guarantor_id := lv_guarant_id;

           END IF;
           IF NVL(lv_lend_non_ed_id,'*') <> NVL(tbh_rec.lend_non_ed_brc_id,'*') THEN
              lb_info_change := TRUE;
              fnd_message.set_name('IGF','IGF_SL_CL_LNDBR_CHG_UPD');
              fnd_message.set_token('LOR_LNBR_CODE',NVL(tbh_rec.lend_non_ed_brc_id,'NULL'));
              fnd_message.set_token('ACK_FILE_BRC',NVL(lv_lend_non_ed_id,'NULL'));
              fnd_file.put_line(fnd_file.log,fnd_message.get);

              tbh_rec.lend_non_ed_brc_id := lv_lend_non_ed_id;

           END IF;

           IF lb_info_change  THEN
              --
              -- Print Recipient Information
              --
              fnd_message.set_name('IGF','IGF_SL_CL_LOAN_RECIP_INFO');
              fnd_message.set_token('RECIP',lv_recipient_id);
              fnd_message.set_token('BRC_CD',NVL(lv_recip_non_ed_id,'NULL'));
              fnd_file.put_line(fnd_file.log,fnd_message.get);

              --
              -- Check if record exists for this combination
              --
              OPEN cur_find_lender;
              FETCH cur_find_lender INTO find_lender_rec;
              IF cur_find_lender%FOUND THEN
                 CLOSE cur_find_lender;
                 IF find_lender_rec.enabled = 'N' THEN
                   fnd_message.set_name('IGF','IGF_SL_CL_SKIP_UPD_EN_FALSE');
                   fnd_file.put_line(fnd_file.log,fnd_message.get);
                   fnd_file.new_line(fnd_file.log,1);

                   RAISE SKIP_UPDATE_LOANS;
                 ELSE
                  --
                  -- Check if the rel code record exists for AY
                  --
                  OPEN  cur_find_rel_code(find_lender_rec.relationship_cd,tbh_rec.ci_cal_type,tbh_rec.ci_sequence_number);
                  FETCH cur_find_rel_code INTO find_rel_code_rec;
                  IF cur_find_rel_code%FOUND THEN
                    CLOSE cur_find_rel_code;
                    fnd_message.set_name('IGF','IGF_SL_CL_LEND_INFO_UPD');
                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                    fnd_file.new_line(fnd_file.log,1);
                    tbh_rec.relationship_cd := find_lender_rec.relationship_cd;
                  ELSIF cur_find_rel_code%NOTFOUND THEN
                    CLOSE cur_find_rel_code;
                    fnd_message.set_name('IGF','IGF_SL_CL_SKIP_LND_AY_NOTFND');
                    fnd_message.set_token('REL_CODE',find_lender_rec.relationship_cd);
                    fnd_message.set_token('AWD_YR',tbh_rec.ci_alternate_code);
                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                    fnd_file.new_line(fnd_file.log,1);
                    RAISE SKIP_UPDATE_LOANS;
                  END IF;
                 END IF;
              ELSIF cur_find_lender%NOTFOUND THEN
                 CLOSE cur_find_lender;

                 fnd_message.set_name('IGF','IGF_SL_CL_SKIP_LND_NOTFND');
                 fnd_file.put_line(fnd_file.log,fnd_message.get);
                 fnd_file.new_line(fnd_file.log,1);

                 RAISE SKIP_UPDATE_LOANS;
              END IF;
           END IF;
        END IF; -- rejected rec condition

        IF loaded_1rec.rec_type_ind <> 'N' THEN -- not re-print req

          gv_debug_str := gv_debug_str || 'UPDATE_LOR - 2' || ' ';
          tbh_rec.cl_seq_number         :=   loaded_1rec.cl_seq_number;
          tbh_rec.borw_confirm_ind      :=   loaded_1rec.borw_confirm_ind;
          tbh_rec.service_type_code     :=   loaded_1rec.service_type_code;
          tbh_rec.rev_notice_of_guarnt  :=   loaded_1rec.rev_notice_of_guarnt;


          IF (loaded_1rec.guarantee_date IS NOT NULL AND tbh_rec.guarantee_date IS NULL)
          OR loaded_1rec.guarantee_date > tbh_rec.guarantee_date THEN
              gv_debug_str := gv_debug_str || 'UPDATE_LOR - 3' || ' ';
              tbh_rec.guarnt_adj_ind         :=   loaded_1rec.guarnt_adj_ind;
              tbh_rec.guarantee_amt          :=   loaded_1rec.guarantee_amt;
              tbh_rec.guarantee_date         :=   loaded_1rec.guarantee_date;
              tbh_rec.guarnt_amt_redn_code   :=   loaded_1rec.guarnt_amt_redn_code;
              tbh_rec.act_interest_rate      :=   loaded_1rec.act_interest_rate;

          END IF;

          --  In case the Guarantee Status in LOR is Guaranteed (equivalent code is 40 )
          --  then no updation of guarantee status code and date
/*
          IF ((loaded_1rec.guarnt_status_date IS NOT NULL AND tbh_rec.guarnt_status_date IS NULL)
              OR loaded_1rec.guarnt_status_date > tbh_rec.guarnt_status_date )
               AND NVL(tbh_rec.guarnt_status_code,'*') <> '40'  THEN
*/
          IF
               (tbh_rec.guarnt_status_code = '01' )
               OR
               (tbh_rec.guarnt_status_code = '05' AND  loaded_1rec.guarnt_status_code  <> '01')
               OR
               (tbh_rec.guarnt_status_code <>  '40'
                    AND loaded_1rec.guarnt_status_date > tbh_rec.guarnt_status_date
                    AND loaded_1rec.guarnt_status_code not in ('01','05'))
               OR
               (loaded_1rec.guarnt_status_date IS NOT NULL AND tbh_rec.guarnt_status_date IS NULL) THEN
              tbh_rec.guarnt_status_code:=loaded_1rec.guarnt_status_code;
              tbh_rec.guarnt_status_date:=loaded_1rec.guarnt_status_date;
              gv_debug_str := gv_debug_str || 'UPDATE_LOR - 4' || ' ';
          END IF;


          --  If the Lender status in LOR is Approved (equivalent code is 45)
          --  then updation of Lender status Code and Date is allowed only when the equivalent Lender Status Code
          --  in File is either 30 or 35

/*
          IF (loaded_1rec.lender_status_date IS NOT NULL AND tbh_rec.lend_status_date IS NULL)
          OR loaded_1rec.lender_status_date >tbh_rec.lend_status_date THEN
*/
          IF
               (tbh_rec.lend_status_code = '01' )
               OR
               (tbh_rec.lend_status_code = '05' AND  loaded_1rec.lender_status_code  <> '01')
               OR
               ((tbh_rec.lend_status_code <>  '45'OR (tbh_rec.lend_status_code = '45'
                    AND loaded_1rec.lender_status_code IN ('30', '35')))
                    AND loaded_1rec.lender_status_date > tbh_rec.lend_status_date
                    AND loaded_1rec.lender_status_code not in ('01','05'))
               OR
               (loaded_1rec.lender_status_date IS NOT NULL AND tbh_rec.lend_status_date IS NULL) THEN
                tbh_rec.lend_status_code := loaded_1rec.lender_status_code;
                tbh_rec.lend_status_date := loaded_1rec.lender_status_date;
                  gv_debug_str := gv_debug_str || 'UPDATE_LOR - 6' || ' ';
          END IF;


          IF (loaded_1rec.sch_refund_date IS NOT NULL AND tbh_rec.sch_refund_date IS NULL)
          OR loaded_1rec.sch_refund_date>tbh_rec.sch_refund_date THEN

             tbh_rec.sch_refund_amt  := loaded_1rec.sch_refund_amt;
             tbh_rec.sch_refund_date := loaded_1rec.sch_refund_date;
             gv_debug_str := gv_debug_str || 'UPDATE_LOR - 7' || ' ';

          END IF;

          IF ((loaded_1rec.credit_status_date IS NOT NULL AND tbh_rec.credit_decision_date IS NULL)
          OR loaded_1rec.credit_status_date >= tbh_rec.credit_decision_date )
          AND (loaded_1rec.credit_status_code <> '01' OR tbh_rec.credit_override IS NULL )  --pssahni 10-Jan-2005  	Code 01 may not overwrite any other code, regardless of the date stamp.
          THEN

             -- credit override reference has been replaced by column crdt_decision_status
             -- change was done as part of CL4 changes and as discussed with sachin
             tbh_rec.credit_override := loaded_1rec.credit_status_code;  -- pssahni it shd be credit_override as per FD instead of crdt_decision_status
             tbh_rec.crdt_decision_status := loaded_1rec.credit_status_code;  -- mnade - 19-Jan-2005
             tbh_rec.credit_decision_date := loaded_1rec.credit_status_date;
             gv_debug_str := gv_debug_str || 'UPDATE_LOR - 8' || ' ';

          END IF;

          IF  (loaded_1rec.pnote_status_date IS NOT NULL AND tbh_rec.pnote_status_date IS NULL)
          OR  loaded_1rec.pnote_status_date > tbh_rec.pnote_status_date THEN
                IF (tbh_rec.pnote_status < loaded_1rec.pnote_status_code)
                    OR tbh_rec.pnote_status IS NULL
                    OR ((tbh_rec.pnote_status = '60') AND  (loaded_1rec.pnote_status_code IN ('50','55')))
                THEN
                    gv_debug_str := gv_debug_str || 'UPDATE_LOR - 12' || ' ';
                    tbh_rec.pnote_status         := loaded_1rec.pnote_status_code;
                    tbh_rec.pnote_status_date    := loaded_1rec.pnote_status_date;
                    tbh_rec.act_serial_loan_code := loaded_1rec.act_serial_loan_code;

                END IF;
          END IF;

          -- Procedure call to compare the Disbursement Information in the Awards Disbursement and the newly
          -- inserted Disbursement Information

          gv_debug_str := gv_debug_str || 'UPDATE_LOR - 10' || ' ';
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.update_lor.debug',gv_debug_str);
          END IF;
         --Procedure call to compare the Alternate Borrow Details
          gv_debug_str := '';
          gv_debug_str := gv_debug_str || 'UPDATE_LOR - 11' || ' ';
          show_alt_details(p_clrp1_id,tbh_rec.loan_id);

          --IN case the Record Type Indicator in File is not N the following updations should
          --be done

          ELSIF  loaded_1rec.rec_type_ind='N' THEN

            IF  ((loaded_1rec.pnote_status_date IS NOT NULL AND tbh_rec.pnote_status_date IS NULL)
            OR  loaded_1rec.pnote_status_date > tbh_rec.pnote_status_date )
            THEN
                -- pssahni 10-Jan-2005
                -- A code may not be overwritten with a lower value code, regardless of date stamp
                -- Code 60 may not be overwritten by any code except 50 and 55 regardless of the date stamp
                -- bvisvana - Bug # 4121689 - Added a OR condition tbh_rec.pnote_status IS NULL
                IF (tbh_rec.pnote_status < loaded_1rec.pnote_status_code)
                OR (tbh_rec.pnote_status IS NULL)
                OR ((tbh_rec.pnote_status = '60') AND  (loaded_1rec.pnote_status_code IN ('50','55')))
                THEN
                    gv_debug_str := gv_debug_str || 'UPDATE_LOR - 12' || ' ';
                    tbh_rec.pnote_status         := loaded_1rec.pnote_status_code;
                    tbh_rec.pnote_status_date    := loaded_1rec.pnote_status_date;
                    tbh_rec.act_serial_loan_code := loaded_1rec.act_serial_loan_code;
                END IF;

            END IF;
            gv_debug_str := gv_debug_str || 'UPDATE_LOR - 13' || ' ';
        END IF;  -- Check for Reprint Request or not ends here

     OPEN  c_igf_sl_loans (cp_v_loan_number => loaded_1rec.loan_number);
     FETCH c_igf_sl_loans INTO rec_c_igf_sl_loans ;
     CLOSE c_igf_sl_loans ;

     IF loaded_1rec.cl_version_code = 'RELEASE-5' THEN
       IF loaded_1rec.rec_type_ind = 'S' THEN
         IF (rec_c_igf_sl_loans.loan_status <> 'S') THEN
           fnd_message.set_name('IGF','IGF_SL_CL_SKIP_SENT');
           fnd_message.set_token('LOAN_STATUS',rec_c_igf_sl_loans.loan_status);
           fnd_file.put_line(fnd_file.log, fnd_message.get);
           log_to_fnd(p_v_module => 'UPDATE_LOR',
                      p_v_string => ' loan status <> S'
                     );
           RAISE skip_update_loans;
         END IF;
         IF ((rec_c_igf_sl_loans.loan_status = 'S') AND
             (tbh_rec.rec_type_ind IN ('A','C','T')) ) THEN
             NULL;
         ELSE
           fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_RT_RC');
           fnd_file.put_line(fnd_file.log, fnd_message.get);
           log_to_fnd(p_v_module => 'UPDATE_LOR',
                      p_v_string => ' loan status <> S and lor rec_type_ind NOT IN (A,C,T)'
                     );
           RAISE skip_update_loans;
         END IF;
       END IF;
       IF loaded_1rec.rec_type_ind = 'X' THEN
         fnd_message.set_name('IGF','IGF_SL_CL_CHG_X_SPRT');
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         log_to_fnd(p_v_module => 'UPDATE_LOR',
                    p_v_string => ' Response Record type = X'
                   );
         RAISE skip_update_loans;
       END IF;
     END IF;

     IF loaded_1rec.cl_version_code = 'RELEASE-4' THEN
       -- 'R' Record can be uploaded into the system only if the Loan Status is "Accepted" and
       -- Loan Change Status is "Sent"
       IF loaded_1rec.rec_type_ind = 'R' THEN
         IF ((rec_c_igf_sl_loans.loan_status = 'A') AND (rec_c_igf_sl_loans.loan_chg_status = 'S')) THEN
           NULL;
         ELSE
           fnd_message.set_name('IGF','IGF_SL_CL_CHG_ST_SE_ACC');
           fnd_file.put_line(fnd_file.log, fnd_message.get);
           log_to_fnd(p_v_module => 'UPDATE_LOR',
                      p_v_string => ' R Record cannot be uploaded into the system. '||
                                    ' Loan status is not Accepted and Loan change status is not sent'
                     );
           RAISE skip_update_loans;
         END IF;
       END IF;
     END IF;
     -- common to both RELEASE-4 AND RELEASE-5
     IF loaded_1rec.rec_type_ind = 'N' THEN
       IF (rec_c_igf_sl_loans.loan_status <> 'S') THEN
         fnd_message.set_name('IGF','IGF_SL_CL_SKIP_SENT');
         fnd_message.set_token('LOAN_STATUS',rec_c_igf_sl_loans.loan_status);
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         log_to_fnd(p_v_module => 'UPDATE_LOR',
                   p_v_string => ' loan status <> S'
                  );
         RAISE skip_update_loans;
       END IF;
       IF ((rec_c_igf_sl_loans.loan_status = 'S') AND
           (tbh_rec.rec_type_ind = 'R') AND
           loaded_1rec.prc_type_code = 'GP') THEN
           NULL;
       ELSE
         -- bvisvana - Bug # 4168692 - IGF_SL_CL_INV_COMB_RT_RC changed to IGF_SL_CL_INV_COMB_PT_RC
         fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         log_to_fnd(p_v_module => 'UPDATE_LOR',
                    p_v_string => ' loan status <> S and lor rec_type_ind NOT IN (A,C,T)'
                   );
         RAISE skip_update_loans;
       END IF;
     END IF;
     IF loaded_1rec.rec_type_ind = 'M' THEN
       IF tbh_rec.rec_type_ind NOT IN ('A','C') THEN
         fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_RT_RC');
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         log_to_fnd(p_v_module => 'UPDATE_LOR',
                    p_v_string => ' send record type not in A and C'
                   );
         RAISE skip_update_loans;
       END IF;
       IF (rec_c_igf_sl_loans.loan_status NOT IN ('A','S')) THEN
         fnd_message.set_name('IGF','IGF_SL_CL_SKIP_SENT_M');
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         log_to_fnd(p_v_module => 'UPDATE_LOR',
                   p_v_string => ' loan status <> S'
                  );
         RAISE skip_update_loans;
       END IF;
     END IF;

      -- Update the Table with all the above arrived values
      -- bvisvana - FA 161 - Bug # 5006583
      IF loaded_1rec.cl_version_code IN ('RELEASE-4','RELEASE-5') THEN

       tbh_rec.actual_record_type_code := loaded_1rec.rec_type_ind;
       tbh_rec.cl_rec_status           := NVL(loaded_1rec.cl_rec_status,tbh_rec.cl_rec_status);
        lv_defer_req_code   :=  loaded_1rec.defer_req_code;
        lv_s_signature_code :=  loaded_1rec.s_signature_code;
        lv_stud_sign_ind    :=  loaded_1rec.stud_sign_ind;

        IF loaded_1rec.fed_appl_form_code IN ('Q','G') THEN
          IF(loaded_1rec.defer_req_code IS NOT NULL) THEN
            lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DEFER_REQ_CODE') ||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR','502');
            fnd_file.put_line(fnd_file.log, lv_log_mesg);
            lv_defer_req_code := NULL;
          END IF;
          IF(loaded_1rec.s_signature_code IS NOT NULL) THEN
            lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_SIGNATURE_CODE') ||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR','502');
            fnd_file.put_line(fnd_file.log, lv_log_mesg);
            lv_s_signature_code := NULL;
          END IF;
          IF(loaded_1rec.stud_sign_ind IS NOT NULL) THEN
            lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_ESIGN_IND_CODE') ||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR','502');
            fnd_file.put_line(fnd_file.log, lv_log_mesg);
            lv_stud_sign_ind  := NULL;
          END IF;
        END IF; -- loaded_1rec.fed_appl_form_code = 'Q'

        IF loaded_1rec.fed_appl_form_code = 'M' THEN
          IF(loaded_1rec.defer_req_code IS NOT NULL) THEN
            lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DEFER_REQ_CODE') ||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR','502');
            fnd_file.put_line(fnd_file.log, lv_log_mesg);
            lv_defer_req_code := NULL;
          END IF;
        END IF; -- loaded_1rec.fed_appl_form_code = 'M'
     END IF;

     igf_sl_lor_pkg.update_row (
          X_Mode                              => 'R'                                      ,
          x_rowid                             => tbh_rec.row_id                           ,
          x_origination_id                    => tbh_rec.origination_id                   ,
          x_loan_id                           => tbh_rec.loan_id                          ,
          x_sch_cert_date                     => tbh_rec.sch_cert_date                    ,
          x_orig_status_flag                  => tbh_rec.orig_status_flag                 ,
          x_orig_batch_id                     => tbh_rec.orig_batch_id                    ,
          x_orig_batch_date                   => tbh_rec.orig_batch_date                  ,
          x_chg_batch_id                      => tbh_rec.chg_batch_id                     ,
          x_orig_ack_date                     => tbh_rec.orig_ack_date                    ,
          x_credit_override                   => tbh_rec.credit_override           ,
          x_credit_decision_date              => tbh_rec.credit_decision_date           ,
          x_req_serial_loan_code              => tbh_rec.req_serial_loan_code             ,
          x_act_serial_loan_code              => loaded_1rec.act_serial_loan_code         ,
          x_pnote_delivery_code               => tbh_rec.pnote_delivery_code              ,
          x_pnote_status                      => tbh_rec.pnote_status            ,
          x_pnote_status_date                 => tbh_rec.pnote_status_date            ,
          x_pnote_id                          => tbh_rec.pnote_id                         ,
          x_pnote_print_ind                   => tbh_rec.pnote_print_ind                  ,
          x_pnote_accept_amt                  => tbh_rec.pnote_accept_amt                 ,
          x_pnote_accept_date                 => tbh_rec.pnote_accept_date                ,
          x_unsub_elig_for_heal               => tbh_rec.unsub_elig_for_heal              ,
          x_disclosure_print_ind              => tbh_rec.disclosure_print_ind             ,
          x_orig_fee_perct                    => tbh_rec.orig_fee_perct                   ,
          x_borw_confirm_ind                  => loaded_1rec.borw_confirm_ind             ,
          x_borw_interest_ind                 => tbh_rec.borw_interest_ind                ,
          x_borw_outstd_loan_code             => tbh_rec.borw_outstd_loan_code            ,
          x_unsub_elig_for_depnt              => tbh_rec.unsub_elig_for_depnt             ,
          x_guarantee_amt                     => loaded_1rec.guarantee_amt                ,
          x_guarantee_date                    => loaded_1rec.guarantee_date               ,
          x_guarnt_amt_redn_code              => loaded_1rec.guarnt_amt_redn_code         ,
          x_guarnt_status_code                => tbh_rec.guarnt_status_code           ,
          x_guarnt_status_date                => tbh_rec.guarnt_status_date           ,
          x_lend_apprv_denied_code            => loaded_1rec.lend_apprv_denied_code       ,
          x_lend_apprv_denied_date            => loaded_1rec.lend_apprv_denied_date       ,
          x_lend_status_code                  => tbh_rec.lend_status_code           ,
          x_lend_status_date                  => tbh_rec.lend_status_date           ,
          x_guarnt_adj_ind                    => loaded_1rec.guarnt_adj_ind               ,
          x_grade_level_code                  => tbh_rec.grade_level_code                 ,
          x_enrollment_code                   => tbh_rec.enrollment_code                  ,
          x_anticip_compl_date                => tbh_rec.anticip_compl_date               ,
          x_borw_lender_id                    => loaded_1rec.lender_id                    ,
          x_duns_borw_lender_id               => NULL                                     ,
          x_guarantor_id                      => loaded_1rec.guarantor_id                 ,
          x_duns_guarnt_id                    => NULL                                     ,
          x_prc_type_code                     => tbh_rec.prc_type_code                    ,
          x_cl_seq_number                     => loaded_1rec.cl_seq_number                ,
          x_last_resort_lender                => tbh_rec.last_resort_lender               ,
          x_lender_id                         => NULL                                     ,
          x_duns_lender_id                    => NULL                                     ,
          x_lend_non_ed_brc_id                => loaded_1rec.lend_non_ed_brc_id           ,
          x_recipient_id                      => NULL                                     ,
          x_recipient_type                    => NULL                                     ,
          x_duns_recip_id                     => NULL                                     ,
          x_recip_non_ed_brc_id               => NULL                                     ,
          x_rec_type_ind                      => tbh_rec.rec_type_ind                     ,
          x_cl_loan_type                      => tbh_rec.cl_loan_type                     ,
          x_cl_rec_status                     => tbh_rec.cl_rec_status                    ,
          x_cl_rec_status_last_update         => loaded_1rec.cl_rec_status_last_update    ,
          x_alt_prog_type_code                => tbh_rec.alt_prog_type_code               ,
          x_alt_appl_ver_code                 => tbh_rec.alt_appl_ver_code                ,
          x_mpn_confirm_code                  => loaded_1rec.mpn_confirm_ind              ,
          x_resp_to_orig_code                 => tbh_rec.resp_to_orig_code                ,
          x_appl_loan_phase_code              => loaded_1rec.appl_loan_phase_code         ,
          x_appl_loan_phase_code_chg          => loaded_1rec.appl_loan_phase_code_chg     ,
          x_appl_send_error_codes             => tbh_rec.appl_send_error_codes            ,
          x_tot_outstd_stafford               => tbh_rec.tot_outstd_stafford              ,
          x_tot_outstd_plus                   => tbh_rec.tot_outstd_plus                  ,
          x_alt_borw_tot_debt                 => tbh_rec.alt_borw_tot_debt                ,
          x_act_interest_rate                 => loaded_1rec.act_interest_rate            ,
          x_service_type_code                 => loaded_1rec.service_type_code            ,
          x_rev_notice_of_guarnt              => loaded_1rec.rev_notice_of_guarnt         ,
          x_sch_refund_amt                    => loaded_1rec.sch_refund_amt               ,
          x_sch_refund_date                   => loaded_1rec.sch_refund_date              ,
          x_uniq_layout_vend_code             => tbh_rec.uniq_layout_vend_code            ,
          x_uniq_layout_ident_code            => tbh_rec.uniq_layout_ident_code           ,
          x_p_person_id                       => tbh_rec.p_person_id                      ,
          x_p_ssn_chg_date                    => tbh_rec.p_ssn_chg_date                   ,
          x_p_dob_chg_date                    => tbh_rec.p_dob_chg_date                   ,
          x_p_permt_addr_chg_date             => tbh_rec.p_permt_addr_chg_date            ,
          x_p_default_status                  => tbh_rec.p_default_status                 ,
          x_p_signature_code                  => loaded_1rec.b_signature_code             ,
          x_p_signature_date                  => loaded_1rec.b_signature_date             ,
          x_s_ssn_chg_date                    => tbh_rec.s_ssn_chg_date                   ,
          x_s_dob_chg_date                    => tbh_rec.s_dob_chg_date                   ,
          x_s_permt_addr_chg_date             => tbh_rec.s_permt_addr_chg_date            ,
          x_s_local_addr_chg_date             => tbh_rec.s_local_addr_chg_date            ,
          x_s_default_status                  => tbh_rec.s_default_status                 ,
          x_s_signature_code                  => lv_s_signature_code             ,
          x_pnote_batch_id                    => tbh_rec.pnote_batch_id                   ,
          x_pnote_ack_date                    => tbh_rec.pnote_ack_date                   ,
          x_pnote_mpn_ind                     => tbh_rec.pnote_mpn_ind                    ,
          x_elec_mpn_ind                      => tbh_rec.elec_mpn_ind                     ,
          x_borr_sign_ind                     => loaded_1rec.borr_sign_ind                ,
          x_stud_sign_ind                     => lv_stud_sign_ind                ,
          x_borr_credit_auth_code             => loaded_1rec.borr_credit_auth_code        ,
          x_relationship_cd                   => tbh_rec.relationship_cd                  ,
          x_interest_rebate_percent_num       => tbh_rec.interest_rebate_percent_num      ,
          x_cps_trans_num                     => tbh_rec.cps_trans_num                    ,
          x_atd_entity_id_txt                 => tbh_rec.atd_entity_id_txt                ,
          x_rep_entity_id_txt                 => tbh_rec.rep_entity_id_txt                ,
          x_crdt_decision_status              => tbh_rec.crdt_decision_status             ,
          x_note_message                      => tbh_rec.note_message                     ,
          x_book_loan_amt                     => tbh_rec.book_loan_amt                    ,
          x_book_loan_amt_date                => tbh_rec.book_loan_amt_date               ,
          x_pymt_servicer_amt                 => tbh_rec.pymt_servicer_amt                ,
          x_pymt_servicer_date                => tbh_rec.pymt_servicer_date               ,
          x_external_loan_id_txt              => tbh_rec.external_loan_id_txt             ,
          x_deferment_request_code            => lv_defer_req_code               ,
          x_eft_authorization_code            => loaded_1rec.eft_auth_code                ,
          x_requested_loan_amt                => tbh_rec.requested_loan_amt               ,
          x_actual_record_type_code           => tbh_rec.actual_record_type_code          ,
          x_reinstatement_amt                 => loaded_1rec.amt_avail_for_reinst         ,
          x_school_use_txt                    => loaded_1rec.school_use_txt               ,
          x_lender_use_txt                    => loaded_1rec.lender_use_txt               ,
          x_guarantor_use_txt                 => loaded_1rec.guarantor_use_txt            ,
          x_fls_approved_amt                  => loaded_1rec.fls_approved_amt             ,
          x_flu_approved_amt                  => loaded_1rec.flu_approved_amt             ,
          x_flp_approved_amt                  => loaded_1rec.flp_approved_amt             ,
          x_alt_approved_amt                  => loaded_1rec.alt_approved_amt             ,
          x_loan_app_form_code                => loaded_1rec.fed_appl_form_code           ,
          x_override_grade_level_code         => tbh_rec.override_grade_level_code        ,
          x_acad_begin_date                   => tbh_rec.acad_begin_date                  ,
          x_acad_end_date                     => tbh_rec.acad_end_date                    ,
          x_b_alien_reg_num_txt               => loaded_1rec.b_alien_reg_num_txt          ,
          x_esign_src_typ_cd                  => NVL(tbh_rec.esign_src_typ_cd,loaded_1rec.esign_src_typ_cd)

        );

        gv_debug_str := gv_debug_str || 'UPDATE_LOR - 14' || ' ';
        --Update the LOR LOC Table with the values arrived from the above Validations between
        --File Data and LOR Data

        DECLARE
          CURSOR c_tbh_lor_rec
          IS
          SELECT lor_loc.*
          FROM igf_sl_lor_loc lor_loc
          WHERE loan_id = tbh_rec.loan_id FOR UPDATE OF loan_status NOWAIT;

     BEGIN

      FOR lorloc_rec in c_tbh_lor_rec LOOP
      gv_debug_str := gv_debug_str || 'UPDATE_LOR-15' ||' ';
         igf_sl_lor_loc_pkg.update_row (
              X_Mode                              => 'R'                                      ,
              x_rowid                             => lorloc_rec.row_id                        ,
              x_loan_id                           => lorloc_rec.loan_id                       ,
              x_origination_id                    => lorloc_rec.origination_id                ,
              x_loan_number                       => lorloc_rec.loan_number                   ,
              x_loan_type                         => lorloc_rec.loan_type                     ,
              x_loan_amt_offered                  => lorloc_rec.loan_amt_offered              ,
              x_loan_amt_accepted                 => lorloc_rec.loan_amt_accepted             ,
              x_loan_per_begin_date               => lorloc_rec.loan_per_begin_date           ,
              x_loan_per_end_date                 => lorloc_rec.loan_per_end_date             ,
              x_acad_yr_begin_date                => lorloc_rec.acad_yr_begin_date            ,
              x_acad_yr_end_date                  => lorloc_rec.acad_yr_end_date              ,
              x_loan_status                       => lorloc_rec.loan_status                   ,
              x_loan_status_date                  => lorloc_rec.loan_status_date              ,
              x_loan_chg_status                   => lorloc_rec.loan_chg_status               ,
              x_loan_chg_status_date              => lorloc_rec.loan_chg_status_date          ,
              x_req_serial_loan_code              => lorloc_rec.req_serial_loan_code          ,
              x_act_serial_loan_code              => loaded_1rec.act_serial_loan_code         ,
              x_active                            => lorloc_rec.active                        ,
              x_active_date                       => lorloc_rec.active_date                   ,
              x_sch_cert_date                     => lorloc_rec.sch_cert_date                 ,
              x_orig_status_flag                  => lorloc_rec.orig_status_flag              ,
              x_orig_batch_id                     => lorloc_rec.orig_batch_id                 ,
              x_orig_batch_date                   => lorloc_rec.orig_batch_date               ,
              x_chg_batch_id                      => lorloc_rec.chg_batch_id                  ,
              x_orig_ack_date                     => lorloc_rec.orig_ack_date                 ,
              x_credit_override                   => loaded_1rec.credit_status_code           ,
              x_credit_decision_date              => loaded_1rec.credit_status_date           ,
              x_pnote_delivery_code               => lorloc_rec.pnote_delivery_code           ,
              x_pnote_status                      => loaded_1rec.pnote_status_code            ,
              x_pnote_status_date                 => loaded_1rec.pnote_status_date            ,
              x_pnote_id                          => lorloc_rec.pnote_id                      ,
              x_pnote_print_ind                   => lorloc_rec.pnote_print_ind               ,
              x_pnote_accept_amt                  => lorloc_rec.pnote_accept_amt              ,
              x_pnote_accept_date                 => lorloc_rec.pnote_accept_date             ,
              x_p_signature_code                  => loaded_1rec.b_signature_code             ,
              x_p_signature_date                  => loaded_1rec.b_signature_date             ,
              x_s_signature_code                  => loaded_1rec.s_signature_code             ,
              x_unsub_elig_for_heal               => lorloc_rec.unsub_elig_for_heal           ,
              x_disclosure_print_ind              => lorloc_rec.disclosure_print_ind          ,
              x_orig_fee_perct                    => lorloc_rec.orig_fee_perct                ,
              x_borw_confirm_ind                  => loaded_1rec.borw_confirm_ind             ,
              x_borw_interest_ind                 => lorloc_rec.borw_interest_ind             ,
              x_unsub_elig_for_depnt              => lorloc_rec.unsub_elig_for_depnt          ,
              x_guarantee_amt                     => loaded_1rec.guarantee_amt                ,
              x_guarantee_date                    => loaded_1rec.guarantee_date               ,
              x_guarnt_adj_ind                    => loaded_1rec.guarnt_adj_ind               ,
              x_guarnt_amt_redn_code              => loaded_1rec.guarnt_amt_redn_code         ,
              x_guarnt_status_code                => loaded_1rec.guarnt_status_code           ,
              x_guarnt_status_date                => loaded_1rec.guarnt_status_date           ,
              x_lend_apprv_denied_code            => loaded_1rec.lend_apprv_denied_code       ,
              x_lend_apprv_denied_date            => loaded_1rec.lend_apprv_denied_date       ,
              x_lend_status_code                  => loaded_1rec.lender_status_code           ,
              x_lend_status_date                  => loaded_1rec.lender_status_date           ,
              x_grade_level_code                  => lorloc_rec.grade_level_code              ,
              x_enrollment_code                   => lorloc_rec.enrollment_code               ,
              x_anticip_compl_date                => lorloc_rec.anticip_compl_date            ,
              x_borw_lender_id                    => loaded_1rec.lender_id                    ,
              x_duns_borw_lender_id               => NULL                                     ,
              x_guarantor_id                      => loaded_1rec.guarantor_id                 ,
              x_duns_guarnt_id                    => NULL                                     ,
              x_prc_type_code                     => lorloc_rec.prc_type_code                 ,
              x_rec_type_ind                      => lorloc_rec.rec_type_ind                  ,
              x_cl_loan_type                      => lorloc_rec.cl_loan_type                  ,
              x_cl_seq_number                     => loaded_1rec.cl_seq_number                ,
              x_last_resort_lender                => lorloc_rec.last_resort_lender            ,
              x_lender_id                         => loaded_1rec.lender_id                    ,
              x_duns_lender_id                    => NULL                                     ,
              x_lend_non_ed_brc_id                => loaded_1rec.lend_non_ed_brc_id           ,
              x_recipient_id                      => lorloc_rec.recipient_id                  ,
              x_recipient_type                    => lorloc_rec.recipient_type                ,
              x_duns_recip_id                     => NULL                                     ,
              x_recip_non_ed_brc_id               => lorloc_rec.recip_non_ed_brc_id           ,
              x_cl_rec_status                     => tbh_rec.cl_rec_status                    ,
              x_cl_rec_status_last_update         => loaded_1rec.cl_rec_status_last_update    ,
              x_alt_prog_type_code                => lorloc_rec.alt_prog_type_code            ,
              x_alt_appl_ver_code                 => lorloc_rec.alt_appl_ver_code             ,
              x_borw_outstd_loan_code             => lorloc_rec.borw_outstd_loan_code         ,
              x_mpn_confirm_code                  => loaded_1rec.mpn_confirm_ind              ,
              x_resp_to_orig_code                 => lorloc_rec.resp_to_orig_code             ,
              x_appl_loan_phase_code              => loaded_1rec.appl_loan_phase_code         ,
              x_appl_loan_phase_code_chg          => loaded_1rec.appl_loan_phase_code_chg     ,
              x_tot_outstd_stafford               => lorloc_rec.tot_outstd_stafford           ,
              x_tot_outstd_plus                   => lorloc_rec.tot_outstd_plus               ,
              x_alt_borw_tot_debt                 => lorloc_rec.alt_borw_tot_debt             ,
              x_act_interest_rate                 => loaded_1rec.act_interest_rate            ,
              x_service_type_code                 => loaded_1rec.service_type_code            ,
              x_rev_notice_of_guarnt              => loaded_1rec.rev_notice_of_guarnt         ,
              x_sch_refund_amt                    => loaded_1rec.sch_refund_amt               ,
              x_sch_refund_date                   => loaded_1rec.sch_refund_date              ,
              x_uniq_layout_vend_code             => lorloc_rec.uniq_layout_vend_code         ,
              x_uniq_layout_ident_code            => lorloc_rec.uniq_layout_ident_code        ,
              x_p_person_id                       => lorloc_rec.p_person_id                   ,
              x_p_ssn                             => lorloc_rec.p_ssn                         ,
              x_p_ssn_chg_date                    => lorloc_rec.p_ssn_chg_date                ,
              x_p_last_name                       => lorloc_rec.p_last_name                   ,
              x_p_first_name                      => lorloc_rec.p_first_name                  ,
              x_p_middle_name                     => lorloc_rec.p_middle_name                 ,
              x_p_permt_addr1                     => lorloc_rec.p_permt_addr1                 ,
              x_p_permt_addr2                     => lorloc_rec.p_permt_addr2                 ,
              x_p_permt_city                      => lorloc_rec.p_permt_city                  ,
              x_p_permt_state                     => lorloc_rec.p_permt_state                 ,
              x_p_permt_zip                       => lorloc_rec.p_permt_zip                   ,
              x_p_permt_addr_chg_date             => lorloc_rec.p_permt_addr_chg_date         ,
              x_p_permt_phone                     => lorloc_rec.p_permt_phone                 ,
              x_p_email_addr                      => lorloc_rec.p_email_addr                  ,
              x_p_date_of_birth                   => lorloc_rec.p_date_of_birth               ,
              x_p_dob_chg_date                    => lorloc_rec.p_dob_chg_date                ,
              x_p_license_num                     => lorloc_rec.p_license_num                 ,
              x_p_license_state                   => lorloc_rec.p_license_state               ,
              x_p_citizenship_status              => lorloc_rec.p_citizenship_status          ,
              x_p_alien_reg_num                   => lorloc_rec.p_alien_reg_num               ,
              x_p_default_status                  => lorloc_rec.p_default_status              ,
              x_p_foreign_postal_code             => lorloc_rec.p_foreign_postal_code         ,
              x_p_state_of_legal_res              => lorloc_rec.p_state_of_legal_res          ,
              x_p_legal_res_date                  => lorloc_rec.p_legal_res_date              ,
              x_s_ssn                             => lorloc_rec.s_ssn                         ,
              x_s_ssn_chg_date                    => lorloc_rec.s_ssn_chg_date                ,
              x_s_last_name                       => lorloc_rec.s_last_name                   ,
              x_s_first_name                      => lorloc_rec.s_first_name                  ,
              x_s_middle_name                     => lorloc_rec.s_middle_name                 ,
              x_s_permt_addr1                     => lorloc_rec.s_permt_addr1                 ,
              x_s_permt_addr2                     => lorloc_rec.s_permt_addr2                 ,
              x_s_permt_city                      => lorloc_rec.s_permt_city                  ,
              x_s_permt_state                     => lorloc_rec.s_permt_state                 ,
              x_s_permt_zip                       => lorloc_rec.s_permt_zip                   ,
              x_s_permt_addr_chg_date             => lorloc_rec.s_permt_addr_chg_date         ,
              x_s_permt_phone                     => lorloc_rec.s_permt_phone                 ,
              x_s_local_addr1                     => lorloc_rec.s_local_addr1                 ,
              x_s_local_addr2                     => lorloc_rec.s_local_addr2                 ,
              x_s_local_city                      => lorloc_rec.s_local_city                  ,
              x_s_local_state                     => lorloc_rec.s_local_state                 ,
              x_s_local_zip                       => lorloc_rec.s_local_zip                   ,
              x_s_local_addr_chg_date             => lorloc_rec.s_local_addr_chg_date         ,
              x_s_email_addr                      => lorloc_rec.s_email_addr                  ,
              x_s_date_of_birth                   => lorloc_rec.s_date_of_birth               ,
              x_s_dob_chg_date                    => lorloc_rec.s_dob_chg_date                ,
              x_s_license_num                     => lorloc_rec.s_license_num                 ,
              x_s_license_state                   => lorloc_rec.s_license_state               ,
              x_s_depncy_status                   => lorloc_rec.s_depncy_status               ,
              x_s_default_status                  => lorloc_rec.s_default_status              ,
              x_s_citizenship_status              => lorloc_rec.s_citizenship_status          ,
              x_s_alien_reg_num                   => lorloc_rec.s_alien_reg_num               ,
              x_s_foreign_postal_code             => lorloc_rec.s_foreign_postal_code         ,
              x_pnote_batch_id                    => lorloc_rec.pnote_batch_id                ,
              x_pnote_ack_date                    => lorloc_rec.pnote_ack_date                ,
              x_pnote_mpn_ind                     => lorloc_rec.pnote_mpn_ind                 ,
              x_award_id                          => lorloc_rec.award_id                      ,
              x_base_id                           => lorloc_rec.base_id                       ,
              x_document_id_txt                   => lorloc_rec.document_id_txt               ,
              x_loan_key_num                      => lorloc_rec.loan_key_num                  ,
              x_interest_rebate_percent_num       => lorloc_rec.interest_rebate_percent_num   ,
              x_fin_award_year                    => lorloc_rec.fin_award_year                ,
              x_cps_trans_num                     => lorloc_rec.cps_trans_num                 ,
              x_atd_entity_id_txt                 => lorloc_rec.atd_entity_id_txt             ,
              x_rep_entity_id_txt                 => lorloc_rec.rep_entity_id_txt             ,
              x_source_entity_id_txt              => lorloc_rec.source_entity_id_txt          ,
              x_pymt_servicer_amt                 => lorloc_rec.pymt_servicer_amt             ,
              x_pymt_servicer_date                => lorloc_rec.pymt_servicer_date            ,
              x_book_loan_amt                     => lorloc_rec.book_loan_amt                 ,
              x_book_loan_amt_date                => lorloc_rec.book_loan_amt_date            ,
              x_s_chg_birth_date                  => lorloc_rec.s_chg_birth_date              ,
              x_s_chg_ssn                         => lorloc_rec.s_chg_ssn                     ,
              x_s_chg_last_name                   => lorloc_rec.s_chg_last_name               ,
              x_b_chg_birth_date                  => lorloc_rec.b_chg_birth_date              ,
              x_b_chg_ssn                         => lorloc_rec.b_chg_ssn                     ,
              x_b_chg_last_name                   => lorloc_rec.b_chg_last_name               ,
              x_note_message                      => lorloc_rec.note_message                  ,
              x_full_resp_code                    => lorloc_rec.full_resp_code                ,
              x_s_permt_county                    => lorloc_rec.s_permt_county                ,
              x_b_permt_county                    => lorloc_rec.b_permt_county                ,
              x_s_permt_country                   => lorloc_rec.s_permt_country               ,
              x_b_permt_country                   => lorloc_rec.b_permt_country               ,
              x_crdt_decision_status              => lorloc_rec.crdt_decision_status          ,
              x_external_loan_id_txt              => lorloc_rec.external_loan_id_txt          ,
              x_deferment_request_code            => loaded_1rec.defer_req_code               ,
              x_eft_authorization_code            => loaded_1rec.eft_auth_code                ,
              x_requested_loan_amt                => lorloc_rec.requested_loan_amt            ,
              x_actual_record_type_code           => tbh_rec.actual_record_type_code          ,
              x_reinstatement_amt                 => loaded_1rec.amt_avail_for_reinst         ,
              x_school_use_txt                    => loaded_1rec.school_use_txt               ,
              x_lender_use_txt                    => loaded_1rec.lender_use_txt               ,
              x_guarantor_use_txt                 => loaded_1rec.guarantor_use_txt            ,
              x_fls_approved_amt                  => loaded_1rec.fls_approved_amt             ,
              x_flu_approved_amt                  => loaded_1rec.flu_approved_amt             ,
              x_flp_approved_amt                  => loaded_1rec.flp_approved_amt             ,
              x_alt_approved_amt                  => loaded_1rec.alt_approved_amt             ,
              x_loan_app_form_code                => loaded_1rec.fed_appl_form_code           ,
              x_alt_borrower_ind_flag             => lorloc_rec.alt_borrower_ind_flag         ,
              x_school_id_txt                     => lorloc_rec.school_id_txt                 ,
              x_cost_of_attendance_amt            => lorloc_rec.cost_of_attendance_amt        ,
              x_expect_family_contribute_amt      => lorloc_rec.expect_family_contribute_amt  ,
              x_established_fin_aid_amount        => lorloc_rec.established_fin_aid_amount    ,
              x_borower_electronic_sign_flag      => loaded_1rec.borr_sign_ind                ,
              x_student_electronic_sign_flag      => loaded_1rec.stud_sign_ind                ,
              x_borower_credit_authoriz_flag      => loaded_1rec.borr_credit_auth_code        ,
              x_mpn_type_flag                     => lorloc_rec.mpn_type_flag                 ,
              x_esign_src_typ_cd                  => loaded_1rec.esign_src_typ_cd
            );
    gv_debug_str := '';
    END LOOP;

   END;


    -- Update the Loan Status in Loans Table  based on the below conditions
   l_loan_status := NULL;
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.update_lor.debug',gv_debug_str||' loaded_1rec.prc_type_code ' || loaded_1rec.prc_type_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.update_lor.debug',gv_debug_str||' tbh_rec.guarnt_status_code ' || tbh_rec.guarnt_status_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.update_lor.debug',gv_debug_str||' tbh_rec.lend_status_code ' || tbh_rec.lend_status_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.update_lor.debug',gv_debug_str||' tbh_rec.pnote_status ' || tbh_rec.pnote_status);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.update_lor.debug',gv_debug_str||' tbh_rec.credit_override ' || tbh_rec.crdt_decision_status );
   END IF;

   IF loaded_1rec.cl_version_code = 'RELEASE-5' THEN
     IF loaded_1rec.prc_type_code='GP' THEN
       -- loan status should be accepted if guarantee status is  40.
       IF ( tbh_rec.guarnt_status_code ='40' -- FA 122 Loans Enhancements
       AND tbh_rec.lend_status_code= '45'
       AND tbh_rec.pnote_status    = '60'
       AND tbh_rec.crdt_decision_status IN ('05','35')) THEN
         -- Loan is Accepted
         gv_debug_str := gv_debug_str || 'UPDATE_LOR-16' || ' ';
         l_loan_status:='A';
         fnd_message.set_name('IGF','IGF_SL_CL_LOAN_ACC');
         fnd_message.set_token('LOAN_NUMBER',loaded_1rec.loan_number);
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         fnd_file.new_line(fnd_file.log,1);
         log_to_fnd(p_v_module => 'update_lor',
                    p_v_string => ' Loan is Accepted'
                   );

       ELSIF (tbh_rec.guarnt_status_code ='30'
             OR tbh_rec.lend_status_code IN ('25','35')
             OR tbh_rec.crdt_decision_status  IN ('20','30')) THEN

         -- Loan is Rejected
         gv_debug_str := gv_debug_str || 'UPDATE_LOR-17' || ' ';
         l_loan_status:='R';
         fnd_message.set_name('IGF','IGF_SL_CL_LOAN_REJ');
         fnd_message.set_token('LOAN_NUMBER',loaded_1rec.loan_number);
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         fnd_file.new_line(fnd_file.log,1);
         log_to_fnd(p_v_module => 'update_lor',
                    p_v_string => ' Loan is Rejected'
                   );

       ELSIF (tbh_rec.guarnt_status_code='35'
             OR tbh_rec.lend_status_code='30') THEN

         -- Loan is Terminated
         l_loan_status:='T';
         fnd_message.set_name('IGF','IGF_SL_CL_LOAN_TER');
         fnd_message.set_token('LOAN_NUMBER',loaded_1rec.loan_number);
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         fnd_file.new_line(fnd_file.log,1);
         gv_debug_str := gv_debug_str || 'UPDATE_LOR-18' || ' ';

       END IF;
     END IF;    -- End of Condition of 'GP'
     IF loaded_1rec.prc_type_code='GO' THEN
       IF ( tbh_rec.guarnt_status_code ='40' AND
            tbh_rec.lend_status_code   = '45') THEN
         l_loan_status := 'A';
         fnd_message.set_name('IGF','IGF_SL_CL_LOAN_ACC');
         fnd_message.set_token('LOAN_NUMBER',loaded_1rec.loan_number);
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         fnd_file.new_line(fnd_file.log,1);
         log_to_fnd(p_v_module => 'update_lor',
                    p_v_string => ' Loan is Accepted'
                   );
       END IF;
       IF (tbh_rec.guarnt_status_code ='30'OR
           tbh_rec.lend_status_code IN ('25','35')) THEN
         l_loan_status:='R';
         fnd_message.set_name('IGF','IGF_SL_CL_LOAN_REJ');
         fnd_message.set_token('LOAN_NUMBER',loaded_1rec.loan_number);
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         fnd_file.new_line(fnd_file.log,1);
         log_to_fnd(p_v_module => 'update_lor',
                    p_v_string => ' Loan is Rejected'
                   );
       END IF;
       IF (tbh_rec.guarnt_status_code = '35') THEN
         -- Loan is Terminated
         l_loan_status:='T';
         fnd_message.set_name('IGF','IGF_SL_CL_LOAN_TER');
         fnd_message.set_token('LOAN_NUMBER',loaded_1rec.loan_number);
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         fnd_file.new_line(fnd_file.log,1);
         log_to_fnd(p_v_module => 'update_lor',
                    p_v_string => ' Loan is Terminated'
                   );
       END IF;
     END IF;
   END IF;

   IF loaded_1rec.cl_version_code = 'RELEASE-4' THEN
--MN 16-Dec-2004 15:27 Both G and B to be treated as Accepted for GP requests.
     IF ((loaded_1rec.prc_type_code='GP') AND (loaded_1rec.cl_rec_status in ('B', 'G'))) THEN
       l_loan_status := 'A';
       fnd_message.set_name('IGF','IGF_SL_CL_LOAN_ACC');
       fnd_message.set_token('LOAN_NUMBER',loaded_1rec.loan_number);
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       fnd_file.new_line(fnd_file.log,1);
       log_to_fnd(p_v_module => 'update_lor',
                  p_v_string => ' Loan is Accepted'
                 );
     END IF;
--MN 16-Dec-2004 15:27 Both G and B to be treated as Accepted for GO requests.
     IF ((loaded_1rec.prc_type_code='GO') AND (loaded_1rec.cl_rec_status in ('B', 'G'))) THEN
       l_loan_status := 'A';
       fnd_message.set_name('IGF','IGF_SL_CL_LOAN_ACC');
       fnd_message.set_token('LOAN_NUMBER',loaded_1rec.loan_number);
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       fnd_file.new_line(fnd_file.log,1);
       log_to_fnd(p_v_module => 'update_lor',
                  p_v_string => ' Loan is Accepted'
                 );
     END IF;
     IF ((loaded_1rec.prc_type_code='GP') AND (loaded_1rec.cl_rec_status = 'D')) THEN
       l_loan_status:='R';
       fnd_message.set_name('IGF','IGF_SL_CL_LOAN_REJ');
       fnd_message.set_token('LOAN_NUMBER',loaded_1rec.loan_number);
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       fnd_file.new_line(fnd_file.log,1);
       log_to_fnd(p_v_module => 'update_lor',
                  p_v_string => ' Loan is Rejected'
                 );
     END IF;
     IF ((loaded_1rec.prc_type_code='GO') AND (loaded_1rec.cl_rec_status = 'D')) THEN
       l_loan_status:='R';
       fnd_message.set_name('IGF','IGF_SL_CL_LOAN_REJ');
       fnd_message.set_token('LOAN_NUMBER',loaded_1rec.loan_number);
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       fnd_file.new_line(fnd_file.log,1);
       log_to_fnd(p_v_module => 'update_lor',
                  p_v_string => ' Loan is rejected'
                 );
     END IF;
     IF ((loaded_1rec.prc_type_code IN ('GO','GP')) AND (loaded_1rec.cl_rec_status = 'T')) THEN
       -- Loan is Terminated
       l_loan_status:='T';
       fnd_message.set_name('IGF','IGF_SL_CL_LOAN_TER');
       fnd_message.set_token('LOAN_NUMBER',loaded_1rec.loan_number);
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       fnd_file.new_line(fnd_file.log,1);
       log_to_fnd(p_v_module => 'update_lor',
                  p_v_string => ' Loan is Terminated'
                 );
     END IF;
   END IF;

   IF l_loan_status IS NOT NULL THEN
     IF l_loan_status = 'A' THEN   -- call only if loan is accepted
        compare_disbursements(l_loan_number);
     END IF;
     FOR loan_rec IN cur_tbh_loans LOOP
       gv_debug_str := gv_debug_str || 'UPDATE_LOR-19' || ' ';
       -- Modified the Update Row procedure call for the IGF_SL_LOANS_PKG to include the
       -- Borrower Determination as part of Refunds DLD - 2144600
       --
       -- check if loan status is sent, then only take the update
       --
       IF loan_rec.loan_status = 'S' THEN
          igf_sl_loans_pkg.update_row (
            X_Mode                              => 'R',
            x_rowid                             => loan_rec.row_id,
            x_loan_id                           => loan_rec.loan_id,
            x_award_id                          => loan_rec.award_id,
            x_seq_num                           => loan_rec.seq_num,
            x_loan_number                       => loan_rec.loan_number,
            x_loan_per_begin_date               => loan_rec.loan_per_begin_date,
            x_loan_per_end_date                 => loan_rec.loan_per_end_date,
            x_loan_status                       => l_loan_status,
            x_loan_status_date                  => TRUNC(SYSDATE),
            x_loan_chg_status                   => loan_rec.loan_chg_status,
            x_loan_chg_status_date              => loan_rec.loan_chg_status_date,
            x_active                            => loan_rec.active,
            x_active_date                       => loan_rec.active_date,
            x_borw_detrm_code                   => loan_rec.borw_detrm_code,
            x_legacy_record_flag                => NULL,
            x_external_loan_id_txt              => loan_rec.external_loan_id_txt
          );
       END IF;
       gv_debug_str := '';
     END LOOP;
   END IF;
   gv_debug_str := '';
 END LOOP;

 gv_debug_str := gv_debug_str || 'UPDATE_LOR-20' || ' ';
 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.update_lor.debug',gv_debug_str);
 END IF;
 gv_debug_str := '';

EXCEPTION

 WHEN SKIP_UPDATE_LOANS THEN
      NULL;

 WHEN app_exception.record_lock_exception THEN
     RAISE;

 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_CL_ACK.UPDATE_LOR');
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.update_lor.exception',gv_debug_str||' '|| SQLERRM);
     END IF;
     gv_debug_str := '';
     igs_ge_msg_stack.add;
     app_exception.raise_exception;

END update_lor;

PROCEDURE compare_disbursements(p_loan_number igf_sl_loans_all.loan_number%TYPE)
AS
/***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/12/07
   Purpose          :    To Compare the Disbursement Amounts specified in the
                     Format @8 Record with Data in the IGF_AW_AWD_DISB table
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who              When      What
   bvisvana         12-Sept-2005    Bug # 4575843.
                                    Removed the functionality of HOLD (place_disb_holds) and calling upd_disb_details
 ***************************************************************/

    l_old_count            NUMBER;
    l_new_count            NUMBER;
    l_award_id             igf_aw_awd_disb_all.award_id%TYPE;
    l_disb_num             igf_aw_awd_disb_all.disb_num%TYPE;
    l_disb_gross_amt       igf_aw_awd_disb_all.disb_gross_amt%TYPE;


      --Count the No.of Disbursements for the award id in Awards Disbursements Table
      CURSOR cur_count_old_disb
        IS
        SELECT award_id,  NVL(COUNT(disb_num),0) FROM igf_aw_awd_disb
        WHERE award_id = (SELECT award_id FROM igf_sl_loans
                          WHERE NVL(external_loan_id_txt,loan_number) = p_loan_number)
        GROUP BY award_id;

      --Count the No.of Disbursements for the award id in Response8 Disbursements Table
      CURSOR cur_count_new_disb (p_rec_status igf_sl_cl_resp_r8_all.resp_record_status%TYPE)
        IS
        SELECT NVL(COUNT(resp8.clrp8_id),0) FROM igf_sl_cl_resp_r8_all resp8
        WHERE clrp1_id                = loaded_1rec.clrp1_id
        AND  resp8.resp_record_status = p_rec_status;

      -- Check if the Disb-Num and Disb_gross_amts are same between the File and
      -- currently in our system.
      CURSOR cur_disb_same_data IS
        SELECT disb_num, disb_gross_amt FROM
        ((
         SELECT disb_num, NVL(disb_accepted_amt,0) disb_gross_amt  FROM igf_aw_awd_disb adisb
          WHERE award_id = l_award_id
          MINUS
          SELECT clrp8_id, disb_gross_amt FROM igf_sl_cl_resp_r8_all clrp8
          WHERE clrp1_id = loaded_1rec.clrp1_id
         )
         UNION ALL
         (SELECT clrp8_id, disb_gross_amt FROM igf_sl_cl_resp_r8_all clrp8
          WHERE clrp1_id = loaded_1rec.clrp1_id
          MINUS
          SELECT disb_num, NVL(disb_accepted_amt,0) disb_gross_amt FROM igf_aw_awd_disb adisb
          WHERE award_id = l_award_id
         )
        );

      --select the NewDisbursements for the award id in Response8 Disbursements Table
      CURSOR cur_new_disbursements(p_rec_status igf_sl_cl_resp_r8_all.resp_record_status%TYPE)
        IS
        SELECT * FROM igf_sl_cl_resp_r8
        WHERE clrp1_id         = loaded_1rec.clrp1_id
        AND resp_record_status = p_rec_status
        ORDER By clrp8_id;

      --Select the old Disbursements for the award id in Awards Disbursements Table
      CURSOR cur_old_disbursements
      IS
      SELECT * FROM  igf_aw_awd_disb
      WHERE award_id = l_award_id
      ORDER BY disb_num;


    --To update the Resp8 Records with Y as Record Status

    PROCEDURE update_resp8_rec_status(p_clrp1_id                igf_sl_cl_resp_r8_all.clrp1_id%TYPE,
                                      p_clrp8_id                igf_sl_cl_resp_r8_all.clrp8_id%TYPE,
                                      p_resp_record_status      igf_sl_cl_resp_r8_all.resp_record_status%TYPE)
    AS
    /***************************************************************
       Created By        :    mesriniv
       Date Created By   :    2000/12/07
       Purpose      :    To Update the Record Status of the Response8
                         Records as Processed
       Known Limitations,Enhancements or Remarks
       Change History    :
--  Who          When            What
--  mnade       21-Jan-2005     Bug - 4136563 - Disbursement update problems.
--                              The disbursements in @8 will be updated based on the flag and
--                              award disbursement changes status.
     ***************************************************************/

    --Select Response8 Records for Updation
    CURSOR cur_resp_r8
        IS
        SELECT *
        FROM igf_sl_cl_resp_r8
        WHERE   clrp1_id = p_clrp1_id
            AND clrp8_id = NVL(p_clrp8_id, clrp8_id)
            AND resp_record_status = 'N';
    l_resp_record_status    igf_sl_cl_resp_r8_all.resp_record_status%TYPE;
    BEGIN

      l_resp_record_status := p_resp_record_status;
      gv_debug_str := 'UPDATE_RESP8_REC_STATUS-1' || ' targetStatus - '|| l_resp_record_status || ' ';

      FOR resp_r8_rec in cur_resp_r8 LOOP

      gv_debug_str := gv_debug_str || 'UPDATE_RESP8_REC_STATUS-2' || ' ';

        igf_sl_cl_resp_r8_pkg.update_row (
          X_Mode                              => 'R',
          x_rowid                             => resp_r8_rec.row_id,
          x_clrp1_id                          => resp_r8_rec.clrp1_id,
          x_clrp8_id                          => resp_r8_rec.clrp8_id,
          x_disb_date                         => resp_r8_rec.disb_date,
          x_disb_gross_amt                    => resp_r8_rec.disb_gross_amt,
          x_orig_fee                          => resp_r8_rec.orig_fee,
          x_guarantee_fee                     => resp_r8_rec.guarantee_fee,
          x_net_disb_amt                      => resp_r8_rec.net_disb_amt,
          x_disb_hold_rel_ind                 => resp_r8_rec.disb_hold_rel_ind,
          x_disb_status                       => resp_r8_rec.disb_status,
          x_guarnt_fee_paid                   => resp_r8_rec.guarnt_fee_paid,
          x_orig_fee_paid                     => resp_r8_rec.orig_fee_paid,
          x_resp_record_status                => l_resp_record_status,
          x_layout_owner_code_txt             => resp_r8_rec.layout_owner_code_txt,
          x_layout_version_code_txt           => resp_r8_rec.layout_version_code_txt,
          x_record_code_txt                   => resp_r8_rec.record_code_txt
--	  x_direct_to_borr_flag               => resp_r8_rec.direct_to_borr_flag
        );
      gv_debug_str := '';
      END LOOP;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.update_resp8_rec_status.debug',gv_debug_str);
     END IF;

    END update_resp8_rec_status;

    PROCEDURE show_disb_details
    AS

     -- ActualLoan Amount       (from OFA)
     -- Requested Loan Amount   (from File)
     -- Guarantee Adj Indicator (From File)
     -- Guarantee Amount        (From File)
     -- Show all Disb details   (From OFA)
     --    Disb-Num    Disb-Gross   Fee1   Fee2   Fee_paid1   Fee_paid2   Disb-Net-Amt
     -- Show all Disb detail    (From File)
     --    Disb-Num    Disb-Gross   Fee1   Fee2   Fee_paid1   Fee_paid2   Disb-Net-Amt

    BEGIN
        gv_debug_str := 'SHOW_DISB_DETAILS-1' ||' ';
        IF p_disb_title IS  NULL THEN
            p_disb_title :=  LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_NUM'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_DATE'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_GROSS_AMT'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_1'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_2'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_PAID_1'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_PAID_2'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_NET_AMT'),30)
			                     ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_CL_ROSTER_LOGS','DIRECT_TO_BORR_IND'),35);

           p_disb_under_line := RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
			                        ||RPAD('-',30,'-')
                              ||RPAD('-',35,'-');
        END IF;

        fnd_file.put_line(fnd_file.log,' ');
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_GEN','OFA_DISB_DETAILS'));
        fnd_file.put_line(fnd_file.log,p_disb_title);
        fnd_file.put_line(fnd_file.log,p_disb_under_line);
        --To show the Disbursement Details in OFA

        FOR OFA_disb IN cur_old_disbursements
        LOOP
             fnd_file.put_line(fnd_file.log,
                                 LPAD(TO_CHAR(OFA_disb.disb_num),30)
                               ||LPAD(fnd_date.date_to_displaydate(OFA_disb.disb_date),30)
                               ||LPAD(TO_CHAR(OFA_disb.disb_accepted_amt),30)                   -- disb gorss amt changed to disb accepted amt
                               ||LPAD(TO_CHAR(OFA_disb.fee_1),30)
                               ||LPAD(TO_CHAR(OFA_disb.fee_2),30)
                               ||LPAD(TO_CHAR(OFA_disb.fee_paid_1),30)
                               ||LPAD(TO_CHAR(OFA_disb.fee_paid_2),30)
                               ||LPAD(TO_CHAR(OFA_disb.disb_net_amt),30)
			       ||LPAD(OFA_disb.direct_to_borr_flag,30));
        END LOOP;

        --To show the Disbursement details in File
        fnd_file.put_line(fnd_file.log,' ');
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_GEN','LOC_DISB_DETAILS'));
        fnd_file.put_line(fnd_file.log,p_disb_title);
        fnd_file.put_line(fnd_file.log,p_disb_under_line);

        FOR LOC_disb IN cur_new_disbursements('N')
        LOOP
           fnd_file.put_line(fnd_file.log,
                               LPAD(TO_CHAR(LOC_disb.clrp8_id),30)
                             ||LPAD(fnd_date.date_to_displaydate(LOC_disb.disb_date),30)
                             ||LPAD(TO_CHAR(LOC_disb.disb_gross_amt),30)
                             ||LPAD(TO_CHAR(LOC_disb.orig_fee),30)
                             ||LPAD(TO_CHAR(LOC_disb.guarantee_fee),30)
                             ||LPAD(TO_CHAR(LOC_disb.orig_fee_paid),30)
                             ||LPAD(TO_CHAR(LOC_disb.guarnt_fee_paid),30)
                             ||LPAD(TO_CHAR(LOC_disb.net_disb_amt),30)
			     ||LPAD(LOC_disb.direct_to_borr_flag,30));

        END LOOP;
        gv_debug_str := gv_debug_str || 'SHOW_DISB_DETAILS-2' ||' ';
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.show_disb_details.debug',gv_debug_str);
        END IF;
    END show_disb_details;

    /***************************************************************
       Change History   :
       Who              When            What
       bvisvana         05-Sept-2005    Bug # 4149649	- Shows disb details only for those with differences
     ***************************************************************/
    PROCEDURE show_differing_disb_details
    AS
        CURSOR cur_loc_disb (p_rec_status igf_sl_cl_resp_r8_all.resp_record_status%TYPE)
        IS
        SELECT clrp8.* FROM igf_sl_cl_resp_r8 clrp8
        WHERE clrp1_id         = loaded_1rec.clrp1_id
        AND resp_record_status = p_rec_status;

        CURSOR c_tbh_cur(p_award_id igf_aw_award.award_id%TYPE,
                         p_disb_num igf_aw_awd_disb.disb_num%TYPE) IS
        SELECT adisb.* FROM igf_aw_awd_disb  adisb
        WHERE award_id = p_award_id AND disb_num = p_disb_num
        FOR UPDATE OF manual_hold_ind NOWAIT;
        l_resp_record_status      igf_sl_cl_resp_r8_all.resp_record_status%TYPE;

        l_disb_title           VARCHAR2(1000);
        l_disb_under_line      VARCHAR2(1000);
        counter                NUMBER;

    BEGIN
      counter := 0;
      l_disb_title :=  LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_NUM'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_DATE'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_GROSS_AMT'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_1'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_2'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_PAID_1'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_PAID_2'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_NET_AMT'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','DISB_STATUS'),30)
                           ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','HOLD_REL_IND'),45)
                  			   ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_CL_ROSTER_LOGS','DIRECT_TO_BORR_IND'),35);

      l_disb_under_line :=    RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',30,'-')
                              ||RPAD('-',45,'-')
                  			      ||RPAD('-',35,'-');

      FOR loc_disb in cur_loc_disb('N') LOOP
        FOR tbh_rec in c_tbh_cur(l_award_id, loc_disb.clrp8_id) LOOP
           IF tbh_rec.disb_gross_amt         <>  loc_disb.disb_gross_amt             OR
              NVL(tbh_rec.fee_1,0)           <>  NVL(loc_disb.orig_fee,0)            OR
              NVL(tbh_rec.fee_2,0)           <>  NVL(loc_disb.guarantee_fee,0)       OR
              NVL(tbh_rec.disb_net_amt,0)    <>  NVL(loc_disb.net_disb_amt,0)        OR
              NVL(tbh_rec.disb_date,SYSDATE) <>  NVL(loc_disb.disb_date,SYSDATE)     OR
              NVL(tbh_rec.hold_rel_ind,'*')  <>  NVL(loc_disb.disb_hold_rel_ind,'*') OR
              NVL(tbh_rec.disb_status,'*')   <>  NVL(loc_disb.disb_status,'*')       OR
              NVL(tbh_rec.fee_paid_1,0)      <>  NVL(loc_disb.orig_fee_paid,0)       OR
              NVL(tbh_rec.fee_paid_2,0)      <>  NVL(loc_disb.guarnt_fee_paid,0)     OR
	      NVL(tbh_rec.direct_to_borr_flag,'N') <> NVL(loc_disb.direct_to_borr_flag,'N')
          THEN
          counter := counter + 1;
          awd_disb_array(counter) :=   LPAD(TO_CHAR(tbh_rec.disb_num),30)
                                       ||LPAD(fnd_date.date_to_displaydate(tbh_rec.disb_date),30)
                                       ||LPAD(TO_CHAR(NVL(tbh_rec.disb_accepted_amt,0)),30)
                                       ||LPAD(TO_CHAR(NVL(tbh_rec.fee_1,0)),30)
                                       ||LPAD(TO_CHAR(NVL(tbh_rec.fee_2,0)),30)
                                       ||LPAD(TO_CHAR(NVL(tbh_rec.fee_paid_1,0)),30)
                                       ||LPAD(TO_CHAR(NVL(tbh_rec.fee_paid_2,0)),30)
                                       ||LPAD(TO_CHAR(NVL(tbh_rec.disb_net_amt,0)),30)
                                       ||LPAD(NVL(TO_CHAR(IGF_AW_GEN.LOOKUP_DESC('IGF_SL_CL_DISB_STATUS',tbh_rec.disb_status)),' '),30)
                                       ||LPAD(NVL(TO_CHAR(IGF_AW_GEN.LOOKUP_DESC('IGF_SL_CL_HOLD_REL_IND_TF',tbh_rec.hold_rel_ind)),' '),45)
				       ||LPAD(NVL(tbh_rec.direct_to_borr_flag,'N'),30);

          loc_disb_array(counter) :=   LPAD(TO_CHAR(loc_disb.clrp8_id),30)
                                       ||LPAD(fnd_date.date_to_displaydate(loc_disb.disb_date),30)
                                       ||LPAD(TO_CHAR(NVL(loc_disb.disb_gross_amt,0)),30)
                                       ||LPAD(TO_CHAR(NVL(loc_disb.orig_fee,0)),30)
                                       ||LPAD(TO_CHAR(NVL(loc_disb.guarantee_fee,0)),30)
                                       ||LPAD(TO_CHAR(NVL(loc_disb.orig_fee_paid,0)),30)
                                       ||LPAD(TO_CHAR(NVL(loc_disb.guarnt_fee_paid,0)),30)
                                       ||LPAD(TO_CHAR(NVL(loc_disb.net_disb_amt,0)),30)
                                       ||LPAD(NVL(TO_CHAR(IGF_AW_GEN.LOOKUP_DESC('IGF_SL_CL_DISB_STATUS',loc_disb.disb_status)),' '),30)
                                       ||LPAD(NVL(TO_CHAR(IGF_AW_GEN.LOOKUP_DESC('IGF_SL_CL_HOLD_REL_IND_TF', loc_disb.disb_hold_rel_ind)),' '),45)
				       ||LPAD(NVL(loc_disb.direct_to_borr_flag,'N'),30);

          END IF;
        END LOOP;
      END LOOP;
      -- Display the information now
      fnd_file.put_line(fnd_file.log,' ');
      fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_GEN','OFA_DISB_DETAILS'));
      fnd_file.put_line(fnd_file.log,l_disb_title);
      fnd_file.put_line(fnd_file.log,l_disb_under_line);

      FOR i IN  1..counter LOOP
        fnd_file.put_line(fnd_file.log,awd_disb_array(i));
      END LOOP;

      fnd_file.put_line(fnd_file.log,' ');
      fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_GEN','LOC_DISB_DETAILS'));
      fnd_file.put_line(fnd_file.log,l_disb_title);
      fnd_file.put_line(fnd_file.log,l_disb_under_line);

      FOR i IN  1..counter LOOP
        fnd_file.put_line(fnd_file.log,loc_disb_array(i));
      END LOOP;

      fnd_file.put_line(fnd_file.log,' ');

    END show_differing_disb_details;

    --Procedure to update award disbursments Fee details with values from the File

    PROCEDURE upd_disb_details(p_disb_num  igf_aw_awd_disb_all.disb_num%TYPE)
     /***************************************************************
       Change History   :
       Who              When            What
       bvisvana         12-Sept-2005    Bug # 4575843
                                        Update the disb_accepted amt with the disb_gross_amt from response
     ***************************************************************/
    AS
        CURSOR cur_loc_disb (p_rec_status igf_sl_cl_resp_r8_all.resp_record_status%TYPE)
        IS
        SELECT clrp8.* FROM igf_sl_cl_resp_r8 clrp8
        WHERE clrp1_id         = loaded_1rec.clrp1_id
        AND resp_record_status = p_rec_status;

        CURSOR c_tbh_cur(p_award_id igf_aw_award.award_id%TYPE,
                         p_disb_num igf_aw_awd_disb.disb_num%TYPE) IS
        SELECT adisb.* FROM igf_aw_awd_disb  adisb
        WHERE award_id = p_award_id AND disb_num = p_disb_num
        FOR UPDATE OF manual_hold_ind NOWAIT;
        l_resp_record_status      igf_sl_cl_resp_r8_all.resp_record_status%TYPE;
    BEGIN

      FOR loc_disb in cur_loc_disb('N') LOOP  -- LOC Loop

        gv_debug_str := 'UPD_DISB_DETAILS-1' ||' ';

        FOR tbh_rec in c_tbh_cur(l_award_id, loc_disb.clrp8_id) LOOP  --CLRP8 Loop

          l_resp_record_status := 'N';
          gv_debug_str := gv_debug_str||'UPD_DISB_DETAILS-2' ||' ';
          IF  tbh_rec.disb_gross_amt         <>  loc_disb.disb_gross_amt             OR
              NVL(tbh_rec.fee_1,0)           <>  NVL(loc_disb.orig_fee,0)            OR
              NVL(tbh_rec.fee_2,0)           <>  NVL(loc_disb.guarantee_fee,0)       OR
              NVL(tbh_rec.disb_net_amt,0)    <>  NVL(loc_disb.net_disb_amt,0)        OR
              NVL(tbh_rec.disb_date,SYSDATE) <>  NVL(loc_disb.disb_date,SYSDATE)     OR
              NVL(tbh_rec.hold_rel_ind,'*')  <>  NVL(loc_disb.disb_hold_rel_ind,'*') OR
              NVL(tbh_rec.disb_status,'*')   <>  NVL(loc_disb.disb_status,'*')       OR
              NVL(tbh_rec.fee_paid_1,0)      <>  NVL(loc_disb.orig_fee_paid,0)       OR
              NVL(tbh_rec.fee_paid_2,0)      <>  NVL(loc_disb.guarnt_fee_paid,0)     OR
	      NVL(tbh_rec.direct_to_borr_flag,'*') <> NVL(loc_disb.direct_to_borr_flag,'*')
          THEN                                                          -- LOR LOC Diff Check

            IF g_c_update_disb_dtls = 'Y' THEN                          -- Update Flag Check
              fnd_message.set_name('IGF','IGF_SL_CL_UPD_DISB_DTLS');
              fnd_message.set_token('DISB_NUM',loc_disb.clrp8_id);
              fnd_file.put_line(fnd_file.log,fnd_message.get);

              -- Update Flag Check
              igf_aw_awd_disb_pkg.update_row (
               x_Mode                      => 'R',
               x_rowid                     => tbh_rec.row_id,
               x_award_id                  => tbh_rec.award_id,
               x_disb_num                  => tbh_rec.disb_num,
               x_tp_cal_type               => tbh_rec.tp_cal_type,
               x_tp_sequence_number        => tbh_rec.tp_sequence_number,
               x_disb_gross_amt            => loc_disb.disb_gross_amt,
               x_fee_1                     => loc_disb.orig_fee,
               x_fee_2                     => loc_disb.guarantee_fee,
               x_disb_net_amt              => loc_disb.net_disb_amt,
               x_disb_date                 => loc_disb.disb_date,
               x_trans_type                => tbh_rec.trans_type,
               x_elig_status               => tbh_rec.elig_status,
               x_elig_status_date          => tbh_rec.elig_status_date,
               x_affirm_flag               => tbh_rec.affirm_flag,
               x_hold_rel_ind              => loc_disb.disb_hold_rel_ind,
               x_manual_hold_ind           => tbh_rec.manual_hold_ind,
               x_disb_status               => loc_disb.disb_status,
               x_disb_status_date          => TRUNC(SYSDATE),
               x_late_disb_ind             => tbh_rec.late_disb_ind,
               x_fund_dist_mthd            => tbh_rec.fund_dist_mthd,
               x_prev_reported_ind         => tbh_rec.prev_reported_ind,
               x_fund_release_date         => tbh_rec.fund_release_date,
               x_fund_status               => tbh_rec.fund_status,
               x_fund_status_date          => tbh_rec.fund_status_date,
               x_fee_paid_1                => loc_disb.orig_fee_paid,
               x_fee_paid_2                => loc_disb.guarnt_fee_paid,
               x_cheque_number             => tbh_rec.cheque_number,
               x_ld_cal_type               => tbh_rec.ld_cal_type,
               x_ld_sequence_number        => tbh_rec.ld_sequence_number,
               x_disb_accepted_amt         => loc_disb.disb_gross_amt, -- tbh_rec.disb_accepted_amt, -- bvisvana.SBCC Bug # 4575843
               x_disb_paid_amt             => tbh_rec.disb_paid_amt,
               x_rvsn_id                   => tbh_rec.rvsn_id,
               x_int_rebate_amt            => tbh_rec.int_rebate_amt,
               x_force_disb                => tbh_rec.force_disb,
               x_min_credit_pts            => tbh_rec.min_credit_pts,
               x_disb_exp_dt               => tbh_rec.disb_exp_dt,
               x_verf_enfr_dt              => tbh_rec.verf_enfr_dt,
               x_fee_class                 => tbh_rec.fee_class,
               x_show_on_bill              => tbh_rec.show_on_bill,
               x_attendance_type_code      => tbh_rec.attendance_type_code,
               x_base_attendance_type_code => tbh_rec.base_attendance_type_code,
               x_payment_prd_st_date       => tbh_rec.payment_prd_st_date,
               x_change_type_code          => tbh_rec.change_type_code,
               x_fund_return_mthd_code     => tbh_rec.fund_return_mthd_code
--	       x_direct_to_borr_flag       => loc_disb.direct_to_borr_flag
              );
              l_resp_record_status := 'U';
            ELSE                                                        -- Else Update Flag Check
              l_resp_record_status := 'D';
            END IF;                                                     -- End Update Flag Check
          ELSE                                                          -- Else Diff Check
              l_resp_record_status := 'Y';
          END IF;                                                       -- End LOR LOC Diff Check
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.upd_disb_details.debug',gv_debug_str ||
                                                    '|clrp1_id - ' || loc_disb.clrp1_id ||
                                                    '|clrp8_id - ' || loc_disb.clrp8_id ||
                                                    '|l_resp_record_status - ' || l_resp_record_status
                                                    );
          END IF;
          gv_debug_str := '';
          update_resp8_rec_status(loc_disb.clrp1_id,
                                  loc_disb.clrp8_id,
                                  l_resp_record_status);
         END LOOP;  --END CLRP8 Loop
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.upd_disb_details.debug',gv_debug_str);
         END IF;
         gv_debug_str := '';
       END LOOP;  -- END LOC Loop

    END upd_disb_details;


    PROCEDURE place_disb_holds(p_award_id   igf_aw_awd_disb_all.award_id%TYPE)
    AS
        CURSOR c_tbh_cur(p_trans_type igf_aw_awd_disb.trans_type%TYPE)
        IS
        SELECT adisb.* FROM igf_aw_awd_disb adisb
        WHERE award_id = p_award_id  and
        trans_type = p_trans_type ;

      CURSOR cur_disb_hold_exists(cp_award_id    igf_db_disb_holds.award_id%TYPE,
                                  cp_disb_num    igf_db_disb_holds.disb_num%TYPE,
                                  cp_hold        igf_db_disb_holds.hold%TYPE ,
                                  cp_release_flag igf_db_disb_holds.release_flag%TYPE)
        IS
        SELECT count(row_id)
        FROM   igf_db_disb_holds
        WHERE  award_id = cp_award_id
        AND    disb_num = cp_disb_num
        AND    hold     = cp_hold
        AND    release_flag = cp_release_flag;

        l_rowid      VARCHAR2(30);
        l_hold_id    igf_db_disb_holds.hold_id%TYPE;
        l_rec_count  NUMBER;

    BEGIN

        FOR tbh_rec in c_tbh_cur('P') LOOP

           l_rowid   := NULL;
           l_hold_id := NULL;
           gv_debug_str := 'PLACE_DISB_HOLDS - 1'||' ';
           OPEN  cur_disb_hold_exists(tbh_rec.award_id,tbh_rec.disb_num,'CL','N');
           FETCH cur_disb_hold_exists into l_rec_count;

           IF NOT ( nvl(l_rec_count,0) > 0) THEN
           gv_debug_str := gv_debug_str || 'PLACE_DISB_HOLDS - 2'||' ';
                 igf_db_disb_holds_pkg.insert_row (
                      x_mode              => 'R',
                      x_rowid             => l_rowid,
                      x_hold_id           => l_hold_id,
                      x_award_id          => tbh_rec.award_id,
                      x_disb_num          => tbh_rec.disb_num,
                      x_hold              => 'CL',
                      x_hold_type         => 'SYSTEM',
                      x_hold_date         => TRUNC(sysdate),
                      x_release_flag      => 'N',
                      x_release_reason    =>  NULL,
                      x_release_date      =>  NULL
                     );
           gv_debug_str := gv_debug_str || 'PLACE_DISB_HOLDS - 3 '||' ';
           END IF;
           CLOSE cur_disb_hold_exists;
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.place_disb_holds.debug',gv_debug_str);
           END IF;
           gv_debug_str := '';
        END LOOP;

    END place_disb_holds;


BEGIN

  --Fetch the Old and New No.of Records

  gv_debug_str := 'COMPARE_DISBURSEMENTS - 1' ||' ';

  OPEN cur_count_old_disb;
  FETCH cur_count_old_disb INTO l_award_id, l_old_count;
  IF l_old_count=0 THEN
     CLOSE cur_count_old_disb;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE cur_count_old_disb;

  gv_debug_str := gv_debug_str || 'COMPARE_DISBURSEMENTS - 2' ||' ';

  OPEN cur_count_new_disb('N');
  FETCH cur_count_new_disb INTO l_new_count;
  IF l_new_count=0 THEN
     CLOSE cur_count_new_disb;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE cur_count_new_disb;

  gv_debug_str := gv_debug_str || 'COMPARE_DISBURSEMENTS - 3' ||' ';

  IF l_old_count <> l_new_count THEN

     -- Show all details like Old(From OFA) and New Disbursement Amounts(From File)
     -- Guarantee Adj Indicator (From File)
     -- Guarantee Amount        (From File)
     -- Requested Loan Amount   (from File)
     gv_debug_str := gv_debug_str || 'COMPARE_DISBURSEMENTS - 4' ||' ';
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.compare_disbursements.debug',gv_debug_str);
     END IF;
     gv_debug_str := '';
--
-- put a message here comparing loc and system data,
-- different number of loc and system disbursements
--
     fnd_file.new_line(fnd_file.log,1);
     fnd_message.set_name('IGF','IGF_SL_CL_DIFF_DISB_NUM');
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     fnd_file.new_line(fnd_file.log,1);

     show_disb_details;

     gv_debug_str := gv_debug_str || 'COMPARE_DISBURSEMENTS - 5' ||' ';
     -- Place Process Holds on All the Disbursement records.
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.compare_disbursements.debug',gv_debug_str);
     END IF;
     gv_debug_str := '';
     place_disb_holds(l_award_id);
     gv_debug_str := gv_debug_str || 'COMPARE_DISBURSEMENTS - 6' ||' ';

  ELSE

     OPEN cur_disb_same_data;
     FETCH cur_disb_same_data INTO l_disb_num, l_disb_gross_amt;
     gv_debug_str := gv_debug_str || 'COMPARE_DISBURSEMENTS - 7' ||' ';

     IF cur_disb_same_data%NOTFOUND THEN

       -- Indicates that disbursement data (Number of Disbursements and
       -- disb-gross-amts and loan_requested_amt ) are currently same,
       -- what was sent to the external processor.

       -- Update Fee_1, fee_2, fee_paid_1, fee_paid_2 from the file into
       -- disbursements records.
       gv_debug_str := gv_debug_str || 'COMPARE_DISBURSEMENTS - 8' ||' ';

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.compare_disbursements.debug',gv_debug_str);
       END IF;
       gv_debug_str := '';
       show_differing_disb_details;
       -- if the parameter update disbursement details  is set to 'y' only then
       -- invoke the upd_disb_details
       -- mnade 21-Jan-2005 - the Check of flag is done in the upd_disb_details
--       IF g_c_update_disb_dtls = 'Y' THEN
         upd_disb_details(l_disb_num);
--       END IF;

     ELSE

       gv_debug_str := gv_debug_str || 'COMPARE_DISBURSEMENTS - 9' ||' ';
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.compare_disbursements.debug',gv_debug_str);
       END IF;
       gv_debug_str := '';
--
-- put a message here
-- different amounts
--
       fnd_message.set_name('IGF','IGF_SL_CL_DIFF_DISB_AMTS');
       fnd_file.new_line(fnd_file.log,1);
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       fnd_file.new_line(fnd_file.log,1);

       show_disb_details;

       -- Place Process Holds on All the Disbursement records.
       gv_debug_str := gv_debug_str || 'COMPARE_DISBURSEMENTS - 10' ||' ';
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.compare_disbursements.debug',gv_debug_str);
       END IF;
       gv_debug_str := '';

       -- bvisvana - SBCC Bug # 4575843 - Instead of placing holds do an update.
       -- place_disb_holds(l_award_id);
       upd_disb_details(l_disb_num);

     END IF;
     CLOSE cur_disb_same_data;

  END IF;

  -- Update the Status of the records in cl_resp_r8 to processed.
     gv_debug_str := gv_debug_str || 'COMPARE_DISBURSEMENTS - 11' ||' ';
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.compare_disbursements.debug',gv_debug_str);
     END IF;
     gv_debug_str := '';
     update_resp8_rec_status(loaded_1rec.clrp1_id, NULL, 'N');

EXCEPTION

 WHEN app_exception.record_lock_exception THEN
    RAISE;

 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_CL_ACK.COMPARE_DISBURSEMENTS');
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.compare_disbursements.exception',gv_debug_str||' '|| SQLERRM);
     END IF;
     gv_debug_str := '';
     igs_ge_msg_stack.add;
     app_exception.raise_exception;

END compare_disbursements;


--Procedure Definition for Inserting into igf_sl_resp_r4 w.r.to new DLD

PROCEDURE insert_into_resp_r4(p_clrp1_id             igf_sl_cl_resp_r1_all.clrp1_id%TYPE,
                              p_r4_record            igf_sl_load_file_t.record_data%TYPE)

/***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2001/05/13
   Purpose          :    To Insert File data into IGF_SL_CL_RESP_R4

   ENH Bug No.:1769051
   Bug Desc   :Development of Loans Processing for Nov 2001.
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who              When      What
 ***************************************************************/

AS


  l_rowid                VARCHAR2(25)      DEFAULT NULL;
  l_loan_id              igf_sl_loans_all.loan_id%TYPE;
  l_fed_stafford         igf_sl_alt_borw.fed_stafford_loan_debt%TYPE;
  l_fed_sls              igf_sl_alt_borw.fed_sls_debt%TYPE;
  rec_cl_resp_r4         igf_sl_cl_resp_r4_all%ROWTYPE;
  BEGIN  --for the procedure insert_into_resp_r4

  gv_debug_str := 'INSERT_INTO_RESP_R4 - 1' || ' ';

  IF g_v_cl_version = 'RELEASE-5' THEN
    rec_cl_resp_r4.stud_mth_housing_pymt       :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,593,5))));
    rec_cl_resp_r4.stud_mth_crdtcard_pymt      :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,598,5))));
    rec_cl_resp_r4.stud_mth_auto_pymt          :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,603,5))));
    rec_cl_resp_r4.stud_mth_ed_loan_pymt       :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,608,5))));
    rec_cl_resp_r4.stud_mth_other_pymt         :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,613,5))));
    rec_cl_resp_r4.cosnr_1_forn_phone_prefix   :=  LTRIM(RTRIM(SUBSTR(p_r4_record,573,10)));
    rec_cl_resp_r4.cosnr_1_mth_housing_pymt    :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,618,5))));
    rec_cl_resp_r4.cosnr_1_mth_crdtcard_pymt   :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,623,5))));
    rec_cl_resp_r4.cosnr_1_mth_auto_pymt       :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,628,5))));
    rec_cl_resp_r4.cosnr_1_mth_ed_loan_pymt    :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,633,5))));
    rec_cl_resp_r4.cosnr_1_mth_other_pymt      :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,638,5))));
    rec_cl_resp_r4.cosnr_1_crdt_auth_code      :=  LTRIM(RTRIM(SUBSTR(p_r4_record,668,1)));
    rec_cl_resp_r4.cosnr_2_forn_phone_prefix   :=  LTRIM(RTRIM(SUBSTR(p_r4_record,583,10)));
    rec_cl_resp_r4.cosnr_2_mth_housing_pymt    :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,643,5))));
    rec_cl_resp_r4.cosnr_2_mth_crdtcard_pymt   :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,648,5))));
    rec_cl_resp_r4.cosnr_2_mth_auto_pymt       :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,653,5))));
    rec_cl_resp_r4.cosnr_2_mth_ed_loan_pymt    :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,658,5))));
    rec_cl_resp_r4.cosnr_2_mth_other_pymt      :=  TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,663,5))));
    rec_cl_resp_r4.cosnr_2_crdt_auth_code      :=  LTRIM(RTRIM(SUBSTR(p_r4_record,669,1)));
    rec_cl_resp_r4.first_csgnr_elec_sign_flag  :=  LTRIM(RTRIM(SUBSTR(p_r4_record,670,1)));
    rec_cl_resp_r4.second_csgnr_elec_sign_flag :=  LTRIM(RTRIM(SUBSTR(p_r4_record,671,1)));

  ELSIF g_v_cl_version = 'RELEASE-4' THEN
    rec_cl_resp_r4.stud_mth_housing_pymt       :=  NULL;
    rec_cl_resp_r4.stud_mth_crdtcard_pymt      :=  NULL;
    rec_cl_resp_r4.stud_mth_auto_pymt          :=  NULL;
    rec_cl_resp_r4.stud_mth_ed_loan_pymt       :=  NULL;
    rec_cl_resp_r4.stud_mth_other_pymt         :=  NULL;
    rec_cl_resp_r4.cosnr_1_forn_phone_prefix   :=  NULL;
    rec_cl_resp_r4.cosnr_1_mth_housing_pymt    :=  NULL;
    rec_cl_resp_r4.cosnr_1_mth_crdtcard_pymt   :=  NULL;
    rec_cl_resp_r4.cosnr_1_mth_auto_pymt       :=  NULL;
    rec_cl_resp_r4.cosnr_1_mth_ed_loan_pymt    :=  NULL;
    rec_cl_resp_r4.cosnr_1_mth_other_pymt      :=  NULL;
    rec_cl_resp_r4.cosnr_1_crdt_auth_code      :=  NULL;
    rec_cl_resp_r4.cosnr_2_forn_phone_prefix   :=  NULL;
    rec_cl_resp_r4.cosnr_2_mth_housing_pymt    :=  NULL;
    rec_cl_resp_r4.cosnr_2_mth_crdtcard_pymt   :=  NULL;
    rec_cl_resp_r4.cosnr_2_mth_auto_pymt       :=  NULL;
    rec_cl_resp_r4.cosnr_2_mth_ed_loan_pymt    :=  NULL;
    rec_cl_resp_r4.cosnr_2_mth_other_pymt      :=  NULL;
    rec_cl_resp_r4.cosnr_2_crdt_auth_code      :=  NULL;
    rec_cl_resp_r4.first_csgnr_elec_sign_flag  :=  NULL;
    rec_cl_resp_r4.second_csgnr_elec_sign_flag :=  NULL;
  END IF;

  igf_sl_cl_resp_r4_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => l_rowid,
      x_clrp1_id                          => p_clrp1_id, --Corresponding id already inserted for @1 Record
      x_loan_number                       => l_loan_number,
      x_fed_stafford_loan_debt            => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,9,5)))),
      x_fed_sls_debt                      => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,14,5)))),
      x_heal_debt                         => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,19,6)))),
      x_perkins_debt                      => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,25,5)))),
      x_other_debt                        => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,30,6)))),
      x_crdt_undr_difft_name              => LTRIM(RTRIM(SUBSTR(p_r4_record,43,1))),
      x_borw_gross_annual_sal             => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,384,7)))),
      x_borw_other_income                 => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,391,7)))),
      x_student_major                     => LTRIM(RTRIM(SUBSTR(p_r4_record,454,15))),
      x_int_rate_opt                      => LTRIM(RTRIM(SUBSTR(p_r4_record,571,1))),
      x_repayment_opt_code                => LTRIM(RTRIM(SUBSTR(p_r4_record,572,1))),
      x_stud_mth_housing_pymt             => rec_cl_resp_r4.stud_mth_housing_pymt  ,
      x_stud_mth_crdtcard_pymt            => rec_cl_resp_r4.stud_mth_crdtcard_pymt ,
      x_stud_mth_auto_pymt                => rec_cl_resp_r4.stud_mth_auto_pymt     ,
      x_stud_mth_ed_loan_pymt             => rec_cl_resp_r4.stud_mth_ed_loan_pymt  ,
      x_stud_mth_other_pymt               => rec_cl_resp_r4.stud_mth_other_pymt,
      x_cosnr_1_last_name                 => LTRIM(RTRIM(SUBSTR(p_r4_record,44,35))),
      x_cosnr_1_first_name                => LTRIM(RTRIM(SUBSTR(p_r4_record,79,12))),
      x_cosnr_1_middle_name               => LTRIM(RTRIM(SUBSTR(p_r4_record,91,1))),
      x_cosnr_1_ssn                       => LTRIM(RTRIM(SUBSTR(p_r4_record,92,9))),
      x_cosnr_1_citizenship               => LTRIM(RTRIM(SUBSTR(p_r4_record,101,1))),
      x_cosnr_1_addr_line1                => LTRIM(RTRIM(SUBSTR(p_r4_record,102,30))),
      x_cosnr_1_addr_line2                => LTRIM(RTRIM(SUBSTR(p_r4_record,132,30))),
      x_cosnr_1_city                      => LTRIM(RTRIM(SUBSTR(p_r4_record,162,24))),
      x_cosnr_1_state                     => LTRIM(RTRIM(SUBSTR(p_r4_record,192,2))),
      x_cosnr_1_zip                       => LTRIM(RTRIM(SUBSTR(p_r4_record,194,5))),
      x_cosnr_1_zip_suffix                => LTRIM(RTRIM(SUBSTR(p_r4_record,199,4))),
      x_cosnr_1_phone                     => LTRIM(RTRIM(SUBSTR(p_r4_record,203,10))),
      x_cosnr_1_sig_code                  => LTRIM(RTRIM(SUBSTR(p_r4_record,213,1))),
      x_cosnr_1_gross_anl_sal             => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,398,7)))),
      x_cosnr_1_other_income              => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,405,7)))),
      x_cosnr_1_forn_postal_code          => LTRIM(RTRIM(SUBSTR(p_r4_record,426,14))),
      x_cosnr_1_forn_phone_prefix         => rec_cl_resp_r4.cosnr_1_forn_phone_prefix,
      --MN 21-Jan-2005 - Using REPLACE to remove DOB containing 0s.
      x_cosnr_1_dob                       => TO_DATE(REPLACE(LTRIM(RTRIM(SUBSTR(p_r4_record,469,8))), '00000000', NULL),'YYYYMMDD'),
      x_cosnr_1_license_state             => LTRIM(RTRIM(SUBSTR(p_r4_record,477,2))),
      x_cosnr_1_license_num               => LTRIM(RTRIM(SUBSTR(p_r4_record,479,20))),
      x_cosnr_1_relationship_to           => LTRIM(RTRIM(SUBSTR(p_r4_record,559,1))),
      x_cosnr_1_years_at_addr             => LTRIM(RTRIM(SUBSTR(p_r4_record,563,2))),
      x_cosnr_1_mth_housing_pymt          => rec_cl_resp_r4.cosnr_1_mth_housing_pymt,
      x_cosnr_1_mth_crdtcard_pymt         => rec_cl_resp_r4.cosnr_1_mth_crdtcard_pymt,
      x_cosnr_1_mth_auto_pymt             => rec_cl_resp_r4.cosnr_1_mth_auto_pymt,
      x_cosnr_1_mth_ed_loan_pymt          => rec_cl_resp_r4.cosnr_1_mth_ed_loan_pymt,
      x_cosnr_1_mth_other_pymt            => rec_cl_resp_r4.cosnr_1_mth_other_pymt,
      x_cosnr_1_crdt_auth_code            => rec_cl_resp_r4.cosnr_1_crdt_auth_code,
      x_cosnr_2_last_name                 => LTRIM(RTRIM(SUBSTR(p_r4_record,214,35))),
      x_cosnr_2_first_name                => LTRIM(RTRIM(SUBSTR(p_r4_record,249,12))),
      x_cosnr_2_middle_name               => LTRIM(RTRIM(SUBSTR(p_r4_record,261,1))),
      x_cosnr_2_ssn                       => LTRIM(RTRIM(SUBSTR(p_r4_record,262,9))),
      x_cosnr_2_citizenship               => LTRIM(RTRIM(SUBSTR(p_r4_record,271,1))),
      x_cosnr_2_addr_line1                => LTRIM(RTRIM(SUBSTR(p_r4_record,272,30))),
      x_cosnr_2_addr_line2                => LTRIM(RTRIM(SUBSTR(p_r4_record,302,30))),
      x_cosnr_2_city                      => LTRIM(RTRIM(SUBSTR(p_r4_record,332,24))),
      x_cosnr_2_state                     => LTRIM(RTRIM(SUBSTR(p_r4_record,362,2))),
      x_cosnr_2_zip                       => LTRIM(RTRIM(SUBSTR(p_r4_record,364,5))),
      x_cosnr_2_zip_suffix                => LTRIM(RTRIM(SUBSTR(p_r4_record,369,4))),
      x_cosnr_2_phone                     => LTRIM(RTRIM(SUBSTR(p_r4_record,373,10))),
      x_cosnr_2_sig_code                  => LTRIM(RTRIM(SUBSTR(p_r4_record,383,1))),
      x_cosnr_2_gross_anl_sal             => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,412,7)))),
      x_cosnr_2_other_income              => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,419,7)))),
      x_cosnr_2_forn_postal_code          => LTRIM(RTRIM(SUBSTR(p_r4_record,440,14))),
      x_cosnr_2_forn_phone_prefix         => rec_cl_resp_r4.cosnr_2_forn_phone_prefix,
      --MN 21-Jan-2005 - Using REPLACE to remove DOB containing 0s.
      x_cosnr_2_dob                       => TO_DATE(REPLACE(LTRIM(RTRIM(SUBSTR(p_r4_record,499,8))), '00000000', NULL),'YYYYMMDD'),
      x_cosnr_2_license_state             => LTRIM(RTRIM(SUBSTR(p_r4_record,507,2))) ,
      x_cosnr_2_license_num               => LTRIM(RTRIM(SUBSTR(p_r4_record,509,20))),
      x_cosnr_2_relationship_to           => LTRIM(RTRIM(SUBSTR(p_r4_record,565,1))),
      x_cosnr_2_years_at_addr             => LTRIM(RTRIM(SUBSTR(p_r4_record,569,2))),
      x_cosnr_2_mth_housing_pymt          => rec_cl_resp_r4.cosnr_2_mth_housing_pymt,
      x_cosnr_2_mth_crdtcard_pymt         => rec_cl_resp_r4.cosnr_2_mth_crdtcard_pymt,
      x_cosnr_2_mth_auto_pymt             => rec_cl_resp_r4.cosnr_2_mth_auto_pymt,
      x_cosnr_2_mth_ed_loan_pymt          => rec_cl_resp_r4.cosnr_2_mth_ed_loan_pymt,
      x_cosnr_2_mth_other_pymt            => rec_cl_resp_r4.cosnr_2_mth_other_pymt,
      x_cosnr_2_crdt_auth_code            => rec_cl_resp_r4.cosnr_2_crdt_auth_code,
      x_other_loan_amt                    => TO_NUMBER (LTRIM(RTRIM(SUBSTR(p_r4_record,36,7)))),
      x_alt_layout_owner_code_txt         => LTRIM(RTRIM(SUBSTR(p_r4_record,3,4))),
      x_alt_layout_identi_code_txt        => LTRIM(RTRIM(SUBSTR(p_r4_record,7,2))),
      x_student_school_phone_txt          => LTRIM(RTRIM(SUBSTR(p_r4_record,549,10))),
      x_first_csgnr_elec_sign_flag        => rec_cl_resp_r4.first_csgnr_elec_sign_flag,
      x_second_csgnr_elec_sign_flag       => rec_cl_resp_r4.second_csgnr_elec_sign_flag

     );

  gv_debug_str := 'INSERT_INTO_RESP_R4 - 2' || ' ';


EXCEPTION
WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_CL_ACK.INSERT_INTO_RESP_R4');
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.insert_into_resp_r4.exception',gv_debug_str||' '|| SQLERRM);
     END IF;
     gv_debug_str := '';
     igs_ge_msg_stack.add;
     app_exception.raise_exception;

END insert_into_resp_r4;


--Procedure declared and defined here to display the difference  in the Alternate Borrower Information between
--OFA and that inserted into the igf_sl_cl_resp_r4 table

PROCEDURE   show_alt_details(
                    p_clrp1_id  igf_sl_cl_resp_r1_all.clrp1_id%TYPE,
                    p_loan_id   igf_sl_loans_all.loan_id%TYPE
                    )

/***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2001/05/13
   Purpose          :    To display the Difference
                    in information between System Data
                    and File Data

   ENH Bug No.:1769051
   Bug Desc   :Development of Loans Processing for Nov 2001.
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who              When      What
 ***************************************************************/


AS
     --
     -- Cursor to Fetch the Alternate Borrower's Information in OFA
     --
     CURSOR cur_alt_borw
     IS
     SELECT borw.*
     FROM   igf_sl_alt_borw borw
     WHERE  loan_id=p_loan_id;

     --
     -- Cursor to Fetch the Alternate Borrower's Information loaded from File
     --
     CURSOR cur_resp4
     IS
     SELECT resp4.*
     FROM   igf_sl_cl_resp_r4 resp4
     WHERE  clrp1_id= p_clrp1_id;

     --
     -- Array declared here to store the difference in data.
     --
     TYPE tab_data_array IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

     ofa_rec        igf_sl_alt_borw%ROWTYPE;
     file_rec       igf_sl_cl_resp_r4%ROWTYPE;

     l_alt_title    VARCHAR2(2000);
     l_alt_data     VARCHAR2(2000);
     l_r4_data      VARCHAR2(2000);
     l_alt_line     VARCHAR2(2000);
     l_log_mesg     VARCHAR2(1000);
     data_array     tab_data_array;

     l_counter      NUMBER DEFAULT  0;

BEGIN

   gv_debug_str := 'SHOW_ALT_DETAILS - 1 ' || ' ';
   --Fetch the respective information
   OPEN cur_alt_borw;
   FETCH cur_alt_borw INTO ofa_rec;
   CLOSE cur_alt_borw;

   OPEN cur_resp4;
   FETCH cur_resp4 INTO file_rec;
   CLOSE cur_resp4;

 -- Each Field in OFA is compared against the corresponding field from File and only
 -- that differ in values will be displayed in Log File.

   IF NVL(ofa_rec.fed_stafford_loan_debt,0) <> NVL(file_rec.fed_stafford_loan_debt,0) THEN
      l_counter  :=l_counter +1;
      data_array(l_counter) := title_array(1) || LPAD(NVL(TO_CHAR(ofa_rec.fed_stafford_loan_debt),' '),30) ||LPAD(NVL(TO_CHAR(file_rec.fed_stafford_loan_debt),' '),40);
   END IF;

   IF NVL(ofa_rec.fed_sls_debt,0) <> NVL(file_rec.fed_sls_debt,0) THEN
      l_counter  :=l_counter+1;
      data_array(l_counter) := title_array(2) || LPAD(NVL(TO_CHAR(ofa_rec.fed_sls_debt),' '),30) ||LPAD(NVL(TO_CHAR(file_rec.fed_sls_debt),' '),40);
   END IF;

   IF NVL(ofa_rec.heal_debt,0) <> NVL(file_rec.heal_debt,0) THEN
      l_counter  :=l_counter+1;
      data_array(l_counter) := title_array(3) || LPAD(NVL(TO_CHAR(ofa_rec.heal_debt),' '),30) ||LPAD(NVL(TO_CHAR(file_rec.heal_debt),' '),40);
   END IF;

   IF NVL(ofa_rec.perkins_debt,0) <> NVL(file_rec.perkins_debt,0) THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(4) || LPAD(NVL(TO_CHAR(ofa_rec.perkins_debt),' '),30) ||LPAD(NVL(TO_CHAR(file_rec.perkins_debt),' '),40);
   END IF;

   IF NVL(ofa_rec.other_debt,0) <> NVL(file_rec.other_debt,0) THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(5) || LPAD(NVL(TO_CHAR(ofa_rec.other_debt),' '),30) ||LPAD(NVL(TO_CHAR(file_rec.other_debt),' '),40);
   END IF;

   IF NVL(ofa_rec.crdt_undr_difft_name,' ') <> NVL(file_rec.crdt_undr_difft_name,' ') THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(6) || LPAD(NVL(ofa_rec.crdt_undr_difft_name,' '),30) ||LPAD(NVL(file_rec.crdt_undr_difft_name,' '),40);
   END IF;

   IF NVL(ofa_rec.borw_gross_annual_sal,0) <> NVL(file_rec.borw_gross_annual_sal,0) THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(7) || LPAD(NVL(TO_CHAR(ofa_rec.borw_gross_annual_sal),' '),30) ||LPAD(NVL(TO_CHAR(file_rec.borw_gross_annual_sal),' '),40);
   END IF;

   IF NVL(ofa_rec.borw_other_income,0) <> NVL(file_rec.borw_other_income,0) THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(8) || LPAD(NVL(TO_CHAR(ofa_rec.borw_other_income),' '),30) ||LPAD(NVL(TO_CHAR(file_rec.borw_other_income),' '),40);
   END IF;

   IF NVL(ofa_rec.student_major,' ') <> NVL(file_rec.student_major,' ') THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(9) || LPAD(NVL(ofa_rec.student_major,' '),30) ||LPAD(NVL(file_rec.student_major,' '),40);
   END IF;

   IF NVL(ofa_rec.int_rate_opt,' ') <> NVL(file_rec.int_rate_opt,' ') THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(10) || LPAD(NVL(ofa_rec.int_rate_opt,' '),30) ||LPAD(NVL(file_rec.int_rate_opt,' '),40);
   END IF;

   IF NVL(ofa_rec.repayment_opt_code,' ') <> NVL(file_rec.repayment_opt_code,' ') THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(11) || LPAD(NVL(ofa_rec.repayment_opt_code,' '),30) ||LPAD(NVL(file_rec.repayment_opt_code,' '),40);
   END IF;

   IF NVL(ofa_rec.stud_mth_housing_pymt,0) <> NVL(file_rec.stud_mth_housing_pymt,0) THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(12) || LPAD(NVL(TO_CHAR(ofa_rec.stud_mth_housing_pymt),' '),30) ||LPAD(NVL(TO_CHAR(file_rec.stud_mth_housing_pymt),' '),40);
   END IF;

   IF NVL(ofa_rec.stud_mth_crdtcard_pymt,0) <> NVL(file_rec.stud_mth_crdtcard_pymt,0) THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(13) || LPAD(NVL(TO_CHAR(ofa_rec.stud_mth_crdtcard_pymt), ' ') ,30)|| LPAD( NVL(TO_CHAR(file_rec.stud_mth_crdtcard_pymt), ' '), 40);
   END IF;

   IF NVL(ofa_rec.stud_mth_auto_pymt,0) <> NVL(file_rec.stud_mth_auto_pymt,0) THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(14) || LPAD(NVL(TO_CHAR(ofa_rec.stud_mth_auto_pymt),' '),30) ||LPAD(NVL(TO_CHAR(file_rec.stud_mth_auto_pymt),' '),40);
  END IF;

  IF NVL(ofa_rec.stud_mth_ed_loan_pymt,0) <> NVL(file_rec.stud_mth_ed_loan_pymt,0) THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(15) || LPAD(NVL(TO_CHAR(ofa_rec.stud_mth_ed_loan_pymt),' '),30) ||LPAD(NVL(TO_CHAR(file_rec.stud_mth_ed_loan_pymt),' '),40);
  END IF;

  IF NVL(ofa_rec.stud_mth_other_pymt,0) <> NVL(file_rec.stud_mth_other_pymt,0) THEN
       l_counter  :=l_counter+1;
       data_array(l_counter) := title_array(16) ||LPAD(NVL(TO_CHAR(ofa_rec.stud_mth_other_pymt),' '),30) ||LPAD(NVL(TO_CHAR(file_rec.stud_mth_other_pymt),' '),40);
  END IF;

  --To display the ALt Borrower's Details

  fnd_file.put_line(fnd_file.log, '');

--To display the Heading for Fields having a difference and also the corresponding data

  IF l_counter <> 0 THEN
       BEGIN

         fnd_file.put_line(fnd_file.log, RPAD(' ',5)|| title_array(17) || title_array(18));
         fnd_file.put_line(fnd_file.log, RPAD(' ',5)||RPAD(' ',50)||RPAD('-',34,'-')||' '||RPAD('-',35,'-'));

         FOR i IN  1..l_counter LOOP
           fnd_file.put_line(fnd_file.log, RPAD(' ',5)||data_array(i));
         END LOOP;

       END;

       --Deleting the Data Stored in the array.
       data_array.DELETE;

  END IF;

  gv_debug_str := gv_debug_str || 'SHOW_ALT_DETAILS - 2 ' || ' ';

EXCEPTION

 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_CL_ORIG_ACK.SHOW_ALT_DETAILS');
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.show_alt_details.exception',gv_debug_str||' '|| SQLERRM);
     END IF;
     gv_debug_str := '';
     igs_ge_msg_stack.add;
     app_exception.raise_exception;

END show_alt_details;


PROCEDURE log_to_fnd ( p_v_module IN VARCHAR2,
                       p_v_string IN VARCHAR2
                     ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 21 October 2004
--
-- Purpose:
-- Invoked     : from within create_file procedure
-- Function    : Private procedure for logging all the statement level
--               messages
-- Parameters  : p_v_module   : IN parameter. Required.
--               p_v_string   : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
BEGIN
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig_ack.'||p_v_module, p_v_string);
  END IF;
END log_to_fnd;

PROCEDURE process_borrow_stud_rec (p_rec_resp_r1  IN  igf_sl_cl_resp_r1_all%ROWTYPE) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 05 November 2004
--
-- Purpose:
-- Invoked     : from within process_1 procedure
-- Function    : Private procedure for processing borrower student data
--               available in the response record
-- Parameters  : p_rec_resp_r1   : IN  parameter. Required.
--
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  l_rec_resp_r1        igf_sl_cl_resp_r1_all%ROWTYPE;
  l_b_pers_exists      BOOLEAN;
  l_b_ret_status       BOOLEAN;
  l_c_borrow_created   VARCHAR2(1);
  l_c_student_created  VARCHAR2(1);
  l_c_rel_created      VARCHAR2(1);
  l_n_student_id       hz_parties.party_id%TYPE;
  l_n_borrower_id      hz_parties.party_id%TYPE;
  l_v_student_number   hz_parties.party_number%TYPE;
  l_v_borrower_number  hz_parties.party_number%TYPE;
  l_n_person_id        hz_parties.party_id%TYPE;
  l_v_person_number    hz_parties.party_number%TYPE;
BEGIN
  log_to_fnd(p_v_module => 'process_borrow_stud_rec',
             p_v_string => ' p_rec_resp_r1.b_ssn              : ' || p_rec_resp_r1.b_ssn              ||
                           ' p_rec_resp_r1.b_last_name        : ' || p_rec_resp_r1.b_last_name        ||
                           ' p_rec_resp_r1.b_first_name       : ' || p_rec_resp_r1.b_first_name       ||
                           ' p_rec_resp_r1.b_middle_name      : ' || p_rec_resp_r1.b_middle_name      ||
                           ' p_rec_resp_r1.b_permt_addr1      : ' || p_rec_resp_r1.b_permt_addr1      ||
                           ' p_rec_resp_r1.b_permt_addr2      : ' || p_rec_resp_r1.b_permt_addr2      ||
                           ' p_rec_resp_r1.b_permt_city       : ' || p_rec_resp_r1.b_permt_city       ||
                           ' p_rec_resp_r1.b_permt_state      : ' || p_rec_resp_r1.b_permt_state      ||
                           ' p_rec_resp_r1.b_date_of_birth    : ' || p_rec_resp_r1.b_date_of_birth    ||
                           ' p_rec_resp_r1.s_ssn              : ' || p_rec_resp_r1.s_ssn              ||
                           ' p_rec_resp_r1.s_last_name        : ' || p_rec_resp_r1.s_last_name        ||
                           ' p_rec_resp_r1.s_first_name       : ' || p_rec_resp_r1.s_first_name       ||
                           ' p_rec_resp_r1.s_middle_name      : ' || p_rec_resp_r1.s_middle_name      ||
                           ' p_rec_resp_r1.s_date_of_birth    : ' || p_rec_resp_r1.s_date_of_birth    ||
                           ' p_rec_resp_r1.cl_loan_type       : ' || p_rec_resp_r1.cl_loan_type       ||
                           ' p_rec_resp_r1.b_indicator_code   : ' || p_rec_resp_r1.b_indicator_code
            );
  log_to_fnd(p_v_module => 'process_borrow_stud_rec',
             p_v_string => ' School Certification Request information '||
                           ' Loan Type = '|| p_rec_resp_r1.cl_loan_type
            );
  l_rec_resp_r1 := p_rec_resp_r1;
  -- plus loans
  IF l_rec_resp_r1.cl_loan_type = 'PL' THEN
    -- Check if the Borrower exists in the System by querying on active SSNs in the System
    IF l_rec_resp_r1.b_first_name IS NOT NULL THEN
      l_n_borrower_id      := NULL;
      l_v_borrower_number  := NULL;
      l_b_pers_exists      := FALSE;
      log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                 p_v_string => ' Borrower information. Invoking perform_ssn_match '
                 );
      perform_ssn_match(
        p_rec_resp_r1     => l_rec_resp_r1,
        p_c_pers_typ_ind  => 'B',
        p_n_person_id     => l_n_borrower_id,
        p_n_person_number => l_v_borrower_number,
        p_c_pers_exists   => l_b_pers_exists
      );
      -- if matching SSN found, do not create the borrower person record
      IF (l_b_pers_exists) THEN
        l_c_borrow_created := 'Y';  -- pssahni 18-Jan-2005  We need to create relationship even if the person exsists
        log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                   p_v_string => ' Borrower information found in the system: '||
                                 ' Borrower Id '    ||l_n_borrower_id         ||
                                 ' Borrower Number '||l_v_borrower_number
                   );
      ELSE
      -- no matching SSN found
      -- create the borrower person record
        l_b_ret_status := FALSE;
        l_b_ret_status := create_person_record(
                           p_rec_resp_r1     => l_rec_resp_r1,
                           p_c_pers_typ_ind  => 'B',
                           p_n_person_id     => l_n_borrower_id,
                           p_n_person_number => l_v_borrower_number
                         );
        -- if person creation failed set the borrower created flag to 'N'
        IF NOT(l_b_ret_status) THEN
          l_c_borrow_created := 'N';
        ELSE
        -- if person creation is successful set the borrower created flag to 'Y'
          l_c_borrow_created := 'Y';
        END IF;
      END IF;
    END IF;
    -- Check if the Student exists in the System by querying on active SSNs in the System.
    IF l_rec_resp_r1.s_first_name IS NOT NULL THEN
      l_n_student_id     := NULL;
      l_v_student_number := NULL;
      l_b_pers_exists    := FALSE;
      log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                 p_v_string => ' Student information. Invoking perform_ssn_match '
                 );
      perform_ssn_match(
        p_rec_resp_r1     => l_rec_resp_r1,
        p_c_pers_typ_ind  => 'S',
        p_n_person_id     => l_n_student_id,
        p_n_person_number => l_v_student_number,
        p_c_pers_exists   => l_b_pers_exists
      );
      -- if matching SSN found, do not create the Student person record
      IF (l_b_pers_exists) THEN
        l_c_student_created := 'Y';   -- pssahni 18-Jan-2005  We need to create relationship even if the person exsists
        log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                   p_v_string => ' Student information found in the system: '||
                                 ' Student Id '    ||l_n_student_id          ||
                                 ' Student Number '||l_v_student_number
                   );
      ELSE
      -- no matching SSN found
      -- create the Student person record
        l_b_ret_status := FALSE;
        l_b_ret_status := create_person_record(
                           p_rec_resp_r1     => l_rec_resp_r1,
                           p_c_pers_typ_ind  => 'S',
                           p_n_person_id     => l_n_student_id,
                           p_n_person_number => l_v_student_number
                         );
        -- if person creation failed set the Student created flag to 'N'
        IF NOT(l_b_ret_status) THEN
          l_c_student_created := 'N';
        ELSE
        -- if person creation is successful set the Student created flag to 'Y'
          l_c_student_created := 'Y';
        END IF;
      END IF;
    END IF;
    -- Create relation between borrower and Student if Student created flag to 'Y' and borrower created flag to 'Y'
    l_c_rel_created  := 'N';
    IF l_c_student_created = 'Y' AND l_c_borrow_created = 'Y' THEN
      l_b_ret_status := FALSE;
      l_b_ret_status := create_borrow_stud_rel (
                          p_n_borrower_id     => l_n_borrower_id,
                          p_v_borrower_number => l_v_borrower_number,
                          p_n_student_id      => l_n_student_id,
                          p_v_student_number  => l_v_student_number
                        ) ;
      -- if relation creation is successful set the relation created flag to 'Y'
      -- if relation creation is not successful set the relation created flag to 'N'
      IF (l_b_ret_status) THEN
        l_c_rel_created := 'Y';
      END IF;
    END IF;
    -- raise the business event
    raise_scr_event(
      p_rec_resp_r1       => l_rec_resp_r1,
      p_c_borrow_created  => l_c_borrow_created,
      p_c_student_created => l_c_student_created,
      p_c_rel_created     => l_c_rel_created
    );
  END IF;

  --akomurav
  --Grad Plus Loans

  IF l_rec_resp_r1.cl_loan_type = 'GB' THEN
     l_c_borrow_created  :=  'N';
     l_c_student_created := 'N';
     IF l_rec_resp_r1.s_ssn = l_rec_resp_r1.b_ssn THEN
        l_n_person_id :=NULL;
        l_v_person_number  :=NULL;
        l_b_pers_exists  := FALSE;

        perform_ssn_match(
        p_rec_resp_r1     => l_rec_resp_r1,
        p_c_pers_typ_ind  => 'B', -- Borrower or Student (both will work)
        p_n_person_id     => l_n_person_id,
        p_n_person_number => l_v_person_number,
        p_c_pers_exists   => l_b_pers_exists
        );
        -- if matching SSN found, do not create the Student person record
        IF (l_b_pers_exists) THEN
           l_c_borrow_created  := 'Y';
           l_c_student_created := 'Y';
        ELSE
           l_b_ret_status := FALSE;
           l_b_ret_status := create_person_record(
              p_rec_resp_r1     => l_rec_resp_r1,
              p_c_pers_typ_ind  => 'B', -- Borrower or Student (both with work)
              p_n_person_id     => l_n_person_id,
              p_n_person_number => l_v_person_number);

           IF NOT(l_b_ret_status) THEN
           -- If ret status is false means Borrower is not created implying student is also not created.
              l_c_borrow_created  :=  'N';
              l_c_student_created := 'N';
           ELSE
              l_c_borrow_created  := 'Y';
              l_c_student_created := 'Y';
           END IF;
        END IF;
     END IF;
     raise_scr_event(
       p_rec_resp_r1       => l_rec_resp_r1,
       p_c_borrow_created  => l_c_borrow_created,
       p_c_student_created => l_c_student_created,
       p_c_rel_created     => 'N'
      );
  END IF;

  -- Alternate loans
  IF l_rec_resp_r1.cl_loan_type = 'AL' THEN
    -- No relation would be created. Hence set the relation created flag to 'N' for alternate loans.
    l_c_rel_created := 'N';
    -- check If the Student himself/herself is Borrower
    IF (l_rec_resp_r1.b_indicator_code = 'Y') THEN
      -- Check if the Student exists in the System by querying on active SSNs in the System.
      IF l_rec_resp_r1.s_first_name IS NOT NULL THEN
        l_n_student_id     := NULL;
        l_v_student_number := NULL;
        l_b_pers_exists    := FALSE;
        log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                   p_v_string => ' Student information. Invoking perform_ssn_match '
                  );
        perform_ssn_match(
          p_rec_resp_r1     => l_rec_resp_r1,
          p_c_pers_typ_ind  => 'S',
          p_n_person_id     => l_n_student_id,
          p_n_person_number => l_v_student_number,
          p_c_pers_exists   => l_b_pers_exists
        );
        -- if matching SSN found, do not create the Student person record
        IF (l_b_pers_exists) THEN
          l_c_student_created := 'N';
          l_c_borrow_created  := 'N';
          log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                     p_v_string => ' Student information found in the system: '||
                                   ' Student Id '    ||l_n_student_id          ||
                                   ' Student Number '||l_v_student_number
                     );
        ELSE
        -- no matching SSN found
        -- create the Student person record
          l_b_ret_status := FALSE;
          l_b_ret_status := create_person_record(
                              p_rec_resp_r1     => l_rec_resp_r1,
                              p_c_pers_typ_ind  => 'S',
                              p_n_person_id     => l_n_student_id,
                              p_n_person_number => l_v_student_number
                            );
          -- if person creation failed set the Student created flag to 'N'
          IF NOT(l_b_ret_status) THEN
            l_c_student_created := 'N';
            l_c_borrow_created  := 'N';
          ELSE
          -- if person creation is successful set the Student created flag to 'Y'
            l_c_student_created := 'Y';
            l_c_borrow_created  := 'Y';
          END IF;
        END IF;
      END IF;
    -- If the Student himself/herself is not a loan Borrower
    ELSIF (l_rec_resp_r1.b_indicator_code = 'N') THEN
      IF l_rec_resp_r1.b_first_name IS NOT NULL THEN
        l_n_borrower_id      := NULL;
        l_v_borrower_number  := NULL;
        l_b_pers_exists      := FALSE;
        log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                   p_v_string => ' Borrower information. Invoking perform_ssn_match '
                   );
        perform_ssn_match(
          p_rec_resp_r1     => l_rec_resp_r1,
          p_c_pers_typ_ind  => 'B',
          p_n_person_id     => l_n_borrower_id,
          p_n_person_number => l_v_borrower_number,
          p_c_pers_exists   => l_b_pers_exists
        );
        -- if matching SSN found, do not create the borrower person record
        IF (l_b_pers_exists) THEN
          l_c_borrow_created := 'N';
          log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                     p_v_string => ' Borrower information found in the system: '||
                                   ' Borrower Id '    ||l_n_borrower_id         ||
                                   ' Borrower Number '||l_v_borrower_number
                    );
        ELSE
        -- no matching SSN found
        -- create the borrower person record
          l_b_ret_status := FALSE;
          l_b_ret_status := create_person_record(
                              p_rec_resp_r1     => l_rec_resp_r1,
                              p_c_pers_typ_ind  => 'B',
                              p_n_person_id     => l_n_borrower_id,
                              p_n_person_number => l_v_borrower_number
                            );
          -- if person creation failed set the borrower created flag to 'N'
          IF NOT(l_b_ret_status) THEN
            l_c_borrow_created := 'N';
          ELSE
          -- if person creation is successful set the borrower created flag to 'Y'
            l_c_borrow_created := 'Y';
          END IF;
        END IF;
      END IF;
      -- Check if the Student exists in the System by querying on active SSNs in the System.
      IF l_rec_resp_r1.s_first_name IS NOT NULL THEN
        l_n_student_id     := NULL;
        l_v_student_number := NULL;
        l_b_pers_exists    := FALSE;
        log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                   p_v_string => ' Student information. Invoking perform_ssn_match '
                   );
        perform_ssn_match(
          p_rec_resp_r1     => l_rec_resp_r1,
          p_c_pers_typ_ind  => 'S',
          p_n_person_id     => l_n_student_id,
          p_n_person_number => l_v_student_number,
          p_c_pers_exists   => l_b_pers_exists
        );
        -- if matching SSN found, do not create the Student person record
        IF (l_b_pers_exists) THEN
          l_c_student_created := 'N';
          log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                     p_v_string => ' Student information found in the system: '||
                                   ' Student Id '    ||l_n_student_id          ||
                                   ' Student Number '||l_v_student_number
                    );
        ELSE
        -- no matching SSN found
        -- create the Student person record
          l_b_ret_status := FALSE;
          l_b_ret_status := create_person_record(
                              p_rec_resp_r1     => l_rec_resp_r1,
                              p_c_pers_typ_ind  => 'S',
                              p_n_person_id     => l_n_student_id,
                              p_n_person_number => l_v_student_number
                            );
          -- if person creation failed set the Student created flag to 'N'
          IF NOT(l_b_ret_status) THEN
            l_c_student_created := 'N';
          ELSE
          -- if person creation is successful set the Student created flag to 'Y'
            l_c_student_created := 'Y';
          END IF;
        END IF;
      END IF;
    END IF;
    -- raise the business event
    raise_scr_event(
      p_rec_resp_r1       => l_rec_resp_r1,
      p_c_borrow_created  => l_c_borrow_created,
      p_c_student_created => l_c_student_created,
      p_c_rel_created     => l_c_rel_created
    );
  END IF;

-- pssahni 18-Jan-2005
-- Bug 	4125359 Person to be created for stafford loan also
  IF l_rec_resp_r1.cl_loan_type IN ('CS','SF','SU') THEN
    -- Check if the Borrower exists in the System by querying on active SSNs in the System
    IF l_rec_resp_r1.b_first_name IS NOT NULL THEN
      l_n_borrower_id      := NULL;
      l_v_borrower_number  := NULL;
      l_b_pers_exists      := FALSE;
      log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                 p_v_string => ' Borrower information. Invoking perform_ssn_match '
                 );
      perform_ssn_match(
        p_rec_resp_r1     => l_rec_resp_r1,
        p_c_pers_typ_ind  => 'B',
        p_n_person_id     => l_n_borrower_id,
        p_n_person_number => l_v_borrower_number,
        p_c_pers_exists   => l_b_pers_exists
      );
      -- if matching SSN found, do not create the borrower person record
      IF (l_b_pers_exists) THEN
        l_c_borrow_created := 'Y';
        log_to_fnd(p_v_module => 'process_borrow_stud_rec',
                   p_v_string => ' Borrower information found in the system: '||
                                 ' Borrower Id '    ||l_n_borrower_id         ||
                                 ' Borrower Number '||l_v_borrower_number
                   );
      ELSE
      -- no matching SSN found
      -- create the borrower person record
        l_b_ret_status := FALSE;
        l_b_ret_status := create_person_record(
                           p_rec_resp_r1     => l_rec_resp_r1,
                           p_c_pers_typ_ind  => 'B',
                           p_n_person_id     => l_n_borrower_id,
                           p_n_person_number => l_v_borrower_number
                         );
        -- if person creation failed set the borrower created flag to 'N'
        IF NOT(l_b_ret_status) THEN
          l_c_borrow_created := 'N';
        ELSE
        -- if person creation is successful set the borrower created flag to 'Y'
          l_c_borrow_created := 'Y';
        END IF;
      END IF;
    END IF;

    l_c_student_created := 'N';
    l_c_rel_created := 'N';
    -- raise the business event
    raise_scr_event(
      p_rec_resp_r1       => l_rec_resp_r1,
      p_c_borrow_created  => l_c_borrow_created,
      p_c_student_created => l_c_student_created,
      p_c_rel_created     => l_c_rel_created
    );
  END IF;


END process_borrow_stud_rec;


PROCEDURE perform_ssn_match(p_rec_resp_r1     IN  igf_sl_cl_resp_r1_all%ROWTYPE,
                            p_c_pers_typ_ind  IN  VARCHAR2,
                            p_n_person_id     OUT NOCOPY hz_parties.party_id%TYPE,
                            p_n_person_number OUT NOCOPY hz_parties.party_number%TYPE,
                            p_c_pers_exists   OUT NOCOPY BOOLEAN
                            )  AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 21 October 2004
--
-- Purpose:
-- Invoked     : from within process_borrow_stud_rec procedure
-- Function    : Private function for checking the matching SSN
--
-- Parameters  : p_rec_resp_r1      : IN  parameter. Required.
--               p_n_person_id      : OUT parameter.
--               p_n_person_number  : OUT parameter.
--               p_c_pers_exists    : OUT parameter. Returns whether person
--                                    with Active SSN exists in the System or not
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  CURSOR  c_ssn(cp_v_ssn  igs_pe_alt_pers_id.api_person_id_uf%TYPE) IS
  SELECT  'OSS'            person_rec_type --source of ssn from OSS
         ,hz.party_number  person_number
         ,hz.party_id      person_id
         ,api_person_id_uf prsn_ssn --unformatted ssn value
         ,hz.person_first_name firstname
         ,hz.person_last_name  lastname
  FROM    igs_pe_alt_pers_id api
         ,igs_pe_person_id_typ pit
         ,hz_parties hz
  WHERE   api.person_id_type   = pit.person_id_type
  AND     pit.s_person_id_type = 'SSN'
  AND     hz.party_id          = api.pe_person_id
  AND    (SYSDATE) BETWEEN api.start_dt AND NVL (api.end_dt, SYSDATE)
  AND     api.api_person_id_uf = cp_v_ssn
  UNION
  SELECT  'HRMS'          person_rec_type --source of ssn from HRMS
         ,hz.party_number person_number
         ,ppf.party_id    person_id
         ,igf_gr_gen.get_ssn_digits(ppf.national_identifier) prsn_ssn
         ,hz.person_first_name firstname
         ,hz.person_last_name  lastname
  FROM    per_all_people_f ppf
         ,per_business_groups_perf pbg
         ,per_person_types         ppt
         ,hz_parties               hz
         ,hz_person_profiles       hp
  WHERE   igs_en_gen_001.check_hrms_installed = 'Y'
  AND     pbg.legislation_code   = 'US'
  AND     ppt.system_person_type = 'EMP'
  AND     ppt.person_type_id     = ppf.person_type_id
  AND     pbg.business_group_id  = ppf.business_group_id
  AND     TRUNC(SYSDATE) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
  AND     ppf.party_id           = hz.party_id
  AND     hp.effective_end_date IS NULL
  AND     igf_ap_matching_process_pkg.remove_spl_chr(ppf.national_identifier) = cp_v_ssn;

  TYPE tab_firstname_typ IS TABLE OF hz_parties.person_first_name%TYPE;
  TYPE tab_lastname_typ  IS TABLE OF hz_parties.person_last_name%TYPE;
  TYPE tab_prsn_ssn_typ  IS TABLE OF igs_pe_alt_pers_id.api_person_id_uf%TYPE;
  TYPE tab_personid_typ  IS TABLE OF hz_parties.party_id%TYPE;
  TYPE tab_personnum_typ IS TABLE OF hz_parties.party_number%TYPE;
  TYPE tab_rec_typ       IS TABLE OF VARCHAR2(30);

  v_tab_firstname_typ       tab_firstname_typ;
  v_tab_lastname_typ        tab_lastname_typ ;
  v_tab_prsn_ssn_typ        tab_prsn_ssn_typ ;
  v_tab_personid_typ        tab_personid_typ ;
  v_tab_personnum_typ       tab_personnum_typ;
  v_tab_rec_typ             tab_rec_typ      ;

  l_v_ssn             igf_ap_isir_ints_all.current_ssn_txt%TYPE;
  l_c_per_oss_exists  BOOLEAN;
  l_n_cnt             NUMBER;
BEGIN
  log_to_fnd(p_v_module => ' Entered Procedure perform_ssn_match. The input parameters are',
             p_v_string => ' p_rec_resp_r1.b_ssn              : ' || p_rec_resp_r1.b_ssn              ||
                           ' p_rec_resp_r1.b_last_name        : ' || p_rec_resp_r1.b_last_name        ||
                           ' p_rec_resp_r1.b_first_name       : ' || p_rec_resp_r1.b_first_name       ||
                           ' p_rec_resp_r1.b_middle_name      : ' || p_rec_resp_r1.b_middle_name      ||
                           ' p_rec_resp_r1.b_permt_addr1      : ' || p_rec_resp_r1.b_permt_addr1      ||
                           ' p_rec_resp_r1.b_permt_addr2      : ' || p_rec_resp_r1.b_permt_addr2      ||
                           ' p_rec_resp_r1.b_permt_city       : ' || p_rec_resp_r1.b_permt_city       ||
                           ' p_rec_resp_r1.b_permt_state      : ' || p_rec_resp_r1.b_permt_state      ||
                           ' p_rec_resp_r1.b_date_of_birth    : ' || p_rec_resp_r1.b_date_of_birth    ||
                           ' p_rec_resp_r1.s_ssn              : ' || p_rec_resp_r1.s_ssn              ||
                           ' p_rec_resp_r1.s_last_name        : ' || p_rec_resp_r1.s_last_name        ||
                           ' p_rec_resp_r1.s_first_name       : ' || p_rec_resp_r1.s_first_name       ||
                           ' p_rec_resp_r1.s_middle_name      : ' || p_rec_resp_r1.s_middle_name      ||
                           ' p_rec_resp_r1.s_date_of_birth    : ' || p_rec_resp_r1.s_date_of_birth    ||
                           ' p_rec_resp_r1.cl_loan_type       : ' || p_rec_resp_r1.cl_loan_type       ||
                           ' p_rec_resp_r1.b_indicator_code   : ' || p_rec_resp_r1.b_indicator_code
            );

  l_c_per_oss_exists := FALSE;

  IF p_c_pers_typ_ind = 'B' THEN
    l_v_ssn  := p_rec_resp_r1.b_ssn ;
  ELSIF p_c_pers_typ_ind = 'S' THEN
    l_v_ssn  := p_rec_resp_r1.s_ssn ;
  END IF;

  log_to_fnd(p_v_module => 'perform_ssn_match',
             p_v_string => ' verifying if already the pl/sql tables exist. '||
                           ' If exists truncate all the elements'
            );
  -- if the pl/sql table exists , re initialize these by deleting all elements of the array
  IF v_tab_firstname_typ.EXISTS(1) THEN
    v_tab_firstname_typ.DELETE;
  END IF;

  IF v_tab_lastname_typ.EXISTS(1) THEN
    v_tab_lastname_typ.DELETE;
  END IF;

  IF v_tab_prsn_ssn_typ.EXISTS(1) THEN
    v_tab_prsn_ssn_typ.DELETE;
  END IF;

  IF v_tab_personid_typ.EXISTS(1) THEN
    v_tab_personid_typ.DELETE;
  END IF;

  IF v_tab_personnum_typ.EXISTS(1) THEN
    v_tab_personnum_typ.DELETE;
  END IF;

  IF v_tab_rec_typ.EXISTS(1) THEN
    v_tab_rec_typ.DELETE;
  END IF;
  log_to_fnd(p_v_module => 'perform_ssn_match',
             p_v_string => ' Querying on active SSNs in the System. '
            );
  OPEN  c_ssn (cp_v_ssn => l_v_ssn);
  FETCH c_ssn  BULK COLLECT INTO v_tab_rec_typ,
                                 v_tab_personnum_typ,
                                 v_tab_personid_typ,
                                 v_tab_prsn_ssn_typ,
                                 v_tab_firstname_typ,
                                 v_tab_lastname_typ;
  CLOSE c_ssn;
  IF v_tab_firstname_typ.COUNT = 0 THEN

    log_to_fnd(p_v_module => 'perform_ssn_match',
               p_v_string => ' No active SSNs found in the System. creating person record'
              );
    fnd_message.set_name('IGF','IGF_SL_CL_SCR_P_NOFOUND');
    fnd_message.set_token('SSN',l_v_ssn);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    p_n_person_id     := NULL;
    p_n_person_number := NULL;
    p_c_pers_exists   := FALSE;
    RETURN;
  END IF;
  log_to_fnd(p_v_module => 'perform_ssn_match',
             p_v_string => ' Active SSN Records found. Performing SSN match'
            );

  FOR l_n_cnt IN v_tab_personid_typ.FIRST..v_tab_personid_typ.LAST
  LOOP
    log_to_fnd(p_v_module => 'perform_ssn_match',
               p_v_string => v_tab_rec_typ (l_n_cnt)
              );
    IF v_tab_rec_typ(l_n_cnt) IN ('OSS','HRMS') THEN
      log_to_fnd(p_v_module => 'perform_ssn_match',
                 p_v_string => 'Active SSNs found in the OSS System.'
                );
      p_n_person_id     := v_tab_personid_typ(l_n_cnt);
      p_n_person_number := v_tab_personnum_typ(l_n_cnt);
      p_c_pers_exists   := TRUE;
      fnd_message.set_name('IGF','IGF_SL_CL_SCR_P_FOUND');
      fnd_message.set_token('SSN',l_v_ssn);
      fnd_message.set_token('PERSON_NUMBER',p_n_person_number);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      EXIT;
    END IF;
  END LOOP;

END perform_ssn_match;

FUNCTION create_person_record(p_rec_resp_r1     IN  igf_sl_cl_resp_r1_all%ROWTYPE,
                              p_c_pers_typ_ind  IN  VARCHAR2,
                              p_n_person_id     OUT NOCOPY hz_parties.party_id%TYPE,
                              p_n_person_number OUT NOCOPY hz_parties.party_number%TYPE
                              )
RETURN BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 21 October 2004
--
-- Purpose:
-- Invoked     : from within process_borrow_stud_rec procedure
-- Function    : Private function for creating person record
--
-- Parameters  : p_hz_parties_rec   : IN parameter. Required.
--               p_n_person_id      : OUT parameter.
--               p_n_person_number  : OUT parameter.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  CURSOR c_person_id_type( cp_v_pers_id_type   VARCHAR2 ) IS
  SELECT person_id_type
  FROM   igs_pe_person_id_typ
  WHERE  s_person_id_type = cp_v_pers_id_type ;


  l_n_msg_count            NUMBER ;
  l_v_msg_data             VARCHAR2(1000);
  l_v_return_status        VARCHAR2(10);
  l_v_rowid                ROWID;
  l_n_person_id            hz_parties.party_id%TYPE;
  l_v_person_number        hz_parties.party_number%TYPE;
  l_v_person_id_type       igs_pe_person_id_typ.person_id_type%TYPE;
  l_n_location_ovn         hz_locations.object_version_number%TYPE;
  l_rec_resp_r1            igf_sl_cl_resp_r1_all%ROWTYPE;
  l_v_ssn                  igf_ap_isir_ints_all.current_ssn_txt%TYPE;
  l_v_person_first_name    hz_parties.person_first_name%TYPE;
  l_v_person_last_name     hz_parties.person_last_name%TYPE;
  l_v_person_middle_name   hz_parties.person_middle_name%TYPE;
  l_d_date_of_birth        igs_pe_person.birth_dt%TYPE;
  l_b_ret_status           BOOLEAN;
BEGIN

 log_to_fnd(p_v_module => 'create_person_record',
             p_v_string => ' p_rec_resp_r1.b_ssn              : ' || p_rec_resp_r1.b_ssn              ||
                           ' p_rec_resp_r1.b_last_name        : ' || p_rec_resp_r1.b_last_name        ||
                           ' p_rec_resp_r1.b_first_name       : ' || p_rec_resp_r1.b_first_name       ||
                           ' p_rec_resp_r1.b_middle_name      : ' || p_rec_resp_r1.b_middle_name      ||
                           ' p_rec_resp_r1.b_permt_addr1      : ' || p_rec_resp_r1.b_permt_addr1      ||
                           ' p_rec_resp_r1.b_permt_addr2      : ' || p_rec_resp_r1.b_permt_addr2      ||
                           ' p_rec_resp_r1.b_permt_city       : ' || p_rec_resp_r1.b_permt_city       ||
                           ' p_rec_resp_r1.b_permt_state      : ' || p_rec_resp_r1.b_permt_state      ||
                           ' p_rec_resp_r1.b_date_of_birth    : ' || p_rec_resp_r1.b_date_of_birth    ||
                           ' p_rec_resp_r1.s_ssn              : ' || p_rec_resp_r1.s_ssn              ||
                           ' p_rec_resp_r1.s_last_name        : ' || p_rec_resp_r1.s_last_name        ||
                           ' p_rec_resp_r1.s_first_name       : ' || p_rec_resp_r1.s_first_name       ||
                           ' p_rec_resp_r1.s_middle_name      : ' || p_rec_resp_r1.s_middle_name      ||
                           ' p_rec_resp_r1.s_date_of_birth    : ' || p_rec_resp_r1.s_date_of_birth    ||
                           ' p_rec_resp_r1.cl_loan_type       : ' || p_rec_resp_r1.cl_loan_type       ||
                           ' p_rec_resp_r1.b_indicator_code   : ' || p_rec_resp_r1.b_indicator_code
            );

  OPEN  c_person_id_type (cp_v_pers_id_type => 'SSN');
  FETCH c_person_id_type INTO l_v_person_id_type;
  IF c_person_id_type%NOTFOUND THEN
    log_to_fnd(p_v_module => 'create_person_record',
               p_v_string => ' Alternate Person ID of type SSN is not setup. Unable to create SSN record for the student.'
              );
    fnd_message.set_name('IGF','IGF_SL_CL_SCR_P_FAIL');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    log_to_fnd(p_v_module => 'create_person_record',
               p_v_string => ' Person creation failed '
              );
    p_n_person_id      := NULL;
    p_n_person_number  := NULL;
    RETURN FALSE;
  END IF;
  CLOSE c_person_id_type;

  l_rec_resp_r1       := p_rec_resp_r1;

  IF p_c_pers_typ_ind = 'B' THEN
    l_v_ssn                :=  l_rec_resp_r1.b_ssn ;
    l_v_person_first_name  :=  l_rec_resp_r1.b_first_name;
    l_v_person_last_name   :=  l_rec_resp_r1.b_last_name;
    l_v_person_middle_name :=  l_rec_resp_r1.b_middle_name;
    l_d_date_of_birth      :=  l_rec_resp_r1.b_date_of_birth;
  ELSIF p_c_pers_typ_ind = 'S' THEN
    l_v_ssn                :=  l_rec_resp_r1.s_ssn ;
    l_v_person_first_name  :=  l_rec_resp_r1.s_first_name;
    l_v_person_last_name   :=  l_rec_resp_r1.s_last_name;
    l_v_person_middle_name :=  l_rec_resp_r1.s_middle_name;
    l_d_date_of_birth      :=  l_rec_resp_r1.s_date_of_birth;
  END IF;


  l_v_rowid           := NULL;
  l_n_person_id       := NULL;
  l_v_person_number   := NULL;
  l_n_location_ovn    := NULL;

  log_to_fnd(p_v_module => 'create_person_record',
             p_v_string => ' Invoking igs_pe_person_pkg.insert_row '
            );

  igs_pe_person_pkg.insert_row
  (
    x_msg_count                => l_n_msg_count,
    x_msg_data                 => l_v_msg_data,
    x_return_status            => l_v_return_status,
    x_rowid                    => l_v_rowid,
    x_person_id                => l_n_person_id,
    x_person_number            => l_v_person_number,
    x_surname                  => INITCAP(l_v_person_last_name),
    x_middle_name              => l_v_person_middle_name,
    x_given_names              => INITCAP(l_v_person_first_name),
    x_sex                      => NULL,
    x_title                    => NULL,
    x_staff_member_ind         => NULL,
    x_deceased_ind             => NULL,
    x_suffix                   => NULL,
    x_pre_name_adjunct         => NULL,
    x_archive_exclusion_ind    => NULL,
    x_archive_dt               => NULL,
    x_purge_exclusion_ind      => NULL,
    x_purge_dt                 => NULL,
    x_deceased_date            => NULL,
    x_proof_of_ins             => NULL,
    x_proof_of_immu            => NULL,
    x_birth_dt                 => l_d_date_of_birth,
    x_salutation               => NULL,
    x_oracle_username          => NULL,
    x_preferred_given_name     => NULL,
    x_email_addr               => NULL,
    x_level_of_qual_id         => NULL,
    x_military_service_reg     => NULL,
    x_veteran                  => NULL,
    x_hz_parties_ovn           => l_n_location_ovn,
    x_attribute_category       => NULL,
    x_attribute1               => NULL,
    x_attribute2               => NULL,
    x_attribute3               => NULL,
    x_attribute4               => NULL,
    x_attribute5               => NULL,
    x_attribute6               => NULL,
    x_attribute7               => NULL,
    x_attribute8               => NULL,
    x_attribute9               => NULL,
    x_attribute10              => NULL,
    x_attribute11              => NULL,
    x_attribute12              => NULL,
    x_attribute13              => NULL,
    x_attribute14              => NULL,
    x_attribute15              => NULL,
    x_attribute16              => NULL,
    x_attribute17              => NULL,
    x_attribute18              => NULL,
    x_attribute19              => NULL,
    x_attribute20              => NULL,
    x_person_id_type           => l_v_person_id_type,
    x_api_person_id            => igf_ap_matching_process_pkg.format_ssn(l_v_ssn)/*,
    x_attribute21              => NULL,
    x_attribute22              => NULL,
    x_attribute23              => NULL,
    x_attribute24              => NULL*/
  );

  IF l_v_return_status <> 'S'  THEN
    fnd_message.set_name('IGF','IGF_SL_CL_SCR_P_FAIL');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    log_to_fnd(p_v_module => 'create_person_record',
               p_v_string => ' Person creation failed '
              );
    p_n_person_id      := NULL;
    p_n_person_number  := NULL;
    RETURN FALSE;
  END IF;
  fnd_message.set_name('IGF','IGF_SL_CL_SCR_P_SUC');
  fnd_message.set_token('PERSON_NUMBER',l_v_person_number);
  fnd_file.put_line(fnd_file.log, fnd_message.get);
  log_to_fnd(p_v_module => 'create_person_record',
             p_v_string => ' Person created, Person Number '||l_v_person_number
            );
  -- If Person is created successfully then create Address Information
  log_to_fnd(p_v_module => 'create_person_record',
             p_v_string => ' creating address information'
            );
/*
-- mnade 20-Jan-2005 - This If codition is taken off to create addressed for all loans.
  -- create_person_addr_record needs to be invoked for borrower or when student himeself/herself
  -- is borrower
  IF ((l_rec_resp_r1.cl_loan_type IN ('PL','AL') AND p_c_pers_typ_ind = 'B') OR
      (l_rec_resp_r1.cl_loan_type = 'AL' AND l_rec_resp_r1.b_indicator_code = 'Y')) THEN
*/
  l_b_ret_status:= create_person_addr_record(p_n_person_id     => l_n_person_id,
                                             p_v_person_number => l_v_person_number,
                                             p_rec_resp_r1     => l_rec_resp_r1
                                           );
    -- no action is being taken even if the above call out returns an error status
--  END IF;
  -- bvisvana -  Bug # 4522973 - To create the phone contact point once the person is created
  -- Do this only for the borrower.
  IF l_n_person_id IS NOT NULL AND p_c_pers_typ_ind = 'B'  THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.create_person_record.debug','Before calling create_person_telephone_record ');
      END IF;
      l_b_ret_status := create_person_telephone_record ( p_n_person_id     => l_n_person_id,
                                                         p_rec_resp_r1     => l_rec_resp_r1
                                                       ) ;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.create_person_record.debug','After calling create_person_telephone_record ');
      END IF;
  END IF;

  p_n_person_id      := l_n_person_id;
  p_n_person_number  := l_v_person_number;
  RETURN TRUE;


END create_person_record;

FUNCTION create_person_addr_record(p_n_person_id     IN  hz_parties.party_id%TYPE,
                                   p_v_person_number IN  hz_parties.party_number%TYPE,
                                   p_rec_resp_r1     IN  igf_sl_cl_resp_r1_all%ROWTYPE
                                   ) RETURN BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 21 October 2004
--
-- Purpose:
-- Invoked     : from within create_person_record function
-- Function    : Private function for creating person address
--               records
-- Parameters  : p_n_person_id     : IN parameter. Required.
--               p_v_person_number : IN parameter. Required.
--               p_hz_parties_rec  : IN parameter. Required.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--rajagupt    29-Jun-06       bug #5348743, Added check to handle lv_return_status of warning type
------------------------------------------------------------------
  l_v_rowid                   ROWID;
  l_n_location_id             igs_pe_person_addr.location_id%TYPE;
  l_n_msg_count               NUMBER ;
  l_v_msg_data                VARCHAR2(1000);
  l_v_return_status           VARCHAR2(10);
  l_n_party_site_id           igs_pe_person_addr.party_site_id%TYPE;
  l_n_location_ovn            hz_locations.object_version_number%TYPE;
  l_n_party_site_ovn          igs_pe_person_addr.party_site_ovn%TYPE;
  l_d_last_update_date        DATE;
  l_n_person_id               hz_parties.party_id%TYPE;
  l_v_person_number           hz_parties.party_number%TYPE;
  l_v_party_site_use          hz_party_site_uses.site_use_type%TYPE;
  l_n_party_site_use_id       hz_party_site_uses.party_site_use_id%TYPE;
  l_d_site_use_last_upd_dt    DATE;
  l_d_profile_last_upd_dt     DATE;
  l_v_permt_addr1             igs_pe_person_addr.addr_line_1%TYPE;
  l_v_permt_addr2             igs_pe_person_addr.addr_line_2%TYPE;
  l_v_permt_city              hz_parties.city%TYPE;
  l_v_permt_state             hz_parties.state%TYPE;
  l_v_postal_code             igs_pe_person_addr.postal_code%TYPE;
  l_rec_resp_r1               igf_sl_cl_resp_r1_all%ROWTYPE;
BEGIN
  log_to_fnd(p_v_module => 'create_person_addr_record',
             p_v_string => ' p_rec_resp_r1.b_ssn              : ' || p_rec_resp_r1.b_ssn              ||
                           ' p_rec_resp_r1.b_last_name        : ' || p_rec_resp_r1.b_last_name        ||
                           ' p_rec_resp_r1.b_first_name       : ' || p_rec_resp_r1.b_first_name       ||
                           ' p_rec_resp_r1.b_middle_name      : ' || p_rec_resp_r1.b_middle_name      ||
                           ' p_rec_resp_r1.b_permt_addr1      : ' || p_rec_resp_r1.b_permt_addr1      ||
                           ' p_rec_resp_r1.b_permt_addr2      : ' || p_rec_resp_r1.b_permt_addr2      ||
                           ' p_rec_resp_r1.b_permt_city       : ' || p_rec_resp_r1.b_permt_city       ||
                           ' p_rec_resp_r1.b_permt_state      : ' || p_rec_resp_r1.b_permt_state      ||
                           ' p_rec_resp_r1.b_date_of_birth    : ' || p_rec_resp_r1.b_date_of_birth    ||
                           ' p_rec_resp_r1.s_ssn              : ' || p_rec_resp_r1.s_ssn              ||
                           ' p_rec_resp_r1.s_last_name        : ' || p_rec_resp_r1.s_last_name        ||
                           ' p_rec_resp_r1.s_first_name       : ' || p_rec_resp_r1.s_first_name       ||
                           ' p_rec_resp_r1.s_middle_name      : ' || p_rec_resp_r1.s_middle_name      ||
                           ' p_rec_resp_r1.s_date_of_birth    : ' || p_rec_resp_r1.s_date_of_birth    ||
                           ' p_rec_resp_r1.cl_loan_type       : ' || p_rec_resp_r1.cl_loan_type       ||
                           ' p_rec_resp_r1.b_indicator_code   : ' || p_rec_resp_r1.b_indicator_code
            );
  l_n_person_id        := p_n_person_id;
  l_v_person_number    := p_v_person_number;
  l_rec_resp_r1        := p_rec_resp_r1;
  l_v_permt_addr1      := l_rec_resp_r1.b_permt_addr1;
  l_v_permt_addr2      := l_rec_resp_r1.b_permt_addr2;
  l_v_permt_city       := l_rec_resp_r1.b_permt_city;
  l_v_permt_state      := l_rec_resp_r1.b_permt_state;
  l_v_postal_code      := l_rec_resp_r1.b_permt_zip;

  -- If the Student himself/herself is Borrower i.e. l_rec_resp_r1.b_indicator_code = 'Y' THEN
  -- address will be created for the student instead of borrower. In this case Student address would
  -- be same as the borrower address.

  l_v_rowid            := NULL;
  l_n_location_id      := NULL;
  l_n_party_site_id    := NULL;
  l_n_party_site_ovn   := NULL;
  l_n_location_ovn     := NULL;
  l_v_return_status    := NULL;
  l_d_last_update_date := NULL;
  l_v_msg_data         := NULL;

  igs_pe_person_addr_pkg.insert_row
  (
           p_action                     => 'R',
           p_rowid                      => l_v_rowid,
           p_location_id                => l_n_location_id,
           p_start_dt                   => NULL,
           p_end_dt                     => NULL,
           p_country                    => 'US',
           p_address_style              => NULL,
           p_addr_line_1                => INITCAP( l_v_permt_addr1),
           p_addr_line_2                => INITCAP( l_v_permt_addr2),
           p_addr_line_3                => NULL,
           p_addr_line_4                => NULL,
           p_date_last_verified         => NULL,
           p_correspondence             => NULL,
           p_city                       => INITCAP(l_v_permt_city),
           p_state                      => l_v_permt_state,
           p_province                   => NULL,
           p_county                     => NULL,
           p_postal_code                => l_v_postal_code,
           p_address_lines_phonetic     => NULL,
           p_delivery_point_code        => NULL,
           p_other_details_1            => NULL,
           p_other_details_2            => NULL,
           p_other_details_3            => NULL,
           l_return_status              => l_v_return_status,
           l_msg_data                   => l_v_msg_data,
           p_party_id                   => l_n_person_id,
           p_party_site_id              => l_n_party_site_id,
           p_party_type                 => NULL,
           p_last_update_date           => l_d_last_update_date,
           p_party_site_ovn             => l_n_party_site_ovn,
           p_location_ovn               => l_n_location_ovn,
           p_status                     => 'A'
  );
  -- if address creation failed
  IF l_v_return_status IN ('E','U')  THEN
    fnd_message.set_name('IGF','IGF_SL_CL_SCR_P_ADD_FAIL');
    fnd_message.set_token('PERSON_NUMBER',l_v_person_number);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    log_to_fnd(p_v_module => 'create_person_addr_record',
               p_v_string => ' Person address creation failed '
              );
    RETURN FALSE;
    -- bug 5348743
  ELSIF l_v_return_status = 'W' THEN
     fnd_file.put_line(fnd_file.log, l_v_msg_data);
     log_to_fnd(p_v_module => 'create_person_addr_record',
               p_v_string => ' Person address creation warning '
              );
  ELSE
  -- person address created successfully
      fnd_message.set_name('IGF','IGF_SL_CL_SCR_P_ADD_SUC');
      fnd_message.set_token('PERSON_NUMBER',l_v_person_number);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      log_to_fnd(p_v_module => 'create_person_addr_record',
                 p_v_string => ' Person address created, Person Number '||l_v_person_number
                );
  END IF;
      log_to_fnd(p_v_module => 'create_person_addr_record',
                 p_v_string => ' verifying the profile for address usage '
                );
   l_v_party_site_use := fnd_profile.value('IGF_AP_DEF_ADDR_USAGE');
   IF  l_v_party_site_use IS NULL THEN
      l_v_party_site_use := 'HOME';
   END IF;

   log_to_fnd(p_v_module => 'create_person_addr_record',
              p_v_string => ' Verified the profile for address usage.party site usage is '||l_v_party_site_use
             );

  l_v_rowid                := NULL;
  l_n_party_site_use_id    := NULL;
  l_v_return_status        := NULL;
  l_d_last_update_date     := NULL;
  l_v_msg_data             := NULL;
  l_d_site_use_last_upd_dt := NULL;
  l_d_profile_last_upd_dt  := NULL;
  l_n_party_site_ovn       := NULL;

   log_to_fnd(p_v_module => 'create_person_addr_record',
              p_v_string => ' Invoking igs_pe_party_site_use_pkg.hz_party_site_uses_ak'
             );

   igs_pe_party_site_use_pkg.hz_party_site_uses_ak (
                             p_action                      => 'INSERT',
                             p_rowid                       => l_v_rowid,
                             p_party_site_use_id           => l_n_party_site_use_id,
                             p_party_site_id               => l_n_party_site_id,
                             p_site_use_type               => l_v_party_site_use,
                             p_status                      => 'A',
                             p_return_status               => l_v_return_status  ,
                             p_msg_data                    => l_v_msg_data,
                             p_last_update_date            => l_d_last_update_date,
                             p_site_use_last_update_date   => l_d_site_use_last_upd_dt,
                             p_profile_last_update_date    => l_d_profile_last_upd_dt,
                             p_hz_party_site_use_ovn       => l_n_party_site_ovn
                     );

  IF l_v_return_status <> 'S'  THEN
    log_to_fnd(p_v_module => 'create_person_addr_record',
               p_v_string => ' igs_pe_party_site_use_pkg.hz_party_site_uses_ak failed '
              );
    RETURN FALSE;
  END IF;
  log_to_fnd(p_v_module => 'create_person_addr_record',
             p_v_string => ' igs_pe_party_site_use_pkg.hz_party_site_uses_ak successfully executed'
            );
  RETURN TRUE;
END create_person_addr_record;

FUNCTION create_person_telephone_record (p_n_person_id     IN  hz_parties.party_id%TYPE,
                                         p_rec_resp_r1     IN  igf_sl_cl_resp_r1_all%ROWTYPE
                                        ) RETURN BOOLEAN AS
------------------------------------------------------------------
--Created by  : bvisvana, Oracle IDC
--Date created: 29 July 2005
--
-- Purpose     : To create the Phone contact point for the person
-- Invoked     : from within create_person_addr_record
-- Parameters  : p_n_person_id and p_rec_resp_r1
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
l_rowid               ROWID;
l_return_status       VARCHAR2(10);
l_last_update_date    DATE ;
l_contact_point_id    VARCHAR2(25);
l_contact_point_ovn   VARCHAR2(25);
l_msg_data            VARCHAR2(1000);
l_perm_phone          VARCHAR2(10);
l_area_code           VARCHAR2(3);
l_phone_num           VARCHAR2(7);

BEGIN

  l_rowid             := NULL;
  l_last_update_date  := NULL;
  l_contact_point_id  := NULL;
  l_contact_point_ovn := NULL;
  l_msg_data          := NULL;
  l_area_code         := NULL;
  l_phone_num         := NULL;
  l_perm_phone        := p_rec_resp_r1.b_permt_phone;

  IF LTRIM(RTRIM(l_perm_phone)) <> 'N/A' and LENGTH(LTRIM(RTRIM(l_perm_phone))) = 10 THEN
     l_area_code  :=  SUBSTR(l_perm_phone,1,3);
     IF l_area_code = '000' THEN
        l_area_code := NULL;
     ENd IF;
     l_phone_num  :=  SUBSTR(l_perm_phone,4);
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.create_person_telephone_record.debug','p_n_person_id = '||p_n_person_id);
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.create_person_telephone_record.debug','Area_code = '||l_area_code);
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.create_person_telephone_record.debug','Phone_num = '||l_phone_num);
    END IF;
  ELSE
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.create_person_telephone_record.debug','Since phone number N/A or length not equal to 10 ..returning as false');
    END IF;
    RETURN FALSE;
  END IF;
  igs_pe_contact_point_pkg.hz_contact_points_akp(
                                                  p_action	             => 'INSERT',
                                                  p_rowid		             => l_rowid,
                                                  p_status	             => 'A',
                                                  p_owner_table_name     => 'HZ_PARTIES',
                                                  p_owner_table_id       => p_n_person_id,
                                                  p_primary_flag	       => 'N',
                                                  p_phone_country_code   => NULL,
                                                  p_phone_area_code      => l_area_code,
                                                  p_phone_number         => l_phone_num,
                                                  p_phone_extension      => NULL,
                                                  p_phone_line_type      => 'GEN',
                                                  p_return_status	       => l_return_status,
                                                  p_msg_data             => l_msg_data,
                                                  p_last_update_date     => l_last_update_date,
                                                  p_contact_point_id     => l_contact_point_id,
                                                  p_contact_point_ovn    => l_contact_point_ovn,
                                                  p_attribute_category   => NULL,
                                                  p_attribute1           => NULL,
                                                  p_attribute2           => NULL,
                                                  p_attribute3           => NULL,
                                                  p_attribute4           => NULL,
                                                  p_attribute5           => NULL,
                                                  p_attribute6           => NULL,
                                                  p_attribute7           => NULL,
                                                  p_attribute8           => NULL,
                                                  p_attribute9           => NULL,
                                                  p_attribute10          => NULL,
                                                  p_attribute11          => NULL,
                                                  p_attribute12          => NULL,
                                                  p_attribute13          => NULL,
                                                  p_attribute14          => NULL,
                                                  p_attribute15          => NULL,
                                                  p_attribute16          => NULL,
                                                  p_attribute17          => NULL,
                                                  p_attribute18          => NULL,
                                                  p_attribute19          => NULL,
                                                  p_attribute20          => NULL
                                                );
    IF l_return_status <> 'S' THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.create_person_telephone_record.debug','FALSE - Telephone return status = '||l_return_status);
      END IF;
      RETURN FALSE;
    ELSE
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.create_person_telephone_record.debug','TRUE - Telephone return status = '||l_return_status);
      END IF;
      RETURN TRUE;
    END IF;
END create_person_telephone_record;


FUNCTION create_borrow_stud_rel ( p_n_borrower_id     IN  hz_parties.party_id%TYPE,
                                  p_v_borrower_number IN  hz_parties.party_number%TYPE,
                                  p_n_student_id      IN  hz_parties.party_id%TYPE,
                                  p_v_student_number  IN  hz_parties.party_number%TYPE
                                 ) RETURN BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 21 October 2004
--
-- Purpose:
-- Invoked     : from within process_borrow_stud_rec procedure
-- Function    : Private function for creating borrower student relation
--
-- Parameters  : p_n_borrower_id     : IN parameter. Required.
--               p_v_borrower_number : IN parameter. Required.
--               p_n_student_id      : IN parameter. Required.
--               p_v_student_number  : IN parameter. Required.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-- pssahni   18-Jan-2005      Added functionality to check if relationship
--                            already exsist between the student and borrower
------------------------------------------------------------------
 -- Get the details of relationship
 CURSOR c_get_relationship( p_subject_id hz_relationships.subject_id%TYPE,
                            p_object_id hz_relationships.object_id%TYPE
           ) IS
   SELECT relationship_type
     FROM hz_relationships
    WHERE subject_id = p_subject_id
      AND object_id  = p_object_id;

  l_relationship c_get_relationship%ROWTYPE;

  l_n_msg_count               NUMBER ;
  l_v_msg_data                VARCHAR2(1000);
  l_v_return_status           VARCHAR2(10);
  l_d_last_update_date        DATE;
  l_n_location_ovn            hz_locations.object_version_number%TYPE;
  l_n_relationship_id         hz_relationships.relationship_id%TYPE;
  l_n_party_id                hz_parties.party_id%TYPE;
  l_v_party_number            hz_parties.party_number%TYPE;


BEGIN
  log_to_fnd(p_v_module => 'create_borrow_stud_rel',
             p_v_string => ' p_n_borrower_id     : ' ||p_n_borrower_id       ||
                           ' p_v_borrower_number : ' ||p_v_borrower_number   ||
                           ' p_n_student_id      : ' ||p_n_student_id        ||
                           ' p_v_student_number  : ' ||p_v_student_number
            );

-- pssahni 18-Jan-2005
-- Since we are creating relationships for exsisting persons so we need to
-- first check if any relationship exsists between the borrower and student
  OPEN c_get_relationship (p_n_borrower_id, p_n_student_id);
  FETCH c_get_relationship INTO l_relationship;
  IF c_get_relationship%FOUND THEN            --Relationship exsists.
    CLOSE c_get_relationship;
    fnd_message.set_name('IGF','IGF_SL_CL_SCR_REL_EXSIST');
    fnd_message.set_token('PERSON_NUMBER',p_v_borrower_number);
    fnd_message.set_token('ST_PERSON_NUM',p_v_student_number);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    RETURN FALSE;
  ELSE                                       -- Create relationship
      CLOSE c_get_relationship;
      igs_pe_relationships_pkg.creatupdate_party_relationship(
            p_action                  => 'INSERT',
            p_subject_id              => p_n_borrower_id,
            p_object_id               => p_n_student_id,
            p_party_relationship_type => 'PARENT/CHILD',
            p_relationship_code       => 'PARENT_OF',
            p_comments                => NULL,
            p_start_date              => SYSDATE,
            p_end_date                => NULL,
            p_last_update_date        => l_d_last_update_date,
            p_return_status           => l_v_return_status,
            p_msg_count               => l_n_msg_count,
            p_msg_data                => l_v_msg_data,
            p_party_relationship_id   => l_n_relationship_id,
            p_party_id                => l_n_party_id,
            p_party_number            => l_v_party_number,
            p_object_version_number   => l_n_location_ovn
      );

      IF (l_v_return_status <> 'S') THEN
        fnd_message.set_name('IGF','IGF_SL_CL_SCR_REL_FAIL');
        fnd_message.set_token('PERSON_NUMBER',p_v_borrower_number);
        fnd_message.set_token('ST_PERSON_NUM',p_v_student_number);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        log_to_fnd(p_v_module => 'create_borrow_stud_rel',
                   p_v_string => ' igs_pe_relationships_pkg.creatupdate_party_relationship failed '
                  );
        RETURN FALSE;
      END IF;
      fnd_message.set_name('IGF','IGF_SL_CL_SCR_REL_SUC');
      fnd_message.set_token('PERSON_NUMBER',p_v_borrower_number);
      fnd_message.set_token('ST_PERSON_NUM',p_v_student_number);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      log_to_fnd(p_v_module => 'create_borrow_stud_rel',
                 p_v_string => ' igs_pe_relationships_pkg.creatupdate_party_relationship successful. '
                );
      RETURN TRUE;

    END IF;

END create_borrow_stud_rel;


PROCEDURE prepare_scr_message (itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                                 actid      IN NUMBER,
                                 funcmode   IN VARCHAR2,
                                 resultout  OUT NOCOPY VARCHAR2)

AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 04 November 2004
--
-- Purpose:
-- Invoked     : invoked from workflow
-- Function    : public function which return the release version attribute .
--               This would decide the workflow Notification Content
-- Parameters  :
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
BEGIN

    resultout := wf_engine.getitemattrtext(
                          itemtype,
                          itemkey,
                          'RELEASE_VERSION');
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig_ack.prepare_scr_message.debug','resultout ' || resultout);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
    resultout := NULL;
    wf_core.context ('IGF_SL_CL_ORIG_ACK',
                      'PREPARE_SCR_MESSAGE', itemtype,
                       itemkey,TO_CHAR(actid), funcmode);
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig_ack.prepare_scr_message.debug','sqlerrm ' || SQLERRM);
    END IF;
END prepare_scr_message;

PROCEDURE raise_scr_event  ( p_rec_resp_r1        IN  igf_sl_cl_resp_r1_all%ROWTYPE,
                             p_c_borrow_created   IN  VARCHAR2,
                             p_c_student_created  IN  VARCHAR2,
                             p_c_rel_created      IN  VARCHAR2
                           ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 04 November 2004
--
-- Purpose:
-- Invoked     : from within process_borrow_stud_rec procedure
-- Function    : private function which would raise the business event
--
-- Parameters  :
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-- bvisvana    26-Sep-2005    Bug # 4141704 - IGF_SL_FED_APPL_FORM_CODE replaced with IGF_SL_CL_APP_FORM_CODE since
--                            IGF_SL_CL_APP_FORM_CODE has the complete set of lookup_code for Application Form Code
------------------------------------------------------------------
  CURSOR  c_wf_event_key IS
  SELECT  igf_sl_cl_scr_seq.NEXTVAL
  FROM    DUAL;

  l_wf_event_t            wf_event_t;
  l_wf_parameter_list_t   wf_parameter_list_t;
  l_wf_event_name         VARCHAR2(255);
  l_wf_event_key          NUMBER;
  l_v_role                fnd_user.user_name%TYPE;
  l_rec_resp_r1           igf_sl_cl_resp_r1_all%ROWTYPE;
BEGIN
  log_to_fnd(p_v_module => 'raise_scr_event',
             p_v_string => ' p_rec_resp_r1.loan_number  : ' ||p_rec_resp_r1.loan_number ||
                           ' p_c_borrow_created         : ' ||p_c_borrow_created        ||
                           ' p_c_student_created        : ' ||p_c_student_created       ||
                           ' p_c_rel_created            : ' ||p_c_rel_created
            );
  log_to_fnd(p_v_module => 'raise_scr_event',
             p_v_string => 'Initializing the wf_event_t object'
            );
  l_rec_resp_r1  := p_rec_resp_r1;

  -- initialize the wf_event_t object
  wf_event_t.initialize(l_wf_event_t);
  l_wf_event_name := 'oracle.apps.igf.sl.loans.ffelp.LoanCertificationRequest';
  log_to_fnd(p_v_module => 'raise_scr_event',
             p_v_string => 'Setting the workflow event name '||l_wf_event_name
            );
  -- set the event name
  l_wf_event_t.seteventname( peventname => l_wf_event_name);

  log_to_fnd(p_v_module => 'raise_scr_event',
             p_v_string => 'Obtaining the workflow event key'
            );
  OPEN  c_wf_event_key;
  FETCH c_wf_event_key INTO l_wf_event_key;
  CLOSE c_wf_event_key ;

  log_to_fnd(p_v_module => 'raise_scr_event',
             p_v_string => 'The workflow event key '||l_wf_event_key
            );
  l_wf_event_t.setEventKey ( pEventKey => l_wf_event_name|| l_wf_event_key );
  -- set the parameter list
  log_to_fnd(p_v_module => 'raise_scr_event',
             p_v_string => 'setting the parameter list'
            );
  l_wf_event_t.setParameterList ( pParameterList => l_wf_parameter_list_t );

  -- Now add the parameters to the list to be passed to the workflow
  log_to_fnd(p_v_module => 'raise_scr_event',
             p_v_string => 'Adding the parameters to the list passed to the workflow'
            );

  log_to_fnd(p_v_module => 'raise_scr_event',
             p_v_string => 'Before calling the fnd.profile.value(USERNAME)'
            );

  l_v_role := fnd_global.user_name;

  log_to_fnd(p_v_module => 'raise_scr_event',
             p_v_string => 'After calling the fnd.profile.value(USERNAME)..The value of the USERNAME is '||l_v_role
            );

  wf_event.addparametertolist(
       p_name          => 'USER_ID',
       p_value         => l_v_role,
       p_parameterlist => l_wf_parameter_list_t
       );
  wf_event.addparametertolist(
       p_name          => 'RELEASE_VERSION',
       p_value         => g_v_cl_version,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_1',
       p_value         => l_rec_resp_r1.b_last_name,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_2',
       p_value         => l_rec_resp_r1.b_first_name,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_3',
       p_value         => l_rec_resp_r1.b_middle_name,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_4',
       p_value         => l_rec_resp_r1.b_ssn,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_5',
       p_value         => l_rec_resp_r1.b_permt_addr1,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_6',
       p_value         => l_rec_resp_r1.b_permt_addr2,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_7',
       p_value         => l_rec_resp_r1.b_permt_city,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_8',
       p_value         => l_rec_resp_r1.b_permt_state,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_9',
       p_value         => l_rec_resp_r1.b_permt_zip,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_10',
       p_value         => l_rec_resp_r1.b_permt_zip_suffix,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_11',
       p_value         => l_rec_resp_r1.b_permt_phone,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_12',
       p_value         => l_rec_resp_r1.b_date_of_birth,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_13',
       p_value         => l_rec_resp_r1.cl_loan_type||' - ' || igf_aw_gen.lookup_desc('IGF_SL_CL_LOAN_TYPE',l_rec_resp_r1.cl_loan_type),
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_14',
       p_value         => l_rec_resp_r1.req_loan_amt,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_15',
       p_value         => l_rec_resp_r1.defer_req_code||' - ' ||igf_aw_gen.lookup_desc('IGF_SL_CL_DEF_REQ_CODE',l_rec_resp_r1.defer_req_code),
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_16',
       p_value         => l_rec_resp_r1.borw_interest_ind||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_BORW_INT_IND',l_rec_resp_r1.borw_interest_ind),
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_17',
       p_value         => l_rec_resp_r1.eft_auth_code||' - ' ||igf_aw_gen.lookup_desc('IGF_SL_CL_EFT_AUTH_CODE',l_rec_resp_r1.eft_auth_code),
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_18',
       p_value         => l_rec_resp_r1.b_signature_code||' - ' ||igf_aw_gen.lookup_desc('IGF_SL_CL_BORW_SIGN_CODE',l_rec_resp_r1.b_signature_code),
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_19',
       p_value         => l_rec_resp_r1.b_signature_date,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_20',
       p_value         => l_rec_resp_r1.loan_number,
       p_parameterlist => l_wf_parameter_list_t
       );

  IF g_v_cl_version = 'RELEASE-5' THEN

    wf_event.addparametertolist(
       p_name          => 'ATT_21',
       p_value         => l_rec_resp_r1.borr_credit_auth_code,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_22',
       p_value         => l_rec_resp_r1.b_citizenship_status||' - '||igf_aw_gen.lookup_desc('IGF_SL_CITIZENSHIP_STAT', l_rec_resp_r1.b_citizenship_status),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_23',
       p_value         => l_rec_resp_r1.b_state_of_legal_res||' - ' ||igf_aw_gen.lookup_desc('IGF_AP_STATE_CODES',l_rec_resp_r1.b_state_of_legal_res),
       p_parameterlist => l_wf_parameter_list_t
       );
    wf_event.addparametertolist(
       p_name          => 'ATT_24',
       p_value         => l_rec_resp_r1.b_legal_res_date,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_25',
       p_value         => l_rec_resp_r1.b_default_status||' - ' ||igf_aw_gen.lookup_desc('IGF_SL_P_DEFAULT_STATUS',l_rec_resp_r1.b_default_status),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_26',
       p_value         => l_rec_resp_r1.b_outstd_loan_code||' - '||igf_aw_gen.lookup_desc('IGF_AP_YES_NO',l_rec_resp_r1.b_outstd_loan_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_27',
       p_value         => l_rec_resp_r1.b_indicator_code||' - '||igf_aw_gen.lookup_desc('IGF_AP_YES_NO',l_rec_resp_r1.b_indicator_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_28',
       p_value         => l_rec_resp_r1.s_last_name,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_29',
       p_value         => l_rec_resp_r1.s_first_name,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_30',
       p_value         => l_rec_resp_r1.s_middle_name,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_31',
       p_value         => l_rec_resp_r1.s_ssn,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_32',
       p_value         => l_rec_resp_r1.s_date_of_birth,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_33',
       p_value         => l_rec_resp_r1.s_citizenship_status||' - ' ||igf_aw_gen.lookup_desc('IGF_SL_CITIZENSHIP_STAT',l_rec_resp_r1.s_citizenship_status),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_34',
       p_value         => l_rec_resp_r1.s_default_code||' - ' ||igf_aw_gen.lookup_desc('IGF_SL_S_DEFAULT_STATUS',l_rec_resp_r1.s_default_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_35',
       p_value         => l_rec_resp_r1.s_signature_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_STUD_SIGN_CODE',l_rec_resp_r1.s_signature_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_36',
       p_value         => l_rec_resp_r1.school_id,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_37',
       p_value         => l_rec_resp_r1.loan_per_begin_date,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_38',
       p_value         => l_rec_resp_r1.loan_per_end_date,
       p_parameterlist => l_wf_parameter_list_t
       );
    wf_event.addparametertolist(
       p_name          => 'ATT_39',
       p_value         => l_rec_resp_r1.borr_sign_ind||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_ELE_SIGN_IND',l_rec_resp_r1.borr_sign_ind),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_40',
       p_value         => l_rec_resp_r1.alt_appl_ver_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_ALT_LOAN_CODE',l_rec_resp_r1.alt_appl_ver_code) ,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_41',
       p_value         => l_rec_resp_r1.lender_id,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_42',
       p_value         => l_rec_resp_r1.guarantor_id,
       p_parameterlist => l_wf_parameter_list_t
       );
    -- Bug # 4141704
    wf_event.addparametertolist(
       p_name          => 'ATT_43',
       p_value         => l_rec_resp_r1.fed_appl_form_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_APP_FORM_CODE',l_rec_resp_r1.fed_appl_form_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_44',
       p_value         => l_rec_resp_r1.b_license_state||' - '||igf_aw_gen.lookup_desc('IGF_AP_STATE_CODES',l_rec_resp_r1.b_license_state),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_45',
       p_value         => l_rec_resp_r1.b_license_number,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_46',
       p_value         => l_rec_resp_r1.b_ref_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_BORW_REF_INF',l_rec_resp_r1.b_ref_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_47',
       p_value         => l_rec_resp_r1.pnote_delivery_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_PNOTE_DELIVERY',l_rec_resp_r1.pnote_delivery_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_48',
       p_value         => l_rec_resp_r1.b_foreign_postal_code,
       p_parameterlist => l_wf_parameter_list_t
       );
    wf_event.addparametertolist(
       p_name          => 'ATT_49',
       p_value         => l_rec_resp_r1.stud_sign_ind||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_ELE_SIGN_IND',l_rec_resp_r1.stud_sign_ind),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_50',
       p_value         => l_rec_resp_r1.lend_non_ed_brc_id,
       p_parameterlist => l_wf_parameter_list_t
       );

   wf_event.addparametertolist(
       p_name          => 'ATT_51',
       p_value         => l_rec_resp_r1.lender_use_txt,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_52',
       p_value         => l_rec_resp_r1.guarantor_use_txt,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_53',
       p_value         => l_rec_resp_r1.b_permt_addr_chg_date,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_54',
       p_value         => l_rec_resp_r1.alt_prog_type_code,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_55',
       p_value         => l_rec_resp_r1.prc_type_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_PRC_TYPE_CODE',l_rec_resp_r1.prc_type_code),
       p_parameterlist => l_wf_parameter_list_t
       );
    -- No mapping field available for ATT_56. Discussed with TD writer
    -- Td writer agreed upon to skip this ATT_56

     wf_event.addparametertolist(
       p_name          => 'ATT_57',
       p_value         => l_rec_resp_r1.guarnt_status_code||' - ' ||igf_aw_gen.lookup_desc('IGF_SL_GUARNT_STATUS',l_rec_resp_r1.guarnt_status_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_58',
       p_value         => l_rec_resp_r1.lender_status_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_LEND_STATUS',l_rec_resp_r1.lender_status_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_59',
       p_value         => l_rec_resp_r1.pnote_status_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_PNOTE_STATUS',l_rec_resp_r1.pnote_status_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_60',
       p_value         => l_rec_resp_r1.credit_status_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_CREDIT_OVERRIDE',l_rec_resp_r1.credit_status_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_61',
       p_value         => l_rec_resp_r1.guarnt_status_date,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_62',
       p_value         => l_rec_resp_r1.lender_status_date,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_63',
       p_value         => l_rec_resp_r1.pnote_status_date,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_64',
       p_value         => l_rec_resp_r1.credit_status_date,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_65',
       p_value         => l_rec_resp_r1.act_serial_loan_code||' - ' ||igf_aw_gen.lookup_desc('IGF_SL_SERIAL_LOAN_CODE',l_rec_resp_r1.act_serial_loan_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_66',
       p_value         => l_rec_resp_r1.sch_non_ed_brc_id,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_67',
       p_value         => igf_aw_gen.lookup_desc('IGF_AP_YES_NO',p_c_borrow_created),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_68',
       p_value         => igf_aw_gen.lookup_desc('IGF_AP_YES_NO',p_c_student_created),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_69',
       p_value         => igf_aw_gen.lookup_desc('IGF_AP_YES_NO',p_c_rel_created),
       p_parameterlist => l_wf_parameter_list_t
       );

  END IF;

  IF g_v_cl_version = 'RELEASE-4' THEN

    wf_event.addparametertolist(
       p_name          => 'ATT_21',
       p_value         => l_rec_resp_r1.b_citizenship_status||' - '||igf_aw_gen.lookup_desc('IGF_SL_CITIZENSHIP_STAT', l_rec_resp_r1.b_citizenship_status),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_22',
       p_value         => l_rec_resp_r1.b_state_of_legal_res||' - '||igf_aw_gen.lookup_desc('IGF_AP_STATE_CODES',l_rec_resp_r1.b_state_of_legal_res),
       p_parameterlist => l_wf_parameter_list_t
       );
    wf_event.addparametertolist(
       p_name          => 'ATT_23',
       p_value         => l_rec_resp_r1.b_legal_res_date,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_24',
       p_value         => l_rec_resp_r1.b_default_status||' - ' ||igf_aw_gen.lookup_desc('IGF_SL_P_DEFAULT_STATUS',l_rec_resp_r1.b_default_status),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_25',
       p_value         => l_rec_resp_r1.b_outstd_loan_code||' - '||igf_aw_gen.lookup_desc('IGF_AP_YES_NO',l_rec_resp_r1.b_outstd_loan_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_26',
       p_value         => l_rec_resp_r1.b_indicator_code||' - '||igf_aw_gen.lookup_desc('IGF_AP_YES_NO',l_rec_resp_r1.b_indicator_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_27',
       p_value         => l_rec_resp_r1.s_last_name,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_28',
       p_value         => l_rec_resp_r1.s_first_name,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_29',
       p_value         => l_rec_resp_r1.s_middle_name,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_30',
       p_value         => l_rec_resp_r1.s_ssn,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_31',
       p_value         => l_rec_resp_r1.s_date_of_birth,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_32',
       p_value         => l_rec_resp_r1.s_citizenship_status||' - '||igf_aw_gen.lookup_desc('IGF_SL_CITIZENSHIP_STAT',l_rec_resp_r1.s_citizenship_status),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_33',
       p_value         => l_rec_resp_r1.s_default_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_S_DEFAULT_STATUS',l_rec_resp_r1.s_default_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_34',
       p_value         => l_rec_resp_r1.s_signature_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_STUD_SIGN_CODE',l_rec_resp_r1.s_signature_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_35',
       p_value         => l_rec_resp_r1.school_id,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_36',
       p_value         => l_rec_resp_r1.loan_per_begin_date,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_37',
       p_value         => l_rec_resp_r1.loan_per_end_date,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_38',
       p_value         => l_rec_resp_r1.alt_appl_ver_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_ALT_LOAN_CODE',l_rec_resp_r1.alt_appl_ver_code) ,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_39',
       p_value         => l_rec_resp_r1.lender_id,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_40',
       p_value         => l_rec_resp_r1.guarantor_id,
       p_parameterlist => l_wf_parameter_list_t
       );
    -- Bug # 4141704
    wf_event.addparametertolist(
       p_name          => 'ATT_41',
       p_value         => l_rec_resp_r1.fed_appl_form_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_APP_FORM_CODE',l_rec_resp_r1.fed_appl_form_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_42',
       p_value         => l_rec_resp_r1.mpn_confirm_ind||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_MPN_CONF_IND',l_rec_resp_r1.mpn_confirm_ind),
       p_parameterlist => l_wf_parameter_list_t
       );


    wf_event.addparametertolist(
       p_name          => 'ATT_43',
       p_value         => l_rec_resp_r1.b_license_state||' - '||igf_aw_gen.lookup_desc('IGF_AP_STATE_CODES',l_rec_resp_r1.b_license_state),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_44',
       p_value         => l_rec_resp_r1.b_license_number,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_45',
       p_value         => l_rec_resp_r1.b_ref_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_CL_BORW_REF_INF',l_rec_resp_r1.b_ref_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_46',
       p_value         => l_rec_resp_r1.pnote_delivery_code||' - '||igf_aw_gen.lookup_desc('IGF_SL_PNOTE_DELIVERY',l_rec_resp_r1.pnote_delivery_code),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_47',
       p_value         => l_rec_resp_r1.b_foreign_postal_code,
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_48',
       p_value         => igf_aw_gen.lookup_desc('IGF_AP_YES_NO',p_c_borrow_created),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_49',
       p_value         => igf_aw_gen.lookup_desc('IGF_AP_YES_NO',p_c_student_created),
       p_parameterlist => l_wf_parameter_list_t
       );

    wf_event.addparametertolist(
       p_name          => 'ATT_50',
       p_value         => igf_aw_gen.lookup_desc('IGF_AP_YES_NO',p_c_rel_created),
       p_parameterlist => l_wf_parameter_list_t
       );

  END IF;

  -- raise the business event
  log_to_fnd(p_v_module => 'raise_scr_event',
             p_v_string => 'Raising the business event'
            );
  wf_event.RAISE (p_event_name => l_wf_event_name,
                  p_event_key  => l_wf_event_key,
                  p_parameters => l_wf_parameter_list_t
                 );
  l_wf_parameter_list_t.DELETE;

END raise_scr_event;

PROCEDURE raise_gamt_event  ( p_v_ci_alternate_code   IN igs_ca_inst_all.alternate_code%TYPE,
                              p_d_ci_start_dt         IN igs_ca_inst_all.start_dt%TYPE,
                              p_d_ci_end_dt           IN igs_ca_inst_all.end_dt%TYPE,
                              p_v_person_number       IN hz_parties.party_number%TYPE,
                              p_v_person_name         IN hz_parties.party_name%TYPE,
                              p_v_ssn                 IN igf_ap_isir_ints_all.current_ssn_txt%TYPE,
                              p_v_loan_number         IN igf_sl_loans_all.loan_number%TYPE,
                              p_d_loan_per_begin_date IN igf_sl_loans_all.loan_per_begin_date%TYPE,
                              p_d_loan_per_end_date   IN igf_sl_loans_all.loan_per_end_date%TYPE,
                              p_v_loan_type           IN igf_aw_fund_cat_all.fed_fund_code%TYPE,
                              p_n_award_accept_amt    IN igf_aw_award_all.accepted_amt%TYPE,
                              p_n_guarantee_amt       IN igf_sl_cl_resp_r1_all.guarantee_amt%TYPE,
                              p_n_approved_amt        IN igf_sl_cl_resp_r1_all.alt_approved_amt%TYPE
                            ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 04 November 2004
--
-- Purpose:
-- Invoked     : from within process_borrow_stud_rec procedure
-- Function    : private function which would raise the business event
--
-- Parameters  :
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  CURSOR  c_wf_event_key IS
  SELECT  igf_sl_cl_scr_seq.NEXTVAL -- MN 12-Jan-2005 - As the WorkFlow in use is common between
                                    -- Amt Diff and SCR Diff using same sequence and removing igf_sl_cl_gamt_seq
  FROM    DUAL;

  l_wf_event_t            wf_event_t;
  l_wf_parameter_list_t   wf_parameter_list_t;
  l_wf_event_name         VARCHAR2(255);
  l_wf_event_key          NUMBER;
  l_v_role                fnd_user.user_name%TYPE;

BEGIN
  log_to_fnd(p_v_module => 'raise_gamt_event',
             p_v_string => '|p_v_ci_alternate_code    : ' ||p_v_ci_alternate_code   ||
                           '|p_d_ci_start_dt          : ' ||p_d_ci_start_dt         ||
                           '|p_d_ci_end_dt            : ' ||p_d_ci_end_dt           ||
                           '|p_v_person_number        : ' ||p_v_person_number       ||
                           '|p_v_person_number        : ' ||p_v_person_number       ||
                           '|p_v_person_name          : ' ||p_v_person_name         ||
                           '|p_v_ssn                  : ' ||p_v_ssn                 ||
                           '|p_v_loan_number          : ' ||p_v_loan_number         ||
                           '|p_d_loan_per_begin_date  : ' ||p_d_loan_per_begin_date ||
                           '|p_d_loan_per_end_date    : ' ||p_d_loan_per_end_date   ||
                           '|p_v_loan_type            : ' ||p_v_loan_type           ||
                           '|p_n_award_accept_amt     : ' ||p_n_award_accept_amt    ||
                           '|p_n_guarantee_amt        : ' ||p_n_guarantee_amt       ||
                           '|p_n_approved_amt         : ' ||p_n_approved_amt
            );

  log_to_fnd(p_v_module => 'raise_gamt_event',
             p_v_string => 'Initializing the wf_event_t object'
            );

  -- initialize the wf_event_t object
  wf_event_t.initialize(l_wf_event_t);
  l_wf_event_name := 'oracle.apps.igf.sl.loans.ffelp.LoanGuaranteeAmount';
  log_to_fnd(p_v_module => 'raise_gamt_event',
             p_v_string => 'Setting the workflow event name '||l_wf_event_name
            );
  -- set the event name
  l_wf_event_t.seteventname( peventname => l_wf_event_name);

  log_to_fnd(p_v_module => 'raise_gamt_event',
             p_v_string => 'Obtaining the workflow event key'
            );
  OPEN  c_wf_event_key;
  FETCH c_wf_event_key INTO l_wf_event_key;
  CLOSE c_wf_event_key ;

  log_to_fnd(p_v_module => 'raise_gamt_event',
             p_v_string => 'The workflow event key '||l_wf_event_key
            );
  l_wf_event_t.setEventKey ( pEventKey => l_wf_event_name|| l_wf_event_key );
  -- set the parameter list
  log_to_fnd(p_v_module => 'raise_gamt_event',
             p_v_string => 'setting the parameter list'
            );
  l_wf_event_t.setParameterList ( pParameterList => l_wf_parameter_list_t );

  -- Now add the parameters to the list to be passed to the workflow
  log_to_fnd(p_v_module => 'raise_gamt_event',
             p_v_string => 'Adding the parameters to the list passed to the workflow'
            );

  log_to_fnd(p_v_module => 'raise_gamt_event',
             p_v_string => 'Before calling the fnd.profile.value(USERNAME)..'
            );

  l_v_role := fnd_global.user_name;

  log_to_fnd(p_v_module => 'raise_gamt_event',
             p_v_string => 'After calling the fnd.profile.value(USERNAME)..The value of the USERNAME is '||l_v_role
            );

  wf_event.addparametertolist(
       p_name          => 'USER_ID',
       p_value         => l_v_role,
       p_parameterlist => l_wf_parameter_list_t
       );
  wf_event.addparametertolist(
       p_name          => 'ATT_1',
       p_value         => p_v_ci_alternate_code,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_2',
       p_value         => (p_d_ci_start_dt ||'-'||p_d_ci_end_dt),
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_3',
       p_value         => p_v_person_number,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_4',
       p_value         => p_v_person_name,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_5',
       p_value         => p_v_ssn,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_6',
       p_value         => p_v_loan_number,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_7',
       p_value         => p_d_loan_per_begin_date||'-'||p_d_loan_per_end_date,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_8',
       p_value         => igf_aw_gen.lookup_desc('IGF_AW_FED_FUND ',p_v_loan_type),
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_9',
       p_value         => p_n_award_accept_amt,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_10',
       p_value         => p_n_guarantee_amt,
       p_parameterlist => l_wf_parameter_list_t
       );

  wf_event.addparametertolist(
       p_name          => 'ATT_11',
       p_value         => p_n_approved_amt,
       p_parameterlist => l_wf_parameter_list_t
       );

 -- raise the business event
  log_to_fnd(p_v_module => 'raise_gamt_event',
             p_v_string => 'Raising the business event'
            );
  wf_event.RAISE (p_event_name => l_wf_event_name,
                  p_event_key  => l_wf_event_key,
                  p_parameters => l_wf_parameter_list_t
                 );
  l_wf_parameter_list_t.DELETE;
END raise_gamt_event;

PROCEDURE insert_into_resp_r2(p_r2_record    IN   igf_sl_cl_resp_r2_dtls%ROWTYPE) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 07 November 2004
--
-- Purpose:
-- Invoked     : from within insert_into_resp1 procedure
-- Function    : private procedure which would insert into resp r2 table
--
-- Parameters  :
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  l_v_rowid                  ROWID;
  l_n_clresp2_id             igf_sl_cl_resp_r2_dtls.clresp2_id%TYPE;
  l_n_clrp1_id               igf_sl_cl_resp_r1_all.clrp1_id%TYPE;
  rec_cl_resp_r2             igf_sl_cl_resp_r2_dtls%ROWTYPE;

BEGIN
  l_v_rowid       :=  NULL;
  l_n_clresp2_id  :=  NULL;
  rec_cl_resp_r2  :=  p_r2_record;
  l_n_clrp1_id    :=  rec_cl_resp_r2.clrp1_id;


  log_to_fnd(p_v_module => 'insert_into_resp_r2',
             p_v_string => 'invoking igf_sl_cl_resp_r2_dtls_pkg.insert_row for clrp1_id ='||l_n_clrp1_id
            );


  igf_sl_cl_resp_r2_dtls_pkg.insert_row(
    x_rowid                        =>  l_v_rowid      ,
    x_clresp2_id                   =>  l_n_clresp2_id ,
    x_clrp1_id                     =>  l_n_clrp1_id   ,
    x_record_code_txt              =>  rec_cl_resp_r2.record_code_txt,
    x_uniq_layout_vend_code        =>  rec_cl_resp_r2.uniq_layout_vend_code,
    x_uniq_layout_ident_code       =>  rec_cl_resp_r2.uniq_layout_ident_code,
    x_filler_txt                   =>  rec_cl_resp_r2.filler_txt,
    x_mode                         =>  'R'
  );
END insert_into_resp_r2;


PROCEDURE insert_into_resp_r3(p_r3_record   IN igf_sl_cl_resp_r3_dtls%ROWTYPE) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 07 November 2004
--
-- Purpose:
-- Invoked     : from within insert_into_resp1 procedure
-- Function    : private procedure which would insert into resp r3 table
--
-- Parameters  :
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  l_v_rowid                   ROWID;
  l_n_clresp3_id             igf_sl_cl_resp_r3_dtls.clresp3_id%TYPE;
  l_n_clrp1_id               igf_sl_cl_resp_r1_all.clrp1_id%TYPE;
  rec_cl_resp_r3             igf_sl_cl_resp_r3_dtls%ROWTYPE;

BEGIN
  l_v_rowid         :=  NULL;
  l_n_clresp3_id    :=  NULL;
  rec_cl_resp_r3    :=  p_r3_record;
  l_n_clrp1_id      :=  rec_cl_resp_r3.clrp1_id;


  log_to_fnd(p_v_module => 'insert_into_resp_r3',
             p_v_string => 'invoking igf_sl_cl_resp_r3_dtls_pkg.insert_row for clrp1_id ='||l_n_clrp1_id
            );

  igf_sl_cl_resp_r3_dtls_pkg.insert_row(
    x_rowid                =>  l_v_rowid,
    x_clresp3_id           =>  l_n_clresp3_id,
    x_clrp1_id             =>  l_n_clrp1_id,
    x_record_code_txt      =>  rec_cl_resp_r3.record_code_txt,
    x_message_1_text       =>  rec_cl_resp_r3.message_1_text,
    x_message_2_text       =>  rec_cl_resp_r3.message_2_text,
    x_message_3_text       =>  rec_cl_resp_r3.message_3_text,
    x_message_4_text       =>  rec_cl_resp_r3.message_4_text,
    x_message_5_text       =>  rec_cl_resp_r3.message_5_text,
    x_mode                 =>  'R'
  );

END insert_into_resp_r3;

PROCEDURE insert_into_resp_r7(p_r7_record  IN  igf_sl_cl_resp_r7_dtls%ROWTYPE) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 07 November 2004
--
-- Purpose:
-- Invoked     : from within insert_into_resp1 procedure
-- Function    : private procedure which would insert into resp r7 table
--
-- Parameters  :
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  l_v_rowid                   ROWID;
  l_n_clresp7_id             igf_sl_cl_resp_r7_dtls.clresp7_id%TYPE;
  l_n_clrp1_id               igf_sl_cl_resp_r1_all.clrp1_id%TYPE;
  rec_cl_resp_r7             igf_sl_cl_resp_r7_dtls%ROWTYPE;

BEGIN
  l_v_rowid       :=  NULL;
  l_n_clresp7_id  :=  NULL;
  rec_cl_resp_r7  :=  p_r7_record;
  l_n_clrp1_id    :=  rec_cl_resp_r7.clrp1_id;


  log_to_fnd(p_v_module => 'insert_into_resp_r7',
             p_v_string => 'invoking igf_sl_cl_resp_r3_dtls_pkg.insert_row for clrp1_id ='||l_n_clrp1_id
            );

  igf_sl_cl_resp_r7_dtls_pkg.insert_row(
    x_rowid                        =>  l_v_rowid,
    x_clresp7_id                   =>  l_n_clresp7_id,
    x_clrp1_id                     =>  l_n_clrp1_id,
    x_record_code_txt              =>  rec_cl_resp_r7.record_code_txt,
    x_layout_owner_code_txt        =>  rec_cl_resp_r7.layout_owner_code_txt,
    x_layout_identifier_code_txt   =>  rec_cl_resp_r7.layout_identifier_code_txt,
    x_email_txt                    =>  rec_cl_resp_r7.email_txt,
    x_valid_email_flag             =>  rec_cl_resp_r7.valid_email_flag,
    x_email_effective_date         =>  rec_cl_resp_r7.email_effective_date,
    x_borrower_temp_add_line_1_txt =>  rec_cl_resp_r7.borrower_temp_add_line_1_txt,
    x_borrower_temp_add_line_2_txt =>  rec_cl_resp_r7.borrower_temp_add_line_2_txt,
    x_borrower_temp_add_city_txt   =>  rec_cl_resp_r7.borrower_temp_add_city_txt,
    x_borrower_temp_add_state_txt  =>  rec_cl_resp_r7.borrower_temp_add_state_txt,
    x_borrower_temp_add_zip_num    =>  rec_cl_resp_r7.borrower_temp_add_zip_num,
    x_borr_temp_add_zip_xtn_num    =>  rec_cl_resp_r7.borrower_temp_add_zip_xtn_num,
    x_borr_forgn_postal_code_txt   =>  rec_cl_resp_r7.borrower_forgn_postal_code_txt,
    x_mode                         =>  'R'
  );

END insert_into_resp_r7;

PROCEDURE insert_into_resp_r6(p_r6_record    IN igf_sl_clchrs_dtls%ROWTYPE )AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 07 November 2004
--
-- Purpose:
-- Invoked     : from within insert_into_resp1 procedure
-- Function    : private procedure which would insert into igf_sl_clchrs_dtls table
--
-- Parameters  :
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  l_v_rowid                   ROWID;
  rec_cl_resp_r6             igf_sl_clchrs_dtls%ROWTYPE;
  l_n_clrp1_id               igf_sl_cl_resp_r1_all.clrp1_id%TYPE;
  l_n_clchgrsp_id            igf_sl_clchrs_dtls.clchgrsp_id%TYPE;

BEGIN
  l_v_rowid       :=  NULL;
  l_n_clchgrsp_id :=  NULL;
  rec_cl_resp_r6  :=  p_r6_record;
  l_n_clrp1_id    :=  rec_cl_resp_r6.clrp1_id;

  log_to_fnd(p_v_module => 'insert_into_resp_r6',
             p_v_string => 'invoking igf_sl_clchrs_dtls_pkg.insert_row for clrp1_id ='||l_n_clrp1_id
            );

  igf_sl_clchrs_dtls_pkg.insert_row (
    x_rowid                         =>  l_v_rowid,
    x_clchgrsp_id                   =>  l_n_clchgrsp_id,
    x_clrp1_id                      =>  l_n_clrp1_id,
    x_record_code                   =>  rec_cl_resp_r6.record_code,
    x_send_record_txt               =>  rec_cl_resp_r6.send_record_txt      ,
    x_error_message_1_code          =>  rec_cl_resp_r6.error_message_1_code ,
    x_error_message_2_code          =>  rec_cl_resp_r6.error_message_2_code ,
    x_error_message_3_code          =>  rec_cl_resp_r6.error_message_3_code ,
    x_error_message_4_code          =>  rec_cl_resp_r6.error_message_4_code ,
    x_error_message_5_code          =>  rec_cl_resp_r6.error_message_5_code ,
    x_record_process_code           =>  rec_cl_resp_r6.record_process_code,
    x_mode                          =>  'R'
  );


END insert_into_resp_r6;

PROCEDURE process_change_records (p_n_clrp1_id     IN  igf_sl_cl_resp_r1_all.clrp1_id%TYPE,
                                  p_v_loan_number  IN  igf_sl_loans_all.loan_number%TYPE) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 07 November 2004
--
-- Purpose:
-- Invoked     : from within process_ack procedure
-- Function    : private procedure which updates igf_sl_clchrs_dtls table
--
-- Parameters  : p_n_clrp1_id  : IN. Required
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  CURSOR  c_sl_clchsn_dtls (cp_v_loan_number igf_sl_loans_all.loan_number%TYPE) IS
  --cp_v_send_record_txt igf_sl_clchsn_dtls.send_record_txt%TYPE)
  SELECT  chdt.*, chdt.ROWID row_id
  FROM    igf_sl_clchsn_dtls chdt
  WHERE   loan_number_txt = cp_v_loan_number
  AND     chdt.status_code     = 'S';

  rec_c_sl_clchsn_dtls  c_sl_clchsn_dtls%ROWTYPE;

  CURSOR  c_sl_clchrs_dtls (cp_n_clrp1_id         igf_sl_cl_resp_r1_all.clrp1_id%TYPE,
                            cp_v_send_record_txt  igf_sl_clchrs_dtls.send_record_txt%TYPE) IS
  SELECT  chrsdtls.*
  FROM    igf_sl_clchrs_dtls chrsdtls
  WHERE   chrsdtls.clrp1_id = cp_n_clrp1_id
          AND send_record_txt = TRIM(cp_v_send_record_txt);

  rec_c_sl_clchrs_dtls    c_sl_clchrs_dtls%ROWTYPE;

  l_n_clrp1_id              igf_sl_cl_resp_r1_all.clrp1_id%TYPE;
  l_v_response_status_code  igf_sl_clchsn_dtls.response_status_code%TYPE;
  l_v_status_code           igf_sl_clchsn_dtls.status_code%TYPE;
  e_skip_change_rec         EXCEPTION;
BEGIN
  log_to_fnd(p_v_module => 'process_change_records',
             p_v_string => '|p_n_clrp1_id = ' || p_n_clrp1_id ||
                           '|p_v_loan_number = ' || p_v_loan_number
                           );
  l_n_clrp1_id := p_n_clrp1_id;
  fnd_file.new_line(fnd_file.log,2);
  fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PROCESSING'),40));

  FOR rec_c_sl_clchsn_dtls IN c_sl_clchsn_dtls (cp_v_loan_number => p_v_loan_number)  -- sl_cl_chsn_dtls rec processing
  LOOP
    -- Missing c_sl_clchrs_dtls means that the change is accepted by the processor
    -- If data is present then need to check for error_message and Mark the c_sl_clchsn_dtls and reject.
    -- initialize the status code to Acknowledge
    l_v_status_code := 'A';
    -- initialize the value to Accepted
    l_v_response_status_code := 'A';
    OPEN c_sl_clchrs_dtls (cp_n_clrp1_id         =>  p_n_clrp1_id,
                           cp_v_send_record_txt  =>  rec_c_sl_clchsn_dtls.send_record_txt);
    FETCH c_sl_clchrs_dtls INTO rec_c_sl_clchrs_dtls;
    IF c_sl_clchrs_dtls%FOUND THEN                                 -- Check for errors if any

        -- If there error codes are present, it would mean that the change record is rejected,
        -- update the change record with status code 'R'.
        -- If there are no error codes present, it would mean that the change record is accepted,
        -- update the change record status to 'A'.
        IF (rec_c_sl_clchrs_dtls.error_message_1_code IS NOT NULL OR
            rec_c_sl_clchrs_dtls.error_message_2_code IS NOT NULL OR
            rec_c_sl_clchrs_dtls.error_message_3_code IS NOT NULL OR
            rec_c_sl_clchrs_dtls.error_message_4_code IS NOT NULL OR
            rec_c_sl_clchrs_dtls.error_message_5_code IS NOT NULL ) THEN
          l_v_response_status_code := 'R';
          log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','ERROR_MSG_1_CODE'),40),
                           p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR',rec_c_sl_clchrs_dtls.error_message_1_code)
                         );
          log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','ERROR_MSG_2_CODE'),40),
                           p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR',rec_c_sl_clchrs_dtls.error_message_2_code)
                         );
          log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','ERROR_MSG_3_CODE'),40),
                           p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR',rec_c_sl_clchrs_dtls.error_message_3_code)
                         );
          log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','ERROR_MSG_4_CODE'),40),
                           p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR',rec_c_sl_clchrs_dtls.error_message_4_code)
                         );
          log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','ERROR_MSG_5_CODE'),40),
                           p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR',rec_c_sl_clchrs_dtls.error_message_5_code)
                         );
        END IF;
    END IF;                                                        -- End Check for errors if any
    CLOSE c_sl_clchrs_dtls;

        log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','CHG_RESP_STATUS'),40),
                         p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CL_CHG_RESP_STATUS',l_v_response_status_code)
                       );
        log_to_fnd(p_v_module => 'process_change_records',
                   p_v_string => 'invoking igf_sl_clchsn_dtls_pkg.update_row for change send id ='||rec_c_sl_clchsn_dtls.clchgsnd_id
                  );
        igf_sl_clchsn_dtls_pkg.update_row (
          x_rowid                             =>    rec_c_sl_clchsn_dtls.row_id                        ,
          x_clchgsnd_id                       =>    rec_c_sl_clchsn_dtls.clchgsnd_id                   ,
          x_award_id                          =>    rec_c_sl_clchsn_dtls.award_id                      ,
          x_loan_number_txt                   =>    rec_c_sl_clchsn_dtls.loan_number_txt               ,
          x_cl_version_code                   =>    rec_c_sl_clchsn_dtls.cl_version_code               ,
          x_change_field_code                 =>    rec_c_sl_clchsn_dtls.change_field_code             ,
          x_change_record_type_txt            =>    rec_c_sl_clchsn_dtls.change_record_type_txt        ,
          x_change_code_txt                   =>    rec_c_sl_clchsn_dtls.change_code_txt               ,
          x_status_code                       =>    l_v_status_code                                    ,
          x_status_date                       =>    rec_c_sl_clchsn_dtls.status_date                   ,
          x_response_status_code              =>    l_v_response_status_code                           ,
          x_old_value_txt                     =>    rec_c_sl_clchsn_dtls.old_value_txt                 ,
          x_new_value_txt                     =>    rec_c_sl_clchsn_dtls.new_value_txt                 ,
          x_old_date                          =>    rec_c_sl_clchsn_dtls.old_date                      ,
          x_new_date                          =>    rec_c_sl_clchsn_dtls.new_date                      ,
          x_old_amt                           =>    rec_c_sl_clchsn_dtls.old_amt                       ,
          x_new_amt                           =>    rec_c_sl_clchsn_dtls.new_amt                       ,
          x_disbursement_number               =>    rec_c_sl_clchsn_dtls.disbursement_number           ,
          x_disbursement_date                 =>    rec_c_sl_clchsn_dtls.disbursement_date             ,
          x_change_issue_code                 =>    rec_c_sl_clchsn_dtls.change_issue_code             ,
          x_disbursement_cancel_date          =>    rec_c_sl_clchsn_dtls.disbursement_cancel_date      ,
          x_disbursement_cancel_amt           =>    rec_c_sl_clchsn_dtls.disbursement_cancel_amt       ,
          x_disbursement_revised_amt          =>    rec_c_sl_clchsn_dtls.disbursement_revised_amt      ,
          x_disbursement_revised_date         =>    rec_c_sl_clchsn_dtls.disbursement_revised_date     ,
          x_disbursement_reissue_code         =>    rec_c_sl_clchsn_dtls.disbursement_reissue_code     ,
          x_disbursement_reinst_code          =>    rec_c_sl_clchsn_dtls.disbursement_reinst_code      ,
          x_disbursement_return_amt           =>    rec_c_sl_clchsn_dtls.disbursement_return_amt       ,
          x_disbursement_return_date          =>    rec_c_sl_clchsn_dtls.disbursement_return_date      ,
          x_disbursement_return_code          =>    rec_c_sl_clchsn_dtls.disbursement_return_code      ,
          x_post_with_disb_return_amt         =>    rec_c_sl_clchsn_dtls.post_with_disb_return_amt     ,
          x_post_with_disb_return_date        =>    rec_c_sl_clchsn_dtls.post_with_disb_return_date    ,
          x_post_with_disb_return_code        =>    rec_c_sl_clchsn_dtls.post_with_disb_return_code    ,
          x_prev_with_disb_return_amt         =>    rec_c_sl_clchsn_dtls.prev_with_disb_return_amt     ,
          x_prev_with_disb_return_date        =>    rec_c_sl_clchsn_dtls.prev_with_disb_return_date    ,
          x_school_use_txt                    =>    rec_c_sl_clchsn_dtls.school_use_txt                ,
          x_lender_use_txt                    =>    rec_c_sl_clchsn_dtls.lender_use_txt                ,
          x_guarantor_use_txt                 =>    rec_c_sl_clchsn_dtls.guarantor_use_txt             ,
          x_validation_edit_txt               =>    rec_c_sl_clchsn_dtls.validation_edit_txt           ,
          x_send_record_txt                   =>    rec_c_sl_clchsn_dtls.send_record_txt               ,
          x_mode                              =>    'R'
        );

  END LOOP;   -- END sl_cl_chsn_dtls rec processing

  fnd_file.new_line(fnd_file.log,2);
  fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','RECORDS_PROCESSED'),40));

END process_change_records;

PROCEDURE log_parameters ( p_v_param_typ IN VARCHAR2,
                           p_v_param_val IN VARCHAR2
                         ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 21 October 2004
--
-- Purpose:
-- Invoked     : from within process_1 procedure
-- Function    : Private procedure for logging
--
-- Parameters  : p_v_param_typ   : IN parameter. Required.
--               p_v_param_val   : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  BEGIN
    fnd_file.put_line(fnd_file.log, p_v_param_typ || ' : ' || p_v_param_val );
  END log_parameters;

END igf_sl_cl_orig_ack;

/
