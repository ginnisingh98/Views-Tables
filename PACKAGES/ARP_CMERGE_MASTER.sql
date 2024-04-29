--------------------------------------------------------
--  DDL for Package ARP_CMERGE_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CMERGE_MASTER" AUTHID CURRENT_USER AS
/* $Header: ARHCMSTS.pls 120.6.12000000.3 2007/10/10 10:39:00 kguggila ship $ */

    PROCEDURE add_request (
              req_id               NUMBER,
              program_name         VARCHAR2 );

    PROCEDURE mark_merge_rows (
              req_id               NUMBER,
              p_process_flag       VARCHAR2,
              p_merge_rule         VARCHAR2 DEFAULT 'OLD',
              p_priority           VARCHAR2 ,    --3897822
              p_number_of_merges   NUMBER );


    PROCEDURE validate_merges (
              req_id               NUMBER,
              p_process_flag       VARCHAR2 DEFAULT 'N' );

    PROCEDURE partiton_merge_data (
              req_id               NUMBER,
              last_set         OUT NOCOPY NUMBER,
              p_process_flag       VARCHAR2 DEFAULT 'N');

    PROCEDURE unpartiton_merge_data (
              req_id               NUMBER,
              last_set         OUT NOCOPY NUMBER,
              set_num              NUMBER );

    PROCEDURE merge_customers (
              req_id               NUMBER,
              set_num              NUMBER,
              process_mode         VARCHAR2,
              status           OUT NOCOPY NUMBER );

    PROCEDURE merge_products (
              req_id               NUMBER,
              set_num              NUMBER,
              process_mode         VARCHAR2,
              status           OUT NOCOPY NUMBER);

    PROCEDURE merge_products (
              req_id               NUMBER,
              set_num              NUMBER,
              process_mode         VARCHAR2,
              status           OUT NOCOPY NUMBER,
              error_text         OUT NOCOPY VARCHAR2 );

    PROCEDURE delete_rows (
              req_id               NUMBER,
              set_num              NUMBER,
              status           OUT NOCOPY NUMBER );

    PROCEDURE done_merge_rows (
              req_id               NUMBER,
              set_num              NUMBER );

    PROCEDURE clear_error_merge_rows (
              req_id               NUMBER );

    PROCEDURE reset_merge_rows (
              req_id               NUMBER,
              set_num              NUMBER,
              p_process_flag       VARCHAR2 DEFAULT 'N');

    PROCEDURE remove_request (
              req_id               NUMBER );

    PROCEDURE veto_delete(req_id            NUMBER,
                          set_num           NUMBER,
                          from_customer_id  NUMBER DEFAULT NULL,
                          veto_reason       VARCHAR2,
              		  part_delete  VARCHAR2 DEFAULT 'N');

   PROCEDURE raise_events(p_req_id NUMBER);  --4230396

   FUNCTION operating_unit RETURN VARCHAR2;  --5528318

END ARP_CMERGE_MASTER;

 

/
