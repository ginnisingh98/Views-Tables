--------------------------------------------------------
--  DDL for Package Body CN_POST_COLLECTION_TAE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_POST_COLLECTION_TAE_PUB" AS
--$Header: cnppcolb.pls 120.9.12010000.2 2009/01/29 09:28:21 gmarwah ship $

--$Header: cnppcolb.pls 120.9.12010000.2 2009/01/29 09:28:21 gmarwah ship $

--Global Variables
G_PKG_NAME 	       CONSTANT VARCHAR2(30) := 'CN_POST_COLLECTION_TAE_PUB';
G_LAST_UPDATE_DATE     DATE 		     := Sysdate;
G_LAST_UPDATED_BY      NUMBER 		:= fnd_global.user_id;
G_CREATION_DATE        DATE 		     := Sysdate;
G_CREATED_BY           NUMBER 		:= fnd_global.user_id;
G_LAST_UPDATE_LOGIN    NUMBER		     := fnd_global.login_id;


---------------------------------------------------------------------------------+
-- ** Public Procedures
---------------------------------------------------------------------------------+

-- Start of comments
--	API name 	: get_assignments
--	Type		: Public
--	Function	: This Public API is used to get TAE assignments
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        NUMBER    Required
--				p_init_msg_list      VARCHAR2  Optional
--					Default = FND_API.G_FALSE
--				p_commit	           VARCHAR2  Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   NUMBER    Optional
--					Default = FND_API.G_VALID_LEVEL_FULL

--	OUT		:	x_return_status	VARCHAR2(1)
--				x_msg_count	     NUMBER
--				x_msg_data	     VARCHAR2(2000)

--	Notes		: Note text

-- End of comments

PROCEDURE get_assignments
  ( p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_start_period_id    IN cn_periods.period_id%TYPE,
    x_end_period_id      IN cn_periods.period_id%TYPE,
    x_conc_program_id    IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_org_id             IN NUMBER
    )
  IS

     l_api_name       CONSTANT VARCHAR2(30) := 'get_assignments';
     l_api_version    CONSTANT NUMBER := 1.0;

     l_msg_count        NUMBER;
     l_msg_data         VARCHAR2(2000);

     l_start_date       DATE;
     l_end_date         DATE;
     l_where_clause     varchar2(1000);

     l_retcode          VARCHAR2(100);

     l_return_status	VARCHAR2(30);
     l_errbuf           varchar2(3000);
     errbuf          varchar2(32767);
     retcode         varchar2(260);

     l_source_id                  NUMBER;
     l_trans_object_type_id       NUMBER;
     l_request_id        	  NUMBER := FND_GLOBAL.CONC_REQUEST_ID();
     l_org_id                     NUMBER;
     l_version_name               VARCHAR2(60);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT get_assignments;
   --+
   -- Standard call to check for call compatibility.
   --+
   IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
						p_api_version,
						l_api_name,
						G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
     THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --+
   -- User hooks
   --+

   -- customer pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_POST_COLLECTION_TAE_PUB',
				'GET_ASSIGNMENTS',
				'B',
				'C')
   THEN
     cn_post_col_tae_pub_cuhk.get_assignments_pre
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status	=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data);

     IF x_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- vertical industry pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_POST_COLLECTION_TAE_PUB',
				'GET_ASSIGNMENTS',
				'B',
				'V')
   THEN
     cn_post_col_tae_pub_vuhk.get_assignments_pre
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status	=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data);

     IF x_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   --+
   -- API body
   --+

    apps.FND_MSG_PUB.initialize;

    l_source_id := -1001;
    l_trans_object_type_id  := -1002;
    l_org_id:=x_org_id;
    cn_periods_api.set_dates(x_start_period_id, x_end_period_id,l_org_id,l_start_date, l_end_date);
    l_where_clause :=' WHERE org_id=to_number('''||l_org_id||''') and txn_date between to_date('''||l_start_date|| ''',''dd-mon-yy'')' || '  and  to_date('''|| l_end_date || ''',''dd-mon-yy'') ';

    BEGIN
      select version_name
      into   l_version_name
      from   jty_trans_usg_pgm_sql
      where  source_id = -1001
      and    trans_type_id = -1002
      and    program_name  = 'SALES/INCENTIVE COMPENSATION PROGRAM'
      and    enabled_flag  = 'Y';
    EXCEPTION
      WHEN OTHERS THEN
        l_version_name := 'OTHER';
    END;

    IF (l_version_name = 'ORACLE') THEN
      l_where_clause := l_where_clause || ' ' ||
                           'AND load_status = ''UNLOADED'' ' ||
                           'AND '||
                           --(adjust_status IS NULL OR
                           '  adjust_status <> ''REVERSAL'' ' ||
                           '  AND (adjust_comments IS NULL OR adjust_comments <> ''Created by TAE'') ';
    END IF;

    fnd_file.put_line(fnd_file.Log, 'Start: collect trans data<<');
-- Begin --
  jty_assign_bulk_pub.collect_trans_data
      ( p_api_version_number    => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_source_id             => -1001,
        p_trans_id              => -1002,
        p_program_name          => 'SALES/INCENTIVE COMPENSATION PROGRAM',
        p_mode                  => 'DATE EFFECTIVE',
        p_where                 =>  l_where_clause,
        p_no_of_workers         => 1,
        p_percent_analyzed      => 20, -- this value can be either a profile option or a parameter to conc program
        p_request_id            => -1, -- request id of the concurrent program
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        ERRBUF                  => errbuf,
        RETCODE                 => retcode
      );
  fnd_file.put_line(fnd_file.Log, 'End: jty_assign_bulk_pub.collect_trans_data trans data');
  IF (retcode = 0) THEN
    fnd_file.put_line(fnd_file.Log, 'Start: get winners<<');
    jty_assign_bulk_pub.get_winners
        ( p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.G_FALSE,
          p_source_id             => -1001,
          p_trans_id              => -1002,
          p_program_name          => 'SALES/INCENTIVE COMPENSATION PROGRAM',
          p_mode                  => 'DATE EFFECTIVE',
          p_percent_analyzed      => 20, --  this value can be either a profile option or a parameter to conc program
          p_worker_id             => 1,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          ERRBUF                  => errbuf,
          RETCODE                 => retcode
        );
  fnd_file.put_line(fnd_file.Log, 'End: get winners<<');
  END IF;
  IF retcode <> 0 THEN
       RAISE fnd_api.g_exc_error;
  END IF;

  IF retcode=0 THEN
  fnd_file.put_line(fnd_file.Log, 'Start: Cn : Process trx records<<');
  CN_PROCESS_TAE_TRX_PUB.Process_Trx_Records(

        p_api_version    		=> 	p_api_version,
     	p_init_msg_list         	=>	p_init_msg_list,
	p_commit	            	=> 	p_commit,
     	p_validation_level      	=>      p_validation_level,

	x_return_status         	=>	l_return_status,
     	x_msg_count             	=>	l_msg_count,
     	x_msg_data              	=>	l_msg_data,
	p_org_id                        =>      l_org_id);
   fnd_file.put_line(fnd_file.Log, 'End: Cn : Process trx records<<');
   END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

   --   +
   -- End of API body.
   --+

   --+
   -- Post processing hooks
   --+

   -- SK Start of post processing hooks

   -- vertical post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_POST_COLLECTION_TAE_PUB',
				'GET_ASSIGNMENTS',
				'A',
				'V')
   THEN
     cn_post_col_tae_pub_vuhk.get_assignments_post
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status	=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data);

     IF x_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- customer post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_POST_COLLECTION_TAE_PUB',
				'GET_ASSIGNMENTS',
				'A',
				'C')
   THEN
     cn_post_col_tae_pub_vuhk.get_assignments_post
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status	=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data);

     IF x_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;
   -- SK End of post processing hooks

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit )
     THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO get_assignments;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_assignments;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
   WHEN OTHERS THEN
      ROLLBACK TO get_assignments;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF 	FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
END get_assignments;

END CN_POST_COLLECTION_TAE_PUB;

/
