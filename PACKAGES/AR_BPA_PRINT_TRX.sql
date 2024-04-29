--------------------------------------------------------
--  DDL for Package AR_BPA_PRINT_TRX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BPA_PRINT_TRX" AUTHID CURRENT_USER AS
/* $Header: arbpapts.pls 120.0.12010000.2 2008/11/19 15:00:53 vsanka ship $ */
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--  Source control header
--
-- PROGRAM NAME
--   arbpapts.pls
--
-- DESCRIPTION
-- This script creates the package specification of AR_BPA_PRINT_TRX
--
-- USAGE
--   To install        sqlplus <apps_user>/<apps_pwd> @arbpapts.pls
--   To execute        sqlplus <apps_user>/<apps_pwd> AR_BPA_PRINT_TRX.
--
-- PROGRAM LIST        DESCRIPTION
--
-- PRINT_INVOICES      This function is used to print the selected invoices
--
-- DEPENDENCIES
-- None
--
-- CALLED BY
-- BPA Master Program
--
-- LAST UPDATE DATE    08-Jun-2007
-- Date the program has been modified for the last time.
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- --------------------------------------
-- Draft1A 08-Jun-2007 Sandeep Kumar G Initial Version
-- Draft1B 19-Nov-2008 Pavan Kumar     sync up changes
--===========================================================================*/
PROCEDURE PRINT_INVOICES(errbuf               IN OUT NOCOPY VARCHAR2
                        ,retcode              IN OUT NOCOPY VARCHAR2
                        ,p_org_id             IN NUMBER
                        ,p_job_size           IN NUMBER
			,p_template_id        IN NUMBER
                        ,p_choice             IN VARCHAR2
                        ,p_cust_trx_class     IN VARCHAR2
                        ,p_trx_type_id        IN NUMBER
                        ,p_customer_name_low  IN VARCHAR2
                        ,p_customer_name_high IN VARCHAR2
                        ,p_customer_no_low    IN VARCHAR2
                        ,p_customer_no_high   IN VARCHAR2
                        ,p_trx_number_low     IN VARCHAR2
                        ,p_trx_number_high    IN VARCHAR2
                        ,p_doc_number_low     IN VARCHAR2
                        ,p_doc_number_high    IN VARCHAR2
                        ,p_print_date_low_in  IN VARCHAR2
                        ,p_print_date_high_in IN VARCHAR2);

END ar_bpa_print_trx;

/
