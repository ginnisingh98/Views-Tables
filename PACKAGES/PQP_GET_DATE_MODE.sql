--------------------------------------------------------
--  DDL for Package PQP_GET_DATE_MODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GET_DATE_MODE" AUTHID CURRENT_USER as
/* $Header: pqdtmode.pkh 115.0 2003/02/05 16:50:30 sshetty noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< Update Date Mode >---------------|
-- ----------------------------------------------------------------------------

Procedure find_dt_upd_modes
  (p_effective_date         IN  DATE
  ,p_base_table_name        IN  VARCHAR2
  ,p_base_key_column        IN  VARCHAR2
  ,p_base_key_value         IN  NUMBER
  ,p_correction             OUT NOCOPY NUMBER
  ,p_update                 OUT NOCOPY NUMBER
  ,p_update_override        OUT NOCOPY NUMBER
  ,p_update_change_insert   OUT NOCOPY NUMBER
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------< Delete Date Mode >------------------|
-- ----------------------------------------------------------------------------


Procedure find_dt_del_modes
  (p_effective_date        IN DATE
  ,p_base_table_name       IN VARCHAR2
  ,p_base_key_column       IN VARCHAR2
  ,p_base_key_value        IN NUMBER
  ,p_zap                   OUT NOCOPY NUMBER
  ,p_delete                OUT NOCOPY NUMBER
  ,p_future_change         OUT NOCOPY NUMBER
  ,p_delete_next_change    OUT NOCOPY NUMBER
  );


end pqp_get_date_mode;

 

/
