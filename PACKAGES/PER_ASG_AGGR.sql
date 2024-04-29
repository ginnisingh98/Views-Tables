--------------------------------------------------------
--  DDL for Package PER_ASG_AGGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASG_AGGR" AUTHID CURRENT_USER AS
/* $Header: peaggasg.pkh 120.1.12010000.3 2010/02/23 10:51:59 rlingama ship $ */

FUNCTION assg_aggr_possible (p_person_id IN NUMBER,
                             p_effective_date IN DATE,
                             p_message IN VARCHAR2) RETURN boolean;
PROCEDURE check_aggr_assg(p_person_id IN NUMBER,
                          p_effective_date IN DATE,
                          p_per_information9 IN VARCHAR2,
                          p_per_information10 IN VARCHAR2,
                          p_datetrack_update_mode in VARCHAR2 default null); --Bug 8370225

PROCEDURE set_paye_aggr(p_person_id IN NUMBER,
                          p_effective_date IN DATE,
                          p_assignment_id IN NUMBER,
                          p_payroll_id IN NUMBER);

FUNCTION get_paye_agg_status(p_person_id IN NUMBER,
                          p_effective_date IN DATE,
                          p_assignment_id IN NUMBER,
                          p_payroll_id IN NUMBER) return varchar2;

END per_asg_aggr;

/
