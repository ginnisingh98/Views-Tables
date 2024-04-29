--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TEMPLATE_USER_ISWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TEMPLATE_USER_ISWI" AUTHID CURRENT_USER As
/* $Header: pytemswi.pkh 120.0 2005/05/29 09:04 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_element >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_template_user_init.create_element
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_element
  (p_validate                     in     number
  ,p_save_for_later               in     varchar2
  ,p_rec                          in     PAY_ELE_TMPLT_OBJ
  ,p_sub_class                    in     PAY_ELE_SUB_CLASS_TABLE
  ,p_freq_rule                    in     PAY_FREQ_RULE_TABLE
  ,p_ele_template_id                 out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_element >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_template_user_init.delete_element
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_element
  (p_validate                     in     number
  ,p_template_id                  in     number
  ,p_return_status                out nocopy varchar2
  );
 end pay_element_template_user_iswi;

 

/
