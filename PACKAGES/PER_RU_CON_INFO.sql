--------------------------------------------------------
--  DDL for Package PER_RU_CON_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RU_CON_INFO" AUTHID CURRENT_USER AS
/* $Header: perucrlp.pkh 120.0.12000000.1 2007/01/22 03:54:27 appldev noship $ */

PROCEDURE CREATE_RU_CON_REL(P_CONTACT_PERSON_ID NUMBER,
                            P_PERSON_ID         NUMBER,
                            P_CONTACT_TYPE      VARCHAR2,
                            P_CONT_INFORMATION1 VARCHAR2);

PROCEDURE UPDATE_RU_CON_REL(P_CONTACT_RELATIONSHIP_ID  NUMBER,
                            P_CONTACT_TYPE             VARCHAR2,
			    p_cont_information1	       VARCHAR2);

END PER_RU_CON_INFO;

 

/
