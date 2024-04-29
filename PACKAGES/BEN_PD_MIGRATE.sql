--------------------------------------------------------
--  DDL for Package BEN_PD_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PD_MIGRATE" AUTHID CURRENT_USER as
/* $Header: bepdcmig.pkh 115.0 2003/08/07 12:06:55 rpillay noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< migrate_cer_rows >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure migrate_cer_rows
(
   p_copy_entity_txn_id             in  number
) ;

end BEN_PD_MIGRATE;

 

/
