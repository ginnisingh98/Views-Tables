--------------------------------------------------------
--  DDL for Package ARP_EBS_AUTOINV_PREPROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_EBS_AUTOINV_PREPROC" AUTHID CURRENT_USER AS
/* $Header: AREBSPPS.pls 115.2 2002/11/15 02:30:44 anukumar noship $ */

   PROCEDURE update_trx ( p_request_id     IN     NUMBER,
                          p_func_curr_code IN VARCHAR2,
                          p_error_code     IN OUT NOCOPY NUMBER  );

END ARP_EBS_AUTOINV_PREPROC ;

 

/
