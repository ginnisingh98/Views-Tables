--------------------------------------------------------
--  DDL for Package Body OZF_SD_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SD_BATCH_PUB" AS
/* $Header: ozfpsdbb.pls 120.0.12010000.7 2009/05/18 09:47:05 annsrini noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30)   := 'OZF_SD_BATCH_PUB';
  G_FILE_NAME CONSTANT VARCHAR2(12)  := 'ozfpsdbb.pls';

-- Start of comments
--	API name        : MARK_BATCH_SUBMITTED
--	Type            : Public
--	Pre-reqs        : None.
--	Parameters      :
--	IN              :       p_api_version_number    IN   NUMBER
--                      :       p_init_msg_list         IN   VARCHAR2
--                      :       p_batch_id		IN   NUMBER
--      OUT             :       x_return_status         OUT  VARCHAR2
--                      :       x_msg_count             OUT  NUMBER
--                      :       x_msg_data              OUT  VARCHAR
--
-- End of comments

  PROCEDURE MARK_BATCH_SUBMITTED (p_api_version_number  IN NUMBER,
			          p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                                  p_batch_id	        IN NUMBER,
			          x_return_status       OUT nocopy VARCHAR2,
                 	          x_msg_count 	        OUT nocopy NUMBER,
			          x_msg_data            OUT nocopy VARCHAR2
			          ) IS

  l_cnt_hdr          number;
  l_cnt_line         number;
  l_status           varchar2(30);

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'MARK_BATCH_SUBMITTED';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  BEGIN

-- Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
	p_api_version_number,
	l_api_name,
	G_PKG_NAME)
  THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

  -- Initialize API return status to sucess
  x_return_status := fnd_api.g_ret_sts_success;

	  SELECT COUNT(1)
	    INTO l_cnt_hdr
            FROM ozf_sd_batch_headers_all
           WHERE batch_id = p_batch_id;

	   IF l_cnt_hdr = 0 THEN
              x_return_status := fnd_api.g_ret_sts_error;
              x_msg_data      := 'This Batch ID does not exist ' || p_batch_id ;
       	      RETURN;
	   END IF;

         SELECT STATUS_CODE
	   INTO l_status
	   FROM ozf_sd_batch_headers_all
          WHERE batch_id = p_batch_id;

           IF l_status NOT IN ('NEW','WIP') THEN
              x_return_status := fnd_api.g_ret_sts_error;
              x_msg_data      := 'Batch is not in NEW or WIP status ' || p_batch_id ;
       	      RETURN;
	   END IF;

	  SELECT COUNT(1)
	    INTO l_cnt_line
            FROM ozf_sd_batch_lines_all
           WHERE batch_id = p_batch_id
	     AND purge_flag <> 'Y'
	     AND transmit_flag = 'Y';

	   IF l_cnt_line = 0 THEN
              x_return_status := fnd_api.g_ret_sts_error;
              x_msg_data      := 'There are no Lines in this Batch which are ready for transmission ' || p_batch_id ;
       	      RETURN;
	   END IF;

	   IF l_status = 'NEW' THEN
	       UPDATE ozf_sd_batch_headers_all
		  SET status_code = 'SUBMITTED',
		      object_version_number  = object_version_number + 1,
		      batch_submission_date = SYSDATE,
		      last_update_login = NVL(FND_GLOBAL.conc_login_id,-1),
		      last_update_date = SYSDATE,
		      last_updated_by  = NVL(FND_GLOBAL.user_id,-1)
		WHERE batch_id = p_batch_id;
	   END IF;

	   IF l_status = 'WIP' THEN
	       UPDATE ozf_sd_batch_line_disputes
		  SET object_version_number  = object_version_number + 1,
		      review_flag = 'Y',
		      last_update_login = NVL(FND_GLOBAL.conc_login_id,-1),
		      last_update_date = SYSDATE,
		      last_updated_by  = NVL(FND_GLOBAL.user_id,-1)
		WHERE batch_id = p_batch_id
		  AND batch_line_id IN ( SELECT batch_line_id
		                           FROM ozf_sd_batch_lines_all
					  WHERE batch_id = p_batch_id
					    AND purge_flag <> 'Y'
					    AND transmit_flag = 'Y' );
	   END IF;

		UPDATE ozf_sd_batch_lines_all
		   SET status_code = 'SUBMITTED',
		       object_version_number  = object_version_number + 1,
		       transmit_flag = 'N',
		       process_feed_flag = 'Y',
		       last_sub_claim_amount = batch_curr_claim_amount,
		       last_update_login = NVL(FND_GLOBAL.conc_login_id,-1),
		       last_update_date = SYSDATE,
		       last_updated_by  = NVL(FND_GLOBAL.user_id,-1)
		 WHERE batch_id = p_batch_id
		   AND purge_flag <> 'Y'
		   AND transmit_flag = 'Y';

          EXCEPTION
          WHEN FND_API.g_exc_error THEN
	    x_return_status := FND_API.g_ret_sts_error;
	    FND_MSG_PUB.count_and_get (
		   p_encoded => FND_API.g_false
		  ,p_count   => x_msg_count
		  ,p_data    => x_msg_data
	    );

	  WHEN FND_API.g_exc_unexpected_error THEN
	    x_return_status := FND_API.g_ret_sts_unexp_error ;
	    FND_MSG_PUB.count_and_get (
		   p_encoded => FND_API.g_false
		  ,p_count   => x_msg_count
		  ,p_data    => x_msg_data
	    );

	  WHEN OTHERS THEN
	    x_return_status := FND_API.g_ret_sts_unexp_error ;
	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
	    END IF;
	    FND_MSG_PUB.count_and_get(
		   p_encoded => FND_API.g_false
		  ,p_count   => x_msg_count
		  ,p_data    => x_msg_data
	    );

  END MARK_BATCH_SUBMITTED;

END OZF_SD_BATCH_PUB;

/
