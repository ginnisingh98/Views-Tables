--------------------------------------------------------
--  DDL for Package IGP_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGP_PARTY_MERGE" AUTHID CURRENT_USER AS
/* $Header: IGSPADDS.pls 120.0 2005/06/01 22:13:54 appldev noship $ */

  PROCEDURE merge_party (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    p_to_id              IN OUT NOCOPY  NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      IN OUT NOCOPY  VARCHAR2 );

END igp_party_merge;

 

/
