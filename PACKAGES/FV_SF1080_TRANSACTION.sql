--------------------------------------------------------
--  DDL for Package FV_SF1080_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_SF1080_TRANSACTION" AUTHID CURRENT_USER AS
-- $Header: FVX1080S.pls 120.4 2006/01/18 19:00:47 ksriniva ship $

PROCEDURE a000_load_table
	(error_code 	  OUT NOCOPY  NUMBER,
	error_message	  OUT NOCOPY  VARCHAR2,
          order_by                IN   VARCHAR2,
          batch                   IN   NUMBER,
          transaction_class       IN   VARCHAR2,
          transaction_type        IN   NUMBER,
          trans_num_low           IN   VARCHAR2,
          trans_num_high          IN   VARCHAR2,
          print_date_low          IN   VARCHAR2,
          print_date_high         IN   VARCHAR2,
          cust_profile_class_id   IN   NUMBER,
          customer_class          IN   VARCHAR2,
          customer                IN   VARCHAR2,
          open_invoices_only      IN   VARCHAR2,
          office_charged          IN   VARCHAR2,
	  print_choice		  IN   VARCHAR2);
End fv_sf1080_transaction;

 

/
