--------------------------------------------------------
--  DDL for Package FF_FUNCTIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FUNCTIONS_BK3" AUTHID CURRENT_USER as
/* $Header: ffffnapi.pkh 120.1.12010000.2 2008/08/05 10:20:27 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_function_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_function_b
  (p_function_id                  in     number
  ,p_object_version_number        in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_function_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_function_a
  (p_function_id                  in     number
  ,p_object_version_number        in     number
  );
--
end FF_FUNCTIONS_BK3;

/
