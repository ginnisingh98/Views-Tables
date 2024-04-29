--------------------------------------------------------
--  DDL for Package HRI_OPL_WRKFC_TRNSFR_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_WRKFC_TRNSFR_EVENTS" AUTHID CURRENT_USER AS
/* $Header: hriowevttrn.pkh 120.0.12000000.2 2007/04/12 13:24:30 smohapat noship $ */

PROCEDURE initialize_globals;

PROCEDURE delete_transfers_mgrh(p_start_object_id   IN NUMBER,
                                p_end_object_id     IN NUMBER);

PROCEDURE delete_transfers(p_start_object_id   IN NUMBER,
                           p_end_object_id     IN NUMBER);

PROCEDURE bulk_insert_transfers;

PROCEDURE process_mgrh_transfer(p_manager_from_id   IN NUMBER,
                                p_manager_to_id     IN NUMBER,
                                p_transfer_psn_id   IN NUMBER,
                                p_transfer_asg_id   IN NUMBER,
                                p_transfer_wty_fk   IN VARCHAR2,
                                p_transfer_date     IN DATE,
                                p_transfer_hdc      IN NUMBER,
                                p_transfer_fte      IN NUMBER);

PROCEDURE process_orgh_transfer(p_organization_from_id  IN NUMBER,
                                p_organization_to_id    IN NUMBER,
                                p_transfer_psn_id       IN NUMBER,
                                p_transfer_asg_id       IN NUMBER,
                                p_transfer_wty_fk       IN VARCHAR2,
                                p_transfer_date         IN DATE,
                                p_transfer_hdc          IN NUMBER,
                                p_transfer_fte          IN NUMBER);

END hri_opl_wrkfc_trnsfr_events;

 

/
