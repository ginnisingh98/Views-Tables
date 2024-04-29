--------------------------------------------------------
--  DDL for Package HR_RU_ADDRESS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RU_ADDRESS_HOOK" AUTHID CURRENT_USER AS
/* $Header: peruaddp.pkh 120.0.12000000.1 2007/01/22 03:54:17 appldev noship $ */
   PROCEDURE create_ru_address (
      p_style               IN   VARCHAR2,
      p_add_information13   IN   VARCHAR2,
      p_postal_code         IN   VARCHAR2
   );

   PROCEDURE update_ru_address (
      p_address_id          IN   NUMBER,
      p_add_information13   IN   VARCHAR2,
      p_postal_code         IN   VARCHAR2
   );

   PROCEDURE update_ru_address_with_style (
      p_style               IN   VARCHAR2,
      p_address_id          IN   NUMBER,
      p_add_information13   IN   VARCHAR2,
      p_postal_code         IN   VARCHAR2
   );
END hr_ru_address_hook;

 

/
