--------------------------------------------------------
--  DDL for Package AP_WEB_CC_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_CC_UPGRADE_PKG" AUTHID CURRENT_USER AS
/* $Header: apwccups.pls 120.0.12010000.4 2009/12/14 12:47:20 meesubra noship $ */


--
-- Procedure : Upgrade_Cards
-- Purpose   : Successful upgrade for a card signifies encryption of a card number,
-- 	       Cardmember Name, and Expiration Date using Oracle Payments api
--	       and updating with correct reference of card_reference_id in ap_cards_all.

PROCEDURE Upgrade_Cards
  (x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_worker_id   IN NUMBER,
   x_num_workers IN NUMBER,
   x_script_name IN VARCHAR2
  );

--
-- Procedure : Upgrade_Trxns
-- Purpose   : For the cards which were successfully migrated during R12 and PADSS, update
--             ap_credit_card_trxns_all for those card numbers.

PROCEDURE Upgrade_Trxns
  (x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_worker_id   IN NUMBER,
   x_num_workers IN NUMBER,
   x_script_name IN VARCHAR2
  );

--
-- Procedure : Upgrade_Cards_Manager
-- Purpose   : To initiate the Upgrade_Cards in a parallel mode
--

PROCEDURE Upgrade_Cards_Manager
  (x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_num_workers IN NUMBER,
   x_script_name IN VARCHAR2
  );

--
-- Procedure : Upgrade_Trxns_Manager
-- Purpose   : To initiate the Upgrade_Trxns in a parallel mode
--

PROCEDURE Upgrade_Trxns_Manager
  (x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_num_workers IN NUMBER,
   x_script_name IN VARCHAR2
  );


END AP_WEB_CC_UPGRADE_PKG;

/
