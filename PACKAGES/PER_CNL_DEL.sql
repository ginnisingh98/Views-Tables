--------------------------------------------------------
--  DDL for Package PER_CNL_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CNL_DEL" AUTHID CURRENT_USER as
/* $Header: pecnlrhi.pkh 120.0 2005/05/31 06:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the delete process
--   for the specified entity. The role of this process is to delete the
--   row from the HR schema. This process is the main backbone of the del
--   business process. The processing of this procedure is as follows:
--   1) The controlling validation process delete_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_delete process is then executed which enables any
--      logic to be processed before the delete dml process is executed.
--   3) The delete_dml process will physical perform the delete dml for the
--      specified row.
--   4) The post_delete process is then executed which enables any
--      logic to be processed after the delete dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in per_cnl_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the delete
--   process for the specified entity and is the outermost layer. The role
--   of this process is to validate and delete the specified row from the
--   HR schema. The processing of this procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      explicitly coding the attribute parameters into the g_rec_type
--      datatype.
--   2) After the conversion has taken place, the corresponding record del
--      interface process is executed.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure del
  (p_location_id                          in     number
  ,p_object_version_number                in     number
  );
--
end per_cnl_del;

 

/
