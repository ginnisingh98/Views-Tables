--------------------------------------------------------
--  DDL for Package GMF_TRANSACTION_ACCOUNTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_TRANSACTION_ACCOUNTS_PUB" AUTHID CURRENT_USER AS
/* $Header: GMFXTABS.pls 120.2 2005/09/14 06:19:18 umoogala noship $ */

  Procedure get_accounts
    ( p_api_version                       IN            NUMBER
    , p_init_msg_list                     IN            VARCHAR2
    , p_source                            IN            VARCHAR2

    , x_return_status                     OUT NOCOPY    VARCHAR2
    , x_msg_data                          OUT NOCOPY    VARCHAR2
    , x_msg_count                         OUT NOCOPY    NUMBER
    )
  ;

--
-- Public record types
--
   TYPE t_rec_gmf_xla_tab_PUR IS RECORD
   (
      source_distrib_id_num_1            NUMBER           --INPUT
    , source_distrib_id_num_2            NUMBER           --INPUT
    , source_distrib_id_num_3            NUMBER           --INPUT
    , source_distrib_id_num_4            NUMBER           --INPUT
    , source_distrib_id_num_5            NUMBER           --INPUT

    , account_type_code                  VARCHAR2(30)     -- INV, EXP, or AAP: NOT NULL

    --START of source list
    , organization_id                    NUMBER           --INPUT
    , inventory_item_id                  NUMBER           --INPUT
    , item_type                          VARCHAR2(80)     --INPUT
    , ledger_id                          NUMBER           --INPUT
    , legal_entity_id                    NUMBER           --INPUT
    , operating_unit                     VARCHAR2(15)     --INPUT
    , subinventory_code                  VARCHAR2(80)     --INPUT
    , subinventory_type                  VARCHAR2(80)     --INPUT
    , locator_id                         NUMBER           --INPUT
    , lot_number                         NUMBER           --INPUT
    , vendor_id                          NUMBER           --INPUT
    , vendor_site_id                     NUMBER           --INPUT
    --END of source list

    , target_ccid                        NUMBER(15)       --OUTPUT
    , concatenated_segments              VARCHAR2(2000)   --OUTPUT
    , msg_count                          NUMBER           --OUTPUT
    , msg_data                           VARCHAR2(2000)   --OUTPUT
   );


   TYPE t_rec_gmf_xla_tab_CTO IS RECORD
   (
      source_distrib_id_num_1            NUMBER           --INPUT
    , source_distrib_id_num_2            NUMBER           --INPUT
    , source_distrib_id_num_3            NUMBER           --INPUT
    , source_distrib_id_num_4            NUMBER           --INPUT
    , source_distrib_id_num_5            NUMBER           --INPUT

    , account_type_code                  VARCHAR2(30)     -- INV, EXP, or AAP: NOT NULL

    --START of source list
    , organization_id                    NUMBER           --INPUT
    , inventory_item_id                  NUMBER           --INPUT
    , ato_flag                           VARCHAR2(1)      --INPUT
    , ledger_id                          NUMBER           --INPUT
    , legal_entity_id                    NUMBER           --INPUT
    , operating_unit                     NUMBER           --INPUT
    , vendor_id                          NUMBER           --INPUT
    , vendor_site_id                     NUMBER           --INPUT
    , customer_id                        NUMBER           --INPUT
    , customer_site_id                   NUMBER           --INPUT
    --END of source list

    , target_ccid                        NUMBER(15)       --OUTPUT
    , concatenated_segments              VARCHAR2(2000)   --OUTPUT
    , msg_count                          NUMBER           --OUTPUT
    , msg_data                           VARCHAR2(2000)   --OUTPUT
   );

   --
   -- Public table types
   --
   TYPE t_array_gmf_xla_tab_PUR
      IS TABLE OF t_rec_gmf_xla_tab_PUR INDEX BY BINARY_INTEGER;

   TYPE t_array_gmf_xla_tab_CTO
      IS TABLE OF t_rec_gmf_xla_tab_CTO INDEX BY BINARY_INTEGER;


   --
   -- Public variables
   --
   g_gmf_accts_tab_PUR     t_array_gmf_xla_tab_PUR;
   g_gmf_accts_tab_CTO     t_array_gmf_xla_tab_CTO;

   --
   -- Global Variables for other teams to use.
   --
   G_CHARGE_INV_ACCT      VARCHAR2(5)   := 'INV';
   G_CHARGE_EXP_ACCT      VARCHAR2(5)   := 'EXP';
   G_ACCRUAL_ACCT         VARCHAR2(5)   := 'AAP';
   G_VARIANCE_PPV_ACCT    VARCHAR2(5)   := 'PPV';

END GMF_transaction_accounts_PUB;

 

/
