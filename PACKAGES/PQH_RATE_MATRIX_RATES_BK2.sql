--------------------------------------------------------
--  DDL for Package PQH_RATE_MATRIX_RATES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_MATRIX_RATES_BK2" AUTHID CURRENT_USER as
/* $Header: pqrmrapi.pkh 120.5 2006/03/14 11:27:52 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_rate_matrix_rate_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rate_matrix_rate_b
  (p_effective_date                in date
  ,p_rate_matrix_rate_id           in number
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_CRITERIA_RATE_DEFN_ID         in number
  ,p_MIN_RATE_VALUE                in number
  ,p_MAX_RATE_VALUE                in number
  ,p_MID_RATE_VALUE                in number
  ,p_RATE_VALUE                    in number
  ,p_BUSINESS_GROUP_ID             in number
  ,p_LEGISLATION_CODE              in varchar2
  ,p_object_version_number         in number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_rate_matrix_rate_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rate_matrix_rate_a
  (p_effective_date                in date
  ,p_rate_matrix_rate_id           in number
  ,p_EFFECTIVE_START_DATE          in date
  ,p_EFFECTIVE_END_DATE            in date
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_CRITERIA_RATE_DEFN_ID         in number
  ,p_MIN_RATE_VALUE                in number
  ,p_MAX_RATE_VALUE                in number
  ,p_MID_RATE_VALUE                in number
  ,p_RATE_VALUE                    in number
  ,p_BUSINESS_GROUP_ID             in number
  ,p_LEGISLATION_CODE              in varchar2
  ,p_object_version_number         in number
  );

--
end PQH_RATE_MATRIX_RATES_BK2;

 

/
