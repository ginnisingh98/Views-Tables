--------------------------------------------------------
--  DDL for Package Body IGS_UC_CONFIG_CYCLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_CONFIG_CYCLE" AS
/* $Header: IGSUC41B.pls 120.7 2006/08/21 06:14:56 jbaber ship $ */

   g_synonym_fail    BOOLEAN := FALSE;


PROCEDURE log_msg (p_name VARCHAR2, p_mode VARCHAR2) IS
    /*************************************************************
    Created By      : DSRIDHAR
    Date Created On : 05-JUN-2003
    Purpose :     Procedure to log messages for Synonyms Created or Dropped
                  based on the parametres

    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    (reverse chronological order - newest change first)
     dsridhar       15-JUL-2003     Tokens added for messages,
                                    All messages used on synoyms and objects sdded here.
     dsridhar       16-JUL-2003     Added cursor cur_uc_defaults_data and changed updation
                                    of package igs_uc_defaults_pkg from cur_uc_defaults to
                                    cur_uc_defaults_data
     jbaber         20-JUN-2006     Added new messages for mode CD and CF
    ***************************************************************/

BEGIN

      -- Synonym Created if p_mode = 'C'
      IF p_mode = 'C' THEN
         -- Logging the message
         fnd_message.set_name('IGS', 'IGS_UC_CREATE_SYNONYMS');
         fnd_message.set_token('SYN_NAME', p_name);
         fnd_file.put_line(fnd_file.log, fnd_message.get);
      -- Synonym Dummy Created if p_mode = 'CD'
      ELSIF p_mode = 'CD' THEN
         -- Logging the message
         fnd_message.set_name('IGS', 'IGS_UC_CREATE_DUMMY_SYNONYMS');
         fnd_message.set_token('SYN_NAME', p_name);
         fnd_file.put_line(fnd_file.log, fnd_message.get);
      -- Synonym Failed to create if p_mode = 'CF'
      ELSIF p_mode = 'CF' THEN
         -- Logging the message
         fnd_message.set_name('IGS', 'IGS_UC_CREATE_SYNONYMS_FAIL');
         fnd_message.set_token('SYN_NAME', p_name);
         fnd_file.put_line(fnd_file.log, fnd_message.get);
      -- Synonym Dropped if p_mode = 'D'
      ELSIF p_mode = 'D' THEN
         -- Logging the message
         fnd_message.set_name('IGS', 'IGS_UC_DROP_SYNONYMS');
         fnd_message.set_token('SYN_NAME', p_name);
         fnd_file.put_line(fnd_file.log, fnd_message.get);
      ELSIF p_mode = 'O' THEN
         -- Logging the message
         fnd_message.set_name('IGS', 'IGS_UC_COMP_OBJECT');
         fnd_message.set_token('OBJ_NAME', p_name);
         fnd_file.put_line(fnd_file.log, fnd_message.get);
      ELSIF p_mode = 'I' THEN
         fnd_message.set_name('IGS','IGS_UC_INV_OBJECT');
         fnd_message.set_token('OBJ_NAME', p_name);
         fnd_file.put_line(fnd_file.log, fnd_message.get);

      END IF;

END log_msg;


PROCEDURE create_synonym (p_mode        IN VARCHAR,
                          p_synonym     IN VARCHAR2,
                          p_object      IN VARCHAR2,
                          p_dblink_name IN VARCHAR2,
                          p_dummy       IN VARCHAR2) IS
/*************************************************************
Created By      : jbaber
Date Created On : 20-Jun-2006
Purpose :         Creates synonyms. Gracefully handles invalid synonmys
                  by pointing to dummy views.

Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

    sql_stmt  VARCHAR2(32767);

BEGIN

    -- Create synonym
    IF p_mode = 'C' THEN

        -- Create synonymn to point to UCAS
        apps_ddl.apps_ddl('CREATE SYNONYM ' || p_synonym || ' FOR ' ||  p_object  || '@'  || p_dblink_name);
        log_msg(p_synonym, 'C');

        -- Try to access synonymn
        BEGIN

            sql_stmt := 'SELECT ''x'' FROM ' || p_synonym || ' WHERE 1 = 2 ';
            EXECUTE IMMEDIATE(sql_stmt);


        EXCEPTION
        WHEN OTHERS THEN
            -- IF fail then log a message and create DUMMY synonym
            log_msg(p_synonym , 'CF');
            apps_ddl.apps_ddl('CREATE OR REPLACE SYNONYM ' || p_synonym || '  FOR  ' || p_dummy);
            log_msg(p_synonym, 'CD');

            -- set fail flag
            g_synonym_fail := TRUE;

        END;

    -- Create Dummy Synonym
    ELSE
        apps_ddl.apps_ddl('CREATE SYNONYM ' || p_synonym || '  FOR  ' || p_dummy);
        log_msg(p_synonym, 'CD');

    END IF;

END create_synonym;


PROCEDURE conf_system_for_ucas_cycle( errbuf  OUT NOCOPY VARCHAR2,
                                      retcode OUT NOCOPY NUMBER,
                                      p_target_cycle IN NUMBER,
                                      p_dblink_name IN VARCHAR2
                                    ) IS
    /*************************************************************
    Created By      : DSRIDHAR
    Date Created On : 05-JUN-2003
    Purpose :     Created w.r.t. UCFD203 - UCAS Multiple Cycles - Build, Bug No: 2669208.
                  Configure System for UCAS Cylce - This process would provide for switching
                  the system between the supported cycles via a standard Concurrent Manager
                  Request. This process would drop and create synonyms either pointing to the
                  Hercules views over the Database link or to the local dummy views to support
                  compilation of code referencing these synonyms.

    Know limitations, enhancements or remarks
    Change History
    Who             When           What
    (reverse chronological order - newest change first)
     dsridhar       15-Jul-03      Tokens added for messages,
                                   New views IGS_UC_IVFORMQUALS_2004_V AND IGS_UC_IVREFERENCE_2004_V added for
                                   compilation, IGS_UC_FORMQUALS_2004 added
     pmarada        16-Jul-03      Added the code to compile igs_uc_gen_001 package,as per UCFD203
     dsridhar       16-Jul-03      Bug No: 3083664. Package IGS_UC_PROC_COM_INST_DATA included for compilation
     smaddali       27-Aug-03      Modified to point cvcontrol , cvrefamendments synonyms always to dblink , bug#3116897  |
     jchakrab       27-Jul-04      Modified for UCFD308 - UCAS - 2005 Regulatory Changes
     jbaber         07-Jul-05      Modified for UC315 - UCAS Support 2006
     anwest         18-JAN-06      Bug# 4950285 R12 Disable OSS Mandate
     jchin          20-jan-06      Bug 4950293  R12 Perf improvements
    ***************************************************************/

        -- Get the cycle information from defaults
        CURSOR cur_cyc_info IS
               SELECT MAX(current_cycle) current_cycle , MAX(configured_cycle) configured_cycle
               FROM igs_uc_defaults ;

        -- Cursor to get the data from IGS_UC_DEFAULTS
        CURSOR cur_uc_defaults_data IS
               SELECT iuc.rowid, iuc.*
               FROM  igs_uc_defaults iuc
               WHERE system_code <> 'S';

        -- Cursor to get the UCAS_INTERFACE for the 'target cycle'
        CURSOR cur_ucas_interface (cp_ucas_cycle  igs_uc_cyc_defaults.ucas_cycle%TYPE,
                                   cp_system_code igs_uc_cyc_defaults.system_code%TYPE) IS
               SELECT ucas_interface
               FROM IGS_UC_CYC_DEFAULTS
               WHERE system_code = cp_system_code
               AND ucas_cycle = cp_ucas_cycle;

        -- Cursor to get the SYNONYMS
        -- smaddali added new synonym igs_uc_u_ivstatement_2004 for bug#33098810
        -- modified the user to add filtering based on pseudo column USER for bug# 3431844
        -- jchin - bug 4950293
        CURSOR cur_synonyms IS
               SELECT   synonym_name object_name
               FROM     user_synonyms
               WHERE    synonym_name IN (
                              'IGS_UC_U_CVCONTROL_2003',
                              'IGS_UC_U_CVCOURSE_2003',
                              'IGS_UC_U_CVEBLSUBJECT_2003',
                              'IGS_UC_U_CVINSTITUTION_2003',
                              'IGS_UC_U_CVJNTADMISSIONS_2003',
                              'IGS_UC_U_CVNAME_2003',
                              'IGS_UC_U_CVREFAMENDMENTS_2003',
                              'IGS_UC_U_CVREFAPR_2003',
                              'IGS_UC_U_CVREFAWARDBODY_2003',
                              'IGS_UC_U_CVREFDIS_2003',
                              'IGS_UC_U_CVREFERROR_2003',
                              'IGS_UC_U_CVREFESTGROUP_2003',
                              'IGS_UC_U_CVREFETHNIC_2003',
                              'IGS_UC_U_CVREFEXAM_2003',
                              'IGS_UC_U_CVREFFEE_2003',
                              'IGS_UC_U_CVREFKEYWORD_2003',
                              'IGS_UC_U_CVREFOEQ_2003',
                              'IGS_UC_U_CVREFOFFERABBREV_2003',
                              'IGS_UC_U_CVREFOFFERSUBJ_2003',
                              'IGS_UC_U_CVREFPOCC_2003',
                              'IGS_UC_U_CVREFPRE2000POCC_2003',
                              'IGS_UC_U_CVREFRESCAT_2003',
                              'IGS_UC_U_CVREFSCHOOLTYPE_2003',
                              'IGS_UC_U_CVREFSOCIALCLASS_2003',
                              'IGS_UC_U_CVREFSOCIOECON_2003',
                              'IGS_UC_U_CVREFSTATUS_2003',
                              'IGS_UC_U_CVREFSUBJ_2003',
                              'IGS_UC_U_CVREFTARIFF_2003',
                              'IGS_UC_U_CVREFUCASGROUP_2003',
                              'IGS_UC_U_CVSCHOOLCONTACT_2003',
                              'IGS_UC_U_CVSCHOOL_2003',
                              'IGS_UC_U_UVCONTACT_2003',
                              'IGS_UC_U_UVCONTGRP_2003',
                              'IGS_UC_U_UVCOURSEKEYWORD_2003',
                              'IGS_UC_U_UVCOURSEVACS_2003',
                              'IGS_UC_U_UVCOURSEVACOPS_2003',
                              'IGS_UC_U_UVCOURSE_2003',
                              'IGS_UC_U_UVINSTITUTION_2003',
                              'IGS_UC_U_UVINSTITUTION_2004',
                              'IGS_UC_U_UVOFFERABBREV_2003',
                              'IGS_UC_U_IVOFFER_2003',
                              'IGS_UC_U_IVQUALIFICATION_2003',
                              'IGS_UC_U_IVSTARA_2003',
                              'IGS_UC_U_IVSTARC_2003',
                              'IGS_UC_U_IVSTARH_2003',
                              'IGS_UC_U_IVSTARK_2003',
                              'IGS_UC_U_IVSTARN_2003',
                              'IGS_UC_U_IVSTARPQR_2003',
                              'IGS_UC_U_IVSTARW_2003',
                              'IGS_UC_U_IVSTARX_2003',
                              'IGS_UC_U_IVSTARZ1_2003',
                              'IGS_UC_U_IVSTARZ2_2003',
                              'IGS_UC_U_IVSTATEMENT_2003',
                              'IGS_UC_U_TRANIN_2003',
                              'IGS_UC_U_IVFORMQUALS_2004',
                              'IGS_UC_U_IVREFERENCE_2004',
                              'IGS_UC_U_IVSTARJ_2004',
                              'IGS_UC_U_IVSTARW_2004',
                              'IGS_UC_U_TRANIN_2004',
                              'IGS_UC_U_IVSTATEMENT_2004',
                              'IGS_UC_U_IVREFERENCE_2006',
                              'IGS_UC_U_IVSTARA_2006',
                              'IGS_UC_U_IVFORMQUALS_2006',
                              'IGS_UC_U_IVSTARA_2007',
                              'IGS_UC_U_IVSTARN_2007',
                              'IGS_UC_U_IVSTARK_2007',
                              'IGS_UC_U_CVREFCOUNTRY_2007',
                              'IGS_UC_U_CVREFNATIONALITY_2007',
                              'IGS_UC_U_CVREFAMENDMENTS_2007',
                              -- Small Systems Synonyms
                              'IGS_UC_G_CVGNAME_2006',
                              'IGS_UC_N_CVNNAME_2006',
                              'IGS_UC_G_IVGOFFER_2006',
                              'IGS_UC_N_IVNOFFER_2006',
                              'IGS_UC_G_IVGSTARA_2006',
                              'IGS_UC_N_IVNSTARA_2006',
                              'IGS_UC_N_IVNSTARC_2006',
                              'IGS_UC_G_IVGSTARG_2006',
                              'IGS_UC_G_IVGSTARH_2006',
                              'IGS_UC_N_IVNSTARH_2006',
                              'IGS_UC_G_IVGSTARK_2006',
                              'IGS_UC_N_IVNSTARK_2006',
                              'IGS_UC_G_IVGSTARN_2006',
                              'IGS_UC_N_IVNSTARN_2006',
                              'IGS_UC_G_IVGSTARW_2006',
                              'IGS_UC_N_IVNSTARW_2006',
                              'IGS_UC_G_IVGSTARX_2006',
                              'IGS_UC_N_IVNSTARX_2006',
                              'IGS_UC_N_IVNSTARZ1_2006',
                              'IGS_UC_G_IVGSTATEMENT_2006',
                              'IGS_UC_N_IVNSTATEMENT_2006',
                              'IGS_UC_G_IVGREFERENCE_2006',
                              'IGS_UC_N_IVNREFERENCE_2006',
                              'IGS_UC_G_CVGREFAMENDMENTS_2006',
                              'IGS_UC_G_CVGREFDEGREESUBJ_2006',
                              'IGS_UC_G_IVGSTARA_2007',
                              'IGS_UC_N_IVNSTARA_2007',
                              'IGS_UC_G_IVGSTARN_2007',
                              'IGS_UC_N_IVNSTARN_2007',
                              'IGS_UC_G_IVGSTARK_2007',
                              'IGS_UC_N_IVNSTARK_2007',
                              'IGS_UC_G_IVGSTARW_2007',
                              'IGS_UC_N_IVNSTARW_2007',
                              'IGS_UC_G_CVGCOURSE_2007',
                              'IGS_UC_N_CVNCOURSE_2007'
                            );

        l_cyc_info_rec             cur_cyc_info%ROWTYPE;
        l_configured_cycle         igs_uc_defaults.configured_cycle%TYPE;
        l_current_cycle            igs_uc_defaults.current_cycle%TYPE;
        l_ucas_interface           igs_uc_cyc_defaults.ucas_interface%TYPE;
        l_gttr_interface           igs_uc_cyc_defaults.ucas_interface%TYPE;
        l_nmas_interface           igs_uc_cyc_defaults.ucas_interface%TYPE;

  BEGIN

        --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
        IGS_GE_GEN_003.SET_ORG_ID;

        -- Get the configured and current cycle information and exit process if not found
        l_cyc_info_rec := NULL ;
        OPEN cur_cyc_info ;
        FETCH cur_cyc_info INTO l_cyc_info_rec ;
        CLOSE cur_cyc_info ;
        IF l_cyc_info_rec.configured_cycle IS NULL OR l_cyc_info_rec.current_cycle IS NULL THEN
            fnd_message.set_name('IGS','IGS_UC_CYCLE_NOT_FOUND');
            errbuf  := fnd_message.get;
            fnd_file.put_line(fnd_file.log, errbuf);
            retcode := 2 ;
            RETURN ;
        END IF;

        l_configured_cycle := l_cyc_info_rec.configured_cycle ;
        l_current_cycle := l_cyc_info_rec.current_cycle ;

        -- Checking if the configured and target cycle are same
        IF l_configured_cycle = p_target_cycle THEN
           fnd_message.set_name('IGS','IGS_UC_CONF_TARG_SAME');
           fnd_file.put_line(fnd_file.log, fnd_message.get);
        END IF;

        -- Fetching 'UCAS_INTERFACE'
        OPEN  cur_ucas_interface (p_target_cycle, 'U');
        FETCH cur_ucas_interface INTO l_ucas_interface;
        CLOSE cur_ucas_interface;

        -- Drop all synonyms
        FOR rec_cur_synonyms IN cur_synonyms LOOP
            BEGIN

                apps_ddl.apps_ddl('DROP SYNONYM ' || rec_cur_synonyms.object_name);
                log_msg(rec_cur_synonyms.object_name, 'D');

            EXCEPTION
            WHEN OTHERS THEN
                retcode := 2 ;
                log_msg(rec_cur_synonyms.object_name, 'I');
            END;
        END LOOP;

        IF p_target_cycle < 2006 THEN
            create_synonym('C', 'IGS_UC_U_CVCONTROL_2003',        'CVCONTROL',           p_dblink_name, 'IGS_UC_CVCONTROL_2003');
        ELSE
            create_synonym('D', 'IGS_UC_U_CVCONTROL_2003',        'CVCONTROL',           p_dblink_name, 'IGS_UC_CVCONTROL_2003');
        END IF;

        IF p_target_cycle < 2007 THEN
            create_synonym('C', 'IGS_UC_U_CVREFAMENDMENTS_2003',  'CVREFAMENDMENTS',     p_dblink_name, 'IGS_UC_CVREFAMENDMENTS_2003');
            create_synonym('D', 'IGS_UC_U_CVREFAMENDMENTS_2007',  'CVREFAMENDMENTS',     p_dblink_name, 'IGS_UC_CVREFAMENDMENTS_2007');
        ELSE
            create_synonym('D', 'IGS_UC_U_CVREFAMENDMENTS_2003',  'CVREFAMENDMENTS',     p_dblink_name, 'IGS_UC_CVREFAMENDMENTS_2003');
            create_synonym('C', 'IGS_UC_U_CVREFAMENDMENTS_2007',  'CVREFAMENDMENTS',     p_dblink_name, 'IGS_UC_CVREFAMENDMENTS_2007');
        END IF;


        -- For all synonyms pertaining to REFERENCE VIEWS for target cycle
        IF p_target_cycle = l_current_cycle THEN

                 -- Check the UCAS Inteface Profile value is whether Hercules or Marvin.
                 IF (l_ucas_interface = 'H') THEN

                     -- Create Synonyms to Hercules for the views 'uvCourseVacancies',
                     -- 'uvCourseVacOptions', 'uvOfferAbbrev'
                     IF p_target_cycle < 2006 THEN
                         create_synonym('C', 'IGS_UC_U_UVCOURSEVACS_2003',     'UVCOURSEVACANCIES',   p_dblink_name, 'IGS_UC_UVCOURSEVACANCIES_2003');
                         create_synonym('C', 'IGS_UC_U_UVCOURSEVACOPS_2003',   'UVCOURSEVACOPTIONS',  p_dblink_name, 'IGS_UC_UVCOURSEVACOPTIONS_2003');

                     ELSE
                         create_synonym('D', 'IGS_UC_U_UVCOURSEVACS_2003',     'UVCOURSEVACANCIES',   p_dblink_name, 'IGS_UC_UVCOURSEVACANCIES_2003');
                         create_synonym('D', 'IGS_UC_U_UVCOURSEVACOPS_2003',   'UVCOURSEVACOPTIONS',  p_dblink_name, 'IGS_UC_UVCOURSEVACOPTIONS_2003');

                     END IF;

                     create_synonym('C', 'IGS_UC_U_UVOFFERABBREV_2003',    'UVOFFERABBREV',       p_dblink_name, 'IGS_UC_UVOFFERABBREV_2003');

                 ELSE
                     -- Create Synonyms to DUMMY VIEW for the views 'uvCourseVacancies',
                     -- 'uvCourseVacOptions', 'uvOfferAbbrev'
                     create_synonym('D', 'IGS_UC_U_UVCOURSEVACS_2003',     'UVCOURSEVACANCIES',   p_dblink_name, 'IGS_UC_UVCOURSEVACANCIES_2003');
                     create_synonym('D', 'IGS_UC_U_UVCOURSEVACOPS_2003',   'UVCOURSEVACOPTIONS',  p_dblink_name, 'IGS_UC_UVCOURSEVACOPTIONS_2003');
                     create_synonym('D', 'IGS_UC_U_UVOFFERABBREV_2003',    'UVOFFERABBREV',       p_dblink_name, 'IGS_UC_UVOFFERABBREV_2003');

                 END IF;


                 -- Create Synonym to HERCULES for views OTHER THAN
                   -- uvCourseVacs, uvCourseVacOptions, uvOfferAbbrev (already done)
                   -- uvContact, uvContactGroups, cvRefPre2000Pocc, cvRefUCASGroup, uvInstitution, cvRefNationality, cvRefCountry (dependent on year)
                 create_synonym('C', 'IGS_UC_U_CVCOURSE_2003',         'CVCOURSE',            p_dblink_name, 'IGS_UC_CVCOURSE_2003');
                 create_synonym('C', 'IGS_UC_U_CVEBLSUBJECT_2003',     'CVEBLSUBJECT',        p_dblink_name, 'IGS_UC_CVEBLSUBJECT_2003');
                 create_synonym('C', 'IGS_UC_U_CVINSTITUTION_2003',    'CVINSTITUTION',       p_dblink_name, 'IGS_UC_CVINSTITUTION_2003');
                 create_synonym('C', 'IGS_UC_U_CVJNTADMISSIONS_2003',  'CVJOINTADMISSIONS',   p_dblink_name, 'IGS_UC_CVJOINTADMISSIONS_2003');
                 create_synonym('C', 'IGS_UC_U_CVNAME_2003',           'CVNAME',              p_dblink_name, 'IGS_UC_CVNAME_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFAPR_2003',         'CVREFAPR',            p_dblink_name, 'IGS_UC_CVREFAPR_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFAWARDBODY_2003',   'CVREFAWARDBODY',      p_dblink_name, 'IGS_UC_CVREFAWARDBODY_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFDIS_2003',         'CVREFDIS',            p_dblink_name, 'IGS_UC_CVREFDIS_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFERROR_2003',       'CVREFERROR',          p_dblink_name, 'IGS_UC_CVREFERROR_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFESTGROUP_2003',    'CVREFESTGROUP',       p_dblink_name, 'IGS_UC_CVREFESTGROUP_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFETHNIC_2003',      'CVREFETHNIC',         p_dblink_name, 'IGS_UC_CVREFETHNIC_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFEXAM_2003',        'CVREFEXAM',           p_dblink_name, 'IGS_UC_CVREFEXAM_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFFEE_2003',         'CVREFFEE',            p_dblink_name, 'IGS_UC_CVREFFEE_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFKEYWORD_2003',     'CVREFKEYWORD',        p_dblink_name, 'IGS_UC_CVREFKEYWORD_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFOEQ_2003',         'CVREFOEQ',            p_dblink_name, 'IGS_UC_CVREFOEQ_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFOFFERABBREV_2003', 'CVREFOFFERABBREV',    p_dblink_name, 'IGS_UC_CVREFOFFERABBREV_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFOFFERSUBJ_2003',   'CVREFOFFERSUBJ',      p_dblink_name, 'IGS_UC_CVREFOFFERSUBJ_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFPOCC_2003',        'CVREFPOCC',           p_dblink_name, 'IGS_UC_CVREFPOCC_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFRESCAT_2003',      'CVREFRESCAT',         p_dblink_name, 'IGS_UC_CVREFRESCAT_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFSCHOOLTYPE_2003',  'CVREFSCHOOLTYPE',     p_dblink_name, 'IGS_UC_CVREFSCHOOLTYPE_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFSOCIALCLASS_2003', 'CVREFSOCIALCLASS',    p_dblink_name, 'IGS_UC_CVREFSOCIALCLASS_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFSOCIOECON_2003',   'CVREFSOCIOECONOMIC',  p_dblink_name, 'IGS_UC_CVREFSOCIOECONOMIC_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFSTATUS_2003',      'CVREFSTATUS',         p_dblink_name, 'IGS_UC_CVREFSTATUS_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFSUBJ_2003',        'CVREFSUBJ',           p_dblink_name, 'IGS_UC_CVREFSUBJ_2003');
                 create_synonym('C', 'IGS_UC_U_CVREFTARIFF_2003',      'CVREFTARIFF',         p_dblink_name, 'IGS_UC_CVREFTARIFF_2003');
                 create_synonym('C', 'IGS_UC_U_CVSCHOOLCONTACT_2003',  'CVSCHOOLCONTACT',     p_dblink_name, 'IGS_UC_CVSCHOOLCONTACT_2003');
                 create_synonym('C', 'IGS_UC_U_CVSCHOOL_2003',         'CVSCHOOL',            p_dblink_name, 'IGS_UC_CVSCHOOL_2003');
                 create_synonym('C', 'IGS_UC_U_UVCOURSEKEYWORD_2003',  'UVCOURSEKEYWORD',     p_dblink_name, 'IGS_UC_UVCOURSEKEYWORD_2003');
                 create_synonym('C', 'IGS_UC_U_UVCOURSE_2003',         'UVCOURSE',            p_dblink_name, 'IGS_UC_UVCOURSE_2003');

                 IF p_target_cycle = 2003 THEN

                    -- Point following synonyms to HERCULES
                    create_synonym('C', 'IGS_UC_U_UVINSTITUTION_2003',    'UVINSTITUTION',       p_dblink_name, 'IGS_UC_UVINSTITUTION_2003');
                    create_synonym('C', 'IGS_UC_U_CVREFPRE2000POCC_2003', 'CVREFPRE2000POCC',    p_dblink_name, 'IGS_UC_CVREFPRE2000POCC_2003');
                    create_synonym('C', 'IGS_UC_U_CVREFUCASGROUP_2003',   'CVREFUCASGROUP',      p_dblink_name, 'IGS_UC_CVREFUCASGROUP_2003');
                    create_synonym('C', 'IGS_UC_U_UVCONTACT_2003',        'UVCONTACT',           p_dblink_name, 'IGS_UC_UVCONTACT_2003');
                    create_synonym('C', 'IGS_UC_U_UVCONTGRP_2003',        'UVCONTGRP',           p_dblink_name, 'IGS_UC_UVCONTGRP_2003');

                    -- Point following synonyms to DUMMY
                    create_synonym('D', 'IGS_UC_U_UVINSTITUTION_2004',    'UVINSTITUTION',       p_dblink_name, 'IGS_UC_UVINSTITUTION_2004');
                    create_synonym('D', 'IGS_UC_U_CVREFCOUNTRY_2007',     'CVREFCOUNTRY',        p_dblink_name, 'IGS_UC_CVREFCOUNTRY_2007');
                    create_synonym('D', 'IGS_UC_U_CVREFNATIONALITY_2007', 'CVREFNATIONALITY',    p_dblink_name, 'IGS_UC_CVREFNATIONALITY_2007');

                 ELSIF p_target_cycle = 2004 OR p_target_cycle = 2005 THEN

                    -- Point following synonyms to HERCULES
                    create_synonym('C', 'IGS_UC_U_UVINSTITUTION_2004',    'UVINSTITUTION',       p_dblink_name, 'IGS_UC_UVINSTITUTION_2004');
                    create_synonym('C', 'IGS_UC_U_CVREFPRE2000POCC_2003', 'CVREFPRE2000POCC',    p_dblink_name, 'IGS_UC_CVREFPRE2000POCC_2003');
                    create_synonym('C', 'IGS_UC_U_CVREFUCASGROUP_2003',   'CVREFUCASGROUP',      p_dblink_name, 'IGS_UC_CVREFUCASGROUP_2003');
                    create_synonym('C', 'IGS_UC_U_UVCONTACT_2003',        'UVCONTACT',           p_dblink_name, 'IGS_UC_UVCONTACT_2003');
                    create_synonym('C', 'IGS_UC_U_UVCONTGRP_2003',        'UVCONTGRP',           p_dblink_name, 'IGS_UC_UVCONTGRP_2003');

                    -- Point following synonyms to DUMMY
                    create_synonym('D', 'IGS_UC_U_UVINSTITUTION_2003',    'UVINSTITUTION',       p_dblink_name, 'IGS_UC_UVINSTITUTION_2003');
                    create_synonym('D', 'IGS_UC_U_CVREFCOUNTRY_2007',     'CVREFCOUNTRY',        p_dblink_name, 'IGS_UC_CVREFCOUNTRY_2007');
                    create_synonym('D', 'IGS_UC_U_CVREFNATIONALITY_2007', 'CVREFNATIONALITY',    p_dblink_name, 'IGS_UC_CVREFNATIONALITY_2007');

                 ELSIF p_target_cycle = 2006 THEN

                    -- Point following synonyms to HERCULES
                    create_synonym('C', 'IGS_UC_U_UVINSTITUTION_2004',    'UVINSTITUTION',       p_dblink_name, 'IGS_UC_UVINSTITUTION_2004');

                    -- Point following synonyms to DUMMY
                    create_synonym('D', 'IGS_UC_U_UVINSTITUTION_2003',    'UVINSTITUTION',       p_dblink_name, 'IGS_UC_UVINSTITUTION_2003');
                    create_synonym('D', 'IGS_UC_U_CVREFPRE2000POCC_2003', 'CVREFPRE2000POCC',    p_dblink_name, 'IGS_UC_CVREFPRE2000POCC_2003');
                    create_synonym('D', 'IGS_UC_U_CVREFUCASGROUP_2003',   'CVREFUCASGROUP',      p_dblink_name, 'IGS_UC_CVREFUCASGROUP_2003');
                    create_synonym('D', 'IGS_UC_U_UVCONTACT_2003',        'UVCONTACT',           p_dblink_name, 'IGS_UC_UVCONTACT_2003');
                    create_synonym('D', 'IGS_UC_U_UVCONTGRP_2003',        'UVCONTGRP',           p_dblink_name, 'IGS_UC_UVCONTGRP_2003');
                    create_synonym('D', 'IGS_UC_U_CVREFCOUNTRY_2007',     'CVREFCOUNTRY',        p_dblink_name, 'IGS_UC_CVREFCOUNTRY_2007');
                    create_synonym('D', 'IGS_UC_U_CVREFNATIONALITY_2007', 'CVREFNATIONALITY',    p_dblink_name, 'IGS_UC_CVREFNATIONALITY_2007');

                 ELSIF p_target_cycle = 2007 THEN
                    -- Point following synonyms to HERCULES
                    create_synonym('C', 'IGS_UC_U_CVREFCOUNTRY_2007',     'CVREFCOUNTRY',        p_dblink_name, 'IGS_UC_CVREFCOUNTRY_2007');
                    create_synonym('C', 'IGS_UC_U_CVREFNATIONALITY_2007', 'CVREFNATIONALITY',    p_dblink_name, 'IGS_UC_CVREFNATIONALITY_2007');
                    create_synonym('C', 'IGS_UC_U_UVINSTITUTION_2004',    'UVINSTITUTION',       p_dblink_name, 'IGS_UC_UVINSTITUTION_2004');

                    -- Point following synonyms to DUMMY
                    create_synonym('D', 'IGS_UC_U_UVINSTITUTION_2003',    'UVINSTITUTION',       p_dblink_name, 'IGS_UC_UVINSTITUTION_2003');
                    create_synonym('D', 'IGS_UC_U_CVREFPRE2000POCC_2003', 'CVREFPRE2000POCC',    p_dblink_name, 'IGS_UC_CVREFPRE2000POCC_2003');
                    create_synonym('D', 'IGS_UC_U_CVREFUCASGROUP_2003',   'CVREFUCASGROUP',      p_dblink_name, 'IGS_UC_CVREFUCASGROUP_2003');
                    create_synonym('D', 'IGS_UC_U_UVCONTACT_2003',        'UVCONTACT',           p_dblink_name, 'IGS_UC_UVCONTACT_2003');
                    create_synonym('D', 'IGS_UC_U_UVCONTGRP_2003',        'UVCONTGRP',           p_dblink_name, 'IGS_UC_UVCONTGRP_2003');

                 END IF;

        -- Create Synonyms to dummy views
        ELSE

                create_synonym('D', 'IGS_UC_U_CVCOURSE_2003',         'CVCOURSE',            p_dblink_name, 'IGS_UC_CVCOURSE_2003');
                create_synonym('D', 'IGS_UC_U_CVEBLSUBJECT_2003',     'CVEBLSUBJECT',        p_dblink_name, 'IGS_UC_CVEBLSUBJECT_2003');
                create_synonym('D', 'IGS_UC_U_CVINSTITUTION_2003',    'CVINSTITUTION',       p_dblink_name, 'IGS_UC_CVINSTITUTION_2003');
                create_synonym('D', 'IGS_UC_U_CVJNTADMISSIONS_2003',  'CVJOINTADMISSIONS',   p_dblink_name, 'IGS_UC_CVJOINTADMISSIONS_2003');
                create_synonym('D', 'IGS_UC_U_CVNAME_2003',           'CVNAME',              p_dblink_name, 'IGS_UC_CVNAME_2003');
                create_synonym('D', 'IGS_UC_U_CVREFAPR_2003',         'CVREFAPR',            p_dblink_name, 'IGS_UC_CVREFAPR_2003');
                create_synonym('D', 'IGS_UC_U_CVREFAWARDBODY_2003',   'CVREFAWARDBODY',      p_dblink_name, 'IGS_UC_CVREFAWARDBODY_2003');
                create_synonym('D', 'IGS_UC_U_CVREFDIS_2003',         'CVREFDIS',            p_dblink_name, 'IGS_UC_CVREFDIS_2003');
                create_synonym('D', 'IGS_UC_U_CVREFERROR_2003',       'CVREFERROR',          p_dblink_name, 'IGS_UC_CVREFERROR_2003');
                create_synonym('D', 'IGS_UC_U_CVREFESTGROUP_2003',    'CVREFESTGROUP',       p_dblink_name, 'IGS_UC_CVREFESTGROUP_2003');
                create_synonym('D', 'IGS_UC_U_CVREFETHNIC_2003',      'CVREFETHNIC',         p_dblink_name, 'IGS_UC_CVREFETHNIC_2003');
                create_synonym('D', 'IGS_UC_U_CVREFEXAM_2003',        'CVREFEXAM',           p_dblink_name, 'IGS_UC_CVREFEXAM_2003');
                create_synonym('D', 'IGS_UC_U_CVREFFEE_2003',         'CVREFFEE',            p_dblink_name, 'IGS_UC_CVREFFEE_2003');
                create_synonym('D', 'IGS_UC_U_CVREFKEYWORD_2003',     'CVREFKEYWORD',        p_dblink_name, 'IGS_UC_CVREFKEYWORD_2003');
                create_synonym('D', 'IGS_UC_U_CVREFOEQ_2003',         'CVREFOEQ',            p_dblink_name, 'IGS_UC_CVREFOEQ_2003');
                create_synonym('D', 'IGS_UC_U_CVREFOFFERABBREV_2003', 'CVREFOFFERABBREV',    p_dblink_name, 'IGS_UC_CVREFOFFERABBREV_2003');
                create_synonym('D', 'IGS_UC_U_CVREFOFFERSUBJ_2003',   'CVREFOFFERSUBJ',      p_dblink_name, 'IGS_UC_CVREFOFFERSUBJ_2003');
                create_synonym('D', 'IGS_UC_U_CVREFPOCC_2003',        'CVREFPOCC',           p_dblink_name, 'IGS_UC_CVREFPOCC_2003');
                create_synonym('D', 'IGS_UC_U_CVREFPRE2000POCC_2003', 'CVREFPRE2000POCC',    p_dblink_name, 'IGS_UC_CVREFPRE2000POCC_2003');
                create_synonym('D', 'IGS_UC_U_CVREFRESCAT_2003',      'CVREFRESCAT',         p_dblink_name, 'IGS_UC_CVREFRESCAT_2003');
                create_synonym('D', 'IGS_UC_U_CVREFSCHOOLTYPE_2003',  'CVREFSCHOOLTYPE',     p_dblink_name, 'IGS_UC_CVREFSCHOOLTYPE_2003');
                create_synonym('D', 'IGS_UC_U_CVREFSOCIALCLASS_2003', 'CVREFSOCIALCLASS',    p_dblink_name, 'IGS_UC_CVREFSOCIALCLASS_2003');
                create_synonym('D', 'IGS_UC_U_CVREFSOCIOECON_2003',   'CVREFSOCIOECONOMIC',  p_dblink_name, 'IGS_UC_CVREFSOCIOECONOMIC_2003');
                create_synonym('D', 'IGS_UC_U_CVREFSTATUS_2003',      'CVREFSTATUS',         p_dblink_name, 'IGS_UC_CVREFSTATUS_2003');
                create_synonym('D', 'IGS_UC_U_CVREFSUBJ_2003',        'CVREFSUBJ',           p_dblink_name, 'IGS_UC_CVREFSUBJ_2003');
                create_synonym('D', 'IGS_UC_U_CVREFTARIFF_2003',      'CVREFTARIFF',         p_dblink_name, 'IGS_UC_CVREFTARIFF_2003');
                create_synonym('D', 'IGS_UC_U_CVREFUCASGROUP_2003',   'CVREFUCASGROUP',      p_dblink_name, 'IGS_UC_CVREFUCASGROUP_2003');
                create_synonym('D', 'IGS_UC_U_CVSCHOOLCONTACT_2003',  'CVSCHOOLCONTACT',     p_dblink_name, 'IGS_UC_CVSCHOOLCONTACT_2003');
                create_synonym('D', 'IGS_UC_U_CVSCHOOL_2003',         'CVSCHOOL',            p_dblink_name, 'IGS_UC_CVSCHOOL_2003');
                create_synonym('D', 'IGS_UC_U_UVCONTACT_2003',        'UVCONTACT',           p_dblink_name, 'IGS_UC_UVCONTACT_2003');
                create_synonym('D', 'IGS_UC_U_UVCONTGRP_2003',        'UVCONTGRP',           p_dblink_name, 'IGS_UC_UVCONTGRP_2003');
                create_synonym('D', 'IGS_UC_U_UVCOURSEKEYWORD_2003',  'UVCOURSEKEYWORD',     p_dblink_name, 'IGS_UC_UVCOURSEKEYWORD_2003');
                create_synonym('D', 'IGS_UC_U_UVCOURSE_2003',         'UVCOURSE',            p_dblink_name, 'IGS_UC_UVCOURSE_2003');
                create_synonym('D', 'IGS_UC_U_UVINSTITUTION_2003',    'UVINSTITUTION',       p_dblink_name, 'IGS_UC_UVINSTITUTION_2003');
                create_synonym('D', 'IGS_UC_U_UVINSTITUTION_2004',    'UVINSTITUTION',       p_dblink_name, 'IGS_UC_UVINSTITUTION_2004');
                create_synonym('D', 'IGS_UC_U_UVCOURSEVACS_2003',     'UVCOURSEVACANCIES',   p_dblink_name, 'IGS_UC_UVCOURSEVACANCIES_2003');
                create_synonym('D', 'IGS_UC_U_UVCOURSEVACOPS_2003',   'UVCOURSEVACOPTIONS',  p_dblink_name, 'IGS_UC_UVCOURSEVACOPTIONS_2003');
                create_synonym('D', 'IGS_UC_U_UVOFFERABBREV_2003',    'UVOFFERABBREV',       p_dblink_name, 'IGS_UC_UVOFFERABBREV_2003');
                create_synonym('D', 'IGS_UC_U_CVREFCOUNTRY_2007',     'CVREFCOUNTRY',        p_dblink_name, 'IGS_UC_CVREFCOUNTRY_2007');
                create_synonym('D', 'IGS_UC_U_CVREFNATIONALITY_2007', 'CVREFNATIONALITY',    p_dblink_name, 'IGS_UC_CVREFNATIONALITY_2007');


        END IF ;

        -- APPLICATION RELATED TABLES/VIEWS
        -- UCAS synonyms for target cycle for applicant tables
        IF (l_ucas_interface = 'H') THEN

            -- For 2003 - 2003 Synonyms should point to Hercules and 2004 Synonyms should point to dummy
            IF p_target_cycle = 2003 THEN

               -- 2003 Synonyms to HERCULES
               create_synonym('C', 'IGS_UC_U_IVQUALIFICATION_2003',  'IVQUALIFICATION',     p_dblink_name, 'IGS_UC_IVQUALIFICATION_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARA_2003',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARC_2003',          'IVSTARC',             p_dblink_name, 'IGS_UC_IVSTARC_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARH_2003',          'IVSTARH',             p_dblink_name, 'IGS_UC_IVSTARH_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARK_2003',          'IVSTARK',             p_dblink_name, 'IGS_UC_IVSTARK_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARN_2003',          'IVSTARN',             p_dblink_name, 'IGS_UC_IVSTARN_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARPQR_2003',        'IVSTARPQR',           p_dblink_name, 'IGS_UC_IVSTARPQR_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARW_2003',          'IVSTARW',             p_dblink_name, 'IGS_UC_IVSTARW_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARX_2003',          'IVSTARX',             p_dblink_name, 'IGS_UC_IVSTARX_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARZ1_2003',         'IVSTARZ1',            p_dblink_name, 'IGS_UC_IVSTARZ1_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARZ2_2003',         'IVSTARZ2',            p_dblink_name, 'IGS_UC_IVSTARZ2_2003');
               create_synonym('C', 'IGS_UC_U_IVSTATEMENT_2003',      'IVSTATEMENT',         p_dblink_name, 'IGS_UC_IVSTATEMENT_2003');
               create_synonym('C', 'IGS_UC_U_TRANIN_2003',           'TRANIN',              p_dblink_name, 'IGS_UC_TRANIN_2003');
               create_synonym('C', 'IGS_UC_U_IVOFFER_2003',          'IVOFFER',             p_dblink_name, 'IGS_UC_IVOFFER_2003');

               -- 2004/05 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVFORMQUALS_2004',      'IVFORMQUALS',         p_dblink_name, 'IGS_UC_IVFORMQUALS_2004');
               create_synonym('D', 'IGS_UC_U_IVREFERENCE_2004',      'IVREFERENCE',         p_dblink_name, 'IGS_UC_IVREFERENCE_2004');
               create_synonym('D', 'IGS_UC_U_IVSTARJ_2004',          'IVSTARJ',             p_dblink_name, 'IGS_UC_IVSTARJ_2004');
               create_synonym('D', 'IGS_UC_U_IVSTARW_2004',          'IVSTARW',             p_dblink_name, 'IGS_UC_IVSTARW_2004');
               create_synonym('D', 'IGS_UC_U_TRANIN_2004',           'TRANIN',              p_dblink_name, 'IGS_UC_TRANIN_2004');
               create_synonym('D', 'IGS_UC_U_IVSTATEMENT_2004',      'IVSTATEMENT',         p_dblink_name, 'IGS_UC_IVSTATEMENT_2004');

               -- 2006 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVSTARA_2006',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2006');
               create_synonym('D', 'IGS_UC_U_IVFORMQUALS_2006',      'IVFORMQUALS',         p_dblink_name, 'IGS_UC_IVFORMQUALS_2006');
               create_synonym('D', 'IGS_UC_U_IVREFERENCE_2006',      'IVREFERENCE',         p_dblink_name, 'IGS_UC_IVREFERENCE_2006');

               -- 2007 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVSTARA_2007',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2007');
               create_synonym('D', 'IGS_UC_U_IVSTARN_2007',          'IVSTARN',             p_dblink_name, 'IGS_UC_IVSTARN_2007');
               create_synonym('D', 'IGS_UC_U_IVSTARK_2007',          'IVSTARK',             p_dblink_name, 'IGS_UC_IVSTARK_2007');


            -- For 2004 - Synonyms in both 2003 and 2004 should point to dummy and others to Hercules
            -- For 2005 - Synonyms similar to 2004
            ELSIF p_target_cycle = 2004 OR p_target_cycle = 2005 THEN

               -- New 2004/05 synonyms to HERCULES
               create_synonym('C', 'IGS_UC_U_IVFORMQUALS_2004',      'IVFORMQUALS',         p_dblink_name, 'IGS_UC_IVFORMQUALS_2004');
               create_synonym('C', 'IGS_UC_U_IVREFERENCE_2004',      'IVREFERENCE',         p_dblink_name, 'IGS_UC_IVREFERENCE_2004');
               create_synonym('C', 'IGS_UC_U_IVSTARJ_2004',          'IVSTARJ',             p_dblink_name, 'IGS_UC_IVSTARJ_2004');
               create_synonym('C', 'IGS_UC_U_IVSTARW_2004',          'IVSTARW',             p_dblink_name, 'IGS_UC_IVSTARW_2004');
               create_synonym('C', 'IGS_UC_U_TRANIN_2004',           'TRANIN',              p_dblink_name, 'IGS_UC_TRANIN_2004');
               create_synonym('C', 'IGS_UC_U_IVSTATEMENT_2004',      'IVSTATEMENT',         p_dblink_name, 'IGS_UC_IVSTATEMENT_2004');

               -- 2003 Synonyms to HERCULES
               create_synonym('C', 'IGS_UC_U_IVQUALIFICATION_2003',  'IVQUALIFICATION',     p_dblink_name, 'IGS_UC_IVQUALIFICATION_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARA_2003',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARC_2003',          'IVSTARC',             p_dblink_name, 'IGS_UC_IVSTARC_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARH_2003',          'IVSTARH',             p_dblink_name, 'IGS_UC_IVSTARH_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARK_2003',          'IVSTARK',             p_dblink_name, 'IGS_UC_IVSTARK_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARN_2003',          'IVSTARN',             p_dblink_name, 'IGS_UC_IVSTARN_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARPQR_2003',        'IVSTARPQR',           p_dblink_name, 'IGS_UC_IVSTARPQR_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARX_2003',          'IVSTARX',             p_dblink_name, 'IGS_UC_IVSTARX_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARZ1_2003',         'IVSTARZ1',            p_dblink_name, 'IGS_UC_IVSTARZ1_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARZ2_2003',         'IVSTARZ2',            p_dblink_name, 'IGS_UC_IVSTARZ2_2003');
               create_synonym('C', 'IGS_UC_U_IVOFFER_2003',          'IVOFFER',             p_dblink_name, 'IGS_UC_IVOFFER_2003');

               -- 2003 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVSTARW_2003',          'IVSTARW',             p_dblink_name, 'IGS_UC_IVSTARW_2003');
               create_synonym('D', 'IGS_UC_U_IVSTATEMENT_2003',      'IVSTATEMENT',         p_dblink_name, 'IGS_UC_IVSTATEMENT_2003');
               create_synonym('D', 'IGS_UC_U_TRANIN_2003',           'TRANIN',              p_dblink_name, 'IGS_UC_TRANIN_2003');

               -- 2006 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVSTARA_2006',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2006');
               create_synonym('D', 'IGS_UC_U_IVFORMQUALS_2006',      'IVFORMQUALS',         p_dblink_name, 'IGS_UC_IVFORMQUALS_2006');
               create_synonym('D', 'IGS_UC_U_IVREFERENCE_2006',      'IVREFERENCE',         p_dblink_name, 'IGS_UC_IVREFERENCE_2006');

               -- 2007 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVSTARA_2007',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2007');
               create_synonym('D', 'IGS_UC_U_IVSTARN_2007',          'IVSTARN',             p_dblink_name, 'IGS_UC_IVSTARN_2007');
               create_synonym('D', 'IGS_UC_U_IVSTARK_2007',          'IVSTARK',             p_dblink_name, 'IGS_UC_IVSTARK_2007');


            -- For 2006 - Synonyms in both 2003 and 2004 should point to dummy and others to Hercules
            ELSIF p_target_cycle = 2006 THEN

               -- New 2006 Synonyms to HERCULES
               create_synonym('C', 'IGS_UC_U_IVSTARA_2006',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2006');
               create_synonym('C', 'IGS_UC_U_IVFORMQUALS_2006',      'IVFORMQUALS',         p_dblink_name, 'IGS_UC_IVFORMQUALS_2006');
               create_synonym('C', 'IGS_UC_U_IVREFERENCE_2006',      'IVREFERENCE',         p_dblink_name, 'IGS_UC_IVREFERENCE_2006');

               -- 2004/05 synonyms to HERCULES
               create_synonym('C', 'IGS_UC_U_IVSTARJ_2004',          'IVSTARJ',             p_dblink_name, 'IGS_UC_IVSTARJ_2004');
               create_synonym('C', 'IGS_UC_U_IVSTARW_2004',          'IVSTARW',             p_dblink_name, 'IGS_UC_IVSTARW_2004');
               create_synonym('C', 'IGS_UC_U_TRANIN_2004',           'TRANIN',              p_dblink_name, 'IGS_UC_TRANIN_2004');
               create_synonym('C', 'IGS_UC_U_IVSTATEMENT_2004',      'IVSTATEMENT',         p_dblink_name, 'IGS_UC_IVSTATEMENT_2004');

               -- 2003 Synonyms to HERCULES
               create_synonym('C', 'IGS_UC_U_IVQUALIFICATION_2003',  'IVQUALIFICATION',     p_dblink_name, 'IGS_UC_IVQUALIFICATION_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARC_2003',          'IVSTARC',             p_dblink_name, 'IGS_UC_IVSTARC_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARH_2003',          'IVSTARH',             p_dblink_name, 'IGS_UC_IVSTARH_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARK_2003',          'IVSTARK',             p_dblink_name, 'IGS_UC_IVSTARK_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARN_2003',          'IVSTARN',             p_dblink_name, 'IGS_UC_IVSTARN_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARPQR_2003',        'IVSTARPQR',           p_dblink_name, 'IGS_UC_IVSTARPQR_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARX_2003',          'IVSTARX',             p_dblink_name, 'IGS_UC_IVSTARX_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARZ1_2003',         'IVSTARZ1',            p_dblink_name, 'IGS_UC_IVSTARZ1_2003');
               create_synonym('C', 'IGS_UC_U_IVOFFER_2003',          'IVOFFER',             p_dblink_name, 'IGS_UC_IVOFFER_2003');

               -- 2003 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVSTARW_2003',          'IVSTARW',             p_dblink_name, 'IGS_UC_IVSTARW_2003');
               create_synonym('D', 'IGS_UC_U_IVSTATEMENT_2003',      'IVSTATEMENT',         p_dblink_name, 'IGS_UC_IVSTATEMENT_2003');
               create_synonym('D', 'IGS_UC_U_TRANIN_2003',           'TRANIN',              p_dblink_name, 'IGS_UC_TRANIN_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARA_2003',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARZ2_2003',         'IVSTARZ2',            p_dblink_name, 'IGS_UC_IVSTARZ2_2003');

               -- 2004/05 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVFORMQUALS_2004',      'IVFORMQUALS',         p_dblink_name, 'IGS_UC_IVFORMQUALS_2004');
               create_synonym('D', 'IGS_UC_U_IVREFERENCE_2004',      'IVREFERENCE',         p_dblink_name, 'IGS_UC_IVREFERENCE_2004');

               -- 2007 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVSTARA_2007',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2007');
               create_synonym('D', 'IGS_UC_U_IVSTARN_2007',          'IVSTARN',             p_dblink_name, 'IGS_UC_IVSTARN_2007');
               create_synonym('D', 'IGS_UC_U_IVSTARK_2007',          'IVSTARK',             p_dblink_name, 'IGS_UC_IVSTARK_2007');


            -- For 2007 - Synonyms in both 2003 and 2004 should point to dummy and others to Hercules
            ELSIF p_target_cycle = 2007 THEN

               -- New 2007 Synonyms to HERCULES
               create_synonym('C', 'IGS_UC_U_IVSTARA_2007',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2007');
               create_synonym('C', 'IGS_UC_U_IVSTARN_2007',          'IVSTARN',             p_dblink_name, 'IGS_UC_IVSTARN_2007');
               create_synonym('C', 'IGS_UC_U_IVSTARK_2007',          'IVSTARK',             p_dblink_name, 'IGS_UC_IVSTARK_2007');

               -- 2006 Synonyms to HERCULES
               create_synonym('C', 'IGS_UC_U_IVFORMQUALS_2006',      'IVFORMQUALS',         p_dblink_name, 'IGS_UC_IVFORMQUALS_2006');
               create_synonym('C', 'IGS_UC_U_IVREFERENCE_2006',      'IVREFERENCE',         p_dblink_name, 'IGS_UC_IVREFERENCE_2006');

               -- 2004/05 synonyms to HERCULES
               create_synonym('C', 'IGS_UC_U_IVSTARJ_2004',          'IVSTARJ',             p_dblink_name, 'IGS_UC_IVSTARJ_2004');
               create_synonym('C', 'IGS_UC_U_IVSTARW_2004',          'IVSTARW',             p_dblink_name, 'IGS_UC_IVSTARW_2004');
               create_synonym('C', 'IGS_UC_U_TRANIN_2004',           'TRANIN',              p_dblink_name, 'IGS_UC_TRANIN_2004');
               create_synonym('C', 'IGS_UC_U_IVSTATEMENT_2004',      'IVSTATEMENT',         p_dblink_name, 'IGS_UC_IVSTATEMENT_2004');

               -- 2003 Synonyms to HERCULES
               create_synonym('C', 'IGS_UC_U_IVQUALIFICATION_2003',  'IVQUALIFICATION',     p_dblink_name, 'IGS_UC_IVQUALIFICATION_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARC_2003',          'IVSTARC',             p_dblink_name, 'IGS_UC_IVSTARC_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARH_2003',          'IVSTARH',             p_dblink_name, 'IGS_UC_IVSTARH_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARPQR_2003',        'IVSTARPQR',           p_dblink_name, 'IGS_UC_IVSTARPQR_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARX_2003',          'IVSTARX',             p_dblink_name, 'IGS_UC_IVSTARX_2003');
               create_synonym('C', 'IGS_UC_U_IVSTARZ1_2003',         'IVSTARZ1',            p_dblink_name, 'IGS_UC_IVSTARZ1_2003');
               create_synonym('C', 'IGS_UC_U_IVOFFER_2003',          'IVOFFER',             p_dblink_name, 'IGS_UC_IVOFFER_2003');

               -- 2003 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVSTARK_2003',          'IVSTARK',             p_dblink_name, 'IGS_UC_IVSTARK_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARW_2003',          'IVSTARW',             p_dblink_name, 'IGS_UC_IVSTARW_2003');
               create_synonym('D', 'IGS_UC_U_IVSTATEMENT_2003',      'IVSTATEMENT',         p_dblink_name, 'IGS_UC_IVSTATEMENT_2003');
               create_synonym('D', 'IGS_UC_U_TRANIN_2003',           'TRANIN',              p_dblink_name, 'IGS_UC_TRANIN_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARA_2003',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARZ2_2003',         'IVSTARZ2',            p_dblink_name, 'IGS_UC_IVSTARZ2_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARN_2003',          'IVSTARN',             p_dblink_name, 'IGS_UC_IVSTARN_2003');

               -- 2004/05 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVFORMQUALS_2004',      'IVFORMQUALS',         p_dblink_name, 'IGS_UC_IVFORMQUALS_2004');
               create_synonym('D', 'IGS_UC_U_IVREFERENCE_2004',      'IVREFERENCE',         p_dblink_name, 'IGS_UC_IVREFERENCE_2004');

               -- 2006 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVSTARA_2006',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2006');


            END IF;

        ELSE
               -- For marvin all the synonyms should point to dummy tables
               -- 2003 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVQUALIFICATION_2003',  'IVQUALIFICATION',     p_dblink_name, 'IGS_UC_IVQUALIFICATION_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARA_2003',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARC_2003',          'IVSTARC',             p_dblink_name, 'IGS_UC_IVSTARC_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARH_2003',          'IVSTARH',             p_dblink_name, 'IGS_UC_IVSTARH_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARK_2003',          'IVSTARK',             p_dblink_name, 'IGS_UC_IVSTARK_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARN_2003',          'IVSTARN',             p_dblink_name, 'IGS_UC_IVSTARN_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARPQR_2003',        'IVSTARPQR',           p_dblink_name, 'IGS_UC_IVSTARPQR_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARW_2003',          'IVSTARW',             p_dblink_name, 'IGS_UC_IVSTARW_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARX_2003',          'IVSTARX',             p_dblink_name, 'IGS_UC_IVSTARX_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARZ1_2003',         'IVSTARZ1',            p_dblink_name, 'IGS_UC_IVSTARZ1_2003');
               create_synonym('D', 'IGS_UC_U_IVSTARZ2_2003',         'IVSTARZ2',            p_dblink_name, 'IGS_UC_IVSTARZ2_2003');
               create_synonym('D', 'IGS_UC_U_IVSTATEMENT_2003',      'IVSTATEMENT',         p_dblink_name, 'IGS_UC_IVSTATEMENT_2003');
               create_synonym('D', 'IGS_UC_U_TRANIN_2003',           'TRANIN',              p_dblink_name, 'IGS_UC_TRANIN_2003');
               create_synonym('D', 'IGS_UC_U_IVOFFER_2003',          'IVOFFER',             p_dblink_name, 'IGS_UC_IVOFFER_2003');

               -- 2004/05 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVFORMQUALS_2004',      'IVFORMQUALS',         p_dblink_name, 'IGS_UC_IVFORMQUALS_2004');
               create_synonym('D', 'IGS_UC_U_IVREFERENCE_2004',      'IVREFERENCE',         p_dblink_name, 'IGS_UC_IVREFERENCE_2004');
               create_synonym('D', 'IGS_UC_U_IVSTARJ_2004',          'IVSTARJ',             p_dblink_name, 'IGS_UC_IVSTARJ_2004');
               create_synonym('D', 'IGS_UC_U_IVSTARW_2004',          'IVSTARW',             p_dblink_name, 'IGS_UC_IVSTARW_2004');
               create_synonym('D', 'IGS_UC_U_TRANIN_2004',           'TRANIN',              p_dblink_name, 'IGS_UC_TRANIN_2004');
               create_synonym('D', 'IGS_UC_U_IVSTATEMENT_2004',      'IVSTATEMENT',         p_dblink_name, 'IGS_UC_IVSTATEMENT_2004');

               -- 2006 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVSTARA_2006',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2006');
               create_synonym('D', 'IGS_UC_U_IVFORMQUALS_2006',      'IVFORMQUALS',         p_dblink_name, 'IGS_UC_IVFORMQUALS_2006');
               create_synonym('D', 'IGS_UC_U_IVREFERENCE_2006',      'IVREFERENCE',         p_dblink_name, 'IGS_UC_IVREFERENCE_2006');

               -- 2007 Synonyms to DUMMY
               create_synonym('D', 'IGS_UC_U_IVSTARA_2007',          'IVSTARA',             p_dblink_name, 'IGS_UC_IVSTARA_2007');
               create_synonym('D', 'IGS_UC_U_IVSTARN_2007',          'IVSTARN',             p_dblink_name, 'IGS_UC_IVSTARN_2007');
               create_synonym('D', 'IGS_UC_U_IVSTARK_2007',          'IVSTARK',             p_dblink_name, 'IGS_UC_IVSTARK_2007');


        END IF;


        -- Fetching 'GTTR_INTERFACE'
        OPEN  cur_ucas_interface (p_target_cycle, 'G');
        FETCH cur_ucas_interface INTO l_gttr_interface;
        CLOSE cur_ucas_interface;

        -- APPLICATION RELATED TABLES/VIEWS
        -- GTTR synonyms for target cycle for applicant tables
        IF (l_gttr_interface = 'H' AND p_target_cycle >= 2006) THEN

            -- For 2006 - Synonyms in 2006 should point to  Hercules
            IF p_target_cycle = 2006 THEN

               -- GTTR Small System Synonyms specific for 2006 pointing to HERCULES
               -- 2006 Reference Data to HERCULES
               create_synonym('C', 'IGS_UC_G_CVGREFAMENDMENTS_2006', 'CVGREFAMENDMENTS',    p_dblink_name, 'IGS_UC_CVGREFAMENDMENTS_2006');
               create_synonym('C', 'IGS_UC_G_CVGNAME_2006',          'CVGNAME',             p_dblink_name, 'IGS_UC_CVNAME_2003');
               create_synonym('C', 'IGS_UC_G_CVGREFDEGREESUBJ_2006', 'CVGREFDEGREESUBJECT', p_dblink_name, 'IGS_UC_CVGREFDEGREESUBJ_2006');

               -- 2006 Application Data to HERCULES
               create_synonym('C', 'IGS_UC_G_IVGOFFER_2006',         'IVGOFFER',            p_dblink_name, 'IGS_UC_IVGOFFER_2006');
               create_synonym('C', 'IGS_UC_G_IVGREFERENCE_2006',     'IVGREFERENCE',        p_dblink_name, 'IGS_UC_IVGREFERENCE_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTARA_2006',         'IVGSTARA',            p_dblink_name, 'IGS_UC_IVGSTARA_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTARG_2006',         'IVGSTARG',            p_dblink_name, 'IGS_UC_IVGSTARG_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTARH_2006',         'IVGSTARH',            p_dblink_name, 'IGS_UC_IVGSTARH_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTARK_2006',         'IVGSTARK',            p_dblink_name, 'IGS_UC_IVGSTARK_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTARN_2006',         'IVGSTARN',            p_dblink_name, 'IGS_UC_IVGSTARN_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTARW_2006',         'IVGSTARW',            p_dblink_name, 'IGS_UC_IVGSTARW_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTARX_2006',         'IVGSTARX',            p_dblink_name, 'IGS_UC_IVGSTARX_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTATEMENT_2006',     'IVGSTATEMENT',        p_dblink_name, 'IGS_UC_IVGSTATEMENT_2006');

               -- 2007 Reference Data to DUMMY
               create_synonym('D', 'IGS_UC_G_CVGCOURSE_2007',        'CVGCOURSE',           p_dblink_name, 'IGS_UC_CVGCOURSE_2007');

               -- 2007 Application Data to DUMMY
               create_synonym('D', 'IGS_UC_G_IVGSTARA_2007',         'IVGSTARA',            p_dblink_name, 'IGS_UC_IVGSTARA_2007');
               create_synonym('D', 'IGS_UC_G_IVGSTARN_2007',         'IVGSTARN',            p_dblink_name, 'IGS_UC_IVGSTARN_2007');
               create_synonym('D', 'IGS_UC_G_IVGSTARK_2007',         'IVGSTARK',            p_dblink_name, 'IGS_UC_IVGSTARK_2007');
               create_synonym('D', 'IGS_UC_G_IVGSTARW_2007',         'IVGSTARW',            p_dblink_name, 'IGS_UC_IVGSTARW_2007');


            ELSIF p_target_cycle = 2007 THEN

               -- 2007 Reference Data to HERCULES
               create_synonym('C', 'IGS_UC_G_CVGCOURSE_2007',        'CVGCOURSE',           p_dblink_name, 'IGS_UC_CVGCOURSE_2007');

               -- 2006 Reference Data to HERCULES
               create_synonym('C', 'IGS_UC_G_CVGREFAMENDMENTS_2006', 'CVGREFAMENDMENTS',    p_dblink_name, 'IGS_UC_CVGREFAMENDMENTS_2006');
               create_synonym('C', 'IGS_UC_G_CVGNAME_2006',          'CVGNAME',             p_dblink_name, 'IGS_UC_CVNAME_2003');
               create_synonym('C', 'IGS_UC_G_CVGREFDEGREESUBJ_2006', 'CVGREFDEGREESUBJECT', p_dblink_name, 'IGS_UC_CVGREFDEGREESUBJ_2006');

               -- 2007 Application Data to HERCULES
               create_synonym('C', 'IGS_UC_G_IVGSTARA_2007',         'IVGSTARA',            p_dblink_name, 'IGS_UC_IVGSTARA_2007');
               create_synonym('C', 'IGS_UC_G_IVGSTARN_2007',         'IVGSTARN',            p_dblink_name, 'IGS_UC_IVGSTARN_2007');
               create_synonym('C', 'IGS_UC_G_IVGSTARK_2007',         'IVGSTARK',            p_dblink_name, 'IGS_UC_IVGSTARK_2007');
               create_synonym('C', 'IGS_UC_G_IVGSTARW_2007',         'IVGSTARW',            p_dblink_name, 'IGS_UC_IVGSTARW_2007');

               -- 2006 Application Data to HERCULES
               create_synonym('C', 'IGS_UC_G_IVGOFFER_2006',         'IVGOFFER',            p_dblink_name, 'IGS_UC_IVGOFFER_2006');
               create_synonym('C', 'IGS_UC_G_IVGREFERENCE_2006',     'IVGREFERENCE',        p_dblink_name, 'IGS_UC_IVGREFERENCE_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTARG_2006',         'IVGSTARG',            p_dblink_name, 'IGS_UC_IVGSTARG_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTARH_2006',         'IVGSTARH',            p_dblink_name, 'IGS_UC_IVGSTARH_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTARX_2006',         'IVGSTARX',            p_dblink_name, 'IGS_UC_IVGSTARX_2006');
               create_synonym('C', 'IGS_UC_G_IVGSTATEMENT_2006',     'IVGSTATEMENT',        p_dblink_name, 'IGS_UC_IVGSTATEMENT_2006');

               -- 2006 Application Data to DUMMY
               create_synonym('D', 'IGS_UC_G_IVGSTARA_2006',         'IVGSTARA',            p_dblink_name, 'IGS_UC_IVGSTARA_2006');
               create_synonym('D', 'IGS_UC_G_IVGSTARN_2006',         'IVGSTARN',            p_dblink_name, 'IGS_UC_IVGSTARN_2006');
               create_synonym('D', 'IGS_UC_G_IVGSTARK_2006',         'IVGSTARK',            p_dblink_name, 'IGS_UC_IVGSTARK_2006');
               create_synonym('D', 'IGS_UC_G_IVGSTARW_2006',         'IVGSTARW',            p_dblink_name, 'IGS_UC_IVGSTARW_2006');

            END IF;

        ELSE

               -- For MARVIN (or prior 2006) all GTTR Small System Synonyms pointing to DUMMY
               -- Reference Data
               create_synonym('D', 'IGS_UC_G_CVGREFAMENDMENTS_2006', 'CVGREFAMENDMENTS',    p_dblink_name, 'IGS_UC_CVGREFAMENDMENTS_2006');
               create_synonym('D', 'IGS_UC_G_CVGNAME_2006',          'CVGNAME',             p_dblink_name, 'IGS_UC_CVNAME_2003');
               create_synonym('D', 'IGS_UC_G_CVGREFDEGREESUBJ_2006', 'CVGREFDEGREESUBJECT', p_dblink_name, 'IGS_UC_CVGREFDEGREESUBJ_2006');

               -- 2006 Application Data
               create_synonym('D', 'IGS_UC_G_IVGOFFER_2006',         'IVGOFFER',            p_dblink_name, 'IGS_UC_IVGOFFER_2006');
               create_synonym('D', 'IGS_UC_G_IVGREFERENCE_2006',     'IVGREFERENCE',        p_dblink_name, 'IGS_UC_IVGREFERENCE_2006');
               create_synonym('D', 'IGS_UC_G_IVGSTARA_2006',         'IVGSTARA',            p_dblink_name, 'IGS_UC_IVGSTARA_2006');
               create_synonym('D', 'IGS_UC_G_IVGSTARG_2006',         'IVGSTARG',            p_dblink_name, 'IGS_UC_IVGSTARG_2006');
               create_synonym('D', 'IGS_UC_G_IVGSTARH_2006',         'IVGSTARH',            p_dblink_name, 'IGS_UC_IVGSTARH_2006');
               create_synonym('D', 'IGS_UC_G_IVGSTARK_2006',         'IVGSTARK',            p_dblink_name, 'IGS_UC_IVGSTARK_2006');
               create_synonym('D', 'IGS_UC_G_IVGSTARN_2006',         'IVGSTARN',            p_dblink_name, 'IGS_UC_IVGSTARN_2006');
               create_synonym('D', 'IGS_UC_G_IVGSTARW_2006',         'IVGSTARW',            p_dblink_name, 'IGS_UC_IVGSTARW_2006');
               create_synonym('D', 'IGS_UC_G_IVGSTARX_2006',         'IVGSTARX',            p_dblink_name, 'IGS_UC_IVGSTARX_2006');
               create_synonym('D', 'IGS_UC_G_IVGSTATEMENT_2006',     'IVGSTATEMENT',        p_dblink_name, 'IGS_UC_IVGSTATEMENT_2006');

               -- 2007 Reference Data
               create_synonym('D', 'IGS_UC_G_CVGCOURSE_2007',        'CVGCOURSE',           p_dblink_name, 'IGS_UC_CVGCOURSE_2007');

               -- 2007 Application Data
               create_synonym('D', 'IGS_UC_G_IVGSTARA_2007',         'IVGSTARA',            p_dblink_name, 'IGS_UC_IVGSTARA_2007');
               create_synonym('D', 'IGS_UC_G_IVGSTARN_2007',         'IVGSTARN',            p_dblink_name, 'IGS_UC_IVGSTARN_2007');
               create_synonym('D', 'IGS_UC_G_IVGSTARK_2007',         'IVGSTARK',            p_dblink_name, 'IGS_UC_IVGSTARK_2007');
               create_synonym('D', 'IGS_UC_G_IVGSTARW_2007',         'IVGSTARW',            p_dblink_name, 'IGS_UC_IVGSTARW_2007');

        END IF;


        -- Fetching 'NMAS_INTERFACE'
        OPEN  cur_ucas_interface (p_target_cycle,'N');
        FETCH cur_ucas_interface INTO l_nmas_interface;
        CLOSE cur_ucas_interface;

        -- APPLICATION RELATED TABLES/VIEWS
        -- NMAS synonyms for target cycle for applicant tables
        IF (l_nmas_interface = 'H' AND p_target_cycle >= 2006 ) THEN

            -- For 2006 - Synonyms in 2006 should point to  Hercules
            IF p_target_cycle = 2006 THEN

               -- NMAS Small System Synonyms specific for 2006 pointing to HERCULES
               -- 2006 Reference Data to HERCULES
               create_synonym('C', 'IGS_UC_N_CVNNAME_2006',          'CVNNAME',             p_dblink_name, 'IGS_UC_CVNAME_2003');

               -- 2006 Application Data to HERCULES
               create_synonym('C', 'IGS_UC_N_IVNOFFER_2006',         'IVNOFFER',            p_dblink_name, 'IGS_UC_IVNOFFER_2006');
               create_synonym('C', 'IGS_UC_N_IVNREFERENCE_2006',     'IVNREFERENCE',        p_dblink_name, 'IGS_UC_IVNREFERENCE_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARA_2006',         'IVNSTARA',            p_dblink_name, 'IGS_UC_IVNSTARA_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARC_2006',         'IVNSTARC',            p_dblink_name, 'IGS_UC_IVNSTARC_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARH_2006',         'IVNSTARH',            p_dblink_name, 'IGS_UC_IVNSTARH_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARK_2006',         'IVNSTARK',            p_dblink_name, 'IGS_UC_IVNSTARK_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARN_2006',         'IVNSTARN',            p_dblink_name, 'IGS_UC_IVNSTARN_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARW_2006',         'IVNSTARW',            p_dblink_name, 'IGS_UC_IVNSTARW_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARX_2006',         'IVNSTARX',            p_dblink_name, 'IGS_UC_IVNSTARX_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARZ1_2006',        'IVNSTARZ1',           p_dblink_name, 'IGS_UC_IVNSTARZ1_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTATEMENT_2006',     'IVNSTATEMENT',        p_dblink_name, 'IGS_UC_IVNSTATEMENT_2006');

               -- 2007 Reference Data to DUMMY
               create_synonym('D', 'IGS_UC_N_CVNCOURSE_2007',        'CVNCOURSE',           p_dblink_name, 'IGS_UC_CVNCOURSE_2007');

               -- 2007 Application Data to DUMMY
               create_synonym('D', 'IGS_UC_N_IVNSTARA_2007',         'IVNSTARA',            p_dblink_name, 'IGS_UC_IVNSTARA_2007');
               create_synonym('D', 'IGS_UC_N_IVNSTARN_2007',         'IVNSTARN',            p_dblink_name, 'IGS_UC_IVNSTARN_2007');
               create_synonym('D', 'IGS_UC_N_IVNSTARK_2007',         'IVNSTARK',            p_dblink_name, 'IGS_UC_IVNSTARK_2007');
               create_synonym('D', 'IGS_UC_N_IVNSTARW_2007',         'IVNSTARW',            p_dblink_name, 'IGS_UC_IVNSTARW_2007');

            ELSIF p_target_cycle = 2007 THEN

               -- 2007 Reference Data to HERCULES
               create_synonym('C', 'IGS_UC_N_CVNCOURSE_2007',        'CVNCOURSE',           p_dblink_name, 'IGS_UC_CVNCOURSE_2007');

               -- 2006 Reference Data to HERCULES
               create_synonym('C', 'IGS_UC_N_CVNNAME_2006',          'CVNNAME',             p_dblink_name, 'IGS_UC_CVNAME_2003');

               -- 2007 Application Data to HERCULES
               create_synonym('C', 'IGS_UC_N_IVNSTARA_2007',         'IVNSTARA',            p_dblink_name, 'IGS_UC_IVNSTARA_2007');
               create_synonym('C', 'IGS_UC_N_IVNSTARN_2007',         'IVNSTARN',            p_dblink_name, 'IGS_UC_IVNSTARN_2007');
               create_synonym('C', 'IGS_UC_N_IVNSTARK_2007',         'IVNSTARK',            p_dblink_name, 'IGS_UC_IVNSTARK_2007');
               create_synonym('C', 'IGS_UC_N_IVNSTARW_2007',         'IVNSTARW',            p_dblink_name, 'IGS_UC_IVNSTARW_2007');

               -- 2006 Application Data to HERCULES
               create_synonym('C', 'IGS_UC_N_IVNOFFER_2006',         'IVNOFFER',            p_dblink_name, 'IGS_UC_IVNOFFER_2006');
               create_synonym('C', 'IGS_UC_N_IVNREFERENCE_2006',     'IVNREFERENCE',        p_dblink_name, 'IGS_UC_IVNREFERENCE_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARC_2006',         'IVNSTARC',            p_dblink_name, 'IGS_UC_IVNSTARC_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARH_2006',         'IVNSTARH',            p_dblink_name, 'IGS_UC_IVNSTARH_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARX_2006',         'IVNSTARX',            p_dblink_name, 'IGS_UC_IVNSTARX_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTARZ1_2006',        'IVNSTARZ1',           p_dblink_name, 'IGS_UC_IVNSTARZ1_2006');
               create_synonym('C', 'IGS_UC_N_IVNSTATEMENT_2006',     'IVNSTATEMENT',        p_dblink_name, 'IGS_UC_IVNSTATEMENT_2006');

               -- 2006 Application Data to DUMMY
               create_synonym('D', 'IGS_UC_N_IVNSTARA_2006',         'IVNSTARA',            p_dblink_name, 'IGS_UC_IVNSTARA_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTARN_2006',         'IVNSTARN',            p_dblink_name, 'IGS_UC_IVNSTARN_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTARK_2006',         'IVNSTARK',            p_dblink_name, 'IGS_UC_IVNSTARK_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTARW_2006',         'IVNSTARW',            p_dblink_name, 'IGS_UC_IVNSTARW_2006');

            END IF;

        ELSE

               -- For MARVIN (or prior 2006) all NMAS Small System Synonyms pointing to DUMMY
               -- Reference Data
               create_synonym('D', 'IGS_UC_N_CVNNAME_2006',          'CVNNAME',             p_dblink_name, 'IGS_UC_CVNAME_2003');

               -- Application Data
               create_synonym('D', 'IGS_UC_N_IVNOFFER_2006',         'IVNOFFER',            p_dblink_name, 'IGS_UC_IVNOFFER_2006');
               create_synonym('D', 'IGS_UC_N_IVNREFERENCE_2006',     'IVNREFERENCE',        p_dblink_name, 'IGS_UC_IVNREFERENCE_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTARA_2006',         'IVNSTARA',            p_dblink_name, 'IGS_UC_IVNSTARA_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTARC_2006',         'IVNSTARC',            p_dblink_name, 'IGS_UC_IVNSTARC_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTARH_2006',         'IVNSTARH',            p_dblink_name, 'IGS_UC_IVNSTARH_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTARK_2006',         'IVNSTARK',            p_dblink_name, 'IGS_UC_IVNSTARK_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTARN_2006',         'IVNSTARN',            p_dblink_name, 'IGS_UC_IVNSTARN_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTARW_2006',         'IVNSTARW',            p_dblink_name, 'IGS_UC_IVNSTARW_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTARX_2006',         'IVNSTARX',            p_dblink_name, 'IGS_UC_IVNSTARX_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTARZ1_2006',        'IVNSTARZ1',           p_dblink_name, 'IGS_UC_IVNSTARZ1_2006');
               create_synonym('D', 'IGS_UC_N_IVNSTATEMENT_2006',     'IVNSTATEMENT',        p_dblink_name, 'IGS_UC_IVNSTATEMENT_2006');

               -- 2007 Reference Data
               create_synonym('D', 'IGS_UC_N_CVNCOURSE_2007',        'CVNCOURSE',           p_dblink_name, 'IGS_UC_CVNCOURSE_2007');

               -- 2007 Application Data
               create_synonym('D', 'IGS_UC_N_IVNSTARA_2007',         'IVNSTARA',            p_dblink_name, 'IGS_UC_IVNSTARA_2007');
               create_synonym('D', 'IGS_UC_N_IVNSTARN_2007',         'IVNSTARN',            p_dblink_name, 'IGS_UC_IVNSTARN_2007');
               create_synonym('D', 'IGS_UC_N_IVNSTARK_2007',         'IVNSTARK',            p_dblink_name, 'IGS_UC_IVNSTARK_2007');
               create_synonym('D', 'IGS_UC_N_IVNSTARW_2007',         'IVNSTARW',            p_dblink_name, 'IGS_UC_IVNSTARW_2007');

        END IF;

        -- If any synonyms failed to create, then set return code = warning
        IF g_synonym_fail THEN
           retcode := 1;
        END IF;

        -- Compile all Data Source Views
        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_CVCONTROL_2003_V COMPILE');
              log_msg('IGS_UC_CVCONTROL_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_CVCONTROL_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVOFFER_2003_V COMPILE');
              log_msg('IGS_UC_IVOFFER_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVOFFER_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVQUALIFICATION_2003_V COMPILE');
              log_msg('IGS_UC_IVQUALIFICATION_2003_V', 'O');
                EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVQUALIFICATION_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARA_2003_V COMPILE');
              log_msg('IGS_UC_IVSTARA_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARA_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARC_2003_V COMPILE');
              log_msg('IGS_UC_IVSTARC_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARC_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARH_2003_V COMPILE');
              log_msg('IGS_UC_IVSTARH_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARH_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARJ_2004_V COMPILE');
              log_msg('IGS_UC_IVSTARJ_2004_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARJ_2004_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARK_2003_V COMPILE');
              log_msg('IGS_UC_IVSTARK_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARK_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARN_2003_V COMPILE');
              log_msg('IGS_UC_IVSTARN_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARN_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARPQR_2003_V COMPILE');
              log_msg('IGS_UC_IVSTARPQR_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARPQR_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARW_2003_V COMPILE');
              log_msg('IGS_UC_IVSTARW_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARW_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARX_2003_V COMPILE');
              log_msg('IGS_UC_IVSTARX_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARX_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARZ1_2003_V COMPILE');
              log_msg('IGS_UC_IVSTARZ1_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARZ1_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARZ2_2003_V COMPILE');
              log_msg('IGS_UC_IVSTARZ2_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARZ2_2003_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTATEMENT_2003_V COMPILE');
              log_msg('IGS_UC_IVSTATEMENT_2003_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTATEMENT_2003_V', 'I');
        END;

        -- smaddali added new view IGS_UC_IVSTATEMENT_2004_V for bug#3098810
        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTATEMENT_2004_V COMPILE');
              log_msg('IGS_UC_IVSTATEMENT_2004_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTATEMENT_2004_V', 'I');
        END;


        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVFORMQUALS_2004_V COMPILE');
              log_msg('IGS_UC_IVFORMQUALS_2004_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVFORMQUALS_2004_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVREFERENCE_2004_V COMPILE');
              log_msg('IGS_UC_IVREFERENCE_2004_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVREFERENCE_2004_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVREFERENCE_2006_V COMPILE');
              log_msg('IGS_UC_IVREFERENCE_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVREFERENCE_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARA_2006_V COMPILE');
              log_msg('IGS_UC_IVSTARA_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARA_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVFORMQUALS_2006_V COMPILE');
              log_msg('IGS_UC_IVFORMQUALS_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVFORMQUALS_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARA_2007_V COMPILE');
              log_msg('IGS_UC_IVSTARA_2007_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARA_2007_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARN_2007_V COMPILE');
              log_msg('IGS_UC_IVSTARN_2007_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARN_2007_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVSTARK_2007_V COMPILE');
              log_msg('IGS_UC_IVSTARK_2007_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVSTARK_2007_V', 'I');
        END;

        -- Small System 2006 Views
        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGOFFER_2006_V COMPILE');
              log_msg('IGS_UC_IVGOFFER_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGOFFER_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNOFFER_2006_V COMPILE');
              log_msg('IGS_UC_IVNOFFER_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNOFFER_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTARA_2006_V COMPILE');
              log_msg('IGS_UC_IVGSTARA_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTARA_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARA_2006_V COMPILE');
              log_msg('IGS_UC_IVNSTARA_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARA_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARC_2006_V COMPILE');
              log_msg('IGS_UC_IVNSTARC_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARC_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTARG_2006_V COMPILE');
              log_msg('IGS_UC_IVGSTARG_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTARG_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTARH_2006_V COMPILE');
              log_msg('IGS_UC_IVGSTARH_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTARH_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARH_2006_V COMPILE');
              log_msg('IGS_UC_IVNSTARH_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARH_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTARK_2006_V COMPILE');
              log_msg('IGS_UC_IVGSTARK_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTARK_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARK_2006_V COMPILE');
              log_msg('IGS_UC_IVNSTARK_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARK_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTARN_2006_V COMPILE');
              log_msg('IGS_UC_IVGSTARN_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTARN_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARN_2006_V COMPILE');
              log_msg('IGS_UC_IVNSTARN_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARN_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTARW_2006_V COMPILE');
              log_msg('IGS_UC_IVGSTARW_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTARW_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARW_2006_V COMPILE');
              log_msg('IGS_UC_IVNSTARW_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARW_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTARX_2006_V COMPILE');
              log_msg('IGS_UC_IVGSTARX_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTARX_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARX_2006_V COMPILE');
              log_msg('IGS_UC_IVNSTARX_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARX_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARZ1_2006_V COMPILE');
              log_msg('IGS_UC_IVNSTARZ1_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARZ1_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTATEMENT_2006_V COMPILE');
              log_msg('IGS_UC_IVGSTATEMENT_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTATEMENT_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTATEMENT_2006_V COMPILE');
              log_msg('IGS_UC_IVNSTATEMENT_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTATEMENT_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGREFERENCE_2006_V COMPILE');
              log_msg('IGS_UC_IVGREFERENCE_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGREFERENCE_2006_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNREFERENCE_2006_V COMPILE');
              log_msg('IGS_UC_IVNREFERENCE_2006_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNREFERENCE_2006_V', 'I');
        END;

        -- Small System 2007 views
        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTARA_2007_V COMPILE');
              log_msg('IGS_UC_IVGSTARA_2007_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTARA_2007_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARA_2007_V COMPILE');
              log_msg('IGS_UC_IVNSTARA_2007_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARA_2007_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTARN_2007_V COMPILE');
              log_msg('IGS_UC_IVGSTARN_2007_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTARN_2007_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARN_2007_V COMPILE');
              log_msg('IGS_UC_IVNSTARN_2007_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARN_2007_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTARK_2007_V COMPILE');
              log_msg('IGS_UC_IVGSTARK_2007_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTARK_2007_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARK_2007_V COMPILE');
              log_msg('IGS_UC_IVNSTARK_2007_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARK_2007_V', 'I');
        END;


        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVGSTARW_2007_V COMPILE');
              log_msg('IGS_UC_IVGSTARW_2007_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVGSTARW_2007_V', 'I');
        END;

        BEGIN
              apps_ddl.apps_ddl('ALTER VIEW IGS_UC_IVNSTARW_2007_V COMPILE');
              log_msg('IGS_UC_IVNSTARW_2007_V', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_IVNSTARW_2007_V', 'I');
        END;

        -- Compile all database packages (body)
        BEGIN
             apps_ddl.apps_ddl('ALTER PACKAGE IGS_UC_LOAD_HERCULES_DATA COMPILE BODY');
             -- Log message for compiling packages
             log_msg('IGS_UC_LOAD_HERCULES_DATA', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_LOAD_HERCULES_DATA', 'I');
        END;

        BEGIN
             apps_ddl.apps_ddl('ALTER PACKAGE IGS_UC_EXT_MARVIN COMPILE BODY');
             -- Log message for compiling packages
             log_msg('IGS_UC_EXT_MARVIN', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_EXT_MARVIN', 'I');
        END;

        BEGIN
             apps_ddl.apps_ddl('ALTER PACKAGE IGS_UC_MV_DATA_UPLD COMPILE BODY');
             -- Log message for compiling packages
             log_msg('IGS_UC_MV_DATA_UPLD', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_MV_DATA_UPLD', 'I');
        END;

        BEGIN
             apps_ddl.apps_ddl('ALTER PACKAGE IGS_UC_EXPORT_UCAS_PKG COMPILE BODY');
             -- Log message for compiling packages
             log_msg('IGS_UC_EXPORT_UCAS_PKG', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_EXPORT_UCAS_PKG', 'I');
        END;

        BEGIN
             apps_ddl.apps_ddl('ALTER PACKAGE IGS_UC_TRAN_PROCESSOR_PKG COMPILE BODY');
             -- Log message for compiling packages
             log_msg('IGS_UC_TRAN_PROCESSOR_PKG', 'O');
        EXCEPTION
        WHEN OTHERS THEN
             retcode := 1 ;
             log_msg('IGS_UC_TRAN_PROCESSOR_PKG', 'I');
        END;

            -- Compile the gen 001 package
        BEGIN
             apps_ddl.apps_ddl('ALTER PACKAGE IGS_UC_GEN_001 COMPILE BODY');
             log_msg('IGS_UC_GEN_001', 'O');
          EXCEPTION
          WHEN OTHERS THEN
               retcode := 1 ;
               log_msg('IGS_UC_GEN_001', 'I');
        END;

        --Bug No: 3083664. Package IGS_UC_PROC_COM_INST_DATA included for compilation
        BEGIN
             apps_ddl.apps_ddl('ALTER PACKAGE IGS_UC_PROC_COM_INST_DATA COMPILE BODY');
             log_msg('IGS_UC_PROC_COM_INST_DATA', 'O');
          EXCEPTION
          WHEN OTHERS THEN
               retcode := 1 ;
               log_msg('IGS_UC_PROC_COM_INST_DATA', 'I');
        END;


        -- Update 'configured cycle' to 'target cycle'
        FOR rec_cur_defaults IN cur_uc_defaults_data
        LOOP
          igs_uc_defaults_pkg.update_row( x_rowid                        => rec_cur_defaults.rowid,
                                          x_current_inst_code            => rec_cur_defaults.current_inst_code,
                                          x_ucas_id_format               => rec_cur_defaults.ucas_id_format,
                                          x_test_app_no                  => rec_cur_defaults.test_app_no,
                                          x_test_choice_no               => rec_cur_defaults.test_choice_no,
                                          x_test_transaction_type        => rec_cur_defaults.test_transaction_type,
                                          x_copy_ucas_id                 => rec_cur_defaults.copy_ucas_id,
                                          x_mode                         => 'R',
                                          x_decision_make_id             => rec_cur_defaults.decision_make_id,
                                          x_decision_reason_id           => rec_cur_defaults.decision_reason_id,
                                          x_obsolete_outcome_status      => rec_cur_defaults.obsolete_outcome_status,
                                          x_pending_outcome_status       => rec_cur_defaults.pending_outcome_status,
                                          x_rejected_outcome_status      => rec_cur_defaults.rejected_outcome_status,
                                          x_system_code                  => rec_cur_defaults.system_code,
                                          x_ni_number_alt_pers_type      => rec_cur_defaults.ni_number_alt_pers_type,
                                          x_application_type             => rec_cur_defaults.application_type,
                                          x_name                         => rec_cur_defaults.name,
                                          x_description                  => rec_cur_defaults.description,
                                          x_ucas_security_key            => rec_cur_defaults.ucas_security_key,
                                          x_current_cycle                => rec_cur_defaults.current_cycle,
                                          x_configured_cycle             => p_target_cycle,
                                          x_prev_inst_left_date          => rec_cur_defaults.prev_inst_left_date
                                       );
        END LOOP;

        EXCEPTION
        WHEN OTHERS THEN
             fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
             fnd_message.set_token('NAME','IGS_UC_CONFIG_CYCLE.conf_system_for_ucas_cycle');
             fnd_file.put_line(fnd_file.log, fnd_message.get);
             fnd_file.put_line(fnd_file.log, 'Exception ' || sqlerrm);
             errbuf  := fnd_message.get ;
             retcode := 2;

             IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

   END conf_system_for_ucas_cycle;

END igs_uc_config_cycle;

/
