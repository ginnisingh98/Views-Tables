--------------------------------------------------------
--  DDL for Package AME_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_MIGRATION_PKG" AUTHID CURRENT_USER as
  /* $Header: amecpmig.pkh 120.0 2005/09/02 03:57 mbocutt noship $ */
  procedure migrate_amea_users
    (errbuf                 out nocopy varchar2
    ,retcode                out nocopy number
    );
  procedure migrate_item_class_usages(errbuf  out nocopy varchar2
                                     ,retcode out nocopy number
                                     );
  procedure migrate_all
    (errbuf                 out nocopy varchar2
    ,retcode                out nocopy number
    );
  procedure migrate_to_ameb
    (errbuf                 out nocopy varchar2
    ,retcode                out nocopy number
    ,migration_type         in varchar2
    );
end ame_migration_pkg;

 

/
