--------------------------------------------------------
--  DDL for Package Body XLA_TB_BALANCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TB_BALANCE_PUB" AS
/* $Header: xlatbblp.pkb 120.2 2008/03/03 11:19:30 samejain ship $ */
/*======================================================================+
|             Copyright (c) 2000-2001 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tb_balance_pub                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Trial Balance Upgrade API (Public)                             |
|                                                                       |
| HISTORY                                                               |
|    21-Dec-05 M.Asada          Created                                 |
|                                                                       |
+======================================================================*/

--=============================================================================
--               *********** Public API Standard Constants **********
--=============================================================================
G_PKG_NAME 	    CONSTANT VARCHAR2(30):='xla_tb_balance_pkg';


--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240)
                      := 'xla.plsql.xla_tb_balance_pub';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pub.trace');
END trace;

--============================================================================
--
--
--
--============================================================================

PROCEDURE upload_balances
  (p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_definition_code   IN  VARCHAR2
  ,p_definition_name   IN  VARCHAR2
  ,p_definition_desc   IN  VARCHAR2
  ,p_ledger_id         IN  NUMBER
  ,p_balance_side_code IN  VARCHAR2
  ,p_je_source_name    IN  VARCHAR2
  ,p_gl_date_from      IN  DATE
  ,p_gl_date_to        IN  DATE
  ,p_mode              IN  VARCHAR2
  )
IS

   l_api_name		  CONSTANT VARCHAR2(30)	:= 'upload_balances';
   l_api_version      CONSTANT NUMBER 		:= 1.0;

   l_log_module       VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.upload_balances';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure upload_balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   SAVEPOINT	Upload_Balances;

   IF NOT FND_API.Compatible_API_Call
            (p_current_version_number => l_api_version
            ,p_caller_version_number  => p_api_version
            ,p_api_name               => l_api_name
            ,p_pkg_name               => G_PKG_NAME)
   THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN

      FND_MSG_PUB.initialize;

   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   xla_tb_balance_pkg.upload_balances
     (p_api_version       => p_api_version
     ,p_init_msg_list     => p_init_msg_list
     ,p_commit            => p_commit
     ,x_return_status     => x_return_status
     ,x_msg_count         => x_msg_count
     ,x_msg_data          => x_msg_data
     ,p_definition_code   => p_definition_code
     ,p_definition_name   => p_definition_name
     ,p_definition_desc   => p_definition_desc
     ,p_ledger_id         => p_ledger_id
     ,p_balance_side_code => p_balance_side_code
     ,p_je_source_name    => p_je_source_name
     ,p_gl_date_from      => p_gl_date_from
     ,p_gl_date_to        => p_gl_date_to
     ,p_mode              => p_mode);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure upload_balance'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   FND_MSG_PUB.Count_And_Get
     (p_count  =>  x_msg_count
     ,p_data   =>  x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

    	ROLLBACK TO Upload_Balances;

		x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
    	  (p_count     => x_msg_count
          ,p_data      => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    	ROLLBACK TO Upload_Balances;

    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	FND_MSG_PUB.Count_And_Get
    	  (p_count     => x_msg_count
          ,p_data      => x_msg_data);

   WHEN OTHERS THEN

		ROLLBACK TO Upload_Balances;

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
           FND_MSG_PUB.Add_Exc_Msg
    	     (p_pkg_name       => G_PKG_NAME
   	         ,p_procedure_name => l_api_name);
		END IF;

		FND_MSG_PUB.Count_And_Get
    	  (p_count     => x_msg_count
          ,p_data      => x_msg_data);

END upload_balances;


PROCEDURE Upgrade_AP_Balances
  (p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_balance_side_code IN  VARCHAR2
  ,p_je_source_name    IN  VARCHAR2
  )
IS

   l_api_name		  CONSTANT VARCHAR2(30)	:= 'Upgrade_AP_Balances';
   l_api_version      CONSTANT NUMBER 		:= 1.0;

   l_log_module       VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Upgrade_AP_Balances';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure Upgrade_AP_Balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   SAVEPOINT Upgrade_AP_Balances;

   IF NOT FND_API.Compatible_API_Call
            (p_current_version_number => l_api_version
            ,p_caller_version_number  => p_api_version
            ,p_api_name               => l_api_name
            ,p_pkg_name               => G_PKG_NAME)
   THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN

      FND_MSG_PUB.initialize;

   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   xla_tb_balance_pkg.Upgrade_AP_Balances
     (p_api_version       => p_api_version
     ,p_init_msg_list     => p_init_msg_list
     ,p_commit            => p_commit
     ,x_return_status     => x_return_status
     ,x_msg_count         => x_msg_count
     ,x_msg_data          => x_msg_data
     ,p_balance_side_code => p_balance_side_code
     ,p_je_source_name    => p_je_source_name);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure Upgrade_AP_Balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   FND_MSG_PUB.Count_And_Get
     (p_count  =>  x_msg_count
     ,p_data   =>  x_msg_data);

EXCEPTION
  WHEN OTHERS THEN
    raise;
/*
   WHEN FND_API.G_EXC_ERROR THEN

--    	ROLLBACK TO Upgrade_AP_Balances;

		x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
    	  (p_count     => x_msg_count
          ,p_data      => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

 --   	ROLLBACK TO Upgrade_AP_Balances;

    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	FND_MSG_PUB.Count_And_Get
    	  (p_count     => x_msg_count
          ,p_data      => x_msg_data);

   WHEN OTHERS THEN

--		ROLLBACK TO Upgrade_AP_Balances;

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
           FND_MSG_PUB.Add_Exc_Msg
    	     (p_pkg_name       => G_PKG_NAME
   	         ,p_procedure_name => l_api_name);
		END IF;

		FND_MSG_PUB.Count_And_Get
    	  (p_count     => x_msg_count
          ,p_data      => x_msg_data);
*/

END Upgrade_AP_Balances;

END xla_tb_balance_pub;

/
