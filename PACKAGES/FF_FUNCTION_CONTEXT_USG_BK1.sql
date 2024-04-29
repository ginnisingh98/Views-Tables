--------------------------------------------------------
--  DDL for Package FF_FUNCTION_CONTEXT_USG_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FUNCTION_CONTEXT_USG_BK1" AUTHID CURRENT_USER as
/* $Header: fffcuapi.pkh 120.1.12010000.2 2008/08/05 10:20:06 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_context_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_context_b
  (p_function_id                   in     number
  ,p_context_id                    in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_context_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_context_a
  (p_function_id                   in     number
  ,p_context_id                    in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in     number
  );
--
end FF_FUNCTION_CONTEXT_USG_BK1;

/
