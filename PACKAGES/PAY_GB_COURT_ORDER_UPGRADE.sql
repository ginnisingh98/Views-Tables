--------------------------------------------------------
--  DDL for Package PAY_GB_COURT_ORDER_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_COURT_ORDER_UPGRADE" AUTHID CURRENT_USER AS
  /* $Header: pygbupgr.pkh 120.0 2005/06/24 07:39:18 appldev noship $ */
  --

PROCEDURE run(errbuf	  OUT NOCOPY	VARCHAR2
             ,retcode	  OUT NOCOPY	NUMBER
	     ,p_bg_id     IN NUMBER
	     ,p_overpaid  IN VARCHAR2
	     ) ;
END pay_gb_court_order_upgrade;

 

/
