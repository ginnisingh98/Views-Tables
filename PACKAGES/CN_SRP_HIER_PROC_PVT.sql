--------------------------------------------------------
--  DDL for Package CN_SRP_HIER_PROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_HIER_PROC_PVT" AUTHID CURRENT_USER AS
  /*$Header: cnvsrhrs.pls 115.9 2002/11/21 21:19:14 hlchen ship $*/

type srp_tbl_type IS table OF number
INDEX BY binary_integer;

type srp_role_group_rec_type IS RECORD
   (salesrep_id         number,
     role_id            number,
     group_id           number,
     mgr_srp_id         number,
     start_date         date,
     end_date           date,
     hier_level         number);

type srp_role_group_tbl_type IS table OF srp_role_group_rec_type INDEX BY binary_integer;


type srp_role_info_rec_type IS RECORD
  (
     srp_role_id        NUMBER,
     srp_id             number,
     overlay_flag       varchar2(1),
     non_std_flag       varchar2(1),
     role_id            NUMBER,
     role_name          VARCHAR2(60),
     job_title_id       NUMBER,
     job_discretion     VARCHAR2(80),
     status             VARCHAR2(30),
     plan_activate_status VARCHAR2(30),
     club_eligible_flag VARCHAR2(1),
     org_code           VARCHAR2(30),
     start_date         date,
     end_date           date,
     group_id           number
     );

type srp_role_info_tbl_type IS table OF srp_role_info_rec_type INDEX BY binary_integer;



type srp_group_rec_type IS record
  (salesrep_id         number,
    group_id      number,
    effective_date     date);

type input_group_type IS record
  (group_id      number(15),
    effective_date    date);

type group_rec_type IS record
  (group_id      number(15),
    start_date    date,
    end_date      date,
    hier_level    number);

type group_tbl_type IS table OF group_rec_type INDEX BY binary_integer;

type group_mbr_rec_type IS record
(
 group_id number,
 salesrep_id number,
 mgr_srp_id number,
 hier_level number
);

type group_mbr_tbl_type IS table OF group_mbr_rec_type INDEX BY binary_integer;


-- Start of comments
--    API name        : Get_Managers
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_salesrep_id         IN NUMBER       Required
--                      p_comp_group_id       IN NUMBER       Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_salesrep_tbl        OUT srp_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_Managers
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level            IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                            ,
  p_salesrep_id                 IN      number                          ,
  p_comp_group_id               IN      number                          ,
  p_effective_date              IN      date                            ,
  x_return_status               OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY     NUMBER                          ,
  x_msg_data                    OUT NOCOPY     VARCHAR2                        ,
  x_salesrep_tbl                OUT NOCOPY     srp_role_group_tbl_type         ,
  x_returned_rows               OUT NOCOPY     integer                         );

-- Start of comments
--    API name        : Get_Salesreps
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_salesrep_id         IN NUMBER       Required
--                      p_comp_group_id       IN NUMBER       Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_salesrep_tbl        OUT srp_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_Salesreps
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level            IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                            ,
  p_salesrep_id                 IN      number                          ,
  p_comp_group_id               IN      number                          ,
  p_effective_date              IN      date                            ,
  p_return_current              IN      varchar2 := 'N'                 ,
  x_return_status               OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY     NUMBER                          ,
  x_msg_data                    OUT NOCOPY     VARCHAR2                        ,
  x_salesrep_tbl                OUT NOCOPY     srp_role_group_tbl_type         ,
  x_returned_rows               OUT NOCOPY     integer                         );

-- Start of comments
--    API name        : Get_Ancestor_Salesreps
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_srp                 IN srp_group_rec_type Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_srp                 OUT srp_role_group_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_Ancestor_Salesreps
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    OUT NOCOPY srp_role_group_tbl_type,
  x_returned_rows          OUT NOCOPY number);

-- Start of comments
--    API name        : Get_Descendant_Salesreps
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_srp                 IN srp_group_rec_type Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_srp                 OUT srp_role_group_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_Descendant_Salesreps
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  p_return_current         IN  varchar2 := 'Y',
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    OUT NOCOPY srp_role_group_tbl_type,
  x_returned_rows          OUT NOCOPY number);


-- Start of comments
--    API name        : Get_desc_role_info
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_srp                 IN srp_group_rec_type Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_srp                 OUT srp_role_info_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_desc_role_info
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  p_return_current         IN  varchar2 := 'Y',
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    OUT NOCOPY srp_role_info_tbl_type,
  x_returned_rows          OUT NOCOPY number);

-- ***********************************
-- TBD : MO
-- ***********************************
PROCEDURE Get_MO_desc_role_info
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  p_return_current         IN  varchar2 := 'Y',
  p_is_multiorg            IN  VARCHAR2 := 'N',
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    OUT NOCOPY srp_role_info_tbl_type,
  x_returned_rows          OUT NOCOPY number);

-- Start of comments
--    API name        : Get_desc_role_info
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_srp                 IN srp_group_rec_type Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_srp                 OUT group_mbr_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_descendant_group_mbrs
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  p_return_current         IN  varchar2 := 'Y',
  p_level                  IN  number := 0,
  p_first_level_only       IN  varchar2 := 'N',
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    IN OUT NOCOPY group_mbr_tbl_type,
  x_returned_rows          OUT NOCOPY number);

-- ***********************************
-- TBD : MO
-- ***********************************

PROCEDURE Get_MO_descendant_group_mbrs
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  p_return_current         IN  varchar2 := 'Y',
  p_level                  IN  number := 0,
  p_first_level_only       IN  varchar2 := 'N',
  p_is_multiorg            IN  VARCHAR2 := 'N',
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    IN OUT NOCOPY group_mbr_tbl_type,
  x_returned_rows          OUT NOCOPY number);

-- API name 	: get_ancestor_group
-- Type	        : Private.
-- Pre-reqs	: None
-- Usage	:
--
-- Desc 	:
--
--
--
-- Parameters	:
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_group               IN input_group_type Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_group               OUT group_tbl_type
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
    -- End of comments



PROCEDURE get_ancestor_group
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_group                 IN  input_group_type,
  x_group                 IN OUT NOCOPY group_tbl_type,
  p_level                 IN number := 0);

-- API name 	: get_descendant_group
-- Type	        : Private.
-- Pre-reqs	: None
-- Usage	:
--
-- Desc 	:
--
--
--
-- Parameters	:
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_group               IN input_group_type Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_group               OUT group_tbl_type
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_descendant_group
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_group                 IN  input_group_type,
  x_group                 IN OUT NOCOPY group_tbl_type,
  p_level                 IN number);

-- Start of comments
--    API name        : Get_All_Managers
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_srp                 IN srp_group_rec_type Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_srp                 OUT srp_role_group_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_All_Managers
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    OUT NOCOPY srp_role_group_tbl_type,
  x_returned_rows          OUT NOCOPY number);

END cn_srp_hier_proc_pvt;

 

/
