--------------------------------------------------------
--  DDL for Package HRI_OLTP_DISC_TRAINING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_DISC_TRAINING" AUTHID CURRENT_USER AS
/* $Header: hriodtrn.pkh 115.0 2002/08/22 09:22:21 jtitmas noship $ */

FUNCTION get_event_budget_cost(p_event_id      IN NUMBER)
               RETURN NUMBER;

FUNCTION get_event_actual_cost(p_event_id    IN NUMBER)
                   RETURN NUMBER;

FUNCTION get_event_revenue(p_event_id   IN NUMBER)
              RETURN NUMBER;

FUNCTION get_att_int_rev_booking(p_event_id       IN NUMBER,
                                 p_booking_id     IN NUMBER)
               RETURN NUMBER;

FUNCTION get_att_ext_rev_booking(p_event_id     IN NUMBER,
                                 p_booking_id   IN NUMBER)
              RETURN NUMBER;

FUNCTION get_non_att_int_rev_booking(p_event_id     IN NUMBER,
                                     p_booking_id   IN NUMBER)
                 RETURN NUMBER;

FUNCTION get_non_att_ext_rev_booking(p_event_id     IN NUMBER,
                                     p_booking_id   IN NUMBER)
              RETURN NUMBER;

FUNCTION convert_training_duration(p_formula_id              IN NUMBER
                                  ,p_from_duration           IN NUMBER
                                  ,p_from_duration_units     IN VARCHAR2
                                  ,p_to_duration_units       IN VARCHAR2
                                  ,p_activity_version_name   IN VARCHAR2
                                  ,p_event_name              IN VARCHAR2
                                  ,p_session_date            IN DATE)
                  RETURN NUMBER;

END hri_oltp_disc_training;

 

/
