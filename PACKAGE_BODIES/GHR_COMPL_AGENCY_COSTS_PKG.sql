--------------------------------------------------------
--  DDL for Package Body GHR_COMPL_AGENCY_COSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPL_AGENCY_COSTS_PKG" AS
/* $Header: ghcstpkg.pkb 120.0 2005/05/29 03:05:17 appldev noship $ */

-- Get Cost Entry Screen Totals
PROCEDURE get_entry_totals (p_complaint_id     IN NUMBER
                           ,p_phase            IN VARCHAR2
                           ,p_stage            IN VARCHAR2
                           ,p_category         IN VARCHAR2
                           ,p_phase_total      OUT NOCOPY NUMBER
                           ,p_stage_total      OUT NOCOPY NUMBER
                           ,p_category_total   OUT NOCOPY NUMBER)
IS

l_phase_total         NUMBER := 0;
l_stage_total         NUMBER := 0;
l_category_total      NUMBER := 0;


CURSOR cur_phase_costs IS
  SELECT cac.amount
  FROM   ghr_compl_agency_costs cac
  WHERE  cac.complaint_id = p_complaint_id
  AND    cac.phase like decode(p_phase,'999','%',p_phase);

CURSOR cur_stage_costs IS
  SELECT cac.amount
  FROM   ghr_compl_agency_costs cac
  WHERE  cac.complaint_id = p_complaint_id
  AND    cac.phase like decode(p_phase,'999','%',p_phase)
  AND    cac.stage like decode(p_stage,'999','%',p_stage);

CURSOR cur_category_costs IS
  SELECT cac.amount
  FROM   ghr_compl_agency_costs cac
  WHERE  cac.complaint_id = p_complaint_id
  AND    cac.phase like decode(p_phase,'999','%',p_phase)
  AND    cac.stage like decode(p_stage,'999','%',p_stage)
  AND    nvl(cac.category,'%') like decode(p_category,'999','%',p_category);

BEGIN
  FOR cur_phase_costs_rec IN cur_phase_costs LOOP
      l_phase_total :=  l_phase_total + nvl(cur_phase_costs_rec.amount,0);
  END LOOP;

  FOR cur_stage_costs_rec IN cur_stage_costs LOOP
      l_stage_total :=  l_stage_total + nvl(cur_stage_costs_rec.amount,0);
  END LOOP;

  FOR cur_category_costs_rec IN cur_category_costs LOOP
      l_category_total :=  l_category_total + nvl(cur_category_costs_rec.amount,0);
  END LOOP;

  p_phase_total := l_phase_total;
  p_stage_total := l_stage_total;
  p_category_total := l_category_total;


EXCEPTION
	WHEN OTHERS THEN
		null;
END get_entry_totals;
--
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
                             ,p_total_benefits_received OUT NOCOPY NUMBER)
 IS


CURSOR cur_agency_costs IS
  SELECT sum(decode(phase,'10',decode(stage,'GHR_US_INFO_INQUIRY_COSTS',amount,0),0)) info_inquiry_info,
         sum(decode(phase,'20',decode(stage,'GHR_US_INFO_INQUIRY_COSTS',amount,0),0)) info_inquiry_pre,
         sum(decode(phase,'30',decode(stage,'GHR_US_INFO_INQUIRY_COSTS',amount,0),0)) info_inquiry_formal,
         sum(decode(phase,'10',decode(stage,'GHR_US_PRE_COMPL_COSTS',amount,0),0)) pre_complaint_info,
         sum(decode(phase,'20',decode(stage,'GHR_US_PRE_COMPL_COSTS',amount,0),0)) pre_complaint_pre,
         sum(decode(phase,'30',decode(stage,'GHR_US_PRE_COMPL_COSTS',amount,0),0)) pre_complaint_formal,
         sum(decode(phase,'10',decode(stage,'GHR_US_FORMAL_COMPL_COSTS',amount,0),0)) formal_info,
         sum(decode(phase,'20',decode(stage,'GHR_US_FORMAL_COMPL_COSTS',amount,0),0)) formal_pre,
         sum(decode(phase,'30',decode(stage,'GHR_US_FORMAL_COMPL_COSTS',amount,0),0)) formal_formal,
         sum(decode(phase,'10',decode(stage,'GHR_US_INVESTIGATION_COSTS',amount,0),0)) investigation_info,
         sum(decode(phase,'20',decode(stage,'GHR_US_INVESTIGATION_COSTS',amount,0),0)) investigation_pre,
         sum(decode(phase,'30',decode(stage,'GHR_US_INVESTIGATION_COSTS',amount,0),0)) investigation_formal,
         sum(decode(phase,'10',decode(stage,'GHR_US_HEARING_COMPL_COSTS',amount,0),0)) hearing_info,
         sum(decode(phase,'20',decode(stage,'GHR_US_HEARING_COMPL_COSTS',amount,0),0)) hearing_pre,
         sum(decode(phase,'30',decode(stage,'GHR_US_HEARING_COMPL_COSTS',amount,0),0)) hearing_formal,
         sum(decode(phase,'10',decode(stage,'GHR_US_FAD_COSTS',amount,0),0)) fad_info,
         sum(decode(phase,'20',decode(stage,'GHR_US_FAD_COSTS',amount,0),0)) fad_pre,
         sum(decode(phase,'30',decode(stage,'GHR_US_FAD_COSTS',amount,0),0)) fad_formal,
         sum(decode(phase,'10',decode(stage,'GHR_US_FAA_COSTS',amount,0),0)) faa_info,
         sum(decode(phase,'20',decode(stage,'GHR_US_FAA_COSTS',amount,0),0)) faa_pre,
         sum(decode(phase,'30',decode(stage,'GHR_US_FAA_COSTS',amount,0),0)) faa_formal,
         sum(decode(phase,'10',decode(stage,'GHR_US_APPELLATE_COSTS',amount,0),0)) appellate_info,
         sum(decode(phase,'20',decode(stage,'GHR_US_APPELLATE_COSTS',amount,0),0)) appellate_pre,
         sum(decode(phase,'30',decode(stage,'GHR_US_APPELLATE_COSTS',amount,0),0)) appellate_formal,
         sum(decode(phase,'10',decode(stage,'GHR_US_CIVIL_ACTION_COSTS',amount,0),0)) civil_action_info,
         sum(decode(phase,'20',decode(stage,'GHR_US_CIVIL_ACTION_COSTS',amount,0),0)) civil_action_pre,
         sum(decode(phase,'30',decode(stage,'GHR_US_CIVIL_ACTION_COSTS',amount,0),0)) civil_action_formal,
         sum(decode(phase,'10',decode(stage,'GHR_US_OTHER_COSTS',amount,0),0)) other_info,
         sum(decode(phase,'20',decode(stage,'GHR_US_OTHER_COSTS',amount,0),0)) other_pre,
         sum(decode(phase,'30',decode(stage,'GHR_US_OTHER_COSTS',amount,0),0)) other_formal,
         sum(decode(phase,'10',decode(stage,'GHR_US_AMENDMENT_COSTS',amount,0),0)) amendment_info,
         sum(decode(phase,'20',decode(stage,'GHR_US_AMENDMENT_COSTS',amount,0),0)) amendment_pre,
         sum(decode(phase,'30',decode(stage,'GHR_US_AMENDMENT_COSTS',amount,0),0)) amendment_formal
  FROM   ghr_compl_agency_costs
  WHERE  complaint_id = p_complaint_id;

CURSOR cur_benefits_received IS
  SELECT nvl(sum(cad.amount),0) amount
  FROM   ghr_compl_ca_details cad, ghr_compl_ca_headers cah
  WHERE  cah.complaint_id = p_complaint_id
  AND    cah.compl_ca_header_id = cad.compl_ca_header_id;

BEGIN
  FOR cur_agency_costs_rec IN cur_agency_costs LOOP
    p_info_inquiry_info     := nvl(cur_agency_costs_rec.info_inquiry_info,0);
    p_info_inquiry_pre      := nvl(cur_agency_costs_rec.info_inquiry_pre,0);
    p_info_inquiry_formal   := nvl(cur_agency_costs_rec.info_inquiry_formal,0);
    p_pre_complaint_info    := nvl(cur_agency_costs_rec.pre_complaint_info,0);
    p_pre_complaint_pre     := nvl(cur_agency_costs_rec.pre_complaint_pre,0);
    p_pre_complaint_formal  := nvl(cur_agency_costs_rec.pre_complaint_formal,0);
    p_formal_info           := nvl(cur_agency_costs_rec.formal_info,0);
    p_formal_pre            := nvl(cur_agency_costs_rec.formal_pre,0);
    p_formal_formal         := nvl(cur_agency_costs_rec.formal_formal,0);
    p_investigation_info    := nvl(cur_agency_costs_rec.investigation_info,0);
    p_investigation_pre     := nvl(cur_agency_costs_rec.investigation_pre,0);
    p_investigation_formal  := nvl(cur_agency_costs_rec.investigation_formal,0);
    p_hearing_info          := nvl(cur_agency_costs_rec.hearing_info,0);
    p_hearing_pre           := nvl(cur_agency_costs_rec.hearing_pre,0);
    p_hearing_formal        := nvl(cur_agency_costs_rec.hearing_formal,0);
    p_fad_info              := nvl(cur_agency_costs_rec.fad_info,0);
    p_fad_pre               := nvl(cur_agency_costs_rec.fad_pre,0);
    p_fad_formal            := nvl(cur_agency_costs_rec.fad_formal,0);
    p_faa_info              := nvl(cur_agency_costs_rec.faa_info,0);
    p_faa_pre               := nvl(cur_agency_costs_rec.faa_pre,0);
    p_faa_formal            := nvl(cur_agency_costs_rec.faa_formal,0);
    p_appellate_info        := nvl(cur_agency_costs_rec.appellate_info,0);
    p_appellate_pre         := nvl(cur_agency_costs_rec.appellate_pre,0);
    p_appellate_formal      := nvl(cur_agency_costs_rec.appellate_formal,0);
    p_civil_action_info     := nvl(cur_agency_costs_rec.civil_action_info,0);
    p_civil_action_pre      := nvl(cur_agency_costs_rec.civil_action_pre,0);
    p_civil_action_formal   := nvl(cur_agency_costs_rec.civil_action_formal,0);
    p_other_info            := nvl(cur_agency_costs_rec.other_info,0);
    p_other_pre             := nvl(cur_agency_costs_rec.other_pre,0);
    p_other_formal          := nvl(cur_agency_costs_rec.other_formal,0);
    p_amendment_info        := nvl(cur_agency_costs_rec.amendment_info,0);
    p_amendment_pre         := nvl(cur_agency_costs_rec.amendment_pre,0);
    p_amendment_formal      := nvl(cur_agency_costs_rec.amendment_formal,0);
  END LOOP;

  FOR cur_benefits_received_rec IN cur_benefits_received LOOP
        p_total_benefits_received  :=   nvl(cur_benefits_received_rec.amount,0);
  END LOOP;


EXCEPTION
	WHEN OTHERS THEN
		null;
END get_summary_totals;


END ghr_compl_agency_costs_pkg;

/
