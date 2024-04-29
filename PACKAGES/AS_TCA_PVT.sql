--------------------------------------------------------
--  DDL for Package AS_TCA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_TCA_PVT" AUTHID CURRENT_USER as
/* $Header: asxvtcas.pls 120.1 2005/06/05 22:53:21 appldev  $ */

--
-- NAME
--   AS_TCA_PVT
--
-- HISTORY
--  05/19/00       ACNG     Create
--

-- Procedure to validate the party_id
--
-- Validation:
--    Check if this party is in the HZ_PARTY table
--
-- NOTES:
--
PROCEDURE Validate_party_id (
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_party_id            IN       NUMBER,
          x_return_status       OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
          x_msg_count           OUT NOCOPY /* file.sql.39 change */      NUMBER,
          x_msg_data            OUT NOCOPY /* file.sql.39 change */      VARCHAR2
);

-- Procedure to validate the party__site_id
--
-- Validation:
--    Check if this party is in the HZ_PARTY_SITES table
--
-- NOTES:
--
PROCEDURE Validate_party_site_id (
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_party_id            IN       NUMBER,
          p_party_site_id       IN       NUMBER,
          x_return_status       OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
          x_msg_count           OUT NOCOPY /* file.sql.39 change */      NUMBER,
          x_msg_data            OUT NOCOPY /* file.sql.39 change */      VARCHAR2
);

-- Procedure to validate the contact_point_id
--
-- Validation:
--    Check if this party is in the HZ_CONTACT_POINTS table
--
-- NOTES:
--
PROCEDURE Validate_contact_point_id (
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_party_id            IN       NUMBER,
          p_org_contact_id      IN       NUMBER,
		p_contact_point_id    IN       NUMBER,
          x_return_status       OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
          x_msg_count           OUT NOCOPY /* file.sql.39 change */      NUMBER,
          x_msg_data            OUT NOCOPY /* file.sql.39 change */      VARCHAR2
);

-- Procedure to validate the contact_id
--
-- Validation:
--    Check if this party is in the HZ_ORG_CONTACTS table
--
-- NOTES:
--
PROCEDURE Validate_contact_id (
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_party_id            IN       NUMBER,
		p_contact_id          IN       NUMBER,
          x_return_status       OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
          x_msg_count           OUT NOCOPY /* file.sql.39 change */      NUMBER,
          x_msg_data            OUT NOCOPY /* file.sql.39 change */      VARCHAR2
);

END AS_TCA_PVT;

 

/
