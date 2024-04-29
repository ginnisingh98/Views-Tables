--------------------------------------------------------
--  DDL for Package HR_CONTINGENT_WORKER_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTINGENT_WORKER_BK5" AUTHID CURRENT_USER as
/* $Header: pecwkapi.pkh 120.1.12010000.1 2008/07/28 04:28:14 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< reverse_terminate_placement_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure reverse_terminate_placement_b
    (p_validate                      in     boolean
    ,p_person_id                     in     number
    ,p_actual_termination_date       in     date
    ,p_clear_details                 in     varchar2
    );
--
-- ----------------------------------------------------------------------------
-- |---------------------< reverse_terminate_placement_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure reverse_terminate_placement_a
    (p_validate                      in     boolean
    ,p_person_id                     in     number
    ,p_actual_termination_date       in     date
    ,p_clear_details                 in     varchar2
    ,p_fut_actns_exist_warning       in     boolean
    );
end hr_contingent_worker_bk5;

/
