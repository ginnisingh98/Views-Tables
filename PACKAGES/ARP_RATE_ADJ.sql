--------------------------------------------------------
--  DDL for Package ARP_RATE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RATE_ADJ" AUTHID CURRENT_USER AS
/* $Header: ARPLRADS.pls 120.1 2002/11/15 02:43:02 anukumar ship $ */

     TYPE NewAdjTyp IS RECORD
          (cash_receipt_id         NUMBER(15),
           new_exchange_date       DATE,
           new_exchange_rate       NUMBER,
           new_exchange_rate_type  VARCHAR2(30),
           gl_date                 DATE,
           created_by              NUMBER,
           creation_date           DATE,
           last_updated_by         NUMBER,
           last_update_date        DATE,
           last_update_login       NUMBER);

     PROCEDURE main(new_crid   IN  NUMBER,
                    new_ed     IN  DATE,
                    new_er     IN  NUMBER,
                    new_ert    IN  VARCHAR2,
                    new_gd     IN  DATE,
                    new_cb     IN NUMBER,
                    new_cd     IN DATE,
                    new_lub    IN NUMBER,
                    new_lud    IN DATE,
                    new_lul    IN NUMBER,
		    touch_hist_and_dist IN BOOLEAN DEFAULT TRUE,
		    crh_id_out OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE);

END arp_rate_adj;

 

/
