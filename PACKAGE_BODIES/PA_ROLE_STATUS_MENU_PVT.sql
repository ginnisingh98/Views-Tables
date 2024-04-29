--------------------------------------------------------
--  DDL for Package Body PA_ROLE_STATUS_MENU_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_STATUS_MENU_PVT" AS
 /* $Header: PAXRSMVB.pls 115.3 2003/08/21 05:21:40 sulkumar ship $ */

procedure INSERT_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 P_ROLE_STATUS_MENU_ID          OUT NOCOPY NUMBER,
 P_ROLE_ID                      IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_STATUS_CODE                  IN         VARCHAR2,
 P_MENU_ID                      IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        OUT NOCOPY NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 p_return_status                OUT NOCOPY varchar2,
 p_msg_count                    out NOCOPY number,
 p_msg_data                     out NOCOPY varchar2
) IS

l_sqlcode            varchar2(30);
l_error_message_code varchar2(30);

l_new_status_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_new_status_type_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_new_menu_name_tbl         SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_new_role_sts_menu_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_mod_status_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_mod_status_type_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_mod_menu_id_tbl           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_mod_role_sts_menu_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_del_status_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_del_status_type_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_del_role_sts_menu_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

l_status_level       varchar2(30);
l_count              number;
l_menu_name          varchar2(30);

BEGIN


FND_MSG_PUB.initialize;

p_msg_count := 0;

--  Check if the role status is a duplicate
pa_role_status_menu_utils.check_dup_role_status(
   p_role_status_menu_id     => p_role_status_menu_id,
   p_role_id                 => p_role_id,
   p_status_code             => p_status_code,
   p_return_status           => p_return_status,
   p_error_message_code      => l_error_message_code);

IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN

   -- Call the table handler to insert into the table

   pa_role_status_menu_pkg.insert_row(
      -- P_ROWID                        =>        P_ROWID,
      P_ROLE_STATUS_MENU_ID          =>        P_ROLE_STATUS_MENU_ID,
      P_ROLE_ID                      =>        P_ROLE_ID,
      P_STATUS_TYPE                  =>        P_STATUS_TYPE,
      P_STATUS_CODE                  =>        P_STATUS_CODE,
      P_MENU_ID                      =>        P_MENU_ID,
      P_OBJECT_VERSION_NUMBER        =>        P_OBJECT_VERSION_NUMBER,
      P_LAST_UPDATE_DATE             =>        P_LAST_UPDATE_DATE,
      P_LAST_UPDATED_BY              =>        P_LAST_UPDATED_BY,
      P_CREATION_DATE                =>        P_CREATION_DATE,
      P_CREATED_BY                   =>        P_CREATED_BY,
      P_LAST_UPDATE_LOGIN            =>        P_LAST_UPDATE_LOGIN
   );

-- hr_utility.trace('after insert_row');
   select count(*)
   into   l_count
   from pa_project_parties
   where project_role_id = p_role_id;

   IF l_count > 0 THEN

      select nvl(status_level, 'SYSTEM')
      into   l_status_level
      from   pa_project_role_types_b
      where  project_role_id = p_role_id;

      select menu_name
      into   l_menu_name
      from   fnd_menus_vl
      where  menu_id = p_menu_id;

      l_new_status_code_tbl.extend;
      l_new_status_type_tbl.extend;
      l_new_menu_name_tbl.extend;
      l_new_role_sts_menu_id_tbl.extend;
      l_new_status_code_tbl(1) := p_status_code;
      l_new_status_type_tbl(1) := p_status_type;
      l_new_menu_name_tbl(1)   := l_menu_name;
      l_new_role_sts_menu_id_tbl(1) := p_role_status_menu_id;

      pa_security_pvt.update_status_based_sec
        (p_commit                   => FND_API.G_FALSE,
         p_project_role_id          => p_role_id,
         p_status_level             => l_status_level,
         p_new_status_code_tbl      => l_new_status_code_tbl,
         p_new_status_type_tbl      => l_new_status_type_tbl,
         p_new_menu_name_tbl        => l_new_menu_name_tbl,
         p_new_role_sts_menu_id_tbl => l_new_role_sts_menu_id_tbl,
         p_mod_status_code_tbl      => l_mod_status_code_tbl,
         p_mod_status_type_tbl      => l_mod_status_type_tbl,
         p_mod_menu_id_tbl          => l_mod_menu_id_tbl,
         p_mod_role_sts_menu_id_tbl => l_mod_role_sts_menu_id_tbl,
         p_del_status_code_tbl      => l_del_status_code_tbl,
         p_del_status_type_tbl      => l_del_status_type_tbl,
         p_del_role_sts_menu_id_tbl => l_del_role_sts_menu_id_tbl,
         x_return_status            => p_return_status,
         x_msg_count                => p_msg_count,
         x_msg_data                 => p_msg_data
        );
   END IF;

ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
   fnd_message.set_name('PA', l_error_message_code);
   fnd_msg_pub.ADD;
   p_msg_count := p_msg_count + 1;

ELSIF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

   fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'pa_role_status_menu_utils',
        p_procedure_name => 'check_dup_role_status',
        p_error_text     => l_error_message_code);

   p_msg_count := p_msg_count + 1;

END IF;

EXCEPTION
  WHEN OTHERS THEN

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_sqlcode := SQLCODE;

    fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_ROLE_STATUS_MENU_PVT',
        p_procedure_name => 'INSERT_ROW',
        p_error_text     => l_sqlcode);

    p_msg_count := p_msg_count + 1;

END;

procedure LOCK_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER,
 p_return_status                OUT NOCOPY varchar2,
 p_msg_count                    out NOCOPY number,
 p_msg_data                     out NOCOPY varchar2
 ) IS

l_sqlcode varchar2(30);

BEGIN

FND_MSG_PUB.initialize;

p_msg_count := 0;

--  Call the table handler to lock the row

pa_role_status_menu_pkg.lock_row(
   P_ROLE_STATUS_MENU_ID          =>         P_ROLE_STATUS_MENU_ID,
   P_OBJECT_VERSION_NUMBER        =>         P_OBJECT_VERSION_NUMBER
   );

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     l_sqlcode := SQLCODE;

     fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_ROLE_STATUS_MENU_PVT',
        p_procedure_name => 'LOCK_ROW',
        p_error_text     => l_sqlcode);

     p_msg_count := p_msg_count + 1;
END;

procedure UPDATE_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 -- P_ROWID                        IN OUT NOCOPY    VARCHAR2,
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_ROLE_ID                      IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_STATUS_CODE                  IN         VARCHAR2,
 P_MENU_ID                      IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN OUT NOCOPY    NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 p_return_status                OUT NOCOPY varchar2,
 p_msg_count                    out NOCOPY number,
 p_msg_data                     out NOCOPY varchar2
) is

l_new_status_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_new_status_type_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_new_menu_name_tbl         SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_new_role_sts_menu_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_mod_status_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_mod_status_type_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_mod_menu_id_tbl           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_mod_role_sts_menu_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_del_status_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_del_status_type_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_del_role_sts_menu_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

l_status_level       varchar2(30);
l_count              number;

l_status_code           VARCHAR2(80);
l_error_message_code    VARCHAR2(30);
l_sqlcode               VARCHAR2(30);

BEGIN

FND_MSG_PUB.initialize;

p_msg_count := 0;

--  Check for duplicates.

select status_code
  into l_status_code
  from pa_role_status_menu_map
 where role_status_menu_id = p_role_status_menu_id;

p_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_status_code <> p_status_code THEN

   --  Check if the role status is a duplicate

   pa_role_status_menu_utils.check_dup_role_status(
      p_role_status_menu_id     => p_role_status_menu_id,
      p_role_id                 => p_role_id,
      p_status_code             => p_status_code,
      p_return_status           => p_return_status,
      p_error_message_code      => l_error_message_code);

END IF;

IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN

   -- Call the table handler to update the row

   pa_role_status_menu_pkg.update_row(
      -- P_ROWID                        =>        P_ROWID,
      P_ROLE_STATUS_MENU_ID          =>        P_ROLE_STATUS_MENU_ID,
      P_ROLE_ID                      =>        P_ROLE_ID,
      P_STATUS_TYPE                  =>        P_STATUS_TYPE,
      P_STATUS_CODE                  =>        P_STATUS_CODE,
      P_MENU_ID                      =>        P_MENU_ID,
      P_OBJECT_VERSION_NUMBER        =>        P_OBJECT_VERSION_NUMBER,
      P_LAST_UPDATE_DATE             =>        P_LAST_UPDATE_DATE,
      P_LAST_UPDATED_BY              =>        P_LAST_UPDATED_BY,
      P_CREATION_DATE                =>        P_CREATION_DATE,
      P_CREATED_BY                   =>        P_CREATED_BY,
      P_LAST_UPDATE_LOGIN            =>        P_LAST_UPDATE_LOGIN
   );

   select count(*)
   into   l_count
   from pa_project_parties
   where project_role_id = p_role_id;

   IF l_count > 0 THEN

      select nvl(status_level, 'SYSTEM')
      into   l_status_level
      from   pa_project_role_types_b
      where  project_role_id = p_role_id;

      l_mod_status_code_tbl.extend;
      l_mod_status_type_tbl.extend;
      l_mod_menu_id_tbl.extend;
      l_mod_role_sts_menu_id_tbl.extend;

      l_mod_status_code_tbl(1) := p_status_code;
      l_mod_status_type_tbl(1) := p_status_type;
      l_mod_menu_id_tbl(1)   := p_menu_id;
      l_mod_role_sts_menu_id_tbl(1) := p_role_status_menu_id;

      pa_security_pvt.update_status_based_sec
        (p_commit                   => FND_API.G_FALSE,
         p_project_role_id          => p_role_id,
         p_status_level             => l_status_level,
         p_new_status_code_tbl      => l_new_status_code_tbl,
         p_new_status_type_tbl      => l_new_status_type_tbl,
         p_new_menu_name_tbl        => l_new_menu_name_tbl,
         p_new_role_sts_menu_id_tbl => l_new_role_sts_menu_id_tbl,
         p_mod_status_code_tbl      => l_mod_status_code_tbl,
         p_mod_status_type_tbl      => l_mod_status_type_tbl,
         p_mod_menu_id_tbl          => l_mod_menu_id_tbl,
         p_mod_role_sts_menu_id_tbl => l_mod_role_sts_menu_id_tbl,
         p_del_status_code_tbl      => l_del_status_code_tbl,
         p_del_status_type_tbl      => l_del_status_type_tbl,
         p_del_role_sts_menu_id_tbl => l_del_role_sts_menu_id_tbl,
         x_return_status            => p_return_status,
         x_msg_count                => p_msg_count,
         x_msg_data                 => p_msg_data
        );
   END IF;


ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
   fnd_message.set_name('PA', l_error_message_code);
   fnd_msg_pub.ADD;

   p_msg_count := p_msg_count + 1;
ELSIF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

   fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_ROLE_STATUS_MENU_UTILS',
        p_procedure_name => 'check_dup_role_status',
        p_error_text     => l_error_message_code);

   p_msg_count := p_msg_count + 1;
END IF;

EXCEPTION
  WHEN OTHERS THEN

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     l_sqlcode := SQLCODE;

     fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_ROLE_STATUS_MENU_PVT',
        p_procedure_name => 'UPDATE_ROW',
        p_error_text     => l_sqlcode);

     p_msg_count := p_msg_count + 1;
END;


procedure DELETE_ROW (
 p_commit                       in         VARCHAR2 := FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER,
 p_return_status                out NOCOPY varchar2,
 p_msg_count                    out NOCOPY number,
 p_msg_data                     out NOCOPY varchar2
) is

l_new_status_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_new_status_type_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_new_menu_name_tbl         SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_new_role_sts_menu_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_mod_status_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_mod_status_type_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_mod_menu_id_tbl           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_mod_role_sts_menu_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_del_status_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_del_status_type_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_del_role_sts_menu_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

l_status_level       varchar2(30);
l_count              number;

l_role_id             NUMBER;
l_status_code         VARCHAR2(30);
l_status_type         VARCHAR2(30);
l_error_message_code  VARCHAR2(30);
l_sqlcode             VARCHAR2(30);

BEGIN
-- hr_utility.trace_on(NULL, 'RMFORM');
-- hr_utility.trace('start');

FND_MSG_PUB.initialize;

p_msg_count := 0;

p_return_status := FND_API.G_RET_STS_SUCCESS;

-- hr_utility.trace('before  my stuff');
select role_id, status_code, status_type
into   l_role_id, l_status_code, l_status_type
from   pa_role_status_menu_map
where  role_status_menu_id = p_role_status_menu_id;

select count(*)
into   l_count
from pa_project_parties
where project_role_id = l_role_id;


   select nvl(status_level, 'SYSTEM')
   into   l_status_level
   from   pa_project_role_types_b
   where  project_role_id = l_role_id;

   l_del_status_code_tbl.extend;
   l_del_status_type_tbl.extend;
   l_del_role_sts_menu_id_tbl.extend;

   l_del_status_code_tbl(1) := l_status_code;
   l_del_status_type_tbl(1) := l_status_type;
   l_del_role_sts_menu_id_tbl(1) := p_role_status_menu_id;

   --  Call the table handler to delete the role status menu mapping.

   pa_role_status_menu_pkg.delete_row(
      P_ROLE_STATUS_MENU_ID          =>         P_ROLE_STATUS_MENU_ID,
      P_OBJECT_VERSION_NUMBER        =>         P_OBJECT_VERSION_NUMBER
   );

-- hr_utility.trace('before  update_status_based_sec');

IF l_count > 0 THEN

   pa_security_pvt.update_status_based_sec
        (p_commit                   => FND_API.G_FALSE,
         p_project_role_id          => l_role_id,
         p_status_level             => l_status_level,
         p_new_status_code_tbl      => l_new_status_code_tbl,
         p_new_status_type_tbl      => l_new_status_type_tbl,
         p_new_menu_name_tbl        => l_new_menu_name_tbl,
         p_new_role_sts_menu_id_tbl => l_new_role_sts_menu_id_tbl,
         p_mod_status_code_tbl      => l_mod_status_code_tbl,
         p_mod_status_type_tbl      => l_mod_status_type_tbl,
         p_mod_menu_id_tbl          => l_mod_menu_id_tbl,
         p_mod_role_sts_menu_id_tbl => l_mod_role_sts_menu_id_tbl,
         p_del_status_code_tbl      => l_del_status_code_tbl,
         p_del_status_type_tbl      => l_del_status_type_tbl,
         p_del_role_sts_menu_id_tbl => l_del_role_sts_menu_id_tbl,
         x_return_status            => p_return_status,
         x_msg_count                => p_msg_count,
         x_msg_data                 => p_msg_data
   );
-- hr_utility.trace('after  update_status_based_sec');
-- hr_utility.trace('p_return_status  is      ' || p_return_status);
-- hr_utility.trace('p_msg_data  is      ' || p_msg_data);

END IF; -- l_count > 0
-- IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
-- END IF;

EXCEPTION
  WHEN OTHERS THEN

-- hr_utility.trace('SQLERRM  is      ' || SQLERRM);
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       l_sqlcode := SQLCODE;

       fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_ROLE_STATUS_MENU_PVT',
        p_procedure_name => 'DELETE_ROW',
        p_error_text     => l_sqlcode);

        p_msg_count := p_msg_count + 1;

END;
end PA_ROLE_STATUS_MENU_PVT;

/
