--------------------------------------------------------
--  DDL for Package HRI_EDW_DIM_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_EDW_DIM_EVENTS" AUTHID CURRENT_USER AS
/* $Header: hriedevt.pkh 120.0 2005/05/29 07:08:19 appldev noship $ */

PROCEDURE add_global( p_user_event_type         IN VARCHAR2
                    , p_threshold_units         IN VARCHAR2
                    , p_global_threshold_value  IN NUMBER
                    , p_global_enabled_flag     IN VARCHAR2);

PROCEDURE set_global( p_user_event_type      IN VARCHAR2
                    , p_value                IN NUMBER );

PROCEDURE enable_global( p_user_event_type      IN VARCHAR2 );

PROCEDURE disable_global( p_user_event_type     IN VARCHAR2 );

PROCEDURE add_event( p_user_event_type      IN VARCHAR2
                   , p_event_code           IN VARCHAR2
                   , p_event_threshold      IN NUMBER );

PROCEDURE drop_event( p_user_event_type      IN VARCHAR2
                    , p_event_code           IN VARCHAR2 );

PROCEDURE load_hrhy_row( p_event_id         IN NUMBER,
                         p_owner            IN VARCHAR2,
                         p_hierarchy        IN VARCHAR2,
                         p_level_number     IN NUMBER,
                         p_event_code       IN VARCHAR2,
                         p_parent_event_id  IN NUMBER,
                         p_reason_type      IN VARCHAR2,
                         p_user_event_type  IN VARCHAR2 );

PROCEDURE load_user_row( p_user_event_type  IN VARCHAR2,
                         p_event_code       IN VARCHAR2,
                         p_owner            IN VARCHAR2,
                         p_threshold_value  IN NUMBER,
                         p_threshold_units  IN VARCHAR2,
                         p_glbl_thr_value   IN NUMBER,
                         p_global_flag      IN VARCHAR2 );

PROCEDURE load_cmbn_row( p_combination_id   IN NUMBER,
                         p_owner            IN VARCHAR2,
                         p_gain_event_id    IN NUMBER,
                         p_loss_event_id    IN NUMBER,
                         p_rec_event_id     IN NUMBER,
                         p_sep_event_id     IN NUMBER,
                         p_reason_type      IN VARCHAR2,
                         p_facts            IN VARCHAR2,
                         p_description      IN VARCHAR2 );

END hri_edw_dim_events;

 

/
