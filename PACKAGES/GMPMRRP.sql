--------------------------------------------------------
--  DDL for Package GMPMRRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMPMRRP" AUTHID CURRENT_USER AS
/* $Header: GMPMRRPS.pls 115.4 2003/09/05 15:24:35 gmangari noship $ */

PROCEDURE gmp_print_mrp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY  VARCHAR2,
 V_schedule_id      IN NUMBER,
 V_mrp_id           IN NUMBER,
 V_fplanning_class  IN VARCHAR2,
 V_tplanning_class  IN VARCHAR2,
 V_fwhse_code       IN VARCHAR2,
 V_twhse_code       IN VARCHAR2,
 V_forgn_code       IN VARCHAR2,
 V_torgn_code       IN VARCHAR2,
 V_fitem_no         IN VARCHAR2,
 V_titem_no         IN VARCHAR2,
 V_fBuyer_Plnr      IN VARCHAR2,
 V_tBuyer_Plnr      IN VARCHAR2,
 V_whse_security    IN VARCHAR2,
 V_printer          IN VARCHAR2,
 V_number_of_copies IN NUMBER,
 V_user_print_style IN VARCHAR2,
 V_run_date         IN VARCHAR2,  --BUG#3125285
 V_run_date1        IN VARCHAR2,  --BUG#3125285
 V_schedule         IN VARCHAR2,
 V_usr_orgn_code    IN VARCHAR2  );

END GMPMRRP;

 

/
