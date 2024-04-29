--------------------------------------------------------
--  DDL for Package FND_LDAP_ERRM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LDAP_ERRM" AUTHID CURRENT_USER as
/* $Header: AFSCOLES.pls 120.0.12010000.1 2008/11/21 11:01:05 bmasa noship $ */
--
/*****************************************************************************/

-- Start of Package Globals

  FND_SSO_OID_REG_ERROR varchar2(60) :='FND_SSO_OID_REG_ERROR';
  FND_SSO_LDAP_APPSDN_PWD_EXPIRD varchar2(60) :='FND_SSO_LDAP_APPSDN_PWD_EXPIRD';
  FND_SSO_LDAP_PWD_POLICY_ERR varchar2(60) :='FND_SSO_LDAP_PWD_POLICY_ERR';
  FND_SSO_UNEXP_ERROR varchar2(60) :='FND_SSO_UNEXP_ERROR';

  G_GSL_PWDEXPIRED_EXCP_9000 	varchar2(60) := 'GSL_PWDEXPIRED_EXCP';
  G_GSL_PWDMINLENGTH_EXCP_9003 	varchar2(60) := 'GSL_PWDMINLENGTH_EXCP';
  G_GSL_PWDNUMERIC_EXCP_9004 	varchar2(60) := 'GSL_PWDNUMERIC_EXCP';
  G_GSL_PWDNULL_EXCP_9005 	varchar2(60) := 'GSL_PWDNULL_EXCP';
  G_GSL_PWDINHISTORY_EXCP_9006 	varchar2(60) := 'GSL_PWDINHISTORY_EXCP';
  G_GSL_PWDILLEGALVALUE_EXCP9007 varchar2(60) := 'GSL_PWDILLEGALVALUE_EXCP';
  G_GSL_PWDALPHA_EXCP_9012 	varchar2(60) := 'GSL_PWDALPHA_EXCP';
  G_GSL_PWDSPECIAL_EXCP_9013 	varchar2(60) := 'GSL_PWDSPECIAL_EXCP';
  G_GSL_PWDUPPER_EXCP_9014 	varchar2(60) := 'GSL_PWDUPPER_EXCP';
  G_GSL_PWDMAXCHAR_EXCP_9015 	varchar2(60) := 'GSL_PWDMAXCHAR_EXCP';
  G_GSL_PWDLOWER_EXCP_9016 	varchar2(60) := 'GSL_PWDLOWER_EXCP';
  G_GSL_PWDMINAGE_EXCP_9020 	varchar2(60) := 'GSL_PWDMINAGE_EXCP';

-- End of Package Globals
--
-------------------------------------------------------------------------------
/*
** Name      : translate_ldap_errors
** Type      : Public, FND Internal
** Desc      : This function takes the LDAP error message and translates it
**             to the user friendly format based on the LDAP error code
**             in the error message.
**
** Pre-Reqs  :
** Parameters: in - LDAP exception error message
**             out - user friendly error message which will be displayed
** Returns   : LDAP error code type.
**
** Notes     :
*/
function translate_ldap_errors( errm in out nocopy varchar2) return varchar2;
-------------------------------------------------------------------------------
end fnd_ldap_errm;

/
