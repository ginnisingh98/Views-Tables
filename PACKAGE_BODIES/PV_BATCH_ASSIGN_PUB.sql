--------------------------------------------------------
--  DDL for Package Body PV_BATCH_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_BATCH_ASSIGN_PUB" AS
/* $Header: pvbtasnb.pls 120.3 2006/01/10 13:52:09 amaram ship $ */

/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    Global Variable Declaration                                    */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/


/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    private procedure declaration                                  */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2,
   p_msg_type      IN VARCHAR2 := 'PV_DEBUG_MESSAGE'
);


PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
);



--=============================================================================+
--| Public Procedure                                                           |
--|    PROCESS_UNASSIGNED                                                      |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|    The purpose of this procedure is to process all the timed out           |
--|    opportunites created by vendor. It will use opportunity_selection API   |
--|    to attemp to route the opportunities to partners.                       |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE PROCESS_UNASSIGNED(ERRBUF     OUT NOCOPY   VARCHAR2,
                             RETCODE    OUT NOCOPY   VARCHAR2,
                             P_COUNTRY  IN VARCHAR2,
			     P_USERNAME IN VARCHAR2,
			     P_FROMDATE IN VARCHAR2)
IS

   l_api_name            CONSTANT VARCHAR2(30) := 'PROCESS_UNASSIGNED';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_fromdate DATE := TO_DATE(p_fromdate, 'yyyy/mm/dd hh24:mi:ss');

   CURSOR lc_vendor (pc_oppty_timeout NUMBER,
                     pc_fromdate      DATE)  IS
          SELECT a.lead_id, a.description
          FROM   as_leads_all a,
                 pv_lead_workflows b,
	         pv_channel_types c,
                 as_statuses_b d
          WHERE a.channel_code                = c.channel_lookup_code
          AND   c.channel_lookup_type         = 'SALES_CHANNEL'
          AND   c.indirect_channel_flag       = 'Y'
          AND   a.lead_id                     = b.lead_id (+)
          AND   b.entity (+)                  = 'OPPORTUNITY'
          AND   b.latest_routing_flag (+)     = 'Y'
          AND   a.status		      = d.status_code
	  AND   d.opp_open_status_flag        = 'Y'
          AND   a.last_update_date	      < sysdate - pc_oppty_timeout
	  AND   a.creation_date 	      >= NVL(pc_fromdate, SYSDATE - 36500)
          AND  (b.routing_status is null OR
                b.routing_status IN ('RECYCLED','WITHDRAWN'));

   CURSOR lc_vendor_cntry(pc_oppty_timeout NUMBER,
                          pc_country       VARCHAR2,
                          pc_fromdate      DATE) IS
          SELECT a.lead_id, a.description
          FROM as_leads_all a, pv_lead_workflows b,
               pv_channel_types c,hz_party_sites d,
               hz_locations e, as_statuses_b f
          WHERE a.channel_code               = c.channel_lookup_code
          AND   a.address_id                 = d.party_site_id
          AND   d.location_id                = e.location_id
	  AND   d.status 		     IN ('A','I')
          AND   c.channel_lookup_type        = 'SALES_CHANNEL'
          AND   c.indirect_channel_flag      = 'Y'
          AND   a.lead_id                    = b.lead_id (+)
          AND   b.entity (+)                 = 'OPPORTUNITY'
          AND   b.latest_routing_flag (+)    = 'Y'
          AND   a.status		     = f.status_code
	  AND   f.opp_open_status_flag       = 'Y'
          AND   e.country                    = pc_country
          AND   a.last_update_date	      < sysdate - pc_oppty_timeout
	  AND   a.creation_date 	      >= NVL(pc_fromdate, SYSDATE - 36500)
          AND  (b.routing_status is null OR
                b.routing_status IN ('RECYCLED','WITHDRAWN'));

   CURSOR lc_get_resource (pc_username varchar2) is
          SELECT extn.category,
                 extn.resource_id
          FROM   fnd_user fuser,
                 jtf_rs_resource_extns extn
          WHERE  fuser.user_name = pc_username
          AND    fuser.user_id   = extn.user_id;

   l_rank                      number := 0;
   l_assignment_type           VARCHAR2(30);
   l_rank_tbl                  JTF_NUMBER_TABLE;
   l_source_type_tbl           JTF_VARCHAR2_TABLE_100;
   l_size                      NUMBER;
   l_resource_id               NUMBER;
   l_partner_count             NUMBER;
   l_category                  VARCHAR2(30);
   l_lead_id_tbl               JTF_NUMBER_TABLE;
   l_lead_desc_tbl             JTF_VARCHAR2_TABLE_400;
   l_partner_id_tbl            JTF_NUMBER_TABLE;

   l_return_status             VARCHAR2(1);
   l_message                   VARCHAR2(32000);
   l_msg_data		       VARCHAR2(32000);
   l_msg_count                 NUMBER;
   l_ret_code		       NUMBER;
   l_opp_count		       NUMBER := 0;
   l_oppty_timeout_set         NUMBER ;
   l_user_name 		       VARCHAR2(20);
   l_no_partner_exec	       EXCEPTION;
   l_user_not_emp_exec	       EXCEPTION;
   l_auto_match_exec	       EXCEPTION;
   l_no_user_exec	       EXCEPTION;
   l_null_timeout_exec	       EXCEPTION;
   l_selected_rule_id	       NUMBER;
   l_failure_code	       VARCHAR2(1000);
   l_lead_id		       NUMBER;

BEGIN
     Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name     => 'PV_CREATE_BATCH_START_TIME',
                 p_token1       => 'P_DATE_TIME',
                 p_token1_value => TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));


     l_return_status := FND_API.G_RET_STS_SUCCESS ;

     l_size := 0;
     l_lead_id_tbl        := JTF_NUMBER_TABLE();
     l_lead_desc_tbl      := JTF_VARCHAR2_TABLE_400();


     IF (p_country is not null) THEN
        Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                    p_msg_name     => 'PV_BATCH_COUNTRY',
                    p_token1       => 'P_COUNTRY',
                    p_token1_value => p_country);

     ELSE
        Debug('Processing the Opportunity Assignment for all countries.');
     END IF;


    IF p_username is not null THEN
        Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                    p_msg_name     => 'PV_CREATE_BATCH_USER',
                    p_token1       => 'P_USER_NAME',
                    p_token1_value => p_username);

     ELSE
        RAISE l_no_user_exec;
     END IF;

     -- ----------------------------------------------------------------------
     -- Retrieve the profile value for unassigned opportunity timeout.
     -- ----------------------------------------------------------------------
     l_oppty_timeout_set  := FND_PROFILE.VALUE('PV_OPPTY_UNASIGNED_TIMEOUT');

     IF (l_oppty_timeout_set IS NULL) THEN
	RAISE l_null_timeout_exec;
     END IF;


      --l_user_name	  := FND_PROFILE.VALUE('PV_BATCH_ASSIGN_USER_NAME');


     OPEN lc_get_resource(p_username);
     FETCH lc_get_resource INTO l_category,l_resource_id;
     Debug('l_category = ' || l_category);
     Debug('l_resource_id = ' || l_resource_id);

     IF (lc_get_resource%NOTFOUND) THEN
        CLOSE lc_get_resource;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     CLOSE lc_get_resource;

     IF (l_category <> 'EMPLOYEE') THEN
        RAISE l_user_not_emp_exec;
     END IF;


     IF p_country IS NULL THEN
         OPEN lc_vendor(l_oppty_timeout_set, l_fromdate);
         LOOP
             l_lead_id_tbl.extend;
             l_lead_desc_tbl.extend;

             l_size := l_size + 1;
             fetch lc_vendor into l_lead_id_tbl(l_size), l_lead_desc_tbl(l_size);
             exit when lc_vendor%notfound;

         END LOOP;
         CLOSE lc_vendor;

     ELSE
         OPEN lc_vendor_cntry(l_oppty_timeout_set, p_country, l_fromdate);
         LOOP
             l_lead_id_tbl.extend;
             l_lead_desc_tbl.extend;

             l_size := l_size + 1;
             fetch lc_vendor_cntry into l_lead_id_tbl(l_size), l_lead_desc_tbl(l_size);
             exit when lc_vendor_cntry%notfound;

         END LOOP;
         CLOSE lc_vendor_cntry;
     END IF;


     l_lead_id_tbl.trim;
     l_lead_desc_tbl.trim;


     Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name     => 'PV_OPPORTUNITY_COUNT',
                 p_token1       => 'P_OPP_COUNT',
                 p_token1_value => l_lead_id_tbl.count);


     -- -----------------------------------------------------------------------------
     -- Start processing unassigned opportunities retrieved.
     -- -----------------------------------------------------------------------------
     IF (l_lead_id_tbl.count > 0) THEN
         FOR j in 1..l_lead_id_tbl.count LOOP
             BEGIN
                Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                            p_msg_name     => 'PV_OPPORTUNITY_NAME',
                            p_token1       => 'TEXT',
                            p_token1_value => 'Opportunity ID :' || l_lead_id_tbl(j) ||
				              '  Opportunity Name: '||l_lead_desc_tbl(j));


                Debug('Starting Automatic matching and Routing');

		l_lead_id := l_lead_id_tbl(j);
                SAVEPOINT vendor_opp;

                Debug('**********************************************************************');
                Debug('Processing opportunity with lead_id = ' || l_lead_id);
                Debug(l_lead_desc_tbl(j));
                Debug('**********************************************************************');

			pv_opp_match_pub.Opportunity_Selection(
			p_api_version		 => l_api_version_number,
			p_init_msg_list          => FND_API.G_FALSE,
			p_commit                 => FND_API.G_FALSE,
			p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
			p_entity_id              => l_lead_id,
			p_entity                 => 'LEAD',
			p_user_name              => p_username,
			p_resource_id            => l_resource_id,
			x_selected_rule_id       => l_selected_rule_id,
			x_matched_partner_count  => l_partner_count,
			x_failure_code           => l_failure_code,
			x_return_status          => l_return_status,
			x_msg_count              => l_msg_count,
			x_msg_data               => l_msg_data
			);

 		 IF (l_return_status <> fnd_api.G_RET_STS_SUCCESS)  THEN

		    IF l_msg_count > 0 THEN

		        l_message := fnd_msg_pub.get(
                                        p_msg_index => fnd_msg_pub.g_first,                                                               p_encoded => FND_API.g_false
                                     );

		        WHILE (l_message IS NOT NULL) LOOP
			    fnd_file.put_line(FND_FILE.LOG,substr(l_message,1,200));
			    l_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);
			END LOOP;

		      END IF;

 		END IF;


		IF (l_partner_count = 0) THEN
                   RAISE l_no_partner_exec;

		ELSIF ((l_partner_count > 0) AND (l_failure_code is null)) THEN
                   Debug('Number of Partners matched and routed for the rule ' ||
                         l_selected_rule_id || 'is :' || l_partner_count);
                   Debug('Completed the Assignment process ...');

                ELSIF (l_failure_code is not null) THEN
		      RAISE l_auto_match_exec;
		END IF;

       EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
               ROLLBACK TO vendor_opp;

               Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                           p_msg_name     => 'PV_NO_OPP_ASSIGN',
                           p_token1       => 'P_OPP_NAME',
                           p_token1_value => l_lead_desc_tbl(j));

               l_opp_count := l_opp_count + 1;

          WHEN l_auto_match_exec THEN
               ROLLBACK TO vendor_opp;
               Debug('Opportunity matching and routing failed due to ' || l_failure_code);

               l_opp_count := l_opp_count+1;

      	  WHEN l_no_partner_exec THEN
	       ROLLBACK TO vendor_opp;

               Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                           p_msg_name     => 'PV_NO_PRTNR_FOR_OPPTY',
                           p_token1       => 'P_OPP_NAME',
                           p_token1_value => l_lead_desc_tbl(j));

               l_opp_count := l_opp_count + 1;

          WHEN OTHERS THEN
               ROLLBACK TO vendor_opp;
               l_opp_count := l_opp_count + 1;

               Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                           p_msg_name     => 'PV_UNKNOWN_ERROR',
                           p_token1       => 'TEXT',
                           p_token1_value => 'Database Error'||sqlcode||' '||sqlerrm);


       END;
    END LOOP;

   ELSE
      l_opp_count := null;

   END IF;


   -- --------------------------------------------------------------------------------
   -- Every unassigned opportunity found have failed to be routed for one reason or
   -- another. The user needs to check the log for the failure reason.
   -- --------------------------------------------------------------------------------
   IF (l_opp_count = l_lead_id_tbl.count) THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_ALL_OPPTY_FAILED');

      RETCODE := 1;
      ERRBUF  := fnd_message.get;

   ELSIF ((l_opp_count <> l_lead_id_tbl.count) AND (l_opp_count <> 0)) THEN
      Debug('Concurrent Program ran for '||l_lead_id_tbl.count||
            'opportunities, of which '||l_opp_count||
            ' opportunities failed. Check the Log');

      RETCODE := 1;
      ERRBUF := fnd_message.get;

   ELSIF (l_opp_count = 0) THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_ALL_OPPTY_SUCCESS');

      RETCODE := 0;
      ERRBUF := fnd_message.get;

   ELSIF (l_opp_count IS null) THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_NO_OPPTY_FOUND');


      RETCODE := 0;
      ERRBUF := fnd_message.get;
   END IF;

   Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
               p_msg_name     => 'PV_CREATE_BATCH_END_TIME',
               p_token1       => 'P_DATE_TIME',
               p_token1_value => TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));

 EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                   p_msg_name     => 'PV_NO_RESOURCE_FOUND');

       RETCODE := 2;
       ERRBUF  := fnd_message.get;

    WHEN l_user_not_emp_exec THEN
       Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                   p_msg_name     => 'PV_USER_NOT_A_EMPLOYEE');

        RETCODE := 2;
        ERRBUF  := fnd_message.get;

     WHEN l_no_user_exec THEN
       Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                   p_msg_name     => 'PV_NO_BATCH_USER',
                   p_token1       => 'TEXT',
                   p_token1_value => 'No Assignment Manager specified, Cannot run the ' ||
                                     'Assignment process');

       RETCODE := 2;
       ERRBUF  := fnd_message.get;

    WHEN l_null_timeout_exec THEN
       Debug('Timeout value is not set. Set the timeout value and run the process');

       RETCODE := 2;
       ERRBUF  := fnd_message.get;

    WHEN OTHERS THEN
       Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                   p_msg_name     => 'PV_UNKNOWN_ERROR',
                   p_token1       => 'TEXT',
                   p_token1_value => 'Database Error:'||sqlcode||' '||sqlerrm);

       RETCODE := 1;
       ERRBUF  := fnd_message.get;
 END PROCESS_UNASSIGNED;


--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Debug                                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2,
   p_msg_type      IN VARCHAR2 := 'PV_DEBUG_MESSAGE'
)
IS
BEGIN
   FND_MESSAGE.Set_Name('PV', p_msg_type);
   FND_MESSAGE.Set_Token('TEXT', p_msg_string);

   IF (g_log_to_file = 'N') THEN
      FND_MSG_PUB.Add;

   ELSIF (g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
   END IF;
END Debug;
-- =================================End of Debug================================



--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level) THEN
        FND_MESSAGE.Set_Name('PV', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);

        IF (p_token1 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        END IF;

        IF (p_token2 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        END IF;

        IF (p_token3 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        END IF;

        IF (g_log_to_file = 'N') THEN
           FND_MSG_PUB.Add;

        ELSIF (g_log_to_file = 'Y') THEN
           FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
        END IF;
    END IF;
END Set_Message;
-- ==============================End of Set_Message==============================


END;

/
