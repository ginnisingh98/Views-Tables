--------------------------------------------------------
--  DDL for Package FND_OID_BULKLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OID_BULKLOAD" AUTHID CURRENT_USER as
/* $Header: AFSCOBLS.pls 120.2 2007/02/19 07:29:30 bmasa ship $ */
--
/*****************************************************************************/

-- Start of Package Globals

  G_SUCCESS             constant  pls_integer := 1;
  G_FAILURE             constant  pls_integer := 0;
  G_TRUE                constant  pls_integer := 1;
  G_FALSE               constant  pls_integer := 0;

  G_MAIL constant varchar2(4) := 'MAIL';
  G_FACSIMILETELEPHONENUMBER constant varchar2(24) := 'FACSIMILETELEPHONENUMBER';
	G_COM_PROD_ORCLECTX constant varchar2(4000) := 'cn=Common,cn=Products,cn=OracleContext';

  G_INTERNAL            constant varchar2(9) := '#INTERNAL';
  G_LDAP_SYNCH          constant varchar2(10) := 'LDAP_SYNCH';
  G_HOST                constant varchar2(4) := 'HOST';
  G_PORT                constant varchar2(4) := 'PORT';
  G_USERNAME            constant varchar2(8) := 'USERNAME';
  G_EPWD                constant varchar2(4) := 'EPWD';
  G_LDAP_PWD            constant varchar2(8) := 'LDAP_PWD';
  G_DBLDAPAUTHLEVEL     constant varchar2(15) := 'dbldapauthlevel';
  G_DBWALLETDIR         constant varchar2(11) := 'dbwalletdir';
  G_DBWALLETPASS        constant varchar2(12) := 'dbwalletpass';

-- End of Package Globals
--
-------------------------------------------------------------------------------
/*
** Name      : get_oid_session
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
**   p_tca_record - when Y creates a TCA record, when N no TCA record will be created.
*/
procedure import_user(p_ldap_user in fnd_oid_util.ldap_message_type,
		      p_duplicate in varchar2, x_ret_status out nocopy varchar2,		      p_tca_record in varchar2 default 'Y');
--
-------------------------------------------------------------------------------

end fnd_oid_bulkload;

/
