--------------------------------------------------------
--  DDL for Package POS_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/*$Header: POSPTYMS.pls 115.1 2004/05/28 19:58:09 bitang noship $ */

-- public method called by party merge program
PROCEDURE party_merge_routine
  (p_entity_name 	IN     VARCHAR2,
   p_from_id     	IN     NUMBER,
   p_to_id       	IN OUT nocopy NUMBER,
   p_from_fk_id  	IN     NUMBER,
   p_to_fk_id    	IN     NUMBER,
   p_parent_entity_name IN     VARCHAR2,
   p_batch_id           IN     VARCHAR2,
   p_batch_party_id     IN     VARCHAR2,
   x_return_status      IN OUT nocopy VARCHAR2
   );

END pos_party_merge_pkg;

 

/
