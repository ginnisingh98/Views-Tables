--------------------------------------------------------
--  DDL for Package Body PYCOPRGP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYCOPRGP" as
/* $Header: pycoprgp.pkb 115.3 2002/12/09 17:16:06 kkawol noship $ */
--
  procedure group_submission (errbuf out nocopy varchar2,
                                   retcode out nocopy number,
                                   proc_group_id in number,
                                   argument1 in varchar2,
                                   argument2 in varchar2,
                                   argument3 in varchar2,
                                   argument4 in varchar2,
                                   argument5 in varchar2)
  as language java
  name 'oracle.apps.pay.proc.PayRunProcessGroup.conc_submission(java.lang.String[], int[], int, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String)';
end pycoprgp;

/
