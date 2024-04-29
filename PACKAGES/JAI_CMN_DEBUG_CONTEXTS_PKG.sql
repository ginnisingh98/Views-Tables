--------------------------------------------------------
--  DDL for Package JAI_CMN_DEBUG_CONTEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_DEBUG_CONTEXTS_PKG" AUTHID CURRENT_USER AS
/*$Header: jai_cmn_dbg_ctx.pls 120.1.12000000.1 2007/07/24 06:55:49 rallamse noship $*/
/***************************************************************************************************
-- #
-- # Change History -


1.   02/02/2007   Bgowrava for bug#5631784. File Version 120.0
									Forward Porting of 11i BUG#4742259 (TCS Enhancement)


********************************************************************************************************/

  type log_rec is record
      (
         row                jai_cmn_debug_contexts%rowtype
        ,registered_name    jai_cmn_debug_contexts.log_context%type
        ,log_file_name      varchar2 (250)
        ,file_handler       binary_integer


      );
  type tab_log_manager_typ
  is
  table of log_rec index by binary_integer;

  detail  constant number  :=  2;
  summary constant number  :=  1;
  off     constant number  :=  0;

  procedure register ( pv_context in  varchar2
                     , pn_reg_id OUT NOCOPY number
                     );
  procedure print  ( pn_reg_id   in number
                   , pv_log_msg  in varchar2
                   , pn_statement_level in number default jai_cmn_debug_contexts_pkg.detail
                   );
  procedure print_stack  ;
  procedure deregister(pn_reg_id in number);

  procedure debug (lv_msg varchar2);

end jai_cmn_debug_contexts_pkg;
 

/
