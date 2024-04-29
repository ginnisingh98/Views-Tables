--------------------------------------------------------
--  DDL for Package CSD_WF_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_WF_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvwfps.pls 120.0 2008/05/12 07:39:57 subhat noship $ */

/* ---------------------------------------------------------*/
/* Define global variables                                  */
/* ---------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_WF_DEMO_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvrwfs.pls';


/*-----------------------------------------------------------------*/
/* procedure name: get_ro_details_wf                               */
/* description   : Derive RO details for the workflow              */
/* The procedure also checks to see if a role already exists for   */
/* the user, if not, it will create a ad-hoc role for the user     */
/*-----------------------------------------------------------------*/
PROCEDURE get_ro_details_wf(itemtype   in         varchar2,
                            itemkey    in         varchar2,
                            actid      in         number,
                            funcmode   in         varchar2,
                            resultout  out NOCOPY varchar2);

END CSD_WF_PROCESS_PVT;

/
