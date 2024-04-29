--------------------------------------------------------
--  DDL for Package Body IGF_AP_LOADER_LAUNCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_LOADER_LAUNCH_PKG" AS
/* $Header: IGFAP49B.pls 120.4 2006/04/18 06:28:30 hkodali noship $ */


FUNCTION get_message_class (p_file_name VARCHAR2)
RETURN VARCHAR2
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 27-Jul-2004
  ||  Purpose :        Returns just the file name after removing the file path, if any.
  ||  Known limitations, enhancements or remarks : The max parameter length would be < 400 chars.
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

  l_firstslash NUMBER;
  l_finalslash NUMBER;
  l_nextslash  NUMBER;
  l_filename   VARCHAR2(400);

BEGIN

  l_firstslash := INSTR(p_file_name, '/');

  IF l_firstslash = 0 THEN
     -- i.e. no '/' in the string and hence entire length is p_file_name
     l_filename := p_file_name;
     RETURN (l_filename);

  ELSE  -- i.e. '/' exists
     l_finalslash := l_firstslash;
     l_nextslash := l_finalslash;

     -- loop till the last '/' is reached.
     WHILE l_nextslash > 0 LOOP
        l_nextslash := INSTR(SUBSTR(p_file_name, l_finalslash + 1), '/') ;
        l_finalslash := l_finalslash + l_nextslash;
     END LOOP;

    l_filename := SUBSTR(SUBSTR(p_file_name,1), l_finalslash+1);
  END IF;

  RETURN (l_filename);

EXCEPTION
  WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log, SQLERRM);
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_AP_LOADER_LAUNCH_PKG.get_message_class');
     fnd_file.put_line(fnd_file.log, fnd_message.get);
     RETURN(NULL);
END get_message_class;


FUNCTION get_parameter_filename
RETURN VARCHAR2
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 27-Jul-2004
  ||  Purpose :        Returns the 1st parameter value for the Conc Program from FND Tables.
  ||  Known limitations, enhancements or remarks :
  ||      1. Filename parameter would be the 1st parameter for the conc. program IGFAPX02.
  ||      2. Max parameter length < 400 chars. (Conc. program parameter has only 240 limit.)
  ||      3. Conc program IGFAPX02 is incompatible with itself else the query would returns multiple rows.
  ||
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   CURSOR get_parameter_cur IS
   SELECT fcr.argument1
   FROM   fnd_concurrent_requests fcr, fnd_concurrent_programs ucpn
   WHERE  fcr.program_application_id = ucpn.application_id
     AND  fcr.concurrent_program_id  = ucpn.concurrent_program_id
     AND  fcr.phase_code = 'R'
     AND  ucpn.concurrent_program_name = 'IGFAPX06'
     AND  ucpn.application_id = 8405;

  -- IGFAPX02 is the executable name for ISIR Loader Process

   l_parameter_value  fnd_concurrent_requests.argument1%TYPE;
   l_file_name VARCHAR2(100);
BEGIN

  -- get the parameter value
  OPEN  get_parameter_cur;
  FETCH get_parameter_cur INTO l_parameter_value;
  CLOSE get_parameter_cur;

  IF l_parameter_value IS NOT NULL THEN
     -- call the function which returns the filename after removing the file path
     l_file_name := get_message_class(l_parameter_value) ;

  END IF;

  RETURN (l_file_name);

EXCEPTION
  WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log, SQLERRM);
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_AP_LOADER_LAUNCH_PKG.get_parameter_filename');
     fnd_file.put_line(fnd_file.log, fnd_message.get);
     RETURN(NULL);
END get_parameter_filename;



PROCEDURE main_process ( errbuf            OUT NOCOPY VARCHAR2,
                         retcode           OUT NOCOPY NUMBER,
                         p_org_id          IN         NUMBER,
                         p_file_path       IN         VARCHAR2,
                         p_file_list       IN         VARCHAR2
                       )
IS

/*
||  Created By : rgangara
||  Created On : 27-JUL-2004
||  Purpose : Main process which in turn calls the ISIR Loader Process
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
||---------------------------------------------------------------------
||  azmohamm      04/04/06...... Bug No: 4946522,
||                               Added 'fileNullOrMsgInvalid' exception
*/

  CURSOR validate_msg_class_cur (cp_msg_class igf_lookups_view.lookup_code%TYPE) IS
  SELECT 'X'
  FROM   igf_lookups_view
  WHERE  lookup_type = 'IGF_AP_ISIR_MESSAGE_CLASS'
    AND  lookup_code = UPPER(cp_msg_class)
    AND  enabled_flag = 'Y';

  l_found_msg_class VARCHAR2(1);
  l_req_id          NUMBER;
  l_msg_class       VARCHAR2(400);
  fileNullOrMsgInvalid Exception;
  l_file_list       VARCHAR2(500);
  l_file_path       VARCHAR2(400);
  l_file_name       VARCHAR2(400);

BEGIN


   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_loader_launch_pkg.main_process.exception','Before Calling method igf_aw_gen.set_org_id' );
   END IF;

   igf_aw_gen.set_org_id(p_org_id);

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_loader_launch_pkg.main_process.exception','After Calling method igf_aw_gen.set_org_id' );
   END IF;

   errbuf             := NULL;
   retcode            := 0;

   l_file_path := TRIM(p_file_path);
   l_file_list := p_file_list;

   -- Append / to file list
   IF SUBSTR(l_file_path, LENGTH(l_file_path)) <> '/' THEN
     l_file_path := l_file_path || '/' ;
   END IF;

   ------------------------------------------------
   -- Validate File Name Parameter.
   ------------------------------------------------
   IF l_file_list IS NOT NULL THEN

      -- loop through the file list to extract each file name
      -- pass the file name along with path to the Internal Loader process
      LOOP

        -- extract file name
        IF INSTR(l_file_list, ',') = 0 THEN
         l_file_name := trim(l_file_list);
        ELSE
         l_file_name := trim(substr(l_file_list, 1, INSTR(l_file_list, ',')-1));
        END IF;

        -- call function to get the message class from the file name
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_loader_launch_pkg.main_process.exception','Before Calling method igf_ap_matching_process_pkg.get_msg_class_from_filename' );
        END IF;

        l_msg_class := igf_ap_matching_process_pkg.get_msg_class_from_filename(l_file_name);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_loader_launch_pkg.main_process.exception','After Calling method igf_ap_matching_process_pkg.get_msg_class_from_filename' );
        END IF;

        -- validate that the filename derived is a valid message class
        -- It is assumed that the file name would be the same as the message class.
        OPEN validate_msg_class_cur(l_msg_class);
        FETCH validate_msg_class_cur INTO l_found_msg_class;

        IF validate_msg_class_cur%NOTFOUND THEN
           RAISE fileNullOrMsgInvalid;
        END IF;

        CLOSE validate_msg_class_cur;

        ------------------------------------------------
        -- End of parameter Validation
        ------------------------------------------------

        -- since the filename validation is successful, launch the ISIR Loader process
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_loader_launch_pkg.main_process.exception','Before Calling method fnd_request.submit_request' );
        END IF;
        l_req_id := FND_REQUEST.SUBMIT_REQUEST
                            ('IGF',
                             'IGFAPX06',
                              'ISIR Loader Process Internal',
                              NULL,
                              FALSE,
                              TRIM(l_file_path)||l_file_name,       -- file path + file name,
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
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_loader_launch_pkg.main_process.exception','After Calling method fnd_request.submit_request' );
        END IF;

        IF l_req_id > 0 THEN
           fnd_message.set_name('IGF','IGF_AP_INT_LDR_PROC_SBMIT');
           fnd_message.set_token('REQ_ID', l_req_id);
           fnd_file.put_line(fnd_file.log, fnd_message.get);
           COMMIT;

        ELSE
           fnd_message.set_name('IGF','IGF_AP_INT_LDR_PROC_NOT_SBMIT');
           fnd_file.put_line(fnd_file.log, fnd_message.get);
        END IF;

        IF INSTR(l_file_list, ',') = 0 THEN
         EXIT;
        END IF;

        -- extract rest of list
        l_file_list := TRIM(SUBSTR(l_file_list, INSTR(l_file_list, ',') + 1, LENGTH(l_file_list)));

      END LOOP;
    ELSE
      -- i.e. file name parameter is NULL
      RAISE fileNullOrMsgInvalid;
    END IF;

EXCEPTION
   WHEN fileNullOrMsgInvalid THEN
       fnd_message.set_name('IGF','IGF_AP_INVALID_MSG_CLASS');
       errbuf := fnd_message.get;
       fnd_file.put_line(fnd_file.log, errbuf);
       retcode := 2;
   WHEN others THEN
        ROLLBACK;
        retcode := 2;
        fnd_file.put_line(fnd_file.log, SQLERRM);

        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_LOADER_LAUNCH_PKG.MAIN_PROCESS');
        errbuf  := fnd_message.get;
        igs_ge_msg_stack.conc_exception_hndl;
END  main_process;

END igf_ap_loader_launch_pkg;

/
