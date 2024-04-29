--------------------------------------------------------
--  DDL for Package ZPB_DC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_DC_UTIL" AUTHID CURRENT_USER AS
/* $Header: ZPBDCUTS.pls 120.1 2007/12/04 14:34:06 mbhat ship $ */


   PROCEDURE freeze_worksheet( p_object_id IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
			       x_msg OUT NOCOPY VARCHAR2);


   PROCEDURE unfreeze_worksheet( p_object_id IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
			       x_msg OUT NOCOPY VARCHAR2);

   PROCEDURE refresh_worksheet( p_object_id IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
			       x_msg OUT NOCOPY VARCHAR2);



END ZPB_DC_UTIL;

/
