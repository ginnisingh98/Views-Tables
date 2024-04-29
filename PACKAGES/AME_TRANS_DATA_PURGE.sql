--------------------------------------------------------
--  DDL for Package AME_TRANS_DATA_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_TRANS_DATA_PURGE" AUTHID CURRENT_USER as
/* $Header: amepurge.pkh 120.1 2007/12/19 17:52:03 prasashe noship $ */
  procedure purgeTransData(errbuf              out nocopy varchar2,   --needed by concurrent manager.
                           retcode             out nocopy number,     --needed by concurrent manager.
                           applicationIdIn in number,
                           purgeTypeIn in varchar2);
  procedure purgeDeviationData(errbuf            out nocopy varchar2,
                            retcode            out nocopy number,
                            applicationIdIn in number default null,
                            ameApplicationId    in number default null,
                            endDateIn         in  varchar2 default null);
end ame_trans_data_purge;

/
