--------------------------------------------------------
--  DDL for Package ENI_DBI_PCO_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_PCO_LOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: ENIPCOLS.pls 115.11 2004/05/12 04:26 skadamal noship $ */
procedure validate_set_parameters(
p_num_workers in number,
p_batch_size in number);

procedure assign_worker_ids(p_collect_mode IN VARCHAR2);

procedure launch_workers(p_collect_mode IN VARCHAR2);

procedure wait_for_workers(p_collect_mode IN VARCHAR2);

procedure cleanup;

procedure collect_modified_bills;

procedure process_incident_interface_g
(
  o_err_code out nocopy varchar2,
  o_err_msg out nocopy varchar2,
  p_num_workers in number default 1,
  p_organization_id IN NUMBER default NULL,
  p_batch_size in number default 10,
  p_collect_mode IN VARCHAR2 default 'INIT',
  p_purge_fact IN VARCHAR2 default 'YES'
);
PROCEDURE part_count_collect_worker
(
    o_error_msg OUT NOCOPY VARCHAR2,
    o_error_code OUT NOCOPY VARCHAR2,
    p_worker_id IN NUMBER DEFAULT 1,
    p_batch_size IN NUMBER DEFAULT 50,
    p_collect_mode IN VARCHAR2 DEFAULT 'INIT'
);
PROCEDURE part_count_collect
(
    p_worker_id IN NUMBER,
    p_collect_mode IN VARCHAR2 DEFAULT 'INIT',
    o_error_occured OUT NOCOPY NUMBER
);

END ENI_DBI_PCO_LOAD_PKG;

 

/
