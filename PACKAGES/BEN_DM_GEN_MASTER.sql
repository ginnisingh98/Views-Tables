--------------------------------------------------------
--  DDL for Package BEN_DM_GEN_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_GEN_MASTER" AUTHID CURRENT_USER AS
/* $Header: benfdmgenm.pkh 120.0 2006/05/04 04:48:46 nkkrishn noship $ */

g_file_handle      utl_file.file_type;

procedure main_generator
(
 errbuf                 out nocopy  varchar2,
 retcode                out nocopy  number ,
 p_migration_id         in   number ,
 p_concurrent_process   in   varchar2 default 'Y',
 p_last_migration_date  in   varchar2,
 p_process_number       in   number ,
 p_dir_name             in   varchar2,
 p_file_name            in   varchar2,
 p_delimiter            in   varchar2 default fnd_global.local_chr(01),
 p_business_group_id    in   number default null
) ;



Procedure   download
(
 errbuf                 out nocopy  varchar2,
 retcode                out nocopy  number ,
 p_migration_id         in   number ,
 p_concurrent_process   in   varchar2 default 'Y',
 p_last_migration_date  in   varchar2,
 p_process_number       in   number,
 p_dir_name             in   varchar2,
 p_file_name            in   varchar2,
 p_delimiter            in   varchar2 default fnd_global.local_chr(01),
 p_business_group_id    in   number  default null
) ;


Procedure   upload
(
 errbuf                 out nocopy  varchar2,
 retcode                out nocopy  number ,
 p_migration_id         in   number ,
 p_concurrent_process   in   varchar2 default 'Y',
 p_last_migration_date  in   varchar2,
 p_process_number       in   number,
 p_dir_name             in   varchar2,
 p_file_name            in   varchar2,
 p_delimiter            in   varchar2 default fnd_global.local_chr(01),
 p_business_group_id    in   number  default null
) ;

end ben_dm_gen_master;

 

/
