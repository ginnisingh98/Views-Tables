--------------------------------------------------------
--  DDL for Package Body IGI_IMP_IAC_IMPORT_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IMP_IAC_IMPORT_CUST_PKG" AS
-- $Header: igiimiab.pls 120.6.12000000.1 2007/08/01 16:21:04 npandya ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiimiab.igi_imp_iac_import_cust_pkg.';

--===========================FND_LOG.END=====================================
   --
   -- Implementation Customized Import Data Process
   --
   PROCEDURE Import_Cust_Data_Process ( errbuf            OUT NOCOPY VARCHAR2
                                      , retcode           OUT NOCOPY NUMBER
                                      , p_full_file_name  IN  VARCHAR2
                                     ) IS

      l_full_file_name VARCHAR2(1000);
      l_message        VARCHAR2(1000);

      -- 07/07/2003, mh, added for web adi check
      l_adi_enabled   VARCHAR2(3);

      e_iac_not_enabled EXCEPTION;
      -- 07/07/2003, mh, added for web adi check
      e_web_adi_enabled    EXCEPTION;
      l_path_name VARCHAR2(150) := g_path||'import_cust_data_process';
   BEGIN

      l_full_file_name := p_full_file_name;

      -- Check if IAC is switched on
      IF NOT igi_gen.is_req_installed('IAC') THEN
         RAISE e_iac_not_enabled;
      END IF;

      -- 07/07/2003, mh, added for web adi check
      -- Check if the profile option to use WebADI for import/export
      -- is set to 'Y'
      l_adi_enabled := fnd_profile.value('IGI_IMP_IAC_USE_WEB_ADI');

      IF (l_adi_enabled = 'Y') THEN
         RAISE e_web_adi_enabled;
      END IF;

      -- Delete old records from the intermediate table
      DELETE FROM igi_imp_iac_intermediate;
      COMMIT;

      -- Write file name to log file
      FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_FILE_LOG');
      FND_MESSAGE.Set_Token('FILE_NAME',l_full_file_name);
      igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
		      p_full_path => l_path_name,
		      p_remove_from_stack => FALSE);
      l_message := FND_MESSAGE.Get;
      FND_FILE.Put_Line(FND_FILE.Log,l_message);

      -- Invoking SQL*Loader to upload the file to the intermediate table.
      igi_imp_iac_import_pkg.spawn_loader( l_full_file_name
                                         );

      -- Invoke the validate and update PL/SQL Program
      igi_imp_iac_import_pkg.validate_update_imp_data( l_full_file_name
                                                     , ''
                                                     , ''
                                                     );

      COMMIT;

   EXCEPTION

      WHEN e_iac_not_enabled THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IAC_NOT_INSTALLED');
         igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		         p_full_path => l_path_name,
		         p_remove_from_stack => FALSE);
         retcode := 2;
         errbuf := FND_MESSAGE.Get;
	 fnd_file.put_line(fnd_file.log, errbuf);
      WHEN e_web_adi_enabled THEN
         FND_MESSAGE.Set_Name('IGI','IGI_IMP_IAC_WEB_ADI_ENABLED');
         igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		         p_full_path => l_path_name,
		         p_remove_from_stack => FALSE);
         retcode := 2;
         errbuf := FND_MESSAGE.Get;
	 fnd_file.put_line(fnd_file.log, errbuf);
      WHEN OTHERS THEN
         FND_MESSAGE.Retrieve(l_message);
         igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		         p_full_path => l_path_name,
		         p_remove_from_stack => FALSE);
         retcode := 2;
         errbuf := l_message;
	 fnd_file.put_line(fnd_file.log, errbuf);

   END Import_Cust_Data_Process;

END igi_imp_iac_import_cust_pkg;

/
