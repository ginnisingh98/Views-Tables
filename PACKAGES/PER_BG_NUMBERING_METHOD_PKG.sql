--------------------------------------------------------
--  DDL for Package PER_BG_NUMBERING_METHOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BG_NUMBERING_METHOD_PKG" AUTHID CURRENT_USER AS
/* $Header: pebgnuma.pkh 115.3 2004/01/30 09:11:39 irgonzal noship $ */

--
PROCEDURE convert_to_auto_gen_method
    (errbuf              OUT nocopy varchar2
    ,retcode             OUT nocopy number
    ,p_business_group_id IN  number
    ,p_person_type       IN  varchar2
    );
--
-- Enables the global sequence to generate automatic person numbers.
--
PROCEDURE convert_to_global_sequence
    (errbuf              OUT nocopy varchar2
    ,retcode             OUT nocopy number
    ,p_person_type       IN  varchar2
    );

--
-- Returns true if Cross-BG person numbering is set to 'Y'
--
FUNCTION Global_person_numbering(p_person_type IN varchar2)
  RETURN BOOLEAN;
--
-- Returns Next person number from global sequence
--
FUNCTION GetGlobalPersonNum(p_person_type IN varchar2)
  RETURN NUMBER;
--
-- Alters global sequence based on last number
--
PROCEDURE SET_GLOBAL_SEQUENCE(p_person_type IN varchar2
                             ,p_last_number IN NUMBER);
--
-- --------------------------------------------------------------------- +
-- Name:    Get_PersonNumber_Formula
-- Purpose: Retrieves the fast formula id defined for person number
--          generation.
-- Returns: formula id is successful, null otherwise.
-- --------------------------------------------------------------------- +
FUNCTION Get_PersonNumber_Formula(p_person_type    varchar2
                                 ,p_effective_date date)
   RETURN number;
--
-- --------------------------------------------------------------------- +
-- Name:    Execute_Get_Person_Number_FF
-- Purpose: Execute fast formula in order to generate next person number.
-- Returns: Next person number
-- --------------------------------------------------------------------- +
FUNCTION EXECUTE_GET_PERSON_NUMBER_FF(
              p_formula_id        number
             ,p_effective_date    date
             ,p_business_group_id number
             ,p_person_type       varchar2
             ,p_legislation_code  varchar2
             ,p_person_id         number
             ,p_person_number     varchar2
             ,p_party_id          number
             ,p_date_of_birth     date
             ,p_start_date         date
             ,p_national_id       per_all_people_f.national_identifier%TYPE)
   RETURN VARCHAR2;
--
END PER_BG_NUMBERING_METHOD_PKG;

 

/
