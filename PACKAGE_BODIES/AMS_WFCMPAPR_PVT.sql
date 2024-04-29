--------------------------------------------------------
--  DDL for Package Body AMS_WFCMPAPR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_WFCMPAPR_PVT" AS
/* $Header: amsvwcab.pls 120.0.12010000.3 2009/10/21 04:01:56 hbandi ship $*/


--  Start of Comments
--
-- NAME
--   AMS_WFCmpApr_PVT
--
-- PURPOSE
--   This package contains the workflow procedures for
--   Campaign Approval in Oracle Marketing
--
-- HISTORY
--   09/13/1999        ptendulk        CREATED
--   01/28/2000        ptendulk        Modified JTF Interaction
--   03/10/2000        ptendulk        Modified for Bug 1226905
--   06/07/2000        ptendulk        Modified , used the faster JTF view for resources
--   06/08/2000        ptendulk        1. Modified the Update status process
--                                     2. Modified the create Notif Doc Procedure
--  02-dec-2002  dbiswas    NOCOPY and debug-level changes for performance


G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_WFCmpApr_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(15):='amsvwcab.pls';

--


/***************************  PRIVATE ROUTINES  *******************************/

-- Start of Comments
--
-- NAME
--   Handle_Err
--
-- PURPOSE
--   This Procedure will Get all the Errors from the Message stack and
--   Set the Workflow item attribut with the Error Messages
--
-- Used By Activities
--
--
-- NOTES
--
-- HISTORY
--   11/05/1999        ptendulk            created
-- End of Comments
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Handle_Err
            (p_itemtype                 IN VARCHAR2    ,
             p_itemkey                  IN VARCHAR2    ,
             p_msg_count                IN NUMBER      , -- Number of error Messages
             p_msg_data                 IN VARCHAR2    ,
             p_attr_name                IN VARCHAR2
            )
IS
     l_msg_count 	  		 NUMBER ;
	 l_msg_data		 	 VARCHAR2(2000);
	 l_final_data	  		 VARCHAR2(4000);
	 l_msg_index	  		 NUMBER ;
	 l_cnt			 	 NUMBER := 0 ;
BEGIN

	WHILE l_cnt < p_msg_count
		LOOP
   		FND_MSG_PUB.Get(p_msg_index 	   => l_cnt + 1,
         			p_encoded	   => FND_API.G_FALSE,
 	              		p_data      	   => l_msg_data,
             		        p_msg_index_out    => l_msg_index )       ;
        	l_final_data := l_final_data ||l_msg_index||': '||l_msg_data||fnd_global.local_chr(10) ;
		l_cnt := l_cnt + 1 ;
	END LOOP ;
	WF_ENGINE.SetItemAttrText(itemtype     =>    p_itemtype,
				  itemkey	   => 	 p_itemkey ,
				  aname	   	   =>	 p_attr_name,
		   		  avalue	   =>  	 l_final_data   );

END Handle_Err;

-- Start of Comments
--
-- NAME
--   Create_WFreqest
--
-- PURPOSE
--   This Procedure inserts workflow process data into AMS_ACT_WF_REQUESTS
--   table and returns SUCCESS if the insertion is successful
--   else it will return FAILURE
--
-- CALLED BY
--


--
-- NOTES
--
--
-- HISTORY
--   09/16/1999        ptendulk            created
-- End of Comments


PROCEDURE Create_WFreqest(p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
					   	  x_return_status        OUT NOCOPY  VARCHAR2,
  						  x_msg_count            OUT NOCOPY  NUMBER  ,
						  x_msg_data             OUT NOCOPY  VARCHAR2,
						  p_obj_id            	 IN   NUMBER,
		  				  p_object_type	         IN   VARCHAR2,
		  			   	  p_approval_type	 IN   VARCHAR2,
						  p_submitted_by 	 IN   NUMBER,
						  p_item_key		 IN   VARCHAR2,
						  P_stat_code		 IN   VARCHAR2,
                          p_stat_id              IN   NUMBER)
IS

   l_api_name      CONSTANT VARCHAR2(30)  := 'Create_WFreqest';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   -- Status Local Variables
   l_return_status          VARCHAR2(1);  -- Return value from procedures

   x_rowid 		       	  VARCHAR2(30);

   l_wf_request_id		  NUMBER;

	CURSOR C_wf_request_id_seq IS
		 SELECT ams_act_wf_requests_s.NEXTVAL
		 FROM DUAL;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_wfreq_PVT;

    IF (AMS_DEBUG_HIGH_ON) THEN



    AMS_Utility_PVT.debug_message(l_full_name||': start');

    END IF;

    IF FND_API.to_boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;


    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    --
    -- API body
    --

	--
	--  Insert the Record
	--
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name ||': insert');
    END IF;

    --
	-- open cursor AND fetch into local variable
    --
	OPEN  C_wf_request_id_seq;
	FETCH C_wf_request_id_seq INTO l_wf_request_id;
	-- close cursor
	CLOSE C_wf_request_id_seq;


	INSERT INTO ams_act_wf_requests
    	(activity_wf_request_id

    	-- standard who columns
     	,last_update_date
     	,last_updated_by
     	,creation_date
     	,created_by
    	,last_update_login

        ,object_version_number
    	,act_wf_req_submitted_for_id
        ,arc_act_wf_req_submitted_for
    	,submitted_by_user_id
    	,request_type
    	,approval_type
    	,workflow_item_key
    	,workflow_process_name
    	,status_code
        ,user_status_id
    	,status_date
    	,description
    	,notes
    	)
    	VALUES
    	(
    	l_wf_request_id

    	-- standard who columns
    	,sysdate
    	,FND_GLOBAL.User_Id
    	,sysdate
    	,FND_GLOBAL.User_Id
    	,FND_GLOBAL.Conc_Login_Id

    	,1
    	,p_obj_id
    	,p_object_type
    	,p_submitted_by
    	,'APPROVAL_REQUEST'
    	,p_approval_type
    	,p_item_key
    	,'AMS_APPROVAL'
    	,p_STAT_CODE
        ,p_stat_id
    	,sysdate
    	,null
    	,null
        );

    --
    -- END of API body.
    --


	--
    -- Standard call to get message count AND IF count is 1, get message info.
	--
        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
	  p_encoded	    	=>      FND_API.G_FALSE
        );

    IF (AMS_DEBUG_HIGH_ON) THEN



    AMS_Utility_PVT.debug_message(l_full_name ||': end');

    END IF;



  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

	        ROLLBACK TO Create_wfreq_PVT;
        	x_return_status := FND_API.G_RET_STS_ERROR ;

	        FND_MSG_PUB.Count_AND_Get
        	( p_count           =>      x_msg_count,
	          p_data            =>      x_msg_data,
		  	  p_encoded	    	=>      FND_API.G_FALSE
	        );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	        ROLLBACK TO Create_wfreq_PVT;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	        FND_MSG_PUB.Count_AND_Get
        	( p_count           =>      x_msg_count,
	          p_data            =>      x_msg_data,
		  	  p_encoded	    	=>      FND_API.G_FALSE
	        );


        WHEN OTHERS THEN

	        ROLLBACK TO Create_wfreq_PVT;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  	        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        	THEN
              		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
	        END IF;

	        FND_MSG_PUB.Count_AND_Get
        	( p_count           =>      x_msg_count,
	          p_data            =>      x_msg_data,
		  	  p_encoded	    	=>      FND_API.G_FALSE
	        );

END Create_WFreqest;


-- Start of Comments
--
-- NAME
--   Find_Owner
--
-- PURPOSE
--   This Procedure will be return the User role for
--   the userid sent
--
-- Called By
--
-- NOTES
--
-- HISTORY
--   11/30/1999        ptendulk      created
--   01/28/2000        ptendulk      Modified
-- End of Comments


PROCEDURE Get_User_Role
  ( p_user_id	          IN	NUMBER,
    x_role_name	          OUT NOCOPY VARCHAR2,
    x_role_display_name	  OUT NOCOPY VARCHAR2 )
IS

BEGIN
-- Pass the Employee ID to get the Role

--    IF (l_emp_id IS NOT NULL) THEN
      WF_DIRECTORY.getrolename
        	( p_orig_system		=> 'PER',
        	  p_orig_system_id	=> p_user_id ,
        	  p_name		=> x_role_name,
        	  p_display_name	=> x_role_display_name );
--    ELSE

-- Has to be changed once the JTF is integrated with Workflow Directory
--  Following Code is Commented by ptendulk as for
--  Marketing Approvals will go to Only Employees so
--  Find out Roles only from Employees Dt : 28Jan2000

--      WF_DIRECTORY.getrolename
--        	( p_orig_system		=> 'FND_USR',
--        	  p_orig_system_id	=> p_user_id,
--        	  p_name		    => x_role_name,
--        	  p_display_name	=> x_role_display_name );
--        WF_DIRECTORY.getrolename
--        	( p_orig_system		=> 'JTF',
--        	  p_orig_system_id	=> p_user_id,
--        	  p_name		    => x_role_name,
--        	  p_display_name	=> x_role_display_name );
--
--   END IF;
END Get_User_Role;

-- Start of Comments
--
-- NAME
--   Find_Owner
--
-- PURPOSE
--   This Procedure will be called to find
--   username of the Owner of the Activity
--
-- Called By
--
-- NOTES
--   When the process is started , all the variables are extracted
--   from database using Activity id passed to the Start Process
--
-- HISTORY
--   11/30/1999        ptendulk            created
--
-- End of Comments

PROCEDURE Find_Owner
            (p_activity_id             IN  NUMBER           ,
             p_activity_type           IN  VARCHAR2         ,
             x_owner_role              OUT NOCOPY VARCHAR2
            )
IS


CURSOR c_camp_det(l_camp_id NUMBER) IS
    SELECT  owner_user_id
    FROM    ams_campaigns_vl
    WHERE   campaign_id = l_camp_id  ;


-- Added By ptendulk on 28 Jan 2000, The Owner
-- of the campaign will be the Owner of the parent
-- Campaign Owner If it exist

l_parent_id NUMBER;
CURSOR c_parent_camp IS
    SELECT parent_campaign_id
    FROM   ams_campaigns_vl
    WHERE  campaign_id = p_activity_id ;

CURSOR c_deli_det IS
    SELECT  owner_user_id
    FROM    ams_deliverables_vl deli
    WHERE   deliverable_id = p_activity_id ;

CURSOR c_eveh_det IS
    SELECT  owner_user_id
    FROM    ams_event_headers_vl
    WHERE   event_header_id = p_activity_id ;

-- Changed By ptendulk on 28 Jan 2000, The Owner
-- of the Event Offer will be the Owner of the Event
-- Header of that Campaign

CURSOR c_eveo_det IS
    SELECT  e.owner_user_id
    FROM    ams_event_offers_vl o,ams_event_headers_vl e
    WHERE   o.event_offer_id = p_activity_id
    AND     o.event_header_id = e.event_header_id  ;

-- Following Code is Added by ptendulk on 28th Jan
-- Get the person ID from JTF
-- Following code is modified by ptendulk on 07-Jun-2000
-- the view is changed to faster jtf view
CURSOR c_get_person(l_res_id NUMBER) IS
     SELECT employee_id source_id
     FROM   ams_jtf_rs_emp_v
     WHERE  resource_id = l_res_id ;

     l_person_id NUMBER ;

l_resource_id NUMBER;
l_display_name VARCHAR2(240);

BEGIN
    IF      p_activity_type = 'CAMP' THEN
        OPEN c_parent_camp ;
        FETCH c_parent_camp INTO l_parent_id ;
        IF l_parent_id IS NULL THEN
           l_parent_id := p_activity_id ;
        END IF ;
        CLOSE c_parent_camp ;

        OPEN  c_camp_det(l_parent_id);
        FETCH c_camp_det INTO l_resource_id;
        CLOSE c_camp_det ;
    ELSIF   p_activity_type = 'DELV' THEN
        OPEN  c_deli_det;
        FETCH c_deli_det INTO l_resource_id;
        CLOSE c_deli_det ;
    ELSIF   p_activity_type = 'EVEH' THEN
        OPEN  c_eveh_det;
        FETCH c_eveh_det INTO l_resource_id;
        CLOSE c_eveh_det ;
    ELSIF   p_activity_type = 'EVEO' THEN
        OPEN  c_eveo_det;
        FETCH c_eveo_det INTO l_resource_id;
        CLOSE c_eveo_det ;
    END IF ;

    -- Get the Resource id from JTF
    OPEN c_get_person(l_resource_id) ;
    FETCH c_get_person INTO l_person_id ;
    CLOSE c_get_person ;

--    x_owner_user_name := l_resource_name ;
    /***************8888 Has to be removed *****************/
--     l_resource_id := 12037 ; -- Userid for BGEORGE
--    l_resource_id := 10446 ; -- Userid for NRENGASW

   IF (AMS_DEBUG_HIGH_ON) THEN



   ams_utility_pvt.debug_message('Owner Person : '||l_person_id);

   END IF;

    Get_User_Role
      ( p_user_id	          => l_person_id,
        x_role_name		  => x_owner_role,
        x_role_display_name	  => l_display_name) ;

END Find_Owner    ;

-- Start of Comments
--
-- NAME
--   Find_Manager
--
-- PURPOSE
--   This Procedure will be called to find
--   username of the Manager of the Requester
--
-- Called By
--
-- NOTES
--   When the process is started , all the variables are extracted
--   from database using Activity id passed to the Start Process
--
-- HISTORY
--   11/30/1999        ptendulk            created
-- End of Comments

PROCEDURE Find_Manager
            (p_user_id         IN  NUMBER           ,
             x_manager_role    OUT NOCOPY VARCHAR2
            )
IS
    CURSOR c_user_det IS
    SELECT  manager_id,employee_id
    FROM    ams_jtf_rs_emp_v
    WHERE   resource_id = p_user_id ;

    -- Write cirsor to get Manager's Resource ID

--    CURSOR c_manager_usr(l_mgr_id IN NUMBER) IS
--    SELECT  resource_id
--    FROM    jtf_resource_extn
--    WHERE   employee_person_id = l_mgr_id ;


l_man_person_id NUMBER ;
l_person_id     NUMBER;
l_manager_id    NUMBER;
l_display_name  VARCHAR2(240);

BEGIN

OPEN  c_user_det ;
FETCH c_user_det INTO l_man_person_id ,l_person_id ;
CLOSE c_user_det ;

-- Following code is modified by ptendulk on 8th Mar
--  If the manager not found then Manger's approval not required
IF l_man_person_id IS NULL THEN
   l_man_person_id := l_person_id ;
END IF ;

-- Give call to find Resource ID of Manager

    /*************** Has to be removed *****************/
--     l_mgr_person_id :=  12038 ; -- Userid for NRENGASW
--l_mgr_person_id := 10446 ; -- Userid for PTENDULK
IF (AMS_DEBUG_HIGH_ON) THEN

ams_utility_pvt.debug_message('Manager: '||l_man_person_id );
END IF;

Get_User_Role
      ( p_user_id	          => l_man_person_id,
        x_role_name		  => x_manager_role,
        x_role_display_name	  => l_display_name) ;


END Find_Manager    ;

-- Start of Comments
--
-- NAME
--   Find_Source
--
-- PURPOSE
--   This Procedure will be called to find
--   username of the Fund Manager of the Activity
--
-- Called By
--
-- NOTES
--   When the process is started , all the variables are extracted
--   from database using Activity id passed to the Start Process
--
-- HISTORY
--   01/28/2000  Created
-- End of Comments
PROCEDURE Find_Source
          ( p_activity_type   IN  VARCHAR2,
            p_activity_id     IN  VARCHAR2,
            x_source_type    OUT NOCOPY  VARCHAR2,
            x_source_id      OUT NOCOPY  NUMBER
            )
IS


CURSOR c_camp_det IS
    SELECT fund_source_type,
           fund_source_id
    FROM   ams_campaigns_vl
    WHERE  campaign_id = p_activity_id ;

CURSOR c_deli_det IS
    SELECT fund_source_type,
           fund_source_id
    FROM   ams_deliverables_vl
    WHERE  deliverable_id = p_activity_id ;

CURSOR c_eveh_det IS
    SELECT fund_source_type_code,
           fund_source_id
    FROM   ams_event_headers_vl
    WHERE  event_header_id = p_activity_id ;

CURSOR c_eveo_det IS
    SELECT fund_source_type_code,
           fund_source_id
    FROM   ams_event_offers_vl
    WHERE  event_offer_id = p_activity_id ;


BEGIN
  IF p_activity_type = 'CAMP' THEN
     OPEN c_camp_det ;
     FETCH c_camp_det INTO x_source_type,x_source_id ;
     CLOSE c_camp_det ;
  ELSIF p_activity_type = 'DELV' THEN
     OPEN c_deli_det ;
     FETCH c_deli_det INTO x_source_type,x_source_id ;
     CLOSE c_deli_det ;
  ELSIF p_activity_type = 'EVEH' THEN
     OPEN c_eveh_det ;
     FETCH c_eveh_det INTO x_source_type,x_source_id ;
     CLOSE c_eveh_det ;
  ELSIF p_activity_type = 'EVEO' THEN
     OPEN c_eveo_det ;
     FETCH c_eveo_det INTO x_source_type,x_source_id ;
     CLOSE c_eveo_det ;
  END IF ;
END Find_Source ;

-- Start of Comments
--
-- NAME
--   Find_Fund_Manager
--
-- PURPOSE
--   This Procedure will be called to find
--   username of the Fund Manager of the Activity
--
-- Called By
--
-- NOTES
--   When the process is started , all the variables are extracted
--   from database using Activity id passed to the Start Process
--
-- HISTORY
--   11/30/1999        ptendulk      created
--   01/29/2000        ptendulk      Modified
-- End of Comments
PROCEDURE Find_Fund_Manager
            ( p_activity_type   IN  VARCHAR2,
              p_activity_id     IN  VARCHAR2,
              x_manager_role    OUT NOCOPY VARCHAR2
            )
IS

l_source_id   NUMBER ;
l_source_type VARCHAR2(30);

CURSOR c_fund_det IS
    SELECT  owner
    FROM    ozf_funds_vl
    WHERE   fund_id = l_source_id   ;

CURSOR c_camp_det IS
    SELECT  owner_user_id
    FROM    ams_campaigns_vl
    WHERE   campaign_id = l_source_id   ;

CURSOR c_deli_det IS
    SELECT  owner_user_id
    FROM    ams_deliverables_vl deli
    WHERE   deliverable_id = l_source_id ;

CURSOR c_eveh_det IS
    SELECT  owner_user_id
    FROM    ams_event_headers_vl
    WHERE   event_header_id = l_source_id ;

CURSOR c_eveo_det IS
    SELECT  owner_user_id
    FROM    ams_event_offers_vl
    WHERE   event_offer_id = l_source_id ;

-- Following Code is Added by ptendulk on 28th Jan
-- Get the person ID from JTF
-- Following code is modified by ptendulk on 07-Jun-00
-- Replaced JTF view with the faster one
CURSOR c_get_person(l_res_id NUMBER) IS
     SELECT employee_id source_id
     FROM   ams_jtf_rs_emp_v
     WHERE  resource_id = l_res_id ;

l_person_id NUMBER;
l_resource_id NUMBER;
l_display_name VARCHAR2(240);
BEGIN
  -- Find the Source for Fund for the current Activity
  Find_Source
          ( p_activity_type  => p_activity_type,
            p_activity_id    => p_activity_id,
            x_source_type    => l_source_type,
            x_source_id      => l_source_id ) ;

  IF l_source_type = 'FUND' THEN
     OPEN c_fund_det ;
     FETCH c_fund_det INTO l_resource_id ;
     CLOSE c_fund_det ;
  ELSIF l_source_type = 'CAMP' THEN
     OPEN c_camp_det ;
     FETCH c_camp_det INTO l_resource_id ;
     CLOSE c_camp_det ;
  ELSIF l_source_type = 'EVEH' THEN
     OPEN c_eveh_det ;
     FETCH c_eveh_det INTO l_resource_id ;
     CLOSE c_eveh_det ;
  ELSIF l_source_type = 'EVEO' THEN
     OPEN c_eveo_det ;
     FETCH c_eveo_det INTO l_resource_id ;
     CLOSE c_eveo_det ;
  END IF ;

  -- Get the Resource id from JTF
  OPEN c_get_person(l_resource_id) ;
  FETCH c_get_person INTO l_person_id ;
  CLOSE c_get_person ;

--    x_owner_user_name := l_resource_name ;
    /***************8888 Has to be removed *****************/
--     l_resource_id := 12037 ; -- Userid for BGEORGE
--    l_resource_id := 10446 ; -- Userid for NRENGASW

  Get_User_Role
      ( p_user_id	          => l_person_id,
        x_role_name		  => x_manager_role,
        x_role_display_name	  => l_display_name) ;

--x_manager_role := 'SSUNDARE' ;
-- x_manager_role := 'NRENGASW' ;

--Get_User_Role
--      ( p_user_id	          => l_mgr_person_id,
--        x_role_name		      => x_manager_role,
--        x_role_display_name	  => l_display_name) ;
--
END Find_Fund_Manager    ;

-- Start of Comments
--
-- NAME
--   Get_Lookup_meaning
--
-- PURPOSE
--   This Function Will return the meaning of the Lookup used in Approvals
--
-- CALLED BY
--   Prepare_Doc
--
-- NOTES
--
--
-- HISTORY
--   09/14/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

FUNCTION Get_Lookup_meaning(p_lookup_type  IN  VARCHAR2,
                             p_lookup_code  IN  VARCHAR2)
RETURN VARCHAR2
IS
    CURSOR c_meaning IS
    SELECT  meaning
    FROM    ams_lookups
    WHERE   lookup_type = p_lookup_type
    AND     lookup_code = p_lookup_code ;
    l_meaning VARCHAR2(80);
BEGIN
    OPEN  c_meaning ;
    FETCH c_meaning INTO l_meaning ;
    CLOSE c_meaning ;
    RETURN(l_meaning);
END;


-- Start of Comments
--
-- NAME
--   StartProcess
--
-- PURPOSE
--   This Procedure will Start the flow
--
--
-- IN
--
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   09/13/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE StartProcess
           (p_approval_for            IN   VARCHAR2
            ,p_approval_for_id	      IN   NUMBER
            ,p_object_version_number  IN   NUMBER
            ,p_orig_stat_id           IN   NUMBER
            ,p_new_stat_id            IN   NUMBER
            ,p_requester_userid       IN   NUMBER
            ,p_notes_from_requester   IN   VARCHAR2   DEFAULT NULL
            ,p_workflowprocess        IN   VARCHAR2   DEFAULT NULL
            ,p_item_type              IN   VARCHAR2   DEFAULT NULL
		   )
IS
    itemtype         VARCHAR2(30) := nvl(p_item_type,'AMSAPPR');
    itemkey          VARCHAR2(30) := p_approval_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss');
    itemuserkey      VARCHAR2(80) := p_approval_for||'-'||p_approval_for_id ;

    l_requester_role VARCHAR2(100) ;
    l_manager_role   VARCHAR2(100) ;
    l_display_name   VARCHAR2(240) ;
    l_appr_for       VARCHAR2(240) ;

-- Following code is modified by ptendulk on 07-Jun-00
-- Replaced JTF view with the faster one
    CURSOR c_resource IS
    SELECT resource_id ,employee_id source_id
    FROM   ams_jtf_rs_emp_v
    WHERE  user_id = p_requester_userid ;
    l_requester_id  NUMBER ;
    l_person_id     NUMBER ;

BEGIN
-- Start Process :
--  If workflowprocess is passed, it will be run.
--  If workflowprocess is NOT passed, the selector function
--  defined in the item type will determine which process to run.
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Start :Item Type : '||itemtype||' Item key : '||itemkey);
   END IF;
   -- dbms_output.put_line('Start :Item Type : '||itemtype||' Item key : '||itemkey);

   WF_ENGINE.CreateProcess (itemtype   =>   itemtype, --itemtype,
                            itemkey    =>   itemkey ,
                            process    =>   p_workflowprocess);

   WF_ENGINE.SetItemUserkey(itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            userkey    =>   itemuserkey);

-- Initialize Workflow Item Attributes

   WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype ,
                            itemkey    =>  itemkey,
                            aname      =>  'AMS_APPROVAL_FOR_OBJECT',
                            avalue     =>   p_approval_for  );

   WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype ,
                            itemkey    =>  itemkey,
                            aname      =>  'AMS_ACT_ID',
                            avalue     =>  p_approval_for_id  );

   WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                            itemkey    =>  itemkey,
                            aname      =>  'AMS_ORIG_STAT_ID',
                            avalue     =>  p_orig_stat_id  );

   WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                            itemkey    =>  itemkey,
                            aname      =>  'AMS_NEW_STAT_ID',
                            avalue     =>  p_new_stat_id  );

   WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                            itemkey    =>  itemkey,
                            aname      =>  'AMS_OBJECT_VERSION_NUMBER',
                            avalue     =>  p_object_version_number  );

   WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                            itemkey    =>  itemkey,
                            aname      =>  'AMS_NOTES_FROM_REQUESTER',
                            avalue     =>  nvl(p_notes_from_requester,'') );

   OPEN c_resource ;
   FETCH c_resource INTO l_requester_id ,l_person_id ;
   CLOSE c_resource ;

   WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                            itemkey    =>  itemkey,
                            aname      =>  'AMS_REQUESTER_ID',
                            avalue     =>  l_requester_id  );

    l_appr_for := Get_Lookup_Meaning('AMS_SYS_ARC_QUALIFIER',p_approval_for);

    WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                            itemkey    =>  itemkey,
                            aname      =>  'AMS_APPR_FOR',
                            avalue     =>  l_appr_for  );

     Get_User_Role
            (p_user_id	          => l_person_id,
            x_role_name		  => l_requester_role,
            x_role_display_name	  => l_display_name     );


-- Following Code is Commented by ptendulk as Find Manager will be called in Set
-- Activity Details
--    Find_Manager
--            (p_user_id            => p_requester_userid,
--             x_manager_role       => l_manager_role        );
--    WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype,
--                            itemkey 	 =>   itemkey,
--                            aname	 =>	  'AMS_MANAGER',
--                            avalue	 =>	  l_manager_role  );
--

-- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message('Manager : '||l_manager_role); END IF;
 -- dbms_output.put_line('Manager : '||l_manager_role);
 IF (AMS_DEBUG_HIGH_ON) THEN

 AMS_Utility_PVT.debug_message('requester : '||l_requester_role);
 END IF;
 -- dbms_output.put_line('requester : '||l_requester_role);

    WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype,
                            itemkey 	 =>  itemkey,
                            aname	 =>  'AMS_REQUESTER',
                            avalue	 =>  l_requester_role  );


    WF_ENGINE.SetItemAttrText(itemtype  =>   itemtype,
                            itemkey 	=>   itemkey,
                            aname 	=>   'MONITOR_URL',
                            avalue 	=>   wf_monitor.geturl
					   (wf_core.TRANSLATE('WF_WEB_AGENT'), itemtype, itemkey, 'NO')
			   );


   WF_ENGINE.SetItemOwner  (itemtype    => itemtype,
                            itemkey     => itemkey,
                            owner 	=> l_requester_role);


   WF_ENGINE.StartProcess (itemtype 	 => itemtype,
                            itemkey 	 => itemkey);


 EXCEPTION
     WHEN OTHERS
     THEN
        wf_core.context ('AMS_WfCmpApr_PVT', 'StartProcess',p_approval_for
           		  ,p_approval_for_id ,p_workflowprocess);
         RAISE;

END StartProcess;

-- Start of Comments
--
-- NAME
--   Selector
--
-- PURPOSE
--   This Procedure will determine which process to run
--
-- IN
-- itemtype     - A Valid item type from (WF_ITEM_TYPES Table).
-- itemkey      - A string generated from application object's primary key.
-- actid        - The function Activity
-- funcmode     - Run / Cancel
--
-- OUT
-- resultout    - Name of workflow process to run
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   08/13/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments


PROCEDURE Selector( itemtype    IN      VARCHAR2,
                    itemkey     IN      VARCHAR2,
                    actid       IN      NUMBER,
                    funcmode    IN      VARCHAR2,
                    resultout   OUT NOCOPY     VARCHAR2
                    )
  IS
   -- PL/SQL Block
  BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('In Selector Function');
   END IF;
   -- dbms_output.put_line('In Selector Function');
      --
      -- RUN mode - normal process execution
      --
      IF  (funcmode = 'RUN')
      THEN
         --
         -- Return process to run
         --
         resultout := 'AMS_APPROVAL';
         RETURN;
      END IF;
      --
      -- CANCEL mode - activity 'compensation'
      --
      IF  (funcmode = 'CANCEL')
      THEN
         --
         -- Return process to run
         --
         resultout := 'AMS_APPROVAL';
         RETURN;
      END IF;
      --
      -- TIMEOUT mode
      --
      IF  (funcmode = 'TIMEOUT')
      THEN
         resultout := 'AMS_APPROVAL';
         RETURN;
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.context ('AMS_WFCMPAPR_PVT', 'Selector', itemtype, itemkey, actid, funcmode);
         RAISE;
   END Selector;

-- Start of Comments
--
-- NAME
--   check_status_order_type
--
-- PURPOSE
--   This Function will return the Status status type for the objects.
--   i.e.  CAMP/DELV/EVEO/EVEH
--
--
-- IN
--    Object_type -- CAMP/DELV/EVEO/EVEH
--
-- OUT
-- 	  SYSTEM_STATUS_TYPE
--
-- NOTES
--
--
-- HISTORY
--   12/1/1999        ptendulk            Modified
-- End of Comments

FUNCTION Check_Status_Order_Type(p_approval_for_object IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    IF     p_approval_for_object = 'CAMP' THEN
        RETURN('AMS_CAMPAIGN_STATUS');
    ELSIF  p_approval_for_object = 'DELV' THEN
        RETURN('AMS_DELIV_STATUS');
    ELSIF  p_approval_for_object = 'EVEH' THEN
        RETURN('AMS_EVENT_STATUS');
    ELSIF  p_approval_for_object = 'EVEO' THEN
        RETURN('AMS_EVENT_STATUS');
    END IF;
END Check_Status_Order_Type;

-- Start of Comments
--
-- NAME
--   Get_Valid_status
--
-- PURPOSE
--   This Procedure will return the Valid System status for the objects.
--
--
-- IN
--    Object_type -- CAMP/DELV/EVEO/EVEH
--    Stat_Code   -- (Used in the Procedure)
--
-- OUT
-- 	  SYSTEM_STATUS_CODE (Defined in the Status_Order_Rules)
--
-- NOTES
-- If the Status Order Rule table changes, Change this Procedure only
--  No need to Change anywhere else. This Process uses internal codes
--  to find out what system status codes are used for it.
--  For e.g. 'SUBMIT_THEME_APPROVAL' for 'SUBMIT_TA'
-- HISTORY
--   12/1/1999        ptendulk            Modified
--    01/28/2000       ptendulk            Modified Lookups
-- End of Comments
PROCEDURE Get_Valid_status(p_object_type       IN  VARCHAR2,
                           p_stat_code      IN  VARCHAR2,
                           x_sys_stat_code  OUT NOCOPY VARCHAR2)
IS
BEGIN
    IF      p_object_type = 'DELV' THEN
        IF      p_stat_code = 'SUBMIT_TA' THEN
            x_sys_stat_code := 'SUBMITTED_TA' ;
        ELSIF   p_stat_code = 'SUBMIT_BA' THEN
            x_sys_stat_code := 'SUBMITTED_BA' ;
        ELSIF   p_stat_code = 'REJECT_TA' THEN
            x_sys_stat_code := 'DENIED_TA' ;
        ELSIF   p_stat_code = 'REJECT_BA' THEN
            x_sys_stat_code := 'DENIED_BA' ;
        END IF;
    ELSIF   (p_object_type = 'CAMP' OR
             p_object_type = 'EVEH' OR
             p_object_type = 'EVEO' )THEN
        IF      p_stat_code = 'SUBMIT_TA' THEN
            x_sys_stat_code := 'SUBMITTED_TA' ;
        ELSIF   p_stat_code = 'SUBMIT_BA' THEN
            x_sys_stat_code := 'SUBMITTED_BA' ;
        ELSIF   p_stat_code = 'REJECT_TA' THEN
            x_sys_stat_code := 'DENIED_TA' ;
        ELSIF   p_stat_code = 'REJECT_BA' THEN
            x_sys_stat_code := 'DENIED_BA' ;
        END IF;
    END IF;

END Get_Valid_status ;

-- Start of Comments
--
-- NAME
--   Update_Status
--
-- PURPOSE
--   This Procedure will Update the Statuses of the Activities
--
--
-- IN
--    Object_type -- CAMP/DELV/EVEO/EVEH
--    Object_id   -- Camp_id,..
--    Object Version Number
--    Next Status Code -- System Status Code
--    Next_Stat_id     -- User Status ID
--
-- OUT
-- 	  x_retuen_status  -- Success Flag
--
-- NOTES
-- If the next Status id (User Sta ID ) is passed then the Status of
-- the Activity is updated using this status ID but If not passed then
-- default status ID of the system status code passed will be used as
-- the Status of the Activity
--
-- HISTORY
--   12/1/1999        ptendulk     Modified
--   06/08/2000       ptendulk     Changed the Update Campaign Statement
-- End of Comments
PROCEDURE Update_Status(p_obj_type               IN   VARCHAR2,
                        p_obj_id                 IN   NUMBER,
                        p_object_version_number  IN   NUMBER,
                        p_next_stat_code         IN   VARCHAR2, --System Status
                        p_next_stat_id           IN   NUMBER DEFAULT NULL, --User Status
                        p_appr_type              IN   VARCHAR2 DEFAULT NULL,
                        p_submitted_by           IN   NUMBER ,
                        p_item_key               IN   VARCHAR2 ,
                        x_msg_count              OUT NOCOPY  NUMBER,
                        x_msg_data               OUT NOCOPY  VARCHAR2,
                        x_return_status    	 OUT NOCOPY  VARCHAR2)

IS

  l_api_name        CONSTANT VARCHAR2(30)  := 'Approval_Req_Check';
  l_next_stat_id 	NUMBER;
  l_api_version     CONSTANT NUMBER := 1.0;

  CURSOR c_next_user_status(l_stat_type IN VARCHAR2,
                            l_stat_code IN VARCHAR2)
  IS
      SELECT user_status_id
      FROM   ams_user_statuses_vl
      WHERE  system_status_code = l_stat_code
      AND    system_status_type = l_stat_type
      AND    default_flag = 'Y' ;

  l_camp_rec          AMS_Campaign_PVT.camp_rec_type;
  l_eveh_rec          AMS_EVENTHEADER_PVT.evh_rec_type ;
  l_eveo_rec          AMS_EVENTOFFER_PVT.evo_rec_type ;
  l_delv_rec          AMS_DELIVERABLE_PVT.deliv_rec_type;
  l_stat_type         VARCHAR2(30);

BEGIN
    --
    -- Initialize the Message List
    --
      FND_MSG_PUB.initialize;

    --
    -- Get the System status type
    --
    l_stat_type := Check_Status_Order_Type(p_obj_type)     ;

    --
    -- Get Next User Status Code
    --
    IF p_next_stat_id IS NULL THEN
        OPEN  c_next_user_status(l_stat_type,p_next_stat_code) ;
        FETCH c_next_user_status INTO l_next_stat_id ;
        CLOSE c_next_user_status ;
    ELSE
        l_next_stat_id := p_next_stat_id ;
    END IF;

    --
    -- Call the APIs to Update the Activities
    --
    IF    p_obj_type = 'CAMP' THEN

       Update ams_campaigns_all_b set user_status_id = l_next_stat_id,
              status_code = p_next_stat_code,
              status_date = sysdate
       where campaign_id = p_obj_id  ;
--       AND   object_version_number = p_object_version_number ;

    -- Update Campaign
--        AMS_Campaign_PVT.init_camp_rec(l_camp_rec);
--        l_camp_rec.campaign_id           := p_obj_id ;
--        l_camp_rec.status_code           := p_next_stat_code ;
--        l_camp_rec.status_date           := SYSDATE  ;
--        l_camp_rec.user_status_id        := l_next_stat_id  ;
--        l_camp_rec.object_version_number := p_object_version_number ;


-- dbms_output.put_line('Update Campaign Stat Code : '||p_next_stat_code||'Status ID : '||l_next_stat_id) ;
--        AMS_CAMPAIGN_PVT.Update_Campaign(
--               p_api_version       =>  l_api_version,
--               p_init_msg_list     =>  FND_API.g_false,
--               p_commit            =>  FND_API.g_false,
--               p_validation_level  =>  FND_API.g_valid_level_full,
--
--               x_return_status     =>  x_return_status,
--               x_msg_count         =>  x_msg_count,
--               x_msg_data          =>  x_msg_data,
--
--               p_camp_rec          =>  l_camp_rec
--                       ) ;

    ELSIF p_obj_type = 'DELV' THEN

    -- Update Deliverables
       Update ams_deliverables_all_b
          set user_status_id = l_next_stat_id,
              status_code = p_next_stat_code,
              status_date = sysdate
       where deliverable_id = p_obj_id ;
--       AND   object_version_number = p_object_version_number ;

--      AMS_Deliverable_PVT.init_deliv_rec(l_delv_rec);
--   -     l_delv_rec.deliverable_id        := p_obj_id ;
--        l_delv_rec.status_code           := p_next_stat_code ;
--        l_delv_rec.status_date           := SYSDATE  ;
--        l_delv_rec.user_status_id        := l_next_stat_id  ;
--        l_delv_rec.object_version_number := p_object_version_number ;
--
--        AMS_DELIVERABLE_PVT.Update_Deliverable(
--               p_api_version       =>  l_api_version,
--               p_init_msg_list     =>  FND_API.g_false,
--               p_commit            =>  FND_API.g_false,
--               p_validation_level  =>  FND_API.g_valid_level_full,
--
--               x_return_status     =>  x_return_status,
--               x_msg_count         =>  x_msg_count,
--               x_msg_data          =>  x_msg_data,
--
--               p_deliv_rec          =>  l_delv_rec
--                        ) ;
--
    ELSIF p_obj_type = 'EVEH' THEN
    -- Update Event Header
       Update ams_event_headers_all_b
          set user_status_id = l_next_stat_id,
              system_status_code = p_next_stat_code,
              last_status_date = sysdate
       where event_header_id = p_obj_id ;
--       AND   object_version_number = p_object_version_number ;

--        AMS_EVENTHEADER_PVT.init_evh_rec(l_eveh_rec);
--        l_eveh_rec.event_header_id       := p_obj_id ;
--        l_eveh_rec.system_status_code    := p_next_stat_code ;
--        l_eveh_rec.last_status_date      := SYSDATE  ;
--        l_eveh_rec.object_version_number := p_object_version_number ;
--        l_eveh_rec.user_status_id        := l_next_stat_id  ;
--
--        AMS_EVENTHEADER_PVT.Update_Event_Header(
--               p_api_version       =>  l_api_version,
--               p_init_msg_list     =>  FND_API.g_false,
--               p_commit            =>  FND_API.g_false,
--               p_validation_level  =>  FND_API.g_valid_level_full,
--
--               x_return_status     =>  x_return_status,
--               x_msg_count         =>  x_msg_count,
--               x_msg_data          =>  x_msg_data,
--
--               p_evh_rec           =>  l_eveh_rec
--                        ) ;
    ELSIF p_obj_type = 'EVEO' THEN
    -- Update Event Offers
       Update ams_event_offers_all_b
          set user_status_id = l_next_stat_id,
              system_status_code = p_next_stat_code,
              last_status_date = sysdate
       where event_offer_id = p_obj_id ;
--       AND   object_version_number = p_object_version_number ;


--        AMS_EVENTOFFER_PVT.init_evo_rec(l_eveo_rec);
--        l_eveo_rec.event_offer_id        := p_obj_id ;
--        l_eveo_rec.system_status_code    := p_next_stat_code ;
--        l_eveo_rec.last_status_date      := SYSDATE  ;
--        l_eveo_rec.object_version_number := p_object_version_number ;
--        l_eveo_rec.user_status_id        := l_next_stat_id  ;
--
--        AMS_EVENTOFFER_PVT.Update_Event_Offer(
--               p_api_version       =>  l_api_version,
--               p_init_msg_list     =>  FND_API.g_false,
--               p_commit            =>  FND_API.g_false,
--               p_validation_level  =>  FND_API.g_valid_level_full,
--
--               x_return_status     =>  x_return_status,
--               x_msg_count         =>  x_msg_count,
--               x_msg_data          =>  x_msg_data,
--
--               p_evo_rec           =>  l_eveo_rec
--                                 ) ;

    END IF;

    Create_WFreqest(p_init_msg_list    => FND_API.G_FALSE,
                    x_return_status    => x_return_status,
                    x_msg_count        => x_msg_count,
                    x_msg_data         => x_msg_data,
                    p_obj_id           => p_obj_id ,
                    p_object_type      => p_obj_type,
                    p_approval_type    => p_appr_type,
                    p_submitted_by     => p_submitted_by,
                    p_item_key	       => p_item_key,
                    P_stat_code	       => p_next_stat_code,
                    p_stat_id          => l_next_stat_id) ;

END Update_Status;



-- Start of Comments
--
-- NAME
--   Update_Attribute
--
-- PURPOSE
--   This Procedure will Update the Attributes of the Activities
--   upon Approvals
--
-- IN
--    Object_type -- CAMP/DELV/EVEO/EVEH
--    Object_id   -- Camp_id,..
--    Object Version Number
--    Next Status Code -- System Status Code
--    Next_Stat_id     -- User Status ID
--
-- OUT
-- 	  x_return_status  -- Success Flag
--
-- NOTES
-- If the next Status id (User Sta ID ) is passed then the Status of
-- the Activity is updated using this status ID but If not passed then
-- default status ID of the system status code passed will be used as
-- the Status of the Activity
--
-- HISTORY
--   12/1/1999        ptendulk            Modified
-- End of Comments
PROCEDURE Update_Attribute(p_obj_type      IN   VARCHAR2,
                           p_obj_id        IN   NUMBER,
                           p_obj_attr      IN   VARCHAR2,
                           x_msg_count     OUT NOCOPY  NUMBER,
                           x_msg_data      OUT NOCOPY  VARCHAR2,
                           x_return_status OUT NOCOPY  VARCHAR2)
IS


BEGIN
    -- This Process Has to be modified once the API for Update Attribute
    -- is available
--    UPDATE ams_object_attributes
--    SET    attribute_defined_flag = 'Y'
--    WHERE  object_type =  p_obj_type
--    AND    object_id   =  p_obj_id
--    AND    object_attribute = p_obj_attr ;

    AMS_ObjectAttribute_PVT.Modify_Object_Attribute
                          (p_api_version       => 1.0 ,
                           p_init_msg_list     => FND_API.g_false,
                           p_commit            => FND_API.g_false,
                           p_validation_level  => FND_API.g_valid_level_full,

                           x_return_status     => x_return_status,
                           x_msg_count         => x_msg_count,
                           x_msg_data          => x_msg_data,

                           p_object_type       => p_obj_type,
                           p_object_id         => p_obj_id,
                           p_attr              => p_obj_attr,
                           p_attr_defined_flag => 'Y' ) ;


END Update_Attribute;


-- Start of Comments
--
-- NAME
--   Create Note
--
-- PURPOSE
--   This Procedure will create the Approval Note in
--   Notes Table
--
--
-- HISTORY
--   01/29/2000        ptendulk            Modified
-- End of Comments
PROCEDURE Update_Note(p_obj_type      IN   VARCHAR2,
                      p_obj_id        IN   NUMBER,
                      p_note          IN   VARCHAR2,
                      p_user          IN   VARCHAR2,
                      x_msg_count     OUT NOCOPY  NUMBER,
                      x_msg_data      OUT NOCOPY  VARCHAR2,
                      x_return_status OUT NOCOPY  VARCHAR2)
IS
   l_id  NUMBER ;
   l_tab wf_directory.UserTable ;
   l_res_id  NUMBER ;

--  *************************8Need to Change
   CURSOR c_emp_id(l_usr VARCHAR2)  IS
   SELECT resource_id
   FROM   ams_jtf_rs_emp_v
   WHERE  resource_id = 100 ;

BEGIN
-- Note API to Update Approval Notes

  wf_directory.GetRoleUsers(p_user,l_tab);

  OPEN  c_emp_id(l_tab(1));
  FETCH c_emp_id INTO l_res_id ;
  CLOSE c_emp_id ;


 JTF_NOTES_PUB.Create_note
  ( p_api_version	 =>  1.0 ,

    x_return_status      =>  x_return_status,
    x_msg_count		 =>  x_msg_count,
    x_msg_data		 =>  x_msg_data,

    p_source_object_id   =>  p_obj_id,
    p_source_object_code =>  p_obj_type,
    p_notes              =>  p_note,
    p_note_status        =>  NULL ,
    p_entered_by         =>  l_res_id,
    p_entered_date       =>  sysdate,
    x_jtf_note_id        =>  l_id ,
    p_note_type          =>  'APPROVAL'    ,
    p_last_update_date   =>  SYSDATE  ,
    p_last_updated_by    =>  l_res_id   ,
    p_creation_date      =>  SYSDATE  ) ;




END Update_Note;


-- Start of Comments
--
-- NAME
--   Check_Approval_Required
--
-- PURPOSE
--   This Procedure will check which type of Approvals are required for the
--   Objects to change the status
--
-- IN
--   p_orig_stat
--   p_new_stat
--   p_stat_type
--
-- OUT
-- 	  SYSTEM_STATUS_TYPE
--
-- NOTES
--
--
-- HISTORY
--   12/1/1999        ptendulk            Modified
-- End of Comments
PROCEDURE Check_Approval_Required(
            p_orig_stat       IN    NUMBER,
            p_new_stat        IN    NUMBER,
            p_stat_type       IN    VARCHAR2,
            p_obj_type        IN    VARCHAR2,
            p_obj_id          IN    NUMBER,

            x_return_status   OUT NOCOPY    VARCHAR2,
            x_msg_data        OUT NOCOPY    VARCHAR2,
            x_appr_req_flag   OUT NOCOPY    VARCHAR2,
            x_appr_type       OUT NOCOPY    VARCHAR2  )
IS

  CURSOR c_sys_status(l_user_stat_id IN NUMBER)
  IS
  SELECT system_status_code
  FROM   ams_user_statuses_vl
  WHERE  user_status_id = l_user_stat_id ;

  CURSOR c_stat_rule(l_sys_stat_type    IN VARCHAR2,
                     l_curr_stat        IN VARCHAR2,
                     l_next_stat        IN VARCHAR2)
  IS
    SELECT  theme_approval_flag,
            budget_approval_flag
    FROM    ams_status_order_rules
    WHERE   system_status_type  = l_sys_stat_type
    AND     current_status_code = l_curr_stat
    AND     next_status_code    = l_next_stat   ;

  l_stat_rec    c_stat_rule%ROWTYPE;

  CURSOR c_attr_det
  IS
    SELECT  attribute_defined_flag,
            object_attribute
    FROM    ams_object_attributes
    WHERE   object_type = p_obj_type
    AND     object_id   = p_obj_id
    AND     (object_attribute = 'TAPL' OR
             object_attribute = 'BAPL')
    AND     attribute_defined_flag = 'N' ;

  CURSOR c_appr_rule(l_appr_type VARCHAR2)
  IS
    SELECT mgr_approval_needed_flag ,
           parent_owner_approval_flag
    FROM   ams_approval_rules
    WHERE  arc_approval_for_object = p_obj_type
    AND    approval_type = l_appr_type ;

  l_attr_rec    c_attr_det%ROWTYPE;

  l_cnt NUMBER := 0 ;
  l_ta_flag     VARCHAR2(1);
  l_ba_flag     VARCHAR2(1);

  l_orig_stat_code VARCHAR2(30);
  l_new_stat_code  VARCHAR2(30);

  l_own_appr_flag   VARCHAR2(1) ;
  l_mgr_appr_flag   VARCHAR2(1) ;
BEGIN
-- dbms_output.put_line('In/ Rec : Stat_type :'||p_stat_type||' Orig_stat: '||p_orig_stat||' New Stat: '||p_new_stat) ;
  --
  -- Initialize the API Return Status to Success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Take the System Statuses for the User Statuses
  --
  OPEN  c_sys_status(p_orig_stat) ;
  FETCH c_sys_status INTO l_orig_stat_code ;
  CLOSE c_sys_status ;

  OPEN  c_sys_status(p_new_stat) ;
  FETCH c_sys_status INTO l_new_stat_code ;
  CLOSE c_sys_status ;

  --
  -- Check in Status Order rule whether Any Approval is Required for the Status Change
  --
  OPEN  c_stat_rule(p_stat_type,l_orig_stat_code,l_new_stat_code);
  FETCH c_stat_rule INTO l_stat_rec;
  IF c_stat_rule%NOTFOUND THEN
		-- Invalid Statuses
        --dbms_output.put_line('trigger_name is missing');
        FND_MESSAGE.Set_Name('AMS', 'AMS_WF_NTF_INVALID_STAT_CODE');
    	x_msg_data := FND_MESSAGE.Get;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- If any errors happen abort API/Procedure.
		RETURN;
  END IF ;
  CLOSE c_stat_rule ;

  -- dbms_output.put_line('Flags in Approval Rules Theme :'||l_stat_rec.theme_approval_flag||' Budget: '|| l_stat_rec.budget_approval_flag);
  IF    l_stat_rec.theme_approval_flag = 'N'
  AND   l_stat_rec.budget_approval_flag = 'N' THEN
        x_appr_req_flag := 'N' ;
        RETURN;
  END IF;

  --
  -- Initialize the Flags
  --
  l_ta_flag := 'N';
  l_ba_flag := 'N';

  --
  -- Now Chack Which Approval are required
  --
  OPEN  c_attr_det;
  LOOP
      FETCH c_attr_det INTO l_attr_rec ;
      EXIT WHEN c_attr_det%NOTFOUND ;
      IF l_attr_rec.object_attribute = 'TAPL' THEN
            IF  l_attr_rec.attribute_defined_flag = 'N'
            AND l_stat_rec.theme_approval_flag = 'Y'
            THEN
                l_ta_flag := 'Y' ;
            END IF;
            l_cnt := l_cnt + 1 ;
      ELSIF l_attr_rec.object_attribute = 'BAPL' THEN
            IF  l_attr_rec.attribute_defined_flag = 'N'
            AND l_stat_rec.budget_approval_flag = 'Y'
            THEN
                l_ba_flag := 'Y' ;
            END IF;
            l_cnt := l_cnt + 1 ;
      END IF;
  END LOOP;
  CLOSE c_attr_det;

  IF    l_ba_flag = 'N' AND l_ta_flag = 'N'   THEN
        x_appr_req_flag := 'N' ;
  ELSIF l_ba_flag = 'Y' AND l_ta_flag = 'N'   THEN
        x_appr_type     := 'BUDGET' ;

        --Following Code is Added by PTENDULK on 28th Jan
        -- If the Flags in AMS_APPROVAL_RULES are N we
        -- Don't need Approvals
        OPEN  c_appr_rule(x_appr_type) ;
        FETCH c_appr_rule INTO l_mgr_appr_flag,l_own_appr_flag ;
        CLOSE c_appr_rule ;

        IF l_mgr_appr_flag = 'N' AND l_mgr_appr_flag = 'N' THEN
              x_appr_req_flag := 'N' ;
        ELSE
              x_appr_req_flag := 'Y' ;
        END IF ;
  ELSIF l_ba_flag = 'N' AND l_ta_flag = 'Y'   THEN
        x_appr_type     := 'THEME' ;
        --Following Code is Added by PTENDULK on 28th Jan
        -- If the Flags in AMS_APPROVAL_RULES are N we
        -- Don't need Approvals
        OPEN  c_appr_rule(x_appr_type) ;
        FETCH c_appr_rule INTO l_mgr_appr_flag,l_own_appr_flag ;
        CLOSE c_appr_rule ;

        IF l_mgr_appr_flag = 'N' AND l_mgr_appr_flag = 'N' THEN
              x_appr_req_flag := 'N' ;
        ELSE
              x_appr_req_flag := 'Y' ;
        END IF ;
  ELSIF l_ba_flag = 'Y' AND l_ta_flag = 'Y'   THEN
        x_appr_type     := 'BOTH' ;
        --Following Code is Added by PTENDULK on 28th Jan
        -- If the Flags in AMS_APPROVAL_RULES are N we
        -- Don't need Approvals
        OPEN  c_appr_rule(x_appr_type) ;
        FETCH c_appr_rule INTO l_mgr_appr_flag,l_own_appr_flag ;
        CLOSE c_appr_rule ;

        IF l_mgr_appr_flag = 'N' AND l_mgr_appr_flag = 'N' THEN
              x_appr_req_flag := 'N' ;
        ELSE
              x_appr_req_flag := 'Y' ;
        END IF ;
  END IF;

END Check_Approval_Required;

-- Start of Comments
--
-- NAME
--   set_activity_details
--
-- PURPOSE
--   This Procedure will set the workflow attributes for the details of the activity
--   These Attributes will be used throughout the process espacially in Notifications
--   It will also check if appropriate Approvers are availables for the approvals seeked
--
--
--   It will Return - Success if the process is successful
--	 	    - Error   If the process is errored out
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:AMS_SUCCESS' If the Process is successful
--	  	 - 'COMPLETE:AMS_ERROR'   If the Process is errored out
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_SET_ACT_DETAILS
--
-- NOTES
--  Various Combinations For Approvals (Requester/Owner/Manager/Fund Manager)
--  BOTH APPROVAL
--  1. All are Same ((Req. = Own = Manager = Fm)
--  2. (Req. = Own = Fm) AND Manager is Different
--  3. (Req. = Own ) AND (Manager = Fm)
--  4. (Req. = Own ) AND (Manager <> Fm)
--  5. (Req  = FM  ) AND (Man = Own)
--  6. (Req  = FM  ) AND (Man <> Own)
--  7. (Own = Man = Fm) AND Req. is Diff.
--  8. (Own = Man <> FM) AND Req. is Diff.
--  9. (Own = FM <> Man ) AND Req. is Diff.
--  10.(Man = FM ) AND req. and Own Diff
--  11.(Man<>FM<>Own<>Req)
--  BUDGET APPPROVAL
--  12.(Own = FM  = REQ )
--  13.(Req = Own <> FM )
--  14.(Req = FM <> Own)
--  15.(Own = FM <> Req)
--  16.(Own <> FM <> Req)
--  Theme Approvals
--  17.(Req = Own =  Man)
--  18.(Req = Own <> Man)
--  19.(Req <> Own = Man)
--  20.(Req <> Own <> Man)
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Set_Activity_Details(itemtype	IN  VARCHAR2,
                               itemkey 	IN  VARCHAR2,
                               actid    IN  NUMBER,
                               funcmode IN  VARCHAR2,
                               result   OUT NOCOPY VARCHAR2) IS

  l_approval_for_object    VARCHAR2(30);
  l_approval_for_objectid  NUMBER;
  l_appr_req_flag          VARCHAR2(1);
  l_requester              VARCHAR2(100);
  l_requester_id           NUMBER ;
  l_owner                  VARCHAR2(100);
  l_manager                VARCHAR2(100);
  l_fund_manager           VARCHAR2(100);
  l_stat_type              VARCHAR2(30);
  l_orig_stat_id           NUMBER;
  l_new_stat_id            NUMBER;
  l_appr_type              VARCHAR2(30);
  l_appr_flag              VARCHAR2(1) ;

  l_err_msg                VARCHAR2(2000);
  l_return_status          VARCHAR2(1);

  tmp          VARCHAR2(1);

  CURSOR c_appr_check(l_appr_type VARCHAR) IS
     SELECT mgr_approval_needed_flag ,
            parent_owner_approval_flag
     FROM   ams_approval_rules
     WHERE  arc_approval_for_object = l_approval_for_object
     AND    approval_type = l_appr_type ;

  l_own_appr_flag VARCHAR2(1);
  l_man_appr_flag VARCHAR2(1);


BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Process Set_Activity_Details');
   END IF;
   -- dbms_output.put_line('Process Set_Activity_Details');

	 --  RUN mode  - Normal Process Execution
IF (funcmode = 'RUN')
THEN
 	l_approval_for_object   := WF_ENGINE.GetItemAttrText(
							   itemtype    =>    itemtype,
						   	   itemkey	   => 	 itemkey ,
						   	   aname	   =>	 'AMS_APPROVAL_FOR_OBJECT');

 	l_approval_for_objectid := WF_ENGINE.GetItemAttrText(
							   itemtype    =>    itemtype,
						   	   itemkey	   => 	 itemkey ,
						   	   aname	   =>	 'AMS_ACT_ID');

 	l_orig_stat_id   := WF_ENGINE.GetItemAttrText(
							   itemtype    =>    itemtype,
						   	   itemkey	   => 	 itemkey ,
						   	   aname	   =>	 'AMS_ORIG_STAT_ID');

 	l_new_stat_id  := WF_ENGINE.GetItemAttrText(
							   itemtype    =>    itemtype,
						   	   itemkey	   => 	 itemkey ,
						   	   aname	   =>	 'AMS_NEW_STAT_ID');

    --
    -- call the Function to get the Status order type for each Activity
    --
    l_stat_type := Check_Status_Order_Type(l_approval_for_object);


    Check_Approval_Required(
            p_orig_stat       => l_orig_stat_id,
            p_new_stat        => l_new_stat_id,
            p_stat_type       => l_stat_type,
            p_obj_type        => l_approval_for_object,
            p_obj_id          => l_approval_for_objectid,

            x_return_status   => l_return_status,
            x_msg_data        => l_err_msg,
            x_appr_req_flag   => l_appr_req_flag  ,
            x_appr_type       => l_appr_type);

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('Approval Required : '||l_appr_type);

   END IF;
   -- dbms_output.put_line('Approval Required Ret Stat : '||l_return_status);
   -- dbms_output.put_line('Approval Type : '||l_appr_type);
   -- dbms_output.put_line('Approval Required : '||l_appr_req_flag);
    IF l_return_status <> FND_API.G_ret_sts_success  THEN
        -- Approval process is errored out
    	WF_ENGINE.SetItemAttrText(itemtype   =>	  itemtype ,
                                  itemkey    =>   itemkey,
                                  aname      =>	  'AMS_ERROR_MSG',
                                  avalue     =>	  l_err_msg);

        result := 'COMPLETE:ERROR' ;
    ELSE
        IF l_appr_req_flag = 'N' THEN
            -- No Need of approval
    	  WF_ENGINE.SetItemAttrText(itemtype =>	  itemtype ,
                                    itemkey  =>   itemkey,
                                    aname    =>	  'AMS_APPR_REQ_CHECK',
                                    avalue   =>	  'N'  );

            result := 'COMPLETE:SUCCESS' ;
        ELSE

          WF_ENGINE.SetItemAttrText(itemtype =>	  itemtype ,
                                    itemkey  =>   itemkey,
                                    aname    =>	  'AMS_APPR_TYPE_LOOKUP',
                                    avalue   =>	  l_appr_type  );

          WF_ENGINE.SetItemAttrText(itemtype =>	  itemtype ,
                                    itemkey  =>   itemkey,
                                    aname    =>	  'AMS_APPR_REQ_CHECK',
                                    avalue   =>	  'Y'  );


          l_requester  := WF_ENGINE.GetItemAttrText(
                                    itemtype =>  itemtype,
                                    itemkey  =>	 itemkey ,
                                    aname    =>	 'AMS_REQUESTER');

          l_requester_id  := WF_ENGINE.GetItemAttrText(
                                    itemtype =>  itemtype,
                                    itemkey  =>	 itemkey ,
                                    aname    =>	 'AMS_REQUESTER_ID');

          -- Find Manager
          Find_Manager
            (p_user_id            => l_requester_id,
             x_manager_role       => l_manager        );

          WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype,
                                    itemkey 	 =>  itemkey,
                                    aname	 =>  'AMS_MANAGER',
                                    avalue	 =>  l_manager  );
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message('Manager : '||l_Manager);
          END IF;

          --
          -- Find the Owner
          --
          Find_Owner
                (p_activity_id          =>  l_approval_for_objectid,
                 p_activity_type        =>  l_approval_for_object,
                 x_owner_role           =>  l_owner         ) ;

          IF (AMS_DEBUG_HIGH_ON) THEN



          AMS_Utility_PVT.debug_message('Owner : '||l_owner);

          END IF;
          -- dbms_output.put_line('Owner : '||l_owner);
          WF_ENGINE.SetItemAttrText(itemtype	 => itemtype ,
                                    itemkey 	 => itemkey,
                                    aname        => 'AMS_OWNER',
                                    avalue       => l_owner  );
          --
          -- Find the Fund Manager
          --
          Find_Fund_Manager
            ( p_activity_type     => l_approval_for_object,
              p_activity_id       => l_approval_for_objectid,
              x_manager_role    => l_fund_manager
            ) ;


          WF_ENGINE.SetItemAttrText(itemtype     =>  itemtype ,
                                    itemkey 	 =>  itemkey,
                                    aname	 =>  'AMS_BUD_MANAGER',
                                    avalue	 =>  l_fund_manager  );
          -- dbms_output.put_line('Fund Manager : '||l_owner);

          IF    l_appr_type = 'BOTH' THEN
          -- Check if all of the Approvers found
              IF    (l_manager IS NULL OR
                     l_owner   IS NULL OR
                     l_fund_manager IS NULL)
              THEN
                 IF l_manager IS NULL THEN
                     FND_MESSAGE.Set_Name('AMS', 'AMS_WF_APPR_NO_MANAGER');
	             FND_MESSAGE.Set_Token('OBJECT_TYPE',l_approval_for_object, FALSE);
                     l_err_msg := FND_MESSAGE.Get;
                 ELSIF l_owner   IS NULL THEN
                     FND_MESSAGE.Set_Name('AMS', 'AMS_WF_APPR_NO_OWNER');
           	     FND_MESSAGE.Set_Token('OBJECT_TYPE',l_approval_for_object, FALSE);
                     l_err_msg := FND_MESSAGE.Get;
                 ELSIF l_fund_manager IS NULL THEN
                     FND_MESSAGE.Set_Name('AMS', 'AMS_WF_APPR_NO_FUND_MANAGER');
           	     FND_MESSAGE.Set_Token('OBJECT_TYPE',l_approval_for_object, FALSE);
                     l_err_msg := FND_MESSAGE.Get;
                 END IF ;

                 WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
            	  			  itemkey  =>  itemkey,
            	   			  aname	   =>  'AMS_ERROR_MSG',
            	   			  avalue   =>  l_err_msg);

                 result := 'COMPLETE:ERROR' ;
              ELSE

                -- Now Check Which Aprovals are required .
                -- Check the Flags in AMS_APPROVAL_RULES
                -- Whether all Approvals are required.
                OPEN  c_appr_check('BOTH') ;
                FETCH c_appr_check INTO l_man_appr_flag,l_own_appr_flag ;
                CLOSE c_appr_check ;

                IF  l_man_appr_flag = 'N' THEN
                   l_manager := l_owner ;
                ELSIF l_own_appr_flag = 'N' THEN
                   l_owner := l_manager ;
                END IF;

                -- Check if all the Approvers are same (Condi: 1)
                IF l_requester = l_manager AND
                    l_requester = l_owner   AND
                    l_requester = l_fund_manager
                THEN
       	            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                              itemkey  =>  itemkey,
                                              aname    =>  'AMS_APPR_REQ_CHECK',
                                              avalue   =>  'N'  );

                    result := 'COMPLETE:SUCCESS' ;
                ELSE
                    WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                              itemkey  =>  itemkey,
                                              aname    =>  'AMS_APPR_USERNAME',
                                              avalue   =>  l_manager);

                    IF l_requester = l_owner OR
                       l_requester = l_fund_manager
                    THEN
                       --(Condi: 2)
                       IF (l_requester = l_owner AND
                            l_requester = l_fund_manager)
                       THEN --(req = Own = Fun_Man) <> Man
                            -- Theme Approval Require Budget Approval Not Require
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                                                      itemkey 	 =>  itemkey,
                                                      aname 	 =>  'AMS_BUDGET_APPR_FLAG',
                                                      avalue	 =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                                                      itemkey 	 =>  itemkey,
                                                      aname	 =>  'AMS_TAOWNER_APPR_FLAG',
                                                      avalue	 =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                                                      itemkey 	 =>  itemkey,
                                                      aname	 =>  'AMS_BAOWNER_APPR_FLAG',
                                                      avalue	 =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                                                      itemkey 	 =>  itemkey,
                                                      aname 	 =>  'AMS_THEME_APPR_FLAG',
                                                      avalue	 =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                                                      itemkey 	 =>  itemkey,
                                                      aname 	 =>  'AMS_APPR_DOC_TYPE',
                                                      avalue	 =>  'BOTH');

                       ELSIF (l_requester = l_owner AND
                              l_requester <> l_fund_manager)
                       THEN --(req = Own <> Fun_Man) <> Man
                          IF l_fund_manager = l_manager THEN    --(Condi: 3)
                            -- Theme Approval Require Budget Approval Not Require
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BUDGET_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_TAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_THEME_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_APPR_DOC_TYPE',
                                                      avalue   =>  'BOTH');
                          ELSE --(Condi: 4)
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BUDGET_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_TAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_THEME_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_APPR_DOC_TYPE',
                                                      avalue   =>  'BOTH');-- Changed on
                            -- 29Jan from THEME by PTENDULK as Manager will receive Notification for Both Approvals
                          END IF;
                       ELSE
                          --(l_requester <> l_owner AND l_requester = l_fund_manager)
                          IF l_owner = l_manager THEN   --(Condi: 5)
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BUDGET_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_TAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_THEME_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_APPR_DOC_TYPE',
                                                      avalue   =>  'BOTH');-- Changed on
                            -- 29Jan from THEME by PTENDULK as Manager will receive Notification for Both Approvals
                          ELSE   --(Condi: 6)
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BUDGET_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_TAOWNER_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_THEME_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_APPR_DOC_TYPE',
                                                      avalue   =>  'BOTH');  -- Changed on
                            -- 29Jan from THEME by PTENDULK as Manager will receive Notification for Both Approvals
                          END IF;

                       END IF;
                    ELSE  -- (Req in not any of the Approvers)
                       IF (l_owner = l_manager OR
                           l_owner = l_fund_manager)
                       THEN
                          IF (l_owner = l_manager AND
                            l_manager = l_fund_manager)
                          THEN                   --(Condi: 7)
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BUDGET_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_TAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_THEME_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_APPR_DOC_TYPE',
                                                      avalue   =>  'BOTH');

                          ELSIF (l_owner = l_manager  AND
                                 l_owner <> l_fund_manager)
                          THEN   --(Condi: 8)
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BUDGET_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_TAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_THEME_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_APPR_DOC_TYPE',
                                                      avalue   =>  'BOTH');

                          ELSE      --(Condi: 9)
--                          (l_owner <>  l_manager AND l_owner = l_fund_manager)
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BUDGET_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_TAOWNER_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_THEME_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_APPR_DOC_TYPE',
                                                      avalue   =>  'BOTH');
                          END IF;
                       ELSE
                          IF l_manager = l_fund_manager
                          THEN  --(Condi: 10)
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BUDGET_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_TAOWNER_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_THEME_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_APPR_DOC_TYPE',
                                                      avalue   =>  'BOTH');
                          ELSE -- (requester<> owner<> manager<> fund_manager) (Condi 11)
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BUDGET_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_TAOWNER_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_BAOWNER_APPR_FLAG',
                                                      avalue   =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_THEME_APPR_FLAG',
                                                      avalue   =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'AMS_APPR_DOC_TYPE',
                                                      avalue   =>  'BOTH');
                          END IF ;
                       END IF;
                    END IF;
                    result := 'COMPLETE:SUCCESS' ;
                END IF;
              END IF ;


          ELSIF l_appr_type = 'BUDGET' THEN
              -- dbms_output.put_line('In Budget Fund Man : '||l_fund_manager);
              -- dbms_output.put_line('In Budget Owner : '||l_owner);

              -- In Funds Approval Approval is required of Manager and
              --  Fund Manager so Replace Owner with Manager
              l_owner := l_manager ;

              -- Check if all of the Approvers found
              IF    (l_fund_manager IS NULL OR
                     l_owner        IS NULL     )
              THEN
                IF l_fund_manager IS NULL THEN
                    FND_MESSAGE.Set_Name('AMS', 'AMS_WF_APPR_NO_FUND_MANAGER');
          	    FND_MESSAGE.Set_Token('OBJECT_TYPE',l_approval_for_object, FALSE);
                ELSE
                    FND_MESSAGE.Set_Name('AMS', 'AMS_WF_APPR_NO_OWNER');
          	    FND_MESSAGE.Set_Token('OBJECT_TYPE',l_approval_for_object, FALSE);
                END IF;
                l_err_msg := FND_MESSAGE.Get;

                WF_ENGINE.SetItemAttrText(itemtype  => itemtype ,
                                          itemkey   => itemkey,
                                          aname     => 'AMS_ERROR_MSG',
                                          avalue    => l_err_msg);

                result := 'COMPLETE:ERROR' ;
              ELSE
                 -- Check if all the Approvers are same
                 IF l_requester  = l_owner   AND
                     l_requester = l_fund_manager
                 THEN       -- Condi : 12
                     WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                                               itemkey 	 =>  itemkey,
                                               aname	 =>  'AMS_APPR_REQ_CHECK',
                                               avalue	 =>  'N'  );
                     -- dbms_output.put_line('All Appr Same : '||l_fund_manager);

                     result := 'COMPLETE:SUCCESS' ;
                 ELSE
                     -- Now Check Which Aprovals are required .
                     -- Check the Flags in AMS_APPROVAL_RULES
                     -- Whether all Approvals are required.
                     OPEN  c_appr_check('BUDGET') ;
                     FETCH c_appr_check INTO l_man_appr_flag,l_own_appr_flag ;
                     CLOSE c_appr_check ;

                     IF  l_man_appr_flag = 'N' THEN
                         l_fund_manager := l_owner ;
                     ELSIF l_own_appr_flag = 'N' THEN
                         l_owner := l_fund_manager ;
                     END IF;

                     IF (l_requester = l_owner ) AND (l_requester <> l_fund_manager )
                     THEN   --  Condi : 13
                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_APPR_USERNAME',
                                                  avalue   =>  l_fund_manager);

                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_BUDGET_APPR_FLAG',
                                                  avalue   =>  'Y');
                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_TAOWNER_APPR_FLAG',
                                                  avalue   =>  'N');
                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_BAOWNER_APPR_FLAG',
                                                  avalue   =>  'N');
                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_THEME_APPR_FLAG',
                                                  avalue   =>  'N');
                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_APPR_DOC_TYPE',
                                                  avalue   =>  'BUDGET');
                     ELSIF (l_requester = l_fund_manager) AND (l_requester <> l_owner )
                     THEN  -- Condi : 14
                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_APPR_USERNAME',
                                                  avalue   =>  l_owner);

                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_BUDGET_APPR_FLAG',
                                                  avalue   =>  'Y');
                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_TAOWNER_APPR_FLAG',
                                                  avalue   =>  'N');
-- Here Budget Approval is not required from Owner as it is already taken (Requester = Fund Manager)
                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_BAOWNER_APPR_FLAG',
                                                  avalue   =>  'N');
                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_THEME_APPR_FLAG',
                                                  avalue   =>  'N');
                        WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                  itemkey  =>  itemkey,
                                                  aname	   =>  'AMS_APPR_DOC_TYPE',
                                                  avalue   =>  'BUDGET');
                     ELSE
             -- dbms_output.put_line('All Appr No Same : '||l_fund_manager);
                        --(l_requester <> l_fund_manager) AND (l_requester <> l_owner)
                        IF l_owner = l_fund_manager THEN  -- Condi : 15
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname 	 =>  'AMS_APPR_USERNAME',
                    	   			      avalue	 =>  l_owner);

                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname	 =>  'AMS_BUDGET_APPR_FLAG',
                    	   			      avalue	 =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname 	 =>  'AMS_TAOWNER_APPR_FLAG',
                    	   			      avalue	 =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname  	 =>  'AMS_BAOWNER_APPR_FLAG',
                    	   			      avalue	 =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname 	 =>  'AMS_THEME_APPR_FLAG',
                    	   			      avalue	 =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname	 =>  'AMS_APPR_DOC_TYPE',
                    	   			      avalue	 =>  'BUDGET');
                          ELSE  -- Condi : 16
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname 	 =>  'AMS_APPR_USERNAME',
                    	   			      avalue	 =>  l_fund_manager);

                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname 	 =>  'AMS_BUDGET_APPR_FLAG',
                    	   			      avalue	 =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname 	 =>  'AMS_TAOWNER_APPR_FLAG',
                    	   			      avalue	 =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname 	 =>  'AMS_BAOWNER_APPR_FLAG',
                    	   			      avalue	 =>  'Y');
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname 	 =>  'AMS_THEME_APPR_FLAG',
                    	   			      avalue	 =>  'N');
                            WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                    	   			      itemkey 	 =>  itemkey,
                    	   			      aname 	 =>  'AMS_APPR_DOC_TYPE',
                    	   			      avalue	 =>  'BUDGET');
                          END IF;
                     END IF;
                     result := 'COMPLETE:SUCCESS' ;
                 END IF;
              END IF;

          ELSIF l_appr_type = 'THEME' THEN
              -- Check if all of the Approvers found
              IF    (l_manager IS NULL OR
                     l_owner    IS NULL     )
              THEN
                 IF l_manager IS NULL THEN
                   FND_MESSAGE.Set_Name('AMS', 'AMS_WF_APPR_NO_MANAGER');
          	   FND_MESSAGE.Set_Token('OBJECT_TYPE',l_approval_for_object, FALSE);
                 ELSE
                   FND_MESSAGE.Set_Name('AMS', 'AMS_WF_APPR_NO_OWNER');
          	   FND_MESSAGE.Set_Token('OBJECT_TYPE',l_approval_for_object, FALSE);
                 END IF;
                   l_err_msg := FND_MESSAGE.Get;

                 WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype ,
            	   			  itemkey    =>  itemkey,
            	   			  aname	     =>  'AMS_ERROR_MSG',
            	   			  avalue     =>  l_err_msg);

                    result := 'COMPLETE:ERROR' ;
              ELSE
                -- Now Check Which Aprovals are required .
                -- Check the Flags in AMS_APPROVAL_RULES
                -- Whether all Approvals are required.
                OPEN  c_appr_check('THEME') ;
                FETCH c_appr_check INTO l_man_appr_flag,l_own_appr_flag ;
                CLOSE c_appr_check ;

                IF  l_man_appr_flag = 'N' THEN
                   l_manager := l_owner ;
                ELSIF l_own_appr_flag = 'N' THEN
                   l_owner := l_manager ;
                END IF;

                -- Check if all the Approvers are same
                IF l_requester = l_owner   AND
                   l_requester = l_manager
                THEN    -- Condi : 17
                   WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                                             itemkey 	 =>  itemkey,
                                             aname       =>  'AMS_APPR_REQ_CHECK',
                                             avalue	 =>  'N'  );

                   result := 'COMPLETE:SUCCESS' ;

                   -- dbms_output.put_line('Theme All Approvals same');
                ELSE
                   IF (l_requester = l_owner )
                   THEN  -- Condi : 18
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_APPR_USERNAME',
                                                 avalue	  =>  l_manager);

                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_BUDGET_APPR_FLAG',
                                                 avalue	  =>  'N');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_TAOWNER_APPR_FLAG',
                                                 avalue	  =>  'N');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_BAOWNER_APPR_FLAG',
                                                 avalue	  =>  'N');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_THEME_APPR_FLAG',
                                                 avalue	  =>  'Y');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_APPR_DOC_TYPE',
                                                 avalue	  =>  'THEME');
                   ELSE                     --(l_requester <> l_owner)
                     IF l_owner = l_fund_manager THEN  -- Condi : 19
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_APPR_USERNAME',
                                                 avalue	  =>  l_owner);

                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_BUDGET_APPR_FLAG',
                                                 avalue	  =>  'N');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_TAOWNER_APPR_FLAG',
                                                 avalue	  =>  'N');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_BAOWNER_APPR_FLAG',
                                                 avalue	  =>  'N');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_THEME_APPR_FLAG',
                                                 avalue	  =>  'Y');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_APPR_DOC_TYPE',
                                                 avalue	  =>  'THEME');
                     ELSE  -- (Condi 20)
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_APPR_USERNAME',
                                                 avalue	  =>  l_manager);

                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_BUDGET_APPR_FLAG',
                                                 avalue	  =>  'N');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_TAOWNER_APPR_FLAG',
                                                 avalue	  =>  'Y');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_BAOWNER_APPR_FLAG',
                                                 avalue	  =>  'N');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_THEME_APPR_FLAG',
                                                 avalue	  =>  'Y');
                       WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                                                 itemkey  =>  itemkey,
                                                 aname	  =>  'AMS_APPR_DOC_TYPE',
                                                 avalue	  =>  'THEME');
                     END IF;
                   END IF;
                   result := 'COMPLETE:SUCCESS' ;
                END IF;
              END IF;

          END IF;  -- For ELSIF l_appr_type = 'THEME' THEN
        END IF;
    END IF;

--       IF (AMS_DEBUG_HIGH_ON) THEN              AMS_Utility_PVT.debug_message('Process Set_Activity_Details End : '||result);       END IF;
       -- dbms_output.put_line('Process Set_Activity_Details End : '||result);
END IF;

--  CANCEL mode  - Normal Process Execution
IF (funcmode = 'CANCEL')
THEN
 	result := 'COMPLETE:' ;
	RETURN;
END IF;

--  TIMEOUT mode  - Normal Process Execution
IF (funcmode = 'TIMEOUT')
THEN
 	result := 'COMPLETE:' ;
	RETURN;
END IF;

EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context('AMS_WFCMPAPR_PVT','Set_Activity_Details',itemtype,itemkey,actid,funcmode);
		  raise ;
END Set_Activity_Details ;

-- Start of Comments
--
-- NAME
--   Appr_Required_Check
--
-- PURPOSE
--   This Procedure will check whether the Approval is required or not
--
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the approval is required
--	  		 - 'COMPLETE:N' If the approval is not required
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_CHECK_APPR
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Appr_Required_Check 	(itemtype  IN  VARCHAR2,
		 		itemkey	   IN  VARCHAR2,
		 		actid	   IN  NUMBER,
		 		funcmode   IN  VARCHAR2,
		 		result     OUT NOCOPY VARCHAR2) IS
l_appr_flag  VARCHAR2(1);
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Process Appr_Required_Check');
   END IF;
   -- dbms_output.put_line('Process Appr_Required_Check');
	 --  RUN mode  - Normal Process Execution
	 IF (funcmode = 'RUN')
	 THEN
            l_appr_flag := WF_ENGINE.GetItemAttrText(
	   			   itemtype  =>  itemtype,
			   	   itemkey   =>	 itemkey ,
			   	   aname     =>	 'AMS_APPR_REQ_CHECK');
            IF l_appr_flag = 'Y' THEN
                result := 'COMPLETE:Y' ;
            ELSE
                result := 'COMPLETE:N' ;
            END IF;

	 END IF;

	 --  CANCEL mode  - Normal Process Execution
	 IF (funcmode = 'CANCEL')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;

	 --  TIMEOUT mode  - Normal Process Execution
	 IF (funcmode = 'TIMEOUT')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;
-- dbms_output.put_line('appr_req_check end: '||result);
EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context(G_PKG_NAME,'Appr_Required_Check',itemtype,itemkey,actid,funcmode);
		  raise ;
END Appr_Required_Check ;


-- Start of Comments
--
-- NAME
--   Update_Status_Na
--
-- PURPOSE
--   This Procedure will Update the Status of the Activity as the
--   Approval is not required
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_UPDATE_STATUS_NA
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE UPDATE_STATUS_NA (itemtype IN	  VARCHAR2,
		     	itemkey	     IN	  VARCHAR2,
			actid	     IN	  NUMBER,
			funcmode     IN	  VARCHAR2,
			result       OUT NOCOPY  VARCHAR2) IS

  l_obj_type              VARCHAR2(30);
  l_next_stat_id          NUMBER ;

  l_msg_count             NUMBER ;
  l_msg_data              VARCHAR2(2000);
  l_obj_id                NUMBER ;
  l_obj_version_number    NUMBER ;
  l_requester_id          NUMBER ;
  l_sys_stat_code         VARCHAR2(30);
  l_return_status         VARCHAR2(1);

  CURSOR c_sys_stat(l_user_stat_id NUMBER) IS
  SELECT    system_status_code
  FROM      ams_user_statuses_vl
  WHERE     user_status_id = l_user_stat_id ;

BEGIN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_Utility_PVT.debug_message('Process Approval_Type');
     END IF;
     -- dbms_output.put_line('Process Approval_Type');
	 --  RUN mode  - Normal Process Execution
	 IF (funcmode = 'RUN')
	 THEN

            l_obj_type    := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPROVAL_FOR_OBJECT');

            l_obj_id      := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_ACT_ID');
            l_obj_version_number := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_OBJECT_VERSION_NUMBER');
            l_next_stat_id := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_NEW_STAT_ID');

            l_requester_id := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_REQUESTER_ID');

            OPEN  c_sys_stat(l_next_stat_id) ;
            FETCH c_sys_stat INTO l_sys_stat_code ;
            CLOSE c_sys_stat ;

            --
            -- Update Activity
            --
            Update_Status(p_obj_type          	 => l_obj_type,
                     	p_obj_id     		 => l_obj_id,
                        p_object_version_number  => l_obj_version_number,
  			p_next_stat_code   	 => l_sys_stat_code, --System Status
                        p_next_stat_id           => l_next_stat_id,
                        p_submitted_by           => l_requester_id,
                        p_item_key		 => itemkey,
                        x_msg_count              => l_msg_count,
                        x_msg_data               => l_msg_data,
		        x_return_status	   	 => l_return_status )  ;

       		IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
   		   	   	    result := 'COMPLETE:SUCCESS' ;
   			ELSE
                    Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_ERROR_MSG'
                            )               ;
   				  result := 'COMPLETE:ERROR' ;
   		    END IF ;
   	 END IF ;

    --  CANCEL mode  - Normal Process Execution
	 IF (funcmode = 'CANCEL')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;

	 --  TIMEOUT mode  - Normal Process Execution
	 IF (funcmode = 'TIMEOUT')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;
EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context(G_PKG_NAME,'Update_Status_NA',itemtype,itemkey,actid,funcmode);
		  raise ;
END Update_Status_NA ;

-- Start of Comments
--
-- NAME
--   Theme_Appr_Req_Check
--
-- PURPOSE
--   This Procedure will check whether the Theme Approval is required or not
--
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the approval is required
--	  		 - 'COMPLETE:N' If the approval is not required
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_CHECK_MAN_APPR
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Theme_Appr_Req_Check 	(itemtype    IN	  VARCHAR2,
  				 		itemkey	 	 IN	  VARCHAR2,
				 		actid	     IN	  NUMBER,
				 		funcmode	 IN	  VARCHAR2,
				 		result       OUT NOCOPY  VARCHAR2) IS
l_theme_appr_flag  VARCHAR2(1);
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Process Fund_Appr_Req_Check');
   END IF;
   -- dbms_output.put_line('Process Fund_Appr_Req_Check');
	 --  RUN mode  - Normal Process Execution
	 IF (funcmode = 'RUN')
	 THEN
	 	 	l_theme_appr_flag := WF_ENGINE.GetItemAttrText(
					   			   itemtype    =>    itemtype,
							   	   itemkey	   => 	 itemkey ,
							   	   aname	   =>	 'AMS_THEME_APPR_FLAG');
            IF l_theme_appr_flag = 'Y' THEN
                result := 'COMPLETE:Y' ;
            ELSE
                result := 'COMPLETE:N' ;
            END IF;

	 END IF;

	 --  CANCEL mode  - Normal Process Execution
	 IF (funcmode = 'CANCEL')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;

	 --  TIMEOUT mode  - Normal Process Execution
	 IF (funcmode = 'TIMEOUT')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;
-- dbms_output.put_line('End Theme Appr Req Check');
EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context(G_PKG_NAME,'Theme_Appr_Req_Check',itemtype,itemkey,actid,funcmode);
		  raise ;
END Theme_Appr_Req_Check ;

-- Start of Comments
--
-- NAME
--   Find_Priority
--
-- PURPOSE
--   This Procedure Calculates Priority and Timeout Days for the given activity and the given
--   approval type
--
-- CALLED BY
--   Prepare_Doc
--
-- NOTES
--
--
-- HISTORY
--   09/14/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments


PROCEDURE Find_Priority(p_obj_type      IN  VARCHAR2,
                        p_obj_id        IN  NUMBER,
                        p_approval_type IN  VARCHAR2,
                        x_timeout_days  OUT NOCOPY NUMBER,
                        x_priority      OUT NOCOPY NUMBER)
IS
CURSOR c_timeout is
  SELECT  timeout_days_low_prio,
  		  timeout_days_std_prio,
		  timeout_days_high_prio,
  		  timeout_days_medium_prio
  FROM	  ams_approval_rules
  WHERE   arc_approval_for_object  = p_obj_type
  AND	  DECODE(approval_type,'BOTH','BUDGET',approval_type)  = p_approval_type ;
  -- If the Approval type is Both then Use Priority and Timeout of Budget

CURSOR c_camp_priority
IS
  SELECT  priority
  FROM    ams_campaigns_vl
  WHERE   campaign_id = p_obj_id ;

CURSOR c_eveh_priority
IS
  SELECT  priority_type_code  priority
  FROM    ams_event_headers_vl
  WHERE   event_header_id = p_obj_id ;

CURSOR c_eveo_priority
IS
  SELECT  priority_type_code  priority
  FROM    ams_event_headers_vl
  WHERE   event_header_id = p_obj_id ;

l_priority      VARCHAR2(30);
l_timeout_rec   c_timeout%ROWTYPE;
l_timeout       NUMBER ;
l_prio          NUMBER ;
BEGIN
    IF    p_obj_type = 'CAMP' THEN
        OPEN  c_camp_priority ;
        FETCH c_camp_priority INTO l_priority ;
        CLOSE c_camp_priority ;
    ELSIF p_obj_type = 'DELV' THEN
        l_priority := 'STANDARD' ;
    ELSIF p_obj_type = 'EVEH' THEN
        OPEN  c_eveh_priority ;
        FETCH c_eveh_priority INTO l_priority ;
        CLOSE c_eveh_priority ;
    ELSIF p_obj_type = 'EVEO' THEN
        OPEN  c_eveo_priority ;
        FETCH c_eveo_priority INTO l_priority ;
        CLOSE c_eveo_priority ;
    END IF;

    OPEN  c_timeout ;
    FETCH c_timeout INTO l_timeout_rec ;
    CLOSE c_timeout ;

    IF    l_priority = 'HIGH' THEN
        l_timeout := l_timeout_rec.timeout_days_high_prio ;
        l_prio := 1 ;
    ELSIF l_priority = 'LOW' THEN
        l_timeout := l_timeout_rec.timeout_days_low_prio ;
        l_prio := 99 ;
    ELSIF l_priority = 'MEDIUM' THEN
        l_timeout := l_timeout_rec.timeout_days_medium_prio ;
        l_prio := 50 ;
    ELSIF l_priority = 'STANDARD' THEN
        l_timeout := l_timeout_rec.timeout_days_std_prio ;
        l_prio := 50 ;
    ELSE
        l_timeout := l_timeout_rec.timeout_days_std_prio ;
        l_prio := 50 ;
    END IF;


    x_timeout_days := l_timeout ;
--    x_priority     := NVL(l_priority,'STANDARD') ;
    x_priority     := l_prio ;

END Find_Priority ;


--
-- Create_Notif_Document
--   Generate the Theme/Budget Document for display in messages (Notifications
--   for the Activity Approvals)
-- IN
--   document_id	- Item Key
--   display_type	- either 'text/plain' or 'text/html'
--   document		- document buffer
--   document_type	- type of document buffer created, either 'text/plain'
--			  or 'text/html'
-- OUT
-- USED BY
--
procedure Create_Notif_Document(document_id	in	varchar2,
				display_type	in	varchar2,
				document	in OUT NOCOPY varchar2,
				document_type	in OUT NOCOPY varchar2)
is
itemtype			VARCHAR2(30);
itemkey				VARCHAR2(30);

l_approval_for		VARCHAR2(30);
l_approval_for_id   NUMBER;
l_approval_type     VARCHAR2(80);

l_message			VARCHAR2(4000);

l_requester			VARCHAR2(30);
l_requester_note	VARCHAR2(2000);
l_start_dt          DATE;
l_end_dt            DATE;
l_desc              VARCHAR2(4000);
l_budget_amount  	NUMBER ;
l_currency_code     VARCHAR2(30);
l_currency          VARCHAR2(80);
l_doc_type          VARCHAR2(30);

l_tmp_str			VARCHAR2(2000);


l_activity_name		VARCHAR2(240);
l_camp_theme 		VARCHAR2(4000);
l_camp_obj		 	VARCHAR2(4000);
l_camp_mkt		 	VARCHAR2(4000);
l_camp_geo		 	VARCHAR2(4000);





l_deli_language 	VARCHAR2(30);
l_deli_mkt_msg  	VARCHAR2(4000);


l_eve_mkt_msg		VARCHAR2(4000);

l_owner                 VARCHAR2(240) ;

--Hbandi added for re-solving the BUG #7538786
l_camp_start_date_txt   VARCHAR2(4000);
l_camp_end_date_txt     VARCHAR2(4000);
--End of hbandi code

-- Following cursors to get the owners is added by ptendulk
-- on 08-Jun-2000
  CURSOR c_camp_owner(l_id NUMBER)
  IS
  SELECT jtf.full_name
  FROM   ams_jtf_rs_emp_v jtf,ams_campaigns_vl camp
  WHERE  camp.campaign_id = l_id
  AND    jtf.resource_id = camp.owner_user_id  ;

  CURSOR c_eveh_owner(l_id NUMBER)
  IS
  SELECT jtf.full_name
  FROM   ams_jtf_rs_emp_v jtf,ams_event_headers_vl eveh
  WHERE  eveh.event_header_id = l_id
  AND    jtf.resource_id = eveh.owner_user_id  ;

  CURSOR c_eveo_owner(l_id NUMBER)
  IS
  SELECT jtf.full_name
  FROM   ams_jtf_rs_emp_v jtf,ams_event_offers_vl eveo
  WHERE  eveo.event_offer_id = l_id
  AND    jtf.resource_id = eveo.owner_user_id  ;


begin
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Create Documents');
   END IF;

--   dbms_output.put_line('Create Documents');
  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo
  ItemType := nvl(substr(document_id, 1, instr(document_id,':')-1),'AMSAPPR');
  ItemKey  := substr(document_id
		, instr(document_id,':')+1);

  l_approval_for  := wf_engine.GetItemAttrText(
				itemtype => ItemType,
				itemkey  => ItemKey,
				aname    => 'AMS_APPROVAL_FOR_OBJECT');

  l_approval_for_id  := wf_engine.GetItemAttrText(
				itemtype => ItemType,
				itemkey  => ItemKey,
				aname    => 'AMS_ACT_ID');

  l_requester := wf_engine.GetItemAttrText(
				itemtype => ItemType,
				itemkey  => ItemKey,
				aname    => 'AMS_REQUESTER');

  l_requester_note := wf_engine.GetItemAttrText(
				itemtype => ItemType,
				itemkey  => ItemKey,
				aname    => 'AMS_NOTES_FROM_REQUESTER');

  -- dbms_output.Put_line('Requester Note : '||l_requester_note );
  l_doc_type    := wf_engine.GetItemAttrText(
				itemtype => ItemType,
				itemkey  => ItemKey,
				aname    => 'AMS_APPR_DOC_TYPE');

  l_approval_type :=  wf_engine.GetItemAttrText(
                itemtype => ItemType,
				itemkey  => ItemKey,
				aname    => 'AMS_APPROVAL_TYPE');

  l_activity_name := WF_ENGINE.GetItemAttrText
                (itemtype	 =>	  itemtype ,
	 			itemkey 	 =>   itemkey,
				aname	 	 =>	  'AMS_ACT_NAME'  );

  l_start_dt := WF_ENGINE.GetItemAttrText
                (itemtype   =>   itemtype,
				itemkey	    =>   itemkey ,
				aname	   	=>	  'AMS_ACT_START_DATE');

  l_end_dt :=  WF_ENGINE.GetItemAttrText
   		        (itemtype   =>   itemtype,
				itemkey	    =>   itemkey ,
				aname	   	=>	  'AMS_ACT_END_DATE' );

  l_budget_amount := WF_ENGINE.GetItemAttrText
			    (itemtype	=>	  itemtype ,
	 			itemkey 	=>   itemkey,
				aname	 	=>	  'AMS_BUDGET_AMOUNT');
  l_desc := WF_ENGINE.GetItemAttrText
	   		    (itemtype   =>   itemtype,
				itemkey	    =>   itemkey ,
				aname	   	=>	  'AMS_ACT_DESC');
  l_currency := WF_ENGINE.GetItemAttrText
			    (itemtype	=>	  itemtype ,
	 			itemkey 	=>   itemkey,
			    aname	 	=>	  'AMS_CURRENCY');

 --Hbandi code for resoving the BUG #7538786 and (set this FND_FORMS_USER_CALENDAR  default value to 'GREGORIAN' for the bug #8974486)
if (FND_RELEASE.MAJOR_VERSION = 12 and FND_RELEASE.minor_version >= 1 and FND_RELEASE.POINT_VERSION >= 1 ) or (FND_RELEASE.MAJOR_VERSION > 12)
then
l_camp_start_date_txt := to_char(l_start_dt,
                               FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', -1),
                               'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR',-1),'GREGORIAN') || '''');
l_camp_end_date_txt  := to_char(l_end_dt,
                               FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', -1),
                               'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR',-1),'GREGORIAN') || '''');
else
  l_camp_start_date_txt := to_char(l_start_dt);
  l_camp_end_date_txt  := to_char(l_end_dt);
end if;



 --End of hbandi Code


  -- Create an html text buffer
--  if (display_type = 'text/html') then
--  null;
--  return;
--  end if;

  -- Create a plain text buffer
--  if (display_type = 'text/plain') then
  	 IF 	l_approval_for = 'CAMP' THEN

         OPEN c_camp_owner(l_approval_for_id) ;
         FETCH c_camp_owner INTO l_owner ;
         CLOSE c_camp_owner ;


        l_camp_theme := WF_ENGINE.GetItemAttrText
			                 (itemtype	 =>	  itemtype ,
	 					   	  itemkey 	 =>   itemkey,
						   	  aname	 	 =>	  'AMS_CAMP_THEME');
        l_camp_mkt :=  WF_ENGINE.GetItemAttrText
	   		                  (itemtype   =>   itemtype,
							  itemkey	 =>   itemkey ,
							  aname	   	 =>	  'AMS_CAMP_MARKET');
        l_camp_geo := WF_ENGINE.GetItemAttrText
			                 (itemtype	 =>	  itemtype ,
	 					   	  itemkey 	 =>   itemkey,
						   	  aname	 	 =>	  'AMS_CAMP_GEO');


	 	IF 		l_doc_type = 'THEME' THEN


			  FND_MESSAGE.Set_Name('AMS', 'AMS_CAMP_WF_NTF_THEME_APPROVAL');
			  FND_MESSAGE.Set_Token('CAMPAIGN_NAME', l_activity_name, FALSE);

			  FND_MESSAGE.Set_Token('CAMP_EXEC_START_DATE', l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('CAMP_EXEC_END_DATE', l_camp_end_date_txt, FALSE);

			  FND_MESSAGE.Set_Token('CAMP_DESC', l_desc, FALSE);
			  FND_MESSAGE.Set_Token('PURPOSE', l_camp_theme, FALSE);
			  FND_MESSAGE.Set_Token('CAMP_MKT', l_camp_mkt, FALSE);
			  FND_MESSAGE.Set_Token('CAMP_GEO', l_camp_geo, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
                          FND_MESSAGE.Set_Token('OWNER', l_owner, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
			  l_message := FND_MESSAGE.Get;

		ELSIF	l_doc_type = 'BUDGET' THEN



			  FND_MESSAGE.Set_Name('AMS', 'AMS_CAMP_WF_NTF_BUDGET_APPR');
			  FND_MESSAGE.Set_Token('CAMPAIGN_NAME', l_activity_name, FALSE);
			  FND_MESSAGE.Set_Token('CAMP_DESC', l_desc, FALSE);
			  FND_MESSAGE.Set_Token('BUDGET_AMOUNT', l_budget_amount, FALSE);
              FND_MESSAGE.Set_Token('CURR', l_currency, FALSE);
			  FND_MESSAGE.Set_Token('CAMP_EXEC_START_DATE',l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('CAMP_EXEC_END_DATE', l_camp_end_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('PURPOSE', l_camp_theme, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
                          FND_MESSAGE.Set_Token('OWNER', l_owner, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
			  l_message := FND_MESSAGE.Get;
	 	ELSIF 	l_doc_type = 'BOTH' THEN


			  FND_MESSAGE.Set_Name('AMS', 'AMS_CAMP_WF_NTF_BOTH_APPR');
			  FND_MESSAGE.Set_Token('CAMPAIGN_NAME', l_activity_name, FALSE);
			  FND_MESSAGE.Set_Token('BUDGET_AMOUNT', l_budget_amount, FALSE);
                          FND_MESSAGE.Set_Token('CURR', l_currency, FALSE);
			  FND_MESSAGE.Set_Token('CAMP_EXEC_START_DATE', l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('CAMP_EXEC_END_DATE', l_camp_end_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('PURPOSE', l_camp_theme, FALSE);
			  FND_MESSAGE.Set_Token('CAMP_MKT', l_camp_mkt, FALSE);
			  FND_MESSAGE.Set_Token('CAMP_GEO', l_camp_geo, FALSE);
			  FND_MESSAGE.Set_Token('CAMP_DESC', l_desc, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
                          FND_MESSAGE.Set_Token('OWNER', l_owner, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
			  l_message := FND_MESSAGE.Get;

		END IF;
	 ELSIF  l_approval_for = 'DELV' THEN
            l_deli_mkt_msg := WF_ENGINE.GetItemAttrText
                                (itemtype   =>   itemtype,
							  itemkey	 =>   itemkey ,
							  aname	   	 =>	  'AMS_DELI_MKT_MESSAGE');

            l_deli_language :=	WF_ENGINE.GetItemAttrText
                             (itemtype   =>   itemtype,
							  itemkey	 =>   itemkey ,
    						  aname	   	 =>	  'AMS_DELI_LANGUAGE' );

	 	IF 	  l_approval_type = 'THEME' THEN


			  FND_MESSAGE.Set_Name('AMS', 'AMS_DELI_WF_NTF_THEME_APPROVAL');
			  FND_MESSAGE.Set_Token('DELIVERABLE_NAME', l_activity_name, FALSE);
			  FND_MESSAGE.Set_Token('DELI_START_DATE',l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('DELI_END_DATE', l_camp_end_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('LANGUAGE', l_deli_language, FALSE);
			  FND_MESSAGE.Set_Token('DELI_DESC', l_desc, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
			  l_message := FND_MESSAGE.Get;

		ELSIF	l_approval_type = 'BUDGET' THEN

			  FND_MESSAGE.Set_Name('AMS', 'AMS_DELI_WF_NTF_BUDGET_APPROVAL');
			  FND_MESSAGE.Set_Token('DELIVERABLE_NAME', l_activity_name, FALSE);
			  FND_MESSAGE.Set_Token('LANGUAGE', l_deli_language, FALSE);
			  FND_MESSAGE.Set_Token('BUDGET_AMOUNT', l_budget_amount, FALSE);
			  FND_MESSAGE.Set_Token('DELI_START_DATE', l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('DELI_END_DATE', l_camp_end_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
			  FND_MESSAGE.Set_Token('DELI_DESC', l_desc, FALSE);
              FND_MESSAGE.Set_Token('CURRENCY', l_currency, FALSE);
			  l_message := FND_MESSAGE.Get;
	 	ELSIF 	  l_approval_type = 'BOTH' THEN
			  FND_MESSAGE.Set_Name('AMS', 'AMS_DELI_WF_NTF_THEME_APPROVAL');
			  FND_MESSAGE.Set_Token('DELIVERABLE_NAME', l_activity_name, FALSE);
			  FND_MESSAGE.Set_Token('DELI_START_DATE', l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('DELI_END_DATE', l_camp_end_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('LANGUAGE', l_deli_language, FALSE);
			  FND_MESSAGE.Set_Token('BUDGET_AMOUNT', l_budget_amount, FALSE);
			  FND_MESSAGE.Set_Token('DELI_DESC', l_desc, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
              FND_MESSAGE.Set_Token('CURRENCY', l_currency, FALSE);
			  l_message := FND_MESSAGE.Get;

		END IF;
	 ELSIF  l_approval_for = 'EVEH' THEN
            l_eve_mkt_msg := WF_ENGINE.GetItemAttrText
                            (itemtype   =>   itemtype,
							  itemkey	 =>   itemkey ,
						  	  aname	   	 =>	  'AMS_EVE_MKT_MESSAGE');
            OPEN c_eveh_owner(l_approval_for_id) ;
            FETCH c_eveh_owner INTO l_owner ;
            CLOSE c_eveh_owner ;


	 	IF 	l_approval_type = 'THEME' THEN
			  FND_MESSAGE.Set_Name('AMS', 'AMS_EVEH_WF_NTF_THEME_APPROVAL');
			  FND_MESSAGE.Set_Token('EVENT_HEADER_NAME', l_activity_name, FALSE);
			  FND_MESSAGE.Set_Token('EVEH_START_DATE', l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('EVEH_END_DATE', l_camp_end_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('EVEH_MARKETING_MSG', l_eve_mkt_msg, FALSE);
			  FND_MESSAGE.Set_Token('EVEH_DESC', l_desc, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
                          FND_MESSAGE.Set_Token('OWNER', l_owner, FALSE);
			  l_message := FND_MESSAGE.Get;

		ELSIF	l_approval_type = 'BUDGET' THEN
			  FND_MESSAGE.Set_Name('AMS', 'AMS_CAMP_WF_NTF_BUDGET_APPROVAL');
			  FND_MESSAGE.Set_Token('EVENT_HEADER_NAME', l_activity_name, FALSE);
			  FND_MESSAGE.Set_Token('EVEH_START_DATE', l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('EVEH_END_DATE', l_camp_end_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('BUDGET_AMOUNT', l_budget_amount, FALSE);
              FND_MESSAGE.Set_Token('CURRENCY', l_currency, FALSE);
			  FND_MESSAGE.Set_Token('EVEH_DESC', l_desc, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
                          FND_MESSAGE.Set_Token('OWNER', l_owner, FALSE);
			  l_message := FND_MESSAGE.Get;

	 	ELSIF 	l_approval_type = 'BOTH' THEN
			  FND_MESSAGE.Set_Name('AMS', 'AMS_EVEH_WF_NTF_THEME_APPROVAL');
			  FND_MESSAGE.Set_Token('EVENT_HEADER_NAME', l_activity_name, FALSE);
			  FND_MESSAGE.Set_Token('EVEH_START_DATE', l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('EVEH_END_DATE', l_camp_end_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('BUDGET_AMOUNT', l_budget_amount, FALSE);
              FND_MESSAGE.Set_Token('CURRENCY', l_currency, FALSE);
			  FND_MESSAGE.Set_Token('EVEH_MARKETING_MSG', l_eve_mkt_msg, FALSE);
			  FND_MESSAGE.Set_Token('EVEH_DESC', l_desc, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
                          FND_MESSAGE.Set_Token('OWNER', l_owner, FALSE);
			  l_message := FND_MESSAGE.Get;

		END IF;
 	 ELSIF  l_approval_for = 'EVEO' THEN

        l_eve_mkt_msg := WF_ENGINE.GetItemAttrText
                                (itemtype   =>   itemtype,
								  itemkey	 =>   itemkey ,
						  		  aname	   	 =>	  'AMS_EVE_MKT_MESSAGE');
         OPEN c_eveo_owner(l_approval_for_id) ;
         FETCH c_eveo_owner INTO l_owner ;
         CLOSE c_eveo_owner ;


	 	IF 	l_approval_type = 'THEME' THEN
			  FND_MESSAGE.Set_Name('AMS', 'AMS_EVEO_WF_NTF_THEME_APPROVAL');
			  FND_MESSAGE.Set_Token('EVENT_OFFER_NAME', l_activity_name, FALSE);
			  FND_MESSAGE.Set_Token('EVEO_START_DATE', l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('EVEO_END_DATE', l_camp_end_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('EVEO_MARKETING_MSG', l_eve_mkt_msg, FALSE);
			  FND_MESSAGE.Set_Token('EVEO_DESC', l_desc, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
                          FND_MESSAGE.Set_Token('OWNER', l_owner, FALSE);
			  l_message := FND_MESSAGE.Get;

		ELSIF	l_approval_type = 'BUDGET' THEN
			  FND_MESSAGE.Set_Name('AMS', 'AMS_CAMP_WF_NTF_BUDGET_APPROVAL');
			  FND_MESSAGE.Set_Token('EVENT_OFFER_NAME', l_activity_name, FALSE);
			  FND_MESSAGE.Set_Token('BUDGET_AMOUNT', l_budget_amount, FALSE);
              FND_MESSAGE.Set_Token('CURRENCY', l_currency, FALSE);
			  FND_MESSAGE.Set_Token('EVEO_START_DATE', l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('EVEO_END_DATE',l_camp_end_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('EVEO_DESC', l_desc, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
                          FND_MESSAGE.Set_Token('OWNER', l_owner, FALSE);
			  l_message := FND_MESSAGE.Get;

	 	ELSIF 	l_approval_type = 'BOTH' THEN
			  FND_MESSAGE.Set_Name('AMS', 'AMS_EVEO_WF_NTF_THEME_APPROVAL');
			  FND_MESSAGE.Set_Token('EVENT_OFFER_NAME', l_activity_name, FALSE);
			  FND_MESSAGE.Set_Token('EVEO_START_DATE', l_camp_start_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('EVEO_END_DATE', l_camp_end_date_txt, FALSE);
			  FND_MESSAGE.Set_Token('EVEO_MARKETING_MSG', l_eve_mkt_msg, FALSE);
			  FND_MESSAGE.Set_Token('BUDGET_AMOUNT', l_budget_amount, FALSE);
              FND_MESSAGE.Set_Token('CURRENCY', l_currency, FALSE);
			  FND_MESSAGE.Set_Token('EVEO_DESC', l_desc, FALSE);
			  FND_MESSAGE.Set_Token('REQUESTER', l_requester, FALSE);
			  FND_MESSAGE.Set_Token('NOTE', l_requester_note, FALSE);
                          FND_MESSAGE.Set_Token('OWNER', l_owner, FALSE);
			  l_message := FND_MESSAGE.Get;

		END IF;
	 END IF ;


  document := document|| l_message ;

  document_type := 'text/plain';

  RETURN;
--  END IF;

EXCEPTION
WHEN OTHERS THEN
    wf_core.context('AMS_WfCmpapr_PVT','Create_Notif_Document',itemtype,itemkey);
	RAISE;
--actid,
END Create_Notif_Document;

-- Start of Comments
--
-- NAME
--   Prepare_Doc
--
-- PURPOSE
--   This Procedure will create the Document to be sent for the Approvals
-- 	 it will also Update the Status As the Activity as Submitted for Approvals
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_PREPARE_DOC
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Prepare_Doc	(itemtype    IN	  VARCHAR2,
                         itemkey     IN	  VARCHAR2,
                         actid	     IN	  NUMBER,
                         funcmode    IN	  VARCHAR2,
                         result      OUT NOCOPY  VARCHAR2) IS

  l_obj_type              VARCHAR2(30);
  l_tmp_stat_code         VARCHAR2(30);
  l_sys_stat_code         VARCHAR2(30);

  l_msg_count             NUMBER ;
  l_msg_data              VARCHAR2(2000);
  l_obj_id                NUMBER ;
  l_obj_version_number    NUMBER ;
  l_requester_id          NUMBER ;
  l_doc_type              VARCHAR2(30) ;
  l_return_status         VARCHAR2(1);

  l_requester             VARCHAR2(30);
  l_approval_for		VARCHAR2(30);
  l_approval_for_id   NUMBER;
  l_approval_type     VARCHAR2(80);
  l_timeout           NUMBER ;
  l_priority          NUMBER;

  l_activity_name		  VARCHAR2(240);

  l_start_dt              DATE;
  l_end_dt                DATE;
  l_desc                  VARCHAR2(2000);
  l_budget_amount         NUMBER;
  l_currency_code         VARCHAR2(30);
  l_currency              VARCHAR2(80);

-- Campaign Variables
  CURSOR C_campaign(l_my_campaign_id   VARCHAR2
  		 	 )	  IS
  SELECT  camp.campaign_name,
	  camp.actual_exec_start_date,
	  camp.actual_exec_end_date,
	  camp.description,
          camp.transaction_currency_code,
          camp.budget_amount_tc
  FROM	  ams_campaigns_vl camp
  WHERE   camp.campaign_id = l_my_campaign_id ;

  CURSOR C_camp_geo(l_my_campaign_id   VARCHAR2
  		  )	  IS
  SELECT  geo_area_name
  FROM	  ams_act_geo_areas_v
  WHERE   act_geo_area_user = 'CAMP'
  AND 	  act_geo_area_user_id = l_my_campaign_id ;

  CURSOR C_camp_mkt(l_my_campaign_id   VARCHAR2
  		 )	  IS
  SELECT  mkt.cell_name
  FROM	  ams_act_market_segments act,ams_cells_vl mkt
  WHERE   act.arc_act_market_segment_used_by = 'CAMP'
  AND 	  act.act_market_segment_used_by_id  = l_my_campaign_id
  AND	  mkt.cell_id = act.market_segment_id ;

  CURSOR C_theme(l_my_campaign_id IN NUMBER,
                 l_my_obj_type       IN VARCHAR2)
      IS
  SELECT m.message_name
  FROM   ams_messages_vl m,ams_act_messages a
  WHERE  a.message_used_by_id  =  l_my_campaign_id
  AND    a.message_used_by = l_my_obj_type
  AND    a.message_id = m.message_id ;

  CURSOR c_currency(l_cur_code IN VARCHAR2)
  IS
  SELECT  name
  FROM    fnd_currencies_vl
  WHERE   currency_code = l_cur_code ;

  l_tmp_str	VARCHAR2(2000);



  l_camp_theme 	VARCHAR2(4000);
  l_camp_obj	VARCHAR2(4000);
  l_camp_mkt	VARCHAR2(4000);
  l_camp_geo	VARCHAR2(4000);


-- Deliverables Variables
  CURSOR C_deliverable(l_my_deliverable_id   VARCHAR2 )
  IS
  SELECT  dl.deliverable_name deliverable_name,
	  dl.actual_avail_from_date actual_avail_from_date,
          dl.actual_avail_to_date actual_avail_to_date,
          dl.description description,
	  lg.nls_language nls_language,
          dl.transaction_currency_code transaction_currency_code,
          dl.budget_amount_tc budget_amount_tc
  FROM	  ams_deliverables_vl dl,fnd_languages lg
  WHERE   dl.deliverable_id = l_my_deliverable_id
  AND	  dl.language_code =  lg.language_code ;


  l_deli_language 	VARCHAR2(30);
  l_deli_mkt_msg  	VARCHAR2(4000);

-- events variables

  CURSOR C_event_header(l_my_event_header_id   VARCHAR2
  		 									   		    )	  IS
  SELECT  event_header_name,
	  active_from_date,
	  active_to_date,
          description,
          fund_amount_tc
          ,currency_code_tc
  FROM	  ams_event_headers_vl
  WHERE   event_header_id = l_my_event_header_id ;

  l_eve_mkt_msg		  VARCHAR2(4000);

  CURSOR C_event_offer(l_my_event_offer_id   VARCHAR2   )
  IS
  SELECT  o.event_offer_name,
  	  o.event_start_date,
  	  o.event_end_date,
          o.description,
          o.fund_amount_tc
         ,o.currency_code_tc
  FROM	  ams_event_offers_vl o
  WHERE   o.event_offer_id = l_my_event_offer_id ;



BEGIN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_Utility_PVT.debug_message('Prepare Documents');
     END IF;
	 --  RUN mode  - Normal Process Execution
	 IF (funcmode = 'RUN')
	 THEN
-- Create the Notification Document

  l_approval_for  := wf_engine.GetItemAttrText(
				itemtype => ItemType,
				itemkey  => ItemKey,
				aname    => 'AMS_APPROVAL_FOR_OBJECT');

  l_approval_for_id  := wf_engine.GetItemAttrText(
				itemtype => ItemType,
				itemkey  => ItemKey,
				aname    => 'AMS_ACT_ID');

  l_requester := wf_engine.GetItemAttrText(
				itemtype => ItemType,
				itemkey  => ItemKey,
				aname    => 'AMS_REQUESTER');

  l_doc_type := wf_engine.GetItemAttrText(
				itemtype => ItemType,
				itemkey  => ItemKey,
				aname    => 'AMS_APPR_DOC_TYPE');

  l_approval_type := Get_Lookup_Meaning('AMS_APPROVAL_TYPE',l_doc_type);

  WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
   			    itemkey    =>  itemkey,
 		   	    aname      =>  'AMS_APPROVAL_TYPE',
			    avalue     =>  l_approval_type  );

  Find_Priority(p_obj_type      => l_approval_for,
                p_obj_id        => l_approval_for_id,
                p_approval_type => l_doc_type,
                x_timeout_days  => l_timeout,
                x_priority      => l_priority) ;


  WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                            itemkey 	 =>  itemkey,
                            aname        =>  'AMS_TIMEOUT',
                            avalue       =>  l_timeout  );

  WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                            itemkey 	 =>  itemkey,
                            aname	 =>  'AMS_PRIORITY',
                            avalue	 =>  l_priority  );


  IF 	l_approval_for = 'CAMP' THEN

       OPEN  c_campaign(l_approval_for_id) ;
       FETCH c_campaign
       INTO  l_activity_name,l_start_dt,l_end_dt,
             l_desc,l_currency_code,l_budget_amount ;
       CLOSE c_campaign;

       OPEN  C_theme(l_approval_for_id,'CAMP') ;
       FETCH C_theme INTO l_camp_theme ;
       LOOP
         FETCH C_theme INTO l_tmp_str ;
         EXIT WHEN C_theme%NOTFOUND ;
         l_camp_theme := l_camp_theme ||', '||l_tmp_str ;
       END LOOP;
       CLOSE C_theme ;

       OPEN  c_camp_geo(l_approval_for_id) ;
       FETCH c_camp_geo INTO l_camp_geo ;
       LOOP
          FETCH C_camp_geo INTO l_tmp_str ;
          EXIT WHEN C_camp_geo%NOTFOUND ;
          l_camp_geo := l_camp_geo ||', '||l_tmp_str ;
       END LOOP;
       CLOSE c_camp_geo ;

       OPEN  c_camp_mkt(l_approval_for_id) ;
       FETCH c_camp_mkt INTO l_camp_mkt ;
       LOOP
          FETCH c_camp_mkt INTO l_tmp_str ;
          EXIT WHEN c_camp_mkt%NOTFOUND ;
          l_camp_mkt := l_camp_mkt ||', '||l_tmp_str ;
       END LOOP;
       CLOSE c_camp_mkt ;

       OPEN  c_currency(l_currency_code);
       FETCH c_currency INTO l_currency ;
       CLOSE c_currency ;


       WF_ENGINE.SetItemAttrText(itemtype          =>  itemtype ,
                                 itemkey 	   =>  itemkey,
                                 aname             =>  'AMS_ACT_NAME',
                                 avalue	           =>  l_activity_name  );
       WF_ENGINE.SetItemAttrText(itemtype          =>  itemtype,
                                 itemkey	   =>  itemkey ,
                                 aname	   	   =>  'AMS_ACT_START_DATE',
                                 avalue	           =>  l_start_dt   );
       WF_ENGINE.SetItemAttrText(itemtype          =>  itemtype,
                                 itemkey	   =>  itemkey ,
                                 aname	   	   =>  'AMS_ACT_END_DATE',
                                 avalue	           =>  l_end_dt   );
       WF_ENGINE.SetItemAttrText(itemtype	   =>  itemtype ,
                                 itemkey 	   =>  itemkey,
                                 aname	 	   =>  'AMS_CAMP_THEME',
                                 avalue	           =>  l_camp_theme  );

       WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
                                 itemkey	 =>   itemkey ,
                                 aname	   	 =>	  'AMS_CAMP_MARKET',
                                 avalue	 =>   l_camp_mkt   );
       WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                                 itemkey 	 =>   itemkey,
                                 aname	 	 =>	  'AMS_CAMP_GEO',
                                 avalue	 =>	  l_camp_geo );
       WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                                 itemkey 	 =>   itemkey,
                                 aname	 	 =>	  'AMS_BUDGET_AMOUNT',
                                 avalue	 =>	  l_budget_amount );
       WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
                                 itemkey	 =>   itemkey ,
                                 aname	   	 =>	  'AMS_ACT_DESC',
                                 avalue	 =>   l_desc    );

       WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                                 itemkey 	 =>   itemkey,
                                 aname	 	 =>	  'AMS_CURRENCY',
                                 avalue	 =>	  l_currency );


	 ELSIF  l_approval_for = 'DELV' THEN
            OPEN  c_deliverable(l_approval_for_id) ;
            FETCH c_deliverable	INTO  l_activity_name,l_start_dt,
                 l_end_dt,l_desc,l_deli_language,l_currency_code,l_budget_amount ;
            CLOSE c_deliverable;

            OPEN  c_currency(l_currency_code);
            FETCH c_currency INTO l_currency ;
            CLOSE c_currency ;

			WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
	 					   			  itemkey 	 =>   itemkey,
						   			  aname	 	 =>	  'AMS_ACT_NAME',
						   			  avalue	 =>	  l_activity_name  );
	   		WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
									  itemkey	 =>   itemkey ,
							  		  aname	   	 =>	  'AMS_ACT_START_DATE',
						   		  	  avalue	 =>   l_start_dt   );
	   		WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
									  itemkey	 =>   itemkey ,
							  		  aname	   	 =>	  'AMS_ACT_END_DATE',
						   		  	  avalue	 =>   l_end_dt   );
	   		WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
									  itemkey	 =>   itemkey ,
							  		  aname	   	 =>	  'AMS_DELI_LANGUAGE',
						   		  	  avalue	 =>   l_deli_language   );
       		WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
									  itemkey	 =>   itemkey ,
							  		  aname	   	 =>	  'AMS_ACT_DESC',
						   		  	  avalue	 =>   l_desc    );
			WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
	 					   			  itemkey 	 =>   itemkey,
						   			  aname	 	 =>	  'AMS_BUDGET_AMOUNT',
						   			  avalue	 =>	  l_budget_amount );

			WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
	 					   			  itemkey 	 =>   itemkey,
						   			  aname	 	 =>	  'AMS_CURRENCY',
						   			  avalue	 =>	  l_currency );
	 ELSIF  l_approval_for = 'EVEH' THEN

            OPEN c_event_header(l_approval_for_id);
            FETCH c_event_header
            INTO l_activity_name,l_start_dt,l_end_dt,l_desc,l_budget_amount,l_currency_code ;
            CLOSE c_event_header;

            OPEN  c_currency(l_currency_code);
            FETCH c_currency INTO l_currency ;
            CLOSE c_currency ;

            OPEN  C_theme(l_approval_for_id,'EVEH') ;
            FETCH C_theme INTO l_eve_mkt_msg ;
            LOOP
               FETCH C_theme INTO l_tmp_str ;
               EXIT WHEN C_theme%NOTFOUND ;
               l_eve_mkt_msg := l_eve_mkt_msg ||', '||l_tmp_str ;
            END LOOP;
            CLOSE C_theme ;

	 	WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
					   			  itemkey 	 =>   itemkey,
					   			  aname	 	 =>	  'AMS_ACT_NAME',
					   			  avalue	 =>	  l_activity_name  );
		WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
								  itemkey	 =>   itemkey ,
						  		  aname	   	 =>	  'AMS_ACT_START_DATE',
					   		  	  avalue	 =>   l_start_dt   );
		WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
								  itemkey	 =>   itemkey ,
						  		  aname	   	 =>	  'AMS_ACT_END_DATE',
					   		  	  avalue	 =>   l_end_dt   );
		WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
								  itemkey	 =>   itemkey ,
						  		  aname	   	 =>	  'AMS_EVE_MKT_MESSAGE',
					   		  	  avalue	 =>   l_eve_mkt_msg   );
		WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
					   			  itemkey 	 =>   itemkey,
	   				   			  aname	 	 =>	  'AMS_BUDGET_AMOUNT',
	       			   			  avalue	 =>	  l_budget_amount );
	   	WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
								  itemkey	 =>   itemkey ,
						  		  aname	   	 =>	  'AMS_ACT_DESC',
					   		  	  avalue	 =>   l_desc    );
    	WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
					   			  itemkey 	 =>   itemkey,
					   			  aname	 	 =>	  'AMS_CURRENCY',
					   			  avalue	 =>	  l_currency );
 	 ELSIF  l_approval_for = 'EVEO' THEN

            OPEN c_event_offer(l_approval_for_id) ;
	    FETCH c_event_offer
	    INTO l_activity_name,l_start_dt,l_end_dt,l_desc,l_budget_amount,l_currency_code;
--           ,  l_currency                 ;
	    CLOSE c_event_offer;

            OPEN  c_currency(l_currency_code);
            FETCH c_currency INTO l_currency ;
            CLOSE c_currency ;

            OPEN  C_theme(l_approval_for_id,'EVEO') ;
            FETCH C_theme INTO l_eve_mkt_msg ;
            LOOP
               FETCH C_theme INTO l_tmp_str ;
               EXIT WHEN C_theme%NOTFOUND ;
               l_eve_mkt_msg := l_eve_mkt_msg ||', '||l_tmp_str ;
            END LOOP;
            CLOSE C_theme ;

	 	WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
					   			  itemkey 	 =>   itemkey,
					   			  aname	 	 =>	  'AMS_ACT_NAME',
					   			  avalue	 =>	  l_activity_name  );
		WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
								  itemkey	 =>   itemkey ,
						  		  aname	   	 =>	  'AMS_ACT_START_DATE',
					   		  	  avalue	 =>   l_start_dt   );
		WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
								  itemkey	 =>   itemkey ,
						  		  aname	   	 =>	  'AMS_ACT_END_DATE',
					   		  	  avalue	 =>   l_end_dt   );
		WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
								  itemkey	 =>   itemkey ,
						  		  aname	   	 =>	  'AMS_EVE_MKT_MESSAGE',
					   		  	  avalue	 =>   l_eve_mkt_msg   );
		WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
					   			  itemkey 	 =>   itemkey,
	   				   			  aname	 	 =>	  'AMS_BUDGET_AMOUNT',
	       			   			  avalue	 =>	  l_budget_amount );
	   	WF_ENGINE.SetItemAttrText(itemtype   =>   itemtype,
								  itemkey	 =>   itemkey ,
						  		  aname	   	 =>	  'AMS_ACT_DESC',
					   		  	  avalue	 =>   l_desc    );
    	WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
					   			  itemkey 	 =>   itemkey,
					   			  aname	 	 =>	  'AMS_CURRENCY',
					   			  avalue	 =>	  l_currency );


    END IF;


	    wf_engine.SetItemAttrText(	itemtype => itemtype,
					itemkey  => itemkey,
					aname    => 'AMS_NOTIF_DOCUMENT',
					avalue   =>
			'PLSQL:AMS_WFCMPAPR_PVT.Create_Notif_Document/'||
			ItemType||':'||
			ItemKey);

            l_doc_type    := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPR_DOC_TYPE');


            l_obj_type    := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPROVAL_FOR_OBJECT');

            l_obj_id      := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_ACT_ID');
            l_obj_version_number := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_OBJECT_VERSION_NUMBER');
           l_requester_id := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_REQUESTER_ID');


            IF l_doc_type = 'BUDGET' THEN
                l_tmp_stat_code := 'SUBMIT_BA' ;
            ELSE
                l_tmp_stat_code := 'SUBMIT_TA' ;
            END IF ;
            --
            -- Get the Valid Code (Bubmit BA/TA) for Activity
            --
            Get_Valid_status(p_object_type    => l_obj_type,
                             p_stat_code      => l_tmp_stat_code,
                             x_sys_stat_code  => l_sys_stat_code) ;

            --
            -- Update Activity
            --
            Update_Status(p_obj_type          	 => l_obj_type,
		   	p_obj_id     		 => l_obj_id,
                        p_object_version_number  => l_obj_version_number,
			p_next_stat_code         => l_sys_stat_code, --System Status
                        p_appr_type              => l_doc_type,
                        p_submitted_by           => l_requester_id,
                        p_item_key               => itemkey   ,
                        x_msg_count              => l_msg_count,
                        x_msg_data               => l_msg_data,
						x_return_status   	   	 => l_return_status)  ;


			IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		   	   	    result := 'COMPLETE:SUCCESS' ;
			ELSE
                    Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_ERROR_MSG'
                            )               ;
				  result := 'COMPLETE:ERROR' ;
 		    END IF ;
	 END IF ;

    --  CANCEL mode  - Normal Process Execution
	 IF (funcmode = 'CANCEL')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;

	 --  TIMEOUT mode  - Normal Process Execution
	 IF (funcmode = 'TIMEOUT')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;
EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context(G_PKG_NAME,'Prepare_Doc',itemtype,itemkey,actid,funcmode);
		  raise ;
END Prepare_Doc ;

-- Start of Comments
--
-- NAME
--   Owner_Appr_Check
--
-- PURPOSE
--   This Procedure will check whether the Owner's Approval is required for the Theme
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the Owner's Approval is required
--	  		 - 'COMPLETE:N' If the Owner's Approval is not required
--
--
-- OUT
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_CHECK_OWN_APPR
-- NOTES
--
--
-- HISTORY
--   09/13/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Owner_Appr_Check 	(itemtype    IN	  VARCHAR2,
		 		itemkey	     IN	  VARCHAR2,
		 		actid	     IN	  NUMBER,
		 		funcmode     IN	  VARCHAR2,
		 		result       OUT NOCOPY  VARCHAR2) IS
	l_ta_appr_flag    VARCHAR2(1);
    l_owner           VARCHAR2(100);
    l_manager         VARCHAR2(100);
    l_fund_manager    VARCHAR2(100);
    l_bud_appr_flag   VARCHAR2(1);
    l_appr_type       VARCHAR2(30);
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Process Owner_appr_check');
   END IF;
   -- dbms_output.put_line('Process Owner_appr_check');
	 --  RUN mode  - Normal Process Execution
	 IF (funcmode = 'RUN')
	 THEN
             l_ta_appr_flag   := WF_ENGINE.GetItemAttrText(
						   itemtype  =>    itemtype,
					   	   itemkey   => 	 itemkey ,
					   	   aname     =>	 'AMS_TAOWNER_APPR_FLAG');
             l_owner   := WF_ENGINE.GetItemAttrText(
	           				   itemtype  =>    itemtype,
					   	   itemkey   => 	 itemkey ,
					   	   aname     =>	 'AMS_OWNER');
             l_bud_appr_flag   := WF_ENGINE.GetItemAttrText(
						   itemtype  =>    itemtype,
					   	   itemkey   => 	 itemkey ,
					   	   aname     =>	 'AMS_BUDGET_APPR_FLAG');

             l_fund_manager   := WF_ENGINE.GetItemAttrText(
						   itemtype  =>    itemtype,
					   	   itemkey   => 	 itemkey ,
					   	   aname     =>	 'AMS_BUD_MANAGER');

             l_manager   := WF_ENGINE.GetItemAttrText(
						   itemtype  =>    itemtype,
					   	   itemkey   => 	 itemkey ,
					   	   aname     =>	 'AMS_MANAGER');

             l_appr_type   := WF_ENGINE.GetItemAttrText(
						   itemtype  =>    itemtype,
					   	   itemkey   => 	 itemkey ,
					   	   aname     =>	 'AMS_APPR_TYPE_LOOKUP');

            IF l_ta_appr_flag = 'Y' THEN
                IF l_appr_type = 'THEME' THEN
               	    WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                                              itemkey 	 =>  itemkey,
                                              aname 	 =>  'AMS_APPR_USERNAME',
                                              avalue	 =>  l_owner);
                    WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                                              itemkey 	 =>  itemkey,
                                              aname 	 =>  'AMS_TAOWNER_APPR_FLAG',
                                              avalue	 =>  'N');
                    WF_ENGINE.SetItemAttrText(itemtype	 =>  itemtype ,
                                              itemkey 	 =>  itemkey,
                                              aname 	 =>  'AMS_APPR_DOC_TYPE',
                                              avalue	 =>  'THEME');

                ELSE -- l_appr_type = 'BOTH' THEN
                    IF l_fund_manager = l_manager THEN
                       	WF_ENGINE.SetItemAttrText(itemtype => itemtype ,
                                                  itemkey  => itemkey,
                                                  aname	   => 'AMS_APPR_USERNAME',
                                                  avalue   => l_owner);
                        WF_ENGINE.SetItemAttrText(itemtype => itemtype ,
                                                  itemkey  => itemkey,
                                                  aname    => 'AMS_TAOWNER_APPR_FLAG',
                                                  avalue   => 'N');
                        WF_ENGINE.SetItemAttrText(itemtype => itemtype ,
                                                  itemkey  => itemkey,
                                                  aname	   => 'AMS_APPR_DOC_TYPE',
                                                  avalue   => 'THEME');
                    ELSIF l_owner = l_fund_manager THEN
                       	WF_ENGINE.SetItemAttrText(itemtype => itemtype ,
                                                  itemkey  => itemkey,
                                                  aname	   => 'AMS_APPR_USERNAME',
                                                  avalue   => l_owner);

                        WF_ENGINE.SetItemAttrText(itemtype => itemtype ,
                                                  itemkey  => itemkey,
                                                  aname	   => 'AMS_TAOWNER_APPR_FLAG',
                                                  avalue   => 'N');
                        WF_ENGINE.SetItemAttrText(itemtype => itemtype ,
                                                  itemkey  => itemkey,
                                                  aname	   => 'AMS_APPR_DOC_TYPE',
                                                  avalue   => 'BOTH');
                    ELSE
                       	WF_ENGINE.SetItemAttrText(itemtype => itemtype ,
                                                  itemkey  => itemkey,
                                                  aname	   => 'AMS_APPR_USERNAME',
                                                  avalue   => l_owner);

                        WF_ENGINE.SetItemAttrText(itemtype => itemtype ,
                                                  itemkey  => itemkey,
                                                  aname	   => 'AMS_BUDGET_APPR_FLAG',
                                                  avalue   => 'Y');
                        WF_ENGINE.SetItemAttrText(itemtype => itemtype ,
                                                  itemkey  => itemkey,
                                                  aname	   => 'AMS_TAOWNER_APPR_FLAG',
                                                  avalue   => 'N');
                        WF_ENGINE.SetItemAttrText(itemtype => itemtype ,
                                                  itemkey  => itemkey,
                                                  aname	   => 'AMS_APPR_DOC_TYPE',
                                                  avalue   => 'THEME');
                    END IF ;
                END IF;
                result := 'COMPLETE:Y' ;
            ELSE -- IF l_ba_appr_flag = 'N' THEN
                IF l_bud_appr_flag = 'Y' THEN
                   	WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                                                  itemkey 	 =>   itemkey,
                                                  aname	 	 =>	  'AMS_APPR_USERNAME',
                                                  avalue	 =>	  l_fund_manager);
                        WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                                                  itemkey 	 =>   itemkey,
                                                  aname	 	 =>	  'AMS_APPR_DOC_TYPE',
                                                      avalue	 =>	  'BUDGET');
                END IF;
                    result := 'COMPLETE:N' ;
            END IF;
	 END IF;

	 --  CANCEL mode  - Normal Process Execution
	 IF (funcmode = 'CANCEL')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;

	 --  TIMEOUT mode  - Normal Process Execution
	 IF (funcmode = 'TIMEOUT')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;
-- dbms_output.put_line('End Update log');
EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context(G_PKG_NAME,'Owner_Appr_Check',itemtype,itemkey,actid,funcmode);
		  raise ;
END Owner_Appr_Check;

-- Start of Comments
--
-- NAME
--   Update_Stat_ApprTA
--
-- PURPOSE
--   This Procedure will Update the Status of the Activity for Approval
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_UPDATE_STATUS_TA
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Update_Stat_ApprTA (itemtype   IN	  VARCHAR2,
                              itemkey 	 IN	  VARCHAR2,
    			      actid	 IN	  NUMBER,
                              funcmode	 IN	  VARCHAR2,
                              result     OUT NOCOPY  VARCHAR2) IS

  l_bud_appr_flg          VARCHAR2(1);
  l_obj_type              VARCHAR2(30);
  l_next_stat_id          NUMBER ;

  l_msg_count             NUMBER ;
  l_msg_data              VARCHAR2(2000);
  l_obj_id                NUMBER ;
  l_obj_version_number    NUMBER ;
  l_doc_type              VARCHAR2(30);
  l_requester_id          NUMBER ;
  l_appr_type_lookup      VARCHAR2(30);
  l_sys_stat_code         VARCHAR2(30);
  l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  l_approver              VARCHAR2(30);
  l_note                  VARCHAR2(2000);

  CURSOR c_sys_stat(l_user_stat_id NUMBER) IS
  SELECT    system_status_code
  FROM      ams_user_statuses_vl
  WHERE     user_status_id = l_user_stat_id ;

BEGIN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_Utility_PVT.debug_message('Process Updt_Stat_apprTA');
     END IF;
     -- dbms_output.put_line('Process Updt_Stat_apprTA');
	 --  RUN mode  - Normal Process Execution
	 IF (funcmode = 'RUN')
	 THEN
            l_bud_appr_flg    := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_BUDGET_APPR_FLAG');

            l_obj_type    := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPROVAL_FOR_OBJECT');

            l_obj_id      := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_ACT_ID');
            l_obj_version_number := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_OBJECT_VERSION_NUMBER');
            l_next_stat_id := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_NEW_STAT_ID');
            l_requester_id := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_REQUESTER_ID');
            l_doc_type := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPR_DOC_TYPE');

            l_appr_type_lookup := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPR_TYPE_LOOKUP');

            l_approver := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPR_USERNAME');

            l_note := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_NOTE');

            OPEN  c_sys_stat(l_next_stat_id) ;
            FETCH c_sys_stat INTO l_sys_stat_code ;
            CLOSE c_sys_stat ;

            -- Update the Notes which Approver has Given with Approvals
            IF l_note IS NOT NULL THEN
            Update_Note(p_obj_type      => l_obj_type,
                        p_obj_id        => l_obj_id,
                        p_note          => l_note,
                        p_user          => l_approver,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        x_return_status => l_return_status) ;

           END IF ;
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_ERROR_MSG'
                            )               ;
		  result := 'COMPLETE:ERROR' ;
           ELSE
             IF l_bud_appr_flg = 'Y' THEN
             -- No Need to Update the Status

             --  Update the Attribute
                Update_Attribute(p_obj_type      => l_obj_type,
                                 p_obj_id 	 => l_obj_id,
                                 p_obj_attr      => 'TAPL',
                                 x_msg_count     => l_msg_count,
                                 x_msg_data      => l_msg_data,
                                 x_return_status => l_return_status )  ;

                IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                    result := 'COMPLETE:SUCCESS' ;
                ELSE
                    Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_ERROR_MSG'
                            )               ;
		  result := 'COMPLETE:ERROR' ;
                END IF;

             ELSE
                --
                -- Update Activity
                --
                Update_Status(p_obj_type               => l_obj_type,
			      p_obj_id     	       => l_obj_id,
                              p_object_version_number  => l_obj_version_number,
    			      p_next_stat_code         => l_sys_stat_code, --System Status
                              p_next_stat_id           => l_next_stat_id,
                              p_appr_type              => l_doc_type,
                              p_submitted_by           => l_requester_id,
                              p_item_key               => itemkey   ,
                              x_msg_count              => l_msg_count,
                              x_msg_data               => l_msg_data,
    			      x_return_status          => l_return_status)  ;

      		IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                -- Update the Attribute to show that Theme Approval is Completed
                  IF    l_appr_type_lookup = 'THEME' THEN
                    Update_Attribute(p_obj_type      => l_obj_type,
   			   	     p_obj_id  	     => l_obj_id,
                                     p_obj_attr      => 'TAPL',
                                     x_msg_count     => l_msg_count,
                                     x_msg_data      => l_msg_data,
                                     x_return_status => l_return_status)  ;
                  ELSIF l_appr_type_lookup = 'BOTH' THEN
                    Update_Attribute(p_obj_type      => l_obj_type,
   	       		   	     p_obj_id        => l_obj_id,
                                     p_obj_attr      => 'TAPL',
                                     x_msg_count     => l_msg_count,
                                     x_msg_data      => l_msg_data,
                                     x_return_status => l_return_status)  ;
                    Update_Attribute(p_obj_type      => l_obj_type,
  	       		   	     p_obj_id        => l_obj_id,
                                     p_obj_attr      => 'BAPL',
                                     x_msg_count     => l_msg_count,
                                     x_msg_data      => l_msg_data,
                                     x_return_status => l_return_status)  ;

                  END IF;

                  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                      result := 'COMPLETE:SUCCESS' ;
                  ELSE
                    Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_ERROR_MSG'
                            )               ;
                    result := 'COMPLETE:ERROR' ;
                  END IF;
                ELSE
                    Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_ERROR_MSG'
                            )               ;
    				  result := 'COMPLETE:ERROR' ;
     		    END IF ;
             END IF ;
           END IF;


	 END IF ;

    --  CANCEL mode  - Normal Process Execution
	 IF (funcmode = 'CANCEL')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;

	 --  TIMEOUT mode  - Normal Process Execution
	 IF (funcmode = 'TIMEOUT')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;
EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context(G_PKG_NAME,'Update_Stat_ApprTA',itemtype,itemkey,actid,funcmode);
		  raise ;
END Update_Stat_ApprTA ;


-- Start of Comments
--
-- NAME
--   Update_Status_Rej
--
-- PURPOSE
--   This Procedure will Update the Status of the Activity for Rejection
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_UPDATE_STATUS_REJ
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Update_Status_Rej	(itemtype    IN	  VARCHAR2,
		  				itemkey	 	 IN	  VARCHAR2,
						actid	     IN	  NUMBER,
						funcmode	 IN	  VARCHAR2,
						result       OUT NOCOPY  VARCHAR2) IS
  l_doc_type              VARCHAR2(30);
  l_obj_type              VARCHAR2(30);
  l_tmp_stat_code         VARCHAR2(30);
  l_sys_stat_code         VARCHAR2(30);

  l_msg_count             NUMBER ;
  l_msg_data              VARCHAR2(2000);
  l_obj_id                NUMBER ;
  l_obj_version_number    NUMBER ;
  l_requester_id          NUMBER ;
  l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS ;
  l_approver              VARCHAR2(30);
  l_note                  VARCHAR2(2000);
BEGIN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_Utility_PVT.debug_message('Process Update Status_rej');
     END IF;
     -- dbms_output.put_line('Process Update Status_rej');
	 --  RUN mode  - Normal Process Execution
	 IF (funcmode = 'RUN')
	 THEN
            l_doc_type    := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPR_DOC_TYPE');

            l_obj_type    := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPROVAL_FOR_OBJECT');

            l_obj_id      := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_ACT_ID');
            l_obj_version_number := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_OBJECT_VERSION_NUMBER');
           l_requester_id := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_REQUESTER_ID');

            l_approver := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPR_USERNAME');

            l_note := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_NOTE');

            IF l_doc_type = 'BUDGET' THEN
                l_tmp_stat_code := 'REJECT_BA' ;
            ELSE
                l_tmp_stat_code := 'REJECT_TA' ;
            END IF ;
            --
            -- Get the Valid Code (Bubmit BA/TA) for Activity
            --
            Get_Valid_status(p_object_type    => l_obj_type,
                             p_stat_code      => l_tmp_stat_code,
                             x_sys_stat_code  => l_sys_stat_code) ;

            -- Update the Notes which Approver has Given with Rejection
            IF l_note IS NOT NULL THEN
            Update_Note(p_obj_type      => l_obj_type,
                        p_obj_id        => l_obj_id,
                        p_note          => l_note,
                        p_user          => l_approver,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        x_return_status => l_return_status) ;

            END IF ;
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	           Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_ERROR_MSG'
                            )               ;
				  result := 'COMPLETE:ERROR' ;
            ELSE

               --
               -- Update Activity
               --
               Update_Status(p_obj_type       	 => l_obj_type,
		   	p_obj_id     		 => l_obj_id,
                        p_object_version_number  => l_obj_version_number,
		        p_next_stat_code         => l_sys_stat_code, --System Status
                        p_appr_type              => l_doc_type,
                        p_submitted_by           => l_requester_id,
                        p_item_key               => itemkey  ,
                        x_msg_count              => l_msg_count,
                        x_msg_data               => l_msg_data,
			x_return_status     	 => l_return_status)  ;

		IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		    result := 'COMPLETE:SUCCESS' ;
		ELSE
                    Handle_Err
                          (p_itemtype          => itemtype   ,
                           p_itemkey           => itemkey    ,
                           p_msg_count         => l_msg_count, -- Number of error Messages
                           p_msg_data          => l_msg_data ,
                           p_attr_name         => 'AMS_ERROR_MSG'
                              )               ;
			  result := 'COMPLETE:ERROR' ;
     		END IF ;
	    END IF ;
         END IF ;

    --  CANCEL mode  - Normal Process Execution
	 IF (funcmode = 'CANCEL')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;

	 --  TIMEOUT mode  - Normal Process Execution
	 IF (funcmode = 'TIMEOUT')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;
EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context(G_PKG_NAME,'Update_Status_Rej',itemtype,itemkey,actid,funcmode);
		  raise ;
END Update_Status_Rej ;

-- Start of Comments
--
-- NAME
--   Revert_Status
--
-- PURPOSE
--   This Procedure will Revert the Status of the Activity Back to Original
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_REVERT_STATUS
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Revert_Status	(itemtype    IN	  VARCHAR2,
		  				itemkey	 	 IN	  VARCHAR2,
						actid	     IN	  NUMBER,
						funcmode	 IN	  VARCHAR2,
						result       OUT NOCOPY  VARCHAR2) IS
  l_obj_type              VARCHAR2(30);
  l_tmp_stat_code         VARCHAR2(30);
  l_doc_type              VARCHAR2(30);
  l_requester_id          NUMBER ;
  l_orig_stat_id          NUMBER ;

  l_msg_count             NUMBER ;
  l_msg_data              VARCHAR2(2000);
  l_obj_id                NUMBER ;
  l_obj_version_number    NUMBER ;
  l_sys_stat_code         VARCHAR2(30);
  l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS ;
  l_approver              VARCHAR2(30);
  l_note                  VARCHAR2(2000);

  CURSOR c_sys_stat(l_user_stat_id NUMBER) IS
  SELECT    system_status_code
  FROM      ams_user_statuses_vl
  WHERE     user_status_id = l_user_stat_id ;

BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Process Revert Status');
   END IF;
   -- dbms_output.put_line('Process Revert Status');
	 --  RUN mode  - Normal Process Execution
	 IF (funcmode = 'RUN')
	 THEN

            l_obj_type    := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPROVAL_FOR_OBJECT');

            l_obj_id      := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_ACT_ID');
            l_obj_version_number := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_OBJECT_VERSION_NUMBER');

            l_orig_stat_id      := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_ORIG_STAT_ID');
           l_requester_id := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_REQUESTER_ID');
           l_doc_type := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPR_DOC_TYPE');

            l_approver := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPR_USERNAME');

            l_note := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_NOTE');



            OPEN  c_sys_stat(l_orig_stat_id) ;
            FETCH c_sys_stat INTO l_sys_stat_code ;
            CLOSE c_sys_stat ;

            -- Update the Notes which Approver has Given with Rejection
            IF l_note IS NOT NULL THEN
            Update_Note(p_obj_type      => l_obj_type,
                        p_obj_id        => l_obj_id,
                        p_note          => l_note,
                        p_user          => l_approver,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        x_return_status => l_return_status) ;

            END IF ;
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	           Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_ERROR_MSG'
                            )               ;
				  result := 'COMPLETE:ERROR' ;
            ELSE
               --
               -- Update Activity
               --
               Update_Status(p_obj_type          	 => l_obj_type,
		   	p_obj_id     			 => l_obj_id,
                        p_object_version_number  => l_obj_version_number,
			p_next_stat_code   	     => l_sys_stat_code, -- System Status
                        p_next_stat_id           => l_orig_stat_id,
                        p_appr_type              => l_doc_type,
                        p_submitted_by           => l_requester_id,
                        p_item_key               => itemkey,
                        x_msg_count              => l_msg_count,
                        x_msg_data               => l_msg_data,
						x_return_status   	   	 => l_return_status)  ;

			IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		   	   	    result := 'COMPLETE:SUCCESS' ;
			ELSE
                           Handle_Err
                            (p_itemtype          => itemtype   ,
                            p_itemkey           => itemkey    ,
                            p_msg_count         => l_msg_count, -- Number of error Messages
                            p_msg_data          => l_msg_data ,
                            p_attr_name         => 'AMS_ERROR_MSG'
                             )               ;
     			   result := 'COMPLETE:ERROR' ;
 		    END IF ;
            END IF;
	 END IF ;

    --  CANCEL mode  - Normal Process Execution
	 IF (funcmode = 'CANCEL')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;

	 --  TIMEOUT mode  - Normal Process Execution
	 IF (funcmode = 'TIMEOUT')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;
EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context(G_PKG_NAME,'Revert_Status',itemtype,itemkey,actid,funcmode);
		  raise ;
END Revert_Status ;

-- Start of Comments
--
-- NAME
--   Fund_Appr_Req_Check
--
-- PURPOSE
--   This Procedure will check whether the Budget Approval is required or not
--
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the approval is required
--	  		 - 'COMPLETE:N' If the approval is not required
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_CHECK_BUD_APPR
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Fund_Appr_Req_Check 	(itemtype    IN	  VARCHAR2,
  				 		itemkey	 	 IN	  VARCHAR2,
				 		actid	     IN	  NUMBER,
				 		funcmode	 IN	  VARCHAR2,
				 		result       OUT NOCOPY  VARCHAR2) IS
l_budget_appr_flag  VARCHAR2(1);
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Process Fund Appr Req_Check');
   END IF;
   -- dbms_output.put_line('Process Fund Appr Req_Check');
	 --  RUN mode  - Normal Process Execution
	 IF (funcmode = 'RUN')
	 THEN
	 	 	l_budget_appr_flag := WF_ENGINE.GetItemAttrText(
					   			   itemtype    =>    itemtype,
							   	   itemkey	   => 	 itemkey ,
							   	   aname	   =>	 'AMS_BUDGET_APPR_FLAG');
            IF l_budget_appr_flag = 'Y' THEN
                result := 'COMPLETE:Y' ;
            ELSE
                result := 'COMPLETE:N' ;
            END IF;

	 END IF;

	 --  CANCEL mode  - Normal Process Execution
	 IF (funcmode = 'CANCEL')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;

	 --  TIMEOUT mode  - Normal Process Execution
	 IF (funcmode = 'TIMEOUT')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;
-- dbms_output.put_line('End Update log');
EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context(G_PKG_NAME,'Fund_Appr_Req_Check',itemtype,itemkey,actid,funcmode);
		  raise ;
END Fund_Appr_Req_Check ;



-- Start of Comments
--
-- NAME
--   Ba_Owner_Appr_Check
--
-- PURPOSE
--   This Procedure will check whether the Owner's Approval is required for the Budget
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the Owner's Approval is required
--	  		 - 'COMPLETE:N' If the Owner's Approval is not required
--
--
-- OUT
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_CHECK_BA_OWN_APPR
-- NOTES
--
--
-- HISTORY
--   09/13/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Ba_Owner_Appr_Check 	(itemtype    IN	  VARCHAR2,
  				 		itemkey	 	 IN	  VARCHAR2,
				 		actid	     IN	  NUMBER,
				 		funcmode	 IN	  VARCHAR2,
				 		result       OUT NOCOPY  VARCHAR2) IS
	l_ba_appr_flag    VARCHAR2(1);
    l_owner           VARCHAR2(100);
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Process BA_OWNER_APPR_CHECK');
   END IF;
   -- dbms_output.put_line('Process BA_OWNER_APPR_CHECK');
	 --  RUN mode  - Normal Process Execution
	 IF (funcmode = 'RUN')
	 THEN
         	l_ba_appr_flag   := WF_ENGINE.GetItemAttrText(
							   itemtype    =>    itemtype,
						   	   itemkey	   => 	 itemkey ,
						   	   aname	   =>	 'AMS_TAOWNER_APPR_FLAG');
           	l_owner   := WF_ENGINE.GetItemAttrText(
	           				   itemtype    =>    itemtype,
						   	   itemkey	   => 	 itemkey ,
						   	   aname	   =>	 'AMS_OWNER');

            IF l_ba_appr_flag = 'Y' THEN

                   	WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
               					   			  itemkey 	 =>   itemkey,
               					   			  aname	 	 =>	  'AMS_APPR_USERNAME',
               					   			  avalue	 =>	  l_owner);

                    WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                        		   			  itemkey 	 =>   itemkey,
                        		   			  aname	 	 =>	  'AMS_BUDGET_APPR_FLAG',
                        		   			  avalue	 =>	  'N');
                    WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                        		   			  itemkey 	 =>   itemkey,
                        		   			  aname	 	 =>	  'AMS_TAOWNER_APPR_FLAG',
                            	   			  avalue	 =>	  'N');
                    WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                           		   			  itemkey 	 =>   itemkey,
                        		   			  aname	 	 =>	  'AMS_BAOWNER_APPR_FLAG',
                        		   			  avalue	 =>	  'N');
                    WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                           		   			  itemkey 	 =>   itemkey,
                        		   			  aname	 	 =>	  'AMS_THEME_APPR_FLAG',
                        		   			  avalue	 =>	  'Y');
                    WF_ENGINE.SetItemAttrText(itemtype	 =>	  itemtype ,
                           		   			  itemkey 	 =>   itemkey,
                        		   			  aname	 	 =>	  'AMS_APPR_DOC_TYPE',
                        		   			  avalue	 =>	  'BUDGET');

                    result := 'COMPLETE:Y' ;
            ELSE -- IF l_ba_appr_flag = 'N' THEN
                result := 'COMPLETE:N' ;
            END IF;
	 END IF;

	 --  CANCEL mode  - Normal Process Execution
	 IF (funcmode = 'CANCEL')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;

	 --  TIMEOUT mode  - Normal Process Execution
	 IF (funcmode = 'TIMEOUT')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;
-- dbms_output.put_line('End Update log');
EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context(G_PKG_NAME,'Ba_Owner_Appr_Check',itemtype,itemkey,actid,funcmode);
		  raise ;
END Ba_Owner_Appr_Check;


-- Start of Comments
--
-- NAME
--   Update_Stat_ApprBA
--
-- PURPOSE
--   This Procedure will Update the Status of the Activity for Approval
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_UPDATE_STATUS_BA
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Update_Stat_ApprBA (itemtype    IN	  VARCHAR2,
		  			     	itemkey	 	 IN	  VARCHAR2,
    						actid	     IN	  NUMBER,
    						funcmode	 IN	  VARCHAR2,
    						result       OUT NOCOPY  VARCHAR2) IS

  l_obj_type              VARCHAR2(30);
  l_next_stat_id          NUMBER ;

  l_msg_count             NUMBER ;
  l_msg_data              VARCHAR2(2000);
  l_obj_id                NUMBER ;
  l_obj_version_number    NUMBER ;
  l_requester_id          NUMBER ;
  l_doc_type              VARCHAR2(30);
  l_sys_stat_code         VARCHAR2(30);
  l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS ;
  l_approver              VARCHAR2(30);
  l_note                  VARCHAR2(2000);

  CURSOR c_sys_stat(l_user_stat_id NUMBER) IS
  SELECT    system_status_code
  FROM      ams_user_statuses_vl
  WHERE     user_status_id = l_user_stat_id ;

BEGIN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_Utility_PVT.debug_message('Process Update Status APPRBA');
     END IF;
     -- dbms_output.put_line('Process Update Status APPRBA');
	 --  RUN mode  - Normal Process Execution
	 IF (funcmode = 'RUN')
	 THEN

            l_obj_type    := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPROVAL_FOR_OBJECT');

            l_obj_id      := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_ACT_ID');
            l_obj_version_number := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_OBJECT_VERSION_NUMBER');
            l_next_stat_id := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_NEW_STAT_ID');
            l_requester_id := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_REQUESTER_ID');
            l_doc_type := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPR_DOC_TYPE');

            OPEN  c_sys_stat(l_next_stat_id) ;
            FETCH c_sys_stat INTO l_sys_stat_code ;
            CLOSE c_sys_stat ;


            l_approver := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_APPR_USERNAME');

            l_note := wf_engine.GetItemAttrText(
							  	 itemtype => ItemType,
							  	 itemkey  => ItemKey,
							  	 aname    => 'AMS_NOTE');


            -- Update the Notes which Approver has Given with Rejection
            IF l_note IS NOT NULL THEN
                 Update_Note(p_obj_type      => l_obj_type,
                        p_obj_id        => l_obj_id,
                        p_note          => l_note,
                        p_user          => l_approver,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        x_return_status => l_return_status) ;

            END IF ;
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	           Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_ERROR_MSG'
                            )               ;
		  result := 'COMPLETE:ERROR' ;
            ELSE
              --
              -- Update Activity
              --
              Update_Status(p_obj_type          	 => l_obj_type,
       	  	   	p_obj_id     		 => l_obj_id,
                        p_object_version_number  => l_obj_version_number,
  			p_next_stat_code         => l_sys_stat_code, --System Status
                        p_next_stat_id           => l_next_stat_id,
                        p_appr_type              => l_doc_type,
                        p_submitted_by           => l_requester_id,
                        p_item_key               => itemkey ,
                        x_msg_count              => l_msg_count,
                        x_msg_data               => l_msg_data,
			x_return_status   	 => l_return_status)  ;

       		IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                -- Update the Attribute to show that Theme Approval is Completed
                    Update_Attribute(p_obj_type      => l_obj_type,
   			   	     p_obj_id        => l_obj_id,
                                     p_obj_attr      => 'BAPL',
                                     x_msg_count     => l_msg_count,
                                     x_msg_data      => l_msg_data,
                                     x_return_status => l_return_status)  ;

                  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                      result := 'COMPLETE:SUCCESS' ;
                  ELSE
                    Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_ERROR_MSG'
                            )               ;
                    result := 'COMPLETE:ERROR' ;
                  END IF;
   		   	   	    result := 'COMPLETE:SUCCESS' ;
		ELSE
                    Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_ERROR_MSG'
                            )               ;
   				  result := 'COMPLETE:ERROR' ;
   		END IF ;
            END IF ;
   	 END IF ;

    --  CANCEL mode  - Normal Process Execution
	 IF (funcmode = 'CANCEL')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;

	 --  TIMEOUT mode  - Normal Process Execution
	 IF (funcmode = 'TIMEOUT')
	 THEN
	 	result := 'COMPLETE:' ;
		RETURN;
	 END IF;
EXCEPTION
	 WHEN OTHERS THEN
	 	  wf_core.context(G_PKG_NAME,'Update_Stat_ApprBA',itemtype,itemkey,actid,funcmode);
		  raise ;
END Update_Stat_ApprBA ;


-- Start of Comments
--
-- NAME
--   AbortProcess
--
-- PURPOSE
--   This Procedure will abort the process of Approvals
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   09/13/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE AbortProcess
		   (p_itemkey         			IN   VARCHAR2
		   ,p_workflowprocess			IN	 VARCHAR2 	DEFAULT NULL
		   ,p_itemtype					IN	 VARCHAR2 	DEFAULT NULL
		   )
IS
    itemkey   VARCHAR2(30) := p_itemkey ;
    itemtype  VARCHAR2(30) := nvl(p_itemtype,'AMSAPPR') ;
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Process Abort Process');
   END IF;
   -- dbms_output.put_line('Process Abort Process');

	 WF_ENGINE.AbortProcess (itemtype   =>   itemtype,
						 	 itemkey 	 =>  itemkey ,
						 	 process 	 =>  p_workflowprocess);

-- dbms_output.put_line('After Aborting Process ');
EXCEPTION
     WHEN OTHERS
     THEN
        wf_core.context ('AMS_WfCmpApr_PVT', 'AbortProcess',itemtype,itemkey
                                                          ,p_workflowprocess);
         RAISE;

END AbortProcess;



END AMS_WfCmpApr_PVT ;


/
