--------------------------------------------------------
--  DDL for Package ASN_PARTY_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASN_PARTY_MERGE_PVT" AUTHID CURRENT_USER AS
/* $Header: asnvpmgs.pls 120.1 2005/08/19 19:34:16 rradhakr noship $ */



-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- Enter package declarations as shown below

 PROCEDURE  MERGE_ACCOUNT_PLANS
  (   p_entity_name             IN     VARCHAR2,
      p_from_id                 IN     NUMBER,
      x_to_id                   OUT  NOCOPY NUMBER,
      p_from_fk_id              IN      NUMBER,
      p_to_fk_id                IN      NUMBER,
      p_parent_entity_name      IN      VARCHAR2,
      p_batch_id                IN      NUMBER,
      p_batch_party_id          IN      NUMBER,
      x_return_status           OUT NOCOPY VARCHAR2
  );

END;

 

/
