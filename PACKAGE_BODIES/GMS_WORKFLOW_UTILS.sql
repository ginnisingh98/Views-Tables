--------------------------------------------------------
--  DDL for Package Body GMS_WORKFLOW_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_WORKFLOW_UTILS" AS
/* $Header: gmsfutlb.pls 115.4 2002/11/19 20:08:24 jmuthuku ship $ */

-- -------------------------------------------------------------------------------------
-- GLOBAL CONSTANTS
-- -------------------------------------------------------------------------------------

G_USER_ID  	  	CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID	  	CONSTANT NUMBER := FND_GLOBAL.login_id;
G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;


-- -------------------------------------------------------------------------------------
--  PROCEDURES
-- -------------------------------------------------------------------------------------

--Name: 		Insert_WF_Processes
--Type:               	Procedure
--Description:      	This procedure inserts rows into the gms_wf_processes
--			table for the start_approval procedures.
--
--
--Called subprograms:	none.
--
--
--
--History:
--
-- IN Parameters
-- p_wf_type_code		- Entity invoking workflow, i.e., 'BUDGET', 'PROJECT'.
-- p_item_type			- Workflow Name, i.e., 'GMSBUDWF'
-- p_item_key			- Workflow process indentifer
-- p_entity_key1		- Primary key of calling entity, i.e., project_id, award_id,
--				   budget_version_id, etc.
-- p_entity_key2		- Supplemental primary key for calling entity. Typically,
--				  used to store baselined budget_version_id.
--
-- OUT NOCOPY Parameters
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--   				   x > 0, Business Rule Violated.
--   p_err_stage			-  Standard error message
--   p_err_stack			-   Not used

PROCEDURE Insert_WF_Processes
(p_wf_type_code		IN	VARCHAR2
, p_item_type		IN	VARCHAR2
, p_item_key		IN	VARCHAR2
, p_entity_key1		IN	VARCHAR2
, p_entity_key2		IN	VARCHAR2 := GMS_BUDGET_PUB.G_PA_MISS_CHAR
, p_description		IN	VARCHAR2 := GMS_BUDGET_PUB.G_PA_MISS_CHAR
, p_err_code            IN OUT NOCOPY	NUMBER
, p_err_stage		IN OUT NOCOPY	VARCHAR2
, p_err_stack		IN OUT NOCOPY	VARCHAR2
)

IS
--

	l_entity_key2	gms_wf_processes.entity_key2%TYPE;
	l_description	gms_wf_processes.description%TYPE;

BEGIN

--  Standard Begin of API Savepoint

    SAVEPOINT Insert_WF_Processes_pvt;

--  Set API Return Status to Success

 	p_err_code	:= 0;

-- Value-Id Layer --------------------------------------------------------------

IF (p_entity_key2 = GMS_BUDGET_PUB.G_PA_MISS_CHAR)
THEN
	l_entity_key2 := 0;
ELSE
	l_entity_key2 := p_entity_key2;
END IF;

IF (p_description = GMS_BUDGET_PUB.G_PA_MISS_CHAR)
THEN
	l_description := NULL;
ELSE
	l_description := p_description;
END IF;

-- ----------------------------------------------------------------------------------


    INSERT INTO gms_wf_processes
		   	(wf_type_code
			, item_type
		 	, item_key
			, entity_key1
			, entity_key2
			, description
		   	, last_update_date
			, last_updated_by
			, creation_date
			, created_by
			, last_update_login
			 )
			VALUES
			(p_wf_type_code
			, p_item_type
		 	, p_item_key
			, p_entity_key1
			, l_entity_key2
			, l_description
			, sysdate
			, fnd_global.user_id
			, sysdate
			, fnd_global.user_id
			, fnd_global.login_id
		 	);

EXCEPTION

	WHEN OTHERS
	 THEN
		p_err_code 	:= SQLCODE;
		ROLLBACK TO Insert_WF_Processes_pvt;
		WF_CORE.CONTEXT('GMS_WORKFLOW_UTILS','INSERT_WF_PROCESSES', p_item_type, p_item_key );
		RAISE;

END Insert_WF_Processes;

-- ==================================================

PROCEDURE Set_Global_Attr (p_item_type  IN VARCHAR2,
                           p_item_key   IN VARCHAR2,
                           p_err_code  OUT NOCOPY VARCHAR2) IS

l_resp_id                 NUMBER := 0;
l_workflow_started_by_id  NUMBER := 0;
l_msg_count               NUMBER := 0;
l_msg_data                VARCHAR2(500) := 0;
l_data                    VARCHAR2(500) := 0;
l_return_status           VARCHAR2(1) ;
l_msg_index_out           NUMBER;

BEGIN

p_err_code := 0;
l_resp_id := wf_engine.GetItemAttrNumber
            (itemtype  	=> p_item_type,
	     itemkey   	=> p_item_key,
    	     aname  	=> 'RESPONSIBILITY_ID' );

l_workflow_started_by_id := wf_engine.GetItemAttrNumber
               (itemtype => p_item_type,
                itemkey  => p_item_key,
                aname    => 'WORKFLOW_STARTED_BY_ID' );

-- Based on the Responsibility, Intialize the Application
FND_GLOBAL.Apps_Initialize
	(user_id         	=> l_workflow_started_by_id
	  , resp_id         	=> l_resp_id
	  , resp_appl_id	=> gms_workflow_utils.get_application_id(l_resp_id)
	);


EXCEPTION

WHEN OTHERS
   THEN
	 p_err_code := SQLCODE;
	WF_CORE.CONTEXT('GMS_WORKFLOW_UTILS','SET_GLOBAL_ATTR', p_item_type, p_item_key );
	RAISE;

END Set_Global_Attr;

-- ==================================================

--Name: 		Set_Notification_Messages
--Type:               	Procedure
--Description:      This procedure populates ten error message
--		attributes in the calling WF.
--
--
--Called subprograms:	none.
--
--
--
--History:
--
-- IN Parameters
--   p_item_type		- WF item type
--   p_item_key		- WF item key.
--
--

PROCEDURE Set_Notification_Messages
(p_item_type IN VARCHAR2
 , p_item_key  IN VARCHAR2
)
--
IS
--
l_attr_name   VARCHAR2(30);
l_msg_count   NUMBER := 0;
l_msg_text    VARCHAR2(2000)		:= NULL;
l_encoded_mesg VARCHAR2(2000);

BEGIN

-- Get l_msg_count for Subsequent Processing
     l_msg_count := FND_MSG_PUB.COUNT_MSG;

-- Intialize First Ten WF Error Message Attributes

FOR i IN 1..10 LOOP
	l_attr_name := 'RULE_NOTE_'||i;
	wf_engine.SetItemAttrText
	 (itemtype	=> p_item_type
	   , itemkey  	=> p_item_key
	   , aname 	=> l_attr_name
	   , avalue	=> l_msg_text
	   );
END LOOP;

-- Populate WF Error Message Attributes with Messages, if any.

IF l_msg_count > 0 THEN
        FOR i IN 1..l_msg_count LOOP
           IF i > 10 THEN
              EXIT;
           END IF;
           l_encoded_mesg := fnd_msg_pub.get
                            (p_msg_index => i,
                             p_encoded   => FND_API.G_TRUE);
           fnd_message.set_encoded (encoded_message => l_encoded_mesg);
           l_msg_text := Fnd_Message.Get;
           l_attr_name := 'RULE_NOTE_'||i;
          wf_engine.SetItemAttrText (itemtype	=> p_item_type,
				      itemkey  	=> p_item_key,
				      aname 	=> l_attr_name,
				      avalue	=> l_msg_text );
         END LOOP;
     END IF;

EXCEPTION
	 WHEN OTHERS
	  THEN
	WF_CORE.CONTEXT('GMS_WORKFLOW_UTILS','SET_NOTIFICATION_MESSAGES', p_item_type, p_item_key );
		RAISE;

END Set_Notification_Messages;
-- ==================================================

--
--  FUNCTION
--              get_application_id
--  PURPOSE
--              This function retrieves the application id of a responsibility.
--              If no application id is found, null is returned.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--
function get_application_id (x_responsibility_id  IN number) return number
is
   cursor c1 is
   		 select application_id
   		 from fnd_responsibility
   		 where responsibility_id = x_responsibility_id;

    c1_rec c1%rowtype;

begin
   open c1;
   fetch c1 into c1_rec;
   if c1%notfound then
           close c1;
           return( null);
   else
           close c1;
           return( c1_rec.application_id);
   end if;

exception
   when others then
   return(SQLCODE);

end get_application_id;

-- ==================================================

END gms_workflow_utils;

/
