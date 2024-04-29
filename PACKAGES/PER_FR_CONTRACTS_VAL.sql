--------------------------------------------------------
--  DDL for Package PER_FR_CONTRACTS_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_CONTRACTS_VAL" AUTHID CURRENT_USER AS
/* $Header: perfrctc.pkh 120.0 2005/05/31 17:52:43 appldev noship $  */
--
PROCEDURE PERSON_CONTRACT_CREATE
        (p_ctr_information_category IN VARCHAR2
        ,p_ctr_information10  IN VARCHAR2
        ,p_ctr_information11  IN VARCHAR2 );
--
PROCEDURE PERSON_CONTRACT_UPDATE
         (p_ctr_information_category IN VARCHAR2
         ,p_ctr_information10  IN VARCHAR2
         ,p_ctr_information11  IN VARCHAR2 );
--

END PER_FR_CONTRACTS_VAL;

 

/
