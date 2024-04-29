--------------------------------------------------------
--  DDL for Package PAY_USER_ROW_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_ROW_BK2" AUTHID CURRENT_USER as
/* $Header: pypurapi.pkh 120.8 2008/04/08 11:33:43 salogana noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_user_row_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_row_b
(p_effective_date                in  date
,p_datetrack_update_mode         in  varchar2
,p_user_row_id                   in  number
,p_display_sequence              in  number
,p_object_version_number         in  number
,p_row_low_range_or_name         in  varchar2
,p_disable_range_overlap_check   in  boolean
,p_disable_units_check           in  boolean
,p_row_high_range                in  varchar2
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_user_row_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_row_a
(p_effective_date                in     date
,p_datetrack_update_mode         in     varchar2
,p_user_row_id                   in     number
,p_display_sequence              in     number
,p_object_version_number         in     number
,p_row_low_range_or_name         in     varchar2
,p_disable_range_overlap_check   in     boolean
,p_disable_units_check           in     boolean
,p_row_high_range                in     varchar2
,p_effective_start_date          in     date
,p_effective_end_date            in     date
);
--
end pay_user_row_bk2;

/
