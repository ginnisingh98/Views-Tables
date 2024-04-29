--------------------------------------------------------
--  DDL for Package Body CN_NOTIFICATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_NOTIFICATION_PUB" AS
--$Header: cnpntxb.pls 120.1 2005/10/10 21:42:17 apink noship $

--Global Variables
G_PKG_NAME 	       CONSTANT VARCHAR2(30) := 'CN_Notification_PUB';
G_LAST_UPDATE_DATE     DATE 		     := Sysdate;
G_LAST_UPDATED_BY      NUMBER 		:= fnd_global.user_id;
G_CREATION_DATE        DATE 		     := Sysdate;
G_CREATED_BY           NUMBER 		:= fnd_global.user_id;
G_LAST_UPDATE_LOGIN    NUMBER		     := fnd_global.login_id;


---------------------------------------------------------------------------------+
-- ** Private Procedures
---------------------------------------------------------------------------------+

-----------------------------------------------------------------------+
-- Function Name
--   collection_required
-- Purpose
--   This function tells the caller whether a new line needs to be
--   added to CN_NOT_TRX_ALL to cause collection ofthe specified
--   source_trx_line. If the specified line is currently unknown to
--   cn_not_trx_all, or the latest entry for that line has collected_flag
--   set to 'Y', then 'Y' is returned to indicated that a new line
--    should indeed be registered in cn_not_trx_all.
--
-- History
--   04-07-00	D.Maskell	    Created

  FUNCTION collection_required(
                          p_org_id  NUMBER,
				      p_line_id NUMBER,
                          p_source_doc_type cn_not_trx_all.source_doc_type%TYPE) RETURN VARCHAR2 IS
  	l_col_flag       VARCHAR2(1) := 'Y';
  BEGIN
    SELECT collected_flag
      INTO l_col_flag
      FROM cn_not_trx_all cnt
     WHERE cnt.source_trx_line_id = p_line_id
           AND NVL(cnt.org_id,-99) = NVL(p_org_id,-99)
           AND cnt.source_doc_type = p_source_doc_type
           AND cnt.not_trx_id = (SELECT max(cnt1.not_trx_id)
				             FROM cn_not_trx_all cnt1
				            WHERE cnt1.source_trx_line_id = p_line_id );
    RETURN l_col_flag;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN l_col_flag;

  END collection_required;

---------------------------------------------------------------------------------+
-- ** Public Procedures
---------------------------------------------------------------------------------+

-- Start of comments
--	API name 	: Create_Notification
--	Type		: Public
--	Function	: This Public API is used to create a Collection Notification
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

--   IN        :    p_line_id         NUMBER        Required
--                  p_source_doc_type VARCHAR2      Required
--                  p_adjusted_flag   VARCHAR2      Optional
--                        Default = 'N'
--                  p_header_id       NUMBER        Optional
--                        Default = FND_API.G_MISS_NUM
--                  p_org_id          NUMBER        Optional
--                        Default = FND_API.G_MISS_NUM
--
--	OUT		:	x_loading_status  VARCHAR2(4000)

--	Version	: Current version	1.0
--				12-Apr-00  Dave Maskell
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--				12-Apr-00  Dave Maskell

--	Notes		: Note text

-- End of comments

PROCEDURE Create_Notification
  ( p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    p_line_id            IN NUMBER,
    p_source_doc_type    IN VARCHAR2,
    p_adjusted_flag      IN VARCHAR2 := 'N',
    p_header_id          IN NUMBER := NULL,
    p_org_id             IN NUMBER := FND_API.G_MISS_NUM,
    x_loading_status     OUT NOCOPY VARCHAR2
    )
  IS

     l_api_name       CONSTANT VARCHAR2(30) := 'Create_Notification';
     l_api_version    CONSTANT NUMBER := 1.0;
     l_loading_status VARCHAR2(4000);

     l_org_id         NUMBER := p_org_id;
     l_proc_audit_id  NUMBER;
     l_batch_id       NUMBER;
     l_not_trx_id     NUMBER;
     l_rowid          ROWID;
     l_event_id       NUMBER;

     l_bind_data_id   NUMBER;
     l_return_code    VARCHAR2(1);

     CURSOR c_event (cp_org_id NUMBER) IS
       SELECT events.event_id
       FROM   cn_table_maps_all tm,
              cn_modules_all_b modules,
              cn_events_all_b events
       WHERE  tm.mapping_type = p_source_doc_type
              AND NVL(tm.org_id,-99) = NVL(cp_org_id,-99)
              AND modules.module_id = tm.module_id
              AND NVL(modules.org_id,-99) = NVL(cp_org_id,-99)
              AND events.event_id = modules.event_id
              AND NVL(events.org_id,-99) = NVL(cp_org_id,-99);
     --+
     -- Declaration for user hooks
     --+
     l_OAI_array	    JTF_USR_HKS.oai_data_array_type;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Create_Notification;
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
   x_loading_status := 'CN_INSERTED';

   --+
   -- User hooks
   --+

   -- customer pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_NOTIFICATION_PUB',
				'CREATE_NOTIFICATION',
				'B',
				'C')
   THEN
     cn_notification_pub_cuhk.create_notification_pre
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status	=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      p_line_id          => p_line_id,
      p_source_doc_type  => p_source_doc_type,
      p_adjusted_flag    => p_adjusted_flag,
      p_header_id        => p_header_id,
      p_org_id           => p_org_id,
      x_loading_status   => x_loading_status);

     IF x_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- vertical industry pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_NOTIFICATION_PUB',
				'CREATE_NOTIFICATION',
				'B',
				'V')
   THEN
     cn_notification_pub_vuhk.create_notification_pre
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status	=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      p_line_id          => p_line_id,
      p_source_doc_type  => p_source_doc_type,
      p_adjusted_flag    => p_adjusted_flag,
      p_header_id        => p_header_id,
      p_org_id           => p_org_id,
      x_loading_status   => x_loading_status);

     IF x_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   --+
   -- API body
   --+
   cn_process_audits_pkg.insert_row
	( l_rowid, l_proc_audit_id, NULL, 'NOT', 'Update Notification Api',
	  NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL, p_org_id);
   --+
   -- Use the correct org_id. If the user did not specify org_id then
   -- get the org_id from the client environment. Note that if p_org_id
   -- is NULL, l_org_id will also be left as NULL.
   --+
   IF l_org_id = FND_API.G_MISS_NUM THEN
     -- The next statement sets l_org_id to be the current ORG_ID from
     -- the user environment. If there is no ORG_ID set, then l_client_org_id is
     -- defaulted to -99.
     SELECT
         NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),
                              ' ', NULL,
                              SUBSTRB(USERENV('CLIENT_INFO'),1,10)
                              )
                       ),
              -99
           )
     INTO l_org_id
     FROM DUAL;
   END IF;

   -- Call to Collection_Required makes sure that there is not
   -- already a 'to-be-collected' record for the line in CN_NOT_TRX_ALL.
   IF Collection_Required
                    (p_org_id => p_org_id,
                     p_line_id => p_line_id,
                     p_source_doc_type => p_source_doc_type) = 'Y' THEN

     --+
     -- Derive the event_id
     --+
     OPEN c_event(l_org_id);
     FETCH c_event INTO l_event_id;
     CLOSE c_event;
	IF l_event_id IS NULL THEN
       --Error condition
       IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	  THEN
	    fnd_message.set_name('CN', 'CN_INVALID_DATA_SOURCE');
	    fnd_msg_pub.add;
       END IF;
       x_loading_status := 'CN_INVALID_DATA_SOURCE';
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     --+
     -- Derive batch_id and not_trx_id
     --+
     SELECT FLOOR(cn_not_trx_s.CURRVAL/NVL(cn_global_var.g_system_batch_size,200)),
            cn_not_trx_s.NEXTVAL
     INTO   l_batch_id,
            l_not_trx_id
     FROM   DUAL;
     --+
     -- Insert a new row for this source_trx_line into cn_not_trx_all,
     -- with collected_flag = 'N'
     --+
     INSERT INTO cn_not_trx_all (
       org_id,
       not_trx_id,
       batch_id,
       notified_date,
       processed_date,
       notification_run_id,
       collected_flag,
       source_trx_id,
       source_trx_line_id,
	  source_doc_type,
       adjusted_flag,
       event_id)
     VALUES
       (l_org_id,
       l_not_trx_id,
       l_batch_id,
       SYSDATE,
       SYSDATE,
       l_proc_audit_id,
       'N',
       p_header_id,
       p_line_id,
	  p_source_doc_type,
       p_adjusted_flag,
       l_event_id);
   END IF;
   --   +
   -- End of API body.
   --+

   --+
   -- Post processing hooks
   --+

   -- SK Start of post processing hooks

   -- vertical post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_NOTIFICATION_PUB',
				'CREATE_NOTIFICATION',
				'A',
				'V')
   THEN
     cn_notification_pub_vuhk.create_notification_post
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status	=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      p_line_id          => p_line_id,
      p_source_doc_type  => p_source_doc_type,
      p_adjusted_flag    => p_adjusted_flag,
      p_header_id        => p_header_id,
      p_org_id           => p_org_id,
      x_loading_status   => x_loading_status);

     IF x_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- customer post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_NOTIFICATION_PUB',
				'CREATE_NOTIFICATION',
				'A',
				'C')
   THEN
     cn_notification_pub_cuhk.create_notification_post
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status	=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      p_line_id          => p_line_id,
      p_source_doc_type  => p_source_doc_type,
      p_adjusted_flag    => p_adjusted_flag,
      p_header_id        => p_header_id,
      p_org_id           => p_org_id,
      x_loading_status   => x_loading_status);

     IF x_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;
   -- SK End of post processing hooks


   -- Message generation section.
   IF JTF_USR_HKS.Ok_to_execute('CN_NOTIFICATION_PUB',
				'CREATE_NOTIFICATION',
				'M',
				'M') THEN
     IF  cn_notification_pub_cuhk.ok_to_generate_msg
        (p_not_trx_id => l_not_trx_id) THEN
	  -- Clear bind variables
--	  XMLGEN.clearBindValues;

	  -- Set values for bind variables,
	  -- call this for all bind variables in the business object
--	  XMLGEN.setBindValue('TRANSACTION_LINE_ID', p_line_id);

       -- get ID for all the bind_variables in a Business Object.
       l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

       JTF_USR_HKS.load_bind_data(l_bind_data_id, 'TRANSACTION_LINE_ID', p_line_id, 'S', 'N');

	 -- Message generation API
       JTF_USR_HKS.generate_message(
                 p_prod_code    => 'CN',
                 p_bus_obj_code => 'NOT',
                 p_bus_obj_name => 'CRT_NOTIFICATION',
                 p_action_code  => 'I',     /* I - Insert  */
                 p_bind_data_id => l_bind_data_id,
                 p_OAI_param    => NULL,
                 p_OAI_array    => l_OAI_array,
                 x_return_code  => l_return_code);

	 IF (l_return_code = FND_API.G_RET_STS_ERROR)
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

/*
	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'CRT_NOTIFICATION',
	    p_bus_obj_name => 'NOTIFICATION',
	    p_action_code  => 'I',
	    p_oai_param    => null,
	    p_oai_array    => l_oai_array,
	    x_return_code  => x_return_status) ;

	 IF (x_return_status = FND_API.G_RET_STS_ERROR)
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

*/
     END IF;
   END IF;  --message generation section


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
      ROLLBACK TO Create_Notification;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Notification;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Notification;
      x_loading_status := 'UNEXPECTED_ERR';
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
END Create_Notification;

END CN_Notification_PUB;

/
