--------------------------------------------------------
--  DDL for Package XLE_CONTACT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_CONTACT_GRP" AUTHID CURRENT_USER AS
/* $Header: xleconts.pls 120.0 2005/10/27 14:11:41 bsilveir noship $ */

FUNCTION concat_contact_roles (p_contact_party_id  IN NUMBER,
                               p_le_etb_party_id   IN NUMBER)
RETURN VARCHAR2;


PROCEDURE end_contact_roles (p_contact_party_id  IN     NUMBER,
                             p_le_etb_party_id   IN     NUMBER,
                             p_commit            IN     VARCHAR2 := FND_API.G_FALSE,
		             x_return_status     OUT NOCOPY VARCHAR2,
  		             x_msg_count         OUT NOCOPY NUMBER,
		             x_msg_data          OUT NOCOPY VARCHAR2);

END XLE_CONTACT_GRP;

 

/
