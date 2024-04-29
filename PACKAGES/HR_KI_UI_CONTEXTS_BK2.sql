--------------------------------------------------------
--  DDL for Package HR_KI_UI_CONTEXTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_UI_CONTEXTS_BK2" AUTHID CURRENT_USER as
/* $Header: hrucxapi.pkh 120.1 2006/10/12 14:31:44 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_UI_CONTEXT_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_UI_CONTEXT_b
  (
   p_ui_context_id                 in     number
  ,p_object_version_number         in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_UI_CONTEXT_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_UI_CONTEXT_a
  (
   p_ui_context_id                 in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_ui_contexts_bk2;

 

/
