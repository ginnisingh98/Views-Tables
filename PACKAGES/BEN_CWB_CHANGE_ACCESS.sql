--------------------------------------------------------
--  DDL for Package BEN_CWB_CHANGE_ACCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_CHANGE_ACCESS" AUTHID CURRENT_USER as
/* $Header: bencwbca.pkh 120.1 2006/12/01 06:15:27 ddeb noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_access >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API is used internally for Compensation Change Access functionality
--  for update of Access for the targetted popultaion.
--
-- Prerequisites:
-- The persons record identified by p_group_per_in_ler_id must already exists.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged. If false
--                                                then the person will be
--                                                updated.
--   p_popl_cd                      Yes  varchar  Decideds the population to be
--                                                to be affected.
--                                                Possible Values:
--                                                D - Direct Managers
--                                                A - All Managers
--                                                H - Selection from HGrid
--                                                S - Selection from Search
--  p_group_per_in_ler_id           No  varchar   Manager's Group Per In Ler Id
--                                                Should be Null if p_popl_cd
--                                                equals D or A.
--  p_group_pl_id                   Yes  number   Group Plan Id
--  p_group_oipl_id                 Yes  number   For Group Plan Level Access
--                                                will be always '-1'
--  p_access_cd_from                Yes  number   Filtering choosen population
--                                                Possible Values:
--                                                'ANY' - Default
--                                                'RO'  - Read Only
--                                                'UP'  - Updateable
--                                                'NA'  - Not Available
--  p_access_cd_to                  Yes  varchar  Target Access Code.
--  p_cascade                       No   varchar  This will only be populated
--                                                if p_popl_cd = 'S'
--  p_comments                      No   varchar  User comments for Notification
--  p_acting_person_id              Yes  varchar  Acting Manager's Person Id
--                                                To be used for Notification
--  p_grp_pl_name                   Yes  varchar  Group Plan Name
--                                                To be used for Notification
--  p_grp_pl_strt_dt                Yes  varchar  Group Plan For Start Date
--                                                To be used for Notification
--  p_grp_pl_end_dt                 Yes  varchar  Group Plan For End Date
--                                                To be used for Notification
-- Post Success:
--   The API will set the following out parameters:
--
--  Name                           Type     Description
--  p_return_status                number  Managers Ler Id
--
--  p_throw_exp                   varchar  Returns 'Y' if some accesses were not changed
--
-- Post Failure:
--  None
--
-- Access Status:
--  Public
--
-- {End Of Comments}

PROCEDURE update_access (
      p_validate                      in     boolean        default false
     ,p_popl_cd                       in     varchar2
     ,p_group_per_in_ler_id           in     BEN_CWB_ACCESS_STRING_ARRAY default null
     ,p_group_pl_id                   in     number
     ,p_group_oipl_id                 in     number
     ,p_access_cd_from                in     varchar2       default 'ANY'
     ,p_access_cd_to                  in     varchar2
     ,p_cascade                       in     varchar2       default 'N'
     ,p_comments                      in     varchar2       default null
     ,p_acting_person_id              in     number
     ,p_grp_pl_name                   in     varchar2
     ,p_grp_pl_for_strt_dt            in     varchar2
     ,p_grp_pl_for_end_dt             in     varchar2
     ,p_return_status                 out nocopy number
     ,p_requestor_name                 in  varchar2
     ,p_throw_exp                     out nocopy varchar2
   );

END ben_cwb_change_access;

/
