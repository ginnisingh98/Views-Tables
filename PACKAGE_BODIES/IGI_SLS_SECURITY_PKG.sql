--------------------------------------------------------
--  DDL for Package Body IGI_SLS_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_SLS_SECURITY_PKG" AS
-- $Header: igislsdb.pls 120.12.12010000.2 2008/08/04 13:07:01 sasukuma ship $

   l_debug_level NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
   l_path        VARCHAR2(50)  := 'IGI.PLSQL.igislsdb.igi_sls_security_pkg.';


  /*-----------------------------------------------------------------
  This procedure writes to the error log.
  -----------------------------------------------------------------*/
  /* PROCEDURE Write_To_Log ( p_message      IN VARCHAR2) IS
   BEGIN
      FND_FILE.put_line( FND_FILE.log, p_message );
   END Write_To_Log;*/


  /*-----------------------------------------------------------------
  This procedure writes to the error log.
  -----------------------------------------------------------------*/
   PROCEDURE Write_To_Log (p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2) IS
   BEGIN
	IF (p_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (p_level , l_path || p_path , p_mesg );
        END IF;
   END Write_To_Log;


   /*------------------------------------------------------------------
  This procedure returns the SCHEMA name, which in most cases will be
  APPS. Created for bug 1933950 by Bidisha on 29 Aug 2001
   ------------------------------------------------------------------*/
   PROCEDURE get_schema_name (p_schema_name      IN OUT NOCOPY VARCHAR2,
                             errbuf             IN OUT NOCOPY VARCHAR2,
                             retcode            IN OUT NOCOPY NUMBER)
   IS
   CURSOR c_sch_name (p_resp_id    NUMBER) IS
          SELECT oracle_username
          FROM   fnd_data_group_units_v dgrp,
                 fnd_responsibility     resp
          WHERE  dgrp.application_id    =  resp.application_id
          AND    dgrp.data_group_id     =  resp.data_group_id
          AND    resp.responsibility_id = p_resp_id;

   l_resp_id   NUMBER;
   BEGIN

      Fnd_Profile.Get('RESP_ID', l_resp_id);

      OPEN c_sch_name (l_resp_id);
      FETCH c_sch_name INTO p_schema_name;
      CLOSE c_sch_name;

      IF p_schema_name IS NULL
      THEN
          errbuf  := NULL;
          retcode := 2;
          write_to_log (l_event_level, 'get_schema_name','END  Procedure get_schema_name - failed. Schema name null' );
          Raise_Application_Error (-20000,
                              'Procedure get_schema_name - failed. Schema name null' );
      END IF;


   EXCEPTION
   WHEN OTHERS THEN

	     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
             retcode := 2;
             errbuf :=  Fnd_message.get;

             write_to_log ( l_excep_level, 'get_schema_name','END  Procedure get_schema_name - failed with error '|| SQLERRM );
             RETURN;

   END get_schema_name;

   /*------------------------------------------------------------------
   This proecdure gets the schema names for the Multilingual and
   Multi currency application

   Its is called from procedure IGI_SLS_SECURITY_PKG.APPLY_SECURITY only.
   ------------------------------------------------------------------*/
   PROCEDURE get_mrc_mls_schemanames  (p_mls_schema_name  IN OUT NOCOPY VARCHAR2,
                                       p_mrc_schema_name  IN OUT NOCOPY VARCHAR2,
                                       errbuf             IN OUT NOCOPY VARCHAR2,
                                       retcode            IN OUT NOCOPY NUMBER)
   IS

   CURSOR c_get_install_num  IS
          SELECT install_group_num
          FROM   fnd_oracle_userid
          WHERE  read_only_flag = 'U'
          ORDER BY install_group_num;

   CURSOR c_get_flag  IS
          SELECT NVL(multi_currency_flag, 'N') multi_currency_flag,
                 NVL(multi_lingual_flag, 'N')  multi_lingual_flag
          FROM   fnd_product_groups;

   CURSOR c_get_schema_name (p_install_group_num           NUMBER,
                             p_read_only_flag              VARCHAR2) IS
          SELECT oracle_username
          FROM   fnd_oracle_userid
          WHERE  (install_group_num = p_install_group_num
          OR     install_group_num  = (SELECT MIN (install_group_num)
                                       FROM   fnd_oracle_userid
                                       WHERE  1=DECODE(p_install_group_num,0,1,2)
                                       AND    read_only_flag = p_read_only_flag))
          AND    read_only_flag     = p_read_only_flag;

    CURSOR c_chk_install (p_schema_name    IN VARCHAR2)  IS
          SELECT COUNT(*)
          FROM   dba_objects
          WHERE  object_type IN ('PACKAGE', 'PACKAGE BODY')
          AND    object_name IN ('APPS_DDL', 'APPS_ARRAY_DDL')
          AND    status = 'VALID'
          AND    owner  = UPPER (p_schema_name);

   l_install_group_num         NUMBER := 1;
   l_count                     NUMBER := 0;
   l_multi_currency_flag       VARCHAR2(1);
   l_multi_lingual_flag        VARCHAR2(1);

   BEGIN

      p_mls_schema_name := NULL;
      p_mrc_schema_name := NULL;

      write_to_log (l_state_level, 'get_mrc_mls_schemanames', 'Get_Mrc_Mls_Schemanames, Checking if multi currency and lingual flags are set');
      -- Check if Multi Currency , Multi Lingual flag is on.
      OPEN  c_get_flag;
      FETCH c_get_flag INTO   l_multi_currency_flag,
                              l_multi_lingual_flag;
      CLOSE c_get_flag;

      -- Get the installation number.
      write_to_log ( l_state_level, 'get_mrc_mls_schemanames','Get_Mrc_Mls_Schemanames, Fetching the installation group number');
      OPEN  c_get_install_num;
      FETCH c_get_install_num INTO l_install_group_num;
      CLOSE c_get_install_num;


      IF l_multi_lingual_flag = 'Y'
      THEN
           -- If multilingual flag is set , get the MLS Schema name.
          write_to_log ( l_state_level, 'get_mrc_mls_schemanames','Get_Mrc_Mls_Schemanames, Getting the MLS Schema Name');
          OPEN  c_get_schema_name (l_install_group_num,
                                   'M');
          FETCH c_get_schema_name INTO p_mls_schema_name;
          CLOSE c_get_schema_name;

          -- Bug 5144650 .. Start
          IF p_mls_schema_name is not null THEN
          -- Bug 5144650 .. End
             -- Check if it has installed properly
             write_to_log (l_state_level, 'get_mrc_mls_schemanames', 'Get_Mrc_Mls_Schemanames, Checking if MLS Schema Name has been installed' );
             OPEN  c_chk_install (p_mls_schema_name);
             FETCH c_chk_install INTO l_count;
             CLOSE c_chk_install ;

             IF l_count <> 4 THEN
                errbuf  := NULL;
                retcode := 2;
                write_to_log (l_state_level, 'get_mrc_mls_schemanames','APPS_DDL / APPS_ARRAY_DDL package(s) missing or invalid in '|| p_mls_schema_name);
                Raise_Application_Error (-20000,
                                       'APPS_DDL / APPS_ARRAY_DDL package(s) missing or invalid in '||
                                       p_mls_schema_name);
             END IF;
          -- Bug 5144650 .. Start
          END IF;
          -- Bug 5144650 .. End
      END IF; -- Multi lingual flag is set

      IF l_multi_currency_flag = 'Y'
      THEN
           -- iF MULticurrency flag is set , get the MRC Schema name.
          write_to_log ( l_state_level, 'get_mrc_mls_schemanames','Get_Mrc_Mls_Schemanames, Getting the MRC Schema Name');
          OPEN  c_get_schema_name (l_install_group_num,
                                   'K');
          FETCH c_get_schema_name INTO p_mrc_schema_name;
          CLOSE c_get_schema_name;

          -- Bug 5144650 .. Start
          IF p_mrc_schema_name is not null THEN
          -- Bug 5144650 .. End
             -- Check if it has installed properly
             l_count := 0;

             write_to_log (l_state_level, 'get_mrc_mls_schemanames','Get_Mrc_Mls_Schemanames, Checking if MRC Schema Name has been installed' );
             OPEN  c_chk_install (p_mrc_schema_name);
             FETCH c_chk_install INTO l_count;
             CLOSE c_chk_install ;

             IF l_count <> 4 THEN
                errbuf  := NULL;
                retcode := 2;
                write_to_log (l_state_level, 'get_mrc_mls_schemanames','APPS_DDL / APPS_ARRAY_DDL package(s) missing or invalid in '|| p_mrc_schema_name);
                Raise_Application_Error (-20000,
                                       'APPS_DDL / APPS_ARRAY_DDL package(s) missing or invalid in '||
                                       p_mrc_schema_name);
             END IF;
          -- Bug 5144650 .. Start
          END IF;
          -- Bug 5144650 .. End
      END IF; -- Multi lingual flag is set

   EXCEPTION
   WHEN OTHERS THEN

             FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
             retcode := 2;
             errbuf :=  Fnd_message.get;
             write_to_log (l_excep_level, 'get_mrc_mls_schemanames', 'END  Procedure Apply Security - failed with error '|| SQLERRM );
             RETURN;

   END get_mrc_mls_schemanames;

   /*------------------------------------------------------------------
   This function checks if allocations exist for the table

   Its is called from procedure IGI_SLS_SECURITY_PKG.APPLY_SECURITY only.
   ------------------------------------------------------------------*/
   FUNCTION check_allocation_exists ( p_table_name  IN  igi_sls_secure_tables.table_name%TYPE)
            RETURN BOOLEAN
   IS

   l_count             NUMBER := 0;

   BEGIN

      -- Check if table is directly allocated to a Security Group
      SELECT COUNT(*)
      INTO   l_count
      FROM   igi_sls_allocations
      WHERE  sls_allocation       = p_table_name
      AND    sls_allocation_type  = 'T'
      AND    sls_group_type       = 'S'
      AND    date_disabled    IS NULL
      AND    date_removed     IS NULL;

      IF l_count = 0
      THEN
          -- Check if table is indirectly allocated to a Security Group
          SELECT COUNT(*)
          INTO   l_count
          FROM   igi_sls_allocations a,
                 igi_sls_allocations b
          WHERE  a.sls_group_type      = 'S'
          AND    a.sls_allocation      = b.sls_group
          AND    a.sls_allocation_type = 'P'
          AND    a.date_disabled    IS NULL
          AND    a.date_removed     IS NULL
          AND    b.sls_group_type      = 'P'
          AND    b.sls_allocation      = p_table_name
          AND    b.sls_allocation_type = 'T'
          AND    b.date_disabled    IS NULL
          AND    b.date_removed     IS NULL;

          IF l_count = 0
          THEN
              write_to_log (l_state_level, 'check_allocation_exists', 'Table '||p_table_name ||
                             ' is not allocated to any group or the allocation is not enabled');
              RETURN FALSE;
          ELSE
              RETURN TRUE;
          END IF;
      ELSE
          RETURN TRUE;
      END IF;

   EXCEPTION
   WHEN OTHERS
   THEN
        write_to_log (l_excep_level, 'check_allocation_exists', 'END  Procedure Apply Security - failed with error '|| SQLERRM );

        IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,l_path || 'check_allocation_exists' , TRUE);
        END IF;
        Raise_Application_Error (-20000,
                                 'Error encountered in check_allocation_exists');
   END check_allocation_exists;


   /*------------------------------------------------------------------
   This proecdure creates , disables, drops the sls objects depending
   on their status in the igi_sls_secure_tables.

   Its is called from procedure IGI_SLS_SECURITY_PKG.APPLY_SECURITY only.
   ------------------------------------------------------------------*/
   PROCEDURE create_drop_sls_objects ( p_mls_schema_name  IN     VARCHAR2,
                                       p_mrc_schema_name  IN     VARCHAR2,
                                       errbuf             IN OUT NOCOPY VARCHAR2,
                                       retcode            IN OUT NOCOPY NUMBER)
   IS
   CURSOR c_get_sectab IS
          SELECT  owner,
                  table_name,
                  sls_table_name,
                  date_enabled,
                  date_disabled,
                  date_removed,
                  date_security_applied,
                  date_object_created,
                  update_allowed,
                  NVL(optimise_sql,'N') optimise_sql
          FROM    igi_sls_secure_tables
          WHERE   date_security_applied IS NULL;

   rt_c_get_sectab          c_get_sectab%ROWTYPE;

   l_table_count           NUMBER := 0;
   l_policy_type           VARCHAR2(50);
   l_policy_function       VARCHAR2(50);
   l_policy_name           VARCHAR2(50);
   l_schema_name           VARCHAR2(50);

   l_date_security_applied DATE ;

   BEGIN

       retcode := 0;
       errbuf  := 'Normal Completion';

       get_schema_name (p_schema_name     => l_schema_name,
                        errbuf            => errbuf,
                        retcode           => retcode);

       FOR rt_c_get_sectab IN c_get_sectab
       LOOP

           write_to_log (l_state_level, 'create_drop_sls_objects', 'Create_Drop_SLS_Objects, Processing Table ' || rt_c_get_sectab.table_name);

           l_policy_function := rt_c_get_sectab.sls_table_name||'_FUN';
           l_policy_name     := rt_c_get_sectab.sls_table_name||'_POL';

           IF rt_c_get_sectab.update_allowed = 'Y'
           THEN
               l_policy_type := 'SELECT,UPDATE';
           ELSE
               l_policy_type := 'SELECT';
           END IF;

           l_date_security_applied := NULL;

           -- Security has been enabled, objects have not been created.
           IF   rt_c_get_sectab.date_object_created IS NULL
           AND  rt_c_get_sectab.date_disabled IS NULL
           AND  rt_c_get_sectab.date_removed  IS NULL
           AND  check_allocation_exists (rt_c_get_sectab.table_name)
           THEN
               IF rt_c_get_sectab.optimise_sql = 'N'
               THEN
                   -- Call Procedure to create SLS Table
                   write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Creating SLS Table ' ||
                                   rt_c_get_sectab.sls_table_name);

                   igi_sls_objects_pkg.create_sls_tab
                          (sls_tab                  => rt_c_get_sectab.sls_table_name,
                           schema_name              => l_schema_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

               ELSE
                   -- Call Procedure to create SLS Colmn
                   write_to_log (l_state_level, 'create_drop_sls_objects', 'Create_Drop_SLS_Objects, Creating SLS Col ');

                   igi_sls_objects_pkg.create_sls_col
                         (sec_tab                   => rt_c_get_sectab.table_name,
                          schema_name               => rt_c_get_sectab.owner,
                          errbuf                   => errbuf,
                          retcode                  => retcode);

               END IF;

               IF  retcode = 0
               THEN
                   IF rt_c_get_sectab.optimise_sql = 'N'
                   THEN
                       -- Call Procedure to create SLS Table
                        write_to_log (l_state_level, 'create_drop_sls_objects', 'Create_Drop_SLS_Objects, Creating index for SLS Table ' ||
                                   rt_c_get_sectab.sls_table_name);

                       igi_sls_objects_pkg.create_sls_inx
                          (sls_tab                  => rt_c_get_sectab.sls_table_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

                  ELSE
                      igi_sls_objects_pkg.create_sls_core_inx
                       (sec_tab         => rt_c_get_sectab.table_name,
                        sls_tab         => rt_c_get_sectab.sls_table_name,
                        schema_name     => rt_c_get_sectab.owner,
                        errbuf          => errbuf,
                        retcode         => retcode);
                  END IF;
               END IF;

               IF  retcode = 0
               AND  rt_c_get_sectab.optimise_sql = 'N'
               THEN
                    write_to_log ( l_state_level, 'create_drop_sls_objects', 'Create_Drop_SLS_Objects, Creating synonym for SLS Table ' ||
                                   rt_c_get_sectab.sls_table_name );

                   igi_sls_objects_pkg.create_sls_apps_syn
                          (sls_tab                  => rt_c_get_sectab.sls_table_name,
                           schema_name              => l_schema_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

               END IF;

/* Commented out NOCOPY MRC, MLS related code as per Atuls instructions - 29 Sep 2000.
               IF  retcode = 0
               AND p_mls_schema_name IS NOT NULL
               THEN
                    write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Creating synonym for SLS Table ' ||
                                   rt_c_get_sectab.sls_table_name || ' in '|| p_mls_schema_name);

                   igi_sls_objects_pkg.create_sls_mls_syn
                          (sls_tab                  => rt_c_get_sectab.sls_table_name,
                           mls_schemaname           => p_mls_schema_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

               END IF;

               IF  retcode = 0
               AND p_mrc_schema_name IS NOT NULL
               THEN
                    write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Creating synonym for SLS Table ' ||
                                   rt_c_get_sectab.sls_table_name || ' in '|| p_mrc_schema_name);

                   igi_sls_objects_pkg.create_sls_mrc_syn
                          (sls_tab                  => rt_c_get_sectab.sls_table_name,
                           mrc_schemaname           => p_mrc_schema_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

               END IF;
*/

               IF retcode = 0
               THEN
                   -- Call Procedure to create Database Trigger
                   write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Creating trigger '||
                                   rt_c_get_sectab.sls_table_name||'_TRG' ||
                                  ' on table ' || rt_c_get_sectab.table_name);

                   IF rt_c_get_sectab.optimise_sql = 'N'
                   THEN
                       write_to_log(l_state_level, 'create_drop_sls_objects', 'New table created, Please run Maintain APPS_MRC,APPS_MLS,if any, and any other customer schema');
                       -- Call Procedure to create SLS Table
                       igi_sls_objects_pkg.create_sls_trg
                          (sls_tab                  => rt_c_get_sectab.sls_table_name,
                           sec_tab                  => rt_c_get_sectab.table_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

                   ELSE
                       igi_sls_objects_pkg.create_sls_col_trg
                          (sls_tab                  => rt_c_get_sectab.sls_table_name,
                           sec_tab                  => rt_c_get_sectab.table_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);
                   END IF;

               END IF;

               IF retcode = 0
               THEN
                   -- Call Procedure to create Policy Function
                   write_to_log (l_state_level, 'create_drop_sls_objects', 'Create_Drop_SLS_Objects, Creating policy function  ' ||l_policy_function);

                   IF rt_c_get_sectab.optimise_sql = 'N'
                   THEN
                       -- Call Procedure to create SLS Table
                       igi_sls_objects_pkg.cre_pol_function
                          (sec_tab                  => rt_c_get_sectab.table_name,
                           sls_tab                  => rt_c_get_sectab.sls_table_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);
                   ELSE
                       igi_sls_objects_pkg.cre_ext_col_pol_func
                          (sec_tab                  => rt_c_get_sectab.table_name,
                           sls_tab                  => rt_c_get_sectab.sls_table_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

                   END IF;


               END IF;

               IF retcode = 0
               THEN
                   write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Creating policy'||
                                  ' on table ' || rt_c_get_sectab.table_name);

                   -- Call Procedure to create Policy
                   igi_sls_objects_pkg.sls_add_pol
                          (object_schema            => rt_c_get_sectab.owner,
                           table_name               => rt_c_get_sectab.table_name,
                           policy_name              => l_policy_name,
                           function_owner           => l_schema_name,
                           policy_function          => l_policy_function,
                           statement_types          => l_policy_type,
                           errbuf                   => errbuf,
                           retcode                  => retcode);
               END IF;

               IF retcode = 0
               THEN
                   write_to_log ( l_state_level, 'create_drop_sls_objects', 'Create_Drop_SLS_Objects, All objects created successfully for '||
                                  rt_c_get_sectab.table_name ||' updating igi_sls_secure_tables');

                   UPDATE igi_sls_secure_tables
                   SET    date_object_created   = SYSDATE,
                          last_update_login     = to_number(fnd_profile.value('LOGIN_ID')),
                          last_update_date      = SYSDATE,
                          last_updated_by       = to_number(fnd_profile.value('USER_ID'))
               WHERE    table_name = rt_c_get_sectab.table_name
               AND      owner      = rt_c_get_sectab.owner;

                   l_date_security_applied := SYSDATE;
               END IF;

               -- End of processing for New table defined and is enabled

           ELSIF rt_c_get_sectab.date_object_created IS NOT NULL
           AND   rt_c_get_sectab.date_removed  IS NULL
           AND   rt_c_get_sectab.date_disabled IS NULL
           THEN
               -- We need to drop and recreate the policy just in case user has changed the
               -- update_allowed flag
               IF retcode = 0
               THEN
                   -- CALL Procedure to drop Policy
                   write_to_log (l_state_level, 'create_drop_sls_objects', 'Create_Drop_SLS_Objects, Dropping policy '||l_policy_name);
                   igi_sls_objects_pkg.sls_drop_pol
                          (object_schema            => rt_c_get_sectab.owner,
                           table_name               => rt_c_get_sectab.table_name,
                           policy_name              => l_policy_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);
               END IF;

               IF retcode = 0
               THEN
                   write_to_log (l_state_level, 'create_drop_sls_objects',  'Refresh_SLS_Objects, Creating policy ' ||l_policy_name ||
                                  ' on table ' || rt_c_get_sectab.table_name);

                   -- Call Procedure to create Policy
                   igi_sls_objects_pkg.sls_add_pol
                          (object_schema            => rt_c_get_sectab.owner,
                           table_name               => rt_c_get_sectab.table_name,
                           policy_name              => l_policy_name,
                           function_owner           => l_schema_name,
                           policy_function          => l_policy_function,
                           statement_types          => l_policy_type,
                           errbuf                   => errbuf,
                           retcode                  => retcode);
               END IF;

               IF retcode = 0
               THEN
                   l_date_security_applied := SYSDATE;
               END IF;
               -- End of Processing for Re Enabled

           ELSIF rt_c_get_sectab.date_object_created IS NOT NULL
           AND   rt_c_get_sectab.date_disabled IS NOT NULL
           AND   rt_c_get_sectab.date_removed  IS NULL
           THEN
               -- Security has been disabled
               write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Disabling policy '||l_policy_name);
               igi_sls_objects_pkg.sls_disable_pol
                          (object_schema            => rt_c_get_sectab.owner,
                           table_name               => rt_c_get_sectab.table_name,
                           policy_name              => l_policy_name,
                           enable                   => FALSE,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

               IF retcode = 0
               THEN
                   l_date_security_applied := SYSDATE;
               END IF;

               -- End of Processing for Disabled

           ELSIF rt_c_get_sectab.date_object_created IS NOT NULL
           AND   rt_c_get_sectab.date_removed IS NOT NULL
           THEN
               -- Security has been deleted
               write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Dropping policy '||l_policy_name);

               igi_sls_objects_pkg.sls_drop_pol
                          (object_schema            => rt_c_get_sectab.owner,
                           table_name               => rt_c_get_sectab.table_name,
                           policy_name              => l_policy_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

               IF retcode = 0
               THEN
                   -- CALL Procedure to drop Policy Function
                   write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Dropping policy function '||l_policy_function);

                   igi_sls_objects_pkg.drop_pol_function
                          (sls_tab            => rt_c_get_sectab.sls_table_name,
                           errbuf             => errbuf,
                           retcode            => retcode);

               END IF;

               IF retcode = 0
               THEN
                   -- CALL Procedure to drop DB Trigger
                   write_to_log ( l_state_level, 'create_drop_sls_objects', 'Create_Drop_SLS_Objects, Dropping trigger on table '||
                                  rt_c_get_sectab.table_name);
                   igi_sls_objects_pkg.drop_sls_trg
                          (sls_tab            => rt_c_get_sectab.sls_table_name,
                           errbuf             => errbuf,
                           retcode            => retcode);
               END IF;

               IF retcode = 0
               THEN
                   IF rt_c_get_sectab.optimise_sql = 'N'
                   THEN
                       -- CALL Procedure to drop SLS Table
                       write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Dropping table '||
                                      rt_c_get_sectab.sls_table_name);
                       igi_sls_objects_pkg.drop_sls_tab
                          (sls_tab            => rt_c_get_sectab.sls_table_name,
                           errbuf             => errbuf,
                           retcode            => retcode);

                   ELSE
                     igi_sls_objects_pkg.drop_sls_col
                       (sec_tab         => rt_c_get_sectab.table_name,
                        schema_name     => rt_c_get_sectab.owner,
                        errbuf             => errbuf,
                        retcode            => retcode);

                     -- The table should also be dropped.
                     igi_sls_objects_pkg.drop_sls_tab
                          (sls_tab            => rt_c_get_sectab.sls_table_name,
                           errbuf             => errbuf,
                           retcode            => retcode);

                   END IF;

               END IF;

               IF retcode = 0
               THEN
                   -- Drop the synonym even though the optimise sql = 'Y'
                   -- CALL Procedure to drop SLS APPS Synonyms
                   write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Dropping synonym table '||
                                  rt_c_get_sectab.sls_table_name  );
                   igi_sls_objects_pkg.drop_sls_apps_syn
                          (sls_tab            => rt_c_get_sectab.sls_table_name,
                           schema_name        => l_schema_name,
                           errbuf             => errbuf,
                           retcode            => retcode);
               END IF;

/* Commented out NOCOPY MRC, MLS code as per Atuls, instructions. 29-Sep-2000.
               IF retcode = 0
               AND p_mls_schema_name IS NOT NULL
               THEn
                   -- CALL Procedure to drop SLS MLS Synonyms
                   write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Dropping synonym table '||
                                  rt_c_get_sectab.sls_table_name || ' in '||p_mls_schema_name);
                   igi_sls_objects_pkg.drop_sls_mls_syn
                          (sls_tab            => rt_c_get_sectab.sls_table_name,
                           mls_schemaname     => p_mls_schema_name,
                           errbuf             => errbuf,
                           retcode            => retcode);
               END IF;

               IF retcode = 0
               AND p_mrc_schema_name IS NOT NULL
               THEN
                   -- CALL Procedure to drop SLS MRC Synonyms
                   write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Dropping synonym on table '||
                                  rt_c_get_sectab.sls_table_name || ' in '||p_mrc_schema_name);
                   igi_sls_objects_pkg.drop_sls_mrc_syn
                          (sls_tab            => rt_c_get_sectab.sls_table_name,
                           mrc_schemaname     => p_mrc_schema_name,
                           errbuf             => errbuf,
                           retcode            => retcode);
               END IF;
*/


               IF retcode = 0
               THEN
                   l_date_security_applied := SYSDATE;
               END IF;

               -- End of Processing for Deleted.

           END IF; -- (Enabled / Disabled / Re-enabled / Deleted)

           IF retcode = 0
           THEN
               -- All objects successfully created for the table.
               write_to_log (l_state_level, 'create_drop_sls_objects',  'Create_Drop_SLS_Objects, Updating igi_sls_secure_tables.date_security_applied '||
                              ' for '|| rt_c_get_sectab.sls_table_name);

               UPDATE   igi_sls_secure_tables
               SET      date_security_applied = l_date_security_applied,
                        last_update_login     = to_number(fnd_profile.value('LOGIN_ID')),
                        last_update_date      = SYSDATE,
                        last_updated_by       = to_number(fnd_profile.value('USER_ID'))
               WHERE    table_name = rt_c_get_sectab.table_name
               AND      owner      = rt_c_get_sectab.owner;

               -- Update the audit table only if the current row is
               -- enabled or disabled.
               -- If in future we decide to maintain an audit history
               -- of all actions then this IF condition will have to go.
               IF rt_c_get_sectab.date_disabled IS NOT NULL
               OR rt_c_get_sectab.date_removed  IS NOT NULL
               THEN
                   UPDATE igi_sls_secure_tables_audit a
                   SET    a.date_security_applied = SYSDATE
                   WHERE  a.date_security_applied IS NULL
                   AND    ROWID = (SELECT MAX(ROWID) b
                                   FROM  igi_sls_secure_tables_audit b
                                   WHERE a.table_name      = b.table_name
                                   AND   a.owner           = b.owner)
                   AND    table_name = rt_c_get_sectab.table_name
                   AND    owner      = rt_c_get_sectab.owner;

               END IF;

           END IF;

       END LOOP; -- For each record in igi_sls_secure_tables (c_get_sectab)

       COMMIT;

   EXCEPTION
   WHEN OTHERS THEN

	     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
      	     retcode := 2;
	     errbuf :=  Fnd_message.get;

	     write_to_log (l_excep_level, 'create_drop_sls_objects',  'END  Procedure Apply Security - failed with error '|| SQLERRM  || ' in create_drop_sls_objects' );
             ROLLBACK;
             RETURN;

   END create_drop_sls_objects;

   /*------------------------------------------------------------------
   This proecdure re-compiles i.e refreshes the triggers and procedures
   for only the enabled tables in the igi_sls_secure_tables

   Its is called from procedure IGI_SLS_SECURITY_PKG.APPLY_SECURITY only.
   ------------------------------------------------------------------*/
   PROCEDURE refresh_sls_objects     ( p_mls_schema_name  IN     VARCHAR2,
                                       p_mrc_schema_name  IN     VARCHAR2,
                                       errbuf             IN OUT NOCOPY VARCHAR2,
                                       retcode            IN OUT NOCOPY NUMBER)
   IS
   -- Cursor to select only those records which have had security applied earlier ie are not
   -- new objects
   CURSOR c_get_enab_sectab IS
          SELECT  owner,
                  table_name,
                  sls_table_name,
                  date_enabled,
                  date_disabled,
                  date_removed,
                  date_security_applied,
                  update_allowed,
                  Nvl(optimise_sql,'N') optimise_sql
          FROM    igi_sls_secure_tables
          WHERE   date_removed IS NULL
          AND     date_object_created IS NOT NULL;

   l_policy_type           VARCHAR2(50);
   l_policy_function       VARCHAR2(50);
   l_policy_name           VARCHAR2(50);
   l_schema_name           VARCHAR2(50);

   BEGIN

       retcode := 0;
       errbuf  := 'Normal Completion';

       get_schema_name (p_schema_name     => l_schema_name,
                        errbuf            => errbuf,
                        retcode           => retcode);


       FOR rt_c_get_enab_sectab IN c_get_enab_sectab
       LOOP
           write_to_log ( l_state_level, 'refresh_sls_objects', 'Refresh_SLS_Objects, Processing table '|| rt_c_get_enab_sectab.table_name);

           l_policy_function := rt_c_get_enab_sectab.sls_table_name||'_FUN';
           l_policy_name     := rt_c_get_enab_sectab.sls_table_name||'_POL';

           IF rt_c_get_enab_sectab.update_allowed = 'Y'
           THEN
               l_policy_type := 'SELECT,UPDATE';
           ELSE
               l_policy_type := 'SELECT';
           END IF;

           IF rt_c_get_enab_sectab.optimise_sql = 'Y'
           THEN
               -- Call procedure to create additional column
               igi_sls_objects_pkg.create_sls_col
                     (sec_tab         => rt_c_get_enab_sectab.table_name,
                      schema_name     => rt_c_get_enab_sectab.owner,
                      errbuf         => errbuf,
                      retcode        => retcode);
           END IF;

           -- Security has been enabled
           IF rt_c_get_enab_sectab.date_disabled  IS NULL
           THEN
               -- Call Procedure to create Database Trigger
               write_to_log (l_state_level, 'refresh_sls_objects', 'Refresh_SLS_Objects, Re-Creating trigger '||
                               rt_c_get_enab_sectab.sls_table_name||'_TRG' ||
                              ' on table ' || rt_c_get_enab_sectab.table_name);

               IF retcode = 0
               THEN
                   IF rt_c_get_enab_sectab.optimise_sql = 'N'
                   THEN
                       igi_sls_objects_pkg.create_sls_trg
                          (sls_tab                  => rt_c_get_enab_sectab.sls_table_name,
                           sec_tab                  => rt_c_get_enab_sectab.table_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

                   ELSE
                       igi_sls_objects_pkg.create_sls_col_trg
                          (sls_tab         => rt_c_get_enab_sectab.sls_table_name,
                           sec_tab         => rt_c_get_enab_sectab.table_name,
                           errbuf          => errbuf,
                           retcode         => retcode);
                   END IF;
               END IF;

               IF retcode = 0
               THEN
                   -- Call Procedure to create Policy Function
                   write_to_log (l_state_level, 'refresh_sls_objects', 'Refresh_SLS_Objects, Re-Creating policy function  ' ||l_policy_function);

                   IF rt_c_get_enab_sectab.optimise_sql = 'N'
                   THEN
                       igi_sls_objects_pkg.cre_pol_function
                          (sec_tab        => rt_c_get_enab_sectab.table_name,
                           sls_tab        => rt_c_get_enab_sectab.sls_table_name,
                           errbuf         => errbuf,
                           retcode        => retcode);
                   ELSE
                       igi_sls_objects_pkg.cre_ext_col_pol_func
                          (sec_tab        => rt_c_get_enab_sectab.table_name,
                           sls_tab        => rt_c_get_enab_sectab.sls_table_name,
                           errbuf         => errbuf,
                           retcode        => retcode);

                   END IF;
               END IF;

               -- We need to drop and recreate the policy just in case user has changed the
               -- update_allowed flag
               IF retcode = 0
               THEN
                   -- CALL Procedure to drop Policy
                   write_to_log (l_state_level, 'refresh_sls_objects', 'Create_Drop_SLS_Objects, Dropping policy '||l_policy_name);
                   igi_sls_objects_pkg.sls_drop_pol
                          (object_schema            => rt_c_get_enab_sectab.owner,
                           table_name               => rt_c_get_enab_sectab.table_name,
                           policy_name              => l_policy_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);
               END IF;

               IF retcode = 0
               THEN
                   write_to_log (l_state_level, 'refresh_sls_objects', 'Refresh_SLS_Objects, Creating policy ' ||l_policy_name ||
                                  ' on table ' || rt_c_get_enab_sectab.table_name);

                   -- Call Procedure to create Policy
                   igi_sls_objects_pkg.sls_add_pol
                          (object_schema            => rt_c_get_enab_sectab.owner,
                           table_name               => rt_c_get_enab_sectab.table_name,
                           policy_name              => l_policy_name,
                           function_owner           => l_schema_name,
                           policy_function          => l_policy_function,
                           statement_types          => l_policy_type,
                           errbuf                   => errbuf,
                           retcode                  => retcode);
               END IF;

               -- End of processing for enabled records

          ELSIF rt_c_get_enab_sectab.date_disabled IS NOT NULL
          THEN
               -- Security has been disabled
               write_to_log ( l_state_level, 'refresh_sls_objects','Refresh_SLS_Objects, Disabling policy '||l_policy_name);
               igi_sls_objects_pkg.sls_disable_pol
                          (object_schema            => rt_c_get_enab_sectab.owner,
                           table_name               => rt_c_get_enab_sectab.table_name,
                           policy_name              => l_policy_name,
                           enable                   => FALSE,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

               IF retcode = 0
               THEN
                   write_to_log (l_state_level, 'refresh_sls_objects', 'Refresh_SLS_Objects, Re-Creating trigger '||
                               rt_c_get_enab_sectab.sls_table_name||'_TRG' ||
                              ' on table ' || rt_c_get_enab_sectab.table_name);

                   IF rt_c_get_enab_sectab.optimise_sql = 'N'
                   THEN
                       igi_sls_objects_pkg.create_sls_trg
                          (sls_tab                  => rt_c_get_enab_sectab.sls_table_name,
                           sec_tab                  => rt_c_get_enab_sectab.table_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);

                   ELSE
                       igi_sls_objects_pkg.create_sls_col_trg
                          (sls_tab         => rt_c_get_enab_sectab.sls_table_name,
                           sec_tab         => rt_c_get_enab_sectab.table_name,
                           errbuf          => errbuf,
                           retcode         => retcode);
                   END IF;
               END IF;

               IF retcode = 0
               THEN
                   -- Call Procedure to create Policy Function
                   write_to_log ( l_state_level, 'refresh_sls_objects','Refresh_SLS_Objects, Re-Creating policy function  ' ||l_policy_function);

                   IF rt_c_get_enab_sectab.optimise_sql = 'N'
                   THEN
                       igi_sls_objects_pkg.cre_pol_function
                          (sec_tab        => rt_c_get_enab_sectab.table_name,
                           sls_tab        => rt_c_get_enab_sectab.sls_table_name,
                           errbuf         => errbuf,
                           retcode        => retcode);
                   ELSE
                       igi_sls_objects_pkg.cre_ext_col_pol_func
                          (sec_tab        => rt_c_get_enab_sectab.table_name,
                           sls_tab        => rt_c_get_enab_sectab.sls_table_name,
                           errbuf         => errbuf,
                           retcode        => retcode);

                   END IF;
               END IF;

               -- End of processing for disabled records

          END IF;  -- (Disabled / Re-Enabled)


          IF rt_c_get_enab_sectab.optimise_sql = 'N'
          THEN
              -- Recreate the index if absent
              igi_sls_objects_pkg.create_sls_inx
                 (sls_tab                  => rt_c_get_enab_sectab.sls_table_name,
                  errbuf                   => errbuf,
                  retcode                  => retcode);
          ELSE
              igi_sls_objects_pkg.create_sls_core_inx
                 (sec_tab         => rt_c_get_enab_sectab.table_name,
                  sls_tab         => rt_c_get_enab_sectab.sls_table_name,
                  schema_name     => rt_c_get_enab_sectab.owner,
                  errbuf          => errbuf,
                  retcode         => retcode);
          END IF;

       END LOOP;  -- For every record in c_get_enab_sectab

   EXCEPTION
   WHEN OTHERS THEN

	     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
	     retcode := 2;
	     errbuf :=  Fnd_message.get;
             write_to_log ( l_excep_level, 'refresh_sls_objects','END  Procedure Apply Security - failed with error '|| SQLERRM );

   END refresh_sls_objects;


   /*------------------------------------------------------------------
   This proecdure populates the igi_sls_security_group_alloc table with the most
   uptodate data

   Its is called from procedure IGI_SLS_SECURITY_PKG.APPLY_SECURITY only.
   ------------------------------------------------------------------*/
   PROCEDURE populate_group_alloc     ( errbuf             IN OUT NOCOPY VARCHAR2,
                                        retcode            IN OUT NOCOPY NUMBER)
   IS

   l_sql_stmt              VARCHAR2(500);

   BEGIN

      write_to_log (l_state_level, 'populate_group_alloc', 'Populate_Group_Alloc, Truncating table igi_sls_security_group_alloc ');
      l_sql_stmt := 'BEGIN igi.apps_ddl.apps_ddl('||'''TRUNCATE TABLE igi_sls_security_group_alloc'''||');END;';

      EXECUTE IMMEDIATE l_sql_stmt;

      write_to_log (l_state_level, 'populate_group_alloc', 'Populate_Group_Alloc, Inserting into table igi_sls_security_group_alloc ');
      INSERT INTO igi_sls_security_group_alloc
                  (SLS_SECURITY_GROUP
                  ,TABLE_NAME
                  )
             SELECT DISTINCT sls_group,
                    table_name
             FROM   igi_sls_enabled_alloc_v;

      COMMIT;

   EXCEPTION
   WHEN OTHERS THEN

             FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
             retcode := 2;
             errbuf :=  Fnd_message.get;
             write_to_log (l_excep_level, 'populate_group_alloc', 'END  Procedure Apply Security - failed with error '|| SQLERRM  ||
                            ' in populate_group_alloc');
             ROLLBACK;
             RETURN;

   END populate_group_alloc;


   /*------------------------------------------------------------------
   This proecdure cleans up the data in the security tables after all
   the objets have been created.

   Its is called from procedure IGI_SLS_SECURITY_PKG.APPLY_SECURITY only.
   ------------------------------------------------------------------*/
   PROCEDURE cleanup_data     ( errbuf             IN OUT NOCOPY VARCHAR2,
                                retcode            IN OUT NOCOPY NUMBER)
   IS

   CURSOR c_del_table IS
          SELECT table_name,
                 date_removed
          FROM   igi_sls_secure_tables
          WHERE  date_removed IS NOT NULL;

   rt_c_del_table       c_del_table%ROWTYPE;

   CURSOR c_del_group IS
          SELECT sls_group,
                 sls_group_type,
                 date_removed
          FROM   igi_sls_groups
          WHERE  date_removed IS NOT NULL;

   rt_c_del_group       c_del_group%ROWTYPE;

   no_table_exists      EXCEPTION;
   PRAGMA EXCEPTION_INIT (no_table_exists, -00942);


   CURSOR c_del_alloc IS
         (SELECT a.sls_group           sls_group,
                 a.sls_allocation      table_name
         FROM    igi_sls_allocations    a
         WHERE   a.sls_group_type      = 'S'
         AND     a.sls_allocation_type = 'T'
         AND     a.date_removed IS NOT NULL
         UNION
         SELECT  a.sls_group           sls_group,
                 d.sls_allocation      table_name
         FROM    igi_sls_aLlocations    a,
                 igi_sls_allocations    d
         WHERE   a.sls_allocation       = d.sls_group
         AND     a.sls_group_type       = 'S'
         AND     a.sls_allocation_type  = 'P'
         AND     d.sls_group_type       = 'P'
         AND     d.sls_allocation_type  = 'T'
         AND     (a.date_removed IS NOT NULL or d.date_removed IS NOT NULL))
         MINUS
         SELECT  sls_security_group    sls_group,
                 table_name            table_name
         FROM    igi_sls_security_group_alloc;

   rt_c_del_alloc          c_del_alloc%ROWTYPE;

   CURSOR c_get_sls_tabname (p_table_name      VARCHAR2) IS
         SELECT sls_table_name,
                date_removed,
                table_name,
                NVL(optimise_sql,'N') optimise_sql
         FROM   igi_sls_secure_tables
         WHERE  table_name = p_table_name;

   l_sls_table_name              igi_sls_secure_tables.sls_table_name%TYPE;
   l_date_removed                igi_sls_secure_tables.date_removed%TYPE;
   l_table_name                  igi_sls_secure_tables.table_name%TYPE;
   l_optimise_sql                igi_sls_secure_tables.OPTIMISE_SQL%TYPE;
   l_sql_stmt                    VARCHAR2(1000);

   BEGIN

      -- for every table, mark the allocations as deleted.
      write_to_log (l_state_level, 'cleanup_data', 'Cleanup_Data, Updating deleted tables in igi_sls_allocations');
      FOR  rt_c_del_table IN c_del_table
      LOOP
         UPDATE igi_sls_allocations
         SET    date_removed        = rt_c_del_table.date_removed,
                date_disabled       = Nvl(date_disabled, rt_c_del_table.date_removed),
                last_update_login     = to_number(fnd_profile.value('LOGIN_ID')),
                last_update_date      = SYSDATE,
                last_updated_by       = to_number(fnd_profile.value('USER_ID'))
         WHERE  sls_allocation      = rt_c_del_table.table_name
         AND    sls_allocation_type = 'T'
         AND    date_removed IS NULL;


         -- Insert into the allocations audit table, the history for the the
         -- record that is about to be deleted.
         -- Insert the record only if it has not already been done earlier.
         INSERT INTO igi_sls_allocations_audit
                (sls_group,
                sls_group_type,
                sls_allocation,
                sls_allocation_type,
                date_enabled,
                date_disabled,
                date_removed ,
                date_security_applied,
                creation_date,
                created_by,
                last_update_login,
                last_update_date,
                last_updated_by)
         SELECT
                sls_group,
                sls_group_type,
                sls_allocation,
                sls_allocation_type,
                date_enabled,
                date_disabled,
                date_removed ,
                SYSDATE,
                creation_date,
                created_by,
                last_update_login,
                last_update_date,
                last_updated_by
         FROM   igi_sls_allocations a
         WHERE  a.sls_allocation = rt_c_del_table.table_name
         AND    a.date_removed   = rt_c_del_table.date_removed
         AND    NOT EXISTS (SELECT 'X'
                            FROM   igi_sls_allocations_audit b
                            WHERE  a.sls_allocation  = b.sls_allocation
                            AND    a.sls_group       = b.sls_group
                            AND    a.date_enabled    = b.date_enabled
                            AND    a.date_removed    = b.date_removed);

      END LOOP ; -- for each deleted table

      -- for every group, mark the allocations as deleted.
      write_to_log (l_state_level, 'cleanup_data', 'Cleanup_Data, Updating deleted group in igi_sls_allocations');
      FOR  rt_c_del_group IN c_del_group
      LOOP
          UPDATE igi_sls_allocations
          SET    date_removed    = rt_c_del_group.date_removed,
                 date_disabled   = Nvl(date_disabled, rt_c_del_group.date_removed),
                 last_update_login     = to_number(fnd_profile.value('LOGIN_ID')),
                 last_update_date      = SYSDATE,
                 last_updated_by       = to_number(fnd_profile.value('USER_ID'))
          WHERE  sls_group       = rt_c_del_group.sls_group
          AND    sls_group_type  = rt_c_del_group.sls_group_type
          AND    date_removed    IS NULL;

          -- Insert into the allocations audit table, the history for the the
          -- record that is about to be deleted.
          -- Insert the record only if it has not already been done earlier.
          INSERT INTO igi_sls_allocations_audit
                (sls_group,
                sls_group_type,
                sls_allocation,
                sls_allocation_type,
                date_enabled,
                date_disabled,
                date_removed ,
                date_security_applied,
                creation_date,
                created_by,
                last_update_login,
                last_update_date,
                last_updated_by)
          SELECT
                sls_group,
                sls_group_type,
                sls_allocation,
                sls_allocation_type,
                date_enabled,
                date_disabled,
                date_removed ,
                SYSDATE,
                creation_date,
                created_by,
                last_update_login,
                last_update_date,
                last_updated_by
          FROM   igi_sls_allocations a
          WHERE  a.sls_group      = rt_c_del_group.sls_group
          AND    a.sls_group_type = rt_c_del_group.sls_group_type
          AND    a.date_removed   = rt_c_del_group.date_removed
          AND    NOT EXISTS (SELECT 'X'
                            FROM   igi_sls_allocations_audit b
                            WHERE  a.sls_allocation  = b.sls_allocation
                            AND    a.sls_group       = b.sls_group
                            AND    a.sls_group_type  = b.sls_group_type
                            AND    a.date_enabled    = b.date_enabled
                            AND    a.date_removed    = b.date_removed);

          IF rt_c_del_group.sls_group_type = 'P'
          THEN
              UPDATE igi_sls_allocations
              SET    date_removed      = rt_c_del_group.date_removed,
                     date_disabled     = Nvl(date_disabled, rt_c_del_group.date_removed),
                     last_update_login = to_number(fnd_profile.value('LOGIN_ID')),
                     last_update_date  = SYSDATE,
                     last_updated_by   = to_number(fnd_profile.value('USER_ID'))
              WHERE  sls_allocation    = rt_c_del_group.sls_group
              AND    sls_group_type    = rt_c_del_group.sls_group_type
              AND    date_removed      IS NULL;

              -- Insert into the allocations audit table, the history for the the
              -- record that is about to be deleted.
              -- Insert the record only if it has not already been done earlier.
              INSERT INTO igi_sls_allocations_audit
                (sls_group,
                sls_group_type,
                sls_allocation,
                sls_allocation_type,
                date_enabled,
                date_disabled,
                date_removed ,
                date_security_applied,
                creation_date,
                created_by,
                last_update_login,
                last_update_date,
                last_updated_by)
              SELECT
                sls_group,
                sls_group_type,
                sls_allocation,
                sls_allocation_type,
                date_enabled,
                date_disabled,
                date_removed ,
                SYSDATE,
                creation_date,
                created_by,
                last_update_login,
                last_update_date,
                last_updated_by
              FROM   igi_sls_allocations a
              WHERE  a.sls_allocation    = rt_c_del_group.sls_group
              AND    a.date_removed      = rt_c_del_group.date_removed
              AND    NOT EXISTS (SELECT 'X'
                            FROM   igi_sls_allocations_audit b
                            WHERE  a.sls_allocation  = b.sls_allocation
                            AND    a.sls_group       = b.sls_group
                            AND    a.sls_group_type  = b.sls_group_type
                            AND    a.date_enabled    = b.date_enabled
                            AND    a.date_removed    = b.date_removed);

          END IF;
      END LOOP ; -- for each deleted group

      -- For every record marked for deletion in igi_sls_allocations
      FOR rt_c_del_alloc IN c_del_alloc
      LOOP
          OPEN  c_get_sls_tabname (rt_c_del_alloc.table_name);
          FETCH c_get_sls_tabname INTO l_sls_table_name,
                                      l_date_removed, l_table_name, l_optimise_sql;
          CLOSE c_get_sls_tabname;

          IF  l_sls_table_name IS NOT NULL
          AND l_date_removed   IS NULL -- If table is deleted, then the extended table will have been
                                       -- dropped by now.
          THEN

         IF l_optimise_sql = 'N'
                THEN
              write_to_log (l_state_level, 'cleanup_data', 'Cleanup_Data, Deleting records from table '||l_sls_table_name ||
                             ' for group '|| rt_c_del_alloc.sls_group );

              BEGIN
                 l_sql_stmt := ' DELETE FROM '|| l_sls_table_name ||
                               ' WHERE sls_sec_grp = :sls_group';
--                            ' WHERE sls_sec_grp = '''|| rt_c_del_alloc.sls_group || '''';
          write_to_log (l_state_level, 'cleanup_data', 'l_sls_table_name '|| l_sls_table_name);
          write_to_log (l_state_level, 'cleanup_data', 'sls_group' || rt_c_del_alloc.sls_group);

                 -- Bug 2972984, Use bind variables
                 EXECUTE IMMEDIATE l_sql_stmt USING rt_c_del_alloc.sls_group;
              EXCEPTION
              WHEN no_table_exists THEN
                   NULL;
              END ;

            ELSE
               BEGIN
                 write_to_log (l_state_level, 'cleanup_data', 'Cleanup_Data, Deleting records from table '|| rt_c_del_alloc.table_name ||
                             ' for group '|| rt_c_del_alloc.sls_group );

              l_sql_stmt := ' UPDATE ' || l_table_name ||
                            ' SET igi_sls_sec_group = NULL ' ||
                               ' WHERE igi_sls_sec_group = :sls_group';
--                            ' WHERE sls_sec_grp = '''|| rt_c_del_alloc.sls_group || '''';
          write_to_log (l_state_level, 'cleanup_data', 'l_sls_table_name '|| l_sls_table_name);
          write_to_log (l_state_level, 'cleanup_data', 'sls_group' || rt_c_del_alloc.sls_group);
           write_to_log (l_state_level, 'cleanup_data', 'table_name '|| rt_c_del_alloc.table_name);
             write_to_log (l_state_level, 'cleanup_data', 'l_table_name '|| l_table_name);
  write_to_log (l_state_level, 'cleanup_data', 'l_sql_stmt '|| l_sql_stmt);
                   -- Bug 2972984, Use bind variables
           EXECUTE IMMEDIATE l_sql_stmt USING  rt_c_del_alloc.sls_group;

           write_to_log (l_state_level, 'cleanup_data', 'After Exec. Immediate');

            delete from FND_PROFILE_OPTION_VALUES
            where  PROFILE_OPTION_ID = (select profile_option_id  from fnd_profile_options where
              profile_option_name = 'IGI_SLS_SECURITY_GROUP')
            and    APPLICATION_ID    = (  select application_id from fnd_application_vl where
              application_short_name  = 'IGI' )
            and profile_option_value = rt_c_del_alloc.sls_group ;

             write_to_log (l_state_level, 'cleanup_data', 'After Delete stmt. Immediate' || rt_c_del_alloc.sls_group);
           EXCEPTION
              WHEN no_table_exists THEN
                   NULL;
              END ;
          END IF;

          END IF;

      END LOOP;

      -- Delete all records marked for deletion
      write_to_log (l_state_level, 'cleanup_data', 'Cleanup_Data, Deleting ALL marked records from igi_sls_allocations');
      DELETE FROM igi_sls_allocations
      WHERE  date_removed IS NOT NULL;

      write_to_log (l_state_level, 'cleanup_data', 'Cleanup_Data, Deleting ALL marked records from igi_sls_secure_tables');
      DELETE FROM igi_sls_secure_tables
      WHERE  date_removed IS NOT NULL;

      write_to_log (l_state_level, 'cleanup_data', 'Cleanup_Data, Deleting ALL marked records from igi_sls_groups');
      DELETE FROM igi_sls_groups
      WHERE  date_removed IS NOT NULL;

      COMMIT;

   EXCEPTION
   WHEN no_table_exists THEN
             NULL;

   WHEN OTHERS THEN

	     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
	     retcode := 2;
	     errbuf :=  Fnd_message.get;
             write_to_log (l_excep_level, 'cleanup_data', 'END  Procedure Apply Security - failed with error '|| SQLERRM ||
                            ' when cleaning up data ');
             ROLLBACK;

   END cleanup_data;



   /*------------------------------------------------------------------
   This proecdure stamps the data with date_security_applied on the
   group and allocations table

   Its is called from procedure IGI_SLS_SECURITY_PKG.APPLY_SECURITY only.
   ------------------------------------------------------------------*/
   PROCEDURE stamp_records     ( errbuf             IN OUT NOCOPY VARCHAR2,
                                retcode            IN OUT NOCOPY NUMBER)
   IS

   CURSOR c_all_group IS
          SELECT sls_group,
                 date_removed,
                 date_disabled
          FROM   igi_sls_groups
          WHERE  date_security_applied IS NULL
          FOR UPDATE OF date_security_applied;

   rt_c_all_group       c_all_group%ROWTYPE;

   CURSOR c_all_alloc IS
         SELECT sls_group,
                sls_allocation,
                date_disabled,
                date_removed
         FROM   igi_sls_allocations
         WHERE  date_security_applied IS NULL
         FOR UPDATE OF date_security_applied;

   rt_c_all_alloc       c_all_alloc%ROWTYPE;

   BEGIN

       write_to_log (l_state_level, 'stamp_records', 'Populate_Group_Alloc, Updating table igi_sls_groups.date_security_applied ');
       FOR rt_c_all_group IN c_all_group
       LOOP
           UPDATE igi_sls_groups
           SET    date_security_applied = SYSDATE,
                  last_update_login     = to_number(fnd_profile.value('LOGIN_ID')),
                  last_update_date      = SYSDATE,
                  last_updated_by       = to_number(fnd_profile.value('USER_ID'))
           WHERE  CURRENT OF c_all_group;

           -- Update the audit table only if the current row is
           -- enabled or disabled.
           -- If in future we decide to maintain an audit history
           -- of all actions then this IF condition will have to go.
           IF rt_c_all_group.date_disabled IS NOT NULL
           OR rt_c_all_group.date_removed  IS NOT NULL
           THEN
               UPDATE igi_sls_groups_audit a
               SET    a.date_security_applied = SYSDATE
               WHERE  date_security_applied IS NULL
               AND    ROWID = (SELECT MAX(ROWID) b
                               FROM igi_sls_groups_audit b
                               WHERE a.sls_group      = b.sls_group)
               AND    sls_group = rt_c_all_group.sls_group;

            END IF;
       END LOOP;

       write_to_log (l_state_level, 'stamp_records', 'Populate_Group_Alloc, Updating table igi_sls_allocations.date_security_applied ');
       FOR rt_c_all_alloc IN c_all_alloc
       LOOP
           UPDATE igi_sls_allocations
           SET    date_security_applied = SYSDATE,
                  last_update_login     = to_number(fnd_profile.value('LOGIN_ID')),
                  last_update_date      = SYSDATE,
                  last_updated_by       = to_number(fnd_profile.value('USER_ID'))
           WHERE  CURRENT OF c_all_alloc;

           -- Update the audit table only if the current row is
           -- enabled or disabled.
           -- If in future we decide to maintain an audit history
           -- of all actions then this IF condition will have to go.
           IF rt_c_all_alloc.date_disabled IS NOT NULL
           OR rt_c_all_alloc.date_removed  IS NOT NULL
           THEN
               UPDATE igi_sls_allocations_audit a
               SET    a.date_security_applied = SYSDATE
               WHERE  a.date_security_applied IS NULL
               AND    ROWID = (SELECT MAX(ROWID) b
                               FROM  igi_sls_allocations_audit b
                               WHERE a.sls_allocation = b.sls_allocation
                               AND   a.sls_group      = b.sls_group)
               AND    sls_allocation = rt_c_all_alloc.sls_allocation
               AND    sls_group      = rt_c_all_alloc.sls_group;
           END IF;

       END LOOP;

       -- Records to be commited after the cleanup exercise
       EXCEPTION
       WHEN OTHERS THEN

	     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
	     retcode := 2;
	     errbuf :=  Fnd_message.get;
             write_to_log ( l_excep_level, 'stamp_records','END  Procedure Apply Security - failed with error '|| SQLERRM ||
                            ' when stamping records with the date_security_applied ');
             ROLLBACK;

   END stamp_records;

  /*---------------------------------------------------------------------
    This procedure contains the consolidatation of groups requirement to
    implement phase 2 of SLS.
    It is called only from apply_security.
  ---------------------------------------------------------------------*/
   PROCEDURE consolidate_groups   ( errbuf             IN OUT NOCOPY VARCHAR2,
                                    retcode            IN OUT NOCOPY NUMBER)
   IS

   CURSOR c_cons_recs IS
          SELECT from_sls_security_group,
                 to_sls_security_group
          FROM   igi_sls_consolidate_groups
          WHERE  date_security_applied IS NULL;

   CURSOR c_grp_alloc  (p_sls_group          igi_sls_groups.sls_group%TYPE) IS
          SELECT sls_group,
                 sls_group_type,
                 sls_allocation,
                 sls_allocation_type,
                 date_enabled,
                 date_disabled,
                 date_removed,
                 date_security_applied,
                 creation_date,
                 created_by,
                 last_update_login,
                 last_update_date,
                 last_updated_by
          FROM   igi_sls_allocations
          WHERE  sls_group = p_sls_group
          AND    date_removed IS NULL;

   CURSOR c_prcgrp_alloc  (p_sls_group          igi_sls_groups.sls_group%TYPE) IS
          SELECT sls_allocation
          FROM   igi_sls_allocations
          WHERE  sls_group = p_sls_group
          AND    sls_allocation_type = 'T'
          AND    date_removed IS NULL;

   CURSOR c_sls_tname  (p_table_name         igi_sls_secure_tables.table_name%TYPE) IS
          SELECT sls_table_name,
          -- Bug 5144650 .. Start
          NVL(optimise_sql,'N') optimise_sql
          -- Bug 5144650 .. End
          FROM   igi_sls_secure_tables
          WHERE  table_name = p_table_name;

   l_sls_tabname                igi_sls_secure_tables.sls_table_name%TYPE;
   l_sql_stmt                   VARCHAR2(1000);
   l_alloc_count                NUMBER;
   l_text                       VARCHAR2(500);
   l_enab_rec_count             NUMBER;
   l_date_disabled              DATE;
   l_sysdate                    DATE := SYSDATE;

   -- Bug 5144650 .. Start
   l_optimise_sql               igi_sls_secure_tables.optimise_sql%TYPE;
   -- Bug 5144650 .. End
   no_table_exists      EXCEPTION;
   PRAGMA EXCEPTION_INIT (no_table_exists, -00942);

   BEGIN

      -- Get all the groups that need to be merged / transferred.
      FOR rt_c_cons_recs IN c_cons_recs
      LOOP
         l_text := 'consolidate_groups, Consolidating group ' ||rt_c_cons_recs.from_sls_security_group||
                   ' with ' || rt_c_cons_recs.to_sls_security_group;

         write_to_log (l_state_level, 'consolidate_groups', l_text);

         FOR rt_c_grp_alloc IN c_grp_alloc(rt_c_cons_recs.from_sls_security_group)
         LOOP

             IF rt_c_grp_alloc.sls_allocation_type = 'T'
             THEN
                 OPEN c_sls_tname (rt_c_grp_alloc.sls_allocation);
                 -- Bug 5144650 .. Start
                 FETCH c_sls_tname INTO l_sls_tabname, l_optimise_sql;
                 -- Bug 5144650 .. End
                 CLOSE c_sls_tname;

                -- Bug 2972984, Use bind variables
/*
                 l_sql_stmt := ' UPDATE ' ||l_sls_tabname ||
                           ' SET sls_sec_grp = '''||rt_c_cons_recs.to_sls_security_group ||''',' ||
                           '    prev_sls_sec_grp = '''||rt_c_cons_recs.from_sls_security_group||''','||
                           '    change_date   = SYSDATE ' ||
                           ' WHERE sls_sec_grp = '''||rt_c_cons_recs.from_sls_security_group||'''';
*/

                 l_sql_stmt := ' UPDATE ' ||l_sls_tabname ||
                           ' SET sls_sec_grp = :to_sls_security_group ,'||
                           '    prev_sls_sec_grp = :from_sls_security_group,'||
                           '    change_date   = SYSDATE ' ||
                           ' WHERE sls_sec_grp = :from_sls_security_group';
                 BEGIN
                     EXECUTE IMMEDIATE l_sql_stmt
                             USING rt_c_cons_recs.to_sls_security_group,
                                   rt_c_cons_recs.from_sls_security_group,
                                   rt_c_cons_recs.from_sls_security_group;
                 EXCEPTION
                 WHEN no_table_exists THEN
                       NULL;
                 END;

             ELSIF rt_c_grp_alloc.sls_allocation_type = 'P'
             THEN

                 FOR rt_c_pgrp_alloc IN c_prcgrp_alloc (rt_c_grp_alloc.sls_allocation)
                 LOOP
                     OPEN c_sls_tname (rt_c_pgrp_alloc.sls_allocation);
                     -- Bug 5144650 .. Start
                     FETCH c_sls_tname INTO l_sls_tabname, l_optimise_sql;
                     -- Bug 5144650 .. End
                     CLOSE c_sls_tname;
                 -- Bug 2972984, Use bind variables
/*
                     l_sql_stmt := ' UPDATE ' ||l_sls_tabname ||
                               ' SET sls_sec_grp = '''||rt_c_cons_recs.to_sls_security_group ||''',' ||
                               '    prev_sls_sec_grp = '''||rt_c_cons_recs.from_sls_security_group||''','||
                               '    change_date   = SYSDATE ' ||
                               ' WHERE sls_sec_grp = '''||rt_c_cons_recs.from_sls_security_group||'''';

*/
                 l_sql_stmt := ' UPDATE ' ||l_sls_tabname ||
                           ' SET sls_sec_grp = :to_sls_security_group ,'||
                           '    prev_sls_sec_grp = :from_sls_security_group,'||
                           '    change_date   = SYSDATE ' ||
                           ' WHERE sls_sec_grp = :from_sls_security_group';
                 BEGIN
                     EXECUTE IMMEDIATE l_sql_stmt
                             USING rt_c_cons_recs.to_sls_security_group,
                                   rt_c_cons_recs.from_sls_security_group,
                                   rt_c_cons_recs.from_sls_security_group;

                     EXCEPTION
                     WHEN no_table_exists THEN
                          NULL;
                     END;

                 END LOOP;
             END IF; -- Allocation type = 'P' or 'T'

             -- Bug 5144650 .. Start
             If l_optimise_sql = 'Y' Then
                write_to_log (l_excep_level, 'consolidate_groups', 'optimise sql flag for table' || rt_c_grp_alloc.sls_allocation || ' is set to ' || l_optimise_sql);
                l_sql_stmt := ' UPDATE ' || rt_c_grp_alloc.sls_allocation ||
                   ' SET igi_sls_sec_group = :to_sls_security_group '||
                   ' WHERE igi_sls_sec_group = :from_sls_security_group';
                Begin
                   Execute Immediate l_sql_stmt
                      USING rt_c_cons_recs.to_sls_security_group,
                            rt_c_cons_recs.from_sls_security_group;
                Exception
                   When no_table_exists Then
                      Null;
                   When others then
                      Raise;
                End;
             End If;
             -- Bug 5144650 .. End

             -- Check if the allocation already exists in the target group.
             SELECT COUNT(*)
             INTO   l_alloc_count
             FROM   igi_sls_allocations
             WHERE  sls_allocation      = rt_c_grp_alloc.sls_allocation
             AND    sls_group           = rt_c_cons_recs.to_sls_security_group
             AND    sls_allocation_type = rt_c_grp_alloc.sls_allocation_type;

             IF l_alloc_count = 0
             THEN

                 -- Check for the status of the allocation in all the groups involved.
                 -- Mark it disabled only if it is disabled in all groups, else
                 -- Mark it enabled.
                 SELECT COUNT(*)
                 INTO   l_enab_rec_count
                 FROM   igi_sls_allocations a,
                        igi_sls_consolidate_groups b
                 WHERE  a.sls_group             = b.from_sls_security_group
                 AND    a.date_disabled IS NULL
                 AND    a.date_removed IS NULL
                 AND    a.sls_allocation        = rt_c_grp_alloc.sls_allocation
                 AND    b.to_sls_security_group = rt_c_cons_recs.to_sls_security_group;

                 IF l_enab_rec_count = 0
                 THEN
                     -- In all the groups that need to be consolidatd, the
                     -- allocation is not enabled anywhere.
                     l_date_disabled := SYSDATE;
                 ELSE
                     -- The allocation is enabled atleast in one group
                     l_date_disabled := NULL;
                 END IF;

                 -- Since Allocation does not exist, insert into the table.
                 INSERT INTO igi_sls_allocations
                        (sls_group,
                         sls_group_type,
                         sls_allocation,
                         sls_allocation_type,
                         date_enabled,
                         date_disabled,
                         date_removed ,
                         date_security_applied,
                         creation_date,
                         created_by,
                         last_update_login,
                         last_update_date,
                         last_updated_by)
                 VALUES
                       (rt_c_cons_recs.to_sls_security_group,
                        'S',
                        rt_c_grp_alloc.sls_allocation,
                        rt_c_grp_alloc.sls_allocation_type,
                        SYSDATE,
                        l_date_disabled,
                        NULL,
                        NULL,
                        SYSDATE,
                        to_number(fnd_profile.value('USER_ID')),
                        to_number(fnd_profile.value('LOGIN_ID')),
                        SYSDATE,
                        to_number(fnd_profile.value('USER_ID')));
             END IF; -- record with the same allocation does not already exist.

         END LOOP; -- rt_c_grp_alloc

         -- Mark the group for deletion,
         -- The allocation and the audit table population will be done in the
         -- cleanup_data procedure. Hence, date_security_applied is set to null.
         UPDATE igi_sls_groups
         SET    date_disabled         = Nvl(date_disabled, l_sysdate),
                date_removed          = SYSDATE,
                date_security_applied = NULL,
                last_update_login     = to_number(fnd_profile.value('LOGIN_ID')),
                last_update_date      = SYSDATE,
                last_updated_by       = to_number(fnd_profile.value('USER_ID'))
         WHERE  sls_group             = rt_c_cons_recs.from_sls_security_group
         AND    date_removed IS NULL;

         -- Since the group is being marked for deletion, enter a record
         -- into the audit table.
         INSERT INTO igi_sls_groups_audit
                (sls_group,
                sls_group_type,
                description,
                date_enabled,
                date_disabled,
                date_removed,
                date_security_applied,
                creation_date,
                created_by,
                last_update_login,
                last_update_date,
                last_updated_by)
          SELECT
                sls_group,
                sls_group_type,
                description,
                date_enabled,
                date_disabled,
                date_removed,
                date_security_applied,
                creation_date,
                created_by,
                last_update_login,
                last_update_date,
                last_updated_by
          FROM  igi_sls_groups
          WHERE sls_group    = rt_c_cons_recs.from_sls_security_group
          AND   date_removed = l_sysdate;

          UPDATE igi_sls_consolidate_groups
          SET    date_security_applied = SYSDATE,
                 last_update_login     = to_number(fnd_profile.value('LOGIN_ID')),
                 last_update_date      = SYSDATE,
                 last_updated_by       = to_number(fnd_profile.value('USER_ID'))
          WHERE  date_security_applied IS NULL;

          COMMIT;

      END LOOP; -- rt_c_cons_recs

   EXCEPTION
   WHEN OTHERS THEN

	     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
	     retcode := 2;
	     errbuf :=  Fnd_message.get;
             write_to_log (l_excep_level, 'consolidate_groups', 'END  Procedure Apply Security - failed with error '|| SQLERRM ||
                            ' when consolidating groups ');
             ROLLBACK;


   END consolidate_groups;


  /*---------------------------------------------------------------------
   This procedure calls the various procedures to implement security on
   the secure tables defined.
   Parameters :
   Input  :  p_mode - CREATE - Create the SLS objects
                      REFRESH - refresh the SLS objects
   Output :  errbuf  - Exit error message
             retcode  - Return code for the procedure.
                      0 - Success
                      1 - Warning
                      2 - Failure
  ---------------------------------------------------------------------*/
   PROCEDURE apply_security    ( errbuf          IN OUT NOCOPY VARCHAR2,
                                 retcode         IN OUT NOCOPY NUMBER,
                                 p_mode          IN     VARCHAR2)
   IS

     p_mrc_schema_name         VARCHAR2(30);
     p_mls_schema_name         VARCHAR2(30);

   BEGIN
       errbuf  := NULL;
       retcode := 0;

       write_to_log (l_state_level, 'apply_security', 'BEGIN  Apply Security - Parameter passed in - '|| p_mode );

       -- Get the MRC, MLS schema names.

       get_mrc_mls_schemanames ( p_mls_schema_name,
                                 p_mrc_schema_name,
                                 errbuf,
                                 retcode );



       IF    p_mode  = 'CREATE'
       AND   retcode = 0
       THEN
           -- Call Procedure to create and drop objects
           create_drop_sls_objects ( p_mls_schema_name,
                                     p_mrc_schema_name,
                                     errbuf,
                                     retcode );


           -- If successful, call procedure to consolidate groups
           IF retcode = 0
           THEN
               consolidate_groups (errbuf,
                                   retcode);
           END IF;

           -- If successful, call procedure to populate the allocation table
           IF retcode = 0
           THEN
               populate_group_alloc (errbuf,
                                     retcode);
           END IF;

           -- If successful, call procedure to stamp records with the date_security_applied
           IF retcode = 0
           THEN
               stamp_records (errbuf,
                             retcode);
           END IF;

           -- If successful, call procedure to clean up data in the tables.
           IF retcode = 0
           THEN
               cleanup_data (errbuf,
                             retcode);
           END IF;

       ELSIF p_mode  = 'REFRESH'
       AND   retcode = 0
       THEN
           -- call procedure to refresh objects
           refresh_sls_objects     ( p_mls_schema_name,
                                     p_mrc_schema_name,
                                     errbuf,
                                     retcode);
       END IF;

       write_to_log (l_state_level, 'apply_security', 'END  Apply Security - Completed');

   END  apply_security   ;



  /*---------------------------------------------------------------------
   This procedure secures existing data
   Written for Enhancement Request 2263845
   Parameters :
   Input  :  p_sls_group - SLS group for which this process needs to run
   Output :  errbuf      - Exit error message
             retcode     - Return code for the procedure.
                           0 - Success
                           1 - Warning
                           2 - Failure
  ---------------------------------------------------------------------*/
   PROCEDURE secure_existing_data ( errbuf          IN OUT NOCOPY VARCHAR2,
                                    retcode         IN OUT NOCOPY NUMBER,
                                    p_sec_grp       IN     VARCHAR2)
   IS

   CURSOR c_sec_dat IS
   SELECT a.sls_table_name,
          b.table_name,
          b.sls_security_group,
          a.owner,
          Nvl(a.optimise_sql,'N') optimise_sql
   FROM   igi_sls_secure_tables a,
          igi_sls_security_group_alloc b
   WHERE  a.table_name         = b.table_name
   AND    b.sls_security_group = Nvl(p_sec_grp  , b.sls_security_group);

   CURSOR c_chk_tab IS
   SELECT DISTINCT a.table_name
   FROM   igi_sls_security_group_alloc a
   WHERE  a.table_name in (SELECT table_name
                           FROM   igi_sls_security_group_alloc
                           GROUP BY table_name
                           HAVING COUNT(*) > 1)
   AND    a.sls_security_group =  Nvl(p_sec_grp  , a.sls_security_group);


   l_count                            NUMBER := 0;
   l_dup_tabs_exist                   BOOLEAN := FALSE;
   l_sql_stmt                         VARCHAR2(2000);

   l_schema            fnd_oracle_userid.oracle_username%TYPE;
   l_prod_status       fnd_product_installations.status%TYPE;
   l_industry          fnd_product_installations.industry%TYPE;


   -- Exceptions
   igi_sls_sec_not_applied_excep      EXCEPTION;


   BEGIN
      IF NOT fnd_installation.get_app_info (application_short_name => 'IGI',
                        status                  => l_prod_status,
                        industry                => l_industry,
                        oracle_schema           => l_schema)
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;

      -- Check if Security has been applied
      SELECT COUNT(*)
      INTO   l_count
      FROM   igi_sls_secure_tables a,
             all_objects    b
      WHERE  a.sls_table_name = b.object_name
      AND b.owner = l_schema;  -- Bug 3431843 hkaniven

      IF l_count = 0
      THEN
          RAISE igi_sls_sec_not_applied_excep;
      END IF;

      -- Check if there are tables that belong to more than 1
      -- security group. If there are , print all of them onto
      -- the log and then raise exception.
      FOR l_chk_tab IN c_chk_tab
      LOOP
         l_dup_tabs_exist := TRUE;

         fnd_message.set_name('IGI','IGI_SLS_DUP_ALLOC_EXISTS');
         fnd_message.set_token('TAB_NAME',l_chk_tab.table_name);
         Write_to_log(l_state_level, 'secure_existing_data',Fnd_Message.Get);

      END LOOP ;

      -- Get the tables for which the data needs to be made secure
      write_to_log (l_state_level, 'secure_existing_data','Securing existing data for all enabled tables ..  ');
      FOR l_sec_dat IN c_sec_dat
      LOOP
          write_to_log (l_state_level, 'secure_existing_data','Processing  '||l_sec_dat.table_name);

          IF l_sec_dat.optimise_sql = 'N'
          THEN
              -- All Validations passed, insert data.
/*
              l_sql_stmt := ' INSERT INTO '||l_sec_dat.sls_table_name ||
                            ' (sls_rowid, sls_sec_grp) ' ||
                            ' SELECT rowid, ' ||
                            ''''||l_sec_dat.sls_security_group||'''' ||
                            ' FROM '|| l_sec_dat.table_name || ' a ' ||
                            ' WHERE NOT EXISTS (SELECT ''X''' ||
                                             '  FROM '||l_sec_dat.sls_table_name ||' b' ||
                                             '  WHERE a.rowid = b.sls_rowid )';

*/
              l_sql_stmt := ' INSERT INTO '||l_sec_dat.sls_table_name ||
                            ' (sls_rowid, sls_sec_grp) ' ||
                            ' SELECT rowid, ' ||
                            ' :sls_security_group' ||
                            ' FROM '|| l_sec_dat.table_name || ' a ' ||
                            ' WHERE NOT EXISTS (SELECT ''X''' ||
                                             '  FROM '||l_sec_dat.sls_table_name ||' b' ||
                                             '  WHERE a.rowid = b.sls_rowid )';

              EXECUTE IMMEDIATE l_sql_stmt USING l_sec_dat.sls_security_group;
          ELSE
              -- User should have disabled SLS before they did this.
              -- Else, the update wont work.
/*
              l_sql_stmt := ' UPDATE ' || l_sec_dat.table_name ||
                            ' SET igi_sls_sec_group = '||''''||l_sec_dat.sls_security_group||''''||
                            ' WHERE igi_sls_sec_group IS NULL ';
*/
              l_sql_stmt := ' UPDATE ' || l_sec_dat.table_name ||
                            ' SET igi_sls_sec_group = :sls_security_group'||
                            ' WHERE igi_sls_sec_group IS NULL ';

              EXECUTE IMMEDIATE l_sql_stmt USING l_sec_dat.sls_security_group;

          END IF;

          IF l_sec_dat.optimise_sql = 'N'
          THEN
              -- Create Index, as they might not be present if User had already
              -- installed SLS
              igi_sls_objects_pkg.create_sls_inx
                          (sls_tab                  => l_sec_dat.sls_table_name,
                           errbuf                   => errbuf,
                           retcode                  => retcode);
          ELSE
              igi_sls_objects_pkg.create_sls_core_inx
                 (sec_tab         => l_sec_dat.table_name,
                  sls_tab         => l_sec_dat.sls_table_name,
                  schema_name     => l_sec_dat.owner,
                  errbuf          => errbuf,
                  retcode         => retcode);
          END IF;

          COMMIT;
      END LOOP;

      EXCEPTION

      WHEN igi_sls_sec_not_applied_excep
      THEN
          fnd_message.set_name('IGI','IGI_SLS_SEC_NOT_APPLIED');
          errbuf  := fnd_message.get;
          write_to_log(l_excep_level, 'secure_existing_data',errbuf);
          retcode := 2;
          RETURN;

      WHEN OTHERS
      THEN

	  FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
	  errbuf :=  Fnd_message.get;

          write_to_log ( l_excep_level, 'secure_existing_data','END  Procedure Secure Existing data - failed with error '|| SQLERRM );
          ROLLBACK;
          retcode := 2;
          RETURN;

   END secure_existing_data;



END igi_sls_security_pkg ;

/
