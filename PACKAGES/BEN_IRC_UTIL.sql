--------------------------------------------------------
--  DDL for Package BEN_IRC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_IRC_UTIL" 
/* $Header: beircutl.pkh 120.3.12000000.1 2007/01/19 10:52:24 appldev noship $ */
AUTHID CURRENT_USER AS


--
   FUNCTION pay_proposal_rec_change (
      p_pay_proposal_rec_old   IN   per_pay_proposals%ROWTYPE,
      p_pay_proposal_rec_new   IN   per_pay_proposals%ROWTYPE
   )
      RETURN BOOLEAN;

--
   FUNCTION offer_assignment_rec_change (
      p_offer_assignment_rec_old   IN   per_all_assignments_f%ROWTYPE,
      p_offer_assignment_rec_new   IN   per_all_assignments_f%ROWTYPE
   )
      RETURN BOOLEAN;

--
   FUNCTION is_benmngle_for_irec_reqd (
      p_person_id                  IN   NUMBER,
      p_assignment_id              IN   NUMBER,
      p_business_group_id          IN   NUMBER,
      p_effective_date             IN   DATE,
      p_pay_proposal_rec_old       IN   per_pay_proposals%ROWTYPE,
      p_pay_proposal_rec_new       IN   per_pay_proposals%ROWTYPE,
      p_offer_assignment_rec_old   IN   per_all_assignments_f%ROWTYPE,
      p_offer_assignment_rec_new   IN   per_all_assignments_f%ROWTYPE
   )
      RETURN VARCHAR2;

--
   PROCEDURE post_irec_process_update (
      p_person_id           IN   NUMBER,
      p_business_group_id   IN   NUMBER,
      p_assignment_id       IN   NUMBER,
      p_effective_date      IN   DATE
   );

--
   PROCEDURE void_or_restore_life_event (
      p_person_id               IN   NUMBER,
      p_assignment_id           IN   NUMBER,
      p_offer_assignment_id     IN   NUMBER DEFAULT NULL,
      p_void_per_in_ler_id      IN   NUMBER DEFAULT NULL,
      p_restore_per_in_ler_id   IN   NUMBER DEFAULT NULL,
      p_status_cd               IN   VARCHAR2 DEFAULT NULL,
      p_effective_date          IN   DATE
   );
--
END ben_irc_util;

 

/
