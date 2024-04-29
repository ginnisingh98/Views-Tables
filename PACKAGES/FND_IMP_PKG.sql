--------------------------------------------------------
--  DDL for Package FND_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_IMP_PKG" AUTHID CURRENT_USER AS
/* $Header: afimps.pls 120.5 2006/05/30 14:52:23 angunda noship $ */

PROCEDURE makesingletons(request_id__ INTEGER);
--PROCEDURE makeprereqs(request_id__ INTEGER, bug_no__ INTEGER);
PROCEDURE rsync1(request_id__ INTEGER);
PROCEDURE rsync2(request_id__ INTEGER);
PROCEDURE refresh(request_id__ INTEGER, stage__ CHAR);
PROCEDURE refresh1M(request_id__ INTEGER, virtual_patch_id__ INTEGER, snapshot_id__ INTEGER);
PROCEDURE refresh1(patch_id__ INTEGER, snapshot_id__ INTEGER);
PROCEDURE refresh2(patch_id__ INTEGER, snapshot_id__ INTEGER);
PROCEDURE refreshCP(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY NUMBER);
PROCEDURE refreshCP2(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY NUMBER);
PROCEDURE refreshAll;
PROCEDURE sync(table_name VARCHAR2);
PROCEDURE wipe(table_name VARCHAR2);
PROCEDURE wipedata(patch_id__ INTEGER, snapshot_id__ INTEGER);
PROCEDURE logstats(request_id__ INTEGER, stage__ CHAR);
PROCEDURE aggregate_patches(request_id__ INTEGER);
PROCEDURE set_aggregate_list(request_id__ INTEGER, buglist__ ad_patch_impact_api.t_rec_patch);
PROCEDURE set_aggregate_list(request_id__ INTEGER, patchlist__ ad_patch_impact_api.t_recomm_patch_tab);
--PROCEDURE compute_prereqs(request_id__ INTEGER);
PROCEDURE refreshCPAgg(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY NUMBER, request_id__ IN INTEGER);
FUNCTION  lastupdate(snapshot_id__ INTEGER, patch_id__ INTEGER) return DATE;
FUNCTION  is_aggregate_running(request_id__ INTEGER) return VARCHAR2;
FUNCTION  get_aggregate_list(request_id__ INTEGER) return VARCHAR2;
FUNCTION  isFileTypeAffected(request_id__ INTEGER, snapshot_id__ INTEGER, filetype__ VARCHAR2) RETURN VARCHAR2;
END FND_IMP_PKG;

 

/
