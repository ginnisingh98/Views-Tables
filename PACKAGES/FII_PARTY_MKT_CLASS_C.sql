--------------------------------------------------------
--  DDL for Package FII_PARTY_MKT_CLASS_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PARTY_MKT_CLASS_C" AUTHID CURRENT_USER as
/* $Header: FIIPCLSS.pls 120.2.12000000.1 2007/01/18 18:02:29 appldev ship $ */

procedure load
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2
, p_load_mode in varchar2 DEFAULT 'INCRE');

FUNCTION DEFAULT_LOAD_MODE return varchar2;

end FII_PARTY_MKT_CLASS_C;

 

/
