--------------------------------------------------------
--  DDL for Package WF_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_INSTALL" authid CURRENT_USER as
/* $Header: wfparts.pls 120.4 2006/03/26 22:07:55 rtodi noship $ */

Procedure CreateTable (
  partition in boolean,
  utl_dir   in varchar2,
  tblname    in varchar2,
  tblspcname in varchar2 default null,
  modified   out nocopy boolean
);

Procedure CreateIndex (
  partition  in boolean,
  utl_dir   in varchar2,
  idxname    in varchar2,
  tblspcname in varchar2 default null
);

PROCEDURE Start_partition ( p_tablespace  in varchar2 default null,
                  partition   out nocopy boolean);


end Wf_Install;

 

/
