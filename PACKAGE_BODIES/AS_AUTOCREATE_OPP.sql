--------------------------------------------------------
--  DDL for Package Body AS_AUTOCREATE_OPP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_AUTOCREATE_OPP" as
/* $Header: asxldopb.pls 120.3 2006/04/20 02:57:43 subabu ship $ */

-- Start of Comments
-- Package name     : AS_AUTOCREATE_OPP
-- Purpose          : Create opportunity records from sales lead tables
-- History          : 08/02/00 FFANG  Created.
-- NOTE             : This concurrent program should be run after runing
--                    Terretory Assignment Manager
-- End of Comments
--

-- Logging function - Local
--
-- p_which = 1. write to log
-- p_which = 2, write to output
--
PROCEDURE Write_Log(p_which number, p_mssg  varchar2) IS
BEGIN
    FND_FILE.put(p_which, p_mssg);
    FND_FILE.NEW_LINE(p_which, 1);
END Write_Log;



PROCEDURE Create_Opp_from_Sales_lead(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_debug_mode          IN  VARCHAR2,
    p_trace_mode          IN  VARCHAR2)
IS
   CURSOR c_Get_Sales_leads IS
       SELECT sales_lead_id
       FROM as_sales_leads l
       WHERE assign_to_salesforce_id in
	            (SELECT salesforce_id
	             FROM as_salesforce_v
	             WHERE role_type_code <> 'TELESALES')
             and sales_lead_id not in
                 (SELECT sales_lead_id
                  FROM as_sales_lead_opportunity);


Cursor C_GetIdentity_FndUser(p_user_id Number) IS
              Select     force.resource_id
              From JTF_RS_RESOURCE_EXTNS force, JTF_RS_ROLE_RELATIONS rrel
			   ,JTF_RS_ROLES_B roleb, FND_User fnd_user
              Where force.user_id = fnd_user.user_id
              and fnd_user.user_id = p_user_id
	         and force.category in ('EMPLOYEE','PARTY')
		    and force.resource_id = rrel.role_resource_id
		    and rrel.role_resource_type = 'RS_INDIVIDUAL'
		    and rrel.role_id = roleb.role_id
		    and roleb.role_type_code in ('SALES','TELESALES','FIELDSALES','PRM')
		    and rownum = 1;

Cursor C_GetIdentity_SGID(p_salesforce_id Number) IS
SELECT group_id
		  FROM jtf_rs_group_members GRPMEM
		 WHERE resource_id = p_salesforce_id
		   AND delete_flag = 'N'
		   AND EXISTS
			(SELECT 'X'
			   FROM jtf_rs_role_relations REL
			  WHERE role_resource_type = 'RS_GROUP_MEMBER'
			    AND delete_flag = 'N'
			    AND sysdate between REL.start_date_active and nvl(REL.end_date_active,sysdate)
			    AND REL.role_resource_id = GRPMEM.group_member_id
			    AND role_id IN (SELECT role_id FROM jtf_rs_roles_b WHERE role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM')));



   l_sales_lead_id    NUMBER;
   l_opportunity_id   NUMBER;
   l_salesforce_id    NUMBER;
   l_salesgroup_id    NUMBER;
   l_return_status    VARCHAR2(1);
   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2(1000);
   commit_counter     INTEGER  := 100;
   l_counter          INTEGER  := 0;
   l_total_success    INTEGER  := 0;
   l_total_process    INTEGER  := 0;
   l_status           BOOLEAN;

BEGIN

     Write_log (1, '*** Auto-create opportunity from sales leads start ***');
OPEN C_GetIdentity_FndUser(FND_GLOBAL.User_Id);
     FETCH C_GetIdentity_FndUser INTO l_salesforce_id;
     IF ( C_GetIdentity_FndUser%NOTFOUND) THEN
             Close C_GetIdentity_FndUser;
             write_log(1,'Error in Login user');
             RAISE FND_API.G_EXC_ERROR;

      END IF;
      Close C_GetIdentity_FndUser;
      write_log(1,'Login Resource id : ' || l_salesforce_id);

     OPEN C_GetIdentity_SGID(l_salesforce_id);
     FETCH C_GetIdentity_SGID INTO l_salesgroup_id;
     IF ( C_GetIdentity_SGID%NOTFOUND) THEN
             Close C_GetIdentity_SGID;
             write_log(1,'Error in Login Group id');
             RAISE FND_API.G_EXC_ERROR;
      END IF;
      Close C_GetIdentity_SGID;
      write_log(1,'Login Group id : ' || l_salesgroup_id);

     OPEN c_Get_Sales_leads;
     LOOP
         FETCH c_Get_Sales_leads into l_sales_lead_id;

         IF ( c_Get_Sales_leads%NOTFOUND) THEN
             Close c_Get_Sales_leads;
             exit;
         END IF;

         l_total_process := l_total_process + 1;

         AS_SALES_LEADS_PUB.Create_Opportunity_For_Lead
                ( p_api_version_number => 2.0,
                  p_init_msg_list => FND_API.G_TRUE,
                  p_commit => FND_API.G_FALSE,
                  p_validation_level => 90,
                  P_Check_Access_Flag => 'Y',
                  P_Admin_Flag => 'N',
                  P_Admin_Group_Id => NULL,
                  P_Identity_Salesforce_Id => l_salesforce_id,
		  P_identity_salesgroup_id =>l_salesgroup_id,
                  P_sales_lead_profile_tbl => AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
                  --P_Partner_Cont_Party_id => FND_API.G_MISS_NUM,
                  P_sales_lead_id => l_sales_lead_id,
                  x_return_status => l_return_status,
                  x_msg_count => l_msg_count,
                  x_msg_data => l_msg_data,
                  X_opportunity_ID => l_opportunity_id);

         IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             IF p_debug_mode = 'Y' and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxldopb', 'Successfully create opportunity '||
                               to_char(l_opportunity_id) || 'for sales lead' ||
                               to_char(l_sales_lead_id));
             END IF;
             l_total_success := l_total_success + 1;
         ELSE
		 FND_MSG_PUB.Count_And_Get
				(  p_count          =>   l_msg_count,
				   p_data           =>   l_msg_data
			        );
			AS_UTILITY_PVT.Get_Messages(l_msg_count, l_msg_data);
			Write_log (1,'Fail to create opportunity for sales lead : ' ||
                               to_char(l_sales_lead_id));
			Write_log (1, 'Error is : '|| l_msg_data);

             IF p_debug_mode = 'Y' and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxldopb', 'Fail to create opportunity for sales lead' ||
                               to_char(l_sales_lead_id));
             END IF;
             IF l_return_status <> FND_API.G_RET_STS_ERROR THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
         END IF;

         IF l_counter = commit_counter THEN
             COMMIT;
             l_counter := 0;
         ELSE
             l_counter := l_counter + 1;
         END IF;

     END LOOP;
     COMMIT;
     Write_log (1, 'Total number of sales leads processed: ' ||
			    to_char(l_total_process));
     Write_log (1, 'Total number of opportunities created: ' ||
                   to_char(l_total_success));
     Write_log (1, '*** End of Auto-create opportunities ***');

     EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             ERRBUF := ERRBUF || sqlerrm;
             RETCODE := FND_API.G_RET_STS_ERROR;
             ROLLBACK;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, 'Error in Create_Opp_from_Sales_lead');
             Write_log (1, 'SQLCODE ' || to_char(SQLCODE) ||
                           ' SQLERRM ' || substr(SQLERRM, 1, 100));

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ERRBUF := ERRBUF||sqlerrm;
             RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
             ROLLBACK;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, 'Unexpected error in Create_Opp_from_Sales_lead');
             Write_log (1, 'SQLCODE ' || to_char(SQLCODE) ||
                           ' SQLERRM ' || substr(SQLERRM, 1, 100));

         WHEN OTHERS THEN
             ERRBUF := ERRBUF||sqlerrm;
             RETCODE := '2';
             ROLLBACK;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, 'Other error in Create_Opp_from_Sales_lead');
             Write_log (1, 'SQLCODE ' || to_char(SQLCODE) ||
                           ' SQLERRM ' || substr(SQLERRM, 1, 100));
END Create_Opp_from_Sales_lead;

END AS_AUTOCREATE_OPP;

/
