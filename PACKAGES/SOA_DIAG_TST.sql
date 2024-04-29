--------------------------------------------------------
--  DDL for Package SOA_DIAG_TST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SOA_DIAG_TST" AUTHID CURRENT_USER AS
/* $Header: SOADIAGTSTS.pls 120.0.12010000.3 2009/09/01 21:16:38 akemiset noship $ */
/*#
 * This is SOA Health Check Diagnostics Test Package.
 * @rep:scope public
 * @rep:product IZU
 * @rep:displayname SOA Health Check Test Package
 * @rep:category BUSINESS_ENTITY SOA_DIAGNOSTICS
 * @rep:lifecycle active
 * @rep:compatibility S
 */

/*#
 * Returns a number.
 * @param arg1 varchar2 varchar argument
 * @param arg2 integer integer argument
 * @param arg3 boolean boolean argument
 * @return Dummy Number
 * @rep:displayname Test Function
 * @rep:scope public
 * @rep:lifecycle active
 */
   FUNCTION TestFunction (arg1 varchar2 ,arg2 integer, arg3 boolean) RETURN NUMBER;

   PROCEDURE testFunctionCP(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY NUMBER);

END SOA_DIAG_TST;

/
