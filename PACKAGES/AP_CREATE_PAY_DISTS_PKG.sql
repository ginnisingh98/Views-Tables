--------------------------------------------------------
--  DDL for Package AP_CREATE_PAY_DISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CREATE_PAY_DISTS_PKG" AUTHID CURRENT_USER AS
/* $Header: appdists.pls 120.4 2004/10/28 23:26:35 pjena noship $ */

    PROCEDURE overlay_segments
	(P_primary_segments	IN	FND_FLEX_EXT.SEGMENTARRAY
	,P_overlay_segments	IN	FND_FLEX_EXT.SEGMENTARRAY
	,P_num_segments		IN	NUMBER
	,P_chart_of_accounts_id	IN	NUMBER
	,P_flex_segment_num	IN	NUMBER
	,P_flex_qualifier_name	IN	VARCHAR2
	,P_segment_delimiter	IN	VARCHAR2
	,P_ccid			OUT NOCOPY NUMBER
	,P_unbuilt_flex		OUT NOCOPY VARCHAR2
	,P_reason_unbuilt_flex	OUT NOCOPY VARCHAR2
	,P_calling_sequence	IN	VARCHAR2
	);

END AP_CREATE_PAY_DISTS_PKG;

 

/
