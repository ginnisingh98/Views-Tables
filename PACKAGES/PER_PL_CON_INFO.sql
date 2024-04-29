--------------------------------------------------------
--  DDL for Package PER_PL_CON_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_CON_INFO" AUTHID CURRENT_USER AS
/* $Header: peplcrlp.pkh 120.0.12000000.1 2007/01/22 01:39:04 appldev noship $ */

PROCEDURE CREATE_PL_CON_REL(P_DATE_START        DATE,
                            P_DATE_END          DATE,
                            P_CONTACT_PERSON_ID NUMBER,
                            P_PERSON_ID         NUMBER,
                            P_CONTACT_TYPE      VARCHAR2,
                            P_DATE_OF_BIRTH     DATE);

PROCEDURE UPDATE_PL_CON_REL(P_CONTACT_RELATIONSHIP_ID  NUMBER,
                            P_DATE_START               DATE,
                            P_DATE_END                 DATE,
                            P_CONTACT_TYPE             VARCHAR2
);

END PER_PL_CON_INFO;

 

/
