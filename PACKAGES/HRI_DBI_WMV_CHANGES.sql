--------------------------------------------------------
--  DDL for Package HRI_DBI_WMV_CHANGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_DBI_WMV_CHANGES" AUTHID CURRENT_USER AS
/* $Header: hriwvch.pkh 120.0 2005/05/29 06:57:10 appldev noship $ */
--
-- Total Gain function returns total workforce gain by a supervisor
-- in a reporting period
--
FUNCTION calc_total_gain(p_supervisor_id        IN NUMBER
                        ,p_effective_start_date IN DATE
                        ,p_effective_end_date   IN DATE) RETURN NUMBER;
--
-- Total Gain function returns total workforce gain by a supervisor
-- in a reporting period
--
FUNCTION calc_total_gain_hire(p_supervisor_id        IN NUMBER
                             ,p_effective_start_date IN DATE
                             ,p_effective_end_date   IN DATE) RETURN NUMBER;
--
-- Total Gain function returns total workforce gain by a supervisor
-- in a reporting period
--
FUNCTION calc_total_gain_transfer(p_supervisor_id        IN NUMBER
                                 ,p_effective_start_date IN DATE
                                 ,p_effective_end_date   IN DATE) RETURN NUMBER;
--
-- Total Loss function returns total workforce loss by a supervisor
-- in a reporting period
--
FUNCTION calc_total_loss(p_supervisor_id        IN NUMBER
                        ,p_effective_start_date IN DATE
                        ,p_effective_end_date   IN DATE) RETURN NUMBER;
--
-- Total Loss function returns total workforce loss by a supervisor
-- in a reporting period
--
FUNCTION calc_total_loss_term(p_supervisor_id        IN NUMBER
                             ,p_effective_start_date IN DATE
                             ,p_effective_end_date   IN DATE) RETURN NUMBER;

FUNCTION calc_total_loss_term_vol(p_supervisor_id        IN NUMBER
                                 ,p_effective_start_date IN DATE
                                 ,p_effective_end_date   IN DATE)
           RETURN NUMBER;

FUNCTION calc_total_loss_term_invol(p_supervisor_id        IN NUMBER
                                   ,p_effective_start_date IN DATE
                                   ,p_effective_end_date   IN DATE)
           RETURN NUMBER;
--
-- Total Loss function returns total workforce loss by a supervisor
-- in a reporting period
--
FUNCTION calc_total_loss_transfer(p_supervisor_id        IN NUMBER
                                 ,p_effective_start_date IN DATE
                                 ,p_effective_end_date   IN DATE) RETURN NUMBER;
--
-- Total Net function returns total workforce gain-loss by a supervisor
-- in a reporting period
--
FUNCTION calc_total_net(p_supervisor_id        IN NUMBER
                       ,p_effective_start_date IN DATE
                       ,p_effective_end_date   IN DATE) RETURN NUMBER;
--
-- Full refresh procedure deletes and collects all data
--
PROCEDURE full_refresh(errbuf  OUT NOCOPY VARCHAR2
                      ,retcode OUT NOCOPY VARCHAR2);
--
-- Refresh from deltas procedure collects data incrementally
--
PROCEDURE refresh_from_deltas(errbuf  OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2);

PROCEDURE refresh_from_deltas(errbuf        OUT NOCOPY VARCHAR2
                             ,retcode       OUT NOCOPY VARCHAR2
                             ,p_start_date  IN VARCHAR2
                             ,p_end_date    IN VARCHAR2);
    --
END hri_dbi_wmv_changes;

 

/
