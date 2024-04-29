--------------------------------------------------------
--  DDL for Package Body IGS_UC_PROC_UCAS_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_PROC_UCAS_DATA" AS
/* $Header: IGSUC43B.pls 120.2 2006/08/21 06:15:09 jbaber noship $  */


  PROCEDURE process_ucas_data (
     errbuf               OUT NOCOPY   VARCHAR2
    ,retcode              OUT NOCOPY   NUMBER
    ,p_proc_ref_data      IN  VARCHAR2
    ,p_proc_appl_data     IN  VARCHAR2) IS

    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :  To call different procedures for processing UCAS data.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     06-JUL-03 dsridhar     Bug No: 3085608. Changing the processing order to call
                            igs_uc_proc_reference_data.process_cvjointadmissions after
                            igs_uc_proc_com_inst_data.process_cvinstitution.
     18-JAN-06 anwest       Bug# 4950285 R12 Disable OSS Mandate
     11-Jul-06 jbaber       Added call to process_cvrefcountry for UCAS 2007 Support
    ***************************************************************** */
  BEGIN

      --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
      IGS_GE_GEN_003.SET_ORG_ID;

      IF p_proc_ref_data = 'N' AND p_proc_appl_data = 'N' THEN
          fnd_message.set_name('IGS','IGS_UC_NO_REF_APPL_PROC');
          errbuf  := fnd_message.get;
          fnd_file.put_line(fnd_file.log, errbuf);
          retcode:=2;
          RETURN;
      END IF;


      -- general validation/setup check procedures.
      -- general validations procedure and package variable initialization
      igs_uc_proc_com_inst_data.common_data_setup (errbuf,
                                                   retcode) ;

      -- if the above procedure returns any error then exit the conc. process with error.
      IF retcode = 2 THEN
         RETURN;
      END IF;

      -- Reference Data
      IF p_proc_ref_data = 'Y' THEN

         igs_uc_proc_com_inst_data.process_uvinstitution      ;
         igs_uc_proc_reference_data.process_cvrefcodes        ;
         igs_uc_proc_reference_data.process_cvrefawardbody    ;

         igs_uc_proc_reference_data.process_cvrefapr          ;
         igs_uc_proc_reference_data.process_cvrefkeyword      ;
         igs_uc_proc_reference_data.process_cvrefpocc         ;

         igs_uc_proc_reference_data.process_cvrefofferabbrev  ;
         igs_uc_proc_com_inst_data.process_uvofferabbrev      ;
         igs_uc_proc_reference_data.process_cvrefsubj         ;

         igs_uc_proc_reference_data.process_cvreftariff       ;

         igs_uc_proc_com_inst_data.process_cvinstitution      ;
         igs_uc_proc_reference_data.process_cvjointadmissions ;

         igs_uc_proc_com_inst_data.process_cveblsubject       ;
         igs_uc_proc_com_inst_data.process_cvschool           ;
         igs_uc_proc_com_inst_data.process_cvschoolcontact    ;

         igs_uc_proc_com_inst_data.process_cvcourse           ;
         igs_uc_proc_com_inst_data.process_uvcourse           ;
         igs_uc_proc_com_inst_data.process_uvcoursekeyword    ;

         igs_uc_proc_reference_data.process_cvrefcountry      ;

      END IF;

      -- Application Data
      IF p_proc_appl_data = 'Y' THEN

         igs_uc_proc_application_data.appl_data_setup (retcode, errbuf) ; -- general validations for Application data.

         -- if the above procedure returns any error then exit the conc. process with error.
         IF retcode = 2 THEN
            RETURN;
         END IF;

         igs_uc_proc_application_data.process_ivstarn         ;
         igs_uc_proc_application_data.process_ivstark         ;

         igs_uc_proc_application_data.process_ivstarc         ;
         igs_uc_proc_application_data.process_ivstarg         ;
         igs_uc_proc_application_data.process_ivstart         ;

         igs_uc_proc_application_data.process_ivstara         ;
         igs_uc_proc_application_data.process_ivqualification ;

         igs_uc_proc_application_data.process_ivstatement     ;

         igs_uc_proc_application_data.process_ivreference     ;
         igs_uc_proc_application_data.process_ivoffer         ;
         igs_uc_proc_application_data.process_ivstarx         ;

         igs_uc_proc_application_data.process_ivstarh         ;
         igs_uc_proc_application_data.process_ivstarpqr       ;
         igs_uc_proc_application_data.process_ivformquals     ;

         igs_uc_proc_application_data.process_ivstarz1        ;
         igs_uc_proc_application_data.process_ivstarz2        ;
         igs_uc_proc_application_data.process_ivstarw         ;

      END IF;


--      ==============================================================================
--                    Launching of Process UCAS Data Error Report
--      ==============================================================================


      -- Submit the Error report IGSUCJ36  to show the errors generated while Importing data.
       DECLARE
          l_rep_request_id   NUMBER ;
          l_conc_request_id  NUMBER;

       BEGIN

          fnd_file.put_line(fnd_file.log, '==========================================================================');

          l_rep_request_id := NULL ;

          l_rep_request_id := Fnd_Request.Submit_Request
                              ('IGS',
                               'IGSUCS36',
                                'Process UCAS Data Error Report',
                                NULL,
                                FALSE,
                                l_conc_request_id ,
                                CHR(0) ,
                                NULL,
                                NULL,
                                NULL,
                                NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                               );


          IF l_rep_request_id > 0 THEN
                 -- if error report successfully submitted then log message
                 fnd_file.put_line( fnd_file.LOG ,' ');
                 fnd_message.set_name('IGS','IGS_UC_LAUNCH_PROC_ERR_REP');
                 fnd_message.set_token('REQ_ID',TO_CHAR(l_rep_request_id));
                 fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
          ELSE
                 -- if error report failed to be launched then log message
                 fnd_message.set_name('IGS','IGS_UC_PROC_ERR_REP_ERR');
                 fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
          END IF;

       END;

  EXCEPTION
       WHEN OTHERS THEN
         ROLLBACK;
         retcode := 2;
         -- even though the admission import process completes in error , this process should continue processing
         Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME','IGS_UC_PROC_UCAS_DATA.PROCESS_UCAS_DATA'||' - '||SQLERRM);
         errbuf  := fnd_message.get;
         fnd_file.put_line(fnd_file.LOG, errbuf);
         igs_ge_msg_stack.conc_exception_hndl;
  END process_ucas_data;





  PROCEDURE log_proc_complete(p_view_name VARCHAR2, p_success_cnt NUMBER, p_error_cnt NUMBER) IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   This process is for logging message marking the completion
                         of the processing for that Hercules view.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

  BEGIN
     fnd_message.set_name('IGS','IGS_UC_PROC_DATA_COMP_STATS');
     fnd_message.set_token('VIEW', p_view_name);
     fnd_message.set_token('TOT_RECS' , TO_CHAR(p_success_cnt + p_error_cnt));
     fnd_message.set_token('SUCC_RECS', TO_CHAR(p_success_cnt));
     fnd_message.set_token('ERR_RECS' , TO_CHAR(p_error_cnt));
     fnd_file.put_line(fnd_file.log, fnd_message.get);
     fnd_file.put_line(fnd_file.log, '==========================================================================');
     fnd_file.put_line(fnd_file.log, ' ');


  END log_proc_complete;




  PROCEDURE log_error_msg(p_error_code igs_uc_uinst_ints.error_code%TYPE) IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   This process fetches the message/meaning from Lookups
                         for the error code that is passed in as parameter.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- get the error message/meaning from Lookups
     CURSOR get_err_msg_cur IS
     SELECT meaning
     FROM   igs_lookup_values
     WHERE  lookup_type = 'IGS_UC_DATA_ERRORS'
     AND    lookup_code = p_error_code;

     l_meaning igs_lookup_values.meaning%TYPE;

  BEGIN

     OPEN get_err_msg_cur;
     FETCH get_err_msg_cur INTO l_meaning;
     IF get_err_msg_cur%NOTFOUND THEN
        fnd_message.set_name('IGS','IGS_UC_INVALID_ERR_CODE');
        fnd_message.set_token('ERROR_CODE', p_error_code);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
     ELSE
        fnd_file.put_line(fnd_file.log, p_error_code || ' - ' ||l_meaning);
     END IF;

     CLOSE get_err_msg_cur;
  END log_error_msg;


END igs_uc_proc_ucas_data;

/
