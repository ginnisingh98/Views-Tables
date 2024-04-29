--------------------------------------------------------
--  DDL for Package PA_OVERRIDE_AR_INST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_OVERRIDE_AR_INST" AUTHID CURRENT_USER AS
/* $Header: PAPARICS.pls 120.5 2006/07/25 06:34:39 lveerubh noship $ */
/*#
 * This extension enables you to use a third-party receivables system
 * for the majority of your receivables functionality, yet have the ability to import customer data from Oracle Receivables.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname  Receivables Installation Override
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_INVOICE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/


/*#
* This procedure returns an installation mode to the calling program.
* @param p_ar_inst_mode The input installation mode (mode in which Oracle Receivables is installed)
* @rep:paraminfo {@rep:required}
* @param x_ar_inst_mode The output (override) installation mode
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Get Installation Mode
* @rep:compatibility S
*/
      PROCEDURE get_installation_mode
          (  p_ar_inst_mode             IN    VARCHAR2,
             x_ar_inst_mode		OUT   NOCOPY VARCHAR2);

end pa_override_ar_inst;

/
