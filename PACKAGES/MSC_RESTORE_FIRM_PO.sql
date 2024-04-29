--------------------------------------------------------
--  DDL for Package MSC_RESTORE_FIRM_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_RESTORE_FIRM_PO" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCRFPOS.pls 120.1.12010000.1 2008/05/02 19:07:32 appldev ship $ */

  ----- CONSTANTS --------------------------------------------------------

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

   PROCEDURE RESTORE_FIRM_PO (
				errbuf                  OUT NOCOPY VARCHAR2,
                                retcode                 OUT NOCOPY NUMBER,
                                arg_plan_id             IN         NUMBER
				);

END MSC_RESTORE_FIRM_PO;

/
