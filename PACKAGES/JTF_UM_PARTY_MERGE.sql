--------------------------------------------------------
--  DDL for Package JTF_UM_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_PARTY_MERGE" AUTHID CURRENT_USER as
/*$Header: JTFUMPMS.pls 115.2 2002/11/21 22:58:11 kching ship $*/

PROCEDURE MERGE_APPROVAL
          (
            p_entity_name         IN    VARCHAR2,
            p_from_id		  IN    NUMBER,
            p_to_id		  out NOCOPY   NUMBER,
            p_from_fk_id          IN    NUMBER,
            p_to_fk_id	          IN    NUMBER,
            p_parent_entity_name  IN    VARCHAR2,
            p_batch_id		  IN    NUMBER,
            p_batch_party_id      IN    NUMBER,
            p_return_status       out NOCOPY   Varchar2
	  );
END JTF_UM_PARTY_MERGE;

 

/
