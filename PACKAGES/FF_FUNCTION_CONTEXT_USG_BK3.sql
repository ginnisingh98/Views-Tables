--------------------------------------------------------
--  DDL for Package FF_FUNCTION_CONTEXT_USG_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FUNCTION_CONTEXT_USG_BK3" AUTHID CURRENT_USER as
/* $Header: fffcuapi.pkh 120.1.12010000.2 2008/08/05 10:20:06 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_context_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_context_b
  (p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_context_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_context_a
  (p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in     number
  );

--
end FF_FUNCTION_CONTEXT_USG_BK3;

/
