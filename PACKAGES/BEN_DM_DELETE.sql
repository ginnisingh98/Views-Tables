--------------------------------------------------------
--  DDL for Package BEN_DM_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_DELETE" AUTHID CURRENT_USER AS
/* $Header: benfdmpmdel.pkh 120.0 2006/05/04 04:51:36 nkkrishn noship $ */

procedure main(
 errbuf                 out nocopy  varchar2,
 retcode                out nocopy  number ,
 p_migration_id         in   number ,
 p_concurrent_process   in   varchar2 default 'Y',
 p_last_migration_date  in   varchar2,
 p_process_number       in   number ,
 p_dir_name             in   varchar2,
 p_file_name            in   varchar2,
 p_delimiter            in   varchar2,
 p_business_group_id    in   number default null) ;

procedure delete_person(p_person_id number);

end ben_dm_delete;

 

/
