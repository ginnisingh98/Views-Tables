--------------------------------------------------------
--  DDL for Package Body CN_JOB_TITLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_JOB_TITLE_PVT" AS
--$Header: cnvjobb.pls 115.14.115100.3 2004/05/11 01:32:51 sbadami noship $

G_PKG_NAME                  CONSTANT VARCHAR2(30):= 'CN_JOB_TITLE_PVT';

PROCEDURE valid_no_srp(p_job_role_id IN cn_job_roles.job_role_id%type) IS
   l_count             NUMBER;
BEGIN
   -- make sure the job title and role involved in this record is
   -- not being used by any salesrep.
    BEGIN
      SELECT 1
      INTO l_count
      FROM cn_job_roles      jr
      WHERE jr.job_role_id  = p_job_role_id
      AND EXISTS (
          SELECT 1
          FROM cn_srp_role_dtls_v sr
          WHERE sr.job_title_id = jr.job_title_id
          AND jr.role_id      = sr.role_id );

      FND_MESSAGE.SET_NAME('CN', 'CN_JOB_ROLE_USED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       NULL ;
    END ;

END valid_no_srp;



PROCEDURE Verify_Date(p_rec IN job_role_rec_type)
IS
   l_count           NUMBER;
   l_min_start_date  DATE ;
   l_max_end_date    DATE ;
   L_NULL_END_DATE   DATE := to_date('31-12-9999','DD-MM-YYYY'); --to_date(to_char(TO_DATE('1','j'), 'DD-MM-RRRR'), 'DD-MM-RRRR') ;

BEGIN
   -- get the min start_date and the max end_date
   -- assigned to an srp for this job_role assignment
  SELECT COUNT(sj.srp_id), min(sj.start_date),
         MAX(sj.end_date)
  into l_count,l_min_start_date , l_max_end_date
  from cn_job_roles      jr,
       cn_srp_job_titles sj,
       cn_srp_roles sr
 where jr.job_role_id  = p_rec.job_role_id
   and jr.job_title_id = sj.job_title_id
   and jr.role_id = sr.role_id
   and sj.srp_id = sr.salesrep_id
  ;

  IF L_COUNT > 0 THEN
     IF l_min_start_date < p_rec.start_date THEN
        FND_MESSAGE.SET_NAME('CN', 'CN_JOB_ROLE_USED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF ;

     IF l_max_end_date IS NOT NULL THEN
         IF NVL(p_rec.end_date, L_NULL_END_DATE) < l_max_end_date
         THEN
            FND_MESSAGE.SET_NAME('CN', 'CN_JOB_ROLE_USED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF ;
     END IF ;
  END IF;
END Verify_Date;


-- Start of comments
--    API name        : Create_Job_Role - Private.
--    Pre-reqs        : None.
--    IN              : standard params
--                      p_rec of table rec type
--    OUT             : standard params
--                      x_job_role_id
--    Version         : 1.0
--
-- End of comments

PROCEDURE Create_Job_Role
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rec                        IN      job_role_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_job_role_id                OUT NOCOPY     cn_job_roles.job_role_id%type) IS

   l_api_name                   CONSTANT VARCHAR2(30) := 'Create_Job_Role';
   l_api_version                CONSTANT NUMBER       := 1.0;
   l_null_date         CONSTANT DATE := to_date('31-12-9999','DD-MM-YYYY');

   l_newrec                     job_role_rec_type := p_rec;
   l_count                      NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Create_Job_Role;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- make sure job_title_id and role_id are valid
   -- if default, make sure it doesn't overlap with another default

   -- checks validity of job_title_id, role_id, date range
   if l_newrec.end_date is not null and
      l_newrec.end_date < l_newrec.start_date then
      FND_MESSAGE.SET_NAME('CN', 'ALL_INVALID_PERIOD_RANGE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;


   --
   select count(job_role_id) into l_count
     from cn_job_roles
    where job_title_id = l_newrec.job_title_id
      and default_flag = 'Y'
      and ((start_date <= l_newrec.start_date  and
       nvl(end_date, l_null_date) >=
                      l_newrec.start_date ) OR
           (start_date >= l_newrec.start_date  and
      start_date <= nvl(l_newrec.end_date, l_null_date)));

   if l_count > 0 and l_newrec.default_flag = 'Y' then
      FND_MESSAGE.SET_NAME('CN', 'CN_JOB_ROLE_OVERLAP');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   select count(job_role_id) into l_count
     from cn_job_roles
    where job_title_id = l_newrec.job_title_id
      and role_id = l_newrec.role_id
      and ((start_date <= l_newrec.start_date  and
       nvl(end_date, l_null_date) >=
                      l_newrec.start_date ) OR
           (start_date >= l_newrec.start_date  and
      start_date <= nvl(l_newrec.end_date, l_null_date)));

   if l_count > 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_JOB_ROLE_OVERLAP');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

  select count(1) into l_count
     from cn_job_roles
    where role_id = l_newrec.role_id
      and job_title_id = l_newrec.job_title_id
      and trunc(start_date) = trunc(l_newrec.start_date)
       ;

   if l_count > 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_JOB_ROLE_OVERLAP');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   cn_job_title_pkg.insert_row(l_newrec);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get
     (p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Job_Role;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Job_Role;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Create_Job_Role;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
END Create_Job_Role;

-- Start of comments
--    API name        : Update_Job_Role - Private.
--    Pre-reqs        : None.
--    IN              : standard params
--                      p_rec of table rec type
--    OUT             : standard params
--    Version :         Current version       1.0
--
-- End of comments

PROCEDURE Update_Job_Role
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rec                        IN      job_role_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                   CONSTANT VARCHAR2(30) := 'Update_Job_Role';
   l_api_version                CONSTANT NUMBER       := 1.0;
   l_null_date         CONSTANT DATE := to_date('31-12-9999','DD-MM-YYYY');

   l_newrec                     job_role_rec_type := p_rec;
   l_count                      NUMBER;
   l_old_start                  DATE;
   l_old_end                    DATE;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Job_Role;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- checks validity of start_date
   if l_newrec.start_date is null then
      FND_MESSAGE.SET_NAME('PA', 'PA_START_DATE_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;


   -- make sure job_title_id and role_id are valid
   -- if default, make sure it doesn't overlap with another default

   -- make sure record to be updated exists.
   select count(*) into l_count
     from cn_job_roles
    where job_role_id = l_newrec.job_role_id;

   if l_count = 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_INVALID_UPDATE_REC');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- checks validity of date range
   if l_newrec.end_date is not null and
      l_newrec.end_date < l_newrec.start_date then
      FND_MESSAGE.SET_NAME('CN', 'ALL_INVALID_PERIOD_RANGE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- make sure it is not being used by any salesrep if we are narrowing
   -- the assignment interval
   select start_date, end_date
     into l_old_start, l_old_end
     from cn_job_roles
    where job_role_id = l_newrec.job_role_id;

   if l_old_start < l_newrec.start_date OR
        nvl(l_old_end,         to_date('12-31-9999','MM-DD-YYYY')) >
        nvl(l_newrec.end_date, to_date('12-31-9999','MM-DD-YYYY')) then
        verify_date(l_newrec);
   end if;

   select count(job_role_id) into l_count
     from cn_job_roles
    where job_title_id = l_newrec.job_title_id
      and job_role_id <> l_newrec.job_role_id
      and default_flag = 'Y'
      and ((start_date <= l_newrec.start_date  and
        nvl(end_date, l_null_date) >= l_newrec.start_date) OR
           (start_date >= l_newrec.start_date  and
      start_date <= nvl(l_newrec.end_date, l_null_date)));
   if l_count > 0 and l_newrec.default_flag = 'Y' then
      FND_MESSAGE.SET_NAME('CN', 'CN_JOB_ROLE_OVERLAP');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   select count(job_role_id) into l_count
     from cn_job_roles
    where job_title_id = l_newrec.job_title_id
      and job_role_id <> l_newrec.job_role_id
      and role_id = l_newrec.role_id
      and ((start_date <= l_newrec.start_date  and
       nvl(end_date, l_null_date) >=
                      l_newrec.start_date ) OR
           (start_date >= l_newrec.start_date  and
      start_date <= nvl(l_newrec.end_date, l_null_date)));

   if l_count > 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_JOB_ROLE_OVERLAP');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- make sure the object version number hasn't changed in the meantime
   cn_job_title_pkg.lock_row(l_newrec.job_role_id,
           l_newrec.object_version_number);

   cn_job_title_pkg.update_row(l_newrec);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get
     (p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Job_Role;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Job_Role;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Update_Job_Role;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
END Update_Job_Role;

-- Start of comments
--      API name        : Delete_Job_Role -  Private.
--      Pre-reqs        : None.
--      IN              : standard params
--                        p_job_role_id
--      OUT             : standard params
--      Version :         Current version       1.0
--
-- End of comments

PROCEDURE Delete_Job_Role
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_job_role_id                IN      cn_job_roles.job_role_id%type,
   p_object_version_number      IN      cn_job_roles.object_version_number%type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                   CONSTANT VARCHAR2(30) := 'Delete_Job_Role';
   l_api_version                CONSTANT NUMBER       := 1.0;
   l_count                      NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Job_Role;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- make sure record to be deleted exists.
   select count(*) into l_count
     from cn_job_roles
    where job_role_id = p_job_role_id;

   if l_count = 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_INVALID_DEL_REC');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- make sure it is not being used by any salesrep
   valid_no_srp(p_job_role_id);

   cn_job_title_pkg.delete_row(p_job_role_id);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get
     (p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Job_Role;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Job_Role;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Job_Role;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
END Delete_Job_Role;

-- Start of comments
--    API name        : Get_Job_Details - Private
--    Pre-reqs        : None.
--    IN              : p_job_title_id
--    OUT             : x_result_tbl
--    Version :         Current version       1.0
--
-- End of comments

PROCEDURE Get_Job_Details
  (p_job_title_id               IN      cn_job_titles.job_title_id%type,
   x_result_tbl                 OUT NOCOPY     job_role_tbl_type) IS

   l_count                      NUMBER  := 1;

   cursor get_data is
   select job_role_id, job_title_id, role_id,
          start_date, end_date, nvl(default_flag, 'N'),
          attribute_category,
          attribute1,  attribute2,  attribute3,  attribute4,  attribute5,
          attribute6,  attribute7,  attribute8,  attribute9,  attribute10,
          attribute11, attribute12, attribute13, attribute14, attribute15,
          object_version_number
     from cn_job_roles
    where job_title_id = p_job_title_id
    order by start_date;

BEGIN
   open get_data;
   loop
      fetch get_data into x_result_tbl(l_count);
      exit when get_data%notfound;
      l_count := l_count + 1;
   end loop;
   close get_data;
END Get_Job_Details;

-- Start of comments
--    API name        : Get_Job_Titles - Private
--    Pre-reqs        : None.
--    IN              : range params, search string for name
--    OUT             : x_result_tbl
--    Version :         Current version       1.0
--
-- End of comments

PROCEDURE Get_Job_Titles
  (p_range_low                  IN      NUMBER,
   p_range_high                 IN      NUMBER,
   p_search_name                IN      VARCHAR2 := '%',
   p_search_code                IN      VARCHAR2 := '%',
   x_total_rows                 OUT NOCOPY     NUMBER,
   x_result_tbl                 OUT NOCOPY     job_title_tbl_type) IS

   rec                          job_title_rec_type;
   l_index                      NUMBER := 0;
   l_name                       cn_job_titles.name%type;
   l_code                       cn_job_titles.job_code%type;

   cursor get_data is
   select job_title_id, name, job_code,
    null role_id, null role_name
     from cn_job_titles
    where upper(name)     like l_name
      and upper(job_code) like l_code
    order by name;

BEGIN
   x_total_rows   := 0;

   l_name := upper(p_search_name) || '%';
   l_code := upper(p_search_code) || '%';

   open get_data;
   loop
      fetch get_data into rec;
      exit when get_data%notfound;

      x_total_rows := x_total_rows + 1;
      if (x_total_rows between p_range_low and p_range_high) OR
   (p_range_high = -1) then
   l_index := l_index + 1;
   x_result_tbl(l_index) := rec;
      end if;
   end loop;
   close get_data;
END Get_Job_Titles;

-- Start of comments
--    API name        : Get_All_Job_Titles - Private
--    Pre-reqs        : None.
--    IN              : (none)
--    OUT             : x_result_tbl
--    Version :         Current version       1.0
--
-- End of comments

PROCEDURE Get_All_Job_Titles
  (x_result_tbl                 OUT NOCOPY     job_title_tbl_type) IS
   l_total_rows                 NUMBER;
BEGIN
   Get_Job_Titles
     (p_range_low   => -1,
      p_range_high  => -1,
      p_search_name => '%',
      p_search_code => '%',
      x_total_rows  => l_total_rows,
      x_result_tbl  => x_result_tbl);
END Get_All_Job_Titles;

-- Start of comments
--    API name        : Get_Job_Roles - Private
--    Pre-reqs        : None.
--    IN              : (none)
--    OUT             : x_result_tbl
--    Version :         Current version       1.0
--
-- End of comments

PROCEDURE Get_Job_Roles
  (x_result_tbl                 OUT NOCOPY     job_title_tbl_type) IS

   l_count                      NUMBER  := 1;

   cursor get_data is
   select distinct * from
  (select jr.job_title_id,
          j.name job_name,
          j.job_code,
          jr.role_id,
          r.role_name
     from cn_job_roles  jr,
          cn_job_titles j,
          jtf_rs_roles_vl r
    where jr.job_title_id = j.job_title_id
      and r.role_type_code= 'SALES_COMP'
      and (r.member_flag = 'Y' OR r.manager_flag = 'Y') -- added check
      and jr.role_id      = r.role_id
    order by jr.job_title_id, jr.default_flag DESC);

BEGIN
   open get_data;
   loop
      fetch get_data into x_result_tbl(l_count);
      exit when get_data%notfound;
      l_count := l_count + 1;
   end loop;
   close get_data;
END Get_Job_Roles;

END CN_JOB_TITLE_PVT;

/
