--------------------------------------------------------
--  DDL for Package BEN_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_UTILITY" AUTHID CURRENT_USER as
/* $Header: beutilit.pkh 120.1 2005/06/08 16:13:30 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< child_exists_error >---------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE child_exists_error (
      p_table_name           IN   all_tables.table_name%TYPE,
      p_parent_table_name    IN   all_tables.table_name%TYPE DEFAULT NULL,
      p_parent_entity_name   IN   VARCHAR2 DEFAULT NULL
   );
-- ----------------------------------------------------------------------------
-- |-------------------------< parent_integrity_error ------------------------|
-- ----------------------------------------------------------------------------
Procedure parent_integrity_error
         (p_table_name in   all_tables.table_name%TYPE);

function get_preferred_currency ( p_itemType in varchar2,
         p_itemKey in varchar2) return varchar2;

end ben_utility;

 

/
