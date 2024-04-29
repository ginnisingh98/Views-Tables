--------------------------------------------------------
--  DDL for Package Body PA_DISTRIBUTION_LIST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DISTRIBUTION_LIST_UTILS" AS
 /* $Header: PATDLUTB.pls 120.3.12010000.7 2009/02/23 22:49:55 asahoo ship $ */

 Function Check_valid_dist_list_id (
                        p_list_id in Number )
 return boolean
 IS
 Cursor C1 is
 Select 'X' from pa_distribution_lists
 where list_id = p_list_id;

 l_dummy   varchar2(1);
 l_return_status  boolean := TRUE;
 Begin
  Open C1;
  fetch C1 into l_dummy;
  if (C1%NOTFOUND) then
   l_return_status := FALSE;
  else
   l_return_status := TRUE;
  end if;
  close C1;

  return l_return_status;

 Exception
  When others then
   RAISE;

 End Check_valid_dist_list_id;

 Function Check_dist_list_name_exists (
                        p_list_id   in number default null,
                        p_list_name in varchar2)
 return boolean
 IS
  Cursor C1 is
  Select list_id
  from pa_distribution_lists
  where name = p_list_name
  and (p_list_id is null
       OR p_list_id <> list_id) ;

  l_list_id   Number := 0;
  l_return_status boolean := FALSE;

 Begin
  Open C1;
  fetch C1 into l_list_id;
  if C1%NOTFOUND then
     l_return_status  := FALSE;
  else
     l_return_status := TRUE;
  end if;
  close C1;
  return l_return_status;

 Exception
  When others then
   RAISE;

 End Check_dist_list_name_exists;

 --Fix for bug#8247832, added a new function
 FUNCTION Check_dist_list_items_exists (
                        p_list_id   in number,
                        p_recipient_type in varchar2,
                        p_recipient_id  in varchar2)
 return boolean
 IS
  Cursor C1 is
  Select list_item_id
  from pa_dist_list_items
  where list_id = p_list_id
  and recipient_type = p_recipient_type
  and recipient_id = p_recipient_id;

  l_list_item_id   Number := 0;
  l_return_status boolean := FALSE;

 Begin
  Open C1;
  fetch C1 into l_list_item_id;
  if C1%NOTFOUND then
     l_return_status  := FALSE;
  else
     l_return_status := TRUE;
  end if;
  close C1;
  return l_return_status;

 Exception
  When others then
   RAISE;
 End Check_dist_list_items_exists;

 Function get_dist_list_id (
                        p_list_name in varchar2 )
 return number
 IS
  Cursor C1 is
  Select list_id
  from pa_distribution_lists
  where name = p_list_name;

  l_list_id   Number := 0;

 Begin
  Open C1;
  fetch C1 into l_list_id;
  if C1%NOTFOUND then
     l_list_id  := -1;
  end if;
  close C1;
  return l_list_id;

 Exception
  When others then
   RAISE;
 End get_dist_list_id;

 Function Check_valid_recipient_type (
                        p_recipient_type in varchar2 )
 return boolean
 IS
  l_return_code boolean := TRUE;
  l_dummy   varchar2(1);
  Cursor C1 is
  Select 'X'
  from pa_lookups
  where lookup_type = 'PA_RECIPIENT_TYPES'
  and lookup_code = p_recipient_type;
 Begin
   open C1;
   fetch C1 into l_dummy;
   if (C1%NOTFOUND) then
    l_return_code := FALSE;
   end if;
   close C1;
   return l_return_code;
 End Check_valid_recipient_type;

 Function Check_valid_recipient_id (
                        p_recipient_type in varchar2,
                        p_recipient_id   in varchar2 )
 return boolean
 IS
 Begin
   return TRUE;
 End Check_valid_recipient_id;

 Function Check_valid_access_level (
                        p_access_level in number)
 return boolean
 IS
 Begin
   return TRUE;
 End Check_valid_access_level;

 Function Check_valid_menu_id (
                        p_menu_id in Number )
 return boolean
 IS
 Cursor C1 is
 Select 'X' from fnd_menus
 where menu_id = p_menu_id;

 l_dummy   varchar2(1);
 l_return_status  boolean := TRUE;
 Begin
  Open C1;
  fetch C1 into l_dummy;
  if (C1%NOTFOUND) then
   l_return_status := FALSE;
  else
   l_return_status := TRUE;
  end if;
  close C1;

  return l_return_status;

 Exception
  When others then
   RAISE;

 End Check_valid_menu_id;


FUNCTION get_access_level (
  p_object_type        IN   VARCHAR2,
  p_object_id          IN   VARCHAR2,
  p_user_id            IN   NUMBER  DEFAULT FND_GLOBAL.USER_ID,
  x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_context_object_type IN  VARCHAR2 DEFAULT NULL,
  p_context_object_id   IN  VARCHAR2 DEFAULT NULL
) RETURN NUMBER
IS
  l_access_level NUMBER;
  l_return_value NUMBER := 0;
  l_resource_id NUMBER;           -- Bug 2717635
  l_party_id NUMBER;
  l_object_type VARCHAR2(30) := p_context_object_type;
  l_object_id NUMBER := p_context_object_id;

  CURSOR c_list_ids IS
  SELECT list_id
  FROM pa_object_dist_lists
  WHERE object_type = p_object_type
    AND object_id = p_object_id;

  /* Bug 2717635 in the following query, selected from table pa_project_parties
     in place of view pa_project_parties_v to improve the performance
     Also passed another parameter to this cursor c_access_level ie
     cp_resource_id which passes the resource_id for a corresponding user_id
     for join with table pa_project_parties
     Also there is a cartesian joint with fnd_user which is not required, hence removing it*/

  CURSOR c_access_level(cp_list_id NUMBER) IS  -- Bug 2717635
  SELECT MAX(access_level) access_level FROM (
  SELECT access_level
  FROM pa_dist_list_items i,
       pa_project_parties p    -- Bug 2717635
  WHERE i.list_id = cp_list_id
    AND i.recipient_type = 'PROJECT_PARTY'
    AND p.project_party_id = i.recipient_id
    AND p.resource_id = l_resource_id    -- Bug 2717635
    AND p.object_type = l_object_type
    AND p.object_id = l_object_id
  UNION ALL
  SELECT access_level
  FROM pa_dist_list_items i,
       pa_project_parties p   -- Bug 2717635
       /* fnd_user u */       -- Bug 2717635
  WHERE i.list_id = cp_list_id
    AND i.recipient_type = 'PROJECT_ROLE'
    AND p.project_role_id = i.recipient_id
    AND p.resource_id = l_resource_id  -- Bug 2717635
    AND p.object_type = l_object_type
    AND p.object_id = l_object_id
  UNION ALL
  SELECT access_level
  FROM pa_dist_list_items
  WHERE list_id = cp_list_id
    AND recipient_type = 'ALL_PROJECT_PARTIES'
    AND EXISTS (SELECT 'Y' FROM pa_project_parties  -- Bug 2717635
                WHERE resource_id = l_resource_id  -- Bug 2717635
                  AND object_type = l_object_type
                  AND object_id = l_object_id)
  UNION ALL
  SELECT access_level
  FROM pa_dist_list_items
  WHERE list_id = cp_list_id
    AND recipient_type = 'HZ_PARTY'
    AND recipient_id = l_party_id);

BEGIN
  x_return_status := 'S';

  IF p_context_object_type IS NULL AND
     p_object_type = 'PA_OBJECT_PAGE_LAYOUT' THEN
    SELECT object_type, object_id
    INTO l_object_type, l_object_id
    FROM pa_object_page_layouts
    WHERE object_page_layout_id = p_object_id;
  END IF;

  l_resource_id := pa_resource_utils.get_resource_id(NULL,p_user_id);   -- Bug 2717635
  l_party_id := pa_utils.get_party_id(p_user_id);

  FOR l_rec IN c_list_ids LOOP
--dbms_output.put_line('list_id='||l_rec.list_id);
    OPEN c_access_level(l_rec.list_id);   -- Bug 2717635
    FETCH c_access_level INTO l_access_level;
--dbms_output.put_line('access_level='||l_access_level);
    IF c_access_level%FOUND AND l_access_level>l_return_value THEN
      l_return_value := l_access_level;
    END IF;
  END LOOP;

  RETURN l_return_value;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := 'E';

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_OBJECT_DIST_LISTS_UTILS',
                             p_procedure_name => 'GET_ACCESS_LEVEL',
                             p_error_text     => SUBSTRB(SQLERRM,1,240));
END get_access_level;

PROCEDURE get_dist_list (
  p_object_type        IN   VARCHAR2,
  p_object_id          IN   VARCHAR2,
  p_access_level       IN   NUMBER,
  x_user_names         OUT  NOCOPY PA_VC_1000_150, --File.Sql.39 bug 4440895
  x_full_names         OUT  NOCOPY PA_VC_1000_150, --File.Sql.39 bug 4440895
  x_email_addresses    OUT  NOCOPY PA_VC_1000_150, --File.Sql.39 bug 4440895
  x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_object_type VARCHAR2(30);
  l_object_id NUMBER;
  l_return_value NUMBER := 0;
  i NUMBER;

  CURSOR c_list_ids IS
  SELECT list_id
  FROM pa_object_dist_lists
  WHERE object_type = p_object_type
    AND object_id = p_object_id;

  --Bug# 4284420: Modified the cursor to avoid selecting end-dated fnd_users
  CURSOR c_dist_list(cp_list_id NUMBER) IS
  SELECT DISTINCT user_name, full_name, email_address FROM (
  SELECT p.user_name user_name,
         p.resource_source_name full_name,
         p.email_address email_address
  FROM pa_dist_list_items i,
       pa_project_parties_v p,
       fnd_user u
  WHERE i.list_id = cp_list_id
    AND i.access_level >= p_access_level
    AND i.recipient_type = 'PROJECT_PARTY'
    AND p.project_party_id = i.recipient_id
    AND p.object_type = l_object_type
    AND p.object_id = l_object_id
    AND u.user_name=p.user_name
    AND (TRUNC(SYSDATE) BETWEEN TRUNC(u.start_date) AND NVL(TRUNC(u.end_date),SYSDATE))
    AND trunc(sysdate) between p.start_date_active and nvl(p.end_date_active,sysdate + 1)
  UNION ALL
  SELECT p.user_name user_name,
         p.resource_source_name full_name,
         p.email_address email_address
  FROM pa_dist_list_items i,
       pa_project_parties_v p,
       fnd_user u
  WHERE i.list_id = cp_list_id
    AND i.access_level >= p_access_level
    AND i.recipient_type = 'PROJECT_ROLE'
    AND p.project_role_id = i.recipient_id
    AND p.object_type = l_object_type
    AND p.object_id = l_object_id
    AND u.user_name=p.user_name
    AND (TRUNC(SYSDATE) BETWEEN TRUNC(u.start_date) AND NVL(TRUNC(u.end_date),SYSDATE))
    AND trunc(sysdate) between p.start_date_active and nvl(p.end_date_active,sysdate + 1)
  UNION ALL
  SELECT p.user_name user_name,
         p.resource_source_name full_name,
         p.email_address email_address
  FROM pa_project_parties_v p,
       fnd_user u
  WHERE EXISTS (SELECT 1 FROM pa_dist_list_items i
                WHERE i.list_id = cp_list_id
                  AND i.access_level >= p_access_level
                  AND i.recipient_type = 'ALL_PROJECT_PARTIES')
    AND p.object_type = l_object_type
    AND p.object_id = l_object_id
    AND u.user_name=p.user_name
    AND (TRUNC(SYSDATE) BETWEEN TRUNC(u.start_date) AND NVL(TRUNC(u.end_date),SYSDATE))
    AND trunc(sysdate) between p.start_date_active and nvl(p.end_date_active,sysdate + 1)
  UNION ALL
  SELECT u.user_name user_name,
         hzp.party_name full_name,
         hzp.email_address email_address
  FROM pa_dist_list_items i,
       hz_parties hzp,
       fnd_user u
  WHERE i.list_id = cp_list_id
    AND i.access_level >= p_access_level
    AND i.recipient_type = 'HZ_PARTY'
    AND hzp.party_id = i.recipient_id
    AND SUBSTR(hzp.orig_system_reference, 1, 3) <> 'PER'
    AND u.person_party_id (+) = hzp.party_id
-- Bug 4527617. Replaced customer_id with person_party_id.
    AND (TRUNC(SYSDATE) BETWEEN TRUNC(u.start_date) AND NVL(TRUNC(u.end_date),SYSDATE))
  UNION ALL
  SELECT u.user_name user_name,
         per.full_name full_name,
         per.email_address email_address
  FROM pa_dist_list_items i,
       per_all_people_f per,
       fnd_user u
  WHERE i.list_id = cp_list_id
    AND i.access_level >= p_access_level
    AND i.recipient_type = 'HZ_PARTY'
    AND per.party_id = i.recipient_id
--Bug 2722021 added filter on eff dates
    AND (TRUNC(SYSDATE) BETWEEN TRUNC(per.effective_start_date)
			    AND TRUNC(per.effective_end_date))
    AND u.employee_id (+) = per.person_id
    AND (TRUNC(SYSDATE) BETWEEN TRUNC(u.start_date) AND NVL(TRUNC(u.end_date),SYSDATE))
  UNION ALL
  SELECT NULL user_name,
         NULL full_name,
         recipient_id email_address
  FROM pa_dist_list_items i
  WHERE i.list_id = cp_list_id
    AND i.access_level >= p_access_level
    AND i.recipient_type = 'EMAIL_ADDRESS');

BEGIN
  x_return_status := 'S';

  IF p_object_type = 'PA_OBJECT_PAGE_LAYOUT' THEN
    SELECT object_type, object_id
    INTO l_object_type, l_object_id
    FROM pa_object_page_layouts
    WHERE object_page_layout_id = p_object_id;
--dbms_output.put_line('object_id='||l_object_id);
  ELSE
--dbms_output.put_line('unhandled object type');
    x_return_status := 'U';
    RETURN;
  END IF;

  FOR l_rec IN c_list_ids LOOP
--dbms_output.put_line('list_id='||l_rec.list_id);
    FOR l_rec1 IN c_dist_list(l_rec.list_id) LOOP
--dbms_output.put_line('email='||l_rec1.email_address);
      IF x_user_names IS NULL THEN
        x_user_names := PA_VC_1000_150(l_rec1.user_name);
      ELSE
        x_user_names.EXTEND;
        x_user_names(x_user_names.COUNT) := l_rec1.user_name;
      END IF;

      IF x_full_names IS NULL THEN
        x_full_names := PA_VC_1000_150(l_rec1.full_name);
      ELSE
        x_full_names.EXTEND;
        x_full_names(x_full_names.COUNT) := l_rec1.full_name;
      END IF;

      IF x_email_addresses IS NULL THEN
        x_email_addresses := PA_VC_1000_150(l_rec1.email_address);
      ELSE
        x_email_addresses.EXTEND;
        x_email_addresses(x_email_addresses.COUNT) := l_rec1.email_address;
      END IF;

    END LOOP;
  END LOOP;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := 'E';
   WHEN OTHERS THEN
--dbms_output.put_line('unhandled exception');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_OBJECT_DIST_LISTS_UTILS',
                             p_procedure_name => 'GET_ACCESS_LEVEL',
                             p_error_text     => SUBSTRB(SQLERRM,1,240));
END get_dist_list;


/* Added for Bug 6843694
 * Returns the list of people to whom email notification has to be sent (username, fullname and email id)
 * Used in the Status Report flow
 */
PROCEDURE get_dist_list_email (
        p_object_type        IN   VARCHAR2,
        p_object_id          IN   VARCHAR2,
        p_access_level       IN   NUMBER,
        x_user_names         OUT  NOCOPY PA_VC_1000_150,
        x_full_names         OUT  NOCOPY PA_VC_1000_150,
        x_email_addresses    OUT  NOCOPY PA_VC_1000_150,
        x_return_status      OUT  NOCOPY VARCHAR2,
        x_msg_count          OUT  NOCOPY NUMBER,
        x_msg_data           OUT  NOCOPY VARCHAR2
)
IS
        l_object_type VARCHAR2(30);
        l_object_id NUMBER;
        l_return_value NUMBER := 0;
        i NUMBER;

        CURSOR c_list_ids IS
        SELECT list_id
        FROM pa_object_dist_lists
        WHERE object_type = p_object_type
        AND object_id = p_object_id;

        /*
         * 1. Modified this cursor to filter out records based on the value of the email column
         *    in pa_dist_list_items.
         * 2. Retrieve all team members if 'Send Status Report by email to all project team members'
         *    is selected.
         * 3. Removed the condition SELECT for ALL_PROJECT_PARTIES as this has nothing to do with
         *    email notifications.
         * 4. Null handled the SELECTs for customers and non team members.
         */
        CURSOR c_dist_list(cp_list_id NUMBER) IS
        SELECT DISTINCT user_name, full_name, email_address FROM (
                SELECT        p.user_name user_name,
                        p.resource_source_name full_name,
                        p.email_address email_address
                FROM        pa_dist_list_items i,
                        pa_project_parties_v p,
                        fnd_user u
                WHERE        i.list_id = cp_list_id
                        AND i.access_level >= p_access_level
                        AND i.recipient_type = 'PROJECT_PARTY'
                        AND p.project_party_id = i.recipient_id
                        AND p.object_type = l_object_type
                        AND p.object_id = l_object_id
                        AND u.user_name=p.user_name
                        AND (TRUNC(SYSDATE) BETWEEN TRUNC(u.start_date) AND NVL(TRUNC(u.end_date),SYSDATE))
			AND trunc(sysdate) between p.start_date_active and nvl(p.end_date_active,sysdate + 1)
                        AND NVL(i.email, 'Y') <> 'N'
                UNION ALL
                SELECT        p.user_name user_name,
                        p.resource_source_name full_name,
                        p.email_address email_address
                FROM        pa_dist_list_items i,
                        pa_project_parties_v p,
                        fnd_user u
                WHERE        i.list_id = cp_list_id
                        AND i.access_level >= p_access_level
                        AND i.recipient_type = 'PROJECT_ROLE'
                        AND p.project_role_id = i.recipient_id
                        AND p.object_type = l_object_type
                        AND p.object_id = l_object_id
                        AND u.user_name=p.user_name
                        AND (TRUNC(SYSDATE) BETWEEN TRUNC(u.start_date) AND NVL(TRUNC(u.end_date),SYSDATE))
			AND trunc(sysdate) between p.start_date_active and nvl(p.end_date_active,sysdate + 1)
                        AND NVL(i.email, 'Y') <> 'N'
                UNION ALL
                SELECT        u.user_name user_name,
                        hzp.party_name full_name,
                        hzp.email_address email_address
                FROM        pa_dist_list_items i,
                        hz_parties hzp,
                        fnd_user u
                WHERE        i.list_id = cp_list_id
                AND        i.access_level >= p_access_level
                        AND i.recipient_type = 'HZ_PARTY'
                        AND hzp.party_id = i.recipient_id
                        AND SUBSTR(hzp.orig_system_reference, 1, 3) <> 'PER'
                        AND u.customer_id (+) = hzp.party_id
                        AND ((u.customer_id IS NULL) OR
                                (TRUNC(SYSDATE) BETWEEN TRUNC(u.start_date) AND NVL(TRUNC(u.end_date),SYSDATE)))
                        AND nvl(i.email, 'Y') <> 'N'
                UNION ALL
                SELECT        u.user_name user_name,
                        per.full_name full_name,
                        per.email_address email_address
                FROM        pa_dist_list_items i,
                        per_all_people_f per,
                        fnd_user u
                WHERE        i.list_id = cp_list_id
                        AND i.access_level >= p_access_level
                        AND i.recipient_type = 'HZ_PARTY'
                        AND per.party_id = i.recipient_id
                        AND (TRUNC(SYSDATE) BETWEEN TRUNC(per.effective_start_date)
                                            AND TRUNC(per.effective_end_date))
                        AND u.employee_id (+) = per.person_id
                        AND ((u.employee_id IS NULL) OR
                                (TRUNC(SYSDATE) BETWEEN TRUNC(u.start_date) AND NVL(TRUNC(u.end_date),SYSDATE)))
                        AND nvl(i.email, 'Y') <> 'N'
                UNION ALL
                SELECT        NULL user_name,
                        NULL full_name,
                        recipient_id email_address
                FROM        pa_dist_list_items i
                WHERE        i.list_id = cp_list_id
                AND        i.access_level >= p_access_level
                AND        i.recipient_type = 'EMAIL_ADDRESS'
                AND nvl(i.email, 'Y') <> 'N'
                -- Send Status Report by email to all project team members
                UNION ALL
                SELECT        DISTINCT p.user_name user_name,
                        p.resource_source_name full_name,
                        p.email_address email_address
                FROM        pa_project_parties_v p,
                        fnd_user u
                WHERE EXISTS (        SELECT 1
                                FROM        pa_dist_list_items i
                                WHERE        i.list_id = cp_list_id
                                AND        i.access_level >= p_access_level
                                AND        i.recipient_type = 'EMAIL_ALL'
                        )
                AND p.object_type = l_object_type
                AND p.object_id = l_object_id
                AND u.user_name=p.user_name
                AND (TRUNC(SYSDATE) BETWEEN TRUNC(u.start_date) AND NVL(TRUNC(u.end_date),SYSDATE))
		AND trunc(sysdate) between p.start_date_active and nvl(p.end_date_active,sysdate + 1)
                AND p.party_type IN ('EMPLOYEE', 'PERSON')
        );


BEGIN
        x_return_status := 'S';

        IF p_object_type = 'PA_OBJECT_PAGE_LAYOUT' THEN
                SELECT object_type, object_id
                INTO l_object_type, l_object_id
                FROM pa_object_page_layouts
                WHERE object_page_layout_id = p_object_id;

        ELSE
                x_return_status := 'U';
                RETURN;
        END IF;

        FOR l_rec IN c_list_ids LOOP
                FOR l_rec1 IN c_dist_list(l_rec.list_id) LOOP
                        IF x_user_names IS NULL THEN
                                x_user_names := PA_VC_1000_150(l_rec1.user_name);
                        ELSE
                                x_user_names.EXTEND;
                                x_user_names(x_user_names.COUNT) := l_rec1.user_name;
                        END IF;

                        IF x_full_names IS NULL THEN
                                x_full_names := PA_VC_1000_150(l_rec1.full_name);
                        ELSE
                                x_full_names.EXTEND;
                                x_full_names(x_full_names.COUNT) := l_rec1.full_name;
                        END IF;

                        IF x_email_addresses IS NULL THEN
                                x_email_addresses := PA_VC_1000_150(l_rec1.email_address);
                        ELSE
                                x_email_addresses.EXTEND;
                                x_email_addresses(x_email_addresses.COUNT) := l_rec1.email_address;
                        END IF;

                END LOOP;
        END LOOP;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := 'E';
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_OBJECT_DIST_LISTS_UTILS',
                                        p_procedure_name => 'GET_DIST_LIST_EMAIL',
                                        p_error_text     => SUBSTRB(SQLERRM,1,240));
END get_dist_list_email;

-- added by atwang....copies the distribution list

   PROCEDURE copy_dist_list
    ( p_object_type_from IN VARCHAR2,
      p_object_id_from IN NUMBER,
      p_object_type_to IN VARCHAR2,
      p_object_id_to IN  NUMBER,
      P_CREATED_BY 		in NUMBER default fnd_global.user_id,
      P_CREATION_DATE 	in DATE default sysdate,
      P_LAST_UPDATED_BY 	in NUMBER default fnd_global.user_id,
      P_LAST_UPDATE_DATE 	in DATE default sysdate,
      P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
      x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      )
    IS

          -- Enter the procedure variables here. As shown below
     l_object_type VARCHAR2(30);
     l_object_id NUMBER;
     l_resource_type_id NUMBER(15);
     l_resource_source_id NUMBER(15);
     l_project_role_id NUMBER(15);
     l_list_id_from NUMBER(15);
     l_list_id_to NUMBER(15);
     l_recipient_type VARCHAR2(30);
     l_recipient_id VARCHAR2(150);
     l_access_level NUMBER(2);
     l_email VARCHAR2(2);
     l_menu_id NUMBER(15);
     l_list_item_id NUMBER(15);
     l_count NUMBER(15);
     l_project_party_id NUMBER(15);



    CURSOR get_object IS SELECT object_id, object_type
                FROM pa_object_page_layouts
                WHERE page_type_code = 'PPR'
                AND object_page_layout_id = p_object_id_to;

    CURSOR get_list_id_from IS SELECT list_id
                FROM pa_object_dist_lists
                WHERE object_type = p_object_type_from
                AND object_id = p_object_id_from;

    CURSOR get_list_id_to IS SELECT list_id
                FROM pa_object_dist_lists
                WHERE object_type = p_object_type_to
                AND object_id = p_object_id_to;

    CURSOR get_project_party_to IS SELECT b.project_party_id
                FROM pa_project_parties a, pa_project_parties b
                WHERE a.project_party_id = l_recipient_id
                AND b.object_type = a.object_type
                AND b.object_id = l_object_id
                AND b.resource_type_id = a.resource_type_id
                AND b.resource_source_id = a.resource_source_id
                AND b.project_role_id = a.project_role_id;

    CURSOR get_list_items IS SELECT recipient_type, recipient_id, access_level, email, menu_id
                FROM pa_dist_list_items
                WHERE list_id = l_list_id_from;


    BEGIN

-- Check to see that no distribution list currently exists
        OPEN get_list_id_to;
        FETCH get_list_id_to INTO l_list_id_to;
        IF get_list_id_to%FOUND THEN
            CLOSE get_list_id_to;
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('PA','PA_DL_LIST_ID_INV');
            fnd_msg_pub.add();
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            return;
        END IF;
        CLOSE get_list_id_to;
        OPEN get_object;
        FETCH get_object INTO  l_object_id,l_object_type;
        CLOSE get_object;

        OPEN get_list_id_from;
        FETCH get_list_id_from INTO l_list_id_from;
        CLOSE get_list_id_from;
        select pa_distribution_lists_s.nextVal into l_list_id_to from dual;

        -- create new entry into pa_distribution_lists

        PA_DISTRIBUTION_LISTS_PVT.CREATE_DIST_LIST(P_VALIDATE_ONLY => 'F',
                                                    P_LIST_ID => l_list_id_to,
                                                    P_NAME => l_list_id_to,
                                                    P_DESCRIPTION => l_list_id_to,
                                                    x_return_status => x_return_status,
                                                    x_msg_count => x_msg_count,
                                                    x_msg_data => x_msg_data);
        IF x_return_status<>'S' THEN
            RETURN;
        END IF;

        -- create new entry into pa_object_dist_lists table

        PA_OBJECT_DIST_LISTS_PVT.CREATE_OBJECT_DIST_LIST(P_VALIDATE_ONLY => 'F',
                                                            P_LIST_ID => l_list_id_to,
                                                            P_OBJECT_TYPE => p_object_type_to,
                                                           P_OBJECT_ID => p_object_id_to,
                                                            x_return_status => x_return_status,
                                                            x_msg_count => x_msg_count,
                                                            x_msg_data => x_msg_data);
        IF x_return_status<>'S' THEN
            RETURN;
        END IF;

            --Loop to copy all items
        FOR c_list_item IN get_list_items LOOP
                l_recipient_type := c_list_item.recipient_type;
                l_recipient_id := c_list_item.recipient_id;
                l_access_level := c_list_item.access_level;
                l_email := c_list_item.email;
                l_menu_id := c_list_item.menu_id;

                -- If the item is a project_party type, need to find the corresponding project_party_id for
                -- the new object

                IF (l_recipient_type = 'PROJECT_PARTY') THEN
                    OPEN get_project_party_to;
                    FETCH get_project_party_to INTO l_project_party_id;
                    CLOSE get_project_party_to;
                    l_recipient_id := l_project_party_id;
                END IF;

                -- Fix for bug#8247832, Check_dist_list_items_exists function is called before calling CREATE_DIST_LIST_ITEM
                -- and if there already exists, update_dist_list_item is called
                IF (PA_DISTRIBUTION_LIST_UTILS.Check_dist_list_items_exists(
                        p_list_id        => l_list_id_to,
                        p_recipient_type => l_recipient_type,
                        p_recipient_id   => l_recipient_id)) THEN

                    PA_DISTRIBUTION_LISTS_PVT.UPDATE_DIST_LIST_ITEM(P_VALIDATE_ONLY => 'F',
                                                                  P_LIST_ITEM_ID => l_list_item_id,
                                                                  P_LIST_ID => l_list_id_to,
                                                                  P_RECIPIENT_TYPE => l_recipient_type,
                                                                  P_RECIPIENT_ID => l_recipient_id,
                                                                  P_ACCESS_LEVEL => l_access_level,
                                                                  P_EMAIL => l_email,
                                                                  P_MENU_ID => l_menu_id,
                                                                  x_return_status => x_return_status,
                                                                  x_msg_count => x_msg_count,
                                                                  x_msg_data => x_msg_data);
	                 IF x_return_status<>'S' THEN
	                    RETURN;
	                 END IF;
                ELSE


								-- Added for bug 7585916. Receipient Id null should coz failure the processing
								-- copy project we can avoid creating dist list items for such receipients and
								-- proceed.
                IF l_recipient_id IS NOT NULL THEN

	                select pa_dist_list_items_s.nextVal into l_list_item_id from dual;

	                PA_DISTRIBUTION_LISTS_PVT.CREATE_DIST_LIST_ITEM(P_VALIDATE_ONLY => 'F',
	                                                              P_LIST_ITEM_ID => l_list_item_id,
	                                                              P_LIST_ID => l_list_id_to,
	                                                              P_RECIPIENT_TYPE => l_recipient_type,
	                                                              P_RECIPIENT_ID => l_recipient_id,
	                                                              P_ACCESS_LEVEL => l_access_level,
	                                                              P_EMAIL => l_email,
	                                                              P_MENU_ID => l_menu_id,
	                                                              x_return_status => x_return_status,
	                                                              x_msg_count => x_msg_count,
	                                                              x_msg_data => x_msg_data);

	                 IF x_return_status<>'S' THEN
	                    RETURN;
	                 END IF;

	        END IF;

                END IF;
        END LOOP;
   END;

 Function Check_valid_dist_list_item_id (
                        p_list_item_id in Number )
 return VARCHAR2
 IS
 Cursor C1 is
 Select 'X' from pa_dist_list_items
 where list_item_id = p_list_item_id;

 l_dummy   varchar2(1);
 l_return_status  varchar2(1) := 'T';
 Begin
  Open C1;
  fetch C1 into l_dummy;
  if (C1%NOTFOUND) then
   l_return_status := 'F';
  else
   l_return_status := 'T';
  end if;
  close C1;

  return l_return_status;

 Exception
  When others then
   RAISE;

 End Check_valid_dist_list_item_id;




END  PA_DISTRIBUTION_LIST_UTILS;

/
