--------------------------------------------------------
--  DDL for Package HRI_OLTP_VIEW_WRKFRC_ORGH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_VIEW_WRKFRC_ORGH" AUTHID CURRENT_USER AS
/* $Header: hriovwrkorg.pkh 120.0.12000000.2 2007/04/12 13:22:27 smohapat noship $ */

FUNCTION get_hdc(p_sup_organization_id    IN NUMBER,
                 p_effective_date   IN DATE,
                 p_worker_type      IN VARCHAR2,
                 p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

FUNCTION get_fte(p_sup_organization_id    IN NUMBER,
                 p_effective_date   IN DATE,
                 p_worker_type      IN VARCHAR2,
                 p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

FUNCTION get_pasg_cnt(p_sup_organization_id    IN NUMBER,
                      p_effective_date   IN DATE,
                      p_worker_type      IN VARCHAR2,
                      p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

FUNCTION get_asg_cnt(p_sup_organization_id    IN NUMBER,
                     p_effective_date   IN DATE,
                     p_worker_type      IN VARCHAR2,
                     p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

FUNCTION get_trn_in_hdc(p_sup_organization_id    IN NUMBER,
                        p_from_date        IN DATE,
                        p_to_date          IN DATE,
                        p_worker_type      IN VARCHAR2,
                        p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

FUNCTION get_trn_out_hdc(p_sup_organization_id    IN NUMBER,
                         p_from_date        IN DATE,
                         p_to_date          IN DATE,
                         p_worker_type      IN VARCHAR2,
                         p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

FUNCTION get_trn_in_fte(p_sup_organization_id    IN NUMBER,
                        p_from_date        IN DATE,
                        p_to_date          IN DATE,
                        p_worker_type      IN VARCHAR2,
                        p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

FUNCTION get_trn_out_fte(p_sup_organization_id    IN NUMBER,
                         p_from_date        IN DATE,
                         p_to_date          IN DATE,
                         p_worker_type      IN VARCHAR2,
                         p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

FUNCTION get_trn_in_pasg_cnt(p_sup_organization_id    IN NUMBER,
                             p_from_date        IN DATE,
                             p_to_date          IN DATE,
                             p_worker_type      IN VARCHAR2,
                             p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

FUNCTION get_trn_out_pasg_cnt(p_sup_organization_id    IN NUMBER,
                              p_from_date        IN DATE,
                              p_to_date          IN DATE,
                              p_worker_type      IN VARCHAR2,
                              p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

FUNCTION get_trn_in_asg_cnt(p_sup_organization_id    IN NUMBER,
                            p_from_date        IN DATE,
                            p_to_date          IN DATE,
                            p_worker_type      IN VARCHAR2,
                            p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

FUNCTION get_trn_out_asg_cnt(p_sup_organization_id    IN NUMBER,
                             p_from_date        IN DATE,
                             p_to_date          IN DATE,
                             p_worker_type      IN VARCHAR2,
                             p_directs_only     IN VARCHAR2)
       RETURN NUMBER;

END HRI_OLTP_VIEW_WRKFRC_ORGH;

 

/
