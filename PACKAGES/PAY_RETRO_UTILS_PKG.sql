--------------------------------------------------------
--  DDL for Package PAY_RETRO_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RETRO_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: pyretutl.pkh 120.2.12010000.1 2008/07/27 23:33:06 appldev ship $ */
--

PROCEDURE get_user(itemtype in varchar2,
                          itemkey in varchar2,
                          actid in number,
                          funcmode in varchar2,
                          resultout out nocopy varchar2);


PROCEDURE is_retropay_scheduled(itemtype in varchar2,
                          itemkey in varchar2,
                          actid in number,
                          funcmode in varchar2,
                          resultout out nocopy varchar2);

-----------------------------
-- PROCEDURES FOR CC
-----------------------------

PROCEDURE cc_reqd(itemtype in varchar2,
                          itemkey in varchar2,
                          actid in number,
                          funcmode in varchar2,
                          resultout out nocopy varchar2);

PROCEDURE cc_perform(itemtype in varchar2,
                          itemkey in varchar2,
                          actid in number,
                          funcmode in varchar2,
                          resultout out nocopy varchar2);

-----------------------------
-- USEFUL UTILS
-----------------------------
/*
Procedure retro_ent_tab_insert(
          p_retro_assignment_id    IN NUMBER
  ,       p_element_entry_id       IN NUMBER
  ,       p_reprocess_date         IN DATE
  ,       p_eff_date               IN DATE);
*/

procedure create_super_retro_asg(p_asg_id           IN NUMBER
                                  ,p_payroll_id       IN NUMBER
                                  ,p_reprocess_date   IN DATE
                                  ,p_retro_asg_id       OUT nocopy NUMBER);
Procedure  maintain_retro_asg(
                   p_asg_id     IN  NUMBER
                  ,p_payroll_id IN  NUMBER
                  ,p_min_date   IN  DATE
                  ,p_eff_date   IN  DATE
                  ,p_retro_asg_id out nocopy NUMBER) ;

FUNCTION  get_retro_component_id(
                   p_element_entry_id in number,
                   p_ef_date in date,
                   p_element_type_id in number,
                   p_asg_id in number default NULL) return number;


end PAY_RETRO_UTILS_PKG;

/
