--------------------------------------------------------
--  DDL for Package PQH_RATE_MATRIX_RATES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_MATRIX_RATES_BK3" AUTHID CURRENT_USER as
/* $Header: pqrmrapi.pkh 120.5 2006/03/14 11:27:52 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rate_matrix_rate_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_matrix_rate_b
  (p_effective_date                in     date
  ,p_rate_matrix_rate_ID  	   in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rate_matrix_rate_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_matrix_rate_a
  (p_effective_date                in     date
  ,p_rate_matrix_rate_ID           in     number
  ,p_object_version_number         in     number
  );
--
end PQH_RATE_MATRIX_RATES_BK3;

 

/
