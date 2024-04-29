--------------------------------------------------------
--  DDL for Package AME_ATTRIBUTE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATTRIBUTE_BK3" AUTHID CURRENT_USER as
/* $Header: amatrapi.pkh 120.3.12010000.2 2019/09/12 12:02:21 jaakhtar ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_attribute_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_attribute_b
  (p_attribute_id                  in     number
  ,p_description                   in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_attribute_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_attribute_a
  (p_attribute_id                  in     number
  ,p_description                   in     varchar2
  ,p_object_version_number         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  );
--
--
end ame_attribute_bk3;

/
