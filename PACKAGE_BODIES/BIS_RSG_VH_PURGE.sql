--------------------------------------------------------
--  DDL for Package Body BIS_RSG_VH_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RSG_VH_PURGE" AS
/*$Header: BISVHPUB.pls 120.1 2006/02/10 05:56:24 aguwalan noship $*/
procedure purge_history_tables(Errbuf out nocopy varchar2, Retcode out nocopy varchar2) is
begin
  delete from bis_request_set_options opt where request_set_name not in
    (select request_set_name from fnd_request_sets req
     where req.request_set_name = opt.request_set_name and req.application_id=opt.set_app_id );

  delete from bis_request_set_objects obj where request_set_name not in
    (select request_set_name from fnd_request_sets req
     where req.request_set_name = obj.request_set_name and req.application_id=obj.set_app_id );

  commit;
end;

END BIS_RSG_VH_PURGE;

/
