--------------------------------------------------------
--  DDL for Package PRP_IH_EMAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PRP_IH_EMAIL_PVT" AUTHID CURRENT_USER AS
/* $Header: PRPVIHES.pls 120.4 2005/11/03 19:03:39 hekkiral ship $ */

PROCEDURE Create_Email_IH
(
  p_api_version                    IN NUMBER,
  p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
  p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_application_id                 IN NUMBER,
  p_party_id                       IN NUMBER,
  p_resource_id                    IN NUMBER,
  p_object_id                      IN NUMBER,
  p_object_type                    IN VARCHAR2,
  p_email_history_id               IN NUMBER,
  p_direction                      IN VARCHAR2,
  p_contact_points_tbl             IN JTF_NUMBER_TABLE,
  p_email_sent_date		   IN DATE,
  x_return_status                  OUT NOCOPY VARCHAR2,
  x_msg_count                      OUT NOCOPY NUMBER,
  x_msg_data                       OUT NOCOPY VARCHAR2
);

END PRP_IH_EMAIL_PVT;

 

/
