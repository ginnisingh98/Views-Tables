--------------------------------------------------------
--  DDL for Package PER_QH_TIMELINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QH_TIMELINE" AUTHID CURRENT_USER as
/* $Header: peqhtmln.pkh 120.0.12010000.1 2008/07/28 05:31:46 appldev ship $ */

type daterec is RECORD
(value VARCHAR2(240)
,start_date VARCHAR2(10)
,end_date VARCHAR2(10));

type datetab is table of daterec
index by binary_integer;

procedure get_dates
(p_field             IN     VARCHAR2
,p_security_mode     IN     VARCHAR2
,p_effective_date    IN     DATE
,p_datetrack_date    IN     DATE
,p_person_id         IN     NUMBER
,p_assignment_id     IN     NUMBER
,p_business_group_id IN     NUMBER
,records                OUT NOCOPY datetab);

procedure get_first_date
(p_field             IN     VARCHAR2
,p_security_mode     IN     VARCHAR2
,p_effective_date    IN     DATE
,p_datetrack_date    IN     DATE
,p_person_id         IN     NUMBER
,p_assignment_id     IN     NUMBER
,p_business_group_id IN     NUMBER

,p_new_date          OUT NOCOPY DATE);

procedure get_previous_date
(p_field             IN     VARCHAR2
,p_security_mode     IN     VARCHAR2
,p_effective_date    IN     DATE
,p_datetrack_date    IN     DATE
,p_person_id         IN     NUMBER
,p_assignment_id     IN     NUMBER
,p_business_group_id IN     NUMBER
,p_new_date          OUT NOCOPY DATE);

procedure get_next_date
(p_field             IN     VARCHAR2
,p_security_mode     IN     VARCHAR2
,p_effective_date    IN     DATE
,p_datetrack_date    IN     DATE
,p_person_id         IN     NUMBER
,p_assignment_id     IN     NUMBER
,p_business_group_id IN     NUMBER
,p_new_date          OUT NOCOPY DATE);

procedure get_last_date
(p_field             IN     VARCHAR2
,p_security_mode     IN     VARCHAR2
,p_effective_date    IN     DATE
,p_datetrack_date    IN     DATE
,p_person_id         IN     NUMBER
,p_assignment_id     IN     NUMBER
,p_business_group_id IN     NUMBER
,p_new_date          OUT NOCOPY DATE);

end per_qh_timeline;

/
