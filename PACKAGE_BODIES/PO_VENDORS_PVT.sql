--------------------------------------------------------
--  DDL for Package Body PO_VENDORS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VENDORS_PVT" AS
/* $Header: POXVVENB.pls 120.3.12010000.4 2014/03/17 05:15:10 shipwu ship $ */


-------------------------------------------------------------------------------
--Start of Comments
--Name: get_po_vendor_id_for_user
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- Get the vendor id (as in PO_VENDORS table ) for a given
-- user name ( as in FND_USER table)
--Parameters:
--IN:
--p_usename
--  fnd username
--Returns
--  vendor id from the PO_VENDORS table.
--Notes:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

FUNCTION get_po_vendor_id_for_user(p_username IN VARCHAR2)
RETURN NUMBER IS
 l_vendor_id number;
BEGIN

        -- SQL What: select PO vendor id for a giver user name
        -- SQL Why: for given fnd username ensure po vendor entry exists
        -- SQL join: fnd_user.username
        -- Moving the logic to the View.Also we do not use
        -- POS_EMPLOYMENT/POS_VENDOR_PARTY any more in R12.

        select vendor_id
        into l_vendor_id
        from pos_supplier_users_v
        where  user_name = p_username;

        return l_vendor_id;
EXCEPTION
    WHEN OTHERS THEN
      return -1;
END get_po_vendor_id_for_user;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_supplier_userlist
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure is sliced from PO_REQAPPROVAL_INIT1 package to return a list
--  of supplier users on a supplier PO document. This procedure is called by
--  Contracts team to determine the supplier users to send notifications to,
--  when deliverables undergo a status change (example: it is overdue) and
--  supplier user is not specified on the deliverable.
--  Other refereces - PO_REQAPPROVAL_INIT1.locate_notifier
--                    Transportation.
--                    PO_CONTERMS_UTL_GRP.get_external_userlist
--Parameters:
--IN:
--p_document_id
--  PO header ID
--p_document_type
--  Contracts business document type ex: PA_BLANKET or PO_STANDARD
--  This will be parsed to retrieve the PO document type
--p_external_contact_id
--  Supplier contact id on the deliverable. Default is null
--OUT:
--x_return_status
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--x_supplier_user_tbl
--  PL/SQL table to FND_USER.username for Contracts
--x_supplier_userlist
--  comma delimited supplier user names for locate_notifier to retain
--  backward compatibility
--x_supplier_userlist_for_sql
--  space delimited supplier user names for locate_notifier to retain
--  backward compatibility
--x_num_users
--  No of supplier users for locate_notifier to retain backwards compatibility
--x_vendor_id
--  PO document vendor id for locate_notifier to retain backward compatibility
--Notes:
--  SAHEGDE 07/18/2003
--  This procedure was sliced from the locate_notifier procedure in the
--  PO_REQAPPROVAL_INIT1 package to allow calling it from multiple procedures.
--  In order to retain backward compatibility with locate notifier curently
--  procedure returns the names as VARCHAR2 as well as a PL/SQL table. Going
--  forward the code will be refactored to return only PL/SQL table and calling
--  code in PO_REQAPPROVAL_INIT1 will be modified to reflect this change.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_supplier_userlist(p_document_id               IN  NUMBER
                               ,p_document_type             IN  VARCHAR2
			       ,p_external_contact_id       IN  NUMBER DEFAULT NULL
                               ,x_return_status             OUT NOCOPY VARCHAR2
                               ,x_supplier_user_tbl         OUT NOCOPY supplier_user_tbl_type
                               ,x_supplier_userlist         OUT NOCOPY VARCHAR2
                               ,x_supplier_userlist_for_sql OUT NOCOPY VARCHAR2
                               ,x_num_users                 OUT NOCOPY NUMBER
                               ,x_vendor_id                 OUT NOCOPY NUMBER)IS


   -- declare local and out variables
   l_user_name                  varchar2(100);
   l_user_id                    number;
   l_vendor_contact_id          number;
   l_vendor_id                  number;
   l_vendor_site_id             number;
   l_step                       varchar2(32000);
   l_temp                       varchar2(100);

   l_num_users                  number := 0;
   l_namelist                   VARCHAR2(31990) := NULL;
   l_namelist_for_sql           VARCHAR2(32000) := NULL;
   l_supplier_user_tbl          supplier_user_tbl_type;
   l_progress                   VARCHAR2(3) := '000';
   l_parent_vendor_id           number;
   l_vendor_id_of_user          number;
   l_add_to_list_flag           VARCHAR2(1):='N';

   l_api_name CONSTANT VARCHAR2(30) := 'get_supplier_userlist';

   -- declare cursor
   -- cursor to select vendor level contacts
   cursor vendor_only_username(v_vendor_id NUMBER) IS
   select DISTINCT user1.user_name
   from fnd_user user1,
   ak_web_user_sec_attr_values ak1,
   fnd_user_resp_groups fur
   where ak1.attribute_code='ICX_SUPPLIER_ORG_ID'
   and ak1.number_value=v_vendor_id
   and ak1.ATTRIBUTE_APPLICATION_ID=177
   and ak1.web_user_id=user1.user_id
   and fur.responsibility_application_id = 177
   and fur.start_date < sysdate
   and nvl(fur.end_date, sysdate + 1) >= sysdate
   and fur.user_id = user1.user_id
   and trunc(sysdate)
       BETWEEN nvl(trunc(user1.start_date), trunc(sysdate))
       AND nvl(trunc(user1.end_date), trunc(sysdate))
   and not exists(
         select 1
         from ak_web_user_sec_attr_values ak2
         where ak2.attribute_code='ICX_SUPPLIER_CONTACT_ID'
         and ak2.web_user_id=ak1.web_user_id
         and ak2.ATTRIBUTE_APPLICATION_ID=177)
   and not exists(
         select 1
         from ak_web_user_sec_attr_values ak3
         where  ak3.attribute_code='ICX_SUPPLIER_SITE_ID'
               and ak3.web_user_id=ak1.web_user_id
               and ak3.ATTRIBUTE_APPLICATION_ID=177)
   order by user1.user_name;

   -- cusrsor to select vendor and site level contacts
  cursor vendor_site_username(v_vendor_id NUMBER
                             , v_vendor_site_id number) IS
   select DISTINCT user1.user_name
   from fnd_user user1,
   ak_web_user_sec_attr_values ak1,
   ak_web_user_sec_attr_values ak2,
   fnd_user_resp_groups fur
   where
   user1.user_id=ak1.web_user_id
   and ak1.attribute_code='ICX_SUPPLIER_ORG_ID'
   and ak1.number_value=v_vendor_id
   and ak1.ATTRIBUTE_APPLICATION_ID=177
   and ak2.attribute_code='ICX_SUPPLIER_SITE_ID'
   and ak2.number_value=v_vendor_site_id
   and ak2.ATTRIBUTE_APPLICATION_ID=177
   and ak1.web_user_id=ak2.web_user_id
   and fur.responsibility_application_id = 177
   and fur.user_id = user1.user_id
   and fur.start_date < sysdate
   and nvl(fur.end_date, sysdate + 1) >= sysdate
   and trunc(sysdate)
       BETWEEN nvl(trunc(user1.start_date), trunc(sysdate))
       AND nvl(trunc(user1.end_date), trunc(sysdate))
   and v_vendor_site_id not in
       (select pvc.vendor_site_id
        from po_vendor_contacts pvc
             , ak_web_user_sec_attr_values ak3
        where ak3.attribute_code='ICX_SUPPLIER_CONTACT_ID'
        and ak3.web_user_id=ak1.web_user_id
        and ak3.ATTRIBUTE_APPLICATION_ID=177
        and ak3.number_value=pvc.vendor_contact_id)
   order by user1.user_name;

   -- cursor to select specified contacts for the vendor
  cursor vendor_contact_username(v_vendor_id NUMBER
                                , v_vendor_contact_id NUMBER) IS
   select DISTINCT user1.user_name
   from fnd_user user1,
   ak_web_user_sec_attr_values ak1,
   ak_web_user_sec_attr_values ak3,
   fnd_user_resp_groups fur
   where user1.user_id=ak1.web_user_id
   and ak1.attribute_code='ICX_SUPPLIER_ORG_ID'
   and ak1.number_value=v_vendor_id
   and ak1.ATTRIBUTE_APPLICATION_ID=177
   and ak3.attribute_code='ICX_SUPPLIER_CONTACT_ID'
   and ak3.number_value=v_vendor_contact_id
   and ak3.ATTRIBUTE_APPLICATION_ID=177
   and ak1.web_user_id=ak3.web_user_id
   and fur.responsibility_application_id  = 177
   and fur.user_id = user1.user_id
   and fur.start_date < sysdate
   and nvl(fur.end_date, sysdate + 1) >= sysdate
   and trunc(sysdate)
       BETWEEN nvl(trunc(user1.start_date), trunc(sysdate))
       AND nvl(trunc(user1.end_date), trunc(sysdate))
   order by user1.user_name;

BEGIN

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_num_users := 0;
   l_step := 0;
   l_progress := '010';

   begin
      if (p_document_type in ('PO', 'PA')) THEN
	 l_progress := '020';
         select DECODE(p_external_contact_id, null, vendor_contact_id, p_external_contact_id) vendor_contact_id
           ,vendor_site_id, vendor_id, to_char(revision_num)
         into l_vendor_contact_id
           ,l_vendor_site_id, l_vendor_id, l_temp
         from po_headers_all
         where po_header_id = to_number(p_document_id);

       elsif (p_document_type = 'RELEASE') THEN
	 l_progress := '030';

         select poh.vendor_contact_id
           ,poh.vendor_site_id, poh.vendor_id
           , to_char(por.revision_num)
         into l_vendor_contact_id
           ,l_vendor_site_id, l_vendor_id
           , l_temp
         from po_releases por, po_headers poh
         where por.po_release_id = to_number(p_document_id)
	   and por.po_header_id = poh.po_header_id;

       elsif (p_document_type in ('RS')) then -- Bug 3197483
	 l_progress := '040';

         select vendor_contact_id, vendor_site_id
           , vendor_id, to_char(null)
         into l_vendor_contact_id, l_vendor_site_id
	   , l_vendor_id, l_temp
         from po_requisition_suppliers
	   where requisition_supplier_id = to_number(p_document_id);

       elsif (p_document_type in ('RQ')) then -- Bug 3626250
	 l_progress := '050';

        select vendor_contact_id, vendor_site_id, vendor_id, to_char(null)
	  into l_vendor_contact_id, l_vendor_site_id, l_vendor_id, l_temp
	  from po_requisition_lines_all
	  where requisition_line_id = to_number(p_document_id);
       ELSE
	 l_progress := '060';
      end if;
    exception
     when no_data_found then
       l_vendor_contact_id := null;
       l_vendor_site_id := null;
       l_vendor_id:=null;
    end;

	 l_progress := '070';

     l_step := '1' ;
     if(l_vendor_contact_id is not null) then
       open vendor_contact_username
           (l_vendor_id
           , l_vendor_contact_id);
       loop
       fetch vendor_contact_username into l_user_name;
       exit when vendor_contact_username%NOTFOUND;
      l_vendor_id_of_user:=get_po_vendor_id_for_user (l_user_name);

       if(l_vendor_id <> l_vendor_id_of_user) then
         select parent_vendor_id into l_parent_vendor_id
         from po_vendors
         where vendor_id =l_vendor_id;

            if(l_parent_vendor_id is NOT NULL AND
                  l_parent_vendor_id=l_vendor_id_of_user) then
               l_add_to_list_flag := 'Y';
            end if;
       else
           l_add_to_list_flag := 'Y';
       end if;


       if (l_add_to_list_flag = 'Y') then
           if(l_namelist is null) then
             l_num_users := l_num_users + 1;
             l_namelist_for_sql := ''''||l_user_name||'''';
             l_namelist:= l_user_name;
           else
             l_num_users := l_num_users + 1;
             l_namelist_for_sql :=
                l_namelist_for_sql||','||''''||l_user_name||'''';
             --Bug 18130769 Start: Concatenated using a comma rather than a space.
             l_namelist:=l_namelist||','||l_user_name;
             --Bug 18130769 End
           end if;
           x_supplier_user_tbl(l_num_users) := l_user_name;
         end if;
       end loop;
       close vendor_contact_username;

     end if; -- vendor id is null

     l_step := '2'||l_namelist ;
     if(l_namelist IS NULL) then

       open vendor_site_username
           (l_vendor_id
           , l_vendor_site_id);
       loop
       fetch vendor_site_username into l_user_name;
       exit when vendor_site_username%NOTFOUND;
       l_vendor_id_of_user:=get_po_vendor_id_for_user (l_user_name);

       if(l_vendor_id <> l_vendor_id_of_user) then
         select parent_vendor_id into l_parent_vendor_id
         from po_vendors
         where vendor_id =l_vendor_id;

            if(l_parent_vendor_id is NOT NULL AND
                  l_parent_vendor_id=l_vendor_id_of_user) then
               l_add_to_list_flag := 'Y';
            end if;
       else
            l_add_to_list_flag := 'Y';
       end if;


       if (l_add_to_list_flag = 'Y') then
           if(l_namelist is null) then
             l_num_users := l_num_users + 1;
             l_namelist_for_sql := ''''||l_user_name||'''';
             l_namelist:= l_user_name;
           else
             l_num_users := l_num_users + 1;
             l_namelist_for_sql :=
                l_namelist_for_sql||','||''''||l_user_name||'''';
             --Bug 18130769 Start: Concatenated using a comma rather than a space.
             l_namelist:=l_namelist||','||l_user_name;
             --Bug 18130769 End
           end if;
           x_supplier_user_tbl(l_num_users) := l_user_name;
         end if;
       end loop;
       close vendor_site_username;

     end if; -- vendor id is null

	 l_progress := '080';
     l_step := '3'||l_namelist ;
     if(l_namelist IS NULL) then

       open vendor_only_username(l_vendor_id);
       loop
       fetch vendor_only_username into l_user_name;
       exit when vendor_only_username%NOTFOUND;
      l_vendor_id_of_user:=get_po_vendor_id_for_user (l_user_name);

       if(l_vendor_id <> l_vendor_id_of_user) then
         select parent_vendor_id into l_parent_vendor_id
         from po_vendors
         where vendor_id =l_vendor_id;

            if(l_parent_vendor_id is NOT NULL AND
                   l_parent_vendor_id=l_vendor_id_of_user) then
               l_add_to_list_flag := 'Y';
            end if;
       else
           l_add_to_list_flag := 'Y';
       end if;

       if (l_add_to_list_flag = 'Y') then
           if(l_namelist is null) then
             l_num_users := l_num_users + 1;
             l_namelist_for_sql := ''''||l_user_name||'''';
             l_namelist:= l_user_name;
           else
             l_num_users := l_num_users + 1;
             l_namelist_for_sql :=
                l_namelist_for_sql||','||''''||l_user_name||'''';
             --Bug 18130769 Start: Concatenated using a comma rather than a space.
             l_namelist:=l_namelist||','||l_user_name;
             --Bug 18130769 End
           end if;
           x_supplier_user_tbl(l_num_users) := l_user_name;
         end if;
       end loop;
       close vendor_only_username;

     end if; -- vendor id is null
	 l_progress := '090';
     -- populate the out parameters
     x_supplier_userlist := l_namelist;
     x_supplier_userlist_for_sql := l_namelist_for_sql;
     x_num_users := l_num_users;
     x_vendor_id := l_vendor_id;

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         IF (g_fnd_debug='Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             FND_LOG.string(log_level => FND_LOG.level_unexpected
                         ,module    => g_module_prefix ||l_api_name || ' ' ||l_progress
			  ,message   => SQLERRM);
           END IF;


         END IF;
     END IF;

END get_supplier_userlist;


END PO_VENDORS_PVT ;

/
