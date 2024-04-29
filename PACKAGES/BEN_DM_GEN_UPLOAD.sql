--------------------------------------------------------
--  DDL for Package BEN_DM_GEN_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_GEN_UPLOAD" AUTHID CURRENT_USER as
/* $Header: benfdmgnup.pkh 120.0 2006/05/04 04:49:33 nkkrishn noship $ */
-- ------------------------- create_tups_pacakge ------------------------




procedure main
(
-- p_business_group_id      in   number,
 p_table_alias            in   varchar2 ,
 p_migration_id           in   number
);



end BEN_DM_GEN_UPLOAD;

 

/
