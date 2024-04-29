--------------------------------------------------------
--  DDL for Package IGS_AD_CANCEL_RECONSIDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_CANCEL_RECONSIDER" AUTHID CURRENT_USER AS
/* $Header: IGSADC9S.pls 120.3 2005/10/07 06:57:18 appldev ship $ */

g_cancel_recons_on VARCHAR2(1);

PROCEDURE cancel_reconsider_appl (
        Errbuf OUT NOCOPY VARCHAR2,
        Retcode OUT NOCOPY NUMBER,
        P_person_id_group IN NUMBER,
        P_calendar_details IN VARCHAR2,
        P_application_type IN VARCHAR2,
        p_recon_no_future IN VARCHAR2,
        p_recon_future IN VARCHAR2,
        p_pend_future IN VARCHAR2);

END igs_ad_cancel_reconsider;

 

/
