--------------------------------------------------------
--  DDL for Package HRI_DBI_WMV_SEPARATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_DBI_WMV_SEPARATION" AUTHID DEFINER AS
/* $Header: hridbite.pkh 115.7 2003/04/22 13:43:25 jtitmas noship $ */
    --
    -- ***********************************************************************
    -- * The internal identifiers we use to recognise our records in the     *
    -- * global summary table, and other constants we might want to see      *
    -- ***********************************************************************
    object_name           CONSTANT VARCHAR2(30) := 'HRI_DBI_WMV_SEPARATION';
    context_type          CONSTANT VARCHAR2(30) := 'HRI_SUPVSR';
    information_category  CONSTANT VARCHAR2(30) := 'HRI_DBI_WMV_SEPARATION';
    event_group           CONSTANT VARCHAR2(30) := 'HRI_WMV_SEPARATION_EVG';
    loss_event_code       CONSTANT VARCHAR2(30) := 'LOSS_SEP';
    involuntary_code      CONSTANT VARCHAR2(30) := 'SEP_INV';
    voluntary_code        CONSTANT VARCHAR2(30) := 'SEP_VOL';
    direct_report_id      CONSTANT VARCHAR2(30) := '-1';
    eot_char              CONSTANT VARCHAR2(30) := fnd_date.date_to_canonical(hr_general.end_of_time);
    sot_char              CONSTANT VARCHAR2(30) := fnd_date.date_to_canonical(hr_general.start_of_time);
    --
    FUNCTION global_wmt RETURN VARCHAR2;
    --
    --
    -- ***********************************************************************
    -- * Fully refresh all summary data for the Annualized Turnover portlets *
    -- * within the specified time period                                    *
    -- ***********************************************************************
    PROCEDURE full_refresh(
        errbuf          OUT NOCOPY VARCHAR2,
        retcode         OUT NOCOPY NUMBER,
        p_start_date    IN  VARCHAR2,
        p_end_date      IN  VARCHAR2 DEFAULT eot_char
    );
    --
    -- ***********************************************************************
    -- * Refresh the summary data for the Annualized Turnover portlets based *
    -- * on the events that have occurred since we last ran this refresh     *
    -- ***********************************************************************
    PROCEDURE refresh_from_deltas(
        errbuf          OUT NOCOPY VARCHAR2,
        retcode         OUT NOCOPY NUMBER
    );
    --
    -- ***********************************************************************
    -- * Special debug modes; will switch on debugging in the Payroll Events *
    -- * wrapper and generate _A_LOT_ of messages to the concurrent log file *
    -- ***********************************************************************
    PROCEDURE full_refresh_debug(
        errbuf          OUT NOCOPY VARCHAR2,
        retcode         OUT NOCOPY NUMBER,
        p_start_date    IN  VARCHAR2,
        p_end_date      IN  VARCHAR2 DEFAULT eot_char
    );
    --
    PROCEDURE refresh_from_deltas_debug(
        errbuf          OUT NOCOPY VARCHAR2,
        retcode         OUT NOCOPY NUMBER
    );
    --
    PROCEDURE set_debugging(p_on IN BOOLEAN);
    PROCEDURE set_concurrent_logging(p_on IN BOOLEAN);
    --
END hri_dbi_wmv_separation;

 

/
