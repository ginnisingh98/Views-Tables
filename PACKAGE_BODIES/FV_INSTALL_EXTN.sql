--------------------------------------------------------
--  DDL for Package Body FV_INSTALL_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_INSTALL_EXTN" AS
-- $Header: FVXPIXTB.pls 120.14 2007/01/10 16:05:51 agovil ship $

PROCEDURE insert_ap_income_tax_types;
PROCEDURE Load_FV_Ldts;

g_module_name varchar2(100);
vp_retcode NUMBER;
vp_errbuf  VARCHAR2(1000);
l_req_id   NUMBER;
l_module_name VARCHAR2(200);

PROCEDURE Run_Process
(
  errbuf                      OUT NOCOPY      VARCHAR2,
  retcode                     OUT NOCOPY      VARCHAR2
)
IS
  --
  l_config_file               VARCHAR2(100);
  l_fnd_config_file           VARCHAR2(100);
  l_language		      VARCHAR2(20);
  l_data_file		      VARCHAR2(100);
  l_errbuf varchar2(300);
  l_retval                    BOOLEAN;
  l_org_id		      NUMBER(15);	--PSKI MOAC Changes
  --
  cursor  c_territory is select iso_territory
			   from fnd_languages
			  where installed_flag  = 'B';
/* removed the installed_flag = 'I' to fix the issue of looking for top_dir for 'I' read
  loader file*/

  -- Check if profile is enabled at User/Responsibility level.
  CURSOR c_prof_enabled IS
  SELECT resp_enabled_flag, user_enabled_flag
  FROM fnd_profile_options
  WHERE profile_option_name = 'FV_ENABLED';

  l_resp_flag fnd_profile_options.resp_enabled_flag%TYPE;
  l_user_flag fnd_profile_options.user_enabled_flag%TYPE;

BEGIN
  g_module_name     := 'fv.plsql.fv_install_extn.';
  l_module_name     := g_module_name || 'run_process';
  l_config_file     := '@FV:patch/115/import/';
  l_fnd_config_file := '@FND:patch/115/import/';
  l_org_id  	    := MO_GLOBAL.get_current_org_id;	--PSKI MOAC Changes
  l_resp_flag       := 'N';
  l_user_flag       := 'N';

  -- Check whether the FV_ENABLED profile is enabled for a responsibility/user
  OPEN c_prof_enabled;
  FETCH c_prof_enabled INTO l_resp_flag, l_user_flag;
  CLOSE c_prof_enabled;

  IF ((l_resp_flag = 'Y') OR (l_user_flag = 'Y')) THEN

    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
    'Note: As profile ''FV: Federal Enabled'' is enabled at Responsibility/User level,
      we will not set the value of profile at Site level.');

  ELSE
    -- Bug#4533611
    -- The following line is added to enable the profile
    -- FV_ENABLED to Y as this process will be run only
    -- by federal customers
    l_retval := fnd_profile.save ('FV_ENABLED', 'Y', 'SITE');

  END IF;

  --
  SAVEPOINT Run_Process_PVT ;
  --
  -- Load Seed Data for each of the installed languages

  for c_territory_rec in c_territory loop

      l_language  := c_territory_rec.iso_territory ;

      -- Load lookup AP data

      l_data_file := l_config_file||l_language||'/fvaplkup.ldt';

        FND_REQUEST.set_org_id(l_org_id);	  --PSKI MOAC Changes
	l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
			  argument1	=> 'UPLOAD',
			  argument2	=> l_fnd_config_file||'aflvmlu.lct',
			  argument3	=> l_data_file);

      if l_req_id = 0 then

         errbuf  := fnd_message.get ;
         retcode := 2 ;
         raise fnd_api.g_exc_error ;

      end if;

-- Load lookup AR data

      l_data_file := l_config_file||l_language||'/fvarlkup.ldt';

        FND_REQUEST.set_org_id(l_org_id);	  --PSKI MOAC Changes
	l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_fnd_config_file||'aflvmlu.lct',
                          argument3     => l_data_file);

      if l_req_id = 0 then

         errbuf  := fnd_message.get ;
         retcode := 2 ;
         raise fnd_api.g_exc_error ;

      end if;

      -- Load GL categories

      l_data_file := l_config_file||l_language||'/fvglcat.ldt';

        FND_REQUEST.set_org_id(l_org_id);	  --PSKI MOAC Changes
	l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
			  argument1	=> 'UPLOAD',
			  argument2	=> l_config_file||'fvglcat.lct',
			  argument3	=> l_data_file);

      if l_req_id = 0 then

         errbuf  := fnd_message.get ;
         retcode := 2 ;
         raise fnd_api.g_exc_error ;

      end if;
      -- Load GL Sources

      l_data_file := l_config_file||l_language||'/fvglsrc.ldt';

        FND_REQUEST.set_org_id(l_org_id);	  --PSKI MOAC Changes
	l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
			  argument1	=> 'UPLOAD',
			  argument2	=> l_config_file||'fvglsrc.lct',
			  argument3	=> l_data_file);

      if l_req_id = 0 then

         errbuf  := fnd_message.get ;
         retcode := 2 ;
         raise fnd_api.g_exc_error ;

      end if;

  end loop ;

  insert_ap_income_tax_types;

  -- Call this procedure to reload ldts after fvdelapi.sql run
  -- This ensure that all the dropped AOL objects are re-created
  -- This design also avoids dummy checkin creation for loader files.
  -- Commented out as it this is causing errors.
  --Load_FV_Ldts;

  retcode := 0 ;

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Run_Process_PVT ;
    retcode := 2 ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Run_Process_PVT ;
    retcode := 2 ;
    --
  WHEN OTHERS THEN
    --
    l_errbuf := sqlerrm;
    ROLLBACK TO Run_Process_PVT ;
    retcode := 2 ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',l_errbuf);
    --
END Run_Process ;

-- Procedure to insert income tax types

PROCEDURE insert_ap_income_tax_types IS
l_module_name varchar2(200);
l_errbuf varchar2(300);
BEGIN

g_module_name := 'fv.plsql.fv_install_extn.';
l_module_name := g_module_name || 'insert_ap_income_tax_types';

INSERT INTO ap_income_tax_types
(income_tax_type,
description,
last_update_date,
last_updated_by,
last_update_login,
creation_date,
created_by)
(SELECT 'GOV 1','Unemployment compensation',sysdate,1,1,sysdate,1
FROM DUAL
WHERE NOT EXISTS
            (SELECT 'x'
                   FROM ap_income_tax_types
                   WHERE income_tax_type = 'GOV 1'
                   AND      description = 'Unemployment compensation'));

INSERT INTO ap_income_tax_types
(income_tax_type,
description,
last_update_date,
last_updated_by,
last_update_login,
creation_date,
created_by)
(SELECT 'GOV 6','Taxable grants',sysdate,1,1,sysdate,1
FROM DUAL
WHERE NOT EXISTS
            (SELECT 'x'
             FROM ap_income_tax_types
             WHERE income_tax_type = 'GOV 6'
             AND     description = 'Taxable grants'));

INSERT INTO ap_income_tax_types
(income_tax_type,
description,
last_update_date,
last_updated_by,
last_update_login,
creation_date,
created_by)
(SELECT 'GOV 6A','Energy grants',sysdate,1,1,sysdate,1
FROM DUAL
WHERE NOT EXISTS
            (SELECT 'x'
             FROM ap_income_tax_types
             WHERE income_tax_type = 'GOV 6A'
             AND     description = 'Energy grants'));

INSERT INTO ap_income_tax_types
(income_tax_type,
description,
last_update_date,
last_updated_by,
last_update_login,
creation_date,
created_by)
(SELECT 'GOV 7','Agriculture payments',sysdate,1,1,sysdate,1
FROM DUAL
WHERE NOT EXISTS
            (SELECT 'x'
             FROM ap_income_tax_types
             WHERE income_tax_type = 'GOV 7'
             AND     description = 'Agriculture payments'));

INSERT INTO ap_income_tax_types
(income_tax_type,
description,
last_update_date,
last_updated_by,
last_update_login,
creation_date,
created_by)
(SELECT 'INT 1','Interest income not included in box 3',sysdate,1,1,sysdate,1
FROM DUAL
WHERE NOT EXISTS
            (SELECT 'x'
             FROM ap_income_tax_types
             WHERE income_tax_type = 'INT 1'
              AND     description = 'Interest income not included in box 3'));

INSERT INTO ap_income_tax_types
(income_tax_type,
description,
last_update_date,
last_updated_by,
last_update_login,
creation_date,
created_by)
(SELECT 'INT 1A','Financial institution interest income not included in box 3',
        sysdate,1,1,sysdate,1
FROM DUAL
WHERE NOT EXISTS
 (SELECT 'x'
  FROM ap_income_tax_types
  WHERE income_tax_type = 'INT 1A'
  AND   description = 'Financial institution interest income not included in box
 3'));

INSERT INTO ap_income_tax_types
(income_tax_type,
description,
last_update_date,
last_updated_by,
last_update_login,
creation_date,
created_by)
(SELECT 'INT 3','Interest on U.S. Savings Bonds and Treasury obligations',
        sysdate,1,1,sysdate,1
FROM DUAL
WHERE NOT EXISTS
  (SELECT 'x'
   FROM ap_income_tax_types
   WHERE income_tax_type = 'INT 3'
   AND description = 'Interest on U.S. Savings Bonds and Treasury obligations'))
;

EXCEPTION WHEN OTHERS THEN
l_errbuf := sqlerrm;
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',l_errbuf);
NULL;

END insert_ap_income_tax_types;

-- Bug# 3578880
-- This procedure loads fvmenus.ldt, fvlkups.ldt, fvcprog.ldt, fvreqst.ldt
-- fvreqln.ldt and fvreqgr.ldt for all the langauges found in fnd_languages
-- with installed flag of I/B.
--
PROCEDURE Load_FV_Ldts AS
  l_config_file     VARCHAR2(100) ;
  l_fnd_config_file VARCHAR2(100) ;
  l_data_file 	    VARCHAR2(100);
  l_cntrl_file 	    VARCHAR2(100);
  l_language        VARCHAR2(20);
  i		    NUMBER;
  l_org_id	    NUMBER(15);		--PSKI MOAC Changes

--Bug#3739019
/*
  CURSOR  c_territory IS select iso_territory
                         from fnd_languages
                         where installed_flag in ('I', 'B');
*/

BEGIN
  l_config_file  :=   '@FV:patch/115/import/';
  l_fnd_config_file := '@FND:patch/115/import/';
  g_module_name := 'fv.plsql.fv_install_extn.';
  l_module_name := g_module_name || 'load_fv_ldts';

--Bug#3739019
/*
  -- Load Seed Data for each of the installed languages
  FOR c_territory_rec IN c_territory
  LOOP 		-- language
      l_language  := c_territory_rec.iso_territory;
*/
      l_language  := 'US';

      FOR i IN 1..6
      LOOP	-- ldts
         IF i = 1
         THEN
            l_data_file := l_config_file||l_language||'/fvmenus.ldt';
            l_cntrl_file:= l_fnd_config_file||'afsload.lct';
         ELSIF i = 2
         THEN
            l_data_file := l_config_file||l_language||'/fvlkups.ldt';
            l_cntrl_file:= l_fnd_config_file||'aflvmlu.lct';
         ELSIF i = 3
         THEN
            l_data_file := l_config_file||l_language||'/fvcprog.ldt';
            l_cntrl_file:= l_fnd_config_file||'afcpprog.lct';
         ELSIF i = 4
         THEN
            l_data_file := l_config_file||l_language||'/fvreqst.ldt';
            l_cntrl_file:= l_fnd_config_file||'afcprset.lct';
         ELSIF i = 5
         THEN
            l_data_file := l_config_file||l_language||'/fvreqln.ldt';
            l_cntrl_file:= l_fnd_config_file||'afcprset.lct';
         ELSIF i = 6
         THEN
            l_data_file := l_config_file||l_language||'/fvreqgr.ldt';
            l_cntrl_file:= l_fnd_config_file||'afcpreqg.lct';
         END IF;

	 l_org_id := MO_GLOBAL.get_current_org_id;	 --PSKI MOAC Changes
	 FND_REQUEST.set_org_id(l_org_id);		 --PSKI MOAC Changes
         l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_cntrl_file,
                          argument3     => l_data_file);

         IF l_req_id = 0
         THEN
            vp_errbuf  := fnd_message.get;
            vp_retcode := -1;
            raise fnd_api.g_exc_error;
         END IF;
      END LOOP; -- ldts
--Bug#3739019
/*
   END LOOP; -- language
*/

EXCEPTION
   WHEN OTHERS THEN
	vp_errbuf := 'Error in Procedure Load_FV_Ldts: '|| sqlerrm;
	FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',vp_errbuf);
END Load_FV_Ldts;

END FV_Install_Extn ;

/
