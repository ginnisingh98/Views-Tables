--------------------------------------------------------
--  DDL for Package ARP_GROUP_INV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_GROUP_INV" AUTHID CURRENT_USER AS
/* $Header: ARPMINVS.pls 115.5 2002/11/15 02:44:25 anukumar ship $*/


   PROCEDURE generate ( p_request_id IN NUMBER);

   PROCEDURE validate_data (P_request_id IN NUMBER);

   PROCEDURE update_ps (P_request_id IN NUMBER);

   PROCEDURE validate_group(p_request_id IN NUMBER, o_rows_rejected OUT NOCOPY NUMBER);

END arp_group_inv;

 

/
