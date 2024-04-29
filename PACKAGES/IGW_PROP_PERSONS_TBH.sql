--------------------------------------------------------
--  DDL for Package IGW_PROP_PERSONS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_PERSONS_TBH" AUTHID CURRENT_USER AS
/* $Header: igwtpers.pls 115.4 2002/11/15 00:41:08 ashkumar ship $ */

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid                  OUT NOCOPY VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_person_id              IN NUMBER,
      p_person_party_id        IN NUMBER,
      p_proposal_role_code     IN VARCHAR2,
      p_pi_flag                IN VARCHAR2,
      p_key_person_flag        IN VARCHAR2,
      p_percent_effort         IN NUMBER,
      p_person_organization_id IN NUMBER,
      p_org_party_id           IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      p_mode                   IN  VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Row
   (
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_person_id              IN NUMBER,
      p_person_party_id        IN NUMBER,
      p_proposal_role_code     IN VARCHAR2,
      p_pi_flag                IN VARCHAR2,
      p_key_person_flag        IN VARCHAR2,
      p_percent_effort         IN NUMBER,
      p_person_organization_id IN NUMBER,
      p_org_party_id           IN NUMBER,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      p_mode                   IN  VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Row
   (
      p_rowid                  IN VARCHAR2,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Prop_Persons_Tbh;

 

/
