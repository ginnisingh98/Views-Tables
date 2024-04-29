--------------------------------------------------------
--  DDL for Package Body BIM_I_UPDATE_FACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_I_UPDATE_FACTS_PKG" AS
/*$Header: bimiulmb.pls 120.6 2005/10/11 05:38:30 sbassi noship $*/

g_init_msg_list         CONSTANT VARCHAR2(50)     := FND_API.G_FALSE;
g_validation_level      CONSTANT NUMBER		  := FND_API.G_VALID_LEVEL_FULL;
g_commit                CONSTANT VARCHAR2(50)     := FND_API.G_FALSE;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_SOURCE_CODES
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number   IN   NUMBER ,
    p_start_date           IN   DATE,
    p_end_date             IN   DATE,
    p_proc_num             IN   NUMBER,
    p_truncate_flg	   IN   VARCHAR2
   ) IS
    l_api_version_number        NUMBER;
    x_msg_count	              NUMBER;
    x_msg_data		      VARCHAR2(240);
    x_return_status	      VARCHAR2(1) ;
    l_api_name                   CONSTANT VARCHAR2(30) := 'INVOKE_SOURCE_CODES';
 BEGIN
    l_api_version_number := p_api_version_number;

    BIM_I_SRC_CODE_PKG.POPULATE
                        (p_api_version_number => p_api_version_number
                        ,x_msg_count          => x_msg_count
                        ,x_msg_data           => x_msg_data
                        ,x_return_status      => x_return_status
                        ,p_start_date         => p_start_date
                        ,p_end_date           => p_end_date
                        ,p_para_num           => p_proc_num
			,p_init_msg_list      => g_init_msg_list
 			,p_validation_level   => g_validation_level
			,p_commit	      => g_commit
			,p_truncate_flg	      => p_truncate_flg
                        );


      IF    x_return_status = FND_API.g_ret_sts_error  THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'End');

 EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status := FND_API.g_ret_sts_error ;
	  FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                               	     p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN OTHERS THEN
       	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
          		             p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF  := sqlerrm(sqlcode);
          RETCODE := sqlcode;

 END INVOKE_SOURCE_CODES;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_MARKETING
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_proc_num              IN   NUMBER,
    p_truncate_flg	    IN   VARCHAR2
    ) IS

    v_error_code              NUMBER;
    v_error_text              VARCHAR2(1500);
    l_start_date              DATE;
    l_end_date                DATE;
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'INVOKE_MARKETING';
    x_msg_count	              NUMBER;
    x_msg_data		      VARCHAR2(240);
    x_return_status	      VARCHAR2(1) ;
    l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;
    l_max_date                DATE;

 BEGIN
     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      BIM_MARKET_FACTS_PKG.POPULATE
                         (p_api_version_number => p_api_version_number
                         ,x_msg_count          => x_msg_count
                         ,x_msg_data           => x_msg_data
                         ,x_return_status      => x_return_status
                         ,p_start_date         => p_start_date
                         ,p_end_date           => p_end_date
                         ,p_para_num           => p_proc_num
			 ,p_truncate_flg       => p_truncate_flg
                         );
      IF    x_return_status = FND_API.g_ret_sts_error
      THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'End');

 EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status := FND_API.g_ret_sts_error ;
	  FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                               	     p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN OTHERS THEN
       	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
          		             p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF  := sqlerrm(sqlcode);
          RETCODE := sqlcode;
 END INVOKE_MARKETING;

  PROCEDURE INVOKE_BUDGET
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_proc_num              IN   NUMBER,
    p_truncate_flg	    IN   VARCHAR2
    ) IS

    v_error_code              NUMBER;
    v_error_text              VARCHAR2(1500);
    l_start_date              DATE;
    l_end_date                DATE;
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'INVOKE_MARKETING';
    x_msg_count	              NUMBER;
    x_msg_data		      VARCHAR2(240);
    x_return_status	      VARCHAR2(1) ;
    l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;
    l_max_date                DATE;

 BEGIN
     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      BIM_I_BGT_FACTS_PKG.POPULATE
                         (p_api_version_number => p_api_version_number
                         ,x_msg_count          => x_msg_count
                         ,x_msg_data           => x_msg_data
                         ,x_return_status      => x_return_status
                         ,p_start_date         => p_start_date
                         ,p_end_date           => p_end_date
                         ,p_para_num           => p_proc_num
			 ,p_truncate_flg       => p_truncate_flg
                         );
      IF   x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'End');

 EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status := FND_API.g_ret_sts_error ;
	  FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                               	     p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN OTHERS THEN
       	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
          		             p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF  := sqlerrm(sqlcode);
          RETCODE := sqlcode;
 END INVOKE_BUDGET;


---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_LEADS
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_proc_num              IN   NUMBER,
    p_truncate_flg	    IN   VARCHAR2
    ) IS

    v_error_code              NUMBER;
    v_error_text              VARCHAR2(1500);
    l_start_date              DATE;
    l_end_date                DATE;
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'INVOKE_LEADS';
    x_msg_count	              NUMBER;
    x_msg_data		      VARCHAR2(240);
    x_return_status	      VARCHAR2(1) ;
    l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;
    l_max_date                DATE;

 BEGIN
     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      BIM_I_LEAD_FACTS_PKG.POPULATE
                        (p_api_version_number => p_api_version_number
                        ,x_msg_count          => x_msg_count
                        ,x_msg_data           => x_msg_data
                        ,x_return_status      => x_return_status
                        ,p_start_date         => p_start_date
                        ,p_end_date           => p_end_date
                        ,p_para_num           => p_proc_num
			,p_init_msg_list      => g_init_msg_list
 			,p_validation_level   => g_validation_level
			,p_commit	      => g_commit
			,p_truncate_flg	      => p_truncate_flg
                        );
      IF    x_return_status = FND_API.g_ret_sts_error
      THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'End');

 EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status := FND_API.g_ret_sts_error ;
	  FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                               	     p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN OTHERS THEN
       	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
          		             p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF  := sqlerrm(sqlcode);
          RETCODE := sqlcode;
 END INVOKE_LEADS;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_MARKETING_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_proc_num              IN   NUMBER,
    p_truncate_flg	    IN   VARCHAR2
    ) IS
 BEGIN
      INVOKE_MARKETING
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => p_start_date
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
	     ,p_truncate_flg	   => p_truncate_flg
             );
 END INVOKE_MARKETING_F;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_MARKETING_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_proc_num              IN   NUMBER
    ) IS
 BEGIN
      INVOKE_MARKETING
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => NULL
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
	     ,p_truncate_flg	   => null
             );
 END INVOKE_MARKETING_I;

---------------------------------------------------------------------------------+


 PROCEDURE INVOKE_BUDGET_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_proc_num              IN   NUMBER,
    p_truncate_flg	    IN   VARCHAR2
    ) IS
 BEGIN
      INVOKE_BUDGET
             (ERRBUF               => ERRBUF
	     ,RETCODE              => RETCODE
	     ,p_api_version_number => p_api_version_number
             ,p_start_date         => p_start_date
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
	     ,p_truncate_flg	   => p_truncate_flg
             );
 END INVOKE_BUDGET_F;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_BUDGET_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_proc_num              IN   NUMBER
    ) IS
 BEGIN
      INVOKE_BUDGET
             (ERRBUF               => ERRBUF
	     ,RETCODE              => RETCODE
	     ,p_api_version_number => p_api_version_number
             ,p_start_date         => NULL
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
	     ,p_truncate_flg	   => null
             );
 END INVOKE_BUDGET_I;
---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_LEADS_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_proc_num              IN   NUMBER,
    p_truncate_flg	    IN   VARCHAR2
    ) IS
 BEGIN
      INVOKE_LEADS
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => p_start_date
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
	     ,p_truncate_flg	   => p_truncate_flg
             );
 END INVOKE_LEADS_F;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_LEADS_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_proc_num              IN   NUMBER
    ) IS
 BEGIN
      INVOKE_LEADS
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => NULL
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
	     ,p_truncate_flg	   => null
             );
 END INVOKE_LEADS_I;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_SOURCE_CODES_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_proc_num              IN   NUMBER,
    p_truncate_flg	    IN   VARCHAR2
    ) IS
 BEGIN
      INVOKE_SOURCE_CODES
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => p_start_date
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
	     ,p_truncate_flg	   => p_truncate_flg
             );
 END invoke_source_codes_f;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_SOURCE_CODES_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_proc_num              IN   NUMBER
    ) IS
 BEGIN
      INVOKE_SOURCE_CODES
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => NULL
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
	     ,p_truncate_flg	   => null
             );
 END invoke_source_codes_i;

---------------------------------------------------------------------------------+


 PROCEDURE INVOKE_SGMT
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_proc_num              IN   NUMBER,
    p_truncate_flg			IN   VARCHAR2
    ) IS


    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'INVOKE_SEGMENT';
    x_msg_count	              NUMBER;
    x_msg_data		      VARCHAR2(240);
    x_return_status	      VARCHAR2(1) ;

 BEGIN
     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      BIM_I_SGMT_FACTS_PKG.POPULATE
                        (p_api_version_number => p_api_version_number
                        ,x_msg_count          => x_msg_count
                        ,x_msg_data           => x_msg_data
                        ,x_return_status      => x_return_status
                        ,p_start_date         => p_start_date
                        ,p_end_date           => p_end_date
                        ,p_para_num           => p_proc_num
						,p_init_msg_list      => g_init_msg_list
						,p_validation_level   => g_validation_level
						,p_commit			  => g_commit
						,p_truncate_flg		  => p_truncate_flg
                        );
      IF    x_return_status = FND_API.g_ret_sts_error  THEN

            RAISE FND_API.g_exc_error;

      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN

	    RAISE FND_API.g_exc_unexpected_error;

      END IF;

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'End');

 EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status := FND_API.g_ret_sts_error ;
	  FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                               	     p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN OTHERS THEN
       	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
          		             p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF  := sqlerrm(sqlcode);
          RETCODE := sqlcode;
 END invoke_sgmt;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_SGMT_ACT
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_proc_num              IN   NUMBER,
    p_truncate_flg			IN   VARCHAR2
    ) IS

    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'INVOKE_SGMT_ACT';
    x_msg_count	              NUMBER;
    x_msg_data		      VARCHAR2(2400);
    x_return_status	      VARCHAR2(1) ;

 BEGIN

     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      BIM_I_SGMT_ACT_FACTS_PKG.POPULATE
                        (p_api_version_number => p_api_version_number
                        ,x_msg_count          => x_msg_count
                        ,x_msg_data           => x_msg_data
                        ,x_return_status      => x_return_status
                        ,p_start_date         => p_start_date
                        ,p_end_date           => p_end_date
                        ,p_para_num           => p_proc_num
						,p_init_msg_list      => g_init_msg_list
 						,p_validation_level   => g_validation_level
						,p_commit			  => g_commit
						,p_truncate_flg		  =>p_truncate_flg
                        );

      IF    x_return_status = FND_API.g_ret_sts_error  THEN

            RAISE FND_API.g_exc_error;

      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN

	    RAISE FND_API.g_exc_unexpected_error;

      END IF;

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'End');

 EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN

	  x_return_status := FND_API.g_ret_sts_error ;
	  FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                               	     p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN OTHERS THEN


       	  x_return_status := FND_API.g_ret_sts_unexp_error ;

          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
          							 p_count => x_msg_count,
                                     p_data  => x_msg_data);

          ERRBUF  := sqlerrm(sqlcode);
          RETCODE := sqlcode;

 END invoke_sgmt_act;
---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_SGMT_CUST
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_proc_num              IN   NUMBER,
    p_truncate_flg			IN   VARCHAR2
    ) IS




    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'INVOKE_SGMT_PARTY';
    x_msg_count	              NUMBER;
    x_msg_data		      VARCHAR2(240);
    x_return_status	      VARCHAR2(1) ;

 BEGIN
     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      BIM_I_SGMT_CUST_FACTS_PKG.POPULATE
                        (p_api_version_number => p_api_version_number
                        ,x_msg_count          => x_msg_count
                        ,x_msg_data           => x_msg_data
                        ,x_return_status      => x_return_status
                        ,p_start_date         => p_start_date
                        ,p_end_date           => p_end_date
                        ,p_para_num           => p_proc_num
						,p_init_msg_list      => g_init_msg_list
						,p_validation_level   => g_validation_level
						,p_commit			  => g_commit
						,p_truncate_flg		  =>p_truncate_flg
                        );
      IF    x_return_status = FND_API.g_ret_sts_error  THEN

            RAISE FND_API.g_exc_error;

      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN

	    RAISE FND_API.g_exc_unexpected_error;

      END IF;

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'End');

 EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status := FND_API.g_ret_sts_error ;
	  FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                               	     p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;

     WHEN OTHERS THEN
       	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
          		             p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF  := sqlerrm(sqlcode);
          RETCODE := sqlcode;

 END invoke_sgmt_cust;
---------------------------------------------------------------------------------+

  PROCEDURE INVOKE_SGMT_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_proc_num              IN   NUMBER,
	p_truncate_flg			IN	 VARCHAR2
    ) IS
 BEGIN
      INVOKE_SGMT
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => p_start_date
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
			 ,p_truncate_flg	   => p_truncate_flg
             );
 END invoke_sgmt_f;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_SGMT_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_proc_num              IN   NUMBER
    ) IS
 BEGIN
      INVOKE_SGMT
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => NULL
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
			 ,p_truncate_flg	   => NULL
             );
 END invoke_sgmt_i;

---------------------------------------------------------------------------------+
  PROCEDURE INVOKE_SGMT_ACT_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_proc_num              IN   NUMBER,
	p_truncate_flg			IN	 VARCHAR2
    ) IS
 BEGIN
      INVOKE_SGMT_ACT
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => p_start_date
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
			 ,p_truncate_flg	   => p_truncate_flg
             );
 END invoke_sgmt_act_f;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_SGMT_ACT_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_proc_num              IN   NUMBER
    ) IS
 BEGIN
      INVOKE_SGMT_ACT
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => NULL
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
			 ,p_truncate_flg	   => NULL
             );
 END invoke_sgmt_act_i;

 ---------------------------------------------------------------------------------+
  PROCEDURE INVOKE_SGMT_CUST_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_start_date            IN   DATE,
    p_proc_num              IN   NUMBER,
	p_truncate_flg			IN	 VARCHAR2
    ) IS
 BEGIN
      INVOKE_SGMT_CUST
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => p_start_date
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
			 ,p_truncate_flg	   => p_truncate_flg
             );
 END invoke_sgmt_cust_f;

---------------------------------------------------------------------------------+

 PROCEDURE INVOKE_SGMT_CUST_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER,
    p_proc_num              IN   NUMBER
    ) IS
 BEGIN
      INVOKE_SGMT_CUST
             (ERRBUF               => ERRBUF,
              RETCODE              => RETCODE,
              p_api_version_number => p_api_version_number
             ,p_start_date         => NULL
             ,p_end_date           => NULL
             ,p_proc_num           => p_proc_num
			 ,p_truncate_flg	   => NULL
             );
 END invoke_sgmt_cust_i;


END BIM_I_UPDATE_FACTS_PKG;

/
