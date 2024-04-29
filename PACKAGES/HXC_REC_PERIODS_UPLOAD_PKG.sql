--------------------------------------------------------
--  DDL for Package HXC_REC_PERIODS_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_REC_PERIODS_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxchrpupl.pkh 115.3 2002/06/10 00:37:23 pkm ship      $ */

PROCEDURE load_recurring_period_row (
          p_name                IN VARCHAR2
        , p_start_date          IN VARCHAR2
        , p_end_date            IN VARCHAR2
        , p_period_type         IN VARCHAR2
        , p_duration_in_days    IN NUMBER
        , p_owner               IN VARCHAR2
        , p_custom_mode         IN VARCHAR2 );

END hxc_rec_periods_upload_pkg;

 

/
