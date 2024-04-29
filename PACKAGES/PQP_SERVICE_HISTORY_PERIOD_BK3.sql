--------------------------------------------------------
--  DDL for Package PQP_SERVICE_HISTORY_PERIOD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_SERVICE_HISTORY_PERIOD_BK3" AUTHID CURRENT_USER as
/* $Header: pqshpapi.pkh 120.1 2005/10/02 02:27:57 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_pqp_service_hist_pd_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pqp_service_hist_pd_b
  (p_service_history_period_id     in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_pqp_service_hist_pd_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pqp_service_hist_pd_a
  (p_service_history_period_id     in     number
  ,p_object_version_number         in     number
  );
--
end pqp_service_history_period_bk3;

 

/
