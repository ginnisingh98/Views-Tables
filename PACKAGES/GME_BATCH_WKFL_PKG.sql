--------------------------------------------------------
--  DDL for Package GME_BATCH_WKFL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_BATCH_WKFL_PKG" AUTHID CURRENT_USER AS
/* $Header: GMEBTWFS.pls 120.0 2006/02/14 07:26:25 kxhunt noship $ */
/* +=========================================================================+
 |                Copyright (c) 2002 Oracle Corporation                    |
 |                         All righTs reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMEBTWFB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains Workflow procedures for GME-OM Integration    |
 |     reservation.                                                        |
 |                                                                         |
 | --  Init_wf()                                                           |
 | --  Check_event()                                                       |
 | --  Insert_gml_batch_so_workflow()                                      |
 |                                                                         |
 | HISTORY                                                                 |
 |              10-Oct-2003  nchekuri        Created                       |
 |                                                                         |
 +=========================================================================+ */

PROCEDURE init_wf (
        p_itemtype           IN VARCHAR2
      , p_itemkey            IN   NUMBER
      ,	p_approver           IN   NUMBER
      , p_so_header_id       IN   NUMBER
      ,	p_so_line_id         IN   NUMBER
      ,	p_batch_id           IN   NUMBER
      , p_batch_line_id      IN   NUMBER
      ,	p_fpo_id             IN   NUMBER
      , p_organization_id    IN   NUMBER
      , p_lot_no             IN   VARCHAR2 DEFAULT NULL
      ,	p_action_code        IN   VARCHAR2 );

PROCEDURE check_event(
        p_itemtype      IN VARCHAR2
      , p_itemkey       IN VARCHAR2
      , p_actid         IN NUMBER
      , p_funcmode      IN VARCHAR2
      , p_resultout     OUT NOCOPY VARCHAR2);

/* Global Variables */

g_itemkey_num  NUMBER := 0;

END GME_BATCH_WKFL_PKG;

 

/
