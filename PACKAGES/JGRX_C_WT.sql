--------------------------------------------------------
--  DDL for Package JGRX_C_WT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JGRX_C_WT" AUTHID CURRENT_USER AS
/* $Header: jgrxcwts.pls 120.4 2005/06/23 22:21:02 rguerrer ship $ */
/**************************************************************************
 *                    Public Procedures Definition                        *
 **************************************************************************/


/**************************************************************************
 *                                                                        *
 * Name       : get_awt_tax		                                  *
 * Purpose    : This is the wrapper procedure for the Withholding extract *
 *              which will initialize some variables, call the core pkg   *
 *									  *
 **************************************************************************/

PROCEDURE get_awt_tax(
 	errbuf		out NOCOPY VARCHAR2,
	retcode		out NOCOPY VARCHAR2,
	argument1	in VARCHAR2 default null, -- SOB ID
	argument2	in VARCHAR2 default null, -- COA ID
	argument3	in VARCHAR2 default null, -- GL Date From
	argument4	in VARCHAR2 default null, -- GL Date To
	argument5	in VARCHAR2 default null, -- Supplier From
	argument6	in VARCHAR2 default null, -- Supplier To
	argument7	in VARCHAR2 default null, -- Supp Tax Registration No.
	argument8	in VARCHAR2 default null, -- Invoice Number
	argument9	in VARCHAR2 default null, -- Reporting Level
	argument10	in VARCHAR2 default null, -- Reporting Context
	argument11	in VARCHAR2 default null, -- Legal Entity ID
	argument12	in VARCHAR2 default null, -- Accounting Flexfield From
	argument13	in VARCHAR2 default null, -- Accounting Flexfield To
	argument14	in VARCHAR2 default null, -- Organization Type
	argument15	in VARCHAR2 default null, -- Location
	argument16	in VARCHAR2 default null, -- Domestic Income Category
	argument17	in VARCHAR2 default null, -- Foreign Income Category
	argument18	in VARCHAR2 default null, -- Debug Flag
	argument19	in VARCHAR2 default null, -- SQL Trace
      argument20	in VARCHAR2 default null,
	argument21	in VARCHAR2 default null,
	argument22 	in VARCHAR2 default null,
        argument23	in VARCHAR2 default null,
	argument24	in VARCHAR2 default null,
	argument25 	in VARCHAR2 default null,
        argument26	in VARCHAR2 default null,
	argument27	in VARCHAR2 default null,
	argument28 	in VARCHAR2 default null,
        argument29	in VARCHAR2 default null,
	argument30	in VARCHAR2 default null,
	argument31 	in VARCHAR2 default null,
        argument32	in VARCHAR2 default null,
	argument33	in VARCHAR2 default null,
	argument34 	in VARCHAR2 default null,
        argument35	in VARCHAR2 default null,
	argument36	in VARCHAR2 default null,
	argument37 	in VARCHAR2 default null,
        argument38	in VARCHAR2 default null,
	argument39	in VARCHAR2 default null,
	argument40 	in VARCHAR2 default null,
        argument41	in VARCHAR2 default null,
	argument42	in VARCHAR2 default null,
	argument43 	in VARCHAR2 default null,
        argument44	in VARCHAR2 default null,
	argument45	in VARCHAR2 default null,
	argument46 	in VARCHAR2 default null,
        argument47	in VARCHAR2 default null,
	argument48	in VARCHAR2 default null,
	argument49 	in VARCHAR2 default null,
        argument50	in VARCHAR2 default null,
	argument51	in VARCHAR2 default null,
	argument52 	in VARCHAR2 default null,
        argument53	in VARCHAR2 default null,
	argument54	in VARCHAR2 default null,
	argument55	in VARCHAR2 default null,
	argument56 	in VARCHAR2 default null,
        argument57	in VARCHAR2 default null,
	argument58	in VARCHAR2 default null,
	argument59 	in VARCHAR2 default null,
        argument60	in VARCHAR2 default null,
	argument61	in VARCHAR2 default null,
	argument62 	in VARCHAR2 default null,
	argument63 	in VARCHAR2 default null,
        argument64	in VARCHAR2 default null,
	argument65	in VARCHAR2 default null,
	argument66 	in VARCHAR2 default null,
        argument67	in VARCHAR2 default null,
	argument68	in VARCHAR2 default null,
	argument69 	in VARCHAR2 default null,
        argument70	in VARCHAR2 default null,
	argument71	in VARCHAR2 default null,
	argument72 	in VARCHAR2 default null,
        argument73	in VARCHAR2 default null,
	argument74	in VARCHAR2 default null,
	argument75	in VARCHAR2 default null,
	argument76 	in VARCHAR2 default null,
        argument77	in VARCHAR2 default null,
	argument78	in VARCHAR2 default null,
	argument79 	in VARCHAR2 default null,
        argument80	in VARCHAR2 default null,
	argument81	in VARCHAR2 default null,
	argument82 	in VARCHAR2 default null,
	argument83 	in VARCHAR2 default null,
        argument84	in VARCHAR2 default null,
	argument85	in VARCHAR2 default null,
	argument86 	in VARCHAR2 default null,
        argument87	in VARCHAR2 default null,
	argument88	in VARCHAR2 default null,
	argument89 	in VARCHAR2 default null,
        argument90	in VARCHAR2 default null,
	argument91	in VARCHAR2 default null,
	argument92 	in VARCHAR2 default null,
        argument93	in VARCHAR2 default null,
	argument94	in VARCHAR2 default null,
	argument95	in VARCHAR2 default null,
	argument96 	in VARCHAR2 default null,
        argument97	in VARCHAR2 default null,
	argument98	in VARCHAR2 default null,
	argument99 	in VARCHAR2 default null,
        argument100	in VARCHAR2 default null);

END JGRX_C_WT;

 

/
