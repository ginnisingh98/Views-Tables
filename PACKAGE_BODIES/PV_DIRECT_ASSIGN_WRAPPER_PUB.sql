--------------------------------------------------------
--  DDL for Package Body PV_DIRECT_ASSIGN_WRAPPER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_DIRECT_ASSIGN_WRAPPER_PUB" as
 /* $Header: pvxpdawb.pls 115.14 2004/06/29 16:32:45 dhii ship $*/


--=============================================================================+
--|  Procedure                                                                 |
--|                                                                            |
--|    Create_Assignment_Wrapper                                               |
--|        This procedure is a wrapper over the CreateAssignment procedure.    |
--|        It takes care of the Opportunites to be assigned when the           |
--|        opportunity comes from OTS.                                         |
--|  Parameters                                                                |
--|  IN     p_api_version_number -                                             |
--|         p_init_msg_list                                                    |
--|         p_commit                                                           |
--|         p_validation_level                                                 |
--|         p_entity - 'OPPORUNITY'                                            |
--|         p_lead_id - Lead_id                                                |
--|         p_creating_username                                                |
--|         p_bypass_cm_ok_flag                                                |
--|  OUT                                                                       |
--|         x_return_status                                                    |
--|         x_msg_count                                                        |
--|         x_msg_data                                                         |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================

 Procedure Create_Assignment_Wrapper ( p_api_version_number    IN      NUMBER
                                      ,p_init_msg_list         IN      VARCHAR2 := FND_API.G_TRUE
                                      ,p_commit                IN      VARCHAR2 := FND_API.G_TRUE
                                      ,p_validation_level      IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                      ,p_entity                IN      VARCHAR2
                                      ,p_lead_id               IN      NUMBER
                                      ,p_creating_username     IN      VARCHAR2
                                      ,p_bypass_cm_ok_flag     IN      VARCHAR2
                                      ,x_return_status         OUT    NOCOPY VARCHAR2
                                      ,x_msg_count             OUT    NOCOPY NUMBER
                                      ,x_msg_data              OUT    NOCOPY VARCHAR2
                                      ) IS
    Type assignment_rec is REF CURSOR;
    assignment_cur              assignment_rec;

    --l_mode                      varchar2(10) := 'EMPLOYEE';
    l_partner_id_tbl            JTF_NUMBER_TABLE;
    l_rank_tbl                  JTF_NUMBER_TABLE;
    l_partner_source_tbl        JTF_VARCHAR2_TABLE_100;

    l_pt_flag                   boolean := false;
    l_duplicate_pt              boolean := false;
    l_partnerid                 number;
    l_partner_cnt_pt_id         number;
    l_party_reltn_type          varchar2(100);
    l_object_id                 number;
    l_assignment_type           varchar2(100);
    l_assigned_partners         varchar2(2000);
    l_partner_count             number := 1;

    p_data                      varchar2(500);

    l_api_name            CONSTANT VARCHAR2(30) := 'Create_Assignment_Wrapper';
    l_api_version_number  CONSTANT NUMBER       := 1.0;

Begin
	SAVEPOINT Create_Assignment_Wrapper;

	-- Standard call to check for call compatibility.
 	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
     					                p_api_version_number,
					                    l_api_name,
					                    G_PKG_NAME) THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 END IF;

	 -- Initialize message list if p_init_msg_list is set to TRUE.
	 IF FND_API.to_Boolean( p_init_msg_list )
 	 THEN
       fnd_msg_pub.initialize;
    END IF;

    l_partner_id_tbl     := JTF_NUMBER_TABLE();
    l_rank_tbl           := JTF_NUMBER_TABLE();
    l_partner_source_tbl := JTF_VARCHAR2_TABLE_100();
	x_return_status         :=  FND_API.G_RET_STS_SUCCESS ;

    IF ( p_lead_id is NULL ) THEN
      fnd_message.SET_NAME('PV', 'PV_NULL_LEAD_ID');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
    END IF;

    IF ( p_creating_username is NULL ) THEN
      fnd_message.SET_NAME('PV', 'PV_NULL_CREATE_USER');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
    END IF;

    IF ( p_bypass_cm_ok_flag is NULL ) THEN
      fnd_message.SET_NAME('PV', 'PV_NULL_CMBYPASS_FLAG');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --IF (p_entity is NULL) or p_entity  not in ('LEAD', 'OPPORTUNITY') THEN
    IF (p_entity is NULL) or p_entity  <> 'OPPORTUNITY' THEN
       fnd_message.SET_NAME('PV', 'PV_INVALID_ENTITY');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_assigned_partners := 'select  asla.INCUMBENT_PARTNER_PARTY_ID ' ||
                           'from as_leads_all asla ' ||
                           'where  asla.lead_id = :p_lead_id ';

    open assignment_cur for l_assigned_partners using p_lead_id;
    fetch assignment_cur  into l_partnerid;

    IF (assignment_cur%found AND l_partnerid is not NULL) then
        l_partner_id_tbl.extend;
        l_partner_id_tbl(l_partner_count) := l_partnerid;

        l_rank_tbl.extend;
        l_rank_tbl(l_partner_count) := l_partner_count;

        l_partner_source_tbl.extend;
        l_partner_source_tbl(l_partner_count) := 'SALESTEAM';

        l_partner_count := l_partner_count + 1;
    END IF;

   CLOSE assignment_cur;

   IF l_partner_id_tbl.count > 0 THEN

       IF l_partner_id_tbl.count > 1 THEN
           l_assignment_type := FND_PROFILE.VALUE('PV_DEFAULT_ASSIGNMENT_TYPE');
       ELSE
           l_assignment_type := 'SINGLE';
       END IF;

       PV_ASSIGNMENT_PUB.CREATEASSIGNMENT (
                             p_api_version_number  => 1.0
                             ,p_init_msg_list      => FND_API.G_TRUE
                             ,p_commit             => FND_API.G_TRUE
                             ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
                             ,p_entity             => p_entity
                             ,p_lead_id            => p_lead_id
                             ,p_creating_username  => p_creating_username
                             ,p_assignment_type    => l_assignment_type
                             ,p_bypass_cm_ok_flag  => p_bypass_cm_ok_flag
                             ,p_partner_id_tbl     => l_partner_id_tbl
                             ,p_rank_tbl           => l_rank_tbl
                             ,p_partner_source_tbl => l_partner_source_tbl
                             ,p_process_rule_id    => NULL
                             ,x_return_status      => x_return_status
                             ,x_msg_count          => x_msg_count
                             ,x_msg_data           => x_msg_data
                             );

	-- If API call returns Error raise Exception. Fix for Bug#2052029
	IF x_return_status = FND_API.g_ret_sts_error THEN
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
     ELSE
	fnd_message.SET_NAME('PV', 'PV_NO_PRTNR_TO_ROUTE');
	fnd_msg_pub.ADD;
	raise FND_API.G_EXC_ERROR;
     END IF;

     IF FND_API.To_Boolean ( p_commit )   THEN
	 COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
				p_count     =>  x_msg_count,
				p_data      =>  x_msg_data);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN

		ROLLBACK TO Create_Assignment_Wrapper;
		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
					p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		ROLLBACK TO Create_Assignment_Wrapper;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
											p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);

	WHEN OTHERS THEN

		ROLLBACK TO Create_Assignment_Wrapper;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

		fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
											p_count     =>  x_msg_count,
		                           p_data      =>  x_msg_data);


END Create_Assignment_Wrapper;
END PV_DIRECT_ASSIGN_WRAPPER_PUB;

/
