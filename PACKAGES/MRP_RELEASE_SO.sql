--------------------------------------------------------
--  DDL for Package MRP_RELEASE_SO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_RELEASE_SO" AUTHID CURRENT_USER AS
/*$Header: MRPRLSOS.pls 120.0.12010000.1 2008/07/28 04:49:23 appldev ship $ */

PROCEDURE release_so_program
(
errbuf                  OUT NOCOPY VARCHAR2
,retcode                 OUT NOCOPY NUMBER,
p_batch_id IN NUMBER,
p_dblink in varchar2,
p_instance_id in number
);

END mrp_release_so;

/
