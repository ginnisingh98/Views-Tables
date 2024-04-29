--------------------------------------------------------
--  DDL for Package PAY_PL_PAYE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_PAYE_BK3" AUTHID CURRENT_USER as
/* $Header: pyppdapi.pkh 120.4 2006/04/24 23:22:43 nprasath noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pl_paye_details_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_paye_details_b
  (p_effective_date                in     date
  ,p_paye_details_id               in     number
  ,p_datetrack_delete_mode         in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pl_paye_details_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_paye_details_a
  (p_effective_date                in     date
  ,p_paye_details_id               in     number
  ,p_datetrack_delete_mode         in     varchar2
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end PAY_PL_PAYE_BK3;

 

/
