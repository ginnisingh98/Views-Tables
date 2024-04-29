--------------------------------------------------------
--  DDL for Package Body CN_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMPORT_PVT" AS
-- $Header: cnvimpb.pls 120.3 2005/08/17 21:46:28 kjayapau noship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'CN_IMPORT_PVT';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvimpb.pls';

--
--    API name        : get_imp_type_code
--
FUNCTION get_imp_type_code (p_imp_header_id IN NUMBER)
  RETURN VARCHAR2
  IS
     l_imp_type_code VARCHAR2(30) := NULL ;
BEGIN

   SELECT import_type_code INTO l_imp_type_code
     FROM cn_imp_headers
     WHERE imp_header_id = p_imp_header_id;

   RETURN l_imp_type_code;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_imp_type_code;

-- --------------------------------------------------------+
--  upd_impline_recnum
--
--  This procedure will update cn_imp_lines record_num
-- --------------------------------------------------------+
PROCEDURE upd_impline_recnum
  (p_imp_header_id IN NUMBER) IS
     PRAGMA AUTONOMOUS_TRANSACTION;

     CURSOR c_imp_lines_csr IS
	SELECT imp_line_id FROM cn_imp_lines
	  WHERE imp_header_id = p_imp_header_id
	  ORDER BY imp_line_id;

     l_count NUMBER := 0;

BEGIN
   FOR l_imp_lines_csr IN c_imp_lines_csr LOOP
      l_count := l_count + 1;
      UPDATE cn_imp_lines
	SET record_num = l_count
	WHERE imp_line_id = l_imp_lines_csr.imp_line_id
	;
   END LOOP;
   COMMIT;

END upd_impline_recnum;


-- Start of comments
--    API name        : Import_Data
--    Type            : Private.
--    Function        : Main program to call all the concurrent programs
--                      to transfer data from datafile to stage table then to
--                      destination table
--    Pre-reqs        : None.
--    Parameters      :
--    Version :         Current version       1.0
-- End of comments

PROCEDURE Import_Data
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_header_id           IN    NUMBER,
   p_user_id                 IN    NUMBER,  -- setting the session context.
   p_resp_id                 IN    NUMBER,  -- setting the session context.
   p_app_id                  IN    NUMBER,  -- setting the session context.
   p_control_file            IN    VARCHAR2,
   x_request_id              OUT NOCOPY   NUMBER,
   p_org_id		     IN NUMBER
   ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Import_Data';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_request_id    	NUMBER;
      l_imp_type_code               VARCHAR2(30);
      l_imp_header                  cn_imp_headers_pvt.imp_headers_rec_type := cn_imp_headers_pvt.G_MISS_IMP_HEADERS_REC;
      l_process_audit_id cn_process_audits.process_audit_id%TYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Import_Data;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body
   l_imp_type_code := get_imp_type_code(p_imp_header_id);
   SELECT name, status_code,server_flag
     INTO l_imp_header.name ,l_imp_header.status_code  ,
     l_imp_header.server_flag
     FROM cn_imp_headers
     WHERE imp_header_id = p_imp_header_id;

   -- open process audit batch
   cn_message_pkg.begin_batch
     ( x_process_type	=> l_imp_type_code,
       x_parent_proc_audit_id  => p_imp_header_id ,
       x_process_audit_id	=>  l_process_audit_id,
       x_request_id		=> null,
       p_org_id			=> p_org_id);

   cn_message_pkg.write
     (p_message_text    => 'Importing ' || l_imp_header.name,
      p_message_type    => 'MILESTONE'
      );
  ----------------------------------------------+
   -- Set the session context equal to the
   -- calling procedure.
   -- NOTE: The session context needs to be
   -- set at the PL/SQL level because the JSP
   -- connection object did not include the
   -- session context, so all calls through the
   -- connection object are equivalent to calls
   -- from a regular database login, not an
   -- Apps session.  Once this is fixed, we can
   -- remove the call to apps_initialize.
   ----------------------------------------------+
   FND_GLOBAL.apps_initialize
     (user_id        => p_user_id,
      resp_id        => p_resp_id,
      resp_appl_id   => p_app_id
      );

   IF l_imp_header.server_flag = 'Y' THEN
      -- Server Side Import. Need to Stage.
      -- SQL*LOADER call to populate the data in OIC tables.
      --

      FND_REQUEST.SET_ORG_ID(p_org_id);

      l_request_id :=
	FND_REQUEST.SUBMIT_REQUEST
	(application   => 'CN',
	 program       => 'CNIMPDS',
	 argument1     => p_imp_header_id,
	 argument2     => p_control_file,
	 argument3     => p_org_id
	 );

      IF l_request_id = 0 THEN
	 update_imp_headers
	   (p_imp_header_id => p_imp_header_id,
	    p_status_code => 'FAIL');
	 cn_message_pkg.write
	   (p_message_text    => 'CNIMPDS submission fail.',
	    p_message_type    => 'ERROR');
	 RAISE FND_API.g_exc_unexpected_error;
      END IF;

      cn_message_pkg.write
	(p_message_text    => 'Staging Concurrent Program CNIMPDS Started.REQ = '|| l_request_id,
	 p_message_type    => 'MILESTONE'
	 );

      x_request_id := l_request_id;

    ELSE
      -- Client Side Import. Stage Completed.
      -- Load_Data call to transfer from stage to target.
      --
      cn_message_pkg.debug('Status = '|| l_imp_header.status_code);

      IF l_imp_header.status_code = 'STAGE' THEN

      	 FND_REQUEST.SET_ORG_ID(p_org_id);

	 l_request_id :=
	   FND_REQUEST.SUBMIT_REQUEST
	   (application   => 'CN',
	    program       => 'CNIMPST',
	    argument1     => p_imp_header_id,
	    argument2     => p_org_id
	    );

	 IF l_request_id = 0 THEN
	    update_imp_headers
	      (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'FAIL');
	    cn_message_pkg.write
	      (p_message_text    => 'CNIMPST submission fail.',
	       p_message_type    => 'ERROR');
	    RAISE FND_API.g_exc_unexpected_error;
	 END IF;

	 cn_message_pkg.write
	   (p_message_text    => 'Loading Concurrent Program CNIMPST Started.REQ = '|| l_request_id,
	    p_message_type    => 'MILESTONE'
	    );

	 x_request_id := l_request_id;
      END IF;
   END IF;

  -- close process batch
  cn_message_pkg.end_batch(l_process_audit_id);

  -- End of API body.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.count_and_get
    (p_count   =>  x_msg_count ,
     p_data    =>  x_msg_data  ,
     p_encoded => FND_API.G_FALSE
     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Import_Data  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      cn_message_pkg.end_batch(l_process_audit_id);
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Import_Data ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      cn_message_pkg.end_batch(l_process_audit_id);
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Import_Data ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      cn_message_pkg.set_error(l_api_name,'Unexpected error');
      cn_message_pkg.end_batch(l_process_audit_id);
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
END import_data;

-- Start of comments
--    API name        : Export_Data
--    Type            : Private.
--    Function        : Main program to call all the concurrent programs
--                      to transfer data from destination file to stage table
--    Pre-reqs        : None.
--    Version :         Current version       1.0
-- End of comments
PROCEDURE Export_Data
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_header_id           IN    NUMBER,
   p_user_id                 IN    NUMBER,  -- setting the session context.
   p_resp_id                 IN    NUMBER,  -- setting the session context.
   p_app_id                  IN    NUMBER,  -- setting the session context.
   x_request_id              OUT NOCOPY   NUMBER,
   p_org_id		     IN NUMBER) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Export_Data';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_request_id    	NUMBER;
      l_imp_type_code   VARCHAR2(30);
      l_name            VARCHAR2(30);
      l_status_code     VARCHAR2(30);
      l_conc_pgm        VARCHAR2(150);
      l_process_audit_id cn_process_audits.process_audit_id%TYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Export_Data;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body

   l_imp_type_code := get_imp_type_code(p_imp_header_id);

   SELECT name, status_code
     INTO l_name ,l_status_code
     FROM cn_imp_headers
    WHERE imp_header_id = p_imp_header_id;

   SELECT export_conc_program
     INTO l_conc_pgm
     FROM cn_import_types
    WHERE import_type_code = l_imp_type_code;

   -- open process audit batch
   cn_message_pkg.begin_batch
     ( x_process_type	       => l_imp_type_code,
       x_parent_proc_audit_id  => p_imp_header_id ,
       x_process_audit_id      => l_process_audit_id,
       x_request_id	       => null,
       p_org_id			=> p_org_id);

   cn_message_pkg.write
     (p_message_text    => 'Exporting ' || l_name,
      p_message_type    => 'MILESTONE');

  ----------------------------------------------+
   -- Set the session context equal to the
   -- calling procedure.
   -- NOTE: The session context needs to be
   -- set at the PL/SQL level because the JSP
   -- connection object did not include the
   -- session context, so all calls through the
   -- connection object are equivalent to calls
   -- from a regular database login, not an
   -- Apps session.  Once this is fixed, we can
   -- remove the call to apps_initialize.
   ----------------------------------------------+
   FND_GLOBAL.apps_initialize
     (user_id        => p_user_id,
      resp_id        => p_resp_id,
      resp_appl_id   => p_app_id);

   -- say request has been submitted
   update_imp_headers
     (p_imp_header_id => p_imp_header_id,
      p_status_code => 'SUBMIT');

   -- Call request to export data to the stage table

   FND_REQUEST.SET_ORG_ID(p_org_id);

   l_request_id :=
     FND_REQUEST.SUBMIT_REQUEST
     (application   => 'CN',
      program       => l_conc_pgm,
      argument1     => p_imp_header_id,
      argument2     => p_org_id);

   IF l_request_id = 0 THEN
      update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'FAIL');
      cn_message_pkg.write
	(p_message_text    => l_conc_pgm || ' submission fail.',
	 p_message_type    => 'ERROR');
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   cn_message_pkg.write
     (p_message_text    => 'Loading Concurrent Program ' || l_conc_pgm ||
                           ' Started.REQ = '|| l_request_id,
      p_message_type    => 'MILESTONE');

   x_request_id := l_request_id;

   -- close process batch
   cn_message_pkg.end_batch(l_process_audit_id);

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get
     (p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Export_Data  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      cn_message_pkg.end_batch(l_process_audit_id);
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Export_Data ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      cn_message_pkg.end_batch(l_process_audit_id);
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Export_Data ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      cn_message_pkg.set_error(l_api_name,'Unexpected error');
      cn_message_pkg.end_batch(l_process_audit_id);
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
END Export_Data;

-- --------------------------------------------------------+
-- This program invokes sql*loader from concurrent program
-- to populate the data from the data file to the OIC application.
-- --------------------------------------------------------+

PROCEDURE Server_Stage_data
  (errbuf                     OUT NOCOPY   VARCHAR2,
   retcode                    OUT NOCOPY   NUMBER,
   p_imp_header_id            IN    NUMBER,
   p_control_file             IN    VARCHAR2,
   p_org_id		     IN NUMBER
   ) IS

  L_SQL_LOADER      		CONSTANT VARCHAR2(30) := 'SQL*Loader';
  l_short_name      		 	 VARCHAR2(30);
  l_request_id      			 NUMBER;
  l_wait_status        		 BOOLEAN;
  l_phase              		 VARCHAR2(30);
  l_status             		 VARCHAR2(30);
  l_start_time                   DATE;
  l_dev_phase          		 VARCHAR2(30);
  l_dev_status         		 VARCHAR2(30);
  l_message            		 VARCHAR2(240);
  l_loaded_rows        		 NUMBER;
  l_imp_header                  cn_imp_headers_pvt.imp_headers_rec_type := cn_imp_headers_pvt.G_MISS_IMP_HEADERS_REC;
  l_imp_type_code               VARCHAR2(30);
  l_msg_count                           NUMBER := 0;
  l_process_audit_id cn_process_audits.process_audit_id%TYPE;
  l_api_name     CONSTANT VARCHAR2(30) := 'Server_Stage_data';
  l_api_version  CONSTANT NUMBER  := 1.0;
  err_num   NUMBER;

  CURSOR c_loaded_rows IS
  SELECT COUNT(*)
  FROM   cn_imp_lines
  WHERE  imp_header_id = p_imp_header_id;

BEGIN
   -- Standard Start of API savepoint
   --  Initialize API return status to success
   -- API body

   update_imp_headers
     (p_imp_header_id => p_imp_header_id,
      p_status_code => 'SUBMIT');

   retcode := 0;  -- no problems. 1= warning, 2  = fail
   l_imp_type_code := get_imp_type_code(p_imp_header_id);

   -- For SQL*Loader programs, the executable file name is equivalent to the
   -- control file.  The field "Executable" on the screen is the same as
   -- "program" in the API.  We will use the short name for both program and
   -- program short name.

   l_short_name := 'CN' || FND_GLOBAL.LOGIN_ID || 'IMP' || p_imp_header_id;

   SELECT name, status_code,server_flag
     INTO l_imp_header.name ,l_imp_header.status_code ,
     l_imp_header.server_flag
     FROM cn_imp_headers
     WHERE imp_header_id = p_imp_header_id;

   -- open process audit batch
   cn_message_pkg.begin_batch
     ( x_process_type	=> l_imp_type_code,
       x_parent_proc_audit_id  => p_imp_header_id ,
       x_process_audit_id	=>  l_process_audit_id,
       x_request_id		=> null,
       p_org_id			=> p_org_id);

   cn_message_pkg.write
     (p_message_text    => 'Start Server Staging Data : Server_Stage_data - ' || l_short_name,
      p_message_type    => 'MILESTONE'
      );

   -- Start Staging Data
   IF l_imp_header.status_code = 'SUBMIT' AND l_imp_header.server_flag = 'Y' THEN
      -- For SQL*Loader Conc Pgm,the control must locate at $CN_TOP/bin/
      -- the execution_file_name cannot include any . or space
      -- Create the Executable entry.
      FND_PROGRAM.EXECUTABLE
	( executable           => l_short_name,
	  application          => 'CN',
	  short_name           => l_short_name,
	  description          => l_imp_header.name,
	  execution_method     => L_SQL_LOADER,
	  execution_file_name  => p_control_file,
	  language_code        => USERENV ('LANG')
	  );

      cn_message_pkg.debug('Staging Data : Conc Executable Created - ' || l_short_name);

      -- Register the concurrent program.
      FND_PROGRAM.REGISTER
	(program                 => l_short_name,
	 application             => 'CN',
	 enabled                 => 'Y',
	 short_name              => l_short_name,
	 executable_short_name   => l_short_name,
	 executable_application  => 'CN',
	 language_code           => USERENV ('LANG')
	 );

      cn_message_pkg.debug('Staging Data : Conc Program Created - ' || l_short_name);

      -- Since this is a SQL*Loader concurrent program,
      -- we don't need to specify other parameters.  The
      -- only other parameter would be the data file name,
      -- but we will include that in the control file.
      --
      l_request_id := FND_REQUEST.SUBMIT_REQUEST
	(application      => 'CN',
	 program          => l_short_name
	 );

      IF l_request_id = 0 THEN
	 FND_MESSAGE.set_name ('CN', 'CN_IMP_DS_SUBMIT_FAIL');
	 cn_message_pkg.write
	   (p_message_text => fnd_message.get_string('CN','CN_IMP_DS_SUBMIT_FAIL'),
	    p_message_type => 'ERROR');
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       ELSE
	 cn_message_pkg.debug('Staging Data : SQL*Loader Submited. Request ID = ' || l_request_id);
      END IF;
      -- when submit conc reg from pl/sql, a COMMIT is required
      -- **** DO NOT REMOVE ****
      COMMIT;

      -- The sql*loader concurrent program MUST finish
      -- before invoking the destination application
      -- concurrent program
      -- This is also required for the clean up process.

      l_wait_status := FND_CONCURRENT.WAIT_FOR_REQUEST
	(request_id        => l_request_id,
	 phase             => l_phase,
	 status            => l_status,
	 dev_phase         => l_dev_phase,
	 dev_status        => l_dev_status,
	 message           => l_message
	 );

      ---------------------------------------------+
      -- WAIT_STATUS should only come back as
      -- TRUE.  It only comes back as FALSE if
      -- the conc request was not successfully
      -- submitted.
      ---------------------------------------------+
      IF NOT l_wait_status THEN
	 FND_MESSAGE.set_name ('CN', 'CN_IMP_DS_SUBMIT_FAIL');
	 cn_message_pkg.write
	   (p_message_text    => fnd_message.get_string('CN','CN_IMP_DS_SUBMIT_FAIL'),
	    p_message_type    => 'ERROR');
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_dev_phase <> 'COMPLETE' OR l_dev_status <> 'NORMAL' THEN
	 -- Conc req complete with error or not complete
	 FND_MESSAGE.set_name ('CN', 'CN_IMP_DS_FAIL');
	 update_imp_headers
	   (p_imp_header_id => p_imp_header_id,
	    p_status_code => 'STAGE_FAIL');
	 cn_message_pkg.write
	   (p_message_text    => fnd_message.get_string('CN','CN_IMP_DS_FAIL'),
	    p_message_type    => 'ERROR');
	 -- raise error after clean up creaated conc
	 GOTO delete_conc;
	 -- RAISE FND_API.g_exc_unexpected_error;
      END IF;

      cn_message_pkg.debug('Staging Data : SQL*Loader Finished.');

      -- UPDATE cn_imp_headers
      OPEN c_loaded_rows;
      FETCH c_loaded_rows INTO l_loaded_rows;
      CLOSE c_loaded_rows;

      update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'STAGE',
	 p_staged_row => l_loaded_rows);

      << delete_conc >>
      -- Clean-up the concurrent programs which were created
      -- during program execution.
      FND_PROGRAM.DELETE_PROGRAM
	(program_short_name   => l_short_name,
	 application          => 'CN'
	 );
      cn_message_pkg.debug('Staging Data : Delete Conc Program.');

      --
      -- The "executable" will be the same as the program short name
      -- for all run-time generated concurrent programs.  The registered
      -- program must be deleted before the executable can be.
      FND_PROGRAM.DELETE_EXECUTABLE
	(executable_short_name      => l_short_name,
	 application                => 'CN'
	 );
      cn_message_pkg.debug('Staging Data : Delete Conc Executable.');

      IF l_dev_phase <> 'COMPLETE' OR l_dev_status <> 'NORMAL' THEN
	 -- Conc req complete with error or not complete
	 -- raise error after clean up created conc
	 RAISE FND_API.g_exc_unexpected_error;
      END IF;

  END IF; -- end status_code = 'SUBMIT' AND server_flag = 'Y'

  cn_message_pkg.write
    (p_message_text    => 'End Staging Data : Server_Stage_data - ' || l_short_name,
     p_message_type    => 'MILESTONE');

  -- close process batch
  cn_message_pkg.end_batch(l_process_audit_id);

  -- Get imp_header status
  SELECT name, status_code,server_flag
    INTO l_imp_header.name ,l_imp_header.status_code  ,l_imp_header.server_flag
    FROM cn_imp_headers
    WHERE imp_header_id = p_imp_header_id;

  -- Start Loading Data
  IF l_imp_header.status_code = 'STAGE'  THEN
     Load_Data
       (errbuf        => errbuf,
	retcode       => retcode,
	p_imp_header_id => p_imp_header_id,
	p_org_id	=> p_org_id
	);

  END IF ;

  --errbuf := SUBSTR (FND_MESSAGE.GET, 1, 240);
   -- End of API body.

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      retcode := 2 ;
      update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'STAGE_FAIL');
      cn_message_pkg.end_batch(l_process_audit_id);
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  l_msg_count ,
           p_data    =>  errbuf   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'STAGE_FAIL');
      err_num :=  SQLCODE;
      IF err_num = -6501 THEN
	 retcode := 2 ;
	 errbuf := fnd_program.message;
       ELSE
	 retcode := 2 ;
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	 END IF;
	 FND_MSG_PUB.count_and_get
	   (p_count   =>  l_msg_count ,
	    p_data    =>  errbuf   ,
	    p_encoded => FND_API.G_FALSE
	    );
      END IF;
      cn_message_pkg.set_error(l_api_name,errbuf);
      cn_message_pkg.end_batch(l_process_audit_id);

END Server_Stage_data;

-- --------------------------------------------------------+
-- This program invokes concurrent program base on import type
-- to populate the data from the staging table into destination table
-- --------------------------------------------------------+

PROCEDURE Load_Data
  (errbuf                     OUT NOCOPY   VARCHAR2,
   retcode                    OUT NOCOPY   NUMBER,
   p_imp_header_id            IN    NUMBER,
   p_org_id		     IN NUMBER
   ) IS

  l_short_name      		 VARCHAR2(30);
  l_request_id      		 NUMBER;
  l_wait_status        		 BOOLEAN;
  l_phase              		 VARCHAR2(30);
  l_status             		 VARCHAR2(30);
  l_start_time                   DATE;
  l_dev_phase          		 VARCHAR2(30);
  l_dev_status         		 VARCHAR2(30);
  l_message            		 VARCHAR2(240);
  l_loaded_rows        		 NUMBER;

  l_imp_header                  cn_imp_headers_pvt.imp_headers_rec_type := cn_imp_headers_pvt.G_MISS_IMP_HEADERS_REC;
  l_process_audit_id cn_process_audits.process_audit_id%TYPE;
  l_imp_type_code               VARCHAR2(30);
  l_conc_program                VARCHAR2(30);

  l_msg_count                           NUMBER := 0;

  l_api_name     CONSTANT VARCHAR2(30) := 'Load_Data';
  l_api_version  CONSTANT NUMBER  := 1.0;
  err_num   NUMBER;

  CURSOR c_conc_name IS
     SELECT conc_program FROM cn_import_types
       WHERE  import_type_code = l_imp_type_code;


BEGIN
  -- Standard Start of API savepoint
  --  Initialize API return status to success
  -- API body

  retcode := 0;  -- no problems. 1= warning, 2  = fail
  l_imp_type_code := get_imp_type_code(p_imp_header_id);
  OPEN  c_conc_name;
  FETCH c_conc_name INTO l_conc_program;
  CLOSE c_conc_name;

  SELECT name, status_code,server_flag
    INTO l_imp_header.name ,l_imp_header.status_code,
    l_imp_header.server_flag
    FROM cn_imp_headers
    WHERE imp_header_id = p_imp_header_id;

  -- open process audit batch
  cn_message_pkg.begin_batch
    ( x_process_type	=> l_imp_type_code,
      x_parent_proc_audit_id  => p_imp_header_id ,
      x_process_audit_id	=>  l_process_audit_id,
      x_request_id		=> null,
      p_org_id			=> p_org_id);

  cn_message_pkg.write
    (p_message_text  => 'Start Loading Data : Load_Data - ' || l_conc_program,
     p_message_type  => 'MILESTONE');

  -- Start Loading Data
  IF l_imp_header.status_code = 'STAGE' THEN
     -- Update record_num in cn_imp_lines
     upd_impline_recnum (p_imp_header_id => p_imp_header_id);

     -- set status = SCHEDULE
     update_imp_headers
       (p_imp_header_id => p_imp_header_id,
	p_status_code => 'SCHEDULE');

     -- Submit conc req
     FND_REQUEST.SET_ORG_ID(p_org_id);

     l_request_id := FND_REQUEST.SUBMIT_REQUEST
       (application      => 'CN',
	program          => l_conc_program,
	argument1        => p_imp_header_id,
	argument2     => p_org_id
	);

     IF l_request_id = 0 THEN
	 FND_MESSAGE.set_name ('CN', 'CN_IMP_ST_SUBMIT_FAIL');
	 cn_message_pkg.write
	   (p_message_text    => fnd_message.get_string('CN','CN_IMP_ST_SUBMIT_FAIL') || ' ' || l_conc_program,
	    p_message_type    => 'ERROR');
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSE
	cn_message_pkg.debug('Loading Data : Conc Pgm Submited. Request ID = ' || l_request_id);
      END IF;
      -- when submit conc reg from pl/sql, a COMMIT is required
      -- **** DO NOT REMOVE ****
      COMMIT;

      -- The concurrent program MUST finish
      -- before update import status

      l_wait_status := FND_CONCURRENT.WAIT_FOR_REQUEST
	(request_id        => l_request_id,
	 phase             => l_phase,
	 status            => l_status,
	 dev_phase         => l_dev_phase,
	 dev_status        => l_dev_status,
	 message           => l_message
	 );

      ---------------------------------------------+
      -- WAIT_STATUS should only come back as
      -- TRUE.  It only comes back as FALSE if
      -- the conc request was not successfully
      -- submitted.
      ---------------------------------------------+
      IF NOT l_wait_status THEN
	 FND_MESSAGE.set_name ('CN', 'CN_IMP_ST_SUBMIT_FAIL');
	 cn_message_pkg.write
	   (p_message_text    => fnd_message.get_string('CN','CN_IMP_ST_SUBMIT_FAIL'),
	    p_message_type    => 'ERROR');
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_dev_phase <> 'COMPLETE' OR l_dev_status <> 'NORMAL' THEN
	 -- Conc req complete with error or not complete
	 FND_MESSAGE.set_name ('CN', 'CN_IMP_ST_FAIL');
	 update_imp_headers
	   (p_imp_header_id => p_imp_header_id,
	    p_status_code => 'IMPORT_FAIL');
	 cn_message_pkg.write
	    (p_message_text    => fnd_message.get_string('CN','CN_IMP_ST_FAIL'),
	    p_message_type    => 'ERROR');
	 RAISE FND_API.g_exc_unexpected_error;
      END IF;

      cn_message_pkg.debug('Loading Data : Load Data Conc Pgm Finished.');
  END IF; -- end status_code = 'STAGE'
  cn_message_pkg.write
    (p_message_text    => 'End Loading Data : Load_Data - ' || l_conc_program,
     p_message_type    => 'MILESTONE'
     );

  -- Close process audit batch
  cn_message_pkg.end_batch(l_process_audit_id);

   --errbuf := SUBSTR (FND_MESSAGE.GET, 1, 240);
   -- End of API body.

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      retcode := 2 ;
      update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'IMPORT_FAIL');
      cn_message_pkg.end_batch(l_process_audit_id);
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  l_msg_count ,
           p_data    =>  errbuf   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'IMPORT_FAIL');
      err_num :=  SQLCODE;
      IF err_num = -6501 THEN
	 retcode := 2 ;
	 errbuf := fnd_program.message;
       ELSE
	 retcode := 2 ;
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	 END IF;
	 FND_MSG_PUB.count_and_get
	   (p_count   =>  l_msg_count ,
	    p_data    =>  errbuf   ,
	    p_encoded => FND_API.G_FALSE
	    );
      END IF;
      cn_message_pkg.set_error(l_api_name,errbuf);
      cn_message_pkg.end_batch(l_process_audit_id);

END Load_Data;

-- Start of comments
--    API name        : Client_Stage_data
--    Type            : Private.
--    Function        : Main program to call CN_IMPORT_CLIENT_PVT
--                      to transfer data from datafile to stage table
--    Pre-reqs        : None.
--    Parameters      :
--    Version :         Current version       1.0
--
--    Notes           :
--     The "p_data" contains all data needed to be inserted, assuming all data
--     types are "VARCHAR2". For example, if the data to be inserted are the
--     followings:
--
--     Row Number   1        2        3        4
--     Column1      Frank    Smith    Scott    Marry
--     Column2      Amos     Anderson Baber    Beier
--     Column3      75039    77002    23060    03062
--
--     The data is stored in the "p_data" as:"Frank", "Smith", "Scott","Marry",
--     "Amos", "Anderson", "Baber", "Beier", "75039", "77002", "23060","03062".
--
-- End of comments

PROCEDURE Client_Stage_Data
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_header_id           IN     NUMBER,
   p_data                    IN     CHAR_DATA_SET_TYPE,
   p_row_count               IN     NUMBER,
   p_map_obj_ver             IN     NUMBER,
   p_org_id		     IN NUMBER
   )
IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Client_Stage_Data';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_imp_type_code   VARCHAR2(30);
      l_imp_header      cn_imp_headers_pvt.imp_headers_rec_type := cn_imp_headers_pvt.G_MISS_IMP_HEADERS_REC;
      l_process_audit_id cn_process_audits.process_audit_id%TYPE;

      CURSOR c_tar_col_cv(c_imp_map_id NUMBER) IS
	 SELECT f.source_column,f.target_column_name,f.target_table_name,
	   m.object_version_number map_obj_ver
	   FROM cn_imp_map_fields f, cn_imp_maps m
	   WHERE m.imp_map_id = c_imp_map_id
	   AND   f.imp_map_id = m.imp_map_id
	   ORDER BY f.source_column
	   ;

      CURSOR c_loaded_rows IS
	 SELECT COUNT(*)
	   FROM   cn_imp_lines
	   WHERE  imp_header_id = p_imp_header_id;
      l_loaded_rows   NUMBER;

      l_data          char_data_set_type;
      l_columns       char_data_set_type;
      l_row_count     NUMBER := 0;
      l_tar_index     NUMBER := 1;
      l_src_index     NUMBER := 1;
      l_index         NUMBER := 1;
      l_target_table  VARCHAR2(30);
      errbuf          VARCHAR2(2000);
      retcode         NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Client_Stage_Data;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body
   l_imp_type_code := get_imp_type_code(p_imp_header_id);

   -- Get imp_header info
   SELECT name, status_code,server_flag,imp_map_id, source_column_num
     INTO l_imp_header.name ,l_imp_header.status_code ,
     l_imp_header.server_flag, l_imp_header.imp_map_id,
     l_imp_header.source_column_num
     FROM cn_imp_headers
     WHERE imp_header_id = p_imp_header_id;

   -- Check if Client_Stage_Data has been process multiple time, means import
   -- data has been divide into multiple chunks and each chunk will call
   -- Client_Stage_Data. Do not reset status if previous chunk of data fail
   IF l_imp_header.status_code <> 'STAGE_FAIL' THEN
      -- set/reset status to 'SUBMIT'
      update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'SUBMIT');
      l_imp_header.status_code := 'SUBMIT';
   END IF;

   -- open process audit batch
   cn_message_pkg.begin_batch
     ( x_process_type	=> l_imp_type_code,
       x_parent_proc_audit_id  => p_imp_header_id ,
       x_process_audit_id	=>  l_process_audit_id,
       x_request_id		=> null,
       p_org_id			=> p_org_id);

   cn_message_pkg.write
     (p_message_text    => 'Start Client Staging Data : Client_Stage_data ' ,
      p_message_type    => 'MILESTONE');

   -- Start staging
   IF l_imp_header.status_code = 'SUBMIT' AND l_imp_header.server_flag = 'N'
     AND l_imp_header.imp_map_id IS NOT NULL
     THEN
      -- re-build p_data to remove unmapped columns
      l_row_count := p_data.COUNT / l_imp_header.source_column_num;
      -- for each mapped column
      FOR c_tar_col IN c_tar_col_cv(l_imp_header.imp_map_id) LOOP
	 -- check if mapping is updated by other user
	 IF c_tar_col.map_obj_ver <> p_map_obj_ver THEN
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
	       FND_MESSAGE.SET_NAME ('CN' , 'CN_IMP_MAPPED_CHANGED');
	       FND_MSG_PUB.Add;
	    END IF;
	    cn_message_pkg.write
	      (p_message_text  => fnd_message.get_string('CN','CN_IMP_MAPPED_CHANGED'),
	       p_message_type  => 'ERROR');
	    RAISE FND_API.G_EXC_ERROR ;
	 END IF;
	 -- build column list
	 l_columns(l_index) := c_tar_col.target_column_name;
	 l_index := l_index + 1;
	 l_target_table := c_tar_col.target_table_name;
	 -- copy data from p_data into l_data
	 l_src_index := (To_number(c_tar_col.source_column) - 1) * l_row_count + 1;
	 FOR i IN 1 .. l_row_count LOOP
	    l_data(l_tar_index) := p_data(l_src_index);
	    l_tar_index := l_tar_index + 1;
	    l_src_index := l_src_index + 1;
	 END LOOP;  -- end l_row_count LOOP
      END LOOP; -- End FOR c_tar_col IN c_tar_col_cv LOOP

      cn_message_pkg.debug('Staging Data : Unmapped data dropped.');

      -- Insert data into stage table
      cn_import_client_pvt.insert_data
	(p_api_version => 1.0,
	 p_imp_header_id => p_imp_header_id,
	 p_import_type_code =>  l_imp_type_code,
	 p_table_name  => l_target_table,
	 p_col_names   => l_columns,
	 p_data        => l_data,
	 p_row_count   => l_row_count,
	 x_return_status => x_return_status,
	 x_msg_count   => x_msg_count,
	 x_msg_data    => x_msg_data);

      IF x_return_status <> FND_API.g_ret_sts_success THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- UPDATE cn_imp_headers
      OPEN c_loaded_rows;
      FETCH c_loaded_rows INTO l_loaded_rows;
      CLOSE c_loaded_rows;
      -- data may cut into 3600 element chuncks, l_row_count is not necessary
      -- staged_row
      update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'STAGE',
	 p_staged_row => l_loaded_rows);

   END IF; -- End IF l_imp_header.status_code = 'SUBMIT'

   cn_message_pkg.write
     (p_message_text    => 'staged row = ' || l_row_count ,
      p_message_type    => 'DEBUG');

   cn_message_pkg.write
     (p_message_text    => 'End Client Staging Data : Client_Stage_data ' ,
      p_message_type    => 'MILESTONE');

   -- close process batch
   cn_message_pkg.end_batch(l_process_audit_id);

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get
     (p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Client_Stage_Data  ;
      update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'STAGE_FAIL');
      x_return_status := FND_API.G_RET_STS_ERROR ;
      cn_message_pkg.end_batch(l_process_audit_id);
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Client_Stage_Data ;
      update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'STAGE_FAIL');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      cn_message_pkg.end_batch(l_process_audit_id);
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Client_Stage_Data ;
      update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'STAGE_FAIL');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      cn_message_pkg.set_error(l_api_name,'Unexpected Error');
      cn_message_pkg.end_batch(l_process_audit_id);
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );

END Client_Stage_Data ;

-- ========================================================
--  Utility Modules
-- ========================================================
-- --------------------------------------------------------+
--  update_imp_lines
--
--  This procedure will update cn_imp_lines status and error code
-- --------------------------------------------------------+
PROCEDURE update_imp_lines
  (p_imp_line_id IN NUMBER,
   p_status_code IN VARCHAR2,
   p_error_code  IN VARCHAR2,
   p_error_msg IN VARCHAR2 := NULL) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   UPDATE cn_imp_lines
     SET status_code = p_status_code, error_code = p_error_code,
     error_msg = p_error_msg
     WHERE imp_line_id = p_imp_line_id
     ;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;
   COMMIT;
END update_imp_lines;

-- --------------------------------------------------------+
--  update_imp_headers
--
--  This procedure will update cn_imp_headers status,processed_row
--  and failed_row
-- --------------------------------------------------------+
PROCEDURE update_imp_headers
  (p_imp_header_id IN NUMBER,
   p_status_code IN VARCHAR2,
   p_staged_row  IN NUMBER := NULL,
   p_processed_row  IN NUMBER := NULL,
   p_failed_row  IN NUMBER := NULL) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   UPDATE cn_imp_headers
     SET status_code = Decode(p_status_code,NULL,status_code,p_status_code),
     staged_row =Decode(p_staged_row,NULL,staged_row,p_staged_row),
     processed_row =Decode(p_processed_row,NULL,processed_row,p_processed_row),
     failed_row = Decode(p_failed_row,NULL,failed_row,p_failed_row)
     WHERE imp_header_id = p_imp_header_id
     ;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;
   COMMIT;
END update_imp_headers;

-- --------------------------------------------------------+
--  build_error_rec
--
-- This procedure will generate the list of source column headers for error
--   reporting. It will also generate a SQL statement which will be used to
--   retrieve target column values
-- --------------------------------------------------------+
PROCEDURE build_error_rec
  (p_imp_header_id IN NUMBER,
   x_header_list OUT NOCOPY VARCHAR2,
   x_sql_stmt OUT NOCOPY VARCHAR2 )
  IS
     CURSOR c_src_col_csr IS
	SELECT f.source_column,f.source_user_column,
	  f.target_column_name,f.target_table_name
	  FROM cn_imp_headers h, cn_imp_map_fields f
	  WHERE h.imp_header_id = p_imp_header_id
	  AND f.imp_map_id = h.imp_map_id
	  ORDER BY f.source_column
	  ;
     l_src_col_csr c_src_col_csr%ROWTYPE;
     l_table_name cn_imp_map_fields.target_column_name%TYPE ;
     l_errbuf VARCHAR2(2000);

BEGIN
   x_header_list := NULL;
   x_sql_stmt := 'SELECT ';

   OPEN c_src_col_csr;
   LOOP
      FETCH c_src_col_csr INTO l_src_col_csr;
      EXIT WHEN c_src_col_csr%notfound;

      IF x_header_list IS NOT NULL THEN
	 x_header_list := x_header_list || ' , ';
      END IF;
      x_header_list := x_header_list || l_src_col_csr.source_user_column;

      IF x_sql_stmt <> 'SELECT ' THEN
	x_sql_stmt := x_sql_stmt || ' || '' , '' || ';
      END IF;
      x_sql_stmt := x_sql_stmt || l_src_col_csr.target_column_name;
      l_table_name := l_src_col_csr.target_table_name;
   END LOOP;
   IF c_src_col_csr%ROWCOUNT = 0 THEN
      x_header_list := NULL;
      x_sql_stmt := NULL;
    ELSE
      x_sql_stmt := x_sql_stmt || ' FROM ' ||  l_table_name;
      x_sql_stmt := x_sql_stmt || ' WHERE imp_line_id = :id' ;
   END IF;
   CLOSE c_src_col_csr;

   -- cn_message_pkg.debug(x_header_list);
   -- cn_message_pkg.debug(x_sql_stmt);

END build_error_rec;

-- --------------------------------------------------------+
--  write_error_rec
--
-- This procedure will write the list of source column headers to process log
--  also retrieve the value of corresponding target columns and write to log
-- --------------------------------------------------------+
PROCEDURE write_error_rec
  (p_imp_header_id IN NUMBER,
   p_imp_line_id IN NUMBER,
   p_header_list IN VARCHAR2,
   p_sql_stmt IN VARCHAR2 )
  IS
     l_data_list VARCHAR2(2000);
     l_errbuf VARCHAR2(2000);
BEGIN

   EXECUTE IMMEDIATE p_sql_stmt INTO l_data_list USING p_imp_line_id ;

   cn_message_pkg.write
     (p_message_text    => '--  ' || p_header_list,
      p_message_type    => 'ERROR');

   cn_message_pkg.write
     (p_message_text    => '-- ' || l_data_list,
      p_message_type    => 'ERROR');

END write_error_rec;

END CN_IMPORT_PVT;

/
