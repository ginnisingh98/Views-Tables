--------------------------------------------------------
--  DDL for Package Body PQP_GET_DATE_MODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GET_DATE_MODE" as
/* $Header: pqdtmode.pkb 115.1 2003/02/18 23:57:54 sshetty noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< Update Date Mode >---------------|
-- ----------------------------------------------------------------------------

Procedure find_dt_upd_modes
  (p_effective_date         in date
  ,p_base_table_name        in varchar2
  ,p_base_key_column        in varchar2
  ,p_base_key_value         in number
  ,p_correction             out nocopy number
  ,p_update                 out nocopy number
  ,p_update_override        out nocopy number
  ,p_update_change_insert   out nocopy number
  )

IS
l_correction                 BOOLEAN;
l_update                     BOOLEAN;
l_update_override            BOOLEAN;
l_update_change_insert       BOOLEAN;
BEGIN

 dt_api.find_dt_upd_modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => p_base_table_name
    ,p_base_key_column       => p_base_key_column
    ,p_base_key_value        => p_base_key_value
    ,p_correction            => l_correction
    ,p_update                => l_update
    ,p_update_override       => l_update_override
    ,p_update_change_insert  => l_update_change_insert
    );

 IF l_correction THEN
  p_correction:=1;
 ELSE
  p_correction:=0;
 END IF;


 IF l_update THEN
  p_update :=1;
 ELSE
  p_update :=0;
 END IF;

 IF l_update_override  THEN
  p_update_override :=1;
 ELSE
  p_update_override :=0;
 END IF;

 IF l_update_change_insert  THEN
  p_update_change_insert :=1;
 ELSE
  p_update_change_insert :=0;
 END IF;
END;
--
--
-- ----------------------------------------------------------------------------
-- |------------------< Delete Date Mode >------------------|
-- ----------------------------------------------------------------------------


Procedure find_dt_del_modes
  (p_effective_date        in date
  ,p_base_table_name       in varchar2
  ,p_base_key_column       in varchar2
  ,p_base_key_value        in number
  ,p_zap                   out nocopy number
  ,p_delete                out nocopy number
  ,p_future_change         out nocopy number
  ,p_delete_next_change    out nocopy number
  )

IS
l_zap                         BOOLEAN;
l_delete                      BOOLEAN;
l_future_change               BOOLEAN;
l_delete_next_change          BOOLEAN;
BEGIN

dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               => p_base_table_name
   ,p_base_key_column               => p_base_key_column
   ,p_base_key_value                => p_base_key_value
   ,p_zap                           => l_zap
   ,p_delete                        => l_delete
   ,p_future_change                 => l_future_change
   ,p_delete_next_change            => l_delete_next_change
   );

 IF l_zap  THEN
  p_zap:=1;
 ELSE
  p_zap:=0;
 END IF;

 IF l_delete  THEN
  p_delete:=1;
 ELSE
  p_delete:=0;
 END IF;

 IF l_future_change  THEN
  p_future_change:=0;
 ELSE
  p_future_change:=0;
 END IF;

 IF l_delete_next_change  THEN
  p_delete_next_change:=0;
 ELSE
  p_delete_next_change:=0;
 END IF;
END;


end pqp_get_date_mode;

/
