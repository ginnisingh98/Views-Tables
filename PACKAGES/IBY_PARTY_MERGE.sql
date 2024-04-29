--------------------------------------------------------
--  DDL for Package IBY_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PARTY_MERGE" AUTHID CURRENT_USER AS
/* $Header: ibyptymergs.pls 120.0.12010000.1 2009/09/01 11:14:28 sgogula noship $ */

  --
  -- Merge of exteral bank account owners
  --
  PROCEDURE acct_owner_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   );

  --
  -- Updates credit credit card owners during party merge;
  -- updates billing address during party site use merge.
  --
  PROCEDURE credit_card_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   );

  --
  -- External payer unification during merge of parties.
  --
  PROCEDURE external_payer_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   );

  --
  -- Payment instrument use merge as the result of payer merge.
  --
  PROCEDURE pmt_instrument_use_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   );

  --
  -- External party payment methods
  --
  PROCEDURE party_pmt_methods_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   );

  --
  -- Transaction Extensions merge
  --
  PROCEDURE fc_tx_extensions_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   );

  --
  -- Transaction Summaries merge
  --
  PROCEDURE txn_summ_all_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   );


END IBY_PARTY_MERGE;

/
