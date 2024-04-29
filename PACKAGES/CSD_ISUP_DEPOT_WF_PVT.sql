--------------------------------------------------------
--  DDL for Package CSD_ISUP_DEPOT_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_ISUP_DEPOT_WF_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvisws.pls 120.3 2008/02/28 11:10:52 subhat noship $ */

/* ---------------------------------------------------------*/
/* Define global variables                                  */
/* ---------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_Isupport_Flow_PVT' ;
G_FILE_NAME CONSTANT VARCHAR2(20) := 'csdIsupports.pls';


/*-----------------------------------------------------------------*/
/* procedure name: create_ro_wf                               */
/* description   :  Create RO and Logistics for a SR*/
/*                                                                 */
/*-----------------------------------------------------------------*/




PROCEDURE check_sr_details_wf(itemtype   in         varchar2,
                            itemkey    in         varchar2,
                            actid      in         number,
                            funcmode   in         varchar2,
                            resultout  out NOCOPY varchar2);



PROCEDURE create_ro_wf(itemtype   in         varchar2,
                            itemkey    in         varchar2,
                            actid      in         number,
                            funcmode   in         varchar2,
                            resultout  out NOCOPY  varchar2);






END  CSD_ISUP_DEPOT_WF_PVT;

/
