--------------------------------------------------------
--  DDL for Package GMF_DATE_FORMATER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_DATE_FORMATER" AUTHID CURRENT_USER as
/* $Header: gmfforms.pls 115.0 99/07/16 04:17:57 porting shi $ */
       procedure FORMAT_DATE (datetoformat  in  date,
                              formattouse   in  varchar2,
                              formateddate  out varchar2,
                              statuscode    out number);
END GMF_DATE_FORMATER;

 

/
