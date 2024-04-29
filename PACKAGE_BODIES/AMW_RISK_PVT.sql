--------------------------------------------------------
--  DDL for Package Body AMW_RISK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_RISK_PVT" as
/* $Header: amwvrskb.pls 120.0 2005/05/31 23:24:25 appldev noship $ */

-- ===============================================================
-- Package name
--          AMW_Risk_PVT
-- Purpose
-- 		  	for Import Risk : Load_Risk (without knowing any risk_id in advance)
--			for direct call : Operate_Risk (knowing risk_id or risk_rev_id)
-- History
-- 		  	7/23/2003    tsho     Creates
-- 		  	12/09/2004   tsho     modify for new column in base table: Classification
--		        01/05/2005   tsho     add Approve_Risk procedure to approve risk without workflow
-- ===============================================================


G_PKG_NAME 	CONSTANT VARCHAR2(30)	:= 'AMW_Risk_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) 	:= 'amwvrskb.pls';


-- ===============================================================
-- Procedure name
--          Load_Risk
-- Purpose
-- 		  	for Import Risk with approval_status 'A' or 'D'
-- ===============================================================
PROCEDURE Load_Risk(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rev_id      		 OUT  NOCOPY NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Load_Risk';
l_dummy       					 		  NUMBER;
l_dummy_risk_rec risk_rec_type 	 		  			   := NULL;

CURSOR c_name_exists (l_risk_name IN VARCHAR2) IS
      SELECT risk_id
      FROM amw_risks_all_vl
      WHERE name = l_risk_name;
l_risk_id amw_risks_all_vl.risk_id%TYPE;

CURSOR c_revision_exists (l_risk_id IN NUMBER) IS
      SELECT count(*)
      FROM amw_risks_b
      GROUP BY risk_id
	  HAVING risk_id=l_risk_id;

CURSOR c_approval_status (l_risk_id IN NUMBER) IS
      SELECT risk_rev_id,
			 approval_status
      FROM amw_risks_b
	  WHERE risk_id=l_risk_id AND
	  		latest_revision_flag='Y';
l_approval_status c_approval_status%ROWTYPE;


BEGIN
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
	  x_return_status := G_RET_STS_SUCCESS;


	  IF p_risk_rec.approval_status ='P' THEN
	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_INVALID_STATUS',
                                      p_token_name   => 'OBJ_TYPE',
                                      p_token_value  =>  G_OBJ_TYPE);
      	RAISE FND_API.G_EXC_ERROR;
	  ELSIF p_risk_rec.approval_status ='R' THEN
	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_INVALID_STATUS',
                                      p_token_name   => 'OBJ_TYPE',
                                      p_token_value  =>  G_OBJ_TYPE);
      	RAISE FND_API.G_EXC_ERROR;
	  ELSIF p_risk_rec.approval_status IS NOT NULL AND p_risk_rec.approval_status <> 'A' AND p_risk_rec.approval_status <> 'D' THEN
	  	-- if it's null, the default will be 'D' , other pass-in unwanted data will be Invalid
	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_INVALID_STATUS',
                                      p_token_name   => 'OBJ_TYPE',
                                      p_token_value  =>  G_OBJ_TYPE);
      	RAISE FND_API.G_EXC_ERROR;
	  END IF;


      l_risk_id := NULL;
	  OPEN c_name_exists(p_risk_rec.risk_name);
	  FETCH c_name_exists INTO l_risk_id;
	  CLOSE c_name_exists;

	  IF l_risk_id IS NULL THEN
  	    -- no existing risk with  pass-in risk_name, then call operation with mode G_OP_CREATE
		Operate_Risk(
		    p_operate_mode 		  => G_OP_CREATE,
		    p_api_version_number  => p_api_version_number,
		    p_init_msg_list       => p_init_msg_list,
		    p_commit     		  => p_commit,
		    p_validation_level    => p_validation_level,
		    x_return_status       => x_return_status,
		    x_msg_count     	  => x_msg_count,
		    x_msg_data     		  => x_msg_data,
		    p_risk_rec     		  => p_risk_rec,
		    x_risk_rev_id     	  => x_risk_rev_id,
		    x_risk_id     		  => x_risk_id);
      	IF x_return_status<>G_RET_STS_SUCCESS THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                        p_token_name   => 'OBJ_TYPE',
                                        p_token_value  =>  G_OBJ_TYPE);
          RAISE FND_API.G_EXC_ERROR;
      	END IF;

	  ELSE
	  	l_dummy_risk_rec := p_risk_rec;
		l_dummy_risk_rec.risk_id := l_risk_id;
	  	l_dummy := NULL;
	    OPEN c_revision_exists(l_risk_id);
	    FETCH c_revision_exists INTO l_dummy;
	    CLOSE c_revision_exists;

		IF l_dummy IS NULL OR l_dummy < 1 THEN
		    -- no corresponding risk_id in AMW_RISKS_B is wrong
	  	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNEXPECT_ERROR',
                                          p_token_name   => 'OBJ_TYPE',
                                          p_token_value  =>  G_OBJ_TYPE);
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_dummy = 1 THEN
			-- has only one record for risk_id in AMW_RISKS_B with pass-in name
			OPEN c_approval_status(l_risk_id);
	    	FETCH c_approval_status INTO l_approval_status;
	    	CLOSE c_approval_status;

			IF l_approval_status.approval_status='P' THEN
			   -- this record is Pending Approval, cannot do G_OP_UPDATE or G_OP_REVISE
			   AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_PENDING_CHANGE_ERROR',
                                             p_token_name   => 'OBJ_TYPE',
                                             p_token_value  =>  G_OBJ_TYPE);
	   		   RAISE FND_API.G_EXC_ERROR;
			ELSIF l_approval_status.approval_status='D' THEN
		   	   Operate_Risk(
		   	   		p_operate_mode 			=> G_OP_UPDATE,
					p_api_version_number    => p_api_version_number,
					p_init_msg_list     	=> p_init_msg_list,
					p_commit     			=> p_commit,
		    		p_validation_level     	=> p_validation_level,
		    		x_return_status     	=> x_return_status,
		    		x_msg_count     		=> x_msg_count,
		    		x_msg_data     			=> x_msg_data,
		    		p_risk_rec     			=> l_dummy_risk_rec,
		    		x_risk_rev_id     		=> x_risk_rev_id,
		    		x_risk_id     			=> x_risk_id);
		      IF x_return_status<>G_RET_STS_SUCCESS THEN
	  	  	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                p_token_name   => 'OBJ_TYPE',
                                                p_token_value  =>  G_OBJ_TYPE);
		          RAISE FND_API.G_EXC_ERROR;
		      END IF;

			ELSIF l_approval_status.approval_status='A' OR l_approval_status.approval_status='R' THEN
		   	   Operate_Risk(
		   	   		p_operate_mode 			=> G_OP_REVISE,
					p_api_version_number    => p_api_version_number,
					p_init_msg_list     	=> p_init_msg_list,
					p_commit     			=> p_commit,
		    		p_validation_level     	=> p_validation_level,
		    		x_return_status     	=> x_return_status,
		    		x_msg_count     		=> x_msg_count,
		    		x_msg_data     			=> x_msg_data,
		    		p_risk_rec     			=> l_dummy_risk_rec,
		    		x_risk_rev_id     		=> x_risk_rev_id,
		    		x_risk_id     			=> x_risk_id);
		      IF x_return_status<>G_RET_STS_SUCCESS THEN
			  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                p_token_name   => 'OBJ_TYPE',
                                                p_token_value  => G_OBJ_TYPE);
		          RAISE FND_API.G_EXC_ERROR;
		      END IF;

			END IF; -- end of if:l_approval_status.approval_status
		ELSE
			-- l_dummy > 1 : has revised before
			Operate_Risk(
		    	p_operate_mode 	 		 => G_OP_REVISE,
		    	p_api_version_number     => p_api_version_number,
		    	p_init_msg_list     	 => p_init_msg_list,
		    	p_commit     			 => p_commit,
		    	p_validation_level     	 => p_validation_level,
		    	x_return_status     	 => x_return_status,
		    	x_msg_count     		 => x_msg_count,
		    	x_msg_data     			 => x_msg_data,
		    	p_risk_rec     			 => l_dummy_risk_rec,
		    	x_risk_rev_id     		 => x_risk_rev_id,
		    	x_risk_id     			 => x_risk_id);
		      IF x_return_status<>G_RET_STS_SUCCESS THEN
			  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                p_token_name   => 'OBJ_TYPE',
                                                p_token_value  => G_OBJ_TYPE);
		          RAISE FND_API.G_EXC_ERROR;
		      END IF;

		END IF; -- end of if:l_dummy

	  END IF; -- end of if:l_risk_id

      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(
	  	 p_count   => x_msg_count,
         p_data    => x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN

     x_return_status := G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END Load_Risk;



-- ===============================================================
-- Procedure name
--          Operate_Risk
-- Purpose
-- 		  	operate risk depends on the pass-in p_operate_mode:
--			G_OP_CREATE
--			G_OP_UPDATE
--			G_OP_REVISE
--			G_OP_DELETE
-- Notes
-- 			the G_OP_UPDATE mode here is in business logic meaning,
--			not as the same as update in table handler meaning.
--			same goes to other p_operate_mode  if it happens to
--			have similar name.
-- ===============================================================
PROCEDURE Operate_Risk(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rev_id      		 OUT  NOCOPY NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
    )
IS
l_api_name 					 CONSTANT VARCHAR2(30) := 'Operate_Risk';
l_risk_rev_id 				 		  NUMBER 	   := NULL;
l_dummy_risk_rec risk_rec_type;

CURSOR c_draft_revision (l_risk_id IN NUMBER) IS
      SELECT risk_rev_id
      FROM amw_risks_b
      WHERE risk_id = l_risk_id AND approval_status='D' AND latest_revision_flag='Y';

BEGIN
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list )
     THEN
        FND_MSG_PUB.initialize;
     END IF;

     AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

	 IF p_operate_mode = G_OP_CREATE THEN
	 	l_dummy_risk_rec := p_risk_rec;
		l_dummy_risk_rec.object_version_number := 1;
		l_dummy_risk_rec.risk_rev_num := 1;
		l_dummy_risk_rec.latest_revision_flag := 'Y';

		IF p_risk_rec.approval_status = 'A' THEN
			l_dummy_risk_rec.approval_status := 'A';
			l_dummy_risk_rec.curr_approved_flag := 'Y';
			l_dummy_risk_rec.approval_date := SYSDATE;
		ELSE
			l_dummy_risk_rec.approval_status := 'D';
			l_dummy_risk_rec.curr_approved_flag := 'N';
		END IF;

		Create_Risk(
		    p_operate_mode 			=> p_operate_mode,
		    p_api_version_number    => p_api_version_number,
		    p_init_msg_list     	=> p_init_msg_list,
		    p_commit     			=> p_commit,
		    p_validation_level     	=> p_validation_level,
		    x_return_status     	=> x_return_status,
		    x_msg_count     		=> x_msg_count,
		    x_msg_data     			=> x_msg_data,
		    p_risk_rec     			=> l_dummy_risk_rec,
		    x_risk_rev_id     		=> x_risk_rev_id,
		    x_risk_id     			=> x_risk_id);

			IF x_return_status<>G_RET_STS_SUCCESS THEN
			  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                p_token_name   => 'OBJ_TYPE',
                                                p_token_value  => G_OBJ_TYPE);
		       RAISE FND_API.G_EXC_ERROR;
		    END IF;

	 ELSIF p_operate_mode = G_OP_UPDATE THEN
 	 	l_dummy_risk_rec := p_risk_rec;
		l_dummy_risk_rec.curr_approved_flag := 'N';
		l_dummy_risk_rec.latest_revision_flag := 'Y';

		IF p_risk_rec.approval_status = 'A' THEN
			l_dummy_risk_rec.approval_status := 'A';
			l_dummy_risk_rec.curr_approved_flag := 'Y';
			l_dummy_risk_rec.approval_date := SYSDATE;
		ELSE
			l_dummy_risk_rec.approval_status := 'D';
			l_dummy_risk_rec.curr_approved_flag := 'N';
		END IF;


		Update_Risk(
		    p_operate_mode 			=> p_operate_mode,
		    p_api_version_number    => p_api_version_number,
		    p_init_msg_list     	=> p_init_msg_list,
		    p_commit     			=> p_commit,
		    p_validation_level     	=> p_validation_level,
		    x_return_status     	=> x_return_status,
		    x_msg_count     		=> x_msg_count,
		    x_msg_data     			=> x_msg_data,
		    p_risk_rec     			=> l_dummy_risk_rec,
		    x_risk_rev_id     		=> x_risk_rev_id,
		    x_risk_id     			=> x_risk_id);

			IF x_return_status<>G_RET_STS_SUCCESS THEN
		  	   AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                             p_token_name   => 'OBJ_TYPE',
                                             p_token_value  => G_OBJ_TYPE);
		       RAISE FND_API.G_EXC_ERROR;
		    END IF;

	 ELSIF p_operate_mode = G_OP_REVISE THEN
	 	   l_risk_rev_id := NULL;
		   OPEN c_draft_revision(p_risk_rec.risk_id);
		   FETCH c_draft_revision INTO l_risk_rev_id;
		   CLOSE c_draft_revision;

	 	   -- has revision with APPROVAL_STATUS='D' exists
		   IF l_risk_rev_id IS NOT NULL THEN
		   	  l_dummy_risk_rec := p_risk_rec;
			  l_dummy_risk_rec.latest_revision_flag := 'Y';

			  IF p_risk_rec.approval_status = 'A' THEN
			  	 l_dummy_risk_rec.approval_status := 'A';
				 l_dummy_risk_rec.curr_approved_flag := 'Y';
				 l_dummy_risk_rec.approval_date := SYSDATE;
			  ELSE
			  	 l_dummy_risk_rec.approval_status := 'D';
				 l_dummy_risk_rec.curr_approved_flag := 'N';
			  END IF;


		   	  Update_Risk(
			      p_operate_mode 		=> p_operate_mode,
				  p_api_version_number 	=> p_api_version_number,
				  p_init_msg_list 		=> p_init_msg_list,
				  p_commit 				=> p_commit,
				  p_validation_level 	=> p_validation_level,
				  x_return_status 		=> x_return_status,
				  x_msg_count 			=> x_msg_count,
				  x_msg_data 			=> x_msg_data,
				  p_risk_rec 			=> l_dummy_risk_rec,
				  x_risk_rev_id 		=> x_risk_rev_id,
				  x_risk_id 			=> x_risk_id);

				  IF x_return_status<>G_RET_STS_SUCCESS THEN
				     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                   p_token_name   => 'OBJ_TYPE',
                                                   p_token_value  => G_OBJ_TYPE);
				  	 RAISE FND_API.G_EXC_ERROR;
		    	  END IF;

		   ELSE
		   	  l_dummy_risk_rec := p_risk_rec;


		   	  Revise_Without_Revision_Exists(
			      p_operate_mode => p_operate_mode,
				  p_api_version_number => p_api_version_number,
				  p_init_msg_list => p_init_msg_list,
				  p_commit => p_commit,
				  p_validation_level => p_validation_level,
				  x_return_status => x_return_status,
				  x_msg_count => x_msg_count,
				  x_msg_data => x_msg_data,
				  p_risk_rec => l_dummy_risk_rec,
				  x_risk_rev_id => x_risk_rev_id,
				  x_risk_id => x_risk_id);

			  IF x_return_status<>G_RET_STS_SUCCESS THEN
		  	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                p_token_name   => 'OBJ_TYPE',
                                                p_token_value  => G_OBJ_TYPE);
			  	 RAISE FND_API.G_EXC_ERROR;
		      END IF;

		   END IF;
	 ELSIF p_operate_mode = G_OP_DELETE THEN
		Delete_Risk(
		    p_operate_mode 			=> p_operate_mode,
		    p_api_version_number    => p_api_version_number,
		    p_init_msg_list     	=> p_init_msg_list,
		    p_commit     			=> p_commit,
		    p_validation_level     	=> p_validation_level,
		    x_return_status     	=> x_return_status,
		    x_msg_count     		=> x_msg_count,
		    x_msg_data     			=> x_msg_data,
		    p_risk_rev_id     		=> p_risk_rec.risk_rev_id,
			x_risk_id     			=> x_risk_id);

			IF x_return_status<>G_RET_STS_SUCCESS THEN
		  	   AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                             p_token_name   => 'OBJ_TYPE',
                                             p_token_value  => G_OBJ_TYPE);
		       RAISE FND_API.G_EXC_ERROR;
		    END IF;

	 ELSE
  	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNEXPECT_ERROR',
                                       p_token_name   => 'OBJ_TYPE',
                                       p_token_value  => G_OBJ_TYPE);
	 	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count  => x_msg_count,
         p_data   => x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
     x_return_status := G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END Operate_Risk;




-- ===============================================================
-- Procedure name
--          Create_Risk
-- Purpose
-- 		  	create risk with specified approval_status,
--			if no specified approval_status in pass-in p_risk_rec,
--			the default approval_status is set to 'D'.
-- ===============================================================
PROCEDURE Create_Risk(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rev_id                OUT  NOCOPY NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
     )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Risk';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_return_status_full        		 VARCHAR2(1);
l_object_version_number     		 NUMBER := 1;
l_RISK_ID                  			 NUMBER;
l_RISK_REV_ID                  		 NUMBER;
l_dummy       						 NUMBER;
l_risk_rec							 risk_rec_type;
l_dummy_risk_rec 					 risk_rec_type;
l_row_id		 			   		 amw_risks_all_vl.row_id%TYPE;

CURSOR c_rev_id IS
      SELECT AMW_RISK_REV_ID_S.NEXTVAL
      FROM dual;

CURSOR c_rev_id_exists (l_rev_id IN NUMBER) IS
      SELECT 1
      FROM AMW_RISKS_B
      WHERE RISK_REV_ID = l_rev_id;

CURSOR c_id IS
      SELECT AMW_RISK_ID_S.NEXTVAL
      FROM dual;

CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMW_RISKS_B
      WHERE RISK_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Risk_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

	  AMW_UTILITY_PVT.debug_message('p_operate_mode: ' || p_operate_mode);
      -- Initialize API return status to SUCCESS
      x_return_status := G_RET_STS_SUCCESS;

   IF p_risk_rec.RISK_REV_ID IS NULL OR p_risk_rec.RISK_REV_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_rev_id;
         FETCH c_rev_id INTO l_RISK_REV_ID;
         CLOSE c_rev_id;

         OPEN c_rev_id_exists(l_RISK_REV_ID);
         FETCH c_rev_id_exists INTO l_dummy;
         CLOSE c_rev_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
   	  l_risk_rev_id := p_risk_rec.risk_rev_id;
   END IF;

   IF p_risk_rec.RISK_ID IS NULL OR p_risk_rec.RISK_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_RISK_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_RISK_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
   	  l_risk_id := p_risk_rec.risk_id;
   END IF;

   x_risk_id := l_risk_id;
   x_risk_rev_id := l_risk_rev_id;

   l_risk_rec := p_risk_rec;
   l_risk_rec.risk_id := l_risk_id;
   l_risk_rec.risk_rev_id := l_risk_rev_id;


      IF FND_GLOBAL.User_Id IS NULL THEN
 	  	 AMW_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (P_validation_level >= G_VALID_LEVEL_FULL) THEN
          AMW_UTILITY_PVT.debug_message('Private API: Validate_Risk');

          -- Invoke validation procedures
          Validate_risk(
 		    p_operate_mode     		=> p_operate_mode,
            p_api_version_number    => p_api_version_number,
            p_init_msg_list    		=> G_FALSE,
            p_validation_level 		=> p_validation_level,
            p_risk_rec  			=> l_risk_rec,
            x_risk_rec  			=> l_dummy_risk_rec,
            x_return_status    		=> x_return_status,
            x_msg_count        		=> x_msg_count,
            x_msg_data         		=> x_msg_data);
      END IF;

      IF x_return_status<>G_RET_STS_SUCCESS THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                        p_token_name   => 'OBJ_TYPE',
                                        p_token_value  => G_OBJ_TYPE);
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      AMW_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

	  -- Invoke table handler(AMW_RISKS_PKG.Insert_Row)
	  AMW_UTILITY_PVT.debug_message( 'Private API: Calling AMW_RISKS_PKG.Insert_Row');
      AMW_RISKS_PKG.Insert_Row(
					  x_rowid		 	   			=> l_row_id,
			          x_name 		 	   			=> l_dummy_risk_rec.risk_name,
					  x_description 	   			=> l_dummy_risk_rec.risk_description,
          			  x_risk_id  		   			=> l_dummy_risk_rec.risk_id,
          			  x_last_update_date   			=> SYSDATE,
          			  x_last_update_login  			=> G_LOGIN_ID,
          			  x_created_by  	   			=> G_USER_ID,
					  x_last_updated_by    			=> G_USER_ID,
          			  x_risk_impact  	   			=> l_dummy_risk_rec.risk_impact,
          			  x_likelihood  	   			=> l_dummy_risk_rec.likelihood,
          			  x_attribute_category 			=> l_dummy_risk_rec.attribute_category,
          			  x_attribute1  	   			=> l_dummy_risk_rec.attribute1,
          			  x_attribute2  	   			=> l_dummy_risk_rec.attribute2,
          			  x_attribute3  	   			=> l_dummy_risk_rec.attribute3,
          			  x_attribute4  	   			=> l_dummy_risk_rec.attribute4,
          			  x_attribute5  	   			=> l_dummy_risk_rec.attribute5,
          			  x_attribute6  	   			=> l_dummy_risk_rec.attribute6,
          			  x_attribute7  	   			=> l_dummy_risk_rec.attribute7,
          			  x_attribute8  	  			=> l_dummy_risk_rec.attribute8,
          			  x_attribute9  	   			=> l_dummy_risk_rec.attribute9,
          			  x_attribute10  	   			=> l_dummy_risk_rec.attribute10,
          			  x_attribute11  	   			=> l_dummy_risk_rec.attribute11,
          			  x_attribute12  	   			=> l_dummy_risk_rec.attribute12,
          			  x_attribute13  	   			=> l_dummy_risk_rec.attribute13,
          			  x_attribute14  	   			=> l_dummy_risk_rec.attribute14,
          			  x_attribute15  	   			=> l_dummy_risk_rec.attribute15,
          			  x_security_group_id  			=> l_dummy_risk_rec.security_group_id,
          			  x_risk_type  		   			=> l_dummy_risk_rec.risk_type,
          			  x_approval_status    			=> l_dummy_risk_rec.approval_status,
          			  x_object_version_number  		=> l_object_version_number,
          			  x_approval_date  				=> l_dummy_risk_rec.approval_date,
          			  x_creation_date  				=> SYSDATE,
          			  x_risk_rev_num  				=> l_dummy_risk_rec.risk_rev_num,
          			  x_risk_rev_id  				=> l_dummy_risk_rec.risk_rev_id,
          			  x_requestor_id  				=> l_dummy_risk_rec.requestor_id,
          			  x_orig_system_reference  		=> l_dummy_risk_rec.orig_system_reference,
          			  x_latest_revision_flag  		=> l_dummy_risk_rec.latest_revision_flag,
          			  x_end_date  					=> l_dummy_risk_rec.end_date,
          			  x_curr_approved_flag  		=> l_dummy_risk_rec.curr_approved_flag,
					  X_MATERIAL   					=> l_dummy_risk_rec.material,
                      X_CLASSIFICATION				=> l_dummy_risk_rec.classification);

      IF x_return_status <> G_RET_STS_SUCCESS THEN
  	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                       p_token_name   => 'OBJ_TYPE',
                                       p_token_value  => G_OBJ_TYPE);
       	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data);

EXCEPTION
   WHEN AMW_UTILITY_PVT.resource_locked THEN
     x_return_status := G_RET_STS_ERROR;
 	 AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Risk_PVT;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Risk_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Risk_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

End Create_Risk;



-- ===============================================================
-- Procedure name
--          Update_Risk
-- Purpose
-- 		  	update risk with specified risk_rev_id,
--			if no specified risk_rev_id in pass-in p_risk_rec,
--			this will update the one with specified risk_id having
--			latest_revision_flag='Y' AND approval_status='D'.
-- Notes
-- 			if risk_rev_id is not specified, then
-- 			risk_id is a must when calling Update_Risk
-- ===============================================================
PROCEDURE Update_Risk(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rev_id      		 OUT  NOCOPY NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
    )
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Risk';
l_api_version_number        CONSTANT NUMBER   	  := 1.0;
l_risk_rev_id    					 NUMBER;
l_risk_rec risk_rec_type;
l_dummy_risk_rec risk_rec_type;

CURSOR c_target_revision (l_risk_id IN NUMBER) IS
      SELECT risk_rev_id
      FROM amw_risks_b
      WHERE risk_id = l_risk_id AND approval_status='D' AND latest_revision_flag='Y';

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Risk_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := G_RET_STS_SUCCESS;

      AMW_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

	  -- if no specified target risk_rev_id, find if from risk_id
	  IF p_risk_rec.risk_rev_id IS NULL OR p_risk_rec.risk_rev_id = FND_API.g_miss_num THEN
	  	  l_risk_rev_id := NULL;
		  OPEN c_target_revision(p_risk_rec.risk_id);
		  FETCH c_target_revision INTO l_risk_rev_id;
		  CLOSE c_target_revision;
	  	  IF l_risk_rev_id IS NULL THEN
	  	  	 x_return_status := G_RET_STS_ERROR;
			 AMW_UTILITY_PVT.debug_message('l_risk_rev_id in Update_Risk is NULL');
	   	  	 RAISE FND_API.G_EXC_ERROR;
	  	  END IF;
	  ELSE
	  	  l_risk_rev_id := p_risk_rec.risk_rev_id;
	  END IF; -- end of if:p_risk_rec.risk_rev_id

   	  AMW_UTILITY_PVT.debug_message('l_risk_rev_id:'||l_risk_rev_id);

	  x_risk_id := p_risk_rec.risk_id;
   	  x_risk_rev_id := l_risk_rev_id;

	  l_risk_rec := p_risk_rec;
	  l_risk_rec.risk_rev_id := l_risk_rev_id;

      IF ( P_validation_level >= G_VALID_LEVEL_FULL)
      THEN
          AMW_UTILITY_PVT.debug_message('Private API: Validate_Risk');

          -- Invoke validation procedures
          Validate_risk(
		    p_operate_mode     		=> p_operate_mode,
            p_api_version_number    => p_api_version_number,
            p_init_msg_list    		=> G_FALSE,
            p_validation_level 		=> p_validation_level,
            p_risk_rec  			=> l_risk_rec,
            x_risk_rec  			=> l_dummy_risk_rec,
            x_return_status    		=> x_return_status,
            x_msg_count        		=> x_msg_count,
            x_msg_data         		=> x_msg_data);
      END IF;

      IF x_return_status<>G_RET_STS_SUCCESS THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                        p_token_name   => 'OBJ_TYPE',
                                        p_token_value  => G_OBJ_TYPE);
      	 RAISE FND_API.G_EXC_ERROR;
      END IF;

	  -- Invoke table handler(AMW_RISKS_PKG.Update_Row)
	  AMW_RISKS_PKG.Update_Row(
	  	 	  x_name 			  			 => l_dummy_risk_rec.risk_name,
  	  	  	  x_description 				 => l_dummy_risk_rec.risk_description,
          	  x_risk_id  					 => l_dummy_risk_rec.risk_id,
          	  x_last_update_date  			 => SYSDATE,
          	  x_last_update_login  			 => G_LOGIN_ID,
          	  x_last_updated_by  			 => G_USER_ID,
          	  x_risk_impact  				 => l_dummy_risk_rec.risk_impact,
          	  x_likelihood  				 => l_dummy_risk_rec.likelihood,
          	  x_attribute_category  		 => l_dummy_risk_rec.attribute_category,
          	  x_attribute1  				 => l_dummy_risk_rec.attribute1,
          	  x_attribute2  				 => l_dummy_risk_rec.attribute2,
          	  x_attribute3  				 => l_dummy_risk_rec.attribute3,
          	  x_attribute4  				 => l_dummy_risk_rec.attribute4,
          	  x_attribute5  				 => l_dummy_risk_rec.attribute5,
          	  x_attribute6  				 => l_dummy_risk_rec.attribute6,
          	  x_attribute7  				 => l_dummy_risk_rec.attribute7,
          	  x_attribute8  				 => l_dummy_risk_rec.attribute8,
          	  x_attribute9  				 => l_dummy_risk_rec.attribute9,
          	  x_attribute10  				 => l_dummy_risk_rec.attribute10,
          	  x_attribute11  				 => l_dummy_risk_rec.attribute11,
          	  x_attribute12  				 => l_dummy_risk_rec.attribute12,
          	  x_attribute13  				 => l_dummy_risk_rec.attribute13,
          	  x_attribute14  				 => l_dummy_risk_rec.attribute14,
          	  x_attribute15  				 => l_dummy_risk_rec.attribute15,
          	  x_security_group_id  			 => l_dummy_risk_rec.security_group_id,
          	  x_risk_type  					 => l_dummy_risk_rec.risk_type,
          	  x_approval_status  			 => l_dummy_risk_rec.approval_status,
          	  x_object_version_number  		 => l_dummy_risk_rec.object_version_number,
          	  x_approval_date  				 => l_dummy_risk_rec.approval_date,
          	  x_risk_rev_num  				 => l_dummy_risk_rec.risk_rev_num,
          	  x_risk_rev_id  				 => l_dummy_risk_rec.risk_rev_id,
          	  x_requestor_id  				 => l_dummy_risk_rec.requestor_id,
          	  x_orig_system_reference  		 => l_dummy_risk_rec.orig_system_reference,
          	  x_latest_revision_flag  		 => l_dummy_risk_rec.latest_revision_flag,
          	  x_end_date  					 => l_dummy_risk_rec.end_date,
          	  x_curr_approved_flag  		 => l_dummy_risk_rec.curr_approved_flag,
			  X_MATERIAL					 => l_dummy_risk_rec.material,
              X_CLASSIFICATION  			 => l_dummy_risk_rec.classification);

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count  => x_msg_count,
         p_data   => x_msg_data);

EXCEPTION

   WHEN AMW_UTILITY_PVT.resource_locked THEN
     x_return_status := G_RET_STS_ERROR;
 AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Risk_PVT;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Risk_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Risk_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

End Update_Risk;




-- ===============================================================
-- Procedure name
--          Delete_Risk
-- Purpose
-- 		  	delete risk with specified risk_rev_id.
-- ===============================================================
PROCEDURE Delete_Risk(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rev_id                IN   NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
    )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Risk';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Risk_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := G_RET_STS_SUCCESS;

      AMW_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(AMW_RISKS_PKG.Delete_Row)
      AMW_RISKS_PKG.Delete_Row(
          x_RISK_REV_ID  => p_RISK_REV_ID);


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data);

EXCEPTION

   WHEN AMW_UTILITY_PVT.resource_locked THEN
     x_return_status := G_RET_STS_ERROR;
 AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Risk_PVT;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Risk_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Risk_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

End Delete_Risk;



-- ===============================================================
-- Procedure name
--          Revise_Without_Revision_Exists
-- Purpose
-- 		  	revise risk with specified risk_id,
--			it'll revise the one having latest_revision_flag='Y'
--			AND approval_status='A' OR 'R' of specified risk_id.
--			the new revision created by this call will have
--			latest_revision_flag='Y', and the approval_status
--			will be set to 'D' if not specified in the p_risk_rec
--			the revisee(the old one) will have latest_revision_flag='N'
-- Note
-- 	   		actually the name for Revise_Without_Revision_Exists
--			should be Revise_Without_Draft_Revision_Exists if there's
--			no limitation for the procedure name.
-- ===============================================================
PROCEDURE Revise_Without_Revision_Exists(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rev_id      		 OUT  NOCOPY NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Revise_Without_Revision_Exists';
l_dummy_risk_rec risk_rec_type 	 		  			   := NULL;
l_risk_rec risk_rec_type 	 		  			   	   := NULL;
l_risk_description	amw_risks_tl.description%TYPE;

-- find the target revision to be revised
CURSOR c_target_revision (l_risk_id IN NUMBER) IS
      SELECT risk_rev_id,
	  		 risk_rev_num,
			 object_version_number
      FROM amw_risks_b
      WHERE risk_id = l_risk_id AND ( approval_status='A' OR approval_status='R') AND latest_revision_flag='Y';
target_revision c_target_revision%ROWTYPE;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT REVISE_Risk_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
         FND_MSG_PUB.initialize;
    END IF;

    AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


    -- Initialize API return status to SUCCESS
    x_return_status := G_RET_STS_SUCCESS;

    OPEN c_target_revision(p_risk_rec.risk_id);
	FETCH c_target_revision INTO target_revision;
	CLOSE c_target_revision;

    -- update the target(latest existing) revision
	l_risk_rec.risk_id := p_risk_rec.risk_id;
	l_risk_rec.risk_rev_id := target_revision.risk_rev_id;
	l_risk_rec.latest_revision_flag := 'N';
    -- 05.13.2004 tsho: bug 3595420, need to be consistent with UI
	--l_risk_rec.end_date := SYSDATE;
	l_risk_rec.object_version_number := target_revision.object_version_number+1;

  	IF p_risk_rec.approval_status = 'A' THEN
		l_risk_rec.curr_approved_flag := 'N';
        -- 05.13.2004 tsho: bug 3595420, need to be consistent with UI
	    l_risk_rec.end_date := SYSDATE;
	END IF;

    Complete_risk_Rec(
   	    p_risk_rec 	   => l_risk_rec,
		x_complete_rec => l_dummy_risk_rec);

	l_risk_description := l_dummy_risk_rec.risk_description;

	Update_Risk(
    	p_operate_mode 	  		=> p_operate_mode,
	    p_api_version_number    => p_api_version_number,
	    p_init_msg_list     	=> p_init_msg_list,
	    p_commit     			=> p_commit,
	    p_validation_level     	=> p_validation_level,
	    x_return_status     	=> x_return_status,
	    x_msg_count     		=> x_msg_count,
	    x_msg_data     			=> x_msg_data,
	    p_risk_rec     			=> l_dummy_risk_rec,
	    x_risk_rev_id     		=> x_risk_rev_id,
	    x_risk_id     			=> x_risk_id);

    IF x_return_status <> G_RET_STS_SUCCESS THEN
  	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                       p_token_name   => 'OBJ_TYPE',
                                       p_token_value  => G_OBJ_TYPE);
       	 RAISE FND_API.G_EXC_ERROR;
    END IF;


  	x_risk_id := p_risk_rec.risk_id;

	-- create the new revision
	l_dummy_risk_rec := p_risk_rec;
	l_dummy_risk_rec.latest_revision_flag := 'Y';
    l_dummy_risk_rec.object_version_number := 1;
    l_dummy_risk_rec.risk_rev_num := target_revision.risk_rev_num+1;

	IF p_risk_rec.risk_description IS NULL THEN
	   l_dummy_risk_rec.risk_description := l_risk_description;
	END IF;

  	IF p_risk_rec.approval_status = 'A' THEN
	   l_dummy_risk_rec.approval_status := 'A';
	   l_dummy_risk_rec.curr_approved_flag := 'Y';
	   l_dummy_risk_rec.approval_date := SYSDATE;
	ELSE
	   l_dummy_risk_rec.approval_status := 'D';
       -- 05.13.2004 tsho: bug 3595420, need to be consistent with UI
	   --l_dummy_risk_rec.curr_approved_flag := 'N';
       l_dummy_risk_rec.curr_approved_flag := 'R';
	END IF;

	Create_Risk(
	    p_operate_mode 			=> p_operate_mode,
	    p_api_version_number    => p_api_version_number,
	    p_init_msg_list     	=> p_init_msg_list,
	    p_commit     			=> p_commit,
	    p_validation_level     	=> p_validation_level,
	    x_return_status     	=> x_return_status,
	    x_msg_count     		=> x_msg_count,
	    x_msg_data     			=> x_msg_data,
	    p_risk_rec     			=> l_dummy_risk_rec,
	    x_risk_rev_id     		=> x_risk_rev_id,
	    x_risk_id     			=> x_risk_id);

    IF x_return_status <> G_RET_STS_SUCCESS THEN
  	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                       p_token_name   => 'OBJ_TYPE',
                                       p_token_value  => G_OBJ_TYPE);
       	 RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
         COMMIT WORK;
    END IF;

    AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count  => x_msg_count,
         p_data   => x_msg_data);

EXCEPTION

   WHEN AMW_UTILITY_PVT.resource_locked THEN
     x_return_status := G_RET_STS_ERROR;
 	 AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO REVISE_Risk_PVT;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO REVISE_Risk_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO REVISE_Risk_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END Revise_Without_Revision_Exists;



-- ===============================================================
-- Procedure name
--          check_risk_uk_items
-- Purpose
-- 		  	check the uniqueness of the items which have been marked
--			as unique in table
-- ===============================================================
PROCEDURE check_risk_uk_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_risk_rec 				 IN  risk_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
	)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := G_RET_STS_SUCCESS;

	  -- 07.23.2003 tsho
	  -- comment out for performance: since the uniqueness of
	  -- risk_rev_id and risk_id have been checked when creating
	  /*
      IF p_operate_mode = G_OP_CREATE THEN
         l_valid_flag := AMW_UTILITY_PVT.check_uniqueness(
         'AMW_RISKS_B',
         'RISK_REV_ID = ''' || p_risk_rec.RISK_REV_ID ||''''
         );
      ELSE
         l_valid_flag := AMW_UTILITY_PVT.check_uniqueness(
         'AMW_RISKS_B',
         'RISK_REV_ID = ''' || p_risk_rec.RISK_REV_ID ||
         ''' AND RISK_REV_ID <> ' || p_risk_rec.RISK_REV_ID
         );
      END IF;
	  */
END check_risk_uk_items;



-- ===============================================================
-- Procedure name
--          check_risk_req_items
-- Purpose
-- 		  	check the requireness of the items which have been marked
--			as NOT NULL in table
-- Note
-- 	   		since the standard default with
--			FND_API.G_MISS_XXX v.s. NULL has been changed to:
--			if user want to update to Null, pass in G_MISS_XXX
--			else if user want to update to some value, pass in value
--			else if user doesn't want to update, pass in NULL.
-- Reference
-- 			http://www-apps.us.oracle.com/atg/performance/
--			Standards and Templates>Business Object API Coding Standards
-- 			2.3.1 Differentiating between Missing parameters and Null parameters
-- ===============================================================
PROCEDURE check_risk_req_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_risk_rec 				 IN  risk_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
	)
IS
BEGIN
   x_return_status := G_RET_STS_SUCCESS;

   IF p_operate_mode = G_OP_CREATE THEN
       IF p_risk_rec.risk_impact IS NULL THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'risk_impact');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_risk_rec.likelihood  IS NULL THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'likelihood');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_risk_rec.risk_rev_num  IS NULL THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'risk_rev_num');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_risk_rec.latest_revision_flag  IS NULL THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'latest_revision_flag');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_risk_rec.curr_approved_flag IS NULL THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'curr_approved_flag');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   ELSE
       IF p_risk_rec.risk_rev_id = FND_API.g_miss_num THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'risk_rev_id');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
	   END IF;

   	   IF p_risk_rec.risk_id = FND_API.g_miss_num THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'risk_id');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
   	   END IF;

       IF p_risk_rec.risk_impact = FND_API.g_miss_char THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'risk_impact');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_risk_rec.likelihood = FND_API.g_miss_char THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'likelihood');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_risk_rec.risk_rev_num = FND_API.g_miss_num THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'risk_rev_num');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_risk_rec.latest_revision_flag = FND_API.g_miss_char THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'latest_revision_flag');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_risk_rec.curr_approved_flag = FND_API.g_miss_char THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'curr_approved_flag');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   END IF; -- end of if:p_operate_mode

END check_risk_req_items;



-- ===============================================================
-- Procedure name
--          check_risk_FK_items
-- Purpose
-- 		  	check forien key of the items
-- ===============================================================
PROCEDURE check_risk_FK_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_risk_rec 				 IN  risk_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
	)
IS
BEGIN
   x_return_status := G_RET_STS_SUCCESS;
END check_risk_FK_items;



-- ===============================================================
-- Procedure name
--          check_risk_Lookup_items
-- Purpose
-- 		  	check lookup of the items
-- ===============================================================
PROCEDURE check_risk_Lookup_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_risk_rec 				 IN  risk_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
	)
IS
BEGIN
   x_return_status := G_RET_STS_SUCCESS;
END check_risk_Lookup_items;



-- ===============================================================
-- Procedure name
--          Check_risk_Items
-- Purpose
-- 		  	check all the necessaries for items
-- Note
-- 	   		Check_risk_Items is the container for calling all the
--			other validation procedures on items(check_xxx_Items)
--			the validation on items should be only table column constraints
--			not the business logic validation.
-- ===============================================================
PROCEDURE Check_risk_Items (
    p_operate_mode 		         IN  VARCHAR2,
    P_risk_rec 				 IN  risk_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
    )
IS
BEGIN
   -- Check Items Uniqueness API calls
   check_risk_uk_items(
      p_operate_mode   		 => p_operate_mode,
      p_risk_rec 			 => p_risk_rec,
      x_return_status 		 => x_return_status);
   IF x_return_status <> G_RET_STS_SUCCESS THEN
  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  => G_OBJ_TYPE);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check Items Required/NOT NULL API calls
   check_risk_req_items(
      p_operate_mode 		 => p_operate_mode,
      p_risk_rec 			 => p_risk_rec,
      x_return_status 		 => x_return_status);
   IF x_return_status <> G_RET_STS_SUCCESS THEN
  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  => G_OBJ_TYPE);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check Items Foreign Keys API calls
   check_risk_FK_items(
      p_operate_mode   	  	 => p_operate_mode,
      p_risk_rec 			 => p_risk_rec,
      x_return_status 		 => x_return_status);
   IF x_return_status <> G_RET_STS_SUCCESS THEN
  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  => G_OBJ_TYPE);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check Items Lookups
   check_risk_Lookup_items(
      p_operate_mode 	     => p_operate_mode,
      p_risk_rec 			 => p_risk_rec,
      x_return_status 		 => x_return_status);
   IF x_return_status <> G_RET_STS_SUCCESS THEN
  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  => G_OBJ_TYPE);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

END Check_risk_Items;



-- ===============================================================
-- Procedure name
--          Complete_risk_Rec
-- Purpose
-- 		  	complete(fill out) the items which are not specified.
-- Note
-- 	   		basically, this is called when G_OP_UPDATE, G_OP_REVISE
-- ===============================================================
PROCEDURE Complete_risk_Rec (
   p_risk_rec 				IN  risk_rec_type,
   x_complete_rec 			OUT NOCOPY risk_rec_type
   )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Complete_risk_Rec';
l_return_status  				 		  VARCHAR2(1);

CURSOR c_complete IS
	  SELECT *
      FROM amw_risks_b
      WHERE risk_rev_id = p_risk_rec.risk_rev_id;
l_risk_rec c_complete%ROWTYPE;


CURSOR c_tl_complete IS
	  SELECT name,
	  		 description
      FROM amw_risks_all_vl
      WHERE risk_rev_id = p_risk_rec.risk_rev_id;
l_risk_tl_rec c_tl_complete%ROWTYPE;


BEGIN
   AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   x_complete_rec := p_risk_rec;

   OPEN c_complete;
   FETCH c_complete INTO l_risk_rec;
   CLOSE c_complete;

   OPEN c_tl_complete;
   FETCH c_tl_complete INTO l_risk_tl_rec;
   CLOSE c_tl_complete;

   -- risk_rev_id
   IF p_risk_rec.risk_rev_id IS NULL THEN
   	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNEXPECT_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  =>  G_OBJ_TYPE);
   	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- risk_id
   IF p_risk_rec.risk_id IS NULL THEN
      x_complete_rec.risk_id := l_risk_rec.risk_id;
   END IF;

   -- risk_name
   IF p_risk_rec.risk_name IS NULL THEN
      x_complete_rec.risk_name := l_risk_tl_rec.name;
   END IF;

   -- risk_description
   IF p_risk_rec.risk_description IS NULL THEN
      x_complete_rec.risk_description := l_risk_tl_rec.description;
   END IF;

   -- last_update_date
   IF p_risk_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_risk_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_risk_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_risk_rec.last_update_login;
   END IF;

   -- created_by
   IF p_risk_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_risk_rec.created_by;
   END IF;

   -- last_updated_by
   IF p_risk_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_risk_rec.last_updated_by;
   END IF;

   -- risk_impact
   IF p_risk_rec.risk_impact IS NULL THEN
      x_complete_rec.risk_impact := l_risk_rec.risk_impact;
   END IF;

   -- likelihood
   IF p_risk_rec.likelihood IS NULL THEN
      x_complete_rec.likelihood := l_risk_rec.likelihood;
   END IF;

   -- material
   IF p_risk_rec.material IS NULL THEN
      x_complete_rec.material := l_risk_rec.material;
   END IF;

   -- classification
   IF p_risk_rec.classification IS NULL THEN
      x_complete_rec.classification := l_risk_rec.classification;
   END IF;

   -- security_group_id
   IF p_risk_rec.security_group_id IS NULL THEN
      x_complete_rec.security_group_id := l_risk_rec.security_group_id;
   END IF;

   -- risk_type
   IF p_risk_rec.risk_type IS NULL THEN
      x_complete_rec.risk_type := l_risk_rec.risk_type;
   END IF;

   -- approval_status
   IF p_risk_rec.approval_status IS NULL THEN
      x_complete_rec.approval_status := l_risk_rec.approval_status;
   END IF;

   -- object_version_number
   IF p_risk_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_risk_rec.object_version_number;
   END IF;

   -- approval_date
   IF p_risk_rec.approval_date IS NULL THEN
      x_complete_rec.approval_date := l_risk_rec.approval_date;
   END IF;

   -- creation_date
   IF p_risk_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_risk_rec.creation_date;
   END IF;

   -- risk_rev_num
   IF p_risk_rec.risk_rev_num IS NULL THEN
      x_complete_rec.risk_rev_num := l_risk_rec.risk_rev_num;
   END IF;
   AMW_UTILITY_PVT.debug_message('risk_rev_num: ' || x_complete_rec.risk_rev_num);

   -- requestor_id
   IF p_risk_rec.requestor_id IS NULL THEN
      x_complete_rec.requestor_id := l_risk_rec.requestor_id;
   END IF;

   -- orig_system_reference
   IF p_risk_rec.orig_system_reference IS NULL THEN
      x_complete_rec.orig_system_reference := l_risk_rec.orig_system_reference;
   END IF;

   -- latest_revision_flag
   IF p_risk_rec.latest_revision_flag IS NULL THEN
      x_complete_rec.latest_revision_flag := l_risk_rec.latest_revision_flag;
   END IF;

   -- end_date
   IF p_risk_rec.end_date IS NULL THEN
      x_complete_rec.end_date := l_risk_rec.end_date;
   END IF;

   -- curr_approved_flag
   IF p_risk_rec.curr_approved_flag IS NULL THEN
      x_complete_rec.curr_approved_flag := l_risk_rec.curr_approved_flag;
   END IF;

   -- attribute_category
   IF p_risk_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_risk_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_risk_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_risk_rec.attribute1;
   END IF;

   -- attribute2
   IF p_risk_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_risk_rec.attribute2;
   END IF;

   -- attribute3
   IF p_risk_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_risk_rec.attribute3;
   END IF;

   -- attribute4
   IF p_risk_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_risk_rec.attribute4;
   END IF;

   -- attribute5
   IF p_risk_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_risk_rec.attribute5;
   END IF;

   -- attribute6
   IF p_risk_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_risk_rec.attribute6;
   END IF;

   -- attribute7
   IF p_risk_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_risk_rec.attribute7;
   END IF;

   -- attribute8
   IF p_risk_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_risk_rec.attribute8;
   END IF;

   -- attribute9
   IF p_risk_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_risk_rec.attribute9;
   END IF;

   -- attribute10
   IF p_risk_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_risk_rec.attribute10;
   END IF;

   -- attribute11
   IF p_risk_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_risk_rec.attribute11;
   END IF;

   -- attribute12
   IF p_risk_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_risk_rec.attribute12;
   END IF;

   -- attribute13
   IF p_risk_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_risk_rec.attribute13;
   END IF;

   -- attribute14
   IF p_risk_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_risk_rec.attribute14;
   END IF;

   -- attribute15
   IF p_risk_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_risk_rec.attribute15;
   END IF;

   AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
END Complete_risk_Rec;



-- ===============================================================
-- Procedure name
--          Validate_risk
-- Purpose
-- 		  	Validate_risk is the container for calling all the other
--			validation procedures on one record(Validate_xxx_Rec) and
--			the container of validation on items(Check_Risk_Items)
-- Note
-- 	   		basically, this should be called before calling table handler
-- ===============================================================
PROCEDURE Validate_risk(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER 	   := G_VALID_LEVEL_FULL,
    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rec               	 OUT  NOCOPY risk_rec_type,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
    )
IS
L_API_NAME                  	 CONSTANT VARCHAR2(30) := 'Validate_Risk';
L_API_VERSION_NUMBER        	 CONSTANT NUMBER	   := 1.0;
l_object_version_number     	 		  NUMBER;
l_risk_rec  							  risk_rec_type;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Risk_;
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := G_RET_STS_SUCCESS;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      l_risk_rec := p_risk_rec;
	  -- 07.21.2003 tsho, only update and revise need complete_risk_rec
	  IF p_operate_mode = G_OP_UPDATE OR p_operate_mode = G_OP_REVISE THEN
	     Complete_risk_Rec(
      	    p_risk_rec 	   => p_risk_rec,
			x_complete_rec => l_risk_rec);
	  END IF;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
	          Check_risk_Items(
                 p_operate_mode   => p_operate_mode,
                 p_risk_rec       => l_risk_rec,
                 x_return_status  => x_return_status);

              IF x_return_status = G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_risk_Rec(
		   p_operate_mode      		=> p_operate_mode,
           p_api_version_number     => 1.0,
           p_init_msg_list          => G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_risk_rec           	=> l_risk_rec);

              IF x_return_status = G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      x_risk_rec := l_risk_rec;

      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data);

EXCEPTION

   WHEN AMW_UTILITY_PVT.resource_locked THEN
     x_return_status := G_RET_STS_ERROR;
 AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Risk_;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Risk_;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Risk_;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

End Validate_Risk;



-- ===============================================================
-- Procedure name
--          Validate_risk_rec
-- Purpose
-- 		  	check all the necessaries for one record,
--			this includes the cross-items validation
-- Note
-- 	   		Validate_risk_rec is the dispatcher of
--			other validation procedures on one record.
--			business logic validation should go here.
-- ===============================================================
PROCEDURE Validate_risk_rec(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Validate_Risk_Rec';

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := G_RET_STS_SUCCESS;

      IF p_operate_mode = G_OP_CREATE THEN
	  	 Validate_create_risk_rec(
		 	x_return_status 	  => x_return_status,
		 	x_msg_count 		  => x_msg_count,
		 	x_msg_data 			  => x_msg_data,
			p_risk_rec 			  => p_risk_rec);
	     IF x_return_status<>G_RET_STS_SUCCESS THEN
		    AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  =>  G_OBJ_TYPE);
         	RAISE FND_API.G_EXC_ERROR;
      	 END IF;

      ELSIF p_operate_mode = G_OP_UPDATE THEN
	  	 Validate_update_risk_rec(
		 	x_return_status 	  => x_return_status,
		 	x_msg_count 		  => x_msg_count,
		 	x_msg_data 			  => x_msg_data,
			p_risk_rec 			  => p_risk_rec);
	     IF x_return_status<>G_RET_STS_SUCCESS THEN
		    AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                          p_token_name   => 'OBJ_TYPE',
                                          p_token_value  =>  G_OBJ_TYPE);
         	RAISE FND_API.G_EXC_ERROR;
      	 END IF;

      ELSIF p_operate_mode = G_OP_REVISE THEN
	  	 Validate_revise_risk_rec(
		 	x_return_status 	  => x_return_status,
		 	x_msg_count 		  => x_msg_count,
		 	x_msg_data 			  => x_msg_data,
			p_risk_rec 			  => p_risk_rec);
	     IF x_return_status<>G_RET_STS_SUCCESS THEN
		    AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                          p_token_name   => 'OBJ_TYPE',
                                          p_token_value  =>  G_OBJ_TYPE);
         	RAISE FND_API.G_EXC_ERROR;
      	 END IF;

      ELSIF p_operate_mode = G_OP_DELETE THEN
	  	 Validate_delete_risk_rec(
		 	x_return_status 	  => x_return_status,
		 	x_msg_count 		  => x_msg_count,
		 	x_msg_data 			  => x_msg_data,
			p_risk_rec 			  => p_risk_rec);
	     IF x_return_status<>G_RET_STS_SUCCESS THEN
		    AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                          p_token_name   => 'OBJ_TYPE',
                                          p_token_value  =>  G_OBJ_TYPE);
         	RAISE FND_API.G_EXC_ERROR;
      	 END IF;

      ELSE
	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNEXPECT_ERROR',
                                       p_token_name   => 'OBJ_TYPE',
                                       p_token_value  =>  G_OBJ_TYPE);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data);

END Validate_risk_Rec;




-- ===============================================================
-- Procedure name
--          Validate_create_risk_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_CREATE.
-- Note
--			risk name cannot be duplicated in table
-- ===============================================================
PROCEDURE Validate_create_risk_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Validate_Create_Risk_Rec';
l_dummy       					 		  NUMBER;

CURSOR c_name_exists (l_risk_name IN VARCHAR2) IS
      SELECT 1
      FROM amw_risks_all_vl
      WHERE name = l_risk_name;

BEGIN
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      x_return_status := G_RET_STS_SUCCESS;

      l_dummy := NULL;
	  OPEN c_name_exists(p_risk_rec.risk_name);
	  FETCH c_name_exists INTO l_dummy;
	  CLOSE c_name_exists;

	  IF l_dummy IS NOT NULL THEN
	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNIQUE_ITEM_ERROR',
                                       p_token_name   => 'ITEM',
                                       p_token_value  => 'risk_name');
	  	 x_return_status := G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
	  END IF;

      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN

     x_return_status := G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END Validate_create_risk_Rec;



-- ===============================================================
-- Procedure name
--          Validate_update_risk_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_UPDATE.
-- Note
--			risk name cannot be duplicated in table.
--			only the risk with approval_status='D' can be use G_OP_UPDATE
-- ===============================================================
PROCEDURE Validate_update_risk_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Validate_Update_Risk_Rec';
l_dummy       					 		  NUMBER;

-- c_target_risk is holding the info of target risk which is going to be updated
CURSOR c_target_risk (l_risk_rev_id IN NUMBER) IS
      SELECT approval_status
      FROM amw_risks_b
      WHERE risk_rev_id = l_risk_rev_id;
target_risk c_target_risk%ROWTYPE;

CURSOR c_name_exists (l_risk_name IN VARCHAR2,l_risk_id IN NUMBER) IS
      SELECT 1
      FROM amw_risks_all_vl
      WHERE name = l_risk_name AND risk_id <> l_risk_id;

BEGIN
	  AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      x_return_status := G_RET_STS_SUCCESS;

	  -- only approval_status='D' can be updated
	  OPEN c_target_risk(p_risk_rec.risk_rev_id);
	  FETCH c_target_risk INTO target_risk;
	  CLOSE c_target_risk;
	  IF target_risk.approval_status <> 'D' THEN
	  	 x_return_status := G_RET_STS_ERROR;
         AMW_UTILITY_PVT.debug_message('approval_status <> D');
	  END IF;

	  -- name duplication is not allowed
      l_dummy := NULL;
	  OPEN c_name_exists(p_risk_rec.risk_name,p_risk_rec.risk_id);
	  FETCH c_name_exists INTO l_dummy;
	  CLOSE c_name_exists;
	  IF l_dummy IS NOT NULL THEN
         AMW_UTILITY_PVT.debug_message('name exists');
	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNIQUE_ITEM_ERROR',
                                       p_token_name   => 'ITEM',
                                       p_token_value  => 'risk_name');
	  	 x_return_status := G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
	  END IF;

      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN

     x_return_status := G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END Validate_update_risk_Rec;



-- ===============================================================
-- Procedure name
--          Validate_revise_risk_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_REVISE.
-- Note
-- 	   		changing risk name when revising a risk is not allowed.
-- ===============================================================
PROCEDURE Validate_revise_risk_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Validate_Revise_Risk_Rec';
l_dummy       					 		  NUMBER;

-- c_target_risk is holding the info of target risk from amw_risks_b which is going to be revised
CURSOR c_target_risk (l_risk_rev_id IN NUMBER) IS
      SELECT approval_status
      FROM amw_risks_b
      WHERE risk_rev_id = l_risk_rev_id;
target_risk c_target_risk%ROWTYPE;

CURSOR c_get_name (l_risk_rev_id IN NUMBER) IS
      SELECT name
      FROM amw_risks_all_vl
      WHERE risk_rev_id = l_risk_rev_id;
original_risk_name amw_risks_all_vl.name%TYPE;

BEGIN
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      x_return_status := G_RET_STS_SUCCESS;

	  -- change the name when revise a risk is not allowed
	  OPEN c_get_name(p_risk_rec.risk_rev_id);
	  FETCH c_get_name INTO original_risk_name;
	  CLOSE c_get_name;
	  IF original_risk_name <> p_risk_rec.risk_name THEN
	  	 x_return_status := G_RET_STS_ERROR;
	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                       p_token_name   => 'OBJ_TYPE',
                                       p_token_value  =>  G_OBJ_TYPE);
         RAISE FND_API.G_EXC_ERROR;
	  END IF;

      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN

     x_return_status := G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END Validate_revise_risk_Rec;



-- ===============================================================
-- Procedure name
--          Validate_delete_risk_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_DELETE.
-- Note
-- 	   		not implemented yet.
--			need to find out when(approval_status='?') can G_OP_DELETE.
-- ===============================================================
PROCEDURE Validate_delete_risk_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Validate_Delete_Risk_Rec';
l_dummy       					 		  NUMBER;

CURSOR c_risk_exists (l_risk_rev_id IN NUMBER) IS
      SELECT 1
      FROM amw_risks_b
      WHERE risk_rev_id = l_risk_rev_id;

BEGIN
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      x_return_status := G_RET_STS_SUCCESS;

	  -- can only delete a risk which exists and has APPROVAL_STATUS='''
      l_dummy := NULL;
	  OPEN c_risk_exists(p_risk_rec.risk_rev_id);
	  FETCH c_risk_exists INTO l_dummy;
	  CLOSE c_risk_exists;
	  IF l_dummy IS NULL THEN
	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                       p_token_name   => 'OBJ_TYPE',
                                       p_token_value  => G_OBJ_TYPE);
	  	 x_return_status := G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
	  END IF;

      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count    => x_msg_count,
         p_data     => x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN

     x_return_status := G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END Validate_delete_risk_Rec;


-- ===============================================================
-- Procedure name
--          Approve_Risk
-- Purpose
-- 		  	to approve the risk without going through workflow
-- Note
--
-- ===============================================================
PROCEDURE Approve_Risk(
    p_risk_rev_id                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2          := G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'Approve_Risk';
l_date DATE;

-- find the target revision (previous latest approved one)
l_target_risk_rev_id    NUMBER;
CURSOR c_target_revision (l_risk_rev_id IN NUMBER) IS
      SELECT risk_rev_id
        FROM amw_risks_b
       WHERE risk_id = (
                 SELECT r.risk_id
                   FROM amw_risks_b r
                  WHERE r.risk_rev_id = l_risk_rev_id
             )
         AND curr_approved_flag='Y';

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF FND_API.to_Boolean( p_init_msg_list )  THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF G_USER_ID IS NULL THEN
      AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- 01.05.2005 tsho: make the date consistent for approval_date, update_date....etc
   l_date := sysdate;
   l_target_risk_rev_id := null;

    OPEN c_target_revision(p_risk_rev_id);
    FETCH c_target_revision INTO l_target_risk_rev_id;
    CLOSE c_target_revision;

    IF (l_target_risk_rev_id IS NOT NULL) THEN
      -- update the previous latest approved revision of specified risk
      update amw_risks_b
         set curr_approved_flag='N'
            ,latest_revision_flag ='N'
	        ,last_update_date=l_date
		    ,last_updated_by=G_USER_ID
		    ,last_update_login=G_LOGIN_ID
            ,end_date=l_date
       where risk_rev_id = l_target_risk_rev_id;
    END IF; -- end of if: _target_risk_rev_id IS NOT NULL

   -- approve the specified risk by risk_rev_id
   update amw_risks_b
      set approval_status='A'
         ,curr_approved_flag='Y'
         ,latest_revision_flag ='Y'
         ,approval_date=l_date
	     ,last_update_date=l_date
		 ,last_updated_by=G_USER_ID
		 ,last_update_login=G_LOGIN_ID
    where risk_rev_id=p_risk_rev_id;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END Approve_Risk;


-- ----------------------------------------------------------------------
END AMW_Risk_PVT;

/
