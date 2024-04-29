--------------------------------------------------------
--  DDL for Package PAY_BATCH_ELEMENT_ENTRY_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BATCH_ELEMENT_ENTRY_BK7" AUTHID CURRENT_USER as
/* $Header: pybthapi.pkh 120.4 2005/10/28 05:44:22 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_header_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_header_b
  (p_batch_id                      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_header_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_header_a
  (p_batch_id                      in     number
  ,p_object_version_number         in     number
  );
--
end pay_batch_element_entry_bk7;

 

/
