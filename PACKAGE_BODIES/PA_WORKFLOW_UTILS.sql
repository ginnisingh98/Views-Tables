--------------------------------------------------------
--  DDL for Package Body PA_WORKFLOW_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WORKFLOW_UTILS" AS
/* $Header: PAWFUTLB.pls 120.3.12010000.4 2009/09/18 06:50:17 jravisha ship $ */

-- -------------------------------------------------------------------------------------
-- GLOBAL CONSTANTS
-- -------------------------------------------------------------------------------------

G_USER_ID  	  CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID	  CONSTANT NUMBER := FND_GLOBAL.login_id;
G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;

g_module_name    VARCHAR2(100) := 'pa_workflow_utils';



-- -------------------------------------------------------------------------------------
--  PROCEDURES
-- -------------------------------------------------------------------------------------

--Name: 		Insert_WF_Processes
--Type:               	Procedure
--Description:      This procedure inserts rows into the pa_wf_processes
--		table for the start_approval procedures.
--
--
--Called subprograms:	none.
--
--
--
--History:
--	14-JUL-97	jwhite		Updated to lastest specs
--	12-AUG-97	jwhite		Added new IN-parameters, p_wf_type_code and
--					p_description, to 	Insert_WF_Processes.
--
-- IN Parameters
-- p_wf_type_code		- Entity invoking workflow, i.e., 'BUDGET', 'PROJECT'.
-- p_item_type			- Workflow Name, i.e., 'PABUDWF'
-- p_item_key			- Workflow process indentifer
-- p_entity_key1			- Primary key of calling entity, i.e., project_id,
--				   budget_version_id, etc.
-- p_entity_key2			- Supplemental primary key for calling entity. Typically,
--				  used to store baselined budget_version_id.
--
-- OUT Parameters
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--   				   x > 0, Business Rule Violated.
--   p_err_stage			-  Standard error message
--   p_err_stack			-   Not used

PROCEDURE Insert_WF_Processes
(p_wf_type_code		IN	VARCHAR2
, p_item_type		IN	VARCHAR2
, p_item_key		IN	VARCHAR2
, p_entity_key1		IN	VARCHAR2
, p_entity_key2		IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_description		IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_err_code            IN OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_err_stage		IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_err_stack		IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS
--

	l_entity_key2	pa_wf_processes.entity_key2%TYPE;
	l_description	pa_wf_processes.description%TYPE;
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Procedure Insert_WF_Processes - Begin';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Input Parameters : ' || ' p_wf_type_code ' || p_wf_type_code;
       PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_item_type '    || p_item_type;
       PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_entity_key1 '  || p_entity_key1;
       PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_entity_key2 '  || p_entity_key2;
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

--  Standard Begin of API Savepoint

    SAVEPOINT Insert_WF_Processes_pvt;

--  Set API Return Status to Success

 	p_err_code	:= 0;

-- Value-Id Layer --------------------------------------------------------------

IF (p_entity_key2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
THEN
	l_entity_key2 := '0'; -- Bug 7170228

        /* Bug fix:5246812: When p_entity_key2 is NULL, throws
        :ORA-01400: cannot insert NULL into (PA."PA_WF_PROCESSES.ENTITY_KEY2)
        */
  -- Bug#7517187
--ELSIF (p_entity_key2 is NULL OR p_entity_key2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) Then
  ELSIF (p_entity_key2 is NULL) Then
        l_entity_key2 := '-99';    -- Bug 7170228
        /* end of bug fix:5246812 */

ELSE
	l_entity_key2 := p_entity_key2;
END IF;

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := ' l_entity_key2 ' || l_entity_key2;
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

IF (p_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
THEN
	l_description := NULL;
ELSE
	l_description := p_description;
END IF;

-- ----------------------------------------------------------------------------------
        IF P_PA_DEBUG_MODE = 'Y' Then
            pa_debug.g_err_stage := 'LOG:'||'Inserting into pa_wf_processes: wf_type_code['||p_wf_type_code||']';
            pa_debug.g_err_stage := pa_debug.g_err_stage||'ItemType['||p_item_type||']ItemKey['||p_item_key||']';
            pa_debug.g_err_stage := pa_debug.g_err_stage||'Key1['||p_entity_key1||']Key2['||l_entity_key2||']';
            PA_DEBUG.write
                (x_Module       => 'pa_workflow_utils.Insert_WF_Processes'
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
        END IF;

    INSERT INTO pa_wf_processes
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

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Procedure Insert_WF_Processes - End';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

EXCEPTION

	WHEN OTHERS
	 THEN
		p_err_code 	:= SQLCODE;
		ROLLBACK TO Insert_WF_Processes_pvt;
		WF_CORE.CONTEXT('PA_WORKFLOW_UTILS','INSERT_WF_PROCESSES', p_item_type, p_item_key );
		RAISE;

END Insert_WF_Processes;

-- ==================================================

PROCEDURE Set_Global_Attr (p_item_type  IN VARCHAR2,
                           p_item_key   IN VARCHAR2,
                           p_err_code  OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_resp_id                 NUMBER := 0;
l_workflow_started_by_id  NUMBER := 0;
l_msg_count               NUMBER := 0;
l_msg_data                VARCHAR2(500) := 0;
l_data                    VARCHAR2(500) := 0;
l_return_status           VARCHAR2(1) ;
l_msg_index_out           NUMBER;
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Procedure Set_Global_Attr - Begin';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Input Parameters : ' || ' p_item_type ' || p_item_type;
       PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_item_key '  || p_item_key;
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

p_err_code := 0;
l_resp_id := wf_engine.GetItemAttrNumber
            (itemtype  	=> p_item_type,
	     itemkey   	=> p_item_key,
    	     aname  	=> 'RESPONSIBILITY_ID' );

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := ' l_resp_id ' || l_resp_id;
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

l_workflow_started_by_id := wf_engine.GetItemAttrNumber
               (itemtype => p_item_type,
                itemkey  => p_item_key,
                aname    => 'WORKFLOW_STARTED_BY_ID' );

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := ' l_workflow_started_by_id ' || l_workflow_started_by_id;
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

-- Based on the Responsibility, Intialize the Application
FND_GLOBAL.Apps_Initialize
	(user_id         	=> l_workflow_started_by_id
	  , resp_id         	=> l_resp_id
	  , resp_appl_id	=> pa_workflow_utils.get_application_id(l_resp_id)
	);

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Procedure Set_Global_Attr - End';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;


EXCEPTION

WHEN OTHERS
   THEN
	 p_err_code := SQLCODE;
	WF_CORE.CONTEXT('PA_WORKFLOW_UTILS','SET_GLOBAL_ATTR', p_item_type, p_item_key );
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
--	XX-AUT-97	rkrishna		- Created
--	24-OCT-97	jwhite		- Added intialization code
--					  for error message attributes.
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

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Procedure Set_Notification_Messages - Begin';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Input Parameters : ' || ' p_item_type ' || p_item_type;
       PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_item_key '  || p_item_key;
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

-- Get l_msg_count for Subsequent Processing
     l_msg_count := FND_MSG_PUB.COUNT_MSG;

-- Intialize First Ten WF Error Message Attributes

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := ' Calling wf_engine.SetItemAttrText in loop - Start ';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;
FOR i IN 1..10 LOOP
	l_attr_name := 'RULE_NOTE_'||i;
	wf_engine.SetItemAttrText
	 (itemtype	=> p_item_type
	   , itemkey  	=> p_item_key
	   , aname 	=> l_attr_name
	   , avalue	=> l_msg_text
	   );
END LOOP;
    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := ' Calling wf_engine.SetItemAttrText in loop - END ';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

-- Populate WF Error Message Attributes with Messages, if any.

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := ' Populate WF Error Message Attributes with Messages in loop - Start ';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;
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
    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := ' Populate WF Error Message Attributes with Messages in loop - End ';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Procedure Set_Notification_Messages - End';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

EXCEPTION
	 WHEN OTHERS
	  THEN
	WF_CORE.CONTEXT('PA_WORKFLOW_UTILS','SET_NOTIFICATION_MESSAGES', p_item_type, p_item_key );
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
--   02-SEP-99      sbalasub   Created
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

PROCEDURE get_workflow_info (
			     p_project_status_code        IN     VARCHAR2
			     ,p_project_status_type        IN     VARCHAR2
			     ,x_enable_wf_flag out NOCOPY varchar2 --File.Sql.39 bug 4440895
			     ,x_workflow_item_type out NOCOPY varchar2 --File.Sql.39 bug 4440895
			     ,x_workflow_process OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
			     ,x_wf_success_status_code OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
			     ,x_wf_failure_status_code OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			     , x_msg_count      out     NOCOPY NUMBER --File.Sql.39 bug 4440895
			     , x_msg_data       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			     , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			     )
  IS


  CURSOR get_info IS
     SELECT
       enable_wf_flag,
       workflow_item_type,
       workflow_process,
       wf_success_status_code,
       wf_failure_status_code
       FROM pa_project_statuses
       WHERE
       status_type = p_project_status_type
       AND
       project_status_code = p_project_status_code;
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Procedure get_workflow_info - Begin';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Input Parameters : ' || ' p_project_status_code ' || p_project_status_code;
       PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_project_status_type ' || p_project_status_type;
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN get_info;
   FETCH get_info INTO
     x_enable_wf_flag,
     x_workflow_item_type
     ,x_workflow_process
     ,x_wf_success_status_code
     ,x_wf_failure_status_code ;
   CLOSE get_info;

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Procedure get_workflow_info - End';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

EXCEPTION
   WHEN OTHERS
     THEN
      x_msg_count := 1;
      x_msg_data := substr(SQLERRM,1,2000);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


end;


  Procedure  Cancel_Workflow
	  (  p_Item_type         IN     VARCHAR2
	   , p_Item_key        IN     VARCHAR2
	   , x_msg_count       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
	   , x_msg_data        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	   , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         )

	  IS

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

        BEGIN

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Procedure Cancel_Workflow - Begin';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Input Parameters : ' || ' p_Item_type ' || p_Item_type;
       PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_Item_key '  || p_Item_key;
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;


        x_return_status := FND_API.G_RET_STS_SUCCESS;

	--debug_msg ( 'after client cancel_workflow call' );

	IF (x_return_status = FND_API.g_ret_sts_success) THEN
	   WF_ENGINE.AbortProcess(  p_Item_Type
				    , p_Item_Key
				    );

	   --debug_msg ( 'after WF_ENGINE abortProcess' );

	   --debug_msg ('before get task_id');

	END IF;

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Procedure Cancel_Workflow - End';
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;


	EXCEPTION

	   WHEN OTHERS THEN
	      --debug_msg ( 'Exception in Cancel_Wf ' || substr(SQLERRM,1,2000) );

	      x_msg_count := 1;
	      x_msg_data := substr(SQLERRM,1,2000);
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Cancel_workflow;


	   Procedure  create_workflow_process (
					       p_item_type         IN     VARCHAR2
					       , p_process_name      IN     VARCHAR2
					       , x_item_key       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					       , x_msg_count      out     NOCOPY NUMBER --File.Sql.39 bug 4440895
					       , x_msg_data       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					       , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					       )
	     IS

		l_item_key NUMBER;
           P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

	   BEGIN
              IF P_PA_DEBUG_MODE = 'Y' Then
                 PA_DEBUG.g_err_stage := 'Procedure create_workflow_process - Begin';
                 PA_DEBUG.write
                          (x_Module       => g_module_name
                          ,x_Msg          => pa_debug.g_err_stage
                          ,x_Log_Level    => 3);
              END IF;

    IF P_PA_DEBUG_MODE = 'Y' Then
       PA_DEBUG.g_err_stage := 'Input Parameters : ' || ' p_Item_type '     || p_Item_type;
       PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_process_name '  || p_process_name;
       PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
    END IF;
	      SELECT pa_workflow_itemkey_s.nextval
		INTO l_item_key
		from dual;

	      x_item_key := To_char(l_item_key);

	      x_return_status := FND_API.G_RET_STS_SUCCESS;

	      -- create the workflow process
              IF P_PA_DEBUG_MODE = 'Y' Then
                 PA_DEBUG.g_err_stage := 'Calling WF_ENGINE.CreateProcess - Start';
                 PA_DEBUG.write
                          (x_Module       => g_module_name
                          ,x_Msg          => pa_debug.g_err_stage
                          ,x_Log_Level    => 3);
              END IF;
	      WF_ENGINE.CreateProcess(    p_item_type
					  , x_item_key
					  , p_Process_Name);
              IF P_PA_DEBUG_MODE = 'Y' Then
                 PA_DEBUG.g_err_stage := 'Calling WF_ENGINE.CreateProcess - End';
                 PA_DEBUG.write
                          (x_Module       => g_module_name
                          ,x_Msg          => pa_debug.g_err_stage
                          ,x_Log_Level    => 3);
              END IF;

              IF P_PA_DEBUG_MODE = 'Y' Then
                 PA_DEBUG.g_err_stage := 'Procedure create_workflow_process - End';
                 PA_DEBUG.write
                          (x_Module       => g_module_name
                          ,x_Msg          => pa_debug.g_err_stage
                          ,x_Log_Level    => 3);
              END IF;
	      --debug_msg ( 'after WF_ENGINE createProcess: key = '  || x_item_key)

	   EXCEPTION

	   WHEN OTHERS THEN
	      --debug_msg ( 'Exception ' || substr(SQLERRM,1,2000)  );


	      x_msg_count := 1;
	      x_msg_data := substr(SQLERRM,1,2000);
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;




	   END ;

	   procedure  start_workflow_process (
				   p_item_type         IN     VARCHAR2
				   , p_process_name      IN     VARCHAR2
				   , p_item_key        IN     number
				   , p_wf_type_code         IN   VARCHAR2
				   , p_entity_key1          IN   VARCHAR2
				   , p_entity_key2          IN   VARCHAR2
				   , p_description          IN   VARCHAR2
				   , x_msg_count      out     NOCOPY NUMBER --File.Sql.39 bug 4440895
				   , x_msg_data       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				   , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				   )
	     IS
		l_err_code NUMBER;
		l_err_stage VARCHAR2(30);
		l_err_stack VARCHAR2(240);
                P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

		     BEGIN
                        IF P_PA_DEBUG_MODE = 'Y' Then
                           PA_DEBUG.g_err_stage := 'Procedure start_workflow_process - Begin';
                           PA_DEBUG.write
                                    (x_Module       => g_module_name
                                    ,x_Msg          => pa_debug.g_err_stage
                                    ,x_Log_Level    => 3);
                        END IF;

                        IF P_PA_DEBUG_MODE = 'Y' Then
                           PA_DEBUG.g_err_stage := 'Input Parameters : ' || ' p_Item_type '    || p_Item_type;
                           PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_process_name ' || p_process_name;
                           PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_Item_key '     || p_Item_key;
                           PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_wf_type_code ' || p_wf_type_code;
                           PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_entity_key1 '  || p_entity_key1 ;
                           PA_DEBUG.g_err_stage := PA_DEBUG.g_err_stage  || ' p_entity_key2 '  || p_entity_key2 ;
                           PA_DEBUG.write
                                    (x_Module       => g_module_name
                                    ,x_Msg          => pa_debug.g_err_stage
                                    ,x_Log_Level    => 3);
                        END IF;

                        IF P_PA_DEBUG_MODE = 'Y' Then
                           PA_DEBUG.g_err_stage := 'WF_ENGINE.StartProcess - Begin';
                           PA_DEBUG.write
                                    (x_Module       => g_module_name
                                    ,x_Msg          => pa_debug.g_err_stage
                                    ,x_Log_Level    => 3);
                        END IF;
			  WF_ENGINE.StartProcess(
				     p_Item_Type
				     , p_Item_Key
						 );
                        IF P_PA_DEBUG_MODE = 'Y' Then
                           PA_DEBUG.g_err_stage := 'WF_ENGINE.StartProcess - End';
                           PA_DEBUG.write
                                    (x_Module       => g_module_name
                                    ,x_Msg          => pa_debug.g_err_stage
                                    ,x_Log_Level    => 3);
                        END IF;

                        IF P_PA_DEBUG_MODE = 'Y' Then
                           PA_DEBUG.g_err_stage := 'PA_WORKFLOW_UTILS.Insert_WF_Processes - Begin';
                           PA_DEBUG.write
                                    (x_Module       => g_module_name
                                    ,x_Msg          => pa_debug.g_err_stage
                                    ,x_Log_Level    => 3);
                        END IF;

			  PA_WORKFLOW_UTILS.Insert_WF_Processes
			    (p_wf_type_code           => p_wf_type_code
			     ,p_item_type              => p_item_type
			     ,p_item_key               => p_item_key
			     ,p_entity_key1            => p_entity_key1
			     ,p_entity_key2            => p_entity_key2
			     ,p_description            => p_description
			     ,p_err_code               => l_err_code
			     ,p_err_stage              => l_err_stage
			     ,p_err_stack              => l_err_stack
			     );
                        IF P_PA_DEBUG_MODE = 'Y' Then
                           PA_DEBUG.g_err_stage := 'PA_WORKFLOW_UTILS.Insert_WF_Processes - End';
                           PA_DEBUG.write
                                    (x_Module       => g_module_name
                                    ,x_Msg          => pa_debug.g_err_stage
                                    ,x_Log_Level    => 3);
                        END IF;

			  IF l_err_code <> 0 THEN

			     PA_UTILS.Add_Message( p_app_short_name => 'PA'
						   ,p_msg_name       => 'PA_PR_CREATE_WF_FAILED');
			     x_return_status := FND_API.G_RET_STS_ERROR;


                        IF P_PA_DEBUG_MODE = 'Y' Then
                           PA_DEBUG.g_err_stage := ' WF_ENGINE.AbortProcess - Begin';
                           PA_DEBUG.write
                                    (x_Module       => g_module_name
                                    ,x_Msg          => pa_debug.g_err_stage
                                    ,x_Log_Level    => 3);
                        END IF;
			     -- abort the workflow process just launched, there is a problem
			     WF_ENGINE.AbortProcess(  p_Item_Type
						      , p_Item_Key
						      );

                        IF P_PA_DEBUG_MODE = 'Y' Then
                           PA_DEBUG.g_err_stage := ' WF_ENGINE.AbortProcess - End';
                           PA_DEBUG.write
                                    (x_Module       => g_module_name
                                    ,x_Msg          => pa_debug.g_err_stage
                                    ,x_Log_Level    => 3);
                        END IF;

			  END IF;

                        IF P_PA_DEBUG_MODE = 'Y' Then
                           PA_DEBUG.g_err_stage := 'Procedure start_workflow_process - End';
                           PA_DEBUG.write
                                    (x_Module       => g_module_name
                                    ,x_Msg          => pa_debug.g_err_stage
                                    ,x_Log_Level    => 3);
                        END IF;

		     EXCEPTION

			WHEN OTHERS THEN
			   --debug_msg ( 'Exception ' || substr(SQLERRM,1,2000)  );


			   x_msg_count := 1;
			   x_msg_data := substr(SQLERRM,1,2000);
			   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		     end;


 /* Bug 3787169. This API takes of removing class attributes from the html
    before using the same in workflow. Further this api removes the
    base and the style tags from html.
 */
PROCEDURE modify_wf_clob_content
   (  p_document             IN OUT NOCOPY pa_page_contents.page_content%TYPE
     ,x_return_status           OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT        NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT        NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_error_msg_code                VARCHAR2(30);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);
l_module_name                   VARCHAR2(100) := 'pa.plsql.PA_WORKFLOW_UTILS';

l_class_attr  constant varchar2(7) := 'class="';
l_end_quote   constant varchar2(1) := '"';
l_start_index number;
l_end_index   number;
l_amount      number;

BASE_TAG varchar2(5)  :='<base';
END_TAG  varchar2(1)  := '>';

STYLE_TAG varchar2(22)  := '<link rel="stylesheet"';

INPUT_TAG  constant varchar2(6) := '<input';
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
        IF P_PA_DEBUG_MODE = 'Y' Then
           PA_DEBUG.g_err_stage := 'Procedure modify_wf_clob_content - Begin';
           PA_DEBUG.write
                    (x_Module       => g_module_name
                    ,x_Msg          => pa_debug.g_err_stage
                    ,x_Log_Level    => 3);
        END IF;
       /* IF P_PA_DEBUG_MODE = 'Y' Then
           PA_DEBUG.g_err_stage := 'Input Parameters : ' || ' p_document '    || p_document;
           PA_DEBUG.write
                    (x_Module       => g_module_name
                    ,x_Msg          => pa_debug.g_err_stage
                    ,x_Log_Level    => 3);
        END IF;*/ /*commented for bug 8915991 */
	x_msg_count := 0;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	pa_debug.set_err_stack('PA_WORKFLOW_UTILS.modify_wf_clob_content');
	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
	l_debug_mode := NVL(l_debug_mode, 'Y');
	pa_debug.set_process('PLSQL','LOG',l_debug_mode);
	l_start_index := dbms_lob.instr(p_document,l_class_attr,1,1);
    while l_start_index <> 0 loop
            l_end_index := dbms_lob.instr(p_document,l_end_quote,l_start_index+length(l_class_attr),1);
			l_amount := l_end_index-l_start_index+1;
			dbms_lob.erase(p_document,l_amount,l_start_index);
            l_start_index := dbms_lob.instr(p_document,l_class_attr,l_end_index,1);
    end loop;

    --Identify the start and the end indices of the base tag and erase it from
    --the clob contents.
    l_start_index := dbms_lob.instr(p_document,BASE_TAG,1,1);

    -- dbms_lob will throw error if l_start_index <> 0 is not present  -- changes commented for bug 4350867
--    if(l_start_index <> 0) then -- Added If condition for 4289078
 --   l_end_index   := dbms_lob.instr(p_document,END_TAG,l_start_index,1);
  --  l_amount := l_end_index-l_start_index+1;
 --   dbms_lob.erase(p_document,l_amount,l_start_index);
 --   end if;

    --Identify the start and the end indices of the style sheet tag and erase it from
    --the clob contents.
    l_start_index := dbms_lob.instr(p_document,STYLE_TAG,1,1);
    if(l_start_index <> 0) then -- Added If condition for 4289078
    l_end_index   := dbms_lob.instr(p_document,END_TAG,l_start_index,1);
    l_amount := l_end_index-l_start_index+1;
    dbms_lob.erase(p_document,l_amount,l_start_index);
    end if;

    --Identify the start and the end indices of the input tag and erase it from
    --the clob contents.
    l_start_index := dbms_lob.instr(p_document,INPUT_TAG,1,1);
    while l_start_index <> 0 loop
            l_end_index := dbms_lob.instr(p_document,END_TAG,l_start_index+length(INPUT_TAG),1);
       	    l_amount := l_end_index-l_start_index+1;
	    dbms_lob.erase(p_document,l_amount,l_start_index);
            l_start_index := dbms_lob.instr(p_document,INPUT_TAG,l_end_index,1);
    end loop;
	pa_debug.reset_err_stack;

        IF P_PA_DEBUG_MODE = 'Y' Then
           PA_DEBUG.g_err_stage := 'Procedure modify_wf_clob_content - End';
           PA_DEBUG.write
                    (x_Module       => g_module_name
                    ,x_Msg          => pa_debug.g_err_stage
                    ,x_Log_Level    => 3);
        END IF;

  EXCEPTION
	WHEN others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_workflow_utils'
                                  ,p_procedure_name  => 'modify_wf_clob_content');


		  pa_debug.reset_err_stack;
          RAISE;

END modify_wf_clob_content;

-- ==================================================

END pa_workflow_utils;

/
