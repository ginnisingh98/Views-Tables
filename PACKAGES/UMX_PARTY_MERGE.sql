--------------------------------------------------------
--  DDL for Package UMX_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_PARTY_MERGE" AUTHID CURRENT_USER AS
/* $Header: UMXPMRGS.pls 115.0 2004/07/08 22:47:34 cmehta noship $ */

PROCEDURE MERGE_PARTIES
          (
            p_entity_name         IN    VARCHAR2,
            p_from_id		  IN    NUMBER,
            p_to_id		  OUT   NOCOPY   NUMBER,
            p_from_fk_id          IN    NUMBER,
            p_to_fk_id	          IN    NUMBER,
            p_parent_entity_name  IN    VARCHAR2,
            p_batch_id		  IN    NUMBER,
            p_batch_party_id      IN    NUMBER,
            p_return_status       out NOCOPY   Varchar2
	  );


end UMX_PARTY_MERGE;

 

/
