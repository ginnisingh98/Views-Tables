--------------------------------------------------------
--  DDL for Package Body GMS_INSTALL_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_INSTALL_EXTN" AS
/* $Header: gmspixtb.pls 115.6 2002/11/25 23:35:26 jmuthuku ship $ */

PROCEDURE Run_Process
(
  errbuf                      OUT NOCOPY      VARCHAR2,
  retcode                     OUT NOCOPY      VARCHAR2
)
IS
  --
  l_config_file               VARCHAR2(100) := '@GMS:patch/115/import/';
  l_language		      VARCHAR2(20)  ;
  l_data_file		      VARCHAR2(100) ;
  l_req_id		      NUMBER ;
  --
  cursor  c_territory is select language_code
			   from fnd_languages
			  where installed_flag in ('I', 'B');

BEGIN
  --
  SAVEPOINT Run_Process_PVT ;
  --
  l_req_id := fnd_request.submit_request
			 (program 	=> 'GMSPIDRV',
			  application	=> 'GMS',
			  description	=> NULL,
			  start_time	=> NULL,
			  sub_request	=> FALSE);

  if l_req_id = 0 then

    errbuf  := fnd_message.get ;
    retcode := 2 ;
    raise fnd_api.g_exc_error ;

  end if;


  -- Load Seed Data for each of the installed languages

  for c_territory_rec in c_territory loop

      l_language  := c_territory_rec.language_code ;

      -- Load lookup PA data

      l_data_file := l_config_file||l_language||'/gmspilkp.ldt';

      l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
			  argument1	=> 'UPLOAD',
			  argument2	=> l_config_file||'gmspilkp.lct',
			  argument3	=> l_data_file);

      if l_req_id = 0 then

         errbuf  := fnd_message.get ;
         retcode := 2 ;
         raise fnd_api.g_exc_error ;

      end if;

      -- Load lookup PA budget entry methods

      l_data_file := l_config_file||l_language||'/gmspibem.ldt';

      l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
			  argument1	=> 'UPLOAD',
			  argument2	=> l_config_file||'gmspibem.lct',
			  argument3	=> l_data_file);

      if l_req_id = 0 then

         errbuf  := fnd_message.get ;
         retcode := 2 ;
         raise fnd_api.g_exc_error ;

      end if;

      -- Load lookup PA event types

      l_data_file := l_config_file||l_language||'/gmspievt.ldt';

      l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
			  argument1	=> 'UPLOAD',
			  argument2	=> l_config_file||'gmspievt.lct',
			  argument3	=> l_data_file);

      if l_req_id = 0 then

         errbuf  := fnd_message.get ;
         retcode := 2 ;
         raise fnd_api.g_exc_error ;

      end if;
      -- Load lookup PA billing extensions

      l_data_file := l_config_file||l_language||'/gmspiblx.ldt';

      l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
			  argument1	=> 'UPLOAD',
			  argument2	=> l_config_file||'gmspiblx.lct',
			  argument3	=> l_data_file);

      if l_req_id = 0 then

         errbuf  := fnd_message.get ;
         retcode := 2 ;
         raise fnd_api.g_exc_error ;

      end if;

      -- Load lookup PA transaction sources GOLD, GOLDE

      l_data_file := l_config_file||l_language||'/gmspitxn.ldt';

      l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
			  argument1	=> 'UPLOAD',
			  argument2	=> l_config_file||'gmspitxn.lct',
			  argument3	=> l_data_file);

      if l_req_id = 0 then

         errbuf  := fnd_message.get ;
         retcode := 2 ;
         raise fnd_api.g_exc_error ;

      end if;
  end loop ;

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
    ROLLBACK TO Run_Process_PVT ;
    retcode := 2 ;
    --
END Run_Process ;

END GMS_Install_Extn ;

/
