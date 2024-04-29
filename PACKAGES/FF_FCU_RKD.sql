--------------------------------------------------------
--  DDL for Package FF_FCU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FCU_RKD" AUTHID CURRENT_USER as
/* $Header: fffcurhi.pkh 120.0 2005/05/27 23:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_function_id                  in number
  ,p_sequence_number              in number
  ,p_context_id_o                 in number
  ,p_object_version_number_o      in number
  );
--
end ff_fcu_rkd;

 

/
