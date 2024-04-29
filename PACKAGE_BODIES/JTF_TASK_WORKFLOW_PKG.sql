--------------------------------------------------------
--  DDL for Package Body JTF_TASK_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_WORKFLOW_PKG" as
/* $Header: jtftkwfb.pls 120.3 2006/02/23 22:16:32 sbarat ship $ */

   g_pkg_name   CONSTANT VARCHAR2(30) := 'JTF_TASK_WORKFLOW_PKG';
   temp1 number := 1 ;

-- -----------------------------------------------------------------------
-- Is_Task_Item_Active
--   Determine whether the workflow process identified by the given process
--   ID for the given task is still active.
-- IN
--   p_task_id : task ID
--   p_wf_process_id : workflow process ID for this task ID
-- RETURN
--   'Y' if process is active, 'N' otherwise
-- -----------------------------------------------------------------------

   FUNCTION Is_Task_Item_Active
  			( p_task_id		IN	NUMBER,
    			  p_wf_process_id	IN	NUMBER ) RETURN VARCHAR2 IS



    l_itemkey	VARCHAR2(240);
    l_dummy	VARCHAR2(1);
    l_end_date	DATE;
    l_result	VARCHAR2(1);

    CURSOR l_task_csr IS
      SELECT end_date
      FROM   wf_items
      WHERE  item_type = 'JTFTASK'
      AND    item_key  = l_itemkey;

  BEGIN
    --
    -- First construct the item key
    -- If we ever change the format of the itemkey, the following code
    -- must be updated
    --
    l_itemkey := to_char(p_task_id)||'-'||to_char(p_wf_process_id);

    --
    -- An item is considered active if its end_date is NULL
    --
    OPEN l_task_csr;
    FETCH l_task_csr INTO l_end_date;
    IF ((l_task_csr%NOTFOUND) OR (l_end_date IS NOT NULL)) THEN
      l_result := 'N';
    ELSE
      l_result := 'Y';
    END IF;
    CLOSE l_task_csr;

    return l_result;

  END Is_Task_Item_Active;

-- -------------------------------------------------------------------
-- Get_Workflow_Display_Name
-- -------------------------------------------------------------------

  FUNCTION Get_Workflow_Disp_Name (
		p_item_type		IN VARCHAR2,
		p_process_name		IN VARCHAR2,
		p_raise_error		IN BOOLEAN    DEFAULT FALSE )
  RETURN VARCHAR2 IS

    l_display_name  VARCHAR2(80);

  BEGIN
    IF (p_process_name IS NULL) OR
       (p_item_type IS NULL)    THEN
      RETURN NULL;
    END IF;

    SELECT display_name INTO l_display_name
      FROM WF_RUNNABLE_PROCESSES_V
     WHERE item_type = p_item_type
       AND process_name = p_process_name;

    return l_display_name;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (p_raise_error = TRUE) THEN
	raise;
      ELSE
	return NULL;
      END IF;
  END Get_Workflow_Disp_Name;

   PROCEDURE check_event (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   )
   IS
      l_resultout   VARCHAR2(200);
      x varchar2(200);
   BEGIN
      --
      -- RUN mode - normal process execution
      --
      IF (funcmode = 'RUN')
      THEN
         --
         -- Return process to run
         --
         l_resultout :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'TASK_EVENT'
            );
         resultout := 'COMPLETE:' || l_resultout;

         RETURN;
      END IF;

      --
      -- CANCEL mode - activity 'compensation'
      --
      IF (funcmode = 'CANCEL')
      THEN
         --
         -- Return process to run
         --
         resultout := 'COMPLETE';
         RETURN;
      END IF;

      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT')
      THEN
         resultout := 'COMPLETE';
         RETURN;
      END IF;
   --

   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.context (
            'JTFTASK',
            'Check Event',
            itemtype,
            itemkey,
            actid,
            funcmode
         );
         RAISE;
   END check_event;


   FUNCTION default_task_details_tbl return task_details_tbl is
   begin
     return g_miss_task_details_tbl;
   end;

   PROCEDURE start_task_workflow (
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id             IN       NUMBER,
      p_old_assignee_code   IN       VARCHAR2 DEFAULT NULL,
      p_old_assignee_id     IN       NUMBER DEFAULT NULL,
      p_new_assignee_code   IN       VARCHAR2 DEFAULT NULL,
      p_new_assignee_id     IN       NUMBER DEFAULT NULL,
      p_old_owner_code      IN       VARCHAR2 DEFAULT NULL,
      p_old_owner_id        IN       NUMBER DEFAULT NULL,
      p_new_owner_code      IN       VARCHAR2 DEFAULT NULL,
      p_new_owner_id        IN       NUMBER DEFAULT NULL,
      p_task_details_tbl    IN       task_details_tbl
            DEFAULT g_miss_task_details_tbl,
      p_event               IN       VARCHAR2,
      p_wf_display_name     IN       VARCHAR2 DEFAULT NULL,
      p_wf_process          IN       VARCHAR2 DEFAULT 'TASK_WORKFLOW',
      p_wf_item_type        IN       VARCHAR2 DEFAULT 'JTFTASK',
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_version     CONSTANT NUMBER
               := 1.0;
      l_api_name        CONSTANT VARCHAR2(30)
               := 'START_TASK_WORKFLOW';
      l_wf_process_id            NUMBER;
      l_itemkey                  wf_item_activity_statuses.item_key%TYPE;
      l_old_assigned_user_name   fnd_user.user_name%TYPE;
      l_new_assigned_user_name   fnd_user.user_name%TYPE;
      l_owner_user_name          fnd_user.user_name%TYPE;
      l_task_name                jtf_tasks_tl.task_name%TYPE;
      l_description              jtf_tasks_tl.description%TYPE;
      l_owner_code               jtf_tasks_b.owner_type_code%TYPE;
      l_owner_id                 jtf_tasks_b.owner_id%TYPE;
      l_task_number              jtf_tasks_b.task_number%TYPE;
      l_task_status_name         jtf_tasks_v.task_status%type ;
      l_task_type_name         jtf_tasks_v.task_type%type ;
      l_task_priority_name         jtf_tasks_v.task_priority%type ;
      current_record             NUMBER;
      source_text                VARCHAR2(200);
      l_errname varchar2(60);
	l_errmsg varchar2(2000);
l_errstack varchar2(4000);

      CURSOR c_wf_processs_id
      IS
         SELECT jtf_task_workflow_process_s.nextval
           FROM dual;

      -- Commented out by SBARAT on 23/02/2006 for bug# 5045559
      /*CURSOR c_task_details
      IS
         SELECT task_name, description, owner_type_code owner_code, owner_id, task_number
           FROM jtf_tasks_v
          WHERE task_id = p_task_id;*/

      -- Added by SBARAT on 23/02/2006 for bug# 5045559
      CURSOR c_task_details
      IS
         SELECT a.task_name, a.description, a.owner_type_code owner_code, a.owner_id, a.task_number
              FROM jtf_tasks_vl a
              WHERE a.task_id = p_task_id
                AND (a.deleted_flag <> 'Y' OR a.deleted_flag is null)
                AND a.task_type_id <> 22;

   BEGIN



      SAVEPOINT start_task_workflow;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;



      --- write the code for the selector in case the process name is not given
      IF p_event NOT IN ('ADD_ASSIGNEE',
               'CHANGE_ASSIGNEE',
               'DELETE_ASSIGNEE',
               'CHANGE_OWNER',
               'CHANGE_TASK_DETAILS'
              )
      THEN
         null;
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_EVENT');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      OPEN c_wf_processs_id;
      FETCH c_wf_processs_id INTO l_wf_process_id;
      CLOSE c_wf_processs_id;
      l_itemkey := TO_CHAR (p_task_id) || '-' || TO_CHAR (l_wf_process_id);
      OPEN c_task_details;
      FETCH c_task_details INTO l_task_name,
                                l_description,
                                l_owner_code,
                                l_owner_id,
                                l_task_number;

      IF c_task_details%NOTFOUND
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_ID');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      CLOSE c_task_details;
      wf_engine.createprocess (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         process => p_wf_process
      );
      wf_engine.setitemuserkey (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         userkey => l_task_name
      );

      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_NAME',
         avalue => l_task_name
      );
      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_DESC',
         avalue => l_description
      );

      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_NUMBER',
         avalue => l_task_number
      );

      -- Commented out by SBARAT on 23/02/2006 for bug# 5045559
      /*select task_status, task_priority , task_type
      into l_task_status_name, l_task_priority_name  , l_task_type_name
      from jtf_tasks_v where task_id = p_task_id ;*/

      -- Added by SBARAT on 23/02/2006 for bug# 5045559
      select b.name task_status, c.name task_priority , d.name task_type
          into l_task_status_name, l_task_priority_name  , l_task_type_name
          from jtf_tasks_b a,
               jtf_task_statuses_tl b,
               jtf_task_priorities_tl c,
               jtf_task_types_tl d
          where a.task_id = p_task_id
            and (a.deleted_flag <> 'Y' OR a.deleted_flag is null)
            and d.task_type_id <> 22
            and b.task_status_id=a.task_status_id
            and c.task_priority_id=a.task_priority_id
            and d.task_type_id=a.task_type_id
            and b.language=userenv('lang')
            and c.language=userenv('lang')
            and d.language=userenv('lang');

      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_STATUS_NAME',
         avalue => l_task_status_name
      );

      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_PRIORITY_NAME',
         avalue => l_task_priority_name
      );

      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_TYPE_NAME',
         avalue => l_task_type_name
      );

      ----
      ----  Task Owner
      ----
      l_owner_user_name := jtf_rs_resource_pub.get_wf_role( l_owner_id );

      if l_owner_user_name  is null then
      		raise fnd_api.g_exc_unexpected_error;
      end if ;

      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'OWNER_ID',
         avalue => l_owner_user_name
      );
      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'OWNER_NAME',
--        avalue =>  wf_directory.getroledisplayname (l_owner_user_name)
         avalue => jtf_task_utl.get_owner(l_owner_code, l_owner_id)
      );
      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_DESC',
         avalue => l_description
      );


      IF p_event = 'ADD_ASSIGNEE'
      THEN
         IF (  p_new_assignee_code IS NULL
            OR p_new_assignee_id IS NULL)
         THEN
            null ;
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_ASSIGNEE_DETAILS');
            fnd_msg_pub.add;
         ELSE
            l_new_assigned_user_name := jtf_rs_resource_pub.get_wf_role( p_new_assignee_id );

            if l_new_assigned_user_name  is null then
      		raise fnd_api.g_exc_unexpected_error;
      end if ;







            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'TASK_EVENT',
               avalue => 'NOTIFY_NEW_ASSIGNEE'
            );

            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'NEW_TASK_ASSIGNEE_ID',
               avalue => l_new_assigned_user_name
            );



            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'NEW_TASK_ASSIGNEE_NAME',
               avalue => wf_directory.getroledisplayname (
                            l_new_assigned_user_name
                         )
            );



         END IF;
      END IF;



      IF p_event = 'CHANGE_ASSIGNEE'
      THEN
         IF (  p_old_assignee_code IS NULL
            OR p_old_assignee_id IS NULL)
         THEN
            null ;
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_ASSIGNEE_DETAILS');
            fnd_msg_pub.add;
         ELSIF (  p_old_assignee_code IS NULL
               OR p_old_assignee_id IS NULL)
         THEN

            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_ASSIGNEE_DETAILS');
            fnd_msg_pub.add;
         ELSE
            l_new_assigned_user_name := jtf_rs_resource_pub.get_wf_role( p_new_assignee_id );

            if l_new_assigned_user_name   is null then
      		raise fnd_api.g_exc_unexpected_error;
      end if ;
            l_old_assigned_user_name := jtf_rs_resource_pub.get_wf_role( p_old_assignee_id );
            if l_old_assigned_user_name    is null then
      		raise fnd_api.g_exc_unexpected_error;
      end if ;


            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'TASK_EVENT',
               avalue => 'CHANGE_ASSIGNEE'
            );

            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'NEW_TASK_ASSIGNEE_ID',
               avalue => l_new_assigned_user_name
            );




            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'NEW_TASK_ASSIGNEE_NAME',
               avalue => wf_directory.getroledisplayname (
                            l_new_assigned_user_name
                         )
            );

            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'OLD_TASK_ASSIGNEE_ID',
               avalue => l_old_assigned_user_name
            );



            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'OLD_TASK_ASSIGNEE_NAME',
               avalue => wf_directory.getroledisplayname (
                            l_old_assigned_user_name
                         )
            );

         END IF;
      END IF;


      IF p_event = 'DELETE_ASSIGNEE'
      THEN

         IF (  p_old_assignee_code IS NULL
            OR p_old_assignee_id IS NULL)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_ASSIGNEE_DETAILS');
            fnd_msg_pub.add;
         ELSE

         l_old_assigned_user_name := jtf_rs_resource_pub.get_wf_role( p_old_assignee_id );

         if l_old_assigned_user_name  is null then
      		raise fnd_api.g_exc_unexpected_error;
      end if ;
            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'TASK_EVENT',
               avalue => 'ASSIGNEE_REMOVAL'
            );
            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'OLD_TASK_ASSIGNEE_ID',
               avalue => l_old_assigned_user_name
            );
            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'OLD_TASK_ASSIGNEE_NAME',
               avalue => wf_directory.getroledisplayname (
                            l_old_assigned_user_name
                         )
            );
         END IF;
      END IF;


      IF p_event = 'CHANGE_OWNER'
      THEN
         IF (  p_old_owner_code IS NULL
            OR p_old_owner_id IS NULL)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OWNER_DETAILS');
            fnd_msg_pub.add;
         ELSIF (  p_new_owner_code IS NULL
               OR p_new_owner_id IS NULL)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OWNER_DETAILS');
            fnd_msg_pub.add;
         ELSE

            l_new_assigned_user_name := jtf_rs_resource_pub.get_wf_role( p_new_owner_id );
            if l_new_assigned_user_name  is null then
      		raise fnd_api.g_exc_unexpected_error;
      end if ;

            l_old_assigned_user_name := jtf_rs_resource_pub.get_wf_role( p_old_owner_id );
            if l_old_assigned_user_name   is null then
      		raise fnd_api.g_exc_unexpected_error;
      end if ;
            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'TASK_EVENT',
               avalue => 'CHANGE_OWNER'
            );
            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'OLD_TASK_OWNER_ID',
               avalue => l_old_assigned_user_name
            );
            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'OLD_TASK_OWNER_NAME',
               avalue => wf_directory.getroledisplayname (
                            l_old_assigned_user_name
                         )
            );
            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'NEW_TASK_OWNER_ID',
               avalue => l_new_assigned_user_name
            );
            wf_engine.setitemattrtext (
               itemtype => 'JTFTASK',
               itemkey => l_itemkey,
               aname => 'NEW_TASK_OWNER_NAME',
               avalue => wf_directory.getroledisplayname (
                            l_new_assigned_user_name
                         )
            );
         END IF;
      END IF;


      IF p_event = 'CHANGE_TASK_DETAILS'
      THEN
         wf_engine.setitemattrtext (
            itemtype => 'JTFTASK',
            itemkey => l_itemkey,
            aname => 'TASK_EVENT',
            avalue => 'CHANGE_TASK_DETAILS'
         );

         IF p_task_details_tbl.COUNT > 0
         THEN
            current_record := p_task_details_tbl.FIRST;
            source_text := '';

            FOR i IN 1 .. p_task_details_tbl.COUNT
            LOOP
               source_text :=
                  source_text ||
                  p_task_details_tbl (current_record).task_attribute ||
                  '             ' ||
                  p_task_details_tbl (current_record).old_value ||
                  '             ' ||
                  p_task_details_tbl (current_record).new_value
                  ;

               current_record := p_task_details_tbl.NEXT (current_record);

            END LOOP;
         ELSE
            fnd_message.set_name ('JTF', 'JTF_TASK_NO_ATTRIBUTES_PASSED');
            fnd_msg_pub.add;
         END IF;

         wf_engine.setitemattrtext (
            itemtype => 'JTFTASK',
            itemkey => l_itemkey,
            aname => 'TASK_TEXT',
            avalue => source_text
         );
      END IF;



      wf_engine.startprocess (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey
      );

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;


        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN

         ROLLBACK TO start_task_workflow;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
            ROLLBACK TO start_task_workflow ;

            wf_core.get_error(l_errname, l_errmsg, l_errstack);

            if (l_errname is not null) then
         	  fnd_message.set_name('FND', 'WF_ERROR');
         	  fnd_message.set_token('ERROR_MESSAGE', l_errmsg);
  	  		fnd_message.set_token('ERROR_STACK', l_errstack);
  	  		fnd_msg_pub.add;
	end if;

            ---fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            ---fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;


   PROCEDURE abort_task_workflow (
   p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id         IN   NUMBER,
      p_wf_process_id   IN   NUMBER,
      p_user_code       IN   VARCHAR2,
      p_user_id         IN   NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR c_task_details
      IS
         SELECT task_name, description, owner_type_code owner_code, owner_id
           FROM jtf_tasks_vl
          WHERE task_id = p_task_id;

      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'ABORT_TASK_WORKFLOW';
      l_wf_process_id          NUMBER;
      l_itemkey                wf_item_activity_statuses.item_key%TYPE;
      l_task_name              jtf_tasks_tl.task_name%TYPE;
      l_description            jtf_tasks_tl.description%TYPE;
      l_owner_code             jtf_tasks_b.owner_type_code%TYPE;
      l_owner_id               jtf_tasks_b.owner_id%TYPE;
      l_aborted_by_user_name   fnd_user.user_name%TYPE;
      l_task_owner_name        fnd_user.user_name%TYPE;
      l_context                VARCHAR2(100);
      l_notification_id        NUMBER;
      wf_not_active          EXCEPTION;
   BEGIN
      SAVEPOINT abort_task_workflow;

      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;


      l_itemkey := TO_CHAR (p_task_id) || '-' || TO_CHAR (p_wf_process_id);

      IF jtf_task_workflow_pkg.is_task_item_active (
            p_task_id => p_task_id,
            p_wf_process_id => p_wf_process_id
         ) =
            'N'
      THEN
         RAISE wf_not_active;
      END IF;

     l_aborted_by_user_name := jtf_rs_resource_pub.get_wf_role( p_user_id );
     if l_aborted_by_user_name   is null then
      		raise fnd_api.g_exc_unexpected_error;
      end if ;

      OPEN c_task_details;
      FETCH c_task_details INTO l_task_name,
                                l_description,
                                l_owner_code,
                                l_owner_id;


      IF c_task_details%NOTFOUND
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_ID');
         fnd_msg_pub.add;
      END IF;

      CLOSE c_task_details;

      l_task_owner_name := jtf_rs_resource_pub.get_wf_role( l_owner_id );
      if l_task_owner_name is null then
      		raise fnd_api.g_exc_unexpected_error;
      end if ;


      wf_engine.abortprocess (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey
      );
      l_context := 'JTFTASK' ||
                   ':' ||
                   l_itemkey ||
                   ':' ||
                   TO_CHAR (-1);
      l_notification_id :=
         wf_notification.send (
            role => l_task_owner_name,
            msg_type => 'JTFTASK',
            msg_name => 'ABORT_MSG',
            callback => 'WF_ENGINE.CB',
            context => l_context
         );
      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'ABORTED_BY_NAME',
         avalue => wf_directory.getroledisplayname (l_aborted_by_user_name)
      );
      wf_notification.setattrtext (
         nid => l_notification_id,
         aname => 'ABORTED_BY',
         avalue => l_aborted_by_user_name
      );
      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_NAME',
         avalue => l_task_name
      );
      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_DESC',
         avalue => l_description
      );


   EXCEPTION
      when wf_not_active then
            ROLLBACK TO abort_task_workflow ;
            fnd_message.set_name('JTF','Workflow is not active ');
            fnd_msg_pub.add ;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO abort_task_workflow ;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


   END;

END JTF_TASK_WORKFLOW_PKG;

/
