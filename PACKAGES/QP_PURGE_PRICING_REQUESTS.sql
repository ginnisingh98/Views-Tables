--------------------------------------------------------
--  DDL for Package QP_PURGE_PRICING_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PURGE_PRICING_REQUESTS" AUTHID CURRENT_USER AS
/* $Header: QPXDLDBS.pls 120.1 2005/06/09 23:54:29 appldev  $ */

  PROCEDURE Purge
  (err_buff                out NOCOPY /* file.sql.39 change */ VARCHAR2,
   retcode                 out NOCOPY /* file.sql.39 change */ NUMBER,
   x_no_of_days            in  NUMBER,
   x_request_name          in  VARCHAR2);

END QP_PURGE_PRICING_REQUESTS;

 

/
