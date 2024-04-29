--------------------------------------------------------
--  DDL for Package PQH_RATE_FACTOR_ON_ELMNTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_FACTOR_ON_ELMNTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqrfeapi.pkh 120.2 2005/11/30 15:00:21 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rate_factor_on_elmnt_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_factor_on_elmnt_b
 ( p_effective_date                in     date
  ,p_rate_factor_on_elmnt_id       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rate_factor_on_elmnt_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_factor_on_elmnt_a
 ( p_effective_date                in     date
  ,p_rate_factor_on_elmnt_id       in     number
  ,p_object_version_number         in     number
  );


end PQH_RATE_FACTOR_ON_ELMNTS_BK3;

 

/
