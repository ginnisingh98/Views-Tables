--------------------------------------------------------
--  DDL for Package PQP_PCV_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PCV_BK3" AUTHID CURRENT_USER as
/* $Header: pqpcvapi.pkh 120.1 2005/10/02 02:45:10 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_configuration_value_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_configuration_value_b
  (p_configuration_value_id         in     number
  ,p_object_version_number          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_configuration_value_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_configuration_value_a
  (p_configuration_value_id         in     number
  ,p_object_version_number          in     number
  );
--
end pqp_pcv_bk3;

 

/
