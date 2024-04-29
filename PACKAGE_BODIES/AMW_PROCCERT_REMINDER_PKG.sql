--------------------------------------------------------
--  DDL for Package Body AMW_PROCCERT_REMINDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROCCERT_REMINDER_PKG" AS
/* $Header: amwpsrmb.pls 120.0.12000000.2 2007/03/29 16:04:13 hyuen ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_PROCCERT_REMINDER_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
--G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_PROCCERT_REMINDER_PKG';
--G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwpsrmb.pls';

TYPE t_proc_owner_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_proc_owner_tbl t_proc_owner_tbl;

TYPE t_owner_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_ownerlist_tbl t_owner_tbl;

FUNCTION  get_proc_owner(
		 p_certification_id  IN NUMBER,
		 p_organization_id   IN NUMBER,
		 p_process_id	     IN NUMBER)
RETURN NUMBER;


FUNCTION  get_proc_owner(
		 p_certification_id  IN NUMBER,
		 p_organization_id   IN NUMBER,
		 p_process_id	     IN NUMBER)
RETURN NUMBER
IS
    CURSOR C_Proc_Owner IS
      select TO_NUMBER(REPLACE(grants.grantee_key,'HZ_PARTY:',''))
        from fnd_grants grants,
             fnd_objects obj,
	     fnd_menus granted_menu
      where  obj.obj_name = 'AMW_PROCESS_ORGANIZATION'
      AND    grants.object_id = obj.object_id
      AND    grants.grantee_type ='USER'
      AND    grants.instance_type = 'INSTANCE'
      AND    grants.instance_pk1_value = to_char(p_ORGANIZATION_ID)
      AND    grants.instance_pk2_value = to_char(p_PROCESS_ID)
      AND    grants.grantee_key like 'HZ_PARTY%'
      AND    NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
      AND    grants.menu_id = granted_menu.menu_id
      and    granted_menu.menu_name = 'AMW_ORG_PROC_OWNER_ROLE';

    CURSOR C_Parent_Proc IS
      select parent_process_id
        from amw_execution_scope
       where entity_type = 'BUSIPROC_CERTIFICATION'
         and entity_id = p_certification_id
	 and organization_id = p_organization_id
	 and process_id = p_process_id;

    CURSOR C_Org_Owner IS
      select TO_NUMBER(REPLACE(grants.grantee_key,'HZ_PARTY:',''))
        from fnd_grants grants,
             fnd_objects obj,
	     fnd_menus granted_menu
      where  obj.obj_name = 'AMW_ORGANIZATION'
      AND    grants.object_id = obj.object_id
      AND    grants.grantee_type ='USER'
      AND    grants.instance_type = 'INSTANCE'
      AND    grants.instance_pk1_value = to_char(p_ORGANIZATION_ID)
      AND    grants.grantee_key like 'HZ_PARTY%'
      AND    NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
      AND    grants.menu_id = granted_menu.menu_id
      and    granted_menu.menu_name = 'AMW_ORG_MANAGER_ROLE';

    l_proc_owner      NUMBER;
    l_parent_proc_id  NUMBER;
BEGIN
    IF g_proc_owner_tbl.exists(p_process_id) THEN
       return g_proc_owner_tbl(p_process_id);
    END IF;

    OPEN C_Proc_Owner;
    FETCH C_Proc_Owner INTO l_proc_owner;
    CLOSE C_Proc_Owner;

    IF l_proc_owner IS null THEN
       OPEN C_Parent_Proc;
       FETCH C_Parent_Proc INTO l_parent_proc_id;
       CLOSE C_Parent_Proc;

       IF l_parent_proc_id = -1 OR l_parent_proc_id IS NULL THEN
          OPEN C_Org_Owner;
	  FETCH C_Org_Owner INTO l_proc_owner;
          CLOSE C_Org_Owner;
       ELSE
          l_proc_owner := Get_Proc_Owner (
		        p_certification_id => p_certification_id,
			p_organization_id  => p_organization_id,
			p_process_id	   => l_parent_proc_id);
       END IF;
    END IF;

    g_proc_owner_tbl(p_process_id) := l_proc_owner;

    return l_proc_owner;

END Get_Proc_Owner;

/* hyuen start Bug 5098058 */
  PROCEDURE add_owner_to_list(p_owner_id IN NUMBER) IS
  l_exists boolean;
  BEGIN

    IF p_owner_id IS NOT NULL THEN
      l_exists := FALSE;
      FOR i IN 1 .. g_ownerlist_tbl.COUNT
      LOOP

        IF g_ownerlist_tbl(i) = p_owner_id THEN
          l_exists := TRUE;
          EXIT;
        END IF;

      END LOOP;

      IF NOT l_exists THEN
        g_ownerlist_tbl(g_ownerlist_tbl.COUNT + 1) := p_owner_id;
      END IF;

    END IF;

  END add_owner_to_list;

  PROCEDURE get_proc_ownerlist(p_certification_id IN NUMBER,   p_organization_id IN NUMBER,   p_process_id IN NUMBER) IS
  CURSOR c_proc_owner IS
  SELECT to_number(REPLACE(grants.grantee_key,   'HZ_PARTY:',   '')) process_owner_id
  FROM fnd_grants grants,
    fnd_objects obj,
    fnd_menus granted_menu
  WHERE obj.obj_name = 'AMW_PROCESS_ORGANIZATION'
   AND grants.object_id = obj.object_id
   AND grants.grantee_type = 'USER'
   AND grants.instance_type = 'INSTANCE'
   AND grants.instance_pk1_value = to_char(p_organization_id)
   AND grants.instance_pk2_value = to_char(p_process_id)
   AND grants.grantee_key LIKE 'HZ_PARTY%'
   AND nvl(grants.end_date,   sysdate + 1) >= TRUNC(sysdate)
   AND grants.menu_id = granted_menu.menu_id
   AND granted_menu.menu_name = 'AMW_ORG_PROC_OWNER_ROLE';

  CURSOR c_parent_proc IS
  SELECT parent_process_id
  FROM amw_execution_scope
  WHERE entity_type = 'BUSIPROC_CERTIFICATION'
   AND entity_id = p_certification_id
   AND organization_id = p_organization_id
   AND process_id = p_process_id;

  CURSOR c_org_owner IS
  SELECT to_number(REPLACE(grants.grantee_key,   'HZ_PARTY:',   '')) org_owner_id
  FROM fnd_grants grants,
    fnd_objects obj,
    fnd_menus granted_menu
  WHERE obj.obj_name = 'AMW_ORGANIZATION'
   AND grants.object_id = obj.object_id
   AND grants.grantee_type = 'USER'
   AND grants.instance_type = 'INSTANCE'
   AND grants.instance_pk1_value = to_char(p_organization_id)
   AND grants.grantee_key LIKE 'HZ_PARTY%'
   AND nvl(grants.end_date,   sysdate + 1) >= TRUNC(sysdate)
   AND grants.menu_id = granted_menu.menu_id
   AND granted_menu.menu_name = 'AMW_ORG_MANAGER_ROLE';

  l_proc_owner NUMBER;
  l_parent_proc_id NUMBER;
  l_exists boolean;
  BEGIN
    FOR procowner_rec IN c_proc_owner
    LOOP
      add_owner_to_list( procowner_rec.process_owner_id );
    END LOOP;

    IF g_ownerlist_tbl.COUNT = 0 THEN
      OPEN c_parent_proc;
      FETCH c_parent_proc INTO l_parent_proc_id;
      CLOSE c_parent_proc;

      IF l_parent_proc_id = -1 OR l_parent_proc_id IS NULL THEN

        FOR orgowner_rec IN c_org_owner
        LOOP
          add_owner_to_list( orgowner_rec.org_owner_id );
        END LOOP;
      ELSE
        get_proc_ownerList(p_certification_id => p_certification_id,
                                      p_organization_id => p_organization_id,
                                      p_process_id => l_parent_proc_id);
      END IF;

    END IF;
END get_proc_ownerlist;

/* hyuen end Bug 5098058 */


PROCEDURE send_reminder_to_all_owners(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY VARCHAR2)
is
   --- GET ALL certiifcatios for which reminders is due -------
   cursor Get_Certi_for_Reminders is
      select certification_id
      from   amw_certification_b
      where  OBJECT_TYPE='PROCESS'
      and    (LAST_REMINDER_DATE  is null
               OR (trunc(LAST_REMINDER_DATE) + CERTIFICATION_REMINDER <= trunc(SYSDATE)))
      and    CERTIFICATION_STATUS = 'ACTIVE';

   cursor Get_Org_To_Notify(c_cert_id NUMBER) is
      select distinct organization_id
        from amw_execution_scope exscope
      where  exscope.ENTITY_TYPE = 'BUSIPROC_CERTIFICATION'
      and    exscope.ENTITY_ID = c_cert_id
      and    exscope.level_id > 3
      and    not exists (select 'Y'
			 from   amw_opinions_v opinion
			 where  opinion.PK1_VALUE = exscope.ENTITY_ID
			 and    opinion.PK2_VALUE = exscope.ORGANIZATION_ID
			 and 	opinion.PK3_VALUE = exscope.PROCESS_ID
			 and    opinion.object_name = 'AMW_ORG_PROCESS'
			 and    opinion.OPINION_TYPE_CODE  = 'CERTIFICATION');


   cursor Get_Org_Proc_To_Notify(c_cert_id NUMBER, c_org_id NUMBER) is
      select distinct process_id
        from amw_execution_scope exscope
      where  exscope.ENTITY_TYPE = 'BUSIPROC_CERTIFICATION'
      and    exscope.ENTITY_ID = c_cert_id
      and    exscope.organization_id = c_org_id
      and    exscope.level_id > 3
      and    not exists (select 'Y'
			 from   amw_opinions_v opinion
			 where  opinion.PK1_VALUE = exscope.ENTITY_ID
			 and    opinion.PK2_VALUE = exscope.ORGANIZATION_ID
			 and 	opinion.PK3_VALUE = exscope.PROCESS_ID
			 and    opinion.object_name = 'AMW_ORG_PROCESS'
			 and    opinion.OPINION_TYPE_CODE  = 'CERTIFICATION');

   x_return_status      VARCHAR2(30);

   l_owner_id	      NUMBER;
   l_owner_tbl        t_owner_tbl;
   l_exists	      BOOLEAN;

begin

   fnd_file.put_line(fnd_file.LOG, 'Starting to Fetch all Certification which are active and a reminder need to send from cursor  Get_Certi_for_Reminders');


   --------------------------------------------
   -- Main cursor loop
   --------------------------------------------

   for cert_rec in Get_Certi_for_Reminders loop
      fnd_file.put_line(fnd_file.LOG,
		'Fetching Certification ID: '||to_number(cert_rec.certification_id));

      l_owner_tbl.delete;
      g_ownerlist_tbl.delete;   /* hyuen bug 5098058 */
      for org_rec in Get_Org_To_Notify(cert_rec.certification_id) loop
        g_proc_owner_tbl.delete;

        for proc_rec in Get_Org_Proc_to_Notify(cert_rec.certification_id, org_rec.organization_id) loop
           /* hyuen start bug 5098058
	   l_owner_id := get_proc_owner(
		    p_certification_id => cert_rec.certification_id,
		    p_organization_id  => org_rec.organization_id,
		    p_process_id       => proc_rec.process_id);

           IF l_owner_id IS NOT NULL THEN
	     l_exists := false;
             FOR i IN 1..l_owner_tbl.count LOOP
               IF l_owner_tbl(i) = l_owner_id THEN
	         l_exists := true;
                 EXIT;
               END IF;
             END LOOP;
             IF NOT l_exists THEN
               l_owner_tbl(l_owner_tbl.count+1) := l_owner_id;
             END IF;
           END IF; */
           get_proc_ownerList(p_certification_id => cert_rec.certification_id,
                            p_organization_id => org_rec.organization_id,
                            p_process_id => proc_rec.process_id);
           /* hyuen end bug 5098058 */
        end loop;
      end loop;

      /* hyuen start bug 5098058
      FOR i IN 1..l_owner_tbl.count LOOP
        AMW_PROCCERT_REMINDER_PKG.send_reminder_to_owner
                  ( p_certification_id => cert_rec.certification_id,
		    p_process_owner_id => l_owner_tbl(i),
		    x_return_status    => x_return_status);
      END LOOP; */

      FOR i IN 1 .. g_ownerList_tbl.COUNT LOOP
        amw_proccert_reminder_pkg.send_reminder_to_owner
                  ( p_certification_id => cert_rec.certification_id,
                    p_process_owner_id => g_ownerList_tbl(i),
                    x_return_status => x_return_status);
      END LOOP;
      /* hyuen end bug 5098058 */

      AMW_PROCCERT_REMINDER_PKG.update_lastreminder_date
                 (p_certificaion_id => cert_rec.certification_id ,
		  x_return_status => x_return_status);
      COMMIT;
   end loop;

EXCEPTION
   WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.LOG,
		'unexpected error in send_reminder_to_all_owners: '||sqlerrm);
END send_reminder_to_all_owners;


-- =================== **************************  ===================================== --


PROCEDURE update_lastreminder_date(p_certificaion_id IN number, x_return_status OUT NOCOPY VARCHAR2)
is
begin
   fnd_file.put_line(fnd_file.LOG,
		'Going to update LAST_REMINDER_DATE for '||p_certificaion_id);

   update amw_certification_b
   set    LAST_REMINDER_DATE= sysdate
   where  CERTIFICATION_ID = p_certificaion_id;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   fnd_file.put_line(fnd_file.LOG,
                'Updates LAST_REMINDER_DATE for '||p_certificaion_id);
EXCEPTION
   WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.LOG,
		'unexpected error in update_lastreminder_date: '||sqlerrm);
END update_lastreminder_date;


-- =================== **************************  ===================================== --

PROCEDURE send_reminder_to_owner(
		  p_item_type           IN  VARCHAR2 := 'AMWNOTIF',
		  p_message_name        IN  VARCHAR2 := 'PROCESSCERTIFICATIONREMINDER',
                  p_certification_id	in NUMBER,
		  p_process_owner_id	in NUMBER,
		  p_organization_id	in NUMBER := null,
		  p_process_id		in NUMBER := null,
		  x_return_status OUT NOCOPY VARCHAR2)
is
    cursor c_certification (c_cert_id NUMBER) is
       select certification_name
       from   amw_certification_vl
       where  certification_id=c_cert_id;

    cursor c_person (c_party_id NUMBER) is
       select employee_id
       from   amw_employees_current_v
       where  party_id = c_party_id;

    l_cert_name		     VARCHAR2(240);
    l_to_role_name           VARCHAR2(100);
    l_from_role_name         VARCHAR2(100);
    l_display_role_name	     VARCHAR2(240);
    l_notif_id		     NUMBER;
    l_subject		     VARCHAR2(2000);
    l_to_emp_id		     NUMBER;
    l_from_emp_id	     NUMBER := FND_GLOBAL.employee_id;

 begin

    fnd_file.put_line(fnd_file.LOG, 'send_reminder_to_owner begin');
    fnd_file.put_line(fnd_file.LOG, 'certification_id:'||to_char(p_certification_id));
    fnd_file.put_line(fnd_file.LOG, 'process_owner_id:'||to_char(p_process_owner_id));
    fnd_file.put_line(fnd_file.LOG, 'organization_id:'||p_organization_id);
    fnd_file.put_line(fnd_file.LOG, 'process_id:'||p_process_id);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open c_certification(p_certification_id);
    fetch c_certification into l_cert_name;
    close c_certification;

    open c_person(p_process_owner_id);
    fetch c_person into l_to_emp_id;
    close c_person;


    FND_MESSAGE.set_name('AMW', 'AMW_PROCESSOWNER_REMINDER_SUBJ');
    FND_MESSAGE.set_token('CERTIFICATION_NAME', l_cert_name, TRUE);
    FND_MSG_PUB.add;
    l_subject := fnd_msg_pub.get(
				p_msg_index => fnd_msg_pub.G_LAST,
				p_encoded => fnd_api.g_false);



    WF_DIRECTORY.getrolename
        (p_orig_system      => 'PER',
	 p_orig_system_id   => l_to_emp_id,
	 p_name             => l_to_role_name,
	 p_display_name     => l_display_role_name );


    IF l_to_role_name IS NULL THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.set_name('AMW','AMW_APPR_INVALID_ROLE');
       FND_MSG_PUB.ADD;
       fnd_file.put_line(fnd_file.LOG, 'to_role is null');
    ELSE

       WF_DIRECTORY.getrolename
	   (p_orig_system      => 'PER',
	    p_orig_system_id   => l_from_emp_id ,
	    p_name             => l_from_role_name,
	    p_display_name     => l_display_role_name);

       l_notif_id := WF_NOTIFICATION.send
			(role => l_to_role_name,
			 msg_type => p_item_type,
			 msg_name => p_message_name);

       fnd_file.put_line(fnd_file.LOG, 'notification_id:'||l_notif_id||'--'||l_subject);

       WF_NOTIFICATION.SetAttrText
	      (l_notif_id,
               'MSG_SUBJECT',
               l_subject);

       WF_NOTIFICATION.setattrtext
              (l_notif_id,
               '#FROM_ROLE',
	       l_from_role_name);

       WF_NOTIFICATION.setattrnumber
              (l_notif_id,
               'CERTIFICATION_ID',
	       p_certification_id);

       WF_NOTIFICATION.setattrnumber
              (l_notif_id,
               'PROCESS_OWNER_ID',
               p_process_owner_id);

       if p_process_id is not null then
          WF_NOTIFICATION.setattrnumber
              (l_notif_id,
               'ORGANIZATION_ID',
               p_organization_id);

          WF_NOTIFICATION.setattrnumber
              (l_notif_id,
               'PROCESS_ID',
               p_process_id);

       end if;
   end if;

EXCEPTION
   WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.LOG,
		'unexpected error in send_reminder_to_owner: '||sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END send_reminder_to_owner;

-------------------------- ********************************************** ---------------------
-- Sends reminder to all Process Owners in Procecss Hierarchy based on a selction in UI by user
-----------------------------------------------------------------------------------------------
PROCEDURE send_reminder_selected_procs(
		p_organization_id IN Number,
		p_entity_id IN Number,
		p_process_id In Number,
		x_return_status OUT NOCOPY VARCHAR2)
is
   CURSOR Get_Pending_Cert_Proc IS
      SELECT distinct scp.organization_id, scp.PROCESS_ID
        FROM amw_execution_scope scp
       where not exists (select 'Y'
			 from   amw_opinions_v opinion
			 where  opinion.PK1_VALUE = scp.ENTITY_ID
			 and    opinion.PK2_VALUE = scp.ORGANIZATION_ID
			 and 	opinion.PK3_VALUE = scp.PROCESS_ID
			 and    opinion.object_name = 'AMW_ORG_PROCESS'
			 and    opinion.OPINION_TYPE_CODE  = 'CERTIFICATION')
       start with scp.ENTITY_ID=p_entity_id
              and scp.ENTITY_TYPE='BUSIPROC_CERTIFICATION'
	      and scp.PROCESS_ID=p_process_id
              and scp.ORGANIZATION_ID=p_organization_id
       connect by PRIOR scp.PROCESS_ID=scp.PARENT_PROCESS_ID
	      and PRIOR scp.ENTITY_ID=scp.ENTITY_ID
	      AND PRIOR scp.ORGANIZATION_ID=scp.ORGANIZATION_ID
	      and PRIOR scp.ENTITY_TYPE=scp.ENTITY_TYPE;


   cursor Get_Proc_Owner_To_Notify is
      select distinct
             TO_NUMBER(REPLACE(grants.grantee_key,'HZ_PARTY:',''))
	     process_owner_id
      from   amw_execution_scope exscope,
             fnd_grants grants,
             fnd_objects obj,
	     fnd_menus granted_menu
      where  exscope.ENTITY_TYPE = 'BUSIPROC_CERTIFICATION'
      and    exscope.ENTITY_ID = p_entity_id
      and    obj.obj_name = 'AMW_PROCESS_ORGANIZATION'
      AND    grants.object_id = obj.object_id
      AND    grants.grantee_type ='USER'
      AND    grants.instance_type = 'INSTANCE'
      AND    grants.instance_pk1_value = to_char(exscope.ORGANIZATION_ID)
      AND    grants.instance_pk2_value = to_char(exscope.PROCESS_ID)
      AND    grants.grantee_key like 'HZ_PARTY%'
      AND    NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
      AND    grants.menu_id = granted_menu.menu_id
      and    granted_menu.menu_name = 'AMW_ORG_PROC_OWNER_ROLE'
      and    not exists (select 'Y'
			 from   amw_opinions_v opinion
			 where  opinion.PK1_VALUE = exscope.ENTITY_ID
			 and    opinion.PK2_VALUE = exscope.ORGANIZATION_ID
			 and 	opinion.PK3_VALUE = exscope.PROCESS_ID
			 and    opinion.object_name = 'AMW_ORG_PROCESS'
			 and    opinion.OPINION_TYPE_CODE  = 'CERTIFICATION')
      and    (exscope.organization_id, exscope.PROCESS_ID) in
	        (select exscopeB.organization_id, exscopeB.PROCESS_ID
		 from   amw_execution_scope exscopeB
		 start with exscopeB.ENTITY_ID=p_entity_id
		       and  exscopeB.ENTITY_TYPE='BUSIPROC_CERTIFICATION'
		       and  exscopeB.PROCESS_ID=p_process_id
		       and  exscopeB.ORGANIZATION_ID=p_organization_id
		 connect by
		      PRIOR exscopeB.PROCESS_ID=exscopeB.PARENT_PROCESS_ID
		  and PRIOR exscopeB.ENTITY_ID=exscopeB.ENTITY_ID
		  AND PRIOR exscopeB.ORGANIZATION_ID=exscopeB.ORGANIZATION_ID
		  and PRIOR exscopeB.ENTITY_TYPE=exscopeB.ENTITY_TYPE);

   lx_return_status   varchar2(30);

   l_owner_id	      NUMBER;
   l_owner_tbl        t_owner_tbl;
   l_exists	      BOOLEAN;

begin
   fnd_file.put_line(fnd_file.LOG, 'Getting Data from Cursor Get_Proc_Owner_To_Notify ');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   g_proc_owner_tbl.delete;
   g_ownerlist_tbl.delete;   /* hyuen bug 5098058 */

   FOR proc_rec in Get_Pending_Cert_Proc LOOP
       /* hyuen start bug 5098058
       l_owner_id := get_proc_owner(
		    p_certification_id => p_entity_id,
		    p_organization_id  => p_organization_id,
		    p_process_id       => proc_rec.process_id);

       IF l_owner_id IS NOT NULL THEN
	 l_exists := false;
         FOR i IN 1..l_owner_tbl.count LOOP
           IF l_owner_tbl(i) = l_owner_id THEN
	     l_exists := true;
             EXIT;
           END IF;
         END LOOP;
         IF NOT l_exists THEN
           l_owner_tbl(l_owner_tbl.count+1) := l_owner_id;
         END IF;
       END IF; */
       get_proc_ownerList(p_certification_id => p_entity_id,
                        p_organization_id => p_organization_id,
                        p_process_id => proc_rec.process_id);
       /* hyuen end bug 5098058 */
   END LOOP;

   /* hyuen start bug 5098058
   FOR i IN 1..l_owner_tbl.count LOOP
       AMW_PROCCERT_REMINDER_PKG.send_reminder_to_owner
                  ( p_certification_id => p_entity_id,
		    p_process_owner_id => l_owner_tbl(i),
		    p_organization_id  => p_organization_id,
		    p_process_id       => p_process_id,
		    x_return_status    => lx_return_status);
   END LOOP; */
   FOR i IN 1 .. g_ownerList_tbl.COUNT LOOP
      amw_proccert_reminder_pkg.send_reminder_to_owner
                       (p_certification_id => p_entity_id,
                        p_process_owner_id => g_ownerList_tbl(i),
                        p_organization_id => p_organization_id,
                        p_process_id => p_process_id,
                        x_return_status => lx_return_status);
   END LOOP;
   /* hyuen end bug 5098058 */

   commit;

EXCEPTION
   WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.LOG,
		'unexpected error in send_reminder_to_owner: '||sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END send_reminder_selected_procs;


END AMW_PROCCERT_REMINDER_PKG ;

/
