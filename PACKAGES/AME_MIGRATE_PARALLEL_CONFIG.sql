--------------------------------------------------------
--  DDL for Package AME_MIGRATE_PARALLEL_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_MIGRATE_PARALLEL_CONFIG" AUTHID CURRENT_USER as
  /* $Header: amemigcfg.pkh 120.1.12000000.1 2007/01/17 23:54:51 appldev noship $ */
  procedure migrate_approval_group_config
    (errbuf                 out nocopy varchar2
    ,retcode                out nocopy number
    );

  procedure migrate_action_type_config
    (errbuf                 out nocopy varchar2
    ,retcode                out nocopy number
    );

  procedure migrate_parallel_config
    (errbuf                 out nocopy varchar2
    ,retcode                out nocopy number
    );

end ame_migrate_parallel_config;

 

/
