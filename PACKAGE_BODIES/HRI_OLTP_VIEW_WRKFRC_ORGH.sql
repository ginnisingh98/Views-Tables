--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_VIEW_WRKFRC_ORGH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_VIEW_WRKFRC_ORGH" AS
/* $Header: hriovwrkorg.pkb 120.0.12000000.2 2007/04/12 13:22:14 smohapat noship $ */

FUNCTION get_hdc(p_sup_organization_id    IN NUMBER,
                 p_effective_date   IN DATE,
                 p_worker_type      IN VARCHAR2,
                 p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

  CURSOR hdc_csr IS
  SELECT NVL(SUM(wrkfc.headcount_end), 0)
  FROM hri_mds_wrkfc_orgh_c01_ct   wrkfc
  WHERE wrkfc.sup_organztn_fk = p_sup_organization_id
  AND wrkfc.time_month_snp_fk = to_number(to_char(p_effective_date, 'YYYYQMM'))
  AND wrkfc.ptyp_wrktyp_fk = p_worker_type
  AND wrkfc.sup_directs_only_flag = p_directs_only;

  l_hdc    NUMBER;

BEGIN

  OPEN hdc_csr;
  FETCH hdc_csr INTO l_hdc;
  CLOSE hdc_csr;

  RETURN l_hdc;

END get_hdc;

FUNCTION get_fte(p_sup_organization_id    IN NUMBER,
                 p_effective_date   IN DATE,
                 p_worker_type      IN VARCHAR2,
                 p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

  CURSOR fte_csr IS
  SELECT NVL(SUM(wrkfc.fte_end), 0)
  FROM hri_mds_wrkfc_orgh_c01_ct   wrkfc
  WHERE wrkfc.sup_organztn_fk = p_sup_organization_id
  AND wrkfc.time_month_snp_fk = to_char(p_effective_date, 'YYYYQMM')
  AND wrkfc.ptyp_wrktyp_fk = p_worker_type
  AND wrkfc.sup_directs_only_flag = p_directs_only;

  l_fte    NUMBER;

BEGIN

  OPEN fte_csr;
  FETCH fte_csr INTO l_fte;
  CLOSE fte_csr;

  RETURN l_fte;

END get_fte;

FUNCTION get_pasg_cnt(p_sup_organization_id    IN NUMBER,
                      p_effective_date   IN DATE,
                      p_worker_type      IN VARCHAR2,
                      p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

  CURSOR pasg_cnt_csr IS
  SELECT NVL(SUM(wrkfc.count_pasg_end), 0)
  FROM hri_mds_wrkfc_orgh_c01_ct   wrkfc
  WHERE wrkfc.sup_organztn_fk = p_sup_organization_id
  AND wrkfc.time_month_snp_fk = to_char(p_effective_date, 'YYYYQMM')
  AND wrkfc.ptyp_wrktyp_fk = p_worker_type
  AND wrkfc.sup_directs_only_flag = p_directs_only;

  l_pasg_cnt    NUMBER;

BEGIN

  OPEN pasg_cnt_csr;
  FETCH pasg_cnt_csr INTO l_pasg_cnt;
  CLOSE pasg_cnt_csr;

  RETURN l_pasg_cnt;

END get_pasg_cnt;

FUNCTION get_asg_cnt(p_sup_organization_id    IN NUMBER,
                     p_effective_date   IN DATE,
                     p_worker_type      IN VARCHAR2,
                     p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

  CURSOR asg_cnt_csr IS
  SELECT NVL(SUM(wrkfc.count_asg_end), 0)
  FROM hri_mds_wrkfc_orgh_c01_ct   wrkfc
  WHERE wrkfc.sup_organztn_fk = p_sup_organization_id
  AND wrkfc.time_month_snp_fk = to_char(p_effective_date, 'YYYYQMM')
  AND wrkfc.ptyp_wrktyp_fk = p_worker_type
  AND wrkfc.sup_directs_only_flag = p_directs_only;

  l_asg_cnt    NUMBER;

BEGIN

  OPEN asg_cnt_csr;
  FETCH asg_cnt_csr INTO l_asg_cnt;
  CLOSE asg_cnt_csr;

  RETURN l_asg_cnt;

END get_asg_cnt;

FUNCTION get_transfer_info(p_sup_organization_id  IN NUMBER,
                           p_from_date        IN DATE,
                           p_to_date          IN DATE,
                           p_worker_type      IN VARCHAR2,
                           p_directs_only     IN VARCHAR2,
                           p_budget_type      IN VARCHAR2,
                           p_transfer_type    IN VARCHAR2)
         RETURN NUMBER IS

  CURSOR trn_csr IS
  SELECT
    NVL(SUM(wevt.headcount * trn.transfer_in_ind), 0)     hdc_trn_in
   ,NVL(SUM(wevt.headcount * trn.transfer_out_ind), 0)    hdc_trn_out
   ,NVL(SUM(wevt.fte * trn.transfer_in_ind), 0)           fte_trn_in
   ,NVL(SUM(wevt.fte * trn.transfer_out_ind), 0)          fte_trn_out
   ,NVL(SUM(wevt.primary_ind * trn.transfer_in_ind), 0)   pasg_cnt_trn_in
   ,NVL(SUM(wevt.primary_ind * trn.transfer_out_ind), 0)  pasg_cnt_trn_out
   ,NVL(SUM(trn.transfer_in_ind), 0)                      asg_cnt_trn_in
   ,NVL(SUM(trn.transfer_out_ind), 0)                     asg_cnt_trn_out
  FROM
   hri_mdp_orgh_transfers_ct trn
  ,hri_mb_wrkfc_evt_ct       wevt
  WHERE trn.org_sup_organztn_fk = p_sup_organization_id
  AND trn.ptyp_wrktyp_fk = p_worker_type
  AND trn.asg_assgnmnt_fk = wevt.asg_assgnmnt_fk
  AND trn.time_day_evt_fk BETWEEN wevt.time_day_evt_fk
                          AND wevt.time_day_evt_end_fk
  AND (p_directs_only = 'N' OR trn.direct_ind = 1)
  AND trn.time_day_evt_fk BETWEEN p_from_date
                          AND p_to_date;

  l_hdc_trn_in        NUMBER;
  l_hdc_trn_out       NUMBER;
  l_fte_trn_in        NUMBER;
  l_fte_trn_out       NUMBER;
  l_pasg_cnt_trn_in   NUMBER;
  l_pasg_cnt_trn_out  NUMBER;
  l_asg_cnt_trn_in    NUMBER;
  l_asg_cnt_trn_out   NUMBER;

BEGIN

  OPEN trn_csr;
  FETCH trn_csr INTO
    l_hdc_trn_in,
    l_hdc_trn_out,
    l_fte_trn_in,
    l_fte_trn_out,
    l_pasg_cnt_trn_in,
    l_pasg_cnt_trn_out,
    l_asg_cnt_trn_in,
    l_asg_cnt_trn_out;
  CLOSE trn_csr;

  IF (p_budget_type = 'HEADCOUNT' AND p_transfer_type = 'IN') THEN
    RETURN l_hdc_trn_in;
  ELSIF (p_budget_type = 'HEADCOUNT' AND p_transfer_type = 'OUT') THEN
    RETURN l_hdc_trn_out;
  ELSIF (p_budget_type = 'FTE' AND p_transfer_type = 'IN') THEN
    RETURN l_fte_trn_in;
  ELSIF (p_budget_type = 'FTE' AND p_transfer_type = 'OUT') THEN
    RETURN l_fte_trn_out;
  ELSIF (p_budget_type = 'PASG_CNT' AND p_transfer_type = 'IN') THEN
    RETURN l_pasg_cnt_trn_in;
  ELSIF (p_budget_type = 'PASG_CNT' AND p_transfer_type = 'OUT') THEN
    RETURN l_pasg_cnt_trn_out;
  ELSIF (p_budget_type = 'ASG_CNT' AND p_transfer_type = 'IN') THEN
    RETURN l_asg_cnt_trn_in;
  ELSIF (p_budget_type = 'ASG_CNT' AND p_transfer_type = 'OUT') THEN
    RETURN l_asg_cnt_trn_out;
  END IF;

  RETURN to_number(null);

END get_transfer_info;

FUNCTION get_trn_in_hdc(p_sup_organization_id    IN NUMBER,
                        p_from_date        IN DATE,
                        p_to_date          IN DATE,
                        p_worker_type      IN VARCHAR2,
                        p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

BEGIN

  RETURN get_transfer_info
          (p_sup_organization_id => p_sup_organization_id,
           p_from_date     => p_from_date,
           p_to_date       => p_to_date,
           p_worker_type   => p_worker_type,
           p_directs_only  => p_directs_only,
           p_budget_type   => 'HEADCOUNT',
           p_transfer_type => 'IN');

END get_trn_in_hdc;

FUNCTION get_trn_out_hdc(p_sup_organization_id    IN NUMBER,
                         p_from_date        IN DATE,
                         p_to_date          IN DATE,
                         p_worker_type      IN VARCHAR2,
                         p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

BEGIN

  RETURN get_transfer_info
          (p_sup_organization_id => p_sup_organization_id,
           p_from_date     => p_from_date,
           p_to_date       => p_to_date,
           p_worker_type   => p_worker_type,
           p_directs_only  => p_directs_only,
           p_budget_type   => 'HEADCOUNT',
           p_transfer_type => 'OUT');

END get_trn_out_hdc;

FUNCTION get_trn_in_fte(p_sup_organization_id    IN NUMBER,
                        p_from_date        IN DATE,
                        p_to_date          IN DATE,
                        p_worker_type      IN VARCHAR2,
                        p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

BEGIN

  RETURN get_transfer_info
          (p_sup_organization_id => p_sup_organization_id,
           p_from_date     => p_from_date,
           p_to_date       => p_to_date,
           p_worker_type   => p_worker_type,
           p_directs_only  => p_directs_only,
           p_budget_type   => 'FTE',
           p_transfer_type => 'IN');

END get_trn_in_fte;

FUNCTION get_trn_out_fte(p_sup_organization_id    IN NUMBER,
                         p_from_date        IN DATE,
                         p_to_date          IN DATE,
                         p_worker_type      IN VARCHAR2,
                         p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

BEGIN

  RETURN get_transfer_info
          (p_sup_organization_id => p_sup_organization_id,
           p_from_date     => p_from_date,
           p_to_date       => p_to_date,
           p_worker_type   => p_worker_type,
           p_directs_only  => p_directs_only,
           p_budget_type   => 'FTE',
           p_transfer_type => 'OUT');

END get_trn_out_fte;

FUNCTION get_trn_in_pasg_cnt(p_sup_organization_id    IN NUMBER,
                             p_from_date        IN DATE,
                             p_to_date          IN DATE,
                             p_worker_type      IN VARCHAR2,
                             p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

BEGIN

  RETURN get_transfer_info
          (p_sup_organization_id => p_sup_organization_id,
           p_from_date     => p_from_date,
           p_to_date       => p_to_date,
           p_worker_type   => p_worker_type,
           p_directs_only  => p_directs_only,
           p_budget_type   => 'PASG_CNT',
           p_transfer_type => 'IN');

END get_trn_in_pasg_cnt;

FUNCTION get_trn_out_pasg_cnt(p_sup_organization_id    IN NUMBER,
                              p_from_date        IN DATE,
                              p_to_date          IN DATE,
                              p_worker_type      IN VARCHAR2,
                              p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

BEGIN

  RETURN get_transfer_info
          (p_sup_organization_id => p_sup_organization_id,
           p_from_date     => p_from_date,
           p_to_date       => p_to_date,
           p_worker_type   => p_worker_type,
           p_directs_only  => p_directs_only,
           p_budget_type   => 'PASG_CNT',
           p_transfer_type => 'OUT');

END get_trn_out_pasg_cnt;

FUNCTION get_trn_in_asg_cnt(p_sup_organization_id    IN NUMBER,
                            p_from_date        IN DATE,
                            p_to_date          IN DATE,
                            p_worker_type      IN VARCHAR2,
                            p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

BEGIN

  RETURN get_transfer_info
          (p_sup_organization_id => p_sup_organization_id,
           p_from_date     => p_from_date,
           p_to_date       => p_to_date,
           p_worker_type   => p_worker_type,
           p_directs_only  => p_directs_only,
           p_budget_type   => 'ASG_CNT',
           p_transfer_type => 'IN');

END get_trn_in_asg_cnt;

FUNCTION get_trn_out_asg_cnt(p_sup_organization_id    IN NUMBER,
                             p_from_date        IN DATE,
                             p_to_date          IN DATE,
                             p_worker_type      IN VARCHAR2,
                             p_directs_only     IN VARCHAR2)
       RETURN NUMBER IS

BEGIN

  RETURN get_transfer_info
          (p_sup_organization_id => p_sup_organization_id,
           p_from_date     => p_from_date,
           p_to_date       => p_to_date,
           p_worker_type   => p_worker_type,
           p_directs_only  => p_directs_only,
           p_budget_type   => 'ASG_CNT',
           p_transfer_type => 'OUT');

END get_trn_out_asg_cnt;

END HRI_OLTP_VIEW_WRKFRC_ORGH;

/
