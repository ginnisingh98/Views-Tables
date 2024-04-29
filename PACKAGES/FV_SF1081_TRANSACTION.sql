--------------------------------------------------------
--  DDL for Package FV_SF1081_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_SF1081_TRANSACTION" AUTHID CURRENT_USER AS
-- $Header: FVX1081S.pls 120.2 2002/11/11 20:06:59 ksriniva ship $

PROCEDURE a000_load_table
	  (error_code 	          OUT NOCOPY  NUMBER,
	  error_message	          OUT NOCOPY  VARCHAR2,
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
	  alc			  IN   VARCHAR2,
	  prepared_by		  IN   VARCHAR2,
	  approved_by		  IN   VARCHAR2,
	  telephone_number_1	  IN   VARCHAR2,
	  telephone_number_2	  IN   VARCHAR2,
          open_invoices_only      IN   VARCHAR2,
	  print_choice		  IN   VARCHAR2,
          details_of_charges      IN   VARCHAR2);
End FV_SF1081_TRANSACTION;

 

/
