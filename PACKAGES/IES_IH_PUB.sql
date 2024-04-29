--------------------------------------------------------
--  DDL for Package IES_IH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_IH_PUB" AUTHID CURRENT_USER as
/* $Header: iespihs.pls 115.4 2002/12/09 21:13:23 appldev noship $ */
procedure Open_Interaction
          (p_ies_user_id        IN  NUMBER,
           p_ies_party_id       IN  NUMBER,
           p_ies_handler_id     IN  NUMBER,
           x_ies_return_status  OUT NOCOPY VARCHAR2,
           x_ies_msg_count      OUT NOCOPY NUMBER,
           x_ies_msg_data       OUT NOCOPY VARCHAR2,
           x_ies_interaction_id OUT NOCOPY NUMBER);

procedure Add_Activity
       (p_ies_user_id            IN  NUMBER,
        p_ies_interaction_id     IN  NUMBER,
        p_ies_action_id          IN  NUMBER,
        p_ies_action_item_id     IN  NUMBER,
	p_ies_script_trans_id    IN  NUMBER,
        x_ies_return_status      OUT NOCOPY VARCHAR2,
        x_ies_msg_count          OUT NOCOPY NUMBER,
        x_ies_msg_data           OUT NOCOPY VARCHAR2,
        x_ies_activity_id        OUT NOCOPY NUMBER);

procedure Update_Activity
       (p_ies_user_id        IN  NUMBER,
        p_ies_interaction_id IN  NUMBER,
        p_ies_activity_id    IN  NUMBER,
        p_ies_outcome_id     IN  NUMBER,
        x_ies_return_status  OUT NOCOPY VARCHAR2,
        x_ies_msg_count      OUT NOCOPY NUMBER,
        x_ies_msg_data       OUT NOCOPY VARCHAR2);

procedure Close_Interaction
       (p_ies_user_id        IN  NUMBER,
        p_ies_interaction_id IN  NUMBER,
        p_ies_outcome_id     IN  NUMBER,
        x_ies_return_status  OUT NOCOPY VARCHAR2,
        x_ies_msg_count      OUT NOCOPY NUMBER,
        x_ies_msg_data       OUT NOCOPY VARCHAR2);

end IES_IH_PUB;

 

/
