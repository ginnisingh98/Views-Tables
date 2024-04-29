--------------------------------------------------------
--  DDL for Package IBY_HZ_UNIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_HZ_UNIFICATION_PKG" AUTHID CURRENT_USER AS
/* $Header: ibyhzufs.pls 120.1 2006/08/24 23:18:57 jleybovi noship $ */

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
  -- External payee unification during merge of parties.
  --
  PROCEDURE external_payee_merge
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
  -- Payment instrument use merge as the result of payee/payer merge.
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
  -- Merge of exteral bank account owners
  --
  PROCEDURE bank_acct_owner_merge
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

  PROCEDURE doc_payable_merge
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

  PROCEDURE payments_all_merge
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

END IBY_HZ_UNIFICATION_PKG;

 

/
