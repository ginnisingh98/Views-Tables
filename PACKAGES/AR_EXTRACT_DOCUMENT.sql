--------------------------------------------------------
--  DDL for Package AR_EXTRACT_DOCUMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_EXTRACT_DOCUMENT" AUTHID CURRENT_USER as
/*$Header: AREXTDCS.pls 115.2 2002/11/15 02:33:47 anukumar noship $ */

                       --argument1 --Transaction Class
                       --argument2 --Transaction Type
                       --argument3 --Transaction Number Low
                       --argument4 --Transaction Number High
                       --argument5 --Customer Class
                       --argument6 --Customer
                       --argument7 --Transaction Date Low
                       --argument8 --Transaction Date High

  procedure extract_documents(errbuf    out NOCOPY varchar2,
                              retcode   out NOCOPY varchar2,
                              argument1 in  varchar2,
                              argument2 in  varchar2,
                              argument3 in  varchar2,
                              argument4 in  varchar2,
                              argument5 in  varchar2,
                              argument6 in  varchar2,
                              argument7 in  varchar2,
                              argument8 in  varchar2);
end;

 

/
