--------------------------------------------------------
--  DDL for Package PER_FR_UPGRADE_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_UPGRADE_DATA_PKG" AUTHID CURRENT_USER AS
/* $Header: perfrupd.pkh 115.3 2002/12/02 11:51:42 sfmorris noship $ */

procedure write_log(p_message in varchar2);

procedure write_log_message(p_message_name      in varchar2
                        ,p_token1       in varchar2 default null
                        ,p_token2       in varchar2 default null
                        ,p_token3       in varchar2 default null);

function get_translation(p_lookup_code in varchar2) return varchar2;

function check_dfs(p_df in varchar2) return number;

function check_lookups(p_fr_lookup_type in varchar2,
                        p_core_lookup_type in varchar2) return number;

Procedure run_upgrade(errbuf          OUT NOCOPY VARCHAR2
                 ,retcode             OUT NOCOPY NUMBER
                 ,p_business_group_id IN NUMBER
                 ,p_upgrade_type      IN VARCHAR2);


END PER_FR_UPGRADE_DATA_PKG;

 

/
