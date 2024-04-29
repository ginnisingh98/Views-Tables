--------------------------------------------------------
--  DDL for Package BEN_DM_GEN_SELF_REF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_GEN_SELF_REF" AUTHID CURRENT_USER as
/* $Header: benfdmgnsr.pkh 120.0 2006/06/13 14:58:19 nkkrishn noship $ */
-- ------------------------- create_tups_pacakge ------------------------
procedure main
(
 p_business_group_id      in   number,
 p_migration_id           in   number
);
end BEN_DM_GEN_SELF_REF ;

 

/
