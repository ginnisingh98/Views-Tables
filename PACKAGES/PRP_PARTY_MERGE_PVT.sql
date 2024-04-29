--------------------------------------------------------
--  DDL for Package PRP_PARTY_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PRP_PARTY_MERGE_PVT" AUTHID CURRENT_USER AS
/* $Header: PRPVPMGS.pls 115.0 2003/04/02 00:12:41 vpalaiya noship $ */

PROCEDURE Merge_Proposals
  (
   p_entity_name                 IN VARCHAR2,
   p_from_id                     IN NUMBER,
   x_to_id                       OUT NOCOPY NUMBER,
   p_from_fk_id                  IN NUMBER,
   p_to_fk_id                    IN NUMBER,
   p_parent_entity_name          IN VARCHAR2,
   p_batch_id                    IN NUMBER,
   p_batch_party_id              IN NUMBER,
   x_return_status               OUT NOCOPY VARCHAR2
  );

PROCEDURE Merge_Email_Recipients
  (
   p_entity_name                 IN VARCHAR2,
   p_from_id                     IN NUMBER,
   x_to_id                       OUT NOCOPY NUMBER,
   p_from_fk_id                  IN NUMBER,
   p_to_fk_id                    IN NUMBER,
   p_parent_entity_name          IN VARCHAR2,
   p_batch_id                    IN NUMBER,
   p_batch_party_id              IN NUMBER,
   x_return_status               OUT NOCOPY VARCHAR2
  );


END PRP_PARTY_MERGE_PVT;

 

/
