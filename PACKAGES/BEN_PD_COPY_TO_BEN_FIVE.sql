--------------------------------------------------------
--  DDL for Package BEN_PD_COPY_TO_BEN_FIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PD_COPY_TO_BEN_FIVE" AUTHID CURRENT_USER as
/* $Header: bepdccp5.pkh 115.1 2002/11/27 01:25:38 pabodla noship $ */
--
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
g_ghr_mode              varchar2(10) default  'FALSE';
--
procedure create_rate_rows
(
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
);

--
-- ----------------------------------------------------------------------------
end BEN_PD_COPY_TO_BEN_five;

 

/
