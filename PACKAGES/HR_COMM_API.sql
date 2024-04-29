--------------------------------------------------------
--  DDL for Package HR_COMM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMM_API" AUTHID CURRENT_USER as
/* $Header: hrcomrhi.pkh 115.2 2002/12/18 12:47:57 hjonnala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  comment_id                        number(15),
  source_table_name                 varchar2(30),
  comment_text                      varchar2(4000)
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Locks the required rows. If the object version attribute
--              is specified then the object version control also is checked.
--
Procedure lck
  (
  p_comment_id                         in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Insert entity interface
--
-- hr_comm_api.ins entity business process model
-- --------------------------------------------------------------------------
--
-- ins
--   |
--   |-- insert_validate
--   |     |-- <validation operations>
--   |
--   |-- pre_insert
--   |-- insert_dml
--   |-- post_insert
--
-- --------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Insert attribute interface
--
-- hr_comm_api.ins attribute business process model
-- --------------------------------------------------------------------------
--
-- ins
--  |
--  |-- convert_args
--  |-- ins
--        |
--        |-- insert_validate
--        |     |-- <validation operations>
--        |
--        |-- pre_insert
--        |-- insert_dml
--        |-- post_insert
--
-- --------------------------------------------------------------------------
Procedure ins
  (
  p_comment_id                   out nocopy number,
  p_source_table_name            in varchar2,
  p_comment_text                 in varchar2  default null,
  p_validate                     in boolean   default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Update entity interface
--
-- hr_comm_api.upd entity business process model
-- --------------------------------------------------------------------------
--
-- upd
--   |
--   |-- lck
--   |-- convert_defs
--   |-- update_validate
--   |     |-- <validation operations>
--   |
--   |-- pre_update
--   |-- update_dml
--   |-- post_update
--
-- --------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Update attribute interface
--
-- hr_comm_api.upd attribute business process model
-- --------------------------------------------------------------------------
--
-- upd
--   |
--   |-- convert_args
--   |-- upd
--         |
--         |-- lck
--         |-- convert_defs
--         |-- update_validate
--         |     |-- <validation operations>
--         |
--         |-- pre_update
--         |-- update_dml
--         |-- post_update
--
-- --------------------------------------------------------------------------
Procedure upd
  (
  p_comment_id                   in out nocopy number,
  p_source_table_name            in varchar2     default hr_api.g_varchar2,
  p_comment_text                 in varchar2     default hr_api.g_varchar2,
  p_validate                     in boolean      default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Delete entity interface
--
-- hr_comm_api.del entity business process model
-- --------------------------------------------------------------------------
--
-- del
--   |
--   |-- lck
--   |-- delete_validate
--   |     |-- <validation operations>
--   |
--   |-- pre_delete
--   |-- delete_dml
--   |-- post_delete
--
-- --------------------------------------------------------------------------
Procedure del
  (
  p_rec	       in g_rec_type,
  p_validate   in boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Delete attribute interface
--
-- hr_comm_api.del attribute business process model
-- --------------------------------------------------------------------------
--
-- del
--  |
--  |-- del
--        |
--        |-- lck
--        |-- delete_validate
--        |     |-- <validation operations>
--        |
--        |-- pre_delete
--        |-- delete_dml
--        |-- post_delete
--
-- --------------------------------------------------------------------------
Procedure del
  (
  p_comment_id                         in number,
  p_validate                           in boolean default false
  );
--
end hr_comm_api;

 

/
