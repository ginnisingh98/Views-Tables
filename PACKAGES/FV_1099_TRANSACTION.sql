--------------------------------------------------------
--  DDL for Package FV_1099_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_1099_TRANSACTION" AUTHID CURRENT_USER AS
--  $Header: FVR1099S.pls 120.4 2006/08/10 08:46:38 ckappaga ship $

    procedure fvr1099p
   (errbuf   	 OUT NOCOPY varchar2,
    retcode	 OUT NOCOPY number,
    v_creditors_tin IN  varchar2,
    v_year	 IN  number,
    v_rec_activity	 IN  number,
    v_include_charges IN varchar2);

END fv_1099_transaction;

 

/
