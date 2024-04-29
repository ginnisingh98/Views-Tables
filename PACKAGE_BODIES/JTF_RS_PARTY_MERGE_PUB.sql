--------------------------------------------------------
--  DDL for Package Body JTF_RS_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_PARTY_MERGE_PUB" AS
/* $Header: jtfrsbmb.pls 120.0.12000000.2 2007/04/02 23:28:09 nsinghai ship $ */

/************************************************************

This is the part and party site merge package for jtf resources

 *****************************************************************************/
PROCEDURE synchronize_resource(p_resource_id       IN  NUMBER,
                               p_category          IN  VARCHAR2,
                               p_address_id        IN  NUMBER,
                               p_source_id         IN  NUMBER,
                               x_ret_status        out NOCOPY VARCHAR2);


PROCEDURE resource_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2)
IS

cursor cat_cur(l_source_id number)
    is
  select     resource_id
	     ,category
             ,resource_number
             ,address_id
             ,contact_id
             ,object_version_number
             , created_by
             , creation_date
             , last_updated_by
             , last_update_date
             , last_update_login
 from  jtf_rs_resource_extns
where  source_id = l_source_id
  and  category IN ('PARTY','PARTNER') ;

cursor to_party_cur(l_party_id number)
    is
select resource_id
 from  jtf_rs_resource_extns
 where  category   = 'PARTY'
  and  source_id = l_party_id;

to_party_rec to_party_cur%rowtype;

cursor to_partner_cur(l_party_id number)
    is
select resource_id
 from  jtf_rs_resource_extns
 where  category   = 'PARTNER'
 and  source_id = l_party_id;

to_partner_rec to_partner_cur%rowtype;

cursor partner_cur(l_party_id in number)
    is
  SELECT  par.party_type,
          prt.party_site_id address_id
    FROM  hz_parties par,
          hz_party_sites prt
   WHERE  par.party_id = l_party_id
     AND  par.party_id = prt.party_id(+)
     AND  nvl(prt.identifying_address_flag, 'Y') = 'Y'
     AND  nvl(prt.status, 'A') = 'A';

partner_rec partner_cur%rowtype;

cursor party_addr_cur(l_party_id in number)
    is
select prt.party_site_id address_id
  from hz_party_sites prt
 where prt.party_id = l_party_id
   and prt.identifying_address_flag = 'Y'
   and prt.status = 'A';

party_addr_rec party_addr_cur%rowtype;

l_api_name varchar2(30) :=  'RESOURCE_PARTY_MERGE';
l_date  Date;
l_user_id  Number;
l_login_id  Number;
l_address_id number;
-------------------------------------
l_error_handle varchar2(30) ;
L_OBJECT_VER_NUMBER   NUMBER;
L_RETURN_STATUS       VARCHAR2(2);
L_MSG_COUNT           NUMBER;
L_MSG_DATA            VARCHAR2(2000);
-------------------------------------

begin
  --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);
-------------------------------------
   l_error_handle := NVL(FND_PROFILE.Value('JTF_RS_PARTY_MRG_FRMID_TOID_ER'),'ERROR');
-------------------------------------
savepoint party_merge_sp;

-----Debug Messages--------------------
FND_FILE.put_line(fnd_file.log, '                      ------------------Resource Party Merge-----------------');
FND_FILE.put_line(fnd_file.log, '                      Begin JTF_RS_PARTY_MERGE_PUB.resource_party_merge(+) ');
FND_FILE.put_line(fnd_file.log, '                        p_entity_name       :'||p_entity_name);
FND_FILE.put_line(fnd_file.log, '                        p_from_id           :'||p_from_id);
FND_FILE.put_line(fnd_file.log, '                        p_from_fk_id        :'||p_from_fk_id);
FND_FILE.put_line(fnd_file.log, '                        p_to_fk_id          :'||p_to_fk_id);
FND_FILE.put_line(fnd_file.log, '                        p_parent_entity_name:'||p_parent_entity_name);
FND_FILE.put_line(fnd_file.log, '                        p_batch_id          :'||p_batch_id);
FND_FILE.put_line(fnd_file.log, '                        p_batch_party_id    :'||p_batch_party_id);
FND_FILE.put_line(fnd_file.log, '                      Error Handling Mode   :'||l_error_handle);
-----End Debug Messages----------------

x_return_status := fnd_api.g_ret_sts_success;

if (p_entity_name <> 'JTF_RS_RESOURCE_EXTNS')
   or (p_parent_entity_name <> 'HZ_PARTIES')
then
   fnd_message.set_name ('JTF', 'JTF_RS_ENTITY_NAME_ERR');
   fnd_message.set_token('P_ENTITY',p_entity_name);
   fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
   FND_MSG_PUB.add;
   RAISE fnd_api.g_exc_error;
end if;

FOR cat_rec IN cat_cur(p_from_fk_id) LOOP
l_address_id := cat_rec.address_id;
if (cat_rec.category = 'PARTY')
THEN
  open to_party_cur(p_to_fk_id);
  fetch to_party_cur into to_party_rec;
  if(to_party_cur%found)
  then
----------------------------------------------------
      -- Check if user wants to end date the record before erroring the process itself.
      IF (l_error_handle = 'END_DATE')  THEN

        /* even if it says end date employee, it is for end dating all type of resources */
        /* End Date the cat_rec.resource_id resource i.e. the one which we want to anyway change to new party */

        l_object_ver_number := cat_rec.object_version_number ;

/* Calling publish API to raise merge resource event. Fix for Enhancement: 3295476 */
    begin
       jtf_rs_wf_events_pub.merge_resource
              (p_api_version               => 1.0
              ,p_init_msg_list             => fnd_api.g_false
              ,p_commit                    => fnd_api.g_false
              ,p_resource_id               => cat_rec.resource_id
              ,p_repl_resource_id          => to_party_rec.resource_id
              ,p_end_date_active           => trunc(sysdate-1)
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data);

    EXCEPTION when others then
       null;
    end;

/* End of publish API call */

        JTF_RS_RESOURCE_UTL_PUB.END_DATE_EMPLOYEE
          (P_API_VERSION          => 1.0,
           P_INIT_MSG_LIST        => FND_API.G_FALSE,
           P_COMMIT               => FND_API.G_FALSE,
           P_RESOURCE_ID          => cat_rec.resource_id,
           P_END_DATE_ACTIVE      => trunc(sysdate-1) ,
           X_OBJECT_VER_NUMBER    => l_object_ver_number,
           X_RETURN_STATUS        => l_return_status,
           X_MSG_COUNT            => l_msg_count,
           X_MSG_DATA             => l_msg_data ) ;

        IF (nvl(l_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success) then
          x_return_status := l_return_status ;
          fnd_message.set_name ('JTF', 'JTF_RS_REJECT_MERGE');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
        END IF;

      ELSIF (l_error_handle = 'ERROR')  THEN
----------------------------------------------------
        -- reject merge
        fnd_message.set_name ('JTF', 'JTF_RS_REJECT_MERGE');
        FND_MSG_PUB.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
----------------------------------------------------
      END IF;
----------------------------------------------------
  else
     l_address_id := null ;
     open party_addr_cur(p_to_fk_id);
     fetch party_addr_cur into l_address_id;
     close party_addr_cur;

     -- update from record with new source id
     update jtf_rs_resource_extns
        set source_id = p_to_fk_id,
            address_id = l_address_id,
            object_version_number = object_version_number + 1
     where  resource_id = cat_rec.resource_id;

--   x_to_id := p_from_id;

    if(nvl(l_address_id, fnd_api.g_miss_num) <> nvl(cat_rec.address_id, fnd_api.g_miss_num))
    then
       insert into JTF_RS_RESOURCE_EXTN_AUD (
       RESOURCE_AUDIT_ID,
       RESOURCE_ID,
       OLD_SOURCE_ID,
       NEW_SOURCE_ID,
       OLD_ADDRESS_ID,
       NEW_ADDRESS_ID,
       NEW_OBJECT_VERSION_NUMBER,
       OLD_OBJECT_VERSION_NUMBER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN
       ) values (
       JTF_RS_RESOURCE_EXTN_AUD_S.NEXTVAL,
       cat_rec.resource_id,
       p_from_fk_id,
       p_to_fk_id,
       cat_rec.address_id,
       l_address_id,
       cat_rec.object_version_number + 1,
       cat_rec.object_version_number,
       l_user_id,
       l_date,
       l_user_id,
       l_date,
       l_login_id
    );
  else
     insert into JTF_RS_RESOURCE_EXTN_AUD (
       RESOURCE_AUDIT_ID,
       RESOURCE_ID,
       OLD_SOURCE_ID,
       NEW_SOURCE_ID,
       NEW_OBJECT_VERSION_NUMBER,
       OLD_OBJECT_VERSION_NUMBER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN
       ) values (
       JTF_RS_RESOURCE_EXTN_AUD_S.NEXTVAL,
       cat_rec.resource_id,
       p_from_fk_id,
       p_to_fk_id,
       cat_rec.object_version_number + 1,
       cat_rec.object_version_number,
       l_user_id,
       l_date,
       l_user_id,
       l_date,
       l_login_id
    );
   end if;

  --synchrnize this resource
   synchronize_resource(p_resource_id => cat_rec.resource_id,
                        p_category    => cat_rec.category,
                        p_address_id  => l_address_id,
                        p_source_id  => p_to_fk_id,
                        x_ret_status => x_return_status);

     if(x_return_status <> fnd_api.g_ret_sts_success)
     then
         RAISE fnd_api.g_exc_error;
     end if;
  end if;
  close to_party_cur;
end if; -- party

if (cat_rec.category = 'PARTNER')
then
  open to_partner_cur(p_to_fk_id);
  fetch to_partner_cur into to_partner_rec;
  if (to_partner_cur%found)
  then
----------------------------------------------------
      -- Check if user wants to end date the record before erroring the process itself.
      IF (l_error_handle = 'END_DATE')  THEN

        /* even if it says end date employee, it is for end dating all type of resources */
        /* End Date the cat_rec.resource_id resource i.e. the one which we want to anyway change to new party */

        l_object_ver_number := cat_rec.object_version_number ;

/* Calling publish API to raise merge resource event. Fix for Enhancement: 3295476 */

    begin
       jtf_rs_wf_events_pub.merge_resource
              (p_api_version               => 1.0
              ,p_init_msg_list             => fnd_api.g_false
              ,p_commit                    => fnd_api.g_false
              ,p_resource_id               => cat_rec.resource_id
              ,p_repl_resource_id          => to_partner_rec.resource_id
              ,p_end_date_active           => trunc(sysdate-1)
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data);

    EXCEPTION when others then
       null;
    end;

/* End of publish API call */

        JTF_RS_RESOURCE_UTL_PUB.END_DATE_EMPLOYEE
          (P_API_VERSION          => 1.0,
           P_INIT_MSG_LIST        => FND_API.G_FALSE,
           P_COMMIT               => FND_API.G_FALSE,
           P_RESOURCE_ID          => cat_rec.resource_id,
           P_END_DATE_ACTIVE      => trunc(sysdate-1) ,
           X_OBJECT_VER_NUMBER    => l_object_ver_number,
           X_RETURN_STATUS        => l_return_status,
           X_MSG_COUNT            => l_msg_count,
           X_MSG_DATA             => l_msg_data ) ;

        IF (nvl(l_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success) then
          x_return_status := l_return_status ;
          fnd_message.set_name ('JTF', 'JTF_RS_REJECT_MERGE');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
        END IF;

      ELSIF (l_error_handle = 'ERROR')  THEN
----------------------------------------------------
        -- reject merge
        fnd_message.set_name ('JTF', 'JTF_RS_REJECT_MERGE');
        FND_MSG_PUB.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
----------------------------------------------------
      END IF;
----------------------------------------------------
  else
   --get primary address of the new party if party_type = 'PARTY_RELATIONSHIP'
    l_address_id := null ;
    open partner_cur(p_to_fk_id);
    fetch partner_cur into partner_rec;
    close partner_cur;

    if(partner_rec.party_type = 'PARTY_RELATIONSHIP')
    then
         l_address_id := partner_rec.address_id;
    else
         l_address_id := cat_rec.address_id;
    end if;

   -- update from record with new source id
     update jtf_rs_resource_extns
        set source_id = p_to_fk_id,
            address_id = l_address_id,
            object_version_number = object_version_number + 1
      where resource_id = cat_rec.resource_id;
--     x_to_id := p_from_id;

     if(nvl(l_address_id, fnd_api.g_miss_num) <> nvl(cat_rec.address_id, fnd_api.g_miss_num))
     then
       insert into JTF_RS_RESOURCE_EXTN_AUD (
             RESOURCE_AUDIT_ID,
             RESOURCE_ID,
             OLD_SOURCE_ID,
             NEW_SOURCE_ID,
             OLD_ADDRESS_ID,
             NEW_ADDRESS_ID,
             NEW_OBJECT_VERSION_NUMBER,
             OLD_OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            ) values (
            JTF_RS_RESOURCE_EXTN_AUD_S.NEXTVAL,
               cat_rec.resource_id,
               p_from_fk_id,
               p_to_fk_id,
               cat_rec.address_id,
               l_address_id,
               cat_rec.object_version_number + 1,
               cat_rec.object_version_number,
               l_user_id,
               l_date,
               l_user_id,
               l_date,
               l_login_id
             );
     else
       insert into JTF_RS_RESOURCE_EXTN_AUD (
             RESOURCE_AUDIT_ID,
             RESOURCE_ID,
             OLD_SOURCE_ID,
             NEW_SOURCE_ID,
             NEW_OBJECT_VERSION_NUMBER,
             OLD_OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            ) values (
            JTF_RS_RESOURCE_EXTN_AUD_S.NEXTVAL,
               cat_rec.resource_id,
               p_from_fk_id,
               p_to_fk_id,
               cat_rec.object_version_number + 1,
               cat_rec.object_version_number,
               l_user_id,
               l_date,
               l_user_id,
               l_date,
               l_login_id
             );
     end if;

       synchronize_resource(p_resource_id => cat_rec.resource_id,
                            p_category    => cat_rec.category,
                            p_address_id  => l_address_id,
                            p_source_id  => p_to_fk_id,
                            x_ret_status => x_return_status);
     if(x_return_status <> fnd_api.g_ret_sts_success)
     then
         RAISE fnd_api.g_exc_error;
     end if;

  end if;
  close to_partner_cur;
end if; -- end of partner
END LOOP;-- end of cat_cur loop

FND_FILE.put_line(fnd_file.log, '                      End JTF_RS_PARTY_MERGE_PUB.resource_party_merge(-) ');
FND_FILE.put_line(fnd_file.log, '                      ------------------Resource Party Merge-----------------');

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO PARTY_MERGE_SP;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO PARTY_MERGE_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END resource_party_merge;


PROCEDURE resource_party_site_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2)
is
l_api_name varchar2(30) := 'RESOURCE_PARTY_SITE_MERGE';

cursor from_cur(l_address_id number)
    is
 select      resource_id
	     ,category
             ,resource_number
             ,source_id
             ,contact_id
             ,object_version_number
             , created_by
             , creation_date
             , last_updated_by
             , last_update_date
             , last_update_login
 from  jtf_rs_resource_extns
 where address_id = l_address_id
   and category = 'PARTNER';

cursor to_cur(l_source_id number,
              l_address_id number)
    is
 select resource_id
  from jtf_rs_resource_extns
  where category = 'PARTNER'
    and source_id = l_source_id
    and address_id = l_address_id ;

to_rec to_cur%rowtype;
  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;
-------------------------------------
l_error_handle varchar2(30) ;
L_OBJECT_VER_NUMBER   NUMBER;
L_RETURN_STATUS       VARCHAR2(2);
L_MSG_COUNT           NUMBER;
L_MSG_DATA            VARCHAR2(2000);
-------------------------------------

begin
  --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);
-------------------------------------
   l_error_handle := NVL(FND_PROFILE.Value('JTF_RS_PARTY_MRG_FRMID_TOID_ER'),'ERROR');
-------------------------------------

savepoint site_merge_sp;

-----Debug Messages--------------------
FND_FILE.put_line(fnd_file.log, '                      ------------------Resource Party Site Merge-----------------');
FND_FILE.put_line(fnd_file.log, '                      Begin JTF_RS_PARTY_MERGE_PUB.resource_party_site_merge(+) ');
FND_FILE.put_line(fnd_file.log, '                        p_entity_name       :'||p_entity_name);
FND_FILE.put_line(fnd_file.log, '                        p_from_id           :'||p_from_id);
FND_FILE.put_line(fnd_file.log, '                        p_from_fk_id        :'||p_from_fk_id);
FND_FILE.put_line(fnd_file.log, '                        p_to_fk_id          :'||p_to_fk_id);
FND_FILE.put_line(fnd_file.log, '                        p_parent_entity_name:'||p_parent_entity_name);
FND_FILE.put_line(fnd_file.log, '                        p_batch_id          :'||p_batch_id);
FND_FILE.put_line(fnd_file.log, '                        p_batch_party_id    :'||p_batch_party_id);
FND_FILE.put_line(fnd_file.log, '                      Error Handling Mode   :'||l_error_handle);
-----End Debug Messages----------------

x_return_status := fnd_api.g_ret_sts_success;

if (p_entity_name <> 'JTF_RS_RESOURCE_EXTNS')
   or (p_parent_entity_name <> 'HZ_PARTY_SITES')
then
   fnd_message.set_name ('JTF', 'JTF_RS_ENTITY_NAME_ERR');
   fnd_message.set_token('P_ENTITY',p_entity_name);
   fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
   FND_MSG_PUB.add;
   RAISE fnd_api.g_exc_error;
end if;

-- get the values of the from record
FOR from_rec IN from_cur(p_from_fk_id) LOOP
--check if there exists another resource with same source id and the new address id
open to_cur(from_rec.source_id,
            p_to_fk_id);
fetch to_cur into to_rec;
if(to_cur%found)
then
----------------------------------------------------
      -- Check if user wants to end date the record before erroring the process itself.
      IF (l_error_handle = 'END_DATE')  THEN

        /* even if it says end date employee, it is for end dating all type of resources */
        /* End Date the cat_rec.resource_id resource i.e. the one which we want to anyway change to new party */

        l_object_ver_number := from_rec.object_version_number ;

/* Calling publish API to raise merge resource event. Fix for Enhancement: 3295476 */

    begin
       jtf_rs_wf_events_pub.merge_resource
              (p_api_version               => 1.0
              ,p_init_msg_list             => fnd_api.g_false
              ,p_commit                    => fnd_api.g_false
              ,p_resource_id               => from_rec.resource_id
              ,p_repl_resource_id          => to_rec.resource_id
              ,p_end_date_active           => trunc(sysdate-1)
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data);

    EXCEPTION when others then
       null;
    end;

/* End of publish API call */

        JTF_RS_RESOURCE_UTL_PUB.END_DATE_EMPLOYEE
          (P_API_VERSION          => 1.0,
           P_INIT_MSG_LIST        => FND_API.G_FALSE,
           P_COMMIT               => FND_API.G_FALSE,
           P_RESOURCE_ID          => from_rec.resource_id,
           P_END_DATE_ACTIVE      => trunc(sysdate-1) ,
           X_OBJECT_VER_NUMBER    => l_object_ver_number,
           X_RETURN_STATUS        => l_return_status,
           X_MSG_COUNT            => l_msg_count,
           X_MSG_DATA             => l_msg_data ) ;

        IF (nvl(l_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success) then
          x_return_status := l_return_status ;
          fnd_message.set_name ('JTF', 'JTF_RS_REJECT_MERGE');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
        END IF;

      ELSIF (l_error_handle = 'ERROR')  THEN
----------------------------------------------------
        --reject merge
        fnd_message.set_name ('JTF', 'JTF_RS_REJECT_MERGE');
        FND_MSG_PUB.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
----------------------------------------------------
      END IF;
----------------------------------------------------
  else
  --if another resource does not exist change the same resource to have the new address id
     update jtf_rs_resource_extns
        set address_id = p_to_fk_id,
            object_version_number = object_version_number + 1
     where  resource_id = from_rec.resource_id;
--     x_to_id := p_from_id;

          insert into JTF_RS_RESOURCE_EXTN_AUD (
             RESOURCE_AUDIT_ID,
             RESOURCE_ID,
             OLD_ADDRESS_ID,
             NEW_ADDRESS_ID,
             NEW_OBJECT_VERSION_NUMBER,
             OLD_OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            ) values (
            JTF_RS_RESOURCE_EXTN_AUD_S.NEXTVAL,
               from_rec.resource_id,
               p_from_fk_id,
               p_to_fk_id,
               from_rec.object_version_number + 1,
               from_rec.object_version_number,
               l_user_id,
               l_date,
               l_user_id,
               l_date,
               l_login_id
             );
      --since site merge changes the address_id only it is not required to do synchronization.
      --So Commenting the code below. This is done as part og Bug fix 3695580
      /*
      synchronize_resource(p_resource_id => from_rec.resource_id,
                           p_category    => from_rec.category,
                           p_address_id  => p_to_fk_id,
                           p_source_id   => from_rec.source_id,
                          x_ret_status => x_return_status);

     if(x_return_status <> fnd_api.g_ret_sts_success)
     then
         RAISE fnd_api.g_exc_error;
     end if;
     */
 end if;
close to_cur;

END LOOP; -- end of from_cur loop

FND_FILE.put_line(fnd_file.log, '                      End JTF_RS_PARTY_MERGE_PUB.resource_party_site_merge(-) ');
FND_FILE.put_line(fnd_file.log, '                      ------------------Resource Party Site Merge-----------------');

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO site_merge_sp;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO site_merge_sp;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO site_merge_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
end resource_party_site_merge;

PROCEDURE resource_party_cont_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2)
is
l_api_name varchar2(30) := 'RESOURCE_PARTY_CONT_MERGE';

cursor res_cur(l_contact_id number)
    is
select resource_id,
       source_id,
       address_id,
       object_version_number
from   jtf_rs_resource_extns
where contact_id = l_contact_id
and category IN ('PARTY','PARTNER') ;

cursor cont_cur(l_party_id number,
                l_party_site_id number,
                l_contact_id number)
is
select 'x'
from jtf_rs_party_contacts_vl
where party_id = l_party_id
and   nvl(party_site_id, -1) = nvl(l_party_site_id, -1)
and   contact_id = l_contact_id ;

  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;
  dummy varchar2(1) ;
begin
   savepoint cont_merge_sp;
   x_return_status := fnd_api.g_ret_sts_success;

  --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

-----Debug Messages--------------------
FND_FILE.put_line(fnd_file.log, '                      ------------------Resource Contact Merge-----------------');
FND_FILE.put_line(fnd_file.log, '                      Begin JTF_RS_PARTY_MERGE_PUB.resource_party_cont_merge(+) ');
FND_FILE.put_line(fnd_file.log, '                        p_entity_name       :'||p_entity_name);
FND_FILE.put_line(fnd_file.log, '                        p_from_id           :'||p_from_id);
FND_FILE.put_line(fnd_file.log, '                        p_from_fk_id        :'||p_from_fk_id);
FND_FILE.put_line(fnd_file.log, '                        p_to_fk_id          :'||p_to_fk_id);
FND_FILE.put_line(fnd_file.log, '                        p_parent_entity_name:'||p_parent_entity_name);
FND_FILE.put_line(fnd_file.log, '                        p_batch_id          :'||p_batch_id);
FND_FILE.put_line(fnd_file.log, '                        p_batch_party_id    :'||p_batch_party_id);
-----End Debug Messages----------------

if (p_entity_name <> 'JTF_RS_RESOURCE_EXTNS')
   or (p_parent_entity_name <> 'HZ_ORG_CONTACTS')
then
   fnd_message.set_name ('JTF', 'JTF_RS_ENTITY_NAME_ERR');
   fnd_message.set_token('P_ENTITY',p_entity_name);
   fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
   FND_MSG_PUB.add;
   RAISE fnd_api.g_exc_error;
end if;

FOR res_rec IN res_cur(p_from_fk_id) LOOP

/* -- Bug 5921975 (Removed validation as it was doing p1-c2 validation which is
   -- not valid and will always fail). (02-APR-2007)
     open cont_cur(res_rec.source_id,
		res_rec.address_id,
		p_to_fk_id) ;
     fetch cont_cur into dummy ;
     if cont_cur%NOTFOUND then
            fnd_message.set_name ('JTF', 'JTF_RS_VALID_TO_ID_ERR');
            FND_MSG_PUB.add;
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
     else
*/
	     update jtf_rs_resource_extns
 		set contact_id = p_to_fk_id,
		    object_version_number = object_version_number + 1
	     where  resource_id = res_rec.resource_id;

	--     x_to_id := p_from_id;


	     insert into JTF_RS_RESOURCE_EXTN_AUD (
		     RESOURCE_AUDIT_ID,
		     RESOURCE_ID,
		     OLD_CONTACT_ID,
		     NEW_CONTACT_ID,
		     NEW_OBJECT_VERSION_NUMBER,
		     OLD_OBJECT_VERSION_NUMBER,
		     CREATED_BY,
		     CREATION_DATE,
		     LAST_UPDATED_BY,
		     LAST_UPDATE_DATE,
		     LAST_UPDATE_LOGIN
		    ) values (
		    JTF_RS_RESOURCE_EXTN_AUD_S.NEXTVAL,
		       res_rec.resource_id,
		       p_from_fk_id,
		       p_to_fk_id,
		       res_rec.object_version_number + 1,
		       res_rec.object_version_number,
		       l_user_id,
		       l_date,
		       l_user_id,
		       l_date,
		       l_login_id
		     );
--     end if ;
--     close cont_cur ;
END LOOP ;

FND_FILE.put_line(fnd_file.log, '                      End JTF_RS_PARTY_MERGE_PUB.resource_party_cont_merge(-) ');
FND_FILE.put_line(fnd_file.log, '                      ------------------Resource Contact Merge-----------------');

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO cont_merge_sp;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO cont_merge_sp;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO cont_merge_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
end resource_party_cont_merge;

PROCEDURE synchronize_resource(p_resource_id IN NUMBER,
                               p_category    IN VARCHAR2,
                               p_address_id  IN NUMBER,
                               p_source_id   IN NUMBER,
                               x_ret_status  out NOCOPY VARCHAR2)
IS
l_api_name  varchar2(30)  := 'SYNCHRONIZE_RESOURCE';
cursor party_cur
    is
 SELECT PARTY.PARTY_NUMBER,
        PARTY.PARTY_NAME,
        PARTY.EMAIL_ADDRESS,
        PARTY.ADDRESS1 ,
        PARTY.ADDRESS2 ,
        PARTY.ADDRESS3  ,
        PARTY.ADDRESS4  ,
        PARTY.CITY    ,
        PARTY.POSTAL_CODE ,
        PARTY.STATE  ,
        PARTY.PROVINCE,
        PARTY.COUNTY  ,
        PARTY.COUNTRY ,
        CT_POINT1.PHONE_AREA_CODE||CT_POINT1.PHONE_NUMBER    PHONE,
        TO_NUMBER(NULL)                                      ORG_ID,
        NULL                                                 ORG_NAME,
        PARTY.PERSON_FIRST_NAME,
        PARTY.PERSON_MIDDLE_NAME,
        PARTY.PERSON_LAST_NAME
  FROM
       HZ_PARTIES         PARTY,
       HZ_CONTACT_POINTS  CT_POINT1
  WHERE  PARTY.PARTY_ID = p_source_id
  AND PARTY.PARTY_TYPE NOT IN ('ORGANIZATION', 'GROUP')
  AND CT_POINT1.OWNER_TABLE_NAME   (+)= 'HZ_PARTIES'
  AND CT_POINT1.OWNER_TABLE_ID     (+)= PARTY.PARTY_ID
  AND CT_POINT1.PRIMARY_FLAG       (+)= 'Y'
  AND CT_POINT1.STATUS             (+)= 'A'
  AND CT_POINT1.CONTACT_POINT_TYPE (+)= 'PHONE';

party_rec party_cur%rowtype;

CURSOR par_cur
   is
SELECT PARTY.PARTY_NAME,
       PARTY.PARTY_NUMBER,
      PARTY.EMAIL_ADDRESS,
      /*PARTY.ADDRESS1 ,
      PARTY.ADDRESS2 ,
      PARTY.ADDRESS3  ,
      PARTY.ADDRESS4  ,
      PARTY.CITY    ,
      PARTY.POSTAL_CODE ,
      PARTY.STATE  ,
      PARTY.PROVINCE,
      PARTY.COUNTY  ,
      PARTY.COUNTRY , */
      CT_POINT1.PHONE_AREA_CODE||CT_POINT1.PHONE_NUMBER    PHONE,
      REL.OBJECT_ID             ORG_ID,
      PARTY.PARTY_NAME          ORG_NAME,
      PARTY.PERSON_FIRST_NAME,
      PARTY.PERSON_MIDDLE_NAME,
      PARTY.PERSON_LAST_NAME
      FROM
             HZ_PARTIES         PARTY,
             HZ_PARTIES         PARTY2,
             HZ_PARTIES         PARTY3,
             HZ_CONTACT_POINTS  CT_POINT1,
--             HZ_PARTY_RELATIONSHIPS  REL
             HZ_RELATIONSHIPS  REL
      WHERE  PARTY.PARTY_ID  = p_source_id
      AND  (
                (
                 PARTY.PARTY_TYPE = 'ORGANIZATION'
                 AND
                 PARTY.PARTY_ID = REL.SUBJECT_ID
                 )
              OR
                (
                 PARTY.PARTY_TYPE             = 'PARTY_RELATIONSHIP'
                 AND
                  PARTY.PARTY_ID               =  REL.PARTY_ID
                 )
             )
--      AND REL.PARTY_RELATIONSHIP_TYPE  IN  ('PARTNER_OF', 'VAD_OF', 'THIRD_PARTY_FOR')
--
      AND REL.RELATIONSHIP_CODE IN
   	   ('PARTNER_OF', 'VAD_OF', 'VAD_VENDOR_OF',
            'THIRD_PARTY_FOR', 'INDIRECTLY_MANAGES_CUSTOMER', 'CUSTOMER_INDIRECTLY_MANAGED_BY')
      AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND REL.DIRECTIONAL_FLAG = 'F'
      AND REL.STATUS = 'A'
--
      AND REL.SUBJECT_ID               = PARTY2.PARTY_ID
      AND (PARTY2.PARTY_TYPE           = 'PERSON'
               OR PARTY2.PARTY_TYPE         = 'ORGANIZATION')
      AND REL.OBJECT_ID                = PARTY3.PARTY_ID
      AND PARTY3.PARTY_TYPE            = 'ORGANIZATION'
      AND CT_POINT1.OWNER_TABLE_NAME   (+)= 'HZ_PARTIES'
      AND CT_POINT1.OWNER_TABLE_ID     (+)= PARTY.PARTY_ID
      AND CT_POINT1.PRIMARY_FLAG       (+)= 'Y'
      AND CT_POINT1.STATUS             (+)= 'A'
      AND CT_POINT1.CONTACT_POINT_TYPE (+)= 'PHONE';

  par_rec par_cur%rowtype;

cursor par_address_cur
   is
SELECT PARTY.PARTY_NUMBER,
       PARTY.PARTY_NAME,
       PARTY.EMAIL_ADDRESS,
       LOC.ADDRESS1
      ,LOC.ADDRESS2
      ,LOC.ADDRESS3
      ,LOC.ADDRESS4
      ,LOC.CITY
      ,LOC.POSTAL_CODE
      ,LOC.STATE
      ,LOC.PROVINCE
      ,LOC.COUNTY
      ,LOC.COUNTRY ,
       CT_POINT1.PHONE_AREA_CODE||CT_POINT1.PHONE_NUMBER    PHONE,
       REL.OBJECT_ID             ORG_ID,
       PARTY.PARTY_NAME          ORG_NAME,
       PARTY.PERSON_FIRST_NAME,
       PARTY.PERSON_MIDDLE_NAME,
       PARTY.PERSON_LAST_NAME
   FROM
      HZ_PARTIES         PARTY,
      HZ_PARTIES         PARTY2,
      HZ_PARTIES         PARTY3,
      HZ_PARTY_SITES     PARTY_SITE,
      HZ_LOCATIONS       LOC,
      HZ_CONTACT_POINTS  CT_POINT1,
--      HZ_PARTY_RELATIONSHIPS  REL
      HZ_RELATIONSHIPS  REL
  WHERE PARTY.PARTY_ID = p_source_id
           AND  (
                (
                 PARTY.PARTY_TYPE = 'ORGANIZATION'
                 AND
                 PARTY.PARTY_ID = REL.SUBJECT_ID
                 )
              OR
                (
                 PARTY.PARTY_TYPE             = 'PARTY_RELATIONSHIP'
                 AND
                  PARTY.PARTY_ID               =  REL.PARTY_ID
                 )
            )
--  AND REL.PARTY_RELATIONSHIP_TYPE  IN  ('PARTNER_OF', 'VAD_OF', 'THIRD_PARTY_FOR')
--
      AND REL.RELATIONSHIP_CODE IN
   	   ('PARTNER_OF', 'VAD_OF', 'VAD_VENDOR_OF',
            'THIRD_PARTY_FOR', 'INDIRECTLY_MANAGES_CUSTOMER', 'CUSTOMER_INDIRECTLY_MANAGED_BY')
      AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND REL.DIRECTIONAL_FLAG = 'F'
      AND REL.STATUS = 'A'
--
  AND REL.SUBJECT_ID               = PARTY2.PARTY_ID
  AND (PARTY2.PARTY_TYPE           = 'PERSON'
        OR PARTY2.PARTY_TYPE         = 'ORGANIZATION')
  AND REL.OBJECT_ID                = PARTY3.PARTY_ID
  AND PARTY3.PARTY_TYPE            = 'ORGANIZATION'
  AND PARTY_SITE.PARTY_SITE_ID      = p_address_id
  AND PARTY_SITE.LOCATION_ID       =  LOC.LOCATION_ID (+)
  AND CT_POINT1.OWNER_TABLE_NAME   (+)= 'HZ_PARTIES'
  AND CT_POINT1.OWNER_TABLE_ID     (+)= PARTY.PARTY_ID
  AND CT_POINT1.PRIMARY_FLAG       (+)= 'Y'
  AND CT_POINT1.STATUS             (+)= 'A'
  AND CT_POINT1.CONTACT_POINT_TYPE (+)= 'PHONE';


par_address_rec par_address_cur%rowtype;

begin

FND_FILE.put_line(fnd_file.log, '                      Begin JTF_RS_PARTY_MERGE_PUB.synchronize_resource(+) ');

SAVEPOINT synchronize_resource_sp;
x_ret_status := fnd_api.g_ret_sts_success;

if(p_category = 'PARTY')
THEN
   open party_cur;
   fetch party_cur into party_rec;
   if (party_cur%found)
   then

       UPDATE JTF_RS_RESOURCE_EXTNS RES
         SET RES.OBJECT_VERSION_NUMBER  = res.object_version_number + 1   ,
                  RES.LAST_UPDATE_DATE  = sysdate,
            RES.LAST_UPDATED_BY  = fnd_global.user_id,
            RES.SOURCE_NUMBER =  party_rec.party_number ,
             RES.SOURCE_NAME =   party_rec.party_name,
             RES.SOURCE_EMAIL  = party_rec.email_address,
             RES.SOURCE_ADDRESS1= party_rec.address1,
             RES.SOURCE_ADDRESS2 = party_rec.address2,
             RES.SOURCE_ADDRESS3 = party_rec.address3,
             RES.SOURCE_ADDRESS4  = party_rec.address4,
             RES.SOURCE_CITY      = party_rec.city,
             RES.SOURCE_POSTAL_CODE = party_rec.postal_code,
             RES.SOURCE_STATE    = party_rec.state,
             RES.SOURCE_PROVINCE = party_rec.province,
             RES.SOURCE_COUNTY   = party_rec.county,
             RES.SOURCE_COUNTRY  = party_rec.country,
             RES.SOURCE_PHONE    = party_rec.phone,
            --RES.SOURCE_MGR_ID  ,
            --RES.SOURCE_MGR_NAME   ,
            RES.SOURCE_ORG_ID    = party_rec.org_id ,
            RES.SOURCE_ORG_NAME =  party_rec.org_name,
            RES.SOURCE_FIRST_NAME = party_rec.person_first_name,
            RES.SOURCE_MIDDLE_NAME = party_rec.person_middle_name,
            RES.SOURCE_LAST_NAME =  party_rec.person_last_name
        WHERE RES.RESOURCE_ID = p_resource_id;
    end if;
    close party_cur;
 elsif(p_category = 'PARTNER')
 then
   if(p_address_id is null)
   THEN
      open par_cur;
      fetch par_cur into par_rec;
      if (par_cur%found)
      then
       UPDATE JTF_RS_RESOURCE_EXTNS RES
         SET RES.OBJECT_VERSION_NUMBER  = res.object_version_number + 1   ,
                  RES.LAST_UPDATE_DATE  = sysdate,
            RES.LAST_UPDATED_BY  = fnd_global.user_id,
            RES.SOURCE_NUMBER =  par_rec.party_number ,
             RES.SOURCE_NAME =   par_rec.party_name,
             RES.SOURCE_EMAIL  = par_rec.email_address,
             /*RES.SOURCE_ADDRESS1= par_rec.address1,
             RES.SOURCE_ADDRESS2 = par_rec.address2,
             RES.SOURCE_ADDRESS3 = par_rec.address3,
             RES.SOURCE_ADDRESS4  = par_rec.address4,
             RES.SOURCE_CITY      = par_rec.city,
             RES.SOURCE_POSTAL_CODE = par_rec.postal_code,
             RES.SOURCE_STATE    = par_rec.state,
             RES.SOURCE_PROVINCE = par_rec.province,
             RES.SOURCE_COUNTY   = par_rec.county,
             RES.SOURCE_COUNTRY  = par_rec.country, */
             RES.SOURCE_PHONE    = par_rec.phone,
            --RES.SOURCE_MGR_ID  ,
            --RES.SOURCE_MGR_NAME   ,
            RES.SOURCE_ORG_ID    = par_rec.org_id ,
            RES.SOURCE_ORG_NAME =  par_rec.org_name,
            RES.SOURCE_FIRST_NAME = par_rec.person_first_name,
            RES.SOURCE_MIDDLE_NAME = par_rec.person_middle_name,
            RES.SOURCE_LAST_NAME =  par_rec.person_last_name
         where RES.RESOURCE_ID   = p_resource_id;
        end if;
        close par_cur;
  else

      open par_address_cur;
      fetch par_address_cur into par_address_rec;
      if (par_address_cur%found)
      then
       UPDATE JTF_RS_RESOURCE_EXTNS RES
         SET RES.OBJECT_VERSION_NUMBER  = res.object_version_number + 1   ,
                  RES.LAST_UPDATE_DATE  = sysdate,
            RES.LAST_UPDATED_BY  = fnd_global.user_id,
            RES.SOURCE_NUMBER =  par_address_rec.party_number ,
             RES.SOURCE_NAME =   par_address_rec.party_name,
             RES.SOURCE_EMAIL  = par_address_rec.email_address,
             RES.SOURCE_ADDRESS1= par_address_rec.address1,
             RES.SOURCE_ADDRESS2 = par_address_rec.address2,
             RES.SOURCE_ADDRESS3 = par_address_rec.address3,
             RES.SOURCE_ADDRESS4  = par_address_rec.address4,
             RES.SOURCE_CITY      = par_address_rec.city,
             RES.SOURCE_POSTAL_CODE = par_address_rec.postal_code,
             RES.SOURCE_STATE    = par_address_rec.state,
             RES.SOURCE_PROVINCE = par_address_rec.province,
             RES.SOURCE_COUNTY   = par_address_rec.county,
             RES.SOURCE_COUNTRY  = par_address_rec.country,
             RES.SOURCE_PHONE    = par_address_rec.phone,
            --RES.SOURCE_MGR_ID  ,
            --RES.SOURCE_MGR_NAME   ,
            RES.SOURCE_ORG_ID    = par_address_rec.org_id ,
            RES.SOURCE_ORG_NAME =  par_address_rec.org_name,
            RES.SOURCE_FIRST_NAME = par_address_rec.person_first_name,
            RES.SOURCE_MIDDLE_NAME = par_address_rec.person_middle_name,
            RES.SOURCE_LAST_NAME =  par_address_rec.person_last_name
         where RES.RESOURCE_ID   = p_resource_id;
        end if;
        close par_address_cur;


   end if; -- end of address_id check

 end if; -- end of category check

  update jtf_rs_resource_extns_tl res
    set  resource_name
    =  (select party_name
          from hz_parties
        where  party_id = p_source_id)
    where res.resource_id = p_resource_id;
FND_FILE.put_line(fnd_file.log, '                      End JTF_RS_PARTY_MERGE_PUB.synchronize_resource(-) ');

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO synchronize_resource_sp;
      x_ret_status := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO synchronize_resource_sp;
      x_ret_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO synchronize_resource_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_ret_status := fnd_api.g_ret_sts_error;

end synchronize_resource;

PROCEDURE resource_support_site_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
                           p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
                           p_batch_id                   IN   NUMBER,
                           p_batch_party_id             IN   NUMBER,
                           x_return_status              OUT NOCOPY  VARCHAR2)
is
 l_api_name varchar2(30) := 'RESOURCE_SUPPORT_SITE_MERGE';

 cursor res_cur(c_support_site_id number)
 is
 select resource_id,
        source_id,
        object_version_number
 from   jtf_rs_resource_extns
 where  support_site_id = c_support_site_id;

--cursor support_site_cur(c_support_site_id number)
--is
--select 'X'
--from  hz_party_sites p,
--      hz_party_site_uses psu
--where p.party_site_id = psu.party_site_id
--and   psu.site_use_type = 'SUPPORT_SITE'
--and   p.party_site_id = c_support_site_id;

 l_date  Date;
 l_user_id  Number;
 l_login_id  Number;
 dummy varchar2(1) ;
begin
   savepoint support_site_merge_sp;
   x_return_status := fnd_api.g_ret_sts_success;

-----Debug Messages--------------------
FND_FILE.put_line(fnd_file.log, '                      ------------------Resource Support Site Merge-----------------');
FND_FILE.put_line(fnd_file.log, '                      Begin JTF_RS_PARTY_MERGE_PUB.resource_support_site_merge(+) ');
FND_FILE.put_line(fnd_file.log, '                        p_entity_name       :'||p_entity_name);
FND_FILE.put_line(fnd_file.log, '                        p_from_id           :'||p_from_id);
FND_FILE.put_line(fnd_file.log, '                        p_from_fk_id        :'||p_from_fk_id);
FND_FILE.put_line(fnd_file.log, '                        p_to_fk_id          :'||p_to_fk_id);
FND_FILE.put_line(fnd_file.log, '                        p_parent_entity_name:'||p_parent_entity_name);
FND_FILE.put_line(fnd_file.log, '                        p_batch_id          :'||p_batch_id);
FND_FILE.put_line(fnd_file.log, '                        p_batch_party_id    :'||p_batch_party_id);
-----End Debug Messages----------------

  --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

if (p_entity_name <> 'JTF_RS_RESOURCE_EXTNS')
   or (p_parent_entity_name <> 'HZ_PARTY_SITES')
then
   fnd_message.set_name ('JTF', 'JTF_RS_ENTITY_NAME_ERR');
   fnd_message.set_token('P_ENTITY',p_entity_name);
   fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
   FND_MSG_PUB.add;
   RAISE fnd_api.g_exc_error;
end if;

FOR res_rec IN res_cur(p_from_fk_id) LOOP
--     open support_site_cur(p_to_fk_id) ;
--     fetch support_site_cur into dummy ;
--     if support_site_cur%NOTFOUND then
--            fnd_message.set_name ('JTF', 'JTF_RS_VALID_TO_ID_ERR');
--            FND_MSG_PUB.add;
--            x_return_status := fnd_api.g_ret_sts_error;
--            RAISE fnd_api.g_exc_error;
--     else
             update jtf_rs_resource_extns
                set support_site_id = p_to_fk_id,
                    object_version_number = object_version_number + 1
             where  resource_id = res_rec.resource_id;

        --     x_to_id := p_from_id;

             insert into JTF_RS_RESOURCE_EXTN_AUD (
                     RESOURCE_AUDIT_ID,
                     RESOURCE_ID,
                     OLD_SUPPORT_SITE_ID,
                     NEW_SUPPORT_SITE_ID,
                     NEW_OBJECT_VERSION_NUMBER,
                     OLD_OBJECT_VERSION_NUMBER,
                     CREATED_BY,
                     CREATION_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_DATE,
                     LAST_UPDATE_LOGIN
                    ) values (
                    JTF_RS_RESOURCE_EXTN_AUD_S.NEXTVAL,
                       res_rec.resource_id,
                       p_from_fk_id,
                       p_to_fk_id,
                       res_rec.object_version_number + 1,
                       res_rec.object_version_number,
                       l_user_id,
                       l_date,
                       l_user_id,
                       l_date,
                       l_login_id
                     );
--     end if ;
--     close support_site_cur ;
END LOOP ;

FND_FILE.put_line(fnd_file.log, '                      End JTF_RS_PARTY_MERGE_PUB.resource_support_site_merge(-) ');
FND_FILE.put_line(fnd_file.log, '                      ------------------Resource Support Site Merge-----------------');

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO support_site_merge_sp;
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO support_site_merge_sp;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      ROLLBACK TO support_site_merge_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
end resource_support_site_merge;

end;

/
