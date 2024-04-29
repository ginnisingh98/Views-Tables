--------------------------------------------------------
--  DDL for Package PAY_GB_EDI_ROLLBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_EDI_ROLLBACK" AUTHID CURRENT_USER as
/* $Header: pygbedir.pkh 120.0.12010000.1 2008/07/27 22:43:44 appldev ship $ */
--
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +============================================================================
 Name    :PAY_GB_EDI_ROLLBACK
 Purpose :Package to contol rollback process for
          P45, P45(3), P46, P46 Car, P46PENNOT, WNU and P11D

 History
 Date        Name          Version  Bug        Description
 ----------- ------------- -------- ---------- ------------------------------
 15-JUN-2006 K.Thampan     115.0               Created.
============================================================================*/

PROCEDURE edi_rollback(errbuf  out NOCOPY VARCHAR2,
                       retcode out NOCOPY NUMBER,
                       p_type  in  varchar2,
                       p_year  in  number,
                       p_actid in  number);


END PAY_GB_EDI_ROLLBACK;

/
