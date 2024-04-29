--------------------------------------------------------
--  DDL for Package ARP_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ADJ_PKG" AUTHID CURRENT_USER AS
/* $Header: ARCIADJS.pls 120.4 2005/10/30 04:14:19 appldev ship $*/
--
PROCEDURE insert_p( p_adj_rec 	IN AR_ADJUSTMENTS%ROWTYPE,
		    p_adj_id      OUT NOCOPY AR_ADJUSTMENTS.ADJUSTMENT_ID%TYPE );
--
PROCEDURE update_p( p_adj_rec 	IN AR_ADJUSTMENTS%ROWTYPE );
--
PROCEDURE delete_p( p_adj_id 	IN AR_ADJUSTMENTS.ADJUSTMENT_ID%TYPE );
--
PROCEDURE lock_p( p_adj_id 	IN AR_ADJUSTMENTS.ADJUSTMENT_ID%TYPE );
--
PROCEDURE fetch_p( p_adj_id IN ar_adjustments.adjustment_id%TYPE,
                   p_adj_rec OUT NOCOPY ar_adjustments%ROWTYPE );
--
END  ARP_ADJ_PKG;
--

 

/
