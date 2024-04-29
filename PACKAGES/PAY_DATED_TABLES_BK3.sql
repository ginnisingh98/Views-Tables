--------------------------------------------------------
--  DDL for Package PAY_DATED_TABLES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DATED_TABLES_BK3" AUTHID CURRENT_USER as
/* $Header: pyptaapi.pkh 120.0 2005/05/29 07:55:56 appldev noship $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< delete_dated_table_b >------------------|
-- ----------------------------------------------------------------------
--
procedure delete_dated_table_b
 ( p_dated_table_id                       in     number
  ,p_object_version_number                in     number
  );
--
-- ----------------------------------------------------------------------
-- |---------------------< delete_dated_table_a >-----------------------|
-- ----------------------------------------------------------------------
--
procedure delete_dated_table_a
 ( p_dated_table_id                       in     number
  ,p_object_version_number                in     number
  );
--
end  pay_dated_tables_bk3;

 

/
