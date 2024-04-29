--------------------------------------------------------
--  DDL for Package IBW_TR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_TR_PVT" AUTHID CURRENT_USER AS
/*$Header: IBWTRS.pls 120.5 2005/08/31 08:01 schittar noship $*/

/*
** change_tracking_sequence - change the sequence definition and profile values
**
*/
PROCEDURE change_tracking_sequence(xerrbuf out NOCOPY varchar2, xerrcode out NOCOPY number,
				   visitidwindow in number, visitoridwindow in number);

/* instance_id - get the unique instance identifier
**
** Returns an unique instance id formed from database host id and the sid.
**
*/
function instance_id return VARCHAR2;

END IBW_TR_PVT;

 

/
