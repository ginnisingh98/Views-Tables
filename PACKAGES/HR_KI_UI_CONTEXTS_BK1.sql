--------------------------------------------------------
--  DDL for Package HR_KI_UI_CONTEXTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_UI_CONTEXTS_BK1" AUTHID CURRENT_USER as
/* $Header: hrucxapi.pkh 120.1 2006/10/12 14:31:44 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_UI_CONTEXT_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_UI_CONTEXT_b
  (
        p_user_interface_id in number
       ,p_label             in varchar2
       ,p_location          in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_UI_CONTEXT_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_UI_CONTEXT_a
  (
       p_user_interface_id       in number
      ,p_label                   in varchar2
      ,p_location                in varchar2
      ,p_ui_context_id           in number
      ,p_object_version_number   in number

  );
--
end hr_ki_ui_contexts_bk1;

 

/
