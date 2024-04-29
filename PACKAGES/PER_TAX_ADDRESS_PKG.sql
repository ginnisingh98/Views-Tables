--------------------------------------------------------
--  DDL for Package PER_TAX_ADDRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_TAX_ADDRESS_PKG" AUTHID CURRENT_USER AS
/* $Header: peaddovr.pkh 115.4 2003/01/15 00:56:05 ynegoro noship $ */

        PROCEDURE address_overide
         (p_person_id             IN NUMBER
         ,p_date_from             IN DATE
         ,p_overide_city          OUT NOCOPY VARCHAR2
         ,p_overide_county        OUT NOCOPY VARCHAR2
         ,p_overide_state         OUT NOCOPY VARCHAR2
         ,p_overide_zip           OUT NOCOPY VARCHAR2
         );
--
        FUNCTION  overide_tax_state
         (p_person_id NUMBER
         ,p_date_from DATE
         )
         RETURN VARCHAR2;
END per_tax_address_pkg;

 

/
