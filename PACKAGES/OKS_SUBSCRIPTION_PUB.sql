--------------------------------------------------------
--  DDL for Package OKS_SUBSCRIPTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_SUBSCRIPTION_PUB" AUTHID CURRENT_USER As
/* $Header: OKSPSUBS.pls 120.0 2005/05/25 17:44:09 appldev noship $*/

  Subtype rangetab Is OKS_SUBSCRIPTION_PVT.rangetab;

  Procedure create_default_schedule
   ( p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY Number,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_cle_id        IN  NUMBER,
     p_intent        IN  VARCHAR2
   );

  Procedure recreate_schedule
   ( p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY Number,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_cle_id        IN  NUMBER,
     p_intent        IN  VARCHAR2,
     x_quantity      OUT NOCOPY NUMBER
   );

  Procedure recreate_instance
   ( p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY Number,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_cle_id        IN  NUMBER,
	p_custacct_id   IN  NUMBER
   );

  Procedure copy_subscription
   ( p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY Number,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_source_cle_id IN  NUMBER,
     p_target_cle_id IN  NUMBER,
     p_intent        IN  VARCHAR2
  );

  Procedure undo_subscription
   ( p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY Number,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_cle_id        IN  NUMBER
  );

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
   );

  Procedure get_subs_qty
   ( p_cle_id        IN  NUMBER,
     x_return_status OUT NOCOPY VARCHAR2,
     x_quantity      OUT NOCOPY NUMBER,
     x_uom_code      OUT NOCOPY VARCHAR2
   );

  Procedure stretch_effectivity
   ( p_start_date    IN  DATE,
     p_end_date      IN  DATE,
     p_frequency     IN  VARCHAR2,
     x_new_start_dt  OUT NOCOPY DATE,
     x_new_end_dt    OUT NOCOPY DATE
   );

  Function subs_termn_amount
   ( p_cle_id        IN  NUMBER,
     p_termn_date    IN  DATE
   ) Return NUMBER;

  Function is_subs_tangible
   ( p_cle_id        IN  NUMBER
   ) Return BOOLEAN;

  Function map_freq_uom
   ( p_frequency     IN  VARCHAR2
   ) Return VARCHAR2;

  Procedure db_commit;

END OKS_SUBSCRIPTION_PUB;


 

/
