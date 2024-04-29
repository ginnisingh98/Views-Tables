--------------------------------------------------------
--  DDL for Package Body PA_ROLE_JOB_BG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_JOB_BG_PVT" AS
 /* $Header: PAXRJBVB.pls 115.2 2003/08/25 19:01:45 ramurthy ship $ */

procedure INSERT_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   IN         VARCHAR2 DEFAULT 'N',
 P_ROLE_JOB_BG_ID               OUT NOCOPY NUMBER,
 P_PROJECT_ROLE_ID              IN         NUMBER,
 P_BUSINESS_GROUP_ID            IN         NUMBER,
 P_JOB_ID                       IN         NUMBER,
 P_MIN_JOB_LEVEL                IN         NUMBER,
 P_MAX_JOB_LEVEL                IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        OUT NOCOPY NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 p_return_status                OUT NOCOPY VARCHAR2,
 p_msg_count                    OUT NOCOPY NUMBER,
 p_msg_data                     OUT NOCOPY VARCHAR2
) IS

l_sqlcode            varchar2(30);
l_error_message_code varchar2(30);

BEGIN

-- hr_utility.trace_on(NULL, 'RMDUP');
-- hr_utility.trace('start insert row');

FND_MSG_PUB.initialize;

p_msg_count := 0;

--  Check if the role job defaults for this BG is a duplicate
pa_role_job_bg_utils.check_dup_job_bg_defaults(
   p_role_job_bg_id          => p_role_job_bg_id,
   p_project_role_id         => p_project_role_id,
   p_business_group_id       => p_business_group_id,
   p_return_status           => p_return_status,
   p_error_message_code      => l_error_message_code);

-- hr_utility.trace('after check_dup_job_bg_defaults');
IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN

   -- Call the table handler to insert into the table

-- hr_utility.trace('before tabkle handler insert row');
   pa_role_job_bg_pkg.insert_row(
      P_ROLE_JOB_BG_ID               =>        P_ROLE_JOB_BG_ID,
      P_PROJECT_ROLE_ID              =>        P_PROJECT_ROLE_ID,
      P_BUSINESS_GROUP_ID            =>        P_BUSINESS_GROUP_ID,
      P_JOB_ID                       =>        P_JOB_ID,
      P_MIN_JOB_LEVEL                =>        P_MIN_JOB_LEVEL,
      P_MAX_JOB_LEVEL                =>        P_MAX_JOB_LEVEL,
      P_OBJECT_VERSION_NUMBER        =>        P_OBJECT_VERSION_NUMBER,
      P_LAST_UPDATE_DATE             =>        P_LAST_UPDATE_DATE,
      P_LAST_UPDATED_BY              =>        P_LAST_UPDATED_BY,
      P_CREATION_DATE                =>        P_CREATION_DATE,
      P_CREATED_BY                   =>        P_CREATED_BY,
      P_LAST_UPDATE_LOGIN            =>        P_LAST_UPDATE_LOGIN
   );

-- hr_utility.trace('after tabkle handler insert row');
-- hr_utility.trace('error is : ' || sqlerrm);

ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
   fnd_message.set_name('PA', l_error_message_code);
   fnd_msg_pub.ADD;
   p_msg_count := p_msg_count + 1;

ELSIF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

   fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'pa_role_job_bg_utils',
        p_procedure_name => 'check_dup_job_bg_defaults',
        p_error_text     => l_error_message_code);

   p_msg_count := p_msg_count + 1;

END IF;

EXCEPTION
  WHEN OTHERS THEN

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_sqlcode := SQLCODE;

    fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_ROLE_JOB_BG_PVT',
        p_procedure_name => 'INSERT_ROW',
        p_error_text     => l_sqlcode);

    p_msg_count := p_msg_count + 1;

END;

procedure LOCK_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   IN         VARCHAR2 DEFAULT 'N',
 P_ROLE_JOB_BG_ID               IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER,
 p_return_status                OUT NOCOPY VARCHAR2,
 p_msg_count                    OUT NOCOPY NUMBER,
 p_msg_data                     OUT NOCOPY VARCHAR2
 ) IS

l_sqlcode varchar2(30);

BEGIN

FND_MSG_PUB.initialize;

p_msg_count := 0;

--  Call the table handler to lock the row

pa_role_job_bg_pkg.lock_row(
   P_ROLE_JOB_BG_ID               =>         P_ROLE_JOB_BG_ID,
   P_OBJECT_VERSION_NUMBER        =>         P_OBJECT_VERSION_NUMBER
   );

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     l_sqlcode := SQLCODE;

     fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_ROLE_JOB_BG_PVT',
        p_procedure_name => 'LOCK_ROW',
        p_error_text     => l_sqlcode);

     p_msg_count := p_msg_count + 1;
END;

procedure UPDATE_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   IN         VARCHAR2 DEFAULT 'N',
 P_ROLE_JOB_BG_ID               IN         NUMBER,
 P_PROJECT_ROLE_ID              IN         NUMBER,
 P_BUSINESS_GROUP_ID            IN         NUMBER,
 P_JOB_ID                       IN         NUMBER,
 P_MIN_JOB_LEVEL                IN         NUMBER,
 P_MAX_JOB_LEVEL                IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN OUT NOCOPY    NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 p_return_status                OUT NOCOPY VARCHAR2,
 p_msg_count                    OUT NOCOPY NUMBER,
 p_msg_data                     OUT NOCOPY VARCHAR2
) is

l_error_message_code    VARCHAR2(30);
l_sqlcode               VARCHAR2(30);
l_business_group_id	NUMBER(15);

BEGIN

FND_MSG_PUB.initialize;

p_msg_count := 0;

select business_group_id
  into l_business_group_id
  from pa_role_job_bgs
 where role_job_bg_id = p_role_job_bg_id;

p_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_business_group_id <> p_business_group_id THEN

--  Check if the role job defaults for this BG is a duplicate
pa_role_job_bg_utils.check_dup_job_bg_defaults(
   p_role_job_bg_id          => p_role_job_bg_id,
   p_project_role_id         => p_project_role_id,
   p_business_group_id       => p_business_group_id,
   p_return_status           => p_return_status,
   p_error_message_code      => l_error_message_code);

END IF;

IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN

   -- Call the table handler to update the row

   pa_role_job_bg_pkg.update_row(
      P_ROLE_JOB_BG_ID               =>        P_ROLE_JOB_BG_ID,
      P_PROJECT_ROLE_ID              =>        P_PROJECT_ROLE_ID,
      P_BUSINESS_GROUP_ID            =>        P_BUSINESS_GROUP_ID,
      P_JOB_ID                       =>        P_JOB_ID,
      P_MIN_JOB_LEVEL                =>        P_MIN_JOB_LEVEL,
      P_MAX_JOB_LEVEL                =>        P_MAX_JOB_LEVEL,
      P_OBJECT_VERSION_NUMBER        =>        P_OBJECT_VERSION_NUMBER,
      P_LAST_UPDATE_DATE             =>        P_LAST_UPDATE_DATE,
      P_LAST_UPDATED_BY              =>        P_LAST_UPDATED_BY,
      P_CREATION_DATE                =>        P_CREATION_DATE,
      P_CREATED_BY                   =>        P_CREATED_BY,
      P_LAST_UPDATE_LOGIN            =>        P_LAST_UPDATE_LOGIN
   );

ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
   fnd_message.set_name('PA', l_error_message_code);
   fnd_msg_pub.ADD;

   p_msg_count := p_msg_count + 1;
ELSIF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

   fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_ROLE_JOB_BG_UTILS',
        p_procedure_name => 'check_dup_job_bg_defaults',
        p_error_text     => l_error_message_code);

   p_msg_count := p_msg_count + 1;
END IF;

EXCEPTION
  WHEN OTHERS THEN

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     l_sqlcode := SQLCODE;

     fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_ROLE_JOB_BG_PVT',
        p_procedure_name => 'UPDATE_ROW',
        p_error_text     => l_sqlcode);

     p_msg_count := p_msg_count + 1;
END;


procedure DELETE_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   IN         VARCHAR2 DEFAULT 'N',
 P_ROLE_JOB_BG_ID               IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER,
 p_return_status                OUT NOCOPY VARCHAR2,
 p_msg_count                    OUT NOCOPY NUMBER,
 p_msg_data                     OUT NOCOPY VARCHAR2
) is

l_error_message_code  VARCHAR2(30);
l_sqlcode             VARCHAR2(30);

BEGIN
-- hr_utility.trace_on(NULL, 'RMFORM');
-- hr_utility.trace('start');

FND_MSG_PUB.initialize;

p_msg_count := 0;

p_return_status := FND_API.G_RET_STS_SUCCESS;

-- hr_utility.trace('before  my stuff');

   --  Call the table handler to delete the job defaults for this BG.

   pa_role_job_bg_pkg.delete_row(
      P_ROLE_JOB_BG_ID               =>         P_ROLE_JOB_BG_ID,
      P_OBJECT_VERSION_NUMBER        =>         P_OBJECT_VERSION_NUMBER
   );

-- hr_utility.trace('p_return_status  is      ' || p_return_status);
-- hr_utility.trace('p_msg_data  is      ' || p_msg_data);

-- IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
-- END IF;

EXCEPTION
  WHEN OTHERS THEN

-- hr_utility.trace('SQLERRM  is      ' || SQLERRM);
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       l_sqlcode := SQLCODE;

       fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_ROLE_JOB_BG_PVT',
        p_procedure_name => 'DELETE_ROW',
        p_error_text     => l_sqlcode);

        p_msg_count := p_msg_count + 1;

END;
end PA_ROLE_JOB_BG_PVT;

/
