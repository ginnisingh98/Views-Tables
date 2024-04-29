--------------------------------------------------------
--  DDL for Package AME_MIGRATION_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_MIGRATION_REPORT" AUTHID CURRENT_USER as
/* $Header: amemigrp.pkh 120.0 2005/07/26 06:03 mbocutt noship $ */
  procedure generateReport(errbuf  out nocopy varchar2,
                           retcode out nocopy number);
end;

 

/
