--------------------------------------------------------
--  DDL for Package Body IES_IH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_IH_PUB" as
/* $Header: iespihb.pls 115.4 2002/12/09 21:13:25 appldev noship $ */
  procedure Open_Interaction
          (p_ies_user_id        IN  NUMBER,
           p_ies_party_id       IN  NUMBER,
           p_ies_handler_id     IN  NUMBER,
           x_ies_return_status  OUT NOCOPY VARCHAR2,
           x_ies_msg_count      OUT NOCOPY NUMBER,
           x_ies_msg_data       OUT NOCOPY VARCHAR2,
           x_ies_interaction_id OUT NOCOPY NUMBER) as

    l_interaction_rec JTF_IH_PUB.interaction_rec_type;

  begin
    --l_interaction_rec.party_id := 10951;
    l_interaction_rec.party_id := p_ies_party_id;

    --l_interaction_rec.handler_id := 519;
    l_interaction_rec.handler_id := p_ies_handler_id;

    --l_interaction_rec.resource_id := 800;

    select resource_id into l_interaction_rec.resource_id
      from jtf_rs_resource_extns
      where user_id = p_ies_user_id;

    --dbms_output.put_line('Resource ID:'||to_char(l_interaction_rec.resource_id));

     JTF_IH_PUB.Open_Interaction(
        p_api_version             => 1.0,
        x_return_status           => x_ies_return_status,
        x_msg_count               => x_ies_msg_count,
        x_msg_data                => x_ies_msg_data,
        p_user_id                 => p_ies_user_id,
        p_interaction_rec         => l_interaction_rec,
        x_interaction_id          => x_ies_interaction_id
        );
  end Open_Interaction;

  procedure Add_Activity
       (p_ies_user_id            IN  NUMBER,
        p_ies_interaction_id     IN  NUMBER,
        p_ies_action_id          IN  NUMBER,
        p_ies_action_item_id     IN  NUMBER,
        p_ies_script_trans_id    IN  NUMBER,
        x_ies_return_status      OUT NOCOPY VARCHAR2,
        x_ies_msg_count          OUT NOCOPY NUMBER,
        x_ies_msg_data           OUT NOCOPY VARCHAR2,
        x_ies_activity_id        OUT NOCOPY NUMBER) as

	l_activity_rec   JTF_IH_PUB.activity_rec_type;

  begin
	l_activity_rec.interaction_id := p_ies_interaction_id;
	l_activity_rec.action_id := p_ies_action_id;
	l_activity_rec.action_item_id := p_ies_action_item_id;
	l_activity_rec.script_trans_id := p_ies_script_trans_id;

     JTF_IH_PUB.Add_Activity(
        p_api_version             => 1.0,
        x_return_status           => x_ies_return_status,
        x_msg_count               => x_ies_msg_count,
        x_msg_data                => x_ies_msg_data,
        p_user_id                 => p_ies_user_id,
	p_activity_rec            => l_activity_rec,
	x_activity_id             => x_ies_activity_id
        );
  end Add_Activity;

  procedure Update_Activity
       (p_ies_user_id        IN  NUMBER,
        p_ies_interaction_id IN  NUMBER,
        p_ies_activity_id    IN  NUMBER,
        p_ies_outcome_id     IN  NUMBER,
        x_ies_return_status  OUT NOCOPY VARCHAR2,
        x_ies_msg_count      OUT NOCOPY NUMBER,
        x_ies_msg_data       OUT NOCOPY VARCHAR2) as

	l_activity_rec   JTF_IH_PUB.activity_rec_type;

  begin
	l_activity_rec.interaction_id := p_ies_interaction_id;
	l_activity_rec.activity_id    := p_ies_activity_id;
	l_activity_rec.outcome_id     := p_ies_outcome_id;

	l_activity_rec.end_date_time  := sysdate;

    JTF_IH_PUB.Update_Activity(
        p_api_version             => 1.0,
        x_return_status           => x_ies_return_status,
        x_msg_count               => x_ies_msg_count,
        x_msg_data                => x_ies_msg_data,
        p_user_id                 => p_ies_user_id,
	p_activity_rec            => l_activity_rec
        );
  end Update_Activity;

  procedure Close_Interaction
       (p_ies_user_id        IN  NUMBER,
        p_ies_interaction_id IN  NUMBER,
        p_ies_outcome_id     IN  NUMBER,
        x_ies_return_status  OUT NOCOPY VARCHAR2,
        x_ies_msg_count      OUT NOCOPY NUMBER,
        x_ies_msg_data       OUT NOCOPY VARCHAR2) as

    l_interaction_rec JTF_IH_PUB.interaction_rec_type;

  begin
    l_interaction_rec.interaction_id := p_ies_interaction_id;
    l_interaction_rec.outcome_id     := p_ies_outcome_id;

     JTF_IH_PUB.Close_Interaction(
        p_api_version             => 1.0,
        x_return_status           => x_ies_return_status,
        x_msg_count               => x_ies_msg_count,
        x_msg_data                => x_ies_msg_data,
        p_user_id                 => p_ies_user_id,
        p_interaction_rec         => l_interaction_rec
        );
  end Close_Interaction;

end IES_IH_PUB;

/
