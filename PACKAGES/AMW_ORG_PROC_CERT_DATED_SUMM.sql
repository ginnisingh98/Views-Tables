--------------------------------------------------------
--  DDL for Package AMW_ORG_PROC_CERT_DATED_SUMM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_ORG_PROC_CERT_DATED_SUMM" AUTHID CURRENT_USER as
/* $Header: amwpcers.pls 120.0 2005/07/29 00:36:53 appldev noship $ */


-- ORGANIZATION FUNCTIONs

-- Get number of unmitigated risks given a certification and org within the certification
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
-- If material risks flag is passed, then only material risks are considered.
-- Considers entity risks also.
FUNCTION get_unmit_risk_for_org
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER;


-- Get number of evaluated risks given a certification and org within the certification
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
-- If material risks flag is passed, then only material risks are considered.
-- Considers entity risks also.
FUNCTION get_eval_risk_for_org
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER;

-- Get number of risks given a certification and org within the certification
-- If material risks flag is passed, then only material risks are considered.
-- Considers entity risks also.
FUNCTION get_total_risks_for_org
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER;

-- Get number of evaluated controls given a certification and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_eval_ctrls_for_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER;

-- Get number of controls given a certification and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_total_ctrls_for_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER;

-- Get number of ineffective controls given a certification and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_ineff_ctrls_for_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER;

-- Get number of process given a certification and org within the certification
-- If significant process flag is passed then filter on significant process flag.
FUNCTION get_all_process_in_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_sig_process in VARCHAR2)
RETURN NUMBER;


-- Get number of process certified given a certification and org within the certification
-- If significant process flag is passed then filter on significant process flag.
FUNCTION get_cert_process_in_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_sig_process in VARCHAR2)
RETURN NUMBER;

-- Get number of process certified with issues given a certification and org within the certification
-- If significant process flag is passed then filter on significant process flag.
FUNCTION get_process_cert_issues_in_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_sig_process in VARCHAR2)
RETURN NUMBER;

-----------------------------------------------------------------------------------------------------
-- ORG PROCESS FUNCTIONs

-- Get number of ineffective controls given a certification, process and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_ineff_ctrls_for_org_proc
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER;

-- Get number of evaluated controls given a certification, process and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_eval_ctrls_for_org_proc
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER;

-- Get number of controls given a certification, process and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_total_ctrls_for_org_proc
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER;

-- Get number of risks given a certification, process and org within the certification
-- If material risks flag is passed, then only material risks are considered.
FUNCTION get_total_risks_for_org_proc
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER;


-- Get number of evaluated risks given a certification, process and org within the certification
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
-- If material risks flag is passed, then only material risks are considered.
FUNCTION get_eval_risk_for_org_proc
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER;

-- Get number of unmitigated risks given a certification, org and process within the certification
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
-- If material risks flag is passed, then only material risks are considered.
FUNCTION get_unmit_risk_for_org_proc
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER;

-- Get number of sub orgs associated to the given process within a given org.
FUNCTION get_total_org
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER)
RETURN NUMBER;


-- Get number of sub orgs certified with issues that are associated to the given process and within a given org.
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
FUNCTION get_total_org_cert_issues
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE)
RETURN NUMBER;

-- Get number of sub orgs certified that are associated to the given process and within a given org.
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
FUNCTION get_total_org_cert
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE)
RETURN NUMBER;

-- Get number of sub processes of a process
FUNCTION get_total_sub_process
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER)
RETURN NUMBER;

FUNCTION get_cert_sub_process
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE)
RETURN NUMBER;

FUNCTION get_sub_process_cert_issues
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE)
RETURN NUMBER;

FUNCTION get_ineff_ctrl_prcnt_for_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER;

FUNCTION get_ineff_ctrl_prcnt_org_proc
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER;

FUNCTION get_unmit_risk_prcnt_org_proc
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER;

FUNCTION get_unmit_risk_prcnt_for_org
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER;

END AMW_ORG_PROC_CERT_DATED_SUMM;

 

/
