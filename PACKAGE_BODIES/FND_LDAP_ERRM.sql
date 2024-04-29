--------------------------------------------------------
--  DDL for Package Body FND_LDAP_ERRM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LDAP_ERRM" as
/* $Header: AFSCOLEB.pls 120.0.12010000.1 2008/11/21 11:01:27 bmasa noship $ */
--
-- Start of Package Globals

  G_MODULE_SOURCE  constant varchar2(80) := 'fnd.plsql.oid.fnd_ldap_errm.';

-- End of Package Globals
-------------------------------------------------------------------------------
function translate_ldap_errors( errm in out nocopy varchar2) return varchar2
is
	l_module_source   varchar2(256);
	l_err_code   varchar2(256);
        l_tmp_str varchar2(4000);
begin
	l_module_source := G_MODULE_SOURCE || 'translate_ldap_errors: ';

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Error Msg : ' || errm);
 end if;

 if (instr(errm, G_GSL_PWDEXPIRED_EXCP_9000 )>0 ) then
	l_err_code :=  FND_SSO_LDAP_APPSDN_PWD_EXPIRD;
        errm := fnd_preference.get('#INTERNAL', 'LDAP_SYNCH', 'USERNAME');
 elsif (instr(errm, G_GSL_PWDMINLENGTH_EXCP_9003)>0 OR
        instr(errm, G_GSL_PWDNUMERIC_EXCP_9004)>0 OR
        instr(errm, G_GSL_PWDNULL_EXCP_9005)>0 OR
        instr(errm, G_GSL_PWDINHISTORY_EXCP_9006)>0 OR
        instr(errm, G_GSL_PWDILLEGALVALUE_EXCP9007)>0 OR
        instr(errm, G_GSL_PWDALPHA_EXCP_9012)>0 OR
        instr(errm, G_GSL_PWDSPECIAL_EXCP_9013)>0 OR
        instr(errm, G_GSL_PWDUPPER_EXCP_9014)>0 OR
        instr(errm, G_GSL_PWDMAXCHAR_EXCP_9015)>0 OR
        instr(errm, G_GSL_PWDLOWER_EXCP_9016)>0 OR
        instr(errm, G_GSL_PWDMINAGE_EXCP_9020)>0) then
	l_err_code :=  FND_SSO_LDAP_PWD_POLICY_ERR;
        /*
         *  The following if block added for colon(":") is not present
         * for error code 9007 in the LDAP error message. In general this colon
         * should be present after the error code.
         */
        if (INSTR(errm, ':', 1, 6) > 0 ) then
            l_tmp_str := substr (errm,  INSTR(errm, ':', 1, 4), (( INSTR(errm, ':', 1, 6) - INSTR(errm, ':', 1, 4) ) + 1) );
        else
            l_tmp_str := substr (errm,  INSTR(errm, ':', 1, 4), (( INSTR(errm, ':', 1, 5) - INSTR(errm, ':', 1, 4) ) + 1) );
        end if;
        l_tmp_str := substr(errm, ( instr(errm, l_tmp_str) + length(l_tmp_str) ) );
        errm := l_tmp_str;
 else
	l_err_code := FND_SSO_UNEXP_ERROR;
 end if;

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_err_code : ' || l_err_code);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_tmp_str: ' || l_tmp_str);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
 end if;

 return l_err_code;

end translate_ldap_errors;
-------------------------------------------------------------------------------
end fnd_ldap_errm;

/
