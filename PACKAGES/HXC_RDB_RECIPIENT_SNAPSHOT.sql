--------------------------------------------------------
--  DDL for Package HXC_RDB_RECIPIENT_SNAPSHOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RDB_RECIPIENT_SNAPSHOT" AUTHID CURRENT_USER AS
/* $Header: hxcrdbrecsnp.pkh 120.1.12010000.1 2010/03/30 14:16:15 asrajago noship $ */

TYPE VARCHARTAB IS TABLE OF VARCHAR2(150);
TYPE NUMBERTAB IS TABLE OF NUMBER;
TYPE DATETAB IS TABLE OF DATE;

PROCEDURE get_snapshot(errbuff      OUT NOCOPY VARCHAR2,
                       retcode      OUT NOCOPY NUMBER,
                       p_request_id IN         NUMBER DEFAULT 0);

END HXC_RDB_RECIPIENT_SNAPSHOT;


/
