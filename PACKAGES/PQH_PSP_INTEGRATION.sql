--------------------------------------------------------
--  DDL for Package PQH_PSP_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PSP_INTEGRATION" AUTHID CURRENT_USER AS
/* $Header: pqhpspkg.pkh 115.3 2002/12/03 00:07:19 rpasapul noship $ */
--
--
TYPE t_assignment_budget_rec IS RECORD
(
 assignment_id     NUMBER(15),
 start_period      DATE,
 end_period        DATE
);
--
TYPE t_assignment_budget_tab IS TABLE OF t_assignment_budget_rec
  INDEX BY BINARY_INTEGER;
--

TYPE t_enc_entity_rec IS RECORD
(
 position_id      NUMBER(15),
 organization_id  NUMBER(15),
 grade_id         NUMBER(15),
 job_id           NUMBER(15),
 start_period     DATE,
 end_period       DATE
);
--
TYPE t_enc_entity_tab IS TABLE OF t_enc_entity_rec
  INDEX BY BINARY_INTEGER;
--

PROCEDURE  relieve_budget_commitments( p_calling_process IN  VARCHAR2,
                                       p_return_status   OUT NOCOPY VARCHAR2) ;
--
--

END PQH_PSP_INTEGRATION;

 

/
