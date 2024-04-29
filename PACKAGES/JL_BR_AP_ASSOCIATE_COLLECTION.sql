--------------------------------------------------------
--  DDL for Package JL_BR_AP_ASSOCIATE_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AP_ASSOCIATE_COLLECTION" AUTHID CURRENT_USER as
/* $Header: jlbrpacs.pls 120.1 2002/11/13 22:24:27 thwon ship $ */

PROCEDURE jl_br_ap_associate_coll_doc (
	bank_collection_id_e IN NUMBER,
	association_method_e IN VARCHAR2,
	invoice_id_s IN OUT NOCOPY NUMBER,
	payment_num_s IN OUT NOCOPY NUMBER,
	associate_flag_s IN OUT NOCOPY VARCHAR2 );

PROCEDURE jl_br_ap_associate_trade_note (
	invoice_id_e IN NUMBER,
	payment_num_e IN NUMBER,
	association_method_e IN VARCHAR2,
	bank_collection_id_s IN OUT NOCOPY NUMBER,
	associate_flag_s IN OUT NOCOPY VARCHAR2 );
END JL_BR_AP_ASSOCIATE_COLLECTION;

 

/
