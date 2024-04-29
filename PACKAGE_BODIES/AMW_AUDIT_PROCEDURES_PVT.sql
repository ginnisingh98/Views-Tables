--------------------------------------------------------
--  DDL for Package Body AMW_AUDIT_PROCEDURES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_AUDIT_PROCEDURES_PVT" as
/* $Header: amwvrcdb.pls 120.1 2005/10/04 05:50:36 appldev noship $ */
-- ===============================================================
-- Package name
--          AMW_AUDIT_PROCEDURES_PVT
-- Purpose
-- 		  	for Import Audit Procedure : Load_AP (without knowing any audit_procedure_id in advance)
--			for direct call : Operate_AP (knowing audit_procedure_id or audit_procedure_rev_id)
-- History
-- 		  	12/08/2003    tsho     Creates
-- ===============================================================


G_PKG_NAME 	CONSTANT VARCHAR2(30)	:= 'AMW_AUDIT_PROCEDURES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) 	:= 'amwvrcdb.pls';


-- ===============================================================
-- Procedure name
--          Load_AP
-- Purpose
-- 		  	for Import Audit Procedure with approval_status 'A' or 'D'
-- ===============================================================
PROCEDURE Load_AP(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN  VARCHAR2,
    p_commit                     IN  VARCHAR2,
    p_validation_level           IN  NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec        IN   audit_procedure_rec_type,
    x_audit_procedure_rev_id     OUT  NOCOPY NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER,
    p_approval_date              IN   DATE
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Load_AP';
l_dummy       					 		  NUMBER;
l_dummy_audit_procedure_rec audit_procedure_rec_type   := NULL;
l_approval_date                 DATE;

CURSOR c_name_exists (l_audit_procedure_name IN VARCHAR2) IS
      SELECT audit_procedure_id
      FROM amw_audit_procedures_vl
      WHERE name = l_audit_procedure_name;
l_audit_procedure_id amw_audit_procedures_vl.audit_procedure_id%TYPE;

CURSOR c_revision_exists (l_audit_procedure_id IN NUMBER) IS
      SELECT count(*)
      FROM amw_audit_procedures_b
      GROUP BY audit_procedure_id
	  HAVING audit_procedure_id=l_audit_procedure_id;

CURSOR c_approval_status (l_audit_procedure_id IN NUMBER) IS
      SELECT audit_procedure_rev_id,
			 approval_status
      FROM amw_audit_procedures_b
	  WHERE audit_procedure_id=l_audit_procedure_id AND
	  		latest_revision_flag='Y';
l_approval_status c_approval_status%ROWTYPE;


BEGIN
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
	  x_return_status := G_RET_STS_SUCCESS;


	  IF p_audit_procedure_rec.approval_status ='P' THEN
	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_INVALID_STATUS',
                                      p_token_name   => 'OBJ_TYPE',
                                      p_token_value  =>  G_OBJ_TYPE);
      	RAISE FND_API.G_EXC_ERROR;
	  ELSIF p_audit_procedure_rec.approval_status ='R' THEN
	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_INVALID_STATUS',
                                      p_token_name   => 'OBJ_TYPE',
                                      p_token_value  =>  G_OBJ_TYPE);
      	RAISE FND_API.G_EXC_ERROR;
	  ELSIF p_audit_procedure_rec.approval_status IS NOT NULL AND p_audit_procedure_rec.approval_status <> 'A' AND p_audit_procedure_rec.approval_status <> 'D' THEN
	  	-- if it's null, the default will be 'D' , other pass-in unwanted data will be Invalid
	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_INVALID_STATUS',
                                      p_token_name   => 'OBJ_TYPE',
                                      p_token_value  =>  G_OBJ_TYPE);
      	RAISE FND_API.G_EXC_ERROR;
	  END IF;

      l_approval_date := p_approval_date;
      l_audit_procedure_id := NULL;
	  OPEN c_name_exists(p_audit_procedure_rec.audit_procedure_name);
	  FETCH c_name_exists INTO l_audit_procedure_id;
	  CLOSE c_name_exists;

      if (p_approval_date is null)
      then
        l_approval_date := SYSDATE;
      end if;

	  IF l_audit_procedure_id IS NULL THEN
  	    -- no existing audit procedure with  pass-in audit_procedure_name, then call operation with mode G_OP_CREATE
		Operate_AP(
		    p_operate_mode 		  => G_OP_CREATE,
		    p_api_version_number  => p_api_version_number,
		    p_init_msg_list       => p_init_msg_list,
		    p_commit     		  => p_commit,
		    p_validation_level    => p_validation_level,
		    x_return_status       => x_return_status,
		    x_msg_count     	  => x_msg_count,
		    x_msg_data     		  => x_msg_data,
		    p_audit_procedure_rec => p_audit_procedure_rec,
		    x_audit_procedure_rev_id => x_audit_procedure_rev_id,
		    x_audit_procedure_id  => x_audit_procedure_id,
            p_approval_date       => l_approval_date);
      	IF x_return_status<>G_RET_STS_SUCCESS THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                        p_token_name   => 'OBJ_TYPE',
                                        p_token_value  =>  G_OBJ_TYPE);
          RAISE FND_API.G_EXC_ERROR;
      	END IF;

	  ELSE
	  	l_dummy_audit_procedure_rec := p_audit_procedure_rec;
		l_dummy_audit_procedure_rec.audit_procedure_id := l_audit_procedure_id;
	  	l_dummy := NULL;
	    OPEN c_revision_exists(l_audit_procedure_id);
	    FETCH c_revision_exists INTO l_dummy;
	    CLOSE c_revision_exists;

		IF l_dummy IS NULL OR l_dummy < 1 THEN
		    -- no corresponding audit_procedure_id in AMW_AUDIT_PROCEDURES_B is wrong
	  	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNEXPECT_ERROR',
                                          p_token_name   => 'OBJ_TYPE',
                                          p_token_value  =>  G_OBJ_TYPE);
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_dummy = 1 THEN
			-- has only one record for audit_procedure_id in AMW_AUDIT_PROCEDURES_B with pass-in name
			OPEN c_approval_status(l_audit_procedure_id);
	    	FETCH c_approval_status INTO l_approval_status;
	    	CLOSE c_approval_status;

			IF l_approval_status.approval_status='P' THEN
			   -- this record is Pending Approval, cannot do G_OP_UPDATE or G_OP_REVISE
			   AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_PENDING_CHANGE_ERROR',
                                             p_token_name   => 'OBJ_TYPE',
                                             p_token_value  =>  G_OBJ_TYPE);
	   		   RAISE FND_API.G_EXC_ERROR;
			ELSIF l_approval_status.approval_status='D' THEN
		   	   Operate_AP(
		   	   		p_operate_mode 			=> G_OP_UPDATE,
					p_api_version_number    => p_api_version_number,
					p_init_msg_list     	=> p_init_msg_list,
					p_commit     			=> p_commit,
		    		p_validation_level     	=> p_validation_level,
		    		x_return_status     	=> x_return_status,
		    		x_msg_count     		=> x_msg_count,
		    		x_msg_data     			=> x_msg_data,
		    		p_audit_procedure_rec   => l_dummy_audit_procedure_rec,
		    		x_audit_procedure_rev_id => x_audit_procedure_rev_id,
		    		x_audit_procedure_id    => x_audit_procedure_id,
                    p_approval_date       => l_approval_date);
		      IF x_return_status<>G_RET_STS_SUCCESS THEN
	  	  	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                p_token_name   => 'OBJ_TYPE',
                                                p_token_value  =>  G_OBJ_TYPE);
		          RAISE FND_API.G_EXC_ERROR;
		      END IF;

			ELSIF l_approval_status.approval_status='A' OR l_approval_status.approval_status='R' THEN
		   	   Operate_AP(
		   	   		p_operate_mode 			=> G_OP_REVISE,
					p_api_version_number    => p_api_version_number,
					p_init_msg_list     	=> p_init_msg_list,
					p_commit     			=> p_commit,
		    		p_validation_level     	=> p_validation_level,
		    		x_return_status     	=> x_return_status,
		    		x_msg_count     		=> x_msg_count,
		    		x_msg_data     			=> x_msg_data,
		    		p_audit_procedure_rec	=> l_dummy_audit_procedure_rec,
		    		x_audit_procedure_rev_id => x_audit_procedure_rev_id,
		    		x_audit_procedure_id   	=> x_audit_procedure_id,
                    p_approval_date       => l_approval_date);
		      IF x_return_status<>G_RET_STS_SUCCESS THEN
			  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                p_token_name   => 'OBJ_TYPE',
                                                p_token_value  => G_OBJ_TYPE);
		          RAISE FND_API.G_EXC_ERROR;
		      END IF;

			END IF; -- end of if:l_approval_status.approval_status
		ELSE
			-- l_dummy > 1 : has revised before
			Operate_AP(
		    	p_operate_mode 	 		 => G_OP_REVISE,
		    	p_api_version_number     => p_api_version_number,
		    	p_init_msg_list     	 => p_init_msg_list,
		    	p_commit     			 => p_commit,
		    	p_validation_level     	 => p_validation_level,
		    	x_return_status     	 => x_return_status,
		    	x_msg_count     		 => x_msg_count,
		    	x_msg_data     			 => x_msg_data,
		    	p_audit_procedure_rec	 => l_dummy_audit_procedure_rec,
		    	x_audit_procedure_rev_id => x_audit_procedure_rev_id,
		    	x_audit_procedure_id   	 => x_audit_procedure_id,
                p_approval_date       => l_approval_date);
		      IF x_return_status<>G_RET_STS_SUCCESS THEN
			  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                p_token_name   => 'OBJ_TYPE',
                                                p_token_value  => G_OBJ_TYPE);
		          RAISE FND_API.G_EXC_ERROR;
		      END IF;

		END IF; -- end of if:l_dummy

	  END IF; -- end of if:l_audit_procedure_id

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

END Load_AP;



-- ===============================================================
-- Procedure name
--          Operate_AP
-- Purpose
-- 		  	operate audit procedure depends on the pass-in p_operate_mode:
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
PROCEDURE Operate_AP(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec        IN   audit_procedure_rec_type,
    x_audit_procedure_rev_id     OUT  NOCOPY NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER,
    p_approval_date              IN   DATE
    )
IS
l_api_name 					 CONSTANT VARCHAR2(30) := 'Operate_AP';
l_audit_procedure_rev_id	 		  NUMBER 	   := NULL;
l_dummy_audit_procedure_rec audit_procedure_rec_type;

CURSOR c_draft_revision (l_audit_procedure_id IN NUMBER) IS
      SELECT audit_procedure_rev_id
      FROM amw_audit_procedures_b
      WHERE audit_procedure_id = l_audit_procedure_id AND approval_status='D' AND latest_revision_flag='Y';

BEGIN
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list )
     THEN
        FND_MSG_PUB.initialize;
     END IF;

     AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


	 IF p_operate_mode = G_OP_CREATE THEN
	 	l_dummy_audit_procedure_rec := p_audit_procedure_rec;
		l_dummy_audit_procedure_rec.object_version_number := 1;
		l_dummy_audit_procedure_rec.audit_procedure_rev_num := 1;
		l_dummy_audit_procedure_rec.latest_revision_flag := 'Y';

		IF p_audit_procedure_rec.approval_status = 'A' THEN
			l_dummy_audit_procedure_rec.approval_status := 'A';
			l_dummy_audit_procedure_rec.curr_approved_flag := 'Y';
			l_dummy_audit_procedure_rec.approval_date := p_approval_date;
		ELSE
			l_dummy_audit_procedure_rec.approval_status := 'D';
			l_dummy_audit_procedure_rec.curr_approved_flag := 'N';
		END IF;

		Create_AP(
		    p_operate_mode 			=> p_operate_mode,
		    p_api_version_number    => p_api_version_number,
		    p_init_msg_list     	=> p_init_msg_list,
		    p_commit     			=> p_commit,
		    p_validation_level     	=> p_validation_level,
		    x_return_status     	=> x_return_status,
		    x_msg_count     		=> x_msg_count,
		    x_msg_data     			=> x_msg_data,
		    p_audit_procedure_rec 	=> l_dummy_audit_procedure_rec,
		    x_audit_procedure_rev_id => x_audit_procedure_rev_id,
		    x_audit_procedure_id   	=> x_audit_procedure_id);

			IF x_return_status<>G_RET_STS_SUCCESS THEN
			  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                p_token_name   => 'OBJ_TYPE',
                                                p_token_value  => G_OBJ_TYPE);
		       RAISE FND_API.G_EXC_ERROR;
		    END IF;

	 ELSIF p_operate_mode = G_OP_UPDATE THEN
 	 	l_dummy_audit_procedure_rec := p_audit_procedure_rec;
		l_dummy_audit_procedure_rec.curr_approved_flag := 'N';
		l_dummy_audit_procedure_rec.latest_revision_flag := 'Y';

		IF p_audit_procedure_rec.approval_status = 'A' THEN
			l_dummy_audit_procedure_rec.approval_status := 'A';
			l_dummy_audit_procedure_rec.curr_approved_flag := 'Y';
			l_dummy_audit_procedure_rec.approval_date := p_approval_date;
		ELSE
			l_dummy_audit_procedure_rec.approval_status := 'D';
			l_dummy_audit_procedure_rec.curr_approved_flag := 'N';
		END IF;


        fnd_file.put_line (fnd_file.LOG, '&&&&&&&&&&&&&&& Going to Update &&&&&&&&&&&&&&&');
		Update_AP(
		    p_operate_mode 			=> p_operate_mode,
		    p_api_version_number    => p_api_version_number,
		    p_init_msg_list     	=> p_init_msg_list,
		    p_commit     			=> p_commit,
		    p_validation_level     	=> p_validation_level,
		    x_return_status     	=> x_return_status,
		    x_msg_count     		=> x_msg_count,
		    x_msg_data     			=> x_msg_data,
		    p_audit_procedure_rec	=> l_dummy_audit_procedure_rec,
		    x_audit_procedure_rev_id => x_audit_procedure_rev_id,
		    x_audit_procedure_id	=> x_audit_procedure_id);

            fnd_file.put_line (fnd_file.LOG, '&&&&&&&&&&&&&&& Came out of Update &&&&&&&&&&&&&&&');
			IF x_return_status<>G_RET_STS_SUCCESS THEN
		  	   AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                             p_token_name   => 'OBJ_TYPE',
                                             p_token_value  => G_OBJ_TYPE);
		       RAISE FND_API.G_EXC_ERROR;
		    END IF;

	 ELSIF p_operate_mode = G_OP_REVISE THEN
	 	   l_audit_procedure_rev_id := NULL;
		   OPEN c_draft_revision(p_audit_procedure_rec.audit_procedure_id);
		   FETCH c_draft_revision INTO l_audit_procedure_rev_id;
		   CLOSE c_draft_revision;

	 	   -- has revision with APPROVAL_STATUS='D' exists
		   IF l_audit_procedure_rev_id IS NOT NULL THEN
		   	  l_dummy_audit_procedure_rec := p_audit_procedure_rec;
			  l_dummy_audit_procedure_rec.latest_revision_flag := 'Y';

			  IF p_audit_procedure_rec.approval_status = 'A' THEN
			  	 l_dummy_audit_procedure_rec.approval_status := 'A';
				 l_dummy_audit_procedure_rec.curr_approved_flag := 'Y';
				 l_dummy_audit_procedure_rec.approval_date := p_approval_date;
			  ELSE
			  	 l_dummy_audit_procedure_rec.approval_status := 'D';
				 l_dummy_audit_procedure_rec.curr_approved_flag := 'N';
			  END IF;


		   	  Update_AP(
			      p_operate_mode 		=> p_operate_mode,
				  p_api_version_number 	=> p_api_version_number,
				  p_init_msg_list 		=> p_init_msg_list,
				  p_commit 				=> p_commit,
				  p_validation_level 	=> p_validation_level,
				  x_return_status 		=> x_return_status,
				  x_msg_count 			=> x_msg_count,
				  x_msg_data 			=> x_msg_data,
				  p_audit_procedure_rec	=> l_dummy_audit_procedure_rec,
				  x_audit_procedure_rev_id => x_audit_procedure_rev_id,
				  x_audit_procedure_id  => x_audit_procedure_id);


				  IF x_return_status<>G_RET_STS_SUCCESS THEN
				     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                   p_token_name   => 'OBJ_TYPE',
                                                   p_token_value  => G_OBJ_TYPE);
				  	 RAISE FND_API.G_EXC_ERROR;
		    	  END IF;


		   ELSE
		   	  l_dummy_audit_procedure_rec := p_audit_procedure_rec;


		   	  Revise_Without_Revision_Exists(
			      p_operate_mode        => p_operate_mode,
				  p_api_version_number  => p_api_version_number,
				  p_init_msg_list       => p_init_msg_list,
				  p_commit              => p_commit,
				  p_validation_level    => p_validation_level,
				  x_return_status       => x_return_status,
				  x_msg_count           => x_msg_count,
				  x_msg_data            => x_msg_data,
				  p_audit_procedure_rec => l_dummy_audit_procedure_rec,
				  x_audit_procedure_rev_id => x_audit_procedure_rev_id,
				  x_audit_procedure_id  => x_audit_procedure_id);

			  IF x_return_status<>G_RET_STS_SUCCESS THEN
		  	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                                p_token_name   => 'OBJ_TYPE',
                                                p_token_value  => G_OBJ_TYPE);
			  	 RAISE FND_API.G_EXC_ERROR;
		      END IF;

		   END IF;
	 ELSIF p_operate_mode = G_OP_DELETE THEN

		Delete_AP(
		    p_operate_mode 			=> p_operate_mode,
		    p_api_version_number    => p_api_version_number,
		    p_init_msg_list     	=> p_init_msg_list,
		    p_commit     			=> p_commit,
		    p_validation_level     	=> p_validation_level,
		    x_return_status     	=> x_return_status,
		    x_msg_count     		=> x_msg_count,
		    x_msg_data     			=> x_msg_data,
		    p_audit_procedure_rev_id => p_audit_procedure_rec.audit_procedure_rev_id,
			x_audit_procedure_id  	=> x_audit_procedure_id);

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

END Operate_AP;




-- ===============================================================
-- Procedure name
--          Create_AP
-- Purpose
-- 		  	create audit procedure with specified approval_status,
--			if no specified approval_status in pass-in p_audit_procedure_rec,
--			the default approval_status is set to 'D'.
-- ===============================================================
PROCEDURE Create_AP(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_audit_procedure_rec        IN   audit_procedure_rec_type,
    x_audit_procedure_rev_id     OUT  NOCOPY NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER
     )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_AP';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_return_status_full        		 VARCHAR2(1);
l_object_version_number     		 NUMBER := 1;
l_audit_procedure_id       			 NUMBER;
l_audit_procedure_rev_id       		 NUMBER;
l_dummy       						 NUMBER;
l_audit_procedure_rec				 audit_procedure_rec_type;
l_dummy_audit_procedure_rec			 audit_procedure_rec_type;
l_row_id		 			   		 amw_audit_procedures_vl.row_id%TYPE;

CURSOR c_rev_id IS
      SELECT amw_procedure_rev_s.nextval
      FROM dual;

CURSOR c_rev_id_exists (l_rev_id IN NUMBER) IS
      SELECT 1
      FROM amw_audit_procedures_b
      WHERE audit_procedure_rev_id = l_rev_id;

CURSOR c_id IS
      SELECT amw_procedures_s.nextval
      FROM dual;

CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM amw_audit_procedures_b
      WHERE audit_procedure_id = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_AP_PVT;

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

   IF p_audit_procedure_rec.audit_procedure_rev_id IS NULL OR p_audit_procedure_rec.audit_procedure_rev_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_rev_id;
         FETCH c_rev_id INTO l_audit_procedure_rev_id;
         CLOSE c_rev_id;

         OPEN c_rev_id_exists(l_audit_procedure_rev_id);
         FETCH c_rev_id_exists INTO l_dummy;
         CLOSE c_rev_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
   	  l_audit_procedure_rev_id := p_audit_procedure_rec.audit_procedure_rev_id;
   END IF;

   IF p_audit_procedure_rec.audit_procedure_id IS NULL OR p_audit_procedure_rec.audit_procedure_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_audit_procedure_id;
         CLOSE c_id;

         OPEN c_id_exists(l_audit_procedure_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
   	  l_audit_procedure_id := p_audit_procedure_rec.audit_procedure_id;
   END IF;

   x_audit_procedure_id := l_audit_procedure_id;
   x_audit_procedure_rev_id := l_audit_procedure_rev_id;

   l_audit_procedure_rec := p_audit_procedure_rec;
   l_audit_procedure_rec.audit_procedure_id := l_audit_procedure_id;
   l_audit_procedure_rec.audit_procedure_rev_id := l_audit_procedure_rev_id;


      IF FND_GLOBAL.User_Id IS NULL THEN
 	  	 AMW_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (P_validation_level >= G_VALID_LEVEL_FULL) THEN
          AMW_UTILITY_PVT.debug_message('Private API: Validate_AP');

          -- Invoke validation procedures
          Validate_AP(
 		    p_operate_mode     		=> p_operate_mode,
            p_api_version_number    => p_api_version_number,
            p_init_msg_list    		=> G_FALSE,
            p_validation_level 		=> p_validation_level,
            p_audit_procedure_rec	=> l_audit_procedure_rec,
            x_audit_procedure_rec	=> l_dummy_audit_procedure_rec,
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

	  -- Invoke table handler(AMW_AUDIT_PROCEDURES_PKG.Insert_Row)
	  AMW_UTILITY_PVT.debug_message( 'Private API: Calling AMW_AUDIT_PROCEDURES_PKG.Insert_Row');
      AMW_AUDIT_PROCEDURES_PKG.Insert_Row(
					  x_rowid		 	   			=> l_row_id,
          			  x_audit_procedure_rev_id  	=> l_dummy_audit_procedure_rec.audit_procedure_rev_id,
                      x_project_id                  => l_dummy_audit_procedure_rec.project_id,
                      x_classification              => l_dummy_audit_procedure_rec.classification,
          			  x_attribute10  	   			=> l_dummy_audit_procedure_rec.attribute10,
          			  x_attribute11  	   			=> l_dummy_audit_procedure_rec.attribute11,
          			  x_attribute12  	   			=> l_dummy_audit_procedure_rec.attribute12,
          			  x_attribute13  	   			=> l_dummy_audit_procedure_rec.attribute13,
          			  x_attribute14  	   			=> l_dummy_audit_procedure_rec.attribute14,
          			  x_attribute15  	   			=> l_dummy_audit_procedure_rec.attribute15,
          			  x_object_version_number  		=> l_object_version_number,
          			  x_approval_status    			=> l_dummy_audit_procedure_rec.approval_status,
          			  x_orig_system_reference  		=> l_dummy_audit_procedure_rec.orig_system_reference,
          			  x_requestor_id  				=> l_dummy_audit_procedure_rec.requestor_id,
          			  x_attribute6  	   			=> l_dummy_audit_procedure_rec.attribute6,
          			  x_attribute7  	   			=> l_dummy_audit_procedure_rec.attribute7,
          			  x_attribute8  	  			=> l_dummy_audit_procedure_rec.attribute8,
          			  x_attribute9  	   			=> l_dummy_audit_procedure_rec.attribute9,
          			  x_security_group_id  			=> l_dummy_audit_procedure_rec.security_group_id,
          			  x_audit_procedure_id 			=> l_dummy_audit_procedure_rec.audit_procedure_id,
          			  x_audit_procedure_rev_num 	=> l_dummy_audit_procedure_rec.audit_procedure_rev_num,
          			  x_end_date  					=> l_dummy_audit_procedure_rec.end_date,
          			  x_approval_date  				=> l_dummy_audit_procedure_rec.approval_date,
          			  x_curr_approved_flag  		=> l_dummy_audit_procedure_rec.curr_approved_flag,
          			  x_latest_revision_flag  		=> l_dummy_audit_procedure_rec.latest_revision_flag,
          			  x_attribute5  	   			=> l_dummy_audit_procedure_rec.attribute5,
          			  x_attribute_category 			=> l_dummy_audit_procedure_rec.attribute_category,
          			  x_attribute1  	   			=> l_dummy_audit_procedure_rec.attribute1,
          			  x_attribute2  	   			=> l_dummy_audit_procedure_rec.attribute2,
          			  x_attribute3  	   			=> l_dummy_audit_procedure_rec.attribute3,
          			  x_attribute4  	   			=> l_dummy_audit_procedure_rec.attribute4,
			          x_name 		 	   			=> l_dummy_audit_procedure_rec.audit_procedure_name,
					  x_description 	   			=> l_dummy_audit_procedure_rec.audit_procedure_description,
          			  x_creation_date  				=> SYSDATE,
          			  x_created_by  	   			=> G_USER_ID,
          			  x_last_update_date   			=> SYSDATE,
					  x_last_updated_by    			=> G_USER_ID,
          			  x_last_update_login  			=> G_LOGIN_ID);

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
     ROLLBACK TO CREATE_AP_PVT;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_AP_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_AP_PVT;
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

End Create_AP;



-- ===============================================================
-- Procedure name
--          Update_AP
-- Purpose
-- 		  	update audit procedure with specified audit_procedure_rev_id,
--			if no specified audit_procedure_rev_id in pass-in p_audit_procedure_rec,
--			this will update the one with specified audit_procedure_id having
--			latest_revision_flag='Y' AND approval_status='D'.
-- Notes
-- 			if audit_procedure_rev_id is not specified, then
-- 			audit_procedure_id is a must when calling Update_AP
-- ===============================================================
PROCEDURE Update_AP(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_audit_procedure_rec        IN   audit_procedure_rec_type,
    x_audit_procedure_rev_id     OUT  NOCOPY NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER
    )
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Update_AP';
l_api_version_number        CONSTANT NUMBER   	  := 1.0;
l_audit_procedure_rev_id			 NUMBER;
l_audit_procedure_rec audit_procedure_rec_type;
l_dummy_audit_procedure_rec audit_procedure_rec_type;
l_classification number;

CURSOR c_target_revision (l_audit_procedure_id IN NUMBER) IS
      SELECT audit_procedure_rev_id
      FROM amw_audit_procedures_b
      WHERE audit_procedure_id = l_audit_procedure_id AND approval_status='D' AND latest_revision_flag='Y';

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_AP_PVT;


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


	  -- if no specified target audit_procedure_rev_id, find if from audit_procedure_id
	  IF p_audit_procedure_rec.audit_procedure_rev_id IS NULL OR p_audit_procedure_rec.audit_procedure_rev_id = FND_API.g_miss_num THEN
	  	  l_audit_procedure_rev_id := NULL;
		  OPEN c_target_revision(p_audit_procedure_rec.audit_procedure_id);
		  FETCH c_target_revision INTO l_audit_procedure_rev_id;
		  CLOSE c_target_revision;
	  	  IF l_audit_procedure_rev_id IS NULL THEN
	  	  	 x_return_status := G_RET_STS_ERROR;
			 AMW_UTILITY_PVT.debug_message('l_audit_procedure_rev_id in Update_AP is NULL');
	   	  	 RAISE FND_API.G_EXC_ERROR;
	  	  END IF;
	  ELSE
	  	  l_audit_procedure_rev_id := p_audit_procedure_rec.audit_procedure_rev_id;
	  END IF; -- end of if:p_audit_procedure_rec.audit_procedure_rev_id


   	  AMW_UTILITY_PVT.debug_message('l_audit_procedure_rev_id:'||l_audit_procedure_rev_id);

	  x_audit_procedure_id := p_audit_procedure_rec.audit_procedure_id;
   	  x_audit_procedure_rev_id := l_audit_procedure_rev_id;

	  l_audit_procedure_rec := p_audit_procedure_rec;
	  l_audit_procedure_rec.audit_procedure_rev_id := l_audit_procedure_rev_id;


      IF ( P_validation_level >= G_VALID_LEVEL_FULL)
      THEN
          AMW_UTILITY_PVT.debug_message('Private API: Validate_AP');

          -- Invoke validation procedures
          Validate_AP(
		    p_operate_mode     		=> p_operate_mode,
            p_api_version_number    => p_api_version_number,
            p_init_msg_list    		=> G_FALSE,
            p_validation_level 		=> p_validation_level,
            p_audit_procedure_rec	=> l_audit_procedure_rec,
            x_audit_procedure_rec	=> l_dummy_audit_procedure_rec,
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


      -- check if the AP has a classification already
      begin
         SELECT classification
           INTO l_classification
           FROM amw_audit_procedures_b
         ----03.01.2005 npanandi: ERROR in below JOIN
         ----audit_procedure_id should be equated to l_dummy_audit_procedure_rec.audit_procedure_id;
         ----WHERE audit_procedure_id = l_dummy_audit_procedure_rec.audit_procedure_rev_id;
         WHERE audit_procedure_id = l_dummy_audit_procedure_rec.audit_procedure_id;
      exception
         when no_data_found then
            null;
         when others then
            null;
      end;


      IF l_classification IS NOT NULL
      THEN
        l_dummy_audit_procedure_rec.classification := l_classification;
      END IF;


	  -- Invoke table handler(AMW_AUDIT_PROCEDURES_PKG.Update_Row)
	  AMW_AUDIT_PROCEDURES_PKG.Update_Row(
          			  x_audit_procedure_rev_id  	=> l_dummy_audit_procedure_rec.audit_procedure_rev_id,
                      x_project_id                  => l_dummy_audit_procedure_rec.project_id,
                      x_classification              => l_dummy_audit_procedure_rec.classification,
          			  x_attribute10  	   			=> l_dummy_audit_procedure_rec.attribute10,
          			  x_attribute11  	   			=> l_dummy_audit_procedure_rec.attribute11,
          			  x_attribute12  	   			=> l_dummy_audit_procedure_rec.attribute12,
          			  x_attribute13  	   			=> l_dummy_audit_procedure_rec.attribute13,
          			  x_attribute14  	   			=> l_dummy_audit_procedure_rec.attribute14,
          			  x_attribute15  	   			=> l_dummy_audit_procedure_rec.attribute15,
          			  x_object_version_number  		=> l_dummy_audit_procedure_rec.object_version_number,
          			  x_approval_status    			=> l_dummy_audit_procedure_rec.approval_status,
          			  x_orig_system_reference  		=> l_dummy_audit_procedure_rec.orig_system_reference,
          			  x_requestor_id  				=> l_dummy_audit_procedure_rec.requestor_id,
          			  x_attribute6  	   			=> l_dummy_audit_procedure_rec.attribute6,
          			  x_attribute7  	   			=> l_dummy_audit_procedure_rec.attribute7,
          			  x_attribute8  	  			=> l_dummy_audit_procedure_rec.attribute8,
          			  x_attribute9  	   			=> l_dummy_audit_procedure_rec.attribute9,
          			  x_security_group_id  			=> l_dummy_audit_procedure_rec.security_group_id,
          			  x_audit_procedure_id 			=> l_dummy_audit_procedure_rec.audit_procedure_id,
          			  x_audit_procedure_rev_num 	=> l_dummy_audit_procedure_rec.audit_procedure_rev_num,
          			  x_end_date  					=> l_dummy_audit_procedure_rec.end_date,
          			  x_approval_date  				=> l_dummy_audit_procedure_rec.approval_date,
          			  x_curr_approved_flag  		=> l_dummy_audit_procedure_rec.curr_approved_flag,
          			  x_latest_revision_flag  		=> l_dummy_audit_procedure_rec.latest_revision_flag,
          			  x_attribute5  	   			=> l_dummy_audit_procedure_rec.attribute5,
          			  x_attribute_category 			=> l_dummy_audit_procedure_rec.attribute_category,
          			  x_attribute1  	   			=> l_dummy_audit_procedure_rec.attribute1,
          			  x_attribute2  	   			=> l_dummy_audit_procedure_rec.attribute2,
          			  x_attribute3  	   			=> l_dummy_audit_procedure_rec.attribute3,
          			  x_attribute4  	   			=> l_dummy_audit_procedure_rec.attribute4,
			          x_name 		 	   			=> l_dummy_audit_procedure_rec.audit_procedure_name,
					  x_description 	   			=> l_dummy_audit_procedure_rec.audit_procedure_description,
          			  x_last_update_date   			=> SYSDATE,
					  x_last_updated_by    			=> G_USER_ID,
          			  x_last_update_login  			=> G_LOGIN_ID);


      -- anmalhot - if approval status = 'A' then approve the control associations
      if(l_dummy_audit_procedure_rec.approval_status = 'A')
      then
        UPDATE amw_ap_associations
        SET approval_date = l_dummy_audit_procedure_rec.approval_date
        WHERE audit_procedure_id = l_dummy_audit_procedure_rec.audit_procedure_id
        AND object_type = 'CTRL';
      end if;


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
     ROLLBACK TO UPDATE_AP_PVT;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_AP_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_AP_PVT;
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

End Update_AP;




-- ===============================================================
-- Procedure name
--          Delete_AP
-- Purpose
-- 		  	delete audit procedure with specified audit_procedure_rev_id.
-- ===============================================================
PROCEDURE Delete_AP(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rev_id     IN   NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER
    )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_AP';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_AP_PVT;

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

      -- Invoke table handler(AMW_AUDIT_PROCEDURES_PKG.Delete_Row)
      AMW_AUDIT_PROCEDURES_PKG.Delete_Row(
          x_audit_procedure_rev_id  => p_audit_procedure_rev_id);


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
     ROLLBACK TO DELETE_AP_PVT;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_AP_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_AP_PVT;
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

End Delete_AP;



-- ===============================================================
-- Procedure name
--          Revise_Without_Revision_Exists
-- Purpose
-- 		  	revise audit procedure with specified audit_procedure_id,
--			it'll revise the one having latest_revision_flag='Y'
--			AND approval_status='A' OR 'R' of specified audit_procedure_id.
--			the new revision created by this call will have
--			latest_revision_flag='Y', and the approval_status
--			will be set to 'D' if not specified in the p_audit_procedure_rec
--			the revisee(the old one) will have latest_revision_flag='N'
-- Note
-- 	   		actually the name for Revise_Without_Revision_Exists
--			should be Revise_Without_Draft_Revision_Exists if there's
--			no limitation for the procedure name.
-- ===============================================================
PROCEDURE Revise_Without_Revision_Exists(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_audit_procedure_rec      	 IN   audit_procedure_rec_type,
    x_audit_procedure_rev_id	 OUT  NOCOPY NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Revise_Without_Revision_Exists';
l_dummy_audit_procedure_rec audit_procedure_rec_type  			   := NULL;
l_audit_procedure_rec audit_procedure_rec_type	  			   	   := NULL;
l_audit_procedure_description	amw_audit_procedures_tl.description%TYPE;
l_classification number;

-- find the target revision to be revised
CURSOR c_target_revision (l_audit_procedure_id IN NUMBER) IS
      SELECT audit_procedure_rev_id,
             audit_procedure_id,
	  		 audit_procedure_rev_num,
			 object_version_number
      FROM amw_audit_procedures_b
      WHERE audit_procedure_id = l_audit_procedure_id AND ( approval_status='A' OR approval_status='R') AND latest_revision_flag='Y';
target_revision c_target_revision%ROWTYPE;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT REVISE_AP_PVT;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
         FND_MSG_PUB.initialize;
    END IF;

    AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


    -- Initialize API return status to SUCCESS
    x_return_status := G_RET_STS_SUCCESS;


    OPEN c_target_revision(p_audit_procedure_rec.audit_procedure_id);
	FETCH c_target_revision INTO target_revision;
	CLOSE c_target_revision;


    -- update the target(latest existing) revision
	l_audit_procedure_rec.audit_procedure_id := p_audit_procedure_rec.audit_procedure_id;
	l_audit_procedure_rec.audit_procedure_rev_id := target_revision.audit_procedure_rev_id;
	l_audit_procedure_rec.latest_revision_flag := 'N';
    -- 05.13.2004 tsho: bug 3595420, need to be consistent with UI
	--l_audit_procedure_rec.end_date := SYSDATE;
	l_audit_procedure_rec.object_version_number := target_revision.object_version_number+1;


  	IF p_audit_procedure_rec.approval_status = 'A' THEN
		l_audit_procedure_rec.curr_approved_flag := 'N';
        -- 05.13.2004 tsho: bug 3595420, need to be consistent with UI
        l_audit_procedure_rec.end_date := SYSDATE;
	END IF;


    Complete_AP_Rec(
   	    p_audit_procedure_rec   => l_audit_procedure_rec,
		x_complete_rec          => l_dummy_audit_procedure_rec);


	l_audit_procedure_description := l_dummy_audit_procedure_rec.audit_procedure_description;

	Update_AP(
    	p_operate_mode 	  		=> p_operate_mode,
	    p_api_version_number    => p_api_version_number,
	    p_init_msg_list     	=> p_init_msg_list,
	    p_commit     			=> p_commit,
	    p_validation_level     	=> p_validation_level,
	    x_return_status     	=> x_return_status,
	    x_msg_count     		=> x_msg_count,
	    x_msg_data     			=> x_msg_data,
	    p_audit_procedure_rec	=> l_dummy_audit_procedure_rec,
	    x_audit_procedure_rev_id => x_audit_procedure_rev_id,
	    x_audit_procedure_id	=> x_audit_procedure_id);


    IF x_return_status <> G_RET_STS_SUCCESS THEN

  	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                       p_token_name   => 'OBJ_TYPE',
                                       p_token_value  => G_OBJ_TYPE);
       	 RAISE FND_API.G_EXC_ERROR;
    END IF;


  	x_audit_procedure_id := p_audit_procedure_rec.audit_procedure_id;

	-- create the new revision
	l_dummy_audit_procedure_rec := p_audit_procedure_rec;
	l_dummy_audit_procedure_rec.latest_revision_flag := 'Y';
    l_dummy_audit_procedure_rec.object_version_number := 1;
    l_dummy_audit_procedure_rec.audit_procedure_rev_num := target_revision.audit_procedure_rev_num+1;


	IF p_audit_procedure_rec.audit_procedure_description IS NULL THEN
	   l_dummy_audit_procedure_rec.audit_procedure_description := l_audit_procedure_description;
	END IF;


  	IF p_audit_procedure_rec.approval_status = 'A' THEN
	   l_dummy_audit_procedure_rec.approval_status := 'A';
	   l_dummy_audit_procedure_rec.curr_approved_flag := 'Y';
	   l_dummy_audit_procedure_rec.approval_date := SYSDATE;
	ELSE
	   l_dummy_audit_procedure_rec.approval_status := 'D';
        -- 05.13.2004 tsho: bug 3595420, need to be consistent with UI
	   --l_dummy_audit_procedure_rec.curr_approved_flag := 'N';
       l_dummy_audit_procedure_rec.curr_approved_flag := 'R';
	END IF;


    -- check if the AP has a classification already
	---03.01.2005 npanandi: inserted the below SQL into a local Begin block
	---webADI upload gives a "Exact Fetch return More than one Row" error
    begin
       SELECT classification
         INTO l_classification
         FROM amw_audit_procedures_b
        ---WHERE audit_procedure_id = target_revision.audit_procedure_rev_id;
        WHERE audit_procedure_id = target_revision.audit_procedure_id;
    exception
       when no_data_found then
          null;
       when others then
          null;
    end;

    IF l_classification IS NOT NULL
    THEN
      l_dummy_audit_procedure_rec.classification := l_classification;
    END IF;

	Create_AP(
	    p_operate_mode 			=> p_operate_mode,
	    p_api_version_number    => p_api_version_number,
	    p_init_msg_list     	=> p_init_msg_list,
	    p_commit     			=> p_commit,
	    p_validation_level     	=> p_validation_level,
	    x_return_status     	=> x_return_status,
	    x_msg_count     		=> x_msg_count,
	    x_msg_data     			=> x_msg_data,
	    p_audit_procedure_rec	=> l_dummy_audit_procedure_rec,
	    x_audit_procedure_rev_id => x_audit_procedure_rev_id,
	    x_audit_procedure_id	=> x_audit_procedure_id);

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
     ROLLBACK TO REVISE_AP_PVT;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO REVISE_AP_PVT;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO REVISE_AP_PVT;
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
--          check_AP_uk_items
-- Purpose
-- 		  	check the uniqueness of the items which have been marked
--			as unique in table
-- ===============================================================
PROCEDURE check_AP_uk_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_audit_procedure_rec	 IN  audit_procedure_rec_type,
    x_return_status 		 OUT NOCOPY VARCHAR2
	)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := G_RET_STS_SUCCESS;

	  -- 07.23.2003 tsho
	  -- comment out for performance: since the uniqueness of
	  -- audit_procedure_rev_id and audit_procedure_id have been checked when creating
	  /*
      IF p_operate_mode = G_OP_CREATE THEN
         l_valid_flag := AMW_UTILITY_PVT.check_uniqueness(
         'amw_audit_procedures_b',
         'audit_procedure_rev_id = ''' || p_audit_procedure_rec.audit_procedure_rev_id ||''''
         );
      ELSE
         l_valid_flag := AMW_UTILITY_PVT.check_uniqueness(
         'amw_audit_procedures_b',
         'audit_procedure_rev_id = ''' || p_audit_procedure_rec.audit_procedure_rev_id ||
         ''' AND audit_procedure_rev_id <> ' || p_audit_procedure_rec.audit_procedure_rev_id
         );
      END IF;
	  */
END check_AP_uk_items;



-- ===============================================================
-- Procedure name
--          check_AP_req_items
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
PROCEDURE check_AP_req_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_audit_procedure_rec	 IN  audit_procedure_rec_type,
    x_return_status 		 OUT NOCOPY VARCHAR2
	)
IS
BEGIN
   x_return_status := G_RET_STS_SUCCESS;

   IF p_operate_mode = G_OP_CREATE THEN

       IF p_audit_procedure_rec.audit_procedure_rev_num  IS NULL THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'audit_procedure_rev_num');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_audit_procedure_rec.latest_revision_flag  IS NULL THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'latest_revision_flag');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_audit_procedure_rec.curr_approved_flag IS NULL THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'curr_approved_flag');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   ELSE
       IF p_audit_procedure_rec.audit_procedure_rev_id = FND_API.g_miss_num THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'audit_procedure_rev_id');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
	   END IF;

   	   IF p_audit_procedure_rec.audit_procedure_id = FND_API.g_miss_num THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'audit_procedure_id');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
   	   END IF;

       IF p_audit_procedure_rec.audit_procedure_rev_num = FND_API.g_miss_num THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'audit_procedure_rev_num');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_audit_procedure_rec.latest_revision_flag = FND_API.g_miss_char THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'latest_revision_flag');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_audit_procedure_rec.curr_approved_flag = FND_API.g_miss_char THEN
	  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'curr_approved_flag');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   END IF; -- end of if:p_operate_mode

END check_AP_req_items;



-- ===============================================================
-- Procedure name
--          check_AP_FK_items
-- Purpose
-- 		  	check forien key of the items
-- ===============================================================
PROCEDURE check_AP_FK_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_audit_procedure_rec 	 IN  audit_procedure_rec_type,
    x_return_status 		 OUT NOCOPY VARCHAR2
	)
IS
BEGIN
   x_return_status := G_RET_STS_SUCCESS;
END check_AP_FK_items;



-- ===============================================================
-- Procedure name
--          check_AP_Lookup_items
-- Purpose
-- 		  	check lookup of the items
-- ===============================================================
PROCEDURE check_AP_Lookup_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_audit_procedure_rec	 IN  audit_procedure_rec_type,
    x_return_status 		 OUT NOCOPY VARCHAR2
	)
IS
BEGIN
   x_return_status := G_RET_STS_SUCCESS;
END check_AP_Lookup_items;



-- ===============================================================
-- Procedure name
--          Check_AP_Items
-- Purpose
-- 		  	check all the necessaries for items
-- Note
-- 	   		Check_AP_Items is the container for calling all the
--			other validation procedures on items(check_xxx_Items)
--			the validation on items should be only table column constraints
--			not the business logic validation.
-- ===============================================================
PROCEDURE Check_AP_Items (
    p_operate_mode 		         IN  VARCHAR2,
    P_audit_procedure_rec		 IN  audit_procedure_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
    )
IS
BEGIN
   -- Check Items Uniqueness API calls
   check_AP_uk_items(
      p_operate_mode   		 => p_operate_mode,
      p_audit_procedure_rec	 => p_audit_procedure_rec,
      x_return_status 		 => x_return_status);
   IF x_return_status <> G_RET_STS_SUCCESS THEN
  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  => G_OBJ_TYPE);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check Items Required/NOT NULL API calls
   check_AP_req_items(
      p_operate_mode 		 => p_operate_mode,
      p_audit_procedure_rec  => p_audit_procedure_rec,
      x_return_status 		 => x_return_status);
   IF x_return_status <> G_RET_STS_SUCCESS THEN
  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  => G_OBJ_TYPE);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check Items Foreign Keys API calls
   check_AP_FK_items(
      p_operate_mode   	  	 => p_operate_mode,
      p_audit_procedure_rec	 => p_audit_procedure_rec,
      x_return_status 		 => x_return_status);
   IF x_return_status <> G_RET_STS_SUCCESS THEN
  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  => G_OBJ_TYPE);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check Items Lookups
   check_AP_Lookup_items(
      p_operate_mode 	     => p_operate_mode,
      p_audit_procedure_rec	 => p_audit_procedure_rec,
      x_return_status 		 => x_return_status);
   IF x_return_status <> G_RET_STS_SUCCESS THEN
  	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  => G_OBJ_TYPE);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

END Check_AP_Items;



-- ===============================================================
-- Procedure name
--          Complete_AP_Rec
-- Purpose
-- 		  	complete(fill out) the items which are not specified.
-- Note
-- 	   		basically, this is called when G_OP_UPDATE, G_OP_REVISE
-- ===============================================================
PROCEDURE Complete_AP_Rec (
   p_audit_procedure_rec    IN  audit_procedure_rec_type,
   x_complete_rec           OUT NOCOPY audit_procedure_rec_type
   )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Complete_AP_Rec';
l_return_status  				 		  VARCHAR2(1);

CURSOR c_complete IS
	  SELECT *
      FROM amw_audit_procedures_b
      WHERE audit_procedure_rev_id = p_audit_procedure_rec.audit_procedure_rev_id;
l_audit_procedure_rec c_complete%ROWTYPE;


CURSOR c_tl_complete IS
	  SELECT name,
	  		 description
      FROM amw_audit_procedures_vl
      WHERE audit_procedure_rev_id = p_audit_procedure_rec.audit_procedure_rev_id;
l_audit_procedure_tl_rec c_tl_complete%ROWTYPE;


BEGIN
   AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   x_complete_rec := p_audit_procedure_rec;

   OPEN c_complete;
   FETCH c_complete INTO l_audit_procedure_rec;
   CLOSE c_complete;

   OPEN c_tl_complete;
   FETCH c_tl_complete INTO l_audit_procedure_tl_rec;
   CLOSE c_tl_complete;

   -- audit_procedure_rev_id
   IF p_audit_procedure_rec.audit_procedure_rev_id IS NULL THEN
   	  AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNEXPECT_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  =>  G_OBJ_TYPE);
   	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- audit_procedure_id
   IF p_audit_procedure_rec.audit_procedure_id IS NULL THEN
      x_complete_rec.audit_procedure_id := l_audit_procedure_rec.audit_procedure_id;
   END IF;

   -- audit_procedure_name
   IF p_audit_procedure_rec.audit_procedure_name IS NULL THEN
      x_complete_rec.audit_procedure_name := l_audit_procedure_tl_rec.name;
   END IF;

   -- audit_procedure_description
   IF p_audit_procedure_rec.audit_procedure_description IS NULL THEN
      x_complete_rec.audit_procedure_description := l_audit_procedure_tl_rec.description;
   END IF;

   -- last_update_date
   IF p_audit_procedure_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_audit_procedure_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_audit_procedure_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_audit_procedure_rec.last_update_login;
   END IF;

   -- created_by
   IF p_audit_procedure_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_audit_procedure_rec.created_by;
   END IF;

   -- last_updated_by
   IF p_audit_procedure_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_audit_procedure_rec.last_updated_by;
   END IF;

   -- security_group_id
   IF p_audit_procedure_rec.security_group_id IS NULL THEN
      x_complete_rec.security_group_id := l_audit_procedure_rec.security_group_id;
   END IF;

   -- approval_status
   IF p_audit_procedure_rec.approval_status IS NULL THEN
      x_complete_rec.approval_status := l_audit_procedure_rec.approval_status;
   END IF;

   -- object_version_number
   IF p_audit_procedure_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_audit_procedure_rec.object_version_number;
   END IF;

   -- approval_date
   IF p_audit_procedure_rec.approval_date IS NULL THEN
      x_complete_rec.approval_date := l_audit_procedure_rec.approval_date;
   END IF;

   -- creation_date
   IF p_audit_procedure_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_audit_procedure_rec.creation_date;
   END IF;

   -- audit_procedure_rev_num
   IF p_audit_procedure_rec.audit_procedure_rev_num IS NULL THEN
      x_complete_rec.audit_procedure_rev_num := l_audit_procedure_rec.audit_procedure_rev_num;
   END IF;
   AMW_UTILITY_PVT.debug_message('audit_procedure_rev_num: ' || x_complete_rec.audit_procedure_rev_num);

   -- requestor_id
   IF p_audit_procedure_rec.requestor_id IS NULL THEN
      x_complete_rec.requestor_id := l_audit_procedure_rec.requestor_id;
   END IF;

   -- orig_system_reference
   IF p_audit_procedure_rec.orig_system_reference IS NULL THEN
      x_complete_rec.orig_system_reference := l_audit_procedure_rec.orig_system_reference;
   END IF;

   -- latest_revision_flag
   IF p_audit_procedure_rec.latest_revision_flag IS NULL THEN
      x_complete_rec.latest_revision_flag := l_audit_procedure_rec.latest_revision_flag;
   END IF;

   -- end_date
   IF p_audit_procedure_rec.end_date IS NULL THEN
      x_complete_rec.end_date := l_audit_procedure_rec.end_date;
   END IF;

   -- curr_approved_flag
   IF p_audit_procedure_rec.curr_approved_flag IS NULL THEN
      x_complete_rec.curr_approved_flag := l_audit_procedure_rec.curr_approved_flag;
   END IF;

   -- attribute_category
   IF p_audit_procedure_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_audit_procedure_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_audit_procedure_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_audit_procedure_rec.attribute1;
   END IF;

   -- attribute2
   IF p_audit_procedure_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_audit_procedure_rec.attribute2;
   END IF;

   -- attribute3
   IF p_audit_procedure_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_audit_procedure_rec.attribute3;
   END IF;

   -- attribute4
   IF p_audit_procedure_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_audit_procedure_rec.attribute4;
   END IF;

   -- attribute5
   IF p_audit_procedure_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_audit_procedure_rec.attribute5;
   END IF;

   -- attribute6
   IF p_audit_procedure_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_audit_procedure_rec.attribute6;
   END IF;

   -- attribute7
   IF p_audit_procedure_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_audit_procedure_rec.attribute7;
   END IF;

   -- attribute8
   IF p_audit_procedure_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_audit_procedure_rec.attribute8;
   END IF;

   -- attribute9
   IF p_audit_procedure_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_audit_procedure_rec.attribute9;
   END IF;

   -- attribute10
   IF p_audit_procedure_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_audit_procedure_rec.attribute10;
   END IF;

   -- attribute11
   IF p_audit_procedure_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_audit_procedure_rec.attribute11;
   END IF;

   -- attribute12
   IF p_audit_procedure_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_audit_procedure_rec.attribute12;
   END IF;

   -- attribute13
   IF p_audit_procedure_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_audit_procedure_rec.attribute13;
   END IF;

   -- attribute14
   IF p_audit_procedure_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_audit_procedure_rec.attribute14;
   END IF;

   -- attribute15
   IF p_audit_procedure_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_audit_procedure_rec.attribute15;
   END IF;

   AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
END Complete_AP_Rec;



-- ===============================================================
-- Procedure name
--          Validate_AP
-- Purpose
-- 		  	Validate_AP is the container for calling all the other
--			validation procedures on one record(Validate_xxx_Rec) and
--			the container of validation on items(Check_AP_Items)
-- Note
-- 	   		basically, this should be called before calling table handler
-- ===============================================================
PROCEDURE Validate_AP(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type,
    x_audit_procedure_rec      	 OUT  NOCOPY audit_procedure_rec_type,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
    )
IS
L_API_NAME                  	 CONSTANT VARCHAR2(30) := 'Validate_AP';
L_API_VERSION_NUMBER        	 CONSTANT NUMBER	   := 1.0;
l_object_version_number     	 		  NUMBER;
l_audit_procedure_rec  					  audit_procedure_rec_type;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_AP_;
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

      l_audit_procedure_rec := p_audit_procedure_rec;
	  -- 07.21.2003 tsho, only update and revise need complete_AP_rec
	  IF p_operate_mode = G_OP_UPDATE OR p_operate_mode = G_OP_REVISE THEN
	     Complete_AP_Rec(
      	    p_audit_procedure_rec   => p_audit_procedure_rec,
			x_complete_rec          => l_audit_procedure_rec);
	  END IF;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
	          Check_AP_Items(
                 p_operate_mode   => p_operate_mode,
                 p_audit_procedure_rec => l_audit_procedure_rec,
                 x_return_status  => x_return_status);

              IF x_return_status = G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_AP_Rec(
		   p_operate_mode      		=> p_operate_mode,
           p_api_version_number     => 1.0,
           p_init_msg_list          => G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_audit_procedure_rec   	=> l_audit_procedure_rec);

              IF x_return_status = G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      x_audit_procedure_rec := l_audit_procedure_rec;

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
     ROLLBACK TO VALIDATE_AP_;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_AP_;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_AP_;
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

End Validate_AP;



-- ===============================================================
-- Procedure name
--          Validate_AP_rec
-- Purpose
-- 		  	check all the necessaries for one record,
--			this includes the cross-items validation
-- Note
-- 	   		Validate_AP_rec is the dispatcher of
--			other validation procedures on one record.
--			business logic validation should go here.
-- ===============================================================
PROCEDURE Validate_AP_rec(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Validate_AP_Rec';

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
	  	 Validate_create_AP_rec(
		 	x_return_status 	  => x_return_status,
		 	x_msg_count 		  => x_msg_count,
		 	x_msg_data 			  => x_msg_data,
			p_audit_procedure_rec => p_audit_procedure_rec);
	     IF x_return_status<>G_RET_STS_SUCCESS THEN
		    AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                    p_token_name   => 'OBJ_TYPE',
                                    p_token_value  =>  G_OBJ_TYPE);
         	RAISE FND_API.G_EXC_ERROR;
      	 END IF;

      ELSIF p_operate_mode = G_OP_UPDATE THEN
	  	 Validate_update_AP_rec(
		 	x_return_status 	  => x_return_status,
		 	x_msg_count 		  => x_msg_count,
		 	x_msg_data 			  => x_msg_data,
			p_audit_procedure_rec => p_audit_procedure_rec);
	     IF x_return_status<>G_RET_STS_SUCCESS THEN
		    AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                          p_token_name   => 'OBJ_TYPE',
                                          p_token_value  =>  G_OBJ_TYPE);
         	RAISE FND_API.G_EXC_ERROR;
      	 END IF;

      ELSIF p_operate_mode = G_OP_REVISE THEN
	  	 Validate_revise_AP_rec(
		 	x_return_status 	  => x_return_status,
		 	x_msg_count 		  => x_msg_count,
		 	x_msg_data 			  => x_msg_data,
			p_audit_procedure_rec => p_audit_procedure_rec);
	     IF x_return_status<>G_RET_STS_SUCCESS THEN
		    AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                          p_token_name   => 'OBJ_TYPE',
                                          p_token_value  =>  G_OBJ_TYPE);
         	RAISE FND_API.G_EXC_ERROR;
      	 END IF;

      ELSIF p_operate_mode = G_OP_DELETE THEN
	  	 Validate_delete_AP_rec(
		 	x_return_status 	  => x_return_status,
		 	x_msg_count 		  => x_msg_count,
		 	x_msg_data 			  => x_msg_data,
			p_audit_procedure_rec => p_audit_procedure_rec);
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

END Validate_AP_rec;




-- ===============================================================
-- Procedure name
--          Validate_create_AP_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_CREATE.
-- Note
--			audit_procedure name cannot be duplicated in table
-- ===============================================================
PROCEDURE Validate_create_AP_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Validate_Create_AP_Rec';
l_dummy       					 		  NUMBER;

CURSOR c_name_exists (l_audit_procedure_name IN VARCHAR2) IS
      SELECT 1
      FROM amw_audit_procedures_vl
      WHERE name = l_audit_procedure_name;

BEGIN
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      x_return_status := G_RET_STS_SUCCESS;

      l_dummy := NULL;
	  OPEN c_name_exists(p_audit_procedure_rec.audit_procedure_name);
	  FETCH c_name_exists INTO l_dummy;
	  CLOSE c_name_exists;

	  IF l_dummy IS NOT NULL THEN
	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNIQUE_ITEM_ERROR',
                                       p_token_name   => 'ITEM',
                                       p_token_value  => 'audit_procedure_name');
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

END Validate_create_AP_rec;



-- ===============================================================
-- Procedure name
--          Validate_update_AP_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_UPDATE.
-- Note
--			audit procedure name cannot be duplicated in table.
--			only the audit procedure with approval_status='D' can be use G_OP_UPDATE
-- ===============================================================
PROCEDURE Validate_update_AP_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Validate_Update_AP_Rec';
l_dummy       					 		  NUMBER;

-- c_target_audit_procedure is holding the info of target audit procedure which is going to be updated
CURSOR c_target_audit_procedure (l_audit_procedure_rev_id IN NUMBER) IS
      SELECT approval_status
      FROM amw_audit_procedures_b
      WHERE audit_procedure_rev_id = l_audit_procedure_rev_id;
target_audit_procedure c_target_audit_procedure%ROWTYPE;

CURSOR c_name_exists (l_audit_procedure_name IN VARCHAR2,l_audit_procedure_id IN NUMBER) IS
      SELECT 1
      FROM amw_audit_procedures_vl
      WHERE name = l_audit_procedure_name AND audit_procedure_id <> l_audit_procedure_id;

BEGIN
	  AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      x_return_status := G_RET_STS_SUCCESS;

	  -- only approval_status='D' can be updated
	  OPEN c_target_audit_procedure(p_audit_procedure_rec.audit_procedure_rev_id);
	  FETCH c_target_audit_procedure INTO target_audit_procedure;
	  CLOSE c_target_audit_procedure;
	  IF target_audit_procedure.approval_status <> 'D' THEN
	  	 x_return_status := G_RET_STS_ERROR;
         AMW_UTILITY_PVT.debug_message('approval_status <> D');
	  END IF;

	  -- name duplication is not allowed
      l_dummy := NULL;
	  OPEN c_name_exists(p_audit_procedure_rec.audit_procedure_name,p_audit_procedure_rec.audit_procedure_id);
	  FETCH c_name_exists INTO l_dummy;
	  CLOSE c_name_exists;
	  IF l_dummy IS NOT NULL THEN
         AMW_UTILITY_PVT.debug_message('name exists');
	     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNIQUE_ITEM_ERROR',
                                       p_token_name   => 'ITEM',
                                       p_token_value  => 'audit_procedure_name');
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

END Validate_update_AP_rec;



-- ===============================================================
-- Procedure name
--          Validate_revise_AP_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_REVISE.
-- Note
-- 	   		changing audit procedure name when revising an audit procedure is not allowed.
-- ===============================================================
PROCEDURE Validate_revise_AP_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Validate_Revise_AP_Rec';
l_dummy       					 		  NUMBER;

-- c_target_audit_procedure is holding the info of target audit procedure from amw_audit_procedures_b which is going to be revised
CURSOR c_target_audit_procedure (l_audit_procedure_rev_id IN NUMBER) IS
      SELECT approval_status
      FROM amw_audit_procedures_b
      WHERE audit_procedure_rev_id = l_audit_procedure_rev_id;
target_audit_procedure c_target_audit_procedure%ROWTYPE;

CURSOR c_get_name (l_audit_procedure_rev_id IN NUMBER) IS
      SELECT name
      FROM amw_audit_procedures_vl
      WHERE audit_procedure_rev_id = l_audit_procedure_rev_id;
original_audit_procedure_name amw_audit_procedures_vl.name%TYPE;

BEGIN
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      x_return_status := G_RET_STS_SUCCESS;

	  -- change the name when revise an audit procedure is not allowed
	  OPEN c_get_name(p_audit_procedure_rec.audit_procedure_rev_id);
	  FETCH c_get_name INTO original_audit_procedure_name;
	  CLOSE c_get_name;
	  IF original_audit_procedure_name <> p_audit_procedure_rec.audit_procedure_name THEN
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

END Validate_revise_AP_rec;



-- ===============================================================
-- Procedure name
--          Validate_delete_AP_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_DELETE.
-- Note
-- 	   		not implemented yet.
--			need to find out when(approval_status='?') can G_OP_DELETE.
-- ===============================================================
PROCEDURE Validate_delete_AP_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type
    )
IS
l_api_name 						 CONSTANT VARCHAR2(30) := 'Validate_Delete_AP_Rec';
l_dummy       					 		  NUMBER;

CURSOR c_audit_procedure_exists (l_audit_procedure_rev_id IN NUMBER) IS
      SELECT 1
      FROM amw_audit_procedures_b
      WHERE audit_procedure_rev_id = l_audit_procedure_rev_id;

BEGIN
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      x_return_status := G_RET_STS_SUCCESS;

	  -- can only delete an audit procedure which exists and has APPROVAL_STATUS='''
      l_dummy := NULL;
	  OPEN c_audit_procedure_exists(p_audit_procedure_rec.audit_procedure_rev_id);
	  FETCH c_audit_procedure_exists INTO l_dummy;
	  CLOSE c_audit_procedure_exists;
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

END Validate_delete_AP_rec;


-- ===============================================================
-- Procedure name
--          copy_audit_step
-- Purpose
-- 		  	this procedure copies audit steps from from_ap_rev_id to
--          to_ap_rev_id
-- Note
--
-- ===============================================================
PROCEDURE copy_audit_steps(
		  p_api_version        	IN	NUMBER,
  		  p_init_msg_list		IN	VARCHAR2, -- default FND_API.G_FALSE,
		  p_commit	    		IN  VARCHAR2, -- default FND_API.G_FALSE,
		  p_validation_level	IN  NUMBER,	-- default	FND_API.G_VALID_LEVEL_FULL,
     	  x_return_status		OUT	NOCOPY VARCHAR2,
		  x_msg_count			OUT	NOCOPY NUMBER,
		  x_msg_data			OUT	NOCOPY VARCHAR2,
		  x_from_ap_rev_id IN NUMBER,
		  x_to_ap_id IN NUMBER
		  )
IS
  l_api_name				  CONSTANT VARCHAR2(30)	:= 'copy_audit_steps';
  l_api_version         	  CONSTANT NUMBER 		:= 1.0;
  l_object_version_number     NUMBER := 1;
  l_from_rev_num			  NUMBER := 1;
  l_row_id		 			  amw_ap_steps_vl.row_id%TYPE;
  l_id 						  NUMBER;
 CURSOR steps_b IS SELECT
 	   AMW_AP_STEPS_S.NEXTVAL STEP_ID,
       SEQNUM,
       SAMPLESIZE,
       step.LAST_UPDATE_DATE,
       step.LAST_UPDATED_BY,
       step.CREATION_DATE,
       step.CREATED_BY,
       step.LAST_UPDATE_LOGIN,
       step.ATTRIBUTE_CATEGORY,
       step.ATTRIBUTE1,
       step.ATTRIBUTE2,
       step.ATTRIBUTE3,
       step.ATTRIBUTE4,
       step.ATTRIBUTE5,
       step.ATTRIBUTE6,
       step.ATTRIBUTE7,
       step.ATTRIBUTE8,
       step.ATTRIBUTE9,
       step.ATTRIBUTE10,
       step.ATTRIBUTE11,
       step.ATTRIBUTE12,
       step.ATTRIBUTE13,
       step.ATTRIBUTE14,
       step.ATTRIBUTE15,
       step.SECURITY_GROUP_ID,
       step.OBJECT_VERSION_NUMBER,
       step.ORIG_SYSTEM_REFERENCE,
       step.REQUESTOR_ID,
	   step.NAME,
	   step.DESCRIPTION,
       step.CSEQNUM
FROM AMW_AP_STEPS_VL step, AMW_AUDIT_PROCEDURES_B ap

WHERE ap.audit_procedure_rev_id = x_from_ap_rev_id and
ap.audit_procedure_id = step.audit_procedure_id and
ap.audit_procedure_rev_num >= step.from_rev_num and
ap.audit_procedure_rev_num < NVL ( step.to_rev_num, ap.audit_procedure_rev_num + 1) ;


BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	COPY_AUDIT_STEPS_SAVEPT;

   	-- Standard call to check for call compatibility.
   	IF NOT FND_API.Compatible_API_Call (l_api_version,
   	       	    	    	 			    p_api_version,
    	    	    	    	 		    l_api_name,
		    	    	    	    	    G_PKG_NAME)
	THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
	   FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
   	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF x_to_ap_id IS NULL OR x_to_ap_id = FND_API.G_MISS_NUM
	THEN
		--	missing or NULL required parameter
		--	1. Set the return status to error
		--	2. Write a message to the message list.
		--	3. Return to the caller.
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MESSAGE.SET_NAME ('AMW', 'AMW_MISS_TO_AP_ID');
		FND_MSG_PUB.Add;
		RETURN;
	END IF;
	FOR steprec IN steps_b
	LOOP

	   AMW_AP_STEPS_PKG.INSERT_ROW (
	   	  X_ROWID => l_row_id,
		  X_AP_STEP_ID => steprec.STEP_ID,
		  X_ATTRIBUTE4 => steprec.ATTRIBUTE4,
		  X_ATTRIBUTE5 => steprec.ATTRIBUTE5,
		  X_ATTRIBUTE1 => steprec.ATTRIBUTE1 ,
		  X_ATTRIBUTE6 => steprec.ATTRIBUTE6 ,
		  X_ATTRIBUTE7 => steprec.ATTRIBUTE7,
		  X_ATTRIBUTE8 => steprec.ATTRIBUTE8,
		  X_ATTRIBUTE9 => steprec.ATTRIBUTE9,
		  X_SAMPLESIZE => steprec.SAMPLESIZE,
		  X_AUDIT_PROCEDURE_ID => x_to_ap_id,
		  X_SEQNUM => steprec.SEQNUM,
		  X_ATTRIBUTE2 => steprec.ATTRIBUTE2,
		  X_ATTRIBUTE3 => steprec.ATTRIBUTE3,
		  X_ATTRIBUTE10 => steprec.ATTRIBUTE10,
		  X_ATTRIBUTE11 => steprec.ATTRIBUTE11,
		  X_ATTRIBUTE12 => steprec.ATTRIBUTE12,
		  X_ATTRIBUTE13 => steprec.ATTRIBUTE13,
		  X_ATTRIBUTE14 => steprec.ATTRIBUTE14,
		  X_ATTRIBUTE15 => steprec.ATTRIBUTE15,
		  X_SECURITY_GROUP_ID => steprec.SECURITY_GROUP_ID,
		  X_OBJECT_VERSION_NUMBER => l_object_version_number,
		  X_ORIG_SYSTEM_REFERENCE => steprec.ORIG_SYSTEM_REFERENCE,
		  X_REQUESTOR_ID => steprec.REQUESTOR_ID,
		  X_ATTRIBUTE_CATEGORY => steprec.ATTRIBUTE_CATEGORY,
		  X_NAME => steprec.NAME,
		  X_DESCRIPTION => steprec.DESCRIPTION,
		  X_CREATION_DATE => SYSDATE,
		  X_CREATED_BY => G_USER_ID,
		  X_LAST_UPDATE_DATE => SYSDATE,
		  X_LAST_UPDATED_BY => G_USER_ID,
		  X_LAST_UPDATE_LOGIN => G_LOGIN_ID,
		  X_FROM_REV_NUM => l_from_rev_num,
		  X_TO_REV_NUM => NULL,
		  X_CSEQNUM => steprec.CSEQNUM);
	END LOOP;
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
		);
	EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO COPY_AUDIT_STEPS_SAVEPT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO COPY_AUDIT_STEPS_SAVEPT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    	(  		p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO COPY_AUDIT_STEPS_SAVEPT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    	FND_MSG_PUB.Add_Exc_Msg
    	    	(		G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    	(  		p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
		);
END copy_audit_steps;

-- ===============================================================
-- Procedure name
--          copy_tasks
-- Purpose
-- 		  	this procedure copies tasks from from_ap_id to
--          to_ap_id
-- Note
--
-- ===============================================================
PROCEDURE copy_tasks(
		  p_api_version        	IN	NUMBER,
  		  p_init_msg_list		IN	VARCHAR2, -- default FND_API.G_FALSE,
		  p_commit	    		IN  VARCHAR2, -- default FND_API.G_FALSE,
		  p_validation_level	IN  NUMBER,	-- default	FND_API.G_VALID_LEVEL_FULL,
     	  x_return_status		OUT	NOCOPY VARCHAR2,
		  x_msg_count			OUT	NOCOPY NUMBER,
		  x_msg_data			OUT	NOCOPY VARCHAR2,
		  x_from_ap_id IN NUMBER,
		  x_to_ap_id IN NUMBER
		  )
IS
  l_api_name			CONSTANT VARCHAR2(30)	:= 'copy_tasks';
  l_api_version         CONSTANT NUMBER 		:= 1.0;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	COPY_TASKS_SAVEPT;

   	-- Standard call to check for call compatibility.
   	IF NOT FND_API.Compatible_API_Call (l_api_version,
   	       	    	    	 			    p_api_version,
    	    	    	    	 		    l_api_name,
		    	    	    	    	    G_PKG_NAME)
	THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
	   FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
   	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF x_to_ap_id IS NULL OR x_to_ap_id = FND_API.G_MISS_NUM
	THEN
		--	missing or NULL required parameter
		--	1. Set the return status to error
		--	2. Write a message to the message list.
		--	3. Return to the caller.
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MESSAGE.SET_NAME ('AMW', 'AMW_MISS_TO_AP_ID');
		FND_MSG_PUB.Add;
		RETURN;
	END IF;

	--FOR taskrec IN tasks
	--LOOP

	 	INSERT INTO AMW_AP_TASKS (AP_TASK_ID,
			AUDIT_PROCEDURE_ID,
			TASK_ID,
			PROJECT_ID,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY ,
			CREATION_DATE   ,
			CREATED_BY      ,
			LAST_UPDATE_LOGIN,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1       ,
			ATTRIBUTE2       ,
			ATTRIBUTE3       ,
			ATTRIBUTE4       ,
			ATTRIBUTE5       ,
			ATTRIBUTE6       ,
			ATTRIBUTE7       ,
			ATTRIBUTE8       ,
			ATTRIBUTE9       ,
			ATTRIBUTE10      ,
			ATTRIBUTE11      ,
			ATTRIBUTE12      ,
			ATTRIBUTE13      ,
			ATTRIBUTE14      ,
			ATTRIBUTE15      ,
			SECURITY_GROUP_ID,
			OBJECT_VERSION_NUMBER,
			ORIG_SYSTEM_REFERENCE,
			REQUESTOR_ID)
		(SELECT AMW_AP_TASKS_S.NEXTVAL,
			   x_to_ap_id,
			   taskrec.TASK_ID,
			   taskrec.PROJECT_ID,
			   SYSDATE,
			   G_USER_ID,
			   SYSDATE,
			   G_USER_ID,
			   G_LOGIN_ID,
			   taskrec.ATTRIBUTE_CATEGORY,
			   taskrec.ATTRIBUTE1,
			   taskrec.ATTRIBUTE2,
			   taskrec.ATTRIBUTE3,
			   taskrec.ATTRIBUTE4,
			   taskrec.ATTRIBUTE5,
			   taskrec.ATTRIBUTE6,
			   taskrec.ATTRIBUTE7,
			   taskrec.ATTRIBUTE8,
			   taskrec.ATTRIBUTE9,
			   taskrec.ATTRIBUTE10,
			   taskrec.ATTRIBUTE11,
			   taskrec.ATTRIBUTE12,
			   taskrec.ATTRIBUTE13,
			   taskrec.ATTRIBUTE14,
			   taskrec.ATTRIBUTE15,
			   taskrec.SECURITY_GROUP_ID,
			   1,
			   taskrec.ORIG_SYSTEM_REFERENCE,
			   taskrec.REQUESTOR_ID
		FROM AMW_AP_TASKS taskrec
		WHERE audit_procedure_id = x_from_ap_id);
	--END LOOP;
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
		);
	EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO COPY_TASKS_SAVEPT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO COPY_TASKS_SAVEPT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    	(  		p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO COPY_TASKS_SAVEPT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    	FND_MSG_PUB.Add_Exc_Msg
    	    	(		G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    	(  		p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
		);
END copy_tasks;

-- ===============================================================
-- Procedure name
--          copy_controls
-- Purpose
-- 		  	this procedure copies controls from from_ap_id to
--          to_ap_id
-- Note
--
-- ===============================================================
PROCEDURE copy_controls(
		  p_api_version        	IN	NUMBER,
  		  p_init_msg_list		IN	VARCHAR2, -- default FND_API.G_FALSE,
		  p_commit	    		IN  VARCHAR2, -- default FND_API.G_FALSE,
		  p_validation_level	IN  NUMBER,	-- default	FND_API.G_VALID_LEVEL_FULL,
     	  x_return_status		OUT	NOCOPY VARCHAR2,
		  x_msg_count			OUT	NOCOPY NUMBER,
		  x_msg_data			OUT	NOCOPY VARCHAR2,
		  x_from_ap_id 			IN  NUMBER,
		  x_to_ap_id 			IN  NUMBER
		  )
IS
  l_api_name			CONSTANT VARCHAR2(30)	:= 'copy_controls';
  l_api_version         CONSTANT NUMBER 		:= 1.0;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	COPY_CONTROLS_SAVEPT;

   	-- Standard call to check for call compatibility.
   	IF NOT FND_API.Compatible_API_Call (l_api_version,
   	       	    	    	 			    p_api_version,
    	    	    	    	 		    l_api_name,
		    	    	    	    	    G_PKG_NAME)
	THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
	   FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
   	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF x_to_ap_id IS NULL OR x_to_ap_id = FND_API.G_MISS_NUM
	THEN
		--	missing or NULL required parameter
		--	1. Set the return status to error
		--	2. Write a message to the message list.
		--	3. Return to the caller.
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MESSAGE.SET_NAME ('AMW', 'AMW_MISS_TO_AP_ID');
		FND_MSG_PUB.Add;
		RETURN;
	END IF;

    --FOR ctrlrec IN controls_assoc
	--LOOP

	 	INSERT INTO AMW_AP_ASSOCIATIONS (AP_ASSOCIATION_ID,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN ,
			PK1               ,
			PK2               ,
			PK3               ,
			PK4               ,
			PK5               ,
			OBJECT_TYPE       ,
			AUDIT_PROCEDURE_ID,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1        ,
			ATTRIBUTE2        ,
			ATTRIBUTE3        ,
			ATTRIBUTE4        ,
			ATTRIBUTE5        ,
			ATTRIBUTE6        ,
			ATTRIBUTE7        ,
			ATTRIBUTE8        ,
			ATTRIBUTE9        ,
			ATTRIBUTE10       ,
			ATTRIBUTE11       ,
			ATTRIBUTE12       ,
			ATTRIBUTE13       ,
			ATTRIBUTE14       ,
			ATTRIBUTE15       ,
			SECURITY_GROUP_ID ,
			OBJECT_VERSION_NUMBER,
			DESIGN_EFFECTIVENESS ,
			OP_EFFECTIVENESS)
		(SELECT AMW_AP_ASSOCIATIONS_S.NEXTVAL,
			   SYSDATE,
			   G_USER_ID,
			   SYSDATE,
			   G_USER_ID,
			   G_LOGIN_ID,
			   ctrlrec.PK1,
			   ctrlrec.PK2,
			   ctrlrec.PK3,
			   ctrlrec.PK4,
			   ctrlrec.PK5,
			   ctrlrec.OBJECT_TYPE,
			   x_to_ap_id,
			   ctrlrec.ATTRIBUTE_CATEGORY,
			   ctrlrec.ATTRIBUTE1,
			   ctrlrec.ATTRIBUTE2,
			   ctrlrec.ATTRIBUTE3,
			   ctrlrec.ATTRIBUTE4,
			   ctrlrec.ATTRIBUTE5,
			   ctrlrec.ATTRIBUTE6,
			   ctrlrec.ATTRIBUTE7,
			   ctrlrec.ATTRIBUTE8,
			   ctrlrec.ATTRIBUTE9,
			   ctrlrec.ATTRIBUTE10,
			   ctrlrec.ATTRIBUTE11,
			   ctrlrec.ATTRIBUTE12,
			   ctrlrec.ATTRIBUTE13,
			   ctrlrec.ATTRIBUTE14,
			   ctrlrec.ATTRIBUTE15,
			   ctrlrec.SECURITY_GROUP_ID,
			   1,
			   ctrlrec.DESIGN_EFFECTIVENESS,
			   ctrlrec.OP_EFFECTIVENESS
    	 FROM AMW_AP_ASSOCIATIONS ctrlrec
		 WHERE audit_procedure_id = x_from_ap_id);
	--END LOOP;
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
		);
	EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO COPY_CONTROLS_SAVEPT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO COPY_CONTROLS_SAVEPT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    	(  		p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO COPY_CONTROLS_SAVEPT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    	FND_MSG_PUB.Add_Exc_Msg
    	    	(		G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    	(  		p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
		);

END copy_controls;

--
--  Insert ap_steps
--
--
   procedure insert_ap_step(
                            p_api_version_number         IN   NUMBER,
                            p_init_msg_list              IN   VARCHAR2,
                            p_commit                     IN   VARCHAR2,
                            p_validation_level           IN   NUMBER,
                            p_samplesize  		    	in number,
   			 				 p_audit_procedure_id   	in number,
							 p_seqnum			    	in varchar2,
							 p_requestor_id		    	in number,
							 p_name				    	in varchar2,
							 p_description		    	in varchar2,
							 p_audit_procedure_rev_id	in number,
                             p_user_id                  in number,
                             x_return_status              OUT  NOCOPY VARCHAR2,
                             x_msg_count                  OUT  NOCOPY NUMBER,
                             x_msg_data                   OUT  NOCOPY VARCHAR2)
   is
	 CURSOR c_step_exists (c_step_num IN varchar2,c_ap_id IN NUMBER, c_from_ap_rev_num IN NUMBER) IS
       SELECT b.ap_step_id,
	   		  b.name,
			  b.description,
			  b.samplesize,
			  b.from_rev_num,
			  b.to_rev_num,
              b.object_version_number
         FROM amw_ap_steps_vl b
        WHERE b.cseqnum = c_step_num
	   	  AND b.audit_procedure_id = c_ap_id
          AND b.from_rev_num = c_from_ap_rev_num;

	 CURSOR c_step_exists_for_prev_rev (c_step_num IN varchar2,c_ap_id IN NUMBER, c_from_ap_rev_num IN NUMBER) IS
       SELECT b.ap_step_id,
	   		  b.name,
			  b.description,
			  b.samplesize,
              b.cseqnum,
			  b.from_rev_num,
			  b.to_rev_num,
              b.object_version_number
         FROM amw_ap_steps_vl b
        WHERE b.cseqnum = c_step_num
	   	  AND b.audit_procedure_id = c_ap_id
          AND b.to_rev_num is null and b.from_rev_num <> c_from_ap_rev_num;

     CURSOR c_get_rev_num(c_audit_procedure_rev_id in number) is
	   Select audit_procedure_rev_num
	     From amw_audit_procedures_b
		Where audit_procedure_rev_id = c_audit_procedure_rev_id;

     cursor get_ap_steps_id is
	  		select amw_ap_steps_s.nextval from dual;

     l_api_name                  CONSTANT VARCHAR2(30) := 'Insert_AP_Step';
     l_api_version_number        CONSTANT NUMBER   := 1.0;

	 l_ap_step_id        number;
	 lx_rowid 	         amw_ap_steps_vl.row_id%type;
     l_ap_rev_num           number;
	 lx_step_rec         c_step_exists%rowtype;
	 lx_prev_step_rec    c_step_exists_for_prev_rev%rowtype;
   begin
      -- Standard Start of API savepoint
      SAVEPOINT INSERT_AP_STEP_PVT;
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

	 -- added    npanandi 11/08/2004
	 x_return_status := fnd_api.g_ret_sts_success;

	 fnd_file.put_line(fnd_file.LOG,'Inside insert_ap_step --> x_return_status: '||x_return_status);

	 open c_get_rev_num(p_audit_procedure_rev_id);
	    fetch c_get_rev_num into l_ap_rev_num;
	 close c_get_rev_num;

     if(l_ap_rev_num is null)
     then
	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNEXPECT_ERROR',
                                      p_token_name   => 'OBJ_TYPE',
                                      p_token_value  =>  G_OBJ_TYPE);
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;

     -- check if a step with the same p_seqnum exists with from_rev_num = l_rev_num. If it does then update
     -- it. Check if a step with the same p_seqnum exists with to_rev_num = null. If it does then set
     -- to_rev_num = l_rev_num and insert a new step row with from_rev_num = l_rev_num.
     OPEN c_step_exists(p_seqnum, p_audit_procedure_id, l_ap_rev_num);
        FETCH c_step_exists INTO lx_step_rec;
	 CLOSE c_step_exists;

     OPEN c_step_exists_for_prev_rev(p_seqnum, p_audit_procedure_id, l_ap_rev_num);
        FETCH c_step_exists_for_prev_rev INTO lx_prev_step_rec;
	 CLOSE c_step_exists_for_prev_rev;

     open get_ap_steps_id;
	 	  fetch get_ap_steps_id into l_ap_step_id;
	 close get_ap_steps_id;

    if(lx_step_rec.ap_step_id is not null)
    then
        -- update the step
		amw_ap_steps_pkg.update_row(
			  X_AP_STEP_ID 		  	=> lx_step_rec.ap_step_id,
			  X_ATTRIBUTE4 		  	=> null,
			  X_ATTRIBUTE5 		  	=> null,
			  X_ATTRIBUTE1 		  	=> null,
			  X_ATTRIBUTE6 		  	=> null,
			  X_ATTRIBUTE7 		  	=> null,
			  X_ATTRIBUTE8 		  	=> null,
			  X_ATTRIBUTE9 		  	=> null,
			  X_SAMPLESIZE 		  	=> p_samplesize,
			  X_AUDIT_PROCEDURE_ID 	=> p_audit_procedure_id,
			  X_SEQNUM 				=> null,
			  X_ATTRIBUTE2 			=> null,
			  X_ATTRIBUTE3 			=> null,
			  X_ATTRIBUTE10 		=> null,
			  X_ATTRIBUTE11 		=> null,
			  X_ATTRIBUTE12 		=> null,
			  X_ATTRIBUTE13 		=> null,
			  X_ATTRIBUTE14 		=> null,
			  X_ATTRIBUTE15 		=> null,
			  X_SECURITY_GROUP_ID 	=> null,
			  X_OBJECT_VERSION_NUMBER => lx_step_rec.object_version_number + 1,
			  X_ORIG_SYSTEM_REFERENCE => null,
			  X_REQUESTOR_ID 		  => p_requestor_id,
			  X_ATTRIBUTE_CATEGORY 	  => null,
			  X_NAME 				  => p_name,
			  X_DESCRIPTION 		  => p_description,
			  X_LAST_UPDATE_DATE 	  => sysdate,
			  X_LAST_UPDATED_BY 	  => p_user_id,
			  X_LAST_UPDATE_LOGIN 	  => p_user_id,
			  X_FROM_REV_NUM 		  => l_ap_rev_num,
			  X_TO_REV_NUM 			  => null,
			  X_CSEQNUM 				=> p_seqnum);
     elsif(lx_prev_step_rec.ap_step_id is not null)
     then
        -- set to_rev_num and insert a new row
		amw_ap_steps_pkg.update_row(
			  X_AP_STEP_ID 		  	=> lx_prev_step_rec.ap_step_id,
			  X_ATTRIBUTE4 		  	=> null,
			  X_ATTRIBUTE5 		  	=> null,
			  X_ATTRIBUTE1 		  	=> null,
			  X_ATTRIBUTE6 		  	=> null,
			  X_ATTRIBUTE7 		  	=> null,
			  X_ATTRIBUTE8 		  	=> null,
			  X_ATTRIBUTE9 		  	=> null,
			  X_SAMPLESIZE 		  	=> lx_prev_step_rec.samplesize,
			  X_AUDIT_PROCEDURE_ID 	=> p_audit_procedure_id,
			  X_SEQNUM 				=> null,
			  X_ATTRIBUTE2 			=> null,
			  X_ATTRIBUTE3 			=> null,
			  X_ATTRIBUTE10 		=> null,
			  X_ATTRIBUTE11 		=> null,
			  X_ATTRIBUTE12 		=> null,
			  X_ATTRIBUTE13 		=> null,
			  X_ATTRIBUTE14 		=> null,
			  X_ATTRIBUTE15 		=> null,
			  X_SECURITY_GROUP_ID 	=> null,
			  X_OBJECT_VERSION_NUMBER => lx_prev_step_rec.object_version_number + 1,
			  X_ORIG_SYSTEM_REFERENCE => null,
			  X_REQUESTOR_ID 		  => p_requestor_id,
			  X_ATTRIBUTE_CATEGORY 	  => null,
			  X_NAME 				  => lx_prev_step_rec.name,
			  X_DESCRIPTION 		  => lx_prev_step_rec.description,
			  X_LAST_UPDATE_DATE 	  => sysdate,
			  X_LAST_UPDATED_BY 	  => p_user_id,
			  X_LAST_UPDATE_LOGIN 	  => p_user_id,
			  X_FROM_REV_NUM 		  => lx_prev_step_rec.from_rev_num,
			  X_TO_REV_NUM 			  => l_ap_rev_num,
			  X_CSEQNUM 			  => lx_prev_step_rec.cseqnum);

        amw_ap_steps_pkg.insert_row(X_ROWID 	  	=> lx_rowid,
							  X_AP_STEP_ID 		  	=> l_ap_step_id,
							  X_ATTRIBUTE4 		  	=> null,
							  X_ATTRIBUTE5 		  	=> null,
							  X_ATTRIBUTE1 		  	=> null,
							  X_ATTRIBUTE6 		  	=> null,
							  X_ATTRIBUTE7 		  	=> null,
							  X_ATTRIBUTE8 		  	=> null,
							  X_ATTRIBUTE9 		  	=> null,
							  X_SAMPLESIZE 		  	=> p_samplesize,
							  X_AUDIT_PROCEDURE_ID 	=> p_audit_procedure_id,
							  X_SEQNUM 				=> null,
							  X_ATTRIBUTE2 			=> null,
							  X_ATTRIBUTE3 			=> null,
							  X_ATTRIBUTE10 		=> null,
							  X_ATTRIBUTE11 		=> null,
							  X_ATTRIBUTE12 		=> null,
							  X_ATTRIBUTE13 		=> null,
							  X_ATTRIBUTE14 		=> null,
							  X_ATTRIBUTE15 		=> null,
							  X_SECURITY_GROUP_ID 	=> null,
							  X_OBJECT_VERSION_NUMBER => 1,
							  X_ORIG_SYSTEM_REFERENCE => null,
							  X_REQUESTOR_ID 		  => p_requestor_id,
							  X_ATTRIBUTE_CATEGORY 	  => null,
							  X_NAME 				  => p_name,
							  X_DESCRIPTION 		  => p_description,
							  X_CREATION_DATE 		  => sysdate,
							  X_CREATED_BY 			  => p_user_id,
							  X_LAST_UPDATE_DATE 	  => sysdate,
							  X_LAST_UPDATED_BY 	  => p_user_id,
							  X_LAST_UPDATE_LOGIN 	  => p_user_id,
							  X_FROM_REV_NUM 		  => l_ap_rev_num,
							  X_TO_REV_NUM 			  => null,
							  X_CSEQNUM 				=> p_seqnum);
     else
         -- create a new step as it does not exist
         amw_ap_steps_pkg.insert_row(X_ROWID 	  	=> lx_rowid,
							  X_AP_STEP_ID 		  	=> l_ap_step_id,
							  X_ATTRIBUTE4 		  	=> null,
							  X_ATTRIBUTE5 		  	=> null,
							  X_ATTRIBUTE1 		  	=> null,
							  X_ATTRIBUTE6 		  	=> null,
							  X_ATTRIBUTE7 		  	=> null,
							  X_ATTRIBUTE8 		  	=> null,
							  X_ATTRIBUTE9 		  	=> null,
							  X_SAMPLESIZE 		  	=> p_samplesize,
							  X_AUDIT_PROCEDURE_ID 	=> p_audit_procedure_id,
							  X_SEQNUM 				=> null,
							  X_ATTRIBUTE2 			=> null,
							  X_ATTRIBUTE3 			=> null,
							  X_ATTRIBUTE10 		=> null,
							  X_ATTRIBUTE11 		=> null,
							  X_ATTRIBUTE12 		=> null,
							  X_ATTRIBUTE13 		=> null,
							  X_ATTRIBUTE14 		=> null,
							  X_ATTRIBUTE15 		=> null,
							  X_SECURITY_GROUP_ID 	=> null,
							  X_OBJECT_VERSION_NUMBER => 1,
							  X_ORIG_SYSTEM_REFERENCE => null,
							  X_REQUESTOR_ID 		  => p_requestor_id,
							  X_ATTRIBUTE_CATEGORY 	  => null,
							  X_NAME 				  => p_name,
							  X_DESCRIPTION 		  => p_description,
							  X_CREATION_DATE 		  => sysdate,
							  X_CREATED_BY 			  => p_user_id,
							  X_LAST_UPDATE_DATE 	  => sysdate,
							  X_LAST_UPDATED_BY 	  => p_user_id,
							  X_LAST_UPDATE_LOGIN 	  => p_user_id,
							  X_FROM_REV_NUM 		  => l_ap_rev_num,
							  X_TO_REV_NUM 			  => null,
							  X_CSEQNUM 				=> p_seqnum);
     end if;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

     fnd_file.put_line(fnd_file.LOG,'Done with amw_ap_steps_pkg.insert_row');

   exception
	WHEN OTHERS THEN
        ROLLBACK TO INSERT_AP_STEP_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count => x_msg_count,
                            p_data => x_msg_data);

   end insert_ap_step;

--
--  Insert control association
--
--
   procedure insert_ap_control_assoc(
                            p_api_version_number         IN   NUMBER,
                            p_init_msg_list              IN   VARCHAR2,
                            p_commit                     IN   VARCHAR2,
                            p_validation_level           IN   NUMBER,
                            p_control_id  		    	in number,
   			 				 p_audit_procedure_id   	in number,
                             p_des_eff                  in varchar2,
                             p_op_eff                   in varchar2,
                             p_approval_date            in date,
                             p_user_id                  in number,
                             x_return_status              OUT  NOCOPY VARCHAR2,
                             x_msg_count                  OUT  NOCOPY NUMBER,
                             x_msg_data                   OUT  NOCOPY VARCHAR2)
   is
	 CURSOR c_assoc_exists (c_control_id IN NUMBER,c_ap_id IN NUMBER) IS
       SELECT a.ap_association_id,
              a.pk1,
              a.audit_procedure_id,
              a.design_effectiveness,
              a.op_effectiveness,
              a.object_version_number
         FROM amw_ap_associations a
        WHERE a.audit_procedure_id = c_ap_id
	   	  AND a.object_type = 'CTRL'
          AND a.pk1 = c_control_id
          AND a.deletion_date is null
          AND a.approval_date is null;

	 CURSOR c_prev_assoc_exists (c_control_id IN NUMBER,c_ap_id IN NUMBER) IS
       SELECT a.ap_association_id,
              a.pk1,
              a.audit_procedure_id,
              a.design_effectiveness,
              a.op_effectiveness,
              a.object_type,
              a.object_version_number
         FROM amw_ap_associations a
        WHERE a.audit_procedure_id = c_ap_id
	   	  AND a.object_type = 'CTRL'
          AND a.pk1 = c_control_id
          AND a.deletion_date is null
          AND a.approval_date is not null;

     l_api_name                  CONSTANT VARCHAR2(30) := 'Insert_AP_Control_Assoc';
     l_api_version_number        CONSTANT NUMBER   := 1.0;
	 lx_assoc_rec         c_assoc_exists%rowtype;
	 lx_prev_assoc_rec    c_prev_assoc_exists%rowtype;
     l_date      date;
   begin
      -- Standard Start of API savepoint
      SAVEPOINT INSERT_AP_CONTROL_ASSOC_PVT;
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
	 x_return_status := fnd_api.g_ret_sts_success;

	 fnd_file.put_line(fnd_file.LOG,'Inside insert_ap_control_assoc --> x_return_status: '||x_return_status);

     if(p_control_id is null OR p_audit_procedure_id is null)
     then
	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNEXPECT_ERROR',
                                      p_token_name   => 'OBJ_TYPE',
                                      p_token_value  =>  G_OBJ_TYPE);
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
	 if(p_des_eff = 'N' AND p_op_eff = 'N') then
   	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_ASSOC_AP_EFF_WEBADI_MSG');
	  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;

     if(p_approval_date is null)
     then
        l_date := SYSDATE;
     else
        l_date := p_approval_date;
     end if;

     -- check if there is an association with approval_date as null. If there is then
     -- update it.
     -- Check if there is an association with approval_date as not null and deletion_date as null.
     -- set the deletion_date for that and insert a new row.
     OPEN c_assoc_exists(p_control_id, p_audit_procedure_id);
        FETCH c_assoc_exists INTO lx_assoc_rec;
	 CLOSE c_assoc_exists;

     OPEN c_prev_assoc_exists(p_control_id, p_audit_procedure_id);
        FETCH c_prev_assoc_exists INTO lx_prev_assoc_rec;
	 CLOSE c_prev_assoc_exists;
    if(lx_assoc_rec.ap_association_id is not null)
    then
        -- update the association
        UPDATE amw_ap_associations
        SET design_effectiveness = p_des_eff,
            op_effectiveness = p_op_eff,
            object_version_number = object_version_number + 1,
            approval_date = p_approval_date
        WHERE ap_association_id = lx_assoc_rec.ap_association_id;
     elsif(lx_prev_assoc_rec.ap_association_id is not null)
     then
        -- set deletion_date and insert a new row
        UPDATE amw_ap_associations
        SET deletion_date = l_date,
            object_version_number = object_version_number + 1,
            deletion_approval_date = p_approval_date
        WHERE ap_association_id = lx_prev_assoc_rec.ap_association_id;

        INSERT INTO amw_ap_associations
                     (ap_association_id
                     ,last_update_date
                     ,last_updated_by
                     ,creation_date
                     ,created_by
		             ,last_update_login
                     ,audit_procedure_id
                     ,pk1
                     ,object_type
				     ,design_effectiveness
				     ,op_effectiveness
				     ,object_version_number
                     ,association_creation_date
                     ,approval_date
                     ,deletion_date
                     ,deletion_approval_date
                     )
                     VALUES (amw_ap_associations_s.NEXTVAL
                                       ,SYSDATE
                                       ,p_user_id
                                       ,SYSDATE
                                       ,p_user_id
									   ,p_user_id
                                       ,p_audit_procedure_id
                                       ,p_control_id
                                       ,'CTRL'
									   ,p_des_eff
									   ,p_op_eff
									   ,1
                                       ,l_date
                                       ,p_approval_date
                                       ,null
                                       ,null
                                       );
     else
         -- create a new assoc as it does not exist
        INSERT INTO amw_ap_associations
                     (ap_association_id
                     ,last_update_date
                     ,last_updated_by
                     ,creation_date
                     ,created_by
		             ,last_update_login
                     ,audit_procedure_id
                     ,pk1
                     ,object_type
				     ,design_effectiveness
				     ,op_effectiveness
				     ,object_version_number
                     ,association_creation_date
                     ,approval_date
                     ,deletion_date
                     ,deletion_approval_date
                     )
                     VALUES (amw_ap_associations_s.NEXTVAL
                                       ,SYSDATE
                                       ,p_user_id
                                       ,SYSDATE
                                       ,p_user_id
									   ,p_user_id
                                       ,p_audit_procedure_id
                                       ,p_control_id
                                       ,'CTRL'
									   ,p_des_eff
									   ,p_op_eff
									   ,1
                                       ,l_date
                                       ,p_approval_date
                                       ,null
                                       ,null
                                       );
     end if;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

     fnd_file.put_line(fnd_file.LOG,'Done with amw_ap_steps_pkg.insert_row');

   exception
	WHEN OTHERS THEN
        ROLLBACK TO INSERT_AP_CONTROL_ASSOC_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count => x_msg_count,
                            p_data => x_msg_data);

   end insert_ap_control_assoc;

procedure copy_ext_attr(
                            p_api_version_number         IN   NUMBER,
                            p_init_msg_list              IN   VARCHAR2,
                            p_commit                     IN   VARCHAR2,
                            p_validation_level           IN   NUMBER,
   			 				p_from_audit_procedure_id   	in number,
   			 				p_to_audit_procedure_id   	in number,
                            x_return_status              OUT  NOCOPY VARCHAR2,
                            x_msg_count                  OUT  NOCOPY NUMBER,
                            x_msg_data                   OUT  NOCOPY VARCHAR2)
   IS
     l_api_name                  CONSTANT VARCHAR2(30) := 'copy_ext_attr';
     l_api_version_number        CONSTANT NUMBER   := 1.0;
     l_object_id       FND_OBJECTS.object_id%TYPE;
     l_error_code      NUMBER;
     l_application_id                fnd_application.application_id%TYPE;
     l_orig_item_pk_value_pairs      EGO_COL_NAME_VALUE_PAIR_ARRAY;
     l_new_item_pk_value_pairs       EGO_COL_NAME_VALUE_PAIR_ARRAY;
     l_commit                        VARCHAR2(20);
   CURSOR c_fnd_object_id(cp_object_name  IN VARCHAR2) IS
   SELECT  object_id
   FROM    fnd_objects
   WHERE   obj_name = cp_object_name;

   CURSOR c_get_application_id IS
   SELECT  application_id
   FROM    fnd_application
   WHERE   application_short_name = 'AMW';
   begin
      -- Standard Start of API savepoint
      SAVEPOINT COPY_EXT_ATTR;
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
	 x_return_status := fnd_api.g_ret_sts_success;

	 fnd_file.put_line(fnd_file.LOG,'Inside copy_ext_attr --> x_return_status: '||x_return_status);

     if(p_from_audit_procedure_id is null OR p_to_audit_procedure_id is null)
     then
	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNEXPECT_ERROR',
                                      p_token_name   => 'OBJ_TYPE',
                                      p_token_value  =>  G_OBJ_TYPE);
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
      OPEN c_fnd_object_id (cp_object_name  => 'AMW_AUDIT_PROCEDURE');
      FETCH c_fnd_object_id INTO l_object_id;
      IF c_fnd_object_id%NOTFOUND THEN
        l_object_id := -1;
      END IF;
      CLOSE c_fnd_object_id;

      OPEN c_get_application_id;
      FETCH c_get_application_id INTO l_application_id;
      IF c_get_application_id%NOTFOUND THEN
        l_application_id := -1;
      END IF;
      CLOSE c_get_application_id;

      l_orig_item_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
         EGO_COL_NAME_VALUE_PAIR_OBJ('AUDIT_PROCEDURE_ID', p_from_audit_procedure_id));
      l_new_item_pk_value_pairs  := EGO_COL_NAME_VALUE_PAIR_ARRAY(
         EGO_COL_NAME_VALUE_PAIR_OBJ('AUDIT_PROCEDURE_ID', p_to_audit_procedure_id));

      EGO_USER_ATTRS_DATA_PUB.Copy_User_Attrs_Data (
         p_api_version                   => 1.0
        ,p_application_id                => l_application_id
        ,p_object_id                     => l_object_id
        ,p_object_name                   => 'AMW_AUDIT_PROCEDURE'
        ,p_old_pk_col_value_pairs        => l_orig_item_pk_value_pairs
        ,p_old_dtlevel_col_value_pairs   => NULL
        ,p_new_pk_col_value_pairs        => l_new_item_pk_value_pairs
        ,p_new_dtlevel_col_value_pairs   => NULL
        ,p_new_cc_col_value_pairs        => NULL
        ,p_commit                        => FND_API.G_FALSE
        ,x_return_status                 => x_return_status
        ,x_errorcode                     => l_error_code
        ,x_msg_count                     => x_msg_count
        ,x_msg_data                      => x_msg_data
        );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     ROLLBACK TO COPY_EXT_ATTR;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     ROLLBACK TO COPY_EXT_ATTR;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN

     ROLLBACK TO COPY_EXT_ATTR;
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


   END copy_ext_attr;

procedure revise_ap_if_necessary(
                            p_api_version_number         IN   NUMBER,
                            p_init_msg_list              IN   VARCHAR2,
                            p_commit                     IN   VARCHAR2,
                            p_validation_level           IN   NUMBER,
                            p_audit_procedure_id        IN  NUMBER,
                            x_return_status              OUT  NOCOPY VARCHAR2,
                            x_msg_count                  OUT  NOCOPY NUMBER,
                            x_msg_data                   OUT  NOCOPY VARCHAR2)
IS
     l_api_name                  CONSTANT VARCHAR2(30) := 'revise_ap_if_necessary';
     l_api_version_number        CONSTANT NUMBER   := 1.0;
CURSOR c_revision_exists (l_audit_procedure_id IN NUMBER) IS
      SELECT count(*)
      FROM amw_audit_procedures_b
      GROUP BY audit_procedure_id
	  HAVING audit_procedure_id=l_audit_procedure_id;

CURSOR c_approval_status (l_audit_procedure_id IN NUMBER) IS
      SELECT audit_procedure_rev_id,
			 approval_status
      FROM amw_audit_procedures_b
	  WHERE audit_procedure_id=l_audit_procedure_id AND
	  		latest_revision_flag='Y';
l_approval_status c_approval_status%ROWTYPE;
l_dummy     NUMBER;
CURSOR c_get_rev_id IS
      SELECT amw_procedure_rev_s.nextval
      FROM dual;
l_audit_procedure_rev_id NUMBER;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT REVISE_AP_IF_NECESSARY;
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
	 x_return_status := fnd_api.g_ret_sts_success;

	    OPEN c_revision_exists(p_audit_procedure_id);
	    FETCH c_revision_exists INTO l_dummy;
	    CLOSE c_revision_exists;

		IF l_dummy IS NULL OR l_dummy < 1
        THEN
		    -- no corresponding audit_procedure_id in AMW_AUDIT_PROCEDURES_B is wrong
	  	  	AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNEXPECT_ERROR',
                                          p_token_name   => 'OBJ_TYPE',
                                          p_token_value  =>  G_OBJ_TYPE);
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_dummy >= 1
        THEN
			-- has only one record for audit_procedure_id in AMW_AUDIT_PROCEDURES_B with pass-in name
			OPEN c_approval_status(p_audit_procedure_id);
	    	FETCH c_approval_status INTO l_approval_status;
	    	CLOSE c_approval_status;

			IF l_approval_status.approval_status='P'
            THEN
			   -- this record is Pending Approval, cannot do G_OP_UPDATE or G_OP_REVISE
			   AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_PENDING_CHANGE_ERROR',
                                             p_token_name   => 'OBJ_TYPE',
                                             p_token_value  =>  G_OBJ_TYPE);
	   		   RAISE FND_API.G_EXC_ERROR;
			ELSIF l_approval_status.approval_status='A' OR l_approval_status.approval_status='R'
            THEN
                OPEN c_get_rev_id;
                FETCH c_get_rev_id INTO l_audit_procedure_rev_id;
                CLOSE c_get_rev_id;

                insert into AMW_AUDIT_PROCEDURES_B (
                    PROJECT_ID,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    OBJECT_VERSION_NUMBER,
                    APPROVAL_STATUS,
                    ORIG_SYSTEM_REFERENCE,
                    REQUESTOR_ID,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    SECURITY_GROUP_ID,
                    AUDIT_PROCEDURE_ID,
                    AUDIT_PROCEDURE_REV_ID,
                    AUDIT_PROCEDURE_REV_NUM,
                    END_DATE,
                    APPROVAL_DATE,
                    CURR_APPROVED_FLAG,
                    LATEST_REVISION_FLAG,
                    ATTRIBUTE5,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    CLASSIFICATION
                  ) (
                    SELECT PROJECT_ID,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    1,
                    'D',
                    ORIG_SYSTEM_REFERENCE,
                    REQUESTOR_ID,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    SECURITY_GROUP_ID,
                    AUDIT_PROCEDURE_ID,
                    l_audit_procedure_rev_id,
                    AUDIT_PROCEDURE_REV_NUM + 1,
                    NULL,
                    NULL,
                    'N',
                    'Y',
                    ATTRIBUTE5,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
    			   SYSDATE,
    			   G_USER_ID,
    			   SYSDATE,
    			   G_USER_ID,
    			   G_LOGIN_ID,
                    CLASSIFICATION
                    FROM AMW_AUDIT_PROCEDURES_B
                    WHERE AUDIT_PROCEDURE_REV_ID = l_approval_status.audit_procedure_rev_id
                  );

                  insert into AMW_AUDIT_PROCEDURES_TL (
                    AUDIT_PROCEDURE_REV_ID,
                    NAME,
                    DESCRIPTION,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    SECURITY_GROUP_ID,
                    LANGUAGE,
                    SOURCE_LANG
                  ) (select
                    l_audit_procedure_rev_id,
                    NAME,
                    DESCRIPTION,
    			    SYSDATE,
      			    G_USER_ID,
    			    SYSDATE,
    			    G_USER_ID,
    			    G_LOGIN_ID,
                    SECURITY_GROUP_ID,
                    LANGUAGE,
                    SOURCE_LANG
                  from AMW_AUDIT_PROCEDURES_TL
                    where AUDIT_PROCEDURE_REV_ID = l_approval_status.audit_procedure_rev_id);

                UPDATE AMW_AUDIT_PROCEDURES_B
                SET LATEST_REVISION_FLAG = 'N',
                    END_DATE = SYSDATE,
                    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
                WHERE AUDIT_PROCEDURE_REV_ID = l_approval_status.audit_procedure_rev_id;

			END IF; -- end of if:l_approval_status.approval_status
        END IF;
    EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     ROLLBACK TO REVISE_AP_IF_NECESSARY;
     x_return_status := G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     ROLLBACK TO REVISE_AP_IF_NECESSARY;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN

     ROLLBACK TO REVISE_AP_IF_NECESSARY;
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


END revise_ap_if_necessary;

END AMW_AUDIT_PROCEDURES_PVT;

/
