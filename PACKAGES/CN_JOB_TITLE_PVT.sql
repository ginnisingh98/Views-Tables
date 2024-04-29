--------------------------------------------------------
--  DDL for Package CN_JOB_TITLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_JOB_TITLE_PVT" AUTHID CURRENT_USER AS
--$Header: cnvjobs.pls 115.5 2002/11/21 21:14:11 hlchen ship $
TYPE job_title_rec_type IS record
  (job_title_id             cn_job_titles.job_title_id%type,
   name                     cn_job_titles.name%type,
   job_code                 cn_job_titles.job_code%type,
   role_id                  cn_roles.role_id%type,
   role_name                cn_roles.name%type);

TYPE job_title_tbl_type IS table OF job_title_rec_type
  INDEX BY binary_integer;

TYPE job_role_rec_type IS record
  (job_role_id              cn_job_roles.job_role_id%type,
   job_title_id             cn_job_roles.job_title_id%type,
   role_id                  cn_job_roles.role_id%type,
   start_date               cn_job_roles.start_date%type,
   end_date                 cn_job_roles.end_date%type,
   default_flag             cn_job_roles.default_flag%type,
   attribute_category       cn_job_roles.attribute_category%type,
   attribute1               cn_job_roles.attribute1%type,
   attribute2               cn_job_roles.attribute2%type,
   attribute3               cn_job_roles.attribute3%type,
   attribute4               cn_job_roles.attribute4%type,
   attribute5               cn_job_roles.attribute5%type,
   attribute6               cn_job_roles.attribute6%type,
   attribute7               cn_job_roles.attribute7%type,
   attribute8               cn_job_roles.attribute8%type,
   attribute9               cn_job_roles.attribute9%type,
   attribute10              cn_job_roles.attribute10%type,
   attribute11              cn_job_roles.attribute11%type,
   attribute12              cn_job_roles.attribute12%type,
   attribute13              cn_job_roles.attribute13%type,
   attribute14              cn_job_roles.attribute14%type,
   attribute15              cn_job_roles.attribute15%type,
   object_version_number    cn_job_roles.object_version_number%type);

TYPE job_role_tbl_type IS table of job_role_rec_type
  INDEX BY binary_integer;

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
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rec                        IN      job_role_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_job_role_id                OUT NOCOPY     cn_job_roles.job_role_id%type);

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
   x_msg_data                   OUT NOCOPY     VARCHAR2);

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
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_job_role_id                IN      cn_job_roles.job_role_id%type,
   p_object_version_number      IN      cn_job_roles.object_version_number%type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

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
   x_result_tbl                 OUT NOCOPY     job_role_tbl_type);

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
   x_result_tbl                 OUT NOCOPY     job_title_tbl_type);

-- Start of comments
--    API name        : Get_All_Job_Titles - Private
--    Pre-reqs        : None.
--    IN              : (none)
--    OUT             : x_result_tbl
--    Version :         Current version       1.0
--
-- End of comments

PROCEDURE Get_All_Job_Titles
  (x_result_tbl                 OUT NOCOPY     job_title_tbl_type);

-- Start of comments
--    API name        : Get_Job_Roles - Private
--    Pre-reqs        : None.
--    IN              : (none)
--    OUT             : x_result_tbl
--    Version :         Current version       1.0
--
-- End of comments

PROCEDURE Get_Job_Roles
  (x_result_tbl                 OUT NOCOPY     job_title_tbl_type);

END CN_JOB_TITLE_PVT;

 

/
