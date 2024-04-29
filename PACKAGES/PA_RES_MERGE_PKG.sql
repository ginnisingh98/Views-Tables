--------------------------------------------------------
--  DDL for Package PA_RES_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RES_MERGE_PKG" AUTHID CURRENT_USER AS
 /* $Header: PARTCAMS.pls 120.0 2005/05/30 12:27:05 appldev noship $ */



PROCEDURE res_party_merge(
p_entity_name                IN   VARCHAR2,
p_from_id                    IN   NUMBER,
x_to_id                      OUT NOCOPY NUMBER,
p_from_fk_id                 IN   NUMBER,
p_to_fk_id                   IN   NUMBER,
p_parent_entity_name         IN   VARCHAR2,
p_batch_id                   IN   NUMBER,
p_batch_party_id             IN   NUMBER,
x_return_status              OUT NOCOPY VARCHAR2);

end;

 

/
