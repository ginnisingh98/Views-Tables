--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TYPES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TYPES_BK3" AUTHID CURRENT_USER as
/* $Header: pyetpapi.pkh 120.2.12010000.2 2008/08/06 07:12:24 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_ELEMENT_TYPE_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ELEMENT_TYPE_b
 (p_effective_date                  in date
 ,p_datetrack_delete_mode           in varchar2
 ,p_element_type_id                 in number
 ,p_object_version_number           in number
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_ELEMENT_TYPE_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ELEMENT_TYPE_a
 (p_effective_date                  in date
 ,p_datetrack_delete_mode           in varchar2
 ,p_element_type_id                 in number
 ,p_object_version_number           in number
 ,p_effective_start_date            in date
 ,p_effective_end_date              in date
 ,p_balance_feeds_warning	    in boolean
 ,p_processing_rules_warning  	    in boolean
 );
--
end PAY_ELEMENT_TYPES_bk3;

/
