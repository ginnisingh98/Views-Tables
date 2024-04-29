--------------------------------------------------------
--  DDL for Package BIS_IMPL_OPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_IMPL_OPT_PKG" AUTHID CURRENT_USER AS
 /*$Header: BISIMPLS.pls 120.3 2005/12/20 10:58:37 tiwang noship $*/
 --PROCEDURE  init_impl; --to be obsolete
 --PROCEDURE  processChange; --to be obsolete
 PROCEDURE  changeimplementation(
    p_object_name varchar2,
    p_impl_flag varchar2);

 PROCEDURE  setImplementationOptions(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2
 );

 PROCEDURE propagateimplementationoptions;

 -- begin: added for bug 3560408
 PROCEDURE setfndformfuncpageimplflag (
    p_func_name                   IN VARCHAR2,
    p_impl_flag                   IN VARCHAR2,
    x_return_status               OUT nocopy VARCHAR2,
    x_msg_data                    OUT nocopy VARCHAR2
 );

 FUNCTION getfndformfuncpageimplflag (
    p_func_name                  IN VARCHAR2
 ) RETURN VARCHAR2;
 -- end: added for bug 3560408

 FUNCTION isPageImplemented (
     p_func_name                  IN VARCHAR2
  ) RETURN VARCHAR2;
  -- end: added for bug 3736131

/** Added for 3999465. but commented for 4422645
function check_top_node(p_object_type in varchar2,p_object_name in varchar2) return varchar2;
procedure set_implflag_reports_in_set(p_set_name in varchar2,p_set_app_id in number);
**/

---added for enhancement 4422645
 PROCEDURE setreportimplflag (
    p_report_name                   IN VARCHAR2,
    p_impl_flag                   IN VARCHAR2,
    x_return_status               OUT nocopy VARCHAR2,
    x_msg_data                    OUT nocopy VARCHAR2
 ) ;

 FUNCTION getreportimplflag (
    p_report_name                  IN VARCHAR2
 ) RETURN VARCHAR2 ;
 ---end added for enhancement 4422645

---this function is for RSG internal use only
function get_impl_flag(p_obj_name in varchar2,p_obj_type in varchar2) return varchar2;

function check_implementation return varchar2;

END BIS_IMPL_OPT_PKG;


 

/
