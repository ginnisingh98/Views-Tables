--------------------------------------------------------
--  DDL for Package OPI_DBI_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIDEHZMGS.pls 115.0 2004/03/17 00:35:46 rjin noship $ */


PROCEDURE OPI_DBI_COGS_F_M (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);



END  OPI_DBI_PARTY_MERGE_PKG;

 

/
