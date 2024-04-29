--------------------------------------------------------
--  DDL for Package PN_NORM_RENORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_NORM_RENORM_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNRENRMS.pls 120.0 2005/05/29 12:21:56 appldev noship $

/* A Record to hold the neccessary attributes of norm items */
TYPE norm_item_rec IS RECORD (
     schedule_id         PN_PAYMENT_SCHEDULES_ALL.payment_schedule_id%TYPE
    ,schedule_date       PN_PAYMENT_SCHEDULES_ALL.schedule_date%TYPE
    ,normalized_amount   PN_PAYMENT_ITEMS_ALL.actual_amount%TYPE
    );

/* Declare a PL/SQL table type of above record */
TYPE norm_item_tbl_type IS TABLE OF norm_item_rec INDEX BY BINARY_INTEGER;

/* Declare a variable of above PL/SQL table type */
g_norm_item_tbl          norm_item_tbl_type;

/* Declare other global variables */
g_pr_rule                PN_LEASES.payment_term_proration_rule%TYPE;
g_new_lea_term_dt        PN_LEASE_DETAILS_ALL.lease_termination_date%TYPE;


/* Main procedure spec for the normalization / renormalization */
PROCEDURE NORMALIZE_RENORMALIZE
          (p_lease_context      IN   VARCHAR2,
           p_lease_id           IN   NUMBER,
           p_term_id            IN   NUMBER,
           p_vendor_id          IN   NUMBER,
           p_cust_id            IN   NUMBER,
           p_vendor_site_id     IN   NUMBER,
           p_cust_site_use_id   IN   NUMBER,
           p_cust_ship_site_id  IN   NUMBER,
           p_sob_id             IN   NUMBER,
           p_curr_code          IN   VARCHAR2,
           p_sch_day            IN   NUMBER,
           p_norm_str_dt        IN   DATE,
           p_norm_end_dt        IN   DATE,
           p_rate               IN   NUMBER,
           p_lease_change_id    IN   NUMBER);

END PN_NORM_RENORM_PKG;

 

/
