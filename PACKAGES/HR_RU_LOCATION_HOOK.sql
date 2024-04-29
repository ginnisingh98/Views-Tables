--------------------------------------------------------
--  DDL for Package HR_RU_LOCATION_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RU_LOCATION_HOOK" AUTHID CURRENT_USER AS
/* $Header: perulocp.pkh 120.0.12000000.1 2007/01/22 03:54:54 appldev noship $ */
   PROCEDURE create_ru_location (
      p_style               IN   VARCHAR2,
      p_loc_information13   IN   VARCHAR2,
      p_postal_code         IN   VARCHAR2
   );

   PROCEDURE update_ru_location (
      p_location_id         IN   NUMBER,
      p_style               IN   VARCHAR2,
      p_loc_information13   IN   VARCHAR2,
      p_postal_code         IN   VARCHAR2
   );
END hr_ru_location_hook;

 

/
