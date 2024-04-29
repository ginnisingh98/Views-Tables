--------------------------------------------------------
--  DDL for Package PQH_GENERIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GENERIC" AUTHID CURRENT_USER as
/* $Header: pqgnfnb.pkh 120.1 2006/03/09 00:26:24 ghshanka noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< PQH_GENERIC >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Created by : Sanej Nair (SCNair)
--
-- Description:
--    This handles transactions like Positions copy, Jobs update etc.
--
-- Access Status:
--   Internal Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
--  Version Date        Author         Comment
--  -------+-----------+--------------+----------------------------------------
--  115.1  27-Feb-2000 Sanej Nair     Initial Version
--  ==========================================================================
--
-- define global variables
--
v_err               varchar2(4000);
g_context           pqh_copy_entity_txns.context%type;
g_gbl_context       pqh_copy_entity_txns.context%type;
g_calling_mode      varchar2(60)  := 'WORK_FLOW' ;       -- Global Calling Mode
g_result_id         varchar2(20)  ;                      -- Global context result id
g_level             number        ;                      -- Global Level Tracking
g_success           boolean       ;                      -- Global Track Master Success
g_conc_warn_flag    boolean       ;                      -- Global concurrent warning flag
g_txn_id            number        ;                      -- Global Transaction Id
--
-- Define record and table
--
type v_rec_type is record
( column_name   varchar2(255),
  column_type   varchar2(10),
  value         varchar2(2000));

type v_rec_tab is table of v_rec_type
index by binary_integer;
--
-- define global PL/SQL table
--
g_source_pk_table    v_rec_tab;
g_target_pk_table    v_rec_tab;
--
Procedure generic_fn( p_copy_entity_txn_id       in  number ,
                      p_master_required_flag     in  varchar2 default 'Y');
--
Procedure generic_fn( errbuf                    out nocopy  varchar2,
                      retcode                   out nocopy  varchar2 ,
				  argument1                      varchar2 ,
				  argument2                      varchar2 default null ,
				  argument3                      varchar2 default null ,
				  argument4                      varchar2 default null ,
				  argument5                      varchar2 default null ,
				  argument6                      varchar2 default null ,
				  argument7                      varchar2 default null ,
				  argument8                      varchar2 default null ,
				  argument9                      varchar2 default null ,
				  argument10                     varchar2 default null ,
				  argument11                     varchar2 default null ,
				  argument12                     varchar2 default null ,
				  argument13                     varchar2 default null ,
				  argument14                     varchar2 default null ,
				  argument15                     varchar2 default null ,
				  argument16                     varchar2 default null ,
				  argument17                     varchar2 default null ,
				  argument18                     varchar2 default null ,
				  argument19                     varchar2 default null ,
				  argument20                     varchar2 default null ,
				  argument21                     varchar2 default null ,
				  argument22                     varchar2 default null ,
				  argument23                     varchar2 default null ,
				  argument24                     varchar2 default null ,
				  argument25                     varchar2 default null ,
				  argument26                     varchar2 default null ,
				  argument27                     varchar2 default null ,
				  argument28                     varchar2 default null ,
				  argument29                     varchar2 default null ,
				  argument30                     varchar2 default null ,
				  argument31                     varchar2 default null ,
				  argument32                     varchar2 default null ,
				  argument33                     varchar2 default null ,
				  argument34                     varchar2 default null ,
				  argument35                     varchar2 default null ,
				  argument36                     varchar2 default null ,
				  argument37                     varchar2 default null ,
				  argument38                     varchar2 default null ,
				  argument39                     varchar2 default null ,
				  argument40                     varchar2 default null ,
				  argument41                     varchar2 default null ,
				  argument42                     varchar2 default null ,
				  argument43                     varchar2 default null ,
				  argument44                     varchar2 default null ,
				  argument45                     varchar2 default null ,
				  argument46                     varchar2 default null ,
				  argument47                     varchar2 default null ,
				  argument48                     varchar2 default null ,
				  argument49                     varchar2 default null ,
				  argument50                     varchar2 default null ,
				  argument51                     varchar2 default null ,
				  argument52                     varchar2 default null ,
				  argument53                     varchar2 default null ,
				  argument54                     varchar2 default null ,
				  argument55                     varchar2 default null ,
				  argument56                     varchar2 default null ,
				  argument57                     varchar2 default null ,
				  argument58                     varchar2 default null ,
				  argument59                     varchar2 default null ,
				  argument60                     varchar2 default null ,
				  argument61                     varchar2 default null ,
				  argument62                     varchar2 default null ,
				  argument63                     varchar2 default null ,
				  argument64                     varchar2 default null ,
				  argument65                     varchar2 default null ,
				  argument66                     varchar2 default null ,
				  argument67                     varchar2 default null ,
				  argument68                     varchar2 default null ,
				  argument69                     varchar2 default null ,
				  argument70                     varchar2 default null ,
				  argument71                     varchar2 default null ,
				  argument72                     varchar2 default null ,
				  argument73                     varchar2 default null ,
				  argument74                     varchar2 default null ,
				  argument75                     varchar2 default null ,
				  argument76                     varchar2 default null ,
				  argument77                     varchar2 default null ,
				  argument78                     varchar2 default null ,
				  argument79                     varchar2 default null ,
				  argument80                     varchar2 default null ,
				  argument81                     varchar2 default null ,
				  argument82                     varchar2 default null ,
				  argument83                     varchar2 default null ,
				  argument84                     varchar2 default null ,
				  argument85                     varchar2 default null ,
				  argument86                     varchar2 default null ,
				  argument87                     varchar2 default null ,
				  argument88                     varchar2 default null ,
				  argument89                     varchar2 default null ,
				  argument90                     varchar2 default null ,
				  argument91                     varchar2 default null ,
				  argument92                     varchar2 default null ,
				  argument93                     varchar2 default null ,
				  argument94                     varchar2 default null ,
				  argument95                     varchar2 default null ,
				  argument96                     varchar2 default null ,
				  argument97                     varchar2 default null ,
				  argument98                     varchar2 default null ,
				  argument99                     varchar2 default null ,
				  argument100                    varchar2 default null );
--
function generic_fn( p_copy_entity_txn_id       in  number ,
                     p_txn_short_name           in  varchar2 ,
                     p_calling_mode             in  varchar2 ) return number;
--
Procedure process_copy(p_copy_entity_txn_id      in  varchar2 ,
                       p_table_route_id          in  varchar2 ,
                       p_from_clause             in  varchar2 ,
                       p_table_alias             in  varchar2 ,
                       p_where_clause            in  varchar2 ,
                       p_pre_copy_proc           in  varchar2 ,
                       p_copy_proc               in  varchar2 ,
                       p_post_copy_proc          in  varchar2 ,
                       p_validate                in  boolean default false);
--
procedure populate_table;
--
procedure Raise_Error(p_copy_entity_result_id in number,
                      p_msg_code              in varchar2);
--
function assign_part( p_column_name in varchar2 ,
                      p_attrib_type in varchar2 ) return varchar2 ;
--
function get_src_effective_date return date ;
-- added this fucntion for the bug 5052820
function get_trg_effective_date return date;
--
procedure assign_value(p_column_name varchar2,
                       p_column_type varchar2,
                       p_value       varchar2,
                       p_reset_flag  varchar2 default 'N',
                       p_source_flag varchar2 default 'N');
--
Procedure dynamic_pltab_populate (p_ddf_column_name           in varchar2
                                  , p_copy_entity_result_id   in number
                                  , p_copy_entity_txn_id      in number
                                  , p_column_name             in varchar2
                                  , p_column_type             in varchar2
                                  , p_reset_flag              in varchar2
                                  , p_source_flag             in varchar2);
--
function get_alias(p_column_name in varchar2) return varchar2 ;
--
function get_user_pref( p_user_id                    number
                        , p_transaction_category_id  number
                        , p_table_route_id           number )
return boolean ;
--
procedure log_error (p_table_route_id        in varchar2 ,
                     p_err_key               in varchar2 ) ;
--
end PQH_GENERIC;

 

/
