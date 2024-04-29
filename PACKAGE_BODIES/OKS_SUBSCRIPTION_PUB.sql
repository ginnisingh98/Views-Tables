--------------------------------------------------------
--  DDL for Package Body OKS_SUBSCRIPTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_SUBSCRIPTION_PUB" As
/* $Header: OKSPSUBB.pls 120.0 2005/05/25 18:02:08 appldev noship $*/

  Procedure create_default_schedule
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY Number,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_cle_id        IN  NUMBER,
                 p_intent        IN  VARCHAR2
               ) IS
  Begin
    OKS_SUBSCRIPTION_PVT.create_default_schedule
                            ( p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_cle_id        => p_cle_id,
                              p_intent        => p_intent
                            );
  End create_default_schedule;

  Procedure recreate_schedule
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY Number,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_cle_id        IN  NUMBER,
                 p_intent        IN  VARCHAR2,
                 x_quantity      OUT NOCOPY NUMBER
               ) IS
  Begin
    OKS_SUBSCRIPTION_PVT.recreate_schedule
                            ( p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_cle_id        => p_cle_id,
                              p_intent        => p_intent,
                              x_quantity      => x_quantity
                            );
  End recreate_schedule;

  Procedure recreate_instance
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY Number,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_cle_id        IN  NUMBER,
                 p_custacct_id   IN  NUMBER
               ) IS
  Begin
    OKS_SUBSCRIPTION_PVT.recreate_instance
                            ( p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_cle_id        => p_cle_id,
                              p_custacct_id   => p_custacct_id
                            );
  End recreate_instance;

  Procedure copy_subscription
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY NUMBER,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_source_cle_id IN  NUMBER,
                 p_target_cle_id IN  NUMBER,
                 p_intent        IN  VARCHAR2
              ) IS
  Begin
    OKS_SUBSCRIPTION_PVT.copy_subscription
                            ( p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_source_cle_id => p_source_cle_id,
                              p_target_cle_id => p_target_cle_id,
                              p_intent        => p_intent
                            );
  End copy_subscription;

  Procedure undo_subscription
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY Number,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_cle_id        IN  NUMBER
              ) IS
  Begin
    OKS_SUBSCRIPTION_PVT.undo_subscription
                            ( p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_cle_id        => p_cle_id
                            );
  End undo_subscription;

  Procedure validate_pattern
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY Number,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_instring      IN  VARCHAR2,
                 p_lowval        IN  NUMBER,
                 p_highval       IN  NUMBER,
                 x_outstring     OUT NOCOPY VARCHAR2,
                 x_outtab        OUT NOCOPY rangetab
               ) IS
  Begin
    OKS_SUBSCRIPTION_PVT.validate_pattern
                            ( p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_instring      => p_instring,
                              p_lowval        => p_lowval,
                              p_highval       => p_highval,
                              x_outstring     => x_outstring,
                              x_outtab        => x_outtab
                            );
  End validate_pattern;

  Procedure get_subs_qty
               ( p_cle_id        IN  NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_quantity      OUT NOCOPY NUMBER,
                 x_uom_code      OUT NOCOPY VARCHAR2
               ) IS
  Begin
    OKS_SUBSCRIPTION_PVT.get_subs_qty
                            ( p_cle_id        => p_cle_id,
                              x_return_status => x_return_status,
                              x_quantity      => x_quantity,
                              x_uom_code      => x_uom_code
                            );
  End get_subs_qty;

  Procedure stretch_effectivity
               ( p_start_date    IN  DATE,
                 p_end_date      IN  DATE,
                 p_frequency     IN  VARCHAR2,
                 x_new_start_dt  OUT NOCOPY DATE,
                 x_new_end_dt    OUT NOCOPY DATE
               )IS
  Begin
    OKS_SUBSCRIPTION_PVT.stretch_effectivity
                            ( p_start_date   => p_start_date,
                              p_end_date     => p_end_date,
                              p_frequency    => p_frequency,
                              x_new_start_dt => x_new_start_dt,
                              x_new_end_dt   => x_new_end_dt
                            );
  End stretch_effectivity;

  Function subs_termn_amount
               ( p_cle_id        IN  NUMBER,
                 p_termn_date    IN  DATE
               ) Return NUMBER IS
  Begin
    Return OKS_SUBSCRIPTION_PVT.subs_termn_amount
                            ( p_cle_id     => p_cle_id,
                              p_termn_date => p_termn_date
                            );
  End subs_termn_amount;

  Function is_subs_tangible
               ( p_cle_id        IN  NUMBER
               ) Return BOOLEAN IS
  Begin
    Return OKS_SUBSCRIPTION_PVT.is_subs_tangible
                            ( p_cle_id => p_cle_id
                            );
  End is_subs_tangible;

  Function map_freq_uom
               ( p_frequency     IN  VARCHAR2
               ) Return VARCHAR2 IS
  Begin
    Return OKS_SUBSCRIPTION_PVT.map_freq_uom
                            ( p_frequency => p_frequency
                            );
  End map_freq_uom;

  Procedure db_commit Is
  Begin
    Commit;
  End db_commit;

END OKS_SUBSCRIPTION_PUB;


/
