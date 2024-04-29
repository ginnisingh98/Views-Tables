--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PERSONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PERSONS_PUB" AS
--$Header: igwpperb.pls 120.2 2006/03/08 20:17:42 dsadhukh ship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_PROP_PERSONS_PUB';

   ---------------------------------------------------------------------------

   PROCEDURE Create_Prop_Person
   (
      p_validate_only          IN VARCHAR2,
      p_commit                 IN VARCHAR2,
      p_proposal_number        IN VARCHAR2,
      p_full_name              IN VARCHAR2,
      p_proposal_role_desc     IN VARCHAR2,
      p_key_person_flag        IN VARCHAR2,
      p_person_unit_name       IN VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   ) IS

   BEGIN

     null;

   END Create_Prop_Person;

   ---------------------------------------------------------------------------

END Igw_Prop_Persons_Pub;

/
