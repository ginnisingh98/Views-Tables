--------------------------------------------------------
--  DDL for Package PQH_RT_MATRIX_NODE_VALUES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RT_MATRIX_NODE_VALUES_BK1" AUTHID CURRENT_USER as
/* $Header: pqrmvapi.pkh 120.6 2006/03/14 11:28:14 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_rt_matrix_node_value_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rt_matrix_node_value_b
  (p_effective_date                in     date
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_SHORT_CODE                    in varchar2
  ,p_CHAR_VALUE1                   in varchar2
  ,p_CHAR_VALUE2                   in varchar2
  ,p_CHAR_VALUE3                   in varchar2
  ,p_CHAR_VALUE4                   in varchar2
  ,p_NUMBER_VALUE1                 in number
  ,p_NUMBER_VALUE2                 in number
  ,p_NUMBER_VALUE3                 in number
  ,p_NUMBER_VALUE4                 in number
  ,p_DATE_VALUE1                   in date
  ,p_DATE_VALUE2                   in date
  ,p_DATE_VALUE3                   in date
  ,p_DATE_VALUE4                   in date
  ,p_BUSINESS_GROUP_ID             in number
  ,p_LEGISLATION_CODE              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_rt_matrix_node_value_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rt_matrix_node_value_a
  (p_effective_date                in date
  ,p_NODE_VALUE_ID                 in number
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_SHORT_CODE                    in varchar2
  ,p_CHAR_VALUE1                   in varchar2
  ,p_CHAR_VALUE2                   in varchar2
  ,p_CHAR_VALUE3                   in varchar2
  ,p_CHAR_VALUE4                   in varchar2
  ,p_NUMBER_VALUE1                 in number
  ,p_NUMBER_VALUE2                 in number
  ,p_NUMBER_VALUE3                 in number
  ,p_NUMBER_VALUE4                 in number
  ,p_DATE_VALUE1                   in date
  ,p_DATE_VALUE2                   in date
  ,p_DATE_VALUE3                   in date
  ,p_DATE_VALUE4                   in date
  ,p_BUSINESS_GROUP_ID             in number
  ,p_LEGISLATION_CODE              in varchar2
  ,p_object_version_number           in number
  );
--
end PQH_RT_MATRIX_NODE_VALUES_BK1;

 

/
