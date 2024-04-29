--------------------------------------------------------
--  DDL for Package FND_ADG_EXCEPTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ADG_EXCEPTION" AUTHID CURRENT_USER as
/* $Header: AFDGEXES.pls 120.0.12010000.2 2010/09/17 16:26:48 rsanders noship $ */

/*      fnd_adg_exception
        =================

        This package is part of Active Data Guard [ADG ] support.

	It defines constants for package errors along with methods
	for raising errors.

	Currently all errors are wrapped in ORA-20001. To change this, we
	just need to change this one package.
*/

/*	Error Codes */

  C_UTLERR_INVALID_DB_RELEASE  constant                   number := 10;
  C_UTLERR_REGISTER_LINK_IS_NULL constant                 number := 11;
  C_UTLERR_OWNER_NOT_PUBLIC    constant                   number := 12;
  C_UTLERR_REG_LINK_NOT_FOUND  constant                   number := 13;
  C_UTLERR_STANDBY_OUT_OF_RANGE constant		  number := 14;
  C_UTLERR_LINK_HOST_MISMATCH constant		  	  number := 15;
  C_UTLERR_STDBY_P_LINKS_MATCH constant			  number := 16;
  C_UTLERR_RPC_SYSTEM_ON	constant		  number := 17;
  C_UTLERR_RPC_SYSTEM_OFF	constant		  number := 18;
  C_UTLERR_RPC_ADG_ON		constant		  number := 19;
  C_UTLERR_RPC_ADG_OFF  	constant		  number := 20;
  C_UTLERR_INCONSISTENT_ADGSTATE constant		  number := 21;
  C_UTLERR_DIRECTIVE_MISMATCH	constant		  number := 22;
  C_UTLERR_INVALID_CONNECT_TYPE constant		  number := 23;
  C_UTLERR_STANDBY_NULL		constant		  number := 24;
  C_UTLERR_RPC_SYSTEM_NOT_PREPED constant		  number := 25;
  C_UTLERR_LINKCHK_NULL        constant			  number := 26;
  C_UTLERR_LINKCHK_TNS         constant			  number := 27;
  C_UTLERR_LINKCHK_LOOPBACK    constant			  number := 28;
  C_UTLERR_LINKCHK_BAD_DBID    constant			  number := 29;
  C_UTLERR_LINKCHK_BAD_DB_ROLE constant			  number := 30;
  C_UTLERR_LINKCHK_RPC_IS_CLONE constant		  number := 31;
  C_UTLERR_LINKCHK_BAD_STANDBY  constant 		  number := 32;
  C_UTLERR_RPC_SYSTEM_LINK_BAD  constant		  number := 33;
  C_UTLERR_LINKCHK_BAD_SERVICE  constant		  number := 34;
  C_UTLERR_BAD_DIR_OBJECT	constant		  number := 35;
  C_UTLERR_REG_CM_NOT_DEFINED   constant		  number := 36;
  C_UTLERR_CDATA_EXISTS		constant		  number := 37;
  C_UTLERR_CONNSTR_TOO_LONG	constant		  number := 38;

  C_MGRERR_NOT_STANDBY         constant                   number := 101;
  C_MGRERR_REMOTE_NOT_PRIMARY  constant                   number := 102;
  C_MGRERR_REMOTE_DOESNT_MATCH constant                   number := 103;
  C_MGRERR_REMOTE_RESOLVE      constant                   number := 104;
  C_MGRERR_UNKNOWN_REMOTE_ERROR constant                  number := 105;
  C_MGRERR_FAILED_PREV_SES_CHK constant                   number := 106;
  C_MGRERR_REMOTE_IS_LOOPBACK  constant                   number := 107;
  C_MGRERR_RPC_EXEC_ERROR      constant			  number := 108;

  C_OBJERR_GEN_MISSING_METHOD  constant                   number := 201;
  C_OBJERR_GEN_OVERLOADED      constant                   number := 202;
  C_OBJERR_GEN_INCOMPAT        constant                   number := 203;
  C_OBJERR_UNSUPPORTD_DATA_TY  constant                   number := 204;
  C_OBJERR_UNSUPPORTD_IO_MODE  constant                   number := 205;
  C_OBJERR_COMPILE_ERROR       constant                   number := 206;
  C_OBJERR_COMPILE_NOT_DEFINED constant                   number := 207;
  C_OBJERR_COMPILE_NO_CODE     constant                   number := 208;
  C_OBJERR_USAGE_NOT_VALID     constant			  number := 209;
  C_OBJERR_USAGE_RPC_NOT_VALID constant			  number := 210;
  C_OBJERR_USAGE_NO_DEP        constant                   number := 211;
  C_OBJERR_USAGE_LIST_IS_EMPTY constant			  number := 212;

  C_SUPERR_PROGRAM_ACCESS_CODE constant			  number := 301;
  C_SUPERR_INVALID_CONC_PROGRAM constant		  number := 302;
  C_SUPERR_VALIDATE_PRIMARY	constant		  number := 303;

/*	raise_error
	===========

	This procedure raises given error along with optional
	user defined text.
*/

  procedure raise_error(p_err number,p_errmsg varchar2 default null);

/*	get_error_msg
	=============

	Get error message.
*/

  function get_error_msg(p_err number) return varchar2;

end fnd_adg_exception;

/
