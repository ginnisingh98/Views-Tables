--------------------------------------------------------
--  DDL for Package FF_FCU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FCU_RKI" AUTHID CURRENT_USER as
/* $Header: fffcurhi.pkh 120.0 2005/05/27 23:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_function_id                  in number
  ,p_sequence_number              in number
  ,p_context_id                   in number
  ,p_object_version_number        in number
  );
end ff_fcu_rki;

 

/
