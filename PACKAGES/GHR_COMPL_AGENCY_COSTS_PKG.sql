--------------------------------------------------------
--  DDL for Package GHR_COMPL_AGENCY_COSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPL_AGENCY_COSTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ghcstpkg.pkh 120.0 2005/05/29 03:05:23 appldev noship $ */

PROCEDURE get_entry_totals (p_complaint_id     IN NUMBER
                           ,p_phase            IN VARCHAR2
                           ,p_stage            IN VARCHAR2
                           ,p_category         IN VARCHAR2
                           ,p_phase_total      OUT NOCOPY NUMBER
                           ,p_stage_total      OUT NOCOPY NUMBER
                           ,p_category_total   OUT NOCOPY NUMBER);

PROCEDURE get_summary_totals (p_complaint_id          IN NUMBER
                             ,p_info_inquiry_info     OUT NOCOPY NUMBER
                             ,p_info_inquiry_pre      OUT NOCOPY NUMBER
                             ,p_info_inquiry_formal   OUT NOCOPY NUMBER
                             ,p_pre_complaint_info    OUT NOCOPY NUMBER
                             ,p_pre_complaint_pre     OUT NOCOPY NUMBER
                             ,p_pre_complaint_formal  OUT NOCOPY NUMBER
                             ,p_formal_info           OUT NOCOPY NUMBER
                             ,p_formal_pre            OUT NOCOPY NUMBER
                             ,p_formal_formal         OUT NOCOPY NUMBER
                             ,p_investigation_info    OUT NOCOPY NUMBER
                             ,p_investigation_pre     OUT NOCOPY NUMBER
                             ,p_investigation_formal  OUT NOCOPY NUMBER
                             ,p_hearing_info          OUT NOCOPY NUMBER
                             ,p_hearing_pre           OUT NOCOPY NUMBER
                             ,p_hearing_formal        OUT NOCOPY NUMBER
                             ,p_fad_info              OUT NOCOPY NUMBER
                             ,p_fad_pre               OUT NOCOPY NUMBER
                             ,p_fad_formal            OUT NOCOPY NUMBER
                             ,p_faa_info              OUT NOCOPY NUMBER
                             ,p_faa_pre               OUT NOCOPY NUMBER
                             ,p_faa_formal            OUT NOCOPY NUMBER
                             ,p_appellate_info        OUT NOCOPY NUMBER
                             ,p_appellate_pre         OUT NOCOPY NUMBER
                             ,p_appellate_formal      OUT NOCOPY NUMBER
                             ,p_civil_action_info     OUT NOCOPY NUMBER
                             ,p_civil_action_pre      OUT NOCOPY NUMBER
                             ,p_civil_action_formal   OUT NOCOPY NUMBER
                             ,p_other_info            OUT NOCOPY NUMBER
                             ,p_other_pre             OUT NOCOPY NUMBER
                             ,p_other_formal          OUT NOCOPY NUMBER
                             ,p_amendment_info        OUT NOCOPY NUMBER
                             ,p_amendment_pre         OUT NOCOPY NUMBER
                             ,p_amendment_formal      OUT NOCOPY NUMBER
                             ,p_total_benefits_received OUT NOCOPY NUMBER);


END ghr_compl_agency_costs_pkg;

 

/
