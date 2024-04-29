--------------------------------------------------------
--  DDL for Package GMPMRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMPMRACT" AUTHID CURRENT_USER AS
/* $Header: GMPMRACS.pls 115.0 2003/03/11 22:12:27 sgidugu noship $ */

PROCEDURE print_mrp_activity
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY  VARCHAR2,
 V_schedule_id      IN NUMBER,
 V_mrp_id           IN NUMBER,
 V_fplanning_class  IN VARCHAR2,
 V_tplanning_class  IN VARCHAR2,
 V_fwhse_code       IN VARCHAR2,
 V_twhse_code       IN VARCHAR2,
 V_fitem_no         IN VARCHAR2,
 V_titem_no         IN VARCHAR2,
 V_fBuyer_Plnr      IN VARCHAR2,
 V_tBuyer_Plnr      IN VARCHAR2,
 V_ftrans_date      IN DATE,
 V_ttrans_date      IN DATE,
 V_whse_security    IN VARCHAR2,
 V_critical_indicator  IN  NUMBER,
 V_printer          IN VARCHAR2,
 V_number_of_copies IN NUMBER,
 V_user_print_style IN VARCHAR2,
 V_run_date         IN DATE,
 V_run_date1        IN DATE,
 V_schedule         IN VARCHAR2,
 V_usr_orgn_code    IN VARCHAR2  );

END GMPMRACT;

 

/
