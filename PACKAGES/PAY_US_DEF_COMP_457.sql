--------------------------------------------------------
--  DDL for Package PAY_US_DEF_COMP_457
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_DEF_COMP_457" AUTHID CURRENT_USER as
/* $Header: py457rol.pkh 115.4 2002/12/31 20:54:41 tmehra ship $ */
--+
-- ----------------------------------------------------------------------------+
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------+
-- {Start Of Comments}
--+
-- Description:
--   This procedure finds out all the valid persons that have or should
--   have records for 457.
--+
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--+
-- In Parameters:
--+
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.
--+
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--+
-- Developer Implementation Notes:
--   None.
--+
-- Access Status:
--   Internal Development Use Only.
--+
-- {End Of Comments}
TYPE g_rec_type IS RECORD
  (
      person_id               per_all_assignments_f.person_id%TYPE          ,
      tax_unit_id             NUMBER                                        ,
      full_name               per_all_people_f.full_name%TYPE               ,
      assignment_id           per_assignments_f.assignment_id%TYPE          ,
      element_link_id         pay_element_entries_f.element_link_id%TYPE    ,
      element_name            pay_element_types_f.element_name%TYPE         ,
      business_group_id       per_assignments_f.business_group_id%TYPE      ,
      element_information1    pay_element_types_f.element_information1%TYPE ,
      effective_end_date      VARCHAR2(11)
  );
--+
-- ----------------------------------------------------------------------------+
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------+
--+
g_old_rec  g_rec_type;                            -- Global record definition

PROCEDURE rollover_process
(
    errbuf              OUT NOCOPY VARCHAR2 ,
    retcode             OUT NOCOPY NUMBER   ,
    p_year              IN  NUMBER   ,
    p_gre_id            IN  NUMBER   DEFAULT NULL ,
    p_person_id         IN  NUMBER   DEFAULT NULL  ,
    p_override_mode     IN  VARCHAR2 DEFAULT 'NO'
);
END pay_us_def_comp_457;

 

/
