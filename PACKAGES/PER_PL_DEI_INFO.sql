--------------------------------------------------------
--  DDL for Package PER_PL_DEI_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_DEI_INFO" AUTHID CURRENT_USER AS
/* $Header: pepldeip.pkh 120.0.12000000.1 2007/01/22 01:39:20 appldev noship $ */

PROCEDURE CREATE_PL_DEI_INFO(P_PERSON_ID                 NUMBER,
                             P_DOCUMENT_TYPE_ID          NUMBER,
                             P_DOCUMENT_NUMBER           VARCHAR2,
                             P_ISSUED_DATE               DATE,
                             P_DATE_FROM                 DATE,
                             P_DATE_TO                   DATE);

PROCEDURE UPDATE_PL_DEI_INFO(P_DOCUMENT_EXTRA_INFO_ID    NUMBER,
                             P_DOCUMENT_TYPE_ID          NUMBER,
                             P_DOCUMENT_NUMBER           VARCHAR2,
                             P_PERSON_ID                 NUMBER,
                             P_DATE_FROM                 DATE,
                             P_DATE_TO                   DATE,
                             P_ISSUED_DATE               DATE);

END PER_PL_DEI_INFO;

 

/
