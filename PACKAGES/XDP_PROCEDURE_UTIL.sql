--------------------------------------------------------
--  DDL for Package XDP_PROCEDURE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_PROCEDURE_UTIL" AUTHID CURRENT_USER AS
/* $Header: XDPPUTLS.pls 120.1 2005/06/16 02:27:01 appldev  $ */

  Function Get_Package_Spec(
	p_proc_type IN VARCHAR2) return varchar2;

  PROCEDURE Create_Package_Spec(
	p_proc_name IN VARCHAR2,
	p_proc_type IN VARCHAR2,
	return_code  OUT NOCOPY NUMBER,
	error_string OUT NOCOPY VARCHAR2);

  PROCEDURE Create_Package_Body(
	p_proc_name IN VARCHAR2,
	p_proc_type IN VARCHAR2,
        p_FaID    in NUMBER,
        p_FeTypeID    in NUMBER,
	p_proc_body IN VARCHAR2,
	return_code  OUT NOCOPY NUMBER,
	error_string OUT NOCOPY VARCHAR2);

  PROCEDURE Load_Proc_Table(
	p_proc_name IN VARCHAR2,
	p_proc_type IN VARCHAR2,
	p_proc_body IN VARCHAR2,
	return_code  OUT NOCOPY NUMBER,
	error_string OUT NOCOPY VARCHAR2);

  PROCEDURE Rollback_Proc(
	p_proc_name IN VARCHAR2,
	p_proc_type IN VARCHAR2,
	p_FaID  IN NUMBER,
	p_FeTypeID  IN NUMBER,
	return_code OUT NOCOPY NUMBER,
	error_string OUT NOCOPY VARCHAR2);

  procedure get_package_name(p_proc_name IN VARCHAR2,
                             p_package_name  OUT NOCOPY varchar2,
                             return_code  OUT NOCOPY NUMBER,
                             error_string OUT NOCOPY VARCHAR2);

function decode_proc_name (ProcName in varchar2) return varchar2;

END;

 

/
