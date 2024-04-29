--------------------------------------------------------
--  DDL for Package IBY_PMTSCHEMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PMTSCHEMES_PKG" AUTHID CURRENT_USER as
/*$Header: ibypmscs.pls 115.8 2002/11/19 21:32:01 jleybovi ship $*/

/*
** Procedure: checkPmtSchemes.
** Purpose:  get payment scheme id based on scheme name, raise exception
**		if scheme doesn't exist
*/
procedure checkPmtScheme( i_pmtschemename in
			iby_pmtschemes.pmtschemename%type,
                        io_pmtschemeid in out nocopy
			iby_pmtschemes.pmtschemeid%type);


/* Procedure: getPmtSchemeName
** Purpose: return pmt scheme name based on bepid
**	for single entry, whatever in the table
**	for double entry, return 'BOTH' ('SSL' and 'BANKACCOUNT')
*/
procedure getPmtSchemeName(i_bepid in iby_pmtschemes.bepid%type,
		--o_pmtschemename out nocopy iby_pmtschemes.pmtschemename%type);
		o_pmtschemename out nocopy JTF_VARCHAR2_TABLE_100);


/* Procedure: createPmtScheme
** Purpose: replace whatever previous existing pmtscheme with new ones
**	for a given bepid
*/
procedure createPmtScheme(i_bepid in iby_pmtschemes.bepid%type,
		i_pmtschemename in JTF_VARCHAR2_TABLE_100);
		--i_pmtschemename in iby_pmtschemes.pmtschemename%type,
                       --i_pmtschemeid1  in iby_pmtschemes.pmtschemeid%type,
                        --i_pmtschemeid2  in iby_pmtschemes.pmtschemeid%type);

end iby_pmtschemes_pkg;



 

/
